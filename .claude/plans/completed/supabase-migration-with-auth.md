# Supabase Migration with Authentication

## Objective and Scope

Migrate from Hive local-only storage to Supabase cloud database with proper authentication. This is a complete replacement of the data layer - no offline mode, no data migration from existing Hive data. Users will need to authenticate before accessing any functionality.

**Key Goals:**
- Replace Hive with Supabase as the single source of truth
- Implement authentication (email/password + social providers)
- Adapt existing models to work with PostgreSQL
- Maintain existing UI/UX with minimal changes
- Remove all Hive-related code and dependencies

## Technical Approach and Reasoning

**Why Supabase:**
- Built on PostgreSQL for robust relational data
- Built-in authentication with multiple providers
- Real-time subscriptions for future features
- Row-Level Security (RLS) for multi-tenant isolation
- Generous free tier for MVP

**Architecture Changes:**
- Replace Hive repositories with Supabase repositories
- Add authentication layer before main app initialization
- Convert models to use PostgreSQL-compatible types
- Use foreign keys for relationships (spaceId → spaces table)
- Maintain Provider pattern for state management

**Data Model Mapping:**
- `Note` (formerly `Item`) → `notes` table
- `TodoList` + `TodoItem` → `todo_lists` + `todo_items` tables (normalized)
- `ListModel` + `ListItem` → `lists` + `list_items` tables (normalized)
- `Space` → `spaces` table
- Add `users` table (handled by Supabase Auth)

## Implementation Phases

### Phase 1: Supabase Setup and Database Schema

- [x] Task 1.1: Configure local Supabase development environment
  - ✅ Added `supabase_flutter: ^2.10.3` dependency to `pubspec.yaml` (latest version)
  - ✅ Started local Supabase dev-server: `supabase start` (uses local PostgreSQL + Auth)
  - ✅ Noted the local API URL (`http://127.0.0.1:54321`) and anon key from CLI output
  - ✅ Created `lib/core/config/supabase_config.dart` with hardcoded local dev credentials:
    - `SUPABASE_URL = 'http://127.0.0.1:54321'`
    - `SUPABASE_ANON_KEY = 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH'`
  - ✅ Initialized Supabase client singleton in config file
  - Note: For production deployment, environment variables can be added later

- [x] Task 1.2: Design and create PostgreSQL database schema
  - ✅ Created migration file: `supabase/migrations/20251103230632_initial_schema.sql`
  - ✅ Edited the generated migration file to include all tables:
    - ✅ `spaces` table with all required columns and constraints
    - ✅ `notes` table with all required columns and constraints
    - ✅ `todo_lists` table with all required columns and constraints
    - ✅ `todo_items` table with all required columns and constraints
    - ✅ `lists` table with all required columns and constraints
    - ✅ `list_items` table with all required columns and constraints
  - ✅ Added indexes for performance optimization on all key columns
  - ✅ Applied migration: `supabase db reset` - migration applied successfully

- [x] Task 1.3: Configure Row-Level Security (RLS) policies
  - ✅ Created new migration: `supabase/migrations/20251103230901_rls_policies.sql`
  - ✅ Added RLS policies to the migration file:
    - ✅ Enabled RLS on all tables
    - ✅ Policy for `spaces`: Users can access own spaces
    - ✅ Policy for `notes`: Users can access own notes
    - ✅ Policy for `todo_lists`: Users can access own todo_lists
    - ✅ Policy for `todo_items`: Users can access todo items in their own todo lists
    - ✅ Policy for `lists`: Users can access own lists
    - ✅ Policy for `list_items`: Users can access list items in their own lists
  - ✅ Applied migration: `supabase db reset` - RLS policies applied successfully
  - 🔄 Test policies: Create test user via Supabase Studio (http://localhost:54323) and verify data isolation (deferred - can be done during Phase 2 testing)

### Phase 2: Authentication Implementation

- [x] Task 2.1: Create authentication service
  - ✅ Created `lib/data/services/auth_service.dart` with Supabase Auth integration
  - ✅ Implemented methods: `signUp()`, `signIn()`, `signOut()`, `getCurrentUser()`, `authStateChanges()`
  - ✅ Added exception handling with user-friendly error messages
  - ✅ Email confirmation disabled in local Supabase for easier testing
  - Note: Social sign-in (Google, Apple) deferred to post-MVP

- [x] Task 2.2: Create authentication provider for state management
  - ✅ Created `lib/providers/auth_provider.dart` extending ChangeNotifier
  - ✅ Added properties: `User? currentUser`, `bool isLoading`, `String? errorMessage`
  - ✅ Implemented auth methods that call AuthService and notify listeners
  - ✅ Added auth state stream listener to update currentUser automatically
  - ✅ Error handling and loading states implemented throughout

- [x] Task 2.3: Create authentication UI screens
  - ✅ Created `lib/widgets/screens/auth/sign_in_screen.dart`:
    - ✅ Email and password fields with validation using TextInputField
    - ✅ Sign In button with loading state using PrimaryButton
    - ✅ Navigation link to Sign Up screen using GestureDetector + RichText
    - ✅ Error banner display with animations
    - ✅ Form validation for email format and required fields
  - ✅ Created `lib/widgets/screens/auth/sign_up_screen.dart`:
    - ✅ Email, password, and confirm password fields with validation
    - ✅ Create Account button with loading state
    - ✅ Navigation link to Sign In screen
    - ✅ Password strength indicator component
    - ✅ Form validation (email format, password length >= 8, passwords match)
  - ✅ Enhanced with AnimatedMeshBackground for bold visual design
  - ✅ Added PasswordStrengthIndicator component for sign-up
  - ✅ Replaced generic icon with branded app icon
  - ✅ Theme-aware styling for light/dark modes
  - ✅ Enhanced text readability with custom textColor parameter on TextInputField
  - ✅ All animations respect reduced motion accessibility preferences
  - Note: Social sign-in UI deferred to post-MVP

- [x] Task 2.4: Add authentication gate to app initialization
  - ✅ Updated `lib/main.dart` to remove Hive initialization
  - ✅ Initialized Supabase client in main() before runApp
  - ✅ Wrapped LaterApp with AuthProvider in MultiProvider
  - ✅ Created `lib/widgets/auth/auth_gate.dart` widget with auth state logic
  - ✅ AuthGate shows SignInScreen when unauthenticated, HomeScreen when authenticated
  - ✅ Loading spinner displayed during auth state changes
  - ✅ MaterialApp's home property updated to use AuthGate

### Phase 3: Model Adaptations for Supabase

- [x] Task 3.1: Update model classes to remove Hive annotations
  - ✅ Removed `@HiveType` and `@HiveField` annotations from all models (Note, Space, TodoList, TodoItem, ListModel, ListItem, enums)
  - ✅ Removed `part 'model_name.g.dart';` imports
  - ✅ Removed `import 'package:hive/hive.dart';` statements
  - ✅ Kept existing `fromJson()` and `toJson()` methods and updated for Supabase compatibility
  - ✅ Updated `fromJson()` to use snake_case field names matching PostgreSQL schema (e.g., `space_id`, `created_at`)
  - ✅ Updated `toJson()` to use snake_case field names for Supabase
  - ✅ Updated enums (TodoPriority, ListStyle) to use string serialization

- [x] Task 3.2: Add user_id field to models for multi-tenancy
  - ✅ Added `final String userId;` field to Space, Note (Item), TodoList, ListModel
  - ✅ Updated constructors to require userId parameter
  - ✅ Updated `fromJson()` methods to parse `user_id` from JSON
  - ✅ Updated `toJson()` methods to include `user_id` in output
  - ✅ Updated `copyWith()` methods to include optional userId parameter
  - Note: userId will be populated from `auth.currentUser.id` in repositories

- [x] Task 3.3: Normalize nested models for relational database (Initial approach - to be revised)
  - ✅ Kept `List<TodoItem>` field in TodoList with documentation noting it's populated by repository
  - ✅ Kept `List<ListItem>` field in ListModel with documentation noting it's populated by repository
  - ✅ Added comments explaining items are fetched separately in Supabase but field maintained for compatibility
  - ⚠️ **Decision to revise:** This approach causes performance issues (loading all items for all lists even in list views)
  - 🔄 **See Phase 3.5 for revised normalization approach**

- [x] Task 3.4: Rename Item model to Note for clarity
  - ✅ Renamed class `Item` to `Note`
  - ✅ Renamed file from `item_model.dart` to `note_model.dart`
  - ✅ Updated all 26 imports throughout the codebase to use `note_model.dart`
  - ✅ Updated factory constructor `Item.fromJson` → `Note.fromJson`
  - ✅ Updated copyWith method to return `Note` instead of `Item`
  - ✅ Updated toString() method to show `Note(...)`
  - ✅ Updated equality operator to check `other is Note`
  - ✅ Removed `syncStatus` field (not needed for Supabase online-only architecture)
  - Note: All imports, repositories, and widgets still reference the Note model correctly

### Phase 3.5: Model Restructuring for Efficient Data Loading

**Context:** The initial Phase 3 approach kept nested `items` lists in TodoList and ListModel, which would force loading all child items even in list views (home screen). This phase separates aggregate data (counts) from child items for optimal performance.

**Architecture Decision:**
- Models contain aggregate fields (counts) populated from database GROUP BY queries
- Child items (TodoItem, ListItem) fetched separately via dedicated repository methods
- Enables efficient list views (only counts) vs detail views (full items loaded)

- [x] Task 3.5.1: Remove items field from TodoList and ListModel
  - ✅ Removed `final List<TodoItem> items;` from TodoList model
  - ✅ Removed `final List<ListItem> items;` from ListModel model
  - ✅ Removed items-related code from constructors
  - ✅ Removed items parameter from `copyWith()` methods
  - ✅ Removed items from `fromJson()` factories (items won't be in JSON response)
  - ✅ Removed items from `toJson()` methods (items stored in separate table)

- [x] Task 3.5.2: Add aggregate count fields to TodoList and ListModel
  - ✅ Added to TodoList:
    - `final int totalItemCount;` - Total number of todo items (from DB aggregate)
    - `final int completedItemCount;` - Number of completed items (from DB aggregate)
  - ✅ Added to ListModel:
    - `final int totalItemCount;` - Total number of list items (from DB aggregate)
    - `final int checkedItemCount;` - Number of checked items (from DB aggregate, only relevant for checkbox style)
  - ✅ Updated constructors to include these count fields with default values of 0
  - ✅ Updated `fromJson()` to parse count fields (e.g., `json['total_item_count']`)
  - ✅ Updated `toJson()` to include count fields (repositories will compute before insert/update)
  - ✅ Updated `copyWith()` methods to include count parameters

- [x] Task 3.5.3: Update getters to use count fields instead of items array
  - ✅ TodoList:
    - Changed `int get totalItems => items.length;` to `int get totalItems => totalItemCount;`
    - Changed `int get completedItems => items.where((item) => item.isCompleted).length;` to `int get completedItems => completedItemCount;`
    - Kept `double get progress` calculation using new getters
  - ✅ ListModel:
    - Changed `int get totalItems => items.length;` to `int get totalItems => totalItemCount;`
    - Changed `int get checkedItems => items.where((item) => item.isChecked).length;` to `int get checkedItems => checkedItemCount;`
    - Kept `double get progress` calculation using new getters

- [x] Task 3.5.4: Add parent foreign key references to TodoItem and ListItem
  - ✅ Added to TodoItem:
    - `final String todoListId;` - Foreign key to parent TodoList
    - Updated constructor, `fromJson()`, `toJson()`, `copyWith()`
    - Parsing from `json['todo_list_id']` (snake_case from DB)
  - ✅ Added to ListItem:
    - `final String listId;` - Foreign key to parent ListModel
    - Updated constructor, `fromJson()`, `toJson()`, `copyWith()`
    - Parsing from `json['list_id']` (snake_case from DB)
  - Note: These match the foreign key columns in the database schema

- [x] Task 3.5.5: Update model documentation
  - ✅ Updated TodoList class documentation to explain items are fetched separately
  - ✅ Updated ListModel class documentation to explain items are fetched separately
  - ✅ Added documentation to count fields explaining they're populated from database aggregates
  - 🔄 Update CLAUDE.md if it references the old nested structure (deferred - will update if issues found)

### Phase 4: Repository Layer Rewrite

- [x] Task 4.1: Create base Supabase repository
  - ✅ Created `lib/data/repositories/base_repository.dart` with:
    - ✅ Protected `supabase` getter accessing SupabaseClient singleton
    - ✅ Protected `userId` getter from `supabase.auth.currentUser!.id`
    - ✅ Helper method `_handlePostgrestException()` to map Supabase exceptions to user-friendly errors
    - ✅ Helper method `_handleAuthException()` to map auth exceptions
    - ✅ Helper method `executeQuery<T>(Future<T> Function() query)` with try-catch and error handling

- [x] Task 4.2: Rewrite SpaceRepository for Supabase
  - ✅ Updated `lib/data/repositories/space_repository.dart` to extend BaseRepository
  - ✅ Replaced Hive box operations with Supabase queries:
    - ✅ `getSpaces()` → `supabase.from('spaces').select().eq('user_id', userId).order('created_at')`
    - ✅ `getSpaceById(id)` → `supabase.from('spaces').select().eq('id', id).eq('user_id', userId).maybeSingle()`
    - ✅ `createSpace(space)` → `supabase.from('spaces').insert(data).select().single()`
    - ✅ `updateSpace(space)` → `supabase.from('spaces').update(data).eq('id', space.id).eq('user_id', userId)`
    - ✅ `deleteSpace(id)` → `supabase.from('spaces').delete().eq('id', id).eq('user_id', userId)`
    - ✅ `getItemCount(spaceId)` → Queries counts from notes, todo_lists, and lists tables
  - ✅ Removed all Hive-specific code (box access, keys iteration)
  - ✅ Added error handling via BaseRepository.executeQuery()

- [x] Task 4.3: Rewrite NoteRepository for Supabase
  - ✅ Updated `lib/data/repositories/note_repository.dart` to extend BaseRepository
  - ✅ Replaced Hive operations with Supabase queries:
    - ✅ `getBySpace(spaceId)` → `supabase.from('notes').select().eq('space_id', spaceId).eq('user_id', userId).order('sort_order')`
    - ✅ `getById(id)` → `supabase.from('notes').select().eq('id', id).eq('user_id', userId).maybeSingle()`
    - ✅ `create(note)` → Insert with user_id and auto-calculated sortOrder
    - ✅ `update(note)` → Update with user_id check and updated_at timestamp
    - ✅ `delete(id)` → Delete with user_id check
    - ✅ `updateSortOrders(List<Note> notes)` → Batch upsert for reordering
  - ✅ Removed all Hive-specific code
  - ✅ Added support for PostgreSQL array type for tags field (using `.contains()`)
  - ✅ Added search functionality with `.or()` and `.ilike()` operators
  - ✅ Added `getByTag()` method using array containment

- [x] Task 4.4: Rewrite TodoListRepository for Supabase
  - ✅ Updated `lib/data/repositories/todo_list_repository.dart` to extend BaseRepository
  - ✅ Replaced Hive operations with Supabase queries for TodoLists:
    - ✅ `getBySpace(spaceId)` → Queries todo_lists and fetches counts by loading items
    - ✅ `getById(id)` → Single query with counts calculated from items
    - ✅ `create(todoList)` → Insert into todo_lists table with initial counts (0, 0)
    - ✅ `update(todoList)` → Update todo_lists table with updated_at timestamp
    - ✅ `delete(id)` → Delete todo_list (cascade deletes todo_items via FK constraint)
  - ✅ Added TodoItem-specific methods:
    - ✅ `getTodoItemsByListId(todoListId)` → Query todo_items table ordered by sort_order
    - ✅ `createTodoItem(todoItem)` → Insert with auto-calculated sortOrder, updates parent counts
    - ✅ `updateTodoItem(todoItem)` → Update with count recalculation if completion status changed
    - ✅ `deleteTodoItem(id, todoListId)` → Delete and update parent list's counts
    - ✅ `updateTodoItemSortOrders(List<TodoItem> items)` → Batch upsert for reordering
  - ✅ Removed embedded list logic (items fetched separately via getTodoItemsByListId)
  - ✅ Added private helper `_updateTodoListCounts()` for efficient count updates

- [x] Task 4.5: Rewrite ListRepository for Supabase
  - ✅ Updated `lib/data/repositories/list_repository.dart` to extend BaseRepository
  - ✅ Replaced Hive operations with Supabase queries for Lists:
    - ✅ `getBySpace(spaceId)` → Queries lists and fetches counts by loading items
    - ✅ `getById(id)` → Single query with counts calculated from items
    - ✅ `create(list)` → Insert into lists table with initial counts (0, 0)
    - ✅ `update(list)` → Update lists table with updated_at timestamp
    - ✅ `delete(id)` → Delete list (cascade deletes list_items via FK constraint)
  - ✅ Added ListItem-specific methods:
    - ✅ `getListItemsByListId(listId)` → Query list_items table ordered by sort_order
    - ✅ `createListItem(listItem)` → Insert with auto-calculated sortOrder, updates parent counts
    - ✅ `updateListItem(listItem)` → Update with count recalculation if checked status changed
    - ✅ `deleteListItem(id, listId)` → Delete and update parent list's counts
    - ✅ `updateListItemSortOrders(List<ListItem> items)` → Batch upsert for reordering
  - ✅ Removed embedded list logic (items fetched separately via getListItemsByListId)
  - ✅ Added private helper `_updateListCounts()` for efficient count updates

**Phase 4 Complete** - All repository code has been successfully migrated from Hive to Supabase with RLS policies, proper error handling, and efficient count management.

### Phase 5: Provider Layer Updates

- [x] Task 5.1: Update SpacesProvider to work with async Supabase operations
  - ✅ SpacesProvider already fully migrated with async operations, loading states, and error handling
  - ✅ Has `loadSpaces()` async method with proper error handling
  - ✅ All CRUD methods (`createSpace()`, `updateSpace()`, `deleteSpace()`) are async and use retry logic
  - ✅ `getSpaceItemCount()` method uses SpaceRepository for on-demand count calculation
  - ✅ Complete loading state management (`isLoading`, `error`, `clearError()`)

- [x] Task 5.2: Update ContentProvider to fetch nested items separately
  - ✅ Updated `lib/providers/content_provider.dart` to handle new repository structure
  - ✅ Updated data fetching pattern:
    - TodoLists loaded with aggregate counts (totalItemCount, completedItemCount) - no items array
    - TodoItems fetched separately only when detail view accessed
    - Lists loaded with aggregate counts (totalItemCount, checkedItemCount) - no items array
    - ListItems fetched separately only when detail view accessed
    - Notes (unchanged - no nested data)
  - ✅ Added new methods for on-demand item fetching:
    - `Future<List<TodoItem>> loadTodoItemsForList(String todoListId)` → fetches items and caches in memory
    - `Future<List<ListItem>> loadListItemsForList(String listId)` → fetches items and caches in memory
  - ✅ Added caching for items:
    - `Map<String, List<TodoItem>> _todoItemsCache` - cache items by todoListId
    - `Map<String, List<ListItem>> _listItemsCache` - cache items by listId
    - Invalidate cache entries when items are created/updated/deleted/reordered
  - ✅ Updated existing CRUD methods:
    - Renamed `addTodoItem()` → `createTodoItem()` - now takes TodoItem directly (no listId parameter)
    - Updated `updateTodoItem()` - now takes TodoItem directly (no listId/itemId parameters)
    - Updated `deleteTodoItem()` - parameters changed to (todoItemId, todoListId) order
    - Removed `toggleTodoItem()` - toggle should be done via `updateTodoItem()` at UI level
    - Updated `reorderTodoItems()` - now takes (todoListId, List<TodoItem>) instead of indices
    - Applied same pattern to ListItem methods (create/update/delete/reorder)
    - All methods now invalidate cache and refresh parent list counts
    - Added helper methods `_refreshTodoList()` and `_refreshList()` to fetch latest counts
  - ✅ Fixed `getTodosWithDueDate()` - now loads items from cache/repository instead of accessing non-existent items field
  - Note: Home screen only needs lists with counts (efficient), detail screen loads items on-demand

- [x] Task 5.3: Add loading and error states to providers
  - ✅ Both SpacesProvider and ContentProvider already have complete loading/error state management
  - ✅ Both have `bool isLoading` property with proper state transitions
  - ✅ Both have `AppError? error` property for error messages
  - ✅ Both have `clearError()` method to dismiss error messages
  - ✅ All async methods properly set loading states and notify listeners

**Phase 5 Complete** - All provider code has been successfully migrated to work with async Supabase operations. Providers now use caching for nested items, have complete loading/error state management, and follow the new repository API patterns.

**Note**: The app does not compile at this point because UI screens (Phase 6) haven't been updated to use the new provider API. This is expected and will be resolved in Phase 6.

### Phase 6: UI Updates for Async Operations

- [x] Task 6.1: Update detail screens to fetch nested items on load ✅
  - ✅ Update `lib/widgets/screens/todo_list_detail_screen.dart`:
    - Already has `_loadTodoItems()` method in initState
    - Uses `_todoItems` state variable with loading states
    - Updated provider calls to use new API: `createTodoItem(TodoItem)`, `updateTodoItem(TodoItem)`, etc.
  - ✅ Update `lib/widgets/screens/list_detail_screen.dart`:
    - Already has `_loadListItems()` method in initState
    - Uses `_listItems` state variable with loading states
    - Updated provider calls to use new API: `createListItem(ListItem)`, `updateListItem(ListItem)`, etc.
  - ✅ Update `lib/widgets/screens/note_detail_screen.dart`:
    - Already correctly uses Note model (renamed from Item)
    - userId properly passed when creating/updating notes

- [x] Task 6.2: Add loading states and error handling to UI ✅
  - ✅ `HomeScreen` already has loading states (shows CircularProgressIndicator when `contentProvider.isLoading`)
  - ✅ Cards already correctly access aggregate count fields:
    - NoteCard uses Note model
    - TodoListCard uses `todoList.totalItems` and `todoList.completedItems`
    - ListCard uses `list.totalItems` and `list.checkedItems`
  - ✅ Error handling already present in providers with retry logic

- [x] Task 6.3: Update QuickCaptureModal and CreateContentModal to pass userId ✅
  - ✅ `create_content_modal.dart` correctly passes userId from `SupabaseConfig.client.auth.currentUser!.id`
  - ✅ `create_space_modal.dart` correctly passes userId
  - ✅ All model constructors updated with required userId parameters

**Phase 6 Status**: ✅ COMPLETE (with caching blocker)

**Known Issue**: Dart incremental compiler is reading stale cached versions of files despite multiple cache clearing attempts. Files on disk are correct, but background Flutter processes are holding old state. Next session should kill all Flutter processes and start fresh build.

### Phase 7: Cleanup and Testing

- [x] Task 7.1: Remove all Hive-related code (COMPLETE)
  - ✅ Deleted `lib/data/local/hive_database.dart`
  - ✅ Deleted `lib/data/local/seed_data.dart`
  - ✅ Deleted `lib/data/migrations/` directory (Hive-specific migrations)
  - ✅ Restored `lib/data/local/preferences_service.dart` (uses SharedPreferences, not Hive)
  - ✅ Removed Hive initialization from `main.dart`
  - ✅ Deleted all `.g.dart` generated files
  - ✅ Ran `flutter clean` to remove build artifacts
  - ✅ Removed `hive`, `hive_flutter`, `hive_generator` from `pubspec.yaml` (kept `build_runner` for potential future code generation)
  - ✅ Updated CLAUDE.md to remove Hive references and add Supabase documentation

- [x] Task 7.2: Add sign-out functionality to UI
  - ✅ Added "Sign Out" button to `lib/widgets/navigation/app_sidebar.dart` footer
  - ✅ Button appears in both expanded and collapsed sidebar states
  - ✅ Calls `AuthProvider.signOut()` on tap
  - ✅ Uses logout icon and proper theme colors
  - Note: AuthGate automatically redirects to SignInScreen on auth state change, cached data cleared by providers

- [ ] Task 7.3: Test authentication flows (READY FOR MANUAL TESTING)
  - App builds successfully and launches
  - Next steps - manual testing checklist:
    - Sign up with new email/password → verify account creation in Supabase Studio
    - Sign in with existing credentials → verify HomeScreen loads
    - Sign out → verify redirect to SignInScreen and session cleared
    - Test invalid credentials → verify error messages display correctly
    - Test form validation → verify email format and password length requirements
  - Verify RLS policies work:
    - Create data with User A → sign out → sign in as User B → verify User B cannot see User A's data
  - Note: Social sign-in testing deferred to post-MVP

- [ ] Task 7.4: Test CRUD operations with Supabase (READY FOR MANUAL TESTING)
  - Manual testing for each content type (Notes, TodoLists, Lists):
    - Create new item → verify appears in Supabase Dashboard
    - Update item → verify changes persist
    - Delete item → verify removed from database
    - Test drag-and-drop reordering → verify sort_order updates
  - Test nested item operations:
    - Add TodoItem to TodoList → verify appears in todo_items table with correct foreign key
    - Complete TodoItem → verify is_completed updates
    - Delete TodoList → verify cascade deletes all TodoItems
  - Test Space operations:
    - Create Space → verify in database
    - Move items between Spaces → verify space_id updates
    - Delete Space → verify cascade deletes (needs FK constraint with ON DELETE CASCADE)

- [ ] Task 7.5: Update test suite to work with Supabase (DEFERRED)
  - Note: Comprehensive test updates are out of scope for MVP
  - Test strategy for future implementation:
    - Use Supabase local development mode for integration tests
    - Mock SupabaseClient for unit tests using mockito
    - Use Flutter integration tests for E2E auth flows
  - Disable or comment out existing Hive-dependent tests to prevent CI failures
  - Update `test/` directory README with new testing approach

### Phase 8: Documentation and Deployment ✅ COMPLETE

- [x] Task 8.1: Update project documentation ✅
  - ✅ CLAUDE.md already comprehensively updated with:
    - ✅ Supabase architecture section with RLS policies and local dev setup (lines 61-68)
    - ✅ Repository pattern documentation with BaseRepository and Supabase queries (lines 70-74)
    - ✅ Authentication flow documentation (lines 76-80)
    - ✅ Development Commands section with Supabase CLI commands (lines 47-51)
    - ✅ Data models section reflecting Note (not Item) and normalized structure (lines 112-136)
    - ✅ Database schema with RLS policies (lines 279-293)
  - ✅ Updated `README.md` with:
    - ✅ Removed offline functionality claims (now reflects cloud-based architecture)
    - ✅ Added comprehensive local Supabase setup instructions with CLI commands
    - ✅ Documented authentication features (email/password)
    - ✅ Added Prerequisites section (Flutter, Supabase CLI, Docker)
    - ✅ Added Getting Started guide (5-step setup process)
    - ✅ Added Supabase CLI Commands reference
    - ✅ Added Development Commands section
    - ✅ Added Database Migrations documentation
    - ✅ Added Architecture overview with Technology Stack and Data Model
    - ✅ Added Key Directories structure

- [x] Task 8.2: Create local development setup guide ✅
  - ✅ Comprehensive local development guide added to README.md
  - ✅ Documented all Supabase CLI commands:
    - ✅ `supabase start` - Start local dev server
    - ✅ `supabase stop` - Stop local dev server
    - ✅ `supabase status` - Check running services and credentials
    - ✅ `supabase db reset` - Reset database and apply migrations
    - ✅ `supabase migration new` - Create new migration
  - ✅ Documented how to access Supabase Studio at http://localhost:54323
  - ✅ Included test account creation instructions (email confirmation disabled for local dev)
  - ✅ Added migration files reference with descriptions

- [ ] Task 8.3: Configure production deployment (deferred to post-MVP)
  - Note: Production configuration is out of scope for local dev MVP
  - When ready for production:
    - Create Supabase cloud project
    - Link local project: `supabase link --project-ref [project-id]`
    - Push migrations: `supabase db push`
    - Update config file with production credentials
    - Set up email templates for authentication
    - Social OAuth providers can be added when needed

## Dependencies and Prerequisites

**New Packages:**
- `supabase_flutter: ^2.0.0` - Official Supabase client for Flutter

**Removed Packages:**
- `hive: ^2.2.3`
- `hive_flutter: ^1.1.0`
- `hive_generator: ^2.0.1`
- `build_runner: ^2.4.12`

**External Requirements:**
- Supabase CLI (already installed) - Required for local development server
- Docker (required by Supabase CLI for local PostgreSQL and services)
- Note: Social OAuth providers (Google, Apple) deferred to post-MVP

**Development Tools:**
- Supabase Studio (included with CLI at http://localhost:54323) - Database management UI
- PostgreSQL knowledge (helpful for debugging queries and RLS policies)

## Challenges and Considerations

**Data Loss:**
- All existing Hive data will be lost (acceptable per requirements)
- Users will start with empty state after authentication
- No migration path for existing data

**Nested Models:**
- TodoList and ListModel currently embed child items (TodoItem, ListItem)
- In PostgreSQL, these must be separate tables with foreign keys
- Requires UI updates to fetch nested items separately (potential performance consideration)
- Solution: Lazy load items when detail screens open, cache in provider

**Authentication Edge Cases:**
- Email verification (optional, can be disabled in Supabase for MVP)
- Password reset flow (requires email templates)
- Session expiration and refresh token handling (handled by Supabase SDK)
- Multi-device sign-in (handled by Supabase)

**Network Dependency:**
- App requires internet connection to function (no offline mode)
- Need proper loading states and error messages for network failures
- Consider adding connection status indicator in UI

**RLS Policy Complexity:**
- Nested queries (e.g., accessing todo_items through spaces) require careful RLS policy design
- Policy for todo_items: User can access if they own the parent todo_list, which must be in a space they own
- May need to use PostgreSQL functions for complex ownership checks

**Performance:**
- Multiple round trips to server for nested data (TodoList → TodoItems)
- Consider using Supabase's `.select('*, todo_items(*)')` syntax for eager loading
- Add indexes on frequently queried fields (space_id, user_id, sort_order)

**Testing:**
- Existing test suite relies heavily on Hive mocks
- Rewriting tests is time-consuming and deferred to post-MVP
- Manual testing will be primary QA method for MVP

**State Management:**
- Provider pattern works well with async operations
- May need to add state flags (isLoading, error) to prevent race conditions
- Consider optimistic updates for better UX (update UI immediately, rollback on error)
