// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:later_mobile/main.dart';

void main() {
  testWidgets('Theme test screen loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LaterApp());

    // Verify that the theme test screen loads
    expect(find.text('Later - Theme Test'), findsOneWidget);
    expect(find.text('Design System Test'), findsOneWidget);
  });

  testWidgets('Theme toggle button exists', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LaterApp());

    // Find the theme toggle button (icon could be either dark_mode or light_mode)
    final toggleButton = find.byTooltip('Toggle theme');
    expect(toggleButton, findsOneWidget);

    // Tap it and verify the app rebuilds
    await tester.tap(toggleButton);
    await tester.pumpAndSettle();

    // Toggle button should still exist
    expect(find.byTooltip('Toggle theme'), findsOneWidget);
  });
}
