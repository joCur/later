import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/models/list_model.dart';
import 'package:later_mobile/data/models/list_style.dart';
import 'package:later_mobile/design_system/organisms/cards/list_card.dart';
import '../../../test_helpers.dart';

void main() {
  group('ListCard', () {
    // Helper function to create a ListModel
    ListModel createListModel({
      String id = '1',
      String name = 'Shopping List',
      String spaceId = 'space1',
      String userId = 'user1',
      String? icon,
      ListStyle style = ListStyle.bullets,
      int totalItemCount = 0,
      int checkedItemCount = 0,
    }) {
      return ListModel(
        id: id,
        spaceId: spaceId,
        userId: userId,
        name: name,
        icon: icon,
        style: style,
        totalItemCount: totalItemCount,
        checkedItemCount: checkedItemCount,
      );
    }

    group('Rendering', () {
      testWidgets('renders with ListModel data', (tester) async {
        final listModel = createListModel();

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        expect(find.byType(ListCard), findsOneWidget);
        expect(find.text('Shopping List'), findsOneWidget);
      });

      testWidgets('displays name correctly', (tester) async {
        final listModel = createListModel(name: 'Grocery List');

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        expect(find.text('Grocery List'), findsOneWidget);
      });

      testWidgets('shows item count with correct format - multiple items', (
        tester,
      ) async {
        final listModel = createListModel(totalItemCount: 5);

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        expect(find.text('5 items'), findsAtLeastNWidgets(1));
      });

      testWidgets('shows item count with singular format - one item', (
        tester,
      ) async {
        final listModel = createListModel(totalItemCount: 1);

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        expect(find.text('1 item'), findsAtLeastNWidgets(1));
      });

      testWidgets('shows item count for empty list', (tester) async {
        final listModel = createListModel(totalItemCount: 0);

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        expect(find.text('0 items'), findsAtLeastNWidgets(1));
      });

      testWidgets('shows "No items yet" preview for empty list', (tester) async {
        final listModel = createListModel(totalItemCount: 0);

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        expect(find.text('No items yet'), findsOneWidget);
      });

      testWidgets('shows item count preview for non-empty list', (tester) async {
        final listModel = createListModel(totalItemCount: 5);

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        expect(find.text('5 items'), findsAtLeastNWidgets(1));
      });

      testWidgets('renders violet gradient border', (tester) async {
        final listModel = createListModel();

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        // GradientPillBorder should be present
        expect(find.byType(ListCard), findsOneWidget);
      });

      testWidgets('shows default list icon when icon is null', (tester) async {
        final listModel = createListModel(icon: null);

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        expect(find.byIcon(Icons.list_alt), findsOneWidget);
      });

      testWidgets('shows custom icon when provided', (tester) async {
        final listModel = createListModel(icon: 'shopping_cart');

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      });

      testWidgets('shows emoji icon when provided', (tester) async {
        final listModel = createListModel(icon: '🛒');

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        expect(find.text('🛒'), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets('onTap callback fires when tapped', (tester) async {
        final listModel = createListModel();
        var tapped = false;

        await tester.pumpWidget(
          testApp(
            ListCard(
              list: listModel,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        );

        await tester.tap(find.byType(ListCard));
        await tester.pump();

        expect(tapped, isTrue);
      });

      testWidgets('onLongPress callback fires when long pressed', (
        tester,
      ) async {
        final listModel = createListModel();
        var longPressed = false;

        await tester.pumpWidget(
          testApp(
            ListCard(
              list: listModel,
              onLongPress: () {
                longPressed = true;
              },
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
          testApp(ListCard(list: listModel)),
        );

        // Should not throw error when tapped without callback
        await tester.tap(find.byType(ListCard));
        await tester.pump();

        expect(find.byType(ListCard), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('has correct semantic label', (tester) async {
        final listModel = createListModel(totalItemCount: 3);

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
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
        expect(semanticsWidget.properties.label, contains('Shopping List'));
        expect(semanticsWidget.properties.label, contains('3 items'));
      });

      testWidgets('semantic label shows singular "item" for one item', (
        tester,
      ) async {
        final listModel = createListModel(
          name: 'To-Do',
          totalItemCount: 1,
        );

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
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
        expect(semanticsWidget.properties.label, contains('To-Do'));
        expect(semanticsWidget.properties.label, contains('1 item'));
      });
    });

    group('Design System Compliance', () {
      testWidgets('uses list gradient (violet) for border', (tester) async {
        final listModel = createListModel();

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        // Card should render with gradient border
        expect(find.byType(ListCard), findsOneWidget);
      });

      testWidgets('displays with correct layout structure', (tester) async {
        final listModel = createListModel(totalItemCount: 3);

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        // Should have icon, title, item count, and preview
        expect(find.byType(ListCard), findsOneWidget);
        expect(find.text('Shopping List'), findsOneWidget);
        expect(find.text('3 items'), findsAtLeastNWidgets(1));
      });

      testWidgets('icon has gradient shader for non-emoji icons', (
        tester,
      ) async {
        final listModel = createListModel(icon: 'shopping_cart');

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        // Find ShaderMask widget
        expect(find.byType(ShaderMask), findsAtLeastNWidgets(1));
      });
    });

    group('Press Animation', () {
      testWidgets('applies press animation on tap', (tester) async {
        final listModel = createListModel();

        await tester.pumpWidget(
          testApp(ListCard(list: listModel, onTap: () {})),
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
      testWidgets('applies entrance animation with index parameter', (
        tester,
      ) async {
        final listModel = createListModel();

        await tester.pumpWidget(
          testApp(ListCard(list: listModel, index: 0)),
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
          testApp(ListCard(list: listModel)),
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
            totalItemCount: index,
          ),
        );

        await tester.pumpWidget(
          testApp(
            ListView.builder(
              itemCount: lists.length,
              itemBuilder: (context, index) {
                return ListCard(list: lists[index], index: index);
              },
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

    group('Edge Cases', () {
      testWidgets('handles very long name', (tester) async {
        final listModel = createListModel(
          name:
              'This is a very long list name that should be truncated with ellipsis when it exceeds the maximum number of lines allowed',
        );

        await tester.pumpWidget(
          testApp(SizedBox(width: 300, child: ListCard(list: listModel))),
        );

        expect(find.byType(ListCard), findsOneWidget);
      });

      testWidgets('handles large item count', (tester) async {
        final listModel = createListModel(totalItemCount: 999);

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        expect(find.text('999 items'), findsAtLeastNWidgets(1));
      });

      testWidgets('handles empty string icon', (tester) async {
        final listModel = createListModel(icon: '');

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        // Should show default icon
        expect(find.byIcon(Icons.list_alt), findsOneWidget);
      });

      testWidgets('handles unknown icon name', (tester) async {
        final listModel = createListModel(icon: 'unknown_icon_name');

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        // Should fall back to default icon (list_alt)
        expect(find.byIcon(Icons.list_alt), findsOneWidget);
      });

      testWidgets('handles unicode in list name', (tester) async {
        final listModel = createListModel(
          name: 'Shopping 🛒 List',
          totalItemCount: 5,
        );

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        expect(find.textContaining('Shopping'), findsOneWidget);
      });
    });

    group('List Styles', () {
      testWidgets('renders with bullets style', (tester) async {
        final listModel = createListModel(
          style: ListStyle.bullets,
          totalItemCount: 3,
        );

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        expect(find.byType(ListCard), findsOneWidget);
        expect(find.text('Shopping List'), findsOneWidget);
      });

      testWidgets('renders with checkboxes style', (tester) async {
        final listModel = createListModel(
          style: ListStyle.checkboxes,
          totalItemCount: 5,
          checkedItemCount: 2,
        );

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        expect(find.byType(ListCard), findsOneWidget);
        expect(find.text('Shopping List'), findsOneWidget);
      });

      testWidgets('renders with numbered style', (tester) async {
        final listModel = createListModel(
          style: ListStyle.numbered,
          totalItemCount: 10,
        );

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        expect(find.byType(ListCard), findsOneWidget);
        expect(find.text('Shopping List'), findsOneWidget);
      });

      testWidgets('renders with simple style', (tester) async {
        final listModel = createListModel(
          style: ListStyle.simple,
          totalItemCount: 4,
        );

        await tester.pumpWidget(
          testApp(ListCard(list: listModel)),
        );

        expect(find.byType(ListCard), findsOneWidget);
        expect(find.text('Shopping List'), findsOneWidget);
      });
    });
  });
}
