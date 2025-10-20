---
title: Typography Tokens
description: Complete typography system with scales, weights, and usage guidelines
last-updated: 2025-10-19
version: 1.0.0
status: approved
related-files:
  - ../style-guide.md
  - ./colors.md
---

# Typography Tokens

## Typography Philosophy: Clarity Through Hierarchy

Typography in later creates **clear information hierarchy** while maintaining exceptional readability. We use a dual-font system that balances humanist warmth (Inter) with technical precision (JetBrains Mono).

## Font Selection Rationale

### Primary: Inter

**Why Inter?**
- Exceptional readability at all sizes
- Variable font with precise weight control
- Optimized for digital screens
- Humanist proportions feel friendly yet professional
- Open apertures improve legibility
- Large x-height aids small text reading
- Free and widely available

**Design Characteristics**
- Geometric with humanist warmth
- Slightly condensed for efficient space use
- Excellent distinction between similar characters (Il1, O0)
- Tall ascenders and descenders for rhythm

### Monospace: JetBrains Mono

**Why JetBrains Mono?**
- Designed specifically for developers
- Excellent character distinction
- Larger height for comfortable reading
- Ligature support (optional)
- Clean, modern aesthetic
- Free and well-maintained

**Design Characteristics**
- Increased height compared to typical monospace
- Clear letterforms prevent confusion
- Optimized for code but works for UI tags
- Slightly wider for comfortable reading

---

## Font Stack Implementation

### Primary Font Stack (Interface)

```css
font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
```

**Fallback Strategy**
1. **Inter** - Preferred, load via Google Fonts
2. **-apple-system** - iOS/macOS system font
3. **BlinkMacSystemFont** - macOS Chrome system font
4. **SF Pro Display** - Explicit macOS font
5. **Segoe UI** - Windows system font
6. **Roboto** - Android system font
7. **Helvetica Neue** - Older macOS fallback
8. **Arial** - Universal fallback
9. **sans-serif** - Generic sans-serif

### Monospace Font Stack (Technical)

```css
font-family: 'JetBrains Mono', 'SF Mono', 'Monaco', Consolas, 'Courier New', monospace;
```

**Fallback Strategy**
1. **JetBrains Mono** - Preferred, load via Google Fonts
2. **SF Mono** - macOS terminal font
3. **Monaco** - macOS classic monospace
4. **Consolas** - Windows monospace
5. **Courier New** - Universal fallback
6. **monospace** - Generic monospace

---

## Font Weight System

Inter supports variable weights from 100-900. We use specific weights for semantic meaning:

| Weight | Value | Name | Usage |
|--------|-------|------|-------|
| Light | 300 | Inter Light | Sparse, large displays only |
| Regular | 400 | Inter Regular | Body text, standard UI |
| Medium | 500 | Inter Medium | Emphasized text, labels |
| Semibold | 600 | Inter Semibold | Subheadings, important UI |
| Bold | 700 | Inter Bold | Headings, strong emphasis |
| Extrabold | 800 | Inter Extrabold | Hero text, display |

**Weight Usage Rules**
- **Never use below 300** - Too light for screen reading
- **Limit 300 weight** to 40px+ sizes only
- **Default to 400** for body text
- **Use 500** for emphasis within body text
- **Reserve 800** for hero moments only
- **Never use 900** - Too heavy, reduces readability

---

## Type Scale System

### Scale Philosophy: Harmonic Progression

Based on **1.25 modular scale** (Major Third in music theory), creating natural visual rhythm and hierarchy.

**Base Size**: 16px (Body)
**Scale Ratio**: 1.25
**Progression**: Each step multiplies by 1.25

### Display Styles

#### Display Large
```
Font Size: 48px
Line Height: 56px (1.17)
Font Weight: 800 (Extrabold)
Letter Spacing: -0.02em (-0.96px)
Mobile: 40px / 48px
```

**Usage**: Hero headlines, splash screens, major empty states
**Max Width**: 680px for readability
**Case**: Sentence case preferred

**Example**
```dart
TextStyle(
  fontSize: 48,
  height: 1.17,
  fontWeight: FontWeight.w800,
  letterSpacing: -0.96,
)
```

#### Display
```
Font Size: 40px
Line Height: 48px (1.20)
Font Weight: 700 (Bold)
Letter Spacing: -0.02em (-0.8px)
Mobile: 32px / 40px
```

**Usage**: Major section headers, onboarding titles
**Max Width**: 600px
**Case**: Sentence case

---

### Headline Styles

#### H1
```
Font Size: 32px
Line Height: 40px (1.25)
Font Weight: 700 (Bold)
Letter Spacing: -0.01em (-0.32px)
Mobile: 28px / 36px
```

**Usage**: Page titles, screen headers, primary headings
**Margin**: 0 0 24px (bottom)
**Case**: Sentence case

#### H2
```
Font Size: 28px
Line Height: 36px (1.29)
Font Weight: 600 (Semibold)
Letter Spacing: -0.01em (-0.28px)
Mobile: 24px / 32px
```

**Usage**: Section headers, modal titles, major groups
**Margin**: 0 0 20px (bottom)
**Case**: Sentence case

#### H3
```
Font Size: 24px
Line Height: 32px (1.33)
Font Weight: 600 (Semibold)
Letter Spacing: 0em
Mobile: 20px / 28px
```

**Usage**: Subsection headers, card titles, feature titles
**Margin**: 0 0 16px (bottom)
**Case**: Sentence case

#### H4
```
Font Size: 20px
Line Height: 28px (1.40)
Font Weight: 600 (Semibold)
Letter Spacing: 0em
Mobile: 18px / 26px
```

**Usage**: List headers, group titles, small sections
**Margin**: 0 0 12px (bottom)
**Case**: Sentence case

#### H5
```
Font Size: 18px
Line Height: 26px (1.44)
Font Weight: 500 (Medium)
Letter Spacing: 0em
Mobile: 16px / 24px
```

**Usage**: Small headers, emphasized labels, compact titles
**Margin**: 0 0 8px (bottom)
**Case**: Sentence case

---

### Body Styles

#### Body XL
```
Font Size: 18px
Line Height: 28px (1.56)
Font Weight: 400 (Regular)
Letter Spacing: 0em
Mobile: 17px / 26px
```

**Usage**: Lead paragraphs, important content, featured text
**Max Width**: 680px (optimal reading)
**Margin**: 0 0 16px (between paragraphs)

#### Body Large
```
Font Size: 17px
Line Height: 26px (1.53)
Font Weight: 400 (Regular)
Letter Spacing: 0em
Mobile: 16px / 24px
```

**Usage**: Reading content, note bodies, long-form text
**Max Width**: 680px
**Margin**: 0 0 16px

#### Body (Default)
```
Font Size: 16px
Line Height: 24px (1.50)
Font Weight: 400 (Regular)
Letter Spacing: 0em
Mobile: 15px / 22px
```

**Usage**: Standard UI text, descriptions, form inputs, list items
**Max Width**: None (UI text)
**Margin**: 0 0 12px (content), none (UI)

**This is the default body text style**

#### Body Small
```
Font Size: 14px
Line Height: 20px (1.43)
Font Weight: 400 (Regular)
Letter Spacing: 0em
Mobile: 13px / 20px
```

**Usage**: Secondary information, metadata, helper text, descriptions
**Max Width**: None
**Margin**: 0 0 8px (if stacked)

---

### Supporting Styles

#### Caption
```
Font Size: 12px
Line Height: 18px (1.50)
Font Weight: 500 (Medium)
Letter Spacing: 0.01em (0.12px)
All Devices: Same size
```

**Usage**: Timestamps, counts, badges, subtle metadata
**Case**: Sentence case
**Color**: Neutral-500 (light), Neutral-500 (dark)

#### Label
```
Font Size: 14px
Line Height: 20px (1.43)
Font Weight: 600 (Semibold)
Letter Spacing: 0.03em (0.42px)
Text Transform: UPPERCASE
Mobile: 13px / 20px
```

**Usage**: Form labels, section labels, category headers
**Case**: ALL CAPS
**Color**: Neutral-700 (light), Neutral-300 (dark)

#### Overline
```
Font Size: 11px
Line Height: 16px (1.45)
Font Weight: 600 (Semibold)
Letter Spacing: 0.08em (0.88px)
Text Transform: UPPERCASE
All Devices: Same size
```

**Usage**: Eyebrow text, tiny category labels, status indicators
**Case**: ALL CAPS
**Color**: Neutral-500 (light), Neutral-500 (dark)

---

### Monospace Styles

#### Code
```
Font Family: JetBrains Mono
Font Size: 14px
Line Height: 22px (1.57)
Font Weight: 400 (Regular)
Letter Spacing: 0em
Mobile: 13px / 20px
```

**Usage**: Tags, IDs, technical labels, inline code
**Background**: Neutral-100 (light), Neutral-800 (dark)
**Padding**: 2px 6px
**Border Radius**: 4px

#### Code Small
```
Font Family: JetBrains Mono
Font Size: 12px
Line Height: 18px (1.50)
Font Weight: 400 (Regular)
Letter Spacing: 0em
All Devices: Same size
```

**Usage**: Small technical labels, compact code snippets
**Background**: Same as Code
**Padding**: 2px 4px
**Border Radius**: 4px

---

## Responsive Typography Strategy

### Breakpoint-Based Scaling

**Mobile (320-767px)**
- Base size maintained
- Display sizes reduced 15-20%
- Line heights maintained for rhythm
- Letter spacing adjusted proportionally

**Tablet (768-1023px)**
- Base size: +5% for comfortable reading distance
- Scale applied to all text
- Optimal for 10-13 inch screens

**Desktop (1024-1439px)**
- Full scale as specified
- Optimal for 13-24 inch screens
- Standard viewing distance

**Wide (1440px+)**
- Base size: +10% for larger displays
- Accounts for greater viewing distance
- Prevents text from feeling tiny on large screens

### Dynamic Type Support

**iOS Dynamic Type**
```dart
Text(
  'Respects user preferences',
  style: Theme.of(context).textTheme.bodyMedium,
  textScaleFactor: MediaQuery.of(context).textScaleFactor,
)
```

**Android Font Scale**
- Respect system font size settings
- Test at 0.85x, 1.0x, 1.3x, 1.5x scales
- Maintain layout integrity at all scales

**Maximum Scale Factor**: 2.0x
- Prevents layout breaking
- Use `textScaleFactor.clamp(0.85, 2.0)`

---

## Typography Usage Guidelines

### Hierarchy Rules

**Single Screen Hierarchy**
- Maximum 3 heading levels per screen
- One H1 per screen (usually page title)
- H2 for major sections
- H3 for subsections and cards
- Body styles for content

**Visual Rhythm**
- Maintain consistent vertical rhythm
- Use line height to create breathing room
- Space headings 1.5x their line height from content
- Space body paragraphs 1x their line height

### Emphasis Techniques

**Primary Emphasis**: Increase font weight
```dart
Text('Important text', style: TextStyle(fontWeight: FontWeight.w600))
```

**Secondary Emphasis**: Use primary color
```dart
Text('Highlighted', style: TextStyle(color: AppColors.primarySolid))
```

**Subtle Emphasis**: Use medium weight (500)
```dart
Text('Slightly emphasized', style: TextStyle(fontWeight: FontWeight.w500))
```

**De-emphasis**: Use lighter color, not lighter weight
```dart
Text('Less important', style: TextStyle(color: AppColors.neutral500))
```

### Text Alignment

**Default**: Left-aligned
- Most readable for LTR languages
- Creates consistent left edge

**Center-aligned**: Sparingly
- Hero text and display content
- Empty state messages
- Short, single-line headings

**Right-aligned**: Rarely
- Numeric data in tables
- RTL language support

**Justified**: Never
- Creates awkward spacing
- Reduces readability

### Line Length Optimization

**Optimal Line Length**: 50-75 characters
**Maximum Line Length**: 90 characters

```dart
Container(
  constraints: BoxConstraints(maxWidth: 680),
  child: Text('Long-form reading content...'),
)
```

### Case Usage

**Sentence case** (Preferred)
- Headings
- Button labels
- Navigation items
- Form inputs
- Error messages

**Title Case** (Avoid)
- Harder to read
- Feels formal/outdated
- Use only for proper nouns

**ALL CAPS** (Sparingly)
- Labels and overlines only
- Never for sentences
- Maximum 2-3 words
- Increase letter spacing (+0.03em minimum)

**lowercase** (Never)
- Avoid all-lowercase in UI
- Reduces scannability
- Feels unprofessional

---

## Color + Typography Combinations

### Light Mode Text Colors

**Primary Text** (Body, UI)
- Color: Neutral-600 (#475569)
- Contrast: 7.8:1 on white (AAA)
- Use: Default text color

**Headings**
- Color: Neutral-700 (#334155)
- Contrast: 11.2:1 on white (AAA)
- Use: All heading styles

**Secondary Text**
- Color: Neutral-500 (#64748B)
- Contrast: 4.9:1 on white (AA)
- Use: Captions, metadata, helper text

**Disabled Text**
- Color: Neutral-400 (#94A3B8)
- Contrast: 3.6:1 on white
- Use: Disabled states only, not for active content

**Link Text**
- Color: Primary Solid (#7C3AED)
- Contrast: 7.2:1 on white (AAA)
- Hover: Primary Hover (#6D28D9)

### Dark Mode Text Colors

**Primary Text**
- Color: Neutral-400 (#94A3B8)
- Contrast: 7.2:1 on Neutral-950 (AAA)
- Use: Default text color

**Headings**
- Color: Neutral-300 (#CBD5E1)
- Contrast: 11.8:1 on Neutral-950 (AAA)
- Use: All heading styles

**Secondary Text**
- Color: Neutral-500 (#64748B)
- Contrast: 4.2:1 on Neutral-950
- Use: Captions, metadata

**Disabled Text**
- Color: Neutral-600 (#475569)
- Use: Disabled states only

**Link Text**
- Color: Primary Start Dark (#818CF8)
- Contrast: 8.1:1 on Neutral-950 (AAA)
- Hover: Brighter variant

### Text on Colored Backgrounds

**Text on Primary**
- Color: White (pure or Neutral-50)
- Minimum contrast: 4.5:1
- Test gradient endpoints

**Text on Success/Error/Warning**
- Light mode: Darker shade of same color
- Dark mode: White or very light
- Always test contrast

**Text on Type Colors** (Task/Note/List)
- Light backgrounds: Neutral-700
- Dark backgrounds: White/Neutral-100

---

## Flutter Implementation

### Google Fonts Setup

**pubspec.yaml**
```yaml
dependencies:
  google_fonts: ^6.1.0
```

**Loading Fonts**
```dart
import 'package:google_fonts/google_fonts.dart';

// In MaterialApp theme
ThemeData(
  textTheme: GoogleFonts.interTextTheme(),
  // ...
)
```

### Typography Theme Class

```dart
// lib/core/theme/app_typography.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  // Base text theme using Inter
  static TextTheme textTheme = TextTheme(
    // DISPLAY STYLES
    displayLarge: GoogleFonts.inter(
      fontSize: 48,
      height: 1.17,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.96,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 40,
      height: 1.20,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
    ),

    // HEADLINE STYLES
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      height: 1.25,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.32,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 28,
      height: 1.29,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.28,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 24,
      height: 1.33,
      fontWeight: FontWeight.w600,
    ),

    // TITLE STYLES (H4, H5)
    titleLarge: GoogleFonts.inter(
      fontSize: 20,
      height: 1.40,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 18,
      height: 1.44,
      fontWeight: FontWeight.w500,
    ),

    // BODY STYLES
    bodyLarge: GoogleFonts.inter(
      fontSize: 17,
      height: 1.53,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 16,
      height: 1.50,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 14,
      height: 1.43,
      fontWeight: FontWeight.w400,
    ),

    // LABEL STYLES
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      height: 1.43,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.42,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      height: 1.50,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.12,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      height: 1.45,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.88,
    ),
  );

  // Monospace styles for code/tags
  static TextStyle code = GoogleFonts.jetBrainsMono(
    fontSize: 14,
    height: 1.57,
    fontWeight: FontWeight.w400,
  );

  static TextStyle codeSmall = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    height: 1.50,
    fontWeight: FontWeight.w400,
  );

  // Utility: Text with emphasis
  static TextStyle emphasis(TextStyle base) {
    return base.copyWith(fontWeight: FontWeight.w600);
  }

  // Utility: Text with color
  static TextStyle withColor(TextStyle base, Color color) {
    return base.copyWith(color: color);
  }

  // Utility: Uppercase labels
  static TextStyle uppercase(TextStyle base) {
    return base.copyWith(
      letterSpacing: base.letterSpacing! + 0.03,
    );
  }
}
```

### Usage Examples

```dart
// Using text theme
Text(
  'Page Title',
  style: Theme.of(context).textTheme.headlineLarge,
)

// Custom style composition
Text(
  'Important body text',
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    fontWeight: FontWeight.w600,
    color: AppColors.primarySolid,
  ),
)

// Monospace text for tags
Container(
  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  decoration: BoxDecoration(
    color: AppColors.neutral100,
    borderRadius: BorderRadius.circular(4),
  ),
  child: Text(
    'TAG-001',
    style: AppTypography.codeSmall,
  ),
)

// Responsive text scaling
Text(
  'Scales with system',
  style: Theme.of(context).textTheme.bodyMedium,
  textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.85, 2.0),
)
```

### Responsive Typography Widget

```dart
// lib/core/theme/responsive_text.dart

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  const ResponsiveText(
    this.text, {
    required this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    double scaleFactor = 1.0;
    if (width < 768) {
      scaleFactor = 0.95; // Mobile: slightly smaller
    } else if (width >= 1440) {
      scaleFactor = 1.1; // Wide: larger for distance
    } else if (width >= 768 && width < 1024) {
      scaleFactor = 1.05; // Tablet: slightly larger
    }

    return Text(
      text,
      style: style.copyWith(fontSize: style.fontSize! * scaleFactor),
      textAlign: textAlign,
    );
  }
}
```

---

## Accessibility Checklist

### Readability
- [ ] Minimum 16px for body text on mobile
- [ ] Line height at least 1.5 for body text
- [ ] Line length not exceeding 90 characters
- [ ] Sufficient contrast ratios for all text
- [ ] No text smaller than 11px (overlines only)

### Dynamic Type
- [ ] Respects system font size settings
- [ ] Layout doesn't break at 2x scale
- [ ] Text doesn't truncate unnecessarily
- [ ] Spacing adjusts proportionally

### Color Contrast
- [ ] Body text: 4.5:1 minimum (AA)
- [ ] Large text: 3:1 minimum (AA)
- [ ] Headings: 4.5:1 or higher
- [ ] Links: 4.5:1 and visually distinct

### Best Practices
- [ ] Text is selectable where appropriate
- [ ] No justified text alignment
- [ ] Adequate spacing between lines and paragraphs
- [ ] Font loading doesn't cause layout shift
- [ ] Fallback fonts specified

---

**Related Documentation**
- [Style Guide](../style-guide.md)
- [Colors](./colors.md)
- [Spacing](./spacing.md)

**Last Updated**: October 19, 2025
**Version**: 1.0.0
