import argparse
import json
import re
import shutil
import sqlite3
from datetime import datetime, timezone
from pathlib import Path


APP_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE_DB = (
    APP_ROOT.parent
    / "MeonSSam-DB"
    / "data"
    / "processed"
    / "problem_bank_incremental"
    / "problem_bank.sqlite"
)
DEFAULT_BANK_ASSET = APP_ROOT / "assets" / "question_bank" / "app_bank.sqlite"
DEFAULT_MEDIA_DIR = APP_ROOT / "assets" / "question_media"
GRADE_LABEL_PATTERN = re.compile(r"\s*\([^)]*\d\s*" + "\uAE09" + r"[^)]*\)")
OCR_PROMPT_REPLACEMENTS = {
    "\uC288\u043D\u0430\u0443\uC800": "\uC288\uB098\uC6B0\uC800",
}
RANGE_MARKER_PATTERN = re.compile(
    r"<\s*"
    + "\uBB38\uC81C"
    + r"\s*(\d+)\s*[-~\uFF5E]\s*(\d+)\s*>"
)
TRAILING_RANGE_SECTION_PATTERN = re.compile(r"\s*\u25C6\s*[^<\u25C6]+$")
TRAILING_DIAMOND_SECTION_PATTERN = re.compile(
    r"\s*[\u25C6\u25C7\u25C8]\s*[^\u25C6\u25C7\u25C8]+$"
)
TRAILING_CATEGORY_PATTERN = re.compile(
    r"\s*-\s*(?:"
    + "|".join(
        re.escape(term)
        for term in [
            "\uADC0",
            "\uCF54",
            "\uB208",
            "\uC8FC\uB465\uC774",
            "\uC785",
            "\uBAA9",
            "\uBAB8",
            "\uB2E4\uB9AC",
            "\uC9C0\uC138",
            "\uD53C\uBAA8 & \uBAA8\uC0C9",
            "\uBCF4\uC591",
            "\uADF8\uB8E8\uBC0D \uC6A9\uC5B4",
        ]
    )
    + r")\s*$"
)
CHOICE_TEXT_OVERRIDES = {
    (539, 1): "전지는 나이프로 빗질 하는듯한 느낌으로 날에 걸리는 털을 뽑아준다",
    (539, 2): "뻣뻣한 털은 힘을 주지 않으면 뽑히지 않으므로 힘을 주지 않음으로써 뻣뻣한 털을 뽑지 않고 유지할 수 있다",
    (539, 3): "후지의 바깥쪽도 전지와 같은 요령으로 빗질하듯이 뽑아나간다",
    (539, 4): "전 후지 모두 이 작업 후에 부드러운 털이 자라나. 그 털에 뺏뻣한 털이 휘감겨 폭이 넓어지게 되는 형태를 만들 수 있다.",
}


SCHEMA = """
PRAGMA foreign_keys = ON;

CREATE TABLE metadata (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

CREATE TABLE stimuli (
  id TEXT PRIMARY KEY,
  asset_path TEXT NOT NULL UNIQUE,
  source_path TEXT NOT NULL UNIQUE,
  source_page INTEGER,
  width INTEGER,
  height INTEGER
);

CREATE TABLE questions (
  id TEXT PRIMARY KEY,
  question_number INTEGER NOT NULL UNIQUE,
  prompt TEXT NOT NULL,
  body_text TEXT NOT NULL DEFAULT '',
  answer_label TEXT,
  review_status TEXT NOT NULL DEFAULT 'unreviewed',
  source_markdown TEXT NOT NULL,
  source_pdf_sha256 TEXT
);

CREATE TABLE choices (
  id TEXT PRIMARY KEY,
  question_id TEXT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  label TEXT NOT NULL,
  text TEXT NOT NULL,
  position INTEGER NOT NULL,
  UNIQUE(question_id, position)
);

CREATE TABLE question_stimuli (
  question_id TEXT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  stimulus_id TEXT NOT NULL REFERENCES stimuli(id) ON DELETE CASCADE,
  position INTEGER NOT NULL,
  PRIMARY KEY(question_id, stimulus_id, position)
);

CREATE TABLE question_sets (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  bank_version TEXT NOT NULL
);

CREATE TABLE question_set_items (
  set_id TEXT NOT NULL REFERENCES question_sets(id) ON DELETE CASCADE,
  question_id TEXT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  position INTEGER NOT NULL,
  PRIMARY KEY(set_id, position)
);

CREATE INDEX idx_questions_number ON questions(question_number);
CREATE INDEX idx_choices_question ON choices(question_id, position);
CREATE INDEX idx_question_stimuli_question ON question_stimuli(question_id, position);
CREATE INDEX idx_question_set_items_question ON question_set_items(question_id);
"""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-db", type=Path, default=DEFAULT_SOURCE_DB)
    parser.add_argument("--bank-asset", type=Path, default=DEFAULT_BANK_ASSET)
    parser.add_argument("--media-dir", type=Path, default=DEFAULT_MEDIA_DIR)
    parser.add_argument("--set-size", type=int, default=20)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if not args.source_db.exists():
        raise FileNotFoundError(args.source_db)

    args.bank_asset.parent.mkdir(parents=True, exist_ok=True)
    args.media_dir.mkdir(parents=True, exist_ok=True)

    if args.bank_asset.exists():
        args.bank_asset.unlink()
    for old_media in args.media_dir.glob("img_*"):
        if old_media.is_file():
            old_media.unlink()

    source = sqlite3.connect(args.source_db)
    source.row_factory = sqlite3.Row
    target = sqlite3.connect(args.bank_asset)
    target.executescript(SCHEMA)

    rows = list(
        source.execute(
            """
            SELECT id, question_number, question_text, raw_markdown, choices_json, answer,
                   image_paths_json, source_markdown, source_pdf_sha256
            FROM questions
            ORDER BY question_number
            """
        )
    )

    image_map: dict[str, tuple[str, str]] = {}
    range_image_paths_by_question = _future_range_image_paths(rows)
    range_body_text_by_question = _future_range_body_texts(rows)

    def stimulus_for(source_path: str) -> tuple[str, str]:
        existing = image_map.get(source_path)
        if existing is not None:
            return existing

        source_file = Path(source_path)
        if not source_file.exists():
            raise FileNotFoundError(source_file)

        stimulus_id = f"stimulus-{len(image_map) + 1:04d}"
        extension = source_file.suffix.lower() or ".webp"
        filename = f"img_{len(image_map) + 1:04d}{extension}"
        target_file = args.media_dir / filename
        shutil.copy2(source_file, target_file)

        asset_path = f"assets/question_media/{filename}"
        image_map[source_path] = (stimulus_id, asset_path)
        target.execute(
            """
            INSERT INTO stimuli(id, asset_path, source_path, source_page, width, height)
            VALUES (?, ?, ?, ?, NULL, NULL)
            """,
            (stimulus_id, asset_path, source_path, _page_number(source_path)),
        )
        return image_map[source_path]

    active_image_paths: list[str] = []
    for row in rows:
        source_text = _clean_source_text(row["question_text"])
        source_markdown = _clean_source_text(row["raw_markdown"])
        prompt, body_text = _split_prompt_and_body(
            source_markdown, source_text
        )
        prompt = _normalize_prompt(prompt)
        body_text = _combine_body_text(
            range_body_text_by_question.get(row["question_number"]), body_text
        )
        target.execute(
            """
            INSERT INTO questions(
              id, question_number, prompt, body_text, answer_label, review_status,
              source_markdown, source_pdf_sha256
            )
            VALUES (?, ?, ?, ?, ?, 'unreviewed', ?, ?)
            """,
            (
                row["id"],
                row["question_number"],
                prompt,
                body_text,
                row["answer"],
                row["source_markdown"],
                row["source_pdf_sha256"],
            ),
        )

        choices = json.loads(row["choices_json"])
        for position, choice in enumerate(choices, start=1):
            choice_text = _clean_choice_text(
                row["question_number"], position, str(choice.get("text", ""))
            )
            target.execute(
                """
                INSERT INTO choices(id, question_id, label, text, position)
                VALUES (?, ?, ?, ?, ?)
                """,
                (
                    f"{row['id']}-c{position:02d}",
                    row["id"],
                    str(choice.get("label", position)),
                    choice_text,
                    position,
                ),
            )

        source_image_paths = json.loads(row["image_paths_json"])
        if source_image_paths:
            active_image_paths = source_image_paths
            image_paths = source_image_paths
        elif row["question_number"] in range_image_paths_by_question:
            active_image_paths = range_image_paths_by_question[row["question_number"]]
            image_paths = active_image_paths
        elif _uses_active_image_prompt(source_text):
            image_paths = active_image_paths
        else:
            active_image_paths = []
            image_paths = []

        for position, source_path in enumerate(image_paths, start=1):
            stimulus_id, _ = stimulus_for(source_path)
            target.execute(
                """
                INSERT INTO question_stimuli(question_id, stimulus_id, position)
                VALUES (?, ?, ?)
                """,
                (row["id"], stimulus_id, position),
            )

    bank_version = datetime.now(timezone.utc).strftime("%Y%m%d%H%M%S")
    _insert_question_sets(target, rows, args.set_size, bank_version)
    _insert_metadata(target, args, rows, image_map, bank_version)

    target.commit()
    source.close()
    target.close()

    print(f"questions={len(rows)}")
    print(f"stimuli={len(image_map)}")
    print(f"sets={(len(rows) + args.set_size - 1) // args.set_size}")
    print(f"bank={args.bank_asset}")
    print(f"media={args.media_dir}")


def _insert_question_sets(
    target: sqlite3.Connection,
    rows: list[sqlite3.Row],
    set_size: int,
    bank_version: str,
) -> None:
    for set_index, start in enumerate(range(0, len(rows), set_size), start=1):
        set_id = f"set-{set_index:03d}"
        title = f"Set {set_index:03d}"
        target.execute(
            "INSERT INTO question_sets(id, title, bank_version) VALUES (?, ?, ?)",
            (set_id, title, bank_version),
        )
        for position, row in enumerate(rows[start : start + set_size], start=1):
            target.execute(
                """
                INSERT INTO question_set_items(set_id, question_id, position)
                VALUES (?, ?, ?)
                """,
                (set_id, row["id"], position),
            )


def _insert_metadata(
    target: sqlite3.Connection,
    args: argparse.Namespace,
    rows: list[sqlite3.Row],
    image_map: dict[str, tuple[str, str]],
    bank_version: str,
) -> None:
    metadata = {
        "schema_version": "1",
        "bank_version": bank_version,
        "source_db": str(args.source_db),
        "question_count": str(len(rows)),
        "stimulus_count": str(len(image_map)),
        "set_size": str(args.set_size),
        "review_status": "unreviewed",
    }
    target.executemany(
        "INSERT INTO metadata(key, value) VALUES (?, ?)",
        sorted(metadata.items()),
    )


def _page_number(source_path: str) -> int | None:
    for part in Path(source_path).parts:
        if part.startswith("page_") and part.endswith("_images"):
            value = part.removeprefix("page_").removesuffix("_images")
            if value.isdigit():
                return int(value)
    return None


def _uses_numbered_image_prompt(text: str) -> bool:
    return any(_is_circled_number(character) for character in text)


def _uses_active_image_prompt(text: str) -> bool:
    compact = re.sub(r"\s+", "", text)
    return (
        _uses_numbered_image_prompt(text)
        or "\uD138\uAE38\uC774" in compact
        or "\uD138\uC758\uAE38\uC774" in compact
        or "\uBC88\uD638\uC640\uD138" in compact
        or "\uC2A4\uD2B8\uB9AC\uD551\uAE38\uC774" in compact
    )


def _is_circled_number(character: str) -> bool:
    codepoint = ord(character)
    return (
        0x2460 <= codepoint <= 0x2473
        or 0x3251 <= codepoint <= 0x325F
        or 0x32B1 <= codepoint <= 0x32BF
    )


def _future_range_image_paths(rows: list[sqlite3.Row]) -> dict[int, list[str]]:
    result: dict[int, list[str]] = {}
    for row in rows:
        image_paths = json.loads(row["image_paths_json"])
        if not image_paths:
            continue

        for match in RANGE_MARKER_PATTERN.finditer(row["question_text"]):
            start = int(match.group(1))
            end = int(match.group(2))
            if start <= int(row["question_number"]):
                continue

            range_paths = [image_paths[-1]]
            for question_number in range(start, end + 1):
                result[question_number] = range_paths
    return result


def _future_range_body_texts(rows: list[sqlite3.Row]) -> dict[int, str]:
    result: dict[int, str] = {}
    seen_sources: set[str] = set()
    for row in rows:
        _collect_range_body_texts(
            result,
            row["raw_markdown"],
            current_question_number=int(row["question_number"]),
        )

        source_markdown = str(row["source_markdown"])
        if source_markdown in seen_sources:
            continue
        seen_sources.add(source_markdown)
        source_file = Path(source_markdown)
        if source_file.exists():
            _collect_range_body_texts(
                result,
                source_file.read_text(encoding="utf-8"),
                current_question_number=0,
            )
    return result


def _collect_range_body_texts(
    result: dict[int, str],
    markdown: str,
    current_question_number: int,
) -> None:
    matches = list(RANGE_MARKER_PATTERN.finditer(markdown))
    for index, match in enumerate(matches):
        start = int(match.group(1))
        end = int(match.group(2))
        if start <= current_question_number:
            continue

        block_end = matches[index + 1].start() if index + 1 < len(matches) else None
        block = markdown[match.start() : block_end]
        body_text = _range_body_text(block, start, end)
        if not body_text:
            continue

        for question_number in range(start, end + 1):
            result[question_number] = body_text


def _range_body_text(block: str, start: int, end: int) -> str:
    lines: list[str] = []
    details_found = False
    for line in block.splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith("!["):
            continue

        marker = RANGE_MARKER_PATTERN.search(stripped)
        if marker:
            title = stripped[marker.end() :].strip()
            if title:
                lines.append(f"\uBB38\uC81C {start}~{end}\n{title}")
            else:
                lines.append(f"\uBB38\uC81C {start}~{end}")
            continue

        if re.match(r"^\d+\s*\.", stripped):
            break

        details_found = True
        lines.append(stripped)

    if not details_found:
        return ""
    return _normalize_text_spacing("\n\n".join(lines))


def _split_prompt_and_body(raw_markdown: str, fallback_prompt: str) -> tuple[str, str]:
    content_lines: list[str] = []
    for line in raw_markdown.splitlines():
        stripped = line.strip()
        if not stripped:
            content_lines.append("")
            continue
        if stripped.startswith("!["):
            continue
        if _is_choice_line(stripped):
            break
        content_lines.append(stripped)

    while content_lines and not content_lines[0]:
        content_lines.pop(0)
    while content_lines and not content_lines[-1]:
        content_lines.pop()

    if not content_lines:
        return fallback_prompt.strip(), ""

    prompt = content_lines[0]
    body = _join_body_lines(content_lines[1:])
    return prompt, body


def _normalize_prompt(prompt: str) -> str:
    normalized = prompt
    for source, replacement in OCR_PROMPT_REPLACEMENTS.items():
        normalized = normalized.replace(source, replacement)
    normalized = GRADE_LABEL_PATTERN.sub("", normalized)
    return _normalize_text_spacing(normalized)


def _clean_source_text(text: str) -> str:
    cleaned = _strip_future_range_block(text)
    cleaned = TRAILING_DIAMOND_SECTION_PATTERN.sub("", cleaned)
    cleaned = TRAILING_CATEGORY_PATTERN.sub("", cleaned)
    return _normalize_text_spacing(cleaned)


def _clean_choice_text(question_number: int, position: int, text: str) -> str:
    override = CHOICE_TEXT_OVERRIDES.get((question_number, position))
    if override is not None:
        return override

    cleaned = _strip_future_range_block(text)
    cleaned = TRAILING_DIAMOND_SECTION_PATTERN.sub("", cleaned)
    cleaned = TRAILING_CATEGORY_PATTERN.sub("", cleaned)
    return _normalize_text_spacing(cleaned)


def _strip_future_range_block(text: str) -> str:
    match = RANGE_MARKER_PATTERN.search(text)
    if match is None:
        return text
    cleaned = text[: match.start()].rstrip()
    return TRAILING_RANGE_SECTION_PATTERN.sub("", cleaned).rstrip()


def _combine_body_text(primary: str | None, secondary: str) -> str:
    parts = [part.strip() for part in (primary, secondary) if part and part.strip()]
    return "\n\n".join(parts)


def _normalize_text_spacing(text: str) -> str:
    text = re.sub(r"<sup>\s*([^<]+?)\s*</sup>\s*", r"\1 ", text)
    text = re.sub(r"</?[^>]+>", "", text)
    text = _normalize_math_text(text)
    lines = [re.sub(r"[ \t]{2,}", " ", line.strip()) for line in text.splitlines()]
    while lines and not lines[0]:
        lines.pop(0)
    while lines and not lines[-1]:
        lines.pop()
    return "\n".join(lines).strip()


def _normalize_math_text(text: str) -> str:
    normalized = re.sub(r"\$\s*([^$]+?)\s*\$", r"\1", text)
    normalized = normalized.replace(r"\sim", " ~ ")
    normalized = re.sub(r"\^\s*\{\s*\\circ\s*\}", "°", normalized)
    normalized = re.sub(r"\^\s*\\circ", "°", normalized)
    normalized = normalized.replace(r"\circ", "°")
    if "°" in normalized:
        normalized = re.sub(r"\s*~\s*", " ~ ", normalized)
    normalized = re.sub(r"[ \t]{2,}", " ", normalized)
    return normalized.strip()


def _is_choice_line(line: str) -> bool:
    stripped = line.lstrip("-* ").lstrip()
    if not stripped:
        return False
    if stripped[0] in "①②③④⑤⑥⑦⑧⑨⑩":
        return True
    return bool(re.match(r"^[1-9]\s*(?:[.)]\s+|:\s*)", stripped))


def _join_body_lines(lines: list[str]) -> str:
    paragraphs: list[str] = []
    current: list[str] = []
    for line in lines:
        if not line:
            if current:
                paragraphs.append(" ".join(current))
                current = []
            continue
        current.append(line)
    if current:
        paragraphs.append(" ".join(current))
    return "\n\n".join(paragraphs)


if __name__ == "__main__":
    main()
