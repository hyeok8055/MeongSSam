import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meongssam/app/di/app_providers.dart';
import 'package:meongssam/features/quiz/domain/question_bank_repository.dart';
import 'package:meongssam/features/quiz/domain/quiz_question.dart';
import 'package:meongssam/features/quiz/domain/quiz_session_store.dart';
import 'package:meongssam/features/quiz/presentation/view/quiz_image_screen.dart';
import 'package:meongssam/features/quiz/presentation/widgets/quiz_choice_card.dart';
import 'package:meongssam/features/quiz/presentation/widgets/quiz_image_placeholder.dart';
import 'package:meongssam/features/quiz/presentation/widgets/quiz_next_button.dart';

void main() {
  testWidgets('quiz image screen renders repository question layout', (
    tester,
  ) async {
    await pumpQuizImageScreen(tester);

    expect(find.text('1/20'), findsOneWidget);
    expect(find.text('다음'), findsOneWidget);
    expect(find.text('Question 1'), findsOneWidget);
    expect(find.text('Readable body text'), findsOneWidget);
    expect(find.textContaining('Question 1 Readable'), findsNothing);
    expect(find.byType(QuizImagePlaceholder), findsOneWidget);
    expect(find.byType(QuizChoiceCard), findsNWidgets(4));
    expect(
      tester.widget<QuizNextButton>(find.byType(QuizNextButton)).enabled,
      isFalse,
    );

    final imageBottom = tester
        .getBottomLeft(find.byType(QuizImagePlaceholder))
        .dy;
    final firstChoiceTop = tester
        .getTopLeft(find.byType(QuizChoiceCard).first)
        .dy;

    expect(firstChoiceTop, greaterThan(imageBottom));
  });

  testWidgets('quiz choice cards show answer states after selection', (
    tester,
  ) async {
    await pumpQuizImageScreen(tester);

    await tester.tap(find.widgetWithText(QuizChoiceCard, '1'));
    await tester.pump();

    final cards = tester
        .widgetList<QuizChoiceCard>(find.byType(QuizChoiceCard))
        .toList();

    expect(cards[0].state, QuizChoiceCardState.incorrect);
    expect(cards[1].state, QuizChoiceCardState.correct);
    expect(cards[2].state, QuizChoiceCardState.idle);
    expect(
      tester.widget<QuizNextButton>(find.byType(QuizNextButton)).enabled,
      isTrue,
    );
  });

  testWidgets('quiz choice cards ignore taps after the first selection', (
    tester,
  ) async {
    await pumpQuizImageScreen(tester);

    await tester.tap(find.widgetWithText(QuizChoiceCard, '1'));
    await tester.pump();
    await tester.tap(find.widgetWithText(QuizChoiceCard, '2'));
    await tester.pump();

    final cards = tester
        .widgetList<QuizChoiceCard>(find.byType(QuizChoiceCard))
        .toList();

    expect(cards[0].state, QuizChoiceCardState.incorrect);
    expect(cards[1].state, QuizChoiceCardState.correct);
  });

  testWidgets('quiz back button asks before returning home', (tester) async {
    await pumpQuizImageScreen(tester);

    await tester.tap(find.byTooltip('홈으로'));
    await tester.pumpAndSettle();

    expect(find.text('문제를 포기하고 나갈까요?'), findsOneWidget);

    await tester.tap(find.text('아니오'));
    await tester.pumpAndSettle();
    expect(find.text('문제를 포기하고 나갈까요?'), findsNothing);
    expect(find.text('1/20'), findsOneWidget);

    await tester.tap(find.byTooltip('홈으로'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('예'));
    await tester.pumpAndSettle();

    expect(find.byType(QuizImageScreen), findsNothing);
  });

  testWidgets(
    'last question shows set result after answering and tapping next',
    (tester) async {
      await pumpQuizImageScreen(tester, questions: _questions(2));

      await tester.tap(find.widgetWithText(QuizChoiceCard, '2'));
      await tester.pump();
      await tester.tap(find.byType(QuizNextButton));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(QuizChoiceCard, '1'));
      await tester.pump();
      await tester.tap(find.byType(QuizNextButton));
      await tester.pumpAndSettle();

      expect(find.text('한 세트를 모두 풀이했어요!'), findsOneWidget);
      expect(find.text('2 문제 중 1문제 맞았어요'), findsOneWidget);
    },
  );
}

Future<void> pumpQuizImageScreen(
  WidgetTester tester, {
  List<QuizQuestion>? questions,
}) async {
  tester.view.physicalSize = const Size(480, 1040);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        questionBankRepositoryProvider.overrideWithValue(
          _FakeQuestionBankRepository(questions ?? _questions(20)),
        ),
        quizSessionStoreProvider.overrideWithValue(_FakeQuizSessionStore()),
      ],
      child: const MaterialApp(home: _QuizRouteHost()),
    ),
  );
  await tester.pumpAndSettle();
}

class _QuizRouteHost extends StatefulWidget {
  const _QuizRouteHost();

  @override
  State<_QuizRouteHost> createState() => _QuizRouteHostState();
}

class _QuizRouteHostState extends State<_QuizRouteHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const QuizImageScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
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
}

class _FakeQuizSessionStore implements QuizSessionStore {
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

List<QuizQuestion> _questions(int count) {
  return List.generate(count, (index) {
    final number = index + 1;
    return QuizQuestion(
      id: 'q$number',
      number: number,
      prompt: 'Question $number',
      bodyText: number == 1 ? 'Readable body text' : '',
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
