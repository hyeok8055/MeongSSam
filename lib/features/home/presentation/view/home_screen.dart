import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongssam/core/assets/app_assets.dart';
import 'package:meongssam/features/home/application/home_view_model.dart';
import 'package:meongssam/features/home/presentation/widgets/level_card.dart';
import 'package:meongssam/features/home/presentation/widgets/quick_action_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _figmaWidth = 402.0;
  static const _targetDeviceWidth = 480.0;
  static const _contentWidth = 342.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(homeViewModelProvider);
    final topInset = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewportWidth = constraints.maxWidth.clamp(
                0.0,
                _targetDeviceWidth,
              );
              final scale = viewportWidth / _figmaWidth;
              final topGap = (82 * scale - topInset).clamp(0.0, 72.0);
              final contentWidth = _contentWidth * scale;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: viewportWidth,
                      child: Column(
                        children: [
                          SizedBox(height: topGap),
                          Image.asset(
                            AppAssets.boricon,
                            width: 94 * scale,
                            height: 94 * scale,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: 44 * scale),
                          SizedBox(
                            width: contentWidth,
                            child: Column(
                              children: [
                                for (
                                  var index = 0;
                                  index < viewModel.levels.length;
                                  index++
                                ) ...[
                                  LevelCard(
                                    item: viewModel.levels[index],
                                    scale: scale,
                                  ),
                                  if (index != viewModel.levels.length - 1)
                                    SizedBox(height: 25 * scale),
                                ],
                                SizedBox(height: 25 * scale),
                                Row(
                                  children: [
                                    for (
                                      var index = 0;
                                      index < viewModel.quickActions.length;
                                      index++
                                    ) ...[
                                      Expanded(
                                        child: QuickActionCard(
                                          item: viewModel.quickActions[index],
                                          scale: scale,
                                        ),
                                      ),
                                      if (index !=
                                          viewModel.quickActions.length - 1)
                                        SizedBox(width: 23 * scale),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
