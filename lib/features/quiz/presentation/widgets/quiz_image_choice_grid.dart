import 'package:flutter/material.dart';

class QuizImageChoiceGrid extends StatelessWidget {
  const QuizImageChoiceGrid({
    super.key,
    required this.imageAssetPaths,
    required this.selectedIndex,
    required this.correctChoiceIndex,
    required this.scale,
    required this.onSelect,
    this.labels = const [],
  });

  final List<String> imageAssetPaths;
  final List<String> labels;
  final int? selectedIndex;
  final int correctChoiceIndex;
  final double scale;
  final ValueChanged<int>? onSelect;

  int get _itemCount => labels.isNotEmpty
      ? labels.length
      : imageAssetPaths.length == 1
      ? 4
      : imageAssetPaths.length;

  @override
  Widget build(BuildContext context) {
    if (imageAssetPaths.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      key: const ValueKey('quiz-image-choice-grid'),
      padding: EdgeInsets.fromLTRB(2 * scale, 0, 2 * scale, 24 * scale),
      itemCount: _itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12 * scale,
        mainAxisSpacing: 12 * scale,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        return _ImageChoiceTile(
          label: _labelFor(index),
          assetPath: _assetPathFor(index),
          compositeIndex: _compositeIndexFor(index),
          scale: scale,
          state: _stateFor(index),
          onTap: selectedIndex == null ? () => onSelect?.call(index) : null,
          onLongPress: () => _showExpandedImage(context, index),
        );
      },
    );
  }

  QuizImageChoiceTileState _stateFor(int index) {
    final selected = selectedIndex;
    if (selected == null) return QuizImageChoiceTileState.idle;
    if (index == correctChoiceIndex) return QuizImageChoiceTileState.correct;
    if (index == selected) return QuizImageChoiceTileState.incorrect;
    return QuizImageChoiceTileState.idle;
  }

  Future<void> _showExpandedImage(BuildContext context, int index) {
    final assetPath = _assetPathFor(index);
    final compositeIndex = _compositeIndexFor(index);

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _ExpandedImageDialog(
        label: _labelFor(index),
        assetPath: assetPath,
        compositeIndex: compositeIndex,
      ),
    );
  }

  String _labelFor(int index) {
    if (labels.isEmpty) return '${index + 1}';
    return labels[index];
  }

  String _assetPathFor(int index) {
    if (imageAssetPaths.length == 1) return imageAssetPaths.first;
    return imageAssetPaths[index];
  }

  int? _compositeIndexFor(int index) {
    return imageAssetPaths.length == 1 && _itemCount == 4 ? index : null;
  }
}

enum QuizImageChoiceTileState { idle, correct, incorrect }

class _ImageChoiceTile extends StatelessWidget {
  const _ImageChoiceTile({
    required this.label,
    required this.assetPath,
    required this.scale,
    required this.state,
    required this.onTap,
    required this.onLongPress,
    this.compositeIndex,
  });

  final String label;
  final String assetPath;
  final int? compositeIndex;
  final double scale;
  final QuizImageChoiceTileState state;
  final VoidCallback? onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = _TileColors.fromState(state);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('quiz-image-choice-$label'),
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8 * scale),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: colors.border, width: 2 * scale),
            borderRadius: BorderRadius.circular(8 * scale),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(8 * scale),
                  child: _ImageChoiceAsset(
                    assetPath: assetPath,
                    compositeIndex: compositeIndex,
                  ),
                ),
              ),
              Positioned(
                top: 8 * scale,
                left: 8 * scale,
                child: _ChoiceBadge(
                  label: label,
                  background: colors.badgeBackground,
                  foreground: colors.badgeForeground,
                  scale: scale,
                ),
              ),
              if (state != QuizImageChoiceTileState.idle)
                Positioned(
                  right: 8 * scale,
                  top: 8 * scale,
                  child: Icon(
                    state == QuizImageChoiceTileState.correct
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: colors.badgeBackground,
                    size: 22 * scale,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageChoiceAsset extends StatelessWidget {
  const _ImageChoiceAsset({required this.assetPath, this.compositeIndex});

  final String assetPath;
  final int? compositeIndex;

  @override
  Widget build(BuildContext context) {
    final index = compositeIndex;
    if (index == null) {
      return Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.broken_image));
        },
      );
    }

    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Transform.translate(
            offset: Offset(-constraints.maxWidth * index, 0),
            child: SizedBox(
              width: constraints.maxWidth * 4,
              height: constraints.maxHeight,
              child: Image.asset(
                assetPath,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.broken_image));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ExpandedImageDialog extends StatelessWidget {
  const _ExpandedImageDialog({
    required this.label,
    required this.assetPath,
    this.compositeIndex,
  });

  final String label;
  final String assetPath;
  final int? compositeIndex;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = (size.width - 36).clamp(280.0, 560.0);
    final dialogHeight = (size.height * 0.62).clamp(280.0, 620.0);

    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 46, 20, 20),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _ImageChoiceAsset(
                      assetPath: assetPath,
                      compositeIndex: compositeIndex,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 16,
              child: Text(
                '$label번',
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                tooltip: '닫기',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceBadge extends StatelessWidget {
  const _ChoiceBadge({
    required this.label,
    required this.background,
    required this.foreground,
    required this.scale,
  });

  final String label;
  final Color background;
  final Color foreground;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30 * scale,
      height: 30 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(7 * scale),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontFamily: 'Pretendard',
          fontSize: 12 * scale,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

class _TileColors {
  const _TileColors({
    required this.border,
    required this.badgeBackground,
    required this.badgeForeground,
  });

  final Color border;
  final Color badgeBackground;
  final Color badgeForeground;

  static _TileColors fromState(QuizImageChoiceTileState state) {
    return switch (state) {
      QuizImageChoiceTileState.correct => const _TileColors(
        border: Color(0xFFC9D8F2),
        badgeBackground: Color(0xFF002366),
        badgeForeground: Colors.white,
      ),
      QuizImageChoiceTileState.incorrect => const _TileColors(
        border: Color(0xFFEE9EA3),
        badgeBackground: Color(0xFFE04A3A),
        badgeForeground: Colors.white,
      ),
      QuizImageChoiceTileState.idle => const _TileColors(
        border: Color(0xFFDDE4EE),
        badgeBackground: Color(0xFFF0F2F5),
        badgeForeground: Color(0xFF191C1D),
      ),
    };
  }
}
