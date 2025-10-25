import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/models/todo_list_model.dart';

void main() {
  group('TodoPriority', () {
    test('has correct values', () {
      expect(TodoPriority.values.length, 3);
      expect(TodoPriority.values, [
        TodoPriority.low,
        TodoPriority.medium,
        TodoPriority.high,
      ]);
    });

    test('serializes to string correctly', () {
      expect(TodoPriority.low.toString().split('.').last, 'low');
      expect(TodoPriority.medium.toString().split('.').last, 'medium');
      expect(TodoPriority.high.toString().split('.').last, 'high');
    });
  });

  group('TodoItem', () {
    group('construction', () {
      test('creates with all required fields', () {
        final item = TodoItem(
          id: 'todo-1',
          title: 'Buy groceries',
          sortOrder: 0,
        );

        expect(item.id, 'todo-1');
        expect(item.title, 'Buy groceries');
        expect(item.description, isNull);
        expect(item.isCompleted, false);
        expect(item.dueDate, isNull);
        expect(item.priority, isNull);
        expect(item.tags, isEmpty);
        expect(item.sortOrder, 0);
      });

      test('creates with all optional fields', () {
        final dueDate = DateTime(2025, 12, 31, 23, 59);
        final item = TodoItem(
          id: 'todo-2',
          title: 'Complete project',
          description: 'Finish the quarterly report and submit to management',
          isCompleted: true,
          dueDate: dueDate,
          priority: TodoPriority.high,
          tags: ['work', 'urgent', 'q4'],
          sortOrder: 5,
        );

        expect(item.id, 'todo-2');
        expect(item.title, 'Complete project');
        expect(item.description, 'Finish the quarterly report and submit to management');
        expect(item.isCompleted, true);
        expect(item.dueDate, dueDate);
        expect(item.priority, TodoPriority.high);
        expect(item.tags, ['work', 'urgent', 'q4']);
        expect(item.sortOrder, 5);
      });

      test('defaults tags to empty list when null', () {
        final item = TodoItem(
          id: 'todo-3',
          title: 'Test task',
          tags: null,
          sortOrder: 0,
        );

        expect(item.tags, isEmpty);
        expect(item.tags, isA<List<String>>());
      });

      test('defaults isCompleted to false', () {
        final item = TodoItem(
          id: 'todo-4',
          title: 'Task',
          sortOrder: 0,
        );

        expect(item.isCompleted, false);
      });
    });

    group('JSON serialization', () {
      test('toJson produces correct format', () {
        final dueDate = DateTime(2025, 11, 15, 10, 30);
        final item = TodoItem(
          id: 'todo-5',
          title: 'Review pull request',
          description: 'Check the new authentication feature',
          isCompleted: false,
          dueDate: dueDate,
          priority: TodoPriority.medium,
          tags: ['development', 'review'],
          sortOrder: 2,
        );

        final json = item.toJson();

        expect(json['id'], 'todo-5');
        expect(json['title'], 'Review pull request');
        expect(json['description'], 'Check the new authentication feature');
        expect(json['isCompleted'], false);
        expect(json['dueDate'], dueDate.toIso8601String());
        expect(json['priority'], 'medium');
        expect(json['tags'], ['development', 'review']);
        expect(json['sortOrder'], 2);
      });

      test('toJson handles null optional fields', () {
        final item = TodoItem(
          id: 'todo-6',
          title: 'Simple task',
          sortOrder: 0,
        );

        final json = item.toJson();

        expect(json['description'], isNull);
        expect(json['dueDate'], isNull);
        expect(json['priority'], isNull);
        expect(json['tags'], isEmpty);
      });

      test('fromJson deserializes correctly', () {
        final json = {
          'id': 'todo-7',
          'title': 'Write documentation',
          'description': 'Update API docs with new endpoints',
          'isCompleted': true,
          'dueDate': '2025-10-20T15:00:00.000Z',
          'priority': 'high',
          'tags': ['documentation', 'api'],
          'sortOrder': 3,
        };

        final item = TodoItem.fromJson(json);

        expect(item.id, 'todo-7');
        expect(item.title, 'Write documentation');
        expect(item.description, 'Update API docs with new endpoints');
        expect(item.isCompleted, true);
        expect(item.dueDate, DateTime.parse('2025-10-20T15:00:00.000Z'));
        expect(item.priority, TodoPriority.high);
        expect(item.tags, ['documentation', 'api']);
        expect(item.sortOrder, 3);
      });

      test('fromJson handles null optional fields', () {
        final json = {
          'id': 'todo-8',
          'title': 'Minimal task',
          'sortOrder': 0,
        };

        final item = TodoItem.fromJson(json);

        expect(item.description, isNull);
        expect(item.isCompleted, false);
        expect(item.dueDate, isNull);
        expect(item.priority, isNull);
        expect(item.tags, isEmpty);
      });

      test('fromJson defaults isCompleted to false when null', () {
        final json = {
          'id': 'todo-9',
          'title': 'Task',
          'isCompleted': null,
          'sortOrder': 0,
        };

        final item = TodoItem.fromJson(json);

        expect(item.isCompleted, false);
      });

      test('fromJson handles unknown priority with fallback', () {
        final json = {
          'id': 'todo-10',
          'title': 'Task',
          'priority': 'unknown-priority',
          'sortOrder': 0,
        };

        final item = TodoItem.fromJson(json);

        expect(item.priority, TodoPriority.medium);
      });

      test('roundtrip JSON serialization preserves data', () {
        final dueDate = DateTime(2025, 6, 1, 9, 0);
        final original = TodoItem(
          id: 'todo-11',
          title: 'Team meeting',
          description: 'Discuss Q2 goals and objectives',
          isCompleted: false,
          dueDate: dueDate,
          priority: TodoPriority.high,
          tags: ['meeting', 'team', 'planning'],
          sortOrder: 1,
        );

        final json = original.toJson();
        final restored = TodoItem.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.title, original.title);
        expect(restored.description, original.description);
        expect(restored.isCompleted, original.isCompleted);
        expect(restored.dueDate, original.dueDate);
        expect(restored.priority, original.priority);
        expect(restored.tags, original.tags);
        expect(restored.sortOrder, original.sortOrder);
      });

      test('roundtrip with minimal data', () {
        final original = TodoItem(
          id: 'todo-12',
          title: 'Basic task',
          sortOrder: 0,
        );

        final json = original.toJson();
        final restored = TodoItem.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.title, original.title);
        expect(restored.isCompleted, original.isCompleted);
        expect(restored.sortOrder, original.sortOrder);
      });
    });

    group('copyWith', () {
      test('updates specified fields only', () {
        final original = TodoItem(
          id: 'todo-13',
          title: 'Original title',
          description: 'Original description',
          isCompleted: false,
          priority: TodoPriority.low,
          tags: ['tag1'],
          sortOrder: 0,
        );

        final updated = original.copyWith(
          title: 'Updated title',
          isCompleted: true,
        );

        expect(updated.id, original.id);
        expect(updated.title, 'Updated title');
        expect(updated.description, original.description);
        expect(updated.isCompleted, true);
        expect(updated.priority, original.priority);
        expect(updated.tags, original.tags);
        expect(updated.sortOrder, original.sortOrder);
      });

      test('preserves unchanged fields', () {
        final dueDate = DateTime(2025, 12, 1);
        final original = TodoItem(
          id: 'todo-14',
          title: 'Task',
          description: 'Description',
          isCompleted: true,
          dueDate: dueDate,
          priority: TodoPriority.high,
          tags: ['work', 'urgent'],
          sortOrder: 5,
        );

        final updated = original.copyWith(sortOrder: 10);

        expect(updated.id, original.id);
        expect(updated.title, original.title);
        expect(updated.description, original.description);
        expect(updated.isCompleted, original.isCompleted);
        expect(updated.dueDate, original.dueDate);
        expect(updated.priority, original.priority);
        expect(updated.tags, original.tags);
        expect(updated.sortOrder, 10);
      });

      test('can update dueDate', () {
        final original = TodoItem(
          id: 'todo-15',
          title: 'Task',
          dueDate: DateTime(2025, 10, 1),
          sortOrder: 0,
        );

        final newDueDate = DateTime(2025, 11, 1);
        final updated = original.copyWith(dueDate: newDueDate);

        expect(updated.dueDate, newDueDate);
      });

      test('clears dueDate with clearDueDate flag', () {
        final original = TodoItem(
          id: 'todo-16',
          title: 'Task',
          dueDate: DateTime(2025, 10, 1),
          sortOrder: 0,
        );

        final updated = original.copyWith(clearDueDate: true);

        expect(updated.dueDate, isNull);
      });

      test('clears priority with clearPriority flag', () {
        final original = TodoItem(
          id: 'todo-17',
          title: 'Task',
          priority: TodoPriority.high,
          sortOrder: 0,
        );

        final updated = original.copyWith(clearPriority: true);

        expect(updated.priority, isNull);
      });

      test('clearDueDate flag takes precedence over dueDate parameter', () {
        final original = TodoItem(
          id: 'todo-18',
          title: 'Task',
          dueDate: DateTime(2025, 10, 1),
          sortOrder: 0,
        );

        final updated = original.copyWith(
          dueDate: DateTime(2025, 11, 1),
          clearDueDate: true,
        );

        expect(updated.dueDate, isNull);
      });

      test('clearPriority flag takes precedence over priority parameter', () {
        final original = TodoItem(
          id: 'todo-19',
          title: 'Task',
          priority: TodoPriority.low,
          sortOrder: 0,
        );

        final updated = original.copyWith(
          priority: TodoPriority.high,
          clearPriority: true,
        );

        expect(updated.priority, isNull);
      });

      test('can update all fields', () {
        final original = TodoItem(
          id: 'todo-20',
          title: 'Old',
          sortOrder: 0,
        );

        final newDueDate = DateTime(2025, 12, 31);
        final updated = original.copyWith(
          id: 'todo-21',
          title: 'New',
          description: 'New description',
          isCompleted: true,
          dueDate: newDueDate,
          priority: TodoPriority.high,
          tags: ['new', 'updated'],
          sortOrder: 10,
        );

        expect(updated.id, 'todo-21');
        expect(updated.title, 'New');
        expect(updated.description, 'New description');
        expect(updated.isCompleted, true);
        expect(updated.dueDate, newDueDate);
        expect(updated.priority, TodoPriority.high);
        expect(updated.tags, ['new', 'updated']);
        expect(updated.sortOrder, 10);
      });
    });

    group('equality', () {
      test('equality is based on id only', () {
        final item1 = TodoItem(
          id: 'same-id',
          title: 'Title 1',
          description: 'Description 1',
          isCompleted: false,
          priority: TodoPriority.low,
          sortOrder: 0,
        );

        final item2 = TodoItem(
          id: 'same-id',
          title: 'Title 2',
          description: 'Description 2',
          isCompleted: true,
          priority: TodoPriority.high,
          sortOrder: 10,
        );

        expect(item1, equals(item2));
        expect(item1.hashCode, equals(item2.hashCode));
      });

      test('different ids are not equal', () {
        final item1 = TodoItem(
          id: 'id-1',
          title: 'Same title',
          sortOrder: 0,
        );

        final item2 = TodoItem(
          id: 'id-2',
          title: 'Same title',
          sortOrder: 0,
        );

        expect(item1, isNot(equals(item2)));
      });

      test('identical items are equal', () {
        final item = TodoItem(
          id: 'todo-22',
          title: 'Task',
          sortOrder: 0,
        );

        expect(item, equals(item));
      });
    });

    group('toString', () {
      test('includes key identifying fields', () {
        final item = TodoItem(
          id: 'todo-23',
          title: 'Review code',
          isCompleted: true,
          sortOrder: 3,
        );

        final string = item.toString();

        expect(string, contains('todo-23'));
        expect(string, contains('Review code'));
        expect(string, contains('true'));
        expect(string, contains('3'));
      });

      test('has readable format', () {
        final item = TodoItem(
          id: 'todo-24',
          title: 'Task',
          sortOrder: 0,
        );

        final string = item.toString();

        expect(string, startsWith('TodoItem('));
        expect(string, contains('id:'));
        expect(string, contains('title:'));
      });
    });

    group('edge cases', () {
      test('handles empty string title', () {
        final item = TodoItem(
          id: 'todo-25',
          title: '',
          sortOrder: 0,
        );

        expect(item.title, '');
      });

      test('handles very long title', () {
        final longTitle = 'A' * 1000;
        final item = TodoItem(
          id: 'todo-26',
          title: longTitle,
          sortOrder: 0,
        );

        expect(item.title, longTitle);
      });

      test('handles past due date', () {
        final pastDate = DateTime(2020, 1, 1);
        final item = TodoItem(
          id: 'todo-27',
          title: 'Task',
          dueDate: pastDate,
          sortOrder: 0,
        );

        expect(item.dueDate, pastDate);
      });

      test('handles future due date', () {
        final futureDate = DateTime(2030, 12, 31);
        final item = TodoItem(
          id: 'todo-28',
          title: 'Task',
          dueDate: futureDate,
          sortOrder: 0,
        );

        expect(item.dueDate, futureDate);
      });

      test('handles empty tags list', () {
        final item = TodoItem(
          id: 'todo-29',
          title: 'Task',
          tags: [],
          sortOrder: 0,
        );

        expect(item.tags, isEmpty);
      });

      test('handles many tags', () {
        final manyTags = List.generate(50, (i) => 'tag$i');
        final item = TodoItem(
          id: 'todo-30',
          title: 'Task',
          tags: manyTags,
          sortOrder: 0,
        );

        expect(item.tags, manyTags);
        expect(item.tags.length, 50);
      });

      test('handles negative sort order', () {
        final item = TodoItem(
          id: 'todo-31',
          title: 'Task',
          sortOrder: -1,
        );

        expect(item.sortOrder, -1);
      });

      test('handles large sort order', () {
        final item = TodoItem(
          id: 'todo-32',
          title: 'Task',
          sortOrder: 999999,
        );

        expect(item.sortOrder, 999999);
      });
    });
  });

  group('TodoList', () {
    group('construction', () {
      test('creates with all required fields', () {
        final list = TodoList(
          id: 'list-1',
          spaceId: 'space-1',
          name: 'Work Tasks',
        );

        expect(list.id, 'list-1');
        expect(list.spaceId, 'space-1');
        expect(list.name, 'Work Tasks');
        expect(list.description, isNull);
        expect(list.items, isEmpty);
        expect(list.createdAt, isA<DateTime>());
        expect(list.updatedAt, isA<DateTime>());
      });

      test('creates with all optional fields', () {
        final createdAt = DateTime(2025, 1, 1);
        final updatedAt = DateTime(2025, 10, 25);
        final items = [
          TodoItem(id: 'item-1', title: 'Task 1', sortOrder: 0),
          TodoItem(id: 'item-2', title: 'Task 2', sortOrder: 1),
        ];

        final list = TodoList(
          id: 'list-2',
          spaceId: 'space-2',
          name: 'Project Alpha',
          description: 'Tasks for the new product launch',
          items: items,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(list.id, 'list-2');
        expect(list.spaceId, 'space-2');
        expect(list.name, 'Project Alpha');
        expect(list.description, 'Tasks for the new product launch');
        expect(list.items, items);
        expect(list.createdAt, createdAt);
        expect(list.updatedAt, updatedAt);
      });

      test('defaults items to empty list when null', () {
        final list = TodoList(
          id: 'list-3',
          spaceId: 'space-3',
          name: 'Empty List',
          items: null,
        );

        expect(list.items, isEmpty);
        expect(list.items, isA<List<TodoItem>>());
      });

      test('defaults createdAt and updatedAt to now when null', () {
        final before = DateTime.now();
        final list = TodoList(
          id: 'list-4',
          spaceId: 'space-4',
          name: 'List',
        );
        final after = DateTime.now();

        expect(list.createdAt.isAfter(before.subtract(Duration(seconds: 1))), true);
        expect(list.createdAt.isBefore(after.add(Duration(seconds: 1))), true);
        expect(list.updatedAt.isAfter(before.subtract(Duration(seconds: 1))), true);
        expect(list.updatedAt.isBefore(after.add(Duration(seconds: 1))), true);
      });
    });

    group('JSON serialization', () {
      test('toJson produces correct format', () {
        final createdAt = DateTime(2025, 1, 15, 10, 30);
        final updatedAt = DateTime(2025, 10, 25, 14, 45);
        final items = [
          TodoItem(
            id: 'item-1',
            title: 'First task',
            description: 'Complete by Friday',
            isCompleted: false,
            priority: TodoPriority.high,
            tags: ['urgent'],
            sortOrder: 0,
          ),
          TodoItem(
            id: 'item-2',
            title: 'Second task',
            isCompleted: true,
            sortOrder: 1,
          ),
        ];

        final list = TodoList(
          id: 'list-5',
          spaceId: 'space-5',
          name: 'Q4 Goals',
          description: 'Fourth quarter objectives',
          items: items,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final json = list.toJson();

        expect(json['id'], 'list-5');
        expect(json['spaceId'], 'space-5');
        expect(json['name'], 'Q4 Goals');
        expect(json['description'], 'Fourth quarter objectives');
        expect(json['items'], isA<List>());
        expect(json['items'].length, 2);
        expect(json['createdAt'], createdAt.toIso8601String());
        expect(json['updatedAt'], updatedAt.toIso8601String());
      });

      test('toJson handles null description', () {
        final list = TodoList(
          id: 'list-6',
          spaceId: 'space-6',
          name: 'Simple List',
        );

        final json = list.toJson();

        expect(json['description'], isNull);
      });

      test('toJson serializes empty items list', () {
        final list = TodoList(
          id: 'list-7',
          spaceId: 'space-7',
          name: 'Empty',
        );

        final json = list.toJson();

        expect(json['items'], isEmpty);
        expect(json['items'], isA<List>());
      });

      test('fromJson deserializes correctly', () {
        final json = {
          'id': 'list-8',
          'spaceId': 'space-8',
          'name': 'Shopping List',
          'description': 'Grocery shopping for the week',
          'items': [
            {
              'id': 'item-1',
              'title': 'Buy milk',
              'isCompleted': false,
              'sortOrder': 0,
            },
            {
              'id': 'item-2',
              'title': 'Buy bread',
              'description': 'Whole wheat',
              'isCompleted': true,
              'priority': 'medium',
              'tags': ['grocery'],
              'sortOrder': 1,
            },
          ],
          'createdAt': '2025-09-01T08:00:00.000Z',
          'updatedAt': '2025-10-25T12:00:00.000Z',
        };

        final list = TodoList.fromJson(json);

        expect(list.id, 'list-8');
        expect(list.spaceId, 'space-8');
        expect(list.name, 'Shopping List');
        expect(list.description, 'Grocery shopping for the week');
        expect(list.items.length, 2);
        expect(list.items[0].title, 'Buy milk');
        expect(list.items[1].title, 'Buy bread');
        expect(list.createdAt, DateTime.parse('2025-09-01T08:00:00.000Z'));
        expect(list.updatedAt, DateTime.parse('2025-10-25T12:00:00.000Z'));
      });

      test('fromJson handles null optional fields', () {
        final json = {
          'id': 'list-9',
          'spaceId': 'space-9',
          'name': 'Minimal List',
          'createdAt': '2025-10-25T10:00:00.000Z',
          'updatedAt': '2025-10-25T10:00:00.000Z',
        };

        final list = TodoList.fromJson(json);

        expect(list.description, isNull);
        expect(list.items, isEmpty);
      });

      test('roundtrip JSON serialization preserves data', () {
        final createdAt = DateTime(2025, 5, 10, 9, 0);
        final updatedAt = DateTime(2025, 10, 25, 15, 30);
        final items = [
          TodoItem(
            id: 'item-1',
            title: 'Design mockups',
            description: 'Create wireframes for homepage',
            isCompleted: false,
            dueDate: DateTime(2025, 11, 1),
            priority: TodoPriority.high,
            tags: ['design', 'ux'],
            sortOrder: 0,
          ),
          TodoItem(
            id: 'item-2',
            title: 'Review feedback',
            isCompleted: true,
            priority: TodoPriority.low,
            sortOrder: 1,
          ),
        ];

        final original = TodoList(
          id: 'list-10',
          spaceId: 'space-10',
          name: 'Design Sprint',
          description: 'Week 1 design tasks',
          items: items,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final json = original.toJson();
        final restored = TodoList.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.spaceId, original.spaceId);
        expect(restored.name, original.name);
        expect(restored.description, original.description);
        expect(restored.items.length, original.items.length);
        expect(restored.createdAt, original.createdAt);
        expect(restored.updatedAt, original.updatedAt);
      });
    });

    group('copyWith', () {
      test('updates specified fields only', () {
        final original = TodoList(
          id: 'list-11',
          spaceId: 'space-11',
          name: 'Original Name',
          description: 'Original description',
        );

        final updated = original.copyWith(
          name: 'Updated Name',
        );

        expect(updated.id, original.id);
        expect(updated.spaceId, original.spaceId);
        expect(updated.name, 'Updated Name');
        expect(updated.description, original.description);
        expect(updated.items, original.items);
        expect(updated.createdAt, original.createdAt);
        expect(updated.updatedAt, original.updatedAt);
      });

      test('preserves unchanged fields', () {
        final createdAt = DateTime(2025, 1, 1);
        final updatedAt = DateTime(2025, 10, 25);
        final items = [
          TodoItem(id: 'item-1', title: 'Task', sortOrder: 0),
        ];

        final original = TodoList(
          id: 'list-12',
          spaceId: 'space-12',
          name: 'Name',
          description: 'Description',
          items: items,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final newUpdatedAt = DateTime(2025, 10, 26);
        final updated = original.copyWith(updatedAt: newUpdatedAt);

        expect(updated.id, original.id);
        expect(updated.spaceId, original.spaceId);
        expect(updated.name, original.name);
        expect(updated.description, original.description);
        expect(updated.items, original.items);
        expect(updated.createdAt, original.createdAt);
        expect(updated.updatedAt, newUpdatedAt);
      });

      test('can update all fields', () {
        final original = TodoList(
          id: 'list-13',
          spaceId: 'space-13',
          name: 'Old',
        );

        final newCreatedAt = DateTime(2025, 1, 1);
        final newUpdatedAt = DateTime(2025, 10, 26);
        final newItems = [
          TodoItem(id: 'new-item', title: 'New Task', sortOrder: 0),
        ];

        final updated = original.copyWith(
          id: 'list-14',
          spaceId: 'space-14',
          name: 'New',
          description: 'New description',
          items: newItems,
          createdAt: newCreatedAt,
          updatedAt: newUpdatedAt,
        );

        expect(updated.id, 'list-14');
        expect(updated.spaceId, 'space-14');
        expect(updated.name, 'New');
        expect(updated.description, 'New description');
        expect(updated.items, newItems);
        expect(updated.createdAt, newCreatedAt);
        expect(updated.updatedAt, newUpdatedAt);
      });
    });

    group('computed properties', () {
      test('totalItems returns correct count for empty list', () {
        final list = TodoList(
          id: 'list-15',
          spaceId: 'space-15',
          name: 'Empty',
        );

        expect(list.totalItems, 0);
      });

      test('totalItems returns correct count for list with items', () {
        final items = [
          TodoItem(id: 'item-1', title: 'Task 1', sortOrder: 0),
          TodoItem(id: 'item-2', title: 'Task 2', sortOrder: 1),
          TodoItem(id: 'item-3', title: 'Task 3', sortOrder: 2),
        ];

        final list = TodoList(
          id: 'list-16',
          spaceId: 'space-16',
          name: 'List',
          items: items,
        );

        expect(list.totalItems, 3);
      });

      test('completedItems returns correct count when no items completed', () {
        final items = [
          TodoItem(id: 'item-1', title: 'Task 1', isCompleted: false, sortOrder: 0),
          TodoItem(id: 'item-2', title: 'Task 2', isCompleted: false, sortOrder: 1),
        ];

        final list = TodoList(
          id: 'list-17',
          spaceId: 'space-17',
          name: 'List',
          items: items,
        );

        expect(list.completedItems, 0);
      });

      test('completedItems returns correct count when some items completed', () {
        final items = [
          TodoItem(id: 'item-1', title: 'Task 1', isCompleted: true, sortOrder: 0),
          TodoItem(id: 'item-2', title: 'Task 2', isCompleted: false, sortOrder: 1),
          TodoItem(id: 'item-3', title: 'Task 3', isCompleted: true, sortOrder: 2),
          TodoItem(id: 'item-4', title: 'Task 4', isCompleted: false, sortOrder: 3),
        ];

        final list = TodoList(
          id: 'list-18',
          spaceId: 'space-18',
          name: 'List',
          items: items,
        );

        expect(list.completedItems, 2);
      });

      test('completedItems returns correct count when all items completed', () {
        final items = [
          TodoItem(id: 'item-1', title: 'Task 1', isCompleted: true, sortOrder: 0),
          TodoItem(id: 'item-2', title: 'Task 2', isCompleted: true, sortOrder: 1),
        ];

        final list = TodoList(
          id: 'list-19',
          spaceId: 'space-19',
          name: 'List',
          items: items,
        );

        expect(list.completedItems, 2);
      });

      test('progress returns 0.0 when no items', () {
        final list = TodoList(
          id: 'list-20',
          spaceId: 'space-20',
          name: 'Empty',
        );

        expect(list.progress, 0.0);
      });

      test('progress returns 0.0 when no items completed', () {
        final items = [
          TodoItem(id: 'item-1', title: 'Task 1', isCompleted: false, sortOrder: 0),
          TodoItem(id: 'item-2', title: 'Task 2', isCompleted: false, sortOrder: 1),
        ];

        final list = TodoList(
          id: 'list-21',
          spaceId: 'space-21',
          name: 'List',
          items: items,
        );

        expect(list.progress, 0.0);
      });

      test('progress returns 1.0 when all items completed', () {
        final items = [
          TodoItem(id: 'item-1', title: 'Task 1', isCompleted: true, sortOrder: 0),
          TodoItem(id: 'item-2', title: 'Task 2', isCompleted: true, sortOrder: 1),
        ];

        final list = TodoList(
          id: 'list-22',
          spaceId: 'space-22',
          name: 'List',
          items: items,
        );

        expect(list.progress, 1.0);
      });

      test('progress calculates correctly for partial completion', () {
        final items = [
          TodoItem(id: 'item-1', title: 'Task 1', isCompleted: true, sortOrder: 0),
          TodoItem(id: 'item-2', title: 'Task 2', isCompleted: false, sortOrder: 1),
          TodoItem(id: 'item-3', title: 'Task 3', isCompleted: false, sortOrder: 2),
          TodoItem(id: 'item-4', title: 'Task 4', isCompleted: false, sortOrder: 3),
        ];

        final list = TodoList(
          id: 'list-23',
          spaceId: 'space-23',
          name: 'List',
          items: items,
        );

        expect(list.progress, 0.25);
      });

      test('progress calculates correctly for 50% completion', () {
        final items = [
          TodoItem(id: 'item-1', title: 'Task 1', isCompleted: true, sortOrder: 0),
          TodoItem(id: 'item-2', title: 'Task 2', isCompleted: true, sortOrder: 1),
          TodoItem(id: 'item-3', title: 'Task 3', isCompleted: false, sortOrder: 2),
          TodoItem(id: 'item-4', title: 'Task 4', isCompleted: false, sortOrder: 3),
        ];

        final list = TodoList(
          id: 'list-24',
          spaceId: 'space-24',
          name: 'List',
          items: items,
        );

        expect(list.progress, 0.5);
      });

      test('progress avoids division by zero', () {
        final list = TodoList(
          id: 'list-25',
          spaceId: 'space-25',
          name: 'Empty',
        );

        expect(() => list.progress, returnsNormally);
        expect(list.progress, 0.0);
      });
    });

    group('equality', () {
      test('equality is based on id only', () {
        final list1 = TodoList(
          id: 'same-id',
          spaceId: 'space-1',
          name: 'Name 1',
          description: 'Description 1',
          items: [TodoItem(id: 'item-1', title: 'Task', sortOrder: 0)],
        );

        final list2 = TodoList(
          id: 'same-id',
          spaceId: 'space-2',
          name: 'Name 2',
          description: 'Description 2',
        );

        expect(list1, equals(list2));
        expect(list1.hashCode, equals(list2.hashCode));
      });

      test('different ids are not equal', () {
        final list1 = TodoList(
          id: 'id-1',
          spaceId: 'space-1',
          name: 'Same name',
        );

        final list2 = TodoList(
          id: 'id-2',
          spaceId: 'space-1',
          name: 'Same name',
        );

        expect(list1, isNot(equals(list2)));
      });

      test('identical lists are equal', () {
        final list = TodoList(
          id: 'list-26',
          spaceId: 'space-26',
          name: 'List',
        );

        expect(list, equals(list));
      });
    });

    group('toString', () {
      test('includes key identifying fields', () {
        final items = [
          TodoItem(id: 'item-1', title: 'Task 1', isCompleted: true, sortOrder: 0),
          TodoItem(id: 'item-2', title: 'Task 2', isCompleted: false, sortOrder: 1),
        ];

        final list = TodoList(
          id: 'list-27',
          spaceId: 'space-27',
          name: 'My Todo List',
          items: items,
        );

        final string = list.toString();

        expect(string, contains('list-27'));
        expect(string, contains('My Todo List'));
        expect(string, contains('space-27'));
        expect(string, contains('2')); // totalItems
        expect(string, contains('1')); // completedItems
      });

      test('has readable format', () {
        final list = TodoList(
          id: 'list-28',
          spaceId: 'space-28',
          name: 'List',
        );

        final string = list.toString();

        expect(string, startsWith('TodoList('));
        expect(string, contains('id:'));
        expect(string, contains('name:'));
        expect(string, contains('spaceId:'));
      });
    });

    group('edge cases', () {
      test('handles empty string name', () {
        final list = TodoList(
          id: 'list-29',
          spaceId: 'space-29',
          name: '',
        );

        expect(list.name, '');
      });

      test('handles very long name', () {
        final longName = 'A' * 1000;
        final list = TodoList(
          id: 'list-30',
          spaceId: 'space-30',
          name: longName,
        );

        expect(list.name, longName);
      });

      test('handles many items', () {
        final manyItems = List.generate(
          100,
          (i) => TodoItem(id: 'item-$i', title: 'Task $i', sortOrder: i),
        );

        final list = TodoList(
          id: 'list-31',
          spaceId: 'space-31',
          name: 'Many Items',
          items: manyItems,
        );

        expect(list.totalItems, 100);
        expect(list.items.length, 100);
      });

      test('handles single item', () {
        final items = [
          TodoItem(id: 'item-1', title: 'Only task', sortOrder: 0),
        ];

        final list = TodoList(
          id: 'list-32',
          spaceId: 'space-32',
          name: 'Single Item',
          items: items,
        );

        expect(list.totalItems, 1);
      });

      test('handles items with same sortOrder', () {
        final items = [
          TodoItem(id: 'item-1', title: 'Task 1', sortOrder: 0),
          TodoItem(id: 'item-2', title: 'Task 2', sortOrder: 0),
          TodoItem(id: 'item-3', title: 'Task 3', sortOrder: 0),
        ];

        final list = TodoList(
          id: 'list-33',
          spaceId: 'space-33',
          name: 'Same Sort Order',
          items: items,
        );

        expect(list.totalItems, 3);
      });
    });
  });
}
