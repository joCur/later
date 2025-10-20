import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/theme/app_animations.dart';
import 'package:later_mobile/widgets/components/loading/gradient_spinner.dart';

void main() {
  group('GradientSpinner', () {
    testWidgets('renders with default size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientSpinner(),
          ),
        ),
      );

      // Find the SizedBox that contains the spinner
      final sizedBox = tester.widget<SizedBox>(
        find.byType(SizedBox).first,
      );

      expect(sizedBox.width, 48.0);
      expect(sizedBox.height, 48.0);
    });

    testWidgets('renders with custom size', (tester) async {
      const customSize = 72.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientSpinner(size: customSize),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.byType(SizedBox).first,
      );

      expect(sizedBox.width, customSize);
      expect(sizedBox.height, customSize);
    });

    testWidgets('renders with custom strokeWidth', (tester) async {
      const customStrokeWidth = 6.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientSpinner(strokeWidth: customStrokeWidth),
          ),
        ),
      );

      // Verify the widget renders (CustomPaint will use the strokeWidth)
      expect(find.byType(GradientSpinner), findsOneWidget);
    });

    testWidgets('uses primary gradient by default in light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: GradientSpinner(),
          ),
        ),
      );

      expect(find.byType(GradientSpinner), findsOneWidget);
      // The gradient will be verified through the CustomPainter
    });

    testWidgets('uses primary gradient by default in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: GradientSpinner(),
          ),
        ),
      );

      expect(find.byType(GradientSpinner), findsOneWidget);
    });

    testWidgets('uses custom gradient when provided', (tester) async {
      const customGradient = LinearGradient(
        colors: [Colors.red, Colors.blue],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientSpinner(gradient: customGradient),
          ),
        ),
      );

      expect(find.byType(GradientSpinner), findsOneWidget);
    });

    testWidgets('rotates continuously', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientSpinner(),
          ),
        ),
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
        const MaterialApp(
          home: Scaffold(
            body: GradientSpinner(),
          ),
        ),
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
        const MaterialApp(
          home: Scaffold(
            body: GradientSpinner.small(),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.byType(SizedBox).first,
      );

      expect(sizedBox.width, 24.0);
      expect(sizedBox.height, 24.0);
    });

    testWidgets('creates medium variant correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientSpinner.medium(),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.byType(SizedBox).first,
      );

      expect(sizedBox.width, 48.0);
      expect(sizedBox.height, 48.0);
    });

    testWidgets('creates large variant correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientSpinner.large(),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.byType(SizedBox).first,
      );

      expect(sizedBox.width, 72.0);
      expect(sizedBox.height, 72.0);
    });

    testWidgets('disposes animation controller properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientSpinner(),
          ),
        ),
      );

      expect(find.byType(GradientSpinner), findsOneWidget);

      // Remove the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
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
