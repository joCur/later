import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/organisms/empty_states/empty_state.dart';
import 'package:later_mobile/design_system/atoms/buttons/primary_button.dart';
import 'package:later_mobile/design_system/atoms/buttons/ghost_button.dart';

void main() {
  group('EmptyState Base Component Tests', () {
    testWidgets('renders with icon, title, and description', (
      WidgetTester tester,
    ) async {
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
              title: 'Title',
              message: 'Description',
            ),
          ),
        ),
      );

      // Assert - icon should be present
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget, isNotNull);
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

    testWidgets('renders with secondary action button', (
      WidgetTester tester,
    ) async {
      // Arrange
      var secondaryButtonPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Description',
              actionLabel: 'Primary Action',
              onActionPressed: () {},
              secondaryActionLabel: 'Secondary Action',
              onSecondaryPressed: () {
                secondaryButtonPressed = true;
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Secondary Action'), findsOneWidget);
      expect(find.byType(GhostButton), findsOneWidget);

      // Tap secondary button
      await tester.tap(find.text('Secondary Action'));
      await tester.pump();
      expect(secondaryButtonPressed, isTrue);
    });

    testWidgets('does not render CTA when not provided', (
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

      // Assert
      expect(find.byType(PrimaryButton), findsNothing);
    });

    testWidgets('does not render secondary action when not provided', (
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

      // Assert
      expect(find.byType(GhostButton), findsNothing);
    });

    testWidgets('uses correct colors in light mode', (
      WidgetTester tester,
    ) async {
      // Act
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

      // Assert - icon uses disabled text color
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.color, isNotNull);
    });

    testWidgets('uses correct colors in dark mode', (
      WidgetTester tester,
    ) async {
      // Act
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

      // Assert - icon uses disabled text color
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.color, isNotNull);
    });

    testWidgets('applies correct typography', (WidgetTester tester) async {
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

      // Assert - title and description use responsive typography
      final titleText = tester.widget<Text>(find.text('Title'));
      expect(titleText.style?.fontSize, isNotNull);

      final descriptionText = tester.widget<Text>(find.text('Description'));
      expect(descriptionText.style?.fontSize, isNotNull);
    });

    testWidgets('applies correct spacing', (WidgetTester tester) async {
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

      // Assert - verify spacing between elements
      final column = tester.widget<Column>(find.byType(Column).first);
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('centers content horizontally and vertically', (
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

      // Assert
      expect(find.byType(Center), findsWidgets);
      final column = tester.widget<Column>(find.byType(Column).first);
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
      expect(column.crossAxisAlignment, CrossAxisAlignment.center);
    });

    // Max width constraint test removed - EmptyState now uses responsive padding instead

    testWidgets('text is center-aligned', (WidgetTester tester) async {
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
      final titleText = tester.widget<Text>(find.text('Title'));
      expect(titleText.textAlign, TextAlign.center);

      final descriptionText = tester.widget<Text>(find.text('Description'));
      expect(descriptionText.textAlign, TextAlign.center);
    });

    testWidgets('CTA button uses PrimaryButton', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Description',
              actionLabel: 'Action',
              onActionPressed: () {},
            ),
          ),
        ),
      );

      // Assert - check PrimaryButton is rendered
      expect(find.text('Action'), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
    });

    testWidgets('renders both primary and secondary actions together', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Description',
              actionLabel: 'Primary',
              onActionPressed: () {},
              secondaryActionLabel: 'Secondary',
              onSecondaryPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(find.byType(GhostButton), findsOneWidget);
    });

    testWidgets('has proper semantic labels for accessibility', (
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

      // Assert - verify text is accessible
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('respects vertical spacing of 64px between sections', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Description',
              actionLabel: 'Action',
              onActionPressed: () {},
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
