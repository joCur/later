import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/design_system/molecules/fab/create_content_fab.dart';
import 'package:later_mobile/design_system/organisms/fab/responsive_fab.dart';

void main() {
  Widget createTestApp({
    required Widget child,
    Size size = const Size(375, 812),
    bool disableAnimations = false,
  }) {
    return MediaQuery(
      data: MediaQueryData(size: size, disableAnimations: disableAnimations),
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          extensions: [TemporalFlowTheme.light()],
        ),
        home: Scaffold(body: child),
      ),
    );
  }

  group('ResponsiveFab', () {
    testWidgets('renders circular FAB without label on mobile', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: ResponsiveFab(
            icon: Icons.add,
            label: 'Add Item',
            onPressed: () {},
          ),
        ),
      );

      // Verify CreateContentFab is used on mobile
      expect(find.byType(CreateContentFab), findsOneWidget);

      // Verify the icon is present
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Verify label is NOT shown on mobile (only in accessibility/tooltip)
      expect(find.text('Add Item'), findsNothing);
    });

    testWidgets('renders extended FAB with label on desktop', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          size: const Size(1440, 900), // Desktop size
          child: ResponsiveFab(
            icon: Icons.add,
            label: 'Add Item',
            onPressed: () {},
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
        createTestApp(
          child: ResponsiveFab(
            icon: Icons.add,
            label: 'Add Item',
            onPressed: () => pressed = true,
          ),
        ),
      );

      // Tap the FAB
      await tester.tap(find.byType(CreateContentFab));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(pressed, isTrue);
    });

    testWidgets('onPressed callback works on desktop', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        createTestApp(
          size: const Size(1440, 900), // Desktop size
          child: ResponsiveFab(
            icon: Icons.add,
            label: 'Add Item',
            onPressed: () => pressed = true,
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
        createTestApp(
          child: ResponsiveFab(
            icon: Icons.edit,
            label: 'Edit',
            onPressed: () {},
          ),
        ),
      );

      // Verify custom icon is present
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('supports null onPressed (disabled state)', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const ResponsiveFab(icon: Icons.add, label: 'Add Item'),
        ),
      );

      // Verify FAB is rendered
      expect(find.byType(CreateContentFab), findsOneWidget);
    });

    testWidgets('uses tooltip when provided', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: ResponsiveFab(
            icon: Icons.add,
            label: 'Add Item',
            tooltip: 'Custom Tooltip',
            onPressed: () {},
          ),
        ),
      );

      // Verify FAB is rendered
      expect(find.byType(CreateContentFab), findsOneWidget);
    });

    testWidgets('uses label as tooltip when tooltip not provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          child: ResponsiveFab(
            icon: Icons.add,
            label: 'Add Item',
            onPressed: () {},
          ),
        ),
      );

      // Verify FAB is rendered
      expect(find.byType(CreateContentFab), findsOneWidget);
    });

    testWidgets('supports custom heroTag', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: ResponsiveFab(
            icon: Icons.add,
            label: 'Add Item',
            heroTag: 'custom-hero',
            onPressed: () {},
          ),
        ),
      );

      // Verify FAB is rendered
      expect(find.byType(CreateContentFab), findsOneWidget);
    });

    testWidgets('renders in light theme', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: ResponsiveFab(
            icon: Icons.add,
            label: 'Add Item',
            onPressed: () {},
          ),
        ),
      );

      // Verify FAB is rendered
      expect(find.byType(CreateContentFab), findsOneWidget);
    });

    testWidgets('renders in dark theme', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: ResponsiveFab(
            icon: Icons.add,
            label: 'Add Item',
            onPressed: () {},
          ),
        ),
      );

      // Verify FAB is rendered
      expect(find.byType(CreateContentFab), findsOneWidget);
    });

    testWidgets('adapts from mobile to desktop on resize', (tester) async {
      // Start with mobile size
      await tester.pumpWidget(
        createTestApp(
          child: ResponsiveFab(
            icon: Icons.add,
            label: 'Add Item',
            onPressed: () {},
          ),
        ),
      );

      // Verify mobile FAB
      expect(find.byType(CreateContentFab), findsOneWidget);

      // Resize to desktop
      await tester.pumpWidget(
        createTestApp(
          size: const Size(1440, 900), // Desktop size
          child: ResponsiveFab(
            icon: Icons.add,
            label: 'Add Item',
            onPressed: () {},
          ),
        ),
      );

      // Verify desktop FAB with label
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Add Item'), findsOneWidget);
    });

    testWidgets('does not pulse by default on mobile', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: ResponsiveFab(
            icon: Icons.add,
            label: 'Add Item',
            onPressed: () {},
          ),
        ),
      );

      final responsiveFab = tester.widget<ResponsiveFab>(
        find.byType(ResponsiveFab),
      );
      expect(responsiveFab.enablePulse, isFalse);
    });

    testWidgets('passes enablePulse to QuickCaptureFab on mobile', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          child: ResponsiveFab(
            icon: Icons.add,
            label: 'Add Item',
            onPressed: () {},
            enablePulse: true,
          ),
        ),
      );

      // Verify ResponsiveFab has pulse enabled
      final responsiveFab = tester.widget<ResponsiveFab>(
        find.byType(ResponsiveFab),
      );
      expect(responsiveFab.enablePulse, isTrue);

      // Verify CreateContentFab has pulse enabled
      final createContentFab = tester.widget<CreateContentFab>(
        find.byType(CreateContentFab),
      );
      expect(createContentFab.enablePulse, isTrue);
    });

    testWidgets('pulses on desktop when enablePulse is true', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          size: const Size(1440, 900), // Desktop size
          child: ResponsiveFab(
            icon: Icons.add,
            label: 'Add Item',
            onPressed: () {},
            enablePulse: true,
          ),
        ),
      );

      // Verify ResponsiveFab has pulse enabled
      final responsiveFab = tester.widget<ResponsiveFab>(
        find.byType(ResponsiveFab),
      );
      expect(responsiveFab.enablePulse, isTrue);

      // Pump frames to allow animation to start
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('stops pulsing on user interaction on mobile', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        createTestApp(
          child: ResponsiveFab(
            icon: Icons.add,
            label: 'Add Item',
            onPressed: () => pressed = true,
            enablePulse: true,
          ),
        ),
      );

      // Tap the FAB
      await tester.tap(find.byType(CreateContentFab));
      await tester.pump();

      // Verify callback was called
      expect(pressed, isTrue);
    });

    testWidgets('stops pulsing on user interaction on desktop', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        createTestApp(
          size: const Size(1440, 900), // Desktop size
          child: ResponsiveFab(
            icon: Icons.add,
            label: 'Add Item',
            onPressed: () => pressed = true,
            enablePulse: true,
          ),
        ),
      );

      // Tap the FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Verify callback was called
      expect(pressed, isTrue);
    });

    testWidgets('respects reduced motion on mobile', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          disableAnimations: true,
          child: ResponsiveFab(
            icon: Icons.add,
            label: 'Add Item',
            onPressed: () {},
            enablePulse: true,
          ),
        ),
      );

      // Verify FAB is rendered
      expect(find.byType(CreateContentFab), findsOneWidget);

      // Pump frames to allow animation to start
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('respects reduced motion on desktop', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          size: const Size(1440, 900), // Desktop size
          disableAnimations: true,
          child: ResponsiveFab(
            icon: Icons.add,
            label: 'Add Item',
            onPressed: () {},
            enablePulse: true,
          ),
        ),
      );

      // Verify FAB is rendered
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Pump frames to allow animation to start
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}
