import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/data/local/preferences_service.dart';
import 'package:later_mobile/features/spaces/application/providers.dart';
import 'package:later_mobile/features/spaces/domain/models/space.dart';
import 'package:later_mobile/features/spaces/presentation/controllers/current_space_controller.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'spaces_controller_test.mocks.dart';

@GenerateMocks([])
void main() {
  group('CurrentSpaceController', () {
    late MockSpaceService mockService;

    setUp(() async {
      mockService = MockSpaceService();
      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      // Initialize PreferencesService before each test
      await PreferencesService.initialize();
    });

    tearDown(() {
      // Clean up after each test
      PreferencesService().reset();
      SharedPreferences.setMockInitialValues({});
    });

    group('build (initialization)', () {
      test('should restore persisted space from SharedPreferences', () async {
        // Arrange
        final testSpaces = [
          Space(id: '1', name: 'Space 1', userId: 'user-1'),
          Space(id: '2', name: 'Space 2', userId: 'user-1'),
        ];
        when(mockService.loadSpaces()).thenAnswer((_) async => testSpaces);

        // Set persisted space ID
        SharedPreferences.setMockInitialValues({
          'last_selected_space_id': '2',
        });
        await PreferencesService.initialize();

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Act
        final state = await container.read(currentSpaceControllerProvider.future);

        // Assert
        expect(state, isNotNull);
        expect(state?.id, '2');
        expect(state?.name, 'Space 2');
      });

      test('should select first space when no persisted space exists',
          () async {
        // Arrange
        final testSpaces = [
          Space(id: '1', name: 'Space 1', userId: 'user-1'),
          Space(id: '2', name: 'Space 2', userId: 'user-1'),
        ];
        when(mockService.loadSpaces()).thenAnswer((_) async => testSpaces);

        // No persisted space ID
        SharedPreferences.setMockInitialValues({});
        await PreferencesService.initialize();

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Act
        final state = await container.read(currentSpaceControllerProvider.future);

        // Assert
        expect(state, isNotNull);
        expect(state?.id, '1');
        expect(state?.name, 'Space 1');
      });

      test('should clear preference and select first when persisted space not found',
          () async {
        // Arrange
        final testSpaces = [
          Space(id: '1', name: 'Space 1', userId: 'user-1'),
          Space(id: '2', name: 'Space 2', userId: 'user-1'),
        ];
        when(mockService.loadSpaces()).thenAnswer((_) async => testSpaces);

        // Set persisted space ID that doesn't exist in spaces list
        SharedPreferences.setMockInitialValues({
          'last_selected_space_id': 'deleted-space-id',
        });
        await PreferencesService.initialize();

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Act
        final state = await container.read(currentSpaceControllerProvider.future);

        // Assert - should fallback to first space
        expect(state, isNotNull);
        expect(state?.id, '1');
        expect(state?.name, 'Space 1');

        // Verify preference was cleared
        final persistedId = PreferencesService().getLastSelectedSpaceId();
        expect(persistedId, isNull);
      });

      test('should return null when no spaces exist', () async {
        // Arrange
        when(mockService.loadSpaces()).thenAnswer((_) async => []);

        SharedPreferences.setMockInitialValues({});
        await PreferencesService.initialize();

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Act
        final state = await container.read(currentSpaceControllerProvider.future);

        // Assert
        expect(state, isNull);
      });
    });

    group('switchSpace', () {
      test('should update state and persist to SharedPreferences', () async {
        // Arrange
        final space1 = Space(id: '1', name: 'Space 1', userId: 'user-1');
        final space2 = Space(id: '2', name: 'Space 2', userId: 'user-1');
        when(mockService.loadSpaces())
            .thenAnswer((_) async => [space1, space2]);

        SharedPreferences.setMockInitialValues({});
        await PreferencesService.initialize();

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(currentSpaceControllerProvider.future);

        // Act
        final controller =
            container.read(currentSpaceControllerProvider.notifier);
        await controller.switchSpace(space2);

        // Assert - state updated
        final state = container.read(currentSpaceControllerProvider);
        expect(state.value?.id, '2');

        // Assert - persisted to SharedPreferences
        final persistedId = PreferencesService().getLastSelectedSpaceId();
        expect(persistedId, '2');
      });

      test('should update state immediately even if persistence fails',
          () async {
        // Arrange
        final space1 = Space(id: '1', name: 'Space 1', userId: 'user-1');
        final space2 = Space(id: '2', name: 'Space 2', userId: 'user-1');
        when(mockService.loadSpaces())
            .thenAnswer((_) async => [space1, space2]);

        SharedPreferences.setMockInitialValues({});
        await PreferencesService.initialize();

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(currentSpaceControllerProvider.future);

        // Reset PreferencesService to simulate failure
        PreferencesService().reset();

        // Act
        final controller =
            container.read(currentSpaceControllerProvider.notifier);
        await controller.switchSpace(space2);

        // Assert - state should still be updated despite persistence failure
        final state = container.read(currentSpaceControllerProvider);
        expect(state.value?.id, '2');
      });

      test('should not update state if unmounted', () async {
        // Arrange
        final space1 = Space(id: '1', name: 'Space 1', userId: 'user-1');
        final space2 = Space(id: '2', name: 'Space 2', userId: 'user-1');
        when(mockService.loadSpaces())
            .thenAnswer((_) async => [space1, space2]);

        SharedPreferences.setMockInitialValues({});
        await PreferencesService.initialize();

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );

        // Wait for initial build
        await container.read(currentSpaceControllerProvider.future);

        // Act
        final controller =
            container.read(currentSpaceControllerProvider.notifier);
        // Start switch but dispose immediately
        unawaited(controller.switchSpace(space2));
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('clearCurrentSpace', () {
      test('should set state to null and clear SharedPreferences', () async {
        // Arrange
        final space = Space(id: '1', name: 'Space 1', userId: 'user-1');
        when(mockService.loadSpaces()).thenAnswer((_) async => [space]);

        SharedPreferences.setMockInitialValues({
          'last_selected_space_id': '1',
        });
        await PreferencesService.initialize();

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(currentSpaceControllerProvider.future);

        // Act
        final controller =
            container.read(currentSpaceControllerProvider.notifier);
        await controller.clearCurrentSpace();

        // Assert - state is null
        final state = container.read(currentSpaceControllerProvider);
        expect(state.value, isNull);

        // Assert - preference cleared
        final persistedId = PreferencesService().getLastSelectedSpaceId();
        expect(persistedId, isNull);
      });

      test('should clear state even if preference clear fails', () async {
        // Arrange
        final space = Space(id: '1', name: 'Space 1', userId: 'user-1');
        when(mockService.loadSpaces()).thenAnswer((_) async => [space]);

        SharedPreferences.setMockInitialValues({
          'last_selected_space_id': '1',
        });
        await PreferencesService.initialize();

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(currentSpaceControllerProvider.future);

        // Reset PreferencesService to simulate failure
        PreferencesService().reset();

        // Act
        final controller =
            container.read(currentSpaceControllerProvider.notifier);
        await controller.clearCurrentSpace();

        // Assert - state should still be cleared despite persistence failure
        final state = container.read(currentSpaceControllerProvider);
        expect(state.value, isNull);
      });

      test('should not update state if unmounted', () async {
        // Arrange
        final space = Space(id: '1', name: 'Space 1', userId: 'user-1');
        when(mockService.loadSpaces()).thenAnswer((_) async => [space]);

        SharedPreferences.setMockInitialValues({
          'last_selected_space_id': '1',
        });
        await PreferencesService.initialize();

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );

        // Wait for initial build
        await container.read(currentSpaceControllerProvider.future);

        // Act
        final controller =
            container.read(currentSpaceControllerProvider.notifier);
        // Start clear but dispose immediately
        unawaited(controller.clearCurrentSpace());
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('setToFirstAvailableSpace', () {
      test('should switch to first space when spaces exist', () async {
        // Arrange
        final space1 = Space(id: '1', name: 'Space 1', userId: 'user-1');
        final space2 = Space(id: '2', name: 'Space 2', userId: 'user-1');
        when(mockService.loadSpaces())
            .thenAnswer((_) async => [space1, space2]);

        SharedPreferences.setMockInitialValues({});
        await PreferencesService.initialize();

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(currentSpaceControllerProvider.future);

        // Act
        final controller =
            container.read(currentSpaceControllerProvider.notifier);
        await controller.setToFirstAvailableSpace();

        // Assert
        final state = container.read(currentSpaceControllerProvider);
        expect(state.value?.id, '1');
        expect(state.value?.name, 'Space 1');

        // Verify persisted
        final persistedId = PreferencesService().getLastSelectedSpaceId();
        expect(persistedId, '1');
      });

      test('should clear current space when no spaces exist', () async {
        // Arrange
        when(mockService.loadSpaces()).thenAnswer((_) async => []);

        SharedPreferences.setMockInitialValues({
          'last_selected_space_id': 'some-space',
        });
        await PreferencesService.initialize();

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Wait for initial build
        await container.read(currentSpaceControllerProvider.future);

        // Act
        final controller =
            container.read(currentSpaceControllerProvider.notifier);
        await controller.setToFirstAvailableSpace();

        // Assert
        final state = container.read(currentSpaceControllerProvider);
        expect(state.value, isNull);

        // Verify preference cleared
        final persistedId = PreferencesService().getLastSelectedSpaceId();
        expect(persistedId, isNull);
      });


      test('should not update state if unmounted', () async {
        // Arrange
        final space = Space(id: '1', name: 'Space 1', userId: 'user-1');
        when(mockService.loadSpaces()).thenAnswer((_) async => [space]);

        SharedPreferences.setMockInitialValues({});
        await PreferencesService.initialize();

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );

        // Wait for initial build
        await container.read(currentSpaceControllerProvider.future);

        // Act
        final controller =
            container.read(currentSpaceControllerProvider.notifier);
        // Start operation but dispose immediately
        unawaited(controller.setToFirstAvailableSpace());
        container.dispose();

        // Wait for operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Assert - no state updates after disposal (verified by no errors thrown)
      });
    });

    group('Integration scenarios', () {
      test('should handle complete workflow: init -> switch -> clear', () async {
        // Arrange
        final space1 = Space(id: '1', name: 'Space 1', userId: 'user-1');
        final space2 = Space(id: '2', name: 'Space 2', userId: 'user-1');
        when(mockService.loadSpaces())
            .thenAnswer((_) async => [space1, space2]);

        SharedPreferences.setMockInitialValues({});
        await PreferencesService.initialize();

        final container = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Act & Assert - Initial state (first space)
        final initialState = await container.read(currentSpaceControllerProvider.future);
        expect(initialState?.id, '1');

        // Act & Assert - Switch to second space
        final controller =
            container.read(currentSpaceControllerProvider.notifier);
        await controller.switchSpace(space2);
        final afterSwitch = container.read(currentSpaceControllerProvider);
        expect(afterSwitch.value?.id, '2');

        // Act & Assert - Clear current space
        await controller.clearCurrentSpace();
        final afterClear = container.read(currentSpaceControllerProvider);
        expect(afterClear.value, isNull);

        // Verify persistence was cleared
        final persistedId = PreferencesService().getLastSelectedSpaceId();
        expect(persistedId, isNull);
      });

      test('should persist selection across controller instances', () async {
        // Arrange
        final space1 = Space(id: '1', name: 'Space 1', userId: 'user-1');
        final space2 = Space(id: '2', name: 'Space 2', userId: 'user-1');
        when(mockService.loadSpaces())
            .thenAnswer((_) async => [space1, space2]);

        SharedPreferences.setMockInitialValues({});
        await PreferencesService.initialize();

        // First container
        final container1 = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );

        await container1.read(currentSpaceControllerProvider.future);
        final controller1 =
            container1.read(currentSpaceControllerProvider.notifier);
        await controller1.switchSpace(space2);
        container1.dispose();

        // Second container (simulating app restart)
        final container2 = ProviderContainer.test(
          overrides: [
            spaceServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container2.dispose);

        // Act - Load state in new container
        final restoredState = await container2.read(currentSpaceControllerProvider.future);

        // Assert - should restore to space2
        expect(restoredState?.id, '2');
      });
    });
  });
}
