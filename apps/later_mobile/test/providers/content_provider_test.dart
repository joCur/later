import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/error/app_error.dart';
import 'package:later_mobile/data/models/list_item_model.dart';
import 'package:later_mobile/data/models/list_model.dart';
import 'package:later_mobile/data/models/list_style.dart';
import 'package:later_mobile/data/models/note_model.dart';
import 'package:later_mobile/data/models/todo_item_model.dart';
import 'package:later_mobile/data/models/todo_list_model.dart';
import 'package:later_mobile/data/repositories/list_repository.dart';
import 'package:later_mobile/data/repositories/note_repository.dart';
import 'package:later_mobile/data/repositories/todo_list_repository.dart';
import 'package:later_mobile/providers/content_provider.dart';

/// Mock implementation of TodoListRepository for testing
class MockTodoListRepository extends TodoListRepository {
  List<TodoList> mockTodoLists = [];
  Map<String, List<TodoItem>> mockTodoItems = {};
  bool shouldThrowError = false;
  String? errorMessage;

  int createCallCount = 0;
  int updateCallCount = 0;
  int deleteCallCount = 0;
  int getBySpaceCallCount = 0;
  int getByIdCallCount = 0;

  void reset() {
    mockTodoLists.clear();
    mockTodoItems.clear();
    shouldThrowError = false;
    errorMessage = null;
    createCallCount = 0;
    updateCallCount = 0;
    deleteCallCount = 0;
    getBySpaceCallCount = 0;
    getByIdCallCount = 0;
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
  Future<TodoList?> getById(String id) async {
    getByIdCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to get todo list by id');
    }
    try {
      return mockTodoLists.firstWhere((list) => list.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<TodoList> create(TodoList todoList) async {
    createCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to create todo list');
    }
    final created = todoList.copyWith(
      sortOrder: mockTodoLists.length,
      totalItemCount: 0,
      completedItemCount: 0,
    );
    mockTodoLists.add(created);
    mockTodoItems[created.id] = [];
    return created;
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
    mockTodoItems.remove(id);
  }

  @override
  Future<List<TodoItem>> getTodoItemsByListId(String todoListId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to get todo items');
    }
    return mockTodoItems[todoListId] ?? [];
  }

  @override
  Future<TodoItem> createTodoItem(TodoItem todoItem) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to create todo item');
    }
    final items = mockTodoItems[todoItem.todoListId] ?? [];
    final created = todoItem.copyWith(sortOrder: items.length);
    items.add(created);
    mockTodoItems[todoItem.todoListId] = items;

    // Update parent list counts
    final listIndex =
        mockTodoLists.indexWhere((t) => t.id == todoItem.todoListId);
    if (listIndex != -1) {
      final list = mockTodoLists[listIndex];
      mockTodoLists[listIndex] = list.copyWith(
        totalItemCount: items.length,
        completedItemCount: items.where((i) => i.isCompleted).length,
      );
    }

    return created;
  }

  @override
  Future<TodoItem> updateTodoItem(TodoItem todoItem) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to update todo item');
    }
    final items = mockTodoItems[todoItem.todoListId] ?? [];
    final index = items.indexWhere((i) => i.id == todoItem.id);
    if (index == -1) {
      throw Exception('TodoItem with id ${todoItem.id} does not exist');
    }
    items[index] = todoItem;

    // Update parent list counts
    final listIndex =
        mockTodoLists.indexWhere((t) => t.id == todoItem.todoListId);
    if (listIndex != -1) {
      final list = mockTodoLists[listIndex];
      mockTodoLists[listIndex] = list.copyWith(
        totalItemCount: items.length,
        completedItemCount: items.where((i) => i.isCompleted).length,
      );
    }

    return todoItem;
  }

  @override
  Future<void> deleteTodoItem(String id, String todoListId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to delete todo item');
    }
    final items = mockTodoItems[todoListId] ?? [];
    items.removeWhere((i) => i.id == id);

    // Update parent list counts
    final listIndex = mockTodoLists.indexWhere((t) => t.id == todoListId);
    if (listIndex != -1) {
      final list = mockTodoLists[listIndex];
      mockTodoLists[listIndex] = list.copyWith(
        totalItemCount: items.length,
        completedItemCount: items.where((i) => i.isCompleted).length,
      );
    }
  }

  @override
  Future<void> updateTodoItemSortOrders(List<TodoItem> todoItems) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to update sort orders');
    }
    if (todoItems.isEmpty) return;

    final todoListId = todoItems.first.todoListId;
    mockTodoItems[todoListId] = todoItems;
  }
}

/// Mock implementation of ListRepository for testing
class MockListRepository extends ListRepository {
  List<ListModel> mockLists = [];
  Map<String, List<ListItem>> mockListItems = {};
  bool shouldThrowError = false;
  String? errorMessage;

  int createCallCount = 0;
  int updateCallCount = 0;
  int deleteCallCount = 0;
  int getBySpaceCallCount = 0;
  int getByIdCallCount = 0;

  void reset() {
    mockLists.clear();
    mockListItems.clear();
    shouldThrowError = false;
    errorMessage = null;
    createCallCount = 0;
    updateCallCount = 0;
    deleteCallCount = 0;
    getBySpaceCallCount = 0;
    getByIdCallCount = 0;
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
  Future<ListModel?> getById(String id) async {
    getByIdCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to get list by id');
    }
    try {
      return mockLists.firstWhere((list) => list.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ListModel> create(ListModel list) async {
    createCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to create list');
    }
    final created = list.copyWith(
      sortOrder: mockLists.length,
      totalItemCount: 0,
      checkedItemCount: 0,
    );
    mockLists.add(created);
    mockListItems[created.id] = [];
    return created;
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
    mockListItems.remove(id);
  }

  @override
  Future<List<ListItem>> getListItemsByListId(String listId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to get list items');
    }
    return mockListItems[listId] ?? [];
  }

  @override
  Future<ListItem> createListItem(ListItem listItem) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to create list item');
    }
    final items = mockListItems[listItem.listId] ?? [];
    final created = listItem.copyWith(sortOrder: items.length);
    items.add(created);
    mockListItems[listItem.listId] = items;

    // Update parent list counts
    final listIndex = mockLists.indexWhere((l) => l.id == listItem.listId);
    if (listIndex != -1) {
      final list = mockLists[listIndex];
      mockLists[listIndex] = list.copyWith(
        totalItemCount: items.length,
        checkedItemCount: items.where((i) => i.isChecked).length,
      );
    }

    return created;
  }

  @override
  Future<ListItem> updateListItem(ListItem listItem) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to update list item');
    }
    final items = mockListItems[listItem.listId] ?? [];
    final index = items.indexWhere((i) => i.id == listItem.id);
    if (index == -1) {
      throw Exception('ListItem with id ${listItem.id} does not exist');
    }
    items[index] = listItem;

    // Update parent list counts
    final listIndex = mockLists.indexWhere((l) => l.id == listItem.listId);
    if (listIndex != -1) {
      final list = mockLists[listIndex];
      mockLists[listIndex] = list.copyWith(
        totalItemCount: items.length,
        checkedItemCount: items.where((i) => i.isChecked).length,
      );
    }

    return listItem;
  }

  @override
  Future<void> deleteListItem(String id, String listId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to delete list item');
    }
    final items = mockListItems[listId] ?? [];
    items.removeWhere((i) => i.id == id);

    // Update parent list counts
    final listIndex = mockLists.indexWhere((l) => l.id == listId);
    if (listIndex != -1) {
      final list = mockLists[listIndex];
      mockLists[listIndex] = list.copyWith(
        totalItemCount: items.length,
        checkedItemCount: items.where((i) => i.isChecked).length,
      );
    }
  }

  @override
  Future<void> updateListItemSortOrders(List<ListItem> listItems) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to update sort orders');
    }
    if (listItems.isEmpty) return;

    final listId = listItems.first.listId;
    mockListItems[listId] = listItems;
  }
}

/// Mock implementation of NoteRepository for testing
class MockNoteRepository extends NoteRepository {
  List<Note> mockNotes = [];
  bool shouldThrowError = false;
  String? errorMessage;

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
  Future<List<Note>> getBySpace(String spaceId) async {
    getBySpaceCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to get notes by space');
    }
    return mockNotes.where((note) => note.spaceId == spaceId).toList();
  }

  @override
  Future<Note> create(Note note) async {
    createCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to create note');
    }
    mockNotes.add(note);
    return note;
  }

  @override
  Future<Note> update(Note note) async {
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

void main() {
  late ContentProvider provider;
  late MockTodoListRepository mockTodoListRepo;
  late MockListRepository mockListRepo;
  late MockNoteRepository mockNoteRepo;
  late int notifyListenersCallCount;

  const testUserId = 'test-user-id';

  setUp(() {
    mockTodoListRepo = MockTodoListRepository();
    mockListRepo = MockListRepository();
    mockNoteRepo = MockNoteRepository();

    provider = ContentProvider(
      todoListRepository: mockTodoListRepo,
      listRepository: mockListRepo,
      noteRepository: mockNoteRepo,
    );

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
      expect(
        () => provider.todoLists.add(
          TodoList(
            id: 'test',
            spaceId: 'test',
            name: 'test',
            userId: testUserId,
          ),
        ),
        throwsUnsupportedError,
      );
      expect(
        () => provider.lists.add(
          ListModel(
            id: 'test',
            spaceId: 'test',
            name: 'test',
            userId: testUserId,
          ),
        ),
        throwsUnsupportedError,
      );
      expect(
        () => provider.notes.add(
          Note(
            id: 'test',
            title: 'test',
            spaceId: 'test',
            userId: testUserId,
          ),
        ),
        throwsUnsupportedError,
      );
    });

    test('should set currentSpaceId during loadSpaceContent', () async {
      await provider.loadSpaceContent('space-123');
      expect(provider.currentSpaceId, 'space-123');
    });

    test('should notify listeners after state changes', () async {
      notifyListenersCallCount = 0;
      await provider.loadSpaceContent('space-1');
      expect(notifyListenersCallCount, greaterThanOrEqualTo(2));
    });
  });

  group('loadSpaceContent', () {
    test('should load all three content types in parallel', () async {
      mockTodoListRepo.mockTodoLists = [
        TodoList(
          id: 'todo-1',
          spaceId: 'space-1',
          name: 'Todo List 1',
          userId: testUserId,
        ),
      ];
      mockListRepo.mockLists = [
        ListModel(
          id: 'list-1',
          spaceId: 'space-1',
          name: 'List 1',
          userId: testUserId,
        ),
      ];
      mockNoteRepo.mockNotes = [
        Note(
          id: 'note-1',
          title: 'Note 1',
          spaceId: 'space-1',
          userId: testUserId,
        ),
      ];

      await provider.loadSpaceContent('space-1');

      expect(mockTodoListRepo.getBySpaceCallCount, 1);
      expect(mockListRepo.getBySpaceCallCount, 1);
      expect(mockNoteRepo.getBySpaceCallCount, 1);

      expect(provider.todoLists.length, 1);
      expect(provider.lists.length, 1);
      expect(provider.notes.length, 1);
    });

    test('should handle errors and set error state', () async {
      mockTodoListRepo.shouldThrowError = true;
      mockTodoListRepo.errorMessage = 'Test error';

      await provider.loadSpaceContent('space-1');

      expect(provider.error, isNotNull);
      expect(provider.error, isA<AppError>());
    });
  });

  group('TodoList CRUD Operations', () {
    test('should create todo list', () async {
      final todoList = TodoList(
        id: 'todo-1',
        spaceId: 'space-1',
        name: 'Weekly Tasks',
        userId: testUserId,
      );

      await provider.createTodoList(todoList);

      expect(provider.todoLists.length, 1);
      expect(provider.todoLists.first.id, 'todo-1');
      expect(mockTodoListRepo.createCallCount, 1);
    });

    test('should update todo list', () async {
      final original = TodoList(
        id: 'todo-1',
        spaceId: 'space-1',
        name: 'Original',
        userId: testUserId,
      );
      await provider.createTodoList(original);

      final updated = original.copyWith(name: 'Updated');
      await provider.updateTodoList(updated);

      expect(provider.todoLists.length, 1);
      expect(provider.todoLists.first.name, 'Updated');
      expect(mockTodoListRepo.updateCallCount, 1);
    });

    test('should delete todo list', () async {
      final todoList = TodoList(
        id: 'todo-1',
        spaceId: 'space-1',
        name: 'Test',
        userId: testUserId,
      );
      await provider.createTodoList(todoList);

      await provider.deleteTodoList('todo-1');

      expect(provider.todoLists, isEmpty);
      expect(mockTodoListRepo.deleteCallCount, 1);
    });
  });

  group('TodoItem Operations', () {
    late TodoList testTodoList;

    setUp(() async {
      testTodoList = TodoList(
        id: 'todo-1',
        spaceId: 'space-1',
        name: 'Test List',
        userId: testUserId,
      );
      await provider.createTodoList(testTodoList);
    });

    test('should load todo items and cache them', () async {
      mockTodoListRepo.mockTodoItems['todo-1'] = [
        TodoItem(
          id: 'item-1',
          title: 'Task 1',
          todoListId: 'todo-1',
          sortOrder: 0,
        ),
        TodoItem(
          id: 'item-2',
          title: 'Task 2',
          todoListId: 'todo-1',
          sortOrder: 1,
        ),
      ];

      final items = await provider.loadTodoItemsForList('todo-1');

      expect(items.length, 2);
      expect(items[0].id, 'item-1');
      expect(items[1].id, 'item-2');
    });

    test('should return cached items on subsequent loads', () async {
      mockTodoListRepo.mockTodoItems['todo-1'] = [
        TodoItem(
          id: 'item-1',
          title: 'Task 1',
          todoListId: 'todo-1',
          sortOrder: 0,
        ),
      ];

      await provider.loadTodoItemsForList('todo-1');
      final cachedItems = await provider.loadTodoItemsForList('todo-1');

      expect(cachedItems.length, 1);
    });

    test('should create todo item and update parent list counts', () async {
      final item = TodoItem(
        id: 'item-1',
        title: 'Task 1',
        todoListId: 'todo-1',
        sortOrder: 0,
      );

      await provider.createTodoItem(item);

      expect(provider.todoLists.first.totalItemCount, 1);
      expect(provider.todoLists.first.completedItemCount, 0);
    });

    test('should update todo item', () async {
      final item = TodoItem(
        id: 'item-1',
        title: 'Original',
        todoListId: 'todo-1',
        sortOrder: 0,
      );
      await provider.createTodoItem(item);

      await provider.loadTodoItemsForList('todo-1');
      final updated = item.copyWith(title: 'Updated');
      await provider.updateTodoItem(updated);

      final items = await provider.loadTodoItemsForList('todo-1');
      expect(items.first.title, 'Updated');
    });

    test('should update completion counts when toggling item', () async {
      final item = TodoItem(
        id: 'item-1',
        title: 'Task 1',
        todoListId: 'todo-1',
        sortOrder: 0,
        isCompleted: false,
      );
      await provider.createTodoItem(item);

      final toggled = item.copyWith(isCompleted: true);
      await provider.updateTodoItem(toggled);

      expect(provider.todoLists.first.totalItemCount, 1);
      expect(provider.todoLists.first.completedItemCount, 1);
    });

    test('should delete todo item and update parent list counts', () async {
      final item = TodoItem(
        id: 'item-1',
        title: 'Task 1',
        todoListId: 'todo-1',
        sortOrder: 0,
      );
      await provider.createTodoItem(item);

      await provider.deleteTodoItem('item-1', 'todo-1');

      expect(provider.todoLists.first.totalItemCount, 0);
    });

    test('should reorder todo items', () async {
      final item1 = TodoItem(
        id: 'item-1',
        title: 'Task 1',
        todoListId: 'todo-1',
        sortOrder: 0,
      );
      final item2 = TodoItem(
        id: 'item-2',
        title: 'Task 2',
        todoListId: 'todo-1',
        sortOrder: 1,
      );
      await provider.createTodoItem(item1);
      await provider.createTodoItem(item2);

      await provider.loadTodoItemsForList('todo-1');
      final reordered = [
        item2.copyWith(sortOrder: 0),
        item1.copyWith(sortOrder: 1),
      ];
      await provider.reorderTodoItems('todo-1', reordered);

      final items = await provider.loadTodoItemsForList('todo-1');
      expect(items[0].id, 'item-2');
      expect(items[1].id, 'item-1');
    });

    test('should invalidate cache after item operations', () async {
      final item = TodoItem(
        id: 'item-1',
        title: 'Task 1',
        todoListId: 'todo-1',
        sortOrder: 0,
      );

      await provider.createTodoItem(item);
      await provider.loadTodoItemsForList('todo-1');

      // Add another item
      final item2 = TodoItem(
        id: 'item-2',
        title: 'Task 2',
        todoListId: 'todo-1',
        sortOrder: 1,
      );
      await provider.createTodoItem(item2);

      // Cache should be invalidated, so reload should get both items
      final items = await provider.loadTodoItemsForList('todo-1');
      expect(items.length, 2);
    });
  });

  group('ListItem Operations', () {
    late ListModel testList;

    setUp(() async {
      testList = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        name: 'Test List',
        userId: testUserId,
        style: ListStyle.checkboxes,
      );
      await provider.createList(testList);
    });

    test('should load list items and cache them', () async {
      mockListRepo.mockListItems['list-1'] = [
        ListItem(
          id: 'item-1',
          title: 'Item 1',
          listId: 'list-1',
          sortOrder: 0,
        ),
        ListItem(
          id: 'item-2',
          title: 'Item 2',
          listId: 'list-1',
          sortOrder: 1,
        ),
      ];

      final items = await provider.loadListItemsForList('list-1');

      expect(items.length, 2);
      expect(items[0].id, 'item-1');
      expect(items[1].id, 'item-2');
    });

    test('should create list item and update parent list counts', () async {
      final item = ListItem(
        id: 'item-1',
        title: 'Item 1',
        listId: 'list-1',
        sortOrder: 0,
      );

      await provider.createListItem(item);

      expect(provider.lists.first.totalItemCount, 1);
      expect(provider.lists.first.checkedItemCount, 0);
    });

    test('should update list item', () async {
      final item = ListItem(
        id: 'item-1',
        title: 'Original',
        listId: 'list-1',
        sortOrder: 0,
      );
      await provider.createListItem(item);

      await provider.loadListItemsForList('list-1');
      final updated = item.copyWith(title: 'Updated');
      await provider.updateListItem(updated);

      final items = await provider.loadListItemsForList('list-1');
      expect(items.first.title, 'Updated');
    });

    test('should update checked counts when toggling item', () async {
      final item = ListItem(
        id: 'item-1',
        title: 'Item 1',
        listId: 'list-1',
        sortOrder: 0,
        isChecked: false,
      );
      await provider.createListItem(item);

      final toggled = item.copyWith(isChecked: true);
      await provider.updateListItem(toggled);

      expect(provider.lists.first.totalItemCount, 1);
      expect(provider.lists.first.checkedItemCount, 1);
    });

    test('should delete list item and update parent list counts', () async {
      final item = ListItem(
        id: 'item-1',
        title: 'Item 1',
        listId: 'list-1',
        sortOrder: 0,
      );
      await provider.createListItem(item);

      await provider.deleteListItem('item-1', 'list-1');

      expect(provider.lists.first.totalItemCount, 0);
    });

    test('should reorder list items', () async {
      final item1 = ListItem(
        id: 'item-1',
        title: 'Item 1',
        listId: 'list-1',
        sortOrder: 0,
      );
      final item2 = ListItem(
        id: 'item-2',
        title: 'Item 2',
        listId: 'list-1',
        sortOrder: 1,
      );
      await provider.createListItem(item1);
      await provider.createListItem(item2);

      await provider.loadListItemsForList('list-1');
      final reordered = [
        item2.copyWith(sortOrder: 0),
        item1.copyWith(sortOrder: 1),
      ];
      await provider.reorderListItems('list-1', reordered);

      final items = await provider.loadListItemsForList('list-1');
      expect(items[0].id, 'item-2');
      expect(items[1].id, 'item-1');
    });
  });

  group('Note CRUD Operations', () {
    test('should create note', () async {
      final note = Note(
        id: 'note-1',
        title: 'Meeting Notes',
        content: 'Discussion points',
        spaceId: 'space-1',
        userId: testUserId,
      );

      await provider.createNote(note);

      expect(provider.notes.length, 1);
      expect(provider.notes.first.id, 'note-1');
      expect(mockNoteRepo.createCallCount, 1);
    });

    test('should update note', () async {
      final original = Note(
        id: 'note-1',
        title: 'Original',
        spaceId: 'space-1',
        userId: testUserId,
      );
      await provider.createNote(original);

      final updated = original.copyWith(title: 'Updated');
      await provider.updateNote(updated);

      expect(provider.notes.length, 1);
      expect(provider.notes.first.title, 'Updated');
      expect(mockNoteRepo.updateCallCount, 1);
    });

    test('should delete note', () async {
      final note = Note(
        id: 'note-1',
        title: 'Test',
        spaceId: 'space-1',
        userId: testUserId,
      );
      await provider.createNote(note);

      await provider.deleteNote('note-1');

      expect(provider.notes, isEmpty);
      expect(mockNoteRepo.deleteCallCount, 1);
    });
  });

  group('Filtering and Search', () {
    setUp(() async {
      mockTodoListRepo.mockTodoLists = [
        TodoList(
          id: 'todo-1',
          spaceId: 'space-1',
          name: 'Work Tasks',
          userId: testUserId,
        ),
        TodoList(
          id: 'todo-2',
          spaceId: 'space-1',
          name: 'Personal Tasks',
          userId: testUserId,
        ),
      ];
      mockListRepo.mockLists = [
        ListModel(
          id: 'list-1',
          spaceId: 'space-1',
          name: 'Shopping List',
          userId: testUserId,
        ),
        ListModel(
          id: 'list-2',
          spaceId: 'space-1',
          name: 'Packing List',
          userId: testUserId,
        ),
      ];
      mockNoteRepo.mockNotes = [
        Note(
          id: 'note-1',
          title: 'Meeting Notes',
          content: 'Important points',
          spaceId: 'space-1',
          userId: testUserId,
        ),
        Note(
          id: 'note-2',
          title: 'Ideas',
          content: 'Creative thoughts',
          spaceId: 'space-1',
          userId: testUserId,
        ),
      ];
      await provider.loadSpaceContent('space-1');
    });

    test('should return all content with ContentFilter.all', () {
      final content = provider.getFilteredContent(ContentFilter.all);
      expect(content.length, 6);
    });

    test('should return only TodoLists with ContentFilter.todoLists', () {
      final content = provider.getFilteredContent(ContentFilter.todoLists);
      expect(content.length, 2);
      expect(content.every((item) => item is TodoList), isTrue);
    });

    test('should return only Lists with ContentFilter.lists', () {
      final content = provider.getFilteredContent(ContentFilter.lists);
      expect(content.length, 2);
      expect(content.every((item) => item is ListModel), isTrue);
    });

    test('should return only Notes with ContentFilter.notes', () {
      final content = provider.getFilteredContent(ContentFilter.notes);
      expect(content.length, 2);
      expect(content.every((item) => item is Note), isTrue);
    });

    test('should return correct total count', () {
      final total = provider.getTotalCount();
      expect(total, 6);
    });

    test('should search TodoLists by name', () {
      final results = provider.search('work');
      expect(results.length, 1);
      expect((results.first as TodoList).name, contains('Work'));
    });

    test('should search Lists by name', () {
      final results = provider.search('shopping');
      expect(results.length, 1);
      expect((results.first as ListModel).name, contains('Shopping'));
    });

    test('should search Notes by title and content', () {
      final titleResults = provider.search('meeting');
      expect(titleResults.length, 1);

      final contentResults = provider.search('creative');
      expect(contentResults.length, 1);
    });

    test('should perform case-insensitive search', () {
      final results1 = provider.search('WORK');
      final results2 = provider.search('work');
      final results3 = provider.search('Work');

      expect(results1.length, results2.length);
      expect(results2.length, results3.length);
    });

    test('should return all content when search query is empty', () {
      final results = provider.search('');
      expect(results.length, 6);
    });
  });

  group('Due Date Filtering', () {
    test('should find TodoLists with items due on specific date', () async {
      final today = DateTime(2025, 1, 15);
      final tomorrow = DateTime(2025, 1, 16);

      final todoList1 = TodoList(
        id: 'todo-1',
        spaceId: 'space-1',
        name: 'Today Tasks',
        userId: testUserId,
      );
      final todoList2 = TodoList(
        id: 'todo-2',
        spaceId: 'space-1',
        name: 'Tomorrow Tasks',
        userId: testUserId,
      );

      await provider.createTodoList(todoList1);
      await provider.createTodoList(todoList2);

      mockTodoListRepo.mockTodoItems['todo-1'] = [
        TodoItem(
          id: 'item-1',
          title: 'Task 1',
          todoListId: 'todo-1',
          sortOrder: 0,
          dueDate: today,
        ),
      ];
      mockTodoListRepo.mockTodoItems['todo-2'] = [
        TodoItem(
          id: 'item-2',
          title: 'Task 2',
          todoListId: 'todo-2',
          sortOrder: 0,
          dueDate: tomorrow,
        ),
      ];

      final results = await provider.getTodosWithDueDate(today);

      expect(results.length, 1);
      expect(results.first.id, 'todo-1');
    });

    test('should filter by day only, ignoring time', () async {
      final morning = DateTime(2025, 1, 15, 8);
      final evening = DateTime(2025, 1, 15, 20);

      final todoList1 = TodoList(
        id: 'todo-1',
        spaceId: 'space-1',
        name: 'Morning',
        userId: testUserId,
      );
      final todoList2 = TodoList(
        id: 'todo-2',
        spaceId: 'space-1',
        name: 'Evening',
        userId: testUserId,
      );

      await provider.createTodoList(todoList1);
      await provider.createTodoList(todoList2);

      mockTodoListRepo.mockTodoItems['todo-1'] = [
        TodoItem(
          id: 'item-1',
          title: 'Morning Task',
          todoListId: 'todo-1',
          sortOrder: 0,
          dueDate: morning,
        ),
      ];
      mockTodoListRepo.mockTodoItems['todo-2'] = [
        TodoItem(
          id: 'item-2',
          title: 'Evening Task',
          todoListId: 'todo-2',
          sortOrder: 0,
          dueDate: evening,
        ),
      ];

      final noon = DateTime(2025, 1, 15, 12);
      final results = await provider.getTodosWithDueDate(noon);

      expect(results.length, 2);
    });

    test('should return empty list when no matches', () async {
      final yesterday = DateTime(2025, 1, 14);

      final todoList = TodoList(
        id: 'todo-1',
        spaceId: 'space-1',
        name: 'Test',
        userId: testUserId,
      );
      await provider.createTodoList(todoList);

      mockTodoListRepo.mockTodoItems['todo-1'] = [
        TodoItem(
          id: 'item-1',
          title: 'Task',
          todoListId: 'todo-1',
          sortOrder: 0,
          dueDate: DateTime(2025, 1, 15),
        ),
      ];

      final results = await provider.getTodosWithDueDate(yesterday);
      expect(results, isEmpty);
    });

    test('should handle null dueDates', () async {
      final today = DateTime(2025, 1, 15);

      final todoList = TodoList(
        id: 'todo-1',
        spaceId: 'space-1',
        name: 'Mixed',
        userId: testUserId,
      );
      await provider.createTodoList(todoList);

      mockTodoListRepo.mockTodoItems['todo-1'] = [
        TodoItem(
          id: 'item-1',
          title: 'No due date',
          todoListId: 'todo-1',
          sortOrder: 0,
        ),
        TodoItem(
          id: 'item-2',
          title: 'Has due date',
          todoListId: 'todo-1',
          sortOrder: 1,
          dueDate: today,
        ),
      ];

      final results = await provider.getTodosWithDueDate(today);

      expect(results.length, 1);
      expect(results.first.id, 'todo-1');
    });
  });

  group('Error Handling', () {
    test('should clear error message', () async {
      mockTodoListRepo.shouldThrowError = true;
      await provider.loadSpaceContent('space-1');
      expect(provider.error, isNotNull);

      provider.clearError();

      expect(provider.error, isNull);
    });

    test('should notify listeners when clearing error', () {
      mockTodoListRepo.shouldThrowError = true;
      provider.loadSpaceContent('space-1');

      notifyListenersCallCount = 0;
      provider.clearError();

      expect(notifyListenersCallCount, 1);
    });

    test('should handle error in TodoItem operations', () async {
      final todoList = TodoList(
        id: 'todo-1',
        spaceId: 'space-1',
        name: 'Test',
        userId: testUserId,
      );
      await provider.createTodoList(todoList);

      mockTodoListRepo.shouldThrowError = true;
      final item = TodoItem(
        id: 'item-1',
        title: 'Task 1',
        todoListId: 'todo-1',
        sortOrder: 0,
      );

      try {
        await provider.createTodoItem(item);
        fail('Expected exception to be thrown');
      } catch (e) {
        expect(e, isException);
        expect(provider.error, isNotNull);
      }
    });

    test('should handle error in ListItem operations', () async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        name: 'Test',
        userId: testUserId,
      );
      await provider.createList(list);

      mockListRepo.shouldThrowError = true;
      final item = ListItem(
        id: 'item-1',
        title: 'Item 1',
        listId: 'list-1',
        sortOrder: 0,
      );

      try {
        await provider.createListItem(item);
        fail('Expected exception to be thrown');
      } catch (e) {
        expect(e, isException);
        expect(provider.error, isNotNull);
      }
    });
  });
}
