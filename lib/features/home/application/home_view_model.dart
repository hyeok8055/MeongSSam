import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeViewModelProvider = Provider<HomeViewModel>((ref) {
  return const HomeViewModel();
});

class HomeViewModel {
  const HomeViewModel();

  List<HomeLevelItem> get levels => const [
    HomeLevelItem(
      title: '1급 문제 풀이',
      description: '핵심 유형을 빠르게 훑고 실전 감각을 유지합니다.',
    ),
    HomeLevelItem(title: '2급 문제 풀이', description: '출제 빈도가 높은 문제를 차분하게 정리합니다.'),
    HomeLevelItem(title: '3급 문제 풀이', description: '기본 개념과 대표 문제를 가볍게 복습합니다.'),
  ];

  List<HomeQuickActionItem> get quickActions => const [
    HomeQuickActionItem(title: '오답노트', description: '헷갈린 문제를 다시 모아봅니다.'),
    HomeQuickActionItem(title: '즐겨찾기', description: '자주 보는 문제를 바로 꺼내봅니다.'),
  ];
}

class HomeLevelItem {
  const HomeLevelItem({required this.title, required this.description});

  final String title;
  final String description;
}

class HomeQuickActionItem {
  const HomeQuickActionItem({required this.title, required this.description});

  final String title;
  final String description;
}
