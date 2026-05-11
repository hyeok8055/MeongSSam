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
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: sideInset),
              child: _HeaderIconButton(scale: scale, onTap: onBack),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: sideInset),
              child: QuizNextButton(
                scale: scale,
                enabled: nextEnabled,
                onTap: onNext,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '홈으로',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7 * scale),
          child: SizedBox(
            width: 63 * scale,
            height: 32 * scale,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                Icons.chevron_left,
                color: Colors.black,
                size: 28 * scale,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
