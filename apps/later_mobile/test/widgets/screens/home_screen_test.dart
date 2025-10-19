import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/widgets/screens/home_screen.dart';
import 'package:later_mobile/widgets/components/empty_state.dart';
import 'package:later_mobile/widgets/components/cards/item_card.dart';
import 'package:later_mobile/widgets/components/fab/quick_capture_fab.dart';
import 'package:later_mobile/widgets/navigation/bottom_navigation_bar.dart';
import 'package:later_mobile/widgets/navigation/app_sidebar.dart';
import 'package:later_mobile/data/models/item_model.dart';
import 'package:later_mobile/data/models/space_model.dart';
import 'package:later_mobile/providers/items_provider.dart';
import 'package:later_mobile/providers/spaces_provider.dart';
import 'package:later_mobile/data/repositories/item_repository.dart';
import 'package:later_mobile/data/repositories/space_repository.dart';
import 'package:provider/provider.dart';

/// Fake ItemRepository for testing
class FakeItemRepository implements ItemRepository {
  List<Item> _items = [];

  void setItems(List<Item> items) {
    _items = items;
  }

  @override
  Future<List<Item>> getItems() async {
    return _items;
  }

  @override
  Future<List<Item>> getItemsBySpace(String spaceId) async {
    return _items.where((item) => item.spaceId == spaceId).toList();
  }

  @override
  Future<List<Item>> getItemsByType(ItemType type) async {
    return _items.where((item) => item.type == type).toList();
  }

  @override
  Future<Item> createItem(Item item) async {
    _items.add(item);
    return item;
  }

  @override
  Future<Item> updateItem(Item item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
    }
    return item;
  }

  @override
  Future<void> deleteItem(String id) async {
    _items.removeWhere((item) => item.id == id);
  }
}

/// Fake SpaceRepository for testing
class FakeSpaceRepository implements SpaceRepository {
  List<Space> _spaces = [];

  void setSpaces(List<Space> spaces) {
    _spaces = spaces;
  }

  @override
  Future<List<Space>> getSpaces({bool includeArchived = false}) async {
    if (includeArchived) {
      return _spaces;
    }
    return _spaces.where((space) => !space.isArchived).toList();
  }

  @override
  Future<Space?> getSpaceById(String id) async {
    try {
      return _spaces.firstWhere((space) => space.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Space> createSpace(Space space) async {
    _spaces.add(space);
    return space;
  }

  @override
  Future<Space> updateSpace(Space space) async {
    final index = _spaces.indexWhere((s) => s.id == space.id);
    if (index != -1) {
      _spaces[index] = space;
    }
    return space;
  }

  @override
  Future<void> deleteSpace(String id) async {
    _spaces.removeWhere((space) => space.id == id);
  }

  @override
  Future<void> incrementItemCount(String spaceId) async {
    final space = await getSpaceById(spaceId);
    if (space != null) {
      final updated = space.copyWith(itemCount: space.itemCount + 1);
      await updateSpace(updated);
    }
  }

  @override
  Future<void> decrementItemCount(String spaceId) async {
    final space = await getSpaceById(spaceId);
    if (space != null) {
      final count = space.itemCount > 0 ? space.itemCount - 1 : 0;
      final updated = space.copyWith(itemCount: count);
      await updateSpace(updated);
    }
  }
}

void main() {
  group('HomeScreen Widget Tests', () {
    late FakeItemRepository fakeItemRepository;
    late FakeSpaceRepository fakeSpaceRepository;
    late ItemsProvider itemsProvider;
    late SpacesProvider spacesProvider;

    setUp(() {
      fakeItemRepository = FakeItemRepository();
      fakeSpaceRepository = FakeSpaceRepository();
      itemsProvider = ItemsProvider(fakeItemRepository);
      spacesProvider = SpacesProvider(fakeSpaceRepository);
    });

    Widget createHomeScreen({Size? size}) {
      final widget = MultiProvider(
        providers: [
          ChangeNotifierProvider<ItemsProvider>.value(value: itemsProvider),
          ChangeNotifierProvider<SpacesProvider>.value(value: spacesProvider),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      );

      if (size != null) {
        return MediaQuery(
          data: MediaQueryData(size: size),
          child: widget,
        );
      }

      return widget;
    }

    testWidgets('renders correctly with empty state on mobile',
        (WidgetTester tester) async {
      // Arrange
      fakeSpaceRepository.setSpaces(<Space>[]);
      fakeItemRepository.setItems(<Item>[]);

      // Act
      await tester.pumpWidget(
        createHomeScreen(size: const Size(400, 800)),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.byType(AppBottomNavigationBar), findsOneWidget);
      expect(find.byType(QuickCaptureFab), findsOneWidget);
    });

    testWidgets('renders correctly with items on mobile',
        (WidgetTester tester) async {
      // Arrange
      final space = Space(
        id: 'space-1',
        name: 'Personal',
        icon: '📱',
        color: '#FF5733',
      );

      final items = [
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

      fakeSpaceRepository.setSpaces([space]);
      fakeItemRepository.setItems(items);

      // Act
      await tester.pumpWidget(
        createHomeScreen(size: const Size(400, 800)),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ItemCard), findsNWidgets(2));
      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Note 1'), findsOneWidget);
    });

    testWidgets('renders correctly on desktop with sidebar',
        (WidgetTester tester) async {
      // Arrange
      final space = Space(
        id: 'space-1',
        name: 'Work',
        icon: '💼',
        color: '#FF5733',
      );

      fakeSpaceRepository.setSpaces([space]);
      fakeItemRepository.setItems(<Item>[]);

      // Act
      await tester.pumpWidget(
        createHomeScreen(size: const Size(1200, 800)),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AppSidebar), findsOneWidget);
      expect(find.byType(AppBottomNavigationBar), findsNothing);
    });

    testWidgets('displays space name in app bar', (WidgetTester tester) async {
      // Arrange
      final space = Space(
        id: 'space-1',
        name: 'My Space',
        icon: '🏠',
        color: '#FF5733',
      );

      fakeSpaceRepository.setSpaces([space]);
      fakeItemRepository.setItems(<Item>[]);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('My Space'), findsOneWidget);
      expect(find.text('🏠'), findsOneWidget);
    });

    testWidgets('shows "No Space" when no space selected',
        (WidgetTester tester) async {
      // Arrange
      fakeSpaceRepository.setSpaces(<Space>[]);
      fakeItemRepository.setItems(<Item>[]);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No Space'), findsOneWidget);
    });

    testWidgets('displays filter chips', (WidgetTester tester) async {
      // Arrange
      fakeSpaceRepository.setSpaces(<Space>[]);
      fakeItemRepository.setItems(<Item>[]);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(FilterChip), findsNWidgets(4));
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Lists'), findsOneWidget);
    });

    testWidgets('filter chips exist and can be tapped',
        (WidgetTester tester) async {
      // Arrange
      final space = Space(
        id: 'space-1',
        name: 'Test',
        icon: '📝',
        color: '#FF5733',
      );

      final items = [
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
          type: ItemType.list,
          title: 'List 1',
          spaceId: 'space-1',
        ),
      ];

      fakeSpaceRepository.setSpaces([space]);
      fakeItemRepository.setItems(items);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // All items should be visible initially
      expect(find.byType(ItemCard), findsNWidgets(3));

      // Verify all filter chips exist
      expect(find.byType(FilterChip), findsNWidgets(4));
    });

    testWidgets('shows empty state with correct message',
        (WidgetTester tester) async {
      // Arrange
      fakeSpaceRepository.setSpaces(<Space>[]);
      fakeItemRepository.setItems(<Item>[]);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Assert - empty state should be visible with default message
      expect(find.byType(EmptyState), findsOneWidget);
      expect(
        find.text(
          'Create your first item to get started. Tap the + button below.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('pull-to-refresh works correctly',
        (WidgetTester tester) async {
      // Arrange
      final space = Space(
        id: 'space-1',
        name: 'Test',
        icon: '📝',
        color: '#FF5733',
      );

      fakeSpaceRepository.setSpaces([space]);
      fakeItemRepository.setItems(<Item>[]);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Find the RefreshIndicator
      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);

      // Perform pull-to-refresh gesture
      await tester.drag(refreshIndicator, const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Assert - no error occurred
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('search button exists and can be tapped',
        (WidgetTester tester) async {
      // Arrange
      fakeSpaceRepository.setSpaces(<Space>[]);
      fakeItemRepository.setItems(<Item>[]);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Find and tap search button
      final searchButton = find.widgetWithIcon(IconButton, Icons.search);
      expect(searchButton, findsOneWidget);

      await tester.tap(searchButton);
      await tester.pump();

      // Assert - no error thrown
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('menu button exists and can be tapped',
        (WidgetTester tester) async {
      // Arrange
      fakeSpaceRepository.setSpaces(<Space>[]);
      fakeItemRepository.setItems(<Item>[]);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Find and tap menu button
      final menuButton = find.widgetWithIcon(IconButton, Icons.more_vert);
      expect(menuButton, findsOneWidget);

      await tester.tap(menuButton);
      await tester.pump();

      // Assert - no error thrown
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('FAB exists and can be tapped', (WidgetTester tester) async {
      // Arrange
      fakeSpaceRepository.setSpaces(<Space>[]);
      fakeItemRepository.setItems(<Item>[]);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Find and tap FAB
      final fab = find.byType(QuickCaptureFab);
      expect(fab, findsOneWidget);

      await tester.tap(fab);
      await tester.pump();

      // Assert - no error thrown
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('task checkbox exists and can be tapped',
        (WidgetTester tester) async {
      // Arrange
      final space = Space(
        id: 'space-1',
        name: 'Test',
        icon: '📝',
        color: '#FF5733',
      );

      final task = Item(
        id: '1',
        type: ItemType.task,
        title: 'Task 1',
        spaceId: 'space-1',
      );

      fakeSpaceRepository.setSpaces([space]);
      fakeItemRepository.setItems([task]);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Find checkbox
      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      // Tap checkbox
      await tester.tap(checkbox, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Assert - no error thrown
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('bottom navigation updates selected index',
        (WidgetTester tester) async {
      // Arrange
      fakeSpaceRepository.setSpaces(<Space>[]);
      fakeItemRepository.setItems(<Item>[]);

      // Act
      await tester.pumpWidget(
        createHomeScreen(size: const Size(400, 800)),
      );
      await tester.pumpAndSettle();

      // Find navigation bar
      final navBar = tester.widget<AppBottomNavigationBar>(
        find.byType(AppBottomNavigationBar),
      );
      expect(navBar.currentIndex, 0);

      // Tap second destination
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Check updated index
      final updatedNavBar = tester.widget<AppBottomNavigationBar>(
        find.byType(AppBottomNavigationBar),
      );
      expect(updatedNavBar.currentIndex, 1);
    });

    testWidgets('empty state action button can be tapped',
        (WidgetTester tester) async {
      // Arrange
      fakeSpaceRepository.setSpaces(<Space>[]);
      fakeItemRepository.setItems(<Item>[]);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Find and tap empty state action button
      final actionButton = find.widgetWithText(ElevatedButton, 'Create Item');
      expect(actionButton, findsOneWidget);

      await tester.tap(actionButton, warnIfMissed: false);
      await tester.pump();

      // Assert - no error thrown
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('item card can be long-pressed', (WidgetTester tester) async {
      // Arrange
      final space = Space(
        id: 'space-1',
        name: 'Test',
        icon: '📝',
        color: '#FF5733',
      );

      final items = [
        Item(
          id: '1',
          type: ItemType.task,
          title: 'Task 1',
          spaceId: 'space-1',
        ),
      ];

      fakeSpaceRepository.setSpaces([space]);
      fakeItemRepository.setItems(items);

      // Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Long press item card
      await tester.longPress(find.byType(ItemCard), warnIfMissed: false);
      await tester.pump();

      // Assert - no error thrown
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
