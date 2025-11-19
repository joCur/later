# Research: Nested Todo Items and List Items Implementation

## Executive Summary

This research analyzes how to implement nested (hierarchical) todo items and list items in the Later app, addressing nesting depth limits, full-text search integration, UI/UX navigation patterns, and technical considerations. Based on industry analysis and technical constraints, the recommendation is to implement **3-level nesting** (parent → child → grandchild) using an **adjacency list pattern** with self-referential foreign keys.

**Key Recommendations:**
- **Maximum Nesting Depth**: 3 levels (current item + 2 nested levels)
- **Database Pattern**: Adjacency list with `parent_id` self-referential foreign key
- **Search Integration**: Include nested items in search with parent context/breadcrumbs
- **UI Pattern**: Expandable/collapsible lists with indentation (16px per level)
- **Performance**: Use recursive CTEs with depth counter, implement lazy loading for deep hierarchies

**Why 3 Levels?**
- Industry standard (Toodledo: Folder→Task→Subtask, most apps support 2-4 levels)
- Balances flexibility with usability (deeper nesting causes cognitive overload)
- Good performance characteristics for recursive queries
- Prevents "nested-doll navigation" anti-pattern on mobile
- Reduces risk of users "losing" deeply nested items

## Research Scope

### What Was Researched
- Current database schema for `todo_items` and `list_items` tables
- Industry best practices for nested task implementations (Todoist, Asana, Toodledo)
- Nesting depth recommendations from UX research and productivity apps
- Database patterns for hierarchical data (adjacency list, closure table, ltree)
- PostgreSQL recursive CTE performance and optimization techniques
- Full-text search strategies for nested/hierarchical data
- Flutter UI patterns for expandable tree views and nested lists
- Mobile UX best practices for indentation, collapse/expand interactions
- Performance implications for search indexing with nested structures

### What Was Explicitly Excluded
- Unlimited/infinite nesting (rejected due to UX and performance concerns)
- Cross-references between items (e.g., linking todo items across different lists)
- Moving items between parents via drag-and-drop (future enhancement)
- Nested notes (notes remain flat - only todo items and list items support nesting)
- Collaborative editing of nested structures (out of scope for MVP)
- Real-time collaboration conflict resolution for nested items

### Research Methodology
- Codebase analysis (database schema, models, repositories, controllers)
- Web research on nested task implementations (2025 best practices)
- Industry app analysis (Todoist, Asana, Toodledo, Amplenote, MyLifeOrganized)
- PostgreSQL recursive query performance research
- Flutter tree view package research (animated_tree_view, expansion_tile patterns)
- Mobile UX pattern research (Nielsen Norman Group, Smashing Magazine)
- Full-text search integration analysis with hierarchical data

## Current State Analysis

### Existing Database Schema

**todo_items table** (from `20251103230632_initial_schema.sql`):
```sql
CREATE TABLE todo_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    todo_list_id UUID REFERENCES todo_lists(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    is_completed BOOLEAN DEFAULT false NOT NULL,
    due_date TIMESTAMPTZ,
    priority TEXT,
    tags TEXT[],
    sort_order INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);
```

**list_items table** (from `20251103230632_initial_schema.sql`):
```sql
CREATE TABLE list_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    list_id UUID REFERENCES lists(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    notes TEXT,
    is_checked BOOLEAN DEFAULT false NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);
```

**Current Structure:**
- Flat hierarchy: items belong to their parent list/todo_list
- No self-referential foreign keys (no nesting support)
- `sort_order` used for manual ordering within parent

### Existing Model Structure

**TodoItem model** (from `todo_item.dart`):
- Fields: `id`, `todoListId`, `title`, `description`, `isCompleted`, `dueDate`, `priority`, `tags`, `sortOrder`
- JSON serialization with Supabase compatibility
- No children/parent references

**ListItem model** (from `list_item_model.dart`):
- Fields: `id`, `listId`, `title`, `notes`, `isChecked`, `sortOrder`
- JSON serialization with Supabase compatibility
- No children/parent references

**Key Observations:**
1. Current models are flat (no nesting)
2. Both use `sortOrder` for manual ordering
3. Clean separation between TodoItem and ListItem
4. Both have foreign keys to parent containers (todo_list_id, list_id)

### Existing Controllers and Repositories

**TodoItemsController** (`todo_items_controller.dart`):
- Family provider scoped by `listId`: `todoItemsControllerProvider(listId)`
- CRUD operations: `createItem`, `updateItem`, `deleteItem`, `toggleCompletion`, `reorderItems`
- Invalidates parent `TodoListsController` on changes to refresh counts
- Uses `TodoListService` for business logic

**ListItemsController** (`list_items_controller.dart`):
- Family provider scoped by `listId`: `listItemsControllerProvider(listId)`
- CRUD operations: `createItem`, `updateItem`, `deleteItem`, `toggleCheck`, `reorderItems`
- Invalidates parent `ListsController` on changes to refresh counts
- Uses `ListService` for business logic

**Repositories:**
- `TodoListRepository` - handles database operations for todo items
- `ListRepository` - handles database operations for list items
- Both extend `BaseRepository` with Supabase client access
- Error handling with centralized `AppError` system

### Planned Search Feature Integration

**From search-feature-implementation.md:**
- Full-text search planned for notes, todo lists, lists, todo items, list items
- PostgreSQL GIN indexes on `fts` tsvector columns
- German language configuration for stemming
- Space-scoped search (current space only)
- Child item search with parent context (JOIN queries planned)

**Relevant search queries (from plan):**
```sql
-- Todo items with parent list name
SELECT ti.*, tl.name
FROM todo_items ti
JOIN todo_lists tl ON ti.todo_list_id = tl.id
WHERE ti.fts @@ to_tsquery('german', 'test')

-- List items with parent list name
SELECT li.*, l.name
FROM list_items li
JOIN lists l ON li.list_id = l.id
WHERE li.fts @@ to_tsquery('german', 'test')
```

**Challenge:** Search plan assumes flat structure - needs revision for nested items.

## Technical Analysis

### Approach 1: Adjacency List Pattern

**Description:** Add a self-referential `parent_id` foreign key to each table, allowing items to reference their parent item. This is the simplest hierarchical pattern.

**Database Changes:**
```sql
-- Add parent_id column to todo_items
ALTER TABLE todo_items
ADD COLUMN parent_id UUID REFERENCES todo_items(id) ON DELETE CASCADE;

-- Add parent_id column to list_items
ALTER TABLE list_items
ADD COLUMN parent_id UUID REFERENCES list_items(id) ON DELETE CASCADE;

-- Add indexes for performance
CREATE INDEX idx_todo_items_parent_id ON todo_items(parent_id);
CREATE INDEX idx_list_items_parent_id ON list_items(parent_id);

-- Add constraint to prevent deep nesting (3 levels max)
-- This requires a function/trigger to check depth
```

**Model Changes:**
```dart
class TodoItem {
  final String id;
  final String todoListId;
  final String? parentId;  // NEW: null for root items
  final String title;
  // ... other fields
}
```

**Query Pattern (get children):**
```sql
SELECT * FROM todo_items
WHERE parent_id = :parent_id
ORDER BY sort_order;
```

**Query Pattern (get full tree with recursive CTE):**
```sql
WITH RECURSIVE item_tree AS (
  -- Base case: root items (no parent)
  SELECT *, 1 as depth, ARRAY[id] as path
  FROM todo_items
  WHERE parent_id IS NULL AND todo_list_id = :list_id

  UNION ALL

  -- Recursive case: children
  SELECT ti.*, it.depth + 1, it.path || ti.id
  FROM todo_items ti
  INNER JOIN item_tree it ON ti.parent_id = it.id
  WHERE ti.depth < 3  -- Limit to 3 levels
)
SELECT * FROM item_tree ORDER BY path;
```

**Pros:**
- ✅ Simple to implement and understand
- ✅ Easy to add/update/delete individual nodes
- ✅ Minimal storage overhead (one extra UUID column)
- ✅ Direct relationship representation
- ✅ Works well with existing architecture
- ✅ Native support in PostgreSQL with recursive CTEs
- ✅ Compatible with Supabase client library

**Cons:**
- ❌ Queries for full tree require recursive CTEs (slightly slower)
- ❌ Getting all descendants requires recursion
- ❌ Depth limit enforcement requires trigger or application logic
- ❌ Moving subtrees requires updating all descendant foreign keys

**Use Cases:**
- Best for read-heavy workloads with occasional tree queries
- When depth is limited (3-4 levels)
- When tree structure changes infrequently
- When simplicity is more important than query performance

**Code Example (Repository Method):**
```dart
// Get root items for a list
Future<List<TodoItem>> getRootItems(String listId) async {
  final response = await supabase
      .from('todo_items')
      .select()
      .eq('todo_list_id', listId)
      .is_('parent_id', null)
      .order('sort_order');

  return (response as List).map((json) => TodoItem.fromJson(json)).toList();
}

// Get children of a specific item
Future<List<TodoItem>> getChildren(String parentId) async {
  final response = await supabase
      .from('todo_items')
      .select()
      .eq('parent_id', parentId)
      .order('sort_order');

  return (response as List).map((json) => TodoItem.fromJson(json)).toList();
}

// Get full tree (requires RPC call or client-side recursion)
Future<List<TodoItem>> getFullTree(String listId) async {
  // Option 1: Client-side recursion (simpler, more HTTP requests)
  final roots = await getRootItems(listId);
  for (final root in roots) {
    await _loadChildrenRecursive(root, 0);
  }
  return roots;

  // Option 2: Server-side recursive CTE (faster, single query)
  // Would require creating a PostgreSQL function
}
```

### Approach 2: Closure Table Pattern

**Description:** Maintain a separate table that stores all ancestor-descendant relationships. This denormalizes the hierarchy for faster queries but requires more storage and complex writes.

**Database Changes:**
```sql
-- Create closure table for todo_items
CREATE TABLE todo_item_paths (
  ancestor_id UUID REFERENCES todo_items(id) ON DELETE CASCADE,
  descendant_id UUID REFERENCES todo_items(id) ON DELETE CASCADE,
  depth INTEGER NOT NULL,
  PRIMARY KEY (ancestor_id, descendant_id)
);

-- Create closure table for list_items
CREATE TABLE list_item_paths (
  ancestor_id UUID REFERENCES list_items(id) ON DELETE CASCADE,
  descendant_id UUID REFERENCES list_items(id) ON DELETE CASCADE,
  depth INTEGER NOT NULL,
  PRIMARY KEY (ancestor_id, descendant_id)
);

-- Add indexes
CREATE INDEX idx_todo_item_paths_descendant ON todo_item_paths(descendant_id);
CREATE INDEX idx_list_item_paths_descendant ON list_item_paths(descendant_id);
```

**Example Data:**
```
For hierarchy: A → B → C

todo_item_paths:
ancestor_id | descendant_id | depth
------------|---------------|------
A           | A             | 0     (self-reference)
A           | B             | 1
A           | C             | 2
B           | B             | 0     (self-reference)
B           | C             | 1
C           | C             | 0     (self-reference)
```

**Query Pattern (get all descendants):**
```sql
SELECT ti.*
FROM todo_items ti
JOIN todo_item_paths p ON ti.id = p.descendant_id
WHERE p.ancestor_id = :item_id
ORDER BY p.depth, ti.sort_order;
```

**Pros:**
- ✅ Excellent read performance (no recursion needed)
- ✅ Fast subtree queries (single JOIN)
- ✅ Fast ancestor queries (single JOIN)
- ✅ Depth information readily available

**Cons:**
- ❌ Complex to maintain (triggers required for INSERT/UPDATE/DELETE)
- ❌ Higher storage requirements (O(n²) in worst case)
- ❌ More difficult to implement correctly
- ❌ Overkill for simple 3-level hierarchy
- ❌ Complexity increases with depth
- ❌ Harder to reason about and debug

**Use Cases:**
- Very deep hierarchies (5+ levels)
- Read-heavy workloads with frequent subtree queries
- When query performance is critical
- When storage is not a constraint

**Assessment:** **NOT RECOMMENDED** for Later app - the complexity outweighs benefits for a 3-level hierarchy.

### Approach 3: PostgreSQL ltree Extension

**Description:** Use PostgreSQL's `ltree` extension which provides a specialized data type for hierarchical tree-like structures. Labels are represented as paths like `root.child.grandchild`.

**Database Changes:**
```sql
-- Enable ltree extension
CREATE EXTENSION IF NOT EXISTS ltree;

-- Add path column to todo_items
ALTER TABLE todo_items ADD COLUMN path ltree;

-- Add GiST index for ltree queries
CREATE INDEX idx_todo_items_path ON todo_items USING GIST (path);
```

**Path Format:**
```
root_item_id
root_item_id.child_item_id
root_item_id.child_item_id.grandchild_item_id
```

**Query Pattern:**
```sql
-- Get all descendants
SELECT * FROM todo_items WHERE path <@ 'root_id';

-- Get direct children only
SELECT * FROM todo_items WHERE path ~ 'root_id.*{1}';

-- Get items at specific depth
SELECT * FROM todo_items WHERE nlevel(path) = 3;
```

**Pros:**
- ✅ Optimized for hierarchical queries
- ✅ Built-in operators for tree operations
- ✅ Good performance with GiST indexes
- ✅ Automatic depth tracking with `nlevel()`
- ✅ Path-based queries are intuitive

**Cons:**
- ❌ Requires Supabase to enable ltree extension (may not be available)
- ❌ Path must be maintained on updates
- ❌ Moving nodes requires path recalculation
- ❌ Limited Flutter/Dart support (no native ltree parsing)
- ❌ Path length limits (up to 65535 labels)
- ❌ Less familiar to developers

**Use Cases:**
- Deep hierarchies with complex path-based queries
- When extension is available and supported
- When path-based operations are common

**Assessment:** **NOT RECOMMENDED** for Later app - adds external dependency, limited Supabase support, and overkill for simple 3-level hierarchy.

### Approach 4: Materialized Path (String-Based)

**Description:** Similar to ltree but using a simple VARCHAR column to store the path. Each item stores the full path from root to itself using a delimiter.

**Database Changes:**
```sql
-- Add path column
ALTER TABLE todo_items ADD COLUMN path VARCHAR(1000);

-- Example paths
-- root: "/item-id/"
-- child: "/parent-id/item-id/"
-- grandchild: "/grandparent-id/parent-id/item-id/"

-- Add index
CREATE INDEX idx_todo_items_path ON todo_items(path);
```

**Query Pattern:**
```sql
-- Get all descendants
SELECT * FROM todo_items WHERE path LIKE '/root-id/%';

-- Get direct children
SELECT * FROM todo_items
WHERE path LIKE '/root-id/%'
  AND path NOT LIKE '/root-id/%/%';
```

**Pros:**
- ✅ Simple to implement
- ✅ No extensions required
- ✅ Fast subtree queries with index
- ✅ Easy to parse in application code

**Cons:**
- ❌ Path must be maintained manually
- ❌ Path length limitations
- ❌ Moving nodes requires path recalculation for all descendants
- ❌ LIKE queries less efficient than specialized indexes
- ❌ More complex update logic

**Assessment:** Viable alternative but adjacency list is simpler for our use case.

## Tools and Libraries

### Flutter Packages for Tree Views

#### Option 1: animated_tree_view

- **Purpose**: Animated TreeView for displaying hierarchical data with expand/collapse
- **Maturity**: Production-ready (actively maintained, 100+ stars)
- **License**: MIT
- **Community**: Small but active, good documentation
- **Integration Effort**: Medium
- **Key Features**:
  - Animated expand/collapse transitions
  - Infinite nesting support
  - Customizable node widgets
  - Lazy loading support
  - Built on Flutter's AnimatedList
  - Performance optimized with O(n) traversal for Map variant

**Example Usage:**
```dart
TreeView<TodoItem>(
  tree: tree,
  builder: (context, node) {
    return TodoItemCard(item: node.data);
  },
  onItemTap: (item) {
    // Handle tap
  },
);
```

**Pros:**
- ✅ Smooth animations out of the box
- ✅ Good performance for medium-sized trees
- ✅ Customizable appearance

**Cons:**
- ❌ External dependency
- ❌ Requires data transformation to tree structure
- ❌ May be overkill for 3-level hierarchy

#### Option 2: ExpansionTile (Flutter Built-in)

- **Purpose**: Built-in Flutter widget for expandable list items
- **Maturity**: Production-ready (part of Flutter SDK)
- **License**: BSD (Flutter license)
- **Community**: Large (Flutter community)
- **Integration Effort**: Low
- **Key Features**:
  - Native Flutter widget
  - Simple expand/collapse
  - Customizable leading/trailing widgets
  - Built-in animations
  - No external dependencies

**Example Usage:**
```dart
ExpansionTile(
  title: Text(todoItem.title),
  children: [
    for (final child in childItems)
      Padding(
        padding: EdgeInsets.only(left: 16.0),
        child: TodoItemCard(item: child),
      ),
  ],
);
```

**Pros:**
- ✅ No external dependencies
- ✅ Simple to implement
- ✅ Familiar to Flutter developers
- ✅ Good performance
- ✅ Built-in animations

**Cons:**
- ❌ Manual nesting of ExpansionTiles for deep hierarchies
- ❌ Less sophisticated than specialized tree packages
- ❌ Requires manual indentation handling

**Recommendation:** Start with **ExpansionTile** for MVP, migrate to animated_tree_view if needed later.

#### Option 3: Custom Implementation with ListView.builder

- **Purpose**: Build custom expandable list with full control
- **Maturity**: N/A (custom code)
- **Integration Effort**: Medium-High
- **Key Features**:
  - Complete customization
  - Optimal performance tuning
  - No external dependencies

**Pros:**
- ✅ Full control over appearance and behavior
- ✅ No external dependencies
- ✅ Can optimize for specific use case

**Cons:**
- ❌ More development time
- ❌ Need to handle expand/collapse state
- ❌ Need to implement animations

**Recommendation:** Only if ExpansionTile doesn't meet requirements.

## Implementation Considerations

### Technical Requirements

#### Database Requirements

1. **Schema Migration:**
   - Add `parent_id` column to `todo_items` table (nullable UUID, foreign key to self)
   - Add `parent_id` column to `list_items` table (nullable UUID, foreign key to self)
   - Add indexes on `parent_id` columns for JOIN performance
   - Add triggers/constraints to enforce 3-level depth limit
   - Add `ON DELETE CASCADE` to ensure children are deleted when parent is deleted

2. **Migration Strategy:**
   - Create new migration file: `YYYYMMDDHHMMSS_add_nested_items_support.sql`
   - Existing data unaffected (parent_id will be NULL for all existing items = root items)
   - No data migration needed
   - Backward compatible (existing code will still work)

3. **Depth Limit Enforcement:**
   ```sql
   -- PostgreSQL function to check depth
   CREATE OR REPLACE FUNCTION check_item_depth()
   RETURNS TRIGGER AS $$
   DECLARE
     current_depth INTEGER := 0;
     current_parent UUID;
   BEGIN
     current_parent := NEW.parent_id;

     -- Traverse up the tree to count depth
     WHILE current_parent IS NOT NULL AND current_depth < 3 LOOP
       current_depth := current_depth + 1;

       SELECT parent_id INTO current_parent
       FROM todo_items
       WHERE id = current_parent;
     END LOOP;

     -- If we found a parent after 3 levels, depth is too deep
     IF current_depth >= 3 AND current_parent IS NOT NULL THEN
       RAISE EXCEPTION 'Maximum nesting depth of 3 levels exceeded';
     END IF;

     RETURN NEW;
   END;
   $$ LANGUAGE plpgsql;

   -- Create trigger
   CREATE TRIGGER enforce_todo_item_depth
   BEFORE INSERT OR UPDATE OF parent_id ON todo_items
   FOR EACH ROW EXECUTE FUNCTION check_item_depth();
   ```

4. **Search Index Updates:**
   - Existing `fts` tsvector columns work as-is
   - GIN indexes still apply
   - JOIN queries need adjustment to include parent context

#### Performance Implications

1. **Query Performance:**
   - Fetching root items: Same as current (WHERE parent_id IS NULL)
   - Fetching children: Additional JOIN, but indexed (fast)
   - Fetching full tree: Recursive CTE (slower, but acceptable for 3 levels)
   - Recommendation: Lazy load children (only load when expanded)

2. **Full-Text Search Performance:**
   - Search query unchanged (still scans all items)
   - Need to JOIN to get parent context (adds ~10-20ms overhead)
   - GIN indexes still apply (fast search)
   - Result formatting needs parent breadcrumb (additional query or JOIN)

3. **UI Rendering Performance:**
   - ExpansionTile: Efficient for collapsed items (children not built)
   - Expanding multiple levels: Manageable for 3 levels
   - Recommendation: Limit initially expanded items (e.g., show only root level)

4. **Memory Considerations:**
   - Model size increases (add parent_id field, ~8 bytes per item)
   - Controller may need to cache tree structure
   - Recommendation: Use lazy loading, don't load full tree eagerly

#### Scalability Considerations

1. **Item Count:**
   - With 3-level limit, worst case: 1 root → 100 children → 100 grandchildren = 10,101 items per list
   - More realistic: 10 roots × 5 children × 3 grandchildren = 160 items per list
   - Recommendation: Monitor list item count, warn users at 500+ items

2. **Database Growth:**
   - Additional UUID column: +16 bytes per item
   - Additional index: O(n log n) space
   - Negligible impact for expected item counts

3. **Network Payload:**
   - Fetching root items only: Same as current
   - Fetching full tree: Larger payload (include all descendants)
   - Recommendation: Lazy load children to minimize payload

#### Security Aspects

1. **Row-Level Security (RLS):**
   - Existing RLS policies apply (user_id based)
   - Ensure parent and child belong to same user (validation in application layer)
   - Prevent cross-user parent references

2. **Data Integrity:**
   - Foreign key constraint ensures parent exists
   - ON DELETE CASCADE ensures orphaned children are removed
   - Depth trigger prevents excessive nesting

3. **Validation:**
   - Validate parent_id belongs to same todo_list_id/list_id
   - Validate parent_id is not the item's own id (prevent self-reference cycles)
   - Validate user owns parent item

4. **Migration Safety:**
   - Migration is additive (no data loss risk)
   - Existing items become root items (parent_id = NULL)
   - Rollback: Just drop parent_id column and indexes

### Integration Points

#### How It Fits with Existing Architecture

1. **Domain Models:**
   ```dart
   class TodoItem {
     final String id;
     final String todoListId;
     final String? parentId;  // NEW: nullable, null = root item
     final String title;
     // ... existing fields
   }
   ```

2. **Repositories:**
   - Add methods: `getRootItems(listId)`, `getChildren(parentId)`, `getItemWithChildren(itemId)`
   - Update methods: `createItem()` accepts optional parentId
   - Validation: Check depth before creating nested item

3. **Services:**
   - Add business logic for nesting rules
   - Validate parent belongs to same list
   - Calculate depth for UI display

4. **Controllers:**
   - Update `TodoItemsController` to support hierarchical loading
   - Add expand/collapse state management
   - Implement lazy loading for children

5. **UI Components:**
   - Modify `TodoItemCard` to support expand/collapse
   - Add indentation based on depth
   - Add visual indicators for parent/child relationships

#### Required Modifications

**Database:**
- ✅ Create migration to add `parent_id` columns
- ✅ Add indexes and triggers
- ✅ Test migration on local Supabase

**Models:**
- ✅ Add `parentId` field to `TodoItem` model
- ✅ Add `parentId` field to `ListItem` model
- ✅ Update `fromJson` and `toJson` methods
- ✅ Add `depth` computed property (requires parent lookup)

**Repositories:**
- ✅ Add `getRootItems(String listId)` method
- ✅ Add `getChildren(String parentId)` method
- ✅ Add `getItemWithDepth(String itemId)` method
- ✅ Update `createItem()` to accept optional `parentId`
- ✅ Update `deleteItem()` to handle cascade (already handled by DB)
- ✅ Add validation for parent references

**Services:**
- ✅ Add `createChildItem(String parentId, ...)` method
- ✅ Add validation: parent exists, depth limit, same list
- ✅ Add `moveItem(String itemId, String? newParentId)` method (future)
- ✅ Add `getItemDepth(String itemId)` helper

**Controllers:**
- ✅ Add `expandedItemIds` state (Set<String>) to track expanded items
- ✅ Add `toggleExpanded(String itemId)` method
- ✅ Add `loadChildren(String parentId)` method (lazy loading)
- ✅ Update `createItem()` to support parent parameter
- ✅ Maintain tree structure in state or build dynamically

**UI:**
- ✅ Update `TodoItemCard` / `ListItemCard` to show expand icon if has children
- ✅ Add indentation (16px per level, max 48px for 3 levels)
- ✅ Add expand/collapse animation
- ✅ Show child count indicator (e.g., "3 subtasks")
- ✅ Update detail screens to support adding child items

**Search Integration:**
- ✅ Update search queries to include parent breadcrumb
- ✅ Modify `SearchResult` model to include parent context
- ✅ Update search repository to JOIN with parents
- ✅ Display breadcrumb in search results (e.g., "Parent > Child > Found Item")

#### API Changes Needed

**TodoListRepository (new methods):**
```dart
// Get root items (parent_id IS NULL)
Future<List<TodoItem>> getRootItems(String listId);

// Get children of a specific item
Future<List<TodoItem>> getChildren(String parentId);

// Get item with all descendants (recursive)
Future<List<TodoItem>> getItemTree(String itemId);

// Get depth of an item (traverse parents)
Future<int> getItemDepth(String itemId);

// Validate parent (same list, depth check, exists)
Future<bool> validateParent(String itemId, String? parentId);
```

**TodoItemsController (updated methods):**
```dart
// Existing methods now accept optional parentId
Future<void> createItem(TodoItem item, {String? parentId});

// New methods
Future<void> toggleExpanded(String itemId);
Future<void> loadChildren(String itemId);
Set<String> get expandedItemIds;
```

**ListRepository (new methods):**
```dart
// Same as TodoListRepository but for list_items
Future<List<ListItem>> getRootItems(String listId);
Future<List<ListItem>> getChildren(String parentId);
Future<List<ListItem>> getItemTree(String itemId);
Future<int> getItemDepth(String itemId);
Future<bool> validateParent(String itemId, String? parentId);
```

#### Database Impact

1. **Storage Growth:**
   - Additional column: ~16 bytes per item (UUID)
   - Additional index: O(n log n) space
   - Example: 10,000 items = ~160KB additional storage (negligible)

2. **Query Performance Impact:**
   - Root item queries: Same as current (add WHERE parent_id IS NULL)
   - Child queries: Fast with index (indexed JOIN)
   - Full tree queries: Slower (recursive CTE), but acceptable for 3 levels
   - Search queries: Slight overhead for JOIN to get parent context (~10-20ms)

3. **Migration Downtime:**
   - Adding column with default NULL: No downtime (online operation)
   - Adding index: Brief lock, but fast for existing data (<1 second for 10K items)
   - Adding trigger: No downtime
   - Total estimated downtime: <5 seconds

4. **Backup Size Increase:**
   - Minimal (~1-2% increase for typical item counts)

### Risks and Mitigation

#### Potential Challenges

1. **Cycle Prevention:**
   - **Risk**: User creates cycle (A → B → A)
   - **Mitigation**:
     - Database trigger checks for cycles
     - Application validation before setting parent
     - UI prevents setting parent to self or descendants

2. **Performance Degradation:**
   - **Risk**: Recursive queries slow with many items
   - **Mitigation**:
     - Enforce 3-level depth limit (prevents deep recursion)
     - Use lazy loading (don't load full tree)
     - Add pagination if list has 100+ root items
     - Monitor query performance with EXPLAIN ANALYZE

3. **UI Complexity:**
   - **Risk**: Nested UI becomes confusing on mobile
   - **Mitigation**:
     - Limit indentation to 48px (3 levels × 16px)
     - Use visual indicators (lines, colors) for hierarchy
     - Provide "collapse all" / "expand all" options
     - Add breadcrumb trail in detail screens

4. **Search Result Confusion:**
   - **Risk**: Users don't understand context of nested items in search results
   - **Mitigation**:
     - Show parent breadcrumb (e.g., "Project > Phase 1 > Task X")
     - Add "Show in list" button to navigate to parent context
     - Group search results by parent
     - Add depth indicator or indentation in search results

5. **Data Migration Issues:**
   - **Risk**: Migration fails or corrupts data
   - **Mitigation**:
     - Test migration thoroughly on local Supabase
     - Use transactions (migration is atomic)
     - Backup data before migration
     - Migration is backward compatible (can rollback by dropping column)

6. **User Confusion:**
   - **Risk**: Users create too deeply nested structures
   - **Mitigation**:
     - Show depth limit in UI (e.g., "Max 3 levels")
     - Disable "add child" button at max depth
     - Educate users on nesting best practices (tooltip/help text)

7. **State Management Complexity:**
   - **Risk**: Managing expand/collapse state becomes complex
   - **Mitigation**:
     - Use simple `Set<String>` for expanded item IDs
     - Persist expand state in local storage (optional)
     - Provide "expand all" / "collapse all" shortcuts

#### Risk Mitigation Strategies

**For Each Challenge:**

1. **Cycle Prevention:**
   ```dart
   // In service layer
   Future<bool> canSetParent(String itemId, String? newParentId) async {
     if (newParentId == null) return true;
     if (newParentId == itemId) return false; // Self-reference

     // Check if newParentId is a descendant of itemId
     final descendants = await repository.getDescendants(itemId);
     return !descendants.any((d) => d.id == newParentId);
   }
   ```

2. **Performance Monitoring:**
   ```sql
   -- Add query to monitor slow recursive queries
   EXPLAIN ANALYZE
   WITH RECURSIVE item_tree AS (...)
   SELECT * FROM item_tree;
   ```

3. **UI Best Practices:**
   ```dart
   // Limit indentation
   double getIndentation(int depth) {
     return (depth * 16.0).clamp(0.0, 48.0); // Max 48px
   }
   ```

4. **Search Result Enhancement:**
   ```dart
   class SearchResult {
     final String id;
     final String title;
     final List<String> breadcrumb; // NEW: ["Project", "Phase 1", "Task"]
     final int depth; // NEW: 0 = root, 1 = child, 2 = grandchild
   }
   ```

#### Fallback Options

If issues arise:

1. **Performance Issues:**
   - Fallback: Disable lazy loading, load full tree (simpler but slower)
   - Fallback: Reduce depth limit to 2 levels
   - Fallback: Add "flatten" view option (show all items as flat list)

2. **UI Issues:**
   - Fallback: Use simpler UI without animations
   - Fallback: Remove indentation, use badges/icons for hierarchy
   - Fallback: Provide "outline view" toggle (tree vs. flat)

3. **Search Issues:**
   - Fallback: Search only root items
   - Fallback: Flatten search results (don't show hierarchy)
   - Fallback: Add filter to exclude/include nested items

4. **Data Integrity Issues:**
   - Rollback migration: DROP COLUMN parent_id
   - Keep items flat until issue resolved
   - Manual data cleanup if needed

## Search Implementation with Nested Structures

### Challenge Analysis

**Problem:** How to include nested items in full-text search results while providing parent context?

**Current Search Plan (from search-feature-implementation.md):**
- Search across `notes`, `todo_lists`, `lists`, `todo_items`, `list_items`
- Use PostgreSQL `tsvector` with GIN indexes
- JOIN child items to parent to show parent name
- Example query:
  ```sql
  SELECT ti.*, tl.name as parent_name
  FROM todo_items ti
  JOIN todo_lists tl ON ti.todo_list_id = tl.id
  WHERE ti.fts @@ to_tsquery('german', 'search_term')
  ```

**With Nesting:** Need to show full breadcrumb, not just immediate parent.

### Search Query Updates

**Option 1: Recursive CTE for Breadcrumb (Accurate but Slower):**

```sql
WITH RECURSIVE item_tree AS (
  -- Base case: the found item
  SELECT
    id,
    parent_id,
    title,
    todo_list_id,
    ARRAY[title] as breadcrumb,
    0 as depth
  FROM todo_items
  WHERE fts @@ to_tsquery('german', :search_term)

  UNION ALL

  -- Recursive case: traverse up to root
  SELECT
    p.id,
    p.parent_id,
    p.title,
    p.todo_list_id,
    p.title || it.breadcrumb,
    it.depth + 1
  FROM todo_items p
  INNER JOIN item_tree it ON p.id = it.parent_id
)
SELECT
  id,
  title,
  breadcrumb,
  tl.name as list_name
FROM item_tree
JOIN todo_lists tl ON todo_list_id = tl.id
WHERE parent_id IS NULL  -- Only get the root entry
ORDER BY updated_at DESC;
```

**Performance:** Acceptable for 3-level depth, would be slow for deeper trees.

**Option 2: Application-Side Breadcrumb (Faster, Simpler):**

```sql
-- Search query (unchanged)
SELECT ti.*, tl.name as list_name
FROM todo_items ti
JOIN todo_lists tl ON ti.todo_list_id = tl.id
WHERE ti.fts @@ to_tsquery('german', :search_term)
ORDER BY ti.updated_at DESC;
```

```dart
// In repository, fetch parents separately
Future<List<String>> getBreadcrumb(String itemId) async {
  final breadcrumb = <String>[];
  String? currentId = itemId;

  while (currentId != null && breadcrumb.length < 3) {
    final item = await getItem(currentId);
    breadcrumb.insert(0, item.title);
    currentId = item.parentId;
  }

  return breadcrumb;
}
```

**Performance:** More HTTP requests, but parallelizable and cacheable.

**Option 3: Materialized Breadcrumb Column (Fastest, More Storage):**

```sql
-- Add computed breadcrumb column
ALTER TABLE todo_items ADD COLUMN breadcrumb TEXT[];

-- Trigger to update breadcrumb on changes
CREATE OR REPLACE FUNCTION update_breadcrumb()
RETURNS TRIGGER AS $$
BEGIN
  -- Build breadcrumb array by traversing parents
  WITH RECURSIVE parents AS (
    SELECT id, parent_id, title, ARRAY[title] as path
    FROM todo_items
    WHERE id = NEW.id

    UNION ALL

    SELECT p.id, p.parent_id, p.title, p.title || parents.path
    FROM todo_items p
    JOIN parents ON p.id = parents.parent_id
  )
  UPDATE todo_items
  SET breadcrumb = (SELECT path FROM parents WHERE parent_id IS NULL)
  WHERE id = NEW.id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Search query (with pre-computed breadcrumb)
SELECT ti.*, ti.breadcrumb, tl.name as list_name
FROM todo_items ti
JOIN todo_lists tl ON ti.todo_list_id = tl.id
WHERE ti.fts @@ to_tsquery('german', :search_term)
ORDER BY ti.updated_at DESC;
```

**Performance:** Fastest (no runtime computation), but adds write overhead.

**Recommendation:** Start with **Option 2 (Application-Side)** for simplicity, migrate to Option 3 if performance becomes an issue.

### Search Result Display

**SearchResult Model (Updated):**
```dart
class SearchResult {
  final String id;
  final ContentType type;
  final String title;
  final String? subtitle;
  final List<String> breadcrumb; // NEW: ["Parent Task", "Current Task"]
  final int depth; // NEW: 0 = root, 1 = child, 2 = grandchild
  final String? parentListName; // "Shopping List" or "Project Tasks"
  final DateTime updatedAt;
  final dynamic content; // Original model (Note/TodoItem/ListItem)
}
```

**Search Result Card (with Breadcrumb):**
```dart
class SearchResultCard extends StatelessWidget {
  final SearchResult result;

  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: _getTypeIcon(result.type),
        title: Text(result.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb
            if (result.breadcrumb.length > 1)
              Text(
                result.breadcrumb.take(result.breadcrumb.length - 1).join(' > '),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            // Parent list name
            Text(result.parentListName ?? ''),
          ],
        ),
        trailing: _getDepthIndicator(result.depth),
        onTap: () => _navigateToItem(context, result),
      ),
    );
  }
}
```

**Depth Indicator:**
```dart
Widget _getDepthIndicator(int depth) {
  if (depth == 0) return SizedBox.shrink();

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (int i = 0; i < depth; i++)
        Icon(Icons.subdirectory_arrow_right, size: 12, color: Colors.grey),
    ],
  );
}
```

### Search Index Optimization

**Existing Plan:** Add `tsvector` column with GIN index to all searchable tables.

**With Nesting:** No changes needed! Each item is still searchable independently.

```sql
-- Existing migration (unchanged)
ALTER TABLE todo_items
ADD COLUMN fts tsvector
GENERATED ALWAYS AS (
  to_tsvector('german', coalesce(title, '') || ' ' || coalesce(description, ''))
) STORED;

CREATE INDEX idx_todo_items_fts ON todo_items USING GIN (fts);
```

**Why No Changes Needed:**
- Each item has its own searchable text (title + description)
- Parent/child relationship doesn't affect text search
- Search returns individual items (not full trees)
- Breadcrumb is computed post-search (not indexed)

### Search Performance Considerations

1. **Search Query Performance:**
   - Base search (tsvector): 10-50ms (with GIN index)
   - Breadcrumb computation (Option 2): +10-30ms per result (parallelizable)
   - Total: 20-80ms for search with breadcrumbs (acceptable)

2. **Result Pagination:**
   - Limit to 50 results per page (same as plan)
   - Load more on demand
   - Breadcrumbs computed only for visible results

3. **Caching Strategy:**
   - Cache breadcrumbs in SearchResult model (don't recompute)
   - Cache parent lookups in repository (short-lived cache)
   - Invalidate cache when items are moved/renamed

4. **Worst Case Scenario:**
   - 1000 search results × 3 parent lookups = 3000 DB queries
   - Mitigation: Limit results, parallelize lookups, add caching

## UI/UX Patterns for Nested Items

### Industry Best Practices

Based on research of Todoist, Asana, Toodledo, and mobile UX guidelines:

1. **Visual Hierarchy:**
   - Use indentation (16px per level)
   - Use connector lines (optional, can be cluttered on mobile)
   - Use icon changes (e.g., filled vs. outlined)
   - Use subtle color shifts per level

2. **Expand/Collapse:**
   - Use downward caret (▼) for collapsed
   - Use upward caret (▲) for expanded
   - Animate transitions (150-300ms duration)
   - Show child count when collapsed (e.g., "▼ 3 items")

3. **Mobile-Specific:**
   - Swipe to indent/outdent (optional gesture)
   - Long-press to show nesting menu
   - Tap to expand/collapse (large hit area)
   - Keep visual hierarchy clear with minimal indentation

4. **Prevent User Error:**
   - Disable "add child" button at max depth
   - Show "Max 3 levels" tooltip
   - Prevent drag-drop that would exceed depth

### Recommended UI Pattern

**For Later App:**

```dart
class TodoItemCard extends ConsumerWidget {
  final TodoItem item;
  final int depth;
  final bool hasChildren;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;

  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0), // Indentation
      child: Card(
        child: ListTile(
          // Leading: Checkbox
          leading: Checkbox(
            value: item.isCompleted,
            onChanged: (value) => _toggleCompletion(ref),
          ),

          // Title
          title: Text(item.title),

          // Subtitle (optional description)
          subtitle: item.description != null
            ? Text(item.description!)
            : null,

          // Trailing: Expand/collapse icon if has children
          trailing: hasChildren
            ? IconButton(
                icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                onPressed: onToggleExpand,
              )
            : null,

          // Tap to view details
          onTap: () => _navigateToDetails(context),
        ),
      ),
    );
  }
}
```

**Detail Screen (Add Child Item):**

```dart
class TodoListDetailScreen extends StatelessWidget {
  Widget _buildAddItemButton(BuildContext context, TodoItem? parent) {
    final depth = parent?.depth ?? 0;
    final canAddChild = depth < 2; // Max depth is 3 (0, 1, 2)

    return FloatingActionButton(
      onPressed: canAddChild
        ? () => _showAddItemDialog(context, parentId: parent?.id)
        : null,
      tooltip: canAddChild
        ? 'Add ${parent != null ? 'sub-task' : 'task'}'
        : 'Max nesting depth reached',
      child: Icon(Icons.add),
    );
  }
}
```

### Visual Hierarchy Examples

**Level 0 (Root):**
```
┌─────────────────────────────────────┐
│ ☐ Buy groceries                  ▼ │
└─────────────────────────────────────┘
```

**Level 1 (Child) - Expanded:**
```
┌─────────────────────────────────────┐
│ ☐ Buy groceries                  ▲ │
│     ┌───────────────────────────┐   │
│     │ ☐ Get milk                 │   │
│     └───────────────────────────┘   │
│     ┌───────────────────────────┐   │
│     │ ☐ Get bread             ▼ │   │
│     └───────────────────────────┘   │
└─────────────────────────────────────┘
```

**Level 2 (Grandchild) - Fully Expanded:**
```
┌─────────────────────────────────────┐
│ ☐ Buy groceries                  ▲ │
│     ┌───────────────────────────┐   │
│     │ ☐ Get milk                 │   │
│     └───────────────────────────┘   │
│     ┌───────────────────────────┐   │
│     │ ☐ Get bread             ▲ │   │
│     │     ┌─────────────────┐   │   │
│     │     │ ☐ Whole wheat    │   │   │
│     │     └─────────────────┘   │   │
│     │     ┌─────────────────┐   │   │
│     │     │ ☐ Sourdough      │   │   │
│     │     └─────────────────┘   │   │
│     └───────────────────────────┘   │
└─────────────────────────────────────┘
```

**Color Coding (Optional):**
- Level 0: Primary color (red-orange for tasks)
- Level 1: 80% opacity of primary
- Level 2: 60% opacity of primary

### Navigation Patterns

1. **Expand/Collapse:**
   - Default: Only show root items
   - User taps caret to expand
   - Children load lazily (on expand)
   - Collapse hides children immediately

2. **Detail Navigation:**
   - Tap item card → Navigate to detail screen
   - Detail screen shows:
     - Current item details
     - Breadcrumb trail (Parent > Current)
     - Button to add child item (if depth < 3)
     - List of children (if any)

3. **Breadcrumb Navigation:**
   - Show breadcrumb at top of detail screen
   - Each breadcrumb segment is tappable
   - Tap to navigate to parent item

4. **Context Menu:**
   - Long-press item → Show menu
   - Options: Edit, Delete, Add child, Move, Convert to... (future)

### Accessibility Considerations

1. **Screen Reader Support:**
   - Announce depth level (e.g., "Level 2 item")
   - Announce expand/collapse state
   - Provide semantic labels (e.g., "Expand subtasks")

2. **Keyboard Navigation:**
   - Tab to navigate between items
   - Space/Enter to toggle expand
   - Arrow keys to navigate hierarchy (future)

3. **Visual Indicators:**
   - High contrast for indentation
   - Clear focus indicators
   - Sufficient touch targets (48×48 minimum)

## Recommendations

### Recommended Approach

**Architecture: Adjacency List Pattern**

- Add `parent_id` self-referential foreign key to `todo_items` and `list_items`
- Use PostgreSQL triggers to enforce 3-level depth limit
- Use recursive CTEs for full tree queries (only when needed)
- Implement lazy loading (fetch children on expand)

**Maximum Depth: 3 Levels**

- Level 0: Root items (parent_id = NULL)
- Level 1: Children (parent_id = root item)
- Level 2: Grandchildren (parent_id = child item)
- Level 3: BLOCKED by database trigger

**UI Pattern: ExpansionTile + Indentation**

- Use Flutter's built-in `ExpansionTile` widget
- Indentation: 16px per level (max 48px)
- Expand/collapse icons: ▼ (collapsed) / ▲ (expanded)
- Show child count when collapsed
- Lazy load children (don't load until expanded)

**Search Integration: Application-Side Breadcrumb**

- Search returns individual items (not trees)
- Fetch parent breadcrumb after search (parallelizable)
- Display breadcrumb in search results
- Add depth indicator (visual)
- "Show in list" button to navigate to context

### Alternative Approaches

**If Performance Becomes an Issue:**

1. **Materialized Breadcrumb Column:**
   - Add `breadcrumb TEXT[]` column to tables
   - Update via trigger on item changes
   - Faster search result display (no runtime computation)
   - Trade-off: More storage, more write overhead

2. **Closure Table Pattern:**
   - Add separate `todo_item_paths` and `list_item_paths` tables
   - Store all ancestor-descendant relationships
   - Faster tree queries (no recursion)
   - Trade-off: More complexity, more storage

3. **Depth-First Ordering:**
   - Add `tree_order` column for depth-first traversal
   - Load items in single query, render as tree in application
   - Faster full tree loads
   - Trade-off: More complex ordering logic

**If UX Issues Arise:**

1. **Flatten View Toggle:**
   - Add button to show all items as flat list
   - Useful for overview or printing

2. **Outline View:**
   - Show full tree structure in separate view
   - More like a traditional outliner

3. **Reduce Depth Limit:**
   - Change from 3 to 2 levels if users find it confusing

### Phased Implementation

**Phase 1: Database Foundation (Week 1)**
- Create migration to add `parent_id` columns
- Add indexes and constraints
- Add depth limit trigger
- Test migration thoroughly

**Phase 2: Model & Repository (Week 1)**
- Update domain models (add `parentId` field)
- Add repository methods: `getRootItems`, `getChildren`
- Add validation logic in services
- Write unit tests

**Phase 3: Basic UI (Week 2)**
- Update item cards with expand/collapse
- Implement indentation
- Add child count indicators
- Test on mobile devices

**Phase 4: Controllers & State (Week 2)**
- Add expand/collapse state management
- Implement lazy loading
- Add create child item functionality
- Write controller tests

**Phase 5: Search Integration (Week 3)**
- Update search queries to include nested items
- Add breadcrumb computation
- Update SearchResult model
- Display breadcrumbs in search UI
- Test search performance

**Phase 6: Polish & Optimization (Week 3)**
- Add animations
- Improve visual hierarchy
- Add accessibility labels
- Performance tuning
- User testing

## Risks and Considerations

### Technical Risks

1. **Performance Degradation:**
   - Recursive queries may be slow with many items
   - **Mitigation:** Limit depth to 3, use lazy loading, add pagination

2. **Complexity:**
   - State management becomes more complex with hierarchies
   - **Mitigation:** Keep expand/collapse state simple (Set<String>), thorough testing

3. **Data Integrity:**
   - Orphaned items if parent deleted (already handled by ON DELETE CASCADE)
   - Cycles if validation fails (prevented by trigger + application logic)
   - **Mitigation:** Database constraints, thorough validation, tests

### UX Risks

1. **Cognitive Overload:**
   - Too much nesting confuses users
   - **Mitigation:** Limit to 3 levels, educate users, provide flatten view

2. **Hidden Items:**
   - Users may forget about collapsed nested items
   - **Mitigation:** Show child count, search includes nested items, breadcrumb navigation

3. **Mobile Limitations:**
   - Indentation reduces space on small screens
   - **Mitigation:** Limit indentation to 48px, test on various device sizes

### Business Risks

1. **Development Time:**
   - Nested items add significant complexity
   - **Mitigation:** Phased approach, MVP first, iterate based on feedback

2. **User Adoption:**
   - Users may not understand or use nesting feature
   - **Mitigation:** Make it optional, provide tooltips/help, show examples

3. **Migration Issues:**
   - Database migration could fail or cause downtime
   - **Mitigation:** Test thoroughly on local Supabase, have rollback plan, backward compatible

## Other Considerations

### Moving Items Between Parents

**Future Enhancement:** Allow users to move items to different parents (or make root).

**Implementation:**
```dart
Future<void> moveItem(String itemId, String? newParentId) async {
  // Validate:
  // 1. New parent exists (if not null)
  // 2. New parent is not a descendant of itemId (prevent cycles)
  // 3. New parent is in same list
  // 4. Depth would not exceed limit

  await supabase
    .from('todo_items')
    .update({'parent_id': newParentId})
    .eq('id', itemId);
}
```

**UI:** Drag-and-drop or context menu "Move to..."

### Converting Between Types

**Future Enhancement:** Convert todo item to note, or vice versa.

**Challenge:** Nested items - what happens to children?

**Options:**
1. Flatten children (make them siblings of converted item)
2. Convert entire subtree
3. Block conversion if item has children

### Bulk Operations

**Future Enhancement:** Complete all children when parent completed, or delete all children when parent deleted.

**Implementation:**
- Already handled for delete (ON DELETE CASCADE)
- For completion: Add checkbox "Complete all subtasks"

### Export/Import

**Consideration:** How to represent hierarchy in exported data?

**Options:**
1. Indented text (Markdown-style)
2. JSON with nested structure
3. CSV with depth column

### Recurring Tasks

**Future Enhancement:** If todo item is recurring, what happens to children?

**Options:**
1. Children are not copied (only parent recurs)
2. Entire subtree is copied
3. User chooses per-recurrence

### Collaboration

**Future Enhancement:** Multiple users working on same nested structure.

**Challenges:**
- Conflict resolution (both users add child to same parent)
- Real-time updates (WebSocket for live changes)
- Permission model (can user edit parent but not children?)

**Out of Scope** for MVP - address in future collaboration feature.

## References

### Documentation

- [PostgreSQL Recursive Queries (WITH RECURSIVE)](https://www.postgresql.org/docs/current/queries-with.html)
- [Flutter ExpansionTile Widget](https://api.flutter.dev/flutter/material/ExpansionTile-class.html)
- [Supabase Self-Referential Foreign Keys](https://supabase.com/docs/guides/database/tables#foreign-keys)
- [Nielsen Norman Group: Mobile Subnavigation](https://www.nngroup.com/articles/mobile-subnavigation/)
- [Smashing Magazine: Designing The Perfect Accordion](https://www.smashingmagazine.com/2017/06/designing-perfect-accordion-checklist/)

### Articles

- [Hierarchical Data in PostgreSQL: Adjacency List vs Closure Table](https://stackoverflow.com/questions/4048151/what-are-the-options-for-storing-hierarchical-data-in-a-relational-database)
- [Flutter Tree View Packages Comparison](https://pub.dev/packages/animated_tree_view)
- [Mobile UX Patterns for Nested Lists](https://ux.stackexchange.com/questions/80567/whats-the-best-navigation-ui-pattern-for-nested-resources-on-mobile)
- [Best Practices for Nested Todo Items (Toodledo)](https://www.toodledo.com/info/subtasks.php)

### Code Repositories

- [animated_tree_view Flutter package](https://pub.dev/packages/animated_tree_view)
- [PostgreSQL ltree extension](https://www.postgresql.org/docs/current/ltree.html)

### Productivity App Examples

- **Todoist:** Basic subtask support (2 levels)
- **Asana:** Unlimited subtask nesting (users requested limit option)
- **Toodledo:** 3-level hierarchy (Folder → Task → Subtask)
- **Amplenote:** Collapsible nested tasks with outlining
- **MyLifeOrganized:** Deep nesting with tree view

## Appendix

### Database Migration Script

**File:** `supabase/migrations/YYYYMMDDHHMMSS_add_nested_items_support.sql`

```sql
-- Migration: Add support for nested todo items and list items
-- Adds parent_id self-referential foreign keys with depth limit

-- 1. Add parent_id column to todo_items
ALTER TABLE todo_items
ADD COLUMN parent_id UUID REFERENCES todo_items(id) ON DELETE CASCADE;

-- 2. Add parent_id column to list_items
ALTER TABLE list_items
ADD COLUMN parent_id UUID REFERENCES list_items(id) ON DELETE CASCADE;

-- 3. Add indexes for performance
CREATE INDEX idx_todo_items_parent_id ON todo_items(parent_id);
CREATE INDEX idx_list_items_parent_id ON list_items(parent_id);

-- 4. Create function to check depth limit (3 levels: 0, 1, 2)
CREATE OR REPLACE FUNCTION check_todo_item_depth()
RETURNS TRIGGER AS $$
DECLARE
  current_depth INTEGER := 0;
  current_parent_id UUID;
BEGIN
  -- If no parent, it's a root item (depth 0) - OK
  IF NEW.parent_id IS NULL THEN
    RETURN NEW;
  END IF;

  -- Prevent self-reference
  IF NEW.parent_id = NEW.id THEN
    RAISE EXCEPTION 'Item cannot be its own parent';
  END IF;

  -- Validate parent belongs to same todo_list
  IF NOT EXISTS (
    SELECT 1 FROM todo_items
    WHERE id = NEW.parent_id
    AND todo_list_id = NEW.todo_list_id
  ) THEN
    RAISE EXCEPTION 'Parent item must belong to the same todo list';
  END IF;

  -- Traverse up to count depth
  current_parent_id := NEW.parent_id;

  WHILE current_parent_id IS NOT NULL LOOP
    current_depth := current_depth + 1;

    -- Check if we've exceeded depth limit
    IF current_depth > 2 THEN
      RAISE EXCEPTION 'Maximum nesting depth of 3 levels exceeded (0, 1, 2)';
    END IF;

    -- Get parent's parent
    SELECT parent_id INTO current_parent_id
    FROM todo_items
    WHERE id = current_parent_id;
  END LOOP;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5. Create trigger for todo_items
CREATE TRIGGER enforce_todo_item_depth
BEFORE INSERT OR UPDATE OF parent_id ON todo_items
FOR EACH ROW EXECUTE FUNCTION check_todo_item_depth();

-- 6. Create function to check depth limit for list_items
CREATE OR REPLACE FUNCTION check_list_item_depth()
RETURNS TRIGGER AS $$
DECLARE
  current_depth INTEGER := 0;
  current_parent_id UUID;
BEGIN
  -- If no parent, it's a root item (depth 0) - OK
  IF NEW.parent_id IS NULL THEN
    RETURN NEW;
  END IF;

  -- Prevent self-reference
  IF NEW.parent_id = NEW.id THEN
    RAISE EXCEPTION 'Item cannot be its own parent';
  END IF;

  -- Validate parent belongs to same list
  IF NOT EXISTS (
    SELECT 1 FROM list_items
    WHERE id = NEW.parent_id
    AND list_id = NEW.list_id
  ) THEN
    RAISE EXCEPTION 'Parent item must belong to the same list';
  END IF;

  -- Traverse up to count depth
  current_parent_id := NEW.parent_id;

  WHILE current_parent_id IS NOT NULL LOOP
    current_depth := current_depth + 1;

    -- Check if we've exceeded depth limit
    IF current_depth > 2 THEN
      RAISE EXCEPTION 'Maximum nesting depth of 3 levels exceeded (0, 1, 2)';
    END IF;

    -- Get parent's parent
    SELECT parent_id INTO current_parent_id
    FROM list_items
    WHERE id = current_parent_id;
  END LOOP;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. Create trigger for list_items
CREATE TRIGGER enforce_list_item_depth
BEFORE INSERT OR UPDATE OF parent_id ON list_items
FOR EACH ROW EXECUTE FUNCTION check_list_item_depth();

-- 8. Add comment for documentation
COMMENT ON COLUMN todo_items.parent_id IS 'Self-referential foreign key for nested todo items. NULL for root items. Maximum depth: 3 levels (0, 1, 2).';
COMMENT ON COLUMN list_items.parent_id IS 'Self-referential foreign key for nested list items. NULL for root items. Maximum depth: 3 levels (0, 1, 2).';
```

### Example Queries

**Get root items:**
```sql
SELECT * FROM todo_items
WHERE todo_list_id = :list_id
  AND parent_id IS NULL
ORDER BY sort_order;
```

**Get children of a specific item:**
```sql
SELECT * FROM todo_items
WHERE parent_id = :parent_id
ORDER BY sort_order;
```

**Get full tree with depth:**
```sql
WITH RECURSIVE item_tree AS (
  -- Base case: root items
  SELECT
    id,
    parent_id,
    todo_list_id,
    title,
    is_completed,
    sort_order,
    0 as depth,
    ARRAY[sort_order] as path
  FROM todo_items
  WHERE todo_list_id = :list_id
    AND parent_id IS NULL

  UNION ALL

  -- Recursive case: children
  SELECT
    ti.id,
    ti.parent_id,
    ti.todo_list_id,
    ti.title,
    ti.is_completed,
    ti.sort_order,
    it.depth + 1,
    it.path || ti.sort_order
  FROM todo_items ti
  INNER JOIN item_tree it ON ti.parent_id = it.id
  WHERE it.depth < 2  -- Limit to depth 2 (3 levels: 0, 1, 2)
)
SELECT * FROM item_tree
ORDER BY path;
```

**Get breadcrumb for search result:**
```sql
WITH RECURSIVE breadcrumb AS (
  -- Base case: the found item
  SELECT
    id,
    parent_id,
    title,
    ARRAY[title] as path
  FROM todo_items
  WHERE id = :item_id

  UNION ALL

  -- Recursive case: traverse up to root
  SELECT
    p.id,
    p.parent_id,
    p.title,
    p.title || bc.path
  FROM todo_items p
  INNER JOIN breadcrumb bc ON p.id = bc.parent_id
)
SELECT path FROM breadcrumb
WHERE parent_id IS NULL;  -- Get the root entry with full path
```

**Count children (for display):**
```sql
SELECT
  ti.*,
  COUNT(children.id) as child_count
FROM todo_items ti
LEFT JOIN todo_items children ON children.parent_id = ti.id
WHERE ti.todo_list_id = :list_id
  AND ti.parent_id IS NULL
GROUP BY ti.id
ORDER BY ti.sort_order;
```

### Additional Notes

**Testing Strategy:**
1. Unit tests for depth validation
2. Integration tests for recursive queries
3. UI tests for expand/collapse
4. Performance tests with large hierarchies
5. Manual testing on various devices

**Performance Monitoring:**
- Track query times for tree operations
- Monitor search performance with nested items
- Alert if queries exceed 100ms
- Use EXPLAIN ANALYZE for optimization

**User Education:**
- Add tooltip explaining nesting (first use)
- Show example in onboarding
- Provide "Best Practices" help article
- Consider in-app tutorial

**Future Enhancements:**
- Drag-and-drop reordering with nesting
- Move item to different parent
- Convert item types (preserve hierarchy)
- Bulk operations on subtrees
- Export/import with hierarchy
- Collaboration features
- Recurring tasks with children
- Parent-child dependencies (complete parent when all children done)
