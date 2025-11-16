import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/error/error.dart';
import 'package:later_mobile/features/todo_lists/application/services/todo_list_service.dart';
import 'package:later_mobile/features/todo_lists/data/repositories/todo_list_repository.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_item.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_list.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([TodoListRepository])
import 'todo_list_service_test.mocks.dart';

void main() {
  group('TodoListService', () {
    late MockTodoListRepository mockRepository;
    late TodoListService service;

    setUp(() {
      mockRepository = MockTodoListRepository();
      service = TodoListService(repository: mockRepository);
    });

    group('getTodoListsForSpace', () {
      test('should fetch and sort todo lists by sortOrder', () async {
        // Arrange
        final list1 = TodoList(
          id: '1',
          name: 'List 1',
          spaceId: 'space-1',
          userId: 'user-1',
          sortOrder: 2,
        );
        final list2 = TodoList(
          id: '2',
          name: 'List 2',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        final list3 = TodoList(
          id: '3',
          name: 'List 3',
          spaceId: 'space-1',
          userId: 'user-1',
          sortOrder: 1,
        );
        when(mockRepository.getBySpace('space-1'))
            .thenAnswer((_) async => [list2, list3, list1]);

        // Act
        final result = await service.getTodoListsForSpace('space-1');

        // Assert
        expect(result.length, 3);
        expect(result[0].id, '2'); // sortOrder: 0
        expect(result[1].id, '3'); // sortOrder: 1
        expect(result[2].id, '1'); // sortOrder: 2
        verify(mockRepository.getBySpace('space-1')).called(1);
      });

      test('should return empty list when no lists exist', () async {
        // Arrange
        when(mockRepository.getBySpace('space-1'))
            .thenAnswer((_) async => []);

        // Act
        final result = await service.getTodoListsForSpace('space-1');

        // Assert
        expect(result, isEmpty);
        verify(mockRepository.getBySpace('space-1')).called(1);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Database error',
        );
        when(mockRepository.getBySpace('space-1')).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.getTodoListsForSpace('space-1'),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        when(mockRepository.getBySpace('space-1'))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.getTodoListsForSpace('space-1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('createTodoList', () {
      test('should create todo list with valid name', () async {
        // Arrange
        final testList = TodoList(
          id: '1',
          name: 'New Todo List',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        when(mockRepository.create(any)).thenAnswer((_) async => testList);

        // Act
        final result = await service.createTodoList(testList);

        // Assert
        expect(result, testList);
        verify(mockRepository.create(testList)).called(1);
      });

      test('should throw ValidationError when name is empty', () async {
        // Arrange
        final testList = TodoList(
          id: '1',
          name: '',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        // Act & Assert
        expect(
          () => service.createTodoList(testList),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify repository was never called
        verifyNever(mockRepository.create(any));
      });

      test('should throw ValidationError when name is only whitespace',
          () async {
        // Arrange
        final testList = TodoList(
          id: '1',
          name: '   ',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        // Act & Assert
        expect(
          () => service.createTodoList(testList),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify repository was never called
        verifyNever(mockRepository.create(any));
      });

      test('should create list with valid name containing whitespace',
          () async {
        // Arrange
        final testList = TodoList(
          id: '1',
          name: '  Valid Name  ',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        when(mockRepository.create(any)).thenAnswer((_) async => testList);

        // Act
        final result = await service.createTodoList(testList);

        // Assert
        expect(result, testList);
        verify(mockRepository.create(testList)).called(1);
      });

      test('should create list with default values', () async {
        // Arrange
        final testList = TodoList(
          id: '1',
          name: 'New List',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        when(mockRepository.create(any)).thenAnswer((_) async => testList);

        // Act
        final result = await service.createTodoList(testList);

        // Assert
        expect(result.totalItemCount, 0);
        expect(result.completedItemCount, 0);
        expect(result.sortOrder, 0);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        final testList = TodoList(
          id: '1',
          name: 'New List',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        const expectedError = AppError(
          code: ErrorCode.databaseUniqueConstraint,
          message: 'List already exists',
        );
        when(mockRepository.create(any)).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.createTodoList(testList),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        final testList = TodoList(
          id: '1',
          name: 'New List',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        when(mockRepository.create(any)).thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.createTodoList(testList),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('updateTodoList', () {
      test('should update todo list with valid name', () async {
        // Arrange
        final testList = TodoList(
          id: '1',
          name: 'Updated List',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        when(mockRepository.update(any)).thenAnswer((_) async => testList);

        // Act
        final result = await service.updateTodoList(testList);

        // Assert
        expect(result, testList);
        verify(mockRepository.update(testList)).called(1);
      });

      test('should throw ValidationError when name is empty', () async {
        // Arrange
        final testList = TodoList(
          id: '1',
          name: '',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        // Act & Assert
        expect(
          () => service.updateTodoList(testList),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify repository was never called
        verifyNever(mockRepository.update(any));
      });

      test('should throw ValidationError when name is only whitespace',
          () async {
        // Arrange
        final testList = TodoList(
          id: '1',
          name: '   ',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        // Act & Assert
        expect(
          () => service.updateTodoList(testList),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify repository was never called
        verifyNever(mockRepository.update(any));
      });

      test('should update list with valid name containing whitespace',
          () async {
        // Arrange
        final testList = TodoList(
          id: '1',
          name: '  Updated Name  ',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        when(mockRepository.update(any)).thenAnswer((_) async => testList);

        // Act
        final result = await service.updateTodoList(testList);

        // Assert
        expect(result, testList);
        verify(mockRepository.update(testList)).called(1);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        final testList = TodoList(
          id: '1',
          name: 'Updated List',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        const expectedError = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Update failed',
        );
        when(mockRepository.update(any)).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.updateTodoList(testList),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        final testList = TodoList(
          id: '1',
          name: 'Updated List',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        when(mockRepository.update(any)).thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.updateTodoList(testList),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteTodoList', () {
      test('should delete todo list successfully', () async {
        // Arrange
        when(mockRepository.delete('list-1')).thenAnswer((_) async => {});

        // Act
        await service.deleteTodoList('list-1');

        // Assert
        verify(mockRepository.delete('list-1')).called(1);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Delete failed',
        );
        when(mockRepository.delete('list-1')).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.deleteTodoList('list-1'),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        when(mockRepository.delete('list-1'))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.deleteTodoList('list-1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('reorderTodoLists', () {
      test('should update sortOrder for all lists', () async {
        // Arrange
        final list1 = TodoList(
          id: '1',
          name: 'List 1',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        final list2 = TodoList(
          id: '2',
          name: 'List 2',
          spaceId: 'space-1',
          userId: 'user-1',
          sortOrder: 1,
        );
        final list3 = TodoList(
          id: '3',
          name: 'List 3',
          spaceId: 'space-1',
          userId: 'user-1',
          sortOrder: 2,
        );

        when(mockRepository.getBySpace('space-1'))
            .thenAnswer((_) async => [list1, list2, list3]);
        when(mockRepository.update(any)).thenAnswer(
          (invocation) async =>
              invocation.positionalArguments[0] as TodoList,
        );

        // Act - Reorder: list3, list1, list2
        await service.reorderTodoLists('space-1', ['3', '1', '2']);

        // Assert
        verify(mockRepository.getBySpace('space-1')).called(1);
        final capturedUpdates =
            verify(mockRepository.update(captureAny)).captured;
        expect(capturedUpdates.length, 3);

        // Verify each list has correct sortOrder
        final updated1 = capturedUpdates.firstWhere((l) => l.id == '3');
        final updated2 = capturedUpdates.firstWhere((l) => l.id == '1');
        final updated3 = capturedUpdates.firstWhere((l) => l.id == '2');

        expect(updated1.sortOrder, 0); // list3 moved to position 0
        expect(updated2.sortOrder, 1); // list1 moved to position 1
        expect(updated3.sortOrder, 2); // list2 moved to position 2
      });

      test('should maintain list order after reorder', () async {
        // Arrange
        final list1 = TodoList(
          id: '1',
          name: 'List 1',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        final list2 = TodoList(
          id: '2',
          name: 'List 2',
          spaceId: 'space-1',
          userId: 'user-1',
          sortOrder: 1,
        );

        when(mockRepository.getBySpace('space-1'))
            .thenAnswer((_) async => [list1, list2]);
        when(mockRepository.update(any)).thenAnswer(
          (invocation) async =>
              invocation.positionalArguments[0] as TodoList,
        );

        // Act - Swap order: list2, list1
        await service.reorderTodoLists('space-1', ['2', '1']);

        // Assert
        final capturedUpdates =
            verify(mockRepository.update(captureAny)).captured;
        expect(capturedUpdates.length, 2);

        final updated1 = capturedUpdates.firstWhere((l) => l.id == '2');
        final updated2 = capturedUpdates.firstWhere((l) => l.id == '1');

        expect(updated1.sortOrder, 0); // list2 first
        expect(updated2.sortOrder, 1); // list1 second
      });

      test('should propagate AppError from repository on getBySpace', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Failed to fetch lists',
        );
        when(mockRepository.getBySpace('space-1')).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.reorderTodoLists('space-1', ['1', '2']),
          throwsA(expectedError),
        );
      });

      test('should propagate AppError from repository on update', () async {
        // Arrange
        final list1 = TodoList(
          id: '1',
          name: 'List 1',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        when(mockRepository.getBySpace('space-1'))
            .thenAnswer((_) async => [list1]);
        const expectedError = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Failed to update list',
        );
        when(mockRepository.update(any)).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.reorderTodoLists('space-1', ['1']),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        when(mockRepository.getBySpace('space-1'))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.reorderTodoLists('space-1', ['1', '2']),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getTodoItemsForList', () {
      test('should fetch and sort items by sortOrder', () async {
        // Arrange
        final item1 = TodoItem(
          id: '1',
          todoListId: 'list-1',
          title: 'Item 1',
          sortOrder: 2,
        );
        final item2 = TodoItem(
          id: '2',
          todoListId: 'list-1',
          title: 'Item 2',
          sortOrder: 0,
        );
        final item3 = TodoItem(
          id: '3',
          todoListId: 'list-1',
          title: 'Item 3',
          sortOrder: 1,
        );

        when(mockRepository.getTodoItemsByListId('list-1'))
            .thenAnswer((_) async => [item2, item3, item1]);

        // Act
        final result = await service.getTodoItemsForList('list-1');

        // Assert
        expect(result.length, 3);
        expect(result[0].id, '2'); // sortOrder: 0
        expect(result[1].id, '3'); // sortOrder: 1
        expect(result[2].id, '1'); // sortOrder: 2
        verify(mockRepository.getTodoItemsByListId('list-1')).called(1);
      });

      test('should return empty list when no items exist', () async {
        // Arrange
        when(mockRepository.getTodoItemsByListId('list-1'))
            .thenAnswer((_) async => []);

        // Act
        final result = await service.getTodoItemsForList('list-1');

        // Assert
        expect(result, isEmpty);
        verify(mockRepository.getTodoItemsByListId('list-1')).called(1);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Database error',
        );
        when(mockRepository.getTodoItemsByListId('list-1'))
            .thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.getTodoItemsForList('list-1'),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        when(mockRepository.getTodoItemsByListId('list-1'))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.getTodoItemsForList('list-1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('createTodoItem', () {
      test('should create todo item with valid title', () async {
        // Arrange
        final testItem = TodoItem(
          id: '1',
          todoListId: 'list-1',
          title: 'New Item',
          sortOrder: 0,
        );
        when(mockRepository.createTodoItem(any))
            .thenAnswer((_) async => testItem);

        // Act
        final result = await service.createTodoItem(testItem);

        // Assert
        expect(result, testItem);
        verify(mockRepository.createTodoItem(testItem)).called(1);
      });

      test('should throw ValidationError when title is empty', () async {
        // Arrange
        final testItem = TodoItem(
          id: '1',
          todoListId: 'list-1',
          title: '',
          sortOrder: 0,
        );

        // Act & Assert
        expect(
          () => service.createTodoItem(testItem),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify repository was never called
        verifyNever(mockRepository.createTodoItem(any));
      });

      test('should throw ValidationError when title is only whitespace',
          () async {
        // Arrange
        final testItem = TodoItem(
          id: '1',
          todoListId: 'list-1',
          title: '   ',
          sortOrder: 0,
        );

        // Act & Assert
        expect(
          () => service.createTodoItem(testItem),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify repository was never called
        verifyNever(mockRepository.createTodoItem(any));
      });

      test('should create item with valid title containing whitespace',
          () async {
        // Arrange
        final testItem = TodoItem(
          id: '1',
          todoListId: 'list-1',
          title: '  Valid Title  ',
          sortOrder: 0,
        );
        when(mockRepository.createTodoItem(any))
            .thenAnswer((_) async => testItem);

        // Act
        final result = await service.createTodoItem(testItem);

        // Assert
        expect(result, testItem);
        verify(mockRepository.createTodoItem(testItem)).called(1);
      });

      test('should create item with default values', () async {
        // Arrange
        final testItem = TodoItem(
          id: '1',
          todoListId: 'list-1',
          title: 'New Item',
          sortOrder: 0,
        );
        when(mockRepository.createTodoItem(any))
            .thenAnswer((_) async => testItem);

        // Act
        final result = await service.createTodoItem(testItem);

        // Assert
        expect(result.isCompleted, false);
        expect(result.sortOrder, 0);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        final testItem = TodoItem(
          id: '1',
          todoListId: 'list-1',
          title: 'New Item',
          sortOrder: 0,
        );
        const expectedError = AppError(
          code: ErrorCode.databaseUniqueConstraint,
          message: 'Item already exists',
        );
        when(mockRepository.createTodoItem(any)).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.createTodoItem(testItem),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        final testItem = TodoItem(
          id: '1',
          todoListId: 'list-1',
          title: 'New Item',
          sortOrder: 0,
        );
        when(mockRepository.createTodoItem(any))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.createTodoItem(testItem),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('updateTodoItem', () {
      test('should update todo item with valid title', () async {
        // Arrange
        final testItem = TodoItem(
          id: '1',
          todoListId: 'list-1',
          title: 'Updated Item',
          sortOrder: 0,
        );
        when(mockRepository.updateTodoItem(any))
            .thenAnswer((_) async => testItem);

        // Act
        final result = await service.updateTodoItem(testItem);

        // Assert
        expect(result, testItem);
        verify(mockRepository.updateTodoItem(testItem)).called(1);
      });

      test('should throw ValidationError when title is empty', () async {
        // Arrange
        final testItem = TodoItem(
          id: '1',
          todoListId: 'list-1',
          title: '',
          sortOrder: 0,
        );

        // Act & Assert
        expect(
          () => service.updateTodoItem(testItem),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify repository was never called
        verifyNever(mockRepository.updateTodoItem(any));
      });

      test('should throw ValidationError when title is only whitespace',
          () async {
        // Arrange
        final testItem = TodoItem(
          id: '1',
          todoListId: 'list-1',
          title: '   ',
          sortOrder: 0,
        );

        // Act & Assert
        expect(
          () => service.updateTodoItem(testItem),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify repository was never called
        verifyNever(mockRepository.updateTodoItem(any));
      });

      test('should update item with valid title containing whitespace',
          () async {
        // Arrange
        final testItem = TodoItem(
          id: '1',
          todoListId: 'list-1',
          title: '  Updated Title  ',
          sortOrder: 0,
        );
        when(mockRepository.updateTodoItem(any))
            .thenAnswer((_) async => testItem);

        // Act
        final result = await service.updateTodoItem(testItem);

        // Assert
        expect(result, testItem);
        verify(mockRepository.updateTodoItem(testItem)).called(1);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        final testItem = TodoItem(
          id: '1',
          todoListId: 'list-1',
          title: 'Updated Item',
          sortOrder: 0,
        );
        const expectedError = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Update failed',
        );
        when(mockRepository.updateTodoItem(any)).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.updateTodoItem(testItem),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        final testItem = TodoItem(
          id: '1',
          todoListId: 'list-1',
          title: 'Updated Item',
          sortOrder: 0,
        );
        when(mockRepository.updateTodoItem(any))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.updateTodoItem(testItem),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteTodoItem', () {
      test('should delete todo item successfully', () async {
        // Arrange
        when(mockRepository.deleteTodoItem('item-1', 'list-1'))
            .thenAnswer((_) async => {});

        // Act
        await service.deleteTodoItem('item-1', 'list-1');

        // Assert
        verify(mockRepository.deleteTodoItem('item-1', 'list-1')).called(1);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Delete failed',
        );
        when(mockRepository.deleteTodoItem('item-1', 'list-1'))
            .thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.deleteTodoItem('item-1', 'list-1'),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        when(mockRepository.deleteTodoItem('item-1', 'list-1'))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.deleteTodoItem('item-1', 'list-1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('toggleTodoItem', () {
      test('should toggle item completion status from false to true', () async {
        // Arrange
        final item = TodoItem(
          id: '1',
          todoListId: 'list-1',
          title: 'Test Item',
          sortOrder: 0,
        );
        final toggledItem = item.copyWith(isCompleted: true);

        when(mockRepository.getTodoItemsByListId('list-1'))
            .thenAnswer((_) async => [item]);
        when(mockRepository.updateTodoItem(any))
            .thenAnswer((_) async => toggledItem);

        // Act
        final result = await service.toggleTodoItem('1', 'list-1');

        // Assert
        expect(result.isCompleted, true);
        verify(mockRepository.getTodoItemsByListId('list-1')).called(1);
        final captured = verify(mockRepository.updateTodoItem(captureAny))
            .captured
            .single as TodoItem;
        expect(captured.isCompleted, true);
      });

      test('should toggle item completion status from true to false', () async {
        // Arrange
        final item = TodoItem(
          id: '1',
          todoListId: 'list-1',
          title: 'Test Item',
          isCompleted: true,
          sortOrder: 0,
        );
        final toggledItem = item.copyWith(isCompleted: false);

        when(mockRepository.getTodoItemsByListId('list-1'))
            .thenAnswer((_) async => [item]);
        when(mockRepository.updateTodoItem(any))
            .thenAnswer((_) async => toggledItem);

        // Act
        final result = await service.toggleTodoItem('1', 'list-1');

        // Assert
        expect(result.isCompleted, false);
        verify(mockRepository.getTodoItemsByListId('list-1')).called(1);
        final captured = verify(mockRepository.updateTodoItem(captureAny))
            .captured
            .single as TodoItem;
        expect(captured.isCompleted, false);
      });

      test('should return toggled item', () async {
        // Arrange
        final item = TodoItem(
          id: '1',
          todoListId: 'list-1',
          title: 'Test Item',
          sortOrder: 0,
        );
        final toggledItem = item.copyWith(isCompleted: true);

        when(mockRepository.getTodoItemsByListId('list-1'))
            .thenAnswer((_) async => [item]);
        when(mockRepository.updateTodoItem(any))
            .thenAnswer((_) async => toggledItem);

        // Act
        final result = await service.toggleTodoItem('1', 'list-1');

        // Assert
        expect(result.id, '1');
        expect(result.title, 'Test Item');
        expect(result.isCompleted, true);
      });

      test('should propagate AppError from repository on getTodoItemsByListId',
          () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Failed to fetch items',
        );
        when(mockRepository.getTodoItemsByListId('list-1'))
            .thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.toggleTodoItem('1', 'list-1'),
          throwsA(expectedError),
        );
      });

      test('should propagate AppError from repository on updateTodoItem',
          () async {
        // Arrange
        final item = TodoItem(
          id: '1',
          todoListId: 'list-1',
          title: 'Test Item',
          sortOrder: 0,
        );
        when(mockRepository.getTodoItemsByListId('list-1'))
            .thenAnswer((_) async => [item]);
        const expectedError = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Failed to update item',
        );
        when(mockRepository.updateTodoItem(any)).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.toggleTodoItem('1', 'list-1'),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        when(mockRepository.getTodoItemsByListId('list-1'))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.toggleTodoItem('1', 'list-1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('reorderTodoItems', () {
      test('should update sortOrder for all items', () async {
        // Arrange
        final item1 = TodoItem(
          id: '1',
          todoListId: 'list-1',
          title: 'Item 1',
          sortOrder: 0,
        );
        final item2 = TodoItem(
          id: '2',
          todoListId: 'list-1',
          title: 'Item 2',
          sortOrder: 1,
        );
        final item3 = TodoItem(
          id: '3',
          todoListId: 'list-1',
          title: 'Item 3',
          sortOrder: 2,
        );

        when(mockRepository.getTodoItemsByListId('list-1'))
            .thenAnswer((_) async => [item1, item2, item3]);
        when(mockRepository.updateTodoItemSortOrders(any))
            .thenAnswer((_) async => {});

        // Act - Reorder: item3, item1, item2
        await service.reorderTodoItems('list-1', ['3', '1', '2']);

        // Assert
        verify(mockRepository.getTodoItemsByListId('list-1')).called(1);
        final capturedUpdates = verify(
                mockRepository.updateTodoItemSortOrders(captureAny))
            .captured
            .single as List<TodoItem>;
        expect(capturedUpdates.length, 3);

        // Verify each item has correct sortOrder
        final updated1 = capturedUpdates.firstWhere((i) => i.id == '3');
        final updated2 = capturedUpdates.firstWhere((i) => i.id == '1');
        final updated3 = capturedUpdates.firstWhere((i) => i.id == '2');

        expect(updated1.sortOrder, 0); // item3 moved to position 0
        expect(updated2.sortOrder, 1); // item1 moved to position 1
        expect(updated3.sortOrder, 2); // item2 moved to position 2
      });

      test('should maintain item order after reorder', () async {
        // Arrange
        final item1 = TodoItem(
          id: '1',
          todoListId: 'list-1',
          title: 'Item 1',
          sortOrder: 0,
        );
        final item2 = TodoItem(
          id: '2',
          todoListId: 'list-1',
          title: 'Item 2',
          sortOrder: 1,
        );

        when(mockRepository.getTodoItemsByListId('list-1'))
            .thenAnswer((_) async => [item1, item2]);
        when(mockRepository.updateTodoItemSortOrders(any))
            .thenAnswer((_) async => {});

        // Act - Swap order: item2, item1
        await service.reorderTodoItems('list-1', ['2', '1']);

        // Assert
        final capturedUpdates = verify(
                mockRepository.updateTodoItemSortOrders(captureAny))
            .captured
            .single as List<TodoItem>;
        expect(capturedUpdates.length, 2);

        final updated1 = capturedUpdates.firstWhere((i) => i.id == '2');
        final updated2 = capturedUpdates.firstWhere((i) => i.id == '1');

        expect(updated1.sortOrder, 0); // item2 first
        expect(updated2.sortOrder, 1); // item1 second
      });

      test('should propagate AppError from repository on getTodoItemsByListId',
          () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Failed to fetch items',
        );
        when(mockRepository.getTodoItemsByListId('list-1'))
            .thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.reorderTodoItems('list-1', ['1', '2']),
          throwsA(expectedError),
        );
      });

      test(
          'should propagate AppError from repository on updateTodoItemSortOrders',
          () async {
        // Arrange
        final item1 = TodoItem(
          id: '1',
          todoListId: 'list-1',
          title: 'Item 1',
          sortOrder: 0,
        );
        when(mockRepository.getTodoItemsByListId('list-1'))
            .thenAnswer((_) async => [item1]);
        const expectedError = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Failed to update sort orders',
        );
        when(mockRepository.updateTodoItemSortOrders(any))
            .thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.reorderTodoItems('list-1', ['1']),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        when(mockRepository.getTodoItemsByListId('list-1'))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.reorderTodoItems('list-1', ['1', '2']),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
