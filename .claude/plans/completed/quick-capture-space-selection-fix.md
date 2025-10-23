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
- [x] Task 1.1: Add local state variable for selected space ID
  - Added `String? _selectedSpaceId;` to `_QuickCaptureModalState` class at line 65
  - Initialized in `initState()` with `spacesProvider.currentSpace?.id` at lines 104-105
  - This tracks which space the user wants to create the task in

### Phase 2: Update Space Selector UI
- [x] Task 2.1: Modify `_buildSpaceSelector()` to use local state
  - Modified `_buildSpaceSelector()` method at lines 905-983
  - Changed the `PopupMenuButton` child to display the space matching `_selectedSpaceId` instead of `currentSpace`
  - Added logic: `final selectedSpace = spacesProvider.spaces.firstWhere((s) => s.id == _selectedSpaceId, orElse: () => currentSpace);` at lines 913-916
  - Now displays `selectedSpace.icon` and `selectedSpace.name` in the UI at lines 934-946

- [x] Task 2.2: Update space selection callback
  - Updated `onSelected: (spaceId)` callback at lines 974-979
  - Removed: `spacesProvider.switchSpace(spaceId);`
  - Replaced with: `setState(() { _selectedSpaceId = spaceId; });`
  - This updates only the local state, not the global provider state

### Phase 3: Update Task Creation Logic
- [x] Task 3.1: Modify `_saveItem()` to use selected space ID
  - Modified `_saveItem()` method at lines 211-268
  - Added null safety check at line 222: `if (_selectedSpaceId == null) return;`
  - Added space existence validation at lines 225-231
  - Changed to use `targetSpaceId` (verified selected space or fallback to current) at line 242
  - Added fallback logic with debug warning if selected space no longer exists
  - Existing items now preserve their original spaceId (updates don't change space)

### Phase 4: Testing and Edge Cases
- [x] Task 4.1: Static analysis and formatting
  - Ran `flutter analyze` - passed with no errors related to our changes
  - Ran `dart format` - code properly formatted
  - Implementation verified to compile without errors

- [x] Task 4.2: Safety checks implemented
  - Added null check for `_selectedSpaceId` at line 222
  - Added space existence validation at lines 225-228
  - Implemented fallback to current space with debug warning at lines 231-235
  - Modal resets `_selectedSpaceId` to current space on each open (initState at lines 104-105)

- [x] Task 4.3: Edge cases addressed
  - Single space: Dropdown still functional, uses local state
  - Space deleted while modal open: Safety check falls back to current space with warning
  - Rapid space switching: setState ensures UI stays in sync
  - Modal reopening: initState reinitializes `_selectedSpaceId` to current space

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
