---
title: No Spaces Empty State - Interaction Design & Animations
description: Detailed interaction patterns, animations, and motion specifications
feature: no-spaces-empty-state
last-updated: 2025-11-07
version: 1.0.0
related-files:
  - ./README.md
  - ./screen-states.md
  - ./accessibility.md
  - ../../design-system/tokens/animations.md
status: approved
---

# No Spaces Empty State - Interaction Design & Animations

## Overview

This document specifies all interaction patterns, animations, transitions, and motion choreography for the No Spaces Empty State feature.

## Animation Philosophy

### Design Principles
- **Physics-based motion**: Use spring curves for natural, organic feel
- **Purposeful animation**: Every animation serves a functional purpose (not decoration)
- **Performance-first**: 60fps minimum, hardware acceleration
- **Accessibility**: Respect `prefers-reduced-motion` system setting
- **Subtle polish**: Animations enhance without distracting

### Motion Language
- **Entrances**: Gentle fade + scale (welcoming, non-aggressive)
- **Interactions**: Snappy response (immediate feedback, responsive feel)
- **Transitions**: Smooth spring curves (natural, organic motion)

---

## Animation Specification 1: Entrance Animation

### Purpose
Smoothly introduce the empty state when first rendered. Prevents jarring "pop-in" and creates polished first impression.

### Trigger
Component mounts (first render after `spaces.length == 0` condition is met)

### Animation Properties

**Fade In**:
- **Start Value**: 0.0 (fully transparent)
- **End Value**: 1.0 (fully opaque)
- **Duration**: 400ms (AppAnimations.gentle)
- **Curve**: `AppAnimations.gentleSpringCurve`
  - Mass: 1.0
  - Stiffness: 120
  - Damping: 14
- **Timing**: Begins at 0ms (immediately on mount)

**Scale**:
- **Start Value**: Offset(0.95, 0.95) (slightly smaller)
- **End Value**: Offset(1.0, 1.0) (normal size)
- **Duration**: 400ms (AppAnimations.gentle)
- **Curve**: `AppAnimations.gentleSpringCurve` (same as fade)
- **Timing**: Begins at 0ms (parallel with fade)
- **Origin**: Center of content container

**Affected Elements**:
- Entire content group (icon, title, message, button)
- Animated as a single unit, not individually

### Implementation

**Code Pattern**:
```dart
// Handled automatically by AnimatedEmptyState component
AnimatedEmptyState(
  icon: Icons.folder_rounded,
  title: 'Welcome to Later',
  message: '...',
  actionLabel: 'Create Your First Space',
  onActionPressed: _handleCreateSpace,
  // No enableFabPulse callback (not applicable for this state)
)
```

**Under the Hood** (in AnimatedEmptyState):
```dart
Widget build(BuildContext context) {
  final reducedMotion = AppAnimations.prefersReducedMotion(context);

  Widget content = EmptyState(...);

  if (!reducedMotion) {
    content = content
      .animate()
      .fadeIn(
        duration: AppAnimations.gentle,
        curve: AppAnimations.gentleSpringCurve,
      )
      .scale(
        begin: Offset(0.95, 0.95),
        end: Offset(1.0, 1.0),
        duration: AppAnimations.gentle,
        curve: AppAnimations.gentleSpringCurve,
      );
  }

  return content;
}
```

### Reduced Motion Alternative

**Condition**: `MediaQuery.of(context).disableAnimations == true`

**Behavior**:
- Skip animation entirely
- Content appears instantly at full opacity and scale
- Ensures accessibility compliance for motion-sensitive users

**Testing**:
- Enable "Reduce Motion" in iOS/Android accessibility settings
- Verify content appears instantly without animation

### Performance Considerations

**Optimization**:
- Use `flutter_animate` package (optimized for performance)
- Hardware acceleration enabled automatically
- No layout thrashing (transform-only animations)

**Frame Rate Target**: 60fps minimum

**Testing**:
- Monitor frame rate in Flutter DevTools
- Test on low-end devices (iPhone 8, Android equivalents)
- Ensure no dropped frames during animation

---

## Animation Specification 2: Button Press Animation

### Purpose
Provide immediate tactile feedback when user taps button. Confirms interaction received before modal opens.

### Trigger
User presses/taps "Create Your First Space" button

### Press Down Animation

**Scale**:
- **Start Value**: 1.0 (normal size)
- **End Value**: 0.96 (AppAnimations.buttonPressScale)
- **Duration**: 120ms (AppAnimations.quick)
- **Curve**: `AppAnimations.snappySpringCurve`
  - Mass: 0.8
  - Stiffness: 220
  - Damping: 10
- **Origin**: Center of button

**Shadow Reduction**:
- **Start Value**: Elevation 2 (offset: 0,2, blur: 4px)
- **End Value**: Elevation 1 (offset: 0,1, blur: 2px)
- **Duration**: 120ms (same as scale)
- **Curve**: `AppAnimations.snappySpringCurve`

**Overlay Darkening**:
- **Start Value**: Transparent (0% opacity)
- **End Value**: Black 5% opacity
- **Duration**: 120ms
- **Curve**: Linear (for smooth color transition)
- **Effect**: Slight darkening of gradient background

### Release Animation (Press Up)

**Scale**:
- **Start Value**: 0.96 (pressed state)
- **End Value**: 1.0 (normal size)
- **Duration**: 150ms (AppAnimations.itemRelease)
- **Curve**: `AppAnimations.bouncySpringCurve`
  - Mass: 1.0
  - Stiffness: 200
  - Damping: 8
- **Overshoot**: Slight bounce back (scale briefly goes to ~1.02, then settles)

**Shadow Recovery**:
- **Start Value**: Elevation 1
- **End Value**: Elevation 2
- **Duration**: 150ms
- **Curve**: `AppAnimations.bouncySpringCurve`

**Overlay Removal**:
- **Start Value**: Black 5% opacity
- **End Value**: Transparent
- **Duration**: 150ms
- **Curve**: Linear

### Haptic Feedback

**Type**: Light impact (`HapticFeedback.lightImpact()`)

**Timing**: On press down (not on release)

**Implementation**:
```dart
await AppAnimations.lightHaptic();
```

**Platform Support**:
- iOS: ✅ Supported (uses Taptic Engine)
- Android: ✅ Supported (uses vibration motor)
- Web: ❌ Not supported (silently fails)

**Accessibility**:
- Haptic feedback is independent of visual motion
- Users with "Reduce Motion" enabled still receive haptic feedback
- Users can disable haptics via system settings (iOS/Android)

### Implementation

**Code Pattern**:
```dart
// PrimaryButton already implements this behavior
PrimaryButton(
  text: 'Create Your First Space',
  onPressed: () async {
    // Haptic feedback triggered automatically by PrimaryButton
    // Press animation triggered automatically by PrimaryButton
    await _handleCreateSpace();
  },
  size: ButtonSize.large,
)
```

**State Management**:
- Button handles its own press state internally
- No external state management needed
- Press animation plays even if `onPressed` is async (doesn't wait for callback)

---

## Animation Specification 3: Button Hover Animation (Desktop/Tablet)

### Purpose
Indicate interactivity when user hovers with cursor (not applicable on touch devices).

### Trigger
Mouse cursor enters button bounds (desktop/tablet with pointer input only)

### Hover Enter Animation

**Shadow Elevation**:
- **Start Value**: Elevation 2
- **End Value**: Elevation 3 (offset: 0,3, blur: 6px)
- **Duration**: 50ms (AppAnimations.instant)
- **Curve**: Linear (for instant feedback)

**Overlay Lightening**:
- **Start Value**: Transparent
- **End Value**: White 10% opacity
- **Duration**: 50ms
- **Curve**: Linear
- **Effect**: Slight brightening of gradient background

**Cursor**:
- **Change**: `SystemMouseCursors.click` (pointing hand)
- **Timing**: Instant (no animation)

### Hover Exit Animation

**Shadow Elevation**:
- **Start Value**: Elevation 3
- **End Value**: Elevation 2
- **Duration**: 50ms
- **Curve**: Linear

**Overlay Removal**:
- **Start Value**: White 10% opacity
- **End Value**: Transparent
- **Duration**: 50ms
- **Curve**: Linear

**Cursor**:
- **Change**: `SystemMouseCursors.basic` (default arrow)
- **Timing**: Instant

### Platform Detection

**Touch Devices** (Mobile):
- Hover animation **disabled**
- Reason: No hover capability on touchscreens
- Detection: `Theme.of(context).platform` or hover events

**Desktop/Tablet with Cursor**:
- Hover animation **enabled**
- Uses MouseRegion widget to detect hover state

### Implementation

**Code Pattern**:
```dart
// PrimaryButton already implements hover behavior
// No additional configuration needed
PrimaryButton(
  text: 'Create Your First Space',
  onPressed: _handleCreateSpace,
  size: ButtonSize.large,
)
```

---

## Animation Specification 4: Button Loading State (Optional)

### Purpose
Indicate processing when space creation takes longer than expected (>200ms).

### Trigger
Button pressed → 200ms delay with no response → Show loading

**Rationale for 200ms delay**:
- Don't flash loading indicator for fast operations
- Most space creations complete in <200ms (local + network)
- 200ms is imperceptible to user (below reaction time threshold)

### Entrance Animation (Text → Spinner)

**Text Fade Out**:
- **Start Value**: 1.0 opacity
- **End Value**: 0.0 opacity
- **Duration**: 50ms
- **Curve**: Linear

**Spinner Fade In**:
- **Start Value**: 0.0 opacity
- **End Value**: 1.0 opacity
- **Duration**: 50ms
- **Delay**: 50ms (after text fades out)
- **Curve**: Linear

**Spinner Appearance**:
- **Component**: `CircularProgressIndicator`
- **Size**: 20px diameter
- **Stroke Width**: 2px
- **Color**: White (`Colors.white`)
- **Position**: Horizontally centered in button

**Button State Changes**:
- **Opacity**: 0.7 (entire button dims)
- **Interaction**: Disabled (`onPressed: null` equivalent)
- **Scale**: 1.0 (release from press state if still pressed)

### Loading Animation (Continuous)

**Spinner Rotation**:
- **Duration**: 1000ms per full rotation (AppAnimations.spinnerRotation)
- **Curve**: `Curves.linear` (constant speed)
- **Loop**: Infinite until loading completes

### Exit Animation (Spinner → Next State)

**On Success** (Space created):
- Entire empty state fades out (120ms)
- Home screen rebuilds with new space
- Transition to WelcomeState

**On Error** (Space creation failed):
- Handled by CreateSpaceModal (not by empty state)
- Button returns to default state (reverse entrance animation)
- Error message shown in modal

### Implementation

**Code Pattern**:
```dart
// In NoSpacesState
Future<void> _handleCreateSpace() async {
  // Show modal
  final spaceCreated = await showModalBottomSheet(
    context: context,
    builder: (context) => CreateSpaceModal(mode: SpaceModalMode.create),
  );

  // If space created, home screen rebuilds automatically via provider
  // No manual loading state management needed
}
```

**Loading State**: Handled by CreateSpaceModal submit button, not empty state button

**Clarification**: Empty state button doesn't show loading. Modal handles all loading states.

---

## Animation Specification 5: Exit Transition (Empty State → Home Screen)

### Purpose
Smoothly transition from empty state to home screen after space is created.

### Trigger
User successfully creates space in CreateSpaceModal → Modal dismisses → Space added to SpacesProvider → Home screen rebuilds

### Exit Animation Sequence

**Timeline**:
```
0ms → Modal dismiss begins
  ↓
120ms → Modal fully dismissed
  ↓
0ms → Empty state fade out begins (simultaneous with modal dismiss)
  ↓
120ms → Empty state fully faded out
  ↓
0ms → Home screen rebuilds with new space
  ↓
0ms → WelcomeState entrance animation begins
  ↓
400ms → WelcomeState fully rendered
```

**Empty State Fade Out**:
- **Start Value**: 1.0 opacity
- **End Value**: 0.0 opacity
- **Duration**: 120ms (AppAnimations.quick)
- **Curve**: `Curves.easeOut` (accelerating exit)
- **Timing**: Begins as modal starts dismissing

**Scale Out** (Optional):
- **Start Value**: 1.0
- **End Value**: 0.95 (slight scale down)
- **Duration**: 120ms
- **Curve**: `Curves.easeOut`

**Implementation**:
- Handled automatically by Flutter's widget rebuilding
- No explicit exit animation needed
- New widget tree replaces old one

### State Transition Flow

**Before**:
```dart
home_screen.dart: spaces.length == 0 → NoSpacesState
```

**After**:
```dart
home_screen.dart: spaces.length == 1 → WelcomeState (empty space)
```

**Provider Update**:
```dart
// SpacesProvider.createSpace() triggers notifyListeners()
// home_screen.dart rebuilds via Consumer<SpacesProvider>
// Condition: spaces.length == 0 → false
// New condition: spaces.length == 1 && content.isEmpty == true
// Result: Show WelcomeState
```

---

## Interaction Specification 1: Button Press Flow

### Complete Interaction Sequence

**Timeline**:
```
0ms → User finger touches button (touchDown)
  ↓
0-50ms → Press animation begins (scale, shadow, overlay)
  ↓
0ms → Haptic feedback fires (lightImpact)
  ↓
120ms → Press animation completes (fully pressed state)
  ↓
[User holds for 0-100ms typical]
  ↓
0ms → User lifts finger (touchUp)
  ↓
0ms → Release animation begins (scale back, shadow recovery)
  ↓
0ms → onPressed callback fires (opens CreateSpaceModal)
  ↓
150ms → Release animation completes (slight overshoot, then settle)
  ↓
250ms → Modal slide-up animation completes (modal fully visible)
```

### Edge Cases

**Fast Tap** (Touch duration <50ms):
- Press animation may not complete before release
- Acceptable: Animation blends smoothly into release
- No visual glitch or stutter

**Slow Tap** (Touch duration >500ms):
- Press state held for entire duration
- No "long press" behavior (not implemented)
- Release animation triggers normally on lift

**Cancel Tap** (Drag out of button bounds):
- Button returns to default state
- `onPressed` callback **not fired**
- Release animation plays (scale 0.96 → 1.0)
- User feedback: Tap was cancelled

---

## Interaction Specification 2: Modal Opening Flow

### Trigger
User successfully taps "Create Your First Space" button (press → release → callback)

### Modal Entrance Animation

**Slide Up**:
- **Start Position**: Bottom of screen (offset: 0, 1.0)
- **End Position**: Final position (offset: 0, 0.0)
- **Duration**: 250ms (AppAnimations.modalEnter)
- **Curve**: `AppAnimations.smoothSpringCurve`
  - Mass: 1.2
  - Stiffness: 150
  - Damping: 15

**Backdrop Fade**:
- **Start Value**: 0.0 (transparent)
- **End Value**: 0.5 (50% black overlay)
- **Duration**: 250ms (parallel with slide)
- **Curve**: `Curves.easeOut`

**Modal Scale**:
- **Start Value**: 0.95 (slightly smaller)
- **End Value**: 1.0 (normal size)
- **Duration**: 250ms (parallel with slide)
- **Curve**: `AppAnimations.smoothSpringCurve`

### Implementation

**Code Pattern**:
```dart
Future<void> _handleCreateSpace() async {
  final result = await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // For rounded top corners
    builder: (context) => CreateSpaceModal(mode: SpaceModalMode.create),
  );

  // result will be Space object if created, null if dismissed
  if (result != null) {
    // Space was created, provider already updated
    // Home screen will rebuild automatically
  }
}
```

**Modal Dismissal**:
- User taps outside modal → Backdrop tap → Modal slides down (120ms)
- User taps "Cancel" in modal → Modal slides down (120ms)
- User completes creation → Modal slides down (120ms) → Home screen updates

---

## Interaction Specification 3: Keyboard Navigation (Future)

### Current Implementation
**Not Applicable** - Mobile-first design, no keyboard support

### Future Web Implementation

**Tab Order**:
1. Primary button ("Create Your First Space")
2. (No other focusable elements)

**Keyboard Actions**:
- **Tab**: Focus button (if not already focused)
- **Enter/Space**: Activate button (same as tap)
- **Escape**: No action (no modal open yet)

**Focus Indicator**:
- **Style**: 2px solid outline in primary color
- **Offset**: 2px from button edge
- **Animation**: Fade in (100ms) on focus, fade out (100ms) on blur

**Implementation** (when needed):
```dart
FocusableActionDetector(
  onShowFocusHighlight: (focused) {
    setState(() => _isFocused = focused);
  },
  actions: {
    ActivateIntent: CallbackAction(onInvoke: (_) => _handleCreateSpace()),
  },
  child: PrimaryButton(...),
)
```

---

## Performance Optimization

### Frame Rate Targets
- **Entrance animation**: 60fps sustained
- **Button press**: 60fps sustained
- **Modal transition**: 60fps sustained

### Optimization Techniques

**Hardware Acceleration**:
- All animations use `Transform` (not `Container` size changes)
- Opacity animations use `Opacity` widget (hardware accelerated)
- No layout-triggering animations (no size/position changes)

**Animation Efficiency**:
- Use `flutter_animate` package (optimized animations)
- Const constructors where possible
- Minimal widget rebuilds during animation

**Testing**:
- Monitor with Flutter DevTools Performance tab
- Check for jank (dropped frames)
- Test on low-end devices (iPhone 8, budget Android)

### Low-End Device Considerations

**Fallback Behavior**:
- If frame rate drops below 45fps, consider:
  - Reducing animation duration (faster = fewer frames)
  - Simplifying animation (fade only, no scale)
  - Disabling non-critical animations

**Implementation**:
```dart
// Example: Detect poor performance and adapt
final performance = WidgetsBinding.instance.frameMetrics;
if (performance.averageFrameRate < 45) {
  // Use simpler animations
}
```

---

## Accessibility Considerations

### Motion Sensitivity

**Reduced Motion Support**:
- **System Setting**: iOS/Android "Reduce Motion" preference
- **Detection**: `MediaQuery.of(context).disableAnimations`
- **Behavior**:
  - Entrance animation: Skipped (content appears instantly)
  - Button press: Still animated (essential feedback)
  - Modal transition: Instant (no slide-up)

**Rationale**:
- Entrance animations are decorative (can be skipped)
- Button feedback is functional (should remain)
- Modal transitions can be instant without losing meaning

### Haptic Feedback Accessibility

**User Control**:
- iOS: Settings → Sounds & Haptics → System Haptics
- Android: Settings → Accessibility → Vibration & haptic strength

**Implementation Respect**:
- System settings automatically respected
- No app-level override needed
- `HapticFeedback` APIs honor system preferences

### Animation Testing Checklist

- ✅ Entrance animation skips when "Reduce Motion" enabled
- ✅ Button press animation still works with "Reduce Motion"
- ✅ Modal transition instant with "Reduce Motion"
- ✅ Haptic feedback respects system settings
- ✅ No motion-dependent information (animation is enhancement only)

---

## Design Tokens Reference

### Animation Constants

**From AppAnimations**:
- `gentle` (400ms) - Entrance animation
- `quick` (120ms) - Button press, modal exit
- `instant` (50ms) - Button hover
- `modalEnter` (250ms) - Modal slide-up
- `modalExit` (120ms) - Modal slide-down

**Spring Curves**:
- `gentleSpringCurve` - Entrance animation
- `snappySpringCurve` - Button press
- `bouncySpringCurve` - Button release
- `smoothSpringCurve` - Modal transitions

**Animation Values**:
- `buttonPressScale` (0.96) - Button scale on press
- `modalSlideOffset` (0, 0.15) - Modal slide distance
- `modalScaleStart` (0.95) - Modal initial scale

---

## Related Documentation

- [Screen States](./screen-states.md) - Visual specifications for each state
- [User Journey](./user-journey.md) - Complete interaction flows
- [Accessibility](./accessibility.md) - Accessibility testing procedures
- [Implementation](./implementation.md) - Developer handoff guide

---

**Next Steps**: Review `accessibility.md` for comprehensive accessibility requirements and testing procedures.
