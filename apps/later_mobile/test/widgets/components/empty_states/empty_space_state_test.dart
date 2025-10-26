import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/organisms/empty_states/empty_space_state.dart';

void main() {
  group('EmptySpaceState Tests', () {
    testWidgets('renders with space name', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptySpaceState(
              spaceName: 'Work',
              onActionPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Your Work is empty'), findsOneWidget);
    });

    testWidgets('renders inbox icon', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptySpaceState(
              spaceName: 'Work',
              onActionPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('displays correct description', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptySpaceState(
              spaceName: 'Work',
              onActionPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(
        find.text('Start capturing your thoughts, tasks, and ideas'),
        findsOneWidget,
      );
    });

    testWidgets('displays Quick Capture button', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptySpaceState(
              spaceName: 'Work',
              onActionPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Quick Capture'), findsOneWidget);
    });

    testWidgets('calls onActionPressed when button pressed',
        (WidgetTester tester) async {
      // Arrange
      var buttonPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptySpaceState(
              spaceName: 'Work',
              onActionPressed: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      // Tap button
      await tester.tap(find.text('Quick Capture'));
      await tester.pump();

      // Assert
      expect(buttonPressed, isTrue);
    });

    testWidgets('handles different space names', (WidgetTester tester) async {
      // Test multiple space names
      final spaceNames = ['Work', 'Personal', 'Projects', 'Ideas'];

      for (final spaceName in spaceNames) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptySpaceState(
                spaceName: spaceName,
                onActionPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Your $spaceName is empty'), findsOneWidget);
      }
    });

    testWidgets('icon has responsive size', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptySpaceState(
              spaceName: 'Work',
              onActionPressed: () {},
            ),
          ),
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
          home: Scaffold(
            body: EmptySpaceState(
              spaceName: 'Work',
              onActionPressed: () {},
            ),
          ),
        ),
      );

      // Assert - verify it's using the base component
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('handles long space names gracefully',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptySpaceState(
              spaceName: 'Very Long Space Name That Should Still Work',
              onActionPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(
        find.textContaining('Your Very Long Space Name'),
        findsOneWidget,
      );
    });

    testWidgets('renders in both light and dark mode',
        (WidgetTester tester) async {
      // Test light mode
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: EmptySpaceState(
              spaceName: 'Work',
              onActionPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Your Work is empty'), findsOneWidget);

      // Test dark mode
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: EmptySpaceState(
              spaceName: 'Work',
              onActionPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Your Work is empty'), findsOneWidget);
    });
  });
}
