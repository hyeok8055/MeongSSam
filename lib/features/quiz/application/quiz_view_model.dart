import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongssam/app/di/app_providers.dart';
import 'package:meongssam/features/quiz/domain/question_bank_repository.dart';
import 'package:meongssam/features/quiz/domain/quiz_question.dart';
import 'package:meongssam/features/quiz/domain/quiz_session_store.dart';

enum QuizLaunchMode { resume, fresh }

final quizViewModelProvider = StateNotifierProvider.autoDispose
    .family<QuizViewModel, QuizState, QuizLaunchMode>((ref, launchMode) {
      final repository = ref.watch(questionBankRepositoryProvider);
      final sessionStore = ref.watch(quizSessionStoreProvider);
      final viewModel = QuizViewModel(
        repository: repository,
        sessionStore: sessionStore,
      );
      viewModel.loadFirstSet(resume: launchMode == QuizLaunchMode.resume);
      return viewModel;
    });

enum QuizStatus { loading, ready, completed, empty, failure }

class QuizState {
  const QuizState({
    required this.status,
    required this.questions,
    required this.currentIndex,
    required this.selectedChoiceIndex,
    required this.selectedChoiceIndexes,
    this.errorMessage,
  });

  const QuizState.loading()
    : status = QuizStatus.loading,
      questions = const [],
      currentIndex = 0,
      selectedChoiceIndex = null,
      selectedChoiceIndexes = const {},
      errorMessage = null;

  final QuizStatus status;
  final List<QuizQuestion> questions;
  final int currentIndex;
  final int? selectedChoiceIndex;
  final Map<String, int> selectedChoiceIndexes;
  final String? errorMessage;

  QuizQuestion? get currentQuestion {
    if (questions.isEmpty) return null;
    final safeIndex = currentIndex.clamp(0, questions.length - 1).toInt();
    return questions[safeIndex];
  }

  int get currentNumber => questions.isEmpty ? 0 : currentIndex + 1;
  int get totalCount => questions.length;
  bool get isLastQuestion => currentIndex >= questions.length - 1;
  bool get canUseNext => selectedChoiceIndex != null;
  int get correctCount {
    var count = 0;
    for (final question in questions) {
      if (selectedChoiceIndexes[question.id] == question.correctChoiceIndex) {
        count++;
      }
    }
    return count;
  }

  QuizState copyWith({
    QuizStatus? status,
    List<QuizQuestion>? questions,
    int? currentIndex,
    int? selectedChoiceIndex,
    Map<String, int>? selectedChoiceIndexes,
    bool clearSelectedChoice = false,
    String? errorMessage,
  }) {
    return QuizState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedChoiceIndex: clearSelectedChoice
          ? null
          : selectedChoiceIndex ?? this.selectedChoiceIndex,
      selectedChoiceIndexes:
          selectedChoiceIndexes ?? this.selectedChoiceIndexes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class QuizViewModel extends StateNotifier<QuizState> {
  QuizViewModel({
    required QuestionBankRepository repository,
    QuizSessionStore? sessionStore,
  }) : _repository = repository,
       _sessionStore = sessionStore,
       super(const QuizState.loading());

  QuizViewModel.legacy({required QuestionBankRepository repository})
    : _repository = repository,
      _sessionStore = null,
      super(const QuizState.loading());

  static const defaultSetSize = 20;

  final QuestionBankRepository _repository;
  final QuizSessionStore? _sessionStore;

  Future<void> loadFirstSet({bool resume = true}) async {
    state = const QuizState.loading();
    try {
      if (resume) {
        final restored = await _restoreSession();
        if (restored) return;
      }

      final questions = await _repository.loadRandomQuestionSet(
        limit: defaultSetSize,
      );
      state = QuizState(
        status: questions.isEmpty ? QuizStatus.empty : QuizStatus.ready,
        questions: questions,
        currentIndex: 0,
        selectedChoiceIndex: null,
        selectedChoiceIndexes: const {},
      );
      await _saveSession();
    } on Object catch (error) {
      state = QuizState(
        status: QuizStatus.failure,
        questions: const [],
        currentIndex: 0,
        selectedChoiceIndex: null,
        selectedChoiceIndexes: const {},
        errorMessage: error.toString(),
      );
    }
  }

  void selectChoice(int index) {
    if (state.status != QuizStatus.ready) return;
    if (state.selectedChoiceIndex != null) return;
    final question = state.currentQuestion;
    if (question == null) return;
    state = state.copyWith(
      selectedChoiceIndex: index,
      selectedChoiceIndexes: {
        ...state.selectedChoiceIndexes,
        question.id: index,
      },
    );
    unawaited(_saveSession());
  }

  void goNext() {
    if (!state.canUseNext) return;
    if (state.isLastQuestion) {
      state = state.copyWith(status: QuizStatus.completed);
      unawaited(_sessionStore?.clear() ?? Future<void>.value());
      return;
    }
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      clearSelectedChoice: true,
    );
    unawaited(_saveSession());
  }

  Future<void> _saveSession() async {
    final sessionStore = _sessionStore;
    if (sessionStore == null) return;
    if (state.status != QuizStatus.ready || state.questions.isEmpty) return;
    await sessionStore.save(
      QuizSessionSnapshot(
        questionIds: state.questions
            .map((question) => question.id)
            .toList(growable: false),
        currentIndex: state.currentIndex,
        selectedChoiceIndexes: state.selectedChoiceIndexes,
      ),
    );
  }

  Future<bool> _restoreSession() async {
    final snapshot = _sessionStore?.read();
    if (snapshot == null || snapshot.questionIds.isEmpty) return false;

    final questions = await _repository.loadQuestionsByIds(
      snapshot.questionIds,
    );
    if (questions.length != snapshot.questionIds.length || questions.isEmpty) {
      await _sessionStore?.clear();
      return false;
    }

    final currentIndex = snapshot.currentIndex
        .clamp(0, questions.length - 1)
        .toInt();
    final selectedChoiceIndexes = Map<String, int>.from(
      snapshot.selectedChoiceIndexes,
    );
    final currentQuestion = questions[currentIndex];
    state = QuizState(
      status: QuizStatus.ready,
      questions: questions,
      currentIndex: currentIndex,
      selectedChoiceIndex: selectedChoiceIndexes[currentQuestion.id],
      selectedChoiceIndexes: selectedChoiceIndexes,
    );
    return true;
  }
}
