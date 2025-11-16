import 'package:later_mobile/core/error/error.dart';
import '../../data/repositories/list_repository.dart';
import '../../domain/models/list_item_model.dart';
import '../../domain/models/list_model.dart';

/// Application service for ListModel business logic
///
/// This service layer sits between the presentation layer (controllers) and
/// the data layer (repositories). It handles validation, business rules, and
/// orchestrates complex operations.
///
/// Business rules:
/// - List name cannot be empty
/// - ListItem title cannot be empty
/// - Sort order management for lists and items
/// - Aggregate count calculation for checklist style (handled by repository)
class ListService {
  ListService({required ListRepository repository}) : _repository = repository;

  final ListRepository _repository;

  // ==================== List Operations ====================

  /// Loads all lists for a space, sorted by sortOrder ascending.
  ///
  /// Returns:
  ///   List of lists with aggregate counts (totalItemCount, checkedItemCount for checklists)
  Future<List<ListModel>> getListsForSpace(String spaceId) async {
    final lists = await _repository.getBySpace(spaceId);
    // Repository already returns lists sorted by sortOrder
    return lists;
  }

  /// Creates a new list with validation.
  ///
  /// Validation rules:
  /// - Name must not be empty
  ///
  /// Returns:
  ///   The created list with initial counts (0, 0)
  Future<ListModel> createList(ListModel list) async {
    // Validate name
    if (list.name.trim().isEmpty) {
      throw ValidationErrorMapper.requiredField('List name');
    }

    // Repository handles sortOrder calculation
    return await _repository.create(list);
  }

  /// Updates an existing list with validation.
  ///
  /// Validation rules:
  /// - Name must not be empty
  Future<ListModel> updateList(ListModel list) async {
    // Validate name
    if (list.name.trim().isEmpty) {
      throw ValidationErrorMapper.requiredField('List name');
    }

    return await _repository.update(list);
  }

  /// Deletes a list and all its items.
  ///
  /// The repository handles cascade deletion of items via foreign key constraints.
  Future<void> deleteList(String id) async {
    await _repository.delete(id);
  }

  /// Reorders lists within a space.
  ///
  /// Parameters:
  ///   - spaceId: The space ID
  ///   - orderedIds: List of list IDs in the new order
  ///
  /// This updates the sortOrder field for all affected lists.
  Future<void> reorderLists(
    String spaceId,
    List<String> orderedIds,
  ) async {
    // Load current lists
    final lists = await _repository.getBySpace(spaceId);

    // Create updated lists with new sortOrder values
    final updatedLists = <ListModel>[];
    for (int i = 0; i < orderedIds.length; i++) {
      final id = orderedIds[i];
      final list = lists.firstWhere((l) => l.id == id);
      updatedLists.add(list.copyWith(sortOrder: i));
    }

    // Update each list with new sortOrder
    for (final list in updatedLists) {
      await _repository.update(list);
    }
  }

  // ==================== ListItem Operations ====================

  /// Loads all list items for a list, sorted by sortOrder ascending.
  Future<List<ListItem>> getListItemsForList(String listId) async {
    final items = await _repository.getListItemsByListId(listId);
    // Repository already returns items sorted by sortOrder
    return items;
  }

  /// Creates a new list item with validation.
  ///
  /// Validation rules:
  /// - Title must not be empty
  ///
  /// For checklist style lists, this updates the parent list's checkedItemCount
  /// if the item is checked.
  ///
  /// Returns:
  ///   The created list item
  Future<ListItem> createListItem(ListItem item) async {
    // Validate title
    if (item.title.trim().isEmpty) {
      throw ValidationErrorMapper.requiredField('List item title');
    }

    // Repository handles sortOrder calculation and count updates
    return await _repository.createListItem(item);
  }

  /// Updates an existing list item with validation.
  ///
  /// Validation rules:
  /// - Title must not be empty
  ///
  /// If checked status changes, updates parent list's checkedItemCount.
  Future<ListItem> updateListItem(ListItem item) async {
    // Validate title
    if (item.title.trim().isEmpty) {
      throw ValidationErrorMapper.requiredField('List item title');
    }

    return await _repository.updateListItem(item);
  }

  /// Deletes a list item.
  ///
  /// Updates parent list's count fields if applicable.
  Future<void> deleteListItem(String id, String listId) async {
    await _repository.deleteListItem(id, listId);
  }

  /// Toggles the checked status of a list item (checklist style only).
  ///
  /// This is a convenience method that toggles isChecked and updates the item.
  /// The repository handles count recalculation.
  ///
  /// Parameters:
  ///   - item: The list item to toggle
  ///
  /// Returns:
  ///   The updated list item with toggled checked status
  Future<ListItem> toggleListItem(ListItem item) async {
    // Toggle checked status
    final updatedItem = item.copyWith(isChecked: !item.isChecked);

    // Update item (repository handles count recalculation)
    return await _repository.updateListItem(updatedItem);
  }

  /// Reorders list items within a list.
  ///
  /// Parameters:
  ///   - listId: The list ID
  ///   - orderedIds: List of item IDs in the new order
  ///
  /// This updates the sortOrder field for all affected items.
  Future<void> reorderListItems(
    String listId,
    List<String> orderedIds,
  ) async {
    // Load current items
    final items = await _repository.getListItemsByListId(listId);

    // Create updated items with new sortOrder values
    final updatedItems = <ListItem>[];
    for (int i = 0; i < orderedIds.length; i++) {
      final id = orderedIds[i];
      final item = items.firstWhere((ListItem it) => it.id == id);
      updatedItems.add(item.copyWith(sortOrder: i));
    }

    // Update each item with new sortOrder
    for (final item in updatedItems) {
      await _repository.updateListItem(item);
    }
  }
}
