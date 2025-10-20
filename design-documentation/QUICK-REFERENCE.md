---
title: Quick Reference Guide
description: Fast reference for common design system values and patterns
last-updated: 2025-10-19
version: 1.0.0
---

# Quick Reference Guide

## At-a-Glance Design Values

### Colors (Most Used)

```dart
// PRIMARY
AppColors.primarySolid      // #7C3AED - Primary actions
AppColors.primaryGradient   // Indigo → Purple gradient

// TYPE COLORS
AppColors.taskColor         // #F87171 - Tasks (Red-Orange)
AppColors.noteColor         // #60A5FA - Notes (Blue)
AppColors.listColor         // #A78BFA - Lists (Purple)

// SEMANTIC
AppColors.success           // #10B981 - Success states
AppColors.error             // #EF4444 - Errors, destructive
AppColors.warning           // #F59E0B - Warnings

// TEXT (Light Mode)
AppColors.neutral700        // #334155 - Headings
AppColors.neutral600        // #475569 - Body text
AppColors.neutral500        // #64748B - Secondary text

// TEXT (Dark Mode)
AppColors.neutral300        // #CBD5E1 - Headings
AppColors.neutral400        // #94A3B8 - Body text
AppColors.neutral500        // #64748B - Secondary text

// BACKGROUNDS (Light Mode)
AppColors.neutral50         // #F8FAFC - Canvas
Colors.white                // #FFFFFF - Surfaces

// BACKGROUNDS (Dark Mode)
AppColors.neutral950        // #020617 - Canvas
AppColors.neutral900        // #0F172A - Surfaces
```

### Typography Styles

```dart
// HEADINGS
Theme.of(context).textTheme.headlineLarge    // 32px, Bold - Page titles
Theme.of(context).textTheme.headlineMedium   // 28px, Semibold - Sections
Theme.of(context).textTheme.headlineSmall    // 24px, Semibold - Subsections

// TITLES
Theme.of(context).textTheme.titleMedium      // 18px, Medium - Card titles
Theme.of(context).textTheme.titleLarge       // 20px, Semibold - Major elements

// BODY
Theme.of(context).textTheme.bodyMedium       // 16px, Regular - Default
Theme.of(context).textTheme.bodyLarge        // 17px, Regular - Reading
Theme.of(context).textTheme.bodySmall        // 14px, Regular - Secondary

// LABELS
Theme.of(context).textTheme.labelLarge       // 14px, Semibold - Form labels
Theme.of(context).textTheme.labelMedium      // 12px, Medium - Captions
```

### Spacing Values

```dart
AppSpacing.xxs    // 4px  - Micro spacing
AppSpacing.xs     // 8px  - Small spacing
AppSpacing.sm     // 12px - Comfortable grouping
AppSpacing.md     // 16px - Default spacing ⭐
AppSpacing.lg     // 24px - Section spacing
AppSpacing.xl     // 32px - Large spacing
AppSpacing.xxl    // 48px - Extra large
AppSpacing.xxxl   // 64px - Huge spacing
```

### Border Radius

```dart
AppRadius.xs      // 4px  - Tags, chips
AppRadius.sm      // 8px  - Buttons, inputs
AppRadius.md      // 12px - Cards ⭐
AppRadius.lg      // 16px - Large cards, FAB
AppRadius.xl      // 20px - Modals
AppRadius.xxl     // 24px - Bottom sheets
AppRadius.full    // 9999px - Pills, circles
```

### Animation Durations

```dart
AppAnimations.instant    // 0ms   - Instant changes
AppAnimations.micro      // 100ms - State changes
AppAnimations.fast       // 200ms - Quick interactions
AppAnimations.base       // 300ms - Standard ⭐
AppAnimations.slow       // 400ms - Deliberate
AppAnimations.slower     // 500ms - Page transitions
```

### Animation Curves

```dart
AppAnimations.easeOutExpo       // Entrances, expansions
AppAnimations.easeInOutQuint    // Smooth transitions
AppAnimations.easeOutQuart      // Snappy interactions
Curves.elasticOut               // Spring bounce
```

---

## Common Patterns

### Item Card

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(...),
    borderRadius: BorderRadius.circular(AppRadius.md),
    border: Border(top: BorderSide(color: typeColor, width: 4)),
    boxShadow: AppShadows.level1,
  ),
  padding: EdgeInsets.all(AppSpacing.md),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(/* Icon + Title */),
      SizedBox(height: AppSpacing.xs),
      Text(/* Content preview */),
      SizedBox(height: AppSpacing.xs),
      Row(/* Metadata */),
    ],
  ),
)
```

### Glass Morphism Container

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(AppRadius.xl),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: YourContent(),
    ),
  ),
)
```

### Gradient Button

```dart
Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(AppRadius.sm),
    boxShadow: [
      BoxShadow(
        color: AppColors.primarySolid.withOpacity(0.3),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Text('Button', style: TextStyle(color: Colors.white)),
      ),
    ),
  ),
)
```

### Fade In Animation

```dart
widget.animate()
  .fadeIn(
    duration: AppAnimations.base,
    curve: AppAnimations.easeOutExpo,
  );
```

### Scale In Animation

```dart
widget.animate()
  .scale(
    begin: Offset(0.95, 0.95),
    duration: AppAnimations.base,
    curve: AppAnimations.easeOutExpo,
  )
  .fadeIn(duration: AppAnimations.base);
```

### Slide Up Animation

```dart
widget.animate()
  .slideY(
    begin: 0.1,
    duration: AppAnimations.slow,
    curve: AppAnimations.easeOutExpo,
  )
  .fadeIn(duration: AppAnimations.slow);
```

---

## Component Cheat Sheet

### FAB (Floating Action Button)

**Size**: 64×64px
**Radius**: 16px (squircle)
**Gradient**: Primary gradient
**Shadow**: Large with color tint
**Position**: Bottom-right, 16px margin

```dart
Container(
  width: 64,
  height: 64,
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    boxShadow: [
      BoxShadow(
        color: AppColors.primarySolid.withOpacity(0.4),
        blurRadius: 16,
        offset: Offset(0, 8),
      ),
    ],
  ),
  child: Icon(Icons.add, size: 28, color: Colors.white),
)
```

### Bottom Navigation

**Height**: 72px (56px + safe area)
**Background**: White/Neutral-900
**Border**: 1px top border
**Items**: 4 main tabs
**Active**: Gradient pill background

### App Bar

**Height**: 64px
**Background**: Frosted glass (white 90% + blur)
**Border**: 1px bottom border
**Title**: Left-aligned, Title Large

---

## Accessibility Quick Checks

### Touch Targets
✓ **Minimum**: 48×48px
✓ **Spacing**: 8px between targets
✓ **Comfortable**: 56×56px for primary actions

### Color Contrast
✓ **Normal text**: 4.5:1 minimum
✓ **Large text**: 3.0:1 minimum
✓ **UI components**: 3.0:1 minimum
✓ **Focus indicators**: 3.0:1 minimum

### Text Sizes
✓ **Minimum body**: 16px on mobile
✓ **Minimum label**: 11px
✓ **Line height**: 1.5 for body text
✓ **Text scaling**: Support up to 2.0x

### Focus Indicators
✓ **Width**: 3px
✓ **Color**: Primary color
✓ **Offset**: 2px from element
✓ **Always visible**: Never remove

---

## Responsive Breakpoints

```dart
// Mobile
if (width < 768) {
  // Phone layout
  // Bottom navigation
  // FAB above nav
  // 16px padding
}

// Tablet
else if (width < 1024) {
  // Tablet layout
  // Navigation rail or sidebar
  // 32px padding
}

// Desktop
else {
  // Desktop layout
  // Sidebar navigation
  // 48px padding
}
```

---

## Common Measurements

### Item Card
- **Padding**: 16px (mobile), 24px (desktop)
- **Radius**: 12px
- **Type strip**: 4px colored border
- **Spacing between**: 12px

### Modal
- **Max width**: 560px
- **Max height**: 70% screen
- **Radius**: 20px
- **Padding**: 24px

### List Spacing
- **Compact**: 8px between items
- **Default**: 12px between items
- **Comfortable**: 16px between items

### Button Padding
- **Small**: 16px horizontal, 8px vertical
- **Medium**: 24px horizontal, 12px vertical
- **Large**: 32px horizontal, 16px vertical

---

## Type Colors Quick Reference

```
Task:  #F87171 (Red-Orange)   🔴 Urgent, action-oriented
Note:  #60A5FA (Blue)          🔵 Contemplative, knowledge
List:  #A78BFA (Purple)        🟣 Organized, structured
```

---

## Shadow Levels

```dart
AppShadows.level1  // Subtle - Cards at rest
AppShadows.level2  // Raised - Hover, interactive
AppShadows.level3  // Floating - Dropdowns, popovers
AppShadows.level4  // Modal - Dialogs, overlays
```

---

## Haptic Feedback Patterns

```dart
HapticFeedback.lightImpact()   // Checkbox, small interactions
HapticFeedback.mediumImpact()  // Button press, selections
HapticFeedback.heavyImpact()   // Destructive, important
HapticFeedback.selectionClick() // Scrolling, dragging
```

---

## Common State Colors

```dart
// Hover (Desktop)
opacity: 0.9
transform: translateY(-2px)

// Pressed
scale: 0.98 (cards) or 0.96 (buttons)

// Focus
border: 3px solid AppColors.primarySolid
offset: 2px

// Disabled
opacity: 0.5
color: AppColors.neutral400

// Loading
Shimmer or CircularProgressIndicator
```

---

## File Import Quick Reference

```dart
// Theme
import 'package:later/core/theme/app_colors.dart';
import 'package:later/core/theme/app_typography.dart';
import 'package:later/core/theme/app_spacing.dart';
import 'package:later/core/theme/app_animations.dart';

// Widgets
import 'package:later/core/widgets/item_card.dart';
import 'package:later/core/widgets/gradient_button.dart';

// Packages
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
```

---

## Decision Trees

### When to use which spacing?

**4px (xxs)**: Icon-text gaps, micro spacing
**8px (xs)**: Internal padding, tight grouping
**12px (sm)**: List items, comfortable grouping
**16px (md)**: Default spacing ⭐ (use when unsure)
**24px (lg)**: Section spacing, card padding
**32px (xl)**: Major separations, screen padding
**48px+ (xxl)**: Hero sections, special moments

### When to use which shadow?

**Level 1**: Default card state
**Level 2**: Hover, raised elements
**Level 3**: Dropdowns, temporary overlays
**Level 4**: Modals, dialogs

### When to use which animation duration?

**100ms**: State changes (hover, focus)
**200ms**: Quick feedback (button press)
**300ms**: Standard transitions ⭐ (use when unsure)
**400ms**: Deliberate transitions (modal open)
**500ms+**: Page transitions, special moments

---

## Most Common Code Snippets

### Theme-Aware Color

```dart
final textColor = Theme.of(context).brightness == Brightness.light
    ? AppColors.neutral600
    : AppColors.neutral400;
```

### Responsive Padding

```dart
final padding = MediaQuery.of(context).size.width < 768
    ? AppSpacing.md
    : AppSpacing.xl;
```

### Safe Animation

```dart
final duration = AppAnimations.reduceMotion
    ? Duration.zero
    : AppAnimations.base;
```

### Timestamp Formatting

```dart
String formatTimestamp(DateTime date) {
  final difference = DateTime.now().difference(date);
  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inHours < 1) return '${difference.inMinutes}m ago';
  if (difference.inDays < 1) return '${difference.inHours}h ago';
  return '${date.month}/${date.day}';
}
```

---

## Checklist for New Components

Before marking a component complete:

- [ ] All states implemented (default, hover, pressed, focus, disabled)
- [ ] Responsive across all breakpoints
- [ ] Dark mode variant created
- [ ] Accessibility labels added
- [ ] Touch targets verified (48×48px min)
- [ ] Color contrast checked (4.5:1 min)
- [ ] Animations respect reduced motion
- [ ] Haptic feedback added for interactions
- [ ] Documentation updated
- [ ] Code example provided

---

## When in Doubt...

**Spacing**: Use `AppSpacing.md` (16px)
**Radius**: Use `AppRadius.md` (12px)
**Animation**: Use `AppAnimations.base` (300ms)
**Shadow**: Use `AppShadows.level1`
**Font**: Use `Theme.of(context).textTheme.bodyMedium`

---

**Quick Links**:
- [Full Style Guide](./design-system/style-guide.md)
- [Color System](./design-system/tokens/colors.md)
- [Implementation Guide](./IMPLEMENTATION-GUIDE.md)
- [Component Library](./design-system/components/)

**Last Updated**: October 19, 2025
