import 'package:hive/hive.dart';
import 'package:later_mobile/data/models/list_model.dart';
import 'package:later_mobile/data/models/list_item_model.dart';

/// Repository for managing ListModel entities in Hive local storage.
///
/// Provides CRUD operations for Lists and ListItems within them.
/// Uses Hive box 'lists' for persistence.
class ListRepository {
  /// Gets the Hive box for lists
  Box<ListModel> get _box => Hive.box<ListModel>('lists');

  /// Creates a new list in the local storage.
  ///
  /// Automatically calculates and assigns the next sortOrder value for the list
  /// within its space. The sortOrder is space-scoped, starting at 0 for the first
  /// list in a space and incrementing for each subsequent list.
  ///
  /// Stores the list using its ID as the key in the Hive box.
  ///
  /// Parameters:
  ///   - [list]: The list to be created
  ///
  /// Returns:
  ///   The created list with assigned sortOrder
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
  /// final created = await repository.create(list);
  /// // created.sortOrder will be 0 for first list in space, 1 for second, etc.
  /// ```
  Future<ListModel> create(ListModel list) async {
    try {
      // Calculate next sortOrder for this space
      final listsInSpace = await getBySpace(list.spaceId);
      final maxSortOrder = listsInSpace.isEmpty
          ? -1
          : listsInSpace
              .map((l) => l.sortOrder)
              .reduce((a, b) => a > b ? a : b);
      final nextSortOrder = maxSortOrder + 1;

      // Create list with calculated sortOrder
      final listWithSortOrder = list.copyWith(sortOrder: nextSortOrder);
      await _box.put(listWithSortOrder.id, listWithSortOrder);
      return listWithSortOrder;
    } catch (e) {
      throw Exception('Failed to create list: $e');
    }
  }

  /// Retrieves a single list by its ID.
  ///
  /// Returns null if the list does not exist.
  ///
  /// Parameters:
  ///   - [id]: The ID of the list to retrieve
  ///
  /// Returns:
  ///   The list with the given ID, or null if not found
  ///
  /// Example:
  /// ```dart
  /// final list = await repository.getById('list-1');
  /// if (list != null) {
  ///   print('Found: ${list.name}');
  /// }
  /// ```
  Future<ListModel?> getById(String id) async {
    try {
      return _box.get(id);
    } catch (e) {
      throw Exception('Failed to get list by id: $e');
    }
  }

  /// Retrieves all lists belonging to a specific space.
  ///
  /// Filters lists by their spaceId property.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to filter by
  ///
  /// Returns:
  ///   A list of lists belonging to the specified space
  ///
  /// Example:
  /// ```dart
  /// final workLists = await repository.getBySpace('work-space-1');
  /// print('Found ${workLists.length} lists');
  /// ```
  Future<List<ListModel>> getBySpace(String spaceId) async {
    try {
      return _box.values.where((list) => list.spaceId == spaceId).toList();
    } catch (e) {
      throw Exception('Failed to get lists by space: $e');
    }
  }

  /// Updates an existing list in local storage.
  ///
  /// Automatically updates the updatedAt timestamp to the current time.
  /// Throws an exception if the list does not exist.
  ///
  /// Parameters:
  ///   - [list]: The list to update with new values
  ///
  /// Returns:
  ///   The updated list with the new updatedAt timestamp
  ///
  /// Throws:
  ///   Exception if the list with the given ID does not exist
  ///
  /// Example:
  /// ```dart
  /// final updated = list.copyWith(name: 'Updated Name');
  /// final result = await repository.update(updated);
  /// ```
  Future<ListModel> update(ListModel list) async {
    try {
      // Check if the list exists
      if (!_box.containsKey(list.id)) {
        throw Exception('ListModel with id ${list.id} does not exist');
      }

      // Update the updatedAt timestamp
      final updatedList = list.copyWith(updatedAt: DateTime.now());

      await _box.put(updatedList.id, updatedList);
      return updatedList;
    } catch (e) {
      throw Exception('Failed to update list: $e');
    }
  }

  /// Deletes a list from local storage.
  ///
  /// If the list does not exist, this operation completes without error.
  ///
  /// Parameters:
  ///   - [id]: The ID of the list to delete
  ///
  /// Example:
  /// ```dart
  /// await repository.delete('list-1');
  /// ```
  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw Exception('Failed to delete list: $e');
    }
  }

  /// Adds a new list item to an existing list.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the list to add the item to
  ///   - [item]: The list item to add
  ///
  /// Returns:
  ///   The updated list with the new item
  ///
  /// Throws:
  ///   Exception if the list does not exist
  ///
  /// Example:
  /// ```dart
  /// final item = ListItem(
  ///   id: 'item-1',
  ///   title: 'Milk',
  ///   sortOrder: 0,
  /// );
  /// final updated = await repository.addItem('list-1', item);
  /// ```
  Future<ListModel> addItem(String listId, ListItem item) async {
    try {
      final list = await getById(listId);
      if (list == null) {
        throw Exception('ListModel with id $listId does not exist');
      }

      final updatedItems = [...list.items, item];
      final updatedList = list.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      await _box.put(listId, updatedList);
      return updatedList;
    } catch (e) {
      throw Exception('Failed to add item to list: $e');
    }
  }

  /// Updates a specific list item within a list.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the list containing the item
  ///   - [itemId]: The ID of the list item to update
  ///   - [updatedItem]: The updated list item
  ///
  /// Returns:
  ///   The updated list
  ///
  /// Throws:
  ///   Exception if the list or item does not exist
  ///
  /// Example:
  /// ```dart
  /// final updated = await repository.updateItem(
  ///   'list-1',
  ///   'item-1',
  ///   item.copyWith(title: 'Updated title'),
  /// );
  /// ```
  Future<ListModel> updateItem(
    String listId,
    String itemId,
    ListItem updatedItem,
  ) async {
    try {
      final list = await getById(listId);
      if (list == null) {
        throw Exception('ListModel with id $listId does not exist');
      }

      final itemIndex = list.items.indexWhere((item) => item.id == itemId);
      if (itemIndex == -1) {
        throw Exception(
          'ListItem with id $itemId does not exist in list $listId',
        );
      }

      final updatedItems = [...list.items];
      updatedItems[itemIndex] = updatedItem;

      final updatedList = list.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      await _box.put(listId, updatedList);
      return updatedList;
    } catch (e) {
      throw Exception('Failed to update item in list: $e');
    }
  }

  /// Deletes a specific list item from a list.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the list containing the item
  ///   - [itemId]: The ID of the list item to delete
  ///
  /// Returns:
  ///   The updated list without the deleted item
  ///
  /// Throws:
  ///   Exception if the list does not exist
  ///
  /// Example:
  /// ```dart
  /// final updated = await repository.deleteItem('list-1', 'item-1');
  /// ```
  Future<ListModel> deleteItem(String listId, String itemId) async {
    try {
      final list = await getById(listId);
      if (list == null) {
        throw Exception('ListModel with id $listId does not exist');
      }

      final updatedItems = list.items
          .where((item) => item.id != itemId)
          .toList();

      final updatedList = list.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      await _box.put(listId, updatedList);
      return updatedList;
    } catch (e) {
      throw Exception('Failed to delete item from list: $e');
    }
  }

  /// Toggles the checked status of a specific list item.
  ///
  /// This is only relevant for lists with checkbox style.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the list containing the item
  ///   - [itemId]: The ID of the list item to toggle
  ///
  /// Returns:
  ///   The updated list with the toggled item
  ///
  /// Throws:
  ///   Exception if the list or item does not exist
  ///
  /// Example:
  /// ```dart
  /// final updated = await repository.toggleItem('list-1', 'item-1');
  /// ```
  Future<ListModel> toggleItem(String listId, String itemId) async {
    try {
      final list = await getById(listId);
      if (list == null) {
        throw Exception('ListModel with id $listId does not exist');
      }

      final itemIndex = list.items.indexWhere((item) => item.id == itemId);
      if (itemIndex == -1) {
        throw Exception(
          'ListItem with id $itemId does not exist in list $listId',
        );
      }

      final updatedItems = [...list.items];
      updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(
        isChecked: !updatedItems[itemIndex].isChecked,
      );

      final updatedList = list.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      await _box.put(listId, updatedList);
      return updatedList;
    } catch (e) {
      throw Exception('Failed to toggle item in list: $e');
    }
  }

  /// Reorders list items within a list.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the list
  ///   - [oldIndex]: The current index of the item
  ///   - [newIndex]: The target index for the item
  ///
  /// Returns:
  ///   The updated list with reordered items
  ///
  /// Throws:
  ///   Exception if the list does not exist or indices are invalid
  ///
  /// Example:
  /// ```dart
  /// final updated = await repository.reorderItems('list-1', 0, 2);
  /// ```
  Future<ListModel> reorderItems(
    String listId,
    int oldIndex,
    int newIndex,
  ) async {
    try {
      final list = await getById(listId);
      if (list == null) {
        throw Exception('ListModel with id $listId does not exist');
      }

      if (oldIndex < 0 ||
          oldIndex >= list.items.length ||
          newIndex < 0 ||
          newIndex >= list.items.length) {
        throw Exception(
          'Invalid reorder indices: oldIndex=$oldIndex, newIndex=$newIndex',
        );
      }

      final updatedItems = [...list.items];
      final item = updatedItems.removeAt(oldIndex);
      updatedItems.insert(newIndex, item);

      // Update sort order for all items
      final reorderedItems = updatedItems.asMap().entries.map((entry) {
        return entry.value.copyWith(sortOrder: entry.key);
      }).toList();

      final updatedList = list.copyWith(
        items: reorderedItems,
        updatedAt: DateTime.now(),
      );

      await _box.put(listId, updatedList);
      return updatedList;
    } catch (e) {
      throw Exception('Failed to reorder items in list: $e');
    }
  }

  /// Deletes all lists belonging to a specific space.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space
  ///
  /// Returns:
  ///   The number of lists deleted
  ///
  /// Example:
  /// ```dart
  /// final count = await repository.deleteAllInSpace('space-1');
  /// print('Deleted $count lists');
  /// ```
  Future<int> deleteAllInSpace(String spaceId) async {
    try {
      final lists = await getBySpace(spaceId);
      for (final list in lists) {
        await delete(list.id);
      }
      return lists.length;
    } catch (e) {
      throw Exception('Failed to delete all lists in space: $e');
    }
  }

  /// Counts the number of lists in a specific space.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space
  ///
  /// Returns:
  ///   The number of lists in the space
  ///
  /// Example:
  /// ```dart
  /// final count = await repository.countBySpace('space-1');
  /// print('Space has $count lists');
  /// ```
  Future<int> countBySpace(String spaceId) async {
    try {
      final lists = await getBySpace(spaceId);
      return lists.length;
    } catch (e) {
      throw Exception('Failed to count lists in space: $e');
    }
  }
}
