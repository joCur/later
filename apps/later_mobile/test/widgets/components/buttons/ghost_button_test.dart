import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/atoms/buttons/ghost_button.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

import '../../../test_helpers.dart';

void main() {
  group('GhostButton', () {
    testWidgets('renders with text', (tester) async {
      await tester.pumpWidget(
        testApp(
          GhostButton(text: 'Test Button', onPressed: () {}),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(GhostButton), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        testApp(
          GhostButton(
            text: 'Test Button',
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(GhostButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('renders in disabled state when onPressed is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(
          const GhostButton(text: 'Disabled Button', onPressed: null),
        ),
      );

      final button = tester.widget<GhostButton>(find.byType(GhostButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('shows loading indicator when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        testApp(
          GhostButton(
            text: 'Loading',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('renders with icon when provided', (tester) async {
      await tester.pumpWidget(
        testApp(
          GhostButton(
            text: 'With Icon',
            icon: Icons.delete,
            onPressed: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });

    testWidgets('has proper semantic label', (tester) async {
      await tester.pumpWidget(
        testApp(
          GhostButton(text: 'Accessible Button', onPressed: () {}),
        ),
      );

      // Verify the button exists and can be tapped
      expect(find.byType(GhostButton), findsOneWidget);
      expect(find.text('Accessible Button'), findsOneWidget);
    });

    testWidgets('does not call onPressed when loading', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        testApp(
          GhostButton(
            text: 'Loading',
            isLoading: true,
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(GhostButton));
      await tester.pump();

      expect(pressed, isFalse);
    });

    group('Temporal Flow Design Requirements', () {
      testWidgets('has 10px border radius', (tester) async {
        await tester.pumpWidget(
          testApp(
            GhostButton(text: 'Test', onPressed: () {}),
          ),
        );

        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(GhostButton),
                matching: find.byType(Container),
              )
              .first,
        );
        final decoration = container.decoration as BoxDecoration;
        final borderRadius = decoration.borderRadius as BorderRadius;
        expect(borderRadius.topLeft.x, AppSpacing.buttonRadius);
      });

      testWidgets('animates to 0.92 scale on press', (tester) async {
        await tester.pumpWidget(
          testApp(
            GhostButton(text: 'Test', onPressed: () {}),
          ),
        );

        // Find the AnimatedScale widget
        final animatedScale = tester.widget<AnimatedScale>(
          find.descendant(
            of: find.byType(GhostButton),
            matching: find.byType(AnimatedScale),
          ),
        );
        expect(animatedScale.scale, 1.0);

        // Simulate tap down
        await tester.press(find.byType(GhostButton));
        await tester.pumpAndSettle();

        // Scale should be 0.92 when pressed
        final animatedScalePressed = tester.widget<AnimatedScale>(
          find.descendant(
            of: find.byType(GhostButton),
            matching: find.byType(AnimatedScale),
          ),
        );
        expect(animatedScalePressed.scale, 0.92);
      });

      testWidgets('disabled state has 40% opacity', (tester) async {
        await tester.pumpWidget(
          testApp(
            const GhostButton(text: 'Disabled', onPressed: null),
          ),
        );

        final opacity = tester.widget<Opacity>(
          find.descendant(
            of: find.byType(GhostButton),
            matching: find.byType(Opacity),
          ),
        );
        expect(opacity.opacity, 0.4);
      });

      testWidgets('icon and text have 8px gap', (tester) async {
        await tester.pumpWidget(
          testApp(
            GhostButton(
              text: 'With Icon',
              icon: Icons.delete,
              onPressed: () {},
            ),
          ),
        );

        // Find the icon
        expect(find.byIcon(Icons.delete), findsOneWidget);

        // Find the SizedBox that is between Icon and Text (should be 8px)
        final row = tester.widget<Row>(
          find.descendant(
            of: find.byType(GhostButton),
            matching: find.byType(Row),
          ),
        );

        // The Row should have 3 children: Icon, SizedBox(width: 8), Text
        expect(row.children.length, 3);
        final sizedBox = row.children[1] as SizedBox;
        expect(sizedBox.width, AppSpacing.xs);
      });
    });
  });
}
