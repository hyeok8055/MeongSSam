import 'package:flutter/material.dart';
import 'package:meongssam/features/home/application/home_view_model.dart';

class LevelCard extends StatelessWidget {
  const LevelCard({super.key, required this.item, this.scale = 1, this.onTap});

  final HomeLevelItem item;
  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final height = 66 * scale;
    final iconSize = 58 * scale * item.iconScale;
    final radius = 12 * scale;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F5),
            border: Border.all(color: const Color(0x1A002366)),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 17 * scale,
                top: (height - iconSize) / 2,
                child: Image.asset(
                  item.iconAsset,
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                ),
              ),
              Center(
                child: Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF191C1D),
                    fontFamily: 'Pretendard',
                    fontSize: 24 * scale,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
