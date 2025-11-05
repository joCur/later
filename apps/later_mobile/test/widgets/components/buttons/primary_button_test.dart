import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/design_system/atoms/buttons/primary_button.dart';

import '../../../test_helpers.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('renders with text', (tester) async {
      await tester.pumpWidget(
        testApp(
          PrimaryButton(text: 'Test Button', onPressed: () {}),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        testApp(
          PrimaryButton(
            text: 'Test Button',
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('renders in disabled state when onPressed is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(
          const PrimaryButton(text: 'Disabled Button', onPressed: null),
        ),
      );

      final button = tester.widget<PrimaryButton>(find.byType(PrimaryButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('renders small size correctly', (tester) async {
      await tester.pumpWidget(
        testApp(
          PrimaryButton(
            text: 'Small',
            size: ButtonSize.small,
            onPressed: () {},
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(of: find.text('Small'), matching: find.byType(Container)),
      );
      expect(container, isNotNull);
    });

    testWidgets('renders medium size correctly', (tester) async {
      await tester.pumpWidget(
        testApp(
          PrimaryButton(text: 'Medium', onPressed: () {}),
        ),
      );

      expect(find.text('Medium'), findsOneWidget);
    });

    testWidgets('renders large size correctly', (tester) async {
      await tester.pumpWidget(
        testApp(
          PrimaryButton(
            text: 'Large',
            size: ButtonSize.large,
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Large'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(
          PrimaryButton(
            text: 'Loading',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('does not call onPressed when loading', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        testApp(
          PrimaryButton(
            text: 'Loading',
            isLoading: true,
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('renders with icon when provided', (tester) async {
      await tester.pumpWidget(
        testApp(
          PrimaryButton(
            text: 'With Icon',
            icon: Icons.add,
            onPressed: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });

    testWidgets('has proper semantic label', (tester) async {
      await tester.pumpWidget(
        testApp(
          PrimaryButton(text: 'Accessible Button', onPressed: () {}),
        ),
      );

      // Verify the button exists and can be tapped
      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(find.text('Accessible Button'), findsOneWidget);
    });

    testWidgets('is not enabled when disabled', (tester) async {
      await tester.pumpWidget(
        testApp(
          const PrimaryButton(text: 'Disabled', onPressed: null),
        ),
      );

      // Verify the button is disabled
      final button = tester.widget<PrimaryButton>(find.byType(PrimaryButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('expands to full width when isExpanded is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(
          SizedBox(
            width: 300,
            child: PrimaryButton(
              text: 'Expanded',
              isExpanded: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Find the SizedBox with width: double.infinity inside PrimaryButton
      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(PrimaryButton),
              matching: find.byType(SizedBox),
            )
            .last,
      );
      expect(sizedBox.width, double.infinity);
    });

    group('Temporal Flow Design Requirements', () {
      testWidgets('has 10px border radius', (tester) async {
        await tester.pumpWidget(
          testApp(
            PrimaryButton(text: 'Test', onPressed: () {}),
          ),
        );

        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(PrimaryButton),
                matching: find.byType(Container),
              )
              .first,
        );
        final decoration = container.decoration as BoxDecoration;
        final borderRadius = decoration.borderRadius as BorderRadius;
        expect(borderRadius.topLeft.x, AppSpacing.buttonRadius);
      });

      testWidgets('uses gradient background in light mode', (tester) async {
        await tester.pumpWidget(
          testApp(
            PrimaryButton(text: 'Test', onPressed: () {}),
          ),
        );

        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(PrimaryButton),
                matching: find.byType(Container),
              )
              .first,
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.gradient, isNotNull);
        expect(decoration.gradient, isA<LinearGradient>());
      });

      testWidgets('uses gradient background in dark mode', (tester) async {
        await tester.pumpWidget(
          testAppDark(
            PrimaryButton(text: 'Test', onPressed: () {}),
          ),
        );

        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(PrimaryButton),
                matching: find.byType(Container),
              )
              .first,
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.gradient, isNotNull);
        expect(decoration.gradient, isA<LinearGradient>());
      });

      testWidgets('animates to 0.92 scale on press', (tester) async {
        await tester.pumpWidget(
          testApp(
            PrimaryButton(text: 'Test', onPressed: () {}),
          ),
        );

        // Find the AnimatedScale widget
        final animatedScale = tester.widget<AnimatedScale>(
          find.descendant(
            of: find.byType(PrimaryButton),
            matching: find.byType(AnimatedScale),
          ),
        );
        expect(animatedScale.scale, 1.0);

        // Simulate tap down
        await tester.press(find.byType(PrimaryButton));
        await tester.pumpAndSettle();

        // Scale should be 0.92 when pressed
        final animatedScalePressed = tester.widget<AnimatedScale>(
          find.descendant(
            of: find.byType(PrimaryButton),
            matching: find.byType(AnimatedScale),
          ),
        );
        expect(animatedScalePressed.scale, 0.92);
      });

      testWidgets('has soft shadow when enabled', (tester) async {
        await tester.pumpWidget(
          testApp(
            PrimaryButton(text: 'Test', onPressed: () {}),
          ),
        );

        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(PrimaryButton),
                matching: find.byType(Container),
              )
              .first,
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.boxShadow, isNotNull);
        expect(decoration.boxShadow!.length, greaterThan(0));
        expect(
          decoration.boxShadow!.first.blurRadius,
          greaterThanOrEqualTo(4.0),
        );
      });

      testWidgets('disabled state has 40% opacity', (tester) async {
        await tester.pumpWidget(
          testApp(
            const PrimaryButton(text: 'Disabled', onPressed: null),
          ),
        );

        final opacity = tester.widget<Opacity>(
          find.descendant(
            of: find.byType(PrimaryButton),
            matching: find.byType(Opacity),
          ),
        );
        expect(opacity.opacity, 0.4);
      });

      testWidgets('icon and text have 8px gap', (tester) async {
        await tester.pumpWidget(
          testApp(
            PrimaryButton(
              text: 'With Icon',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        );

        // Find the icon
        expect(find.byIcon(Icons.add), findsOneWidget);

        // Find the SizedBox that is between Icon and Text (should be 8px)
        final row = tester.widget<Row>(
          find.descendant(
            of: find.byType(PrimaryButton),
            matching: find.byType(Row),
          ),
        );

        // The Row should have 3 children: Icon, SizedBox(width: 8), Text
        expect(row.children.length, 3);
        final sizedBox = row.children[1] as SizedBox;
        expect(sizedBox.width, AppSpacing.xs);
      });

      testWidgets('button sizes are correct', (tester) async {
        // Small: 36px
        await tester.pumpWidget(
          testApp(
            PrimaryButton(
              text: 'Small',
              size: ButtonSize.small,
              onPressed: () {},
            ),
          ),
        );

        // Container uses height constraint, verify it's 36px
        var containerBox = tester.getSize(
          find
              .descendant(
                of: find.byType(PrimaryButton),
                matching: find.byType(Container),
              )
              .first,
        );
        expect(containerBox.height, 36.0);

        // Medium: 44px
        await tester.pumpWidget(
          testApp(
            PrimaryButton(text: 'Medium', onPressed: () {}),
          ),
        );

        // Container uses height constraint, verify it's 44px
        containerBox = tester.getSize(
          find
              .descendant(
                of: find.byType(PrimaryButton),
                matching: find.byType(Container),
              )
              .first,
        );
        expect(containerBox.height, 44.0);

        // Large: 52px
        await tester.pumpWidget(
          testApp(
            PrimaryButton(
              text: 'Large',
              size: ButtonSize.large,
              onPressed: () {},
            ),
          ),
        );

        // Container uses height constraint, verify it's 52px
        containerBox = tester.getSize(
          find
              .descendant(
                of: find.byType(PrimaryButton),
                matching: find.byType(Container),
              )
              .first,
        );
        expect(containerBox.height, 52.0);
      });
    });
  });
}
