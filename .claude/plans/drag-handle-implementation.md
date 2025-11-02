# Drag Handle Implementation for Content Reordering

## Objective and Scope

Add explicit drag handles to content cards (TodoListCard, NoteCard, ListCard) on the HomeScreen to fix UX issues with the current full-card dragging implementation. Users are experiencing difficulty scrolling and triggering pull-to-refresh because the entire card surface captures drag gestures.

**MVP Scope:**
- Create reusable `DragHandleWidget` component following design specifications
- Integrate drag handle into all three card types (TodoListCard, NoteCard, ListCard)
- Update HomeScreen to only trigger reordering via drag handle (not entire card)
- Ensure accessibility compliance (WCAG 2.1 AA)
- Maintain existing card design aesthetic with minimal visual disruption

**Out of Scope:**
- Alternative sorting/filtering methods
- Drag-and-drop between different spaces
- Keyboard-based reordering (future enhancement)
- Desktop-specific hover optimizations

## Technical Approach and Reasoning

**Why Drag Handle (vs. Full Card Dragging):**
- **Better UX**: Clear visual affordance for reordering capability
- **Gesture separation**: Scrolling, pull-to-refresh, and reordering don't conflict
- **Discoverability**: Users immediately understand the card can be reordered
- **Mobile-first**: Optimized for thumb interaction with 48×48px touch target

**Key Design Decisions:**
- **Right-side placement**: Optimal for right-handed majority, doesn't interfere with leading icon/content
- **Vertical grip dots pattern**: Industry standard (used in iOS Settings, Android lists)
- **Type-specific gradients**: Handle color matches card border gradient for visual cohesion
- **Opacity states**: 40% default → 60% hover → 100% active (clear feedback without clutter)
- **ReorderableDragStartListener**: Only handle widget triggers drag, card tap still navigates

**Implementation Strategy:**
1. Create `DragHandleWidget` as reusable Atom component
2. Refactor cards to include handle in trailing position
3. Update HomeScreen to wrap only handle (not entire card) with `ReorderableDragStartListener`
4. Add haptic feedback and animations for interaction states
5. Test accessibility with VoiceOver/TalkBack

## Implementation Phases

### Phase 1: Create DragHandleWidget Component ✅ COMPLETED

- [x] Task 1.1: Create DragHandleWidget file and structure
  - Create `apps/later_mobile/lib/design_system/atoms/drag_handle/drag_handle_widget.dart`
  - Define StatefulWidget with required parameters: `gradient`, `semanticLabel`
  - Add optional parameters: `onDragStart`, `onDragEnd`, `size` (default 48.0)
  - Implement state management for pressed/hover states

- [x] Task 1.2: Implement visual rendering (grip dots pattern)
  - Create `_buildGripDots()` method returning 3×2 grid of circular dots
  - Each dot: 4×4px circles with 4px vertical spacing, 6px horizontal spacing
  - Total visible icon size: 20×24px (centered in 48×48px touch target)
  - Use `Container` grid with border radius for dots
  - Apply gradient shader to dots using `ShaderMask`

- [x] Task 1.3: Implement interaction states (opacity management)
  - Default state: 40% opacity (subtle, doesn't clutter)
  - Hover state (desktop): 60% opacity on mouse enter
  - Active state (pressed/dragging): 100% opacity
  - Use `AnimatedOpacity` with 200ms duration for smooth transitions
  - Wrap in `GestureDetector` to detect onTapDown/onTapUp/onTapCancel

- [x] Task 1.4: Add haptic feedback
  - Using `AppAnimations.mediumHaptic()` on drag start (onTapDown)
  - Call `onDragStart` callback if provided
  - Using `AppAnimations.lightHaptic()` on drag end (onTapUp/onTapCancel)
  - Call `onDragEnd` callback if provided

- [x] Task 1.5: Implement accessibility features
  - Wrap in `Semantics` widget with:
    - `label`: Use provided `semanticLabel` parameter (e.g., "Reorder Shopping List")
    - `hint`: "Double tap and hold to reorder"
    - `button`: true (treat as interactive element)
  - Add `ExcludeSemantics` to decorative grip dots (only semantic label matters)
  - Ensure 48×48px minimum touch target using `SizedBox` wrapper
  - Add `Tooltip` for desktop hover hint

- [x] Task 1.6: Support reduced motion accessibility
  - Check `AppAnimations.prefersReducedMotion(context)`
  - If true, skip opacity animation transitions (instant state changes)
  - Maintain haptic feedback regardless of motion preference

- [x] Task 1.7: Export component in design system
  - Create `apps/later_mobile/lib/design_system/atoms/drag_handle/drag_handle.dart` barrel file
  - Export `DragHandleWidget`
  - Update `apps/later_mobile/lib/design_system/atoms/atoms.dart` to include drag_handle
  - Verified with `flutter analyze` - No issues found

### Phase 2: Integrate Drag Handle into TodoListCard ✅ COMPLETED

- [x] Task 2.1: Add drag handle to TodoListCard layout
  - Opened `apps/later_mobile/lib/design_system/organisms/cards/todo_list_card.dart`
  - Located the main card `Row` widget (contains leading icon, title, metadata)
  - Added `DragHandleWidget` as trailing widget in the Row
  - Passed `gradient: AppColors.taskGradient` (red-orange)
  - Passed `semanticLabel: 'Reorder ${widget.todoList.name}'`
  - Added `const SizedBox(width: AppSpacing.xs)` spacing before handle

- [x] Task 2.2: Update card layout constraints
  - Title/content column already wrapped with `Expanded` to prevent overflow
  - Verified card padding accommodates handle (20px padding is sufficient)
  - Long titles already properly truncate with ellipsis (AppTypography.itemTitleMaxLines)

- [x] Task 2.3: Handle interaction state coordination
  - Added `_isDragging` state variable to TodoListCard
  - Passed `onDragStart: () => setState(() => _isDragging = true)` to DragHandleWidget
  - Passed `onDragEnd: () => setState(() => _isDragging = false)` to DragHandleWidget
  - Disabled card press animation when `_isDragging == true` in `_handleTapDown` method

- [x] Task 2.4: Test TodoListCard with drag handle
  - Code compiled successfully with `flutter analyze` (no issues)
  - Drag handle successfully integrated into TodoListCard layout
  - Visual testing pending (app running on macOS for verification)

### Phase 3: Integrate Drag Handle into NoteCard and ListCard

- [ ] Task 3.1: Add drag handle to NoteCard
  - Open `apps/later_mobile/lib/design_system/organisms/cards/note_card.dart`
  - Add `DragHandleWidget` to card layout (same pattern as TodoListCard)
  - Pass `gradient: AppColors.noteGradient` (blue-cyan)
  - Pass `semanticLabel: 'Reorder ${widget.item.title}'`
  - Add `_isDragging` state management
  - Test rendering, interaction, and accessibility

- [ ] Task 3.2: Add drag handle to ListCard
  - Open `apps/later_mobile/lib/design_system/organisms/cards/list_card.dart`
  - Add `DragHandleWidget` to card layout (same pattern as TodoListCard)
  - Pass `gradient: AppColors.listGradient` (purple-lavender)
  - Pass `semanticLabel: 'Reorder ${widget.list.name}'`
  - Add `_isDragging` state management
  - Test rendering, interaction, and accessibility

- [ ] Task 3.3: Ensure consistent spacing across all card types
  - Verify all three card types have identical handle placement and spacing
  - Check alignment in mixed content list (TodoList + Note + List)
  - Test with various content lengths (short titles, long titles, empty descriptions)

### Phase 4: Update HomeScreen Drag Logic

- [ ] Task 4.1: Refactor _buildContentCard to use handle-only dragging
  - Open `apps/later_mobile/lib/widgets/screens/home_screen.dart`
  - Locate `_buildContentCard` method (currently wraps entire card with ReorderableDragStartListener)
  - **Current implementation (lines 530-536)**:
    ```dart
    return ReorderableDragStartListener(
      key: ValueKey<String>(_getItemId(item)),
      index: index,
      child: card,
    );
    ```
  - **New implementation**: Remove ReorderableDragStartListener wrapper from card level
  - Instead, cards will internally wrap their DragHandleWidget with ReorderableDragStartListener

- [ ] Task 4.2: Update card components to wrap drag handle with listener
  - Modify each card (TodoListCard, NoteCard, ListCard) to accept `index` parameter
  - Wrap `DragHandleWidget` with `ReorderableDragStartListener`:
    ```dart
    ReorderableDragStartListener(
      index: widget.index,
      child: DragHandleWidget(
        gradient: ...,
        semanticLabel: ...,
      ),
    )
    ```
  - Pass `index` from HomeScreen's `_buildContentCard` to each card constructor
  - Update card constructors to include `required this.index` parameter

- [ ] Task 4.3: Update HomeScreen to pass index to cards
  - Modify `_buildContentCard` to pass `index: index` to all three card types
  - Update TodoListCard instantiation: `TodoListCard(todoList: item, index: index, onTap: ...)`
  - Update NoteCard instantiation: `NoteCard(item: item, index: index, onTap: ...)`
  - Update ListCard instantiation: `ListCard(list: item, index: index, onTap: ...)`
  - Keep `key: ValueKey<String>(_getItemId(item))` on the card widget itself

- [ ] Task 4.4: Test reordering interaction
  - Verify tapping card body still navigates to detail screen (gesture not captured by drag)
  - Verify dragging by handle triggers reordering (ReorderableListView responds)
  - Verify scrolling the list works smoothly (no accidental drag triggers)
  - Verify pull-to-refresh works without conflict
  - Test on physical device (not just simulator) for accurate gesture detection

- [ ] Task 4.5: Clean up removed code
  - Remove any commented-out code from previous full-card drag implementation
  - Remove unused variables or imports if any
  - Run `dart analyze` to check for warnings
  - Run `dart format .` to ensure consistent formatting

### Phase 5: Testing and Documentation

- [ ] Task 5.1: Write unit tests for DragHandleWidget
  - Create `apps/later_mobile/test/design_system/atoms/drag_handle/drag_handle_widget_test.dart`
  - Test rendering with different gradients (task, note, list)
  - Test interaction states (default, hover, pressed)
  - Test haptic feedback callbacks (onDragStart, onDragEnd)
  - Test semantic labels and accessibility properties
  - Mock HapticFeedback to verify it's called

- [ ] Task 5.2: Write widget tests for card integration
  - Create `apps/later_mobile/test/design_system/organisms/cards/card_drag_handle_test.dart`
  - Test each card type renders drag handle in correct position
  - Test drag handle has correct gradient for each card type
  - Test tapping card body navigates (doesn't trigger drag)
  - Test ReorderableDragStartListener is attached to handle (not card)

- [ ] Task 5.3: Write integration test for HomeScreen reordering
  - Update `apps/later_mobile/test/widgets/screens/home_screen_reorder_test.dart`
  - Test dragging by handle reorders items
  - Test scrolling works without triggering drag
  - Test pull-to-refresh works without triggering drag
  - Test reorder persists after operation completes
  - Use `WidgetTester.drag` or `WidgetTester.longPress` to simulate gestures

- [ ] Task 5.4: Manual testing checklist
  - [ ] Drag handle appears on all three card types (TodoList, Note, List)
  - [ ] Handle gradients match card border gradients
  - [ ] Tapping card body navigates to detail screen
  - [ ] Dragging handle reorders items
  - [ ] Scrolling works smoothly (no accidental drags)
  - [ ] Pull-to-refresh works without conflict
  - [ ] Haptic feedback triggers on drag start
  - [ ] VoiceOver announces semantic labels correctly
  - [ ] TalkBack announces semantic labels correctly
  - [ ] Touch target is 48×48px (verified in DevTools)
  - [ ] Light mode: handle visible and meets contrast ratio
  - [ ] Dark mode: handle visible and meets contrast ratio
  - [ ] Reduced motion: opacity changes are instant
  - [ ] Performance: 60fps maintained during scroll/drag
  - [ ] Order persists after app restart

- [ ] Task 5.5: Update documentation
  - Update `design-documentation/design-system/atoms.md` to document DragHandleWidget
  - Add usage examples showing how to integrate drag handle in cards
  - Update `CLAUDE.md` to mention drag handle pattern for reorderable lists
  - Add code comments in DragHandleWidget explaining gradient shader technique
  - Document accessibility considerations in component documentation

- [ ] Task 5.6: Update existing implementation plan
  - Move `user-defined-content-ordering.md` to `.claude/plans/completed/`
  - Create summary document linking drag handle design docs to implementation
  - Note lessons learned and any deviations from original plan

## Dependencies and Prerequisites

**Required Flutter/Dart:**
- `flutter/services.dart` - For HapticFeedback (already available)
- `flutter/material.dart` - For widgets and Material Design (already available)
- No new external dependencies needed

**Existing Code Patterns:**
- Atomic Design structure (`design_system/atoms/`)
- Gradient-based color system (AppColors.taskGradient, noteGradient, listGradient)
- ReorderableListView with ReorderableDragStartListener (already implemented)
- Semantic labels for accessibility (pattern exists in codebase)

**Design Specifications:**
- Complete design documentation in `design-documentation/features/drag-handle/`
- Visual specs, interaction specs, accessibility guidelines all defined
- Reference implementation guide with Flutter code examples

**Development Setup:**
- Working directory: `apps/later_mobile`
- Ensure Flutter SDK is up to date (`flutter upgrade`)
- Run `flutter pub get` to ensure dependencies are current
- Use physical device for haptic feedback and gesture testing (simulators don't provide accurate feedback)

## Challenges and Considerations

**1. Gesture Conflict Resolution:**
- **Challenge**: Ensuring drag handle captures drag gestures without breaking card tap or list scroll
- **Mitigation**: Use `ReorderableDragStartListener` only on handle, not entire card. GestureDetector on card body will win for tap gestures, ScrollController will win for scroll gestures
- **Test**: Extensively test tap, long-press, drag, and scroll interactions on physical device

**2. Visual Clutter:**
- **Challenge**: Adding drag handle without making cards feel busy or cramped
- **Mitigation**: Use 40% default opacity (subtle), right-side placement (out of focus area), minimal size (20×24px visible icon)
- **Test**: Get user feedback on visual design, consider A/B testing with different opacity levels

**3. Accessibility Compliance:**
- **Challenge**: Meeting WCAG 2.1 AA standards for touch target, contrast, and screen reader support
- **Mitigation**: 48×48px touch target exceeds 44×44px requirement, active state ensures 4.5:1 contrast, semantic labels provide context
- **Test**: Use automated accessibility scanners (Accessibility Scanner on Android, Accessibility Inspector on iOS)

**4. Haptic Feedback Availability:**
- **Challenge**: HapticFeedback may not work on all devices (older Android, web, desktop)
- **Mitigation**: Wrap HapticFeedback calls in try-catch or platform checks, provide visual feedback as primary indicator
- **Test**: Test on various devices and platforms, ensure app doesn't crash if haptics unavailable

**5. Performance with Many Items:**
- **Challenge**: Adding DragHandleWidget to 100+ cards could impact scroll performance
- **Mitigation**: Keep widget lightweight (no heavy animations or computations), use const constructors, profile with DevTools
- **Test**: Test with 100+ items on older/slower devices

**6. Gradient Shader Complexity:**
- **Challenge**: Applying gradient to grip dots requires ShaderMask, which can be expensive
- **Mitigation**: Cache shader if possible, use RepaintBoundary, consider solid color fallback for low-end devices
- **Test**: Profile rendering performance, especially during scroll

**7. Dark Mode Gradient Visibility:**
- **Challenge**: Gradients designed for light mode may not be visible enough in dark mode at 40% opacity
- **Mitigation**: Design specs already account for dark mode with adjusted colors, test thoroughly in dark mode
- **Test**: View handles in dark mode, verify 40% opacity is visible, adjust if needed

**8. Index Passing in Widget Tree:**
- **Challenge**: ReorderableListView requires index at the listener level, but now listener is inside card component
- **Mitigation**: Pass `index` as parameter from HomeScreen to each card, card internally wraps handle with listener
- **Test**: Verify reordering works correctly, check that index updates don't cause unnecessary rebuilds

**9. State Management During Drag:**
- **Challenge**: Card needs to know when drag is active to disable press animation
- **Mitigation**: Use local state (`_isDragging`) in card, updated via DragHandleWidget callbacks
- **Test**: Verify press animation doesn't trigger during drag, verify animation re-enables after drag ends

**10. Backward Compatibility:**
- **Challenge**: Existing users may be used to full-card dragging behavior
- **Mitigation**: Document change in release notes, provide visual affordance (handle) to teach new interaction
- **Test**: Consider beta testing with subset of users, gather feedback on discoverability

**11. Testing Drag Gestures in Widget Tests:**
- **Challenge**: Simulating drag gestures in widget tests can be flaky, especially with ReorderableListView
- **Mitigation**: Use robust test utilities, add delays between gesture steps, focus on integration tests over unit tests for gesture logic
- **Test**: Run widget tests multiple times to ensure consistency, use golden tests for visual regression

**12. Reduced Motion Support:**
- **Challenge**: Users with motion sensitivity need animations disabled
- **Mitigation**: Check `MediaQuery.disableAnimations`, skip AnimatedOpacity transitions if true
- **Test**: Enable Reduce Motion in device settings, verify transitions are instant

## Success Criteria

- [ ] Drag handle appears on all three card types with correct gradients
- [ ] Dragging handle reorders content, tapping card navigates
- [ ] Scrolling and pull-to-refresh work without gesture conflicts
- [ ] All accessibility tests pass (VoiceOver, TalkBack, touch target, contrast)
- [ ] Performance maintained at 60fps with 100+ items
- [ ] Unit, widget, and integration tests pass
- [ ] Manual testing checklist completed
- [ ] Documentation updated

## Implementation Timeline Estimate

- Phase 1: Create DragHandleWidget - **2-3 hours**
- Phase 2: Integrate into TodoListCard - **1 hour**
- Phase 3: Integrate into NoteCard and ListCard - **1 hour**
- Phase 4: Update HomeScreen drag logic - **1-2 hours**
- Phase 5: Accessibility testing - **2 hours**
- Phase 6: Performance testing - **1 hour**
- Phase 7: Testing and documentation - **3-4 hours**

**Total estimate: 11-16 hours** (1-2 days of focused development)
