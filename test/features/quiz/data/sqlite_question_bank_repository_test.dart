import 'package:flutter_test/flutter_test.dart';
import 'package:meongssam/features/quiz/data/question_bank_database_service.dart';
import 'package:meongssam/features/quiz/data/sqlite_question_bank_repository.dart';

void main() {
  test(
    'maps question rows, choices, answers, and shared image assets',
    () async {
      final databaseService = _FakeQuestionBankDatabaseService();
      final repository = SqliteQuestionBankRepository(databaseService);

      final questions = await repository.loadRandomQuestionSet(limit: 20);

      expect(questions, hasLength(2));
      expect(databaseService.lastLimit, 20);
      expect(questions[0].prompt, 'Question 1');
      expect(questions[0].bodyText, 'Readable body text');
      expect(questions[0].choices.map((choice) => choice.text), ['A', 'B']);
      expect(questions[0].correctChoiceIndex, 1);
      expect(questions[0].imageAssetPaths, [
        'assets/question_media/shared.webp',
      ]);
      expect(questions[1].imageAssetPaths, [
        'assets/question_media/shared.webp',
      ]);
    },
  );

  test('loads all questions in database order', () async {
    final databaseService = _FakeQuestionBankDatabaseService();
    final repository = SqliteQuestionBankRepository(databaseService);

    final questions = await repository.loadAllQuestions();

    expect(databaseService.loadedAllQuestions, isTrue);
    expect(questions.map((question) => question.number), [1, 2]);
  });

  test('uses numeric answer labels for image-choice questions', () async {
    final databaseService = _ImageChoiceQuestionDatabaseService();
    final repository = SqliteQuestionBankRepository(databaseService);

    final questions = await repository.loadRandomQuestionSet(limit: 1);

    expect(questions.single.choices, isEmpty);
    expect(questions.single.correctChoiceIndex, 3);
  });
}

class _FakeQuestionBankDatabaseService extends QuestionBankDatabaseService {
  @override
  Future<List<Map<String, Object?>>> queryQuestionRows({
    required String setId,
  }) async {
    throw UnimplementedError();
  }

  int? lastLimit;
  bool loadedAllQuestions = false;

  @override
  Future<List<Map<String, Object?>>> queryAllQuestionRows() async {
    loadedAllQuestions = true;
    return queryRandomQuestionRows(limit: 800);
  }

  @override
  Future<List<Map<String, Object?>>> queryRandomQuestionRows({
    required int limit,
  }) async {
    lastLimit = limit;
    return const [
      {
        'id': 'q1',
        'question_number': 1,
        'prompt': 'Question 1',
        'body_text': 'Readable body text',
        'answer_label': '2',
      },
      {
        'id': 'q2',
        'question_number': 2,
        'prompt': 'Question 2',
        'body_text': '',
        'answer_label': '1',
      },
    ];
  }

  @override
  Future<List<Map<String, Object?>>> queryQuestionRowsByIds(
    List<String> questionIds,
  ) async {
    final rows = await queryRandomQuestionRows(limit: questionIds.length);
    return rows
        .where((row) => questionIds.contains(row['id']))
        .toList(growable: false);
  }

  @override
  Future<List<Map<String, Object?>>> queryChoiceRows(
    List<String> questionIds,
  ) async {
    return const [
      {'question_id': 'q1', 'label': '1', 'text': 'A', 'position': 1},
      {'question_id': 'q1', 'label': '2', 'text': 'B', 'position': 2},
      {'question_id': 'q2', 'label': '1', 'text': 'C', 'position': 1},
      {'question_id': 'q2', 'label': '2', 'text': 'D', 'position': 2},
    ];
  }

  @override
  Future<List<Map<String, Object?>>> queryImageRows(
    List<String> questionIds,
  ) async {
    return const [
      {
        'question_id': 'q1',
        'asset_path': 'assets/question_media/shared.webp',
        'position': 1,
      },
      {
        'question_id': 'q2',
        'asset_path': 'assets/question_media/shared.webp',
        'position': 1,
      },
    ];
  }
}

class _ImageChoiceQuestionDatabaseService extends QuestionBankDatabaseService {
  @override
  Future<List<Map<String, Object?>>> queryQuestionRows({
    required String setId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, Object?>>> queryRandomQuestionRows({
    required int limit,
  }) async {
    return const [
      {
        'id': 'q326',
        'question_number': 326,
        'prompt': 'Question 326',
        'body_text': 'Body',
        'answer_label': '4',
      },
    ];
  }

  @override
  Future<List<Map<String, Object?>>> queryQuestionRowsByIds(
    List<String> questionIds,
  ) async {
    return queryRandomQuestionRows(limit: questionIds.length);
  }

  @override
  Future<List<Map<String, Object?>>> queryChoiceRows(
    List<String> questionIds,
  ) async {
    return const [];
  }

  @override
  Future<List<Map<String, Object?>>> queryImageRows(
    List<String> questionIds,
  ) async {
    return const [
      {
        'question_id': 'q326',
        'asset_path': 'assets/question_media/img_0047.webp',
        'position': 1,
      },
    ];
  }
}
