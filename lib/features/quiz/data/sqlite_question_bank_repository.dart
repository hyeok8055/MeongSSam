import 'package:meongssam/features/quiz/data/question_bank_database_service.dart';
import 'package:meongssam/features/quiz/domain/question_bank_repository.dart';
import 'package:meongssam/features/quiz/domain/quiz_question.dart';

class SqliteQuestionBankRepository implements QuestionBankRepository {
  const SqliteQuestionBankRepository(this._databaseService);

  final QuestionBankDatabaseService _databaseService;

  @override
  Future<List<QuizQuestion>> loadRandomQuestionSet({required int limit}) async {
    final questionRows = await _databaseService.queryRandomQuestionRows(
      limit: limit,
    );
    return _questionsFromRows(questionRows);
  }

  @override
  Future<List<QuizQuestion>> loadQuestionsByIds(List<String> ids) async {
    final questionRows = await _databaseService.queryQuestionRowsByIds(ids);
    final questionsById = {
      for (final question in await _questionsFromRows(questionRows))
        question.id: question,
    };
    return [
      for (final id in ids)
        if (questionsById[id] != null) questionsById[id]!,
    ];
  }

  @override
  Future<List<QuizQuestion>> loadAllQuestions() async {
    final questionRows = await _databaseService.queryAllQuestionRows();
    return _questionsFromRows(questionRows);
  }

  Future<List<QuizQuestion>> _questionsFromRows(
    List<Map<String, Object?>> questionRows,
  ) async {
    final questionIds = questionRows
        .map((row) => row['id']! as String)
        .toList(growable: false);

    final choicesByQuestion = _choicesByQuestion(
      await _databaseService.queryChoiceRows(questionIds),
    );
    final imagesByQuestion = _imagesByQuestion(
      await _databaseService.queryImageRows(questionIds),
    );

    return questionRows
        .map((row) {
          final id = row['id']! as String;
          final choices = choicesByQuestion[id] ?? const <QuizChoice>[];
          final answerLabel = row['answer_label'] as String?;
          final correctChoiceIndex = _correctChoiceIndex(choices, answerLabel);

          return QuizQuestion(
            id: id,
            number: row['question_number']! as int,
            prompt: row['prompt']! as String,
            bodyText: row['body_text']! as String,
            choices: choices,
            correctChoiceIndex: correctChoiceIndex < 0 ? 0 : correctChoiceIndex,
            imageAssetPaths: imagesByQuestion[id] ?? const <String>[],
          );
        })
        .toList(growable: false);
  }

  int _correctChoiceIndex(List<QuizChoice> choices, String? answerLabel) {
    final choiceIndex = choices.indexWhere(
      (choice) => choice.label == answerLabel,
    );
    if (choiceIndex >= 0) return choiceIndex;

    final numericLabel = int.tryParse(answerLabel ?? '');
    if (numericLabel != null && numericLabel > 0) {
      return numericLabel - 1;
    }
    return 0;
  }

  Map<String, List<QuizChoice>> _choicesByQuestion(
    List<Map<String, Object?>> rows,
  ) {
    final result = <String, List<QuizChoice>>{};
    for (final row in rows) {
      final questionId = row['question_id']! as String;
      final choices = result.putIfAbsent(questionId, () => <QuizChoice>[]);
      choices.add(
        QuizChoice(
          label: row['label']! as String,
          text: row['text']! as String,
        ),
      );
    }
    return result;
  }

  Map<String, List<String>> _imagesByQuestion(List<Map<String, Object?>> rows) {
    final result = <String, List<String>>{};
    for (final row in rows) {
      final questionId = row['question_id']! as String;
      final paths = result.putIfAbsent(questionId, () => <String>[]);
      paths.add(row['asset_path']! as String);
    }
    return result;
  }
}
