# Live Counter Update Fix

## Objective and Scope

Fix the issue where counter displays (e.g., "4/7 completed" for TodoLists and checked items for Lists) in detail screens do not update live when items are toggled. Users currently must navigate back to the list view and return to see updated counts.

**Scope:**
- Fix TodoListDetailScreen counter updates
- Fix ListDetailScreen counter updates
- Ensure counts update immediately when items are toggled
- Maintain compatibility with existing architecture
- No breaking changes to data models or API

## Technical Approach and Reasoning

**Root Cause:**
The detail screens listen to parent controller updates, but the equality check `if (updated != _currentTodoList)` prevents state updates because:
1. TodoList/ListModel don't override `==` and `hashCode`
2. Even if they did, there's a race condition where the listener fires before database counts are recalculated

**Solution: Hybrid Approach (Approach 2 + Approach 4)**

1. **Remove equality check** in listener to ensure parent updates always propagate
2. **Watch item controller directly** to calculate counts from items list for immediate live updates

**Benefits:**
- Immediate UI feedback (no waiting for database queries)
- Single source of truth (items list)
- No need for complex equality implementation
- No dependency on async parent refresh timing
- Aligns with existing Riverpod 3.0 architecture
- Minimal code changes

## Implementation Phases

### Phase 1: Fix TodoListDetailScreen ✅

- [x] Task 1.1: Remove equality check in parent controller listener
  - ✅ Changed `if (mounted && updated != _currentTodoList)` to `if (mounted)` on line 122
  - Parent updates now always propagate to local state

- [x] Task 1.2: Add item controller watch for live count calculation
  - ✅ Added `ref.watch(todoItemsControllerProvider(widget.todoList.id))` in `build()` method
  - ✅ Calculate counts from items using `whenOrNull` for graceful handling
  - ✅ Calculates total count, completed count, and progress value
  - Counts stored in nullable local variables with fallback pattern

- [x] Task 1.3: Update counter display to use calculated counts
  - ✅ Updated counter display to use `calculatedCompletedCount ?? _currentTodoList.completedItemCount`
  - ✅ Updated total count to use `calculatedTotalCount ?? _currentTodoList.totalItemCount`
  - ✅ Updated progress bar to use `calculatedProgress ?? _currentTodoList.progress`
  - Fallback pattern ensures graceful handling during loading states

- [x] Task 1.4: Test TodoList counter updates
  - ✅ Code analysis passed with no issues
  - Ready for manual testing:
    - Run the app and open a TodoList detail screen
    - Toggle items and verify counter updates immediately
    - Test with empty TodoLists (0/0 case)
    - Navigate away and back to verify persistence

### Phase 2: Fix ListDetailScreen

- [ ] Task 2.1: Remove equality check in parent controller listener
  - Open `apps/later_mobile/lib/features/lists/presentation/screens/list_detail_screen.dart`
  - Locate the `listenManual` callback in `initState()` (around line 112-129)
  - Change `if (mounted && updated != _currentList)` to `if (mounted)`
  - This ensures parent updates always propagate to local state

- [ ] Task 2.2: Add item controller watch for live count calculation
  - In the `build()` method, add `ref.watch(listItemsControllerProvider(widget.list.id))`
  - Calculate counts from items: `items.length` for total, `items.where((item) => item.isChecked).length` for checked
  - Use `whenOrNull` to handle loading/error states gracefully
  - Store calculated counts in local variables for use in UI

- [ ] Task 2.3: Update counter/checked display to use calculated counts
  - Locate counter display widgets (progress indicators or checked item displays)
  - Replace `_currentList.checkedItemCount` with calculated checked count
  - Replace `_currentList.totalItemCount` with calculated total count
  - Add fallback to `_currentList` counts if item controller is loading

- [ ] Task 2.4: Test List counter updates
  - Run the app in debug mode
  - Open a List detail screen with checklist style
  - Toggle multiple items and verify counter updates immediately
  - Test with different list styles (simple, checklist, numbered, bullet)
  - Navigate away and back to verify persistence
  - Test with empty Lists (0/0 case)

### Phase 3: Testing and Verification

- [ ] Task 3.1: Manual testing across scenarios
  - Test rapid toggling (multiple items in quick succession)
  - Test with poor network conditions (airplane mode, then reconnect)
  - Test navigation patterns (back button, deep links, app backgrounding)
  - Test with large item counts (20+ items)
  - Verify no performance degradation

- [ ] Task 3.2: Add widget tests for counter updates
  - Create test file: `test/features/todo_lists/presentation/screens/todo_list_detail_screen_test.dart`
  - Test: Counter updates when items are toggled
  - Test: Counter displays correct values on initial load
  - Test: Counter handles loading states gracefully
  - Create test file: `test/features/lists/presentation/screens/list_detail_screen_test.dart`
  - Same tests for ListDetailScreen

- [ ] Task 3.3: Add integration tests for parent-child sync
  - Test: Parent controller refresh still works after changes
  - Test: Home screen list counts update after detail screen changes
  - Test: Multiple detail screens open simultaneously stay in sync
  - Test: Counts remain consistent after app restart

- [ ] Task 3.4: Verify no regressions
  - Run full test suite: `cd apps/later_mobile && flutter test`
  - Verify all existing tests pass
  - Run analyzer: `flutter analyze`
  - Verify no new warnings or errors

## Dependencies and Prerequisites

**Required:**
- Existing Riverpod 3.0 architecture (already in place)
- `todoItemsControllerProvider` and `listItemsControllerProvider` (already exist)
- Item models have `isCompleted` and `isChecked` fields (already exist)

**No new dependencies needed** - this uses existing state management infrastructure.

## Challenges and Considerations

### Challenge 1: Performance with Large Item Lists
**Issue:** Recalculating counts on every item controller update may be expensive with 100+ items

**Mitigation:**
- Current implementation is acceptable for MVP (most users have <50 items per list)
- If performance becomes an issue, add memoization using `useMemoized` from `flutter_hooks`
- Monitor performance metrics after deployment

### Challenge 2: Loading State Flicker
**Issue:** When item controller is loading, might briefly show stale counts

**Mitigation:**
- Use fallback pattern: `calculatedCount ?? _currentList.count`
- Item controller loads quickly (already in memory from list view)
- Consider skeleton loader if flicker is noticeable

### Challenge 3: Race Condition with Optimistic Updates
**Issue:** User toggles item → UI updates → database rejects update → counts out of sync

**Mitigation:**
- Item toggle operations already have error handling
- On error, item controller refreshes from database (resets counts)
- This is acceptable for MVP - full optimistic update with rollback is future enhancement

### Challenge 4: Multiple Detail Screens Open
**Issue:** If user opens multiple detail screens (e.g., via deep links), they might show different counts temporarily

**Mitigation:**
- Item controllers are family providers (separate instances per list ID)
- Parent controller refresh keeps all screens in sync
- This is edge case - acceptable behavior for MVP

### Challenge 5: Testing Riverpod Listeners
**Issue:** Testing `listenManual` callbacks requires proper Riverpod test setup

**Mitigation:**
- Use `ProviderContainer` in tests
- Mock item controllers with test data
- Use `pumpAndSettle` to wait for async updates
- Refer to existing test patterns in codebase

## Future Enhancements (Out of Scope)

1. **Supabase Realtime** (Approach 5): For multi-user collaboration and cross-device sync
2. **Freezed Models** (Approach 1): Migrate models to `freezed` for automatic equality
3. **Optimistic Updates** (Approach 3): Full optimistic UI with error rollback
4. **Memoization**: Cache count calculations if performance becomes issue

## Success Criteria

- ✅ Counter updates immediately when items are toggled (no navigation required)
- ✅ No regressions in existing functionality
- ✅ All tests pass
- ✅ No new analyzer warnings
- ✅ Performance remains acceptable (<16ms frame time during toggle)
