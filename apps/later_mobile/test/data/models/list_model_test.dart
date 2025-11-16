import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/features/lists/domain/models/list_item_model.dart';
import 'package:later_mobile/features/lists/domain/models/list_model.dart';
import 'package:later_mobile/data/models/list_style.dart';

void main() {
  group('ListStyle', () {
    test('has correct values', () {
      expect(ListStyle.values.length, 4);
      expect(ListStyle.values, [
        ListStyle.bullets,
        ListStyle.numbered,
        ListStyle.checkboxes,
        ListStyle.simple,
      ]);
    });

    test('serializes to string correctly', () {
      expect(ListStyle.bullets.toJson(), 'bullets');
      expect(ListStyle.numbered.toJson(), 'numbered');
      expect(ListStyle.checkboxes.toJson(), 'checkboxes');
      expect(ListStyle.simple.toJson(), 'simple');
    });

    test('deserializes from string correctly', () {
      expect(ListStyleExtension.fromJson('bullets'), ListStyle.bullets);
      expect(ListStyleExtension.fromJson('numbered'), ListStyle.numbered);
      expect(ListStyleExtension.fromJson('checkboxes'), ListStyle.checkboxes);
      expect(ListStyleExtension.fromJson('simple'), ListStyle.simple);
    });

    test('handles invalid value with default', () {
      expect(ListStyleExtension.fromJson('invalid'), ListStyle.bullets);
    });
  });

  group('ListItem', () {
    group('construction', () {
      test('creates with all required fields', () {
        final item = ListItem(
          id: 'item-1',
          listId: 'list-1',
          title: 'Buy milk',
          sortOrder: 0,
        );

        expect(item.id, 'item-1');
        expect(item.listId, 'list-1');
        expect(item.title, 'Buy milk');
        expect(item.notes, isNull);
        expect(item.isChecked, false);
        expect(item.sortOrder, 0);
      });

      test('creates with all optional fields', () {
        final item = ListItem(
          id: 'item-2',
          listId: 'list-2',
          title: 'Complete project proposal',
          notes: 'Include budget estimates and timeline',
          isChecked: true,
          sortOrder: 5,
        );

        expect(item.id, 'item-2');
        expect(item.listId, 'list-2');
        expect(item.title, 'Complete project proposal');
        expect(item.notes, 'Include budget estimates and timeline');
        expect(item.isChecked, true);
        expect(item.sortOrder, 5);
      });

      test('defaults isChecked to false', () {
        final item = ListItem(
          id: 'item-3',
          listId: 'list-3',
          title: 'Task',
          sortOrder: 0,
        );

        expect(item.isChecked, false);
      });
    });

    group('fromJson', () {
      test('deserializes from JSON with all fields', () {
        final json = {
          'id': 'item-1',
          'list_id': 'list-1',
          'title': 'Research topic',
          'notes': 'Focus on recent publications',
          'is_checked': true,
          'sort_order': 3,
        };

        final item = ListItem.fromJson(json);

        expect(item.id, 'item-1');
        expect(item.listId, 'list-1');
        expect(item.title, 'Research topic');
        expect(item.notes, 'Focus on recent publications');
        expect(item.isChecked, true);
        expect(item.sortOrder, 3);
      });

      test('deserializes from JSON with minimal fields', () {
        final json = {
          'id': 'item-2',
          'list_id': 'list-2',
          'title': 'Simple item',
          'sort_order': 0,
        };

        final item = ListItem.fromJson(json);

        expect(item.id, 'item-2');
        expect(item.listId, 'list-2');
        expect(item.title, 'Simple item');
        expect(item.notes, isNull);
        expect(item.isChecked, false);
        expect(item.sortOrder, 0);
      });

      test('handles null notes gracefully', () {
        final json = {
          'id': 'item-3',
          'list_id': 'list-3',
          'title': 'Item',
          'notes': null,
          'sort_order': 0,
        };

        final item = ListItem.fromJson(json);

        expect(item.notes, isNull);
      });

      test('handles null is_checked with default false', () {
        final json = {
          'id': 'item-4',
          'list_id': 'list-4',
          'title': 'Item',
          'is_checked': null,
          'sort_order': 0,
        };

        final item = ListItem.fromJson(json);

        expect(item.isChecked, false);
      });
    });

    group('toJson', () {
      test('serializes to JSON with all fields', () {
        final item = ListItem(
          id: 'item-1',
          listId: 'list-1',
          title: 'Write report',
          notes: 'Include graphs and tables',
          isChecked: true,
          sortOrder: 2,
        );

        final json = item.toJson();

        expect(json['id'], 'item-1');
        expect(json['list_id'], 'list-1');
        expect(json['title'], 'Write report');
        expect(json['notes'], 'Include graphs and tables');
        expect(json['is_checked'], true);
        expect(json['sort_order'], 2);
      });

      test('serializes to JSON with minimal fields', () {
        final item = ListItem(
          id: 'item-2',
          listId: 'list-2',
          title: 'Simple',
          sortOrder: 0,
        );

        final json = item.toJson();

        expect(json['id'], 'item-2');
        expect(json['list_id'], 'list-2');
        expect(json['title'], 'Simple');
        expect(json['notes'], isNull);
        expect(json['is_checked'], false);
        expect(json['sort_order'], 0);
      });
    });

    group('copyWith', () {
      test('creates copy with updated title', () {
        final original = ListItem(
          id: 'item-1',
          listId: 'list-1',
          title: 'Original',
          sortOrder: 0,
        );

        final updated = original.copyWith(title: 'Updated');

        expect(updated.id, original.id);
        expect(updated.listId, original.listId);
        expect(updated.title, 'Updated');
        expect(updated.sortOrder, original.sortOrder);
      });

      test('creates copy with updated isChecked', () {
        final original = ListItem(
          id: 'item-1',
          listId: 'list-1',
          title: 'Item',
          sortOrder: 0,
        );

        final updated = original.copyWith(isChecked: true);

        expect(updated.isChecked, true);
      });

      test('creates copy with updated notes', () {
        final original = ListItem(
          id: 'item-1',
          listId: 'list-1',
          title: 'Item',
          sortOrder: 0,
        );

        final updated = original.copyWith(notes: 'New notes');

        expect(updated.notes, 'New notes');
      });

      test('can clear notes', () {
        final original = ListItem(
          id: 'item-1',
          listId: 'list-1',
          title: 'Item',
          notes: 'Old notes',
          sortOrder: 0,
        );

        final updated = original.copyWith(clearNotes: true);

        expect(updated.notes, isNull);
      });
    });

    group('equality', () {
      test('items with same id are equal', () {
        final item1 = ListItem(
          id: 'item-1',
          listId: 'list-1',
          title: 'Item 1',
          sortOrder: 0,
        );

        final item2 = ListItem(
          id: 'item-1',
          listId: 'list-2',
          title: 'Item 2',
          sortOrder: 1,
        );

        expect(item1, equals(item2));
        expect(item1.hashCode, equals(item2.hashCode));
      });

      test('items with different id are not equal', () {
        final item1 = ListItem(
          id: 'item-1',
          listId: 'list-1',
          title: 'Item',
          sortOrder: 0,
        );

        final item2 = ListItem(
          id: 'item-2',
          listId: 'list-1',
          title: 'Item',
          sortOrder: 0,
        );

        expect(item1, isNot(equals(item2)));
      });
    });

    group('round-trip serialization', () {
      test('survives JSON round trip with all fields', () {
        final original = ListItem(
          id: 'item-1',
          listId: 'list-1',
          title: 'Complete task',
          notes: 'Notes here',
          isChecked: true,
          sortOrder: 3,
        );

        final json = original.toJson();
        final deserialized = ListItem.fromJson(json);

        expect(deserialized.id, original.id);
        expect(deserialized.listId, original.listId);
        expect(deserialized.title, original.title);
        expect(deserialized.notes, original.notes);
        expect(deserialized.isChecked, original.isChecked);
        expect(deserialized.sortOrder, original.sortOrder);
      });

      test('survives JSON round trip with minimal fields', () {
        final original = ListItem(
          id: 'item-2',
          listId: 'list-2',
          title: 'Simple',
          sortOrder: 0,
        );

        final json = original.toJson();
        final deserialized = ListItem.fromJson(json);

        expect(deserialized.id, original.id);
        expect(deserialized.listId, original.listId);
        expect(deserialized.title, original.title);
        expect(deserialized.isChecked, false);
        expect(deserialized.sortOrder, 0);
      });
    });
  });

  group('ListModel', () {
    group('construction', () {
      test('creates with all required fields', () {
        final list = ListModel(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'Shopping List',
        );

        expect(list.id, 'list-1');
        expect(list.spaceId, 'space-1');
        expect(list.userId, 'user-1');
        expect(list.name, 'Shopping List');
        expect(list.icon, isNull);
        expect(list.style, ListStyle.bullets);
        expect(list.totalItemCount, 0);
        expect(list.checkedItemCount, 0);
        expect(list.createdAt, isA<DateTime>());
        expect(list.updatedAt, isA<DateTime>());
        expect(list.sortOrder, 0);
      });

      test('creates with all optional fields', () {
        final createdAt = DateTime(2025);
        final updatedAt = DateTime(2025, 10, 25);

        final list = ListModel(
          id: 'list-2',
          spaceId: 'space-2',
          userId: 'user-2',
          name: 'Project Tasks',
          icon: '📝',
          style: ListStyle.checkboxes,
          totalItemCount: 15,
          checkedItemCount: 8,
          createdAt: createdAt,
          updatedAt: updatedAt,
          sortOrder: 5,
        );

        expect(list.id, 'list-2');
        expect(list.spaceId, 'space-2');
        expect(list.userId, 'user-2');
        expect(list.name, 'Project Tasks');
        expect(list.icon, '📝');
        expect(list.style, ListStyle.checkboxes);
        expect(list.totalItemCount, 15);
        expect(list.checkedItemCount, 8);
        expect(list.createdAt, createdAt);
        expect(list.updatedAt, updatedAt);
        expect(list.sortOrder, 5);
      });

      test('defaults style to bullets when not provided', () {
        final list = ListModel(
          id: 'list-3',
          spaceId: 'space-3',
          userId: 'user-3',
          name: 'List',
        );

        expect(list.style, ListStyle.bullets);
      });

      test('defaults counts to 0 when not provided', () {
        final list = ListModel(
          id: 'list-4',
          spaceId: 'space-4',
          userId: 'user-4',
          name: 'Empty List',
        );

        expect(list.totalItemCount, 0);
        expect(list.checkedItemCount, 0);
      });

      test('initializes dates to now when not provided', () {
        final before = DateTime.now();
        final list = ListModel(
          id: 'list-5',
          spaceId: 'space-5',
          userId: 'user-5',
          name: 'List',
        );
        final after = DateTime.now();

        expect(
          list.createdAt.isAfter(before.subtract(const Duration(seconds: 1))),
          true,
        );
        expect(
          list.createdAt.isBefore(after.add(const Duration(seconds: 1))),
          true,
        );
        expect(
          list.updatedAt.isAfter(before.subtract(const Duration(seconds: 1))),
          true,
        );
        expect(
          list.updatedAt.isBefore(after.add(const Duration(seconds: 1))),
          true,
        );
      });
    });

    group('fromJson', () {
      test('deserializes from JSON with all fields', () {
        final json = {
          'id': 'list-1',
          'space_id': 'space-1',
          'user_id': 'user-1',
          'name': 'Groceries',
          'icon': '🛒',
          'style': 'checkboxes',
          'total_item_count': 12,
          'checked_item_count': 5,
          'created_at': '2025-01-01T10:00:00.000Z',
          'updated_at': '2025-01-02T15:30:00.000Z',
          'sort_order': 3,
        };

        final list = ListModel.fromJson(json);

        expect(list.id, 'list-1');
        expect(list.spaceId, 'space-1');
        expect(list.userId, 'user-1');
        expect(list.name, 'Groceries');
        expect(list.icon, '🛒');
        expect(list.style, ListStyle.checkboxes);
        expect(list.totalItemCount, 12);
        expect(list.checkedItemCount, 5);
        expect(list.createdAt, DateTime.parse('2025-01-01T10:00:00.000Z'));
        expect(list.updatedAt, DateTime.parse('2025-01-02T15:30:00.000Z'));
        expect(list.sortOrder, 3);
      });

      test('deserializes from JSON with minimal fields', () {
        final json = {
          'id': 'list-2',
          'space_id': 'space-2',
          'user_id': 'user-2',
          'name': 'Simple List',
          'created_at': '2025-01-01T10:00:00.000Z',
          'updated_at': '2025-01-01T10:00:00.000Z',
        };

        final list = ListModel.fromJson(json);

        expect(list.id, 'list-2');
        expect(list.spaceId, 'space-2');
        expect(list.userId, 'user-2');
        expect(list.name, 'Simple List');
        expect(list.icon, isNull);
        expect(list.style, ListStyle.bullets);
        expect(list.totalItemCount, 0);
        expect(list.checkedItemCount, 0);
        expect(list.sortOrder, 0);
      });

      test('handles null icon gracefully', () {
        final json = {
          'id': 'list-3',
          'space_id': 'space-3',
          'user_id': 'user-3',
          'name': 'List',
          'icon': null,
          'created_at': '2025-01-01T10:00:00.000Z',
          'updated_at': '2025-01-01T10:00:00.000Z',
        };

        final list = ListModel.fromJson(json);

        expect(list.icon, isNull);
      });

      test('handles null counts with default 0', () {
        final json = {
          'id': 'list-4',
          'space_id': 'space-4',
          'user_id': 'user-4',
          'name': 'List',
          'total_item_count': null,
          'checked_item_count': null,
          'created_at': '2025-01-01T10:00:00.000Z',
          'updated_at': '2025-01-01T10:00:00.000Z',
        };

        final list = ListModel.fromJson(json);

        expect(list.totalItemCount, 0);
        expect(list.checkedItemCount, 0);
      });

      test('handles null style with default bullets', () {
        final json = {
          'id': 'list-5',
          'space_id': 'space-5',
          'user_id': 'user-5',
          'name': 'List',
          'style': null,
          'created_at': '2025-01-01T10:00:00.000Z',
          'updated_at': '2025-01-01T10:00:00.000Z',
        };

        final list = ListModel.fromJson(json);

        expect(list.style, ListStyle.bullets);
      });

      test('handles missing sort_order with default 0', () {
        final json = {
          'id': 'list-6',
          'space_id': 'space-6',
          'user_id': 'user-6',
          'name': 'List',
          'created_at': '2025-01-01T10:00:00.000Z',
          'updated_at': '2025-01-01T10:00:00.000Z',
        };

        final list = ListModel.fromJson(json);

        expect(list.sortOrder, 0);
      });
    });

    group('toJson', () {
      test('serializes to JSON with all fields', () {
        final createdAt = DateTime(2025, 1, 1, 10);
        final updatedAt = DateTime(2025, 1, 2, 15, 30);

        final list = ListModel(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'Tasks',
          icon: '✅',
          style: ListStyle.numbered,
          totalItemCount: 20,
          checkedItemCount: 12,
          createdAt: createdAt,
          updatedAt: updatedAt,
          sortOrder: 2,
        );

        final json = list.toJson();

        expect(json['id'], 'list-1');
        expect(json['space_id'], 'space-1');
        expect(json['user_id'], 'user-1');
        expect(json['name'], 'Tasks');
        expect(json['icon'], '✅');
        expect(json['style'], 'numbered');
        expect(json['total_item_count'], 20);
        expect(json['checked_item_count'], 12);
        expect(json['created_at'], createdAt.toIso8601String());
        expect(json['updated_at'], updatedAt.toIso8601String());
        expect(json['sort_order'], 2);
      });

      test('serializes to JSON with minimal fields', () {
        final list = ListModel(
          id: 'list-2',
          spaceId: 'space-2',
          userId: 'user-2',
          name: 'Simple',
        );

        final json = list.toJson();

        expect(json['id'], 'list-2');
        expect(json['space_id'], 'space-2');
        expect(json['user_id'], 'user-2');
        expect(json['name'], 'Simple');
        expect(json['icon'], isNull);
        expect(json['style'], 'bullets');
        expect(json['total_item_count'], 0);
        expect(json['checked_item_count'], 0);
        expect(json['sort_order'], 0);
      });
    });

    group('copyWith', () {
      test('creates copy with updated name', () {
        final original = ListModel(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'Original',
        );

        final updated = original.copyWith(name: 'Updated');

        expect(updated.id, original.id);
        expect(updated.name, 'Updated');
        expect(updated.spaceId, original.spaceId);
        expect(updated.userId, original.userId);
      });

      test('creates copy with updated style', () {
        final original = ListModel(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'List',
        );

        final updated = original.copyWith(style: ListStyle.numbered);

        expect(updated.style, ListStyle.numbered);
      });

      test('creates copy with updated counts', () {
        final original = ListModel(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'List',
        );

        final updated = original.copyWith(
          totalItemCount: 10,
          checkedItemCount: 5,
        );

        expect(updated.totalItemCount, 10);
        expect(updated.checkedItemCount, 5);
      });

      test('can clear icon', () {
        final original = ListModel(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'List',
          icon: '🎯',
        );

        final updated = original.copyWith(clearIcon: true);

        expect(updated.icon, isNull);
      });

      test('preserves unchanged fields', () {
        final createdAt = DateTime(2025);
        final original = ListModel(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'Original',
          icon: '📌',
          style: ListStyle.checkboxes,
          totalItemCount: 5,
          checkedItemCount: 2,
          createdAt: createdAt,
          sortOrder: 3,
        );

        final updated = original.copyWith(name: 'Updated');

        expect(updated.icon, original.icon);
        expect(updated.style, original.style);
        expect(updated.totalItemCount, original.totalItemCount);
        expect(updated.checkedItemCount, original.checkedItemCount);
        expect(updated.createdAt, original.createdAt);
        expect(updated.sortOrder, original.sortOrder);
      });
    });

    group('getters', () {
      test('totalItems returns totalItemCount', () {
        final list = ListModel(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'List',
          totalItemCount: 15,
        );

        expect(list.totalItems, 15);
      });

      test('checkedItems returns checkedItemCount', () {
        final list = ListModel(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'List',
          checkedItemCount: 7,
        );

        expect(list.checkedItems, 7);
      });

      test('progress calculates correctly', () {
        final list = ListModel(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'List',
          totalItemCount: 10,
          checkedItemCount: 3,
        );

        expect(list.progress, 0.3);
      });

      test('progress returns 0.0 when no items', () {
        final list = ListModel(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'List',
        );

        expect(list.progress, 0.0);
      });

      test('progress returns 1.0 when all items checked', () {
        final list = ListModel(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'List',
          totalItemCount: 5,
          checkedItemCount: 5,
        );

        expect(list.progress, 1.0);
      });
    });

    group('equality', () {
      test('lists with same id are equal', () {
        final list1 = ListModel(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'Name 1',
        );

        final list2 = ListModel(
          id: 'list-1',
          spaceId: 'space-2',
          userId: 'user-2',
          name: 'Name 2',
        );

        expect(list1, equals(list2));
        expect(list1.hashCode, equals(list2.hashCode));
      });

      test('lists with different id are not equal', () {
        final list1 = ListModel(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'Name',
        );

        final list2 = ListModel(
          id: 'list-2',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'Name',
        );

        expect(list1, isNot(equals(list2)));
      });
    });

    group('toString', () {
      test('returns readable string representation', () {
        final list = ListModel(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'My List',
          style: ListStyle.checkboxes,
        );

        final string = list.toString();

        expect(string, contains('ListModel'));
        expect(string, contains('list-1'));
        expect(string, contains('My List'));
        expect(string, contains('space-1'));
        expect(string, contains('user-1'));
        expect(string, contains('checkboxes'));
      });
    });

    group('round-trip serialization', () {
      test('survives JSON round trip with all fields', () {
        final original = ListModel(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'Test List',
          icon: '🎯',
          style: ListStyle.simple,
          totalItemCount: 12,
          checkedItemCount: 6,
          createdAt: DateTime(2025, 1, 1, 10),
          updatedAt: DateTime(2025, 1, 2, 15),
          sortOrder: 7,
        );

        final json = original.toJson();
        final deserialized = ListModel.fromJson(json);

        expect(deserialized.id, original.id);
        expect(deserialized.spaceId, original.spaceId);
        expect(deserialized.userId, original.userId);
        expect(deserialized.name, original.name);
        expect(deserialized.icon, original.icon);
        expect(deserialized.style, original.style);
        expect(deserialized.totalItemCount, original.totalItemCount);
        expect(deserialized.checkedItemCount, original.checkedItemCount);
        expect(deserialized.createdAt, original.createdAt);
        expect(deserialized.updatedAt, original.updatedAt);
        expect(deserialized.sortOrder, original.sortOrder);
      });

      test('survives JSON round trip with minimal fields', () {
        final original = ListModel(
          id: 'list-2',
          spaceId: 'space-2',
          userId: 'user-2',
          name: 'Minimal',
        );

        final json = original.toJson();
        final deserialized = ListModel.fromJson(json);

        expect(deserialized.id, original.id);
        expect(deserialized.spaceId, original.spaceId);
        expect(deserialized.userId, original.userId);
        expect(deserialized.name, original.name);
        expect(deserialized.icon, isNull);
        expect(deserialized.style, ListStyle.bullets);
        expect(deserialized.totalItemCount, 0);
        expect(deserialized.checkedItemCount, 0);
      });
    });
  });
}
