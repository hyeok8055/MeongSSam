import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongssam/features/quiz/application/quiz_view_model.dart';
import 'package:meongssam/features/quiz/presentation/widgets/quiz_choice_card.dart';
import 'package:meongssam/features/quiz/presentation/widgets/quiz_image_placeholder.dart';

class QuizImageScreen extends ConsumerWidget {
  const QuizImageScreen({super.key});

  static const _figmaWidth = 402.0;
  static const _targetDeviceWidth = 480.0;
  static const _contentWidth = 342.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final question = ref.watch(quizViewModelProvider).currentQuestion;
    final topInset = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewportWidth = constraints.maxWidth.clamp(
                0.0,
                _targetDeviceWidth,
              );
              final scale = viewportWidth / _figmaWidth;
              final topGap = (83 * scale - topInset).clamp(0.0, 64.0);
              final contentWidth = _contentWidth * scale;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: viewportWidth,
                      child: Column(
                        children: [
                          SizedBox(height: topGap),
                          Text(
                            '${question.currentNumber}/${question.totalCount}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Pretendard',
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.w600,
                              height: 1,
                            ),
                          ),
                          SizedBox(height: 26 * scale),
                          SizedBox(
                            width: contentWidth,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                question.prompt,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Pretendard',
                                  fontSize: 20 * scale,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 23 * scale),
                          SizedBox(
                            width: viewportWidth,
                            child: QuizImagePlaceholder(height: 234 * scale),
                          ),
                          SizedBox(height: 22 * scale),
                          SizedBox(
                            width: contentWidth,
                            child: Column(
                              children: [
                                for (
                                  var index = 0;
                                  index < question.choices.length;
                                  index++
                                ) ...[
                                  QuizChoiceCard(
                                    label: question.choices[index],
                                    scale: scale,
                                  ),
                                  if (index != question.choices.length - 1)
                                    SizedBox(height: 15 * scale),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: 74 * scale),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
