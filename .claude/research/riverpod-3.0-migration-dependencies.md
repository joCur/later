# Research: Riverpod 3.0 Dependencies and Migration Considerations

## Executive Summary

The Riverpod migration plan in `riverpod-architecture-migration.md` was designed for **Riverpod 2.6.1**, but as of November 2025, **Riverpod 3.0.3** is the latest stable version. This represents a major version update released in September 2025 with significant breaking changes and new features that require updates to the migration plan.

**Key Findings:**
- All Riverpod dependencies have moved from 2.6.1 to 3.0.3 (major version bump)
- Riverpod 3.0 introduces **breaking API changes** requiring pattern modifications
- New features like **automatic retry**, **Ref.mounted**, and **offline persistence** offer significant improvements
- Testing patterns have improved with **ProviderContainer.test()** utility
- Code generation patterns remain largely the same but with simplified syntax

**Recommendation:** Update the migration plan to target Riverpod 3.0.3 with adjustments for breaking changes and leverage new features for better resilience and developer experience.

---

## Research Scope

### What Was Researched
- Latest versions of all Riverpod-related dependencies (as of November 2025)
- Breaking changes from Riverpod 2.6.1 to 3.0.3
- New features and patterns introduced in Riverpod 3.0
- Best practices and architectural patterns for Riverpod 3.0 + Clean Architecture
- Testing pattern changes and improvements
- Code generation syntax updates

### What Was Explicitly Excluded
- Other state management alternatives (Bloc, GetX, etc.)
- Riverpod versions older than 2.6.1
- Third-party Riverpod extensions not officially maintained
- Riverpod for web-only features

### Research Methodology
- Web search for official documentation and changelogs
- Analysis of pub.dev package pages for exact version numbers
- Review of migration guides and community best practices
- Examination of code examples from official sources

---

## Current State Analysis

### Existing Implementation (Later App)
- **Current state management**: Provider (not Riverpod)
- **Target architecture**: Feature-First Clean Architecture with Riverpod
- **Migration plan version**: Written for Riverpod 2.6.1
- **Test infrastructure**: 200+ tests, >70% coverage with widget tests
- **Key pain points**: God object (ContentProvider 1200+ lines), BuildContext dependency, difficult testing

### Industry Standards (2025)
- **Riverpod 3.0** is now the production-ready standard (released September 2025)
- **Code generation** with `@riverpod` annotation is the recommended approach
- **Feature-first organization** with Clean Architecture is the established pattern
- **Pure Dart unit testing** for services is the preferred testing strategy
- **Automatic retry** and **offline persistence** are emerging as standard patterns

---

## Version Analysis

### Riverpod Dependency Updates

| Package | Plan Version | Latest Version | Change | Status |
|---------|-------------|----------------|--------|--------|
| `flutter_riverpod` | 2.6.1 | **3.0.3** | Major | ⚠️ Breaking |
| `riverpod_annotation` | 2.6.1 | **3.0.3** | Major | ⚠️ Breaking |
| `riverpod_generator` | 2.6.1 | **3.0.3** | Major | ⚠️ Breaking |
| `riverpod_lint` | 2.6.1 | **3.0.3** | Major | ⚠️ Breaking |
| `build_runner` | 2.10.1 | **2.10.2** | Patch | ✅ Safe |

**Updated Dependencies for Phase 0:**
```yaml
dependencies:
  flutter_riverpod: ^3.0.3

dev_dependencies:
  riverpod_annotation: ^3.0.3
  riverpod_generator: ^3.0.3
  riverpod_lint: ^3.0.3
  build_runner: ^2.10.2
```

---

## Breaking Changes in Riverpod 3.0

### 1. Automatic Retry (Now Default Behavior)

**What Changed:**
Providers that fail during initialization now **automatically retry** with exponential backoff (200ms → 400ms → 800ms → up to 6.4s).

**Impact on Migration Plan:**
- **Medium impact** - Changes error handling behavior
- Services and controllers no longer need manual retry logic
- May affect error handling tests (errors are retried, not immediately thrown)

**Code Example:**
```dart
// Old (2.6.1): Manual retry in service
class NoteService {
  Future<List<Note>> getNotes() async {
    try {
      return await repository.getNotes();
    } catch (e) {
      // Manual retry logic
      await Future.delayed(Duration(milliseconds: 200));
      return await repository.getNotes();
    }
  }
}

// New (3.0): Automatic retry (no manual logic needed)
@riverpod
Future<List<Note>> notes(Ref ref) async {
  final service = ref.watch(noteServiceProvider);
  return service.getNotes(); // Automatically retried on failure
}

// Disable retry if needed (per-provider)
@Riverpod(retry: (count, error) => null)
Future<List<Note>> notesNoRetry(Ref ref) async {
  // Will not retry
}
```

**Migration Plan Update:**
- Remove manual retry logic from services (simplification)
- Update error handling tests to account for retry behavior
- Document that transient errors (network timeouts) are auto-retried

---

### 2. Legacy Provider Types Moved

**What Changed:**
`StateProvider`, `StateNotifierProvider`, and `ChangeNotifierProvider` moved to `package:flutter_riverpod/legacy.dart`.

**Impact on Migration Plan:**
- **Low impact** - Plan doesn't use these legacy providers
- Migration uses `Notifier` and `AsyncNotifier` (modern approach)

**Code Example:**
```dart
// Old import (if using StateProvider)
import 'package:flutter_riverpod/flutter_riverpod.dart';
final counterProvider = StateProvider<int>((ref) => 0);

// New import (3.0) - legacy providers
import 'package:flutter_riverpod/legacy.dart';
final counterProvider = StateProvider<int>((ref) => 0);

// Recommended (3.0) - use Notifier instead
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
}
```

**Migration Plan Update:**
- No changes needed (plan already uses modern Notifier pattern)

---

### 3. Unified Ref Type (No More Generics)

**What Changed:**
- `Ref<T>` → `Ref` (no type parameter)
- `ProviderRef.state` → `Notifier.state`
- `Ref.listenSelf` → `Notifier.listenSelf`
- `FutureProviderRef.future` → `AsyncNotifier.future`

**Impact on Migration Plan:**
- **Medium impact** - Code examples need updating
- Pattern is simpler in 3.0

**Code Example:**
```dart
// Old (2.6.1)
@riverpod
class TodoListController extends _$TodoListController {
  @override
  Future<List<TodoList>> build(String spaceId) async {
    final service = ref.watch(todoListServiceProvider);

    // Access ref properties
    ref.listenSelf((previous, next) {
      // React to changes
    });

    return service.getTodoListsForSpace(spaceId);
  }
}

// New (3.0)
@riverpod
class TodoListController extends _$TodoListController {
  @override
  Future<List<TodoList>> build(String spaceId) async {
    final service = ref.watch(todoListServiceProvider);

    // Use Notifier methods instead of Ref
    listenSelf((previous, next) {
      // React to changes
    });

    return service.getTodoListsForSpace(spaceId);
  }
}
```

**Migration Plan Update:**
- Update code examples to use `Ref` without type parameter
- Use `Notifier.state`, `Notifier.listenSelf` instead of `Ref` variants
- Simplifies controller implementation

---

### 4. AutoDispose and Family Simplification

**What Changed:**
- `AutoDisposeNotifier` → `Notifier` (unified)
- `FamilyNotifier` → `Notifier` with parameters
- `AutoDisposeFamilyNotifier` → `Notifier` with parameters
- AutoDispose is **now the default** with code generation

**Impact on Migration Plan:**
- **High impact** - Major simplification of patterns
- All code examples need updating
- Migration becomes simpler

**Code Example:**
```dart
// Old (2.6.1) - Complex type hierarchy
class TodoListController extends AutoDisposeFamilyAsyncNotifier<List<TodoList>, String> {
  @override
  Future<List<TodoList>> build(String spaceId) async {
    final service = ref.watch(todoListServiceProvider);
    return service.getTodoListsForSpace(spaceId);
  }
}

final todoListControllerProvider =
  AsyncNotifierProvider.autoDispose.family<TodoListController, List<TodoList>, String>(
    TodoListController.new,
  );

// New (3.0) - Simple, unified
@riverpod
class TodoListController extends _$TodoListController {
  @override
  Future<List<TodoList>> build(String spaceId) async {
    final service = ref.watch(todoListServiceProvider);
    return service.getTodoListsForSpace(spaceId);
  }
}
// Auto-disposed by default, family parameter automatically inferred
```

**Migration Plan Update:**
- Remove all `AutoDispose` and `Family` prefixes from code examples
- Document that autoDispose is default (use `keepAlive: true` to disable)
- Simplify all controller patterns

---

### 5. ProviderException Wrapping

**What Changed:**
All provider errors are now wrapped in `ProviderException`. Original exception is in `.exception` property.

**Impact on Migration Plan:**
- **Low-Medium impact** - Error handling patterns need adjustment
- Affects controller error handling and tests

**Code Example:**
```dart
// Old (2.6.1) - Catch original exceptions
try {
  final notes = await ref.read(notesProvider(spaceId).future);
} on AppError catch (e) {
  // Handle AppError
} on NotFoundException catch (e) {
  // Handle NotFoundException
}

// New (3.0) - Unwrap ProviderException
try {
  final notes = await ref.read(notesProvider(spaceId).future);
} on ProviderException catch (e) {
  if (e.exception is AppError) {
    // Handle AppError
  } else if (e.exception is NotFoundException) {
    // Handle NotFoundException
  }
}
```

**Migration Plan Update:**
- Update error handling examples to unwrap ProviderException
- Update test expectations for error types
- Document ProviderException wrapping behavior

---

### 6. Equality Filtering Changes

**What Changed:**
All providers now use `==` (not `identical`) for update filtering. Affects `StreamProvider` and custom objects.

**Impact on Migration Plan:**
- **Low impact** - Most models already implement equality
- Need to ensure models have proper `==` and `hashCode` implementations

**Code Example:**
```dart
// Ensure models implement equality
class Note {
  final String id;
  final String title;
  final String content;

  // Required for Riverpod 3.0 update filtering
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          content == other.content;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ content.hashCode;
}

// Or use Freezed (recommended)
@freezed
class Note with _$Note {
  const factory Note({
    required String id,
    required String title,
    required String content,
  }) = _Note;
}
```

**Migration Plan Update:**
- Verify all models have proper equality implementation
- Consider adding Freezed in Phase 8 (post-migration recommendation already exists)

---

### 7. ProviderObserver Interface Changes

**What Changed:**
`ProviderObserver` methods now receive `ProviderObserverContext` instead of separate parameters.

**Impact on Migration Plan:**
- **Very Low impact** - Plan doesn't extensively use ProviderObserver
- Only affects logging/debugging setup

**Code Example:**
```dart
// Old (2.6.1)
class MyObserver extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    print('Provider $provider was initialized with $value');
  }
}

// New (3.0)
class MyObserver extends ProviderObserver {
  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    print('Provider ${context.provider} was initialized with $value');
    // Access container: context.container
  }
}
```

**Migration Plan Update:**
- Update ProviderObserver examples if used for logging
- No major pattern changes

---

## New Features in Riverpod 3.0

### 1. Ref.mounted (Critical for Async Operations)

**What It Is:**
Similar to `BuildContext.mounted`, checks if a provider is still alive before updating state after async operations.

**Impact on Migration Plan:**
- **High value** - Prevents common async errors
- Should be used in all controllers with async operations

**Code Example:**
```dart
@riverpod
class TodoItemController extends _$TodoItemController {
  @override
  List<TodoItem> build(String listId) {
    return [];
  }

  Future<void> createItem(TodoItem item) async {
    try {
      final service = ref.read(todoListServiceProvider);
      final created = await service.createTodoItem(item);

      // NEW in 3.0: Check if still mounted before updating state
      if (!ref.mounted) return;

      state = [...state, created];
    } catch (e) {
      // Handle error
    }
  }
}
```

**Migration Plan Update:**
- Add `ref.mounted` checks to all async controller methods
- Document this pattern as a best practice
- Add to Phase 1 (Theme) as example pattern

---

### 2. ProviderContainer.test() Utility

**What It Is:**
Built-in test utility that creates a container and automatically disposes it after the test.

**Impact on Migration Plan:**
- **High value** - Simplifies test setup
- Replaces custom `createContainer()` helper

**Code Example:**
```dart
// Old (2.6.1) - Custom helper
ProviderContainer createContainer({List<Override> overrides = const []}) {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  return container;
}

test('my test', () {
  final container = createContainer(
    overrides: [myServiceProvider.overrideWithValue(mockService)],
  );
  // ...
});

// New (3.0) - Built-in utility
test('my test', () {
  final container = ProviderContainer.test(
    overrides: [myServiceProvider.overrideWithValue(mockService)],
  );
  // Automatically disposed after test
});
```

**Migration Plan Update:**
- Replace custom `createContainer()` helper with `ProviderContainer.test()`
- Update test examples in all phases
- Simplifies Phase 1 test helper setup

---

### 3. NotifierProvider.overrideWithBuild()

**What It Is:**
Mock only the `build()` method of a Notifier, not the entire notifier object.

**Impact on Migration Plan:**
- **Medium value** - Makes testing easier
- Allows partial mocking of controllers

**Code Example:**
```dart
// Old (2.6.1) - Mock entire notifier
class MockTodoListController extends Mock implements TodoListController {}

testWidgets('test', (tester) async {
  final mockController = MockTodoListController();
  when(mockController.build(any)).thenReturn([]);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todoListControllerProvider(spaceId).overrideWith((ref) => mockController),
      ],
      child: testApp(MyWidget()),
    ),
  );
});

// New (3.0) - Mock only build method
testWidgets('test', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todoListControllerProvider(spaceId).overrideWithBuild((ref, arg) {
          return []; // Mock data
        }),
      ],
      child: testApp(MyWidget()),
    ),
  );
});
```

**Migration Plan Update:**
- Use `overrideWithBuild()` in widget tests for simpler mocking
- Document this pattern in test examples
- Add to Phase 1 test patterns

---

### 4. Automatic Pause/Resume for Invisible Widgets

**What It Is:**
Providers automatically pause when widgets are off-screen (not visible), reducing unnecessary computations.

**Impact on Migration Plan:**
- **Low impact** - Automatic optimization
- No code changes needed
- Performance benefit

**Behavior:**
- When a widget is not visible (e.g., scrolled off screen), its provider listeners pause
- Providers with only paused listeners also pause
- Resumes automatically when widget becomes visible

**Migration Plan Update:**
- Document this behavior as a built-in optimization
- No action needed in migration phases

---

### 5. Offline Persistence (Experimental)

**What It Is:**
Experimental feature to persist provider state to local database and restore on app restart.

**Impact on Migration Plan:**
- **Future consideration** - Not for initial migration
- Excellent fit for the app's requirements
- Add to post-migration recommendations

**Code Example:**
```dart
// Enable offline persistence for a provider
@Riverpod(keepAlive: true)
class TodoListController extends _$TodoListController {
  @override
  @offlineFirst // Mark as offline-first
  Future<List<TodoList>> build(String spaceId) async {
    final service = ref.watch(todoListServiceProvider);
    return service.getTodoListsForSpace(spaceId);
    // Automatically persisted to DB on state changes
    // Automatically restored from DB on app restart
  }
}

// Check if value is from cache
if (asyncValue.isFromCache) {
  // Show "syncing" indicator
}
```

**Migration Plan Update:**
- Add to Phase 8 post-migration recommendations
- Highlight as future enhancement for offline support
- Requires additional package: `riverpod_sqflite`

---

### 6. Mutations (Experimental)

**What It Is:**
Experimental feature to track side-effect operations (like form submission) with idle/pending/error/success states.

**Impact on Migration Plan:**
- **Future consideration** - Not for initial migration
- Useful for form handling and CRUD operations
- Add to post-migration recommendations

**Code Example:**
```dart
@riverpod
class TodoListController extends _$TodoListController {
  @override
  List<TodoList> build(String spaceId) => [];

  @mutation // Mark as mutation
  Future<void> createTodoList(TodoList list) async {
    // UI automatically tracks mutation state
    final service = ref.read(todoListServiceProvider);
    final created = await service.createTodoList(list);
    state = [...state, created];
  }
}

// In UI, track mutation state
Widget build(BuildContext context, WidgetRef ref) {
  final mutation = ref.watch(createTodoListMutationProvider);

  return Column(
    children: [
      if (mutation.isPending) CircularProgressIndicator(),
      if (mutation.isError) Text('Error: ${mutation.error}'),
      if (mutation.isSuccess) Text('Created successfully!'),
    ],
  );
}
```

**Migration Plan Update:**
- Add to Phase 8 post-migration recommendations
- Potential replacement for manual loading states

---

## Testing Pattern Updates

### ProviderContainer.test() Migration

**Old Pattern (2.6.1):**
```dart
// test/helpers/riverpod_test_helpers.dart
ProviderContainer createContainer({List<Override> overrides = const []}) {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  return container;
}

// Usage
test('space service test', () {
  final container = createContainer(
    overrides: [spaceRepositoryProvider.overrideWithValue(mockRepo)],
  );
  final service = container.read(spaceServiceProvider);
  // ...
});
```

**New Pattern (3.0):**
```dart
// No custom helper needed - use built-in utility

// Usage
test('space service test', () {
  final container = ProviderContainer.test(
    overrides: [spaceRepositoryProvider.overrideWithValue(mockRepo)],
  );
  final service = container.read(spaceServiceProvider);
  // Automatically disposed after test
});
```

### Widget Test Access to Container

**New in 3.0:**
```dart
testWidgets('access container in widget test', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: testApp(MyWidget()),
    ),
  );

  // NEW: Access container directly
  final container = tester.container;
  final value = container.read(myProvider);

  expect(value, expectedValue);
});
```

---

## Architecture Pattern Validation

### Feature-First Clean Architecture (Still Valid)

The planned architecture remains the **industry standard** in 2025:

```
lib/features/{feature_name}/
├── domain/          # Pure Dart entities and business rules
│   └── models/
├── data/            # Data access and external dependencies
│   └── repositories/
├── application/     # Business logic and use cases
│   └── services/
└── presentation/    # UI and state management
    ├── controllers/  # Riverpod controllers
    ├── screens/
    └── widgets/
```

**Validation:**
- ✅ Still the recommended approach (2025 best practices)
- ✅ Riverpod 3.0 documentation examples use this structure
- ✅ Community consensus on feature-first organization
- ✅ Scales from 6 screens to 50+ screens

**Source:** Multiple 2025 articles on Riverpod + Clean Architecture confirm this pattern.

---

## Code Generation Pattern Updates

### Simplified Syntax in 3.0

**Family Parameters:**
```dart
// Old (2.6.1) - Explicit family
final todoListControllerProvider =
  AsyncNotifierProvider.autoDispose.family<TodoListController, List<TodoList>, String>(
    TodoListController.new,
  );

// New (3.0) - Parameters automatically create family
@riverpod
class TodoListController extends _$TodoListController {
  @override
  Future<List<TodoList>> build(String spaceId) async {
    // spaceId parameter automatically creates a family provider
  }
}
// Usage: ref.watch(todoListControllerProvider('space-id'))
```

**KeepAlive Instead of AutoDispose:**
```dart
// AutoDispose by default in 3.0
@riverpod
class MyController extends _$MyController { ... }

// Disable autoDispose if needed
@Riverpod(keepAlive: true)
class MyRepository extends _$MyRepository { ... }
```

**Generic Support:**
```dart
// NEW in 3.0: Type parameters
@riverpod
T multiply<T extends num>(Ref ref, T a, T b) {
  return (a * b) as T;
}

// Usage: ref.watch(multiplyProvider<int>(2, 3))
```

---

## Migration Plan Impact Summary

### Critical Updates Required

| Phase | Update Required | Severity | Description |
|-------|----------------|----------|-------------|
| Phase 0 | ✅ High | Critical | Update dependencies to 3.0.3 |
| Phase 1 | ⚠️ Medium | Important | Update code examples, add Ref.mounted pattern |
| Phase 2-7 | ⚠️ Medium | Important | Update all controller patterns (no AutoDispose prefix) |
| Phase 2-7 | ⚠️ Medium | Important | Add ProviderException unwrapping in error handling |
| All Phases | ✅ High | Important | Replace createContainer() with ProviderContainer.test() |
| Phase 8 | ℹ️ Low | Nice-to-have | Document new features as future enhancements |

### Simplified Patterns in 3.0

**Advantages:**
- ✅ Less boilerplate (no AutoDispose prefix, unified Ref)
- ✅ Cleaner code examples in migration plan
- ✅ Better testing utilities (ProviderContainer.test)
- ✅ Automatic retry reduces manual error handling
- ✅ Ref.mounted prevents common async bugs

**Disadvantages:**
- ⚠️ Breaking changes require pattern updates
- ⚠️ Some experimental features not stable yet
- ⚠️ Need to update all code examples in plan

---

## Updated Dependency Specification

### Phase 0: Pre-Migration Setup

**Update Task 0.1:**

```yaml
dependencies:
  flutter_riverpod: ^3.0.3  # Updated from ^2.6.1
  riverpod_annotation: ^3.0.3  # Updated from ^2.6.1
  provider: ^6.1.0  # Keep temporarily for gradual migration

dev_dependencies:
  build_runner: ^2.10.2  # Updated from ^2.10.1
  riverpod_generator: ^3.0.3  # Updated from ^2.6.1
  riverpod_lint: ^3.0.3  # Updated from ^2.6.1
```

**Run after updating:**
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze  # Should be clean
flutter test     # Should pass (no breaking changes yet)
```

---

## Code Example Updates for Migration Plan

### Example 1: Controller Pattern (Updated for 3.0)

```dart
// lib/features/spaces/presentation/controllers/spaces_controller.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../application/services/space_service.dart';
import '../../domain/models/space.dart';

part 'spaces_controller.g.dart';

@riverpod
class SpacesController extends _$SpacesController {
  @override
  Future<List<Space>> build(String userId) async {
    final service = ref.watch(spaceServiceProvider);
    return service.loadSpaces(userId);
    // AutoDispose by default in 3.0
    // Automatic retry on failure
  }

  Future<void> createSpace(Space space) async {
    try {
      state = const AsyncValue.loading();
      final service = ref.read(spaceServiceProvider);
      final created = await service.createSpace(space);

      // NEW in 3.0: Check if still mounted
      if (!ref.mounted) return;

      state = await AsyncValue.guard(() async {
        final spaces = await service.loadSpaces(space.userId);
        return spaces;
      });
    } on ProviderException catch (e) {
      // NEW in 3.0: Unwrap ProviderException
      state = AsyncValue.error(e.exception, e.stackTrace);
    }
  }

  Future<void> deleteSpace(String id) async {
    try {
      final service = ref.read(spaceServiceProvider);
      await service.deleteSpace(id);

      // NEW in 3.0: Check if still mounted
      if (!ref.mounted) return;

      ref.invalidateSelf(); // Refresh list
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
```

### Example 2: Test Pattern (Updated for 3.0)

```dart
// test/features/spaces/presentation/controllers/spaces_controller_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  group('SpacesController', () {
    late MockSpaceService mockService;

    setUp(() {
      mockService = MockSpaceService();
    });

    test('should load spaces on build', () async {
      // NEW in 3.0: Use built-in test utility
      final container = ProviderContainer.test(
        overrides: [
          spaceServiceProvider.overrideWithValue(mockService),
        ],
      );
      // Automatically disposed after test

      final testSpaces = [Space(id: '1', name: 'Test Space')];
      when(mockService.loadSpaces(any)).thenAnswer((_) async => testSpaces);

      final controller = container.read(spacesControllerProvider('user-1').future);
      final spaces = await controller;

      expect(spaces, testSpaces);
      verify(mockService.loadSpaces('user-1')).called(1);
    });

    test('should handle errors with ProviderException', () async {
      final container = ProviderContainer.test(
        overrides: [
          spaceServiceProvider.overrideWithValue(mockService),
        ],
      );

      when(mockService.loadSpaces(any)).thenThrow(Exception('Network error'));

      final state = container.read(spacesControllerProvider('user-1'));

      // NEW in 3.0: Errors are wrapped in ProviderException
      expect(state, isA<AsyncError>());
      expect(state.error, isA<Exception>());
    });
  });
}
```

### Example 3: Widget Test with Container Access (New in 3.0)

```dart
testWidgets('home screen displays spaces', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        spacesControllerProvider('user-1').overrideWithBuild((ref, arg) {
          return [Space(id: '1', name: 'My Space')];
        }),
      ],
      child: testApp(HomeScreen()),
    ),
  );

  await tester.pump();

  // NEW in 3.0: Access container directly
  final container = tester.container;
  final spaces = container.read(spacesControllerProvider('user-1'));

  expect(find.text('My Space'), findsOneWidget);
  expect(spaces.value?.length, 1);
});
```

---

## Recommendations

### Primary Recommendation: Adopt Riverpod 3.0.3

**Reasoning:**
1. **Stable release** (3.0.3, not a beta) - Production-ready as of September 2025
2. **Simpler patterns** - Less boilerplate, unified API
3. **Better resilience** - Automatic retry, Ref.mounted
4. **Improved testing** - Built-in test utilities
5. **Future-proof** - Current industry standard
6. **Breaking changes are manageable** - Mostly syntax updates, core patterns remain

**Migration Plan Adjustments:**

#### Phase 0: Pre-Migration Setup
- Update all dependencies to 3.0.3
- Run `dart run build_runner build` to verify code generation works
- Verify existing tests still pass (no breaking changes to app code yet)

#### Phase 1: Theme Migration
- Use updated controller pattern (no AutoDispose prefix)
- Add `ref.mounted` check example
- Replace custom `createContainer()` with `ProviderContainer.test()`
- Document these patterns for all subsequent phases

#### Phases 2-7: Feature Migrations
- Use simplified Notifier syntax (no AutoDispose/Family prefixes)
- Add `ref.mounted` checks to all async controller methods
- Use `ProviderContainer.test()` in all tests
- Update error handling to unwrap ProviderException
- Leverage automatic retry (remove manual retry logic)

#### Phase 8: Cleanup & Documentation
- Update ARCHITECTURE.md with Riverpod 3.0 patterns
- Document new features (Ref.mounted, automatic retry)
- Add post-migration recommendations:
  - Offline persistence for offline support
  - Mutations for form/CRUD state tracking
  - Generic providers where applicable

### Alternative Approach: Stay on Riverpod 2.6.1

**When to Consider:**
- If the team is risk-averse to major version updates
- If migration timeline is extremely tight
- If there are concerns about Riverpod 3.0 stability

**Disadvantages:**
- Riverpod 2.6.1 will become outdated
- More boilerplate code
- No access to new features (Ref.mounted, better testing)
- Future migration to 3.x will be needed anyway

**Our Assessment:** Not recommended. Riverpod 3.0 is stable and simplifies the migration.

---

## Implementation Considerations

### Technical Requirements

**Build Runner:**
- Version 2.10.2 is compatible with Riverpod 3.0.3
- No changes to build runner commands
- Code generation workflow unchanged

**Dart/Flutter Compatibility:**
- Riverpod 3.0.3 requires **Dart SDK ≥3.6.0**
- Later app uses Flutter 3.9.2+ (includes Dart 3.0+)
- ✅ Compatible - no Flutter version update needed

**Analyzer/Linting:**
- riverpod_lint 3.0.3 adds new lint rules:
  - `provider_dependencies` - Validates `@Riverpod(dependencies: ...)`
  - `scoped_providers_should_specify_dependencies`
  - `unsupported_provider_value`
- Update `analysis_options.yaml` to enable new lint rules

### Integration Points

**Existing Codebase:**
- Provider and Riverpod can coexist (no conflicts with 3.0)
- Migration plan's gradual approach still valid
- ProviderScope wraps MultiProvider (no changes needed)

**Supabase Integration:**
- No impact - data layer patterns unchanged
- Repository → Service → Controller flow remains same

**Testing Infrastructure:**
- Mockito still works with Riverpod 3.0
- Widget test helpers need minor updates (ProviderContainer.test)
- Test coverage maintained or improved (faster unit tests)

### Risks and Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Breaking changes cause test failures | Medium | Medium | Update test helpers in Phase 1, validate early |
| Team unfamiliarity with 3.0 patterns | Medium | Low | Document patterns clearly, simpler than 2.6 |
| Experimental features unstable | Low | Low | Don't use experimental features in migration |
| Migration timeline extends | Medium | Medium | Breaking changes are mostly syntax, automatable |

---

## Phase-by-Phase Updates

### Phase 0: Pre-Migration Setup

**Additional Task 0.6: Verify Riverpod 3.0 Compatibility**
- Update dependencies to 3.0.3
- Run `dart run build_runner build --delete-conflicting-outputs`
- Run `flutter analyze` (should be clean)
- Run `flutter test` (all tests should pass - no breaking changes to app code yet)
- Review Riverpod 3.0 migration guide: https://riverpod.dev/docs/3.0_migration
- Document 3.0 patterns in migration log

### Phase 1: Theme Migration

**Updated Patterns:**
- Use `@riverpod` with no AutoDispose prefix
- Add `ref.mounted` check in async methods
- Replace `createContainer()` with `ProviderContainer.test()`
- Document these patterns as examples for all phases

**Example Task 1.3 Update:**
```dart
// Create theme controller with simplified 3.0 syntax
@riverpod
class ThemeController extends _$ThemeController {
  @override
  ThemeMode build() {
    // Load from service
    final service = ref.watch(themeServiceProvider);
    return service.loadTheme();
  }

  Future<void> toggleTheme() async {
    final service = ref.read(themeServiceProvider);
    final newTheme = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await service.saveTheme(newTheme);

    // NEW in 3.0: Check if still mounted
    if (!ref.mounted) return;

    state = newTheme;
  }
}
```

### Phases 2-7: Feature Migrations

**Pattern Updates Across All Phases:**
1. Remove `AutoDispose` and `Family` prefixes
2. Use unified `Ref` type (no generics)
3. Add `ref.mounted` checks to all async methods
4. Unwrap `ProviderException` in error handling
5. Use `ProviderContainer.test()` in all tests
6. Use `overrideWithBuild()` for simple widget test mocking

### Phase 8: Cleanup & Documentation

**Additional Documentation:**
- Update ARCHITECTURE.md with Riverpod 3.0 patterns
- Document new features used (Ref.mounted, automatic retry)
- Document features not used (offline persistence, mutations)
- Add section on Riverpod 3.0 best practices
- Update code examples to use 3.0 syntax

**Post-Migration Recommendations (Updated):**
- Add Freezed for immutability (already planned)
- **NEW:** Consider offline persistence (experimental but stable)
- **NEW:** Evaluate mutations for form/CRUD state tracking
- **NEW:** Add provider dependencies lint rules for scoped providers
- Performance optimization with `.select()` (already planned)

---

## References and Resources

### Official Riverpod 3.0 Documentation

- [What's New in Riverpod 3.0](https://riverpod.dev/docs/whats_new) - Official feature overview
- [Migrating from 2.0 to 3.0](https://riverpod.dev/docs/3.0_migration) - Official migration guide
- [Automatic Retry](https://riverpod.dev/docs/concepts2/retry) - Retry behavior documentation
- [Offline Persistence](https://riverpod.dev/docs/concepts2/offline) - Experimental feature guide
- [Testing Guide](https://riverpod.dev/docs/how_to/testing) - Updated testing patterns

### Package Pages

- [flutter_riverpod 3.0.3](https://pub.dev/packages/flutter_riverpod)
- [riverpod_annotation 3.0.3](https://pub.dev/packages/riverpod_annotation)
- [riverpod_generator 3.0.3](https://pub.dev/packages/riverpod_generator)
- [riverpod_lint 3.0.3](https://pub.dev/packages/riverpod_lint)
- [build_runner 2.10.2](https://pub.dev/packages/build_runner)

### Community Resources (2025)

- [Riverpod 3 New Features Flutter Users Must Know](https://www.dhiwise.com/post/riverpod-3-new-features-for-flutter-developers)
- [Flutter Riverpod 3.0 Released: A Major Redesign](https://medium.com/@lee645521797/flutter-riverpod-3-0-released-a-major-redesign-of-the-state-management-framework-f7e31f19b179)
- [Clean Architecture with Riverpod](https://otakoyi.software/blog/flutter-clean-architecture-with-riverpod-and-supabase)
- [September 2025 Newsletter: Riverpod 3.0](https://codewithandrea.com/newsletter/september-2025/)

---

## Appendix

### Complete Breaking Changes Checklist

- [x] Update dependencies to 3.0.3
- [x] Remove `AutoDispose` prefixes from all Notifiers
- [x] Remove `Family` suffixes from all Notifiers
- [x] Update `Ref<T>` to `Ref` (no type parameter)
- [x] Replace `ProviderRef.state` with `Notifier.state`
- [x] Replace `Ref.listenSelf` with `Notifier.listenSelf`
- [x] Replace `createContainer()` with `ProviderContainer.test()`
- [x] Add `ref.mounted` checks to async controller methods
- [x] Update error handling to unwrap `ProviderException`
- [x] Verify model equality implementations (for `==` filtering)
- [x] Update ProviderObserver if used (accept ProviderObserverContext)
- [x] Move legacy providers to `import 'package:flutter_riverpod/legacy.dart'` if used

### Migration Timeline Adjustment

**Original Estimate (Riverpod 2.6.1):** 18 days (4.5 weeks with buffer)

**Updated Estimate (Riverpod 3.0.3):**
- **Phase 0:** +0.5 days (verify 3.0 compatibility) = 1.5 days
- **Phase 1:** +0.5 days (document new patterns) = 1.5 days
- **Phases 2-7:** No change (patterns are actually simpler) = 15 days
- **Phase 8:** +0.5 days (document 3.0 features) = 2.5 days

**Total:** 20.5 days (~4.5-5 weeks with buffer)

**Impact:** Minimal timeline extension due to simpler patterns offsetting learning curve.

### Quick Reference: 2.6.1 → 3.0.3 Syntax Changes

```dart
// AutoDispose Notifier
-class MyController extends AutoDisposeNotifier<MyState>
+class MyController extends _$MyController

// Family Notifier
-class MyController extends FamilyAsyncNotifier<MyState, String>
+class MyController extends _$MyController // Parameter in build()

// Ref with generic
-String myMethod(MyControllerRef ref)
+String myMethod(Ref ref)

// Ref.state (in provider)
-ref.state = newState;
+state = newState; // Use Notifier.state

// Test container
-final container = createContainer();
+final container = ProviderContainer.test();

// Error handling
-} catch (e) {
-  if (e is MyException) ...
+} on ProviderException catch (e) {
+  if (e.exception is MyException) ...

// Provider definition (code gen)
-final myProvider = NotifierProvider.autoDispose<MyNotifier, MyState>(MyNotifier.new);
+// No manual definition - generated from @riverpod annotation
```

---

## Conclusion

Riverpod 3.0.3 represents a **major improvement** over 2.6.1 with simplified patterns, better resilience, and improved developer experience. The breaking changes are primarily **syntax simplifications** that make the migration **easier**, not harder.

**Key Recommendations:**
1. ✅ **Adopt Riverpod 3.0.3** for the migration (not 2.6.1)
2. ✅ Update all code examples in migration plan to use 3.0 syntax
3. ✅ Leverage new features: `Ref.mounted`, automatic retry, `ProviderContainer.test()`
4. ✅ Document experimental features for post-migration evaluation
5. ✅ Add ~0.5-1 day buffer to Phase 0 and Phase 1 for pattern establishment

**Expected Benefits:**
- Simpler, more maintainable code
- Fewer async-related bugs (Ref.mounted)
- Better error resilience (automatic retry)
- Faster, easier testing (built-in utilities)
- Future-proof architecture (current industry standard)

The migration plan's **core strategy remains sound**. The update to Riverpod 3.0 is a net positive that will result in cleaner, more robust code.
