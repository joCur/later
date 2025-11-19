import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_item.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_list.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_priority.dart';

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
          todoListId: 'list-1',
          title: 'Buy groceries',
          sortOrder: 0,
        );

        expect(item.id, 'todo-1');
        expect(item.todoListId, 'list-1');
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
          todoListId: 'list-2',
          title: 'Complete project',
          description: 'Finish the quarterly report and submit to management',
          isCompleted: true,
          dueDate: dueDate,
          priority: TodoPriority.high,
          tags: ['work', 'urgent', 'q4'],
          sortOrder: 5,
        );

        expect(item.id, 'todo-2');
        expect(item.todoListId, 'list-2');
        expect(item.title, 'Complete project');
        expect(
          item.description,
          'Finish the quarterly report and submit to management',
        );
        expect(item.isCompleted, true);
        expect(item.dueDate, dueDate);
        expect(item.priority, TodoPriority.high);
        expect(item.tags, ['work', 'urgent', 'q4']);
        expect(item.sortOrder, 5);
      });

      test('defaults tags to empty list when null', () {
        final item = TodoItem(
          id: 'todo-3',
          todoListId: 'list-3',
          title: 'Test task',
          sortOrder: 0,
        );

        expect(item.tags, isEmpty);
        expect(item.tags, isA<List<String>>());
      });

      test('defaults isCompleted to false', () {
        final item = TodoItem(
          id: 'todo-4',
          todoListId: 'list-4',
          title: 'Task',
          sortOrder: 0,
        );

        expect(item.isCompleted, false);
      });
    });

    group('fromJson', () {
      test('deserializes from JSON with all fields', () {
        final json = {
          'id': 'todo-1',
          'todo_list_id': 'list-1',
          'title': 'Review pull request',
          'description': 'Check the new authentication feature',
          'is_completed': false,
          'due_date': '2025-11-15T10:30:00.000Z',
          'priority': 'medium',
          'tags': ['development', 'review'],
          'sort_order': 2,
        };

        final item = TodoItem.fromJson(json);

        expect(item.id, 'todo-1');
        expect(item.todoListId, 'list-1');
        expect(item.title, 'Review pull request');
        expect(item.description, 'Check the new authentication feature');
        expect(item.isCompleted, false);
        expect(item.dueDate, DateTime.parse('2025-11-15T10:30:00.000Z'));
        expect(item.priority, TodoPriority.medium);
        expect(item.tags, ['development', 'review']);
        expect(item.sortOrder, 2);
      });

      test('deserializes from JSON with minimal fields', () {
        final json = {
          'id': 'todo-2',
          'todo_list_id': 'list-2',
          'title': 'Simple task',
          'sort_order': 0,
        };

        final item = TodoItem.fromJson(json);

        expect(item.id, 'todo-2');
        expect(item.todoListId, 'list-2');
        expect(item.title, 'Simple task');
        expect(item.description, isNull);
        expect(item.isCompleted, false);
        expect(item.dueDate, isNull);
        expect(item.priority, isNull);
        expect(item.tags, isEmpty);
        expect(item.sortOrder, 0);
      });

      test('handles null priority gracefully', () {
        final json = {
          'id': 'todo-3',
          'todo_list_id': 'list-3',
          'title': 'Task',
          'priority': null,
          'sort_order': 0,
        };

        final item = TodoItem.fromJson(json);

        expect(item.priority, isNull);
      });

      test('handles null tags array', () {
        final json = {
          'id': 'todo-4',
          'todo_list_id': 'list-4',
          'title': 'Task',
          'tags': null,
          'sort_order': 0,
        };

        final item = TodoItem.fromJson(json);

        expect(item.tags, isEmpty);
      });

      test('handles null due_date gracefully', () {
        final json = {
          'id': 'todo-5',
          'todo_list_id': 'list-5',
          'title': 'Task',
          'due_date': null,
          'sort_order': 0,
        };

        final item = TodoItem.fromJson(json);

        expect(item.dueDate, isNull);
      });

      test('handles null is_completed with default false', () {
        final json = {
          'id': 'todo-6',
          'todo_list_id': 'list-6',
          'title': 'Task',
          'is_completed': null,
          'sort_order': 0,
        };

        final item = TodoItem.fromJson(json);

        expect(item.isCompleted, false);
      });
    });

    group('toJson', () {
      test('serializes to JSON with all fields', () {
        final dueDate = DateTime(2025, 11, 15, 10, 30);
        final item = TodoItem(
          id: 'todo-1',
          todoListId: 'list-1',
          title: 'Review pull request',
          description: 'Check the new authentication feature',
          dueDate: dueDate,
          priority: TodoPriority.medium,
          tags: ['development', 'review'],
          sortOrder: 2,
        );

        final json = item.toJson();

        expect(json['id'], 'todo-1');
        expect(json['todo_list_id'], 'list-1');
        expect(json['title'], 'Review pull request');
        expect(json['description'], 'Check the new authentication feature');
        expect(json['due_date'], dueDate.toIso8601String());
        expect(json['priority'], 'medium');
        expect(json['tags'], ['development', 'review']);
        expect(json['is_completed'], false);
        expect(json['sort_order'], 2);
      });

      test('serializes to JSON with minimal fields', () {
        final item = TodoItem(
          id: 'todo-2',
          todoListId: 'list-2',
          title: 'Simple task',
          sortOrder: 0,
        );

        final json = item.toJson();

        expect(json['id'], 'todo-2');
        expect(json['todo_list_id'], 'list-2');
        expect(json['title'], 'Simple task');
        expect(json['description'], isNull);
        expect(json['due_date'], isNull);
        expect(json['priority'], isNull);
        expect(json['tags'], isEmpty);
        expect(json['is_completed'], false);
        expect(json['sort_order'], 0);
      });
    });

    group('copyWith', () {
      test('creates copy with updated title', () {
        final original = TodoItem(
          id: 'todo-1',
          todoListId: 'list-1',
          title: 'Original',
          sortOrder: 0,
        );

        final updated = original.copyWith(title: 'Updated');

        expect(updated.id, original.id);
        expect(updated.todoListId, original.todoListId);
        expect(updated.title, 'Updated');
        expect(updated.sortOrder, original.sortOrder);
      });

      test('creates copy with updated isCompleted', () {
        final original = TodoItem(
          id: 'todo-1',
          todoListId: 'list-1',
          title: 'Task',
          sortOrder: 0,
        );

        final updated = original.copyWith(isCompleted: true);

        expect(updated.isCompleted, true);
      });

      test('creates copy with updated dueDate', () {
        final newDueDate = DateTime(2025, 12, 31);
        final original = TodoItem(
          id: 'todo-1',
          todoListId: 'list-1',
          title: 'Task',
          sortOrder: 0,
        );

        final updated = original.copyWith(dueDate: newDueDate);

        expect(updated.dueDate, newDueDate);
      });

      test('creates copy with updated priority', () {
        final original = TodoItem(
          id: 'todo-1',
          todoListId: 'list-1',
          title: 'Task',
          sortOrder: 0,
        );

        final updated = original.copyWith(priority: TodoPriority.high);

        expect(updated.priority, TodoPriority.high);
      });

      test('can clear due date', () {
        final original = TodoItem(
          id: 'todo-1',
          todoListId: 'list-1',
          title: 'Task',
          dueDate: DateTime(2025, 12, 31),
          sortOrder: 0,
        );

        final updated = original.copyWith(clearDueDate: true);

        expect(updated.dueDate, isNull);
      });

      test('can clear priority', () {
        final original = TodoItem(
          id: 'todo-1',
          todoListId: 'list-1',
          title: 'Task',
          priority: TodoPriority.high,
          sortOrder: 0,
        );

        final updated = original.copyWith(clearPriority: true);

        expect(updated.priority, isNull);
      });
    });

    group('equality', () {
      test('items with same id are equal', () {
        final item1 = TodoItem(
          id: 'todo-1',
          todoListId: 'list-1',
          title: 'Task 1',
          sortOrder: 0,
        );

        final item2 = TodoItem(
          id: 'todo-1',
          todoListId: 'list-2',
          title: 'Task 2',
          sortOrder: 1,
        );

        expect(item1, equals(item2));
        expect(item1.hashCode, equals(item2.hashCode));
      });

      test('items with different id are not equal', () {
        final item1 = TodoItem(
          id: 'todo-1',
          todoListId: 'list-1',
          title: 'Task',
          sortOrder: 0,
        );

        final item2 = TodoItem(
          id: 'todo-2',
          todoListId: 'list-1',
          title: 'Task',
          sortOrder: 0,
        );

        expect(item1, isNot(equals(item2)));
      });
    });

    group('round-trip serialization', () {
      test('survives JSON round trip with all fields', () {
        final original = TodoItem(
          id: 'todo-1',
          todoListId: 'list-1',
          title: 'Complete task',
          description: 'Description here',
          isCompleted: true,
          dueDate: DateTime(2025, 12, 31),
          priority: TodoPriority.high,
          tags: ['urgent', 'work'],
          sortOrder: 3,
        );

        final json = original.toJson();
        final deserialized = TodoItem.fromJson(json);

        expect(deserialized.id, original.id);
        expect(deserialized.todoListId, original.todoListId);
        expect(deserialized.title, original.title);
        expect(deserialized.description, original.description);
        expect(deserialized.isCompleted, original.isCompleted);
        expect(deserialized.dueDate, original.dueDate);
        expect(deserialized.priority, original.priority);
        expect(deserialized.tags, original.tags);
        expect(deserialized.sortOrder, original.sortOrder);
      });

      test('survives JSON round trip with minimal fields', () {
        final original = TodoItem(
          id: 'todo-2',
          todoListId: 'list-2',
          title: 'Simple',
          sortOrder: 0,
        );

        final json = original.toJson();
        final deserialized = TodoItem.fromJson(json);

        expect(deserialized.id, original.id);
        expect(deserialized.todoListId, original.todoListId);
        expect(deserialized.title, original.title);
        expect(deserialized.isCompleted, false);
        expect(deserialized.sortOrder, 0);
      });
    });
  });

  group('TodoList', () {
    group('construction', () {
      test('creates with all required fields', () {
        final list = TodoList(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'Work Tasks',
        );

        expect(list.id, 'list-1');
        expect(list.spaceId, 'space-1');
        expect(list.userId, 'user-1');
        expect(list.name, 'Work Tasks');
        expect(list.description, isNull);
        expect(list.totalItemCount, 0);
        expect(list.completedItemCount, 0);
        expect(list.createdAt, isA<DateTime>());
        expect(list.updatedAt, isA<DateTime>());
        expect(list.sortOrder, 0);
      });

      test('creates with all optional fields', () {
        final createdAt = DateTime(2025);
        final updatedAt = DateTime(2025, 10, 25);

        final list = TodoList(
          id: 'list-2',
          spaceId: 'space-2',
          userId: 'user-2',
          name: 'Project Alpha',
          description: 'Tasks for the new product launch',
          totalItemCount: 10,
          completedItemCount: 3,
          createdAt: createdAt,
          updatedAt: updatedAt,
          sortOrder: 5,
        );

        expect(list.id, 'list-2');
        expect(list.spaceId, 'space-2');
        expect(list.userId, 'user-2');
        expect(list.name, 'Project Alpha');
        expect(list.description, 'Tasks for the new product launch');
        expect(list.totalItemCount, 10);
        expect(list.completedItemCount, 3);
        expect(list.createdAt, createdAt);
        expect(list.updatedAt, updatedAt);
        expect(list.sortOrder, 5);
      });

      test('defaults counts to 0 when not provided', () {
        final list = TodoList(
          id: 'list-3',
          spaceId: 'space-3',
          userId: 'user-3',
          name: 'Empty List',
        );

        expect(list.totalItemCount, 0);
        expect(list.completedItemCount, 0);
      });

      test('initializes dates to now when not provided', () {
        final before = DateTime.now();
        final list = TodoList(
          id: 'list-4',
          spaceId: 'space-4',
          userId: 'user-4',
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
          'name': 'Work Projects',
          'description': 'All work-related tasks',
          'total_item_count': 15,
          'completed_item_count': 7,
          'created_at': '2025-01-01T10:00:00.000Z',
          'updated_at': '2025-01-02T15:30:00.000Z',
          'sort_order': 3,
        };

        final list = TodoList.fromJson(json);

        expect(list.id, 'list-1');
        expect(list.spaceId, 'space-1');
        expect(list.userId, 'user-1');
        expect(list.name, 'Work Projects');
        expect(list.description, 'All work-related tasks');
        expect(list.totalItemCount, 15);
        expect(list.completedItemCount, 7);
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

        final list = TodoList.fromJson(json);

        expect(list.id, 'list-2');
        expect(list.spaceId, 'space-2');
        expect(list.userId, 'user-2');
        expect(list.name, 'Simple List');
        expect(list.description, isNull);
        expect(list.totalItemCount, 0);
        expect(list.completedItemCount, 0);
        expect(list.sortOrder, 0);
      });

      test('handles null counts with default 0', () {
        final json = {
          'id': 'list-3',
          'space_id': 'space-3',
          'user_id': 'user-3',
          'name': 'List',
          'total_item_count': null,
          'completed_item_count': null,
          'created_at': '2025-01-01T10:00:00.000Z',
          'updated_at': '2025-01-01T10:00:00.000Z',
        };

        final list = TodoList.fromJson(json);

        expect(list.totalItemCount, 0);
        expect(list.completedItemCount, 0);
      });

      test('handles missing sort_order with default 0', () {
        final json = {
          'id': 'list-4',
          'space_id': 'space-4',
          'user_id': 'user-4',
          'name': 'List',
          'created_at': '2025-01-01T10:00:00.000Z',
          'updated_at': '2025-01-01T10:00:00.000Z',
        };

        final list = TodoList.fromJson(json);

        expect(list.sortOrder, 0);
      });
    });

    group('toJson', () {
      test('serializes to JSON with all fields', () {
        final createdAt = DateTime(2025, 1, 1, 10);
        final updatedAt = DateTime(2025, 1, 2, 15, 30);

        final list = TodoList(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'Work',
          description: 'Work tasks',
          totalItemCount: 20,
          completedItemCount: 8,
          createdAt: createdAt,
          updatedAt: updatedAt,
          sortOrder: 2,
        );

        final json = list.toJson();

        expect(json['id'], 'list-1');
        expect(json['space_id'], 'space-1');
        expect(json['user_id'], 'user-1');
        expect(json['name'], 'Work');
        expect(json['description'], 'Work tasks');
        // Count fields are computed aggregates and should NOT be serialized
        expect(json.containsKey('total_item_count'), false);
        expect(json.containsKey('completed_item_count'), false);
        expect(json['created_at'], createdAt.toIso8601String());
        expect(json['updated_at'], updatedAt.toIso8601String());
        expect(json['sort_order'], 2);
      });

      test('serializes to JSON with minimal fields', () {
        final list = TodoList(
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
        expect(json['description'], isNull);
        // Count fields are computed aggregates and should NOT be serialized
        expect(json.containsKey('total_item_count'), false);
        expect(json.containsKey('completed_item_count'), false);
        expect(json['sort_order'], 0);
      });
    });

    group('copyWith', () {
      test('creates copy with updated name', () {
        final original = TodoList(
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

      test('creates copy with updated counts', () {
        final original = TodoList(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'List',
        );

        final updated = original.copyWith(
          totalItemCount: 10,
          completedItemCount: 5,
        );

        expect(updated.totalItemCount, 10);
        expect(updated.completedItemCount, 5);
      });

      test('creates copy with updated description', () {
        final original = TodoList(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'List',
        );

        final updated = original.copyWith(description: 'New description');

        expect(updated.description, 'New description');
      });

      test('preserves unchanged fields', () {
        final createdAt = DateTime(2025);
        final original = TodoList(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'Original',
          description: 'Desc',
          totalItemCount: 5,
          completedItemCount: 2,
          createdAt: createdAt,
          sortOrder: 3,
        );

        final updated = original.copyWith(name: 'Updated');

        expect(updated.description, original.description);
        expect(updated.totalItemCount, original.totalItemCount);
        expect(updated.completedItemCount, original.completedItemCount);
        expect(updated.createdAt, original.createdAt);
        expect(updated.sortOrder, original.sortOrder);
      });
    });

    group('getters', () {
      test('totalItems returns totalItemCount', () {
        final list = TodoList(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'List',
          totalItemCount: 15,
        );

        expect(list.totalItems, 15);
      });

      test('completedItems returns completedItemCount', () {
        final list = TodoList(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'List',
          completedItemCount: 7,
        );

        expect(list.completedItems, 7);
      });

      test('progress calculates correctly', () {
        final list = TodoList(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'List',
          totalItemCount: 10,
          completedItemCount: 3,
        );

        expect(list.progress, 0.3);
      });

      test('progress returns 0.0 when no items', () {
        final list = TodoList(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'List',
        );

        expect(list.progress, 0.0);
      });

      test('progress returns 1.0 when all items completed', () {
        final list = TodoList(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'List',
          totalItemCount: 5,
          completedItemCount: 5,
        );

        expect(list.progress, 1.0);
      });
    });

    group('equality', () {
      test('lists with same id are equal', () {
        final list1 = TodoList(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'Name 1',
        );

        final list2 = TodoList(
          id: 'list-1',
          spaceId: 'space-2',
          userId: 'user-2',
          name: 'Name 2',
        );

        expect(list1, equals(list2));
        expect(list1.hashCode, equals(list2.hashCode));
      });

      test('lists with different id are not equal', () {
        final list1 = TodoList(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'Name',
        );

        final list2 = TodoList(
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
        final list = TodoList(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'My List',
        );

        final string = list.toString();

        expect(string, contains('TodoList'));
        expect(string, contains('list-1'));
        expect(string, contains('My List'));
        expect(string, contains('space-1'));
        expect(string, contains('user-1'));
      });
    });

    group('round-trip serialization', () {
      test('survives JSON round trip with all fields', () {
        final original = TodoList(
          id: 'list-1',
          spaceId: 'space-1',
          userId: 'user-1',
          name: 'Test List',
          description: 'Description',
          totalItemCount: 12,
          completedItemCount: 6,
          createdAt: DateTime(2025, 1, 1, 10),
          updatedAt: DateTime(2025, 1, 2, 15),
          sortOrder: 7,
        );

        final json = original.toJson();
        final deserialized = TodoList.fromJson(json);

        expect(deserialized.id, original.id);
        expect(deserialized.spaceId, original.spaceId);
        expect(deserialized.userId, original.userId);
        expect(deserialized.name, original.name);
        expect(deserialized.description, original.description);
        // Count fields are NOT serialized, so they default to 0 after deserialization
        expect(deserialized.totalItemCount, 0);
        expect(deserialized.completedItemCount, 0);
        expect(deserialized.createdAt, original.createdAt);
        expect(deserialized.updatedAt, original.updatedAt);
        expect(deserialized.sortOrder, original.sortOrder);
      });

      test('survives JSON round trip with minimal fields', () {
        final original = TodoList(
          id: 'list-2',
          spaceId: 'space-2',
          userId: 'user-2',
          name: 'Minimal',
        );

        final json = original.toJson();
        final deserialized = TodoList.fromJson(json);

        expect(deserialized.id, original.id);
        expect(deserialized.spaceId, original.spaceId);
        expect(deserialized.userId, original.userId);
        expect(deserialized.name, original.name);
        expect(deserialized.totalItemCount, 0);
        expect(deserialized.completedItemCount, 0);
      });
    });
  });
}
