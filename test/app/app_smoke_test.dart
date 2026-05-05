import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meongssam/app/app.dart';
import 'package:meongssam/features/home/presentation/widgets/level_card.dart';

void main() {
  testWidgets('MeongSSamApp renders the home shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MeongSSamApp()));
    await tester.pumpAndSettle();

    expect(find.byType(LevelCard), findsNWidgets(3));
  });
}
