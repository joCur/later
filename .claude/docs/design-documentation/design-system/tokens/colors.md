---
title: Color Tokens
description: Complete color palette specifications for Later app with light and dark mode variants
version: 1.0.0
last-updated: 2025-10-18
status: approved
related-files:
  - ../style-guide.md
  - ./typography.md
---

# Color Tokens

## Overview

Later's color system is designed for:
- **Accessibility**: WCAG AA compliance minimum (AAA for critical elements)
- **Flexibility**: Supports light and dark modes seamlessly
- **Clarity**: Visual distinction between item types without overwhelming
- **Brand**: Cohesive, modern, professional aesthetic

## Implementation in Flutter

```dart
// lib/core/theme/colors.dart

class AppColors {
  // Light mode colors
  static const lightPrimary = Color(0xFF6366F1);
  static const lightPrimaryDark = Color(0xFF4F46E5);
  static const lightPrimaryLight = Color(0xFFE0E7FF);

  // Dark mode colors
  static const darkPrimary = Color(0xFF818CF8);
  static const darkPrimaryDark = Color(0xFF6366F1);
  static const darkPrimaryLight = Color(0xFF312E81);

  // ... (see full implementation below)
}
```

## Primary Colors

### Primary (Indigo)

**Purpose**: Main brand color, primary CTAs, active states, focus indicators

| Context | Light Mode | Dark Mode | Contrast Ratio |
|---------|-----------|-----------|----------------|
| Primary | `#6366F1` | `#818CF8` | 4.5:1 on white |
| Primary Dark | `#4F46E5` | `#6366F1` | 5.2:1 on white |
| Primary Light | `#E0E7FF` | `#312E81` | Background use |

**Usage Examples**:
- Primary action buttons
- Active navigation items
- Selected space indicators
- Focus rings and outlines
- Progress indicators

**Accessibility Notes**:
- Light primary (#6366F1) on white: 4.6:1 (AA compliant)
- Dark primary (#818CF8) on dark background: 7.2:1 (AAA compliant)
- Never use primary-light for text on white

### Color Combinations

**Safe Text Combinations**:
- `#FFFFFF` (white) on `#6366F1` (primary) - 4.6:1 ✓
- `#FFFFFF` (white) on `#4F46E5` (primary-dark) - 5.3:1 ✓✓
- `#6366F1` (primary) on `#E0E7FF` (primary-light) - 3.8:1 (large text only)

## Secondary Colors

### Secondary (Violet)

**Purpose**: Supporting elements, secondary actions, decorative accents

| Context | Light Mode | Dark Mode | Contrast Ratio |
|---------|-----------|-----------|----------------|
| Secondary | `#8B5CF6` | `#A78BFA` | 4.5:1 on white |
| Secondary Light | `#EDE9FE` | `#3B0764` | Background use |
| Secondary Pale | `#F5F3FF` | `#2E1065` | Background use |

**Usage Examples**:
- Secondary buttons and actions
- Tags and labels
- Decorative elements
- Accent borders
- Alternative CTAs

**Accessibility Notes**:
- Light secondary (#8B5CF6) on white: 4.7:1 (AA compliant)
- Use on dark backgrounds for better contrast
- Pale variants only for backgrounds, never text

## Accent Colors

### Accent Primary (Amber)

**Purpose**: Important notifications, quick capture, pending states

| Context | Light Mode | Dark Mode |
|---------|-----------|-----------|
| Accent Primary | `#F59E0B` | `#FCD34D` |

**Usage Examples**:
- Quick capture floating button
- Important notifications
- Pending sync indicators
- Warning states
- Attention-grabbing elements

**Accessibility Notes**:
- Light accent (#F59E0B) on white: 3.2:1 (large text only)
- Use `#D97706` (Amber-600) for AA-compliant text
- Dark accent (#FCD34D) has excellent contrast on dark backgrounds

### Accent Secondary (Teal)

**Purpose**: Success states, completed items, online status

| Context | Light Mode | Dark Mode |
|---------|-----------|-----------|
| Accent Secondary | `#14B8A6` | `#5EEAD4` |

**Usage Examples**:
- Completed task indicators
- Success messages
- Online/synced status
- Positive feedback
- Active connections

## Semantic Colors

### Success (Emerald)

**Purpose**: Positive actions, confirmations, successful operations

| Context | Light Mode | Dark Mode | Usage |
|---------|-----------|-----------|-------|
| Success | `#10B981` | `#34D399` | Icons, text, borders |
| Success Light | `#D1FAE5` | `#065F46` | Backgrounds |

**Usage Examples**:
- Success toast messages
- Completed state indicators
- Sync complete status
- Form validation success
- Positive feedback

**Accessibility**:
- Success on white: 3.9:1 (large text or icons)
- Use `#059669` (Emerald-600) for body text

### Warning (Amber)

**Purpose**: Caution states, alerts, unsaved changes

| Context | Light Mode | Dark Mode | Usage |
|---------|-----------|-----------|-------|
| Warning | `#F59E0B` | `#FBBF24` | Icons, text, borders |
| Warning Light | `#FEF3C7` | `#78350F` | Backgrounds |

**Usage Examples**:
- Warning messages
- Unsaved changes indicators
- Sync pending status
- Cautionary alerts
- Validation warnings

**Accessibility**:
- Use `#D97706` (Amber-600) for AA-compliant warning text
- Warning light only for backgrounds

### Error (Red)

**Purpose**: Errors, destructive actions, critical alerts

| Context | Light Mode | Dark Mode | Usage |
|---------|-----------|-----------|-------|
| Error | `#EF4444` | `#F87171` | Icons, text, borders |
| Error Light | `#FEE2E2` | `#7F1D1D` | Backgrounds |

**Usage Examples**:
- Error messages
- Destructive action buttons (delete)
- Sync failed status
- Form validation errors
- Critical alerts

**Accessibility**:
- Error on white: 3.9:1 (icons and large text)
- Use `#DC2626` (Red-600) for body text

### Info (Blue)

**Purpose**: Informational messages, tips, help text

| Context | Light Mode | Dark Mode | Usage |
|---------|-----------|-----------|-------|
| Info | `#3B82F6` | `#60A5FA` | Icons, text, borders |
| Info Light | `#DBEAFE` | `#1E3A8A` | Backgrounds |

**Usage Examples**:
- Informational toasts
- Tips and help text
- Feature announcements
- Onboarding hints
- Tutorial highlights

## Neutral Palette

### Light Mode Neutrals

| Token | Hex | Usage |
|-------|-----|-------|
| Neutral-50 | `#FAFAFA` | App background, subtle fills |
| Neutral-100 | `#F5F5F5` | Card backgrounds, hover states |
| Neutral-200 | `#E5E5E5` | Borders, dividers, separators |
| Neutral-300 | `#D4D4D4` | Disabled borders, subtle lines |
| Neutral-400 | `#A3A3A3` | Placeholder text, subtle icons |
| Neutral-500 | `#737373` | Secondary text, captions, metadata |
| Neutral-600 | `#525252` | Body text, labels, standard text |
| Neutral-700 | `#404040` | Primary text, headings, emphasis |
| Neutral-800 | `#262626` | High emphasis text, titles |
| Neutral-900 | `#171717` | Maximum emphasis, important text |

### Dark Mode Neutrals

| Token | Hex | Usage |
|-------|-----|-------|
| Neutral-50 | `#18181B` | App background, base surface |
| Neutral-100 | `#27272A` | Card backgrounds, elevated surfaces |
| Neutral-200 | `#3F3F46` | Borders, dividers, separators |
| Neutral-300 | `#52525B` | Disabled borders, subtle lines |
| Neutral-400 | `#71717A` | Placeholder text, subtle icons |
| Neutral-500 | `#A1A1AA` | Secondary text, captions, metadata |
| Neutral-600 | `#D4D4D8` | Body text, labels, standard text |
| Neutral-700 | `#E4E4E7` | Primary text, headings, emphasis |
| Neutral-800 | `#F4F4F5` | High emphasis text, titles |
| Neutral-900 | `#FAFAFA` | Maximum emphasis, important text |

### Neutral Usage Guidelines

**Backgrounds**:
- Primary background: Neutral-50 (light) / Neutral-50 (dark)
- Card background: White (light) / Neutral-100 (dark)
- Hover background: Neutral-100 (light) / Neutral-200 (dark)

**Text**:
- Primary text: Neutral-900 (light) / Neutral-900 (dark)
- Secondary text: Neutral-600 (light) / Neutral-600 (dark)
- Placeholder: Neutral-400 (light) / Neutral-400 (dark)

**Borders**:
- Default: Neutral-200 (light) / Neutral-200 (dark)
- Focus: Primary color
- Error: Error color

## Item Type Colors

### Purpose

Visually distinguish tasks, notes, and lists without overwhelming the interface. Colors are used subtly in:
- Left border accent (4px)
- Icon tint
- Type badge (optional, can be hidden)

### Task Color (Blue)

| Context | Light Mode | Dark Mode |
|---------|-----------|-----------|
| Task | `#3B82F6` | `#60A5FA` |
| Task Light | `#DBEAFE` | `#1E3A8A` |

**Usage**: Task items, task icons, task filters

### Note Color (Amber)

| Context | Light Mode | Dark Mode |
|---------|-----------|-----------|
| Note | `#F59E0B` | `#FBBF24` |
| Note Light | `#FEF3C7` | `#78350F` |

**Usage**: Note items, note icons, note filters

### List Color (Violet)

| Context | Light Mode | Dark Mode |
|---------|-----------|-----------|
| List | `#8B5CF6` | `#A78BFA` |
| List Light | `#EDE9FE` | `#3B0764` |

**Usage**: List items, list icons, list filters

### Item Type Implementation

**Subtle Approach** (Recommended):
- 4px left border in item type color
- Icon uses item type color
- Background remains neutral
- Type badge shown only when filtering or in mixed views

**Bold Approach** (Optional):
- Full background tint using `[Type]-Light` color
- Colored border
- Colored icon
- Use sparingly to avoid overwhelming interface

## Gradient System

### Primary Gradient

**Gradient**: Indigo to Violet
- Start: `#6366F1` (Indigo-500)
- End: `#8B5CF6` (Violet-500)
- Angle: 135deg (diagonal)

**Usage**:
- Premium features highlight
- Onboarding screens
- Hero sections
- Special promotions
- Celebratory moments

### Subtle Gradient

**Gradient**: Light Indigo to Light Violet
- Start: `#E0E7FF` (Indigo-100)
- End: `#EDE9FE` (Violet-100)
- Angle: 135deg

**Usage**:
- Background accents
- Card headers
- Feature highlights
- Subtle emphasis

## Color Accessibility Matrix

### WCAG AA Compliance

| Foreground | Background | Ratio | Pass |
|-----------|-----------|-------|------|
| Neutral-900 | White | 21:1 | ✓✓✓ AAA |
| Neutral-700 | White | 11.6:1 | ✓✓✓ AAA |
| Neutral-600 | White | 7.3:1 | ✓✓ AAA |
| Primary | White | 4.6:1 | ✓ AA |
| Success | White | 3.9:1 | ~ Large text |
| Error | White | 3.9:1 | ~ Large text |

### Color Blind Considerations

**Protanopia/Deuteranopia** (Red-Green):
- Never rely solely on red/green distinction
- Use icons with semantic colors
- Use patterns or text labels

**Tritanopia** (Blue-Yellow):
- Primary (blue) and warning (amber) are distinguishable
- Use multiple visual cues beyond color

**Testing Tools**:
- Coblis Color Blindness Simulator
- Color Oracle (desktop app)
- Chrome DevTools vision deficiency emulation

## Implementation Example (Flutter)

```dart
// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color lightPrimary = Color(0xFF6366F1);
  static const Color lightPrimaryDark = Color(0xFF4F46E5);
  static const Color lightPrimaryLight = Color(0xFFE0E7FF);

  static const Color darkPrimary = Color(0xFF818CF8);
  static const Color darkPrimaryDark = Color(0xFF6366F1);
  static const Color darkPrimaryLight = Color(0xFF312E81);

  // Secondary Colors
  static const Color lightSecondary = Color(0xFF8B5CF6);
  static const Color lightSecondaryLight = Color(0xFFEDE9FE);

  static const Color darkSecondary = Color(0xFFA78BFA);
  static const Color darkSecondaryLight = Color(0xFF3B0764);

  // Semantic Colors
  static const Color lightSuccess = Color(0xFF10B981);
  static const Color darkSuccess = Color(0xFF34D399);

  static const Color lightWarning = Color(0xFFF59E0B);
  static const Color darkWarning = Color(0xFFFBBF24);

  static const Color lightError = Color(0xFFEF4444);
  static const Color darkError = Color(0xFFF87171);

  static const Color lightInfo = Color(0xFF3B82F6);
  static const Color darkInfo = Color(0xFF60A5FA);

  // Item Type Colors
  static const Color lightTask = Color(0xFF3B82F6);
  static const Color darkTask = Color(0xFF60A5FA);

  static const Color lightNote = Color(0xFFF59E0B);
  static const Color darkNote = Color(0xFFFBBF24);

  static const Color lightList = Color(0xFF8B5CF6);
  static const Color darkList = Color(0xFFA78BFA);

  // Neutrals (Light Mode)
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // Neutrals (Dark Mode)
  static const Color darkNeutral50 = Color(0xFF18181B);
  static const Color darkNeutral100 = Color(0xFF27272A);
  static const Color darkNeutral200 = Color(0xFF3F3F46);
  static const Color darkNeutral300 = Color(0xFF52525B);
  static const Color darkNeutral400 = Color(0xFF71717A);
  static const Color darkNeutral500 = Color(0xFFA1A1AA);
  static const Color darkNeutral600 = Color(0xFFD4D4D8);
  static const Color darkNeutral700 = Color(0xFFE4E4E7);
  static const Color darkNeutral800 = Color(0xFFF4F4F5);
  static const Color darkNeutral900 = Color(0xFFFAFAFA);
}
```

## Related Documentation

- [Style Guide](../style-guide.md) - Complete design system
- [Typography Tokens](./typography.md) - Type system with color usage
- [Component Library](../components/) - Components using these colors

---

**Last Updated**: 2025-10-18 | **Version**: 1.0.0 | **Status**: Approved
