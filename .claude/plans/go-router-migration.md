# go_router Migration Plan

## Objective and Scope

Migrate the Later app from imperative navigation (MaterialApp with `home` property and manual Navigator calls) to **declarative routing with go_router**. This will implement state-of-the-art authentication-aware routing, eliminate the dead-end error screen in AuthGate, enable deep linking support, and provide a foundation for future web deployment.

**Scope:**
- Replace AuthGate widget with go_router redirect guards
- **Replace AsyncValue-based AuthStateController with Stream-based authStreamProvider** for cleaner reactive auth state
- Configure declarative routes for all 8 screens
- Replace **13 imperative Navigator calls** across 5 files:
  - 2 calls in auth screens (sign-in ↔ sign-up)
  - 5 calls in HomeScreen (detail screen navigation + search + upgrade)
  - 5 calls in SearchResultCard (detail screen navigation for search results)
  - 1 call in UpgradeRequiredDialog (upgrade screen navigation)
- Integrate Riverpod auth stream with go_router's refreshListenable
- Add type-safe route parameters for detail screens
- Keep modal/dialog navigation with `Navigator.pop()` unchanged (standard practice)
- Refactor all UI components to use stream-based auth instead of AsyncValue

**Non-Goals:**
- Nested navigation (not needed for current app structure)
- Custom page transitions (use go_router defaults)
- Route-based analytics (future enhancement)

## Technical Approach and Reasoning

### Why go_router?

Based on the research document findings:
1. **Official Flutter recommendation** - Maintained by Flutter team, feature-complete
2. **Maintenance mode = maturity** - Not abandoned, just stable
3. **Seamless Riverpod integration** - Well-documented `refreshListenable` pattern
4. **Declarative routing** - Modern Flutter standard, navigation as function of state
5. **Future-proof** - Enables web support, deep linking without refactoring
6. **Minimal migration effort** - Only 2 Navigator calls to replace, 8 screens total

### Architecture Decision

**Router Structure:**
```
lib/core/routing/
├── app_router.dart           # Router provider + route configuration
├── app_router.g.dart         # Generated Riverpod code
└── routes.dart               # Route path constants
```

**Route Guard Strategy:**
- Use top-level `redirect` callback for authentication checks
- Auth state from `authStateControllerProvider` determines routing
- Loading state shows spinner screen
- Error state fallback to SignInScreen (eliminates dead-end)
- Unauthenticated users redirect to `/auth/sign-in`
- Authenticated users on auth routes redirect to `/`

**Key Technical Decisions:**
1. **Stream-based auth state** - Replace AsyncValue-based AuthStateController with StreamProvider for cleaner reactive auth without artificial loading/error states
2. **GoRouterRefreshStream wrapper** - Convert auth stream to ChangeNotifier for go_router reactivity
3. **Error screen elimination** - Fallback to SignInScreen instead of showing error (per research recommendations)
4. **Route parameters** - Use path parameters (`:id`) for detail screens, not query parameters
5. **Auth operations remain in controller** - Create AuthController (not State) for sign-in/sign-up/sign-out operations, separate from stream state
6. **Pass full objects vs IDs** - Currently Navigator passes full objects (note, todoList, list) to detail screens. With go_router, we'll pass IDs via route parameters and let detail screens fetch data via Riverpod providers
7. **Application layer decoupling** - Auth stream goes through AuthApplicationService, not directly from Supabase, maintaining clean architecture

## Implementation Phases

### Phase 1: Setup and Stream-Based Auth Migration (~3-4 hours) ✅ COMPLETED

**Goal:** Add go_router dependency, replace AsyncValue-based auth with Stream-based auth, and create basic router configuration.

**Status:** ✅ **COMPLETED** - All tasks finished successfully. Stream-based auth is now in place, old AuthStateController deleted, routing infrastructure ready for Phase 2.

- [x] Task 1.1: Add go_router dependency
  - Add `go_router: ^14.6.2` to `pubspec.yaml` dependencies
  - Run `flutter pub get` to install
  - Verify no version conflicts with existing packages

- [x] Task 1.2: Create stream-based auth provider
  - Add to `lib/features/auth/application/providers.dart`
  - Create `authStreamProvider` using `@Riverpod(keepAlive: true)` and `Stream<User?>`
  - Watch `authApplicationServiceProvider` and map `authStateChanges()` to `User?`
  - Stream emits current user or null, no loading/error states
  - Run `dart run build_runner build --delete-conflicting-outputs` to generate provider code

- [x] Task 1.3: Create AuthController for auth operations
  - Create `lib/features/auth/presentation/controllers/auth_controller.dart`
  - Use `@riverpod` (NOT `@Riverpod(keepAlive: true)`) - stateless controller
  - Move sign-in, sign-up, sign-out, anonymous sign-in, upgrade methods from AuthStateController
  - These methods don't manage state, they just call AuthApplicationService and throw errors
  - UI components handle local loading states, not the controller
  - Run `dart run build_runner build --delete-conflicting-outputs`

- [x] Task 1.4: Update SignInScreen to use stream-based auth
  - Remove `ref.watch(authStateControllerProvider)` - no longer exists
  - Use `ref.watch(authStreamProvider)` to get current user (for checking if already authenticated)
  - Call `ref.read(authControllerProvider).signIn()` for sign-in operation
  - Keep local `_isSigningIn` state for loading indicator
  - Keep `ref.listen` for error handling (catches thrown errors from controller)
  - Remove any `.when()` calls on AsyncValue
  - Test that sign-in still works correctly

- [x] Task 1.5: Update SignUpScreen to use stream-based auth
  - Remove `ref.watch(authStateControllerProvider)`
  - Use `ref.watch(authStreamProvider)` to get current user
  - Call `ref.read(authControllerProvider).signUp()` for sign-up operation
  - Keep local `_isSigningUp` state for loading indicator
  - Keep `ref.listen` for error handling
  - Remove any `.when()` calls on AsyncValue
  - Test that sign-up still works correctly

- [x] Task 1.6: Update AuthGate to use stream-based auth
  - Change to use `ref.watch(authStreamProvider)` instead of `authStateControllerProvider`
  - Stream returns `AsyncValue<User?>` from Riverpod (wraps the stream automatically)
  - Use `.when()` to handle loading (initial stream connection), data (user or null), error (stream error)
  - Loading state now represents stream initialization, not auth check
  - This is temporary - AuthGate will be deleted in Phase 3
  - Test that app routing still works during this transition

- [x] Task 1.7: Create route constants file
  - Create `lib/core/routing/routes.dart`
  - Define constant strings for all route paths:
    - `/` - Home
    - `/auth/sign-in` - Sign in screen
    - `/auth/sign-up` - Sign up screen
    - `/auth/account-upgrade` - Account upgrade screen
    - `/notes/:id` - Note detail screen
    - `/todos/:id` - Todo list detail screen
    - `/lists/:id` - List detail screen
    - `/search` - Search screen
  - Export constants with descriptive names (e.g., `kRouteHome`, `kRouteSignIn`, etc.)

- [x] Task 1.8: Create GoRouterRefreshStream helper
  - Create `lib/core/routing/go_router_refresh_stream.dart`
  - Implement ChangeNotifier wrapper for auth stream (made generic to accept `Stream<dynamic>`)
  - Constructor accepts any stream type and subscribes
  - Call `notifyListeners()` on stream events
  - Properly dispose subscription in `dispose()` override
  - Make stream subscription broadcast to support multiple listeners

- [x] Task 1.9: Create basic router provider structure
  - Create `lib/core/routing/app_router.dart` with `@riverpod` annotation
  - Define `routerProvider` returning `GoRouter` instance
  - Set `initialLocation: '/auth/sign-in'` (initial route before auth check completes)
  - Add empty `routes` list (to be filled in Phase 2)
  - Add placeholder `redirect` callback returning `null` (to be implemented in Phase 2)
  - Add `errorBuilder` that shows SignInScreen as fallback
  - Do NOT integrate auth state yet (Phase 2)
  - Run `dart run build_runner build --delete-conflicting-outputs` to generate code

- [x] Task 1.10: Delete old AuthStateController
  - ✅ Updated all 6 files to use new providers:
    - `lib/core/permissions/permission_service.dart` - uses `authStreamProvider`
    - `lib/features/auth/presentation/screens/account_upgrade_screen.dart` - uses `authController` with local loading state
    - `lib/features/home/presentation/screens/home_screen.dart` - uses `authStreamProvider` and `authController`
    - `lib/features/home/presentation/widgets/create_content_modal.dart` - uses `authStreamProvider`
    - `lib/features/spaces/presentation/widgets/create_space_modal.dart` - uses `authStreamProvider`
    - `lib/shared/widgets/navigation/app_sidebar.dart` - uses `authStreamProvider` and `authController`
  - ✅ Deleted `lib/features/auth/presentation/controllers/auth_state_controller.dart`
  - ✅ Deleted `lib/features/auth/presentation/controllers/auth_state_controller.g.dart`
  - ✅ Deleted `test/features/auth/presentation/controllers/auth_state_controller_test.dart`
  - ✅ Ran `flutter analyze` - only 1 minor doc comment warning, no errors

### Phase 2: Route Definitions and Auth Guards (~2 hours) ✅ COMPLETED

**Goal:** Define all application routes and implement authentication-aware redirect logic.

**Status:** ✅ **COMPLETED** - All tasks finished successfully. Routes defined for all 8 screens (3 auth, 5 protected). Authentication redirect guard implemented with stream-based reactivity. Router will automatically redirect users based on auth state when integrated in Phase 3.

**Note:** Detail screen routes (notes, todos, lists) pass ID parameters but detail screen constructors still expect full objects. This creates temporary errors that will be resolved in Phase 4 Task 4.7 when constructors are updated to accept IDs.

- [x] Task 2.1: Define unauthenticated routes
  - ✅ Added `/auth/sign-in` route → SignInScreen
  - ✅ Added `/auth/sign-up` route → SignUpScreen
  - ✅ Added `/auth/account-upgrade` route → AccountUpgradeScreen
  - ✅ Used `GoRoute` with `path` and `builder` properties
  - ✅ No route guards needed (public routes)

- [x] Task 2.2: Define authenticated routes
  - ✅ Added `/` route → HomeScreen
  - ✅ Added `/notes/:id` route → NoteDetailScreen with `state.pathParameters['id']!`
  - ✅ Added `/todos/:id` route → TodoListDetailScreen with `state.pathParameters['id']!`
  - ✅ Added `/lists/:id` route → ListDetailScreen with `state.pathParameters['id']!`
  - ✅ Added `/search` route → SearchScreen
  - ✅ Routes will be protected by top-level redirect guard
  - ⚠️ Temporary errors: Detail screen constructors need to be updated in Phase 4 to accept `noteId`, `todoListId`, `listId` parameters

- [x] Task 2.3: Implement authentication redirect guard
  - ✅ Get auth service in router provider: `ref.read(authApplicationServiceProvider)`
  - ✅ Create `refreshListenable` using `GoRouterRefreshStream(authService.authStateChanges().map(...))`
  - ✅ Implement `redirect` callback with complete logic:
    1. ✅ Read auth stream value: `final authValue = ref.read(authStreamProvider)`
    2. ✅ Check if stream has value: `if (!authValue.hasValue) return null`
    3. ✅ Extract user: `final user = authValue.value`
    4. ✅ Extract authenticated flag: `final isAuthenticated = user != null`
    5. ✅ Detect auth routes: `final isOnAuthRoute = state.matchedLocation.startsWith('/auth')`
    6. ✅ If not authenticated and not on auth route → redirect to `/auth/sign-in`
    7. ✅ If authenticated and on auth route → redirect to `/`
    8. ✅ Otherwise return `null` (no redirect needed)
  - ✅ Added debug logging for redirect decisions (wrapped in `kDebugMode`)
  - ✅ Stream errors handled by falling back to sign-in screen in errorBuilder

- [x] Task 2.4: Verify SignInScreen stream behavior
  - ✅ SignInScreen configured as initial route
  - ✅ Auth stream will emit immediately from Supabase (synchronous from currentUser)
  - ✅ No special loading state handling needed - stream provides immediate value
  - ✅ If stream is slow, user sees sign-in form briefly (acceptable UX)
  - ⏭️ Full app startup testing will occur in Phase 3 when router is integrated

### Phase 3: Main App Integration (~30 minutes) ✅ COMPLETED

**Goal:** Replace MaterialApp with MaterialApp.router and remove AuthGate widget.

**Status:** ✅ **COMPLETED** - All tasks finished successfully. App now uses MaterialApp.router with go_router. AuthGate deprecated and marked for removal in Phase 5. Router is integrated and will automatically handle authentication-aware navigation.

**Known Issues (Expected):**
- Flutter analyze shows 6 errors in app_router.dart for detail screen constructors (NoteDetailScreen, TodoListDetailScreen, ListDetailScreen) expecting full objects instead of IDs. This is expected and documented in Phase 2 notes - will be resolved in Phase 4 Task 4.7 when detail screens are refactored to accept ID parameters.

- [x] Task 3.1: Update main.dart to use MaterialApp.router
  - ✅ Added `final router = ref.watch(routerProvider)` in `_MyApp` widget
  - ✅ Replaced `MaterialApp(home: AuthGate())` with `MaterialApp.router(routerConfig: router)`
  - ✅ Kept all existing properties (title, theme, darkTheme, themeMode, localization)
  - ✅ Kept themeAnimationDuration and themeAnimationCurve
  - ✅ Removed `home` property entirely
  - ✅ Updated import from AuthGate to app_router

- [x] Task 3.2: Verify AuthGate is no longer used
  - ✅ Searched codebase for `AuthGate` imports and usage
  - ✅ Confirmed only references are in `auth_gate.dart` file itself and one comment in create_content_modal.dart
  - ✅ File kept for Phase 5 deletion after full testing
  - ✅ Added prominent deprecation comment in AuthGate file noting it's deprecated and will be removed

- [x] Task 3.3: Update pubspec.yaml and imports
  - ✅ Verified go_router: ^14.6.2 is in dependencies list (line 20)
  - ✅ Ran `flutter pub get` - clean dependency resolution
  - ✅ No barrel export files needed updating

### Phase 4: Replace Imperative Navigation (~4-5 hours)

**Goal:** Replace all 13 Navigator calls across 5 files with go_router navigation, and update detail screens to accept ID parameters.

- [ ] Task 4.1: Update SignInScreen navigation
  - Import `package:go_router/go_router.dart` and route constants
  - Replace `_navigateToSignUp()` method implementation:
    - Change `Navigator.of(context).pushReplacement(...)` to `context.go(kRouteSignUp)`
  - Remove MaterialPageRoute and SignUpScreen widget import (still imported for types elsewhere)
  - Test that sign-in → sign-up navigation works with new routing

- [ ] Task 4.2: Update SignUpScreen navigation
  - Import `package:go_router/go_router.dart` and route constants
  - Replace `_navigateToSignIn()` method implementation:
    - Change `Navigator.of(context).pushReplacement(...)` to `context.go(kRouteSignIn)`
  - Remove MaterialPageRoute and SignInScreen widget import (still imported for types elsewhere)
  - Test that sign-up → sign-in navigation works with new routing

- [ ] Task 4.3: Verify authentication flow triggers navigation
  - After successful sign-in, AuthStateController updates auth state
  - Router's refreshListenable triggers redirect evaluation
  - Redirect guard sees authenticated user and redirects to `/`
  - User automatically navigates to HomeScreen without manual navigation call
  - Same flow for sign-up and anonymous sign-in

- [ ] Task 4.4: Update HomeScreen navigation (5 calls)
  - Import `package:go_router/go_router.dart` and route constants
  - Replace navigation to NoteDetailScreen: `context.push('/notes/${note.id}')`
  - Replace navigation to TodoListDetailScreen: `context.push('/todos/${todoList.id}')`
  - Replace navigation to ListDetailScreen: `context.push('/lists/${list.id}')`
  - Replace navigation to SearchScreen: `context.push(kRouteSearch)`
  - Replace navigation to AccountUpgradeScreen: `context.push(kRouteAccountUpgrade)`
  - Remove MaterialPageRoute imports

- [ ] Task 4.5: Update SearchResultCard navigation (5 calls)
  - Import `package:go_router/go_router.dart` and route constants
  - Replace navigation to NoteDetailScreen: `context.push('/notes/${note.id}')`
  - Replace navigation to TodoListDetailScreen: `context.push('/todos/${todoList.id}')`
  - Replace navigation to ListDetailScreen: `context.push('/lists/${list.id}')`
  - Handle parent TodoList navigation: `context.push('/todos/${parentTodoList.id}')`
  - Handle parent List navigation: `context.push('/lists/${parentList.id}')`
  - Remove MaterialPageRoute imports

- [ ] Task 4.6: Update UpgradeRequiredDialog navigation (1 call)
  - Import `package:go_router/go_router.dart` and route constants
  - Keep `Navigator.pop()` for closing dialog (standard practice)
  - Replace navigation to AccountUpgradeScreen: `context.push(kRouteAccountUpgrade)`
  - Remove MaterialPageRoute import

- [ ] Task 4.7: Update detail screens to accept ID parameters
  - Update NoteDetailScreen constructor to accept `String noteId` instead of `Note note`
  - Update TodoListDetailScreen constructor to accept `String todoListId` instead of `TodoList todoList`
  - Update ListDetailScreen constructor to accept `String listId` instead of `ListModel list`
  - Update each detail screen to fetch data via Riverpod provider using the ID parameter
  - Handle loading and error states while fetching data
  - Add null checks for when data is not found (show error screen or redirect)

### Phase 5: Testing and Validation (~3-4 hours)

**Goal:** Comprehensive testing of all routing scenarios and edge cases.

- [ ] Task 5.1: Test authentication routing flows
  - Start app unauthenticated → should show SignInScreen
  - Sign in successfully → should redirect to HomeScreen
  - Sign out from HomeScreen → should redirect to SignInScreen
  - Start app with existing session → should restore to HomeScreen directly
  - AuthStateController initialization error → should show SignInScreen (no dead-end)
  - Test anonymous sign-in flow

- [ ] Task 5.2: Test auth screen transitions
  - SignInScreen → "Don't have an account?" link → SignUpScreen
  - SignUpScreen → "Already have an account?" link → SignInScreen
  - Verify no back button navigation issues
  - Verify form state doesn't persist across transitions (expected behavior)

- [ ] Task 5.3: Test protected route navigation
  - From HomeScreen, open note → NoteDetailScreen with correct ID
  - From HomeScreen, open todo list → TodoListDetailScreen with correct ID
  - From HomeScreen, open list → ListDetailScreen with correct ID
  - Verify back button returns to HomeScreen
  - Test deep link to protected route while unauthenticated → redirect to SignInScreen

- [ ] Task 5.4: Test edge cases and error handling
  - Invalid route path → should show SignInScreen (errorBuilder)
  - Navigate to protected route without auth → redirect to SignInScreen
  - Navigate to auth route while authenticated → redirect to HomeScreen
  - App state changes while on wrong screen → automatic redirect
  - Multiple rapid auth state changes → no navigation loops
  - Test on both Android and iOS platforms

- [ ] Task 5.5: Update and run existing tests
  - Update widget tests that reference AuthGate to use router
  - Update tests that mock Navigator to work with go_router
  - Run `flutter test` and fix any failing tests
  - Update `test_helpers.dart` if needed for router testing
  - Verify test coverage remains above 70%

### Phase 6: Cleanup and Documentation (~1 hour)

**Goal:** Remove deprecated code, update documentation, and prepare for production.

**Total Estimated Time: 15-17.5 hours** (includes stream-based auth migration + 13 navigation calls + detail screen refactoring)

- [ ] Task 6.1: Remove deprecated code
  - Delete `lib/features/auth/presentation/widgets/auth_gate.dart`
  - Remove AuthGate imports from any test files
  - Search for "TODO: Future improvement - migrate to go_router" comments and remove
  - Run `flutter analyze` to ensure no unused imports

- [ ] Task 6.2: Update CLAUDE.md documentation
  - Remove AuthGate reference from architecture section
  - Add new "Routing" section describing go_router setup
  - Document route constants and how to add new routes
  - Document authentication redirect guard logic
  - Add example of navigating to detail screens with parameters
  - Update "Adding a New Content Type" section to include route definition step

- [ ] Task 6.3: Add inline code documentation
  - Add comprehensive dartdoc comments to `app_router.dart`
  - Document redirect guard logic and authentication flow
  - Add usage examples for common navigation patterns
  - Document GoRouterRefreshStream purpose and usage
  - Add comments explaining route parameter extraction

- [ ] Task 6.4: Update research document status
  - Mark research document as "Implemented" in `.claude/research/auth-routing-error-handling-best-practices.md`
  - Add implementation completion date
  - Add link to this implementation plan
  - Note any deviations from research recommendations with rationale

## Dependencies and Prerequisites

**Required Dependencies:**
- `go_router: ^14.6.2` - Official Flutter routing package
- Existing: `flutter_riverpod: ^3.0.3` - Already in project
- Existing: `supabase_flutter: ^2.10.3` - Already in project

**Prerequisites:**
- Existing Riverpod auth state management must be working
- `authStateControllerProvider` must expose current user state via AsyncValue
- `AuthService.authStateChanges()` must return Stream<AuthState> from Supabase
- All screens must be stateless/stateful widgets (not Routes) - ✅ confirmed

**Development Tools:**
- `build_runner` for Riverpod code generation - Already in project
- Run `dart run build_runner watch --delete-conflicting-outputs` during development

## Challenges and Considerations

### Challenge 1: Stream to ChangeNotifier Conversion
**Issue:** go_router's `refreshListenable` expects ChangeNotifier, but Supabase auth provides Stream<AuthState>.

**Solution:** Implement `GoRouterRefreshStream` wrapper class that:
- Extends ChangeNotifier
- Subscribes to auth stream in constructor
- Calls `notifyListeners()` on stream events
- Converts stream to broadcast stream for multiple listeners
- Properly disposes subscription

**Reference:** [Q Agency blog implementation](https://q.agency/blog/handling-authentication-state-with-go_router-and-riverpod/)

### Challenge 2: Avoiding Redirect Loops
**Issue:** Incorrect redirect logic could cause infinite navigation loops.

**Solution:**
- Always check current location before redirecting: `state.matchedLocation`
- Use clear boolean flags: `isAuthenticated`, `isOnAuthRoute`
- Return `null` when no redirect needed (important!)
- Add logging to debug redirect decisions
- Test rapid auth state changes

### Challenge 3: Stream vs AsyncValue Provider Pattern
**Issue:** Current code uses AsyncValue-based AuthStateController with loading/error states. Need to migrate to stream-based pattern without breaking existing screens.

**Solution:**
- Create `authStreamProvider` first (Stream<User?> from AuthApplicationService)
- Create `AuthController` for auth operations (sign-in/sign-up/sign-out) without state management
- Update SignInScreen, SignUpScreen, AuthGate to use new providers before implementing router
- Test thoroughly after migration to ensure auth still works
- Only then proceed with router implementation
- Delete old AuthStateController after all references are removed
- This staged approach reduces risk of breaking auth during router migration

### Challenge 4: Riverpod Provider Lifecycle
**Issue:** Router provider must stay alive and react to auth stream changes.

**Solution:**
- Use `@Riverpod(keepAlive: true)` annotation for router provider
- Watch auth stream inside router provider: `ref.watch(authStreamProvider)`
- Router will rebuild when stream emits new values due to Riverpod reactivity
- Use `ref.read()` inside redirect callback to get current stream value
- `authStreamProvider` also uses `keepAlive: true` to maintain stream subscription

### Challenge 5: Stream Initialization Handling
**Issue:** During app startup, auth stream needs to emit initial value before routing can decide where to go.

**Solution:**
- **No loading state needed** - Supabase auth stream emits current user immediately on subscription
- Stream emits synchronously from `currentUser` on first subscription
- In redirect guard, check `authValue.hasValue` - if false, return null (stay on current route)
- Set initial location to `/auth/sign-in` (safe default)
- Stream emits almost immediately, redirect guard evaluates, routes appropriately
- If authenticated, user sees sign-in screen for a few milliseconds then redirects to home
- Acceptable UX, no loading screen needed
- Much cleaner than AsyncValue with artificial loading states

### Challenge 6: Error State UX
**Issue:** Research recommends eliminating error screen dead-end, but we still need error handling.

**Solution:**
- In redirect guard, treat error state same as unauthenticated: redirect to `/auth/sign-in`
- Errors are still logged by ErrorLogger in AuthStateController
- Auth screens handle their own operation errors inline via ref.listen
- SignInScreen becomes the recovery path for unexpected errors
- User can attempt sign-in which triggers fresh auth check

### Challenge 7: Testing with go_router
**Issue:** Existing widget tests may assume imperative navigation patterns.

**Solution:**
- Update `test_helpers.dart` to provide router-aware test app wrapper
- Mock `routerProvider` in tests that need specific routes
- Use `GoRouter.of(context)` for navigation assertions
- Test redirect logic separately from UI tests
- May need `mockito` mocks for router in some tests

### Challenge 8: Route Parameters Type Safety
**Issue:** Path parameters are String but IDs might be UUID/int types.

**Solution:**
- Use `state.pathParameters['id']!` to extract parameter
- Pass directly to detail screen widgets (they already accept String IDs)
- Repository layer handles ID validation and lookup
- Invalid IDs will trigger error handling in controllers
- Consider adding route-level validation in future if needed

### Challenge 9: Back Button Behavior
**Issue:** go_router handles back stack differently than Navigator.

**Solution:**
- Use `context.go()` for replacements (sign-in ↔ sign-up)
- Use `context.push()` for stacking (home → detail)
- Test back button behavior on Android
- Verify no unexpected back stack states
- Use `context.pop()` instead of `Navigator.pop()` for consistency

### Challenge 10: Gradual Migration
**Issue:** Cannot migrate all navigation at once without breaking app.

**Solution:**
- Phase 1-3 sets up router without touching existing navigation
- Phase 4 replaces Navigator calls one screen at a time
- Test after each screen migration
- Keep modal/dialog navigation using Navigator.push (standard practice)
- Can run old and new navigation side-by-side during transition

### Challenge 11: Changing Detail Screen Data Flow
**Issue:** Current implementation passes full objects (Note, TodoList, ListModel) to detail screens. With go_router, we must pass IDs and fetch data in detail screens.

**Solution:**
- Update detail screen constructors to accept ID strings instead of full objects
- Create or use existing Riverpod providers that fetch single items by ID:
  - May need `noteByIdProvider(String id)` family provider
  - May need `todoListByIdProvider(String id)` family provider
  - May need `listByIdProvider(String id)` family provider
- Detail screens will show loading state while fetching data
- Handle not found case (invalid ID or deleted item) with error screen
- This is actually better architecture - detail screens always have fresh data from source
- Side benefit: Deep links can work directly with just an ID

**Alternative (if providers don't exist):**
- Detail screens could search through existing list providers to find item by ID
- Less efficient but avoids creating new providers
- Still need to handle not found case

### Challenge 12: Deep Linking Foundation
**Issue:** Future deep linking support requires careful route structure design.

**Solution:**
- Use meaningful path segments: `/notes/:id`, not `/n/:id`
- Use path parameters, not query parameters for required data
- All routes have unique, descriptive paths
- Authentication guard handles protected routes automatically
- Foundation is laid even if deep linking isn't implemented immediately
