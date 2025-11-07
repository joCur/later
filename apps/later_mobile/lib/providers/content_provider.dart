import 'package:flutter/foundation.dart';
import '../core/error/app_error.dart';
import '../data/models/list_item_model.dart';
import '../data/models/list_model.dart';
import '../data/models/note_model.dart';
import '../data/models/todo_item_model.dart';
import '../data/models/todo_list_model.dart';
import '../data/repositories/list_repository.dart';
import '../data/repositories/note_repository.dart';
import '../data/repositories/todo_list_repository.dart';

/// Enum to filter content by type
enum ContentFilter { all, todoLists, lists, notes }

/// Provider for managing unified content state (TodoLists, Lists, Notes) in the application.
///
/// This provider handles all content-related operations across three content types:
/// - TodoLists: Container for actionable tasks with progress tracking
/// - Lists: Container for reference collections (shopping lists, etc.)
/// - Notes: Standalone documentation items
///
/// It manages loading states, error states, and notifies listeners of state changes.
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
  }) : _todoListRepository = todoListRepository,
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
  List<Note> _notes = [];

  /// Returns an unmodifiable view of the current notes.
  List<Note> get notes => List.unmodifiable(_notes);

  /// Cache for TodoItems, keyed by TodoList ID.
  /// Items are fetched on-demand and cached for performance.
  final Map<String, List<TodoItem>> _todoItemsCache = {};

  /// Cache for ListItems, keyed by ListModel ID.
  /// Items are fetched on-demand and cached for performance.
  final Map<String, List<ListItem>> _listItemsCache = {};

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
      _notes = results[2] as List<Note>;

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

  /// Creates a new todo list.
  ///
  /// Parameters:
  ///   - [todoList]: The todo list to create
  ///
  /// Example:
  /// ```dart
  /// final todoList = TodoList(
  ///   id: 'todo-1',
  ///   spaceId: 'space-1',
  ///   name: 'Weekly Tasks',
  ///   items: [],
  /// );
  /// await provider.createTodoList(todoList);
  /// ```
  Future<void> createTodoList(TodoList todoList) async {
    _error = null;

    try {
      final created = await _executeWithRetry(
        () => _todoListRepository.create(todoList),
        'createTodoList',
      );
      _todoLists = [..._todoLists, created];

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
      rethrow;
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

  /// Deletes a todo list.
  ///
  /// Parameters:
  ///   - [id]: The ID of the todo list to delete
  ///
  /// Example:
  /// ```dart
  /// await provider.deleteTodoList('todo-1');
  /// ```
  Future<void> deleteTodoList(String id) async {
    _error = null;

    try {
      await _executeWithRetry(
        () => _todoListRepository.delete(id),
        'deleteTodoList',
      );
      _todoLists = _todoLists.where((t) => t.id != id).toList();
      _todoItemsCache.remove(id); // Clear cache

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

  /// Loads todo items for a specific todo list.
  ///
  /// Fetches items from the repository and caches them for future access.
  /// This method is called on-demand by detail screens, not automatically.
  ///
  /// Parameters:
  ///   - [todoListId]: The ID of the todo list to load items for
  ///
  /// Returns:
  ///   A list of todo items for the specified todo list
  ///
  /// Example:
  /// ```dart
  /// final items = await provider.loadTodoItemsForList('todo-1');
  /// ```
  Future<List<TodoItem>> loadTodoItemsForList(String todoListId) async {
    try {
      final items = await _executeWithRetry(
        () => _todoListRepository.getTodoItemsByListId(todoListId),
        'loadTodoItemsForList',
      );
      _todoItemsCache[todoListId] = items;
      return items;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      } else {
        throw AppError.fromException(e);
      }
    }
  }

  /// Creates a new todo item in an existing todo list.
  ///
  /// Creates the item in the repository, updates the cache, and refreshes
  /// the parent todo list to reflect updated counts.
  ///
  /// Parameters:
  ///   - [todoItem]: The todo item to create
  ///
  /// Example:
  /// ```dart
  /// final item = TodoItem(
  ///   id: 'item-1',
  ///   todoListId: 'todo-1',
  ///   title: 'New task',
  ///   sortOrder: 0,
  /// );
  /// await provider.createTodoItem(item);
  /// ```
  Future<void> createTodoItem(TodoItem todoItem) async {
    _error = null;

    try {
      await _executeWithRetry(
        () => _todoListRepository.createTodoItem(todoItem),
        'createTodoItem',
      );

      // Update cache
      _todoItemsCache.remove(todoItem.todoListId);

      // Refresh parent todo list with updated counts
      await _refreshTodoList(todoItem.todoListId);

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
  /// Updates the item in the repository, invalidates the cache, and refreshes
  /// the parent todo list if completion status changed.
  ///
  /// Parameters:
  ///   - [todoItem]: The updated todo item
  ///
  /// Example:
  /// ```dart
  /// final updated = item.copyWith(title: 'Updated title');
  /// await provider.updateTodoItem(updated);
  /// ```
  Future<void> updateTodoItem(TodoItem todoItem) async {
    _error = null;

    try {
      await _executeWithRetry(
        () => _todoListRepository.updateTodoItem(todoItem),
        'updateTodoItem',
      );

      // Update cache
      _todoItemsCache.remove(todoItem.todoListId);

      // Refresh parent todo list (repository updates counts if completion changed)
      await _refreshTodoList(todoItem.todoListId);

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
  /// Deletes the item from the repository, invalidates the cache, and refreshes
  /// the parent todo list to reflect updated counts.
  ///
  /// Parameters:
  ///   - [todoItemId]: The ID of the todo item to delete
  ///   - [todoListId]: The ID of the parent todo list
  ///
  /// Example:
  /// ```dart
  /// await provider.deleteTodoItem('item-1', 'todo-1');
  /// ```
  Future<void> deleteTodoItem(String todoItemId, String todoListId) async {
    _error = null;

    try {
      await _executeWithRetry(
        () => _todoListRepository.deleteTodoItem(todoItemId, todoListId),
        'deleteTodoItem',
      );

      // Update cache
      _todoItemsCache.remove(todoListId);

      // Refresh parent todo list with updated counts
      await _refreshTodoList(todoListId);

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
  /// Updates the sort orders of the affected items and invalidates the cache.
  ///
  /// Parameters:
  ///   - [todoListId]: The ID of the todo list
  ///   - [items]: The list of todo items with updated sortOrder values
  ///
  /// Example:
  /// ```dart
  /// await provider.reorderTodoItems('todo-1', reorderedItems);
  /// ```
  Future<void> reorderTodoItems(
    String todoListId,
    List<TodoItem> items,
  ) async {
    _error = null;

    try {
      await _executeWithRetry(
        () => _todoListRepository.updateTodoItemSortOrders(items),
        'reorderTodoItems',
      );

      // Invalidate cache - items will be refetched when needed
      _todoItemsCache.remove(todoListId);

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

  /// Creates a new list.
  ///
  /// Parameters:
  ///   - [list]: The list to create
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
  /// await provider.createList(list);
  /// ```
  Future<void> createList(ListModel list) async {
    _error = null;

    try {
      final created = await _executeWithRetry(
        () => _listRepository.create(list),
        'createList',
      );
      _lists = [..._lists, created];

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
      rethrow;
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

  /// Deletes a list.
  ///
  /// Parameters:
  ///   - [id]: The ID of the list to delete
  ///
  /// Example:
  /// ```dart
  /// await provider.deleteList('list-1');
  /// ```
  Future<void> deleteList(String id) async {
    _error = null;

    try {
      await _executeWithRetry(() => _listRepository.delete(id), 'deleteList');
      _lists = _lists.where((l) => l.id != id).toList();
      _listItemsCache.remove(id); // Clear cache

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

  /// Loads list items for a specific list.
  ///
  /// Fetches items from the repository and caches them for future access.
  /// This method is called on-demand by detail screens, not automatically.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the list to load items for
  ///
  /// Returns:
  ///   A list of list items for the specified list
  ///
  /// Example:
  /// ```dart
  /// final items = await provider.loadListItemsForList('list-1');
  /// ```
  Future<List<ListItem>> loadListItemsForList(String listId) async {
    try {
      final items = await _executeWithRetry(
        () => _listRepository.getListItemsByListId(listId),
        'loadListItemsForList',
      );
      _listItemsCache[listId] = items;
      return items;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      } else {
        throw AppError.fromException(e);
      }
    }
  }

  /// Creates a new list item in an existing list.
  ///
  /// Creates the item in the repository, updates the cache, and refreshes
  /// the parent list to reflect updated counts.
  ///
  /// Parameters:
  ///   - [listItem]: The list item to create
  ///
  /// Example:
  /// ```dart
  /// final item = ListItem(
  ///   id: 'item-1',
  ///   listId: 'list-1',
  ///   title: 'Milk',
  ///   sortOrder: 0,
  /// );
  /// await provider.createListItem(item);
  /// ```
  Future<void> createListItem(ListItem listItem) async {
    _error = null;

    try {
      await _executeWithRetry(
        () => _listRepository.createListItem(listItem),
        'createListItem',
      );

      // Update cache
      _listItemsCache.remove(listItem.listId);

      // Refresh parent list with updated counts
      await _refreshList(listItem.listId);

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
  /// Updates the item in the repository, invalidates the cache, and refreshes
  /// the parent list if checked status changed.
  ///
  /// Parameters:
  ///   - [listItem]: The updated list item
  ///
  /// Example:
  /// ```dart
  /// final updated = item.copyWith(title: 'Updated title');
  /// await provider.updateListItem(updated);
  /// ```
  Future<void> updateListItem(ListItem listItem) async {
    _error = null;

    try {
      await _executeWithRetry(
        () => _listRepository.updateListItem(listItem),
        'updateListItem',
      );

      // Update cache
      _listItemsCache.remove(listItem.listId);

      // Refresh parent list (repository updates counts if checked status changed)
      await _refreshList(listItem.listId);

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
  /// Deletes the item from the repository, invalidates the cache, and refreshes
  /// the parent list to reflect updated counts.
  ///
  /// Parameters:
  ///   - [listItemId]: The ID of the list item to delete
  ///   - [listId]: The ID of the parent list
  ///
  /// Example:
  /// ```dart
  /// await provider.deleteListItem('item-1', 'list-1');
  /// ```
  Future<void> deleteListItem(String listItemId, String listId) async {
    _error = null;

    try {
      await _executeWithRetry(
        () => _listRepository.deleteListItem(listItemId, listId),
        'deleteListItem',
      );

      // Update cache
      _listItemsCache.remove(listId);

      // Refresh parent list with updated counts
      await _refreshList(listId);

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
  /// Updates the sort orders of the affected items and invalidates the cache.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the list
  ///   - [items]: The list of list items with updated sortOrder values
  ///
  /// Example:
  /// ```dart
  /// await provider.reorderListItems('list-1', reorderedItems);
  /// ```
  Future<void> reorderListItems(
    String listId,
    List<ListItem> items,
  ) async {
    _error = null;

    try {
      await _executeWithRetry(
        () => _listRepository.updateListItemSortOrders(items),
        'reorderListItems',
      );

      // Invalidate cache - items will be refetched when needed
      _listItemsCache.remove(listId);

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

  /// Reorders heterogeneous content items within the current space.
  ///
  /// This method handles reordering of mixed content types (TodoLists, Lists, Notes).
  /// It updates the sortOrder field for all affected items and persists the changes
  /// to the database.
  ///
  /// Parameters:
  ///   - [filter]: The current content filter (determines which items are being reordered)
  ///   - [oldIndex]: The current index of the item
  ///   - [newIndex]: The target index for the item
  ///
  /// Example:
  /// ```dart
  /// await provider.reorderContent(ContentFilter.all, 0, 2);
  /// ```
  Future<void> reorderContent(
    ContentFilter filter,
    int oldIndex,
    int newIndex,
  ) async {
    _error = null;

    try {
      // Get current filtered content
      final content = getFilteredContent(filter);

      // Adjust newIndex if moving down (ReorderableListView convention)
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      // Perform in-memory reorder
      final item = content[oldIndex];
      content.removeAt(oldIndex);
      content.insert(newIndex, item);

      // PHASE 1: Update all local state FIRST (optimistic update)
      final updatedItems = <dynamic>[];
      for (int i = 0; i < content.length; i++) {
        final currentItem = content[i];
        final newSortOrder = i;

        // Create updated items with new sortOrder
        if (currentItem is TodoList) {
          final updated = currentItem.copyWith(sortOrder: newSortOrder);
          updatedItems.add(updated);

          // Update local state immediately
          final index = _todoLists.indexWhere((t) => t.id == currentItem.id);
          if (index != -1) {
            _todoLists = [
              ..._todoLists.sublist(0, index),
              updated,
              ..._todoLists.sublist(index + 1),
            ];
          }
        } else if (currentItem is ListModel) {
          final updated = currentItem.copyWith(sortOrder: newSortOrder);
          updatedItems.add(updated);

          // Update local state immediately
          final index = _lists.indexWhere((l) => l.id == currentItem.id);
          if (index != -1) {
            _lists = [
              ..._lists.sublist(0, index),
              updated,
              ..._lists.sublist(index + 1),
            ];
          }
        } else if (currentItem is Note) {
          final updated = currentItem.copyWith(sortOrder: newSortOrder);
          updatedItems.add(updated);

          // Update local state immediately
          final index = _notes.indexWhere((n) => n.id == currentItem.id);
          if (index != -1) {
            _notes = [
              ..._notes.sublist(0, index),
              updated,
              ..._notes.sublist(index + 1),
            ];
          }
        }
      }

      // Notify listeners immediately for instant UI update
      notifyListeners();

      // PHASE 2: Persist to database in parallel for better performance
      final updateFutures = <Future<void>>[];
      for (final item in updatedItems) {
        if (item is TodoList) {
          updateFutures.add(
            _executeWithRetry(
              () => _todoListRepository.update(item),
              'updateTodoList',
            ),
          );
        } else if (item is ListModel) {
          updateFutures.add(
            _executeWithRetry(
              () => _listRepository.update(item),
              'updateList',
            ),
          );
        } else if (item is Note) {
          updateFutures.add(
            _executeWithRetry(
              () => _noteRepository.update(item),
              'updateNote',
            ),
          );
        }
      }
      await Future.wait(updateFutures);

      _error = null;
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
      rethrow; // Rethrow so UI can handle the error
    }
  }

  /// Creates a new note.
  ///
  /// Parameters:
  ///   - [note]: The note to create
  ///
  /// Example:
  /// ```dart
  /// final note = Note(
  ///   id: 'note-1',
  ///   title: 'Meeting Notes',
  ///   content: 'Discussion points...',
  ///   spaceId: 'space-1',
  /// );
  /// await provider.createNote(note);
  /// ```
  Future<void> createNote(Note note) async {
    _error = null;

    try {
      final created = await _executeWithRetry(
        () => _noteRepository.create(note),
        'createNote',
      );
      _notes = [..._notes, created];

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
  Future<void> updateNote(Note note) async {
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

  /// Deletes a note.
  ///
  /// Parameters:
  ///   - [id]: The ID of the note to delete
  ///
  /// Example:
  /// ```dart
  /// await provider.deleteNote('note-1');
  /// ```
  Future<void> deleteNote(String id) async {
    _error = null;

    try {
      await _executeWithRetry(() => _noteRepository.delete(id), 'deleteNote');
      _notes = _notes.where((n) => n.id != id).toList();

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
  /// Content is sorted by sortOrder in ascending order.
  ///
  /// Parameters:
  ///   - [filter]: The content filter to apply
  ///
  /// Returns:
  ///   A list of content items (TodoList, ListModel, or Item) sorted by sortOrder
  ///
  /// Example:
  /// ```dart
  /// final allContent = provider.getFilteredContent(ContentFilter.all);
  /// final onlyTodos = provider.getFilteredContent(ContentFilter.todoLists);
  /// ```
  List<dynamic> getFilteredContent(ContentFilter filter) {
    List<dynamic> result;
    switch (filter) {
      case ContentFilter.all:
        result = [..._todoLists, ..._lists, ..._notes];
      case ContentFilter.todoLists:
        result = [..._todoLists];
      case ContentFilter.lists:
        result = [..._lists];
      case ContentFilter.notes:
        result = [..._notes];
    }

    // Sort by sortOrder
    result.sort((a, b) => _getSortOrder(a).compareTo(_getSortOrder(b)));
    return result;
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
        final descMatch =
            todoList.description?.toLowerCase().contains(lowerQuery) ?? false;
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
        final contentMatch =
            note.content?.toLowerCase().contains(lowerQuery) ?? false;
        return titleMatch || contentMatch;
      }),
    );

    return results;
  }

  /// Gets todo lists with items that have a due date on the specified date.
  ///
  /// Note: This method requires items to be loaded first using loadTodoItemsForList().
  /// Only checks cached items - if items are not cached, the list will not be included.
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
  /// final dueTodayLists = await provider.getTodosWithDueDate(today);
  /// ```
  Future<List<TodoList>> getTodosWithDueDate(DateTime date) async {
    final matchingLists = <TodoList>[];

    for (final todoList in _todoLists) {
      // Load items if not cached
      if (!_todoItemsCache.containsKey(todoList.id)) {
        await loadTodoItemsForList(todoList.id);
      }

      final items = _todoItemsCache[todoList.id] ?? [];
      final hasMatchingItem = items.any((item) {
        if (item.dueDate == null) return false;
        final dueDate = item.dueDate!;
        return dueDate.year == date.year &&
            dueDate.month == date.month &&
            dueDate.day == date.day;
      });

      if (hasMatchingItem) {
        matchingLists.add(todoList);
      }
    }

    return matchingLists;
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

  /// Refreshes a todo list from the repository.
  ///
  /// Fetches the latest version of the todo list (with updated counts) and
  /// updates the local state.
  ///
  /// Parameters:
  ///   - [todoListId]: The ID of the todo list to refresh
  Future<void> _refreshTodoList(String todoListId) async {
    final refreshed = await _executeWithRetry(
      () => _todoListRepository.getById(todoListId),
      'refreshTodoList',
    );

    if (refreshed != null) {
      final index = _todoLists.indexWhere((t) => t.id == todoListId);
      if (index != -1) {
        _todoLists = [
          ..._todoLists.sublist(0, index),
          refreshed,
          ..._todoLists.sublist(index + 1),
        ];
      }
    }
  }

  /// Refreshes a list from the repository.
  ///
  /// Fetches the latest version of the list (with updated counts) and
  /// updates the local state.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the list to refresh
  Future<void> _refreshList(String listId) async {
    final refreshed = await _executeWithRetry(
      () => _listRepository.getById(listId),
      'refreshList',
    );

    if (refreshed != null) {
      final index = _lists.indexWhere((l) => l.id == listId);
      if (index != -1) {
        _lists = [
          ..._lists.sublist(0, index),
          refreshed,
          ..._lists.sublist(index + 1),
        ];
      }
    }
  }

  /// Gets the sortOrder value from a content item.
  ///
  /// This helper method extracts the sortOrder field from different content types
  /// (TodoList, ListModel, Note). Returns 0 if the item type is unknown.
  ///
  /// Parameters:
  ///   - [item]: The content item (TodoList, ListModel, or Note)
  ///
  /// Returns the sortOrder value of the item.
  int _getSortOrder(dynamic item) {
    if (item is TodoList) {
      return item.sortOrder;
    } else if (item is ListModel) {
      return item.sortOrder;
    } else if (item is Note) {
      return item.sortOrder;
    }
    return 0;
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
    throw lastError ??
        AppError.unknown(message: 'Unknown error in $operationName');
  }
}
