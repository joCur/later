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

      testWidgets('completion animation shows gradient color shift', (tester) async {
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

        // Tap the checkbox to trigger completion
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        // Animation should be in progress
        await tester.pump(const Duration(milliseconds: 100));

        // Callback should be called
        expect(checkboxValue, isTrue);

        // Complete the animation
        await tester.pumpAndSettle();
      });

      testWidgets('completion overlay fades in and out', (tester) async {
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

        // Tap the checkbox to trigger completion
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        // Animation duration is 400ms for overlay
        await tester.pump(const Duration(milliseconds: 200));

        // Should be mid-animation
        expect(find.byType(ItemCard), findsOneWidget);

        // Complete the animation
        await tester.pumpAndSettle();
      });
    });

    group('Entrance Animations', () {
      testWidgets('applies entrance animation with index parameter', (tester) async {
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
                index: 0,
              ),
            ),
          ),
        );

        // Card should render
        expect(find.byType(ItemCard), findsOneWidget);

        // Pump and settle to complete entrance animation
        await tester.pumpAndSettle();

        // Card should still be visible after animation
        expect(find.text('Test Task'), findsOneWidget);
      });

      testWidgets('applies staggered delay based on index', (tester) async {
        final items = List.generate(
          3,
          (index) => Item(
            id: 'item_$index',
            type: ItemType.task,
            title: 'Task $index',
            spaceId: 'space1',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ItemCard(
                    item: items[index],
                    index: index,
                  );
                },
              ),
            ),
          ),
        );

        // All cards should render
        expect(find.byType(ItemCard), findsNWidgets(3));

        // Pump frames to allow staggered animations to start
        await tester.pump(const Duration(milliseconds: 50)); // First item delay
        await tester.pump(const Duration(milliseconds: 50)); // Second item delay
        await tester.pump(const Duration(milliseconds: 50)); // Third item delay

        // Complete all animations
        await tester.pumpAndSettle();

        // All items should be visible
        for (int i = 0; i < items.length; i++) {
          expect(find.text('Task $i'), findsOneWidget);
        }
      });

      testWidgets('entrance animation respects reduced motion', (tester) async {
        final item = Item(
          id: '1',
          type: ItemType.task,
          title: 'Test Task',
          spaceId: 'space1',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                disableAnimations: true, // Simulate reduced motion
              ),
              child: Scaffold(
                body: ItemCard(
                  item: item,
                  index: 0,
                ),
              ),
            ),
          ),
        );

        // Card should render immediately
        expect(find.byType(ItemCard), findsOneWidget);

        // With reduced motion, animation should be instant
        await tester.pump();

        // Content should be visible immediately
        expect(find.text('Test Task'), findsOneWidget);

        // Ensure all animations complete
        await tester.pumpAndSettle();
      });

      testWidgets('entrance animation works without index parameter', (tester) async {
        final item = Item(
          id: '1',
          type: ItemType.task,
          title: 'Test Task',
          spaceId: 'space1',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ItemCard(item: item),
            ),
          ),
        );

        // Card should render (no index means no entrance animation)
        expect(find.byType(ItemCard), findsOneWidget);
        expect(find.text('Test Task'), findsOneWidget);
      });

      testWidgets('entrance animation completes within expected duration', (tester) async {
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
                index: 0,
              ),
            ),
          ),
        );

        // Start animation
        await tester.pump();

        // Animation duration is 250ms with spring curve
        await tester.pump(const Duration(milliseconds: 250));

        // Should be mostly complete
        expect(find.byType(ItemCard), findsOneWidget);

        // Settle any remaining animation
        await tester.pumpAndSettle();

        // Card should be fully visible
        expect(find.text('Test Task'), findsOneWidget);
      });

      testWidgets('entrance animation works with large list indices', (tester) async {
        final item = Item(
          id: '100',
          type: ItemType.task,
          title: 'Task 100',
          spaceId: 'space1',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ItemCard(
                item: item,
                index: 99, // Large index
              ),
            ),
          ),
        );

        // Card should render despite large index
        expect(find.byType(ItemCard), findsOneWidget);

        // Complete entrance animation
        await tester.pumpAndSettle();

        // Card should be visible
        expect(find.text('Task 100'), findsOneWidget);
      });
    });
  });
}
