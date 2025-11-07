# Later: Your Life, Organized Your Way

Tired of todo apps that force you into their way of thinking? Later is different.

It's a flexible workspace where tasks, notes, and lists live together—not in separate apps. Need to jot down a movie recommendation? Create a watchlist. Planning a project? Add detailed notes right alongside your tasks. Managing work and home life? Switch between spaces instantly.

Later syncs your data seamlessly across all your devices using secure cloud storage. Sign in with your email and access your organized life from anywhere.

No subscriptions to manage productivity features you'll never use. Just a clean, intuitive app that adapts to how you actually work.

**Later: Because your to-dos shouldn't dictate how you organize your life.**

---

## Features

- **Flexible Organization**: Combine tasks, notes, and custom lists in one workspace
- **Spaces**: Organize content by context (Work, Personal, Projects, etc.)
- **Beautiful Design**: Gradient-based color system with smooth animations
- **Cloud Sync**: Your data is securely stored and synced across devices
- **Authentication**: Email/password authentication with secure data isolation

---

## Local Development Setup

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** `^3.9.2` or higher ([Install Flutter](https://flutter.dev/docs/get-started/install))
- **Supabase CLI** ([Install Supabase CLI](https://supabase.com/docs/guides/cli))
  ```bash
  brew install supabase/tap/supabase
  ```
- **Docker Desktop** (required by Supabase CLI for local PostgreSQL)

### Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd later
   ```

2. **Start Supabase local development server**
   ```bash
   supabase start
   ```

   This will start local PostgreSQL and authentication services. Note the credentials displayed:
   - **API URL**: `http://127.0.0.1:54321`
   - **Studio URL**: `http://localhost:54323` (database management UI)
   - **Anon Key**: Used for client authentication

3. **Install Flutter dependencies**
   ```bash
   cd apps/later_mobile
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

5. **Create a test account**
   - The app will launch with the Sign Up screen
   - Email confirmation is disabled in local development for easier testing
   - Create an account with any email/password (e.g., `test@example.com`)

### Supabase CLI Commands

```bash
# Start local development server
supabase start

# Stop local development server
supabase stop

# Check running services and credentials
supabase status

# Reset database and apply migrations
supabase db reset

# Create a new database migration
supabase migration new migration_name

# Access Supabase Studio (database UI)
open http://localhost:54323
```

### Development Commands

All commands should be run from the `apps/later_mobile` directory:

```bash
# Run the app
flutter run

# Run tests
flutter test                              # All tests
flutter test test/path/to/file_test.dart  # Single test file
flutter test --coverage                   # With coverage report

# Code quality
flutter analyze                           # Static analysis
dart format .                             # Format code
dart fix --apply                          # Apply automated fixes
```

### Database Migrations

Database schema changes are managed through Supabase migrations in the `supabase/migrations/` directory:

- **Initial schema**: `20251103230632_initial_schema.sql` (tables, indexes)
- **RLS policies**: `20251103230901_rls_policies.sql` (row-level security)

To apply migrations:
```bash
supabase db reset
```

---

## Architecture

### Technology Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL + Authentication)
- **State Management**: Provider pattern
- **Design System**: Atomic Design with custom theme extensions

### Data Model

- **Spaces**: Top-level organizational containers
- **Notes**: Freeform note items
- **TodoLists**: Task lists with completion tracking
- **Lists**: Custom lists (simple, checklist, numbered, bullet)

All data is isolated by user via Row-Level Security (RLS) policies.

### Key Directories

```
/
├── apps/later_mobile/          # Main Flutter application
│   ├── lib/
│   │   ├── core/               # Core utilities, theme, error handling
│   │   ├── design_system/      # Atomic Design components
│   │   ├── data/               # Models, repositories, services
│   │   ├── providers/          # State management (Provider pattern)
│   │   └── widgets/            # Feature screens and modals
│   └── test/                   # Test suite
├── supabase/
│   └── migrations/             # Database schema migrations
└── design-documentation/       # Design system documentation
```

---

## Contributing

This is a personal project, but feedback and suggestions are welcome! Please see `CLAUDE.md` for detailed development guidelines and architecture documentation.

---

## License

[License information to be added]