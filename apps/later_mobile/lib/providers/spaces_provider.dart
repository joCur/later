import 'package:flutter/foundation.dart';
import '../core/error/app_error.dart';
import '../data/local/preferences_service.dart';
import '../data/models/space_model.dart';
import '../data/repositories/space_repository.dart';

/// Provider for managing Space state in the application.
///
/// This provider handles all space-related operations including loading,
/// creating, updating, and deleting spaces. It also manages the current
/// active space and item count updates. It manages loading states,
/// error states, and notifies listeners of state changes.
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
  /// If no current space is set and spaces are loaded, the first
  /// non-archived space will be set as the current space.
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

      // Set first non-archived space as current if none is selected
      if (_currentSpace == null && _spaces.isNotEmpty) {
        _currentSpace = _spaces.first;
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
    }
  }

  /// Updates an existing space in the repository and updates the state.
  ///
  /// The space is updated in the repository and then the local list
  /// is updated to reflect the changes. If the updated space is the
  /// current space, the current space is also updated.
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
  /// the local list of spaces. If an error occurs, the state is not updated.
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
        userMessage: 'Cannot delete the current space. Please switch to another space first.',
      );
      notifyListeners();
      return;
    }

    try {
      await _executeWithRetry(
        () => _repository.deleteSpace(id),
        'deleteSpace',
      );
      _spaces = _spaces.where((space) => space.id != id).toList();
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

  /// Increments the item count for a space by 1.
  ///
  /// This should be called when an item is added to the space.
  /// Updates both the space in the list and the current space if applicable.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to increment
  ///
  /// Example:
  /// ```dart
  /// await provider.incrementSpaceItemCount('space-1');
  /// ```
  Future<void> incrementSpaceItemCount(String spaceId) async {
    _error = null;

    try {
      await _executeWithRetry(
        () => _repository.incrementItemCount(spaceId),
        'incrementSpaceItemCount',
      );

      // Reload the updated space
      final updatedSpace = await _executeWithRetry(
        () => _repository.getSpaceById(spaceId),
        'getSpaceById',
      );
      if (updatedSpace != null) {
        final index = _spaces.indexWhere((s) => s.id == spaceId);
        if (index != -1) {
          _spaces = [
            ..._spaces.sublist(0, index),
            updatedSpace,
            ..._spaces.sublist(index + 1),
          ];
        }

        // Update current space if it's the one being incremented
        if (_currentSpace?.id == spaceId) {
          _currentSpace = updatedSpace;
        }
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

  /// Decrements the item count for a space by 1.
  ///
  /// This should be called when an item is removed from the space.
  /// The count will not go below 0.
  /// Updates both the space in the list and the current space if applicable.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to decrement
  ///
  /// Example:
  /// ```dart
  /// await provider.decrementSpaceItemCount('space-1');
  /// ```
  Future<void> decrementSpaceItemCount(String spaceId) async {
    _error = null;

    try {
      await _executeWithRetry(
        () => _repository.decrementItemCount(spaceId),
        'decrementSpaceItemCount',
      );

      // Reload the updated space
      final updatedSpace = await _executeWithRetry(
        () => _repository.getSpaceById(spaceId),
        'getSpaceById',
      );
      if (updatedSpace != null) {
        final index = _spaces.indexWhere((s) => s.id == spaceId);
        if (index != -1) {
          _spaces = [
            ..._spaces.sublist(0, index),
            updatedSpace,
            ..._spaces.sublist(index + 1),
          ];
        }

        // Update current space if it's the one being decremented
        if (_currentSpace?.id == spaceId) {
          _currentSpace = updatedSpace;
        }
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
    throw lastError ?? AppError.unknown(message: 'Unknown error in $operationName');
  }
}
