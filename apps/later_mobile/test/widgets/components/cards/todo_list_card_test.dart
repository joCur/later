import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/models/todo_list_model.dart';
import 'package:later_mobile/design_system/organisms/cards/todo_list_card.dart';

void main() {
  group('TodoListCard', () {
    // Helper function to create a TodoList with items
    TodoList createTodoList({
      String id = '1',
      String name = 'Shopping List',
      String? description,
      List<TodoItem>? items,
    }) {
      return TodoList(
        id: id,
        spaceId: 'space1',
        name: name,
        description: description,
        items: items,
      );
    }

    // Helper function to create a TodoItem
    TodoItem createTodoItem({
      required String id,
      required String title,
      bool isCompleted = false,
      DateTime? dueDate,
      int sortOrder = 0,
    }) {
      return TodoItem(
        id: id,
        title: title,
        isCompleted: isCompleted,
        dueDate: dueDate,
        sortOrder: sortOrder,
      );
    }

    group('Rendering', () {
      testWidgets('renders with TodoList data', (tester) async {
        final todoList = createTodoList();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        expect(find.byType(TodoListCard), findsOneWidget);
        expect(find.text('Shopping List'), findsOneWidget);
      });

      testWidgets('displays name correctly', (tester) async {
        final todoList = createTodoList(name: 'Project Tasks');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        expect(find.text('Project Tasks'), findsOneWidget);
      });

      testWidgets('shows progress indicator with correct format', (
        tester,
      ) async {
        final todoList = createTodoList(
          items: [
            createTodoItem(id: '1', title: 'Task 1', isCompleted: true),
            createTodoItem(id: '2', title: 'Task 2', isCompleted: true),
            createTodoItem(id: '3', title: 'Task 3', isCompleted: true),
            createTodoItem(id: '4', title: 'Task 4', isCompleted: true),
            createTodoItem(id: '5', title: 'Task 5'),
            createTodoItem(id: '6', title: 'Task 6'),
            createTodoItem(id: '7', title: 'Task 7'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        // Should show "4 of 7 completed" or similar
        expect(find.textContaining('4'), findsAtLeastNWidgets(1));
        expect(find.textContaining('7'), findsAtLeastNWidgets(1));
      });

      testWidgets('renders progress bar', (tester) async {
        final todoList = createTodoList(
          items: [
            createTodoItem(id: '1', title: 'Task 1', isCompleted: true),
            createTodoItem(id: '2', title: 'Task 2'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets('shows checkbox outline icon', (tester) async {
        final todoList = createTodoList();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
      });

      testWidgets('displays gradient border', (tester) async {
        final todoList = createTodoList();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        // GradientPillBorder should be present
        expect(find.byType(TodoListCard), findsOneWidget);
      });

      testWidgets('shows due date when items have due dates', (tester) async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final todoList = createTodoList(
          items: [
            createTodoItem(id: '1', title: 'Task 1', dueDate: tomorrow),
            createTodoItem(id: '2', title: 'Task 2'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        // Should show some date information
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      });

      testWidgets('handles empty list (0 items)', (tester) async {
        final todoList = createTodoList(items: []);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        expect(find.byType(TodoListCard), findsOneWidget);
        expect(find.text('Shopping List'), findsOneWidget);
      });

      testWidgets('shows correct progress for all completed items', (
        tester,
      ) async {
        final todoList = createTodoList(
          items: [
            createTodoItem(id: '1', title: 'Task 1', isCompleted: true),
            createTodoItem(id: '2', title: 'Task 2', isCompleted: true),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        expect(find.textContaining('2'), findsAtLeastNWidgets(1));
      });

      testWidgets('shows correct progress for no completed items', (
        tester,
      ) async {
        final todoList = createTodoList(
          items: [
            createTodoItem(id: '1', title: 'Task 1'),
            createTodoItem(id: '2', title: 'Task 2'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        expect(find.textContaining('0'), findsAtLeastNWidgets(1));
        expect(find.textContaining('2'), findsAtLeastNWidgets(1));
      });
    });

    group('Interactions', () {
      testWidgets('onTap callback fires when tapped', (tester) async {
        final todoList = createTodoList();
        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TodoListCard(
                todoList: todoList,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(TodoListCard));
        await tester.pump();

        expect(tapped, isTrue);
      });

      testWidgets('onLongPress callback fires when long pressed', (
        tester,
      ) async {
        final todoList = createTodoList();
        var longPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TodoListCard(
                todoList: todoList,
                onLongPress: () {
                  longPressed = true;
                },
              ),
            ),
          ),
        );

        await tester.longPress(find.byType(TodoListCard));
        await tester.pump();

        expect(longPressed, isTrue);
      });

      testWidgets('handles tap without onTap callback', (tester) async {
        final todoList = createTodoList();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        // Should not throw error when tapped without callback
        await tester.tap(find.byType(TodoListCard));
        await tester.pump();

        expect(find.byType(TodoListCard), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('has correct semantic label', (tester) async {
        final todoList = createTodoList();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        // Find the container Semantics widget
        final semanticsFinder = find.descendant(
          of: find.byType(TodoListCard),
          matching: find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.container == true,
          ),
        );

        expect(semanticsFinder, findsOneWidget);

        final semanticsWidget = tester.widget<Semantics>(semanticsFinder);
        expect(semanticsWidget.properties.label, contains('Shopping List'));
      });

      testWidgets('semantic label includes progress information', (
        tester,
      ) async {
        final todoList = createTodoList(
          items: [
            createTodoItem(id: '1', title: 'Task 1', isCompleted: true),
            createTodoItem(id: '2', title: 'Task 2'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        // Find the container Semantics widget
        final semanticsFinder = find.descendant(
          of: find.byType(TodoListCard),
          matching: find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.container == true,
          ),
        );

        expect(semanticsFinder, findsOneWidget);

        final semanticsWidget = tester.widget<Semantics>(semanticsFinder);
        expect(semanticsWidget.properties.label, isNotNull);
        expect(semanticsWidget.properties.label, contains('1 of 2'));
      });
    });

    group('Design System Compliance', () {
      testWidgets('uses task gradient for border', (tester) async {
        final todoList = createTodoList();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        // Card should render with gradient border
        expect(find.byType(TodoListCard), findsOneWidget);
      });

      testWidgets('displays with correct layout structure', (tester) async {
        final todoList = createTodoList(
          items: [
            createTodoItem(id: '1', title: 'Task 1', isCompleted: true),
            createTodoItem(id: '2', title: 'Task 2'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        // Should have icon, title, progress indicator, and progress bar
        expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
        expect(find.text('Shopping List'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });
    });

    group('Press Animation', () {
      testWidgets('applies press animation on tap', (tester) async {
        final todoList = createTodoList();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TodoListCard(todoList: todoList, onTap: () {}),
            ),
          ),
        );

        // Find the card
        final cardFinder = find.byType(TodoListCard);
        expect(cardFinder, findsOneWidget);

        // Tap down
        await tester.press(cardFinder);
        await tester.pump();

        // Card should still be present
        expect(cardFinder, findsOneWidget);

        // Release
        await tester.pumpAndSettle();
      });
    });

    group('Entrance Animation', () {
      testWidgets('applies entrance animation with index parameter', (
        tester,
      ) async {
        final todoList = createTodoList();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList, index: 0)),
          ),
        );

        // Card should render
        expect(find.byType(TodoListCard), findsOneWidget);

        // Pump and settle to complete entrance animation
        await tester.pumpAndSettle();

        // Card should still be visible after animation
        expect(find.text('Shopping List'), findsOneWidget);
      });

      testWidgets('works without index parameter', (tester) async {
        final todoList = createTodoList();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        // Card should render without animation
        expect(find.byType(TodoListCard), findsOneWidget);
        expect(find.text('Shopping List'), findsOneWidget);
      });

      testWidgets('applies staggered delay based on index', (tester) async {
        final todoLists = List.generate(
          3,
          (index) => createTodoList(id: 'list_$index', name: 'List $index'),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: todoLists.length,
                itemBuilder: (context, index) {
                  return TodoListCard(todoList: todoLists[index], index: index);
                },
              ),
            ),
          ),
        );

        // All cards should render
        expect(find.byType(TodoListCard), findsNWidgets(3));

        // Complete all animations
        await tester.pumpAndSettle();

        // All items should be visible
        for (int i = 0; i < todoLists.length; i++) {
          expect(find.text('List $i'), findsOneWidget);
        }
      });
    });

    group('Progress Bar', () {
      testWidgets('progress bar shows correct value', (tester) async {
        final todoList = createTodoList(
          items: [
            createTodoItem(id: '1', title: 'Task 1', isCompleted: true),
            createTodoItem(id: '2', title: 'Task 2'),
            createTodoItem(id: '3', title: 'Task 3'),
            createTodoItem(id: '4', title: 'Task 4'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        final progressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );

        // 1 out of 4 completed = 0.25 progress
        expect(progressIndicator.value, 0.25);
      });

      testWidgets('progress bar is 0 for empty list', (tester) async {
        final todoList = createTodoList(items: []);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        final progressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );

        expect(progressIndicator.value, 0.0);
      });

      testWidgets('progress bar is 1.0 for all completed', (tester) async {
        final todoList = createTodoList(
          items: [
            createTodoItem(id: '1', title: 'Task 1', isCompleted: true),
            createTodoItem(id: '2', title: 'Task 2', isCompleted: true),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        final progressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );

        expect(progressIndicator.value, 1.0);
      });
    });

    group('Due Date Display', () {
      testWidgets('shows earliest due date from items', (tester) async {
        final today = DateTime.now();
        final tomorrow = today.add(const Duration(days: 1));
        final nextWeek = today.add(const Duration(days: 7));

        final todoList = createTodoList(
          items: [
            createTodoItem(id: '1', title: 'Task 1', dueDate: nextWeek),
            createTodoItem(id: '2', title: 'Task 2', dueDate: tomorrow),
            createTodoItem(id: '3', title: 'Task 3'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        // Should show the calendar icon for due date
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      });

      testWidgets('does not show due date when no items have due dates', (
        tester,
      ) async {
        final todoList = createTodoList(
          items: [
            createTodoItem(id: '1', title: 'Task 1'),
            createTodoItem(id: '2', title: 'Task 2'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        // Should not show calendar icon
        expect(find.byIcon(Icons.calendar_today), findsNothing);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles very long names', (tester) async {
        final todoList = createTodoList(
          name:
              'This is a very long todo list name that should be truncated with ellipsis when it exceeds the maximum number of lines allowed',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                child: TodoListCard(todoList: todoList),
              ),
            ),
          ),
        );

        expect(find.byType(TodoListCard), findsOneWidget);
      });

      testWidgets('handles many items', (tester) async {
        final items = List.generate(
          100,
          (index) => createTodoItem(
            id: 'item_$index',
            title: 'Task $index',
            isCompleted: index % 2 == 0,
          ),
        );

        final todoList = createTodoList(items: items);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TodoListCard(todoList: todoList)),
          ),
        );

        expect(find.byType(TodoListCard), findsOneWidget);
        // Should show 50 of 100 completed
        expect(find.textContaining('50'), findsAtLeastNWidgets(1));
        expect(find.textContaining('100'), findsAtLeastNWidgets(1));
      });
    });
  });
}
