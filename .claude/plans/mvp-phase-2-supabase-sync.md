# Later MVP - Phase 2: Supabase Backend & Sync

## Objective and Scope

Integrate Supabase backend to enable cross-device sync, user authentication, and cloud backup while maintaining the offline-first architecture from Phase 1. This phase transitions from local-only to a hybrid local-first + cloud-sync model.

**What's In Scope:**
- Supabase CLI setup with local development stack
- Database schema design and migrations
- Row-Level Security (RLS) policies
- Email/password authentication
- OAuth provider setup (Google, GitHub)
- Bi-directional sync between local Hive and Supabase
- Conflict resolution (last-write-wins)
- Sync status indicators
- Account creation and sign-in flows
- Local-to-cloud migration for existing users

**What's Out of Scope (Future Phases):**
- Real-time collaboration
- Sharing spaces with other users
- Advanced conflict resolution (merge strategies)
- Natural language processing
- Search functionality
- Push notifications

## Technical Approach and Reasoning

### Architecture Decisions

**1. Local-First Sync (Optimistic UI)**
- **Why:** User actions feel instant, app works offline
- **Reasoning:** Hive remains source of truth; Supabase is backup/sync layer
- **Flow:** User action → Update Hive → Queue sync → Background sync to Supabase

**2. Supabase CLI for Infrastructure-as-Code**
- **Why:** Version-controlled database schema and config
- **Reasoning:** Aligns with research findings, enables local dev without consuming free tier quota
- **Benefit:** Test migrations locally before pushing to production

**3. Dual Repository Pattern**
- **Why:** Abstraction allows seamless online/offline operation
- **Structure:**
  - `LocalRepository` (Hive) - always used
  - `RemoteRepository` (Supabase) - used when authenticated
  - `SyncRepository` - orchestrates between them

**4. JWT-Based Authentication**
- **Why:** Supabase built-in auth with RLS integration
- **Reasoning:** Secure, scalable, integrates with OAuth providers
- **Benefit:** No custom auth logic needed

**5. Sync Queue with Retry Logic**
- **Why:** Handle intermittent connectivity gracefully
- **Reasoning:** Operations queue when offline, auto-retry when online
- **Benefit:** User never sees sync failures under normal conditions

### Database Schema Design

```sql
-- Users table (managed by Supabase Auth)
-- auth.users - built-in

-- Profiles table (extends auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  display_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Spaces table
CREATE TABLE spaces (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL CHECK (char_length(name) >= 1 AND char_length(name) <= 100),
  icon TEXT,
  color TEXT,
  is_archived BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Sync metadata
  version INTEGER DEFAULT 1,  -- For conflict resolution

  UNIQUE(user_id, name)  -- Space names must be unique per user
);

-- Items table
CREATE TABLE items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  space_id UUID NOT NULL REFERENCES spaces(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('task', 'note', 'list')),
  title TEXT NOT NULL CHECK (char_length(title) >= 1 AND char_length(title) <= 500),
  content TEXT CHECK (char_length(content) <= 50000),
  is_completed BOOLEAN DEFAULT FALSE,
  due_date TIMESTAMPTZ,
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Sync metadata
  version INTEGER DEFAULT 1,  -- For conflict resolution
  is_deleted BOOLEAN DEFAULT FALSE  -- Soft delete for sync
);

-- Indexes for performance
CREATE INDEX idx_items_user_id ON items(user_id);
CREATE INDEX idx_items_space_id ON items(space_id);
CREATE INDEX idx_items_type ON items(type);
CREATE INDEX idx_items_updated_at ON items(updated_at);  -- For incremental sync
CREATE INDEX idx_spaces_user_id ON spaces(user_id);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE spaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE items ENABLE ROW LEVEL SECURITY;
```

### Sync Strategy

**Incremental Sync Algorithm:**
```
1. On app launch (if authenticated):
   - Get last_sync_timestamp from local storage
   - Fetch items/spaces WHERE updated_at > last_sync_timestamp
   - Merge into local Hive (last-write-wins based on updated_at)

2. On local changes:
   - Update Hive immediately (instant UI feedback)
   - Add to sync queue with operation type (create/update/delete)
   - Process queue in background when online

3. Conflict Resolution (Last-Write-Wins):
   - Compare updated_at timestamps
   - Keep item with newer updated_at
   - Store version number for future merge strategies
```

**Sync Queue Schema:**
```dart
SyncOperation {
  String id;
  String operation;  // 'create', 'update', 'delete'
  String entityType; // 'item', 'space'
  String entityId;
  Map<String, dynamic> data;
  DateTime queuedAt;
  int retryCount;
  String? error;
}
```

## Implementation Phases

### Phase 2.1: Supabase Local Setup & Schema

- [ ] **Task 2.1.1: Install and Initialize Supabase CLI**
  - Install Supabase CLI globally (`npm install -g supabase` or Scoop on Windows)
  - Run `supabase init` in project root
  - Review generated `supabase/config.toml` configuration
  - Start local Supabase stack with `supabase start`
  - Verify local services: Studio (http://localhost:54323), API (http://localhost:54321)
  - Document local URLs and keys in project README

- [ ] **Task 2.1.2: Create Database Schema Migration**
  - Create initial migration: `supabase migration new initial_schema`
  - Define profiles table extending auth.users
  - Define spaces table with user_id foreign key
  - Define items table with user_id and space_id foreign keys
  - Add indexes for performance (user_id, space_id, updated_at)
  - Add constraints (name length, type enum, unique space names per user)
  - Apply migration locally: `supabase db reset`
  - Verify schema in local Studio UI

- [ ] **Task 2.1.3: Implement Row-Level Security Policies**
  - Create RLS policy for profiles: users can only view/edit their own profile
  - Create RLS policies for spaces:
    - SELECT: user_id = auth.uid()
    - INSERT: user_id = auth.uid()
    - UPDATE: user_id = auth.uid()
    - DELETE: user_id = auth.uid()
  - Create RLS policies for items:
    - SELECT: user_id = auth.uid() AND is_deleted = false
    - INSERT: user_id = auth.uid() AND space exists and belongs to user
    - UPDATE: user_id = auth.uid()
    - DELETE: user_id = auth.uid() (sets is_deleted = true)
  - Test RLS policies with multiple user scenarios in local Studio
  - Document security rules in migration file

- [ ] **Task 2.1.4: Generate TypeScript Types**
  - Run `supabase gen types typescript --local > lib/data/models/supabase_types.dart`
  - Convert TypeScript types to Dart equivalents manually (or use converter)
  - Create Dart model classes matching database schema
  - Add JSON serialization methods (toJson, fromJson)
  - Update existing Item and Space models to support sync fields (version, updated_at)

- [ ] **Task 2.1.5: Seed Local Database**
  - Create `supabase/seed.sql` with test user and sample data
  - Add test user via Supabase Auth
  - Create sample spaces for test user
  - Create sample items across different spaces
  - Run `supabase db reset` to apply seed data
  - Verify seed data appears in local Studio

### Phase 2.2: Flutter Supabase Client Setup

- [ ] **Task 2.2.1: Add Supabase Dependencies**
  - Add `supabase_flutter: ^2.8.0` to pubspec.yaml
  - Add `flutter_dotenv: ^5.1.0` for environment variables
  - Create `.env` file with local Supabase credentials
  - Add `.env` to `.gitignore`
  - Create `.env.example` template for team
  - Run `flutter pub get`

- [ ] **Task 2.2.2: Initialize Supabase Client**
  - Create `lib/core/services/supabase_service.dart` as singleton
  - Initialize Supabase in `main.dart` before runApp
  - Load environment variables from .env
  - Configure Supabase client with local URL and anon key
  - Add auth state change listener
  - Test connection to local Supabase instance

- [ ] **Task 2.2.3: Create Remote Repository Layer**
  - Create `lib/data/repositories/remote_item_repository.dart`
  - Implement CRUD operations using Supabase client:
    - `createItem()` - INSERT with RLS
    - `getItems()` - SELECT with user filter
    - `getItemsBySpace()` - SELECT with space_id filter
    - `updateItem()` - UPDATE with version increment
    - `deleteItem()` - UPDATE is_deleted = true (soft delete)
  - Create `lib/data/repositories/remote_space_repository.dart`
  - Implement CRUD operations for spaces
  - Add error handling for network failures
  - Test operations against local Supabase

- [ ] **Task 2.2.4: Implement Sync Queue**
  - Create `lib/data/local/sync_queue.dart` using Hive
  - Define SyncOperation model with Hive adapter
  - Implement queue operations: enqueue, dequeue, peek, clear
  - Add retry logic with exponential backoff
  - Persist queue to survive app restarts
  - Add queue status tracking (pending count, last sync time)

### Phase 2.3: Authentication Flows

- [ ] **Task 2.3.1: Sign Up Screen**
  - Create `lib/widgets/screens/auth/sign_up_screen.dart`
  - Implement email input with validation
  - Implement password input with strength indicator
  - Add password confirmation field
  - Add "Sign Up" button with loading state
  - Call Supabase `auth.signUp()` with email/password
  - Show email confirmation required message
  - Handle errors (email already exists, weak password)
  - Add "Already have account? Sign In" link

- [ ] **Task 2.3.2: Sign In Screen**
  - Create `lib/widgets/screens/auth/sign_in_screen.dart`
  - Implement email and password inputs
  - Add "Sign In" button with loading state
  - Call Supabase `auth.signInWithPassword()`
  - Navigate to home on success
  - Show error messages for invalid credentials
  - Add "Forgot Password?" link
  - Add "Don't have account? Sign Up" link
  - Add "Continue without account" option (local-only mode)

- [ ] **Task 2.3.3: OAuth Provider Setup (Google)**
  - Configure Google OAuth app in Google Cloud Console
  - Get Client ID and Client Secret
  - Add to local Supabase config.toml for development
  - Configure in Supabase Dashboard for production (manual step)
  - Add Google sign-in button to sign-in screen
  - Implement OAuth flow using `auth.signInWithOAuth()`
  - Handle callback and token exchange
  - Test OAuth flow on mobile and web

- [ ] **Task 2.3.4: OAuth Provider Setup (GitHub)**
  - Create GitHub OAuth app in GitHub settings
  - Get Client ID and Client Secret
  - Add to local Supabase config.toml
  - Configure in Supabase Dashboard for production
  - Add GitHub sign-in button
  - Implement OAuth flow
  - Test authentication flow

- [ ] **Task 2.3.5: Password Reset Flow**
  - Create `lib/widgets/screens/auth/forgot_password_screen.dart`
  - Implement email input for reset
  - Call Supabase `auth.resetPasswordForEmail()`
  - Show "Check your email" confirmation
  - Create password reset confirmation screen
  - Handle magic link callback
  - Allow user to set new password
  - Test complete reset flow

- [ ] **Task 2.3.6: Auth State Management**
  - Create `lib/providers/auth_provider.dart`
  - Listen to Supabase auth state changes
  - Expose current user and auth status
  - Implement sign out functionality
  - Handle token refresh automatically
  - Persist auth session across app restarts
  - Test session timeout and renewal

### Phase 2.4: Sync Engine Implementation

- [ ] **Task 2.4.1: Initial Full Sync (Cloud → Local)**
  - Create `lib/core/services/sync_service.dart`
  - Implement `performInitialSync()` method:
    - Fetch all user's spaces from Supabase
    - Fetch all user's items from Supabase
    - Clear local Hive boxes (after confirmation)
    - Insert cloud data into Hive
    - Set last_sync_timestamp
  - Show sync progress indicator
  - Handle sync errors gracefully
  - Test with large datasets (1000+ items)

- [ ] **Task 2.4.2: Incremental Sync (Cloud → Local)**
  - Implement `performIncrementalSync()` method:
    - Get last_sync_timestamp from local storage
    - Fetch spaces WHERE updated_at > last_sync_timestamp
    - Fetch items WHERE updated_at > last_sync_timestamp
    - Merge changes into Hive using conflict resolution
    - Update last_sync_timestamp
  - Run on app launch and periodically
  - Show subtle sync indicator
  - Handle deleted items (is_deleted = true)

- [ ] **Task 2.4.3: Local → Cloud Sync (Queue Processing)**
  - Implement `processSyncQueue()` method:
    - Dequeue oldest operation from sync queue
    - Execute operation via RemoteRepository
    - On success: remove from queue, update local version
    - On failure: increment retry count, re-queue with backoff
    - Continue until queue is empty or max retries reached
  - Run in background when online
  - Show sync status in UI
  - Log sync operations for debugging

- [ ] **Task 2.4.4: Conflict Resolution Logic**
  - Implement `resolveConflict()` method:
    - Compare local and remote updated_at timestamps
    - Keep item with newer timestamp (last-write-wins)
    - Update losing item's version number
    - Log conflicts for future analysis
  - Handle edge cases (simultaneous edits, deleted vs updated)
  - Show conflict notification to user (optional)
  - Store conflict history for debugging

- [ ] **Task 2.4.5: Offline Queue Management**
  - Update ItemsProvider to enqueue changes:
    - On `addItem()`: add to queue with 'create' operation
    - On `updateItem()`: add to queue with 'update' operation
    - On `deleteItem()`: add to queue with 'delete' operation
  - Update SpacesProvider similarly
  - Process queue automatically when connectivity restored
  - Show pending sync count in UI
  - Test offline → online transition

### Phase 2.5: Migration Flow for Existing Users

- [ ] **Task 2.5.1: Local-to-Cloud Migration UI**
  - Create `lib/widgets/screens/settings/account_settings_screen.dart`
  - Add "Create Account & Sync" button for local-only users
  - Show benefits of cloud sync (backup, multi-device)
  - Explain migration process clearly
  - Add "Continue Local Only" option
  - Track migration analytics

- [ ] **Task 2.5.2: Migration Logic**
  - Create `lib/core/services/migration_service.dart`
  - Implement `migrateLocalDataToCloud()` method:
    - Create user account via sign-up flow
    - Upload all local spaces to Supabase
    - Upload all local items to Supabase
    - Verify upload success
    - Switch from local-only to sync mode
    - Delete local-only flag
  - Show migration progress with percentage
  - Handle migration errors with retry
  - Test with various data sizes

- [ ] **Task 2.5.3: Rollback Mechanism**
  - Implement migration rollback if upload fails
  - Keep local data intact during migration
  - Only switch to sync mode after full verification
  - Allow user to cancel migration midway
  - Test rollback scenarios

### Phase 2.6: Sync UI Indicators

- [ ] **Task 2.6.1: Sync Status Badge**
  - Create `lib/widgets/components/sync/sync_status_badge.dart`
  - Show in app bar with icon and label:
    - Synced: Checkmark, "Synced 2m ago"
    - Syncing: Spinner, "Syncing..."
    - Pending: Queue icon, "3 items pending"
    - Error: Alert icon, "Sync failed"
    - Offline: Cloud-off icon, "Offline"
  - Make badge tappable to show sync details
  - Update in real-time based on SyncService state

- [ ] **Task 2.6.2: Sync Details Bottom Sheet**
  - Create `lib/widgets/modals/sync_details_modal.dart`
  - Show last sync timestamp
  - Show pending operations count
  - Show recent sync errors with retry button
  - Show data usage stats (items synced, data transferred)
  - Add "Sync Now" manual trigger button
  - Add "View Sync Log" for debugging

- [ ] **Task 2.6.3: Item-Level Sync Indicators**
  - Add subtle indicator to ItemCard for pending sync
  - Show amber dot for unsaved changes
  - Show red dot for sync errors
  - Animate indicator during sync operation
  - Remove indicator when synced successfully

### Phase 2.7: Production Deployment Setup

- [ ] **Task 2.7.1: Create Supabase Production Project**
  - Sign up for Supabase free tier account
  - Create new project via Supabase Dashboard
  - Note project URL and anon key
  - Configure custom project name
  - Set up project region (closest to target users)

- [ ] **Task 2.7.2: Deploy Database Schema to Production**
  - Link local project to remote: `supabase link --project-ref YOUR_REF`
  - Push migrations to production: `supabase db push`
  - Verify schema in production Studio
  - Test RLS policies in production
  - Run seed script if needed (optional)

- [ ] **Task 2.7.3: Configure OAuth in Dashboard**
  - Navigate to Authentication → Providers in Dashboard
  - Enable and configure Google OAuth:
    - Add Client ID and Client Secret
    - Set authorized redirect URL
  - Enable and configure GitHub OAuth:
    - Add Client ID and Client Secret
    - Set authorized redirect URL
  - Test OAuth flows against production

- [ ] **Task 2.7.4: Configure Production Environment**
  - Create `.env.production` with production Supabase credentials
  - Update Flutter app to use production config in release builds
  - Test authentication against production
  - Test sync operations against production
  - Monitor Supabase Dashboard for usage stats

- [ ] **Task 2.7.5: Set Up Email Templates**
  - Customize email templates in Dashboard:
    - Confirmation email
    - Password reset email
    - Magic link email
  - Add branding (logo, colors)
  - Test email delivery
  - Configure custom SMTP if desired (optional, requires Dashboard)

### Phase 2.8: Testing & Polish

- [ ] **Task 2.8.1: Integration Testing**
  - Write integration tests for auth flows (sign up, sign in, sign out)
  - Write integration tests for sync operations (create, update, delete)
  - Test conflict resolution scenarios
  - Test offline → online transition
  - Test migration from local-only to cloud sync
  - Achieve >70% coverage for sync logic

- [ ] **Task 2.8.2: Error Handling & Recovery**
  - Test all error scenarios:
    - Network timeout during sync
    - Invalid credentials
    - RLS policy violations
    - Quota exceeded (free tier limits)
    - Invalid data format
  - Implement graceful degradation (fall back to local-only)
  - Add user-friendly error messages
  - Log errors for debugging

- [ ] **Task 2.8.3: Performance Optimization**
  - Profile sync operations with large datasets
  - Optimize queries with proper indexes
  - Implement pagination for initial sync (batch 100 items)
  - Reduce payload size (exclude unnecessary fields)
  - Test sync performance with poor network conditions
  - Monitor Supabase API usage

- [ ] **Task 2.8.4: Security Audit**
  - Review RLS policies for gaps
  - Test data isolation between users
  - Verify passwords are never logged
  - Check for SQL injection vulnerabilities
  - Verify JWT token security
  - Test session timeout and renewal

- [ ] **Task 2.8.5: User Acceptance Testing**
  - Recruit beta testers (5-10 users)
  - Provide test builds (iOS TestFlight, Android APK)
  - Collect feedback on sync reliability
  - Monitor crash reports and errors
  - Iterate on UX issues
  - Document known issues and workarounds

## Dependencies and Prerequisites

### From Phase 1
- Completed Phase 1 with local Hive implementation
- Item and Space models with UUID IDs
- Repository pattern with abstraction layer
- Working offline-first UI

### Supabase Requirements
- Supabase CLI installed (npm, Scoop, or Homebrew)
- Docker Desktop (for local Supabase stack)
- Supabase free tier account (for production)
- OAuth app credentials (Google, GitHub)

### Flutter Packages (Additional)
```yaml
dependencies:
  # Add to existing Phase 1 dependencies
  supabase_flutter: ^2.8.0       # Supabase client
  flutter_dotenv: ^5.1.0         # Environment variables
  connectivity_plus: ^6.0.0      # Network connectivity detection
  retry: ^3.1.0                  # Retry logic for failed requests
```

### Network Requirements
- Stable internet connection for initial setup
- Development environment can access localhost:54321 (local Supabase)
- Production app can access Supabase cloud API
- OAuth providers can redirect to app (configure deep links)

### OAuth Setup (Manual Steps)
1. **Google Cloud Console:**
   - Create OAuth 2.0 Client ID
   - Configure authorized origins and redirect URIs
   - Download credentials

2. **GitHub Settings:**
   - Create OAuth App
   - Set authorization callback URL
   - Note Client ID and Secret

3. **Supabase Dashboard (Production):**
   - Add OAuth credentials in Authentication → Providers
   - Configure redirect URLs in URL Configuration
   - Test OAuth flows

## Challenges and Considerations

### Technical Challenges

**Challenge 1: Sync Conflicts**
- **Issue:** Simultaneous edits on multiple devices create conflicts
- **Mitigation:** Last-write-wins initially; store conflict history for future merge strategies
- **Monitoring:** Log all conflicts; analyze patterns to improve resolution logic

**Challenge 2: Network Reliability**
- **Issue:** Sync can fail due to poor connectivity or timeouts
- **Mitigation:** Retry logic with exponential backoff; queue operations offline
- **Testing:** Use network throttling tools to simulate poor conditions

**Challenge 3: Data Migration Failures**
- **Issue:** Migration from local to cloud can fail midway
- **Mitigation:** Atomic operations; rollback on failure; keep local data intact
- **Recovery:** Allow user to retry migration; provide manual export option

**Challenge 4: Free Tier Limitations**
- **Issue:** 500MB database, 2 projects max
- **Mitigation:** Monitor usage; implement data cleanup; prepare upgrade path
- **Optimization:** Use soft deletes; compress large content; archive old data

**Challenge 5: RLS Policy Complexity**
- **Issue:** Complex RLS can impact performance or create security gaps
- **Mitigation:** Keep policies simple; test thoroughly; monitor query performance
- **Auditing:** Regular security reviews; test with multiple user scenarios

### UX Considerations

**Consideration 1: Sync Transparency**
- Show sync status clearly without being intrusive
- Use subtle indicators (badge, not modal)
- Provide detailed sync info on demand
- Never block UI for sync operations

**Consideration 2: Migration Anxiety**
- Clearly communicate migration benefits
- Explain data safety (backup, not move)
- Show progress and allow cancellation
- Provide "Continue Local Only" option

**Consideration 3: OAuth Friction**
- Simplify OAuth flow (single tap)
- Handle errors gracefully (redirect back, show message)
- Support web and mobile equally
- Test on actual devices, not just simulators

**Consideration 4: Offline Capability**
- Maintain full functionality offline (Phase 1 behavior)
- Show pending sync count unobtrusively
- Auto-sync when online without user action
- Allow manual sync trigger if desired

**Consideration 5: First-Time Cloud User**
- Gentle onboarding for cloud features
- Explain benefits of account creation
- Make account optional, not mandatory
- Preserve local-only mode as valid choice

### Security Considerations

**Security 1: Data Privacy**
- Encrypt data in transit (HTTPS)
- Implement RLS correctly (no data leakage)
- Support account deletion (GDPR compliance)
- Provide data export for transparency

**Security 2: Authentication**
- Use strong password requirements
- Implement rate limiting (Supabase built-in)
- Secure OAuth callback URLs
- Handle token refresh securely

**Security 3: API Keys**
- Never commit keys to Git (.env in .gitignore)
- Use environment-specific keys (dev, prod)
- Rotate keys if compromised
- Document key management process

## Success Criteria

### Functional Requirements
- ✅ Users can create account with email/password
- ✅ Users can sign in with Google and GitHub OAuth
- ✅ Users can sync data across devices
- ✅ Local data migrates to cloud successfully
- ✅ Offline changes sync when online
- ✅ Conflicts resolve without data loss
- ✅ Users can reset password via email
- ✅ Users can sign out and data persists

### Performance Requirements
- ✅ Initial sync completes in <10 seconds for 100 items
- ✅ Incremental sync completes in <3 seconds
- ✅ Sync queue processes operations in <1 second each
- ✅ App remains responsive during background sync
- ✅ Auth operations complete in <2 seconds

### Quality Requirements
- ✅ Sync success rate >99% under normal conditions
- ✅ Zero data loss during sync or migration
- ✅ RLS policies prevent unauthorized data access
- ✅ No crashes during sync operations
- ✅ Integration test coverage >70%

### User Experience Requirements
- ✅ Sync status visible and up-to-date
- ✅ Users understand when data is syncing
- ✅ Migration process is clear and safe
- ✅ OAuth flows work on all platforms
- ✅ Errors provide actionable recovery steps

### Security Requirements
- ✅ Passes RLS security audit
- ✅ OAuth tokens handled securely
- ✅ Passwords meet strength requirements
- ✅ Sessions timeout appropriately
- ✅ No sensitive data in logs

## Migration Path to Phase 3

**Preparing for Collaboration Features:**
- Database schema supports multi-user access (add shared_with field)
- RLS policies can be extended for sharing
- Sync engine handles collaborative edits
- UI ready for presence indicators

**Future Enhancements:**
- Real-time subscriptions (Supabase Realtime)
- Space sharing with permissions
- Collaborative editing with presence
- Activity feed and notifications
- Advanced search with full-text indexing

## Documentation Requirements

- [ ] Update README with Supabase setup instructions
- [ ] Document local development workflow with Supabase CLI
- [ ] Create migration guide for existing users
- [ ] Document OAuth setup process
- [ ] Add sync architecture diagram
- [ ] Document troubleshooting common sync issues
- [ ] Create security best practices guide

## Rollout Strategy

**Phase 2A: Internal Alpha (Week 1-2)**
- Deploy to internal testers only
- Test auth flows thoroughly
- Validate sync reliability
- Fix critical bugs

**Phase 2B: Closed Beta (Week 3-4)**
- Invite 10-20 external testers
- Monitor sync operations and errors
- Collect feedback on UX
- Optimize performance based on real usage

**Phase 2C: Open Beta (Week 5-6)**
- Expand to 100+ testers
- Monitor Supabase quota usage
- Test with diverse network conditions
- Prepare for public launch

**Phase 2D: Production Launch**
- Deploy to app stores
- Monitor backend performance
- Provide user support
- Iterate based on analytics

---

**Total Estimated Effort**: 4-5 weeks for single developer
**Priority**: P1 - Required for cross-device sync
**Status**: Dependent on Phase 1 completion
**Prerequisites**: Phase 1 fully functional and tested
