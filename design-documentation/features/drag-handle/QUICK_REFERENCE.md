---
title: Drag Handle Quick Reference Guide
description: One-page cheat sheet for implementing the drag handle component
feature: drag-handle-reordering
last-updated: 2025-11-02
version: 1.0.0
status: approved
---

# Drag Handle Quick Reference Guide

> **TL;DR**: Add a 48×48px grip dot handle to the right side of cards with type-specific gradients and 40% → 60% → 100% opacity states.

---

## Visual Specifications (At a Glance)

```
┌─────────────────────────────────────┐
│ Card with Drag Handle               │
│  [Icon] Content Text          [:::] │  ← 48×48px handle
│                               [:::] │
│                               [:::] │
└─────────────────────────────────────┘

Handle Icon (Grip Dots):
● ●  ← 4px dots, 4px apart
● ●  ← 6px vertical spacing
● ●

Touch Target: 48×48px (WCAG AA)
Visible Icon: 20×24px (centered)
Dot Size: 4×4px (2px border radius)
```

---

## Quick Specs Table

| Property | Value | Notes |
|----------|-------|-------|
| **Touch Target** | 48×48px | WCAG AA compliant |
| **Icon Size** | 20×24px | Visible grip dots |
| **Placement** | Right side (trailing) | Top-aligned with icon |
| **Dot Size** | 4×4px each | 6 dots total (3 rows × 2 cols) |
| **Dot Spacing** | 4px horizontal, 6px vertical | |
| **Dot Radius** | 2px | Subtle rounding |
| **Gradients** | Task: Red-Orange<br>Note: Blue-Cyan<br>List: Purple | Type-specific |
| **Opacity (Default)** | 40% (0.4) | Subtle presence |
| **Opacity (Hover)** | 60% (0.6) | Desktop/web only |
| **Opacity (Active)** | 100% (1.0) | During drag |
| **Scale (Active)** | 1.05 | Subtle lift |
| **Animation Duration** | 150ms | Ease-out |

---

## Color Gradients

```dart
// Type-specific gradients
TodoListCard → AppColors.taskGradient  // Red-Orange
NoteCard     → AppColors.noteGradient  // Blue-Cyan
ListCard     → AppColors.listGradient  // Purple-Lavender
```

---

## State Transitions

```
Default (40%) ──[Hover]──> Hover (60%) ──[Drag]──> Active (100%)
     ↑                          ↓                        ↓
     └──────────────────────────┴────────────────────────┘
                        [Release/Cancel]
```

| State | Opacity | Scale | Cursor | Haptic |
|-------|---------|-------|--------|--------|
| **Default** | 40% | 1.0 | basic | - |
| **Hover** | 60% | 1.0 | grab | - |
| **Active** | 100% | 1.05 | grabbing | Light impact |
| **Disabled** | 0% | - | basic | - |

---

## Implementation Checklist

### Step 1: Create Component
```dart
// lib/design_system/atoms/drag_handle/drag_handle_widget.dart
class DragHandleWidget extends StatefulWidget {
  const DragHandleWidget({
    required this.gradient,
    this.isActive = false,
    this.enabled = true,
    this.semanticLabel,
  });
}
```

### Step 2: Add to Card Layout
```dart
Row(
  children: [
    _buildLeadingIcon(),           // 48×48px icon
    SizedBox(width: 8),
    Expanded(child: _buildContent()),
    DragHandleWidget(              // 48×48px handle
      gradient: AppColors.taskGradient,
      semanticLabel: 'Drag to reorder ${item.name}',
    ),
  ],
)
```

### Step 3: Wrap Handle Only
```dart
// Wrap ONLY the handle, not the entire card
ReorderableDragStartListener(
  index: index,
  child: DragHandleWidget(...),
)
```

### Step 4: Update HomeScreen
```dart
ReorderableListView.builder(
  buildDefaultDragHandles: false, // IMPORTANT!
  onReorder: (old, new) => _handleReorder(old, new),
  itemBuilder: (ctx, idx) => _buildCard(idx),
)
```

---

## Code Snippets

### Grip Dots Implementation
```dart
Widget _buildGripDots() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildDotRow(),
      SizedBox(height: 6),
      _buildDotRow(),
      SizedBox(height: 6),
      _buildDotRow(),
    ],
  );
}

Widget _buildDotRow() {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildDot(),
      SizedBox(width: 4),
      _buildDot(),
    ],
  );
}

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
```

### Opacity State Management
```dart
double get _opacity {
  if (!widget.enabled) return 0.0;
  if (widget.isActive) return 1.0;
  if (_isHovered) return 0.6;
  return 0.4;
}
```

### Haptic Feedback
```dart
void _handleDragStart() {
  HapticFeedback.lightImpact();
  setState(() => _isDragging = true);
}

void _handleReorderSuccess() {
  HapticFeedback.mediumImpact();
}
```

---

## Accessibility Quick Check

- [x] **Touch Target**: 48×48px ✓
- [x] **Contrast (Default)**: 3:1+ ✓
- [x] **Contrast (Hover)**: 4.5:1+ ✓
- [x] **Focus Indicator**: 2px, 4.5:1+ ✓
- [x] **Semantic Label**: "Drag to reorder [item]" ✓
- [x] **Keyboard Navigation**: Arrow keys ✓
- [x] **Screen Reader**: VoiceOver/TalkBack ✓
- [x] **Reduced Motion**: Instant transitions ✓

---

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| **Tab** | Focus next handle |
| **Shift+Tab** | Focus previous handle |
| **Arrow Up** | Move item up |
| **Arrow Down** | Move item down |
| **Enter** | Open card detail |
| **Space** | Open card detail |
| **ESC** | Cancel drag |

---

## Common Pitfalls

### ❌ DON'T: Wrap entire card
```dart
// WRONG
ReorderableDragStartListener(
  index: index,
  child: TodoListCard(...), // Entire card
)
```

### ✓ DO: Wrap handle only
```dart
// CORRECT
TodoListCard(
  child: Row([
    Icon(),
    Content(),
    ReorderableDragStartListener(
      index: index,
      child: DragHandleWidget(...), // Handle only
    ),
  ]),
)
```

### ❌ DON'T: Use horizontal grip bars
```
═══  ← Wrong (horizontal)
═══
═══
```

### ✓ DO: Use vertical grip dots
```
● ●  ← Correct (vertical)
● ●
● ●
```

### ❌ DON'T: Place on left side
```
[:::] [Icon] Content  ← Blocks icon, interferes with scrolling
```

### ✓ DO: Place on right side
```
[Icon] Content [:::] ← Clear affordance, no conflicts
```

---

## Testing Quick Commands

```bash
# Run widget tests
flutter test test/design_system/atoms/drag_handle/

# Run accessibility tests
flutter test --coverage test/accessibility/

# Test with screen reader (iOS)
# 1. Enable VoiceOver: Settings → Accessibility → VoiceOver
# 2. Swipe to navigate to handle
# 3. Verify announcement

# Test with screen reader (Android)
# 1. Enable TalkBack: Settings → Accessibility → TalkBack
# 2. Swipe to navigate to handle
# 3. Verify announcement
```

---

## Performance Tips

```dart
// 1. Cache gradients
late final LinearGradient _cachedGradient = AppColors.taskGradient;

// 2. Use RepaintBoundary
RepaintBoundary(
  child: DragHandleWidget(...),
)

// 3. Const constructors
const SizedBox(height: 6),
const SizedBox(width: 4),

// 4. Reduce motion support
final duration = MediaQuery.of(context).disableAnimations
  ? Duration.zero
  : Duration(milliseconds: 150);
```

---

## File Locations

```
lib/
├── design_system/
│   └── atoms/
│       └── drag_handle/
│           └── drag_handle_widget.dart  ← Create this
└── widgets/
    └── screens/
        └── home_screen.dart             ← Update this

design-documentation/
└── features/
    └── drag-handle/
        ├── README.md                    ← Overview
        ├── visual-specifications.md     ← Visual details
        ├── interaction-specifications.md ← Interactions
        ├── implementation-guide.md      ← Code guide
        ├── accessibility.md             ← A11y specs
        └── QUICK_REFERENCE.md          ← This file
```

---

## Design Token Reference

```dart
// Spacing
AppSpacing.xxs     // 4px (dot spacing)
AppSpacing.xs      // 8px (icon-content gap)

// Colors
AppColors.taskGradient   // TodoList: Red-Orange
AppColors.noteGradient   // Note: Blue-Cyan
AppColors.listGradient   // List: Purple-Lavender
AppColors.focusLight     // Focus indicator (light)
AppColors.focusDark      // Focus indicator (dark)

// Animation
Duration(milliseconds: 150)  // Opacity transitions
Duration(milliseconds: 100)  // Scale animations
Curves.easeOut               // Easing function
Curves.easeOutBack           // Spring-back easing
```

---

## Support & Resources

- **Full Documentation**: `/design-documentation/features/drag-handle/`
- **Visual Specs**: `visual-specifications.md`
- **Interaction Specs**: `interaction-specifications.md`
- **Implementation Guide**: `implementation-guide.md`
- **Accessibility Guide**: `accessibility.md`

---

## Questions?

**Visual Design**: See `visual-specifications.md`
**Interactions**: See `interaction-specifications.md`
**Implementation**: See `implementation-guide.md`
**Accessibility**: See `accessibility.md`

---

**Last Updated**: 2025-11-02 | **Version**: 1.0.0 | **Status**: Approved
