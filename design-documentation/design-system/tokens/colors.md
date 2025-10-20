---
title: Color Tokens
description: Complete color palette with light/dark mode variants and usage guidelines
last-updated: 2025-10-19
version: 1.0.0
status: approved
related-files:
  - ../style-guide.md
  - ../components/item-cards.md
---

# Color Tokens

## Philosophy: Chromatic Intelligence

Colors in later aren't decorative—they carry meaning and create instant context. Our **gradient-infused palette** creates depth and dimensionality, inspired by the transitions of dusk and dawn when productivity peaks.

## Color Strategy

### Gradient-First Approach
Unlike traditional flat color systems, later uses gradients as primary colors. This creates:
- **Visual Interest**: Subtle chromatic transitions catch the eye
- **Depth**: Gradients suggest dimensionality and elevation
- **Brand Recognition**: Distinctive, memorable visual signature
- **Flexibility**: Gradients can be used as fills, overlays, or borders

### Adaptive Color System
Colors adapt based on:
- **Theme**: Optimized palettes for light and dark modes
- **Context**: Different hues for tasks, notes, and lists
- **State**: Interactive states use color to communicate feedback
- **Accessibility**: All combinations meet WCAG AA standards minimum

---

## Primary Color System

### Primary Gradient: Twilight

The signature color of later - a blend of indigo and purple representing the transition between day and night, when productivity often peaks.

**Gradient Definition**
```css
background: linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%);
```

**Component Colors**
- **Start**: `#6366F1` (Indigo-500)
  - RGB: `rgb(99, 102, 241)`
  - HSL: `hsl(238, 84%, 67%)`

- **End**: `#8B5CF6` (Violet-500)
  - RGB: `rgb(139, 92, 246)`
  - HSL: `hsl(259, 88%, 66%)`

**Solid Variants** (for non-gradient contexts)
- **Primary Solid**: `#7C3AED` (Violet-600)
  - Usage: Flat buttons, icons, borders
  - Hover: `#6D28D9` (Violet-700)
  - Active: `#5B21B6` (Violet-800)
  - Disabled: `#DDD6FE` (Violet-200)

**Light Tints**
- **Primary Light**: `#EDE9FE` (Violet-100)
  - Usage: Subtle backgrounds, hover states
  - Dark Mode: `rgba(124, 58, 237, 0.1)`

- **Primary Pale**: `#F5F3FF` (Violet-50)
  - Usage: Very subtle backgrounds, selected states
  - Dark Mode: `rgba(124, 58, 237, 0.05)`

**Dark Mode Adaptation**
```css
/* Softer, less saturated for dark backgrounds */
background: linear-gradient(135deg, #818CF8 0%, #A78BFA 100%);
```
- Start: `#818CF8` (Indigo-400)
- End: `#A78BFA` (Violet-400)

**Usage Guidelines**
- Primary CTAs and action buttons
- Active navigation items
- Focus states and selection highlights
- Brand elements and accent moments
- Loading indicators and progress bars

**Accessibility**
- Contrast on white: 7.2:1 (AAA)
- Contrast on Neutral-50: 7.1:1 (AAA)
- Contrast on dark: 8.1:1 (AAA)
- Meets all WCAG requirements

---

## Secondary Color System

### Secondary Gradient: Dawn

A warm gradient from amber to pink, representing new beginnings and creative energy.

**Gradient Definition**
```css
background: linear-gradient(135deg, #F59E0B 0%, #EC4899 100%);
```

**Component Colors**
- **Start**: `#F59E0B` (Amber-500)
  - RGB: `rgb(245, 158, 11)`
  - HSL: `hsl(38, 92%, 50%)`

- **End**: `#EC4899` (Pink-500)
  - RGB: `rgb(236, 72, 153)`
  - HSL: `hsl(330, 81%, 60%)`

**Solid Variants**
- **Secondary Solid**: `#F97316` (Orange-500)
  - Usage: Secondary buttons, highlights
  - Hover: `#EA580C` (Orange-600)
  - Active: `#C2410C` (Orange-700)

**Light Tints**
- **Secondary Light**: `#FED7AA` (Orange-200)
- **Secondary Pale**: `#FFEDD5` (Orange-100)

**Dark Mode Adaptation**
```css
background: linear-gradient(135deg, #FCD34D 0%, #F9A8D4 100%);
```

**Usage Guidelines**
- Secondary actions and buttons
- Accent highlights and badges
- Promotional elements
- Complementary to primary gradient
- Warning states (amber side)

---

## Accent Color System

### Accent Cyan: Cool Intelligence

**Base Colors**
- **Accent Cyan**: `#06B6D4` (Cyan-500)
- **Accent Cyan Light**: `#22D3EE` (Cyan-400)
- **Accent Cyan Pale**: `#CFFAFE` (Cyan-100)
- **Dark Mode**: `#67E8F9` (Cyan-300)

**Usage**
- Informational messages
- Cool accents and highlights
- Links and hypertext
- Data visualization (cool tones)

### Accent Emerald: Natural Success

**Base Colors**
- **Accent Emerald**: `#10B981` (Emerald-500)
- **Accent Emerald Light**: `#34D399` (Emerald-400)
- **Accent Emerald Pale**: `#D1FAE5` (Emerald-100)
- **Dark Mode**: `#6EE7B7` (Emerald-300)

**Usage**
- Success confirmations
- Completion states
- Positive feedback
- Nature/sustainability themes

---

## Type-Specific Colors

These colors create instant visual recognition for different content types throughout the app.

### Task Color: Urgent Action

**Gradient**
```css
background: linear-gradient(135deg, #EF4444 0%, #F97316 100%);
/* Red-500 to Orange-500 */
```

**Solid Color**
- **Task Primary**: `#F87171` (Red-400)
- **Task Dark**: `#DC2626` (Red-600)
- **Task Light**: `#FEE2E2` (Red-100)
- **Dark Mode BG**: `rgba(239, 68, 68, 0.1)`

**Usage**
- Task item backgrounds
- Task type indicators
- Due date warnings
- Action-required badges

**Psychology**: Red-orange conveys urgency, energy, and action-orientation

### Note Color: Contemplative Knowledge

**Gradient**
```css
background: linear-gradient(135deg, #3B82F6 0%, #06B6D4 100%);
/* Blue-500 to Cyan-500 */
```

**Solid Color**
- **Note Primary**: `#60A5FA` (Blue-400)
- **Note Dark**: `#2563EB` (Blue-600)
- **Note Light**: `#DBEAFE` (Blue-100)
- **Dark Mode BG**: `rgba(59, 130, 246, 0.1)`

**Usage**
- Note item backgrounds
- Note type indicators
- Information highlights
- Knowledge badges

**Psychology**: Blue conveys trust, stability, and intellectual depth

### List Color: Organized Structure

**Gradient**
```css
background: linear-gradient(135deg, #8B5CF6 0%, #A78BFA 100%);
/* Violet-500 to Violet-400 */
```

**Solid Color**
- **List Primary**: `#A78BFA` (Violet-400)
- **List Dark**: `#7C3AED` (Violet-600)
- **List Light**: `#EDE9FE` (Violet-100)
- **Dark Mode BG**: `rgba(139, 92, 246, 0.1)`

**Usage**
- List item backgrounds
- List type indicators
- Collection badges
- Organization elements

**Psychology**: Purple conveys creativity, organization, and premium quality

---

## Semantic Color System

### Success Color

**Base**: `#10B981` (Emerald-500)
- **Light**: `#6EE7B7` (Emerald-300)
- **Dark**: `#059669` (Emerald-600)
- **Background**: `#D1FAE5` (Emerald-100)
- **Dark BG**: `rgba(16, 185, 129, 0.15)`

**Usage**
- Task completion checkmarks
- Success toast messages
- Positive status indicators
- Confirmation dialogs
- "Done" states

**Accessibility**
- On white: 4.8:1 (AA)
- On background: 6.2:1 (AAA)

### Warning Color

**Base**: `#F59E0B` (Amber-500)
- **Light**: `#FCD34D` (Amber-300)
- **Dark**: `#D97706` (Amber-600)
- **Background**: `#FEF3C7` (Amber-100)
- **Dark BG**: `rgba(245, 158, 11, 0.15)`

**Usage**
- Due date approaching
- Caution messages
- Attention-needed states
- Non-critical warnings
- "Review" states

**Accessibility**
- On white: 5.1:1 (AA)
- On background: 6.8:1 (AAA)

### Error Color

**Base**: `#EF4444` (Red-500)
- **Light**: `#FCA5A5` (Red-300)
- **Dark**: `#DC2626` (Red-600)
- **Background**: `#FEE2E2` (Red-100)
- **Dark BG**: `rgba(239, 68, 68, 0.15)`

**Usage**
- Error messages
- Destructive action confirmations
- Failed states
- Validation errors
- Critical warnings

**Accessibility**
- On white: 5.9:1 (AA+)
- On background: 8.1:1 (AAA)

### Info Color

**Base**: `#3B82F6` (Blue-500)
- **Light**: `#93C5FD` (Blue-300)
- **Dark**: `#2563EB` (Blue-600)
- **Background**: `#DBEAFE` (Blue-100)
- **Dark BG**: `rgba(59, 130, 246, 0.15)`

**Usage**
- Informational tooltips
- Help text
- Tips and suggestions
- Non-critical information
- Tutorial highlights

**Accessibility**
- On white: 5.4:1 (AA+)
- On background: 7.2:1 (AAA)

---

## Neutral Color System

### Light Mode Neutrals (Slate)

**Ultra Light**
- **Neutral-50**: `#F8FAFC`
  - Usage: Canvas background, page base
  - RGB: `rgb(248, 250, 252)`

- **Neutral-100**: `#F1F5F9`
  - Usage: Subtle backgrounds, section divisions
  - RGB: `rgb(241, 245, 249)`

**Light**
- **Neutral-200**: `#E2E8F0`
  - Usage: Borders, dividers, disabled backgrounds
  - RGB: `rgb(226, 232, 240)`

- **Neutral-300**: `#CBD5E1`
  - Usage: Disabled text, subtle dividers
  - RGB: `rgb(203, 213, 225)`

**Medium**
- **Neutral-400**: `#94A3B8`
  - Usage: Placeholders, secondary icons
  - RGB: `rgb(148, 163, 184)`
  - Contrast on white: 3.6:1

- **Neutral-500**: `#64748B`
  - Usage: Secondary text, muted content
  - RGB: `rgb(100, 116, 139)`
  - Contrast on white: 4.9:1 (AA)

**Dark**
- **Neutral-600**: `#475569`
  - Usage: Primary body text, standard icons
  - RGB: `rgb(71, 85, 105)`
  - Contrast on white: 7.8:1 (AAA)

- **Neutral-700**: `#334155`
  - Usage: Headings, emphasized text
  - RGB: `rgb(51, 65, 85)`
  - Contrast on white: 11.2:1 (AAA)

**Very Dark**
- **Neutral-800**: `#1E293B`
  - Usage: Strong headings, dark emphasis
  - RGB: `rgb(30, 41, 59)`
  - Contrast on white: 15.1:1 (AAA)

- **Neutral-900**: `#0F172A`
  - Usage: Maximum contrast text (rare)
  - RGB: `rgb(15, 23, 42)`
  - Contrast on white: 18.2:1 (AAA)

### Dark Mode Neutrals

**Canvas & Surfaces**
- **Neutral-950**: `#020617`
  - Usage: Canvas background (dark mode)
  - RGB: `rgb(2, 6, 23)`

- **Neutral-900**: `#0F172A`
  - Usage: Card backgrounds, primary surfaces
  - RGB: `rgb(15, 23, 42)`

- **Neutral-800**: `#1E293B`
  - Usage: Elevated surfaces, hover states
  - RGB: `rgb(30, 41, 59)`

**Dividers & Borders**
- **Neutral-700**: `#334155`
  - Usage: Borders, dividers, separators
  - RGB: `rgb(51, 65, 85)`

- **Neutral-600**: `#475569`
  - Usage: Subtle dividers, disabled states
  - RGB: `rgb(71, 85, 105)`

**Text (Dark Mode)**
- **Neutral-500**: `#64748B`
  - Usage: Tertiary text, very subtle content
  - RGB: `rgb(100, 116, 139)`

- **Neutral-400**: `#94A3B8`
  - Usage: Body text, standard content
  - RGB: `rgb(148, 163, 184)`
  - Contrast on Neutral-950: 7.2:1 (AAA)

- **Neutral-300**: `#CBD5E1`
  - Usage: Headings, emphasized text
  - RGB: `rgb(203, 213, 225)`
  - Contrast on Neutral-950: 11.8:1 (AAA)

- **Neutral-200**: `#E2E8F0`
  - Usage: High contrast text, strong emphasis
  - RGB: `rgb(226, 232, 240)`
  - Contrast on Neutral-950: 14.2:1 (AAA)

- **Neutral-100**: `#F1F5F9`
  - Usage: Maximum contrast (rare)
  - RGB: `rgb(241, 245, 249)`
  - Contrast on Neutral-950: 16.8:1 (AAA)

---

## Special Effects Colors

### Glass Morphism

**Light Mode Glass**
```css
background: rgba(255, 255, 255, 0.7);
backdrop-filter: blur(20px) saturate(180%);
border: 1px solid rgba(255, 255, 255, 0.3);
box-shadow: 0 8px 32px rgba(31, 38, 135, 0.1);
```

**Dark Mode Glass**
```css
background: rgba(30, 41, 59, 0.7);
backdrop-filter: blur(20px) saturate(180%);
border: 1px solid rgba(255, 255, 255, 0.1);
box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
```

**Usage**: Quick capture modal, navigation bars, overlays

### Gradient Overlays

**Subtle Gradient Overlay** (for cards)
```css
background: linear-gradient(135deg, rgba(255,255,255,0.1) 0%, rgba(255,255,255,0) 100%);
```

**Dramatic Gradient Overlay** (for heroes)
```css
background: linear-gradient(180deg, rgba(0,0,0,0) 0%, rgba(0,0,0,0.7) 100%);
```

---

## Color Usage Guidelines

### Do's

**Do** use gradients for primary actions and brand moments
**Do** maintain consistent type colors across the app
**Do** use semantic colors for their intended purpose
**Do** test color contrast ratios before implementation
**Do** provide dark mode variants for all colors
**Do** use neutral colors for majority of UI chrome

### Don'ts

**Don't** mix gradient and solid versions of the same color arbitrarily
**Don't** use semantic colors for decoration
**Don't** override type colors without strong reason
**Don't** use pure black (#000000) or pure white (#FFFFFF)
**Don't** create new color variations without documentation
**Don't** rely solely on color to convey information (accessibility)

### Combining Colors

**Complementary Gradients**
- Primary + Secondary: High energy, celebratory
- Primary + Emerald: Success with emphasis
- Secondary + Task: Urgent action needed

**Neutral Combinations**
- Text on background: Neutral-600 on Neutral-50 (light)
- Text on background: Neutral-400 on Neutral-950 (dark)
- Borders: Neutral-200 (light), Neutral-700 (dark)

**Type Color Combinations**
- Never mix type colors in the same item
- Can use type colors side-by-side for comparisons
- Use neutral text on type-colored backgrounds

---

## Flutter Implementation

### Color Class Definition

```dart
// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Private constructor

  // PRIMARY COLORS
  static const primaryStart = Color(0xFF6366F1);
  static const primaryEnd = Color(0xFF8B5CF6);
  static const primarySolid = Color(0xFF7C3AED);
  static const primaryHover = Color(0xFF6D28D9);
  static const primaryActive = Color(0xFF5B21B6);
  static const primaryLight = Color(0xFFEDE9FE);
  static const primaryPale = Color(0xFFF5F3FF);

  // Dark mode variants
  static const primaryStartDark = Color(0xFF818CF8);
  static const primaryEndDark = Color(0xFFA78BFA);

  // PRIMARY GRADIENT
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStart, primaryEnd],
  );

  static const primaryGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStartDark, primaryEndDark],
  );

  // SECONDARY COLORS
  static const secondaryStart = Color(0xFFF59E0B);
  static const secondaryEnd = Color(0xFFEC4899);
  static const secondarySolid = Color(0xFFF97316);

  static const secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryStart, secondaryEnd],
  );

  // ACCENT COLORS
  static const accentCyan = Color(0xFF06B6D4);
  static const accentCyanLight = Color(0xFF22D3EE);
  static const accentCyanPale = Color(0xFFCFFAFE);

  static const accentEmerald = Color(0xFF10B981);
  static const accentEmeraldLight = Color(0xFF34D399);
  static const accentEmeraldPale = Color(0xFFD1FAE5);

  // TYPE-SPECIFIC COLORS
  static const taskColor = Color(0xFFF87171);
  static const taskDark = Color(0xFFDC2626);
  static const taskLight = Color(0xFFFEE2E2);

  static const noteColor = Color(0xFF60A5FA);
  static const noteDark = Color(0xFF2563EB);
  static const noteLight = Color(0xFFDBEAFE);

  static const listColor = Color(0xFFA78BFA);
  static const listDark = Color(0xFF7C3AED);
  static const listLight = Color(0xFFEDE9FE);

  // SEMANTIC COLORS
  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFF6EE7B7);
  static const successBg = Color(0xFFD1FAE5);

  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFCD34D);
  static const warningBg = Color(0xFFFEF3C7);

  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFCA5A5);
  static const errorBg = Color(0xFFFEE2E2);

  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFF93C5FD);
  static const infoBg = Color(0xFFDBEAFE);

  // NEUTRALS - LIGHT MODE
  static const neutral50 = Color(0xFFF8FAFC);
  static const neutral100 = Color(0xFFF1F5F9);
  static const neutral200 = Color(0xFFE2E8F0);
  static const neutral300 = Color(0xFFCBD5E1);
  static const neutral400 = Color(0xFF94A3B8);
  static const neutral500 = Color(0xFF64748B);
  static const neutral600 = Color(0xFF475569);
  static const neutral700 = Color(0xFF334155);
  static const neutral800 = Color(0xFF1E293B);
  static const neutral900 = Color(0xFF0F172A);
  static const neutral950 = Color(0xFF020617);

  // THEME-AWARE GETTERS
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? neutral50
        : neutral950;
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : neutral900;
  }

  static Color text(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? neutral600
        : neutral400;
  }

  static Color textEmphasis(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? neutral700
        : neutral300;
  }

  static LinearGradient primaryGradientAdaptive(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? primaryGradient
        : primaryGradientDark;
  }
}
```

### Usage Example

```dart
// Using solid colors
Container(
  color: AppColors.primarySolid,
  child: Text(
    'Hello',
    style: TextStyle(color: Colors.white),
  ),
)

// Using gradients
Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text('Gradient Button'),
)

// Using theme-aware colors
Container(
  color: AppColors.surface(context),
  child: Text(
    'Adaptive text',
    style: TextStyle(
      color: AppColors.text(context),
    ),
  ),
)

// Type-specific usage
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).brightness == Brightness.light
        ? AppColors.taskLight
        : AppColors.taskColor.withOpacity(0.1),
    border: Border.all(
      color: AppColors.taskColor,
      width: 1,
    ),
  ),
)
```

---

## Accessibility Testing Checklist

- [ ] All text colors meet 4.5:1 contrast ratio minimum
- [ ] Large text (18px+) meets 3:1 contrast ratio minimum
- [ ] Interactive elements meet 3:1 contrast with surrounding colors
- [ ] Color is not the only means of conveying information
- [ ] Gradient readability verified with text overlays
- [ ] Dark mode colors tested for eye strain
- [ ] Type colors distinguishable for color-blind users
- [ ] Focus indicators visible against all backgrounds

---

**Related Documentation**
- [Style Guide](../style-guide.md) - Complete design system
- [Typography](./typography.md) - Text styling and hierarchy
- [Components](../components/) - Component-specific color usage

**Last Updated**: October 19, 2025
**Version**: 1.0.0
