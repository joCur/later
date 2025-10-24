# Research: Space Handling for New Data Model

## Executive Summary

The current space handling implementation in Later is **fully compatible** with the transition to TodoList/List/Note containers as first-class objects. The space architecture is well-designed as a **container-agnostic organizational layer** that simply groups content by `spaceId` - it doesn't care whether that content is flat items or hierarchical containers.

**Key Finding:** Spaces work like folders in a file system - they don't need to know the internal structure of what they contain. The new model's impact on spaces is **minimal and additive**, not disruptive.

**Recommendation:** Keep the space handling architecture largely as-is. Only update the space detail view (HomeScreen) to display mixed content types (TodoLists + Lists + Notes) instead of just flat Items.

---

## Research Scope

### What Was Researched
- Current space data model and storage
- Space creation, selection, and switching UX flows
- Space-item relationship architecture
- Navigation patterns and state management
- Industry patterns (Notion, Todoist, Microsoft To Do, Apple Reminders)
- HomeScreen filtering and display logic
- Quick Capture modal space selection
- Space count management

### What Was Explicitly Excluded
- Backend sync implementation (future Phase 2)
- Space templates feature (out of scope)
- Space collaboration/sharing (future feature)
- Detailed UI design mockups (covered in separate design work)

### Research Methodology
1. Code analysis of space-related components
2. Data flow tracing from space selection to item display
3. Industry research on workspace/folder organization
4. Gap analysis between current and required functionality
5. Feasibility assessment for new model compatibility

---

## Current State Analysis

### Space Data Model

**Core Structure:**
```dart
class Space {
  String id;              // UUID for space identification
  String name;            // User-visible name
  String? icon;           // Optional emoji/icon
  String? color;          // Optional color hex
  int itemCount;          // Number of items in space
  bool isArchived;        // Archive state
  DateTime createdAt;
  DateTime updatedAt;
}
```

**Key Characteristics:**
- **Container-agnostic**: Space only tracks `itemCount`, not item structure
- **Simple relationship**: Items reference space via `spaceId` field
- **No knowledge of content type**: Space doesn't differentiate between tasks/notes/lists
- **Clean separation**: Space concerns (organization) vs. Content concerns (structure)

### Space-Item Relationship

**Current Architecture:**
```
Space (id: "work")
  └── Item (type: task, spaceId: "work")
  └── Item (type: note, spaceId: "work")
  └── Item (type: list, spaceId: "work")
```

**New Architecture:**
```
Space (id: "work")
  └── TodoList (spaceId: "work")
      └── TodoItem 1
      └── TodoItem 2
  └── ListModel (spaceId: "work")
      └── ListItem 1
      └── ListItem 2
  └── Note (type: note, spaceId: "work")
```

**Impact:** Space still just references content via `spaceId` - the internal structure of that content is irrelevant to the Space model.

### Space Selection & Switching Flow

**Current Implementation:**

1. **Space Switcher Modal** (`space_switcher_modal.dart`):
   - Displays all available spaces with metadata
   - Shows current space with visual indicator
   - Keyboard shortcuts (1-9 for quick selection, arrow keys)
   - Search/filter capability
   - Archive/restore space actions
   - Create new space button

2. **State Management** (`spaces_provider.dart`):
   - `loadSpaces()`: Loads all non-archived spaces by default
   - `switchSpace(spaceId)`: Changes current active space
   - `currentSpace`: Tracks currently selected space
   - Persistence: Last selected space saved to SharedPreferences

3. **Navigation Flow:**
   ```
   User clicks Space name/icon → Space Switcher Modal opens
   → User selects different space → Provider.switchSpace(spaceId)
   → HomeScreen rebuilds with new space's items
   → Items filtered by new currentSpace.id
   ```

**Key Strengths:**
- Clean separation between space management and content display
- Persists space selection across app restarts
- Responsive design (mobile bottom sheet, desktop dialog)
- Excellent keyboard navigation support
- No hard-coded assumptions about content structure

### Space Creation Flow

**Implementation Details** (`create_space_modal.dart`):

**Features:**
- Modal supports both Create and Edit modes
- Name input (required, 1-100 characters)
- Icon picker: 30 curated emoji options
- Color picker: 12 color options from design system
- Form validation with real-time feedback
- Auto-switch to newly created space

**Space Creation Process:**
1. User clicks "Create New Space" button
2. Modal opens with empty form
3. User enters name, selects icon/color
4. On save: Space created with UUID
5. New space set as `currentSpace` automatically
6. Space persisted to SharedPreferences as last selected
7. Modal closes, HomeScreen reloads with new empty space

**Code Flow:**
```dart
// CreateSpaceModal → SpacesProvider
final space = Space(
  id: Uuid().v4(),
  name: name,
  icon: selectedIcon,
  color: selectedColor,
  itemCount: 0,  // Starts at 0
);

await spacesProvider.addSpace(space);
// Automatically sets as currentSpace
// Automatically persists to preferences
```

**Compatibility with New Model:**
✅ **Perfect** - Space creation is content-agnostic. New spaces will work identically whether they contain TodoLists, Lists, or Notes.

### Space Detail View (HomeScreen)

**Current Implementation:**

**Display Logic** (`home_screen.dart`):
```dart
// Load items by space
Future<void> _loadData() async {
  await spacesProvider.loadSpaces();
  if (spacesProvider.currentSpace != null) {
    await itemsProvider.loadItemsBySpace(currentSpace.id);
  }
}

// Filter items by type
List<Item> _getFilteredItems(List<Item> items) {
  switch (_selectedFilter) {
    case ItemFilter.all: return items;
    case ItemFilter.tasks: return items.where((i) => i.type == ItemType.task);
    case ItemFilter.notes: return items.where((i) => i.type == ItemType.note);
    case ItemFilter.lists: return items.where((i) => i.type == ItemType.list);
  }
}
```

**Current View Structure:**
```
HomeScreen
  ├── AppBar
  │   ├── Space name/icon (tap to open switcher)
  │   ├── Search button
  │   └── Menu button
  ├── Filter Chips: [All] [Tasks] [Notes] [Lists]
  ├── Item List
  │   └── ItemCard (uniform card for all types)
  └── Quick Capture FAB
```

**Key Features:**
- Pull-to-refresh
- Pagination (loads 100 items initially, 50 more on scroll)
- Empty state when no items
- Filter by item type
- Each item shows in uniform card regardless of type

**What Needs to Change:**
```diff
- itemsProvider.loadItemsBySpace(spaceId)
+ contentProvider.loadSpaceContent(spaceId)

- List<Item> _getFilteredItems(List<Item> items)
+ List<ContentContainer> _getFilteredContent(SpaceContent content)

- ItemCard(item: item)
+ TodoListCard(todoList: todoList)
+ ListCard(list: list)
+ NoteCard(note: note)
```

### Space Item Count Management

**Current System:**

**Tracking:**
```dart
class Space {
  int itemCount;  // Total items in space
}

// When item added:
await spacesProvider.incrementSpaceItemCount(spaceId);

// When item deleted:
await spacesProvider.decrementSpaceItemCount(spaceId);
```

**Provider Methods:**
```dart
Future<void> incrementSpaceItemCount(String spaceId) async {
  await _repository.incrementItemCount(spaceId);
  // Reload space to get updated count
  final updatedSpace = await _repository.getSpaceById(spaceId);
  // Update in-memory spaces list
  // Update currentSpace if it's the one being modified
}

Future<void> decrementSpaceItemCount(String spaceId) async {
  await _repository.decrementItemCount(spaceId);
  // Same reload logic...
}
```

**Behavior:**
- Count displayed in Space Switcher Modal next to space name
- Shows total number of items (not sub-items)
- Cannot go below 0
- Automatically updates when items added/removed

**Adaptation for New Model:**

**Simple Approach - Count Top-Level Containers:**
```dart
// In new model:
Space.itemCount = TodoLists.length + Lists.length + Notes.length

// Example:
// Space has:
//   - 2 TodoLists (each with 5 todos) = 2
//   - 3 Lists (each with 10 items) = 3
//   - 1 Note = 1
// itemCount = 6 (not 36!)
```

**Alternative Approach - Count All Items:**
```dart
// Show total tasks/items across all containers
Space.itemCount =
  (TodoLists.reduce(sum of todos)) +
  (Lists.reduce(sum of items)) +
  Notes.length

// Same example: itemCount = 26 (10 todos + 15 list items + 1 note)
```

**Recommendation:** Use **Simple Approach** (count containers, not sub-items):
- ✅ Consistent with "Space contains X things" mental model
- ✅ Simpler to implement and maintain
- ✅ Matches industry patterns (Notion shows "6 pages", not "127 blocks")
- ✅ Less confusing when items added/removed from lists

### Quick Capture Space Selection

**Current Implementation** (`quick_capture_modal.dart`):

**Space Selection UI:**
```dart
Widget _buildSpaceSelector() {
  return Consumer<SpacesProvider>(
    builder: (context, spacesProvider, child) {
      final currentSpace = spacesProvider.currentSpace;

      // Display selected space
      return PopupMenuButton<String>(
        child: Container(
          // Shows: icon + space name + dropdown arrow
        ),
        itemBuilder: (context) {
          // Dropdown with all available spaces
          return spacesProvider.spaces.map((space) {
            return PopupMenuItem(
              value: space.id,
              child: Row([icon, name]),
            );
          });
        },
        onSelected: (spaceId) {
          // Update local state (modal-only selection)
          setState(() => _selectedSpaceId = spaceId);
        },
      );
    },
  );
}
```

**Key Behavior:**
- Defaults to current space when modal opens
- User can select different space via dropdown
- Selection is **modal-local** (doesn't change global currentSpace)
- Item is created in selected space, not necessarily current space
- After modal closes, user stays on original space

**Code Flow:**
```dart
// When saving item:
final spaceId = _selectedSpaceId ?? currentSpace.id;

final item = Item(
  id: uuid.v4(),
  type: itemType,
  spaceId: spaceId,  // Uses selected space, not current
);

await itemsProvider.addItem(item);
```

**Compatibility with New Model:**
✅ **Perfect** - Space selection dropdown is content-agnostic. Works identically for creating TodoLists, Lists, or Notes.

**Potential Enhancement:**
```dart
// Could add visual indicator of what's being created
QuickCaptureModal(
  selectedType: ContentType.todoList,
  selectedSpace: spaceId,
  title: "Create in: ${space.icon} ${space.name}",
)
```

### Empty State Handling

**Current Implementation** (`empty_space_state.dart`):

**When Space Has No Items:**
```
┌─────────────────────────────────────┐
│                                     │
│          [Illustration]             │
│                                     │
│      No items in this space         │
│                                     │
│   Tap the + button to get started  │
│                                     │
└─────────────────────────────────────┘
```

**Features:**
- Shows when `items.length == 0` for current space
- Friendly illustration and message
- Guides user to Quick Capture FAB
- Adapts to light/dark theme

**What Needs to Change:**

**New Empty State Variations:**

1. **Completely Empty Space:**
   ```
   No content in this space yet
   Tap + to create a todo list, list, or note
   ```

2. **Filtered Empty State:**
   ```
   // When TodoLists filter active but space has 0 todo lists
   No todo lists in this space
   Try a different filter or create one
   ```

3. **All Content Archived/Completed:**
   ```
   Nothing to see here - great job!
   You've completed everything in this space
   ```

**Implementation:**
```dart
Widget _buildEmptyState(SpaceContent content, ContentFilter filter) {
  final hasTodoLists = content.todoLists.isNotEmpty;
  final hasLists = content.lists.isNotEmpty;
  final hasNotes = content.notes.isNotEmpty;
  final totalContent = content.todoLists.length +
                       content.lists.length +
                       content.notes.length;

  if (totalContent == 0) {
    return EmptySpaceState(
      message: "No content in this space yet",
      hint: "Tap + to create a todo list, list, or note",
    );
  } else {
    return FilteredEmptyState(
      filter: filter,
      message: "No ${filter.label.toLowerCase()} in this space",
      hint: "Try a different filter or create one",
    );
  }
}
```

### Navigation State Management

**Current Architecture:**

**Space State:**
- Managed by `SpacesProvider` (ChangeNotifier)
- Uses Hive for persistence
- Uses SharedPreferences for last selected space
- All screens consume space state via `Provider.of<SpacesProvider>`

**Space Persistence:**
```dart
// When space switched:
await PreferencesService().setLastSelectedSpaceId(spaceId);

// On app start:
final lastSpaceId = PreferencesService().getLastSelectedSpaceId();
if (lastSpaceId != null) {
  _currentSpace = spaces.firstWhere((s) => s.id == lastSpaceId);
}
```

**Navigation Flow:**
```
App Start
  ↓
SpacesProvider.loadSpaces()
  ↓
Restore last selected space from SharedPreferences
  ↓
ItemsProvider.loadItemsBySpace(currentSpace.id)
  ↓
HomeScreen displays items
```

**Cross-Screen Consistency:**
- All screens see same `currentSpace`
- Switching space triggers rebuild across app
- Provider notifies all listeners on space change

**Compatibility with New Model:**
✅ **Perfect** - Navigation and state management is content-agnostic. New model will work identically.

---

## Industry Analysis

### Microsoft To Do: Groups & Lists

**Architecture:**
```
Group (e.g., "Work", "Personal", "Vacation")
  └── List (e.g., "Project Alpha", "Shopping", "Packing")
      └── Task (individual todo item)
      └── Task
      └── Task
```

**Key Characteristics:**
- **Groups are organizational folders** (like Later's Spaces)
- **Lists are first-class containers** (like Later's proposed TodoLists)
- **Tasks live inside Lists** (like Later's proposed TodoItems)
- Groups cannot be shared (personal organization only)
- Lists can be shared individually
- No aggregated view of all tasks in a group
- Drag-and-drop to organize lists within groups

**Relevant to Later:**
- ✅ Confirms space-as-folder mental model
- ✅ Lists as containers is standard pattern
- ✅ Count top-level containers, not all items
- ⚠️ Consider: Should spaces show aggregated counts?

### Notion: Workspaces & Pages

**Architecture:**
```
Workspace (e.g., "Company Wiki")
  └── Page (can contain multiple block types)
      ├── Text blocks
      ├── Todo lists (as blocks)
      ├── Databases (tables, boards, calendars)
      └── Nested pages
```

**Key Characteristics:**
- **Workspaces contain heterogeneous content**
- **Pages can mix multiple content types**
- **Databases are first-class containers**
- **Flexible nesting** (pages within pages)
- **View modes** (list, table, board, calendar) for databases
- **Rich metadata** (icons, covers, properties)

**Relevant to Later:**
- ✅ Mixed content types in one space = validated approach
- ✅ Different views for different content types
- ✅ Icons per container (not just per space)
- ⚠️ Later keeps it simpler (no infinite nesting)

### Apple Reminders: Lists & Reminders

**Architecture:**
```
Account
  └── List (e.g., "Work", "Groceries", "Travel")
      └── Reminder (todo item)
      └── Reminder
      └── Sub-reminder (optional nesting)
```

**Key Characteristics:**
- **Lists are top-level containers** (no workspace/group layer)
- **Reminders are tasks with optional subtasks**
- **Smart Lists** (Today, Scheduled, All, Flagged) = dynamic views
- **List groups on iOS 17+** for organization
- **Color-coded lists** with icons
- **Shared lists** for collaboration

**Relevant to Later:**
- ✅ Lists as primary containers validated
- ✅ Smart views (Today, etc.) similar to Later's Today view
- ⚠️ Simpler than Later (no space layer)
- ✅ Color + icon per list = good UX pattern

### Todoist: Projects & Tasks

**Architecture:**
```
No explicit workspace layer
  └── Project (e.g., "Product Launch", "Home Renovation")
      └── Section (optional grouping within project)
          └── Task
          └── Task
          └── Sub-task (optional nesting)
```

**Key Characteristics:**
- **Projects are top-level containers** (like Later's Spaces)
- **Sections within projects** for sub-organization
- **Tasks can have subtasks** (1 level deep)
- **Views:** Today, Upcoming, Filters & Labels
- **No workspace layer** (simpler hierarchy)
- **Shared projects** for collaboration

**Relevant to Later:**
- ⚠️ Different: Todoist projects ≈ Later spaces, but no workspace layer
- ✅ Sections could inspire Later's list organization
- ✅ Task → Sub-task = TodoList → TodoItem pattern
- ✅ Multiple views validated (Today, by space, etc.)

### Synthesis: Common Patterns

**Across All Apps:**

1. **Two-Tier Organization:**
   - Top tier: Workspace/Group/Account (organizational)
   - Bottom tier: List/Project/Database (functional containers)

2. **Container-Based Lists:**
   - All major apps use lists/projects as first-class containers
   - Items/tasks live **inside** these containers, not standalone
   - Containers have metadata (name, icon, color, count)

3. **Mixed Content Views:**
   - Notion shows mixed content types in one workspace
   - Later can do the same: TodoLists + Lists + Notes in one Space

4. **Smart/Dynamic Views:**
   - "Today", "Scheduled", "Flagged", etc. cut across containers
   - Later's Today view already implements this pattern
   - Could add: "All Todos", "All Lists", etc.

5. **Item Counts:**
   - Microsoft To Do: Shows list count per group (not task count)
   - Notion: Shows page count in workspace sidebar
   - Apple Reminders: Shows reminder count per list
   - **Industry standard:** Count containers, not sub-items

**Best Practices for Later:**

✅ **Keep Space as organizational layer** (workspace/group equivalent)
✅ **TodoLists and Lists as first-class containers** (validated pattern)
✅ **Count containers, not sub-items** (industry standard)
✅ **Allow mixed content in one space** (Notion validates this)
✅ **Maintain Today/smart views** (cross-container views are valuable)
✅ **Icon + color per container** (enhances visual organization)

---

## Feasibility Analysis

### What Stays the Same

**Space Core Model:**
```dart
class Space {
  String id;              ✅ No change
  String name;            ✅ No change
  String? icon;           ✅ No change
  String? color;          ✅ No change
  int itemCount;          ⚠️ Semantic change only (count containers)
  bool isArchived;        ✅ No change
  DateTime createdAt;     ✅ No change
  DateTime updatedAt;     ✅ No change
}
```

**Space Operations:**
- ✅ `loadSpaces()` - No change
- ✅ `addSpace()` - No change
- ✅ `updateSpace()` - No change
- ✅ `deleteSpace()` - No change
- ✅ `switchSpace()` - No change
- ✅ `archiveSpace()` / `restoreSpace()` - No change

**UI Components:**
- ✅ Space Switcher Modal - No change
- ✅ Create Space Modal - No change
- ✅ Space dropdown in Quick Capture - No change
- ✅ Space icon/name in AppBar - No change

**State Management:**
- ✅ SpacesProvider architecture - No change
- ✅ currentSpace tracking - No change
- ✅ Space persistence to SharedPreferences - No change

**Navigation:**
- ✅ Space switching triggers content reload - Same pattern
- ✅ Space selection in navigation bar - No change

### What Needs to Change

**1. Content Loading Pattern**

**Current:**
```dart
// ItemsProvider
Future<void> loadItemsBySpace(String spaceId) async {
  _items = await _repository.getItemsBySpace(spaceId);
  _currentSpaceId = spaceId;
  notifyListeners();
}
```

**New:**
```dart
// ContentProvider
Future<void> loadSpaceContent(String spaceId) async {
  _todoLists = await _todoListRepo.getBySpace(spaceId);
  _lists = await _listRepo.getBySpace(spaceId);
  _notes = await _noteRepo.getBySpace(spaceId);
  _currentSpaceId = spaceId;
  notifyListeners();
}
```

**Impact:** Medium effort (1-2 days)
- Need to query 3 boxes instead of 1
- Need parallel queries for performance
- Provider API changes slightly

**2. HomeScreen Content Display**

**Current:**
```dart
// Single item type
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemCard(item: items[index]);
  },
)
```

**New:**
```dart
// Mixed content types
ListView.builder(
  itemCount: _calculateTotalItems(content),
  itemBuilder: (context, index) {
    final item = _getContentAtIndex(content, index);
    if (item is TodoList) return TodoListCard(todoList: item);
    if (item is ListModel) return ListCard(list: item);
    if (item is Note) return NoteCard(note: item);
  },
)
```

**Alternative (Simpler):**
```dart
// Separate sections
Column([
  if (todoLists.isNotEmpty)
    _buildTodoListsSection(todoLists),
  if (lists.isNotEmpty)
    _buildListsSection(lists),
  if (notes.isNotEmpty)
    _buildNotesSection(notes),
])
```

**Impact:** High effort (3-5 days)
- Need 3 different card types (TodoListCard, ListCard, NoteCard)
- Need mixed list rendering logic
- Need to update filter chips to filter mixed content
- Need to handle empty states per section

**3. Filter System**

**Current:**
```dart
enum ItemFilter {
  all,      // Show all items
  tasks,    // Show only tasks
  notes,    // Show only notes
  lists,    // Show only lists
}
```

**New:**
```dart
enum ContentFilter {
  all,        // Show all content (TodoLists + Lists + Notes)
  todoLists,  // Show only TodoLists
  lists,      // Show only Lists
  notes,      // Show only Notes
}
```

**Impact:** Low effort (1 day)
- Rename enum
- Update filter logic
- Update filter chip labels

**4. Item Count Management**

**Current:**
```dart
// When item added
await spacesProvider.incrementSpaceItemCount(spaceId);

// When item deleted
await spacesProvider.decrementSpaceItemCount(spaceId);
```

**New:**
```dart
// When TodoList/List/Note added
await spacesProvider.incrementSpaceItemCount(spaceId);

// When TodoList/List/Note deleted
await spacesProvider.decrementSpaceItemCount(spaceId);

// Note: Adding/removing items WITHIN a TodoList/List
// does NOT change space.itemCount
```

**Impact:** Very low (< 1 day)
- Same API, just called from different places
- Need to ensure count tracks containers, not sub-items

**5. Empty State Variations**

**Current:**
```dart
EmptySpaceState(
  message: "No items in this space",
)
```

**New:**
```dart
// Completely empty
EmptySpaceState(
  message: "No content in this space yet",
  hint: "Tap + to create a todo list, list, or note",
)

// Filtered empty (e.g., no todo lists)
FilteredEmptyState(
  filter: ContentFilter.todoLists,
  message: "No todo lists in this space",
  hint: "Try a different filter or create one",
)
```

**Impact:** Low effort (1 day)
- Update empty state component
- Add logic to detect filtered vs. completely empty

### Total Effort Estimate

**Changes Required:**
1. Content loading pattern: **1-2 days**
2. HomeScreen display: **3-5 days**
3. Filter system: **1 day**
4. Item count management: **< 1 day**
5. Empty states: **1 day**

**Total:** **7-10 days** of development work

**Testing Required:**
- Space switching with mixed content: 1 day
- Filter toggling: 1 day
- Item count accuracy: 1 day
- Empty state variations: 1 day
- Integration tests: 2 days

**Total with Testing:** **13-16 days**

### Risk Assessment

**Low Risk Areas:**
- ✅ Space model (no changes)
- ✅ Space operations (no changes)
- ✅ Space switcher UI (no changes)
- ✅ Space creation (no changes)
- ✅ Space persistence (no changes)

**Medium Risk Areas:**
- ⚠️ Content loading (need to query 3 boxes, could have performance implications)
- ⚠️ Filter system (need to ensure all content types handled correctly)
- ⚠️ Empty states (need to handle multiple variations)

**High Risk Areas:**
- 🔴 HomeScreen display logic (complex mixed content rendering)
- 🔴 Item count accuracy (critical for correct space metadata)

**Mitigation Strategies:**

1. **Content Loading Performance:**
   - Use `Future.wait()` to query boxes in parallel
   - Implement caching in ContentProvider
   - Monitor query times with benchmarks

2. **HomeScreen Display:**
   - Build incrementally (TodoLists first, then Lists, then Notes)
   - Create shared base card component
   - Extensive testing with mixed content

3. **Item Count Accuracy:**
   - Implement comprehensive test suite
   - Add debug logging to track count changes
   - Create migration script to recalculate all counts

---

## Recommendations

### 1. Keep Space Architecture As-Is

**Rationale:**
- Space model is **container-agnostic by design**
- Current architecture already supports arbitrary content types
- No fundamental restructuring needed
- Minimizes migration risk

**Action Items:**
- ✅ No changes to Space data model
- ✅ No changes to SpacesProvider
- ✅ No changes to space UI components

### 2. Update Content Loading Pattern

**Implement Unified Content Loading:**

```dart
class ContentProvider extends ChangeNotifier {
  final TodoListRepository _todoListRepo;
  final ListRepository _listRepo;
  final NoteRepository _noteRepo;

  List<TodoList> _todoLists = [];
  List<ListModel> _lists = [];
  List<Note> _notes = [];
  String? _currentSpaceId;

  Future<void> loadSpaceContent(String spaceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load in parallel for performance
      final results = await Future.wait([
        _todoListRepo.getBySpace(spaceId),
        _listRepo.getBySpace(spaceId),
        _noteRepo.getBySpace(spaceId),
      ]);

      _todoLists = results[0];
      _lists = results[1];
      _notes = results[2];
      _currentSpaceId = spaceId;

    } catch (e) {
      _error = AppError.fromException(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filtered accessors
  List<TodoList> getTodoLists(String spaceId) =>
    _todoLists.where((l) => l.spaceId == spaceId).toList();

  List<ListModel> getLists(String spaceId) =>
    _lists.where((l) => l.spaceId == spaceId).toList();

  List<Note> getNotes(String spaceId) =>
    _notes.where((n) => n.spaceId == spaceId).toList();
}
```

**Benefits:**
- Single provider to manage all content types
- Parallel loading for performance
- Clean separation of concerns
- Easy to extend with new content types

### 3. Enhance HomeScreen for Mixed Content

**Option A: Unified List (Recommended for MVP)**

```dart
Widget _buildContentList(SpaceContent content, ContentFilter filter) {
  final filteredContent = _getFilteredContent(content, filter);

  return ListView.builder(
    itemCount: filteredContent.length,
    itemBuilder: (context, index) {
      final item = filteredContent[index];

      return switch (item) {
        TodoList todoList => TodoListCard(
          todoList: todoList,
          onTap: () => _openTodoListDetail(todoList),
        ),
        ListModel list => ListCard(
          list: list,
          onTap: () => _openListDetail(list),
        ),
        Note note => NoteCard(
          note: note,
          onTap: () => _openNoteDetail(note),
        ),
        _ => SizedBox.shrink(),
      };
    },
  );
}
```

**Option B: Sectioned View (Future Enhancement)**

```dart
Widget _buildContentSections(SpaceContent content) {
  return CustomScrollView(
    slivers: [
      // TodoLists section
      if (content.todoLists.isNotEmpty)
        _buildTodoListsSection(content.todoLists),

      // Lists section
      if (content.lists.isNotEmpty)
        _buildListsSection(content.lists),

      // Notes section
      if (content.notes.isNotEmpty)
        _buildNotesSection(content.notes),
    ],
  );
}

Widget _buildTodoListsSection(List<TodoList> todoLists) {
  return SliverToBoxAdapter(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Text('Todo Lists', style: AppTypography.h4),
        ),
        ...todoLists.map((tl) => TodoListCard(todoList: tl)),
      ],
    ),
  );
}
```

**Recommendation:** Start with **Option A** (unified list) for MVP, consider **Option B** (sectioned view) in Phase 2 based on user feedback.

### 4. Adapt Item Count to Container Count

**Implementation:**

```dart
// In Space model
class Space {
  int itemCount; // Now means "container count"

  // Helper to clarify what's being counted
  String get itemCountLabel {
    if (itemCount == 0) return 'Empty';
    if (itemCount == 1) return '1 item';
    return '$itemCount items';
  }
}

// When TodoList created/deleted
await spacesProvider.incrementSpaceItemCount(spaceId);
await spacesProvider.decrementSpaceItemCount(spaceId);

// When List created/deleted
await spacesProvider.incrementSpaceItemCount(spaceId);
await spacesProvider.decrementSpaceItemCount(spaceId);

// When Note created/deleted
await spacesProvider.incrementSpaceItemCount(spaceId);
await spacesProvider.decrementSpaceItemCount(spaceId);

// IMPORTANT: When TodoItem added/removed from TodoList
// → DO NOT change space.itemCount
// → Only the TodoList's internal count changes
```

**Migration Script:**

```dart
Future<void> migrateSpaceItemCounts() async {
  final spaces = Hive.box<Space>('spaces').values;

  for (var space in spaces) {
    final todoListCount = await todoListRepo.countBySpace(space.id);
    final listCount = await listRepo.countBySpace(space.id);
    final noteCount = await noteRepo.countBySpace(space.id);

    final newCount = todoListCount + listCount + noteCount;

    final updatedSpace = space.copyWith(
      itemCount: newCount,
      updatedAt: DateTime.now(),
    );

    await spaceRepo.updateSpace(updatedSpace);
  }
}
```

### 5. Update Filter System

**New Filter Implementation:**

```dart
enum ContentFilter {
  all,        // Show TodoLists + Lists + Notes
  todoLists,  // Show only TodoLists
  lists,      // Show only Lists
  notes,      // Show only Notes
}

extension ContentFilterExtension on ContentFilter {
  String get label {
    switch (this) {
      case ContentFilter.all: return 'All';
      case ContentFilter.todoLists: return 'Todo Lists';
      case ContentFilter.lists: return 'Lists';
      case ContentFilter.notes: return 'Notes';
    }
  }

  IconData get icon {
    switch (this) {
      case ContentFilter.all: return Icons.grid_view;
      case ContentFilter.todoLists: return Icons.check_box_outlined;
      case ContentFilter.lists: return Icons.list;
      case ContentFilter.notes: return Icons.description_outlined;
    }
  }
}

// Filter logic
List<dynamic> _getFilteredContent(SpaceContent content, ContentFilter filter) {
  switch (filter) {
    case ContentFilter.all:
      return [
        ...content.todoLists,
        ...content.lists,
        ...content.notes,
      ];
    case ContentFilter.todoLists:
      return content.todoLists.cast<dynamic>();
    case ContentFilter.lists:
      return content.lists.cast<dynamic>();
    case ContentFilter.notes:
      return content.notes.cast<dynamic>();
  }
}
```

### 6. Enhance Empty States

**Implementation:**

```dart
Widget _buildEmptyState(SpaceContent content, ContentFilter filter) {
  final totalCount = content.todoLists.length +
                     content.lists.length +
                     content.notes.length;

  // Completely empty space
  if (totalCount == 0) {
    return EmptySpaceState(
      icon: Icons.inbox_outlined,
      title: "Nothing here yet",
      message: "Create a todo list, list, or note to get started",
      actionText: "Create content",
      onAction: _showQuickCaptureModal,
    );
  }

  // Filtered empty (space has content, but not of selected type)
  return FilteredEmptyState(
    icon: filter.icon,
    title: "No ${filter.label.toLowerCase()} in this space",
    message: "Try a different filter or create new content",
    actionText: "Clear filter",
    onAction: () => setState(() => _selectedFilter = ContentFilter.all),
  );
}
```

### 7. Performance Optimization

**Query Optimization:**

```dart
class ContentProvider {
  // Cache content by space ID
  final Map<String, SpaceContent> _contentCache = {};

  Future<void> loadSpaceContent(String spaceId) async {
    // Check cache first
    if (_contentCache.containsKey(spaceId)) {
      _setContentFromCache(spaceId);
      notifyListeners();
      // Optionally refresh in background
      _refreshContentInBackground(spaceId);
      return;
    }

    // Load from database if not cached
    await _loadFromDatabase(spaceId);
  }

  Future<void> _refreshContentInBackground(String spaceId) async {
    final freshContent = await _loadFromDatabase(spaceId);
    _contentCache[spaceId] = freshContent;
    notifyListeners();
  }
}
```

**Lazy Loading for Large Spaces:**

```dart
class ContentProvider {
  static const int INITIAL_LOAD_COUNT = 50;

  Future<void> loadSpaceContent(String spaceId) async {
    // Load only first 50 items of each type
    _todoLists = await _todoListRepo.getBySpace(
      spaceId,
      limit: INITIAL_LOAD_COUNT,
    );
    _lists = await _listRepo.getBySpace(
      spaceId,
      limit: INITIAL_LOAD_COUNT,
    );
    _notes = await _noteRepo.getBySpace(
      spaceId,
      limit: INITIAL_LOAD_COUNT,
    );

    notifyListeners();
  }

  Future<void> loadMoreContent() async {
    // Load next batch when user scrolls to bottom
  }
}
```

---

## Implementation Plan

### Phase 1: Core Changes (Week 1-2)

**Tasks:**
1. ✅ Create ContentProvider (replaces ItemsProvider)
2. ✅ Implement parallel content loading
3. ✅ Update HomeScreen to use ContentProvider
4. ✅ Create base card components (TodoListCard, ListCard, NoteCard)
5. ✅ Update filter system to ContentFilter
6. ✅ Update empty states

**Deliverables:**
- HomeScreen displays mixed content (TodoLists + Lists + Notes)
- Filter chips work for all content types
- Space switching loads correct content
- Empty states handle all variations

**Testing:**
- Unit tests for ContentProvider
- Integration tests for space switching
- UI tests for filter toggling
- Performance benchmarks for content loading

### Phase 2: Polish & Optimization (Week 3)

**Tasks:**
1. ✅ Implement content caching
2. ✅ Add lazy loading for large spaces
3. ✅ Optimize query performance
4. ✅ Add loading skeletons
5. ✅ Polish animations and transitions

**Deliverables:**
- Fast space switching (< 100ms perceived)
- Smooth scrolling with mixed content
- Loading states don't flicker
- Animations feel polished

**Testing:**
- Performance testing with 1000+ items
- Memory usage monitoring
- Animation smoothness testing

### Phase 3: Migration & Deployment (Week 4)

**Tasks:**
1. ✅ Write migration script for space.itemCount
2. ✅ Test migration with production-like data
3. ✅ Create rollback plan
4. ✅ Deploy to beta testers
5. ✅ Monitor for issues

**Deliverables:**
- Migration runs successfully on all devices
- Space item counts accurate
- No data loss
- Beta feedback collected

**Testing:**
- Migration testing with various data states
- Rollback testing
- Beta user feedback collection

---

## Success Metrics

### Functional Metrics

**Space Operations:**
- ✅ Space switching works with mixed content (100% success rate)
- ✅ Space creation creates empty space (100% success rate)
- ✅ Space item counts accurate (0 count errors)
- ✅ Filter toggling shows correct content (100% accuracy)

**Performance Metrics:**
- ✅ Space switching perceived delay < 100ms (target)
- ✅ Content loading time < 500ms for 500 items (target)
- ✅ Memory usage increase < 20% vs. old model
- ✅ No UI jank during scrolling (60fps maintained)

### User Experience Metrics

**Usability:**
- ✅ Users understand mixed content view (survey > 80% comprehension)
- ✅ Users can switch spaces easily (< 3 taps)
- ✅ Filter system is intuitive (survey > 90% found it clear)
- ✅ Empty states are helpful (survey > 80% found them clear)

**Satisfaction:**
- ✅ No increase in support tickets about spaces
- ✅ No negative feedback about space handling
- ✅ Users appreciate mixed content view (survey > 70%)

---

## Migration Strategy

### Data Migration

**No migration needed** for Space model itself. Only semantic change:
- `Space.itemCount` now counts containers (TodoLists + Lists + Notes)
- Previously counted flat items (Tasks + Notes + Lists)

**Migration Script:**

```dart
Future<void> migrateItemCountsToContainerCounts() async {
  final spacesBox = Hive.box<Space>('spaces');
  final todoListsBox = Hive.box<TodoList>('todo_lists');
  final listsBox = Hive.box<ListModel>('lists');
  final notesBox = Hive.box<Note>('notes');

  // Backup current space data
  final backup = spacesBox.toMap();
  await Hive.box('spaces_backup').putAll(backup);

  for (var space in spacesBox.values) {
    // Count containers (not sub-items)
    final todoListCount = todoListsBox.values
      .where((tl) => tl.spaceId == space.id)
      .length;

    final listCount = listsBox.values
      .where((l) => l.spaceId == space.id)
      .length;

    final noteCount = notesBox.values
      .where((n) => n.spaceId == space.id)
      .length;

    final newItemCount = todoListCount + listCount + noteCount;

    // Update space
    final updatedSpace = space.copyWith(
      itemCount: newItemCount,
      updatedAt: DateTime.now(),
    );

    await spacesBox.put(space.id, updatedSpace);

    debugPrint(
      'Migrated space ${space.name}: '
      'old count ${space.itemCount} → new count $newItemCount'
    );
  }

  debugPrint('Space migration complete');
}
```

**Migration Timing:**
- Run on app update (before first launch with new model)
- Show progress UI if migration takes > 1 second
- Provide rollback mechanism if migration fails

### UI Migration

**No breaking UI changes.** Space-related UI remains identical:
- Space Switcher Modal - unchanged
- Create Space Modal - unchanged
- Space dropdown in Quick Capture - unchanged
- AppBar space selector - unchanged

**Only change:** HomeScreen content display (internal implementation, not user-facing UI change)

### User Communication

**For Existing Users:**

**In-App Notification (First Launch):**
```
✨ Improved Organization!

Spaces now support Todo Lists, Lists, and Notes.
Your existing items have been organized for you.

Everything is right where you left it!

[Got it]
```

**Help Text:**
```
What's New:
• Todo Lists: Organize related tasks together
• Lists: Create shopping lists, watchlists, and more
• Notes: Capture thoughts and context

Spaces work the same way, now with better organization!
```

---

## Appendix A: Code Examples

### Example 1: ContentProvider with Mixed Content

```dart
class ContentProvider extends ChangeNotifier {
  final TodoListRepository _todoListRepo;
  final ListRepository _listRepo;
  final NoteRepository _noteRepo;

  List<TodoList> _todoLists = [];
  List<ListModel> _lists = [];
  List<Note> _notes = [];
  String? _currentSpaceId;
  bool _isLoading = false;
  AppError? _error;

  // Getters
  List<TodoList> get todoLists => List.unmodifiable(_todoLists);
  List<ListModel> get lists => List.unmodifiable(_lists);
  List<Note> get notes => List.unmodifiable(_notes);
  bool get isLoading => _isLoading;
  AppError? get error => _error;

  // Load all content for a space
  Future<void> loadSpaceContent(String spaceId) async {
    _isLoading = true;
    _error = null;
    _currentSpaceId = spaceId;
    notifyListeners();

    try {
      // Load in parallel for best performance
      final results = await Future.wait([
        _todoListRepo.getBySpace(spaceId),
        _listRepo.getBySpace(spaceId),
        _noteRepo.getBySpace(spaceId),
      ]);

      _todoLists = results[0];
      _lists = results[1];
      _notes = results[2];

      _error = null;
    } catch (e) {
      _error = AppError.fromException(e);
      _todoLists = [];
      _lists = [];
      _notes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add TodoList (and increment space count)
  Future<void> addTodoList(TodoList todoList, SpacesProvider spacesProvider) async {
    try {
      final created = await _todoListRepo.create(todoList);
      _todoLists = [..._todoLists, created];

      // Increment space item count
      await spacesProvider.incrementSpaceItemCount(todoList.spaceId);

      notifyListeners();
    } catch (e) {
      _error = AppError.fromException(e);
      notifyListeners();
    }
  }

  // Delete TodoList (and decrement space count)
  Future<void> deleteTodoList(String id, SpacesProvider spacesProvider) async {
    try {
      final todoList = _todoLists.firstWhere((tl) => tl.id == id);

      await _todoListRepo.delete(id);
      _todoLists = _todoLists.where((tl) => tl.id != id).toList();

      // Decrement space item count
      await spacesProvider.decrementSpaceItemCount(todoList.spaceId);

      notifyListeners();
    } catch (e) {
      _error = AppError.fromException(e);
      notifyListeners();
    }
  }

  // Get filtered content for display
  List<dynamic> getFilteredContent(ContentFilter filter) {
    switch (filter) {
      case ContentFilter.all:
        return [..._todoLists, ..._lists, ..._notes];
      case ContentFilter.todoLists:
        return _todoLists.cast<dynamic>();
      case ContentFilter.lists:
        return _lists.cast<dynamic>();
      case ContentFilter.notes:
        return _notes.cast<dynamic>();
    }
  }

  // Get total content count
  int getTotalCount() {
    return _todoLists.length + _lists.length + _notes.length;
  }
}
```

### Example 2: HomeScreen with Mixed Content

```dart
class _HomeScreenState extends State<HomeScreen> {
  ContentFilter _selectedFilter = ContentFilter.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer2<SpacesProvider, ContentProvider>(
        builder: (context, spacesProvider, contentProvider, child) {
          final currentSpace = spacesProvider.currentSpace;

          // No space selected
          if (currentSpace == null) {
            return WelcomeState();
          }

          // Loading content
          if (contentProvider.isLoading) {
            return _buildLoadingState();
          }

          // Get filtered content
          final filteredContent = contentProvider.getFilteredContent(_selectedFilter);

          // Empty state
          if (filteredContent.isEmpty) {
            return _buildEmptyState(
              contentProvider.getTotalCount() == 0,
              _selectedFilter,
            );
          }

          // Display content
          return Column(
            children: [
              _buildFilterChips(),
              Expanded(
                child: _buildContentList(filteredContent),
              ),
            ],
          );
        },
      ),
      floatingActionButton: QuickCaptureFAB(),
    );
  }

  Widget _buildContentList(List<dynamic> content) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        itemCount: content.length,
        itemBuilder: (context, index) {
          final item = content[index];

          if (item is TodoList) {
            return TodoListCard(
              todoList: item,
              onTap: () => _openTodoListDetail(item),
            );
          } else if (item is ListModel) {
            return ListCard(
              list: item,
              onTap: () => _openListDetail(item),
            );
          } else if (item is Note) {
            return NoteCard(
              note: item,
              onTap: () => _openNoteDetail(item),
            );
          }

          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: ContentFilter.values.map((filter) {
          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.xs),
            child: FilterChip(
              selected: _selectedFilter == filter,
              label: Row(
                children: [
                  Icon(filter.icon, size: 16),
                  SizedBox(width: AppSpacing.xxxs),
                  Text(filter.label),
                ],
              ),
              onSelected: (selected) {
                setState(() => _selectedFilter = filter);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(bool isCompletelyEmpty, ContentFilter filter) {
    if (isCompletelyEmpty) {
      return EmptySpaceState(
        icon: Icons.inbox_outlined,
        title: "Nothing here yet",
        message: "Create a todo list, list, or note to get started",
        actionText: "Create content",
        onAction: _showQuickCaptureModal,
      );
    } else {
      return FilteredEmptyState(
        icon: filter.icon,
        title: "No ${filter.label.toLowerCase()} in this space",
        message: "Try a different filter or create new content",
        actionText: "Clear filter",
        onAction: () => setState(() => _selectedFilter = ContentFilter.all),
      );
    }
  }
}
```

### Example 3: Space Item Count Update

```dart
// In ContentProvider
Future<void> addTodoList(TodoList todoList) async {
  final spacesProvider = context.read<SpacesProvider>();

  try {
    // Create TodoList
    final created = await _todoListRepo.create(todoList);
    _todoLists = [..._todoLists, created];

    // Increment space count (since we added a container)
    await spacesProvider.incrementSpaceItemCount(todoList.spaceId);

    notifyListeners();
  } catch (e) {
    _error = AppError.fromException(e);
    notifyListeners();
  }
}

// When adding TodoItem to existing TodoList
Future<void> addTodoItemToList(String listId, TodoItem item) async {
  try {
    // Find the TodoList
    final todoList = _todoLists.firstWhere((tl) => tl.id == listId);

    // Add item to list
    final updatedList = todoList.copyWith(
      items: [...todoList.items, item],
      updatedAt: DateTime.now(),
    );

    // Update in database
    await _todoListRepo.update(updatedList);

    // Update in memory
    final index = _todoLists.indexWhere((tl) => tl.id == listId);
    _todoLists = [
      ..._todoLists.sublist(0, index),
      updatedList,
      ..._todoLists.sublist(index + 1),
    ];

    // IMPORTANT: Do NOT increment space count
    // (we're adding an item to a container, not a container itself)

    notifyListeners();
  } catch (e) {
    _error = AppError.fromException(e);
    notifyListeners();
  }
}
```

---

## Appendix B: Testing Strategy

### Unit Tests

**SpacesProvider Tests:**
```dart
test('incrementSpaceItemCount increases count by 1', () async {
  final space = Space(id: 's1', name: 'Test', itemCount: 5);
  await spacesProvider.addSpace(space);

  await spacesProvider.incrementSpaceItemCount('s1');

  expect(spacesProvider.spaces.first.itemCount, 6);
});

test('decrementSpaceItemCount decreases count by 1', () async {
  final space = Space(id: 's1', name: 'Test', itemCount: 5);
  await spacesProvider.addSpace(space);

  await spacesProvider.decrementSpaceItemCount('s1');

  expect(spacesProvider.spaces.first.itemCount, 4);
});

test('decrementSpaceItemCount does not go below 0', () async {
  final space = Space(id: 's1', name: 'Test', itemCount: 0);
  await spacesProvider.addSpace(space);

  await spacesProvider.decrementSpaceItemCount('s1');

  expect(spacesProvider.spaces.first.itemCount, 0);
});
```

**ContentProvider Tests:**
```dart
test('loadSpaceContent loads all content types', () async {
  // Setup: Create mixed content
  await seedSpace('s1', todoLists: 2, lists: 3, notes: 1);

  // Execute
  await contentProvider.loadSpaceContent('s1');

  // Verify
  expect(contentProvider.todoLists.length, 2);
  expect(contentProvider.lists.length, 3);
  expect(contentProvider.notes.length, 1);
});

test('getFilteredContent returns only selected type', () async {
  await seedSpace('s1', todoLists: 2, lists: 3, notes: 1);
  await contentProvider.loadSpaceContent('s1');

  final todoListsOnly = contentProvider.getFilteredContent(ContentFilter.todoLists);

  expect(todoListsOnly.length, 2);
  expect(todoListsOnly.every((item) => item is TodoList), true);
});
```

### Integration Tests

**Space Switching with Mixed Content:**
```dart
testWidgets('space switching loads correct content', (tester) async {
  // Setup: Create 2 spaces with different content
  await seedSpace('work', todoLists: 3, lists: 0, notes: 2);
  await seedSpace('home', todoLists: 1, lists: 5, notes: 0);

  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle();

  // Verify initial space (work)
  expect(find.text('work'), findsOneWidget);
  expect(find.byType(TodoListCard), findsNWidgets(3));
  expect(find.byType(NoteCard), findsNWidgets(2));

  // Switch to home space
  await tester.tap(find.text('work'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('home'));
  await tester.pumpAndSettle();

  // Verify new space content
  expect(find.text('home'), findsOneWidget);
  expect(find.byType(TodoListCard), findsNWidgets(1));
  expect(find.byType(ListCard), findsNWidgets(5));
});
```

**Filter Toggle:**
```dart
testWidgets('filter chips show correct content', (tester) async {
  await seedSpace('s1', todoLists: 2, lists: 3, notes: 1);
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle();

  // Initial state: All content visible
  expect(find.byType(TodoListCard), findsNWidgets(2));
  expect(find.byType(ListCard), findsNWidgets(3));
  expect(find.byType(NoteCard), findsNWidgets(1));

  // Toggle to TodoLists only
  await tester.tap(find.text('Todo Lists'));
  await tester.pumpAndSettle();

  expect(find.byType(TodoListCard), findsNWidgets(2));
  expect(find.byType(ListCard), findsNothing);
  expect(find.byType(NoteCard), findsNothing);
});
```

### Performance Tests

**Content Loading Speed:**
```dart
test('loadSpaceContent completes in < 500ms for 500 items', () async {
  await seedSpace('s1', todoLists: 200, lists: 200, notes: 100);

  final stopwatch = Stopwatch()..start();
  await contentProvider.loadSpaceContent('s1');
  stopwatch.stop();

  expect(stopwatch.elapsedMilliseconds, lessThan(500));
});

test('parallel loading faster than sequential', () async {
  await seedSpace('s1', todoLists: 100, lists: 100, notes: 100);

  // Sequential loading
  final seqStopwatch = Stopwatch()..start();
  await _todoListRepo.getBySpace('s1');
  await _listRepo.getBySpace('s1');
  await _noteRepo.getBySpace('s1');
  seqStopwatch.stop();

  // Parallel loading
  final parStopwatch = Stopwatch()..start();
  await Future.wait([
    _todoListRepo.getBySpace('s1'),
    _listRepo.getBySpace('s1'),
    _noteRepo.getBySpace('s1'),
  ]);
  parStopwatch.stop();

  expect(
    parStopwatch.elapsedMilliseconds,
    lessThan(seqStopwatch.elapsedMilliseconds),
  );
});
```

---

## References

### Code Files Analyzed
- `/apps/later_mobile/lib/data/models/space_model.dart` - Space data model
- `/apps/later_mobile/lib/providers/spaces_provider.dart` - Space state management
- `/apps/later_mobile/lib/widgets/modals/space_switcher_modal.dart` - Space selection UI
- `/apps/later_mobile/lib/widgets/modals/create_space_modal.dart` - Space creation UI
- `/apps/later_mobile/lib/widgets/modals/quick_capture_modal.dart` - Quick capture with space selection
- `/apps/later_mobile/lib/widgets/screens/home_screen.dart` - Space detail view
- `/apps/later_mobile/lib/providers/items_provider.dart` - Current item management
- `/apps/later_mobile/lib/data/repositories/item_repository.dart` - Current data access

### Industry Research
- Microsoft To Do: Groups & Lists architecture
- Notion: Workspaces with mixed content types
- Apple Reminders: Lists and smart views
- Todoist: Projects and tasks organization

### Related Research Documents
- `/Users/jonascurth/later/.claude/research/product-concept-analysis.md` - New data model requirements
- Product concept document - TodoList/List/Note architecture

---

*Research Document Version: 1.0*
*Created: October 24, 2025*
*Researcher: Claude Code*
*Status: Complete - Ready for Implementation*
