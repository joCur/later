import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../application/providers.dart';
import '../../domain/models/list_model.dart';

part 'lists_controller.g.dart';

/// Controller for managing lists within a space
///
/// This controller uses family pattern to scope state by spaceId.
/// It manages an AsyncValue with list of ListModel and provides methods for CRUD operations.
///
/// Usage:
/// ```dart
/// // Watch the controller
/// final listsAsync = ref.watch(listsControllerProvider(spaceId));
///
/// // Call methods
/// ref.read(listsControllerProvider(spaceId).notifier).createList(list);
/// ```
@riverpod
class ListsController extends _$ListsController {
  @override
  Future<List<ListModel>> build(String spaceId) async {
    // Load lists for this space on initialization
    final service = ref.read(listServiceProvider);
    return service.getListsForSpace(spaceId);
  }

  /// Creates a new list in the current space
  Future<void> createList(ListModel list) async {
    final service = ref.read(listServiceProvider);

    try {
      final created = await service.createList(list);

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

  /// Updates an existing list
  Future<void> updateList(ListModel list) async {
    final service = ref.read(listServiceProvider);

    try {
      final updated = await service.updateList(list);

      // Check if still mounted
      if (!ref.mounted) return;

      // Replace in current state
      state = state.whenData((lists) {
        final index = lists.indexWhere((l) => l.id == updated.id);
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

  /// Deletes a list
  Future<void> deleteList(String id) async {
    final service = ref.read(listServiceProvider);

    try {
      await service.deleteList(id);

      // Check if still mounted
      if (!ref.mounted) return;

      // Remove from current state
      state = state.whenData((lists) => lists.where((l) => l.id != id).toList());
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Reorders lists within the space
  ///
  /// Parameters:
  ///   - orderedIds: List of list IDs in the new order
  Future<void> reorderLists(List<String> orderedIds) async {
    final service = ref.read(listServiceProvider);
    final spaceId = this.spaceId; // Access family parameter

    try {
      await service.reorderLists(spaceId, orderedIds);

      // Check if still mounted
      if (!ref.mounted) return;

      // Refresh state from repository to get updated sortOrder values
      final updated = await service.getListsForSpace(spaceId);

      if (ref.mounted) {
        state = AsyncValue.data(updated);
      }
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Refreshes the list state from the repository
  ///
  /// Useful after operations that might change list counts or other data
  Future<void> refresh() async {
    final service = ref.read(listServiceProvider);
    final spaceId = this.spaceId;

    try {
      final updated = await service.getListsForSpace(spaceId);

      if (ref.mounted) {
        state = AsyncValue.data(updated);
      }
    } catch (e) {
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }
}
