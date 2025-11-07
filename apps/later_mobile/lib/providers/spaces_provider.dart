import 'package:flutter/foundation.dart';
import '../core/error/app_error.dart';
import '../data/local/preferences_service.dart';
import '../data/models/space_model.dart';
import '../data/repositories/space_repository.dart';

/// Provider for managing Space state in the application.
///
/// This provider handles all space-related operations including loading,
/// creating, updating, and deleting spaces. It also manages the current
/// active space. It manages loading states, error states, and notifies
/// listeners of state changes.
///
/// Example usage:
/// ```dart
/// final provider = Provider.of<SpacesProvider>(context);
/// await provider.loadSpaces();
/// print('Current space: ${provider.currentSpace?.name}');
/// ```
class SpacesProvider extends ChangeNotifier {
  /// Creates a SpacesProvider with the given repository.
  ///
  /// The [repository] parameter is required and will be used for all
  /// data persistence operations.
  SpacesProvider(this._repository);

  final SpaceRepository _repository;

  /// List of spaces currently loaded in the provider.
  List<Space> _spaces = [];

  /// Returns an unmodifiable view of the current spaces.
  List<Space> get spaces => List.unmodifiable(_spaces);

  /// The currently active space.
  Space? _currentSpace;

  /// Returns the currently active space, or null if none is selected.
  Space? get currentSpace => _currentSpace;

  /// Indicates whether an async operation is currently in progress.
  bool _isLoading = false;

  /// Returns true if an async operation is in progress.
  bool get isLoading => _isLoading;

  /// Current error, if any.
  AppError? _error;

  /// Returns the current error, or null if there is no error.
  AppError? get error => _error;

  /// Maximum number of retry attempts for failed operations.
  static const int _maxRetries = 3;

  /// Base delay for exponential backoff (in milliseconds).
  static const int _baseDelayMs = 300;

  /// Loads spaces from the repository.
  ///
  /// By default, only non-archived spaces are loaded. Set [includeArchived]
  /// to true to load all spaces including archived ones.
  ///
  /// If no current space is set and spaces are loaded, attempts to restore
  /// the last selected space from preferences. If the persisted space is not
  /// found (e.g., it was deleted), falls back to the first non-archived space.
  ///
  /// Parameters:
  ///   - [includeArchived]: If true, includes archived spaces. Defaults to false.
  ///
  /// Example:
  /// ```dart
  /// await provider.loadSpaces();
  /// print('Loaded ${provider.spaces.length} spaces');
  /// ```
  Future<void> loadSpaces({bool includeArchived = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _spaces = await _executeWithRetry(
        () => _repository.getSpaces(includeArchived: includeArchived),
        'loadSpaces',
      );

      // Restore persisted space selection if no current space is set
      if (_currentSpace == null && _spaces.isNotEmpty) {
        try {
          final lastSpaceId = PreferencesService().getLastSelectedSpaceId();

          if (lastSpaceId != null) {
            // Try to find the persisted space in the loaded spaces
            try {
              _currentSpace = _spaces.firstWhere((s) => s.id == lastSpaceId);
            } catch (e) {
              // Persisted space not found (was deleted), clear the stale preference
              await PreferencesService().clearLastSelectedSpaceId();
              // Fall back to first space
              _currentSpace = _spaces.first;
            }
          } else {
            // No persisted space, use first space
            _currentSpace = _spaces.first;
          }
        } catch (e) {
          // If preference loading fails, fall back to first space
          debugPrint('Failed to restore persisted space selection: $e');
          _currentSpace = _spaces.first;
        }
      }

      _error = null;
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      _spaces = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new space to the repository and updates the state.
  ///
  /// The space is added to the repository and then added to the local
  /// list of spaces. The newly added space is automatically set as the
  /// current space and persisted to preferences. If an error occurs, the state is not updated.
  ///
  /// Parameters:
  ///   - [space]: The space to add
  ///
  /// Example:
  /// ```dart
  /// final newSpace = Space(
  ///   id: 'space-1',
  ///   name: 'Work',
  ///   icon: '💼',
  ///   color: '#FF5733',
  /// );
  /// await provider.addSpace(newSpace);
  /// ```
  Future<void> addSpace(Space space) async {
    _error = null;

    try {
      final createdSpace = await _executeWithRetry(
        () => _repository.createSpace(space),
        'addSpace',
      );
      _spaces = [..._spaces, createdSpace];
      _currentSpace = createdSpace;

      // Persist the newly created space as the current selection
      try {
        await PreferencesService().setLastSelectedSpaceId(createdSpace.id);
      } catch (e) {
        // Log error but don't fail the operation if persistence fails
        debugPrint('Failed to persist space selection: $e');
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
      rethrow;
    }
  }

  /// Updates an existing space in the repository and updates the state.
  ///
  /// The space is updated in the repository and then the local list
  /// is updated to reflect the changes. If the updated space is the
  /// current space, the current space is also updated.
  ///
  /// **Archival behavior**: When archiving a space, the persisted space ID
  /// is kept (not cleared). This allows archived spaces to be restored on
  /// next app start if `includeArchived: true` is used when loading spaces.
  /// This design prioritizes consistency over forcing users to select a new
  /// space after archiving.
  ///
  /// Parameters:
  ///   - [space]: The space to update with new values
  ///
  /// Example:
  /// ```dart
  /// final updatedSpace = space.copyWith(
  ///   name: 'Updated Work',
  ///   isArchived: true,
  /// );
  /// await provider.updateSpace(updatedSpace);
  /// ```
  Future<void> updateSpace(Space space) async {
    _error = null;

    try {
      final updatedSpace = await _executeWithRetry(
        () => _repository.updateSpace(space),
        'updateSpace',
      );
      final index = _spaces.indexWhere((s) => s.id == space.id);
      if (index != -1) {
        _spaces = [
          ..._spaces.sublist(0, index),
          updatedSpace,
          ..._spaces.sublist(index + 1),
        ];
      }

      // Update current space if it's the one being updated
      if (_currentSpace?.id == space.id) {
        _currentSpace = updatedSpace;
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Deletes a space from the repository and updates the state.
  ///
  /// The space is removed from the repository and then removed from
  /// the local list of spaces. If the deleted space was persisted as the
  /// last selected space, the persisted ID is cleared to prevent attempting
  /// to restore a deleted space on next app start.
  ///
  /// IMPORTANT: Cannot delete the current space. Either switch to a different
  /// space first, or the operation will fail with an error.
  ///
  /// Parameters:
  ///   - [id]: The ID of the space to delete
  ///
  /// Example:
  /// ```dart
  /// await provider.deleteSpace('space-1');
  /// ```
  Future<void> deleteSpace(String id) async {
    _error = null;

    // Prevent deleting current space
    if (_currentSpace?.id == id) {
      _error = AppError.validation(
        message: 'Cannot delete the current space',
        userMessage:
            'Cannot delete the current space. Please switch to another space first.',
      );
      notifyListeners();
      return;
    }

    try {
      await _executeWithRetry(() => _repository.deleteSpace(id), 'deleteSpace');
      _spaces = _spaces.where((space) => space.id != id).toList();

      // Clear persisted space ID if we're deleting the persisted space
      try {
        final persistedSpaceId = PreferencesService().getLastSelectedSpaceId();
        if (persistedSpaceId == id) {
          await PreferencesService().clearLastSelectedSpaceId();
        }
      } catch (e) {
        // Log error but don't fail the operation if preference cleanup fails
        debugPrint('Failed to clear persisted space ID: $e');
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Switches the current active space.
  ///
  /// Changes the current space to the space with the given ID and persists
  /// the selection. If the space does not exist in the loaded spaces, an error is set.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to switch to
  ///
  /// Example:
  /// ```dart
  /// await provider.switchSpace('space-2');
  /// print('Switched to: ${provider.currentSpace?.name}');
  /// ```
  Future<void> switchSpace(String spaceId) async {
    _error = null;

    try {
      final space = _spaces.firstWhere(
        (s) => s.id == spaceId,
        orElse: () => throw Exception('Space with id $spaceId not found'),
      );

      _currentSpace = space;

      // Persist the space selection
      try {
        await PreferencesService().setLastSelectedSpaceId(spaceId);
      } catch (e) {
        // Log error but don't fail the operation if persistence fails
        debugPrint('Failed to persist space selection: $e');
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      if (e is AppError) {
        _error = e;
      } else {
        _error = AppError.fromException(e);
      }
      notifyListeners();
    }
  }

  /// Gets the calculated item count for a space.
  ///
  /// This method returns the actual count of items (notes, todo lists, and
  /// regular lists) that belong to the specified space by querying the
  /// database directly. The count is calculated on-demand and represents
  /// the single source of truth for space item counts.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to get the count for
  ///
  /// Returns the calculated item count for the space.
  ///
  /// Example:
  /// ```dart
  /// final count = await provider.getSpaceItemCount('space-1');
  /// print('Space has $count items');
  /// ```
  Future<int> getSpaceItemCount(String spaceId) async {
    try {
      return await _executeWithRetry(
        () => _repository.getItemCount(spaceId),
        'getSpaceItemCount',
      );
    } catch (e) {
      // Log error but return 0 as fallback
      debugPrint('Failed to get item count for space $spaceId: $e');
      return 0;
    }
  }

  /// Clears any current error message.
  ///
  /// This is useful for dismissing error messages in the UI.
  ///
  /// Example:
  /// ```dart
  /// provider.clearError();
  /// ```
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Executes an operation with retry logic.
  ///
  /// Implements exponential backoff for transient failures.
  /// Only retries operations that throw retryable errors.
  ///
  /// Parameters:
  ///   - [operation]: The async operation to execute
  ///   - [operationName]: Name of the operation for error logging
  ///
  /// Returns the result of the operation.
  /// Throws the last error if all retry attempts fail.
  Future<T> _executeWithRetry<T>(
    Future<T> Function() operation,
    String operationName,
  ) async {
    int attempts = 0;
    AppError? lastError;

    while (attempts < _maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        lastError = AppError.fromException(e);

        // Only retry if the error is retryable and we have attempts left
        if (lastError.isRetryable && attempts < _maxRetries) {
          // Exponential backoff: delay increases with each attempt
          final delayMs = _baseDelayMs * (1 << (attempts - 1));
          await Future<void>.delayed(Duration(milliseconds: delayMs));
          continue;
        }

        // Non-retryable error or max retries reached
        throw lastError;
      }
    }

    // This should never be reached, but throw the last error just in case
    throw lastError ??
        AppError.unknown(message: 'Unknown error in $operationName');
  }
}
