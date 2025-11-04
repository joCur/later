import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:later_mobile/data/models/note_model.dart';
import 'package:later_mobile/data/repositories/note_repository.dart';

void main() {
  group('NoteRepository Tests', () {
    late NoteRepository repository;
    late Box<Item> noteBox;

    setUp(() async {
      // Initialize Hive in test directory
      const tempDir = '.dart_tool/test/hive';
      Hive.init(tempDir);

      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ItemAdapter());
      }

      // Open box
      noteBox = await Hive.openBox<Item>('notes');
      repository = NoteRepository();
    });

    tearDown(() async {
      // Clear and close the box
      await noteBox.clear();
      await noteBox.close();
      await Hive.deleteBoxFromDisk('notes');
    });

    /// Helper function to create a test Note (Item)
    Item createTestNote({
      String? id,
      String title = 'Meeting Notes',
      String? content,
      String spaceId = 'space-1',
      List<String>? tags,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? syncStatus,
    }) {
      return Item(
        id: id ?? 'note-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        content: content,
        spaceId: spaceId,
        tags: tags ?? [],
        createdAt: createdAt,
        updatedAt: updatedAt,
        syncStatus: syncStatus,
      );
    }

    group('CRUD operations', () {
      test('create() successfully stores a Note', () async {
        // Arrange
        final note = createTestNote(
          id: 'note-1',
          content: 'Discussion about project roadmap',
        );

        // Act
        final result = await repository.create(note);

        // Assert
        expect(result.id, equals('note-1'));
        expect(result.title, equals('Meeting Notes'));
        expect(result.content, equals('Discussion about project roadmap'));
        expect(noteBox.length, equals(1));
        expect(noteBox.get('note-1'), isNotNull);
      });

      test('create() assigns sortOrder 0 for first note in space', () async {
        // Arrange
        final note = createTestNote(id: 'note-1');

        // Act
        final result = await repository.create(note);

        // Assert
        expect(result.sortOrder, equals(0));
      });

      test('create() assigns incremental sortOrder for subsequent notes', () async {
        // Arrange
        final note1 = createTestNote(id: 'note-1');
        final note2 = createTestNote(id: 'note-2');
        final note3 = createTestNote(id: 'note-3');

        // Act
        final result1 = await repository.create(note1);
        final result2 = await repository.create(note2);
        final result3 = await repository.create(note3);

        // Assert
        expect(result1.sortOrder, equals(0));
        expect(result2.sortOrder, equals(1));
        expect(result3.sortOrder, equals(2));
      });

      test('create() uses space-scoped sortOrder values', () async {
        // Arrange - Create notes in different spaces
        final note1Space1 = createTestNote(id: 'note-1');
        final note2Space1 = createTestNote(id: 'note-2');
        final note1Space2 = createTestNote(id: 'note-3', spaceId: 'space-2');
        final note2Space2 = createTestNote(id: 'note-4', spaceId: 'space-2');

        // Act
        final result1Space1 = await repository.create(note1Space1);
        final result2Space1 = await repository.create(note2Space1);
        final result1Space2 = await repository.create(note1Space2);
        final result2Space2 = await repository.create(note2Space2);

        // Assert - Each space should have independent sortOrder sequence
        expect(result1Space1.sortOrder, equals(0));
        expect(result2Space1.sortOrder, equals(1));
        expect(result1Space2.sortOrder, equals(0)); // Restarts for new space
        expect(result2Space2.sortOrder, equals(1));
      });

      test('getById() returns existing Note', () async {
        // Arrange
        final note = createTestNote(
          id: 'note-1',
          title: 'Project Ideas',
          content: 'New features to implement',
        );
        await repository.create(note);

        // Act
        final result = await repository.getById('note-1');

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals('note-1'));
        expect(result.title, equals('Project Ideas'));
        expect(result.content, equals('New features to implement'));
      });

      test('getById() returns null for non-existent ID', () async {
        // Act
        final result = await repository.getById('non-existent');

        // Assert
        expect(result, isNull);
      });

      test('getBySpace() returns all Notes for a space', () async {
        // Arrange
        final note1 = createTestNote(id: 'note-1', title: 'Note 1');
        final note2 = createTestNote(id: 'note-2', title: 'Note 2');
        final note3 = createTestNote(
          id: 'note-3',
          spaceId: 'space-2',
          title: 'Note 3',
        );

        await repository.create(note1);
        await repository.create(note2);
        await repository.create(note3);

        // Act
        final result = await repository.getBySpace('space-1');

        // Assert
        expect(result.length, equals(2));
        expect(result.every((note) => note.spaceId == 'space-1'), isTrue);
        expect(
          result.map((note) => note.id),
          containsAll(['note-1', 'note-2']),
        );
      });

      test('getBySpace() returns empty list when no Notes exist', () async {
        // Act
        final result = await repository.getBySpace('space-1');

        // Assert
        expect(result, isEmpty);
      });

      test('update() updates existing Note and timestamp', () async {
        // Arrange
        final note = createTestNote(
          id: 'note-1',
          title: 'Original Title',
          content: 'Original content',
        );
        await repository.create(note);

        // Wait to ensure timestamp difference
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final updatedNote = note.copyWith(
          title: 'Updated Title',
          content: 'Updated content',
        );

        // Act
        final result = await repository.update(updatedNote);

        // Assert
        expect(result.title, equals('Updated Title'));
        expect(result.content, equals('Updated content'));
        expect(result.updatedAt.isAfter(note.updatedAt), isTrue);
        expect(noteBox.get('note-1')!.title, equals('Updated Title'));
      });

      test('update() throws exception when Note does not exist', () async {
        // Arrange
        final nonExistentNote = createTestNote(id: 'non-existent');

        // Act & Assert
        expect(() => repository.update(nonExistentNote), throwsException);
      });

      test('delete() removes Note', () async {
        // Arrange
        final note = createTestNote(id: 'note-1');
        await repository.create(note);
        expect(noteBox.length, equals(1));

        // Act
        await repository.delete('note-1');

        // Assert
        expect(noteBox.length, equals(0));
        expect(noteBox.get('note-1'), isNull);
      });

      test('delete() succeeds even if Note does not exist', () async {
        // Act & Assert - should not throw
        await repository.delete('non-existent');
        expect(noteBox.length, equals(0));
      });
    });

    group('Bulk operations', () {
      test('deleteAllInSpace() deletes all Notes in space', () async {
        // Arrange
        final note1 = createTestNote(id: 'note-1');
        final note2 = createTestNote(id: 'note-2');
        final note3 = createTestNote(id: 'note-3', spaceId: 'space-2');

        await repository.create(note1);
        await repository.create(note2);
        await repository.create(note3);

        // Act
        await repository.deleteAllInSpace('space-1');

        // Assert
        expect(noteBox.length, equals(1));
        expect(noteBox.get('note-3'), isNotNull);
      });

      test('deleteAllInSpace() returns correct count', () async {
        // Arrange
        final note1 = createTestNote(id: 'note-1');
        final note2 = createTestNote(id: 'note-2');

        await repository.create(note1);
        await repository.create(note2);

        // Act
        final count = await repository.deleteAllInSpace('space-1');

        // Assert
        expect(count, equals(2));
        expect(noteBox.length, equals(0));
      });

      test('deleteAllInSpace() returns 0 when space is empty', () async {
        // Act
        final count = await repository.deleteAllInSpace('empty-space');

        // Assert
        expect(count, equals(0));
      });

      test('countBySpace() returns correct count', () async {
        // Arrange
        final note1 = createTestNote(id: 'note-1');
        final note2 = createTestNote(id: 'note-2');
        final note3 = createTestNote(id: 'note-3', spaceId: 'space-2');

        await repository.create(note1);
        await repository.create(note2);
        await repository.create(note3);

        // Act
        final count1 = await repository.countBySpace('space-1');
        final count2 = await repository.countBySpace('space-2');

        // Assert
        expect(count1, equals(2));
        expect(count2, equals(1));
      });

      test('countBySpace() returns 0 for empty space', () async {
        // Act
        final count = await repository.countBySpace('empty-space');

        // Assert
        expect(count, equals(0));
      });
    });

    group('Enhanced operations', () {
      test('getByTag() returns notes with specific tag', () async {
        // Arrange
        final note1 = createTestNote(
          id: 'note-1',
          title: 'Work Note',
          tags: ['work', 'important'],
        );
        final note2 = createTestNote(
          id: 'note-2',
          title: 'Personal Note',
          tags: ['personal'],
        );
        final note3 = createTestNote(
          id: 'note-3',
          title: 'Another Work Note',
          tags: ['work', 'meeting'],
        );

        await repository.create(note1);
        await repository.create(note2);
        await repository.create(note3);

        // Act
        final workNotes = await repository.getByTag('work');
        final personalNotes = await repository.getByTag('personal');

        // Assert
        expect(workNotes.length, equals(2));
        expect(
          workNotes.map((note) => note.id),
          containsAll(['note-1', 'note-3']),
        );
        expect(personalNotes.length, equals(1));
        expect(personalNotes.first.id, equals('note-2'));
      });

      test('getByTag() returns empty list when no matches', () async {
        // Arrange
        final note = createTestNote(id: 'note-1', tags: ['work']);
        await repository.create(note);

        // Act
        final result = await repository.getByTag('personal');

        // Assert
        expect(result, isEmpty);
      });

      test('search() finds notes by title', () async {
        // Arrange
        final note1 = createTestNote(
          id: 'note-1',
          title: 'Meeting Notes for Monday',
        );
        final note2 = createTestNote(id: 'note-2', title: 'Project Ideas');
        final note3 = createTestNote(
          id: 'note-3',
          title: 'Team Meeting Agenda',
        );

        await repository.create(note1);
        await repository.create(note2);
        await repository.create(note3);

        // Act
        final result = await repository.search('meeting');

        // Assert
        expect(result.length, equals(2));
        expect(
          result.map((note) => note.id),
          containsAll(['note-1', 'note-3']),
        );
      });

      test('search() finds notes by content', () async {
        // Arrange
        final note1 = createTestNote(
          id: 'note-1',
          title: 'Note 1',
          content: 'Discuss the quarterly budget meeting',
        );
        final note2 = createTestNote(
          id: 'note-2',
          title: 'Note 2',
          content: 'Review project timeline',
        );
        final note3 = createTestNote(
          id: 'note-3',
          title: 'Note 3',
          content: 'Schedule budget review',
        );

        await repository.create(note1);
        await repository.create(note2);
        await repository.create(note3);

        // Act
        final result = await repository.search('budget');

        // Assert
        expect(result.length, equals(2));
        expect(
          result.map((note) => note.id),
          containsAll(['note-1', 'note-3']),
        );
      });

      test('search() is case-insensitive', () async {
        // Arrange
        final note = createTestNote(
          id: 'note-1',
          title: 'Important Meeting',
          content: 'Discussion about PROJECT roadmap',
        );
        await repository.create(note);

        // Act
        final result1 = await repository.search('MEETING');
        final result2 = await repository.search('project');
        final result3 = await repository.search('ImPoRtAnT');

        // Assert
        expect(result1.length, equals(1));
        expect(result2.length, equals(1));
        expect(result3.length, equals(1));
      });

      test('search() returns empty list when no matches', () async {
        // Arrange
        final note = createTestNote(id: 'note-1', content: 'Discussion points');
        await repository.create(note);

        // Act
        final result = await repository.search('budget');

        // Assert
        expect(result, isEmpty);
      });

      test('search() finds notes by both title and content', () async {
        // Arrange
        final note1 = createTestNote(
          id: 'note-1',
          title: 'Important Note',
          content: 'Some content here',
        );
        final note2 = createTestNote(
          id: 'note-2',
          title: 'Some Title',
          content: 'This is important content',
        );
        final note3 = createTestNote(
          id: 'note-3',
          title: 'Regular Note',
          content: 'Regular content',
        );

        await repository.create(note1);
        await repository.create(note2);
        await repository.create(note3);

        // Act
        final result = await repository.search('important');

        // Assert
        expect(result.length, equals(2));
        expect(
          result.map((note) => note.id),
          containsAll(['note-1', 'note-2']),
        );
      });

      test('search() handles null content gracefully', () async {
        // Arrange
        final note = createTestNote(id: 'note-1');
        await repository.create(note);

        // Act & Assert - should not throw
        final result = await repository.search('meeting');
        expect(result.length, equals(1));
      });
    });

    group('Edge cases and complex scenarios', () {
      test('Note with multiple tags', () async {
        // Arrange
        final note = createTestNote(
          id: 'note-1',
          title: 'Complex Note',
          tags: ['work', 'important', 'urgent', 'meeting'],
        );

        // Act
        final result = await repository.create(note);

        // Assert
        expect(result.tags.length, equals(4));
        expect(
          result.tags,
          containsAll(['work', 'important', 'urgent', 'meeting']),
        );
      });

      test('Note with empty tags list', () async {
        // Arrange
        final note = createTestNote(id: 'note-1', tags: []);

        // Act
        final result = await repository.create(note);

        // Assert
        expect(result.tags, isEmpty);
      });

      test('Note with null content', () async {
        // Arrange
        final note = createTestNote(id: 'note-1', title: 'Title Only Note');

        // Act
        final result = await repository.create(note);

        // Assert
        expect(result.content, isNull);
        expect(noteBox.get('note-1')!.content, isNull);
      });

      test('Note with long content', () async {
        // Arrange
        final longContent = 'This is a very long note content. ' * 100;
        final note = createTestNote(id: 'note-1', content: longContent);

        // Act
        final result = await repository.create(note);

        // Assert
        expect(result.content, equals(longContent));
        expect(result.content!.length, greaterThan(1000));
      });

      test('update preserves other fields', () async {
        // Arrange
        final note = createTestNote(
          id: 'note-1',
          title: 'Original Title',
          content: 'Original content',
          tags: ['work', 'important'],
          syncStatus: 'synced',
        );
        await repository.create(note);

        // Act
        final updated = note.copyWith(title: 'New Title');
        final result = await repository.update(updated);

        // Assert
        expect(result.title, equals('New Title'));
        expect(result.content, equals('Original content'));
        expect(result.tags, containsAll(['work', 'important']));
        expect(result.syncStatus, equals('synced'));
      });

      test('timestamps are set correctly on creation', () async {
        // Arrange
        final now = DateTime.now();
        final note = createTestNote(id: 'note-1');

        // Act
        final result = await repository.create(note);

        // Assert
        expect(result.createdAt.difference(now).inSeconds.abs(), lessThan(2));
        expect(result.updatedAt.difference(now).inSeconds.abs(), lessThan(2));
      });

      test('search with empty query returns all notes', () async {
        // Arrange
        final note1 = createTestNote(id: 'note-1', title: 'Some Note');
        final note2 = createTestNote(id: 'note-2', title: 'Another Note');
        await repository.create(note1);
        await repository.create(note2);

        // Act
        final result = await repository.search('');

        // Assert
        // Empty string is contained in all strings, so returns all notes
        expect(result.length, equals(2));
      });

      test('search with special characters', () async {
        // Arrange
        final note = createTestNote(
          id: 'note-1',
          title: r'Note with special chars: @#$%',
          content: r'Content with symbols: !@#$%^&*()',
        );
        await repository.create(note);

        // Act
        final result1 = await repository.search(r'@#$');
        final result2 = await repository.search(r'!@#');

        // Assert
        expect(result1.length, equals(1));
        expect(result2.length, equals(1));
      });

      test('multiple notes in same space with different tags', () async {
        // Arrange
        final note1 = createTestNote(id: 'note-1', tags: ['work']);
        final note2 = createTestNote(id: 'note-2', tags: ['personal']);
        final note3 = createTestNote(id: 'note-3', tags: ['work', 'personal']);

        await repository.create(note1);
        await repository.create(note2);
        await repository.create(note3);

        // Act
        final spaceNotes = await repository.getBySpace('space-1');
        final workNotes = await repository.getByTag('work');
        final personalNotes = await repository.getByTag('personal');

        // Assert
        expect(spaceNotes.length, equals(3));
        expect(workNotes.length, equals(2));
        expect(personalNotes.length, equals(2));
      });

      test('syncStatus field handling', () async {
        // Arrange
        final note1 = createTestNote(id: 'note-1', syncStatus: 'pending');
        final note2 = createTestNote(id: 'note-2', syncStatus: 'synced');
        final note3 = createTestNote(id: 'note-3');

        // Act
        await repository.create(note1);
        await repository.create(note2);
        await repository.create(note3);

        // Assert
        final result1 = await repository.getById('note-1');
        final result2 = await repository.getById('note-2');
        final result3 = await repository.getById('note-3');

        expect(result1!.syncStatus, equals('pending'));
        expect(result2!.syncStatus, equals('synced'));
        expect(result3!.syncStatus, isNull);
      });

      test('delete multiple notes sequentially', () async {
        // Arrange
        final note1 = createTestNote(id: 'note-1');
        final note2 = createTestNote(id: 'note-2');
        final note3 = createTestNote(id: 'note-3');

        await repository.create(note1);
        await repository.create(note2);
        await repository.create(note3);

        // Act
        await repository.delete('note-1');
        await repository.delete('note-2');

        // Assert
        expect(noteBox.length, equals(1));
        expect(noteBox.get('note-3'), isNotNull);
      });

      test('getByTag with tag containing special characters', () async {
        // Arrange
        final note = createTestNote(
          id: 'note-1',
          tags: ['tag-with-dash', 'tag_with_underscore', 'tag.with.dot'],
        );
        await repository.create(note);

        // Act
        final result1 = await repository.getByTag('tag-with-dash');
        final result2 = await repository.getByTag('tag_with_underscore');
        final result3 = await repository.getByTag('tag.with.dot');

        // Assert
        expect(result1.length, equals(1));
        expect(result2.length, equals(1));
        expect(result3.length, equals(1));
      });

      test('search partial word matches', () async {
        // Arrange
        final note = createTestNote(
          id: 'note-1',
          title: 'Meeting',
          content: 'Discussion',
        );
        await repository.create(note);

        // Act
        final result1 = await repository.search('meet');
        final result2 = await repository.search('disc');

        // Assert
        expect(result1.length, equals(1));
        expect(result2.length, equals(1));
      });

      test('update multiple times updates timestamp each time', () async {
        // Arrange
        final note = createTestNote(id: 'note-1', title: 'Original');
        await repository.create(note);

        // Act & Assert
        await Future<void>.delayed(const Duration(milliseconds: 10));
        final update1 = await repository.update(
          note.copyWith(title: 'Update 1'),
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));
        final update2 = await repository.update(
          update1.copyWith(title: 'Update 2'),
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));
        final update3 = await repository.update(
          update2.copyWith(title: 'Update 3'),
        );

        expect(update2.updatedAt.isAfter(update1.updatedAt), isTrue);
        expect(update3.updatedAt.isAfter(update2.updatedAt), isTrue);
      });

      test('create note with all fields populated', () async {
        // Arrange
        final note = createTestNote(
          id: 'note-1',
          title: 'Complete Note',
          content: 'Full content here',
          tags: ['tag1', 'tag2'],
          syncStatus: 'synced',
        );

        // Act
        final result = await repository.create(note);

        // Assert
        expect(result.id, equals('note-1'));
        expect(result.title, equals('Complete Note'));
        expect(result.content, equals('Full content here'));
        expect(result.spaceId, equals('space-1'));
        expect(result.tags.length, equals(2));
        expect(result.syncStatus, equals('synced'));
        expect(result.createdAt, isNotNull);
        expect(result.updatedAt, isNotNull);
      });
    });
  });
}
