import 'package:flutter/material.dart';
import 'package:meongssam/core/design/app_colors.dart';
import 'package:meongssam/core/design/app_spacing.dart';
import 'package:meongssam/features/home/application/home_view_model.dart';
import 'package:meongssam/shared/ui/app_button.dart';

class LevelCard extends StatelessWidget {
  const LevelCard({super.key, required this.item, this.onTap});

  final HomeLevelItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppButton(
      onTap: onTap,
      backgroundColor: AppColors.surface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.brandSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: AppColors.brand,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(item.description, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
