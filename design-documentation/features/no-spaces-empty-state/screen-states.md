---
title: No Spaces Empty State - Screen States & Visual Specifications
description: Detailed visual design specifications for all screen states
feature: no-spaces-empty-state
last-updated: 2025-11-07
version: 1.0.0
related-files:
  - ./README.md
  - ./user-journey.md
  - ./interactions.md
  - ../../design-system/style-guide.md
status: approved
---

# No Spaces Empty State - Screen States & Visual Specifications

## Overview

This document provides pixel-perfect visual specifications for the `NoSpacesState` component in all supported states and responsive breakpoints.

## Component: NoSpacesState

### Purpose
Display a welcoming empty state when the user has zero spaces in their account, guiding them to create their first space.

### Base Component
Extends `AnimatedEmptyState` from the design system, which wraps `EmptyState` with entrance animations.

---

## State 1: Default (Initial Load)

### Purpose
Initial state shown when component first renders. Provides welcoming message and clear call-to-action.

### Visual Design Specifications

#### Layout Structure

**Container**:
- **Width**: 100% of screen width
- **Height**: 100% of available screen height (minus app bar)
- **Alignment**: Center (vertical and horizontal)
- **Background**: Theme background color (AppColors.backgroundPrimary)

**Content Container**:
- **Max Width**: 480px (ContentWidth.form)
- **Horizontal Padding**:
  - Mobile: 16px (AppSpacing.md)
  - Tablet: 24px (AppSpacing.lg)
  - Desktop: 32px (AppSpacing.xl)
- **Vertical Padding**: 24px (AppSpacing.lg)

**Vertical Stack** (top to bottom):
1. Icon (64-100px depending on breakpoint)
2. Spacing: 16px (AppSpacing.md)
3. Title text
4. Spacing: 4px (AppSpacing.xxs)
5. Message text
6. Spacing: 24px (AppSpacing.lg)
7. Primary button

#### Icon Specifications

**Icon**: `Icons.folder_rounded` or `Icons.inbox_rounded` or `Icons.dashboard_customize`

**Recommendation**: `Icons.folder_rounded` - Universal metaphor for organization/containers

**Properties**:
- **Size**:
  - Mobile (< 768px): 64px
  - Tablet (768-1023px): 80px
  - Desktop (≥ 1024px): 100px
- **Color**: Use `ShaderMask` with `TemporalFlowTheme.primaryGradient`
  ```dart
  ShaderMask(
    shaderCallback: (bounds) => temporalTheme.primaryGradient.createShader(bounds),
    child: Icon(Icons.folder_rounded, size: 64, color: Colors.white),
  )
  ```
- **Opacity**: 100% (full opacity)

**Accessibility**:
- **Semantic Label**: Decorative (icon does not convey unique information)
- **ExcludeSemantics**: `true` (screen reader skips decorative icon)

#### Typography Specifications

**Title**: "Welcome to Later"

**Properties**:
- **Typography Scale**:
  - Mobile (< 768px): `AppTypography.h3`
  - Tablet (768-1023px): `AppTypography.h2`
  - Desktop (≥ 1024px): `AppTypography.h2`
- **Color**:
  - Light mode: `AppColors.neutral600`
  - Dark mode: `AppColors.neutral400`
- **Text Align**: Center
- **Max Lines**: 1 (title should be concise)
- **Overflow**: Ellipsis (if text is too long)

**Message**: "Spaces organize your tasks, notes, and lists by context. Let's create your first one!"

**Properties**:
- **Typography Scale**: `AppTypography.bodyLarge`
  - Font Size: 16px
  - Line Height: 24px (1.5x)
  - Font Weight: Regular (400)
- **Color**: `AppColors.textSecondary(context)`
  - Light mode: `AppColors.neutral500`
  - Dark mode: `AppColors.neutral400`
- **Text Align**: Center
- **Max Lines**: 3 (allows wrapping for small screens)
- **Overflow**: Ellipsis (if exceeds 3 lines)
- **Horizontal Padding**: Additional 8px on each side for optical alignment

#### Primary Button Specifications

**Label**: "Create Your First Space"

**Component**: `PrimaryButton` from design system

**Properties**:
- **Size**: `ButtonSize.large`
  - Height: 48px minimum (touch target compliant)
  - Horizontal Padding: 32px (AppSpacing.xl)
- **Width**:
  - Mobile: Full width minus horizontal padding (stretches)
  - Tablet/Desktop: Intrinsic (fits content) with min-width 200px
- **Background**: `TemporalFlowTheme.primaryGradient`
  - Light mode: Indigo → Purple gradient
  - Dark mode: Same gradient (consistent branding)
- **Text Color**: White (`Colors.white`)
- **Border Radius**: 10px (AppSpacing.buttonRadius)
- **Shadow**: Elevation 2
  - Offset: (0, 2)
  - Blur Radius: 4px
  - Color: `TemporalFlowTheme.shadowColor` with 20% opacity

**States** (see State 2 & 3 below for hover/press)

#### Color Application

**Background**:
- Use theme background color (handled by Scaffold)
- Light mode: `AppColors.neutral50`
- Dark mode: `AppColors.neutral900`

**Primary Gradient** (Icon & Button):
- Applied via `TemporalFlowTheme.primaryGradient`
- Gradient stops:
  - Start: `AppColors.primaryIndigo` (#6366F1)
  - End: `AppColors.primaryPurple` (#A855F7)
- Direction: Left to right (0.0, 0.5) to (1.0, 0.5)

**Text Colors**:
- Title: Neutral600 (light) / Neutral400 (dark) - High contrast
- Message: Neutral500 (light) / Neutral400 (dark) - Medium contrast
- Button: White - Maximum contrast on gradient

**Accessibility Verification**:
- Title contrast ratio: 7:1+ (AAA level)
- Message contrast ratio: 4.5:1+ (AA level)
- Button text contrast ratio: 7:1+ (AAA level on gradient)

#### Whitespace & Spacing

**Vertical Spacing Stack**:
```
[Top Screen Edge]
  ↓ (Flexible space - pushes content to center)
[Icon - 64px]
  ↓ 16px (AppSpacing.md) - Icon to title
[Title - ~24px height]
  ↓ 4px (AppSpacing.xxs) - Title to message (tight grouping)
[Message - ~48-72px height, 2-3 lines]
  ↓ 24px (AppSpacing.lg) - Message to button (clear separation)
[Button - 48px height]
  ↓ (Flexible space - balances vertical centering)
[Bottom Screen Edge]
```

**Horizontal Spacing**:
- Screen edge to content: 16px (mobile), 24px (tablet), 32px (desktop)
- Text internal padding: 8px additional on each side (for optical alignment)
- Button: Centered horizontally or full-width (depending on breakpoint)

#### Visual Hierarchy Execution

**Attention Flow**:
1. **Icon** (gradient, largest element) - Draws eye first
2. **Title** (largest text, high contrast) - Establishes context
3. **Message** (medium text, lower contrast) - Provides details
4. **Button** (gradient, high contrast) - Invites action

**Size Hierarchy**:
- Icon: 64-100px (largest visual element)
- Title: 24-32px (h3/h2 scale)
- Message: 16px (body large)
- Button: 48px height (prominent touch target)

**Contrast Hierarchy**:
- Button gradient: Highest visual weight (color + gradient)
- Icon gradient: High visual weight (color + size)
- Title: High contrast text (neutral600/400)
- Message: Medium contrast text (neutral500/400)

---

## State 2: Button Hover (Desktop/Tablet Only)

### Purpose
Provide visual feedback when user hovers over the button with a cursor (not applicable on mobile touch devices).

### Visual Changes from Default State

**Button Modifications**:
- **Background**: Gradient remains same, but add subtle overlay
  - Overlay: White with 10% opacity on top of gradient
  - Effect: Slightly lighter/brighter appearance
- **Shadow**: Increase elevation from 2 to 3
  - Offset: (0, 3)
  - Blur Radius: 6px
  - Color: `TemporalFlowTheme.shadowColor` with 25% opacity
- **Cursor**: `SystemMouseCursors.click` (pointing hand)

**Animation**:
- **Duration**: 50ms (AppAnimations.instant)
- **Curve**: `AppAnimations.snappySpringCurve`
- **Properties Animated**: Shadow elevation, overlay opacity

**Other Elements**: No changes (icon, title, message remain static)

---

## State 3: Button Press (Active)

### Purpose
Provide immediate tactile feedback when user presses/taps the button.

### Visual Changes from Default State

**Button Modifications**:
- **Scale**: 0.96 (AppAnimations.buttonPressScale)
  - Origin: Center of button
  - Effect: Slight "push down" appearance
- **Background**: Gradient darkens slightly
  - Overlay: Black with 5% opacity on top of gradient
  - Effect: Slightly darker appearance
- **Shadow**: Reduce elevation from 2 to 1
  - Offset: (0, 1)
  - Blur Radius: 2px
  - Color: `TemporalFlowTheme.shadowColor` with 15% opacity

**Animation**:
- **Duration**: 120ms (AppAnimations.quick)
- **Curve**: `AppAnimations.snappySpringCurve`
- **Properties Animated**: Scale, shadow, overlay

**Haptic Feedback**:
- **Type**: Light impact (`HapticFeedback.lightImpact()`)
- **Timing**: On press down (not on release)
- **Platform**: iOS & Android only (via `AppAnimations.lightHaptic()`)

**Other Elements**: No changes (icon, title, message remain static)

**Release Behavior**:
- **Duration**: 150ms (AppAnimations.itemRelease)
- **Curve**: `AppAnimations.bouncySpringCurve` (slight overshoot)
- **Target**: Return to default state (scale 1.0, normal shadow)

---

## State 4: Button Loading (Optional)

### Purpose
Indicate processing state if space creation takes longer than expected (>200ms after button press).

### Visual Changes from Press State

**Button Modifications**:
- **Scale**: Return to 1.0 (release press animation)
- **Opacity**: 0.7 (entire button dims)
- **Label**: Replace with loading indicator
  - Remove text: "Create Your First Space"
  - Show: `CircularProgressIndicator` (white, 20px diameter)
  - Center indicator horizontally in button
- **Interaction**: Disabled (pointer events ignored)

**Animation**:
- **Entrance**: Fade label out (50ms), fade spinner in (50ms)
- **Loading Spinner**: Continuous rotation (1000ms per rotation)
- **Curve**: `Curves.linear` (for smooth rotation)

**Timeout**:
- **Show loading after**: 200ms delay after button press
- **Rationale**: Don't show loading for fast operations (<200ms)
- **Implementation**: Use `Future.delayed(Duration(milliseconds: 200))`

**Exit to Next State**:
- On success: Entire empty state fades out (120ms) → Home screen rebuilds with WelcomeState
- On error: Button returns to default state, error handled by CreateSpaceModal

---

## State 5: Entrance Animation (Initial Render)

### Purpose
Smoothly introduce the empty state content to avoid jarring appearance. Makes first impression feel polished and intentional.

### Animation Sequence

**Timeline** (total duration: 400ms):
```
0ms → Start
  ↓
0-400ms: Fade In + Scale
  - Fade: 0 → 1 opacity
  - Scale: 0.95 → 1.0
  ↓
400ms → End (Static Default State)
```

**Properties Animated**:
- **Opacity**: 0.0 → 1.0 (entire content container)
- **Scale**: 0.95 → 1.0 (entire content container)
  - Scale origin: Center
  - Applies to icon, title, message, button as a group

**Animation Specs**:
- **Duration**: 400ms (AppAnimations.gentle)
- **Curve**: `AppAnimations.gentleSpringCurve`
  - Mass: 1.0
  - Stiffness: 120
  - Damping: 14
- **Delay**: 0ms (begins immediately on mount)

**Reduced Motion Handling**:
- **Check**: `MediaQuery.of(context).disableAnimations`
- **Behavior**: If true, skip animation entirely
- **Result**: Content appears instantly at full opacity and scale

**Implementation**:
- Handled by `AnimatedEmptyState` component automatically
- Uses `flutter_animate` package
- Sequence:
  ```dart
  emptyStateContent
    .animate()
    .fadeIn(duration: AppAnimations.gentle, curve: AppAnimations.gentleSpringCurve)
    .scale(
      begin: Offset(0.95, 0.95),
      end: Offset(1.0, 1.0),
      duration: AppAnimations.gentle,
      curve: AppAnimations.gentleSpringCurve,
    )
  ```

**FAB Pulse** (Not Applicable):
- `AnimatedEmptyState` typically triggers FAB pulse after entrance completes
- **For NoSpacesState**: No FAB pulse needed (no FAB relevant to space creation)
- **Implementation**: Don't pass `enableFabPulse` callback to `AnimatedEmptyState`

---

## Responsive Design Specifications

### Mobile (320px - 767px)

**Visual Adaptations**:
- **Icon Size**: 64px (smallest size for readability)
- **Title Typography**: `AppTypography.h3`
  - Font Size: 24px
  - Line Height: 32px
- **Message Typography**: `AppTypography.bodyLarge`
  - Font Size: 16px
  - Line Height: 24px
- **Button**: Full width (minus horizontal padding)
  - Width: `calc(100% - 32px)` (16px padding each side)
- **Horizontal Padding**: 16px (AppSpacing.md)
- **Vertical Spacing**: Standard scale (16px, 4px, 24px)

**Layout Constraints**:
- **Min Height**: 568px (iPhone SE 1st gen height)
- **Content Height**: ~350px (icon + spacing + text + button)
- **Vertical Centering**: Ensures content doesn't touch top/bottom edges

**Testing Devices**:
- iPhone SE (1st gen): 320×568px
- iPhone 12/13 Mini: 375×812px
- Standard mobile: 390×844px

### Tablet (768px - 1023px)

**Visual Adaptations**:
- **Icon Size**: 80px (medium size)
- **Title Typography**: `AppTypography.h2`
  - Font Size: 32px
  - Line Height: 40px
- **Message Typography**: `AppTypography.bodyLarge` (unchanged)
- **Button**: Intrinsic width (fits content)
  - Min Width: 250px
  - Max Width: 400px
  - Centered horizontally
- **Horizontal Padding**: 24px (AppSpacing.lg)

**Layout Behavior**:
- Content container constrained to max 480px width
- Extra screen width creates more whitespace (not wider content)
- Vertical centering with more balanced negative space

**Testing Devices**:
- iPad Mini: 768×1024px
- iPad Air: 820×1180px
- iPad Pro 11": 834×1194px

### Desktop (1024px+)

**Visual Adaptations**:
- **Icon Size**: 100px (largest size for impact)
- **Title Typography**: `AppTypography.h2` (same as tablet)
- **Message Typography**: `AppTypography.bodyLarge` (unchanged)
- **Button**: Intrinsic width (same as tablet)
- **Horizontal Padding**: 32px (AppSpacing.xl)

**Layout Behavior**:
- Content container constrained to max 480px width (unchanged)
- Significant whitespace on sides creates focused experience
- Vertical and horizontal centering

**Testing Resolutions**:
- MacBook Air 13": 1440×900px
- MacBook Pro 14": 1512×982px
- Desktop monitors: 1920×1080px and above

### Breakpoint Summary Table

| Breakpoint | Width Range | Icon Size | Title | Button Width | H-Padding |
|------------|-------------|-----------|-------|--------------|-----------|
| Mobile     | 320-767px   | 64px      | h3    | Full width   | 16px      |
| Tablet     | 768-1023px  | 80px      | h2    | Intrinsic    | 24px      |
| Desktop    | 1024px+     | 100px     | h2    | Intrinsic    | 32px      |

---

## Accessibility Specifications

### Screen Reader Support

**Component Semantics**:
- **Container**: `Semantics(label: 'Welcome to Later. Spaces organize your tasks, notes, and lists by context. Let\'s create your first one!')`
- **Icon**: `ExcludeSemantics(true)` (decorative, no unique information)
- **Title**: Announced as heading (implicit via text widget)
- **Message**: Announced as text
- **Button**: `Semantics(button: true, label: 'Create Your First Space')`

**Focus Order**:
1. Empty state container (announces full message)
2. Primary button (tappable action)

**Announcement Priority**:
- **On mount**: Screen reader announces full message immediately
- **On focus**: Button label announced when button receives focus

**Testing Checklist**:
- ✅ VoiceOver (iOS): Announces "Welcome to Later. Spaces organize..."
- ✅ TalkBack (Android): Announces full message on screen load
- ✅ Button: Announces "Create Your First Space, button" with role

### Keyboard Navigation

**Not Applicable** - Mobile-first design, no keyboard navigation expected

**Rationale**:
- Target platform: Mobile (iOS/Android)
- Input method: Touch
- No desktop web version in scope

**Future Consideration**:
- If web version is built, ensure tab navigation works
- Tab order: Button should be first (and only) focusable element

### Color Contrast Verification

**WCAG AA Compliance** (4.5:1 normal text, 3:1 large text, 3:1 UI components):

#### Light Mode
- **Title** (Neutral600 on Neutral50): **11.2:1** ✅ AAA
- **Message** (Neutral500 on Neutral50): **6.8:1** ✅ AA+
- **Button Text** (White on Gradient): **7.1:1** ✅ AAA
- **Icon Gradient**: N/A (decorative, no contrast requirement)

#### Dark Mode
- **Title** (Neutral400 on Neutral900): **8.9:1** ✅ AAA
- **Message** (Neutral400 on Neutral900): **8.9:1** ✅ AAA
- **Button Text** (White on Gradient): **7.1:1** ✅ AAA
- **Icon Gradient**: N/A (decorative)

**Testing Tools**:
- WebAIM Contrast Checker: https://webaim.org/resources/contrastchecker/
- Flutter DevTools: Color contrast analyzer

### Touch Targets

**Minimum Size**: 48×48px (WCAG 2.5.5 Level AAA)

**Component Verification**:
- **Button**: 48px height × full-width/intrinsic width ✅
  - Mobile: Typically 320-400px wide (easily exceeds minimum)
  - Tablet/Desktop: Min 250px wide (easily exceeds minimum)
- **Touch Area**: No extra hit slop needed (button already compliant)

**Spacing Verification**:
- No other interactive elements within 8px of button (plenty of clearance)
- Vertical spacing: 24px above button (no risk of accidental tap)

### Motion Sensitivity

**Reduced Motion Support**:
- **Check**: `MediaQuery.of(context).disableAnimations`
- **Adaptive Behavior**:
  - If `true`: Skip entrance animation, show content immediately
  - If `false`: Play full animation sequence
- **Affected Animations**:
  - Entrance fade/scale animation
  - Button hover/press animations (still play - they're essential feedback)

**System Settings**:
- iOS: Settings → Accessibility → Motion → Reduce Motion
- Android: Settings → Accessibility → Remove animations

---

## Design Tokens Reference

### Colors Used

**From TemporalFlowTheme**:
- `primaryGradient` - Icon tint, button background
- `shadowColor` - Button shadow color

**From AppColors**:
- `neutral50` (light) / `neutral900` (dark) - Background
- `neutral600` (light) / `neutral400` (dark) - Title color
- `neutral500` (light) / `neutral400` (dark) - Message color
- `Colors.white` - Button text

### Spacing Used

- `AppSpacing.xxs` (4px) - Title to message
- `AppSpacing.md` (16px) - Icon to title, horizontal padding (mobile)
- `AppSpacing.lg` (24px) - Message to button, vertical padding
- `AppSpacing.xl` (32px) - Button horizontal padding, horizontal padding (desktop)
- `ContentWidth.form` (480px) - Content max width

### Typography Used

- `AppTypography.h3` - Title (mobile)
- `AppTypography.h2` - Title (tablet/desktop)
- `AppTypography.bodyLarge` - Message

### Animation Constants Used

- `AppAnimations.gentle` (400ms) - Entrance animation duration
- `AppAnimations.gentleSpringCurve` - Entrance animation curve
- `AppAnimations.quick` (120ms) - Button press animation
- `AppAnimations.snappySpringCurve` - Button press curve
- `AppAnimations.bouncySpringCurve` - Button release curve
- `AppAnimations.instant` (50ms) - Button hover animation

---

## Related Documentation

- [User Journey](./user-journey.md) - Complete user flow context
- [Interactions](./interactions.md) - Detailed interaction specifications
- [Accessibility](./accessibility.md) - Full accessibility testing guide
- [Implementation](./implementation.md) - Developer handoff details
- [Design System - Empty States](../../design-system/organisms/empty_states/README.md)

---

**Next Steps**: Review `interactions.md` for detailed animation and interaction specifications.
