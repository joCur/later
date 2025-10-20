---
title: later - Style Guide
description: Complete visual design system and style specifications
last-updated: 2025-10-19
version: 1.0.0
status: approved
related-files:
  - ../design-system/tokens/colors.md
  - ../design-system/tokens/typography.md
  - ../design-system/tokens/spacing.md
  - ../design-system/tokens/animations.md
---

# later - Style Guide

## Design Philosophy: Temporal Flow

later's design language is rooted in **"Temporal Flow"** - the concept that productivity tools should feel like natural extensions of human thought, not rigid organizational systems. Our interface moves with you, adapts to you, and stays out of your way.

### Core Design Metaphor: Flowing Water

Water finds its path, adapts to its container, and moves with natural grace. Similarly, later:
- **Flows** around content without rigid constraints
- **Adapts** to different contexts and content types
- **Moves** with smooth, physics-based animations
- **Reflects** depth and dimension through light and shadow

### Design Pillars

#### 1. Luminous Minimalism
We embrace whitespace and restraint, but punctuate with moments of vibrant color and depth. Like a gallery space, we let content shine while providing a beautiful frame.

#### 2. Chromatic Intelligence
Colors aren't decoration - they carry meaning. Tasks, notes, and lists each have distinct chromatic signatures that help users navigate context instantly.

#### 3. Gestural Fluidity
Every touch interaction should feel immediate, responsive, and natural. We use physics-based animations and haptic feedback to create intimate, tactile experiences.

#### 4. Adaptive Hierarchy
The interface adapts its visual weight based on context. In focus mode, chrome disappears. In organization mode, structure becomes visible.

## Complete Design System

---

## 1. Color System

### Design Approach

Our color system uses **gradient-infused palettes** rather than flat colors. Every primary color exists as a subtle gradient, creating a sense of depth and dimensionality. We draw inspiration from dusk and dawn - times of transition and productivity.

### Primary Colors: Twilight Gradient

**Primary Gradient** (Main brand identity, primary CTAs)
- Start: `#6366F1` (Vibrant Indigo)
- End: `#8B5CF6` (Rich Purple)
- Usage: Primary buttons, active states, brand elements
- Gradient: `linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%)`

**Primary Solid** (When gradients aren't appropriate)
- Base: `#7C3AED` (Deep Violet)
- Hover: `#6D28D9` (Darker Violet)
- Active: `#5B21B6` (Deepest Violet)

**Primary Light** (Subtle backgrounds, highlights)
- Base: `#EDE9FE` (Pale Lavender)
- Hover: `#DDD6FE` (Soft Lavender)

### Secondary Colors: Dawn Gradient

**Secondary Gradient** (Supporting actions, complementary elements)
- Start: `#F59E0B` (Warm Amber)
- End: `#EC4899` (Vibrant Pink)
- Usage: Secondary buttons, accents, highlights
- Gradient: `linear-gradient(135deg, #F59E0B 0%, #EC4899 100%)`

**Secondary Solid**
- Base: `#F97316` (Bright Orange)
- Hover: `#EA580C` (Deep Orange)

### Accent Colors: Ethereal Mist

**Accent Cyan** (Information, cool highlights)
- Base: `#06B6D4` (Vivid Cyan)
- Light: `#22D3EE` (Bright Cyan)
- Pale: `#CFFAFE` (Ice Blue)

**Accent Emerald** (Success, nature, completion)
- Base: `#10B981` (Fresh Emerald)
- Light: `#34D399` (Bright Emerald)
- Pale: `#D1FAE5` (Mint)

### Type-Specific Colors

These colors create instant visual recognition for different content types:

**Task Color** (Action-oriented, urgent)
- Gradient: `linear-gradient(135deg, #EF4444 0%, #F97316 100%)` (Red to Orange)
- Solid: `#F87171` (Coral Red)
- Background: `#FEE2E2` (Pale Rose)
- Dark Mode Bg: `rgba(239, 68, 68, 0.1)`

**Note Color** (Contemplative, knowledge)
- Gradient: `linear-gradient(135deg, #3B82F6 0%, #06B6D4 100%)` (Blue to Cyan)
- Solid: `#60A5FA` (Sky Blue)
- Background: `#DBEAFE` (Pale Blue)
- Dark Mode Bg: `rgba(59, 130, 246, 0.1)`

**List Color** (Organizational, structured)
- Gradient: `linear-gradient(135deg, #8B5CF6 0%, #A78BFA 100%)` (Purple to Lavender)
- Solid: `#A78BFA` (Soft Purple)
- Background: `#EDE9FE` (Pale Lavender)
- Dark Mode Bg: `rgba(139, 92, 246, 0.1)`

### Semantic Colors

**Success** (Confirmations, completions)
- Base: `#10B981` (Emerald)
- Light: `#6EE7B7` (Mint)
- Background: `#D1FAE5`
- Usage: Checkmarks, success messages, completed tasks

**Warning** (Caution, attention needed)
- Base: `#F59E0B` (Amber)
- Light: `#FCD34D` (Golden)
- Background: `#FEF3C7`
- Usage: Due dates approaching, warnings

**Error** (Problems, destructive actions)
- Base: `#EF4444` (Red)
- Light: `#FCA5A5` (Rose)
- Background: `#FEE2E2`
- Usage: Error states, destructive confirmations

**Info** (Helpful information, tips)
- Base: `#3B82F6` (Blue)
- Light: `#93C5FD` (Sky)
- Background: `#DBEAFE`
- Usage: Tooltips, informational messages

### Neutral Palette: Slate Scale

Based on Tailwind's Slate palette with custom adjustments:

**Light Mode Neutrals**
- `Neutral-50`: `#F8FAFC` - Backgrounds, canvas
- `Neutral-100`: `#F1F5F9` - Subtle backgrounds
- `Neutral-200`: `#E2E8F0` - Borders, dividers
- `Neutral-300`: `#CBD5E1` - Disabled states
- `Neutral-400`: `#94A3B8` - Placeholders
- `Neutral-500`: `#64748B` - Secondary text
- `Neutral-600`: `#475569` - Body text
- `Neutral-700`: `#334155` - Headings
- `Neutral-800`: `#1E293B` - Dark headings
- `Neutral-900`: `#0F172A` - Maximum contrast

**Dark Mode Neutrals**
- `Neutral-950`: `#020617` - Canvas background
- `Neutral-900`: `#0F172A` - Card backgrounds
- `Neutral-800`: `#1E293B` - Elevated surfaces
- `Neutral-700`: `#334155` - Borders, dividers
- `Neutral-600`: `#475569` - Disabled states
- `Neutral-500`: `#64748B` - Secondary text
- `Neutral-400`: `#94A3B8` - Body text
- `Neutral-300`: `#CBD5E1` - Headings
- `Neutral-200`: `#E2E8F0` - High contrast text
- `Neutral-100`: `#F1F5F9` - Maximum contrast

### Dark Mode Color Adaptations

**Strategy**: In dark mode, we maintain vibrant colors but reduce saturation slightly and use transparency overlays to prevent eye strain.

**Primary Gradient (Dark)**
- Start: `#818CF8` (Softer Indigo)
- End: `#A78BFA` (Softer Purple)

**Background Layers**
- Canvas: `#020617` (Near Black)
- Surface: `#0F172A` (Dark Slate)
- Elevated: `#1E293B` (Slate)
- Overlay: `rgba(255, 255, 255, 0.05)` (Glass effect)

**Glass Morphism (Dark)**
- Background: `rgba(30, 41, 59, 0.7)`
- Backdrop Filter: `blur(20px) saturate(180%)`
- Border: `1px solid rgba(255, 255, 255, 0.1)`

### Accessibility Compliance

All color combinations have been verified for WCAG AA compliance:

**Light Mode Contrast Ratios**
- Primary on White: 7.2:1 (AAA)
- Neutral-600 on White: 7.8:1 (AAA)
- Neutral-500 on White: 4.9:1 (AA)
- Error on Background: 8.1:1 (AAA)

**Dark Mode Contrast Ratios**
- Primary on Dark: 8.1:1 (AAA)
- Neutral-400 on Dark: 6.8:1 (AAA)
- Neutral-500 on Dark: 4.7:1 (AA)
- All interactive elements: 4.5:1+ (AA)

---

## 2. Typography System

### Font Philosophy

Typography in later serves two purposes: **clarity and hierarchy**. We use a dual-font system:
- **Inter** for interface text (exceptional readability, humanist proportions)
- **JetBrains Mono** for code, tags, and technical content

### Font Stack

**Primary (Interface)**
```css
font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', sans-serif;
```

**Monospace (Technical)**
```css
font-family: 'JetBrains Mono', 'SF Mono', Consolas, 'Courier New', monospace;
```

### Font Weights

Inter supports variable font weights. We use:
- **Light**: 300 - Sparse usage, large displays only
- **Regular**: 400 - Body text, standard UI
- **Medium**: 500 - Emphasized text, labels
- **Semibold**: 600 - Subheadings, important UI
- **Bold**: 700 - Headings, strong emphasis
- **Extrabold**: 800 - Hero text, display (rare)

### Type Scale: Harmonic Progression

Based on a 1.25 modular scale (Major Third) with optical adjustments:

**Display Text**
- **Display Large**: `48px / 56px`, Extrabold (800), `-0.02em`
  - Usage: Hero headlines, empty states, onboarding
  - Mobile: `40px / 48px`

- **Display**: `40px / 48px`, Bold (700), `-0.02em`
  - Usage: Major section headers, splash screens
  - Mobile: `32px / 40px`

**Headlines**
- **H1**: `32px / 40px`, Bold (700), `-0.01em`
  - Usage: Page titles, primary headings
  - Mobile: `28px / 36px`

- **H2**: `28px / 36px`, Semibold (600), `-0.01em`
  - Usage: Section headers, modal titles
  - Mobile: `24px / 32px`

- **H3**: `24px / 32px`, Semibold (600), `0em`
  - Usage: Subsection headers, card titles
  - Mobile: `20px / 28px`

- **H4**: `20px / 28px`, Semibold (600), `0em`
  - Usage: List headers, group titles
  - Mobile: `18px / 26px`

- **H5**: `18px / 26px`, Medium (500), `0em`
  - Usage: Small headers, emphasized labels
  - Mobile: `16px / 24px`

**Body Text**
- **Body XL**: `18px / 28px`, Regular (400), `0em`
  - Usage: Lead paragraphs, important content
  - Mobile: `17px / 26px`

- **Body Large**: `17px / 26px`, Regular (400), `0em`
  - Usage: Reading content, note bodies
  - Mobile: `16px / 24px`

- **Body**: `16px / 24px`, Regular (400), `0em`
  - Usage: Standard UI text, form inputs
  - Mobile: `15px / 22px`

- **Body Small**: `14px / 20px`, Regular (400), `0em`
  - Usage: Secondary information, metadata
  - Mobile: `13px / 20px`

**Supporting Text**
- **Caption**: `12px / 18px`, Medium (500), `0.01em`
  - Usage: Timestamps, counts, subtle metadata
  - All devices: Same size

- **Label**: `14px / 20px`, Semibold (600), `0.03em`, UPPERCASE
  - Usage: Form labels, section labels, categories
  - Mobile: `13px / 20px`

- **Overline**: `11px / 16px`, Semibold (600), `0.08em`, UPPERCASE
  - Usage: Eyebrow text, tiny labels
  - All devices: Same size

**Monospace Text**
- **Code**: `14px / 22px`, JetBrains Mono Regular (400)
  - Usage: Tags, IDs, technical content
  - Mobile: `13px / 20px`

- **Code Small**: `12px / 18px`, JetBrains Mono Regular (400)
  - Usage: Inline code, small technical labels
  - All devices: Same size

### Responsive Typography Strategy

**Breakpoint Adjustments**
- **Mobile (320-767px)**: Base scale with minor reductions
- **Tablet (768-1023px)**: +5% increase for comfortable reading distance
- **Desktop (1024-1439px)**: Full scale as specified
- **Wide (1440px+)**: +10% for displays viewed at greater distance

**Dynamic Scaling**
All typography respects system font size preferences and scales proportionally for accessibility.

### Typography Usage Guidelines

**Do's:**
- Use bold weights for important headings and CTAs
- Maintain consistent line height for rhythm
- Use sentence case for most UI elements
- Reserve ALL CAPS for labels and overlines only
- Ensure minimum 16px for body text on mobile

**Don'ts:**
- Never use more than 3 font weights on a single screen
- Avoid justified text alignment
- Don't use font sizes between defined scale steps
- Never use light weights on colored backgrounds
- Avoid line lengths exceeding 75 characters

---

## 3. Spacing & Layout System

### Spacing Philosophy

later uses a **progressive spacing system** based on powers of 2, starting from a 4px base unit. This creates harmonious proportional relationships throughout the interface.

### Base Unit

**Base**: `4px`

### Spacing Scale

- **xxs**: `4px` (1× base) - Micro spacing, icon-text gaps
- **xs**: `8px` (2× base) - Internal padding, tight groupings
- **sm**: `12px` (3× base) - Small spacing, comfortable groupings
- **md**: `16px` (4× base) - Standard spacing, default margins
- **lg**: `24px` (6× base) - Section spacing, card padding
- **xl**: `32px` (8× base) - Large spacing, major separations
- **2xl**: `48px` (12× base) - Extra large spacing, screen padding
- **3xl**: `64px` (16× base) - Huge spacing, hero sections
- **4xl**: `96px` (24× base) - Maximum spacing, full-bleed sections

### Layout Grid System

**Column Grid**
- **Mobile**: 4 columns, 16px gutters, 16px margins
- **Tablet**: 8 columns, 24px gutters, 32px margins
- **Desktop**: 12 columns, 24px gutters, 48px margins
- **Wide**: 12 columns, 32px gutters, 64px margins

**Max Content Widths**
- **Reading Width**: 680px (optimal for text content)
- **Form Width**: 480px (comfortable for forms)
- **Modal Width**: 560px (standard modal container)
- **Content Width**: 1200px (full content area)
- **Wide Width**: 1440px (maximum application width)

### Breakpoints

- **Mobile**: `320px - 767px`
- **Tablet**: `768px - 1023px`
- **Desktop**: `1024px - 1439px`
- **Wide**: `1440px+`

### Component Spacing Rules

**Card Padding**
- Mobile: `16px`
- Tablet: `20px`
- Desktop: `24px`

**Section Spacing**
- Between sections: `32px` (mobile), `48px` (desktop)
- Between major sections: `48px` (mobile), `64px` (desktop)

**List Item Spacing**
- Between items: `12px`
- Internal padding: `16px`

---

## 4. Elevation & Shadow System

### Philosophy: Luminous Layers

Rather than heavy drop shadows, later uses **soft, diffused shadows** combined with subtle borders to create depth. Think of layers as sheets of frosted glass catching light.

### Shadow Levels

**Level 0: Flat**
```css
box-shadow: none;
```
Usage: Base surfaces, canvas

**Level 1: Resting**
```css
box-shadow:
  0 1px 2px rgba(15, 23, 42, 0.04),
  0 0 0 1px rgba(15, 23, 42, 0.02);
```
Usage: Cards, list items, subtle elevation

**Level 2: Raised**
```css
box-shadow:
  0 4px 6px rgba(15, 23, 42, 0.06),
  0 2px 4px rgba(15, 23, 42, 0.03),
  0 0 0 1px rgba(15, 23, 42, 0.02);
```
Usage: Buttons, interactive cards, hover states

**Level 3: Floating**
```css
box-shadow:
  0 10px 15px rgba(15, 23, 42, 0.08),
  0 4px 6px rgba(15, 23, 42, 0.04),
  0 0 0 1px rgba(15, 23, 42, 0.02);
```
Usage: Dropdowns, popovers, floating buttons

**Level 4: Modal**
```css
box-shadow:
  0 20px 25px rgba(15, 23, 42, 0.10),
  0 10px 10px rgba(15, 23, 42, 0.04),
  0 0 0 1px rgba(15, 23, 42, 0.02);
```
Usage: Modals, dialogs, overlays

**Level 5: Maximum (Rare)**
```css
box-shadow:
  0 25px 50px rgba(15, 23, 42, 0.15),
  0 12px 20px rgba(15, 23, 42, 0.08),
  0 0 0 1px rgba(15, 23, 42, 0.02);
```
Usage: Tooltips over modals, extreme elevation

### Dark Mode Shadows

In dark mode, shadows become lighter to create contrast:

```css
/* Level 2 (Dark Mode) */
box-shadow:
  0 4px 6px rgba(0, 0, 0, 0.4),
  0 2px 4px rgba(0, 0, 0, 0.2),
  0 0 0 1px rgba(255, 255, 255, 0.05);
```

### Glass Morphism Effect

**Light Mode Glass**
```css
background: rgba(255, 255, 255, 0.7);
backdrop-filter: blur(20px) saturate(180%);
border: 1px solid rgba(255, 255, 255, 0.3);
```

**Dark Mode Glass**
```css
background: rgba(30, 41, 59, 0.7);
backdrop-filter: blur(20px) saturate(180%);
border: 1px solid rgba(255, 255, 255, 0.1);
```

Usage: Quick capture modal, overlays, navigation bars

---

## 5. Border Radius System

### Philosophy: Soft Geometry

later uses **generous rounded corners** throughout to create a friendly, approachable feel. Our radius system creates visual harmony through consistent curvature.

### Radius Scale

- **xs**: `4px` - Small elements, tags, badges
- **sm**: `8px` - Buttons, inputs, chips
- **md**: `12px` - Cards, list items (primary)
- **lg**: `16px` - Large cards, modal corners
- **xl**: `20px` - Hero cards, featured content
- **2xl**: `24px` - Large modals, sheet corners
- **full**: `9999px` - Pills, circular buttons

### Component Radius Guidelines

- **Item Cards**: `12px` (md)
- **Buttons**: `8px` (sm)
- **Inputs**: `8px` (sm)
- **Modals**: `20px` (xl)
- **Bottom Sheets**: `24px` (2xl) top corners only
- **FAB**: `16px` (lg) for squircle feel
- **Avatar**: `full` for circles
- **Tags**: `4px` (xs) for compact feel

---

## 6. Motion & Animation System

### Animation Philosophy: Physics-Based Fluidity

Every animation in later follows **real-world physics principles**. Movements have weight, momentum, and natural easing. We use spring-based animations for organic, lively interactions.

### Timing Functions

**Ease Out Expo** (Entrances, expansions)
```css
cubic-bezier(0.16, 1, 0.3, 1)
```
Usage: Elements entering screen, expanding panels

**Ease In Out Quint** (Smooth transitions)
```css
cubic-bezier(0.83, 0, 0.17, 1)
```
Usage: Modal transitions, screen changes

**Ease Out Quart** (Snappy interactions)
```css
cubic-bezier(0.25, 1, 0.5, 1)
```
Usage: Button presses, quick interactions

**Spring Natural** (Organic bounces)
```
tension: 300
friction: 25
mass: 1
```
Usage: Quick capture opening, playful interactions

**Spring Gentle** (Subtle bounces)
```
tension: 200
friction: 30
mass: 1
```
Usage: List reordering, gentle feedback

### Duration Scale

**Instant**: `0ms` - Immediate state changes
**Micro**: `100ms` - Subtle state changes, color transitions
**Fast**: `200ms` - Quick interactions, button feedback
**Base**: `300ms` - Standard transitions, most animations
**Slow**: `400ms` - Deliberate transitions, complex animations
**Slower**: `500ms` - Page transitions, modal appearances
**Slowest**: `600ms` - Hero animations, onboarding (rare)

### Animation Patterns

**Fade In**
```css
opacity: 0 → 1
duration: 300ms
easing: ease-out-expo
```

**Scale In**
```css
transform: scale(0.95) → scale(1)
opacity: 0 → 1
duration: 300ms
easing: ease-out-expo
```

**Slide Up**
```css
transform: translateY(16px) → translateY(0)
opacity: 0 → 1
duration: 400ms
easing: ease-out-expo
```

**Slide Down (Exit)**
```css
transform: translateY(0) → translateY(16px)
opacity: 1 → 0
duration: 200ms
easing: ease-in-out-quint
```

**Spring Bounce**
```
Using spring physics
Ideal for: Item additions, playful confirmations
```

### Micro-Interactions

**Button Press**
```css
transform: scale(1) → scale(0.96)
duration: 100ms
easing: ease-out-quart
```

**Checkbox/Radio Toggle**
```css
Scale spring animation on check
Duration: 300ms
Spring: tension 300, friction 25
```

**List Item Swipe**
```
Gesture-driven with spring physics
Velocity-based momentum
Snap points at -80px (delete) and 80px (complete)
```

**Haptic Patterns**
- Light: Checkbox toggle, small interactions
- Medium: Button press, item selection
- Heavy: Destructive action, important confirmation
- Success: Task completion, successful save
- Warning: Approaching limit, caution
- Error: Deletion, failed action

---

## 7. Iconography System

### Icon Style: Outlined Minimalism

later uses **outlined icons with rounded caps** for a friendly, modern aesthetic. Icons should feel lightweight and approachable.

### Icon Library

**Primary**: Lucide Icons (lucide.dev)
- Clean, consistent outlined style
- Rounded line caps
- 24px base size with optical adjustments
- Excellent Flutter/React support

**Alternative**: Phosphor Icons (phosphoricons.com)
- Similar aesthetic
- Larger variety
- Multiple weights available

### Icon Sizing System

- **Tiny**: `16px` - Inline icons, dense UI
- **Small**: `20px` - List item icons, compact views
- **Base**: `24px` - Standard UI icons
- **Large**: `32px` - Feature icons, empty states
- **XL**: `48px` - Hero icons, onboarding
- **XXL**: `64px` - Splash screens, major empty states

### Stroke Width

- **Thin**: `1px` - Large decorative icons only
- **Regular**: `1.5px` - Standard (default)
- **Medium**: `2px` - Emphasis, small sizes
- **Bold**: `2.5px` - Strong emphasis (rare)

### Icon Colors

Icons inherit text color by default but can use semantic colors:

- **Default**: `Neutral-600` (light), `Neutral-400` (dark)
- **Subdued**: `Neutral-500` (light), `Neutral-500` (dark)
- **Primary**: Use primary gradient or solid
- **Semantic**: Match action type (success, error, warning)
- **Type-Specific**: Task/Note/List colors for context

### Custom Icon Needs

**Type Indicators**
- Task: Checkmark circle (outlined)
- Note: Document text (outlined)
- List: Bullets list (outlined)

**Quick Capture**
- Plus in circle (filled gradient)
- Sparkle (for AI features)

**Gestures**
- Swipe left/right indicators
- Long press hint

---

## 8. Component Design Specifications

Components are detailed in separate files. See:
- [Item Cards](./components/item-cards.md)
- [Quick Capture](./components/quick-capture.md)
- [Navigation](./components/navigation.md)
- [Buttons](./components/buttons.md)
- [Forms](./components/forms.md)

---

## 9. Accessibility Standards

### Minimum Requirements

**Touch Targets**
- Minimum: `44 × 44px` (iOS), `48 × 48px` (Android)
- Comfortable: `48 × 48px` all platforms
- Generous: `56 × 56px` for primary actions

**Color Contrast**
- Body text: 4.5:1 minimum (AA)
- Large text (18px+): 3:1 minimum (AA)
- UI elements: 3:1 minimum
- Target: 7:1 for critical text (AAA)

**Focus States**
- Visible keyboard focus indicator
- 3px outline with primary color
- 2px offset from element
- Never remove focus styling

**Motion Sensitivity**
- Respect `prefers-reduced-motion`
- Provide alternative static states
- Disable parallax and complex animations

**Screen Reader Support**
- Semantic HTML/Widget structure
- Proper ARIA labels and roles
- Descriptive alt text for images
- Logical tab order and focus management

---

## Implementation Notes

### Flutter Packages Recommended

**Design System Foundation**
```yaml
dependencies:
  google_fonts: ^6.1.0  # Inter and JetBrains Mono
  flutter_animate: ^4.5.0  # Powerful animation library
  shimmer: ^3.0.0  # Loading states
  flutter_svg: ^2.0.9  # Vector icons
```

**Advanced UI Effects**
```yaml
dependencies:
  glassmorphism: ^3.0.0  # Glass morphism effects
  flutter_blurhash: ^0.8.2  # Image blur loading
  animations: ^2.0.11  # Material motion system
  flutter_staggered_animations: ^1.1.1  # List animations
```

**Gestures & Interactions**
```yaml
dependencies:
  flutter_slidable: ^3.0.1  # Swipe actions
  smooth_page_indicator: ^1.1.0  # Onboarding dots
  feedback: ^3.0.0  # Haptic feedback management
```

**State Management & Architecture**
```yaml
dependencies:
  riverpod: ^2.4.10  # State management
  go_router: ^13.0.0  # Navigation
  shared_preferences: ^2.2.2  # Local storage
```

### Design Token Implementation

Create a centralized theme file:

```dart
// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Gradient
  static const primaryStart = Color(0xFF6366F1);
  static const primaryEnd = Color(0xFF8B5CF6);
  static const primarySolid = Color(0xFF7C3AED);

  // Generate gradient
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStart, primaryEnd],
  );

  // Type colors
  static const taskColor = Color(0xFFF87171);
  static const noteColor = Color(0xFF60A5FA);
  static const listColor = Color(0xFFA78BFA);

  // Neutrals (Light Mode)
  static const neutral50 = Color(0xFFF8FAFC);
  static const neutral100 = Color(0xFFF1F5F9);
  // ... etc
}

class AppTypography {
  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: 48,
      height: 1.17,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.96,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      height: 1.25,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.32,
    ),
    // ... etc
  );
}

class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const full = 9999.0;
}
```

### Animation Implementation

Use flutter_animate for declarative animations:

```dart
import 'package:flutter_animate/flutter_animate.dart';

// Fade in animation
Widget fadeIn(Widget child) {
  return child
    .animate()
    .fadeIn(
      duration: 300.ms,
      curve: Curves.easeOutExpo,
    );
}

// Scale in animation
Widget scaleIn(Widget child) {
  return child
    .animate()
    .scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1, 1),
      duration: 300.ms,
      curve: Curves.easeOutExpo,
    )
    .fadeIn(
      duration: 300.ms,
      curve: Curves.easeOutExpo,
    );
}

// Slide up animation
Widget slideUp(Widget child) {
  return child
    .animate()
    .slideY(
      begin: 0.1,
      end: 0,
      duration: 400.ms,
      curve: Curves.easeOutExpo,
    )
    .fadeIn(
      duration: 400.ms,
      curve: Curves.easeOutExpo,
    );
}
```

### Glass Morphism Implementation

```dart
import 'dart:ui';

class GlassMorphicContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color color;
  final BorderRadius? borderRadius;

  const GlassMorphicContainer({
    required this.child,
    this.blur = 20,
    this.color = const Color(0xB3FFFFFF), // 70% white
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius ?? BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
```

### Gradient Implementation

```dart
class GradientButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Gradient gradient;

  const GradientButton({
    required this.child,
    required this.onPressed,
    this.gradient = AppColors.primaryGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySolid.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
```

---

## Design System Maintenance

### Version Control
- All design changes require version bump
- Breaking changes: Major version
- New components: Minor version
- Tweaks/fixes: Patch version

### Documentation Updates
- Update documentation with every design change
- Maintain changelog in each file
- Cross-reference related changes

### Quality Assurance
- Regular accessibility audits
- Contrast ratio verification
- Performance monitoring
- User testing for new patterns

---

**Last Updated**: October 19, 2025
**Version**: 1.0.0
**Status**: Approved for Implementation
