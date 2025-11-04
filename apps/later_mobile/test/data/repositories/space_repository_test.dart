import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:later_mobile/data/models/note_model.dart';
import 'package:later_mobile/data/models/list_model.dart';
import 'package:later_mobile/data/models/list_item_model.dart';
import 'package:later_mobile/data/models/list_style.dart';
import 'package:later_mobile/data/models/space_model.dart';
import 'package:later_mobile/data/models/list_model.dart';
import 'package:later_mobile/data/models/list_item_model.dart';
import 'package:later_mobile/data/models/list_style.dart';
import 'package:later_mobile/data/models/todo_item_model.dart';
import 'package:later_mobile/data/models/todo_priority.dart';
import 'package:later_mobile/data/repositories/space_repository.dart';

void main() {
  group('SpaceRepository Tests', () {
    late SpaceRepository repository;
    late Box<Space> spacesBox;

    setUp(() async {
      // Initialize Hive in test directory
      const tempDir = '.dart_tool/test/hive';
      Hive.init(tempDir);

      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(SpaceAdapter());
      }

      // Open box
      spacesBox = await Hive.openBox<Space>('spaces');
      repository = SpaceRepository();
    });

    tearDown(() async {
      // Clear and close the box
      await spacesBox.clear();
      await spacesBox.close();
      await Hive.deleteBoxFromDisk('spaces');
    });

    /// Helper function to create a test space
    Space createTestSpace({
      String? id,
      String name = 'Test Space',
      String? icon,
      String? color,
      bool isArchived = false,
    }) {
      return Space(
        id: id ?? 'space-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        icon: icon,
        color: color,
        isArchived: isArchived,
      );
    }

    group('createSpace', () {
      test('should successfully create a space', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1', name: 'Work');

        // Act
        final result = await repository.createSpace(space);

        // Assert
        expect(result.id, equals('space-1'));
        expect(result.name, equals('Work'));
        expect(spacesBox.length, equals(1));
        expect(spacesBox.get('space-1'), isNotNull);
      });

      test('should add space to Hive box with correct key', () async {
        // Arrange
        final space = createTestSpace(id: 'space-2', name: 'Personal');

        // Act
        await repository.createSpace(space);

        // Assert
        final storedSpace = spacesBox.get('space-2');
        expect(storedSpace, isNotNull);
        expect(storedSpace!.name, equals('Personal'));
      });

      test('should create multiple spaces', () async {
        // Arrange
        final space1 = createTestSpace(id: 'space-1', name: 'Work');
        final space2 = createTestSpace(id: 'space-2', name: 'Personal');
        final space3 = createTestSpace(id: 'space-3', name: 'Projects');

        // Act
        await repository.createSpace(space1);
        await repository.createSpace(space2);
        await repository.createSpace(space3);

        // Assert
        expect(spacesBox.length, equals(3));
      });

      test('should create space with icon and color', () async {
        // Arrange
        final space = createTestSpace(
          id: 'space-1',
          name: 'Work',
          icon: '💼',
          color: '#FF5733',
        );

        // Act
        final result = await repository.createSpace(space);

        // Assert
        expect(result.icon, equals('💼'));
        expect(result.color, equals('#FF5733'));
      });
    });

    group('getSpaces', () {
      test('should return empty list when no spaces exist', () async {
        // Act
        final result = await repository.getSpaces();

        // Assert
        expect(result, isEmpty);
      });

      test('should return all non-archived spaces by default', () async {
        // Arrange
        final space1 = createTestSpace(id: 'space-1', name: 'Work');
        final space2 = createTestSpace(id: 'space-2', name: 'Personal');
        final space3 = createTestSpace(
          id: 'space-3',
          name: 'Archived',
          isArchived: true,
        );

        await repository.createSpace(space1);
        await repository.createSpace(space2);
        await repository.createSpace(space3);

        // Act
        final result = await repository.getSpaces();

        // Assert
        expect(result.length, equals(2));
        expect(result.every((space) => !space.isArchived), isTrue);
        expect(
          result.map((space) => space.id),
          containsAll(['space-1', 'space-2']),
        );
      });

      test('should return all spaces when includeArchived is true', () async {
        // Arrange
        final space1 = createTestSpace(id: 'space-1', name: 'Work');
        final space2 = createTestSpace(id: 'space-2', name: 'Personal');
        final space3 = createTestSpace(
          id: 'space-3',
          name: 'Archived',
          isArchived: true,
        );

        await repository.createSpace(space1);
        await repository.createSpace(space2);
        await repository.createSpace(space3);

        // Act
        final result = await repository.getSpaces(includeArchived: true);

        // Assert
        expect(result.length, equals(3));
        expect(
          result.map((space) => space.id),
          containsAll(['space-1', 'space-2', 'space-3']),
        );
      });

      test(
        'should return only archived spaces when all are archived',
        () async {
          // Arrange
          final space1 = createTestSpace(
            id: 'space-1',
            name: 'Archived 1',
            isArchived: true,
          );
          final space2 = createTestSpace(
            id: 'space-2',
            name: 'Archived 2',
            isArchived: true,
          );

          await repository.createSpace(space1);
          await repository.createSpace(space2);

          // Act
          final result = await repository.getSpaces();

          // Assert
          expect(result, isEmpty);

          // Act with includeArchived
          final resultWithArchived = await repository.getSpaces(
            includeArchived: true,
          );

          // Assert
          expect(resultWithArchived.length, equals(2));
        },
      );
    });

    group('getSpaceById', () {
      test('should return null when space does not exist', () async {
        // Act
        final result = await repository.getSpaceById('non-existent');

        // Assert
        expect(result, isNull);
      });

      test('should return correct space when it exists', () async {
        // Arrange
        final space1 = createTestSpace(id: 'space-1', name: 'Work');
        final space2 = createTestSpace(id: 'space-2', name: 'Personal');

        await repository.createSpace(space1);
        await repository.createSpace(space2);

        // Act
        final result = await repository.getSpaceById('space-2');

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals('space-2'));
        expect(result.name, equals('Personal'));
      });

      test('should return space with all properties intact', () async {
        // Arrange
        final space = createTestSpace(
          id: 'space-1',
          name: 'Work',
          icon: '💼',
          color: '#FF5733',
        );

        await repository.createSpace(space);

        // Act
        final result = await repository.getSpaceById('space-1');

        // Assert
        expect(result, isNotNull);
        expect(result!.name, equals('Work'));
        expect(result.icon, equals('💼'));
        expect(result.color, equals('#FF5733'));
      });
    });

    group('updateSpace', () {
      test('should successfully update an existing space', () async {
        // Arrange
        final originalSpace = createTestSpace(
          id: 'space-1',
          name: 'Original Name',
          icon: '📁',
        );
        await repository.createSpace(originalSpace);

        final updatedSpace = originalSpace.copyWith(
          name: 'Updated Name',
          icon: '💼',
        );

        // Act
        final result = await repository.updateSpace(updatedSpace);

        // Assert
        expect(result.name, equals('Updated Name'));
        expect(result.icon, equals('💼'));
        expect(spacesBox.get('space-1')!.name, equals('Updated Name'));
      });

      test('should update the updatedAt timestamp', () async {
        // Arrange
        final originalSpace = createTestSpace(id: 'space-1');
        await repository.createSpace(originalSpace);

        // Wait a small amount to ensure timestamp difference
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final updatedSpace = originalSpace.copyWith(name: 'New Name');

        // Act
        final result = await repository.updateSpace(updatedSpace);

        // Assert
        expect(result.updatedAt.isAfter(originalSpace.updatedAt), isTrue);
      });

      test('should throw exception when updating non-existent space', () async {
        // Arrange
        final nonExistentSpace = createTestSpace(id: 'non-existent');

        // Act & Assert
        expect(() => repository.updateSpace(nonExistentSpace), throwsException);
      });

      test('should update space archive status', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1');
        await repository.createSpace(space);

        final archivedSpace = space.copyWith(isArchived: true);

        // Act
        final result = await repository.updateSpace(archivedSpace);

        // Assert
        expect(result.isArchived, isTrue);
        expect(spacesBox.get('space-1')!.isArchived, isTrue);
      });

      test('should update space color and icon', () async {
        // Arrange
        final space = createTestSpace(
          id: 'space-1',
          icon: '📁',
          color: '#FFFFFF',
        );
        await repository.createSpace(space);

        final updatedSpace = space.copyWith(icon: '💼', color: '#FF5733');

        // Act
        final result = await repository.updateSpace(updatedSpace);

        // Assert
        expect(result.icon, equals('💼'));
        expect(result.color, equals('#FF5733'));
      });
    });

    group('deleteSpace', () {
      test('should successfully delete an existing space', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1');
        await repository.createSpace(space);
        expect(spacesBox.length, equals(1));

        // Act
        await repository.deleteSpace('space-1');

        // Assert
        expect(spacesBox.length, equals(0));
        expect(spacesBox.get('space-1'), isNull);
      });

      test('should delete correct space from multiple spaces', () async {
        // Arrange
        final space1 = createTestSpace(id: 'space-1', name: 'Space 1');
        final space2 = createTestSpace(id: 'space-2', name: 'Space 2');
        final space3 = createTestSpace(id: 'space-3', name: 'Space 3');

        await repository.createSpace(space1);
        await repository.createSpace(space2);
        await repository.createSpace(space3);

        // Act
        await repository.deleteSpace('space-2');

        // Assert
        expect(spacesBox.length, equals(2));
        expect(spacesBox.get('space-1'), isNotNull);
        expect(spacesBox.get('space-2'), isNull);
        expect(spacesBox.get('space-3'), isNotNull);
      });

      test('should handle deletion of non-existent space gracefully', () async {
        // Act & Assert - should not throw
        await repository.deleteSpace('non-existent');
        expect(spacesBox.length, equals(0));
      });
    });

    group('getItemCount', () {
      late Box<Item> notesBox;
      late Box<TodoList> todoListsBox;
      late Box<ListModel> listsBox;

      setUp(() async {
        // Register additional adapters if not already registered
        if (!Hive.isAdapterRegistered(1)) {
          Hive.registerAdapter(ItemAdapter());
        }
        if (!Hive.isAdapterRegistered(20)) {
          Hive.registerAdapter(TodoListAdapter());
        }
        if (!Hive.isAdapterRegistered(22)) {
          Hive.registerAdapter(ListModelAdapter());
        }
        if (!Hive.isAdapterRegistered(21)) {
          Hive.registerAdapter(TodoItemAdapter());
        }
        if (!Hive.isAdapterRegistered(23)) {
          Hive.registerAdapter(ListItemAdapter());
        }
        if (!Hive.isAdapterRegistered(24)) {
          Hive.registerAdapter(ListStyleAdapter());
        }

        // Open boxes
        notesBox = await Hive.openBox<Item>('notes');
        todoListsBox = await Hive.openBox<TodoList>('todo_lists');
        listsBox = await Hive.openBox<ListModel>('lists');
      });

      tearDown(() async {
        // Clear and close all boxes
        await notesBox.clear();
        await notesBox.close();
        await todoListsBox.clear();
        await todoListsBox.close();
        await listsBox.clear();
        await listsBox.close();
        await Hive.deleteBoxFromDisk('notes');
        await Hive.deleteBoxFromDisk('todo_lists');
        await Hive.deleteBoxFromDisk('lists');
      });

      test('should return 0 for space with no items', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1');
        await repository.createSpace(space);

        // Act
        final count = await repository.getItemCount('space-1');

        // Assert
        expect(count, equals(0));
      });

      test('should count notes only', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1');
        await repository.createSpace(space);

        // Add 3 notes to space-1
        await notesBox.put(
          'note-1',
          Item(
            id: 'note-1',
            title: 'Note 1',
            content: '',
            spaceId: 'space-1',
          ),
        );
        await notesBox.put(
          'note-2',
          Item(
            id: 'note-2',
            title: 'Note 2',
            content: '',
            spaceId: 'space-1',
          ),
        );
        await notesBox.put(
          'note-3',
          Item(
            id: 'note-3',
            title: 'Note 3',
            content: '',
            spaceId: 'space-1',
          ),
        );

        // Act
        final count = await repository.getItemCount('space-1');

        // Assert
        expect(count, equals(3));
      });

      test('should count todo lists only', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1');
        await repository.createSpace(space);

        // Add 2 todo lists to space-1
        await todoListsBox.put(
          'todo-1',
          TodoList(
            id: 'todo-1',
            name: 'Todo 1',
            spaceId: 'space-1',
            items: [],
          ),
        );
        await todoListsBox.put(
          'todo-2',
          TodoList(
            id: 'todo-2',
            name: 'Todo 2',
            spaceId: 'space-1',
            items: [],
          ),
        );

        // Act
        final count = await repository.getItemCount('space-1');

        // Assert
        expect(count, equals(2));
      });

      test('should count lists only', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1');
        await repository.createSpace(space);

        // Add 2 lists to space-1
        await listsBox.put(
          'list-1',
          ListModel(
            id: 'list-1',
            name: 'List 1',
            spaceId: 'space-1',
            items: [],
          ),
        );
        await listsBox.put(
          'list-2',
          ListModel(
            id: 'list-2',
            name: 'List 2',
            spaceId: 'space-1',
            items: [],
          ),
        );

        // Act
        final count = await repository.getItemCount('space-1');

        // Assert
        expect(count, equals(2));
      });

      test('should sum all item types', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1');
        await repository.createSpace(space);

        // Add 2 notes
        await notesBox.put(
          'note-1',
          Item(
            id: 'note-1',
            title: 'Note 1',
            content: '',
            spaceId: 'space-1',
          ),
        );
        await notesBox.put(
          'note-2',
          Item(
            id: 'note-2',
            title: 'Note 2',
            content: '',
            spaceId: 'space-1',
          ),
        );

        // Add 1 todo list
        await todoListsBox.put(
          'todo-1',
          TodoList(
            id: 'todo-1',
            name: 'Todo 1',
            spaceId: 'space-1',
            items: [],
          ),
        );

        // Add 3 lists
        await listsBox.put(
          'list-1',
          ListModel(
            id: 'list-1',
            name: 'List 1',
            spaceId: 'space-1',
            items: [],
          ),
        );
        await listsBox.put(
          'list-2',
          ListModel(
            id: 'list-2',
            name: 'List 2',
            spaceId: 'space-1',
            items: [],
          ),
        );
        await listsBox.put(
          'list-3',
          ListModel(
            id: 'list-3',
            name: 'List 3',
            spaceId: 'space-1',
            items: [],
          ),
        );

        // Act
        final count = await repository.getItemCount('space-1');

        // Assert
        expect(count, equals(6)); // 2 notes + 1 todo + 3 lists
      });

      test('should filter by spaceId correctly', () async {
        // Arrange
        final space1 = createTestSpace(id: 'space-1');
        final space2 = createTestSpace(id: 'space-2');
        await repository.createSpace(space1);
        await repository.createSpace(space2);

        // Add items to space-1
        await notesBox.put(
          'note-1',
          Item(
            id: 'note-1',
            title: 'Note in Space 1',
            content: '',
            spaceId: 'space-1',
          ),
        );
        await todoListsBox.put(
          'todo-1',
          TodoList(
            id: 'todo-1',
            name: 'Todo in Space 1',
            spaceId: 'space-1',
            items: [],
          ),
        );

        // Add items to space-2
        await notesBox.put(
          'note-2',
          Item(
            id: 'note-2',
            title: 'Note in Space 2',
            content: '',
            spaceId: 'space-2',
          ),
        );
        await listsBox.put(
          'list-1',
          ListModel(
            id: 'list-1',
            name: 'List in Space 2',
            spaceId: 'space-2',
            items: [],
          ),
        );

        // Act
        final count1 = await repository.getItemCount('space-1');
        final count2 = await repository.getItemCount('space-2');

        // Assert
        expect(count1, equals(2)); // 1 note + 1 todo
        expect(count2, equals(2)); // 1 note + 1 list
      });

      test('should return 0 for non-existent space', () async {
        // Act
        final count = await repository.getItemCount('non-existent-space');

        // Assert
        expect(count, equals(0));
      });
    });

    group('Edge Cases', () {
      test('should handle space with null icon', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1');

        // Act
        final result = await repository.createSpace(space);

        // Assert
        expect(result.icon, isNull);
        expect(spacesBox.get('space-1')!.icon, isNull);
      });

      test('should handle space with null color', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1');

        // Act
        final result = await repository.createSpace(space);

        // Assert
        expect(result.color, isNull);
        expect(spacesBox.get('space-1')!.color, isNull);
      });

      test('should handle space with very long name', () async {
        // Arrange
        final longName = 'A' * 1000;
        final space = createTestSpace(id: 'space-1', name: longName);

        // Act
        final result = await repository.createSpace(space);

        // Assert
        expect(result.name, equals(longName));
        expect(result.name.length, equals(1000));
      });

    });
  });
}
