import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/widgets/components/fab/quick_capture_fab.dart';
import 'package:later_mobile/widgets/components/fab/responsive_fab.dart';

void main() {
  group('ResponsiveFab', () {
    testWidgets('renders circular FAB without label on mobile', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)), // Mobile size
            child: Scaffold(
              body: ResponsiveFab(
                icon: Icons.add,
                label: 'Add Item',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Verify QuickCaptureFab is used on mobile
      expect(find.byType(QuickCaptureFab), findsOneWidget);

      // Verify the icon is present
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Verify label is NOT shown on mobile (only in accessibility/tooltip)
      expect(find.text('Add Item'), findsNothing);
    });

    testWidgets('renders extended FAB with label on desktop', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1440, 900)), // Desktop size
            child: Scaffold(
              body: ResponsiveFab(
                icon: Icons.add,
                label: 'Add Item',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Verify FloatingActionButton.extended is used on desktop
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Verify the icon is present
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Verify label IS shown on desktop
      expect(find.text('Add Item'), findsOneWidget);
    });

    testWidgets('onPressed callback works on mobile', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)), // Mobile size
            child: Scaffold(
              body: ResponsiveFab(
                icon: Icons.add,
                label: 'Add Item',
                onPressed: () => pressed = true,
              ),
            ),
          ),
        ),
      );

      // Tap the FAB
      await tester.tap(find.byType(QuickCaptureFab));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(pressed, isTrue);
    });

    testWidgets('onPressed callback works on desktop', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1440, 900)), // Desktop size
            child: Scaffold(
              body: ResponsiveFab(
                icon: Icons.add,
                label: 'Add Item',
                onPressed: () => pressed = true,
              ),
            ),
          ),
        ),
      );

      // Tap the FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(pressed, isTrue);
    });

    testWidgets('supports custom icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)), // Mobile size
            child: Scaffold(
              body: ResponsiveFab(
                icon: Icons.edit,
                label: 'Edit',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Verify custom icon is present
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('supports null onPressed (disabled state)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(375, 812)), // Mobile size
            child: Scaffold(
              body: ResponsiveFab(icon: Icons.add, label: 'Add Item'),
            ),
          ),
        ),
      );

      // Verify FAB is rendered
      expect(find.byType(QuickCaptureFab), findsOneWidget);
    });

    testWidgets('uses tooltip when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)), // Mobile size
            child: Scaffold(
              body: ResponsiveFab(
                icon: Icons.add,
                label: 'Add Item',
                tooltip: 'Custom Tooltip',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Verify FAB is rendered
      expect(find.byType(QuickCaptureFab), findsOneWidget);
    });

    testWidgets('uses label as tooltip when tooltip not provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)), // Mobile size
            child: Scaffold(
              body: ResponsiveFab(
                icon: Icons.add,
                label: 'Add Item',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Verify FAB is rendered
      expect(find.byType(QuickCaptureFab), findsOneWidget);
    });

    testWidgets('supports custom heroTag', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)), // Mobile size
            child: Scaffold(
              body: ResponsiveFab(
                icon: Icons.add,
                label: 'Add Item',
                heroTag: 'custom-hero',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Verify FAB is rendered
      expect(find.byType(QuickCaptureFab), findsOneWidget);
    });

    testWidgets('renders in light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)), // Mobile size
            child: Scaffold(
              body: ResponsiveFab(
                icon: Icons.add,
                label: 'Add Item',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Verify FAB is rendered
      expect(find.byType(QuickCaptureFab), findsOneWidget);
    });

    testWidgets('renders in dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)), // Mobile size
            child: Scaffold(
              body: ResponsiveFab(
                icon: Icons.add,
                label: 'Add Item',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Verify FAB is rendered
      expect(find.byType(QuickCaptureFab), findsOneWidget);
    });

    testWidgets('adapts from mobile to desktop on resize', (tester) async {
      // Start with mobile size
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)), // Mobile size
            child: Scaffold(
              body: ResponsiveFab(
                icon: Icons.add,
                label: 'Add Item',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Verify mobile FAB
      expect(find.byType(QuickCaptureFab), findsOneWidget);

      // Resize to desktop
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1440, 900)), // Desktop size
            child: Scaffold(
              body: ResponsiveFab(
                icon: Icons.add,
                label: 'Add Item',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Verify desktop FAB with label
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Add Item'), findsOneWidget);
    });
  });
}
