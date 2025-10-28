# Rename "Quick Capture" to "Create" and Implement Explicit Save

## Objective and Scope

Rename the "Quick Capture" modal to "Create" modal and replace the auto-save mechanism with explicit save functionality requiring user action to create new content. The modal creates new content containers (TodoLists, Lists, and Notes), and users should have explicit control over when these are created.

**Key Changes:**
- Rename all "Quick Capture" references to "Create"
- Remove auto-save debounce timer for new content creation
- Add explicit save button with keyboard shortcut support
- Update UI strings to reflect content creation focus
- Update empty state CTAs to use "Create" terminology
- Add unsaved changes confirmation when closing with unsaved content

**Out of Scope:**
- Keep auto-save for editing existing items (future consideration when edit mode is added)
- No changes to type detection logic
- No changes to space selector functionality

## Technical Approach and Reasoning

### Why "Create" Instead of "Quick Capture"

**Current Reality:**
- Modal creates **TodoLists** (with empty items array) - lines 271-279
- Modal creates **Lists** (with empty items array) - lines 282-290
- Modal creates **Notes** (standalone content items) - lines 293-296

These are not quick, ephemeral captures—they are structured content types that users will build upon. The term "Quick Capture" implies rapid, lightweight item creation, but the modal actually creates structured content types.

**Why "Create" is Better:**
1. **Accurate**: Reflects that you're creating a new todo list, list, or note
2. **Clear Intent**: "Create Note", "Create Todo", "Create List" is self-explanatory
3. **Standard**: Matches common UX patterns (e.g., "Create New Document")
4. **No False Expectations**: Doesn't imply this is for rapid item entry

### Why Explicit Save for New Content

Auto-save is unexpected when creating new content. Users expect to:
1. Type their content
2. Press a button/shortcut to confirm creation
3. See immediate feedback that the item was created

Auto-save makes sense for *editing* existing items (less risk, continuous updates expected), but for *creation*, users want explicit control. This prevents:
- Accidental creation while typing/thinking
- Unwanted items created by the debounce timer
- Unclear feedback about when creation actually happens

### Implementation Strategy

1. **Rename first** - Update all class names, file names, and UI strings
2. **Remove auto-save for new items** - Keep debounce timer structure for future edit mode
3. **Add explicit save UI** - Save button in toolbar, keyboard shortcuts
4. **Add creation feedback** - Success indicator after save
5. **Test edge cases** - Unsaved changes warning, keyboard shortcuts

## Implementation Phases

### Phase 1: Rename Modal Files and Classes ✅ COMPLETED

- [x] Task 1.1: Rename modal file
  - Rename `apps/later_mobile/lib/widgets/modals/quick_capture_modal.dart` to `create_content_modal.dart`
  - Update class name from `QuickCaptureModal` to `CreateContentModal`
  - Update state class from `_QuickCaptureModalState` to `_CreateContentModalState`
  - Update all internal references to use new naming

- [x] Task 1.2: Update modal documentation
  - Update file header comment (lines 37-48) to describe "Create Content Modal"
  - Update class doc comment to reflect content creation purpose
  - Change "quickly capturing" to "creating" in documentation
  - Update debug print statements from "QuickCapture:" to "CreateContent:"

### Phase 2: Rename FAB Files and Classes

- [x] Task 2.1: Rename FAB file
  - Rename `apps/later_mobile/lib/design_system/molecules/fab/quick_capture_fab.dart` to `create_content_fab.dart`
  - Update class name from `QuickCaptureFab` to `CreateContentFab`
  - Update state class from `_QuickCaptureFabState` to `_CreateContentFabState`

- [x] Task 2.2: Update FAB documentation and labels
  - Update file header comment (lines 5-17) to describe "Create Content FAB"
  - Update semantic label from 'Quick Capture' to 'Create' (line 157)
  - Update hero tag default from 'quick-capture-fab' to 'create-content-fab' (line 24)
  - Update doc comments to reference "Create" instead of "Quick Capture"

### Phase 3: Update All Import Statements

- [x] Task 3.1: Update modal imports
  - Search for all imports of `quick_capture_modal.dart`
  - Update to `create_content_modal.dart`
  - Update class references from `QuickCaptureModal` to `CreateContentModal`
  - Files to update:
    - `apps/later_mobile/lib/widgets/screens/home_screen.dart` (line 23)
    - Any other screens or widgets that import the modal

- [x] Task 3.2: Update FAB imports
  - Search for all imports of `quick_capture_fab.dart`
  - Update to `create_content_fab.dart`
  - Update class references from `QuickCaptureFab` to `CreateContentFab`
  - Files to update:
    - `apps/later_mobile/lib/widgets/screens/home_screen.dart` (line 17)
    - Any other files importing the FAB

- [x] Task 3.3: Update design system barrel exports
  - Update `lib/design_system/molecules/molecules.dart` if it exports the FAB
  - Update any barrel files that export these components

### Phase 4: Update UI Strings and Semantic Labels

- [x] Task 4.1: Update modal UI strings
  - In `create_content_modal.dart`:
    - Header title: "Quick Capture" → "Create" (line 644-646)
    - Semantic label: "Quick Capture" → "Create" (line 644)
    - Update hint text if needed to reflect explicit save

- [x] Task 4.2: Update empty state strings
  - In `lib/design_system/organisms/empty_states/empty_space_state.dart`:
    - Button text: "Quick Capture" → "Create" (line 40)
    - Documentation reference: "Quick Capture button" → "Create button" (line 31)

- [x] Task 4.3: Update welcome state strings
  - In `lib/design_system/organisms/empty_states/welcome_state.dart`:
    - Search for any "Quick Capture" references and update to "Create"

- [x] Task 4.4: Search for remaining UI strings
  - Use grep to find any remaining "Quick Capture" strings in:
    - `lib/widgets/**/*.dart`
    - `lib/design_system/**/*.dart`
  - Update all user-facing strings to "Create"

### Phase 5: Remove Auto-Save for New Content ✅ COMPLETED

- [x] Task 5.1: Add state tracking for new vs. editing mode
  - In `create_content_modal.dart` state class: Add `bool get _isNewItem => _currentItemId == null`
  - This getter will determine if we're creating new or editing existing
  - **COMPLETED**: Added getter on line 70

- [x] Task 5.2: Disable auto-save for new content
  - In `_onTextChanged()` method (lines 186-228): Wrap auto-save logic in `if (!_isNewItem) { ... }`
  - Keep the debounce timer code structure for future edit mode support
  - Remove `_isSaving` and `_isSaved` state updates for new items
  - Keep auto-save trigger active only when `_currentItemId != null`
  - **COMPLETED**: Auto-save logic now only runs for existing items (lines 216-227)

- [x] Task 5.3: Keep debounce cleanup
  - Ensure `_debounceTimer?.cancel()` still happens in dispose (line 178)
  - Keep timer initialization structure for future use
  - **COMPLETED**: Verified debounce cleanup still in place at line 181

### Phase 6: Add Explicit Save UI and Functionality ✅ COMPLETED

- [x] Task 6.1: Add save button to toolbar
  - In `_buildToolbar()` method (lines 699-769): Add save button as rightmost element
  - Button design:
    - Primary gradient button when text is not empty
    - Disabled/gray state when text is empty
    - Icon: Icons.check
    - Text: "Create" (matching the modal name)
    - Minimum touch target: 48px (WCAG AA)
    - Desktop: Show full button with text and icon
    - Mobile: Icon-only with "Create" semantic label
  - Position after space selector, with 8px spacing
  - **COMPLETED**: Added `_buildSaveButton()` method (lines 771-826) with responsive mobile/desktop layouts

- [x] Task 6.2: Implement explicit save action
  - Create new method `_handleExplicitSave()` that:
    - Validates text is not empty (trim check)
    - Calls existing `_saveItem()` logic
    - Shows brief success indicator (green checkmark animation, 800ms)
    - Automatically closes modal after success (with 500ms delay for feedback)
  - Wire save button `onPressed` to `_handleExplicitSave()`
  - **COMPLETED**: Implemented `_handleExplicitSave()` (lines 337-362) with validation, save, and auto-close

- [x] Task 6.3: Update keyboard shortcuts
  - In `_handleKeyEvent()` method (lines 376-397): Update Cmd/Ctrl+Enter to call `_handleExplicitSave()` instead of immediate save + close
  - Keep Escape behavior for close with unsaved changes confirmation
  - Update keyboard shortcut hint text to show "⌘/Ctrl+Enter to create"
  - **COMPLETED**: Updated keyboard handler and hint text (lines 1048-1049, 1052)

- [x] Task 6.4: Add success feedback animation
  - Create `_showSuccessFeedback()` method with:
    - Set `_isSaved = true` to show green checkmark (reuse existing indicator UI)
    - Short haptic feedback (HapticFeedback.mediumImpact)
    - Duration: 800ms
  - Call from `_handleExplicitSave()` after successful save
  - Auto-close modal 500ms after feedback completes
  - **COMPLETED**: Implemented `_showSuccessFeedback()` (lines 364-374) with haptics and timing

### Phase 7: Update Unsaved Changes Handling

- [ ] Task 7.1: Update close confirmation logic
  - In `_handleClose()` method (lines 365-383): Update condition for unsaved changes
  - Show confirmation dialog only if: `_textController.text.trim().isNotEmpty && _currentItemId == null`
  - Dialog text: "Discard unsaved content?" / "You haven't created this item yet. Discard?"
  - Actions: "Discard" (destructive), "Cancel" (default), "Create & Close"

- [ ] Task 7.2: Add "Create & Close" to confirmation
  - In confirmation dialog (lines 385-457): Add third action "Create & Close"
  - On "Create & Close": Call `_handleExplicitSave()` without auto-close delay, then close immediately
  - Make "Create & Close" the primary/suggested action (blue color)

### Phase 8: Update Auto-Save Indicator UI

- [ ] Task 8.1: Simplify indicator for new content
  - In `_buildAutoSaveIndicator()` method (lines 935-1021): Hide saving/saved states when `_isNewItem`
  - For new items: Show only keyboard shortcut hint
  - Text: "⌘+Enter to create • Esc to cancel" (macOS) or "Ctrl+Enter to create • Esc to cancel" (others)
  - Remove "Saving..." and "Saved" states for new items

- [ ] Task 8.2: Keep indicator for editing mode (future)
  - When `!_isNewItem`: Keep existing auto-save indicator behavior
  - Show "Saving..." with spinner during debounce
  - Show "Saved" with checkmark after successful auto-save
  - This preserves auto-save for future edit functionality

### Phase 9: Update Test Files

- [ ] Task 9.1: Rename modal test file
  - Rename `test/widgets/modals/quick_capture_modal_test.dart` to `create_content_modal_test.dart`
  - Update all imports and class references to use `CreateContentModal`
  - Update test group names and descriptions
  - Update test descriptions from "Quick Capture" to "Create"

- [ ] Task 9.2: Rename FAB test file
  - Rename `test/widgets/components/fab/quick_capture_fab_test.dart` to `create_content_fab_test.dart`
  - Update all imports and class references to use `CreateContentFab`
  - Update test group names and descriptions
  - Update test descriptions from "Quick Capture" to "Create"

- [ ] Task 9.3: Update unit tests for explicit save
  - In `create_content_modal_test.dart`: Add tests for explicit save button
  - Test save button enabled/disabled states
  - Test keyboard shortcut (Cmd/Ctrl+Enter) triggers save
  - Test unsaved changes confirmation dialog
  - Test success feedback animation
  - Test that typing doesn't auto-save

- [ ] Task 9.4: Update integration tests
  - Search for integration test files referencing "quick_capture"
  - Rename and update all references
  - Test: Open modal → Type text → Press save button → Verify item created
  - Test: Open modal → Type text → Press Cmd/Ctrl+Enter → Verify item created
  - Test: Open modal → Type text → Press Esc → Confirm discard → Verify no item created
  - Test: Open modal → Type text → Press Esc → Create & close → Verify item created

- [ ] Task 9.5: Update semantic label tests
  - In `test/widgets/accessibility/semantic_labels_test.dart` (if exists):
    - Update expected semantic labels from "Quick Capture" to "Create"
    - Verify screen reader announcements use "Create modal"
    - Verify save button has proper semantic label

### Phase 10: Update Documentation

- [ ] Task 10.1: Update CLAUDE.md references
  - Search for "Quick Capture" in `/CLAUDE.md`
  - Update references to "Create" or "Create Content Modal"
  - Update any examples showing modal usage
  - Document the explicit save behavior

- [ ] Task 10.2: Update design documentation
  - Search `design-documentation/` for "Quick Capture" references
  - Update to "Create" or "Create Content Modal"
  - Update any screenshots or diagrams if necessary

### Phase 11: Verification and Testing

- [ ] Task 11.1: Run all tests
  - Execute `flutter test` to ensure all tests pass
  - Verify no broken imports or references
  - Check that all renamed files are properly referenced

- [ ] Task 11.2: Manual verification
  - Open the app and test Create modal functionality
  - Verify header shows "Create" not "Quick Capture"
  - Verify typing doesn't auto-save
  - Verify save button appears and works
  - Verify keyboard shortcuts work (Cmd/Ctrl+Enter)
  - Verify unsaved changes dialog appears on close
  - Verify success feedback animation
  - Test on both mobile and desktop layouts

- [ ] Task 11.3: Search for any remaining references
  - Use grep/ripgrep to search entire codebase for "quick_capture" or "Quick Capture"
  - Verify no references remain except in git history
  - Update any missed references

- [ ] Task 11.4: Verify accessibility
  - Test with screen reader (if possible)
  - Verify semantic labels are correct
  - Verify keyboard navigation to save button (Tab order)
  - Verify save button meets WCAG AA standards (48px touch target, sufficient contrast)

## Dependencies and Prerequisites

**Existing Code Dependencies:**
- `apps/later_mobile/lib/widgets/modals/quick_capture_modal.dart` → `create_content_modal.dart`
- `apps/later_mobile/lib/design_system/molecules/fab/quick_capture_fab.dart` → `create_content_fab.dart`
- `apps/later_mobile/lib/core/theme/app_animations.dart` (use existing animations)
- `apps/later_mobile/lib/design_system/tokens/tokens.dart` (use existing colors and spacing)
- All screens and widgets that import these files

**No External Dependencies:**
- No new packages required
- Uses existing Flutter material design components
- Uses existing design system components (buttons, colors, animations)

**Testing Dependencies:**
- Flutter test framework (already in use)
- Existing test utilities and mocks

## Challenges and Considerations

### 1. User Behavior Change
**Challenge:** Users accustomed to auto-save might forget to press save button
**Mitigation:**
- Keep unsaved changes confirmation dialog
- Make save button prominent and primary action
- Keyboard shortcut for power users
- Success feedback reinforces save action
- Clear keyboard shortcut hints

### 2. Auto-Save for Edit Mode (Future)
**Challenge:** We're keeping auto-save structure for future edit mode, but not implementing edit mode now
**Consideration:**
- Keep `_currentItemId` tracking
- Keep `_isNewItem` getter for future expansion
- Keep debounce timer code structure
- When edit mode is added, auto-save will work automatically

### 3. State Management Complexity
**Challenge:** Managing new vs. edit mode with different save behaviors
**Mitigation:**
- Clear `_isNewItem` getter makes distinction explicit
- Conditional logic in `_onTextChanged()` is straightforward
- Existing `_saveItem()` logic already handles both cases

### 4. Button Layout on Mobile
**Challenge:** Adding save button might crowd toolbar on small screens
**Mitigation:**
- Use icon-only save button on mobile (with semantic label)
- Full button with text on desktop/tablets
- Existing responsive layout patterns handle this well
- Current toolbar has spacer between left and right groups

### 5. File Rename Git History
**Challenge:** Renaming files loses git history tracking
**Mitigation:**
- Git should auto-detect file renames if content is mostly unchanged
- Use `git mv` or `git log --follow` to track history if needed
- Document the rename in commit message

### 6. Breaking Changes
**Challenge:** Renaming classes is a breaking change
**Consideration:**
- No external API consumers (internal app only)
- No backwards compatibility needed per guidelines
- All changes confined to mobile app codebase

### 7. Test Coverage During Changes
**Challenge:** Tests may fail during intermediate steps
**Mitigation:**
- Complete file renames first (files, classes, imports)
- Then remove auto-save
- Then add explicit save UI
- Then update tests
- Run tests after each major phase to catch issues early

## Edge Cases to Handle

1. **Empty Text Save Attempt:** Disable save button when text is empty (trim check)
2. **Rapid Save Button Clicks:** Debounce save button to prevent duplicate items
3. **Keyboard Shortcut During Save:** Disable shortcuts while `_isSaving` is true
4. **Close During Save:** Block close action while save is in progress
5. **Space Deleted During Creation:** Existing fallback to current space handles this (lines 244-260)
6. **Type Detection Edge Cases:** Existing `ItemTypeDetector` handles this robustly
7. **Modal Dismissed via Gesture:** Treat as close action, show unsaved changes dialog if needed
8. **Hero Animation Tag:** Update to avoid conflicts with new naming
9. **Keyboard Navigation:** Ensure Tab order reaches save button naturally
10. **Success Animation Interruption:** Handle case where user closes during success feedback
