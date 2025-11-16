import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/core/error/error.dart';
import 'package:later_mobile/features/todo_lists/application/providers.dart';
import 'package:later_mobile/features/todo_lists/application/services/todo_list_service.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_list.dart';
import 'package:later_mobile/features/todo_lists/presentation/controllers/todo_lists_controller.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([TodoListService])
import 'todo_lists_controller_test.mocks.dart';

void main() {
  group('TodoListsController', () {
    late MockTodoListService mockService;
    const testSpaceId = 'space-1';
    const testUserId = 'user-1';

    setUp(() {
      mockService = MockTodoListService();
    });

    // Helper to create test TodoLists
    TodoList createTodoList({
      required String id,
      required String name,
      int sortOrder = 0,
      int totalItemCount = 0,
      int completedItemCount = 0,
    }) {
      return TodoList(
        id: id,
        spaceId: testSpaceId,
        userId: testUserId,
        name: name,
        sortOrder: sortOrder,
        totalItemCount: totalItemCount,
        completedItemCount: completedItemCount,
      );
    }

    group('build (initialization)', () {
      test('should load todo lists for space on initialization', () async {
        // Arrange
        final testLists = [
          createTodoList(id: '1', name: 'Todo List 1'),
          createTodoList(id: '2', name: 'Todo List 2', sortOrder: 1),
        ];
        when(
          mockService.getTodoListsForSpace(any),
        ).thenAnswer((_) async => testLists);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Act
        final state = await container.read(
          todoListsControllerProvider(testSpaceId).future,
        );

        // Assert
        expect(state, testLists);
        expect(state.length, 2);
        expect(state[0].id, '1');
        expect(state[1].id, '2');
        verify(mockService.getTodoListsForSpace(testSpaceId)).called(1);
      });

      test('should return AsyncValue.data with lists', () async {
        // Arrange
        final testLists = [createTodoList(id: '1', name: 'Todo List 1')];
        when(
          mockService.getTodoListsForSpace(any),
        ).thenAnswer((_) async => testLists);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Act
        await container.read(todoListsControllerProvider(testSpaceId).future);
        final asyncState = container.read(
          todoListsControllerProvider(testSpaceId),
        );

        // Assert
        expect(asyncState.hasValue, true);
        expect(asyncState.hasError, false);
        expect(asyncState.isLoading, false);
        expect(asyncState.value, testLists);
      });

      test('should initialize with empty list when no lists exist', () async {
        // Arrange
        when(mockService.getTodoListsForSpace(any)).thenAnswer((_) async => []);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Act
        final state = await container.read(
          todoListsControllerProvider(testSpaceId).future,
        );

        // Assert
        expect(state, isEmpty);
      });
    });

    group('createTodoList', () {
      test('should add new todo list to state', () async {
        // Arrange
        final existingLists = [
          createTodoList(id: '1', name: 'Existing List'),
        ];
        final newList = createTodoList(id: '2', name: 'New List', sortOrder: 1);

        when(
          mockService.getTodoListsForSpace(any),
        ).thenAnswer((_) async => existingLists);
        when(mockService.createTodoList(any)).thenAnswer((_) async => newList);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoListsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(todoListsControllerProvider(testSpaceId).notifier)
            .createTodoList(newList);

        // Assert
        final finalState = container.read(
          todoListsControllerProvider(testSpaceId),
        );
        expect(finalState.value?.length, 2);
        expect(finalState.value?[1], newList);
        verify(mockService.createTodoList(newList)).called(1);
      });

      test('should sort lists by sortOrder after creation', () async {
        // Arrange
        final existingLists = [
          createTodoList(id: '1', name: 'List 1'),
          createTodoList(id: '3', name: 'List 3', sortOrder: 2),
        ];
        final newList = createTodoList(id: '2', name: 'List 2', sortOrder: 1);

        when(
          mockService.getTodoListsForSpace(any),
        ).thenAnswer((_) async => existingLists);
        when(mockService.createTodoList(any)).thenAnswer((_) async => newList);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoListsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(todoListsControllerProvider(testSpaceId).notifier)
            .createTodoList(newList);

        // Assert
        final finalState = container.read(
          todoListsControllerProvider(testSpaceId),
        );
        expect(finalState.value?.length, 3);
        expect(finalState.value?[0].id, '1'); // sortOrder: 0
        expect(finalState.value?[1].id, '2'); // sortOrder: 1
        expect(finalState.value?[2].id, '3'); // sortOrder: 2
      });

      test('should update state to error on service failure', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.validationRequired,
          message: 'TodoList name is required',
        );
        final newList = createTodoList(id: '1', name: '');

        when(mockService.getTodoListsForSpace(any)).thenAnswer((_) async => []);
        when(mockService.createTodoList(any)).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoListsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(todoListsControllerProvider(testSpaceId).notifier)
            .createTodoList(newList);

        // Assert
        final finalState = container.read(
          todoListsControllerProvider(testSpaceId),
        );
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if ref is not mounted', () async {
        // Arrange
        final newList = createTodoList(id: '1', name: 'New List');

        when(mockService.getTodoListsForSpace(any)).thenAnswer((_) async => []);
        when(mockService.createTodoList(any)).thenAnswer((_) async {
          // Simulate slow operation
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return newList;
        });

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );

        // Wait for initial build
        await container.read(todoListsControllerProvider(testSpaceId).future);

        // Act
        final controller = container.read(
          todoListsControllerProvider(testSpaceId).notifier,
        );
        // Start creation but dispose immediately
        unawaited(controller.createTodoList(newList));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('updateTodoList', () {
      test('should replace existing todo list in state', () async {
        // Arrange
        final originalList = createTodoList(
          id: '1',
          name: 'Original Name',
        );
        final updatedList = createTodoList(
          id: '1',
          name: 'Updated Name',
        );

        when(
          mockService.getTodoListsForSpace(any),
        ).thenAnswer((_) async => [originalList]);
        when(
          mockService.updateTodoList(any),
        ).thenAnswer((_) async => updatedList);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoListsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(todoListsControllerProvider(testSpaceId).notifier)
            .updateTodoList(updatedList);

        // Assert
        final finalState = container.read(
          todoListsControllerProvider(testSpaceId),
        );
        expect(finalState.value?.length, 1);
        expect(finalState.value?.first.name, 'Updated Name');
        verify(mockService.updateTodoList(updatedList)).called(1);
      });

      test('should maintain list order', () async {
        // Arrange
        final list1 = createTodoList(id: '1', name: 'List 1');
        final list2 = createTodoList(id: '2', name: 'List 2', sortOrder: 1);
        final list3 = createTodoList(id: '3', name: 'List 3', sortOrder: 2);
        final updatedList2 = createTodoList(
          id: '2',
          name: 'Updated List 2',
          sortOrder: 1,
        );

        when(
          mockService.getTodoListsForSpace(any),
        ).thenAnswer((_) async => [list1, list2, list3]);
        when(
          mockService.updateTodoList(any),
        ).thenAnswer((_) async => updatedList2);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoListsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(todoListsControllerProvider(testSpaceId).notifier)
            .updateTodoList(updatedList2);

        // Assert
        final finalState = container.read(
          todoListsControllerProvider(testSpaceId),
        );
        expect(finalState.value?.length, 3);
        expect(finalState.value?[0].id, '1');
        expect(finalState.value?[1].id, '2');
        expect(finalState.value?[1].name, 'Updated List 2');
        expect(finalState.value?[2].id, '3');
      });

      test('should not update state if list not found', () async {
        // Arrange
        final existingList = createTodoList(id: '1', name: 'Existing');
        final updatedList = createTodoList(id: '999', name: 'Not Found');

        when(
          mockService.getTodoListsForSpace(any),
        ).thenAnswer((_) async => [existingList]);
        when(
          mockService.updateTodoList(any),
        ).thenAnswer((_) async => updatedList);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoListsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(todoListsControllerProvider(testSpaceId).notifier)
            .updateTodoList(updatedList);

        // Assert - state should remain unchanged
        final finalState = container.read(
          todoListsControllerProvider(testSpaceId),
        );
        expect(finalState.value?.length, 1);
        expect(finalState.value?.first, existingList);
      });

      test('should update state to error on service failure', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.validationRequired,
          message: 'TodoList name is required',
        );
        final todoList = createTodoList(id: '1', name: '');

        when(
          mockService.getTodoListsForSpace(any),
        ).thenAnswer((_) async => [todoList]);
        when(mockService.updateTodoList(any)).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoListsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(todoListsControllerProvider(testSpaceId).notifier)
            .updateTodoList(todoList);

        // Assert
        final finalState = container.read(
          todoListsControllerProvider(testSpaceId),
        );
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if ref is not mounted', () async {
        // Arrange
        final todoList = createTodoList(id: '1', name: 'Test List');
        final updatedList = createTodoList(id: '1', name: 'Updated List');

        when(
          mockService.getTodoListsForSpace(any),
        ).thenAnswer((_) async => [todoList]);
        when(mockService.updateTodoList(any)).thenAnswer((_) async {
          // Simulate slow operation
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return updatedList;
        });

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );

        // Wait for initial build
        await container.read(todoListsControllerProvider(testSpaceId).future);

        // Act
        final controller = container.read(
          todoListsControllerProvider(testSpaceId).notifier,
        );
        // Start update but dispose immediately
        unawaited(controller.updateTodoList(updatedList));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('deleteTodoList', () {
      test('should remove todo list from state', () async {
        // Arrange
        final list1 = createTodoList(id: '1', name: 'List 1');
        final list2 = createTodoList(id: '2', name: 'List 2');

        when(
          mockService.getTodoListsForSpace(any),
        ).thenAnswer((_) async => [list1, list2]);
        when(mockService.deleteTodoList('1')).thenAnswer((_) async => {});

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoListsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(todoListsControllerProvider(testSpaceId).notifier)
            .deleteTodoList('1');

        // Assert
        final finalState = container.read(
          todoListsControllerProvider(testSpaceId),
        );
        expect(finalState.value?.length, 1);
        expect(finalState.value?.first.id, '2');
        verify(mockService.deleteTodoList('1')).called(1);
      });

      test('should update state to error on service failure', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.databasePermissionDenied,
          message: 'Permission denied',
        );
        final list = createTodoList(id: '1', name: 'Test List');

        when(
          mockService.getTodoListsForSpace(any),
        ).thenAnswer((_) async => [list]);
        when(mockService.deleteTodoList('1')).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoListsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(todoListsControllerProvider(testSpaceId).notifier)
            .deleteTodoList('1');

        // Assert
        final finalState = container.read(
          todoListsControllerProvider(testSpaceId),
        );
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if ref is not mounted', () async {
        // Arrange
        final list = createTodoList(id: '1', name: 'Test List');

        when(
          mockService.getTodoListsForSpace(any),
        ).thenAnswer((_) async => [list]);
        when(mockService.deleteTodoList(any)).thenAnswer((_) async {
          // Simulate slow operation
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );

        // Wait for initial build
        await container.read(todoListsControllerProvider(testSpaceId).future);

        // Act
        final controller = container.read(
          todoListsControllerProvider(testSpaceId).notifier,
        );
        // Start deletion but dispose immediately
        unawaited(controller.deleteTodoList('1'));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('reorderLists', () {
      test('should refresh state with updated sortOrder values', () async {
        // Arrange
        final originalLists = [
          createTodoList(id: '1', name: 'List 1'),
          createTodoList(id: '2', name: 'List 2', sortOrder: 1),
          createTodoList(id: '3', name: 'List 3', sortOrder: 2),
        ];
        final reorderedLists = [
          createTodoList(id: '3', name: 'List 3'),
          createTodoList(id: '1', name: 'List 1', sortOrder: 1),
          createTodoList(id: '2', name: 'List 2', sortOrder: 2),
        ];

        when(
          mockService.getTodoListsForSpace(any),
        ).thenAnswer((_) async => originalLists);
        when(
          mockService.reorderTodoLists(any, any),
        ).thenAnswer((_) async => {});
        // After reorder, return the reordered lists
        when(
          mockService.getTodoListsForSpace(testSpaceId),
        ).thenAnswer((_) async => reorderedLists);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoListsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(todoListsControllerProvider(testSpaceId).notifier)
            .reorderLists(['3', '1', '2']);

        // Assert
        final finalState = container.read(
          todoListsControllerProvider(testSpaceId),
        );
        expect(finalState.value?.length, 3);
        expect(finalState.value?[0].id, '3');
        expect(finalState.value?[1].id, '1');
        expect(finalState.value?[2].id, '2');
        verify(
          mockService.reorderTodoLists(testSpaceId, ['3', '1', '2']),
        ).called(1);
      });

      test('should update state to error on service failure', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.databaseTimeout,
          message: 'Database timeout',
        );
        final lists = [
          createTodoList(id: '1', name: 'List 1'),
          createTodoList(id: '2', name: 'List 2'),
        ];

        when(
          mockService.getTodoListsForSpace(any),
        ).thenAnswer((_) async => lists);
        when(mockService.reorderTodoLists(any, any)).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoListsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(todoListsControllerProvider(testSpaceId).notifier)
            .reorderLists(['2', '1']);

        // Assert
        final finalState = container.read(
          todoListsControllerProvider(testSpaceId),
        );
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if ref is not mounted', () async {
        // Arrange
        final lists = [
          createTodoList(id: '1', name: 'List 1'),
          createTodoList(id: '2', name: 'List 2'),
        ];

        when(
          mockService.getTodoListsForSpace(any),
        ).thenAnswer((_) async => lists);
        when(mockService.reorderTodoLists(any, any)).thenAnswer((_) async {
          // Simulate slow operation
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );

        // Wait for initial build
        await container.read(todoListsControllerProvider(testSpaceId).future);

        // Act
        final controller = container.read(
          todoListsControllerProvider(testSpaceId).notifier,
        );
        // Start reorder but dispose immediately
        unawaited(controller.reorderLists(['2', '1']));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('refreshTodoList', () {
      test('should reload all lists to refresh counts', () async {
        // Arrange
        final initialLists = [
          createTodoList(
            id: '1',
            name: 'List 1',
            totalItemCount: 5,
            completedItemCount: 2,
          ),
        ];
        final refreshedLists = [
          createTodoList(
            id: '1',
            name: 'List 1',
            totalItemCount: 6,
            completedItemCount: 3,
          ),
        ];

        when(
          mockService.getTodoListsForSpace(any),
        ).thenAnswer((_) async => initialLists);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoListsControllerProvider(testSpaceId).future);

        // Setup mock for refresh
        when(
          mockService.getTodoListsForSpace(testSpaceId),
        ).thenAnswer((_) async => refreshedLists);

        // Act
        await container
            .read(todoListsControllerProvider(testSpaceId).notifier)
            .refreshTodoList('1');

        // Assert
        final finalState = container.read(
          todoListsControllerProvider(testSpaceId),
        );
        expect(finalState.value?.first.totalItemCount, 6);
        expect(finalState.value?.first.completedItemCount, 3);
        verify(mockService.getTodoListsForSpace(testSpaceId)).called(2);
      });

      test('should update state with fresh data', () async {
        // Arrange
        final initialLists = [
          createTodoList(id: '1', name: 'List 1'),
          createTodoList(id: '2', name: 'List 2'),
        ];
        final refreshedLists = [
          createTodoList(id: '1', name: 'List 1'),
          createTodoList(id: '2', name: 'List 2 Updated'),
          createTodoList(id: '3', name: 'List 3 New'),
        ];

        when(
          mockService.getTodoListsForSpace(any),
        ).thenAnswer((_) async => initialLists);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoListsControllerProvider(testSpaceId).future);

        // Setup mock for refresh
        when(
          mockService.getTodoListsForSpace(testSpaceId),
        ).thenAnswer((_) async => refreshedLists);

        // Act
        await container
            .read(todoListsControllerProvider(testSpaceId).notifier)
            .refreshTodoList('2');

        // Assert
        final finalState = container.read(
          todoListsControllerProvider(testSpaceId),
        );
        expect(finalState.value?.length, 3);
        expect(finalState.value?[1].name, 'List 2 Updated');
        expect(finalState.value?[2].name, 'List 3 New');
      });

      test('should update state to error on service failure', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.networkNoConnection,
          message: 'No network connection',
        );
        final lists = [createTodoList(id: '1', name: 'List 1')];

        when(
          mockService.getTodoListsForSpace(any),
        ).thenAnswer((_) async => lists);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoListsControllerProvider(testSpaceId).future);

        // Setup mock for refresh failure
        when(
          mockService.getTodoListsForSpace(testSpaceId),
        ).thenThrow(expectedError);

        // Act
        await container
            .read(todoListsControllerProvider(testSpaceId).notifier)
            .refreshTodoList('1');

        // Assert
        final finalState = container.read(
          todoListsControllerProvider(testSpaceId),
        );
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if ref is not mounted', () async {
        // Arrange
        final lists = [createTodoList(id: '1', name: 'List 1')];

        when(
          mockService.getTodoListsForSpace(any),
        ).thenAnswer((_) async => lists);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );

        // Wait for initial build
        await container.read(todoListsControllerProvider(testSpaceId).future);

        // Setup mock for slow refresh
        when(mockService.getTodoListsForSpace(testSpaceId)).thenAnswer((
          _,
        ) async {
          // Simulate slow operation
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return lists;
        });

        // Act
        final controller = container.read(
          todoListsControllerProvider(testSpaceId).notifier,
        );
        // Start refresh but dispose immediately
        unawaited(controller.refreshTodoList('1'));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });
  });
}
