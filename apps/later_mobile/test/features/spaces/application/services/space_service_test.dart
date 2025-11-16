import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/error/error.dart';
import 'package:later_mobile/features/spaces/application/services/space_service.dart';
import 'package:later_mobile/features/spaces/data/repositories/space_repository.dart';
import 'package:later_mobile/features/spaces/domain/models/space.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([SpaceRepository])
import 'space_service_test.mocks.dart';

void main() {
  group('SpaceService', () {
    late MockSpaceRepository mockRepository;
    late SpaceService service;

    setUp(() {
      mockRepository = MockSpaceRepository();
      service = SpaceService(repository: mockRepository);
    });

    group('loadSpaces', () {
      test('should load spaces from repository', () async {
        // Arrange
        final testSpaces = [
          Space(id: '1', name: 'Test Space 1', userId: 'user-1'),
          Space(id: '2', name: 'Test Space 2', userId: 'user-1'),
        ];
        when(mockRepository.getSpaces())
            .thenAnswer((_) async => testSpaces);

        // Act
        final result = await service.loadSpaces();

        // Assert
        expect(result, testSpaces);
        verify(mockRepository.getSpaces()).called(1);
      });

      test('should load spaces with includeArchived true', () async {
        // Arrange
        final testSpaces = [
          Space(id: '1', name: 'Test Space', userId: 'user-1'),
          Space(
            id: '2',
            name: 'Archived Space',
            userId: 'user-1',
            isArchived: true,
          ),
        ];
        when(mockRepository.getSpaces(includeArchived: true))
            .thenAnswer((_) async => testSpaces);

        // Act
        final result = await service.loadSpaces(includeArchived: true);

        // Assert
        expect(result, testSpaces);
        expect(result.length, 2);
        verify(mockRepository.getSpaces(includeArchived: true)).called(1);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Database error',
        );
        when(mockRepository.getSpaces())
            .thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.loadSpaces(),
          throwsA(expectedError),
        );
      });

      test('should wrap unknown errors in AppError', () async {
        // Arrange
        when(mockRepository.getSpaces())
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.loadSpaces(),
          throwsA(
            isA<AppError>().having(
              (e) => e.code,
              'code',
              ErrorCode.unknownError,
            ),
          ),
        );
      });
    });

    group('createSpace', () {
      test('should create space with valid name', () async {
        // Arrange
        final testSpace = Space(id: '1', name: 'New Space', userId: 'user-1');
        when(mockRepository.createSpace(any))
            .thenAnswer((_) async => testSpace);

        // Act
        final result = await service.createSpace(testSpace);

        // Assert
        expect(result, testSpace);
        verify(mockRepository.createSpace(testSpace)).called(1);
      });

      test('should throw ValidationError when name is empty', () async {
        // Arrange
        final testSpace = Space(id: '1', name: '', userId: 'user-1');

        // Act & Assert
        expect(
          () => service.createSpace(testSpace),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify repository was never called
        verifyNever(mockRepository.createSpace(any));
      });

      test('should throw ValidationError when name is only whitespace',
          () async {
        // Arrange
        final testSpace = Space(id: '1', name: '   ', userId: 'user-1');

        // Act & Assert
        expect(
          () => service.createSpace(testSpace),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify repository was never called
        verifyNever(mockRepository.createSpace(any));
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        final testSpace = Space(id: '1', name: 'New Space', userId: 'user-1');
        const expectedError = AppError(
          code: ErrorCode.databaseUniqueConstraint,
          message: 'Space name already exists',
        );
        when(mockRepository.createSpace(any)).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.createSpace(testSpace),
          throwsA(expectedError),
        );
      });

      test('should wrap unknown errors in AppError', () async {
        // Arrange
        final testSpace = Space(id: '1', name: 'New Space', userId: 'user-1');
        when(mockRepository.createSpace(any))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.createSpace(testSpace),
          throwsA(
            isA<AppError>().having(
              (e) => e.code,
              'code',
              ErrorCode.unknownError,
            ),
          ),
        );
      });
    });

    group('updateSpace', () {
      test('should update space with valid name', () async {
        // Arrange
        final testSpace =
            Space(id: '1', name: 'Updated Space', userId: 'user-1');
        when(mockRepository.updateSpace(any))
            .thenAnswer((_) async => testSpace);

        // Act
        final result = await service.updateSpace(testSpace);

        // Assert
        expect(result, testSpace);
        verify(mockRepository.updateSpace(testSpace)).called(1);
      });

      test('should throw ValidationError when name is empty', () async {
        // Arrange
        final testSpace = Space(id: '1', name: '', userId: 'user-1');

        // Act & Assert
        expect(
          () => service.updateSpace(testSpace),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify repository was never called
        verifyNever(mockRepository.updateSpace(any));
      });

      test('should throw ValidationError when name is only whitespace',
          () async {
        // Arrange
        final testSpace = Space(id: '1', name: '   ', userId: 'user-1');

        // Act & Assert
        expect(
          () => service.updateSpace(testSpace),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify repository was never called
        verifyNever(mockRepository.updateSpace(any));
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        final testSpace =
            Space(id: '1', name: 'Updated Space', userId: 'user-1');
        const expectedError = AppError(
          code: ErrorCode.spaceNotFound,
          message: 'Space not found',
        );
        when(mockRepository.updateSpace(any)).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.updateSpace(testSpace),
          throwsA(expectedError),
        );
      });

      test('should wrap unknown errors in AppError', () async {
        // Arrange
        final testSpace =
            Space(id: '1', name: 'Updated Space', userId: 'user-1');
        when(mockRepository.updateSpace(any))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.updateSpace(testSpace),
          throwsA(
            isA<AppError>().having(
              (e) => e.code,
              'code',
              ErrorCode.unknownError,
            ),
          ),
        );
      });
    });

    group('deleteSpace', () {
      test('should delete space when not current space', () async {
        // Arrange
        when(mockRepository.deleteSpace('space-1')).thenAnswer((_) async => {});

        // Act
        await service.deleteSpace('space-1', 'space-2');

        // Assert
        verify(mockRepository.deleteSpace('space-1')).called(1);
      });

      test('should delete space when currentSpaceId is null', () async {
        // Arrange
        when(mockRepository.deleteSpace('space-1')).thenAnswer((_) async => {});

        // Act
        await service.deleteSpace('space-1', null);

        // Assert
        verify(mockRepository.deleteSpace('space-1')).called(1);
      });

      test(
          'should throw AppError with validationRequired when deleting current space',
          () async {
        // Act & Assert
        expect(
          () => service.deleteSpace('space-1', 'space-1'),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify repository was never called
        verifyNever(mockRepository.deleteSpace(any));
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.spaceNotFound,
          message: 'Space not found',
        );
        when(mockRepository.deleteSpace('space-1')).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.deleteSpace('space-1', 'space-2'),
          throwsA(expectedError),
        );
      });

      test('should wrap unknown errors in AppError', () async {
        // Arrange
        when(mockRepository.deleteSpace('space-1'))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.deleteSpace('space-1', 'space-2'),
          throwsA(
            isA<AppError>().having(
              (e) => e.code,
              'code',
              ErrorCode.unknownError,
            ),
          ),
        );
      });
    });

    group('archiveSpace', () {
      test('should archive space by setting isArchived to true', () async {
        // Arrange
        final testSpace = Space(id: '1', name: 'Test Space', userId: 'user-1');
        final archivedSpace = testSpace.copyWith(isArchived: true);
        when(mockRepository.updateSpace(any))
            .thenAnswer((_) async => archivedSpace);

        // Act
        final result = await service.archiveSpace(testSpace);

        // Assert
        expect(result.isArchived, true);
        verify(mockRepository.updateSpace(archivedSpace)).called(1);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        final testSpace = Space(id: '1', name: 'Test Space', userId: 'user-1');
        const expectedError = AppError(
          code: ErrorCode.spaceNotFound,
          message: 'Space not found',
        );
        when(mockRepository.updateSpace(any)).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.archiveSpace(testSpace),
          throwsA(expectedError),
        );
      });

      test('should wrap unknown errors in AppError', () async {
        // Arrange
        final testSpace = Space(id: '1', name: 'Test Space', userId: 'user-1');
        when(mockRepository.updateSpace(any))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.archiveSpace(testSpace),
          throwsA(
            isA<AppError>().having(
              (e) => e.code,
              'code',
              ErrorCode.unknownError,
            ),
          ),
        );
      });
    });

    group('unarchiveSpace', () {
      test('should unarchive space by setting isArchived to false', () async {
        // Arrange
        final testSpace = Space(
          id: '1',
          name: 'Test Space',
          userId: 'user-1',
          isArchived: true,
        );
        final unarchivedSpace = testSpace.copyWith(isArchived: false);
        when(mockRepository.updateSpace(any))
            .thenAnswer((_) async => unarchivedSpace);

        // Act
        final result = await service.unarchiveSpace(testSpace);

        // Assert
        expect(result.isArchived, false);
        verify(mockRepository.updateSpace(unarchivedSpace)).called(1);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        final testSpace = Space(
          id: '1',
          name: 'Test Space',
          userId: 'user-1',
          isArchived: true,
        );
        const expectedError = AppError(
          code: ErrorCode.spaceNotFound,
          message: 'Space not found',
        );
        when(mockRepository.updateSpace(any)).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.unarchiveSpace(testSpace),
          throwsA(expectedError),
        );
      });

      test('should wrap unknown errors in AppError', () async {
        // Arrange
        final testSpace = Space(
          id: '1',
          name: 'Test Space',
          userId: 'user-1',
          isArchived: true,
        );
        when(mockRepository.updateSpace(any))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.unarchiveSpace(testSpace),
          throwsA(
            isA<AppError>().having(
              (e) => e.code,
              'code',
              ErrorCode.unknownError,
            ),
          ),
        );
      });
    });

    group('getSpaceItemCount', () {
      test('should return count from repository', () async {
        // Arrange
        when(mockRepository.getItemCount('space-1'))
            .thenAnswer((_) async => 5);

        // Act
        final result = await service.getSpaceItemCount('space-1');

        // Assert
        expect(result, 5);
        verify(mockRepository.getItemCount('space-1')).called(1);
      });

      test('should return 0 when repository returns 0', () async {
        // Arrange
        when(mockRepository.getItemCount('space-1'))
            .thenAnswer((_) async => 0);

        // Act
        final result = await service.getSpaceItemCount('space-1');

        // Assert
        expect(result, 0);
      });

      test('should propagate AppError from repository', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.spaceNotFound,
          message: 'Space not found',
        );
        when(mockRepository.getItemCount('space-1')).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.getSpaceItemCount('space-1'),
          throwsA(expectedError),
        );
      });

      test('should wrap unknown errors in AppError', () async {
        // Arrange
        when(mockRepository.getItemCount('space-1'))
            .thenThrow(Exception('Unknown error'));

        // Act & Assert
        expect(
          () => service.getSpaceItemCount('space-1'),
          throwsA(
            isA<AppError>().having(
              (e) => e.code,
              'code',
              ErrorCode.unknownError,
            ),
          ),
        );
      });
    });
  });
}
