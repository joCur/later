import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/models/item_model.dart';

void main() {
  group('ItemModel', () {
    test('creates an item with all required fields', () {
      final item = Item(
        id: 'test-id',
        type: ItemType.task,
        title: 'Test Task',
        spaceId: 'space-1',
      );

      expect(item.id, 'test-id');
      expect(item.type, ItemType.task);
      expect(item.title, 'Test Task');
      expect(item.spaceId, 'space-1');
      expect(item.isCompleted, false);
      expect(item.tags, isEmpty);
    });

    test('creates an item with optional fields', () {
      final dueDate = DateTime(2024, 12, 31);
      final item = Item(
        id: 'test-id',
        type: ItemType.task,
        title: 'Test Task',
        content: 'Task description',
        spaceId: 'space-1',
        isCompleted: true,
        dueDate: dueDate,
        tags: ['work', 'urgent'],
        syncStatus: 'synced',
      );

      expect(item.content, 'Task description');
      expect(item.isCompleted, true);
      expect(item.dueDate, dueDate);
      expect(item.tags, ['work', 'urgent']);
      expect(item.syncStatus, 'synced');
    });

    test('copyWith creates a new instance with updated fields', () {
      final original = Item(
        id: 'test-id',
        type: ItemType.task,
        title: 'Original Title',
        spaceId: 'space-1',
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        isCompleted: true,
      );

      expect(updated.id, original.id);
      expect(updated.title, 'Updated Title');
      expect(updated.isCompleted, true);
      expect(updated.type, original.type);
      expect(updated.spaceId, original.spaceId);
    });

    test('toJson serializes correctly', () {
      final item = Item(
        id: 'test-id',
        type: ItemType.note,
        title: 'Test Note',
        content: 'Note content',
        spaceId: 'space-1',
        tags: ['personal'],
      );

      final json = item.toJson();

      expect(json['id'], 'test-id');
      expect(json['type'], 'note');
      expect(json['title'], 'Test Note');
      expect(json['content'], 'Note content');
      expect(json['spaceId'], 'space-1');
      expect(json['tags'], ['personal']);
      expect(json['isCompleted'], false);
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'test-id',
        'type': 'list',
        'title': 'Test List',
        'content': 'List items',
        'spaceId': 'space-1',
        'isCompleted': false,
        'tags': ['shopping'],
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-02T00:00:00.000Z',
      };

      final item = Item.fromJson(json);

      expect(item.id, 'test-id');
      expect(item.type, ItemType.list);
      expect(item.title, 'Test List');
      expect(item.content, 'List items');
      expect(item.spaceId, 'space-1');
      expect(item.tags, ['shopping']);
    });

    test('roundtrip JSON serialization preserves data', () {
      final original = Item(
        id: 'test-id',
        type: ItemType.task,
        title: 'Test Task',
        content: 'Task description',
        spaceId: 'space-1',
        isCompleted: true,
        tags: ['work', 'important'],
      );

      final json = original.toJson();
      final restored = Item.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.type, original.type);
      expect(restored.title, original.title);
      expect(restored.content, original.content);
      expect(restored.spaceId, original.spaceId);
      expect(restored.isCompleted, original.isCompleted);
      expect(restored.tags, original.tags);
    });

    test('equality is based on id', () {
      final item1 = Item(
        id: 'same-id',
        type: ItemType.task,
        title: 'Title 1',
        spaceId: 'space-1',
      );

      final item2 = Item(
        id: 'same-id',
        type: ItemType.note,
        title: 'Title 2',
        spaceId: 'space-2',
      );

      final item3 = Item(
        id: 'different-id',
        type: ItemType.task,
        title: 'Title 1',
        spaceId: 'space-1',
      );

      expect(item1, equals(item2));
      expect(item1, isNot(equals(item3)));
    });

    test('toString includes key fields', () {
      final item = Item(
        id: 'test-id',
        type: ItemType.task,
        title: 'Test Task',
        spaceId: 'space-1',
        isCompleted: true,
      );

      final string = item.toString();

      expect(string, contains('test-id'));
      expect(string, contains('task'));
      expect(string, contains('Test Task'));
      expect(string, contains('space-1'));
      expect(string, contains('true'));
    });
  });
}
