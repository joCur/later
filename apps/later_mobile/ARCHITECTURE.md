# Later Mobile - Architecture Guide

## Current Architecture (Pre-Migration)

### State Management: Provider Pattern

The Later mobile app currently uses the Provider package for state management with the following key providers:

- **AuthProvider** - Manages authentication state and auth operations
- **ContentProvider** - Manages all content items (notes, todos, lists) with caching (1200+ lines)
- **SpacesProvider** - Manages spaces and active space selection
- **ThemeProvider** - Manages light/dark theme

### Data Layer

**Repository Pattern:**
- All data access through repositories (`data/repositories/`)
- Repositories extend `BaseRepository` with Supabase client access
- Key repositories: `NoteRepository`, `TodoListRepository`, `ListRepository`, `SpaceRepository`

**Database:** Supabase (PostgreSQL) with Row-Level Security

### Code Organization (Pre-Migration)

```
lib/
├── core/               # Core utilities, theme, error handling
├── design_system/      # Atomic Design components
├── data/              # Data layer (models, repositories)
├── providers/         # State management (Provider pattern)
└── widgets/           # Feature screens and modals
```

## Target Architecture (Post-Migration)

### State Management: Riverpod 3.0.3

Migrating to Riverpod 3.0 with Feature-First Clean Architecture.

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

### Code Organization (Post-Migration)

```
lib/
├── core/               # Framework concerns (unchanged)
├── design_system/      # Atomic Design (unchanged)
├── shared/            # Shared utilities
└── features/          # Feature-first organization
    ├── auth/
    │   ├── domain/models/
    │   ├── data/services/
    │   ├── application/
    │   └── presentation/controllers/
    ├── spaces/
    ├── notes/
    ├── todo_lists/
    └── lists/
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

**Phase 0: Pre-Migration Setup** - ✅ Complete
- Dependencies added
- Build runner configured
- Baseline metrics captured
- Documentation structure created

**Remaining Phases:**
- Phase 1: Theme Migration
- Phase 2: Auth Migration
- Phase 3: Spaces Migration
- Phase 4: Notes Migration
- Phase 5: TodoLists Migration
- Phase 6: Lists Migration
- Phase 7: Home Screen & Integration
- Phase 8: Cleanup & Documentation

See `.claude/plans/riverpod-architecture-migration.md` for detailed migration plan.

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

1. **Better Testability** - Pure Dart unit tests for business logic
2. **Improved Scalability** - Feature-first scales from 6 screens to 50+
3. **Compile-time Safety** - Riverpod catches errors at compile time
4. **Better Developer Experience** - Less boilerplate, clearer organization
5. **Maintainability** - Breaking up ContentProvider god object (1200+ lines)

---

**Note:** This document will be updated as the migration progresses.
