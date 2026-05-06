import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meongssam/features/home/application/home_view_model.dart';

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.item,
    this.scale = 1,
    this.onTap,
  });

  final HomeQuickActionItem item;
  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = 12 * scale;
    final height = 130 * scale;
    final iconSize = 56 * scale;

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
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 17 * scale,
                child: SvgPicture.asset(
                  item.iconAsset,
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 83 * scale,
                left: 0,
                right: 0,
                child: Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
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
