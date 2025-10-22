# Rename Quick Capture and Implement Explicit Save

## Objective and Scope

Rename "Quick Capture" to simply "Capture" throughout the app and replace the auto-save mechanism with explicit save functionality requiring user action to create new items. This aligns with user expectations that creating an item requires deliberate confirmation.

**Key Changes:**
- Rename all "Quick Capture" references to "Capture"
- Remove auto-save debounce timer for new items
- Add explicit save button with keyboard shortcut support
- Keep auto-save only for editing existing items (future consideration)
- Update empty state CTAs to reflect new naming

## Technical Approach and Reasoning

### Why "Capture" Instead of "Quick Capture"
The current name "Quick Capture" implies there's a separate, non-quick way to create items, which doesn't exist. The modal is the *only* way to create items, so "Capture" is more accurate and cleaner.

### Why Explicit Save for New Items
Auto-save is unexpected when creating a new item. Users expect to:
1. Type their content
2. Press a button/shortcut to confirm creation
3. See immediate feedback that the item was created

Auto-save makes sense for *editing* existing items (less risk, continuous updates expected), but for *creation*, users want explicit control.

### Implementation Strategy
1. **Rename first** - Update all class names, file names, and UI strings
2. **Add explicit save UI** - Save button in toolbar, keyboard shortcuts
3. **Remove auto-save for new items** - Keep debounce timer state for future edit mode
4. **Add creation feedback** - Success indicator after save
5. **Test edge cases** - Unsaved changes warning, keyboard shortcuts

## Implementation Phases

### Phase 1: Rename "Quick Capture" to "Capture"

- [ ] Task 1.1: Rename modal file
  - Rename `apps/later_mobile/lib/widgets/modals/quick_capture_modal.dart` to `capture_modal.dart`
  - Update class name from `QuickCaptureModal` to `CaptureModal`
  - Update state class from `_QuickCaptureModalState` to `_CaptureModalState`

- [ ] Task 1.2: Rename FAB file and class
  - Rename `apps/later_mobile/lib/widgets/components/fab/quick_capture_fab.dart` to `capture_fab.dart`
  - Update class name from `QuickCaptureFab` to `CaptureFab`
  - Update state class from `_QuickCaptureFabState` to `_CaptureFabState`

- [ ] Task 1.3: Update import statements
  - Search for all imports of `quick_capture_modal.dart` and update to `capture_modal.dart`
  - Search for all imports of `quick_capture_fab.dart` and update to `capture_fab.dart`
  - Files to update: `home_screen.dart`, test files (approx. 19 files based on grep results)

- [ ] Task 1.4: Update UI strings
  - In `capture_modal.dart`: Update semantic label from "Quick Capture" to "Capture" (line 626)
  - In `capture_modal.dart`: Update documentation header comment (lines 35-46)
  - In `empty_space_state.dart`: Update button text from "Quick Capture" to "Capture" (line 41)
  - In `empty_space_state.dart`: Update documentation comment reference (line 11, 17)
  - In `welcome_state.dart`: Update documentation comment reference (line 19)
  - Search for any other "Quick Capture" strings in UI code

- [ ] Task 1.5: Update test files
  - Rename `test/widgets/modals/quick_capture_modal_test.dart` to `capture_modal_test.dart`
  - Rename `test/widgets/components/fab/quick_capture_fab_test.dart` to `capture_fab_test.dart`
  - Rename `test/integration/quick_capture_integration_test.dart` to `capture_integration_test.dart`
  - Update all test class names and references within test files
  - Update test descriptions and strings

### Phase 2: Remove Auto-Save for New Items

- [ ] Task 2.1: Add state tracking for new vs. editing mode
  - In `capture_modal.dart` state class: Add `bool get _isNewItem => _currentItemId == null`
  - This getter will determine if we're creating new or editing existing

- [ ] Task 2.2: Disable auto-save for new items
  - In `_onTextChanged()` method (lines 185-209): Add condition `if (!_isNewItem) { ... }` around auto-save logic
  - Keep the debounce timer code structure for future edit mode support
  - Remove `_isSaving` and `_isSaved` state updates for new items
  - Keep auto-save trigger active only when `_currentItemId != null`

- [ ] Task 2.3: Keep debounce cleanup
  - Ensure `_debounceTimer?.cancel()` still happens in dispose (line 175)
  - Keep timer initialization structure for future use

### Phase 3: Add Explicit Save UI and Functionality

- [ ] Task 3.1: Add save button to toolbar
  - In `_buildToolbar()` method (lines 756-827): Add save button as rightmost element
  - Button design:
    - Primary blue gradient button when text is not empty
    - Disabled/gray state when text is empty
    - Icon: Icons.check or Icons.add_task
    - Text: "Save" or "Create" (with appropriate spacing)
    - Minimum touch target: 56px height (mobile-first)
    - Desktop: Show full button with text and icon
    - Mobile: Consider icon-only with "Save" semantic label
  - Position after space selector, with 8px spacing

- [ ] Task 3.2: Implement explicit save action
  - Create new method `_handleExplicitSave()` that:
    - Validates text is not empty (trim check)
    - Calls existing `_saveItem()` logic
    - Shows brief success indicator (green checkmark animation, 800ms)
    - Automatically closes modal after success (with 500ms delay for feedback)
  - Wire save button `onPressed` to `_handleExplicitSave()`

- [ ] Task 3.3: Update keyboard shortcuts
  - In `_handleKeyEvent()` method (lines 283-306): Update Cmd/Ctrl+Enter to call `_handleExplicitSave()` instead of immediate save + close
  - Keep Escape behavior for close with unsaved changes confirmation
  - Update auto-save indicator text to show only keyboard shortcut (remove "auto-save" language)

- [ ] Task 3.4: Add success feedback animation
  - Create `_showSuccessFeedback()` method with:
    - Set `_isSaved = true` to show green checkmark (reuse existing indicator UI)
    - Scale animation for checkmark (AppAnimations.scaleIn)
    - Short haptic feedback (HapticFeedback.mediumImpact)
    - Duration: 800ms
  - Call from `_handleExplicitSave()` after successful save
  - Auto-close modal 500ms after feedback completes

### Phase 4: Update Unsaved Changes Handling

- [ ] Task 4.1: Update close confirmation logic
  - In `_handleClose()` method (lines 318-336): Update condition for unsaved changes
  - Show confirmation dialog only if: `_textController.text.trim().isNotEmpty && _currentItemId == null`
  - Dialog text: "Discard unsaved item?" / "Your item hasn't been saved yet. Discard?"
  - Actions: "Discard" (destructive), "Cancel" (default), optional "Save & Close"

- [ ] Task 4.2: Add optional "Save & Close" to confirmation
  - In confirmation dialog: Add third action "Save & Close"
  - On "Save & Close": Call `_handleExplicitSave()` without auto-close delay, then close immediately
  - Make "Save & Close" the primary/suggested action (blue color)

### Phase 5: Update Auto-Save Indicator UI

- [ ] Task 5.1: Simplify indicator for new items
  - In `_buildAutoSaveIndicator()` method (lines 997-1086): Hide saving/saved states when `_isNewItem`
  - For new items: Show only keyboard shortcut hint
  - Text: "⌘+Enter to save • Esc to cancel" (macOS) or "Ctrl+Enter to save • Esc to cancel" (others)
  - Remove "Saving..." and "Saved" states for new items

- [ ] Task 5.2: Keep indicator for editing mode (future)
  - When `!_isNewItem`: Keep existing auto-save indicator behavior
  - Show "Saving..." with spinner during debounce
  - Show "Saved" with checkmark after successful auto-save
  - This preserves auto-save for future edit functionality

### Phase 6: Testing and Polish

- [ ] Task 6.1: Update unit tests
  - Update `capture_modal_test.dart`: Test explicit save button
  - Test save button enabled/disabled states
  - Test keyboard shortcut (Cmd/Ctrl+Enter)
  - Test unsaved changes confirmation dialog
  - Test success feedback animation

- [ ] Task 6.2: Update integration tests
  - Update `capture_integration_test.dart`: Test full create flow
  - Test: Open modal → Type text → Press save button → Verify item created
  - Test: Open modal → Type text → Press Cmd/Ctrl+Enter → Verify item created
  - Test: Open modal → Type text → Press Esc → Confirm discard → Verify no item created
  - Test: Open modal → Type text → Press Esc → Save & close → Verify item created

- [ ] Task 6.3: Accessibility testing
  - Update `semantic_labels_test.dart`: Verify "Capture" labels
  - Verify save button has proper semantic label
  - Test screen reader announces "Capture modal" not "Quick Capture modal"
  - Verify keyboard navigation to save button (Tab order)

- [ ] Task 6.4: Visual polish
  - Test modal animations with new save button
  - Verify success checkmark animation timing feels right
  - Test on mobile (bottom sheet) and desktop (centered modal)
  - Verify button spacing in toolbar doesn't break layout

## Dependencies and Prerequisites

**Existing Code Dependencies:**
- `apps/later_mobile/lib/widgets/modals/quick_capture_modal.dart` (rename to `capture_modal.dart`)
- `apps/later_mobile/lib/widgets/components/fab/quick_capture_fab.dart` (rename to `capture_fab.dart`)
- `apps/later_mobile/lib/providers/items_provider.dart` (no changes needed)
- `apps/later_mobile/lib/core/theme/app_animations.dart` (use existing animations)
- `apps/later_mobile/lib/core/theme/app_colors.dart` (use existing colors)

**External Dependencies:**
- No new packages required
- Uses existing Flutter material design components
- Uses existing uuid package for ID generation

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
- Full button with text on desktop
- Existing responsive layout patterns handle this well
- Current toolbar has spacer between left and right groups

### 5. Test Coverage
**Challenge:** Many test files reference "Quick Capture"
**Mitigation:**
- Systematic rename across all test files
- Use grep to find all references
- Update test descriptions to match new terminology
- Verify all tests pass after rename

### 6. Breaking Changes
**Challenge:** Renaming files and classes is a breaking change
**Consideration:**
- No external API consumers (internal app only)
- No backwards compatibility needed per guidelines
- All changes confined to mobile app codebase

### 7. Draft System (Future Consideration)
**Out of Scope:** User mentioned potential draft system for future
**Note:**
- Current implementation doesn't include drafts
- Auto-save removal actually makes future drafts easier
- Drafts could use same `_currentItemId` pattern
- Can add draft indicator in toolbar when needed

## Edge Cases to Handle

1. **Empty Text Save Attempt:** Disable save button when text is empty (trim check)
2. **Rapid Save Button Clicks:** Debounce save button to prevent duplicate items
3. **Keyboard Shortcut During Save:** Disable shortcuts while `_isSaving` is true
4. **Close During Save:** Block close action while save is in progress
5. **Space Deleted During Creation:** Existing fallback to current space handles this (lines 225-231)
6. **Type Detection Edge Cases:** Existing `ItemTypeDetector` handles this robustly
7. **Network Error (Future):** Save to local storage first, sync later (existing pattern)
8. **Modal Dismissed via Gesture:** Treat as close action, show unsaved changes dialog
