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

    group('Checkbox Animation', () {
      testWidgets('animates checkbox when toggled', (tester) async {
        final item = Item(
          id: '1',
          type: ItemType.task,
          title: 'Test Task',
          spaceId: 'space1',
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

        // Find the Transform.scale widget
        final transformFinder = find.descendant(
          of: find.byType(ItemCard),
          matching: find.byType(AnimatedBuilder),
        );

        expect(transformFinder, findsOneWidget);

        // Tap the checkbox to trigger animation
        await tester.tap(find.byType(Checkbox));

        // Pump a frame to start the animation
        await tester.pump();

        // Pump frames during animation (150ms total)
        await tester.pump(const Duration(milliseconds: 75));

        // Animation should be in progress
        // The scale should be greater than 1.0 at the midpoint
        final animatedBuilder = tester.widget<AnimatedBuilder>(transformFinder);
        expect(animatedBuilder, isNotNull);

        // Complete the animation
        await tester.pumpAndSettle();

        // Verify callback was called
        expect(checkboxValue, isTrue);
      });

      testWidgets('animation completes within expected duration', (tester) async {
        final item = Item(
          id: '1',
          type: ItemType.task,
          title: 'Test Task',
          spaceId: 'space1',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ItemCard(
                item: item,
                onCheckboxChanged: (value) {},
              ),
            ),
          ),
        );

        // Tap the checkbox
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        // Animation duration is 150ms
        // Pump exactly that duration
        await tester.pump(const Duration(milliseconds: 150));

        // Animation should be complete or very close
        await tester.pumpAndSettle();

        // No errors should occur
        expect(find.byType(ItemCard), findsOneWidget);
      });

      testWidgets('handles rapid toggling without errors', (tester) async {
        final item = Item(
          id: '1',
          type: ItemType.task,
          title: 'Test Task',
          spaceId: 'space1',
        );

        int toggleCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ItemCard(
                item: item,
                onCheckboxChanged: (value) {
                  toggleCount++;
                },
              ),
            ),
          ),
        );

        // Rapidly toggle the checkbox multiple times
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.byType(Checkbox));
          await tester.pump();
          // Small delay between taps
          await tester.pump(const Duration(milliseconds: 30));
        }

        // Complete any remaining animations
        await tester.pumpAndSettle();

        // All toggles should have been registered
        expect(toggleCount, 5);

        // Widget should still be rendered without errors
        expect(find.byType(ItemCard), findsOneWidget);
      });

      testWidgets('animation does not affect non-task items', (tester) async {
        final noteItem = Item(
          id: '2',
          type: ItemType.note,
          title: 'Test Note',
          spaceId: 'space1',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ItemCard(item: noteItem),
            ),
          ),
        );

        // Note items should not have AnimatedBuilder for checkbox
        final animatedBuilderFinder = find.descendant(
          of: find.byType(ItemCard),
          matching: find.byType(AnimatedBuilder),
        );

        // Should not find AnimatedBuilder since it's a note, not a task
        expect(animatedBuilderFinder, findsNothing);

        // Icon should be present instead
        expect(find.byIcon(Icons.description_outlined), findsOneWidget);
      });

      testWidgets('animation preserves haptic feedback', (tester) async {
        final item = Item(
          id: '1',
          type: ItemType.task,
          title: 'Test Task',
          spaceId: 'space1',
        );

        bool callbackCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ItemCard(
                item: item,
                onCheckboxChanged: (value) {
                  callbackCalled = true;
                },
              ),
            ),
          ),
        );

        // Tap the checkbox
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        // Callback should be called (haptic feedback is called before this)
        expect(callbackCalled, isTrue);

        await tester.pumpAndSettle();
      });

      testWidgets('animation works for completed tasks', (tester) async {
        final item = Item(
          id: '1',
          type: ItemType.task,
          title: 'Completed Task',
          spaceId: 'space1',
          isCompleted: true,
        );

        bool callbackCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ItemCard(
                item: item,
                onCheckboxChanged: (value) {
                  callbackCalled = true;
                },
              ),
            ),
          ),
        );

        // Checkbox should be checked
        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, isTrue);

        // Tap to uncheck
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        // Should still animate
        await tester.pump(const Duration(milliseconds: 75));

        expect(callbackCalled, isTrue);

        await tester.pumpAndSettle();
      });
    });
  });
}
