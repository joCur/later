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
│   │   ├── data/               # Data layer (models, repositories, local storage)
│   │   ├── providers/          # State management (Provider pattern)
│   │   └── widgets/            # Feature screens and modals
│   └── test/                   # Comprehensive test suite (200+ tests, >70% coverage)
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
supabase db reset               # Reset database and apply migrations

# Code analysis and formatting
flutter analyze                 # Check for issues
dart format .                   # Format all files
dart fix --apply                # Apply automated fixes
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
- `AuthService` (`data/services/auth_service.dart`) - Handles Supabase Auth operations
- `AuthProvider` - State management for authentication state
- `AuthGate` widget - Routes between auth screens and main app based on auth state
- All repositories automatically filter data by `user_id` from current auth session

**State Management:**
- **Provider** for state management (not Riverpod, not Bloc)
- Main providers:
  - `AuthProvider` - manages authentication state and auth operations
  - `ContentProvider` - manages all content items (notes, todos, lists) with caching
  - `SpacesProvider` - manages spaces and active space selection
  - `ThemeProvider` - manages light/dark theme
- Providers handle loading states, error states, and async operations

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
- Note: Test suite is currently undergoing migration from Hive to Supabase

## Common Development Patterns

### Adding a New Content Type

1. Create database migration in `supabase/migrations/` with table schema
2. Create model in `lib/data/models/` with JSON serialization (`fromJson`, `toJson`)
3. Create repository in `lib/data/repositories/` extending `BaseRepository`
4. Add to `ContentProvider` if needed with proper caching
5. Create card component in `design_system/molecules/`
6. Add detail screen in `widgets/screens/`
7. Update QuickCapture modal for type detection
8. Add RLS policies to secure data access by user_id

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
- Apply migrations: `supabase db reset`
- Create new migration: `supabase migration new migration_name`

## Documentation References

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
