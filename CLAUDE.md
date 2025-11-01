# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Later** is a flexible, offline-first task and note organizer built with Flutter. It combines tasks (TodoLists), notes, and custom lists into "Spaces" without forcing users into rigid organizational structures. The app works 100% offline, with planned cloud sync via Supabase (Phase 2).

**Current Status**: Phase 1 (Foundation & Local-First Core) is complete. Phase 2 (Supabase backend & sync) is planned but not yet implemented.

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

# Code generation (for Hive adapters)
dart run build_runner build
dart run build_runner watch     # Watch mode for development

# Code analysis and formatting
flutter analyze                 # Check for issues
dart format .                   # Format all files
dart fix --apply                # Apply automated fixes
```

## Architecture & Key Concepts

### Data Architecture

**Local-First with Hive:**
- **Hive** is used for local NoSQL storage (no SQLite)
- All data models use Hive type adapters (generated with `build_runner`)
- Type IDs: Space (2), Item/Note (1), TodoList (20), TodoItem (21), ListModel (22), ListItem (23)
- Boxes: `notes`, `todo_lists`, `lists`, `spaces`

**Repository Pattern:**
- All data access goes through repositories (`data/repositories/`)
- Repositories abstract Hive operations from UI layer
- Key repositories: `NoteRepository`, `TodoListRepository`, `ListRepository`, `SpaceRepository`

**State Management:**
- **Provider** for state management (not Riverpod, not Bloc)
- Main providers:
  - `ContentProvider` - manages all content items (notes, todos, lists)
  - `SpacesProvider` - manages spaces and active space selection
  - `ThemeProvider` - manages light/dark theme

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

**Item** (Note):
- `id`, `title`, `content`, `tags`, `spaceId`, `isFavorite`, `isArchived`
- Hive typeId: 1
- Used for freeform notes

**TodoList**:
- `id`, `name`, `description`, `spaceId`, `color`, `icon`, `items` (List<TodoItem>)
- Hive typeId: 20
- Contains TodoItems with completion tracking, due dates, priorities

**ListModel**:
- `id`, `name`, `description`, `spaceId`, `style` (enum: simple, checklist, numbered, bullet)
- Hive typeId: 22
- Flexible lists with different visual styles

**Space**:
- `id`, `name`, `icon`, `color`, `isArchived`
- Hive typeId: 2
- Top-level organizational container
- Note: Item counts are calculated dynamically, not stored (see Item Count Calculation below)

### Auto-Save Pattern

The app uses `AutoSaveMixin` (in `lib/core/mixins/auto_save_mixin.dart`) for automatic content saving:

```dart
class MyScreen extends StatefulWidget with AutoSaveMixin {
  @override
  void scheduleSave(VoidCallback callback) {
    // Debounces saves to reduce Hive writes
  }
}
```

Recently applied to note and list detail screens. When adding similar edit screens, use this mixin.

### Item Count Calculation

**Calculated Counts (Not Stored):**
- Space item counts are **calculated dynamically** from the database, not stored
- Uses `SpaceItemCountService.calculateItemCount(spaceId)` to query all content boxes
- Single source of truth: actual items in Hive boxes (`notes`, `todo_lists`, `lists`)
- Eliminates desynchronization bugs - impossible for counts to be inaccurate

**How to Get Item Counts:**
- Repository: `SpaceRepository.getItemCount(spaceId)` - returns `Future<int>`
- Provider: `SpacesProvider.getSpaceItemCount(spaceId)` - returns `Future<int>` with retry logic
- UI: Use `FutureBuilder` or pre-fetch counts on widget initialization (see `SpaceSwitcherModal` or `AppSidebar` for examples)

**Performance:**
- Query overhead is minimal (O(n) where n = items in all spaces)
- UI components pre-fetch and cache counts to prevent flicker
- Typical performance: <100ms for 10 spaces with 100 items each

**Migration:**
- Old Space model had stored `itemCount` field (removed in v2)
- Migration runs automatically on first app launch after upgrade
- Hive automatically drops unknown fields when deserializing with new adapter

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
- Mock Hive operations in tests (see `test/data/` for examples)
- Use `mockito` for mocking dependencies

## Common Development Patterns

### Adding a New Content Type

1. Create model in `lib/data/models/` with Hive annotations
2. Add type adapter registration in `HiveDatabase.initialize()`
3. Create repository in `lib/data/repositories/`
4. Add to `ContentProvider` if needed
5. Create card component in `design_system/molecules/`
6. Add detail screen in `widgets/screens/`
7. Update QuickCapture modal for type detection

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

### Hive Type IDs

**Reserved Type IDs:**
- 1: Item (Note)
- 2: Space
- 20: TodoList
- 21: TodoItem
- 22: ListModel
- 23: ListItem
- 24: ListStyle (enum)
- 25: TodoPriority (enum)

When adding new models, use IDs starting from 30+.

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

## Migration Path (Phase 2 - Not Yet Implemented)

Phase 2 will add Supabase backend for cloud sync. When implementing:
- Supabase CLI for local development and migrations
- Remote repositories will sit alongside local repositories
- Sync engine with conflict resolution (last-write-wins initially)
- Row-Level Security (RLS) policies for multi-tenant isolation
- Migration service to move local data to cloud on first sign-in

**Do not implement Phase 2 features without explicit instruction.**

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
