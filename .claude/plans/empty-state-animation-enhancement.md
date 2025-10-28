# Empty State Animation Enhancement Plan

## Objective and Scope

Enhance empty state screens (HomeScreen, TodoListDetailScreen, ListDetailScreen) with engaging animations that guide users to create their first item. The animations will feature:
- Curved arrow pointing from empty state to the FAB/create button
- Pulsing/bouncing animation on the create button
- Smooth entrance animations for the empty state content

This enhancement aims to improve user onboarding and make the "create first item" action more discoverable and inviting.

## Technical Approach and Reasoning

**Animation Library**: Use `flutter_animate` (already in use) for declarative animations with spring physics matching the existing design system.

**Component Architecture**:
- Create a new `AnimatedEmptyState` organism component that wraps the existing `EmptyState`
- Create a reusable `CurvedArrowPointer` atom component for the animated arrow
- Enhance empty state views in HomeScreen, TodoListDetailScreen, and ListDetailScreen
- Add pulsing animation controller to the FAB when displayed in empty state context

**Design Considerations**:
- Use existing `AppAnimations` tokens for consistent timing (gentle spring, normal duration)
- Curved arrow should use a custom painter for smooth Bezier curves
- Pulse animation should be subtle and non-intrusive (scale 1.0 → 1.08 → 1.0)
- Animation should respect `MediaQuery.disableAnimations` for accessibility
- Arrow should adapt to screen size and FAB position

**Integration Pattern**:
- Empty states will conditionally render the animated version on first mount
- Use a flag to prevent showing animation after first dismissal (stored in shared preferences)
- Animation plays once when empty state is first shown, can be dismissed or auto-hides after 10 seconds

## Implementation Phases

### Phase 1: Create Curved Arrow Component
- [x] Task 1.1: Create `CurvedArrowPointer` atom component
  - Create new file `apps/later_mobile/lib/design_system/atoms/indicators/curved_arrow_pointer.dart`
  - Implement `CustomPainter` subclass for drawing curved arrow using `Path.quadraticBezierTo()`
  - Support parameters: `startPosition`, `endPosition`, `color`, `strokeWidth`, `arrowHeadSize`
  - Add entrance animation: fade in + slide along curve path
  - Use `AppAnimations.gentleSpring` for smooth entrance
  - Add arrow head rotation to align with curve tangent at end point

- [x] Task 1.2: Add arrow to design system exports
  - Create `apps/later_mobile/lib/design_system/atoms/indicators/indicators.dart` barrel file
  - Export `CurvedArrowPointer` from barrel file
  - Update `apps/later_mobile/lib/design_system/atoms/atoms.dart` to include indicators

### Phase 2: Create Pulsing Animation for FAB
- [x] Task 2.1: Add pulse animation state to QuickCaptureFab
  - Modified `apps/later_mobile/lib/design_system/molecules/fab/quick_capture_fab.dart`
  - Added optional `enablePulse` boolean parameter (default false)
  - Implemented pulse animation using `flutter_animate` with scale 1.0 → 1.08 → 1.0
  - Pulse animation stops on user interaction or after 10 seconds
  - Used `flutter_animate`'s `.animate().scale()` with repeat and bouncy spring curve
  - Respects reduced motion preferences via `AppAnimations.prefersReducedMotion(context)`

- [x] Task 2.2: Add pulse animation to ResponsiveFab
  - Modified `apps/later_mobile/lib/design_system/organisms/fab/responsive_fab.dart`
  - Converted to StatefulWidget to manage pulse state
  - Added optional `enablePulse` boolean parameter (default false)
  - Passes `enablePulse` to QuickCaptureFab for mobile layout
  - Implemented pulse animation for desktop extended FAB
  - Pulse respects reduced motion preferences

### Phase 3: Create Animated Empty State Component
- [ ] Task 3.1: Create AnimatedEmptyState organism
  - Create new file `apps/later_mobile/lib/design_system/organisms/empty_states/animated_empty_state.dart`
  - Accept `EmptyState` properties plus `fabPosition` and `showArrow` parameters
  - Use `LayoutBuilder` to calculate FAB position relative to empty state
  - Position curved arrow from message text to FAB location (bottom-right)
  - Stagger animations: empty state content (0ms) → arrow (300ms) → FAB pulse (600ms)
  - Add optional dismiss button (X icon) in top-right corner
  - Emit callback when dismissed so parent can update state

- [ ] Task 3.2: Implement animation sequencing
  - Use `flutter_animate`'s delay feature for staggering
  - Empty state: fade in + slight scale (0.95 → 1.0) with `AppAnimations.gentleSpring`
  - Arrow: fade in + draw animation (path progress 0 → 1) with `AppAnimations.smoothSpring`
  - FAB pulse: start after arrow completes, repeat 3-4 times then stop
  - Total sequence duration: ~3 seconds (entrance) + 8 seconds (pulse cycles)

- [ ] Task 3.3: Export animated empty state
  - Update `apps/later_mobile/lib/design_system/organisms/empty_states/empty_states.dart`
  - Export `AnimatedEmptyState`

### Phase 4: Integrate Animations in Home Screen
- [ ] Task 4.1: Update WelcomeState to use animations
  - Modify `apps/later_mobile/lib/design_system/organisms/empty_states/welcome_state.dart`
  - Wrap existing `EmptyState` with animation logic for first-time users
  - Calculate FAB position from screen dimensions (bottom-right: 16px offset)
  - Show animated version on first mount only

- [ ] Task 4.2: Update EmptySpaceState to use animations
  - Modify `apps/later_mobile/lib/design_system/organisms/empty_states/empty_space_state.dart`
  - Add animation support similar to WelcomeState
  - Ensure animation respects user preferences

- [ ] Task 4.3: Connect animations to HomeScreen
  - Modify `apps/later_mobile/lib/widgets/screens/home_screen.dart`
  - Pass `enablePulse: true` to QuickCaptureFab when showing empty state
  - Ensure FAB position is accessible to empty state for arrow calculation
  - Use `GlobalKey` to get FAB position if needed, or calculate from screen size

### Phase 5: Integrate Animations in Detail Screens
- [ ] Task 5.1: Update TodoListDetailScreen empty state
  - Modify `apps/later_mobile/lib/widgets/screens/todo_list_detail_screen.dart`
  - Update `_buildEmptyState()` method to use `AnimatedEmptyState`
  - Enable FAB pulse when list is empty
  - Arrow points to FAB in bottom-right

- [ ] Task 5.2: Update ListDetailScreen empty state
  - Modify `apps/later_mobile/lib/widgets/screens/list_detail_screen.dart`
  - Update `_buildEmptyState()` method to use `AnimatedEmptyState`
  - Enable FAB pulse when list is empty
  - Arrow points to FAB in bottom-right

### Phase 6: Add Persistence and Polish
- [ ] Task 6.1: Add shared preferences for animation state
  - Create utility function to check if animations have been shown
  - Store flag in `SharedPreferences` when animation is dismissed or completed
  - Key format: `animation_shown_{screen_name}` (e.g., `animation_shown_welcome`)
  - Animation shows once per screen type

- [ ] Task 6.2: Add auto-dismiss after duration
  - Implement timer to auto-dismiss animation after 10 seconds
  - Smoothly fade out arrow and stop FAB pulse
  - Mark as completed in preferences

- [ ] Task 6.3: Respect reduced motion preferences
  - Check `MediaQuery.of(context).disableAnimations`
  - If true, skip animations or use instant transitions
  - Ensure arrow still visible but without animation

### Phase 7: Testing and Refinement
- [ ] Task 7.1: Add widget tests for new components
  - Test `CurvedArrowPointer` renders correctly with different positions
  - Test `AnimatedEmptyState` animation sequence
  - Test FAB pulse animation starts and stops correctly
  - Test animation respects reduced motion preferences

- [ ] Task 7.2: Test on different screen sizes
  - Verify arrow position calculates correctly on mobile (small/large)
  - Test on tablet/desktop if applicable
  - Ensure FAB position detection works across breakpoints

- [ ] Task 7.3: Performance testing
  - Verify animations run at 60fps
  - Check memory usage with animation controllers
  - Ensure proper disposal of animation controllers

## Dependencies and Prerequisites

**Existing Dependencies:**
- `flutter_animate: ^4.5.0` - Already in pubspec.yaml
- `shared_preferences` - Need to add for persistence

**New Dependencies:**
- Add `shared_preferences: ^2.2.0` to `apps/later_mobile/pubspec.yaml`

**Design System:**
- Use existing `AppAnimations` tokens for timing and curves
- Use existing `AppColors` for arrow color (gradient-based)
- Use existing `AppSpacing` for positioning

**Files to Create:**
- `apps/later_mobile/lib/design_system/atoms/indicators/curved_arrow_pointer.dart`
- `apps/later_mobile/lib/design_system/atoms/indicators/indicators.dart`
- `apps/later_mobile/lib/design_system/organisms/empty_states/animated_empty_state.dart`
- `apps/later_mobile/lib/core/utils/animation_preferences.dart` (for persistence)

**Files to Modify:**
- `apps/later_mobile/lib/design_system/molecules/fab/quick_capture_fab.dart`
- `apps/later_mobile/lib/design_system/organisms/fab/responsive_fab.dart`
- `apps/later_mobile/lib/design_system/organisms/empty_states/welcome_state.dart`
- `apps/later_mobile/lib/design_system/organisms/empty_states/empty_space_state.dart`
- `apps/later_mobile/lib/design_system/organisms/empty_states/empty_states.dart`
- `apps/later_mobile/lib/design_system/atoms/atoms.dart`
- `apps/later_mobile/lib/widgets/screens/home_screen.dart`
- `apps/later_mobile/lib/widgets/screens/todo_list_detail_screen.dart`
- `apps/later_mobile/lib/widgets/screens/list_detail_screen.dart`
- `apps/later_mobile/pubspec.yaml`

## Challenges and Considerations

**Challenge 1: Accurate FAB Position Calculation**
- FAB position is managed by Flutter's FloatingActionButton positioning
- May need to use `GlobalKey` with `RenderBox` to get precise coordinates
- Alternative: Use fixed offset based on screen size (simpler, less precise)
- Solution: Start with fixed offset approach, use GlobalKey only if needed

**Challenge 2: Arrow Path Calculation**
- Need to draw smooth Bezier curve from empty state text to FAB
- Control points must be calculated based on start/end positions
- Arrow should curve naturally (typically curve upward, then down to FAB)
- Solution: Use quadratic Bezier with control point offset vertically and horizontally

**Challenge 3: Animation Timing Coordination**
- Multiple animations need to be coordinated across components
- FAB pulse in separate widget from empty state
- Need clean communication pattern
- Solution: Use callbacks to trigger FAB pulse from AnimatedEmptyState lifecycle

**Challenge 4: Performance with Custom Painter**
- Custom painting can be expensive if not cached
- Arrow needs to animate smoothly without jank
- Solution: Use `RepaintBoundary` around arrow, cache painter when possible

**Challenge 5: First-Time Experience Detection**
- Need reliable way to detect first-time users vs. returning users
- Should work even if user closes app and returns
- Solution: SharedPreferences with per-screen flags

**Challenge 6: Reduced Motion Accessibility**
- Users with motion sensitivity need alternative experience
- Animations should respect system preferences
- Solution: Check `MediaQuery.disableAnimations`, show static arrow if needed

**Edge Cases:**
- User creates item before animation completes (animation should gracefully exit)
- User switches tabs/spaces during animation (animation should pause/reset)
- Keyboard covers FAB on mobile (arrow should adjust or hide)
- Screen rotation during animation (re-calculate positions)

**Design Decisions:**
- Arrow color: Use theme-aware primary gradient color at 60% opacity for subtlety
- Arrow style: Dashed line with animated dash offset for "drawing" effect
- Pulse scale: 1.08 max (subtle, not distracting)
- Animation duration: 10 seconds total (3s entrance + 7s pulse, then auto-dismiss)
- Dismiss interaction: Tap anywhere on screen or tap explicit X button
