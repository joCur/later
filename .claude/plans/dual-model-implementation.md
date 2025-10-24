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

### Phase 3: State Management (Week 2)

- [ ] Task 3.1: Create unified ContentProvider
  - Create `lib/providers/content_provider.dart` extending ChangeNotifier
  - Add TodoListRepository, ListRepository, NoteRepository as dependencies
  - Add state: _todoLists, _lists, _notes, _currentSpaceId, _isLoading, _error
  - Add getters for all state (with unmodifiable lists)
  - Implement loadSpaceContent() to load all 3 types in parallel using Future.wait
  - Add error handling and loading states

- [ ] Task 3.2: Implement TodoList operations in provider
  - Add createTodoList(TodoList, SpacesProvider) - increments space count
  - Add updateTodoList(TodoList)
  - Add deleteTodoList(String id, SpacesProvider) - decrements space count
  - Add addTodoItem(String listId, TodoItem)
  - Add updateTodoItem(String listId, String itemId, TodoItem)
  - Add deleteTodoItem(String listId, String itemId)
  - Add toggleTodoItem(String listId, String itemId)
  - Add reorderTodoItems(String listId, int oldIndex, int newIndex)
  - All methods should notifyListeners() after updates

- [ ] Task 3.3: Implement List operations in provider
  - Add createList(ListModel, SpacesProvider) - increments space count
  - Add updateList(ListModel)
  - Add deleteList(String id, SpacesProvider) - decrements space count
  - Add addListItem(String listId, ListItem)
  - Add updateListItem(String listId, String itemId, ListItem)
  - Add deleteListItem(String listId, String itemId)
  - Add toggleListItem(String listId, String itemId) - if checkbox style
  - All methods should notifyListeners() after updates

- [ ] Task 3.4: Implement Note operations in provider
  - Add createNote(Note, SpacesProvider) - increments space count
  - Add updateNote(Note)
  - Add deleteNote(String id, SpacesProvider) - decrements space count
  - All methods should notifyListeners() after updates

- [ ] Task 3.5: Add filtering and search functionality
  - Create ContentFilter enum: all, todoLists, lists, notes
  - Add getFilteredContent(ContentFilter) method
  - Add getTotalCount() method
  - Add search(String query) method that searches across all content types
  - Add getTodosWithDueDate(DateTime date) for Today view

- [ ] Task 3.6: Integrate ContentProvider into app
  - Update `lib/main.dart` to provide ContentProvider
  - Add ContentProvider to MultiProvider list
  - Inject repositories into ContentProvider
  - Remove old ItemsProvider references

### Phase 4: UI Components - Cards (Week 2-3)

- [ ] Task 4.1: Create TodoListCard component
  - Create `lib/widgets/components/cards/todo_list_card.dart`
  - Display: name, progress indicator (4/7), progress bar, due date info
  - Use red-orange gradient border from design system
  - Show TodoList icon (checkbox outline)
  - Add onTap callback to open detail screen
  - Add long-press menu: Edit, Delete, Archive
  - Support swipe actions (complete all, delete)

- [ ] Task 4.2: Create ListCard component
  - Create `lib/widgets/components/cards/list_card.dart`
  - Display: custom icon (or default), name, item count (12 items)
  - Use green gradient border from design system
  - Show preview of first 3 items ("Milk, Eggs, Bread...")
  - Add onTap callback to open detail screen
  - Add long-press menu: Edit, Delete, Archive
  - Support swipe actions

- [ ] Task 4.3: Create NoteCard component
  - Create `lib/widgets/components/cards/note_card.dart`
  - Display: title, content preview (first 100 chars), tags
  - Use blue gradient border from design system
  - Show document icon
  - Add onTap callback to open detail screen
  - Add long-press menu: Edit, Delete, Archive
  - Support swipe actions

- [ ] Task 4.4: Create TodoItemCard component (sub-item)
  - Create `lib/widgets/components/cards/todo_item_card.dart`
  - Display: checkbox, title, due date, priority indicator
  - Support strikethrough for completed items
  - Add onTap callback to toggle completion
  - Add long-press to open edit dialog
  - Show reorder handle for drag-and-drop

- [ ] Task 4.5: Create ListItemCard component (sub-item)
  - Create `lib/widgets/components/cards/list_item_card.dart`
  - Display: bullet/number/checkbox, title, optional notes
  - Support checkbox toggle if style is checkboxes
  - Add onTap callback (checkbox toggle or edit)
  - Add long-press to open edit dialog
  - Show reorder handle for drag-and-drop

### Phase 5: UI Components - Detail Screens (Week 3)

- [ ] Task 5.1: Create TodoListDetailScreen
  - Create `lib/widgets/screens/todo_list_detail_screen.dart`
  - Show TodoList name (editable) in AppBar with gradient
  - Show progress indicator (4/7) and progress bar
  - Display list of TodoItems in ReorderableListView
  - Add "Add New Todo" button at bottom
  - Support drag-and-drop reordering of items
  - Add edit dialog for TodoItems (title, description, due date, priority)
  - Add swipe-to-delete for TodoItems
  - Add menu: Edit list properties, Delete list

- [ ] Task 5.2: Create ListDetailScreen
  - Create `lib/widgets/screens/list_detail_screen.dart`
  - Show List name (editable) and custom icon in AppBar with gradient
  - Display list of ListItems in ReorderableListView
  - Show in chosen style (bullets/numbered/checkboxes)
  - Add "Add New Item" button at bottom
  - Support drag-and-drop reordering of items
  - Add edit dialog for ListItems (title, notes, checkbox)
  - Add swipe-to-delete for ListItems
  - Add menu: Change style, Change icon, Delete list

- [ ] Task 5.3: Create NoteDetailScreen
  - Create `lib/widgets/screens/note_detail_screen.dart`
  - Show Note title (editable) in AppBar
  - Large text area for content (multiline TextField)
  - Show tags below content
  - Add formatting toolbar (future: for markdown)
  - Auto-save on focus loss or every 2 seconds
  - Add menu: Delete note, Add to favorites

- [ ] Task 5.4: Update navigation routing
  - Update `lib/core/routes/app_routes.dart`
  - Add routes for TodoListDetailScreen, ListDetailScreen, NoteDetailScreen
  - Create navigation helper methods: navigateToTodoList, navigateToList, navigateToNote
  - Remove old ItemDetailScreen route

### Phase 6: HomeScreen Updates (Week 3-4)

- [ ] Task 6.1: Update HomeScreen to use ContentProvider
  - Update `lib/widgets/screens/home_screen.dart`
  - Replace ItemsProvider with ContentProvider in Consumer
  - Update _loadData() to call contentProvider.loadSpaceContent()
  - Handle loading state with skeleton cards
  - Handle error state with error message and retry button

- [ ] Task 6.2: Implement mixed content list rendering
  - Update ListView.builder to handle mixed content types
  - Use switch expression or if-else to render correct card type
  - Handle type casting: `if (item is TodoList)` → TodoListCard
  - Ensure smooth scrolling with consistent card heights
  - Add separators between cards

- [ ] Task 6.3: Update filter system
  - Replace ItemFilter enum with ContentFilter enum
  - Update filter chips: [All] [Todo Lists] [Lists] [Notes]
  - Add icons to filter chips (grid, checkbox, list, document)
  - Update _getFilteredItems() to _getFilteredContent()
  - Persist selected filter to state

- [ ] Task 6.4: Update empty states
  - Update empty state to show different messages based on context
  - Completely empty space: "Create a todo list, list, or note to get started"
  - Filtered empty: "No [type] in this space - try a different filter"
  - Add illustrations for each empty state
  - Add "Create Content" button that opens Quick Capture

- [ ] Task 6.5: Update space switching flow
  - Ensure space switching triggers contentProvider.loadSpaceContent()
  - Show loading skeleton while switching spaces
  - Reset filter to "All" when switching spaces (or persist per space)
  - Update space itemCount display in Space Switcher

### Phase 7: Quick Capture Updates (Week 4)

- [ ] Task 7.1: Update Quick Capture modal for content types
  - Update `lib/widgets/modals/quick_capture_modal.dart`
  - Add content type selector: TodoList, List, Note
  - Show different input fields based on selected type
  - For TodoList: name field, first TodoItem title
  - For List: name field, list style selector, first item
  - For Note: title field, content area
  - Keep space selector as-is

- [ ] Task 7.2: Implement smart type detection for Quick Capture
  - Update `lib/core/utils/item_type_detector.dart`
  - Add detectContentType(String input) method
  - Detect TodoList: "todo", "task", "need to", due date keywords
  - Detect List: "shopping", "list", "to watch", bullet points
  - Detect Note: long text (>100 chars), paragraph structure
  - Auto-select content type based on detection

- [ ] Task 7.3: Add quick add for items within containers
  - Add "Add to Existing TodoList" option in Quick Capture
  - Add "Add to Existing List" option in Quick Capture
  - Show dropdown of existing TodoLists/Lists in current space
  - If selected, add item directly to container instead of creating new
  - Show success message: "Added to [Container Name]"

- [ ] Task 7.4: Update Quick Capture save logic
  - Update save handler to create correct content type
  - Call contentProvider.createTodoList() for TodoList
  - Call contentProvider.createList() for List
  - Call contentProvider.createNote() for Note
  - Handle errors with user-friendly messages
  - Close modal and navigate to created item on success

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
