import 'package:flutter/foundation.dart';
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

  /// Current error message, if any.
  String? _error;

  /// Returns the current error message, or null if there is no error.
  String? get error => _error;

  /// Loads all items from the repository.
  ///
  /// Sets the loading state, fetches all items, and updates the state
  /// accordingly. If an error occurs, it is captured in the error state.
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
      _items = await _repository.getItems();
      _error = null;
    } catch (e) {
      _error = e.toString();
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
      _items = await _repository.getItemsBySpace(spaceId);
      _error = null;
    } catch (e) {
      _error = e.toString();
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
      _items = await _repository.getItemsByType(type);
      _error = null;
    } catch (e) {
      _error = e.toString();
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
      final createdItem = await _repository.createItem(item);
      _items = [..._items, createdItem];
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Updates an existing item in the repository and updates the state.
  ///
  /// The item is updated in the repository and then the local list
  /// is updated to reflect the changes. If the item does not exist,
  /// an error is set.
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
      final updatedItem = await _repository.updateItem(item);
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
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Deletes an item from the repository and updates the state.
  ///
  /// The item is removed from the repository and then removed from
  /// the local list of items. If an error occurs, the state is not updated.
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
      await _repository.deleteItem(id);
      _items = _items.where((item) => item.id != id).toList();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Toggles the completion status of a task item.
  ///
  /// Finds the item by ID, flips its isCompleted status, and updates
  /// it in the repository. If the item is not found, an error is set.
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
      _error = e.toString();
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
}
