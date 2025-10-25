import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/models/item_model.dart';

void main() {
  group('Item', () {
    group('construction', () {
      test('creates with all required fields', () {
        final item = Item(
          id: 'note-1',
          title: 'Meeting Notes',
          spaceId: 'space-1',
        );

        expect(item.id, 'note-1');
        expect(item.title, 'Meeting Notes');
        expect(item.content, isNull);
        expect(item.spaceId, 'space-1');
        expect(item.tags, isEmpty);
        expect(item.createdAt, isA<DateTime>());
        expect(item.updatedAt, isA<DateTime>());
        expect(item.syncStatus, isNull);
      });

      test('creates with all optional fields', () {
        final createdAt = DateTime(2025, 1, 1, 10, 0);
        final updatedAt = DateTime(2025, 10, 25, 14, 30);

        final item = Item(
          id: 'note-2',
          title: 'Project Documentation',
          content: 'Comprehensive documentation for the authentication system. '
              'Includes API endpoints, security considerations, and usage examples.',
          spaceId: 'space-2',
          tags: ['documentation', 'api', 'security'],
          createdAt: createdAt,
          updatedAt: updatedAt,
          syncStatus: 'synced',
        );

        expect(item.id, 'note-2');
        expect(item.title, 'Project Documentation');
        expect(item.content, contains('authentication system'));
        expect(item.spaceId, 'space-2');
        expect(item.tags, ['documentation', 'api', 'security']);
        expect(item.createdAt, createdAt);
        expect(item.updatedAt, updatedAt);
        expect(item.syncStatus, 'synced');
      });

      test('defaults tags to empty list when null', () {
        final item = Item(
          id: 'note-3',
          title: 'Note',
          spaceId: 'space-3',
          tags: null,
        );

        expect(item.tags, isEmpty);
        expect(item.tags, isA<List<String>>());
      });

      test('defaults createdAt and updatedAt to now when null', () {
        final before = DateTime.now();
        final item = Item(
          id: 'note-4',
          title: 'Note',
          spaceId: 'space-4',
        );
        final after = DateTime.now();

        expect(item.createdAt.isAfter(before.subtract(Duration(seconds: 1))), true);
        expect(item.createdAt.isBefore(after.add(Duration(seconds: 1))), true);
        expect(item.updatedAt.isAfter(before.subtract(Duration(seconds: 1))), true);
        expect(item.updatedAt.isBefore(after.add(Duration(seconds: 1))), true);
      });
    });

    group('JSON serialization', () {
      test('toJson produces correct format', () {
        final createdAt = DateTime(2025, 3, 15, 9, 30);
        final updatedAt = DateTime(2025, 10, 25, 11, 45);

        final item = Item(
          id: 'note-5',
          title: 'Design System',
          content: 'Color palette, typography, and component guidelines',
          spaceId: 'space-5',
          tags: ['design', 'ui', 'components'],
          createdAt: createdAt,
          updatedAt: updatedAt,
          syncStatus: 'pending',
        );

        final json = item.toJson();

        expect(json['id'], 'note-5');
        expect(json['title'], 'Design System');
        expect(json['content'], 'Color palette, typography, and component guidelines');
        expect(json['spaceId'], 'space-5');
        expect(json['tags'], ['design', 'ui', 'components']);
        expect(json['createdAt'], createdAt.toIso8601String());
        expect(json['updatedAt'], updatedAt.toIso8601String());
        expect(json['syncStatus'], 'pending');
      });

      test('toJson handles null optional fields', () {
        final item = Item(
          id: 'note-6',
          title: 'Simple Note',
          spaceId: 'space-6',
        );

        final json = item.toJson();

        expect(json['content'], isNull);
        expect(json['tags'], isEmpty);
        expect(json['syncStatus'], isNull);
      });

      test('fromJson deserializes correctly', () {
        final json = {
          'id': 'note-7',
          'title': 'API Reference',
          'content': 'REST API documentation with examples',
          'spaceId': 'space-7',
          'tags': ['api', 'reference', 'backend'],
          'createdAt': '2025-06-10T08:00:00.000Z',
          'updatedAt': '2025-10-25T10:30:00.000Z',
          'syncStatus': 'synced',
        };

        final item = Item.fromJson(json);

        expect(item.id, 'note-7');
        expect(item.title, 'API Reference');
        expect(item.content, 'REST API documentation with examples');
        expect(item.spaceId, 'space-7');
        expect(item.tags, ['api', 'reference', 'backend']);
        expect(item.createdAt, DateTime.parse('2025-06-10T08:00:00.000Z'));
        expect(item.updatedAt, DateTime.parse('2025-10-25T10:30:00.000Z'));
        expect(item.syncStatus, 'synced');
      });

      test('fromJson handles null optional fields', () {
        final json = {
          'id': 'note-8',
          'title': 'Minimal Note',
          'spaceId': 'space-8',
          'createdAt': '2025-10-25T10:00:00.000Z',
          'updatedAt': '2025-10-25T10:00:00.000Z',
        };

        final item = Item.fromJson(json);

        expect(item.content, isNull);
        expect(item.tags, isEmpty);
        expect(item.syncStatus, isNull);
      });

      test('roundtrip JSON serialization preserves data', () {
        final createdAt = DateTime(2025, 2, 14, 15, 0);
        final updatedAt = DateTime(2025, 10, 25, 16, 20);

        final original = Item(
          id: 'note-9',
          title: 'Architecture Decisions',
          content: 'Key architectural decisions and their rationale:\n'
              '1. Use dual-model architecture for content types\n'
              '2. Implement ContentProvider for unified access\n'
              '3. Use Hive for local storage\n'
              '4. Plan for future Supabase sync',
          spaceId: 'space-9',
          tags: ['architecture', 'decisions', 'technical'],
          createdAt: createdAt,
          updatedAt: updatedAt,
          syncStatus: 'pending',
        );

        final json = original.toJson();
        final restored = Item.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.title, original.title);
        expect(restored.content, original.content);
        expect(restored.spaceId, original.spaceId);
        expect(restored.tags, original.tags);
        expect(restored.createdAt, original.createdAt);
        expect(restored.updatedAt, original.updatedAt);
        expect(restored.syncStatus, original.syncStatus);
      });

      test('roundtrip with minimal data', () {
        final original = Item(
          id: 'note-10',
          title: 'Basic Note',
          spaceId: 'space-10',
        );

        final json = original.toJson();
        final restored = Item.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.title, original.title);
        expect(restored.spaceId, original.spaceId);
      });
    });

    group('copyWith', () {
      test('updates specified fields only', () {
        final original = Item(
          id: 'note-11',
          title: 'Original Title',
          content: 'Original content',
          spaceId: 'space-11',
          tags: ['tag1'],
          syncStatus: 'pending',
        );

        final updated = original.copyWith(
          title: 'Updated Title',
          content: 'Updated content',
        );

        expect(updated.id, original.id);
        expect(updated.title, 'Updated Title');
        expect(updated.content, 'Updated content');
        expect(updated.spaceId, original.spaceId);
        expect(updated.tags, original.tags);
        expect(updated.createdAt, original.createdAt);
        expect(updated.updatedAt, original.updatedAt);
        expect(updated.syncStatus, original.syncStatus);
      });

      test('preserves unchanged fields', () {
        final createdAt = DateTime(2025, 1, 1);
        final updatedAt = DateTime(2025, 10, 25);

        final original = Item(
          id: 'note-12',
          title: 'Title',
          content: 'Content',
          spaceId: 'space-12',
          tags: ['work', 'important'],
          createdAt: createdAt,
          updatedAt: updatedAt,
          syncStatus: 'synced',
        );

        final newUpdatedAt = DateTime(2025, 10, 26);
        final updated = original.copyWith(updatedAt: newUpdatedAt);

        expect(updated.id, original.id);
        expect(updated.title, original.title);
        expect(updated.content, original.content);
        expect(updated.spaceId, original.spaceId);
        expect(updated.tags, original.tags);
        expect(updated.createdAt, original.createdAt);
        expect(updated.updatedAt, newUpdatedAt);
        expect(updated.syncStatus, original.syncStatus);
      });

      test('can update content', () {
        final original = Item(
          id: 'note-13',
          title: 'Note',
          content: 'Old content',
          spaceId: 'space-13',
        );

        final updated = original.copyWith(content: 'New content');

        expect(updated.content, 'New content');
      });

      test('can update syncStatus', () {
        final original = Item(
          id: 'note-14',
          title: 'Note',
          spaceId: 'space-14',
          syncStatus: 'pending',
        );

        final updated = original.copyWith(syncStatus: 'synced');

        expect(updated.syncStatus, 'synced');
      });

      test('can update tags', () {
        final original = Item(
          id: 'note-15',
          title: 'Note',
          spaceId: 'space-15',
          tags: ['old', 'tags'],
        );

        final updated = original.copyWith(tags: ['new', 'updated', 'tags']);

        expect(updated.tags, ['new', 'updated', 'tags']);
      });

      test('can update all fields', () {
        final original = Item(
          id: 'note-16',
          title: 'Old',
          spaceId: 'space-16',
        );

        final newCreatedAt = DateTime(2025, 1, 1);
        final newUpdatedAt = DateTime(2025, 10, 26);

        final updated = original.copyWith(
          id: 'note-17',
          title: 'New',
          content: 'New content',
          spaceId: 'space-17',
          tags: ['new', 'tags'],
          createdAt: newCreatedAt,
          updatedAt: newUpdatedAt,
          syncStatus: 'synced',
        );

        expect(updated.id, 'note-17');
        expect(updated.title, 'New');
        expect(updated.content, 'New content');
        expect(updated.spaceId, 'space-17');
        expect(updated.tags, ['new', 'tags']);
        expect(updated.createdAt, newCreatedAt);
        expect(updated.updatedAt, newUpdatedAt);
        expect(updated.syncStatus, 'synced');
      });
    });

    group('equality', () {
      test('equality is based on id only', () {
        final item1 = Item(
          id: 'same-id',
          title: 'Title 1',
          content: 'Content 1',
          spaceId: 'space-1',
          tags: ['tag1'],
          syncStatus: 'pending',
        );

        final item2 = Item(
          id: 'same-id',
          title: 'Title 2',
          content: 'Content 2',
          spaceId: 'space-2',
          tags: ['tag2'],
          syncStatus: 'synced',
        );

        expect(item1, equals(item2));
        expect(item1.hashCode, equals(item2.hashCode));
      });

      test('different ids are not equal', () {
        final item1 = Item(
          id: 'id-1',
          title: 'Same title',
          spaceId: 'space-1',
        );

        final item2 = Item(
          id: 'id-2',
          title: 'Same title',
          spaceId: 'space-1',
        );

        expect(item1, isNot(equals(item2)));
      });

      test('identical items are equal', () {
        final item = Item(
          id: 'note-18',
          title: 'Note',
          spaceId: 'space-18',
        );

        expect(item, equals(item));
      });
    });

    group('toString', () {
      test('includes key identifying fields', () {
        final item = Item(
          id: 'note-19',
          title: 'Important Note',
          spaceId: 'space-19',
          tags: ['important', 'urgent'],
        );

        final string = item.toString();

        expect(string, contains('note-19'));
        expect(string, contains('Important Note'));
        expect(string, contains('space-19'));
        expect(string, contains('important'));
        expect(string, contains('urgent'));
      });

      test('has readable format', () {
        final item = Item(
          id: 'note-20',
          title: 'Note',
          spaceId: 'space-20',
        );

        final string = item.toString();

        expect(string, startsWith('Item('));
        expect(string, contains('id:'));
        expect(string, contains('title:'));
        expect(string, contains('spaceId:'));
        expect(string, contains('tags:'));
      });
    });

    group('edge cases', () {
      test('handles empty string title', () {
        final item = Item(
          id: 'note-21',
          title: '',
          spaceId: 'space-21',
        );

        expect(item.title, '');
      });

      test('handles very long title', () {
        final longTitle = 'A' * 1000;
        final item = Item(
          id: 'note-22',
          title: longTitle,
          spaceId: 'space-22',
        );

        expect(item.title, longTitle);
      });

      test('handles very long content', () {
        final longContent = 'B' * 10000;
        final item = Item(
          id: 'note-23',
          title: 'Note',
          content: longContent,
          spaceId: 'space-23',
        );

        expect(item.content, longContent);
        expect(item.content!.length, 10000);
      });

      test('handles empty content string', () {
        final item = Item(
          id: 'note-24',
          title: 'Note',
          content: '',
          spaceId: 'space-24',
        );

        expect(item.content, '');
      });

      test('handles multiline content', () {
        final multilineContent = '''
This is a note with multiple lines.

It includes:
- Bullet points
- Multiple paragraphs
- Various formatting

And it should all be preserved.
''';

        final item = Item(
          id: 'note-25',
          title: 'Multiline Note',
          content: multilineContent,
          spaceId: 'space-25',
        );

        expect(item.content, multilineContent);
      });

      test('handles empty tags list', () {
        final item = Item(
          id: 'note-26',
          title: 'Note',
          spaceId: 'space-26',
          tags: [],
        );

        expect(item.tags, isEmpty);
      });

      test('handles many tags', () {
        final manyTags = List.generate(50, (i) => 'tag$i');
        final item = Item(
          id: 'note-27',
          title: 'Note',
          spaceId: 'space-27',
          tags: manyTags,
        );

        expect(item.tags, manyTags);
        expect(item.tags.length, 50);
      });

      test('handles special characters in title', () {
        final item = Item(
          id: 'note-28',
          title: 'Special chars: @#\$%^&*()_+-=[]{}|;:,.<>?/~`',
          spaceId: 'space-28',
        );

        expect(item.title, 'Special chars: @#\$%^&*()_+-=[]{}|;:,.<>?/~`');
      });

      test('handles special characters in content', () {
        final item = Item(
          id: 'note-29',
          title: 'Note',
          content: 'Special chars in content: @#\$%^&*()_+-=[]{}|;:,.<>?/~`',
          spaceId: 'space-29',
        );

        expect(item.content, 'Special chars in content: @#\$%^&*()_+-=[]{}|;:,.<>?/~`');
      });

      test('handles unicode and emoji in title', () {
        final item = Item(
          id: 'note-30',
          title: 'Note with emoji 📝 and unicode 你好',
          spaceId: 'space-30',
        );

        expect(item.title, 'Note with emoji 📝 and unicode 你好');
      });

      test('handles unicode and emoji in content', () {
        final item = Item(
          id: 'note-31',
          title: 'Note',
          content: 'Content with emoji 🎉 and unicode 世界',
          spaceId: 'space-31',
        );

        expect(item.content, 'Content with emoji 🎉 and unicode 世界');
      });

      test('handles various syncStatus values', () {
        final pendingItem = Item(
          id: 'note-32',
          title: 'Note',
          spaceId: 'space-32',
          syncStatus: 'pending',
        );

        final syncedItem = Item(
          id: 'note-33',
          title: 'Note',
          spaceId: 'space-33',
          syncStatus: 'synced',
        );

        final localItem = Item(
          id: 'note-34',
          title: 'Note',
          spaceId: 'space-34',
          syncStatus: null,
        );

        expect(pendingItem.syncStatus, 'pending');
        expect(syncedItem.syncStatus, 'synced');
        expect(localItem.syncStatus, isNull);
      });

      test('handles past timestamps', () {
        final pastDate = DateTime(2020, 1, 1);
        final item = Item(
          id: 'note-35',
          title: 'Old Note',
          spaceId: 'space-35',
          createdAt: pastDate,
          updatedAt: pastDate,
        );

        expect(item.createdAt, pastDate);
        expect(item.updatedAt, pastDate);
      });

      test('handles future timestamps', () {
        final futureDate = DateTime(2030, 12, 31);
        final item = Item(
          id: 'note-36',
          title: 'Future Note',
          spaceId: 'space-36',
          createdAt: futureDate,
          updatedAt: futureDate,
        );

        expect(item.createdAt, futureDate);
        expect(item.updatedAt, futureDate);
      });

      test('handles createdAt and updatedAt being different', () {
        final createdAt = DateTime(2025, 1, 1);
        final updatedAt = DateTime(2025, 10, 25);
        final item = Item(
          id: 'note-37',
          title: 'Updated Note',
          spaceId: 'space-37',
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(item.createdAt, createdAt);
        expect(item.updatedAt, updatedAt);
        expect(item.updatedAt.isAfter(item.createdAt), true);
      });
    });

    group('use cases', () {
      test('represents a simple quick note', () {
        final item = Item(
          id: 'quick-1',
          title: 'Remember to call dentist',
          spaceId: 'personal',
        );

        expect(item.title, 'Remember to call dentist');
        expect(item.content, isNull);
        expect(item.tags, isEmpty);
      });

      test('represents a detailed documentation note', () {
        final item = Item(
          id: 'doc-1',
          title: 'API Authentication Flow',
          content: '''
# Authentication Flow

## Overview
Our API uses JWT tokens for authentication.

## Process
1. User sends credentials to /auth/login
2. Server validates and returns JWT token
3. Client includes token in Authorization header
4. Server validates token on each request

## Security Considerations
- Tokens expire after 24 hours
- Refresh tokens available for long-lived sessions
- All endpoints require HTTPS
''',
          spaceId: 'development',
          tags: ['documentation', 'api', 'security', 'authentication'],
          syncStatus: 'synced',
        );

        expect(item.title, 'API Authentication Flow');
        expect(item.content, contains('JWT tokens'));
        expect(item.tags.length, 4);
        expect(item.syncStatus, 'synced');
      });

      test('represents a tagged note for organization', () {
        final item = Item(
          id: 'tagged-1',
          title: 'Q4 Planning Meeting Notes',
          content: 'Key decisions and action items from today\'s planning session',
          spaceId: 'work',
          tags: ['meeting', 'planning', 'q4', 'important'],
        );

        expect(item.tags, contains('meeting'));
        expect(item.tags, contains('q4'));
        expect(item.tags.length, 4);
      });

      test('represents a note pending sync', () {
        final item = Item(
          id: 'pending-1',
          title: 'Offline Note',
          content: 'Created while offline, needs to sync',
          spaceId: 'personal',
          syncStatus: 'pending',
        );

        expect(item.syncStatus, 'pending');
      });

      test('represents a local-only note', () {
        final item = Item(
          id: 'local-1',
          title: 'Private Note',
          content: 'This note stays on device only',
          spaceId: 'personal',
          syncStatus: null,
        );

        expect(item.syncStatus, isNull);
      });
    });
  });
}
