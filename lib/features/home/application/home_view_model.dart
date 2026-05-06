import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongssam/core/assets/app_assets.dart';

final homeViewModelProvider = Provider<HomeViewModel>((ref) {
  return const HomeViewModel();
});

class HomeViewModel {
  const HomeViewModel();

  List<HomeLevelItem> get levels => const [
    HomeLevelItem(title: '1급 문제 풀이', iconAsset: AppAssets.deongIcon),
    HomeLevelItem(title: '2급 문제 풀이', iconAsset: AppAssets.somcon),
    HomeLevelItem(
      title: '3급 문제 풀이',
      iconAsset: AppAssets.mengcon,
      // TODO: Rework the source asset so the 3급 icon ratio matches Figma exactly.
      iconScale: 1.12,
    ),
  ];

  List<HomeQuickActionItem> get quickActions => const [
    HomeQuickActionItem(title: '즐겨찾기', iconAsset: AppAssets.star),
    HomeQuickActionItem(title: '오답노트', iconAsset: AppAssets.error),
  ];
}

class HomeLevelItem {
  const HomeLevelItem({
    required this.title,
    required this.iconAsset,
    this.iconScale = 1,
  });

  final String title;
  final String iconAsset;
  final double iconScale;
}

class HomeQuickActionItem {
  const HomeQuickActionItem({required this.title, required this.iconAsset});

  final String title;
  final String iconAsset;
}
