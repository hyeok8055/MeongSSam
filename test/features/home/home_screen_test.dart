import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meongssam/features/home/presentation/view/home_screen.dart';
import 'package:meongssam/features/home/presentation/widgets/level_card.dart';
import 'package:meongssam/features/home/presentation/widgets/quick_action_card.dart';

void main() {
  testWidgets('home screen shows main level actions and quick actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LevelCard), findsNWidgets(3));
    expect(find.byType(QuickActionCard), findsNWidgets(2));
  });
}
