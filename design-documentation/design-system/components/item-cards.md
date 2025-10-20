---
title: Item Cards Component
description: Comprehensive specification for task, note, and list item cards
last-updated: 2025-10-19
version: 1.0.0
status: approved
related-files:
  - ../style-guide.md
  - ../tokens/colors.md
  - ../tokens/spacing.md
  - ./quick-capture.md
---

# Item Cards Component

## Overview

Item Cards are the fundamental building block of later. They represent tasks, notes, and lists in a unified, visually distinct format that creates instant recognition while maintaining consistency.

## Design Philosophy

**Chromatic Differentiation**: Each item type has a distinct color signature that users recognize instantly, creating effortless mental mapping between color and content type.

**Luminous Depth**: Cards use subtle gradients, soft shadows, and glass-morphic effects to feel elevated yet lightweight.

**Gestural Intimacy**: Every card supports swipe gestures, long-press actions, and tap interactions with immediate haptic feedback.

---

## Visual Design

### Card Anatomy

```
┌─────────────────────────────────────────┐
│ [Type Indicator Strip - 4px colored]   │
├─────────────────────────────────────────┤
│  [Icon] Title Text              [Badge]│
│                                         │
│  Content preview or description...     │
│                                         │
│  [Metadata] [Tags] [Timestamp]         │
└─────────────────────────────────────────┘
```

**Components**:
1. **Type Indicator** - 4px colored strip at top (task/note/list color)
2. **Icon** - Type-specific icon (20px, colored)
3. **Title** - Item title (H4 or Body Large, bold)
4. **Badge** - Optional status indicator
5. **Content** - Preview of content (truncated)
6. **Metadata** - Tags, due date, counts
7. **Timestamp** - Last modified or due date

---

## Task Card Specification

### Default State

**Visual Properties**
```dart
Container(
  decoration: BoxDecoration(
    // Background: Gradient on Light, Solid on Dark
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        AppColors.taskLight.withOpacity(0.3),
      ],
    ),
    borderRadius: BorderRadius.circular(AppRadius.md), // 12px
    border: Border(
      top: BorderSide(
        color: AppColors.taskColor,
        width: 4,
      ),
    ),
    boxShadow: [
      AppShadows.level1, // Resting shadow
    ],
  ),
  padding: EdgeInsets.all(AppSpacing.md), // 16px
)
```

**Layout Structure**
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: AppSpacing.xs, // 8px
  children: [
    // Header Row
    Row(
      children: [
        Icon(Lucide.checkCircle, size: 20, color: AppColors.taskColor),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            'Task title',
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (hasBadge) StatusBadge(),
      ],
    ),

    // Content Preview (if exists)
    if (hasContent)
      Text(
        'Task description or notes...',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.neutral500,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),

    // Metadata Row
    Row(
      children: [
        if (hasDueDate)
          DueDateChip(),
        if (hasTags)
          Wrap(
            spacing: AppSpacing.xxs,
            children: tags.map((tag) => TagChip(tag)).toList(),
          ),
        Spacer(),
        TimestampText(),
      ],
    ),
  ],
)
```

**Colors**
- **Border Top**: Task gradient or solid
- **Background**: White with subtle task color tint (light), Dark with task opacity (dark)
- **Icon**: Task color
- **Text**: Neutral-700 (light), Neutral-300 (dark)
- **Metadata**: Neutral-500

**Typography**
- **Title**: Title Medium (18px, medium weight)
- **Content**: Body Small (14px, regular)
- **Metadata**: Label Medium (12px, medium)

**Spacing**
- **Padding**: 16px all sides
- **Between elements**: 8px vertical
- **Icon-text gap**: 8px

### Completed State

**Visual Changes**
```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.successBg.withOpacity(0.3), // Faint green tint
    border: Border(
      top: BorderSide(color: AppColors.success, width: 4),
    ),
  ),
  child: Stack(
    children: [
      Opacity(
        opacity: 0.5, // Dimmed content
        child: CardContent(),
      ),
      // Checkmark overlay
      Positioned(
        top: AppSpacing.sm,
        right: AppSpacing.sm,
        child: Icon(
          Lucide.checkCircle,
          color: AppColors.success,
          size: 24,
        ).animate()
          .scale(
            duration: AppAnimations.base,
            curve: Curves.elasticOut,
          ),
      ),
    ],
  ),
)
```

**Interaction**
- Swipe left reveals "Undo" action
- Tap toggles back to incomplete
- Spring animation on completion

### Overdue State

**Visual Changes**
- Border color: Error color
- Badge: "Overdue" in red
- Due date text: Error color, bold
- Subtle pulse animation (optional, respects reduced motion)

### Hover State (Desktop/Tablet)

```dart
AnimatedContainer(
  duration: AppAnimations.fast,
  curve: AppAnimations.easeOutQuart,
  decoration: BoxDecoration(
    boxShadow: [
      AppShadows.level2, // Raised shadow
    ],
  ),
  transform: Matrix4.translationValues(0, -2, 0), // Lift 2px
)
```

### Pressed State

```dart
// Scale down to 0.98
Transform.scale(
  scale: 0.98,
  child: Card(),
)
// Haptic: Medium impact
```

---

## Note Card Specification

### Default State

**Visual Properties**
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        AppColors.noteLight.withOpacity(0.3),
      ],
    ),
    borderRadius: BorderRadius.circular(AppRadius.md),
    border: Border(
      top: BorderSide(
        color: AppColors.noteColor,
        width: 4,
      ),
    ),
    boxShadow: [AppShadows.level1],
  ),
  padding: EdgeInsets.all(AppSpacing.md),
)
```

**Key Differences from Task**:
- Note-specific blue gradient
- Document icon instead of checkmark
- No completion state
- Focus on content preview
- No due dates

**Layout**
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: AppSpacing.xs,
  children: [
    // Header
    Row(
      children: [
        Icon(Lucide.fileText, size: 20, color: AppColors.noteColor),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            'Note title',
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isPinned)
          Icon(Lucide.pin, size: 16, color: AppColors.neutral400),
      ],
    ),

    // Content Preview (always shown for notes)
    Text(
      'Note content preview with markdown support...',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.neutral500,
      ),
      maxLines: 3, // More lines than task
      overflow: TextOverflow.ellipsis,
    ),

    // Metadata
    Row(
      children: [
        if (hasTags)
          Wrap(
            spacing: AppSpacing.xxs,
            children: tags.map((tag) => TagChip(tag)).toList(),
          ),
        Spacer(),
        Text(
          'Modified 2h ago',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.neutral500,
          ),
        ),
      ],
    ),
  ],
)
```

**Special Features**:
- More content preview lines (3 vs 2 for tasks)
- Pin indicator for pinned notes
- Rich text preview (markdown formatting hints)

---

## List Card Specification

### Default State

**Visual Properties**
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        AppColors.listLight.withOpacity(0.3),
      ],
    ),
    borderRadius: BorderRadius.circular(AppRadius.md),
    border: Border(
      top: BorderSide(
        color: AppColors.listColor,
        width: 4,
      ),
    ),
    boxShadow: [AppShadows.level1],
  ),
  padding: EdgeInsets.all(AppSpacing.md),
)
```

**Layout**
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: AppSpacing.xs,
  children: [
    // Header
    Row(
      children: [
        Icon(Lucide.list, size: 20, color: AppColors.listColor),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            'List title',
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Item count badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: AppColors.listColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: Text(
            '8 items',
            style: AppTypography.codeSmall.copyWith(
              color: AppColors.listColor,
            ),
          ),
        ),
      ],
    ),

    // Item Preview (first 3 items)
    Column(
      spacing: AppSpacing.xxs,
      children: [
        ListItemPreview(text: '• First item'),
        ListItemPreview(text: '• Second item'),
        ListItemPreview(text: '• Third item'),
        if (hasMoreItems)
          Text(
            '+ 5 more items',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
      ],
    ),

    // Metadata
    Row(
      children: [
        if (hasTags)
          Wrap(
            spacing: AppSpacing.xxs,
            children: tags.map((tag) => TagChip(tag)).toList(),
          ),
        Spacer(),
        TimestampText(),
      ],
    ),
  ],
)
```

**Special Features**:
- Item count badge
- Preview of first 3 list items
- "+ N more items" indicator
- No completion state (individual items can be completed)

---

## Compact Card Variant

For dense views (search results, archive):

**Visual Changes**:
- Padding: 12px (reduced from 16px)
- Title: Body Large (instead of Title Medium)
- Content: 1 line only
- No icon
- Type indicator strip: 3px (instead of 4px)

**Layout**
```dart
Container(
  padding: EdgeInsets.all(AppSpacing.sm), // 12px
  child: Row(
    children: [
      // Type color dot
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: typeColor,
          shape: BoxShape.circle,
        ),
      ),
      SizedBox(width: AppSpacing.xs),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, maxLines: 1),
            Text(preview, maxLines: 1),
          ],
        ),
      ),
      TimestampText(),
    ],
  ),
)
```

---

## Interactive States

### Swipe Actions

**Left Swipe** (Task/Note/List)

```dart
Slidable(
  endActionPane: ActionPane(
    motion: const DrawerMotion(),
    extentRatio: 0.25,
    children: [
      SlidableAction(
        onPressed: (_) {
          // Delete action
          HapticFeedback.mediumImpact();
        },
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        icon: Lucide.trash2,
        label: 'Delete',
      ),
    ],
  ),
  child: Card(),
)
```

**Right Swipe** (Task only)

```dart
Slidable(
  startActionPane: ActionPane(
    motion: const DrawerMotion(),
    extentRatio: 0.25,
    children: [
      SlidableAction(
        onPressed: (_) {
          // Complete action
          HapticFeedback.lightImpact();
        },
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        icon: Lucide.check,
        label: 'Complete',
      ),
    ],
  ),
  child: Card(),
)
```

**Swipe Behavior**:
- Snap point at 80px
- Spring physics with velocity
- Haptic feedback on action
- Undo toast appears after action

### Long Press Menu

**Trigger**: 500ms long press

**Menu Actions** (contextual):
```dart
showModalBottomSheet(
  context: context,
  builder: (context) => ActionSheet(
    actions: [
      ActionItem(
        icon: Lucide.edit,
        label: 'Edit',
        onTap: () {},
      ),
      ActionItem(
        icon: Lucide.copy,
        label: 'Duplicate',
        onTap: () {},
      ),
      ActionItem(
        icon: Lucide.share,
        label: 'Share',
        onTap: () {},
      ),
      ActionItem(
        icon: Lucide.archive,
        label: 'Archive',
        onTap: () {},
      ),
      ActionItem(
        icon: Lucide.trash2,
        label: 'Delete',
        onTap: () {},
        isDestructive: true,
      ),
    ],
  ),
);
```

**Haptic**: Heavy impact on long press trigger

### Tap Action

**Single Tap**: Open item detail/edit view
**Animation**: Scale in transition (300ms)
**Haptic**: Light impact

---

## Special Card Variants

### Empty State Card (Placeholder)

```dart
Container(
  decoration: BoxDecoration(
    border: Border.all(
      color: AppColors.neutral200,
      width: 2,
      style: BorderStyle.dashed,
    ),
    borderRadius: BorderRadius.circular(AppRadius.md),
  ),
  padding: EdgeInsets.all(AppSpacing.xl),
  child: Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Lucide.plus,
          size: 48,
          color: AppColors.neutral300,
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Add your first task',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.neutral500,
          ),
        ),
      ],
    ),
  ),
)
```

### Pinned Card Indicator

For pinned items at top of lists:

```dart
// Add pin icon to top-right
Positioned(
  top: AppSpacing.sm,
  right: AppSpacing.sm,
  child: Icon(
    Lucide.pin,
    size: 16,
    color: AppColors.primarySolid,
  ),
)

// Add subtle glow
BoxDecoration(
  boxShadow: [
    BoxShadow(
      color: AppColors.primarySolid.withOpacity(0.1),
      blurRadius: 8,
      spreadRadius: 2,
    ),
  ],
)
```

---

## Dark Mode Adaptations

```dart
// Dark mode colors
Container(
  decoration: BoxDecoration(
    // Solid dark background with type color opacity
    color: Theme.of(context).brightness == Brightness.dark
        ? AppColors.neutral900
        : Colors.white,

    // Type indicator more prominent
    border: Border(
      top: BorderSide(
        color: typeColor,
        width: Theme.of(context).brightness == Brightness.dark ? 5 : 4,
      ),
    ),

    // Subtle inner glow
    boxShadow: Theme.of(context).brightness == Brightness.dark
        ? [
            BoxShadow(
              color: typeColor.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: -4,
            ),
          ]
        : [AppShadows.level1],
  ),
)
```

**Dark Mode Changes**:
- Solid backgrounds instead of gradients
- Stronger type indicator (5px vs 4px)
- Subtle inner glow with type color
- Higher contrast shadows
- Brighter type colors (use -300/-400 variants)

---

## Responsive Behavior

### Mobile (320-767px)
- Full width cards
- Padding: 16px
- Touch targets: 48px minimum
- Swipe gestures enabled

### Tablet (768-1023px)
- Cards in 2-column grid
- Padding: 20px
- Hover states enabled
- Both touch and mouse interactions

### Desktop (1024px+)
- Cards in 2-3 column grid
- Padding: 24px
- Full hover/focus states
- Keyboard navigation support

---

## Accessibility

### Screen Reader Support

```dart
Semantics(
  label: 'Task: $title',
  hint: 'Double tap to open, swipe for actions',
  button: true,
  child: Card(),
)
```

### Keyboard Navigation

- **Tab**: Focus card
- **Enter/Space**: Open card
- **Delete**: Delete card (with confirmation)
- **Arrow keys**: Navigate between cards

### Focus State

```dart
FocusableActionDetector(
  onFocusChange: (focused) {
    setState(() => _isFocused = focused);
  },
  child: Container(
    decoration: BoxDecoration(
      border: _isFocused
          ? Border.all(
              color: AppColors.primarySolid,
              width: 3,
            )
          : null,
    ),
  ),
)
```

**Focus Indicator**:
- 3px primary color border
- 2px offset from card edge
- Visible on all backgrounds
- Animated appearance (100ms)

---

## Animation Specifications

### Card Entrance

```dart
card.animate()
  .fadeIn(duration: 300.ms, curve: Curves.easeOutExpo)
  .slideY(begin: 0.05, duration: 300.ms, curve: Curves.easeOutExpo);
```

### Card Exit (Delete)

```dart
card.animate()
  .fadeOut(duration: 200.ms)
  .scale(
    begin: const Offset(1, 1),
    end: const Offset(0.9, 0.9),
    duration: 200.ms,
  )
  .slideX(end: -0.1, duration: 200.ms);
```

### List Reorder

```dart
// Use ReorderableListView with spring physics
ReorderableListView(
  onReorder: (oldIndex, newIndex) {
    HapticFeedback.lightImpact();
    // Reorder logic
  },
  children: cards,
)
```

### Task Completion

```dart
// Checkmark scales with spring bounce
Icon(Lucide.checkCircle)
  .animate()
  .scale(
    duration: 400.ms,
    curve: Curves.elasticOut,
  );

// Card fades and collapses
card.animate()
  .fadeOut(duration: 300.ms)
  .slideY(end: -0.1, duration: 300.ms);
```

---

## Flutter Implementation

### Base Card Widget

```dart
// lib/core/widgets/item_card.dart

class ItemCard extends StatelessWidget {
  final ItemType type;
  final String title;
  final String? content;
  final List<String>? tags;
  final DateTime? dueDate;
  final DateTime lastModified;
  final bool isCompleted;
  final bool isPinned;
  final VoidCallback onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;

  const ItemCard({
    required this.type,
    required this.title,
    this.content,
    this.tags,
    this.dueDate,
    required this.lastModified,
    this.isCompleted = false,
    this.isPinned = false,
    required this.onTap,
    this.onComplete,
    this.onDelete,
  });

  Color get typeColor {
    switch (type) {
      case ItemType.task:
        return AppColors.taskColor;
      case ItemType.note:
        return AppColors.noteColor;
      case ItemType.list:
        return AppColors.listColor;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case ItemType.task:
        return Lucide.checkCircle;
      case ItemType.note:
        return Lucide.fileText;
      case ItemType.list:
        return Lucide.list;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) {
              HapticFeedback.mediumImpact();
              onDelete?.call();
            },
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Lucide.trash2,
            label: 'Delete',
          ),
        ],
      ),
      startActionPane: type == ItemType.task
          ? ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (_) {
                    HapticFeedback.lightImpact();
                    onComplete?.call();
                  },
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  icon: Lucide.check,
                  label: 'Complete',
                ),
              ],
            )
          : null,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          decoration: BoxDecoration(
            gradient: _buildGradient(context),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border(
              top: BorderSide(
                color: typeColor,
                width: 4,
              ),
            ),
            boxShadow: [AppShadows.level1],
          ),
          padding: EdgeInsets.all(AppSpacing.md),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.xs,
      children: [
        _buildHeader(context),
        if (content != null) _buildContentPreview(context),
        _buildMetadata(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(typeIcon, size: 20, color: typeColor),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isPinned)
          Icon(Lucide.pin, size: 16, color: AppColors.neutral400),
      ],
    );
  }

  Widget _buildContentPreview(BuildContext context) {
    return Text(
      content!,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.neutral500,
      ),
      maxLines: type == ItemType.note ? 3 : 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetadata(BuildContext context) {
    return Row(
      children: [
        if (tags != null && tags!.isNotEmpty)
          Wrap(
            spacing: AppSpacing.xxs,
            children: tags!.map((tag) => _TagChip(tag)).toList(),
          ),
        Spacer(),
        Text(
          _formatTimestamp(lastModified),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.neutral500,
          ),
        ),
      ],
    );
  }

  Gradient _buildGradient(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return LinearGradient(colors: [AppColors.neutral900, AppColors.neutral900]);
    }

    Color endColor;
    switch (type) {
      case ItemType.task:
        endColor = AppColors.taskLight.withOpacity(0.3);
      case ItemType.note:
        endColor = AppColors.noteLight.withOpacity(0.3);
      case ItemType.list:
        endColor = AppColors.listLight.withOpacity(0.3);
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white, endColor],
    );
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}

enum ItemType { task, note, list }
```

---

**Related Documentation**
- [Style Guide](../style-guide.md)
- [Colors](../tokens/colors.md)
- [Quick Capture](./quick-capture.md)

**Last Updated**: October 19, 2025
**Version**: 1.0.0
