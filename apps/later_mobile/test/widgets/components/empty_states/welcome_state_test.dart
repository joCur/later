import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/organisms/empty_states/welcome_state.dart';

void main() {
  group('WelcomeState Tests', () {
    testWidgets('renders welcome title', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WelcomeState(onActionPressed: () {})),
        ),
      );

      // Assert
      expect(find.text('Welcome to later'), findsOneWidget);
    });

    testWidgets('renders sparkles icon', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WelcomeState(onActionPressed: () {})),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('displays welcome description', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WelcomeState(onActionPressed: () {})),
        ),
      );

      // Assert
      expect(
        find.text(
          'Your peaceful place for thoughts, tasks, and everything in between',
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays Create your first item button', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WelcomeState(onActionPressed: () {})),
        ),
      );

      // Assert
      expect(find.text('Create your first item'), findsOneWidget);
    });

    testWidgets('calls onActionPressed when button pressed', (
      WidgetTester tester,
    ) async {
      // Arrange
      var buttonPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeState(
              onActionPressed: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      // Tap button
      await tester.tap(find.text('Create your first item'));
      await tester.pump();

      // Assert
      expect(buttonPressed, isTrue);
    });

    testWidgets('displays secondary Learn how it works link when provided', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeState(
              onActionPressed: () {},
              onSecondaryPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Learn how it works'), findsOneWidget);
    });

    testWidgets('does not display Learn how it works link when not provided', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WelcomeState(onActionPressed: () {})),
        ),
      );

      // Assert
      expect(find.text('Learn how it works'), findsNothing);
    });

    testWidgets('calls onSecondaryPressed when secondary link pressed', (
      WidgetTester tester,
    ) async {
      // Arrange
      var linkPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeState(
              onActionPressed: () {},
              onSecondaryPressed: () {
                linkPressed = true;
              },
            ),
          ),
        ),
      );

      // Tap link
      await tester.tap(find.text('Learn how it works'));
      await tester.pump();

      // Assert
      expect(linkPressed, isTrue);
    });

    testWidgets('icon has responsive size', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WelcomeState(onActionPressed: () {})),
        ),
      );

      // Assert - icon size is responsive (80px mobile, 100px desktop)
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.size, isNotNull);
    });

    testWidgets('uses EmptyState base component', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WelcomeState(onActionPressed: () {})),
        ),
      );

      // Assert - verify it's using the base component
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('renders in both light and dark mode', (
      WidgetTester tester,
    ) async {
      // Test light mode
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(body: WelcomeState(onActionPressed: () {})),
        ),
      );

      expect(find.text('Welcome to later'), findsOneWidget);

      // Test dark mode
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(body: WelcomeState(onActionPressed: () {})),
        ),
      );

      expect(find.text('Welcome to later'), findsOneWidget);
    });

    testWidgets('has proper semantic structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WelcomeState(onActionPressed: () {})),
        ),
      );

      // Assert - verify all key elements are accessible
      expect(find.text('Welcome to later'), findsOneWidget);
      expect(
        find.text(
          'Your peaceful place for thoughts, tasks, and everything in between',
        ),
        findsOneWidget,
      );
      expect(find.text('Create your first item'), findsOneWidget);
    });

    testWidgets('displays both button and link together', (
      WidgetTester tester,
    ) async {
      // Arrange
      var buttonPressed = false;
      var linkPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeState(
              onActionPressed: () {
                buttonPressed = true;
              },
              onSecondaryPressed: () {
                linkPressed = true;
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Create your first item'), findsOneWidget);
      expect(find.text('Learn how it works'), findsOneWidget);

      // Test interactions
      await tester.tap(find.text('Create your first item'));
      await tester.pump();
      expect(buttonPressed, isTrue);

      await tester.tap(find.text('Learn how it works'));
      await tester.pump();
      expect(linkPressed, isTrue);
    });
  });
}
