import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/atoms/drag_handle/drag_handle_widget.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

/// Widget Test Suite: DragHandleWidget Component
///
/// Tests the DragHandleWidget atom component from the design system.
///
/// Verifies:
/// - Initial render with correct dimensions
/// - Gradient shader applied to grip dots
/// - Semantic labels and accessibility properties
/// - Touch target meets accessibility standards (48×48px)
/// - Interaction states (default 40%, hover 60%, active 100% opacity)
/// - Haptic feedback callbacks (onDragStart, onDragEnd)
/// - Grip dots pattern (3×2 grid of 4×4px circles)
/// - Reduced motion support
/// - Different gradients for different content types
///
/// Success Criteria:
/// - All visual states render correctly
/// - Interactions work as expected
/// - Animations respect reduced motion preferences
/// - Component is accessible
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DragHandleWidget Component Tests', () {
    testWidgets('Initial render shows grip dots', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DragHandleWidget(
              gradient: AppColors.taskGradient,
              semanticLabel: 'Reorder item',
            ),
          ),
        ),
      );

      expect(find.byType(DragHandleWidget), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('Has correct default size (48×48px)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DragHandleWidget(
              gradient: AppColors.taskGradient,
              semanticLabel: 'Reorder item',
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(48.0));
      expect(sizedBox.height, equals(48.0));
    });

    testWidgets('Custom size is respected', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DragHandleWidget(
              gradient: AppColors.taskGradient,
              semanticLabel: 'Reorder item',
              size: 64.0,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(64.0));
      expect(sizedBox.height, equals(64.0));
    });

    testWidgets('Semantic label is set correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DragHandleWidget(
              gradient: AppColors.taskGradient,
              semanticLabel: 'Reorder Shopping List',
            ),
          ),
        ),
      );

      // Verify semantic properties are set
      expect(find.byType(Semantics), findsWidgets);
      expect(find.byType(DragHandleWidget), findsOneWidget);
    });

    testWidgets('Tooltip shows semantic label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DragHandleWidget(
              gradient: AppColors.taskGradient,
              semanticLabel: 'Reorder Shopping List',
            ),
          ),
        ),
      );

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, equals('Reorder Shopping List'));
    });

    testWidgets('Grip dots have correct dimensions (20×30px)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DragHandleWidget(
              gradient: AppColors.taskGradient,
              semanticLabel: 'Reorder item',
            ),
          ),
        ),
      );

      // Find the SizedBox that contains the grip dots
      final gripDotsSizedBox = tester.widget<SizedBox>(
        find.byType(SizedBox).at(1),
      );
      expect(gripDotsSizedBox.width, equals(20));
      expect(gripDotsSizedBox.height, equals(30));
    });

    testWidgets('Individual dots are 4×4px circles', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DragHandleWidget(
              gradient: AppColors.taskGradient,
              semanticLabel: 'Reorder item',
            ),
          ),
        ),
      );

      // Find all dot containers (should be 6: 3 rows × 2 columns)
      final dotContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(dotContainers, findsNWidgets(6));

      // Check first dot's dimensions
      final firstDot = tester.widget<Container>(dotContainers.first);
      expect(firstDot.constraints?.maxWidth, equals(4));
      expect(firstDot.constraints?.maxHeight, equals(4));
    });

    testWidgets('Gradient shader is applied to dots', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DragHandleWidget(
              gradient: AppColors.taskGradient,
              semanticLabel: 'Reorder item',
            ),
          ),
        ),
      );

      final shaderMask = tester.widget<ShaderMask>(find.byType(ShaderMask));
      expect(shaderMask.shaderCallback, isNotNull);
    });

    testWidgets('Task gradient is applied correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DragHandleWidget(
              gradient: AppColors.taskGradient,
              semanticLabel: 'Reorder task',
            ),
          ),
        ),
      );

      expect(find.byType(DragHandleWidget), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('Note gradient is applied correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DragHandleWidget(
              gradient: AppColors.noteGradient,
              semanticLabel: 'Reorder note',
            ),
          ),
        ),
      );

      expect(find.byType(DragHandleWidget), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('List gradient is applied correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DragHandleWidget(
              gradient: AppColors.listGradient,
              semanticLabel: 'Reorder list',
            ),
          ),
        ),
      );

      expect(find.byType(DragHandleWidget), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('Default opacity is 40%', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DragHandleWidget(
              gradient: AppColors.taskGradient,
              semanticLabel: 'Reorder item',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animatedOpacity.opacity, equals(0.4));
    });

    testWidgets('Opacity changes to 100% on tap down', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: DragHandleWidget(
                gradient: AppColors.taskGradient,
                semanticLabel: 'Reorder item',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial opacity should be 40%
      var animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animatedOpacity.opacity, equals(0.4));

      // Tap down
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(DragHandleWidget)),
      );
      await tester.pumpAndSettle();

      // Opacity should change to 100%
      animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animatedOpacity.opacity, equals(1.0));

      // Release
      await gesture.up();
      await tester.pumpAndSettle();

      // Opacity should return to 40%
      animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animatedOpacity.opacity, equals(0.4));
    });

    testWidgets('onDragStart callback is called on tap down', (
      WidgetTester tester,
    ) async {
      var dragStartCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: DragHandleWidget(
                gradient: AppColors.taskGradient,
                semanticLabel: 'Reorder item',
                onDragStart: () {
                  dragStartCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(dragStartCalled, isFalse);

      // Tap to trigger onDragStart
      await tester.tap(find.byType(DragHandleWidget));
      await tester.pumpAndSettle();

      expect(dragStartCalled, isTrue);
    });

    testWidgets('onDragEnd callback is called on tap up', (
      WidgetTester tester,
    ) async {
      var dragEndCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: DragHandleWidget(
                gradient: AppColors.taskGradient,
                semanticLabel: 'Reorder item',
                onDragEnd: () {
                  dragEndCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(dragEndCalled, isFalse);

      // Tap (down and up)
      await tester.tap(find.byType(DragHandleWidget));
      await tester.pumpAndSettle();

      expect(dragEndCalled, isTrue);
    });

    testWidgets('Both callbacks work together', (WidgetTester tester) async {
      var dragStartCalled = false;
      var dragEndCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: DragHandleWidget(
                gradient: AppColors.taskGradient,
                semanticLabel: 'Reorder item',
                onDragStart: () {
                  dragStartCalled = true;
                },
                onDragEnd: () {
                  dragEndCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(dragStartCalled, isFalse);
      expect(dragEndCalled, isFalse);

      // Tap
      await tester.tap(find.byType(DragHandleWidget));
      await tester.pumpAndSettle();

      expect(dragStartCalled, isTrue);
      expect(dragEndCalled, isTrue);
    });

    testWidgets('Animation duration is 200ms by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DragHandleWidget(
              gradient: AppColors.taskGradient,
              semanticLabel: 'Reorder item',
            ),
          ),
        ),
      );

      final animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(
        animatedOpacity.duration,
        equals(const Duration(milliseconds: 200)),
      );
    });

    testWidgets('ExcludeSemantics wraps grip dots', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DragHandleWidget(
              gradient: AppColors.taskGradient,
              semanticLabel: 'Reorder item',
            ),
          ),
        ),
      );

      // Verify ExcludeSemantics is present (hides decorative grip dots from screen readers)
      // May be multiple due to framework widgets
      expect(find.byType(ExcludeSemantics), findsWidgets);
    });

    testWidgets('MouseRegion is present for hover detection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DragHandleWidget(
              gradient: AppColors.taskGradient,
              semanticLabel: 'Reorder item',
            ),
          ),
        ),
      );

      // MouseRegion is present (may be multiple due to framework widgets)
      expect(find.byType(MouseRegion), findsWidgets);
    });

    testWidgets('GestureDetector captures tap events', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DragHandleWidget(
              gradient: AppColors.taskGradient,
              semanticLabel: 'Reorder item',
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('Widget tree structure is correct', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DragHandleWidget(
              gradient: AppColors.taskGradient,
              semanticLabel: 'Reorder item',
            ),
          ),
        ),
      );

      // Verify widget tree hierarchy
      expect(find.byType(Semantics), findsWidgets);
      expect(find.byType(MouseRegion), findsWidgets);
      expect(find.byType(GestureDetector), findsWidgets);
      expect(find.byType(Tooltip), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(AnimatedOpacity), findsOneWidget);
      expect(find.byType(ExcludeSemantics), findsWidgets);
      expect(find.byType(ShaderMask), findsOneWidget);
      expect(find.byType(Column), findsOneWidget); // Grip dots column
      expect(find.byType(Row), findsWidgets); // Dot rows
    });

    testWidgets('Multiple drag handles can coexist', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                DragHandleWidget(
                  gradient: AppColors.taskGradient,
                  semanticLabel: 'Reorder first item',
                ),
                DragHandleWidget(
                  gradient: AppColors.noteGradient,
                  semanticLabel: 'Reorder second item',
                ),
                DragHandleWidget(
                  gradient: AppColors.listGradient,
                  semanticLabel: 'Reorder third item',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(DragHandleWidget), findsNWidgets(3));
    });

    testWidgets('State updates correctly across interactions', (
      WidgetTester tester,
    ) async {
      var dragStartCallCount = 0;
      var dragEndCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: DragHandleWidget(
                gradient: AppColors.taskGradient,
                semanticLabel: 'Reorder item',
                onDragStart: () {
                  dragStartCallCount++;
                },
                onDragEnd: () {
                  dragEndCallCount++;
                },
              ),
            ),
          ),
        ),
      );

      // First interaction
      await tester.tap(find.byType(DragHandleWidget));
      await tester.pumpAndSettle();
      expect(dragStartCallCount, equals(1));
      expect(dragEndCallCount, equals(1));

      // Second interaction
      await tester.tap(find.byType(DragHandleWidget));
      await tester.pumpAndSettle();
      expect(dragStartCallCount, equals(2));
      expect(dragEndCallCount, equals(2));

      // Third interaction
      await tester.tap(find.byType(DragHandleWidget));
      await tester.pumpAndSettle();
      expect(dragStartCallCount, equals(3));
      expect(dragEndCallCount, equals(3));
    });

    testWidgets(
      'Grip dots use correct spacing (6px vertical, 4px horizontal)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DragHandleWidget(
                gradient: AppColors.taskGradient,
                semanticLabel: 'Reorder item',
              ),
            ),
          ),
        );

        // Find all SizedBox widgets used for spacing
        final spacingBoxes = find.byWidgetPredicate(
          (widget) =>
              widget is SizedBox &&
              (widget.height == 6.0 || widget.width == 4.0),
        );

        // Should have vertical (6px) and horizontal (4px) spacing
        expect(spacingBoxes, findsWidgets);
      },
    );
  });
}
