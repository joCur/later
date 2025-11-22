# Research: Live Counter Update Issue in Detail Screens

## Executive Summary

The counter displays (e.g., "4/7 completed" for TodoLists and checked items for Lists) in detail screens do not update live when items are toggled. Users must navigate back to the list view and then return to see updated counts. This issue stems from a **broken data flow** where the detail screen expects updates from the parent controller, but the parent controller is only refreshed **after** the detail screen's state management operations complete, causing a race condition where the local state (`_currentTodoList` / `_currentList`) never receives the updated counts.

The root cause is an **architectural issue** in how item state changes propagate to parent list counts. The current implementation calls `refreshTodoList()` or `refresh()` on the parent controller **after** item operations, but the detail screen's listener doesn't receive these updates because they're reading stale data from the parent controller state.

## Research Scope

**What was researched:**
- Data flow from item toggle/CRUD operations to counter display updates
- State management pattern using Riverpod 3.0 family providers
- Repository layer count calculation and caching behavior
- Detail screen listener implementation for parent controller updates
- Race conditions in async state updates

**What was excluded:**
- UI/UX design improvements for counter display
- Performance optimizations unrelated to the counter issue
- Alternative state management patterns (Provider, Bloc, etc.)

**Research methodology:**
- Code analysis of detail screens, controllers, and repositories
- Trace of data flow from item toggle to counter update
- Identification of state update timing issues

## Current State Analysis

### Existing Implementation

**Detail Screen Pattern (TodoListDetailScreen):**

```dart
// Line 53-67: Initialize local state from widget
late TodoList _currentTodoList;

@override
void initState() {
  _currentTodoList = widget.todoList;

  // Listen to parent controller for updates
  ref.listenManual(
    todoListsControllerProvider(widget.todoList.spaceId),
    (previous, next) {
      next.whenData((lists) {
        final updated = lists.firstWhere(
          (tl) => tl.id == _currentTodoList.id,
          orElse: () => _currentTodoList,
        );
        if (mounted && updated != _currentTodoList) {
          setState(() {
            _currentTodoList = updated;  // ← Should update counts here
          });
        }
      });
    },
    fireImmediately: true,
  );
}

// Line 277-293: Toggle item operation
Future<void> _toggleTodoItem(TodoItem item) async {
  try {
    // Toggle item via Riverpod controller
    await ref
        .read(todoItemsControllerProvider(widget.todoList.id).notifier)
        .toggleItem(item.id, _currentTodoList.id);

    // Refresh parent list to get updated counts
    await ref
        .read(todoListsControllerProvider(widget.todoList.spaceId).notifier)
        .refreshTodoList(widget.todoList.id);  // ← Called AFTER toggle
  } catch (e) {
    // Error handling...
  }
}

// Line 609-612: Counter display in UI
Text(
  l10n.todoDetailProgressCompleted(
    _currentTodoList.completedItemCount,  // ← Never updates
    _currentTodoList.totalItemCount,
  ),
  // ...
)
```

**Parent Controller Refresh Pattern:**

```dart
// TodoListsController.refreshTodoList() - Line 149-166
Future<void> refreshTodoList(String todoListId) async {
  final service = ref.read(todoListServiceProvider);

  try {
    // Reload all lists - this refreshes counts from the database
    final updated = await service.getTodoListsForSpace(spaceId);

    if (!ref.mounted) return;

    state = AsyncValue.data(updated);  // ← Updates parent state
  } catch (e) {
    if (ref.mounted) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
```

**Repository Count Calculation:**

```dart
// TodoListRepository.getBySpace() - Line 108-136
Future<List<TodoList>> getBySpace(String spaceId) async {
  return executeQuery(() async {
    final response = await supabase
        .from('todo_lists')
        .select()
        .eq('space_id', spaceId)
        .eq('user_id', userId)
        .order('sort_order', ascending: true);

    final todoLists = (response as List)
        .map((json) => TodoList.fromJson(json as Map<String, dynamic>))
        .toList();

    // Fetch counts for each todo list
    final todoListsWithCounts = await Future.wait(
      todoLists.map((todoList) async {
        final items = await getTodoItemsByListId(todoList.id);
        final totalCount = items.length;
        final completedCount = items.where((item) => item.isCompleted).length;

        return todoList.copyWith(
          totalItemCount: totalCount,
          completedItemCount: completedCount,
        );
      }),
    );

    return todoListsWithCounts;
  });
}
```

### Problem Identification

**The Issue:**
The detail screen's listener (`listenManual`) on the parent controller **does fire** when `refreshTodoList()` is called, but there's a **race condition** and **equality check issue**:

1. **Race Condition**: When `_toggleTodoItem()` calls `refreshTodoList()`, the parent controller state is updated asynchronously
2. **Equality Check**: The listener has `if (updated != _currentTodoList)` which compares TodoList objects
3. **Reference Equality**: Even if counts change, the `!=` check may fail if the TodoList model doesn't properly override `==` and `hashCode`
4. **Timing Issue**: The local `_currentTodoList` state is based on the **initial widget.todoList**, not the live parent state

**Data Flow Problem:**

```
1. User toggles item checkbox
2. _toggleTodoItem() calls todoItemsController.toggleItem()
3. todoItemsController updates item in database
4. _toggleTodoItem() calls todoListsController.refreshTodoList()
5. refreshTodoList() queries database and gets new counts
6. refreshTodoList() updates parent state: state = AsyncValue.data(updated)
7. listenManual() callback fires
8. Callback finds updated TodoList in lists array
9. Callback checks: if (updated != _currentTodoList)
   → This check FAILS if TodoList doesn't override equals
   → OR the counts are the same in memory as in _currentTodoList
10. Counter never updates in UI
```

**Root Cause Analysis:**

Looking at the code, the primary issues are:

1. **No TodoList equality override**: The `!=` check in the listener likely compares references, not values
2. **Async state propagation delay**: The database query in `refreshTodoList()` takes time, so the listener may fire before counts are recalculated
3. **Listener not detecting count changes**: Even if the listener fires, the equality check prevents state update

## Technical Analysis

### Approach 1: Override `==` and `hashCode` in TodoList/ListModel

**Description:**
Add proper equality implementation to `TodoList` and `ListModel` models to ensure the `!=` check in the listener works correctly when counts change.

**Pros:**
- Minimal code changes
- Fixes the equality check issue
- Follows Dart best practices for value objects
- No architectural changes needed

**Cons:**
- Doesn't address async propagation delay
- Requires implementing equality for all fields (can be verbose)
- May not solve the issue if counts are cached incorrectly

**Use Cases:**
- When the listener is firing but not detecting changes
- When you want minimal code changes

**Implementation:**

```dart
// In TodoList model
@override
bool operator ==(Object other) =>
    identical(this, other) ||
    other is TodoList &&
        runtimeType == other.runtimeType &&
        id == other.id &&
        name == other.name &&
        spaceId == other.spaceId &&
        totalItemCount == other.totalItemCount &&  // ← Include counts
        completedItemCount == other.completedItemCount &&
        // ... other fields

@override
int get hashCode =>
    id.hashCode ^
    name.hashCode ^
    spaceId.hashCode ^
    totalItemCount.hashCode ^
    completedItemCount.hashCode ^
    // ... other fields
```

### Approach 2: Remove Equality Check in Listener

**Description:**
Remove the `if (updated != _currentTodoList)` check in the listener to always update local state when parent state changes.

**Pros:**
- Simple one-line change
- Guarantees state update on every parent refresh
- No need to implement equality operators

**Cons:**
- May cause unnecessary rebuilds
- Doesn't address root architectural issue
- Could trigger setState() with identical values

**Use Cases:**
- Quick fix for the immediate problem
- When performance impact is acceptable

**Implementation:**

```dart
ref.listenManual(
  todoListsControllerProvider(widget.todoList.spaceId),
  (previous, next) {
    next.whenData((lists) {
      final updated = lists.firstWhere(
        (tl) => tl.id == _currentTodoList.id,
        orElse: () => _currentTodoList,
      );
      // Remove: if (mounted && updated != _currentTodoList)
      if (mounted) {  // ← Just check mounted
        setState(() {
          _currentTodoList = updated;
        });
      }
    });
  },
  fireImmediately: true,
);
```

### Approach 3: Direct Count Update via Item Controller

**Description:**
Update the local `_currentTodoList` counts directly in the toggle method **before** calling the parent refresh, using the current item state.

**Pros:**
- Immediate UI feedback (optimistic update)
- No waiting for database query
- Better user experience

**Cons:**
- Counts may temporarily be out of sync if other operations fail
- Duplicate state management logic
- Requires manual count calculation

**Use Cases:**
- When you want instant UI updates
- When database queries are slow

**Implementation:**

```dart
Future<void> _toggleTodoItem(TodoItem item) async {
  // Optimistic count update
  final newCompletedCount = item.isCompleted
      ? _currentTodoList.completedItemCount - 1
      : _currentTodoList.completedItemCount + 1;

  setState(() {
    _currentTodoList = _currentTodoList.copyWith(
      completedItemCount: newCompletedCount,
    );
  });

  try {
    await ref
        .read(todoItemsControllerProvider(widget.todoList.id).notifier)
        .toggleItem(item.id, _currentTodoList.id);

    // Still refresh parent for other screens
    await ref
        .read(todoListsControllerProvider(widget.todoList.spaceId).notifier)
        .refreshTodoList(widget.todoList.id);
  } catch (e) {
    // Revert optimistic update on error
    setState(() {
      _currentTodoList = _currentTodoList.copyWith(
        completedItemCount: item.isCompleted
            ? _currentTodoList.completedItemCount + 1
            : _currentTodoList.completedItemCount - 1,
      );
    });
    // Error handling...
  }
}
```

### Approach 4: Watch Item Controller and Calculate Counts Locally

**Description:**
Instead of relying on parent controller for counts, watch the `todoItemsControllerProvider` and calculate counts from the items list directly in the UI.

**Pros:**
- Real-time updates as items change
- No dependency on parent controller refresh
- Single source of truth (items list)
- Eliminates async propagation issues

**Cons:**
- Changes architecture pattern
- Duplicates count calculation logic
- May impact performance with large item lists

**Use Cases:**
- When you want guaranteed live updates
- When count calculation is simple

**Implementation:**

```dart
// In build method
final todoItemsAsync = ref.watch(todoItemsControllerProvider(widget.todoList.id));

// Calculate counts from items
final countsData = todoItemsAsync.whenOrNull(
  data: (items) {
    final total = items.length;
    final completed = items.where((item) => item.isCompleted).length;
    return (total: total, completed: completed);
  },
);

// Use calculated counts in UI
Text(
  l10n.todoDetailProgressCompleted(
    countsData?.completed ?? _currentTodoList.completedItemCount,
    countsData?.total ?? _currentTodoList.totalItemCount,
  ),
)
```

### Approach 5: Stream-Based Real-Time Updates (Supabase Realtime)

**Description:**
Use Supabase Realtime subscriptions to listen to database changes and update counts automatically when items are toggled by any client.

**Pros:**
- True real-time updates across all clients
- No manual refresh needed
- Scales to multi-user scenarios
- Eliminates polling and manual sync

**Cons:**
- Requires Supabase Realtime setup
- More complex implementation
- Adds dependency on WebSocket connection
- May have cost implications at scale

**Use Cases:**
- Multi-user collaborative features
- When you need instant cross-device sync
- Production apps with real-time requirements

**Implementation:**

```dart
// In repository or service
Stream<TodoList> watchTodoList(String id) {
  return supabase
      .from('todo_lists')
      .stream(primaryKey: ['id'])
      .eq('id', id)
      .map((data) => TodoList.fromJson(data.first));
}

// In controller (using @riverpod for stream)
@riverpod
Stream<TodoList> watchTodoList(WatchTodoListRef ref, String id) {
  final repo = ref.read(todoListRepositoryProvider);
  return repo.watchTodoList(id);
}

// In detail screen
ref.listen(
  watchTodoListProvider(widget.todoList.id),
  (previous, next) {
    next.whenData((updated) {
      if (mounted) {
        setState(() {
          _currentTodoList = updated;
        });
      }
    });
  },
);
```

## Tools and Libraries

### Option 1: equatable Package

- **Purpose**: Simplifies equality and hashCode implementation for value objects
- **Maturity**: Production-ready (widely used in Flutter community)
- **License**: MIT
- **Community**: Very large and active
- **Integration Effort**: Low
- **Key Features**:
  - Automatic equality based on props list
  - No need to manually write `==` and `hashCode`
  - Type-safe comparisons

**Usage:**
```dart
import 'package:equatable/equatable.dart';

class TodoList extends Equatable {
  final String id;
  final int totalItemCount;
  final int completedItemCount;
  // ... other fields

  @override
  List<Object?> get props => [
    id,
    name,
    totalItemCount,
    completedItemCount,
    // ... other fields
  ];
}
```

### Option 2: freezed Package (Already in use)

- **Purpose**: Code generation for immutable models with built-in equality
- **Maturity**: Production-ready (official recommendation)
- **License**: MIT
- **Community**: Very large, maintained by Flutter team members
- **Integration Effort**: Medium (requires code generation setup)
- **Key Features**:
  - Automatic `==`, `hashCode`, `copyWith`, `toString()`
  - Union types and sealed classes
  - JSON serialization support

**Usage:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_list.freezed.dart';
part 'todo_list.g.dart';

@freezed
class TodoList with _$TodoList {
  factory TodoList({
    required String id,
    required int totalItemCount,
    required int completedItemCount,
    // ... other fields
  }) = _TodoList;

  factory TodoList.fromJson(Map<String, dynamic> json) =>
      _$TodoListFromJson(json);
}
```

**Note:** The project already uses Riverpod code generation, so adding `freezed` is a natural fit.

## Implementation Considerations

### Technical Requirements

**Dependencies:**
- Current: `riverpod_annotation: ^2.6.1` (for code generation)
- Potential: `equatable: ^2.0.5` OR convert models to `freezed`

**Performance Implications:**
- Approach 1-2: Minimal performance impact
- Approach 3: Adds computational cost for optimistic updates
- Approach 4: Recalculates counts on every item controller update
- Approach 5: Adds WebSocket overhead

**Scalability Considerations:**
- Approaches 1-3: Scale well with current architecture
- Approach 4: May become expensive with 100+ items
- Approach 5: Best for long-term scalability

### Integration Points

**Affected Files:**
1. `lib/features/todo_lists/domain/models/todo_list.dart`
2. `lib/features/lists/domain/models/list_model.dart`
3. `lib/features/todo_lists/presentation/screens/todo_list_detail_screen.dart`
4. `lib/features/lists/presentation/screens/list_detail_screen.dart`

**Required Modifications:**
- **Approach 1**: Modify models to add `==` and `hashCode`
- **Approach 2**: Modify detail screens (2 files)
- **Approach 3**: Modify detail screens with optimistic updates
- **Approach 4**: Modify detail screens to watch item controllers
- **Approach 5**: Add Supabase Realtime setup, modify repositories and controllers

### Risks and Mitigation

**Risk 1: Equality Implementation Bugs**
- **Impact**: Incorrect equality may cause missed updates or false positives
- **Mitigation**: Comprehensive unit tests for model equality

**Risk 2: Optimistic Update Race Conditions**
- **Impact**: UI shows wrong counts if server rejects update
- **Mitigation**: Proper error handling with state rollback (Approach 3)

**Risk 3: Performance Degradation with Approach 4**
- **Impact**: Recalculating counts on every update may be slow
- **Mitigation**: Memoization or caching of count calculations

**Risk 4: Supabase Realtime Connection Issues**
- **Impact**: Updates may be delayed or lost if WebSocket disconnects
- **Mitigation**: Fallback to polling, connection retry logic

## Recommendations

### Recommended Approach

**Primary Recommendation: Approach 2 + Approach 4 (Hybrid)**

Combine two approaches for maximum reliability:

1. **Remove equality check in listener** (Approach 2) to ensure parent updates always propagate
2. **Watch item controller and calculate counts** (Approach 4) for immediate live updates

**Rationale:**
- **Approach 2** fixes the immediate bug with minimal changes
- **Approach 4** provides true live updates and eliminates dependency on parent refresh timing
- Hybrid approach is more robust than either alone
- No need for complex equality implementation or Supabase Realtime
- Aligns with existing Riverpod architecture

**Implementation Steps:**

1. **Modify detail screens** (TodoListDetailScreen, ListDetailScreen):
   - Remove `if (updated != _currentTodoList)` check in listener
   - Add `ref.watch(todoItemsControllerProvider(listId))` in build method
   - Calculate counts from items list
   - Use calculated counts in progress bar UI

2. **Keep existing parent refresh logic** for consistency across app

3. **Add unit tests** to verify counts update correctly

### Alternative Approach (If Models Become `freezed`)

If the project decides to migrate models to `freezed` (which is recommended for other reasons like immutability and JSON serialization):

**Use Approach 1 (freezed provides equality) + Approach 4**

This gives you:
- Automatic equality from `freezed`
- Live count updates from watching item controller
- Better model immutability guarantees
- Easier state management

### Phased Implementation Strategy

**Phase 1 (Immediate Fix):**
- Implement Approach 2 (remove equality check)
- Deploy to fix the bug quickly

**Phase 2 (Better UX):**
- Implement Approach 4 (watch item controller for counts)
- Ensures counts are always live

**Phase 3 (Future Enhancement):**
- Consider Approach 5 (Supabase Realtime) if multi-user collaboration is added
- Provides cross-device sync

## References

### Documentation
- [Riverpod 3.0 Best Practices](https://riverpod.dev/docs/essentials/combining_requests)
- [Flutter State Management Patterns](https://docs.flutter.dev/data-and-backend/state-mgmt/options)
- [Supabase Realtime](https://supabase.com/docs/guides/realtime)

### Code Repositories
- [Riverpod Examples - Real-time Updates](https://github.com/rrousselGit/riverpod/tree/master/examples)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)

### Related Files in Codebase
- `lib/features/todo_lists/presentation/screens/todo_list_detail_screen.dart:113-130`
- `lib/features/todo_lists/presentation/controllers/todo_lists_controller.dart:149-166`
- `lib/features/todo_lists/data/repositories/todo_list_repository.dart:108-136`
- `lib/features/lists/presentation/screens/list_detail_screen.dart:112-129`
- `lib/features/lists/presentation/controllers/lists_controller.dart:152-167`
- `lib/features/lists/data/repositories/list_repository.dart:104-133`

## Appendix

### Additional Notes

**Why Counts Don't Update in Current Implementation:**

The key insight is that the listener **does fire**, but the state update is blocked by:

1. The `!=` check comparing objects without proper equality
2. Even if equality is implemented, there's still an async gap between:
   - Item toggle completing
   - Database recalculating counts
   - Parent controller fetching updated counts
   - Listener receiving new state

This creates a window where `_currentTodoList` and the "updated" list from parent state have the **same counts** because the database hasn't propagated the change yet.

**The Hybrid Approach solves this by:**
- Removing the equality barrier (Approach 2)
- Providing a direct, synchronous count source (Approach 4)
- Maintaining backward compatibility with existing architecture

### Questions for Further Investigation

1. Are there other places in the app where similar patterns cause stale UI?
2. Should the project standardize on `freezed` for all models?
3. Is Supabase Realtime needed for future collaborative features?
4. How do count updates behave under poor network conditions?

### Related Topics Worth Exploring

- Optimistic UI updates throughout the app
- Offline-first architecture with local state caching
- Real-time collaboration features
- State reconciliation patterns when server state diverges from local state
