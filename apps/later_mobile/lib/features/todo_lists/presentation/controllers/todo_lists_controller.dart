import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/permissions/permissions.dart';
import '../../application/providers.dart';
import '../../domain/models/todo_list.dart';

part 'todo_lists_controller.g.dart';

/// Controller for managing todo lists within a space
///
/// This controller uses family pattern to scope state by spaceId.
/// It manages an AsyncValue with list of TodoList and provides methods for CRUD operations.
///
/// Usage:
/// ```dart
/// // Watch the controller
/// final todoListsAsync = ref.watch(todoListsControllerProvider(spaceId));
///
/// // Call methods
/// ref.read(todoListsControllerProvider(spaceId).notifier).createTodoList(todoList);
/// ```
@riverpod
class TodoListsController extends _$TodoListsController {
  @override
  Future<List<TodoList>> build(String spaceId) async {
    // Load todo lists for this space on initialization
    final service = ref.read(todoListServiceProvider);
    return service.getTodoListsForSpace(spaceId);
  }

  /// Creates a new todo list in the current space
  ///
  /// For anonymous users, checks if they have reached their todo list limit (10 per space).
  /// If the limit is reached, throws a [TodoListLimitReachedException] which should
  /// be handled by the caller to show an upgrade prompt.
  ///
  /// Throws:
  ///   - [TodoListLimitReachedException] if anonymous user has reached their limit
  Future<void> createTodoList(TodoList todoList) async {
    // Check permission limit for anonymous users
    final role = ref.read(currentUserRoleProvider);
    if (role == UserRole.anonymous) {
      // Get current todo list count from state
      final currentTodoListCount = state.whenData((lists) => lists.length).value ?? 0;
      if (currentTodoListCount >= UserRolePermissions(role).maxTodoListsPerSpaceForAnonymous) {
        // Throw a custom exception that the caller should handle
        throw TodoListLimitReachedException();
      }
    }

    final service = ref.read(todoListServiceProvider);

    try {
      final created = await service.createTodoList(todoList);

      // Check if still mounted
      if (!ref.mounted) return;

      // Add to current state (sorted by sortOrder)
      state = state.whenData((lists) {
        final updated = [...lists, created];
        updated.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return updated;
      });
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Updates an existing todo list
  Future<void> updateTodoList(TodoList todoList) async {
    final service = ref.read(todoListServiceProvider);

    try {
      final updated = await service.updateTodoList(todoList);

      // Check if still mounted
      if (!ref.mounted) return;

      // Replace in current state
      state = state.whenData((lists) {
        final index = lists.indexWhere((t) => t.id == updated.id);
        if (index == -1) return lists;

        return [
          ...lists.sublist(0, index),
          updated,
          ...lists.sublist(index + 1),
        ];
      });
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Deletes a todo list
  Future<void> deleteTodoList(String id) async {
    final service = ref.read(todoListServiceProvider);

    try {
      await service.deleteTodoList(id);

      // Check if still mounted
      if (!ref.mounted) return;

      // Remove from current state
      state = state.whenData((lists) => lists.where((t) => t.id != id).toList());
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Reorders todo lists within the space
  ///
  /// Parameters:
  ///   - orderedIds: List of todo list IDs in the new order
  Future<void> reorderLists(List<String> orderedIds) async {
    final service = ref.read(todoListServiceProvider);

    try {
      await service.reorderTodoLists(spaceId, orderedIds);

      // Check if still mounted
      if (!ref.mounted) return;

      // Refresh state to get updated sortOrder values
      final updated = await service.getTodoListsForSpace(spaceId);
      state = AsyncValue.data(updated);
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Refreshes a specific todo list to get updated counts
  ///
  /// This is useful after items are added/removed/toggled to refresh the parent list.
  /// Called by TodoItemsController when item counts change.
  Future<void> refreshTodoList(String todoListId) async {
    final service = ref.read(todoListServiceProvider);

    try {
      // Reload all lists - this refreshes counts from the database
      final updated = await service.getTodoListsForSpace(spaceId);

      // Check if still mounted
      if (!ref.mounted) return;

      state = AsyncValue.data(updated);
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }
}

/// Exception thrown when an anonymous user reaches their todo list creation limit.
///
/// This exception should be caught by the UI layer to show an upgrade prompt dialog.
class TodoListLimitReachedException implements Exception {
  @override
  String toString() => 'Anonymous users are limited to 10 todo lists per space';
}
