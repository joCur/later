# User-Defined Content Ordering in Spaces

## Objective and Scope

Implement manual drag-and-drop reordering for heterogeneous content items (Notes, TodoLists, Lists) within Spaces on the HomeScreen. This will replace the current creation-date-based ordering with user-controlled positioning, allowing users to organize their content according to their preferences.

**MVP Scope:**
- Add `sortOrder` field to all content models (Item/Note, TodoList, ListModel)
- Implement space-scoped ordering (each Space has independent ordering)
- Add ReorderableListView to HomeScreen with drag-and-drop UI
- Create reorder methods in ContentProvider for heterogeneous content
- Run one-time migration to assign initial sort orders to existing content

**Out of Scope (Future Enhancements):**
- Cross-space content movement
- Alternative sorting options (alphabetical, by type, etc.)
- Bulk reorder operations
- Undo/redo functionality

## Technical Approach and Reasoning

**Why `sortOrder` in Models (Approach 1):**
- Consistent with existing pattern (ListItem and TodoItem already have `sortOrder`)
- Simple integer-based ordering is predictable and easy to maintain
- No denormalization - order data lives with the content
- Works naturally with Hive's limitations (sorting in Dart code)
- Space-scoped sequences prevent conflicts between spaces

**Key Design Decisions:**
- Use space-scoped ordering (sortOrder 0, 1, 2... per space, not global)
- Sort in Dart code, not in Hive (Hive has no query language)
- Update multiple items on reorder (acceptable for <1000 items per space)
- Allow gaps in sortOrder values (renormalization not required initially)
- Optimistic UI updates for smooth user experience

## Implementation Phases

### Phase 1: Data Model Updates

- [x] Task 1.1: Add `sortOrder` field to Item model
  - Open `lib/data/models/item_model.dart`
  - Add `@HiveField(11) final int sortOrder;` (HiveField 11 is next available)
  - Add `sortOrder` parameter to constructor with default value `0`
  - Update `copyWith` method to include `sortOrder`
  - Update `toJson` and `fromJson` methods to include `sortOrder`
  - Add `sortOrder` to equality comparison in `operator ==` and `hashCode`

- [x] Task 1.2: Add `sortOrder` field to TodoList model
  - Open `lib/data/models/todo_list_model.dart`
  - Add `@HiveField(7) final int sortOrder;` (HiveField 7 is next available)
  - Add `sortOrder` parameter to constructor with default value `0`
  - Update `copyWith` method to include `sortOrder`
  - Update `toJson` and `fromJson` methods to include `sortOrder`
  - Add `sortOrder` to equality comparison in `operator ==` and `hashCode`

- [x] Task 1.3: Add `sortOrder` field to ListModel
  - Open `lib/data/models/list_model.dart`
  - Add `@HiveField(8) final int sortOrder;` (HiveField 8 is next available)
  - Add `sortOrder` parameter to constructor with default value `0`
  - Update `copyWith` method to include `sortOrder`
  - Update `toJson` and `fromJson` methods to include `sortOrder`
  - Add `sortOrder` to equality comparison in `operator ==` and `hashCode`

- [x] Task 1.4: Regenerate Hive type adapters
  - Run `cd apps/later_mobile && dart run build_runner build --delete-conflicting-outputs`
  - Verify all three `.g.dart` files are regenerated
  - Check for any build errors or warnings

### Phase 2: Repository Layer Updates

- [x] Task 2.1: Update NoteRepository create method
  - Open `lib/data/repositories/note_repository.dart`
  - Modify `create()` method to calculate next sortOrder for the space
  - Query all notes in the same spaceId
  - Find max sortOrder value (or use 0 if space is empty)
  - Assign `sortOrder = maxSortOrder + 1` to new note

- [x] Task 2.2: Update TodoListRepository create method
  - Open `lib/data/repositories/todo_list_repository.dart`
  - Modify `create()` method to calculate next sortOrder for the space
  - Query all todo lists in the same spaceId
  - Find max sortOrder value (or use 0 if space is empty)
  - Assign `sortOrder = maxSortOrder + 1` to new todo list

- [x] Task 2.3: Update ListRepository create method
  - Open `lib/data/repositories/list_repository.dart`
  - Modify `create()` method to calculate next sortOrder for the space
  - Query all lists in the same spaceId
  - Find max sortOrder value (or use 0 if space is empty)
  - Assign `sortOrder = maxSortOrder + 1` to new list

- [x] Task 2.4: Add helper method to calculate max sortOrder across all content types
  - NOT NEEDED: Each repository independently calculates sortOrder within its own content type
  - sortOrder is space-scoped but type-independent (each type maintains its own sortOrder sequence)
  - This approach is simpler and prevents race conditions across content types

### Phase 3: Provider Layer - Reordering Logic

- [ ] Task 3.1: Add `_getSortOrder` helper method to ContentProvider
  - Open `lib/providers/content_provider.dart`
  - Add private method `int _getSortOrder(dynamic item)`
  - Use type checking: if TodoList return `item.sortOrder`, if ListModel return `item.sortOrder`, if Item return `item.sortOrder`
  - Return 0 as fallback for unknown types

- [ ] Task 3.2: Update `getFilteredContent` to sort by sortOrder
  - Modify `getFilteredContent(ContentFilter filter)` method
  - After building the result list, add sorting logic
  - Use `result.sort((a, b) => _getSortOrder(a).compareTo(_getSortOrder(b)))`
  - Apply to all filter types (all, todoLists, lists, notes)

- [ ] Task 3.3: Add `reorderContent` method to ContentProvider
  - Add public method `Future<void> reorderContent(int oldIndex, int newIndex) async`
  - Get current filtered content list
  - Adjust newIndex if moving down: `if (newIndex > oldIndex) newIndex -= 1;`
  - Remove item at oldIndex, insert at newIndex (in-memory reorder)
  - Iterate through reordered list and update sortOrder for each item (0, 1, 2, 3...)
  - Use type checking to call appropriate update method (updateTodoList, updateList, updateNote)
  - Handle errors and revert on failure

- [ ] Task 3.4: Add optimistic state update support
  - After reorder operation, call `notifyListeners()` to update UI immediately
  - Consider adding a local cache of sorted content to avoid re-sorting on every build
  - If reorder fails, revert the local state and show error to user

### Phase 4: UI Layer - HomeScreen Updates

- [ ] Task 4.1: Replace ListView with ReorderableListView in HomeScreen
  - Open `lib/widgets/screens/home_screen.dart`
  - Locate the current list builder (likely `ListView.builder`)
  - Replace with `ReorderableListView.builder`
  - Add `onReorder: (oldIndex, newIndex) async { await contentProvider.reorderContent(oldIndex, newIndex); }`
  - Ensure all list items have unique keys using `key: ValueKey(item.id)`

- [ ] Task 4.2: Update content card builders to include keys
  - Ensure `_buildContentCard` or similar method returns widgets with `ValueKey(item.id)`
  - Verify keys work for all three content types (Note, TodoList, ListModel)
  - Test that keys are stable across rebuilds

- [ ] Task 4.3: Add visual drag handle or feedback
  - Add a drag handle icon to content cards (optional, entire card can be draggable)
  - Consider using `ReorderableDragStartListener` for custom drag affordance
  - Add visual feedback during drag (slight scale/elevation change)
  - Ensure 48x48px minimum touch target for accessibility

- [ ] Task 4.4: Handle loading states during reorder
  - Show subtle loading indicator while reorder is being persisted
  - Disable reordering while a reorder operation is in progress
  - Ensure smooth UI without flicker during optimistic updates

### Phase 5: Data Migration

- [ ] Task 5.1: Create migration utility class
  - Create `lib/data/migrations/sort_order_migration.dart`
  - Create class `SortOrderMigration` with static method `Future<void> run()`
  - Use `shared_preferences` to track migration completion with key `'sort_order_migration_v1_completed'`
  - Check if migration already ran, return early if completed

- [ ] Task 5.2: Implement migration logic
  - Open all Hive boxes (notes, todo_lists, lists, spaces)
  - For each space, gather all content items (notes, todoLists, lists)
  - Sort combined content by `createdAt` ascending (preserve existing order)
  - Assign sequential sortOrder values (0, 1, 2, 3...) to each item
  - Update each item in its respective Hive box with new sortOrder
  - Mark migration as complete in SharedPreferences

- [ ] Task 5.3: Integrate migration into app startup
  - Open `lib/main.dart`
  - After `HiveDatabase.initialize()` call, add `await SortOrderMigration.run()`
  - Ensure migration runs before `runApp()` to avoid data inconsistencies
  - Wrap migration in try-catch to handle errors gracefully
  - Log migration success/failure for debugging

- [ ] Task 5.4: Test migration with real data
  - Create test data with existing items (no sortOrder)
  - Run migration and verify all items get sequential sortOrder values
  - Verify sortOrder values are scoped per space (Space A: 0,1,2; Space B: 0,1,2)
  - Verify existing order (by createdAt) is preserved after migration

### Phase 6: Testing and Polish

- [ ] Task 6.1: Write unit tests for ContentProvider reordering
  - Create `test/providers/content_provider_reorder_test.dart`
  - Test `reorderContent` with mixed content types
  - Test edge cases: reorder first item, reorder last item, no-op reorder
  - Test error handling (repository failure, invalid indices)
  - Mock repositories to isolate provider logic

- [ ] Task 6.2: Write integration test for HomeScreen reordering
  - Create `test/widgets/screens/home_screen_reorder_test.dart`
  - Test drag-and-drop interaction with `ReorderableListView`
  - Verify content order persists after reorder
  - Test reordering with different content filters (all, tasks, notes)
  - Use `WidgetTester.drag` to simulate drag gestures

- [ ] Task 6.3: Manual testing on real device
  - Test reordering with 10+ items of mixed types
  - Test reordering in multiple spaces independently
  - Verify no performance issues with ~100 items
  - Test with slow device to ensure smooth animations
  - Test after app restart to ensure order persists

- [ ] Task 6.4: Add accessibility improvements
  - Ensure drag handles meet 48x48px minimum touch target
  - Add semantic labels for screen readers ("Reorder [item name]")
  - Test with VoiceOver/TalkBack enabled
  - Verify keyboard navigation works (if applicable)

- [ ] Task 6.5: Update documentation
  - Add code comments explaining sortOrder field in models
  - Document reorderContent method in ContentProvider
  - Add user-facing documentation (if needed) about reordering feature
  - Update CLAUDE.md to mention sortOrder pattern

## Dependencies and Prerequisites

**Required:**
- `flutter_reorderable_list` - Built-in Flutter widget (no new dependency)
- `shared_preferences` - Already in project for migration tracking
- `build_runner` - Already in project for Hive adapters
- `hive` and `hive_flutter` - Already in project

**Existing Code Patterns:**
- Repository pattern (`data/repositories/`)
- Provider pattern for state management
- AutoSaveMixin for debounced saves (not needed for reordering, but good to know)
- Hive type adapters with `@HiveField` annotations

**Development Setup:**
- Ensure `apps/later_mobile` is the working directory
- Run `flutter pub get` to ensure dependencies are up to date
- Run `dart run build_runner build` after model changes

## Challenges and Considerations

**1. Migration Safety:**
- Migration must be idempotent (safe to run multiple times)
- Use SharedPreferences flag to prevent re-running
- Wrap in try-catch to avoid blocking app startup on failure
- Consider logging migration errors for debugging
- **Mitigation:** Test migration thoroughly with real data scenarios

**2. Reorder Performance:**
- Updating multiple items (O(n) operation) could be slow for large spaces
- Typical use case: <100 items per space, acceptable performance
- **Mitigation:** Show loading indicator during reorder, disable UI interactions

**3. Data Consistency:**
- sortOrder gaps after deletions (acceptable, no renormalization needed)
- New content must calculate correct sortOrder (max + 1)
- **Mitigation:** Ensure create methods in repositories calculate sortOrder correctly

**4. User Experience:**
- Accidental reordering could be frustrating
- **Mitigation:** Require deliberate drag gesture (not just tap), show visual feedback

**5. Edge Cases:**
- Empty spaces (sortOrder starts at 0)
- Reordering with active filters (only visible items are reordered)
- Deleting items creates gaps in sortOrder (acceptable)
- **Mitigation:** Test edge cases thoroughly in unit tests

**6. Backward Compatibility:**
- Items without sortOrder will default to 0 (need migration)
- Old app versions won't recognize sortOrder field (Hive ignores unknown fields)
- **Mitigation:** Migration assigns sortOrder to all existing items on first launch

**7. Hive Adapter Versioning:**
- Adding fields to Hive models requires regenerating adapters
- Existing data remains compatible (Hive handles missing fields gracefully)
- **Mitigation:** Run `build_runner` immediately after model changes, test with existing data

**8. Testing Drag Interactions:**
- Widget tests for drag gestures can be flaky
- **Mitigation:** Use robust test utilities, test on multiple screen sizes

**9. Atomic Operations:**
- Reorder updates multiple items, not atomic (could fail mid-operation)
- **Mitigation:** Use optimistic UI updates, revert on failure, show error message
