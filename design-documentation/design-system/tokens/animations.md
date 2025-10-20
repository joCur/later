---
title: Animation Tokens
description: Motion system, timing functions, and animation patterns
last-updated: 2025-10-19
version: 1.0.0
status: approved
related-files:
  - ../style-guide.md
  - ../components/quick-capture.md
---

# Animation Tokens

## Animation Philosophy: Physics-Based Fluidity

Animations in later follow **real-world physics principles**. Every movement has weight, momentum, and natural easing. We use spring-based animations for organic, lively interactions that feel responsive and alive.

### Core Principles

1. **Purposeful Motion**: Every animation serves a functional purpose
2. **Natural Physics**: Movements follow real-world physics
3. **Performance First**: 60fps minimum, hardware acceleration
4. **Accessibility**: Respect `prefers-reduced-motion`
5. **Consistency**: Similar actions use similar timings

---

## Timing Functions (Easing Curves)

### Ease Out Expo

**Best for**: Entrances, expansions, revealing content

```css
cubic-bezier(0.16, 1, 0.3, 1)
```

**Characteristics**:
- Starts fast, decelerates smoothly
- Feels responsive and immediate
- Natural settling motion

**Usage**:
- Elements entering screen
- Expanding panels
- Modal openings
- Dropdown reveals

```dart
Curves.easeOutExpo
```

### Ease In Out Quint

**Best for**: Smooth transitions, transformations

```css
cubic-bezier(0.83, 0, 0.17, 1)
```

**Characteristics**:
- Smooth acceleration and deceleration
- Balanced, sophisticated feel
- Good for complex transitions

**Usage**:
- Modal transitions
- Screen changes
- Large movements
- State transformations

```dart
Curves.easeInOutQuint
```

### Ease Out Quart

**Best for**: Snappy interactions, quick feedback

```css
cubic-bezier(0.25, 1, 0.5, 1)
```

**Characteristics**:
- Quick start, smooth end
- Snappy but not abrupt
- Responsive feel

**Usage**:
- Button presses
- Quick interactions
- Toggle switches
- Menu items

```dart
Curves.easeOutQuart
```

### Ease In Out Circ

**Best for**: Dramatic movements, hero animations

```css
cubic-bezier(0.85, 0, 0.15, 1)
```

**Characteristics**:
- Dramatic acceleration/deceleration
- Elegant, sweeping motion
- Use sparingly

**Usage**:
- Hero transitions
- Onboarding sequences
- Special moments
- Celebratory animations

```dart
Curves.easeInOutCirc
```

### Linear

**Best for**: Continuous motion, looping animations

```css
cubic-bezier(0, 0, 1, 1)
```

**Usage**:
- Loading spinners
- Continuous rotations
- Progress indicators
- Infinite loops

```dart
Curves.linear
```

---

## Spring Animations

### Spring Natural

**Best for**: Organic bounces, playful interactions

```dart
// Spring physics parameters
tension: 300
friction: 25
mass: 1
```

**Characteristics**:
- Natural bounce effect
- Playful, alive feeling
- Quick but organic

**Usage**:
- Quick capture modal opening
- Item additions to lists
- Success confirmations
- Playful micro-interactions

**Implementation**:
```dart
// Using flutter_animate
widget.animate()
  .scale(
    duration: 400.ms,
    curve: Curves.elasticOut,
  )
```

### Spring Gentle

**Best for**: Subtle bounces, refined interactions

```dart
tension: 200
friction: 30
mass: 1
```

**Characteristics**:
- Subtle bounce
- Refined, polished feel
- Gentle settling

**Usage**:
- List reordering
- Gentle feedback
- Subtle confirmations
- Refined micro-interactions

**Implementation**:
```dart
widget.animate()
  .scale(
    duration: 500.ms,
    curve: Curves.elasticOut,
  )
```

### Spring Bouncy

**Best for**: Celebratory moments, dramatic effects

```dart
tension: 400
friction: 20
mass: 1
```

**Characteristics**:
- Pronounced bounce
- Energetic, exciting
- Attention-grabbing

**Usage**:
- Task completion celebrations
- Achievement unlocks
- Special confirmations
- Rare, impactful moments

---

## Duration Scale

| Token | Duration | Usage |
|-------|----------|-------|
| **instant** | `0ms` | Immediate state changes |
| **micro** | `100ms` | Subtle state changes, color transitions |
| **fast** | `200ms` | Quick interactions, button feedback |
| **base** | `300ms` | Standard transitions (default) |
| **slow** | `400ms` | Deliberate transitions, complex animations |
| **slower** | `500ms` | Page transitions, modal appearances |
| **slowest** | `600ms` | Hero animations, onboarding (rare) |

### Duration Guidelines

**0-100ms**: Instant feedback
- Color changes
- Opacity toggles
- Immediate state changes

**100-200ms**: Quick interactions
- Button presses
- Checkbox toggles
- Hover states
- Focus indicators

**200-300ms**: Standard transitions
- Menu openings
- Tooltip appearances
- Small movements
- Most animations (default)

**300-400ms**: Deliberate transitions
- Card expansions
- Panel slides
- Complex state changes
- Multi-property animations

**400-500ms**: Page-level transitions
- Screen changes
- Modal appearances
- Large movements
- Important transitions

**500ms+**: Special moments
- Onboarding sequences
- Hero animations
- Celebratory moments
- Use sparingly

---

## Animation Patterns

### Fade In

**When to use**: Gentle appearances, subtle reveals

```dart
widget.animate()
  .fadeIn(
    duration: 300.ms,
    curve: Curves.easeOutExpo,
  )
```

**CSS Equivalent**:
```css
opacity: 0 → 1;
duration: 300ms;
easing: cubic-bezier(0.16, 1, 0.3, 1);
```

**Use Cases**:
- Text appearing
- Subtle UI reveals
- Tooltip appearances

### Fade Out

**When to use**: Gentle exits, dismissals

```dart
widget.animate()
  .fadeOut(
    duration: 200.ms,
    curve: Curves.easeInOutQuint,
  )
```

**Use Cases**:
- Toast dismissals
- Tooltip hiding
- Subtle exits

### Scale In

**When to use**: Emphasis, attention-grabbing entrances

```dart
widget.animate()
  .scale(
    begin: const Offset(0.95, 0.95),
    end: const Offset(1, 1),
    duration: 300.ms,
    curve: Curves.easeOutExpo,
  )
  .fadeIn(duration: 300.ms)
```

**Use Cases**:
- Modal openings
- Important alerts
- Featured content
- Quick capture modal

### Scale Out

**When to use**: Dismissals, item removals

```dart
widget.animate()
  .scale(
    begin: const Offset(1, 1),
    end: const Offset(0.95, 0.95),
    duration: 200.ms,
    curve: Curves.easeInOutQuint,
  )
  .fadeOut(duration: 200.ms)
```

**Use Cases**:
- Modal closings
- Item deletions
- Dismissing alerts

### Slide Up

**When to use**: Bottom sheets, rising content

```dart
widget.animate()
  .slideY(
    begin: 0.1, // Start 10% down
    end: 0,
    duration: 400.ms,
    curve: Curves.easeOutExpo,
  )
  .fadeIn(duration: 400.ms)
```

**Use Cases**:
- Bottom sheets
- Success messages
- Rising notifications
- Mobile sheets

### Slide Down (Exit)

**When to use**: Dismissing bottom sheets

```dart
widget.animate()
  .slideY(
    begin: 0,
    end: 0.1,
    duration: 200.ms,
    curve: Curves.easeInOutQuint,
  )
  .fadeOut(duration: 200.ms)
```

**Use Cases**:
- Bottom sheet dismissal
- Notification exit
- Downward movements

### Slide In (Horizontal)

**When to use**: Side panels, navigation

```dart
// From right
widget.animate()
  .slideX(
    begin: 0.1,
    end: 0,
    duration: 300.ms,
    curve: Curves.easeOutExpo,
  )

// From left
widget.animate()
  .slideX(
    begin: -0.1,
    end: 0,
    duration: 300.ms,
    curve: Curves.easeOutExpo,
  )
```

**Use Cases**:
- Side navigation
- Swipe actions reveal
- Horizontal panels

### Expand/Collapse

**When to use**: Accordions, expandable sections

```dart
// Expand
AnimatedSize(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeOutExpo,
  child: expanded ? FullContent() : CollapsedContent(),
)
```

**Use Cases**:
- Accordions
- Expandable cards
- Show more/less
- Collapsible sections

### Shimmer (Loading)

**When to use**: Content loading states

```dart
// Using shimmer package
Shimmer.fromColors(
  baseColor: AppColors.neutral200,
  highlightColor: AppColors.neutral100,
  period: Duration(milliseconds: 1200),
  child: ContentSkeleton(),
)
```

**Use Cases**:
- Loading skeletons
- Content placeholders
- Async data loading

---

## Micro-Interactions

### Button Press

```dart
// Scale down on press
GestureDetector(
  onTapDown: (_) {
    // Scale to 0.96
  },
  onTapUp: (_) {
    // Scale to 1.0
  },
  child: widget.animate()
    .scale(
      duration: 100.ms,
      curve: Curves.easeOutQuart,
    ),
)
```

**Parameters**:
- Duration: 100ms
- Scale: 1.0 → 0.96 → 1.0
- Curve: Ease Out Quart

### Checkbox/Radio Toggle

```dart
// Spring bounce on check
Checkbox(
  // ...
).animate(target: isChecked ? 1 : 0)
  .scale(
    duration: 300.ms,
    curve: Curves.elasticOut,
  )
```

**Parameters**:
- Duration: 300ms
- Spring: Natural bounce
- Scale: Subtle pop effect

### Hover State

```dart
// Gentle lift on hover
MouseRegion(
  onEnter: (_) {
    // Lift up slightly
  },
  onExit: (_) {
    // Return to original
  },
  child: AnimatedContainer(
    duration: Duration(milliseconds: 200),
    curve: Curves.easeOutQuart,
    // Apply shadow change
  ),
)
```

**Parameters**:
- Duration: 200ms
- Curve: Ease Out Quart
- Shadow: Level 1 → Level 2

### Swipe Action Reveal

```dart
// Gesture-driven with spring physics
// Use flutter_slidable package
Slidable(
  endActionPane: ActionPane(
    motion: const DrawerMotion(),
    children: [...],
  ),
)
```

**Parameters**:
- Spring physics based on velocity
- Snap points: -80px (delete), 80px (complete)
- Momentum-based

### Pull to Refresh

```dart
RefreshIndicator(
  onRefresh: () async {
    // Refresh action
  },
  // Custom physics
  displacement: 40,
  edgeOffset: 0,
)
```

**Parameters**:
- Duration: 300ms
- Rotation during pull
- Spring settle on release

---

## Haptic Feedback Patterns

### Haptic Levels

```dart
import 'package:flutter/services.dart';

// Light tap
HapticFeedback.lightImpact();

// Medium tap
HapticFeedback.mediumImpact();

// Heavy tap
HapticFeedback.heavyImpact();

// Selection change
HapticFeedback.selectionClick();

// Vibrate (Android)
HapticFeedback.vibrate();
```

### Usage Guidelines

**Light Impact**:
- Checkbox toggle
- Radio button select
- Small interactions
- Subtle feedback

**Medium Impact**:
- Button press
- Item selection
- Swipe action
- Standard interactions

**Heavy Impact**:
- Destructive action
- Important confirmation
- Task completion
- Significant events

**Selection Click**:
- Scrolling through picker
- Dragging slider
- Continuous selection
- List scrubbing

**Success Pattern**:
```dart
// Two light impacts
HapticFeedback.lightImpact();
Future.delayed(Duration(milliseconds: 50), () {
  HapticFeedback.lightImpact();
});
```

**Error Pattern**:
```dart
// Heavy + Light
HapticFeedback.heavyImpact();
Future.delayed(Duration(milliseconds: 100), () {
  HapticFeedback.lightImpact();
});
```

---

## Page Transitions

### Fade Transition

```dart
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => NextPage(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  },
  transitionDuration: Duration(milliseconds: 300),
)
```

### Slide Transition

```dart
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => NextPage(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    const begin = Offset(1.0, 0.0); // From right
    const end = Offset.zero;
    const curve = Curves.easeOutExpo;

    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  },
  transitionDuration: Duration(milliseconds: 400),
)
```

### Scale Transition

```dart
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => NextPage(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutExpo,
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  },
  transitionDuration: Duration(milliseconds: 300),
)
```

---

## Loading States

### Spinner

```dart
CircularProgressIndicator(
  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primarySolid),
  strokeWidth: 3,
)
```

**Duration**: Continuous (linear)
**Usage**: Indeterminate loading

### Linear Progress

```dart
LinearProgressIndicator(
  value: progress, // 0.0 to 1.0
  backgroundColor: AppColors.neutral200,
  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primarySolid),
)
```

**Duration**: Based on actual progress
**Usage**: Determinate loading

### Skeleton Shimmer

```dart
Shimmer.fromColors(
  baseColor: AppColors.neutral200,
  highlightColor: AppColors.neutral100,
  period: Duration(milliseconds: 1200),
  child: Container(
    width: double.infinity,
    height: 16,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
    ),
  ),
)
```

**Duration**: 1200ms loop
**Usage**: Content loading placeholders

---

## Accessibility: Reduced Motion

### Implementation

```dart
// Check for reduced motion preference
bool get reduceMotion {
  return WidgetsBinding.instance.window.accessibilityFeatures.disableAnimations;
}

// Conditional animation
widget.animate()
  .fadeIn(
    duration: reduceMotion ? 0.ms : 300.ms,
  )

// Alternative: Provide static alternative
if (reduceMotion) {
  return StaticWidget();
} else {
  return AnimatedWidget();
}
```

### Guidelines

When `prefers-reduced-motion` is enabled:
- Disable complex animations
- Keep essential transitions (instant or very fast)
- Maintain state changes (no animation)
- Preserve functionality

**Essential Transitions** (keep even with reduced motion):
- Focus indicators (instant)
- State changes (instant or 100ms max)
- Critical feedback (simplified)

**Disable Completely**:
- Parallax effects
- Auto-playing animations
- Continuous motion
- Decorative animations

---

## Flutter Implementation

### Animation Tokens Class

```dart
// lib/core/theme/app_animations.dart

import 'package:flutter/material.dart';

class AppAnimations {
  AppAnimations._();

  // DURATIONS
  static const Duration instant = Duration.zero;
  static const Duration micro = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration base = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 500);
  static const Duration slowest = Duration(milliseconds: 600);

  // CURVES
  static const Curve easeOutExpo = Cubic(0.16, 1, 0.3, 1);
  static const Curve easeInOutQuint = Cubic(0.83, 0, 0.17, 1);
  static const Curve easeOutQuart = Cubic(0.25, 1, 0.5, 1);
  static const Curve easeInOutCirc = Cubic(0.85, 0, 0.15, 1);

  // SPRING PRESETS (for flutter_animate)
  static const springNatural = (tension: 300.0, friction: 25.0);
  static const springGentle = (tension: 200.0, friction: 30.0);
  static const springBouncy = (tension: 400.0, friction: 20.0);

  // ACCESSIBILITY
  static bool get reduceMotion {
    return WidgetsBinding.instance.window.accessibilityFeatures.disableAnimations;
  }

  static Duration getDuration(Duration normal) {
    return reduceMotion ? Duration.zero : normal;
  }

  // COMMON ANIMATIONS
  static Widget fadeIn(Widget child, {Duration? duration}) {
    return AnimatedOpacity(
      opacity: 1,
      duration: getDuration(duration ?? base),
      curve: easeOutExpo,
      child: child,
    );
  }

  static Widget scaleIn(Widget child, {Duration? duration}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.0),
      duration: getDuration(duration ?? base),
      curve: easeOutExpo,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  static Widget slideUp(Widget child, {Duration? duration}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 16.0, end: 0.0),
      duration: getDuration(duration ?? slow),
      curve: easeOutExpo,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: Opacity(
            opacity: 1 - (value / 16),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
```

### Using flutter_animate

```dart
import 'package:flutter_animate/flutter_animate.dart';

// Fade in
Text('Hello').animate()
  .fadeIn(
    duration: AppAnimations.base,
    curve: AppAnimations.easeOutExpo,
  );

// Scale in with fade
Container(...)
  .animate()
  .scale(
    begin: const Offset(0.95, 0.95),
    duration: AppAnimations.base,
    curve: AppAnimations.easeOutExpo,
  )
  .fadeIn(duration: AppAnimations.base);

// Slide up
Widget()
  .animate()
  .slideY(
    begin: 0.1,
    duration: AppAnimations.slow,
    curve: AppAnimations.easeOutExpo,
  )
  .fadeIn(duration: AppAnimations.slow);

// With conditional reduced motion
Widget()
  .animate(
    onPlay: (controller) {
      if (AppAnimations.reduceMotion) {
        controller.duration = Duration.zero;
      }
    },
  )
  .fadeIn();
```

### Interactive Animations

```dart
// Button press animation
class PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  @override
  _PressableButtonState createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.micro,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOutQuart),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## Performance Optimization

### Best Practices

1. **Use Hardware Acceleration**
```dart
// Opacity, Transform, and some others are GPU-accelerated
Transform.translate() // Good
Transform.scale()     // Good
Opacity()             // Good
```

2. **Avoid Layout Changes**
```dart
// Bad: Causes layout recalculation
AnimatedContainer(width: _width)

// Good: No layout change
Transform.scale(scale: _scale, child: Container())
```

3. **Use RepaintBoundary**
```dart
RepaintBoundary(
  child: AnimatedWidget(),
)
```

4. **Limit Simultaneous Animations**
- Maximum 3-4 concurrent animations
- Stagger complex animations
- Use AnimationController.dispose()

### Performance Checklist

- [ ] Animations run at 60fps
- [ ] No jank or dropped frames
- [ ] Hardware acceleration used where possible
- [ ] RepaintBoundary used for expensive widgets
- [ ] Animation controllers properly disposed
- [ ] Reduced motion preference respected
- [ ] No layout thrashing during animations

---

**Related Documentation**
- [Style Guide](../style-guide.md)
- [Quick Capture Component](../components/quick-capture.md)
- [Item Cards Component](../components/item-cards.md)

**Last Updated**: October 19, 2025
**Version**: 1.0.0
