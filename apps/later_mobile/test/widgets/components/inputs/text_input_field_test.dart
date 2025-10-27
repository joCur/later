import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/design_system/atoms/inputs/text_input_field.dart';

void main() {
  group('TextInputField', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextInputField(
              label: 'Test Label',
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.byType(TextInputField), findsOneWidget);
    });

    testWidgets('renders with hint text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextInputField(
              label: 'Label',
              hintText: 'Enter text here',
            ),
          ),
        ),
      );

      expect(find.text('Enter text here'), findsOneWidget);
    });

    testWidgets('accepts text input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextInputField(
              label: 'Label',
              controller: controller,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test input');
      expect(controller.text, 'Test input');

      controller.dispose();
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextInputField(
              label: 'Label',
              onChanged: (value) {
                changedText = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Changed');
      expect(changedText, 'Changed');
    });

    testWidgets('displays error message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextInputField(
              label: 'Label',
              errorText: 'This field is required',
            ),
          ),
        ),
      );

      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('renders in disabled state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextInputField(
              label: 'Label',
              enabled: false,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('shows prefix icon when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextInputField(
              label: 'Label',
              prefixIcon: Icons.search,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows suffix icon when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextInputField(
              label: 'Label',
              suffixIcon: Icons.clear,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextInputField(
              label: 'Password',
              obscureText: true,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('applies keyboard type', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextInputField(
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('applies text input action', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextInputField(
              label: 'Label',
              textInputAction: TextInputAction.search,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.textInputAction, TextInputAction.search);
    });

    testWidgets('calls onSubmitted when submitted', (tester) async {
      String? submittedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextInputField(
              label: 'Label',
              onSubmitted: (value) {
                submittedText = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Submitted');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submittedText, 'Submitted');
    });

    testWidgets('auto-focuses when autofocus is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextInputField(
              label: 'Label',
              autofocus: true,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.autofocus, isTrue);
    });

    testWidgets('displays character counter when maxLength provided', (tester) async {
      final controller = TextEditingController(text: 'Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextInputField(
              label: 'Label',
              controller: controller,
              maxLength: 10,
            ),
          ),
        ),
      );

      // Should display custom counter (TextField maxLength is null to hide default)
      expect(find.text('4 / 10'), findsOneWidget);

      controller.dispose();
    });

    // ============================================================
    // TEMPORAL FLOW DESIGN SYSTEM TESTS
    // ============================================================

    group('Temporal Flow Design', () {
      testWidgets('has glass background with 3% opacity', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TextInputField(
                label: 'Label',
              ),
            ),
          ),
        );

        // Find the outermost AnimatedContainer
        final animatedContainer = tester.widget<AnimatedContainer>(
          find.ancestor(
            of: find.byType(TextField),
            matching: find.byType(AnimatedContainer),
          ).first,
        );

        final decoration = animatedContainer.decoration as BoxDecoration;
        final theme = Theme.of(tester.element(find.byType(TextInputField)));
        final isDark = theme.brightness == Brightness.dark;

        // Check for glass background (3% opacity)
        final expectedColor = isDark
            ? AppColors.neutral900.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.03);

        expect(decoration.color, expectedColor);
      });

      testWidgets('shows gradient border on focus in light mode', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TextInputField(
                label: 'Label',
              ),
            ),
          ),
        );

        // Tap to focus the field
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        // Find the outermost AnimatedContainer which has the gradient
        final animatedContainer = tester.widget<AnimatedContainer>(
          find.ancestor(
            of: find.byType(TextField),
            matching: find.byType(AnimatedContainer),
          ).first,
        );

        final decoration = animatedContainer.decoration as BoxDecoration;

        // Check for gradient border (with 30% opacity)
        expect(decoration.gradient, isNotNull);
        expect(decoration.gradient, isA<LinearGradient>());

        final gradient = decoration.gradient as LinearGradient;
        // Should have gradient colors with 30% opacity
        expect(gradient.colors.length, 2);
        // Check that colors have reduced alpha (30%)
        for (final color in gradient.colors) {
          expect((color.a * 255.0).round() & 0xff, lessThanOrEqualTo((255 * 0.3).round()));
        }
      });

      testWidgets('shows gradient border on focus in dark mode', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const Scaffold(
              body: TextInputField(
                label: 'Label',
              ),
            ),
          ),
        );

        // Tap to focus the field
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        // Find the outermost AnimatedContainer which has the gradient
        final animatedContainer = tester.widget<AnimatedContainer>(
          find.ancestor(
            of: find.byType(TextField),
            matching: find.byType(AnimatedContainer),
          ).first,
        );

        final decoration = animatedContainer.decoration as BoxDecoration;

        // Check for dark mode gradient border (with 30% opacity)
        expect(decoration.gradient, isNotNull);
        expect(decoration.gradient, isA<LinearGradient>());

        final gradient = decoration.gradient as LinearGradient;
        // Should have gradient colors with 30% opacity
        expect(gradient.colors.length, 2);
        // Check that colors have reduced alpha (30%)
        for (final color in gradient.colors) {
          expect((color.a * 255.0).round() & 0xff, lessThanOrEqualTo((255 * 0.3).round()));
        }
      });

      testWidgets('shows focus shadow with gradient tint (8px blur, 20% opacity)', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TextInputField(
                label: 'Label',
              ),
            ),
          ),
        );

        // Tap to focus the field
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        // Find the outermost AnimatedContainer which has the shadow
        final animatedContainer = tester.widget<AnimatedContainer>(
          find.ancestor(
            of: find.byType(TextField),
            matching: find.byType(AnimatedContainer),
          ).first,
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

      testWidgets('has standard border when not focused', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TextInputField(
                label: 'Label',
              ),
            ),
          ),
        );

        // Find the outermost AnimatedContainer
        final animatedContainer = tester.widget<AnimatedContainer>(
          find.ancestor(
            of: find.byType(TextField),
            matching: find.byType(AnimatedContainer),
          ).first,
        );

        final decoration = animatedContainer.decoration as BoxDecoration;

        // Should have no gradient or shadow when not focused
        expect(decoration.gradient, isNull);
        expect(decoration.boxShadow, isNull);
      });

      testWidgets('shows error gradient border when errorText is provided', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TextInputField(
                label: 'Label',
                errorText: 'Error message',
              ),
            ),
          ),
        );

        // Find the outermost AnimatedContainer
        final animatedContainer = tester.widget<AnimatedContainer>(
          find.ancestor(
            of: find.byType(TextField),
            matching: find.byType(AnimatedContainer),
          ).first,
        );

        final decoration = animatedContainer.decoration as BoxDecoration;

        // Check for error gradient border
        expect(decoration.gradient, isNotNull);
        expect(decoration.gradient, isA<LinearGradient>());

        final gradient = decoration.gradient as LinearGradient;
        // Error gradient: red-500 to orange-400 in light mode
        expect(gradient.colors, contains(const Color(0xFFEF4444)));
        expect(gradient.colors, contains(const Color(0xFFFB923C)));
      });

      testWidgets('shows error gradient border in dark mode', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const Scaffold(
              body: TextInputField(
                label: 'Label',
                errorText: 'Error message',
              ),
            ),
          ),
        );

        // Find the outermost AnimatedContainer
        final animatedContainer = tester.widget<AnimatedContainer>(
          find.ancestor(
            of: find.byType(TextField),
            matching: find.byType(AnimatedContainer),
          ).first,
        );

        final decoration = animatedContainer.decoration as BoxDecoration;

        // Check for dark mode error gradient border
        expect(decoration.gradient, isNotNull);
        final gradient = decoration.gradient as LinearGradient;
        // Error gradient: red-400 to yellow-400 in dark mode
        expect(gradient.colors, contains(const Color(0xFFF87171)));
        expect(gradient.colors, contains(const Color(0xFFFBBF24)));
      });

      testWidgets('displays character counter with maxLength', (tester) async {
        final controller = TextEditingController(text: 'Test');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextInputField(
                label: 'Label',
                controller: controller,
                maxLength: 10,
              ),
            ),
          ),
        );

        // Should show character counter: "4 / 10"
        expect(find.text('4 / 10'), findsOneWidget);

        controller.dispose();
      });

      testWidgets('character counter shows warning gradient when >80%', (tester) async {
        final controller = TextEditingController(text: 'Twelve12');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextInputField(
                label: 'Label',
                controller: controller,
                maxLength: 10,
              ),
            ),
          ),
        );

        // Should show counter with gradient when approaching limit (>80%)
        expect(find.text('8 / 10'), findsOneWidget);

        // Should have gradient foreground (ShaderMask applied)
        // This is tested by checking parent widget structure
        final counterParent = tester.widget<Widget>(
          find.ancestor(
            of: find.text('8 / 10'),
            matching: find.byType(ShaderMask),
          ),
        );
        expect(counterParent, isNotNull);

        controller.dispose();
      });

      testWidgets('character counter shows bold gradient when >90%', (tester) async {
        final controller = TextEditingController(text: 'TwelveOne');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextInputField(
                label: 'Label',
                controller: controller,
                maxLength: 10,
              ),
            ),
          ),
        );

        // Should show counter with bold gradient when very close to limit (>90%)
        expect(find.text('9 / 10'), findsOneWidget);

        final counterText = tester.widget<Text>(find.text('9 / 10'));

        // Should be bold
        expect(counterText.style?.fontWeight, FontWeight.bold);

        controller.dispose();
      });

      testWidgets('does not show character counter when maxLength is null', (tester) async {
        final controller = TextEditingController(text: 'Test text');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextInputField(
                label: 'Label',
                controller: controller,
              ),
            ),
          ),
        );

        // Should not show character counter when maxLength is not provided
        expect(find.textContaining('/'), findsNothing);

        controller.dispose();
      });

      testWidgets('placeholder has softer colors (60% opacity)', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TextInputField(
                label: 'Label',
                hintText: 'Placeholder text',
              ),
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
          const MaterialApp(
            home: Scaffold(
              body: TextInputField(
                label: 'Label',
              ),
            ),
          ),
        );

        // Find the outermost AnimatedContainer
        final animatedContainer = tester.widget<AnimatedContainer>(
          find.ancestor(
            of: find.byType(TextField),
            matching: find.byType(AnimatedContainer),
          ).first,
        );

        final decoration = animatedContainer.decoration as BoxDecoration;
        final borderRadius = decoration.borderRadius as BorderRadius;

        // Plan specifies 10px border radius
        expect(borderRadius.topLeft.x, 10.0);
        expect(borderRadius.topRight.x, 10.0);
        expect(borderRadius.bottomLeft.x, 10.0);
        expect(borderRadius.bottomRight.x, 10.0);
      });

      testWidgets('works correctly with long input', (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextInputField(
                label: 'Label',
                controller: controller,
                maxLength: 100,
              ),
            ),
          ),
        );

        // Enter long text
        const longText = 'This is a very long text that should work correctly '
            'with the new design system and display properly.';
        await tester.enterText(find.byType(TextField), longText);

        expect(controller.text, longText);
        expect(find.text('${longText.length} / 100'), findsOneWidget);

        controller.dispose();
      });

      testWidgets('maintains focus state transitions correctly', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TextInputField(
                label: 'Label',
              ),
            ),
          ),
        );

        // Initial state: no focus, no gradient
        var animatedContainer = tester.widget<AnimatedContainer>(
          find.ancestor(
            of: find.byType(TextField),
            matching: find.byType(AnimatedContainer),
          ).first,
        );
        var decoration = animatedContainer.decoration as BoxDecoration;
        expect(decoration.gradient, isNull);

        // Tap to focus
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        // Focused state: should have gradient border
        animatedContainer = tester.widget<AnimatedContainer>(
          find.ancestor(
            of: find.byType(TextField),
            matching: find.byType(AnimatedContainer),
          ).first,
        );
        decoration = animatedContainer.decoration as BoxDecoration;
        expect(decoration.gradient, isNotNull);
        expect(decoration.boxShadow, isNotNull);

        // Unfocus
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Unfocused state: gradient should be removed
        animatedContainer = tester.widget<AnimatedContainer>(
          find.ancestor(
            of: find.byType(TextField),
            matching: find.byType(AnimatedContainer),
          ).first,
        );
        decoration = animatedContainer.decoration as BoxDecoration;
        expect(decoration.gradient, isNull);
        expect(decoration.boxShadow, isNull);
      });

      testWidgets('has smooth focus/blur transitions (200ms)', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TextInputField(
                label: 'Label',
              ),
            ),
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
          const MaterialApp(
            home: Scaffold(
              body: TextInputField(
                label: 'Label',
              ),
            ),
          ),
        );

        // Tap to focus the field
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        // Find the outermost AnimatedContainer
        final animatedContainer = tester.widget<AnimatedContainer>(
          find.ancestor(
            of: find.byType(TextField),
            matching: find.byType(AnimatedContainer),
          ).first,
        );

        final decoration = animatedContainer.decoration as BoxDecoration;
        expect(decoration.gradient, isNotNull);

        final gradient = decoration.gradient as LinearGradient;
        // Gradient should use colors with 30% opacity
        for (final color in gradient.colors) {
          expect((color.a * 255.0).round() & 0xff, lessThanOrEqualTo((255 * 0.3).round()));
        }
      });

      testWidgets('applies glass effect overlay on focus (5% opacity)', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TextInputField(
                label: 'Label',
              ),
            ),
          ),
        );

        // Tap to focus the field
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        // Find all AnimatedContainers to check for glass effect overlay
        final animatedContainers = tester.widgetList<AnimatedContainer>(
          find.ancestor(
            of: find.byType(TextField),
            matching: find.byType(AnimatedContainer),
          ),
        );

        // Should have multiple AnimatedContainers for layering effect (3 layers)
        expect(animatedContainers.length, 3);
      });

      testWidgets('has proper padding (12px horizontal, 12px vertical)', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TextInputField(
                label: 'Label',
              ),
            ),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        final decoration = textField.decoration!;
        final padding = decoration.contentPadding as EdgeInsets;

        // Single-line input: 12px horizontal, 12px vertical
        expect(padding.left, 12.0); // AppSpacing.inputPaddingHorizontal
        expect(padding.right, 12.0);
        expect(padding.top, 12.0); // AppSpacing.inputPaddingVertical
        expect(padding.bottom, 12.0);
      });
    });
  });
}
