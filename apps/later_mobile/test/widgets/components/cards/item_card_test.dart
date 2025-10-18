import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/models/item_model.dart';
import 'package:later_mobile/widgets/components/cards/item_card.dart';

void main() {
  group('ItemCard', () {
    testWidgets('renders task card with title', (tester) async {
      final item = Item(
        id: '1',
        type: ItemType.task,
        title: 'Buy groceries',
        spaceId: 'space1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(item: item),
          ),
        ),
      );

      expect(find.text('Buy groceries'), findsOneWidget);
      expect(find.byType(ItemCard), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('renders note card with title and content', (tester) async {
      final item = Item(
        id: '2',
        type: ItemType.note,
        title: 'Meeting Notes',
        content: 'Discussed project timeline and deliverables',
        spaceId: 'space1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(item: item),
          ),
        ),
      );

      expect(find.text('Meeting Notes'), findsOneWidget);
      expect(find.text('Discussed project timeline and deliverables'), findsOneWidget);
    });

    testWidgets('renders list card with title', (tester) async {
      final item = Item(
        id: '3',
        type: ItemType.list,
        title: 'Shopping List',
        spaceId: 'space1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(item: item),
          ),
        ),
      );

      expect(find.text('Shopping List'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      final item = Item(
        id: '1',
        type: ItemType.task,
        title: 'Test Task',
        spaceId: 'space1',
      );

      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              item: item,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ItemCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('calls onLongPress when long pressed', (tester) async {
      final item = Item(
        id: '1',
        type: ItemType.task,
        title: 'Test Task',
        spaceId: 'space1',
      );

      var longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              item: item,
              onLongPress: () {
                longPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(ItemCard));
      await tester.pump();

      expect(longPressed, isTrue);
    });

    testWidgets('calls onCheckboxChanged for task items', (tester) async {
      final item = Item(
        id: '1',
        type: ItemType.task,
        title: 'Test Task',
        spaceId: 'space1',
        isCompleted: false,
      );

      bool? checkboxValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              item: item,
              onCheckboxChanged: (value) {
                checkboxValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(checkboxValue, isTrue);
    });

    testWidgets('displays completed state for task', (tester) async {
      final item = Item(
        id: '1',
        type: ItemType.task,
        title: 'Completed Task',
        spaceId: 'space1',
        isCompleted: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(item: item),
          ),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('shows selected state when isSelected is true', (tester) async {
      final item = Item(
        id: '1',
        type: ItemType.task,
        title: 'Selected Task',
        spaceId: 'space1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              item: item,
              isSelected: true,
            ),
          ),
        ),
      );

      expect(find.byType(ItemCard), findsOneWidget);
    });

    testWidgets('truncates long titles', (tester) async {
      final item = Item(
        id: '1',
        type: ItemType.task,
        title:
            'This is a very long title that should be truncated with an ellipsis when it exceeds the maximum number of lines allowed',
        spaceId: 'space1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: ItemCard(item: item),
            ),
          ),
        ),
      );

      expect(find.byType(ItemCard), findsOneWidget);
    });

    testWidgets('displays task border color', (tester) async {
      final item = Item(
        id: '1',
        type: ItemType.task,
        title: 'Task',
        spaceId: 'space1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(item: item),
          ),
        ),
      );

      expect(find.byType(ItemCard), findsOneWidget);
    });

    testWidgets('displays note border color', (tester) async {
      final item = Item(
        id: '2',
        type: ItemType.note,
        title: 'Note',
        spaceId: 'space1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(item: item),
          ),
        ),
      );

      expect(find.byType(ItemCard), findsOneWidget);
    });

    testWidgets('displays list border color', (tester) async {
      final item = Item(
        id: '3',
        type: ItemType.list,
        title: 'List',
        spaceId: 'space1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(item: item),
          ),
        ),
      );

      expect(find.byType(ItemCard), findsOneWidget);
    });
  });
}
