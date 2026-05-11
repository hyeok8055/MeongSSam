import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongssam/core/assets/app_assets.dart';
import 'package:meongssam/features/quiz/application/quiz_view_model.dart';
import 'package:meongssam/features/quiz/presentation/widgets/quiz_choice_list.dart';
import 'package:meongssam/features/quiz/presentation/widgets/quiz_header.dart';
import 'package:meongssam/features/quiz/presentation/widgets/quiz_image_placeholder.dart';
import 'package:meongssam/features/quiz/presentation/widgets/quiz_question_prompt.dart';
import 'package:meongssam/features/quiz/presentation/widgets/quiz_responsive_frame.dart';

class QuizImageScreen extends ConsumerStatefulWidget {
  const QuizImageScreen({super.key, this.launchMode = QuizLaunchMode.resume});

  final QuizLaunchMode launchMode;

  @override
  ConsumerState<QuizImageScreen> createState() => _QuizImageScreenState();
}

class _QuizImageScreenState extends ConsumerState<QuizImageScreen> {
  String? _imageQuestionId;
  int _imageIndex = 0;

  void _selectChoice(int index) {
    ref
        .read(quizViewModelProvider(widget.launchMode).notifier)
        .selectChoice(index);
  }

  void _goNext() {
    ref.read(quizViewModelProvider(widget.launchMode).notifier).goNext();
  }

  void _closeCompletion() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  Future<void> _requestExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _QuizExitDialog(),
    );
    if (!mounted || shouldExit != true) return;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  void _showPreviousImage(int imageCount) {
    setState(() {
      _imageIndex = (_imageIndex - 1).clamp(0, imageCount - 1).toInt();
    });
  }

  void _showNextImage(int imageCount) {
    setState(() {
      _imageIndex = (_imageIndex + 1).clamp(0, imageCount - 1).toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizViewModelProvider(widget.launchMode));
    final question = state.currentQuestion;

    if (state.status == QuizStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.status == QuizStatus.failure) {
      return Scaffold(
        body: Center(child: Text(state.errorMessage ?? 'Question bank error')),
      );
    }

    if (question == null) {
      return const Scaffold(body: Center(child: Text('No questions')));
    }

    if (_imageQuestionId != question.id) {
      _imageQuestionId = question.id;
      _imageIndex = 0;
    }

    final imageCount = question.imageAssetPaths.length;
    final imageAssetPath = imageCount == 0
        ? null
        : question.imageAssetPaths[_imageIndex
              .clamp(0, imageCount - 1)
              .toInt()];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _requestExit();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.white,
          systemNavigationBarColor: Colors.white,
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              SafeArea(
                child: QuizResponsiveFrame(
                  builder: (context, metrics) {
                    final scale = metrics.scale;
                    final topGap = 27 * scale;
                    final promptWidth = metrics.viewportWidth - (32 * scale);
                    final stimulusHeight = (metrics.minHeight * 0.31)
                        .clamp(220 * scale, 294 * scale)
                        .toDouble();

                    return Column(
                      children: [
                        SizedBox(height: topGap),
                        QuizHeader(
                          currentNumber: state.currentNumber,
                          totalCount: state.totalCount,
                          viewportWidth: metrics.viewportWidth,
                          contentWidth: metrics.contentWidth,
                          scale: scale,
                          nextEnabled: state.canUseNext,
                          onNext: _goNext,
                          onBack: _requestExit,
                        ),
                        SizedBox(height: 24 * scale),
                        SizedBox(
                          width: promptWidth,
                          child: QuizQuestionPrompt(
                            prompt: question.prompt,
                            scale: scale,
                          ),
                        ),
                        SizedBox(height: 24 * scale),
                        SizedBox(
                          width: metrics.viewportWidth,
                          height: stimulusHeight,
                          child: ClipRect(
                            child: QuizImagePlaceholder(
                              height: stimulusHeight,
                              imageAssetPath: imageAssetPath,
                              bodyText: question.bodyText,
                              showNavigation: question.hasImageNavigation,
                              onPrevious: () => _showPreviousImage(imageCount),
                              onNext: () => _showNextImage(imageCount),
                            ),
                          ),
                        ),
                        SizedBox(height: 16 * scale),
                        Expanded(
                          child: ClipRect(
                            child: ColoredBox(
                              color: Colors.white,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: SizedBox(
                                  width: metrics.contentWidth,
                                  child: QuizChoiceList(
                                    choices: question.choices,
                                    selectedIndex: state.selectedChoiceIndex,
                                    correctChoiceIndex:
                                        question.correctChoiceIndex,
                                    scale: scale,
                                    onSelect: _selectChoice,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (state.status == QuizStatus.completed)
                _QuizCompletionOverlay(
                  totalCount: state.totalCount,
                  correctCount: state.correctCount,
                  onConfirm: _closeCompletion,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizExitDialog extends StatelessWidget {
  const _QuizExitDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFF9FAFB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text(
        '문제를 포기하고 나갈까요?',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'Pretendard',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('아니오'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF002366),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Text('예'),
        ),
      ],
    );
  }
}

class _QuizCompletionOverlay extends StatelessWidget {
  const _QuizCompletionOverlay({
    required this.totalCount,
    required this.correctCount,
    required this.onConfirm,
  });

  final int totalCount;
  final int correctCount;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dialogWidth = (screenWidth - 58).clamp(280.0, 342.0);

    return Stack(
      children: [
        const Positioned.fill(
          child: ModalBarrier(color: Color(0x80000000), dismissible: false),
        ),
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: dialogWidth,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    AppAssets.deongIcon,
                    width: 44,
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '한 세트를 모두 풀이했어요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Pretendard',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    '$totalCount 문제 중 $correctCount문제 맞았어요',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'Pretendard',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onConfirm,
                      borderRadius: BorderRadius.circular(6),
                      child: Ink(
                        width: 63,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF002366),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text(
                            '확인',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
