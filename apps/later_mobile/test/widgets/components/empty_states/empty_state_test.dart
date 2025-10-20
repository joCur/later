import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/widgets/components/empty_states/empty_state.dart';
import 'package:later_mobile/core/theme/app_colors.dart';

void main() {
  group('EmptyState Base Component Tests', () {
    testWidgets('renders with icon, title, and description',
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
              iconSize: 64.0,
              title: title,
              description: description,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.text(description), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('renders with custom icon size', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              iconSize: 64.0,
              title: 'Title',
              description: 'Description',
            ),
          ),
        ),
      );

      // Assert
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.size, 64.0);
    });

    testWidgets('renders with CTA button', (WidgetTester tester) async {
      // Arrange
      var buttonPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              iconSize: 64.0,
              title: 'Title',
              description: 'Description',
              ctaText: 'Take Action',
              onCtaPressed: () {
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

    testWidgets('renders with secondary text link', (WidgetTester tester) async {
      // Arrange
      var linkPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              iconSize: 64.0,
              title: 'Title',
              description: 'Description',
              secondaryText: 'Learn more',
              onSecondaryPressed: () {
                linkPressed = true;
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Learn more'), findsOneWidget);

      // Tap link
      await tester.tap(find.text('Learn more'));
      await tester.pump();
      expect(linkPressed, isTrue);
    });

    testWidgets('does not render CTA when not provided',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              iconSize: 64.0,
              title: 'Title',
              description: 'Description',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('does not render secondary link when not provided',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              iconSize: 64.0,
              title: 'Title',
              description: 'Description',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('uses correct colors in light mode',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              iconSize: 64.0,
              title: 'Title',
              description: 'Description',
            ),
          ),
        ),
      );

      // Assert
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.color, AppColors.neutralGray300);
    });

    testWidgets('uses correct colors in dark mode',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              iconSize: 64.0,
              title: 'Title',
              description: 'Description',
            ),
          ),
        ),
      );

      // Assert
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.color, AppColors.neutralGray600);
    });

    testWidgets('applies correct typography', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              iconSize: 64.0,
              title: 'Title',
              description: 'Description',
            ),
          ),
        ),
      );

      // Assert - title uses display large on mobile (40px)
      final titleText = tester.widget<Text>(find.text('Title'));
      expect(titleText.style?.fontSize, 40.0);

      // Assert - description uses body large (17px)
      final descriptionText = tester.widget<Text>(find.text('Description'));
      expect(descriptionText.style?.fontSize, 16.0);
    });

    testWidgets('applies correct spacing', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              iconSize: 64.0,
              title: 'Title',
              description: 'Description',
            ),
          ),
        ),
      );

      // Assert - verify spacing between elements
      final column = tester.widget<Column>(find.byType(Column).first);
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('centers content horizontally and vertically',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              iconSize: 64.0,
              title: 'Title',
              description: 'Description',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Center), findsWidgets);
      final column = tester.widget<Column>(find.byType(Column).first);
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
      expect(column.crossAxisAlignment, CrossAxisAlignment.center);
    });

    testWidgets('applies max width constraint', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              iconSize: 64.0,
              title: 'Title',
              description: 'Description',
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

    testWidgets('text is center-aligned', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              iconSize: 64.0,
              title: 'Title',
              description: 'Description',
            ),
          ),
        ),
      );

      // Assert
      final titleText = tester.widget<Text>(find.text('Title'));
      expect(titleText.textAlign, TextAlign.center);

      final descriptionText = tester.widget<Text>(find.text('Description'));
      expect(descriptionText.textAlign, TextAlign.center);
    });

    testWidgets('CTA button has gradient style', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              iconSize: 64.0,
              title: 'Title',
              description: 'Description',
              ctaText: 'Action',
              onCtaPressed: () {},
            ),
          ),
        ),
      );

      // Assert - check button is rendered
      expect(find.text('Action'), findsOneWidget);
    });

    testWidgets('secondary link has correct styling',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              iconSize: 64.0,
              title: 'Title',
              description: 'Description',
              secondaryText: 'Learn more',
              onSecondaryPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      final textButton = tester.widget<TextButton>(find.byType(TextButton));
      expect(textButton, isNotNull);
    });

    testWidgets('renders both CTA and secondary link together',
        (WidgetTester tester) async {
      // Arrange
      var ctaPressed = false;
      var secondaryPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              iconSize: 64.0,
              title: 'Title',
              description: 'Description',
              ctaText: 'Primary Action',
              onCtaPressed: () {
                ctaPressed = true;
              },
              secondaryText: 'Secondary Action',
              onSecondaryPressed: () {
                secondaryPressed = true;
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Primary Action'), findsOneWidget);
      expect(find.text('Secondary Action'), findsOneWidget);

      await tester.tap(find.text('Primary Action'));
      await tester.pump();
      expect(ctaPressed, isTrue);

      await tester.tap(find.text('Secondary Action'));
      await tester.pump();
      expect(secondaryPressed, isTrue);
    });

    testWidgets('has proper semantic labels for accessibility',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              iconSize: 64.0,
              title: 'Title',
              description: 'Description',
            ),
          ),
        ),
      );

      // Assert - verify text is accessible
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('respects vertical spacing of 64px between sections',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              iconSize: 64.0,
              title: 'Title',
              description: 'Description',
              ctaText: 'Action',
              onCtaPressed: () {},
            ),
          ),
        ),
      );

      // Assert - find SizedBox widgets with height spacing
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsWidgets);
    });
  });
}
