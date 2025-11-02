---
title: Drag Handle Implementation Guide
description: Flutter implementation guidelines for the drag handle component
feature: drag-handle-reordering
last-updated: 2025-11-02
version: 1.0.0
related-files:
  - ./README.md
  - ./visual-specifications.md
  - ./interaction-specifications.md
dependencies:
  - Flutter SDK 3.9.2+
  - flutter_animate package
  - Design system tokens
status: approved
---

# Drag Handle Implementation Guide

## Implementation Overview

This guide provides detailed Flutter implementation guidelines for creating the `DragHandleWidget` atomic component and integrating it into content cards (TodoListCard, NoteCard, ListCard).

## Component Structure

### File Organization
```
lib/
├── design_system/
│   └── atoms/
│       └── drag_handle/
│           ├── drag_handle_widget.dart       # Main component
│           └── grip_dots_painter.dart        # Custom painter (if needed)
└── design_system/
    └── organisms/
        └── cards/
            ├── todo_list_card.dart           # Updated with handle
            ├── note_card.dart                # Updated with handle
            └── list_card.dart                # Updated with handle
```

### Component Hierarchy
```
DragHandleWidget (Atom)
  └─ MouseRegion (Desktop hover)
      └─ Semantics (Accessibility)
          └─ AnimatedOpacity (State transitions)
              └─ AnimatedScale (Drag animation)
                  └─ Container (48×48px touch target)
                      └─ _buildGripDots() (20×24px icon)
```

---

## DragHandleWidget Implementation

### Basic Component Structure

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

/// Drag handle widget for content card reordering
///
/// Provides a visual affordance for drag-and-drop reordering with:
/// - 48×48px touch target (WCAG AA compliant)
/// - Type-specific gradient coloring
/// - State transitions (default → hover → active)
/// - Haptic feedback on mobile
/// - Keyboard accessibility
class DragHandleWidget extends StatefulWidget {
  const DragHandleWidget({
    super.key,
    required this.gradient,
    this.isActive = false,
    this.onDragStart,
    this.enabled = true,
    this.semanticLabel,
  });

  /// Gradient to apply to handle (type-specific: task, note, list)
  final LinearGradient gradient;

  /// Whether the handle is in active drag state
  final bool isActive;

  /// Callback when drag starts (for haptic feedback)
  final VoidCallback? onDragStart;

  /// Whether the handle is enabled (shows/hides handle)
  final bool enabled;

  /// Semantic label for screen readers
  final String? semanticLabel;

  @override
  State<DragHandleWidget> createState() => _DragHandleWidgetState();
}

class _DragHandleWidgetState extends State<DragHandleWidget> {
  bool _isHovered = false;

  /// Get current opacity based on state
  double get _opacity {
    if (!widget.enabled) return 0.0;
    if (widget.isActive) return 1.0;
    if (_isHovered) return 0.6;
    return 0.4;
  }

  /// Get current scale based on state
  double get _scale {
    if (widget.isActive) return 1.05;
    return 1.0;
  }

  /// Get cursor based on state
  SystemMouseCursor get _cursor {
    if (!widget.enabled) return SystemMouseCursors.basic;
    if (widget.isActive) return SystemMouseCursors.grabbing;
    if (_isHovered) return SystemMouseCursors.grab;
    return SystemMouseCursors.basic;
  }

  @override
  Widget build(BuildContext context) {
    // Don't render if disabled
    if (!widget.enabled) {
      return const SizedBox.shrink();
    }

    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final animationDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 150);

    return MouseRegion(
      cursor: _cursor,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Semantics(
        button: true,
        enabled: widget.enabled,
        label: widget.semanticLabel ?? 'Drag to reorder',
        hint: 'Use arrow keys to move up or down',
        child: AnimatedOpacity(
          duration: animationDuration,
          opacity: _opacity,
          child: AnimatedScale(
            duration: animationDuration,
            scale: _scale,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: _buildGripDots(),
            ),
          ),
        ),
      ),
    );
  }

  /// Build the grip dots icon (3 rows × 2 columns)
  Widget _buildGripDots() {
    return SizedBox(
      width: 20,
      height: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDotRow(),
          const SizedBox(height: 6),
          _buildDotRow(),
          const SizedBox(height: 6),
          _buildDotRow(),
        ],
      ),
    );
  }

  /// Build a single row of dots (2 dots, 4px apart)
  Widget _buildDotRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(),
        const SizedBox(width: 4),
        _buildDot(),
      ],
    );
  }

  /// Build a single dot (4×4px with gradient)
  Widget _buildDot() {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: widget.gradient,
      ),
    );
  }
}
```

---

## Integration into Card Components

### Step 1: Add Drag Handle to Card Layout

Update each card component (TodoListCard, NoteCard, ListCard) to include the drag handle:

```dart
// In todo_list_card.dart, note_card.dart, list_card.dart

/// Build the card content row with drag handle
Widget _buildContentRow(BuildContext context) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Leading icon (48×48px)
      _buildLeadingIcon(),

      const SizedBox(width: AppSpacing.xs), // 8px

      // Content area (expandable)
      Expanded(
        child: _buildContent(),
      ),

      // Drag handle (48×48px) - NEW
      DragHandleWidget(
        gradient: _getBorderGradient(),
        isActive: _isDragging,
        enabled: widget.enableReordering ?? true,
        semanticLabel: _getDragSemanticLabel(),
        onDragStart: () {
          // Haptic feedback on drag start
          HapticFeedback.lightImpact();
          setState(() => _isDragging = true);
        },
      ),
    ],
  );
}

/// Get semantic label for drag handle
String _getDragSemanticLabel() {
  // For TodoListCard
  return 'Drag to reorder todo list: ${widget.todoList.name}';

  // For NoteCard
  // return 'Drag to reorder note: ${widget.item.title}';

  // For ListCard
  // return 'Drag to reorder list: ${widget.list.name}';
}
```

### Step 2: Update ReorderableDragStartListener Wrapping

**Current Implementation (Entire Card)**:
```dart
// In home_screen.dart
return ReorderableDragStartListener(
  key: ValueKey<String>(_getItemId(item)),
  index: index,
  child: card, // Entire card is draggable
);
```

**New Implementation (Handle Only)**:
```dart
// In card component
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: widget.onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardSpacing),
      child: GradientPillBorder(
        gradient: _getBorderGradient(),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPaddingMobile),
          child: Row(
            children: [
              _buildLeadingIcon(),
              SizedBox(width: AppSpacing.xs),
              Expanded(child: _buildContent()),

              // Wrap ONLY the handle with ReorderableDragStartListener
              ReorderableDragStartListener(
                key: ValueKey('handle-${_getItemId()}'),
                index: widget.index,
                child: DragHandleWidget(
                  gradient: _getBorderGradient(),
                  isActive: _isDragging,
                  semanticLabel: _getDragSemanticLabel(),
                  onDragStart: _handleDragStart,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _handleDragStart() {
  HapticFeedback.lightImpact();
  setState(() => _isDragging = true);
}
```

### Step 3: Add Drag State Management

Add drag state tracking to each card component:

```dart
class _TodoListCardState extends State<TodoListCard> {
  // Existing state
  bool _isPressed = false;
  late AnimationController _pressAnimationController;

  // NEW: Drag state
  bool _isDragging = false;

  // Listen to drag events from ReorderableListView
  @override
  void didUpdateWidget(TodoListCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset drag state when drag ends
    if (_isDragging) {
      // Drag ended, reset state
      Future.microtask(() {
        if (mounted) {
          setState(() => _isDragging = false);
        }
      });
    }
  }
}
```

---

## HomeScreen Integration

### Update ReorderableListView Configuration

```dart
// In home_screen.dart

Widget _buildContentList(...) {
  return ReorderableListView.builder(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    itemCount: itemCount,

    // IMPORTANT: Disable default drag handles
    buildDefaultDragHandles: false,

    onReorder: (oldIndex, newIndex) async {
      if (_isReordering) return;

      setState(() => _isReordering = true);

      try {
        await contentProvider.reorderContent(
          _selectedFilter,
          oldIndex,
          newIndex,
        );

        // Haptic feedback on successful reorder
        HapticFeedback.mediumImpact();
      } finally {
        if (mounted) {
          setState(() => _isReordering = false);
        }
      }
    },

    itemBuilder: (context, index) {
      final item = content[index];

      // Build card with integrated handle
      // (no ReorderableDragStartListener wrapper here)
      return _buildContentCard(item, index);
    },
  );
}

Widget _buildContentCard(dynamic item, int index) {
  if (item is TodoList) {
    return TodoListCard(
      key: ValueKey('todo-${item.id}'),
      todoList: item,
      index: index,
      enableReordering: true, // NEW: Pass reordering state
      onTap: () => _navigateToDetail(item),
    );
  } else if (item is Item) {
    return NoteCard(
      key: ValueKey('note-${item.id}'),
      item: item,
      index: index,
      enableReordering: true, // NEW
      onTap: () => _navigateToDetail(item),
    );
  } else if (item is ListModel) {
    return ListCard(
      key: ValueKey('list-${item.id}'),
      list: item,
      index: index,
      enableReordering: true, // NEW
      onTap: () => _navigateToDetail(item),
    );
  }

  return const SizedBox.shrink();
}
```

---

## Card Component Updates

### Add enableReordering Parameter

Update each card component to accept `enableReordering`:

```dart
class TodoListCard extends StatefulWidget {
  const TodoListCard({
    super.key,
    required this.todoList,
    this.onTap,
    this.onLongPress,
    this.showMetadata = true,
    this.index,
    this.enableReordering = true, // NEW
  });

  // Existing parameters...

  /// Whether to show drag handle for reordering
  final bool enableReordering;
}
```

### Pass Index to ReorderableDragStartListener

Ensure each card has access to its index:

```dart
class TodoListCard extends StatefulWidget {
  const TodoListCard({
    super.key,
    required this.todoList,
    this.index, // Required for reordering
    // ...
  });

  /// Index in the list for reordering
  /// If null, drag handle is hidden
  final int? index;
}
```

---

## Keyboard Navigation Implementation

### Focus Management

Add focus handling to `DragHandleWidget`:

```dart
class _DragHandleWidgetState extends State<DragHandleWidget> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: MouseRegion(
        // ... existing code
        child: Container(
          decoration: _focusNode.hasFocus
              ? BoxDecoration(
                  border: Border.all(
                    color: AppColors.focus(context),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                )
              : null,
          child: _buildHandle(),
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      // Arrow keys for reordering
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        widget.onKeyboardReorder?.call(-1); // Move up
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        widget.onKeyboardReorder?.call(1); // Move down
        return KeyEventResult.handled;
      }

      // Enter/Space to open card
      else if (event.logicalKey == LogicalKeyboardKey.enter ||
               event.logicalKey == LogicalKeyboardKey.space) {
        widget.onTap?.call();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }
}
```

### Keyboard Reorder Callback

Add keyboard reorder callback to card components:

```dart
// In card component
ReorderableDragStartListener(
  index: widget.index,
  child: DragHandleWidget(
    gradient: _getBorderGradient(),
    onKeyboardReorder: (direction) {
      // direction: -1 (up) or 1 (down)
      final newIndex = widget.index + direction;
      if (newIndex >= 0 && newIndex < totalItemCount) {
        // Trigger reorder
        widget.onReorder?.call(widget.index, newIndex);
      }
    },
  ),
)
```

---

## Performance Optimizations

### RepaintBoundary Isolation

Wrap drag handle in `RepaintBoundary` to isolate repaints:

```dart
Widget _buildDragHandle() {
  return RepaintBoundary(
    child: ReorderableDragStartListener(
      index: widget.index,
      child: DragHandleWidget(
        gradient: _getBorderGradient(),
        // ...
      ),
    ),
  );
}
```

### Const Constructors

Use const constructors wherever possible:

```dart
const SizedBox(height: 6),
const SizedBox(width: 4),
BorderRadius.circular(2), // Cache this
```

### Gradient Caching

Cache gradient instances to avoid recreation:

```dart
class _TodoListCardState extends State<TodoListCard> {
  late final LinearGradient _cachedGradient;

  @override
  void initState() {
    super.initState();
    _cachedGradient = AppColors.taskGradient;
  }

  LinearGradient _getBorderGradient() {
    return _cachedGradient;
  }
}
```

---

## Accessibility Implementation

### Semantic Labels

Provide descriptive semantic labels:

```dart
DragHandleWidget(
  gradient: AppColors.taskGradient,
  semanticLabel: 'Drag to reorder todo list: ${todoList.name}',
  // ...
)
```

### Screen Reader Support

Ensure proper ARIA-like semantics:

```dart
Semantics(
  button: true,
  enabled: widget.enabled,
  label: widget.semanticLabel,
  hint: 'Use arrow keys to move up or down. Press Enter to open.',
  onTap: widget.onTap,
  child: _buildHandle(),
)
```

### Focus Indicator

Provide clear focus indicator:

```dart
Container(
  decoration: _isFocused
      ? BoxDecoration(
          border: Border.all(
            color: AppColors.focus(context),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        )
      : null,
  child: _buildHandle(),
)
```

---

## Testing Guidelines

### Unit Tests

Test drag handle component in isolation:

```dart
// test/design_system/atoms/drag_handle/drag_handle_widget_test.dart

void main() {
  group('DragHandleWidget', () {
    testWidgets('renders with correct size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DragHandleWidget(
              gradient: AppColors.taskGradient,
            ),
          ),
        ),
      );

      final handle = find.byType(DragHandleWidget);
      expect(handle, findsOneWidget);

      final size = tester.getSize(handle);
      expect(size.width, 48.0);
      expect(size.height, 48.0);
    });

    testWidgets('transitions opacity on hover', (tester) async {
      // Test opacity transitions
    });

    testWidgets('has correct semantic label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DragHandleWidget(
              gradient: AppColors.taskGradient,
              semanticLabel: 'Drag to reorder test item',
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Drag to reorder test item'),
        findsOneWidget,
      );
    });
  });
}
```

### Integration Tests

Test drag-and-drop reordering:

```dart
// test/widgets/screens/home_screen_integration_test.dart

void main() {
  testWidgets('can reorder cards via drag handle', (tester) async {
    // Setup test data
    final testItems = [/* ... */];

    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Find first card's drag handle
    final firstHandle = find.byKey(ValueKey('handle-todo-1'));
    expect(firstHandle, findsOneWidget);

    // Drag first card down by 100px
    await tester.drag(firstHandle, Offset(0, 100));
    await tester.pumpAndSettle();

    // Verify reorder occurred
    expect(find.text('First Item'), findsNothing); // Moved out of view
  });
}
```

### Accessibility Tests

Test keyboard navigation and focus:

```dart
testWidgets('keyboard navigation works', (tester) async {
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle();

  // Tab to first handle
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pumpAndSettle();

  // Verify focus indicator
  final focusedHandle = find.byWidgetPredicate(
    (widget) => widget is Container && widget.decoration != null,
  );
  expect(focusedHandle, findsOneWidget);

  // Press arrow down to reorder
  await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
  await tester.pumpAndSettle();

  // Verify reorder occurred
  // (check item positions)
});
```

---

## Migration Checklist

### Phase 1: Component Creation
- [ ] Create `DragHandleWidget` in `design_system/atoms/drag_handle/`
- [ ] Implement grip dots layout (3 rows × 2 columns)
- [ ] Add gradient application via `ShaderMask` or `Container`
- [ ] Implement opacity state transitions (default/hover/active)
- [ ] Add cursor changes for desktop/web
- [ ] Add semantic labels and focus indicators

### Phase 2: Card Integration
- [ ] Add `enableReordering` parameter to card components
- [ ] Add `index` parameter to card components
- [ ] Integrate `DragHandleWidget` into card layout (trailing position)
- [ ] Wrap handle with `ReorderableDragStartListener`
- [ ] Add drag state management (`_isDragging`)
- [ ] Add haptic feedback on drag start

### Phase 3: HomeScreen Updates
- [ ] Set `buildDefaultDragHandles: false` in `ReorderableListView`
- [ ] Pass `index` and `enableReordering` to card components
- [ ] Remove outer `ReorderableDragStartListener` wrapper
- [ ] Add haptic feedback on reorder success
- [ ] Test gesture priority (handle vs card tap vs scroll)

### Phase 4: Accessibility
- [ ] Add keyboard navigation (arrow keys, Enter, ESC)
- [ ] Add focus management and focus indicators
- [ ] Add semantic labels for screen readers
- [ ] Test with TalkBack/VoiceOver
- [ ] Verify WCAG 2.1 AA compliance

### Phase 5: Testing & Polish
- [ ] Write unit tests for `DragHandleWidget`
- [ ] Write integration tests for drag-and-drop reordering
- [ ] Test on multiple devices (iOS, Android, Web)
- [ ] Test with `prefers-reduced-motion` enabled
- [ ] Conduct user testing for discoverability
- [ ] Iterate based on feedback

---

## Common Pitfalls & Solutions

### Pitfall 1: Gesture Conflicts
**Problem**: Card tap fires when dragging handle
**Solution**: Wrap only handle with `ReorderableDragStartListener`, not entire card

### Pitfall 2: Handle Hidden Behind Content
**Problem**: Handle is obscured by content overflow
**Solution**: Use `CrossAxisAlignment.start` and ensure handle is last in row

### Pitfall 3: Poor Performance
**Problem**: Repaints on every drag movement
**Solution**: Use `RepaintBoundary` around handle and cache gradients

### Pitfall 4: Accessibility Issues
**Problem**: Screen readers don't announce drag affordance
**Solution**: Add `Semantics` widget with descriptive labels and hints

### Pitfall 5: Dark Mode Contrast
**Problem**: Handle not visible in dark mode
**Solution**: Use theme-adaptive gradients from `TemporalFlowTheme`

---

## Code Examples Repository

Complete code examples are available in:
- `design_system/atoms/drag_handle/drag_handle_widget.dart`
- `design_system/organisms/cards/todo_list_card.dart` (reference implementation)

---

## Support & Questions

For implementation questions or issues:
1. Review this guide and related specifications
2. Check existing card implementations for patterns
3. Consult Flutter's `ReorderableListView` documentation
4. Test accessibility with screen readers and keyboard navigation

---

## Approval & Sign-Off

**Implementation Status**: Ready for Development
**Last Updated**: 2025-11-02
**Version**: 1.0.0

**Next Steps**:
1. Create `DragHandleWidget` component
2. Integrate into one card type (TodoListCard) for testing
3. Validate accessibility and performance
4. Roll out to remaining card types (NoteCard, ListCard)
5. Conduct user testing and iterate
