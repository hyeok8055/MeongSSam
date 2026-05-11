import argparse
import re
import sqlite3
from collections import defaultdict
from pathlib import Path


APP_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_BANK_ASSET = APP_ROOT / "assets" / "question_bank" / "app_bank.sqlite"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--bank-asset", type=Path, default=DEFAULT_BANK_ASSET)
    parser.add_argument("--expected-questions", type=int, default=800)
    parser.add_argument("--set-size", type=int, default=20)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    failures: list[str] = []

    if not args.bank_asset.exists():
        raise FileNotFoundError(args.bank_asset)

    connection = sqlite3.connect(args.bank_asset)
    connection.row_factory = sqlite3.Row

    question_count = _single_int(connection, "SELECT count(*) FROM questions")
    if question_count != args.expected_questions:
        failures.append(f"questions expected {args.expected_questions}, got {question_count}")

    set_counts = list(
        connection.execute(
            """
            SELECT set_id, count(*) AS count
            FROM question_set_items
            GROUP BY set_id
            ORDER BY set_id
            """
        )
    )
    bad_sets = [
        f"{row['set_id']}={row['count']}"
        for row in set_counts
        if row["count"] != args.set_size
    ]
    if bad_sets:
        failures.append("non-20 sets: " + ", ".join(bad_sets))

    missing_media = []
    for row in connection.execute("SELECT asset_path FROM stimuli ORDER BY id"):
        asset_file = APP_ROOT / row["asset_path"]
        if not asset_file.exists():
            missing_media.append(row["asset_path"])
    if missing_media:
        failures.append("missing media assets: " + ", ".join(missing_media[:20]))

    image_prompt_missing = list(
        connection.execute(
            """
            SELECT q.question_number, q.prompt
            FROM questions q
            LEFT JOIN question_stimuli qs ON qs.question_id = q.id
            WHERE qs.question_id IS NULL
            ORDER BY q.question_number
            """
        )
    )
    image_prompt_missing = [
        row
        for row in image_prompt_missing
        if _uses_numbered_image_prompt(row["prompt"])
    ]
    if image_prompt_missing:
        sample = ", ".join(
            f"q{row['question_number']}" for row in image_prompt_missing[:20]
        )
        failures.append(f"numbered image prompts without image: {sample}")

    body_split_failures = _body_split_failures(connection)
    if body_split_failures:
        failures.append("body split failures: " + ", ".join(body_split_failures))

    range_stimulus_failures = _range_stimulus_failures(connection)
    if range_stimulus_failures:
        failures.append(
            "range stimulus failures: " + ", ".join(range_stimulus_failures)
        )

    prompt_failures = _prompt_failures(connection)
    if prompt_failures:
        failures.append("prompt failures: " + ", ".join(prompt_failures[:20]))

    text_cleanup_failures = _text_cleanup_failures(connection)
    if text_cleanup_failures:
        failures.append(
            "text cleanup failures: " + ", ".join(text_cleanup_failures[:20])
        )

    image_mapping_failures = _image_mapping_failures(connection)
    if image_mapping_failures:
        failures.append(
            "image mapping failures: " + ", ".join(image_mapping_failures[:20])
        )

    grouped_numbers = _question_numbers_by_stimulus(connection)
    non_contiguous = []
    for stimulus_id, numbers in grouped_numbers.items():
        if not _is_contiguous(numbers):
            non_contiguous.append(f"{stimulus_id}:{_ranges(numbers)}")
    if non_contiguous:
        failures.append("non-contiguous image groups: " + ", ".join(non_contiguous[:20]))

    print(f"questions={question_count}")
    print(f"sets={len(set_counts)}")
    print(f"stimuli={_single_int(connection, 'SELECT count(*) FROM stimuli')}")
    print(f"question_stimuli={_single_int(connection, 'SELECT count(*) FROM question_stimuli')}")
    print(f"numbered_image_prompt_missing={len(image_prompt_missing)}")
    print(f"body_split_failures={len(body_split_failures)}")
    print(f"range_stimulus_failures={len(range_stimulus_failures)}")
    print(f"prompt_failures={len(prompt_failures)}")
    print(f"text_cleanup_failures={len(text_cleanup_failures)}")
    print(f"image_mapping_failures={len(image_mapping_failures)}")
    print(f"non_contiguous_image_groups={len(non_contiguous)}")
    print("largest_image_groups:")
    for stimulus_id, numbers in sorted(
        grouped_numbers.items(), key=lambda item: len(item[1]), reverse=True
    )[:10]:
        asset_path = connection.execute(
            "SELECT asset_path FROM stimuli WHERE id = ?", (stimulus_id,)
        ).fetchone()["asset_path"]
        print(f"- {stimulus_id} {asset_path} questions={_ranges(numbers)} count={len(numbers)}")

    connection.close()

    if failures:
        print("FAIL")
        for failure in failures:
            print(f"- {failure}")
        raise SystemExit(1)

    print("PASS")


def _single_int(connection: sqlite3.Connection, sql: str) -> int:
    return int(connection.execute(sql).fetchone()[0])


def _question_numbers_by_stimulus(
    connection: sqlite3.Connection,
) -> dict[str, list[int]]:
    result: dict[str, list[int]] = defaultdict(list)
    for row in connection.execute(
        """
        SELECT qs.stimulus_id, q.question_number
        FROM question_stimuli qs
        INNER JOIN questions q ON q.id = qs.question_id
        ORDER BY qs.stimulus_id, q.question_number
        """
    ):
        result[row["stimulus_id"]].append(row["question_number"])
    return dict(result)


def _body_split_failures(connection: sqlite3.Connection) -> list[str]:
    checks = {
        267: "주로 단모종에 사용한다.",
        536: "1.6mm 날을 사용하여",
    }
    failures: list[str] = []
    for question_number, body_prefix in checks.items():
        row = connection.execute(
            """
            SELECT prompt, body_text
            FROM questions
            WHERE question_number = ?
            """,
            (question_number,),
        ).fetchone()
        if row is None:
            failures.append(f"q{question_number}:missing")
            continue
        if body_prefix in row["prompt"]:
            failures.append(f"q{question_number}:body_in_prompt")
        if body_prefix not in row["body_text"]:
            failures.append(f"q{question_number}:body_missing")
    return failures


def _range_stimulus_failures(connection: sqlite3.Connection) -> list[str]:
    required = {
        284: ("\uBB38\uC81C 284~285", "\uAF2C\uB9AC \uBFCC\uB9AC\uBD80\uBD84"),
        285: ("\uBB38\uC81C 284~285", "\uAF2C\uB9AC \uBFCC\uB9AC\uBD80\uBD84"),
        569: ("\uBB38\uC81C 569~572", "\uC2A4\uD2B8\uB9AC\uD551 2\uB2E8\uACC4"),
        570: ("\uBB38\uC81C 569~572", "\uC2A4\uD2B8\uB9AC\uD551 2\uB2E8\uACC4"),
        571: ("\uBB38\uC81C 569~572", "\uC2A4\uD2B8\uB9AC\uD551 2\uB2E8\uACC4"),
        572: ("\uBB38\uC81C 569~572", "\uC2A4\uD2B8\uB9AC\uD551 2\uB2E8\uACC4"),
        662: ("\uBB38\uC81C 662~664", "\uB300\uD1F4\uBD80\uB294"),
        663: ("\uBB38\uC81C 662~664", "\uB300\uD1F4\uBD80\uB294"),
        664: ("\uBB38\uC81C 662~664", "\uB300\uD1F4\uBD80\uB294"),
    }
    failures: list[str] = []
    for question_number, snippets in required.items():
        row = connection.execute(
            "SELECT body_text FROM questions WHERE question_number = ?",
            (question_number,),
        ).fetchone()
        if row is None:
            failures.append(f"q{question_number}:missing")
            continue
        body_text = row["body_text"]
        for snippet in snippets:
            if snippet not in body_text:
                failures.append(f"q{question_number}:missing_range_stimulus")
                break
    return failures


def _prompt_failures(connection: sqlite3.Connection) -> list[str]:
    failures: list[str] = []
    grade_pattern = re.compile(r"\([^)]*\d\s*" + "\uAE09" + r"[^)]*\)")
    for row in connection.execute(
        "SELECT question_number, prompt FROM questions ORDER BY question_number"
    ):
        prompt = row["prompt"]
        question_number = row["question_number"]
        if grade_pattern.search(prompt):
            failures.append(f"q{question_number}:grade_suffix")
        if any(_is_cyrillic(character) for character in prompt):
            failures.append(f"q{question_number}:cyrillic")

    q521 = connection.execute(
        "SELECT prompt FROM questions WHERE question_number = 521"
    ).fetchone()
    expected = "521. 다음 미니어쳐 슈나우저의 스트리핑 1단계 종료 사진에 대한 설명으로 옳지 않은 것은?"
    if q521 is None or q521["prompt"] != expected:
        failures.append("q521:prompt_expected")
    return failures


def _text_cleanup_failures(connection: sqlite3.Connection) -> list[str]:
    failures: list[str] = []
    category_pattern = re.compile(
        r"\s-\s*(?:"
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
    diamond_pattern = re.compile(r"[\u25C6\u25C7\u25C8]")
    for row in connection.execute(
        """
        SELECT question_number, prompt
        FROM questions
        ORDER BY question_number
        """
    ):
        if "<" in row["prompt"] and "\uBB38\uC81C" in row["prompt"]:
            failures.append(f"q{row['question_number']}:marker_in_prompt")
        if diamond_pattern.search(row["prompt"]):
            failures.append(f"q{row['question_number']}:diamond_in_prompt")

    for row in connection.execute(
        """
        SELECT q.question_number, c.position, c.text
        FROM choices c
        INNER JOIN questions q ON q.id = c.question_id
        ORDER BY q.question_number, c.position
        """
    ):
        question_number = row["question_number"]
        text = row["text"]
        if "\uBB38\uC81C" in text:
            failures.append(f"q{question_number}:marker_in_choice{row['position']}")
        if diamond_pattern.search(text):
            failures.append(f"q{question_number}:diamond_in_choice{row['position']}")
        if category_pattern.search(text):
            failures.append(f"q{question_number}:category_in_choice{row['position']}")
        if "$" in text or "\\circ" in text or "\\sim" in text:
            failures.append(f"q{question_number}:tex_in_choice{row['position']}")

    expected_choices = {
        (284, 1): "25°",
        (284, 2): "30°",
        (284, 3): "35°",
        (284, 4): "40°",
        (285, 1): "25° ~ 30°",
        (285, 2): "30° ~ 35°",
        (285, 3): "35° ~ 40°",
        (285, 4): "40° ~ 45°",
        (539, 1): "전지는 나이프로 빗질 하는듯한 느낌으로 날에 걸리는 털을 뽑아준다",
        (539, 2): "뻣뻣한 털은 힘을 주지 않으면 뽑히지 않으므로 힘을 주지 않음으로써 뻣뻣한 털을 뽑지 않고 유지할 수 있다",
        (539, 3): "후지의 바깥쪽도 전지와 같은 요령으로 빗질하듯이 뽑아나간다",
        (539, 4): "전 후지 모두 이 작업 후에 부드러운 털이 자라나. 그 털에 뺏뻣한 털이 휘감겨 폭이 넓어지게 되는 형태를 만들 수 있다.",
        (704, 4): "\uB514\uC26C\uD398\uC774\uC2A4(dishface)",
        (708, 4): "\uB85C\uBDF0\uB77C (lobular)",
        (712, 4): "\uC544\uC774\uBCFC(eyeball)",
    }
    for (question_number, position), expected in expected_choices.items():
        row = connection.execute(
            """
            SELECT c.text
            FROM choices c
            INNER JOIN questions q ON q.id = c.question_id
            WHERE q.question_number = ? AND c.position = ?
            """,
            (question_number, position),
        ).fetchone()
        if row is None or row["text"] != expected:
            failures.append(f"q{question_number}:choice{position}_expected")
    return failures


def _image_mapping_failures(connection: sqlite3.Connection) -> list[str]:
    failures: list[str] = []
    for question_number in (607,):
        row = connection.execute(
            """
            SELECT count(*) AS count
            FROM questions q
            INNER JOIN question_stimuli qs ON qs.question_id = q.id
            WHERE q.question_number = ?
            """,
            (question_number,),
        ).fetchone()
        if row["count"] == 0:
            failures.append(f"q{question_number}:missing_image")
    return failures


def _ranges(numbers: list[int]) -> str:
    ranges = []
    start = previous = numbers[0]
    for number in numbers[1:]:
        if number == previous + 1:
            previous = number
            continue
        ranges.append(_range_text(start, previous))
        start = previous = number
    ranges.append(_range_text(start, previous))
    return ",".join(ranges)


def _range_text(start: int, end: int) -> str:
    if start == end:
        return str(start)
    return f"{start}-{end}"


def _is_contiguous(numbers: list[int]) -> bool:
    return all(current + 1 == next_ for current, next_ in zip(numbers, numbers[1:]))


def _uses_numbered_image_prompt(text: str) -> bool:
    return any(_is_circled_number(character) for character in text)


def _is_cyrillic(character: str) -> bool:
    codepoint = ord(character)
    return 0x0400 <= codepoint <= 0x04FF


def _is_circled_number(character: str) -> bool:
    codepoint = ord(character)
    return (
        0x2460 <= codepoint <= 0x2473
        or 0x3251 <= codepoint <= 0x325F
        or 0x32B1 <= codepoint <= 0x32BF
    )


if __name__ == "__main__":
    main()
