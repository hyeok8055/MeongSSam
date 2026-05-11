import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meongssam/app/di/app_providers.dart';
import 'package:meongssam/features/quiz/domain/question_bank_repository.dart';
import 'package:meongssam/features/quiz/domain/quiz_question.dart';
import 'package:meongssam/features/quiz/presentation/view/question_audit_screen.dart';

void main() {
  testWidgets('audit screen navigates previous, next, and direct number jump', (
    tester,
  ) async {
    await pumpQuestionAuditScreen(tester);

    expect(find.text('검수 1 / 5'), findsOneWidget);
    expect(find.text('Question 1'), findsOneWidget);

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('검수 2 / 5'), findsOneWidget);
    expect(find.text('Question 2'), findsOneWidget);

    await tester.tap(find.text('이전'));
    await tester.pumpAndSettle();

    expect(find.text('검수 1 / 5'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('audit-question-number-button')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('audit-question-number-field')),
      '4',
    );
    await tester.tap(find.text('이동'));
    await tester.pumpAndSettle();

    expect(find.text('검수 4 / 5'), findsOneWidget);
    expect(find.text('Question 4'), findsOneWidget);
  });
}

Future<void> pumpQuestionAuditScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(480, 1040);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        questionBankRepositoryProvider.overrideWithValue(
          _FakeQuestionBankRepository(_questions(5)),
        ),
      ],
      child: const MaterialApp(home: QuestionAuditScreen()),
    ),
  );
  await tester.pumpAndSettle();
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
      bodyText: 'Body $number',
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
