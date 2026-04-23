import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meongssam/app/app.dart';

void main() {
  testWidgets('MeongSSamApp renders the app shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MeongSSamApp()));

    expect(find.text('멍쌤'), findsOneWidget);
  });
}
