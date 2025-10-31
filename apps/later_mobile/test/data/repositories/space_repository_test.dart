import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:later_mobile/data/models/space_model.dart';
import 'package:later_mobile/data/repositories/space_repository.dart';

void main() {
  group('SpaceRepository Tests', () {
    late SpaceRepository repository;
    late Box<Space> spacesBox;

    setUp(() async {
      // Initialize Hive in test directory
      const tempDir = '.dart_tool/test/hive';
      Hive.init(tempDir);

      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(SpaceAdapter());
      }

      // Open box
      spacesBox = await Hive.openBox<Space>('spaces');
      repository = SpaceRepository();
    });

    tearDown(() async {
      // Clear and close the box
      await spacesBox.clear();
      await spacesBox.close();
      await Hive.deleteBoxFromDisk('spaces');
    });

    /// Helper function to create a test space
    Space createTestSpace({
      String? id,
      String name = 'Test Space',
      String? icon,
      String? color,
      bool isArchived = false,
    }) {
      return Space(
        id: id ?? 'space-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        icon: icon,
        color: color,
        isArchived: isArchived,
      );
    }

    group('createSpace', () {
      test('should successfully create a space', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1', name: 'Work');

        // Act
        final result = await repository.createSpace(space);

        // Assert
        expect(result.id, equals('space-1'));
        expect(result.name, equals('Work'));
        expect(spacesBox.length, equals(1));
        expect(spacesBox.get('space-1'), isNotNull);
      });

      test('should add space to Hive box with correct key', () async {
        // Arrange
        final space = createTestSpace(id: 'space-2', name: 'Personal');

        // Act
        await repository.createSpace(space);

        // Assert
        final storedSpace = spacesBox.get('space-2');
        expect(storedSpace, isNotNull);
        expect(storedSpace!.name, equals('Personal'));
      });

      test('should create multiple spaces', () async {
        // Arrange
        final space1 = createTestSpace(id: 'space-1', name: 'Work');
        final space2 = createTestSpace(id: 'space-2', name: 'Personal');
        final space3 = createTestSpace(id: 'space-3', name: 'Projects');

        // Act
        await repository.createSpace(space1);
        await repository.createSpace(space2);
        await repository.createSpace(space3);

        // Assert
        expect(spacesBox.length, equals(3));
      });

      test('should create space with icon and color', () async {
        // Arrange
        final space = createTestSpace(
          id: 'space-1',
          name: 'Work',
          icon: '💼',
          color: '#FF5733',
        );

        // Act
        final result = await repository.createSpace(space);

        // Assert
        expect(result.icon, equals('💼'));
        expect(result.color, equals('#FF5733'));
      });
    });

    group('getSpaces', () {
      test('should return empty list when no spaces exist', () async {
        // Act
        final result = await repository.getSpaces();

        // Assert
        expect(result, isEmpty);
      });

      test('should return all non-archived spaces by default', () async {
        // Arrange
        final space1 = createTestSpace(id: 'space-1', name: 'Work');
        final space2 = createTestSpace(id: 'space-2', name: 'Personal');
        final space3 = createTestSpace(
          id: 'space-3',
          name: 'Archived',
          isArchived: true,
        );

        await repository.createSpace(space1);
        await repository.createSpace(space2);
        await repository.createSpace(space3);

        // Act
        final result = await repository.getSpaces();

        // Assert
        expect(result.length, equals(2));
        expect(result.every((space) => !space.isArchived), isTrue);
        expect(
          result.map((space) => space.id),
          containsAll(['space-1', 'space-2']),
        );
      });

      test('should return all spaces when includeArchived is true', () async {
        // Arrange
        final space1 = createTestSpace(id: 'space-1', name: 'Work');
        final space2 = createTestSpace(id: 'space-2', name: 'Personal');
        final space3 = createTestSpace(
          id: 'space-3',
          name: 'Archived',
          isArchived: true,
        );

        await repository.createSpace(space1);
        await repository.createSpace(space2);
        await repository.createSpace(space3);

        // Act
        final result = await repository.getSpaces(includeArchived: true);

        // Assert
        expect(result.length, equals(3));
        expect(
          result.map((space) => space.id),
          containsAll(['space-1', 'space-2', 'space-3']),
        );
      });

      test(
        'should return only archived spaces when all are archived',
        () async {
          // Arrange
          final space1 = createTestSpace(
            id: 'space-1',
            name: 'Archived 1',
            isArchived: true,
          );
          final space2 = createTestSpace(
            id: 'space-2',
            name: 'Archived 2',
            isArchived: true,
          );

          await repository.createSpace(space1);
          await repository.createSpace(space2);

          // Act
          final result = await repository.getSpaces();

          // Assert
          expect(result, isEmpty);

          // Act with includeArchived
          final resultWithArchived = await repository.getSpaces(
            includeArchived: true,
          );

          // Assert
          expect(resultWithArchived.length, equals(2));
        },
      );
    });

    group('getSpaceById', () {
      test('should return null when space does not exist', () async {
        // Act
        final result = await repository.getSpaceById('non-existent');

        // Assert
        expect(result, isNull);
      });

      test('should return correct space when it exists', () async {
        // Arrange
        final space1 = createTestSpace(id: 'space-1', name: 'Work');
        final space2 = createTestSpace(id: 'space-2', name: 'Personal');

        await repository.createSpace(space1);
        await repository.createSpace(space2);

        // Act
        final result = await repository.getSpaceById('space-2');

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals('space-2'));
        expect(result.name, equals('Personal'));
      });

      test('should return space with all properties intact', () async {
        // Arrange
        final space = createTestSpace(
          id: 'space-1',
          name: 'Work',
          icon: '💼',
          color: '#FF5733',
          itemCount: 5,
        );

        await repository.createSpace(space);

        // Act
        final result = await repository.getSpaceById('space-1');

        // Assert
        expect(result, isNotNull);
        expect(result!.name, equals('Work'));
        expect(result.icon, equals('💼'));
        expect(result.color, equals('#FF5733'));
        expect(result.itemCount, equals(5));
      });
    });

    group('updateSpace', () {
      test('should successfully update an existing space', () async {
        // Arrange
        final originalSpace = createTestSpace(
          id: 'space-1',
          name: 'Original Name',
          icon: '📁',
        );
        await repository.createSpace(originalSpace);

        final updatedSpace = originalSpace.copyWith(
          name: 'Updated Name',
          icon: '💼',
        );

        // Act
        final result = await repository.updateSpace(updatedSpace);

        // Assert
        expect(result.name, equals('Updated Name'));
        expect(result.icon, equals('💼'));
        expect(spacesBox.get('space-1')!.name, equals('Updated Name'));
      });

      test('should update the updatedAt timestamp', () async {
        // Arrange
        final originalSpace = createTestSpace(id: 'space-1');
        await repository.createSpace(originalSpace);

        // Wait a small amount to ensure timestamp difference
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final updatedSpace = originalSpace.copyWith(name: 'New Name');

        // Act
        final result = await repository.updateSpace(updatedSpace);

        // Assert
        expect(result.updatedAt.isAfter(originalSpace.updatedAt), isTrue);
      });

      test('should throw exception when updating non-existent space', () async {
        // Arrange
        final nonExistentSpace = createTestSpace(id: 'non-existent');

        // Act & Assert
        expect(() => repository.updateSpace(nonExistentSpace), throwsException);
      });

      test('should update space archive status', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1');
        await repository.createSpace(space);

        final archivedSpace = space.copyWith(isArchived: true);

        // Act
        final result = await repository.updateSpace(archivedSpace);

        // Assert
        expect(result.isArchived, isTrue);
        expect(spacesBox.get('space-1')!.isArchived, isTrue);
      });

      test('should update space color and icon', () async {
        // Arrange
        final space = createTestSpace(
          id: 'space-1',
          icon: '📁',
          color: '#FFFFFF',
        );
        await repository.createSpace(space);

        final updatedSpace = space.copyWith(icon: '💼', color: '#FF5733');

        // Act
        final result = await repository.updateSpace(updatedSpace);

        // Assert
        expect(result.icon, equals('💼'));
        expect(result.color, equals('#FF5733'));
      });
    });

    group('deleteSpace', () {
      test('should successfully delete an existing space', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1');
        await repository.createSpace(space);
        expect(spacesBox.length, equals(1));

        // Act
        await repository.deleteSpace('space-1');

        // Assert
        expect(spacesBox.length, equals(0));
        expect(spacesBox.get('space-1'), isNull);
      });

      test('should delete correct space from multiple spaces', () async {
        // Arrange
        final space1 = createTestSpace(id: 'space-1', name: 'Space 1');
        final space2 = createTestSpace(id: 'space-2', name: 'Space 2');
        final space3 = createTestSpace(id: 'space-3', name: 'Space 3');

        await repository.createSpace(space1);
        await repository.createSpace(space2);
        await repository.createSpace(space3);

        // Act
        await repository.deleteSpace('space-2');

        // Assert
        expect(spacesBox.length, equals(2));
        expect(spacesBox.get('space-1'), isNotNull);
        expect(spacesBox.get('space-2'), isNull);
        expect(spacesBox.get('space-3'), isNotNull);
      });

      test('should handle deletion of non-existent space gracefully', () async {
        // Act & Assert - should not throw
        await repository.deleteSpace('non-existent');
        expect(spacesBox.length, equals(0));
      });
    });

    group('incrementItemCount', () {
      test('should increment item count by 1', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1', itemCount: 5);
        await repository.createSpace(space);

        // Act
        await repository.incrementItemCount('space-1');

        // Assert
        final updatedSpace = spacesBox.get('space-1');
        expect(updatedSpace!.itemCount, equals(6));
      });

      test('should increment from 0', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1');
        await repository.createSpace(space);

        // Act
        await repository.incrementItemCount('space-1');

        // Assert
        final updatedSpace = spacesBox.get('space-1');
        expect(updatedSpace!.itemCount, equals(1));
      });

      test('should increment multiple times', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1');
        await repository.createSpace(space);

        // Act
        await repository.incrementItemCount('space-1');
        await repository.incrementItemCount('space-1');
        await repository.incrementItemCount('space-1');

        // Assert
        final updatedSpace = spacesBox.get('space-1');
        expect(updatedSpace!.itemCount, equals(3));
      });

      test('should throw exception when space does not exist', () async {
        // Act & Assert
        expect(
          () => repository.incrementItemCount('non-existent'),
          throwsException,
        );
      });

      test('should update the updatedAt timestamp', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1');
        await repository.createSpace(space);
        final originalUpdatedAt = space.updatedAt;

        // Wait a small amount to ensure timestamp difference
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // Act
        await repository.incrementItemCount('space-1');

        // Assert
        final updatedSpace = spacesBox.get('space-1');
        expect(updatedSpace!.updatedAt.isAfter(originalUpdatedAt), isTrue);
      });
    });

    group('decrementItemCount', () {
      test('should decrement item count by 1', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1', itemCount: 5);
        await repository.createSpace(space);

        // Act
        await repository.decrementItemCount('space-1');

        // Assert
        final updatedSpace = spacesBox.get('space-1');
        expect(updatedSpace!.itemCount, equals(4));
      });

      test('should not go below 0', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1');
        await repository.createSpace(space);

        // Act
        await repository.decrementItemCount('space-1');

        // Assert
        final updatedSpace = spacesBox.get('space-1');
        expect(updatedSpace!.itemCount, equals(0));
      });

      test('should decrement from 1 to 0', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1', itemCount: 1);
        await repository.createSpace(space);

        // Act
        await repository.decrementItemCount('space-1');

        // Assert
        final updatedSpace = spacesBox.get('space-1');
        expect(updatedSpace!.itemCount, equals(0));
      });

      test('should decrement multiple times', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1', itemCount: 5);
        await repository.createSpace(space);

        // Act
        await repository.decrementItemCount('space-1');
        await repository.decrementItemCount('space-1');
        await repository.decrementItemCount('space-1');

        // Assert
        final updatedSpace = spacesBox.get('space-1');
        expect(updatedSpace!.itemCount, equals(2));
      });

      test('should throw exception when space does not exist', () async {
        // Act & Assert
        expect(
          () => repository.decrementItemCount('non-existent'),
          throwsException,
        );
      });

      test('should update the updatedAt timestamp', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1', itemCount: 5);
        await repository.createSpace(space);
        final originalUpdatedAt = space.updatedAt;

        // Wait a small amount to ensure timestamp difference
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // Act
        await repository.decrementItemCount('space-1');

        // Assert
        final updatedSpace = spacesBox.get('space-1');
        expect(updatedSpace!.updatedAt.isAfter(originalUpdatedAt), isTrue);
      });
    });

    group('Edge Cases', () {
      test('should handle space with null icon', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1');

        // Act
        final result = await repository.createSpace(space);

        // Assert
        expect(result.icon, isNull);
        expect(spacesBox.get('space-1')!.icon, isNull);
      });

      test('should handle space with null color', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1');

        // Act
        final result = await repository.createSpace(space);

        // Assert
        expect(result.color, isNull);
        expect(spacesBox.get('space-1')!.color, isNull);
      });

      test('should handle space with very long name', () async {
        // Arrange
        final longName = 'A' * 1000;
        final space = createTestSpace(id: 'space-1', name: longName);

        // Act
        final result = await repository.createSpace(space);

        // Assert
        expect(result.name, equals(longName));
        expect(result.name.length, equals(1000));
      });

      test('should handle rapid increment and decrement operations', () async {
        // Arrange
        final space = createTestSpace(id: 'space-1', itemCount: 10);
        await repository.createSpace(space);

        // Act
        await repository.incrementItemCount('space-1');
        await repository.incrementItemCount('space-1');
        await repository.decrementItemCount('space-1');
        await repository.incrementItemCount('space-1');
        await repository.decrementItemCount('space-1');
        await repository.decrementItemCount('space-1');

        // Assert
        final updatedSpace = spacesBox.get('space-1');
        expect(updatedSpace!.itemCount, equals(10));
      });
    });
  });
}
