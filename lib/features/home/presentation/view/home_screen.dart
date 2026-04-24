import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongssam/core/design/app_spacing.dart';
import 'package:meongssam/features/home/application/home_view_model.dart';
import 'package:meongssam/features/home/presentation/widgets/home_header.dart';
import 'package:meongssam/features/home/presentation/widgets/level_card.dart';
import 'package:meongssam/features/home/presentation/widgets/quick_action_card.dart';
import 'package:meongssam/shared/ui/app_scaffold.dart';
import 'package:meongssam/shared/ui/app_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(homeViewModelProvider);

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: AppSpacing.lg,
          bottom: AppSpacing.xl,
        ),
        child: Column(
          children: [
            const HomeHeader(),
            const SizedBox(height: AppSpacing.xl),
            AppSection(
              title: '문제 풀이',
              subtitle: '원하는 난이도를 선택해 바로 학습을 시작합니다.',
              child: Column(
                children: [
                  for (final item in viewModel.levels) ...[
                    LevelCard(item: item),
                    if (item != viewModel.levels.last)
                      const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppSection(
              title: '빠른 이동',
              subtitle: '자주 여는 학습 도구를 한 번에 접근합니다.',
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSingleColumn = constraints.maxWidth < 420;
                  if (isSingleColumn) {
                    return Column(
                      children: [
                        for (final item in viewModel.quickActions) ...[
                          QuickActionCard(item: item),
                          if (item != viewModel.quickActions.last)
                            const SizedBox(height: AppSpacing.md),
                        ],
                      ],
                    );
                  }

                  return Row(
                    children: [
                      for (
                        var index = 0;
                        index < viewModel.quickActions.length;
                        index++
                      ) ...[
                        Expanded(
                          child: QuickActionCard(
                            item: viewModel.quickActions[index],
                          ),
                        ),
                        if (index != viewModel.quickActions.length - 1)
                          const SizedBox(width: AppSpacing.md),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
