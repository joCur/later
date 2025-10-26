import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/organisms/empty_states/empty_state.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

void main() {
  group('EmptyState Widget Tests', () {
    testWidgets('renders with title and message', (WidgetTester tester) async {
      // Arrange
      const title = 'No items';
      const message = 'Create your first item';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: title,
              message: message,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('renders with icon when provided', (WidgetTester tester) async {
      // Arrange
      const icon = Icons.inbox_outlined;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: icon,
              title: 'Title',
              message: 'Message',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(icon), findsOneWidget);
    });

    testWidgets('does not render icon when not provided',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Title',
              message: 'Message',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('renders CTA button when provided',
        (WidgetTester tester) async {
      // Arrange
      const actionLabel = 'Create Item';
      var buttonPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Title',
              message: 'Message',
              actionLabel: actionLabel,
              onActionPressed: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(actionLabel), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Tap the button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(buttonPressed, isTrue);
    });

    testWidgets('does not render CTA button when not provided',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Title',
              message: 'Message',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('does not render CTA button when only label provided',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Title',
              message: 'Message',
              actionLabel: 'Create Item',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('does not render CTA button when only callback provided',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Title',
              message: 'Message',
              onActionPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('uses correct colors in light mode',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: EmptyState(
              icon: Icons.inbox_outlined,
              title: 'Title',
              message: 'Message',
            ),
          ),
        ),
      );

      // Assert
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.color, AppColors.textDisabledLight);
    });

    testWidgets('uses correct colors in dark mode',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: EmptyState(
              icon: Icons.inbox_outlined,
              title: 'Title',
              message: 'Message',
            ),
          ),
        ),
      );

      // Assert
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.color, AppColors.textDisabledDark);
    });

    testWidgets('centers content vertically and horizontally',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Title',
              message: 'Message',
            ),
          ),
        ),
      );

      // Assert
      final centerFinder = find.byType(Center);
      expect(centerFinder, findsOneWidget);

      final columnWidget = tester.widget<Column>(find.byType(Column).first);
      expect(columnWidget.mainAxisAlignment, MainAxisAlignment.center);
      expect(columnWidget.crossAxisAlignment, CrossAxisAlignment.center);
    });

    testWidgets('text is center-aligned', (WidgetTester tester) async {
      // Arrange
      const title = 'Title';
      const message = 'Message';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: title,
              message: message,
            ),
          ),
        ),
      );

      // Assert
      final titleText = tester.widget<Text>(find.text(title));
      expect(titleText.textAlign, TextAlign.center);

      final messageText = tester.widget<Text>(find.text(message));
      expect(messageText.textAlign, TextAlign.center);
    });

    testWidgets('message has max 3 lines with ellipsis',
        (WidgetTester tester) async {
      // Arrange
      const longMessage = 'This is a very long message that should be truncated '
          'after three lines with ellipsis overflow behavior';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Title',
              message: longMessage,
            ),
          ),
        ),
      );

      // Assert
      final messageText = tester.widget<Text>(find.text(longMessage));
      expect(messageText.maxLines, 3);
      expect(messageText.overflow, TextOverflow.ellipsis);
    });

    testWidgets('CTA button has proper styling', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Title',
              message: 'Message',
              actionLabel: 'Create',
              onActionPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final buttonStyle = button.style!;

      // Check background color
      final backgroundColor =
          buttonStyle.backgroundColor?.resolve(<WidgetState>{});
      expect(backgroundColor, AppColors.primaryAmber);

      // Check foreground color
      final foregroundColor =
          buttonStyle.foregroundColor?.resolve(<WidgetState>{});
      expect(foregroundColor, AppColors.neutralBlack);
    });

    testWidgets('responds to different screen sizes',
        (WidgetTester tester) async {
      // Test mobile size
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(size: Size(400, 800)),
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

      final iconWidgetMobile = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidgetMobile.size, 80.0);

      // Test desktop size
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

      final iconWidgetDesktop = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidgetDesktop.size, 100.0);
    });

    testWidgets('CTA button has minimum touch target size',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Title',
              message: 'Message',
              actionLabel: 'Create',
              onActionPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final minimumSize = button.style!.minimumSize?.resolve(<WidgetState>{});

      expect(minimumSize, isNotNull);
      expect(minimumSize!.width, greaterThanOrEqualTo(44.0));
      expect(minimumSize.height, greaterThanOrEqualTo(44.0));
    });

    testWidgets('full integration with all features',
        (WidgetTester tester) async {
      // Arrange
      var actionCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox_outlined,
              title: 'No items yet',
              message: 'Create your first item to get started',
              actionLabel: 'Create Item',
              onActionPressed: () {
                actionCalled = true;
              },
            ),
          ),
        ),
      );

      // Assert - all elements present
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('No items yet'), findsOneWidget);
      expect(find.text('Create your first item to get started'), findsOneWidget);
      expect(find.text('Create Item'), findsOneWidget);

      // Tap action button
      await tester.tap(find.byType(ElevatedButton));
      expect(actionCalled, isTrue);
    });
  });
}
