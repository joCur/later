import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:later_mobile/data/models/item_model.dart';
import 'package:later_mobile/data/models/space_model.dart';
import 'package:later_mobile/data/repositories/item_repository.dart';
import 'package:later_mobile/data/repositories/space_repository.dart';
import 'package:later_mobile/providers/items_provider.dart';
import 'package:later_mobile/providers/spaces_provider.dart';
import 'package:later_mobile/widgets/modals/quick_capture_modal.dart';
import 'package:provider/provider.dart';

void main() {
  late ItemRepository itemRepository;
  late SpaceRepository spaceRepository;
  late ItemsProvider itemsProvider;
  late SpacesProvider spacesProvider;

  setUp(() async {
    // Initialize Hive in test directory
    const tempDir = '.dart_tool/test/hive';
    Hive.init(tempDir);

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ItemTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ItemAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SpaceAdapter());
    }

    // Open boxes
    await Hive.openBox<Item>('items');
    await Hive.openBox<Space>('spaces');

    itemRepository = ItemRepository();
    spaceRepository = SpaceRepository();
    itemsProvider = ItemsProvider(itemRepository);
    spacesProvider = SpacesProvider(spaceRepository);

    // Create a default space
    final defaultSpace = Space(
      id: 'space-1',
      name: 'Personal',
      icon: '🏠',
    );
    await spaceRepository.createSpace(defaultSpace);
    await spacesProvider.loadSpaces();
  });

  tearDown(() async {
    final itemsBox = Hive.box<Item>('items');
    final spacesBox = Hive.box<Space>('spaces');

    await itemsBox.clear();
    await spacesBox.clear();
    await itemsBox.close();
    await spacesBox.close();
    await Hive.deleteBoxFromDisk('items');
    await Hive.deleteBoxFromDisk('spaces');
  });

  Widget createTestWidget({
    bool isMobile = true,
    VoidCallback? onClose,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ItemsProvider>.value(value: itemsProvider),
        ChangeNotifierProvider<SpacesProvider>.value(value: spacesProvider),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(
              size: Size(isMobile ? 375 : 1024, 800),
            ),
            child: QuickCaptureModal(
              onClose: onClose ?? () {},
            ),
          ),
        ),
      ),
    );
  }

  group('QuickCaptureModal - Rendering', () {
    testWidgets('renders all required components on mobile',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Mobile-specific: Drag handle
      expect(find.byKey(const Key('drag_handle')), findsOneWidget);

      // Header
      expect(find.text('Quick Capture'), findsOneWidget);
      expect(find.byKey(const Key('close_button')), findsOneWidget);

      // Input field
      expect(find.byKey(const Key('capture_input')), findsOneWidget);
      expect(find.text('What\'s on your mind?'), findsOneWidget);

      // Toolbar buttons
      expect(find.byKey(const Key('voice_button')), findsOneWidget);
      expect(find.byKey(const Key('image_button')), findsOneWidget);
      expect(find.byKey(const Key('type_selector')), findsOneWidget);
      expect(find.byKey(const Key('space_selector')), findsOneWidget);

      // Auto-save indicator
      expect(find.byKey(const Key('autosave_indicator')), findsOneWidget);
    });

    testWidgets('renders correctly on desktop without drag handle',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(isMobile: false));
      await tester.pumpAndSettle();

      // Desktop: No drag handle
      expect(find.byKey(const Key('drag_handle')), findsNothing);

      // Other components should still be present
      expect(find.text('Quick Capture'), findsOneWidget);
      expect(find.byKey(const Key('capture_input')), findsOneWidget);
    });

    testWidgets('has correct modal width on desktop',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(isMobile: false));
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.byKey(const Key('modal_container')),
      );

      expect(container.constraints?.maxWidth, equals(600.0));
    });

    testWidgets('has correct modal width on tablet',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ItemsProvider>.value(value: itemsProvider),
            ChangeNotifierProvider<SpacesProvider>.value(
                value: spacesProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: MediaQuery(
                data: const MediaQueryData(size: Size(800, 600)),
                child: QuickCaptureModal(onClose: () {}),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.byKey(const Key('modal_container')),
      );

      // Tablet: 90% width, max 600px
      // 800 * 0.9 = 720, but max is 600
      expect(container.constraints?.maxWidth, equals(600.0));
    });
  });

  group('QuickCaptureModal - Input Interaction', () {
    testWidgets('input field auto-focuses on mount',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(
        find.byKey(const Key('capture_input')),
      );

      expect(textField.autofocus, isTrue);
    });

    testWidgets('input field accepts text input',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('capture_input')),
        'Buy groceries',
      );
      await tester.pump();

      expect(find.text('Buy groceries'), findsOneWidget);
    });

    testWidgets('input field has correct min and max lines',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(
        find.byKey(const Key('capture_input')),
      );

      // Based on design specs: min 120px (~3 lines), max 400px (~10 lines)
      expect(textField.minLines, equals(3));
      expect(textField.maxLines, equals(10));
    });
  });

  group('QuickCaptureModal - Type Selector', () {
    testWidgets('shows all type options when clicked',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('type_selector')));
      await tester.pumpAndSettle();

      // Should show all 4 type options
      expect(find.text('Auto'), findsOneWidget);
      expect(find.text('Task'), findsOneWidget);
      expect(find.text('Note'), findsOneWidget);
      expect(find.text('List'), findsOneWidget);
    });

    testWidgets('selects Task type when clicked',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('type_selector')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Task'));
      await tester.pumpAndSettle();

      // Should show Task as selected
      expect(find.text('Task'), findsOneWidget);
    });

    testWidgets('type selector shows correct icons',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('type_selector')));
      await tester.pumpAndSettle();

      // Verify icons are present (by key)
      expect(find.byKey(const Key('type_icon_auto')), findsOneWidget);
      expect(find.byKey(const Key('type_icon_task')), findsOneWidget);
      expect(find.byKey(const Key('type_icon_note')), findsOneWidget);
      expect(find.byKey(const Key('type_icon_list')), findsOneWidget);
    });
  });

  group('QuickCaptureModal - Space Selector', () {
    testWidgets('shows current space', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Personal'), findsOneWidget);
    });

    testWidgets('shows all spaces when clicked',
        (WidgetTester tester) async {
      // Add another space
      await spaceRepository.createSpace(
        Space(id: 'space-2', name: 'Work', icon: '💼'),
      );
      await spacesProvider.loadSpaces();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('space_selector')));
      await tester.pumpAndSettle();

      expect(find.text('Personal'), findsWidgets);
      expect(find.text('Work'), findsOneWidget);
    });

    testWidgets('switches space when selected',
        (WidgetTester tester) async {
      // Add another space
      await spaceRepository.createSpace(
        Space(id: 'space-2', name: 'Work', icon: '💼'),
      );
      await spacesProvider.loadSpaces();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('space_selector')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();

      // Verify space changed
      expect(spacesProvider.currentSpace?.name, equals('Work'));
    });
  });

  group('QuickCaptureModal - Auto-save', () {
    testWidgets('shows "Saving..." indicator when typing',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('capture_input')),
        'Buy groceries',
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Should show saving indicator
      expect(find.text('Saving...'), findsOneWidget);
    });

    testWidgets('shows "Saved" indicator after debounce',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('capture_input')),
        'Buy groceries',
      );

      // Wait for debounce (500ms) + save time
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Should show saved indicator
      expect(find.text('Saved'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('creates item after auto-save debounce',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('capture_input')),
        'Buy groceries',
      );

      // Wait for debounce
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Verify item was created
      await itemsProvider.loadItems();
      expect(itemsProvider.items.length, equals(1));
      expect(itemsProvider.items.first.title, equals('Buy groceries'));
    });

    testWidgets('updates existing item when text changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // First save
      await tester.enterText(
        find.byKey(const Key('capture_input')),
        'Buy groceries',
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Update text
      await tester.enterText(
        find.byKey(const Key('capture_input')),
        'Buy groceries and milk',
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Should only have one item (updated)
      await itemsProvider.loadItems();
      expect(itemsProvider.items.length, equals(1));
      expect(itemsProvider.items.first.title, equals('Buy groceries and milk'));
    });
  });

  group('QuickCaptureModal - Keyboard Shortcuts', () {
    testWidgets('closes on Escape key', (WidgetTester tester) async {
      bool closeCalled = false;
      await tester.pumpWidget(
        createTestWidget(onClose: () => closeCalled = true),
      );
      await tester.pumpAndSettle();

      // Simulate Escape key
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(closeCalled, isTrue);
    });

    testWidgets('saves and closes on Cmd+Enter (macOS)',
        (WidgetTester tester) async {
      bool closeCalled = false;
      await tester.pumpWidget(
        createTestWidget(onClose: () => closeCalled = true),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('capture_input')),
        'Buy groceries',
      );
      await tester.pump();

      // Simulate Cmd+Enter
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      // Should save and close
      expect(closeCalled, isTrue);
      await itemsProvider.loadItems();
      expect(itemsProvider.items.length, equals(1));
    });

    testWidgets('saves and closes on Ctrl+Enter (Windows/Linux)',
        (WidgetTester tester) async {
      bool closeCalled = false;
      await tester.pumpWidget(
        createTestWidget(onClose: () => closeCalled = true),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('capture_input')),
        'Buy groceries',
      );
      await tester.pump();

      // Simulate Ctrl+Enter
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Should save and close
      expect(closeCalled, isTrue);
      await itemsProvider.loadItems();
      expect(itemsProvider.items.length, equals(1));
    });
  });

  group('QuickCaptureModal - Dismissal', () {
    testWidgets('closes when close button is tapped',
        (WidgetTester tester) async {
      bool closeCalled = false;
      await tester.pumpWidget(
        createTestWidget(onClose: () => closeCalled = true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('close_button')));
      await tester.pumpAndSettle();

      expect(closeCalled, isTrue);
    });

    testWidgets('closes when backdrop is tapped on desktop',
        (WidgetTester tester) async {
      bool closeCalled = false;
      await tester.pumpWidget(
        createTestWidget(isMobile: false, onClose: () => closeCalled = true),
      );
      await tester.pumpAndSettle();

      // Tap outside modal (backdrop)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(closeCalled, isTrue);
    });

    testWidgets('closes on drag down gesture on mobile',
        (WidgetTester tester) async {
      bool closeCalled = false;
      await tester.pumpWidget(
        createTestWidget(onClose: () => closeCalled = true),
      );
      await tester.pumpAndSettle();

      // Find the drag handle
      final dragHandle = find.byKey(const Key('drag_handle'));

      // Drag down
      await tester.drag(dragHandle, const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(closeCalled, isTrue);
    });
  });

  group('QuickCaptureModal - Animations', () {
    testWidgets('has entry animation on desktop',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(isMobile: false));

      // Before animation
      await tester.pump();

      // During animation
      await tester.pump(const Duration(milliseconds: 150));

      // Animation should be in progress (scale/fade)
      final scaleTransition = tester.widget<ScaleTransition>(
        find.byType(ScaleTransition),
      );
      expect(scaleTransition, isNotNull);

      // Complete animation
      await tester.pumpAndSettle();
    });

    testWidgets('has slide-up entry animation on mobile',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Before animation
      await tester.pump();

      // During animation
      await tester.pump(const Duration(milliseconds: 150));

      // Animation should be in progress (slide)
      final slideTransition = tester.widget<SlideTransition>(
        find.byType(SlideTransition),
      );
      expect(slideTransition, isNotNull);

      // Complete animation
      await tester.pumpAndSettle();
    });

    testWidgets('button has press animation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final closeButton = find.byKey(const Key('close_button'));

      // Press down
      final gesture = await tester.startGesture(
        tester.getCenter(closeButton),
      );
      await tester.pump(const Duration(milliseconds: 50));

      // Release
      await gesture.up();
      await tester.pumpAndSettle();

      // Animation should have completed
      expect(tester.takeException(), isNull);
    });
  });

  group('QuickCaptureModal - Accessibility', () {
    testWidgets('has semantic labels', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel('Quick Capture'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Close'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Voice input'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Add image'),
        findsOneWidget,
      );
    });

    testWidgets('supports keyboard navigation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tab through focusable elements
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Should move focus
      expect(tester.takeException(), isNull);
    });

    testWidgets('buttons have minimum touch target size',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final closeButton = tester.getSize(
        find.byKey(const Key('close_button')),
      );
      final voiceButton = tester.getSize(
        find.byKey(const Key('voice_button')),
      );
      final imageButton = tester.getSize(
        find.byKey(const Key('image_button')),
      );

      // Minimum 44x44dp touch target
      expect(closeButton.width, greaterThanOrEqualTo(44.0));
      expect(closeButton.height, greaterThanOrEqualTo(44.0));
      expect(voiceButton.width, greaterThanOrEqualTo(44.0));
      expect(voiceButton.height, greaterThanOrEqualTo(44.0));
      expect(imageButton.width, greaterThanOrEqualTo(44.0));
      expect(imageButton.height, greaterThanOrEqualTo(44.0));
    });
  });

  group('QuickCaptureModal - Type Detection', () {
    testWidgets('detects task type for text starting with checkbox',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('capture_input')),
        '[] Buy groceries',
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Verify item type was detected as task
      await itemsProvider.loadItems();
      expect(itemsProvider.items.first.type, equals(ItemType.task));
    });

    testWidgets('detects list type for text with bullet points',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('capture_input')),
        '- Item 1\n- Item 2',
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Verify item type was detected as list
      await itemsProvider.loadItems();
      expect(itemsProvider.items.first.type, equals(ItemType.list));
    });

    testWidgets('defaults to note type for plain text',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('capture_input')),
        'This is a note',
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Verify item type was detected as note
      await itemsProvider.loadItems();
      expect(itemsProvider.items.first.type, equals(ItemType.note));
    });

    testWidgets('uses manually selected type over auto-detection',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Select Task type manually
      await tester.tap(find.byKey(const Key('type_selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Task'));
      await tester.pumpAndSettle();

      // Enter text that would normally be detected as note
      await tester.enterText(
        find.byKey(const Key('capture_input')),
        'This is a note',
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Should use manually selected type
      await itemsProvider.loadItems();
      expect(itemsProvider.items.first.type, equals(ItemType.task));
    });
  });
}
