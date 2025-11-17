# Search Feature Implementation Plan

## Objective and Scope

Implement a unified search feature for the Later app that allows users to search across all content types (notes, todo lists, lists) with advanced filtering capabilities. The search will be accessible from the app bar (replacing the current placeholder) and will be removed from the bottom navigation bar to simplify the UI. This is an MVP implementation focusing on core search functionality with full-text search powered by PostgreSQL.

**Key Goals:**
- Unified search across all content types
- App bar integration (remove from bottom nav)
- Full-text search with PostgreSQL GIN indexes
- Content type filtering
- Tag-based filtering
- Debounced search input (300ms)
- Space-scoped search (current space only)

**Out of Scope (Future Enhancements):**
- Search history/saved searches
- Global search (all spaces)
- Search suggestions/autocomplete
- Advanced date-based filtering
- Fuzzy search/typo tolerance

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

### Phase 1: Database Foundation

- [ ] Task 1.1: Add full-text search support to database
  - Create new migration file `supabase/migrations/YYYYMMDDHHMMSS_add_search_indexes.sql`
  - Add tsvector column `fts` to `notes` table (generated from title + content)
  - Add tsvector column `fts` to `todo_lists` table (generated from name + description)
  - Add tsvector column `fts` to `lists` table (generated from name)
  - Create GIN indexes on all three `fts` columns for fast search
  - Create GIN index on `notes.tags` for tag filtering
  - Add composite indexes for space_id + updated_at pattern
  - Run `supabase db reset` to apply migration

- [ ] Task 1.2: Test full-text search in Supabase Studio
  - Open Supabase Studio (http://localhost:54323)
  - Run test query: `SELECT * FROM notes WHERE fts @@ to_tsquery('english', 'test')`
  - Verify GIN indexes are being used (EXPLAIN ANALYZE)
  - Test tag filtering: `SELECT * FROM notes WHERE tags @> ARRAY['work']`
  - Verify performance with sample data

### Phase 2: Feature Module Structure

- [ ] Task 2.1: Create search feature directory structure
  - Create `lib/features/search/` directory
  - Create subdirectories: `domain/`, `data/`, `application/`, `presentation/`
  - Create `domain/models/` for domain models
  - Create `data/repositories/` for data access
  - Create `application/services/` for business logic
  - Create `presentation/controllers/` for state management
  - Create `presentation/screens/` for UI screens
  - Create `presentation/widgets/` for UI components

- [ ] Task 2.2: Implement domain models
  - Create `domain/models/search_query.dart`:
    - Fields: query (String), contentTypes (List<ContentType>?), tags (List<String>?), spaceId (String)
    - Add copyWith method for immutability
  - Create `domain/models/search_result.dart`:
    - Fields: id, type (ContentType enum), title, subtitle, preview, tags, updatedAt, content (dynamic)
    - Factory constructor to map from Note/TodoList/ListModel
  - Create `domain/models/search_filters.dart`:
    - Fields: contentTypes (List<ContentType>?), tags (List<String>?)
    - Add copyWith method for filter updates
  - Export all models in `domain/models/models.dart` barrel file

- [ ] Task 2.3: Create ContentType enum if not exists
  - Check if ContentType enum exists in codebase
  - If not, create `lib/core/enums/content_type.dart`:
    - Enum values: note, todoList, list
    - Add helper methods: displayName, icon
  - Update imports throughout codebase to use new enum

### Phase 3: Data Layer - Search Repository

- [ ] Task 3.1: Create SearchRepository with base structure
  - Create `data/repositories/search_repository.dart`
  - Extend `BaseRepository` from core
  - Add constructor with required dependencies
  - Implement executeQuery wrapper for error handling
  - Add provider in `data/repositories/providers.dart`

- [ ] Task 3.2: Implement unified search method
  - Add `Future<List<SearchResult>> search(SearchQuery query)` method
  - Use executeQuery wrapper for error handling
  - Call private methods: _searchNotes, _searchTodoLists, _searchLists
  - Combine results into single list
  - Sort combined results by updatedAt (descending)
  - Return List<SearchResult>

- [ ] Task 3.3: Implement _searchNotes private method
  - Build Supabase query for notes table
  - Add `.eq('user_id', userId)` filter (RLS backup)
  - Add `.eq('space_id', query.spaceId)` filter (space-scoped search)
  - Use `.textSearch('fts', query.query, config: 'english')` for full-text search
  - Add `.contains('tags', query.tags)` if tags provided
  - Add `.order('updated_at', ascending: false)`
  - Map results to SearchResult objects (type: ContentType.note)
  - Handle errors and wrap in AppError

- [ ] Task 3.4: Implement _searchTodoLists private method
  - Build Supabase query for todo_lists table
  - Add `.eq('user_id', userId)` filter (RLS backup)
  - Add `.eq('space_id', query.spaceId)` filter (space-scoped search)
  - Use `.textSearch('fts', query.query, config: 'english')` for full-text search
  - Add `.order('updated_at', ascending: false)`
  - Map results to SearchResult objects (type: ContentType.todoList)
  - Handle errors and wrap in AppError

- [ ] Task 3.5: Implement _searchLists private method
  - Build Supabase query for lists table
  - Add `.eq('user_id', userId)` filter (RLS backup)
  - Add `.eq('space_id', query.spaceId)` filter (space-scoped search)
  - Use `.textSearch('fts', query.query, config: 'english')` for full-text search
  - Add `.order('updated_at', ascending: false)`
  - Map results to SearchResult objects (type: ContentType.list)
  - Handle errors and wrap in AppError

### Phase 4: Application Layer - Search Service

- [ ] Task 4.1: Create SearchService
  - Create `application/services/search_service.dart`
  - Add constructor with SearchRepository dependency
  - Implement `Future<List<SearchResult>> search(SearchQuery query)` method
  - Add input validation (empty query handling)
  - Validate contentTypes filter if provided
  - Call repository.search(query)
  - Add error handling with AppError
  - Add provider in `application/providers.dart`

- [ ] Task 4.2: Add query validation logic
  - Handle empty query string (return empty list or all results)
  - Validate spaceId is not empty
  - Validate contentTypes list is not empty if provided
  - Trim whitespace from query string
  - Add query length limits (e.g., max 500 characters)

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
  - Add onTap callback to navigate to detail screen
  - Wrap in Material widget for ink splash effect

- [ ] Task 6.7: Add navigation handlers
  - In SearchResultCard, add onTap callback
  - Navigate based on content type:
    - Note → Navigator.push to NoteDetailScreen
    - TodoList → Navigator.push to TodoListDetailScreen
    - ListModel → Navigator.push to ListDetailScreen
  - Pass the original model from result.content
  - Use MaterialPageRoute for navigation

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

- [ ] Task 8.2: Add German localization strings
  - Open `lib/l10n/app_de.arb`
  - Add search screen strings (German translations):
    - `searchBarHint`: "Notizen, Aufgaben, Listen durchsuchen..."
    - `searchScreenTitle`: "Suchen"
    - `searchEmptyTitle`: "Keine Ergebnisse gefunden"
    - `searchEmptyMessage`: "Versuchen Sie andere Suchbegriffe oder passen Sie die Filter an"
    - `searchClearButton`: "Löschen"
    - `searchInCurrentSpace`: "In {spaceName} suchen"
  - Add filter strings (if not exist)

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
  - Test search() respects space filter
  - Test search() respects tag filter
  - Test search() sorts by updatedAt descending
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
