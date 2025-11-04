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

- [ ] Task 3.1: Update model classes to remove Hive annotations
  - Remove `@HiveType` and `@HiveField` annotations from all models (Note, Space, TodoList, TodoItem, ListModel, ListItem, enums)
  - Remove `part 'model_name.g.dart';` imports
  - Remove `import 'package:hive/hive.dart';` statements
  - Keep existing `fromJson()` and `toJson()` methods (compatible with Supabase)
  - Update `fromJson()` to handle PostgreSQL UUID strings and timestamp formats
  - Update enums (TodoPriority, ListStyle) to use string serialization for PostgreSQL

- [ ] Task 3.2: Add user_id field to models for multi-tenancy
  - Add `final String userId;` field to Space, Note, TodoList, ListModel
  - Update constructors to require userId parameter
  - Update `fromJson()` and `toJson()` methods to include userId
  - Update `copyWith()` methods to include optional userId parameter
  - Note: userId will be populated from `auth.uid()` in repositories, not passed from UI

- [ ] Task 3.3: Normalize nested models for relational database
  - TodoList: Remove embedded `List<TodoItem>` field, replace with repository method to fetch items
  - ListModel: Remove embedded `List<ListItem>` field, replace with repository method to fetch items
  - Update `totalItems`, `completedItems`, `progress` getters to accept items as parameters (calculated in UI layer)
  - Keep model classes simple and focused on data representation

- [ ] Task 3.4: Rename Item model to Note for clarity
  - Rename `lib/data/models/item_model.dart` to `note_model.dart`
  - Rename class `Item` to `Note` in the file
  - Update all imports throughout the codebase from `item_model.dart` to `note_model.dart`
  - Update all type references from `Item` to `Note` (variables, parameters, return types, generics)
  - Update file references:
    - Repository: `note_repository.dart` already uses correct naming (no change needed)
    - Provider: Update `ContentProvider` to use `Note` type instead of `Item`
    - Widgets: Update `ItemCard` to `NoteCard` in `design_system/molecules/`
    - Update all imports and usages of `ItemCard` to `NoteCard`
  - Update variable names: `item` → `note`, `items` → `notes`, `getItem` → `getNote`, etc.
  - Update comments and documentation strings that reference "Item" to say "Note"
  - Find and replace pattern: Search for "Item" (case-sensitive) in context of notes and replace with "Note"
  - Verify no regressions by running `flutter analyze` after changes

### Phase 4: Repository Layer Rewrite

- [ ] Task 4.1: Create base Supabase repository
  - Create `lib/data/repositories/base_repository.dart` with:
    - Protected `supabase` getter accessing SupabaseClient singleton
    - Protected `userId` getter from `supabase.auth.currentUser!.id`
    - Helper method `handleSupabaseError(error)` to map Supabase exceptions to AppError
    - Helper method `executeQuery<T>(Future<T> Function() query)` with try-catch and error handling

- [ ] Task 4.2: Rewrite SpaceRepository for Supabase
  - Update `lib/data/repositories/space_repository.dart` to extend BaseRepository
  - Replace Hive box operations with Supabase queries:
    - `getAllSpaces()` → `supabase.from('spaces').select().eq('user_id', userId).order('created_at')`
    - `getSpaceById(id)` → `supabase.from('spaces').select().eq('id', id).eq('user_id', userId).single()`
    - `createSpace(space)` → `supabase.from('spaces').insert(space.toJson()..addAll({'user_id': userId}))`
    - `updateSpace(space)` → `supabase.from('spaces').update(space.toJson()).eq('id', space.id).eq('user_id', userId)`
    - `deleteSpace(id)` → `supabase.from('spaces').delete().eq('id', id).eq('user_id', userId)`
    - `getItemCount(spaceId)` → Query counts from notes, todo_lists, and lists tables (similar to SpaceItemCountService logic)
  - Remove Hive-specific code (box access, keys iteration)
  - Add error handling for network errors, auth errors, RLS violations

- [ ] Task 4.3: Rewrite NoteRepository for Supabase
  - Update `lib/data/repositories/note_repository.dart` to extend BaseRepository
  - Replace Hive operations with Supabase queries:
    - `getAllNotes()` → `supabase.from('notes').select().eq('user_id', userId).order('sort_order')`
    - `getNotesBySpaceId(spaceId)` → Add `.eq('space_id', spaceId)` filter
    - `getNoteById(id)` → `supabase.from('notes').select().eq('id', id).single()`
    - `createNote(note)` → Insert with user_id
    - `updateNote(note)` → Update with user_id check
    - `deleteNote(id)` → Delete with user_id check
    - `updateSortOrders(List<Item> notes)` → Batch update via `.upsert()`
  - Remove Hive-specific code
  - Handle PostgreSQL array type for tags field

- [ ] Task 4.4: Rewrite TodoListRepository for Supabase
  - Update `lib/data/repositories/todo_list_repository.dart` to extend BaseRepository
  - Replace Hive operations with Supabase queries:
    - `getAllTodoLists()` → Query todo_lists table with user_id filter
    - `getTodoListById(id)` → Single query with RLS check
    - `createTodoList(todoList)` → Insert into todo_lists table only (no nested items)
    - `updateTodoList(todoList)` → Update todo_lists table
    - `deleteTodoList(id)` → Delete todo_list (cascade deletes todo_items via FK constraint)
    - `getTodoItemsForList(todoListId)` → Query todo_items table with foreign key filter
    - `createTodoItem(todoItem)` → Insert into todo_items table
    - `updateTodoItem(todoItem)` → Update todo_items table
    - `deleteTodoItem(id)` → Delete from todo_items table
    - `updateTodoItemSortOrders(List<TodoItem> items)` → Batch upsert
  - Remove embedded list logic (todos are now separate queries)

- [ ] Task 4.5: Rewrite ListRepository for Supabase
  - Update `lib/data/repositories/list_repository.dart` to extend BaseRepository
  - Replace Hive operations with Supabase queries:
    - `getAllLists()` → Query lists table with user_id filter
    - `getListById(id)` → Single query with RLS check
    - `createList(list)` → Insert into lists table only (no nested items)
    - `updateList(list)` → Update lists table
    - `deleteList(id)` → Delete list (cascade deletes list_items via FK constraint)
    - `getListItemsForList(listId)` → Query list_items table with foreign key filter
    - `createListItem(listItem)` → Insert into list_items table
    - `updateListItem(listItem)` → Update list_items table
    - `deleteListItem(id)` → Delete from list_items table
    - `updateListItemSortOrders(List<ListItem> items)` → Batch upsert
  - Remove embedded list logic (items are now separate queries)

### Phase 5: Provider Layer Updates

- [ ] Task 5.1: Update SpacesProvider to work with async Supabase operations
  - Update `lib/providers/spaces_provider.dart` to handle async repository calls
  - Replace synchronous Hive listeners with explicit refresh pattern
  - Update `loadSpaces()` to be async and handle loading/error states
  - Update `createSpace()`, `updateSpace()`, `deleteSpace()` to await repository calls and refresh spaces list
  - Remove `getSpaceItemCount()` if SpaceRepository already returns counts

- [ ] Task 5.2: Update ContentProvider to fetch nested items separately
  - Update `lib/providers/content_provider.dart` to handle new repository structure
  - Replace single query pattern with separate queries for:
    - TodoLists (without items)
    - TodoItems (fetched per list when needed)
    - Lists (without items)
    - ListItems (fetched per list when needed)
    - Notes (unchanged)
  - Add methods:
    - `loadTodoItemsForList(todoListId)` → fetches and caches items
    - `loadListItemsForList(listId)` → fetches and caches items
  - Update existing CRUD methods to handle async operations and error states
  - Consider adding local caching strategy for better UX (optional for MVP)

- [ ] Task 5.3: Add loading and error states to providers
  - Add `bool isLoading` and `String? errorMessage` properties to SpacesProvider and ContentProvider
  - Notify listeners when loading states change
  - Expose error messages to UI for user feedback
  - Add `clearError()` methods to dismiss error messages

### Phase 6: UI Updates for Async Operations

- [ ] Task 6.1: Update detail screens to fetch nested items on load
  - Update `lib/widgets/screens/todo_list_detail_screen.dart`:
    - Remove assumption that TodoList contains items
    - Add `initState()` to call `ContentProvider.loadTodoItemsForList(todoListId)`
    - Use `FutureBuilder` or loading state to show shimmer while items load
    - Update item CRUD operations to refresh items after changes
  - Update `lib/widgets/screens/list_detail_screen.dart`:
    - Similar pattern to fetch ListItems on screen load
    - Add loading states and error handling
  - Update `lib/widgets/screens/note_detail_screen.dart`:
    - Ensure userId is populated when creating/updating notes
    - No major structural changes needed (notes are not nested)

- [ ] Task 6.2: Add loading states and error handling to UI
  - Update `HomeScreen` to show loading shimmer while spaces and content load
  - Add error banners/snackbars to display provider error messages
  - Update cards (NoteCard, TodoListCard, ListCard) to handle missing data gracefully
  - Add retry buttons for failed operations
  - Ensure all user actions show loading indicators (e.g., disable buttons during async operations)

- [ ] Task 6.3: Update QuickCaptureModal to pass userId
  - Update `lib/widgets/modals/quick_capture_modal.dart`:
    - Get current userId from AuthProvider or Supabase client
    - Pass userId to ContentProvider when creating new items
    - No major UI changes needed

### Phase 7: Cleanup and Testing

- [ ] Task 7.1: Remove all Hive-related code
  - Delete `lib/data/local/hive_database.dart`
  - Delete `lib/data/migrations/` directory (Hive-specific migrations)
  - Delete `lib/data/local/seed_data.dart` (no longer needed - users start with empty state)
  - Remove Hive imports from all files
  - Remove Hive initialization from `main.dart`
  - Delete all `.g.dart` generated files (run `flutter clean` to remove build artifacts)
  - Remove `hive`, `hive_flutter`, `hive_generator`, and `build_runner` from `pubspec.yaml`
  - Update CLAUDE.md to remove Hive references and add Supabase documentation

- [ ] Task 7.2: Add sign-out functionality to UI
  - Add "Sign Out" option to app settings or user profile menu
  - Update `lib/widgets/organisms/app_sidebar.dart` or create settings screen
  - Call `AuthProvider.signOut()` and navigate to SignInScreen
  - Clear any cached data in providers after sign out

- [ ] Task 7.3: Test authentication flows
  - Manual testing:
    - Sign up with new email/password → verify account creation in Supabase Studio
    - Sign in with existing credentials → verify HomeScreen loads
    - Sign out → verify redirect to SignInScreen and session cleared
    - Test invalid credentials → verify error messages display correctly
    - Test form validation → verify email format and password length requirements
  - Verify RLS policies work:
    - Create data with User A → sign out → sign in as User B → verify User B cannot see User A's data
  - Note: Social sign-in testing deferred to post-MVP

- [ ] Task 7.4: Test CRUD operations with Supabase
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

- [ ] Task 7.5: Update test suite to work with Supabase (deferred)
  - Note: Comprehensive test updates are out of scope for MVP
  - Disable or comment out existing Hive-dependent tests to prevent CI failures
  - Document test strategy for future implementation:
    - Use Supabase local development mode for integration tests
    - Mock SupabaseClient for unit tests
    - Use Flutter integration tests for E2E auth flows
  - Update `test/` directory README with new testing approach

### Phase 8: Documentation and Deployment

- [ ] Task 8.1: Update project documentation
  - Update `CLAUDE.md`:
    - Remove Hive architecture section
    - Add Supabase architecture section with RLS policies and local dev setup
    - Update repository pattern documentation (BaseRepository, Supabase queries)
    - Add authentication flow documentation (AuthService, AuthProvider, AuthGate)
    - Update "Development Commands" section (remove build_runner, add Supabase CLI commands)
    - Update data models section to reflect Note (not Item) and normalized structure
  - Update `README.md` (if exists):
    - Add local Supabase setup instructions with CLI commands
    - Document authentication features (email/password only for MVP)
    - Add note about local-first development approach
    - Note: Social login documentation deferred until implementation

- [ ] Task 8.2: Create local development setup guide
  - Document Supabase CLI commands in README:
    - `supabase start` - Start local dev server
    - `supabase stop` - Stop local dev server
    - `supabase status` - Check running services and get credentials
    - `supabase db reset` - Reset database and apply migrations
  - Document how to access Supabase Studio at http://localhost:54323
  - Note: Production deployment guide will be added when deploying to cloud

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
