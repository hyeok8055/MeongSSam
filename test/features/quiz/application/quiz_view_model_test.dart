import 'package:flutter_test/flutter_test.dart';
import 'package:meongssam/features/quiz/application/quiz_view_model.dart';
import 'package:meongssam/features/quiz/domain/question_bank_repository.dart';
import 'package:meongssam/features/quiz/domain/quiz_question.dart';
import 'package:meongssam/features/quiz/domain/quiz_session_store.dart';

void main() {
  test('loads 20 random questions from question bank', () async {
    final repository = _FakeQuestionBankRepository(_questions(25));
    final viewModel = QuizViewModel(repository: repository);

    await viewModel.loadFirstSet();

    expect(viewModel.state.status, QuizStatus.ready);
    expect(viewModel.state.questions, hasLength(20));
    expect(viewModel.state.currentQuestion?.number, 1);
    expect(viewModel.state.totalCount, 20);
    expect(repository.lastLimit, 20);
  });

  test('advances question and clears selected choice', () async {
    final repository = _FakeQuestionBankRepository(_questions(2));
    final viewModel = QuizViewModel(repository: repository);
    await viewModel.loadFirstSet();

    viewModel.selectChoice(1);
    expect(viewModel.state.selectedChoiceIndex, 1);

    viewModel.goNext();

    expect(viewModel.state.currentQuestion?.number, 2);
    expect(viewModel.state.selectedChoiceIndex, isNull);
  });

  test('keeps the first selected choice for a question', () async {
    final repository = _FakeQuestionBankRepository(_questions(2));
    final viewModel = QuizViewModel(repository: repository);
    await viewModel.loadFirstSet();

    viewModel.selectChoice(0);
    viewModel.selectChoice(1);

    expect(viewModel.state.selectedChoiceIndex, 0);
    expect(viewModel.state.selectedChoiceIndexes['q1'], 0);
  });

  test('keeps shared image assets as references on each question', () async {
    const sharedImage = 'assets/question_media/shared.webp';
    final questions = _questions(3, imageAssetPaths: const [sharedImage]);
    final repository = _FakeQuestionBankRepository(questions);
    final viewModel = QuizViewModel(repository: repository);

    await viewModel.loadFirstSet();

    expect(
      viewModel.state.questions.map((question) => question.imageAssetPaths),
      everyElement(const [sharedImage]),
    );
  });

  test('resumes a saved quiz session', () async {
    final repository = _FakeQuestionBankRepository(_questions(3));
    final sessionStore = _FakeQuizSessionStore(
      QuizSessionSnapshot(
        questionIds: const ['q1', 'q2', 'q3'],
        currentIndex: 1,
        selectedChoiceIndexes: const {'q2': 0},
      ),
    );
    final viewModel = QuizViewModel(
      repository: repository,
      sessionStore: sessionStore,
    );

    await viewModel.loadFirstSet();

    expect(viewModel.state.currentQuestion?.id, 'q2');
    expect(viewModel.state.selectedChoiceIndex, 0);
    expect(repository.lastLimit, isNull);
  });
}

class _FakeQuestionBankRepository implements QuestionBankRepository {
  _FakeQuestionBankRepository(this._questions);

  final List<QuizQuestion> _questions;
  int? lastLimit;

  @override
  Future<List<QuizQuestion>> loadRandomQuestionSet({required int limit}) async {
    lastLimit = limit;
    return _questions.take(limit).toList(growable: false);
  }

  @override
  Future<List<QuizQuestion>> loadQuestionsByIds(List<String> ids) async {
    final questionsById = {
      for (final question in _questions) question.id: question,
    };
    return [
      for (final id in ids)
        if (questionsById[id] != null) questionsById[id]!,
    ];
  }

  @override
  Future<List<QuizQuestion>> loadAllQuestions() async {
    return _questions;
  }
}

class _FakeQuizSessionStore implements QuizSessionStore {
  _FakeQuizSessionStore(this.snapshot);

  QuizSessionSnapshot? snapshot;

  @override
  Future<void> clear() async {
    snapshot = null;
  }

  @override
  bool hasSession() => snapshot != null;

  @override
  QuizSessionSnapshot? read() => snapshot;

  @override
  Future<void> save(QuizSessionSnapshot snapshot) async {
    this.snapshot = snapshot;
  }
}

List<QuizQuestion> _questions(
  int count, {
  List<String> imageAssetPaths = const [],
}) {
  return List.generate(count, (index) {
    final number = index + 1;
    return QuizQuestion(
      id: 'q$number',
      number: number,
      prompt: 'Question $number',
      bodyText: '',
      choices: const [
        QuizChoice(label: '1', text: 'A'),
        QuizChoice(label: '2', text: 'B'),
        QuizChoice(label: '3', text: 'C'),
        QuizChoice(label: '4', text: 'D'),
      ],
      correctChoiceIndex: 0,
      imageAssetPaths: imageAssetPaths,
    );
  });
}
