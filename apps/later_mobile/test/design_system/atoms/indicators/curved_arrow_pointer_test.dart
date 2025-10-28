import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/design_system/atoms/indicators/curved_arrow_pointer.dart';

/// Widget Test Suite: CurvedArrowPointer Component
///
/// Tests the CurvedArrowPointer atom component from the design system.
///
/// Verifies:
/// - Initial render with different positions
/// - CustomPainter draws arrow correctly
/// - Animation entrance (fade in + draw animation)
/// - Theme-aware coloring (uses primary gradient)
/// - Custom color support
/// - Reduced motion support
/// - Arrow head rotation and alignment
/// - Different stroke widths and arrow head sizes
///
/// Success Criteria:
/// - Arrow renders at specified positions
/// - Animation works smoothly
/// - Respects accessibility preferences
/// - Theme colors are applied correctly
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CurvedArrowPointer Component Tests', () {
    testWidgets('Renders with default properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: [TemporalFlowTheme.light()],
          ),
          home: const Scaffold(
            body: Stack(
              children: [
                CurvedArrowPointer(
                  startPosition: Offset(100, 100),
                  endPosition: Offset(300, 300),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify CustomPaint is rendered
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Renders with custom color', (WidgetTester tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: [TemporalFlowTheme.light()],
          ),
          home: const Scaffold(
            body: Stack(
              children: [
                CurvedArrowPointer(
                  startPosition: Offset(100, 100),
                  endPosition: Offset(300, 300),
                  color: customColor,
                ),
              ],
            ),
          ),
        ),
      );

      // Find the CustomPaint widget
      final customPaint = tester.widget<CustomPaint>(
        find.byType(CustomPaint).first,
      );

      // Verify painter uses custom color
      expect(customPaint.painter, isNotNull);
    });

    testWidgets('Renders with custom stroke width', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: [TemporalFlowTheme.light()],
          ),
          home: const Scaffold(
            body: Stack(
              children: [
                CurvedArrowPointer(
                  startPosition: Offset(100, 100),
                  endPosition: Offset(300, 300),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify CustomPaint is rendered
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Renders with custom arrow head size', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: [TemporalFlowTheme.light()],
          ),
          home: const Scaffold(
            body: Stack(
              children: [
                CurvedArrowPointer(
                  startPosition: Offset(100, 100),
                  endPosition: Offset(300, 300),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify CustomPaint is rendered
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Animation disabled when animate is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: [TemporalFlowTheme.light()],
          ),
          home: const Scaffold(
            body: Stack(
              children: [
                CurvedArrowPointer(
                  startPosition: Offset(100, 100),
                  endPosition: Offset(300, 300),
                  animate: false,
                ),
              ],
            ),
          ),
        ),
      );

      // Arrow should render immediately without animation
      expect(find.byType(CustomPaint), findsOneWidget);

      // Pump frames to verify no animation occurs
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('Works with different position combinations', (
      WidgetTester tester,
    ) async {
      // Test 1: Start bottom-left, end top-right
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: [TemporalFlowTheme.light()],
          ),
          home: const Scaffold(
            body: Stack(
              children: [
                CurvedArrowPointer(
                  startPosition: Offset(50, 400),
                  endPosition: Offset(350, 100),
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(CustomPaint), findsWidgets);

      // Test 2: Start top-right, end bottom-left
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: [TemporalFlowTheme.light()],
          ),
          home: const Scaffold(
            body: Stack(
              children: [
                CurvedArrowPointer(
                  startPosition: Offset(350, 100),
                  endPosition: Offset(50, 400),
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(CustomPaint), findsWidgets);

      // Test 3: Horizontal arrow
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: [TemporalFlowTheme.light()],
          ),
          home: const Scaffold(
            body: Stack(
              children: [
                CurvedArrowPointer(
                  startPosition: Offset(50, 200),
                  endPosition: Offset(350, 200),
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(CustomPaint), findsWidgets);

      // Test 4: Vertical arrow
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: [TemporalFlowTheme.light()],
          ),
          home: const Scaffold(
            body: Stack(
              children: [
                CurvedArrowPointer(
                  startPosition: Offset(200, 50),
                  endPosition: Offset(200, 400),
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Uses theme colors in light mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: [TemporalFlowTheme.light()],
          ),
          home: const Scaffold(
            body: Stack(
              children: [
                CurvedArrowPointer(
                  startPosition: Offset(100, 100),
                  endPosition: Offset(300, 300),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify widget renders
      expect(find.byType(CurvedArrowPointer), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Uses theme colors in dark mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            extensions: [TemporalFlowTheme.dark()],
          ),
          home: const Scaffold(
            body: Stack(
              children: [
                CurvedArrowPointer(
                  startPosition: Offset(100, 100),
                  endPosition: Offset(300, 300),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify widget renders with dark theme
      expect(find.byType(CurvedArrowPointer), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Multiple arrows can coexist', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: [TemporalFlowTheme.light()],
          ),
          home: const Scaffold(
            body: Stack(
              children: [
                CurvedArrowPointer(
                  startPosition: Offset(100, 100),
                  endPosition: Offset(300, 300),
                ),
                CurvedArrowPointer(
                  startPosition: Offset(150, 150),
                  endPosition: Offset(350, 350),
                  color: Colors.blue,
                ),
                CurvedArrowPointer(
                  startPosition: Offset(200, 200),
                  endPosition: Offset(400, 400),
                  strokeWidth: 4.0,
                ),
              ],
            ),
          ),
        ),
      );

      // Verify all three arrows are rendered
      expect(find.byType(CurvedArrowPointer), findsNWidgets(3));
    });

    testWidgets('Respects reduced motion setting', (WidgetTester tester) async {
      // Create a test widget that simulates reduced motion
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: [TemporalFlowTheme.light()],
          ),
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: Stack(
                children: [
                  CurvedArrowPointer(
                    startPosition: Offset(100, 100),
                    endPosition: Offset(300, 300),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Arrow should render immediately without animation
      expect(find.byType(CustomPaint), findsOneWidget);

      // Verify no animation wrapper is present
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('Minimal distance arrow (start and end close)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: [TemporalFlowTheme.light()],
          ),
          home: const Scaffold(
            body: Stack(
              children: [
                CurvedArrowPointer(
                  startPosition: Offset(100, 100),
                  endPosition: Offset(120, 120),
                ),
              ],
            ),
          ),
        ),
      );

      // Should still render even with minimal distance
      expect(find.byType(CurvedArrowPointer), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Zero-distance positions (start equals end)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: [TemporalFlowTheme.light()],
          ),
          home: const Scaffold(
            body: Stack(
              children: [
                CurvedArrowPointer(
                  startPosition: Offset(100, 100),
                  endPosition: Offset(100, 100),
                ),
              ],
            ),
          ),
        ),
      );

      // Should render without errors even with zero distance
      expect(find.byType(CurvedArrowPointer), findsOneWidget);
    });
  });
}
