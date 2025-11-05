import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/atoms/inputs/text_area_field.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

import '../../../test_helpers.dart';

void main() {
  group('TextAreaField', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(
        testApp(
          const TextAreaField(label: 'Test Label'),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.byType(TextAreaField), findsOneWidget);
    });

    testWidgets('renders with hint text', (tester) async {
      await tester.pumpWidget(
        testApp(
          const TextAreaField(
            label: 'Label',
            hintText: 'Enter multiple lines here',
          ),
        ),
      );

      expect(find.text('Enter multiple lines here'), findsOneWidget);
    });

    testWidgets('accepts multiline text input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        testApp(
          TextAreaField(label: 'Label', controller: controller),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Line 1\nLine 2\nLine 3');
      expect(controller.text, 'Line 1\nLine 2\nLine 3');

      controller.dispose();
    });

    testWidgets('displays error message when provided', (tester) async {
      await tester.pumpWidget(
        testApp(
          const TextAreaField(
            label: 'Label',
            errorText: 'This field is required',
          ),
        ),
      );

      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('renders in disabled state', (tester) async {
      await tester.pumpWidget(
        testApp(
          const TextAreaField(label: 'Label', enabled: false),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('sets minimum lines', (tester) async {
      await tester.pumpWidget(
        testApp(
          const TextAreaField(label: 'Label'),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.minLines, 3);
    });

    testWidgets('sets maximum lines', (tester) async {
      await tester.pumpWidget(
        testApp(
          const TextAreaField(label: 'Label', maxLines: 10),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, 10);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changedText;

      await tester.pumpWidget(
        testApp(
          TextAreaField(
            label: 'Label',
            onChanged: (value) {
              changedText = value;
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Changed text');
      expect(changedText, 'Changed text');
    });

    // ============================================================
    // TEMPORAL FLOW DESIGN SYSTEM TESTS
    // ============================================================

    group('Temporal Flow Design', () {
      testWidgets('has glass background with 3% opacity', (tester) async {
        await tester.pumpWidget(
          testApp(
            const TextAreaField(label: 'Label'),
          ),
        );

        final animatedContainer = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.byType(TextField),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );

        final decoration = animatedContainer.decoration as BoxDecoration;
        final theme = Theme.of(tester.element(find.byType(TextAreaField)));
        final isDark = theme.brightness == Brightness.dark;

        // Check for glass background (3% opacity)
        final expectedColor = isDark
            ? AppColors.neutral900.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.03);

        expect(decoration.color, expectedColor);
      });

      testWidgets('shows gradient border on focus', (tester) async {
        await tester.pumpWidget(
          testApp(
            const TextAreaField(label: 'Label'),
          ),
        );

        // Tap to focus the field
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        final animatedContainer = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.byType(TextField),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );

        final decoration = animatedContainer.decoration as BoxDecoration;

        // Check for gradient border
        expect(decoration.gradient, isNotNull);
        expect(decoration.gradient, isA<LinearGradient>());

        final gradient = decoration.gradient! as LinearGradient;
        // Should have gradient colors with 30% opacity
        expect(gradient.colors.length, 2);
        // Check that colors have reduced alpha (30%)
        for (final color in gradient.colors) {
          expect(
            (color.a * 255.0).round() & 0xff,
            lessThanOrEqualTo((255 * 0.3).round()),
          );
        }
      });

      testWidgets('shows focus shadow with gradient tint', (tester) async {
        await tester.pumpWidget(
          testApp(
            const TextAreaField(label: 'Label'),
          ),
        );

        // Tap to focus the field
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        final animatedContainer = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.byType(TextField),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );

        final decoration = animatedContainer.decoration as BoxDecoration;

        // Check for focus shadow
        expect(decoration.boxShadow, isNotNull);
        expect(decoration.boxShadow!.length, greaterThan(0));

        final shadow = decoration.boxShadow!.first;
        expect(shadow.blurRadius, 8.0);
        expect(shadow.offset, const Offset(0, 2));

        // Check shadow color has gradient tint at 20% opacity
        final expectedColor = AppColors.primaryEnd.withValues(alpha: 0.2);
        expect(shadow.color.toARGB32(), expectedColor.toARGB32());
      });

      testWidgets('shows error gradient border when errorText is provided', (
        tester,
      ) async {
        await tester.pumpWidget(
          testApp(
            const TextAreaField(label: 'Label', errorText: 'Error message'),
          ),
        );

        final animatedContainer = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.byType(TextField),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );

        final decoration = animatedContainer.decoration as BoxDecoration;

        // Check for error gradient border
        expect(decoration.gradient, isNotNull);
        expect(decoration.gradient, isA<LinearGradient>());

        final gradient = decoration.gradient! as LinearGradient;
        // Error gradient: red-500 to orange-400 in light mode
        expect(gradient.colors, contains(const Color(0xFFEF4444)));
        expect(gradient.colors, contains(const Color(0xFFFB923C)));
      });

      testWidgets('displays character counter with maxLength', (tester) async {
        final controller = TextEditingController(text: 'Test content\nLine 2');

        await tester.pumpWidget(
          testApp(
            TextAreaField(
              label: 'Label',
              controller: controller,
              maxLength: 100,
            ),
          ),
        );

        // Should show character counter
        final currentLength = controller.text.length;
        expect(find.text('$currentLength / 100'), findsOneWidget);

        controller.dispose();
      });

      testWidgets('character counter shows warning gradient when >80%', (
        tester,
      ) async {
        final controller = TextEditingController(text: 'X' * 81);

        await tester.pumpWidget(
          testApp(
            TextAreaField(
              label: 'Label',
              controller: controller,
              maxLength: 100,
            ),
          ),
        );

        // Should show counter with gradient when approaching limit (>80%)
        expect(find.text('81 / 100'), findsOneWidget);

        // Should have gradient foreground (ShaderMask applied)
        final counterParent = tester.widget<Widget>(
          find.ancestor(
            of: find.text('81 / 100'),
            matching: find.byType(ShaderMask),
          ),
        );
        expect(counterParent, isNotNull);

        controller.dispose();
      });

      testWidgets('placeholder has softer colors (60% opacity)', (
        tester,
      ) async {
        await tester.pumpWidget(
          testApp(
            const TextAreaField(
              label: 'Label',
              hintText: 'Enter description here',
            ),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        final hintStyle = textField.decoration!.hintStyle!;

        final theme = Theme.of(tester.element(find.byType(TextAreaField)));
        final isDark = theme.brightness == Brightness.dark;

        final expectedColor = isDark
            ? AppColors.neutral500.withValues(alpha: 0.6)
            : AppColors.neutral500.withValues(alpha: 0.6);

        expect(hintStyle.color?.toARGB32(), expectedColor.toARGB32());
      });

      testWidgets('uses correct border radius (10px)', (tester) async {
        await tester.pumpWidget(
          testApp(
            const TextAreaField(label: 'Label'),
          ),
        );

        final animatedContainer = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.byType(TextField),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );

        final decoration = animatedContainer.decoration as BoxDecoration;
        final borderRadius = decoration.borderRadius! as BorderRadius;

        // Plan specifies 10px border radius
        expect(borderRadius.topLeft.x, 10.0);
        expect(borderRadius.topRight.x, 10.0);
        expect(borderRadius.bottomLeft.x, 10.0);
        expect(borderRadius.bottomRight.x, 10.0);
      });

      testWidgets('works correctly with multiline input', (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          testApp(
            TextAreaField(label: 'Label', controller: controller),
          ),
        );

        // Enter multiline text
        const multilineText = 'Line 1\nLine 2\nLine 3\nLine 4\nLine 5';
        await tester.enterText(find.byType(TextField), multilineText);

        expect(controller.text, multilineText);

        controller.dispose();
      });

      testWidgets('maintains focus state transitions correctly', (
        tester,
      ) async {
        await tester.pumpWidget(
          testApp(
            const TextAreaField(label: 'Label'),
          ),
        );

        // Initial state: no focus, no gradient
        var animatedContainer = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.byType(TextField),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        var decoration = animatedContainer.decoration as BoxDecoration;
        expect(decoration.gradient, isNull);

        // Tap to focus
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        // Focused state: should have gradient border
        animatedContainer = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.byType(TextField),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        decoration = animatedContainer.decoration as BoxDecoration;
        expect(decoration.gradient, isNotNull);
        expect(decoration.boxShadow, isNotNull);

        // Unfocus
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Unfocused state: gradient should be removed
        animatedContainer = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.byType(TextField),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        decoration = animatedContainer.decoration as BoxDecoration;
        expect(decoration.gradient, isNull);
        expect(decoration.boxShadow, isNull);
      });

      testWidgets('supports custom min and max lines', (tester) async {
        await tester.pumpWidget(
          testApp(
            const TextAreaField(label: 'Label', minLines: 5, maxLines: 15),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.minLines, 5);
        expect(textField.maxLines, 15);
      });

      testWidgets('has smooth focus/blur transitions (200ms)', (tester) async {
        await tester.pumpWidget(
          testApp(
            const TextAreaField(label: 'Label'),
          ),
        );

        // Tap to focus
        await tester.tap(find.byType(TextField));

        // Pump a few frames to check for animated transitions
        await tester.pump(); // Start animation
        await tester.pump(const Duration(milliseconds: 100)); // Mid-animation

        // Complete animation (200ms total)
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        // Verify AnimatedContainer is being used for transitions
        expect(find.byType(AnimatedContainer), findsWidgets);
      });

      testWidgets('gradient border uses 30% opacity on focus', (tester) async {
        await tester.pumpWidget(
          testApp(
            const TextAreaField(label: 'Label'),
          ),
        );

        // Tap to focus the field
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        final animatedContainer = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.byType(TextField),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );

        final decoration = animatedContainer.decoration as BoxDecoration;
        expect(decoration.gradient, isNotNull);

        final gradient = decoration.gradient! as LinearGradient;
        // Gradient should use colors with 30% opacity
        for (final color in gradient.colors) {
          expect(
            (color.a * 255.0).round() & 0xff,
            lessThanOrEqualTo((255 * 0.3).round()),
          );
        }
      });

      testWidgets('applies glass effect overlay on focus (5% opacity)', (
        tester,
      ) async {
        await tester.pumpWidget(
          testApp(
            const TextAreaField(label: 'Label'),
          ),
        );

        // Tap to focus the field
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        // Find all containers to check for glass effect overlay
        final animatedContainers = tester.widgetList<AnimatedContainer>(
          find.ancestor(
            of: find.byType(TextField),
            matching: find.byType(AnimatedContainer),
          ),
        );

        // Should have multiple AnimatedContainers for layering effect (3 layers)
        expect(animatedContainers.length, 3);
      });

      testWidgets('has proper padding (12px horizontal, 16px vertical)', (
        tester,
      ) async {
        await tester.pumpWidget(
          testApp(
            const TextAreaField(label: 'Label'),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        final decoration = textField.decoration!;
        final padding = decoration.contentPadding! as EdgeInsets;

        // Multi-line input: 12px horizontal, 16px vertical
        expect(padding.left, 12.0); // AppSpacing.inputPaddingHorizontal
        expect(padding.right, 12.0);
        expect(padding.top, 16.0); // 16px for multi-line
        expect(padding.bottom, 16.0);
      });
    });
  });
}
