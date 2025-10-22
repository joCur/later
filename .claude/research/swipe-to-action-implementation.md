# Research: Swipe-to-Action Implementation for Later Tasks

## Executive Summary

This research investigates the best swipe-to-action patterns and implementation approaches for the Later mobile app. Based on codebase analysis, industry best practices, and popular task management apps (Todoist, Things, Gmail), the recommended approach is to implement **flutter_slidable** for multi-action swipe gestures with the following primary actions:

**Primary Recommendation:**
- **Left Swipe**: Complete (tasks only) / Archive (notes/lists)
- **Right Swipe**: Delete with confirmation

**Key Findings:**
- The app currently has no swipe actions; items are tap-only
- flutter_slidable is superior to Dismissible for multi-action scenarios
- Users expect 1-2 primary actions per swipe direction for task management apps
- Visual feedback and undo mechanisms are critical for user confidence
- The existing ItemCard component is well-architected for swipe integration

## Research Scope

### What Was Researched
- Current Later app architecture and item card implementation
- Flutter swipe libraries: Dismissible (built-in) vs flutter_slidable
- Mobile UI patterns for swipe actions in task management apps
- Industry standards from Todoist, Things, Gmail, and Material Design
- Accessibility and user experience considerations
- Integration requirements with existing Provider architecture

### What Was Explicitly Excluded
- Complex multi-selection swipe gestures (already handled by long-press)
- Custom swipe libraries (focusing on mature, maintained solutions)
- Desktop-specific swipe implementations (mobile-first approach)

### Research Methodology
1. Analyzed existing Later app codebase structure
2. Web research on Flutter swipe libraries and best practices
3. Studied UX patterns from leading productivity apps
4. Evaluated integration complexity with current architecture

## Current State Analysis

### Existing Implementation

**Item Model Structure:**
- Items have three types: Task, Note, List
- Tasks have `isCompleted` boolean property
- No archival system currently exists (opportunity for future feature)
- Items belong to spaces (workspace concept)

**Current ItemCard Component (lib/widgets/components/cards/item_card.dart):**
- Mobile-first bold design with 2px gradient pill border
- Optimized with RepaintBoundary for 60fps performance
- Existing gesture handlers:
  - `onTap`: Opens detail view
  - `onLongPress`: Multi-select mode
  - `onCheckboxChanged`: Toggle task completion (tasks only)
- Animation support via flutter_animate
- Press state animations already implemented
- Leading element: checkbox for tasks, icon for notes/lists

**Items Provider (lib/providers/items_provider.dart):**
- Supports CRUD operations: `addItem()`, `updateItem()`, `deleteItem()`
- Has `toggleCompletion()` method for tasks
- Implements retry logic with exponential backoff
- Error handling via AppError class

**Home Screen (lib/widgets/screens/home_screen.dart):**
- Displays items in ListView with pagination
- Filter chips for All/Tasks/Notes/Lists
- Pull-to-refresh support
- No swipe actions currently implemented

**Key Observations:**
- ✅ Clean separation of concerns (Provider pattern)
- ✅ Performance-optimized card design
- ✅ Existing animation infrastructure (flutter_animate)
- ✅ Haptic feedback support (AppAnimations.lightHaptic, mediumHaptic)
- ❌ No swipe actions exist yet
- ❌ No archival system (space model has `isArchived` for spaces, not items)
- ❌ No undo/redo system

### Industry Standards

**Material Design Guidelines:**
- Swipe gestures should be discoverable through visual cues
- Provide clear feedback during and after swipe actions
- Support undo for destructive actions
- Limit contextual actions to 1-2 per direction
- Use consistent swipe patterns throughout the app

**Popular Task Management Apps:**

**Todoist:**
- Left swipe: Complete (tasks) with green confirmation
- Right swipe: Configurable (Schedule/Delete/Select)
- Visual icons appear during swipe
- Smooth animations with haptic feedback
- Undo snackbar for completed/deleted tasks

**Things:**
- Swipe right: Complete task
- Swipe left: Move to list / Delete
- Minimal animation, focus on speed
- Confirmation for delete actions

**Gmail:**
- Swipe left/right: Archive (default)
- Customizable per direction (6 options: Archive, Delete, Mark as read/unread, Move to, Snooze, None)
- Snackbar with undo button
- Immediate visual feedback

**Common Patterns:**
- Primary action (complete/archive) on dominant hand side (right for most users)
- Destructive action (delete) requires more deliberate swipe or confirmation
- 1-2 actions per direction maximum
- Visual icons reveal during swipe
- Undo mechanism for reversible actions

## Technical Analysis

### Approach 1: Flutter Dismissible (Built-in)

**Description:**
Flutter's built-in Dismissible widget allows items to be swiped away with a single action per direction. The item is removed from the list when dismissed.

**Pros:**
- ✅ Built into Flutter SDK (no dependencies)
- ✅ Simple API, easy to implement
- ✅ Supports `confirmDismiss` callback for user confirmation
- ✅ Background widget for visual feedback during swipe
- ✅ Direction control (left, right, both, none)
- ✅ Lightweight and performant

**Cons:**
- ❌ Single action per direction only (no multi-action menus)
- ❌ Item is dismissed from list (can't just reveal actions)
- ❌ Less flexible for complex interactions
- ❌ No built-in undo mechanism
- ❌ Limited customization of animation behaviors

**Use Cases:**
- Simple swipe-to-delete scenarios
- Single action per direction (e.g., archive left, delete right)
- Apps where dismissed items don't need to be retained in view

**Code Example:**
```dart
Dismissible(
  key: Key(item.id),
  direction: DismissDirection.horizontal,
  confirmDismiss: (direction) async {
    if (direction == DismissDirection.endToStart) {
      // Delete - show confirmation dialog
      return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Item'),
          content: Text('Are you sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
          ],
        ),
      );
    }
    return true; // Complete/Archive - no confirmation
  },
  background: Container(
    color: Colors.green,
    alignment: Alignment.centerLeft,
    padding: EdgeInsets.only(left: 20),
    child: Icon(Icons.check, color: Colors.white),
  ),
  secondaryBackground: Container(
    color: Colors.red,
    alignment: Alignment.centerRight,
    padding: EdgeInsets.only(right: 20),
    child: Icon(Icons.delete, color: Colors.white),
  ),
  onDismissed: (direction) {
    if (direction == DismissDirection.startToEnd) {
      // Complete/Archive
      itemsProvider.toggleCompletion(item.id);
    } else {
      // Delete
      itemsProvider.deleteItem(item.id);
    }
  },
  child: ItemCard(item: item),
);
```

**Performance:** Excellent - built into Flutter core
**Complexity:** Low - simple to implement
**Maintenance:** Minimal - part of Flutter SDK

### Approach 2: flutter_slidable Package (Recommended)

**Description:**
A Flutter Favorite package that provides slidable list items with directional slide actions. Items slide to reveal action buttons rather than being dismissed.

**Pros:**
- ✅ Multiple actions per direction (up to 3-4 actions visible)
- ✅ Flutter Favorite badge (vetted by Flutter team)
- ✅ Rich animation options (ScrollMotion, DrawerMotion, StretchMotion, BehindMotion)
- ✅ Item remains in list after action (better for undo)
- ✅ Dismissible integration (can combine with swipe-to-delete)
- ✅ Programmatic control via SlidableController
- ✅ Auto-close on scroll
- ✅ Highly customizable
- ✅ Active maintenance (latest update 2024)

**Cons:**
- ❌ External dependency (~145KB)
- ❌ Slightly more complex API than Dismissible
- ❌ Requires understanding of ActionPane concept
- ❌ More configuration needed for simple use cases

**Use Cases:**
- Task management apps with multiple actions
- Apps needing contextual action menus
- Scenarios where items should remain visible after action
- Apps requiring both swipe actions and swipe-to-delete

**Code Example:**
```dart
Slidable(
  key: ValueKey(item.id),
  // Right swipe - Complete/Archive
  startActionPane: ActionPane(
    motion: const StretchMotion(),
    extentRatio: 0.25,
    children: [
      SlidableAction(
        onPressed: (context) {
          if (item.type == ItemType.task) {
            itemsProvider.toggleCompletion(item.id);
          } else {
            // Archive note/list (future feature)
            _showArchiveSnackbar(context, item);
          }
        },
        backgroundColor: item.type == ItemType.task
          ? AppColors.success
          : AppColors.accentBlue,
        foregroundColor: Colors.white,
        icon: item.type == ItemType.task
          ? Icons.check_circle
          : Icons.archive,
        label: item.type == ItemType.task ? 'Complete' : 'Archive',
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
    ],
  ),
  // Left swipe - Delete with confirmation
  endActionPane: ActionPane(
    motion: const ScrollMotion(),
    extentRatio: 0.25,
    dismissible: DismissiblePane(
      onDismissed: () {
        _showDeleteConfirmation(context, item);
      },
      confirmDismiss: () async {
        return await _showDeleteDialog(context);
      },
    ),
    children: [
      SlidableAction(
        onPressed: (context) async {
          final confirmed = await _showDeleteDialog(context);
          if (confirmed == true) {
            itemsProvider.deleteItem(item.id);
            _showUndoSnackbar(context, item);
          }
        },
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        icon: Icons.delete,
        label: 'Delete',
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
    ],
  ),
  child: ItemCard(
    key: ValueKey<String>(item.id),
    item: item,
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => ItemDetailScreen(item: item),
        ),
      );
    },
    onCheckboxChanged: item.type == ItemType.task
        ? (value) {
            itemsProvider.toggleCompletion(item.id);
          }
        : null,
  ),
);
```

**Performance:** Excellent - optimized for Flutter
**Complexity:** Medium - requires understanding of ActionPane/DismissiblePane
**Maintenance:** Low - actively maintained Flutter Favorite package

### Approach 3: Custom Swipe Implementation with GestureDetector

**Description:**
Build a custom swipe solution using Flutter's GestureDetector and AnimationController to create fully customized swipe behaviors.

**Pros:**
- ✅ Complete control over behavior and animations
- ✅ No external dependencies
- ✅ Can integrate perfectly with existing ItemCard animations
- ✅ Maximum flexibility for unique UX requirements

**Cons:**
- ❌ Significant development time (2-3 days)
- ❌ Complex state management for swipe lifecycle
- ❌ Need to handle edge cases (velocity, thresholds, conflicts with scroll)
- ❌ Requires extensive testing across devices
- ❌ Maintenance burden for future updates
- ❌ Risk of bugs and performance issues

**Use Cases:**
- Unique swipe patterns not supported by existing libraries
- Apps with very specific animation requirements
- When bundle size is absolutely critical (rare for mobile)

**Code Example:**
```dart
// Simplified structure - full implementation would be 300+ lines
class SwipeableItemCard extends StatefulWidget {
  final Item item;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  @override
  State<SwipeableItemCard> createState() => _SwipeableItemCardState();
}

class _SwipeableItemCardState extends State<SwipeableItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragExtent = 0.0;

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.primaryDelta!;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    const double threshold = 100.0;
    if (_dragExtent.abs() > threshold) {
      if (_dragExtent > 0) {
        widget.onComplete();
      } else {
        widget.onDelete();
      }
    }
    _resetPosition();
  }

  // ... extensive additional code for animations, thresholds, etc.
}
```

**Performance:** Variable - depends on implementation quality
**Complexity:** High - 300+ lines of code, extensive testing needed
**Maintenance:** High - ongoing maintenance for edge cases and updates

## Tools and Libraries

### Option 1: flutter_slidable

**Purpose:** Slidable list item widget with directional slide actions and dismissible support

**Maturity:** Production-ready (Flutter Favorite)
- Latest version: 3.1.1 (October 2024)
- First released: 2018
- 7+ years of active development
- 2.6k+ stars on GitHub

**License:** MIT License (permissive, commercial-friendly)

**Community:**
- Size: Large (used in many production apps)
- Activity: High (regular updates, responsive maintainer)
- Documentation: Excellent (examples, API docs, migration guides)
- Issues: Well-maintained (quick response to bugs)

**Integration Effort:** Low-Medium
- Installation: Add to pubspec.yaml
- Learning curve: 2-3 hours for full proficiency
- Integration time: 4-6 hours for basic implementation
- Testing time: 2-3 hours

**Key Features:**
- ActionPane with multiple motion types
- DismissiblePane for swipe-to-delete
- Auto-close on scroll
- Programmatic control (SlidableController)
- Customizable flex ratios for actions
- Built-in accessibility support
- Smooth animations (60fps)

**Bundle Size Impact:** ~145KB (minimal impact for mobile apps)

**Dependencies:** None (relies only on Flutter SDK)

### Option 2: Built-in Dismissible Widget

**Purpose:** Simple swipe-to-dismiss widget for single actions

**Maturity:** Production-ready (part of Flutter SDK)
- Included since: Flutter 0.x
- Stable: Yes (part of core Flutter)
- Breaking changes: Rare (follows Flutter versioning)

**License:** BSD-3-Clause (Flutter SDK license)

**Community:**
- Size: Entire Flutter community
- Activity: High (maintained by Flutter team)
- Documentation: Official Flutter docs
- Support: Flutter GitHub, Stack Overflow

**Integration Effort:** Low
- Installation: Already available
- Learning curve: 30 minutes
- Integration time: 1-2 hours
- Testing time: 1 hour

**Key Features:**
- DismissDirection control
- Background/secondaryBackground widgets
- confirmDismiss callback
- onDismissed callback
- resizeDuration for list updates
- movementDuration for swipe animation

**Bundle Size Impact:** 0KB (included in Flutter core)

**Dependencies:** None

## Implementation Considerations

### Technical Requirements

**Dependencies:**
- flutter_slidable: ^3.1.1 (recommended)
- No additional dependencies needed

**Performance Implications:**
- Swipe animations must maintain 60fps on mid-range devices
- ItemCard already uses RepaintBoundary (good foundation)
- Slidable adds minimal overhead (~1-2ms per frame during swipe)
- Use motion types wisely: StretchMotion (smoothest) vs DrawerMotion (heavier)

**Scalability Considerations:**
- Pagination already implemented (loads 100 items initially)
- ListView.builder ensures only visible items are rendered
- Swipe state is per-item (no global state management needed)
- Memory usage: Negligible impact

**Security Aspects:**
- Delete confirmation prevents accidental data loss
- No security implications (local state management only)
- Future sync consideration: Optimistic UI updates with retry

### Integration Points

**How It Fits with Existing Architecture:**

1. **ItemCard Component:**
   - Wrap ItemCard with Slidable widget
   - Keep existing tap/long-press handlers
   - Maintain current animations (press, entrance)
   - Checkbox functionality unchanged

2. **ItemsProvider:**
   - Use existing methods: `toggleCompletion()`, `deleteItem()`
   - No new provider methods needed initially
   - Future: Add `archiveItem()` when archival feature is built

3. **Home Screen:**
   - Replace ItemCard instantiation with Slidable wrapper
   - Add helper methods for confirmation dialogs
   - Implement undo snackbar component
   - No changes to list structure

4. **Theme Integration:**
   - Use AppColors for action backgrounds (success, error, accentBlue)
   - Apply AppSpacing.cardRadius for consistent border radius
   - Match gradient styling where appropriate
   - Use existing haptic feedback (AppAnimations)

**Required Modifications:**

**Minimal Changes:**
- home_screen.dart: Wrap ItemCard with Slidable (15-20 lines)
- Add confirmation dialog helper (30 lines)
- Add undo snackbar component (40 lines)
- Add flutter_slidable to pubspec.yaml (1 line)

**No Changes Needed:**
- ItemCard component (fully compatible)
- ItemsProvider (existing methods suffice)
- Item model (no schema changes)
- Theme system (colors/spacing already defined)

**Database Impacts:**
- None for initial implementation
- Future: Add `isArchived` field to Item model for archival feature

### Risks and Mitigation

**Risk 1: Accidental Actions**
- **Severity:** Medium
- **Likelihood:** High (user education needed)
- **Impact:** User frustration, data loss
- **Mitigation:**
  - Require delete confirmation dialog
  - Implement undo snackbar (7-second window)
  - Visual feedback during swipe (action icon appears)
  - Haptic feedback on action trigger
  - Tutorial overlay on first use (optional)

**Risk 2: Gesture Conflicts**
- **Severity:** Medium
- **Likelihood:** Low (slidable handles this well)
- **Impact:** Swipe doesn't trigger, or wrong action triggers
- **Mitigation:**
  - flutter_slidable auto-handles scroll conflicts
  - Test on various devices (different scroll velocities)
  - Use `closeOnScroll: true` parameter
  - Set appropriate swipe threshold (25% of item width)

**Risk 3: Performance on Low-End Devices**
- **Severity:** Low
- **Likelihood:** Low (flutter_slidable is optimized)
- **Impact:** Choppy animations, poor UX
- **Mitigation:**
  - Use StretchMotion (most performant)
  - Test on low-end Android devices
  - Maintain RepaintBoundary on ItemCard
  - Profile with Flutter DevTools

**Risk 4: Discovery (Users Not Knowing Feature Exists)**
- **Severity:** High
- **Likelihood:** High (hidden interaction)
- **Impact:** Feature underutilization
- **Mitigation:**
  - Add subtle arrow indicators on first 3 items
  - Show tutorial overlay on first app launch
  - Add help section explaining swipe actions
  - Use partial reveal (items slightly offset) on load

**Risk 5: Incomplete Swipes (User Changes Mind Mid-Swipe)**
- **Severity:** Low
- **Likelihood:** Medium
- **Impact:** Confusion about state
- **Mitigation:**
  - Slidable auto-resets on incomplete swipe
  - No action triggered unless fully swiped or tapped
  - Clear threshold (25% = action button appears, 75% = action triggers)

**Fallback Options:**
- If flutter_slidable causes issues: Fall back to Dismissible
- If swipe actions are problematic: Add action buttons to item detail screen
- If users struggle with gestures: Add long-press menu as alternative

## Recommendations

### Recommended Approach: flutter_slidable with Contextual Actions

**Primary Recommendation:**

Implement flutter_slidable with the following action configuration:

**For Tasks:**
- **Right Swipe (startActionPane):** Complete
  - Icon: check_circle
  - Color: AppColors.success (green)
  - Action: `toggleCompletion()`
  - No confirmation needed
  - Haptic: medium

- **Left Swipe (endActionPane):** Delete
  - Icon: delete
  - Color: AppColors.error (red)
  - Action: `deleteItem()` with confirmation
  - Requires confirmation dialog
  - Haptic: medium

**For Notes/Lists:**
- **Right Swipe (startActionPane):** Archive (future feature placeholder)
  - Icon: archive
  - Color: AppColors.accentBlue
  - Action: Show "Archive coming soon" snackbar
  - No confirmation needed
  - Haptic: light

- **Left Swipe (endActionPane):** Delete
  - Same as tasks

**Why This Approach:**
1. **Best of Both Worlds:** Multi-action support + swipe-to-delete
2. **Flutter Favorite:** Vetted by Flutter team, production-ready
3. **Minimal Dependencies:** Only 145KB, well-maintained
4. **Industry Standard:** Matches Todoist/Things patterns
5. **Easy Integration:** Works seamlessly with existing ItemCard
6. **Performance:** Optimized for 60fps animations
7. **Accessibility:** Built-in support, keyboard-friendly
8. **Future-Proof:** Supports adding more actions later

**Alternative Approach (If Constraints Change):**

If bundle size is critical or multi-action isn't needed, use **Dismissible** with:
- Right swipe: Complete/Archive (no confirmation)
- Left swipe: Delete (with confirmation dialog)

**Phased Implementation Strategy:**

**Phase 1: Core Swipe Actions (1 sprint / 2 weeks)**
- Add flutter_slidable dependency
- Implement basic swipe-to-complete (tasks)
- Implement swipe-to-delete (all types)
- Add confirmation dialog for delete
- Add undo snackbar
- Basic testing

**Phase 2: Polish & Discovery (1 sprint / 1 week)**
- Add tutorial overlay for first-time users
- Implement haptic feedback
- Add arrow hint indicators
- Performance testing on low-end devices
- Accessibility testing

**Phase 3: Advanced Features (future)**
- Implement archival system for notes/lists
- Add more contextual actions (move to space, set due date)
- Customizable swipe actions (settings)
- Gesture analytics to improve UX

**Success Metrics:**
- 60fps animations on mid-range devices (Pixel 4a, iPhone 11)
- <5% accidental deletions (tracked via undo usage)
- 40%+ users discover and use swipe within first week
- 0 critical bugs in gesture handling

## References

### Documentation
- [Flutter Dismissible Widget](https://docs.flutter.dev/cookbook/gestures/dismissible)
- [flutter_slidable Package](https://pub.dev/packages/flutter_slidable)
- [flutter_slidable Examples](https://pub.dev/packages/flutter_slidable/example)
- [Dart API: Slidable Class](https://pub.dev/documentation/flutter_slidable/latest/flutter_slidable/Slidable-class.html)

### Design Guidelines
- [Material Design: Swipe to Delete](https://m3.material.io/components/lists/guidelines#dismissible)
- [LogRocket: Designing Swipe-to-Delete Interactions](https://blog.logrocket.com/ux-design/accessible-swipe-contextual-action-triggers/)
- [Oracle Alta Mobile: Contextual Actions](https://www.oracle.com/webfolder/ux/mobile/pattern/contextualactions.html)

### Productivity Apps Research
- [Todoist: Swipe Actions Help](https://www.todoist.com/help/articles/how-to-change-your-swipe-actions-D5DQOQz6)
- [Gmail: Customize Swipe Actions](https://android.gadgethacks.com/how-to/customize-gmails-swipe-actions-so-theyre-not-just-delete-archive-0185191/)
- [Medium: Flutter Package of the Day - Slidable](https://medium.com/@sajjadmakman/flutter-package-of-the-day-slidable-26f68e2c870b)

### Best Practices Articles
- [DartLing: Swipe Actions in Flutter with Dismissible](https://dartling.dev/swipe-actions-flutter-dismissible-widget)
- [OnlyFlutter: How to Dismiss Widgets in Flutter](https://onlyflutter.com/how-to-dismiss-widgets-in-flutter/)
- [JustinMind: Mobile Gestures - Tap or Swipe](https://www.justinmind.com/blog/tap-or-swipe-mobile-gestures-which-one-should-you-design-with/)

### Code Examples
- [Medium: Flutter Swipe to Delete](https://medium.com/easy-flutter/swipe-to-delete-in-flutter-with-dismissible-c18d1f478066)
- [Stack Overflow: Swipe List Item for More Options](https://stackoverflow.com/questions/46651974/swipe-list-item-for-more-options-flutter)
- [Dev.to: Dismissible Widget - Slide to Delete](https://dev.to/aakashp/dismissible-widget-slide-to-delete-in-flutter-hnf)

## Appendix

### Additional Notes

**Observations During Research:**
1. Later app has excellent architecture for swipe integration - no major refactoring needed
2. ItemCard component is already performance-optimized (RepaintBoundary, animations)
3. No archival system exists yet - perfect opportunity to add with swipe
4. Existing haptic feedback infrastructure makes polish easier
5. Pagination system means swipe performance won't degrade with large lists

**Questions for Further Investigation:**
1. Should archive feature be added before swipe implementation?
   - **Recommendation:** No - add placeholder action, implement archive later
2. Should swipe actions be customizable by users?
   - **Recommendation:** Not in v1 - complexity vs benefit unclear
3. Should completed tasks stay in list or auto-hide?
   - **Recommendation:** Stay visible with 70% opacity (already implemented)
4. How to handle swipe on items with long-press multi-select?
   - **Recommendation:** Swipe disabled in multi-select mode

**Related Topics Worth Exploring:**
- Batch actions (swipe multiple selected items)
- Swipe sensitivity customization (accessibility)
- Gesture tutorials and onboarding best practices
- Animation performance profiling with Flutter DevTools
- A/B testing swipe patterns (complete left vs right)

### Implementation Checklist

When proceeding to implementation, use this checklist:

**Pre-Implementation:**
- [ ] Review ItemCard component thoroughly
- [ ] Test current tap/long-press behavior
- [ ] Create design mockups for swipe states
- [ ] Define color scheme for actions

**Implementation:**
- [ ] Add flutter_slidable to pubspec.yaml
- [ ] Create SwipeableItemCard wrapper component
- [ ] Implement complete action (tasks)
- [ ] Implement delete action (all types)
- [ ] Add confirmation dialog for delete
- [ ] Implement undo snackbar component
- [ ] Add haptic feedback on actions
- [ ] Add visual feedback (icons appear during swipe)
- [ ] Test on Android and iOS

**Polish:**
- [ ] Add tutorial overlay for first launch
- [ ] Add arrow hint indicators
- [ ] Test on low-end devices (performance)
- [ ] Test with screen readers (accessibility)
- [ ] Add analytics events for swipe usage
- [ ] Write unit tests for swipe actions
- [ ] Write widget tests for Slidable integration

**Documentation:**
- [ ] Update user-facing help docs
- [ ] Add swipe actions to onboarding
- [ ] Document code with inline comments
- [ ] Create demo video for stakeholders

**Future Considerations:**
- [ ] Implement archival system
- [ ] Add more contextual actions
- [ ] Consider customizable swipe settings
- [ ] Explore batch swipe actions
