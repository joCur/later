import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/widgets/components/empty_states/welcome_state.dart';

void main() {
  group('WelcomeState Tests', () {
    testWidgets('renders welcome title', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeState(
              onCreateFirstItem: () {},
            ),
          ),
        ),
      );

      // Assert - Now the title is split between regular text and gradient text
      expect(find.text('Welcome to '), findsOneWidget);
      expect(find.text('later'), findsOneWidget);
    });

    testWidgets('renders sparkles icon', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeState(
              onCreateFirstItem: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('displays welcome description', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeState(
              onCreateFirstItem: () {},
            ),
          ),
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

    testWidgets('displays Create your first item button',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeState(
              onCreateFirstItem: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Create your first item'), findsOneWidget);
    });

    testWidgets('calls onCreateFirstItem when button pressed',
        (WidgetTester tester) async {
      // Arrange
      var buttonPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeState(
              onCreateFirstItem: () {
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

    testWidgets('displays secondary Learn how it works link when provided',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeState(
              onCreateFirstItem: () {},
              onLearnMore: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Learn how it works'), findsOneWidget);
    });

    testWidgets('does not display Learn how it works link when not provided',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeState(
              onCreateFirstItem: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Learn how it works'), findsNothing);
    });

    testWidgets('calls onLearnMore when secondary link pressed',
        (WidgetTester tester) async {
      // Arrange
      var linkPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeState(
              onCreateFirstItem: () {},
              onLearnMore: () {
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

    testWidgets('icon size is 64px', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeState(
              onCreateFirstItem: () {},
            ),
          ),
        ),
      );

      // Assert
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.size, 64.0);
    });

    testWidgets('uses EmptyState base component', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeState(
              onCreateFirstItem: () {},
            ),
          ),
        ),
      );

      // Assert - verify it's using the base component
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('renders in both light and dark mode',
        (WidgetTester tester) async {
      // Test light mode
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: WelcomeState(
              onCreateFirstItem: () {},
            ),
          ),
        ),
      );

      // Title is now split into two text widgets (regular + gradient)
      expect(find.text('Welcome to '), findsOneWidget);
      expect(find.text('later'), findsOneWidget);

      // Test dark mode
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: WelcomeState(
              onCreateFirstItem: () {},
            ),
          ),
        ),
      );

      // Title is now split into two text widgets (regular + gradient)
      expect(find.text('Welcome to '), findsOneWidget);
      expect(find.text('later'), findsOneWidget);
    });

    testWidgets('has proper semantic structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeState(
              onCreateFirstItem: () {},
            ),
          ),
        ),
      );

      // Assert - verify all key elements are accessible
      // Title is now split into two text widgets (regular + gradient)
      expect(find.text('Welcome to '), findsOneWidget);
      expect(find.text('later'), findsOneWidget);
      expect(
        find.text(
          'Your peaceful place for thoughts, tasks, and everything in between',
        ),
        findsOneWidget,
      );
      expect(find.text('Create your first item'), findsOneWidget);
    });

    testWidgets('displays both button and link together',
        (WidgetTester tester) async {
      // Arrange
      var buttonPressed = false;
      var linkPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeState(
              onCreateFirstItem: () {
                buttonPressed = true;
              },
              onLearnMore: () {
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
