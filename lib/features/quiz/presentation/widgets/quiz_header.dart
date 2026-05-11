import 'package:flutter/material.dart';
import 'package:meongssam/features/quiz/presentation/widgets/quiz_next_button.dart';
import 'package:meongssam/features/quiz/presentation/widgets/quiz_progress_label.dart';

class QuizHeader extends StatelessWidget {
  const QuizHeader({
    super.key,
    required this.currentNumber,
    required this.totalCount,
    required this.viewportWidth,
    required this.contentWidth,
    required this.scale,
    required this.onNext,
    required this.onBack,
    this.nextEnabled = true,
  });

  final int currentNumber;
  final int totalCount;
  final double viewportWidth;
  final double contentWidth;
  final double scale;
  final bool nextEnabled;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final sideInset = 13 * scale;

    return SizedBox(
      width: viewportWidth,
      height: 32 * scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          QuizProgressLabel(
            currentNumber: currentNumber,
            totalCount: totalCount,
            scale: scale,
          ),
          Positioned(
            left: sideInset,
            top: 0,
            child: IconButton(
              tooltip: '홈으로',
              onPressed: onBack,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tightFor(
                width: 32 * scale,
                height: 32 * scale,
              ),
              icon: Icon(
                Icons.chevron_left,
                color: Colors.black,
                size: 28 * scale,
              ),
              splashRadius: 20 * scale,
            ),
          ),
          Positioned(
            right: sideInset,
            top: 0,
            child: QuizNextButton(
              scale: scale,
              enabled: nextEnabled,
              onTap: onNext,
            ),
          ),
        ],
      ),
    );
  }
}
