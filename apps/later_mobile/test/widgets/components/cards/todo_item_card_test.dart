import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/widgets/components/cards/todo_item_card.dart';
import 'package:later_mobile/data/models/todo_list_model.dart';
import 'package:later_mobile/core/theme/app_colors.dart';
import 'package:later_mobile/core/theme/app_animations.dart';

void main() {
  group('TodoItemCard', () {
    // Test data
    final testTodoItem = TodoItem(
      id: 'test-item-1',
      title: 'Complete project documentation',
      description: 'Write comprehensive docs',
      isCompleted: false,
      dueDate: DateTime(2025, 3, 15),
      priority: TodoPriority.high,
      tags: ['urgent', 'docs'],
      sortOrder: 0,
    );

    final completedTodoItem = TodoItem(
      id: 'test-item-2',
      title: 'Review pull request',
      isCompleted: true,
      sortOrder: 1,
    );

    final minimalTodoItem = TodoItem(
      id: 'test-item-3',
      title: 'Simple task',
      sortOrder: 2,
    );

    // Helper to wrap widget in MaterialApp for testing
    Widget makeTestableWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: child,
        ),
      );
    }

    group('Rendering', () {
      testWidgets('renders with TodoItem data', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: testTodoItem),
          ),
        );

        expect(find.byType(TodoItemCard), findsOneWidget);
      });

      testWidgets('displays title correctly', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: testTodoItem),
          ),
        );

        expect(find.text('Complete project documentation'), findsOneWidget);
      });

      testWidgets('shows checkbox with correct state when not completed', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: testTodoItem),
          ),
        );

        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, false);
      });

      testWidgets('shows checkbox with correct state when completed', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: completedTodoItem),
          ),
        );

        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, true);
      });

      testWidgets('shows strikethrough when completed', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: completedTodoItem),
          ),
        );

        final textWidget = tester.widget<Text>(
          find.text('Review pull request'),
        );
        expect(textWidget.style?.decoration, TextDecoration.lineThrough);
      });

      testWidgets('does not show strikethrough when not completed', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: testTodoItem),
          ),
        );

        final textWidget = tester.widget<Text>(
          find.text('Complete project documentation'),
        );
        expect(textWidget.style?.decoration, isNot(TextDecoration.lineThrough));
      });

      testWidgets('shows due date if present', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: testTodoItem),
          ),
        );

        // Should show "Mar 15" format
        expect(find.text('Mar 15'), findsOneWidget);
      });

      testWidgets('does not show due date if not present', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: minimalTodoItem),
          ),
        );

        // Should not show date text
        expect(find.byIcon(Icons.calendar_today), findsNothing);
      });

      testWidgets('shows priority badge for high priority', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: testTodoItem),
          ),
        );

        expect(find.text('HIGH'), findsOneWidget);
      });

      testWidgets('shows priority badge for medium priority', (tester) async {
        final mediumPriorityItem = testTodoItem.copyWith(priority: TodoPriority.medium);
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: mediumPriorityItem),
          ),
        );

        expect(find.text('MED'), findsOneWidget);
      });

      testWidgets('shows priority badge for low priority', (tester) async {
        final lowPriorityItem = testTodoItem.copyWith(priority: TodoPriority.low);
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: lowPriorityItem),
          ),
        );

        expect(find.text('LOW'), findsOneWidget);
      });

      testWidgets('does not show priority badge if priority is null', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: minimalTodoItem),
          ),
        );

        expect(find.text('HIGH'), findsNothing);
        expect(find.text('MED'), findsNothing);
        expect(find.text('LOW'), findsNothing);
      });

      testWidgets('shows reorder handle icon', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: testTodoItem),
          ),
        );

        expect(find.byIcon(Icons.drag_indicator), findsOneWidget);
      });

      testWidgets('renders with compact height', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: testTodoItem),
          ),
        );

        // Find the container (card should be 56-64px height)
        final box = tester.getSize(find.byType(TodoItemCard));
        expect(box.height, lessThan(80)); // Should be compact
      });
    });

    group('Priority Badge Colors', () {
      testWidgets('high priority badge has red background', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: testTodoItem),
          ),
        );

        // Find the priority badge container
        final badgeFinder = find.ancestor(
          of: find.text('HIGH'),
          matching: find.byType(Container),
        );

        expect(badgeFinder, findsWidgets);
        final container = tester.widget<Container>(badgeFinder.first);
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, AppColors.error);
      });

      testWidgets('medium priority badge has amber background', (tester) async {
        final mediumPriorityItem = testTodoItem.copyWith(priority: TodoPriority.medium);
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: mediumPriorityItem),
          ),
        );

        final badgeFinder = find.ancestor(
          of: find.text('MED'),
          matching: find.byType(Container),
        );

        expect(badgeFinder, findsWidgets);
        final container = tester.widget<Container>(badgeFinder.first);
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, AppColors.warning);
      });

      testWidgets('low priority badge has neutral background', (tester) async {
        final lowPriorityItem = testTodoItem.copyWith(priority: TodoPriority.low);
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: lowPriorityItem),
          ),
        );

        final badgeFinder = find.ancestor(
          of: find.text('LOW'),
          matching: find.byType(Container),
        );

        expect(badgeFinder, findsWidgets);
        final container = tester.widget<Container>(badgeFinder.first);
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, AppColors.neutral300);
      });
    });

    group('Interactions', () {
      testWidgets('onTap callback fires when card is tapped', (tester) async {
        bool tapped = false;
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(
              todoItem: testTodoItem,
              onTap: () => tapped = true,
            ),
          ),
        );

        await tester.tap(find.byType(TodoItemCard));
        await tester.pump();

        expect(tapped, true);
      });

      testWidgets('onCheckboxChanged callback fires when checkbox is tapped', (tester) async {
        bool? newValue;
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(
              todoItem: testTodoItem,
              onCheckboxChanged: (value) => newValue = value,
            ),
          ),
        );

        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        expect(newValue, true);
      });

      testWidgets('onCheckboxChanged callback receives correct value when toggling from completed', (tester) async {
        bool? newValue;
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(
              todoItem: completedTodoItem,
              onCheckboxChanged: (value) => newValue = value,
            ),
          ),
        );

        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        expect(newValue, false);
      });

      testWidgets('long press callback fires', (tester) async {
        bool longPressed = false;
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(
              todoItem: testTodoItem,
              onLongPress: () => longPressed = true,
            ),
          ),
        );

        await tester.longPress(find.byType(TodoItemCard));
        await tester.pump();

        expect(longPressed, true);
      });

      testWidgets('onTap toggles completion when no callback provided', (tester) async {
        bool? checkboxValue;
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(
              todoItem: testTodoItem,
              onCheckboxChanged: (value) => checkboxValue = value,
            ),
          ),
        );

        // Tap the card (not checkbox)
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pump();

        // Should trigger checkbox callback
        expect(checkboxValue, true);
      });
    });

    group('Accessibility', () {
      testWidgets('has correct semantic label for incomplete item', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: testTodoItem),
          ),
        );

        expect(
          find.bySemanticsLabel(RegExp('Complete project documentation.*not completed')),
          findsOneWidget,
        );
      });

      testWidgets('has correct semantic label for completed item', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: completedTodoItem),
          ),
        );

        expect(
          find.bySemanticsLabel(RegExp('Review pull request.*completed')),
          findsOneWidget,
        );
      });

      testWidgets('includes due date in semantic label if present', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: testTodoItem),
          ),
        );

        expect(
          find.bySemanticsLabel(RegExp('.*due.*Mar 15.*')),
          findsOneWidget,
        );
      });

      testWidgets('includes priority in semantic label if present', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: testTodoItem),
          ),
        );

        expect(
          find.bySemanticsLabel(RegExp('.*priority: high.*')),
          findsOneWidget,
        );
      });

      testWidgets('checkbox is marked as checkbox for screen readers', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: testTodoItem),
          ),
        );

        // Verify checkbox is present and accessible
        expect(find.byType(Checkbox), findsOneWidget);
      });
    });

    group('Visual States', () {
      testWidgets('shows hover state on desktop', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: testTodoItem),
          ),
        );

        // Find the gesture detector and hover
        final gesture = find.byType(GestureDetector).first;
        await tester.tap(gesture);
        await tester.pump();

        // Card should exist and not throw errors
        expect(find.byType(TodoItemCard), findsOneWidget);
      });

      testWidgets('applies reduced opacity when completed', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: completedTodoItem),
          ),
        );

        // The entire card should have reduced opacity
        final opacityFinder = find.ancestor(
          of: find.text('Review pull request'),
          matching: find.byType(Opacity),
        );

        expect(opacityFinder, findsWidgets);
        final opacity = tester.widget<Opacity>(opacityFinder.first);
        expect(opacity.opacity, AppColors.completedOpacity);
      });
    });

    group('Date Formatting', () {
      testWidgets('formats date correctly for current year', (tester) async {
        final item = testTodoItem.copyWith(
          dueDate: DateTime(DateTime.now().year, 6, 20),
        );

        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: item),
          ),
        );

        expect(find.text('Jun 20'), findsOneWidget);
      });

      testWidgets('formats date correctly for different month', (tester) async {
        final item = testTodoItem.copyWith(
          dueDate: DateTime(DateTime.now().year, 12, 5),
        );

        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: item),
          ),
        );

        expect(find.text('Dec 5'), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles empty title gracefully', (tester) async {
        final emptyTitleItem = TodoItem(
          id: 'empty',
          title: '',
          sortOrder: 0,
        );

        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: emptyTitleItem),
          ),
        );

        expect(find.byType(TodoItemCard), findsOneWidget);
      });

      testWidgets('handles very long title with ellipsis', (tester) async {
        final longTitleItem = TodoItem(
          id: 'long',
          title: 'This is a very long title that should be truncated with an ellipsis because it exceeds the maximum width available in the card',
          sortOrder: 0,
        );

        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: longTitleItem),
          ),
        );

        final textWidget = tester.widget<Text>(
          find.text(longTitleItem.title),
        );
        expect(textWidget.overflow, TextOverflow.ellipsis);
      });

      testWidgets('handles null callbacks gracefully', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: testTodoItem),
          ),
        );

        // Should not crash when tapping without callbacks
        await tester.tap(find.byType(TodoItemCard));
        await tester.pump();

        expect(find.byType(TodoItemCard), findsOneWidget);
      });
    });

    group('Layout', () {
      testWidgets('checkbox is on the left', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: testTodoItem),
          ),
        );

        final checkboxOffset = tester.getTopLeft(find.byType(Checkbox));
        final titleOffset = tester.getTopLeft(find.text(testTodoItem.title));

        expect(checkboxOffset.dx, lessThan(titleOffset.dx));
      });

      testWidgets('reorder handle is on the right', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: testTodoItem),
          ),
        );

        final handleOffset = tester.getTopRight(find.byIcon(Icons.drag_indicator));
        final titleOffset = tester.getTopRight(find.text(testTodoItem.title));

        expect(handleOffset.dx, greaterThan(titleOffset.dx));
      });

      testWidgets('priority badge is below title in metadata row', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: testTodoItem),
          ),
        );

        final titleOffset = tester.getCenter(find.text(testTodoItem.title));
        final badgeOffset = tester.getCenter(find.text('HIGH'));

        // Badge should be below the title (higher dy value)
        expect(badgeOffset.dy, greaterThan(titleOffset.dy));
      });
    });

    group('Performance', () {
      testWidgets('uses RepaintBoundary for optimization', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            TodoItemCard(todoItem: testTodoItem),
          ),
        );

        expect(find.byType(RepaintBoundary), findsWidgets);
      });
    });
  });
}
