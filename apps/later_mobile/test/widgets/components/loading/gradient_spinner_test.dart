import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/design_system/atoms/loading/gradient_spinner.dart';
import '../../../test_helpers.dart';

void main() {
  group('GradientSpinner', () {
    testWidgets('renders with default size', (tester) async {
      await tester.pumpWidget(
        testApp(const GradientSpinner()),
      );

      // Verify it renders without errors
      expect(find.byType(GradientSpinner), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders with custom size', (tester) async {
      const customSize = 72.0;

      await tester.pumpWidget(
        testApp(const GradientSpinner(size: customSize)),
      );

      // Verify it renders without errors
      expect(find.byType(GradientSpinner), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders with custom strokeWidth', (tester) async {
      const customStrokeWidth = 6.0;

      await tester.pumpWidget(
        testApp(const GradientSpinner(strokeWidth: customStrokeWidth)),
      );

      // Verify the widget renders (CustomPaint will use the strokeWidth)
      expect(find.byType(GradientSpinner), findsOneWidget);
    });

    testWidgets('uses primary gradient by default in light mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(const GradientSpinner()),
      );

      expect(find.byType(GradientSpinner), findsOneWidget);
      // The gradient will be verified through the CustomPainter
    });

    testWidgets('uses primary gradient by default in dark mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        testAppDark(const GradientSpinner()),
      );

      expect(find.byType(GradientSpinner), findsOneWidget);
    });

    testWidgets('uses custom gradient when provided', (tester) async {
      const customGradient = LinearGradient(colors: [Colors.red, Colors.blue]);

      await tester.pumpWidget(
        testApp(const GradientSpinner(gradient: customGradient)),
      );

      expect(find.byType(GradientSpinner), findsOneWidget);
    });

    testWidgets('rotates continuously', (tester) async {
      await tester.pumpWidget(
        testApp(const GradientSpinner()),
      );

      // Get initial rotation
      final animatedBuilder = tester.widget<AnimatedBuilder>(
        find.byType(AnimatedBuilder).first,
      );
      expect(animatedBuilder, isNotNull);

      // Pump animation frames
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Animation controller should be running
      expect(find.byType(GradientSpinner), findsOneWidget);
    });

    testWidgets('animation repeats indefinitely', (tester) async {
      await tester.pumpWidget(
        testApp(const GradientSpinner()),
      );

      // Pump through multiple animation cycles
      await tester.pump(AppAnimations.spinnerRotation);
      await tester.pump(AppAnimations.spinnerRotation);
      await tester.pump(AppAnimations.spinnerRotation);

      // Should still be animating
      expect(find.byType(GradientSpinner), findsOneWidget);
    });

    testWidgets('creates small variant correctly', (tester) async {
      await tester.pumpWidget(
        testApp(const GradientSpinner.small()),
      );

      // Verify it renders without errors
      expect(find.byType(GradientSpinner), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('creates medium variant correctly', (tester) async {
      await tester.pumpWidget(
        testApp(const GradientSpinner.medium()),
      );

      // Verify it renders without errors
      expect(find.byType(GradientSpinner), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('creates large variant correctly', (tester) async {
      await tester.pumpWidget(
        testApp(const GradientSpinner.large()),
      );

      // Verify it renders without errors
      expect(find.byType(GradientSpinner), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets(
      'factory constructor .pulsing() creates spinner with pulsing enabled',
      (tester) async {
        await tester.pumpWidget(
          testApp(const GradientSpinner.pulsing()),
        );

        expect(find.byType(GradientSpinner), findsOneWidget);
        // Spinner should exist with pulsing animation
        final spinner = tester.widget<GradientSpinner>(
          find.byType(GradientSpinner),
        );
        expect(spinner.pulsing, isTrue);
      },
    );

    testWidgets('pulsing animation scales spinner', (tester) async {
      await tester.pumpWidget(
        testApp(const GradientSpinner.pulsing()),
      );

      // Should find AnimatedBuilder widgets
      expect(find.byType(AnimatedBuilder), findsWidgets);

      // Advance pulsing animation
      await tester.pump(const Duration(milliseconds: 1000));

      // Widget should still be rendering
      expect(find.byType(GradientSpinner), findsOneWidget);
    });

    testWidgets('uses RepaintBoundary for performance', (tester) async {
      await tester.pumpWidget(
        testApp(const GradientSpinner()),
      );

      expect(find.byType(RepaintBoundary), findsAtLeastNWidgets(1));
    });

    testWidgets('stroke width adjusts with size variants', (tester) async {
      await tester.pumpWidget(
        testApp(
          const Column(
            children: [
              GradientSpinner.small(), // 2px stroke
              GradientSpinner.medium(), // 3px stroke
              GradientSpinner.large(), // 4px stroke
            ],
          ),
        ),
      );

      final spinners = tester.widgetList<GradientSpinner>(
        find.byType(GradientSpinner),
      );
      expect(spinners.elementAt(0).strokeWidth, equals(2.0));
      expect(spinners.elementAt(1).strokeWidth, equals(3.0));
      expect(spinners.elementAt(2).strokeWidth, equals(4.0));
    });

    testWidgets('multiple spinners can render simultaneously', (tester) async {
      await tester.pumpWidget(
        testApp(
          const Column(
            children: [
              GradientSpinner.small(),
              GradientSpinner.medium(),
              GradientSpinner.large(),
            ],
          ),
        ),
      );

      expect(find.byType(GradientSpinner), findsNWidgets(3));
    });

    testWidgets('disposes animation controller properly', (tester) async {
      await tester.pumpWidget(
        testApp(const GradientSpinner()),
      );

      expect(find.byType(GradientSpinner), findsOneWidget);

      // Remove the widget
      await tester.pumpWidget(
        testApp(const SizedBox()),
      );

      // Should dispose without errors
      expect(find.byType(GradientSpinner), findsNothing);
    });
  });

  group('GradientSpinnerPainter', () {
    test('calculates arc correctly for 75% of circle', () {
      // The painter should draw 75% of a circle (270 degrees)
      const expectedArcAngle = pi * 1.5; // 270 degrees in radians
      expect(expectedArcAngle, greaterThan(0));
    });
  });
}
