import 'package:later_mobile/data/repositories/base_repository.dart';
import 'package:later_mobile/features/lists/domain/models/list_item_model.dart';
import 'package:later_mobile/features/lists/domain/models/list_model.dart';

/// Repository for managing ListModel and ListItem entities in Supabase.
///
/// Provides CRUD operations for lists and their items.
/// Uses Supabase 'lists' and 'list_items' tables with RLS policies.
/// ListItems are stored separately and fetched on demand for efficiency.
class ListRepository extends BaseRepository {
  /// Creates a new list in Supabase.
  ///
  /// Automatically calculates and assigns the next sortOrder value for the list
  /// within its space. Automatically sets the user_id from the authenticated user.
  /// Initializes count fields to 0.
  ///
  /// Parameters:
  ///   - [list]: The list to be created
  ///
  /// Returns:
  ///   The created list with assigned sortOrder and initial counts
  ///
  /// Throws:
  ///   Exception if user is not authenticated or database operation fails
  Future<ListModel> create(ListModel list) async {
    return executeQuery(() async {
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
      final data = listWithSortOrder.toJson();
      data['user_id'] = userId; // Ensure correct user_id

      // Remove count fields - these are calculated, not stored
      data.remove('total_item_count');
      data.remove('checked_item_count');

      final response = await supabase
          .from('lists')
          .insert(data)
          .select()
          .single();

      // Calculate counts for the newly created list (will be 0)
      return ListModel.fromJson(
        response,
      ).copyWith(totalItemCount: 0, checkedItemCount: 0);
    });
  }

  /// Retrieves a single list by its ID with aggregate counts.
  ///
  /// Returns null if the list does not exist or user doesn't have access.
  /// RLS policies ensure users can only access their own lists.
  /// Note: This does NOT fetch the list items - use getListItemsByListId() for that.
  ///
  /// Parameters:
  ///   - [id]: The ID of the list to retrieve
  ///
  /// Returns:
  ///   The list with the given ID (with aggregate counts), or null if not found
  Future<ListModel?> getById(String id) async {
    return executeQuery(() async {
      final listResponse = await supabase
          .from('lists')
          .select()
          .eq('id', id)
          .eq('user_id', userId)
          .maybeSingle();

      if (listResponse == null) return null;

      // Fetch items to calculate counts
      final items = await getListItemsByListId(id);
      final totalCount = items.length;
      final checkedCount = items.where((item) => item.isChecked).length;

      final list = ListModel.fromJson(listResponse);
      return list.copyWith(
        totalItemCount: totalCount,
        checkedItemCount: checkedCount,
      );
    });
  }

  /// Retrieves all lists belonging to a specific space with aggregate counts.
  ///
  /// RLS policies ensure users can only access their own lists.
  /// Orders by sort_order ascending.
  /// Note: This does NOT fetch the list items - use getListItemsByListId() for that.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to filter by
  ///
  /// Returns:
  ///   A list of lists belonging to the specified space
  Future<List<ListModel>> getBySpace(String spaceId) async {
    return executeQuery(() async {
      final response = await supabase
          .from('lists')
          .select()
          .eq('space_id', spaceId)
          .eq('user_id', userId)
          .order('sort_order', ascending: true);

      final lists = (response as List)
          .map((json) => ListModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Fetch counts for each list
      final listsWithCounts = await Future.wait(
        lists.map((list) async {
          final items = await getListItemsByListId(list.id);
          final totalCount = items.length;
          final checkedCount = items.where((item) => item.isChecked).length;

          return list.copyWith(
            totalItemCount: totalCount,
            checkedItemCount: checkedCount,
          );
        }),
      );

      return listsWithCounts;
    });
  }

  /// Updates an existing list in Supabase.
  ///
  /// Automatically updates the updated_at timestamp to the current time.
  /// RLS policies ensure users can only update their own lists.
  /// Note: This updates the list metadata only. To update items, use ListItem methods.
  ///
  /// Parameters:
  ///   - [list]: The list to update with new values
  ///
  /// Returns:
  ///   The updated list with the new updated_at timestamp
  Future<ListModel> update(ListModel list) async {
    return executeQuery(() async {
      // Update the updatedAt timestamp
      final updatedList = list.copyWith(updatedAt: DateTime.now());
      final data = updatedList.toJson();

      final response = await supabase
          .from('lists')
          .update(data)
          .eq('id', list.id)
          .eq('user_id', userId)
          .select()
          .single();

      return ListModel.fromJson(response);
    });
  }

  /// Deletes a list from Supabase.
  ///
  /// RLS policies ensure users can only delete their own lists.
  /// Associated list items will be cascade deleted via foreign key constraints.
  ///
  /// Parameters:
  ///   - [id]: The ID of the list to delete
  Future<void> delete(String id) async {
    return executeQuery(() async {
      await supabase.from('lists').delete().eq('id', id).eq('user_id', userId);
    });
  }

  /// Retrieves all list items belonging to a specific list.
  ///
  /// RLS policies ensure users can only access items from their own lists.
  /// Orders by sort_order ascending.
  ///
  /// Parameters:
  ///   - [listId]: The ID of the list
  ///
  /// Returns:
  ///   A list of list items belonging to the specified list
  Future<List<ListItem>> getListItemsByListId(String listId) async {
    return executeQuery(() async {
      final response = await supabase
          .from('list_items')
          .select()
          .eq('list_id', listId)
          .order('sort_order', ascending: true);

      return (response as List)
          .map((json) => ListItem.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  /// Creates a new list item in Supabase.
  ///
  /// Automatically calculates and assigns the next sortOrder value for the item
  /// within its list. After creating the item, updates the parent list's
  /// aggregate counts.
  ///
  /// Parameters:
  ///   - [listItem]: The list item to be created
  ///
  /// Returns:
  ///   The created list item with assigned sortOrder
  Future<ListItem> createListItem(ListItem listItem) async {
    return executeQuery(() async {
      // Calculate next sortOrder for this list
      final itemsInList = await getListItemsByListId(listItem.listId);
      final maxSortOrder = itemsInList.isEmpty
          ? -1
          : itemsInList
                .map((item) => item.sortOrder)
                .reduce((a, b) => a > b ? a : b);
      final nextSortOrder = maxSortOrder + 1;

      // Create item with calculated sortOrder
      final listItemWithSortOrder = listItem.copyWith(sortOrder: nextSortOrder);
      final data = listItemWithSortOrder.toJson();

      final response = await supabase
          .from('list_items')
          .insert(data)
          .select()
          .single();

      return ListItem.fromJson(response);
    });
  }

  /// Updates an existing list item in Supabase.
  ///
  /// If the checked status changes, updates the parent list's counts.
  /// RLS policies ensure users can only update items from their own lists.
  ///
  /// Parameters:
  ///   - [listItem]: The list item to update with new values
  ///
  /// Returns:
  ///   The updated list item
  Future<ListItem> updateListItem(ListItem listItem) async {
    return executeQuery(() async {
      final data = listItem.toJson();

      final response = await supabase
          .from('list_items')
          .update(data)
          .eq('id', listItem.id)
          .select()
          .single();

      return ListItem.fromJson(response);
    });
  }

  /// Deletes a list item from Supabase.
  ///
  /// After deleting the item, updates the parent list's aggregate counts.
  /// RLS policies ensure users can only delete items from their own lists.
  ///
  /// Parameters:
  ///   - [id]: The ID of the list item to delete
  ///   - [listId]: The ID of the parent list (for count updates)
  Future<void> deleteListItem(String id, String listId) async {
    return executeQuery(() async {
      await supabase.from('list_items').delete().eq('id', id);
    });
  }

  /// Updates the sort orders for multiple list items in a batch.
  ///
  /// Used for drag-and-drop reordering. Updates all items with their new
  /// sort_order values in a single operation.
  ///
  /// Parameters:
  ///   - [listItems]: List of list items with updated sortOrder values
  Future<void> updateListItemSortOrders(List<ListItem> listItems) async {
    return executeQuery(() async {
      final updates = listItems.map((item) => item.toJson()).toList();

      // Use upsert to update multiple records at once
      await supabase.from('list_items').upsert(updates);
    });
  }
}
