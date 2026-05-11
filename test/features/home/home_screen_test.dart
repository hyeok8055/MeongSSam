import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meongssam/app/di/app_providers.dart';
import 'package:meongssam/features/home/presentation/view/home_screen.dart';
import 'package:meongssam/features/home/presentation/widgets/level_card.dart';
import 'package:meongssam/features/home/presentation/widgets/main_warning_dialog.dart';
import 'package:meongssam/features/home/presentation/widgets/quick_action_card.dart';
import 'package:meongssam/features/quiz/domain/question_bank_repository.dart';
import 'package:meongssam/features/quiz/domain/quiz_question.dart';
import 'package:meongssam/features/quiz/domain/quiz_session_store.dart';

void main() {
  testWidgets('home screen shows main level actions and quick actions', (
    tester,
  ) async {
    await pumpHomeScreen(tester);

    expect(find.byType(LevelCard), findsNWidgets(3));
    expect(find.byType(QuickActionCard), findsNWidgets(2));
  });

  testWidgets('first level action opens the image quiz screen', (tester) async {
    await pumpHomeScreen(tester);

    await tester.tap(find.byType(LevelCard).first);
    await tester.pumpAndSettle();

    expect(find.text('1/20'), findsOneWidget);
    expect(find.text('Question 1'), findsOneWidget);
    expect(find.text('COMING SOON!'), findsNothing);
  });

  testWidgets('first level action asks to resume when a session exists', (
    tester,
  ) async {
    await pumpHomeScreen(tester, hasSavedQuizSession: true);

    await tester.tap(find.byType(LevelCard).first);
    await tester.pumpAndSettle();

    expect(find.text('이어서 풀기'), findsOneWidget);
    expect(find.text('새 문제 풀기'), findsOneWidget);

    await tester.tap(find.text('새 문제 풀기'));
    await tester.pumpAndSettle();

    expect(find.text('1/20'), findsOneWidget);
  });

  testWidgets('temporary audit action opens all-question audit screen', (
    tester,
  ) async {
    await pumpHomeScreen(tester, questionCount: 800);

    await tester.tap(find.text('전수 검수'));
    await tester.pumpAndSettle();

    expect(find.text('검수 1 / 800'), findsOneWidget);
    expect(find.text('Question 1'), findsOneWidget);
  });

  testWidgets('unimplemented main actions show the warning popup', (
    tester,
  ) async {
    await pumpHomeScreen(tester);

    final inactiveCards = [
      find.byType(LevelCard).at(1),
      find.byType(LevelCard).at(2),
      find.byType(QuickActionCard).at(0),
      find.byType(QuickActionCard).at(1),
    ];

    for (final card in inactiveCards) {
      await tester.tap(card);
      await tester.pump();

      expect(find.text('COMING SOON!'), findsOneWidget);

      final confirmButton = find.descendant(
        of: find.byType(MainWarningDialog),
        matching: find.byType(InkWell),
      );
      await tester.tap(confirmButton);
      await tester.pump();

      expect(find.text('COMING SOON!'), findsNothing);
    }
  });
}

Future<void> pumpHomeScreen(
  WidgetTester tester, {
  bool hasSavedQuizSession = false,
  int questionCount = 20,
}) async {
  tester.view.physicalSize = const Size(480, 1040);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        questionBankRepositoryProvider.overrideWithValue(
          _FakeQuestionBankRepository(_questions(questionCount)),
        ),
        quizSessionStoreProvider.overrideWithValue(
          _FakeQuizSessionStore(hasSavedSession: hasSavedQuizSession),
        ),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeQuizSessionStore implements QuizSessionStore {
  _FakeQuizSessionStore({required this.hasSavedSession});

  final bool hasSavedSession;

  @override
  Future<void> clear() async {}

  @override
  bool hasSession() => hasSavedSession;

  @override
  QuizSessionSnapshot? read() => null;

  @override
  Future<void> save(QuizSessionSnapshot snapshot) async {}
}

class _FakeQuestionBankRepository implements QuestionBankRepository {
  const _FakeQuestionBankRepository(this._questions);

  final List<QuizQuestion> _questions;

  @override
  Future<List<QuizQuestion>> loadRandomQuestionSet({required int limit}) async {
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

List<QuizQuestion> _questions(int count) {
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
      correctChoiceIndex: 1,
      imageAssetPaths: const [],
    );
  });
}
