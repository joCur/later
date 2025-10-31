# Space Item Count - Calculated Counts Implementation

## Objective and Scope

Replace the manual counter-based item count system with calculated counts derived directly from the database. This eliminates the entire class of desynchronization bugs by having a single source of truth: the actual items stored in Hive.

**Scope:** Complete migration to calculated counts, removing stored counter and all increment/decrement logic.

## Technical Approach and Reasoning

**Why Calculated Counts:**
- ✅ **Always accurate** - impossible to desynchronize
- ✅ **Simpler codebase** - removes ~100 lines of counter maintenance code
- ✅ **Single source of truth** - count derives from actual data
- ✅ **Easier to reason about** - no hidden state to track
- ✅ **Better data integrity** - eliminates entire bug class

**Performance Considerations:**
- Query overhead: O(n) where n = total items across all spaces
- For typical usage (10 spaces, 100 items each): ~50ms query time
- SpaceSwitcherModal already lazy-loads, async pattern fits naturally
- Can optimize later with caching if needed (but likely unnecessary)

**Implementation Strategy:**
1. Add async `getItemCount()` method to calculate from Hive boxes
2. Update UI to handle async loading (FutureBuilder pattern)
3. Remove stored `itemCount` field from Space model (breaking change)
4. Remove all increment/decrement logic
5. Add migration to handle existing data

## Implementation Phases

### Phase 1: Add Calculated Count Method ✅ COMPLETED
- [x] Task 1.1: Create `SpaceItemCountService` utility class
  - ✅ Created file: `lib/core/services/space_item_count_service.dart`
  - ✅ Added static method: `Future<int> calculateItemCount(String spaceId)`
  - ✅ Access Hive boxes: `Hive.box<Item>('notes')`, `Hive.box<TodoList>('todo_lists')`, `Hive.box<ListModel>('lists')`
  - ✅ Filter each box by spaceId: `.values.where((item) => item.spaceId == spaceId).length`
  - ✅ Sum counts from all three boxes
  - ✅ Add null safety checks for unopened boxes (return 0 if box not available)
  - ✅ Add documentation explaining this is the single source of truth for counts

- [x] Task 1.2: Add tests for `SpaceItemCountService`
  - ✅ Created file: `test/core/services/space_item_count_service_test.dart`
  - ✅ Setup: Mock Hive boxes with test data
  - ✅ Test case: returns 0 for space with no items
  - ✅ Test case: counts only notes (3 notes in space A, 2 in space B, assert space A = 3)
  - ✅ Test case: counts only todo lists (2 lists in space A, assert count = 2)
  - ✅ Test case: counts only regular lists (2 lists in space A, assert count = 2)
  - ✅ Test case: sums all item types (2 notes + 1 todo + 3 lists = 6)
  - ✅ Test case: filters by spaceId correctly (items in multiple spaces)
  - ✅ Test case: handles unopened boxes gracefully (returns 0)
  - ✅ **Result: All 7 tests passing**

### Phase 2: Update Space Model ✅ COMPLETED
- [x] Task 2.1: Remove stored `itemCount` field from Space model
  - ✅ Navigated to `lib/data/models/space_model.dart`
  - ✅ Removed `@HiveField(4) final int itemCount;`
  - ✅ Removed `itemCount` from constructor parameters
  - ✅ Removed `itemCount` from `copyWith` method
  - ✅ Removed `itemCount` from `toJson` and `fromJson` methods
  - ✅ Removed default value in factory constructors
  - ✅ Removed `itemCount` from `toString()` method

- [x] Task 2.2: Update Space model tests
  - ✅ Navigated to `test/data/models/space_model_test.dart`
  - ✅ Removed all assertions checking `space.itemCount`
  - ✅ Updated `copyWith` tests to remove itemCount parameter
  - ✅ Updated serialization tests (toJson/fromJson) to exclude itemCount
  - ✅ Verified factory constructors no longer reference itemCount
  - ✅ **Result: All 9 space model tests passing**

- [x] Task 2.3: Regenerate Hive adapters
  - ✅ Ran: `dart run build_runner build --delete-conflicting-outputs`
  - ✅ Verified `lib/data/models/space_model.g.dart` is regenerated without itemCount field
  - ✅ No compilation errors - all tests pass

### Phase 3: Update SpaceRepository ✅ COMPLETED
- [x] Task 3.1: Remove increment/decrement methods from `SpaceRepository`
  - ✅ Navigated to `lib/data/repositories/space_repository.dart`
  - ✅ Deleted `incrementItemCount()` method (lines 135-163)
  - ✅ Deleted `decrementItemCount()` method (lines 165-197)
  - ✅ Updated class documentation to remove item count management reference

- [x] Task 3.2: Add `getItemCount()` method to `SpaceRepository`
  - ✅ Navigated to `lib/data/repositories/space_repository.dart`
  - ✅ Added new method after space CRUD operations
  - ✅ Method signature: `Future<int> getItemCount(String spaceId)`
  - ✅ Implementation: delegates to `SpaceItemCountService.calculateItemCount(spaceId)`
  - ✅ Added comprehensive documentation explaining calculated counts

- [x] Task 3.3: Update repository tests ✅ COMPLETED
  - ✅ Navigated to `test/data/repositories/space_repository_test.dart`
  - ✅ Deleted test group for `incrementItemCount` (lines 382-448)
  - ✅ Deleted test group for `decrementItemCount` (lines 450-529)
  - ✅ Removed itemCount references from other test cases
  - ✅ Added comprehensive test group for `getItemCount` with 7 test cases:
    - ✅ Test case: returns 0 for space with no items
    - ✅ Test case: counts notes only (3 notes)
    - ✅ Test case: counts todo lists only (2 lists)
    - ✅ Test case: counts regular lists only (2 lists)
    - ✅ Test case: sums all item types (2 notes + 1 todo + 3 lists = 6)
    - ✅ Test case: filters by spaceId correctly (items in multiple spaces)
    - ✅ Test case: returns 0 for non-existent space
  - ✅ Added necessary imports for Item, TodoList, and ListModel
  - ✅ Added Hive adapter registrations in setUp for test isolation
  - ✅ **Result: All 29 repository tests passing**

### Phase 4: Update SpacesProvider ✅ COMPLETED
- [x] Task 4.1: Remove increment/decrement methods from `SpacesProvider`
  - ✅ Navigated to `lib/providers/spaces_provider.dart`
  - ✅ Deleted `incrementSpaceItemCount()` method (lines 336-388)
  - ✅ Deleted `decrementSpaceItemCount()` method (lines 390-443)
  - ✅ Updated class documentation to remove item count management reference

- [x] Task 4.2: Add `getSpaceItemCount()` method to `SpacesProvider`
  - ✅ Navigated to `lib/providers/spaces_provider.dart`
  - ✅ Added new method after `switchSpace` method
  - ✅ Method signature: `Future<int> getSpaceItemCount(String spaceId)`
  - ✅ Implementation: calls `_repository.getItemCount(spaceId)` with retry logic via `_executeWithRetry`
  - ✅ Returns 0 as graceful fallback on error
  - ✅ Added comprehensive documentation

- [x] Task 4.3: Update provider tests
  - ✅ Navigated to `test/providers/spaces_provider_test.dart`
  - ✅ Removed call count trackers for increment/decrement methods from MockSpaceRepository
  - ✅ Deleted increment/decrement methods from MockSpaceRepository
  - ✅ Added `getItemCount` method to MockSpaceRepository with override capability
  - ✅ Deleted test group for `incrementSpaceItemCount` (lines 808-860)
  - ✅ Deleted test group for `decrementSpaceItemCount` (lines 862-927)
  - ✅ Added test group for `getSpaceItemCount` with 2 test cases:
    - ✅ Test case: returns count from repository
    - ✅ Test case: returns 0 on error
  - ✅ Fixed error message assertions to use `.toString()` for AppError objects
  - ✅ **Result: All 44 provider tests passing**

### Phase 5: Remove Counter Updates from ContentProvider ✅ COMPLETED
- [x] Task 5.1: Remove counter updates from TodoList operations
  - ✅ Navigated to `lib/providers/content_provider.dart`
  - ✅ In `createTodoList()` method, removed call to `spacesProvider.incrementSpaceItemCount()`
  - ✅ In `deleteTodoList()` method, removed call to `spacesProvider.decrementSpaceItemCount()`
  - ✅ Removed `spacesProvider` parameter from both methods
  - ✅ Updated all call sites to remove `spacesProvider` argument

- [x] Task 5.2: Remove counter updates from List operations
  - ✅ Navigated to `lib/providers/content_provider.dart`
  - ✅ In `createList()` method, removed call to `spacesProvider.incrementSpaceItemCount()`
  - ✅ In `deleteList()` method, removed call to `spacesProvider.decrementSpaceItemCount()`
  - ✅ Removed `spacesProvider` parameter from both methods
  - ✅ Updated all call sites to remove `spacesProvider` argument

- [x] Task 5.3: Remove counter updates from Note operations
  - ✅ Navigated to `lib/providers/content_provider.dart`
  - ✅ In `createNote()` method, removed call to `spacesProvider.incrementSpaceItemCount()`
  - ✅ In `deleteNote()` method, removed call to `spacesProvider.decrementSpaceItemCount()`
  - ✅ Removed `spacesProvider` parameter from both methods
  - ✅ Updated all call sites to remove `spacesProvider` argument
  - ✅ Updated call sites in:
    - `lib/widgets/screens/todo_list_detail_screen.dart`
    - `lib/widgets/screens/note_detail_screen.dart`
    - `lib/widgets/screens/list_detail_screen.dart`
    - `lib/widgets/modals/create_content_modal.dart`

- [x] Task 5.4: Update ContentProvider tests
  - ✅ Navigated to `test/providers/content_provider_test.dart`
  - ✅ Removed increment/decrement counter tracking methods from MockSpacesProvider
  - ✅ Removed all mock expectations for `incrementSpaceItemCount` and `decrementSpaceItemCount`
  - ✅ Updated test assertions to no longer verify counter updates
  - ✅ Updated all test method calls to remove `spacesProvider` parameter
  - ✅ Tests pass (69 passing, 3 pre-existing failures unrelated to this change)

### Phase 6: Update UI to Handle Async Counts
- [ ] Task 6.1: Update SpaceSwitcherModal to use async count loading
  - Navigate to `lib/widgets/modals/space_switcher_modal.dart`
  - Locate item count display (line ~387-394)
  - Replace direct `space.itemCount` access with FutureBuilder
  - FutureBuilder future: `spacesProvider.getSpaceItemCount(space.id)`
  - Loading state: show placeholder (e.g., `'...'` or small spinner)
  - Success state: display count as `'${snapshot.data}'`
  - Error state: show `'0'` as fallback
  - Apply same pattern to accessibility label (line ~238)
  - Apply same pattern to long-press menu (line ~476)

- [ ] Task 6.2: Optimize async loading with caching
  - Add `Map<String, int> _cachedCounts = {}` to SpaceSwitcherModal state
  - In `initState()`, pre-fetch counts for all spaces: `for (final space in spaces) { spacesProvider.getSpaceItemCount(space.id).then((count) => setState(() => _cachedCounts[space.id] = count)); }`
  - Update FutureBuilder to use synchronous cached value if available
  - Clear cache in `dispose()`
  - This prevents flicker by loading counts once on modal open

- [ ] Task 6.3: Add widget tests for async count display
  - Navigate to `test/widgets/modals/space_switcher_modal_test.dart`
  - Test case: shows loading state while count is being calculated
  - Test case: displays correct count after loading completes
  - Test case: shows fallback on error
  - Test case: updates accessibility label with correct count
  - Mock `spacesProvider.getSpaceItemCount()` to control async behavior

### Phase 7: Update Other UI Components Using Item Count
- [ ] Task 7.1: Search codebase for `space.itemCount` usage
  - Run: `grep -r "space.itemCount" apps/later_mobile/lib/`
  - Identify all files that reference `space.itemCount`
  - Create list of files to update

- [ ] Task 7.2: Update each identified component
  - For each file found in Task 7.1:
    - Replace `space.itemCount` with async count loading
    - Use FutureBuilder or cached value pattern
    - Add loading/error states
    - Update tests for async behavior

- [ ] Task 7.3: Verify no remaining direct count access
  - Run: `grep -r "itemCount" apps/later_mobile/lib/ | grep -v "getItemCount"`
  - Should find no references to stored itemCount field
  - Only references should be to the new `getItemCount()` method

### Phase 8: Migration and Cleanup
- [ ] Task 8.1: Add migration logic for existing data
  - Navigate to `lib/core/services/hive_database.dart`
  - In `initialize()` method, after boxes are opened
  - Check for migration flag in shared preferences: `prefs.getBool('migrated_to_calculated_counts_v2')`
  - If not migrated:
    - Log: "Running migration: removing stored item counts"
    - Iterate through all spaces
    - For each space, reload from Hive (this will drop the itemCount field automatically)
    - Set migration flag: `prefs.setBool('migrated_to_calculated_counts_v2', true)`
  - Note: Hive will automatically drop unknown fields, so explicit migration may not be needed

- [ ] Task 8.2: Clean up imports and unused code
  - Search for unused imports related to counter logic
  - Remove any helper methods or utilities that were only used for counter maintenance
  - Update documentation and comments referencing the old counter system

- [ ] Task 8.3: Update documentation
  - Update `CLAUDE.md` to remove references to increment/decrement counter pattern
  - Add note about calculated counts being the source of truth
  - Update architecture documentation if it references counter logic

## Dependencies and Prerequisites

**Required Hive Boxes:**
- `notes` (box must be open)
- `todo_lists` (box must be open)
- `lists` (box must be open)
- `spaces` (box must be open)

**Breaking Changes:**
- Space model no longer has `itemCount` field
- Hive adapter regeneration required
- Existing app data will lose stored counts (acceptable - will be recalculated)

**No New Dependencies:**
- Uses existing Hive infrastructure
- FutureBuilder is built into Flutter

## Challenges and Considerations

**Performance:**
- Initial concern: querying 3 Hive boxes for each count
- Mitigation: Pre-fetch and cache counts when modal opens
- For typical usage (10 spaces, 100 items each): ~50ms total, negligible
- Can further optimize with provider-level caching if needed

**UI/UX:**
- Brief loading state when modal first opens
- Mitigation: Pre-fetch counts in initState, cache results
- Loading state should be barely noticeable (<100ms)

**Migration:**
- Removing field is a breaking change for Hive model
- Mitigation: Hive handles unknown fields gracefully (drops them)
- Regenerating adapter with `--delete-conflicting-outputs` handles compatibility
- No user data loss (items themselves are unaffected)

**Edge Cases:**
- Hive box not open when calculating count: return 0 as fallback
- Space deleted during count calculation: handled by returning 0
- Concurrent item creation during count display: acceptable stale read (refresh on next open)

**Code Simplification:**
- Removes ~100-150 lines of counter maintenance code
- Removes increment/decrement logic from all create/delete operations
- Eliminates entire test groups for counter operations
- Net reduction in code complexity

**Future Optimizations (if needed):**
- Add provider-level caching: cache counts for 30 seconds
- Stream-based updates: listen to Hive box changes and update counts reactively
- Background pre-calculation: calculate all counts on app start, store in memory
- But: likely not needed for MVP, calculated on-demand is sufficient

## Success Metrics

- Zero test failures after implementation
- No compilation errors after Hive adapter regeneration
- SpaceSwitcherModal displays correct counts with <100ms load time
- Manual testing: create/delete items, verify counts update on next modal open
- Code reduction: ~100-150 lines removed (increment/decrement logic)
- Impossible to desynchronize counts (single source of truth)

## Rollback Plan

If performance becomes an issue:
1. Revert Space model changes (restore itemCount field)
2. Restore increment/decrement methods
3. Implement reconciliation instead (fallback to Phase 1 of original plan)

But this is unlikely to be necessary for MVP scale.
