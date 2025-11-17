# Research: Search and Filter Feature Integration for Later App

## Executive Summary

Based on comprehensive analysis of the Later app's feature-first architecture and industry best practices for 2025, this research explores how to integrate unified search and advanced filtering capabilities into the existing codebase. The app already has foundational pieces in place: basic search in NoteRepository, tag support in the Note model, and a ContentFilterController for type-based filtering. However, a complete search and filter feature requires a dedicated feature module that provides cross-content-type search, tag-based filtering, and a cohesive UI experience.

**Key Findings:**
- **Current State**: Basic filtering by content type exists; search is repository-level only (not exposed in UI)
- **Architecture Fit**: Feature-first structure is ideal for a dedicated `search` feature module
- **Implementation Strategy**: Create `features/search/` with full Clean Architecture layers (Domain, Data, Application, Presentation)
- **Technology Stack**: Supabase PostgreSQL full-text search with GIN indexes, Riverpod 3.0 for state management with debouncing
- **Benefits**: Unified search across all content types, tag-based filtering, advanced query capabilities, and scalable architecture

**Recommended Approach:**
1. Create dedicated `features/search/` module with Clean Architecture
2. Implement SearchService using Supabase full-text search (.textSearch() API)
3. Add database GIN indexes for full-text search and tag filtering
4. Build SearchController with Riverpod 3.0 for debounced search state
5. Design search UI with filters, results view, and empty states

This positions Later to handle sophisticated search requirements while maintaining clean separation of concerns and leveraging existing infrastructure (Supabase, Riverpod 3.0, design system).

## Research Scope

### What Was Researched
- Current Later app architecture and feature organization
- Existing search/filter capabilities in codebase
- Feature-first architecture patterns for search features in Flutter 2025
- Supabase PostgreSQL full-text search capabilities and Flutter integration
- Riverpod 3.0 state management patterns for search (debouncing, caching)
- Database schema and indexing requirements
- Industry best practices for search UI/UX in productivity apps
- Tag system implementation across content types
- Integration points with existing controllers and repositories

### What Was Explicitly Excluded
- Third-party search services (Algolia, Meilisearch, ElasticSearch) - staying with Supabase
- Advanced NLP/fuzzy search - basic full-text search is sufficient for MVP
- Voice search integration - future enhancement
- Search analytics and relevance tracking - future enhancement
- Cross-user search (collaboration features) - not in current scope
- Search history/saved searches - future enhancement

### Research Methodology
- Codebase analysis using Grep, Glob, and Read tools
- Review of existing feature modules (auth, notes, spaces, lists, todo_lists)
- Examination of current repository patterns and search methods
- Web research on Flutter search best practices 2025
- Supabase documentation review for full-text search API
- Riverpod 3.0 state management patterns analysis
- Industry standards review for search/filter UI patterns

## Current State Analysis

### Existing Implementation

**✅ Already Implemented:**

1. **Basic Content Type Filtering** (`features/home/presentation/controllers/content_filter_controller.dart`):
   - `ContentFilter` enum with `all`, `todoLists`, `lists`, `notes`
   - `getFilteredContent(spaceId)` method combines and filters content
   - Used in HomeScreen to show filtered lists
   - Sorting by `updatedAt` descending (most recent first)

2. **Repository-Level Search** (`features/notes/data/repositories/note_repository.dart`):
   - `search(String query)` method using Supabase `.or()` with `.ilike()`
   - Searches both `title` and `content` fields case-insensitively
   - Returns `List<Note>` sorted by sort_order
   - **NOT exposed in UI** - only at repository level

3. **Tag Support in Note Model**:
   - `tags` field (List<String>) in Note domain model
   - `getByTag(String tag)` method in NoteRepository using `.contains()`
   - Database column `tags TEXT[]` in notes table
   - **No UI for tag management or filtering**

4. **Design System Components**:
   - `EmptySearchState` widget for no results
   - `FilterChip` atom for filter UI
   - Existing card components for displaying results

5. **Feature-First Architecture**:
   - Clean separation: Domain, Data, Application, Presentation layers
   - Riverpod 3.0 with code generation (`@riverpod` annotation)
   - Service layer pattern between controllers and repositories
   - Provider architecture with auto-dispose family providers

**❌ Missing Capabilities:**

1. **No Unified Search Feature**:
   - No search UI (search bar, results screen)
   - No cross-content-type search (only notes have search method)
   - No search state management (query, results, loading)
   - No search history or suggestions

2. **No Advanced Filtering**:
   - No tag filtering UI (tags exist but not used)
   - No date-based filtering (no due dates implemented yet)
   - No combined filters (type + tag + search query)
   - No filter persistence

3. **No Tag Management UI**:
   - Tags in Note model but no UI to add/remove/edit tags
   - No tag autocomplete or suggestions
   - No tag-based navigation or filtering
   - Tags not implemented for TodoList or ListModel

4. **Database Optimization Missing**:
   - No full-text search indexes (GIN indexes for tsvector)
   - No tag indexes (GIN indexes for tag arrays)
   - No optimized search queries (using simple ILIKE)

5. **Search Experience Gaps**:
   - No debouncing for search input
   - No search result highlighting
   - No search within specific space vs. global search
   - No sorting options for results

### Technical Foundation

**Current Architecture Strengths:**

1. **Feature-First Structure** (`lib/features/`):
   ```
   features/
   ├── auth/           # Authentication
   ├── home/           # Home screen with ContentFilterController
   ├── lists/          # Custom lists feature
   ├── notes/          # Notes feature with search method
   ├── spaces/         # Spaces management
   ├── theme/          # Theme management
   └── todo_lists/     # Todo lists feature
   ```

2. **Clean Architecture Layers** (example from lists feature):
   ```
   lists/
   ├── application/
   │   ├── providers.dart
   │   └── services/
   │       └── list_service.dart
   ├── data/
   │   └── repositories/
   │       ├── list_repository.dart
   │       └── providers.dart
   ├── domain/
   │   └── models/
   │       ├── list_item_model.dart
   │       └── list_model.dart
   └── presentation/
       ├── controllers/
       │   ├── list_items_controller.dart
       │   └── lists_controller.dart
       └── screens/
           └── list_detail_screen.dart
   ```

3. **Riverpod 3.0 Controller Pattern**:
   ```dart
   @riverpod
   class NotesController extends _$NotesController {
     @override
     Future<List<Note>> build(String spaceId) async {
       final service = ref.watch(noteServiceProvider);
       return service.getNotesForSpace(spaceId);
     }
   }
   ```

4. **Service Layer Pattern** (example from `note_service.dart`):
   - Validation and business logic
   - Error handling with AppError
   - Repository delegation
   - Consistent interface across features

5. **Database Schema** (PostgreSQL via Supabase):
   ```sql
   -- notes table
   CREATE TABLE notes (
       id UUID PRIMARY KEY,
       user_id UUID REFERENCES auth.users(id),
       space_id UUID REFERENCES spaces(id),
       title TEXT NOT NULL,
       content TEXT,
       tags TEXT[],  -- Array for tags
       sort_order INTEGER,
       created_at TIMESTAMPTZ,
       updated_at TIMESTAMPTZ
   );

   -- Existing indexes
   CREATE INDEX idx_notes_user_space_sort ON notes(user_id, space_id, sort_order);
   ```

6. **Supabase Client Integration**:
   - `BaseRepository` provides `supabase` client
   - `executeQuery()` wrapper for error handling
   - RLS policies ensure user-scoped data access

### Industry Standards (2025)

**Must-Have Search Features:**

1. **Full-Text Search**:
   - Sub-50ms response time for local/indexed search
   - Search across all text fields (title, content, description)
   - Case-insensitive matching
   - Relevance ranking of results

2. **Real-Time Search**:
   - Debounced search input (300-500ms delay)
   - Instant results as user types
   - Loading indicators during search
   - Cancel previous requests when new query starts

3. **Advanced Filtering**:
   - Filter by content type (Notes, TodoLists, Lists)
   - Filter by tags (multi-select)
   - Filter by date range (when due dates implemented)
   - Combine multiple filters with AND logic

4. **Search UI Components**:
   - Prominent search bar (app bar or dedicated screen)
   - Search result preview with context/highlights
   - Filter chips for quick filtering
   - Empty state for no results
   - Clear search button

5. **Tag System**:
   - Create, edit, delete tags
   - Tag autocomplete/suggestions
   - Tag-based filtering
   - Tag colors for visual distinction
   - Tag usage count

**Best Practices from Competitors:**

- **Todoist**: Unified search across all projects, tag-based filters, saved searches
- **Notion**: Full-text search with result previews, filter by type and date
- **Bear**: Tag-based navigation, nested tags, fast search
- **Things 3**: Quick search with keyboard shortcuts, tag filtering
- **Obsidian**: Powerful search with regex, tag-based organization

## Technical Analysis

### Approach 1: Dedicated Search Feature Module

**Description:**
Create a new `features/search/` module following the existing feature-first architecture pattern. This module contains all search and filter logic with full Clean Architecture layers.

**Structure:**
```
features/search/
├── domain/
│   └── models/
│       ├── search_query.dart          # Search query parameters
│       ├── search_result.dart         # Unified result type
│       └── search_filters.dart        # Filter configuration
├── data/
│   ├── repositories/
│   │   ├── search_repository.dart     # Unified search across content types
│   │   └── providers.dart
│   └── mappers/
│       └── search_result_mapper.dart  # Maps different content types to SearchResult
├── application/
│   ├── services/
│   │   └── search_service.dart        # Business logic and validation
│   └── providers.dart
└── presentation/
    ├── controllers/
    │   ├── search_controller.dart      # Main search state controller
    │   └── search_filters_controller.dart
    ├── screens/
    │   └── search_screen.dart          # Dedicated search screen
    └── widgets/
        ├── search_bar_widget.dart
        ├── search_filters_widget.dart
        ├── search_result_card.dart
        └── search_suggestions_widget.dart
```

**Pros:**
- **Clean Separation**: Search logic isolated from other features
- **Scalable**: Easy to extend with new search capabilities
- **Maintainable**: Clear ownership and responsibility
- **Testable**: Independent unit/widget tests for search feature
- **Reusable**: SearchService can be used by other features
- **Follows Existing Pattern**: Matches current architecture (auth, notes, spaces, etc.)
- **Future-Proof**: Easy to add advanced features (saved searches, search history)

**Cons:**
- **More Files**: Adds new feature directory with multiple files
- **Initial Setup**: Requires boilerplate for controllers, services, repositories
- **Navigation Complexity**: Need to handle navigation to search screen
- **Potential Duplication**: Some search logic may overlap with repository search methods

**Use Cases:**
- Global search from app bar (across all spaces and content types)
- Search within current space only
- Advanced filtering with multiple criteria
- Tag-based search and filtering
- Quick search from keyboard shortcut
- Search suggestions based on recent queries

**Implementation Complexity:** Medium-High

**Code Example:**

```dart
// domain/models/search_query.dart
class SearchQuery {
  final String query;
  final List<ContentType>? contentTypes;
  final List<String>? tags;
  final String? spaceId;  // null = search all spaces
  final DateRange? dateRange;
  final bool caseSensitive;

  SearchQuery({
    required this.query,
    this.contentTypes,
    this.tags,
    this.spaceId,
    this.dateRange,
    this.caseSensitive = false,
  });
}

// domain/models/search_result.dart
class SearchResult {
  final String id;
  final ContentType type;  // note, todoList, list
  final String title;
  final String? subtitle;
  final String? preview;  // First N chars of content
  final List<String> tags;
  final DateTime updatedAt;
  final dynamic content;  // Original Note/TodoList/ListModel

  SearchResult({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.preview,
    required this.tags,
    required this.updatedAt,
    required this.content,
  });
}

// data/repositories/search_repository.dart
class SearchRepository extends BaseRepository {
  /// Unified search across all content types using Supabase full-text search
  Future<List<SearchResult>> search(SearchQuery query) async {
    return executeQuery(() async {
      final results = <SearchResult>[];

      // Search notes if included in content types
      if (query.contentTypes == null ||
          query.contentTypes!.contains(ContentType.note)) {
        final notes = await _searchNotes(query);
        results.addAll(notes);
      }

      // Search todo lists if included
      if (query.contentTypes == null ||
          query.contentTypes!.contains(ContentType.todoList)) {
        final todoLists = await _searchTodoLists(query);
        results.addAll(todoLists);
      }

      // Search lists if included
      if (query.contentTypes == null ||
          query.contentTypes!.contains(ContentType.list)) {
        final lists = await _searchLists(query);
        results.addAll(lists);
      }

      // Sort by relevance/updatedAt
      results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return results;
    });
  }

  Future<List<SearchResult>> _searchNotes(SearchQuery query) async {
    var queryBuilder = supabase
        .from('notes')
        .select()
        .eq('user_id', userId);

    // Scope to specific space if provided
    if (query.spaceId != null) {
      queryBuilder = queryBuilder.eq('space_id', query.spaceId!);
    }

    // Use PostgreSQL full-text search (faster than ILIKE)
    if (query.query.isNotEmpty) {
      queryBuilder = queryBuilder.textSearch(
        'fts',  // Full-text search column (tsvector)
        query.query,
        config: 'english',
      );
    }

    // Filter by tags if provided
    if (query.tags != null && query.tags!.isNotEmpty) {
      // PostgreSQL array contains operator
      queryBuilder = queryBuilder.contains('tags', query.tags!);
    }

    final response = await queryBuilder;

    return (response as List)
        .map((json) => Note.fromJson(json as Map<String, dynamic>))
        .map((note) => SearchResult(
              id: note.id,
              type: ContentType.note,
              title: note.title,
              preview: note.content?.substring(0, 100),
              tags: note.tags,
              updatedAt: note.updatedAt,
              content: note,
            ))
        .toList();
  }

  // Similar methods for _searchTodoLists() and _searchLists()
}

// presentation/controllers/search_controller.dart
@riverpod
class SearchController extends _$SearchController {
  Timer? _debounceTimer;

  @override
  Future<List<SearchResult>> build() async {
    // Initially return empty list
    return [];
  }

  /// Performs search with debouncing (waits 300ms after user stops typing)
  Future<void> search(SearchQuery query) async {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Set loading state immediately
    state = const AsyncValue.loading();

    // Debounce: wait 300ms before executing search
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        final service = ref.read(searchServiceProvider);
        final results = await service.search(query);

        if (!ref.mounted) return;
        state = AsyncValue.data(results);
      } on AppError catch (e) {
        ErrorLogger.logError(e, context: 'SearchController.search');
        if (!ref.mounted) return;
        state = AsyncValue.error(e, StackTrace.current);
      }
    });
  }

  /// Clears search results
  void clear() {
    _debounceTimer?.cancel();
    state = const AsyncValue.data([]);
  }
}

// presentation/screens/search_screen.dart
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
  }

  void _performSearch(String query) {
    final currentSpace = ref.read(currentSpaceControllerProvider).valueOrNull;
    final filters = ref.read(searchFiltersControllerProvider);

    ref.read(searchControllerProvider.notifier).search(
      SearchQuery(
        query: query,
        spaceId: currentSpace?.id,
        contentTypes: filters.contentTypes,
        tags: filters.tags,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search notes, tasks, lists...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                ref.read(searchControllerProvider.notifier).clear();
              },
            ),
          ),
          onChanged: _performSearch,
        ),
      ),
      body: Column(
        children: [
          SearchFiltersWidget(),  // Filter chips
          Expanded(
            child: searchResults.when(
              data: (results) {
                if (results.isEmpty) {
                  return EmptySearchState(query: _searchController.text);
                }
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return SearchResultCard(result: results[index]);
                  },
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stack) => ErrorView(error: error as AppError),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Priority:** 🔴 **HIGH PRIORITY** - Essential for productivity app

---

### Approach 2: Extend Existing ContentFilterController

**Description:**
Enhance the existing `ContentFilterController` to include search query state and search execution, without creating a new feature module.

**Pros:**
- **Minimal New Code**: Reuses existing controller
- **Quick Implementation**: Less boilerplate
- **Centralized Filtering**: All filtering logic in one place
- **No New Navigation**: Works within existing HomeScreen

**Cons:**
- **Violates Single Responsibility**: Controller handles both filtering and search
- **Limited Scalability**: Hard to extend with advanced search features
- **Tight Coupling**: Search logic tied to home screen
- **Poor Separation**: Mixes presentation and data access concerns
- **Testing Complexity**: Harder to test search in isolation
- **Not Feature-First**: Doesn't follow app's architecture pattern

**Use Cases:**
- Simple search within home screen only
- Quick prototype for search functionality
- Temporary solution before full search feature

**Implementation Complexity:** Low

**Code Example:**

```dart
// Enhanced content_filter_controller.dart
@riverpod
class ContentFilterController extends _$ContentFilterController {
  String _searchQuery = '';

  @override
  ContentFilter build() {
    return ContentFilter.all;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    ref.notifyListeners();  // Trigger rebuild
  }

  List<dynamic> getFilteredContent(String spaceId) {
    // Existing filtering logic...
    var content = [...todoLists, ...lists, ...notes];

    // Apply search query if present
    if (_searchQuery.isNotEmpty) {
      content = content.where((item) {
        if (item is Note) {
          return item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 (item.content?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        } else if (item is TodoList) {
          return item.name.toLowerCase().contains(_searchQuery.toLowerCase());
        } else if (item is ListModel) {
          return item.name.toLowerCase().contains(_searchQuery.toLowerCase());
        }
        return false;
      }).toList();
    }

    return content;
  }
}
```

**Priority:** 🟡 **LOW PRIORITY** - Not recommended for production

---

### Approach 3: Repository-Level Search Enhancement

**Description:**
Enhance existing repository search methods and expose them through services and controllers, without creating a dedicated search feature.

**Pros:**
- **Leverages Existing Infrastructure**: Uses current repository pattern
- **No New Feature Module**: Minimal architectural changes
- **Gradual Enhancement**: Can improve search incrementally
- **Familiar Pattern**: Developers already understand repository pattern

**Cons:**
- **No Unified Search**: Each repository has separate search method
- **Duplicated Code**: Similar search logic in NoteRepository, TodoListRepository, ListRepository
- **No Cross-Type Search**: Can't search across notes + tasks + lists simultaneously
- **Limited Filtering**: Hard to combine filters across types
- **Poor UX**: User has to search each type separately
- **Doesn't Scale**: Adding new content types requires updating all search logic

**Use Cases:**
- Search within single content type (notes only, tasks only)
- Specialized search for specific use cases
- Backend for dedicated search feature (repositories as data source)

**Implementation Complexity:** Low-Medium

**Code Example:**

```dart
// Enhanced note_repository.dart
Future<List<Note>> advancedSearch({
  required String query,
  String? spaceId,
  List<String>? tags,
}) async {
  return executeQuery(() async {
    var queryBuilder = supabase
        .from('notes')
        .select()
        .eq('user_id', userId);

    if (spaceId != null) {
      queryBuilder = queryBuilder.eq('space_id', spaceId);
    }

    if (query.isNotEmpty) {
      queryBuilder = queryBuilder
          .or('title.ilike.%$query%,content.ilike.%$query%');
    }

    if (tags != null && tags.isNotEmpty) {
      queryBuilder = queryBuilder.contains('tags', tags);
    }

    final response = await queryBuilder.order('updated_at', ascending: false);

    return (response as List)
        .map((json) => Note.fromJson(json as Map<String, dynamic>))
        .toList();
  });
}

// Similar enhanced methods in TodoListRepository and ListRepository
```

**Priority:** 🟢 **MEDIUM PRIORITY** - Good foundation for full search feature

---

## Database Requirements

### Required Schema Changes

```sql
-- Migration: Add full-text search support

-- 1. Add tsvector columns for full-text search
ALTER TABLE notes ADD COLUMN fts tsvector
  GENERATED ALWAYS AS (
    to_tsvector('english', coalesce(title, '') || ' ' || coalesce(content, ''))
  ) STORED;

ALTER TABLE todo_lists ADD COLUMN fts tsvector
  GENERATED ALWAYS AS (
    to_tsvector('english', coalesce(name, '') || ' ' || coalesce(description, ''))
  ) STORED;

ALTER TABLE lists ADD COLUMN fts tsvector
  GENERATED ALWAYS AS (
    to_tsvector('english', name)
  ) STORED;

-- 2. Create GIN indexes for full-text search (massively improves search performance)
CREATE INDEX idx_notes_fts ON notes USING gin(fts);
CREATE INDEX idx_todo_lists_fts ON todo_lists USING gin(fts);
CREATE INDEX idx_lists_fts ON lists USING gin(fts);

-- 3. Create GIN indexes for tag arrays (enables fast tag filtering)
CREATE INDEX idx_notes_tags ON notes USING gin(tags);
-- Note: todo_lists and lists don't have tags yet, add when implementing tag support

-- 4. Add tags to todo_lists and lists (future enhancement)
-- ALTER TABLE todo_lists ADD COLUMN tags TEXT[] DEFAULT '{}';
-- ALTER TABLE lists ADD COLUMN tags TEXT[] DEFAULT '{}';
-- CREATE INDEX idx_todo_lists_tags ON todo_lists USING gin(tags);
-- CREATE INDEX idx_lists_tags ON lists USING gin(tags);

-- 5. Add composite indexes for common query patterns
CREATE INDEX idx_notes_space_updated ON notes(space_id, updated_at DESC);
CREATE INDEX idx_todo_lists_space_updated ON todo_lists(space_id, updated_at DESC);
CREATE INDEX idx_lists_space_updated ON lists(space_id, updated_at DESC);
```

### Performance Implications

**Full-Text Search Indexes (GIN):**
- **Read Performance**: 10-100x faster than ILIKE for text search
- **Write Performance**: Slight overhead when inserting/updating (index must be updated)
- **Storage**: ~20-30% increase in table size for tsvector columns and indexes
- **Maintenance**: PostgreSQL handles automatically, no manual maintenance needed

**Tag Array Indexes (GIN):**
- **Read Performance**: Instant tag lookups (O(1) vs O(n) array scan)
- **Write Performance**: Minimal overhead
- **Storage**: Small increase (depends on number of unique tags)

**Composite Indexes:**
- **Query Optimization**: Speeds up space + date filtering (common pattern)
- **Index Size**: Minimal (only two columns)

**Estimated Impact:**
- Small dataset (< 1,000 items): Negligible difference
- Medium dataset (1,000 - 10,000 items): 5-10x search improvement
- Large dataset (> 10,000 items): 50-100x search improvement

### Query Examples

```sql
-- Full-text search across notes (Supabase API)
SELECT * FROM notes
WHERE fts @@ to_tsquery('english', 'flutter & mobile')
  AND user_id = 'user-123'
ORDER BY updated_at DESC;

-- Tag-based filtering
SELECT * FROM notes
WHERE tags @> ARRAY['work', 'urgent']  -- Contains all tags
  AND user_id = 'user-123';

-- Combined search + tag filter
SELECT * FROM notes
WHERE fts @@ to_tsquery('english', 'meeting')
  AND tags && ARRAY['work']  -- Overlaps with tags
  AND space_id = 'space-456'
  AND user_id = 'user-123';

-- Search across all content types (union query)
SELECT id, 'note' as type, title, updated_at FROM notes
  WHERE fts @@ to_tsquery('english', 'project')
UNION ALL
SELECT id, 'todo_list' as type, name as title, updated_at FROM todo_lists
  WHERE fts @@ to_tsquery('english', 'project')
UNION ALL
SELECT id, 'list' as type, name as title, updated_at FROM lists
  WHERE fts @@ to_tsquery('english', 'project')
ORDER BY updated_at DESC;
```

## Implementation Considerations

### Integration with Feature-First Architecture

**How Search Feature Fits:**

```
features/
├── auth/                  # User authentication
├── home/                  # Main screen (uses search feature)
│   └── uses → search/    # HomeScreen shows search bar, links to SearchScreen
├── lists/                 # Custom lists
├── notes/                 # Notes
├── search/                # ⭐ NEW: Unified search and filter
│   ├── domain/
│   ├── data/
│   ├── application/
│   └── presentation/
├── spaces/                # Space management
├── theme/                 # Theme controller
└── todo_lists/            # Todo lists
```

**Cross-Feature Dependencies:**

1. **Search → Notes/TodoLists/Lists** (data access):
   - SearchRepository uses NoteRepository, TodoListRepository, ListRepository
   - Or SearchRepository directly queries Supabase (bypassing repositories)
   - **Recommendation**: Direct Supabase queries for unified search (avoids circular dependencies)

2. **Home → Search** (navigation):
   - HomeScreen app bar contains search button
   - Tapping search button navigates to SearchScreen
   - HomeScreen can show recent search results or search preview

3. **Search → Spaces** (context):
   - Search respects current space (if user wants space-scoped search)
   - Search can toggle between "current space" and "all spaces"

4. **Search → Theme** (UI):
   - SearchScreen uses design system components
   - Theme-aware colors and gradients

**Provider Architecture:**

```dart
// features/search/data/repositories/providers.dart
@riverpod
SearchRepository searchRepository(SearchRepositoryRef ref) {
  return SearchRepository();
}

// features/search/application/providers.dart
@riverpod
SearchService searchService(SearchServiceRef ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return SearchService(repository: repository);
}

// features/search/presentation/controllers/search_controller.dart
@riverpod
class SearchController extends _$SearchController {
  @override
  Future<List<SearchResult>> build() async {
    return [];
  }

  Future<void> search(SearchQuery query) async {
    // Implementation
  }
}

// Usage in SearchScreen
final searchResults = ref.watch(searchControllerProvider);
```

### Riverpod 3.0 State Management Patterns

**Debouncing Search Input:**

```dart
import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
class SearchController extends _$SearchController {
  Timer? _debounceTimer;

  @override
  Future<List<SearchResult>> build() async {
    // Initial state
    return [];
  }

  /// Search with 300ms debounce
  void search(SearchQuery query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Set loading state immediately for UI feedback
    state = const AsyncValue.loading();

    // Create new debounce timer
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        final service = ref.read(searchServiceProvider);
        final results = await service.search(query);

        // Check if still mounted before updating state (Riverpod 3.0 feature)
        if (!ref.mounted) return;

        state = AsyncValue.data(results);
      } on AppError catch (e) {
        ErrorLogger.logError(e, context: 'SearchController.search');

        if (!ref.mounted) return;
        state = AsyncValue.error(e, StackTrace.current);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
```

**Caching Search Results (Riverpod 3.0 built-in):**

Riverpod 3.0 has automatic caching for providers. To leverage this:

```dart
// Keep results cached for 5 minutes
@Riverpod(keepAlive: true)
class SearchCacheController extends _$SearchCacheController {
  final Map<String, List<SearchResult>> _cache = {};

  @override
  Map<String, List<SearchResult>> build() {
    return {};
  }

  void cacheResults(String query, List<SearchResult> results) {
    _cache[query] = results;
    state = Map.from(_cache);
  }

  List<SearchResult>? getCached(String query) {
    return _cache[query];
  }
}
```

**Search Filters State:**

```dart
@riverpod
class SearchFiltersController extends _$SearchFiltersController {
  @override
  SearchFilters build() {
    return SearchFilters(
      contentTypes: null,  // null = all types
      tags: null,
      dateRange: null,
    );
  }

  void setContentTypes(List<ContentType>? types) {
    state = state.copyWith(contentTypes: types);
  }

  void setTags(List<String>? tags) {
    state = state.copyWith(tags: tags);
  }

  void reset() {
    state = SearchFilters();
  }
}
```

### UI/UX Design Considerations

**Search Bar Placement Options:**

1. **App Bar Integration** (Recommended):
   - Search icon button in HomeScreen app bar
   - Tapping opens SearchScreen with auto-focused search field
   - Similar to iOS Spotlight search pattern

2. **Persistent Search Bar**:
   - Always-visible search bar at top of HomeScreen
   - Tapping expands to full search experience
   - Similar to Gmail mobile app

3. **Floating Search FAB**:
   - Floating Action Button with search icon
   - Secondary to existing "create" FAB
   - Not recommended (too many FABs)

**Search Results Display:**

```dart
class SearchResultCard extends StatelessWidget {
  final SearchResult result;

  @override
  Widget build(BuildContext context) {
    // Use existing card components
    switch (result.type) {
      case ContentType.note:
        return NoteCard(note: result.content as Note);
      case ContentType.todoList:
        return TodoListCard(todoList: result.content as TodoList);
      case ContentType.list:
        return ListCard(list: result.content as ListModel);
    }
  }
}
```

**Filter Chips UI:**

```dart
class SearchFiltersWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(searchFiltersControllerProvider);

    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: 'Notes',
          selected: filters.contentTypes?.contains(ContentType.note) ?? false,
          onSelected: (selected) {
            // Toggle note filter
          },
        ),
        FilterChip(
          label: 'Tasks',
          selected: filters.contentTypes?.contains(ContentType.todoList) ?? false,
          onSelected: (selected) {
            // Toggle task filter
          },
        ),
        FilterChip(
          label: 'Lists',
          selected: filters.contentTypes?.contains(ContentType.list) ?? false,
          onSelected: (selected) {
            // Toggle list filter
          },
        ),
        // Tag filter chips...
      ],
    );
  }
}
```

**Empty States:**

- **No Query**: Show search tips, recent searches, or popular tags
- **No Results**: Use existing `EmptySearchState` widget
- **Loading**: Show skeleton loading for search results

### Testing Strategy

**Unit Tests:**

```dart
// test/features/search/data/repositories/search_repository_test.dart
void main() {
  group('SearchRepository', () {
    late SearchRepository repository;
    late MockSupabaseClient mockSupabase;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      repository = SearchRepository();
      // Inject mock
    });

    test('search returns results for matching notes', () async {
      // Arrange
      when(mockSupabase.from('notes').select()...).thenReturn(...);

      // Act
      final results = await repository.search(
        SearchQuery(query: 'flutter'),
      );

      // Assert
      expect(results, hasLength(2));
      expect(results[0].type, ContentType.note);
    });

    test('search respects space filter', () async {
      // Test space-scoped search
    });

    test('search respects tag filter', () async {
      // Test tag filtering
    });
  });
}
```

**Widget Tests:**

```dart
// test/features/search/presentation/screens/search_screen_test.dart
void main() {
  testWidgets('SearchScreen displays search bar', (tester) async {
    await tester.pumpWidget(
      testApp(SearchScreen()),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Search notes, tasks, lists...'), findsOneWidget);
  });

  testWidgets('SearchScreen shows loading indicator during search', (tester) async {
    // Test loading state
  });

  testWidgets('SearchScreen displays results', (tester) async {
    // Test results rendering
  });

  testWidgets('SearchScreen shows empty state for no results', (tester) async {
    // Test empty state
  });
}
```

**Integration Tests:**

```dart
// integration_test/search_flow_test.dart
void main() {
  testWidgets('Complete search flow', (tester) async {
    // 1. Navigate to search screen
    // 2. Enter search query
    // 3. Wait for debounce
    // 4. Verify results appear
    // 5. Apply filter
    // 6. Verify filtered results
    // 7. Tap result to navigate to detail
  });
}
```

### Performance Optimization

**Database Query Optimization:**

1. **Use Full-Text Search** (not ILIKE):
   ```dart
   // ❌ Slow (scans entire table)
   .or('title.ilike.%$query%,content.ilike.%$query%')

   // ✅ Fast (uses GIN index)
   .textSearch('fts', query, config: 'english')
   ```

2. **Limit Result Count**:
   ```dart
   queryBuilder = queryBuilder.limit(50);  // Paginate results
   ```

3. **Select Only Needed Columns**:
   ```dart
   // ❌ Fetches all columns
   .select()

   // ✅ Fetches only needed columns
   .select('id, title, content, tags, updated_at')
   ```

4. **Use Composite Indexes**:
   ```sql
   -- Speeds up common query pattern
   CREATE INDEX idx_notes_space_updated ON notes(space_id, updated_at DESC);
   ```

**UI Performance:**

1. **Debounce Search Input** (300-500ms):
   - Reduces number of queries
   - Better UX (waits for user to finish typing)

2. **Virtualized List** (already using ListView.builder):
   - Only renders visible items
   - Handles large result sets efficiently

3. **Lazy Loading Images** (if adding image attachments):
   - Use `cached_network_image` package
   - Placeholder while loading

4. **Cancel Previous Requests**:
   ```dart
   // In SearchController
   _debounceTimer?.cancel();  // Cancel previous search
   ```

### Security and Privacy

**Row-Level Security (RLS):**

All search queries must respect existing RLS policies:

```sql
-- Existing RLS policies ensure user can only search their own data
CREATE POLICY "Users can only view their own notes"
  ON notes FOR SELECT
  USING (auth.uid() = user_id);
```

**Search Query Sanitization:**

Supabase handles SQL injection prevention automatically when using `.textSearch()` and `.contains()` methods. No additional sanitization needed.

**Privacy Considerations:**

- Search queries are NOT stored by default (no search history)
- If implementing search history: store locally only (not in database)
- Tag autocomplete: based on user's own tags only (not global tags)

## Recommendations

### Recommended Implementation: Dedicated Search Feature Module

**Primary Recommendation:**

Create `features/search/` with full Clean Architecture following the existing pattern used for auth, notes, spaces, etc.

**Rationale:**

1. **Architectural Consistency**: Matches existing feature-first structure
2. **Scalability**: Easy to extend with advanced features (saved searches, search history, AI-powered search)
3. **Maintainability**: Clear ownership and responsibility for search logic
4. **Testability**: Can be tested in complete isolation
5. **Reusability**: SearchService can be used by other features
6. **Future-Proof**: Room for growth without refactoring

### Implementation Roadmap

**Phase 1: Foundation (Week 1-2)**

1. **Database Migration**:
   - Add tsvector columns and GIN indexes
   - Test full-text search in Supabase Studio
   - Verify performance with test data

2. **Search Feature Module**:
   - Create `features/search/` directory structure
   - Implement domain models (SearchQuery, SearchResult, SearchFilters)
   - Create SearchRepository with direct Supabase queries

3. **Basic Search UI**:
   - SearchScreen with search bar
   - SearchResultCard using existing card components
   - EmptySearchState (already exists)

**Phase 2: Search Functionality (Week 2-3)**

1. **SearchService Layer**:
   - Validation and business logic
   - Error handling with AppError
   - Search query transformation

2. **SearchController (Riverpod 3.0)**:
   - Debounced search (300ms)
   - AsyncValue state management
   - Error handling and logging

3. **Integration with HomeScreen**:
   - Add search icon to app bar
   - Navigation to SearchScreen
   - Pass current space context

**Phase 3: Filtering & Polish (Week 3-4)**

1. **Advanced Filtering**:
   - SearchFiltersController for filter state
   - Filter chips UI (type, tags)
   - Combine multiple filters

2. **Tag System Enhancement**:
   - Add tags to TodoList and ListModel (database migration)
   - Tag autocomplete in search
   - Tag filtering across all content types

3. **Performance Optimization**:
   - Result pagination (load 50, then load more)
   - Query caching with Riverpod 3.0
   - Cancel previous requests

**Phase 4: Testing & Refinement (Week 4)**

1. **Comprehensive Testing**:
   - Unit tests for SearchRepository, SearchService
   - Widget tests for SearchScreen, SearchResultCard
   - Integration tests for complete search flow

2. **UX Refinements**:
   - Keyboard shortcuts for search (desktop)
   - Search result highlighting
   - Recent searches (local storage)

3. **Documentation**:
   - Update CLAUDE.md with search feature
   - Add comments to SearchRepository
   - Document search query syntax

### Alternative Phased Approach (Faster MVP)

If rapid iteration is needed:

**Quick Wins (Week 1)**:
1. Enhance NoteRepository.search() to use full-text search
2. Add search bar to HomeScreen app bar
3. Show inline search results in HomeScreen (filter existing list)

**Full Feature (Week 2-3)**:
1. Create dedicated SearchScreen
2. Implement cross-type search with SearchRepository
3. Add basic filtering (type only)

**Advanced Features (Week 4+)**:
1. Tag-based filtering
2. Advanced filters (date, status)
3. Search suggestions and history

### Success Metrics

**Feature Adoption:**
- 60% of daily active users perform at least one search
- Average 3-5 searches per active user session
- 40% of searches use filters

**Performance:**
- Search query response time < 100ms (with indexes)
- UI debounce delay: 300ms
- Zero search-related errors in production

**User Experience:**
- 80% of searches return relevant results (based on user clicks)
- 30% of users use advanced filters
- Search feature rated 4+ stars in user feedback

## Tools and Libraries

### Option 1: Supabase Flutter SDK (Built-in)

**Purpose:** Full-text search and database queries

**Already Integrated:** ✅ Yes

**Key Features:**
- `.textSearch()` method for full-text search
- `.contains()` method for array filtering (tags)
- `.or()` and `.and()` for complex queries
- Automatic SQL injection prevention

**Usage:**
```dart
final results = await supabase
  .from('notes')
  .select()
  .textSearch('fts', query, config: 'english')
  .contains('tags', ['work'])
  .eq('user_id', userId);
```

**Recommendation:** ✅ **Use this** - already integrated, no new dependencies

---

### Option 2: flutter_riverpod (v3.0)

**Purpose:** State management for search controller

**Already Integrated:** ✅ Yes (3.0.3)

**Key Features:**
- `@riverpod` code generation for controllers
- AsyncValue for loading/error states
- Automatic caching and disposal
- Built-in retry mechanism

**Recommendation:** ✅ **Use this** - already using Riverpod 3.0

---

### Option 3: rxdart (for advanced debouncing)

**Purpose:** Advanced stream operations and debouncing

**Maturity:** Production-ready

**License:** Apache 2.0

**Community:** Very active

**Integration Effort:** Low

**Key Features:**
- Advanced debouncing with `debounceTime()`
- Stream transformations
- Combine multiple streams

**Usage:**
```dart
final searchStream = StreamController<String>();

searchStream.stream
  .debounceTime(Duration(milliseconds: 300))
  .listen((query) {
    // Perform search
  });
```

**Recommendation:** 🟡 **Optional** - Dart Timer is sufficient for basic debouncing

---

### Option 4: flutter_typeahead (for autocomplete)

**Purpose:** Autocomplete suggestions for search

**Maturity:** Production-ready

**License:** MIT

**Community:** Active

**Integration Effort:** Medium

**Key Features:**
- Autocomplete dropdown
- Custom suggestion builders
- Debouncing built-in

**Recommendation:** 🟢 **Future Enhancement** - Not needed for MVP

---

### Option 5: searchfield (search field widget)

**Purpose:** Pre-built search field widget

**Maturity:** Production-ready

**License:** MIT

**Integration Effort:** Low

**Key Features:**
- Search suggestions
- Custom styling
- Built-in animations

**Recommendation:** 🔴 **Skip** - Better to use TextField with custom design system

---

## References

### Documentation Sources
- Later App CLAUDE.md (project documentation)
- Later App next-features-roadmap.md (research foundation)
- Supabase Full-Text Search Docs: https://supabase.com/docs/guides/database/full-text-search
- Flutter Riverpod 3.0 API Reference: https://pub.dev/packages/riverpod
- PostgreSQL Full-Text Search: https://www.postgresql.org/docs/current/textsearch.html

### Articles and Resources
- "Flutter Project Structure: Feature-first or Layer-first?" (Code with Andrea)
- "Mastering Riverpod 3.0: The Ultimate Flutter State Management Guide" (Medium)
- "Supabase Flutter SDK Reference" (Official Docs)
- "Flutter Pagination with Riverpod: The Ultimate Guide" (Code with Andrea)
- "Full Text Search – Flutter Community" (Medium)

### Code Examples
- Later app existing feature modules (auth, notes, spaces, lists, todo_lists)
- NoteRepository.search() implementation
- ContentFilterController pattern
- SearchScreen widget (to be created)

### Internal Documentation
- `/Users/jonascurth/later/apps/later_mobile/lib/features/` - existing feature modules
- `/Users/jonascurth/later/supabase/migrations/` - database schema
- `/Users/jonascurth/later/apps/later_mobile/lib/design_system/` - design components

## Appendix

### Feature Module Structure Template

For reference when creating the search feature:

```
features/search/
├── domain/
│   └── models/
│       ├── search_query.dart           # Search parameters
│       ├── search_result.dart          # Unified result type
│       ├── search_filters.dart         # Filter configuration
│       └── content_type.dart           # Enum for note/todoList/list
├── data/
│   ├── repositories/
│   │   ├── search_repository.dart      # Data access
│   │   └── providers.dart              # Riverpod providers
│   └── mappers/
│       └── search_result_mapper.dart   # Map content types to SearchResult
├── application/
│   ├── services/
│   │   └── search_service.dart         # Business logic
│   └── providers.dart                  # Riverpod providers
└── presentation/
    ├── controllers/
    │   ├── search_controller.dart           # Main search state (with debouncing)
    │   ├── search_filters_controller.dart   # Filter state
    │   └── search_suggestions_controller.dart  # Autocomplete suggestions (future)
    ├── screens/
    │   └── search_screen.dart               # Full-screen search UI
    └── widgets/
        ├── search_bar_widget.dart           # Search input field
        ├── search_filters_widget.dart       # Filter chips
        ├── search_result_card.dart          # Result item display
        ├── search_suggestions_widget.dart   # Autocomplete dropdown (future)
        └── search_empty_state.dart          # No results view (already exists in design_system)
```

### Supabase Full-Text Search Quick Reference

**Basic Search:**
```dart
await supabase
  .from('notes')
  .select()
  .textSearch('fts', 'flutter mobile');
```

**AND Search:**
```dart
.textSearch('fts', 'flutter & mobile')  // Both words must appear
```

**OR Search:**
```dart
.textSearch('fts', 'flutter | mobile')  // Either word can appear
```

**Phrase Search:**
```dart
.textSearch('fts', "'flutter mobile'")  // Exact phrase
```

**Prefix Search:**
```dart
.textSearch('fts', 'flut:*')  // Words starting with 'flut'
```

**With Filters:**
```dart
await supabase
  .from('notes')
  .select()
  .textSearch('fts', query)
  .eq('space_id', spaceId)
  .contains('tags', ['work']);
```

### Sample SearchQuery Configurations

```dart
// 1. Simple text search (all content, all spaces)
SearchQuery(query: 'flutter');

// 2. Search within current space only
SearchQuery(
  query: 'meeting notes',
  spaceId: currentSpace.id,
);

// 3. Search specific content type
SearchQuery(
  query: 'project',
  contentTypes: [ContentType.todoList],
);

// 4. Tag-based search (no text query)
SearchQuery(
  query: '',
  tags: ['work', 'urgent'],
);

// 5. Advanced combined search
SearchQuery(
  query: 'flutter',
  contentTypes: [ContentType.note, ContentType.todoList],
  tags: ['work'],
  spaceId: currentSpace.id,
);

// 6. Date range search (future enhancement)
SearchQuery(
  query: '',
  dateRange: DateRange(
    start: DateTime.now().subtract(Duration(days: 7)),
    end: DateTime.now(),
  ),
);
```

### Keyboard Shortcuts (Future Enhancement)

For desktop/web versions, consider adding keyboard shortcuts:

- **Cmd/Ctrl + K**: Open search
- **Cmd/Ctrl + F**: Focus search bar
- **Escape**: Clear search / close search screen
- **Enter**: Navigate to first result
- **Arrow keys**: Navigate between results

### Migration Script Example

```sql
-- File: supabase/migrations/20251117000000_add_search_indexes.sql

-- Add full-text search columns to notes
ALTER TABLE notes ADD COLUMN fts tsvector
  GENERATED ALWAYS AS (
    to_tsvector('english', coalesce(title, '') || ' ' || coalesce(content, ''))
  ) STORED;

-- Add full-text search columns to todo_lists
ALTER TABLE todo_lists ADD COLUMN fts tsvector
  GENERATED ALWAYS AS (
    to_tsvector('english', coalesce(name, '') || ' ' || coalesce(description, ''))
  ) STORED;

-- Add full-text search columns to lists
ALTER TABLE lists ADD COLUMN fts tsvector
  GENERATED ALWAYS AS (
    to_tsvector('english', name)
  ) STORED;

-- Create GIN indexes for full-text search
CREATE INDEX idx_notes_fts ON notes USING gin(fts);
CREATE INDEX idx_todo_lists_fts ON todo_lists USING gin(fts);
CREATE INDEX idx_lists_fts ON lists USING gin(fts);

-- Create GIN index for notes tags (already has tags column)
CREATE INDEX idx_notes_tags ON notes USING gin(tags);

-- Add composite indexes for common query patterns
CREATE INDEX idx_notes_space_updated ON notes(space_id, updated_at DESC);
CREATE INDEX idx_todo_lists_space_updated ON todo_lists(space_id, updated_at DESC);
CREATE INDEX idx_lists_space_updated ON lists(space_id, updated_at DESC);

-- Test the indexes
EXPLAIN ANALYZE
SELECT * FROM notes
WHERE fts @@ to_tsquery('english', 'flutter')
  AND user_id = 'test-user-id'
ORDER BY updated_at DESC;
```

### Localization Strings for Search

Add to `lib/l10n/app_en.arb`:

```json
{
  "searchBarHint": "Search notes, tasks, lists...",
  "searchScreenTitle": "Search",
  "searchEmptyTitle": "No results found",
  "searchEmptyMessage": "Try different keywords or adjust filters",
  "searchFilterAll": "All",
  "searchFilterNotes": "Notes",
  "searchFilterTasks": "Tasks",
  "searchFilterLists": "Lists",
  "searchFilterTags": "Tags",
  "searchResultsCount": "{count, plural, =0{No results} =1{1 result} other{{count} results}}",
  "searchClearButton": "Clear",
  "searchInCurrentSpace": "Search in {spaceName}",
  "searchInAllSpaces": "Search everywhere"
}
```

Add to `lib/l10n/app_de.arb`:

```json
{
  "searchBarHint": "Notizen, Aufgaben, Listen durchsuchen...",
  "searchScreenTitle": "Suchen",
  "searchEmptyTitle": "Keine Ergebnisse gefunden",
  "searchEmptyMessage": "Versuchen Sie andere Suchbegriffe oder passen Sie die Filter an",
  "searchFilterAll": "Alle",
  "searchFilterNotes": "Notizen",
  "searchFilterTasks": "Aufgaben",
  "searchFilterLists": "Listen",
  "searchFilterTags": "Tags",
  "searchResultsCount": "{count, plural, =0{Keine Ergebnisse} =1{1 Ergebnis} other{{count} Ergebnisse}}",
  "searchClearButton": "Löschen",
  "searchInCurrentSpace": "In {spaceName} suchen",
  "searchInAllSpaces": "Überall suchen"
}
```

---

## Conclusion

Based on comprehensive analysis of the Later app architecture and industry best practices for 2025, **integrating a dedicated search feature module is the recommended approach**. This provides:

### Must-Have Features (Immediate Implementation)
1. **Unified Search Across Content Types** - Search notes, todo lists, and lists simultaneously
2. **Full-Text Search with PostgreSQL** - Fast, indexed search using Supabase's built-in capabilities
3. **Content Type Filtering** - Filter results by note/task/list
4. **Space-Scoped Search** - Search within current space or across all spaces
5. **Debounced Search Input** - 300ms delay for better UX and performance

### High-Value Enhancements (Phase 2)
6. **Tag-Based Filtering** - Add tags to all content types and enable tag search
7. **Advanced Filters** - Combine multiple filters (type + tag + date range)
8. **Search Result Highlighting** - Highlight matching text in results
9. **Recent Searches** - Show recently searched queries (local storage)

### Future Differentiators (Phase 3+)
10. **Saved Searches** - Save commonly used search queries
11. **Search Suggestions** - Autocomplete based on content
12. **Fuzzy Search** - Handle typos and similar words
13. **AI-Powered Search** - Natural language queries ("tasks due this week")

**Recommended Implementation Order:**
1. **Week 1-2**: Database indexes + SearchRepository + Basic SearchScreen
2. **Week 2-3**: SearchController with debouncing + HomeScreen integration
3. **Week 3-4**: Advanced filtering + Tag system + Testing
4. **Week 4+**: Performance optimization + UX refinements + Documentation

This roadmap positions Later as a competitive productivity app with robust search capabilities while maintaining clean architecture and leveraging existing infrastructure (Supabase, Riverpod 3.0, design system). The feature-first approach ensures the search feature is maintainable, testable, and scalable for future enhancements.
