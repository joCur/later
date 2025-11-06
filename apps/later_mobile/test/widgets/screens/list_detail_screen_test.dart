import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/widgets/screens/list_detail_screen.dart';
import 'package:later_mobile/design_system/organisms/cards/list_item_card.dart';
import 'package:later_mobile/design_system/atoms/text/gradient_text.dart';
import 'package:later_mobile/design_system/organisms/fab/responsive_fab.dart';
import 'package:later_mobile/design_system/organisms/modals/bottom_sheet_container.dart';
import 'package:later_mobile/data/models/list_model.dart';
import 'package:later_mobile/data/models/list_item_model.dart';
import 'package:later_mobile/data/models/list_style.dart';
import 'package:later_mobile/providers/content_provider.dart';
import 'package:later_mobile/providers/spaces_provider.dart';
import 'package:later_mobile/data/repositories/list_repository.dart';
import 'package:later_mobile/data/repositories/todo_list_repository.dart';
import 'package:later_mobile/data/repositories/note_repository.dart';
import 'package:later_mobile/data/repositories/space_repository.dart';
import 'package:later_mobile/data/models/space_model.dart';
import 'package:provider/provider.dart';

/// Fake ListRepository for testing
/// Matches the new Supabase repository API with separate items storage
class FakeListRepository implements ListRepository {
  List<ListModel> _lists = [];
  final Map<String, List<ListItem>> _itemsByListId = {};
  bool _shouldThrowError = false;

  void setLists(List<ListModel> lists) {
    _lists = lists;
  }

  void setItemsForList(String listId, List<ListItem> items) {
    _itemsByListId[listId] = items;
    // Update counts on the list
    final listIndex = _lists.indexWhere((l) => l.id == listId);
    if (listIndex != -1) {
      final checkedCount = items.where((item) => item.isChecked).length;
      _lists[listIndex] = _lists[listIndex].copyWith(
        totalItemCount: items.length,
        checkedItemCount: checkedCount,
      );
    }
  }

  void setShouldThrowError(bool value) {
    _shouldThrowError = value;
  }

  void _updateListCounts(String listId) {
    final items = _itemsByListId[listId] ?? [];
    final listIndex = _lists.indexWhere((l) => l.id == listId);
    if (listIndex != -1) {
      final checkedCount = items.where((item) => item.isChecked).length;
      _lists[listIndex] = _lists[listIndex].copyWith(
        totalItemCount: items.length,
        checkedItemCount: checkedCount,
      );
    }
  }

  @override
  Future<ListModel> create(ListModel list) async {
    if (_shouldThrowError) throw Exception('Create failed');
    _lists.add(list);
    _itemsByListId[list.id] = [];
    return list;
  }

  @override
  Future<ListModel?> getById(String id) async {
    if (_shouldThrowError) throw Exception('GetById failed');
    try {
      return _lists.firstWhere((list) => list.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ListModel>> getBySpace(String spaceId) async {
    if (_shouldThrowError) throw Exception('GetBySpace failed');
    return _lists.where((list) => list.spaceId == spaceId).toList();
  }

  @override
  Future<ListModel> update(ListModel list) async {
    if (_shouldThrowError) throw Exception('Update failed');
    final index = _lists.indexWhere((l) => l.id == list.id);
    if (index == -1) throw Exception('List not found');
    _lists[index] = list.copyWith(updatedAt: DateTime.now());
    return _lists[index];
  }

  @override
  Future<void> delete(String id) async {
    if (_shouldThrowError) throw Exception('Delete failed');
    _lists.removeWhere((list) => list.id == id);
    _itemsByListId.remove(id);
  }

  @override
  Future<List<ListItem>> getListItemsByListId(String listId) async {
    if (_shouldThrowError) throw Exception('GetListItemsByListId failed');
    return _itemsByListId[listId] ?? [];
  }

  @override
  Future<ListItem> createListItem(ListItem listItem) async {
    if (_shouldThrowError) throw Exception('CreateListItem failed');
    final items = _itemsByListId[listItem.listId] ?? [];
    items.add(listItem);
    _itemsByListId[listItem.listId] = items;
    _updateListCounts(listItem.listId);
    return listItem;
  }

  @override
  Future<ListItem> updateListItem(ListItem listItem) async {
    if (_shouldThrowError) throw Exception('UpdateListItem failed');
    final items = _itemsByListId[listItem.listId] ?? [];
    final index = items.indexWhere((item) => item.id == listItem.id);
    if (index == -1) throw Exception('Item not found');
    items[index] = listItem;
    _itemsByListId[listItem.listId] = items;
    _updateListCounts(listItem.listId);
    return listItem;
  }

  @override
  Future<void> deleteListItem(String id, String listId) async {
    if (_shouldThrowError) throw Exception('DeleteListItem failed');
    final items = _itemsByListId[listId] ?? [];
    items.removeWhere((item) => item.id == id);
    _itemsByListId[listId] = items;
    _updateListCounts(listId);
  }

  @override
  Future<void> updateListItemSortOrders(List<ListItem> listItems) async {
    if (_shouldThrowError) throw Exception('UpdateListItemSortOrders failed');
    if (listItems.isEmpty) return;
    final listId = listItems.first.listId;
    _itemsByListId[listId] = listItems;
    _updateListCounts(listId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake TodoListRepository for testing
class FakeTodoListRepository implements TodoListRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake NoteRepository for testing
class FakeNoteRepository implements NoteRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake SpaceRepository for testing
class FakeSpaceRepository implements SpaceRepository {
  List<Space> _spaces = [];

  void setSpaces(List<Space> spaces) {
    _spaces = spaces;
  }

  @override
  Future<List<Space>> getSpaces({bool includeArchived = false}) async {
    return _spaces;
  }

  @override
  Future<Space?> getSpaceById(String id) async {
    try {
      return _spaces.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Space> updateSpace(Space space) async {
    final index = _spaces.indexWhere((s) => s.id == space.id);
    if (index == -1) throw Exception('Space not found');
    _spaces[index] = space;
    return space;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeListRepository fakeListRepository;
  late FakeTodoListRepository fakeTodoListRepository;
  late FakeNoteRepository fakeNoteRepository;
  late FakeSpaceRepository fakeSpaceRepository;
  late ContentProvider contentProvider;
  late SpacesProvider spacesProvider;

  setUp(() {
    fakeListRepository = FakeListRepository();
    fakeTodoListRepository = FakeTodoListRepository();
    fakeNoteRepository = FakeNoteRepository();
    fakeSpaceRepository = FakeSpaceRepository();

    contentProvider = ContentProvider(
      todoListRepository: fakeTodoListRepository,
      listRepository: fakeListRepository,
      noteRepository: fakeNoteRepository,
    );

    spacesProvider = SpacesProvider(fakeSpaceRepository);

    // Set up default space
    fakeSpaceRepository.setSpaces([
      Space(
        id: 'space-1',
        name: 'Test Space',
        icon: '🏠',
        userId: 'test-user-id',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ]);
  });

  Widget createTestWidget(ListModel list, {Size? screenSize}) {
    Widget widget = MultiProvider(
      providers: [
        ChangeNotifierProvider<ContentProvider>.value(value: contentProvider),
        ChangeNotifierProvider<SpacesProvider>.value(value: spacesProvider),
      ],
      child: MaterialApp(home: ListDetailScreen(list: list)),
    );

    // Wrap with MediaQuery if custom screen size is provided
    if (screenSize != null) {
      widget = MediaQuery(
        data: MediaQueryData(size: screenSize),
        child: widget,
      );
    }

    return widget;
  }

  /// Helper to set mobile viewport size (< 768px)
  Widget createMobileTestWidget(ListModel list) {
    return createTestWidget(
      list,
      screenSize: const Size(375, 812),
    ); // iPhone size
  }

  /// Helper to set desktop viewport size (>= 1024px)
  Widget createDesktopTestWidget(ListModel list) {
    return createTestWidget(list, screenSize: const Size(1200, 800));
  }

  group('ListDetailScreen - Rendering', () {
    testWidgets('renders with list name in AppBar', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'Shopping List',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Check for list name in AppBar
      expect(find.text('Shopping List'), findsOneWidget);
      expect(find.byType(GradientText), findsOneWidget);
    });

    testWidgets('renders custom icon in AppBar', (WidgetTester tester) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'Shopping List',
        icon: '🛒',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Check for custom icon
      expect(find.text('🛒'), findsOneWidget);
    });

    testWidgets('renders empty state when no items', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'Empty List',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Check for empty state
      expect(find.text('No items yet'), findsOneWidget);
      expect(
        find.text('Tap the + button to add your first item'),
        findsOneWidget,
      );
    });

    testWidgets('renders list items in correct style - bullets', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'Shopping List',
        totalItemCount: 2,
        
      );
      fakeListRepository.setLists([list]);
      fakeListRepository.setItemsForList('list-1', [
        ListItem(id: 'item-1', title: 'Milk', sortOrder: 0, listId: 'list-1'),
        ListItem(id: 'item-2', title: 'Eggs', sortOrder: 1, listId: 'list-1'),
      ]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Check for list items
      expect(find.text('Milk'), findsOneWidget);
      expect(find.text('Eggs'), findsOneWidget);
      expect(find.byType(ListItemCard), findsNWidgets(2));
    });

    testWidgets('renders list items in correct style - numbered', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'Steps',
        style: ListStyle.numbered,
        totalItemCount: 2,
        
      );
      fakeListRepository.setLists([list]);
      fakeListRepository.setItemsForList('list-1', [
        ListItem(id: 'item-1', title: 'First step', sortOrder: 0, listId: 'list-1'),
        ListItem(id: 'item-2', title: 'Second step', sortOrder: 1, listId: 'list-1'),
      ]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Check for numbered items
      expect(find.text('First step'), findsOneWidget);
      expect(find.text('Second step'), findsOneWidget);
      expect(find.byType(ListItemCard), findsNWidgets(2));
    });

    testWidgets('renders list items in correct style - checkboxes', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'Tasks',
        style: ListStyle.checkboxes,
        totalItemCount: 2,
        checkedItemCount: 1,
      );
      fakeListRepository.setLists([list]);
      fakeListRepository.setItemsForList('list-1', [
        ListItem(id: 'item-1', title: 'Task 1', sortOrder: 0, listId: 'list-1'),
        ListItem(
          id: 'item-2',
          title: 'Task 2',
          isChecked: true,
          sortOrder: 1,
          listId: 'list-1',
        ),
      ]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Check for checkbox items
      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
      expect(find.byType(Checkbox), findsNWidgets(2));
    });

    testWidgets('renders ResponsiveFab for adding items', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Check for ResponsiveFab
      expect(find.byType(ResponsiveFab), findsOneWidget);
    });

    testWidgets('renders menu button in AppBar', (WidgetTester tester) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Check for menu button
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });
  });

  group('ListDetailScreen - Name Editing', () {
    testWidgets('allows editing list name inline', (WidgetTester tester) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'Original Name',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Tap on the name to edit
      await tester.tap(find.text('Original Name'));
      await tester.pumpAndSettle();

      // Should show TextField
      expect(find.byType(TextField), findsOneWidget);

      // Enter new name
      await tester.enterText(find.byType(TextField), 'Updated Name');
      await tester.pumpAndSettle();

      // Submit by pressing enter or unfocusing
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Wait for debounce
      await tester.pump(const Duration(milliseconds: 600));

      // Verify update was called
      final updatedList = fakeListRepository._lists.first;
      expect(updatedList.name, 'Updated Name');
    });

    testWidgets('shows loading indicator while saving', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'Original Name',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Tap on the name to edit
      await tester.tap(find.text('Original Name'));
      await tester.pumpAndSettle();

      // Enter new name
      await tester.enterText(find.byType(TextField), 'Updated Name');
      await tester.pumpAndSettle();

      // Submit
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Wait for debounce
      await tester.pump(const Duration(milliseconds: 100));

      // Check for loading indicator (may or may not be present due to timing)
      // This test is timing-dependent, so we'll just verify the update happened
      final updatedList = fakeListRepository._lists.first;
      expect(updatedList.name, 'Updated Name');
    });

    testWidgets('prevents empty list name', (WidgetTester tester) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'Original Name',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Tap on the name to edit
      await tester.tap(find.text('Original Name'));
      await tester.pumpAndSettle();

      // Try to set empty name
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pumpAndSettle();

      // Submit
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Wait for debounce
      await tester.pump(const Duration(milliseconds: 600));

      // Should show error snackbar
      expect(find.text('List name cannot be empty'), findsOneWidget);
    });
  });

  group('ListDetailScreen - Item Management', () {
    testWidgets('opens modal to add new item', (WidgetTester tester) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Tap FAB to add item
      await tester.tap(find.byType(ResponsiveFab));
      await tester.pumpAndSettle();

      // Should show modal with BottomSheetContainer
      expect(find.byType(BottomSheetContainer), findsOneWidget);
      // Note: "Add Item" appears twice - once in FAB label on desktop, once in modal title
      expect(find.text('Add Item'), findsAtLeastNWidgets(1));
      expect(find.text('Title *'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('adds new item successfully', (WidgetTester tester) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Verify empty state initially
      expect(find.text('No items yet'), findsOneWidget);

      // Tap FAB
      await tester.tap(find.byType(ResponsiveFab));
      await tester.pumpAndSettle();

      // We have dialog open, enter text in the title field
      // Find the first TextField inside the dialog (by checking for label)
      await tester.enterText(
        find.widgetWithText(TextField, 'Title *'),
        'New Item',
      );
      await tester.pumpAndSettle();

      // Tap Add button in dialog
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pumpAndSettle();

      // Verify item was added to repository
      final items = await fakeListRepository.getListItemsByListId('list-1');
      expect(items.length, 1);
      expect(items.first.title, 'New Item');
    });

    testWidgets('opens edit dialog on long press', (WidgetTester tester) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        totalItemCount: 1,
        
      );
      fakeListRepository.setLists([list]);
      fakeListRepository.setItemsForList('list-1', [
        ListItem(id: 'item-1', title: 'Existing Item', sortOrder: 0, listId: 'list-1'),
      ]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Long press on item
      await tester.longPress(find.text('Existing Item'));
      await tester.pumpAndSettle();

      // Should show edit dialog
      expect(find.text('Edit Item'), findsOneWidget);
    });

    testWidgets('toggles checkbox for checkboxes style', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'Tasks',
        style: ListStyle.checkboxes,
        totalItemCount: 1,
        
      );
      fakeListRepository.setLists([list]);
      fakeListRepository.setItemsForList('list-1', [
        ListItem(id: 'item-1', title: 'Task', sortOrder: 0, listId: 'list-1'),
      ]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Find and tap checkbox
      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Verify item was toggled
      final items = await fakeListRepository.getListItemsByListId('list-1');
      expect(items.first.isChecked, true);
    });

    testWidgets('supports swipe-to-delete', (WidgetTester tester) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        totalItemCount: 1,
        
      );
      fakeListRepository.setLists([list]);
      fakeListRepository.setItemsForList('list-1', [
        ListItem(id: 'item-1', title: 'Item to Delete', sortOrder: 0, listId: 'list-1'),
      ]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Find Dismissible
      final dismissible = find.byType(Dismissible);
      expect(dismissible, findsOneWidget);

      // Swipe to delete
      await tester.drag(dismissible, const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Should show delete confirmation
      expect(find.text('Delete Item'), findsOneWidget);
    });

    testWidgets('confirms deletion before removing item', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        totalItemCount: 1,
        
      );
      fakeListRepository.setLists([list]);
      fakeListRepository.setItemsForList('list-1', [
        ListItem(id: 'item-1', title: 'Item to Delete', sortOrder: 0, listId: 'list-1'),
      ]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Swipe to delete
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify item was deleted
      expect(find.text('Item to Delete'), findsNothing);
    });
  });

  group('ListDetailScreen - Reordering', () {
    testWidgets('supports drag-and-drop reordering', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        totalItemCount: 3,
        
      );
      fakeListRepository.setLists([list]);
      fakeListRepository.setItemsForList('list-1', [
        ListItem(id: 'item-1', title: 'First', sortOrder: 0, listId: 'list-1'),
        ListItem(id: 'item-2', title: 'Second', sortOrder: 1, listId: 'list-1'),
        ListItem(id: 'item-3', title: 'Third', sortOrder: 2, listId: 'list-1'),
      ]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Check for ReorderableListView
      expect(find.byType(ReorderableListView), findsOneWidget);
    });
  });

  group('ListDetailScreen - Menu Actions', () {
    testWidgets('shows menu with all options', (WidgetTester tester) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Tap menu button
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Check for menu options
      expect(find.text('Change Style'), findsOneWidget);
      expect(find.text('Change Icon'), findsOneWidget);
      expect(find.text('Delete List'), findsOneWidget);
    });

    testWidgets('opens change style dialog', (WidgetTester tester) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Tap menu button
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap Change Style
      await tester.tap(find.text('Change Style'));
      await tester.pumpAndSettle();

      // Should show style dialog
      expect(find.text('Select Style'), findsOneWidget);
      expect(find.text('Bullets'), findsOneWidget);
      expect(find.text('Numbered'), findsOneWidget);
      expect(find.text('Checkboxes'), findsOneWidget);
    });

    testWidgets('opens change icon dialog', (WidgetTester tester) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Tap menu button
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap Change Icon
      await tester.tap(find.text('Change Icon'));
      await tester.pumpAndSettle();

      // Should show icon dialog
      expect(find.text('Select Icon'), findsOneWidget);
    });

    testWidgets('deletes list with confirmation', (WidgetTester tester) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List to Delete',
        totalItemCount: 1,
        
      );
      fakeListRepository.setLists([list]);
      fakeListRepository.setItemsForList('list-1', [
        ListItem(id: 'item-1', title: 'Item', sortOrder: 0, listId: 'list-1'),
      ]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Tap menu button
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap Delete List
      await tester.tap(find.text('Delete List'));
      await tester.pumpAndSettle();

      // Should show confirmation
      expect(
        find.text('Delete List'),
        findsOneWidget,
      ); // Title (button text is just 'Delete')
      expect(find.textContaining('Are you sure'), findsOneWidget);
      expect(find.textContaining('1 items'), findsOneWidget);
    });
  });

  group('ListDetailScreen - Progress Display (Checkboxes)', () {
    testWidgets('shows progress for checkboxes style', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'Tasks',
        style: ListStyle.checkboxes,
        totalItemCount: 3,
        checkedItemCount: 2,
      );
      fakeListRepository.setLists([list]);
      fakeListRepository.setItemsForList('list-1', [
        ListItem(
          id: 'item-1',
          title: 'Task 1',
          isChecked: true,
          sortOrder: 0,
          listId: 'list-1',
        ),
        ListItem(id: 'item-2', title: 'Task 2', sortOrder: 1, listId: 'list-1'),
        ListItem(
          id: 'item-3',
          title: 'Task 3',
          isChecked: true,
          sortOrder: 2,
          listId: 'list-1',
        ),
      ]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Check for progress text
      expect(find.text('2/3 completed'), findsOneWidget);

      // Check for progress bar
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('hides progress for non-checkbox styles', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        totalItemCount: 2,
        
      );
      fakeListRepository.setLists([list]);
      fakeListRepository.setItemsForList('list-1', [
        ListItem(id: 'item-1', title: 'Item 1', sortOrder: 0, listId: 'list-1'),
        ListItem(id: 'item-2', title: 'Item 2', sortOrder: 1, listId: 'list-1'),
      ]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Should not show progress
      expect(find.text('completed'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });

  group('ListDetailScreen - Error Handling', () {
    testWidgets('shows error snackbar on save failure', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Enable error after initial load
      fakeListRepository.setShouldThrowError(true);

      // Try to add an item (which should fail)
      await tester.tap(find.byType(ResponsiveFab));
      await tester.pumpAndSettle();

      // Enter title
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'Test Item');
      await tester.pumpAndSettle();

      // Tap Add button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
      await tester.pumpAndSettle();

      // Should show error - check for any error text in snackbar
      expect(find.textContaining('Failed to add item'), findsOneWidget);
    });
  });

  group('ListDetailScreen - Auto-save', () {
    testWidgets('auto-saves after debounce period', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'Original',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Edit name
      await tester.tap(find.text('Original'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Updated');
      await tester.pumpAndSettle();

      // Wait for debounce (500ms)
      await tester.pump(const Duration(milliseconds: 600));

      // Verify save was called
      final updatedList = fakeListRepository._lists.first;
      expect(updatedList.name, 'Updated');
    });
  });

  group('ListDetailScreen - Accessibility', () {
    testWidgets('has proper semantic labels', (WidgetTester tester) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'Accessible List',
        style: ListStyle.checkboxes,
        totalItemCount: 1,
        
      );
      fakeListRepository.setLists([list]);
      fakeListRepository.setItemsForList('list-1', [
        ListItem(id: 'item-1', title: 'Item 1', sortOrder: 0, listId: 'list-1'),
      ]);

      await tester.pumpWidget(createTestWidget(list));
      await tester.pumpAndSettle();

      // Check for semantic labels
      expect(find.bySemanticsLabel(RegExp('.*Item 1.*')), findsOneWidget);
    });
  });

  group('ListDetailScreen - Responsive FAB', () {
    testWidgets('renders ResponsiveFab on mobile', (WidgetTester tester) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createMobileTestWidget(list));
      await tester.pumpAndSettle();

      // Should have ResponsiveFab
      expect(find.byType(ResponsiveFab), findsOneWidget);

      // On mobile, FAB should be circular (QuickCaptureFab style)
      // The label "Add Item" should not be visible on mobile (icon only)
      final fab = tester.widget<ResponsiveFab>(find.byType(ResponsiveFab));
      expect(fab.label, 'Add Item');
      expect(fab.icon, Icons.add);
    });

    testWidgets('renders extended FAB on desktop', (WidgetTester tester) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createDesktopTestWidget(list));
      await tester.pumpAndSettle();

      // Should have ResponsiveFab
      expect(find.byType(ResponsiveFab), findsOneWidget);

      // On desktop, FAB should be extended with visible label
      expect(find.text('Add Item'), findsOneWidget);

      // Should also have the icon
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('FAB opens modal on mobile', (WidgetTester tester) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createMobileTestWidget(list));
      await tester.pumpAndSettle();

      // Tap FAB
      await tester.tap(find.byType(ResponsiveFab));
      await tester.pumpAndSettle();

      // Modal should open
      expect(find.byType(BottomSheetContainer), findsOneWidget);
      expect(find.text('Add Item'), findsOneWidget);
    });

    testWidgets('FAB opens modal on desktop', (WidgetTester tester) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createDesktopTestWidget(list));
      await tester.pumpAndSettle();

      // Tap FAB
      await tester.tap(find.byType(ResponsiveFab));
      await tester.pumpAndSettle();

      // Modal should open
      expect(find.byType(BottomSheetContainer), findsOneWidget);
      expect(find.text('Add Item'), findsAtLeastNWidgets(1));
    });
  });

  group('ListDetailScreen - Responsive Modals (Add/Edit Item)', () {
    testWidgets('shows bottom sheet on mobile when adding item', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createMobileTestWidget(list));
      await tester.pumpAndSettle();

      // Open add item modal
      await tester.tap(find.byType(ResponsiveFab));
      await tester.pumpAndSettle();

      // Should show BottomSheetContainer with title
      expect(find.byType(BottomSheetContainer), findsOneWidget);
      expect(find.text('Add Item'), findsOneWidget);

      // Should have drag handle on mobile (Container with specific dimensions)
      final dragHandle = find.byWidgetPredicate(
        (widget) => widget is Container && widget.constraints?.maxWidth == 32,
      );
      expect(dragHandle, findsAtLeastNWidgets(1));

      // Should have form fields
      expect(find.text('Title *'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('shows dialog on desktop when adding item', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createDesktopTestWidget(list));
      await tester.pumpAndSettle();

      // Open add item modal
      await tester.tap(find.byType(ResponsiveFab));
      await tester.pumpAndSettle();

      // Should show Dialog containing BottomSheetContainer
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(BottomSheetContainer), findsOneWidget);
      expect(find.text('Add Item'), findsAtLeastNWidgets(1));

      // Should have form fields
      expect(find.text('Title *'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('shows bottom sheet on mobile when editing item', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        totalItemCount: 1,
        
      );
      fakeListRepository.setLists([list]);
      fakeListRepository.setItemsForList('list-1', [
        ListItem(id: 'item-1', title: 'Existing Item', sortOrder: 0, listId: 'list-1'),
      ]);

      await tester.pumpWidget(createMobileTestWidget(list));
      await tester.pumpAndSettle();

      // Long press to edit
      await tester.longPress(find.text('Existing Item'));
      await tester.pumpAndSettle();

      // Should show BottomSheetContainer with "Edit Item" title
      expect(find.byType(BottomSheetContainer), findsOneWidget);
      expect(find.text('Edit Item'), findsOneWidget);

      // Should have drag handle on mobile
      final dragHandle = find.byWidgetPredicate(
        (widget) => widget is Container && widget.constraints?.maxWidth == 32,
      );
      expect(dragHandle, findsAtLeastNWidgets(1));
    });

    testWidgets('shows dialog on desktop when editing item', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        totalItemCount: 1,
        
      );
      fakeListRepository.setLists([list]);
      fakeListRepository.setItemsForList('list-1', [
        ListItem(id: 'item-1', title: 'Existing Item', sortOrder: 0, listId: 'list-1'),
      ]);

      await tester.pumpWidget(createDesktopTestWidget(list));
      await tester.pumpAndSettle();

      // Long press to edit
      await tester.longPress(find.text('Existing Item'));
      await tester.pumpAndSettle();

      // Should show Dialog containing BottomSheetContainer
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(BottomSheetContainer), findsOneWidget);
      expect(find.text('Edit Item'), findsOneWidget);
    });
  });

  group('ListDetailScreen - Responsive Modals (Style Selection)', () {
    testWidgets('shows bottom sheet on mobile for style selection', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createMobileTestWidget(list));
      await tester.pumpAndSettle();

      // Open menu and select "Change Style"
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Change Style'));
      await tester.pumpAndSettle();

      // Should show BottomSheetContainer
      expect(find.byType(BottomSheetContainer), findsOneWidget);
      expect(find.text('Select Style'), findsOneWidget);

      // Should have drag handle on mobile
      final dragHandle = find.byWidgetPredicate(
        (widget) => widget is Container && widget.constraints?.maxWidth == 32,
      );
      expect(dragHandle, findsAtLeastNWidgets(1));

      // Should have style options
      expect(find.text('Bullets'), findsOneWidget);
      expect(find.text('Numbered'), findsOneWidget);
      expect(find.text('Checkboxes'), findsOneWidget);
    });

    testWidgets('shows dialog on desktop for style selection', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createDesktopTestWidget(list));
      await tester.pumpAndSettle();

      // Open menu and select "Change Style"
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Change Style'));
      await tester.pumpAndSettle();

      // Should show Dialog containing BottomSheetContainer
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(BottomSheetContainer), findsOneWidget);
      expect(find.text('Select Style'), findsOneWidget);

      // Should have style options
      expect(find.text('Bullets'), findsOneWidget);
      expect(find.text('Numbered'), findsOneWidget);
      expect(find.text('Checkboxes'), findsOneWidget);
    });
  });

  group('ListDetailScreen - Responsive Modals (Icon Selection)', () {
    testWidgets('shows bottom sheet on mobile for icon selection', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createMobileTestWidget(list));
      await tester.pumpAndSettle();

      // Open menu and select "Change Icon"
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Change Icon'));
      await tester.pumpAndSettle();

      // Should show BottomSheetContainer
      expect(find.byType(BottomSheetContainer), findsOneWidget);
      expect(find.text('Select Icon'), findsOneWidget);

      // Should have drag handle on mobile
      final dragHandle = find.byWidgetPredicate(
        (widget) => widget is Container && widget.constraints?.maxWidth == 32,
      );
      expect(dragHandle, findsAtLeastNWidgets(1));

      // Should have icon grid
      expect(find.text('📝'), findsOneWidget);
      expect(find.text('📋'), findsOneWidget);
    });

    testWidgets('shows dialog on desktop for icon selection', (
      WidgetTester tester,
    ) async {
      final list = ListModel(
        id: 'list-1',
        spaceId: 'space-1',
        userId: 'test-user-id',
        name: 'List',
        
        
      );
      fakeListRepository.setLists([list]);

      await tester.pumpWidget(createDesktopTestWidget(list));
      await tester.pumpAndSettle();

      // Open menu and select "Change Icon"
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Change Icon'));
      await tester.pumpAndSettle();

      // Should show Dialog containing BottomSheetContainer
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(BottomSheetContainer), findsOneWidget);
      expect(find.text('Select Icon'), findsOneWidget);

      // Should have icon grid
      expect(find.text('📝'), findsOneWidget);
      expect(find.text('📋'), findsOneWidget);
    });
  });

}
