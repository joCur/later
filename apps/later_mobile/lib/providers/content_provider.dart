import 'package:flutter/foundation.dart';
import '../core/error/app_error.dart';
import '../data/models/item_model.dart';
import '../data/models/list_model.dart';
import '../data/models/todo_list_model.dart';
import '../data/repositories/list_repository.dart';
import '../data/repositories/note_repository.dart';
import '../data/repositories/todo_list_repository.dart';
import 'spaces_provider.dart';

/// Enum to filter content by type
enum ContentFilter {
  all,
  todoLists,
  lists,
  notes,
}

/// Provider for managing unified content state (TodoLists, Lists, Notes) in the application.
///
/// This provider handles all content-related operations across three content types:
/// - TodoLists: Container for actionable tasks with progress tracking
/// - Lists: Container for reference collections (shopping lists, etc.)
/// - Notes: Standalone documentation items
///
/// It manages loading states, error states, and notifies listeners of state changes.
/// All content operations automatically update space item counts via SpacesProvider.
///
/// Example usage:
/// ```dart
/// final provider = Provider.of<ContentProvider>(context);
/// await provider.loadSpaceContent('space-1');
/// final filtered = provider.getFilteredContent(ContentFilter.todoLists);
/// ```
class ContentProvider extends ChangeNotifier {
  /// Creates a ContentProvider with the given repositories.
  ///
  /// All repository parameters are required and will be used for
  /// data persistence operations.
  ContentProvider({
    required TodoListRepository todoListRepository,
    required ListRepository listRepository,
    required NoteRepository noteRepository,
  })  : _todoListRepository = todoListRepository,
        _listRepository = listRepository,
        _noteRepository = noteRepository;

  final TodoListRepository _todoListRepository;
  final ListRepository _listRepository;
  final NoteRepository _noteRepository;

  /// List of todo lists currently loaded in the provider.
  List<TodoList> _todoLists = [];

  /// Returns an unmodifiable view of the current todo lists.
  List<TodoList> get todoLists => List.unmodifiable(_todoLists);

  /// List of lists currently loaded in the provider.
  List<ListModel> _lists = [];

  /// Returns an unmodifiable view of the current lists.
  List<ListModel> get lists => List.unmodifiable(_lists);

  /// List of notes currently loaded in the provider.
  List<Item> _notes = [];

  /// Returns an unmodifiable view of the current notes.
  List<Item> get notes => List.unmodifiable(_notes);

  /// The ID of the currently loaded space.
  String? _currentSpaceId;

  /// Returns the ID of the currently loaded space.
  String? get currentSpaceId => _currentSpaceId;

  /// Indicates whether an async operation is currently in progress.
  bool _isLoading = false;

  /// Returns true if an async operation is in progress.
  bool get isLoading => _isLoading;

  /// Current error, if any.
  AppError? _error;

  /// Returns the current error, or null if there is no error.
  AppError? get error => _error;

  /// Maximum number of retry attempts for failed operations.
  static const int _maxRetries = 3;

  /// Base delay for exponential backoff (in milliseconds).
  static const int _baseDelayMs = 300;

  /// Loads all content (TodoLists, Lists, Notes) for a specific space.
  ///
  /// Uses parallel loading with Future.wait for optimal performance.
  /// Sets loading state and handles errors appropriately.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to load content for
  ///
  /// Example:
  /// ```dart
  /// await provider.loadSpaceContent('space-1');
  /// print('Loaded ${provider.todoLists.length} todo lists');
  /// ```
  Future<void> loadSpaceContent(String spaceId) async {
    _isLoading = true;
    _error = null;
    _currentSpaceId = spaceId;
    notifyListeners();

    try {
      // Load all three content types in parallel
      final results = await Future.wait([
        _executeWithRetry(
          () => _todoListRepository.getBySpace(spaceId),
          'loadTodoLists',
        ),
        _executeWithRetry(
          () => _listRepository.getBySpace(spaceId),
          'loadLists',
        ),
        _executeWithRetry(
          () => _noteRepository.getBySpace(spaceId),
          'loadNotes',
        ),
      ]);

      _todoLists = results[0] as List<TodoList>;
      _lists = results[1] as List<ListModel>;
      _notes = results[2] as List<Item>;

      _error = null;
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      _todoLists = [];
      _lists = [];
      _notes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new todo list and increments the space item count.
  ///
  /// Parameters:
  ///   - [todoList]: The todo list to create
  ///   - [spacesProvider]: The spaces provider to update item count
  ///
  /// Example:
  /// ```dart
  /// final todoList = TodoList(
  ///   id: 'todo-1',
  ///   spaceId: 'space-1',
  ///   name: 'Weekly Tasks',
  ///   items: [],
  /// );
  /// await provider.createTodoList(todoList, spacesProvider);
  /// ```
  Future<void> createTodoList(TodoList todoList, SpacesProvider spacesProvider) async {
    _error = null;

    try {
      final created = await _executeWithRetry(
        () => _todoListRepository.create(todoList),
        'createTodoList',
      );
      _todoLists = [..._todoLists, created];

      // Increment space item count
      await spacesProvider.incrementSpaceItemCount(todoList.spaceId);

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Updates an existing todo list.
  ///
  /// Parameters:
  ///   - [todoList]: The todo list with updated values
  ///
  /// Example:
  /// ```dart
  /// final updated = todoList.copyWith(name: 'Updated Name');
  /// await provider.updateTodoList(updated);
  /// ```
  Future<void> updateTodoList(TodoList todoList) async {
    _error = null;

    try {
      final updated = await _executeWithRetry(
        () => _todoListRepository.update(todoList),
        'updateTodoList',
      );
      final index = _todoLists.indexWhere((t) => t.id == todoList.id);
      if (index != -1) {
        _todoLists = [
          ..._todoLists.sublist(0, index),
          updated,
          ..._todoLists.sublist(index + 1),
        ];
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Deletes a todo list and decrements the space item count.
  ///
  /// Parameters:
  ///   - [id]: The ID of the todo list to delete
  ///   - [spacesProvider]: The spaces provider to update item count
  ///
  /// Example:
  /// ```dart
  /// await provider.deleteTodoList('todo-1', spacesProvider);
  /// ```
  Future<void> deleteTodoList(String id, SpacesProvider spacesProvider) async {
    _error = null;

    try {
      // Get the todo list to find its spaceId before deleting
      final todoList = _todoLists.firstWhere((t) => t.id == id);

      await _executeWithRetry(
        () => _todoListRepository.delete(id),
        'deleteTodoList',
      );
      _todoLists = _todoLists.where((t) => t.id != id).toList();

      // Decrement space item count
      await spacesProvider.decrementSpaceItemCount(todoList.spaceId);

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Adds a new todo item to an existing todo list.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the todo list to add the item to
  ///   - [item]: The todo item to add
  ///
  /// Example:
  /// ```dart
  /// final item = TodoItem(
  ///   id: 'item-1',
  ///   title: 'New task',
  ///   sortOrder: 0,
  /// );
  /// await provider.addTodoItem('todo-1', item);
  /// ```
  Future<void> addTodoItem(String listId, TodoItem item) async {
    _error = null;

    try {
      final updated = await _executeWithRetry(
        () => _todoListRepository.addItem(listId, item),
        'addTodoItem',
      );
      final index = _todoLists.indexWhere((t) => t.id == listId);
      if (index != -1) {
        _todoLists = [
          ..._todoLists.sublist(0, index),
          updated,
          ..._todoLists.sublist(index + 1),
        ];
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Updates a specific todo item within a todo list.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the todo list containing the item
  ///   - [itemId]: The ID of the todo item to update
  ///   - [item]: The updated todo item
  ///
  /// Example:
  /// ```dart
  /// final updated = item.copyWith(title: 'Updated title');
  /// await provider.updateTodoItem('todo-1', 'item-1', updated);
  /// ```
  Future<void> updateTodoItem(String listId, String itemId, TodoItem item) async {
    _error = null;

    try {
      final updated = await _executeWithRetry(
        () => _todoListRepository.updateItem(listId, itemId, item),
        'updateTodoItem',
      );
      final index = _todoLists.indexWhere((t) => t.id == listId);
      if (index != -1) {
        _todoLists = [
          ..._todoLists.sublist(0, index),
          updated,
          ..._todoLists.sublist(index + 1),
        ];
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Deletes a specific todo item from a todo list.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the todo list containing the item
  ///   - [itemId]: The ID of the todo item to delete
  ///
  /// Example:
  /// ```dart
  /// await provider.deleteTodoItem('todo-1', 'item-1');
  /// ```
  Future<void> deleteTodoItem(String listId, String itemId) async {
    _error = null;

    try {
      final updated = await _executeWithRetry(
        () => _todoListRepository.deleteItem(listId, itemId),
        'deleteTodoItem',
      );
      final index = _todoLists.indexWhere((t) => t.id == listId);
      if (index != -1) {
        _todoLists = [
          ..._todoLists.sublist(0, index),
          updated,
          ..._todoLists.sublist(index + 1),
        ];
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Toggles the completion status of a specific todo item.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the todo list containing the item
  ///   - [itemId]: The ID of the todo item to toggle
  ///
  /// Example:
  /// ```dart
  /// await provider.toggleTodoItem('todo-1', 'item-1');
  /// ```
  Future<void> toggleTodoItem(String listId, String itemId) async {
    _error = null;

    try {
      final updated = await _executeWithRetry(
        () => _todoListRepository.toggleItem(listId, itemId),
        'toggleTodoItem',
      );
      final index = _todoLists.indexWhere((t) => t.id == listId);
      if (index != -1) {
        _todoLists = [
          ..._todoLists.sublist(0, index),
          updated,
          ..._todoLists.sublist(index + 1),
        ];
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Reorders todo items within a todo list.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the todo list
  ///   - [oldIndex]: The current index of the item
  ///   - [newIndex]: The target index for the item
  ///
  /// Example:
  /// ```dart
  /// await provider.reorderTodoItems('todo-1', 0, 2);
  /// ```
  Future<void> reorderTodoItems(String listId, int oldIndex, int newIndex) async {
    _error = null;

    try {
      final updated = await _executeWithRetry(
        () => _todoListRepository.reorderItems(listId, oldIndex, newIndex),
        'reorderTodoItems',
      );
      final index = _todoLists.indexWhere((t) => t.id == listId);
      if (index != -1) {
        _todoLists = [
          ..._todoLists.sublist(0, index),
          updated,
          ..._todoLists.sublist(index + 1),
        ];
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Creates a new list and increments the space item count.
  ///
  /// Parameters:
  ///   - [list]: The list to create
  ///   - [spacesProvider]: The spaces provider to update item count
  ///
  /// Example:
  /// ```dart
  /// final list = ListModel(
  ///   id: 'list-1',
  ///   spaceId: 'space-1',
  ///   name: 'Shopping List',
  ///   style: ListStyle.checkboxes,
  ///   items: [],
  /// );
  /// await provider.createList(list, spacesProvider);
  /// ```
  Future<void> createList(ListModel list, SpacesProvider spacesProvider) async {
    _error = null;

    try {
      final created = await _executeWithRetry(
        () => _listRepository.create(list),
        'createList',
      );
      _lists = [..._lists, created];

      // Increment space item count
      await spacesProvider.incrementSpaceItemCount(list.spaceId);

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Updates an existing list.
  ///
  /// Parameters:
  ///   - [list]: The list with updated values
  ///
  /// Example:
  /// ```dart
  /// final updated = list.copyWith(name: 'Updated Name');
  /// await provider.updateList(updated);
  /// ```
  Future<void> updateList(ListModel list) async {
    _error = null;

    try {
      final updated = await _executeWithRetry(
        () => _listRepository.update(list),
        'updateList',
      );
      final index = _lists.indexWhere((l) => l.id == list.id);
      if (index != -1) {
        _lists = [
          ..._lists.sublist(0, index),
          updated,
          ..._lists.sublist(index + 1),
        ];
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Deletes a list and decrements the space item count.
  ///
  /// Parameters:
  ///   - [id]: The ID of the list to delete
  ///   - [spacesProvider]: The spaces provider to update item count
  ///
  /// Example:
  /// ```dart
  /// await provider.deleteList('list-1', spacesProvider);
  /// ```
  Future<void> deleteList(String id, SpacesProvider spacesProvider) async {
    _error = null;

    try {
      // Get the list to find its spaceId before deleting
      final list = _lists.firstWhere((l) => l.id == id);

      await _executeWithRetry(
        () => _listRepository.delete(id),
        'deleteList',
      );
      _lists = _lists.where((l) => l.id != id).toList();

      // Decrement space item count
      await spacesProvider.decrementSpaceItemCount(list.spaceId);

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Adds a new list item to an existing list.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the list to add the item to
  ///   - [item]: The list item to add
  ///
  /// Example:
  /// ```dart
  /// final item = ListItem(
  ///   id: 'item-1',
  ///   title: 'Milk',
  ///   sortOrder: 0,
  /// );
  /// await provider.addListItem('list-1', item);
  /// ```
  Future<void> addListItem(String listId, ListItem item) async {
    _error = null;

    try {
      final updated = await _executeWithRetry(
        () => _listRepository.addItem(listId, item),
        'addListItem',
      );
      final index = _lists.indexWhere((l) => l.id == listId);
      if (index != -1) {
        _lists = [
          ..._lists.sublist(0, index),
          updated,
          ..._lists.sublist(index + 1),
        ];
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Updates a specific list item within a list.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the list containing the item
  ///   - [itemId]: The ID of the list item to update
  ///   - [item]: The updated list item
  ///
  /// Example:
  /// ```dart
  /// final updated = item.copyWith(title: 'Updated title');
  /// await provider.updateListItem('list-1', 'item-1', updated);
  /// ```
  Future<void> updateListItem(String listId, String itemId, ListItem item) async {
    _error = null;

    try {
      final updated = await _executeWithRetry(
        () => _listRepository.updateItem(listId, itemId, item),
        'updateListItem',
      );
      final index = _lists.indexWhere((l) => l.id == listId);
      if (index != -1) {
        _lists = [
          ..._lists.sublist(0, index),
          updated,
          ..._lists.sublist(index + 1),
        ];
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Deletes a specific list item from a list.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the list containing the item
  ///   - [itemId]: The ID of the list item to delete
  ///
  /// Example:
  /// ```dart
  /// await provider.deleteListItem('list-1', 'item-1');
  /// ```
  Future<void> deleteListItem(String listId, String itemId) async {
    _error = null;

    try {
      final updated = await _executeWithRetry(
        () => _listRepository.deleteItem(listId, itemId),
        'deleteListItem',
      );
      final index = _lists.indexWhere((l) => l.id == listId);
      if (index != -1) {
        _lists = [
          ..._lists.sublist(0, index),
          updated,
          ..._lists.sublist(index + 1),
        ];
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Toggles the checked status of a specific list item (for checkbox style).
  ///
  /// Parameters:
  ///   - [listId]: The ID of the list containing the item
  ///   - [itemId]: The ID of the list item to toggle
  ///
  /// Example:
  /// ```dart
  /// await provider.toggleListItem('list-1', 'item-1');
  /// ```
  Future<void> toggleListItem(String listId, String itemId) async {
    _error = null;

    try {
      final updated = await _executeWithRetry(
        () => _listRepository.toggleItem(listId, itemId),
        'toggleListItem',
      );
      final index = _lists.indexWhere((l) => l.id == listId);
      if (index != -1) {
        _lists = [
          ..._lists.sublist(0, index),
          updated,
          ..._lists.sublist(index + 1),
        ];
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Reorders list items within a list.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the list
  ///   - [oldIndex]: The current index of the item
  ///   - [newIndex]: The target index for the item
  ///
  /// Example:
  /// ```dart
  /// await provider.reorderListItems('list-1', 0, 2);
  /// ```
  Future<void> reorderListItems(String listId, int oldIndex, int newIndex) async {
    _error = null;

    try {
      final updated = await _executeWithRetry(
        () => _listRepository.reorderItems(listId, oldIndex, newIndex),
        'reorderListItems',
      );
      final index = _lists.indexWhere((l) => l.id == listId);
      if (index != -1) {
        _lists = [
          ..._lists.sublist(0, index),
          updated,
          ..._lists.sublist(index + 1),
        ];
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Creates a new note and increments the space item count.
  ///
  /// Parameters:
  ///   - [note]: The note to create
  ///   - [spacesProvider]: The spaces provider to update item count
  ///
  /// Example:
  /// ```dart
  /// final note = Item(
  ///   id: 'note-1',
  ///   title: 'Meeting Notes',
  ///   content: 'Discussion points...',
  ///   spaceId: 'space-1',
  /// );
  /// await provider.createNote(note, spacesProvider);
  /// ```
  Future<void> createNote(Item note, SpacesProvider spacesProvider) async {
    _error = null;

    try {
      final created = await _executeWithRetry(
        () => _noteRepository.create(note),
        'createNote',
      );
      _notes = [..._notes, created];

      // Increment space item count
      await spacesProvider.incrementSpaceItemCount(note.spaceId);

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Updates an existing note.
  ///
  /// Parameters:
  ///   - [note]: The note with updated values
  ///
  /// Example:
  /// ```dart
  /// final updated = note.copyWith(
  ///   title: 'Updated Title',
  ///   content: 'Updated content...',
  /// );
  /// await provider.updateNote(updated);
  /// ```
  Future<void> updateNote(Item note) async {
    _error = null;

    try {
      final updated = await _executeWithRetry(
        () => _noteRepository.update(note),
        'updateNote',
      );
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes = [
          ..._notes.sublist(0, index),
          updated,
          ..._notes.sublist(index + 1),
        ];
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Deletes a note and decrements the space item count.
  ///
  /// Parameters:
  ///   - [id]: The ID of the note to delete
  ///   - [spacesProvider]: The spaces provider to update item count
  ///
  /// Example:
  /// ```dart
  /// await provider.deleteNote('note-1', spacesProvider);
  /// ```
  Future<void> deleteNote(String id, SpacesProvider spacesProvider) async {
    _error = null;

    try {
      // Get the note to find its spaceId before deleting
      final note = _notes.firstWhere((n) => n.id == id);

      await _executeWithRetry(
        () => _noteRepository.delete(id),
        'deleteNote',
      );
      _notes = _notes.where((n) => n.id != id).toList();

      // Decrement space item count
      await spacesProvider.decrementSpaceItemCount(note.spaceId);

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Gets filtered content based on the specified filter.
  ///
  /// Returns a list of all content types combined, or filtered to a specific type.
  ///
  /// Parameters:
  ///   - [filter]: The content filter to apply
  ///
  /// Returns:
  ///   A list of content items (TodoList, ListModel, or Item)
  ///
  /// Example:
  /// ```dart
  /// final allContent = provider.getFilteredContent(ContentFilter.all);
  /// final onlyTodos = provider.getFilteredContent(ContentFilter.todoLists);
  /// ```
  List<dynamic> getFilteredContent(ContentFilter filter) {
    switch (filter) {
      case ContentFilter.all:
        return [..._todoLists, ..._lists, ..._notes];
      case ContentFilter.todoLists:
        return _todoLists;
      case ContentFilter.lists:
        return _lists;
      case ContentFilter.notes:
        return _notes;
    }
  }

  /// Gets the total count of all content items in the current space.
  ///
  /// Returns:
  ///   The total number of content items (TodoLists + Lists + Notes)
  ///
  /// Example:
  /// ```dart
  /// final total = provider.getTotalCount();
  /// print('Space has $total items');
  /// ```
  int getTotalCount() {
    return _todoLists.length + _lists.length + _notes.length;
  }

  /// Searches across all content types by title, content, and other fields.
  ///
  /// Performs a case-insensitive search across:
  /// - TodoList: name, description
  /// - List: name
  /// - Note: title, content
  ///
  /// Parameters:
  ///   - [query]: The search query string
  ///
  /// Returns:
  ///   A list of content items that match the search query
  ///
  /// Example:
  /// ```dart
  /// final results = provider.search('meeting');
  /// print('Found ${results.length} items');
  /// ```
  List<dynamic> search(String query) {
    if (query.isEmpty) {
      return getFilteredContent(ContentFilter.all);
    }

    final lowerQuery = query.toLowerCase();
    final results = <dynamic>[];

    // Search TodoLists
    results.addAll(
      _todoLists.where((todoList) {
        final nameMatch = todoList.name.toLowerCase().contains(lowerQuery);
        final descMatch = todoList.description?.toLowerCase().contains(lowerQuery) ?? false;
        return nameMatch || descMatch;
      }),
    );

    // Search Lists
    results.addAll(
      _lists.where((list) {
        return list.name.toLowerCase().contains(lowerQuery);
      }),
    );

    // Search Notes
    results.addAll(
      _notes.where((note) {
        final titleMatch = note.title.toLowerCase().contains(lowerQuery);
        final contentMatch = note.content?.toLowerCase().contains(lowerQuery) ?? false;
        return titleMatch || contentMatch;
      }),
    );

    return results;
  }

  /// Gets todo lists with items that have a due date on the specified date.
  ///
  /// Useful for "Today" view or filtering by due date.
  ///
  /// Parameters:
  ///   - [date]: The date to filter by (compared by year, month, day only)
  ///
  /// Returns:
  ///   A list of todo lists containing items due on the specified date
  ///
  /// Example:
  /// ```dart
  /// final today = DateTime.now();
  /// final dueTodayLists = provider.getTodosWithDueDate(today);
  /// ```
  List<TodoList> getTodosWithDueDate(DateTime date) {
    return _todoLists.where((todoList) {
      return todoList.items.any((item) {
        if (item.dueDate == null) return false;
        final dueDate = item.dueDate!;
        return dueDate.year == date.year &&
            dueDate.month == date.month &&
            dueDate.day == date.day;
      });
    }).toList();
  }

  /// Clears any current error message.
  ///
  /// This is useful for dismissing error messages in the UI.
  ///
  /// Example:
  /// ```dart
  /// provider.clearError();
  /// ```
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Executes an operation with retry logic.
  ///
  /// Implements exponential backoff for transient failures.
  /// Only retries operations that throw retryable errors.
  ///
  /// Parameters:
  ///   - [operation]: The async operation to execute
  ///   - [operationName]: Name of the operation for error logging
  ///
  /// Returns the result of the operation.
  /// Throws the last error if all retry attempts fail.
  Future<T> _executeWithRetry<T>(
    Future<T> Function() operation,
    String operationName,
  ) async {
    int attempts = 0;
    AppError? lastError;

    while (attempts < _maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        lastError = AppError.fromException(e);

        // Only retry if the error is retryable and we have attempts left
        if (lastError.isRetryable && attempts < _maxRetries) {
          // Exponential backoff: delay increases with each attempt
          final delayMs = _baseDelayMs * (1 << (attempts - 1));
          await Future<void>.delayed(Duration(milliseconds: delayMs));
          continue;
        }

        // Non-retryable error or max retries reached
        throw lastError;
      }
    }

    // This should never be reached, but throw the last error just in case
    throw lastError ?? AppError.unknown(message: 'Unknown error in $operationName');
  }
}
