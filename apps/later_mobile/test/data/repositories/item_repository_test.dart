import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:later_mobile/data/models/item_model.dart';
import 'package:later_mobile/data/repositories/item_repository.dart';

void main() {
  group('ItemRepository Tests', () {
    late ItemRepository repository;
    late Box<Item> itemsBox;

    setUp(() async {
      // Initialize Hive in test directory
      const tempDir = '.dart_tool/test/hive';
      Hive.init(tempDir);

      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ItemTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ItemAdapter());
      }

      // Open box
      itemsBox = await Hive.openBox<Item>('items');
      repository = ItemRepository();
    });

    tearDown(() async {
      // Clear and close the box
      await itemsBox.clear();
      await itemsBox.close();
      await Hive.deleteBoxFromDisk('items');
    });

    /// Helper function to create a test item
    Item createTestItem({
      String? id,
      ItemType type = ItemType.task,
      String title = 'Test Item',
      String? content,
      String spaceId = 'space-1',
      bool isCompleted = false,
      DateTime? dueDate,
      List<String>? tags,
    }) {
      return Item(
        id: id ?? 'item-${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        title: title,
        content: content,
        spaceId: spaceId,
        isCompleted: isCompleted,
        dueDate: dueDate,
        tags: tags ?? [],
      );
    }

    group('createItem', () {
      test('should successfully create an item', () async {
        // Arrange
        final item = createTestItem(id: 'item-1', title: 'New Task');

        // Act
        final result = await repository.createItem(item);

        // Assert
        expect(result.id, equals('item-1'));
        expect(result.title, equals('New Task'));
        expect(itemsBox.length, equals(1));
        expect(itemsBox.get('item-1'), isNotNull);
      });

      test('should add item to Hive box with correct key', () async {
        // Arrange
        final item = createTestItem(id: 'item-2', title: 'Another Task');

        // Act
        await repository.createItem(item);

        // Assert
        final storedItem = itemsBox.get('item-2');
        expect(storedItem, isNotNull);
        expect(storedItem!.title, equals('Another Task'));
      });

      test('should create multiple items', () async {
        // Arrange
        final item1 = createTestItem(id: 'item-1', title: 'Task 1');
        final item2 = createTestItem(id: 'item-2', title: 'Task 2');
        final item3 = createTestItem(id: 'item-3', title: 'Task 3');

        // Act
        await repository.createItem(item1);
        await repository.createItem(item2);
        await repository.createItem(item3);

        // Assert
        expect(itemsBox.length, equals(3));
      });
    });

    group('getItems', () {
      test('should return empty list when no items exist', () async {
        // Act
        final result = await repository.getItems();

        // Assert
        expect(result, isEmpty);
      });

      test('should return all items', () async {
        // Arrange
        final item1 = createTestItem(id: 'item-1', title: 'Task 1');
        final item2 = createTestItem(id: 'item-2', title: 'Task 2');
        final item3 = createTestItem(id: 'item-3', title: 'Task 3');

        await repository.createItem(item1);
        await repository.createItem(item2);
        await repository.createItem(item3);

        // Act
        final result = await repository.getItems();

        // Assert
        expect(result.length, equals(3));
        expect(result.map((item) => item.id), containsAll(['item-1', 'item-2', 'item-3']));
      });

      test('should return items in consistent order', () async {
        // Arrange
        final item1 = createTestItem(id: 'item-1', title: 'First');
        final item2 = createTestItem(id: 'item-2', title: 'Second');

        await repository.createItem(item1);
        await repository.createItem(item2);

        // Act
        final result1 = await repository.getItems();
        final result2 = await repository.getItems();

        // Assert
        expect(result1.length, equals(result2.length));
        for (var i = 0; i < result1.length; i++) {
          expect(result1[i].id, equals(result2[i].id));
        }
      });
    });

    group('getItemsBySpace', () {
      test('should return empty list when no items in space', () async {
        // Arrange
        final item1 = createTestItem(id: 'item-1');
        await repository.createItem(item1);

        // Act
        final result = await repository.getItemsBySpace('space-2');

        // Assert
        expect(result, isEmpty);
      });

      test('should return only items from specified space', () async {
        // Arrange
        final item1 = createTestItem(id: 'item-1', title: 'Space 1 Item 1');
        final item2 = createTestItem(id: 'item-2', spaceId: 'space-2', title: 'Space 2 Item');
        final item3 = createTestItem(id: 'item-3', title: 'Space 1 Item 2');

        await repository.createItem(item1);
        await repository.createItem(item2);
        await repository.createItem(item3);

        // Act
        final result = await repository.getItemsBySpace('space-1');

        // Assert
        expect(result.length, equals(2));
        expect(result.every((item) => item.spaceId == 'space-1'), isTrue);
        expect(result.map((item) => item.id), containsAll(['item-1', 'item-3']));
      });

      test('should filter items correctly for multiple spaces', () async {
        // Arrange
        final item1 = createTestItem(id: 'item-1');
        final item2 = createTestItem(id: 'item-2', spaceId: 'space-2');
        final item3 = createTestItem(id: 'item-3', spaceId: 'space-3');

        await repository.createItem(item1);
        await repository.createItem(item2);
        await repository.createItem(item3);

        // Act
        final space1Items = await repository.getItemsBySpace('space-1');
        final space2Items = await repository.getItemsBySpace('space-2');
        final space3Items = await repository.getItemsBySpace('space-3');

        // Assert
        expect(space1Items.length, equals(1));
        expect(space2Items.length, equals(1));
        expect(space3Items.length, equals(1));
      });
    });

    group('getItemsByType', () {
      test('should return empty list when no items of type exist', () async {
        // Arrange
        final item1 = createTestItem(id: 'item-1');
        await repository.createItem(item1);

        // Act
        final result = await repository.getItemsByType(ItemType.note);

        // Assert
        expect(result, isEmpty);
      });

      test('should return only items of specified type', () async {
        // Arrange
        final task1 = createTestItem(id: 'item-1', title: 'Task 1');
        final note1 = createTestItem(id: 'item-2', type: ItemType.note, title: 'Note 1');
        final task2 = createTestItem(id: 'item-3', title: 'Task 2');
        final list1 = createTestItem(id: 'item-4', type: ItemType.list, title: 'List 1');

        await repository.createItem(task1);
        await repository.createItem(note1);
        await repository.createItem(task2);
        await repository.createItem(list1);

        // Act
        final tasks = await repository.getItemsByType(ItemType.task);
        final notes = await repository.getItemsByType(ItemType.note);
        final lists = await repository.getItemsByType(ItemType.list);

        // Assert
        expect(tasks.length, equals(2));
        expect(notes.length, equals(1));
        expect(lists.length, equals(1));
        expect(tasks.every((item) => item.type == ItemType.task), isTrue);
        expect(notes.every((item) => item.type == ItemType.note), isTrue);
        expect(lists.every((item) => item.type == ItemType.list), isTrue);
      });
    });

    group('updateItem', () {
      test('should successfully update an existing item', () async {
        // Arrange
        final originalItem = createTestItem(
          id: 'item-1',
          title: 'Original Title',
          content: 'Original Content',
        );
        await repository.createItem(originalItem);

        final updatedItem = originalItem.copyWith(
          title: 'Updated Title',
          content: 'Updated Content',
        );

        // Act
        final result = await repository.updateItem(updatedItem);

        // Assert
        expect(result.title, equals('Updated Title'));
        expect(result.content, equals('Updated Content'));
        expect(itemsBox.get('item-1')!.title, equals('Updated Title'));
      });

      test('should update the updatedAt timestamp', () async {
        // Arrange
        final originalItem = createTestItem(id: 'item-1');
        await repository.createItem(originalItem);

        // Wait a small amount to ensure timestamp difference
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final updatedItem = originalItem.copyWith(title: 'New Title');

        // Act
        final result = await repository.updateItem(updatedItem);

        // Assert
        expect(result.updatedAt.isAfter(originalItem.updatedAt), isTrue);
      });

      test('should throw exception when updating non-existent item', () async {
        // Arrange
        final nonExistentItem = createTestItem(id: 'non-existent');

        // Act & Assert
        expect(
          () => repository.updateItem(nonExistentItem),
          throwsException,
        );
      });

      test('should update item completion status', () async {
        // Arrange
        final item = createTestItem(id: 'item-1');
        await repository.createItem(item);

        final completedItem = item.copyWith(isCompleted: true);

        // Act
        final result = await repository.updateItem(completedItem);

        // Assert
        expect(result.isCompleted, isTrue);
        expect(itemsBox.get('item-1')!.isCompleted, isTrue);
      });
    });

    group('deleteItem', () {
      test('should successfully delete an existing item', () async {
        // Arrange
        final item = createTestItem(id: 'item-1');
        await repository.createItem(item);
        expect(itemsBox.length, equals(1));

        // Act
        await repository.deleteItem('item-1');

        // Assert
        expect(itemsBox.length, equals(0));
        expect(itemsBox.get('item-1'), isNull);
      });

      test('should delete correct item from multiple items', () async {
        // Arrange
        final item1 = createTestItem(id: 'item-1', title: 'Item 1');
        final item2 = createTestItem(id: 'item-2', title: 'Item 2');
        final item3 = createTestItem(id: 'item-3', title: 'Item 3');

        await repository.createItem(item1);
        await repository.createItem(item2);
        await repository.createItem(item3);

        // Act
        await repository.deleteItem('item-2');

        // Assert
        expect(itemsBox.length, equals(2));
        expect(itemsBox.get('item-1'), isNotNull);
        expect(itemsBox.get('item-2'), isNull);
        expect(itemsBox.get('item-3'), isNotNull);
      });

      test('should handle deletion of non-existent item gracefully', () async {
        // Act & Assert - should not throw
        await repository.deleteItem('non-existent');
        expect(itemsBox.length, equals(0));
      });

      test('should allow deletion of all items', () async {
        // Arrange
        final item1 = createTestItem(id: 'item-1');
        final item2 = createTestItem(id: 'item-2');

        await repository.createItem(item1);
        await repository.createItem(item2);

        // Act
        await repository.deleteItem('item-1');
        await repository.deleteItem('item-2');

        // Assert
        expect(itemsBox.length, equals(0));
      });
    });

    group('Edge Cases', () {
      test('should handle item with null content', () async {
        // Arrange
        final item = createTestItem(id: 'item-1');

        // Act
        final result = await repository.createItem(item);

        // Assert
        expect(result.content, isNull);
        expect(itemsBox.get('item-1')!.content, isNull);
      });

      test('should handle item with empty tags list', () async {
        // Arrange
        final item = createTestItem(id: 'item-1', tags: []);

        // Act
        final result = await repository.createItem(item);

        // Assert
        expect(result.tags, isEmpty);
      });

      test('should handle item with multiple tags', () async {
        // Arrange
        final item = createTestItem(
          id: 'item-1',
          tags: ['urgent', 'work', 'important'],
        );

        // Act
        final result = await repository.createItem(item);

        // Assert
        expect(result.tags.length, equals(3));
        expect(result.tags, containsAll(['urgent', 'work', 'important']));
      });

      test('should handle item with due date', () async {
        // Arrange
        final dueDate = DateTime(2025, 12, 31);
        final item = createTestItem(id: 'item-1', dueDate: dueDate);

        // Act
        final result = await repository.createItem(item);

        // Assert
        expect(result.dueDate, equals(dueDate));
      });
    });
  });
}
