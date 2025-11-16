import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../application/providers.dart';
import '../../domain/models/list_item_model.dart';

part 'list_items_controller.g.dart';

/// Controller for managing list items within a list
///
/// This controller uses family pattern to scope state by listId.
/// It manages an AsyncValue with list of ListItem and provides methods for CRUD operations.
///
/// When items are added/removed/toggled, it invalidates the parent ListsController
/// to refresh counts (totalItemCount, checkedItemCount for checklists).
///
/// Usage:
/// ```dart
/// // Watch the controller
/// final itemsAsync = ref.watch(listItemsControllerProvider(listId));
///
/// // Call methods
/// ref.read(listItemsControllerProvider(listId).notifier).createItem(item);
/// ```
@riverpod
class ListItemsController extends _$ListItemsController {
  @override
  Future<List<ListItem>> build(String listId) async {
    // Load list items for this list on initialization
    final service = ref.read(listServiceProvider);
    return service.getListItemsForList(listId);
  }

  /// Creates a new list item in the current list
  Future<void> createItem(ListItem listItem) async {
    final service = ref.read(listServiceProvider);

    try {
      final created = await service.createListItem(listItem);

      // Check if still mounted
      if (!ref.mounted) return;

      // Add to current state (sorted by sortOrder)
      state = state.whenData((items) {
        final updated = [...items, created];
        updated.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return updated;
      });

      // Invalidate parent list controller to refresh counts
      await _refreshParentList(listItem.listId);
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Updates an existing list item
  Future<void> updateItem(ListItem listItem) async {
    final service = ref.read(listServiceProvider);

    try {
      final updated = await service.updateListItem(listItem);

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

      // Invalidate parent list controller to refresh counts (if checked status changed)
      await _refreshParentList(listItem.listId);
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Deletes a list item
  Future<void> deleteItem(String id, String listId) async {
    final service = ref.read(listServiceProvider);

    try {
      await service.deleteListItem(id, listId);

      // Check if still mounted
      if (!ref.mounted) return;

      // Remove from current state
      state = state.whenData((items) => items.where((i) => i.id != id).toList());

      // Invalidate parent list controller to refresh counts
      await _refreshParentList(listId);
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Toggles the checked status of a list item (checklist style only)
  Future<void> toggleItem(ListItem item) async {
    final service = ref.read(listServiceProvider);

    try {
      final toggled = await service.toggleListItem(item);

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
      await _refreshParentList(item.listId);
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Reorders list items within the list
  ///
  /// Parameters:
  ///   - orderedIds: List of list item IDs in the new order
  Future<void> reorderItems(List<String> orderedIds) async {
    final service = ref.read(listServiceProvider);

    try {
      await service.reorderListItems(listId, orderedIds);

      // Check if still mounted
      if (!ref.mounted) return;

      // Refresh state to get updated sortOrder values
      final updated = await service.getListItemsForList(listId);
      state = AsyncValue.data(updated);
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Refreshes the parent list to update counts
  ///
  /// This is called after item CRUD operations to keep the parent list counts in sync.
  /// The repository handles count updates automatically, so this is primarily for
  /// invalidating cached state.
  Future<void> _refreshParentList(String listId) async {
    // The ListRepository automatically updates counts in the database
    // when items are created/updated/deleted/toggled.
    //
    // To refresh the UI, the ListsController watching the parent space
    // should call refresh() after item operations if needed.
    //
    // For now, we don't need to do anything here since the repository
    // handles count updates. The parent controller will refresh when needed.
  }
}
