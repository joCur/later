import 'package:later_mobile/data/repositories/base_repository.dart';
import 'package:later_mobile/features/search/domain/models/search_query.dart';
import 'package:later_mobile/features/search/domain/models/search_result.dart';
import 'package:later_mobile/features/notes/domain/models/note.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_list.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_item.dart';
import 'package:later_mobile/features/lists/domain/models/list_model.dart';
import 'package:later_mobile/features/lists/domain/models/list_item_model.dart';
import 'package:later_mobile/core/enums/content_type.dart';

/// Repository for performing unified search across all content types
///
/// Provides search functionality across notes, todo lists, lists, todo items,
/// and list items using PostgreSQL full-text search with GIN indexes.
///
/// Supports pagination with configurable limit and offset parameters.
///
/// Usage:
/// ```dart
/// final repo = SearchRepository();
/// final query = SearchQuery(
///   query: 'shopping',
///   spaceId: 'space-1',
///   contentTypes: [ContentType.note, ContentType.todoList],
///   limit: 50,
///   offset: 0,
/// );
/// final results = await repo.search(query);
/// ```
class SearchRepository extends BaseRepository {
  /// Search across all content types based on the provided query
  ///
  /// Performs full-text search using PostgreSQL's tsvector columns and GIN indexes.
  /// Results are filtered by space_id and optionally by content type and tags.
  /// All results are sorted by updated_at in descending order.
  ///
  /// Parameters:
  ///   - [query]: Search parameters including query string, space filter, and content type filter
  ///
  /// Returns:
  ///   List of SearchResult objects sorted by updated_at (descending)
  ///
  /// Throws:
  ///   AppError with appropriate error code for database errors
  ///
  /// Example:
  /// ```dart
  /// final query = SearchQuery(
  ///   query: 'meeting',
  ///   spaceId: 'space-123',
  ///   contentTypes: [ContentType.note],
  ///   tags: ['work'],
  /// );
  /// final results = await repository.search(query);
  /// ```
  Future<List<SearchResult>> search(SearchQuery query) async {
    return executeQuery(() async {
      final results = <SearchResult>[];

      // Determine which content types to search
      final contentTypes = query.contentTypes ?? ContentType.values;

      // Search each content type based on filter
      if (contentTypes.contains(ContentType.note)) {
        results.addAll(await _searchNotes(query));
      }
      if (contentTypes.contains(ContentType.todoList)) {
        results.addAll(await _searchTodoLists(query));
      }
      if (contentTypes.contains(ContentType.list)) {
        results.addAll(await _searchLists(query));
      }
      if (contentTypes.contains(ContentType.todoItem)) {
        results.addAll(await _searchTodoItems(query));
      }
      if (contentTypes.contains(ContentType.listItem)) {
        results.addAll(await _searchListItems(query));
      }

      // Sort all results by updatedAt descending
      results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return results;
    });
  }

  /// Search notes using ILIKE for substring matching
  ///
  /// Searches both title and content fields using case-insensitive substring matching.
  /// Filters by user_id, space_id, and optionally tags.
  Future<List<SearchResult>> _searchNotes(SearchQuery query) async {
    // Build base query
    var queryBuilder = supabase
        .from('notes')
        .select()
        .eq('user_id', userId)
        .eq('space_id', query.spaceId);

    // Add tag filter if provided (AND logic: result must contain ALL tags)
    if (query.tags != null && query.tags!.isNotEmpty) {
      queryBuilder = queryBuilder.contains('tags', query.tags!);
    }

    // Search in both title and content using OR
    // Note: We need to use .or() to search multiple fields
    final response = await queryBuilder
        .or('title.ilike.%${query.query}%,content.ilike.%${query.query}%')
        .order('updated_at', ascending: false)
        .range(query.offset, query.offset + query.limit - 1);

    return (response as List<dynamic>)
        .map((json) => Note.fromJson(json as Map<String, dynamic>))
        .map((note) => SearchResult.fromNote(note))
        .toList();
  }

  /// Search todo lists using ILIKE for substring matching
  ///
  /// Searches both name and description fields using case-insensitive substring matching.
  /// Filters by user_id and space_id.
  Future<List<SearchResult>> _searchTodoLists(SearchQuery query) async {
    final response = await supabase
        .from('todo_lists')
        .select()
        .eq('user_id', userId)
        .eq('space_id', query.spaceId)
        .or('name.ilike.%${query.query}%,description.ilike.%${query.query}%')
        .order('updated_at', ascending: false)
        .range(query.offset, query.offset + query.limit - 1);

    return (response as List<dynamic>)
        .map((json) => TodoList.fromJson(json as Map<String, dynamic>))
        .map((todoList) => SearchResult.fromTodoList(todoList))
        .toList();
  }

  /// Search lists using ILIKE for substring matching
  ///
  /// Searches the lists table using ILIKE for case-insensitive substring matching.
  /// This allows "ein" to match "Einkaufsliste" and "kauf" to match "Einkaufsliste".
  /// Filters by user_id and space_id.
  Future<List<SearchResult>> _searchLists(SearchQuery query) async {
    final response = await supabase
        .from('lists')
        .select()
        .eq('user_id', userId)
        .eq('space_id', query.spaceId)
        .ilike('name', '%${query.query}%')
        .order('updated_at', ascending: false)
        .range(query.offset, query.offset + query.limit - 1);

    return (response as List<dynamic>)
        .map((json) => ListModel.fromJson(json as Map<String, dynamic>))
        .map((list) => SearchResult.fromList(list))
        .toList();
  }

  /// Search todo items using ILIKE for substring matching with JOIN to parent todo_lists
  ///
  /// Searches both title and description fields using case-insensitive substring matching.
  /// Uses INNER JOIN to filter by space_id and user_id via the parent relationship.
  /// Returns results with parent context (parent name and ID) for display.
  Future<List<SearchResult>> _searchTodoItems(SearchQuery query) async {
    // Build base query with JOIN
    var queryBuilder = supabase
        .from('todo_items')
        .select('*, todo_lists!inner(id, name, space_id, user_id, updated_at)')
        .eq('todo_lists.user_id', userId)
        .eq('todo_lists.space_id', query.spaceId);

    // Add tag filter if provided (AND logic: result must contain ALL tags)
    if (query.tags != null && query.tags!.isNotEmpty) {
      queryBuilder = queryBuilder.contains('tags', query.tags!);
    }

    // Search in both title and description using OR
    final response = await queryBuilder
        .or('title.ilike.%${query.query}%,description.ilike.%${query.query}%')
        .range(query.offset, query.offset + query.limit - 1);

    return (response as List<dynamic>).map((json) {
      final itemJson = Map<String, dynamic>.from(json as Map<String, dynamic>);
      final parentJson = itemJson['todo_lists'] as Map<String, dynamic>;

      // Remove nested parent object before parsing TodoItem
      itemJson.remove('todo_lists');

      final item = TodoItem.fromJson(itemJson);

      return SearchResult.fromTodoItem(
        item: item,
        parentId: parentJson['id'] as String,
        parentName: parentJson['name'] as String,
        parentUpdatedAt: DateTime.parse(parentJson['updated_at'] as String),
      );
    }).toList();
  }

  /// Search list items using ILIKE for substring matching with JOIN to parent lists
  ///
  /// Searches both title and notes fields using case-insensitive substring matching.
  /// Uses INNER JOIN to filter by space_id and user_id via the parent relationship.
  /// Returns results with parent context (parent name and ID) for display.
  Future<List<SearchResult>> _searchListItems(SearchQuery query) async {
    final response = await supabase
        .from('list_items')
        .select('*, lists!inner(id, name, space_id, user_id, updated_at)')
        .eq('lists.user_id', userId)
        .eq('lists.space_id', query.spaceId)
        .or('title.ilike.%${query.query}%,notes.ilike.%${query.query}%')
        .range(query.offset, query.offset + query.limit - 1);

    return (response as List<dynamic>).map((json) {
      final itemJson = Map<String, dynamic>.from(json as Map<String, dynamic>);
      final parentJson = itemJson['lists'] as Map<String, dynamic>;

      // Remove nested parent object before parsing ListItem
      itemJson.remove('lists');

      final item = ListItem.fromJson(itemJson);

      return SearchResult.fromListItem(
        item: item,
        parentId: parentJson['id'] as String,
        parentName: parentJson['name'] as String,
        parentUpdatedAt: DateTime.parse(parentJson['updated_at'] as String),
      );
    }).toList();
  }
}
