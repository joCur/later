// ignore_for_file: depend_on_referenced_packages
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../application/providers.dart';
import '../../domain/models/note.dart';

part 'notes_controller.g.dart';

/// Controller for managing notes state for a specific space.
///
/// Manages AsyncValue with list of notes for a space.
/// Provides methods for CRUD operations on notes.
/// Uses NoteService for business logic.
///
/// This is a family provider that takes a spaceId parameter,
/// so each space has its own independent notes controller.
@riverpod
class NotesController extends _$NotesController {
  @override
  Future<List<Note>> build(String spaceId) async {
    // Load notes for this space on initialization
    final service = ref.read(noteServiceProvider);
    return service.getNotesForSpace(spaceId);
  }

  /// Reloads notes for the current space.
  Future<void> refresh() async {
    state = const AsyncValue.loading();

    final service = ref.read(noteServiceProvider);
    state = await AsyncValue.guard(() => service.getNotesForSpace(spaceId));
  }

  /// Creates a new note in the current space.
  ///
  /// Validates and creates the note, then adds it to the current state.
  ///
  /// Parameters:
  ///   - [note]: The note to create
  Future<void> createNote(Note note) async {
    final service = ref.read(noteServiceProvider);

    try {
      final created = await service.createNote(note);

      // Check if still mounted
      if (!ref.mounted) return;

      // Add to current state (at beginning since sorted by updatedAt desc)
      state = state.whenData((notes) => [created, ...notes]);
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Updates an existing note.
  ///
  /// Validates and updates the note, then refreshes the note in the current state.
  ///
  /// Parameters:
  ///   - [note]: The note to update with new values
  Future<void> updateNote(Note note) async {
    final service = ref.read(noteServiceProvider);

    try {
      final updated = await service.updateNote(note);

      // Check if still mounted
      if (!ref.mounted) return;

      // Update in current state
      state = state.whenData((notes) {
        final index = notes.indexWhere((n) => n.id == note.id);
        if (index == -1) return notes;

        // Create new list with updated note
        final updatedNotes = [
          ...notes.sublist(0, index),
          updated,
          ...notes.sublist(index + 1),
        ];

        // Re-sort by updatedAt descending
        updatedNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return updatedNotes;
      });
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Deletes a note.
  ///
  /// Removes the note from the repository and updates the state.
  ///
  /// Parameters:
  ///   - [id]: The ID of the note to delete
  Future<void> deleteNote(String id) async {
    final service = ref.read(noteServiceProvider);

    try {
      await service.deleteNote(id);

      // Check if still mounted
      if (!ref.mounted) return;

      // Remove from current state
      state = state.whenData((notes) => notes.where((n) => n.id != id).toList());
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Toggles the favorite status of a note.
  ///
  /// Note: This is a placeholder for future functionality.
  /// The Note model does not currently have a favorite field.
  ///
  /// Parameters:
  ///   - [id]: The ID of the note to toggle
  Future<void> toggleFavorite(String id) async {
    final service = ref.read(noteServiceProvider);

    try {
      final updated = await service.toggleFavorite(id);

      // Check if still mounted
      if (!ref.mounted) return;

      // Update in current state
      state = state.whenData((notes) {
        final index = notes.indexWhere((n) => n.id == id);
        if (index == -1) return notes;

        return [
          ...notes.sublist(0, index),
          updated,
          ...notes.sublist(index + 1),
        ];
      });
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Archives a note.
  ///
  /// Note: This is a placeholder for future functionality.
  /// The Note model does not currently have an archived field.
  ///
  /// Parameters:
  ///   - [id]: The ID of the note to archive
  Future<void> archiveNote(String id) async {
    final service = ref.read(noteServiceProvider);

    try {
      final updated = await service.archiveNote(id);

      // Check if still mounted
      if (!ref.mounted) return;

      // Update in current state
      state = state.whenData((notes) {
        final index = notes.indexWhere((n) => n.id == id);
        if (index == -1) return notes;

        return [
          ...notes.sublist(0, index),
          updated,
          ...notes.sublist(index + 1),
        ];
      });
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Unarchives a note.
  ///
  /// Note: This is a placeholder for future functionality.
  /// The Note model does not currently have an archived field.
  ///
  /// Parameters:
  ///   - [id]: The ID of the note to unarchive
  Future<void> unarchiveNote(String id) async {
    final service = ref.read(noteServiceProvider);

    try {
      final updated = await service.unarchiveNote(id);

      // Check if still mounted
      if (!ref.mounted) return;

      // Update in current state
      state = state.whenData((notes) {
        final index = notes.indexWhere((n) => n.id == id);
        if (index == -1) return notes;

        return [
          ...notes.sublist(0, index),
          updated,
          ...notes.sublist(index + 1),
        ];
      });
    } catch (e) {
      // Update state with error
      if (ref.mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }
}
