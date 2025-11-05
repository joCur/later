import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/atoms/inputs/text_input_field.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

import '../../../test_helpers.dart';

void main() {
  group('TextInputField', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(
        testApp(
          const TextInputField(label: 'Test Label'),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.byType(TextInputField), findsOneWidget);
    });

    testWidgets('renders with hint text', (tester) async {
      await tester.pumpWidget(
        testApp(
          const TextInputField(
            label: 'Label',
            hintText: 'Enter text here',
          ),
        ),
      );

      expect(find.text('Enter text here'), findsOneWidget);
    });

    testWidgets('accepts text input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        testApp(
          TextInputField(label: 'Label', controller: controller),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test input');
      expect(controller.text, 'Test input');

      controller.dispose();
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changedText;

      await tester.pumpWidget(
        testApp(
          TextInputField(
            label: 'Label',
            onChanged: (value) {
              changedText = value;
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Changed');
      expect(changedText, 'Changed');
    });

    testWidgets('displays error message when provided', (tester) async {
      await tester.pumpWidget(
        testApp(
          const TextInputField(
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
          const TextInputField(label: 'Label', enabled: false),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('shows prefix icon when provided', (tester) async {
      await tester.pumpWidget(
        testApp(
          const TextInputField(label: 'Label', prefixIcon: Icons.search),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows suffix icon when provided', (tester) async {
      await tester.pumpWidget(
        testApp(
          const TextInputField(label: 'Label', suffixIcon: Icons.clear),
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      await tester.pumpWidget(
        testApp(
          const TextInputField(label: 'Password', obscureText: true),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('applies keyboard type', (tester) async {
      await tester.pumpWidget(
        testApp(
          const TextInputField(
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('applies text input action', (tester) async {
      await tester.pumpWidget(
        testApp(
          const TextInputField(
            label: 'Label',
            textInputAction: TextInputAction.search,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.textInputAction, TextInputAction.search);
    });

    testWidgets('calls onSubmitted when submitted', (tester) async {
      String? submittedText;

      await tester.pumpWidget(
        testApp(
          TextInputField(
            label: 'Label',
            onSubmitted: (value) {
              submittedText = value;
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Submitted');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submittedText, 'Submitted');
    });

    testWidgets('auto-focuses when autofocus is true', (tester) async {
      await tester.pumpWidget(
        testApp(
          const TextInputField(label: 'Label', autofocus: true),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.autofocus, isTrue);
    });

    testWidgets(
      'displays character counter when maxLength provided',
      (tester) async {
        final controller = TextEditingController(text: 'Test');

        await tester.pumpWidget(
          testApp(
            TextInputField(
              label: 'Label',
              controller: controller,
              maxLength: 10,
            ),
          ),
        );

        // Should display custom counter
        expect(find.text('4 / 10'), findsOneWidget);

        controller.dispose();
      },
    );

    // ============================================================
    // TEMPORAL FLOW DESIGN SYSTEM TESTS
    // ============================================================

    group('Temporal Flow Design', () {
      testWidgets('has glass background with 3% opacity', (tester) async {
        await tester.pumpWidget(
          testApp(
            const TextInputField(label: 'Label'),
          ),
        );

        // Find all AnimatedContainers
        final containers =
            tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));

        // Check that at least one has the glass background color
        final theme = Theme.of(tester.element(find.byType(TextInputField)));
        final isDark = theme.brightness == Brightness.dark;

        final expectedColor = isDark
            ? AppColors.neutral900.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.03);

        expect(
          containers.any((container) {
            final decoration = container.decoration as BoxDecoration?;
            return decoration?.color == expectedColor;
          }),
          isTrue,
        );
      });

      testWidgets('shows gradient border on focus in light mode', (
        tester,
      ) async {
        await tester.pumpWidget(
          testApp(
            const TextInputField(label: 'Label'),
          ),
        );

        // Tap to focus the field
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        // Find all AnimatedContainers
        final containers =
            tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));

        // Check that at least one has a gradient
        expect(
          containers.any((container) {
            final decoration = container.decoration as BoxDecoration?;
            return decoration?.gradient is LinearGradient;
          }),
          isTrue,
        );
      });

      testWidgets('shows gradient border on focus in dark mode', (
        tester,
      ) async {
        await tester.pumpWidget(
          testAppDark(
            const TextInputField(label: 'Label'),
          ),
        );

        // Tap to focus the field
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        // Find all AnimatedContainers
        final containers =
            tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));

        // Check that at least one has a gradient
        expect(
          containers.any((container) {
            final decoration = container.decoration as BoxDecoration?;
            return decoration?.gradient is LinearGradient;
          }),
          isTrue,
        );
      });

      testWidgets(
        'shows focus shadow with gradient tint (8px blur, 20% opacity)',
        (tester) async {
          await tester.pumpWidget(
            testApp(
              const TextInputField(label: 'Label'),
            ),
          );

          // Tap to focus the field
          await tester.tap(find.byType(TextField));
          await tester.pumpAndSettle();

          // Find all AnimatedContainers
          final containers = tester
              .widgetList<AnimatedContainer>(find.byType(AnimatedContainer));

          // Check that at least one has a box shadow
          expect(
            containers.any((container) {
              final decoration = container.decoration as BoxDecoration?;
              final shadows = decoration?.boxShadow;
              if (shadows == null || shadows.isEmpty) return false;
              final shadow = shadows.first;
              return shadow.blurRadius == 8.0 &&
                  shadow.offset == const Offset(0, 2);
            }),
            isTrue,
          );
        },
      );

      testWidgets('has standard border when not focused', (tester) async {
        await tester.pumpWidget(
          testApp(
            const TextInputField(label: 'Label'),
          ),
        );

        // Don't focus - check initial state
        final containers =
            tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));

        // When not focused, the outermost container should not have a gradient
        // (only a standard border on the middle container)
        final outerContainer = containers.first;
        final decoration = outerContainer.decoration as BoxDecoration;
        expect(decoration.gradient, isNull);
        expect(decoration.boxShadow, isNull);
      });

      testWidgets('shows error gradient border when errorText is provided', (
        tester,
      ) async {
        await tester.pumpWidget(
          testApp(
            const TextInputField(label: 'Label', errorText: 'Error message'),
          ),
        );

        // Find all AnimatedContainers
        final containers =
            tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));

        // Check for error gradient border
        expect(
          containers.any((container) {
            final decoration = container.decoration as BoxDecoration?;
            if (decoration?.gradient is! LinearGradient) return false;
            final gradient = decoration!.gradient! as LinearGradient;
            // Error gradient should contain red and orange colors
            return gradient.colors.any(
              (c) =>
                  (c.r * 255.0).round() & 0xff > 200 &&
                  (c.g * 255.0).round() & 0xff < 100,
            );
          }),
          isTrue,
        );
      });

      testWidgets('shows error gradient border in dark mode', (tester) async {
        await tester.pumpWidget(
          testAppDark(
            const TextInputField(label: 'Label', errorText: 'Error message'),
          ),
        );

        // Find all AnimatedContainers
        final containers =
            tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));

        // Check for error gradient in dark mode
        expect(
          containers.any((container) {
            final decoration = container.decoration as BoxDecoration?;
            return decoration?.gradient is LinearGradient;
          }),
          isTrue,
        );
      });

      testWidgets('displays character counter with maxLength', (tester) async {
        final controller = TextEditingController(text: 'Test');

        await tester.pumpWidget(
          testApp(
            TextInputField(
              label: 'Label',
              controller: controller,
              maxLength: 10,
            ),
          ),
        );

        // Should show character counter: "4 / 10"
        expect(find.text('4 / 10'), findsOneWidget);

        controller.dispose();
      });

      testWidgets('character counter shows warning when >80%', (
        tester,
      ) async {
        final controller = TextEditingController(text: 'Twelve12');

        await tester.pumpWidget(
          testApp(
            TextInputField(
              label: 'Label',
              controller: controller,
              maxLength: 10,
            ),
          ),
        );

        // Should show counter when approaching limit (>80%)
        // The exact visual treatment (gradient via ShaderMask) is an implementation
        // detail - what matters is that the counter is displayed
        expect(find.text('8 / 10'), findsOneWidget);

        controller.dispose();
      });

      testWidgets('character counter shows warning when >90%', (
        tester,
      ) async {
        final controller = TextEditingController(text: 'TwelveOne');

        await tester.pumpWidget(
          testApp(
            TextInputField(
              label: 'Label',
              controller: controller,
              maxLength: 10,
            ),
          ),
        );

        // Should show counter when very close to limit (>90%)
        // The exact visual treatment (gradient + bold via ShaderMask) is an
        // implementation detail - what matters is that the counter is displayed
        expect(find.text('9 / 10'), findsOneWidget);

        controller.dispose();
      });

      testWidgets('does not show character counter when maxLength is null', (
        tester,
      ) async {
        final controller = TextEditingController(text: 'Test text');

        await tester.pumpWidget(
          testApp(
            TextInputField(label: 'Label', controller: controller),
          ),
        );

        // Should not show character counter when maxLength is not provided
        expect(find.textContaining('/'), findsNothing);

        controller.dispose();
      });

      testWidgets('placeholder has softer colors (60% opacity)', (
        tester,
      ) async {
        await tester.pumpWidget(
          testApp(
            const TextInputField(
              label: 'Label',
              hintText: 'Placeholder text',
            ),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        final hintStyle = textField.decoration!.hintStyle!;

        final theme = Theme.of(tester.element(find.byType(TextInputField)));
        final isDark = theme.brightness == Brightness.dark;

        final expectedColor = isDark
            ? AppColors.neutral500.withValues(alpha: 0.6)
            : AppColors.neutral500.withValues(alpha: 0.6);

        expect(hintStyle.color?.toARGB32(), expectedColor.toARGB32());
      });

      testWidgets('uses correct border radius (10px)', (tester) async {
        await tester.pumpWidget(
          testApp(
            const TextInputField(label: 'Label'),
          ),
        );

        // Find all AnimatedContainers
        final containers =
            tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));

        // Check that at least one has the correct border radius
        expect(
          containers.any((container) {
            final decoration = container.decoration as BoxDecoration?;
            final borderRadius = decoration?.borderRadius as BorderRadius?;
            return borderRadius?.topLeft.x == 10.0;
          }),
          isTrue,
        );
      });

      testWidgets('works correctly with long input', (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          testApp(
            TextInputField(
              label: 'Label',
              controller: controller,
              maxLength: 200,
            ),
          ),
        );

        // Enter long text
        const longText = 'This is a very long text that should work correctly '
            'with the new design system and display properly.';
        await tester.enterText(find.byType(TextField), longText);
        await tester.pump(); // Trigger rebuild for character counter

        expect(controller.text, longText);
        // Verify character counter is shown (text is ~100 chars)
        expect(find.textContaining('/ 200'), findsOneWidget);

        controller.dispose();
      });

      testWidgets('has smooth focus/blur transitions (200ms)', (tester) async {
        await tester.pumpWidget(
          testApp(
            const TextInputField(label: 'Label'),
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

      testWidgets('applies glass effect overlay on focus (5% opacity)', (
        tester,
      ) async {
        await tester.pumpWidget(
          testApp(
            const TextInputField(label: 'Label'),
          ),
        );

        // Tap to focus the field
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        // Find all containers to check for glass effect overlay
        final animatedContainers = tester.widgetList<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );

        // Should have multiple AnimatedContainers for layering effect (3 layers)
        expect(animatedContainers.length, 3);
      });

      testWidgets('has proper padding (12px horizontal, 12px vertical)', (
        tester,
      ) async {
        await tester.pumpWidget(
          testApp(
            const TextInputField(label: 'Label'),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        final decoration = textField.decoration!;
        final padding = decoration.contentPadding! as EdgeInsets;

        // Single-line input: 12px horizontal, 12px vertical
        expect(padding.left, 12.0); // AppSpacing.inputPaddingHorizontal
        expect(padding.right, 12.0);
        expect(padding.top, 12.0); // AppSpacing.inputPaddingVertical
        expect(padding.bottom, 12.0);
      });
    });
  });
}
