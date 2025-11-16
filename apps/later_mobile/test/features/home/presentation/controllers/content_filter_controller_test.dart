import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/models/list_style.dart';
import 'package:later_mobile/features/home/presentation/controllers/content_filter_controller.dart';
import 'package:later_mobile/features/lists/application/providers.dart';
import 'package:later_mobile/features/lists/application/services/list_service.dart';
import 'package:later_mobile/features/lists/domain/models/list_model.dart';
import 'package:later_mobile/features/lists/presentation/controllers/lists_controller.dart';
import 'package:later_mobile/features/notes/application/providers.dart';
import 'package:later_mobile/features/notes/application/services/note_service.dart';
import 'package:later_mobile/features/notes/domain/models/note.dart';
import 'package:later_mobile/features/notes/presentation/controllers/notes_controller.dart';
import 'package:later_mobile/features/todo_lists/application/providers.dart';
import 'package:later_mobile/features/todo_lists/application/services/todo_list_service.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_list.dart';
import 'package:later_mobile/features/todo_lists/presentation/controllers/todo_lists_controller.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([NoteService, TodoListService, ListService])
import 'content_filter_controller_test.mocks.dart';

/// Helper to create a test container with mocked services
ProviderContainer createTestContainer({
  required String spaceId,
  required MockNoteService mockNoteService,
  required MockTodoListService mockTodoListService,
  required MockListService mockListService,
}) {
  return ProviderContainer(
    overrides: [
      noteServiceProvider.overrideWithValue(mockNoteService),
      todoListServiceProvider.overrideWithValue(mockTodoListService),
      listServiceProvider.overrideWithValue(mockListService),
    ],
  );
}

void main() {
  group('ContentFilterController', () {
    const testSpaceId = 'test-space-id';
    const testUserId = 'test-user-id';

    late MockNoteService mockNoteService;
    late MockTodoListService mockTodoListService;
    late MockListService mockListService;

    setUp(() {
      mockNoteService = MockNoteService();
      mockTodoListService = MockTodoListService();
      mockListService = MockListService();
    });

    // Create mock data with different timestamps for sorting tests
    final now = DateTime.now();
    final mockNote1 = Note(
      id: 'note-1',
      title: 'Note 1',
      content: 'Content 1',
      spaceId: testSpaceId,
      userId: testUserId,
      updatedAt: now.subtract(const Duration(hours: 1)),
    );
    final mockNote2 = Note(
      id: 'note-2',
      title: 'Note 2',
      content: 'Content 2',
      spaceId: testSpaceId,
      userId: testUserId,
      updatedAt: now.subtract(const Duration(hours: 3)),
    );
    final mockTodoList1 = TodoList(
      id: 'todo-1',
      spaceId: testSpaceId,
      userId: testUserId,
      name: 'Todo List 1',
      totalItemCount: 5,
      completedItemCount: 2,
      updatedAt: now, // Most recent
    );
    final mockTodoList2 = TodoList(
      id: 'todo-2',
      spaceId: testSpaceId,
      userId: testUserId,
      name: 'Todo List 2',
      totalItemCount: 3,
      completedItemCount: 1,
      updatedAt: now.subtract(const Duration(hours: 4)),
    );
    final mockList1 = ListModel(
      id: 'list-1',
      spaceId: testSpaceId,
      userId: testUserId,
      name: 'List 1',
      totalItemCount: 4,
      updatedAt: now.subtract(const Duration(hours: 2)),
    );
    final mockList2 = ListModel(
      id: 'list-2',
      spaceId: testSpaceId,
      userId: testUserId,
      name: 'List 2',
      style: ListStyle.checkboxes,
      totalItemCount: 2,
      checkedItemCount: 1,
      updatedAt: now.subtract(const Duration(hours: 5)), // Oldest
    );

    test('initial state is ContentFilter.all', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final filter = container.read(contentFilterControllerProvider);

      expect(filter, equals(ContentFilter.all));
    });

    test('setFilter() changes the filter state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(
        contentFilterControllerProvider.notifier,
      );

      // Initially should be "all"
      expect(
        container.read(contentFilterControllerProvider),
        equals(ContentFilter.all),
      );

      // Change to notes
      controller.setFilter(ContentFilter.notes);
      expect(
        container.read(contentFilterControllerProvider),
        equals(ContentFilter.notes),
      );

      // Change to todoLists
      controller.setFilter(ContentFilter.todoLists);
      expect(
        container.read(contentFilterControllerProvider),
        equals(ContentFilter.todoLists),
      );

      // Change to lists
      controller.setFilter(ContentFilter.lists);
      expect(
        container.read(contentFilterControllerProvider),
        equals(ContentFilter.lists),
      );

      // Change back to all
      controller.setFilter(ContentFilter.all);
      expect(
        container.read(contentFilterControllerProvider),
        equals(ContentFilter.all),
      );
    });

    test(
      'getFilteredContent() returns all content when filter is "all"',
      () async {
        when(
          mockNoteService.getNotesForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockNote1, mockNote2]);
        when(
          mockTodoListService.getTodoListsForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockTodoList1, mockTodoList2]);
        when(
          mockListService.getListsForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockList1, mockList2]);

        final container = createTestContainer(
          spaceId: testSpaceId,
          mockNoteService: mockNoteService,
          mockTodoListService: mockTodoListService,
          mockListService: mockListService,
        );
        addTearDown(container.dispose);

        // Wait for data to load
        await container.read(notesControllerProvider(testSpaceId).future);
        await container.read(todoListsControllerProvider(testSpaceId).future);
        await container.read(listsControllerProvider(testSpaceId).future);

        final controller = container.read(
          contentFilterControllerProvider.notifier,
        );
        final content = controller.getFilteredContent(testSpaceId);

        // Should contain all 6 items (2 notes + 2 todo lists + 2 lists)
        expect(content.length, equals(6));
        expect(content.whereType<Note>().length, equals(2));
        expect(content.whereType<TodoList>().length, equals(2));
        expect(content.whereType<ListModel>().length, equals(2));
      },
    );

    test(
      'getFilteredContent() returns only notes when filter is "notes"',
      () async {
        when(
          mockNoteService.getNotesForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockNote1, mockNote2]);
        when(
          mockTodoListService.getTodoListsForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockTodoList1, mockTodoList2]);
        when(
          mockListService.getListsForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockList1, mockList2]);

        final container = createTestContainer(
          spaceId: testSpaceId,
          mockNoteService: mockNoteService,
          mockTodoListService: mockTodoListService,
          mockListService: mockListService,
        );
        addTearDown(container.dispose);

        // Wait for data to load
        await container.read(notesControllerProvider(testSpaceId).future);
        await container.read(todoListsControllerProvider(testSpaceId).future);
        await container.read(listsControllerProvider(testSpaceId).future);

        final controller = container.read(
          contentFilterControllerProvider.notifier,
        );
        controller.setFilter(ContentFilter.notes);

        final content = controller.getFilteredContent(testSpaceId);

        // Should contain only 2 notes
        expect(content.length, equals(2));
        expect(content.whereType<Note>().length, equals(2));
        expect(content.whereType<TodoList>().length, equals(0));
        expect(content.whereType<ListModel>().length, equals(0));
      },
    );

    test(
      'getFilteredContent() returns only todoLists when filter is "todoLists"',
      () async {
        when(
          mockNoteService.getNotesForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockNote1, mockNote2]);
        when(
          mockTodoListService.getTodoListsForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockTodoList1, mockTodoList2]);
        when(
          mockListService.getListsForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockList1, mockList2]);

        final container = createTestContainer(
          spaceId: testSpaceId,
          mockNoteService: mockNoteService,
          mockTodoListService: mockTodoListService,
          mockListService: mockListService,
        );
        addTearDown(container.dispose);

        // Wait for data to load
        await container.read(notesControllerProvider(testSpaceId).future);
        await container.read(todoListsControllerProvider(testSpaceId).future);
        await container.read(listsControllerProvider(testSpaceId).future);

        final controller = container.read(
          contentFilterControllerProvider.notifier,
        );
        controller.setFilter(ContentFilter.todoLists);

        final content = controller.getFilteredContent(testSpaceId);

        // Should contain only 2 todo lists
        expect(content.length, equals(2));
        expect(content.whereType<Note>().length, equals(0));
        expect(content.whereType<TodoList>().length, equals(2));
        expect(content.whereType<ListModel>().length, equals(0));
      },
    );

    test(
      'getFilteredContent() returns only lists when filter is "lists"',
      () async {
        when(
          mockNoteService.getNotesForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockNote1, mockNote2]);
        when(
          mockTodoListService.getTodoListsForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockTodoList1, mockTodoList2]);
        when(
          mockListService.getListsForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockList1, mockList2]);

        final container = createTestContainer(
          spaceId: testSpaceId,
          mockNoteService: mockNoteService,
          mockTodoListService: mockTodoListService,
          mockListService: mockListService,
        );
        addTearDown(container.dispose);

        // Wait for data to load
        await container.read(notesControllerProvider(testSpaceId).future);
        await container.read(todoListsControllerProvider(testSpaceId).future);
        await container.read(listsControllerProvider(testSpaceId).future);

        final controller = container.read(
          contentFilterControllerProvider.notifier,
        );
        controller.setFilter(ContentFilter.lists);

        final content = controller.getFilteredContent(testSpaceId);

        // Should contain only 2 lists
        expect(content.length, equals(2));
        expect(content.whereType<Note>().length, equals(0));
        expect(content.whereType<TodoList>().length, equals(0));
        expect(content.whereType<ListModel>().length, equals(2));
      },
    );

    test(
      'getFilteredContent() sorts by updatedAt (most recent first) when filter is "all"',
      () async {
        when(
          mockNoteService.getNotesForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockNote1, mockNote2]);
        when(
          mockTodoListService.getTodoListsForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockTodoList1, mockTodoList2]);
        when(
          mockListService.getListsForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockList1, mockList2]);

        final container = createTestContainer(
          spaceId: testSpaceId,
          mockNoteService: mockNoteService,
          mockTodoListService: mockTodoListService,
          mockListService: mockListService,
        );
        addTearDown(container.dispose);

        // Wait for data to load
        await container.read(notesControllerProvider(testSpaceId).future);
        await container.read(todoListsControllerProvider(testSpaceId).future);
        await container.read(listsControllerProvider(testSpaceId).future);

        final controller = container.read(
          contentFilterControllerProvider.notifier,
        );
        final content = controller.getFilteredContent(testSpaceId);

        // Expected order (most recent first):
        // 1. mockTodoList1 (now)
        // 2. mockNote1 (now - 1 hour)
        // 3. mockList1 (now - 2 hours)
        // 4. mockNote2 (now - 3 hours)
        // 5. mockTodoList2 (now - 4 hours)
        // 6. mockList2 (now - 5 hours)
        expect(content.length, equals(6));
        expect((content[0] as TodoList).id, equals('todo-1'));
        expect((content[1] as Note).id, equals('note-1'));
        expect((content[2] as ListModel).id, equals('list-1'));
        expect((content[3] as Note).id, equals('note-2'));
        expect((content[4] as TodoList).id, equals('todo-2'));
        expect((content[5] as ListModel).id, equals('list-2'));
      },
    );

    test(
      'getFilteredContent() returns empty list when controllers are loading',
      () {
        // Don't answer mock calls - providers will be in loading state
        final container = createTestContainer(
          spaceId: testSpaceId,
          mockNoteService: mockNoteService,
          mockTodoListService: mockTodoListService,
          mockListService: mockListService,
        );
        addTearDown(container.dispose);

        final controller = container.read(
          contentFilterControllerProvider.notifier,
        );
        final content = controller.getFilteredContent(testSpaceId);

        // Should return empty when loading
        expect(content.length, equals(0));
      },
    );

    test(
      'getFilteredContent() handles partial loading (some controllers loading)',
      () async {
        // Only set up notes and lists, leave todo lists without mock answer
        when(
          mockNoteService.getNotesForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockNote1, mockNote2]);
        when(
          mockListService.getListsForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockList1, mockList2]);

        final container = createTestContainer(
          spaceId: testSpaceId,
          mockNoteService: mockNoteService,
          mockTodoListService: mockTodoListService,
          mockListService: mockListService,
        );
        addTearDown(container.dispose);

        // Wait for non-loading data to load
        await container.read(notesControllerProvider(testSpaceId).future);
        await container.read(listsControllerProvider(testSpaceId).future);

        final controller = container.read(
          contentFilterControllerProvider.notifier,
        );
        final content = controller.getFilteredContent(testSpaceId);

        // Should contain notes and lists, but not todo lists (still loading)
        expect(content.length, equals(4));
        expect(content.whereType<Note>().length, equals(2));
        expect(content.whereType<TodoList>().length, equals(0));
        expect(content.whereType<ListModel>().length, equals(2));
      },
    );

    test('isLoading() returns true when any controller is loading', () {
      // Don't answer mock calls - providers will be in loading state
      final container = createTestContainer(
        spaceId: testSpaceId,
        mockNoteService: mockNoteService,
        mockTodoListService: mockTodoListService,
        mockListService: mockListService,
      );
      addTearDown(container.dispose);

      final controller = container.read(
        contentFilterControllerProvider.notifier,
      );
      expect(controller.isLoading(testSpaceId), isTrue);
    });

    test('isLoading() returns false when all controllers have data', () async {
      when(
        mockNoteService.getNotesForSpace(testSpaceId),
      ).thenAnswer((_) async => [mockNote1, mockNote2]);
      when(
        mockTodoListService.getTodoListsForSpace(testSpaceId),
      ).thenAnswer((_) async => [mockTodoList1, mockTodoList2]);
      when(
        mockListService.getListsForSpace(testSpaceId),
      ).thenAnswer((_) async => [mockList1, mockList2]);

      final container = createTestContainer(
        spaceId: testSpaceId,
        mockNoteService: mockNoteService,
        mockTodoListService: mockTodoListService,
        mockListService: mockListService,
      );
      addTearDown(container.dispose);

      // Wait for data to load
      await container.read(notesControllerProvider(testSpaceId).future);
      await container.read(todoListsControllerProvider(testSpaceId).future);
      await container.read(listsControllerProvider(testSpaceId).future);

      final controller = container.read(
        contentFilterControllerProvider.notifier,
      );
      expect(controller.isLoading(testSpaceId), isFalse);
    });

    test(
      'getTotalCount() returns sum of all content when filter is "all"',
      () async {
        when(
          mockNoteService.getNotesForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockNote1, mockNote2]);
        when(
          mockTodoListService.getTodoListsForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockTodoList1, mockTodoList2]);
        when(
          mockListService.getListsForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockList1, mockList2]);

        final container = createTestContainer(
          spaceId: testSpaceId,
          mockNoteService: mockNoteService,
          mockTodoListService: mockTodoListService,
          mockListService: mockListService,
        );
        addTearDown(container.dispose);

        // Wait for data to load
        await container.read(notesControllerProvider(testSpaceId).future);
        await container.read(todoListsControllerProvider(testSpaceId).future);
        await container.read(listsControllerProvider(testSpaceId).future);

        final controller = container.read(
          contentFilterControllerProvider.notifier,
        );
        final count = controller.getTotalCount(testSpaceId);

        expect(count, equals(6)); // 2 notes + 2 todo lists + 2 lists
      },
    );

    test(
      'getTotalCount() returns notes count when filter is "notes"',
      () async {
        when(
          mockNoteService.getNotesForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockNote1, mockNote2]);
        when(
          mockTodoListService.getTodoListsForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockTodoList1, mockTodoList2]);
        when(
          mockListService.getListsForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockList1, mockList2]);

        final container = createTestContainer(
          spaceId: testSpaceId,
          mockNoteService: mockNoteService,
          mockTodoListService: mockTodoListService,
          mockListService: mockListService,
        );
        addTearDown(container.dispose);

        // Wait for data to load
        await container.read(notesControllerProvider(testSpaceId).future);
        await container.read(todoListsControllerProvider(testSpaceId).future);
        await container.read(listsControllerProvider(testSpaceId).future);

        final controller = container.read(
          contentFilterControllerProvider.notifier,
        );
        controller.setFilter(ContentFilter.notes);

        final count = controller.getTotalCount(testSpaceId);
        expect(count, equals(2)); // 2 notes
      },
    );

    test(
      'getTotalCount() returns todoLists count when filter is "todoLists"',
      () async {
        when(
          mockNoteService.getNotesForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockNote1, mockNote2]);
        when(
          mockTodoListService.getTodoListsForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockTodoList1, mockTodoList2]);
        when(
          mockListService.getListsForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockList1, mockList2]);

        final container = createTestContainer(
          spaceId: testSpaceId,
          mockNoteService: mockNoteService,
          mockTodoListService: mockTodoListService,
          mockListService: mockListService,
        );
        addTearDown(container.dispose);

        // Wait for data to load
        await container.read(notesControllerProvider(testSpaceId).future);
        await container.read(todoListsControllerProvider(testSpaceId).future);
        await container.read(listsControllerProvider(testSpaceId).future);

        final controller = container.read(
          contentFilterControllerProvider.notifier,
        );
        controller.setFilter(ContentFilter.todoLists);

        final count = controller.getTotalCount(testSpaceId);
        expect(count, equals(2)); // 2 todo lists
      },
    );

    test(
      'getTotalCount() returns lists count when filter is "lists"',
      () async {
        when(
          mockNoteService.getNotesForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockNote1, mockNote2]);
        when(
          mockTodoListService.getTodoListsForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockTodoList1, mockTodoList2]);
        when(
          mockListService.getListsForSpace(testSpaceId),
        ).thenAnswer((_) async => [mockList1, mockList2]);

        final container = createTestContainer(
          spaceId: testSpaceId,
          mockNoteService: mockNoteService,
          mockTodoListService: mockTodoListService,
          mockListService: mockListService,
        );
        addTearDown(container.dispose);

        // Wait for data to load
        await container.read(notesControllerProvider(testSpaceId).future);
        await container.read(todoListsControllerProvider(testSpaceId).future);
        await container.read(listsControllerProvider(testSpaceId).future);

        final controller = container.read(
          contentFilterControllerProvider.notifier,
        );
        controller.setFilter(ContentFilter.lists);

        final count = controller.getTotalCount(testSpaceId);
        expect(count, equals(2)); // 2 lists
      },
    );

    test('getTotalCount() returns 0 when controllers are loading', () {
      // Don't answer mock calls - providers will be in loading state
      final container = createTestContainer(
        spaceId: testSpaceId,
        mockNoteService: mockNoteService,
        mockTodoListService: mockTodoListService,
        mockListService: mockListService,
      );
      addTearDown(container.dispose);

      final controller = container.read(
        contentFilterControllerProvider.notifier,
      );
      final count = controller.getTotalCount(testSpaceId);

      expect(count, equals(0));
    });
  });
}
