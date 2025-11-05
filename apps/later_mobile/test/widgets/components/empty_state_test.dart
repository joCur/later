import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/organisms/empty_states/empty_state.dart';
import 'package:later_mobile/design_system/atoms/buttons/primary_button.dart';
import 'package:later_mobile/design_system/atoms/buttons/ghost_button.dart';

import '../../test_helpers.dart';

void main() {
  group('EmptyState Widget Tests', () {
    testWidgets('renders with title and message', (tester) async {
      // Arrange
      const title = 'No items';
      const message = 'Create your first item';

      // Act
      await tester.pumpWidget(
        testApp(
          const EmptyState(
            title: title,
            message: message,
          ),
        ),
      );

      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('renders with icon when provided', (tester) async {
      // Arrange
      const icon = Icons.inbox_outlined;

      // Act
      await tester.pumpWidget(
        testApp(
          const EmptyState(
            icon: icon,
            title: 'Title',
            message: 'Message',
          ),
        ),
      );

      // Assert
      expect(find.byIcon(icon), findsOneWidget);
    });

    testWidgets('does not render icon when not provided', (tester) async {
      // Act
      await tester.pumpWidget(
        testApp(
          const EmptyState(
            title: 'Title',
            message: 'Message',
          ),
        ),
      );

      // Assert
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('renders primary action button when provided', (tester) async {
      // Arrange
      const actionLabel = 'Create Item';
      var buttonPressed = false;

      // Act
      await tester.pumpWidget(
        testApp(
          EmptyState(
            title: 'Title',
            message: 'Message',
            actionLabel: actionLabel,
            onActionPressed: () {
              buttonPressed = true;
            },
          ),
        ),
      );

      // Assert
      expect(find.text(actionLabel), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);

      // Tap the button
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      expect(buttonPressed, isTrue);
    });

    testWidgets('renders secondary action button when provided', (
      tester,
    ) async {
      // Arrange
      var secondaryPressed = false;

      // Act
      await tester.pumpWidget(
        testApp(
          EmptyState(
            title: 'Title',
            message: 'Message',
            secondaryActionLabel: 'Learn More',
            onSecondaryPressed: () {
              secondaryPressed = true;
            },
          ),
        ),
      );

      // Assert
      expect(find.text('Learn More'), findsOneWidget);
      expect(find.byType(GhostButton), findsOneWidget);

      // Tap the button
      await tester.tap(find.byType(GhostButton));
      await tester.pump();

      expect(secondaryPressed, isTrue);
    });

    testWidgets('does not render buttons when not provided', (tester) async {
      // Act
      await tester.pumpWidget(
        testApp(
          const EmptyState(
            title: 'Title',
            message: 'Message',
          ),
        ),
      );

      // Assert
      expect(find.byType(PrimaryButton), findsNothing);
      expect(find.byType(GhostButton), findsNothing);
    });

    testWidgets('does not render button when only label provided', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(
        testApp(
          const EmptyState(
            title: 'Title',
            message: 'Message',
            actionLabel: 'Create Item',
          ),
        ),
      );

      // Assert
      expect(find.byType(PrimaryButton), findsNothing);
    });

    testWidgets('does not render button when only callback provided', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(
        testApp(
          EmptyState(
            title: 'Title',
            message: 'Message',
            onActionPressed: () {},
          ),
        ),
      );

      // Assert
      expect(find.byType(PrimaryButton), findsNothing);
    });

    testWidgets('renders both primary and secondary buttons', (tester) async {
      // Act
      await tester.pumpWidget(
        testApp(
          EmptyState(
            title: 'Title',
            message: 'Message',
            actionLabel: 'Primary',
            onActionPressed: () {},
            secondaryActionLabel: 'Secondary',
            onSecondaryPressed: () {},
          ),
        ),
      );

      // Assert
      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(find.byType(GhostButton), findsOneWidget);
    });

    testWidgets('icon uses correct color in light mode', (tester) async {
      // Act
      await tester.pumpWidget(
        testApp(
          const EmptyState(
            icon: Icons.inbox_outlined,
            title: 'Title',
            message: 'Message',
          ),
        ),
      );

      // Assert - icon should have a color set
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.color, isNotNull);
    });

    testWidgets('icon uses correct color in dark mode', (tester) async {
      // Act
      await tester.pumpWidget(
        testAppDark(
          const EmptyState(
            icon: Icons.inbox_outlined,
            title: 'Title',
            message: 'Message',
          ),
        ),
      );

      // Assert - icon should have a color set
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.color, isNotNull);
    });

    testWidgets('centers content vertically and horizontally', (tester) async {
      // Act
      await tester.pumpWidget(
        testApp(
          const EmptyState(
            title: 'Title',
            message: 'Message',
          ),
        ),
      );

      // Assert
      final centerFinder = find.byType(Center);
      expect(centerFinder, findsWidgets);

      final columnWidget = tester.widget<Column>(find.byType(Column).first);
      expect(columnWidget.mainAxisAlignment, MainAxisAlignment.center);
      expect(columnWidget.crossAxisAlignment, CrossAxisAlignment.center);
    });

    testWidgets('text is center-aligned', (tester) async {
      // Arrange
      const title = 'Title';
      const message = 'Message';

      // Act
      await tester.pumpWidget(
        testApp(
          const EmptyState(
            title: title,
            message: message,
          ),
        ),
      );

      // Assert
      final titleText = tester.widget<Text>(find.text(title));
      expect(titleText.textAlign, TextAlign.center);

      final messageText = tester.widget<Text>(find.text(message));
      expect(messageText.textAlign, TextAlign.center);
    });

    testWidgets('message has max 3 lines with ellipsis', (tester) async {
      // Arrange
      const longMessage = 'This is a very long message that should be '
          'truncated after three lines with ellipsis overflow behavior';

      // Act
      await tester.pumpWidget(
        testApp(
          const EmptyState(
            title: 'Title',
            message: longMessage,
          ),
        ),
      );

      // Assert
      final messageText = tester.widget<Text>(find.text(longMessage));
      expect(messageText.maxLines, 3);
      expect(messageText.overflow, TextOverflow.ellipsis);
    });

    testWidgets('icon has responsive size on mobile', (tester) async {
      // Act - wrap in mobile-sized MediaQuery (< 768px)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: testApp(
            const EmptyState(
              icon: Icons.inbox_outlined,
              title: 'Title',
              message: 'Message',
            ),
          ),
        ),
      );

      // Assert
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.size, 80.0);
    });

    testWidgets('icon has responsive size on desktop', (tester) async {
      // Act - wrap in larger MediaQuery
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(size: Size(1200, 800)),
          child: MaterialApp(
            home: Scaffold(
              body: EmptyState(
                icon: Icons.inbox_outlined,
                title: 'Title',
                message: 'Message',
              ),
            ),
          ),
        ),
      );

      // Need to trigger theme extension setup
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)),
          child: testApp(
            const EmptyState(
              icon: Icons.inbox_outlined,
              title: 'Title',
              message: 'Message',
            ),
          ),
        ),
      );

      // Assert
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.size, 100.0);
    });

    testWidgets('full integration with all features', (tester) async {
      // Arrange
      var primaryCalled = false;
      var secondaryCalled = false;

      // Act
      await tester.pumpWidget(
        testApp(
          EmptyState(
            icon: Icons.inbox_outlined,
            title: 'No items yet',
            message: 'Create your first item to get started',
            actionLabel: 'Create Item',
            onActionPressed: () {
              primaryCalled = true;
            },
            secondaryActionLabel: 'Learn More',
            onSecondaryPressed: () {
              secondaryCalled = true;
            },
          ),
        ),
      );

      // Assert - all elements present
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('No items yet'), findsOneWidget);
      expect(find.text('Create your first item to get started'), findsOneWidget);
      expect(find.text('Create Item'), findsOneWidget);
      expect(find.text('Learn More'), findsOneWidget);

      // Tap primary action
      await tester.tap(find.byType(PrimaryButton));
      expect(primaryCalled, isTrue);

      // Tap secondary action
      await tester.tap(find.byType(GhostButton));
      expect(secondaryCalled, isTrue);
    });

    testWidgets('uses proper spacing between elements', (tester) async {
      // Act
      await tester.pumpWidget(
        testApp(
          EmptyState(
            icon: Icons.inbox_outlined,
            title: 'Title',
            message: 'Message',
            actionLabel: 'Action',
            onActionPressed: () {},
          ),
        ),
      );

      // Assert - find SizedBox widgets for spacing
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsWidgets);
    });

    testWidgets('applies responsive padding', (tester) async {
      // Act
      await tester.pumpWidget(
        testApp(
          const EmptyState(
            title: 'Title',
            message: 'Message',
          ),
        ),
      );

      // Assert - find Padding widget
      final paddingWidget = tester.widget<Padding>(
        find.descendant(
          of: find.byType(Center),
          matching: find.byType(Padding),
        ),
      );
      expect(paddingWidget, isNotNull);
    });
  });
}
