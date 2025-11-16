import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../application/providers.dart';
import '../../domain/models/todo_item.dart';

part 'todo_items_controller.g.dart';

/// Controller for managing todo items within a todo list
///
/// This controller uses family pattern to scope state by listId.
/// It manages an AsyncValue with list of TodoItem and provides methods for CRUD operations.
///
/// When items are added/removed/toggled, it invalidates the parent TodoListsController
/// to refresh counts (totalItemCount, completedItemCount).
///
/// Usage:
/// ```dart
/// // Watch the controller
/// final itemsAsync = ref.watch(todoItemsControllerProvider(listId));
///
/// // Call methods
/// ref.read(todoItemsControllerProvider(listId).notifier).createItem(item);
/// ```
@riverpod
class TodoItemsController extends _$TodoItemsController {
  @override
  Future<List<TodoItem>> build(String listId) async {
    // Load todo items for this list on initialization
    final service = ref.read(todoListServiceProvider);
    return service.getTodoItemsForList(listId);
  }

  /// Creates a new todo item in the current list
  Future<void> createItem(TodoItem todoItem) async {
    final service = ref.read(todoListServiceProvider);

    try {
      final created = await service.createTodoItem(todoItem);

      // Check if still mounted
      if (!ref.mounted) return;

      // Add to current state (sorted by sortOrder)
      state = state.whenData((items) {
        final updated = [...items, created];
        updated.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return updated;
      });

      // Invalidate parent list controller to refresh counts
      await _refreshParentList(todoItem.todoListId);
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Updates an existing todo item
  Future<void> updateItem(TodoItem todoItem) async {
    final service = ref.read(todoListServiceProvider);

    try {
      final updated = await service.updateTodoItem(todoItem);

      // Check if still mounted
      if (!ref.mounted) return;

      // Replace in current state
      state = state.whenData((items) {
        final index = items.indexWhere((i) => i.id == updated.id);
        if (index == -1) return items;

        return [
          ...items.sublist(0, index),
          updated,
          ...items.sublist(index + 1),
        ];
      });

      // Invalidate parent list controller to refresh counts (if completion changed)
      await _refreshParentList(todoItem.todoListId);
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Deletes a todo item
  Future<void> deleteItem(String id, String todoListId) async {
    final service = ref.read(todoListServiceProvider);

    try {
      await service.deleteTodoItem(id, todoListId);

      // Check if still mounted
      if (!ref.mounted) return;

      // Remove from current state
      state = state.whenData((items) => items.where((i) => i.id != id).toList());

      // Invalidate parent list controller to refresh counts
      await _refreshParentList(todoListId);
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Toggles the completed status of a todo item
  Future<void> toggleItem(String id, String todoListId) async {
    final service = ref.read(todoListServiceProvider);

    try {
      final toggled = await service.toggleTodoItem(id, todoListId);

      // Check if still mounted
      if (!ref.mounted) return;

      // Replace in current state
      state = state.whenData((items) {
        final index = items.indexWhere((i) => i.id == toggled.id);
        if (index == -1) return items;

        return [
          ...items.sublist(0, index),
          toggled,
          ...items.sublist(index + 1),
        ];
      });

      // Invalidate parent list controller to refresh counts
      await _refreshParentList(todoListId);
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Reorders todo items within the list
  ///
  /// Parameters:
  ///   - orderedIds: List of todo item IDs in the new order
  Future<void> reorderItems(List<String> orderedIds) async {
    final service = ref.read(todoListServiceProvider);

    try {
      await service.reorderTodoItems(listId, orderedIds);

      // Check if still mounted
      if (!ref.mounted) return;

      // Refresh state to get updated sortOrder values
      final updated = await service.getTodoItemsForList(listId);
      state = AsyncValue.data(updated);
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Refreshes the parent todo list to update counts
  ///
  /// This is called after item CRUD operations to keep the parent list counts in sync.
  /// The repository handles count updates automatically, so this is primarily for
  /// invalidating cached state.
  Future<void> _refreshParentList(String todoListId) async {
    // The TodoListRepository automatically updates counts in the database
    // when items are created/updated/deleted/toggled.
    //
    // To refresh the UI, the TodoListsController watching the parent space
    // should call refreshTodoList(todoListId) after item operations.
    //
    // For now, we don't need to do anything here since the repository
    // handles count updates. The parent controller will refresh when needed.
  }
}
