import 'package:hive/hive.dart';
import '../models/item_model.dart';

/// Repository for managing Item entities in Hive local storage.
///
/// Provides CRUD operations and filtering capabilities for items.
/// Uses Hive box 'items' for persistence.
class ItemRepository {
  /// Gets the Hive box for items
  Box<Item> get _box => Hive.box<Item>('items');

  /// Creates a new item in the local storage.
  ///
  /// Stores the item using its ID as the key in the Hive box.
  ///
  /// Parameters:
  ///   - [item]: The item to be created
  ///
  /// Returns:
  ///   The created item
  ///
  /// Example:
  /// ```dart
  /// final item = Item(
  ///   id: 'item-1',
  ///   type: ItemType.task,
  ///   title: 'Buy groceries',
  ///   spaceId: 'space-1',
  /// );
  /// final created = await repository.createItem(item);
  /// ```
  Future<Item> createItem(Item item) async {
    await _box.put(item.id, item);
    return item;
  }

  /// Retrieves all items from local storage.
  ///
  /// Returns:
  ///   A list of all items in the storage
  ///
  /// Example:
  /// ```dart
  /// final items = await repository.getItems();
  /// print('Total items: ${items.length}');
  /// ```
  Future<List<Item>> getItems() async {
    return _box.values.toList();
  }

  /// Retrieves all items belonging to a specific space.
  ///
  /// Filters items by their spaceId property.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to filter by
  ///
  /// Returns:
  ///   A list of items belonging to the specified space
  ///
  /// Example:
  /// ```dart
  /// final workItems = await repository.getItemsBySpace('work-space-1');
  /// ```
  Future<List<Item>> getItemsBySpace(String spaceId) async {
    return _box.values.where((item) => item.spaceId == spaceId).toList();
  }

  /// Retrieves all items of a specific type.
  ///
  /// Filters items by their ItemType (task, note, or list).
  ///
  /// Parameters:
  ///   - [type]: The ItemType to filter by
  ///
  /// Returns:
  ///   A list of items matching the specified type
  ///
  /// Example:
  /// ```dart
  /// final tasks = await repository.getItemsByType(ItemType.task);
  /// final notes = await repository.getItemsByType(ItemType.note);
  /// ```
  Future<List<Item>> getItemsByType(ItemType type) async {
    return _box.values.where((item) => item.type == type).toList();
  }

  /// Updates an existing item in local storage.
  ///
  /// Automatically updates the updatedAt timestamp to the current time.
  /// Throws an exception if the item does not exist.
  ///
  /// Parameters:
  ///   - [item]: The item to update with new values
  ///
  /// Returns:
  ///   The updated item with the new updatedAt timestamp
  ///
  /// Throws:
  ///   Exception if the item with the given ID does not exist
  ///
  /// Example:
  /// ```dart
  /// final updatedItem = item.copyWith(
  ///   title: 'Updated title',
  ///   isCompleted: true,
  /// );
  /// final result = await repository.updateItem(updatedItem);
  /// ```
  Future<Item> updateItem(Item item) async {
    // Check if the item exists
    if (!_box.containsKey(item.id)) {
      throw Exception('Item with id ${item.id} does not exist');
    }

    // Update the updatedAt timestamp
    final updatedItem = item.copyWith(
      updatedAt: DateTime.now(),
    );

    await _box.put(updatedItem.id, updatedItem);
    return updatedItem;
  }

  /// Deletes an item from local storage.
  ///
  /// If the item does not exist, this operation completes without error.
  ///
  /// Parameters:
  ///   - [id]: The ID of the item to delete
  ///
  /// Example:
  /// ```dart
  /// await repository.deleteItem('item-1');
  /// ```
  Future<void> deleteItem(String id) async {
    await _box.delete(id);
  }
}
