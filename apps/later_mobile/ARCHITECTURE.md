# Later Mobile - Architecture Guide

## Current Architecture (Riverpod 3.0 + Feature-First Clean Architecture)

### ✅ Migration Complete (November 2025)

The Later mobile app has been successfully migrated from Provider to **Riverpod 3.0.3** with Feature-First Clean Architecture. All Provider code has been removed and the app now runs entirely on Riverpod.

## Architecture Overview

### State Management: Riverpod 3.0.3

The app uses Riverpod 3.0.3 for state management with code generation. Key controllers include:

- **AuthStateController** - Manages authentication state and stream subscription (keepAlive)
- **ThemeController** - Manages light/dark theme (keepAlive)
- **SpacesController** - Manages list of all spaces (keepAlive)
- **CurrentSpaceController** - Manages currently selected space (keepAlive)
- **NotesController(spaceId)** - Manages notes for a specific space (auto-dispose)
- **TodoListsController(spaceId)** - Manages todo lists for a specific space (auto-dispose)
- **ListsController(spaceId)** - Manages custom lists for a specific space (auto-dispose)
- **TodoItemsController(listId)** - Manages items for a specific todo list (auto-dispose)
- **ListItemsController(listId)** - Manages items for a specific custom list (auto-dispose)

**keepAlive vs Auto-Dispose:**
- `keepAlive: true` - For global state that should persist (auth, theme, spaces)
- Auto-dispose (default) - For feature-scoped state tied to specific screens or parameters

### Architectural Layers

Each feature has four Clean Architecture layers:

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

### Code Organization

```
lib/
├── core/                   # Framework concerns
│   ├── config/            # App configuration (Supabase setup)
│   ├── error/             # Centralized error handling
│   └── mixins/            # Shared behaviors (AutoSaveMixin)
├── design_system/          # Atomic Design components
│   ├── atoms/             # Basic components (buttons, inputs)
│   ├── molecules/         # Composed components (cards)
│   └── organisms/         # Complex components (navigation)
├── data/                   # Legacy data layer (being phased out)
│   ├── local/             # SharedPreferences (PreferencesService)
│   └── models/            # Some legacy models
└── features/               # Feature-first organization
    ├── auth/
    │   ├── data/services/          # AuthService (Supabase integration)
    │   ├── application/            # AuthApplicationService (business logic)
    │   └── presentation/
    │       ├── controllers/        # AuthStateController
    │       └── screens/            # SignInScreen, SignUpScreen
    ├── theme/
    │   ├── application/            # ThemeService
    │   └── presentation/
    │       └── controllers/        # ThemeController
    ├── spaces/
    │   ├── domain/models/          # Space model
    │   ├── data/repositories/      # SpaceRepository
    │   ├── application/            # SpaceService
    │   └── presentation/
    │       └── controllers/        # SpacesController, CurrentSpaceController
    ├── notes/
    │   ├── domain/models/          # Note model
    │   ├── data/repositories/      # NoteRepository
    │   ├── application/            # NoteService
    │   └── presentation/
    │       ├── controllers/        # NotesController
    │       └── screens/            # NoteDetailScreen
    ├── todo_lists/
    │   ├── domain/models/          # TodoList, TodoItem models
    │   ├── data/repositories/      # TodoListRepository
    │   ├── application/            # TodoListService
    │   └── presentation/
    │       ├── controllers/        # TodoListsController, TodoItemsController
    │       └── screens/            # TodoListDetailScreen
    ├── lists/
    │   ├── domain/models/          # ListModel, ListItem models
    │   ├── data/repositories/      # ListRepository
    │   ├── application/            # ListService
    │   └── presentation/
    │       ├── controllers/        # ListsController, ListItemsController
    │       └── screens/            # ListDetailScreen
    └── home/
        └── presentation/
            ├── controllers/        # ContentFilterController
            └── screens/            # HomeScreen
```

## Riverpod 3.0 Patterns

### Provider Types

1. **Provider** - For read-only values (repositories, services)
2. **NotifierProvider** - For mutable state (controllers)
3. **FutureProvider** - For async read-only data
4. **StateProvider** - For simple mutable state

### Code Generation

Riverpod 3.0 uses `@riverpod` annotation with simplified syntax:

```dart
@riverpod
class ThemeController extends _$ThemeController {
  @override
  ThemeMode build() {
    // Load initial state
    return ThemeMode.system;
  }

  void toggleTheme() {
    // Update state
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}
```

**Key Features:**
- Auto-dispose by default (no AutoDispose prefix)
- Family parameters inferred from build() method
- Unified Ref type (no generics)
- `Ref.mounted` for async safety

### Testing Strategy

**Service Unit Tests** (Pure Dart):
```dart
test('business logic test', () {
  final mockRepo = MockRepository();
  final service = MyService(repository: mockRepo);

  final result = service.doSomething();

  expect(result, expectedValue);
});
```

**Controller Tests** (Riverpod 3.0):
```dart
test('controller test', () {
  final container = ProviderContainer.test(
    overrides: [myServiceProvider.overrideWithValue(mockService)],
  );

  final controller = container.read(myControllerProvider.notifier);
  controller.performAction();

  expect(container.read(myControllerProvider), expectedState);
});
```

**Widget Tests** (Minimal):
```dart
testWidgets('UI test', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        myControllerProvider.overrideWithBuild((ref, arg) => testData),
      ],
      child: testApp(MyWidget()),
    ),
  );

  expect(find.text('Expected UI'), findsOneWidget);
});
```

## Migration Status

### ✅ Complete (All Phases)

All 9 phases of the Riverpod 3.0 migration have been successfully completed:

- **Phase 0: Pre-Migration Setup** ✅
  - Added Riverpod 3.0.3 dependencies, configured build runner, captured baseline metrics

- **Phase 1: Theme Migration** ✅
  - Migrated ThemeService and ThemeController with keepAlive pattern

- **Phase 2: Auth Migration** ✅
  - Migrated AuthService and AuthStateController with stream subscription management

- **Phase 3: Spaces Migration** ✅
  - Migrated SpaceService, SpacesController, and CurrentSpaceController

- **Phase 4: Notes Migration** ✅
  - Migrated NoteService and NotesController with family pattern

- **Phase 5: TodoLists Migration** ✅
  - Migrated TodoListService, TodoListsController, and TodoItemsController

- **Phase 6: Lists Migration** ✅
  - Migrated ListService, ListsController, and ListItemsController

- **Phase 7: Home Screen & Integration** ✅
  - Migrated HomeScreen, ContentFilterController, and cross-feature integration

- **Phase 8: Cleanup & Optimization** ✅
  - Removed all Provider code, optimized keepAlive usage, completed documentation

**Key Achievements:**
- ✅ Zero Provider code remains in codebase
- ✅ 1195+ tests passing (zero new test failures from migration)
- ✅ Zero analyzer errors or warnings in source code
- ✅ keepAlive optimization applied to global state controllers
- ✅ Functional parity maintained - app works identically to pre-migration

See `.claude/plans/riverpod-architecture-migration.md` for detailed migration plan and `.claude/migration-retrospective.md` for lessons learned.

## Key Principles

### 1. Feature-First Organization
- Code organized by feature, not by layer
- Each feature is a vertical slice (domain → data → application → presentation)
- Easier to find and maintain related code

### 2. Clean Architecture Layers
- **Domain** - Pure business logic (no dependencies)
- **Data** - External systems (database, APIs)
- **Application** - Use cases and services
- **Presentation** - UI and state management

### 3. Separation of Concerns
- Business logic in services (testable with pure Dart)
- State management in controllers (Riverpod)
- UI in widgets (minimal logic)

### 4. Testability First
- Service layer: Pure Dart unit tests
- Controller layer: ProviderContainer tests
- Widget layer: Minimal UI tests

### 5. Type Safety
- Compile-time safety with Riverpod
- No BuildContext dependency
- No runtime context errors

## Benefits of New Architecture

1. **Better Testability** - Pure Dart unit tests for business logic (900+ service/controller tests)
2. **Improved Scalability** - Feature-first scales from 6 screens to 50+ screens easily
3. **Compile-time Safety** - Riverpod catches errors at compile time, no runtime context errors
4. **Better Developer Experience** - Less boilerplate with code generation, clearer organization
5. **Maintainability** - Broke up ContentProvider god object (1200+ lines) into focused feature services
6. **Separation of Concerns** - Business logic in testable services, state in controllers, UI minimal
7. **Automatic Error Retry** - Riverpod 3.0 provides built-in exponential backoff retry for async operations
8. **Async Safety** - `ref.mounted` checks prevent state updates after disposal

## Riverpod 3.0 Key Features

### Code Generation Patterns

**Repository/Service Providers** (Singleton with keepAlive):
```dart
@Riverpod(keepAlive: true)
SpaceRepository spaceRepository(Ref ref) {
  return SpaceRepository();
}
```

**Controller Providers** (Auto-dispose by default):
```dart
@riverpod
class NotesController extends _$NotesController {
  @override
  Future<List<Note>> build(String spaceId) async {
    // Load initial state
    final service = ref.watch(noteServiceProvider);
    return service.getNotesForSpace(spaceId);
  }

  Future<void> createNote(Note note) async {
    final service = ref.read(noteServiceProvider);
    final created = await service.createNote(note);

    // NEW in 3.0: Check if still mounted before updating
    if (!ref.mounted) return;

    state = AsyncValue.data([...state.value!, created]);
  }
}
```

**Global State Controllers** (keepAlive to prevent disposal):
```dart
@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  @override
  ThemeMode build() {
    final service = ref.watch(themeServiceProvider);
    return service.loadThemePreference();
  }

  Future<void> toggleTheme() async {
    // Theme logic with ref.mounted checks
  }
}
```

### Testing Patterns

**Service Tests** (Pure Dart):
```dart
test('creates note successfully', () async {
  final mockRepo = MockNoteRepository();
  final service = NoteService(repository: mockRepo);

  when(mockRepo.createNote(any)).thenAnswer((_) async => testNote);

  final result = await service.createNote(testNote);

  expect(result, testNote);
  verify(mockRepo.createNote(testNote)).called(1);
});
```

**Controller Tests** (ProviderContainer.test):
```dart
test('loads notes for space', () async {
  final container = ProviderContainer.test(
    overrides: [
      noteServiceProvider.overrideWithValue(mockService),
    ],
  );

  final notesAsync = await container.read(
    notesControllerProvider('space-1').future,
  );

  expect(notesAsync.length, 2);
});
```

### Dependency Injection

Riverpod providers form a dependency graph automatically:

```
AuthStateController
  ↓ depends on
AuthApplicationService (keepAlive)
  ↓ depends on
AuthService (keepAlive)
  ↓ depends on
Supabase client (from BaseRepository)
```

When any provider changes, dependent providers are automatically invalidated and rebuilt.

---

**Last Updated:** November 2025 - Post Riverpod 3.0 Migration
