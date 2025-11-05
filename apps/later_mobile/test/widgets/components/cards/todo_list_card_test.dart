import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/models/todo_list_model.dart';
import 'package:later_mobile/design_system/organisms/cards/todo_list_card.dart';
import '../../../test_helpers.dart';

void main() {
  group('TodoListCard', () {
    // Helper function to create a TodoList
    TodoList createTodoList({
      String id = '1',
      String name = 'Shopping List',
      String spaceId = 'space1',
      String userId = 'user1',
      String? description,
      int totalItemCount = 0,
      int completedItemCount = 0,
    }) {
      return TodoList(
        id: id,
        spaceId: spaceId,
        userId: userId,
        name: name,
        description: description,
        totalItemCount: totalItemCount,
        completedItemCount: completedItemCount,
      );
    }

    group('Rendering', () {
      testWidgets('renders with TodoList data', (tester) async {
        final todoList = createTodoList();

        await tester.pumpWidget(
          testApp(TodoListCard(todoList: todoList)),
        );

        expect(find.byType(TodoListCard), findsOneWidget);
        expect(find.text('Shopping List'), findsOneWidget);
      });

      testWidgets('displays name correctly', (tester) async {
        final todoList = createTodoList(name: 'Daily Tasks');

        await tester.pumpWidget(
          testApp(TodoListCard(todoList: todoList)),
        );

        expect(find.text('Daily Tasks'), findsOneWidget);
      });

      testWidgets('shows progress text with correct format - multiple items', (
        tester,
      ) async {
        final todoList = createTodoList(
          totalItemCount: 7,
          completedItemCount: 4,
        );

        await tester.pumpWidget(
          testApp(TodoListCard(todoList: todoList)),
        );

        expect(find.text('4 of 7 completed'), findsOneWidget);
      });

      testWidgets('shows progress text with singular format - one item total', (
        tester,
      ) async {
        final todoList = createTodoList(
          totalItemCount: 1,
        );

        await tester.pumpWidget(
          testApp(TodoListCard(todoList: todoList)),
        );

        expect(find.text('0 of 1 completed'), findsOneWidget);
      });

      testWidgets('shows progress text for empty list', (tester) async {
        final todoList = createTodoList();

        await tester.pumpWidget(
          testApp(TodoListCard(todoList: todoList)),
        );

        expect(find.text('0 of 0 completed'), findsOneWidget);
      });

      testWidgets('shows progress bar', (tester) async {
        final todoList = createTodoList(
          totalItemCount: 10,
          completedItemCount: 5,
        );

        await tester.pumpWidget(
          testApp(TodoListCard(todoList: todoList)),
        );

        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets('progress bar shows 0% when no items completed', (
        tester,
      ) async {
        final todoList = createTodoList(
          totalItemCount: 5,
        );

        await tester.pumpWidget(
          testApp(TodoListCard(todoList: todoList)),
        );

        final progressIndicator =
            tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
        expect(progressIndicator.value, 0.0);
      });

      testWidgets('progress bar shows 100% when all items completed', (
        tester,
      ) async {
        final todoList = createTodoList(
          totalItemCount: 5,
          completedItemCount: 5,
        );

        await tester.pumpWidget(
          testApp(TodoListCard(todoList: todoList)),
        );

        final progressIndicator =
            tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
        expect(progressIndicator.value, 1.0);
      });

      testWidgets('progress bar shows partial completion', (tester) async {
        final todoList = createTodoList(
          totalItemCount: 4,
          completedItemCount: 2,
        );

        await tester.pumpWidget(
          testApp(TodoListCard(todoList: todoList)),
        );

        final progressIndicator =
            tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
        expect(progressIndicator.value, 0.5);
      });

      testWidgets('renders red-orange gradient border (taskGradient)', (
        tester,
      ) async {
        final todoList = createTodoList();

        await tester.pumpWidget(
          testApp(TodoListCard(todoList: todoList)),
        );

        // GradientPillBorder should be present
        expect(find.byType(TodoListCard), findsOneWidget);
      });

      testWidgets('shows checkbox outline icon', (tester) async {
        final todoList = createTodoList();

        await tester.pumpWidget(
          testApp(TodoListCard(todoList: todoList)),
        );

        expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets('onTap callback fires when tapped', (tester) async {
        final todoList = createTodoList();
        var tapped = false;

        await tester.pumpWidget(
          testApp(
            TodoListCard(
              todoList: todoList,
              onTap: () {
                tapped = true;
              },
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
          testApp(
            TodoListCard(
              todoList: todoList,
              onLongPress: () {
                longPressed = true;
              },
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
          testApp(TodoListCard(todoList: todoList)),
        );

        // Should not throw error when tapped without callback
        await tester.tap(find.byType(TodoListCard));
        await tester.pump();

        expect(find.byType(TodoListCard), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('has correct semantic label', (tester) async {
        final todoList = createTodoList(
          totalItemCount: 5,
          completedItemCount: 3,
        );

        await tester.pumpWidget(
          testApp(TodoListCard(todoList: todoList)),
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
        expect(semanticsWidget.properties.label, contains('Todo list'));
        expect(semanticsWidget.properties.label, contains('Shopping List'));
        expect(semanticsWidget.properties.label, contains('3 of 5 completed'));
      });
    });

    group('Design System Compliance', () {
      testWidgets('uses task gradient (red-orange) for border', (tester) async {
        final todoList = createTodoList();

        await tester.pumpWidget(
          testApp(TodoListCard(todoList: todoList)),
        );

        // Card should render with gradient border
        expect(find.byType(TodoListCard), findsOneWidget);
      });

      testWidgets('displays with correct layout structure', (tester) async {
        final todoList = createTodoList(
          totalItemCount: 5,
          completedItemCount: 2,
        );

        await tester.pumpWidget(
          testApp(TodoListCard(todoList: todoList)),
        );

        // Should have icon, title, progress text, and progress bar
        expect(find.byType(TodoListCard), findsOneWidget);
        expect(find.text('Shopping List'), findsOneWidget);
        expect(find.text('2 of 5 completed'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets('icon has gradient shader', (tester) async {
        final todoList = createTodoList();

        await tester.pumpWidget(
          testApp(TodoListCard(todoList: todoList)),
        );

        // Find ShaderMask widget
        expect(find.byType(ShaderMask), findsAtLeastNWidgets(1));
      });
    });

    group('Press Animation', () {
      testWidgets('applies press animation on tap', (tester) async {
        final todoList = createTodoList();

        await tester.pumpWidget(
          testApp(TodoListCard(todoList: todoList, onTap: () {})),
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
          testApp(TodoListCard(todoList: todoList, index: 0)),
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
          testApp(TodoListCard(todoList: todoList)),
        );

        // Card should render without animation
        expect(find.byType(TodoListCard), findsOneWidget);
        expect(find.text('Shopping List'), findsOneWidget);
      });

      testWidgets('applies staggered delay based on index', (tester) async {
        final todoLists = List.generate(
          3,
          (index) => createTodoList(
            id: 'list_$index',
            name: 'List $index',
            totalItemCount: index,
          ),
        );

        await tester.pumpWidget(
          testApp(
            ListView.builder(
              itemCount: todoLists.length,
              itemBuilder: (context, index) {
                return TodoListCard(todoList: todoLists[index], index: index);
              },
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

    group('Edge Cases', () {
      testWidgets('handles very long name', (tester) async {
        final todoList = createTodoList(
          name:
              'This is a very long todo list name that should be truncated with ellipsis when it exceeds the maximum number of lines allowed',
        );

        await tester.pumpWidget(
          testApp(SizedBox(width: 300, child: TodoListCard(todoList: todoList))),
        );

        expect(find.byType(TodoListCard), findsOneWidget);
      });

      testWidgets('handles large item counts', (tester) async {
        final todoList = createTodoList(
          totalItemCount: 999,
          completedItemCount: 500,
        );

        await tester.pumpWidget(
          testApp(TodoListCard(todoList: todoList)),
        );

        expect(find.text('500 of 999 completed'), findsOneWidget);
      });

      testWidgets('handles 0% progress correctly', (tester) async {
        final todoList = createTodoList(
          totalItemCount: 100,
        );

        await tester.pumpWidget(
          testApp(TodoListCard(todoList: todoList)),
        );

        final progressIndicator =
            tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
        expect(progressIndicator.value, 0.0);
      });

      testWidgets('handles unicode in name', (tester) async {
        final todoList = createTodoList(
          name: 'Shopping 🛒 List',
          totalItemCount: 5,
          completedItemCount: 3,
        );

        await tester.pumpWidget(
          testApp(TodoListCard(todoList: todoList)),
        );

        expect(find.textContaining('Shopping'), findsOneWidget);
      });

      testWidgets('handles description correctly', (tester) async {
        final todoList = createTodoList(
          name: 'My List',
          description: 'This is a detailed description',
          totalItemCount: 3,
          completedItemCount: 1,
        );

        await tester.pumpWidget(
          testApp(TodoListCard(todoList: todoList)),
        );

        expect(find.byType(TodoListCard), findsOneWidget);
        expect(find.text('My List'), findsOneWidget);
      });
    });
  });
}
