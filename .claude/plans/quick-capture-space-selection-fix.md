# Quick Capture Space Selection Fix

## Objective and Scope

Fix the space selection behavior in the quick capture modal so that:
1. Selecting a space in the dropdown creates the task in that selected space
2. The global current space does NOT change (space list remains on current space)
3. The dropdown shows the selected target space for task creation
4. This is a local, modal-only space selection that doesn't affect the main app state

## Technical Approach and Reasoning

**Current Problem:**
- Space selector calls `spacesProvider.switchSpace(spaceId)` which changes the global current space
- This affects the entire app's space context, not just the quick capture modal
- Tasks are created using `currentSpace.id` from the provider

**Solution:**
- Add local state `_selectedSpaceId` to `QuickCaptureModal`
- Initialize it with `spacesProvider.currentSpace.id` on modal open
- Update the space selector to modify local state instead of calling `switchSpace()`
- Use `_selectedSpaceId` when creating items instead of `currentSpace.id`
- Keep the dropdown UI synced with the local selection

**Why This Approach:**
- Maintains separation between modal-local state and global app state
- Minimal changes to existing codebase
- No impact on SpacesProvider or other components
- Follows existing pattern of local state management in modal

## Implementation Phases

### Phase 1: Add Local Space Selection State
- [ ] Task 1.1: Add local state variable for selected space ID
  - Add `String? _selectedSpaceId;` to `_QuickCaptureModalState` class
  - Initialize in `initState()` with `spacesProvider.currentSpace?.id`
  - This will track which space the user wants to create the task in

### Phase 2: Update Space Selector UI
- [ ] Task 2.1: Modify `_buildSpaceSelector()` to use local state
  - Find the `_buildSpaceSelector()` method in `quick_capture_modal.dart` (around lines 885-954)
  - Change the `PopupMenuButton` child to display the space matching `_selectedSpaceId` instead of `currentSpace`
  - Update logic: `final selectedSpace = spacesProvider.spaces.firstWhere((s) => s.id == _selectedSpaceId, orElse: () => currentSpace);`
  - Display `selectedSpace.icon` and `selectedSpace.name` in the UI

- [ ] Task 2.2: Update space selection callback
  - In `onSelected: (spaceId)` callback of `PopupMenuButton`
  - Remove the line: `spacesProvider.switchSpace(spaceId);`
  - Replace with: `setState(() { _selectedSpaceId = spaceId; });`
  - This updates only the local state, not the global provider state

### Phase 3: Update Task Creation Logic
- [ ] Task 3.1: Modify `_saveItem()` to use selected space ID
  - Find the `_saveItem()` method in `quick_capture_modal.dart`
  - Locate where `currentSpace.id` is used when creating a new `Item`
  - Change from: `spaceId: currentSpace.id`
  - Change to: `spaceId: _selectedSpaceId ?? currentSpace.id`
  - Add null safety check at method start: `if (_selectedSpaceId == null) return;`

### Phase 4: Testing and Edge Cases
- [ ] Task 4.1: Test normal flow
  - Open quick capture modal (verify space selector shows current space)
  - Select a different space from dropdown (verify UI updates to show new space)
  - Type and save a task (verify task created in selected space)
  - Close modal and check space list (verify current space unchanged)

- [ ] Task 4.2: Test edge cases
  - Test when there's only one space (dropdown should still work)
  - Test when selected space is deleted while modal is open (add safety check)
  - Test rapid space switching before task is saved
  - Test modal reopening after space selection (should reset to current space)

- [ ] Task 4.3: Add safety check for deleted spaces
  - In `_saveItem()`, verify `_selectedSpaceId` exists in `spacesProvider.spaces`
  - If not found, fall back to `currentSpace.id`
  - Add warning log if fallback occurs

## Dependencies and Prerequisites

**Existing Files to Modify:**
- `/Users/jonascurth/later/apps/later_mobile/lib/widgets/modals/quick_capture_modal.dart`

**Dependencies Already in Place:**
- `SpacesProvider` for reading available spaces
- `ItemsProvider` for creating items
- `Consumer<SpacesProvider>` for reactive UI updates

**No New Dependencies Required**

## Challenges and Considerations

**Challenge 1: Space Deleted While Modal Open**
- If user deletes the selected space in another window/device
- Solution: Safety check in `_saveItem()` to fall back to current space
- Alternative: Listen to space changes and reset `_selectedSpaceId` if deleted

**Challenge 2: Modal State Reset**
- Each time modal opens, should start with current space (not remember previous selection)
- Solution: Initialize `_selectedSpaceId` in `initState()`, which runs on each modal open

**Challenge 3: Visual Feedback**
- User needs clear indication that space selection is for task creation only
- Consider: Add subtle text below space selector "Task will be created in [space name]"
- Decision: Current UI is sufficient, behavior will be intuitive

**Challenge 4: Consistency with Item Updates**
- Existing items being edited should maintain their original space
- Solution: Only set `spaceId` when creating new items (`_currentItemId == null`)
- For updates, preserve existing item's `spaceId`

**Edge Case: No Spaces Available**
- If `currentSpace == null` or no spaces loaded
- Current code already handles this: `if (currentSpace == null) return const SizedBox.shrink();`
- Safety check in `_saveItem()` also prevents creation without valid space
