import 'package:flutter/material.dart';
import 'package:meongssam/core/assets/app_assets.dart';

class MainWarningDialog extends StatelessWidget {
  const MainWarningDialog({
    super.key,
    required this.width,
    required this.scale,
    required this.onConfirm,
  });

  final double width;
  final double scale;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final radius = 8 * scale;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        height: 146 * scale,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Column(
          children: [
            SizedBox(height: 20 * scale),
            Image.asset(
              AppAssets.deongIcon,
              width: 44 * scale,
              height: 44 * scale,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 12 * scale),
            Text(
              'COMING SOON!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Pretendard',
                fontSize: 20 * scale,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
            SizedBox(height: 18 * scale),
            _ConfirmButton(scale: scale, onTap: onConfirm),
          ],
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = 6 * scale;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          width: 51 * scale,
          height: 26 * scale,
          decoration: BoxDecoration(
            color: const Color(0xFF002366),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Center(
            child: Text(
              '확인',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Pretendard',
                fontSize: 12 * scale,
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
