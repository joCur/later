import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:later_mobile/data/models/todo_list_model.dart';
import 'package:later_mobile/data/repositories/todo_list_repository.dart';

void main() {
  group('TodoListRepository Tests', () {
    late TodoListRepository repository;
    late Box<TodoList> todoListBox;

    setUp(() async {
      // Initialize Hive in test directory
      const tempDir = '.dart_tool/test/hive';
      Hive.init(tempDir);

      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(20)) {
        Hive.registerAdapter(TodoListAdapter());
      }
      if (!Hive.isAdapterRegistered(21)) {
        Hive.registerAdapter(TodoItemAdapter());
      }
      if (!Hive.isAdapterRegistered(25)) {
        Hive.registerAdapter(TodoPriorityAdapter());
      }

      // Open box
      todoListBox = await Hive.openBox<TodoList>('todo_lists');
      repository = TodoListRepository();
    });

    tearDown(() async {
      // Clear and close the box
      await todoListBox.clear();
      await todoListBox.close();
      await Hive.deleteBoxFromDisk('todo_lists');
    });

    /// Helper function to create a test TodoList
    TodoList createTestTodoList({
      String? id,
      String spaceId = 'space-1',
      String name = 'Weekly Tasks',
      String? description,
      List<TodoItem>? items,
      DateTime? createdAt,
      DateTime? updatedAt,
    }) {
      return TodoList(
        id: id ?? 'todo-${DateTime.now().millisecondsSinceEpoch}',
        spaceId: spaceId,
        name: name,
        description: description,
        items: items ?? [],
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    }

    /// Helper function to create a test TodoItem
    TodoItem createTestTodoItem({
      String? id,
      String title = 'Buy groceries',
      String? description,
      bool isCompleted = false,
      DateTime? dueDate,
      TodoPriority? priority,
      List<String>? tags,
      int sortOrder = 0,
    }) {
      return TodoItem(
        id: id ?? 'item-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        isCompleted: isCompleted,
        dueDate: dueDate,
        priority: priority,
        tags: tags ?? [],
        sortOrder: sortOrder,
      );
    }

    group('CRUD operations', () {
      test('create() successfully stores a TodoList', () async {
        // Arrange
        final todoList = createTestTodoList(
          id: 'todo-1',
        );

        // Act
        final result = await repository.create(todoList);

        // Assert
        expect(result.id, equals('todo-1'));
        expect(result.name, equals('Weekly Tasks'));
        expect(todoListBox.length, equals(1));
        expect(todoListBox.get('todo-1'), isNotNull);
      });

      test('getById() returns existing TodoList', () async {
        // Arrange
        final todoList = createTestTodoList(
          id: 'todo-1',
          name: 'Project Roadmap',
        );
        await repository.create(todoList);

        // Act
        final result = await repository.getById('todo-1');

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals('todo-1'));
        expect(result.name, equals('Project Roadmap'));
      });

      test('getById() returns null for non-existent ID', () async {
        // Act
        final result = await repository.getById('non-existent');

        // Assert
        expect(result, isNull);
      });

      test('getBySpace() returns all TodoLists for a space', () async {
        // Arrange
        final todoList1 = createTestTodoList(
          id: 'todo-1',
          name: 'List 1',
        );
        final todoList2 = createTestTodoList(
          id: 'todo-2',
          name: 'List 2',
        );
        final todoList3 = createTestTodoList(
          id: 'todo-3',
          spaceId: 'space-2',
          name: 'List 3',
        );

        await repository.create(todoList1);
        await repository.create(todoList2);
        await repository.create(todoList3);

        // Act
        final result = await repository.getBySpace('space-1');

        // Assert
        expect(result.length, equals(2));
        expect(result.every((list) => list.spaceId == 'space-1'), isTrue);
        expect(result.map((list) => list.id), containsAll(['todo-1', 'todo-2']));
      });

      test('getBySpace() returns empty list when no TodoLists exist', () async {
        // Act
        final result = await repository.getBySpace('space-1');

        // Assert
        expect(result, isEmpty);
      });

      test('update() updates existing TodoList and timestamp', () async {
        // Arrange
        final todoList = createTestTodoList(
          id: 'todo-1',
          name: 'Original Name',
        );
        await repository.create(todoList);

        // Wait to ensure timestamp difference
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final updatedTodoList = todoList.copyWith(
          name: 'Updated Name',
        );

        // Act
        final result = await repository.update(updatedTodoList);

        // Assert
        expect(result.name, equals('Updated Name'));
        expect(result.updatedAt.isAfter(todoList.updatedAt), isTrue);
        expect(todoListBox.get('todo-1')!.name, equals('Updated Name'));
      });

      test('update() throws exception when TodoList does not exist', () async {
        // Arrange
        final nonExistentTodoList = createTestTodoList(id: 'non-existent');

        // Act & Assert
        expect(
          () => repository.update(nonExistentTodoList),
          throwsException,
        );
      });

      test('delete() removes TodoList', () async {
        // Arrange
        final todoList = createTestTodoList(id: 'todo-1');
        await repository.create(todoList);
        expect(todoListBox.length, equals(1));

        // Act
        await repository.delete('todo-1');

        // Assert
        expect(todoListBox.length, equals(0));
        expect(todoListBox.get('todo-1'), isNull);
      });

      test('delete() succeeds even if TodoList does not exist', () async {
        // Act & Assert - should not throw
        await repository.delete('non-existent');
        expect(todoListBox.length, equals(0));
      });
    });

    group('TodoItem operations', () {
      test('addItem() adds new TodoItem to TodoList', () async {
        // Arrange
        final todoList = createTestTodoList(id: 'todo-1', items: []);
        await repository.create(todoList);

        final item = createTestTodoItem(
          id: 'item-1',
          title: 'Fix bug #123',
        );

        // Act
        final result = await repository.addItem('todo-1', item);

        // Assert
        expect(result.items.length, equals(1));
        expect(result.items.first.id, equals('item-1'));
        expect(result.items.first.title, equals('Fix bug #123'));
        expect(todoListBox.get('todo-1')!.items.length, equals(1));
      });

      test('addItem() throws exception when TodoList does not exist', () async {
        // Arrange
        final item = createTestTodoItem(id: 'item-1');

        // Act & Assert
        expect(
          () => repository.addItem('non-existent', item),
          throwsException,
        );
      });

      test('updateItem() updates specific TodoItem', () async {
        // Arrange
        final item1 = createTestTodoItem(
          id: 'item-1',
          title: 'Original Title',
        );
        final todoList = createTestTodoList(
          id: 'todo-1',
          items: [item1],
        );
        await repository.create(todoList);

        final updatedItem = item1.copyWith(title: 'Updated Title');

        // Act
        final result = await repository.updateItem('todo-1', 'item-1', updatedItem);

        // Assert
        expect(result.items.first.title, equals('Updated Title'));
        expect(todoListBox.get('todo-1')!.items.first.title, equals('Updated Title'));
      });

      test('updateItem() throws exception when TodoList does not exist', () async {
        // Arrange
        final item = createTestTodoItem(id: 'item-1');

        // Act & Assert
        expect(
          () => repository.updateItem('non-existent', 'item-1', item),
          throwsException,
        );
      });

      test('updateItem() throws exception when TodoItem does not exist', () async {
        // Arrange
        final todoList = createTestTodoList(id: 'todo-1', items: []);
        await repository.create(todoList);

        final item = createTestTodoItem(id: 'item-1');

        // Act & Assert
        expect(
          () => repository.updateItem('todo-1', 'item-1', item),
          throwsException,
        );
      });

      test('deleteItem() removes TodoItem from TodoList', () async {
        // Arrange
        final item1 = createTestTodoItem(id: 'item-1');
        final item2 = createTestTodoItem(id: 'item-2', sortOrder: 1);
        final todoList = createTestTodoList(
          id: 'todo-1',
          items: [item1, item2],
        );
        await repository.create(todoList);

        // Act
        final result = await repository.deleteItem('todo-1', 'item-1');

        // Assert
        expect(result.items.length, equals(1));
        expect(result.items.first.id, equals('item-2'));
        expect(todoListBox.get('todo-1')!.items.length, equals(1));
      });

      test('deleteItem() throws exception when TodoList does not exist', () async {
        // Act & Assert
        expect(
          () => repository.deleteItem('non-existent', 'item-1'),
          throwsException,
        );
      });

      test('toggleItem() toggles isCompleted status', () async {
        // Arrange
        final item = createTestTodoItem(
          id: 'item-1',
        );
        final todoList = createTestTodoList(
          id: 'todo-1',
          items: [item],
        );
        await repository.create(todoList);

        // Act - toggle to true
        final result1 = await repository.toggleItem('todo-1', 'item-1');

        // Assert
        expect(result1.items.first.isCompleted, isTrue);

        // Act - toggle back to false
        final result2 = await repository.toggleItem('todo-1', 'item-1');

        // Assert
        expect(result2.items.first.isCompleted, isFalse);
      });

      test('toggleItem() throws exception when TodoList does not exist', () async {
        // Act & Assert
        expect(
          () => repository.toggleItem('non-existent', 'item-1'),
          throwsException,
        );
      });

      test('toggleItem() throws exception when TodoItem does not exist', () async {
        // Arrange
        final todoList = createTestTodoList(id: 'todo-1', items: []);
        await repository.create(todoList);

        // Act & Assert
        expect(
          () => repository.toggleItem('todo-1', 'non-existent'),
          throwsException,
        );
      });

      test('reorderItems() reorders items and updates sortOrder', () async {
        // Arrange
        final item1 = createTestTodoItem(id: 'item-1', title: 'First');
        final item2 = createTestTodoItem(id: 'item-2', title: 'Second', sortOrder: 1);
        final item3 = createTestTodoItem(id: 'item-3', title: 'Third', sortOrder: 2);
        final todoList = createTestTodoList(
          id: 'todo-1',
          items: [item1, item2, item3],
        );
        await repository.create(todoList);

        // Act - move first item to last position
        final result = await repository.reorderItems('todo-1', 0, 2);

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
        final item = createTestTodoItem(id: 'item-1');
        final todoList = createTestTodoList(
          id: 'todo-1',
          items: [item],
        );
        await repository.create(todoList);

        // Act & Assert
        expect(
          () => repository.reorderItems('todo-1', -1, 0),
          throwsException,
        );
        expect(
          () => repository.reorderItems('todo-1', 5, 0),
          throwsException,
        );
      });

      test('reorderItems() throws exception for invalid newIndex', () async {
        // Arrange
        final item = createTestTodoItem(id: 'item-1');
        final todoList = createTestTodoList(
          id: 'todo-1',
          items: [item],
        );
        await repository.create(todoList);

        // Act & Assert
        expect(
          () => repository.reorderItems('todo-1', 0, -1),
          throwsException,
        );
        expect(
          () => repository.reorderItems('todo-1', 0, 5),
          throwsException,
        );
      });

      test('reorderItems() handles single item list', () async {
        // Arrange
        final item = createTestTodoItem(id: 'item-1');
        final todoList = createTestTodoList(
          id: 'todo-1',
          items: [item],
        );
        await repository.create(todoList);

        // Act
        final result = await repository.reorderItems('todo-1', 0, 0);

        // Assert
        expect(result.items.length, equals(1));
        expect(result.items.first.sortOrder, equals(0));
      });
    });

    group('Bulk operations', () {
      test('deleteAllInSpace() deletes all TodoLists in space', () async {
        // Arrange
        final todoList1 = createTestTodoList(
          id: 'todo-1',
        );
        final todoList2 = createTestTodoList(
          id: 'todo-2',
        );
        final todoList3 = createTestTodoList(
          id: 'todo-3',
          spaceId: 'space-2',
        );

        await repository.create(todoList1);
        await repository.create(todoList2);
        await repository.create(todoList3);

        // Act
        await repository.deleteAllInSpace('space-1');

        // Assert
        expect(todoListBox.length, equals(1));
        expect(todoListBox.get('todo-3'), isNotNull);
      });

      test('deleteAllInSpace() returns correct count', () async {
        // Arrange
        final todoList1 = createTestTodoList(
          id: 'todo-1',
        );
        final todoList2 = createTestTodoList(
          id: 'todo-2',
        );

        await repository.create(todoList1);
        await repository.create(todoList2);

        // Act
        final count = await repository.deleteAllInSpace('space-1');

        // Assert
        expect(count, equals(2));
        expect(todoListBox.length, equals(0));
      });

      test('deleteAllInSpace() returns 0 when space is empty', () async {
        // Act
        final count = await repository.deleteAllInSpace('empty-space');

        // Assert
        expect(count, equals(0));
      });

      test('countBySpace() returns correct count', () async {
        // Arrange
        final todoList1 = createTestTodoList(
          id: 'todo-1',
        );
        final todoList2 = createTestTodoList(
          id: 'todo-2',
        );
        final todoList3 = createTestTodoList(
          id: 'todo-3',
          spaceId: 'space-2',
        );

        await repository.create(todoList1);
        await repository.create(todoList2);
        await repository.create(todoList3);

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

    group('Edge cases and complex scenarios', () {
      test('create TodoList with multiple items', () async {
        // Arrange
        final items = [
          createTestTodoItem(id: 'item-1', title: 'Task 1'),
          createTestTodoItem(id: 'item-2', title: 'Task 2', sortOrder: 1),
          createTestTodoItem(id: 'item-3', title: 'Task 3', sortOrder: 2),
        ];
        final todoList = createTestTodoList(
          id: 'todo-1',
          items: items,
        );

        // Act
        final result = await repository.create(todoList);

        // Assert
        expect(result.items.length, equals(3));
        expect(result.totalItems, equals(3));
      });

      test('TodoItem with priority and tags', () async {
        // Arrange
        final item = createTestTodoItem(
          id: 'item-1',
          title: 'Important task',
          priority: TodoPriority.high,
          tags: ['urgent', 'work'],
        );
        final todoList = createTestTodoList(
          id: 'todo-1',
          items: [item],
        );

        // Act
        await repository.create(todoList);
        final result = await repository.getById('todo-1');

        // Assert
        expect(result!.items.first.priority, equals(TodoPriority.high));
        expect(result.items.first.tags, containsAll(['urgent', 'work']));
      });

      test('TodoItem with due date', () async {
        // Arrange
        final dueDate = DateTime(2025, 12, 31);
        final item = createTestTodoItem(
          id: 'item-1',
          dueDate: dueDate,
        );
        final todoList = createTestTodoList(
          id: 'todo-1',
          items: [item],
        );

        // Act
        await repository.create(todoList);
        final result = await repository.getById('todo-1');

        // Assert
        expect(result!.items.first.dueDate, equals(dueDate));
      });

      test('progress calculation with completed items', () async {
        // Arrange
        final items = [
          createTestTodoItem(id: 'item-1', isCompleted: true),
          createTestTodoItem(id: 'item-2', isCompleted: true, sortOrder: 1),
          createTestTodoItem(id: 'item-3', sortOrder: 2),
        ];
        final todoList = createTestTodoList(
          id: 'todo-1',
          items: items,
        );

        // Act
        await repository.create(todoList);
        final result = await repository.getById('todo-1');

        // Assert
        expect(result!.completedItems, equals(2));
        expect(result.totalItems, equals(3));
        expect(result.progress, closeTo(0.666, 0.01));
      });

      test('empty TodoList has 0 progress', () async {
        // Arrange
        final todoList = createTestTodoList(id: 'todo-1', items: []);

        // Act
        await repository.create(todoList);
        final result = await repository.getById('todo-1');

        // Assert
        expect(result!.progress, equals(0.0));
      });

      test('update preserves other fields', () async {
        // Arrange
        final item = createTestTodoItem(id: 'item-1');
        final todoList = createTestTodoList(
          id: 'todo-1',
          name: 'Original Name',
          description: 'Original Description',
          items: [item],
        );
        await repository.create(todoList);

        // Act
        final updated = todoList.copyWith(name: 'New Name');
        final result = await repository.update(updated);

        // Assert
        expect(result.name, equals('New Name'));
        expect(result.description, equals('Original Description'));
        expect(result.items.length, equals(1));
      });

      test('multiple addItem calls accumulate items', () async {
        // Arrange
        final todoList = createTestTodoList(id: 'todo-1', items: []);
        await repository.create(todoList);

        // Act
        await repository.addItem('todo-1', createTestTodoItem(id: 'item-1'));
        await repository.addItem('todo-1', createTestTodoItem(id: 'item-2', sortOrder: 1));
        await repository.addItem('todo-1', createTestTodoItem(id: 'item-3', sortOrder: 2));

        // Assert
        final result = await repository.getById('todo-1');
        expect(result!.items.length, equals(3));
      });

      test('deleteItem on non-existent item does not throw', () async {
        // Arrange
        final item = createTestTodoItem(id: 'item-1');
        final todoList = createTestTodoList(
          id: 'todo-1',
          items: [item],
        );
        await repository.create(todoList);

        // Act
        final result = await repository.deleteItem('todo-1', 'non-existent');

        // Assert
        expect(result.items.length, equals(1));
      });

      test('TodoList with null description', () async {
        // Arrange
        final todoList = createTestTodoList(
          id: 'todo-1',
        );

        // Act
        final result = await repository.create(todoList);

        // Assert
        expect(result.description, isNull);
      });

      test('timestamps are set correctly on creation', () async {
        // Arrange
        final now = DateTime.now();
        final todoList = createTestTodoList(id: 'todo-1');

        // Act
        final result = await repository.create(todoList);

        // Assert
        expect(
          result.createdAt.difference(now).inSeconds.abs(),
          lessThan(2),
        );
        expect(
          result.updatedAt.difference(now).inSeconds.abs(),
          lessThan(2),
        );
      });
    });
  });
}
