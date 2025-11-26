# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Later** is a flexible task and note organizer built with Flutter. It combines tasks (TodoLists), notes, and custom lists into "Spaces" without forcing users into rigid organizational structures. The app uses Supabase for cloud storage with authentication.

**Current Status**: Supabase migration complete. The app requires authentication and stores all data in the cloud via Supabase.

## Repository Structure

This is a monorepo with a single Flutter mobile app:

```
/
├── apps/later_mobile/          # Main Flutter application
│   ├── lib/
│   │   ├── core/               # Core utilities, theme, error handling
│   │   ├── design_system/      # Atomic Design components (atoms/molecules/organisms)
│   │   ├── data/               # Legacy data layer (local storage, some models)
│   │   ├── features/           # Feature-first organization (Riverpod 3.0)
│   │   │   ├── auth/           # Authentication feature
│   │   │   ├── theme/          # Theme management feature
│   │   │   ├── spaces/         # Spaces feature
│   │   │   ├── notes/          # Notes feature
│   │   │   ├── todo_lists/     # TodoLists feature
│   │   │   ├── lists/          # Custom lists feature
│   │   │   └── home/           # Home screen feature
│   │   └── widgets/            # Legacy widgets (being migrated to features)
│   └── test/                   # Comprehensive test suite (1195+ tests, >70% coverage)
├── design-documentation/       # Complete design system documentation
├── .claude/                    # Claude Code plans and research
```

## Development Commands

All commands should be run from `apps/later_mobile` directory:

```bash
cd apps/later_mobile

# Get dependencies
flutter pub get

# Run the app (development)
flutter run

# Run tests
flutter test                    # Run all tests
flutter test test/path/to/file_test.dart  # Run single test file
flutter test --coverage         # Generate coverage report

# Supabase local development
supabase start                  # Start local Supabase dev server
supabase stop                   # Stop local dev server
supabase status                 # Check running services and credentials
supabase db migrate             # Applies all new migrations to the database
supabase db reset               # Reset database, should never be used to apply new migrations

# Code analysis and formatting
flutter analyze                 # Check for issues
dart format .                   # Format all files
dart fix --apply                # Apply automated fixes

# Riverpod code generation (for @riverpod annotated providers)
dart run build_runner watch --delete-conflicting-outputs  # Auto-generate on file changes
dart run build_runner build --delete-conflicting-outputs  # One-time build
dart run build_runner clean                                # Clean generated files
```

## Architecture & Key Concepts

### Data Architecture

**Supabase Cloud Storage:**
- **Supabase** (PostgreSQL) is used for cloud storage with authentication
- All data is stored in PostgreSQL tables with Row-Level Security (RLS) policies
- Tables: `spaces`, `notes`, `todo_lists`, `todo_items`, `lists`, `list_items`
- Authentication: Email/password via Supabase Auth
- Local development uses Supabase CLI with Docker-based local PostgreSQL

**Repository Pattern:**
- All data access goes through repositories (`data/repositories/`)
- Repositories extend `BaseRepository` which provides Supabase client access
- Repositories handle async operations with proper error handling
- Key repositories: `NoteRepository`, `TodoListRepository`, `ListRepository`, `SpaceRepository`

**Authentication:**
- `AuthService` (`features/auth/data/services/auth_service.dart`) - Handles Supabase Auth operations
- `AuthApplicationService` (`features/auth/application/`) - Business logic layer for authentication
- `authStreamProvider` (`features/auth/application/providers.dart`) - Stream-based provider exposing current user (Stream<User?>)
- `AuthController` (`features/auth/presentation/controllers/`) - Stateless controller for auth operations (sign-in, sign-up, sign-out)
- All repositories automatically filter data by `user_id` from current auth session
- Authentication routing handled by go_router redirect guards (see Routing section below)

**Authentication Error Handling Pattern:**
- Auth screens (SignInScreen, SignUpScreen) use `ref.listen` to intercept error states inline
- When auth operations fail:
  1. Error is caught in `ref.listen` callback
  2. Error is displayed inline via `ErrorHandler.showErrorSnackBar()`
  3. User stays on auth screen (no navigation to error page)
- Controllers throw errors which are caught by UI components for inline display
- This pattern provides better UX than full-page error screens for auth failures
- Example implementation in SignInScreen:76-121

**State Management:**
- **Riverpod 3.0.3** for state management (migrated from Provider in November 2025)
- Feature-first architecture with Clean Architecture layers (Domain, Data, Application, Presentation)
- Main controllers (all use `@riverpod` code generation):
  - `authStreamProvider` - provides stream of current user (keepAlive)
  - `AuthController` - handles auth operations (stateless, auto-dispose)
  - `ThemeController` - manages light/dark theme (keepAlive)
  - `SpacesController` - manages all spaces (keepAlive)
  - `CurrentSpaceController` - manages currently selected space (keepAlive)
  - `NotesController(spaceId)` - manages notes for specific space (auto-dispose family)
  - `TodoListsController(spaceId)` - manages todo lists for specific space (auto-dispose family)
  - `ListsController(spaceId)` - manages custom lists for specific space (auto-dispose family)
  - `TodoItemsController(listId)` - manages items for specific todo list (auto-dispose family)
  - `ListItemsController(listId)` - manages items for specific list (auto-dispose family)
  - `ContentFilterController` - manages home screen filter state (auto-dispose)
- Controllers handle loading states (AsyncValue.loading/data/error), error states, and async operations
- Code generation: Run `dart run build_runner watch` during development

### Routing

The app uses **go_router** for declarative, authentication-aware navigation.

**Router Structure:**
```
lib/core/routing/
├── app_router.dart           # Router provider + route configuration
├── app_router.g.dart         # Generated Riverpod code
├── routes.dart               # Route path constants
└── go_router_refresh_stream.dart  # Stream-to-ChangeNotifier adapter
```

**Route Constants:**
All route paths are defined as constants in `lib/core/routing/routes.dart`:
- `kRouteHome` → `/` (HomeScreen)
- `kRouteSignIn` → `/auth/sign-in` (SignInScreen)
- `kRouteSignUp` → `/auth/sign-up` (SignUpScreen)
- `kRouteAccountUpgrade` → `/auth/account-upgrade` (AccountUpgradeScreen)
- `kRouteSearch` → `/search` (SearchScreen)
- Note detail: `/notes/:id` (NoteDetailScreen with noteId parameter)
- Todo detail: `/todos/:id` (TodoListDetailScreen with todoListId parameter)
- List detail: `/lists/:id` (ListDetailScreen with listId parameter)

**Authentication Guards:**
The router uses a top-level `redirect` callback that automatically:
- Redirects unauthenticated users to `/auth/sign-in` when accessing protected routes
- Redirects authenticated users to `/` when accessing auth routes
- Reacts to auth state changes via `GoRouterRefreshStream` wrapper around `authStreamProvider`

**Navigation Patterns:**
```dart
// Navigate to new route (push onto stack)
context.push('/notes/${note.id}');
context.push(kRouteSearch);

// Replace current route (no back navigation)
context.go(kRouteSignIn);

// Go back
context.pop();

// No need to manually check auth state - router handles it automatically
```

**Detail Screen Data Loading:**
Detail screens receive ID parameters from routes and fetch data via Riverpod providers:
```dart
class NoteDetailScreen extends ConsumerWidget {
  final String noteId;

  // Router passes noteId from path parameter /notes/:id
  // Screen fetches full Note object via provider
}
```

**Adding New Routes:**
1. Add route constant to `lib/core/routing/routes.dart`
2. Add route definition to `routerProvider` in `lib/core/routing/app_router.dart`
3. Use `context.push()` or `context.go()` for navigation
4. Detail screens should accept ID parameters and fetch data via providers

### Error Handling

The app uses a **centralized error code system** with localization support. All errors flow through a type-safe `ErrorCode` enum and are automatically converted to user-friendly localized messages.

**Core Components:**
- `ErrorCode` enum (`lib/core/error/error_codes.dart`) - Type-safe error codes organized by category
- `AppError` class (`lib/core/error/app_error.dart`) - Standard error object with code, message, and context
- Error mappers (`lib/core/error/mappers/`) - Convert third-party exceptions to `AppError`
- Localized messages (`lib/l10n/app_en.arb`) - User-facing error messages with i18n support

**Error Categories:**
- **Database errors**: `databaseUniqueConstraint`, `databaseTimeout`, `databasePermissionDenied`, etc.
- **Auth errors**: `authInvalidCredentials`, `authSessionExpired`, `authWeakPassword`, etc.
- **Network errors**: `networkTimeout`, `networkNoConnection`, `networkServerError`, etc.
- **Validation errors**: `validationRequired`, `validationInvalidFormat`, `validationOutOfRange`, etc.
- **Business logic errors**: `spaceNotFound`, `noteNotFound`, `insufficientPermissions`, etc.

**Error Flow:**
1. **Repository Layer**: Catch third-party exceptions (PostgrestException, AuthException) and map to AppError using error mappers
2. **Service Layer**: Business logic catches AppError, may add context, passes to controller
3. **Controller Layer** (Riverpod): Catch AppError, log with ErrorLogger, store in AsyncValue.error state
4. **UI Layer**: Display localized error messages using ErrorDialog or ErrorSnackBar

**How to Handle Errors in Repositories:**

```dart
import 'package:later_mobile/core/error/error.dart';

class MyRepository extends BaseRepository {
  Future<void> myOperation() async {
    try {
      await supabase.from('table').insert({...});
    } on PostgrestException catch (e) {
      // Map database errors using SupabaseErrorMapper
      throw SupabaseErrorMapper.fromPostgrestException(e);
    } on AuthException catch (e) {
      // Map auth errors using SupabaseErrorMapper
      throw SupabaseErrorMapper.fromAuthException(e);
    } on AppError {
      // Already an AppError - just rethrow
      rethrow;
    } catch (e, stackTrace) {
      // Wrap unknown errors
      throw AppError(
        code: ErrorCode.unknownError,
        message: 'Unexpected error in myOperation: $e',
        technicalDetails: e.toString(),
      );
    }
  }
}
```

**How to Handle Errors in Controllers (Riverpod 3.0):**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:later_mobile/core/error/error.dart';

part 'my_controller.g.dart';

@riverpod
class MyController extends _$MyController {
  @override
  Future<MyData> build() async {
    // Load initial data
    final service = ref.watch(myServiceProvider);
    return service.loadData();
  }

  Future<void> performAction() async {
    // Set loading state
    state = const AsyncValue.loading();

    try {
      final service = ref.read(myServiceProvider);
      final result = await service.performAction();

      // Check if still mounted before updating (Riverpod 3.0 feature)
      if (!ref.mounted) return;

      // Update state with success
      state = AsyncValue.data(result);
    } on AppError catch (e) {
      // Log and store the error in AsyncValue.error
      ErrorLogger.logError(e, context: 'MyController.performAction');

      if (!ref.mounted) return;
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e, stackTrace) {
      // Wrap unexpected errors
      final error = AppError(
        code: ErrorCode.unknownError,
        message: 'Unexpected error in performAction: $e',
        technicalDetails: e.toString(),
      );
      ErrorLogger.logError(error, context: 'MyController.performAction');

      if (!ref.mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
```

**How to Display Errors in UI (Riverpod 3.0):**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/core/error/error_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// In a ConsumerWidget
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(myControllerProvider);

    return asyncValue.when(
      data: (data) => MyDataView(data: data),
      loading: () => CircularProgressIndicator(),
      error: (error, stackTrace) {
        // error is an AppError from controller
        final appError = error as AppError;

        // Show error UI
        return ErrorView(
          error: appError,
          onRetry: appError.isRetryable
              ? () => ref.invalidate(myControllerProvider)
              : null,
        );
      },
    );
  }
}

// Or show error dialog on error
ref.listen(myControllerProvider, (previous, next) {
  next.whenOrNull(
    error: (error, stackTrace) {
      final appError = error as AppError;
      ErrorHandler.showErrorDialog(
        context,
        appError,
        onRetry: appError.isRetryable
            ? () => ref.invalidate(myControllerProvider)
            : null,
      );
    },
  );
});

// Get localized message directly
final localizations = AppLocalizations.of(context);
final message = error.getUserMessageLocalized(localizations);
```

**Validation Errors:**

For input validation, use `ValidationErrorMapper`:

```dart
import 'package:later_mobile/core/error/error.dart';

// Required field validation
if (name.isEmpty) {
  throw ValidationErrorMapper.requiredField('Name');
}

// Invalid format validation
if (!emailRegex.hasMatch(email)) {
  throw ValidationErrorMapper.invalidFormat('Email');
}

// Out of range validation
if (age < 18 || age > 120) {
  throw ValidationErrorMapper.outOfRange('Age', '18', '120');
}

// Duplicate validation
if (existingNames.contains(name)) {
  throw ValidationErrorMapper.duplicate('Space name');
}
```

**Error Metadata:**

Each `ErrorCode` has associated metadata:
- `isRetryable`: Whether the operation can be retried (network/timeout errors are retryable)
- `severity`: Error severity level (low/medium/high/critical) for logging/monitoring
- `localizationKey`: Key for retrieving localized user message from ARB files

**Important Rules:**
1. **NEVER throw raw exceptions** - always convert to `AppError` at repository boundary
2. **NEVER create AppError without ErrorCode** - use the enum for type safety
3. **ALWAYS use error mappers** for third-party exceptions (Supabase, validation)
4. **ALWAYS log errors** with `ErrorLogger.logError()` when catching in providers
5. **NEVER show technical details to users** - use `getUserMessageLocalized()` for UI

**Adding New Error Types:**

When adding a new error code:
1. Add to `ErrorCode` enum in `error_codes.dart`
2. Add metadata logic in `ErrorCodeMetadata` extension (isRetryable, severity)
3. Add localized message to `lib/l10n/app_en.arb` (key format: `errorYourNewCode`)
4. Run `flutter pub get` to regenerate localization code
5. Write unit tests for the new error code

### Design System

**Atomic Design Structure:**
- **Tokens** (`design_system/tokens/`) - Design primitives (colors, typography, spacing)
- **Atoms** (`design_system/atoms/`) - Basic components (buttons, inputs, chips)
- **Molecules** (`design_system/molecules/`) - Composed components (cards, list tiles)
- **Organisms** (`design_system/organisms/`) - Complex components (navigation, modals)

**Key Design Principles:**
- Gradient-based color system (not flat Material colors)
- Spring-physics animations (using `flutter_animate`)
- Type-specific colors: Red-Orange (tasks), Blue-Cyan (notes), Purple-Lavender (lists)

**Import Pattern:**
All design system components can be imported via:
```dart
import 'package:later_mobile/design_system/design_system.dart';
```

### Core Models

**Note** (formerly Item):
- `id`, `title`, `content`, `tags`, `spaceId`, `userId`, `isFavorite`, `isArchived`
- Stored in `notes` table
- Used for freeform notes
- Uses JSON serialization with snake_case field names

**TodoList**:
- `id`, `name`, `description`, `spaceId`, `userId`, `color`, `icon`, `totalItemCount`, `completedItemCount`
- Stored in `todo_lists` table
- TodoItems are stored separately in `todo_items` table with `todoListId` foreign key
- Count fields are aggregate values calculated by repository from child items
- Items fetched separately on-demand (not embedded in TodoList model)

**ListModel**:
- `id`, `name`, `description`, `spaceId`, `userId`, `style` (enum: simple, checklist, numbered, bullet), `totalItemCount`, `checkedItemCount`
- Stored in `lists` table
- ListItems are stored separately in `list_items` table with `listId` foreign key
- Count fields are aggregate values calculated by repository from child items
- Items fetched separately on-demand (not embedded in ListModel)

**Space**:
- `id`, `name`, `icon`, `color`, `userId`, `isArchived`
- Stored in `spaces` table
- Top-level organizational container
- Note: Item counts are calculated dynamically by querying related tables

### Auto-Save Pattern

The app uses `AutoSaveMixin` (in `lib/core/mixins/auto_save_mixin.dart`) for automatic content saving:

```dart
class MyScreen extends StatefulWidget with AutoSaveMixin {
  @override
  void scheduleSave(VoidCallback callback) {
    // Debounces saves to reduce database writes
  }
}
```

Recently applied to note and list detail screens. When adding similar edit screens, use this mixin to reduce unnecessary database operations.

### Item Count Calculation and Caching

**Nested Item Loading:**
- TodoList and ListModel have aggregate count fields (`totalItemCount`, `completedItemCount`, etc.)
- Child items (TodoItem, ListItem) are stored in separate tables with foreign keys
- Items are fetched on-demand when detail screens open, not loaded with parent lists
- Enables efficient list views (home screen shows counts only, no expensive item queries)

**Provider Caching:**
- `ContentProvider` maintains in-memory caches for nested items:
  - `Map<String, List<TodoItem>> _todoItemsCache` - keyed by todoListId
  - `Map<String, List<ListItem>> _listItemsCache` - keyed by listId
- Cache is populated on first load via `loadTodoItemsForList()` / `loadListItemsForList()`
- Cache is invalidated when items are created/updated/deleted/reordered
- Reduces unnecessary database queries for frequently accessed lists

**Space Item Counts:**
- Space item counts are **calculated dynamically** by querying related tables
- Uses `SpaceRepository.getItemCount(spaceId)` - returns `Future<int>`
- Provider: `SpacesProvider.getSpaceItemCount(spaceId)` - returns `Future<int>` with retry logic
- UI: Use `FutureBuilder` or pre-fetch counts on widget initialization

### Localization

The app supports **English (en) and German (de)** through Flutter's ARB-based localization system.

**Files:**
- `lib/l10n/app_en.arb` - English translations (source language)
- `lib/l10n/app_de.arb` - German translations
- Auto-generated: `lib/l10n/app_localizations.dart` (regenerated on `flutter pub get`)

**Usage in Code:**
```dart
import 'package:later_mobile/l10n/app_localizations.dart';

Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return Text(l10n.buttonSignIn);  // Simple string
  return Text(l10n.errorAuthWeakPassword('8'));  // String with placeholder
}
```

**Adding New Localized Strings:**
1. Add the English string to `app_en.arb`:
   ```json
   "myNewString": "Hello World",
   "@myNewString": {
     "description": "Greeting message"
   }
   ```

2. Add the German translation to `app_de.arb`:
   ```json
   "myNewString": "Hallo Welt"
   ```

3. Run `flutter pub get` to regenerate localization code

4. Import and use in your widget:
   ```dart
   final l10n = AppLocalizations.of(context)!;
   Text(l10n.myNewString)
   ```

**Strings with Placeholders:**
```json
"welcomeMessage": "Welcome, {userName}!",
"@welcomeMessage": {
  "description": "Welcome message with username",
  "placeholders": {
    "userName": {
      "type": "String",
      "example": "John"
    }
  }
}
```

Usage: `l10n.welcomeMessage('John')`

**Naming Convention:**
- Format: `category` + `Type` + `Description`
- Examples: `buttonSignIn`, `authLabelEmail`, `errorDatabaseTimeout`, `navigationHomeTooltip`
- Categories: `button`, `auth`, `error`, `navigation`, `sidebar`, `filter`, `menu`, `note`, `todo`, `list`, `space`, `create`, `accessibility`, `search`

**Widget Tests:**
Always use the `testApp()` helper from `test_helpers.dart` which includes localization setup:
```dart
import '../test_helpers.dart';

testWidgets('my test', (tester) async {
  await tester.pumpWidget(
    testApp(
      MyWidget(),
    ),
  );
  // Tests run with English locale by default
});
```

**Locale Switching:**
- App respects device language settings
- Supported: English (default), German
- No in-app language switcher (uses system settings)

**Important Notes:**
- ALL user-facing strings must be localized (no hardcoded strings)
- Error messages use the centralized error handling system with localized messages
- German strings are typically 30-40% longer than English - test layouts with German locale
- Accessibility labels should also be localized

## Contributing and Pull Request Guidelines

This project uses **automated semantic versioning** with CI/CD deployment to Google Play Store. Understanding the PR workflow is critical for all contributions.

### Pull Request Workflow

**Important**: This project uses **squash merging** for all pull requests. Only the PR title matters for versioning - individual commit messages in feature branches can use any format.

**PR Title Format (Required):**
```
<type>(<scope>): <description>
```

**Examples:**
- `feat(notes): add full-text search for notes` → MINOR version bump (1.0.0 → 1.1.0)
- `fix(auth): resolve session timeout issue` → PATCH version bump (1.0.0 → 1.0.1)
- `feat!: migrate to new authentication system` → MAJOR version bump (1.0.0 → 2.0.0)
- `docs: update installation instructions` → No version bump

**Commit Types:**
- `feat`: New feature (MINOR bump)
- `fix`: Bug fix (PATCH bump)
- `docs`: Documentation only (no bump)
- `style`: Code formatting (no bump)
- `refactor`: Code refactoring (no bump)
- `test`: Adding/updating tests (no bump)
- `chore`: Maintenance tasks (no bump)
- `perf`: Performance improvements (no bump)
- `ci`: CI/CD changes (no bump)

**Breaking Changes:**
Add `!` after type for MAJOR version bump: `feat!: breaking change description`

**Complete Guidelines:**
See `.github/CONTRIBUTING.md` for comprehensive PR title guidelines and examples.

**PR Template:**
The repository includes a PR template (`.github/pull_request_template.md`) that automatically reminds contributors of:
- Conventional commit format requirements
- Type of change checklist
- Breaking change identification
- Testing requirements

### CI/CD Automation

**PR Checks (runs on every PR):**
- Flutter analyze (code quality)
- Flutter test (all tests must pass)
- Build APK (validation only, not deployed)

**Deployment (runs on merge to main):**
- Calculates semantic version from PR title (after squash merge)
- Updates `pubspec.yaml` automatically
- Runs tests again as safety check
- Builds signed AAB with Supabase environment variables
- Deploys to Google Play Store Internal Testing
- Creates git tag (e.g., `v1.1.0`)
- Creates GitHub Release with version notes

**Version Calculation:**
- Uses `ietf-tools/semver-action` to parse commit messages
- Follows Conventional Commits specification
- Build number is GitHub run number (always incrementing)
- Format: `MAJOR.MINOR.PATCH+BUILD_NUMBER` (e.g., `1.2.3+42`)

**Important Notes for Contributors:**
1. **ALWAYS use conventional commit format in PR titles** - this is not optional
2. Individual commits in your feature branch can use any format you prefer
3. PR title becomes the squash commit message on `main`
4. Invalid PR titles won't break the build but will cause incorrect versioning
5. All tests must pass before merge is allowed
6. After merge, deployment to Play Store is automatic

### Working on this Project

**Feature Development:**
1. Create feature branch: `git checkout -b feat/my-feature`
2. Make changes with any commit style you prefer
3. Push branch and create PR with **conventional commit format in title**
4. Wait for PR checks to pass (build + test)
5. Get approval from maintainer
6. Merge with **squash merge** (enforced in GitHub settings)
7. Deployment workflow runs automatically

**Bug Fixes:**
1. Create fix branch: `git checkout -b fix/issue-description`
2. Fix the bug and add tests
3. Create PR with title: `fix(scope): description of fix`
4. Merge triggers PATCH version bump (e.g., 1.0.0 → 1.0.1)

**Documentation Updates:**
Use `docs:` prefix in PR title - no version bump will occur.

## Code Quality Standards

### Linting Configuration

The project uses strict linting rules (see `analysis_options.yaml`):

- **Strict analyzer settings**: `strict-casts`, `strict-inference`, `strict-raw-types`
- **Single quotes** for strings: `'text'` not `"text"`
- **Const constructors** wherever possible
- **Final variables** when not reassigned
- **Trailing commas** in widget trees for better formatting
- **No print statements** - use proper logging
- **Explicit return types** on all functions

**Generated files excluded**: `*.g.dart`, `*.freezed.dart`, `*.mocks.dart`

### Testing Requirements

- Comprehensive test coverage (target >70%)
- Test structure mirrors `lib/` directory
- Unit tests for models, repositories, providers
- Widget tests for UI components
- Mock Supabase operations in tests using `mockito`
- Use Supabase local development server for integration tests
- Note: Test suite requires updates to work with Supabase (see plan for future test migration strategy)

### Widget Testing with test_helpers.dart

**IMPORTANT**: All widget tests must use the `testApp()` helper from `test/test_helpers.dart` to properly configure theme extensions.

The design system components (buttons, cards, etc.) require `TemporalFlowTheme` extension to be available in the theme. Without it, widgets will throw null check errors when accessing theme properties.

**Usage pattern:**
```dart
import 'package:flutter_test/flutter_test.dart';
import '../../test_helpers.dart'; // Adjust path based on test location

testWidgets('my widget test', (tester) async {
  await tester.pumpWidget(
    testApp(
      MyWidget(),
    ),
  );

  // Your test assertions...
});
```

**Available helpers:**
- `testApp(Widget child)` - MaterialApp with light theme + TemporalFlowTheme.light()
- `testAppDark(Widget child)` - MaterialApp with dark theme + TemporalFlowTheme.dark()

**Why this matters:**
- Design system components use `Theme.of(context).extension<TemporalFlowTheme>()!`
- Without the extension, tests fail with "Null check operator used on a null value"
- The helper wraps your widget in a properly configured MaterialApp + Scaffold
- Ensures consistent theme setup across all tests

**Do NOT create custom MaterialApp wrappers** in individual test files. Always use the shared helpers to prevent theme-related test failures.

## Common Development Patterns

### Adding a New Content Type

1. Create database migration in `supabase/migrations/` with table schema
2. Create model in `lib/data/models/` with JSON serialization (`fromJson`, `toJson`)
3. Create repository in `lib/data/repositories/` extending `BaseRepository`
4. Add to `ContentProvider` if needed with proper caching
5. Create card component in `design_system/molecules/`
6. Add detail screen in `widgets/screens/` (should accept ID parameter, not full object)
7. Add route constant to `lib/core/routing/routes.dart`
8. Add route definition to `lib/core/routing/app_router.dart` with path parameter (e.g., `/mytype/:id`)
9. Update QuickCapture modal for type detection
10. Add RLS policies to secure data access by user_id

### Creating Reusable Components

**Follow Atomic Design:**
- Simple elements → `design_system/atoms/`
- Composed elements → `design_system/molecules/`
- Complex features → `design_system/organisms/`

**Export pattern:**
Update the corresponding barrel file (`atoms.dart`, `molecules.dart`, etc.) to include new components.

### Widget Pattern Analysis

See `WIDGET_PATTERN_ANALYSIS.md` for identified code duplication patterns. Before creating duplicate dialogs or confirmation flows, check if a reusable component exists or should be created.

## Known Patterns & Conventions

### Naming Conventions

- **Models**: Suffix with `Model` if name might conflict (e.g., `ListModel` not `List`)
- **Providers**: Suffix with `Provider` (e.g., `ContentProvider`)
- **Repositories**: Suffix with `Repository` (e.g., `NoteRepository`)
- **Screens**: Suffix with `Screen` (e.g., `HomeScreen`)
- **Modals**: Suffix with `Modal` (e.g., `QuickCaptureModal`)

### File Organization

- One widget/class per file (unless closely related)
- File name matches main class name in snake_case
- Private classes can share file with public class
- Barrel files (`.dart` exports) at directory level

### Database Schema

**PostgreSQL Tables:**
- `spaces` - Top-level organizational containers
- `notes` - Freeform note items
- `todo_lists` - Todo list containers
- `todo_items` - Individual todo items (FK: todo_list_id)
- `lists` - Custom list containers
- `list_items` - Individual list items (FK: list_id)

**Row-Level Security (RLS):**
- All tables have RLS enabled
- Policies enforce user_id-based access control
- Users can only access their own data
- Foreign key relationships maintain referential integrity

## Design System Guidelines

### Theme Extensions

The app uses Flutter's `ThemeExtension` API for custom design tokens via `TemporalFlowTheme`. This provides automatic light/dark mode handling and smooth theme transitions.

**Accessing theme in components:**
```dart
// Get the theme extension
final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;

// Access themed properties
final gradient = temporalTheme.primaryGradient;       // Auto light/dark
final glassColor = temporalTheme.glassBackground;     // Auto light/dark
final shadow = temporalTheme.shadowColor;             // Auto light/dark
```

**Available properties:**
- `primaryGradient` - Main brand gradient (indigo → purple)
- `secondaryGradient` - Secondary brand gradient (amber → pink)
- `taskGradient` - Task-specific gradient (red → orange)
- `noteGradient` - Note-specific gradient (blue → cyan)
- `listGradient` - List-specific gradient (violet)
- `glassBackground` - Glassmorphism background color
- `glassBorder` - Glassmorphism border color
- `taskColor`, `noteColor`, `listColor` - Type-specific accent colors
- `shadowColor` - Shadow color for elevation

**Deprecated helpers:**
The following `AppColors` helper methods are deprecated in favor of `TemporalFlowTheme`:
- ~~`AppColors.primaryGradientAdaptive(context)`~~ → Use `temporalTheme.primaryGradient`
- ~~`AppColors.glass(context)`~~ → Use `temporalTheme.glassBackground`
- ~~`AppColors.shadow(context)`~~ → Use `temporalTheme.shadowColor`

### Colors

Import tokens: `import 'package:later_mobile/design_system/design_system.dart';`

```dart
// Use semantic color names
AppColors.taskPrimary      // Red-orange gradient for tasks
AppColors.notePrimary      // Blue-cyan gradient for notes
AppColors.listPrimary      // Purple-lavender gradient for lists
AppColors.twilight         // Primary brand gradient (indigo → purple)
AppColors.textPrimary      // Theme-aware text colors
```

### Typography

```dart
// Use semantic text styles
AppTypography.displayLarge
AppTypography.headingMedium
AppTypography.bodyRegular
AppTypography.labelSmall
```

### Spacing

```dart
// Use spacing scale (4px base unit)
AppSpacing.xs    // 4px
AppSpacing.sm    // 8px
AppSpacing.md    // 16px
AppSpacing.lg    // 24px
AppSpacing.xl    // 32px
```

### Component Usage

**Buttons:**
```dart
PrimaryButton(text: 'Save', onPressed: () {})
SecondaryButton(text: 'Cancel', onPressed: () {})
GhostButton(text: 'Skip', onPressed: () {})
DangerButton(text: 'Delete', onPressed: () {})
```

**Cards:**
```dart
ItemCard(item: note)           // For notes
TodoListCard(todoList: list)   // For todo lists
ListCard(list: list)           // For custom lists
```

## Accessibility

All components must meet **WCAG 2.1 AA** standards:
- Minimum touch targets: 48×48px
- Color contrast: 4.5:1 for normal text, 3:1 for large text
- Screen reader support (semantic labels)
- Keyboard navigation where applicable
- Respect `MediaQuery.of(context).textScaleFactor`

## Performance Considerations

- Use `const` constructors wherever possible
- Wrap expensive widgets in `RepaintBoundary`
- Implement pagination for large lists (see `ContentProvider.loadMoreItems()`)
- Debounce text input with `AutoSaveMixin`
- Avoid rebuilding entire widget trees unnecessarily

## Local Development Setup

**Prerequisites:**
- Supabase CLI installed (`brew install supabase/tap/supabase`)
- Docker running (required by Supabase CLI)

**Starting Local Development:**
```bash
cd /path/to/later
supabase start          # Start local PostgreSQL + Auth services
cd apps/later_mobile
flutter run             # Run the app
```

**Accessing Services:**
- Supabase Studio (DB management): http://localhost:54323
- Local API URL: http://127.0.0.1:54321
- Email confirmation is disabled in local dev for easier testing

**Database Migrations:**
- Migrations are in `supabase/migrations/`
- Apply migrations: `supabase db migrate`
- Create new migration: `supabase migration new migration_name`

## Documentation References

- **Contributing Guidelines**: `.github/CONTRIBUTING.md` - PR title format and semantic versioning
- **PR Template**: `.github/pull_request_template.md` - Conventional commit reminder
- **CI/CD Plan**: `.claude/plans/ci-cd-play-store-automation.md` - Complete CI/CD implementation plan
- **Design System**: `design-documentation/design-system/`
- **Style Guide**: `design-documentation/design-system/style-guide.md`
- **Implementation Guide**: `design-documentation/IMPLEMENTATION-GUIDE.md`
- **MVP Roadmap**: `.claude/plans/mvp-master-plan.md`
- **Widget Patterns**: `WIDGET_PATTERN_ANALYSIS.md`
- **Linting Guide**: `apps/later_mobile/LINTING.md`

## Flutter & Dart Version

- **SDK**: `^3.9.2` (or higher)
- **Flutter Channel**: Stable recommended
- Uses Flutter 3+ features (Material 3, `flutter_animate`)

## Running MCP Tools

The Dart MCP server is available for Flutter-specific tasks:
- Use `mcp__dart__hot_reload` for live updates during development
- Use `mcp__dart__run_tests` for running tests (prefer this over `flutter test` command)
- Use `mcp__dart__analyze_files` for full project analysis
