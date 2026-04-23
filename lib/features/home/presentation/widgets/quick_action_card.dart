import 'package:flutter/material.dart';
import 'package:meongssam/core/design/app_colors.dart';
import 'package:meongssam/core/design/app_spacing.dart';
import 'package:meongssam/features/home/application/home_view_model.dart';
import 'package:meongssam/shared/ui/app_button.dart';

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({super.key, required this.item, this.onTap});

  final HomeQuickActionItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isNote = item.title == '오답노트';
    final backgroundColor = isNote ? AppColors.note : AppColors.favorite;
    final icon = isNote ? Icons.auto_stories_rounded : Icons.favorite_rounded;
    final theme = Theme.of(context);

    return AppButton(
      onTap: onTap,
      backgroundColor: backgroundColor,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 156),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(item.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(item.description, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
