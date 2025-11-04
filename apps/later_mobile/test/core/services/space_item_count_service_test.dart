import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:later_mobile/core/services/space_item_count_service.dart';
import 'package:later_mobile/data/models/note_model.dart';
import 'package:later_mobile/data/models/list_model.dart';
import 'package:later_mobile/data/models/list_item_model.dart';
import 'package:later_mobile/data/models/list_style.dart';
import 'package:later_mobile/data/models/list_model.dart';
import 'package:later_mobile/data/models/list_item_model.dart';
import 'package:later_mobile/data/models/list_style.dart';
import 'package:later_mobile/data/models/todo_item_model.dart';
import 'package:later_mobile/data/models/todo_priority.dart';

void main() {
  group('SpaceItemCountService Tests', () {
    late Box<Item> notesBox;
    late Box<TodoList> todoListsBox;
    late Box<ListModel> listsBox;

    setUp(() async {
      // Initialize Hive in test directory
      const tempDir = '.dart_tool/test/hive';
      Hive.init(tempDir);

      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ItemAdapter());
      }
      if (!Hive.isAdapterRegistered(20)) {
        Hive.registerAdapter(TodoListAdapter());
      }
      if (!Hive.isAdapterRegistered(21)) {
        Hive.registerAdapter(TodoItemAdapter());
      }
      if (!Hive.isAdapterRegistered(22)) {
        Hive.registerAdapter(ListModelAdapter());
      }
      if (!Hive.isAdapterRegistered(23)) {
        Hive.registerAdapter(ListItemAdapter());
      }
      if (!Hive.isAdapterRegistered(24)) {
        Hive.registerAdapter(ListStyleAdapter());
      }
      if (!Hive.isAdapterRegistered(25)) {
        Hive.registerAdapter(TodoPriorityAdapter());
      }

      // Open boxes
      notesBox = await Hive.openBox<Item>('notes');
      todoListsBox = await Hive.openBox<TodoList>('todo_lists');
      listsBox = await Hive.openBox<ListModel>('lists');
    });

    tearDown(() async {
      // Clear and close boxes
      await notesBox.clear();
      await todoListsBox.clear();
      await listsBox.clear();

      await notesBox.close();
      await todoListsBox.close();
      await listsBox.close();

      await Hive.deleteBoxFromDisk('notes');
      await Hive.deleteBoxFromDisk('todo_lists');
      await Hive.deleteBoxFromDisk('lists');
    });

    /// Helper function to create a test note
    Item createTestNote({
      required String id,
      required String spaceId,
      String title = 'Test Note',
    }) {
      return Item(
        id: id,
        title: title,
        spaceId: spaceId,
      );
    }

    /// Helper function to create a test todo list
    TodoList createTestTodoList({
      required String id,
      required String spaceId,
      String name = 'Test Todo List',
    }) {
      return TodoList(
        id: id,
        name: name,
        spaceId: spaceId,
      );
    }

    /// Helper function to create a test list
    ListModel createTestList({
      required String id,
      required String spaceId,
      String name = 'Test List',
    }) {
      return ListModel(
        id: id,
        name: name,
        spaceId: spaceId,
      );
    }

    group('calculateItemCount', () {
      test('should return 0 for space with no items', () async {
        // Arrange
        const spaceId = 'space-1';

        // Act
        final count = await SpaceItemCountService.calculateItemCount(spaceId);

        // Assert
        expect(count, equals(0));
      });

      test('should count only notes correctly', () async {
        // Arrange
        const spaceA = 'space-a';
        const spaceB = 'space-b';

        final note1 = createTestNote(id: 'note-1', spaceId: spaceA);
        final note2 = createTestNote(id: 'note-2', spaceId: spaceA);
        final note3 = createTestNote(id: 'note-3', spaceId: spaceA);
        final note4 = createTestNote(id: 'note-4', spaceId: spaceB);

        await notesBox.put(note1.id, note1);
        await notesBox.put(note2.id, note2);
        await notesBox.put(note3.id, note3);
        await notesBox.put(note4.id, note4);

        // Act
        final countA = await SpaceItemCountService.calculateItemCount(spaceA);
        final countB = await SpaceItemCountService.calculateItemCount(spaceB);

        // Assert
        expect(countA, equals(3));
        expect(countB, equals(1));
      });

      test('should count only todo lists correctly', () async {
        // Arrange
        const spaceA = 'space-a';

        final todo1 = createTestTodoList(id: 'todo-1', spaceId: spaceA);
        final todo2 = createTestTodoList(id: 'todo-2', spaceId: spaceA);

        await todoListsBox.put(todo1.id, todo1);
        await todoListsBox.put(todo2.id, todo2);

        // Act
        final count = await SpaceItemCountService.calculateItemCount(spaceA);

        // Assert
        expect(count, equals(2));
      });

      test('should count only regular lists correctly', () async {
        // Arrange
        const spaceA = 'space-a';

        final list1 = createTestList(id: 'list-1', spaceId: spaceA);
        final list2 = createTestList(id: 'list-2', spaceId: spaceA);

        await listsBox.put(list1.id, list1);
        await listsBox.put(list2.id, list2);

        // Act
        final count = await SpaceItemCountService.calculateItemCount(spaceA);

        // Assert
        expect(count, equals(2));
      });

      test('should sum all item types correctly', () async {
        // Arrange
        const spaceA = 'space-a';

        final note1 = createTestNote(id: 'note-1', spaceId: spaceA);
        final note2 = createTestNote(id: 'note-2', spaceId: spaceA);
        final todo1 = createTestTodoList(id: 'todo-1', spaceId: spaceA);
        final list1 = createTestList(id: 'list-1', spaceId: spaceA);
        final list2 = createTestList(id: 'list-2', spaceId: spaceA);
        final list3 = createTestList(id: 'list-3', spaceId: spaceA);

        await notesBox.put(note1.id, note1);
        await notesBox.put(note2.id, note2);
        await todoListsBox.put(todo1.id, todo1);
        await listsBox.put(list1.id, list1);
        await listsBox.put(list2.id, list2);
        await listsBox.put(list3.id, list3);

        // Act
        final count = await SpaceItemCountService.calculateItemCount(spaceA);

        // Assert
        expect(count, equals(6)); // 2 notes + 1 todo + 3 lists
      });

      test('should filter by spaceId correctly across multiple spaces',
          () async {
        // Arrange
        const spaceA = 'space-a';
        const spaceB = 'space-b';
        const spaceC = 'space-c';

        final note1 = createTestNote(id: 'note-1', spaceId: spaceA);
        final note2 = createTestNote(id: 'note-2', spaceId: spaceB);
        final todo1 = createTestTodoList(id: 'todo-1', spaceId: spaceA);
        final todo2 = createTestTodoList(id: 'todo-2', spaceId: spaceC);
        final list1 = createTestList(id: 'list-1', spaceId: spaceA);
        final list2 = createTestList(id: 'list-2', spaceId: spaceB);

        await notesBox.put(note1.id, note1);
        await notesBox.put(note2.id, note2);
        await todoListsBox.put(todo1.id, todo1);
        await todoListsBox.put(todo2.id, todo2);
        await listsBox.put(list1.id, list1);
        await listsBox.put(list2.id, list2);

        // Act
        final countA = await SpaceItemCountService.calculateItemCount(spaceA);
        final countB = await SpaceItemCountService.calculateItemCount(spaceB);
        final countC = await SpaceItemCountService.calculateItemCount(spaceC);

        // Assert
        expect(countA, equals(3)); // 1 note + 1 todo + 1 list
        expect(countB, equals(2)); // 1 note + 1 list
        expect(countC, equals(1)); // 1 todo
      });

      test('should handle unopened boxes gracefully', () async {
        // Arrange - Close all boxes
        await notesBox.close();
        await todoListsBox.close();
        await listsBox.close();

        // Act
        final count =
            await SpaceItemCountService.calculateItemCount('space-1');

        // Assert
        expect(count, equals(0));

        // Clean up - Re-open boxes for tearDown
        notesBox = await Hive.openBox<Item>('notes');
        todoListsBox = await Hive.openBox<TodoList>('todo_lists');
        listsBox = await Hive.openBox<ListModel>('lists');
      });
    });
  });
}
