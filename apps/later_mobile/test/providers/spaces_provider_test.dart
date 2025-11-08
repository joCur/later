import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/error/app_error.dart';
import 'package:later_mobile/data/local/preferences_service.dart';
import 'package:later_mobile/data/models/space_model.dart';
import 'package:later_mobile/data/repositories/space_repository.dart';
import 'package:later_mobile/providers/spaces_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mock implementation of SpaceRepository for testing
class MockSpaceRepository extends SpaceRepository {
  List<Space> mockSpaces = [];
  bool shouldThrowError = false;
  String? errorMessage;

  // Track method calls for verification
  int createSpaceCallCount = 0;
  int updateSpaceCallCount = 0;
  int deleteSpaceCallCount = 0;

  // Allow overriding getItemCount behavior for tests
  Future<int> Function(String)? _getItemCountOverride;

  @override
  Future<List<Space>> getSpaces({bool includeArchived = false}) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to get spaces');
    }
    if (includeArchived) {
      return List.from(mockSpaces);
    }
    return mockSpaces.where((space) => !space.isArchived).toList();
  }

  @override
  Future<Space?> getSpaceById(String id) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to get space');
    }
    try {
      return mockSpaces.firstWhere((space) => space.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Space> createSpace(Space space) async {
    createSpaceCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to create space');
    }
    mockSpaces.add(space);
    return space;
  }

  @override
  Future<Space> updateSpace(Space space) async {
    updateSpaceCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to update space');
    }
    final index = mockSpaces.indexWhere((s) => s.id == space.id);
    if (index == -1) {
      throw Exception('Space with id ${space.id} does not exist');
    }
    mockSpaces[index] = space;
    return space;
  }

  @override
  Future<void> deleteSpace(String id) async {
    deleteSpaceCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to delete space');
    }
    mockSpaces.removeWhere((space) => space.id == id);
  }

  @override
  Future<int> getItemCount(String spaceId) async {
    if (_getItemCountOverride != null) {
      return _getItemCountOverride!(spaceId);
    }
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to get item count');
    }
    // For testing purposes, return a mock count
    // In real tests, this can be overridden with specific values
    return 0;
  }

  /// Allows overriding getItemCount behavior for specific tests
  void setGetItemCountOverride(Future<int> Function(String) fn) {
    _getItemCountOverride = fn;
  }

  /// Helper method to reset the mock state
  void reset() {
    mockSpaces.clear();
    shouldThrowError = false;
    errorMessage = null;
    createSpaceCallCount = 0;
    updateSpaceCallCount = 0;
    deleteSpaceCallCount = 0;
    _getItemCountOverride = null;
  }
}

void main() {
  late MockSpaceRepository mockRepository;
  late SpacesProvider provider;

  setUp(() async {
    // Initialize SharedPreferences for tests
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.initialize();

    mockRepository = MockSpaceRepository();
    provider = SpacesProvider(mockRepository);
  });

  tearDown(() {
    mockRepository.reset();
    PreferencesService().reset();
  });

  group('SpacesProvider - Initial State', () {
    test('should have empty spaces list initially', () {
      expect(provider.spaces, isEmpty);
    });

    test('should have no current space initially', () {
      expect(provider.currentSpace, isNull);
    });

    test('should not be loading initially', () {
      expect(provider.isLoading, isFalse);
    });

    test('should have no error initially', () {
      expect(provider.error, isNull);
    });
  });

  group('SpacesProvider - loadSpaces', () {
    test('should load spaces successfully', () async {
      // Arrange
      final testSpaces = [
        Space(
          id: '1',
          userId: 'test-user',
          name: 'Work',
          icon: '💼',
          color: '#FF5733',
        ),
        Space(
          id: '2',
          userId: 'test-user',
          name: 'Personal',
          icon: '🏠',
          color: '#33FF57',
        ),
      ];
      mockRepository.mockSpaces = testSpaces;

      // Act
      await provider.loadSpaces();

      // Assert
      expect(provider.spaces, hasLength(2));
      expect(provider.spaces[0].name, 'Work');
      expect(provider.spaces[1].name, 'Personal');
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('should set first space as current space when loading', () async {
      // Arrange
      final testSpaces = [
        Space(id: '1', userId: 'test-user', name: 'Work'),
        Space(id: '2', userId: 'test-user', name: 'Personal'),
      ];
      mockRepository.mockSpaces = testSpaces;

      // Act
      await provider.loadSpaces();

      // Assert
      expect(provider.currentSpace, isNotNull);
      expect(provider.currentSpace?.id, '1');
    });

    test('should exclude archived spaces by default', () async {
      // Arrange
      final testSpaces = [
        Space(id: '1', userId: 'test-user', name: 'Work'),
        Space(
          id: '2',
          userId: 'test-user',
          name: 'Old Project',
          isArchived: true,
        ),
        Space(id: '3', userId: 'test-user', name: 'Personal'),
      ];
      mockRepository.mockSpaces = testSpaces;

      // Act
      await provider.loadSpaces();

      // Assert
      expect(provider.spaces, hasLength(2));
      expect(provider.spaces.any((s) => s.isArchived), isFalse);
    });

    test('should include archived spaces when requested', () async {
      // Arrange
      final testSpaces = [
        Space(id: '1', userId: 'test-user', name: 'Work'),
        Space(
          id: '2',
          userId: 'test-user',
          name: 'Old Project',
          isArchived: true,
        ),
        Space(id: '3', userId: 'test-user', name: 'Personal'),
      ];
      mockRepository.mockSpaces = testSpaces;

      // Act
      await provider.loadSpaces(includeArchived: true);

      // Assert
      expect(provider.spaces, hasLength(3));
      expect(provider.spaces.where((s) => s.isArchived), hasLength(1));
    });

    test('should set loading state during loadSpaces', () async {
      // Arrange
      bool wasLoadingDuringCall = false;
      provider.addListener(() {
        if (provider.isLoading) {
          wasLoadingDuringCall = true;
        }
      });

      // Act
      await provider.loadSpaces();

      // Assert
      expect(wasLoadingDuringCall, isTrue);
      expect(provider.isLoading, isFalse);
    });

    test('should handle error when loading spaces fails', () async {
      // Arrange
      mockRepository.shouldThrowError = true;
      mockRepository.errorMessage = 'Network error';

      // Act
      await provider.loadSpaces();

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.error.toString(), contains('Network error'));
      expect(provider.isLoading, isFalse);
      expect(provider.spaces, isEmpty);
    });

    test('should notify listeners on successful load', () async {
      // Arrange
      mockRepository.mockSpaces = [
        Space(id: '1', userId: 'test-user', name: 'Work'),
      ];
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      // Act
      await provider.loadSpaces();

      // Assert - should notify at least twice (loading start, loading complete)
      expect(notifyCount, greaterThanOrEqualTo(2));
    });

    test('should not set current space if already set', () async {
      // Arrange
      final testSpaces = [
        Space(id: '1', userId: 'test-user', name: 'Work'),
        Space(id: '2', userId: 'test-user', name: 'Personal'),
      ];
      mockRepository.mockSpaces = testSpaces;
      await provider.loadSpaces();
      await provider.switchSpace('2');

      // Act - reload spaces
      await provider.loadSpaces();

      // Assert - current space should remain as space 2
      expect(provider.currentSpace?.id, '2');
    });

    test('should restore persisted space selection on load', () async {
      // Arrange
      final testSpaces = [
        Space(id: '1', userId: 'test-user', name: 'Work'),
        Space(id: '2', userId: 'test-user', name: 'Personal'),
        Space(id: '3', userId: 'test-user', name: 'Projects'),
      ];
      mockRepository.mockSpaces = testSpaces;

      // Persist space '2' as the last selected space
      await PreferencesService().setLastSelectedSpaceId('2');

      // Act - load spaces (should restore persisted selection)
      await provider.loadSpaces();

      // Assert - should restore space 2, not default to first space
      expect(provider.currentSpace, isNotNull);
      expect(provider.currentSpace?.id, '2');
      expect(provider.currentSpace?.name, 'Personal');
    });

    test(
      'should fall back to first space when persisted space does not exist',
      () async {
        // Arrange
        final testSpaces = [
          Space(id: '1', userId: 'test-user', name: 'Work'),
          Space(id: '2', userId: 'test-user', name: 'Personal'),
        ];
        mockRepository.mockSpaces = testSpaces;

        // Persist a space ID that doesn't exist anymore (simulating deleted space)
        await PreferencesService().setLastSelectedSpaceId('999');

        // Act - load spaces (should fall back to first space)
        await provider.loadSpaces();

        // Assert - should fall back to first space
        expect(provider.currentSpace, isNotNull);
        expect(provider.currentSpace?.id, '1');
        expect(provider.currentSpace?.name, 'Work');
      },
    );

    test('should clear persisted space ID when it does not exist', () async {
      // Arrange
      final testSpaces = [
        Space(id: '1', userId: 'test-user', name: 'Work'),
        Space(id: '2', userId: 'test-user', name: 'Personal'),
      ];
      mockRepository.mockSpaces = testSpaces;

      // Persist a space ID that doesn't exist anymore
      await PreferencesService().setLastSelectedSpaceId('999');
      expect(PreferencesService().getLastSelectedSpaceId(), '999');

      // Act - load spaces (should clear invalid persisted ID)
      await provider.loadSpaces();

      // Assert - should clear the invalid persisted space ID
      final persistedSpaceId = PreferencesService().getLastSelectedSpaceId();
      expect(persistedSpaceId, isNull);
    });

    test(
      'should prioritize persisted space over first space on initial load',
      () async {
        // Arrange
        final testSpaces = [
          Space(id: '1', userId: 'test-user', name: 'Work'),
          Space(id: '2', userId: 'test-user', name: 'Personal'),
          Space(id: '3', userId: 'test-user', name: 'Projects'),
        ];
        mockRepository.mockSpaces = testSpaces;

        // Persist space '3' as the last selected space
        await PreferencesService().setLastSelectedSpaceId('3');

        // Act - load spaces on fresh provider (simulating app restart)
        await provider.loadSpaces();

        // Assert - should load persisted space '3', not default to first space
        expect(provider.currentSpace?.id, '3');
        expect(provider.currentSpace?.name, 'Projects');
      },
    );

    test('should handle null persisted space ID gracefully', () async {
      // Arrange
      final testSpaces = [
        Space(id: '1', userId: 'test-user', name: 'Work'),
        Space(id: '2', userId: 'test-user', name: 'Personal'),
      ];
      mockRepository.mockSpaces = testSpaces;

      // No persisted space ID (fresh install scenario)
      expect(PreferencesService().getLastSelectedSpaceId(), isNull);

      // Act - load spaces
      await provider.loadSpaces();

      // Assert - should default to first space
      expect(provider.currentSpace, isNotNull);
      expect(provider.currentSpace?.id, '1');
      expect(provider.currentSpace?.name, 'Work');
    });
  });

  group('SpacesProvider - addSpace', () {
    test('should add space successfully', () async {
      // Arrange
      final newSpace = Space(
        id: '1',
        userId: 'test-user',
        name: 'Work',
        icon: '💼',
        color: '#FF5733',
      );

      // Act
      await provider.addSpace(newSpace);

      // Assert
      expect(provider.spaces, contains(newSpace));
      expect(mockRepository.createSpaceCallCount, 1);
      expect(provider.error, isNull);
    });

    test('should set new space as current space', () async {
      // Arrange
      final newSpace = Space(id: '1', userId: 'test-user', name: 'Work');

      // Act
      await provider.addSpace(newSpace);

      // Assert
      expect(provider.currentSpace, equals(newSpace));
      expect(provider.currentSpace?.id, '1');
    });

    test('should persist new space as current selection', () async {
      // Arrange
      final newSpace = Space(id: '1', userId: 'test-user', name: 'Work');

      // Act
      await provider.addSpace(newSpace);

      // Assert
      expect(provider.currentSpace?.id, '1');
      final persistedSpaceId = PreferencesService().getLastSelectedSpaceId();
      expect(persistedSpaceId, '1');
    });

    test('should handle error when adding space fails', () async {
      // Arrange
      mockRepository.shouldThrowError = true;
      final newSpace = Space(id: '1', userId: 'test-user', name: 'Work');

      // Act
      await provider.addSpace(newSpace);

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.spaces, isEmpty);
      expect(provider.currentSpace, isNull);
    });

    test('should not persist space when adding fails', () async {
      // Arrange
      mockRepository.shouldThrowError = true;
      final newSpace = Space(id: '1', userId: 'test-user', name: 'Work');

      // Act
      await provider.addSpace(newSpace);

      // Assert
      expect(provider.error, isNotNull);
      final persistedSpaceId = PreferencesService().getLastSelectedSpaceId();
      expect(persistedSpaceId, isNull);
    });

    test('should notify listeners when adding space', () async {
      // Arrange
      final newSpace = Space(id: '1', userId: 'test-user', name: 'Work');
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      // Act
      await provider.addSpace(newSpace);

      // Assert
      expect(notifyCount, greaterThan(0));
    });

    test('should wrap unknown errors with context-specific message', () async {
      // Arrange
      mockRepository.shouldThrowError = true;
      mockRepository.errorMessage = 'Unknown database error';
      final newSpace = Space(id: '1', userId: 'test-user', name: 'Work');

      // Act
      await provider.addSpace(newSpace);

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.error!.type, ErrorType.unknown);
      expect(provider.error!.message, contains('Failed to create space'));
      expect(
        provider.error!.userMessage,
        'Could not create the space. Please check your connection and try again.',
      );
      expect(provider.spaces, isEmpty);
      expect(provider.currentSpace, isNull);
    });
  });

  group('SpacesProvider - updateSpace', () {
    test('should update space successfully', () async {
      // Arrange
      final originalSpace = Space(id: '1', userId: 'test-user', name: 'Work');
      mockRepository.mockSpaces = [originalSpace];
      await provider.loadSpaces();

      final updatedSpace = originalSpace.copyWith(name: 'Updated Work');

      // Act
      await provider.updateSpace(updatedSpace);

      // Assert
      expect(provider.spaces.first.name, 'Updated Work');
      expect(mockRepository.updateSpaceCallCount, 1);
      expect(provider.error, isNull);
    });

    test(
      'should update current space if it is the one being updated',
      () async {
        // Arrange
        final space = Space(id: '1', userId: 'test-user', name: 'Work');
        mockRepository.mockSpaces = [space];
        await provider.loadSpaces();

        final updatedSpace = space.copyWith(name: 'Updated Work');

        // Act
        await provider.updateSpace(updatedSpace);

        // Assert
        expect(provider.currentSpace?.name, 'Updated Work');
      },
    );

    test('should handle error when updating space fails', () async {
      // Arrange
      final space = Space(id: '1', userId: 'test-user', name: 'Work');
      mockRepository.mockSpaces = [space];
      await provider.loadSpaces();

      mockRepository.shouldThrowError = true;
      final updatedSpace = space.copyWith(name: 'Updated Work');

      // Act
      await provider.updateSpace(updatedSpace);

      // Assert
      expect(provider.error, isNotNull);
    });

    test('should handle updating non-existent space', () async {
      // Arrange
      final space = Space(id: '999', userId: 'test-user', name: 'Non-existent');

      // Act
      await provider.updateSpace(space);

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.error.toString(), contains('does not exist'));
    });

    test('should keep persisted space ID when archiving current space', () async {
      // Arrange
      final space = Space(id: '1', userId: 'test-user', name: 'Work');
      mockRepository.mockSpaces = [space];
      await provider.loadSpaces();

      // Manually persist the space (in real usage, switchSpace or addSpace would do this)
      await PreferencesService().setLastSelectedSpaceId('1');
      expect(PreferencesService().getLastSelectedSpaceId(), '1');

      // Act - archive the current space
      final archivedSpace = space.copyWith(isArchived: true);
      await provider.updateSpace(archivedSpace);

      // Assert
      expect(provider.currentSpace?.isArchived, true);
      // Design decision: Keep the persisted space ID even when archiving
      // This allows the archived space to be restored on next app start
      expect(PreferencesService().getLastSelectedSpaceId(), '1');
    });

    test(
      'should keep persisted space ID when archiving non-current space',
      () async {
        // Arrange
        final space1 = Space(id: '1', userId: 'test-user', name: 'Work');
        final space2 = Space(id: '2', userId: 'test-user', name: 'Personal');
        mockRepository.mockSpaces = [space1, space2];
        await provider.loadSpaces();

        // Manually persist space1 (in real usage, switchSpace or addSpace would do this)
        await PreferencesService().setLastSelectedSpaceId('1');
        expect(PreferencesService().getLastSelectedSpaceId(), '1');

        // Act - archive space2 (not the current space)
        final archivedSpace2 = space2.copyWith(isArchived: true);
        await provider.updateSpace(archivedSpace2);

        // Assert
        expect(provider.currentSpace?.id, '1'); // Current space unchanged
        // Persisted space ID should remain unchanged
        expect(PreferencesService().getLastSelectedSpaceId(), '1');
      },
    );
  });

  group('SpacesProvider - deleteSpace', () {
    test('should delete space successfully', () async {
      // Arrange
      final space1 = Space(id: '1', userId: 'test-user', name: 'Work');
      final space2 = Space(id: '2', userId: 'test-user', name: 'Personal');
      mockRepository.mockSpaces = [space1, space2];
      await provider.loadSpaces();
      await provider.switchSpace(
        '2',
      ); // Switch to space 2 so we can delete space 1

      // Act
      await provider.deleteSpace('1');

      // Assert
      expect(provider.spaces, hasLength(1));
      expect(provider.spaces.first.id, '2');
      expect(mockRepository.deleteSpaceCallCount, 1);
      expect(provider.error, isNull);
    });

    test('should prevent deleting current space', () async {
      // Arrange
      final space = Space(id: '1', userId: 'test-user', name: 'Work');
      mockRepository.mockSpaces = [space];
      await provider.loadSpaces();

      // Act
      await provider.deleteSpace('1');

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.error.toString(), contains('current space'));
      expect(provider.spaces, hasLength(1)); // Space should still be there
      expect(
        mockRepository.deleteSpaceCallCount,
        0,
      ); // Should not call repository
    });

    test('should handle error when deleting space fails', () async {
      // Arrange
      final space1 = Space(id: '1', userId: 'test-user', name: 'Work');
      final space2 = Space(id: '2', userId: 'test-user', name: 'Personal');
      mockRepository.mockSpaces = [space1, space2];
      await provider.loadSpaces();

      mockRepository.shouldThrowError = true;

      // Act
      await provider.deleteSpace('2');

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.spaces, hasLength(2)); // Spaces should still be there
    });

    test('should notify listeners when deleting space', () async {
      // Arrange
      final space1 = Space(id: '1', userId: 'test-user', name: 'Work');
      final space2 = Space(id: '2', userId: 'test-user', name: 'Personal');
      mockRepository.mockSpaces = [space1, space2];
      await provider.loadSpaces();
      await provider.switchSpace('2');

      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      // Act
      await provider.deleteSpace('1');

      // Assert
      expect(notifyCount, greaterThan(0));
    });

    test(
      'should clear persisted space ID when deleting a persisted space',
      () async {
        // Arrange
        final space1 = Space(id: '1', userId: 'test-user', name: 'Work');
        final space2 = Space(id: '2', userId: 'test-user', name: 'Personal');
        final space3 = Space(id: '3', userId: 'test-user', name: 'Hobby');
        mockRepository.mockSpaces = [space1, space2, space3];
        await provider.loadSpaces();

        // Switch to space2 (this will persist '2')
        await provider.switchSpace('2');
        expect(PreferencesService().getLastSelectedSpaceId(), '2');

        // Manually set the persisted space to space3 (simulating a previous session)
        await PreferencesService().setLastSelectedSpaceId('3');
        expect(PreferencesService().getLastSelectedSpaceId(), '3');

        // Act - delete space3 (the persisted one, but not the current one)
        await provider.deleteSpace('3');

        // Assert
        expect(provider.spaces, hasLength(2));
        // The persisted space ID should be cleared since we deleted the persisted space
        expect(PreferencesService().getLastSelectedSpaceId(), isNull);
      },
    );

    test(
      'should not clear persisted space ID when deleting a non-persisted space',
      () async {
        // Arrange
        final space1 = Space(id: '1', userId: 'test-user', name: 'Work');
        final space2 = Space(id: '2', userId: 'test-user', name: 'Personal');
        final space3 = Space(id: '3', userId: 'test-user', name: 'Hobby');
        mockRepository.mockSpaces = [space1, space2, space3];
        await provider.loadSpaces();

        // Switch to space2 (this will persist '2')
        await provider.switchSpace('2');
        expect(PreferencesService().getLastSelectedSpaceId(), '2');

        // Act - delete space3 (neither current nor persisted)
        await provider.deleteSpace('3');

        // Assert
        expect(provider.spaces, hasLength(2));
        // The persisted space ID should still be '2' since we didn't delete it
        expect(PreferencesService().getLastSelectedSpaceId(), '2');
      },
    );
  });

  group('SpacesProvider - switchSpace', () {
    test('should switch to different space', () async {
      // Arrange
      final space1 = Space(id: '1', userId: 'test-user', name: 'Work');
      final space2 = Space(id: '2', userId: 'test-user', name: 'Personal');
      mockRepository.mockSpaces = [space1, space2];
      await provider.loadSpaces();

      // Act
      await provider.switchSpace('2');

      // Assert
      expect(provider.currentSpace?.id, '2');
      expect(provider.currentSpace?.name, 'Personal');
    });

    test('should persist space selection when switching space', () async {
      // Arrange
      final space1 = Space(id: '1', userId: 'test-user', name: 'Work');
      final space2 = Space(id: '2', userId: 'test-user', name: 'Personal');
      mockRepository.mockSpaces = [space1, space2];
      await provider.loadSpaces();

      // Act
      await provider.switchSpace('2');

      // Assert
      expect(provider.currentSpace?.id, '2');
      final persistedSpaceId = PreferencesService().getLastSelectedSpaceId();
      expect(persistedSpaceId, '2');
    });

    test('should handle switching to non-existent space', () async {
      // Arrange
      final space = Space(id: '1', userId: 'test-user', name: 'Work');
      mockRepository.mockSpaces = [space];
      await provider.loadSpaces();

      // Act
      await provider.switchSpace('999');

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.error.toString(), contains('not found'));
      expect(provider.currentSpace?.id, '1'); // Should remain unchanged
    });

    test('should notify listeners when switching space', () async {
      // Arrange
      final space1 = Space(id: '1', userId: 'test-user', name: 'Work');
      final space2 = Space(id: '2', userId: 'test-user', name: 'Personal');
      mockRepository.mockSpaces = [space1, space2];
      await provider.loadSpaces();

      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      // Act
      await provider.switchSpace('2');

      // Assert
      expect(notifyCount, 1);
    });

    test('should not persist space selection when switch fails', () async {
      // Arrange
      final space = Space(id: '1', userId: 'test-user', name: 'Work');
      mockRepository.mockSpaces = [space];
      await provider.loadSpaces();

      // Act
      await provider.switchSpace('999'); // Non-existent space

      // Assert
      expect(provider.error, isNotNull);
      // Should still have the original space ID persisted (from loadSpaces)
      final persistedSpaceId = PreferencesService().getLastSelectedSpaceId();
      expect(persistedSpaceId, isNull); // No persistence on failed switch
    });
  });

  group('SpacesProvider - getSpaceItemCount', () {
    test('should return count from repository', () async {
      // Arrange
      mockRepository.setGetItemCountOverride((String spaceId) async => 5);

      // Act
      final count = await provider.getSpaceItemCount('1');

      // Assert
      expect(count, 5);
    });

    test('should return 0 on error', () async {
      // Arrange
      mockRepository.shouldThrowError = true;

      // Act
      final count = await provider.getSpaceItemCount('1');

      // Assert
      expect(count, 0);
    });
  });

  group('SpacesProvider - clearError', () {
    test('should clear error message', () async {
      // Arrange
      mockRepository.shouldThrowError = true;
      await provider.loadSpaces();
      expect(provider.error, isNotNull);

      // Act
      provider.clearError();

      // Assert
      expect(provider.error, isNull);
    });

    test('should notify listeners when clearing error', () {
      // Arrange
      mockRepository.shouldThrowError = true;
      provider.loadSpaces();

      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      // Act
      provider.clearError();

      // Assert
      expect(notifyCount, 1);
    });
  });
}
