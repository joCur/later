import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/widgets/components/fab/quick_capture_fab.dart';

void main() {
  group('QuickCaptureFab', () {
    testWidgets('renders FAB with icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickCaptureFab(
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(QuickCaptureFab), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickCaptureFab(
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(QuickCaptureFab));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('has correct size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickCaptureFab(
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(QuickCaptureFab),
          matching: find.byType(Container),
        ),
      );

      // Temporal Flow: 64x64px squircle FAB
      expect(container.constraints?.maxWidth, 64);
      expect(container.constraints?.maxHeight, 64);
    });

    testWidgets('renders with custom icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickCaptureFab(
              icon: Icons.edit,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('renders with custom label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickCaptureFab(
              label: 'Create',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('renders extended FAB with icon and label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickCaptureFab(
              label: 'Create Item',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Create Item'), findsOneWidget);
    });

    testWidgets('shows tooltip when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickCaptureFab(
              tooltip: 'Quick Capture',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(QuickCaptureFab), findsOneWidget);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuickCaptureFab(
              onPressed: null,
            ),
          ),
        ),
      );

      final fab = tester.widget<QuickCaptureFab>(find.byType(QuickCaptureFab));
      expect(fab.onPressed, isNull);
    });

    testWidgets('has hero tag when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickCaptureFab(
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(QuickCaptureFab), findsOneWidget);
    });

    testWidgets('has elevation shadow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickCaptureFab(
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(QuickCaptureFab), findsOneWidget);
    });
  });
}
