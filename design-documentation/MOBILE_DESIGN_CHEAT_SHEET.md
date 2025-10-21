# Mobile-First Bold Redesign - Quick Reference Cheat Sheet

**For**: Developers implementing the mobile redesign
**Last Updated**: 2025-10-21

---

## 📏 Key Measurements (Mobile: 320-767px)

### Cards
```
Border:     6px gradient (type-specific)
Radius:     20px (pill shape)
Padding:    24px horizontal, 20px vertical
Margins:    16px from screen edges
Gap:        16px between cards
Background: Solid (NO gradients)
Height:     ~120px (flexible, based on content)
```

### Typography
```
Title:    18px, weight 700 (bold), line-height 1.4
Preview:  15px, weight 400, line-height 1.5, 60% opacity
Meta:     13px, weight 500, line-height 1.4, 50% opacity
Max lines: 2 lines for title, 2 lines for preview
```

### Spacing (8px base unit on mobile)
```
xxs:  8px   — icon + text gap
xs:   12px  — related elements
sm:   16px  — between cards
md:   24px  — card padding, screen margins
lg:   32px  — section spacing
xl:   48px  — major sections
xxl:  64px  — hero spacing
```

### Navigation
```
Height:     64px
Icons:      24×24px (48×48px touch target)
Underline:  3px height, 48px width, primary gradient
Background: Solid (NO glass effect)
Labels:     NONE (icons only)
```

### FAB
```
Size:       56×56px (circular)
Radius:     28px (half of 56)
Background: Primary gradient (indigo→purple)
Icon:       24×24px, white
Shadow:     4px blur, 20% opacity
Position:   16px from bottom-right
```

---

## 🎨 Gradient Colors

### Type-Specific Borders (6px pill)

**Task (Red → Orange):**
```dart
Light: [0xFFEF4444, 0xFFF97316] // bright red → orange
Dark:  [0xFFDC2626, 0xFFEA580C] // darker for contrast
```

**Note (Blue → Cyan):**
```dart
Light: [0xFF3B82F6, 0xFF06B6D4] // bright blue → cyan
Dark:  [0xFF2563EB, 0xFF0891B2] // darker for contrast
```

**List (Purple → Lavender):**
```dart
Light: [0xFF8B5CF6, 0xFFC084FC] // bright purple → lavender
Dark:  [0xFF7C3AED, 0xFFA78BFA] // darker for contrast
```

**Primary (Bottom Nav, FAB):**
```dart
Light: [0xFF4F46E5, 0xFF7C3AED] // indigo → purple
Dark:  [0xFF4338CA, 0xFF6D28D9] // darker for contrast
```

**Gradient Direction**: `135deg` (top-left → bottom-right) for cards

---

## 🎬 Animation Timings

### Durations
```
Instant:  50ms   — color changes
Quick:    100ms  — press scale
Normal:   200ms  — checkbox, fade
Gentle:   250ms  — nav transition, icon rotate
Slow:     300ms  — modal slide
```

### Curves
```
Press:      easeOut           — button press
Fade:       easeInOut         — opacity changes
Slide:      easeOut           — modal entry
Scale:      easeOut           — FAB press
Nav:        easeInOut         — tab transitions
```

### Key Animations
```dart
// Card Press
scale: 0.98, duration: 100ms, curve: easeOut
haptic: light

// Checkbox Toggle
scale: 1.0 → 1.15 → 1.0, duration: 200ms
haptic: medium

// FAB Press
scale: 0.92, duration: 100ms
rotate: 0° → 45° (+ → ×), duration: 250ms
haptic: medium

// Bottom Nav Transition
underline slide: 250ms, curve: easeInOut
icon color: 200ms, curve: easeInOut
haptic: selection

// Modal Open
background fade: 200ms
modal slide up: 300ms, curve: easeOut
```

---

## 🎯 Touch Targets (Minimum 48×48px)

```
✅ Bottom nav icons:   48×48px
✅ FAB:                56×56px
✅ Card tap area:      Full card (120px+ height)
✅ Checkbox:           24px visual, 48px touch zone
✅ Filter chips:       44px height minimum
✅ App bar icons:      48×48px
```

---

## 📱 Breakpoints

```
Mobile:   320px - 767px   (8px spacing base, mobile optimizations)
Tablet:   768px - 1023px  (4px spacing base, desktop patterns)
Desktop:  1024px+          (4px spacing base, full features)
```

---

## 🎨 Quick Color Reference (Light Mode)

```
Background:    #FFFFFF      — Pure white
Surface:       #F8F9FA      — Very light gray
Border:        #E5E7EB      — 20% neutral

Text Primary:  #111827      — Near black (100% opacity)
Text Secondary:#6B7280      — 60% of primary
Text Tertiary: #9CA3AF      — 50% of primary

Success:       #10B981      — Green
Error:         #EF4444      — Red
Warning:       #F59E0B      — Amber
Info:          #3B82F6      — Blue
```

---

## 🎨 Quick Color Reference (Dark Mode)

```
Background:    #0F172A      — Very dark blue-gray
Surface:       #1E293B      — Slightly lighter
Border:        #334155      — 20% light

Text Primary:  #F8FAFC      — Near white (100% opacity)
Text Secondary:#94A3B8      — 60% of primary
Text Tertiary: #64748B      — 50% of primary

Success:       #10B981      — Green (same)
Error:         #DC2626      — Darker red
Warning:       #F59E0B      — Amber (same)
Info:          #2563EB      — Darker blue
```

---

## 📋 Component Checklist

### ItemCard
```
✅ 6px gradient pill border (type-specific)
✅ 20px corner radius
✅ Solid background (no gradients)
✅ 18px bold title (max 2 lines)
✅ 15px preview (60% opacity, max 2 lines)
✅ 13px meta (50% opacity)
✅ 24px horizontal padding
✅ 20px vertical padding
✅ 16px margins from screen
✅ RepaintBoundary wrapper (performance)
```

### BottomNavigationBar
```
✅ 64px height
✅ Icons only (no labels)
✅ 24×24px icons, 48×48px touch targets
✅ 3px gradient underline for active
✅ Solid background (no glass)
✅ 250ms transition animation
✅ Haptic feedback on tap
✅ SafeArea wrapper
```

### QuickCaptureFab
```
✅ 56×56px circular
✅ Primary gradient background
✅ White icon (24×24px)
✅ 4px shadow (20% opacity, tinted)
✅ 16px from bottom-right
✅ Icon rotates: + → × (250ms)
✅ Scale press: 0.92 (100ms)
✅ Medium haptic on press
```

### AppBar
```
✅ 56px height
✅ Solid background (no glass)
✅ 1px gradient separator bottom
✅ 18px bold title (center)
✅ Space switcher icon (left)
✅ Settings/actions (right)
✅ SafeArea wrapper
```

### QuickCaptureModal
```
✅ Bottom sheet style (not centered)
✅ 24px top corner radius
✅ 4px gradient top border
✅ 32×4px drag handle
✅ Solid background (no glass)
✅ 24px padding all sides
✅ Keyboard-aware height
✅ Type selector chips (horizontal)
✅ 300ms slide animation
```

---

## ⚡ Performance Guidelines

### Always Do:
```
✅ Use RepaintBoundary on cards
✅ Use const constructors
✅ Use ListView.builder (not ListView)
✅ Specify itemExtent when possible
✅ Cache gradient instances
✅ Profile with DevTools before commit
```

### Never Do:
```
❌ Gradient backgrounds on cards
❌ BackdropFilter (glass) on scrolling elements
❌ setState in scroll callbacks
❌ Heavy computations in build()
❌ Nested ListView/GridView
❌ Complex spring physics on every animation
```

### Target Metrics:
```
Frame rate:     60fps average
Frame budget:   < 16ms per frame
Jank:           < 10% dropped frames
Memory:         < 100MB typical usage
Cold start:     < 2 seconds
```

---

## 🧪 Testing Checklist

### Before Every Commit:
```
[ ] Visual test on 320px, 360px, 414px widths
[ ] Scroll 100+ cards at 60fps
[ ] Profile with DevTools (no jank)
[ ] Dark mode verification
[ ] Reduced motion test
[ ] Screen reader navigation
[ ] Touch target verification (48×48px)
```

### Before Release:
```
[ ] Physical device testing (2021 Android)
[ ] Accessibility audit (WCAG AA)
[ ] Performance profiling (60fps target)
[ ] Memory leak check (< 100MB)
[ ] Battery drain test (< 10% per hour)
[ ] Small screen test (320px)
[ ] Contrast ratio verification (4.5:1)
```

---

## 🔧 Common Code Patterns

### Gradient Border Widget
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20.0),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [startColor, endColor],
    ),
  ),
  child: Container(
    margin: EdgeInsets.all(6.0), // Border width
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14.0), // 20-6
    ),
    child: child,
  ),
)
```

### Responsive Spacing
```dart
double _getSpacing(BuildContext context, double mobile, double desktop) {
  final width = MediaQuery.of(context).size.width;
  return width < 768 ? mobile : desktop;
}
```

### Mobile Typography
```dart
TextStyle mobileTitleLarge(BuildContext context) {
  return TextStyle(
    fontFamily: 'Inter',
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: Theme.of(context).colorScheme.onSurface,
  );
}
```

### Gradient Underline (Active Nav)
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 250),
  curve: Curves.easeInOut,
  width: 48.0,
  height: 3.0,
  decoration: isActive ? BoxDecoration(
    borderRadius: BorderRadius.circular(1.5),
    gradient: LinearGradient(
      colors: [primaryStart, primaryEnd],
    ),
  ) : null,
)
```

### Haptic Feedback
```dart
// Light (selection, navigation)
HapticFeedback.selectionClick();

// Medium (checkbox, FAB, important actions)
HapticFeedback.mediumImpact();

// Heavy (delete, destructive actions)
HapticFeedback.heavyImpact();
```

---

## 🚨 Quick Troubleshooting

### Problem: Cards look cramped on 320px
**Fix**: Reduce padding from 24px to 20px on very small screens
```dart
final padding = width < 340 ? 20.0 : 24.0;
```

### Problem: Gradient borders cause jank
**Fix**: Wrap in RepaintBoundary
```dart
RepaintBoundary(child: CardGradientBorder(...))
```

### Problem: Bottom nav jumps with keyboard
**Fix**: Use resizeToAvoidBottomInset: false
```dart
Scaffold(resizeToAvoidBottomInset: false, ...)
```

### Problem: Dark mode gradients too bright
**Fix**: Use darker gradient colors (see color reference above)

### Problem: Text too small on large text setting
**Fix**: Use MediaQuery.textScaleFactor and clamp to 2.0
```dart
final scaleFactor = MediaQuery.textScaleFactorOf(context).clamp(1.0, 2.0);
```

---

## 📚 Documentation Links

**Full Design Spec**: [MOBILE-FIRST-BOLD-REDESIGN.md](./MOBILE-FIRST-BOLD-REDESIGN.md)
**Implementation Guide**: [MOBILE_IMPLEMENTATION_QUICK_START.md](./MOBILE_IMPLEMENTATION_QUICK_START.md)
**Visual Comparison**: [MOBILE_VISUAL_COMPARISON.md](./MOBILE_VISUAL_COMPARISON.md)
**Executive Summary**: [MOBILE_REDESIGN_SUMMARY.md](./MOBILE_REDESIGN_SUMMARY.md)

---

## ✅ Quick Success Check

Before shipping, can you answer YES to all?

```
[ ] Screenshots on 360px phone look distinctive (not generic Material)
[ ] 100+ cards scroll at 60fps on 2021 Android
[ ] Users can identify task/note/list types without reading labels
[ ] Bottom nav feels spacious (not cramped)
[ ] FAB feels Android-native (not iOS-esque)
[ ] Text is readable at arm's length without focusing
[ ] Dark mode gradients have proper contrast
[ ] All touch targets ≥ 48×48px
[ ] Reduced motion skips animations gracefully
[ ] Memory usage < 100MB during typical use
```

If all YES → **SHIP IT!** 🚀

---

**Keep this cheat sheet handy during implementation!**
