import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/molecules/lists/dismissible_list_item.dart';
import 'package:later_mobile/design_system/tokens/colors.dart';

void main() {
  group('DismissibleListItem', () {
    testWidgets('should render child widget correctly', (tester) async {
      // Arrange
      const testText = 'Test Item';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissibleListItem(
              itemKey: const ValueKey('test-item'),
              itemName: 'Test Item',
              onDelete: () {},
              child: const Text(testText),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('should reveal red background with delete icon on swipe', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissibleListItem(
              itemKey: const ValueKey('test-item'),
              itemName: 'Test Item',
              onDelete: () {},
              child: Container(
                height: 80,
                color: Colors.white,
                child: const Text('Swipeable Item'),
              ),
            ),
          ),
        ),
      );

      // Act - Start swipe gesture from right to left
      await tester.drag(find.text('Swipeable Item'), const Offset(-300, 0));
      await tester.pump();

      // Assert - Background should be visible during swipe
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ClipRRect),
          matching: find.byType(Container),
        ),
      );
      expect(container.color, equals(AppColors.error));

      // Assert - Delete icon should be visible
      expect(find.byIcon(Icons.delete), findsOneWidget);
      final icon = tester.widget<Icon>(find.byIcon(Icons.delete));
      expect(icon.color, equals(Colors.white));
      expect(icon.size, equals(24));
    });

    testWidgets('should show confirmation dialog when confirmDelete is true', (
      tester,
    ) async {
      // Arrange
      const itemName = 'Test Item Name';
      var deleteCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissibleListItem(
              itemKey: const ValueKey('test-item'),
              itemName: itemName,
              onDelete: () => deleteCallCount++,
              child: Container(
                height: 80,
                color: Colors.white,
                child: const Text('Swipeable Item'),
              ),
            ),
          ),
        ),
      );

      // Act - Swipe to delete
      await tester.drag(find.text('Swipeable Item'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Assert - Confirmation dialog should appear
      expect(find.text('Delete Item?'), findsOneWidget);
      expect(find.textContaining(itemName), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Assert - onDelete should not be called yet
      expect(deleteCallCount, equals(0));
    });

    testWidgets('should call onDelete after confirmation', (tester) async {
      // Arrange
      var deleteCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissibleListItem(
              itemKey: const ValueKey('test-item'),
              itemName: 'Test Item',
              onDelete: () => deleteCallCount++,
              child: Container(
                height: 80,
                color: Colors.white,
                child: const Text('Swipeable Item'),
              ),
            ),
          ),
        ),
      );

      // Act - Swipe to delete
      await tester.drag(find.text('Swipeable Item'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Act - Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert - onDelete should be called once
      expect(deleteCallCount, equals(1));

      // Assert - Item should be removed from widget tree
      expect(find.text('Swipeable Item'), findsNothing);
    });

    testWidgets('should not call onDelete when cancelled', (tester) async {
      // Arrange
      var deleteCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissibleListItem(
              itemKey: const ValueKey('test-item'),
              itemName: 'Test Item',
              onDelete: () => deleteCallCount++,
              child: Container(
                height: 80,
                color: Colors.white,
                child: const Text('Swipeable Item'),
              ),
            ),
          ),
        ),
      );

      // Act - Swipe to delete
      await tester.drag(find.text('Swipeable Item'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Act - Cancel deletion
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert - onDelete should not be called
      expect(deleteCallCount, equals(0));

      // Assert - Item should still be visible (swipe dismissed)
      expect(find.text('Swipeable Item'), findsOneWidget);
    });

    testWidgets('should skip confirmation when confirmDelete is false', (
      tester,
    ) async {
      // Arrange
      var deleteCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissibleListItem(
              itemKey: const ValueKey('test-item'),
              itemName: 'Test Item',
              confirmDelete: false,
              onDelete: () => deleteCallCount++,
              child: Container(
                height: 80,
                color: Colors.white,
                child: const Text('Swipeable Item'),
              ),
            ),
          ),
        ),
      );

      // Act - Swipe to delete
      await tester.drag(find.text('Swipeable Item'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Assert - No confirmation dialog should appear
      expect(find.text('Delete Item?'), findsNothing);
      expect(find.text('Cancel'), findsNothing);

      // Assert - onDelete should be called immediately
      expect(deleteCallCount, equals(1));

      // Assert - Item should be removed from widget tree
      expect(find.text('Swipeable Item'), findsNothing);
    });

    testWidgets('should only dismiss from right-to-left direction', (
      tester,
    ) async {
      // Arrange
      var deleteCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissibleListItem(
              itemKey: const ValueKey('test-item'),
              itemName: 'Test Item',
              confirmDelete: false,
              onDelete: () => deleteCallCount++,
              child: Container(
                height: 80,
                color: Colors.white,
                child: const Text('Swipeable Item'),
              ),
            ),
          ),
        ),
      );

      // Act - Try to swipe from left to right (should not dismiss)
      await tester.drag(find.text('Swipeable Item'), const Offset(500, 0));
      await tester.pumpAndSettle();

      // Assert - Item should still be visible (swipe not supported)
      expect(find.text('Swipeable Item'), findsOneWidget);
      expect(deleteCallCount, equals(0));
    });

    testWidgets('should apply correct padding and border radius', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissibleListItem(
              itemKey: const ValueKey('test-item'),
              itemName: 'Test Item',
              onDelete: () {},
              child: Container(
                height: 80,
                color: Colors.white,
                child: const Text('Swipeable Item'),
              ),
            ),
          ),
        ),
      );

      // Act - Start swipe to reveal background
      await tester.drag(find.text('Swipeable Item'), const Offset(-300, 0));
      await tester.pump();

      // Assert - Check padding
      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(Dismissible),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(padding.padding, equals(const EdgeInsets.only(bottom: 8.0)));

      // Assert - Check border radius
      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, equals(BorderRadius.circular(8.0)));
    });

    testWidgets('should use provided itemKey for dismissible', (tester) async {
      // Arrange
      const testKey = ValueKey('unique-item-key');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissibleListItem(
              itemKey: testKey,
              itemName: 'Test Item',
              onDelete: () {},
              child: const Text('Swipeable Item'),
            ),
          ),
        ),
      );

      // Assert - Dismissible should use the provided key
      final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
      expect(dismissible.key, equals(testKey));
    });

    testWidgets('should properly align delete icon to center right', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DismissibleListItem(
              itemKey: const ValueKey('test-item'),
              itemName: 'Test Item',
              onDelete: () {},
              child: Container(
                height: 80,
                color: Colors.white,
                child: const Text('Swipeable Item'),
              ),
            ),
          ),
        ),
      );

      // Act - Start swipe to reveal background
      await tester.drag(find.text('Swipeable Item'), const Offset(-300, 0));
      await tester.pump();

      // Assert - Container should have correct alignment
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ClipRRect),
          matching: find.byType(Container),
        ),
      );
      expect(container.alignment, equals(Alignment.centerRight));

      // Assert - Container should have correct padding for icon
      expect(container.padding, equals(const EdgeInsets.only(right: 16.0)));
    });
  });
}
