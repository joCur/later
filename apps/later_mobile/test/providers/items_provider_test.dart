import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/models/item_model.dart';
import 'package:later_mobile/data/repositories/item_repository.dart';
import 'package:later_mobile/providers/items_provider.dart';

/// Mock implementation of ItemRepository for testing
class MockItemRepository extends ItemRepository {
  List<Item> mockItems = [];
  bool shouldThrowError = false;
  String? errorMessage;

  // Track method calls for verification
  int createItemCallCount = 0;
  int updateItemCallCount = 0;
  int deleteItemCallCount = 0;

  @override
  Future<List<Item>> getItems() async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to get items');
    }
    return List.from(mockItems);
  }

  @override
  Future<List<Item>> getItemsBySpace(String spaceId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to get items by space');
    }
    return mockItems.where((item) => item.spaceId == spaceId).toList();
  }

  @override
  Future<List<Item>> getItemsByType(ItemType type) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to get items by type');
    }
    return mockItems.where((item) => item.type == type).toList();
  }

  @override
  Future<Item> createItem(Item item) async {
    createItemCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to create item');
    }
    mockItems.add(item);
    return item;
  }

  @override
  Future<Item> updateItem(Item item) async {
    updateItemCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to update item');
    }
    final index = mockItems.indexWhere((i) => i.id == item.id);
    if (index == -1) {
      throw Exception('Item with id ${item.id} does not exist');
    }
    mockItems[index] = item;
    return item;
  }

  @override
  Future<void> deleteItem(String id) async {
    deleteItemCallCount++;
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to delete item');
    }
    mockItems.removeWhere((item) => item.id == id);
  }

  /// Helper method to reset the mock state
  void reset() {
    mockItems.clear();
    shouldThrowError = false;
    errorMessage = null;
    createItemCallCount = 0;
    updateItemCallCount = 0;
    deleteItemCallCount = 0;
  }
}

void main() {
  late MockItemRepository mockRepository;
  late ItemsProvider provider;

  setUp(() {
    mockRepository = MockItemRepository();
    provider = ItemsProvider(mockRepository);
  });

  tearDown(() {
    mockRepository.reset();
  });

  group('ItemsProvider - Initial State', () {
    test('should have empty items list initially', () {
      expect(provider.items, isEmpty);
    });

    test('should not be loading initially', () {
      expect(provider.isLoading, isFalse);
    });

    test('should have no error initially', () {
      expect(provider.error, isNull);
    });
  });

  group('ItemsProvider - loadItems', () {
    test('should load items successfully', () async {
      // Arrange
      final testItems = [
        Item(
          id: '1',
          type: ItemType.task,
          title: 'Task 1',
          spaceId: 'space-1',
        ),
        Item(
          id: '2',
          type: ItemType.note,
          title: 'Note 1',
          spaceId: 'space-1',
        ),
      ];
      mockRepository.mockItems = testItems;

      // Act
      await provider.loadItems();

      // Assert
      expect(provider.items, hasLength(2));
      expect(provider.items[0].title, 'Task 1');
      expect(provider.items[1].title, 'Note 1');
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('should set loading state during loadItems', () async {
      // Arrange
      bool wasLoadingDuringCall = false;
      provider.addListener(() {
        if (provider.isLoading) {
          wasLoadingDuringCall = true;
        }
      });

      // Act
      await provider.loadItems();

      // Assert
      expect(wasLoadingDuringCall, isTrue);
      expect(provider.isLoading, isFalse);
    });

    test('should handle error when loading items fails', () async {
      // Arrange
      mockRepository.shouldThrowError = true;
      mockRepository.errorMessage = 'Network error';

      // Act
      await provider.loadItems();

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.error, contains('Network error'));
      expect(provider.isLoading, isFalse);
      expect(provider.items, isEmpty);
    });

    test('should notify listeners on successful load', () async {
      // Arrange
      mockRepository.mockItems = [
        Item(
          id: '1',
          type: ItemType.task,
          title: 'Task 1',
          spaceId: 'space-1',
        ),
      ];
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      // Act
      await provider.loadItems();

      // Assert - should notify at least twice (loading start, loading complete)
      expect(notifyCount, greaterThanOrEqualTo(2));
    });
  });

  group('ItemsProvider - loadItemsBySpace', () {
    test('should load items filtered by space', () async {
      // Arrange
      final testItems = [
        Item(
          id: '1',
          type: ItemType.task,
          title: 'Task 1',
          spaceId: 'space-1',
        ),
        Item(
          id: '2',
          type: ItemType.task,
          title: 'Task 2',
          spaceId: 'space-2',
        ),
        Item(
          id: '3',
          type: ItemType.note,
          title: 'Note 1',
          spaceId: 'space-1',
        ),
      ];
      mockRepository.mockItems = testItems;

      // Act
      await provider.loadItemsBySpace('space-1');

      // Assert
      expect(provider.items, hasLength(2));
      expect(provider.items.every((item) => item.spaceId == 'space-1'), isTrue);
    });

    test('should handle error when loading items by space fails', () async {
      // Arrange
      mockRepository.shouldThrowError = true;

      // Act
      await provider.loadItemsBySpace('space-1');

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.isLoading, isFalse);
    });

    test('should return empty list when no items match space', () async {
      // Arrange
      mockRepository.mockItems = [
        Item(
          id: '1',
          type: ItemType.task,
          title: 'Task 1',
          spaceId: 'space-1',
        ),
      ];

      // Act
      await provider.loadItemsBySpace('space-999');

      // Assert
      expect(provider.items, isEmpty);
      expect(provider.error, isNull);
    });
  });

  group('ItemsProvider - loadItemsByType', () {
    test('should load items filtered by type', () async {
      // Arrange
      final testItems = [
        Item(
          id: '1',
          type: ItemType.task,
          title: 'Task 1',
          spaceId: 'space-1',
        ),
        Item(
          id: '2',
          type: ItemType.note,
          title: 'Note 1',
          spaceId: 'space-1',
        ),
        Item(
          id: '3',
          type: ItemType.task,
          title: 'Task 2',
          spaceId: 'space-1',
        ),
      ];
      mockRepository.mockItems = testItems;

      // Act
      await provider.loadItemsByType(ItemType.task);

      // Assert
      expect(provider.items, hasLength(2));
      expect(provider.items.every((item) => item.type == ItemType.task), isTrue);
    });

    test('should handle error when loading items by type fails', () async {
      // Arrange
      mockRepository.shouldThrowError = true;

      // Act
      await provider.loadItemsByType(ItemType.task);

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.isLoading, isFalse);
    });
  });

  group('ItemsProvider - addItem', () {
    test('should add item successfully', () async {
      // Arrange
      final newItem = Item(
        id: '1',
        type: ItemType.task,
        title: 'New Task',
        spaceId: 'space-1',
      );

      // Act
      await provider.addItem(newItem);

      // Assert
      expect(provider.items, contains(newItem));
      expect(mockRepository.createItemCallCount, 1);
      expect(provider.error, isNull);
    });

    test('should handle error when adding item fails', () async {
      // Arrange
      mockRepository.shouldThrowError = true;
      final newItem = Item(
        id: '1',
        type: ItemType.task,
        title: 'New Task',
        spaceId: 'space-1',
      );

      // Act
      await provider.addItem(newItem);

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.items, isEmpty);
    });

    test('should notify listeners when adding item', () async {
      // Arrange
      final newItem = Item(
        id: '1',
        type: ItemType.task,
        title: 'New Task',
        spaceId: 'space-1',
      );
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      // Act
      await provider.addItem(newItem);

      // Assert
      expect(notifyCount, greaterThan(0));
    });
  });

  group('ItemsProvider - updateItem', () {
    test('should update item successfully', () async {
      // Arrange
      final originalItem = Item(
        id: '1',
        type: ItemType.task,
        title: 'Original Task',
        spaceId: 'space-1',
      );
      mockRepository.mockItems = [originalItem];
      await provider.loadItems();

      final updatedItem = originalItem.copyWith(title: 'Updated Task');

      // Act
      await provider.updateItem(updatedItem);

      // Assert
      expect(provider.items.first.title, 'Updated Task');
      expect(mockRepository.updateItemCallCount, 1);
      expect(provider.error, isNull);
    });

    test('should handle error when updating item fails', () async {
      // Arrange
      final item = Item(
        id: '1',
        type: ItemType.task,
        title: 'Task',
        spaceId: 'space-1',
      );
      mockRepository.mockItems = [item];
      await provider.loadItems();

      mockRepository.shouldThrowError = true;
      final updatedItem = item.copyWith(title: 'Updated Task');

      // Act
      await provider.updateItem(updatedItem);

      // Assert
      expect(provider.error, isNotNull);
    });

    test('should handle updating non-existent item', () async {
      // Arrange
      final item = Item(
        id: '999',
        type: ItemType.task,
        title: 'Task',
        spaceId: 'space-1',
      );

      // Act
      await provider.updateItem(item);

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.error, contains('does not exist'));
    });
  });

  group('ItemsProvider - deleteItem', () {
    test('should delete item successfully', () async {
      // Arrange
      final item = Item(
        id: '1',
        type: ItemType.task,
        title: 'Task',
        spaceId: 'space-1',
      );
      mockRepository.mockItems = [item];
      await provider.loadItems();

      // Act
      await provider.deleteItem('1');

      // Assert
      expect(provider.items, isEmpty);
      expect(mockRepository.deleteItemCallCount, 1);
      expect(provider.error, isNull);
    });

    test('should handle error when deleting item fails', () async {
      // Arrange
      final item = Item(
        id: '1',
        type: ItemType.task,
        title: 'Task',
        spaceId: 'space-1',
      );
      mockRepository.mockItems = [item];
      await provider.loadItems();

      mockRepository.shouldThrowError = true;

      // Act
      await provider.deleteItem('1');

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.items, hasLength(1)); // Item should still be there
    });

    test('should notify listeners when deleting item', () async {
      // Arrange
      final item = Item(
        id: '1',
        type: ItemType.task,
        title: 'Task',
        spaceId: 'space-1',
      );
      mockRepository.mockItems = [item];
      await provider.loadItems();

      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      // Act
      await provider.deleteItem('1');

      // Assert
      expect(notifyCount, greaterThan(0));
    });
  });

  group('ItemsProvider - toggleCompletion', () {
    test('should toggle task completion status', () async {
      // Arrange
      final task = Item(
        id: '1',
        type: ItemType.task,
        title: 'Task',
        spaceId: 'space-1',
      );
      mockRepository.mockItems = [task];
      await provider.loadItems();

      // Act
      await provider.toggleCompletion('1');

      // Assert
      expect(provider.items.first.isCompleted, isTrue);
      expect(mockRepository.updateItemCallCount, 1);
    });

    test('should toggle from completed to incomplete', () async {
      // Arrange
      final task = Item(
        id: '1',
        type: ItemType.task,
        title: 'Task',
        spaceId: 'space-1',
        isCompleted: true,
      );
      mockRepository.mockItems = [task];
      await provider.loadItems();

      // Act
      await provider.toggleCompletion('1');

      // Assert
      expect(provider.items.first.isCompleted, isFalse);
    });

    test('should handle error when toggling completion fails', () async {
      // Arrange
      final task = Item(
        id: '1',
        type: ItemType.task,
        title: 'Task',
        spaceId: 'space-1',
      );
      mockRepository.mockItems = [task];
      await provider.loadItems();

      mockRepository.shouldThrowError = true;

      // Act
      await provider.toggleCompletion('1');

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.items.first.isCompleted, isFalse); // Should remain unchanged
    });

    test('should handle toggling non-existent item', () async {
      // Act
      await provider.toggleCompletion('999');

      // Assert
      expect(provider.error, isNotNull);
    });
  });

  group('ItemsProvider - clearError', () {
    test('should clear error message', () async {
      // Arrange
      mockRepository.shouldThrowError = true;
      await provider.loadItems();
      expect(provider.error, isNotNull);

      // Act
      provider.clearError();

      // Assert
      expect(provider.error, isNull);
    });

    test('should notify listeners when clearing error', () {
      // Arrange
      mockRepository.shouldThrowError = true;
      provider.loadItems();

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
