import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:later_mobile/data/models/list_model.dart';
import 'package:later_mobile/data/models/list_item_model.dart';
import 'package:later_mobile/data/models/list_style.dart';
import 'package:later_mobile/data/repositories/list_repository.dart';

void main() {
  group('ListRepository Tests', () {
    late ListRepository repository;
    late Box<ListModel> listBox;

    setUp(() async {
      // Initialize Hive in test directory
      const tempDir = '.dart_tool/test/hive';
      Hive.init(tempDir);

      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(22)) {
        Hive.registerAdapter(ListModelAdapter());
      }
      if (!Hive.isAdapterRegistered(23)) {
        Hive.registerAdapter(ListItemAdapter());
      }
      if (!Hive.isAdapterRegistered(24)) {
        Hive.registerAdapter(ListStyleAdapter());
      }

      // Open box
      listBox = await Hive.openBox<ListModel>('lists');
      repository = ListRepository();
    });

    tearDown(() async {
      // Clear and close the box
      await listBox.clear();
      await listBox.close();
      await Hive.deleteBoxFromDisk('lists');
    });

    /// Helper function to create a test ListModel
    ListModel createTestList({
      String? id,
      String spaceId = 'space-1',
      String name = 'Shopping List',
      String? icon,
      List<ListItem>? items,
      ListStyle style = ListStyle.bullets,
      DateTime? createdAt,
      DateTime? updatedAt,
    }) {
      return ListModel(
        id: id ?? 'list-${DateTime.now().millisecondsSinceEpoch}',
        spaceId: spaceId,
        name: name,
        icon: icon,
        items: items ?? [],
        style: style,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    }

    /// Helper function to create a test ListItem
    ListItem createTestListItem({
      String? id,
      String title = 'Milk',
      String? notes,
      bool isChecked = false,
      int sortOrder = 0,
    }) {
      return ListItem(
        id: id ?? 'item-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        notes: notes,
        isChecked: isChecked,
        sortOrder: sortOrder,
      );
    }

    group('CRUD operations', () {
      test('create() successfully stores a ListModel', () async {
        // Arrange
        final list = createTestList(id: 'list-1', style: ListStyle.checkboxes);

        // Act
        final result = await repository.create(list);

        // Assert
        expect(result.id, equals('list-1'));
        expect(result.name, equals('Shopping List'));
        expect(result.style, equals(ListStyle.checkboxes));
        expect(listBox.length, equals(1));
        expect(listBox.get('list-1'), isNotNull);
      });

      test('create() assigns sortOrder 0 for first list in space', () async {
        // Arrange
        final list = createTestList(id: 'list-1');

        // Act
        final result = await repository.create(list);

        // Assert
        expect(result.sortOrder, equals(0));
      });

      test('create() assigns incremental sortOrder for subsequent lists', () async {
        // Arrange
        final list1 = createTestList(id: 'list-1');
        final list2 = createTestList(id: 'list-2');
        final list3 = createTestList(id: 'list-3');

        // Act
        final result1 = await repository.create(list1);
        final result2 = await repository.create(list2);
        final result3 = await repository.create(list3);

        // Assert
        expect(result1.sortOrder, equals(0));
        expect(result2.sortOrder, equals(1));
        expect(result3.sortOrder, equals(2));
      });

      test('create() uses space-scoped sortOrder values', () async {
        // Arrange - Create lists in different spaces
        final list1Space1 = createTestList(id: 'list-1');
        final list2Space1 = createTestList(id: 'list-2');
        final list1Space2 = createTestList(id: 'list-3', spaceId: 'space-2');
        final list2Space2 = createTestList(id: 'list-4', spaceId: 'space-2');

        // Act
        final result1Space1 = await repository.create(list1Space1);
        final result2Space1 = await repository.create(list2Space1);
        final result1Space2 = await repository.create(list1Space2);
        final result2Space2 = await repository.create(list2Space2);

        // Assert - Each space should have independent sortOrder sequence
        expect(result1Space1.sortOrder, equals(0));
        expect(result2Space1.sortOrder, equals(1));
        expect(result1Space2.sortOrder, equals(0)); // Restarts for new space
        expect(result2Space2.sortOrder, equals(1));
      });

      test('getById() returns existing ListModel', () async {
        // Arrange
        final list = createTestList(
          id: 'list-1',
          name: 'Grocery List',
          style: ListStyle.numbered,
        );
        await repository.create(list);

        // Act
        final result = await repository.getById('list-1');

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals('list-1'));
        expect(result.name, equals('Grocery List'));
        expect(result.style, equals(ListStyle.numbered));
      });

      test('getById() returns null for non-existent ID', () async {
        // Act
        final result = await repository.getById('non-existent');

        // Assert
        expect(result, isNull);
      });

      test('getBySpace() returns all ListModels for a space', () async {
        // Arrange
        final list1 = createTestList(id: 'list-1', name: 'List 1');
        final list2 = createTestList(id: 'list-2', name: 'List 2');
        final list3 = createTestList(
          id: 'list-3',
          spaceId: 'space-2',
          name: 'List 3',
        );

        await repository.create(list1);
        await repository.create(list2);
        await repository.create(list3);

        // Act
        final result = await repository.getBySpace('space-1');

        // Assert
        expect(result.length, equals(2));
        expect(result.every((list) => list.spaceId == 'space-1'), isTrue);
        expect(
          result.map((list) => list.id),
          containsAll(['list-1', 'list-2']),
        );
      });

      test(
        'getBySpace() returns empty list when no ListModels exist',
        () async {
          // Act
          final result = await repository.getBySpace('space-1');

          // Assert
          expect(result, isEmpty);
        },
      );

      test('update() updates existing ListModel and timestamp', () async {
        // Arrange
        final list = createTestList(id: 'list-1', name: 'Original Name');
        await repository.create(list);

        // Wait to ensure timestamp difference
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final updatedList = list.copyWith(name: 'Updated Name');

        // Act
        final result = await repository.update(updatedList);

        // Assert
        expect(result.name, equals('Updated Name'));
        expect(result.updatedAt.isAfter(list.updatedAt), isTrue);
        expect(listBox.get('list-1')!.name, equals('Updated Name'));
      });

      test('update() throws exception when ListModel does not exist', () async {
        // Arrange
        final nonExistentList = createTestList(id: 'non-existent');

        // Act & Assert
        expect(() => repository.update(nonExistentList), throwsException);
      });

      test('delete() removes ListModel', () async {
        // Arrange
        final list = createTestList(id: 'list-1');
        await repository.create(list);
        expect(listBox.length, equals(1));

        // Act
        await repository.delete('list-1');

        // Assert
        expect(listBox.length, equals(0));
        expect(listBox.get('list-1'), isNull);
      });

      test('delete() succeeds even if ListModel does not exist', () async {
        // Act & Assert - should not throw
        await repository.delete('non-existent');
        expect(listBox.length, equals(0));
      });
    });

    group('ListItem operations', () {
      test('addItem() adds new ListItem to ListModel', () async {
        // Arrange
        final list = createTestList(id: 'list-1', items: []);
        await repository.create(list);

        final item = createTestListItem(id: 'item-1', title: 'Bread');

        // Act
        final result = await repository.addItem('list-1', item);

        // Assert
        expect(result.items.length, equals(1));
        expect(result.items.first.id, equals('item-1'));
        expect(result.items.first.title, equals('Bread'));
        expect(listBox.get('list-1')!.items.length, equals(1));
      });

      test(
        'addItem() throws exception when ListModel does not exist',
        () async {
          // Arrange
          final item = createTestListItem(id: 'item-1');

          // Act & Assert
          expect(
            () => repository.addItem('non-existent', item),
            throwsException,
          );
        },
      );

      test('updateItem() updates specific ListItem', () async {
        // Arrange
        final item1 = createTestListItem(id: 'item-1', title: 'Original Title');
        final list = createTestList(id: 'list-1', items: [item1]);
        await repository.create(list);

        final updatedItem = item1.copyWith(title: 'Updated Title');

        // Act
        final result = await repository.updateItem(
          'list-1',
          'item-1',
          updatedItem,
        );

        // Assert
        expect(result.items.first.title, equals('Updated Title'));
        expect(
          listBox.get('list-1')!.items.first.title,
          equals('Updated Title'),
        );
      });

      test(
        'updateItem() throws exception when ListModel does not exist',
        () async {
          // Arrange
          final item = createTestListItem(id: 'item-1');

          // Act & Assert
          expect(
            () => repository.updateItem('non-existent', 'item-1', item),
            throwsException,
          );
        },
      );

      test(
        'updateItem() throws exception when ListItem does not exist',
        () async {
          // Arrange
          final list = createTestList(id: 'list-1', items: []);
          await repository.create(list);

          final item = createTestListItem(id: 'item-1');

          // Act & Assert
          expect(
            () => repository.updateItem('list-1', 'item-1', item),
            throwsException,
          );
        },
      );

      test('deleteItem() removes ListItem from ListModel', () async {
        // Arrange
        final item1 = createTestListItem(id: 'item-1');
        final item2 = createTestListItem(id: 'item-2', sortOrder: 1);
        final list = createTestList(id: 'list-1', items: [item1, item2]);
        await repository.create(list);

        // Act
        final result = await repository.deleteItem('list-1', 'item-1');

        // Assert
        expect(result.items.length, equals(1));
        expect(result.items.first.id, equals('item-2'));
        expect(listBox.get('list-1')!.items.length, equals(1));
      });

      test(
        'deleteItem() throws exception when ListModel does not exist',
        () async {
          // Act & Assert
          expect(
            () => repository.deleteItem('non-existent', 'item-1'),
            throwsException,
          );
        },
      );

      test('toggleItem() toggles isChecked status', () async {
        // Arrange
        final item = createTestListItem(id: 'item-1');
        final list = createTestList(
          id: 'list-1',
          items: [item],
          style: ListStyle.checkboxes,
        );
        await repository.create(list);

        // Act - toggle to true
        final result1 = await repository.toggleItem('list-1', 'item-1');

        // Assert
        expect(result1.items.first.isChecked, isTrue);

        // Act - toggle back to false
        final result2 = await repository.toggleItem('list-1', 'item-1');

        // Assert
        expect(result2.items.first.isChecked, isFalse);
      });

      test(
        'toggleItem() throws exception when ListModel does not exist',
        () async {
          // Act & Assert
          expect(
            () => repository.toggleItem('non-existent', 'item-1'),
            throwsException,
          );
        },
      );

      test(
        'toggleItem() throws exception when ListItem does not exist',
        () async {
          // Arrange
          final list = createTestList(id: 'list-1', items: []);
          await repository.create(list);

          // Act & Assert
          expect(
            () => repository.toggleItem('list-1', 'non-existent'),
            throwsException,
          );
        },
      );

      test('reorderItems() reorders items and updates sortOrder', () async {
        // Arrange
        final item1 = createTestListItem(id: 'item-1', title: 'First');
        final item2 = createTestListItem(
          id: 'item-2',
          title: 'Second',
          sortOrder: 1,
        );
        final item3 = createTestListItem(
          id: 'item-3',
          title: 'Third',
          sortOrder: 2,
        );
        final list = createTestList(id: 'list-1', items: [item1, item2, item3]);
        await repository.create(list);

        // Act - move first item to last position
        final result = await repository.reorderItems('list-1', 0, 2);

        // Assert
        expect(result.items[0].id, equals('item-2'));
        expect(result.items[1].id, equals('item-3'));
        expect(result.items[2].id, equals('item-1'));
        expect(result.items[0].sortOrder, equals(0));
        expect(result.items[1].sortOrder, equals(1));
        expect(result.items[2].sortOrder, equals(2));
      });

      test('reorderItems() throws exception for invalid oldIndex', () async {
        // Arrange
        final item = createTestListItem(id: 'item-1');
        final list = createTestList(id: 'list-1', items: [item]);
        await repository.create(list);

        // Act & Assert
        expect(() => repository.reorderItems('list-1', -1, 0), throwsException);
        expect(() => repository.reorderItems('list-1', 5, 0), throwsException);
      });

      test('reorderItems() throws exception for invalid newIndex', () async {
        // Arrange
        final item = createTestListItem(id: 'item-1');
        final list = createTestList(id: 'list-1', items: [item]);
        await repository.create(list);

        // Act & Assert
        expect(() => repository.reorderItems('list-1', 0, -1), throwsException);
        expect(() => repository.reorderItems('list-1', 0, 5), throwsException);
      });

      test('reorderItems() handles single item list', () async {
        // Arrange
        final item = createTestListItem(id: 'item-1');
        final list = createTestList(id: 'list-1', items: [item]);
        await repository.create(list);

        // Act
        final result = await repository.reorderItems('list-1', 0, 0);

        // Assert
        expect(result.items.length, equals(1));
        expect(result.items.first.sortOrder, equals(0));
      });
    });

    group('Bulk operations', () {
      test('deleteAllInSpace() deletes all ListModels in space', () async {
        // Arrange
        final list1 = createTestList(id: 'list-1');
        final list2 = createTestList(id: 'list-2');
        final list3 = createTestList(id: 'list-3', spaceId: 'space-2');

        await repository.create(list1);
        await repository.create(list2);
        await repository.create(list3);

        // Act
        await repository.deleteAllInSpace('space-1');

        // Assert
        expect(listBox.length, equals(1));
        expect(listBox.get('list-3'), isNotNull);
      });

      test('deleteAllInSpace() returns correct count', () async {
        // Arrange
        final list1 = createTestList(id: 'list-1');
        final list2 = createTestList(id: 'list-2');

        await repository.create(list1);
        await repository.create(list2);

        // Act
        final count = await repository.deleteAllInSpace('space-1');

        // Assert
        expect(count, equals(2));
        expect(listBox.length, equals(0));
      });

      test('deleteAllInSpace() returns 0 when space is empty', () async {
        // Act
        final count = await repository.deleteAllInSpace('empty-space');

        // Assert
        expect(count, equals(0));
      });

      test('countBySpace() returns correct count', () async {
        // Arrange
        final list1 = createTestList(id: 'list-1');
        final list2 = createTestList(id: 'list-2');
        final list3 = createTestList(id: 'list-3', spaceId: 'space-2');

        await repository.create(list1);
        await repository.create(list2);
        await repository.create(list3);

        // Act
        final count1 = await repository.countBySpace('space-1');
        final count2 = await repository.countBySpace('space-2');

        // Assert
        expect(count1, equals(2));
        expect(count2, equals(1));
      });

      test('countBySpace() returns 0 for empty space', () async {
        // Act
        final count = await repository.countBySpace('empty-space');

        // Assert
        expect(count, equals(0));
      });
    });

    group('ListStyle variants', () {
      test('create ListModel with bullets style', () async {
        // Arrange
        final list = createTestList(id: 'list-1', name: 'Notes');

        // Act
        final result = await repository.create(list);

        // Assert
        expect(result.style, equals(ListStyle.bullets));
      });

      test('create ListModel with numbered style', () async {
        // Arrange
        final list = createTestList(
          id: 'list-1',
          name: 'Steps',
          style: ListStyle.numbered,
        );

        // Act
        final result = await repository.create(list);

        // Assert
        expect(result.style, equals(ListStyle.numbered));
      });

      test('create ListModel with checkboxes style', () async {
        // Arrange
        final list = createTestList(
          id: 'list-1',
          name: 'Tasks',
          style: ListStyle.checkboxes,
        );

        // Act
        final result = await repository.create(list);

        // Assert
        expect(result.style, equals(ListStyle.checkboxes));
      });

      test('update ListModel style', () async {
        // Arrange
        final list = createTestList(id: 'list-1');
        await repository.create(list);

        // Act
        final updated = list.copyWith(style: ListStyle.checkboxes);
        final result = await repository.update(updated);

        // Assert
        expect(result.style, equals(ListStyle.checkboxes));
      });
    });

    group('Edge cases and complex scenarios', () {
      test('create ListModel with multiple items', () async {
        // Arrange
        final items = [
          createTestListItem(id: 'item-1', title: 'Item 1'),
          createTestListItem(id: 'item-2', title: 'Item 2', sortOrder: 1),
          createTestListItem(id: 'item-3', title: 'Item 3', sortOrder: 2),
        ];
        final list = createTestList(id: 'list-1', items: items);

        // Act
        final result = await repository.create(list);

        // Assert
        expect(result.items.length, equals(3));
        expect(result.totalItems, equals(3));
      });

      test('ListItem with notes', () async {
        // Arrange
        final item = createTestListItem(
          id: 'item-1',
          title: 'Important item',
          notes: 'This is a detailed note about the item',
        );
        final list = createTestList(id: 'list-1', items: [item]);

        // Act
        await repository.create(list);
        final result = await repository.getById('list-1');

        // Assert
        expect(
          result!.items.first.notes,
          equals('This is a detailed note about the item'),
        );
      });

      test('progress calculation with checked items', () async {
        // Arrange
        final items = [
          createTestListItem(id: 'item-1', isChecked: true),
          createTestListItem(id: 'item-2', isChecked: true, sortOrder: 1),
          createTestListItem(id: 'item-3', sortOrder: 2),
        ];
        final list = createTestList(
          id: 'list-1',
          items: items,
          style: ListStyle.checkboxes,
        );

        // Act
        await repository.create(list);
        final result = await repository.getById('list-1');

        // Assert
        expect(result!.checkedItems, equals(2));
        expect(result.totalItems, equals(3));
        expect(result.progress, closeTo(0.666, 0.01));
      });

      test('empty ListModel has 0 progress', () async {
        // Arrange
        final list = createTestList(id: 'list-1', items: []);

        // Act
        await repository.create(list);
        final result = await repository.getById('list-1');

        // Assert
        expect(result!.progress, equals(0.0));
      });

      test('update preserves other fields', () async {
        // Arrange
        final item = createTestListItem(id: 'item-1');
        final list = createTestList(
          id: 'list-1',
          name: 'Original Name',
          icon: '📝',
          items: [item],
        );
        await repository.create(list);

        // Act
        final updated = list.copyWith(name: 'New Name');
        final result = await repository.update(updated);

        // Assert
        expect(result.name, equals('New Name'));
        expect(result.icon, equals('📝'));
        expect(result.items.length, equals(1));
        expect(result.style, equals(ListStyle.bullets));
      });

      test('multiple addItem calls accumulate items', () async {
        // Arrange
        final list = createTestList(id: 'list-1', items: []);
        await repository.create(list);

        // Act
        await repository.addItem('list-1', createTestListItem(id: 'item-1'));
        await repository.addItem(
          'list-1',
          createTestListItem(id: 'item-2', sortOrder: 1),
        );
        await repository.addItem(
          'list-1',
          createTestListItem(id: 'item-3', sortOrder: 2),
        );

        // Assert
        final result = await repository.getById('list-1');
        expect(result!.items.length, equals(3));
      });

      test('deleteItem on non-existent item does not throw', () async {
        // Arrange
        final item = createTestListItem(id: 'item-1');
        final list = createTestList(id: 'list-1', items: [item]);
        await repository.create(list);

        // Act
        final result = await repository.deleteItem('list-1', 'non-existent');

        // Assert
        expect(result.items.length, equals(1));
      });

      test('ListModel with custom icon', () async {
        // Arrange
        final list = createTestList(id: 'list-1', name: 'Shopping', icon: '🛒');

        // Act
        final result = await repository.create(list);

        // Assert
        expect(result.icon, equals('🛒'));
      });

      test('ListModel with null icon', () async {
        // Arrange
        final list = createTestList(id: 'list-1');

        // Act
        final result = await repository.create(list);

        // Assert
        expect(result.icon, isNull);
      });

      test('timestamps are set correctly on creation', () async {
        // Arrange
        final now = DateTime.now();
        final list = createTestList(id: 'list-1');

        // Act
        final result = await repository.create(list);

        // Assert
        expect(result.createdAt.difference(now).inSeconds.abs(), lessThan(2));
        expect(result.updatedAt.difference(now).inSeconds.abs(), lessThan(2));
      });

      test('checkbox toggle is relevant only for checkbox style', () async {
        // Arrange
        final item = createTestListItem(id: 'item-1');
        final list = createTestList(id: 'list-1', items: [item]);
        await repository.create(list);

        // Act - toggle should still work but is semantically for checkboxes
        final result = await repository.toggleItem('list-1', 'item-1');

        // Assert
        expect(result.items.first.isChecked, isTrue);
        expect(result.style, equals(ListStyle.bullets));
      });

      test('ListItem with null notes', () async {
        // Arrange
        final item = createTestListItem(id: 'item-1');
        final list = createTestList(id: 'list-1', items: [item]);

        // Act
        final result = await repository.create(list);

        // Assert
        expect(result.items.first.notes, isNull);
      });

      test('clear icon with clearIcon flag', () async {
        // Arrange
        final list = createTestList(id: 'list-1', icon: '📝');
        await repository.create(list);

        // Act
        final updated = list.copyWith(clearIcon: true);
        final result = await repository.update(updated);

        // Assert
        expect(result.icon, isNull);
      });
    });
  });
}
