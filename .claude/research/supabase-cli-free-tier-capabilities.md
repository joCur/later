# Research: Supabase CLI Configuration Capabilities on Free Tier

## Executive Summary

The Supabase CLI provides extensive configuration capabilities for database, authentication, and edge functions—even on the free tier. Most development work can be done entirely through the CLI using local development, with changes deployed via migration files and CLI commands. However, certain production configurations, particularly OAuth provider credentials and custom SMTP settings, must be configured through the Supabase Dashboard UI.

**Key Finding:** The CLI offers a "config-as-code" approach through the `supabase/config.toml` file, enabling version-controlled infrastructure setup for local development. The primary workflow involves developing locally (which is free and doesn't consume project quota), then pushing changes to remote projects via `supabase db push` and `supabase functions deploy`.

**Dashboard-Only Requirements:** OAuth provider credentials (client IDs/secrets), production SMTP settings, custom email templates, and redirect URL allow-lists must be configured through the Dashboard UI. The CLI config.toml handles these for local development only.

## Research Scope

### What Was Researched
- Supabase CLI capabilities for database schema management
- Authentication provider configuration (local and remote)
- Edge Functions development and deployment workflow
- Free tier limitations and quotas
- CLI vs Dashboard UI configuration boundaries
- Type generation and developer tooling
- Migration and deployment workflows

### What Was Excluded
- Realtime subscriptions and broadcast features
- Storage bucket configurations
- Advanced self-hosting scenarios
- Paid tier exclusive features (PITR, SOC 2, etc.)
- Third-party integrations beyond OAuth providers

### Research Methodology
- Official Supabase documentation analysis
- Community discussions and GitHub issues review
- Pricing and tier limitation investigation
- CLI reference documentation review

## Current State Analysis

### Free Tier Limitations

**Project Limits:**
- Maximum 2 active projects
- Projects paused after 1 week of inactivity
- No Point-in-Time Recovery (PITR) or automatic backups
- No HIPAA/SOC 2 compliance
- No custom domains (projects use `yourproject.supabase.co`)

**Resource Quotas:**
- 500 MB database storage
- 1 GB file storage
- 50 MB individual file upload size
- 2 million Edge Function invocations per month
- 50 MB Edge Functions script size limit

**Key Advantage:** Local development is completely free and doesn't consume project quota, making the CLI particularly valuable for free tier users who want to develop and test extensively before deploying.

### Industry Standards

**Infrastructure-as-Code Trend:** The Supabase CLI v2 introduced "config as code" functionality, aligning with modern DevOps practices where infrastructure configuration is version-controlled alongside application code.

**Developer Experience Best Practices:**
- Local-first development workflows
- Type-safe database access through generated TypeScript types
- Migration-based schema management
- Environment variable management through .env files
- Git-based version control for all configurations

## Technical Analysis

### Approach 1: Full CLI Workflow (Recommended)

**Description:** Develop entirely locally using `supabase init` and `supabase start`, manage schema through migrations, configure auth providers in config.toml, and deploy to remote via CLI commands.

**Pros:**
- Free local development (doesn't consume project quota)
- Complete version control of database schema and configuration
- Type-safe development with generated TypeScript types
- Fast iteration cycles with local Supabase Studio
- Declarative configuration through config.toml
- Migration history provides clear audit trail
- Works offline for database/auth development

**Cons:**
- OAuth provider credentials still require Dashboard setup for production
- Custom SMTP not available for local development
- Email templates must be manually copied to Dashboard
- Initial Docker setup can be slow (images ~2GB)
- Requires Docker Desktop or compatible container runtime

**Use Cases:**
- New projects starting from scratch
- Teams wanting infrastructure-as-code workflows
- Developers on free tier maximizing quota usage
- Projects with frequent schema changes

**Code Example:**

```bash
# Initialize project
supabase init

# Start local stack
supabase start

# Access local services:
# - Studio UI: http://localhost:54323
# - API: http://localhost:54321
# - DB: postgresql://postgres:postgres@localhost:54322/postgres

# Make schema changes via migrations
supabase migration new create_users_table

# Edit supabase/migrations/[timestamp]_create_users_table.sql
# Add your SQL changes

# Apply migrations locally
supabase db reset

# Generate TypeScript types
supabase gen types typescript --local > types/database.types.ts

# Link to remote project
supabase link --project-ref your-project-id

# Push migrations to production
supabase db push

# Deploy edge functions
supabase functions deploy my-function
```

### Approach 2: Dashboard-First Workflow

**Description:** Use the Supabase Dashboard UI for all configuration and schema changes, optionally pulling changes to local via `supabase db pull`.

**Pros:**
- Visual interface for database design
- Immediate production changes (no deployment step)
- Easier for non-technical team members
- No local Docker requirement
- Quick prototyping and exploration

**Cons:**
- No version control of configuration changes
- Consumes project quota for all testing
- Difficult to rollback changes
- No local development environment
- Hard to replicate across multiple projects
- Schema drift between environments

**Use Cases:**
- Quick prototypes and MVPs
- Non-developers managing simple projects
- Projects with infrequent schema changes
- When Docker isn't available

### Approach 3: Hybrid Workflow

**Description:** Use CLI for database migrations and local development, but configure auth providers, SMTP, and some settings through Dashboard.

**Pros:**
- Best of both worlds
- Version-controlled schema with visual auth setup
- Flexible based on task complexity
- Practical for most real-world projects

**Cons:**
- Configuration split across two locations
- Potential for confusion about where to make changes
- Some duplication (config.toml for local, Dashboard for production)

**Use Cases:**
- Production applications on free tier
- Teams transitioning from Dashboard to CLI
- Projects requiring OAuth authentication
- Applications needing custom SMTP

## Database Management

### CLI Capabilities (Full Control)

**Schema Migrations:**
```bash
# Create new migration
supabase migration new add_profiles_table

# Generate migration from schema diff
supabase db diff -f migration_name

# Pull remote schema changes
supabase db pull

# Apply migrations
supabase db push

# Reset local database (reapply all migrations + seed)
supabase db reset
```

**Declarative Schema Management:**
Instead of imperative migrations, you can define your entire schema in SQL files and use `supabase db diff` to generate migrations automatically:

```bash
# Define schema in supabase/schema.sql
# Then generate migration from diff
supabase db diff -f sync_schema
```

**Type Generation:**
```bash
# Generate TypeScript types from local database
supabase gen types typescript --local > types/database.types.ts

# Generate from remote database
supabase gen types typescript --project-id your-project-ref > types/database.types.ts
```

**Row Level Security (RLS):**
RLS policies are defined in SQL migrations, providing full version control:

```sql
-- In a migration file
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = user_id);
```

### Dashboard-Only Features

None for database management—everything can be done via CLI. However, the Dashboard provides:
- Visual table editor (convenience only)
- SQL editor with autocomplete
- Database backups (not available on free tier)

## Authentication Configuration

### CLI Capabilities (Local Development)

**config.toml Configuration:**
The CLI provides comprehensive auth configuration for local development:

```toml
[auth]
# Site URL for redirects
site_url = "http://localhost:3000"

# Additional allowed redirect URLs
additional_redirect_urls = ["http://localhost:3001", "http://localhost:3002"]

# JWT settings
jwt_expiry = 3600  # 1 hour (max 604,800 / 1 week)
enable_refresh_token_rotation = true
refresh_token_reuse_interval = 10

# Email settings (local only)
[auth.email]
enable_signup = true
double_confirm_changes = true
enable_confirmations = false

# External OAuth providers (local dev)
[auth.external.github]
enabled = true
client_id = "env(SUPABASE_AUTH_GITHUB_CLIENT_ID)"
secret = "env(SUPABASE_AUTH_GITHUB_SECRET)"
redirect_uri = "http://localhost:54321/auth/v1/callback"

[auth.external.google]
enabled = true
client_id = "env(SUPABASE_AUTH_GOOGLE_CLIENT_ID)"
secret = "env(SUPABASE_AUTH_GOOGLE_SECRET)"

# SMS providers (local dev)
[auth.sms.twilio]
enabled = true
account_sid = "env(TWILIO_ACCOUNT_SID)"
message_service_sid = "env(TWILIO_MESSAGE_SERVICE_SID)"
auth_token = "env(TWILIO_AUTH_TOKEN)"
```

**Environment Variables:**
Store sensitive credentials in `.env` file at project root:

```bash
# .env (never commit to git!)
SUPABASE_AUTH_GITHUB_CLIENT_ID=your_client_id
SUPABASE_AUTH_GITHUB_SECRET=your_client_secret
SUPABASE_AUTH_GOOGLE_CLIENT_ID=your_google_client_id
SUPABASE_AUTH_GOOGLE_SECRET=your_google_client_secret
```

### Dashboard-Required Configuration

**Production OAuth Setup:**
For each OAuth provider (Google, GitHub, etc.):

1. **Provider Credentials:** Navigate to Dashboard → Authentication → Providers
   - Enable the provider
   - Enter Client ID and Client Secret
   - These CANNOT be set via CLI for remote projects

2. **Callback URLs:** Each provider requires the Supabase callback URL:
   - Format: `https://your-project-ref.supabase.co/auth/v1/callback`
   - Must be registered in the OAuth provider's application settings

3. **Redirect URL Allow-List:** Dashboard → Authentication → URL Configuration
   - Site URL (main production URL)
   - Additional Redirect URLs (comma-separated list)
   - Supports wildcard patterns for preview URLs: `https://*.vercel.app`

**Important Limitation:** While config.toml can configure OAuth for local development, production OAuth credentials MUST be set through the Dashboard UI. There's no CLI command to push auth provider credentials to remote projects.

## Edge Functions

### CLI Capabilities (Full Control)

**Local Development:**
```bash
# Create new function
supabase functions new my-function

# Serve locally with hot reload
supabase functions serve my-function --env-file ./supabase/.env.local --no-verify-jwt

# Access at http://localhost:54321/functions/v1/my-function
```

**Function Structure:**
```typescript
// supabase/functions/my-function/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { name } = await req.json()
  const data = {
    message: `Hello ${name}!`,
  }

  return new Response(
    JSON.stringify(data),
    { headers: { "Content-Type": "application/json" } },
  )
})
```

**Environment Variables/Secrets:**
```bash
# Set individual secret
supabase secrets set MY_SECRET=value

# Set from .env file
supabase secrets set --env-file ./supabase/.env

# List secrets (doesn't show values)
supabase secrets list

# Secrets are visible in Dashboard after setting via CLI
```

**Built-in Environment Variables:**
Edge Functions automatically have access to:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `SUPABASE_DB_URL`

**Deployment:**
```bash
# Deploy single function
supabase functions deploy my-function

# Deploy all functions
supabase functions deploy

# Deploy with no JWT verification (for webhooks)
supabase functions deploy webhook-handler --no-verify-jwt
```

**Authentication in Edge Functions:**
```typescript
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  // Create client with user's JWT from Authorization header
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
  )

  // Get user from JWT
  const { data: { user } } = await supabaseClient.auth.getUser()

  // RLS policies automatically enforced
  const { data, error } = await supabaseClient
    .from('profiles')
    .select('*')

  return new Response(JSON.stringify(data), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

### Edge Function Limitations (Free Tier)

**Execution Limits:**
- 2 million invocations per month
- 50 MB script size limit
- 10 second CPU time limit per invocation
- 150 MB memory limit

**No Dashboard-Only Features:**
Edge Functions can be fully managed via CLI. The Dashboard provides:
- Function logs viewer (convenience)
- Manual invocation testing (convenience)
- Metrics and usage stats (convenience)

## Email Configuration

### Major Dashboard Requirement

**Custom SMTP (Dashboard Only):**
Production SMTP settings MUST be configured through the Dashboard:

1. Navigate to Dashboard → Authentication → Emails → SMTP Settings
2. Enable Custom SMTP
3. Configure:
   - SMTP Host
   - Port (typically 587 or 465)
   - Username
   - Password
   - Sender email and name

**Important Limitation:** Custom SMTP cannot be configured via CLI for remote projects. The config.toml SMTP settings only apply to local development.

**Email Templates (Dashboard Only):**
Email templates (confirmation, password reset, magic link, etc.) must be:
1. Developed and tested locally (preview via Mailpit at http://localhost:54324)
2. Manually copied to Dashboard → Authentication → Email Templates
3. Customized with Supabase's template variables

**CLI Workaround:** While you can test email templates locally using config.toml, there's currently no CLI command to push templates to production. This is a known limitation discussed in GitHub issue #8165.

## Tools and Libraries

### Supabase CLI

- **Purpose:** Local development environment, migration management, and deployment orchestration
- **Maturity:** Production-ready (v1.0+)
- **License:** Apache 2.0
- **Community:** Official Supabase tool, actively maintained
- **Integration Effort:** Low (requires Docker)
- **Key Features:**
  - Complete local Supabase stack via Docker
  - Migration generation and management
  - Type generation for TypeScript
  - Edge Function development and deployment
  - Secret management
  - Project linking and deployment

**Installation:**
```bash
# macOS/Linux
brew install supabase/tap/supabase

# Windows (via Scoop)
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase

# NPM (cross-platform)
npm install -g supabase
```

### TypeScript Types Generator

- **Purpose:** Generate type-safe database types from Postgres schema
- **Maturity:** Production-ready
- **License:** MIT (part of Supabase CLI)
- **Community:** Official Supabase tool
- **Integration Effort:** Low (single command)
- **Key Features:**
  - Auto-generated types for all tables, views, functions
  - Supports enums and composite types
  - Works with local or remote databases
  - Integrates with supabase-js client

**Usage:**
```bash
# Generate types
supabase gen types typescript --local > types/supabase.ts

# Use in code
import { Database } from './types/supabase'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient<Database>(url, key)

// TypeScript now knows your schema
const { data } = await supabase.from('users').select('*')
// data is typed as Database['public']['Tables']['users']['Row'][]
```

### Auth Helpers (Official Libraries)

- **Purpose:** Framework-specific authentication helpers
- **Maturity:** Production-ready
- **License:** MIT
- **Community:** Official Supabase libraries
- **Integration Effort:** Low
- **Key Features:**
  - Automatic session management
  - SSR support
  - Type-safe auth patterns
  - Cookie handling

**Available For:**
- Next.js (`@supabase/auth-helpers-nextjs`)
- SvelteKit (`@supabase/auth-helpers-sveltekit`)
- Remix (`@supabase/auth-helpers-remix`)
- React (`@supabase/auth-helpers-react`)

### Supabase Studio (Included with CLI)

- **Purpose:** Visual database management interface
- **Maturity:** Production-ready
- **License:** Apache 2.0
- **Community:** Official Supabase tool
- **Integration Effort:** Zero (included with `supabase start`)
- **Key Features:**
  - Table editor with visual schema designer
  - SQL editor with autocomplete
  - RLS policy builder
  - Function management
  - Authentication user management
  - Storage bucket management

**Access:** Automatically available at http://localhost:54323 when running local stack

## Implementation Considerations

### Technical Requirements

**Local Development:**
- Docker Desktop or compatible container runtime (Podman, Rancher Desktop)
- ~2GB disk space for Docker images
- Node.js (for TypeScript type generation and client libraries)
- Git (for version control of migrations and config)

**Deployment:**
- Supabase account (free tier supported)
- GitHub account (optional, for CI/CD)
- Access tokens for CLI authentication

**Network Requirements:**
- Local development works offline (except initial Docker image pull)
- Deployment requires internet connection
- OAuth providers require publicly accessible callback URLs

### Integration Points

**Database Schema:**
- Migrations stored in `supabase/migrations/` directory
- Seed data in `supabase/seed.sql`
- All SQL-based (supports full Postgres features)

**Authentication Flow:**
1. Configure providers in config.toml (local) or Dashboard (production)
2. Use Supabase Auth client libraries in application
3. JWT tokens automatically include user metadata
4. RLS policies automatically enforced based on JWT claims

**Edge Functions Integration:**
- Functions stored in `supabase/functions/` directory
- Each function is a separate Deno module
- Deployed independently or all at once
- Can access database with full RLS support
- Can call other functions via HTTP

**Type Safety:**
```typescript
// Application code remains type-safe
import { Database } from './types/supabase'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient<Database>(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_ANON_KEY!
)

// TypeScript knows the schema
const { data: users } = await supabase
  .from('users')
  .select('id, email, created_at')
  .eq('is_active', true)

// data is fully typed, intellisense works
```

### Risks and Mitigation

**Risk: Configuration Drift Between Local and Remote**
- **Mitigation:** Use `supabase db pull` regularly to sync remote changes locally
- Always develop locally first, then push to remote
- Use Git to track all config.toml and migration changes
- Consider staging environment to test before production

**Risk: OAuth Credentials Not Version Controlled**
- **Mitigation:** Document required OAuth providers in README
- Use environment variables for provider config in config.toml
- Create setup scripts to remind developers to configure Dashboard
- Consider using CI/CD checks to verify provider setup

**Risk: Email Templates Out of Sync**
- **Mitigation:** Store template source in version control
- Document manual Dashboard update process
- Test templates locally via Mailpit before copying to Dashboard
- Consider templating tools to generate final HTML

**Risk: Free Tier Project Pausing**
- **Mitigation:** Set up monitoring/alerts for project activity
- Document restoration process
- Use multiple projects for different environments if needed
- Upgrade to Pro tier if project becomes critical

**Risk: Migration Failures on Production**
- **Mitigation:** Test all migrations on local environment first
- Use transactions in migration files (automatic in Postgres)
- Keep migrations small and focused
- Have rollback plan (reverse migration or backup restore)

**Risk: Docker Storage Consumption**
- **Mitigation:** Regularly prune unused Docker images
- Use `supabase stop` when not developing
- Consider cloud-based alternatives for resource-constrained machines

## Recommendations

### Recommended Approach: CLI-First Hybrid Workflow

**Primary Strategy:**
1. **Initialize with CLI:** Start all new projects with `supabase init`
2. **Develop Locally:** Use `supabase start` for free, quota-free development
3. **Version Control Everything:** Commit migrations, config.toml, and seed data to Git
4. **Deploy via CLI:** Use `supabase db push` and `supabase functions deploy`
5. **Configure OAuth in Dashboard:** Accept that OAuth credentials require Dashboard setup
6. **Document Dashboard Steps:** Maintain clear documentation for team members

**Why This Approach:**
- Maximizes free tier value (local development is free)
- Provides infrastructure-as-code benefits
- Enables team collaboration via Git
- Supports CI/CD workflows
- Pragmatic about Dashboard requirements

**Phased Implementation:**

**Phase 1: Local Setup (Week 1)**
```bash
# Initialize project
supabase init
supabase start

# Configure auth providers for local dev in config.toml
# Set up .env file with credentials
# Create initial database schema via migrations
supabase migration new initial_schema

# Develop and test locally
supabase db reset  # Apply migrations
supabase gen types typescript --local > types/database.types.ts
```

**Phase 2: Remote Project Setup (Week 2)**
```bash
# Create project in Supabase Dashboard (if not exists)
# Link local to remote
supabase link --project-ref your-project-id

# Push schema to remote
supabase db push

# Configure OAuth in Dashboard
# - Add provider credentials
# - Set redirect URLs
# - Test authentication flow
```

**Phase 3: Edge Functions (Week 3)**
```bash
# Develop functions locally
supabase functions new my-function
supabase functions serve --env-file .env.local

# Set production secrets
supabase secrets set --env-file .env.production

# Deploy functions
supabase functions deploy
```

**Phase 4: Production Hardening (Week 4)**
- Configure custom SMTP in Dashboard
- Customize email templates
- Set up monitoring and alerts
- Document deployment procedures
- Create CI/CD pipeline (optional)

### Alternative Approach: Dashboard-First for Prototypes

**When to Use:**
- Rapid prototyping (< 1 week projects)
- Non-technical users
- No Docker available
- Learning/exploring Supabase

**Quick Start:**
1. Create project in Dashboard
2. Use Table Editor to create schema
3. Configure auth providers via UI
4. Deploy Edge Functions via Dashboard upload
5. Optionally pull schema locally: `supabase db pull`

**Transition Strategy:**
When prototype becomes real project:
1. Run `supabase init` in project directory
2. Run `supabase link --project-ref your-project-id`
3. Run `supabase db pull` to create migration from current schema
4. Switch to CLI-first workflow going forward

## What Can Be Done via CLI (Free Tier)

### ✅ Fully Supported via CLI

**Database:**
- Schema creation and modifications (all DDL)
- Migrations creation, application, and management
- Seed data management
- RLS policy creation and updates
- Function/trigger creation
- View and materialized view management
- Schema diffing and pulling from remote
- Type generation (TypeScript, Go, Swift)

**Authentication (Local Development):**
- Email/password authentication
- OAuth provider configuration (local only)
- SMS provider configuration (local only)
- JWT settings (expiry, refresh tokens)
- Email settings (confirmation, double opt-in)
- Redirect URL configuration (local only)
- Auth hooks configuration

**Edge Functions:**
- Function creation and editing
- Local development with hot reload
- Secret/environment variable management
- Deployment to production
- Function configuration (JWT verification, etc.)
- Log viewing (via CLI)

**Developer Tools:**
- TypeScript type generation
- Project initialization
- Local Supabase stack management
- Database backups and restores (via CLI)
- Project linking
- Configuration management

### ⚠️ Requires Dashboard UI (Production)

**Authentication:**
- OAuth provider credentials (Client ID, Secret)
- OAuth provider callback URL registration
- Production redirect URL allow-list
- Custom SMTP settings
- Email template customization
- SMS provider credentials (production)

**Project Management:**
- Project creation (initial setup)
- API key viewing/regeneration
- Project pausing/resuming
- Project deletion
- Usage metrics and monitoring
- Billing and subscription management

**Optional Dashboard Features (Convenience):**
- Visual table editor
- SQL editor with autocomplete
- Auth user management UI
- Storage bucket management UI
- Realtime settings UI
- Function logs viewer
- Database performance insights

## References

### Official Documentation
- [Supabase CLI Overview](https://supabase.com/docs/guides/local-development)
- [CLI Configuration Reference](https://supabase.com/docs/guides/cli/config)
- [Database Migrations Guide](https://supabase.com/docs/guides/deployment/database-migrations)
- [Edge Functions Documentation](https://supabase.com/docs/guides/functions)
- [Authentication Configuration](https://supabase.com/docs/guides/auth)
- [CLI Reference](https://supabase.com/docs/reference/cli/introduction)
- [Generating TypeScript Types](https://supabase.com/docs/guides/api/rest/generating-types)

### Pricing and Limitations
- [Supabase Pricing](https://supabase.com/pricing)
- [Edge Function Limits](https://supabase.com/docs/guides/functions/limits)

### Community Resources
- [Supabase CLI GitHub Repository](https://github.com/supabase/cli)
- [CLI v2: Config as Code Announcement](https://supabase.com/blog/cli-v2-config-as-code)
- [config.toml Template](https://github.com/supabase/cli/blob/develop/pkg/config/templates/config.toml)

### Related Guides
- [Custom SMTP Setup](https://supabase.com/docs/guides/auth/auth-smtp)
- [Email Templates](https://supabase.com/docs/guides/auth/auth-email-templates)
- [Managing Config and Secrets](https://supabase.com/docs/guides/local-development/managing-config)
- [Declarative Database Schemas](https://supabase.com/docs/guides/local-development/declarative-database-schemas)

## Appendix

### Sample Workflow: New Project Setup

```bash
# 1. Install CLI (if not already installed)
npm install -g supabase

# 2. Initialize project
mkdir my-project && cd my-project
supabase init
git init
git add .
git commit -m "Initialize Supabase project"

# 3. Start local development
supabase start

# 4. Create initial schema
supabase migration new create_initial_schema

# Edit migration file with your schema
cat > supabase/migrations/*_create_initial_schema.sql << EOF
-- Create profiles table
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);
EOF

# 5. Apply migrations
supabase db reset

# 6. Generate types
supabase gen types typescript --local > types/database.types.ts

# 7. Configure auth (edit config.toml)
# Add your OAuth providers with env() references

# 8. Create .env file
cat > .env.local << EOF
SUPABASE_AUTH_GITHUB_CLIENT_ID=your_dev_client_id
SUPABASE_AUTH_GITHUB_SECRET=your_dev_secret
EOF

# 9. Restart to apply auth config
supabase stop && supabase start

# 10. Create Edge Function
supabase functions new hello-world

# 11. Test locally
supabase functions serve

# 12. When ready for production: Create project in Dashboard

# 13. Link to remote
supabase link --project-ref your-project-ref

# 14. Push schema to production
supabase db push

# 15. Set production secrets
supabase secrets set --env-file .env.production

# 16. Deploy functions
supabase functions deploy

# 17. Configure OAuth in Dashboard
# - Navigate to Authentication → Providers
# - Add Client IDs and Secrets
# - Set callback URLs

# 18. Configure redirect URLs in Dashboard
# - Navigate to Authentication → URL Configuration
# - Add production and development URLs

# 19. Optional: Set up custom SMTP in Dashboard
# - Navigate to Authentication → Email → SMTP Settings
```

### Common Questions

**Q: Can I use the CLI without Docker?**
A: No, the local development environment requires Docker or a compatible container runtime. However, you can still use CLI commands like `supabase gen types` and deployment commands without Docker.

**Q: Will my local changes overwrite production?**
A: Only when you explicitly run `supabase db push`. The CLI will show you a diff of changes before applying them.

**Q: Can I use multiple environments (dev, staging, prod)?**
A: Yes! The config.toml supports a `[remotes]` section for branch-specific configurations. You can link to different projects and manage them separately.

**Q: What happens to local data when I run `supabase stop`?**
A: Data persists in Docker volumes. Use `supabase db reset` to wipe and reapply migrations, or `supabase stop --backup` to preserve data.

**Q: Can I use the CLI in CI/CD pipelines?**
A: Yes! The CLI supports non-interactive mode. Common pattern:

```yaml
# GitHub Actions example
- name: Deploy migrations
  run: |
    supabase link --project-ref ${{ secrets.SUPABASE_PROJECT_ID }}
    supabase db push
  env:
    SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
```

**Q: Is the free tier sufficient for production?**
A: For small applications and MVPs, yes. Monitor your usage and upgrade when you approach limits. The 500MB database and 2M Edge Function invocations are reasonable for early-stage products.

**Q: How do I backup my free tier project?**
A: Use `supabase db dump` to create SQL backups:

```bash
supabase db dump -f backup.sql --data-only
supabase db dump -f schema.sql --schema-only
```

Free tier doesn't include Point-in-Time Recovery, so regular manual backups are important.

### Additional Notes

**Email Testing in Local Development:**
The local stack includes Mailpit (http://localhost:54324), an SMTP server that captures all emails without sending them. This is perfect for testing email flows without actually sending emails or configuring SMTP.

**Database Version Compatibility:**
Your local Postgres version (set in config.toml) should match your production version. Check production version with:
```sql
SHOW server_version;
```

**Migration Best Practices:**
- Keep migrations small and focused
- Use descriptive names: `add_user_profiles_table` not `migration1`
- Include reverse migrations for rollback capability
- Test on local before pushing to production
- Use transactions (Postgres does this automatically)

**Type Generation Frequency:**
Regenerate types whenever schema changes:
```bash
# Add to package.json scripts
"types": "supabase gen types typescript --local > types/database.types.ts"

# Run after migrations
npm run types
```

Consider adding a pre-commit hook to keep types in sync.
