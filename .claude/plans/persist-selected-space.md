# Persist Selected Space Across App Restarts

## Objective and Scope

Implement persistence for the currently selected space so users return to their last active space when reopening the app. Currently, the app defaults to the first space on each restart, which disrupts user workflow.

## Technical Approach and Reasoning

**Storage Strategy**: Use SharedPreferences for storing the last selected space ID rather than Hive. While the app already uses Hive for structured data (Items, Spaces), SharedPreferences is better suited for simple key-value preferences like "last selected space ID" because:
- It's optimized for small, frequently accessed values
- It's the Flutter/Dart standard for app preferences
- It separates concerns: Hive for domain data, SharedPreferences for UI state
- It has simpler async initialization than Hive boxes

**Implementation Pattern**:
- Store space ID (not the full space object) to avoid data duplication and sync issues
- Load the persisted space ID during app initialization
- Validate the space still exists before selecting it (handles deleted spaces)
- Fall back to first space if persisted space is invalid

## Implementation Phases

### Phase 1: Add SharedPreferences Dependency ✅
- [x] Task 1.1: Add shared_preferences package to pubspec.yaml
  - Open `apps/later_mobile/pubspec.yaml`
  - Add `shared_preferences: ^2.2.2` to the dependencies section
  - Run `flutter pub get` to install the dependency
  - **Status**: Completed - dependency was already present and installed successfully

### Phase 2: Create Preferences Service ✅
- [x] Task 2.1: Create preferences service for managing app-wide settings
  - Create new file `apps/later_mobile/lib/data/local/preferences_service.dart`
  - Implement singleton pattern similar to HiveDatabase
  - Add `initialize()` method that loads SharedPreferences instance
  - Add `getLastSelectedSpaceId()` method that returns `String?`
  - Add `setLastSelectedSpaceId(String spaceId)` method that saves the space ID
  - Add `clearLastSelectedSpaceId()` method for cleanup/reset scenarios
  - Add proper error handling for all preference operations
  - **Status**: Completed - PreferencesService created with full test coverage (37 passing tests)

### Phase 3: Initialize Preferences in App Startup ✅
- [x] Task 3.1: Add preferences initialization to main.dart
  - Import the new PreferencesService in `apps/later_mobile/lib/main.dart`
  - Call `await PreferencesService.initialize()` in `main()` function after HiveDatabase initialization
  - Ensure initialization happens before `runApp()` is called
  - **Status**: Completed - PreferencesService initialized in main.dart after HiveDatabase
  - **Bonus**: Migrated existing ThemeProvider to use PreferencesService instead of SharedPreferences directly, improving consistency

### Phase 4: Update SpacesProvider to Persist Selection ✅
- [x] Task 4.1: Modify switchSpace method to persist the selection
  - Import PreferencesService in `apps/later_mobile/lib/providers/spaces_provider.dart`
  - In `switchSpace()` method, after successfully setting `_currentSpace`, call `await PreferencesService().setLastSelectedSpaceId(spaceId)`
  - Add error handling to ensure preference save failures don't break space switching
  - **Status**: Completed - switchSpace now persists selection with proper error handling
  - **Test Coverage**: Added tests for successful persistence and failure scenarios

- [x] Task 4.2: Modify addSpace method to persist new space selection
  - In `addSpace()` method, after setting `_currentSpace = createdSpace`, call `await PreferencesService().setLastSelectedSpaceId(createdSpace.id)`
  - This ensures newly created spaces are persisted as the current selection
  - **Status**: Completed - addSpace now persists new spaces as the current selection
  - **Test Coverage**: Added tests for successful persistence and failure scenarios

### Phase 5: Restore Last Selected Space on App Start ✅
- [x] Task 5.1: Update loadSpaces to restore persisted space selection
  - In `loadSpaces()` method in SpacesProvider, before the default "first space" logic
  - Call `final lastSpaceId = PreferencesService().getLastSelectedSpaceId()`
  - If `lastSpaceId` is not null, search for the space in `_spaces` list
  - If found, set `_currentSpace` to that space
  - If not found (space was deleted), fall back to first space and clear the persisted ID
  - Keep existing fallback logic: if no persisted space and `_currentSpace == null`, use first space
  - **Status**: Completed - loadSpaces now restores persisted space selection with proper fallback handling
  - **Test Coverage**: Added 5 comprehensive tests covering all restoration scenarios:
    - Restoring valid persisted space
    - Falling back when persisted space doesn't exist
    - Clearing stale persisted space ID
    - Prioritizing persisted space over first space
    - Handling null persisted space ID gracefully

### Phase 6: Handle Edge Cases ✅
- [x] Task 6.1: Handle space deletion cleanup
  - In `deleteSpace()` method in SpacesProvider, check if the deleted space ID matches the persisted space ID
  - If it matches, call `await PreferencesService().clearLastSelectedSpaceId()` to clear stale preference
  - This prevents attempting to restore a deleted space on next app start
  - **Status**: Completed - deleteSpace now clears persisted space ID when deleting a persisted space
  - **Test Coverage**: Added 2 tests covering deletion of persisted and non-persisted spaces

- [x] Task 6.2: Handle space archival
  - In `updateSpace()` method, check if the updated space is being archived AND is the current space
  - If both conditions are true, optionally clear the persisted space ID or let it restore (design decision needed)
  - Document the chosen behavior in code comments
  - **Status**: Completed - updateSpace documentation updated with archival behavior
  - **Design Decision**: Chose Option B - Keep persisted space ID when archiving (allows archived spaces to be restored)
  - **Test Coverage**: Added 2 tests covering archival of current and non-current spaces

### Phase 7: Testing
- [ ] Task 7.1: Add unit tests for PreferencesService
  - Create test file `apps/later_mobile/test/data/local/preferences_service_test.dart`
  - Mock SharedPreferences using the standard Flutter test approach
  - Test successful save and retrieval of space ID
  - Test handling of null values (no preference set yet)
  - Test error scenarios

- [ ] Task 7.2: Add unit tests for SpacesProvider persistence behavior
  - Update `apps/later_mobile/test/providers/spaces_provider_test.dart`
  - Test that `switchSpace()` persists the selection
  - Test that `loadSpaces()` restores the persisted space
  - Test fallback behavior when persisted space doesn't exist
  - Test that `deleteSpace()` clears persisted ID when appropriate
  - Mock PreferencesService in tests

- [ ] Task 7.3: Manual testing scenarios
  - Test normal case: select a space, restart app, verify correct space is selected
  - Test deleted space: select a space, delete it via another device/session, restart app, verify fallback to first space
  - Test first run: fresh install with no persisted space, verify first space is selected
  - Test space archival: archive current space, restart app, verify behavior

## Dependencies and Prerequisites

- **shared_preferences package**: Latest stable version (^2.2.2)
- **Existing architecture**: Works with current SpacesProvider and repository pattern
- **Initialization order**: Must initialize PreferencesService after WidgetsFlutterBinding but before runApp()

## Challenges and Considerations

**Challenge 1: Async initialization complexity**
- SharedPreferences requires async initialization
- Must ensure preferences are loaded before first space selection attempt
- Solution: Initialize in main() before runApp(), similar to Hive initialization

**Challenge 2: Deleted space handling**
- User might delete the persisted space from another device (future sync scenario)
- Solution: Validate space exists in loadSpaces(), clear preference if not found

**Challenge 3: Race conditions**
- Multiple simultaneous space switches could cause inconsistent persisted state
- Solution: SharedPreferences operations are atomic, last write wins (acceptable for this use case)

**Challenge 4: Migration from current behavior**
- Existing users have no persisted preference
- Solution: First space fallback handles this gracefully, no migration needed

**Challenge 5: Testing complexity**
- Mocking SharedPreferences requires special setup
- Solution: Use Flutter's standard SharedPreferences.setMockInitialValues() for testing

**Design Decision Needed**: When archiving the current space, should we:
- A) Clear the persisted space ID (user must select new space on next start)
- B) Keep the persisted space ID (archived space can be restored)
- Recommendation: Option B for consistency, but worth discussing with user
