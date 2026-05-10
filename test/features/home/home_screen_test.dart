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
    await pumpHomeScreen(tester);

    expect(find.byType(LevelCard), findsNWidgets(3));
    expect(find.byType(QuickActionCard), findsNWidgets(2));
  });

  testWidgets('first level action opens the image quiz screen', (tester) async {
    await pumpHomeScreen(tester);

    await tester.tap(find.text('1급 문제 풀이'));
    await tester.pumpAndSettle();

    expect(find.text('1/20'), findsOneWidget);
    expect(find.text('1번의 명칭은 무엇입니까?'), findsOneWidget);
    expect(find.text('COMING SOON!'), findsNothing);
  });

  testWidgets('unimplemented main actions show the warning popup', (
    tester,
  ) async {
    await pumpHomeScreen(tester);

    for (final title in ['2급 문제 풀이', '3급 문제 풀이', '즐겨찾기', '오답노트']) {
      await tester.tap(find.text(title));
      await tester.pump();

      expect(find.text('COMING SOON!'), findsOneWidget);
      expect(find.text('확인'), findsOneWidget);

      await tester.tap(find.text('확인'));
      await tester.pump();

      expect(find.text('COMING SOON!'), findsNothing);
    }
  });
}

Future<void> pumpHomeScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(480, 1040);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    const ProviderScope(child: MaterialApp(home: HomeScreen())),
  );
  await tester.pumpAndSettle();
}
