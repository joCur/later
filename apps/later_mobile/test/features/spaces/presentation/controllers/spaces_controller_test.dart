import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/core/error/error.dart';
import 'package:later_mobile/features/spaces/application/providers.dart';
import 'package:later_mobile/features/spaces/application/services/space_service.dart';
import 'package:later_mobile/features/spaces/domain/models/space.dart';
import 'package:later_mobile/features/spaces/presentation/controllers/spaces_controller.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([SpaceService])
import 'spaces_controller_test.mocks.dart';

void main() {
  group('SpacesController', () {
    late MockSpaceService mockService;

    setUp(() {
      mockService = MockSpaceService();
    });

    group('build (initialization)', () {
      test('should load spaces on initialization', () async {
        // Arrange
        final testSpaces = [
          Space(id: '1', name: 'Test Space 1', userId: 'user-1'),
          Space(id: '2', name: 'Test Space 2', userId: 'user-1'),
        ];
        when(mockService.loadSpaces()).thenAnswer((_) async => testSpaces);

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Act
        final state = await container.read(spacesControllerProvider.future);

        // Assert
        expect(state, testSpaces);
        verify(mockService.loadSpaces()).called(1);
      });

      test('should initialize with empty list when no spaces exist', () async {
        // Arrange
        when(mockService.loadSpaces()).thenAnswer((_) async => []);

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Act
        final state = await container.read(spacesControllerProvider.future);

        // Assert
        expect(state, isEmpty);
      });
    });

    group('loadSpaces', () {
      test('should set loading state then load spaces', () async {
        // Arrange
        final testSpaces = [
          Space(id: '1', name: 'Test Space', userId: 'user-1'),
        ];
        when(mockService.loadSpaces()).thenAnswer((_) async => testSpaces);

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(spacesControllerProvider.future);

        // Act
        final controller = container.read(spacesControllerProvider.notifier);
        final future = controller.loadSpaces();

        // Verify loading state
        expect(
          container.read(spacesControllerProvider).isLoading,
          true,
        );

        // Wait for completion
        await future;

        // Assert
        final finalState = container.read(spacesControllerProvider);
        expect(finalState.hasValue, true);
        expect(finalState.value, testSpaces);
        expect(finalState.hasError, false);
      });

      test('should load spaces with includeArchived true', () async {
        // Arrange
        final testSpaces = [
          Space(id: '1', name: 'Active Space', userId: 'user-1'),
          Space(
            id: '2',
            name: 'Archived Space',
            userId: 'user-1',
            isArchived: true,
          ),
        ];
        // Mock both default and includeArchived calls
        when(mockService.loadSpaces()).thenAnswer((_) async => [testSpaces.first]);
        when(mockService.loadSpaces(includeArchived: true))
            .thenAnswer((_) async => testSpaces);

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(spacesControllerProvider.future);

        // Act
        final controller = container.read(spacesControllerProvider.notifier);
        await controller.loadSpaces(includeArchived: true);

        // Assert
        final finalState = container.read(spacesControllerProvider);
        expect(finalState.value, testSpaces);
        verify(mockService.loadSpaces(includeArchived: true)).called(1);
      });

      test('should set error state when load fails', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.networkTimeout,
          message: 'Network timeout',
        );
        // First call succeeds (for initialization), second call fails
        var callCount = 0;
        when(mockService.loadSpaces()).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            return [];
          } else {
            throw expectedError;
          }
        });

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(spacesControllerProvider.future);

        // Act
        final controller = container.read(spacesControllerProvider.notifier);
        await controller.loadSpaces();

        // Assert
        final finalState = container.read(spacesControllerProvider);
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });
    });

    group('createSpace', () {
      test('should create space and add to state', () async {
        // Arrange
        final existingSpaces = [
          Space(id: '1', name: 'Existing Space', userId: 'user-1'),
        ];
        final newSpace = Space(id: '2', name: 'New Space', userId: 'user-1');

        when(mockService.loadSpaces()).thenAnswer((_) async => existingSpaces);
        when(mockService.createSpace(any)).thenAnswer((_) async => newSpace);

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(spacesControllerProvider.future);

        // Act
        final controller = container.read(spacesControllerProvider.notifier);
        await controller.createSpace(newSpace);

        // Assert
        final finalState = container.read(spacesControllerProvider);
        expect(finalState.value?.length, 2);
        expect(finalState.value?.last, newSpace);
        verify(mockService.createSpace(newSpace)).called(1);
      });

      test('should set error state when create fails', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.validationRequired,
          message: 'Name is required',
        );
        final newSpace = Space(id: '1', name: '', userId: 'user-1');

        when(mockService.loadSpaces()).thenAnswer((_) async => []);
        when(mockService.createSpace(any)).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(spacesControllerProvider.future);

        // Act
        final controller = container.read(spacesControllerProvider.notifier);
        await controller.createSpace(newSpace);

        // Assert
        final finalState = container.read(spacesControllerProvider);
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if unmounted', () async {
        // Arrange
        final newSpace = Space(id: '1', name: 'New Space', userId: 'user-1');

        when(mockService.loadSpaces()).thenAnswer((_) async => []);
        when(mockService.createSpace(any)).thenAnswer(
          (_) async {
            // Simulate slow operation
            await Future<void>.delayed(const Duration(milliseconds: 100));
            return newSpace;
          },
        );

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );

        // Wait for initial build
        await container.read(spacesControllerProvider.future);

        // Act
        final controller = container.read(spacesControllerProvider.notifier);
        // Start creation but dispose immediately
        unawaited(controller.createSpace(newSpace));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('updateSpace', () {
      test('should update space in state', () async {
        // Arrange
        final originalSpace =
            Space(id: '1', name: 'Original Name', userId: 'user-1');
        final updatedSpace =
            Space(id: '1', name: 'Updated Name', userId: 'user-1');

        when(mockService.loadSpaces()).thenAnswer((_) async => [originalSpace]);
        when(mockService.updateSpace(any))
            .thenAnswer((_) async => updatedSpace);

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(spacesControllerProvider.future);

        // Act
        final controller = container.read(spacesControllerProvider.notifier);
        await controller.updateSpace(updatedSpace);

        // Assert
        final finalState = container.read(spacesControllerProvider);
        expect(finalState.value?.first.name, 'Updated Name');
        verify(mockService.updateSpace(updatedSpace)).called(1);
      });

      test('should not update state if space not found', () async {
        // Arrange
        final existingSpace = Space(id: '1', name: 'Existing', userId: 'user-1');
        final updatedSpace =
            Space(id: '999', name: 'Not Found', userId: 'user-1');

        when(mockService.loadSpaces()).thenAnswer((_) async => [existingSpace]);
        when(mockService.updateSpace(any))
            .thenAnswer((_) async => updatedSpace);

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(spacesControllerProvider.future);

        // Act
        final controller = container.read(spacesControllerProvider.notifier);
        await controller.updateSpace(updatedSpace);

        // Assert - state should remain unchanged
        final finalState = container.read(spacesControllerProvider);
        expect(finalState.value?.length, 1);
        expect(finalState.value?.first, existingSpace);
      });

      test('should set error state when update fails', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.spaceNotFound,
          message: 'Space not found',
        );
        final space = Space(id: '1', name: 'Test Space', userId: 'user-1');

        when(mockService.loadSpaces()).thenAnswer((_) async => [space]);
        when(mockService.updateSpace(any)).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(spacesControllerProvider.future);

        // Act
        final controller = container.read(spacesControllerProvider.notifier);
        await controller.updateSpace(space);

        // Assert
        final finalState = container.read(spacesControllerProvider);
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if unmounted', () async {
        // Arrange
        final space = Space(id: '1', name: 'Test Space', userId: 'user-1');
        final updatedSpace =
            Space(id: '1', name: 'Updated Space', userId: 'user-1');

        when(mockService.loadSpaces()).thenAnswer((_) async => [space]);
        when(mockService.updateSpace(any)).thenAnswer(
          (_) async {
            // Simulate slow operation
            await Future<void>.delayed(const Duration(milliseconds: 100));
            return updatedSpace;
          },
        );

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );

        // Wait for initial build
        await container.read(spacesControllerProvider.future);

        // Act
        final controller = container.read(spacesControllerProvider.notifier);
        // Start update but dispose immediately
        unawaited(controller.updateSpace(updatedSpace));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('deleteSpace', () {
      test('should delete space and remove from state', () async {
        // Arrange
        final space1 = Space(id: '1', name: 'Space 1', userId: 'user-1');
        final space2 = Space(id: '2', name: 'Space 2', userId: 'user-1');

        when(mockService.loadSpaces()).thenAnswer((_) async => [space1, space2]);
        when(mockService.deleteSpace('1', '2')).thenAnswer((_) async => {});

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(spacesControllerProvider.future);

        // Act
        final controller = container.read(spacesControllerProvider.notifier);
        await controller.deleteSpace('1', '2');

        // Assert
        final finalState = container.read(spacesControllerProvider);
        expect(finalState.value?.length, 1);
        expect(finalState.value?.first.id, '2');
        verify(mockService.deleteSpace('1', '2')).called(1);
      });

      test('should set error state when deleting current space', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.validationRequired,
          message: 'Cannot delete current space',
        );
        final space = Space(id: '1', name: 'Current Space', userId: 'user-1');

        when(mockService.loadSpaces()).thenAnswer((_) async => [space]);
        when(mockService.deleteSpace('1', '1')).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(spacesControllerProvider.future);

        // Act
        final controller = container.read(spacesControllerProvider.notifier);
        await controller.deleteSpace('1', '1');

        // Assert
        final finalState = container.read(spacesControllerProvider);
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if unmounted', () async {
        // Arrange
        final space = Space(id: '1', name: 'Test Space', userId: 'user-1');

        when(mockService.loadSpaces()).thenAnswer((_) async => [space]);
        when(mockService.deleteSpace(any, any)).thenAnswer(
          (_) async {
            // Simulate slow operation
            await Future<void>.delayed(const Duration(milliseconds: 100));
          },
        );

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );

        // Wait for initial build
        await container.read(spacesControllerProvider.future);

        // Act
        final controller = container.read(spacesControllerProvider.notifier);
        // Start deletion but dispose immediately
        unawaited(controller.deleteSpace('1', null));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('archiveSpace', () {
      test('should archive space and update in state', () async {
        // Arrange
        final space = Space(id: '1', name: 'Test Space', userId: 'user-1');
        final archivedSpace = space.copyWith(isArchived: true);

        when(mockService.loadSpaces()).thenAnswer((_) async => [space]);
        when(mockService.archiveSpace(any))
            .thenAnswer((_) async => archivedSpace);

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(spacesControllerProvider.future);

        // Act
        final controller = container.read(spacesControllerProvider.notifier);
        await controller.archiveSpace(space);

        // Assert
        final finalState = container.read(spacesControllerProvider);
        expect(finalState.value?.first.isArchived, true);
        verify(mockService.archiveSpace(space)).called(1);
      });

      test('should set error state when archive fails', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.spaceNotFound,
          message: 'Space not found',
        );
        final space = Space(id: '1', name: 'Test Space', userId: 'user-1');

        when(mockService.loadSpaces()).thenAnswer((_) async => [space]);
        when(mockService.archiveSpace(any)).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(spacesControllerProvider.future);

        // Act
        final controller = container.read(spacesControllerProvider.notifier);
        await controller.archiveSpace(space);

        // Assert
        final finalState = container.read(spacesControllerProvider);
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if unmounted', () async {
        // Arrange
        final space = Space(id: '1', name: 'Test Space', userId: 'user-1');
        final archivedSpace = space.copyWith(isArchived: true);

        when(mockService.loadSpaces()).thenAnswer((_) async => [space]);
        when(mockService.archiveSpace(any)).thenAnswer(
          (_) async {
            // Simulate slow operation
            await Future<void>.delayed(const Duration(milliseconds: 100));
            return archivedSpace;
          },
        );

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );

        // Wait for initial build
        await container.read(spacesControllerProvider.future);

        // Act
        final controller = container.read(spacesControllerProvider.notifier);
        // Start archive but dispose immediately
        unawaited(controller.archiveSpace(space));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('unarchiveSpace', () {
      test('should unarchive space and update in state', () async {
        // Arrange
        final space = Space(
          id: '1',
          name: 'Test Space',
          userId: 'user-1',
          isArchived: true,
        );
        final unarchivedSpace = space.copyWith(isArchived: false);

        when(mockService.loadSpaces()).thenAnswer((_) async => [space]);
        when(mockService.unarchiveSpace(any))
            .thenAnswer((_) async => unarchivedSpace);

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(spacesControllerProvider.future);

        // Act
        final controller = container.read(spacesControllerProvider.notifier);
        await controller.unarchiveSpace(space);

        // Assert
        final finalState = container.read(spacesControllerProvider);
        expect(finalState.value?.first.isArchived, false);
        verify(mockService.unarchiveSpace(space)).called(1);
      });

      test('should set error state when unarchive fails', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.spaceNotFound,
          message: 'Space not found',
        );
        final space = Space(
          id: '1',
          name: 'Test Space',
          userId: 'user-1',
          isArchived: true,
        );

        when(mockService.loadSpaces()).thenAnswer((_) async => [space]);
        when(mockService.unarchiveSpace(any)).thenThrow(expectedError);

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(spacesControllerProvider.future);

        // Act
        final controller = container.read(spacesControllerProvider.notifier);
        await controller.unarchiveSpace(space);

        // Assert
        final finalState = container.read(spacesControllerProvider);
        expect(finalState.hasError, true);
        expect(finalState.error, expectedError);
      });

      test('should not update state if unmounted', () async {
        // Arrange
        final space = Space(
          id: '1',
          name: 'Test Space',
          userId: 'user-1',
          isArchived: true,
        );
        final unarchivedSpace = space.copyWith(isArchived: false);

        when(mockService.loadSpaces()).thenAnswer((_) async => [space]);
        when(mockService.unarchiveSpace(any)).thenAnswer(
          (_) async {
            // Simulate slow operation
            await Future<void>.delayed(const Duration(milliseconds: 100));
            return unarchivedSpace;
          },
        );

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );

        // Wait for initial build
        await container.read(spacesControllerProvider.future);

        // Act
        final controller = container.read(spacesControllerProvider.notifier);
        // Start unarchive but dispose immediately
        unawaited(controller.unarchiveSpace(space));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 150));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('getSpaceItemCount', () {
      test('should return count from service', () async {
        // Arrange
        when(mockService.loadSpaces()).thenAnswer((_) async => []);
        when(mockService.getSpaceItemCount('space-1'))
            .thenAnswer((_) async => 5);

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(spacesControllerProvider.future);

        // Act
        final controller = container.read(spacesControllerProvider.notifier);
        final count = await controller.getSpaceItemCount('space-1');

        // Assert
        expect(count, 5);
        verify(mockService.getSpaceItemCount('space-1')).called(1);
      });

      test('should return 0 when service throws error', () async {
        // Arrange
        when(mockService.loadSpaces()).thenAnswer((_) async => []);
        when(mockService.getSpaceItemCount('space-1'))
            .thenThrow(const AppError(
          code: ErrorCode.spaceNotFound,
          message: 'Space not found',
        ));

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(spacesControllerProvider.future);

        // Act
        final controller = container.read(spacesControllerProvider.notifier);
        final count = await controller.getSpaceItemCount('space-1');

        // Assert - fallback to 0
        expect(count, 0);
      });
    });
  });
}
