import 'package:flutter/material.dart';

class QuizQuestionPrompt extends StatelessWidget {
  const QuizQuestionPrompt({
    super.key,
    required this.prompt,
    required this.scale,
  });

  final String prompt;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        prompt,
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'Pretendard',
          fontSize: 22 * scale,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
      ),
    );
  }
}
