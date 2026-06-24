// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:ai_consultant/main.dart';

void main() {
  testWidgets('AI consultant App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AIConsultantApp());

    // Run the app for a few seconds to let initial timers fire
    await tester.pump(const Duration(seconds: 3));

    // Verify the splash screen is present (brand text may animate)
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
