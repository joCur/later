# Item Space Move Bug Fix

## Objective and Scope

Fix a state synchronization bug where items remain visible in their old space after being moved to another space. When a user moves an item to a different space via the item detail screen and returns to the home screen, the item should no longer appear in the old space's list.

## Technical Approach and Reasoning

**Root Cause Analysis:**
The bug occurs in `item_detail_screen.dart:182` in the `_changeSpace` method. When a user moves an item to another space:
1. The item is updated in the repository (correct)
2. The ItemsProvider's `updateItem` method updates the item in its internal `_items` list (correct)
3. However, the ItemsProvider still contains ALL items that were originally loaded for that space
4. The item with the updated `spaceId` remains in the list, so when the home screen filters by current space, it still shows items whose `spaceId` has changed

**Solution:**
When an item's `spaceId` changes, we need to remove it from the ItemsProvider's list since it no longer belongs to the current space view. We have two approaches:

1. **Option A (Recommended):** Add a check in ItemsProvider's `updateItem` to detect when `spaceId` changes and remove the item from the list
2. **Option B:** Reload items after space change (less efficient)

We'll use Option A because it's more efficient and doesn't require a full reload.

## Implementation Phases

### Phase 1: Fix ItemsProvider State Management
- [ ] Task 1.1: Modify ItemsProvider.updateItem to detect spaceId changes
  - Add logic in `items_provider.dart:222` in the `updateItem` method
  - Before updating the item in the list, check if `item.spaceId` differs from the existing item's `spaceId`
  - If the spaceId has changed, remove the item from the `_items` list instead of updating it
  - If the spaceId is the same, update the item as normal
  - Ensure `notifyListeners()` is called in both cases

- [ ] Task 1.2: Add method to remove item from current view
  - Create a helper method `removeItem(String id)` in ItemsProvider
  - This method removes an item from the local `_items` list without deleting from repository
  - Call `notifyListeners()` after removal
  - This provides a clear API for removing items from the current view

### Phase 2: Update Home Screen to Handle Reload
- [ ] Task 2.1: Verify home screen properly reacts to provider changes
  - Review `home_screen.dart:577` where it watches ItemsProvider
  - Ensure the UI rebuilds correctly when items are removed from the list
  - No changes should be needed since it already uses `context.watch<ItemsProvider>()`

### Phase 3: Testing
- [ ] Task 3.1: Test the fix manually
  - Create an item in Space A
  - Move it to Space B via the item detail screen
  - Return to home screen viewing Space A
  - Verify the item is no longer visible in Space A
  - Switch to Space B and verify the item appears there

- [ ] Task 3.2: Add unit tests for the fix
  - Add test case in `items_provider_test.dart` for updating an item's spaceId
  - Verify that the item is removed from the list when spaceId changes
  - Verify that the item remains in the list when other properties change

- [ ] Task 3.3: Test edge cases
  - Test moving item and immediately switching spaces
  - Test moving item multiple times quickly
  - Test with multiple items being moved

## Dependencies and Prerequisites

- Existing ItemsProvider implementation
- Existing SpacesProvider implementation
- Current item detail screen with space changing functionality

## Challenges and Considerations

**Challenge 1: Race Conditions**
- If a user rapidly moves items and switches spaces, there could be timing issues
- The current implementation already handles this well by using `context.read()` before async operations

**Challenge 2: Multiple Views**
- If multiple screens are showing items from the same space, they all need to update
- This is handled automatically by `notifyListeners()` in the provider

**Challenge 3: Optimistic Updates**
- The current code updates local state before the async operation completes
- If the repository update fails, the local state could be inconsistent
- Consider handling errors by reverting the local state if the update fails

**Edge Cases:**
1. Moving an item while the home screen is in the background
2. Moving an item that's currently being filtered out (e.g., task filter active but moving a note)
3. Moving the last item in a space
4. Moving items in spaces that aren't currently loaded

**Design Decision:**
We're choosing to remove items from the list rather than reload because:
- More efficient (no network/storage call needed)
- Faster user experience
- Maintains scroll position and other UI state
- Consistent with how other operations (delete) work
