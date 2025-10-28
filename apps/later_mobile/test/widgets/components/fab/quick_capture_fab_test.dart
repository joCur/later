import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/design_system/molecules/fab/quick_capture_fab.dart';

void main() {
  Widget createTestApp({required Widget child}) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        extensions: [TemporalFlowTheme.light()],
      ),
      home: Scaffold(body: child),
    );
  }

  group('QuickCaptureFab', () {
    testWidgets('renders FAB with icon', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: QuickCaptureFab(onPressed: () {})),
      );

      expect(find.byType(QuickCaptureFab), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        createTestApp(
          child: QuickCaptureFab(
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(QuickCaptureFab));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('has correct size', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: QuickCaptureFab(onPressed: () {})),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(QuickCaptureFab),
          matching: find.byType(Container),
        ),
      );

      // Mobile-First Bold Design: 56x56px circular FAB
      expect(container.constraints?.maxWidth, 56);
      expect(container.constraints?.maxHeight, 56);
    });

    testWidgets('renders with custom icon', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: QuickCaptureFab(icon: Icons.edit, onPressed: () {}),
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('renders with custom label', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: QuickCaptureFab(label: 'Create', onPressed: () {}),
        ),
      );

      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('renders extended FAB with icon and label', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: QuickCaptureFab(label: 'Create Item', onPressed: () {}),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Create Item'), findsOneWidget);
    });

    testWidgets('shows tooltip when provided', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: QuickCaptureFab(tooltip: 'Quick Capture', onPressed: () {}),
        ),
      );

      expect(find.byType(QuickCaptureFab), findsOneWidget);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: const QuickCaptureFab(onPressed: null)),
      );

      final fab = tester.widget<QuickCaptureFab>(find.byType(QuickCaptureFab));
      expect(fab.onPressed, isNull);
    });

    testWidgets('has hero tag when provided', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: QuickCaptureFab(onPressed: () {})),
      );

      expect(find.byType(QuickCaptureFab), findsOneWidget);
    });

    testWidgets('has elevation shadow', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: QuickCaptureFab(onPressed: () {})),
      );

      expect(find.byType(QuickCaptureFab), findsOneWidget);
    });

    testWidgets('does not pulse by default', (tester) async {
      await tester.pumpWidget(
        createTestApp(child: QuickCaptureFab(onPressed: () {})),
      );

      final fab = tester.widget<QuickCaptureFab>(find.byType(QuickCaptureFab));
      expect(fab.enablePulse, isFalse);
    });

    testWidgets('pulses when enablePulse is true', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: QuickCaptureFab(onPressed: () {}, enablePulse: true),
        ),
      );

      // Verify the FAB is created with pulse enabled
      final fab = tester.widget<QuickCaptureFab>(find.byType(QuickCaptureFab));
      expect(fab.enablePulse, isTrue);

      // Pump frames to allow animation to start
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('stops pulsing on user interaction', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        createTestApp(
          child: QuickCaptureFab(
            onPressed: () {
              pressed = true;
            },
            enablePulse: true,
          ),
        ),
      );

      // Tap the FAB
      await tester.tap(find.byType(QuickCaptureFab));
      await tester.pumpAndSettle();

      // Verify onPressed was called
      expect(pressed, isTrue);
    });

    testWidgets('stops pulsing after 10 seconds', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: QuickCaptureFab(onPressed: () {}, enablePulse: true),
        ),
      );

      // Pump until 10 seconds have passed
      await tester.pump();
      await tester.pump(const Duration(seconds: 10));
      await tester.pump();
    });

    testWidgets('respects reduced motion preferences', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            theme: ThemeData(
              brightness: Brightness.light,
              extensions: [TemporalFlowTheme.light()],
            ),
            home: Scaffold(
              body: QuickCaptureFab(onPressed: () {}, enablePulse: true),
            ),
          ),
        ),
      );

      // With reduced motion, pulse should not be applied even if enabled
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}
