import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/core/error/error.dart';
import 'package:later_mobile/data/models/list_style.dart';
import 'package:later_mobile/features/lists/application/providers.dart';
import 'package:later_mobile/features/lists/application/services/list_service.dart';
import 'package:later_mobile/features/lists/domain/models/list_model.dart';
import 'package:later_mobile/features/lists/presentation/controllers/lists_controller.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([ListService])
import 'lists_controller_test.mocks.dart';

void main() {
  group('ListsController', () {
    late MockListService mockService;
    const testSpaceId = 'space-1';
    const testUserId = 'user-1';

    setUp(() {
      mockService = MockListService();
    });

    // Helper to create test ListModels
    ListModel createList({
      required String id,
      required String name,
      int sortOrder = 0,
      int totalItemCount = 0,
      int checkedItemCount = 0,
      ListStyle style = ListStyle.bullets,
    }) {
      return ListModel(
        id: id,
        spaceId: testSpaceId,
        userId: testUserId,
        name: name,
        sortOrder: sortOrder,
        totalItemCount: totalItemCount,
        checkedItemCount: checkedItemCount,
        style: style,
      );
    }

    group('build (initialization)', () {
      test('should load lists for space on initialization', () async {
        // Arrange
        final testLists = [
          createList(id: '1', name: 'List 1'),
          createList(id: '2', name: 'List 2', sortOrder: 1),
        ];
        when(
          mockService.getListsForSpace(any),
        ).thenAnswer((_) async => testLists);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Act
        final state = await container.read(
          listsControllerProvider(testSpaceId).future,
        );

        // Assert
        expect(state, testLists);
        expect(state.length, 2);
        expect(state[0].id, '1');
        expect(state[1].id, '2');
        verify(mockService.getListsForSpace(testSpaceId)).called(1);
      });

      test('should return AsyncValue.data with lists', () async {
        // Arrange
        final testLists = [createList(id: '1', name: 'List 1')];
        when(
          mockService.getListsForSpace(any),
        ).thenAnswer((_) async => testLists);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Act
        await container.read(listsControllerProvider(testSpaceId).future);
        final asyncState = container.read(
          listsControllerProvider(testSpaceId),
        );

        // Assert
        expect(asyncState.hasValue, true);
        expect(asyncState.hasError, false);
        expect(asyncState.isLoading, false);
        expect(asyncState.value, testLists);
      });

      test('should initialize with empty list when no lists exist', () async {
        // Arrange
        when(mockService.getListsForSpace(any)).thenAnswer((_) async => []);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Act
        final state = await container.read(
          listsControllerProvider(testSpaceId).future,
        );

        // Assert
        expect(state, isEmpty);
      });
    });

    group('createList', () {
      test('should add new list to state', () async {
        // Arrange
        final existingLists = [
          createList(id: '1', name: 'Existing List'),
        ];
        final newList = createList(id: '2', name: 'New List', sortOrder: 1);

        when(
          mockService.getListsForSpace(any),
        ).thenAnswer((_) async => existingLists);
        when(mockService.createList(any)).thenAnswer((_) async => newList);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(listsControllerProvider(testSpaceId).notifier)
            .createList(newList);

        // Assert
        final finalState = container.read(
          listsControllerProvider(testSpaceId),
        );
        expect(finalState.value?.length, 2);
        expect(finalState.value?[1], newList);
        verify(mockService.createList(newList)).called(1);
      });

      test('should sort lists by sortOrder after creation', () async {
        // Arrange
        final existingLists = [
          createList(id: '1', name: 'List 1'),
          createList(id: '3', name: 'List 3', sortOrder: 2),
        ];
        final newList = createList(id: '2', name: 'List 2', sortOrder: 1);

        when(
          mockService.getListsForSpace(any),
        ).thenAnswer((_) async => existingLists);
        when(mockService.createList(any)).thenAnswer((_) async => newList);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(listsControllerProvider(testSpaceId).notifier)
            .createList(newList);

        // Assert
        final finalState = container.read(
          listsControllerProvider(testSpaceId),
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
          message: 'List name is required',
        );
        final newList = createList(id: '1', name: '');

        when(mockService.getListsForSpace(any)).thenAnswer((_) async => []);
        when(mockService.createList(any)).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(listsControllerProvider(testSpaceId).notifier)
            .createList(newList);

        // Assert
        final finalState = container.read(
          listsControllerProvider(testSpaceId),
        );
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if ref is not mounted', () async {
        // Arrange
        final newList = createList(id: '1', name: 'New List');

        when(mockService.getListsForSpace(any)).thenAnswer((_) async => []);
        when(mockService.createList(any)).thenAnswer((_) async {
          // Simulate slow operation
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return newList;
        });

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );

        // Wait for initial build
        await container.read(listsControllerProvider(testSpaceId).future);

        // Act
        final controller = container.read(
          listsControllerProvider(testSpaceId).notifier,
        );
        // Start creation but dispose immediately
        unawaited(controller.createList(newList));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('updateList', () {
      test('should replace existing list in state', () async {
        // Arrange
        final originalList = createList(
          id: '1',
          name: 'Original Name',
        );
        final updatedList = createList(
          id: '1',
          name: 'Updated Name',
        );

        when(
          mockService.getListsForSpace(any),
        ).thenAnswer((_) async => [originalList]);
        when(
          mockService.updateList(any),
        ).thenAnswer((_) async => updatedList);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(listsControllerProvider(testSpaceId).notifier)
            .updateList(updatedList);

        // Assert
        final finalState = container.read(
          listsControllerProvider(testSpaceId),
        );
        expect(finalState.value?.length, 1);
        expect(finalState.value?.first.name, 'Updated Name');
        verify(mockService.updateList(updatedList)).called(1);
      });

      test('should maintain list order', () async {
        // Arrange
        final list1 = createList(id: '1', name: 'List 1');
        final list2 = createList(id: '2', name: 'List 2', sortOrder: 1);
        final list3 = createList(id: '3', name: 'List 3', sortOrder: 2);
        final updatedList2 = createList(
          id: '2',
          name: 'Updated List 2',
          sortOrder: 1,
        );

        when(
          mockService.getListsForSpace(any),
        ).thenAnswer((_) async => [list1, list2, list3]);
        when(
          mockService.updateList(any),
        ).thenAnswer((_) async => updatedList2);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(listsControllerProvider(testSpaceId).notifier)
            .updateList(updatedList2);

        // Assert
        final finalState = container.read(
          listsControllerProvider(testSpaceId),
        );
        expect(finalState.value?.length, 3);
        expect(finalState.value?[0].id, '1');
        expect(finalState.value?[1].id, '2');
        expect(finalState.value?[1].name, 'Updated List 2');
        expect(finalState.value?[2].id, '3');
      });

      test('should not update state if list not found', () async {
        // Arrange
        final existingList = createList(id: '1', name: 'Existing');
        final updatedList = createList(id: '999', name: 'Not Found');

        when(
          mockService.getListsForSpace(any),
        ).thenAnswer((_) async => [existingList]);
        when(
          mockService.updateList(any),
        ).thenAnswer((_) async => updatedList);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(listsControllerProvider(testSpaceId).notifier)
            .updateList(updatedList);

        // Assert - state should remain unchanged
        final finalState = container.read(
          listsControllerProvider(testSpaceId),
        );
        expect(finalState.value?.length, 1);
        expect(finalState.value?.first, existingList);
      });

      test('should update state to error on service failure', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.validationRequired,
          message: 'List name is required',
        );
        final list = createList(id: '1', name: '');

        when(
          mockService.getListsForSpace(any),
        ).thenAnswer((_) async => [list]);
        when(mockService.updateList(any)).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(listsControllerProvider(testSpaceId).notifier)
            .updateList(list);

        // Assert
        final finalState = container.read(
          listsControllerProvider(testSpaceId),
        );
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if ref is not mounted', () async {
        // Arrange
        final list = createList(id: '1', name: 'Test List');
        final updatedList = createList(id: '1', name: 'Updated List');

        when(
          mockService.getListsForSpace(any),
        ).thenAnswer((_) async => [list]);
        when(mockService.updateList(any)).thenAnswer((_) async {
          // Simulate slow operation
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return updatedList;
        });

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );

        // Wait for initial build
        await container.read(listsControllerProvider(testSpaceId).future);

        // Act
        final controller = container.read(
          listsControllerProvider(testSpaceId).notifier,
        );
        // Start update but dispose immediately
        unawaited(controller.updateList(updatedList));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('deleteList', () {
      test('should remove list from state', () async {
        // Arrange
        final list1 = createList(id: '1', name: 'List 1');
        final list2 = createList(id: '2', name: 'List 2');

        when(
          mockService.getListsForSpace(any),
        ).thenAnswer((_) async => [list1, list2]);
        when(mockService.deleteList('1')).thenAnswer((_) async => {});

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(listsControllerProvider(testSpaceId).notifier)
            .deleteList('1');

        // Assert
        final finalState = container.read(
          listsControllerProvider(testSpaceId),
        );
        expect(finalState.value?.length, 1);
        expect(finalState.value?.first.id, '2');
        verify(mockService.deleteList('1')).called(1);
      });

      test('should update state to error on service failure', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.databasePermissionDenied,
          message: 'Permission denied',
        );
        final list = createList(id: '1', name: 'Test List');

        when(
          mockService.getListsForSpace(any),
        ).thenAnswer((_) async => [list]);
        when(mockService.deleteList('1')).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(listsControllerProvider(testSpaceId).notifier)
            .deleteList('1');

        // Assert
        final finalState = container.read(
          listsControllerProvider(testSpaceId),
        );
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if ref is not mounted', () async {
        // Arrange
        final list = createList(id: '1', name: 'Test List');

        when(
          mockService.getListsForSpace(any),
        ).thenAnswer((_) async => [list]);
        when(mockService.deleteList(any)).thenAnswer((_) async {
          // Simulate slow operation
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );

        // Wait for initial build
        await container.read(listsControllerProvider(testSpaceId).future);

        // Act
        final controller = container.read(
          listsControllerProvider(testSpaceId).notifier,
        );
        // Start deletion but dispose immediately
        unawaited(controller.deleteList('1'));
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
          createList(id: '1', name: 'List 1'),
          createList(id: '2', name: 'List 2', sortOrder: 1),
          createList(id: '3', name: 'List 3', sortOrder: 2),
        ];
        final reorderedLists = [
          createList(id: '3', name: 'List 3'),
          createList(id: '1', name: 'List 1', sortOrder: 1),
          createList(id: '2', name: 'List 2', sortOrder: 2),
        ];

        when(
          mockService.getListsForSpace(any),
        ).thenAnswer((_) async => originalLists);
        when(
          mockService.reorderLists(any, any),
        ).thenAnswer((_) async => {});
        // After reorder, return the reordered lists
        when(
          mockService.getListsForSpace(testSpaceId),
        ).thenAnswer((_) async => reorderedLists);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(listsControllerProvider(testSpaceId).notifier)
            .reorderLists(['3', '1', '2']);

        // Assert
        final finalState = container.read(
          listsControllerProvider(testSpaceId),
        );
        expect(finalState.value?.length, 3);
        expect(finalState.value?[0].id, '3');
        expect(finalState.value?[1].id, '1');
        expect(finalState.value?[2].id, '2');
        verify(
          mockService.reorderLists(testSpaceId, ['3', '1', '2']),
        ).called(1);
      });

      test('should update state to error on service failure', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.databaseTimeout,
          message: 'Database timeout',
        );
        final lists = [
          createList(id: '1', name: 'List 1'),
          createList(id: '2', name: 'List 2'),
        ];

        when(
          mockService.getListsForSpace(any),
        ).thenAnswer((_) async => lists);
        when(mockService.reorderLists(any, any)).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listsControllerProvider(testSpaceId).future);

        // Act
        await container
            .read(listsControllerProvider(testSpaceId).notifier)
            .reorderLists(['2', '1']);

        // Assert
        final finalState = container.read(
          listsControllerProvider(testSpaceId),
        );
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if ref is not mounted', () async {
        // Arrange
        final lists = [
          createList(id: '1', name: 'List 1'),
          createList(id: '2', name: 'List 2'),
        ];

        when(
          mockService.getListsForSpace(any),
        ).thenAnswer((_) async => lists);
        when(mockService.reorderLists(any, any)).thenAnswer((_) async {
          // Simulate slow operation
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );

        // Wait for initial build
        await container.read(listsControllerProvider(testSpaceId).future);

        // Act
        final controller = container.read(
          listsControllerProvider(testSpaceId).notifier,
        );
        // Start reorder but dispose immediately
        unawaited(controller.reorderLists(['2', '1']));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('refresh', () {
      test('should reload all lists to refresh counts', () async {
        // Arrange
        final initialLists = [
          createList(
            id: '1',
            name: 'List 1',
            totalItemCount: 5,
            checkedItemCount: 2,
          ),
        ];
        final refreshedLists = [
          createList(
            id: '1',
            name: 'List 1',
            totalItemCount: 6,
            checkedItemCount: 3,
          ),
        ];

        when(
          mockService.getListsForSpace(any),
        ).thenAnswer((_) async => initialLists);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listsControllerProvider(testSpaceId).future);

        // Setup mock for refresh
        when(
          mockService.getListsForSpace(testSpaceId),
        ).thenAnswer((_) async => refreshedLists);

        // Act
        await container
            .read(listsControllerProvider(testSpaceId).notifier)
            .refresh();

        // Assert
        final finalState = container.read(
          listsControllerProvider(testSpaceId),
        );
        expect(finalState.value?.first.totalItemCount, 6);
        expect(finalState.value?.first.checkedItemCount, 3);
        verify(mockService.getListsForSpace(testSpaceId)).called(2);
      });

      test('should update state with fresh data', () async {
        // Arrange
        final initialLists = [
          createList(id: '1', name: 'List 1'),
          createList(id: '2', name: 'List 2'),
        ];
        final refreshedLists = [
          createList(id: '1', name: 'List 1'),
          createList(id: '2', name: 'List 2 Updated'),
          createList(id: '3', name: 'List 3 New'),
        ];

        when(
          mockService.getListsForSpace(any),
        ).thenAnswer((_) async => initialLists);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listsControllerProvider(testSpaceId).future);

        // Setup mock for refresh
        when(
          mockService.getListsForSpace(testSpaceId),
        ).thenAnswer((_) async => refreshedLists);

        // Act
        await container
            .read(listsControllerProvider(testSpaceId).notifier)
            .refresh();

        // Assert
        final finalState = container.read(
          listsControllerProvider(testSpaceId),
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
        final lists = [createList(id: '1', name: 'List 1')];

        when(
          mockService.getListsForSpace(any),
        ).thenAnswer((_) async => lists);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(listsControllerProvider(testSpaceId).future);

        // Setup mock for refresh failure
        when(
          mockService.getListsForSpace(testSpaceId),
        ).thenThrow(expectedError);

        // Act
        await container
            .read(listsControllerProvider(testSpaceId).notifier)
            .refresh();

        // Assert
        final finalState = container.read(
          listsControllerProvider(testSpaceId),
        );
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if ref is not mounted', () async {
        // Arrange
        final lists = [createList(id: '1', name: 'List 1')];

        when(
          mockService.getListsForSpace(any),
        ).thenAnswer((_) async => lists);

        final container = ProviderContainer.test(
          overrides: [listServiceProvider.overrideWithValue(mockService)],
        );

        // Wait for initial build
        await container.read(listsControllerProvider(testSpaceId).future);

        // Setup mock for slow refresh
        when(mockService.getListsForSpace(testSpaceId)).thenAnswer((
          _,
        ) async {
          // Simulate slow operation
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return lists;
        });

        // Act
        final controller = container.read(
          listsControllerProvider(testSpaceId).notifier,
        );
        // Start refresh but dispose immediately
        unawaited(controller.refresh());
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });
  });
}
