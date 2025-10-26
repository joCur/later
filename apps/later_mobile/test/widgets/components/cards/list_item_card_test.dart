import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/widgets/components/cards/list_item_card.dart';
import 'package:later_mobile/data/models/list_model.dart';
import 'package:later_mobile/core/theme/app_colors.dart';

void main() {
  group('ListItemCard', () {
    // Test data
    final testListItem = ListItem(
      id: 'test-item-1',
      title: 'Buy groceries',
      notes: 'Milk, eggs, bread, and cheese',
      sortOrder: 0,
    );

    final checkedListItem = ListItem(
      id: 'test-item-2',
      title: 'Call dentist',
      isChecked: true,
      sortOrder: 1,
    );

    final minimalListItem = ListItem(
      id: 'test-item-3',
      title: 'Simple item',
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
      testWidgets('renders with ListItem data', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.bullets,
              itemIndex: 1,
            ),
          ),
        );

        expect(find.byType(ListItemCard), findsOneWidget);
      });

      testWidgets('displays title correctly', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.bullets,
              itemIndex: 1,
            ),
          ),
        );

        expect(find.text('Buy groceries'), findsOneWidget);
      });

      testWidgets('shows notes if present', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.bullets,
              itemIndex: 1,
            ),
          ),
        );

        expect(find.text('Milk, eggs, bread, and cheese'), findsOneWidget);
      });

      testWidgets('does not show notes if not present', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: minimalListItem,
              listStyle: ListStyle.bullets,
              itemIndex: 1,
            ),
          ),
        );

        // Only title should be visible
        expect(find.text('Simple item'), findsOneWidget);
        // No notes widget should be rendered
        final textWidgets = tester.widgetList<Text>(find.byType(Text));
        expect(textWidgets.length, lessThanOrEqualTo(2)); // Title + indicator (or just title)
      });

      testWidgets('shows reorder handle icon', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.bullets,
              itemIndex: 1,
            ),
          ),
        );

        expect(find.byIcon(Icons.drag_indicator), findsOneWidget);
      });

      testWidgets('renders with compact height', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: minimalListItem,
              listStyle: ListStyle.bullets,
              itemIndex: 1,
            ),
          ),
        );

        // Find the container (card should be 56-64px height)
        final box = tester.getSize(find.byType(ListItemCard));
        expect(box.height, lessThan(80)); // Should be compact
      });
    });

    group('List Style - Bullets', () {
      testWidgets('shows bullet point for bullets style', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.bullets,
              itemIndex: 1,
            ),
          ),
        );

        // Should show bullet character
        expect(find.text('•'), findsOneWidget);
      });

      testWidgets('does not show checkbox for bullets style', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.bullets,
              itemIndex: 1,
            ),
          ),
        );

        expect(find.byType(Checkbox), findsNothing);
      });
    });

    group('List Style - Numbered', () {
      testWidgets('shows number for numbered style', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.numbered,
              itemIndex: 1,
            ),
          ),
        );

        // Should show number badge with "1."
        expect(find.text('1.'), findsOneWidget);
      });

      testWidgets('shows correct number based on itemIndex', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            Column(
              children: [
                ListItemCard(
                  listItem: testListItem,
                  listStyle: ListStyle.numbered,
                  itemIndex: 1,
                ),
                ListItemCard(
                  listItem: checkedListItem,
                  listStyle: ListStyle.numbered,
                  itemIndex: 2,
                ),
                ListItemCard(
                  listItem: minimalListItem,
                  listStyle: ListStyle.numbered,
                  itemIndex: 3,
                ),
              ],
            ),
          ),
        );

        expect(find.text('1.'), findsOneWidget);
        expect(find.text('2.'), findsOneWidget);
        expect(find.text('3.'), findsOneWidget);
      });

      testWidgets('does not show checkbox for numbered style', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.numbered,
              itemIndex: 1,
            ),
          ),
        );

        expect(find.byType(Checkbox), findsNothing);
      });
    });

    group('List Style - Checkboxes', () {
      testWidgets('shows checkbox for checkboxes style', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.checkboxes,
              itemIndex: 1,
            ),
          ),
        );

        expect(find.byType(Checkbox), findsOneWidget);
      });

      testWidgets('checkbox shows correct state when not checked', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.checkboxes,
              itemIndex: 1,
            ),
          ),
        );

        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, false);
      });

      testWidgets('checkbox shows correct state when checked', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: checkedListItem,
              listStyle: ListStyle.checkboxes,
              itemIndex: 1,
            ),
          ),
        );

        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, true);
      });

      testWidgets('shows strikethrough when checked', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: checkedListItem,
              listStyle: ListStyle.checkboxes,
              itemIndex: 1,
            ),
          ),
        );

        final textWidget = tester.widget<Text>(
          find.text('Call dentist'),
        );
        expect(textWidget.style?.decoration, TextDecoration.lineThrough);
      });

      testWidgets('does not show strikethrough when not checked', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.checkboxes,
              itemIndex: 1,
            ),
          ),
        );

        final textWidget = tester.widget<Text>(
          find.text('Buy groceries'),
        );
        expect(textWidget.style?.decoration, isNot(TextDecoration.lineThrough));
      });
    });

    group('Interactions', () {
      testWidgets('onTap callback fires when card is tapped', (tester) async {
        bool tapped = false;
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.bullets,
              itemIndex: 1,
              onTap: () => tapped = true,
            ),
          ),
        );

        await tester.tap(find.byType(ListItemCard));
        await tester.pump();

        expect(tapped, true);
      });

      testWidgets('onCheckboxChanged callback fires when checkbox is tapped (checkboxes style)', (tester) async {
        bool? newValue;
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.checkboxes,
              itemIndex: 1,
              onCheckboxChanged: (value) => newValue = value,
            ),
          ),
        );

        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        expect(newValue, true);
      });

      testWidgets('onCheckboxChanged callback receives correct value when toggling from checked', (tester) async {
        bool? newValue;
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: checkedListItem,
              listStyle: ListStyle.checkboxes,
              itemIndex: 1,
              onCheckboxChanged: (value) => newValue = value,
            ),
          ),
        );

        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        expect(newValue, false);
      });

      testWidgets('onTap triggers checkbox toggle for checkboxes style when callback provided', (tester) async {
        bool? checkboxValue;
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.checkboxes,
              itemIndex: 1,
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

      testWidgets('long press callback fires', (tester) async {
        bool longPressed = false;
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.bullets,
              itemIndex: 1,
              onLongPress: () => longPressed = true,
            ),
          ),
        );

        await tester.longPress(find.byType(ListItemCard));
        await tester.pump();

        expect(longPressed, true);
      });

      testWidgets('checkbox not shown for bullets style even with callback', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.bullets,
              itemIndex: 1,
              onCheckboxChanged: (value) {},
            ),
          ),
        );

        expect(find.byType(Checkbox), findsNothing);
      });

      testWidgets('checkbox not shown for numbered style even with callback', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.numbered,
              itemIndex: 1,
              onCheckboxChanged: (value) {},
            ),
          ),
        );

        expect(find.byType(Checkbox), findsNothing);
      });
    });

    group('Accessibility', () {
      testWidgets('has correct semantic label for unchecked item with notes', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.checkboxes,
              itemIndex: 1,
            ),
          ),
        );

        expect(
          find.bySemanticsLabel(RegExp('Buy groceries.*not checked.*Milk, eggs, bread, and cheese')),
          findsOneWidget,
        );
      });

      testWidgets('has correct semantic label for checked item', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: checkedListItem,
              listStyle: ListStyle.checkboxes,
              itemIndex: 1,
            ),
          ),
        );

        expect(
          find.bySemanticsLabel(RegExp('Call dentist.*checked')),
          findsOneWidget,
        );
      });

      testWidgets('has correct semantic label for bullets style', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.bullets,
              itemIndex: 1,
            ),
          ),
        );

        expect(
          find.bySemanticsLabel(RegExp('Buy groceries.*bullet')),
          findsOneWidget,
        );
      });

      testWidgets('has correct semantic label for numbered style', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.numbered,
              itemIndex: 1,
            ),
          ),
        );

        expect(
          find.bySemanticsLabel(RegExp('Buy groceries.*number 1')),
          findsOneWidget,
        );
      });

      testWidgets('checkbox is marked as checkbox for screen readers', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.checkboxes,
              itemIndex: 1,
            ),
          ),
        );

        // Verify checkbox is present and accessible
        expect(find.byType(Checkbox), findsOneWidget);
      });
    });

    group('Visual States', () {
      testWidgets('applies reduced opacity when checked', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: checkedListItem,
              listStyle: ListStyle.checkboxes,
              itemIndex: 1,
            ),
          ),
        );

        // The entire card should have reduced opacity
        final opacityFinder = find.ancestor(
          of: find.text('Call dentist'),
          matching: find.byType(Opacity),
        );

        expect(opacityFinder, findsWidgets);
        final opacity = tester.widget<Opacity>(opacityFinder.first);
        expect(opacity.opacity, AppColors.completedOpacity);
      });

      testWidgets('full opacity when not checked', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.checkboxes,
              itemIndex: 1,
            ),
          ),
        );

        // Should have full opacity
        final opacityFinder = find.ancestor(
          of: find.text('Buy groceries'),
          matching: find.byType(Opacity),
        );

        // If opacity widget exists, it should be 1.0
        if (opacityFinder.evaluate().isNotEmpty) {
          final opacity = tester.widget<Opacity>(opacityFinder.first);
          expect(opacity.opacity, 1.0);
        }
      });
    });

    group('Edge Cases', () {
      testWidgets('handles empty title gracefully', (tester) async {
        final emptyTitleItem = ListItem(
          id: 'empty',
          title: '',
          sortOrder: 0,
        );

        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: emptyTitleItem,
              listStyle: ListStyle.bullets,
              itemIndex: 1,
            ),
          ),
        );

        expect(find.byType(ListItemCard), findsOneWidget);
      });

      testWidgets('handles very long title with ellipsis', (tester) async {
        final longTitleItem = ListItem(
          id: 'long',
          title: 'This is a very long title that should be truncated with an ellipsis because it exceeds the maximum width available in the card',
          sortOrder: 0,
        );

        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: longTitleItem,
              listStyle: ListStyle.bullets,
              itemIndex: 1,
            ),
          ),
        );

        final textWidget = tester.widget<Text>(
          find.text(longTitleItem.title),
        );
        expect(textWidget.overflow, TextOverflow.ellipsis);
      });

      testWidgets('handles very long notes with ellipsis', (tester) async {
        final longNotesItem = ListItem(
          id: 'long-notes',
          title: 'Item with long notes',
          notes: 'These are very long notes that should be truncated with an ellipsis because they exceed the maximum number of lines available in the card which is set to 2 lines maximum',
          sortOrder: 0,
        );

        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: longNotesItem,
              listStyle: ListStyle.bullets,
              itemIndex: 1,
            ),
          ),
        );

        final notesWidget = tester.widget<Text>(
          find.text(longNotesItem.notes!),
        );
        expect(notesWidget.maxLines, 2);
        expect(notesWidget.overflow, TextOverflow.ellipsis);
      });

      testWidgets('handles null callbacks gracefully', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.bullets,
              itemIndex: 1,
            ),
          ),
        );

        // Should not crash when tapping without callbacks
        await tester.tap(find.byType(ListItemCard));
        await tester.pump();

        expect(find.byType(ListItemCard), findsOneWidget);
      });

      testWidgets('handles itemIndex 0 correctly', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.numbered,
              itemIndex: 0,
            ),
          ),
        );

        // itemIndex 0 should show as "0."
        expect(find.text('0.'), findsOneWidget);
      });
    });

    group('Layout', () {
      testWidgets('indicator is on the left', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.bullets,
              itemIndex: 1,
            ),
          ),
        );

        final bulletOffset = tester.getTopLeft(find.text('•'));
        final titleOffset = tester.getTopLeft(find.text(testListItem.title));

        expect(bulletOffset.dx, lessThan(titleOffset.dx));
      });

      testWidgets('checkbox is on the left for checkboxes style', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.checkboxes,
              itemIndex: 1,
            ),
          ),
        );

        final checkboxOffset = tester.getTopLeft(find.byType(Checkbox));
        final titleOffset = tester.getTopLeft(find.text(testListItem.title));

        expect(checkboxOffset.dx, lessThan(titleOffset.dx));
      });

      testWidgets('reorder handle is on the right', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.bullets,
              itemIndex: 1,
            ),
          ),
        );

        final handleOffset = tester.getTopRight(find.byIcon(Icons.drag_indicator));
        final titleOffset = tester.getTopRight(find.text(testListItem.title));

        expect(handleOffset.dx, greaterThan(titleOffset.dx));
      });

      testWidgets('notes are below title', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.bullets,
              itemIndex: 1,
            ),
          ),
        );

        final titleOffset = tester.getCenter(find.text(testListItem.title));
        final notesOffset = tester.getCenter(find.text(testListItem.notes!));

        // Notes should be below the title (higher dy value)
        expect(notesOffset.dy, greaterThan(titleOffset.dy));
      });
    });

    group('Performance', () {
      testWidgets('uses RepaintBoundary for optimization', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            ListItemCard(
              listItem: testListItem,
              listStyle: ListStyle.bullets,
              itemIndex: 1,
            ),
          ),
        );

        expect(find.byType(RepaintBoundary), findsWidgets);
      });
    });
  });
}
