import 'package:later_mobile/core/error/error.dart';
import '../../data/repositories/todo_list_repository.dart';
import '../../domain/models/todo_item.dart';
import '../../domain/models/todo_list.dart';

/// Application service for TodoList business logic
///
/// This service layer sits between the presentation layer (controllers) and
/// the data layer (repositories). It handles validation, business rules, and
/// orchestrates complex operations.
///
/// Business rules:
/// - TodoList name cannot be empty
/// - TodoItem title cannot be empty
/// - Sort order management for lists and items
/// - Aggregate count calculation (handled by repository)
class TodoListService {
  TodoListService({required TodoListRepository repository})
      : _repository = repository;

  final TodoListRepository _repository;

  // ==================== TodoList Operations ====================

  /// Loads all todo lists for a space, sorted by sortOrder ascending.
  ///
  /// Returns:
  ///   List of todo lists with aggregate counts (totalItemCount, completedItemCount)
  Future<List<TodoList>> getTodoListsForSpace(String spaceId) async {
    final todoLists = await _repository.getBySpace(spaceId);
    // Repository already returns lists sorted by sortOrder
    return todoLists;
  }

  /// Creates a new todo list with validation.
  ///
  /// Validation rules:
  /// - Name must not be empty
  ///
  /// Returns:
  ///   The created todo list with initial counts (0, 0)
  Future<TodoList> createTodoList(TodoList todoList) async {
    // Validate name
    if (todoList.name.trim().isEmpty) {
      throw ValidationErrorMapper.requiredField('TodoList name');
    }

    // Repository handles sortOrder calculation
    return await _repository.create(todoList);
  }

  /// Updates an existing todo list with validation.
  ///
  /// Validation rules:
  /// - Name must not be empty
  Future<TodoList> updateTodoList(TodoList todoList) async {
    // Validate name
    if (todoList.name.trim().isEmpty) {
      throw ValidationErrorMapper.requiredField('TodoList name');
    }

    return await _repository.update(todoList);
  }

  /// Deletes a todo list and all its items.
  ///
  /// The repository handles cascade deletion of items via foreign key constraints.
  Future<void> deleteTodoList(String id) async {
    await _repository.delete(id);
  }

  /// Reorders todo lists within a space.
  ///
  /// Parameters:
  ///   - spaceId: The space ID
  ///   - orderedIds: List of todo list IDs in the new order
  ///
  /// This updates the sortOrder field for all affected lists.
  Future<void> reorderTodoLists(
    String spaceId,
    List<String> orderedIds,
  ) async {
    // Load current todo lists
    final todoLists = await _repository.getBySpace(spaceId);

    // Create updated todo lists with new sortOrder values
    final updatedLists = <TodoList>[];
    for (int i = 0; i < orderedIds.length; i++) {
      final id = orderedIds[i];
      final todoList = todoLists.firstWhere((t) => t.id == id);
      updatedLists.add(todoList.copyWith(sortOrder: i));
    }

    // Update each todo list with new sortOrder
    for (final todoList in updatedLists) {
      await _repository.update(todoList);
    }
  }

  // ==================== TodoItem Operations ====================

  /// Loads all todo items for a list, sorted by sortOrder ascending.
  Future<List<TodoItem>> getTodoItemsForList(String listId) async {
    final items = await _repository.getTodoItemsByListId(listId);
    // Repository already returns items sorted by sortOrder
    return items;
  }

  /// Creates a new todo item with validation.
  ///
  /// Validation rules:
  /// - Title must not be empty
  ///
  /// The repository handles sortOrder calculation and parent list count updates.
  Future<TodoItem> createTodoItem(TodoItem todoItem) async {
    // Validate title
    if (todoItem.title.trim().isEmpty) {
      throw ValidationErrorMapper.requiredField('TodoItem title');
    }

    return await _repository.createTodoItem(todoItem);
  }

  /// Updates an existing todo item with validation.
  ///
  /// Validation rules:
  /// - Title must not be empty
  ///
  /// The repository handles parent list count updates if completion status changed.
  Future<TodoItem> updateTodoItem(TodoItem todoItem) async {
    // Validate title
    if (todoItem.title.trim().isEmpty) {
      throw ValidationErrorMapper.requiredField('TodoItem title');
    }

    return await _repository.updateTodoItem(todoItem);
  }

  /// Deletes a todo item.
  ///
  /// The repository handles parent list count updates.
  Future<void> deleteTodoItem(String id, String todoListId) async {
    await _repository.deleteTodoItem(id, todoListId);
  }

  /// Toggles the completed status of a todo item.
  ///
  /// This is a convenience method that loads the item, toggles isCompleted,
  /// and updates it. The repository handles parent list count updates.
  Future<TodoItem> toggleTodoItem(String id, String todoListId) async {
    // Load current items to find the item
    final items = await _repository.getTodoItemsByListId(todoListId);
    final item = items.firstWhere((i) => i.id == id);

    // Toggle completion status
    final updated = item.copyWith(isCompleted: !item.isCompleted);

    // Update via repository
    return await _repository.updateTodoItem(updated);
  }

  /// Reorders todo items within a list.
  ///
  /// Parameters:
  ///   - listId: The todo list ID
  ///   - orderedIds: List of todo item IDs in the new order
  ///
  /// This updates the sortOrder field for all affected items.
  Future<void> reorderTodoItems(
    String listId,
    List<String> orderedIds,
  ) async {
    // Load current items
    final items = await _repository.getTodoItemsByListId(listId);

    // Create updated items with new sortOrder values
    final updatedItems = <TodoItem>[];
    for (int i = 0; i < orderedIds.length; i++) {
      final id = orderedIds[i];
      final item = items.firstWhere((t) => t.id == id);
      updatedItems.add(item.copyWith(sortOrder: i));
    }

    // Use repository's batch update method
    await _repository.updateTodoItemSortOrders(updatedItems);
  }
}
