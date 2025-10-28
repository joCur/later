import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/data/models/todo_list_model.dart';
import 'package:later_mobile/data/repositories/list_repository.dart';
import 'package:later_mobile/data/repositories/note_repository.dart';
import 'package:later_mobile/data/repositories/space_repository.dart';
import 'package:later_mobile/data/repositories/todo_list_repository.dart';
import 'package:later_mobile/providers/content_provider.dart';
import 'package:later_mobile/providers/spaces_provider.dart';
import 'package:later_mobile/design_system/organisms/fab/responsive_fab.dart';
import 'package:later_mobile/widgets/screens/todo_list_detail_screen.dart';
import 'package:provider/provider.dart';

/// Mock TodoListRepository for testing
class MockTodoListRepository extends TodoListRepository {
  List<TodoList> mockTodoLists = [];

  @override
  Future<TodoList> update(TodoList todoList) async {
    final index = mockTodoLists.indexWhere((t) => t.id == todoList.id);
    if (index != -1) {
      mockTodoLists[index] = todoList;
    }
    return todoList;
  }

  @override
  Future<TodoList> addItem(String listId, TodoItem item) async {
    final index = mockTodoLists.indexWhere((t) => t.id == listId);
    if (index == -1) {
      throw Exception('TodoList not found');
    }
    final updated = mockTodoLists[index].copyWith(
      items: [...mockTodoLists[index].items, item],
    );
    mockTodoLists[index] = updated;
    return updated;
  }

  @override
  Future<TodoList> updateItem(
    String listId,
    String itemId,
    TodoItem updatedItem,
  ) async {
    final listIndex = mockTodoLists.indexWhere((t) => t.id == listId);
    if (listIndex == -1) throw Exception('TodoList not found');

    final items = List<TodoItem>.from(mockTodoLists[listIndex].items);
    final itemIndex = items.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) throw Exception('Item not found');

    items[itemIndex] = updatedItem;
    final updated = mockTodoLists[listIndex].copyWith(items: items);
    mockTodoLists[listIndex] = updated;
    return updated;
  }

  @override
  Future<TodoList> deleteItem(String listId, String itemId) async {
    final listIndex = mockTodoLists.indexWhere((t) => t.id == listId);
    if (listIndex == -1) throw Exception('TodoList not found');

    final items = mockTodoLists[listIndex].items
        .where((i) => i.id != itemId)
        .toList();
    final updated = mockTodoLists[listIndex].copyWith(items: items);
    mockTodoLists[listIndex] = updated;
    return updated;
  }
}

/// Mock ListRepository for testing
class MockListRepository extends ListRepository {}

/// Mock NoteRepository for testing
class MockNoteRepository extends NoteRepository {}

/// Mock SpaceRepository for testing
class MockSpaceRepository extends SpaceRepository {}

void main() {
  late TodoList testTodoList;
  late MockTodoListRepository mockTodoListRepository;
  late MockListRepository mockListRepository;
  late MockNoteRepository mockNoteRepository;
  late MockSpaceRepository mockSpaceRepository;
  late ContentProvider mockContentProvider;
  late SpacesProvider mockSpacesProvider;

  setUp(() {
    testTodoList = TodoList(
      id: 'test-todo-list',
      name: 'Test TodoList',
      items: [
        TodoItem(
          id: 'item-1',
          title: 'Test Item 1',
          description: 'Description 1',
          priority: TodoPriority.high,
          sortOrder: 0,
        ),
        TodoItem(
          id: 'item-2',
          title: 'Test Item 2',
          isCompleted: true,
          priority: TodoPriority.medium,
          sortOrder: 1,
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      spaceId: 'test-space',
    );

    mockTodoListRepository = MockTodoListRepository();
    mockTodoListRepository.mockTodoLists = [testTodoList];

    mockListRepository = MockListRepository();
    mockNoteRepository = MockNoteRepository();
    mockSpaceRepository = MockSpaceRepository();

    mockContentProvider = ContentProvider(
      todoListRepository: mockTodoListRepository,
      listRepository: mockListRepository,
      noteRepository: mockNoteRepository,
    );

    mockSpacesProvider = SpacesProvider(mockSpaceRepository);
  });

  Widget createTestWidget({
    required TodoList todoList,
    Size? screenSize, // Mobile size by default
  }) {
    Widget widget = MultiProvider(
      providers: [
        ChangeNotifierProvider<ContentProvider>.value(
          value: mockContentProvider,
        ),
        ChangeNotifierProvider<SpacesProvider>.value(value: mockSpacesProvider),
      ],
      child: MaterialApp(home: TodoListDetailScreen(todoList: todoList)),
    );

    if (screenSize != null) {
      widget = MediaQuery(
        data: MediaQueryData(size: screenSize),
        child: widget,
      );
    }

    return widget;
  }

  group('TodoListDetailScreen - Basic UI', () {
    testWidgets('should display TodoList name in AppBar', (tester) async {
      await tester.pumpWidget(createTestWidget(todoList: testTodoList));
      await tester.pumpAndSettle();

      expect(find.text('Test TodoList'), findsOneWidget);
    });

    testWidgets('should display progress indicator', (tester) async {
      await tester.pumpWidget(createTestWidget(todoList: testTodoList));
      await tester.pumpAndSettle();

      expect(find.text('1/2 completed'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should display all TodoItems', (tester) async {
      await tester.pumpWidget(createTestWidget(todoList: testTodoList));
      await tester.pumpAndSettle();

      expect(find.text('Test Item 1'), findsOneWidget);
      expect(find.text('Test Item 2'), findsOneWidget);
    });

    testWidgets('should display empty state when no items', (tester) async {
      final emptyTodoList = testTodoList.copyWith(items: []);
      await tester.pumpWidget(createTestWidget(todoList: emptyTodoList));
      await tester.pumpAndSettle();

      expect(find.text('No tasks yet'), findsOneWidget);
      expect(
        find.text('Tap the + button to add your first task'),
        findsOneWidget,
      );
    });
  });

  group('TodoListDetailScreen - Responsive FAB', () {
    testWidgets('should render ResponsiveFab on mobile', (tester) async {
      // Mobile screen size
      await tester.pumpWidget(
        createTestWidget(
          todoList: testTodoList,
          screenSize: const Size(375, 812),
        ),
      );
      await tester.pumpAndSettle();

      // ResponsiveFab should exist
      expect(find.byType(ResponsiveFab), findsOneWidget);
    });

    testWidgets('should render ResponsiveFab on desktop with label', (
      tester,
    ) async {
      // Desktop screen size
      await tester.pumpWidget(
        createTestWidget(
          todoList: testTodoList,
          screenSize: const Size(1200, 800),
        ),
      );
      await tester.pumpAndSettle();

      // ResponsiveFab should exist
      expect(find.byType(ResponsiveFab), findsOneWidget);

      // On desktop, label should be visible
      expect(find.text('Add Todo'), findsOneWidget);
    });

    testWidgets('FAB should open add TodoItem modal when tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(todoList: testTodoList));
      await tester.pumpAndSettle();

      // Tap FAB (find by ResponsiveFab type)
      await tester.tap(find.byType(ResponsiveFab));
      await tester.pumpAndSettle();

      // Modal should open with title
      expect(find.text('Add TodoItem'), findsOneWidget);
      expect(find.text('Title *'), findsOneWidget);
    });
  });

  group('TodoListDetailScreen - Responsive Modal', () {
    testWidgets('should show bottom sheet on mobile when adding TodoItem', (
      tester,
    ) async {
      // Mobile screen size
      await tester.pumpWidget(
        createTestWidget(
          todoList: testTodoList,
          screenSize: const Size(375, 812),
        ),
      );
      await tester.pumpAndSettle();

      // Tap FAB to open modal
      await tester.tap(find.byType(ResponsiveFab));
      await tester.pumpAndSettle();

      // On mobile, should see bottom sheet container with drag handle
      // The drag handle is a Container with specific dimensions
      final dragHandle = find.byWidgetPredicate(
        (widget) => widget is Container && widget.constraints?.maxWidth == 32,
      );
      expect(dragHandle, findsAtLeastNWidgets(1));
    });

    testWidgets('should show dialog on desktop when adding TodoItem', (
      tester,
    ) async {
      // Desktop screen size
      await tester.pumpWidget(
        createTestWidget(
          todoList: testTodoList,
          screenSize: const Size(1200, 800),
        ),
      );
      await tester.pumpAndSettle();

      // Tap FAB to open modal
      await tester.tap(find.byType(ResponsiveFab));
      await tester.pumpAndSettle();

      // On desktop, should see dialog
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Add TodoItem'), findsOneWidget);
    });

    testWidgets('should show edit modal when long-pressing TodoItem', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(todoList: testTodoList));
      await tester.pumpAndSettle();

      // Find and long-press the first item
      await tester.longPress(find.text('Test Item 1'));
      await tester.pumpAndSettle();

      // Edit modal should open
      expect(find.text('Edit TodoItem'), findsOneWidget);
      expect(find.text('Title *'), findsOneWidget);
    });
  });

  group('TodoListDetailScreen - TodoItem Form Fields', () {
    testWidgets('should display all form fields in add modal', (tester) async {
      await tester.pumpWidget(createTestWidget(todoList: testTodoList));
      await tester.pumpAndSettle();

      // Open add modal
      await tester.tap(find.byType(ResponsiveFab));
      await tester.pumpAndSettle();

      // Check all form fields exist
      expect(find.text('Title *'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('No due date'), findsOneWidget);
      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('should show validation error for empty title', (tester) async {
      await tester.pumpWidget(createTestWidget(todoList: testTodoList));
      await tester.pumpAndSettle();

      // Open add modal
      await tester.tap(find.byType(ResponsiveFab));
      await tester.pumpAndSettle();

      // Try to save without entering title
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Should show error snackbar
      expect(find.text('Title is required'), findsOneWidget);
    });

    testWidgets('should close modal when Cancel is tapped', (tester) async {
      await tester.pumpWidget(createTestWidget(todoList: testTodoList));
      await tester.pumpAndSettle();

      // Open add modal
      await tester.tap(find.byType(ResponsiveFab));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Modal should be closed
      expect(find.text('Add TodoItem'), findsNothing);
    });
  });

  group('TodoListDetailScreen - Dismissible Background', () {
    testWidgets('should show delete background when swiping TodoItem', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(todoList: testTodoList));
      await tester.pumpAndSettle();

      // Find the dismissible
      final dismissible = find.byType(Dismissible).first;

      // Start swipe gesture (don't complete it)
      await tester.drag(dismissible, const Offset(-200, 0));
      await tester.pump();

      // Should see delete icon
      expect(find.byIcon(Icons.delete), findsAtLeastNWidgets(1));
    });

    testWidgets('should show delete confirmation when dismissing', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(todoList: testTodoList));
      await tester.pumpAndSettle();

      // Swipe to delete
      await tester.drag(find.text('Test Item 1'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Delete TodoItem'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete "Test Item 1"?'),
        findsOneWidget,
      );
    });

    testWidgets('Dismissible background should have correct styling', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(todoList: testTodoList));
      await tester.pumpAndSettle();

      // Find the dismissible
      final dismissible = find.byType(Dismissible).first;

      // Start swipe to reveal background
      await tester.drag(dismissible, const Offset(-200, 0));
      await tester.pump();

      // Find the ClipRRect with border radius
      final clipRRect = find.byWidgetPredicate(
        (widget) =>
            widget is ClipRRect &&
            widget.borderRadius == BorderRadius.circular(8.0),
      );
      expect(clipRRect, findsAtLeastNWidgets(1));

      // Find the background container with error color
      final backgroundContainer = find.byWidgetPredicate(
        (widget) => widget is Container && widget.color == AppColors.error,
      );
      expect(backgroundContainer, findsAtLeastNWidgets(1));
    });
  });

  group('TodoListDetailScreen - Menu Actions', () {
    testWidgets('should show delete list option in menu', (tester) async {
      await tester.pumpWidget(createTestWidget(todoList: testTodoList));
      await tester.pumpAndSettle();

      // Tap menu button
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Should see delete option
      expect(find.text('Delete List'), findsOneWidget);
    });

    testWidgets('should show delete confirmation when deleting list', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(todoList: testTodoList));
      await tester.pumpAndSettle();

      // Open menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap delete
      await tester.tap(find.text('Delete List'));
      await tester.pumpAndSettle();

      // Should show confirmation
      expect(find.text('Delete TodoList'), findsOneWidget);
      expect(
        find.textContaining('Are you sure you want to delete "Test TodoList"?'),
        findsOneWidget,
      );
    });
  });
}
