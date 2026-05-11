import 'package:flutter/material.dart';

class QuizResponsiveFrame extends StatelessWidget {
  const QuizResponsiveFrame({super.key, required this.builder});

  static const figmaWidth = 402.0;
  static const targetDeviceWidth = 480.0;
  static const contentWidth = 342.0;

  final Widget Function(BuildContext context, QuizFrameMetrics metrics) builder;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth.clamp(
          0.0,
          targetDeviceWidth,
        );
        final scale = viewportWidth / figmaWidth;

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: viewportWidth,
            height: constraints.maxHeight,
            child: builder(
              context,
              QuizFrameMetrics(
                scale: scale,
                viewportWidth: viewportWidth,
                contentWidth: contentWidth * scale,
                topInset: topInset,
                minHeight: constraints.maxHeight,
              ),
            ),
          ),
        );
      },
    );
  }
}

class QuizFrameMetrics {
  const QuizFrameMetrics({
    required this.scale,
    required this.viewportWidth,
    required this.contentWidth,
    required this.topInset,
    required this.minHeight,
  });

  final double scale;
  final double viewportWidth;
  final double contentWidth;
  final double topInset;
  final double minHeight;
}
