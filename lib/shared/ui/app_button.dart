import 'package:flutter/material.dart';
import 'package:meongssam/core/design/app_radius.dart';
import 'package:meongssam/shared/ui/app_card.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AppCard(
          backgroundColor: backgroundColor,
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
