import 'package:hive/hive.dart';
import '../../core/services/space_item_count_service.dart';
import '../models/space_model.dart';

/// Repository for managing Space entities in Hive local storage.
///
/// Provides CRUD operations and filtering capabilities for spaces.
/// Uses Hive box 'spaces' for persistence.
/// Item counts are calculated dynamically via SpaceItemCountService.
class SpaceRepository {
  /// Gets the Hive box for spaces
  Box<Space> get _box => Hive.box<Space>('spaces');

  /// Creates a new space in the local storage.
  ///
  /// Stores the space using its ID as the key in the Hive box.
  ///
  /// Parameters:
  ///   - [space]: The space to be created
  ///
  /// Returns:
  ///   The created space
  ///
  /// Example:
  /// ```dart
  /// final space = Space(
  ///   id: 'space-1',
  ///   name: 'Work',
  ///   icon: '💼',
  ///   color: '#FF5733',
  /// );
  /// final created = await repository.createSpace(space);
  /// ```
  Future<Space> createSpace(Space space) async {
    await _box.put(space.id, space);
    return space;
  }

  /// Retrieves spaces from local storage.
  ///
  /// By default, returns only non-archived spaces. Set [includeArchived] to
  /// true to retrieve all spaces including archived ones.
  ///
  /// Parameters:
  ///   - [includeArchived]: If true, includes archived spaces in the results.
  ///     Defaults to false.
  ///
  /// Returns:
  ///   A list of spaces based on the archive filter
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
    if (includeArchived) {
      return _box.values.toList();
    }
    return _box.values.where((space) => !space.isArchived).toList();
  }

  /// Retrieves a single space by its ID.
  ///
  /// Returns null if the space does not exist.
  ///
  /// Parameters:
  ///   - [id]: The ID of the space to retrieve
  ///
  /// Returns:
  ///   The space with the given ID, or null if not found
  ///
  /// Example:
  /// ```dart
  /// final space = await repository.getSpaceById('space-1');
  /// if (space != null) {
  ///   print('Found space: ${space.name}');
  /// }
  /// ```
  Future<Space?> getSpaceById(String id) async {
    return _box.get(id);
  }

  /// Updates an existing space in local storage.
  ///
  /// Automatically updates the updatedAt timestamp to the current time.
  /// Throws an exception if the space does not exist.
  ///
  /// Parameters:
  ///   - [space]: The space to update with new values
  ///
  /// Returns:
  ///   The updated space with the new updatedAt timestamp
  ///
  /// Throws:
  ///   Exception if the space with the given ID does not exist
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
    // Check if the space exists
    if (!_box.containsKey(space.id)) {
      throw Exception('Space with id ${space.id} does not exist');
    }

    // Update the updatedAt timestamp
    final updatedSpace = space.copyWith(updatedAt: DateTime.now());

    await _box.put(updatedSpace.id, updatedSpace);
    return updatedSpace;
  }

  /// Deletes a space from local storage.
  ///
  /// If the space does not exist, this operation completes without error.
  ///
  /// Parameters:
  ///   - [id]: The ID of the space to delete
  ///
  /// Example:
  /// ```dart
  /// await repository.deleteSpace('space-1');
  /// ```
  Future<void> deleteSpace(String id) async {
    await _box.delete(id);
  }

  /// Calculates the total number of items in a space.
  ///
  /// This count is calculated dynamically from the actual items stored in
  /// Hive boxes (notes, todo_lists, lists), ensuring it's always accurate
  /// and synchronized with the database.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to count items for
  ///
  /// Returns:
  ///   The total number of items in the space
  ///
  /// Example:
  /// ```dart
  /// final count = await repository.getItemCount('space-1');
  /// print('Space has $count items');
  /// ```
  Future<int> getItemCount(String spaceId) async {
    return SpaceItemCountService.calculateItemCount(spaceId);
  }
}
