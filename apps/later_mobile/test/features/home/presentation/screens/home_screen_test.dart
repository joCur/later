import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/models/list_style.dart';
import 'package:later_mobile/design_system/atoms/chips/filter_chip.dart';
import 'package:later_mobile/design_system/organisms/cards/list_card.dart';
import 'package:later_mobile/design_system/organisms/cards/note_card.dart';
import 'package:later_mobile/design_system/organisms/cards/todo_list_card.dart';
import 'package:later_mobile/design_system/organisms/empty_states/empty_space_state.dart';
import 'package:later_mobile/design_system/organisms/empty_states/no_spaces_state.dart';
import 'package:later_mobile/design_system/organisms/empty_states/welcome_state.dart';
import 'package:later_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:later_mobile/features/home/presentation/controllers/content_filter_controller.dart';
import 'package:later_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:later_mobile/features/lists/domain/models/list_model.dart';
import 'package:later_mobile/features/lists/presentation/controllers/lists_controller.dart';
import 'package:later_mobile/features/notes/domain/models/note.dart';
import 'package:later_mobile/features/notes/presentation/controllers/notes_controller.dart';
import 'package:later_mobile/features/spaces/domain/models/space.dart';
import 'package:later_mobile/features/spaces/presentation/controllers/current_space_controller.dart';
import 'package:later_mobile/features/spaces/presentation/controllers/spaces_controller.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_list.dart';
import 'package:later_mobile/features/todo_lists/presentation/controllers/todo_lists_controller.dart';

import '../../../test_helpers.dart';

void main() {
  group('HomeScreen Empty States', () {
    const testUserId = 'test-user-id';

    testWidgets('shows NoSpacesState when no spaces exist', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spacesControllerProvider.overrideWithValue(
              const AsyncValue.data([]),
            ),
            currentSpaceControllerProvider.overrideWithValue(
              const AsyncValue.data(null),
            ),
            authStateControllerProvider.overrideWith((ref) {
              return AuthStateController(ref, initialUserId: testUserId);
            }),
          ],
          child: testApp(const HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Should show NoSpacesState
      expect(find.byType(NoSpacesState), findsOneWidget);
      expect(find.text('Welcome to Later'), findsOneWidget);
    });

    testWidgets('shows WelcomeState for new user with default Inbox space', (
      tester,
    ) async {
      final defaultSpace = Space(
        id: 'inbox-space',
        name: 'Inbox',
        userId: testUserId,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spacesControllerProvider.overrideWithValue(
              AsyncValue.data([defaultSpace]),
            ),
            currentSpaceControllerProvider.overrideWithValue(
              AsyncValue.data(defaultSpace),
            ),
            notesControllerProvider(
              defaultSpace.id,
            ).overrideWithValue(const AsyncValue.data([])),
            todoListsControllerProvider(
              defaultSpace.id,
            ).overrideWithValue(const AsyncValue.data([])),
            listsControllerProvider(
              defaultSpace.id,
            ).overrideWithValue(const AsyncValue.data([])),
            authStateControllerProvider.overrideWith((ref) {
              return AuthStateController(ref, initialUserId: testUserId);
            }),
          ],
          child: testApp(const HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Should show WelcomeState
      expect(find.byType(WelcomeState), findsOneWidget);
      expect(
        find.text('Welcome! Let\'s capture your first thought'),
        findsOneWidget,
      );
    });

    testWidgets(
      'shows EmptySpaceState for existing user with empty custom space',
      (tester) async {
        final customSpace = Space(
          id: 'custom-space',
          name: 'Work',
          userId: testUserId,
        );
        final inboxSpace = Space(
          id: 'inbox-space',
          name: 'Inbox',
          userId: testUserId,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              spacesControllerProvider.overrideWithValue(
                AsyncValue.data([inboxSpace, customSpace]),
              ),
              currentSpaceControllerProvider.overrideWithValue(
                AsyncValue.data(customSpace),
              ),
              notesControllerProvider(
                customSpace.id,
              ).overrideWithValue(const AsyncValue.data([])),
              todoListsControllerProvider(
                customSpace.id,
              ).overrideWithValue(const AsyncValue.data([])),
              listsControllerProvider(
                customSpace.id,
              ).overrideWithValue(const AsyncValue.data([])),
              authStateControllerProvider.overrideWith((ref) {
                return AuthStateController(ref, initialUserId: testUserId);
              }),
            ],
            child: testApp(const HomeScreen()),
          ),
        );

        await tester.pumpAndSettle();

        // Should show EmptySpaceState
        expect(find.byType(EmptySpaceState), findsOneWidget);
        expect(find.textContaining('Work'), findsOneWidget);
      },
    );
  });

  group('HomeScreen Filter Chips', () {
    const testUserId = 'test-user-id';
    const testSpaceId = 'test-space-id';

    late Space mockSpace;
    late Note mockNote;
    late TodoList mockTodoList;
    late ListModel mockList;

    setUp(() {
      mockSpace = Space(
        id: testSpaceId,
        name: 'Test Space',
        userId: testUserId,
      );

      mockNote = Note(
        id: 'note-1',
        title: 'Test Note',
        content: 'Test content',
        spaceId: testSpaceId,
        userId: testUserId,
      );

      mockTodoList = TodoList(
        id: 'todo-1',
        spaceId: testSpaceId,
        userId: testUserId,
        name: 'Test Todo List',
        totalItemCount: 3,
        completedItemCount: 1,
      );

      mockList = ListModel(
        id: 'list-1',
        spaceId: testSpaceId,
        userId: testUserId,
        name: 'Test List',
        totalItemCount: 2,
      );
    });

    testWidgets('displays all filter chips', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spacesControllerProvider.overrideWithValue(
              AsyncValue.data([mockSpace]),
            ),
            currentSpaceControllerProvider.overrideWithValue(
              AsyncValue.data(mockSpace),
            ),
            notesControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockNote])),
            todoListsControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockTodoList])),
            listsControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockList])),
            authStateControllerProvider.overrideWith((ref) {
              return AuthStateController(ref, initialUserId: testUserId);
            }),
          ],
          child: testApp(const HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Should display all filter chips
      expect(find.byType(TemporalFilterChip), findsNWidgets(4));
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Lists'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('All filter is selected by default', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spacesControllerProvider.overrideWithValue(
              AsyncValue.data([mockSpace]),
            ),
            currentSpaceControllerProvider.overrideWithValue(
              AsyncValue.data(mockSpace),
            ),
            notesControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockNote])),
            todoListsControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockTodoList])),
            listsControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockList])),
            authStateControllerProvider.overrideWith((ref) {
              return AuthStateController(ref, initialUserId: testUserId);
            }),
          ],
          child: testApp(const HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Find the "All" filter chip
      final allChipFinder = find.ancestor(
        of: find.text('All'),
        matching: find.byType(TemporalFilterChip),
      );

      expect(allChipFinder, findsOneWidget);

      // Verify it's selected (by checking if the widget exists and is rendered)
      final allChip = tester.widget<TemporalFilterChip>(allChipFinder);
      expect(allChip.isSelected, isTrue);
    });

    testWidgets('can tap filter chips to change filter', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spacesControllerProvider.overrideWithValue(
              AsyncValue.data([mockSpace]),
            ),
            currentSpaceControllerProvider.overrideWithValue(
              AsyncValue.data(mockSpace),
            ),
            notesControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockNote])),
            todoListsControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockTodoList])),
            listsControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockList])),
            authStateControllerProvider.overrideWith((ref) {
              return AuthStateController(ref, initialUserId: testUserId);
            }),
          ],
          child: testApp(const HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the "Notes" filter chip
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      // Verify the "Notes" chip is now selected
      final notesChipFinder = find.ancestor(
        of: find.text('Notes'),
        matching: find.byType(TemporalFilterChip),
      );
      final notesChip = tester.widget<TemporalFilterChip>(notesChipFinder);
      expect(notesChip.isSelected, isTrue);
    });
  });

  group('HomeScreen Content Display', () {
    const testUserId = 'test-user-id';
    const testSpaceId = 'test-space-id';

    late Space mockSpace;
    late Note mockNote;
    late TodoList mockTodoList;
    late ListModel mockList;

    setUp(() {
      mockSpace = Space(
        id: testSpaceId,
        name: 'Test Space',
        userId: testUserId,
      );

      mockNote = Note(
        id: 'note-1',
        title: 'Test Note',
        content: 'Test content',
        spaceId: testSpaceId,
        userId: testUserId,
      );

      mockTodoList = TodoList(
        id: 'todo-1',
        spaceId: testSpaceId,
        userId: testUserId,
        name: 'Test Todo List',
        totalItemCount: 3,
        completedItemCount: 1,
      );

      mockList = ListModel(
        id: 'list-1',
        spaceId: testSpaceId,
        userId: testUserId,
        name: 'Test List',
        totalItemCount: 2,
      );
    });

    testWidgets('displays all content types when filter is "all"', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spacesControllerProvider.overrideWithValue(
              AsyncValue.data([mockSpace]),
            ),
            currentSpaceControllerProvider.overrideWithValue(
              AsyncValue.data(mockSpace),
            ),
            notesControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockNote])),
            todoListsControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockTodoList])),
            listsControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockList])),
            authStateControllerProvider.overrideWith((ref) {
              return AuthStateController(ref, initialUserId: testUserId);
            }),
          ],
          child: testApp(const HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Should display all 3 card types
      expect(find.byType(NoteCard), findsOneWidget);
      expect(find.byType(TodoListCard), findsOneWidget);
      expect(find.byType(ListCard), findsOneWidget);
    });

    testWidgets('displays only notes when filter is "notes"', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spacesControllerProvider.overrideWithValue(
              AsyncValue.data([mockSpace]),
            ),
            currentSpaceControllerProvider.overrideWithValue(
              AsyncValue.data(mockSpace),
            ),
            notesControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockNote])),
            todoListsControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockTodoList])),
            listsControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockList])),
            authStateControllerProvider.overrideWith((ref) {
              return AuthStateController(ref, initialUserId: testUserId);
            }),
          ],
          child: testApp(const HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the "Notes" filter
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      // Should display only notes
      expect(find.byType(NoteCard), findsOneWidget);
      expect(find.byType(TodoListCard), findsNothing);
      expect(find.byType(ListCard), findsNothing);
    });

    testWidgets('displays only todo lists when filter is "todoLists"', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spacesControllerProvider.overrideWithValue(
              AsyncValue.data([mockSpace]),
            ),
            currentSpaceControllerProvider.overrideWithValue(
              AsyncValue.data(mockSpace),
            ),
            notesControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockNote])),
            todoListsControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockTodoList])),
            listsControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockList])),
            authStateControllerProvider.overrideWith((ref) {
              return AuthStateController(ref, initialUserId: testUserId);
            }),
          ],
          child: testApp(const HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the "Tasks" filter
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      // Should display only todo lists
      expect(find.byType(NoteCard), findsNothing);
      expect(find.byType(TodoListCard), findsOneWidget);
      expect(find.byType(ListCard), findsNothing);
    });

    testWidgets('displays only lists when filter is "lists"', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spacesControllerProvider.overrideWithValue(
              AsyncValue.data([mockSpace]),
            ),
            currentSpaceControllerProvider.overrideWithValue(
              AsyncValue.data(mockSpace),
            ),
            notesControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockNote])),
            todoListsControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockTodoList])),
            listsControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockList])),
            authStateControllerProvider.overrideWith((ref) {
              return AuthStateController(ref, initialUserId: testUserId);
            }),
          ],
          child: testApp(const HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the "Lists" filter
      await tester.tap(find.text('Lists'));
      await tester.pumpAndSettle();

      // Should display only lists
      expect(find.byType(NoteCard), findsNothing);
      expect(find.byType(TodoListCard), findsNothing);
      expect(find.byType(ListCard), findsOneWidget);
    });
  });

  group('HomeScreen Loading States', () {
    const testUserId = 'test-user-id';
    const testSpaceId = 'test-space-id';

    late Space mockSpace;

    setUp(() {
      mockSpace = Space(
        id: testSpaceId,
        name: 'Test Space',
        userId: testUserId,
      );
    });

    testWidgets('shows loading indicator when content is loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spacesControllerProvider.overrideWithValue(
              AsyncValue.data([mockSpace]),
            ),
            currentSpaceControllerProvider.overrideWithValue(
              AsyncValue.data(mockSpace),
            ),
            notesControllerProvider(
              testSpaceId,
            ).overrideWithValue(const AsyncValue.loading()),
            todoListsControllerProvider(
              testSpaceId,
            ).overrideWithValue(const AsyncValue.loading()),
            listsControllerProvider(
              testSpaceId,
            ).overrideWithValue(const AsyncValue.loading()),
            authStateControllerProvider.overrideWith((ref) {
              return AuthStateController(ref, initialUserId: testUserId);
            }),
          ],
          child: testApp(const HomeScreen()),
        ),
      );

      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows content after loading completes', (tester) async {
      final mockNote = Note(
        id: 'note-1',
        title: 'Test Note',
        content: 'Test content',
        spaceId: testSpaceId,
        userId: testUserId,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spacesControllerProvider.overrideWithValue(
              AsyncValue.data([mockSpace]),
            ),
            currentSpaceControllerProvider.overrideWithValue(
              AsyncValue.data(mockSpace),
            ),
            notesControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockNote])),
            todoListsControllerProvider(
              testSpaceId,
            ).overrideWithValue(const AsyncValue.data([])),
            listsControllerProvider(
              testSpaceId,
            ).overrideWithValue(const AsyncValue.data([])),
            authStateControllerProvider.overrideWith((ref) {
              return AuthStateController(ref, initialUserId: testUserId);
            }),
          ],
          child: testApp(const HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Should show content
      expect(find.byType(NoteCard), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('HomeScreen Mixed Content', () {
    const testUserId = 'test-user-id';
    const testSpaceId = 'test-space-id';

    testWidgets('displays multiple items of mixed types in correct order', (
      tester,
    ) async {
      final mockSpace = Space(
        id: testSpaceId,
        name: 'Test Space',
        userId: testUserId,
      );

      final now = DateTime.now();

      // Create items with different timestamps
      final mockNote1 = Note(
        id: 'note-1',
        title: 'Recent Note',
        content: 'Content 1',
        spaceId: testSpaceId,
        userId: testUserId,
        updatedAt: now, // Most recent
      );

      final mockTodoList1 = TodoList(
        id: 'todo-1',
        spaceId: testSpaceId,
        userId: testUserId,
        name: 'Old Todo',
        totalItemCount: 3,
        completedItemCount: 1,
        updatedAt: now.subtract(const Duration(hours: 2)), // Oldest
      );

      final mockList1 = ListModel(
        id: 'list-1',
        spaceId: testSpaceId,
        userId: testUserId,
        name: 'Middle List',
        totalItemCount: 2,
        updatedAt: now.subtract(const Duration(hours: 1)), // Middle
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spacesControllerProvider.overrideWithValue(
              AsyncValue.data([mockSpace]),
            ),
            currentSpaceControllerProvider.overrideWithValue(
              AsyncValue.data(mockSpace),
            ),
            notesControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockNote1])),
            todoListsControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockTodoList1])),
            listsControllerProvider(
              testSpaceId,
            ).overrideWithValue(AsyncValue.data([mockList1])),
            authStateControllerProvider.overrideWith((ref) {
              return AuthStateController(ref, initialUserId: testUserId);
            }),
          ],
          child: testApp(const HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Find all cards using ReorderableListView
      final noteCardFinder = find.byType(NoteCard);
      final todoListCardFinder = find.byType(TodoListCard);
      final listCardFinder = find.byType(ListCard);

      // All cards should be present
      expect(noteCardFinder, findsOneWidget);
      expect(todoListCardFinder, findsOneWidget);
      expect(listCardFinder, findsOneWidget);

      // Verify order by checking vertical positions (most recent should be at top)
      final noteCardY = tester.getTopLeft(noteCardFinder).dy;
      final listCardY = tester.getTopLeft(listCardFinder).dy;
      final todoListCardY = tester.getTopLeft(todoListCardFinder).dy;

      // Note (most recent) should be at top
      expect(noteCardY < listCardY, isTrue);
      // List (middle) should be between note and todo
      expect(listCardY < todoListCardY, isTrue);
    });
  });
}
