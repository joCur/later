import 'package:later_mobile/data/models/list_item_model.dart';
import 'package:later_mobile/data/models/list_model.dart';
import 'package:later_mobile/data/models/note_model.dart';
import 'package:later_mobile/data/models/space_model.dart';
import 'package:later_mobile/data/models/todo_item_model.dart';
import 'package:later_mobile/data/models/todo_list_model.dart';
import 'package:later_mobile/data/repositories/list_repository.dart';
import 'package:later_mobile/data/repositories/note_repository.dart';
import 'package:later_mobile/data/repositories/space_repository.dart';
import 'package:later_mobile/data/repositories/todo_list_repository.dart';

/// Fake ListRepository for testing
/// Matches the new Supabase repository API with separate items storage
class FakeListRepository implements ListRepository {
  List<ListModel> _lists = [];
  final Map<String, List<ListItem>> _itemsByListId = {};
  bool _shouldThrowError = false;

  /// Getter for accessing lists in tests
  List<ListModel> get lists => _lists;

  void setLists(List<ListModel> lists) {
    _lists = lists;
  }

  void setItemsForList(String listId, List<ListItem> items) {
    _itemsByListId[listId] = items;
    // Update counts on the list
    final listIndex = _lists.indexWhere((l) => l.id == listId);
    if (listIndex != -1) {
      final checkedCount = items.where((item) => item.isChecked).length;
      _lists[listIndex] = _lists[listIndex].copyWith(
        totalItemCount: items.length,
        checkedItemCount: checkedCount,
      );
    }
  }

  void setShouldThrowError(bool value) {
    _shouldThrowError = value;
  }

  void _updateListCounts(String listId) {
    final items = _itemsByListId[listId] ?? [];
    final listIndex = _lists.indexWhere((l) => l.id == listId);
    if (listIndex != -1) {
      final checkedCount = items.where((item) => item.isChecked).length;
      _lists[listIndex] = _lists[listIndex].copyWith(
        totalItemCount: items.length,
        checkedItemCount: checkedCount,
      );
    }
  }

  @override
  Future<ListModel> create(ListModel list) async {
    if (_shouldThrowError) throw Exception('Create failed');
    _lists.add(list);
    _itemsByListId[list.id] = [];
    return list;
  }

  @override
  Future<ListModel?> getById(String id) async {
    if (_shouldThrowError) throw Exception('GetById failed');
    try {
      return _lists.firstWhere((list) => list.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ListModel>> getBySpace(String spaceId) async {
    if (_shouldThrowError) throw Exception('GetBySpace failed');
    return _lists.where((list) => list.spaceId == spaceId).toList();
  }

  @override
  Future<ListModel> update(ListModel list) async {
    if (_shouldThrowError) throw Exception('Update failed');
    final index = _lists.indexWhere((l) => l.id == list.id);
    if (index == -1) throw Exception('List not found');
    _lists[index] = list.copyWith(updatedAt: DateTime.now());
    return _lists[index];
  }

  @override
  Future<void> delete(String id) async {
    if (_shouldThrowError) throw Exception('Delete failed');
    _lists.removeWhere((list) => list.id == id);
    _itemsByListId.remove(id);
  }

  @override
  Future<List<ListItem>> getListItemsByListId(String listId) async {
    if (_shouldThrowError) throw Exception('GetListItemsByListId failed');
    return _itemsByListId[listId] ?? [];
  }

  @override
  Future<ListItem> createListItem(ListItem listItem) async {
    if (_shouldThrowError) throw Exception('CreateListItem failed');
    final items = _itemsByListId[listItem.listId] ?? [];
    items.add(listItem);
    _itemsByListId[listItem.listId] = items;
    _updateListCounts(listItem.listId);
    return listItem;
  }

  @override
  Future<ListItem> updateListItem(ListItem listItem) async {
    if (_shouldThrowError) throw Exception('UpdateListItem failed');
    final items = _itemsByListId[listItem.listId] ?? [];
    final index = items.indexWhere((item) => item.id == listItem.id);
    if (index == -1) throw Exception('Item not found');
    items[index] = listItem;
    _itemsByListId[listItem.listId] = items;
    _updateListCounts(listItem.listId);
    return listItem;
  }

  @override
  Future<void> deleteListItem(String id, String listId) async {
    if (_shouldThrowError) throw Exception('DeleteListItem failed');
    final items = _itemsByListId[listId] ?? [];
    items.removeWhere((item) => item.id == id);
    _itemsByListId[listId] = items;
    _updateListCounts(listId);
  }

  @override
  Future<void> updateListItemSortOrders(List<ListItem> listItems) async {
    if (_shouldThrowError) throw Exception('UpdateListItemSortOrders failed');
    if (listItems.isEmpty) return;
    final listId = listItems.first.listId;
    _itemsByListId[listId] = listItems;
    _updateListCounts(listId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake TodoListRepository for testing
/// Matches the new Supabase repository API with separate items storage
class FakeTodoListRepository implements TodoListRepository {
  List<TodoList> _todoLists = [];
  final Map<String, List<TodoItem>> _itemsByTodoListId = {};
  bool _shouldThrowError = false;

  void setTodoLists(List<TodoList> todoLists) {
    _todoLists = todoLists;
  }

  void setItemsForTodoList(String todoListId, List<TodoItem> items) {
    _itemsByTodoListId[todoListId] = items;
    // Update counts on the todo list
    final todoListIndex = _todoLists.indexWhere((tl) => tl.id == todoListId);
    if (todoListIndex != -1) {
      final completedCount =
          items.where((item) => item.isCompleted).length;
      _todoLists[todoListIndex] = _todoLists[todoListIndex].copyWith(
        totalItemCount: items.length,
        completedItemCount: completedCount,
      );
    }
  }

  void setShouldThrowError(bool value) {
    _shouldThrowError = value;
  }

  void _updateTodoListCounts(String todoListId) {
    final items = _itemsByTodoListId[todoListId] ?? [];
    final todoListIndex = _todoLists.indexWhere((tl) => tl.id == todoListId);
    if (todoListIndex != -1) {
      final completedCount =
          items.where((item) => item.isCompleted).length;
      _todoLists[todoListIndex] = _todoLists[todoListIndex].copyWith(
        totalItemCount: items.length,
        completedItemCount: completedCount,
      );
    }
  }

  @override
  Future<TodoList> create(TodoList todoList) async {
    if (_shouldThrowError) throw Exception('Create failed');
    _todoLists.add(todoList);
    _itemsByTodoListId[todoList.id] = [];
    return todoList;
  }

  @override
  Future<TodoList?> getById(String id) async {
    if (_shouldThrowError) throw Exception('GetById failed');
    try {
      return _todoLists.firstWhere((todoList) => todoList.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<TodoList>> getBySpace(String spaceId) async {
    if (_shouldThrowError) throw Exception('GetBySpace failed');
    return _todoLists
        .where((todoList) => todoList.spaceId == spaceId)
        .toList();
  }

  @override
  Future<TodoList> update(TodoList todoList) async {
    if (_shouldThrowError) throw Exception('Update failed');
    final index = _todoLists.indexWhere((tl) => tl.id == todoList.id);
    if (index == -1) throw Exception('TodoList not found');
    _todoLists[index] = todoList.copyWith(updatedAt: DateTime.now());
    return _todoLists[index];
  }

  @override
  Future<void> delete(String id) async {
    if (_shouldThrowError) throw Exception('Delete failed');
    _todoLists.removeWhere((todoList) => todoList.id == id);
    _itemsByTodoListId.remove(id);
  }

  @override
  Future<List<TodoItem>> getTodoItemsByListId(String todoListId) async {
    if (_shouldThrowError) {
      throw Exception('GetTodoItemsByListId failed');
    }
    return _itemsByTodoListId[todoListId] ?? [];
  }

  @override
  Future<TodoItem> createTodoItem(TodoItem todoItem) async {
    if (_shouldThrowError) throw Exception('CreateTodoItem failed');
    final items = _itemsByTodoListId[todoItem.todoListId] ?? [];
    items.add(todoItem);
    _itemsByTodoListId[todoItem.todoListId] = items;
    _updateTodoListCounts(todoItem.todoListId);
    return todoItem;
  }

  @override
  Future<TodoItem> updateTodoItem(TodoItem todoItem) async {
    if (_shouldThrowError) throw Exception('UpdateTodoItem failed');
    final items = _itemsByTodoListId[todoItem.todoListId] ?? [];
    final index = items.indexWhere((item) => item.id == todoItem.id);
    if (index == -1) throw Exception('Item not found');
    items[index] = todoItem;
    _itemsByTodoListId[todoItem.todoListId] = items;
    _updateTodoListCounts(todoItem.todoListId);
    return todoItem;
  }

  @override
  Future<void> deleteTodoItem(String id, String todoListId) async {
    if (_shouldThrowError) throw Exception('DeleteTodoItem failed');
    final items = _itemsByTodoListId[todoListId] ?? [];
    items.removeWhere((item) => item.id == id);
    _itemsByTodoListId[todoListId] = items;
    _updateTodoListCounts(todoListId);
  }

  @override
  Future<void> updateTodoItemSortOrders(List<TodoItem> todoItems) async {
    if (_shouldThrowError) {
      throw Exception('UpdateTodoItemSortOrders failed');
    }
    if (todoItems.isEmpty) return;
    final todoListId = todoItems.first.todoListId;
    _itemsByTodoListId[todoListId] = todoItems;
    _updateTodoListCounts(todoListId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake NoteRepository for testing
class FakeNoteRepository implements NoteRepository {
  List<Note> _notes = [];
  bool _shouldThrowError = false;

  void setNotes(List<Note> notes) {
    _notes = notes;
  }

  void setShouldThrowError(bool value) {
    _shouldThrowError = value;
  }

  @override
  Future<Note> create(Note note) async {
    if (_shouldThrowError) throw Exception('Create failed');
    _notes.add(note);
    return note;
  }

  @override
  Future<Note?> getById(String id) async {
    if (_shouldThrowError) throw Exception('GetById failed');
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Note>> getBySpace(String spaceId) async {
    if (_shouldThrowError) throw Exception('GetBySpace failed');
    return _notes.where((note) => note.spaceId == spaceId).toList();
  }

  @override
  Future<Note> update(Note note) async {
    if (_shouldThrowError) throw Exception('Update failed');
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index == -1) throw Exception('Note not found');
    _notes[index] = note.copyWith(updatedAt: DateTime.now());
    return _notes[index];
  }

  @override
  Future<void> delete(String id) async {
    if (_shouldThrowError) throw Exception('Delete failed');
    _notes.removeWhere((note) => note.id == id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake SpaceRepository for testing
class FakeSpaceRepository implements SpaceRepository {
  List<Space> _spaces = [];
  bool _shouldThrowError = false;

  void setSpaces(List<Space> spaces) {
    _spaces = spaces;
  }

  void setShouldThrowError(bool value) {
    _shouldThrowError = value;
  }

  @override
  Future<List<Space>> getSpaces({bool includeArchived = false}) async {
    if (_shouldThrowError) throw Exception('GetSpaces failed');
    return _spaces;
  }

  @override
  Future<Space?> getSpaceById(String id) async {
    if (_shouldThrowError) throw Exception('GetSpaceById failed');
    try {
      return _spaces.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Space> createSpace(Space space) async {
    if (_shouldThrowError) throw Exception('CreateSpace failed');
    _spaces.add(space);
    return space;
  }

  @override
  Future<Space> updateSpace(Space space) async {
    if (_shouldThrowError) throw Exception('UpdateSpace failed');
    final index = _spaces.indexWhere((s) => s.id == space.id);
    if (index == -1) throw Exception('Space not found');
    _spaces[index] = space;
    return space;
  }

  @override
  Future<void> deleteSpace(String id) async {
    if (_shouldThrowError) throw Exception('DeleteSpace failed');
    _spaces.removeWhere((s) => s.id == id);
  }

  @override
  Future<int> getItemCount(String spaceId) async {
    if (_shouldThrowError) throw Exception('GetItemCount failed');
    // For testing, return a mock count
    return 0;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
