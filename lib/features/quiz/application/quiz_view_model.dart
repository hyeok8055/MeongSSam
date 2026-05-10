import 'package:flutter_riverpod/flutter_riverpod.dart';

final quizViewModelProvider = Provider<QuizViewModel>((ref) {
  return const QuizViewModel();
});

class QuizViewModel {
  const QuizViewModel();

  QuizQuestion get currentQuestion => const QuizQuestion(
    currentNumber: 1,
    totalCount: 20,
    prompt: '1번의 명칭은 무엇입니까?',
    choices: ['1', '2', '3', '4'],
  );
}

class QuizQuestion {
  const QuizQuestion({
    required this.currentNumber,
    required this.totalCount,
    required this.prompt,
    required this.choices,
  });

  final int currentNumber;
  final int totalCount;
  final String prompt;
  final List<String> choices;
}
