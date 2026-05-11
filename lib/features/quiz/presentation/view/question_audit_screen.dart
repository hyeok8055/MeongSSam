import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongssam/app/di/app_providers.dart';
import 'package:meongssam/features/quiz/domain/quiz_question.dart';
import 'package:meongssam/features/quiz/presentation/widgets/quiz_choice_card.dart';
import 'package:meongssam/features/quiz/presentation/widgets/quiz_image_placeholder.dart';
import 'package:meongssam/features/quiz/presentation/widgets/quiz_question_prompt.dart';

final questionAuditQuestionsProvider =
    FutureProvider.autoDispose<List<QuizQuestion>>((ref) {
      return ref.watch(questionBankRepositoryProvider).loadAllQuestions();
    });

class QuestionAuditScreen extends ConsumerStatefulWidget {
  const QuestionAuditScreen({super.key});

  @override
  ConsumerState<QuestionAuditScreen> createState() =>
      _QuestionAuditScreenState();
}

class _QuestionAuditScreenState extends ConsumerState<QuestionAuditScreen> {
  int _currentIndex = 0;

  void _showPrevious(List<QuizQuestion> questions) {
    if (_currentIndex == 0) return;
    setState(() => _currentIndex -= 1);
  }

  void _showNext(List<QuizQuestion> questions) {
    if (_currentIndex >= questions.length - 1) return;
    setState(() => _currentIndex += 1);
  }

  Future<void> _showQuestionPicker(List<QuizQuestion> questions) async {
    final selectedNumber = await showDialog<int>(
      context: context,
      builder: (context) => _QuestionNumberDialog(
        currentNumber: questions[_currentIndex].number,
        minNumber: questions.first.number,
        maxNumber: questions.last.number,
      ),
    );
    if (!mounted || selectedNumber == null) return;

    final targetIndex = questions.indexWhere(
      (question) => question.number == selectedNumber,
    );
    if (targetIndex >= 0) {
      setState(() => _currentIndex = targetIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionsValue = ref.watch(questionAuditQuestionsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: questionsValue.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text(error.toString())),
            data: (questions) {
              if (questions.isEmpty) {
                return const Center(child: Text('검수할 문제가 없습니다'));
              }

              final safeIndex = _currentIndex
                  .clamp(0, questions.length - 1)
                  .toInt();
              final question = questions[safeIndex];

              return Column(
                children: [
                  _AuditHeader(
                    question: question,
                    totalCount: questions.length,
                    canGoPrevious: safeIndex > 0,
                    canGoNext: safeIndex < questions.length - 1,
                    onPrevious: () => _showPrevious(questions),
                    onNumberTap: () => _showQuestionPicker(questions),
                    onNext: () => _showNext(questions),
                  ),
                  Expanded(
                    child: _AuditQuestionBody(
                      question: question,
                      currentIndex: safeIndex,
                      totalCount: questions.length,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuditHeader extends StatelessWidget {
  const _AuditHeader({
    required this.question,
    required this.totalCount,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNumberTap,
    required this.onNext,
  });

  final QuizQuestion question;
  final int totalCount;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNumberTap;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: canGoPrevious ? onPrevious : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text('이전'),
          ),
          Expanded(
            child: Center(
              child: OutlinedButton(
                key: const ValueKey('audit-question-number-button'),
                onPressed: onNumberTap,
                child: Text('${question.number} / $totalCount'),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: canGoNext ? onNext : null,
            icon: const Text('다음'),
            label: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _AuditQuestionBody extends StatelessWidget {
  const _AuditQuestionBody({
    required this.question,
    required this.currentIndex,
    required this.totalCount,
  });

  final QuizQuestion question;
  final int currentIndex;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final contentWidth = width.clamp(0.0, 560.0);
    final imageHeight =
        MediaQuery.sizeOf(context).height.clamp(640.0, 1040.0) * 0.34;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        (width - contentWidth) / 2 + 18,
        12,
        (width - contentWidth) / 2 + 18,
        28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '검수 ${currentIndex + 1} / $totalCount',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          QuizQuestionPrompt(prompt: question.prompt, scale: 1),
          const SizedBox(height: 18),
          SizedBox(
            height: imageHeight,
            child: QuizImagePlaceholder(
              height: imageHeight,
              imageAssetPath: question.imageAssetPaths.isEmpty
                  ? null
                  : question.imageAssetPaths.first,
              bodyText: question.bodyText,
            ),
          ),
          const SizedBox(height: 18),
          for (var index = 0; index < question.choices.length; index++) ...[
            QuizChoiceCard(
              label: question.choices[index].label,
              text: question.choices[index].text,
              scale: 1,
              state: index == question.correctChoiceIndex
                  ? QuizChoiceCardState.correct
                  : QuizChoiceCardState.idle,
            ),
            if (index != question.choices.length - 1)
              const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _QuestionNumberDialog extends StatefulWidget {
  const _QuestionNumberDialog({
    required this.currentNumber,
    required this.minNumber,
    required this.maxNumber,
  });

  final int currentNumber;
  final int minNumber;
  final int maxNumber;

  @override
  State<_QuestionNumberDialog> createState() => _QuestionNumberDialogState();
}

class _QuestionNumberDialogState extends State<_QuestionNumberDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentNumber.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_controller.text.trim());
    if (value == null || value < widget.minNumber || value > widget.maxNumber) {
      setState(() {
        _errorText = '${widget.minNumber}~${widget.maxNumber} 사이 번호를 입력하세요';
      });
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('문제 번호 이동'),
      content: TextField(
        key: const ValueKey('audit-question-number-field'),
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: '문제 번호',
          helperText: '${widget.minNumber}~${widget.maxNumber}',
          errorText: _errorText,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(onPressed: _submit, child: const Text('이동')),
      ],
    );
  }
}
