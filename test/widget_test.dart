import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/main.dart';

void main() {
  testWidgets('App renders Pokédex title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(isDark: false, favoriteIds: {}));
    await tester.pumpAndSettle();
    expect(find.text('Pokédex'), findsOneWidget);
  });
}
