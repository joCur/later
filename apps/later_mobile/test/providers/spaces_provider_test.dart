import 'package:flutter_test/flutter_test.dart';
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
  int incrementItemCountCallCount = 0;
  int decrementItemCountCallCount = 0;

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
  Future<void> incrementItemCount(String spaceId) async {
    incrementItemCountCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to increment item count');
    }
    final space = mockSpaces.firstWhere(
      (s) => s.id == spaceId,
      orElse: () => throw Exception('Space with id $spaceId does not exist'),
    );
    final index = mockSpaces.indexOf(space);
    mockSpaces[index] = space.copyWith(itemCount: space.itemCount + 1);
  }

  @override
  Future<void> decrementItemCount(String spaceId) async {
    decrementItemCountCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to decrement item count');
    }
    final space = mockSpaces.firstWhere(
      (s) => s.id == spaceId,
      orElse: () => throw Exception('Space with id $spaceId does not exist'),
    );
    final index = mockSpaces.indexOf(space);
    final newCount = space.itemCount > 0 ? space.itemCount - 1 : 0;
    mockSpaces[index] = space.copyWith(itemCount: newCount);
  }

  /// Helper method to reset the mock state
  void reset() {
    mockSpaces.clear();
    shouldThrowError = false;
    errorMessage = null;
    createSpaceCallCount = 0;
    updateSpaceCallCount = 0;
    deleteSpaceCallCount = 0;
    incrementItemCountCallCount = 0;
    decrementItemCountCallCount = 0;
  }
}

void main() {
  late MockSpaceRepository mockRepository;
  late SpacesProvider provider;

  setUp(() {
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
          name: 'Work',
          icon: '💼',
          color: '#FF5733',
        ),
        Space(
          id: '2',
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
        Space(id: '1', name: 'Work'),
        Space(id: '2', name: 'Personal'),
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
        Space(id: '1', name: 'Work'),
        Space(id: '2', name: 'Old Project', isArchived: true),
        Space(id: '3', name: 'Personal'),
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
        Space(id: '1', name: 'Work'),
        Space(id: '2', name: 'Old Project', isArchived: true),
        Space(id: '3', name: 'Personal'),
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
      expect(provider.error, contains('Network error'));
      expect(provider.isLoading, isFalse);
      expect(provider.spaces, isEmpty);
    });

    test('should notify listeners on successful load', () async {
      // Arrange
      mockRepository.mockSpaces = [Space(id: '1', name: 'Work')];
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
        Space(id: '1', name: 'Work'),
        Space(id: '2', name: 'Personal'),
      ];
      mockRepository.mockSpaces = testSpaces;
      await provider.loadSpaces();
      await provider.switchSpace('2');

      // Act - reload spaces
      await provider.loadSpaces();

      // Assert - current space should remain as space 2
      expect(provider.currentSpace?.id, '2');
    });
  });

  group('SpacesProvider - addSpace', () {
    test('should add space successfully', () async {
      // Arrange
      final newSpace = Space(
        id: '1',
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
      final newSpace = Space(id: '1', name: 'Work');

      // Act
      await provider.addSpace(newSpace);

      // Assert
      expect(provider.currentSpace, equals(newSpace));
      expect(provider.currentSpace?.id, '1');
    });

    test('should persist new space as current selection', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.initialize();

      final newSpace = Space(id: '1', name: 'Work');

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
      final newSpace = Space(id: '1', name: 'Work');

      // Act
      await provider.addSpace(newSpace);

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.spaces, isEmpty);
      expect(provider.currentSpace, isNull);
    });

    test('should not persist space when adding fails', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.initialize();

      mockRepository.shouldThrowError = true;
      final newSpace = Space(id: '1', name: 'Work');

      // Act
      await provider.addSpace(newSpace);

      // Assert
      expect(provider.error, isNotNull);
      final persistedSpaceId = PreferencesService().getLastSelectedSpaceId();
      expect(persistedSpaceId, isNull);
    });

    test('should notify listeners when adding space', () async {
      // Arrange
      final newSpace = Space(id: '1', name: 'Work');
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      // Act
      await provider.addSpace(newSpace);

      // Assert
      expect(notifyCount, greaterThan(0));
    });
  });

  group('SpacesProvider - updateSpace', () {
    test('should update space successfully', () async {
      // Arrange
      final originalSpace = Space(id: '1', name: 'Work');
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

    test('should update current space if it is the one being updated', () async {
      // Arrange
      final space = Space(id: '1', name: 'Work');
      mockRepository.mockSpaces = [space];
      await provider.loadSpaces();

      final updatedSpace = space.copyWith(name: 'Updated Work');

      // Act
      await provider.updateSpace(updatedSpace);

      // Assert
      expect(provider.currentSpace?.name, 'Updated Work');
    });

    test('should handle error when updating space fails', () async {
      // Arrange
      final space = Space(id: '1', name: 'Work');
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
      final space = Space(id: '999', name: 'Non-existent');

      // Act
      await provider.updateSpace(space);

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.error, contains('does not exist'));
    });
  });

  group('SpacesProvider - deleteSpace', () {
    test('should delete space successfully', () async {
      // Arrange
      final space1 = Space(id: '1', name: 'Work');
      final space2 = Space(id: '2', name: 'Personal');
      mockRepository.mockSpaces = [space1, space2];
      await provider.loadSpaces();
      await provider.switchSpace('2'); // Switch to space 2 so we can delete space 1

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
      final space = Space(id: '1', name: 'Work');
      mockRepository.mockSpaces = [space];
      await provider.loadSpaces();

      // Act
      await provider.deleteSpace('1');

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.error, contains('current space'));
      expect(provider.spaces, hasLength(1)); // Space should still be there
      expect(mockRepository.deleteSpaceCallCount, 0); // Should not call repository
    });

    test('should handle error when deleting space fails', () async {
      // Arrange
      final space1 = Space(id: '1', name: 'Work');
      final space2 = Space(id: '2', name: 'Personal');
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
      final space1 = Space(id: '1', name: 'Work');
      final space2 = Space(id: '2', name: 'Personal');
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
  });

  group('SpacesProvider - switchSpace', () {
    test('should switch to different space', () async {
      // Arrange
      final space1 = Space(id: '1', name: 'Work');
      final space2 = Space(id: '2', name: 'Personal');
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
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.initialize();

      final space1 = Space(id: '1', name: 'Work');
      final space2 = Space(id: '2', name: 'Personal');
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
      final space = Space(id: '1', name: 'Work');
      mockRepository.mockSpaces = [space];
      await provider.loadSpaces();

      // Act
      await provider.switchSpace('999');

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.error, contains('not found'));
      expect(provider.currentSpace?.id, '1'); // Should remain unchanged
    });

    test('should notify listeners when switching space', () async {
      // Arrange
      final space1 = Space(id: '1', name: 'Work');
      final space2 = Space(id: '2', name: 'Personal');
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
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.initialize();

      final space = Space(id: '1', name: 'Work');
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

  group('SpacesProvider - incrementSpaceItemCount', () {
    test('should increment item count successfully', () async {
      // Arrange
      final space = Space(id: '1', name: 'Work', itemCount: 5);
      mockRepository.mockSpaces = [space];
      await provider.loadSpaces();

      // Act
      await provider.incrementSpaceItemCount('1');

      // Assert
      expect(provider.spaces.first.itemCount, 6);
      expect(mockRepository.incrementItemCountCallCount, 1);
      expect(provider.error, isNull);
    });

    test('should update current space if it is being incremented', () async {
      // Arrange
      final space = Space(id: '1', name: 'Work', itemCount: 5);
      mockRepository.mockSpaces = [space];
      await provider.loadSpaces();

      // Act
      await provider.incrementSpaceItemCount('1');

      // Assert
      expect(provider.currentSpace?.itemCount, 6);
    });

    test('should handle error when incrementing fails', () async {
      // Arrange
      final space = Space(id: '1', name: 'Work', itemCount: 5);
      mockRepository.mockSpaces = [space];
      await provider.loadSpaces();

      mockRepository.shouldThrowError = true;

      // Act
      await provider.incrementSpaceItemCount('1');

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.spaces.first.itemCount, 5); // Should remain unchanged
    });

    test('should handle incrementing non-existent space', () async {
      // Act
      await provider.incrementSpaceItemCount('999');

      // Assert
      expect(provider.error, isNotNull);
    });
  });

  group('SpacesProvider - decrementSpaceItemCount', () {
    test('should decrement item count successfully', () async {
      // Arrange
      final space = Space(id: '1', name: 'Work', itemCount: 5);
      mockRepository.mockSpaces = [space];
      await provider.loadSpaces();

      // Act
      await provider.decrementSpaceItemCount('1');

      // Assert
      expect(provider.spaces.first.itemCount, 4);
      expect(mockRepository.decrementItemCountCallCount, 1);
      expect(provider.error, isNull);
    });

    test('should update current space if it is being decremented', () async {
      // Arrange
      final space = Space(id: '1', name: 'Work', itemCount: 5);
      mockRepository.mockSpaces = [space];
      await provider.loadSpaces();

      // Act
      await provider.decrementSpaceItemCount('1');

      // Assert
      expect(provider.currentSpace?.itemCount, 4);
    });

    test('should not go below zero', () async {
      // Arrange
      final space = Space(id: '1', name: 'Work');
      mockRepository.mockSpaces = [space];
      await provider.loadSpaces();

      // Act
      await provider.decrementSpaceItemCount('1');

      // Assert
      expect(provider.spaces.first.itemCount, 0);
    });

    test('should handle error when decrementing fails', () async {
      // Arrange
      final space = Space(id: '1', name: 'Work', itemCount: 5);
      mockRepository.mockSpaces = [space];
      await provider.loadSpaces();

      mockRepository.shouldThrowError = true;

      // Act
      await provider.decrementSpaceItemCount('1');

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.spaces.first.itemCount, 5); // Should remain unchanged
    });

    test('should handle decrementing non-existent space', () async {
      // Act
      await provider.decrementSpaceItemCount('999');

      // Assert
      expect(provider.error, isNotNull);
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
