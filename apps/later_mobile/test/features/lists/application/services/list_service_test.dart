import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/error/error.dart';
import 'package:later_mobile/data/models/list_style.dart';
import 'package:later_mobile/features/lists/application/services/list_service.dart';
import 'package:later_mobile/features/lists/data/repositories/list_repository.dart';
import 'package:later_mobile/features/lists/domain/models/list_item_model.dart';
import 'package:later_mobile/features/lists/domain/models/list_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([ListRepository])
import 'list_service_test.mocks.dart';

void main() {
  group('ListService', () {
    late MockListRepository mockRepository;
    late ListService service;

    setUp(() {
      mockRepository = MockListRepository();
      service = ListService(repository: mockRepository);
    });

    group('getListsForSpace', () {
      test('should fetch lists sorted by sortOrder', () async {
        // Arrange
        final list1 = ListModel(
          id: '1',
          name: 'List 1',
          spaceId: 'space-1',
          userId: 'user-1',
          sortOrder: 2,
        );
        final list2 = ListModel(
          id: '2',
          name: 'List 2',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        final list3 = ListModel(
          id: '3',
          name: 'List 3',
          spaceId: 'space-1',
          userId: 'user-1',
          sortOrder: 1,
        );
        when(mockRepository.getBySpace('space-1'))
            .thenAnswer((_) async => [list2, list3, list1]);

        // Act
        final result = await service.getListsForSpace('space-1');

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
        final result = await service.getListsForSpace('space-1');

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
          () => service.getListsForSpace('space-1'),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        when(mockRepository.getBySpace('space-1'))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.getListsForSpace('space-1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('createList', () {
      test('should create list with valid name', () async {
        // Arrange
        final testList = ListModel(
          id: '1',
          name: 'New List',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        when(mockRepository.create(any)).thenAnswer((_) async => testList);

        // Act
        final result = await service.createList(testList);

        // Assert
        expect(result, testList);
        verify(mockRepository.create(testList)).called(1);
      });

      test('should throw ValidationError when name is empty', () async {
        // Arrange
        final testList = ListModel(
          id: '1',
          name: '',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        // Act & Assert
        expect(
          () => service.createList(testList),
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
        final testList = ListModel(
          id: '1',
          name: '   ',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        // Act & Assert
        expect(
          () => service.createList(testList),
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
        final testList = ListModel(
          id: '1',
          name: '  Valid Name  ',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        when(mockRepository.create(any)).thenAnswer((_) async => testList);

        // Act
        final result = await service.createList(testList);

        // Assert
        expect(result, testList);
        verify(mockRepository.create(testList)).called(1);
      });

      test('should create list with default values', () async {
        // Arrange
        final testList = ListModel(
          id: '1',
          name: 'New List',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        when(mockRepository.create(any)).thenAnswer((_) async => testList);

        // Act
        final result = await service.createList(testList);

        // Assert
        expect(result.totalItemCount, 0);
        expect(result.checkedItemCount, 0);
        expect(result.sortOrder, 0);
        expect(result.style, ListStyle.bullets);
      });

      test('should create list with custom style', () async {
        // Arrange
        final testList = ListModel(
          id: '1',
          name: 'Checklist',
          spaceId: 'space-1',
          userId: 'user-1',
          style: ListStyle.checkboxes,
        );
        when(mockRepository.create(any)).thenAnswer((_) async => testList);

        // Act
        final result = await service.createList(testList);

        // Assert
        expect(result.style, ListStyle.checkboxes);
        verify(mockRepository.create(testList)).called(1);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        final testList = ListModel(
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
          () => service.createList(testList),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        final testList = ListModel(
          id: '1',
          name: 'New List',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        when(mockRepository.create(any)).thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.createList(testList),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('updateList', () {
      test('should update list with valid name', () async {
        // Arrange
        final testList = ListModel(
          id: '1',
          name: 'Updated List',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        when(mockRepository.update(any)).thenAnswer((_) async => testList);

        // Act
        final result = await service.updateList(testList);

        // Assert
        expect(result, testList);
        verify(mockRepository.update(testList)).called(1);
      });

      test('should throw ValidationError when name is empty', () async {
        // Arrange
        final testList = ListModel(
          id: '1',
          name: '',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        // Act & Assert
        expect(
          () => service.updateList(testList),
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
        final testList = ListModel(
          id: '1',
          name: '   ',
          spaceId: 'space-1',
          userId: 'user-1',
        );

        // Act & Assert
        expect(
          () => service.updateList(testList),
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
        final testList = ListModel(
          id: '1',
          name: '  Updated Name  ',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        when(mockRepository.update(any)).thenAnswer((_) async => testList);

        // Act
        final result = await service.updateList(testList);

        // Assert
        expect(result, testList);
        verify(mockRepository.update(testList)).called(1);
      });

      test('should update list style', () async {
        // Arrange
        final testList = ListModel(
          id: '1',
          name: 'Updated List',
          spaceId: 'space-1',
          userId: 'user-1',
          style: ListStyle.numbered,
        );
        when(mockRepository.update(any)).thenAnswer((_) async => testList);

        // Act
        final result = await service.updateList(testList);

        // Assert
        expect(result.style, ListStyle.numbered);
        verify(mockRepository.update(testList)).called(1);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        final testList = ListModel(
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
          () => service.updateList(testList),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        final testList = ListModel(
          id: '1',
          name: 'Updated List',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        when(mockRepository.update(any)).thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.updateList(testList),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteList', () {
      test('should delete list successfully', () async {
        // Arrange
        when(mockRepository.delete('list-1')).thenAnswer((_) async => {});

        // Act
        await service.deleteList('list-1');

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
          () => service.deleteList('list-1'),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        when(mockRepository.delete('list-1'))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.deleteList('list-1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('reorderLists', () {
      test('should update sortOrder for all lists', () async {
        // Arrange
        final list1 = ListModel(
          id: '1',
          name: 'List 1',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        final list2 = ListModel(
          id: '2',
          name: 'List 2',
          spaceId: 'space-1',
          userId: 'user-1',
          sortOrder: 1,
        );
        final list3 = ListModel(
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
              invocation.positionalArguments[0] as ListModel,
        );

        // Act - Reorder: list3, list1, list2
        await service.reorderLists('space-1', ['3', '1', '2']);

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
        final list1 = ListModel(
          id: '1',
          name: 'List 1',
          spaceId: 'space-1',
          userId: 'user-1',
        );
        final list2 = ListModel(
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
              invocation.positionalArguments[0] as ListModel,
        );

        // Act - Swap order: list2, list1
        await service.reorderLists('space-1', ['2', '1']);

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
          () => service.reorderLists('space-1', ['1', '2']),
          throwsA(expectedError),
        );
      });

      test('should propagate AppError from repository on update', () async {
        // Arrange
        final list1 = ListModel(
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
          () => service.reorderLists('space-1', ['1']),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        when(mockRepository.getBySpace('space-1'))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.reorderLists('space-1', ['1', '2']),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getListItemsForList', () {
      test('should fetch and sort items by sortOrder', () async {
        // Arrange
        final item1 = ListItem(
          id: '1',
          listId: 'list-1',
          title: 'Item 1',
          sortOrder: 2,
        );
        final item2 = ListItem(
          id: '2',
          listId: 'list-1',
          title: 'Item 2',
          sortOrder: 0,
        );
        final item3 = ListItem(
          id: '3',
          listId: 'list-1',
          title: 'Item 3',
          sortOrder: 1,
        );

        when(mockRepository.getListItemsByListId('list-1'))
            .thenAnswer((_) async => [item2, item3, item1]);

        // Act
        final result = await service.getListItemsForList('list-1');

        // Assert
        expect(result.length, 3);
        expect(result[0].id, '2'); // sortOrder: 0
        expect(result[1].id, '3'); // sortOrder: 1
        expect(result[2].id, '1'); // sortOrder: 2
        verify(mockRepository.getListItemsByListId('list-1')).called(1);
      });

      test('should return empty list when no items exist', () async {
        // Arrange
        when(mockRepository.getListItemsByListId('list-1'))
            .thenAnswer((_) async => []);

        // Act
        final result = await service.getListItemsForList('list-1');

        // Assert
        expect(result, isEmpty);
        verify(mockRepository.getListItemsByListId('list-1')).called(1);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Database error',
        );
        when(mockRepository.getListItemsByListId('list-1'))
            .thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.getListItemsForList('list-1'),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        when(mockRepository.getListItemsByListId('list-1'))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.getListItemsForList('list-1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('createListItem', () {
      test('should create list item with valid title', () async {
        // Arrange
        final testItem = ListItem(
          id: '1',
          listId: 'list-1',
          title: 'New Item',
          sortOrder: 0,
        );
        when(mockRepository.createListItem(any))
            .thenAnswer((_) async => testItem);

        // Act
        final result = await service.createListItem(testItem);

        // Assert
        expect(result, testItem);
        verify(mockRepository.createListItem(testItem)).called(1);
      });

      test('should throw ValidationError when title is empty', () async {
        // Arrange
        final testItem = ListItem(
          id: '1',
          listId: 'list-1',
          title: '',
          sortOrder: 0,
        );

        // Act & Assert
        expect(
          () => service.createListItem(testItem),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify repository was never called
        verifyNever(mockRepository.createListItem(any));
      });

      test('should throw ValidationError when title is only whitespace',
          () async {
        // Arrange
        final testItem = ListItem(
          id: '1',
          listId: 'list-1',
          title: '   ',
          sortOrder: 0,
        );

        // Act & Assert
        expect(
          () => service.createListItem(testItem),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify repository was never called
        verifyNever(mockRepository.createListItem(any));
      });

      test('should create item with valid title containing whitespace',
          () async {
        // Arrange
        final testItem = ListItem(
          id: '1',
          listId: 'list-1',
          title: '  Valid Title  ',
          sortOrder: 0,
        );
        when(mockRepository.createListItem(any))
            .thenAnswer((_) async => testItem);

        // Act
        final result = await service.createListItem(testItem);

        // Assert
        expect(result, testItem);
        verify(mockRepository.createListItem(testItem)).called(1);
      });

      test('should create item with default checked status', () async {
        // Arrange
        final testItem = ListItem(
          id: '1',
          listId: 'list-1',
          title: 'New Item',
          sortOrder: 0,
        );
        when(mockRepository.createListItem(any))
            .thenAnswer((_) async => testItem);

        // Act
        final result = await service.createListItem(testItem);

        // Assert
        expect(result.isChecked, false);
        expect(result.sortOrder, 0);
      });

      test('should create checked item', () async {
        // Arrange
        final testItem = ListItem(
          id: '1',
          listId: 'list-1',
          title: 'New Item',
          isChecked: true,
          sortOrder: 0,
        );
        when(mockRepository.createListItem(any))
            .thenAnswer((_) async => testItem);

        // Act
        final result = await service.createListItem(testItem);

        // Assert
        expect(result.isChecked, true);
        verify(mockRepository.createListItem(testItem)).called(1);
      });

      test('should create item with notes', () async {
        // Arrange
        final testItem = ListItem(
          id: '1',
          listId: 'list-1',
          title: 'New Item',
          notes: 'Some notes here',
          sortOrder: 0,
        );
        when(mockRepository.createListItem(any))
            .thenAnswer((_) async => testItem);

        // Act
        final result = await service.createListItem(testItem);

        // Assert
        expect(result.notes, 'Some notes here');
        verify(mockRepository.createListItem(testItem)).called(1);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        final testItem = ListItem(
          id: '1',
          listId: 'list-1',
          title: 'New Item',
          sortOrder: 0,
        );
        const expectedError = AppError(
          code: ErrorCode.databaseUniqueConstraint,
          message: 'Item already exists',
        );
        when(mockRepository.createListItem(any)).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.createListItem(testItem),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        final testItem = ListItem(
          id: '1',
          listId: 'list-1',
          title: 'New Item',
          sortOrder: 0,
        );
        when(mockRepository.createListItem(any))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.createListItem(testItem),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('updateListItem', () {
      test('should update list item with valid title', () async {
        // Arrange
        final testItem = ListItem(
          id: '1',
          listId: 'list-1',
          title: 'Updated Item',
          sortOrder: 0,
        );
        when(mockRepository.updateListItem(any))
            .thenAnswer((_) async => testItem);

        // Act
        final result = await service.updateListItem(testItem);

        // Assert
        expect(result, testItem);
        verify(mockRepository.updateListItem(testItem)).called(1);
      });

      test('should throw ValidationError when title is empty', () async {
        // Arrange
        final testItem = ListItem(
          id: '1',
          listId: 'list-1',
          title: '',
          sortOrder: 0,
        );

        // Act & Assert
        expect(
          () => service.updateListItem(testItem),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify repository was never called
        verifyNever(mockRepository.updateListItem(any));
      });

      test('should throw ValidationError when title is only whitespace',
          () async {
        // Arrange
        final testItem = ListItem(
          id: '1',
          listId: 'list-1',
          title: '   ',
          sortOrder: 0,
        );

        // Act & Assert
        expect(
          () => service.updateListItem(testItem),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify repository was never called
        verifyNever(mockRepository.updateListItem(any));
      });

      test('should update item with valid title containing whitespace',
          () async {
        // Arrange
        final testItem = ListItem(
          id: '1',
          listId: 'list-1',
          title: '  Updated Title  ',
          sortOrder: 0,
        );
        when(mockRepository.updateListItem(any))
            .thenAnswer((_) async => testItem);

        // Act
        final result = await service.updateListItem(testItem);

        // Assert
        expect(result, testItem);
        verify(mockRepository.updateListItem(testItem)).called(1);
      });

      test('should update checked status', () async {
        // Arrange
        final testItem = ListItem(
          id: '1',
          listId: 'list-1',
          title: 'Updated Item',
          isChecked: true,
          sortOrder: 0,
        );
        when(mockRepository.updateListItem(any))
            .thenAnswer((_) async => testItem);

        // Act
        final result = await service.updateListItem(testItem);

        // Assert
        expect(result.isChecked, true);
        verify(mockRepository.updateListItem(testItem)).called(1);
      });

      test('should update notes', () async {
        // Arrange
        final testItem = ListItem(
          id: '1',
          listId: 'list-1',
          title: 'Updated Item',
          notes: 'Updated notes',
          sortOrder: 0,
        );
        when(mockRepository.updateListItem(any))
            .thenAnswer((_) async => testItem);

        // Act
        final result = await service.updateListItem(testItem);

        // Assert
        expect(result.notes, 'Updated notes');
        verify(mockRepository.updateListItem(testItem)).called(1);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        final testItem = ListItem(
          id: '1',
          listId: 'list-1',
          title: 'Updated Item',
          sortOrder: 0,
        );
        const expectedError = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Update failed',
        );
        when(mockRepository.updateListItem(any)).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.updateListItem(testItem),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        final testItem = ListItem(
          id: '1',
          listId: 'list-1',
          title: 'Updated Item',
          sortOrder: 0,
        );
        when(mockRepository.updateListItem(any))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.updateListItem(testItem),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteListItem', () {
      test('should delete list item successfully', () async {
        // Arrange
        when(mockRepository.deleteListItem('item-1', 'list-1'))
            .thenAnswer((_) async => {});

        // Act
        await service.deleteListItem('item-1', 'list-1');

        // Assert
        verify(mockRepository.deleteListItem('item-1', 'list-1')).called(1);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Delete failed',
        );
        when(mockRepository.deleteListItem('item-1', 'list-1'))
            .thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.deleteListItem('item-1', 'list-1'),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        when(mockRepository.deleteListItem('item-1', 'list-1'))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.deleteListItem('item-1', 'list-1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('toggleListItem', () {
      test('should toggle item checked status from false to true', () async {
        // Arrange
        final item = ListItem(
          id: '1',
          listId: 'list-1',
          title: 'Test Item',
          sortOrder: 0,
        );
        final toggledItem = item.copyWith(isChecked: true);

        when(mockRepository.updateListItem(any))
            .thenAnswer((_) async => toggledItem);

        // Act
        final result = await service.toggleListItem(item);

        // Assert
        expect(result.isChecked, true);
        final captured = verify(mockRepository.updateListItem(captureAny))
            .captured
            .single as ListItem;
        expect(captured.isChecked, true);
      });

      test('should toggle item checked status from true to false', () async {
        // Arrange
        final item = ListItem(
          id: '1',
          listId: 'list-1',
          title: 'Test Item',
          isChecked: true,
          sortOrder: 0,
        );
        final toggledItem = item.copyWith(isChecked: false);

        when(mockRepository.updateListItem(any))
            .thenAnswer((_) async => toggledItem);

        // Act
        final result = await service.toggleListItem(item);

        // Assert
        expect(result.isChecked, false);
        final captured = verify(mockRepository.updateListItem(captureAny))
            .captured
            .single as ListItem;
        expect(captured.isChecked, false);
      });

      test('should return toggled item', () async {
        // Arrange
        final item = ListItem(
          id: '1',
          listId: 'list-1',
          title: 'Test Item',
          sortOrder: 0,
        );
        final toggledItem = item.copyWith(isChecked: true);

        when(mockRepository.updateListItem(any))
            .thenAnswer((_) async => toggledItem);

        // Act
        final result = await service.toggleListItem(item);

        // Assert
        expect(result.id, '1');
        expect(result.title, 'Test Item');
        expect(result.isChecked, true);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        final item = ListItem(
          id: '1',
          listId: 'list-1',
          title: 'Test Item',
          sortOrder: 0,
        );
        const expectedError = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Failed to update item',
        );
        when(mockRepository.updateListItem(any)).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.toggleListItem(item),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        final item = ListItem(
          id: '1',
          listId: 'list-1',
          title: 'Test Item',
          sortOrder: 0,
        );
        when(mockRepository.updateListItem(any))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.toggleListItem(item),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('reorderListItems', () {
      test('should update sortOrder for all items', () async {
        // Arrange
        final item1 = ListItem(
          id: '1',
          listId: 'list-1',
          title: 'Item 1',
          sortOrder: 0,
        );
        final item2 = ListItem(
          id: '2',
          listId: 'list-1',
          title: 'Item 2',
          sortOrder: 1,
        );
        final item3 = ListItem(
          id: '3',
          listId: 'list-1',
          title: 'Item 3',
          sortOrder: 2,
        );

        when(mockRepository.getListItemsByListId('list-1'))
            .thenAnswer((_) async => [item1, item2, item3]);
        when(mockRepository.updateListItem(any))
            .thenAnswer((invocation) async =>
                invocation.positionalArguments[0] as ListItem);

        // Act - Reorder: item3, item1, item2
        await service.reorderListItems('list-1', ['3', '1', '2']);

        // Assert
        verify(mockRepository.getListItemsByListId('list-1')).called(1);
        final capturedUpdates =
            verify(mockRepository.updateListItem(captureAny)).captured;
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
        final item1 = ListItem(
          id: '1',
          listId: 'list-1',
          title: 'Item 1',
          sortOrder: 0,
        );
        final item2 = ListItem(
          id: '2',
          listId: 'list-1',
          title: 'Item 2',
          sortOrder: 1,
        );

        when(mockRepository.getListItemsByListId('list-1'))
            .thenAnswer((_) async => [item1, item2]);
        when(mockRepository.updateListItem(any))
            .thenAnswer((invocation) async =>
                invocation.positionalArguments[0] as ListItem);

        // Act - Swap order: item2, item1
        await service.reorderListItems('list-1', ['2', '1']);

        // Assert
        final capturedUpdates =
            verify(mockRepository.updateListItem(captureAny)).captured;
        expect(capturedUpdates.length, 2);

        final updated1 = capturedUpdates.firstWhere((i) => i.id == '2');
        final updated2 = capturedUpdates.firstWhere((i) => i.id == '1');

        expect(updated1.sortOrder, 0); // item2 first
        expect(updated2.sortOrder, 1); // item1 second
      });

      test('should propagate AppError from repository on getListItemsByListId',
          () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Failed to fetch items',
        );
        when(mockRepository.getListItemsByListId('list-1'))
            .thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.reorderListItems('list-1', ['1', '2']),
          throwsA(expectedError),
        );
      });

      test('should propagate AppError from repository on updateListItem',
          () async {
        // Arrange
        final item1 = ListItem(
          id: '1',
          listId: 'list-1',
          title: 'Item 1',
          sortOrder: 0,
        );
        when(mockRepository.getListItemsByListId('list-1'))
            .thenAnswer((_) async => [item1]);
        const expectedError = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Failed to update item',
        );
        when(mockRepository.updateListItem(any)).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.reorderListItems('list-1', ['1']),
          throwsA(expectedError),
        );
      });

      test('should handle repository errors', () async {
        // Arrange
        when(mockRepository.getListItemsByListId('list-1'))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.reorderListItems('list-1', ['1', '2']),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
