import '../models/note_model.dart';
import 'base_repository.dart';

/// Repository for managing Note entities in Supabase.
///
/// Provides CRUD operations for notes, which are standalone content items
/// for documentation and free-form text. Uses Supabase 'notes' table with RLS policies.
class NoteRepository extends BaseRepository {
  /// Creates a new note in Supabase.
  ///
  /// Automatically calculates and assigns the next sortOrder value for the note
  /// within its space. The sortOrder is space-scoped, starting at 0 for the first
  /// note in a space and incrementing for each subsequent note.
  /// Automatically sets the user_id from the authenticated user.
  ///
  /// Parameters:
  ///   - [note]: The note to be created
  ///
  /// Returns:
  ///   The created note with assigned sortOrder
  ///
  /// Throws:
  ///   Exception if user is not authenticated or database operation fails
  ///
  /// Example:
  /// ```dart
  /// final note = Note(
  ///   id: 'note-1',
  ///   title: 'Meeting Notes',
  ///   content: 'Discussion points from today\'s meeting...',
  ///   spaceId: 'space-1',
  ///   userId: 'user-123',
  ///   tags: ['work', 'meetings'],
  /// );
  /// final created = await repository.create(note);
  /// // created.sortOrder will be 0 for first note in space, 1 for second, etc.
  /// ```
  Future<Note> create(Note note) async {
    return executeQuery(() async {
      // Calculate next sortOrder for this space
      final notesInSpace = await getBySpace(note.spaceId);
      final maxSortOrder = notesInSpace.isEmpty
          ? -1
          : notesInSpace
                .map((n) => n.sortOrder)
                .reduce((a, b) => a > b ? a : b);
      final nextSortOrder = maxSortOrder + 1;

      // Create note with calculated sortOrder
      final noteWithSortOrder = note.copyWith(sortOrder: nextSortOrder);
      final data = noteWithSortOrder.toJson();
      data['user_id'] = userId; // Ensure correct user_id

      final response = await supabase
          .from('notes')
          .insert(data)
          .select()
          .single();

      return Note.fromJson(response);
    });
  }

  /// Retrieves a single note by its ID.
  ///
  /// Returns null if the note does not exist or user doesn't have access.
  /// RLS policies ensure users can only access their own notes.
  ///
  /// Parameters:
  ///   - [id]: The ID of the note to retrieve
  ///
  /// Returns:
  ///   The note with the given ID, or null if not found
  ///
  /// Throws:
  ///   Exception if user is not authenticated or database operation fails
  ///
  /// Example:
  /// ```dart
  /// final note = await repository.getById('note-1');
  /// if (note != null) {
  ///   print('Found: ${note.title}');
  /// }
  /// ```
  Future<Note?> getById(String id) async {
    return executeQuery(() async {
      final response = await supabase
          .from('notes')
          .select()
          .eq('id', id)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return Note.fromJson(response);
    });
  }

  /// Retrieves all notes belonging to a specific space.
  ///
  /// Filters notes by their space_id and orders by sort_order.
  /// RLS policies ensure users can only access their own notes.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to filter by
  ///
  /// Returns:
  ///   A list of notes belonging to the specified space
  ///
  /// Throws:
  ///   Exception if user is not authenticated or database operation fails
  ///
  /// Example:
  /// ```dart
  /// final workNotes = await repository.getBySpace('work-space-1');
  /// print('Found ${workNotes.length} notes');
  /// ```
  Future<List<Note>> getBySpace(String spaceId) async {
    return executeQuery(() async {
      final response = await supabase
          .from('notes')
          .select()
          .eq('space_id', spaceId)
          .eq('user_id', userId)
          .order('sort_order', ascending: true);

      return (response as List)
          .map((json) => Note.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  /// Updates an existing note in Supabase.
  ///
  /// Automatically updates the updated_at timestamp to the current time.
  /// RLS policies ensure users can only update their own notes.
  ///
  /// Parameters:
  ///   - [note]: The note to update with new values
  ///
  /// Returns:
  ///   The updated note with the new updated_at timestamp
  ///
  /// Throws:
  ///   Exception if note doesn't exist, user doesn't have access, or operation fails
  ///
  /// Example:
  /// ```dart
  /// final updated = note.copyWith(
  ///   title: 'Updated Title',
  ///   content: 'Updated content...',
  /// );
  /// final result = await repository.update(updated);
  /// ```
  Future<Note> update(Note note) async {
    return executeQuery(() async {
      // Update the updatedAt timestamp
      final updatedNote = note.copyWith(updatedAt: DateTime.now());
      final data = updatedNote.toJson();

      final response = await supabase
          .from('notes')
          .update(data)
          .eq('id', note.id)
          .eq('user_id', userId)
          .select()
          .single();

      return Note.fromJson(response);
    });
  }

  /// Deletes a note from Supabase.
  ///
  /// RLS policies ensure users can only delete their own notes.
  ///
  /// Parameters:
  ///   - [id]: The ID of the note to delete
  ///
  /// Throws:
  ///   Exception if user doesn't have access or operation fails
  ///
  /// Example:
  /// ```dart
  /// await repository.delete('note-1');
  /// ```
  Future<void> delete(String id) async {
    return executeQuery(() async {
      await supabase.from('notes').delete().eq('id', id).eq('user_id', userId);
    });
  }

  /// Deletes all notes belonging to a specific space.
  ///
  /// RLS policies ensure users can only delete their own notes.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space
  ///
  /// Returns:
  ///   The number of notes deleted
  ///
  /// Throws:
  ///   Exception if user doesn't have access or operation fails
  ///
  /// Example:
  /// ```dart
  /// final count = await repository.deleteAllInSpace('space-1');
  /// print('Deleted $count notes');
  /// ```
  Future<int> deleteAllInSpace(String spaceId) async {
    return executeQuery(() async {
      final notes = await getBySpace(spaceId);
      await supabase
          .from('notes')
          .delete()
          .eq('space_id', spaceId)
          .eq('user_id', userId);
      return notes.length;
    });
  }

  /// Counts the number of notes in a specific space.
  ///
  /// RLS policies ensure users can only count their own notes.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space
  ///
  /// Returns:
  ///   The number of notes in the space
  ///
  /// Throws:
  ///   Exception if user is not authenticated or database operation fails
  ///
  /// Example:
  /// ```dart
  /// final count = await repository.countBySpace('space-1');
  /// print('Space has $count notes');
  /// ```
  Future<int> countBySpace(String spaceId) async {
    return executeQuery(() async {
      final response = await supabase
          .from('notes')
          .select()
          .eq('space_id', spaceId)
          .eq('user_id', userId);

      return (response as List).length;
    });
  }

  /// Retrieves all notes with a specific tag.
  ///
  /// Uses PostgreSQL array operations to filter by tag.
  /// RLS policies ensure users can only access their own notes.
  ///
  /// Parameters:
  ///   - [tag]: The tag to filter by
  ///
  /// Returns:
  ///   A list of notes that have the specified tag
  ///
  /// Throws:
  ///   Exception if user is not authenticated or database operation fails
  ///
  /// Example:
  /// ```dart
  /// final workNotes = await repository.getByTag('work');
  /// ```
  Future<List<Note>> getByTag(String tag) async {
    return executeQuery(() async {
      final response = await supabase
          .from('notes')
          .select()
          .contains('tags', [tag])
          .eq('user_id', userId)
          .order('sort_order', ascending: true);

      return (response as List)
          .map((json) => Note.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  /// Searches notes by title or content.
  ///
  /// Performs a case-insensitive search using PostgreSQL's ILIKE operator.
  /// RLS policies ensure users can only search their own notes.
  ///
  /// Parameters:
  ///   - [query]: The search query string
  ///
  /// Returns:
  ///   A list of notes that match the search query
  ///
  /// Throws:
  ///   Exception if user is not authenticated or database operation fails
  ///
  /// Example:
  /// ```dart
  /// final results = await repository.search('meeting');
  /// ```
  Future<List<Note>> search(String query) async {
    return executeQuery(() async {
      // Using .or() with .ilike() for case-insensitive search
      final response = await supabase
          .from('notes')
          .select()
          .eq('user_id', userId)
          .or('title.ilike.%$query%,content.ilike.%$query%')
          .order('sort_order', ascending: true);

      return (response as List)
          .map((json) => Note.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  /// Updates the sort orders for multiple notes in a batch.
  ///
  /// Used for drag-and-drop reordering. Updates all notes with their new
  /// sort_order values in a single operation.
  /// RLS policies ensure users can only update their own notes.
  ///
  /// Parameters:
  ///   - [notes]: List of notes with updated sortOrder values
  ///
  /// Throws:
  ///   Exception if user doesn't have access or operation fails
  ///
  /// Example:
  /// ```dart
  /// final reorderedNotes = notes
  ///   .asMap()
  ///   .entries
  ///   .map((entry) => entry.value.copyWith(sortOrder: entry.key))
  ///   .toList();
  /// await repository.updateSortOrders(reorderedNotes);
  /// ```
  Future<void> updateSortOrders(List<Note> notes) async {
    return executeQuery(() async {
      final updates = notes.map((note) {
        final data = note.toJson();
        data['user_id'] = userId; // Ensure correct user_id
        return data;
      }).toList();

      // Use upsert to update multiple records at once
      await supabase.from('notes').upsert(updates);
    });
  }
}
