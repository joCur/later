import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:later_mobile/data/models/item_model.dart';
import 'package:later_mobile/data/models/space_model.dart';
import 'package:later_mobile/data/repositories/item_repository.dart';
import 'package:later_mobile/data/repositories/space_repository.dart';
import 'package:later_mobile/providers/items_provider.dart';
import 'package:later_mobile/providers/spaces_provider.dart';
import 'package:later_mobile/widgets/modals/quick_capture_modal.dart';
import 'package:later_mobile/widgets/screens/home_screen.dart';
import 'package:later_mobile/core/utils/item_type_detector.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Initialize Hive with in-memory path for testing
    Hive.init('./test_hive');

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
    // Close boxes if open
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

  group('Quick Capture Integration Tests', () {
    testWidgets('FAB tap opens QuickCaptureModal', (tester) async {
      // Create test space
      final spaceRepo = SpaceRepository();
      final testSpace = Space(
        id: 'test-space-1',
        name: 'Test Space',
        icon: '📝',
      );
      await spaceRepo.createSpace(testSpace);

      // Build app with providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => SpacesProvider(spaceRepo)..loadSpaces(),
            ),
            ChangeNotifierProvider(
              create: (_) => ItemsProvider(ItemRepository()),
            ),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Verify FAB is present
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify modal is shown
      expect(find.text('Quick Capture'), findsOneWidget);
      expect(find.byKey(const Key('capture_input')), findsOneWidget);
    });

    testWidgets('Keyboard shortcut (Ctrl+N) opens QuickCaptureModal',
        (tester) async {
      // Create test space
      final spaceRepo = SpaceRepository();
      final testSpace = Space(
        id: 'test-space-2',
        name: 'Test Space',
        icon: '📝',
      );
      await spaceRepo.createSpace(testSpace);

      // Build app with providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => SpacesProvider(spaceRepo)..loadSpaces(),
            ),
            ChangeNotifierProvider(
              create: (_) => ItemsProvider(ItemRepository()),
            ),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate Ctrl+N keyboard shortcut
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Verify modal is shown
      expect(find.text('Quick Capture'), findsOneWidget);
      expect(find.byKey(const Key('capture_input')), findsOneWidget);
    });

    testWidgets('Auto-save creates item after debounce', (tester) async {
      // Create test space
      final spaceRepo = SpaceRepository();
      final itemRepo = ItemRepository();
      final testSpace = Space(
        id: 'test-space-3',
        name: 'Test Space',
        icon: '📝',
      );
      await spaceRepo.createSpace(testSpace);

      final spacesProvider = SpacesProvider(spaceRepo);
      final itemsProvider = ItemsProvider(itemRepo);

      await spacesProvider.loadSpaces();

      // Build widget tree with modal
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: spacesProvider),
            ChangeNotifierProvider.value(value: itemsProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: QuickCaptureModal(
                onClose: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Type content into input
      await tester.enterText(
        find.byKey(const Key('capture_input')),
        'Buy groceries tomorrow',
      );
      await tester.pump();

      // Wait for debounce (500ms)
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify "Saved" indicator appears
      expect(find.text('Saved'), findsOneWidget);

      // Verify item was created
      await itemsProvider.loadItemsBySpace(testSpace.id);
      expect(itemsProvider.items.length, 1);
      expect(itemsProvider.items[0].title, 'Buy groceries tomorrow');
    });

    testWidgets('Type detection - Task with action verb', (tester) async {
      // Create test space
      final spaceRepo = SpaceRepository();
      final itemRepo = ItemRepository();
      final testSpace = Space(
        id: 'test-space-4',
        name: 'Test Space',
        icon: '📝',
      );
      await spaceRepo.createSpace(testSpace);

      final spacesProvider = SpacesProvider(spaceRepo);
      final itemsProvider = ItemsProvider(itemRepo);

      await spacesProvider.loadSpaces();

      // Build widget tree
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: spacesProvider),
            ChangeNotifierProvider.value(value: itemsProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: QuickCaptureModal(
                onClose: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Type task-like content
      const taskContent = 'Call dentist tomorrow';
      await tester.enterText(
        find.byKey(const Key('capture_input')),
        taskContent,
      );
      await tester.pump();

      // Wait for auto-save
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify item was created with correct type
      await itemsProvider.loadItemsBySpace(testSpace.id);
      expect(itemsProvider.items.length, 1);
      expect(itemsProvider.items[0].type, ItemType.task);
    });

    testWidgets('Type detection - Note with long text', (tester) async {
      // Create test space
      final spaceRepo = SpaceRepository();
      final itemRepo = ItemRepository();
      final testSpace = Space(
        id: 'test-space-5',
        name: 'Test Space',
        icon: '📝',
      );
      await spaceRepo.createSpace(testSpace);

      final spacesProvider = SpacesProvider(spaceRepo);
      final itemsProvider = ItemsProvider(itemRepo);

      await spacesProvider.loadSpaces();

      // Build widget tree
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: spacesProvider),
            ChangeNotifierProvider.value(value: itemsProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: QuickCaptureModal(
                onClose: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Type note-like content
      const noteContent =
          'This is a longer note with multiple sentences. It contains various thoughts and ideas that I want to capture for later reference.';
      await tester.enterText(
        find.byKey(const Key('capture_input')),
        noteContent,
      );
      await tester.pump();

      // Wait for auto-save
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify item was created with correct type
      await itemsProvider.loadItemsBySpace(testSpace.id);
      expect(itemsProvider.items.length, 1);
      expect(itemsProvider.items[0].type, ItemType.note);
    });

    testWidgets('Type detection - List with bullet points', (tester) async {
      // Create test space
      final spaceRepo = SpaceRepository();
      final itemRepo = ItemRepository();
      final testSpace = Space(
        id: 'test-space-6',
        name: 'Test Space',
        icon: '📝',
      );
      await spaceRepo.createSpace(testSpace);

      final spacesProvider = SpacesProvider(spaceRepo);
      final itemsProvider = ItemsProvider(itemRepo);

      await spacesProvider.loadSpaces();

      // Build widget tree
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: spacesProvider),
            ChangeNotifierProvider.value(value: itemsProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: QuickCaptureModal(
                onClose: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Type list-like content
      const listContent = '- Milk\n- Eggs\n- Bread\n- Butter';
      await tester.enterText(
        find.byKey(const Key('capture_input')),
        listContent,
      );
      await tester.pump();

      // Wait for auto-save
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify item was created with correct type
      await itemsProvider.loadItemsBySpace(testSpace.id);
      expect(itemsProvider.items.length, 1);
      expect(itemsProvider.items[0].type, ItemType.list);
    });

    testWidgets('Manual type selection overrides auto-detection',
        (tester) async {
      // Create test space
      final spaceRepo = SpaceRepository();
      final itemRepo = ItemRepository();
      final testSpace = Space(
        id: 'test-space-7',
        name: 'Test Space',
        icon: '📝',
      );
      await spaceRepo.createSpace(testSpace);

      final spacesProvider = SpacesProvider(spaceRepo);
      final itemsProvider = ItemsProvider(itemRepo);

      await spacesProvider.loadSpaces();

      // Build widget tree
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: spacesProvider),
            ChangeNotifierProvider.value(value: itemsProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: QuickCaptureModal(
                onClose: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Type task-like content
      const taskContent = 'Call dentist tomorrow';
      await tester.enterText(
        find.byKey(const Key('capture_input')),
        taskContent,
      );
      await tester.pump();

      // Open type selector and select Note
      await tester.tap(find.byKey(const Key('type_selector')));
      await tester.pumpAndSettle();

      // Tap on Note option
      await tester.tap(find.byKey(const Key('type_icon_note')));
      await tester.pumpAndSettle();

      // Wait for auto-save
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify item was created with manually selected type
      await itemsProvider.loadItemsBySpace(testSpace.id);
      expect(itemsProvider.items.length, 1);
      expect(itemsProvider.items[0].type, ItemType.note);
    });

    testWidgets('Cmd/Ctrl+Enter saves and closes modal', (tester) async {
      // Create test space
      final spaceRepo = SpaceRepository();
      final itemRepo = ItemRepository();
      final testSpace = Space(
        id: 'test-space-8',
        name: 'Test Space',
        icon: '📝',
      );
      await spaceRepo.createSpace(testSpace);

      final spacesProvider = SpacesProvider(spaceRepo);
      final itemsProvider = ItemsProvider(itemRepo);

      await spacesProvider.loadSpaces();

      bool modalClosed = false;

      // Build widget tree
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: spacesProvider),
            ChangeNotifierProvider.value(value: itemsProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: QuickCaptureModal(
                onClose: () {
                  modalClosed = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Type content
      await tester.enterText(
        find.byKey(const Key('capture_input')),
        'Test item',
      );
      await tester.pump();

      // Press Ctrl+Enter
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Verify modal close callback was called
      expect(modalClosed, true);

      // Verify item was created
      await itemsProvider.loadItemsBySpace(testSpace.id);
      expect(itemsProvider.items.length, 1);
      expect(itemsProvider.items[0].title, 'Test item');
    });

    testWidgets('Items persist across app restarts', (tester) async {
      // Create test space
      final spaceRepo = SpaceRepository();
      final itemRepo = ItemRepository();
      final testSpace = Space(
        id: 'test-space-9',
        name: 'Test Space',
        icon: '📝',
      );
      await spaceRepo.createSpace(testSpace);

      final spacesProvider = SpacesProvider(spaceRepo);
      final itemsProvider = ItemsProvider(itemRepo);

      await spacesProvider.loadSpaces();

      // Build widget tree
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: spacesProvider),
            ChangeNotifierProvider.value(value: itemsProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: QuickCaptureModal(
                onClose: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Create an item
      await tester.enterText(
        find.byKey(const Key('capture_input')),
        'Persistent item',
      );
      await tester.pump();

      // Wait for auto-save
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Create a new provider instance (simulating app restart)
      final newItemsProvider = ItemsProvider(ItemRepository());
      await newItemsProvider.loadItemsBySpace(testSpace.id);

      // Verify item persisted
      expect(newItemsProvider.items.length, 1);
      expect(newItemsProvider.items[0].title, 'Persistent item');
    });

    testWidgets('Close button closes modal', (tester) async {
      // Create test space
      final spaceRepo = SpaceRepository();
      final testSpace = Space(
        id: 'test-space-10',
        name: 'Test Space',
        icon: '📝',
      );
      await spaceRepo.createSpace(testSpace);

      final spacesProvider = SpacesProvider(spaceRepo);
      final itemsProvider = ItemsProvider(ItemRepository());

      await spacesProvider.loadSpaces();

      bool modalClosed = false;

      // Build widget tree
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: spacesProvider),
            ChangeNotifierProvider.value(value: itemsProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: QuickCaptureModal(
                onClose: () {
                  modalClosed = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap close button
      await tester.tap(find.byKey(const Key('close_button')));
      await tester.pumpAndSettle();

      // Verify modal close callback was called
      expect(modalClosed, true);
    });

    testWidgets('Escape key closes modal', (tester) async {
      // Create test space
      final spaceRepo = SpaceRepository();
      final testSpace = Space(
        id: 'test-space-11',
        name: 'Test Space',
        icon: '📝',
      );
      await spaceRepo.createSpace(testSpace);

      final spacesProvider = SpacesProvider(spaceRepo);
      final itemsProvider = ItemsProvider(ItemRepository());

      await spacesProvider.loadSpaces();

      bool modalClosed = false;

      // Build widget tree
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: spacesProvider),
            ChangeNotifierProvider.value(value: itemsProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: QuickCaptureModal(
                onClose: () {
                  modalClosed = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Press Escape key
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Verify modal close callback was called
      expect(modalClosed, true);
    });

    testWidgets('Empty input does not create item', (tester) async {
      // Create test space
      final spaceRepo = SpaceRepository();
      final itemRepo = ItemRepository();
      final testSpace = Space(
        id: 'test-space-12',
        name: 'Test Space',
        icon: '📝',
      );
      await spaceRepo.createSpace(testSpace);

      final spacesProvider = SpacesProvider(spaceRepo);
      final itemsProvider = ItemsProvider(itemRepo);

      await spacesProvider.loadSpaces();

      // Build widget tree
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: spacesProvider),
            ChangeNotifierProvider.value(value: itemsProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: QuickCaptureModal(
                onClose: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Type and then clear content
      await tester.enterText(
        find.byKey(const Key('capture_input')),
        '   ', // Only whitespace
      );
      await tester.pump();

      // Wait for debounce
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify no item was created
      await itemsProvider.loadItemsBySpace(testSpace.id);
      expect(itemsProvider.items.length, 0);
    });
  });

  group('ItemTypeDetector Integration', () {
    test('detectType - Task examples', () {
      expect(ItemTypeDetector.detectType('Call doctor tomorrow'),
          ItemType.task);
      expect(ItemTypeDetector.detectType('Buy groceries'), ItemType.task);
      expect(ItemTypeDetector.detectType('[] Fix the bug'), ItemType.task);
      expect(
          ItemTypeDetector.detectType('Complete urgent report'), ItemType.task);
    });

    test('detectType - Note examples', () {
      expect(
        ItemTypeDetector.detectType(
            'This is a longer note with multiple sentences. It contains various thoughts.'),
        ItemType.note,
      );
      expect(
        ItemTypeDetector.detectType('Random thoughts about the project'),
        ItemType.note,
      );
    });

    test('detectType - List examples', () {
      expect(
        ItemTypeDetector.detectType('- Milk\n- Eggs\n- Bread'),
        ItemType.list,
      );
      expect(
        ItemTypeDetector.detectType('1. First item\n2. Second item\n3. Third'),
        ItemType.list,
      );
    });
  });
}
