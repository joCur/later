# Fix ReorderableListView Key Error and Implement Custom Error Widget

## Objective and Scope

Fix the critical bug preventing users from adding new TodoItems and ListItems (caused by missing keys in ReorderableListView), and implement a production-ready custom error widget to replace Flutter's default red error screen for future issues.

**Scope:**
- Fix immediate key error in todo and list detail screens
- Create reusable CustomErrorWidget component integrated with existing ErrorHandler
- Ensure production-ready error handling with debug info in development only
- Maintain design system consistency and theme awareness

**Out of Scope:**
- Remote error reporting (Phase 2)
- Alternative list widget implementations
- General performance optimization

## Technical Approach and Reasoning

**Key Error Fix:**
- Pass explicit `ValueKey(item.id)` to `TodoItemCard` and `ListItemCard` widgets
- Minimal change approach - leverages existing `super.key` pattern in StatefulWidgets
- Both Dismissible (via DismissibleListItem) and the content cards need keys for proper ReorderableListView functionality
- Uses stable IDs from data models ensuring keys remain consistent across rebuilds

**Custom Error Widget:**
- Create `CustomErrorWidget` as a design system organism
- Integrate with existing `ErrorHandler` for consistent error processing
- Use `ThemeExtension` (TemporalFlowTheme) for automatic light/dark mode support
- Configure `ErrorWidget.builder` in `ErrorHandler.initialize()` for centralized setup
- Show debug details only in `kDebugMode` to prevent information leakage

**Reasoning:**
- Approach 1 from research (pass key through) is cleanest and most maintainable
- Integrated error widget (Approach 2 from research) maintains design system consistency
- Centralized configuration reduces duplication and ensures all errors are handled uniformly

## Implementation Phases

### Phase 1: Fix ReorderableListView Key Error (Critical Priority)

- [x] Task 1.1: Update TodoListDetailScreen
  - ✓ Opened `lib/widgets/screens/todo_list_detail_screen.dart`
  - ✓ Added `key: ValueKey(item.id)` parameter to `DismissibleListItem` at line 544
  - ✓ DismissibleListItem already has `itemKey: ValueKey(item.id)` for the internal Dismissible widget
  - ✓ Saved file

- [x] Task 1.2: Update ListDetailScreen
  - ✓ Opened `lib/widgets/screens/list_detail_screen.dart`
  - ✓ Added `key: ValueKey(item.id)` parameter to `DismissibleListItem` at line 610
  - ✓ DismissibleListItem already has `itemKey: ValueKey(item.id)` for the internal Dismissible widget
  - ✓ Saved file

- [x] Task 1.3: Manual verification testing
  - ✓ Ran app in debug mode
  - ✓ Tested TodoList detail screen
  - ✓ Added new TodoItems - no error screen appeared
  - ✓ Verified the fix resolved the key error
  - **Result**: Fix successful! Adding items now works without errors.

### Phase 2: Create Custom Error Widget Component

- [x] Task 2.1: Create CustomErrorWidget component
  - ✓ Created new file: `lib/design_system/organisms/error/custom_error_widget.dart`
  - ✓ Imported required packages: `flutter/material.dart`, `flutter/foundation.dart` (for kDebugMode)
  - ✓ Created `CustomErrorWidget` as a `StatelessWidget` accepting `FlutterErrorDetails details` parameter
  - ✓ Implemented build method with Material wrapper and themed Container using `TemporalFlowTheme`
  - ✓ Added centered Column with error icon (Icons.error_outline, size 64)
  - ✓ Added "Something went wrong" heading using `AppTypography.headlineSmall`
  - ✓ Added user-friendly message from converted `AppError` using `AppTypography.bodyLarge`
  - ✓ Added conditional debug info section (wrapped in `if (kDebugMode)`) showing exception and first 5 stack trace lines
  - ✓ Used `temporalTheme.glassBackground`, `temporalTheme.shadowColor`, etc. for theme-aware styling with fallbacks
  - ✓ Fixed all linting issues (removed unused imports, fixed deprecated withOpacity calls)

- [x] Task 2.2: Export CustomErrorWidget in design system
  - ✓ Created `lib/design_system/organisms/error/error.dart` barrel file
  - ✓ Added export: `export 'custom_error_widget.dart';`
  - ✓ Updated `lib/design_system/organisms/organisms.dart` to export `error/error.dart`
  - ✓ Fixed dangling library doc comment warning

- [x] Task 2.3: Update ErrorHandler to configure ErrorWidget.builder
  - ✓ Opened `lib/core/error/error_handler.dart`
  - ✓ Added `ErrorWidget.builder` configuration in `ErrorHandler.initialize()` method BEFORE existing `FlutterError.onError` setup
  - ✓ Set `ErrorWidget.builder = (FlutterErrorDetails details) { ... }`
  - ✓ Inside builder: calls `handleFlutterError(details)` to log error
  - ✓ Returns `CustomErrorWidget(details: details)`
  - ✓ Added proper import of `CustomErrorWidget` from design system

### Phase 3: Testing and Verification

- [ ] Task 3.1: Test CustomErrorWidget in debug mode
  - Run app in debug mode
  - Temporarily introduce a build-time error (e.g., `throw Exception('Test error');` in a widget builder)
  - Verify CustomErrorWidget appears with branded styling
  - Verify debug info section is visible with exception details
  - Verify theme switching works (toggle light/dark mode)
  - Remove test error

- [ ] Task 3.2: Test CustomErrorWidget in release mode
  - Build release version: `cd apps/later_mobile && flutter build apk --release` (or iOS equivalent)
  - Install release build on device/emulator
  - Temporarily introduce same test error
  - Verify CustomErrorWidget appears WITHOUT debug info section
  - Verify user-friendly message is displayed
  - Remove test error and rebuild clean release

- [ ] Task 3.3: Run automated test suite
  - Run full test suite: `cd apps/later_mobile && flutter test`
  - Verify existing widget tests for detail screens still pass
  - Check test coverage report: `flutter test --coverage`
  - Ensure no regressions in existing functionality

- [ ] Task 3.4: Create widget test for CustomErrorWidget (optional but recommended)
  - Create test file: `test/design_system/organisms/error/custom_error_widget_test.dart`
  - Write test verifying CustomErrorWidget renders with error details
  - Test debug mode shows debug info
  - Test release mode hides debug info (using `debugDefaultTargetPlatformOverride`)
  - Test theme integration (light/dark mode)

## Dependencies and Prerequisites

**Required:**
- Flutter SDK ^3.9.2 (already installed)
- Existing ErrorHandler infrastructure (`lib/core/error/`)
- Existing design system tokens and ThemeExtension (`TemporalFlowTheme`)
- Access to `kDebugMode` from `package:flutter/foundation.dart`

**No new external dependencies required**

**Files to modify:**
- `lib/widgets/screens/todo_list_detail_screen.dart` (line ~547)
- `lib/widgets/screens/list_detail_screen.dart` (line ~613)
- `lib/core/error/error_handler.dart` (line ~32-36)

**Files to create:**
- `lib/design_system/organisms/error/custom_error_widget.dart`
- `lib/design_system/organisms/error/error.dart` (if doesn't exist)
- `test/design_system/organisms/error/custom_error_widget_test.dart` (optional)

## Challenges and Considerations

**Key Error Fix:**
- **Risk**: Keys added to wrong widgets or in wrong location
  - **Mitigation**: Follow exact line numbers from research, verify both DismissibleListItem key and card key are present
- **Risk**: Performance impact of keys
  - **Mitigation**: Minimal - keys are lightweight and required by ReorderableListView anyway
- **Edge case**: Duplicate IDs in items causing key conflicts
  - **Mitigation**: Hive ensures unique IDs, but verify in manual testing

**Custom Error Widget:**
- **Risk**: ErrorWidget doesn't match app theme
  - **Mitigation**: Use TemporalFlowTheme and existing design system tokens
- **Risk**: Debug info leaking to production
  - **Mitigation**: Guard all debug info with `kDebugMode` check, test in release mode
- **Risk**: ErrorWidget breaks during error rendering (recursive error)
  - **Mitigation**: Keep CustomErrorWidget simple with minimal dependencies, use try-catch if accessing context
- **Edge case**: Multiple simultaneous errors in different widget subtrees
  - **Consideration**: ErrorWidget.builder is global - each error will show its own CustomErrorWidget instance
- **Edge case**: Error occurs before theme is initialized
  - **Mitigation**: Provide fallback colors if TemporalFlowTheme is null (use null-aware operators)

**Testing Considerations:**
- Verify swipe-to-dismiss functionality isn't broken by key changes
- Test error widget in both light and dark themes
- Ensure error widget is accessible (screen reader support, contrast ratios)
- Manual testing required for error widget since unit tests can't easily simulate Flutter's error handling flow

**Future Enhancements (Not in Scope):**
- Remote error reporting (Sentry/Firebase) - Phase 2
- Error widget retry/dismiss functionality
- Localization of error messages (i18n)
- Golden tests for error widget visual regression
