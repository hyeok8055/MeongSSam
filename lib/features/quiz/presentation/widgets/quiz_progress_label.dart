import 'package:flutter/material.dart';

class QuizProgressLabel extends StatelessWidget {
  const QuizProgressLabel({
    super.key,
    required this.currentNumber,
    required this.totalCount,
    required this.scale,
  });

  final int currentNumber;
  final int totalCount;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$currentNumber/$totalCount',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black,
        fontFamily: 'Pretendard',
        fontSize: 20 * scale,
        fontWeight: FontWeight.w600,
        height: 1,
      ),
    );
  }
}
