// ignore_for_file: depend_on_referenced_packages
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../data/local/preferences_service.dart';
import '../../domain/models/space.dart';
import 'spaces_controller.dart';

part 'current_space_controller.g.dart';

/// Controller for managing current space selection.
///
/// Manages AsyncValue with current space for the active space.
/// Persists selection to SharedPreferences.
/// Single source of truth for current space selection.
/// keepAlive: true prevents disposal and maintains current space state.
@Riverpod(keepAlive: true)
class CurrentSpaceController extends _$CurrentSpaceController {
  @override
  Future<Space?> build() async {
    // Try to restore persisted space selection
    final lastSpaceId = PreferencesService().getLastSelectedSpaceId();

    if (lastSpaceId != null) {
      // Load all spaces and find the persisted one
      final spacesState = await ref.watch(spacesControllerProvider.future);

      try {
        return spacesState.firstWhere((s) => s.id == lastSpaceId);
      } catch (e) {
        // Persisted space not found (was deleted), clear the stale preference
        await PreferencesService().clearLastSelectedSpaceId();
        // Return first space if available
        return spacesState.isNotEmpty ? spacesState.first : null;
      }
    }

    // No persisted space, use first space if available
    final spacesState = await ref.watch(spacesControllerProvider.future);
    return spacesState.isNotEmpty ? spacesState.first : null;
  }

  /// Switches to a different space.
  ///
  /// Updates the current space and persists the selection to SharedPreferences.
  ///
  /// Parameters:
  ///   - [space]: The space to switch to
  Future<void> switchSpace(Space space) async {
    try {
      // Update state
      state = AsyncValue.data(space);

      // Persist the selection
      if (ref.mounted) {
        try {
          await PreferencesService().setLastSelectedSpaceId(space.id);
        } catch (e) {
          // Log error but don't fail the operation if persistence fails
          // ignore: avoid_print
          print('Failed to persist space selection: $e');
        }
      }
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Clears the current space selection.
  ///
  /// Used when a space is deleted or archived.
  Future<void> clearCurrentSpace() async {
    try {
      state = const AsyncValue.data(null);

      // Clear persisted selection
      if (ref.mounted) {
        try {
          await PreferencesService().clearLastSelectedSpaceId();
        } catch (e) {
          // Log error but don't fail the operation if persistence fails
          // ignore: avoid_print
          print('Failed to clear persisted space selection: $e');
        }
      }
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Sets the current space to the first available space.
  ///
  /// Used after deleting or archiving the current space.
  Future<void> setToFirstAvailableSpace() async {
    try {
      final spacesState = await ref.watch(spacesControllerProvider.future);

      if (spacesState.isNotEmpty) {
        await switchSpace(spacesState.first);
      } else {
        await clearCurrentSpace();
      }
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }
}
