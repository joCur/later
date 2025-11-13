# Riverpod Architecture Migration Plan

## Objective and Scope

Migrate the Later mobile app from Provider-based architecture to Feature-First Clean Architecture with Riverpod. This migration will:

- Replace Provider with Riverpod for state management and dependency injection
- Introduce clear architectural layers (Data, Domain, Application, Presentation)
- Organize code by features rather than layers
- Dramatically improve testability with pure Dart unit tests
- Achieve compile-time safety and eliminate runtime context errors
- Maintain 100% functional parity - zero UI/UX changes or business logic modifications
- Rewrite all tests to leverage improved testability
- Achieve zero analyzer errors, warnings, or informational messages

**Critical Constraint:** The app must work exactly as it currently does. This is a pure architectural refactor with no functional changes.

## Technical Approach and Reasoning

### Why Riverpod + Feature-First Clean Architecture?

Based on comprehensive research (see `.claude/research/flutter-architecture-patterns.md`), this approach was chosen because:

1. **Addresses Current Pain Points:**
   - Eliminates Provider's BuildContext dependency and runtime errors
   - Breaks up the monolithic 1200+ line ContentProvider god object
   - Separates business logic from state management
   - Enables pure Dart unit testing without widget test infrastructure

2. **Industry Best Practice (2025):**
   - Riverpod is the recommended modern solution by Flutter experts
   - Created by the same author as Provider, fixing its known issues
   - Feature-first organization is standard for scalable Flutter apps
   - Clean Architecture with four layers (Data, Domain, Application, Presentation) is industry standard

3. **Gradual Migration Path:**
   - Can migrate feature-by-feature (unlike BLoC)
   - Provider and Riverpod can coexist during migration
   - Lower risk than big-bang rewrites
   - Each phase can be validated independently

4. **Long-Term Benefits:**
   - 30-50% faster feature development after migration
   - Dramatically easier testing (pure Dart vs widget tests)
   - Better developer experience with compile-time safety
   - Scales from current 6 screens to 50+ screens

### Architectural Layers

Each feature will have four layers:

```
lib/features/{feature_name}/
├── domain/          # Pure Dart entities and business rules
│   └── models/      # Data models (Note, TodoList, etc.)
├── data/            # Data access and external dependencies
│   └── repositories/  # Repository implementations
├── application/     # Business logic and use cases
│   └── services/    # Service classes coordinating business logic
└── presentation/    # UI and state management
    ├── controllers/  # Riverpod controllers for UI state
    ├── screens/      # Screen widgets
    └── widgets/      # Feature-specific widgets
```

**Shared Code:**
- `lib/core/` - Framework-level concerns (theme, navigation, error handling)
- `lib/shared/` - Truly shared code (common widgets, utilities)
- `lib/design_system/` - Atomic Design components (unchanged)

### Testing Strategy

**Old Approach (Provider):**
```dart
testWidgets('test business logic', (tester) async {
  // Requires full widget tree with MultiProvider
  await tester.pumpWidget(
    MultiProvider(
      providers: [...],
      child: MaterialApp(home: MyScreen()),
    ),
  );
  // Test business logic mixed with UI
});
```

**New Approach (Riverpod):**
```dart
// Service unit tests (pure Dart, fast)
test('business logic test', () async {
  final mockRepo = MockRepository();
  final service = MyService(repository: mockRepo);

  final result = await service.doSomething();

  expect(result, expectedValue);
  verify(mockRepo.method(any)).called(1);
});

// Controller tests (with ProviderContainer)
test('controller test', () async {
  final container = ProviderContainer(
    overrides: [
      myServiceProvider.overrideWithValue(mockService),
    ],
  );

  final controller = container.read(myControllerProvider.notifier);
  await controller.performAction();

  expect(container.read(myControllerProvider).value, expectedState);
});

// Widget tests (minimal, focused on UI)
testWidgets('UI test', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        myControllerProvider.overrideWith((ref) => mockController),
      ],
      child: testApp(MyWidget()),
    ),
  );
  expect(find.text('Expected UI'), findsOneWidget);
});
```

**Test Migration Strategy:**
- Phase 1-7: Write new tests alongside migration (service tests, controller tests, minimal widget tests)
- Phase 8: Delete old Provider-based tests, verify 100% coverage maintained

### Code Generation

Riverpod uses code generation for optimal developer experience:

```dart
// Define provider with annotation
@riverpod
class TodoListController extends _$TodoListController {
  @override
  Future<List<TodoList>> build(String spaceId) async {
    final service = ref.watch(todoListServiceProvider);
    return service.getTodoListsForSpace(spaceId);
  }
}

// Generated code provides:
// - Auto-dispose
// - Type-safe provider access
// - Compile-time safety
```

Run `dart run build_runner watch` during development for automatic code generation.

## Implementation Phases

### Phase 0: Pre-Migration Setup (1 day)

**Goal:** Prepare infrastructure, add dependencies, verify baseline

- [ ] Task 0.1: Add Riverpod dependencies to pubspec.yaml
  - Add `flutter_riverpod: ^2.6.1`
  - Add `riverpod_annotation: ^2.6.1`
  - Add `riverpod_generator: ^2.6.1` to dev_dependencies
  - Add `riverpod_lint: ^2.6.1` to dev_dependencies
  - Keep `provider: ^6.1.0` temporarily for gradual migration
  - Run `flutter pub get`

- [ ] Task 0.2: Set up build_runner for code generation
  - Create `build.yaml` configuration file
  - Run `dart run build_runner build --delete-conflicting-outputs` to test setup
  - Document code generation commands in CLAUDE.md

- [ ] Task 0.3: Create baseline metrics
  - Run `flutter analyze` and save output (should be clean)
  - Run `flutter test` and record all test results
  - Run `flutter test --coverage` and save coverage report
  - Document current test count (200+ tests, >70% coverage)
  - Time a full app build (`flutter build apk --debug`)

- [ ] Task 0.4: Create migration documentation structure
  - Create `.claude/migration-log.md` to track decisions and learnings
  - Create `apps/later_mobile/ARCHITECTURE.md` skeleton
  - Document "before" architecture in ARCHITECTURE.md

- [ ] Task 0.5: Set up ProviderScope in main.dart
  - Wrap `MultiProvider` with `ProviderScope` (both can coexist)
  - Verify app still launches and works identically
  - Run `flutter analyze` (should be clean)
  - Run full test suite (should pass)

**Success Criteria:**
- All dependencies added, build_runner working
- Baseline metrics documented
- App launches with ProviderScope wrapping MultiProvider
- All existing tests pass
- Zero analyzer errors/warnings/info

**Risk: Very Low** - Pure additive changes, no breaking modifications

---

### Phase 1: Theme Migration (1 day)

**Goal:** Migrate simplest provider (ThemeProvider) to establish patterns and validate approach

- [ ] Task 1.1: Create feature structure for theme
  - Create `lib/features/theme/` directory
  - Create subdirectories: `presentation/controllers/`
  - Keep theme-related code in `lib/core/theme/` (framework-level concern)
  - Document decision in migration log

- [ ] Task 1.2: Create theme service provider
  - Create `lib/features/theme/application/theme_service.dart`
  - Extract business logic from ThemeProvider (load/save theme preference)
  - Create Riverpod provider: `themeServiceProvider`
  - Service should use existing SharedPreferences storage
  - Run `flutter analyze` after creation

- [ ] Task 1.3: Create theme controller with Riverpod
  - Create `lib/features/theme/presentation/controllers/theme_controller.dart`
  - Use `@riverpod` annotation for code generation
  - Controller manages ThemeMode state (light/dark/system)
  - Implement `toggleTheme()` method calling service
  - Run `dart run build_runner build --delete-conflicting-outputs`
  - Run `flutter analyze`

- [ ] Task 1.4: Update MyApp to use Riverpod theme controller
  - Replace `context.watch<ThemeProvider>()` with `ref.watch(themeControllerProvider)`
  - Convert MyApp to ConsumerWidget if needed
  - Keep ThemeProvider temporarily (don't delete yet)
  - Run app and verify theme switching works identically
  - Run `flutter analyze`

- [ ] Task 1.5: Write tests for theme service and controller
  - Create `test/features/theme/application/theme_service_test.dart`
  - Test load/save theme preference with mock SharedPreferences
  - Create `test/features/theme/presentation/controllers/theme_controller_test.dart`
  - Test theme state management with ProviderContainer
  - Create minimal widget test for theme switching UI
  - Delete old `test/providers/theme_provider_test.dart`
  - Run `flutter test` (all tests should pass)
  - Run `flutter test --coverage` (coverage should be maintained or improved)

- [ ] Task 1.6: Update Riverpod test helpers
  - Create `test/helpers/riverpod_test_helpers.dart`
  - Add `createContainer()` helper for creating ProviderContainer with overrides
  - Add `testAppWithProviders()` helper extending existing testApp()
  - Document patterns in test helper file

**Success Criteria:**
- Theme switching works identically to before
- Theme service has 100% pure Dart unit test coverage
- Theme controller has ProviderContainer-based tests
- Old ThemeProvider still exists but unused
- All tests pass
- Zero analyzer errors/warnings/info

**Risk: Low** - Simple provider with minimal dependencies

---

### Phase 2: Auth Migration (2 days)

**Goal:** Migrate authentication feature with service layer pattern

- [ ] Task 2.1: Create auth feature structure
  - Create `lib/features/auth/` directory
  - Create subdirectories: `domain/models/`, `data/services/`, `application/`, `presentation/controllers/`
  - Move `lib/data/services/auth_service.dart` to `lib/features/auth/data/services/`
  - Update imports throughout codebase
  - Run `flutter analyze`

- [ ] Task 2.2: Create auth repository provider
  - AuthService currently wraps Supabase directly
  - Create `authServiceProvider` (Provider, not StateNotifier)
  - Provider should return singleton AuthService instance
  - Run `flutter analyze`

- [ ] Task 2.3: Create auth application service
  - Create `lib/features/auth/application/auth_application_service.dart`
  - Extract business logic from AuthProvider (validation, error mapping)
  - Methods: `signIn(email, password)`, `signUp(email, password)`, `signOut()`, `checkAuthStatus()`
  - Service calls AuthService (data layer) and applies business rules
  - Handle error mapping from SupabaseException to AppError
  - Run `flutter analyze`

- [ ] Task 2.4: Create auth state controller
  - Create `lib/features/auth/presentation/controllers/auth_state_controller.dart`
  - Use `@riverpod` annotation
  - Controller manages AsyncValue<User?> state
  - Methods: `signIn()`, `signUp()`, `signOut()`, `initialize()`
  - Run `dart run build_runner build --delete-conflicting-outputs`
  - Run `flutter analyze`

- [ ] Task 2.5: Update auth screens to use Riverpod
  - Update `SignInScreen` to use ConsumerWidget
  - Replace `context.read<AuthProvider>()` with `ref.read(authStateControllerProvider.notifier)`
  - Update `SignUpScreen` similarly
  - Update `AuthGate` widget to watch auth state
  - Keep AuthProvider temporarily
  - Run app and verify sign-in/sign-up/sign-out works identically
  - Run `flutter analyze`

- [ ] Task 2.6: Write comprehensive auth tests
  - Create `test/features/auth/application/auth_application_service_test.dart`
  - Test sign-in/sign-up/sign-out business logic with mocked AuthService
  - Test error mapping (invalid credentials, weak password, network errors)
  - Create `test/features/auth/presentation/controllers/auth_state_controller_test.dart`
  - Test auth state transitions with ProviderContainer
  - Test AsyncValue states (loading, data, error)
  - Create minimal widget tests for SignInScreen/SignUpScreen (UI only)
  - Delete old `test/providers/auth_provider_test.dart`
  - Run `flutter test`
  - Run `flutter test --coverage`

**Success Criteria:**
- Authentication flows work identically (sign-in, sign-up, sign-out)
- Auth application service has 100% unit test coverage
- Auth state controller has comprehensive tests with AsyncValue validation
- Old AuthProvider still exists but unused
- All tests pass
- Zero analyzer errors/warnings/info

**Risk: Medium** - Authentication is critical, requires careful migration and comprehensive testing

---

### Phase 3: Spaces Feature Migration (2 days)

**Goal:** Migrate spaces feature, establishing full feature-first pattern with all four layers

- [ ] Task 3.1: Create spaces feature structure
  - Create `lib/features/spaces/` directory
  - Create subdirectories: `domain/models/`, `data/repositories/`, `application/services/`, `presentation/controllers/`, `presentation/widgets/`
  - Move `lib/data/models/space.dart` to `lib/features/spaces/domain/models/`
  - Move `lib/data/repositories/space_repository.dart` to `lib/features/spaces/data/repositories/`
  - Update all imports throughout codebase
  - Run `flutter analyze`

- [ ] Task 3.2: Create spaces repository provider
  - Create `spaceRepositoryProvider` in `lib/features/spaces/data/repositories/providers.dart`
  - Provider returns singleton SpaceRepository instance
  - Repository depends on Supabase client (from core/config)
  - Run `flutter analyze`

- [ ] Task 3.3: Create spaces service (application layer)
  - Create `lib/features/spaces/application/services/space_service.dart`
  - Extract business logic from SpacesProvider:
    - `loadSpaces()` - get user's spaces, apply sorting
    - `createSpace(Space)` - validate name, create space, return created
    - `updateSpace(Space)` - validate, update, refresh current space if needed
    - `deleteSpace(String id)` - validate not deleting active space, delete, switch to remaining space
    - `archiveSpace(String id)` / `unarchiveSpace(String id)` - toggle archive status
  - Service coordinates with SpaceRepository
  - Handle error mapping
  - Run `flutter analyze`

- [ ] Task 3.4: Create spaces state controller
  - Create `lib/features/spaces/presentation/controllers/spaces_controller.dart`
  - Use `@riverpod` annotation for code generation
  - Controller manages AsyncValue<List<Space>> for all spaces
  - Controller manages current space selection
  - Methods: `loadSpaces()`, `createSpace()`, `updateSpace()`, `deleteSpace()`, `setCurrentSpace()`, `archiveSpace()`, `unarchiveSpace()`
  - Run `dart run build_runner build --delete-conflicting-outputs`
  - Run `flutter analyze`

- [ ] Task 3.5: Create current space controller
  - Create `lib/features/spaces/presentation/controllers/current_space_controller.dart`
  - Separate controller for current space selection (single source of truth)
  - Use `@riverpod` annotation
  - Controller manages AsyncValue<Space?> for active space
  - Persists to SharedPreferences
  - Run `dart run build_runner build --delete-conflicting-outputs`
  - Run `flutter analyze`

- [ ] Task 3.6: Update space-related widgets to use Riverpod
  - Update space switcher modal widgets to use ConsumerWidget
  - Replace `context.watch<SpacesProvider>()` with `ref.watch(spacesControllerProvider)`
  - Update create space modal
  - Update edit space modal
  - Update delete confirmation dialog
  - Keep SpacesProvider temporarily
  - Run app and verify space CRUD works identically (create, switch, edit, delete, archive)
  - Test space item count loading (uses FutureBuilder)
  - Run `flutter analyze`

- [ ] Task 3.7: Write comprehensive spaces tests
  - Create `test/features/spaces/application/services/space_service_test.dart`
  - Test business logic: validation, sorting, active space switching on delete
  - Mock SpaceRepository
  - Create `test/features/spaces/presentation/controllers/spaces_controller_test.dart`
  - Test state management with ProviderContainer
  - Test AsyncValue error states
  - Create `test/features/spaces/presentation/controllers/current_space_controller_test.dart`
  - Test current space selection and persistence
  - Create minimal widget tests for space modals (UI only)
  - Delete old `test/providers/spaces_provider_test.dart`
  - Run `flutter test`
  - Run `flutter test --coverage`

**Success Criteria:**
- Space CRUD operations work identically (create, read, update, delete, archive)
- Space switching works
- Space service has 100% unit test coverage
- Controllers have comprehensive ProviderContainer tests
- Old SpacesProvider still exists but unused
- All tests pass
- Zero analyzer errors/warnings/info

**Risk: Medium** - Spaces are central to app, many UI touchpoints, current space selection is complex

---

### Phase 4: Notes Feature Migration (2 days)

**Goal:** Migrate notes feature following established pattern

- [ ] Task 4.1: Create notes feature structure
  - Create `lib/features/notes/` directory
  - Create subdirectories: `domain/models/`, `data/repositories/`, `application/services/`, `presentation/controllers/`, `presentation/widgets/`, `presentation/screens/`
  - Move `lib/data/models/note.dart` to `lib/features/notes/domain/models/`
  - Move `lib/data/repositories/note_repository.dart` to `lib/features/notes/data/repositories/`
  - Update all imports
  - Run `flutter analyze`

- [ ] Task 4.2: Create note repository provider
  - Create `noteRepositoryProvider` in `lib/features/notes/data/repositories/providers.dart`
  - Run `flutter analyze`

- [ ] Task 4.3: Create note service (application layer)
  - Create `lib/features/notes/application/services/note_service.dart`
  - Extract business logic from ContentProvider for notes:
    - `getNotesForSpace(String spaceId)` - load, sort by updatedAt
    - `createNote(Note)` - validate, create, return created
    - `updateNote(Note)` - validate, update
    - `deleteNote(String id)` - delete
    - `toggleFavorite(String id)` - toggle favorite status
    - `archiveNote(String id)` / `unarchiveNote(String id)` - toggle archive
  - Service coordinates with NoteRepository
  - Run `flutter analyze`

- [ ] Task 4.4: Create notes controller
  - Create `lib/features/notes/presentation/controllers/notes_controller.dart`
  - Use `@riverpod` annotation with family modifier: `notesController(String spaceId)`
  - Controller manages AsyncValue<List<Note>> for space
  - Methods: `createNote()`, `updateNote()`, `deleteNote()`, `toggleFavorite()`, `archiveNote()`
  - Run `dart run build_runner build --delete-conflicting-outputs`
  - Run `flutter analyze`

- [ ] Task 4.5: Update note-related screens and widgets
  - Move `lib/widgets/screens/note_detail_screen.dart` to `lib/features/notes/presentation/screens/`
  - Update NoteDetailScreen to use ConsumerStatefulWidget (for auto-save)
  - Replace `context.watch<ContentProvider>()` with `ref.watch(notesControllerProvider(spaceId))`
  - Update NoteCard widget to use ConsumerWidget
  - Update note-related modals and widgets
  - Keep ContentProvider temporarily (for other content types)
  - Run app and verify note CRUD works identically (create, read, update, delete, favorite, archive)
  - Test note detail screen auto-save (AutoSaveMixin integration)
  - Test QuickCapture note creation
  - Run `flutter analyze`

- [ ] Task 4.6: Write comprehensive note tests
  - Create `test/features/notes/application/services/note_service_test.dart`
  - Test business logic with mocked repository
  - Create `test/features/notes/presentation/controllers/notes_controller_test.dart`
  - Test state management with ProviderContainer
  - Create widget tests for NoteDetailScreen (minimal, focus on auto-save behavior)
  - Delete note-related tests from old `test/providers/content_provider_test.dart` (keep file for other content types)
  - Run `flutter test`
  - Run `flutter test --coverage`

**Success Criteria:**
- Note CRUD works identically (create, read, update, delete, favorite, archive)
- Note detail screen auto-save works
- QuickCapture note creation works
- Note service has 100% unit test coverage
- Controller has comprehensive tests
- ContentProvider still exists for TodoLists and Lists
- All tests pass
- Zero analyzer errors/warnings/info

**Risk: Low** - Following established pattern from spaces

---

### Phase 5: TodoLists Feature Migration (3 days)

**Goal:** Migrate todo lists with nested todo items, handle complex caching logic

- [ ] Task 5.1: Create todo lists feature structure
  - Create `lib/features/todo_lists/` directory
  - Create subdirectories: `domain/models/`, `data/repositories/`, `application/services/`, `presentation/controllers/`, `presentation/widgets/`, `presentation/screens/`
  - Move `lib/data/models/todo_list.dart` and `todo_item.dart` to `lib/features/todo_lists/domain/models/`
  - Move `lib/data/repositories/todo_list_repository.dart` to `lib/features/todo_lists/data/repositories/`
  - Update all imports
  - Run `flutter analyze`

- [ ] Task 5.2: Create repository providers
  - Create `todoListRepositoryProvider` in `lib/features/todo_lists/data/repositories/providers.dart`
  - Repository already handles both TodoList and TodoItem operations
  - Run `flutter analyze`

- [ ] Task 5.3: Create todo list service (application layer)
  - Create `lib/features/todo_lists/application/services/todo_list_service.dart`
  - Extract business logic from ContentProvider for todo lists:
    - `getTodoListsForSpace(String spaceId)` - load lists, sort by sortOrder
    - `createTodoList(TodoList)` - validate, create, return with item counts
    - `updateTodoList(TodoList)` - validate, update
    - `deleteTodoList(String id)` - delete list and all items
    - `reorderTodoLists(String spaceId, List<String> orderedIds)` - update sort orders
  - Methods for todo items:
    - `getTodoItemsForList(String listId)` - load items, sort by sortOrder
    - `createTodoItem(TodoItem)` - validate, create, update list counts
    - `updateTodoItem(TodoItem)` - validate, update, recalculate counts if completion changed
    - `deleteTodoItem(String id)` - delete, update list counts
    - `toggleTodoItem(String id)` - toggle completed status, update counts
    - `reorderTodoItems(String listId, List<String> orderedIds)` - update sort orders
  - Service coordinates with TodoListRepository
  - Business logic: aggregate count calculation, sort order management
  - Run `flutter analyze`

- [ ] Task 5.4: Create todo lists controller
  - Create `lib/features/todo_lists/presentation/controllers/todo_lists_controller.dart`
  - Use `@riverpod` annotation with family: `todoListsController(String spaceId)`
  - Controller manages AsyncValue<List<TodoList>> for space
  - Methods: `createTodoList()`, `updateTodoList()`, `deleteTodoList()`, `reorderLists()`
  - Run `dart run build_runner build --delete-conflicting-outputs`
  - Run `flutter analyze`

- [ ] Task 5.5: Create todo items controller (for detail screen)
  - Create `lib/features/todo_lists/presentation/controllers/todo_items_controller.dart`
  - Use `@riverpod` annotation with family: `todoItemsController(String listId)`
  - Controller manages AsyncValue<List<TodoItem>> for list
  - Methods: `createItem()`, `updateItem()`, `deleteItem()`, `toggleItem()`, `reorderItems()`
  - Controller invalidates parent list controller when counts change
  - Run `dart run build_runner build --delete-conflicting-outputs`
  - Run `flutter analyze`

- [ ] Task 5.6: Update todo list screens and widgets
  - Move `lib/widgets/screens/todo_list_detail_screen.dart` to `lib/features/todo_lists/presentation/screens/`
  - Update TodoListDetailScreen to use ConsumerStatefulWidget
  - Replace ContentProvider access with Riverpod controllers
  - Use `ref.watch(todoListsControllerProvider(spaceId))` for list data
  - Use `ref.watch(todoItemsControllerProvider(listId))` for items in detail screen
  - Update TodoListCard to use ConsumerWidget
  - Update create/edit modals
  - Keep ContentProvider temporarily (for Lists)
  - Run app and verify todo list functionality:
    - Create/edit/delete todo lists
    - Create/edit/delete/toggle todo items
    - Progress percentage calculation
    - Reordering lists and items
    - QuickCapture todo creation
  - Run `flutter analyze`

- [ ] Task 5.7: Write comprehensive todo list tests
  - Create `test/features/todo_lists/application/services/todo_list_service_test.dart`
  - Test business logic: count calculation, reordering, validation
  - Mock TodoListRepository
  - Create `test/features/todo_lists/presentation/controllers/todo_lists_controller_test.dart`
  - Test list state management
  - Create `test/features/todo_lists/presentation/controllers/todo_items_controller_test.dart`
  - Test item state management, count updates, toggle behavior
  - Test controller invalidation when items change
  - Create widget tests for TodoListDetailScreen (minimal)
  - Delete todo-related tests from old `test/providers/content_provider_test.dart` (keep file for Lists)
  - Run `flutter test`
  - Run `flutter test --coverage`

**Success Criteria:**
- TodoList CRUD works identically
- TodoItem CRUD works identically
- Item toggling and progress calculation works
- Reordering lists and items works
- QuickCapture todo creation works
- Service has 100% unit test coverage
- Controllers have comprehensive tests with count update validation
- ContentProvider still exists for Lists
- All tests pass
- Zero analyzer errors/warnings/info

**Risk: Medium** - Complex nested state, count aggregation, cache invalidation logic

---

### Phase 6: Lists Feature Migration (2 days)

**Goal:** Complete content migration with custom lists (similar to TodoLists)

- [ ] Task 6.1: Create lists feature structure
  - Create `lib/features/lists/` directory
  - Create subdirectories: `domain/models/`, `data/repositories/`, `application/services/`, `presentation/controllers/`, `presentation/widgets/`, `presentation/screens/`
  - Move `lib/data/models/list_model.dart` and `list_item.dart` to `lib/features/lists/domain/models/`
  - Move `lib/data/repositories/list_repository.dart` to `lib/features/lists/data/repositories/`
  - Update all imports
  - Run `flutter analyze`

- [ ] Task 6.2: Create repository provider
  - Create `listRepositoryProvider` in `lib/features/lists/data/repositories/providers.dart`
  - Run `flutter analyze`

- [ ] Task 6.3: Create list service (application layer)
  - Create `lib/features/lists/application/services/list_service.dart`
  - Extract business logic from ContentProvider for lists:
    - `getListsForSpace(String spaceId)` - load lists, sort by sortOrder
    - `createList(ListModel)` - validate, create with style
    - `updateList(ListModel)` - validate, update
    - `deleteList(String id)` - delete list and items
    - `reorderLists(String spaceId, List<String> orderedIds)` - update sort orders
  - Methods for list items:
    - `getListItemsForList(String listId)` - load items, sort by sortOrder
    - `createListItem(ListItem)` - validate, create, update counts if checklist
    - `updateListItem(ListItem)` - validate, update, recalculate counts if checked status changed
    - `deleteListItem(String id)` - delete, update counts
    - `toggleListItem(String id)` - toggle checked status, update counts (checklist style only)
    - `reorderListItems(String listId, List<String> orderedIds)` - update sort orders
  - Business logic: checkedItemCount calculation for checklist style
  - Run `flutter analyze`

- [ ] Task 6.4: Create lists controller
  - Create `lib/features/lists/presentation/controllers/lists_controller.dart`
  - Use `@riverpod` annotation with family: `listsController(String spaceId)`
  - Controller manages AsyncValue<List<ListModel>> for space
  - Methods: `createList()`, `updateList()`, `deleteList()`, `reorderLists()`
  - Run `dart run build_runner build --delete-conflicting-outputs`
  - Run `flutter analyze`

- [ ] Task 6.5: Create list items controller
  - Create `lib/features/lists/presentation/controllers/list_items_controller.dart`
  - Use `@riverpod` annotation with family: `listItemsController(String listId)`
  - Controller manages AsyncValue<List<ListItem>> for list
  - Methods: `createItem()`, `updateItem()`, `deleteItem()`, `toggleItem()`, `reorderItems()`
  - Controller invalidates parent list controller when counts change
  - Run `dart run build_runner build --delete-conflicting-outputs`
  - Run `flutter analyze`

- [ ] Task 6.6: Update list screens and widgets
  - Move `lib/widgets/screens/list_detail_screen.dart` to `lib/features/lists/presentation/screens/`
  - Update ListDetailScreen to use ConsumerStatefulWidget (for auto-save)
  - Replace ContentProvider access with Riverpod controllers
  - Update ListCard to use ConsumerWidget
  - Update create/edit modals
  - Run app and verify list functionality:
    - Create/edit/delete lists with different styles (simple, checklist, numbered, bullet)
    - Create/edit/delete/toggle list items
    - Checked item count for checklists
    - Reordering lists and items
    - QuickCapture list creation
    - Auto-save in detail screen
  - Run `flutter analyze`

- [ ] Task 6.7: Write comprehensive list tests
  - Create `test/features/lists/application/services/list_service_test.dart`
  - Test business logic: checklist count calculation, reordering, style handling
  - Create `test/features/lists/presentation/controllers/lists_controller_test.dart`
  - Test list state management
  - Create `test/features/lists/presentation/controllers/list_items_controller_test.dart`
  - Test item state management, checklist toggle, count updates
  - Create widget tests for ListDetailScreen (minimal, focus on style rendering)
  - Delete remaining list-related tests from old `test/providers/content_provider_test.dart`
  - ContentProvider can now be completely removed
  - Run `flutter test`
  - Run `flutter test --coverage`

**Success Criteria:**
- List CRUD works identically with all styles (simple, checklist, numbered, bullet)
- ListItem CRUD works identically
- Checklist toggling and count calculation works
- Reordering lists and items works
- QuickCapture list creation works
- Service has 100% unit test coverage
- Controllers have comprehensive tests
- Old ContentProvider is now unused and can be deleted
- All tests pass
- Zero analyzer errors/warnings/info

**Risk: Low** - Similar pattern to TodoLists, well-established by this phase

---

### Phase 7: Home Screen & Cross-Feature Integration (3 days)

**Goal:** Migrate home screen to use all Riverpod controllers, integrate features, migrate remaining screens/widgets

- [ ] Task 7.1: Create home feature structure
  - Create `lib/features/home/` directory
  - Create subdirectories: `presentation/screens/`, `presentation/widgets/`
  - Move `lib/widgets/screens/home_screen.dart` to `lib/features/home/presentation/screens/`
  - Identify home-specific widgets and move them
  - Run `flutter analyze`

- [ ] Task 7.2: Update home screen to use Riverpod controllers
  - Update HomeScreen to use ConsumerStatefulWidget
  - Replace all ContentProvider and SpacesProvider access with Riverpod controllers:
    - Use `ref.watch(currentSpaceControllerProvider)` for active space
    - Use `ref.watch(notesControllerProvider(spaceId))` for notes
    - Use `ref.watch(todoListsControllerProvider(spaceId))` for todo lists
    - Use `ref.watch(listsControllerProvider(spaceId))` for lists
  - Update data loading logic in `_loadData()` method
  - Handle AsyncValue states (loading, error, data) for each content type
  - Run app and verify home screen displays all content correctly
  - Test pull-to-refresh
  - Test filtering by content type
  - Run `flutter analyze`

- [ ] Task 7.3: Create unified content search/filter controller
  - Create `lib/features/home/presentation/controllers/content_filter_controller.dart`
  - Use `@riverpod` annotation
  - Controller manages filter state (all, notes, todos, lists)
  - Controller manages search query
  - Provide filtered/searched content from multiple controllers
  - Run `dart run build_runner build --delete-conflicting-outputs`
  - Run `flutter analyze`

- [ ] Task 7.4: Update QuickCapture modal to use Riverpod
  - QuickCapture modal uses item type detection
  - Update modal to use ConsumerStatefulWidget
  - Replace ContentProvider calls with appropriate feature controllers based on detected type
  - Use `ref.read(notesControllerProvider(spaceId).notifier).createNote()` for notes
  - Use `ref.read(todoListsControllerProvider(spaceId).notifier).createTodoList()` for todos
  - Use `ref.read(listsControllerProvider(spaceId).notifier).createList()` for lists
  - Run app and verify QuickCapture works for all types
  - Test type detection algorithm
  - Run `flutter analyze`

- [ ] Task 7.5: Update navigation and remaining screens
  - Update BottomNavigationBar widget if it depends on Provider
  - Update any remaining widgets in `lib/widgets/` that use Provider
  - Check for any modals or dialogs still using Provider
  - Update sidebar widgets if applicable
  - Run full app navigation flow test
  - Run `flutter analyze`

- [ ] Task 7.6: Implement pagination with Riverpod
  - ContentProvider has `loadMoreItems()` for pagination
  - Update each feature controller to support pagination:
    - Add pagination state to controllers
    - Implement `loadMore()` method
    - Use Riverpod's `family` with pagination parameters
  - Test pagination on home screen (scroll to load more)
  - Run `flutter analyze`

- [ ] Task 7.7: Write home screen and integration tests
  - Create `test/features/home/presentation/screens/home_screen_test.dart`
  - Widget test: Verify home screen renders all content types
  - Widget test: Verify loading states
  - Widget test: Verify error states
  - Widget test: Verify pull-to-refresh
  - Create `test/features/home/presentation/controllers/content_filter_controller_test.dart`
  - Test filtering logic with ProviderContainer
  - Test search logic
  - Create integration test: Full flow from launch to content creation
  - Run `flutter test`
  - Run `flutter test --coverage`

**Success Criteria:**
- Home screen displays all content types identically
- Filtering by type works
- Search functionality works
- Pull-to-refresh works
- Pagination works
- QuickCapture works for all detected types
- All navigation flows work
- All screens migrated to Riverpod
- Home integration tests pass
- All tests pass
- Zero analyzer errors/warnings/info

**Risk: Medium** - Home screen is complex, integrates all features, high user visibility

---

### Phase 8: Cleanup, Optimization & Documentation (2 days)

**Goal:** Remove all Provider code, optimize Riverpod usage, finalize tests, complete documentation

- [ ] Task 8.1: Remove Provider dependencies and old code
  - Delete old provider files:
    - `lib/providers/content_provider.dart`
    - `lib/providers/spaces_provider.dart`
    - `lib/providers/auth_provider.dart`
    - `lib/providers/theme_provider.dart`
  - Remove `provider: ^6.1.0` from `pubspec.yaml`
  - Remove `MultiProvider` wrapper from `main.dart` (keep only `ProviderScope`)
  - Run `flutter pub get`
  - Run `flutter analyze` (should be clean)

- [ ] Task 8.2: Delete old Provider tests
  - Delete `test/providers/` directory entirely
  - Verify all functionality is covered by new feature tests
  - Run `flutter test`
  - Run `flutter test --coverage`
  - Verify coverage is maintained or improved (target: 80%+)

- [ ] Task 8.3: Optimize Riverpod usage
  - Review all controllers for proper `.select()` usage (fine-grained reactivity)
  - Add `@riverpod(keepAlive: true)` where appropriate (repositories, services)
  - Add `autoDispose` modifiers where appropriate (feature controllers)
  - Review provider dependencies and ensure proper invalidation
  - Test for memory leaks (use DevTools)
  - Run app and verify performance hasn't regressed
  - Run `flutter analyze`

- [ ] Task 8.4: Optimize test performance
  - Identify slow tests (widget tests with full widget trees)
  - Convert to faster unit tests where possible
  - Add test groups for better organization
  - Run `flutter test` and measure total test time
  - Compare to baseline from Phase 0 (should be faster due to more unit tests)

- [ ] Task 8.5: Complete ARCHITECTURE.md documentation
  - Document architectural layers (Data, Domain, Application, Presentation)
  - Document feature-first organization principles
  - Document Riverpod provider patterns:
    - Repository providers (singleton)
    - Service providers (singleton)
    - Controller providers (auto-dispose with family)
    - State providers for simple state
  - Document testing strategies:
    - Pure Dart unit tests for services
    - ProviderContainer tests for controllers
    - Minimal widget tests for UI
  - Document code generation workflow
  - Add architecture diagrams (text-based)
  - Add examples of each pattern

- [ ] Task 8.6: Update CLAUDE.md with new architecture
  - Update "Architecture & Key Concepts" section
  - Replace Provider patterns with Riverpod patterns
  - Update state management section
  - Update testing section with new patterns
  - Add section on feature-first organization
  - Update code examples throughout
  - Document Riverpod-specific commands

- [ ] Task 8.7: Create migration retrospective document
  - Create `.claude/migration-retrospective.md`
  - Document what went well
  - Document challenges encountered
  - Document lessons learned
  - Document time estimates vs actuals
  - Provide recommendations for future migrations

- [ ] Task 8.8: Final validation and metrics
  - Run `flutter analyze` (must be completely clean)
  - Run `flutter test` (all tests must pass)
  - Run `flutter test --coverage` (verify ≥80% coverage)
  - Run full manual app test:
    - Authentication flow (sign-in, sign-up, sign-out)
    - Space management (create, switch, edit, delete, archive)
    - Notes (create, edit, delete, favorite, archive, auto-save)
    - TodoLists (create, edit, delete, toggle items, reorder)
    - Lists (create, edit, delete, all styles, toggle checklist items, reorder)
    - Home screen (filtering, search, pagination)
    - QuickCapture (all types)
    - Theme switching
  - Time a full app build and compare to baseline
  - Measure app performance on key screens (DevTools)
  - Document final metrics in migration retrospective

**Success Criteria:**
- Zero Provider code remains in codebase
- Zero analyzer errors/warnings/info
- All tests pass (≥80% coverage target achieved)
- ARCHITECTURE.md complete and comprehensive
- CLAUDE.md updated with Riverpod patterns
- Migration retrospective completed
- App functions identically to before migration
- Performance metrics meet or exceed baseline

**Risk: Low** - Cleanup phase, all functionality already migrated and tested

---

## Dependencies and Prerequisites

### Required Dependencies

**New dependencies (add in Phase 0):**
```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

dev_dependencies:
  riverpod_generator: ^2.6.1
  riverpod_lint: ^2.6.1
  build_runner: ^2.10.1  # Already exists
```

**Keep during migration (remove in Phase 8):**
```yaml
dependencies:
  provider: ^6.1.0  # Coexists with Riverpod during migration
```

### Existing Dependencies (No Changes)

All current dependencies remain:
- `supabase_flutter: ^2.10.3` - Data layer unchanged
- `shared_preferences: ^2.2.2` - Local storage unchanged
- `mockito: ^5.5.1` - Test mocking unchanged
- All design system dependencies (flutter_animate, google_fonts, etc.)

### Prerequisites

1. **Baseline Metrics:**
   - Current test results captured
   - Current coverage report saved
   - Current build times documented
   - Current analyzer output captured

2. **Code Generation Setup:**
   - build_runner configured
   - Developers familiar with code generation workflow
   - `.dart_tool/` in .gitignore

3. **Testing Infrastructure:**
   - Test helpers updated for Riverpod
   - ProviderContainer test utilities created
   - Mock patterns documented

4. **Developer Knowledge:**
   - Team familiar with Riverpod concepts (providers, refs, notifiers)
   - Team understands Clean Architecture layers
   - Team understands feature-first organization
   - Code review checklist for Riverpod patterns created

## Challenges and Considerations

### Technical Challenges

1. **Breaking Up ContentProvider God Object:**
   - ContentProvider is 1200+ lines managing 3 content types + nested items
   - **Mitigation:** Carefully extract business logic into feature services one content type at a time
   - **Approach:** Phases 4-6 tackle this incrementally (Notes → TodoLists → Lists)

2. **Nested State Management (TodoItems, ListItems):**
   - Current approach uses manual cache invalidation
   - **Mitigation:** Use Riverpod's invalidation and family modifiers
   - **Approach:** Separate controllers for parent (list) and children (items), with explicit invalidation on mutations

3. **Current Space Selection Persistence:**
   - SpacesProvider manages both all spaces and current space
   - Current space must persist across app restarts
   - **Mitigation:** Create separate controller for current space with SharedPreferences integration
   - **Approach:** `currentSpaceController` manages single source of truth, separate from `spacesController`

4. **AsyncValue Error Handling:**
   - Current Provider error handling uses nullable `AppError? _error`
   - Riverpod uses `AsyncValue.error()` which has different semantics
   - **Mitigation:** Ensure error mappers work with AsyncValue, test error states comprehensively
   - **Approach:** Service layer throws AppError, controller catches and wraps in AsyncValue.error()

5. **QuickCapture Type Detection:**
   - QuickCapture uses ItemTypeDetector to determine content type
   - Must route to correct controller based on detection
   - **Mitigation:** Type detection logic unchanged, only controller routing changes
   - **Approach:** Switch statement calling appropriate controller method based on detected type

6. **Item Count Aggregation:**
   - TodoList and ListModel have aggregate count fields (totalItemCount, completedItemCount)
   - Counts must update when items change
   - **Mitigation:** Service layer handles count calculation, controller invalidates parent on item changes
   - **Approach:** Item mutations trigger parent list controller refresh to recalculate counts

7. **Code Generation Overhead:**
   - Build runner adds 5-10s to build times
   - Developers must remember to run build_runner
   - **Mitigation:** Document workflow clearly, use `build_runner watch` during development
   - **Approach:** Add to CLAUDE.md, create IDE shortcuts, add to PR checklist

### Testing Challenges

1. **Test Rewrite Scope:**
   - 200+ tests need rewriting or replacement
   - Must maintain coverage throughout migration
   - **Mitigation:** Write new tests alongside migration, delete old tests only when feature complete
   - **Approach:** Each phase includes comprehensive test task before moving to next phase

2. **ProviderContainer Learning Curve:**
   - Team unfamiliar with ProviderContainer testing
   - Different pattern from widget-based Provider tests
   - **Mitigation:** Create test helpers and examples early (Phase 1)
   - **Approach:** Document patterns in `test/helpers/riverpod_test_helpers.dart` with examples

3. **Widget Test Complexity:**
   - Some widget tests currently test business logic (anti-pattern)
   - Need to separate business logic tests (services) from UI tests (widgets)
   - **Mitigation:** Identify business logic in widget tests, extract to service tests
   - **Approach:** Service tests are pure Dart unit tests, widget tests focus only on rendering and interactions

4. **Integration Test Coverage:**
   - Home screen integration test needs to mock multiple controllers
   - Complex setup with ProviderScope overrides
   - **Mitigation:** Create integration test helpers for multi-controller scenarios
   - **Approach:** Phase 7 includes comprehensive integration test patterns

### Migration Challenges

1. **Feature Interdependencies:**
   - Home screen depends on all content features (Notes, TodoLists, Lists)
   - Cannot fully migrate home screen until all content features complete
   - **Mitigation:** Migrate home screen last (Phase 7), keep ContentProvider for unmigrated types
   - **Approach:** Phases 4-6 are order-dependent, must complete in sequence

2. **Maintaining App Functionality:**
   - App must remain functional throughout migration
   - No broken states between phases
   - **Mitigation:** Provider and Riverpod coexist, each phase leaves app in working state
   - **Approach:** Each phase ends with full manual app test and analyzer verification

3. **Import Refactoring:**
   - Moving models and repositories changes imports throughout codebase
   - Risk of missing imports or broken references
   - **Mitigation:** Use IDE refactoring tools, run analyzer after each move
   - **Approach:** Each structural change immediately followed by `flutter analyze`

4. **Rollback Strategy:**
   - If a phase fails or introduces critical bugs, need rollback plan
   - **Mitigation:** Each phase is a separate Git commit (or set of commits)
   - **Approach:** Can revert phase commits without losing earlier work, Provider still exists as fallback

### Organizational Challenges

1. **Developer Availability:**
   - Estimated 4-5 weeks assumes 1 full-time developer
   - Interruptions or context switching will extend timeline
   - **Mitigation:** Block dedicated time for migration, minimize interruptions
   - **Approach:** Communicate timeline and importance to stakeholders, protect developer time

2. **Code Review Capacity:**
   - Large PRs are difficult to review effectively
   - **Mitigation:** Break each phase into multiple smaller PRs
   - **Approach:** PR per feature (e.g., "Migrate Theme to Riverpod", "Migrate Spaces to Riverpod")

3. **Knowledge Transfer:**
   - Team needs to understand new architecture
   - Documentation must be comprehensive
   - **Mitigation:** Update documentation as you go, don't leave to end
   - **Approach:** Each phase updates relevant docs, final phase consolidates

### Edge Cases

1. **Empty State Handling:**
   - App behavior when no spaces exist (first launch)
   - Must handle identically to current implementation
   - **Approach:** Test empty state in space controller tests, verify first-launch flow

2. **Offline/Error Resilience:**
   - Current retry logic with exponential backoff in providers
   - Must preserve retry behavior in service layer
   - **Approach:** Move retry logic to service layer, test error recovery

3. **Concurrent Mutations:**
   - Multiple simultaneous updates to same content (e.g., rapid item toggles)
   - Riverpod handles concurrent state updates differently than Provider
   - **Approach:** Test rapid interactions, ensure state consistency

4. **Deep Linking:**
   - If app supports deep linking to specific content items
   - Must ensure navigation still works with new controllers
   - **Approach:** Test deep link scenarios in Phase 7

## Success Metrics

### Functional Metrics

**Critical (Must be 100%):**
- [ ] All authentication flows work identically (sign-in, sign-up, sign-out)
- [ ] All space CRUD operations work identically
- [ ] All note CRUD operations work identically
- [ ] All todo list CRUD operations work identically
- [ ] All list CRUD operations work identically
- [ ] Item count aggregation works correctly (TodoLists, Lists)
- [ ] Reordering works identically (lists and items)
- [ ] QuickCapture works for all content types
- [ ] Theme switching works identically
- [ ] Home screen filtering works identically
- [ ] Search functionality works identically
- [ ] Pagination works identically
- [ ] Auto-save works identically (notes, list detail screens)

### Quality Metrics

**Code Quality:**
- [ ] Zero analyzer errors
- [ ] Zero analyzer warnings
- [ ] Zero analyzer informational messages
- [ ] All linting rules pass
- [ ] No TODO or FIXME comments left in migration code

**Test Coverage:**
- [ ] All tests pass (100% pass rate)
- [ ] Test coverage ≥ 80% (improved from current 70%)
- [ ] Service layer has 100% unit test coverage
- [ ] Controller layer has comprehensive ProviderContainer tests
- [ ] Critical UI flows have widget tests

### Performance Metrics

**Build Performance:**
- [ ] Full build time ≤ baseline + 10% (accounting for code generation)
- [ ] Hot reload time unchanged
- [ ] Test suite execution time improved (more unit tests, fewer widget tests)

**Runtime Performance:**
- [ ] App launch time unchanged or improved
- [ ] Screen navigation time unchanged or improved
- [ ] Home screen rendering time unchanged or improved
- [ ] No memory leaks (verified with DevTools)
- [ ] 60fps maintained on key screens (Home, Detail screens)

### Developer Experience Metrics

**Maintainability:**
- [ ] Clear feature-first organization (easier to find code)
- [ ] Service layer enables pure Dart testing
- [ ] Compile-time safety catches errors early
- [ ] Reduced lines of code (less boilerplate than Provider)
- [ ] Lower cyclomatic complexity (better separation of concerns)

**Documentation:**
- [ ] ARCHITECTURE.md complete and comprehensive
- [ ] CLAUDE.md updated with Riverpod patterns
- [ ] Migration retrospective completed with lessons learned
- [ ] Code examples for all common patterns
- [ ] Test examples for all testing strategies

## Timeline and Estimates

### Phase Breakdown

| Phase | Description | Duration | Risk |
|-------|-------------|----------|------|
| 0 | Pre-Migration Setup | 1 day | Very Low |
| 1 | Theme Migration | 1 day | Low |
| 2 | Auth Migration | 2 days | Medium |
| 3 | Spaces Migration | 2 days | Medium |
| 4 | Notes Migration | 2 days | Low |
| 5 | TodoLists Migration | 3 days | Medium |
| 6 | Lists Migration | 2 days | Low |
| 7 | Home Screen & Integration | 3 days | Medium |
| 8 | Cleanup & Documentation | 2 days | Low |
| **Total** | | **18 days** | |

### Assumptions

- **1 full-time developer** dedicated to migration
- **6 hours/day** of focused migration work (accounting for meetings, interruptions)
- **Existing test suite** catches regressions effectively
- **Team has moderate Riverpod knowledge** (basic familiarity with providers, refs, notifiers)
- **No major production incidents** requiring context switch

### Buffer and Contingency

- **Add 20% buffer** for unexpected issues: **18 days × 1.2 = ~22 days (~4.5 weeks)**
- **Realistic estimate with buffer: 5 weeks**

### Recommended Schedule

**Week 1:**
- Day 1: Phase 0 (Setup)
- Day 2: Phase 1 (Theme)
- Day 3-4: Phase 2 (Auth)
- Day 5: Start Phase 3 (Spaces)

**Week 2:**
- Day 1: Complete Phase 3 (Spaces)
- Day 2-3: Phase 4 (Notes)
- Day 4-5: Start Phase 5 (TodoLists)

**Week 3:**
- Day 1: Complete Phase 5 (TodoLists)
- Day 2-3: Phase 6 (Lists)
- Day 4-5: Start Phase 7 (Home Screen)

**Week 4:**
- Day 1: Complete Phase 7 (Home Screen)
- Day 2-3: Phase 8 (Cleanup)
- Day 4-5: Buffer for issues or final validation

**Week 5:**
- Day 1-2: Buffer for issues
- Day 3-5: Final testing, documentation review, knowledge transfer

## Rollback Strategy

### Per-Phase Rollback

Each phase is a separate Git commit (or set of commits) with the following structure:

```
commit: "feat: Migrate [Feature] to Riverpod - Phase N"

Changes:
- Created feature structure (lib/features/[feature]/)
- Implemented service layer
- Implemented Riverpod controllers
- Updated UI to use Riverpod
- Migrated tests

Verified:
- All tests pass
- flutter analyze clean
- Manual app test passed
- Feature works identically to before
```

**If issues found in a phase:**
1. Attempt to fix forward (preferred)
2. If fix-forward is complex or risky:
   - Revert the phase commits
   - Provider code still exists and functional
   - App returns to working state
   - Investigate issue, plan fix, retry phase

### Full Migration Rollback

**If fundamental issues discovered late (Phase 7-8):**

1. **Immediate:**
   - Revert to commit before Phase 0
   - Provider-based architecture restored
   - App fully functional

2. **Investigation:**
   - Identify root cause
   - Determine if migration approach needs revision
   - Consider alternative approaches (keep Provider, hybrid approach)

3. **Re-attempt:**
   - If Riverpod migration still viable, address root cause
   - Restart from Phase 0 with lessons learned
   - Update plan with mitigation strategies

**Likelihood:** Very Low (incremental migration with validation at each phase minimizes this risk)

## Post-Migration Recommendations

### Immediate (Week 6)

1. **Monitor Production:**
   - Watch for performance regressions
   - Monitor error rates
   - Collect user feedback

2. **Knowledge Transfer:**
   - Hold team meeting to review new architecture
   - Walk through ARCHITECTURE.md
   - Share migration retrospective learnings

3. **Celebrate:**
   - Acknowledge team effort
   - Document success metrics achieved

### Short-Term (Month 2-3)

1. **Add Freezed for Immutability:**
   - Incrementally convert models to Freezed
   - Benefits: immutability, copyWith, equality
   - Start with simplest models (Space, Note)

2. **Performance Optimization:**
   - Profile app with Riverpod DevTools
   - Add `.select()` for fine-grained reactivity where beneficial
   - Optimize provider dependencies

3. **Advanced Testing:**
   - Add integration tests for critical flows
   - Add performance regression tests
   - Improve test helpers based on usage patterns

### Long-Term (Month 4+)

1. **Offline Support:**
   - Riverpod's repository pattern makes this straightforward
   - Consider adding local database (Drift/Isar)
   - Implement sync strategy

2. **Feature Flags:**
   - Riverpod providers make overriding behavior easy
   - Add feature flag system for A/B testing
   - Use ProviderScope overrides for testing flags

3. **Modularization:**
   - As app grows, consider splitting features into packages
   - Feature-first architecture makes this easier
   - Example: `packages/features/notes/`, `packages/features/todos/`

## References and Resources

### Official Documentation

- [Riverpod Official Docs](https://riverpod.dev/) - Comprehensive Riverpod documentation
- [Flutter App Architecture Guide](https://docs.flutter.dev/app-architecture) - Official Flutter guidance
- [Riverpod Code Generation](https://riverpod.dev/docs/concepts/about_code_generation) - Code generation setup

### Expert Articles

- [Flutter App Architecture with Riverpod: An Introduction](https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/) - Andrea Bizzotto
- [Comparison of Flutter App Architectures](https://codewithandrea.com/articles/comparison-flutter-app-architectures/) - Andrea Bizzotto
- [Clean Architecture Flutter Guide](https://www.happycoders.in/flutter-clean-architecture-a-practical-guide/)

### Code Examples

- [Flutter Clean Architecture Example (GitHub)](https://github.com/guilherme-v/flutter-clean-architecture-example) - Riverpod examples
- [Riverpod Examples (Official)](https://github.com/rrousselGit/riverpod/tree/master/examples) - Official examples

### Testing Resources

- [Riverpod Testing Guide](https://riverpod.dev/docs/essentials/testing) - Official testing documentation
- [Flutter Testing Guide](https://docs.flutter.dev/testing) - Official Flutter testing guide

## Appendix

### Key Riverpod Concepts

**Provider Types:**

1. **Provider** - For read-only values (repositories, services)
   ```dart
   final myServiceProvider = Provider<MyService>((ref) {
     return MyService(repository: ref.watch(myRepositoryProvider));
   });
   ```

2. **NotifierProvider** - For mutable state (controllers)
   ```dart
   @riverpod
   class MyController extends _$MyController {
     @override
     MyState build() => MyState.initial();

     void performAction() {
       state = state.copyWith(value: newValue);
     }
   }
   ```

3. **FutureProvider** - For async read-only data
   ```dart
   @riverpod
   Future<List<Item>> items(ItemsRef ref, String id) async {
     return ref.watch(itemServiceProvider).getItems(id);
   }
   ```

4. **StateProvider** - For simple mutable state
   ```dart
   final counterProvider = StateProvider<int>((ref) => 0);
   ```

**Provider Modifiers:**

- `autoDispose` - Automatically dispose when no longer watched (default with code generation)
- `family` - Accept parameters (e.g., `provider(spaceId)`)
- `keepAlive` - Keep provider alive even when not watched (repositories, services)

**Ref Methods:**

- `ref.watch(provider)` - Watch provider, rebuild when changes
- `ref.read(provider)` - Read provider once, no rebuild
- `ref.listen(provider, (prev, next) {})` - Listen to changes
- `ref.invalidate(provider)` - Force provider refresh

### Code Generation Commands

**During Development:**
```bash
# Watch mode (auto-generate on file changes)
dart run build_runner watch --delete-conflicting-outputs

# One-time build
dart run build_runner build --delete-conflicting-outputs
```

**Clean Generated Files:**
```bash
dart run build_runner clean
```

**Before Committing:**
```bash
# Ensure all generated files are up to date
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

### Feature-First File Structure Template

```
lib/features/{feature_name}/
├── domain/
│   └── models/
│       ├── {entity}.dart
│       └── {entity}.g.dart          # If using Freezed/json_serializable
├── data/
│   └── repositories/
│       ├── {feature}_repository.dart
│       └── providers.dart             # Repository providers
├── application/
│   └── services/
│       ├── {feature}_service.dart
│       └── providers.dart             # Service providers
└── presentation/
    ├── controllers/
    │   ├── {feature}_controller.dart
    │   └── {feature}_controller.g.dart  # Generated
    ├── screens/
    │   └── {feature}_screen.dart
    └── widgets/
        ├── {feature}_card.dart
        └── {feature}_modal.dart
```

### Testing Pattern Templates

**Service Unit Test:**
```dart
void main() {
  group('MyService', () {
    late MockMyRepository mockRepo;
    late MyService service;

    setUp(() {
      mockRepo = MockMyRepository();
      service = MyService(repository: mockRepo);
    });

    test('should do something', () async {
      // Arrange
      when(mockRepo.getData()).thenAnswer((_) async => testData);

      // Act
      final result = await service.doSomething();

      // Assert
      expect(result, expectedValue);
      verify(mockRepo.getData()).called(1);
    });
  });
}
```

**Controller Test:**
```dart
void main() {
  group('MyController', () {
    late ProviderContainer container;
    late MockMyService mockService;

    setUp(() {
      mockService = MockMyService();
      container = ProviderContainer(
        overrides: [
          myServiceProvider.overrideWithValue(mockService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should update state', () async {
      // Arrange
      when(mockService.doSomething()).thenAnswer((_) async => testResult);

      // Act
      final controller = container.read(myControllerProvider.notifier);
      await controller.performAction();

      // Assert
      final state = container.read(myControllerProvider);
      expect(state.value, expectedState);
    });
  });
}
```

**Widget Test:**
```dart
testWidgets('should render correctly', (tester) async {
  // Arrange
  final mockController = MockMyController();
  when(mockController.build()).thenReturn(AsyncValue.data(testData));

  // Act
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        myControllerProvider.overrideWith((ref) => mockController),
      ],
      child: testApp(MyScreen()),
    ),
  );

  // Assert
  expect(find.text('Expected Text'), findsOneWidget);
});
```
