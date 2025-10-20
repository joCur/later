import 'package:flutter/foundation.dart';
import '../core/error/app_error.dart';
import '../data/models/item_model.dart';
import '../data/repositories/item_repository.dart';

/// Provider for managing Item state in the application.
///
/// This provider handles all item-related operations including loading,
/// creating, updating, and deleting items. It manages loading states,
/// error states, and notifies listeners of state changes.
///
/// Example usage:
/// ```dart
/// final provider = Provider.of<ItemsProvider>(context);
/// await provider.loadItems();
/// print('Loaded ${provider.items.length} items');
/// ```
class ItemsProvider extends ChangeNotifier {
  /// Creates an ItemsProvider with the given repository.
  ///
  /// The [repository] parameter is required and will be used for all
  /// data persistence operations.
  ItemsProvider(this._repository);

  final ItemRepository _repository;

  /// List of items currently loaded in the provider.
  List<Item> _items = [];

  /// Returns an unmodifiable view of the current items.
  List<Item> get items => List.unmodifiable(_items);

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

  /// Loads all items from the repository.
  ///
  /// Sets the loading state, fetches all items, and updates the state
  /// accordingly. If an error occurs, it is captured in the error state.
  /// Implements automatic retry with exponential backoff for transient failures.
  ///
  /// Example:
  /// ```dart
  /// await provider.loadItems();
  /// if (provider.error != null) {
  ///   print('Error loading items: ${provider.error}');
  /// }
  /// ```
  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _executeWithRetry(
        () => _repository.getItems(),
        'loadItems',
      );
      _error = null;
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads items filtered by a specific space.
  ///
  /// Sets the loading state, fetches items for the given space,
  /// and updates the state accordingly.
  /// Implements automatic retry with exponential backoff for transient failures.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to filter by
  ///
  /// Example:
  /// ```dart
  /// await provider.loadItemsBySpace('space-1');
  /// print('Found ${provider.items.length} items in this space');
  /// ```
  Future<void> loadItemsBySpace(String spaceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _executeWithRetry(
        () => _repository.getItemsBySpace(spaceId),
        'loadItemsBySpace',
      );
      _error = null;
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads items filtered by a specific type.
  ///
  /// Sets the loading state, fetches items of the given type,
  /// and updates the state accordingly.
  /// Implements automatic retry with exponential backoff for transient failures.
  ///
  /// Parameters:
  ///   - [type]: The ItemType to filter by (task, note, or list)
  ///
  /// Example:
  /// ```dart
  /// await provider.loadItemsByType(ItemType.task);
  /// print('Found ${provider.items.length} tasks');
  /// ```
  Future<void> loadItemsByType(ItemType type) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _executeWithRetry(
        () => _repository.getItemsByType(type),
        'loadItemsByType',
      );
      _error = null;
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new item to the repository and updates the state.
  ///
  /// The item is added to the repository and then added to the local
  /// list of items. If an error occurs, the state is not updated.
  /// Implements automatic retry with exponential backoff for transient failures.
  ///
  /// Parameters:
  ///   - [item]: The item to add
  ///
  /// Example:
  /// ```dart
  /// final newItem = Item(
  ///   id: 'item-1',
  ///   type: ItemType.task,
  ///   title: 'Buy groceries',
  ///   spaceId: 'space-1',
  /// );
  /// await provider.addItem(newItem);
  /// ```
  Future<void> addItem(Item item) async {
    _error = null;

    try {
      final createdItem = await _executeWithRetry(
        () => _repository.createItem(item),
        'addItem',
      );
      _items = [..._items, createdItem];
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

  /// Updates an existing item in the repository and updates the state.
  ///
  /// The item is updated in the repository and then the local list
  /// is updated to reflect the changes. If the item does not exist,
  /// an error is set.
  /// Implements automatic retry with exponential backoff for transient failures.
  ///
  /// Parameters:
  ///   - [item]: The item to update with new values
  ///
  /// Example:
  /// ```dart
  /// final updatedItem = item.copyWith(
  ///   title: 'Updated title',
  ///   isCompleted: true,
  /// );
  /// await provider.updateItem(updatedItem);
  /// ```
  Future<void> updateItem(Item item) async {
    _error = null;

    try {
      final updatedItem = await _executeWithRetry(
        () => _repository.updateItem(item),
        'updateItem',
      );
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items = [
          ..._items.sublist(0, index),
          updatedItem,
          ..._items.sublist(index + 1),
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

  /// Deletes an item from the repository and updates the state.
  ///
  /// The item is removed from the repository and then removed from
  /// the local list of items. If an error occurs, the state is not updated.
  /// Implements automatic retry with exponential backoff for transient failures.
  ///
  /// Parameters:
  ///   - [id]: The ID of the item to delete
  ///
  /// Example:
  /// ```dart
  /// await provider.deleteItem('item-1');
  /// ```
  Future<void> deleteItem(String id) async {
    _error = null;

    try {
      await _executeWithRetry(
        () => _repository.deleteItem(id),
        'deleteItem',
      );
      _items = _items.where((item) => item.id != id).toList();
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

  /// Toggles the completion status of a task item.
  ///
  /// Finds the item by ID, flips its isCompleted status, and updates
  /// it in the repository. If the item is not found, an error is set.
  /// Implements automatic retry with exponential backoff for transient failures.
  ///
  /// Parameters:
  ///   - [id]: The ID of the task item to toggle
  ///
  /// Example:
  /// ```dart
  /// await provider.toggleCompletion('item-1');
  /// ```
  Future<void> toggleCompletion(String id) async {
    _error = null;

    try {
      final item = _items.firstWhere(
        (i) => i.id == id,
        orElse: () => throw Exception('Item with id $id not found'),
      );

      final updatedItem = item.copyWith(isCompleted: !item.isCompleted);
      await updateItem(updatedItem);
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
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
