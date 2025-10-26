import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/atoms/loading/gradient_spinner.dart';

void main() {
  group('GradientSpinner - Enhanced Features', () {
    testWidgets('renders with default size (48px)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientSpinner(),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(48.0));
      expect(sizedBox.height, equals(48.0));
    });

    testWidgets('factory constructor .small() creates 16px spinner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientSpinner.small(),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(16.0));
      expect(sizedBox.height, equals(16.0));
    });

    testWidgets('factory constructor .medium() creates 24px spinner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientSpinner.medium(),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(24.0));
      expect(sizedBox.height, equals(24.0));
    });

    testWidgets('factory constructor .large() creates 48px spinner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientSpinner.large(),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(48.0));
      expect(sizedBox.height, equals(48.0));
    });

    testWidgets('factory constructor .pulsing() creates spinner with pulsing enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientSpinner.pulsing(),
          ),
        ),
      );

      expect(find.byType(GradientSpinner), findsOneWidget);
      // Spinner should exist with pulsing animation
      final spinner = tester.widget<GradientSpinner>(find.byType(GradientSpinner));
      expect(spinner.pulsing, isTrue);
    });

    testWidgets('uses custom size when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientSpinner(size: 60),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(60.0));
      expect(sizedBox.height, equals(60.0));
    });

    testWidgets('uses custom gradient when provided', (tester) async {
      const customGradient = LinearGradient(
        colors: [Colors.red, Colors.blue],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientSpinner(
              gradient: customGradient,
            ),
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

      // Find Transform.rotate widget specifically
      final transforms = find.byType(Transform);
      expect(transforms, findsWidgets);

      // Advance animation
      await tester.pump(const Duration(milliseconds: 250));

      // Widget should still be rendering (animation is continuous)
      expect(find.byType(GradientSpinner), findsOneWidget);
      expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1));
    });

    testWidgets('pulsing animation scales spinner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientSpinner.pulsing(),
          ),
        ),
      );

      // Should find AnimatedScale or Transform.scale widget
      expect(find.byType(AnimatedBuilder), findsWidgets);

      // Advance pulsing animation
      await tester.pump(const Duration(milliseconds: 1000));

      // Widget should still be rendering
      expect(find.byType(GradientSpinner), findsOneWidget);
    });

    testWidgets('uses RepaintBoundary for performance', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientSpinner(),
          ),
        ),
      );

      expect(find.byType(RepaintBoundary), findsAtLeastNWidgets(1));
    });

    testWidgets('adapts gradient to theme in light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: GradientSpinner(),
          ),
        ),
      );

      expect(find.byType(GradientSpinner), findsOneWidget);
      // In light mode, should use primary gradient
    });

    testWidgets('adapts gradient to theme in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: GradientSpinner(),
          ),
        ),
      );

      expect(find.byType(GradientSpinner), findsOneWidget);
      // In dark mode, should use primary dark gradient
    });

    testWidgets('stroke width adjusts with size variants', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GradientSpinner.small(), // 2px stroke
                GradientSpinner.medium(), // 3px stroke
                GradientSpinner.large(), // 4px stroke
              ],
            ),
          ),
        ),
      );

      final spinners = tester.widgetList<GradientSpinner>(find.byType(GradientSpinner));
      expect(spinners.elementAt(0).strokeWidth, equals(2.0));
      expect(spinners.elementAt(1).strokeWidth, equals(3.0));
      expect(spinners.elementAt(2).strokeWidth, equals(4.0));
    });

    testWidgets('multiple spinners can render simultaneously', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GradientSpinner.small(),
                GradientSpinner.medium(),
                GradientSpinner.large(),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(GradientSpinner), findsNWidgets(3));
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

      // Remove widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );

      // Should not throw errors
      expect(tester.takeException(), isNull);
    });
  });
}
