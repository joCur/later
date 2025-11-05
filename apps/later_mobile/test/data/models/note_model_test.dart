import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/models/note_model.dart';

void main() {
  group('Note', () {
    group('construction', () {
      test('creates with all required fields', () {
        final note = Note(
          id: 'note-1',
          title: 'Meeting Notes',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        expect(note.id, 'note-1');
        expect(note.title, 'Meeting Notes');
        expect(note.content, isNull);
        expect(note.spaceId, 'space-1');
        expect(note.userId, 'user-1');
        expect(note.tags, isEmpty);
        expect(note.createdAt, isA<DateTime>());
        expect(note.updatedAt, isA<DateTime>());
        expect(note.sortOrder, 0);
      });

      test('creates with all optional fields', () {
        final createdAt = DateTime(2025, 1, 1, 10);
        final updatedAt = DateTime(2025, 10, 25, 14, 30);

        final note = Note(
          id: 'note-2',
          title: 'Project Documentation',
          content:
              'Comprehensive documentation for the authentication system. '
              'Includes API endpoints, security considerations, and usage examples.',
          spaceId: 'space-2',
          userId: 'user-2',
          tags: ['documentation', 'api', 'security'],
          createdAt: createdAt,
          updatedAt: updatedAt,
          sortOrder: 5,
        );

        expect(note.id, 'note-2');
        expect(note.title, 'Project Documentation');
        expect(note.content, contains('authentication system'));
        expect(note.spaceId, 'space-2');
        expect(note.userId, 'user-2');
        expect(note.tags, ['documentation', 'api', 'security']);
        expect(note.createdAt, createdAt);
        expect(note.updatedAt, updatedAt);
        expect(note.sortOrder, 5);
      });

      test('initializes empty tags list when not provided', () {
        final note = Note(
          id: 'note-3',
          title: 'Untitled',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        expect(note.tags, isEmpty);
        expect(note.tags, isA<List<String>>());
      });

      test('initializes dates to now when not provided', () {
        final beforeCreation = DateTime.now();
        final note = Note(
          id: 'note-4',
          title: 'Test Note',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        final afterCreation = DateTime.now();

        expect(note.createdAt.isAfter(beforeCreation.subtract(const Duration(seconds: 1))), isTrue);
        expect(note.createdAt.isBefore(afterCreation.add(const Duration(seconds: 1))), isTrue);
        expect(note.updatedAt.isAfter(beforeCreation.subtract(const Duration(seconds: 1))), isTrue);
        expect(note.updatedAt.isBefore(afterCreation.add(const Duration(seconds: 1))), isTrue);
      });
    });

    group('fromJson', () {
      test('deserializes from JSON with all fields', () {
        final json = {
          'id': 'note-1',
          'title': 'API Design',
          'content': 'RESTful endpoints for user management',
          'space_id': 'space-1',
          'user_id': 'user-1',
          'tags': ['api', 'design'],
          'created_at': '2025-01-01T10:00:00.000Z',
          'updated_at': '2025-01-02T15:30:00.000Z',
          'sort_order': 3,
        };

        final note = Note.fromJson(json);

        expect(note.id, 'note-1');
        expect(note.title, 'API Design');
        expect(note.content, 'RESTful endpoints for user management');
        expect(note.spaceId, 'space-1');
        expect(note.userId, 'user-1');
        expect(note.tags, ['api', 'design']);
        expect(note.createdAt, DateTime.parse('2025-01-01T10:00:00.000Z'));
        expect(note.updatedAt, DateTime.parse('2025-01-02T15:30:00.000Z'));
        expect(note.sortOrder, 3);
      });

      test('deserializes from JSON with minimal fields', () {
        final json = {
          'id': 'note-2',
          'title': 'Quick Note',
          'space_id': 'space-2',
          'user_id': 'user-2',
          'created_at': '2025-01-01T10:00:00.000Z',
          'updated_at': '2025-01-01T10:00:00.000Z',
        };

        final note = Note.fromJson(json);

        expect(note.id, 'note-2');
        expect(note.title, 'Quick Note');
        expect(note.content, isNull);
        expect(note.spaceId, 'space-2');
        expect(note.userId, 'user-2');
        expect(note.tags, isEmpty);
        expect(note.sortOrder, 0);
      });

      test('handles null content gracefully', () {
        final json = {
          'id': 'note-3',
          'title': 'Empty Note',
          'content': null,
          'space_id': 'space-1',
          'user_id': 'user-1',
          'created_at': '2025-01-01T10:00:00.000Z',
          'updated_at': '2025-01-01T10:00:00.000Z',
        };

        final note = Note.fromJson(json);

        expect(note.content, isNull);
      });

      test('handles empty tags array', () {
        final json = {
          'id': 'note-4',
          'title': 'Untagged',
          'space_id': 'space-1',
          'user_id': 'user-1',
          'tags': <String>[],
          'created_at': '2025-01-01T10:00:00.000Z',
          'updated_at': '2025-01-01T10:00:00.000Z',
        };

        final note = Note.fromJson(json);

        expect(note.tags, isEmpty);
      });

      test('handles null tags array', () {
        final json = {
          'id': 'note-5',
          'title': 'No Tags',
          'space_id': 'space-1',
          'user_id': 'user-1',
          'tags': null,
          'created_at': '2025-01-01T10:00:00.000Z',
          'updated_at': '2025-01-01T10:00:00.000Z',
        };

        final note = Note.fromJson(json);

        expect(note.tags, isEmpty);
      });

      test('handles missing sort_order with default', () {
        final json = {
          'id': 'note-6',
          'title': 'Default Order',
          'space_id': 'space-1',
          'user_id': 'user-1',
          'created_at': '2025-01-01T10:00:00.000Z',
          'updated_at': '2025-01-01T10:00:00.000Z',
        };

        final note = Note.fromJson(json);

        expect(note.sortOrder, 0);
      });

      test('handles null sort_order with default', () {
        final json = {
          'id': 'note-7',
          'title': 'Null Order',
          'space_id': 'space-1',
          'user_id': 'user-1',
          'sort_order': null,
          'created_at': '2025-01-01T10:00:00.000Z',
          'updated_at': '2025-01-01T10:00:00.000Z',
        };

        final note = Note.fromJson(json);

        expect(note.sortOrder, 0);
      });
    });

    group('toJson', () {
      test('serializes to JSON with all fields', () {
        final createdAt = DateTime(2025, 1, 1, 10);
        final updatedAt = DateTime(2025, 1, 2, 15, 30);

        final note = Note(
          id: 'note-1',
          title: 'Design Doc',
          content: 'System architecture overview',
          spaceId: 'space-1',
          userId: 'user-1',
          tags: ['design', 'architecture'],
          createdAt: createdAt,
          updatedAt: updatedAt,
          sortOrder: 2,
        );

        final json = note.toJson();

        expect(json['id'], 'note-1');
        expect(json['title'], 'Design Doc');
        expect(json['content'], 'System architecture overview');
        expect(json['space_id'], 'space-1');
        expect(json['user_id'], 'user-1');
        expect(json['tags'], ['design', 'architecture']);
        expect(json['created_at'], createdAt.toIso8601String());
        expect(json['updated_at'], updatedAt.toIso8601String());
        expect(json['sort_order'], 2);
      });

      test('serializes to JSON with minimal fields', () {
        final note = Note(
          id: 'note-2',
          title: 'Simple Note',
          spaceId: 'space-2',
          userId: 'user-2',
        );

        final json = note.toJson();

        expect(json['id'], 'note-2');
        expect(json['title'], 'Simple Note');
        expect(json['content'], isNull);
        expect(json['space_id'], 'space-2');
        expect(json['user_id'], 'user-2');
        expect(json['tags'], isEmpty);
        expect(json['sort_order'], 0);
      });

      test('preserves null content in JSON', () {
        final note = Note(
          id: 'note-3',
          title: 'No Content',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        final json = note.toJson();

        expect(json.containsKey('content'), isTrue);
        expect(json['content'], isNull);
      });

      test('preserves empty tags array in JSON', () {
        final note = Note(
          id: 'note-4',
          title: 'No Tags',
          spaceId: 'space-1',
          userId: 'user-1',
          tags: [],
        );

        final json = note.toJson();

        expect(json['tags'], isEmpty);
        expect(json['tags'], isA<List<String>>());
      });
    });

    group('copyWith', () {
      test('creates copy with updated title', () {
        final original = Note(
          id: 'note-1',
          title: 'Original Title',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        final updated = original.copyWith(title: 'Updated Title');

        expect(updated.id, original.id);
        expect(updated.title, 'Updated Title');
        expect(updated.spaceId, original.spaceId);
        expect(updated.userId, original.userId);
      });

      test('creates copy with updated content', () {
        final original = Note(
          id: 'note-1',
          title: 'Title',
          content: 'Old content',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        final updated = original.copyWith(content: 'New content');

        expect(updated.content, 'New content');
      });

      test('creates copy with updated tags', () {
        final original = Note(
          id: 'note-1',
          title: 'Title',
          spaceId: 'space-1',
          userId: 'user-1',
          tags: ['old'],
        );

        final updated = original.copyWith(tags: ['new', 'tags']);

        expect(updated.tags, ['new', 'tags']);
      });

      test('creates copy with updated spaceId', () {
        final original = Note(
          id: 'note-1',
          title: 'Title',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        final updated = original.copyWith(spaceId: 'space-2');

        expect(updated.spaceId, 'space-2');
      });

      test('creates copy with updated userId', () {
        final original = Note(
          id: 'note-1',
          title: 'Title',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        final updated = original.copyWith(userId: 'user-2');

        expect(updated.userId, 'user-2');
      });

      test('creates copy with updated sortOrder', () {
        final original = Note(
          id: 'note-1',
          title: 'Title',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        final updated = original.copyWith(sortOrder: 5);

        expect(updated.sortOrder, 5);
      });

      test('preserves unchanged fields', () {
        final createdAt = DateTime(2025);
        final original = Note(
          id: 'note-1',
          title: 'Title',
          content: 'Content',
          spaceId: 'space-1',
          userId: 'user-1',
          tags: ['tag1', 'tag2'],
          createdAt: createdAt,
          sortOrder: 3,
        );

        final updated = original.copyWith(title: 'New Title');

        expect(updated.content, original.content);
        expect(updated.tags, original.tags);
        expect(updated.createdAt, original.createdAt);
        expect(updated.sortOrder, original.sortOrder);
      });

      test('returns a different instance', () {
        final note = Note(
          id: 'note-1',
          title: 'Title',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        final updated = note.copyWith(title: 'New Title');

        expect(identical(note, updated), isFalse);
      });
    });

    group('equality', () {
      test('notes with same id are equal', () {
        final note1 = Note(
          id: 'note-1',
          title: 'Title 1',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        final note2 = Note(
          id: 'note-1',
          title: 'Title 2',
          spaceId: 'space-2',
          userId: 'user-2',
        );

        expect(note1, equals(note2));
        expect(note1.hashCode, equals(note2.hashCode));
      });

      test('notes with different id are not equal', () {
        final note1 = Note(
          id: 'note-1',
          title: 'Title',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        final note2 = Note(
          id: 'note-2',
          title: 'Title',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        expect(note1, isNot(equals(note2)));
      });

      test('identical instances are equal', () {
        final note = Note(
          id: 'note-1',
          title: 'Title',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        // ignore: unrelated_type_equality_checks
        expect(note, equals(note));
        expect(note.hashCode, equals(note.hashCode));
      });
    });

    group('toString', () {
      test('returns readable string representation', () {
        final note = Note(
          id: 'note-1',
          title: 'My Note',
          spaceId: 'space-1',
          userId: 'user-1',
          tags: ['tag1', 'tag2'],
        );

        final string = note.toString();

        expect(string, contains('Note'));
        expect(string, contains('note-1'));
        expect(string, contains('My Note'));
        expect(string, contains('space-1'));
        expect(string, contains('tag1'));
        expect(string, contains('tag2'));
      });
    });

    group('round-trip serialization', () {
      test('survives JSON round trip with all fields', () {
        final original = Note(
          id: 'note-1',
          title: 'Round Trip Test',
          content: 'Testing serialization',
          spaceId: 'space-1',
          userId: 'user-1',
          tags: ['test', 'serialization'],
          createdAt: DateTime(2025, 1, 1, 10),
          updatedAt: DateTime(2025, 1, 2, 15),
          sortOrder: 7,
        );

        final json = original.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.id, original.id);
        expect(deserialized.title, original.title);
        expect(deserialized.content, original.content);
        expect(deserialized.spaceId, original.spaceId);
        expect(deserialized.userId, original.userId);
        expect(deserialized.tags, original.tags);
        expect(deserialized.createdAt, original.createdAt);
        expect(deserialized.updatedAt, original.updatedAt);
        expect(deserialized.sortOrder, original.sortOrder);
      });

      test('survives JSON round trip with minimal fields', () {
        final original = Note(
          id: 'note-2',
          title: 'Minimal',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        final json = original.toJson();
        final deserialized = Note.fromJson(json);

        expect(deserialized.id, original.id);
        expect(deserialized.title, original.title);
        expect(deserialized.content, original.content);
        expect(deserialized.spaceId, original.spaceId);
        expect(deserialized.userId, original.userId);
        expect(deserialized.tags, isEmpty);
      });
    });
  });
}
