import '../../domain/models/space.dart';
import '../../../../data/repositories/base_repository.dart';

/// Repository for managing Space entities in Supabase.
///
/// Provides CRUD operations and filtering capabilities for spaces.
/// Uses Supabase 'spaces' table for persistence with RLS policies.
/// Item counts are calculated dynamically via database queries.
class SpaceRepository extends BaseRepository {
  /// Creates a new space in Supabase.
  ///
  /// Automatically sets the user_id from the authenticated user.
  ///
  /// Parameters:
  ///   - [space]: The space to be created
  ///
  /// Returns:
  ///   The created space
  ///
  /// Throws:
  ///   Exception if user is not authenticated or database operation fails
  ///
  /// Example:
  /// ```dart
  /// final space = Space(
  ///   id: 'space-1',
  ///   name: 'Work',
  ///   userId: 'user-123',
  ///   icon: '💼',
  ///   color: '#FF5733',
  /// );
  /// final created = await repository.createSpace(space);
  /// ```
  Future<Space> createSpace(Space space) async {
    return executeQuery(() async {
      final data = space.toJson();
      data['user_id'] = userId; // Ensure correct user_id

      final response = await supabase
          .from('spaces')
          .insert(data)
          .select()
          .single();

      return Space.fromJson(response);
    });
  }

  /// Retrieves spaces from Supabase.
  ///
  /// By default, returns only non-archived spaces. Set [includeArchived] to
  /// true to retrieve all spaces including archived ones.
  /// Automatically filters by authenticated user via RLS policies.
  ///
  /// Parameters:
  ///   - [includeArchived]: If true, includes archived spaces in the results.
  ///     Defaults to false.
  ///
  /// Returns:
  ///   A list of spaces based on the archive filter
  ///
  /// Throws:
  ///   Exception if user is not authenticated or database operation fails
  ///
  /// Example:
  /// ```dart
  /// // Get only active spaces
  /// final activeSpaces = await repository.getSpaces();
  ///
  /// // Get all spaces including archived
  /// final allSpaces = await repository.getSpaces(includeArchived: true);
  /// ```
  Future<List<Space>> getSpaces({bool includeArchived = false}) async {
    return executeQuery(() async {
      final response = includeArchived
          ? await supabase
                .from('spaces')
                .select()
                .eq('user_id', userId)
                .order('created_at', ascending: true)
          : await supabase
                .from('spaces')
                .select()
                .eq('user_id', userId)
                .eq('is_archived', false)
                .order('created_at', ascending: true);

      return (response as List)
          .map((json) => Space.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  /// Retrieves a single space by its ID.
  ///
  /// Returns null if the space does not exist or user doesn't have access.
  /// RLS policies ensure users can only access their own spaces.
  ///
  /// Parameters:
  ///   - [id]: The ID of the space to retrieve
  ///
  /// Returns:
  ///   The space with the given ID, or null if not found
  ///
  /// Throws:
  ///   Exception if user is not authenticated or database operation fails
  ///
  /// Example:
  /// ```dart
  /// final space = await repository.getSpaceById('space-1');
  /// if (space != null) {
  ///   print('Found space: ${space.name}');
  /// }
  /// ```
  Future<Space?> getSpaceById(String id) async {
    return executeQuery(() async {
      final response = await supabase
          .from('spaces')
          .select()
          .eq('id', id)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return Space.fromJson(response);
    });
  }

  /// Updates an existing space in Supabase.
  ///
  /// Automatically updates the updated_at timestamp to the current time.
  /// RLS policies ensure users can only update their own spaces.
  ///
  /// Parameters:
  ///   - [space]: The space to update with new values
  ///
  /// Returns:
  ///   The updated space with the new updated_at timestamp
  ///
  /// Throws:
  ///   Exception if space doesn't exist, user doesn't have access, or operation fails
  ///
  /// Example:
  /// ```dart
  /// final updatedSpace = space.copyWith(
  ///   name: 'Updated Work',
  ///   isArchived: true,
  /// );
  /// final result = await repository.updateSpace(updatedSpace);
  /// ```
  Future<Space> updateSpace(Space space) async {
    return executeQuery(() async {
      // Update the updatedAt timestamp
      final updatedSpace = space.copyWith(updatedAt: DateTime.now());
      final data = updatedSpace.toJson();

      final response = await supabase
          .from('spaces')
          .update(data)
          .eq('id', space.id)
          .eq('user_id', userId)
          .select()
          .single();

      return Space.fromJson(response);
    });
  }

  /// Deletes a space from Supabase.
  ///
  /// RLS policies ensure users can only delete their own spaces.
  /// Associated content (notes, todos, lists) will be cascade deleted
  /// if foreign key constraints are configured with ON DELETE CASCADE.
  ///
  /// Parameters:
  ///   - [id]: The ID of the space to delete
  ///
  /// Throws:
  ///   Exception if user doesn't have access or operation fails
  ///
  /// Example:
  /// ```dart
  /// await repository.deleteSpace('space-1');
  /// ```
  Future<void> deleteSpace(String id) async {
    return executeQuery(() async {
      await supabase.from('spaces').delete().eq('id', id).eq('user_id', userId);
    });
  }

  /// Calculates the total number of items in a space.
  ///
  /// This count is calculated dynamically from the database by querying
  /// the notes, todo_lists, and lists tables, ensuring it's always accurate.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to count items for
  ///
  /// Returns:
  ///   The total number of items in the space
  ///
  /// Throws:
  ///   Exception if user is not authenticated or database operation fails
  ///
  /// Example:
  /// ```dart
  /// final count = await repository.getItemCount('space-1');
  /// print('Space has $count items');
  /// ```
  Future<int> getItemCount(String spaceId) async {
    return executeQuery(() async {
      int totalCount = 0;

      // Count notes
      final notesResponse = await supabase
          .from('notes')
          .select()
          .eq('space_id', spaceId)
          .eq('user_id', userId);
      totalCount += (notesResponse as List).length;

      // Count todo_lists
      final todoListsResponse = await supabase
          .from('todo_lists')
          .select()
          .eq('space_id', spaceId)
          .eq('user_id', userId);
      totalCount += (todoListsResponse as List).length;

      // Count lists
      final listsResponse = await supabase
          .from('lists')
          .select()
          .eq('space_id', spaceId)
          .eq('user_id', userId);
      totalCount += (listsResponse as List).length;

      return totalCount;
    });
  }
}
