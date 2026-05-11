import 'package:flutter/material.dart';

enum QuizChoiceCardState { idle, selected, correct, incorrect }

class QuizChoiceCard extends StatelessWidget {
  const QuizChoiceCard({
    super.key,
    required this.label,
    required this.text,
    required this.scale,
    this.state = QuizChoiceCardState.idle,
    this.onTap,
  });

  final String label;
  final String text;
  final double scale;
  final QuizChoiceCardState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = 9 * scale;
    final colors = _QuizChoiceCardColors.fromState(state);
    final statusIcon = _statusIconFor(state);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 65 * scale),
          child: Ink(
            decoration: BoxDecoration(
              color: colors.background,
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16 * scale,
                vertical: 12 * scale,
              ),
              child: Row(
                children: [
                  _ChoiceNumberBadge(
                    label: label,
                    scale: scale,
                    background: colors.badgeBackground,
                    foreground: colors.foreground,
                  ),
                  SizedBox(width: 12 * scale),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: const Color(0xFF191C1D),
                        fontFamily: 'Pretendard',
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ),
                  if (statusIcon != null) ...[
                    SizedBox(width: 12 * scale),
                    statusIcon,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _statusIconFor(QuizChoiceCardState state) {
    return switch (state) {
      QuizChoiceCardState.selected ||
      QuizChoiceCardState.correct => _ChoiceStatusIcon(
        icon: Icons.check,
        background: const Color(0xFF001F5C),
        scale: scale,
      ),
      QuizChoiceCardState.incorrect => _ChoiceStatusIcon(
        icon: Icons.close,
        background: const Color(0xFFE04A3A),
        scale: scale,
      ),
      QuizChoiceCardState.idle => null,
    };
  }
}

class _ChoiceNumberBadge extends StatelessWidget {
  const _ChoiceNumberBadge({
    required this.label,
    required this.scale,
    required this.background,
    required this.foreground,
  });

  final String label;
  final double scale;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32 * scale,
      height: 32 * scale,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(7 * scale),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontFamily: 'Pretendard',
          fontSize: 12 * scale,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}

class _ChoiceStatusIcon extends StatelessWidget {
  const _ChoiceStatusIcon({
    required this.icon,
    required this.background,
    required this.scale,
  });

  final IconData icon;
  final Color background;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20 * scale,
      height: 20 * scale,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.white, size: 14 * scale),
    );
  }
}

class _QuizChoiceCardColors {
  const _QuizChoiceCardColors({
    required this.background,
    required this.border,
    required this.badgeBackground,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color badgeBackground;
  final Color foreground;

  static _QuizChoiceCardColors fromState(QuizChoiceCardState state) {
    return switch (state) {
      QuizChoiceCardState.selected => const _QuizChoiceCardColors(
        background: Color(0xFFEAF2FF),
        border: Color(0xFFC9D8F2),
        badgeBackground: Color(0xFF002366),
        foreground: Colors.white,
      ),
      QuizChoiceCardState.correct => const _QuizChoiceCardColors(
        background: Color(0xFFEAF2FF),
        border: Color(0xFFC9D8F2),
        badgeBackground: Color(0xFF002366),
        foreground: Colors.white,
      ),
      QuizChoiceCardState.incorrect => const _QuizChoiceCardColors(
        background: Color(0xFFF6B3B7),
        border: Color(0xFFEE9EA3),
        badgeBackground: Color(0xFFE04A3A),
        foreground: Colors.white,
      ),
      QuizChoiceCardState.idle => const _QuizChoiceCardColors(
        background: Colors.white,
        border: Color(0xFFDDE4EE),
        badgeBackground: Color(0xFFF0F2F5),
        foreground: Color(0xFF191C1D),
      ),
    };
  }
}
