# Search Feature Implementation Plan

## Objective and Scope

Implement a unified search feature for the Later app that allows users to search across all content types (notes, todo lists, lists) with advanced filtering capabilities. The search will be accessible from the app bar (replacing the current placeholder) and will be removed from the bottom navigation bar to simplify the UI. This is an MVP implementation focusing on core search functionality with full-text search powered by PostgreSQL.

**Key Goals:**
- Unified search across all content types (including child items)
- App bar integration (remove from bottom nav)
- Full-text search with PostgreSQL GIN indexes
- Content type filtering (notes, todo lists, lists, todo items, list items)
- Tag-based filtering
- Debounced search input (300ms)
- Space-scoped search (current space only)
- Child item search with parent context

**Out of Scope (Future Enhancements):**
- Search history/saved searches
- Global search (all spaces)
- Search suggestions/autocomplete
- Advanced date-based filtering
- Fuzzy search/typo tolerance
- Per-content language detection (add language column to dynamically choose 'german'/'english' config)

## Technical Approach and Reasoning

**Architecture:** Following the app's feature-first Clean Architecture pattern, we'll create a dedicated `features/search/` module with Domain, Data, Application, and Presentation layers. This provides clear separation of concerns and makes the feature easy to test and maintain.

**Database Strategy:** Use PostgreSQL's native full-text search with tsvector columns and GIN indexes. This is significantly faster than ILIKE queries (10-100x improvement) and is already available in Supabase without additional dependencies.

**State Management:** Riverpod 3.0 with code generation (`@riverpod` annotation). The SearchController will handle debouncing using Dart's Timer class (no need for rxdart dependency).

**UI Integration:**
- Search icon in app bar navigates to dedicated SearchScreen
- Remove search tab from bottom navigation (simplify to Home/Settings)
- Use existing design system components (SearchBar, FilterChips, Cards)
- Empty states already exist in design system

**Search Scope:** Initial implementation will search within current space only (not global search). This simplifies the UX and reduces result overload.

## Implementation Phases

### Phase 1: Database Foundation ✅ COMPLETED

- [x] Task 1.1: Add full-text search support to database ✅
  - Created migration file `supabase/migrations/20251117225536_add_search_indexes.sql`
  - Added tsvector column `fts` to `notes` table (generated from title + content with weights)
  - Added tsvector column `fts` to `todo_lists` table (generated from name + description with weights)
  - Added tsvector column `fts` to `lists` table (generated from name)
  - Added tsvector column `fts` to `todo_items` table (generated from title + description with weights)
  - Added tsvector column `fts` to `list_items` table (generated from title + notes with weights)
  - Created GIN indexes on all five `fts` columns for fast search
  - Created GIN index on `notes.tags` for tag filtering
  - Created GIN index on `todo_items.tags` for tag filtering
  - Added composite indexes for space_id + updated_at pattern
  - Applied migration with `supabase db reset`

- [x] Task 1.2: Test full-text search in Supabase Studio ✅
  - Created seed file `supabase/seed.sql` with test data
  - Created test script `test_search_queries.sh` for automated testing
  - Tested basic full-text search: `SELECT * FROM notes WHERE fts @@ to_tsquery('german', 'shopping')` ✅
  - Tested German stemming: `laufen` correctly matches `gelaufen` and `lief` ✅
  - Tested JOIN query for todo_items with parent info ✅
  - Tested JOIN query for list_items with parent info ✅
  - Verified all 7 GIN indexes exist (idx_notes_fts, idx_todo_lists_fts, idx_lists_fts, idx_todo_items_fts, idx_list_items_fts, idx_notes_tags, idx_todo_items_tags) ✅
  - Verified composite indexes exist (idx_notes_space_updated, idx_todo_lists_space_updated, idx_lists_space_updated) ✅
  - Tested tag filtering on notes: `WHERE tags @> ARRAY['work']` ✅
  - Tested tag filtering on todo_items: `WHERE tags @> ARRAY['shopping']` ✅
  - Tested multi-table unified search with UNION ALL ✅
  - Note: Sequential scans used for small datasets (expected behavior), GIN indexes will be used automatically for larger tables

### Phase 2: Feature Module Structure ✅ COMPLETED

- [x] Task 2.1: Create search feature directory structure ✅
  - Created `lib/features/search/` directory
  - Created subdirectories: `domain/`, `data/`, `application/`, `presentation/`
  - Created `domain/models/` for domain models
  - Created `data/repositories/` for data access
  - Created `application/services/` for business logic
  - Created `presentation/controllers/` for state management
  - Created `presentation/screens/` for UI screens
  - Created `presentation/widgets/` for UI components

- [x] Task 2.2: Implement domain models ✅
  - Created `domain/models/search_query.dart`:
    - Fields: query (String), contentTypes (List<ContentType>?), tags (List<String>?), spaceId (String)
    - Added copyWith method for immutability
    - Added toString, equals, and hashCode overrides
  - Created `domain/models/search_result.dart`:
    - Fields: id, type (ContentType enum), title, subtitle, preview, tags, updatedAt, content (dynamic)
    - Added parentId (String?) and parentName (String?) fields for child items
    - Factory constructors: fromNote, fromTodoList, fromList, fromTodoItem, fromListItem
    - Added isChildItem getter to identify child items
    - Added toString, equals, and hashCode overrides
  - Created `domain/models/search_filters.dart`:
    - Fields: contentTypes (List<ContentType>?), tags (List<String>?)
    - Added copyWith method for filter updates (with clear options)
    - Added reset() method to clear all filters
    - Added hasActiveFilters getter
    - Added toString, equals, and hashCode overrides
  - Created `domain/models/models.dart` barrel file exporting all models

- [x] Task 2.3: Extend ContentType enum ✅
  - ContentType enum originally existed in `lib/core/utils/item_type_detector.dart`
  - **Refactored**: Relocated ContentType enum to proper location `lib/core/enums/content_type.dart`
  - Removed unused ItemTypeDetector class (only used in tests, not production)
  - Extended enum with todoItem and listItem values
  - Added ContentTypeExtension with helper methods:
    - displayName getter: Returns user-friendly names ("Todo Item", "List Item", etc.)
    - isContainer getter: Returns true for container types (note/todoList/list), false for child items (todoItem/listItem)
  - Updated all imports in production code to use new location:
    - `lib/features/search/domain/models/` (3 files)
    - `lib/features/home/presentation/widgets/create_content_modal.dart`
    - `lib/features/home/presentation/screens/home_screen.dart`
  - Added exhaustive switch cases for todoItem/listItem in create_content_modal.dart (throw UnsupportedError)
  - Deleted obsolete ItemTypeDetector tests
  - Verified all 1210+ tests pass with no breakage
  - Verified all files pass flutter analyze with no issues

### Phase 3: Data Layer - Search Repository ✅ COMPLETED

- [x] Task 3.1: Create SearchRepository with base structure ✅
  - Created `lib/features/search/data/repositories/search_repository.dart`
  - Extended `BaseRepository` from core
  - Added constructor with required dependencies
  - Implemented executeQuery wrapper for error handling
  - Added provider in `data/repositories/providers.dart`
  - Generated provider code with build_runner

- [x] Task 3.2: Implement unified search method ✅
  - Added `Future<List<SearchResult>> search(SearchQuery query)` method
  - Used executeQuery wrapper for error handling
  - Called private methods: _searchNotes, _searchTodoLists, _searchLists, _searchTodoItems, _searchListItems
  - Combined results into single list
  - Sorted combined results by updatedAt (descending)
  - Returns List<SearchResult>

- [x] Task 3.3: Implement _searchNotes private method ✅
  - Built Supabase query for notes table
  - Added `.eq('user_id', userId)` filter (RLS backup)
  - Added `.eq('space_id', query.spaceId)` filter (space-scoped search)
  - Used `.textSearch('fts', query.query, config: 'german')` for full-text search
  - Added `.contains('tags', query.tags)` if tags provided (must be applied before textSearch)
  - Added `.order('updated_at', ascending: false)`
  - Mapped results to SearchResult objects (type: ContentType.note)
  - Errors handled and wrapped in AppError via BaseRepository.executeQuery

- [x] Task 3.4: Implement _searchTodoLists private method ✅
  - Built Supabase query for todo_lists table
  - Added `.eq('user_id', userId)` filter (RLS backup)
  - Added `.eq('space_id', query.spaceId)` filter (space-scoped search)
  - Used `.textSearch('fts', query.query, config: 'german')` for full-text search
  - Added `.order('updated_at', ascending: false)`
  - Mapped results to SearchResult objects (type: ContentType.todoList)
  - Errors handled and wrapped in AppError via BaseRepository.executeQuery

- [x] Task 3.5: Implement _searchLists private method ✅
  - Built Supabase query for lists table
  - Added `.eq('user_id', userId)` filter (RLS backup)
  - Added `.eq('space_id', query.spaceId)` filter (space-scoped search)
  - Used `.textSearch('fts', query.query, config: 'german')` for full-text search
  - Added `.order('updated_at', ascending: false)`
  - Mapped results to SearchResult objects (type: ContentType.list)
  - Errors handled and wrapped in AppError via BaseRepository.executeQuery

- [x] Task 3.6: Implement _searchTodoItems private method ✅
  - Built Supabase query with JOIN to todo_lists table
  - Used `.select('*, todo_lists!inner(id, name, space_id, user_id, updated_at)')`
  - Added `.textSearch('fts', query.query, config: 'german')` for full-text search
  - Added `.eq('todo_lists.user_id', userId)` filter (via JOIN)
  - Added `.eq('todo_lists.space_id', query.spaceId)` filter (space-scoped via JOIN)
  - Added `.contains('tags', query.tags)` if tags provided (must be applied before textSearch)
  - Mapped results to SearchResult objects (type: ContentType.todoItem)
  - Included parentId and parentName from joined todo_lists data
  - Used parent's updated_at for sorting
  - Errors handled and wrapped in AppError via BaseRepository.executeQuery

- [x] Task 3.7: Implement _searchListItems private method ✅
  - Built Supabase query with JOIN to lists table
  - Used `.select('*, lists!inner(id, name, space_id, user_id, updated_at)')`
  - Added `.textSearch('fts', query.query, config: 'german')` for full-text search
  - Added `.eq('lists.user_id', userId)` filter (via JOIN)
  - Added `.eq('lists.space_id', query.spaceId)` filter (space-scoped via JOIN)
  - Mapped results to SearchResult objects (type: ContentType.listItem)
  - Included parentId and parentName from joined lists data
  - Used parent's updated_at for sorting
  - Errors handled and wrapped in AppError via BaseRepository.executeQuery

- [x] Task 3.8: Write comprehensive tests ✅
  - Created `test/features/search/data/repositories/search_repository_test.dart`
  - Created 23 test cases covering:
    - Repository instantiation
    - SearchQuery validation (all parameters, required only, empty query)
    - Content type filtering (single, multiple, child items, all types, null)
    - Tag filtering (single, multiple, empty, null)
    - Integration test scenarios (documented expected behavior for future integration testing)
  - All 23 tests pass
  - Total test count increased from 1210 to 1233 tests
  - No regressions - all existing tests still pass
  - Verified with flutter analyze - no lint errors

### Phase 4: Application Layer - Search Service ✅ COMPLETED

- [x] Task 4.1: Create SearchService ✅
  - Created `application/services/search_service.dart`
  - Added constructor with SearchRepository dependency
  - Implemented `Future<List<SearchResult>> search(SearchQuery query)` method
  - Added input validation (empty query handling)
  - Validated contentTypes filter if provided
  - Calls repository.search(query)
  - Added error handling with AppError
  - Created provider in `application/providers.dart` using @riverpod annotation
  - Generated provider code with build_runner

- [x] Task 4.2: Add query validation logic ✅
  - Handled empty query string (returns empty list)
  - Validated spaceId is not empty (throws ValidationError)
  - Validated contentTypes list is not empty if provided (returns empty list)
  - Trimmed whitespace from query string
  - Added query length limit (max 500 characters) with ValidationError

- [x] Task 4.3: Write comprehensive tests ✅
  - Created `test/features/search/application/services/search_service_test.dart`
  - Created 14 test cases covering:
    - Constructor validation
    - Empty/whitespace query handling
    - SpaceId validation
    - Query trimming
    - Query length validation (boundary testing)
    - Empty contentTypes filter handling
    - Repository calls with valid queries
    - ContentTypes filter testing
    - Tags filter testing
    - Error propagation from repository
    - Unknown error wrapping
    - Empty result handling
  - All 14 tests pass
  - Total test count increased from 1233 to 1247 tests
  - No regressions - all existing tests still pass
  - Verified with flutter analyze - no lint errors
  - Fixed Riverpod provider to use `Ref` instead of generated type
  - Removed unused stackTrace variable

### Phase 5: Presentation Layer - Controllers

- [ ] Task 5.1: Create SearchController with debouncing
  - Create `presentation/controllers/search_controller.dart`
  - Use `@riverpod` annotation (auto-dispose by default)
  - Add Timer field for debouncing (_debounceTimer)
  - Implement build() method returning `Future<List<SearchResult>>`
  - Initial state: empty list
  - Generate code: `dart run build_runner build --delete-conflicting-outputs`

- [ ] Task 5.2: Implement search method with debouncing
  - Add `void search(SearchQuery query)` method
  - Cancel previous timer if exists (_debounceTimer?.cancel())
  - Set state to AsyncValue.loading() immediately (UI feedback)
  - Create new Timer with 300ms duration
  - In timer callback: call searchService.search(query)
  - Check ref.mounted before updating state (Riverpod 3.0 best practice)
  - Update state with AsyncValue.data(results) on success
  - Catch AppError and store in AsyncValue.error state
  - Log errors with ErrorLogger.logError()

- [ ] Task 5.3: Implement clear method
  - Add `void clear()` method
  - Cancel debounce timer if running
  - Set state to AsyncValue.data([])
  - Reset to empty results

- [ ] Task 5.4: Add dispose override
  - Override dispose() method
  - Cancel debounce timer to prevent memory leaks
  - Call super.dispose()

- [ ] Task 5.5: Create SearchFiltersController
  - Create `presentation/controllers/search_filters_controller.dart`
  - Use `@riverpod` annotation (auto-dispose)
  - Implement build() returning SearchFilters (initial: all types, no tags)
  - Add `void setContentTypes(List<ContentType>? types)` method
  - Add `void setTags(List<String>? tags)` method
  - Add `void reset()` method to clear all filters
  - Generate code: `dart run build_runner build --delete-conflicting-outputs`

### Phase 6: Presentation Layer - UI Components

- [ ] Task 6.1: Create SearchScreen
  - Create `presentation/screens/search_screen.dart`
  - Extend ConsumerStatefulWidget
  - Add TextEditingController for search input (_searchController)
  - Add optional initialQuery parameter
  - Implement initState to trigger search if initialQuery provided
  - Implement dispose to clean up TextEditingController

- [ ] Task 6.2: Build SearchScreen Scaffold
  - Create Scaffold with AppBar
  - AppBar title: TextField for search input (autofocus: true)
  - TextField decoration: hintText with localized string
  - Add clear button (IconButton with X icon) in TextField suffix
  - TextField onChanged: call _performSearch method
  - Set body to Column with filters and results

- [ ] Task 6.3: Implement _performSearch helper
  - Get current space from currentSpaceControllerProvider
  - Get current filters from searchFiltersControllerProvider
  - Build SearchQuery with: query, spaceId, contentTypes, tags
  - Call ref.read(searchControllerProvider.notifier).search(query)

- [ ] Task 6.4: Build search results view
  - Watch searchControllerProvider in build method
  - Use AsyncValue.when() to handle loading/data/error states
  - Loading state: Center with CircularProgressIndicator
  - Error state: ErrorView widget with retry button
  - Data state: Check if results.isEmpty
    - If empty: Show EmptySearchState from design system
    - If not empty: Show ListView.builder with SearchResultCard widgets

- [ ] Task 6.5: Create SearchFiltersWidget
  - Create `presentation/widgets/search_filters_widget.dart`
  - Extend ConsumerWidget
  - Watch searchFiltersControllerProvider
  - Build Wrap with horizontal filter chips
  - Add TemporalFilterChip for "All", "Notes", "Tasks", "Lists"
  - Each chip: onSelected callback updates searchFiltersControllerProvider
  - Use localized strings for labels
  - Add padding and spacing (8px between chips)

- [ ] Task 6.6: Create SearchResultCard
  - Create `presentation/widgets/search_result_card.dart`
  - Extend StatelessWidget
  - Accept SearchResult parameter
  - Use switch on result.type to render appropriate card:
    - ContentType.note → NoteCard(note: result.content as Note)
    - ContentType.todoList → TodoListCard(todoList: result.content as TodoList)
    - ContentType.list → ListCard(list: result.content as ListModel)
    - ContentType.todoItem → TodoItemSearchCard with parent context
    - ContentType.listItem → ListItemSearchCard with parent context
  - Add onTap callback to navigate to detail screen
  - Wrap in Material widget for ink splash effect

- [ ] Task 6.6a: Create TodoItemSearchCard widget
  - Create `presentation/widgets/todo_item_search_card.dart`
  - Display TodoItem title and preview
  - Show parent context: "in [TodoList Name]" subtitle
  - Use task-specific styling/gradient
  - Add checkbox indicator showing completion status
  - Handle onTap to navigate to parent TodoListDetailScreen

- [ ] Task 6.6b: Create ListItemSearchCard widget
  - Create `presentation/widgets/list_item_search_card.dart`
  - Display ListItem title and notes preview
  - Show parent context: "in [List Name]" subtitle
  - Use list-specific styling/gradient
  - Add style indicator (bullet/numbered/checklist)
  - Handle onTap to navigate to parent ListDetailScreen

- [ ] Task 6.7: Add navigation handlers
  - In SearchResultCard, add onTap callback
  - Navigate based on content type:
    - Note → Navigator.push to NoteDetailScreen
    - TodoList → Navigator.push to TodoListDetailScreen
    - ListModel → Navigator.push to ListDetailScreen
    - TodoItem → Navigator.push to TodoListDetailScreen(listId: result.parentId)
    - ListItem → Navigator.push to ListDetailScreen(listId: result.parentId)
  - Pass the original model from result.content
  - For child items, pass parentId to navigate to parent detail screen
  - Use MaterialPageRoute for navigation
  - Consider adding scroll-to-item functionality for child items (future enhancement)

### Phase 7: Integration with Home Screen

- [ ] Task 7.1: Update home_screen.dart app bar
  - Open `features/home/presentation/screens/home_screen.dart`
  - Find search IconButton in _buildAppBar (line ~502)
  - Replace onPressed with navigation to SearchScreen:
    ```dart
    onPressed: () {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const SearchScreen(),
        ),
      );
    },
    ```
  - Update tooltip to use localized string

- [ ] Task 7.2: Remove search from bottom navigation
  - Open `shared/widgets/navigation/icon_only_bottom_nav.dart`
  - Remove search navigation item (index 1)
  - Update assertions to check for 0-1 range (2 items instead of 3)
  - Update Row children to only include Home and Settings
  - Remove search-related localization references
  - Update documentation comments

- [ ] Task 7.3: Update HomeScreen to use 2-item navigation
  - Update _selectedNavIndex logic to support 0-1 range
  - Remove search index handling
  - Update IconOnlyBottomNav instantiation with 2 items
  - Test navigation between Home and Settings tabs

### Phase 8: Localization

- [ ] Task 8.1: Add English localization strings
  - Open `lib/l10n/app_en.arb`
  - Add search screen strings:
    - `searchBarHint`: "Search notes, tasks, lists..."
    - `searchScreenTitle`: "Search"
    - `searchEmptyTitle`: "No results found"
    - `searchEmptyMessage`: "Try different keywords or adjust filters"
    - `searchClearButton`: "Clear"
    - `searchInCurrentSpace`: "Search in {spaceName}"
  - Add filter strings (if not exist):
    - `filterAll`: "All"
    - `filterNotes`: "Notes"
    - `filterTodoLists`: "Tasks"
    - `filterLists`: "Lists"
    - `filterTodoItems`: "Todo Items"
    - `filterListItems`: "List Items"
  - Add child item context strings:
    - `searchResultInTodoList`: "in {todoListName}"
    - `searchResultInList`: "in {listName}"

- [ ] Task 8.2: Add German localization strings
  - Open `lib/l10n/app_de.arb`
  - Add search screen strings (German translations):
    - `searchBarHint`: "Notizen, Aufgaben, Listen durchsuchen..."
    - `searchScreenTitle`: "Suchen"
    - `searchEmptyTitle`: "Keine Ergebnisse gefunden"
    - `searchEmptyMessage`: "Versuchen Sie andere Suchbegriffe oder passen Sie die Filter an"
    - `searchClearButton`: "Löschen"
    - `searchInCurrentSpace`: "In {spaceName} suchen"
  - Add filter strings (if not exist):
    - `filterTodoItems`: "Todo-Einträge"
    - `filterListItems`: "Listeneinträge"
  - Add child item context strings:
    - `searchResultInTodoList`: "in {todoListName}"
    - `searchResultInList`: "in {listName}"

- [ ] Task 8.3: Regenerate localization code
  - Run `flutter pub get` to regenerate localization files
  - Verify `lib/l10n/app_localizations.dart` has new methods
  - Check no errors in generated code

### Phase 9: Testing

- [ ] Task 9.1: Create unit tests for SearchRepository
  - Create `test/features/search/data/repositories/search_repository_test.dart`
  - Mock Supabase client using mockito
  - Test search() returns correct results for notes
  - Test search() returns correct results for todo lists
  - Test search() returns correct results for lists
  - Test search() returns correct results for todo items (with JOIN)
  - Test search() returns correct results for list items (with JOIN)
  - Test search() respects space filter (including for child items via JOIN)
  - Test search() respects tag filter (notes and todo items)
  - Test search() sorts by updatedAt descending (using parent updatedAt for children)
  - Test child items include parentId and parentName in SearchResult
  - Test error handling (Supabase errors wrapped in AppError)

- [ ] Task 9.2: Create unit tests for SearchService
  - Create `test/features/search/application/services/search_service_test.dart`
  - Mock SearchRepository
  - Test search() validates empty query
  - Test search() validates spaceId
  - Test search() calls repository.search()
  - Test error handling

- [ ] Task 9.3: Create unit tests for SearchController
  - Create `test/features/search/presentation/controllers/search_controller_test.dart`
  - Mock SearchService
  - Test search() sets loading state
  - Test search() debounces requests (300ms delay)
  - Test search() updates state with results
  - Test clear() resets state
  - Test error handling
  - Test dispose cancels timer

- [ ] Task 9.4: Create widget tests for SearchScreen
  - Create `test/features/search/presentation/screens/search_screen_test.dart`
  - Use testApp() helper from test_helpers.dart
  - Test SearchScreen displays search bar
  - Test TextField has correct hint text
  - Test clear button clears search
  - Test loading state shows CircularProgressIndicator
  - Test empty state shows EmptySearchState
  - Test results list shows SearchResultCard widgets
  - Test error state shows ErrorView

- [ ] Task 9.5: Create widget tests for SearchFiltersWidget
  - Create `test/features/search/presentation/widgets/search_filters_widget_test.dart`
  - Use testApp() helper
  - Test filter chips are rendered
  - Test selecting filter updates controller
  - Test filter chips show selected state
  - Test filter chips use localized strings

- [ ] Task 9.6: Run all tests and verify coverage
  - Run `flutter test` to execute all tests
  - Verify all search tests pass
  - Check existing tests still pass (no regressions)
  - Run `flutter test --coverage` to generate coverage report
  - Verify search feature has >70% coverage

### Phase 10: Performance Optimization & Polish

- [ ] Task 10.1: Add result pagination
  - Update SearchRepository to accept limit parameter (default: 50)
  - Add `.limit(50)` to Supabase queries
  - Update SearchScreen to show "Load More" button if 50+ results
  - Implement loadMore() method in SearchController
  - Test with large result sets

- [ ] Task 10.2: Optimize database queries
  - Review EXPLAIN ANALYZE for search queries in Supabase Studio
  - Verify GIN indexes are being used
  - Test query performance with sample data (100, 1000, 10000 items)
  - Add `.select('id, title, content, tags, updated_at')` to reduce payload
  - Measure query time (should be <100ms)

- [ ] Task 10.3: Add keyboard shortcuts (optional)
  - Add Focus widget to SearchScreen
  - Implement onKeyEvent handler
  - Add Escape key to clear search
  - Add Cmd/Ctrl+K shortcut from HomeScreen to open search
  - Test keyboard navigation

- [ ] Task 10.4: Test with German locale
  - Change device language to German
  - Verify all search strings are translated
  - Verify filter chips use German labels
  - Check for text overflow issues (German is ~30% longer)
  - Test with long German words

- [ ] Task 10.5: Add analytics (optional)
  - Log search queries (anonymized) for insights
  - Track search result clicks
  - Track filter usage
  - Monitor search performance metrics

## Dependencies and Prerequisites

**Existing Dependencies:**
- `flutter_riverpod: ^3.0.3` (already in pubspec.yaml)
- `riverpod_annotation: ^3.0.1` (already in pubspec.yaml)
- `build_runner` (already in pubspec.yaml)
- `supabase_flutter` (already in pubspec.yaml)

**No New Dependencies Required:** The implementation uses only existing dependencies. Dart's Timer class is sufficient for debouncing (no need for rxdart).

**Database Prerequisites:**
- Supabase CLI installed and running
- Local Supabase instance running (via `supabase start`)
- Database migrations applied (via `supabase db reset`)

**Code Generation Prerequisites:**
- `dart run build_runner build --delete-conflicting-outputs` after adding @riverpod providers
- Run during development: `dart run build_runner watch --delete-conflicting-outputs`

**Testing Prerequisites:**
- Mock Supabase client setup in tests
- testApp() helper from test_helpers.dart for widget tests
- Mockito for mocking dependencies

## Challenges and Considerations

**Challenge 1: Full-Text Search Query Syntax**
- PostgreSQL full-text search uses special syntax (& for AND, | for OR)
- User input needs to be sanitized/escaped for tsvector queries
- Solution: Use Supabase `.textSearch()` method which handles escaping
- Fallback to ILIKE if full-text search fails
- Language config: Using 'german' as default for better German stemming support

**Challenge 2: Performance with Large Datasets**
- Full-text search can be slow without proper indexes
- Solution: GIN indexes on tsvector columns (Phase 1)
- Pagination to limit result set size (max 50 results)
- Debouncing to reduce query frequency (300ms)

**Challenge 3: Cross-Type Search Results**
- Different content types have different schemas (Note vs TodoList vs ListModel)
- Solution: Unified SearchResult model that normalizes differences
- Type-safe casting when rendering cards (result.content as Note)

**Challenge 4: Tag Filtering Edge Cases**
- Notes have tags, but TodoLists and Lists do not (yet)
- Solution: Tag filtering only applies to Notes in Phase 1
- Future enhancement: Add tags to TodoLists and Lists tables

**Challenge 5: Empty Query Handling**
- Should empty query show all results or nothing?
- Solution: Empty query returns empty list (no results)
- User must type at least one character to search
- Alternative: Show "recent content" when query is empty

**Challenge 6: Bottom Navigation Removal**
- Removing search from nav bar changes navigation flow
- Users might expect search in bottom nav
- Solution: Prominent search button in app bar (top right)
- Consider adding search tutorial/tooltip on first use

**Challenge 7: Space-Scoped Search UX**
- Search is scoped to current space (not global)
- Users might expect global search
- Solution: Show "Search in [Space Name]" hint in search bar
- Future enhancement: Add toggle for global vs space-scoped search

**Challenge 8: Testing Full-Text Search**
- Hard to test PostgreSQL full-text search in unit tests
- Solution: Mock Supabase client in tests
- Integration tests with local Supabase instance
- Manual testing in Supabase Studio

**Challenge 9: Error Handling**
- Network errors, timeout errors, database errors
- Solution: Use centralized error handling with AppError
- Show user-friendly error messages (localized)
- Add retry button in error state

**Challenge 10: Migration Backwards Compatibility**
- Adding tsvector columns to existing tables
- Solution: Use GENERATED ALWAYS AS to auto-populate tsvector
- No data migration needed (computed on-the-fly)
- Test migration with `supabase db reset`

**Challenge 11: Child Item Search with JOINs**
- Child items (todo_items, list_items) don't have direct user_id or space_id
- Need JOIN queries to filter by parent's space_id/user_id
- Solution: Use Supabase `.select('*, parent_table!inner(...)')` syntax
- Inner join ensures only items with valid parents are returned
- Access parent data via nested JSON in response

**Challenge 12: Result Deduplication**
- Searching "Shopping" might return parent TodoList + multiple TodoItems
- Could overwhelm user with many related results
- Solution for MVP: Show all results separately (simple)
- Future enhancement: Group by parent with "3 matching items" badge
- Sort intelligently: parent first, then children
