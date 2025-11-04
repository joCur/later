import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/models/list_model.dart';
import 'package:later_mobile/data/models/list_item_model.dart';
import 'package:later_mobile/data/models/list_style.dart';

void main() {
  group('ListStyle', () {
    test('has correct values', () {
      expect(ListStyle.values.length, 3);
      expect(ListStyle.values, [
        ListStyle.bullets,
        ListStyle.numbered,
        ListStyle.checkboxes,
      ]);
    });

    test('toJson serializes to string correctly', () {
      expect(ListStyle.bullets.toJson(), 'bullets');
      expect(ListStyle.numbered.toJson(), 'numbered');
      expect(ListStyle.checkboxes.toJson(), 'checkboxes');
    });

    test('fromJson deserializes from string correctly', () {
      expect(ListStyleExtension.fromJson('bullets'), ListStyle.bullets);
      expect(ListStyleExtension.fromJson('numbered'), ListStyle.numbered);
      expect(ListStyleExtension.fromJson('checkboxes'), ListStyle.checkboxes);
    });

    test('fromJson handles unknown value with fallback', () {
      expect(ListStyleExtension.fromJson('unknown'), ListStyle.bullets);
    });
  });

  group('ListItem', () {
    group('construction', () {
      test('creates with all required fields', () {
        final item = ListItem(
          id: 'item-1',
          title: 'Buy groceries',
          sortOrder: 0,
        );

        expect(item.id, 'item-1');
        expect(item.title, 'Buy groceries');
        expect(item.notes, isNull);
        expect(item.isChecked, false);
        expect(item.sortOrder, 0);
      });

      test('creates with all optional fields', () {
        final item = ListItem(
          id: 'item-2',
          title: 'Complete documentation',
          notes: 'Include API examples and usage guidelines',
          isChecked: true,
          sortOrder: 5,
        );

        expect(item.id, 'item-2');
        expect(item.title, 'Complete documentation');
        expect(item.notes, 'Include API examples and usage guidelines');
        expect(item.isChecked, true);
        expect(item.sortOrder, 5);
      });

      test('defaults isChecked to false', () {
        final item = ListItem(id: 'item-3', title: 'Task', sortOrder: 0);

        expect(item.isChecked, false);
      });
    });

    group('JSON serialization', () {
      test('toJson produces correct format', () {
        final item = ListItem(
          id: 'item-4',
          title: 'Review pull request',
          notes: 'Check for security issues',
          sortOrder: 2,
        );

        final json = item.toJson();

        expect(json['id'], 'item-4');
        expect(json['title'], 'Review pull request');
        expect(json['notes'], 'Check for security issues');
        expect(json['isChecked'], false);
        expect(json['sortOrder'], 2);
      });

      test('toJson handles null notes', () {
        final item = ListItem(id: 'item-5', title: 'Simple item', sortOrder: 0);

        final json = item.toJson();

        expect(json['notes'], isNull);
      });

      test('fromJson deserializes correctly', () {
        final json = {
          'id': 'item-6',
          'title': 'Write tests',
          'notes': 'Cover all edge cases',
          'isChecked': true,
          'sortOrder': 3,
        };

        final item = ListItem.fromJson(json);

        expect(item.id, 'item-6');
        expect(item.title, 'Write tests');
        expect(item.notes, 'Cover all edge cases');
        expect(item.isChecked, true);
        expect(item.sortOrder, 3);
      });

      test('fromJson handles null optional fields', () {
        final json = {'id': 'item-7', 'title': 'Minimal item', 'sortOrder': 0};

        final item = ListItem.fromJson(json);

        expect(item.notes, isNull);
        expect(item.isChecked, false);
      });

      test('fromJson defaults isChecked to false when null', () {
        final json = {
          'id': 'item-8',
          'title': 'Item',
          'isChecked': null,
          'sortOrder': 0,
        };

        final item = ListItem.fromJson(json);

        expect(item.isChecked, false);
      });

      test('roundtrip JSON serialization preserves data', () {
        final original = ListItem(
          id: 'item-9',
          title: 'Design homepage',
          notes: 'Use brand colors and follow style guide',
          isChecked: true,
          sortOrder: 1,
        );

        final json = original.toJson();
        final restored = ListItem.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.title, original.title);
        expect(restored.notes, original.notes);
        expect(restored.isChecked, original.isChecked);
        expect(restored.sortOrder, original.sortOrder);
      });

      test('roundtrip with minimal data', () {
        final original = ListItem(
          id: 'item-10',
          title: 'Basic item',
          sortOrder: 0,
        );

        final json = original.toJson();
        final restored = ListItem.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.title, original.title);
        expect(restored.isChecked, original.isChecked);
        expect(restored.sortOrder, original.sortOrder);
      });
    });

    group('copyWith', () {
      test('updates specified fields only', () {
        final original = ListItem(
          id: 'item-11',
          title: 'Original title',
          notes: 'Original notes',
          sortOrder: 0,
        );

        final updated = original.copyWith(
          title: 'Updated title',
          isChecked: true,
        );

        expect(updated.id, original.id);
        expect(updated.title, 'Updated title');
        expect(updated.notes, original.notes);
        expect(updated.isChecked, true);
        expect(updated.sortOrder, original.sortOrder);
      });

      test('preserves unchanged fields', () {
        final original = ListItem(
          id: 'item-12',
          title: 'Title',
          notes: 'Notes',
          isChecked: true,
          sortOrder: 5,
        );

        final updated = original.copyWith(sortOrder: 10);

        expect(updated.id, original.id);
        expect(updated.title, original.title);
        expect(updated.notes, original.notes);
        expect(updated.isChecked, original.isChecked);
        expect(updated.sortOrder, 10);
      });

      test('can update notes', () {
        final original = ListItem(
          id: 'item-13',
          title: 'Item',
          notes: 'Old notes',
          sortOrder: 0,
        );

        final updated = original.copyWith(notes: 'New notes');

        expect(updated.notes, 'New notes');
      });

      test('clears notes with clearNotes flag', () {
        final original = ListItem(
          id: 'item-14',
          title: 'Item',
          notes: 'Some notes',
          sortOrder: 0,
        );

        final updated = original.copyWith(clearNotes: true);

        expect(updated.notes, isNull);
      });

      test('clearNotes flag takes precedence over notes parameter', () {
        final original = ListItem(
          id: 'item-15',
          title: 'Item',
          notes: 'Old notes',
          sortOrder: 0,
        );

        final updated = original.copyWith(notes: 'New notes', clearNotes: true);

        expect(updated.notes, isNull);
      });

      test('can update all fields', () {
        final original = ListItem(id: 'item-16', title: 'Old', sortOrder: 0);

        final updated = original.copyWith(
          id: 'item-17',
          title: 'New',
          notes: 'New notes',
          isChecked: true,
          sortOrder: 10,
        );

        expect(updated.id, 'item-17');
        expect(updated.title, 'New');
        expect(updated.notes, 'New notes');
        expect(updated.isChecked, true);
        expect(updated.sortOrder, 10);
      });
    });

    group('equality', () {
      test('equality is based on id only', () {
        final item1 = ListItem(
          id: 'same-id',
          title: 'Title 1',
          notes: 'Notes 1',
          sortOrder: 0,
        );

        final item2 = ListItem(
          id: 'same-id',
          title: 'Title 2',
          notes: 'Notes 2',
          isChecked: true,
          sortOrder: 10,
        );

        expect(item1, equals(item2));
        expect(item1.hashCode, equals(item2.hashCode));
      });

      test('different ids are not equal', () {
        final item1 = ListItem(id: 'id-1', title: 'Same title', sortOrder: 0);

        final item2 = ListItem(id: 'id-2', title: 'Same title', sortOrder: 0);

        expect(item1, isNot(equals(item2)));
      });

      test('identical items are equal', () {
        final item = ListItem(id: 'item-18', title: 'Item', sortOrder: 0);

        expect(item, equals(item));
      });
    });

    group('toString', () {
      test('includes key identifying fields', () {
        final item = ListItem(
          id: 'item-19',
          title: 'Review code',
          isChecked: true,
          sortOrder: 3,
        );

        final string = item.toString();

        expect(string, contains('item-19'));
        expect(string, contains('Review code'));
        expect(string, contains('true'));
        expect(string, contains('3'));
      });

      test('has readable format', () {
        final item = ListItem(id: 'item-20', title: 'Item', sortOrder: 0);

        final string = item.toString();

        expect(string, startsWith('ListItem('));
        expect(string, contains('id:'));
        expect(string, contains('title:'));
      });
    });

    group('edge cases', () {
      test('handles empty string title', () {
        final item = ListItem(id: 'item-21', title: '', sortOrder: 0);

        expect(item.title, '');
      });

      test('handles very long title', () {
        final longTitle = 'A' * 1000;
        final item = ListItem(id: 'item-22', title: longTitle, sortOrder: 0);

        expect(item.title, longTitle);
      });

      test('handles very long notes', () {
        final longNotes = 'B' * 5000;
        final item = ListItem(
          id: 'item-23',
          title: 'Item',
          notes: longNotes,
          sortOrder: 0,
        );

        expect(item.notes, longNotes);
      });

      test('handles negative sort order', () {
        final item = ListItem(id: 'item-24', title: 'Item', sortOrder: -1);

        expect(item.sortOrder, -1);
      });

      test('handles large sort order', () {
        final item = ListItem(id: 'item-25', title: 'Item', sortOrder: 999999);

        expect(item.sortOrder, 999999);
      });
    });
  });

  group('ListModel', () {
    group('construction', () {
      test('creates with all required fields', () {
        final list = ListModel(
          id: 'list-1',
          spaceId: 'space-1',
          name: 'Shopping List',
        );

        expect(list.id, 'list-1');
        expect(list.spaceId, 'space-1');
        expect(list.name, 'Shopping List');
        expect(list.icon, isNull);
        expect(list.items, isEmpty);
        expect(list.style, ListStyle.bullets);
        expect(list.createdAt, isA<DateTime>());
        expect(list.updatedAt, isA<DateTime>());
      });

      test('creates with all optional fields', () {
        final createdAt = DateTime(2025);
        final updatedAt = DateTime(2025, 10, 25);
        final items = [
          ListItem(id: 'item-1', title: 'Item 1', sortOrder: 0),
          ListItem(id: 'item-2', title: 'Item 2', sortOrder: 1),
        ];

        final list = ListModel(
          id: 'list-2',
          spaceId: 'space-2',
          name: 'Project Checklist',
          icon: 'checklist',
          items: items,
          style: ListStyle.checkboxes,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(list.id, 'list-2');
        expect(list.spaceId, 'space-2');
        expect(list.name, 'Project Checklist');
        expect(list.icon, 'checklist');
        expect(list.items, items);
        expect(list.style, ListStyle.checkboxes);
        expect(list.createdAt, createdAt);
        expect(list.updatedAt, updatedAt);
      });

      test('defaults items to empty list when null', () {
        final list = ListModel(
          id: 'list-3',
          spaceId: 'space-3',
          name: 'Empty List',
        );

        expect(list.items, isEmpty);
        expect(list.items, isA<List<ListItem>>());
      });

      test('defaults style to bullets', () {
        final list = ListModel(id: 'list-4', spaceId: 'space-4', name: 'List');

        expect(list.style, ListStyle.bullets);
      });

      test('defaults createdAt and updatedAt to now when null', () {
        final before = DateTime.now();
        final list = ListModel(id: 'list-5', spaceId: 'space-5', name: 'List');
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

    group('JSON serialization', () {
      test('toJson produces correct format', () {
        final createdAt = DateTime(2025, 1, 15, 10, 30);
        final updatedAt = DateTime(2025, 10, 25, 14, 45);
        final items = [
          ListItem(
            id: 'item-1',
            title: 'First item',
            notes: 'Important notes',
            sortOrder: 0,
          ),
          ListItem(
            id: 'item-2',
            title: 'Second item',
            isChecked: true,
            sortOrder: 1,
          ),
        ];

        final list = ListModel(
          id: 'list-6',
          spaceId: 'space-6',
          name: 'Meeting Agenda',
          icon: 'meeting',
          items: items,
          style: ListStyle.numbered,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final json = list.toJson();

        expect(json['id'], 'list-6');
        expect(json['spaceId'], 'space-6');
        expect(json['name'], 'Meeting Agenda');
        expect(json['icon'], 'meeting');
        expect(json['items'], isA<List<dynamic>>());
        expect(json['items'].length, 2);
        expect(json['style'], 'numbered');
        expect(json['createdAt'], createdAt.toIso8601String());
        expect(json['updatedAt'], updatedAt.toIso8601String());
      });

      test('toJson handles null icon', () {
        final list = ListModel(
          id: 'list-7',
          spaceId: 'space-7',
          name: 'Simple List',
        );

        final json = list.toJson();

        expect(json['icon'], isNull);
      });

      test('toJson serializes empty items list', () {
        final list = ListModel(id: 'list-8', spaceId: 'space-8', name: 'Empty');

        final json = list.toJson();

        expect(json['items'], isEmpty);
        expect(json['items'], isA<List<dynamic>>());
      });

      test('toJson serializes all list styles correctly', () {
        final bulletList = ListModel(
          id: 'list-9',
          spaceId: 'space-9',
          name: 'Bullet List',
        );

        final numberedList = ListModel(
          id: 'list-10',
          spaceId: 'space-10',
          name: 'Numbered List',
          style: ListStyle.numbered,
        );

        final checkboxList = ListModel(
          id: 'list-11',
          spaceId: 'space-11',
          name: 'Checkbox List',
          style: ListStyle.checkboxes,
        );

        expect(bulletList.toJson()['style'], 'bullets');
        expect(numberedList.toJson()['style'], 'numbered');
        expect(checkboxList.toJson()['style'], 'checkboxes');
      });

      test('fromJson deserializes correctly', () {
        final json = {
          'id': 'list-12',
          'spaceId': 'space-12',
          'name': 'Book List',
          'icon': 'book',
          'items': [
            {
              'id': 'item-1',
              'title': 'Read chapter 1',
              'isChecked': false,
              'sortOrder': 0,
            },
            {
              'id': 'item-2',
              'title': 'Read chapter 2',
              'notes': 'Focus on key concepts',
              'isChecked': true,
              'sortOrder': 1,
            },
          ],
          'style': 'checkboxes',
          'createdAt': '2025-09-01T08:00:00.000Z',
          'updatedAt': '2025-10-25T12:00:00.000Z',
        };

        final list = ListModel.fromJson(json);

        expect(list.id, 'list-12');
        expect(list.spaceId, 'space-12');
        expect(list.name, 'Book List');
        expect(list.icon, 'book');
        expect(list.items.length, 2);
        expect(list.items[0].title, 'Read chapter 1');
        expect(list.items[1].title, 'Read chapter 2');
        expect(list.style, ListStyle.checkboxes);
        expect(list.createdAt, DateTime.parse('2025-09-01T08:00:00.000Z'));
        expect(list.updatedAt, DateTime.parse('2025-10-25T12:00:00.000Z'));
      });

      test('fromJson handles null optional fields', () {
        final json = {
          'id': 'list-13',
          'spaceId': 'space-13',
          'name': 'Minimal List',
          'createdAt': '2025-10-25T10:00:00.000Z',
          'updatedAt': '2025-10-25T10:00:00.000Z',
        };

        final list = ListModel.fromJson(json);

        expect(list.icon, isNull);
        expect(list.items, isEmpty);
        expect(list.style, ListStyle.bullets);
      });

      test('fromJson defaults style to bullets when null', () {
        final json = {
          'id': 'list-14',
          'spaceId': 'space-14',
          'name': 'List',
          'style': null,
          'createdAt': '2025-10-25T10:00:00.000Z',
          'updatedAt': '2025-10-25T10:00:00.000Z',
        };

        final list = ListModel.fromJson(json);

        expect(list.style, ListStyle.bullets);
      });

      test('roundtrip JSON serialization preserves data', () {
        final createdAt = DateTime(2025, 5, 10, 9);
        final updatedAt = DateTime(2025, 10, 25, 15, 30);
        final items = [
          ListItem(
            id: 'item-1',
            title: 'Design wireframes',
            notes: 'Mobile-first approach',
            sortOrder: 0,
          ),
          ListItem(
            id: 'item-2',
            title: 'Review designs',
            isChecked: true,
            sortOrder: 1,
          ),
        ];

        final original = ListModel(
          id: 'list-15',
          spaceId: 'space-15',
          name: 'Design Tasks',
          icon: 'design',
          items: items,
          style: ListStyle.checkboxes,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final json = original.toJson();
        final restored = ListModel.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.spaceId, original.spaceId);
        expect(restored.name, original.name);
        expect(restored.icon, original.icon);
        expect(restored.items.length, original.items.length);
        expect(restored.style, original.style);
        expect(restored.createdAt, original.createdAt);
        expect(restored.updatedAt, original.updatedAt);
      });
    });

    group('copyWith', () {
      test('updates specified fields only', () {
        final original = ListModel(
          id: 'list-16',
          spaceId: 'space-16',
          name: 'Original Name',
          icon: 'star',
        );

        final updated = original.copyWith(name: 'Updated Name');

        expect(updated.id, original.id);
        expect(updated.spaceId, original.spaceId);
        expect(updated.name, 'Updated Name');
        expect(updated.icon, original.icon);
        expect(updated.items, original.items);
        expect(updated.style, original.style);
        expect(updated.createdAt, original.createdAt);
        expect(updated.updatedAt, original.updatedAt);
      });

      test('preserves unchanged fields', () {
        final createdAt = DateTime(2025);
        final updatedAt = DateTime(2025, 10, 25);
        final items = [ListItem(id: 'item-1', title: 'Item', sortOrder: 0)];

        final original = ListModel(
          id: 'list-17',
          spaceId: 'space-17',
          name: 'Name',
          icon: 'icon',
          items: items,
          style: ListStyle.numbered,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final newUpdatedAt = DateTime(2025, 10, 26);
        final updated = original.copyWith(updatedAt: newUpdatedAt);

        expect(updated.id, original.id);
        expect(updated.spaceId, original.spaceId);
        expect(updated.name, original.name);
        expect(updated.icon, original.icon);
        expect(updated.items, original.items);
        expect(updated.style, original.style);
        expect(updated.createdAt, original.createdAt);
        expect(updated.updatedAt, newUpdatedAt);
      });

      test('can update icon', () {
        final original = ListModel(
          id: 'list-18',
          spaceId: 'space-18',
          name: 'List',
          icon: 'old-icon',
        );

        final updated = original.copyWith(icon: 'new-icon');

        expect(updated.icon, 'new-icon');
      });

      test('clears icon with clearIcon flag', () {
        final original = ListModel(
          id: 'list-19',
          spaceId: 'space-19',
          name: 'List',
          icon: 'icon',
        );

        final updated = original.copyWith(clearIcon: true);

        expect(updated.icon, isNull);
      });

      test('clearIcon flag takes precedence over icon parameter', () {
        final original = ListModel(
          id: 'list-20',
          spaceId: 'space-20',
          name: 'List',
          icon: 'old-icon',
        );

        final updated = original.copyWith(icon: 'new-icon', clearIcon: true);

        expect(updated.icon, isNull);
      });

      test('can update all fields', () {
        final original = ListModel(
          id: 'list-21',
          spaceId: 'space-21',
          name: 'Old',
        );

        final newCreatedAt = DateTime(2025);
        final newUpdatedAt = DateTime(2025, 10, 26);
        final newItems = [
          ListItem(id: 'new-item', title: 'New Item', sortOrder: 0),
        ];

        final updated = original.copyWith(
          id: 'list-22',
          spaceId: 'space-22',
          name: 'New',
          icon: 'new-icon',
          items: newItems,
          style: ListStyle.numbered,
          createdAt: newCreatedAt,
          updatedAt: newUpdatedAt,
        );

        expect(updated.id, 'list-22');
        expect(updated.spaceId, 'space-22');
        expect(updated.name, 'New');
        expect(updated.icon, 'new-icon');
        expect(updated.items, newItems);
        expect(updated.style, ListStyle.numbered);
        expect(updated.createdAt, newCreatedAt);
        expect(updated.updatedAt, newUpdatedAt);
      });
    });

    group('computed properties', () {
      test('totalItems returns correct count for empty list', () {
        final list = ListModel(
          id: 'list-23',
          spaceId: 'space-23',
          name: 'Empty',
        );

        expect(list.totalItems, 0);
      });

      test('totalItems returns correct count for list with items', () {
        final items = [
          ListItem(id: 'item-1', title: 'Item 1', sortOrder: 0),
          ListItem(id: 'item-2', title: 'Item 2', sortOrder: 1),
          ListItem(id: 'item-3', title: 'Item 3', sortOrder: 2),
        ];

        final list = ListModel(
          id: 'list-24',
          spaceId: 'space-24',
          name: 'List',
          items: items,
        );

        expect(list.totalItems, 3);
      });

      test('checkedItems returns correct count when no items checked', () {
        final items = [
          ListItem(id: 'item-1', title: 'Item 1', sortOrder: 0),
          ListItem(id: 'item-2', title: 'Item 2', sortOrder: 1),
        ];

        final list = ListModel(
          id: 'list-25',
          spaceId: 'space-25',
          name: 'List',
          items: items,
          style: ListStyle.checkboxes,
        );

        expect(list.checkedItems, 0);
      });

      test('checkedItems returns correct count when some items checked', () {
        final items = [
          ListItem(
            id: 'item-1',
            title: 'Item 1',
            isChecked: true,
            sortOrder: 0,
          ),
          ListItem(id: 'item-2', title: 'Item 2', sortOrder: 1),
          ListItem(
            id: 'item-3',
            title: 'Item 3',
            isChecked: true,
            sortOrder: 2,
          ),
          ListItem(id: 'item-4', title: 'Item 4', sortOrder: 3),
        ];

        final list = ListModel(
          id: 'list-26',
          spaceId: 'space-26',
          name: 'List',
          items: items,
          style: ListStyle.checkboxes,
        );

        expect(list.checkedItems, 2);
      });

      test('checkedItems returns correct count when all items checked', () {
        final items = [
          ListItem(
            id: 'item-1',
            title: 'Item 1',
            isChecked: true,
            sortOrder: 0,
          ),
          ListItem(
            id: 'item-2',
            title: 'Item 2',
            isChecked: true,
            sortOrder: 1,
          ),
        ];

        final list = ListModel(
          id: 'list-27',
          spaceId: 'space-27',
          name: 'List',
          items: items,
          style: ListStyle.checkboxes,
        );

        expect(list.checkedItems, 2);
      });

      test('checkedItems works for non-checkbox styles', () {
        final items = [
          ListItem(
            id: 'item-1',
            title: 'Item 1',
            isChecked: true,
            sortOrder: 0,
          ),
          ListItem(id: 'item-2', title: 'Item 2', sortOrder: 1),
        ];

        final list = ListModel(
          id: 'list-28',
          spaceId: 'space-28',
          name: 'List',
          items: items,
        );

        expect(list.checkedItems, 1);
      });

      test('progress returns 0.0 when no items', () {
        final list = ListModel(
          id: 'list-29',
          spaceId: 'space-29',
          name: 'Empty',
          style: ListStyle.checkboxes,
        );

        expect(list.progress, 0.0);
      });

      test('progress returns 0.0 when no items checked', () {
        final items = [
          ListItem(id: 'item-1', title: 'Item 1', sortOrder: 0),
          ListItem(id: 'item-2', title: 'Item 2', sortOrder: 1),
        ];

        final list = ListModel(
          id: 'list-30',
          spaceId: 'space-30',
          name: 'List',
          items: items,
          style: ListStyle.checkboxes,
        );

        expect(list.progress, 0.0);
      });

      test('progress returns 1.0 when all items checked', () {
        final items = [
          ListItem(
            id: 'item-1',
            title: 'Item 1',
            isChecked: true,
            sortOrder: 0,
          ),
          ListItem(
            id: 'item-2',
            title: 'Item 2',
            isChecked: true,
            sortOrder: 1,
          ),
        ];

        final list = ListModel(
          id: 'list-31',
          spaceId: 'space-31',
          name: 'List',
          items: items,
          style: ListStyle.checkboxes,
        );

        expect(list.progress, 1.0);
      });

      test('progress calculates correctly for partial completion', () {
        final items = [
          ListItem(
            id: 'item-1',
            title: 'Item 1',
            isChecked: true,
            sortOrder: 0,
          ),
          ListItem(id: 'item-2', title: 'Item 2', sortOrder: 1),
          ListItem(id: 'item-3', title: 'Item 3', sortOrder: 2),
          ListItem(id: 'item-4', title: 'Item 4', sortOrder: 3),
        ];

        final list = ListModel(
          id: 'list-32',
          spaceId: 'space-32',
          name: 'List',
          items: items,
          style: ListStyle.checkboxes,
        );

        expect(list.progress, 0.25);
      });

      test('progress calculates correctly for 50% completion', () {
        final items = [
          ListItem(
            id: 'item-1',
            title: 'Item 1',
            isChecked: true,
            sortOrder: 0,
          ),
          ListItem(
            id: 'item-2',
            title: 'Item 2',
            isChecked: true,
            sortOrder: 1,
          ),
          ListItem(id: 'item-3', title: 'Item 3', sortOrder: 2),
          ListItem(id: 'item-4', title: 'Item 4', sortOrder: 3),
        ];

        final list = ListModel(
          id: 'list-33',
          spaceId: 'space-33',
          name: 'List',
          items: items,
          style: ListStyle.checkboxes,
        );

        expect(list.progress, 0.5);
      });

      test('progress avoids division by zero', () {
        final list = ListModel(
          id: 'list-34',
          spaceId: 'space-34',
          name: 'Empty',
        );

        expect(() => list.progress, returnsNormally);
        expect(list.progress, 0.0);
      });

      test('progress works for non-checkbox styles', () {
        final items = [
          ListItem(
            id: 'item-1',
            title: 'Item 1',
            isChecked: true,
            sortOrder: 0,
          ),
          ListItem(id: 'item-2', title: 'Item 2', sortOrder: 1),
        ];

        final list = ListModel(
          id: 'list-35',
          spaceId: 'space-35',
          name: 'List',
          items: items,
        );

        expect(list.progress, 0.5);
      });
    });

    group('equality', () {
      test('equality is based on id only', () {
        final list1 = ListModel(
          id: 'same-id',
          spaceId: 'space-1',
          name: 'Name 1',
          icon: 'icon-1',
          items: [ListItem(id: 'item-1', title: 'Item', sortOrder: 0)],
        );

        final list2 = ListModel(
          id: 'same-id',
          spaceId: 'space-2',
          name: 'Name 2',
          icon: 'icon-2',
          style: ListStyle.numbered,
        );

        expect(list1, equals(list2));
        expect(list1.hashCode, equals(list2.hashCode));
      });

      test('different ids are not equal', () {
        final list1 = ListModel(
          id: 'id-1',
          spaceId: 'space-1',
          name: 'Same name',
        );

        final list2 = ListModel(
          id: 'id-2',
          spaceId: 'space-1',
          name: 'Same name',
        );

        expect(list1, isNot(equals(list2)));
      });

      test('identical lists are equal', () {
        final list = ListModel(
          id: 'list-36',
          spaceId: 'space-36',
          name: 'List',
        );

        expect(list, equals(list));
      });
    });

    group('toString', () {
      test('includes key identifying fields', () {
        final items = [
          ListItem(
            id: 'item-1',
            title: 'Item 1',
            isChecked: true,
            sortOrder: 0,
          ),
          ListItem(id: 'item-2', title: 'Item 2', sortOrder: 1),
        ];

        final list = ListModel(
          id: 'list-37',
          spaceId: 'space-37',
          name: 'My List',
          items: items,
          style: ListStyle.checkboxes,
        );

        final string = list.toString();

        expect(string, contains('list-37'));
        expect(string, contains('My List'));
        expect(string, contains('space-37'));
        expect(string, contains('checkboxes'));
        expect(string, contains('2')); // totalItems
        expect(string, contains('1')); // checkedItems
      });

      test('has readable format', () {
        final list = ListModel(
          id: 'list-38',
          spaceId: 'space-38',
          name: 'List',
        );

        final string = list.toString();

        expect(string, startsWith('ListModel('));
        expect(string, contains('id:'));
        expect(string, contains('name:'));
        expect(string, contains('spaceId:'));
        expect(string, contains('style:'));
      });
    });

    group('edge cases', () {
      test('handles empty string name', () {
        final list = ListModel(id: 'list-39', spaceId: 'space-39', name: '');

        expect(list.name, '');
      });

      test('handles very long name', () {
        final longName = 'A' * 1000;
        final list = ListModel(
          id: 'list-40',
          spaceId: 'space-40',
          name: longName,
        );

        expect(list.name, longName);
      });

      test('handles emoji icon', () {
        final list = ListModel(
          id: 'list-41',
          spaceId: 'space-41',
          name: 'List',
          icon: '📝',
        );

        expect(list.icon, '📝');
      });

      test('handles many items', () {
        final manyItems = List.generate(
          100,
          (i) => ListItem(id: 'item-$i', title: 'Item $i', sortOrder: i),
        );

        final list = ListModel(
          id: 'list-42',
          spaceId: 'space-42',
          name: 'Many Items',
          items: manyItems,
        );

        expect(list.totalItems, 100);
        expect(list.items.length, 100);
      });

      test('handles single item', () {
        final items = [
          ListItem(id: 'item-1', title: 'Only item', sortOrder: 0),
        ];

        final list = ListModel(
          id: 'list-43',
          spaceId: 'space-43',
          name: 'Single Item',
          items: items,
        );

        expect(list.totalItems, 1);
      });

      test('handles all list styles', () {
        final bulletList = ListModel(
          id: 'list-44',
          spaceId: 'space-44',
          name: 'Bullet',
        );

        final numberedList = ListModel(
          id: 'list-45',
          spaceId: 'space-45',
          name: 'Numbered',
          style: ListStyle.numbered,
        );

        final checkboxList = ListModel(
          id: 'list-46',
          spaceId: 'space-46',
          name: 'Checkbox',
          style: ListStyle.checkboxes,
        );

        expect(bulletList.style, ListStyle.bullets);
        expect(numberedList.style, ListStyle.numbered);
        expect(checkboxList.style, ListStyle.checkboxes);
      });
    });
  });
}
