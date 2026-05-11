import 'package:meongssam/features/quiz/domain/quiz_question.dart';

abstract interface class QuestionBankRepository {
  Future<List<QuizQuestion>> loadRandomQuestionSet({required int limit});
  Future<List<QuizQuestion>> loadQuestionsByIds(List<String> ids);
  Future<List<QuizQuestion>> loadAllQuestions();
}
