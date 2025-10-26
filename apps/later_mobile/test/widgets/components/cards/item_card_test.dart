import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/models/item_model.dart';
import 'package:later_mobile/widgets/components/cards/item_card.dart';

void main() {
  group('ItemCard', () {
    testWidgets('renders task card with title', (tester) async {
      final item = Item(
        id: '1',
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

    // NOTE: onCheckboxChanged tests removed - ItemCard is now Notes-only in dual-model architecture
    // TodoItem and ListItem have their own dedicated card components with checkbox functionality

    testWidgets('shows selected state when isSelected is true', (tester) async {
      final item = Item(
        id: '1',
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

    // NOTE: 'Checkbox Animation' test group removed - ItemCard is now Notes-only in dual-model architecture
    // Checkbox animations are tested in TodoItemCard and ListItemCard test suites

    group('Entrance Animations', () {
      testWidgets('applies entrance animation with index parameter', (tester) async {
        final item = Item(
          id: '1',
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
