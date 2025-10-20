import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:later_mobile/data/models/item_model.dart';
import 'package:later_mobile/data/models/space_model.dart';
import 'package:later_mobile/data/repositories/item_repository.dart';
import 'package:later_mobile/data/repositories/space_repository.dart';
import 'package:later_mobile/providers/items_provider.dart';
import 'package:later_mobile/providers/spaces_provider.dart';
import 'package:later_mobile/widgets/screens/home_screen.dart';

/// Integration tests for core user flows
/// Tests complete end-to-end scenarios from user perspective
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Initialize Hive with in-memory path for testing
    Hive.init('./test_hive_flows');

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ItemTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ItemAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SpaceAdapter());
    }
  });

  setUp(() async {
    // Close and clear boxes if open
    if (Hive.isBoxOpen('items')) {
      await Hive.box<Item>('items').clear();
    } else {
      await Hive.openBox<Item>('items');
    }

    if (Hive.isBoxOpen('spaces')) {
      await Hive.box<Space>('spaces').clear();
    } else {
      await Hive.openBox<Space>('spaces');
    }
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('Item Management Flow', () {
    testWidgets('Complete item lifecycle: Create → View → Edit → Complete → Delete',
        (tester) async {
      // Setup: Create a test space
      final spaceRepo = SpaceRepository();
      final itemRepo = ItemRepository();
      final testSpace = Space(
        id: 'test-space-items',
        name: 'Test Space',
        icon: '📝',
      );
      await spaceRepo.createSpace(testSpace);

      final spacesProvider = SpacesProvider(spaceRepo);
      final itemsProvider = ItemsProvider(itemRepo);

      await spacesProvider.loadSpaces();

      // Build app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: spacesProvider),
            ChangeNotifierProvider.value(value: itemsProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // STEP 1: Create Item
      // Open quick capture
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter task
      await tester.enterText(
        find.byKey(const Key('capture_input')),
        'Write integration tests',
      );
      await tester.pump();

      // Wait for auto-save
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify item created
      await itemsProvider.loadItemsBySpace(testSpace.id);
      expect(itemsProvider.items.length, 1);
      final createdItem = itemsProvider.items.first;
      expect(createdItem.title, 'Write integration tests');
      expect(createdItem.type, ItemType.task);
      expect(createdItem.isCompleted, isFalse);

      // Close modal
      await tester.tap(find.byKey(const Key('close_button')));
      await tester.pumpAndSettle();

      // STEP 2: View Item
      // Verify item appears in list
      expect(find.text('Write integration tests'), findsOneWidget);

      // STEP 3: Edit Item
      // Tap on item to edit
      await tester.tap(find.text('Write integration tests'));
      await tester.pumpAndSettle();

      // Edit the title
      await tester.enterText(
        find.byKey(const Key('item_title_field')),
        'Write comprehensive integration tests',
      );
      await tester.pump();

      // Save changes
      await tester.tap(find.byKey(const Key('save_item_button')));
      await tester.pumpAndSettle();

      // Verify item updated
      await itemsProvider.loadItemsBySpace(testSpace.id);
      expect(itemsProvider.items.first.title, 'Write comprehensive integration tests');

      // STEP 4: Complete Task
      // Toggle completion
      await itemsProvider.toggleCompletion(createdItem.id);
      await tester.pump();

      // Verify task completed
      await itemsProvider.loadItemsBySpace(testSpace.id);
      expect(itemsProvider.items.first.isCompleted, isTrue);

      // STEP 5: Delete Item
      // Delete the item
      await itemsProvider.deleteItem(createdItem.id);
      await tester.pump();

      // Verify item deleted
      await itemsProvider.loadItemsBySpace(testSpace.id);
      expect(itemsProvider.items.length, 0);
    });

    testWidgets('Complete task → Undo → Re-complete flow', (tester) async {
      // Setup
      final spaceRepo = SpaceRepository();
      final itemRepo = ItemRepository();
      final testSpace = Space(
        id: 'test-space-toggle',
        name: 'Test Space',
        icon: '✅',
      );
      await spaceRepo.createSpace(testSpace);

      final spacesProvider = SpacesProvider(spaceRepo);
      final itemsProvider = ItemsProvider(itemRepo);

      await spacesProvider.loadSpaces();

      // Create a task
      final task = Item(
        id: 'task-1',
        type: ItemType.task,
        title: 'Complete this task',
        spaceId: testSpace.id,
      );
      await itemsProvider.addItem(task);

      // Build app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: spacesProvider),
            ChangeNotifierProvider.value(value: itemsProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify task is not completed
      await itemsProvider.loadItemsBySpace(testSpace.id);
      expect(itemsProvider.items.first.isCompleted, isFalse);

      // Complete task
      await itemsProvider.toggleCompletion(task.id);
      await tester.pump();

      await itemsProvider.loadItemsBySpace(testSpace.id);
      expect(itemsProvider.items.first.isCompleted, isTrue);

      // Undo completion
      await itemsProvider.toggleCompletion(task.id);
      await tester.pump();

      await itemsProvider.loadItemsBySpace(testSpace.id);
      expect(itemsProvider.items.first.isCompleted, isFalse);

      // Re-complete
      await itemsProvider.toggleCompletion(task.id);
      await tester.pump();

      await itemsProvider.loadItemsBySpace(testSpace.id);
      expect(itemsProvider.items.first.isCompleted, isTrue);
    });
  });

  group('Space Management Flow', () {
    testWidgets('Create space → Switch space → Archive space', (tester) async {
      // Setup
      final spaceRepo = SpaceRepository();
      final itemRepo = ItemRepository();

      final spacesProvider = SpacesProvider(spaceRepo);
      final itemsProvider = ItemsProvider(itemRepo);

      // Build app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: spacesProvider),
            ChangeNotifierProvider.value(value: itemsProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // STEP 1: Create Space
      final newSpace1 = Space(
        id: 'space-1',
        name: 'Work',
        icon: '💼',
        color: '#FF5733',
      );
      await spacesProvider.addSpace(newSpace1);
      await tester.pumpAndSettle();

      // Verify space created and set as current
      expect(spacesProvider.spaces.length, 1);
      expect(spacesProvider.currentSpace?.id, 'space-1');
      expect(spacesProvider.currentSpace?.name, 'Work');

      // Create another space
      final newSpace2 = Space(
        id: 'space-2',
        name: 'Personal',
        icon: '🏠',
        color: '#33FF57',
      );
      await spacesProvider.addSpace(newSpace2);
      await tester.pumpAndSettle();

      // Verify second space created and set as current
      expect(spacesProvider.spaces.length, 2);
      expect(spacesProvider.currentSpace?.id, 'space-2');

      // STEP 2: Switch Space
      await spacesProvider.switchSpace('space-1');
      await tester.pumpAndSettle();

      // Verify space switched
      expect(spacesProvider.currentSpace?.id, 'space-1');
      expect(spacesProvider.currentSpace?.name, 'Work');

      // STEP 3: Archive Space
      // First switch to another space (can't archive current space)
      await spacesProvider.switchSpace('space-2');
      await tester.pumpAndSettle();

      // Archive space-1
      final archivedSpace = newSpace1.copyWith(isArchived: true);
      await spacesProvider.updateSpace(archivedSpace);
      await tester.pumpAndSettle();

      // Reload spaces (without archived)
      await spacesProvider.loadSpaces(includeArchived: false);

      // Verify archived space not in active list
      expect(spacesProvider.spaces.length, 1);
      expect(spacesProvider.spaces.any((s) => s.id == 'space-1'), isFalse);

      // Verify archived space still in database when including archived
      await spacesProvider.loadSpaces(includeArchived: true);
      expect(spacesProvider.spaces.length, 2);
      final archivedFromDb =
          spacesProvider.spaces.firstWhere((s) => s.id == 'space-1');
      expect(archivedFromDb.isArchived, isTrue);
    });

    testWidgets('Create space → Edit space name and icon', (tester) async {
      // Setup
      final spaceRepo = SpaceRepository();
      final itemRepo = ItemRepository();

      final spacesProvider = SpacesProvider(spaceRepo);
      final itemsProvider = ItemsProvider(itemRepo);

      // Build app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: spacesProvider),
            ChangeNotifierProvider.value(value: itemsProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Create space
      final originalSpace = Space(
        id: 'space-edit',
        name: 'Original Name',
        icon: '📝',
        color: '#FF5733',
      );
      await spacesProvider.addSpace(originalSpace);
      await tester.pumpAndSettle();

      // Verify space created
      expect(spacesProvider.currentSpace?.name, 'Original Name');
      expect(spacesProvider.currentSpace?.icon, '📝');

      // Edit space
      final updatedSpace = originalSpace.copyWith(
        name: 'Updated Name',
        icon: '✨',
      );
      await spacesProvider.updateSpace(updatedSpace);
      await tester.pumpAndSettle();

      // Verify space updated
      expect(spacesProvider.currentSpace?.name, 'Updated Name');
      expect(spacesProvider.currentSpace?.icon, '✨');
      expect(spacesProvider.currentSpace?.color, '#FF5733'); // Color unchanged
    });
  });

  group('Cross-Feature Flows', () {
    testWidgets('Create item in one space → Switch space → Verify isolation',
        (tester) async {
      // Setup
      final spaceRepo = SpaceRepository();
      final itemRepo = ItemRepository();

      // Create two spaces
      final space1 = Space(
        id: 'space-isolation-1',
        name: 'Space 1',
        icon: '1️⃣',
      );
      final space2 = Space(
        id: 'space-isolation-2',
        name: 'Space 2',
        icon: '2️⃣',
      );
      await spaceRepo.createSpace(space1);
      await spaceRepo.createSpace(space2);

      final spacesProvider = SpacesProvider(spaceRepo);
      final itemsProvider = ItemsProvider(itemRepo);

      await spacesProvider.loadSpaces();

      // Build app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: spacesProvider),
            ChangeNotifierProvider.value(value: itemsProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Create item in space 1
      final item1 = Item(
        id: 'item-1',
        type: ItemType.task,
        title: 'Item in Space 1',
        spaceId: space1.id,
      );
      await itemsProvider.addItem(item1);

      // Verify item in space 1
      await itemsProvider.loadItemsBySpace(space1.id);
      expect(itemsProvider.items.length, 1);
      expect(itemsProvider.items.first.title, 'Item in Space 1');

      // Switch to space 2
      await spacesProvider.switchSpace(space2.id);
      await itemsProvider.loadItemsBySpace(space2.id);
      await tester.pumpAndSettle();

      // Verify space 2 is empty
      expect(itemsProvider.items.length, 0);

      // Create item in space 2
      final item2 = Item(
        id: 'item-2',
        type: ItemType.note,
        title: 'Item in Space 2',
        spaceId: space2.id,
      );
      await itemsProvider.addItem(item2);

      // Verify item in space 2
      await itemsProvider.loadItemsBySpace(space2.id);
      expect(itemsProvider.items.length, 1);
      expect(itemsProvider.items.first.title, 'Item in Space 2');

      // Switch back to space 1
      await spacesProvider.switchSpace(space1.id);
      await itemsProvider.loadItemsBySpace(space1.id);
      await tester.pumpAndSettle();

      // Verify space 1 still has only its item
      expect(itemsProvider.items.length, 1);
      expect(itemsProvider.items.first.title, 'Item in Space 1');
    });

    testWidgets('Multiple rapid item creations', (tester) async {
      // Setup
      final spaceRepo = SpaceRepository();
      final itemRepo = ItemRepository();
      final testSpace = Space(
        id: 'space-rapid',
        name: 'Rapid Test Space',
        icon: '⚡',
      );
      await spaceRepo.createSpace(testSpace);

      final spacesProvider = SpacesProvider(spaceRepo);
      final itemsProvider = ItemsProvider(itemRepo);

      await spacesProvider.loadSpaces();

      // Build app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: spacesProvider),
            ChangeNotifierProvider.value(value: itemsProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Create multiple items rapidly
      final items = <Item>[];
      for (int i = 0; i < 10; i++) {
        final item = Item(
          id: 'rapid-item-$i',
          type: ItemType.task,
          title: 'Task $i',
          spaceId: testSpace.id,
        );
        items.add(item);
        await itemsProvider.addItem(item);
      }

      // Verify all items created
      await itemsProvider.loadItemsBySpace(testSpace.id);
      expect(itemsProvider.items.length, 10);

      // Verify items in order
      for (int i = 0; i < 10; i++) {
        final item = itemsProvider.items.firstWhere((item) => item.id == 'rapid-item-$i');
        expect(item.title, 'Task $i');
      }
    });

    testWidgets('Error recovery: Failed item creation', (tester) async {
      // Setup
      final spaceRepo = SpaceRepository();
      final itemRepo = ItemRepository();

      final spacesProvider = SpacesProvider(spaceRepo);
      final itemsProvider = ItemsProvider(itemRepo);

      // Build app (no space created - should cause error)
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: spacesProvider),
            ChangeNotifierProvider.value(value: itemsProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to create item without a space
      final item = Item(
        id: 'orphan-item',
        type: ItemType.task,
        title: 'Orphan Task',
        spaceId: 'non-existent-space',
      );

      await itemsProvider.addItem(item);
      await tester.pump();

      // Item should be added despite no validation in this basic implementation
      // In a real app, you'd validate space exists before adding item
      expect(itemsProvider.items.length, 1);

      // Now create the space
      final testSpace = Space(
        id: 'recovery-space',
        name: 'Recovery Space',
        icon: '🔄',
      );
      await spacesProvider.addSpace(testSpace);
      await tester.pumpAndSettle();

      // Create proper item
      final properItem = Item(
        id: 'proper-item',
        type: ItemType.task,
        title: 'Proper Task',
        spaceId: testSpace.id,
      );
      await itemsProvider.addItem(properItem);

      // Verify items can be loaded by space
      await itemsProvider.loadItemsBySpace(testSpace.id);
      expect(itemsProvider.items.any((i) => i.id == 'proper-item'), isTrue);
    });
  });

  group('Data Persistence', () {
    test('Items persist across provider instances', () async {
      // Create space and item
      final spaceRepo = SpaceRepository();
      final itemRepo = ItemRepository();

      final testSpace = Space(
        id: 'persist-space',
        name: 'Persist Space',
        icon: '💾',
      );
      await spaceRepo.createSpace(testSpace);

      final spacesProvider1 = SpacesProvider(spaceRepo);
      final itemsProvider1 = ItemsProvider(itemRepo);

      await spacesProvider1.loadSpaces();

      final item = Item(
        id: 'persist-item',
        type: ItemType.task,
        title: 'Persistent Task',
        spaceId: testSpace.id,
      );
      await itemsProvider1.addItem(item);

      // Create new provider instances (simulating app restart)
      final spacesProvider2 = SpacesProvider(SpaceRepository());
      final itemsProvider2 = ItemsProvider(ItemRepository());

      await spacesProvider2.loadSpaces();
      await itemsProvider2.loadItemsBySpace(testSpace.id);

      // Verify data persisted
      expect(spacesProvider2.spaces.length, 1);
      expect(spacesProvider2.spaces.first.name, 'Persist Space');
      expect(itemsProvider2.items.length, 1);
      expect(itemsProvider2.items.first.title, 'Persistent Task');
    });

    test('Spaces persist across provider instances', () async {
      // Create multiple spaces
      final spaceRepo = SpaceRepository();
      final spacesProvider1 = SpacesProvider(spaceRepo);

      final spaces = [
        Space(id: 'persist-1', name: 'Space 1', icon: '1️⃣'),
        Space(id: 'persist-2', name: 'Space 2', icon: '2️⃣'),
        Space(id: 'persist-3', name: 'Space 3', icon: '3️⃣'),
      ];

      for (final space in spaces) {
        await spacesProvider1.addSpace(space);
      }

      // Create new provider instance
      final spacesProvider2 = SpacesProvider(SpaceRepository());
      await spacesProvider2.loadSpaces();

      // Verify all spaces persisted
      expect(spacesProvider2.spaces.length, 3);
      expect(spacesProvider2.spaces.map((s) => s.name).toList(),
          containsAll(['Space 1', 'Space 2', 'Space 3']));
    });
  });
}
