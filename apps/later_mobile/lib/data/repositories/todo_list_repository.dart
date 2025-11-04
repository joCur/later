import 'package:hive/hive.dart';
import 'package:later_mobile/data/models/list_model.dart';
import 'package:later_mobile/data/models/list_item_model.dart';
import 'package:later_mobile/data/models/list_style.dart';
import 'package:later_mobile/data/models/todo_item_model.dart';
import 'package:later_mobile/data/models/todo_priority.dart';

/// Repository for managing TodoList entities in Hive local storage.
///
/// Provides CRUD operations for TodoLists and TodoItems within them.
/// Uses Hive box 'todo_lists' for persistence.
class TodoListRepository {
  /// Gets the Hive box for todo lists
  Box<TodoList> get _box => Hive.box<TodoList>('todo_lists');

  /// Creates a new todo list in the local storage.
  ///
  /// Automatically calculates and assigns the next sortOrder value for the todo list
  /// within its space. The sortOrder is space-scoped, starting at 0 for the first
  /// todo list in a space and incrementing for each subsequent todo list.
  ///
  /// Stores the todo list using its ID as the key in the Hive box.
  ///
  /// Parameters:
  ///   - [todoList]: The todo list to be created
  ///
  /// Returns:
  ///   The created todo list with assigned sortOrder
  ///
  /// Example:
  /// ```dart
  /// final todoList = TodoList(
  ///   id: 'todo-1',
  ///   spaceId: 'space-1',
  ///   name: 'Weekly Tasks',
  ///   items: [],
  /// );
  /// final created = await repository.create(todoList);
  /// // created.sortOrder will be 0 for first todo list in space, 1 for second, etc.
  /// ```
  Future<TodoList> create(TodoList todoList) async {
    try {
      // Calculate next sortOrder for this space
      final todoListsInSpace = await getBySpace(todoList.spaceId);
      final maxSortOrder = todoListsInSpace.isEmpty
          ? -1
          : todoListsInSpace
              .map((t) => t.sortOrder)
              .reduce((a, b) => a > b ? a : b);
      final nextSortOrder = maxSortOrder + 1;

      // Create todo list with calculated sortOrder
      final todoListWithSortOrder = todoList.copyWith(sortOrder: nextSortOrder);
      await _box.put(todoListWithSortOrder.id, todoListWithSortOrder);
      return todoListWithSortOrder;
    } catch (e) {
      throw Exception('Failed to create todo list: $e');
    }
  }

  /// Retrieves a single todo list by its ID.
  ///
  /// Returns null if the todo list does not exist.
  ///
  /// Parameters:
  ///   - [id]: The ID of the todo list to retrieve
  ///
  /// Returns:
  ///   The todo list with the given ID, or null if not found
  ///
  /// Example:
  /// ```dart
  /// final todoList = await repository.getById('todo-1');
  /// if (todoList != null) {
  ///   print('Found: ${todoList.name}');
  /// }
  /// ```
  Future<TodoList?> getById(String id) async {
    try {
      return _box.get(id);
    } catch (e) {
      throw Exception('Failed to get todo list by id: $e');
    }
  }

  /// Retrieves all todo lists belonging to a specific space.
  ///
  /// Filters todo lists by their spaceId property.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to filter by
  ///
  /// Returns:
  ///   A list of todo lists belonging to the specified space
  ///
  /// Example:
  /// ```dart
  /// final workTodos = await repository.getBySpace('work-space-1');
  /// print('Found ${workTodos.length} todo lists');
  /// ```
  Future<List<TodoList>> getBySpace(String spaceId) async {
    try {
      return _box.values.where((list) => list.spaceId == spaceId).toList();
    } catch (e) {
      throw Exception('Failed to get todo lists by space: $e');
    }
  }

  /// Updates an existing todo list in local storage.
  ///
  /// Automatically updates the updatedAt timestamp to the current time.
  /// Throws an exception if the todo list does not exist.
  ///
  /// Parameters:
  ///   - [todoList]: The todo list to update with new values
  ///
  /// Returns:
  ///   The updated todo list with the new updatedAt timestamp
  ///
  /// Throws:
  ///   Exception if the todo list with the given ID does not exist
  ///
  /// Example:
  /// ```dart
  /// final updated = todoList.copyWith(name: 'Updated Name');
  /// final result = await repository.update(updated);
  /// ```
  Future<TodoList> update(TodoList todoList) async {
    try {
      // Check if the todo list exists
      if (!_box.containsKey(todoList.id)) {
        throw Exception('TodoList with id ${todoList.id} does not exist');
      }

      // Update the updatedAt timestamp
      final updatedTodoList = todoList.copyWith(updatedAt: DateTime.now());

      await _box.put(updatedTodoList.id, updatedTodoList);
      return updatedTodoList;
    } catch (e) {
      throw Exception('Failed to update todo list: $e');
    }
  }

  /// Deletes a todo list from local storage.
  ///
  /// If the todo list does not exist, this operation completes without error.
  ///
  /// Parameters:
  ///   - [id]: The ID of the todo list to delete
  ///
  /// Example:
  /// ```dart
  /// await repository.delete('todo-1');
  /// ```
  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw Exception('Failed to delete todo list: $e');
    }
  }

  /// Adds a new todo item to an existing todo list.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the todo list to add the item to
  ///   - [item]: The todo item to add
  ///
  /// Returns:
  ///   The updated todo list with the new item
  ///
  /// Throws:
  ///   Exception if the todo list does not exist
  ///
  /// Example:
  /// ```dart
  /// final item = TodoItem(
  ///   id: 'item-1',
  ///   title: 'New task',
  ///   sortOrder: 0,
  /// );
  /// final updated = await repository.addItem('todo-1', item);
  /// ```
  Future<TodoList> addItem(String listId, TodoItem item) async {
    try {
      final todoList = await getById(listId);
      if (todoList == null) {
        throw Exception('TodoList with id $listId does not exist');
      }

      final updatedItems = [...todoList.items, item];
      final updatedTodoList = todoList.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      await _box.put(listId, updatedTodoList);
      return updatedTodoList;
    } catch (e) {
      throw Exception('Failed to add item to todo list: $e');
    }
  }

  /// Updates a specific todo item within a todo list.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the todo list containing the item
  ///   - [itemId]: The ID of the todo item to update
  ///   - [updatedItem]: The updated todo item
  ///
  /// Returns:
  ///   The updated todo list
  ///
  /// Throws:
  ///   Exception if the todo list or item does not exist
  ///
  /// Example:
  /// ```dart
  /// final updated = await repository.updateItem(
  ///   'todo-1',
  ///   'item-1',
  ///   item.copyWith(title: 'Updated title'),
  /// );
  /// ```
  Future<TodoList> updateItem(
    String listId,
    String itemId,
    TodoItem updatedItem,
  ) async {
    try {
      final todoList = await getById(listId);
      if (todoList == null) {
        throw Exception('TodoList with id $listId does not exist');
      }

      final itemIndex = todoList.items.indexWhere((item) => item.id == itemId);
      if (itemIndex == -1) {
        throw Exception(
          'TodoItem with id $itemId does not exist in list $listId',
        );
      }

      final updatedItems = [...todoList.items];
      updatedItems[itemIndex] = updatedItem;

      final updatedTodoList = todoList.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      await _box.put(listId, updatedTodoList);
      return updatedTodoList;
    } catch (e) {
      throw Exception('Failed to update item in todo list: $e');
    }
  }

  /// Deletes a specific todo item from a todo list.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the todo list containing the item
  ///   - [itemId]: The ID of the todo item to delete
  ///
  /// Returns:
  ///   The updated todo list without the deleted item
  ///
  /// Throws:
  ///   Exception if the todo list does not exist
  ///
  /// Example:
  /// ```dart
  /// final updated = await repository.deleteItem('todo-1', 'item-1');
  /// ```
  Future<TodoList> deleteItem(String listId, String itemId) async {
    try {
      final todoList = await getById(listId);
      if (todoList == null) {
        throw Exception('TodoList with id $listId does not exist');
      }

      final updatedItems = todoList.items
          .where((item) => item.id != itemId)
          .toList();

      final updatedTodoList = todoList.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      await _box.put(listId, updatedTodoList);
      return updatedTodoList;
    } catch (e) {
      throw Exception('Failed to delete item from todo list: $e');
    }
  }

  /// Toggles the completion status of a specific todo item.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the todo list containing the item
  ///   - [itemId]: The ID of the todo item to toggle
  ///
  /// Returns:
  ///   The updated todo list with the toggled item
  ///
  /// Throws:
  ///   Exception if the todo list or item does not exist
  ///
  /// Example:
  /// ```dart
  /// final updated = await repository.toggleItem('todo-1', 'item-1');
  /// ```
  Future<TodoList> toggleItem(String listId, String itemId) async {
    try {
      final todoList = await getById(listId);
      if (todoList == null) {
        throw Exception('TodoList with id $listId does not exist');
      }

      final itemIndex = todoList.items.indexWhere((item) => item.id == itemId);
      if (itemIndex == -1) {
        throw Exception(
          'TodoItem with id $itemId does not exist in list $listId',
        );
      }

      final updatedItems = [...todoList.items];
      updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(
        isCompleted: !updatedItems[itemIndex].isCompleted,
      );

      final updatedTodoList = todoList.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      await _box.put(listId, updatedTodoList);
      return updatedTodoList;
    } catch (e) {
      throw Exception('Failed to toggle item in todo list: $e');
    }
  }

  /// Reorders todo items within a todo list.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the todo list
  ///   - [oldIndex]: The current index of the item
  ///   - [newIndex]: The target index for the item
  ///
  /// Returns:
  ///   The updated todo list with reordered items
  ///
  /// Throws:
  ///   Exception if the todo list does not exist or indices are invalid
  ///
  /// Example:
  /// ```dart
  /// final updated = await repository.reorderItems('todo-1', 0, 2);
  /// ```
  Future<TodoList> reorderItems(
    String listId,
    int oldIndex,
    int newIndex,
  ) async {
    try {
      final todoList = await getById(listId);
      if (todoList == null) {
        throw Exception('TodoList with id $listId does not exist');
      }

      if (oldIndex < 0 ||
          oldIndex >= todoList.items.length ||
          newIndex < 0 ||
          newIndex >= todoList.items.length) {
        throw Exception(
          'Invalid reorder indices: oldIndex=$oldIndex, newIndex=$newIndex',
        );
      }

      final updatedItems = [...todoList.items];
      final item = updatedItems.removeAt(oldIndex);
      updatedItems.insert(newIndex, item);

      // Update sort order for all items
      final reorderedItems = updatedItems.asMap().entries.map((entry) {
        return entry.value.copyWith(sortOrder: entry.key);
      }).toList();

      final updatedTodoList = todoList.copyWith(
        items: reorderedItems,
        updatedAt: DateTime.now(),
      );

      await _box.put(listId, updatedTodoList);
      return updatedTodoList;
    } catch (e) {
      throw Exception('Failed to reorder items in todo list: $e');
    }
  }

  /// Deletes all todo lists belonging to a specific space.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space
  ///
  /// Returns:
  ///   The number of todo lists deleted
  ///
  /// Example:
  /// ```dart
  /// final count = await repository.deleteAllInSpace('space-1');
  /// print('Deleted $count todo lists');
  /// ```
  Future<int> deleteAllInSpace(String spaceId) async {
    try {
      final todoLists = await getBySpace(spaceId);
      for (final todoList in todoLists) {
        await delete(todoList.id);
      }
      return todoLists.length;
    } catch (e) {
      throw Exception('Failed to delete all todo lists in space: $e');
    }
  }

  /// Counts the number of todo lists in a specific space.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space
  ///
  /// Returns:
  ///   The number of todo lists in the space
  ///
  /// Example:
  /// ```dart
  /// final count = await repository.countBySpace('space-1');
  /// print('Space has $count todo lists');
  /// ```
  Future<int> countBySpace(String spaceId) async {
    try {
      final todoLists = await getBySpace(spaceId);
      return todoLists.length;
    } catch (e) {
      throw Exception('Failed to count todo lists in space: $e');
    }
  }
}
