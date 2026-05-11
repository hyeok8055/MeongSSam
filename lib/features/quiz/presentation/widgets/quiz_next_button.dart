import 'package:flutter/material.dart';

class QuizNextButton extends StatelessWidget {
  const QuizNextButton({
    super.key,
    required this.scale,
    required this.onTap,
    this.enabled = true,
  });

  final double scale;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = enabled
        ? const Color(0xFF002366)
        : const Color(0xFFE7EBF2);
    final foreground = enabled ? Colors.white : const Color(0xFF9AA4B2);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(7 * scale),
        child: Ink(
          width: 63 * scale,
          height: 32 * scale,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(7 * scale),
          ),
          child: Center(
            child: Text(
              '다음',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: foreground,
                fontFamily: 'Pretendard',
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
