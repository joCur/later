# Research: Anonymous User Implementation for Later App

## Executive Summary

This research explores implementing anonymous user authentication in the Later app to allow new users to try the app before committing to account creation. Supabase provides native support for anonymous authentication via `signInAnonymously()`, which creates temporary users that can be seamlessly upgraded to permanent accounts while preserving all user data. The implementation requires enabling anonymous sign-ins in Supabase config, updating the AuthService with new methods, modifying RLS policies to handle the `is_anonymous` JWT claim, and implementing a feature flagging system to restrict premium features for anonymous users. The user's ID remains constant during the anonymous-to-permanent upgrade, ensuring data continuity without complex migration logic.

**Key Recommendations:**
- Use Supabase's built-in anonymous authentication with `updateUser()` for seamless account upgrades
- Implement a permission service with role-based access control distinguishing anonymous vs. authenticated users
- Update RLS policies to check the `is_anonymous` JWT claim for feature restrictions
- Add CAPTCHA protection to prevent anonymous user abuse
- Design clear upgrade prompts at strategic friction points (e.g., when attempting to use premium features)

## Research Scope

### What Was Researched
- Supabase anonymous authentication implementation in Flutter
- Anonymous-to-authenticated user migration strategies
- Feature flagging and permission systems for anonymous users
- Row-Level Security (RLS) policy patterns for anonymous users
- Best practices for anonymous user onboarding flows
- Data preservation during account upgrades
- Security considerations and abuse prevention

### What Was Explicitly Excluded
- Third-party authentication providers (OAuth, social login) - already supported
- Multi-factor authentication for anonymous users
- Anonymous user analytics and tracking implementation
- Pricing/monetization strategies for free vs. premium features

### Research Methodology
1. Analyzed current Later app authentication architecture (Supabase, Riverpod 3.0)
2. Reviewed official Supabase documentation and Flutter SDK examples
3. Researched industry best practices via web search and developer communities
4. Examined RLS policy patterns and JWT claim handling
5. Investigated feature flagging patterns in Flutter apps

## Current State Analysis

### Existing Implementation

**Authentication Architecture:**
- **AuthService** (`features/auth/data/services/auth_service.dart`) - Handles Supabase Auth operations
  - Currently supports: `signUpWithEmail()`, `signInWithEmail()`, `signOut()`, `getCurrentUser()`
  - Uses Supabase Auth with email/password authentication only
  - Error handling via `AppError` with centralized error codes

- **AuthStateController** (`features/auth/presentation/controllers/auth_state_controller.dart`) - Riverpod 3.0 controller
  - Manages authentication state with `AsyncValue<User?>`
  - Maintains auth stream subscription with `keepAlive: true`
  - Currently binary: user is either authenticated (non-null) or not authenticated (null)
  - No distinction between anonymous and permanent users

- **AuthGate** (`features/auth/presentation/widgets/auth_gate.dart`) - Routes based on auth status
  - If user exists → `HomeScreen`
  - If user is null → `SignInScreen`
  - No support for anonymous user onboarding flow

**Data Architecture:**
- **BaseRepository** - All repositories extend this and use `userId` property
  - `userId` getter retrieves `supabase.auth.currentUser?.id`
  - Throws `ErrorCode.authSessionExpired` if no user is authenticated
  - Currently assumes all users are authenticated with accounts

**Database Schema:**
- All tables have `user_id` UUID column referencing `auth.users`
- RLS policies use `auth.uid()` to filter by current user
- Current policies: `USING (user_id = auth.uid())` - allows all operations for matching user_id
- No differentiation between anonymous and permanent users in RLS policies

**Supabase Configuration:**
- `supabase/config.toml` currently has:
  - `enable_anonymous_sign_ins = false` (line 138)
  - `anonymous_users = 30` rate limit configured (line 153)
  - Email confirmations disabled for local dev: `enable_confirmations = false`

### Technical Debt and Limitations

1. **No anonymous user support** - Users must create an account before trying the app
2. **Binary authentication state** - No concept of "partial" or "trial" users
3. **No feature flagging system** - All features available to all authenticated users
4. **Hard authentication requirement** - `BaseRepository.userId` throws error if not authenticated
5. **No upgrade flow UI** - No screens/prompts to convert anonymous users to permanent accounts

### Industry Standards

**Anonymous Authentication Patterns:**
1. **Temporary Guest Access** - Users can try core features without account creation
2. **Seamless Upgrade** - Convert anonymous users to permanent accounts without data loss
3. **Progressive Disclosure** - Request account creation at strategic friction points
4. **Data Continuity** - User ID remains constant during upgrade to preserve all data

**Best Practices:**
- Enable anonymous auth for low-friction onboarding
- Limit anonymous users to core features, prompt upgrade for premium features
- Use CAPTCHA to prevent anonymous user abuse
- Implement clear "Sign up to keep your data" messaging
- Upgrade prompts at natural friction points (e.g., when accessing restricted features)

## Technical Analysis

### Approach 1: Supabase Native Anonymous Authentication

**Description:**
Use Supabase's built-in `signInAnonymously()` method to create temporary anonymous users. Later upgrade them using `updateUser()` to link email/password credentials while preserving the same user ID.

**Pros:**
- ✅ Native Supabase support - no third-party dependencies
- ✅ User ID remains constant during upgrade (seamless data continuity)
- ✅ Simple implementation - single method call for anonymous sign-in
- ✅ JWT contains `is_anonymous` claim for RLS policy filtering
- ✅ Works with existing Supabase Flutter SDK (v2.8.0+)
- ✅ Automatic session management and refresh token handling
- ✅ No manual data migration required - same user record is updated

**Cons:**
- ❌ Requires Supabase project configuration change
- ❌ Potential for abuse - anonymous users can inflate database size
- ❌ Rate limiting needed to prevent spam (30 per hour per IP by default)
- ❌ Email verification required before setting password (two-step upgrade)
- ❌ Manual linking must be enabled in Supabase project settings

**Use Cases:**
- Best for apps wanting low-friction onboarding with seamless upgrade path
- Ideal when user data continuity is critical
- Perfect for trial experiences before requiring account creation

**Code Example:**

```dart
// AuthService - Add anonymous sign-in method
Future<User> signInAnonymously() async {
  try {
    final response = await _supabase.auth.signInAnonymously();

    if (response.user == null) {
      throw const AppError(
        code: ErrorCode.authGeneric,
        message: 'Anonymous sign-in failed. Please try again.',
      );
    }

    return response.user!;
  } on AuthException catch (e) {
    throw SupabaseErrorMapper.fromAuthException(e);
  } on AppError {
    rethrow;
  } catch (e, stackTrace) {
    throw AppError(
      code: ErrorCode.unknownError,
      message: 'Unexpected error during anonymous sign-in: ${e.toString()}',
      technicalDetails: stackTrace.toString(),
    );
  }
}

// AuthService - Upgrade anonymous user to permanent account
Future<User> upgradeAnonymousUser({
  required String email,
  required String password,
}) async {
  try {
    final currentUser = _supabase.auth.currentUser;

    if (currentUser == null) {
      throw const AppError(
        code: ErrorCode.authSessionExpired,
        message: 'No active session to upgrade.',
      );
    }

    // Check if user is anonymous
    final isAnonymous = currentUser.isAnonymous;
    if (!isAnonymous) {
      throw const AppError(
        code: ErrorCode.authGeneric,
        message: 'User is already authenticated with credentials.',
      );
    }

    // Step 1: Update email (will send verification email)
    final response = await _supabase.auth.updateUser(
      UserAttributes(email: email),
    );

    if (response.user == null) {
      throw const AppError(
        code: ErrorCode.authGeneric,
        message: 'Failed to update email.',
      );
    }

    // Step 2: After email verification, update password
    // Note: This requires email to be verified first
    // You'll need to handle this in a separate flow after email verification

    return response.user!;
  } on AuthException catch (e) {
    throw SupabaseErrorMapper.fromAuthException(e);
  } on AppError {
    rethrow;
  } catch (e, stackTrace) {
    throw AppError(
      code: ErrorCode.unknownError,
      message: 'Unexpected error during account upgrade: ${e.toString()}',
      technicalDetails: stackTrace.toString(),
    );
  }
}

// Alternative: Set password after email verification
Future<User> setPasswordAfterVerification({
  required String password,
}) async {
  try {
    final response = await _supabase.auth.updateUser(
      UserAttributes(password: password),
    );

    if (response.user == null) {
      throw const AppError(
        code: ErrorCode.authGeneric,
        message: 'Failed to set password.',
      );
    }

    return response.user!;
  } on AuthException catch (e) {
    throw SupabaseErrorMapper.fromAuthException(e);
  } on AppError {
    rethrow;
  } catch (e, stackTrace) {
    throw AppError(
      code: ErrorCode.unknownError,
      message: 'Unexpected error setting password: ${e.toString()}',
      technicalDetails: stackTrace.toString(),
    );
  }
}
```

### Approach 2: OAuth Linking for Instant Upgrade

**Description:**
Allow anonymous users to upgrade using OAuth providers (Google, Apple) via `linkIdentity()`. This provides instant upgrade without email verification steps.

**Pros:**
- ✅ Single-step upgrade process (no email verification wait)
- ✅ Better user experience - instant account conversion
- ✅ User ID remains constant (seamless data continuity)
- ✅ Native Supabase support via `linkIdentity()` method
- ✅ Reduces friction in conversion funnel
- ✅ Leverages existing OAuth provider trust

**Cons:**
- ❌ Requires OAuth provider setup (Google, Apple, etc.)
- ❌ Platform-specific implementation complexity (iOS/Android)
- ❌ Users without OAuth accounts still need email/password fallback
- ❌ Additional OAuth configuration in Supabase dashboard
- ❌ May require native SDK integration (google_sign_in, sign_in_with_apple)

**Use Cases:**
- Apps targeting users who prefer social login
- When instant upgrade is more important than email/password simplicity
- Combined with Approach 1 as a premium upgrade option

**Code Example:**

```dart
// AuthService - Upgrade anonymous user via Google OAuth
Future<User> upgradeWithGoogle() async {
  try {
    final currentUser = _supabase.auth.currentUser;

    if (currentUser == null || !currentUser.isAnonymous) {
      throw const AppError(
        code: ErrorCode.authGeneric,
        message: 'No anonymous session to upgrade.',
      );
    }

    // Get Google credentials using google_sign_in package
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null || idToken == null) {
      throw const AppError(
        code: ErrorCode.authGeneric,
        message: 'Failed to get Google credentials.',
      );
    }

    // Link Google identity to anonymous user
    final response = await _supabase.auth.linkIdentity(
      OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    if (response.user == null) {
      throw const AppError(
        code: ErrorCode.authGeneric,
        message: 'Failed to link Google account.',
      );
    }

    return response.user!;
  } on AuthException catch (e) {
    throw SupabaseErrorMapper.fromAuthException(e);
  } on AppError {
    rethrow;
  } catch (e, stackTrace) {
    throw AppError(
      code: ErrorCode.unknownError,
      message: 'Unexpected error upgrading with Google: ${e.toString()}',
      technicalDetails: stackTrace.toString(),
    );
  }
}
```

### Approach 3: Local-Only Guest Mode (No Backend)

**Description:**
Implement a fully local guest mode using local storage (SharedPreferences/SQLite) without creating Supabase users. Migrate data to backend upon account creation.

**Pros:**
- ✅ No backend storage for trial users - reduces database load
- ✅ Works offline completely
- ✅ No rate limiting or abuse concerns for anonymous users
- ✅ Full privacy - no data leaves device until upgrade
- ✅ Can work without internet connection

**Cons:**
- ❌ Complex data migration logic required on upgrade
- ❌ Data lost if user uninstalls app before upgrading
- ❌ Requires maintaining two separate data layers (local + remote)
- ❌ No sync across devices during guest mode
- ❌ Testing complexity - two different storage mechanisms
- ❌ Duplicate code for local vs. remote repository implementations
- ❌ Risk of migration failures and data loss

**Use Cases:**
- Apps with strict database size limits
- When preventing anonymous user abuse is critical
- Apps that work primarily offline

**Implementation Note:**
Not recommended for Later app due to complexity and existing cloud-first architecture. The app is already designed around Supabase sync, and introducing a local-only mode would require significant refactoring.

## Feature Flagging and Permission System

### Option 1: Permission Service with User Role Enum

**Purpose:** Centralized service to check user permissions based on authentication status

**Maturity:** Production-ready pattern used in many Flutter apps

**License:** Not applicable (architectural pattern)

**Community:** Widely adopted in Flutter community

**Integration Effort:** Low - can be implemented in a single service class

**Key Features:**
- Type-safe role enumeration
- Centralized permission logic
- Easy to extend with new features
- Works with existing Riverpod architecture

**Implementation:**

```dart
// lib/core/permissions/user_role.dart
enum UserRole {
  anonymous,
  authenticated,
}

extension UserRolePermissions on UserRole {
  bool get canCreateSpaces {
    return this == UserRole.authenticated;
  }

  bool get canExportData {
    return this == UserRole.authenticated;
  }

  bool get canAccessPremiumFeatures {
    return this == UserRole.authenticated;
  }

  bool get canSyncAcrossDevices {
    return this == UserRole.authenticated;
  }

  // Add more permissions as needed
}

// lib/core/permissions/permission_service.dart
class PermissionService {
  final SupabaseClient _supabase;

  PermissionService(this._supabase);

  /// Get the current user's role based on authentication status
  UserRole getCurrentUserRole() {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      // No user at all - should not happen in app with anonymous auth
      return UserRole.anonymous;
    }

    // Check if user is anonymous using the JWT claim
    if (user.isAnonymous) {
      return UserRole.anonymous;
    }

    return UserRole.authenticated;
  }

  /// Check if current user has permission for a specific feature
  bool hasPermission(bool Function(UserRole) permissionCheck) {
    final role = getCurrentUserRole();
    return permissionCheck(role);
  }
}

// Riverpod provider
@riverpod
PermissionService permissionService(PermissionServiceRef ref) {
  return PermissionService(SupabaseConfig.client);
}

@riverpod
UserRole currentUserRole(CurrentUserRoleRef ref) {
  final service = ref.watch(permissionServiceProvider);
  return service.getCurrentUserRole();
}
```

**Usage in UI:**

```dart
// In a widget
class CreateSpaceButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);

    return PrimaryButton(
      text: 'Create Space',
      onPressed: role.canCreateSpaces
          ? () => _createSpace(context)
          : () => _showUpgradePrompt(context),
    );
  }
}
```

### Option 2: Feature Flag Package (flutter_flagsmith, launch_darkly)

**Purpose:** Third-party feature flag services with remote configuration

**Maturity:** Production-ready, enterprise-grade solutions

**License:** Various (Flagsmith is open-source, LaunchDarkly is commercial)

**Community:** Large - used by major companies

**Integration Effort:** Medium - requires SDK setup and configuration dashboard

**Key Features:**
- Remote feature flag toggling (no app update required)
- A/B testing capabilities
- Gradual rollout support
- Analytics integration
- User segmentation

**Pros:**
- ✅ Can toggle features without app updates
- ✅ Advanced targeting and segmentation
- ✅ A/B testing support

**Cons:**
- ❌ Additional external dependency
- ❌ Monthly costs for commercial solutions
- ❌ Adds network latency for feature checks
- ❌ Overkill for simple anonymous vs. authenticated distinction

**Recommendation:** Not needed for Later app's initial anonymous user implementation. The simple permission service (Option 1) is sufficient and more maintainable.

### Option 3: RLS-Based Feature Gating

**Purpose:** Use Supabase Row-Level Security policies to restrict features at database level

**Maturity:** Production-ready (Supabase native feature)

**License:** Part of Supabase (open-source/commercial)

**Community:** Large Supabase community

**Integration Effort:** Low - modify existing RLS policies

**Key Features:**
- Server-side enforcement (cannot be bypassed)
- No client-side code needed
- Leverages existing infrastructure

**Implementation:**

```sql
-- Example: Restrict space creation to permanent users only
CREATE POLICY "Only permanent users can create spaces"
ON spaces FOR INSERT
TO authenticated
WITH CHECK (
  (SELECT (auth.jwt()->>'is_anonymous')::boolean) IS FALSE
);

-- Example: Allow anonymous users to read but not create/update/delete
CREATE POLICY "Anonymous users can read spaces"
ON spaces FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Permanent users can modify spaces"
ON spaces FOR UPDATE
TO authenticated
USING (
  user_id = auth.uid()
  AND (SELECT (auth.jwt()->>'is_anonymous')::boolean) IS FALSE
);

-- Example: Limit anonymous users to 5 spaces
CREATE POLICY "Anonymous users limited to 5 spaces"
ON spaces FOR INSERT
TO authenticated
WITH CHECK (
  CASE
    WHEN (SELECT (auth.jwt()->>'is_anonymous')::boolean) IS TRUE
    THEN (SELECT COUNT(*) FROM spaces WHERE user_id = auth.uid()) < 5
    ELSE true
  END
);
```

**Pros:**
- ✅ Server-side enforcement - secure and tamper-proof
- ✅ No client code changes needed for enforcement
- ✅ Works automatically for all clients

**Cons:**
- ❌ Less flexible than client-side checks
- ❌ Harder to provide good UX (must handle database errors)
- ❌ Requires database migrations to change restrictions

**Recommendation:** Use RLS policies as a security layer in addition to client-side permission checks, not as the primary feature gating mechanism.

## Data Migration and Account Upgrade

### Migration Strategy 1: In-Place Upgrade (Recommended)

**Description:**
Use Supabase's `updateUser()` to convert anonymous user to permanent user. The user ID remains constant, so all existing data automatically belongs to the upgraded user.

**Process:**
1. User is signed in anonymously → Creates spaces, notes, todos (all linked to anonymous user_id)
2. User decides to upgrade → Clicks "Create Account" button
3. App calls `updateUser()` with email → Supabase sends verification email
4. User verifies email → Email is linked to same user record
5. User sets password → Same user record now has email + password credentials
6. User can now sign in with email/password → Same user_id, all data preserved

**Pros:**
- ✅ Zero data migration complexity - user_id never changes
- ✅ Atomic operation - no race conditions
- ✅ Native Supabase support
- ✅ No risk of data loss during migration
- ✅ Works seamlessly with existing RLS policies

**Cons:**
- ❌ Two-step process (email verification, then password)
- ❌ User must wait for email verification

**Code Example:**

```dart
// lib/features/auth/application/auth_upgrade_service.dart
class AuthUpgradeService {
  final AuthService _authService;

  AuthUpgradeService(this._authService);

  /// Step 1: Initiate upgrade by adding email
  /// This sends a verification email to the user
  Future<void> initiateUpgrade(String email) async {
    await _authService.updateUserEmail(email);
  }

  /// Step 2: Set password after email verification
  /// Call this after user clicks verification link in email
  Future<void> completeUpgrade(String password) async {
    await _authService.setPasswordAfterVerification(password: password);
  }

  /// Check if current user is anonymous
  bool isCurrentUserAnonymous() {
    final user = _authService.getCurrentUser();
    return user?.isAnonymous ?? false;
  }

  /// Check if current user needs to complete upgrade
  /// (has email but no password)
  bool needsPasswordSetup() {
    final user = _authService.getCurrentUser();
    if (user == null) return false;

    // If user has email but is still marked as anonymous,
    // they need to set a password
    return user.email != null && user.isAnonymous;
  }
}
```

### Migration Strategy 2: Link to Existing Account

**Description:**
If a user already has an account with the same email, merge the anonymous user's data into the existing account.

**Process:**
1. Anonymous user tries to upgrade with email that already exists
2. Detect the conflict (email already registered)
3. Prompt user: "You already have an account. Sign in to keep both sets of data?"
4. User signs in with existing credentials
5. App queries all data with anonymous user_id
6. App updates all records to new user_id (existing account)
7. App deletes anonymous user record

**Pros:**
- ✅ Handles edge case of returning users
- ✅ Merges data from multiple sessions

**Cons:**
- ❌ Complex implementation - requires manual data migration
- ❌ Risk of data conflicts (e.g., duplicate space names)
- ❌ Requires additional database queries and transactions
- ❌ Potential for partial migration failures
- ❌ Must handle rollback on failure

**Recommendation:** Implement this as a Phase 2 feature only if user research shows it's needed. Most users won't have pre-existing accounts, so the added complexity may not be worth it initially.

**Code Example (Reference Only - Not Recommended for MVP):**

```dart
// Complex migration - only implement if necessary
Future<void> mergeAnonymousDataToExistingAccount({
  required String existingUserId,
  required String anonymousUserId,
}) async {
  final supabase = SupabaseConfig.client;

  try {
    // Start a transaction by updating all tables
    await supabase.from('spaces').update({'user_id': existingUserId})
        .eq('user_id', anonymousUserId);

    await supabase.from('notes').update({'user_id': existingUserId})
        .eq('user_id', anonymousUserId);

    await supabase.from('todo_lists').update({'user_id': existingUserId})
        .eq('user_id', anonymousUserId);

    await supabase.from('lists').update({'user_id': existingUserId})
        .eq('user_id', anonymousUserId);

    // Delete anonymous user
    await supabase.auth.admin.deleteUser(anonymousUserId);
  } catch (e) {
    // Handle rollback - this is complex and error-prone
    throw AppError(
      code: ErrorCode.databaseOperationFailed,
      message: 'Failed to merge anonymous user data',
      technicalDetails: e.toString(),
    );
  }
}
```

## Upgrade Flow UX Patterns

### Pattern 1: Progressive Disclosure on Feature Access

**When:** User attempts to use a restricted feature (e.g., create 6th space as anonymous user)

**Flow:**
1. User clicks "Create New Space" when at limit
2. Show modal: "Upgrade to Create More Spaces"
   - "Free accounts are limited to 5 spaces"
   - "Sign up to create unlimited spaces"
   - Primary button: "Create Account"
   - Secondary link: "Not now"
3. If "Create Account" → Navigate to upgrade screen
4. If "Not now" → Dismiss modal

**Benefits:**
- Clear value proposition at point of need
- User understands what they're gaining
- Non-intrusive - only shown when relevant

### Pattern 2: Gentle Reminders with Data Preservation Warning

**When:** User has been using app for 7 days or created significant content

**Flow:**
1. Show banner at top of home screen
2. Message: "⚠️ Your data is temporary. Sign up to keep it forever."
3. Button: "Create Account" or dismiss (X)
4. Store dismissal state to avoid re-showing too frequently

**Benefits:**
- Creates urgency without being pushy
- Emphasizes data loss risk
- User-controlled dismissal

### Pattern 3: Success-Based Upgrade Prompt

**When:** User completes a significant action (e.g., completes first todo list)

**Flow:**
1. Show celebration modal: "🎉 Great job!"
2. Message: "You completed your first task! Sign up to sync your progress across all your devices."
3. Primary button: "Create Account"
4. Link: "Maybe later"

**Benefits:**
- Positive emotional moment increases conversion
- Highlights sync as a benefit
- Doesn't interrupt workflow

## Implementation Considerations

### Technical Requirements

**Dependencies:**
- Supabase Flutter SDK ≥2.8.0 (has `signInAnonymously()` support)
- No additional packages required for basic implementation
- Optional: `google_sign_in` or `sign_in_with_apple` for OAuth upgrade path

**Configuration Changes:**
1. Enable anonymous sign-ins in Supabase config:
   ```toml
   # supabase/config.toml
   enable_anonymous_sign_ins = true
   enable_manual_linking = true  # Required for OAuth linking
   ```

2. Add CAPTCHA protection (recommended):
   ```toml
   [auth.captcha]
   enabled = true
   provider = "turnstile"  # or "hcaptcha"
   secret = "env(CAPTCHA_SECRET)"
   ```

3. Adjust rate limits if needed:
   ```toml
   [auth.rate_limit]
   anonymous_users = 30  # Per hour per IP address
   ```

**Performance Implications:**
- Anonymous sign-in is a fast operation (~100-200ms)
- No significant impact on database performance (anonymous users are regular auth.users rows)
- RLS policies with `auth.jwt()->>'is_anonymous'` add minimal query overhead

**Scalability Considerations:**
- Anonymous users are stored in same auth.users table as permanent users
- Consider adding cleanup job to delete old unused anonymous accounts (e.g., after 30 days of inactivity)
- Monitor anonymous user creation rate to detect abuse

**Security Aspects:**
- Enable CAPTCHA to prevent anonymous user spam
- Rate limit anonymous sign-ins (default: 30/hour/IP)
- RLS policies enforce server-side permission checks (cannot be bypassed)
- JWT `is_anonymous` claim is cryptographically signed - cannot be forged

### Integration Points

**1. AuthService Changes:**
- Add `signInAnonymously()` method
- Add `upgradeAnonymousUser()` method
- Add `isCurrentUserAnonymous()` getter
- Modify error handling for anonymous-specific errors

**2. AuthStateController Changes:**
- Update initial build() to call `signInAnonymously()` if no user exists
- Add upgrade-related methods (initiate, complete)
- Update state management to track upgrade progress

**3. AuthGate Changes:**
- Remove automatic redirect to SignInScreen for anonymous users
- Anonymous users should see HomeScreen with upgrade prompts
- Add `OnboardingScreen` for first-time anonymous users (optional)

**4. BaseRepository Changes:**
- No changes needed - `userId` getter works for both anonymous and permanent users
- Anonymous users have valid user IDs just like permanent users

**5. UI Changes:**
- Add "Create Account" button in app bar or sidebar
- Add upgrade prompts at feature restriction points
- Add banner/modal for gentle reminders
- Create `AccountUpgradeScreen` with email/password form

**6. Database Migrations:**
- Add new RLS policies to restrict features for anonymous users
- Keep existing policies - they already use `auth.uid()` correctly

### Risks and Mitigation

**Risk 1: Anonymous User Abuse (Database Bloat)**
- **Impact:** High - Could significantly increase database size and costs
- **Likelihood:** Medium - Common attack vector for services with anonymous access
- **Mitigation:**
  - Enable CAPTCHA (Turnstile or hCaptcha)
  - Strict rate limiting (30 anonymous sign-ins per hour per IP)
  - Automated cleanup job to delete inactive anonymous accounts after 30 days
  - Monitor anonymous user creation metrics
  - Set up alerts for unusual signup spikes

**Risk 2: Email Verification Friction During Upgrade**
- **Impact:** Medium - Users may abandon upgrade if verification takes too long
- **Likelihood:** High - Email delivery can be delayed
- **Mitigation:**
  - Offer OAuth upgrade path (Google, Apple) for instant upgrade
  - Show clear "Check your email" message with resend option
  - Allow users to continue using app while awaiting verification
  - Consider implementing SMS verification as alternative

**Risk 3: Users Losing Data (App Uninstall Before Upgrade)**
- **Impact:** High - Poor user experience, lost trust
- **Likelihood:** Medium - Users may try app briefly and uninstall
- **Mitigation:**
  - Show upgrade prompts early (after first significant action)
  - Persistent banner: "Sign up to save your data"
  - Exit survey: "Create account before leaving?"
  - Consider implementing data export for anonymous users

**Risk 4: RLS Policy Complexity and Performance**
- **Impact:** Medium - Complex policies could slow down queries
- **Likelihood:** Low - JWT claim checks are fast
- **Mitigation:**
  - Keep RLS policies simple - use `auth.jwt()->>'is_anonymous'` consistently
  - Monitor query performance with Supabase dashboard
  - Add database indexes if needed
  - Test with realistic data volumes

**Risk 5: Incomplete Upgrade Flow (User Gets Stuck)**
- **Impact:** Medium - User has email but no password (limbo state)
- **Likelihood:** Low - But possible if user closes app during verification
- **Mitigation:**
  - Add "Complete Setup" screen for users with email but no password
  - Detect incomplete upgrades on app launch and prompt completion
  - Allow users to cancel upgrade and return to anonymous state
  - Log upgrade funnel metrics to identify drop-off points

### Fallback Options

**Fallback 1: Disable Anonymous Auth If Abuse Detected**
- If anonymous user creation spikes abnormally, temporarily disable `enable_anonymous_sign_ins`
- Existing anonymous users can still use app, but no new anonymous sign-ins
- Re-enable after implementing additional abuse prevention

**Fallback 2: Require Immediate Upgrade for Production**
- If anonymous users cause too many issues, change AuthGate to require account creation
- Keep anonymous sign-in code but only use it for development/testing
- This reverts to current behavior but with less code debt

**Fallback 3: Local-Only Guest Mode**
- If Supabase anonymous auth proves problematic, implement local-only guest mode
- Much more complex but eliminates backend concerns
- Only consider if Approach 1 fails

## Recommendations

### Recommended Approach

**Phase 1: Core Anonymous Authentication (MVP)**
- ✅ Use Supabase native `signInAnonymously()` (Approach 1)
- ✅ Implement in-place upgrade via `updateUser()` (Migration Strategy 1)
- ✅ Create simple permission service (Option 1)
- ✅ Add basic RLS policies for feature restrictions (Option 3 as security layer)
- ✅ Enable CAPTCHA protection

**Timeline:** 2-3 days

**Files to Create/Modify:**
1. `supabase/config.toml` - Enable anonymous auth
2. `lib/features/auth/data/services/auth_service.dart` - Add anonymous methods
3. `lib/features/auth/application/auth_upgrade_service.dart` - New file for upgrade logic
4. `lib/features/auth/presentation/controllers/auth_state_controller.dart` - Update for anonymous users
5. `lib/features/auth/presentation/widgets/auth_gate.dart` - Support anonymous flow
6. `lib/core/permissions/permission_service.dart` - New file for feature checks
7. `lib/core/permissions/user_role.dart` - New file for role enum
8. `lib/features/auth/presentation/screens/account_upgrade_screen.dart` - New upgrade UI
9. `lib/design_system/molecules/upgrade_prompt_banner.dart` - New banner component
10. `supabase/migrations/YYYYMMDDHHMMSS_anonymous_user_policies.sql` - New RLS policies

**Phase 2: Enhanced UX & OAuth Upgrade**
- Add OAuth upgrade path via `linkIdentity()` (Approach 2)
- Implement progressive upgrade prompts (UX Patterns)
- Add analytics to track upgrade funnel
- Create automated cleanup job for inactive anonymous accounts

**Timeline:** 2-3 days

**Phase 3: Advanced Features (Optional)**
- Implement merge-to-existing-account flow (Migration Strategy 2) if user research shows need
- Add feature flag service for remote feature toggling
- Implement A/B testing for upgrade prompts

**Timeline:** 3-5 days

### Alternative Approach (If Constraints Change)

If database size becomes a critical constraint or Supabase anonymous auth proves problematic:
- Consider **Approach 3: Local-Only Guest Mode**
- Requires significant refactoring of repository layer
- Only pursue if Phase 1 implementation reveals insurmountable issues

### Phased Implementation Strategy

**Week 1: Core Implementation**
```
Day 1-2: Backend Setup
- Enable anonymous sign-ins in Supabase config
- Add RLS policies for anonymous user restrictions
- Deploy and test in local development

Day 3-4: AuthService & Controller
- Implement signInAnonymously() and upgradeAnonymousUser()
- Update AuthStateController for anonymous users
- Add permission service and user role enum
- Write unit tests for new auth methods

Day 5: UI Components
- Create AccountUpgradeScreen
- Add "Create Account" button to app bar
- Implement upgrade prompt modal
- Update AuthGate to support anonymous flow
```

**Week 2: Polish & Testing**
```
Day 6-7: UX Improvements
- Add upgrade banner to home screen
- Implement progressive prompts at feature restrictions
- Add success messaging and onboarding
- Test upgrade flow end-to-end

Day 8-9: Security & Performance
- Enable CAPTCHA protection
- Add rate limiting tests
- Performance testing with anonymous users
- Security review of RLS policies

Day 10: Launch Preparation
- Documentation for new auth flow
- Update error handling and localization
- Monitoring and alerting setup
- Soft launch with subset of users
```

## References

### Supabase Documentation
- [Anonymous Sign-Ins | Supabase Docs](https://supabase.com/docs/guides/auth/auth-anonymous)
- [Row Level Security | Supabase Docs](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [Custom Claims & RBAC | Supabase Docs](https://supabase.com/docs/guides/database/postgres/custom-claims-and-role-based-access-control-rbac)
- [Flutter API Reference - signInAnonymously](https://supabase.com/docs/reference/dart/auth-signinanonymously)

### Flutter Resources
- [Flutter Tips - Supabase: Link anonymous user to authenticated](https://apparencekit.dev/flutter-tips/supabase-link-anonymous-user-to-authenticated/)
- [Flutter RBAC Implementation - DEV Community](https://dev.to/sparshmalhotra/role-based-access-control-in-flutter-4m6c)
- [Creating a Flutter Onboarding Screen - LogRocket](https://blog.logrocket.com/creating-flutter-onboarding-screen/)

### Authentication Best Practices
- [Best Practices for Anonymous Authentication - Firebase Blog](https://firebase.blog/posts/2023/07/best-practices-for-anonymous-authentication/)
- [Feature Flags and RBAC - freeCodeCamp](https://www.freecodecamp.org/news/feature-flags-and-role-based-access-control-devops/)

### GitHub Discussions
- [How to convert anonymous user to permanent user - Supabase Discussion #29017](https://github.com/orgs/supabase/discussions/29017)
- [Converting Anonymous users not working - Supabase Issue #25787](https://github.com/supabase/supabase/issues/25787)

### Example Implementations
- [Flutter MVVM Riverpod with Supabase](https://github.com/namanh11611/flutter_mvvm_riverpod)
- [Supabase Flutter SDK Examples](https://github.com/supabase/supabase-flutter)

## Appendix

### A. Error Codes to Add

Add the following error codes to `lib/core/error/error_codes.dart`:

```dart
// Anonymous authentication errors
authAnonymousSignInFailed,
authUpgradeFailed,
authEmailVerificationRequired,
authAlreadyAuthenticated,

// Permission errors
permissionDeniedAnonymousUser,
permissionFeatureRestricted,
permissionUpgradeRequired,
```

Add corresponding localized messages to `lib/l10n/app_en.arb`:

```json
"errorAuthAnonymousSignInFailed": "Could not start trial. Please try again.",
"errorAuthUpgradeFailed": "Could not create account. Please try again.",
"errorAuthEmailVerificationRequired": "Please verify your email before setting a password.",
"errorAuthAlreadyAuthenticated": "You already have an account.",
"errorPermissionDeniedAnonymousUser": "This feature requires an account.",
"errorPermissionFeatureRestricted": "Upgrade to access this feature.",
"errorPermissionUpgradeRequired": "Create an account to continue."
```

### B. Feature Restrictions for Anonymous Users

**Recommended Restrictions for Anonymous Users:**

| Feature | Anonymous | Authenticated | Rationale |
|---------|-----------|---------------|-----------|
| Create spaces | Limited to 5 | Unlimited | Prevents abuse, encourages upgrade |
| Create notes | Limited to 20 | Unlimited | Prevents abuse, encourages upgrade |
| Create todo lists | Limited to 10 | Unlimited | Prevents abuse, encourages upgrade |
| Create custom lists | Limited to 5 | Unlimited | Prevents abuse, encourages upgrade |
| Search content | ✅ Full | ✅ Full | Core feature, no reason to restrict |
| Archive items | ✅ Full | ✅ Full | Core feature, no reason to restrict |
| Favorite items | ✅ Full | ✅ Full | Core feature, no reason to restrict |
| Tags | Limited to 10 | Unlimited | Prevents abuse |
| Export data | ❌ Disabled | ✅ Enabled | Premium feature, encourages upgrade |
| Cloud sync | ✅ Enabled | ✅ Enabled | Needed to preserve data for upgrade |
| Dark mode | ✅ Enabled | ✅ Enabled | No reason to restrict |
| Multi-device access | ❌ Disabled | ✅ Enabled | Requires account, encourages upgrade |
| Share spaces | ❌ Disabled | ✅ Enabled | Future feature, requires account |

**RLS Policy Examples:**

```sql
-- Limit anonymous users to 5 spaces
CREATE POLICY "Anonymous users limited to 5 spaces"
ON spaces FOR INSERT
TO authenticated
WITH CHECK (
  CASE
    WHEN (SELECT (auth.jwt()->>'is_anonymous')::boolean) IS TRUE
    THEN (SELECT COUNT(*) FROM spaces WHERE user_id = auth.uid()) < 5
    ELSE true
  END
);

-- Limit anonymous users to 20 notes per space
CREATE POLICY "Anonymous users limited to 20 notes per space"
ON notes FOR INSERT
TO authenticated
WITH CHECK (
  CASE
    WHEN (SELECT (auth.jwt()->>'is_anonymous')::boolean) IS TRUE
    THEN (SELECT COUNT(*) FROM notes WHERE user_id = auth.uid() AND space_id = NEW.space_id) < 20
    ELSE true
  END
);
```

### C. Monitoring and Analytics

**Key Metrics to Track:**

1. **Anonymous User Funnel:**
   - Anonymous sign-ups per day
   - Anonymous users who create first space
   - Anonymous users who create first note
   - Anonymous users who hit feature limits
   - Anonymous users who start upgrade flow
   - Anonymous users who complete upgrade

2. **Upgrade Conversion:**
   - Upgrade conversion rate (anonymous → permanent)
   - Time to upgrade (median, average)
   - Upgrade method (email/password vs. OAuth)
   - Upgrade abandonment points

3. **Abuse Detection:**
   - Anonymous sign-ups per IP address
   - Anonymous users with suspiciously high activity
   - Failed CAPTCHA attempts
   - Database size growth rate

4. **Performance:**
   - Anonymous sign-in latency
   - RLS policy query performance
   - Upgrade flow latency

**Implementation:**
- Use Supabase Analytics for basic metrics
- Consider adding Mixpanel or Amplitude for detailed funnel analysis
- Set up Sentry for error tracking
- Create Supabase dashboard queries for abuse detection

### D. Future Considerations

**Features to Consider After Initial Launch:**

1. **Guest Data Expiration Policy:**
   - Automatically delete anonymous accounts after 30 days of inactivity
   - Send notification before deletion (if possible)
   - Allow anonymous users to extend their trial

2. **Social Proof in Upgrade Prompts:**
   - "Join 10,000+ users who upgraded to Pro"
   - Show testimonials or success stories

3. **Freemium Model:**
   - Some features always free (core task management)
   - Premium features require paid upgrade (advanced analytics, AI features)
   - Anonymous users see preview of premium features

4. **Guest Invitation System:**
   - Anonymous users can invite friends
   - Convert to permanent account to unlock sharing

5. **Progressive Web App Considerations:**
   - PWA users may not want to create accounts
   - Consider extended anonymous access for PWA
   - Sync data via local storage with cloud backup

### E. Questions for Further Investigation

1. **Product Strategy:**
   - What is the target conversion rate from anonymous to permanent users?
   - How long should the anonymous trial period last before prompting upgrade?
   - Should we implement a freemium model or just anonymous trial + full access?

2. **Technical:**
   - What is the expected number of anonymous users? (Important for capacity planning)
   - Should we implement automatic cleanup of abandoned anonymous accounts?
   - Do we need to support migrating anonymous data to an existing account? (Complex edge case)

3. **UX:**
   - Where should upgrade prompts appear in the UI?
   - How aggressive should we be with upgrade messaging?
   - Should we implement a "skip for now" counter to avoid annoying users?

4. **Legal/Privacy:**
   - Do anonymous users need to accept terms of service?
   - How do GDPR/privacy laws apply to anonymous users?
   - Should anonymous users be informed that their data may be deleted after inactivity?

### F. Testing Strategy

**Unit Tests:**
- `auth_service_test.dart` - Test `signInAnonymously()` and `upgradeAnonymousUser()` methods
- `permission_service_test.dart` - Test role detection and permission checks
- `auth_upgrade_service_test.dart` - Test upgrade flow logic

**Integration Tests:**
- Anonymous sign-in → Create data → Upgrade → Verify data persists
- Anonymous sign-in → Hit feature limit → See upgrade prompt
- Anonymous sign-in → Attempt restricted feature → See permission error

**Widget Tests:**
- `auth_gate_test.dart` - Test routing for anonymous vs. permanent users
- `account_upgrade_screen_test.dart` - Test upgrade form validation and submission
- `upgrade_prompt_banner_test.dart` - Test banner display and dismissal

**Manual Testing Scenarios:**
1. Fresh install → Auto sign-in anonymously → Create spaces/notes → Upgrade → Verify data
2. Anonymous user → Hit 5 space limit → See upgrade prompt → Upgrade → Create 6th space
3. Anonymous user → Try to export data → See "Upgrade Required" message
4. Anonymous user → Start upgrade → Close app → Reopen → See "Complete Setup" prompt
5. Anonymous user → Upgrade with existing email → Handle conflict gracefully

**Load Testing:**
- Simulate 100 anonymous sign-ins per minute (abuse scenario)
- Verify rate limiting works correctly
- Verify CAPTCHA prevents bot sign-ups

### G. Code Review Checklist

Before merging anonymous user implementation:

**Security:**
- [ ] CAPTCHA enabled in Supabase config
- [ ] Rate limiting configured appropriately
- [ ] RLS policies use `is_anonymous` claim correctly
- [ ] All permission checks are server-side enforced
- [ ] No sensitive features exposed to anonymous users

**Error Handling:**
- [ ] All new auth methods use try-catch with AppError
- [ ] Error codes added to error_codes.dart
- [ ] Localized error messages added to app_en.arb and app_de.arb
- [ ] Errors logged with ErrorLogger

**Testing:**
- [ ] Unit tests for all new methods (>80% coverage)
- [ ] Widget tests for new screens and prompts
- [ ] Integration tests for upgrade flow
- [ ] Manual testing completed and documented

**UX:**
- [ ] Upgrade prompts are clear and non-intrusive
- [ ] Users understand they're using a trial/temporary account
- [ ] Upgrade flow is simple and fast (minimal steps)
- [ ] Error states have helpful messaging

**Performance:**
- [ ] Anonymous sign-in completes in <200ms
- [ ] RLS policies don't significantly slow queries
- [ ] No N+1 query issues with permission checks

**Documentation:**
- [ ] CLAUDE.md updated with anonymous user patterns
- [ ] README includes anonymous user setup instructions
- [ ] Code comments explain upgrade flow
- [ ] Migration guide for RLS policy changes
