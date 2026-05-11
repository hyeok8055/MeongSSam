import 'package:flutter/material.dart';

class QuizImagePlaceholder extends StatelessWidget {
  const QuizImagePlaceholder({
    super.key,
    required this.height,
    this.imageAssetPath,
    this.bodyText = '',
    this.showNavigation = false,
    this.currentImageIndex = 0,
    this.imageCount = 0,
    this.onPrevious,
    this.onNext,
  });

  final double height;
  final String? imageAssetPath;
  final String bodyText;
  final bool showNavigation;
  final int currentImageIndex;
  final int imageCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final hasBodyText = bodyText.trim().isNotEmpty;
    final hasImage = imageAssetPath != null;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: GestureDetector(
        onHorizontalDragEnd: showNavigation && hasImage
            ? (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity < -120) {
                  onNext?.call();
                } else if (velocity > 120) {
                  onPrevious?.call();
                }
              }
            : null,
        child: ColoredBox(
          color: Colors.white,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: _StimulusContent(
                  imageAssetPath: imageAssetPath,
                  bodyText: bodyText,
                  showBodyPanel: hasBodyText,
                  imageFlex: hasImage && hasBodyText ? 3 : 1,
                  bodyFlex: hasImage && hasBodyText ? 2 : 1,
                ),
              ),
              if (showNavigation && hasImage) ...[
                Positioned(
                  left: 5,
                  child: _ImageNavigationButton(
                    icon: Icons.chevron_left,
                    onTap: onPrevious,
                  ),
                ),
                Positioned(
                  right: 5,
                  child: _ImageNavigationButton(
                    icon: Icons.chevron_right,
                    onTap: onNext,
                  ),
                ),
                Positioned(
                  bottom: 8,
                  child: _ImagePageDots(
                    currentIndex: currentImageIndex,
                    imageCount: imageCount,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StimulusContent extends StatelessWidget {
  const _StimulusContent({
    required this.imageAssetPath,
    required this.bodyText,
    required this.showBodyPanel,
    required this.imageFlex,
    required this.bodyFlex,
  });

  final String? imageAssetPath;
  final String bodyText;
  final bool showBodyPanel;
  final int imageFlex;
  final int bodyFlex;

  @override
  Widget build(BuildContext context) {
    if (imageAssetPath == null && !showBodyPanel) {
      return const SizedBox.shrink();
    }

    if (imageAssetPath == null) {
      return _StimulusTextPanel(text: bodyText, fillsHeight: true);
    }

    if (!showBodyPanel) {
      return _StimulusImage(assetPath: imageAssetPath!);
    }

    return Column(
      children: [
        Expanded(
          flex: imageFlex,
          child: _StimulusImage(assetPath: imageAssetPath!),
        ),
        const SizedBox(height: 10),
        Expanded(
          flex: bodyFlex,
          child: _StimulusTextPanel(text: bodyText, fillsHeight: true),
        ),
      ],
    );
  }
}

class _StimulusImage extends StatelessWidget {
  const _StimulusImage({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Center(child: Icon(Icons.broken_image));
      },
    );
  }
}

class _StimulusTextPanel extends StatelessWidget {
  const _StimulusTextPanel({required this.text, required this.fillsHeight});

  final String text;
  final bool fillsHeight;

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF191C1D),
          fontFamily: 'Pretendard',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),
      ),
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE3E7EE)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: fillsHeight ? content : IntrinsicHeight(child: content),
    );
  }
}

class _ImageNavigationButton extends StatelessWidget {
  const _ImageNavigationButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      icon: Icon(icon, color: Colors.black, size: 32),
      splashRadius: 20,
    );
  }
}

class _ImagePageDots extends StatelessWidget {
  const _ImagePageDots({required this.currentIndex, required this.imageCount});

  final int currentIndex;
  final int imageCount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x99000000),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < imageCount; index++) ...[
              AnimatedContainer(
                key: ValueKey('quiz-image-page-dot-$index'),
                duration: const Duration(milliseconds: 160),
                width: index == currentIndex ? 14 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: index == currentIndex
                      ? Colors.white
                      : const Color(0x99FFFFFF),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              if (index != imageCount - 1) const SizedBox(width: 5),
            ],
          ],
        ),
      ),
    );
  }
}
