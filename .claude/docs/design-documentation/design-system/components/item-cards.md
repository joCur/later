---
title: Item Cards Component
description: Unified card component for tasks, notes, and lists with variant specifications
version: 1.0.0
last-updated: 2025-10-18
status: approved
related-files:
  - ../style-guide.md
  - ../tokens/colors.md
  - ../../features/unified-item-management/README.md
---

# Item Cards Component

## Overview

Item cards are the core component of Later, displaying tasks, notes, and lists in a unified, flexible format. The card design balances visual distinction between item types with clean simplicity.

**Design Principle**: Subtle differentiation through color accents, not overwhelming visual distinctions.

## Component Anatomy

```
┌─────────────────────────────────────────────────┐
│ [4px colored border] │ [Checkbox/Icon] [Title] │ [•••]
│                      │ [Content preview...]     │
│                      │ [Meta] [Tags] [Date]     │
└─────────────────────────────────────────────────┘
```

### Structure Elements

1. **Left Border** - 4px colored accent (item type color)
2. **Leading Element** - Checkbox (task) or icon (note/list)
3. **Title** - H4 typography, 1-2 lines, truncate with ellipsis
4. **Content Preview** - Body text, 2-3 lines for notes/lists
5. **Metadata Row** - Space name, tags, date/time
6. **Action Menu** - Three-dot menu (always visible on desktop, show on long-press mobile)

## Visual Specifications

### Default State

**Container**:
- Background: White (light) / Neutral-100 (dark)
- Border: None (except 4px left accent)
- Border Radius: 8px (radius-md)
- Shadow: Level 1 elevation
- Padding: 16px (md)
- Margin: 0 0 8px 0 (stacked items)

**Left Border Accent**:
- Width: 4px
- Height: 100% (full card height)
- Color: Item type color (Blue/Amber/Violet)
- Border Radius: 8px 0 0 8px (matches container)

**Typography**:
- Title: H4 (18px/26px, Semibold 600)
- Content: Body (14px/22px, Regular 400)
- Metadata: Caption (11px/16px, Regular 400)

**Spacing**:
- Between elements: 8px (sm)
- Internal padding: 16px (md)
- Icon to text: 12px gap

### Hover State

**Changes**:
- Background: Neutral-50 (light) / Neutral-200 (dark)
- Shadow: Level 2 elevation
- Cursor: Pointer
- Transition: 150ms ease-out

**Animation**:
```
transition: background-color 150ms ease-out,
            box-shadow 150ms ease-out;
```

### Selected State

**Changes**:
- Background: Primary-light (E0E7FF / 312E81)
- Left border: Primary color (wider: 6px)
- Shadow: Level 1 elevation
- Checkmark indicator (multi-select mode)

### Pressed/Active State

**Changes**:
- Scale: 0.99 (subtle compression)
- Shadow: Level 0 (flattens)
- Duration: 100ms

### Completed State (Tasks Only)

**Changes**:
- Title: Strikethrough, Neutral-500 color
- Content: 70% opacity
- Left border: Accent-secondary (teal) color
- Checkbox: Filled with checkmark

### Dragging State

**Changes**:
- Opacity: 0.7
- Shadow: Level 3 elevation
- Cursor: Grabbing
- Slight rotation: ±2deg (subtle)

## Variants

### Task Card

**Distinctive Features**:
- Left border: Blue (#3B82F6 / #60A5FA)
- Leading element: Checkbox (24x24px)
- Optional: Due date badge
- Optional: Priority indicator (!, !!, !!!)

**Checkbox Specifications**:
- Size: 24x24px
- Border: 2px, Neutral-300
- Border Radius: 6px (radius-sm)
- Checked: Blue fill with white checkmark
- Hover: Blue border
- Animation: Scale 1.1 on check, 150ms ease-out

**Due Date Badge**:
- Background: Error-light (overdue), Warning-light (today), transparent (future)
- Text: Error (overdue), Warning (today), Neutral-600 (future)
- Typography: Caption (11px), Medium weight
- Padding: 4px 8px
- Border Radius: 4px (radius-xs)

### Note Card

**Distinctive Features**:
- Left border: Amber (#F59E0B / #FBBF24)
- Leading element: Note icon (20x20px)
- Content preview: 2-3 lines of note text
- Optional: Image/attachment thumbnail

**Icon Specifications**:
- Icon: File-text or Note icon
- Size: 20x20px
- Color: Amber (matches border)
- Stroke Width: 2px

**Content Preview**:
- Max lines: 3
- Overflow: Ellipsis
- Rich text: Stripped to plain text for preview
- Font: Body (14px/22px)

### List Card

**Distinctive Features**:
- Left border: Violet (#8B5CF6 / #A78BFA)
- Leading element: List icon (20x20px)
- Content preview: First 3 list items
- Progress indicator: "3/10 items"

**Icon Specifications**:
- Icon: List or Checklist icon
- Size: 20x20px
- Color: Violet (matches border)
- Stroke Width: 2px

**List Item Preview**:
- Show first 3 items
- Format: "• Item 1\n• Item 2\n• Item 3"
- Typography: Body small (12px/18px)
- Color: Neutral-600

**Progress Indicator**:
- Format: "3/10 items" or "3 of 10 completed"
- Typography: Caption (11px), Medium weight
- Color: Neutral-500
- Position: Bottom right of card

## Responsive Behavior

### Mobile (320-767px)

**Adjustments**:
- Padding: 12px (slightly tighter)
- Title: 16px (H4 mobile variant)
- Content preview: 2 lines max (save space)
- Action menu: Hidden, shown via long-press
- Swipe actions: Enabled (swipe right: complete, swipe left: delete)

**Touch Targets**:
- Minimum height: 64px
- Checkbox: 44x44px touch target (24x24px visual)
- Action menu: 44x44px touch target

### Tablet (768-1023px)

**Adjustments**:
- Standard specifications
- Two-column grid layout (2 cards per row)
- Gutter: 16px between cards

### Desktop (1024px+)

**Adjustments**:
- Standard specifications
- Optional: Three-column layout for wide screens
- Hover states: Always visible
- Action menu: Always visible on hover
- Keyboard navigation: Focus ring (2px primary, 2px offset)

## Interaction Patterns

### Click/Tap

**Single Click**:
- Action: Open item detail view
- Animation: Fade transition to detail (300ms)
- Haptic: Light tap (mobile)

**Double Click** (Desktop):
- Action: Enter edit mode
- Animation: Transform to inline edit
- Keyboard: Auto-focus title field

### Long Press (Mobile)

**Trigger**: 500ms hold
- Action: Show context menu or multi-select mode
- Visual: Card scales to 1.02, shadow increases
- Haptic: Medium impact
- Menu: Bottom sheet with actions

### Swipe Actions (Mobile)

**Swipe Right** (Tasks):
- Action: Mark complete/incomplete
- Threshold: 30% card width
- Animation: Checkmark icon reveal, teal background
- Haptic: Light impact on threshold, medium on complete

**Swipe Left**:
- Action: Delete item
- Threshold: 50% card width
- Animation: Trash icon reveal, red background
- Haptic: Light impact on threshold, warning haptic on delete
- Confirmation: Required for permanent delete

### Drag and Drop

**Desktop**:
- Trigger: Click and hold 300ms
- Visual: Card lifts (shadow level 3), cursor changes
- Drop zones: Spaces, lists, reorder positions
- Snap: Magnetic snap to valid drop positions
- Invalid: Shake animation on invalid drop

**Mobile**:
- Trigger: Long press then drag
- Visual: Card lifts, other cards shift
- Haptic: Light continuous feedback during drag
- Drop: Medium impact on successful drop

## States & Feedback

### Loading State

**Skeleton Loader**:
- Animated gradient: Neutral-100 to Neutral-200
- Animation: Shimmer left to right (1.5s infinite)
- Structure: Placeholder shapes matching card anatomy
- Count: Show 3-5 skeleton cards

### Empty State

**No Items**:
- Icon: Plus-circle (48px), Neutral-400
- Title: "No items yet"
- Description: "Tap + to create your first [task/note/list]"
- CTA: Large "Create Item" button

### Error State

**Sync Error**:
- Border: Error color (red)
- Icon: Alert-triangle in top-right corner
- Message: "Sync failed" badge
- Action: Tap to retry or view error details

### Offline State

**Visual Indicators**:
- Subtle badge: "Offline" (Neutral-500)
- No border color change (don't penalize offline)
- Sync icon: Cloud-off (subtle, not prominent)

## Accessibility Specifications

### Screen Reader Support

**ARIA Labels**:
```html
<div role="article" aria-label="Task: Buy groceries, due today">
  <button role="checkbox" aria-checked="false" aria-label="Mark task complete">
  <h4>Buy groceries</h4>
  <p>Milk, eggs, bread</p>
  <span aria-label="Due date: Today, 5:00 PM">Today, 5:00 PM</span>
</div>
```

### Keyboard Navigation

**Focus Order**:
1. Card container (Enter to open)
2. Checkbox (Space to toggle)
3. Action menu (Enter to open)

**Shortcuts**:
- `Enter`: Open item detail
- `Space`: Toggle checkbox (tasks)
- `Delete`: Delete item (with confirmation)
- `e`: Edit item
- `Cmd/Ctrl + D`: Duplicate item

### Color Contrast

- Title on background: 11.6:1 (AAA)
- Content on background: 7.3:1 (AAA)
- Metadata on background: 4.6:1 (AA)
- Border accent: Decorative only, not relied upon for meaning

### Touch Targets

- Minimum: 48x48dp for all interactive elements
- Card itself: Minimum 64px height
- Checkbox: 44x44dp touch area (24x24dp visual)
- Action menu: 44x44dp touch area

## Usage Guidelines

### When to Use

- Displaying tasks, notes, or lists in main workspace
- Search results
- Space-specific item views
- Widget displays (mobile home screen)

### When NOT to Use

- Item detail view (use full-page layout)
- Inline editing (use expanded form)
- Quick capture modal (use simplified form)

### Best Practices

1. **Consistent Spacing**: Maintain 8px vertical gap between cards
2. **Truncation**: Always truncate long titles with ellipsis after 2 lines
3. **Metadata**: Show only essential metadata (space, date, tags)
4. **Performance**: Virtualize long lists (only render visible cards)
5. **Animations**: Keep subtle, don't distract from content

### Common Mistakes to Avoid

1. Don't overcrowd cards with too many badges/indicators
2. Don't make color distinction too bold (subtle accents only)
3. Don't hide important actions behind multiple taps
4. Don't forget loading states (skeleton cards)
5. Don't make touch targets too small (min 44x44dp)

## Implementation Example (Flutter)

```dart
// lib/widgets/item_card.dart

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const ItemCard({
    required this.item,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>();

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
          ? colors.primaryLight
          : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: _getItemTypeColor(),
            width: isSelected ? 6 : 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeadingElement(),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(),
                      if (item.hasContent) ...[
                        SizedBox(height: 4),
                        _buildContentPreview(),
                      ],
                      SizedBox(height: 8),
                      _buildMetadata(),
                    ],
                  ),
                ),
                _buildActionMenu(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getItemTypeColor() {
    switch (item.type) {
      case ItemType.task:
        return AppColors.lightTask;
      case ItemType.note:
        return AppColors.lightNote;
      case ItemType.list:
        return AppColors.lightList;
    }
  }

  Widget _buildLeadingElement() {
    if (item.type == ItemType.task) {
      return Checkbox(
        value: item.isCompleted,
        onChanged: (value) => item.toggleComplete(),
      );
    }
    return Icon(
      item.type == ItemType.note ? Icons.note : Icons.list,
      size: 20,
      color: _getItemTypeColor(),
    );
  }

  // Additional build methods...
}
```

## Related Documentation

- [Style Guide](../style-guide.md) - Design system foundation
- [Color Tokens](../tokens/colors.md) - Item type colors
- [Unified Item Management](../../features/unified-item-management/) - Feature context
- [Buttons Component](./buttons.md) - Action menu button specs

---

**Last Updated**: 2025-10-18 | **Version**: 1.0.0 | **Status**: Approved
