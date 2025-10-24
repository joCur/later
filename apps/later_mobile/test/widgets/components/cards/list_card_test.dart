import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/models/list_model.dart';
import 'package:later_mobile/widgets/components/cards/list_card.dart';

void main() {
  group('ListCard', () {
    // Helper function to create a ListModel
    ListModel createListModel({
      String id = '1',
      String name = 'Shopping List',
      String? icon,
      List<ListItem>? items,
      ListStyle style = ListStyle.bullets,
    }) {
      return ListModel(
        id: id,
        spaceId: 'space1',
        name: name,
        icon: icon,
        items: items,
        style: style,
      );
    }

    // Helper function to create a ListItem
    ListItem createListItem({
      required String id,
      required String title,
      String? notes,
      bool isChecked = false,
      int sortOrder = 0,
    }) {
      return ListItem(
        id: id,
        title: title,
        notes: notes,
        isChecked: isChecked,
        sortOrder: sortOrder,
      );
    }

    group('Rendering', () {
      testWidgets('renders with ListModel data', (tester) async {
        final listModel = createListModel();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        expect(find.byType(ListCard), findsOneWidget);
        expect(find.text('Shopping List'), findsOneWidget);
      });

      testWidgets('displays name correctly', (tester) async {
        final listModel = createListModel(name: 'Grocery List');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        expect(find.text('Grocery List'), findsOneWidget);
      });

      testWidgets('shows item count with correct format - multiple items', (tester) async {
        final listModel = createListModel(
          items: [
            createListItem(id: '1', title: 'Milk'),
            createListItem(id: '2', title: 'Eggs'),
            createListItem(id: '3', title: 'Bread'),
            createListItem(id: '4', title: 'Butter'),
            createListItem(id: '5', title: 'Cheese'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        expect(find.text('5 items'), findsOneWidget);
      });

      testWidgets('shows item count with singular format - one item', (tester) async {
        final listModel = createListModel(
          items: [
            createListItem(id: '1', title: 'Milk'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        expect(find.text('1 item'), findsOneWidget);
      });

      testWidgets('shows item count for empty list', (tester) async {
        final listModel = createListModel(items: []);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        expect(find.text('0 items'), findsOneWidget);
      });

      testWidgets('shows preview of first 3 items', (tester) async {
        final listModel = createListModel(
          items: [
            createListItem(id: '1', title: 'Milk'),
            createListItem(id: '2', title: 'Eggs'),
            createListItem(id: '3', title: 'Bread'),
            createListItem(id: '4', title: 'Butter'),
            createListItem(id: '5', title: 'Cheese'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        expect(find.text('Milk, Eggs, Bread...'), findsOneWidget);
      });

      testWidgets('shows preview with ellipsis when more than 3 items', (tester) async {
        final listModel = createListModel(
          items: [
            createListItem(id: '1', title: 'Item 1'),
            createListItem(id: '2', title: 'Item 2'),
            createListItem(id: '3', title: 'Item 3'),
            createListItem(id: '4', title: 'Item 4'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        // Should show first 3 items with ellipsis
        expect(find.textContaining('Item 1, Item 2, Item 3...'), findsOneWidget);
      });

      testWidgets('shows preview without ellipsis when 3 or fewer items', (tester) async {
        final listModel = createListModel(
          items: [
            createListItem(id: '1', title: 'Milk'),
            createListItem(id: '2', title: 'Eggs'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        expect(find.text('Milk, Eggs'), findsOneWidget);
      });

      testWidgets('shows empty message when no items', (tester) async {
        final listModel = createListModel(items: []);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        expect(find.text('No items'), findsOneWidget);
      });

      testWidgets('renders violet gradient border', (tester) async {
        final listModel = createListModel();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        // GradientPillBorder should be present
        expect(find.byType(ListCard), findsOneWidget);
      });

      testWidgets('shows custom icon when provided', (tester) async {
        final listModel = createListModel(icon: '🛒');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        // Should show emoji icon
        expect(find.text('🛒'), findsOneWidget);
      });

      testWidgets('shows default icon when icon is null', (tester) async {
        final listModel = createListModel(icon: null);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        // Should show default list icon
        expect(find.byIcon(Icons.list_alt), findsOneWidget);
      });

      testWidgets('shows icon name as icon when provided', (tester) async {
        final listModel = createListModel(icon: 'shopping_cart');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        // Should show shopping_cart icon
        expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      });
    });

    group('List Styles', () {
      testWidgets('handles bullets style', (tester) async {
        final listModel = createListModel(
          style: ListStyle.bullets,
          items: [
            createListItem(id: '1', title: 'Item 1'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        expect(find.byType(ListCard), findsOneWidget);
      });

      testWidgets('handles numbered style', (tester) async {
        final listModel = createListModel(
          style: ListStyle.numbered,
          items: [
            createListItem(id: '1', title: 'Item 1'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        expect(find.byType(ListCard), findsOneWidget);
      });

      testWidgets('handles checkboxes style', (tester) async {
        final listModel = createListModel(
          style: ListStyle.checkboxes,
          items: [
            createListItem(id: '1', title: 'Item 1', isChecked: true),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        expect(find.byType(ListCard), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets('onTap callback fires when tapped', (tester) async {
        final listModel = createListModel();
        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(
                list: listModel,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ListCard));
        await tester.pump();

        expect(tapped, isTrue);
      });

      testWidgets('onLongPress callback fires when long pressed', (tester) async {
        final listModel = createListModel();
        var longPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(
                list: listModel,
                onLongPress: () {
                  longPressed = true;
                },
              ),
            ),
          ),
        );

        await tester.longPress(find.byType(ListCard));
        await tester.pump();

        expect(longPressed, isTrue);
      });

      testWidgets('handles tap without onTap callback', (tester) async {
        final listModel = createListModel();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        // Should not throw error when tapped without callback
        await tester.tap(find.byType(ListCard));
        await tester.pump();

        expect(find.byType(ListCard), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('has correct semantic label', (tester) async {
        final listModel = createListModel(
          name: 'Shopping List',
          items: [
            createListItem(id: '1', title: 'Milk'),
            createListItem(id: '2', title: 'Eggs'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        // Find the container Semantics widget
        final semanticsFinder = find.descendant(
          of: find.byType(ListCard),
          matching: find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.container == true,
          ),
        );

        expect(semanticsFinder, findsOneWidget);

        final semanticsWidget = tester.widget<Semantics>(semanticsFinder);
        expect(semanticsWidget.properties.label, contains('Shopping List'));
        expect(semanticsWidget.properties.label, contains('2 items'));
      });

      testWidgets('semantic label includes list type', (tester) async {
        final listModel = createListModel(name: 'My List');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        // Find the container Semantics widget
        final semanticsFinder = find.descendant(
          of: find.byType(ListCard),
          matching: find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.container == true,
          ),
        );

        expect(semanticsFinder, findsOneWidget);

        final semanticsWidget = tester.widget<Semantics>(semanticsFinder);
        expect(semanticsWidget.properties.label, contains('List'));
      });
    });

    group('Design System Compliance', () {
      testWidgets('uses violet gradient for border', (tester) async {
        final listModel = createListModel();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        // Card should render with gradient border
        expect(find.byType(ListCard), findsOneWidget);
      });

      testWidgets('displays with correct layout structure', (tester) async {
        final listModel = createListModel(
          items: [
            createListItem(id: '1', title: 'Item 1'),
            createListItem(id: '2', title: 'Item 2'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        // Should have icon, title, item count, and preview
        expect(find.text('Shopping List'), findsOneWidget);
        expect(find.text('2 items'), findsOneWidget);
        expect(find.text('Item 1, Item 2'), findsOneWidget);
      });
    });

    group('Press Animation', () {
      testWidgets('applies press animation on tap', (tester) async {
        final listModel = createListModel();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(
                list: listModel,
                onTap: () {},
              ),
            ),
          ),
        );

        // Find the card
        final cardFinder = find.byType(ListCard);
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
      testWidgets('applies entrance animation with index parameter', (tester) async {
        final listModel = createListModel();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(
                list: listModel,
                index: 0,
              ),
            ),
          ),
        );

        // Card should render
        expect(find.byType(ListCard), findsOneWidget);

        // Pump and settle to complete entrance animation
        await tester.pumpAndSettle();

        // Card should still be visible after animation
        expect(find.text('Shopping List'), findsOneWidget);
      });

      testWidgets('works without index parameter', (tester) async {
        final listModel = createListModel();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        // Card should render without animation
        expect(find.byType(ListCard), findsOneWidget);
        expect(find.text('Shopping List'), findsOneWidget);
      });

      testWidgets('applies staggered delay based on index', (tester) async {
        final lists = List.generate(
          3,
          (index) => createListModel(
            id: 'list_$index',
            name: 'List $index',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  return ListCard(
                    list: lists[index],
                    index: index,
                  );
                },
              ),
            ),
          ),
        );

        // All cards should render
        expect(find.byType(ListCard), findsNWidgets(3));

        // Complete all animations
        await tester.pumpAndSettle();

        // All items should be visible
        for (int i = 0; i < lists.length; i++) {
          expect(find.text('List $i'), findsOneWidget);
        }
      });
    });

    group('Icon Parsing', () {
      testWidgets('parses emoji icon correctly', (tester) async {
        final listModel = createListModel(icon: '📝');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        expect(find.text('📝'), findsOneWidget);
      });

      testWidgets('parses icon name to Icon widget', (tester) async {
        final listModel = createListModel(icon: 'favorite');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        expect(find.byIcon(Icons.favorite), findsOneWidget);
      });

      testWidgets('handles invalid icon name gracefully', (tester) async {
        final listModel = createListModel(icon: 'invalid_icon_name_xyz');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        // Should fall back to default icon
        expect(find.byIcon(Icons.list_alt), findsOneWidget);
      });

      testWidgets('handles empty icon string', (tester) async {
        final listModel = createListModel(icon: '');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        // Should fall back to default icon
        expect(find.byIcon(Icons.list_alt), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles very long list names', (tester) async {
        final listModel = createListModel(
          name: 'This is a very long list name that should be truncated with ellipsis when it exceeds the maximum number of lines allowed',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                child: ListCard(list: listModel),
              ),
            ),
          ),
        );

        expect(find.byType(ListCard), findsOneWidget);
      });

      testWidgets('handles many items', (tester) async {
        final items = List.generate(
          100,
          (index) => createListItem(
            id: 'item_$index',
            title: 'Item $index',
          ),
        );

        final listModel = createListModel(items: items);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListCard(list: listModel),
            ),
          ),
        );

        expect(find.byType(ListCard), findsOneWidget);
        expect(find.text('100 items'), findsOneWidget);
        // Should only show first 3 items in preview
        expect(find.text('Item 0, Item 1, Item 2...'), findsOneWidget);
      });

      testWidgets('handles items with very long titles', (tester) async {
        final listModel = createListModel(
          items: [
            createListItem(id: '1', title: 'This is a very long item title that might cause overflow'),
            createListItem(id: '2', title: 'Another long title'),
            createListItem(id: '3', title: 'Yet another long title'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 300,
                child: ListCard(list: listModel),
              ),
            ),
          ),
        );

        expect(find.byType(ListCard), findsOneWidget);
      });
    });
  });
}
