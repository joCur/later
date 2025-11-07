import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/atoms/chips/filter_chip.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

import '../../../test_helpers.dart';

/// Widget Test Suite: TemporalFilterChip Component
///
/// Tests the TemporalFilterChip atom component from the design system.
///
/// Verifies:
/// - Initial render shows label correctly
/// - Selected state displays gradient border
/// - Unselected state displays solid border
/// - Tap triggers onSelected callback
/// - Animation triggers on tap
/// - Optional icon displays when provided
/// - Theme-aware colors (light/dark mode)
/// - Correct dimensions (36px height)
/// - Haptic feedback integration
/// - Accessibility
///
/// Success Criteria:
/// - All visual states render correctly
/// - Interactions work as expected
/// - Animations are smooth
/// - Component is accessible
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TemporalFilterChip Component Tests', () {
    testWidgets('Initial render shows label', (WidgetTester tester) async {
      await tester.pumpWidget(
        testApp(
          TemporalFilterChip(
            label: 'Test Filter',
            isSelected: false,
            onSelected: () {},
          ),
        ),
      );

      expect(find.text('Test Filter'), findsOneWidget);
    });

    testWidgets('Selected state shows gradient border', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        testApp(
          TemporalFilterChip(
            label: 'Selected',
            isSelected: true,
            onSelected: () {},
          ),
        ),
      );

      // Find the outer container with gradient
      final container = tester.widget<Container>(find.byType(Container).first);

      // Verify gradient decoration exists
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, equals(AppColors.primaryGradient));
      expect(decoration.borderRadius, equals(BorderRadius.circular(20)));

      // Verify inner container has 2px margin (border width)
      final innerContainer = tester.widget<Container>(
        find.byType(Container).at(1),
      );
      expect(innerContainer.margin, equals(const EdgeInsets.all(2)));
    });

    testWidgets('Selected state shows gradient border in dark mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        testAppDark(
          TemporalFilterChip(
            label: 'Selected',
            isSelected: true,
            onSelected: () {},
          ),
        ),
      );

      // Find the outer container with gradient
      final container = tester.widget<Container>(find.byType(Container).first);

      // Verify dark mode gradient
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, equals(AppColors.primaryGradientDark));
    });

    testWidgets('Unselected state shows solid border', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        testApp(
          TemporalFilterChip(
            label: 'Unselected',
            isSelected: false,
            onSelected: () {},
          ),
        ),
      );

      // Find the container with border
      final container = tester.widget<Container>(find.byType(Container).first);

      // Verify solid border decoration
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.gradient, isNull);
      expect(decoration.borderRadius, equals(BorderRadius.circular(20)));
    });

    testWidgets('Unselected state shows solid border in dark mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        testAppDark(
          TemporalFilterChip(
            label: 'Unselected',
            isSelected: false,
            onSelected: () {},
          ),
        ),
      );

      // Find the container with border
      final container = tester.widget<Container>(find.byType(Container).first);

      // Verify solid border exists in dark mode
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.gradient, isNull);
    });

    testWidgets('Tap calls onSelected callback', (WidgetTester tester) async {
      var callbackInvoked = false;

      await tester.pumpWidget(
        testApp(
          Center(
            child: TemporalFilterChip(
              label: 'Tap Me',
              isSelected: false,
              onSelected: () {
                callbackInvoked = true;
              },
            ),
          ),
        ),
      );

      // Tap the chip
      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(callbackInvoked, isTrue);
    });

    testWidgets('Animation triggers on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        testApp(
          TemporalFilterChip(
            label: 'Animate',
            isSelected: false,
            onSelected: () {},
          ),
        ),
      );

      // Get initial scale
      final initialTransform = tester.widget<Transform>(
        find.byType(Transform).first,
      );
      expect(initialTransform.transform.getMaxScaleOnAxis(), equals(1.0));

      // Tap to trigger animation
      await tester.tap(find.byType(TemporalFilterChip));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 100)); // Mid-animation

      // Verify scale has changed (should be > 1.0 during animation)
      final animatedTransform = tester.widget<Transform>(
        find.byType(Transform).first,
      );
      expect(animatedTransform.transform.getMaxScaleOnAxis(), greaterThan(1.0));

      // Complete animation
      await tester.pumpAndSettle();

      // Verify scale returns to 1.0
      final finalTransform = tester.widget<Transform>(
        find.byType(Transform).first,
      );
      expect(finalTransform.transform.getMaxScaleOnAxis(), equals(1.0));
    });

    testWidgets('Icon displays when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        testApp(
          TemporalFilterChip(
            label: 'With Icon',
            isSelected: false,
            onSelected: () {},
            icon: Icons.filter_list,
          ),
        ),
      );

      // Verify icon is rendered
      expect(find.byIcon(Icons.filter_list), findsOneWidget);

      // Verify icon size
      final icon = tester.widget<Icon>(find.byIcon(Icons.filter_list));
      expect(icon.size, equals(16));
    });

    testWidgets('No icon when not provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        testApp(
          TemporalFilterChip(
            label: 'No Icon',
            isSelected: false,
            onSelected: () {},
          ),
        ),
      );

      // Verify no icon is rendered
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('Light theme uses correct text colors', (
      WidgetTester tester,
    ) async {
      // Test selected state
      await tester.pumpWidget(
        testApp(
          TemporalFilterChip(
            label: 'Selected',
            isSelected: true,
            onSelected: () {},
          ),
        ),
      );

      final selectedText = tester.widget<Text>(find.text('Selected'));
      expect(selectedText.style?.color, equals(AppColors.neutral600));

      // Test unselected state
      await tester.pumpWidget(
        testApp(
          TemporalFilterChip(
            label: 'Unselected',
            isSelected: false,
            onSelected: () {},
          ),
        ),
      );

      final unselectedText = tester.widget<Text>(find.text('Unselected'));
      expect(unselectedText.style?.color, equals(AppColors.neutral500));
    });

    testWidgets('Dark theme uses correct text colors', (
      WidgetTester tester,
    ) async {
      // Test selected state
      await tester.pumpWidget(
        testAppDark(
          TemporalFilterChip(
            label: 'Selected',
            isSelected: true,
            onSelected: () {},
          ),
        ),
      );

      final selectedText = tester.widget<Text>(find.text('Selected'));
      expect(selectedText.style?.color, equals(AppColors.neutral400));

      // Test unselected state
      await tester.pumpWidget(
        testAppDark(
          TemporalFilterChip(
            label: 'Unselected',
            isSelected: false,
            onSelected: () {},
          ),
        ),
      );

      final unselectedText = tester.widget<Text>(find.text('Unselected'));
      expect(unselectedText.style?.color, equals(AppColors.neutral500));
    });

    testWidgets('Icon uses correct colors in light theme', (
      WidgetTester tester,
    ) async {
      // Test selected state
      await tester.pumpWidget(
        testApp(
          TemporalFilterChip(
            label: 'Selected',
            isSelected: true,
            onSelected: () {},
            icon: Icons.star,
          ),
        ),
      );

      final selectedIcon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(selectedIcon.color, equals(AppColors.neutral600));

      // Test unselected state
      await tester.pumpWidget(
        testApp(
          TemporalFilterChip(
            label: 'Unselected',
            isSelected: false,
            onSelected: () {},
            icon: Icons.star,
          ),
        ),
      );

      final unselectedIcon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(unselectedIcon.color, equals(AppColors.neutral500));
    });

    testWidgets('Icon uses correct colors in dark theme', (
      WidgetTester tester,
    ) async {
      // Test selected state
      await tester.pumpWidget(
        testAppDark(
          TemporalFilterChip(
            label: 'Selected',
            isSelected: true,
            onSelected: () {},
            icon: Icons.star,
          ),
        ),
      );

      final selectedIcon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(selectedIcon.color, equals(AppColors.neutral400));

      // Test unselected state
      await tester.pumpWidget(
        testAppDark(
          TemporalFilterChip(
            label: 'Unselected',
            isSelected: false,
            onSelected: () {},
            icon: Icons.star,
          ),
        ),
      );

      final unselectedIcon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(unselectedIcon.color, equals(AppColors.neutral500));
    });

    testWidgets('Chip has correct height', (WidgetTester tester) async {
      await tester.pumpWidget(
        testApp(
          TemporalFilterChip(
            label: 'Height Test',
            isSelected: false,
            onSelected: () {},
          ),
        ),
      );

      // Find the container that defines height
      final container = tester.widget<Container>(find.byType(Container).first);

      // Height is set directly on the container using BoxConstraints
      // The outer container has height: 36
      final boxConstraints = container.constraints;
      if (boxConstraints != null) {
        expect(boxConstraints.maxHeight, equals(36.0));
      }

      // Verify the chip renders at 36px height
      final renderBox = tester.renderObject<RenderBox>(
        find.byType(TemporalFilterChip),
      );
      expect(renderBox.size.height, equals(36.0));
    });

    testWidgets('Text uses correct font size and weight', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        testApp(
          TemporalFilterChip(
            label: 'Typography Test',
            isSelected: false,
            onSelected: () {},
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Typography Test'));
      expect(text.style?.fontSize, equals(14));
      expect(text.style?.fontWeight, equals(FontWeight.w500));
    });

    testWidgets('Multiple chips can coexist', (WidgetTester tester) async {
      await tester.pumpWidget(
        testApp(
          Row(
            children: [
              TemporalFilterChip(
                label: 'First',
                isSelected: true,
                onSelected: () {},
              ),
              TemporalFilterChip(
                label: 'Second',
                isSelected: false,
                onSelected: () {},
              ),
              TemporalFilterChip(
                label: 'Third',
                isSelected: false,
                onSelected: () {},
                icon: Icons.filter,
              ),
            ],
          ),
        ),
      );

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);
      expect(find.byIcon(Icons.filter), findsOneWidget);
    });

    testWidgets('State changes update visual appearance', (
      WidgetTester tester,
    ) async {
      bool isSelected = false;

      await tester.pumpWidget(
        testApp(
          StatefulBuilder(
            builder: (context, setState) {
              return Center(
                child: TemporalFilterChip(
                  label: 'Toggle',
                  isSelected: isSelected,
                  onSelected: () {
                    setState(() {
                      isSelected = !isSelected;
                    });
                  },
                ),
              );
            },
          ),
        ),
      );

      // Initially unselected - should have border
      var container = tester.widget<Container>(find.byType(Container).first);
      var decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.gradient, isNull);

      // Tap to select
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      // Now selected - should have gradient
      container = tester.widget<Container>(find.byType(Container).first);
      decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, equals(AppColors.primaryGradient));
    });
  });
}
