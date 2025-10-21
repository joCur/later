# Design Tokens Reference - Mobile-First Bold Redesign

Quick reference guide for all design tokens used in the Later mobile-first redesign. This document consolidates colors, spacing, typography, shadows, and other design primitives in one place.

---

## Color System

### Neutral Colors (Slate Scale)

| Token | Hex Code | RGB | Usage |
|-------|----------|-----|-------|
| **Neutral-50** | `#F8FAFC` | `rgb(248, 250, 252)` | Canvas background, page base |
| **Neutral-100** | `#F1F5F9` | `rgb(241, 245, 249)` | Subtle backgrounds, section divisions |
| **Neutral-200** | `#E2E8F0` | `rgb(226, 232, 240)` | Borders, dividers, disabled backgrounds |
| **Neutral-300** | `#CBD5E1` | `rgb(203, 213, 225)` | Disabled text, subtle dividers |
| **Neutral-400** | `#94A3B8` | `rgb(148, 163, 184)` | Placeholders, secondary icons |
| **Neutral-500** | `#64748B` | `rgb(100, 116, 139)` | Secondary text, muted content |
| **Neutral-600** | `#475569` | `rgb(71, 85, 105)` | Primary body text, standard icons |
| **Neutral-700** | `#334155` | `rgb(51, 65, 85)` | Headings, emphasized text |
| **Neutral-800** | `#1E293B` | `rgb(30, 41, 59)` | Strong headings, dark emphasis |
| **Neutral-900** | `#0F172A` | `rgb(15, 23, 42)` | Maximum contrast text |
| **Neutral-950** | `#020617` | `rgb(2, 6, 23)` | Dark mode canvas |

### Primary Colors

**Primary Gradient: Twilight**
```css
linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%)
```

| Token | Hex Code | RGB | Usage |
|-------|----------|-----|-------|
| **Primary Start** | `#6366F1` | `rgb(99, 102, 241)` | Indigo-500 - Gradient start |
| **Primary End** | `#8B5CF6` | `rgb(139, 92, 246)` | Violet-500 - Gradient end |
| **Primary Solid** | `#7C3AED` | `rgb(124, 58, 237)` | Violet-600 - Flat buttons, icons |
| **Primary Hover** | `#6D28D9` | `rgb(109, 40, 217)` | Violet-700 - Hover states |
| **Primary Active** | `#5B21B6` | `rgb(91, 33, 182)` | Violet-800 - Active states |
| **Primary Light** | `#EDE9FE` | `rgb(237, 233, 254)` | Violet-100 - Subtle backgrounds |
| **Primary Pale** | `#F5F3FF` | `rgb(245, 243, 255)` | Violet-50 - Very subtle backgrounds |

**Dark Mode Variants**
```css
linear-gradient(135deg, #818CF8 0%, #A78BFA 100%)
```

| Token | Hex Code | Usage |
|-------|----------|-------|
| **Primary Start Dark** | `#818CF8` | Indigo-400 - Dark mode gradient start |
| **Primary End Dark** | `#A78BFA` | Violet-400 - Dark mode gradient end |

### Semantic Colors

#### Success (Emerald)
| Token | Hex Code | RGB | Usage |
|-------|----------|-----|-------|
| **Success** | `#10B981` | `rgb(16, 185, 129)` | Emerald-500 - Success states |
| **Success Light** | `#6EE7B7` | `rgb(110, 231, 183)` | Emerald-300 - Light variant |
| **Success Dark** | `#059669` | `rgb(5, 150, 105)` | Emerald-600 - Dark variant |
| **Success BG** | `#D1FAE5` | `rgb(209, 250, 229)` | Emerald-100 - Background |

#### Warning (Amber)
| Token | Hex Code | RGB | Usage |
|-------|----------|-----|-------|
| **Warning** | `#F59E0B` | `rgb(245, 158, 11)` | Amber-500 - Warning states |
| **Warning Light** | `#FCD34D` | `rgb(252, 211, 77)` | Amber-300 - Light variant |
| **Warning Dark** | `#D97706` | `rgb(217, 119, 6)` | Amber-600 - Dark variant |
| **Warning BG** | `#FEF3C7` | `rgb(254, 243, 199)` | Amber-100 - Background |

#### Error (Red)
| Token | Hex Code | RGB | Usage |
|-------|----------|-----|-------|
| **Error** | `#EF4444` | `rgb(239, 68, 68)` | Red-500 - Error states |
| **Error Light** | `#FCA5A5` | `rgb(252, 165, 165)` | Red-300 - Light variant |
| **Error Dark** | `#DC2626` | `rgb(220, 38, 38)` | Red-600 - Dark variant |
| **Error BG** | `#FEE2E2` | `rgb(254, 226, 226)` | Red-100 - Background |

#### Info (Blue)
| Token | Hex Code | RGB | Usage |
|-------|----------|-----|-------|
| **Info** | `#3B82F6` | `rgb(59, 130, 246)` | Blue-500 - Info states |
| **Info Light** | `#93C5FD` | `rgb(147, 197, 253)` | Blue-300 - Light variant |
| **Info Dark** | `#2563EB` | `rgb(37, 99, 235)` | Blue-600 - Dark variant |
| **Info BG** | `#DBEAFE` | `rgb(219, 234, 254)` | Blue-100 - Background |

### Type-Specific Gradients

#### Task Color: Urgent Action
```css
linear-gradient(135deg, #EF4444 0%, #F97316 100%)
/* Red-500 to Orange-500 */
```

| Token | Hex Code | RGB | Usage |
|-------|----------|-----|-------|
| **Task Primary** | `#F87171` | `rgb(248, 113, 113)` | Red-400 - Task items |
| **Task Dark** | `#DC2626` | `rgb(220, 38, 38)` | Red-600 - Dark variant |
| **Task Light** | `#FEE2E2` | `rgb(254, 226, 226)` | Red-100 - Background |

#### Note Color: Contemplative Knowledge
```css
linear-gradient(135deg, #3B82F6 0%, #06B6D4 100%)
/* Blue-500 to Cyan-500 */
```

| Token | Hex Code | RGB | Usage |
|-------|----------|-----|-------|
| **Note Primary** | `#60A5FA` | `rgb(96, 165, 250)` | Blue-400 - Note items |
| **Note Dark** | `#2563EB` | `rgb(37, 99, 235)` | Blue-600 - Dark variant |
| **Note Light** | `#DBEAFE` | `rgb(219, 234, 254)` | Blue-100 - Background |

#### List Color: Organized Structure
```css
linear-gradient(135deg, #8B5CF6 0%, #A78BFA 100%)
/* Violet-500 to Violet-400 */
```

| Token | Hex Code | RGB | Usage |
|-------|----------|-----|-------|
| **List Primary** | `#A78BFA` | `rgb(167, 139, 250)` | Violet-400 - List items |
| **List Dark** | `#7C3AED` | `rgb(124, 58, 237)` | Violet-600 - Dark variant |
| **List Light** | `#EDE9FE` | `rgb(237, 233, 254)` | Violet-100 - Background |

---

## Spacing Scale

Based on **4px base unit** - all values are multiples of 4.

| Token | Value | Multiplier | Dart Constant | Usage |
|-------|-------|------------|---------------|-------|
| **xxs** | `4px` | 1× | `AppSpacing.xxs` | Micro spacing, icon-text gaps |
| **xs** | `8px` | 2× | `AppSpacing.xs` | Internal padding, tight groupings |
| **sm** | `12px` | 3× | `AppSpacing.sm` | Small spacing, comfortable groupings |
| **md** | `16px` | 4× | `AppSpacing.md` | Standard spacing, default margins (DEFAULT) |
| **lg** | `24px` | 6× | `AppSpacing.lg` | Section spacing, card padding |
| **xl** | `32px` | 8× | `AppSpacing.xl` | Large spacing, major separations |
| **2xl** | `48px` | 12× | `AppSpacing.xxl` | Extra large spacing, screen padding |
| **3xl** | `64px` | 16× | `AppSpacing.xxxl` | Huge spacing, hero sections |
| **4xl** | `96px` | 24× | `AppSpacing.xxxxl` | Maximum spacing, full-bleed sections |

### Common Usage Patterns

**Card Padding**
- Mobile: `16px` (md)
- Tablet: `24px` (lg)
- Desktop: `24px` (lg)

**Screen Padding**
- Mobile: `16px` (md)
- Tablet: `32px` (xl)
- Desktop: `48px` (2xl)

**List Spacing**
- Compact: `8px` (xs)
- Default: `12px` (sm)
- Comfortable: `16px` (md)

**Button Padding**
- Small: `16px × 8px` (md × xs)
- Medium: `24px × 12px` (lg × sm)
- Large: `32px × 16px` (xl × md)

---

## Typography Scale

### Font Family

**Primary (Interface)**
```
'Inter', -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif
```

**Monospace (Technical)**
```
'JetBrains Mono', 'SF Mono', 'Monaco', Consolas, 'Courier New', monospace
```

### Font Weights

| Weight | Value | Name | Usage |
|--------|-------|------|-------|
| **Light** | 300 | Inter Light | Large displays only (40px+) |
| **Regular** | 400 | Inter Regular | Body text, standard UI |
| **Medium** | 500 | Inter Medium | Emphasized text, labels |
| **Semibold** | 600 | Inter Semibold | Subheadings, important UI |
| **Bold** | 700 | Inter Bold | Headings, strong emphasis |
| **Extrabold** | 800 | Inter Extrabold | Hero text, display |

### Type Scale

Based on **1.25 modular scale** (Major Third), base size 16px.

#### Display Styles

| Style | Size | Line Height | Weight | Letter Spacing | Mobile |
|-------|------|-------------|--------|----------------|--------|
| **Display Large** | 48px | 56px (1.17) | 800 | -0.02em | 40px / 48px |
| **Display** | 40px | 48px (1.20) | 700 | -0.02em | 32px / 40px |

#### Headings

| Style | Size | Line Height | Weight | Letter Spacing | Mobile | Margin Bottom |
|-------|------|-------------|--------|----------------|--------|---------------|
| **H1** | 32px | 40px (1.25) | 700 | -0.01em | 28px / 36px | 24px |
| **H2** | 28px | 36px (1.29) | 600 | -0.01em | 24px / 32px | 20px |
| **H3** | 24px | 32px (1.33) | 600 | 0em | 20px / 28px | 16px |
| **H4** | 20px | 28px (1.40) | 600 | 0em | 18px / 26px | 12px |
| **H5** | 18px | 26px (1.44) | 500 | 0em | 16px / 24px | 8px |

#### Body Styles

| Style | Size | Line Height | Weight | Letter Spacing | Mobile |
|-------|------|-------------|--------|----------------|--------|
| **Body XL** | 18px | 28px (1.56) | 400 | 0em | 17px / 26px |
| **Body Large** | 17px | 26px (1.53) | 400 | 0em | 16px / 24px |
| **Body (Default)** | 16px | 24px (1.50) | 400 | 0em | 15px / 22px |
| **Body Small** | 14px | 20px (1.43) | 400 | 0em | 13px / 20px |

#### Supporting Styles

| Style | Size | Line Height | Weight | Letter Spacing | Transform |
|-------|------|-------------|--------|----------------|-----------|
| **Caption** | 12px | 18px (1.50) | 500 | 0.01em | Sentence case |
| **Label** | 14px | 20px (1.43) | 600 | 0.03em | UPPERCASE |
| **Overline** | 11px | 16px (1.45) | 600 | 0.08em | UPPERCASE |

#### Monospace Styles

| Style | Size | Line Height | Weight | Letter Spacing |
|-------|------|-------------|--------|----------------|
| **Code** | 14px | 22px (1.57) | 400 | 0em |
| **Code Small** | 12px | 18px (1.50) | 400 | 0em |

### Text Color Pairings

#### Light Mode
| Usage | Token | Hex Code | Contrast Ratio |
|-------|-------|----------|----------------|
| Primary Text | Neutral-600 | `#475569` | 7.8:1 (AAA) |
| Headings | Neutral-700 | `#334155` | 11.2:1 (AAA) |
| Secondary Text | Neutral-500 | `#64748B` | 4.9:1 (AA) |
| Disabled Text | Neutral-400 | `#94A3B8` | 3.6:1 |
| Link Text | Primary Solid | `#7C3AED` | 7.2:1 (AAA) |

#### Dark Mode
| Usage | Token | Hex Code | Contrast Ratio |
|-------|-------|----------|----------------|
| Primary Text | Neutral-400 | `#94A3B8` | 7.2:1 (AAA) |
| Headings | Neutral-300 | `#CBD5E1` | 11.8:1 (AAA) |
| Secondary Text | Neutral-500 | `#64748B` | 4.2:1 |
| Disabled Text | Neutral-600 | `#475569` | - |
| Link Text | Primary Start Dark | `#818CF8` | 8.1:1 (AAA) |

---

## Shadows & Elevation

Soft, diffused shadows create depth without heaviness. All shadow values use Neutral-900 (`#0F172A`) as base color.

### Shadow Levels

#### Level 0: Flat
```css
box-shadow: none;
```
**Usage**: Base surfaces, canvas

#### Level 1: Resting
```css
box-shadow:
  0 1px 2px rgba(15, 23, 42, 0.04),
  0 0 0 1px rgba(15, 23, 42, 0.02);
```
**Dart Implementation**:
```dart
AppShadows.level1
```
**Usage**: Cards at rest, list items, subtle elevation

#### Level 2: Raised
```css
box-shadow:
  0 4px 6px rgba(15, 23, 42, 0.06),
  0 2px 4px rgba(15, 23, 42, 0.03);
```
**Dart Implementation**:
```dart
AppShadows.level2
```
**Usage**: Buttons, interactive cards, hover states

#### Level 3: Floating
```css
box-shadow:
  0 10px 15px rgba(15, 23, 42, 0.08),
  0 4px 6px rgba(15, 23, 42, 0.04);
```
**Dart Implementation**:
```dart
AppShadows.level3
```
**Usage**: Dropdowns, popovers, floating action button

#### Level 4: Modal
```css
box-shadow:
  0 20px 25px rgba(15, 23, 42, 0.10),
  0 10px 10px rgba(15, 23, 42, 0.04);
```
**Dart Implementation**:
```dart
AppShadows.level4
```
**Usage**: Modals, dialogs, quick capture overlay

### Dark Mode Shadows

In dark mode, shadows use black with higher opacity for contrast:

```css
box-shadow:
  0 4px 6px rgba(0, 0, 0, 0.4),
  0 2px 4px rgba(0, 0, 0, 0.2),
  0 0 0 1px rgba(255, 255, 255, 0.05);
```

### Mobile-First Shadow Usage

**Mobile FAB Shadow** (reduced for performance):
```css
box-shadow: 0 4px 8px rgba(15, 23, 42, 0.2);
```
- 4px blur
- 20% opacity
- Tinted with gradient end color

---

## Icon Sizing System

Consistent icon sizes create visual rhythm and alignment.

| Size | Value | Usage | Example |
|------|-------|-------|---------|
| **Tiny** | `16px` | List item metadata, inline icons | Check marks, status indicators |
| **Small** | `20px` | List items, cards, standard UI | Item type icons, action buttons |
| **Medium** | `24px` | Navigation, toolbars, prominent UI | Bottom nav icons, FAB icons |
| **Large** | `32px` | Hero sections, empty states | Large action buttons, featured icons |

### Dart Implementation

```dart
Icon(Icons.check, size: 16) // Tiny
Icon(Icons.task, size: 20)  // Small
Icon(Icons.add, size: 24)   // Medium
Icon(Icons.star, size: 32)  // Large
```

### Icon Color Guidelines

**On Colored Backgrounds**: White or very light (`#FFFFFF`)
**On Light Backgrounds**: Neutral-600 (`#475569`)
**On Dark Backgrounds**: Neutral-400 (`#94A3B8`)
**Disabled State**: Neutral-400 (light), Neutral-600 (dark)

---

## Z-Index Layers

Consistent z-index system prevents layering conflicts.

| Layer | Z-Index | Usage |
|-------|---------|-------|
| **Base** | `0` | Default, page content |
| **Cards** | `1` | Item cards, elevated content |
| **Sticky** | `10` | Sticky headers, persistent UI |
| **Dropdown** | `100` | Dropdowns, popovers |
| **Navigation** | `500` | Bottom nav, app bar |
| **FAB** | `600` | Floating action button |
| **Overlay** | `900` | Modal overlays, backdrops |
| **Modal** | `1000` | Modal dialogs, sheets |
| **Toast** | `1100` | Notifications, toasts |
| **Tooltip** | `1200` | Tooltips, hints |

### Dart Implementation

```dart
class AppZIndex {
  static const int base = 0;
  static const int cards = 1;
  static const int sticky = 10;
  static const int dropdown = 100;
  static const int navigation = 500;
  static const int fab = 600;
  static const int overlay = 900;
  static const int modal = 1000;
  static const int toast = 1100;
  static const int tooltip = 1200;
}
```

---

## Animation Durations

Physics-based, purposeful motion. All animations respect `prefers-reduced-motion`.

| Token | Duration | Usage |
|-------|----------|-------|
| **instant** | `0ms` | Immediate state changes |
| **micro** | `100ms` | Color transitions, subtle changes |
| **fast** | `200ms` | Button feedback, quick interactions |
| **base** | `300ms` | Standard transitions (DEFAULT) |
| **slow** | `400ms` | Deliberate transitions, complex animations |
| **slower** | `500ms` | Page transitions, modal appearances |
| **slowest** | `600ms` | Hero animations (rare) |

### Easing Curves

| Curve | CSS Bezier | Usage |
|-------|------------|-------|
| **Ease Out Expo** | `cubic-bezier(0.16, 1, 0.3, 1)` | Entrances, expansions, reveals |
| **Ease In Out Quint** | `cubic-bezier(0.83, 0, 0.17, 1)` | Smooth transitions, transformations |
| **Ease Out Quart** | `cubic-bezier(0.25, 1, 0.5, 1)` | Snappy interactions, quick feedback |
| **Ease In Out Circ** | `cubic-bezier(0.85, 0, 0.15, 1)` | Dramatic movements, hero animations |
| **Linear** | `cubic-bezier(0, 0, 1, 1)` | Continuous motion, looping |

### Dart Implementation

```dart
AppAnimations.instant  // 0ms
AppAnimations.micro    // 100ms
AppAnimations.fast     // 200ms
AppAnimations.base     // 300ms (default)
AppAnimations.slow     // 400ms
AppAnimations.slower   // 500ms
AppAnimations.slowest  // 600ms

// Curves
AppAnimations.easeOutExpo
AppAnimations.easeInOutQuint
AppAnimations.easeOutQuart
AppAnimations.easeInOutCirc
Curves.linear
```

---

## Border Radius

Consistent corner rounding creates cohesive feel.

| Token | Value | Usage |
|-------|-------|-------|
| **xs** | `4px` | Chips, tags, small elements |
| **sm** | `8px` | Buttons, inputs, small cards |
| **md** | `12px` | Cards, containers (DEFAULT) |
| **lg** | `16px` | Large cards, panels |
| **xl** | `20px` | Modals, sheets |
| **2xl** | `24px` | Hero sections |
| **full** | `9999px` | Pills, circular elements |

### Mobile-First Card Radius

Cards use **12px (md)** border radius on mobile for a softer, more approachable feel.

---

## Breakpoints

Mobile-first responsive design breakpoints.

| Breakpoint | Min Width | Max Width | Usage |
|------------|-----------|-----------|-------|
| **Mobile** | `320px` | `767px` | Phones (default) |
| **Tablet** | `768px` | `1023px` | Tablets, small laptops |
| **Desktop** | `1024px` | `1439px` | Laptops, desktops |
| **Wide** | `1440px` | - | Large displays |

### Container Max Widths

| Context | Max Width | Usage |
|---------|-----------|-------|
| **Reading Width** | `680px` | Long-form text, optimal readability |
| **Form Width** | `480px` | Single-column forms |
| **Modal Width** | `560px` | Standard dialogs |
| **Content Width** | `1200px` | Default max width |
| **Wide Width** | `1440px` | Maximum application width |

---

## Quick Reference

### Most Common Values

**Spacing**: `16px` (md) - default for most spacing needs
**Typography**: `16px` / `24px` (Body) - default text style
**Color**: `#475569` (Neutral-600) - default text color
**Shadow**: Level 1 - default card elevation
**Animation**: `300ms` (base) - default transition duration
**Border Radius**: `12px` (md) - default card corners
**Icon Size**: `20px` (small) - default icon size

### Mobile-First Priorities

1. **16px margins** around cards (creates floating effect)
2. **Bold 3px gradient borders** (not shadows, not backgrounds)
3. **Minimal shadows** (4px blur, 20% opacity for FAB only)
4. **24px icon navigation** (icon-only with gradient underline)
5. **60px FAB** with gradient fill and 4px shadow

---

**Last Updated**: 2025-10-21
**Version**: 2.0.0 (Mobile-First Bold Redesign)
**Status**: Production Ready
