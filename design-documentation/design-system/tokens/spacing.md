---
title: Spacing Tokens
description: Spacing scale, layout grid, and usage guidelines
last-updated: 2025-10-19
version: 1.0.0
status: approved
related-files:
  - ../style-guide.md
  - ./typography.md
---

# Spacing Tokens

## Spacing Philosophy: Proportional Harmony

later uses a **progressive spacing system** based on multiples of a 4px base unit. This creates mathematical harmony and consistent visual rhythm throughout the interface.

## Base Unit System

**Base Unit**: `4px`

Every spacing value is a multiple of 4px, creating a predictable, scalable system that maintains visual harmony across all screen sizes.

---

## Spacing Scale

| Token | Value | Multiplier | Usage |
|-------|-------|------------|-------|
| **xxs** | `4px` | 1× | Micro spacing, icon-text gaps |
| **xs** | `8px` | 2× | Internal padding, tight groupings |
| **sm** | `12px` | 3× | Small spacing, comfortable groupings |
| **md** | `16px` | 4× | Standard spacing, default margins |
| **lg** | `24px` | 6× | Section spacing, card padding |
| **xl** | `32px` | 8× | Large spacing, major separations |
| **2xl** | `48px` | 12× | Extra large spacing, screen padding |
| **3xl** | `64px` | 16× | Huge spacing, hero sections |
| **4xl** | `96px` | 24× | Maximum spacing, full-bleed sections |

### Visual Scale

```
xxs  ▪
xs   ▪▪
sm   ▪▪▪
md   ▪▪▪▪
lg   ▪▪▪▪▪▪
xl   ▪▪▪▪▪▪▪▪
2xl  ▪▪▪▪▪▪▪▪▪▪▪▪
3xl  ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
4xl  ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
```

---

## Spacing Usage Guidelines

### Micro Spacing (xxs: 4px)

**Use For:**
- Gap between icon and adjacent text
- Spacing between badge and text
- Internal spacing in compact chips
- Minimal padding in dense UI

**Examples:**
```dart
// Icon + Text
Row(
  spacing: AppSpacing.xxs, // 4px
  children: [Icon(Icons.star), Text('Favorite')],
)

// Compact chip
Chip(
  padding: EdgeInsets.symmetric(
    horizontal: AppSpacing.xs,
    vertical: AppSpacing.xxs,
  ),
)
```

### Extra Small (xs: 8px)

**Use For:**
- Internal padding for buttons
- Small component padding
- Tight list item spacing
- Close element groupings

**Examples:**
```dart
// Button internal padding (vertical)
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.xs,
  ),
  child: Text('Button'),
)

// Tight list spacing
ListView.separated(
  separatorBuilder: (context, index) => SizedBox(height: AppSpacing.xs),
)
```

### Small (sm: 12px)

**Use For:**
- Moderate list item spacing
- Comfortable element groupings
- Card internal spacing (compact)
- Form field spacing

**Examples:**
```dart
// List item spacing
ListView.separated(
  separatorBuilder: (context, index) => SizedBox(height: AppSpacing.sm),
)

// Form field gap
Column(
  spacing: AppSpacing.sm,
  children: [TextField(), TextField()],
)
```

### Medium (md: 16px) - **Default**

**Use For:**
- Default spacing between elements
- Standard card padding
- Form field internal padding
- Default margin between sections

**This is the most common spacing value**

**Examples:**
```dart
// Card padding
Padding(
  padding: EdgeInsets.all(AppSpacing.md),
  child: CardContent(),
)

// Default spacing
Column(
  spacing: AppSpacing.md,
  children: [...],
)
```

### Large (lg: 24px)

**Use For:**
- Section spacing within screens
- Card padding on tablets/desktop
- Spacing between major groups
- Comfortable breathing room

**Examples:**
```dart
// Section spacing
Column(
  children: [
    Section1(),
    SizedBox(height: AppSpacing.lg),
    Section2(),
  ],
)

// Card padding (tablet+)
Padding(
  padding: EdgeInsets.all(
    screenWidth > 768 ? AppSpacing.lg : AppSpacing.md,
  ),
)
```

### Extra Large (xl: 32px)

**Use For:**
- Major section separations
- Top/bottom screen padding
- Large card padding
- Significant visual breaks

**Examples:**
```dart
// Screen padding
Padding(
  padding: EdgeInsets.all(AppSpacing.xl),
  child: ScreenContent(),
)

// Major section break
SizedBox(height: AppSpacing.xl)
```

### 2XL (2xl: 48px)

**Use For:**
- Screen-level padding on desktop
- Major section spacing
- Hero section padding
- Generous whitespace

**Examples:**
```dart
// Desktop screen padding
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: screenWidth > 1024 ? AppSpacing.xxl : AppSpacing.xl,
    vertical: AppSpacing.xl,
  ),
)
```

### 3XL (3xl: 64px)

**Use For:**
- Hero sections
- Empty state padding
- Extra generous whitespace
- Dramatic spacing moments

**Examples:**
```dart
// Empty state padding
Padding(
  padding: EdgeInsets.all(AppSpacing.xxxl),
  child: EmptyStateContent(),
)
```

### 4XL (4xl: 96px)

**Use For:**
- Maximum spacing (rare)
- Full-bleed sections
- Splash screens
- Extreme whitespace

**Usage**: Very rare, only for special moments

---

## Layout Grid System

### Grid Philosophy

Our grid system creates consistent layouts across all screen sizes while allowing flexibility for content.

### Column Grid

**Mobile (320-767px)**
- **Columns**: 4
- **Gutters**: 16px (md)
- **Margins**: 16px (md)
- **Max Width**: 100% - 32px

**Tablet (768-1023px)**
- **Columns**: 8
- **Gutters**: 24px (lg)
- **Margins**: 32px (xl)
- **Max Width**: 100% - 64px

**Desktop (1024-1439px)**
- **Columns**: 12
- **Gutters**: 24px (lg)
- **Margins**: 48px (2xl)
- **Max Width**: 1200px

**Wide (1440px+)**
- **Columns**: 12
- **Gutters**: 32px (xl)
- **Margins**: 64px (3xl)
- **Max Width**: 1440px

### Grid Implementation

```dart
// lib/core/layout/responsive_grid.dart

class ResponsiveGrid {
  static int getColumns(double width) {
    if (width < 768) return 4;
    if (width < 1024) return 8;
    return 12;
  }

  static double getGutter(double width) {
    if (width < 768) return AppSpacing.md;
    if (width < 1440) return AppSpacing.lg;
    return AppSpacing.xl;
  }

  static double getMargin(double width) {
    if (width < 768) return AppSpacing.md;
    if (width < 1024) return AppSpacing.xl;
    if (width < 1440) return AppSpacing.xxl;
    return AppSpacing.xxxl;
  }

  static double getMaxWidth(double width) {
    if (width < 1024) return width - (getMargin(width) * 2);
    if (width < 1440) return 1200;
    return 1440;
  }
}
```

---

## Content Width Constraints

### Optimal Reading Widths

**Reading Width**: `680px`
- Optimal for long-form text
- 50-75 characters per line
- Use for note content, articles

**Form Width**: `480px`
- Comfortable for forms
- Single-column forms
- Prevents excessive line length

**Modal Width**: `560px`
- Standard modal container
- Dialogs and popups
- Quick capture modal

**Content Width**: `1200px`
- Full content area
- Default max width for content

**Wide Width**: `1440px`
- Maximum application width
- Edge-to-edge on smaller screens

### Implementation

```dart
class ContentWidth {
  static const double reading = 680;
  static const double form = 480;
  static const double modal = 560;
  static const double content = 1200;
  static const double wide = 1440;
}

// Usage
Container(
  constraints: BoxConstraints(maxWidth: ContentWidth.reading),
  child: Text('Long-form content...'),
)
```

---

## Component-Specific Spacing

### Card Spacing

**Internal Padding**
```dart
// Mobile
padding: EdgeInsets.all(AppSpacing.md) // 16px

// Tablet
padding: EdgeInsets.all(AppSpacing.lg) // 20px

// Desktop
padding: EdgeInsets.all(AppSpacing.lg) // 24px
```

**Between Cards**
```dart
// List of cards
spacing: AppSpacing.sm // 12px (compact)
spacing: AppSpacing.md // 16px (default)
```

### List Item Spacing

**Compact Lists**
```dart
spacing: AppSpacing.xs // 8px
```

**Default Lists**
```dart
spacing: AppSpacing.sm // 12px
```

**Comfortable Lists**
```dart
spacing: AppSpacing.md // 16px
```

**Internal List Item Padding**
```dart
padding: EdgeInsets.all(AppSpacing.md) // 16px
```

### Button Spacing

**Internal Padding**
```dart
// Small buttons
padding: EdgeInsets.symmetric(
  horizontal: AppSpacing.md, // 16px
  vertical: AppSpacing.xs,   // 8px
)

// Medium buttons (default)
padding: EdgeInsets.symmetric(
  horizontal: AppSpacing.lg, // 24px
  vertical: AppSpacing.sm,   // 12px
)

// Large buttons
padding: EdgeInsets.symmetric(
  horizontal: AppSpacing.xl, // 32px
  vertical: AppSpacing.md,   // 16px
)
```

**Between Buttons**
```dart
// Horizontal
spacing: AppSpacing.sm // 12px

// Vertical
spacing: AppSpacing.xs // 8px
```

### Form Spacing

**Between Form Fields**
```dart
spacing: AppSpacing.md // 16px (default)
spacing: AppSpacing.lg // 24px (comfortable)
```

**Label to Input**
```dart
spacing: AppSpacing.xs // 8px
```

**Helper Text Spacing**
```dart
spacing: AppSpacing.xxs // 4px
```

**Form Sections**
```dart
spacing: AppSpacing.xl // 32px
```

### Screen Spacing

**Screen Padding**
```dart
// Mobile
padding: EdgeInsets.all(AppSpacing.md) // 16px

// Tablet
padding: EdgeInsets.all(AppSpacing.xl) // 32px

// Desktop
padding: EdgeInsets.all(AppSpacing.xxl) // 48px
```

**Between Sections**
```dart
// Mobile
spacing: AppSpacing.lg // 24px

// Tablet/Desktop
spacing: AppSpacing.xl // 32px
spacing: AppSpacing.xxl // 48px (major sections)
```

### Navigation Spacing

**Bottom Navigation**
```dart
height: 56px // Fixed
itemSpacing: AppSpacing.sm // 12px
```

**Tab Bar**
```dart
height: 48px // Fixed
tabSpacing: AppSpacing.lg // 24px
```

**App Bar**
```dart
height: 56px // Mobile
height: 64px // Desktop
padding: EdgeInsets.symmetric(horizontal: AppSpacing.md)
```

---

## Safe Area Handling

### Mobile Safe Areas

```dart
// Respect system UI insets
SafeArea(
  child: Scaffold(
    body: Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Content(),
    ),
  ),
)

// Custom safe area with minimum padding
Padding(
  padding: EdgeInsets.only(
    top: max(MediaQuery.of(context).padding.top, AppSpacing.md),
    bottom: max(MediaQuery.of(context).padding.bottom, AppSpacing.md),
    left: AppSpacing.md,
    right: AppSpacing.md,
  ),
)
```

### Notch Handling

```dart
// Additional padding for notches
final topPadding = MediaQuery.of(context).padding.top;
final bottomPadding = MediaQuery.of(context).padding.bottom;

// Apply additional spacing
paddingTop: topPadding + AppSpacing.md
```

---

## Responsive Spacing Strategy

### Breakpoint-Based Spacing

```dart
class ResponsiveSpacing {
  static double getScreenPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 768) return AppSpacing.md;    // 16px
    if (width < 1024) return AppSpacing.xl;   // 32px
    return AppSpacing.xxl;                     // 48px
  }

  static double getCardPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 768) return AppSpacing.md;    // 16px
    return AppSpacing.lg;                      // 24px
  }

  static double getSectionSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 768) return AppSpacing.lg;    // 24px
    if (width < 1024) return AppSpacing.xl;   // 32px
    return AppSpacing.xxl;                     // 48px
  }
}
```

### Usage

```dart
// Responsive screen padding
Padding(
  padding: EdgeInsets.all(
    ResponsiveSpacing.getScreenPadding(context),
  ),
  child: Content(),
)

// Responsive section spacing
SizedBox(height: ResponsiveSpacing.getSectionSpacing(context))
```

---

## Flutter Implementation

### Spacing Constants Class

```dart
// lib/core/theme/app_spacing.dart

class AppSpacing {
  AppSpacing._(); // Private constructor

  // Base unit
  static const double base = 4.0;

  // Spacing scale
  static const double xxs = 4.0;   // 1×
  static const double xs = 8.0;    // 2×
  static const double sm = 12.0;   // 3×
  static const double md = 16.0;   // 4× (default)
  static const double lg = 24.0;   // 6×
  static const double xl = 32.0;   // 8×
  static const double xxl = 48.0;  // 12×
  static const double xxxl = 64.0; // 16×
  static const double xxxxl = 96.0; // 24×

  // Semantic aliases
  static const double tiny = xxs;
  static const double small = xs;
  static const double medium = md;
  static const double large = lg;
  static const double huge = xxl;

  // Common padding presets
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  // Common horizontal padding
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXL = EdgeInsets.symmetric(horizontal: xl);

  // Common vertical padding
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXL = EdgeInsets.symmetric(vertical: xl);

  // Screen padding (responsive)
  static EdgeInsets screenPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) return paddingMD;
    if (width < 1024) return paddingXL;
    return paddingXXL;
  }

  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);
}

// Content width constraints
class ContentWidth {
  ContentWidth._();

  static const double reading = 680;
  static const double form = 480;
  static const double modal = 560;
  static const double content = 1200;
  static const double wide = 1440;
}
```

### Usage Examples

```dart
// Simple padding
Padding(
  padding: EdgeInsets.all(AppSpacing.md),
  child: Content(),
)

// Using presets
Padding(
  padding: AppSpacing.paddingMD,
  child: Content(),
)

// Responsive padding
Padding(
  padding: AppSpacing.screenPadding(context),
  child: Content(),
)

// Custom combination
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.md,
  ),
  child: Content(),
)

// Spacing between widgets
Column(
  children: [
    Widget1(),
    SizedBox(height: AppSpacing.md),
    Widget2(),
    SizedBox(height: AppSpacing.lg),
    Widget3(),
  ],
)

// Using spacer with Column
Column(
  spacing: AppSpacing.md, // Flutter 3.16+
  children: [Widget1(), Widget2(), Widget3()],
)

// Content width constraint
Center(
  child: Container(
    constraints: BoxConstraints(maxWidth: ContentWidth.reading),
    padding: AppSpacing.paddingMD,
    child: LongFormText(),
  ),
)
```

---

## Spacing Decision Tree

**When choosing spacing:**

1. **Are elements tightly related?** → `xxs` or `xs`
2. **Are elements moderately related?** → `sm` or `md`
3. **Are elements in different groups?** → `lg` or `xl`
4. **Are elements in different sections?** → `xl` or `2xl`
5. **Is this a hero or special moment?** → `3xl` or `4xl`

**Default to `md` (16px) when unsure**

---

## Accessibility Considerations

### Touch Target Spacing

**Minimum Touch Target**: 48×48px (iOS: 44×44px)

```dart
// Ensure adequate spacing for touch targets
Container(
  height: 48,
  width: 48,
  child: IconButton(...),
)

// Spacing between touch targets
spacing: max(AppSpacing.sm, 12) // Minimum 12px between
```

### Visual Breathing Room

- Maintain consistent spacing for visual rhythm
- Use whitespace to create focus areas
- Don't overcrowd interactive elements
- Provide clear visual separation between sections

### Dense Mode (Accessibility)

```dart
// Respect user preference for dense UI
final textScaleFactor = MediaQuery.of(context).textScaleFactor;
final denseFactor = textScaleFactor > 1.3 ? 0.85 : 1.0;

spacing: AppSpacing.md * denseFactor
```

---

## Best Practices

### Do's

- Use spacing tokens consistently
- Maintain vertical rhythm with consistent spacing
- Increase spacing for emphasis and separation
- Use responsive spacing for different screen sizes
- Test spacing at different text scale factors

### Don'ts

- Don't create custom spacing values outside the scale
- Don't use pixel-perfect spacing (use tokens)
- Don't neglect safe areas and notches
- Don't make touch targets too close together
- Don't overcrowd the interface

### Testing Checklist

- [ ] Spacing consistent across similar elements
- [ ] Touch targets have adequate spacing
- [ ] Layout works at text scale factor 2.0
- [ ] Safe areas respected on all devices
- [ ] Responsive spacing works at all breakpoints
- [ ] No overlapping elements
- [ ] Visual hierarchy clear through spacing

---

**Related Documentation**
- [Style Guide](../style-guide.md)
- [Typography](./typography.md)
- [Components](../components/)

**Last Updated**: October 19, 2025
**Version**: 1.0.0
