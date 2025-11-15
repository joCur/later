import '../../data/repositories/space_repository.dart';
import '../../domain/models/space.dart';
import 'package:later_mobile/core/error/error.dart';

/// Application service for space business logic.
///
/// Coordinates space operations with validation and business rules.
/// Delegates data access to SpaceRepository.
class SpaceService {
  SpaceService({required SpaceRepository repository}) : _repository = repository;

  final SpaceRepository _repository;

  /// Loads spaces from the repository.
  ///
  /// By default, only non-archived spaces are loaded and sorted by creation date.
  /// Set [includeArchived] to true to load all spaces including archived ones.
  ///
  /// Parameters:
  ///   - [includeArchived]: If true, includes archived spaces. Defaults to false.
  ///
  /// Returns list of spaces sorted by creation date (oldest first).
  ///
  /// Throws [AppError] if the operation fails.
  Future<List<Space>> loadSpaces({bool includeArchived = false}) async {
    try {
      final spaces =
          await _repository.getSpaces(includeArchived: includeArchived);
      // Spaces are already sorted by created_at in repository
      return spaces;
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError(
        code: ErrorCode.unknownError,
        message: 'Failed to load spaces: ${e.toString()}',
        technicalDetails: e.toString(),
      );
    }
  }

  /// Creates a new space with validation.
  ///
  /// Validates that the space name is not empty before creating.
  ///
  /// Parameters:
  ///   - [space]: The space to create
  ///
  /// Returns the created space.
  ///
  /// Throws [AppError] if validation fails or operation fails.
  Future<Space> createSpace(Space space) async {
    // Validate name is not empty
    if (space.name.trim().isEmpty) {
      throw ValidationErrorMapper.requiredField('Space name');
    }

    try {
      return await _repository.createSpace(space);
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError(
        code: ErrorCode.unknownError,
        message: 'Failed to create space: ${e.toString()}',
        technicalDetails: e.toString(),
      );
    }
  }

  /// Updates an existing space with validation.
  ///
  /// Validates that the space name is not empty before updating.
  ///
  /// Parameters:
  ///   - [space]: The space to update with new values
  ///
  /// Returns the updated space.
  ///
  /// Throws [AppError] if validation fails or operation fails.
  Future<Space> updateSpace(Space space) async {
    // Validate name is not empty
    if (space.name.trim().isEmpty) {
      throw ValidationErrorMapper.requiredField('Space name');
    }

    try {
      return await _repository.updateSpace(space);
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError(
        code: ErrorCode.unknownError,
        message: 'Failed to update space: ${e.toString()}',
        technicalDetails: e.toString(),
      );
    }
  }

  /// Deletes a space from the repository.
  ///
  /// Business rule: Cannot delete the current/active space.
  /// Caller must switch to a different space before deleting.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to delete
  ///   - [currentSpaceId]: The ID of the currently active space
  ///
  /// Throws [AppError] if trying to delete current space or operation fails.
  Future<void> deleteSpace(String spaceId, String? currentSpaceId) async {
    // Business rule: Cannot delete current space
    if (currentSpaceId != null && spaceId == currentSpaceId) {
      throw const AppError(
        code: ErrorCode.validationRequired,
        message: 'Cannot delete the current space',
        context: {'fieldName': 'Current space'},
      );
    }

    try {
      await _repository.deleteSpace(spaceId);
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError(
        code: ErrorCode.unknownError,
        message: 'Failed to delete space: ${e.toString()}',
        technicalDetails: e.toString(),
      );
    }
  }

  /// Archives a space.
  ///
  /// Sets the space's isArchived flag to true.
  ///
  /// Parameters:
  ///   - [space]: The space to archive
  ///
  /// Returns the archived space.
  ///
  /// Throws [AppError] if operation fails.
  Future<Space> archiveSpace(Space space) async {
    try {
      final archivedSpace = space.copyWith(isArchived: true);
      return await _repository.updateSpace(archivedSpace);
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError(
        code: ErrorCode.unknownError,
        message: 'Failed to archive space: ${e.toString()}',
        technicalDetails: e.toString(),
      );
    }
  }

  /// Unarchives a space.
  ///
  /// Sets the space's isArchived flag to false.
  ///
  /// Parameters:
  ///   - [space]: The space to unarchive
  ///
  /// Returns the unarchived space.
  ///
  /// Throws [AppError] if operation fails.
  Future<Space> unarchiveSpace(Space space) async {
    try {
      final unarchivedSpace = space.copyWith(isArchived: false);
      return await _repository.updateSpace(unarchivedSpace);
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError(
        code: ErrorCode.unknownError,
        message: 'Failed to unarchive space: ${e.toString()}',
        technicalDetails: e.toString(),
      );
    }
  }

  /// Gets the calculated item count for a space.
  ///
  /// Delegates to repository to calculate the count from database.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to get the count for
  ///
  /// Returns the calculated item count for the space.
  ///
  /// Throws [AppError] if operation fails.
  Future<int> getSpaceItemCount(String spaceId) async {
    try {
      return await _repository.getItemCount(spaceId);
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError(
        code: ErrorCode.unknownError,
        message: 'Failed to get item count: ${e.toString()}',
        technicalDetails: e.toString(),
      );
    }
  }
}
