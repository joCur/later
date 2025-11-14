# Riverpod 3.0 Patterns - Quick Reference

This document provides quick reference patterns for Riverpod 3.0.3 features and breaking changes.

## Key Breaking Changes from 2.x

### 1. AutoDispose is Now Default
```dart
// Old (2.x) - Explicit AutoDispose
class MyControllerAutoDispose extends AutoDisposeNotifier<MyState> {
  @override
  MyState build() => MyState();
}

// New (3.0) - Default AutoDispose
@riverpod
class MyController extends _$MyController {
  @override
  MyState build() => MyState();
  // Auto-disposed by default!
}

// To keep alive (disable auto-dispose):
@Riverpod(keepAlive: true)
class MyRepository extends _$MyRepository {
  @override
  MyRepo build() => MyRepo();
}
```

### 2. Unified Ref Type (No Generics)
```dart
// Old (2.x)
class MyController extends AutoDisposeNotifier<MyState> {
  @override
  MyState build() {
    ref.listenSelf((previous, next) { ... });
    return MyState();
  }
}

// New (3.0)
@riverpod
class MyController extends _$MyController {
  @override
  MyState build() {
    listenSelf((previous, next) { ... });  // No ref prefix!
    return MyState();
  }
}
```

### 3. Family Parameters Automatically Inferred
```dart
// Old (2.x) - Complex
class TodoListController extends AutoDisposeFamilyAsyncNotifier<List<TodoList>, String> {
  @override
  Future<List<TodoList>> build(String spaceId) async { ... }
}

// New (3.0) - Simple
@riverpod
class TodoListController extends _$TodoListController {
  @override
  Future<List<TodoList>> build(String spaceId) async { ... }
  // Family parameter automatically inferred from build() signature!
}

// Usage is the same:
ref.watch(todoListControllerProvider('space-123'))
```

## New Features in Riverpod 3.0

### 1. Automatic Retry with Exponential Backoff
```dart
@riverpod
Future<List<Note>> notes(Ref ref) async {
  final service = ref.watch(noteServiceProvider);
  return service.getNotes();
  // Automatically retries on failure:
  // 200ms → 400ms → 800ms → up to 6.4s
}

// Disable retry if needed:
@Riverpod(retry: (count, error) => null)
Future<List<Note>> notesNoRetry(Ref ref) async {
  // Will not retry
}

// Custom retry logic:
@Riverpod(retry: (count, error) => count < 5 ? 1000 : null)
Future<List<Note>> notesCustomRetry(Ref ref) async {
  // Retries up to 5 times with 1 second delay
}
```

### 2. Ref.mounted for Async Safety
```dart
@riverpod
class TodoItemController extends _$TodoItemController {
  @override
  List<TodoItem> build(String listId) => [];

  Future<void> createItem(TodoItem item) async {
    final service = ref.read(todoListServiceProvider);
    final created = await service.createTodoItem(item);

    // NEW in 3.0: Check if provider still mounted before updating state
    if (!ref.mounted) return;  // Prevents "setState after dispose"

    state = [...state, created];
  }
}
```

### 3. ProviderContainer.test() for Testing
```dart
// Old (2.x) - Custom helper
ProviderContainer createContainer() {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container;
}

// New (3.0) - Built-in utility
test('my test', () {
  final container = ProviderContainer.test(
    overrides: [myServiceProvider.overrideWithValue(mockService)],
  );
  // Automatically disposed after test - no tearDown needed!

  final controller = container.read(myControllerProvider.notifier);
  controller.performAction();

  expect(container.read(myControllerProvider), expectedState);
});
```

### 4. overrideWithBuild() for Widget Tests
```dart
// Old (2.x) - Mock entire notifier
class MockController extends Mock implements TodoListController {}

testWidgets('test', (tester) async {
  final mock = MockController();
  when(mock.build(any)).thenReturn([]);
  // Complex setup...
});

// New (3.0) - Mock only build method
testWidgets('test', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todoListControllerProvider('space-id').overrideWithBuild(
          (ref, arg) => [], // Simple mock data!
        ),
      ],
      child: testApp(MyWidget()),
    ),
  );

  expect(find.text('Expected UI'), findsOneWidget);
});
```

### 5. tester.container for Widget Tests
```dart
testWidgets('test', (tester) async {
  await tester.pumpWidget(
    ProviderScope(child: testApp(MyWidget())),
  );

  // NEW in 3.0: Access container directly
  final container = tester.container;
  final value = container.read(myProvider);

  expect(value, expectedValue);
});
```

### 6. ProviderException Wrapping
```dart
// All provider errors are wrapped in ProviderException

// Old (2.x) - Catch original exceptions
try {
  final notes = await ref.read(notesProvider(spaceId).future);
} on AppError catch (e) {
  // Handle AppError
}

// New (3.0) - Unwrap ProviderException
try {
  final notes = await ref.read(notesProvider(spaceId).future);
} on ProviderException catch (e) {
  if (e.exception is AppError) {
    final appError = e.exception as AppError;
    // Handle AppError
  }
}
```

## Common Patterns

### Simple Provider (Read-Only)
```dart
@riverpod
MyService myService(Ref ref) {
  final repository = ref.watch(myRepositoryProvider);
  return MyService(repository: repository);
}
```

### State Provider (Mutable)
```dart
@riverpod
class CounterController extends _$CounterController {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
}
```

### Async Provider (FutureProvider)
```dart
@riverpod
Future<List<Note>> notes(Ref ref, String spaceId) async {
  final service = ref.watch(noteServiceProvider);
  return service.getNotesForSpace(spaceId);
}
```

### Async State Provider (AsyncNotifier)
```dart
@riverpod
class NotesController extends _$NotesController {
  @override
  Future<List<Note>> build(String spaceId) async {
    final service = ref.watch(noteServiceProvider);
    return service.getNotesForSpace(spaceId);
  }

  Future<void> createNote(Note note) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(noteServiceProvider);
      final created = await service.createNote(note);

      if (!ref.mounted) return state.value!;

      return [...state.value!, created];
    });
  }
}
```

### Keep-Alive Provider (Repositories, Services)
```dart
@Riverpod(keepAlive: true)
NoteRepository noteRepository(Ref ref) {
  return NoteRepository();
}

@Riverpod(keepAlive: true)
NoteService noteService(Ref ref) {
  final repository = ref.watch(noteRepositoryProvider);
  return NoteService(repository: repository);
}
```

## Testing Patterns

### Service Unit Test (Pure Dart)
```dart
void main() {
  group('NoteService', () {
    late MockNoteRepository mockRepo;
    late NoteService service;

    setUp(() {
      mockRepo = MockNoteRepository();
      service = NoteService(repository: mockRepo);
    });

    test('should create note', () async {
      final note = Note(id: '1', title: 'Test');
      when(mockRepo.createNote(note)).thenAnswer((_) async => note);

      final result = await service.createNote(note);

      expect(result, note);
      verify(mockRepo.createNote(note)).called(1);
    });
  });
}
```

### Controller Test (Riverpod 3.0)
```dart
void main() {
  group('NotesController', () {
    test('should load notes', () async {
      final mockService = MockNoteService();
      when(mockService.getNotesForSpace('space-1'))
          .thenAnswer((_) async => [testNote]);

      final container = ProviderContainer.test(
        overrides: [
          noteServiceProvider.overrideWithValue(mockService),
        ],
      );

      final controller = container.read(
        notesControllerProvider('space-1').notifier,
      );

      // Wait for initial load
      await container.read(notesControllerProvider('space-1').future);

      final state = container.read(notesControllerProvider('space-1'));
      expect(state.value, [testNote]);
    });
  });
}
```

### Widget Test (Riverpod 3.0)
```dart
testWidgets('should display notes', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        notesControllerProvider('space-1').overrideWithBuild(
          (ref, arg) => [testNote],
        ),
      ],
      child: testApp(NotesScreen(spaceId: 'space-1')),
    ),
  );

  expect(find.text('Test Note'), findsOneWidget);
});
```

## Migration Checklist

When migrating a provider to Riverpod 3.0:

- [ ] Replace `AutoDispose`/`Family` types with simple `Notifier`
- [ ] Add `@riverpod` annotation
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`
- [ ] Remove `ref.` prefix from `listenSelf`, `state`, etc.
- [ ] Add `ref.mounted` checks to all async mutations
- [ ] Use `@Riverpod(keepAlive: true)` for repositories/services
- [ ] Update tests to use `ProviderContainer.test()`
- [ ] Update widget tests to use `overrideWithBuild()`
- [ ] Remove manual retry logic (use automatic retry)
- [ ] Wrap errors in try/catch for `ProviderException`

## Resources

- Official Riverpod 3.0 Docs: https://riverpod.dev/
- Migration Guide: https://riverpod.dev/docs/3.0_migration
- Automatic Retry: https://riverpod.dev/docs/concepts2/retry
- Testing Guide: https://riverpod.dev/docs/how_to/testing
