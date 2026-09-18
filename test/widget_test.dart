import 'package:flutter_test/flutter_test.dart';
import 'package:pyp_app/main.dart';

void main() {
  testWidgets('PypApp loads Login screen and allows Guest exploration', (WidgetTester tester) async {
    await tester.pumpWidget(const PypApp());
    await tester.pumpAndSettle();

    // Verify initial Login Screen is displayed
    expect(find.text('Welcome to PYP'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    // Tap 'Explore as Guest' to enter Home Screen
    await tester.tap(find.text('Explore as Guest'));
    await tester.pumpAndSettle();

    // Verify Home Screen is displayed
    expect(find.text('Find the perfect'), findsOneWidget);
    expect(find.text('photographer.'), findsOneWidget);
  });
}
