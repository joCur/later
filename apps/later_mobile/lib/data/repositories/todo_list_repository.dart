import '../models/todo_item_model.dart';
import '../models/todo_list_model.dart';
import 'base_repository.dart';

/// Repository for managing TodoList and TodoItem entities in Supabase.
///
/// Provides CRUD operations for todo lists and their items.
/// Uses Supabase 'todo_lists' and 'todo_items' tables with RLS policies.
/// TodoItems are stored separately and fetched on demand for efficiency.
class TodoListRepository extends BaseRepository {
  // ==================== TodoList Operations ====================

  /// Creates a new todo list in Supabase.
  ///
  /// Automatically calculates and assigns the next sortOrder value for the todo list
  /// within its space. Automatically sets the user_id from the authenticated user.
  /// Initializes count fields to 0.
  ///
  /// Parameters:
  ///   - [todoList]: The todo list to be created
  ///
  /// Returns:
  ///   The created todo list with assigned sortOrder and initial counts
  ///
  /// Throws:
  ///   Exception if user is not authenticated or database operation fails
  Future<TodoList> create(TodoList todoList) async {
    return executeQuery(() async {
      // Calculate next sortOrder for this space
      final todoListsInSpace = await getBySpace(todoList.spaceId);
      final maxSortOrder = todoListsInSpace.isEmpty
          ? -1
          : todoListsInSpace
              .map((t) => t.sortOrder)
              .reduce((a, b) => a > b ? a : b);
      final nextSortOrder = maxSortOrder + 1;

      // Create todo list with calculated sortOrder and initial counts
      final todoListWithSortOrder = todoList.copyWith(
        sortOrder: nextSortOrder,
        totalItemCount: 0,
        completedItemCount: 0,
      );
      final data = todoListWithSortOrder.toJson();
      data['user_id'] = userId; // Ensure correct user_id

      final response = await supabase
          .from('todo_lists')
          .insert(data)
          .select()
          .single();

      return TodoList.fromJson(response);
    });
  }

  /// Retrieves a single todo list by its ID with aggregate counts.
  ///
  /// Returns null if the todo list does not exist or user doesn't have access.
  /// RLS policies ensure users can only access their own todo lists.
  /// Note: This does NOT fetch the todo items - use getTodoItemsByListId() for that.
  ///
  /// Parameters:
  ///   - [id]: The ID of the todo list to retrieve
  ///
  /// Returns:
  ///   The todo list with the given ID (with aggregate counts), or null if not found
  Future<TodoList?> getById(String id) async {
    return executeQuery(() async {
      // Fetch todo list with aggregate counts using a raw SQL query via RPC
      // or by fetching items separately and calculating counts
      final todoListResponse = await supabase
          .from('todo_lists')
          .select()
          .eq('id', id)
          .eq('user_id', userId)
          .maybeSingle();

      if (todoListResponse == null) return null;

      // Fetch items to calculate counts
      final items = await getTodoItemsByListId(id);
      final totalCount = items.length;
      final completedCount = items.where((item) => item.isCompleted).length;

      final todoList = TodoList.fromJson(todoListResponse);
      return todoList.copyWith(
        totalItemCount: totalCount,
        completedItemCount: completedCount,
      );
    });
  }

  /// Retrieves all todo lists belonging to a specific space with aggregate counts.
  ///
  /// RLS policies ensure users can only access their own todo lists.
  /// Orders by sort_order ascending.
  /// Note: This does NOT fetch the todo items - use getTodoItemsByListId() for that.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to filter by
  ///
  /// Returns:
  ///   A list of todo lists belonging to the specified space
  Future<List<TodoList>> getBySpace(String spaceId) async {
    return executeQuery(() async {
      final response = await supabase
          .from('todo_lists')
          .select()
          .eq('space_id', spaceId)
          .eq('user_id', userId)
          .order('sort_order', ascending: true);

      final todoLists = (response as List)
          .map((json) => TodoList.fromJson(json as Map<String, dynamic>))
          .toList();

      // Fetch counts for each todo list
      final todoListsWithCounts = await Future.wait(
        todoLists.map((todoList) async {
          final items = await getTodoItemsByListId(todoList.id);
          final totalCount = items.length;
          final completedCount =
              items.where((item) => item.isCompleted).length;

          return todoList.copyWith(
            totalItemCount: totalCount,
            completedItemCount: completedCount,
          );
        }),
      );

      return todoListsWithCounts;
    });
  }

  /// Updates an existing todo list in Supabase.
  ///
  /// Automatically updates the updated_at timestamp to the current time.
  /// RLS policies ensure users can only update their own todo lists.
  /// Note: This updates the todo list metadata only. To update items, use TodoItem methods.
  ///
  /// Parameters:
  ///   - [todoList]: The todo list to update with new values
  ///
  /// Returns:
  ///   The updated todo list with the new updated_at timestamp
  Future<TodoList> update(TodoList todoList) async {
    return executeQuery(() async {
      // Update the updatedAt timestamp
      final updatedTodoList = todoList.copyWith(updatedAt: DateTime.now());
      final data = updatedTodoList.toJson();

      final response = await supabase
          .from('todo_lists')
          .update(data)
          .eq('id', todoList.id)
          .eq('user_id', userId)
          .select()
          .single();

      return TodoList.fromJson(response);
    });
  }

  /// Deletes a todo list from Supabase.
  ///
  /// RLS policies ensure users can only delete their own todo lists.
  /// Associated todo items will be cascade deleted via foreign key constraints.
  ///
  /// Parameters:
  ///   - [id]: The ID of the todo list to delete
  Future<void> delete(String id) async {
    return executeQuery(() async {
      await supabase
          .from('todo_lists')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    });
  }

  // ==================== TodoItem Operations ====================

  /// Retrieves all todo items belonging to a specific todo list.
  ///
  /// RLS policies ensure users can only access items from their own todo lists.
  /// Orders by sort_order ascending.
  ///
  /// Parameters:
  ///   - [todoListId]: The ID of the todo list
  ///
  /// Returns:
  ///   A list of todo items belonging to the specified todo list
  Future<List<TodoItem>> getTodoItemsByListId(String todoListId) async {
    return executeQuery(() async {
      final response = await supabase
          .from('todo_items')
          .select()
          .eq('todo_list_id', todoListId)
          .order('sort_order', ascending: true);

      return (response as List)
          .map((json) => TodoItem.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  /// Creates a new todo item in Supabase.
  ///
  /// Automatically calculates and assigns the next sortOrder value for the item
  /// within its todo list. After creating the item, updates the parent todo list's
  /// aggregate counts.
  ///
  /// Parameters:
  ///   - [todoItem]: The todo item to be created
  ///
  /// Returns:
  ///   The created todo item with assigned sortOrder
  Future<TodoItem> createTodoItem(TodoItem todoItem) async {
    return executeQuery(() async {
      // Calculate next sortOrder for this todo list
      final itemsInList = await getTodoItemsByListId(todoItem.todoListId);
      final maxSortOrder = itemsInList.isEmpty
          ? -1
          : itemsInList
              .map((item) => item.sortOrder)
              .reduce((a, b) => a > b ? a : b);
      final nextSortOrder = maxSortOrder + 1;

      // Create item with calculated sortOrder
      final todoItemWithSortOrder = todoItem.copyWith(sortOrder: nextSortOrder);
      final data = todoItemWithSortOrder.toJson();

      final response = await supabase
          .from('todo_items')
          .insert(data)
          .select()
          .single();

      // Update parent todo list counts
      await _updateTodoListCounts(todoItem.todoListId);

      return TodoItem.fromJson(response);
    });
  }

  /// Updates an existing todo item in Supabase.
  ///
  /// If the completion status changes, updates the parent todo list's counts.
  /// RLS policies ensure users can only update items from their own todo lists.
  ///
  /// Parameters:
  ///   - [todoItem]: The todo item to update with new values
  ///
  /// Returns:
  ///   The updated todo item
  Future<TodoItem> updateTodoItem(TodoItem todoItem) async {
    return executeQuery(() async {
      // Get the old item to check if completion status changed
      final oldItemResponse = await supabase
          .from('todo_items')
          .select()
          .eq('id', todoItem.id)
          .single();
      final oldItem = TodoItem.fromJson(oldItemResponse);

      final data = todoItem.toJson();

      final response = await supabase
          .from('todo_items')
          .update(data)
          .eq('id', todoItem.id)
          .select()
          .single();

      // Update parent todo list counts if completion status changed
      if (oldItem.isCompleted != todoItem.isCompleted) {
        await _updateTodoListCounts(todoItem.todoListId);
      }

      return TodoItem.fromJson(response);
    });
  }

  /// Deletes a todo item from Supabase.
  ///
  /// After deleting the item, updates the parent todo list's aggregate counts.
  /// RLS policies ensure users can only delete items from their own todo lists.
  ///
  /// Parameters:
  ///   - [id]: The ID of the todo item to delete
  ///   - [todoListId]: The ID of the parent todo list (for count updates)
  Future<void> deleteTodoItem(String id, String todoListId) async {
    return executeQuery(() async {
      await supabase.from('todo_items').delete().eq('id', id);

      // Update parent todo list counts
      await _updateTodoListCounts(todoListId);
    });
  }

  /// Updates the sort orders for multiple todo items in a batch.
  ///
  /// Used for drag-and-drop reordering. Updates all items with their new
  /// sort_order values in a single operation.
  ///
  /// Parameters:
  ///   - [todoItems]: List of todo items with updated sortOrder values
  Future<void> updateTodoItemSortOrders(List<TodoItem> todoItems) async {
    return executeQuery(() async {
      final updates = todoItems.map((item) => item.toJson()).toList();

      // Use upsert to update multiple records at once
      await supabase.from('todo_items').upsert(updates);
    });
  }

  /// Private helper to update a todo list's aggregate counts.
  ///
  /// Fetches all items for the list and recalculates totalItemCount and completedItemCount.
  Future<void> _updateTodoListCounts(String todoListId) async {
    final items = await getTodoItemsByListId(todoListId);
    final totalCount = items.length;
    final completedCount = items.where((item) => item.isCompleted).length;

    await supabase
        .from('todo_lists')
        .update({
          'total_item_count': totalCount,
          'completed_item_count': completedCount,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', todoListId)
        .eq('user_id', userId);
  }
}
