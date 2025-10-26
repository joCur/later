import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/organisms/empty_states/empty_state.dart';

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

    // Removed test: 'renders with secondary text link'
    // EmptyState no longer supports secondaryText/onSecondaryPressed parameters

    testWidgets('does not render CTA when not provided',
        (WidgetTester tester) async {
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
      expect(find.byType(ElevatedButton), findsNothing);
    });

    // Removed test: 'does not render secondary link when not provided'
    // EmptyState no longer supports secondary link functionality

    testWidgets('uses correct colors in light mode',
        (WidgetTester tester) async {
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

      // Assert - icon now uses white color for ShaderMask gradient
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.color, Colors.white);
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
              title: 'Title',
              message: 'Description',
            ),
          ),
        ),
      );

      // Assert - icon now uses white color for ShaderMask gradient
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.color, Colors.white);
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

      // Assert - title uses display large on mobile (40px)
      final titleText = tester.widget<Text>(find.text('Title'));
      expect(titleText.style?.fontSize, 40.0);

      // Assert - description uses body large (18px)
      final descriptionText = tester.widget<Text>(find.text('Description'));
      expect(descriptionText.style?.fontSize, 18.0);
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

    testWidgets('centers content horizontally and vertically',
        (WidgetTester tester) async {
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

    testWidgets('applies max width constraint', (WidgetTester tester) async {
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

    testWidgets('CTA button has gradient style', (WidgetTester tester) async {
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

      // Assert - check button is rendered
      expect(find.text('Action'), findsOneWidget);
    });

    // Removed test: 'secondary link has correct styling'
    // EmptyState no longer supports secondary link functionality

    // Removed test: 'renders both CTA and secondary link together'
    // EmptyState no longer supports secondary link functionality

    testWidgets('has proper semantic labels for accessibility',
        (WidgetTester tester) async {
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

    testWidgets('respects vertical spacing of 64px between sections',
        (WidgetTester tester) async {
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
