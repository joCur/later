---
title: Drag Handle Interaction Specifications
description: Complete interaction patterns, animations, and state transitions for the drag handle
feature: drag-handle-reordering
last-updated: 2025-11-02
version: 1.0.0
related-files:
  - ./README.md
  - ./visual-specifications.md
  - ./implementation-guide.md
status: approved
---

# Drag Handle Interaction Specifications

## Interaction Overview

The drag handle provides a dedicated, discoverable affordance for reordering content cards via drag-and-drop. This document specifies all interaction patterns, state transitions, animations, and feedback mechanisms.

## Interaction States

### State Diagram
```
┌─────────┐
│ Default │ (40% opacity, idle)
└────┬────┘
     │
     ├──► [Mouse Enter] ──► ┌───────┐
     │                       │ Hover │ (60% opacity, grab cursor)
     │                       └───┬───┘
     │                           │
     ├──► [Touch Start] ────────►│
     │                           │
     │                      [Drag Start]
     │                           │
     │                           ▼
     │                      ┌────────┐
     │                      │ Active │ (100% opacity, scale 1.05)
     │                      └───┬────┘
     │                          │
     │                     [Drag End]
     │                          │
     └──────────────────────────┘
```

### State Specifications

#### 1. Default State (Idle)
**When**: Handle is visible but not being interacted with

**Visual Properties**:
- Opacity: 40% (0.4)
- Scale: 1.0
- Cursor: Default pointer
- Shadow: Inherits card shadow

**Behavior**:
- Visible affordance indicating draggable nature
- Non-intrusive presence within card
- No animations or transitions

**Transitions From Default**:
- Mouse enter → Hover state (desktop/web only)
- Touch start → Active state (all platforms)
- Long press start → Active state (mobile fallback)

---

#### 2. Hover State (Desktop/Web Only)
**When**: Mouse cursor is over the handle (hover-capable devices only)

**Visual Properties**:
- Opacity: 60% (0.6) — stronger presence
- Scale: 1.0
- Cursor: `SystemMouseCursors.grab`
- Shadow: Inherits card shadow
- Transition: 150ms ease-out fade

**Behavior**:
- Emphasizes interactivity on hover-capable devices
- Provides affordance before drag interaction
- Smooth opacity transition from default

**Transitions From Hover**:
- Mouse leave → Default state
- Mouse down (drag start) → Active state
- Card tap (outside handle) → Default state (handle loses hover)

**Implementation Notes**:
- Use `MouseRegion` widget for hover detection
- Only enable on desktop/web (not on touch-only devices)
- Cursor change provides additional affordance

---

#### 3. Active State (Dragging)
**When**: User is actively dragging the card via the handle

**Visual Properties**:
- Opacity: 100% (1.0) — full gradient intensity
- Scale: 1.05 (subtle lift effect)
- Cursor: `SystemMouseCursors.grabbing` (desktop/web)
- Shadow: Card shadow increases (8px offset, 16px blur, 20% opacity)
- Transition: 100ms ease-out scale animation

**Behavior**:
- Maximum visibility during drag operation
- Card follows cursor/touch position
- Drag preview shows card at current position
- Other cards animate aside to show potential drop location

**Feedback Mechanisms**:
- **Haptic**: Light impact (`HapticFeedback.lightImpact()`) on drag start
- **Visual**: Handle scale + opacity increase
- **Cursor**: Grabbing cursor (desktop/web)
- **Card Elevation**: Entire card lifts with increased shadow

**Transitions From Active**:
- Drag end (successful reorder) → Default state
- Drag cancel (ESC key, invalid drop) → Default state with animation
- Touch cancel (gesture conflict) → Default state

---

#### 4. Disabled State (Read-Only Mode)
**When**: Reordering is disabled (e.g., filtered view, read-only space)

**Visual Properties**:
- Opacity: 0% (completely hidden)
- Interactive: False
- Render: Handle is not rendered or is hidden

**Behavior**:
- Handle is not visible or interactive
- Card cannot be dragged
- No hover states or cursor changes

**Transitions**:
- Enable reordering → Default state with fade-in animation

---

## Gesture Recognition

### Touch Gestures (Mobile)

#### Tap (Quick Touch & Release)
**Trigger**: Touch down + touch up within 100ms, no movement
**Action**: Pass through to card (open card detail screen)
**Rationale**: Tapping handle should not trigger drag, only open card

#### Long Press (Fallback)
**Trigger**: Touch down + hold for 500ms
**Action**: Start drag operation (same as handle drag)
**Rationale**: Provides fallback for users who miss the handle
**Note**: This is the existing behavior, handle provides better affordance

#### Drag from Handle
**Trigger**: Touch down on handle + move >8px within 100ms
**Action**: Start drag operation immediately
**Rationale**: Primary drag interaction, no delay needed

**Drag Threshold**: 8px movement before drag starts
**Purpose**: Prevents accidental drags from taps

#### Scroll (Outside Handle)
**Trigger**: Touch down outside handle + vertical swipe
**Action**: Scroll list (normal scrolling)
**Rationale**: Drag handle prevents gesture conflicts with scrolling

#### Pull-to-Refresh (Outside Handle)
**Trigger**: Touch down outside handle + vertical swipe from top
**Action**: Trigger pull-to-refresh
**Rationale**: Drag handle prevents gesture conflicts with pull-to-refresh

### Mouse Gestures (Desktop/Web)

#### Hover
**Trigger**: Mouse enter handle area (48×48px)
**Action**: Transition to hover state (60% opacity, grab cursor)

#### Click & Drag
**Trigger**: Mouse down on handle + mouse move >4px
**Action**: Start drag operation
**Rationale**: Standard desktop drag interaction

**Drag Threshold**: 4px (lower than touch, more sensitive for mouse)

#### Click (No Drag)
**Trigger**: Mouse down + mouse up within 100ms, no movement
**Action**: Pass through to card (open card detail screen)
**Rationale**: Clicking handle without dragging should open card

### Keyboard Navigation (Accessibility)

#### Tab to Handle
**Trigger**: Tab key press (focus management)
**Action**: Focus handle, show focus indicator (2px outline)
**Accessibility**: Screen reader announces "Drag to reorder [item name]"

#### Arrow Keys (Up/Down)
**Trigger**: Up/Down arrow keys while handle is focused
**Action**: Reorder card up/down in list
**Rationale**: Keyboard-accessible alternative to drag-and-drop

**Implementation**:
- Up Arrow: Move card one position up
- Down Arrow: Move card one position down
- Shift + Up/Down: Move to top/bottom of list
- Animation: Same as drag-and-drop reorder

#### Enter/Space Key
**Trigger**: Enter or Space key while handle is focused
**Action**: Open card detail screen (same as clicking card)
**Rationale**: Provides card interaction via keyboard

#### Escape Key (During Drag)
**Trigger**: ESC key during drag operation
**Action**: Cancel drag, return card to original position
**Rationale**: Standard escape hatch for canceling drag

---

## Animation Specifications

### Opacity Transitions

#### Default → Hover
- **Duration**: 150ms
- **Easing**: `Curves.easeOut`
- **Property**: Opacity 0.4 → 0.6
- **Widget**: `AnimatedOpacity` or `TweenAnimationBuilder`

#### Hover → Default
- **Duration**: 150ms
- **Easing**: `Curves.easeOut`
- **Property**: Opacity 0.6 → 0.4
- **Widget**: `AnimatedOpacity`

#### Any → Active
- **Duration**: 100ms
- **Easing**: `Curves.easeOut`
- **Property**: Opacity → 1.0
- **Widget**: `AnimatedOpacity`

#### Active → Default
- **Duration**: 200ms
- **Easing**: `Curves.easeOut`
- **Property**: Opacity 1.0 → 0.4
- **Widget**: `AnimatedOpacity`

### Scale Animations

#### Active State (Drag Start)
- **Duration**: 100ms
- **Easing**: `Curves.easeOut`
- **Property**: Scale 1.0 → 1.05
- **Transform Origin**: Center of handle
- **Widget**: `AnimatedScale` or `TweenAnimationBuilder`

#### Active → Default (Drag End)
- **Duration**: 200ms
- **Easing**: `Curves.easeOutBack` (slight overshoot)
- **Property**: Scale 1.05 → 1.0
- **Transform Origin**: Center of handle
- **Widget**: `AnimatedScale`

### Card Elevation Animation (During Drag)

#### Card Lift (Drag Start)
- **Duration**: 100ms
- **Easing**: `Curves.easeOut`
- **Properties**:
  - Card scale: 1.0 → 1.03
  - Shadow offset: 4px → 8px
  - Shadow blur: 8px → 16px
  - Shadow opacity: 12% → 20%

#### Card Drop (Drag End)
- **Duration**: 250ms
- **Easing**: `Curves.easeOutBack`
- **Properties**:
  - Card scale: 1.03 → 1.0
  - Shadow offset: 8px → 4px
  - Shadow blur: 16px → 8px
  - Shadow opacity: 20% → 12%

### List Reordering Animation

When cards reorder in the list:

- **Duration**: 250ms
- **Easing**: `Curves.easeInOut`
- **Animation**: Cards slide smoothly to new positions
- **Widget**: `ReorderableListView` (built-in animation)

**Implementation Note**: Flutter's `ReorderableListView` handles this automatically.

---

## Haptic Feedback

### Mobile Haptic Patterns

#### Drag Start (Handle Touch)
- **Type**: `HapticFeedback.lightImpact()`
- **When**: Touch down on handle + movement starts drag
- **Purpose**: Confirm drag has started

#### Reorder Success
- **Type**: `HapticFeedback.mediumImpact()`
- **When**: Card is dropped at new position
- **Purpose**: Confirm successful reorder

#### Drag Cancel
- **Type**: `HapticFeedback.selectionClick()`
- **When**: Drag is canceled (ESC key, invalid drop)
- **Purpose**: Indicate cancellation

### Desktop/Web (No Haptics)
No haptic feedback on desktop/web platforms. Visual and cursor feedback only.

---

## Cursor Changes (Desktop/Web)

### Cursor States

#### Default State
- **Cursor**: `SystemMouseCursors.basic` (default pointer)
- **Context**: When not hovering over handle

#### Hover State (Over Handle)
- **Cursor**: `SystemMouseCursors.grab` (open hand)
- **Context**: Mouse hovering over handle, ready to drag

#### Active State (Dragging)
- **Cursor**: `SystemMouseCursors.grabbing` (closed fist)
- **Context**: Actively dragging card via handle

#### Disabled State
- **Cursor**: `SystemMouseCursors.basic` (default pointer)
- **Context**: Handle is hidden or disabled

### Implementation
```dart
MouseRegion(
  cursor: _isHovered
    ? SystemMouseCursors.grab
    : SystemMouseCursors.basic,
  onEnter: (_) => setState(() => _isHovered = true),
  onExit: (_) => setState(() => _isHovered = false),
  child: GestureDetector(
    onPanStart: (details) {
      setState(() => _isDragging = true);
      // Cursor automatically changes to grabbing via platform
    },
    child: DragHandleWidget(...),
  ),
)
```

---

## Focus Management (Accessibility)

### Focus Indicator
When handle receives keyboard focus:

- **Outline**: 2px solid border
- **Color (Light)**: `AppColors.focusLight` (#3B82F6, Blue-500)
- **Color (Dark)**: `AppColors.focusDark` (#EDE9FE, Violet-100)
- **Offset**: 2px outside handle boundary (no overlap)
- **Border Radius**: 4px (matches handle shape)
- **Contrast**: 4.5:1 minimum against background

### Focus Order
Tab order within card:
1. Card container (tappable area)
2. Drag handle (keyboard reorder)
3. Next card in list

**Implementation**: Use `FocusNode` for handle, ensure proper tab order.

### Screen Reader Announcements

#### On Focus
```
"Drag handle. Drag to reorder [item name].
Use arrow keys to move up or down.
Press Enter to open."
```

#### During Reorder
```
"Moved [item name] to position [X]"
```

#### On Cancel
```
"Reorder canceled. [item name] returned to position [X]"
```

---

## Gesture Arena & Priority

### Problem: Gesture Conflicts
Multiple gestures compete for touch events:
- Card tap (open detail)
- Scroll (list scrolling)
- Pull-to-refresh (refresh content)
- Drag handle (reorder)

### Solution: Gesture Priority

#### High Priority (Wins Arena)
1. **Drag Handle Gesture**: When touch starts on handle (48×48px area)
   - Wins over card tap
   - Prevents scroll and pull-to-refresh conflicts

#### Medium Priority
2. **Card Tap Gesture**: When touch is outside handle
   - Opens card detail screen
   - Loses to drag handle if touch is on handle

#### Low Priority (System Defaults)
3. **Scroll Gesture**: When touch is outside handle and moves vertically
4. **Pull-to-Refresh**: When touch is at top of list and swipes down

### Implementation Strategy

#### ReorderableDragStartListener (Current)
The current implementation wraps the entire card:

```dart
ReorderableDragStartListener(
  key: ValueKey('item-${item.id}'),
  index: index,
  child: card,
)
```

**Problem**: Entire card is draggable, causes gesture conflicts.

#### Solution: Drag Handle Only
Wrap only the drag handle:

```dart
Card(
  child: Row(
    children: [
      LeadingIcon(),
      Expanded(child: Content()),
      ReorderableDragStartListener(
        key: ValueKey('handle-${item.id}'),
        index: index,
        child: DragHandleWidget(),
      ),
    ],
  ),
)
```

**Benefit**: Only handle triggers drag, card tap and scroll work normally.

---

## Performance Considerations

### Animation Performance
- **Target**: 60fps on all devices
- **Strategy**: Use GPU-accelerated animations
- **Widgets**: `AnimatedOpacity`, `AnimatedScale` (built-in optimization)
- **Shader Caching**: Cache gradient shaders for reuse

### Repaint Optimization
- **RepaintBoundary**: Isolate handle from card repaints
- **Const Constructors**: Use const for static handle parts
- **Lazy Rendering**: Only render when card is visible

### Memory Management
- **Dispose**: Properly dispose animation controllers
- **Shared Gradients**: Reuse gradient instances across cards
- **Weak References**: Avoid memory leaks in callbacks

---

## Edge Cases & Error Handling

### Edge Case 1: Drag to Invalid Position
**Scenario**: User drags card outside list bounds
**Behavior**: Snap back to original position with animation
**Animation**: 250ms ease-out-back (rubber band effect)

### Edge Case 2: Rapid Gestures
**Scenario**: User rapidly taps/drags handle
**Behavior**: Debounce gestures, only process first valid gesture
**Implementation**: Track `_isDragging` state, ignore new gestures while true

### Edge Case 3: Network Error During Reorder
**Scenario**: Drag succeeds locally but sync fails (future Phase 2)
**Behavior**: Show error toast, maintain local order, retry on reconnect
**Note**: Currently local-only, no network sync yet

### Edge Case 4: Keyboard Focus on Hidden Handle
**Scenario**: Handle is focused, then disabled (filtered view)
**Behavior**: Move focus to next focusable element in list
**Implementation**: Remove handle from focus order when disabled

### Edge Case 5: Screen Rotation During Drag
**Scenario**: Device rotates while dragging
**Behavior**: Cancel drag, return card to original position
**Rationale**: Prevents disorientation and layout issues

---

## Accessibility Testing Checklist

- ✓ Touch target meets 48×48px minimum (WCAG 2.5.5 Level AA)
- ✓ Focus indicator has 4.5:1+ contrast ratio (WCAG 1.4.11)
- ✓ Keyboard navigation works (Tab, Arrow keys, Enter, ESC)
- ✓ Screen reader announces drag affordance and state changes
- ✓ Cursor changes communicate interactivity (desktop/web)
- ✓ Haptic feedback confirms interactions (mobile)
- ✓ Animation respects `prefers-reduced-motion` preference
- ✓ Color contrast meets AA standards at all opacity levels
- ✓ Focus order is logical and predictable
- ✓ Alternative text is descriptive and context-aware

---

## Motion & Accessibility: Reduced Motion

### User Preference Detection
```dart
final reduceMotion = MediaQuery.of(context).disableAnimations;
```

### Reduced Motion Behavior
When `prefers-reduced-motion` is enabled:

- **Opacity Transitions**: Instant (0ms duration)
- **Scale Animations**: Instant (0ms duration)
- **Card Reorder**: Instant position change (no slide animation)
- **Card Elevation**: Instant shadow change (no scale animation)

**Implementation**:
```dart
final duration = reduceMotion
  ? Duration.zero
  : Duration(milliseconds: 150);

AnimatedOpacity(
  duration: duration,
  opacity: _opacity,
  child: child,
)
```

---

## Implementation Priority

### P0 - Core Interactions
1. ✓ Touch drag from handle (mobile primary use case)
2. ✓ Opacity state transitions (default → hover → active)
3. ✓ Drag start/end animations (scale, elevation)
4. ✓ Haptic feedback on drag start and reorder success

### P1 - Enhanced Experience
5. ✓ Hover state for desktop/web (cursor changes)
6. ✓ Keyboard navigation (Tab, arrow keys)
7. ✓ Focus indicators for accessibility
8. ✓ Screen reader announcements

### P2 - Polish
9. Reduced motion support
10. Advanced keyboard shortcuts (Shift + arrows)
11. Drag preview customization
12. Multi-select drag (future enhancement)

---

## Next Steps

1. Review implementation guide for Flutter code examples
2. Implement `DragHandleWidget` with all state transitions
3. Integrate into card components with gesture priority
4. Test accessibility compliance (focus, screen readers, keyboard)
5. Conduct user testing for discoverability and usability
6. Iterate based on user feedback
