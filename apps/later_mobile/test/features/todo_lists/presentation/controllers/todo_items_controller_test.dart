import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/core/error/error.dart';
import 'package:later_mobile/features/todo_lists/application/providers.dart';
import 'package:later_mobile/features/todo_lists/application/services/todo_list_service.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_item.dart';
import 'package:later_mobile/features/todo_lists/presentation/controllers/todo_items_controller.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([TodoListService])
import 'todo_items_controller_test.mocks.dart';

void main() {
  group('TodoItemsController', () {
    late MockTodoListService mockService;
    const testListId = 'list-1';

    setUp(() {
      mockService = MockTodoListService();
    });

    // Helper to create test TodoItems
    TodoItem createTodoItem({
      required String id,
      required String title,
      int sortOrder = 0,
      bool isCompleted = false,
      String? description,
    }) {
      return TodoItem(
        id: id,
        todoListId: testListId,
        title: title,
        sortOrder: sortOrder,
        isCompleted: isCompleted,
        description: description,
      );
    }

    group('build (initialization)', () {
      test('should load todo items for list on initialization', () async {
        // Arrange
        final testItems = [
          createTodoItem(id: '1', title: 'Item 1'),
          createTodoItem(id: '2', title: 'Item 2', sortOrder: 1),
        ];
        when(
          mockService.getTodoItemsForList(any),
        ).thenAnswer((_) async => testItems);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Act
        final state = await container.read(
          todoItemsControllerProvider(testListId).future,
        );

        // Assert
        expect(state, testItems);
        expect(state.length, 2);
        expect(state[0].id, '1');
        expect(state[1].id, '2');
        verify(mockService.getTodoItemsForList(testListId)).called(1);
      });

      test('should return AsyncValue.data with items', () async {
        // Arrange
        final testItems = [createTodoItem(id: '1', title: 'Item 1')];
        when(
          mockService.getTodoItemsForList(any),
        ).thenAnswer((_) async => testItems);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Act
        await container.read(todoItemsControllerProvider(testListId).future);
        final asyncState = container.read(
          todoItemsControllerProvider(testListId),
        );

        // Assert
        expect(asyncState.hasValue, true);
        expect(asyncState.hasError, false);
        expect(asyncState.isLoading, false);
        expect(asyncState.value, testItems);
      });

      test('should initialize with empty list when no items exist', () async {
        // Arrange
        when(mockService.getTodoItemsForList(any)).thenAnswer((_) async => []);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Act
        final state = await container.read(
          todoItemsControllerProvider(testListId).future,
        );

        // Assert
        expect(state, isEmpty);
      });
    });

    group('createItem', () {
      test('should add new item to state', () async {
        // Arrange
        final existingItems = [
          createTodoItem(id: '1', title: 'Existing Item'),
        ];
        final newItem = createTodoItem(id: '2', title: 'New Item', sortOrder: 1);

        when(
          mockService.getTodoItemsForList(any),
        ).thenAnswer((_) async => existingItems);
        when(mockService.createTodoItem(any)).thenAnswer((_) async => newItem);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(todoItemsControllerProvider(testListId).notifier)
            .createItem(newItem);

        // Assert
        final finalState = container.read(
          todoItemsControllerProvider(testListId),
        );
        expect(finalState.value?.length, 2);
        expect(finalState.value?[1], newItem);
        verify(mockService.createTodoItem(newItem)).called(1);
      });

      test('should sort items by sortOrder after creation', () async {
        // Arrange
        final existingItems = [
          createTodoItem(id: '1', title: 'Item 1'),
          createTodoItem(id: '3', title: 'Item 3', sortOrder: 2),
        ];
        final newItem = createTodoItem(id: '2', title: 'Item 2', sortOrder: 1);

        when(
          mockService.getTodoItemsForList(any),
        ).thenAnswer((_) async => existingItems);
        when(mockService.createTodoItem(any)).thenAnswer((_) async => newItem);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(todoItemsControllerProvider(testListId).notifier)
            .createItem(newItem);

        // Assert
        final finalState = container.read(
          todoItemsControllerProvider(testListId),
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
          message: 'TodoItem title is required',
        );
        final newItem = createTodoItem(id: '1', title: '');

        when(mockService.getTodoItemsForList(any)).thenAnswer((_) async => []);
        when(mockService.createTodoItem(any)).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(todoItemsControllerProvider(testListId).notifier)
            .createItem(newItem);

        // Assert
        final finalState = container.read(
          todoItemsControllerProvider(testListId),
        );
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if ref is not mounted', () async {
        // Arrange
        final newItem = createTodoItem(id: '1', title: 'New Item');

        when(mockService.getTodoItemsForList(any)).thenAnswer((_) async => []);
        when(mockService.createTodoItem(any)).thenAnswer((_) async {
          // Simulate slow operation
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return newItem;
        });

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );

        // Wait for initial build
        await container.read(todoItemsControllerProvider(testListId).future);

        // Act
        final controller = container.read(
          todoItemsControllerProvider(testListId).notifier,
        );
        // Start creation but dispose immediately
        unawaited(controller.createItem(newItem));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('updateItem', () {
      test('should replace existing item in state', () async {
        // Arrange
        final originalItem = createTodoItem(
          id: '1',
          title: 'Original Title',
        );
        final updatedItem = createTodoItem(
          id: '1',
          title: 'Updated Title',
        );

        when(
          mockService.getTodoItemsForList(any),
        ).thenAnswer((_) async => [originalItem]);
        when(
          mockService.updateTodoItem(any),
        ).thenAnswer((_) async => updatedItem);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(todoItemsControllerProvider(testListId).notifier)
            .updateItem(updatedItem);

        // Assert
        final finalState = container.read(
          todoItemsControllerProvider(testListId),
        );
        expect(finalState.value?.length, 1);
        expect(finalState.value?.first.title, 'Updated Title');
        verify(mockService.updateTodoItem(updatedItem)).called(1);
      });

      test('should maintain item order', () async {
        // Arrange
        final item1 = createTodoItem(id: '1', title: 'Item 1');
        final item2 = createTodoItem(id: '2', title: 'Item 2', sortOrder: 1);
        final item3 = createTodoItem(id: '3', title: 'Item 3', sortOrder: 2);
        final updatedItem2 = createTodoItem(
          id: '2',
          title: 'Updated Item 2',
          sortOrder: 1,
        );

        when(
          mockService.getTodoItemsForList(any),
        ).thenAnswer((_) async => [item1, item2, item3]);
        when(
          mockService.updateTodoItem(any),
        ).thenAnswer((_) async => updatedItem2);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(todoItemsControllerProvider(testListId).notifier)
            .updateItem(updatedItem2);

        // Assert
        final finalState = container.read(
          todoItemsControllerProvider(testListId),
        );
        expect(finalState.value?.length, 3);
        expect(finalState.value?[0].id, '1');
        expect(finalState.value?[1].id, '2');
        expect(finalState.value?[1].title, 'Updated Item 2');
        expect(finalState.value?[2].id, '3');
      });

      test('should not update state if item not found', () async {
        // Arrange
        final existingItem = createTodoItem(id: '1', title: 'Existing');
        final updatedItem = createTodoItem(id: '999', title: 'Not Found');

        when(
          mockService.getTodoItemsForList(any),
        ).thenAnswer((_) async => [existingItem]);
        when(
          mockService.updateTodoItem(any),
        ).thenAnswer((_) async => updatedItem);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(todoItemsControllerProvider(testListId).notifier)
            .updateItem(updatedItem);

        // Assert - state should remain unchanged
        final finalState = container.read(
          todoItemsControllerProvider(testListId),
        );
        expect(finalState.value?.length, 1);
        expect(finalState.value?.first, existingItem);
      });

      test('should update state to error on service failure', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.validationRequired,
          message: 'TodoItem title is required',
        );
        final todoItem = createTodoItem(id: '1', title: '');

        when(
          mockService.getTodoItemsForList(any),
        ).thenAnswer((_) async => [todoItem]);
        when(mockService.updateTodoItem(any)).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(todoItemsControllerProvider(testListId).notifier)
            .updateItem(todoItem);

        // Assert
        final finalState = container.read(
          todoItemsControllerProvider(testListId),
        );
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if ref is not mounted', () async {
        // Arrange
        final todoItem = createTodoItem(id: '1', title: 'Test Item');
        final updatedItem = createTodoItem(id: '1', title: 'Updated Item');

        when(
          mockService.getTodoItemsForList(any),
        ).thenAnswer((_) async => [todoItem]);
        when(mockService.updateTodoItem(any)).thenAnswer((_) async {
          // Simulate slow operation
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return updatedItem;
        });

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );

        // Wait for initial build
        await container.read(todoItemsControllerProvider(testListId).future);

        // Act
        final controller = container.read(
          todoItemsControllerProvider(testListId).notifier,
        );
        // Start update but dispose immediately
        unawaited(controller.updateItem(updatedItem));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('deleteItem', () {
      test('should remove item from state', () async {
        // Arrange
        final item1 = createTodoItem(id: '1', title: 'Item 1');
        final item2 = createTodoItem(id: '2', title: 'Item 2');

        when(
          mockService.getTodoItemsForList(any),
        ).thenAnswer((_) async => [item1, item2]);
        when(mockService.deleteTodoItem('1', testListId))
            .thenAnswer((_) async => {});

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(todoItemsControllerProvider(testListId).notifier)
            .deleteItem('1', testListId);

        // Assert
        final finalState = container.read(
          todoItemsControllerProvider(testListId),
        );
        expect(finalState.value?.length, 1);
        expect(finalState.value?.first.id, '2');
        verify(mockService.deleteTodoItem('1', testListId)).called(1);
      });

      test('should update state to error on service failure', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.databasePermissionDenied,
          message: 'Permission denied',
        );
        final item = createTodoItem(id: '1', title: 'Test Item');

        when(
          mockService.getTodoItemsForList(any),
        ).thenAnswer((_) async => [item]);
        when(mockService.deleteTodoItem('1', testListId))
            .thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(todoItemsControllerProvider(testListId).notifier)
            .deleteItem('1', testListId);

        // Assert
        final finalState = container.read(
          todoItemsControllerProvider(testListId),
        );
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if ref is not mounted', () async {
        // Arrange
        final item = createTodoItem(id: '1', title: 'Test Item');

        when(
          mockService.getTodoItemsForList(any),
        ).thenAnswer((_) async => [item]);
        when(mockService.deleteTodoItem(any, any)).thenAnswer((_) async {
          // Simulate slow operation
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );

        // Wait for initial build
        await container.read(todoItemsControllerProvider(testListId).future);

        // Act
        final controller = container.read(
          todoItemsControllerProvider(testListId).notifier,
        );
        // Start deletion but dispose immediately
        unawaited(controller.deleteItem('1', testListId));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('toggleItem', () {
      test('should update item completion status in state', () async {
        // Arrange
        final item = createTodoItem(
          id: '1',
          title: 'Test Item',
        );
        final toggledItem = createTodoItem(
          id: '1',
          title: 'Test Item',
          isCompleted: true,
        );

        when(
          mockService.getTodoItemsForList(any),
        ).thenAnswer((_) async => [item]);
        when(
          mockService.toggleTodoItem('1', testListId),
        ).thenAnswer((_) async => toggledItem);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(todoItemsControllerProvider(testListId).notifier)
            .toggleItem('1', testListId);

        // Assert
        final finalState = container.read(
          todoItemsControllerProvider(testListId),
        );
        expect(finalState.value?.length, 1);
        expect(finalState.value?.first.isCompleted, true);
        verify(mockService.toggleTodoItem('1', testListId)).called(1);
      });

      test('should maintain item order', () async {
        // Arrange
        final item1 = createTodoItem(
          id: '1',
          title: 'Item 1',
        );
        final item2 = createTodoItem(
          id: '2',
          title: 'Item 2',
          sortOrder: 1,
        );
        final item3 = createTodoItem(
          id: '3',
          title: 'Item 3',
          sortOrder: 2,
        );
        final toggledItem2 = createTodoItem(
          id: '2',
          title: 'Item 2',
          sortOrder: 1,
          isCompleted: true,
        );

        when(
          mockService.getTodoItemsForList(any),
        ).thenAnswer((_) async => [item1, item2, item3]);
        when(
          mockService.toggleTodoItem('2', testListId),
        ).thenAnswer((_) async => toggledItem2);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(todoItemsControllerProvider(testListId).notifier)
            .toggleItem('2', testListId);

        // Assert
        final finalState = container.read(
          todoItemsControllerProvider(testListId),
        );
        expect(finalState.value?.length, 3);
        expect(finalState.value?[0].id, '1');
        expect(finalState.value?[0].isCompleted, false);
        expect(finalState.value?[1].id, '2');
        expect(finalState.value?[1].isCompleted, true);
        expect(finalState.value?[2].id, '3');
        expect(finalState.value?[2].isCompleted, false);
      });

      test('should not update state if item not found', () async {
        // Arrange
        final item = createTodoItem(id: '1', title: 'Existing');
        final toggledItem = createTodoItem(id: '999', title: 'Not Found');

        when(
          mockService.getTodoItemsForList(any),
        ).thenAnswer((_) async => [item]);
        when(
          mockService.toggleTodoItem('999', testListId),
        ).thenAnswer((_) async => toggledItem);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(todoItemsControllerProvider(testListId).notifier)
            .toggleItem('999', testListId);

        // Assert - state should remain unchanged
        final finalState = container.read(
          todoItemsControllerProvider(testListId),
        );
        expect(finalState.value?.length, 1);
        expect(finalState.value?.first, item);
      });

      test('should update state to error on service failure', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.networkNoConnection,
          message: 'No network connection',
        );
        final item = createTodoItem(id: '1', title: 'Test Item');

        when(
          mockService.getTodoItemsForList(any),
        ).thenAnswer((_) async => [item]);
        when(mockService.toggleTodoItem('1', testListId))
            .thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(todoItemsControllerProvider(testListId).notifier)
            .toggleItem('1', testListId);

        // Assert
        final finalState = container.read(
          todoItemsControllerProvider(testListId),
        );
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if ref is not mounted', () async {
        // Arrange
        final item = createTodoItem(id: '1', title: 'Test Item');
        final toggledItem = createTodoItem(
          id: '1',
          title: 'Test Item',
          isCompleted: true,
        );

        when(
          mockService.getTodoItemsForList(any),
        ).thenAnswer((_) async => [item]);
        when(mockService.toggleTodoItem('1', testListId)).thenAnswer((_) async {
          // Simulate slow operation
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return toggledItem;
        });

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );

        // Wait for initial build
        await container.read(todoItemsControllerProvider(testListId).future);

        // Act
        final controller = container.read(
          todoItemsControllerProvider(testListId).notifier,
        );
        // Start toggle but dispose immediately
        unawaited(controller.toggleItem('1', testListId));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('reorderItems', () {
      test('should refresh state with updated sortOrder values', () async {
        // Arrange
        final originalItems = [
          createTodoItem(id: '1', title: 'Item 1'),
          createTodoItem(id: '2', title: 'Item 2', sortOrder: 1),
          createTodoItem(id: '3', title: 'Item 3', sortOrder: 2),
        ];
        final reorderedItems = [
          createTodoItem(id: '3', title: 'Item 3'),
          createTodoItem(id: '1', title: 'Item 1', sortOrder: 1),
          createTodoItem(id: '2', title: 'Item 2', sortOrder: 2),
        ];

        when(
          mockService.getTodoItemsForList(any),
        ).thenAnswer((_) async => originalItems);
        when(
          mockService.reorderTodoItems(any, any),
        ).thenAnswer((_) async => {});
        // After reorder, return the reordered items
        when(
          mockService.getTodoItemsForList(testListId),
        ).thenAnswer((_) async => reorderedItems);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(todoItemsControllerProvider(testListId).notifier)
            .reorderItems(['3', '1', '2']);

        // Assert
        final finalState = container.read(
          todoItemsControllerProvider(testListId),
        );
        expect(finalState.value?.length, 3);
        expect(finalState.value?[0].id, '3');
        expect(finalState.value?[1].id, '1');
        expect(finalState.value?[2].id, '2');
        verify(
          mockService.reorderTodoItems(testListId, ['3', '1', '2']),
        ).called(1);
      });

      test('should update state to error on service failure', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.databaseTimeout,
          message: 'Database timeout',
        );
        final items = [
          createTodoItem(id: '1', title: 'Item 1'),
          createTodoItem(id: '2', title: 'Item 2'),
        ];

        when(
          mockService.getTodoItemsForList(any),
        ).thenAnswer((_) async => items);
        when(mockService.reorderTodoItems(any, any)).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(todoItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(todoItemsControllerProvider(testListId).notifier)
            .reorderItems(['2', '1']);

        // Assert
        final finalState = container.read(
          todoItemsControllerProvider(testListId),
        );
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if ref is not mounted', () async {
        // Arrange
        final items = [
          createTodoItem(id: '1', title: 'Item 1'),
          createTodoItem(id: '2', title: 'Item 2'),
        ];

        when(
          mockService.getTodoItemsForList(any),
        ).thenAnswer((_) async => items);
        when(mockService.reorderTodoItems(any, any)).thenAnswer((_) async {
          // Simulate slow operation
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });

        final container = ProviderContainer.test(
          overrides: [todoListServiceProvider.overrideWithValue(mockService)],
        );

        // Wait for initial build
        await container.read(todoItemsControllerProvider(testListId).future);

        // Act
        final controller = container.read(
          todoItemsControllerProvider(testListId).notifier,
        );
        // Start reorder but dispose immediately
        unawaited(controller.reorderItems(['2', '1']));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });
  });
}
