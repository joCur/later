import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/core/error/error.dart';
import 'package:later_mobile/features/lists/application/providers.dart';
import 'package:later_mobile/features/lists/application/services/list_service.dart';
import 'package:later_mobile/features/lists/domain/models/list_item_model.dart';
import 'package:later_mobile/features/lists/presentation/controllers/list_items_controller.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([ListService])
import 'list_items_controller_test.mocks.dart';

void main() {
  group('ListItemsController', () {
    late MockListService mockService;
    const testListId = 'list-1';

    setUp(() {
      mockService = MockListService();
    });

    // Helper to create test ListItems
    ListItem createItem({
      required String id,
      required String title,
      int sortOrder = 0,
      bool isChecked = false,
      String? notes,
    }) {
      return ListItem(
        id: id,
        listId: testListId,
        title: title,
        sortOrder: sortOrder,
        isChecked: isChecked,
        notes: notes,
      );
    }

    group('build (initialization)', () {
      test('should load list items on initialization', () async {
        // Arrange
        final testItems = [
          createItem(id: '1', title: 'Item 1'),
          createItem(id: '2', title: 'Item 2', sortOrder: 1),
        ];
        when(
          mockService.getListItemsForList(any),
        ).thenAnswer((_) async => testItems);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Act
        final state = await container.read(
          listItemsControllerProvider(testListId).future,
        );

        // Assert
        expect(state, testItems);
        expect(state.length, 2);
        expect(state[0].id, '1');
        expect(state[1].id, '2');
        verify(mockService.getListItemsForList(testListId)).called(1);
      });

      test('should return AsyncValue.data with items', () async {
        // Arrange
        final testItems = [createItem(id: '1', title: 'Item 1')];
        when(
          mockService.getListItemsForList(any),
        ).thenAnswer((_) async => testItems);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Act
        await container.read(listItemsControllerProvider(testListId).future);
        final asyncState = container.read(
          listItemsControllerProvider(testListId),
        );

        // Assert
        expect(asyncState.hasValue, true);
        expect(asyncState.hasError, false);
        expect(asyncState.isLoading, false);
        expect(asyncState.value, testItems);
      });

      test('should initialize with empty list when no items exist', () async {
        // Arrange
        when(mockService.getListItemsForList(any))
            .thenAnswer((_) async => []);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Act
        final state = await container.read(
          listItemsControllerProvider(testListId).future,
        );

        // Assert
        expect(state, isEmpty);
      });
    });

    group('createItem', () {
      test('should add new item to state', () async {
        // Arrange
        final existingItems = [
          createItem(id: '1', title: 'Existing Item'),
        ];
        final newItem = createItem(id: '2', title: 'New Item', sortOrder: 1);

        when(
          mockService.getListItemsForList(any),
        ).thenAnswer((_) async => existingItems);
        when(mockService.createListItem(any)).thenAnswer((_) async => newItem);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(listItemsControllerProvider(testListId).notifier)
            .createItem(newItem);

        // Assert
        final finalState = container.read(
          listItemsControllerProvider(testListId),
        );
        expect(finalState.value?.length, 2);
        expect(finalState.value?[1], newItem);
        verify(mockService.createListItem(newItem)).called(1);
      });

      test('should sort items by sortOrder after creation', () async {
        // Arrange
        final existingItems = [
          createItem(id: '1', title: 'Item 1'),
          createItem(id: '3', title: 'Item 3', sortOrder: 2),
        ];
        final newItem = createItem(id: '2', title: 'Item 2', sortOrder: 1);

        when(
          mockService.getListItemsForList(any),
        ).thenAnswer((_) async => existingItems);
        when(mockService.createListItem(any)).thenAnswer((_) async => newItem);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(listItemsControllerProvider(testListId).notifier)
            .createItem(newItem);

        // Assert
        final finalState = container.read(
          listItemsControllerProvider(testListId),
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
          message: 'Item title is required',
        );
        final newItem = createItem(id: '1', title: '');

        when(mockService.getListItemsForList(any))
            .thenAnswer((_) async => []);
        when(mockService.createListItem(any)).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(listItemsControllerProvider(testListId).notifier)
            .createItem(newItem);

        // Assert
        final finalState = container.read(
          listItemsControllerProvider(testListId),
        );
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if ref is not mounted', () async {
        // Arrange
        final newItem = createItem(id: '1', title: 'New Item');

        when(mockService.getListItemsForList(any))
            .thenAnswer((_) async => []);
        when(mockService.createListItem(any)).thenAnswer((_) async {
          // Simulate slow operation
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return newItem;
        });

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );

        // Wait for initial build
        await container.read(listItemsControllerProvider(testListId).future);

        // Act
        final controller = container.read(
          listItemsControllerProvider(testListId).notifier,
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
        final originalItem = createItem(
          id: '1',
          title: 'Original Title',
        );
        final updatedItem = createItem(
          id: '1',
          title: 'Updated Title',
        );

        when(
          mockService.getListItemsForList(any),
        ).thenAnswer((_) async => [originalItem]);
        when(
          mockService.updateListItem(any),
        ).thenAnswer((_) async => updatedItem);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(listItemsControllerProvider(testListId).notifier)
            .updateItem(updatedItem);

        // Assert
        final finalState = container.read(
          listItemsControllerProvider(testListId),
        );
        expect(finalState.value?.length, 1);
        expect(finalState.value?.first.title, 'Updated Title');
        verify(mockService.updateListItem(updatedItem)).called(1);
      });

      test('should maintain item order', () async {
        // Arrange
        final item1 = createItem(id: '1', title: 'Item 1');
        final item2 = createItem(id: '2', title: 'Item 2', sortOrder: 1);
        final item3 = createItem(id: '3', title: 'Item 3', sortOrder: 2);
        final updatedItem2 = createItem(
          id: '2',
          title: 'Updated Item 2',
          sortOrder: 1,
        );

        when(
          mockService.getListItemsForList(any),
        ).thenAnswer((_) async => [item1, item2, item3]);
        when(
          mockService.updateListItem(any),
        ).thenAnswer((_) async => updatedItem2);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(listItemsControllerProvider(testListId).notifier)
            .updateItem(updatedItem2);

        // Assert
        final finalState = container.read(
          listItemsControllerProvider(testListId),
        );
        expect(finalState.value?.length, 3);
        expect(finalState.value?[0].id, '1');
        expect(finalState.value?[1].id, '2');
        expect(finalState.value?[1].title, 'Updated Item 2');
        expect(finalState.value?[2].id, '3');
      });

      test('should not update state if item not found', () async {
        // Arrange
        final existingItem = createItem(id: '1', title: 'Existing');
        final updatedItem = createItem(id: '999', title: 'Not Found');

        when(
          mockService.getListItemsForList(any),
        ).thenAnswer((_) async => [existingItem]);
        when(
          mockService.updateListItem(any),
        ).thenAnswer((_) async => updatedItem);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(listItemsControllerProvider(testListId).notifier)
            .updateItem(updatedItem);

        // Assert - state should remain unchanged
        final finalState = container.read(
          listItemsControllerProvider(testListId),
        );
        expect(finalState.value?.length, 1);
        expect(finalState.value?.first, existingItem);
      });

      test('should update state to error on service failure', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.validationRequired,
          message: 'Item title is required',
        );
        final item = createItem(id: '1', title: '');

        when(
          mockService.getListItemsForList(any),
        ).thenAnswer((_) async => [item]);
        when(mockService.updateListItem(any)).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(listItemsControllerProvider(testListId).notifier)
            .updateItem(item);

        // Assert
        final finalState = container.read(
          listItemsControllerProvider(testListId),
        );
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if ref is not mounted', () async {
        // Arrange
        final item = createItem(id: '1', title: 'Test Item');
        final updatedItem = createItem(id: '1', title: 'Updated Item');

        when(
          mockService.getListItemsForList(any),
        ).thenAnswer((_) async => [item]);
        when(mockService.updateListItem(any)).thenAnswer((_) async {
          // Simulate slow operation
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return updatedItem;
        });

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );

        // Wait for initial build
        await container.read(listItemsControllerProvider(testListId).future);

        // Act
        final controller = container.read(
          listItemsControllerProvider(testListId).notifier,
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
        final item1 = createItem(id: '1', title: 'Item 1');
        final item2 = createItem(id: '2', title: 'Item 2');

        when(
          mockService.getListItemsForList(any),
        ).thenAnswer((_) async => [item1, item2]);
        when(mockService.deleteListItem('1', testListId))
            .thenAnswer((_) async => {});

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(listItemsControllerProvider(testListId).notifier)
            .deleteItem('1', testListId);

        // Assert
        final finalState = container.read(
          listItemsControllerProvider(testListId),
        );
        expect(finalState.value?.length, 1);
        expect(finalState.value?.first.id, '2');
        verify(mockService.deleteListItem('1', testListId)).called(1);
      });

      test('should update state to error on service failure', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.databasePermissionDenied,
          message: 'Permission denied',
        );
        final item = createItem(id: '1', title: 'Test Item');

        when(
          mockService.getListItemsForList(any),
        ).thenAnswer((_) async => [item]);
        when(mockService.deleteListItem('1', testListId))
            .thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(listItemsControllerProvider(testListId).notifier)
            .deleteItem('1', testListId);

        // Assert
        final finalState = container.read(
          listItemsControllerProvider(testListId),
        );
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if ref is not mounted', () async {
        // Arrange
        final item = createItem(id: '1', title: 'Test Item');

        when(
          mockService.getListItemsForList(any),
        ).thenAnswer((_) async => [item]);
        when(mockService.deleteListItem(any, any)).thenAnswer((_) async {
          // Simulate slow operation
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );

        // Wait for initial build
        await container.read(listItemsControllerProvider(testListId).future);

        // Act
        final controller = container.read(
          listItemsControllerProvider(testListId).notifier,
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
      test('should toggle item from unchecked to checked', () async {
        // Arrange
        final item = createItem(id: '1', title: 'Test Item');
        final toggledItem = item.copyWith(isChecked: true);

        when(
          mockService.getListItemsForList(any),
        ).thenAnswer((_) async => [item]);
        when(mockService.toggleListItem(any))
            .thenAnswer((_) async => toggledItem);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(listItemsControllerProvider(testListId).notifier)
            .toggleItem(item);

        // Assert
        final finalState = container.read(
          listItemsControllerProvider(testListId),
        );
        expect(finalState.value?.first.isChecked, true);
        verify(mockService.toggleListItem(item)).called(1);
      });

      test('should toggle item from checked to unchecked', () async {
        // Arrange
        final item = createItem(id: '1', title: 'Test Item', isChecked: true);
        final toggledItem = item.copyWith(isChecked: false);

        when(
          mockService.getListItemsForList(any),
        ).thenAnswer((_) async => [item]);
        when(mockService.toggleListItem(any))
            .thenAnswer((_) async => toggledItem);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(listItemsControllerProvider(testListId).notifier)
            .toggleItem(item);

        // Assert
        final finalState = container.read(
          listItemsControllerProvider(testListId),
        );
        expect(finalState.value?.first.isChecked, false);
        verify(mockService.toggleListItem(item)).called(1);
      });

      test('should maintain item properties after toggle', () async {
        // Arrange
        final item = createItem(
          id: '1',
          title: 'Test Item',
          notes: 'Some notes',
        );
        final toggledItem = item.copyWith(isChecked: true);

        when(
          mockService.getListItemsForList(any),
        ).thenAnswer((_) async => [item]);
        when(mockService.toggleListItem(any))
            .thenAnswer((_) async => toggledItem);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(listItemsControllerProvider(testListId).notifier)
            .toggleItem(item);

        // Assert
        final finalState = container.read(
          listItemsControllerProvider(testListId),
        );
        expect(finalState.value?.first.title, 'Test Item');
        expect(finalState.value?.first.notes, 'Some notes');
      });

      test('should update state to error on service failure', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Toggle failed',
        );
        final item = createItem(id: '1', title: 'Test Item');

        when(
          mockService.getListItemsForList(any),
        ).thenAnswer((_) async => [item]);
        when(mockService.toggleListItem(any)).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(listItemsControllerProvider(testListId).notifier)
            .toggleItem(item);

        // Assert
        final finalState = container.read(
          listItemsControllerProvider(testListId),
        );
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if ref is not mounted', () async {
        // Arrange
        final item = createItem(id: '1', title: 'Test Item');

        when(
          mockService.getListItemsForList(any),
        ).thenAnswer((_) async => [item]);
        when(mockService.toggleListItem(any)).thenAnswer((_) async {
          // Simulate slow operation
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return item.copyWith(isChecked: true);
        });

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );

        // Wait for initial build
        await container.read(listItemsControllerProvider(testListId).future);

        // Act
        final controller = container.read(
          listItemsControllerProvider(testListId).notifier,
        );
        // Start toggle but dispose immediately
        unawaited(controller.toggleItem(item));
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
          createItem(id: '1', title: 'Item 1'),
          createItem(id: '2', title: 'Item 2', sortOrder: 1),
          createItem(id: '3', title: 'Item 3', sortOrder: 2),
        ];
        final reorderedItems = [
          createItem(id: '3', title: 'Item 3'),
          createItem(id: '1', title: 'Item 1', sortOrder: 1),
          createItem(id: '2', title: 'Item 2', sortOrder: 2),
        ];

        when(
          mockService.getListItemsForList(any),
        ).thenAnswer((_) async => originalItems);
        when(
          mockService.reorderListItems(any, any),
        ).thenAnswer((_) async => {});
        // After reorder, return the reordered items
        when(
          mockService.getListItemsForList(testListId),
        ).thenAnswer((_) async => reorderedItems);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(listItemsControllerProvider(testListId).notifier)
            .reorderItems(['3', '1', '2']);

        // Assert
        final finalState = container.read(
          listItemsControllerProvider(testListId),
        );
        expect(finalState.value?.length, 3);
        expect(finalState.value?[0].id, '3');
        expect(finalState.value?[1].id, '1');
        expect(finalState.value?[2].id, '2');
        verify(
          mockService.reorderListItems(testListId, ['3', '1', '2']),
        ).called(1);
      });

      test('should update state to error on service failure', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.databaseTimeout,
          message: 'Database timeout',
        );
        final items = [
          createItem(id: '1', title: 'Item 1'),
          createItem(id: '2', title: 'Item 2'),
        ];

        when(
          mockService.getListItemsForList(any),
        ).thenAnswer((_) async => items);
        when(mockService.reorderListItems(any, any)).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listItemsControllerProvider(testListId).future);

        // Act
        await container
            .read(listItemsControllerProvider(testListId).notifier)
            .reorderItems(['2', '1']);

        // Assert
        final finalState = container.read(
          listItemsControllerProvider(testListId),
        );
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if ref is not mounted', () async {
        // Arrange
        final items = [
          createItem(id: '1', title: 'Item 1'),
          createItem(id: '2', title: 'Item 2'),
        ];

        when(
          mockService.getListItemsForList(any),
        ).thenAnswer((_) async => items);
        when(mockService.reorderListItems(any, any)).thenAnswer((_) async {
          // Simulate slow operation
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );

        // Wait for initial build
        await container.read(listItemsControllerProvider(testListId).future);

        // Act
        final controller = container.read(
          listItemsControllerProvider(testListId).notifier,
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
