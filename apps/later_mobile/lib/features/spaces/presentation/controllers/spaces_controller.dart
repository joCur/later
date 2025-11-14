// ignore_for_file: depend_on_referenced_packages
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../application/providers.dart';
import '../../domain/models/space.dart';

part 'spaces_controller.g.dart';

/// Controller for managing spaces state.
///
/// Manages AsyncValue with list of spaces for all spaces.
/// Provides methods for CRUD operations on spaces.
/// Uses SpaceService for business logic.
@riverpod
class SpacesController extends _$SpacesController {
  @override
  Future<List<Space>> build() async {
    // Load spaces on initialization
    final service = ref.read(spaceServiceProvider);
    return service.loadSpaces();
  }

  /// Loads spaces from the service.
  ///
  /// By default, only non-archived spaces are loaded.
  /// Set [includeArchived] to true to load all spaces including archived ones.
  ///
  /// Parameters:
  ///   - [includeArchived]: If true, includes archived spaces. Defaults to false.
  Future<void> loadSpaces({bool includeArchived = false}) async {
    state = const AsyncValue.loading();

    final service = ref.read(spaceServiceProvider);
    state = await AsyncValue.guard(() => service.loadSpaces(includeArchived: includeArchived));
  }

  /// Creates a new space.
  ///
  /// Validates and creates the space, then refreshes the spaces list.
  ///
  /// Parameters:
  ///   - [space]: The space to create
  Future<void> createSpace(Space space) async {
    final service = ref.read(spaceServiceProvider);

    try {
      final created = await service.createSpace(space);

      // Check if still mounted
      if (!ref.mounted) return;

      // Add to current state
      state = state.whenData((spaces) => [...spaces, created]);
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Updates an existing space.
  ///
  /// Validates and updates the space, then refreshes the spaces list.
  ///
  /// Parameters:
  ///   - [space]: The space to update with new values
  Future<void> updateSpace(Space space) async {
    final service = ref.read(spaceServiceProvider);

    try {
      final updated = await service.updateSpace(space);

      // Check if still mounted
      if (!ref.mounted) return;

      // Update in current state
      state = state.whenData((spaces) {
        final index = spaces.indexWhere((s) => s.id == space.id);
        if (index == -1) return spaces;

        return [
          ...spaces.sublist(0, index),
          updated,
          ...spaces.sublist(index + 1),
        ];
      });
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Deletes a space.
  ///
  /// Validates that the space is not the current space, then deletes it.
  /// Refreshes the spaces list after deletion.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to delete
  ///   - [currentSpaceId]: The ID of the currently active space
  Future<void> deleteSpace(String spaceId, String? currentSpaceId) async {
    final service = ref.read(spaceServiceProvider);

    try {
      await service.deleteSpace(spaceId, currentSpaceId);

      // Check if still mounted
      if (!ref.mounted) return;

      // Remove from current state
      state = state.whenData((spaces) => spaces.where((s) => s.id != spaceId).toList());
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Archives a space.
  ///
  /// Sets the space's isArchived flag to true.
  ///
  /// Parameters:
  ///   - [space]: The space to archive
  Future<void> archiveSpace(Space space) async {
    final service = ref.read(spaceServiceProvider);

    try {
      final archived = await service.archiveSpace(space);

      // Check if still mounted
      if (!ref.mounted) return;

      // Update in current state
      state = state.whenData((spaces) {
        final index = spaces.indexWhere((s) => s.id == space.id);
        if (index == -1) return spaces;

        return [
          ...spaces.sublist(0, index),
          archived,
          ...spaces.sublist(index + 1),
        ];
      });
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Unarchives a space.
  ///
  /// Sets the space's isArchived flag to false.
  ///
  /// Parameters:
  ///   - [space]: The space to unarchive
  Future<void> unarchiveSpace(Space space) async {
    final service = ref.read(spaceServiceProvider);

    try {
      final unarchived = await service.unarchiveSpace(space);

      // Check if still mounted
      if (!ref.mounted) return;

      // Update in current state
      state = state.whenData((spaces) {
        final index = spaces.indexWhere((s) => s.id == space.id);
        if (index == -1) return spaces;

        return [
          ...spaces.sublist(0, index),
          unarchived,
          ...spaces.sublist(index + 1),
        ];
      });
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Gets the calculated item count for a space.
  ///
  /// Returns the number of items (notes, todos, lists) in the space.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to get the count for
  ///
  /// Returns the item count, or 0 if an error occurs.
  Future<int> getSpaceItemCount(String spaceId) async {
    final service = ref.read(spaceServiceProvider);

    try {
      return await service.getSpaceItemCount(spaceId);
    } catch (e) {
      // Return 0 as fallback
      return 0;
    }
  }
}
