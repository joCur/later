---
title: Drag Handle Component Design Specification
description: Visual drag handle affordance for content card reordering in the Later app
feature: drag-handle-reordering
last-updated: 2025-11-02
version: 1.0.0
related-files:
  - ../drag-handle/visual-specifications.md
  - ../drag-handle/interaction-specifications.md
  - ../drag-handle/implementation-guide.md
dependencies:
  - Card components (TodoListCard, NoteCard, ListCard)
  - Reorderable list implementation
  - Design system tokens (colors, spacing, typography)
status: approved
---

# Drag Handle Component Design Specification

## Overview

This document specifies the design for a visual drag handle component that enables users to reorder content cards (notes, todo lists, and lists) in the Later app. The drag handle addresses UX issues with the current long-press-to-drag interaction by providing a discoverable, accessible, and intuitive drag affordance.

## Problem Statement

### Current Implementation Issues
- **No Visual Affordance**: Users don't know cards are draggable
- **Gesture Conflicts**: Long-press interferes with scrolling and pull-to-refresh
- **Discoverability**: Drag-and-drop functionality is hidden from users
- **Accessibility**: Long-press gesture is not screen reader accessible

### Design Goals
1. **Discoverability**: Make drag functionality immediately visible
2. **Accessibility**: Meet WCAG 2.1 AA standards (48×48px touch target)
3. **Aesthetic Harmony**: Integrate seamlessly with mobile-first bold design
4. **Type Differentiation**: Work with all three card types and their gradients
5. **Non-Intrusive**: Maintain card's clean, uncluttered appearance

## Quick Reference

### Visual Summary
- **Handle Style**: Vertical grip dots (3 rows of 2 dots)
- **Placement**: Right side (trailing edge) of card
- **Size**: 48×48px touch target (visible icon: 20×24px)
- **Colors**: Type-specific gradient with subtle opacity
- **States**: Default (40% opacity), Hover (60% opacity), Active (100% opacity, drag cursor)

### Key Specifications
- **Touch Target**: 48×48px (WCAG AA compliant)
- **Visual Icon**: 20×24px (3 rows × 2 columns of 4px dots)
- **Dot Spacing**: 4px horizontal gap, 6px vertical gap between rows
- **Border Radius**: 2px per dot (subtle rounding)
- **Animation**: 150ms ease-out for opacity transitions

## Design Rationale

### Why Vertical Grip Dots?
1. **Universal Recognition**: Industry-standard drag handle pattern (Material Design, iOS)
2. **Vertical Emphasis**: Reinforces vertical reordering action
3. **Compact Footprint**: Minimal space consumption (20×24px)
4. **Gradient Compatible**: Dots work beautifully with gradient shader masks
5. **Clear Intent**: Unmistakably indicates draggable functionality

### Why Right Side Placement?
1. **Thumb Ergonomics**: Right-handed users (90%) can easily reach
2. **Non-Blocking**: Doesn't interfere with icon or content reading
3. **Consistent Pattern**: Matches iOS and Android conventions
4. **Visual Balance**: Complements leading icon on left side
5. **Scrolling Freedom**: Allows left-side scroll gestures

### Why Type-Specific Gradients?
1. **Visual Continuity**: Matches card's gradient border treatment
2. **Type Recognition**: Reinforces content type identity
3. **Design Cohesion**: Maintains mobile-first bold aesthetic
4. **Subtle Presence**: 40% opacity keeps handle non-intrusive
5. **Active Feedback**: 100% opacity on drag provides clear engagement

## Design System Integration

### Color Tokens
The drag handle uses existing gradient tokens from the design system:

- **TodoListCard**: `AppColors.taskGradient` (Red-Orange)
- **NoteCard**: `AppColors.noteGradient` (Blue-Cyan)
- **ListCard**: `AppColors.listGradient` (Purple-Lavender)

### Spacing Tokens
- **Touch target**: `48px` (WCAG minimum)
- **Icon size**: `20×24px` (visible area)
- **Dot size**: `4px` diameter
- **Horizontal gap**: `AppSpacing.xxs` (4px)
- **Vertical gap**: `6px` (custom for visual balance)
- **Dot radius**: `2px` (subtle rounding)

### Animation Tokens
- **Opacity transition**: `150ms` with `Curves.easeOut`
- **Drag start**: `100ms` scale animation to 1.05
- **Active state**: Gradient at 100% opacity with drag cursor

## Accessibility Compliance

### WCAG 2.1 AA Standards
- ✓ **Minimum Touch Target**: 48×48px exceeds 44×44px minimum
- ✓ **Color Contrast**: Gradient at 60% opacity meets 3:1 ratio on surface backgrounds
- ✓ **Screen Reader Support**: Semantic label "Drag to reorder [item name]"
- ✓ **Keyboard Navigation**: Alternative keyboard reordering via arrow keys
- ✓ **Focus Indicator**: 2px outline in focus color when keyboard focused
- ✓ **Motion Sensitivity**: Respects `prefers-reduced-motion` (instant opacity changes)

### Semantic Labels
```dart
// TodoList handle
'Drag to reorder todo list: ${todoList.name}'

// Note handle
'Drag to reorder note: ${note.title}'

// List handle
'Drag to reorder list: ${list.name}'
```

## Component Variants

### Default State (Not Dragging)
- **Opacity**: 40% (subtle but visible)
- **Cursor**: Default pointer
- **Purpose**: Indicates draggable affordance without visual clutter

### Hover State (Desktop/Web)
- **Opacity**: 60% (stronger presence)
- **Cursor**: Grab cursor (`SystemMouseCursors.grab`)
- **Transition**: 150ms ease-out
- **Purpose**: Reinforces interactivity on hover-capable devices

### Active State (Dragging)
- **Opacity**: 100% (full gradient intensity)
- **Cursor**: Grabbing cursor (`SystemMouseCursors.grabbing`)
- **Scale**: 1.05 (subtle lift effect)
- **Purpose**: Clear visual feedback during drag operation

### Disabled State (Read-Only Mode)
- **Opacity**: 0% (completely hidden)
- **Interactive**: False
- **Purpose**: Hide handle when reordering is disabled

## Platform Considerations

### Mobile (Primary Target)
- **Touch Target**: Full 48×48px for thumb-friendly interaction
- **Haptic Feedback**: Light haptic on drag start (`HapticFeedback.lightImpact`)
- **Visual Feedback**: Opacity + scale animation for drag confirmation
- **Gesture Priority**: Handle takes precedence over card tap in gesture arena

### Desktop/Web (Secondary)
- **Hover States**: Show enhanced opacity (60%) on mouse hover
- **Cursors**: Grab/grabbing cursors for clear drag affordance
- **Keyboard Alternative**: Arrow keys for reordering (handle is focusable)
- **Screen Reader**: Full ARIA support with semantic labels

## Performance Optimizations

### Rendering Strategy
- **RepaintBoundary**: Isolate handle from card repaints
- **Const constructors**: Use const wherever possible
- **Shader caching**: Cache gradient shaders for 60fps performance
- **Animation optimization**: Use `AnimatedOpacity` for GPU-accelerated transitions

### Memory Efficiency
- **Shared gradients**: Reuse gradient instances across cards
- **Lazy rendering**: Only render when card is visible
- **Dispose cleanly**: Properly dispose animation controllers

## Related Documentation

For detailed specifications, see:
- [Visual Specifications](./visual-specifications.md) - Complete visual design details
- [Interaction Specifications](./interaction-specifications.md) - Interaction states and animations
- [Implementation Guide](./implementation-guide.md) - Flutter implementation guidelines

## Approval & Sign-Off

**Design Status**: ✓ Approved for Implementation
**Design Date**: 2025-11-02
**Design Version**: 1.0.0

**Next Steps**:
1. Review visual specifications document
2. Review interaction specifications document
3. Implement `DragHandleWidget` component
4. Integrate into card components
5. Test accessibility compliance
6. Conduct user testing for discoverability
