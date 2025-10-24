# Research: Product Concept Analysis - Todo Lists, Lists & Notes Implementation

## Executive Summary

The provided product concept introduces a **fundamental restructuring** of how Later handles content organization. The key innovation is elevating **Lists** and **Todo Lists** to **first-class container objects** that can hold multiple items, rather than the current flat item-based architecture where everything is an individual item (Task, Note, or List).

**Current Architecture:** 3 item types (Task, Note, List) stored as individual items in Spaces
**Proposed Architecture:** 3 content types (Todo List, List, Note) where Lists and Todo Lists are **containers** that hold multiple sub-items

**Key Implications:**
1. **Major data model redesign** required - Lists/Todo Lists become parent objects
2. **UI paradigm shift** - Two-level navigation (Space → Container → Items vs. Space → Items)
3. **Enhanced organization** - Better reflects how people naturally group actionable vs. reference information
4. **Backward compatibility challenge** - Existing data migration needed

This research analyzes what can be implemented from the concept, identifies gaps in current implementation, and provides actionable recommendations for evolution.

---

## Research Scope

### What Was Researched
- Complete analysis of product concept document (735 lines)
- Current Later app implementation (data models, UI, architecture)
- Gap analysis between concept and implementation
- Data model evolution requirements
- UI/UX transformation needs
- Migration strategy for existing data

### What Was Explicitly Excluded
- Backend sync implementation details (Supabase already planned)
- Monetization strategy analysis (business decision)
- Competitive analysis deep-dive
- User research validation

### Research Methodology
1. Line-by-line concept document analysis
2. Codebase exploration for current implementation patterns
3. Feature mapping (concept vs. current)
4. Technical feasibility assessment
5. Migration complexity evaluation

---

## Current State Analysis

### Existing Implementation

#### Data Model Architecture
**Current Item Types (Flat Structure):**
```dart
enum ItemType {
  task,   // Individual actionable item with checkbox
  note,   // Free-form text content
  list,   // Structured list (currently also flat)
}

class Item {
  String id;
  ItemType type;
  String title;
  String? content;
  String spaceId;
  bool isCompleted;      // Used for tasks
  DateTime? dueDate;     // Used for tasks
  List<String> tags;
  DateTime createdAt;
  DateTime updatedAt;
}
```

**Current Space Model:**
```dart
class Space {
  String id;
  String name;
  String? icon;
  String? color;
  int itemCount;
  bool isArchived;
  DateTime createdAt;
  DateTime updatedAt;
}
```

**Key Limitation:** Everything is a single-level item. A "List" in the current implementation is just one item with content, not a container holding multiple sub-items.

#### UI Organization
**Current Navigation Flow:**
```
App
├── Home Screen (Today View) - Shows items due today
├── Spaces Screen - Grid/list of all spaces
│   └── Space Detail - Shows all items in space
│       ├── Task items (with checkbox)
│       ├── Note items (with document icon)
│       └── List items (with list icon)
└── Item Detail Screen - Edit individual item
```

**Current Item Display:**
- ItemCard shows individual items with type-specific styling
- All items shown in chronological/mixed view
- Filter tabs: [All] [Tasks] [Notes] [Lists]
- Each item opens to detail screen for editing

#### Smart Type Detection
Currently implemented (`item_type_detector.dart`):
- Detects item type from content using heuristics
- Extracts due dates from natural language
- **Limited list parsing** - Extracts bullet items but doesn't create sub-items
- Auto-classification on quick capture

#### Current Strengths
✅ Offline-first architecture ready
✅ Clean architecture with separation of concerns
✅ Smart type detection already working
✅ Space-based organization implemented
✅ Rich gradient design system
✅ Type-specific visual differentiation
✅ Quick capture system operational

### Industry Standards

#### Common Approaches to List Management

**Option 1: Single-Level Items (Current Later Approach)**
- Examples: Apple Reminders (earlier versions), Google Keep
- Pros: Simple data model, flat structure, easy search
- Cons: Limited organization, hard to group related items

**Option 2: Container-Based Lists (Proposed Concept)**
- Examples: Todoist (projects with tasks), Microsoft To Do (lists with todos), Apple Reminders (current)
- Pros: Natural grouping, better organization, clear hierarchies
- Cons: More complex data model, deeper navigation

**Option 3: Hybrid/Nested (Advanced)**
- Examples: Notion (blocks with infinite nesting), Workflowy
- Pros: Maximum flexibility, powerful organization
- Cons: Can become overwhelming, steep learning curve

**Best Practice Recommendation:** Container-based lists (Option 2) represent the industry standard for productivity apps and align with user mental models.

#### List vs. Todo List Differentiation

**Industry Analysis:**
- **Todoist:** All lists are actionable (checkbox-based)
- **Apple Reminders:** All items have checkboxes, but context implies use
- **Google Keep:** Notes vs. Lists with checkboxes (similar to Later concept)
- **Microsoft To Do:** All lists are todo-based
- **Notion:** Flexible - databases can be any type

**User Mental Model (from concept):**
- **Todo Lists:** Time-bound, actionable, have deadlines and priorities → Need completion tracking
- **Lists:** Reference collections, shopping lists, watchlists → Optional completion, no deadlines
- **Notes:** Free-form context and documentation → No checkboxes

**Recommended Approach:** Support checkboxes in both List and Todo List types, but differentiate through:
1. Visual styling (colors, icons)
2. Default properties (Todo Lists have due dates by default)
3. Context/use case
4. User can choose when creating

---

## Technical Analysis

### Approach 1: Minimal Evolution (Quick Win)

**Description:** Enhance current flat structure with list-like features without fundamental restructuring

**Implementation:**
- Keep existing Item model as-is
- Add `parentItemId` field to Item for sub-items
- List items can have child items
- UI shows list items with expandable sections
- Parser creates linked items instead of content text

**Data Model Change:**
```dart
class Item {
  // Existing fields...
  String? parentItemId;  // NEW: Links to parent list
  int? sortOrder;        // NEW: Order within parent list

  // Helper methods
  bool get isSubItem => parentItemId != null;
  bool get isContainer => type == ItemType.list && !isSubItem;
}
```

**Pros:**
- ✅ Minimal data migration (just add nullable fields)
- ✅ Backward compatible (existing items work as-is)
- ✅ Quick to implement (1-2 weeks)
- ✅ Maintains current architecture patterns
- ✅ Can be done incrementally

**Cons:**
- ❌ Not a true container model (parent is still an "item")
- ❌ Querying becomes complex (need to filter parent/child)
- ❌ Doesn't fully match concept vision
- ❌ Performance issues with deep nesting queries
- ❌ UI navigation still somewhat flat

**Use Cases:**
- Quick prototype to validate user interest
- Interim solution while planning full restructure
- Testing ground for list interaction patterns

**Code Example:**
```dart
// Creating a shopping list with items
final shoppingList = Item(
  id: uuid.v4(),
  type: ItemType.list,
  title: 'Groceries',
  spaceId: spaceId,
  parentItemId: null, // Top-level container
);

final milkItem = Item(
  id: uuid.v4(),
  type: ItemType.list, // Or could be task
  title: 'Milk',
  spaceId: spaceId,
  parentItemId: shoppingList.id, // Child of shopping list
  sortOrder: 0,
);
```

**Estimated Effort:** 2-3 weeks
- 1 week: Data model + migration
- 1 week: UI for nested display
- 3 days: Testing and refinement

---

### Approach 2: Dual Model (Recommended)

**Description:** Introduce separate TodoList and List models as first-class containers alongside existing Item model

**Implementation:**
- Create new `TodoList` and `ListModel` classes as containers
- Items become sub-items within lists
- Notes remain standalone items
- Spaces contain both containers (lists) and standalone items (notes)
- Clear separation of concerns

**New Data Models:**
```dart
// New container for actionable todo lists
class TodoList {
  String id;
  String spaceId;
  String name;
  String? description;
  List<TodoItem> items;  // Embedded sub-items
  DateTime createdAt;
  DateTime updatedAt;

  // Computed properties
  int get totalItems => items.length;
  int get completedItems => items.where((i) => i.isCompleted).length;
  double get progress => totalItems > 0 ? completedItems / totalItems : 0;
}

class TodoItem {
  String id;
  String title;
  String? description;
  bool isCompleted;
  DateTime? dueDate;
  Priority? priority;
  List<String> tags;
  int sortOrder;
}

// New container for reference lists
class ListModel {
  String id;
  String spaceId;
  String name;
  String? icon;  // Custom icon per list (🛒, 📺, etc.)
  List<ListItem> items;  // Embedded sub-items
  ListStyle style;  // Bullets, numbered, checkboxes
  DateTime createdAt;
  DateTime updatedAt;

  int get itemCount => items.length;
}

class ListItem {
  String id;
  String title;
  String? notes;  // Optional notes per item
  bool? isChecked;  // Optional checkbox
  int sortOrder;
}

enum ListStyle {
  bullets,     // Simple bullet points
  numbered,    // 1. 2. 3.
  checkboxes,  // With completion state
}

// Existing Item model (for Notes only now)
class Item {
  String id;
  ItemType type;  // Would primarily be 'note' now
  String title;
  String? content;
  String spaceId;
  List<String> tags;
  DateTime createdAt;
  DateTime updatedAt;
  // Remove task-specific fields
}
```

**Storage Strategy:**
```dart
// Hive boxes
Box<TodoList> todoListsBox;
Box<ListModel> listsBox;
Box<Item> itemsBox;  // Notes only
Box<Space> spacesBox;
```

**Pros:**
- ✅ **Matches concept architecture** perfectly
- ✅ Clear separation of concerns (containers vs. items)
- ✅ Better query performance (no parent/child filtering)
- ✅ Easier to implement container-specific features
- ✅ Progress tracking built-in (4/7 completed)
- ✅ Sub-items can have rich properties
- ✅ Scales well for future features

**Cons:**
- ❌ **Significant data migration** required
- ❌ More complex codebase (3 model types instead of 1)
- ❌ UI needs substantial refactoring
- ❌ Repository layer becomes more complex
- ❌ Need to handle cross-type linking carefully
- ❌ 4-6 weeks implementation time

**Use Cases:**
- Full implementation of product concept
- Long-term scalable architecture
- When ready for significant refactor
- Aligns with MVP Phase 1 completion

**Migration Strategy:**
```dart
// Migration from old Item to new models
Future<void> migrateData() async {
  final oldItems = Hive.box<Item>('items').values;

  for (var item in oldItems) {
    if (item.type == ItemType.task) {
      // Convert task to TodoList with single item
      final todoList = TodoList(
        id: uuid.v4(),
        spaceId: item.spaceId,
        name: 'Quick Tasks', // Default list name
        items: [
          TodoItem(
            id: item.id,
            title: item.title,
            description: item.content,
            isCompleted: item.isCompleted,
            dueDate: item.dueDate,
            sortOrder: 0,
          ),
        ],
      );
      await todoListsBox.put(todoList.id, todoList);

    } else if (item.type == ItemType.list) {
      // Parse content and create ListModel with items
      final parsedItems = ItemTypeDetector.extractListItems(item.content ?? '');
      final list = ListModel(
        id: item.id,
        spaceId: item.spaceId,
        name: item.title,
        style: ListStyle.bullets,
        items: parsedItems.asMap().entries.map((entry) => ListItem(
          id: uuid.v4(),
          title: entry.value,
          sortOrder: entry.key,
        )).toList(),
      );
      await listsBox.put(list.id, list);

    } else if (item.type == ItemType.note) {
      // Notes stay as-is
      await itemsBox.put(item.id, item);
    }
  }

  // Archive old items box
  await Hive.box<Item>('items_backup').putAll(
    Hive.box<Item>('items').toMap()
  );
}
```

**Estimated Effort:** 4-6 weeks
- 1 week: Data model design + Hive adapters
- 1 week: Repository layer refactoring
- 2 weeks: UI components (list views, detail screens)
- 1 week: Migration + testing
- 3 days: Polish and bug fixes

---

### Approach 3: Hybrid Flexibility (Maximum Power)

**Description:** Implement both container lists AND allow standalone tasks/notes, giving users maximum flexibility

**Implementation:**
- TodoList and ListModel containers (from Approach 2)
- Standalone Task items (quick tasks not in a list)
- Standalone Note items
- Users choose: create standalone or add to container
- Quick capture asks: "Add to list or create standalone?"

**Data Model:**
```dart
// Container models (same as Approach 2)
class TodoList { /* ... */ }
class ListModel { /* ... */ }

// Enhanced Item model supports standalone items
class Item {
  String id;
  ItemType type;  // task, note
  String title;
  String? content;
  String spaceId;

  // Task-specific (only for type == task)
  bool? isCompleted;
  DateTime? dueDate;
  Priority? priority;

  DateTime createdAt;
  DateTime updatedAt;
}

enum ItemType {
  task,  // Standalone actionable item
  note,  // Standalone documentation
  // list removed - now only containers
}
```

**UI Flow:**
```dart
// Quick add presents choice
QuickAddDialog(
  options: [
    'Quick Task',        // → Standalone Item(type: task)
    'Todo List',         // → New TodoList container
    'Add to Todo List',  // → Add TodoItem to existing TodoList
    'List',              // → New ListModel container
    'Add to List',       // → Add ListItem to existing ListModel
    'Note',              // → Standalone Item(type: note)
  ],
)
```

**Pros:**
- ✅ Maximum user flexibility
- ✅ Supports both organized (lists) and quick (standalone) workflows
- ✅ Matches real-world usage (some tasks don't need lists)
- ✅ Allows progressive organization (start standalone, move to list later)
- ✅ Aligns with Phase 2 feature: content conversion

**Cons:**
- ❌ Most complex implementation (3 storage types)
- ❌ UI needs to handle multiple creation paths
- ❌ Risk of user confusion (when to use what?)
- ❌ Search and filtering across 3 types
- ❌ 6-8 weeks implementation time
- ❌ Harder to explain in onboarding

**Use Cases:**
- Power users who want maximum control
- After validating simpler approach (Approach 2)
- Phase 2+ feature (not MVP)
- When user research shows demand for standalone tasks

**Code Example:**
```dart
// User workflow 1: Quick standalone task
final quickTask = Item(
  type: ItemType.task,
  title: 'Buy milk',
  isCompleted: false,
  dueDate: DateTime.now().add(Duration(hours: 2)),
);

// User workflow 2: Organized todo list
final projectTasks = TodoList(
  name: 'Home Renovation',
  items: [
    TodoItem(title: 'Submit permit', dueDate: tomorrow),
    TodoItem(title: 'Hire contractor', dueDate: nextWeek),
  ],
);
```

**Estimated Effort:** 6-8 weeks
- 1.5 weeks: Extended data models
- 1.5 weeks: Repository layer with multi-type support
- 2 weeks: UI for both paradigms
- 1 week: Migration from old data
- 1 week: Testing all interaction paths
- 1 week: Polish and edge cases

---

## Tools and Libraries

### Option 1: Hive (Current, Keep)

**Purpose:** Local embedded database for offline-first storage

**Maturity:** Production-ready (v2.2.3+)

**License:** Apache 2.0

**Community:** 3.8k+ GitHub stars, active maintenance

**Integration Effort:** Already integrated ✅

**Key Features:**
- Fast key-value storage
- Type-safe with custom adapters
- No native dependencies
- Lazy box support for large datasets
- Encryption support

**Recommendation:** ✅ **Keep for local storage** - Already working well, no need to change

**Considerations for New Models:**
- Need to write Hive TypeAdapters for TodoList, ListModel
- Use lazy boxes for sub-items if lists become very large
- Consider separate boxes for better performance:
  - `todo_lists` box
  - `lists` box
  - `items` box (notes)

---

### Option 2: Markdown Support (flutter_markdown)

**Purpose:** Rich text rendering and editing for Notes

**Maturity:** Production-ready (v0.6.18+)

**License:** BSD-3-Clause

**Community:** 1.5k+ GitHub stars, Flutter Favorite package

**Integration Effort:** Medium (2-3 days)

**Key Features:**
- Render markdown to Flutter widgets
- Syntax highlighting for code blocks
- Image support
- Link handling
- Customizable styling

**Use Case from Concept:**
Notes should support:
- Bold, italic, headings (lines 208-209)
- Bullet points and numbered lists (line 209)
- Code blocks (line 211)
- Links (line 210)

**Implementation Example:**
```dart
// In Note detail screen
import 'package:flutter_markdown/flutter_markdown.dart';

Markdown(
  data: noteContent,
  styleSheet: MarkdownStyleSheet(
    h1: AppTypography.h1,
    p: AppTypography.bodyLarge,
    code: AppTypography.code,
  ),
  onTapLink: (text, href, title) {
    // Handle [[Note Title]] links (concept line 321-322)
    if (href?.startsWith('[[') ?? false) {
      _navigateToLinkedNote(href);
    }
  },
)
```

**Recommendation:** ✅ **Implement in Phase 2** - Aligns with concept's Note features (Section 4, lines 184-214)

---

### Option 3: Markdown Editor (flutter_quill or markdown_editable_textinput)

**Purpose:** Rich text editing interface for Notes

**Maturity:** flutter_quill is production-ready (v9.0.0+), widely used

**License:** MIT

**Community:** 2.3k+ GitHub stars

**Integration Effort:** Medium-High (1 week for basic, 2 weeks for full)

**Key Features:**
- WYSIWYG editing
- Toolbar with formatting options
- Image insertion
- Delta format (JSON) for storage
- Mobile-optimized

**Alternative: markdown_editable_textinput**
- Simpler, markdown-first approach
- Less feature-rich but easier to integrate
- Better for users comfortable with markdown syntax

**Implementation Consideration:**
```dart
// Storage format decision
class Item {
  String? content;        // Plain text (current)
  String? richContent;    // NEW: Quill Delta JSON or Markdown
  ContentFormat format;   // NEW: plain, markdown, rich
}

enum ContentFormat {
  plain,     // Current default
  markdown,  // For markdown_editable_textinput
  rich,      // For flutter_quill
}
```

**Recommendation:** ⚠️ **Defer to Phase 2** - Not essential for MVP, adds complexity

**Phase 1 Alternative:** Keep plain text, add simple markdown shortcuts (**, *, -, [])

---

### Option 4: Reorderable Lists (reorderables package)

**Purpose:** Drag-and-drop reordering for list items and todos

**Maturity:** Production-ready (v0.6.0+)

**License:** MIT

**Community:** 300+ stars, actively maintained

**Integration Effort:** Low (2-3 days)

**Key Features:**
- Smooth drag animations
- Works with ListView and GridView
- Haptic feedback built-in
- Auto-scroll during drag

**Use Case from Concept:**
Line 147: "Drag & drop → Reorder" for todos

**Implementation Example:**
```dart
ReorderableListView.builder(
  itemCount: todoList.items.length,
  onReorder: (oldIndex, newIndex) async {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = todoList.items.removeAt(oldIndex);
      todoList.items.insert(newIndex, item);

      // Update sortOrder for all items
      for (var i = 0; i < todoList.items.length; i++) {
        todoList.items[i].sortOrder = i;
      }
    });

    await _todoListRepository.update(todoList);
  },
  itemBuilder: (context, index) {
    return TodoItemCard(
      key: ValueKey(todoList.items[index].id),
      item: todoList.items[index],
    );
  },
)
```

**Recommendation:** ✅ **Implement in Phase 1** - High value, low effort, expected feature

---

### Option 5: Cross-Linking System (Custom Implementation)

**Purpose:** Internal linking between Notes, Todo Lists, and Lists

**Maturity:** Custom implementation needed

**Integration Effort:** Medium (1 week)

**Key Features (from concept lines 318-326):**
- `[[Item Name]]` syntax for linking
- Clickable navigation to linked items
- Backlinks (items that reference this item)
- Auto-suggestions while typing

**Data Model Addition:**
```dart
class Item {
  // ... existing fields
  List<String> linkedItemIds;  // NEW: IDs of referenced items

  // Computed from content analysis
  List<String> get backlinks =>
    // Find all items that link to this item
}

// Helper to parse links from content
class LinkParser {
  static List<String> extractLinks(String content) {
    final regex = RegExp(r'\[\[(.+?)\]\]');
    return regex.allMatches(content)
                .map((m) => m.group(1)!)
                .toList();
  }

  static Future<List<String>> resolveLinks(
    List<String> linkNames,
    String currentSpaceId,
  ) async {
    // Search for items with matching titles in same space
    // Return list of item IDs
  }
}
```

**UI Implementation:**
```dart
// Markdown renderer with custom link handler
Markdown(
  data: noteContent,
  onTapLink: (text, href, title) {
    if (href?.startsWith('[[') && href?.endsWith(']]')) {
      final linkedItemName = href.substring(2, href.length - 2);
      _navigateToLinkedItem(linkedItemName);
    }
  },
)

// Auto-complete during editing
TextField(
  onChanged: (text) {
    if (text.endsWith('[[')) {
      _showLinkSuggestions(currentSpaceId);
    }
  },
)
```

**Recommendation:** ⚠️ **Phase 2 Feature** - Powerful but not essential for MVP validation (concept Phase 2, lines 612-628)

---

## Implementation Considerations

### Technical Requirements

#### Data Migration Strategy (Critical)

**Challenge:** Existing users have data in old format (flat Item model)

**Migration Approach:**

**Option A: One-Time Migration (Recommended)**
```dart
class MigrationService {
  Future<void> migrateToV2() async {
    final migrationComplete = await _checkMigrationStatus();
    if (migrationComplete) return;

    try {
      // 1. Backup existing data
      await _backupCurrentData();

      // 2. Create new boxes
      await _initializeNewBoxes();

      // 3. Migrate items
      await _migrateItems();

      // 4. Verify migration
      await _verifyMigration();

      // 5. Mark complete
      await _saveMigrationStatus(complete: true);

      // 6. Archive old box (don't delete for safety)
      await _archiveOldData();

    } catch (e) {
      // Rollback on error
      await _rollbackMigration();
      rethrow;
    }
  }

  Future<void> _migrateItems() async {
    final oldItems = Hive.box<Item>('items').values;

    // Group standalone tasks by space
    final standaloneTasksBySpace = <String, List<Item>>{};

    for (var item in oldItems) {
      if (item.type == ItemType.task) {
        standaloneTasksBySpace
          .putIfAbsent(item.spaceId, () => [])
          .add(item);
      } else if (item.type == ItemType.list) {
        await _migrateToListModel(item);
      } else if (item.type == ItemType.note) {
        await _migrateNote(item);
      }
    }

    // Convert standalone tasks to default "Quick Tasks" lists per space
    for (var entry in standaloneTasksBySpace.entries) {
      await _createQuickTasksList(entry.key, entry.value);
    }
  }

  Future<void> _migrateToListModel(Item oldListItem) async {
    final parsedItems = ItemTypeDetector.extractListItems(
      oldListItem.content ?? ''
    );

    final newList = ListModel(
      id: oldListItem.id,
      spaceId: oldListItem.spaceId,
      name: oldListItem.title,
      style: ListStyle.bullets,
      items: parsedItems.asMap().entries.map((e) => ListItem(
        id: uuid.v4(),
        title: e.value,
        sortOrder: e.key,
      )).toList(),
      createdAt: oldListItem.createdAt,
      updatedAt: oldListItem.updatedAt,
    );

    await Hive.box<ListModel>('lists').put(newList.id, newList);
  }

  Future<void> _createQuickTasksList(String spaceId, List<Item> tasks) async {
    final todoList = TodoList(
      id: uuid.v4(),
      spaceId: spaceId,
      name: 'Quick Tasks',
      description: 'Migrated from standalone tasks',
      items: tasks.map((t) => TodoItem(
        id: t.id,
        title: t.title,
        description: t.content,
        isCompleted: t.isCompleted,
        dueDate: t.dueDate,
        sortOrder: 0,
      )).toList(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await Hive.box<TodoList>('todo_lists').put(todoList.id, todoList);
  }
}
```

**Option B: Progressive Migration**
- Lazy migration: Convert items when accessed
- Pros: No upfront delay, graceful
- Cons: Complex, dual-model support during transition

**Recommendation:** Option A (one-time) with clear progress UI

---

#### Performance Implications

**Consideration 1: List Size Limits**
- **Problem:** Large TodoLists (100+ items) embedded in model
- **Solution:**
  - Set soft limit (50 items per list)
  - Use Hive lazy boxes if needed
  - Pagination in UI for large lists

**Consideration 2: Query Performance**
- **Current:** Simple `box.values` for all items
- **New:** Need to query multiple boxes and combine
```dart
// Loading Space content
Future<SpaceContent> loadSpaceContent(String spaceId) async {
  final todoLists = await todoListsBox.values
    .where((l) => l.spaceId == spaceId)
    .toList();

  final lists = await listsBox.values
    .where((l) => l.spaceId == spaceId)
    .toList();

  final notes = await itemsBox.values
    .where((i) => i.spaceId == spaceId && i.type == ItemType.note)
    .toList();

  return SpaceContent(
    todoLists: todoLists,
    lists: lists,
    notes: notes,
  );
}
```
**Optimization:** Index by spaceId for faster lookups

**Consideration 3: Search Performance**
- **Problem:** Search now spans 3 boxes instead of 1
- **Solution:** Implement search index
```dart
class SearchIndex {
  // Maintains searchable text index
  Map<String, ContentReference> _index = {};

  void indexTodoList(TodoList list) {
    _index[list.id] = ContentReference(
      id: list.id,
      type: ContentType.todoList,
      searchableText: '${list.name} ${list.description} ${list.items.map((i) => i.title).join(' ')}',
    );
  }

  List<ContentReference> search(String query) {
    return _index.values
      .where((ref) => ref.searchableText.toLowerCase().contains(query.toLowerCase()))
      .toList();
  }
}
```

---

#### Scalability Considerations

**Multi-Device Sync (Phase 2 with Supabase):**
- TodoList and ListModel need JSON serialization (already planned)
- Sub-items sync as part of parent (embedded)
- Conflict resolution: Last-write-wins for metadata, operational transforms for item lists

**Database Schema (Supabase):**
```sql
-- Spaces table (existing)
CREATE TABLE spaces (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT,
  color TEXT,
  user_id UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Todo Lists table (NEW)
CREATE TABLE todo_lists (
  id UUID PRIMARY KEY,
  space_id UUID REFERENCES spaces(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Todo Items table (NEW)
CREATE TABLE todo_items (
  id UUID PRIMARY KEY,
  todo_list_id UUID REFERENCES todo_lists(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  is_completed BOOLEAN DEFAULT FALSE,
  due_date TIMESTAMPTZ,
  priority TEXT,
  sort_order INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Lists table (NEW)
CREATE TABLE lists (
  id UUID PRIMARY KEY,
  space_id UUID REFERENCES spaces(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  icon TEXT,
  style TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- List Items table (NEW)
CREATE TABLE list_items (
  id UUID PRIMARY KEY,
  list_id UUID REFERENCES lists(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  notes TEXT,
  is_checked BOOLEAN,
  sort_order INTEGER
);

-- Notes table (existing, formerly items)
CREATE TABLE notes (
  id UUID PRIMARY KEY,
  space_id UUID REFERENCES spaces(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Benefits of Relational Structure:**
- ✅ Proper foreign keys and cascade deletes
- ✅ Efficient queries (JOIN on space_id)
- ✅ Indexes on frequently queried fields
- ✅ Row-level security per user

---

#### Security Aspects

**Current Security (Offline-Only):**
- ✅ Data stored locally on device
- ✅ No network transmission
- ✅ Hive encryption available (not enabled)

**Future Considerations (Phase 2 Sync):**
- Row-Level Security (RLS) on Supabase
- End-to-end encryption for sensitive lists
- OAuth integration (Google, Apple Sign-In)
- Secure token storage for sync auth

**Recommendation:** Enable Hive encryption for sensitive data even in offline mode
```dart
await Hive.openBox<TodoList>(
  'todo_lists',
  encryptionCipher: HiveAesCipher(encryptionKey),
);
```

---

### Integration Points

#### How It Fits with Existing Architecture

**Current Architecture Layers:**
```
UI Layer (Screens, Components)
    ↓
Provider Layer (State Management)
    ↓
Repository Layer (Data Operations)
    ↓
Local Storage (Hive)
```

**Proposed Changes:**

**1. Model Layer** (Data Models)
```
OLD: Item (task/note/list)
NEW: TodoList, ListModel, Item (note-only)

Changes Required:
- Create todo_list_model.dart
- Create list_model.dart
- Update item_model.dart (simplify to notes only)
- Create Hive TypeAdapters for new models
```

**2. Repository Layer** (Data Access)
```
OLD: ItemRepository (CRUD for all items)
NEW:
- TodoListRepository (CRUD for todo lists + items)
- ListRepository (CRUD for lists + items)
- NoteRepository (CRUD for notes)

Changes Required:
- Implement new repositories
- Migrate ItemRepository logic
- Update error handling for each type
```

**3. Provider Layer** (State Management)
```
OLD: ItemsProvider (manages all items)
NEW:
- TodoListsProvider (manages todo lists)
- ListsProvider (manages lists)
- NotesProvider (manages notes)
OR
- ContentProvider (unified provider for all 3 types)

Recommendation: Unified ContentProvider
class ContentProvider extends ChangeNotifier {
  List<TodoList> _todoLists = [];
  List<ListModel> _lists = [];
  List<Item> _notes = [];

  // Unified loading
  Future<void> loadSpaceContent(String spaceId) async {
    _todoLists = await _todoListRepo.getBySpace(spaceId);
    _lists = await _listRepo.getBySpace(spaceId);
    _notes = await _noteRepo.getBySpace(spaceId);
    notifyListeners();
  }

  // Type-specific accessors
  List<TodoList> getTodoLists(String spaceId) =>
    _todoLists.where((l) => l.spaceId == spaceId).toList();
}
```

**4. UI Layer** (Screens and Components)
```
OLD:
- ItemCard (single card for all types)
- ItemDetailScreen (single detail screen)

NEW:
- TodoListCard (shows progress 4/7)
- ListCard (shows item count)
- NoteCard (shows preview)
- TodoListDetailScreen (expandable todos)
- ListDetailScreen (bullet/numbered items)
- NoteDetailScreen (rich text editor)

Shared Components:
- CardContainer (gradient borders)
- ContentTypeIcon
- MetadataRow
```

---

#### Required Modifications

**File-by-File Change Summary:**

**1. Data Models** (Priority: Critical)
```
📁 lib/data/models/
  ✨ NEW: todo_list_model.dart
  ✨ NEW: list_model.dart
  ✏️ MODIFY: item_model.dart (simplify)
  ✏️ MODIFY: space_model.dart (update item count logic)
```

**2. Hive Adapters** (Priority: Critical)
```
📁 lib/data/local/
  ✨ NEW: todo_list_adapter.dart
  ✨ NEW: list_adapter.dart
  ✏️ MODIFY: hive_database.dart (register new adapters)
```

**3. Repositories** (Priority: Critical)
```
📁 lib/data/repositories/
  ✨ NEW: todo_list_repository.dart
  ✨ NEW: list_repository.dart
  ✏️ MODIFY: item_repository.dart → note_repository.dart
  ✏️ MODIFY: space_repository.dart (update item counting)
```

**4. Providers** (Priority: High)
```
📁 lib/providers/
  ✏️ MODIFY: items_provider.dart → content_provider.dart
  OR
  ✨ NEW: todo_lists_provider.dart
  ✨ NEW: lists_provider.dart
  ✨ NEW: notes_provider.dart
```

**5. UI Components** (Priority: High)
```
📁 lib/widgets/components/cards/
  ✏️ MODIFY: item_card.dart → Split into:
    ✨ NEW: todo_list_card.dart
    ✨ NEW: list_card.dart
    ✨ NEW: note_card.dart
  ✨ NEW: todo_item_card.dart (sub-item)
  ✨ NEW: list_item_card.dart (sub-item)
```

**6. Screens** (Priority: High)
```
📁 lib/widgets/screens/
  ✏️ MODIFY: item_detail_screen.dart → Split into:
    ✨ NEW: todo_list_detail_screen.dart
    ✨ NEW: list_detail_screen.dart
    ✨ NEW: note_detail_screen.dart
  ✏️ MODIFY: home_screen.dart (load multiple content types)
  ✏️ MODIFY: space_detail_screen.dart (display mixed content)
```

**7. Utilities** (Priority: Medium)
```
📁 lib/core/utils/
  ✏️ MODIFY: item_type_detector.dart
    - Update to detect TodoList vs List vs Note
    - Add list style detection (bullets/numbered/checkboxes)
  ✨ NEW: list_parser.dart (extract items from text)
```

**8. Migration** (Priority: Critical)
```
📁 lib/data/migration/
  ✨ NEW: migration_service.dart
  ✨ NEW: v2_migration.dart
  ✨ NEW: migration_screen.dart (UI with progress)
```

---

#### API Changes Needed

**Current API (Provider Methods):**
```dart
// ItemsProvider (OLD)
Future<void> createItem(Item item)
Future<void> updateItem(Item item)
Future<void> deleteItem(String id)
List<Item> getItemsBySpace(String spaceId)
List<Item> getItemsByType(ItemType type)
```

**New API (ContentProvider):**
```dart
// TodoLists
Future<void> createTodoList(TodoList list)
Future<void> updateTodoList(TodoList list)
Future<void> deleteTodoList(String id)
Future<void> addTodoItem(String listId, TodoItem item)
Future<void> updateTodoItem(String listId, String itemId, TodoItem item)
Future<void> deleteTodoItem(String listId, String itemId)
Future<void> toggleTodoItem(String listId, String itemId)
Future<void> reorderTodoItems(String listId, int oldIndex, int newIndex)

// Lists
Future<void> createList(ListModel list)
Future<void> updateList(ListModel list)
Future<void> deleteList(String id)
Future<void> addListItem(String listId, ListItem item)
Future<void> updateListItem(String listId, String itemId, ListItem item)
Future<void> deleteListItem(String listId, String itemId)
Future<void> toggleListItem(String listId, String itemId)

// Notes
Future<void> createNote(Item note)
Future<void> updateNote(Item note)
Future<void> deleteNote(String id)

// Unified Queries
List<TodoList> getTodoListsBySpace(String spaceId)
List<ListModel> getListsBySpace(String spaceId)
List<Item> getNotesBySpace(String spaceId)
List<dynamic> getAllContentBySpace(String spaceId) // Mixed
TodoList? findTodoListById(String id)
ListModel? findListById(String id)
Item? findNoteById(String id)

// Cross-cutting
Future<SearchResults> search(String query)
List<TodoItem> getTodosWithDueDate(DateTime date)
```

**Navigation API Changes:**
```dart
// OLD
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ItemDetailScreen(itemId: item.id),
  ),
)

// NEW - Type-specific navigation
void navigateToTodoList(BuildContext context, String listId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TodoListDetailScreen(listId: listId),
    ),
  );
}

void navigateToList(BuildContext context, String listId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ListDetailScreen(listId: listId),
    ),
  );
}

void navigateToNote(BuildContext context, String noteId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => NoteDetailScreen(noteId: noteId),
    ),
  );
}
```

---

#### Database Impacts

**Current Hive Structure:**
```
Hive Boxes:
- items: Box<Item>
- spaces: Box<Space>
```

**New Hive Structure:**
```
Hive Boxes:
- todo_lists: Box<TodoList>
- lists: Box<ListModel>
- notes: Box<Item>  (or rename to Box<Note>)
- spaces: Box<Space>
- items_backup: Box<Item>  (archived for rollback)
```

**Size Implications:**
- **OLD:** 1 item = ~500 bytes (title, content, metadata)
- **NEW:** 1 TodoList with 5 items = ~800 bytes (list + embedded items)
- **Impact:** Slightly larger due to structure, but negligible for local storage

**Indexing Strategy:**
```dart
// Create custom indexes for faster queries
class HiveDatabase {
  static Map<String, List<String>> _spaceIndex = {};

  static void _buildSpaceIndex() {
    // Index: spaceId -> [list of content IDs]
    for (var todoList in todoListsBox.values) {
      _spaceIndex
        .putIfAbsent(todoList.spaceId, () => [])
        .add(todoList.id);
    }
    // Repeat for lists and notes
  }

  static List<dynamic> getContentBySpace(String spaceId) {
    final ids = _spaceIndex[spaceId] ?? [];
    // Fast lookup by cached IDs
  }
}
```

**Backup Strategy:**
```dart
class BackupService {
  Future<void> createBackup() async {
    final backupPath = await _getBackupPath();

    // Export all boxes to JSON
    final backup = {
      'version': 2,
      'timestamp': DateTime.now().toIso8601String(),
      'todo_lists': todoListsBox.values.map((l) => l.toJson()).toList(),
      'lists': listsBox.values.map((l) => l.toJson()).toList(),
      'notes': notesBox.values.map((n) => n.toJson()).toList(),
      'spaces': spacesBox.values.map((s) => s.toJson()).toList(),
    };

    await File(backupPath).writeAsString(jsonEncode(backup));
  }
}
```

---

### Risks and Mitigation

#### Risk 1: Data Loss During Migration

**Risk Level:** 🔴 Critical

**Scenario:** Migration fails mid-process, user loses data

**Mitigation Strategy:**
1. ✅ **Full backup before migration** (stored separately)
2. ✅ **Atomic migration** (all-or-nothing using transactions)
3. ✅ **Verification step** (count items before/after)
4. ✅ **Rollback mechanism** (restore from backup on failure)
5. ✅ **Keep old data** (don't delete original items box for 30 days)
6. ✅ **Export option** (let users export data before migration)

**Implementation:**
```dart
class SafeMigration {
  Future<void> migrate() async {
    // 1. Backup
    final backupSuccess = await _createBackup();
    if (!backupSuccess) throw MigrationException('Backup failed');

    // 2. Verify current data
    final originalCount = _countItems();

    // 3. Migrate in transaction
    try {
      await _performMigration();
    } catch (e) {
      await _rollback();
      throw MigrationException('Migration failed: $e');
    }

    // 4. Verify new data
    final newCount = _countMigratedItems();
    if (newCount != originalCount) {
      await _rollback();
      throw MigrationException('Item count mismatch');
    }

    // 5. Mark complete
    await _saveMigrationStatus();
  }
}
```

---

#### Risk 2: User Confusion with New Structure

**Risk Level:** 🟡 Medium

**Scenario:** Users don't understand TodoList vs List vs Note, or don't know when to create which

**Mitigation Strategy:**
1. ✅ **Onboarding tutorial** (show examples with screenshots)
2. ✅ **Smart defaults** (guide users with suggestions)
3. ✅ **Contextual help** (tooltips on first use)
4. ✅ **Migration guide** (explain changes to existing users)
5. ✅ **Preserve muscle memory** (keep quick capture familiar)

**Onboarding Flow:**
```
Screen 1: "What's New in Later"
- TodoLists: Organize your actionable tasks with deadlines
  Example: "Home Renovation Tasks", "Weekly Errands"

- Lists: Keep reference collections without pressure
  Example: "Movies to Watch", "Shopping List", "Gift Ideas"

- Notes: Capture thoughts and context for your projects
  Example: "Project Planning", "Meeting Notes", "Budget"

Screen 2: "Creating Content"
- Quick Add (+) button works the same way
- We'll suggest the right type based on what you write
- You can always change the type later

Screen 3: "Your Existing Items"
- We've organized your existing tasks into "Quick Tasks" lists
- Your lists and notes are exactly where you left them
- Everything is in the same Spaces
```

**Smart Suggestions:**
```dart
class ContentTypeSuggester {
  ContentType suggestType(String input) {
    if (input.contains(RegExp(r'(todo|task|need to|have to)', caseSensitive: false))) {
      return ContentType.todoList;
    }

    if (input.contains(RegExp(r'(list|shopping|to watch|to read)', caseSensitive: false))) {
      return ContentType.list;
    }

    if (input.length > 100 || input.split('\n').length > 3) {
      return ContentType.note;
    }

    // Default to todoList for ambiguous cases
    return ContentType.todoList;
  }
}
```

---

#### Risk 3: Performance Degradation

**Risk Level:** 🟡 Medium

**Scenario:** Querying multiple boxes slows down app, large lists cause UI lag

**Mitigation Strategy:**
1. ✅ **Lazy loading** (load lists on-demand, not all at once)
2. ✅ **Pagination** (limit visible items, load more on scroll)
3. ✅ **Caching** (keep frequently accessed lists in memory)
4. ✅ **Background loading** (load while showing skeleton)
5. ✅ **Performance monitoring** (measure query times)
6. ✅ **Size limits** (warn users when lists get too large)

**Implementation:**
```dart
class PerformantContentLoader {
  static const MAX_INITIAL_ITEMS = 20;

  Future<SpaceContent> loadSpaceContent(String spaceId) async {
    final stopwatch = Stopwatch()..start();

    // Load in parallel
    final results = await Future.wait([
      _loadTodoLists(spaceId),
      _loadLists(spaceId),
      _loadNotes(spaceId),
    ]);

    stopwatch.stop();
    _logPerformance('loadSpaceContent', stopwatch.elapsedMilliseconds);

    return SpaceContent(
      todoLists: results[0],
      lists: results[1],
      notes: results[2],
    );
  }

  // Only load first N items per list, lazy load rest
  Future<List<TodoList>> _loadTodoLists(String spaceId) async {
    return todoListsBox.values
      .where((l) => l.spaceId == spaceId)
      .map((l) => l.copyWith(
        items: l.items.take(MAX_INITIAL_ITEMS).toList(),
      ))
      .toList();
  }
}
```

---

#### Risk 4: Backward Compatibility Breaking

**Risk Level:** 🟡 Medium

**Scenario:** Users with old app version can't open data after update

**Mitigation Strategy:**
1. ✅ **Versioned data** (store schema version in database)
2. ✅ **Migration on app update** (automatic, not manual)
3. ✅ **Support old format temporarily** (read-only)
4. ✅ **Clear update notes** (explain what's changing)
5. ✅ **Staged rollout** (beta testers first, then public)
6. ✅ **Hotfix plan** (ability to rollback migration if needed)

**Version Management:**
```dart
class DataVersionManager {
  static const CURRENT_VERSION = 2;

  Future<void> ensureCompatibility() async {
    final storedVersion = await _getStoredVersion();

    if (storedVersion == null) {
      // Fresh install
      await _initializeV2();
    } else if (storedVersion < CURRENT_VERSION) {
      // Migration needed
      await _showMigrationDialog();
      await _migrateFromV1toV2();
    } else if (storedVersion > CURRENT_VERSION) {
      // User downgraded app (rare)
      throw VersionException('App version too old for this data');
    }
  }
}
```

---

## Recommendations

### Recommended Approach

After analyzing all options, here is the recommended implementation strategy:

#### **Approach: Two-Phase Evolution**

**Phase 1: Enhanced Current Model (Milestone 1, 2-3 weeks)**
Implement **Approach 1 (Minimal Evolution)** as a quick win to validate user interest

**Deliverables:**
- ✅ Add `parentItemId` and `sortOrder` to Item model
- ✅ UI shows expandable list items
- ✅ Parser creates linked items instead of text content
- ✅ Basic reordering support
- ✅ User testing and feedback collection

**Success Criteria:**
- Users actively create list items (not just single-line lists)
- Average list has 3+ items
- Positive feedback on organization

**Decision Point:** After Phase 1, evaluate user feedback. If users love the list functionality, proceed to Phase 2.

---

**Phase 2: Full Concept Implementation (Milestone 2, 4-6 weeks)**
Implement **Approach 2 (Dual Model)** for production-ready architecture

**Deliverables:**
- ✅ TodoList and ListModel as first-class containers
- ✅ Data migration from Phase 1 enhanced model
- ✅ Separate detail screens for each type
- ✅ Progress indicators (4/7 completed)
- ✅ Rich metadata (due dates, priorities, custom icons)
- ✅ Reorderable items with drag-and-drop
- ✅ Cross-linking foundation (for future Phase 3)

**Success Criteria:**
- Migration success rate > 99%
- No performance degradation
- User retention maintained or improved
- App Store rating maintained > 4.5

---

#### Why This Approach?

**Advantages:**
1. ✅ **Lower risk** - Validate concept before major refactor
2. ✅ **Faster time-to-market** - Something in users' hands in 2-3 weeks
3. ✅ **User-driven** - Real feedback informs Phase 2 design
4. ✅ **Incremental migration** - Easier data transitions
5. ✅ **Budget-friendly** - Smaller initial investment

**Timeline:**
```
Week 1-2:   Phase 1 Implementation (Enhanced Current Model)
Week 3:     Phase 1 Beta Testing & Feedback
Week 4:     Phase 1 Iteration based on feedback
            👉 Decision: Proceed to Phase 2? 👈
Week 5-6:   Phase 2 Data Model Design
Week 7-8:   Phase 2 Implementation (TodoList/ListModel)
Week 9:     Phase 2 Migration & Testing
Week 10:    Phase 2 Beta Testing
Week 11:    Phase 2 Public Release
```

---

### Alternative Recommendation (Aggressive)

If you want to go **directly to the full concept implementation** (skip Phase 1):

**Implement Approach 2 immediately** with comprehensive user onboarding

**Rationale for Aggressive Approach:**
- ✅ Concept is well-researched (735-line spec)
- ✅ Clear industry precedent (Todoist, Apple Reminders, Microsoft To Do)
- ✅ Current architecture ready for change (clean, testable)
- ✅ Risk mitigation strategies in place (backup, rollback)

**Recommendation:** Only if you have:
- 🎯 Confidence in product vision
- 🎯 Resources for 6-week development cycle
- 🎯 Beta tester group ready for feedback
- 🎯 Buffer time for iteration (weeks 7-8)

---

### Feature Priority Matrix

| Feature | Concept Alignment | User Value | Implementation Effort | Priority |
|---------|------------------|------------|---------------------|----------|
| **TodoList Container** | ✅✅✅ High | ✅✅✅ High | 🟡 Medium | 🔴 **P0 - Critical** |
| **List Container** | ✅✅✅ High | ✅✅✅ High | 🟡 Medium | 🔴 **P0 - Critical** |
| **Progress Indicators** (4/7) | ✅✅✅ High | ✅✅ Medium | 🟢 Low | 🟡 **P1 - High** |
| **Item Reordering** | ✅✅ Medium | ✅✅✅ High | 🟢 Low | 🟡 **P1 - High** |
| **Custom List Icons** | ✅✅ Medium | ✅✅ Medium | 🟢 Low | 🟡 **P1 - High** |
| **Note [[Linking]]** | ✅✅ Medium | ✅✅ Medium | 🟡 Medium | 🟢 **P2 - Medium** |
| **Rich Text Editor** | ✅✅ Medium | ✅ Low | 🔴 High | 🟢 **P2 - Medium** |
| **Content Conversion** | ✅✅ Medium | ✅ Low | 🟡 Medium | 🟢 **P2 - Medium** |
| **Space Templates** | ✅✅✅ High | ✅ Low | 🟡 Medium | ⚪ **P3 - Low** |
| **List Style Options** | ✅ Low | ✅ Low | 🟢 Low | ⚪ **P3 - Low** |

**Legend:**
- 🔴 **P0 - Critical**: Must-have for concept implementation
- 🟡 **P1 - High**: Should-have, high impact
- 🟢 **P2 - Medium**: Nice-to-have, moderate value
- ⚪ **P3 - Low**: Future consideration

---

### Next Steps After Research

**Immediate Actions (This Week):**
1. ✅ Review this research document with team
2. ✅ Decide: Two-Phase (safer) or Aggressive (faster) approach
3. ✅ Set up project tracking (use TodoWrite for milestones)
4. ✅ Create design mockups for TodoList/List detail screens
5. ✅ Write data migration test cases

**Week 1-2 (Implementation Start):**
1. If Two-Phase: Start Phase 1 (Enhanced Current Model)
2. If Aggressive: Start data model design (TodoList/ListModel)
3. Set up feature branch: `feature/list-containers`
4. Create migration service skeleton
5. Write Hive TypeAdapters

**User Research (Ongoing):**
1. Interview 5-10 current users about list organization
2. Questions:
   - How do you currently use the "List" item type?
   - Do you create multiple related tasks that should be grouped?
   - Would you find a "Shopping List" container with items useful?
   - How do you differentiate between actionable vs. reference lists?
3. Synthesize findings and adjust implementation

**Beta Testing Plan:**
1. Recruit 20-30 beta testers (mix of power users and casual users)
2. Provide migration guide and onboarding
3. Collect feedback via in-app survey + user interviews
4. Iterate based on feedback before public release

---

## References

### Product Concept Document
- **Source:** `/Users/jonascurth/Downloads/later-app-product-concept.md`
- **Version:** 1.0 (October 23, 2025)
- **Key Sections:**
  - Section 2: Information Architecture (lines 20-40)
  - Section 4: Content Type Details (lines 111-214)
  - Section 9: Space View Concepts (lines 404-447)
  - Section 12: Technical Considerations (lines 536-583)

### Current Implementation Files
- **Item Model:** `apps/later_mobile/lib/data/models/item_model.dart`
- **Hive Database:** `apps/later_mobile/lib/data/local/hive_database.dart`
- **Item Repository:** `apps/later_mobile/lib/data/repositories/item_repository.dart`
- **Item Card:** `apps/later_mobile/lib/widgets/components/cards/item_card.dart`
- **Type Detector:** `apps/later_mobile/lib/core/utils/item_type_detector.dart`

### Industry References
- **Todoist:** Projects with tasks (container model)
  - https://todoist.com/
- **Apple Reminders:** Lists with reminders (container model)
  - https://www.apple.com/ios/reminders/
- **Microsoft To Do:** Lists with todos (container model)
  - https://todo.microsoft.com/
- **Notion:** Blocks with infinite nesting
  - https://www.notion.so/

### Technical Documentation
- **Hive Documentation:** https://docs.hivedb.dev/
- **Flutter Markdown:** https://pub.dev/packages/flutter_markdown
- **Flutter Quill:** https://pub.dev/packages/flutter_quill
- **Reorderables:** https://pub.dev/packages/reorderables

---

## Appendix

### A. Comparison Table: Concept vs. Current Implementation

| Feature | Concept | Current Implementation | Gap |
|---------|---------|----------------------|-----|
| **Data Structure** | TodoList, List, Note as containers | Item (task/note/list) as flat items | ❌ Major gap |
| **List Items** | Lists contain multiple sub-items | List is single item with text content | ❌ Major gap |
| **Progress Tracking** | Built-in (4/7 completed) | Manual counting | ❌ Gap |
| **Item Reordering** | Drag & drop within lists | No reordering | ❌ Gap |
| **Custom Icons** | Per-list custom icons | Per-space icons only | ❌ Gap |
| **Due Dates** | TodoList items have due dates | Tasks have due dates | ✅ Implemented |
| **Spaces** | Project containers | Spaces implemented | ✅ Implemented |
| **Quick Capture** | Type-aware quick add | Smart type detection | ✅ Implemented |
| **Offline-First** | Full offline support | 100% offline | ✅ Implemented |
| **Rich Text Notes** | Markdown, images, links | Plain text only | ⚠️ Partial gap |
| **Cross-Linking** | [[Note Title]] syntax | Not implemented | ❌ Gap |
| **Content Conversion** | Note→Todo, List→TodoList | Not implemented | ❌ Gap |
| **Space Templates** | Pre-built structures | Not implemented | ❌ Gap |
| **List Styles** | Bullets, numbered, checkboxes | Parser recognizes but no storage | ⚠️ Partial gap |

**Summary:**
- ✅ **6 features fully aligned**
- ⚠️ **2 features partially aligned**
- ❌ **9 features missing or require major changes**

---

### B. Sample Data Migration

**Before (Current Model):**
```json
{
  "items": [
    {
      "id": "abc-123",
      "type": "task",
      "title": "Buy groceries",
      "content": "Milk, eggs, bread",
      "spaceId": "home-space",
      "isCompleted": false,
      "dueDate": "2025-10-24T18:00:00Z"
    },
    {
      "id": "def-456",
      "type": "list",
      "title": "Movies to Watch",
      "content": "- Inception\n- The Matrix\n- Interstellar",
      "spaceId": "entertainment-space"
    },
    {
      "id": "ghi-789",
      "type": "note",
      "title": "Project Ideas",
      "content": "Build a productivity app...",
      "spaceId": "work-space"
    }
  ]
}
```

**After (New Model):**
```json
{
  "todo_lists": [
    {
      "id": "quick-tasks-home",
      "spaceId": "home-space",
      "name": "Quick Tasks",
      "items": [
        {
          "id": "abc-123",
          "title": "Buy groceries",
          "description": "Milk, eggs, bread",
          "isCompleted": false,
          "dueDate": "2025-10-24T18:00:00Z",
          "sortOrder": 0
        }
      ]
    }
  ],
  "lists": [
    {
      "id": "def-456",
      "spaceId": "entertainment-space",
      "name": "Movies to Watch",
      "style": "bullets",
      "items": [
        {
          "id": "item-1",
          "title": "Inception",
          "sortOrder": 0
        },
        {
          "id": "item-2",
          "title": "The Matrix",
          "sortOrder": 1
        },
        {
          "id": "item-3",
          "title": "Interstellar",
          "sortOrder": 2
        }
      ]
    }
  ],
  "notes": [
    {
      "id": "ghi-789",
      "type": "note",
      "title": "Project Ideas",
      "content": "Build a productivity app...",
      "spaceId": "work-space"
    }
  ]
}
```

---

### C. UI Mockup Descriptions

**TodoList Card (Concept Aligned):**
```
┌─────────────────────────────────────┐
│ ☐ Permit Applications        4/7 ✓ │  ← Red-orange gradient border
│   Todo List · 2 hours ago           │
│   ──────────────────────────        │  ← Progress bar (57%)
│   📅 2 items due today               │
└─────────────────────────────────────┘
```

**List Card (Concept Aligned):**
```
┌─────────────────────────────────────┐
│ 🛒 Groceries              12 items  │  ← Green gradient border
│    List · 3 days ago                │
│                                     │
│    Milk, Eggs, Bread...             │  ← Preview of items
└─────────────────────────────────────┘
```

**TodoList Detail Screen:**
```
┌─────────────────────────────────────┐
│ ← Permit Applications          [···]│  ← Red-orange gradient header
│                                     │
│ ◯ Submit building permit   🔴 Today │  ← High priority
│ ◯ Hire structural engineer Fri Oct 25│
│ ✓ Get land registry extract         │  ← Completed (strikethrough)
│ ◯ Pick up building approval         │
│ ◯ Finalize insurance                │
│                                     │
│ [+ New Todo]                        │
└─────────────────────────────────────┘
```

---

### D. Questions for Further Investigation

#### User Behavior Questions
1. **List Usage Patterns:**
   - Do users currently write multiple list items in a single "List" item?
   - How many items on average?
   - Do they use bullet points, numbers, or plain text?

2. **Task Organization:**
   - Do users create many related tasks that should be grouped?
   - Would they prefer "Home Tasks" list vs. individual tasks?
   - How often do they check off tasks vs. delete them?

3. **Note Complexity:**
   - How long are typical notes?
   - Do users add lists within notes?
   - Would they use markdown if available?

#### Technical Questions
1. **Performance:**
   - What's the acceptable max size for a list (50, 100, 500 items)?
   - Should we implement virtualization for large lists?
   - How does query performance change with 3 boxes vs. 1?

2. **Sync Strategy:**
   - Should sub-items sync individually or as part of parent?
   - How to handle conflicts (reordering on two devices)?
   - Offline queue strategy for list operations?

3. **Migration:**
   - Should migration be automatic or user-initiated?
   - What's the rollback strategy if users hate the new structure?
   - How long to keep old data before cleanup?

#### Product Strategy Questions
1. **Onboarding:**
   - How much explanation do users need for TodoList vs. List distinction?
   - Should we show examples or let users discover organically?
   - What's the right amount of guidance without overwhelming?

2. **Defaults:**
   - Should quick capture default to TodoList or standalone task?
   - Should lists have checkboxes by default?
   - What's the default list style (bullets, numbered, checkboxes)?

3. **Future Features:**
   - Priority order: Rich text editor vs. Cross-linking vs. Templates?
   - Should Phase 2 include content conversion?
   - When to introduce collaboration features?

---

### E. Success Metrics

**Phase 1 (Enhanced Current Model) Success Criteria:**

**Engagement Metrics:**
- 50%+ of users create at least one list with 2+ items
- Average list length increases from 1.0 to 2.5+ items
- Time spent organizing increases by 20%

**Quality Metrics:**
- Migration success rate: 100% (no data loss)
- App crash rate remains < 0.1%
- Performance: Space loading < 500ms

**User Sentiment:**
- User interviews: 7+ out of 10 positive sentiment
- App Store reviews mention list organization positively
- Support tickets related to lists: < 5

---

**Phase 2 (Full Concept Implementation) Success Criteria:**

**Adoption Metrics:**
- 60%+ of users create at least one TodoList container
- 40%+ of users create at least one List container
- Average items per TodoList: 5+
- Average items per List: 8+

**Retention Metrics:**
- D7 retention remains ≥ 50% (maintained or improved)
- D30 retention remains ≥ 30%
- Churn rate due to change: < 5%

**Performance Metrics:**
- App launch time: < 1 second (maintained)
- Space loading time: < 500ms (maintained)
- Search across all types: < 300ms

**Migration Metrics:**
- Migration completion rate: 99%+
- Rollback rate: < 1%
- User-reported data issues: < 0.1% of users

---

*Research Document Version: 1.0*
*Created: October 24, 2025*
*Researcher: Claude Code*
*Status: Complete - Ready for Decision*
