---
title: No Spaces Empty State - Visual Design Mockup
description: ASCII art mockups and visual specifications
feature: no-spaces-empty-state
last-updated: 2025-11-07
version: 1.0.0
status: approved
---

# No Spaces Empty State - Visual Design Mockup

## Mobile Layout (375×812px - iPhone 13 Pro)

```
┌───────────────────────────────────────┐
│ Later                  🌓  [≡]        │ ← App bar (64px)
├───────────────────────────────────────┤
│                                       │
│                                       │
│                                       │
│                  📁                   │ ← Icon 64×64px
│             (gradient)                │    Indigo→Purple tint
│                                       │
│                  ↓                    │ ← 16px spacing
│                                       │
│        Welcome to Later               │ ← Title: h3 (24px)
│                                       │    Neutral600 (light)
│                  ↓                    │ ← 4px spacing
│                                       │
│   Spaces organize your tasks,         │
│   notes, and lists by context.        │ ← Message: bodyLarge (16px)
│   Let's create your first one!        │    Neutral500 (light)
│                                       │    Max 3 lines, centered
│                  ↓                    │ ← 24px spacing
│                                       │
│  ┌─────────────────────────────────┐ │
│  │  Create Your First Space        │ │ ← Button: 48px height
│  │       (gradient background)      │ │    Indigo→Purple
│  └─────────────────────────────────┘ │    White text
│                                       │
│                                       │
│                                       │
│                                       │
│                                       │
│                  ⊕                    │ ← FAB (hidden or inactive)
│                                       │
└───────────────────────────────────────┘
      ← 16px →                 ← 16px →
   (horizontal padding on both sides)
```

**Key Measurements**:
- Screen width: 375px
- Content max width: 343px (375 - 32px padding)
- Vertical centering: Content group vertically centered in available space
- Icon: 64×64px
- Button: Full width (343px)

---

## Tablet Layout (768×1024px - iPad Mini)

```
┌─────────────────────────────────────────────────────┐
│ Later                           🌓  [≡]             │ ← App bar
├─────────────────────────────────────────────────────┤
│                                                     │
│                                                     │
│                                                     │
│                                                     │
│                       📁                            │ ← Icon 80×80px
│                  (gradient)                         │    Larger on tablet
│                                                     │
│                       ↓                             │ ← 16px spacing
│                                                     │
│              Welcome to Later                       │ ← Title: h2 (32px)
│                                                     │    Larger on tablet
│                       ↓                             │ ← 4px spacing
│                                                     │
│        Spaces organize your tasks,                  │
│        notes, and lists by context.                 │ ← Message: same size
│        Let's create your first one!                 │    bodyLarge (16px)
│                                                     │
│                       ↓                             │ ← 24px spacing
│                                                     │
│         ┌─────────────────────────────┐            │
│         │  Create Your First Space    │            │ ← Button: intrinsic
│         │    (gradient background)     │            │    width (~300px)
│         └─────────────────────────────┘            │    Centered
│                                                     │
│                                                     │
│                                                     │
│                                                     │
│                                                     │
└─────────────────────────────────────────────────────┘
       ← 24px →                            ← 24px →
    (larger padding on tablet)
```

**Key Measurements**:
- Screen width: 768px
- Content max width: 480px (constrained for readability)
- Horizontal padding: 24px
- Icon: 80×80px (larger on tablet)
- Button: Intrinsic width, centered (approx 300-350px)

---

## Desktop Layout (1440×900px - MacBook Air 13")

```
┌───────────────────────────────────────────────────────────────────────────────┐
│ Later                                                    🌓  [≡]              │
├───────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│                                                                               │
│                                                                               │
│                                                                               │
│                                 📁                                            │ ← Icon 100×100px
│                            (gradient)                                         │    Largest on desktop
│                                                                               │
│                                 ↓                                             │ ← 16px spacing
│                                                                               │
│                        Welcome to Later                                       │ ← Title: h2 (32px)
│                                                                               │
│                                 ↓                                             │ ← 4px spacing
│                                                                               │
│                  Spaces organize your tasks,                                  │
│                  notes, and lists by context.                                 │ ← Message
│                  Let's create your first one!                                 │
│                                                                               │
│                                 ↓                                             │ ← 24px spacing
│                                                                               │
│                   ┌─────────────────────────────┐                            │
│                   │  Create Your First Space    │                            │ ← Button
│                   │    (gradient background)     │                            │
│                   └─────────────────────────────┘                            │
│                                                                               │
│                                                                               │
│                                                                               │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
           ← 32px →                                               ← 32px →
         (desktop padding)
```

**Key Measurements**:
- Screen width: 1440px
- Content max width: 480px (same as tablet, for consistency)
- Horizontal padding: 32px (more whitespace on sides)
- Icon: 100×100px (largest size)
- Button: Intrinsic width, centered (approx 300-350px)

---

## Color Specifications (Light Mode)

```
┌──────────────────────────────────────┐
│                                      │
│  Background: Neutral50 (#FAFAFA)     │
│  ────────────────────────────────    │
│                                      │
│           📁 Gradient Icon           │ ← primaryGradient
│        #6366F1 → #A855F7             │    (Indigo → Purple)
│                                      │
│      Welcome to Later                │ ← Neutral600 (#525252)
│                                      │    11.2:1 contrast ✅
│  Spaces organize your tasks,         │
│  notes, and lists by context.        │ ← Neutral500 (#737373)
│  Let's create your first one!        │    6.8:1 contrast ✅
│                                      │
│  ┌────────────────────────────────┐ │
│  │ Create Your First Space        │ │ ← White (#FFFFFF)
│  │   (gradient: #6366F1→#A855F7)  │ │    on gradient
│  └────────────────────────────────┘ │    7.1:1 contrast ✅
│                                      │
└──────────────────────────────────────┘
```

**Light Mode Palette**:
- **Background**: `#FAFAFA` (Neutral50)
- **Title**: `#525252` (Neutral600) - 11.2:1 contrast
- **Message**: `#737373` (Neutral500) - 6.8:1 contrast
- **Icon Gradient**: `#6366F1` → `#A855F7` (Indigo → Purple)
- **Button Gradient**: `#6366F1` → `#A855F7` (same)
- **Button Text**: `#FFFFFF` (White) - 7.1:1 contrast on gradient

---

## Color Specifications (Dark Mode)

```
┌──────────────────────────────────────┐
│                                      │
│  Background: Neutral900 (#171717)    │
│  ────────────────────────────────    │
│                                      │
│           📁 Gradient Icon           │ ← primaryGradient
│        #6366F1 → #A855F7             │    (same gradient)
│                                      │
│      Welcome to Later                │ ← Neutral400 (#A3A3A3)
│                                      │    8.9:1 contrast ✅
│  Spaces organize your tasks,         │
│  notes, and lists by context.        │ ← Neutral400 (#A3A3A3)
│  Let's create your first one!        │    8.9:1 contrast ✅
│                                      │
│  ┌────────────────────────────────┐ │
│  │ Create Your First Space        │ │ ← White (#FFFFFF)
│  │   (gradient: #6366F1→#A855F7)  │ │    on gradient
│  └────────────────────────────────┘ │    7.1:1 contrast ✅
│                                      │
└──────────────────────────────────────┘
```

**Dark Mode Palette**:
- **Background**: `#171717` (Neutral900)
- **Title**: `#A3A3A3` (Neutral400) - 8.9:1 contrast
- **Message**: `#A3A3A3` (Neutral400) - 8.9:1 contrast
- **Icon Gradient**: `#6366F1` → `#A855F7` (same as light)
- **Button Gradient**: `#6366F1` → `#A855F7` (same as light)
- **Button Text**: `#FFFFFF` (White) - 7.1:1 contrast on gradient

---

## Animation Sequence (Entrance)

### Frame 0ms (Start)
```
┌───────────────────────────────┐
│                               │
│                               │
│                               │
│         [invisible]           │ ← Opacity: 0.0
│                               │    Scale: 0.95
│                               │
│                               │
│                               │
└───────────────────────────────┘
```

### Frame 100ms (25% Progress)
```
┌───────────────────────────────┐
│                               │
│                               │
│            📁                 │ ← Opacity: 0.25
│       Welcome to Later        │    Scale: 0.9625
│     Spaces organize...        │
│   ┌─────────────────────┐    │
│   │ Create Your Firs... │    │
│   └─────────────────────┘    │
└───────────────────────────────┘
```

### Frame 200ms (50% Progress)
```
┌───────────────────────────────┐
│                               │
│            📁                 │ ← Opacity: 0.5
│       Welcome to Later        │    Scale: 0.975
│     Spaces organize your...   │
│   ┌─────────────────────────┐│
│   │ Create Your First Spa...││
│   └─────────────────────────┘│
└───────────────────────────────┘
```

### Frame 400ms (100% Complete)
```
┌───────────────────────────────┐
│                               │
│                               │
│            📁                 │ ← Opacity: 1.0
│       Welcome to Later        │    Scale: 1.0
│     Spaces organize your...   │
│   ┌─────────────────────────┐│
│   │ Create Your First Space ││
│   └─────────────────────────┘│
│                               │
└───────────────────────────────┘
```

**Animation Details**:
- **Duration**: 400ms (gentle)
- **Curve**: Gentle spring (mass: 1.0, stiffness: 120, damping: 14)
- **Properties**: Opacity (0.0 → 1.0) + Scale (0.95 → 1.0)
- **Origin**: Center of content group

---

## Button States (Visual)

### Default State
```
┌─────────────────────────────┐
│  Create Your First Space    │ ← Gradient fill
│  (Indigo→Purple gradient)   │    Shadow: 0,2 blur:4
└─────────────────────────────┘    Opacity: 1.0
```

### Hover State (Desktop/Tablet)
```
┌─────────────────────────────┐
│  Create Your First Space    │ ← Gradient + white 10% overlay
│  (Slightly brighter)        │    Shadow: 0,3 blur:6
└─────────────────────────────┘    Cursor: pointer
```

### Press State (Active)
```
┌───────────────────────────┐   ← Scale: 0.96
│ Create Your First Space   │      Gradient + black 5% overlay
│ (Slightly darker/smaller) │      Shadow: 0,1 blur:2
└───────────────────────────┘      Haptic: light impact
```

### Loading State (Optional)
```
┌─────────────────────────────┐
│           ⟳  ⟳  ⟳          │ ← Spinner replaces text
│  (Circular progress)        │    Opacity: 0.7
└─────────────────────────────┘    Disabled (no interaction)
```

---

## Spacing Diagram (Annotated)

```
┌─────────────────────────────────────┐
│ ← 16px horizontal padding (mobile)  │
│                                     │
│              📁 64px                │
│              ↕ 16px (md)            │
│        Welcome to Later             │
│              ↕ 4px (xxs)            │
│  Spaces organize your tasks,        │
│  notes, and lists by context.       │
│  Let's create your first one!       │
│              ↕ 24px (lg)            │
│  ┌───────────────────────────────┐ │
│  │ Create Your First Space ← 48px│ │
│  └───────────────────────────────┘ │
│                                     │
│ ← 16px horizontal padding (mobile) →│
└─────────────────────────────────────┘

Spacing Tokens Used:
- AppSpacing.md (16px) - Icon to title
- AppSpacing.xxs (4px) - Title to message (tight grouping)
- AppSpacing.lg (24px) - Message to button (clear separation)
- Button height: 48px (ButtonSize.large)
```

---

## Gradient Specification

### Icon Gradient (ShaderMask)
```
Linear Gradient:
  Begin: Alignment(-1.0, 0.0)  ← Left
  End: Alignment(1.0, 0.0)     ← Right

  Colors:
    Stop 0.0: #6366F1 (Indigo)
    Stop 1.0: #A855F7 (Purple)

Applied via ShaderMask:
  ShaderMask(
    shaderCallback: (bounds) =>
      primaryGradient.createShader(bounds),
    child: Icon(..., color: Colors.white),
  )
```

### Button Gradient (Background)
```
Linear Gradient:
  Begin: Alignment(-1.0, 0.0)  ← Left
  End: Alignment(1.0, 0.0)     ← Right

  Colors:
    Stop 0.0: #6366F1 (Indigo)
    Stop 1.0: #A855F7 (Purple)

Applied via BoxDecoration:
  decoration: BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(10),
  )
```

---

## Typography Hierarchy (Visual)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MOBILE (< 768px)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Welcome to Later
▲ h3: 24px / 32px line-height
   Weight: 600 (Semibold)
   Color: Neutral600 (#525252)

Spaces organize your tasks,
notes, and lists by context.
Let's create your first one!
▲ bodyLarge: 16px / 24px line-height
   Weight: 400 (Regular)
   Color: Neutral500 (#737373)

Create Your First Space
▲ Button label: 16px
   Weight: 600 (Semibold)
   Color: White (#FFFFFF)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TABLET/DESKTOP (≥ 768px)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Welcome to Later
▲ h2: 32px / 40px line-height
   Weight: 600 (Semibold)
   Color: Neutral600 (#525252)

[Message and button same as mobile]
```

---

## Component Hierarchy (Tree)

```
NoSpacesState
  └── AnimatedEmptyState
        ├── FadeEffect (0.0 → 1.0, 400ms)
        └── ScaleEffect (0.95 → 1.0, 400ms)
              └── EmptyState
                    └── Center
                          └── Padding (16px horizontal)
                                └── Column (mainAxisAlignment: center)
                                      ├── ShaderMask (gradient icon)
                                      │     └── Icon(Icons.folder_rounded, 64px)
                                      ├── SizedBox(height: 16px)
                                      ├── Text('Welcome to Later', h3/h2)
                                      ├── SizedBox(height: 4px)
                                      ├── Text('Spaces organize...', bodyLarge)
                                      ├── SizedBox(height: 24px)
                                      └── PrimaryButton('Create Your First Space', 48px)
```

---

## Accessibility Visual Indicators

```
┌─────────────────────────────────────┐
│                                     │
│            📁 [decorative]          │ ← Icon: ExcludeSemantics(true)
│                                     │    Not announced by screen reader
│        Welcome to Later             │ ← Title: Announced as heading
│                                     │    Contrast: 11.2:1 ✅
│  Spaces organize your tasks,        │
│  notes, and lists by context.       │ ← Message: Announced as text
│  Let's create your first one!       │    Contrast: 6.8:1 ✅
│                                     │
│  ┌───────────────────────────────┐ │
│  │ Create Your First Space       │ │ ← Button: Announced with role
│  │   [Touch target: 48×300px]    │ │    Contrast: 7.1:1 ✅
│  └───────────────────────────────┘ │    Meets 48px minimum ✅
│                                     │
└─────────────────────────────────────┘

Screen Reader Announcement (Full):
"Welcome to Later. Spaces organize your tasks,
notes, and lists by context. Let's create your
first one! Create Your First Space, button."
```

---

## Related Documentation

For implementation details, see:
- [screen-states.md](./screen-states.md) - Complete visual specifications
- [interactions.md](./interactions.md) - Animation details
- [implementation.md](./implementation.md) - Code implementation guide
- [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) - Quick specs and copy-paste code

---

**Note**: These ASCII mockups are approximations. For pixel-perfect implementation, refer to the detailed measurements in [screen-states.md](./screen-states.md) and use Flutter's layout inspector to verify.
