import '../../data/repositories/note_repository.dart';
import '../../domain/models/note.dart';
import '../../../../core/error/error.dart';

/// Application service for note business logic.
///
/// Coordinates note operations with validation and business rules.
/// Delegates data access to NoteRepository.
class NoteService {
  NoteService({required NoteRepository repository}) : _repository = repository;

  final NoteRepository _repository;

  /// Gets all notes for a specific space.
  ///
  /// Notes are sorted by updatedAt timestamp in descending order (most recent first).
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to load notes from
  ///
  /// Returns list of notes sorted by updatedAt (most recent first).
  ///
  /// Throws [AppError] if the operation fails.
  Future<List<Note>> getNotesForSpace(String spaceId) async {
    try {
      final notes = await _repository.getBySpace(spaceId);
      // Sort by updatedAt descending (most recent first)
      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return notes;
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError(
        code: ErrorCode.unknownError,
        message: 'Failed to load notes: ${e.toString()}',
        technicalDetails: e.toString(),
      );
    }
  }

  /// Creates a new note with validation.
  ///
  /// Validates that the note title is not empty before creating.
  ///
  /// Parameters:
  ///   - [note]: The note to create
  ///
  /// Returns the created note with assigned sortOrder.
  ///
  /// Throws [AppError] if validation fails or operation fails.
  Future<Note> createNote(Note note) async {
    // Validate title is not empty
    if (note.title.trim().isEmpty) {
      throw ValidationErrorMapper.requiredField('Note title');
    }

    try {
      return await _repository.create(note);
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError(
        code: ErrorCode.unknownError,
        message: 'Failed to create note: ${e.toString()}',
        technicalDetails: e.toString(),
      );
    }
  }

  /// Updates an existing note with validation.
  ///
  /// Validates that the note title is not empty before updating.
  /// Automatically updates the updatedAt timestamp.
  ///
  /// Parameters:
  ///   - [note]: The note to update with new values
  ///
  /// Returns the updated note with new updatedAt timestamp.
  ///
  /// Throws [AppError] if validation fails or operation fails.
  Future<Note> updateNote(Note note) async {
    // Validate title is not empty
    if (note.title.trim().isEmpty) {
      throw ValidationErrorMapper.requiredField('Note title');
    }

    try {
      return await _repository.update(note);
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError(
        code: ErrorCode.unknownError,
        message: 'Failed to update note: ${e.toString()}',
        technicalDetails: e.toString(),
      );
    }
  }

  /// Deletes a note from the repository.
  ///
  /// Parameters:
  ///   - [id]: The ID of the note to delete
  ///
  /// Throws [AppError] if the operation fails.
  Future<void> deleteNote(String id) async {
    try {
      await _repository.delete(id);
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError(
        code: ErrorCode.unknownError,
        message: 'Failed to delete note: ${e.toString()}',
        technicalDetails: e.toString(),
      );
    }
  }

  /// Toggles the favorite status of a note.
  ///
  /// Note: This is a placeholder for future functionality.
  /// The Note model does not currently have a favorite field.
  ///
  /// Parameters:
  ///   - [id]: The ID of the note to toggle
  ///
  /// Throws [AppError] indicating feature not implemented.
  Future<Note> toggleFavorite(String id) async {
    throw const AppError(
      code: ErrorCode.unknownError,
      message: 'Favorite feature not yet implemented for notes',
      technicalDetails: 'Note model does not have isFavorite field',
    );
  }

  /// Archives a note.
  ///
  /// Note: This is a placeholder for future functionality.
  /// The Note model does not currently have an archived field.
  ///
  /// Parameters:
  ///   - [id]: The ID of the note to archive
  ///
  /// Throws [AppError] indicating feature not implemented.
  Future<Note> archiveNote(String id) async {
    throw const AppError(
      code: ErrorCode.unknownError,
      message: 'Archive feature not yet implemented for notes',
      technicalDetails: 'Note model does not have isArchived field',
    );
  }

  /// Unarchives a note.
  ///
  /// Note: This is a placeholder for future functionality.
  /// The Note model does not currently have an archived field.
  ///
  /// Parameters:
  ///   - [id]: The ID of the note to unarchive
  ///
  /// Throws [AppError] indicating feature not implemented.
  Future<Note> unarchiveNote(String id) async {
    throw const AppError(
      code: ErrorCode.unknownError,
      message: 'Archive feature not yet implemented for notes',
      technicalDetails: 'Note model does not have isArchived field',
    );
  }
}
