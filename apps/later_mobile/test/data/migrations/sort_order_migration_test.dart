import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:later_mobile/data/local/preferences_service.dart';
import 'package:later_mobile/data/migrations/sort_order_migration.dart';
import 'package:later_mobile/data/models/note_model.dart';
import 'package:later_mobile/data/models/list_model.dart';
import 'package:later_mobile/data/models/space_model.dart';
import 'package:later_mobile/data/models/todo_list_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SortOrderMigration', () {
    setUp(() async {
      // Initialize Hive with a temporary directory
      Hive.init('.dart_tool/test/hive_sort_order_migration');

      // Register adapters
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ItemAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(SpaceAdapter());
      }
      if (!Hive.isAdapterRegistered(20)) {
        Hive.registerAdapter(TodoListAdapter());
      }
      if (!Hive.isAdapterRegistered(21)) {
        Hive.registerAdapter(TodoItemAdapter());
      }
      if (!Hive.isAdapterRegistered(25)) {
        Hive.registerAdapter(TodoPriorityAdapter());
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

      // Open boxes
      await Hive.openBox<Item>('notes');
      await Hive.openBox<TodoList>('todo_lists');
      await Hive.openBox<ListModel>('lists');
      await Hive.openBox<Space>('spaces');

      // Set up SharedPreferences with mock values
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.initialize();
    });

    tearDown(() async {
      // Clear and close all boxes
      final notesBox = Hive.box<Item>('notes');
      final todoListsBox = Hive.box<TodoList>('todo_lists');
      final listsBox = Hive.box<ListModel>('lists');
      final spacesBox = Hive.box<Space>('spaces');

      await notesBox.clear();
      await todoListsBox.clear();
      await listsBox.clear();
      await spacesBox.clear();

      await notesBox.close();
      await todoListsBox.close();
      await listsBox.close();
      await spacesBox.close();

      // Delete boxes from disk
      await Hive.deleteBoxFromDisk('notes');
      await Hive.deleteBoxFromDisk('todo_lists');
      await Hive.deleteBoxFromDisk('lists');
      await Hive.deleteBoxFromDisk('spaces');

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Reset PreferencesService
      PreferencesService().reset();
    });

    test('should run migration successfully on first run', () async {
      // Arrange: Create test data with different creation times
      final spacesBox = Hive.box<Space>('spaces');
      final notesBox = Hive.box<Item>('notes');
      final todoListsBox = Hive.box<TodoList>('todo_lists');
      final listsBox = Hive.box<ListModel>('lists');

      final space1 = Space(
        id: 'space-1',
        name: 'Work',
        createdAt: DateTime(2024),
      );
      await spacesBox.put(space1.id, space1);

      // Create items with different creation times
      final note1 = Item(
        id: 'note-1',
        title: 'Note 1',
        spaceId: 'space-1',
        createdAt: DateTime(2024, 1, 1, 10),
      );
      final todoList1 = TodoList(
        id: 'todo-1',
        name: 'Todo 1',
        spaceId: 'space-1',
        items: [],
        createdAt: DateTime(2024, 1, 1, 11),
      );
      final list1 = ListModel(
        id: 'list-1',
        name: 'List 1',
        spaceId: 'space-1',
        items: [],
        createdAt: DateTime(2024, 1, 1, 12),
      );

      await notesBox.put(note1.id, note1);
      await todoListsBox.put(todoList1.id, todoList1);
      await listsBox.put(list1.id, list1);

      // Act: Run migration
      await SortOrderMigration.run();

      // Assert: Check that sortOrder values are assigned correctly
      final updatedNote1 = notesBox.get('note-1');
      final updatedTodo1 = todoListsBox.get('todo-1');
      final updatedList1 = listsBox.get('list-1');

      expect(updatedNote1!.sortOrder, 0); // Earliest
      expect(updatedTodo1!.sortOrder, 1); // Middle
      expect(updatedList1!.sortOrder, 2); // Latest

      // Assert: Check that migration is marked complete
      final prefs = PreferencesService();
      expect(prefs.hasMigratedSortOrder(), true);
    });

    test('should preserve existing order by createdAt', () async {
      // Arrange: Create multiple items in specific order
      final spacesBox = Hive.box<Space>('spaces');
      final notesBox = Hive.box<Item>('notes');

      final space1 = Space(
        id: 'space-1',
        name: 'Work',
        createdAt: DateTime(2024),
      );
      await spacesBox.put(space1.id, space1);

      // Create notes in specific order
      final note1 = Item(
        id: 'note-1',
        title: 'First Note',
        spaceId: 'space-1',
        createdAt: DateTime(2024, 1, 1, 10),
      );
      final note2 = Item(
        id: 'note-2',
        title: 'Second Note',
        spaceId: 'space-1',
        createdAt: DateTime(2024, 1, 1, 11),
      );
      final note3 = Item(
        id: 'note-3',
        title: 'Third Note',
        spaceId: 'space-1',
        createdAt: DateTime(2024, 1, 1, 12),
      );

      await notesBox.put(note1.id, note1);
      await notesBox.put(note2.id, note2);
      await notesBox.put(note3.id, note3);

      // Act: Run migration
      await SortOrderMigration.run();

      // Assert: Check order is preserved
      final updatedNote1 = notesBox.get('note-1');
      final updatedNote2 = notesBox.get('note-2');
      final updatedNote3 = notesBox.get('note-3');

      expect(updatedNote1!.sortOrder, 0);
      expect(updatedNote2!.sortOrder, 1);
      expect(updatedNote3!.sortOrder, 2);
    });

    test('should scope sortOrder per space', () async {
      // Arrange: Create items in two different spaces
      final spacesBox = Hive.box<Space>('spaces');
      final notesBox = Hive.box<Item>('notes');

      final space1 = Space(
        id: 'space-1',
        name: 'Work',
        createdAt: DateTime(2024),
      );
      final space2 = Space(
        id: 'space-2',
        name: 'Personal',
        createdAt: DateTime(2024, 1, 2),
      );
      await spacesBox.put(space1.id, space1);
      await spacesBox.put(space2.id, space2);

      // Create notes in space 1
      final note1 = Item(
        id: 'note-1',
        title: 'Work Note 1',
        spaceId: 'space-1',
        createdAt: DateTime(2024, 1, 1, 10),
      );
      final note2 = Item(
        id: 'note-2',
        title: 'Work Note 2',
        spaceId: 'space-1',
        createdAt: DateTime(2024, 1, 1, 11),
      );

      // Create notes in space 2
      final note3 = Item(
        id: 'note-3',
        title: 'Personal Note 1',
        spaceId: 'space-2',
        createdAt: DateTime(2024, 1, 2, 10),
      );
      final note4 = Item(
        id: 'note-4',
        title: 'Personal Note 2',
        spaceId: 'space-2',
        createdAt: DateTime(2024, 1, 2, 11),
      );

      await notesBox.put(note1.id, note1);
      await notesBox.put(note2.id, note2);
      await notesBox.put(note3.id, note3);
      await notesBox.put(note4.id, note4);

      // Act: Run migration
      await SortOrderMigration.run();

      // Assert: Check that each space has independent sortOrder sequences
      final updatedNote1 = notesBox.get('note-1');
      final updatedNote2 = notesBox.get('note-2');
      final updatedNote3 = notesBox.get('note-3');
      final updatedNote4 = notesBox.get('note-4');

      // Space 1 should have sortOrder 0, 1
      expect(updatedNote1!.sortOrder, 0);
      expect(updatedNote2!.sortOrder, 1);

      // Space 2 should also have sortOrder 0, 1 (independent sequence)
      expect(updatedNote3!.sortOrder, 0);
      expect(updatedNote4!.sortOrder, 1);
    });

    test('should skip migration if already completed', () async {
      // Arrange: Mark migration as already completed
      final prefsService = PreferencesService();
      await prefsService.setMigratedSortOrder();

      // Create test data
      final spacesBox = Hive.box<Space>('spaces');
      final notesBox = Hive.box<Item>('notes');

      final space1 = Space(
        id: 'space-1',
        name: 'Work',
        createdAt: DateTime(2024),
      );
      await spacesBox.put(space1.id, space1);

      final note1 = Item(
        id: 'note-1',
        title: 'Note 1',
        spaceId: 'space-1',
        createdAt: DateTime(2024, 1, 1, 10),
        sortOrder: 99, // Non-standard value to prove migration didn't run
      );
      await notesBox.put(note1.id, note1);

      // Act: Run migration
      await SortOrderMigration.run();

      // Assert: Check that sortOrder was NOT changed (migration was skipped)
      final updatedNote1 = notesBox.get('note-1');
      expect(updatedNote1!.sortOrder, 99); // Should remain unchanged
    });

    test('should handle empty spaces gracefully', () async {
      // Arrange: Create space with no content
      final spacesBox = Hive.box<Space>('spaces');

      final space1 = Space(
        id: 'space-1',
        name: 'Empty Space',
        createdAt: DateTime(2024),
      );
      await spacesBox.put(space1.id, space1);

      // Act & Assert: Should not throw
      await expectLater(
        SortOrderMigration.run(),
        completes,
      );
    });

    test('should handle migration errors gracefully', () async {
      // Arrange: Close boxes to simulate error condition
      await Hive.box<Item>('notes').close();

      // Act & Assert: Should not throw even with closed box
      await expectLater(
        SortOrderMigration.run(),
        completes,
      );

      // Re-open box for tearDown
      await Hive.openBox<Item>('notes');
    });
  });
}
