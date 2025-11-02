# Research: User-Defined Content Ordering in Spaces

## Executive Summary

This research explores implementing user-defined manual ordering for heterogeneous content items (TodoLists, Lists, Notes) within Spaces in the Later mobile app. Currently, content is ordered by creation date (`createdAt`), which limits users' ability to organize content according to their preferences.

**Key Findings:**
- Need to add a `sortOrder` field to all three content model types (Item/Note, TodoList, ListModel)
- Use separate ordering sequences per Space to allow independent organization
- Implement ReorderableListView for drag-and-drop UI in HomeScreen
- Create reorder methods in ContentProvider to handle heterogeneous content types
- Store order data in Hive boxes, leveraging existing repository pattern
- Migration required to assign initial sort orders to existing content

**Recommended Approach:** Add `sortOrder` fields to models, implement type-aware reordering in ContentProvider, and update HomeScreen with ReorderableListView for mixed content types.

## Research Scope

### What Was Researched
- Existing implementation of reordering within TodoLists and Lists (items within detail screens)
- Current data models (Item, TodoList, ListModel, Space) and their Hive storage structure
- Content retrieval and filtering in ContentProvider
- Flutter ReorderableListView patterns for heterogeneous data
- Hive best practices for manual ordering (2025)
- Migration strategies for adding sort order to existing data

### What Was Explicitly Excluded
- Alternative ordering methods (alphabetical, custom filters, tags)
- Cross-space content ordering
- Sorting by properties other than manual positioning (e.g., priority, due date)
- Advanced drag-and-drop libraries beyond Flutter's built-in widgets

### Research Methodology
- Codebase analysis of existing reorder implementation
- Review of data models and repository patterns
- Web research on Flutter/Hive ordering best practices
- Analysis of HomeScreen content display logic

## Current State Analysis

### Existing Implementation

**Reordering Within Detail Screens:**
The app already implements successful reordering for items *within* TodoLists and Lists:

**List Detail Screen** (`list_detail_screen.dart:195-226`):
```dart
Future<void> _reorderListItems(int oldIndex, int newIndex) async {
  if (newIndex > oldIndex) {
    newIndex -= 1;
  }

  // Optimistically update local state
  final reorderedItems = List<ListItem>.from(_currentList.items);
  final item = reorderedItems.removeAt(oldIndex);
  reorderedItems.insert(newIndex, item);

  setState(() {
    _currentList = _currentList.copyWith(items: reorderedItems);
  });

  // Persist to provider
  final provider = Provider.of<ContentProvider>(context, listen: false);
  await provider.reorderListItems(_currentList.id, oldIndex, newIndex);
}
```

**Data Models with sortOrder:**
- **ListItem** (`list_model.dart:47`): Has `sortOrder` field (HiveField 4)
- **TodoItem** (`todo_list_model.dart:81`): Has `sortOrder` field (HiveField 7)
- **Item/Note** (`item_model.dart:16`): **NO** `sortOrder` field ❌
- **TodoList** (`todo_list_model.dart:142`): **NO** top-level `sortOrder` ❌
- **ListModel** (`list_model.dart:130`): **NO** top-level `sortOrder` ❌

**Content Retrieval** (`content_provider.dart:899-910`):
```dart
List<dynamic> getFilteredContent(ContentFilter filter) {
  switch (filter) {
    case ContentFilter.all:
      return [..._todoLists, ..._lists, ..._notes];  // Mixed types
    case ContentFilter.todoLists:
      return _todoLists;
    case ContentFilter.lists:
      return _lists;
    case ContentFilter.notes:
      return _notes;
  }
}
```

Currently returns content in **insertion order** (as retrieved from Hive), which correlates with `createdAt` since items are stored sequentially.

### Current Architecture

**Repository Pattern:**
- `TodoListRepository`: Manages TodoList CRUD + `reorderItems(listId, oldIndex, newIndex)`
- `ListRepository`: Manages ListModel CRUD + `reorderItems(listId, oldIndex, newIndex)`
- `NoteRepository`: Manages Item/Note CRUD (no reordering currently)

**Provider Layer:**
- `ContentProvider`: Aggregates content from all repositories
- Exposes `reorderTodoItems()` and `reorderListItems()` for *within-collection* reordering
- No cross-type reordering capability

**Hive Storage:**
- Separate boxes: `notes`, `todo_lists`, `lists`, `spaces`
- Type IDs: Item(1), Space(2), TodoList(20), TodoItem(21), ListModel(22), ListItem(23)

### Industry Standards

**Best Practice: Store Sort Order in Data Model**
From 2025 Hive best practices research:
> "The most common approach is to add an `order` or `position` field to your data objects and update these values when reordering occurs."

**Hive Limitation:**
> "Hive is sorted by its key and cannot directly store the order of lists... Hive has no query language and only limited support for sorting, but sorting and filtering is much faster if you do it yourself in Dart."

**Flutter ReorderableListView:**
> "All list items must have a key... The onReorder function is triggered whenever the user moves an item."

## Technical Analysis

### Approach 1: Add sortOrder to All Content Models (With Space Scoping)

**Description:**
Add a `sortOrder` integer field to Item, TodoList, and ListModel. Sort orders are scoped per Space, meaning each Space has independent ordering sequences (0, 1, 2, 3...). When content is loaded for a Space, it's sorted by `sortOrder` ascending before display.

**Implementation Details:**

1. **Model Changes** (Hive Type Adapters):
   ```dart
   // Item (Note) - add new HiveField
   @HiveField(11)  // Next available field
   final int sortOrder;

   // TodoList - add new HiveField
   @HiveField(7)  // Next available field
   final int sortOrder;

   // ListModel - add new HiveField
   @HiveField(8)  // Next available field
   final int sortOrder;
   ```

2. **ContentProvider Reordering Logic**:
   ```dart
   Future<void> reorderContent(int oldIndex, int newIndex) async {
     // Get all content for current space
     final allContent = getFilteredContent(ContentFilter.all);

     // Adjust index if moving down
     if (newIndex > oldIndex) newIndex -= 1;

     // Reorder in memory
     final item = allContent.removeAt(oldIndex);
     allContent.insert(newIndex, item);

     // Update sortOrder for affected items
     for (int i = 0; i < allContent.length; i++) {
       final content = allContent[i];
       if (content is TodoList) {
         await updateTodoList(content.copyWith(sortOrder: i));
       } else if (content is ListModel) {
         await updateList(content.copyWith(sortOrder: i));
       } else if (content is Item) {
         await updateNote(content.copyWith(sortOrder: i));
       }
     }
   }
   ```

3. **HomeScreen UI**:
   ```dart
   ReorderableListView.builder(
     onReorder: (oldIndex, newIndex) {
       contentProvider.reorderContent(oldIndex, newIndex);
     },
     itemCount: filteredContent.length,
     itemBuilder: (context, index) {
       final item = filteredContent[index];
       return _buildContentCard(item, key: ValueKey(item.id));
     },
   )
   ```

4. **Sorting in getFilteredContent**:
   ```dart
   List<dynamic> getFilteredContent(ContentFilter filter) {
     List<dynamic> result;
     switch (filter) {
       case ContentFilter.all:
         result = [..._todoLists, ..._lists, ..._notes];
         break;
       // ... other cases
     }

     // Sort by sortOrder ascending
     result.sort((a, b) {
       final aOrder = _getSortOrder(a);
       final bOrder = _getSortOrder(b);
       return aOrder.compareTo(bOrder);
     });
     return result;
   }

   int _getSortOrder(dynamic item) {
     if (item is TodoList) return item.sortOrder;
     if (item is ListModel) return item.sortOrder;
     if (item is Item) return item.sortOrder;
     return 0;
   }
   ```

**Pros:**
- ✅ Consistent with existing child-item reordering pattern
- ✅ Space-scoped ordering provides clean separation
- ✅ Leverages existing repository pattern
- ✅ Works with existing Hive setup (no new boxes)
- ✅ Supports heterogeneous content types naturally
- ✅ Simple conceptual model (just an integer per item)

**Cons:**
- ⚠️ Requires model migration for existing data
- ⚠️ Reorder operation updates multiple records (not atomic)
- ⚠️ Need to rebuild sort orders when content is deleted
- ⚠️ Must handle new content insertion (assign next sortOrder)

**Use Cases:**
- Best for: Apps with < 1000 items per space (typical use case)
- Suitable when: Users expect stable, persistent ordering
- Ideal when: Content types are mixed in display

**Migration Strategy:**
```dart
// One-time migration
Future<void> migrateSortOrders() async {
  for (final space in spaces) {
    final allContent = await loadSpaceContent(space.id);

    // Sort by createdAt to preserve existing order
    allContent.sort((a, b) =>
      _getCreatedAt(a).compareTo(_getCreatedAt(b))
    );

    // Assign sequential sortOrders
    for (int i = 0; i < allContent.length; i++) {
      final item = allContent[i];
      if (item is TodoList) {
        await _todoListRepository.update(
          item.copyWith(sortOrder: i)
        );
      }
      // ... similarly for List and Item
    }
  }
}
```

---

### Approach 2: Store Ordered ID List in Space Model

**Description:**
Add a `contentOrder: List<String>` field to the Space model that stores item IDs in display order. Content is then sorted by matching IDs against this list when retrieved.

**Implementation Details:**

1. **Space Model Change**:
   ```dart
   @HiveType(typeId: 2)
   class Space {
     // ... existing fields

     @HiveField(8)  // Next available field
     final List<String> contentOrder;
   }
   ```

2. **Reorder Logic**:
   ```dart
   Future<void> reorderContent(int oldIndex, int newIndex) async {
     final space = currentSpace!;
     final order = List<String>.from(space.contentOrder);

     // Reorder IDs
     final id = order.removeAt(oldIndex);
     if (newIndex > oldIndex) newIndex -= 1;
     order.insert(newIndex, id);

     // Update space
     await spacesProvider.updateSpace(
       space.copyWith(contentOrder: order)
     );
   }
   ```

3. **Sorting**:
   ```dart
   List<dynamic> getFilteredContent(ContentFilter filter) {
     final result = // ... get content as before

     // Sort by position in space.contentOrder
     final order = _currentSpace!.contentOrder;
     result.sort((a, b) {
       final aIndex = order.indexOf(_getId(a));
       final bIndex = order.indexOf(_getId(b));
       if (aIndex == -1) return 1;  // Not in order list
       if (bIndex == -1) return -1;
       return aIndex.compareTo(bIndex);
     });
     return result;
   }
   ```

**Pros:**
- ✅ Single-record update on reorder (atomic)
- ✅ No need to modify content models
- ✅ Fast reorder operation (just update one list)
- ✅ Clear "source of truth" for ordering

**Cons:**
- ❌ Must keep contentOrder list synchronized with actual content
- ❌ Orphaned IDs if content deleted but not removed from order list
- ❌ Missing IDs if content created but not added to order list
- ❌ More complex synchronization logic
- ❌ Denormalized data (order lives separate from content)
- ❌ Need to handle new content insertion position

**Use Cases:**
- Best for: Frequent reordering with minimal content changes
- Suitable when: Atomicity of reorder is critical
- Not ideal for: Heterogeneous content with complex lifecycles

---

### Approach 3: Hybrid - Fractional Ordering (LexoRank-style)

**Description:**
Use floating-point or string-based fractional ordering where items can be inserted "between" existing items without reassigning all sort orders.

**Implementation Details:**

```dart
@HiveField(11)
final double sortOrder;  // e.g., 1.0, 1.5, 2.0, 2.25...

// Insert between items at positions i and i+1
double newSortOrder = (items[i].sortOrder + items[i+1].sortOrder) / 2;
```

**Pros:**
- ✅ Minimal updates on reorder (only moved item)
- ✅ Can insert anywhere without reassigning

**Cons:**
- ❌ Floating-point precision issues over time
- ❌ Need periodic "renormalization" to avoid precision loss
- ❌ More complex implementation
- ❌ Overkill for typical use case
- ❌ String-based lexorank is even more complex

**Use Cases:**
- Best for: Collaborative editing with real-time sync
- Overkill for: Single-user local-first app

---

## Recommendations

### Recommended Approach: **Approach 1 - Add sortOrder to All Content Models**

**Rationale:**
1. **Consistent with existing patterns**: The app already uses `sortOrder` for ListItem and TodoItem
2. **Simple and predictable**: Integer-based ordering is easy to reason about
3. **Space-scoped independence**: Each space has its own ordering, preventing conflicts
4. **Works with Hive limitations**: Sorting happens in Dart code, as recommended
5. **No denormalization**: Order data lives with the content it describes

**Implementation Priority:**

**Phase 1: Data Layer (High Priority)**
1. Add `sortOrder` field to Item, TodoList, ListModel
2. Run `build_runner` to regenerate Hive adapters
3. Create migration to assign initial sort orders
4. Update `copyWith` methods to include `sortOrder`
5. Update JSON serialization/deserialization

**Phase 2: Repository Layer (High Priority)**
6. Update create methods to assign `sortOrder` (use `max(existing) + 1`)
7. Ensure delete operations don't break ordering
8. (Optional) Add renormalization method if gaps are problematic

**Phase 3: Provider Layer (High Priority)**
9. Add `reorderContent(int oldIndex, int newIndex)` to ContentProvider
10. Update `getFilteredContent()` to sort by `sortOrder`
11. Add helper method `_getSortOrder(dynamic item)` for type checking

**Phase 4: UI Layer (Medium Priority)**
12. Convert HomeScreen list to `ReorderableListView`
13. Wire up `onReorder` callback to `contentProvider.reorderContent`
14. Ensure proper keys for all list items (`ValueKey(item.id)`)
15. Handle loading states during reorder

**Phase 5: Polish (Low Priority)**
16. Add visual feedback during drag (drag handle icon?)
17. Haptic feedback on reorder
18. Undo/redo support (optional)
19. Settings toggle to switch between manual/date ordering

### Alternative Approach if Constraints Change

If atomicity becomes critical (e.g., adding real-time sync), reconsider **Approach 2** (ID list in Space), but only after Approach 1 is validated in production.

## Implementation Considerations

### Technical Requirements

**Dependencies:**
- No new packages required (uses built-in `ReorderableListView`)
- Hive adapter regeneration via `build_runner`
- Migration script for existing data

**Performance:**
- Sorting 100-1000 items in Dart is negligible (<5ms)
- Reorder operation: O(n) where n = items in space (typically < 100)
- Hive write: ~1-10ms per item (updating multiple items is acceptable)

**Scalability:**
- Recommended limit: 1000 items per space for smooth reordering
- If users exceed this, consider pagination in reorder UI

**Data Integrity:**
- sortOrder values may have gaps after deletions (acceptable)
- Renormalization can compact gaps if needed (not required initially)
- New items get `max(sortOrder) + 1` or `0` if space is empty

### Integration Points

**Model Layer:**
- **Item** (typeId 1): Add HiveField(11) for `sortOrder`
- **TodoList** (typeId 20): Add HiveField(7) for `sortOrder`
- **ListModel** (typeId 22): Add HiveField(8) for `sortOrder`

**Repository Layer:**
- Update `NoteRepository.create()` to assign sortOrder
- Update `TodoListRepository.create()` to assign sortOrder
- Update `ListRepository.create()` to assign sortOrder
- (Optional) Add `renormalizeSortOrders()` utility

**Provider Layer:**
- Add `reorderContent()` method in `ContentProvider`
- Modify `getFilteredContent()` to sort by sortOrder
- Handle optimistic UI updates (update local state immediately)

**UI Layer:**
- Replace `ListView.builder` with `ReorderableListView.builder` in `home_screen.dart`
- Add drag handle to content cards (or make entire card draggable)
- Show visual indicator during drag

### Database Migration

**Migration Script** (run once on app update):

```dart
class SortOrderMigration {
  static const String migrationKey = 'sort_order_migration_v1_completed';

  static Future<void> run() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(migrationKey) ?? false) {
      return; // Already migrated
    }

    final spacesBox = await Hive.openBox<Space>('spaces');
    final noteBox = await Hive.openBox<Item>('notes');
    final todoListBox = await Hive.openBox<TodoList>('todo_lists');
    final listBox = await Hive.openBox<ListModel>('lists');

    for (final space in spacesBox.values) {
      // Get all content for this space
      final notes = noteBox.values
          .where((n) => n.spaceId == space.id)
          .toList();
      final todoLists = todoListBox.values
          .where((t) => t.spaceId == space.id)
          .toList();
      final lists = listBox.values
          .where((l) => l.spaceId == space.id)
          .toList();

      // Combine and sort by createdAt
      final allContent = <dynamic>[...notes, ...todoLists, ...lists];
      allContent.sort((a, b) {
        final aDate = a.createdAt as DateTime;
        final bDate = b.createdAt as DateTime;
        return aDate.compareTo(bDate);
      });

      // Assign sequential sortOrders
      for (int i = 0; i < allContent.length; i++) {
        final item = allContent[i];
        if (item is Item) {
          await noteBox.put(
            item.id,
            item.copyWith(sortOrder: i),
          );
        } else if (item is TodoList) {
          await todoListBox.put(
            item.id,
            item.copyWith(sortOrder: i),
          );
        } else if (item is ListModel) {
          await listBox.put(
            item.id,
            item.copyWith(sortOrder: i),
          );
        }
      }
    }

    // Mark migration as complete
    await prefs.setBool(migrationKey, true);
  }
}
```

**Run migration in `main()`**:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveDatabase.initialize();
  await SortOrderMigration.run();  // Before app starts

  runApp(const MyApp());
}
```

### Risks and Mitigation

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Migration fails mid-way | HIGH | LOW | Run in try-catch, log errors, allow retry |
| Reorder conflicts with other operations | MEDIUM | MEDIUM | Use optimistic UI updates, revert on error |
| sortOrder gaps cause confusion | LOW | MEDIUM | Document that gaps are okay, add renormalization |
| Performance degrades with many items | MEDIUM | LOW | Limit items per space, add pagination warning |
| Users accidentally reorder | MEDIUM | MEDIUM | Add "Tap to reorder" hint, require long-press |

**Mitigation Details:**

**Migration Safety:**
- Run migration before any content operations
- Use atomic batch writes if Hive supports it
- Allow app to function even if migration fails (fallback to createdAt ordering)

**Reorder Conflicts:**
- Lock reordering during save operations
- Show loading spinner during reorder
- Revert local state if backend operation fails

**User Experience:**
- Add onboarding tooltip: "Hold and drag to reorder"
- Provide "Reset to Date Order" option in settings
- Show undo snackbar after reorder

## References

### Documentation
- [Flutter ReorderableListView API](https://api.flutter.dev/flutter/material/ReorderableListView-class.html)
- [Hive Documentation](https://docs.hivedb.dev/)
- [Hive Best Practices 2025](https://climbtheladder.com/10-flutter-hive-best-practices/)

### Stack Overflow
- [Best practice of ReorderableListView with Hive](https://stackoverflow.com/questions/72321470/flutter-what-is-the-best-practice-of-reorderablelistview-with-hive)
- [Filter and sort records from Hive box](https://stackoverflow.com/questions/66304606/filter-and-sort-records-from-hive-box-in-flutter)

### Codebase References
- `lib/widgets/screens/list_detail_screen.dart:195-226` - Existing reorder implementation
- `lib/widgets/screens/todo_list_detail_screen.dart:548` - TodoItem reorder
- `lib/providers/content_provider.dart:899-910` - Content filtering
- `lib/data/models/list_model.dart:47` - ListItem sortOrder field
- `lib/data/models/todo_list_model.dart:81` - TodoItem sortOrder field

## Appendix

### Additional Notes

**Future Enhancements:**
- Drag between spaces (move content to different space)
- Bulk reorder operations (select multiple, drag together)
- Keyboard shortcuts for reordering (desktop)
- Customizable sort options (manual, date, alphabetical, type)

**Questions for Further Investigation:**
- Should reordering be disabled during sync operations (Phase 2)?
- Do we need different ordering for different filter views (All, Tasks, Notes)?
- Should archived items maintain their sortOrder?

**Related Topics Worth Exploring:**
- Content grouping within spaces (sections/categories)
- Custom views/filters that remember their own ordering
- Smart ordering based on usage patterns (ML-based)
