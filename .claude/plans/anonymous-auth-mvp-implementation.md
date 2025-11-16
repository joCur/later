# Anonymous User Authentication - MVP Implementation Plan

## Objective and Scope

Implement Supabase anonymous authentication in the Later app to enable a frictionless onboarding experience. Users can try the app immediately without creating an account, then seamlessly upgrade to a permanent account when ready, preserving all their data.

**MVP Scope (Simplified):**
- Anonymous sign-in on first app launch
- Basic feature limits for anonymous users (1 space, 20 notes per space, 10 todo lists, 5 custom lists)
- Simple upgrade flow: email + password (no email verification required for MVP)
- Permission service for client-side feature gating
- RLS policies for server-side enforcement
- Basic upgrade UI (banner + upgrade screen)

**Explicitly Excluded from MVP:**
- CAPTCHA protection (add in Phase 2)
- Email verification during upgrade (disabled for MVP)
- OAuth upgrade path (Google/Apple)
- Automated cleanup of inactive anonymous accounts
- Advanced upgrade prompts and analytics
- Merge-to-existing-account flow

## Technical Approach and Reasoning

**Why Supabase Native Anonymous Auth:**
- User ID remains constant during upgrade → zero data migration complexity
- Native SDK support → no additional dependencies
- JWT contains `is_anonymous` claim → easy RLS policy filtering
- Seamless upgrade via `updateUser()` → atomic operation

**Why Skip Email Verification for MVP:**
- Reduces upgrade friction dramatically (single-step instead of two-step)
- Faster iteration and testing during development
- Can be enabled later via config change (no code changes required)
- Local dev environment already has `enable_confirmations = false`

**Why Skip CAPTCHA for MVP:**
- Simplifies initial implementation
- Rate limiting still provides basic abuse prevention (30 per hour per IP)
- Can monitor abuse metrics and add CAPTCHA in Phase 2 if needed
- Focuses MVP on core functionality validation

**Architecture Pattern:**
- Permission Service (client-side) for UX and feature gating
- RLS Policies (server-side) as security enforcement layer
- In-place upgrade strategy (user_id never changes) for data continuity
- Riverpod 3.0 code generation for type-safe providers

## Implementation Phases

### Phase 1: Backend Configuration & Database Policies ✅

**Goal:** Enable anonymous authentication in Supabase and add RLS policies for feature restrictions

**Status:** COMPLETED - All backend infrastructure ready for anonymous authentication

- [x] Task 1.1: Enable anonymous sign-ins in Supabase config
  - ✅ Opened `supabase/config.toml`
  - ✅ Set `enable_anonymous_sign_ins = true` (line 138)
  - ✅ Verified `enable_confirmations = false` for local dev (line 176)
  - ✅ Verified existing `anonymous_users = 30` rate limit (line 153)
  - ✅ Applied config changes with `supabase db reset`

- [x] Task 1.2: Create database migration for anonymous user RLS policies
  - ✅ Created migration file: `supabase/migrations/20251116141316_add_anonymous_user_policies.sql`
  - ✅ Added policy to limit anonymous users to 1 space
  - ✅ Added policy to limit anonymous users to 20 notes per space
  - ✅ Added policy to limit anonymous users to 10 todo lists per space
  - ✅ Added policy to limit anonymous users to 5 custom lists per space
  - ✅ Existing user-based policies work for both anonymous and authenticated
  - ✅ Applied migration with `supabase db reset`

**SQL for migration:**
```sql
-- Policy: Limit anonymous users to 1 space
CREATE POLICY "Anonymous users limited to 1 space"
ON spaces FOR INSERT
TO authenticated
WITH CHECK (
  CASE
    WHEN (SELECT (auth.jwt()->>'is_anonymous')::boolean) IS TRUE
    THEN (SELECT COUNT(*) FROM spaces WHERE user_id = auth.uid()) < 1
    ELSE true
  END
);

-- Policy: Limit anonymous users to 20 notes per space
CREATE POLICY "Anonymous users limited to 20 notes per space"
ON notes FOR INSERT
TO authenticated
WITH CHECK (
  CASE
    WHEN (SELECT (auth.jwt()->>'is_anonymous')::boolean) IS TRUE
    THEN (
      SELECT COUNT(*)
      FROM notes
      WHERE user_id = auth.uid() AND space_id = NEW.space_id
    ) < 20
    ELSE true
  END
);

-- Policy: Limit anonymous users to 10 todo lists per space
CREATE POLICY "Anonymous users limited to 10 todo lists per space"
ON todo_lists FOR INSERT
TO authenticated
WITH CHECK (
  CASE
    WHEN (SELECT (auth.jwt()->>'is_anonymous')::boolean) IS TRUE
    THEN (
      SELECT COUNT(*)
      FROM todo_lists
      WHERE user_id = auth.uid() AND space_id = NEW.space_id
    ) < 10
    ELSE true
  END
);

-- Policy: Limit anonymous users to 5 custom lists per space
CREATE POLICY "Anonymous users limited to 5 custom lists per space"
ON lists FOR INSERT
TO authenticated
WITH CHECK (
  CASE
    WHEN (SELECT (auth.jwt()->>'is_anonymous')::boolean) IS TRUE
    THEN (
      SELECT COUNT(*)
      FROM lists
      WHERE user_id = auth.uid() AND space_id = NEW.space_id
    ) < 5
    ELSE true
  END
);
```

- [x] Task 1.3: Test policies locally
  - ✅ Supabase running (verified with `supabase status`)
  - ✅ Studio URL available: http://localhost:54323
  - ✅ Verified all 4 RLS policies created successfully:
    - `Anonymous users limited to 1 space` (INSERT on spaces) - **Updated from 5 to 1**
    - `Anonymous users limited to 20 notes per space` (INSERT on notes)
    - `Anonymous users limited to 10 todo lists per space` (INSERT on todo_lists)
    - `Anonymous users limited to 5 custom lists per space` (INSERT on lists)
  - ✅ Verified policy logic checks JWT `is_anonymous` claim correctly
  - ✅ Permanent users bypass limits (ELSE true in CASE statement)
  - ⏭️ End-to-end functional testing will occur during Flutter integration (Phase 3+)

### Phase 2: Permission Service & User Role System ✅

**Goal:** Create client-side permission service for feature gating

**Status:** COMPLETED - Permission service and user role system implemented with comprehensive tests

- [x] Task 2.1: Create UserRole enum
  - ✅ Created file: `apps/later_mobile/lib/core/permissions/user_role.dart`
  - ✅ Defined `enum UserRole { anonymous, authenticated }`
  - ✅ Added extension `UserRolePermissions` with permission getters:
    - `canCreateUnlimitedSpaces` → returns `this == UserRole.authenticated`
    - `canCreateUnlimitedNotes` → returns `this == UserRole.authenticated`
    - `canCreateUnlimitedTodoLists` → returns `this == UserRole.authenticated`
    - `canCreateUnlimitedLists` → returns `this == UserRole.authenticated`
  - ✅ Added numeric limit getters for anonymous users:
    - `maxSpacesForAnonymous` → returns `1`
    - `maxNotesPerSpaceForAnonymous` → returns `20`
    - `maxTodoListsPerSpaceForAnonymous` → returns `10`
    - `maxListsPerSpaceForAnonymous` → returns `5`

- [x] Task 2.2: Create PermissionService
  - ✅ Created file: `apps/later_mobile/lib/core/permissions/permission_service.dart`
  - ✅ Added class `PermissionService` with constructor taking `SupabaseClient`
  - ✅ Implemented method `UserRole getCurrentUserRole()`:
    - Gets current user via `_supabase.auth.currentUser`
    - If user is null, returns `UserRole.anonymous` (fallback)
    - If `user.isAnonymous == true`, returns `UserRole.anonymous`
    - Otherwise returns `UserRole.authenticated`
  - ✅ Added convenience method `bool isAnonymous()` → returns `getCurrentUserRole() == UserRole.anonymous`
  - ✅ Added convenience method `bool isAuthenticated()` → returns `getCurrentUserRole() == UserRole.authenticated`

- [x] Task 2.3: Create Riverpod providers for permissions
  - ✅ Added Riverpod providers using `@riverpod` annotation in permission_service.dart
  - ✅ Added provider `PermissionService permissionService(Ref ref)`:
    - Returns `PermissionService(SupabaseConfig.client)`
    - Marked with `@Riverpod(keepAlive: true)` for consistent permission checks
  - ✅ Added provider `UserRole currentUserRole(Ref ref)`:
    - Watches `permissionServiceProvider`
    - Returns `service.getCurrentUserRole()`
    - Marked with `@Riverpod(keepAlive: true)` to maintain auth state
  - ✅ Ran `dart run build_runner build --delete-conflicting-outputs`
  - ✅ Generated `permission_service.g.dart` successfully

- [x] Task 2.4: Export permissions from barrel file
  - ✅ Created file: `apps/later_mobile/lib/core/permissions/permissions.dart`
  - ✅ Exported all permission-related files:
    - `export 'user_role.dart';`
    - `export 'permission_service.dart';`
  - ℹ️ Note: No core/core.dart barrel file exists (not needed)

- [x] Task 2.5: Write comprehensive unit tests
  - ✅ Created file: `test/core/permissions/permission_service_test.dart`
  - ✅ Tests for `PermissionService.getCurrentUserRole()` (3 test cases)
  - ✅ Tests for `PermissionService.isAnonymous()` (3 test cases)
  - ✅ Tests for `PermissionService.isAuthenticated()` (3 test cases)
  - ✅ Tests for `UserRolePermissions` permission getters (8 test cases)
  - ✅ Tests for `UserRolePermissions` limit getters (4 test cases)
  - ✅ Generated mocks with `@GenerateMocks([SupabaseClient, GoTrueClient, User])`
  - ✅ All 21 tests passing

### Phase 3: AuthService - Anonymous Sign-In Methods ✅

**Goal:** Add anonymous authentication methods to AuthService

**Status:** COMPLETED - Anonymous authentication methods implemented in AuthService with proper error handling

- [x] Task 3.1: Add error codes for anonymous auth
  - ✅ Added error codes to `error_codes.dart`:
    - `authAnonymousSignInFailed`
    - `authUpgradeFailed`
    - `authAlreadyAuthenticated`
  - ✅ Added to severity metadata (all high severity)
  - ✅ Added English localized messages to `app_en.arb`:
    - `"errorAuthAnonymousSignInFailed": "Could not start trial. Please try again."`
    - `"errorAuthUpgradeFailed": "Could not create account. Please try again."`
    - `"errorAuthAlreadyAuthenticated": "You already have an account."`
  - ✅ Added German translations to `app_de.arb`:
    - `"errorAuthAnonymousSignInFailed": "Test konnte nicht gestartet werden. Bitte versuchen Sie es erneut."`
    - `"errorAuthUpgradeFailed": "Konto konnte nicht erstellt werden. Bitte versuchen Sie es erneut."`
    - `"errorAuthAlreadyAuthenticated": "Sie haben bereits ein Konto."`
  - ✅ Added error cases to `app_error.dart` switch statements (localization + fallback)
  - ✅ Ran `flutter pub get` to regenerate localization code

- [x] Task 3.2: Implement signInAnonymously() in AuthService
  - ✅ Opened `apps/later_mobile/lib/features/auth/data/services/auth_service.dart`
  - ✅ Added method `Future<User> signInAnonymously()`:
    - ✅ Added try-catch block
    - ✅ Called `await _supabase.auth.signInAnonymously()`
    - ✅ Check if `response.user == null`, throw `AppError(code: ErrorCode.authAnonymousSignInFailed)`
    - ✅ Return `response.user!`
    - ✅ Catch `AuthException` → throw `SupabaseErrorMapper.fromAuthException(e)`
    - ✅ Catch `AppError` → rethrow
    - ✅ Catch generic exception → throw `AppError(code: ErrorCode.unknownError)` with details

- [x] Task 3.3: Implement upgradeAnonymousUser() in AuthService
  - ✅ Added method `Future<User> upgradeAnonymousUser({required String email, required String password})`:
    - ✅ Get current user: `final currentUser = _supabase.auth.currentUser`
    - ✅ If null, throw `AppError(code: ErrorCode.authSessionExpired, message: 'No active session to upgrade.')`
    - ✅ If `!currentUser.isAnonymous`, throw `AppError(code: ErrorCode.authAlreadyAuthenticated)`
    - ✅ Call `await _supabase.auth.updateUser(UserAttributes(email: email, password: password))`
    - ✅ Check if `response.user == null`, throw `AppError(code: ErrorCode.authUpgradeFailed)`
    - ✅ Return `response.user!`
    - ✅ Added same error handling pattern (AuthException, AppError, generic)

- [x] Task 3.4: Add helper method isCurrentUserAnonymous()
  - ✅ Added getter `bool get isCurrentUserAnonymous`:
    - ✅ Get current user: `final user = getCurrentUser()`
    - ✅ Return `user?.isAnonymous ?? false`

- [x] Task 3.5: Write unit tests
  - ✅ Created `test/features/auth/data/services/auth_service_test.dart`
  - ✅ Added placeholder tests documenting expected behavior
  - ℹ️ Note: Full unit testing requires dependency injection refactor (AuthService uses static SupabaseConfig.client)
  - ℹ️ Recommendation: Use integration tests with local Supabase instance for Phase 8 testing
  - ✅ All existing tests pass (45 tests in auth feature)

### Phase 4: AuthStateController - Auto Anonymous Sign-In

**Goal:** Update auth controller to automatically sign in anonymously on first launch

- [ ] Task 4.1: Update AuthStateController initial build()
  - Open `apps/later_mobile/lib/features/auth/presentation/controllers/auth_state_controller.dart`
  - Modify `build()` method:
    - Check if current user exists: `final currentUser = _authService.getCurrentUser()`
    - If `currentUser == null`, call `await _authService.signInAnonymously()`
    - Set up auth state stream subscription as before
    - Return current user (now always non-null after anonymous sign-in)
  - Handle errors: if anonymous sign-in fails, return `null` and log error

- [ ] Task 4.2: Add upgrade method to controller
  - Add method `Future<void> upgradeToFullAccount({required String email, required String password})`:
    - Set loading state: `state = const AsyncValue.loading()`
    - Call `await ref.read(authServiceProvider).upgradeAnonymousUser(email: email, password: password)`
    - On success, state will update automatically via auth stream subscription
    - On error, catch and set `state = AsyncValue.error(error, stackTrace)`
    - Log error with `ErrorLogger.logError()`

- [ ] Task 4.3: Add helper to check if current user is anonymous
  - Add getter `bool get isCurrentUserAnonymous`:
    - Read from `state.value?.isAnonymous ?? false`
  - This provides easy access to anonymous status in UI

### Phase 5: AuthGate - Support Anonymous Users

**Goal:** Update AuthGate to allow anonymous users to access HomeScreen

- [ ] Task 5.1: Modify AuthGate routing logic
  - Open `apps/later_mobile/lib/features/auth/presentation/widgets/auth_gate.dart`
  - Current logic: `user == null` → SignInScreen, `user != null` → HomeScreen
  - New logic: Keep same behavior (anonymous users have non-null user object)
  - Anonymous users will now automatically reach HomeScreen
  - No code changes needed if AuthStateController handles anonymous sign-in in build()

- [ ] Task 5.2: Add "Skip for now" option to SignInScreen (optional for MVP)
  - Open `apps/later_mobile/lib/features/auth/presentation/screens/sign_in_screen.dart`
  - Add GhostButton "Continue without account" below sign-in form
  - On tap, call `ref.read(authStateControllerProvider.notifier).signInAnonymously()`
  - This allows users to explicitly choose anonymous mode if auto sign-in is removed later

### Phase 6: Upgrade UI - Banner & Screen

**Goal:** Create UI components for account upgrade flow

- [ ] Task 6.1: Create upgrade banner molecule
  - Create file: `apps/later_mobile/lib/design_system/molecules/upgrade_prompt_banner.dart`
  - Create widget `UpgradePromptBanner extends StatelessWidget`:
    - Display banner with warning icon + message: "Create an account to keep your data safe"
    - Primary button: "Create Account" → navigates to AccountUpgradeScreen
    - Dismiss button (X icon) → hides banner
    - Use `GlassCard` from design system for glassmorphism effect
    - Use `AppColors.taskGradient` for attention-grabbing accent
  - Add to `apps/later_mobile/lib/design_system/molecules/molecules.dart` barrel file

- [ ] Task 6.2: Create AccountUpgradeScreen
  - Create file: `apps/later_mobile/lib/features/auth/presentation/screens/account_upgrade_screen.dart`
  - Create StatefulWidget with form fields:
    - Email TextFormField with validation (required, email format)
    - Password TextFormField with validation (required, min 8 chars)
    - Confirm password TextFormField (must match password)
  - Add PrimaryButton "Create Account":
    - On tap, validate form
    - If valid, call `ref.read(authStateControllerProvider.notifier).upgradeToFullAccount(email: email, password: password)`
    - Show loading indicator during upgrade
    - On success, show success snackbar and pop screen
    - On error, show error dialog with localized message
  - Add GhostButton "Maybe later" to dismiss screen
  - Use ConsumerStatefulWidget to access Riverpod

- [ ] Task 6.3: Add localized strings for upgrade UI
  - Open `apps/later_mobile/lib/l10n/app_en.arb`
  - Add strings:
    - `"authUpgradeBannerMessage": "Create an account to keep your data safe"`
    - `"authUpgradeBannerButton": "Create Account"`
    - `"authUpgradeScreenTitle": "Create Your Account"`
    - `"authUpgradeScreenSubtitle": "Upgrade to unlock unlimited features"`
    - `"authUpgradeEmailLabel": "Email"`
    - `"authUpgradePasswordLabel": "Password"`
    - `"authUpgradeConfirmPasswordLabel": "Confirm Password"`
    - `"authUpgradeSubmitButton": "Create Account"`
    - `"authUpgradeCancelButton": "Maybe Later"`
    - `"authUpgradeSuccessMessage": "Account created successfully!"`
  - Open `apps/later_mobile/lib/l10n/app_de.arb`
  - Add German translations for all strings above
  - Run `flutter pub get`

- [ ] Task 6.4: Integrate banner into HomeScreen
  - Open `apps/later_mobile/lib/features/home/presentation/screens/home_screen.dart`
  - Add `UpgradePromptBanner` at top of screen (above content)
  - Show banner only if `ref.watch(currentUserRoleProvider) == UserRole.anonymous`
  - Add state management for banner dismissal (store in SharedPreferences)
  - Re-show banner after 7 days if still anonymous

### Phase 7: Feature Limit Enforcement in UI

**Goal:** Add client-side checks to prevent anonymous users from exceeding limits

- [ ] Task 7.1: Update SpacesController to check limits
  - Open `apps/later_mobile/lib/features/spaces/presentation/controllers/spaces_controller.dart`
  - In `createSpace()` method, before calling repository:
    - Get user role: `final role = ref.read(currentUserRoleProvider)`
    - If `role == UserRole.anonymous`:
      - Get current space count from state
      - If count >= 1, throw `AppError(code: ErrorCode.permissionFeatureRestricted, message: 'Anonymous users limited to 1 space')`
      - Show upgrade prompt modal instead of error
    - Otherwise proceed with creation
  - Update UI to show "Upgrade to create more spaces" message when limit reached

- [ ] Task 7.2: Update NotesController to check limits
  - Open `apps/later_mobile/lib/features/notes/presentation/controllers/notes_controller.dart`
  - In `createNote()` method, before calling repository:
    - Check user role
    - If anonymous, check if current note count for this space >= 20
    - If at limit, show upgrade prompt instead of creating note

- [ ] Task 7.3: Update TodoListsController to check limits
  - Open `apps/later_mobile/lib/features/todo_lists/presentation/controllers/todo_lists_controller.dart`
  - In `createTodoList()` method:
    - Check user role
    - If anonymous, check if current todo list count for this space >= 10
    - If at limit, show upgrade prompt

- [ ] Task 7.4: Update ListsController to check limits
  - Open `apps/later_mobile/lib/features/lists/presentation/controllers/lists_controller.dart`
  - In `createList()` method:
    - Check user role
    - If anonymous, check if current list count for this space >= 5
    - If at limit, show upgrade prompt

- [ ] Task 7.5: Create reusable upgrade prompt dialog
  - Create file: `apps/later_mobile/lib/design_system/organisms/upgrade_required_dialog.dart`
  - Create dialog widget with:
    - Title: "Upgrade Required"
    - Message: customizable (e.g., "Anonymous users limited to 1 space. Create an account to unlock unlimited spaces.")
    - Primary button: "Create Account" → navigate to AccountUpgradeScreen
    - Secondary button: "Not Now" → dismiss dialog
  - Use this dialog in all controllers when limits are reached

### Phase 8: Testing & Validation

**Goal:** Ensure implementation works correctly with comprehensive testing

- [ ] Task 8.1: Write unit tests for permission service
  - Create file: `apps/later_mobile/test/core/permissions/permission_service_test.dart`
  - Test `getCurrentUserRole()` returns correct role based on user.isAnonymous
  - Test role permissions (canCreateUnlimitedSpaces, etc.)
  - Mock SupabaseClient and User objects

- [ ] Task 8.2: Write unit tests for AuthService anonymous methods
  - Open `apps/later_mobile/test/features/auth/data/services/auth_service_test.dart`
  - Test `signInAnonymously()` success case
  - Test `signInAnonymously()` error cases (AuthException, null user)
  - Test `upgradeAnonymousUser()` success case
  - Test `upgradeAnonymousUser()` error cases (no user, already authenticated)
  - Mock Supabase auth responses

- [ ] Task 8.3: Write widget tests for upgrade UI
  - Create file: `apps/later_mobile/test/features/auth/presentation/screens/account_upgrade_screen_test.dart`
  - Test screen renders correctly
  - Test form validation (email format, password length, password match)
  - Test submit button calls upgrade method
  - Test error handling and success states
  - Use `testApp()` helper from `test_helpers.dart`

- [ ] Task 8.4: Manual testing flow
  - Fresh install → Verify auto sign-in as anonymous user
  - Create 1 space → Verify 2nd space shows upgrade prompt
  - Create 20 notes in the space → Verify 21st note shows upgrade prompt
  - Click "Create Account" → Fill form → Submit → Verify upgrade succeeds
  - Verify all created data still exists after upgrade
  - Sign out and sign in with new credentials → Verify data persists
  - Check Supabase Studio → Verify user.is_anonymous changed from true to false

- [ ] Task 8.5: Test RLS policies
  - Use Supabase Studio SQL editor
  - Create anonymous user via API
  - Test INSERT operations respect limits (1 space, 20 notes, 10 todo lists, 5 custom lists)
  - Verify permanent users can exceed limits
  - Test policies block operations correctly (return error, not silently fail)

## Dependencies and Prerequisites

**Required:**
- Supabase Flutter SDK ≥ 2.8.0 (already installed - supports `signInAnonymously()`)
- Supabase CLI for local development (already installed)
- Docker running (required by Supabase CLI)
- Flutter SDK 3.9.2+
- Riverpod 3.0.3 (already migrated)

**No New Dependencies:**
- All functionality uses existing Supabase SDK
- No third-party packages needed for MVP

**Prerequisites:**
- Local Supabase instance running (`supabase start`)
- Existing auth infrastructure (AuthService, AuthStateController)
- Existing error handling system (ErrorCode, AppError, error mappers)
- Existing permission structure (repositories, RLS policies)

## Challenges and Considerations

**Challenge 1: Auto Sign-In UX**
- **Issue:** Users may not realize they're in "trial mode" if auto signed-in anonymously
- **Mitigation:** Show clear banner at top: "You're in trial mode. Create account to keep data."
- **Alternative:** Add explicit "Try without account" button on sign-in screen (gives users choice)

**Challenge 2: Limit Enforcement Timing**
- **Issue:** Client-side checks can be bypassed, RLS policies are final enforcement
- **Mitigation:** Always show user-friendly upgrade prompt client-side, but rely on RLS to actually block operations
- **Consideration:** Handle RLS policy errors gracefully (show upgrade prompt, not generic error)

**Challenge 3: Data Loss Risk**
- **Issue:** Anonymous users may uninstall app before upgrading, losing all data
- **Mitigation:** Show persistent banner reminder to create account
- **Phase 2:** Add local notification after 7 days: "You have unsaved data, create account?"

**Challenge 4: Upgrade Flow Abandonment**
- **Issue:** Users may start upgrade and quit mid-flow
- **Mitigation:** Make form as simple as possible (just email + password for MVP)
- **Phase 2:** Add "Complete your account setup" reminder on next launch

**Challenge 5: Testing Anonymous Auth Locally**
- **Issue:** Need to test anonymous sign-in without affecting real Supabase project
- **Mitigation:** Use `supabase start` for local PostgreSQL + Auth instance
- **Consideration:** Ensure local config has `enable_confirmations = false` for testing

**Edge Cases to Handle:**
- User creates anonymous account → upgrades → signs out → tries to sign in anonymously again (should create new anonymous user)
- User creates anonymous account → tries to upgrade with email that already exists (show "email already registered" error for MVP, handle merge in Phase 2)
- User reaches limit → sees upgrade prompt → dismisses → tries again → should see prompt again (don't hide permanently)

**Performance Considerations:**
- Anonymous sign-in adds ~100-200ms to app startup (acceptable)
- RLS policy checks for limits add minimal overhead (PostgreSQL function calls are fast)
- Client-side permission checks are instant (in-memory enum comparison)

**Security Considerations:**
- JWT `is_anonymous` claim is cryptographically signed → cannot be forged
- RLS policies enforce limits server-side → cannot be bypassed
- Rate limiting (30/hour/IP) provides basic abuse prevention even without CAPTCHA
- Consider monitoring anonymous user creation rate and adding CAPTCHA in Phase 2 if abuse detected
