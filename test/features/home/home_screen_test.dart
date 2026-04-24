import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meongssam/app/app.dart';

void main() {
  testWidgets('home screen shows main level actions and quick actions', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MeongSSamApp()));
    await tester.pumpAndSettle();

    expect(find.text('1급 문제 풀이'), findsOneWidget);
    expect(find.text('2급 문제 풀이'), findsOneWidget);
    expect(find.text('3급 문제 풀이'), findsOneWidget);
    expect(find.text('오답노트'), findsOneWidget);
    expect(find.text('즐겨찾기'), findsOneWidget);
  });
}
