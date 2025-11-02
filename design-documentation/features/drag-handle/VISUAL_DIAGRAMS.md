---
title: Drag Handle Visual Diagrams
description: ASCII diagrams and visual references for implementing the drag handle
feature: drag-handle-reordering
last-updated: 2025-11-02
version: 1.0.0
status: reference
---

# Drag Handle Visual Diagrams

> Visual reference guide with ASCII diagrams to clarify positioning, sizing, and layout

---

## Complete Card Layout with Handle

### Overview Diagram
```
┌────────────────────────────────────────────────────────────┐
│  Card Container (20px border radius, 6px gradient border) │
│  ┌──────────────────────────────────────────────────────┐ │
│  │  Card Interior (20px padding all sides)             │ │
│  │                                                      │ │
│  │  ┌──────┐  ┌─────────────────────────────┐  ┌────┐ │ │
│  │  │      │  │                             │  │ :: │ │ │
│  │  │ Icon │  │  Content Area               │  │ :: │ │ │
│  │  │ 48px │  │  (Expandable)               │  │ :: │ │ │
│  │  │      │  │                             │  │48px│ │ │
│  │  └──────┘  └─────────────────────────────┘  └────┘ │ │
│  │     ↑            ↑                              ↑   │ │
│  │   Icon      Content Area                   Handle   │ │
│  │  (48×48)      (Flexible)                  (48×48)   │ │
│  │                                                      │ │
│  └──────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────┘

Horizontal Spacing:
│←20px→│←48px→│←8px→│←Flexible→│←48px→│←20px→│
Card    Icon    Gap   Content     Handle   Card
Padding                            Touch    Padding
                                   Target
```

---

## Touch Target Dimensions

### Handle Touch Target (48×48px)
```
          48px
    ┌──────────────┐
    │              │
    │   ┌──────┐   │ ← 20×24px visible icon (centered)
48px│   │ :: : │   │
    │   │ :: : │   │
    │   │ :: : │   │
    │   └──────┘   │
    │              │
    └──────────────┘

Touch Target: 48×48px (transparent container)
Visible Icon: 20×24px (grip dots)
Padding: 14px horizontal, 12px vertical (centering)
```

### Grip Dots Detail (20×24px)
```
     20px
  ┌────────┐
  │● ●     │ ← Row 1: Two 4px dots, 4px apart
  │  ↕ 6px │ ← Vertical spacing between rows
24│● ●     │ ← Row 2: Two 4px dots, 4px apart
px│  ↕ 6px │ ← Vertical spacing between rows
  │● ●     │ ← Row 3: Two 4px dots, 4px apart
  └────────┘

Single Dot:
┌──┐
│●│  4×4px with 2px border radius
└──┘
```

---

## Card Content Row Layout

### TodoListCard Example
```
┌─────────────────────────────────────────────────────────────┐
│ Card (GradientPillBorder: 6px border, 20px radius)         │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Container (padding: 20px all sides)                     │ │
│ │                                                         │ │
│ │ Row (CrossAxisAlignment.start)                          │ │
│ │ ┌────────┬────┬──────────────────────┬──────────────┐  │ │
│ │ │        │    │                      │              │  │ │
│ │ │ ┌───┐  │ 8px│  Column (Expanded)   │  ┌────────┐  │  │ │
│ │ │ │ ☐ │  │    │  ┌─────────────────┐ │  │  ●  ●  │  │  │
│ │ │ │   │  │    │  │ Title (18px B)  │ │  │        │  │  │
│ │ │ │48 │  │    │  │ "Weekly Plan"   │ │  │  ●  ●  │  │  │
│ │ │ │×  │  │    │  └─────────────────┘ │  │   48px │  │  │
│ │ │ │48 │  │    │  ┌─────────────────┐ │  │  ●  ●  │  │  │
│ │ │ │px │  │    │  │ Progress (15px) │ │  │        │  │  │
│ │ │ │   │  │    │  │ "4 of 7 done"   │ │  └────────┘  │  │
│ │ │ │   │  │    │  └─────────────────┘ │  Drag Handle │  │
│ │ │ └───┘  │    │  ┌─────────────────┐ │              │  │
│ │ │ Icon   │    │  │ Progress Bar    │ │              │  │
│ │ │        │    │  └─────────────────┘ │              │  │
│ │ └────────┴────┴──────────────────────┴──────────────┘  │ │
│ │                                                         │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

Horizontal Flow: Icon → 8px gap → Content (flexible) → Handle
Vertical Alignment: CrossAxisAlignment.start (top-aligned)
```

### NoteCard Example
```
┌─────────────────────────────────────────────────────────────┐
│ Card (GradientPillBorder: 6px border, 20px radius)         │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Container (padding: 20px all sides)                     │ │
│ │                                                         │ │
│ │ Row (CrossAxisAlignment.start)                          │ │
│ │ ┌────────┬────┬──────────────────────┬──────────────┐  │ │
│ │ │        │    │                      │              │  │ │
│ │ │ ┌───┐  │ 8px│  Column (Expanded)   │  ┌────────┐  │  │
│ │ │ │ 📄 │  │    │  ┌─────────────────┐ │  │  ●  ●  │  │  │
│ │ │ │   │  │    │  │ Title (18px B)  │ │  │        │  │  │
│ │ │ │48 │  │    │  │ "Meeting Notes" │ │  │  ●  ●  │  │  │
│ │ │ │×  │  │    │  └─────────────────┘ │  │   48px │  │  │
│ │ │ │48 │  │    │  ┌─────────────────┐ │  │  ●  ●  │  │  │
│ │ │ │px │  │    │  │ Content (15px)  │ │  │        │  │  │
│ │ │ │   │  │    │  │ "Discussed..."  │ │  └────────┘  │  │
│ │ │ │   │  │    │  └─────────────────┘ │  Drag Handle │  │
│ │ │ └───┘  │    │  ┌─────────────────┐ │              │  │
│ │ │ Icon   │    │  │ Tags            │ │              │  │
│ │ │        │    │  └─────────────────┘ │              │  │
│ │ └────────┴────┴──────────────────────┴──────────────┘  │ │
│ │                                                         │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

Horizontal Flow: Icon → 8px gap → Content (flexible) → Handle
Vertical Alignment: CrossAxisAlignment.start (top-aligned)
```

---

## State Transition Diagrams

### Opacity States
```
Default State (40% opacity)
┌────┐
│ ●● │ ← Subtle presence, visible but non-intrusive
│ ●● │
│ ●● │
└────┘

       ↓ Mouse Enter (Desktop/Web)

Hover State (60% opacity)
┌────┐
│ ●● │ ← Emphasized presence, ready to interact
│ ●● │   Cursor: grab (open hand)
│ ●● │
└────┘

       ↓ Drag Start

Active State (100% opacity)
┌────┐
│ ●● │ ← Full intensity, maximum visibility
│ ●● │   Scale: 1.05, Cursor: grabbing (closed fist)
│ ●● │   Haptic: Light impact
└────┘

       ↓ Drag End / Cancel

Back to Default State (40% opacity)
```

### Scale Animation During Drag
```
Default (Scale 1.0):
┌────────┐
│  ●  ●  │
│  ●  ●  │ ← Normal size
│  ●  ●  │
└────────┘

       ↓ 100ms ease-out animation

Active (Scale 1.05):
┌─────────┐
│   ●  ●  │
│   ●  ●  │ ← Slightly enlarged (lift effect)
│   ●  ●  │
└─────────┘

       ↓ 200ms ease-out-back animation

Default (Scale 1.0):
┌────────┐
│  ●  ●  │
│  ●  ●  │ ← Returns to normal with slight overshoot
│  ●  ●  │
└────────┘
```

---

## Gradient Application

### Gradient Direction (Diagonal)
```
┌─────────────────┐
│ Start Color     │ ← Top-left: Gradient start
│   ╲             │
│     ╲           │   TaskGradient: Red (#EF4444) → Orange (#F97316)
│       ╲         │   NoteGradient: Blue (#3B82F6) → Cyan (#06B6D4)
│         ╲       │   ListGradient: Violet (#8B5CF6) → Lavender (#A78BFA)
│           ╲     │
│             ╲   │
│     End Color   │ ← Bottom-right: Gradient end
└─────────────────┘

LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [startColor, endColor],
)
```

### Gradient on Grip Dots
```
Individual Dot with Gradient:

┌──┐  ← Top-left: Start color
│●│  ← Gradient fills entire dot
└──┘  ← Bottom-right: End color

Full Handle (6 dots):

●[gradient] ●[gradient]  ← Row 1
●[gradient] ●[gradient]  ← Row 2
●[gradient] ●[gradient]  ← Row 3

Each dot is independently filled with the same gradient
Result: Cohesive gradient appearance across all dots
```

---

## Focus Indicator (Keyboard Navigation)

### Default (No Focus)
```
┌────────┐
│  ●  ●  │
│  ●  ●  │ ← No outline
│  ●  ●  │
└────────┘
```

### Focused (Via Keyboard)
```
╔════════╗ ← 2px solid border, focus color
║  ●  ●  ║   Light: Blue-500 (#3B82F6)
║  ●  ●  ║   Dark: Violet-100 (#EDE9FE)
║  ●  ●  ║   Contrast: 4.5:1+ against background
╚════════╝   Border radius: 4px

BoxDecoration(
  border: Border.all(color: focusColor, width: 2),
  borderRadius: BorderRadius.circular(4),
)
```

---

## Gesture Recognition Zones

### Card with Gesture Zones
```
┌─────────────────────────────────────────────────────────────┐
│ Card Gesture Zone (Card Tap → Open Detail)                 │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ ┌───────┐  ┌──────────────────────────┐  ┌───────────┐ │ │
│ │ │       │  │                          │  │           │ │ │
│ │ │ Icon  │  │   Content Tap Zone       │  │   HANDLE  │ │ │
│ │ │       │  │   → Opens card detail    │  │   ZONE    │ │ │
│ │ │       │  │                          │  │  → DRAG   │ │ │
│ │ │       │  │                          │  │           │ │ │
│ │ └───────┘  └──────────────────────────┘  └───────────┘ │ │
│ │    ↑                  ↑                        ↑        │ │
│ │  Passes            Passes                 Intercepts    │ │
│ │  through           through                gesture       │ │
│ │  to card           to card                arena         │ │
│ │                                                         │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

Gesture Priority:
1. HIGH: Drag Handle (48×48px) → Starts drag, prevents card tap
2. MEDIUM: Card Content → Opens card detail
3. LOW: Scroll/Pull-to-Refresh → System gestures (when outside handle)
```

---

## Responsive Layout (Different Screen Sizes)

### Mobile (320px - 767px)
```
Card Width: ~90% of screen width (e.g., 320px - 32px margins = 288px)

┌────────────────────────────────────────────┐
│ Card (288px width)                         │
│ ┌────────────────────────────────────────┐ │
│ │ [Icon 48px] [Content ~180px] [Handle] │ │
│ │             (flexible)         48px    │ │
│ └────────────────────────────────────────┘ │
└────────────────────────────────────────────┘

Icon: 48px (fixed)
Gap: 8px (fixed)
Content: ~180px (flexible, based on available space)
Handle: 48px (fixed)
Padding: 20px each side (fixed)

Total: 20 + 48 + 8 + 180 + 48 + 20 = 324px (fits 320px with some flex)
```

### Tablet (768px - 1023px)
```
Card Width: ~700px (centered with margins)

┌──────────────────────────────────────────────────────────────┐
│ Card (700px width)                                           │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ [Icon 48px] [Content ~556px] [Handle 48px]              │ │
│ │             (flexible, more space)                       │ │
│ └──────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘

Icon: 48px (fixed)
Gap: 8px (fixed)
Content: ~556px (flexible, more room for content)
Handle: 48px (fixed)
Padding: 20px each side (fixed)
```

### Desktop (1024px+)
```
Card Width: ~800px (max-width, centered)

┌────────────────────────────────────────────────────────────────────┐
│ Card (800px width, max)                                            │
│ ┌────────────────────────────────────────────────────────────────┐ │
│ │ [Icon 48px] [Content ~656px] [Handle 48px]                    │ │
│ │             (flexible, plenty of space)                        │ │
│ │             Hover state: Cursor changes to 'grab'              │ │
│ └────────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────┘

Icon: 48px (fixed)
Gap: 8px (fixed)
Content: ~656px (flexible, maximum readability)
Handle: 48px (fixed)
Padding: 20px each side (fixed)
Hover: Enabled (60% opacity on mouse enter)
```

---

## Animation Timing Diagrams

### Opacity Transition Timeline
```
Timeline: 0ms ────────────────────── 150ms
Opacity:  0.4 ──────────────────────→ 0.6  (Default → Hover)
          [          Ease-out curve         ]

Timeline: 0ms ────────────────────── 150ms
Opacity:  0.6 ──────────────────────→ 1.0  (Hover → Active)
          [          Ease-out curve         ]

Timeline: 0ms ────────────────────── 200ms
Opacity:  1.0 ──────────────────────→ 0.4  (Active → Default)
          [       Ease-out curve (slower)   ]
```

### Scale Transition Timeline
```
Timeline: 0ms ─────────── 100ms
Scale:    1.0 ──────────→ 1.05  (Default → Active)
          [   Ease-out    ]

Timeline: 0ms ──────────────── 200ms
Scale:    1.05 ─────────────→ 1.0  (Active → Default)
          [ Ease-out-back (overshoot) ]
                            ↗↘ Slight bounce effect
```

### Full Drag Cycle
```
0ms:      User touches handle (Default: opacity 0.4, scale 1.0)
          ↓
10ms:     System detects touch, starts transition
          ↓
50ms:     Opacity ramping up, scale starting
          ↓
100ms:    Active state reached (opacity 1.0, scale 1.05)
          │ Haptic feedback fires
          │ User is dragging...
          ↓
[Drag in progress - user moves card up/down]
          ↓
500ms:    User releases (drag ends)
          ↓
510ms:    Opacity starts fading, scale starts shrinking
          ↓
650ms:    Scale passes through 1.0 (slight overshoot to 0.98)
          ↓
710ms:    Back to Default (opacity 0.4, scale 1.0)
          └──→ Drag complete, haptic confirmation
```

---

## Dark Mode Comparison

### Light Mode
```
Background: White (#FFFFFF)
Handle (40%): Red-Orange gradient at 40% opacity
              ┌────┐
              │ ●● │ ← Subtle, visible
              │ ●● │   Contrast: 2.8:1+
              │ ●● │
              └────┘

Focus Indicator: Blue-500 (#3B82F6) - 2px border
Card Shadow: 4px offset, 8px blur, 12% black
```

### Dark Mode
```
Background: Neutral-900 (#0F172A)
Handle (40%): Red-Orange gradient at 40% opacity
              ┌────┐
              │ ●● │ ← Softer, less saturated
              │ ●● │   Contrast: 2.9:1+
              │ ●● │
              └────┘

Focus Indicator: Violet-100 (#EDE9FE) - 2px border
Card Shadow: 4px offset, 8px blur, 12% black (same)
```

**Note**: Theme-adaptive gradients automatically adjust saturation for dark mode comfort.

---

## Implementation Tree Diagram

```
DragHandleWidget (Root Widget)
├── MouseRegion (Desktop hover detection)
│   ├── cursor: grab / grabbing
│   ├── onEnter: Set _isHovered = true
│   └── onExit: Set _isHovered = false
│
├── Semantics (Accessibility)
│   ├── button: true
│   ├── enabled: true/false
│   ├── label: "Drag to reorder [item]"
│   └── hint: "Use arrow keys..."
│
├── AnimatedOpacity (State transition)
│   ├── duration: 150ms
│   ├── opacity: 0.4 / 0.6 / 1.0
│   └── curve: Curves.easeOut
│
├── AnimatedScale (Drag feedback)
│   ├── duration: 150ms
│   ├── scale: 1.0 / 1.05
│   └── curve: Curves.easeOut / easeOutBack
│
├── Container (Touch target)
│   ├── width: 48px
│   ├── height: 48px
│   ├── alignment: Alignment.center
│   │
│   └── SizedBox (Icon container)
│       ├── width: 20px
│       ├── height: 24px
│       │
│       └── Column (Grip dots layout)
│           ├── mainAxisSize: MainAxisSize.min
│           │
│           ├── Row (Dot row 1)
│           │   ├── Container (Dot 1) - 4×4px, gradient
│           │   ├── SizedBox (Gap) - 4px
│           │   └── Container (Dot 2) - 4×4px, gradient
│           │
│           ├── SizedBox (Vertical gap) - 6px
│           │
│           ├── Row (Dot row 2)
│           │   ├── Container (Dot 1) - 4×4px, gradient
│           │   ├── SizedBox (Gap) - 4px
│           │   └── Container (Dot 2) - 4×4px, gradient
│           │
│           ├── SizedBox (Vertical gap) - 6px
│           │
│           └── Row (Dot row 3)
│               ├── Container (Dot 1) - 4×4px, gradient
│               ├── SizedBox (Gap) - 4px
│               └── Container (Dot 2) - 4×4px, gradient
│
└── Optional: FocusNode (Keyboard navigation)
    ├── onKeyEvent: Handle arrow keys
    └── Focus indicator: 2px border when focused
```

---

## Spacing Calculation Examples

### Example 1: Mobile Card (320px screen)
```
Screen width: 320px
Screen margins: 16px each side (total 32px)
Available width: 320 - 32 = 288px

Card content width: 288px
├── Card padding left: 20px
├── Icon width: 48px
├── Icon-content gap: 8px
├── Content width: 288 - 20 - 48 - 8 - 48 - 20 = 144px
├── Handle width: 48px
└── Card padding right: 20px
Total: 288px ✓

Content area: 144px (flexible)
- Title: 18px font, 2 lines max
- Spacing: 4-8px between elements
- Content preview: 15px font, 2 lines max
- Tags/metadata: 12px font
```

### Example 2: Desktop Card (800px max-width)
```
Card max-width: 800px

Card content width: 800px
├── Card padding left: 20px
├── Icon width: 48px
├── Icon-content gap: 8px
├── Content width: 800 - 20 - 48 - 8 - 48 - 20 = 656px
├── Handle width: 48px
└── Card padding right: 20px
Total: 800px ✓

Content area: 656px (flexible, plenty of space)
- Title: 18px font, 2 lines max
- Spacing: 4-8px between elements
- Content preview: 15px font, 2 lines max (more content visible)
- Tags/metadata: 12px font (more tags visible)
```

---

## Complete Integration Diagram

```
HomeScreen (ReorderableListView)
│
├─ buildDefaultDragHandles: false (IMPORTANT!)
│
├─ itemBuilder: (context, index) {
│   │
│   └─ returns: Card Component (TodoListCard, NoteCard, ListCard)
│       │
│       ├── key: ValueKey('item-${item.id}')
│       │
│       ├── GestureDetector (Card tap)
│       │   └── onTap: Open detail screen
│       │
│       ├── Container (Card container)
│       │   ├── margin: 0 0 16px 0 (bottom only)
│       │   │
│       │   └── GradientPillBorder (6px border, gradient)
│       │       │
│       │       └── Container (Card interior)
│       │           ├── padding: 20px (all sides)
│       │           │
│       │           └── Row (Content row)
│       │               ├── _buildLeadingIcon() → 48×48px
│       │               ├── SizedBox(width: 8px)
│       │               ├── Expanded(_buildContent())
│       │               │
│       │               └── ReorderableDragStartListener ← WRAP HANDLE ONLY
│       │                   ├── key: ValueKey('handle-${id}')
│       │                   ├── index: widget.index
│       │                   │
│       │                   └── DragHandleWidget
│       │                       ├── gradient: type-specific
│       │                       ├── isActive: _isDragging
│       │                       ├── enabled: widget.enableReordering
│       │                       └── semanticLabel: 'Drag to reorder...'
│       │
│       └── Press/Drag state management
│           ├── _isPressed (for card tap feedback)
│           └── _isDragging (for handle drag state)
│
└─ onReorder: (oldIndex, newIndex) {
    ├── Validate indices
    ├── Call ContentProvider.reorderContent()
    ├── Haptic feedback (medium impact)
    └── Update UI
}
```

---

## End of Visual Diagrams

**For implementation details, see**:
- `implementation-guide.md` - Code examples and setup
- `visual-specifications.md` - Detailed measurements and colors
- `interaction-specifications.md` - State transitions and animations
- `QUICK_REFERENCE.md` - One-page cheat sheet

---

**Last Updated**: 2025-11-02 | **Version**: 1.0.0
