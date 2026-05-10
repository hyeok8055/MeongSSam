import 'package:flutter/material.dart';

class QuizImagePlaceholder extends StatelessWidget {
  const QuizImagePlaceholder({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(painter: _CheckerboardPainter()),
    );
  }
}

class _CheckerboardPainter extends CustomPainter {
  static const _tileSize = 24.0;
  static const _lightColor = Color(0xFFF7F7F7);
  static const _darkColor = Color(0xFFE9E9E9);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final rows = (size.height / _tileSize).ceil();
    final columns = (size.width / _tileSize).ceil();

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        paint.color = (row + column).isEven ? _lightColor : _darkColor;
        canvas.drawRect(
          Rect.fromLTWH(
            column * _tileSize,
            row * _tileSize,
            _tileSize,
            _tileSize,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
