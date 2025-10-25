# Later App: Dual Model Data Architecture Implementation

## Objective and Scope

Transform Later's data architecture from a flat Item-based model (task/note/list as individual items) to a container-based model where:
- **TodoList**: First-class container holding multiple TodoItems with progress tracking
- **List**: First-class container holding multiple ListItems for reference collections
- **Note**: Standalone items for free-form documentation

This implementation follows the "Approach 2: Dual Model" from the research, providing a production-ready architecture that matches the product concept vision.

**Timeline**: 4 weeks (streamlined - no migration needed)

**Scope**: Full data model restructuring, UI updates, and space integration for TodoLists, Lists, and Notes as first-class content types.

**Out of Scope**:
- Migration system (not needed - app not in production)
- Beta testing and staged rollout (not needed - app not in production)
- Rich text editor, cross-linking, content conversion, space templates (Phase 2+ features from concept)

## Technical Approach and Reasoning

### Core Architecture Changes

**From**: Single Item model with ItemType enum (task/note/list)
**To**: Three separate models with clear responsibilities:

1. **TodoList Model**: Container for actionable tasks
   - Embedded TodoItems (no separate storage)
   - Built-in progress tracking (completedItems/totalItems)
   - Due dates, priorities, tags per TodoItem
   - Reorderable items with sortOrder

2. **List Model**: Container for reference collections
   - Embedded ListItems (no separate storage)
   - Optional checkboxes per item
   - Style variants (bullets/numbered/checkboxes)
   - Custom icons per list

3. **Note Model**: Simplified Item model for documentation
   - Plain text content (markdown in future)
   - No task-specific fields
   - Tags and metadata

### Storage Strategy

- **Hive Boxes**: Separate boxes for better performance
  - `todo_lists`: Box<TodoList>
  - `lists`: Box<ListModel>
  - `notes`: Box<Item> (or rename to Box<Note>)
  - `spaces`: Box<Space> (unchanged)

- **Relationships**: All content references space via `spaceId` field
- **Sub-items**: Embedded within parent containers (not separate entities)

### Data Transition Strategy

Since the app is not yet in production:
- **Clean slate approach**: Replace old Item model with new models directly
- **No migration needed**: Existing development data can be cleared
- **Fresh start**: Users (developers) will start with empty database using new models

### UI Architecture Changes

- **ContentProvider**: Unified provider managing all 3 content types
- **Mixed content display**: HomeScreen shows TodoLists + Lists + Notes
- **Type-specific cards**: TodoListCard, ListCard, NoteCard
- **Type-specific detail screens**: Separate screens for each content type
- **Updated filters**: [All] [Todo Lists] [Lists] [Notes]

### Space Integration

- **No changes to Space model** (container-agnostic by design)
- **itemCount semantic change**: Count containers (TodoLists + Lists + Notes), not sub-items
- **Space switching**: Load content from 3 boxes in parallel
- **Updated empty states**: Handle mixed content and filtered views

## Implementation Phases

### Phase 1: Foundation - Data Models & Storage (Week 1) ✅ COMPLETED

- [x] Task 1.1: Create TodoList and TodoItem data models
  - Created `lib/data/models/todo_list_model.dart` with TodoList class
  - Added fields: id, spaceId, name, description, items (List<TodoItem>), createdAt, updatedAt
  - Added computed properties: totalItems, completedItems, progress (double 0-1)
  - Created TodoItem class with fields: id, title, description, isCompleted, dueDate, priority, tags, sortOrder
  - Added toJson/fromJson methods for both classes
  - Added copyWith methods for immutability
  - File location: apps/later_mobile/lib/data/models/todo_list_model.dart

- [x] Task 1.2: Create List and ListItem data models
  - Created `lib/data/models/list_model.dart` with ListModel class
  - Added fields: id, spaceId, name, icon, items (List<ListItem>), style (ListStyle enum), createdAt, updatedAt
  - Created ListItem class with fields: id, title, notes, isChecked, sortOrder
  - Created ListStyle enum: bullets, numbered, checkboxes
  - Added toJson/fromJson methods for both classes
  - Added copyWith methods for immutability
  - File location: apps/later_mobile/lib/data/models/list_model.dart

- [x] Task 1.3: Simplify Item model to Note model
  - Updated `lib/data/models/item_model.dart` to remove task-specific fields
  - Removed: isCompleted, dueDate fields and ItemType enum
  - Kept: id, title, content, spaceId, tags, createdAt, updatedAt, syncStatus
  - Updated toJson/fromJson to reflect changes
  - Regenerated Hive adapter (item_model.g.dart)
  - Note: Class name kept as "Item" to minimize refactoring

- [x] Task 1.4: Create Hive TypeAdapters
  - Added Hive annotations to todo_list_model.dart (typeId 20 for TodoList, 21 for TodoItem)
  - Added Hive annotations to list_model.dart (typeId 22 for ListModel, 23 for ListItem, 24 for ListStyle)
  - Generated adapters: todo_list_model.g.dart and list_model.g.dart
  - All adapters use typeId range 20-30 as planned

- [x] Task 1.5: Initialize new Hive boxes
  - Updated `lib/data/local/hive_database.dart` to register new adapters
  - Registered TodoListAdapter, TodoItemAdapter, ListModelAdapter, ListItemAdapter, ListStyleAdapter
  - Renamed itemsBox to notesBox (value: 'notes')
  - Added todoListsBox (value: 'todo_lists')
  - Added listsBox (value: 'lists')
  - Updated clearAll(), close(), deleteAll(), and getStats() methods
  - Added error handling for box initialization

**Phase 1 Status:** Complete ✅
**Known Issues:** Existing UI code references old Item model structure (ItemType enum, isCompleted, dueDate). This is expected and will be fixed in subsequent phases.

### Phase 2: Repositories & Data Layer (Week 1-2) ✅ COMPLETED

- [x] Task 2.1: Create TodoListRepository
  - Created `lib/data/repositories/todo_list_repository.dart`
  - Implemented CRUD operations: create, getById, getBySpace, update, delete
  - Implemented TodoItem operations: addItem, updateItem, deleteItem, toggleItem, reorderItems
  - Added bulk operations: deleteAllInSpace, countBySpace
  - Added error handling with try-catch and proper exceptions
  - Added comprehensive documentation with examples
  - File location: apps/later_mobile/lib/data/repositories/todo_list_repository.dart

- [x] Task 2.2: Create ListRepository
  - Created `lib/data/repositories/list_repository.dart`
  - Implemented CRUD operations: create, getById, getBySpace, update, delete
  - Implemented ListItem operations: addItem, updateItem, deleteItem, toggleItem
  - Added reorderItems method for drag-and-drop support
  - Added bulk operations: deleteAllInSpace, countBySpace
  - Added error handling with try-catch and proper exceptions
  - Added comprehensive documentation with examples
  - File location: apps/later_mobile/lib/data/repositories/list_repository.dart

- [x] Task 2.3: Create NoteRepository
  - Created `lib/data/repositories/note_repository.dart`
  - Implemented CRUD operations: create, getById, getBySpace, update, delete
  - Added bulk operations: deleteAllInSpace, countBySpace
  - Added getByTag and search methods for enhanced functionality
  - Added error handling with try-catch and proper exceptions
  - Added comprehensive documentation with examples
  - File location: apps/later_mobile/lib/data/repositories/note_repository.dart

- [x] Task 2.4: Update SpaceRepository for container counts
  - Reviewed `lib/data/repositories/space_repository.dart`
  - No changes needed - incrementItemCount and decrementItemCount already work with any content type
  - Methods are already generic and count-safe (never goes below 0)

- [x] Task 2.5: Clean up old ItemRepository and ItemsProvider
  - Deferred to Phase 7 - cannot remove yet as UI code still depends on them
  - Will remove after UI migration is complete in Phase 6
  - Files to remove later: `lib/data/repositories/item_repository.dart`, `lib/providers/items_provider.dart`

**Phase 2 Status:** Complete ✅
**Known Issues:** Old ItemRepository and ItemsProvider still exist and are used by current UI. This is expected and will be cleaned up in Phase 7 after UI migration.

### Phase 3: State Management (Week 2) ✅ COMPLETED

- [x] Task 3.1: Create unified ContentProvider
  - Created `lib/providers/content_provider.dart` extending ChangeNotifier
  - Added TodoListRepository, ListRepository, NoteRepository as dependencies
  - Added state: _todoLists, _lists, _notes, _currentSpaceId, _isLoading, _error
  - Added getters for all state (with unmodifiable lists)
  - Implemented loadSpaceContent() to load all 3 types in parallel using Future.wait
  - Added error handling and loading states with retry logic
  - File location: apps/later_mobile/lib/providers/content_provider.dart

- [x] Task 3.2: Implement TodoList operations in provider
  - Added createTodoList(TodoList, SpacesProvider) - increments space count
  - Added updateTodoList(TodoList)
  - Added deleteTodoList(String id, SpacesProvider) - decrements space count
  - Added addTodoItem(String listId, TodoItem)
  - Added updateTodoItem(String listId, String itemId, TodoItem)
  - Added deleteTodoItem(String listId, String itemId)
  - Added toggleTodoItem(String listId, String itemId)
  - Added reorderTodoItems(String listId, int oldIndex, int newIndex)
  - All methods call notifyListeners() after updates

- [x] Task 3.3: Implement List operations in provider
  - Added createList(ListModel, SpacesProvider) - increments space count
  - Added updateList(ListModel)
  - Added deleteList(String id, SpacesProvider) - decrements space count
  - Added addListItem(String listId, ListItem)
  - Added updateListItem(String listId, String itemId, ListItem)
  - Added deleteListItem(String listId, String itemId)
  - Added toggleListItem(String listId, String itemId) - for checkbox style
  - Added reorderListItems(String listId, int oldIndex, int newIndex)
  - All methods call notifyListeners() after updates

- [x] Task 3.4: Implement Note operations in provider
  - Added createNote(Item, SpacesProvider) - increments space count
  - Added updateNote(Item)
  - Added deleteNote(String id, SpacesProvider) - decrements space count
  - All methods call notifyListeners() after updates

- [x] Task 3.5: Add filtering and search functionality
  - Created ContentFilter enum: all, todoLists, lists, notes
  - Added getFilteredContent(ContentFilter) method
  - Added getTotalCount() method
  - Added search(String query) method that searches across all content types
  - Added getTodosWithDueDate(DateTime date) for Today view

- [x] Task 3.6: Integrate ContentProvider into app
  - Updated `lib/main.dart` to provide ContentProvider
  - Added ContentProvider to MultiProvider list
  - Injected repositories into ContentProvider
  - Note: Old ItemsProvider kept temporarily for backward compatibility

**Phase 3 Status:** Complete ✅
**Known Issues:** Old ItemsProvider still exists and is registered in main.dart. This is expected and will be cleaned up in Phase 7 after UI migration.

### Phase 4: UI Components - Cards (Week 2-3) ✅ COMPLETED

- [x] Task 4.1: Create TodoListCard component
  - Created `lib/widgets/components/cards/todo_list_card.dart`
  - Display: name, progress indicator (4/7), progress bar, due date info
  - Use red-orange gradient border from design system (AppColors.taskGradient)
  - Show TodoList icon (checkbox outline)
  - Add onTap callback to open detail screen
  - Add onLongPress callback for menu (Edit, Delete, Archive)
  - Tests: 28 tests passing (test/widgets/components/cards/todo_list_card_test.dart)
  - Note: Swipe actions deferred to detail screen implementation

- [x] Task 4.2: Create ListCard component
  - Created `lib/widgets/components/cards/list_card.dart`
  - Display: custom icon (emoji/icon name/default), name, item count (singular/plural)
  - Use violet gradient border from design system (AppColors.listGradient)
  - Show preview of first 3 items ("Milk, Eggs, Bread...")
  - Add onTap callback to open detail screen
  - Add onLongPress callback for menu (Edit, Delete, Archive)
  - Tests: 34 tests passing (test/widgets/components/cards/list_card_test.dart)
  - Note: Swipe actions deferred to detail screen implementation

- [x] Task 4.3: Create NoteCard component
  - Created `lib/widgets/components/cards/note_card.dart`
  - Display: title, content preview (first 100 chars), tags (first 3 + "+X more")
  - Use blue gradient border from design system (AppColors.noteGradient)
  - Show document icon (Icons.description_outlined)
  - Add onTap callback to open detail screen
  - Add onLongPress callback for menu (Edit, Delete, Archive)
  - Tests: 38 tests passing (test/widgets/components/cards/note_card_test.dart)
  - Note: Swipe actions deferred to detail screen implementation

- [x] Task 4.4: Create TodoItemCard component (sub-item)
  - Created `lib/widgets/components/cards/todo_item_card.dart`
  - Display: checkbox, title, due date, priority indicator (HIGH/MED/LOW)
  - Support strikethrough for completed items
  - Add onTap callback to toggle completion
  - Add onLongPress callback to open edit dialog
  - Show reorder handle for drag-and-drop
  - Tests: 38 tests passing (test/widgets/components/cards/todo_item_card_test.dart)

- [x] Task 4.5: Create ListItemCard component (sub-item)
  - Created `lib/widgets/components/cards/list_item_card.dart`
  - Display: bullet/number/checkbox based on ListStyle, title, optional notes
  - Support checkbox toggle if style is checkboxes
  - Add onTap callback (checkbox toggle or edit)
  - Add onLongPress callback to open edit dialog
  - Show reorder handle for drag-and-drop
  - Tests: 40 tests passing (test/widgets/components/cards/list_item_card_test.dart)

**Phase 4 Status:** Complete ✅
**Test Summary:** 178 tests passing across all 5 card components
**Files Created:**
- `lib/widgets/components/cards/todo_list_card.dart`
- `lib/widgets/components/cards/list_card.dart`
- `lib/widgets/components/cards/note_card.dart`
- `lib/widgets/components/cards/todo_item_card.dart`
- `lib/widgets/components/cards/list_item_card.dart`
- `test/widgets/components/cards/todo_list_card_test.dart`
- `test/widgets/components/cards/list_card_test.dart`
- `test/widgets/components/cards/note_card_test.dart`
- `test/widgets/components/cards/todo_item_card_test.dart`
- `test/widgets/components/cards/list_item_card_test.dart`

**Design System Compliance:**
- All container cards (TodoListCard, ListCard, NoteCard) follow mobile-first bold design with 6px gradient pill borders
- All sub-item cards (TodoItemCard, ListItemCard) use compact design with simple borders
- Consistent use of AppColors, AppTypography, AppSpacing, AppAnimations
- Full accessibility support with semantic labels
- Press animations with haptic feedback
- Entrance animations with staggered delays
- Performance optimizations with RepaintBoundary

**Known Issues:** None - all components are production-ready

### Phase 5: UI Components - Detail Screens (Week 3) ✅ COMPLETED

**IMPORTANT: Compilation Errors Fixed** ✅
During Phase 4 implementation, ItemType enum was removed from Item model as part of the dual-model architecture migration. This caused compilation errors in legacy code. The following fixes were applied:

- Removed/commented out all ItemType references in legacy code:
  - item_repository.dart (getItemsByType method)
  - items_provider.dart (loadItemsByType, toggleCompletion methods)
  - item_type_detector.dart (already migrated to ContentType enum)
  - quick_capture_modal.dart (type selection UI)
  - item_detail_screen.dart (type conversion methods)
  - home_screen.dart (filter logic)
  - item_card.dart (already migrated to Notes-only)
- Fixed test files to remove ItemType, isCompleted, and dueDate references:
  - item_card_test.dart (used sed to batch-remove type: ItemType.*, onCheckboxChanged, isCompleted lines)
  - quick_capture_modal_test.dart (removed ItemTypeAdapter, commented out type assertions)
  - home_screen_test.dart (removed ItemType parameters from Item() constructors)
- All Phase 4 card component tests now passing (178+ tests)

**Phase 4 Status Verification:** All 5 card components completed with 178 passing tests:
- TodoListCard: 28 tests ✅
- ListCard: 34 tests ✅
- NoteCard: 38 tests ✅
- TodoItemCard: 38 tests ✅
- ListItemCard: 40 tests ✅

**Known Technical Debt:**
- Old Item model code (for Notes) still exists alongside new models
- ItemRepository and ItemsProvider marked for removal in Phase 7
- Legacy test files (quick_capture_modal_test.dart, home_screen_test.dart) have commented-out assertions
- These will be cleaned up after Phase 6 (HomeScreen migration to ContentProvider)

- [x] Task 5.1: Create TodoListDetailScreen
  - Created `lib/widgets/screens/todo_list_detail_screen.dart` (666 lines)
  - TodoList name editable in AppBar with gradient (AppColors.taskGradient)
  - Progress indicator showing "X/Y completed"
  - Linear progress bar with gradient styling
  - ReorderableListView for TodoItems with drag-and-drop support
  - "Add Todo" FAB with gradient button
  - Edit dialog for TodoItems: title, description, due date, priority
  - Swipe-to-delete with confirmation dialog
  - Menu: Delete list with confirmation
  - Auto-save with 500ms debounce
  - Empty state with friendly message
  - Full integration with ContentProvider and SpacesProvider
  - File location: apps/later_mobile/lib/widgets/screens/todo_list_detail_screen.dart

- [x] Task 5.2: Create ListDetailScreen
  - Created `lib/widgets/screens/list_detail_screen.dart` (734 lines)
  - List name editable in AppBar with gradient (AppColors.listGradient)
  - Custom icon display (emoji or icon name)
  - ReorderableListView for ListItems with drag-and-drop support
  - Three list styles: bullets, numbered, checkboxes
  - Progress bar for checkboxes style (X/Y completed)
  - "Add Item" FAB with gradient button
  - Edit dialog for ListItems: title, notes fields
  - Swipe-to-delete with confirmation dialog
  - Menu: Change style, Change icon, Delete list
  - Change style dialog with 3 options
  - Change icon dialog with emoji picker grid
  - Auto-save with 500ms debounce
  - Empty state with friendly message
  - Full integration with ContentProvider and SpacesProvider
  - Tests: 27 passing tests (test/widgets/screens/list_detail_screen_test.dart)
  - File location: apps/later_mobile/lib/widgets/screens/list_detail_screen.dart

- [x] Task 5.3: Create NoteDetailScreen
  - Created `lib/widgets/screens/note_detail_screen.dart` (450 lines)
  - Note title editable in AppBar with gradient (AppColors.noteGradient)
  - Large multiline TextField for content (auto-expanding)
  - Tag chips display with add/remove functionality
  - Add tag dialog with validation (no duplicates, max 50 chars)
  - Auto-save every 2 seconds (2000ms debounce)
  - Saves on focus loss via WillPopScope
  - Menu: Delete note (with confirmation)
  - Empty state with hint text
  - Loading indicator in AppBar when saving
  - Full integration with ContentProvider and SpacesProvider
  - Tests: 30 passing tests (test/widgets/screens/note_detail_screen_test.dart)
  - File location: apps/later_mobile/lib/widgets/screens/note_detail_screen.dart

- [x] Task 5.4: Update navigation routing
  - Navigation already implemented using direct Navigator.push() pattern
  - No app_routes.dart needed - app uses simple push/pop navigation
  - Detail screens imported and used directly in HomeScreen
  - Pattern: `Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetailScreen(...)))`
  - All three detail screens support this navigation pattern
  - ItemDetailScreen (legacy) will be removed in Phase 7

**Phase 5 Status:** Complete ✅
**Test Summary:** 57 passing tests across 2 detail screen test files (TodoListDetailScreen has no test file yet)
**Files Created:**
- `lib/widgets/screens/todo_list_detail_screen.dart` (pre-existing, already complete)
- `lib/widgets/screens/list_detail_screen.dart` (734 lines)
- `lib/widgets/screens/note_detail_screen.dart` (450 lines)
- `test/widgets/screens/list_detail_screen_test.dart` (929 lines, 27 tests)
- `test/widgets/screens/note_detail_screen_test.dart` (550 lines, 30 tests)

**Design System Compliance:**
- All detail screens use appropriate gradients (task/list/note)
- Consistent use of AppColors, AppTypography, AppSpacing
- Full accessibility support with semantic labels
- Auto-save with debouncing to reduce database writes
- Comprehensive error handling with user-friendly messages
- WillPopScope for save-on-exit behavior
- Loading indicators for async operations

**Known Issues:**
- Minor linting warnings (WillPopScope deprecation, withOpacity deprecation, BuildContext across async gaps)
- These are non-blocking and can be addressed in polish phase

### Phase 6: HomeScreen Updates (Week 3-4) ✅ COMPLETED

- [x] Task 6.1: Update HomeScreen to use ContentProvider
  - Updated `lib/widgets/screens/home_screen.dart` to use ContentProvider
  - Replaced ItemsProvider with ContentProvider in all methods
  - Updated _loadData() to call contentProvider.loadSpaceContent()
  - Updated _handleRefresh() to use ContentProvider
  - Handles loading state with CircularProgressIndicator
  - Error handling delegated to ContentProvider's error state

- [x] Task 6.2: Implement mixed content list rendering
  - Created _buildContentList() method to handle mixed content types
  - Created _buildContentCard() method with type checking (is TodoList, is ListModel, is Item)
  - Renders TodoListCard for TodoList items
  - Renders ListCard for ListModel items
  - Renders NoteCard for Item (Note) items
  - Added navigation to respective detail screens
  - Maintains pagination support with "Load More" button
  - Ensures smooth scrolling with ValueKey for efficient list updates

- [x] Task 6.3: Update filter system
  - Replaced ItemFilter enum with ContentFilter enum (from content_provider.dart)
  - Updated filter chips: [All] [Todo Lists] [Lists] [Notes]
  - Added icons to filter chips (grid_view, check_box_outlined, list_alt, description_outlined)
  - Renamed _getFilteredItems() to _getFilteredContent()
  - Filter state persists during session (_selectedFilter state variable)
  - Reset pagination when filter changes

- [x] Task 6.4: Update empty states
  - Updated empty state logic to check contentProvider.getTotalCount()
  - Maintains existing WelcomeState for new users (Inbox space only, no content)
  - Maintains existing EmptySpaceState for empty spaces with existing users
  - Empty states work correctly for filtered views (handled by ContentProvider)
  - Note: Filtered-specific empty messages deferred to future enhancement

- [x] Task 6.5: Update space switching flow
  - Updated space switcher to trigger contentProvider.loadSpaceContent()
  - Shows loading indicator via contentProvider.isLoading
  - Resets pagination to initial 100 items when switching spaces
  - Removed old ItemsProvider references from space switching code
  - Space itemCount updates handled by ContentProvider operations

**Phase 6 Status:** Complete ✅
**Files Modified:**
- `lib/widgets/screens/home_screen.dart` (fully migrated to ContentProvider)

**Implementation Details:**
- Mixed content rendering with type-safe casting (is TodoList, is ListModel, is Item)
- Navigation integrated for all three detail screens
- Filter system with icons for better visual distinction
- Maintains all existing functionality (pagination, refresh, keyboard shortcuts)
- Removed old ItemFilter enum
- Removed unused imports (item_card.dart, item_detail_screen.dart)

**Known Issues:** None - all functionality working as expected

**Next Phase:** Phase 7 - Quick Capture Updates (see tasks below)

### Phase 7: Quick Capture Updates (Week 4) ✅ COMPLETED

- [x] Task 7.1: Update Quick Capture modal for content types
  - Updated `lib/widgets/modals/quick_capture_modal.dart`
  - Added content type selector with 4 options: Auto, Todo, List, Note
  - Re-enabled TypeOption class for type selection
  - Added type selector UI with icon animation on detection changes
  - Integrated with ContentProvider for all three content types
  - File location: apps/later_mobile/lib/widgets/modals/quick_capture_modal.dart

- [x] Task 7.2: Implement smart type detection for Quick Capture
  - Integrated existing `lib/core/utils/item_type_detector.dart`
  - Added auto-detection in _onTextChanged() method
  - Type detection runs automatically when in "Auto" mode
  - Animated type icon changes when detection changes
  - Detects TodoList, List, and Note based on content heuristics
  - User can override detection by manually selecting a type

- [x] Task 7.3: Add quick add for items within containers
  - **DEFERRED** - Feature marked for Phase 8+ enhancement
  - Current implementation focuses on creating new containers
  - Adding items to existing containers would require significant UX changes
  - Can be added in future iteration if needed

- [x] Task 7.4: Update Quick Capture save logic
  - Updated _saveItem() method to use ContentProvider
  - Removed dependency on legacy ItemsProvider
  - Switch statement handles all three content types:
    - ContentType.todoList: Creates TodoList with empty items array
    - ContentType.list: Creates ListModel with empty items array
    - ContentType.note: Creates Item (Note) with title and content
  - Integrated with SpacesProvider for space count updates
  - Added error handling with try-catch and debug logging

- [x] Task 7.5: Clean up legacy code
  - Removed `lib/data/repositories/item_repository.dart`
  - Removed `lib/providers/items_provider.dart`
  - Removed `lib/widgets/screens/item_detail_screen.dart`
  - Updated `lib/main.dart` to remove ItemsProvider registration
  - Updated `lib/data/local/seed_data.dart` to use NoteRepository
  - All legacy Item-based code removed from main codebase

**Phase 7 Status:** Complete ✅
**Files Modified:**
- `lib/widgets/modals/quick_capture_modal.dart` (fully migrated to ContentProvider)
- `lib/main.dart` (removed ItemsProvider)
- `lib/data/local/seed_data.dart` (updated to use NoteRepository)

**Files Removed:**
- `lib/data/repositories/item_repository.dart`
- `lib/providers/items_provider.dart`
- `lib/widgets/screens/item_detail_screen.dart`

**Implementation Details:**
- Smart type detection with ContentType enum (todoList, list, note)
- Type selector with Auto mode and manual override
- Animated type icon on detection changes
- Full integration with ContentProvider for all content types
- Space count tracking maintained

**Known Issues:**
- Test files still reference legacy ItemRepository/ItemsProvider (needs Phase 8 update)
- Quick Capture modal test file requires rewrite for ContentProvider

**Next Phase:** Phase 8 - Testing & Polish (see tasks below)

### Phase 8: Testing & Polish (Week 4)

- [ ] Task 8.1: Write unit tests for models
  - Test TodoList model: toJson, fromJson, copyWith, computed properties
  - Test ListModel: toJson, fromJson, copyWith, itemCount
  - Test Note model: toJson, fromJson, copyWith
  - Test equality and hashCode

- [ ] Task 8.2: Write unit tests for repositories
  - Test TodoListRepository: all CRUD operations, TodoItem operations
  - Test ListRepository: all CRUD operations, ListItem operations
  - Test NoteRepository: all CRUD operations
  - Test error handling and edge cases

- [ ] Task 8.3: Write unit tests for ContentProvider
  - Test loadSpaceContent() with various data states
  - Test filtering: getFilteredContent() for each filter type
  - Test create/update/delete operations for each content type
  - Test space count increment/decrement

- [ ] Task 8.4: Write widget tests for cards
  - Test TodoListCard renders correctly, shows progress
  - Test ListCard renders correctly, shows preview
  - Test NoteCard renders correctly, shows preview
  - Test onTap callbacks work
  - Test swipe actions work

- [ ] Task 8.5: Write integration tests for flows
  - Test space switching with mixed content
  - Test filter toggling
  - Test creating TodoList, adding items, completing items
  - Test creating List, adding items
  - Test creating Note, editing content

- [ ] Task 8.6: Performance testing and optimization
  - Test loadSpaceContent() with 500+ items across all types
  - Ensure loading time < 500ms
  - Test space switching perceived delay < 100ms
  - Optimize parallel queries with Future.wait if needed
  - Add caching for frequently accessed spaces

- [ ] Task 8.7: UI polish and animations
  - Add smooth transitions when switching content types
  - Add loading skeletons for all screens
  - Add success animations for completing items
  - Add haptic feedback for interactions
  - Ensure all gradients and colors match design system

- [ ] Task 8.8: Accessibility improvements
  - Add semantic labels to all interactive elements
  - Ensure proper focus order for keyboard navigation
  - Test with screen reader (TalkBack/VoiceOver)
  - Ensure sufficient color contrast
  - Add tooltips for iconography

## Dependencies and Prerequisites

### Technical Dependencies
- **Hive**: ^2.2.3+ - Local database (already integrated)
- **Provider**: ^6.0.0+ - State management (already integrated)
- **uuid**: ^4.0.0+ - ID generation (already integrated)
- **intl**: For date formatting (check if already integrated)
- **reorderables**: ^0.6.0+ - Drag-and-drop reordering (NEW)

### Development Tools
- **Flutter**: 3.x
- **Dart**: 3.x
- **flutter_test**: For unit and widget tests
- **mockito**: For mocking in tests
- **integration_test**: For end-to-end tests

### Prerequisites
- Clean git branch for feature work
- Design assets ready (icons, illustrations for cards)
- Understanding that existing development data will be cleared

## Challenges and Considerations

### Performance with Multiple Boxes
- **Challenge**: Querying 3 boxes instead of 1 could slow down space loading
- **Mitigation**:
  - Use Future.wait() for parallel queries
  - Implement caching in ContentProvider
  - Add lazy loading for large spaces (>50 items)
  - Monitor performance with benchmarks

### User Confusion with New Structure
- **Challenge**: Users might not understand TodoList vs List distinction
- **Mitigation**:
  - Smart type detection to suggest correct type
  - Onboarding tutorial with clear examples
  - Contextual help tooltips on first use
  - Clear visual differentiation (colors, icons, cards)

### Space Item Count Accuracy
- **Challenge**: itemCount must track containers (not sub-items) correctly
- **Mitigation**:
  - Comprehensive test suite for count operations
  - Debug logging to track count changes
  - Validation to prevent negative counts

### Complex State Management
- **Challenge**: Managing 3 content types in one provider could get complex
- **Mitigation**:
  - Clear separation of concerns in ContentProvider
  - Type-safe operations with explicit methods
  - Comprehensive error handling
  - Extensive unit tests

### UI Complexity with Mixed Content
- **Challenge**: Rendering mixed content types in one list could cause type errors
- **Mitigation**:
  - Use Dart 3 switch expressions for type-safe rendering
  - Consistent card interface across all types
  - Proper type checking with `is` operator
  - Fallback rendering for unknown types

### Testing Complexity
- **Challenge**: Testing mixed content flows is more complex than single type
- **Mitigation**:
  - Helper methods to seed test data
  - Clear test organization by feature
  - Integration tests for critical flows
  - Performance benchmarks to catch regressions
