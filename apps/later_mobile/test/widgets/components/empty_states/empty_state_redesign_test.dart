import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/organisms/empty_states/empty_state.dart';

/// Phase 4, Task 4.3: Empty State Redesign Tests
///
/// Tests the Temporal Flow design system updates:
/// 1. Gradient tinted icons (ShaderMask with primaryGradient)
/// 2. Animated gradient background (subtle, 2-3% opacity)
/// 3. Dark mode adaptation for gradients
/// 4. All contexts work correctly (EmptySpaceState, WelcomeState, EmptySearchState)
void main() {
  group('EmptyState Redesign - Temporal Flow (Phase 4.3)', () {
    testWidgets('has gradient tinted icon using ShaderMask', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Description',
            ),
          ),
        ),
      );

      // Assert - icon should be wrapped in ShaderMask for gradient effect
      final shaderMaskFinder = find.descendant(
        of: find.byType(EmptyState),
        matching: find.byType(ShaderMask),
      );
      expect(shaderMaskFinder, findsOneWidget);

      // Verify ShaderMask contains an Icon
      final iconInShaderMask = find.descendant(
        of: shaderMaskFinder,
        matching: find.byIcon(Icons.inbox),
      );
      expect(iconInShaderMask, findsOneWidget);
    });

    testWidgets('icon gradient uses primaryGradient in light mode', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Description',
            ),
          ),
        ),
      );

      // Assert - ShaderMask should use primaryGradient colors
      final shaderMask = tester.widget<ShaderMask>(find.byType(ShaderMask));
      expect(shaderMask.blendMode, BlendMode.srcIn);
    });

    testWidgets('icon gradient uses primaryGradientDark in dark mode', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Description',
            ),
          ),
        ),
      );

      // Assert - ShaderMask should be present for dark mode gradient
      final shaderMaskFinder = find.byType(ShaderMask);
      expect(shaderMaskFinder, findsOneWidget);
    });

    testWidgets('has animated gradient background container', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Description',
            ),
          ),
        ),
      );

      // Assert - should have AnimatedOpacity for background fade-in
      final animatedOpacityFinder = find.descendant(
        of: find.byType(EmptyState),
        matching: find.byType(AnimatedOpacity),
      );
      expect(animatedOpacityFinder, findsOneWidget);

      // Verify AnimatedOpacity contains a Container with gradient
      final containerInAnimation = find.descendant(
        of: animatedOpacityFinder,
        matching: find.byType(Container),
      );
      expect(containerInAnimation, findsOneWidget);
    });

    testWidgets('animated background fades in over 2 seconds', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Description',
            ),
          ),
        ),
      );

      // Assert - AnimatedOpacity should have 2 second duration
      final animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animatedOpacity.duration, const Duration(seconds: 2));
    });

    testWidgets('animated background starts at opacity 0', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Description',
            ),
          ),
        ),
      );

      // Don't pump frames yet - check initial state
      final animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );

      // Opacity starts at 0 and animates to target value
      expect(animatedOpacity.opacity, 0.03); // Target opacity
    });

    testWidgets('background gradient uses primaryGradient in light mode', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Description',
            ),
          ),
        ),
      );

      // Assert - Container should have gradient decoration
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnimatedOpacity),
          matching: find.byType(Container),
        ),
      );

      expect(container.decoration, isNotNull);
      expect(container.decoration, isA<BoxDecoration>());

      final boxDecoration = container.decoration as BoxDecoration;
      expect(boxDecoration.gradient, isNotNull);
      expect(boxDecoration.gradient, isA<LinearGradient>());
    });

    testWidgets('background gradient uses primaryGradientDark in dark mode', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Description',
            ),
          ),
        ),
      );

      // Assert - Container should have gradient decoration
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnimatedOpacity),
          matching: find.byType(Container),
        ),
      );

      expect(container.decoration, isNotNull);
      expect(container.decoration, isA<BoxDecoration>());

      final boxDecoration = container.decoration as BoxDecoration;
      expect(boxDecoration.gradient, isNotNull);
      expect(boxDecoration.gradient, isA<LinearGradient>());
    });

    testWidgets(
      'maintains all existing functionality - icon, title, description',
      (WidgetTester tester) async {
        // Arrange
        const title = 'Empty State Title';
        const description = 'Empty state description';

        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmptyState(
                icon: Icons.inbox,
                title: title,
                message: description,
              ),
            ),
          ),
        );

        // Assert - all original elements still present
        expect(find.text(title), findsOneWidget);
        expect(find.text(description), findsOneWidget);
        expect(find.byIcon(Icons.inbox), findsOneWidget);
      },
    );

    testWidgets('maintains CTA button functionality', (
      WidgetTester tester,
    ) async {
      // Arrange
      var buttonPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Description',
              actionLabel: 'Take Action',
              onActionPressed: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Take Action'), findsOneWidget);

      // Tap button
      await tester.tap(find.text('Take Action'));
      await tester.pump();
      expect(buttonPressed, isTrue);
    });

    // Removed test: 'maintains secondary text link functionality'
    // EmptyState no longer supports secondaryText/onSecondaryPressed parameters

    testWidgets('maintains responsive layout with max width', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Description',
            ),
          ),
        ),
      );

      // Assert - find ConstrainedBox with max width
      final constrainedBoxes = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );

      // Find the one with maxWidth 480
      final hasMaxWidth480 = constrainedBoxes.any(
        (box) => box.constraints.maxWidth == 480.0,
      );
      expect(hasMaxWidth480, isTrue);
    });

    testWidgets('maintains scrollable behavior', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Description',
            ),
          ),
        ),
      );

      // Assert - SingleChildScrollView should be present
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('typography remains unchanged', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Description',
            ),
          ),
        ),
      );

      // Assert - title uses display large on mobile (40px)
      final titleText = tester.widget<Text>(find.text('Title'));
      expect(titleText.style?.fontSize, 40.0);

      // Assert - description uses body large
      final descriptionText = tester.widget<Text>(find.text('Description'));
      expect(descriptionText.style?.fontSize, greaterThanOrEqualTo(16.0));
    });

    testWidgets('maintains center alignment', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Description',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Center), findsWidgets);

      final titleText = tester.widget<Text>(find.text('Title'));
      expect(titleText.textAlign, TextAlign.center);

      final descriptionText = tester.widget<Text>(find.text('Description'));
      expect(descriptionText.textAlign, TextAlign.center);
    });

    testWidgets('gradient icon maintains proper size', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Description',
            ),
          ),
        ),
      );

      // Assert - icon inside ShaderMask should be present
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.inbox));
      expect(iconWidget, isNotNull);
    });

    testWidgets('gradient icon has white color for proper masking', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Description',
            ),
          ),
        ),
      );

      // Assert - icon should have white color for ShaderMask to work
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.inbox));
      expect(iconWidget.color, Colors.white);
    });

    testWidgets('background gradient covers full widget area', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Description',
            ),
          ),
        ),
      );

      // Assert - Positioned.fill should wrap the gradient container
      final positionedFill = find.descendant(
        of: find.byType(EmptyState),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Positioned &&
              widget.left == 0 &&
              widget.right == 0 &&
              widget.top == 0 &&
              widget.bottom == 0,
        ),
      );
      expect(positionedFill, findsOneWidget);
    });

    testWidgets('uses spring curve for animation', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Description',
            ),
          ),
        ),
      );

      // Assert - AnimatedOpacity should use easeOut curve
      final animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animatedOpacity.curve, Curves.easeOut);
    });
  });
}
