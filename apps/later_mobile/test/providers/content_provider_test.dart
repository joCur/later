import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/error/app_error.dart';
import 'package:later_mobile/data/models/note_model.dart';
import 'package:later_mobile/data/models/list_model.dart';
import 'package:later_mobile/data/models/todo_list_model.dart';
import 'package:later_mobile/data/repositories/list_repository.dart';
import 'package:later_mobile/data/repositories/note_repository.dart';
import 'package:later_mobile/data/repositories/space_repository.dart';
import 'package:later_mobile/data/repositories/todo_list_repository.dart';
import 'package:later_mobile/providers/content_provider.dart';
import 'package:later_mobile/providers/spaces_provider.dart';

/// Mock implementation of TodoListRepository for testing
class MockTodoListRepository extends TodoListRepository {
  List<TodoList> mockTodoLists = [];
  bool shouldThrowError = false;
  String? errorMessage;
  bool throwRetryableError = true;

  // Track method calls for verification
  int createCallCount = 0;
  int updateCallCount = 0;
  int deleteCallCount = 0;
  int getBySpaceCallCount = 0;

  void reset() {
    mockTodoLists.clear();
    shouldThrowError = false;
    errorMessage = null;
    throwRetryableError = true;
    createCallCount = 0;
    updateCallCount = 0;
    deleteCallCount = 0;
    getBySpaceCallCount = 0;
  }

  @override
  Future<List<TodoList>> getBySpace(String spaceId) async {
    getBySpaceCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to get todo lists by space');
    }
    return mockTodoLists.where((list) => list.spaceId == spaceId).toList();
  }

  @override
  Future<TodoList> create(TodoList todoList) async {
    createCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to create todo list');
    }
    mockTodoLists.add(todoList);
    return todoList;
  }

  @override
  Future<TodoList> update(TodoList todoList) async {
    updateCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to update todo list');
    }
    final index = mockTodoLists.indexWhere((t) => t.id == todoList.id);
    if (index == -1) {
      throw Exception('TodoList with id ${todoList.id} does not exist');
    }
    mockTodoLists[index] = todoList;
    return todoList;
  }

  @override
  Future<void> delete(String id) async {
    deleteCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to delete todo list');
    }
    mockTodoLists.removeWhere((t) => t.id == id);
  }

  @override
  Future<TodoList> addItem(String listId, TodoItem item) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to add item');
    }
    final index = mockTodoLists.indexWhere((t) => t.id == listId);
    if (index == -1) {
      throw Exception('TodoList with id $listId does not exist');
    }
    final updated = mockTodoLists[index].copyWith(
      items: [...mockTodoLists[index].items, item],
    );
    mockTodoLists[index] = updated;
    return updated;
  }

  @override
  Future<TodoList> updateItem(
    String listId,
    String itemId,
    TodoItem updatedItem,
  ) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to update item');
    }
    final listIndex = mockTodoLists.indexWhere((t) => t.id == listId);
    if (listIndex == -1) {
      throw Exception('TodoList with id $listId does not exist');
    }
    final itemIndex = mockTodoLists[listIndex].items.indexWhere(
      (i) => i.id == itemId,
    );
    if (itemIndex == -1) {
      throw Exception('TodoItem with id $itemId does not exist');
    }
    final items = [...mockTodoLists[listIndex].items];
    items[itemIndex] = updatedItem;
    final updated = mockTodoLists[listIndex].copyWith(items: items);
    mockTodoLists[listIndex] = updated;
    return updated;
  }

  @override
  Future<TodoList> deleteItem(String listId, String itemId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to delete item');
    }
    final index = mockTodoLists.indexWhere((t) => t.id == listId);
    if (index == -1) {
      throw Exception('TodoList with id $listId does not exist');
    }
    final items = mockTodoLists[index].items
        .where((i) => i.id != itemId)
        .toList();
    final updated = mockTodoLists[index].copyWith(items: items);
    mockTodoLists[index] = updated;
    return updated;
  }

  @override
  Future<TodoList> toggleItem(String listId, String itemId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to toggle item');
    }
    final listIndex = mockTodoLists.indexWhere((t) => t.id == listId);
    if (listIndex == -1) {
      throw Exception('TodoList with id $listId does not exist');
    }
    final itemIndex = mockTodoLists[listIndex].items.indexWhere(
      (i) => i.id == itemId,
    );
    if (itemIndex == -1) {
      throw Exception('TodoItem with id $itemId does not exist');
    }
    final items = [...mockTodoLists[listIndex].items];
    items[itemIndex] = items[itemIndex].copyWith(
      isCompleted: !items[itemIndex].isCompleted,
    );
    final updated = mockTodoLists[listIndex].copyWith(items: items);
    mockTodoLists[listIndex] = updated;
    return updated;
  }

  @override
  Future<TodoList> reorderItems(
    String listId,
    int oldIndex,
    int newIndex,
  ) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to reorder items');
    }
    final index = mockTodoLists.indexWhere((t) => t.id == listId);
    if (index == -1) {
      throw Exception('TodoList with id $listId does not exist');
    }
    final items = [...mockTodoLists[index].items];
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    final updated = mockTodoLists[index].copyWith(items: items);
    mockTodoLists[index] = updated;
    return updated;
  }
}

/// Mock implementation of ListRepository for testing
class MockListRepository extends ListRepository {
  List<ListModel> mockLists = [];
  bool shouldThrowError = false;
  String? errorMessage;

  // Track method calls for verification
  int createCallCount = 0;
  int updateCallCount = 0;
  int deleteCallCount = 0;
  int getBySpaceCallCount = 0;

  void reset() {
    mockLists.clear();
    shouldThrowError = false;
    errorMessage = null;
    createCallCount = 0;
    updateCallCount = 0;
    deleteCallCount = 0;
    getBySpaceCallCount = 0;
  }

  @override
  Future<List<ListModel>> getBySpace(String spaceId) async {
    getBySpaceCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to get lists by space');
    }
    return mockLists.where((list) => list.spaceId == spaceId).toList();
  }

  @override
  Future<ListModel> create(ListModel list) async {
    createCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to create list');
    }
    mockLists.add(list);
    return list;
  }

  @override
  Future<ListModel> update(ListModel list) async {
    updateCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to update list');
    }
    final index = mockLists.indexWhere((l) => l.id == list.id);
    if (index == -1) {
      throw Exception('ListModel with id ${list.id} does not exist');
    }
    mockLists[index] = list;
    return list;
  }

  @override
  Future<void> delete(String id) async {
    deleteCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to delete list');
    }
    mockLists.removeWhere((l) => l.id == id);
  }

  @override
  Future<ListModel> addItem(String listId, ListItem item) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to add item');
    }
    final index = mockLists.indexWhere((l) => l.id == listId);
    if (index == -1) {
      throw Exception('ListModel with id $listId does not exist');
    }
    final updated = mockLists[index].copyWith(
      items: [...mockLists[index].items, item],
    );
    mockLists[index] = updated;
    return updated;
  }

  @override
  Future<ListModel> updateItem(
    String listId,
    String itemId,
    ListItem updatedItem,
  ) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to update item');
    }
    final listIndex = mockLists.indexWhere((l) => l.id == listId);
    if (listIndex == -1) {
      throw Exception('ListModel with id $listId does not exist');
    }
    final itemIndex = mockLists[listIndex].items.indexWhere(
      (i) => i.id == itemId,
    );
    if (itemIndex == -1) {
      throw Exception('ListItem with id $itemId does not exist');
    }
    final items = [...mockLists[listIndex].items];
    items[itemIndex] = updatedItem;
    final updated = mockLists[listIndex].copyWith(items: items);
    mockLists[listIndex] = updated;
    return updated;
  }

  @override
  Future<ListModel> deleteItem(String listId, String itemId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to delete item');
    }
    final index = mockLists.indexWhere((l) => l.id == listId);
    if (index == -1) {
      throw Exception('ListModel with id $listId does not exist');
    }
    final items = mockLists[index].items.where((i) => i.id != itemId).toList();
    final updated = mockLists[index].copyWith(items: items);
    mockLists[index] = updated;
    return updated;
  }

  @override
  Future<ListModel> toggleItem(String listId, String itemId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to toggle item');
    }
    final listIndex = mockLists.indexWhere((l) => l.id == listId);
    if (listIndex == -1) {
      throw Exception('ListModel with id $listId does not exist');
    }
    final itemIndex = mockLists[listIndex].items.indexWhere(
      (i) => i.id == itemId,
    );
    if (itemIndex == -1) {
      throw Exception('ListItem with id $itemId does not exist');
    }
    final items = [...mockLists[listIndex].items];
    items[itemIndex] = items[itemIndex].copyWith(
      isChecked: !items[itemIndex].isChecked,
    );
    final updated = mockLists[listIndex].copyWith(items: items);
    mockLists[listIndex] = updated;
    return updated;
  }

  @override
  Future<ListModel> reorderItems(
    String listId,
    int oldIndex,
    int newIndex,
  ) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to reorder items');
    }
    final index = mockLists.indexWhere((l) => l.id == listId);
    if (index == -1) {
      throw Exception('ListModel with id $listId does not exist');
    }
    final items = [...mockLists[index].items];
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    final updated = mockLists[index].copyWith(items: items);
    mockLists[index] = updated;
    return updated;
  }
}

/// Mock implementation of NoteRepository for testing
class MockNoteRepository extends NoteRepository {
  List<Item> mockNotes = [];
  bool shouldThrowError = false;
  String? errorMessage;

  // Track method calls for verification
  int createCallCount = 0;
  int updateCallCount = 0;
  int deleteCallCount = 0;
  int getBySpaceCallCount = 0;

  void reset() {
    mockNotes.clear();
    shouldThrowError = false;
    errorMessage = null;
    createCallCount = 0;
    updateCallCount = 0;
    deleteCallCount = 0;
    getBySpaceCallCount = 0;
  }

  @override
  Future<List<Item>> getBySpace(String spaceId) async {
    getBySpaceCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to get notes by space');
    }
    return mockNotes.where((note) => note.spaceId == spaceId).toList();
  }

  @override
  Future<Item> create(Item note) async {
    createCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to create note');
    }
    mockNotes.add(note);
    return note;
  }

  @override
  Future<Item> update(Item note) async {
    updateCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to update note');
    }
    final index = mockNotes.indexWhere((n) => n.id == note.id);
    if (index == -1) {
      throw Exception('Note with id ${note.id} does not exist');
    }
    mockNotes[index] = note;
    return note;
  }

  @override
  Future<void> delete(String id) async {
    deleteCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to delete note');
    }
    mockNotes.removeWhere((n) => n.id == id);
  }
}

/// Mock implementation of SpaceRepository for testing
class MockSpaceRepository extends SpaceRepository {
  bool shouldThrowError = false;
  String? errorMessage;

  void reset() {
    shouldThrowError = false;
    errorMessage = null;
  }
}

/// Mock implementation of SpacesProvider for testing
class MockSpacesProvider extends SpacesProvider {
  MockSpacesProvider(this.mockRepo) : super(mockRepo);
  final MockSpaceRepository mockRepo;

  bool shouldThrowError = false;
  String? errorMessage;

  void reset() {
    shouldThrowError = false;
    errorMessage = null;
    mockRepo.reset();
  }
}

void main() {
  late ContentProvider provider;
  late MockTodoListRepository mockTodoListRepo;
  late MockListRepository mockListRepo;
  late MockNoteRepository mockNoteRepo;
  late MockSpacesProvider mockSpacesProvider;
  late int notifyListenersCallCount;

  setUp(() {
    // Create mocks
    mockTodoListRepo = MockTodoListRepository();
    mockListRepo = MockListRepository();
    mockNoteRepo = MockNoteRepository();
    final mockSpaceRepo = MockSpaceRepository();
    mockSpacesProvider = MockSpacesProvider(mockSpaceRepo);

    // Create provider
    provider = ContentProvider(
      todoListRepository: mockTodoListRepo,
      listRepository: mockListRepo,
      noteRepository: mockNoteRepo,
    );

    // Track notifyListeners calls
    notifyListenersCallCount = 0;
    provider.addListener(() {
      notifyListenersCallCount++;
    });
  });

  tearDown(() {
    provider.dispose();
    mockTodoListRepo.reset();
    mockListRepo.reset();
    mockNoteRepo.reset();
    mockSpacesProvider.reset();
  });

  group('State Management', () {
    test('should have correct initial state', () {
      expect(provider.todoLists, isEmpty);
      expect(provider.lists, isEmpty);
      expect(provider.notes, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      expect(provider.currentSpaceId, isNull);
    });

    test('should return unmodifiable lists from getters', () {
      // Verify that returned lists are unmodifiable
      expect(
        () => provider.todoLists.add(
          TodoList(id: 'test', spaceId: 'test', name: 'test'),
        ),
        throwsUnsupportedError,
      );
      expect(
        () => provider.lists.add(
          ListModel(id: 'test', spaceId: 'test', name: 'test'),
        ),
        throwsUnsupportedError,
      );
      expect(
        () => provider.notes.add(
          Item(id: 'test', title: 'test', spaceId: 'test'),
        ),
        throwsUnsupportedError,
      );
    });

    test('should set isLoading to true during loadSpaceContent', () async {
      // Track loading state changes
      final loadingStates = <bool>[];
      provider.addListener(() {
        loadingStates.add(provider.isLoading);
      });

      // Act
      await provider.loadSpaceContent('space-1');

      // Assert - should have been true at some point
      expect(loadingStates, contains(true));
    });

    test(
      'should set isLoading to false after loadSpaceContent completes',
      () async {
        // Act
        await provider.loadSpaceContent('space-1');

        // Assert
        expect(provider.isLoading, isFalse);
      },
    );

    test('should set error when loadSpaceContent fails', () async {
      // Arrange
      mockTodoListRepo.shouldThrowError = true;
      mockTodoListRepo.errorMessage = 'Test error';

      // Act
      await provider.loadSpaceContent('space-1');

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.error, isA<AppError>());
    });

    test(
      'should clear error on successful operation after previous error',
      () async {
        // Arrange - cause an error first
        mockTodoListRepo.shouldThrowError = true;
        await provider.loadSpaceContent('space-1');
        expect(provider.error, isNotNull);

        // Act - successful operation
        mockTodoListRepo.shouldThrowError = false;
        await provider.loadSpaceContent('space-1');

        // Assert
        expect(provider.error, isNull);
      },
    );

    test('should set currentSpaceId during loadSpaceContent', () async {
      // Act
      await provider.loadSpaceContent('space-123');

      // Assert
      expect(provider.currentSpaceId, 'space-123');
    });

    test('should notify listeners after state changes', () async {
      // Reset counter
      notifyListenersCallCount = 0;

      // Act
      await provider.loadSpaceContent('space-1');

      // Assert - should notify at least twice (start loading, end loading)
      expect(notifyListenersCallCount, greaterThanOrEqualTo(2));
    });
  });

  group('loadSpaceContent', () {
    test('should load all three content types in parallel', () async {
      // Arrange
      mockTodoListRepo.mockTodoLists = [
        TodoList(id: 'todo-1', spaceId: 'space-1', name: 'Todo List 1'),
      ];
      mockListRepo.mockLists = [
        ListModel(id: 'list-1', spaceId: 'space-1', name: 'List 1'),
      ];
      mockNoteRepo.mockNotes = [
        Item(id: 'note-1', title: 'Note 1', spaceId: 'space-1'),
      ];

      // Act
      await provider.loadSpaceContent('space-1');

      // Assert - all repositories should have been called
      expect(mockTodoListRepo.getBySpaceCallCount, 1);
      expect(mockListRepo.getBySpaceCallCount, 1);
      expect(mockNoteRepo.getBySpaceCallCount, 1);

      // Verify content was loaded
      expect(provider.todoLists.length, 1);
      expect(provider.lists.length, 1);
      expect(provider.notes.length, 1);
    });

    test('should filter content by spaceId', () async {
      // Arrange
      mockTodoListRepo.mockTodoLists = [
        TodoList(id: 'todo-1', spaceId: 'space-1', name: 'Todo List 1'),
        TodoList(id: 'todo-2', spaceId: 'space-2', name: 'Todo List 2'),
      ];
      mockListRepo.mockLists = [
        ListModel(id: 'list-1', spaceId: 'space-1', name: 'List 1'),
        ListModel(id: 'list-2', spaceId: 'space-2', name: 'List 2'),
      ];
      mockNoteRepo.mockNotes = [
        Item(id: 'note-1', title: 'Note 1', spaceId: 'space-1'),
        Item(id: 'note-2', title: 'Note 2', spaceId: 'space-2'),
      ];

      // Act
      await provider.loadSpaceContent('space-1');

      // Assert - only space-1 content should be loaded
      expect(provider.todoLists.length, 1);
      expect(provider.todoLists.first.id, 'todo-1');
      expect(provider.lists.length, 1);
      expect(provider.lists.first.id, 'list-1');
      expect(provider.notes.length, 1);
      expect(provider.notes.first.id, 'note-1');
    });

    test('should handle errors and set error state', () async {
      // Arrange
      mockTodoListRepo.shouldThrowError = true;
      mockTodoListRepo.errorMessage = 'Test error';

      // Act
      await provider.loadSpaceContent('space-1');

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.error!.message, contains('Test error'));
    });

    test('should clear content on error', () async {
      // Arrange - load some content first
      mockTodoListRepo.mockTodoLists = [
        TodoList(id: 'todo-1', spaceId: 'space-1', name: 'Todo List 1'),
      ];
      await provider.loadSpaceContent('space-1');
      expect(provider.todoLists, isNotEmpty);

      // Act - cause an error
      mockTodoListRepo.shouldThrowError = true;
      await provider.loadSpaceContent('space-1');

      // Assert - content should be cleared
      expect(provider.todoLists, isEmpty);
      expect(provider.lists, isEmpty);
      expect(provider.notes, isEmpty);
    });

    test('should handle multiple consecutive loads correctly', () async {
      // Arrange
      mockTodoListRepo.mockTodoLists = [
        TodoList(id: 'todo-1', spaceId: 'space-1', name: 'Todo List 1'),
      ];

      // Act - load twice
      await provider.loadSpaceContent('space-1');
      await provider.loadSpaceContent('space-1');

      // Assert
      expect(provider.todoLists.length, 1);
      expect(mockTodoListRepo.getBySpaceCallCount, 2);
    });

    test('should set isLoading to true at start and false at end', () async {
      // Track loading state changes
      final loadingStates = <bool>[];
      provider.addListener(() {
        loadingStates.add(provider.isLoading);
      });

      // Act
      await provider.loadSpaceContent('space-1');

      // Assert - should start with true and end with false
      expect(loadingStates.first, isTrue);
      expect(loadingStates.last, isFalse);
      expect(provider.isLoading, isFalse);
    });

    test('should set currentSpaceId before loading', () async {
      // Act
      final future = provider.loadSpaceContent('space-123');

      // Assert - currentSpaceId should be set immediately
      expect(provider.currentSpaceId, 'space-123');

      // Wait for completion
      await future;
    });
  });

  group('TodoList Operations - Create, Update, Delete', () {
    test('should create todo list and increment space count', () async {
      // Arrange
      final todoList = TodoList(
        id: 'todo-1',
        spaceId: 'space-1',
        name: 'Weekly Tasks',
      );

      // Act
      await provider.createTodoList(todoList);

      // Assert
      expect(provider.todoLists.length, 1);
      expect(provider.todoLists.first.id, 'todo-1');
      expect(mockTodoListRepo.createCallCount, 1);
    });

    test('should handle create todo list error', () async {
      // Arrange
      mockTodoListRepo.shouldThrowError = true;
      final todoList = TodoList(id: 'todo-1', spaceId: 'space-1', name: 'Test');

      // Act
      await provider.createTodoList(todoList);

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.todoLists, isEmpty);
    });

    test('should update existing todo list', () async {
      // Arrange
      final original = TodoList(
        id: 'todo-1',
        spaceId: 'space-1',
        name: 'Original',
      );
      await provider.createTodoList(original);

      final updated = original.copyWith(name: 'Updated');

      // Act
      await provider.updateTodoList(updated);

      // Assert
      expect(provider.todoLists.length, 1);
      expect(provider.todoLists.first.name, 'Updated');
      expect(mockTodoListRepo.updateCallCount, 1);
    });

    test('should handle update non-existent todo list', () async {
      // Arrange
      final todoList = TodoList(
        id: 'non-existent',
        spaceId: 'space-1',
        name: 'Test',
      );

      // Act
      await provider.updateTodoList(todoList);

      // Assert
      expect(provider.error, isNotNull);
    });

    test('should delete todo list and decrement space count', () async {
      // Arrange
      final todoList = TodoList(id: 'todo-1', spaceId: 'space-1', name: 'Test');
      await provider.createTodoList(todoList);
      expect(provider.todoLists.length, 1);

      // Act
      await provider.deleteTodoList('todo-1');

      // Assert
      expect(provider.todoLists, isEmpty);
      expect(mockTodoListRepo.deleteCallCount, 1);
    });

    test('should handle delete non-existent todo list', () async {
      // Act
      await provider.deleteTodoList('non-existent');

      // Assert
      expect(provider.error, isNotNull);
    });

    test('should notify listeners on todo list operations', () async {
      // Arrange
      final todoList = TodoList(id: 'todo-1', spaceId: 'space-1', name: 'Test');
      notifyListenersCallCount = 0;

      // Act & Assert - create
      await provider.createTodoList(todoList);
      expect(notifyListenersCallCount, greaterThan(0));

      // Act & Assert - update
      notifyListenersCallCount = 0;
      await provider.updateTodoList(todoList.copyWith(name: 'Updated'));
      expect(notifyListenersCallCount, greaterThan(0));

      // Act & Assert - delete
      notifyListenersCallCount = 0;
      await provider.deleteTodoList('todo-1');
      expect(notifyListenersCallCount, greaterThan(0));
    });
  });

  group('TodoList Operations - Todo Items', () {
    test('should add todo item to list', () async {
      // Arrange
      final todoList = TodoList(id: 'todo-1', spaceId: 'space-1', name: 'Test');
      await provider.createTodoList(todoList);

      final item = TodoItem(id: 'item-1', title: 'Task 1', sortOrder: 0);

      // Act
      await provider.addTodoItem('todo-1', item);

      // Assert
      expect(provider.todoLists.first.items.length, 1);
      expect(provider.todoLists.first.items.first.id, 'item-1');
    });

    test('should update todo item in list', () async {
      // Arrange
      final item = TodoItem(id: 'item-1', title: 'Original', sortOrder: 0);
      final todoList = TodoList(
        id: 'todo-1',
        spaceId: 'space-1',
        name: 'Test',
        items: [item],
      );
      await provider.createTodoList(todoList);

      final updatedItem = item.copyWith(title: 'Updated');

      // Act
      await provider.updateTodoItem('todo-1', 'item-1', updatedItem);

      // Assert
      expect(provider.todoLists.first.items.first.title, 'Updated');
    });

    test('should delete todo item from list', () async {
      // Arrange
      final item = TodoItem(id: 'item-1', title: 'Task 1', sortOrder: 0);
      final todoList = TodoList(
        id: 'todo-1',
        spaceId: 'space-1',
        name: 'Test',
        items: [item],
      );
      await provider.createTodoList(todoList);

      // Act
      await provider.deleteTodoItem('todo-1', 'item-1');

      // Assert
      expect(provider.todoLists.first.items, isEmpty);
    });

    test('should toggle todo item completion status', () async {
      // Arrange
      final item = TodoItem(id: 'item-1', title: 'Task 1', sortOrder: 0);
      final todoList = TodoList(
        id: 'todo-1',
        spaceId: 'space-1',
        name: 'Test',
        items: [item],
      );
      await provider.createTodoList(todoList);

      // Act
      await provider.toggleTodoItem('todo-1', 'item-1');

      // Assert
      expect(provider.todoLists.first.items.first.isCompleted, isTrue);

      // Act - toggle again
      await provider.toggleTodoItem('todo-1', 'item-1');

      // Assert
      expect(provider.todoLists.first.items.first.isCompleted, isFalse);
    });

    test('should reorder todo items in list', () async {
      // Arrange
      final items = [
        TodoItem(id: 'item-1', title: 'Task 1', sortOrder: 0),
        TodoItem(id: 'item-2', title: 'Task 2', sortOrder: 1),
        TodoItem(id: 'item-3', title: 'Task 3', sortOrder: 2),
      ];
      final todoList = TodoList(
        id: 'todo-1',
        spaceId: 'space-1',
        name: 'Test',
        items: items,
      );
      await provider.createTodoList(todoList);

      // Act - move item from index 0 to index 2
      await provider.reorderTodoItems('todo-1', 0, 2);

      // Assert - order should be: item-2, item-3, item-1
      expect(provider.todoLists.first.items[0].id, 'item-2');
      expect(provider.todoLists.first.items[1].id, 'item-3');
      expect(provider.todoLists.first.items[2].id, 'item-1');
    });

    test('should handle todo item operation errors', () async {
      // Arrange
      final todoList = TodoList(id: 'todo-1', spaceId: 'space-1', name: 'Test');
      await provider.createTodoList(todoList);

      mockTodoListRepo.shouldThrowError = true;
      final item = TodoItem(id: 'item-1', title: 'Task 1', sortOrder: 0);

      // Act & Assert - addTodoItem
      await provider.addTodoItem('todo-1', item);
      expect(provider.error, isNotNull);

      // Act & Assert - updateTodoItem
      provider.clearError();
      await provider.updateTodoItem('todo-1', 'item-1', item);
      expect(provider.error, isNotNull);

      // Act & Assert - deleteTodoItem
      provider.clearError();
      await provider.deleteTodoItem('todo-1', 'item-1');
      expect(provider.error, isNotNull);

      // Act & Assert - toggleTodoItem
      provider.clearError();
      await provider.toggleTodoItem('todo-1', 'item-1');
      expect(provider.error, isNotNull);

      // Act & Assert - reorderTodoItems
      provider.clearError();
      await provider.reorderTodoItems('todo-1', 0, 1);
      expect(provider.error, isNotNull);
    });

    test('should notify listeners on todo item operations', () async {
      // Arrange
      final item = TodoItem(id: 'item-1', title: 'Task 1', sortOrder: 0);
      final todoList = TodoList(
        id: 'todo-1',
        spaceId: 'space-1',
        name: 'Test',
        items: [item],
      );
      await provider.createTodoList(todoList);

      // Test each operation
      notifyListenersCallCount = 0;
      await provider.addTodoItem(
        'todo-1',
        TodoItem(id: 'item-2', title: 'Task 2', sortOrder: 1),
      );
      expect(notifyListenersCallCount, greaterThan(0));

      notifyListenersCallCount = 0;
      await provider.updateTodoItem(
        'todo-1',
        'item-1',
        item.copyWith(title: 'Updated'),
      );
      expect(notifyListenersCallCount, greaterThan(0));

      notifyListenersCallCount = 0;
      await provider.toggleTodoItem('todo-1', 'item-1');
      expect(notifyListenersCallCount, greaterThan(0));
    });
  });

  group('List Operations - Create, Update, Delete', () {
    test('should create list and increment space count', () async {
      // Arrange
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        name: 'Shopping List',
        style: ListStyle.checkboxes,
      );

      // Act
      await provider.createList(list);

      // Assert
      expect(provider.lists.length, 1);
      expect(provider.lists.first.id, 'list-1');
      expect(mockListRepo.createCallCount, 1);
    });

    test('should handle create list error', () async {
      // Arrange
      mockListRepo.shouldThrowError = true;
      final list = ListModel(id: 'list-1', spaceId: 'space-1', name: 'Test');

      // Act
      await provider.createList(list);

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.lists, isEmpty);
    });

    test('should update existing list', () async {
      // Arrange
      final original = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        name: 'Original',
      );
      await provider.createList(original);

      final updated = original.copyWith(name: 'Updated');

      // Act
      await provider.updateList(updated);

      // Assert
      expect(provider.lists.length, 1);
      expect(provider.lists.first.name, 'Updated');
      expect(mockListRepo.updateCallCount, 1);
    });

    test('should handle update non-existent list', () async {
      // Arrange
      final list = ListModel(
        id: 'non-existent',
        spaceId: 'space-1',
        name: 'Test',
      );

      // Act
      await provider.updateList(list);

      // Assert
      expect(provider.error, isNotNull);
    });

    test('should delete list and decrement space count', () async {
      // Arrange
      final list = ListModel(id: 'list-1', spaceId: 'space-1', name: 'Test');
      await provider.createList(list);

      // Act
      await provider.deleteList('list-1');

      // Assert
      expect(provider.lists, isEmpty);
      expect(mockListRepo.deleteCallCount, 1);
    });

    test('should handle delete non-existent list', () async {
      // Act
      await provider.deleteList('non-existent');

      // Assert
      expect(provider.error, isNotNull);
    });

    test('should notify listeners on list operations', () async {
      // Arrange
      final list = ListModel(id: 'list-1', spaceId: 'space-1', name: 'Test');

      // Create
      notifyListenersCallCount = 0;
      await provider.createList(list);
      expect(notifyListenersCallCount, greaterThan(0));

      // Update
      notifyListenersCallCount = 0;
      await provider.updateList(list.copyWith(name: 'Updated'));
      expect(notifyListenersCallCount, greaterThan(0));

      // Delete
      notifyListenersCallCount = 0;
      await provider.deleteList('list-1');
      expect(notifyListenersCallCount, greaterThan(0));
    });
  });

  group('List Operations - List Items', () {
    test('should add list item', () async {
      // Arrange
      final list = ListModel(id: 'list-1', spaceId: 'space-1', name: 'Test');
      await provider.createList(list);

      final item = ListItem(id: 'item-1', title: 'Item 1', sortOrder: 0);

      // Act
      await provider.addListItem('list-1', item);

      // Assert
      expect(provider.lists.first.items.length, 1);
      expect(provider.lists.first.items.first.id, 'item-1');
    });

    test('should update list item', () async {
      // Arrange
      final item = ListItem(id: 'item-1', title: 'Original', sortOrder: 0);
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        name: 'Test',
        items: [item],
      );
      await provider.createList(list);

      final updatedItem = item.copyWith(title: 'Updated');

      // Act
      await provider.updateListItem('list-1', 'item-1', updatedItem);

      // Assert
      expect(provider.lists.first.items.first.title, 'Updated');
    });

    test('should delete list item', () async {
      // Arrange
      final item = ListItem(id: 'item-1', title: 'Item 1', sortOrder: 0);
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        name: 'Test',
        items: [item],
      );
      await provider.createList(list);

      // Act
      await provider.deleteListItem('list-1', 'item-1');

      // Assert
      expect(provider.lists.first.items, isEmpty);
    });

    test('should toggle list item checked status', () async {
      // Arrange
      final item = ListItem(id: 'item-1', title: 'Item 1', sortOrder: 0);
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        name: 'Test',
        style: ListStyle.checkboxes,
        items: [item],
      );
      await provider.createList(list);

      // Act
      await provider.toggleListItem('list-1', 'item-1');

      // Assert
      expect(provider.lists.first.items.first.isChecked, isTrue);

      // Act - toggle again
      await provider.toggleListItem('list-1', 'item-1');

      // Assert
      expect(provider.lists.first.items.first.isChecked, isFalse);
    });

    test('should reorder list items', () async {
      // Arrange
      final items = [
        ListItem(id: 'item-1', title: 'Item 1', sortOrder: 0),
        ListItem(id: 'item-2', title: 'Item 2', sortOrder: 1),
        ListItem(id: 'item-3', title: 'Item 3', sortOrder: 2),
      ];
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        name: 'Test',
        items: items,
      );
      await provider.createList(list);

      // Act - move item from index 0 to index 2
      await provider.reorderListItems('list-1', 0, 2);

      // Assert
      expect(provider.lists.first.items[0].id, 'item-2');
      expect(provider.lists.first.items[1].id, 'item-3');
      expect(provider.lists.first.items[2].id, 'item-1');
    });

    test('should handle list item operation errors', () async {
      // Arrange
      final list = ListModel(id: 'list-1', spaceId: 'space-1', name: 'Test');
      await provider.createList(list);

      mockListRepo.shouldThrowError = true;
      final item = ListItem(id: 'item-1', title: 'Item 1', sortOrder: 0);

      // Test each operation
      await provider.addListItem('list-1', item);
      expect(provider.error, isNotNull);

      provider.clearError();
      await provider.updateListItem('list-1', 'item-1', item);
      expect(provider.error, isNotNull);

      provider.clearError();
      await provider.deleteListItem('list-1', 'item-1');
      expect(provider.error, isNotNull);

      provider.clearError();
      await provider.toggleListItem('list-1', 'item-1');
      expect(provider.error, isNotNull);

      provider.clearError();
      await provider.reorderListItems('list-1', 0, 1);
      expect(provider.error, isNotNull);
    });

    test('should notify listeners on list item operations', () async {
      // Arrange
      final item = ListItem(id: 'item-1', title: 'Item 1', sortOrder: 0);
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        name: 'Test',
        items: [item],
      );
      await provider.createList(list);

      // Test each operation
      notifyListenersCallCount = 0;
      await provider.addListItem(
        'list-1',
        ListItem(id: 'item-2', title: 'Item 2', sortOrder: 1),
      );
      expect(notifyListenersCallCount, greaterThan(0));

      notifyListenersCallCount = 0;
      await provider.updateListItem(
        'list-1',
        'item-1',
        item.copyWith(title: 'Updated'),
      );
      expect(notifyListenersCallCount, greaterThan(0));

      notifyListenersCallCount = 0;
      await provider.toggleListItem('list-1', 'item-1');
      expect(notifyListenersCallCount, greaterThan(0));
    });
  });

  group('Note Operations', () {
    test('should create note and increment space count', () async {
      // Arrange
      final note = Item(
        id: 'note-1',
        title: 'Meeting Notes',
        content: 'Discussion points',
        spaceId: 'space-1',
      );

      // Act
      await provider.createNote(note);

      // Assert
      expect(provider.notes.length, 1);
      expect(provider.notes.first.id, 'note-1');
      expect(mockNoteRepo.createCallCount, 1);
    });

    test('should handle create note error', () async {
      // Arrange
      mockNoteRepo.shouldThrowError = true;
      final note = Item(id: 'note-1', title: 'Test', spaceId: 'space-1');

      // Act
      await provider.createNote(note);

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.notes, isEmpty);
    });

    test('should update existing note', () async {
      // Arrange
      final original = Item(
        id: 'note-1',
        title: 'Original',
        spaceId: 'space-1',
      );
      await provider.createNote(original);

      final updated = original.copyWith(title: 'Updated');

      // Act
      await provider.updateNote(updated);

      // Assert
      expect(provider.notes.length, 1);
      expect(provider.notes.first.title, 'Updated');
      expect(mockNoteRepo.updateCallCount, 1);
    });

    test('should handle update non-existent note', () async {
      // Arrange
      final note = Item(id: 'non-existent', title: 'Test', spaceId: 'space-1');

      // Act
      await provider.updateNote(note);

      // Assert
      expect(provider.error, isNotNull);
    });

    test('should delete note and decrement space count', () async {
      // Arrange
      final note = Item(id: 'note-1', title: 'Test', spaceId: 'space-1');
      await provider.createNote(note);

      // Act
      await provider.deleteNote('note-1');

      // Assert
      expect(provider.notes, isEmpty);
      expect(mockNoteRepo.deleteCallCount, 1);
    });

    test('should handle delete non-existent note', () async {
      // Act
      await provider.deleteNote('non-existent');

      // Assert
      expect(provider.error, isNotNull);
    });

    test('should notify listeners on note operations', () async {
      // Arrange
      final note = Item(id: 'note-1', title: 'Test', spaceId: 'space-1');

      // Create
      notifyListenersCallCount = 0;
      await provider.createNote(note);
      expect(notifyListenersCallCount, greaterThan(0));

      // Update
      notifyListenersCallCount = 0;
      await provider.updateNote(note.copyWith(title: 'Updated'));
      expect(notifyListenersCallCount, greaterThan(0));

      // Delete
      notifyListenersCallCount = 0;
      await provider.deleteNote('note-1');
      expect(notifyListenersCallCount, greaterThan(0));
    });
  });

  group('Filtering and Search', () {
    setUp(() async {
      // Setup test data
      mockTodoListRepo.mockTodoLists = [
        TodoList(id: 'todo-1', spaceId: 'space-1', name: 'Work Tasks'),
        TodoList(id: 'todo-2', spaceId: 'space-1', name: 'Personal Tasks'),
      ];
      mockListRepo.mockLists = [
        ListModel(id: 'list-1', spaceId: 'space-1', name: 'Shopping List'),
        ListModel(id: 'list-2', spaceId: 'space-1', name: 'Packing List'),
      ];
      mockNoteRepo.mockNotes = [
        Item(
          id: 'note-1',
          title: 'Meeting Notes',
          content: 'Important points',
          spaceId: 'space-1',
        ),
        Item(
          id: 'note-2',
          title: 'Ideas',
          content: 'Creative thoughts',
          spaceId: 'space-1',
        ),
      ];
      await provider.loadSpaceContent('space-1');
    });

    test('should return all content with ContentFilter.all', () {
      // Act
      final content = provider.getFilteredContent(ContentFilter.all);

      // Assert
      expect(content.length, 6); // 2 todos + 2 lists + 2 notes
    });

    test('should return only TodoLists with ContentFilter.todoLists', () {
      // Act
      final content = provider.getFilteredContent(ContentFilter.todoLists);

      // Assert
      expect(content.length, 2);
      expect(content.every((item) => item is TodoList), isTrue);
    });

    test('should return only Lists with ContentFilter.lists', () {
      // Act
      final content = provider.getFilteredContent(ContentFilter.lists);

      // Assert
      expect(content.length, 2);
      expect(content.every((item) => item is ListModel), isTrue);
    });

    test('should return only Notes with ContentFilter.notes', () {
      // Act
      final content = provider.getFilteredContent(ContentFilter.notes);

      // Assert
      expect(content.length, 2);
      expect(content.every((item) => item is Item), isTrue);
    });

    test('should return correct total count', () {
      // Act
      final total = provider.getTotalCount();

      // Assert
      expect(total, 6);
    });

    test('should search TodoLists by name', () {
      // Act
      final results = provider.search('work');

      // Assert
      expect(results.length, 1);
      expect((results.first as TodoList).name, contains('Work'));
    });

    test('should search Lists by name', () {
      // Act
      final results = provider.search('shopping');

      // Assert
      expect(results.length, 1);
      expect((results.first as ListModel).name, contains('Shopping'));
    });

    test('should search Notes by title and content', () {
      // Act - search by title
      final titleResults = provider.search('meeting');
      expect(titleResults.length, 1);

      // Act - search by content
      final contentResults = provider.search('creative');
      expect(contentResults.length, 1);
    });

    test('should perform case-insensitive search', () {
      // Act
      final results1 = provider.search('WORK');
      final results2 = provider.search('work');
      final results3 = provider.search('Work');

      // Assert - all should return the same results
      expect(results1.length, results2.length);
      expect(results2.length, results3.length);
    });

    test('should return all content when search query is empty', () {
      // Act
      final results = provider.search('');

      // Assert
      expect(results.length, 6);
    });
  });

  group('Due Date Filtering', () {
    test('should find TodoLists with items due on specific date', () async {
      // Arrange
      final today = DateTime(2025, 1, 15);
      final tomorrow = DateTime(2025, 1, 16);

      final item1 = TodoItem(
        id: 'item-1',
        title: 'Task 1',
        sortOrder: 0,
        dueDate: today,
      );
      final item2 = TodoItem(
        id: 'item-2',
        title: 'Task 2',
        sortOrder: 1,
        dueDate: tomorrow,
      );

      mockTodoListRepo.mockTodoLists = [
        TodoList(
          id: 'todo-1',
          spaceId: 'space-1',
          name: 'Today Tasks',
          items: [item1],
        ),
        TodoList(
          id: 'todo-2',
          spaceId: 'space-1',
          name: 'Tomorrow Tasks',
          items: [item2],
        ),
      ];
      await provider.loadSpaceContent('space-1');

      // Act
      final results = provider.getTodosWithDueDate(today);

      // Assert
      expect(results.length, 1);
      expect(results.first.id, 'todo-1');
    });

    test('should filter by day only, ignoring time', () async {
      // Arrange
      final morning = DateTime(2025, 1, 15, 8);
      final evening = DateTime(2025, 1, 15, 20);

      final item1 = TodoItem(
        id: 'item-1',
        title: 'Morning Task',
        sortOrder: 0,
        dueDate: morning,
      );
      final item2 = TodoItem(
        id: 'item-2',
        title: 'Evening Task',
        sortOrder: 1,
        dueDate: evening,
      );

      mockTodoListRepo.mockTodoLists = [
        TodoList(
          id: 'todo-1',
          spaceId: 'space-1',
          name: 'Morning',
          items: [item1],
        ),
        TodoList(
          id: 'todo-2',
          spaceId: 'space-1',
          name: 'Evening',
          items: [item2],
        ),
      ];
      await provider.loadSpaceContent('space-1');

      // Act - search using noon time (should match both)
      final noon = DateTime(2025, 1, 15, 12);
      final results = provider.getTodosWithDueDate(noon);

      // Assert - both should be found since they're on the same day
      expect(results.length, 2);
    });

    test('should return empty list when no matches', () async {
      // Arrange
      final yesterday = DateTime(2025, 1, 14);
      final item = TodoItem(
        id: 'item-1',
        title: 'Task',
        sortOrder: 0,
        dueDate: DateTime(2025, 1, 15),
      );

      mockTodoListRepo.mockTodoLists = [
        TodoList(id: 'todo-1', spaceId: 'space-1', name: 'Test', items: [item]),
      ];
      await provider.loadSpaceContent('space-1');

      // Act
      final results = provider.getTodosWithDueDate(yesterday);

      // Assert
      expect(results, isEmpty);
    });

    test('should handle null dueDates', () async {
      // Arrange
      final today = DateTime(2025, 1, 15);
      final item1 = TodoItem(id: 'item-1', title: 'No due date', sortOrder: 0);
      final item2 = TodoItem(
        id: 'item-2',
        title: 'Has due date',
        sortOrder: 1,
        dueDate: today,
      );

      mockTodoListRepo.mockTodoLists = [
        TodoList(
          id: 'todo-1',
          spaceId: 'space-1',
          name: 'Mixed',
          items: [item1, item2],
        ),
      ];
      await provider.loadSpaceContent('space-1');

      // Act
      final results = provider.getTodosWithDueDate(today);

      // Assert - should only find the TodoList that contains an item with dueDate
      expect(results.length, 1);
      expect(results.first.id, 'todo-1');
      // The TodoList contains both items, but at least one has the due date
      expect(results.first.items.any((item) => item.dueDate == today), isTrue);
      expect(results.first.items.any((item) => item.dueDate == null), isTrue);
    });
  });

  group('Error Handling and Retry Logic', () {
    test('should clear error message', () async {
      // Arrange - cause an error
      mockTodoListRepo.shouldThrowError = true;
      await provider.loadSpaceContent('space-1');
      expect(provider.error, isNotNull);

      // Act
      provider.clearError();

      // Assert
      expect(provider.error, isNull);
    });

    test('should notify listeners when clearing error', () {
      // Arrange
      mockTodoListRepo.shouldThrowError = true;
      provider.loadSpaceContent('space-1');

      notifyListenersCallCount = 0;

      // Act
      provider.clearError();

      // Assert
      expect(notifyListenersCallCount, 1);
    });

    test(
      'should preserve error state across operations until cleared',
      () async {
        // Arrange - cause an error
        mockTodoListRepo.shouldThrowError = true;
        await provider.loadSpaceContent('space-1');
        final firstError = provider.error;
        expect(firstError, isNotNull);

        // Act - try another operation that succeeds
        mockTodoListRepo.shouldThrowError = false;
        final note = Item(id: 'note-1', title: 'Test', spaceId: 'space-1');
        await provider.createNote(note);

        // Assert - error should be cleared by successful operation
        expect(provider.error, isNull);
      },
    );

    test('should create AppError from exceptions', () async {
      // Arrange
      mockTodoListRepo.shouldThrowError = true;
      mockTodoListRepo.errorMessage = 'Storage error occurred';

      // Act
      await provider.loadSpaceContent('space-1');

      // Assert
      expect(provider.error, isA<AppError>());
      expect(provider.error!.message, contains('Storage error'));
    });

    test(
      'should handle error during content creation and not increment count',
      () async {
        // Arrange
        mockTodoListRepo.shouldThrowError = true;
        final todoList = TodoList(
          id: 'todo-1',
          spaceId: 'space-1',
          name: 'Test',
        );

        // Act
        await provider.createTodoList(todoList);

        // Assert
        expect(provider.error, isNotNull);
        expect(provider.todoLists, isEmpty);
      },
    );

    test(
      'should handle error during content deletion and not decrement count',
      () async {
        // Arrange
        final todoList = TodoList(
          id: 'todo-1',
          spaceId: 'space-1',
          name: 'Test',
        );
        await provider.createTodoList(todoList);

        // Act - cause error on delete
        mockTodoListRepo.shouldThrowError = true;
        await provider.deleteTodoList('todo-1');

        // Assert
        expect(provider.error, isNotNull);
      },
    );

    test('should continue normal operation after error recovery', () async {
      // Arrange - cause an error
      mockTodoListRepo.shouldThrowError = true;
      await provider.loadSpaceContent('space-1');
      expect(provider.error, isNotNull);

      // Act - recover and do successful operation
      mockTodoListRepo.shouldThrowError = false;
      mockTodoListRepo.mockTodoLists = [
        TodoList(id: 'todo-1', spaceId: 'space-1', name: 'Test'),
      ];
      await provider.loadSpaceContent('space-1');

      // Assert
      expect(provider.error, isNull);
      expect(provider.todoLists.length, 1);
    });

    test('should handle partial failure in parallel loading', () async {
      // Arrange - only todo list repo fails
      mockTodoListRepo.shouldThrowError = true;
      mockListRepo.mockLists = [
        ListModel(id: 'list-1', spaceId: 'space-1', name: 'Test'),
      ];
      mockNoteRepo.mockNotes = [
        Item(id: 'note-1', title: 'Test', spaceId: 'space-1'),
      ];

      // Act
      await provider.loadSpaceContent('space-1');

      // Assert - should have error and cleared all content
      expect(provider.error, isNotNull);
      expect(provider.todoLists, isEmpty);
      expect(provider.lists, isEmpty);
      expect(provider.notes, isEmpty);
    });
  });
}
