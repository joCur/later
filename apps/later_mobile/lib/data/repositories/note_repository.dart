import 'package:hive/hive.dart';
import '../models/item_model.dart';

/// Repository for managing Note entities (Item model) in Hive local storage.
///
/// Provides CRUD operations for notes, which are standalone content items
/// for documentation and free-form text. Uses Hive box 'notes' for persistence.
class NoteRepository {
  /// Gets the Hive box for notes
  Box<Item> get _box => Hive.box<Item>('notes');

  /// Creates a new note in the local storage.
  ///
  /// Stores the note using its ID as the key in the Hive box.
  ///
  /// Parameters:
  ///   - [note]: The note to be created
  ///
  /// Returns:
  ///   The created note
  ///
  /// Example:
  /// ```dart
  /// final note = Item(
  ///   id: 'note-1',
  ///   title: 'Meeting Notes',
  ///   content: 'Discussion points from today\'s meeting...',
  ///   spaceId: 'space-1',
  ///   tags: ['work', 'meetings'],
  /// );
  /// final created = await repository.create(note);
  /// ```
  Future<Item> create(Item note) async {
    try {
      await _box.put(note.id, note);
      return note;
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  /// Retrieves a single note by its ID.
  ///
  /// Returns null if the note does not exist.
  ///
  /// Parameters:
  ///   - [id]: The ID of the note to retrieve
  ///
  /// Returns:
  ///   The note with the given ID, or null if not found
  ///
  /// Example:
  /// ```dart
  /// final note = await repository.getById('note-1');
  /// if (note != null) {
  ///   print('Found: ${note.title}');
  /// }
  /// ```
  Future<Item?> getById(String id) async {
    try {
      return _box.get(id);
    } catch (e) {
      throw Exception('Failed to get note by id: $e');
    }
  }

  /// Retrieves all notes belonging to a specific space.
  ///
  /// Filters notes by their spaceId property.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to filter by
  ///
  /// Returns:
  ///   A list of notes belonging to the specified space
  ///
  /// Example:
  /// ```dart
  /// final workNotes = await repository.getBySpace('work-space-1');
  /// print('Found ${workNotes.length} notes');
  /// ```
  Future<List<Item>> getBySpace(String spaceId) async {
    try {
      return _box.values.where((note) => note.spaceId == spaceId).toList();
    } catch (e) {
      throw Exception('Failed to get notes by space: $e');
    }
  }

  /// Updates an existing note in local storage.
  ///
  /// Automatically updates the updatedAt timestamp to the current time.
  /// Throws an exception if the note does not exist.
  ///
  /// Parameters:
  ///   - [note]: The note to update with new values
  ///
  /// Returns:
  ///   The updated note with the new updatedAt timestamp
  ///
  /// Throws:
  ///   Exception if the note with the given ID does not exist
  ///
  /// Example:
  /// ```dart
  /// final updated = note.copyWith(
  ///   title: 'Updated Title',
  ///   content: 'Updated content...',
  /// );
  /// final result = await repository.update(updated);
  /// ```
  Future<Item> update(Item note) async {
    try {
      // Check if the note exists
      if (!_box.containsKey(note.id)) {
        throw Exception('Note with id ${note.id} does not exist');
      }

      // Update the updatedAt timestamp
      final updatedNote = note.copyWith(updatedAt: DateTime.now());

      await _box.put(updatedNote.id, updatedNote);
      return updatedNote;
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  /// Deletes a note from local storage.
  ///
  /// If the note does not exist, this operation completes without error.
  ///
  /// Parameters:
  ///   - [id]: The ID of the note to delete
  ///
  /// Example:
  /// ```dart
  /// await repository.delete('note-1');
  /// ```
  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  /// Deletes all notes belonging to a specific space.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space
  ///
  /// Returns:
  ///   The number of notes deleted
  ///
  /// Example:
  /// ```dart
  /// final count = await repository.deleteAllInSpace('space-1');
  /// print('Deleted $count notes');
  /// ```
  Future<int> deleteAllInSpace(String spaceId) async {
    try {
      final notes = await getBySpace(spaceId);
      for (final note in notes) {
        await delete(note.id);
      }
      return notes.length;
    } catch (e) {
      throw Exception('Failed to delete all notes in space: $e');
    }
  }

  /// Counts the number of notes in a specific space.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space
  ///
  /// Returns:
  ///   The number of notes in the space
  ///
  /// Example:
  /// ```dart
  /// final count = await repository.countBySpace('space-1');
  /// print('Space has $count notes');
  /// ```
  Future<int> countBySpace(String spaceId) async {
    try {
      final notes = await getBySpace(spaceId);
      return notes.length;
    } catch (e) {
      throw Exception('Failed to count notes in space: $e');
    }
  }

  /// Retrieves all notes with a specific tag.
  ///
  /// Parameters:
  ///   - [tag]: The tag to filter by
  ///
  /// Returns:
  ///   A list of notes that have the specified tag
  ///
  /// Example:
  /// ```dart
  /// final workNotes = await repository.getByTag('work');
  /// ```
  Future<List<Item>> getByTag(String tag) async {
    try {
      return _box.values.where((note) => note.tags.contains(tag)).toList();
    } catch (e) {
      throw Exception('Failed to get notes by tag: $e');
    }
  }

  /// Searches notes by title or content.
  ///
  /// Performs a case-insensitive search across both title and content fields.
  ///
  /// Parameters:
  ///   - [query]: The search query string
  ///
  /// Returns:
  ///   A list of notes that match the search query
  ///
  /// Example:
  /// ```dart
  /// final results = await repository.search('meeting');
  /// ```
  Future<List<Item>> search(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      return _box.values.where((note) {
        final titleMatch = note.title.toLowerCase().contains(lowerQuery);
        final contentMatch =
            note.content?.toLowerCase().contains(lowerQuery) ?? false;
        return titleMatch || contentMatch;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search notes: $e');
    }
  }
}
