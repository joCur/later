# Later App - Design System Summary

**Version**: 1.0.0
**Last Updated**: 2025-10-18
**Status**: Approved for Development

## Quick Links

- **Complete Documentation**: [design-documentation/README.md](./design-documentation/README.md)
- **Style Guide**: [design-documentation/design-system/style-guide.md](./design-documentation/design-system/style-guide.md)
- **Design Tokens**: [design-documentation/assets/design-tokens.json](./design-documentation/assets/design-tokens.json)
- **Flutter Guide**: [design-documentation/design-system/platform-adaptations/flutter.md](./design-documentation/design-system/platform-adaptations/flutter.md)

---

## Design Philosophy

Later embodies **"works how you think"** - a flexible organizer that combines tasks, notes, and lists without forcing rigid workflows. The design balances:

- **Bold simplicity** with intuitive navigation
- **Offline-first clarity** without intrusive indicators
- **Beautiful aesthetics** serving functionality
- **Cross-platform consistency** with platform respect
- **Progressive disclosure** of advanced features

---

## Visual Identity

### Color Palette

**Primary (Indigo)**: Brand color, CTAs, active states
- Light: `#6366F1` | Dark: `#818CF8`

**Secondary (Violet)**: Supporting elements, accents
- Light: `#8B5CF6` | Dark: `#A78BFA`

**Accent Primary (Amber)**: Quick capture, notifications
- Light: `#F59E0B` | Dark: `#FCD34D`

**Item Type Colors**:
- Task (Blue): `#3B82F6` / `#60A5FA`
- Note (Amber): `#F59E0B` / `#FBBF24`
- List (Violet): `#8B5CF6` / `#A78BFA`

**Semantic**:
- Success: `#10B981` / `#34D399`
- Warning: `#F59E0B` / `#FBBF24`
- Error: `#EF4444` / `#F87171`
- Info: `#3B82F6` / `#60A5FA`

### Typography

**Font Family**: Inter, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, sans-serif

**Type Scale**:
- H1: 32px/40px, Bold 700 - Page titles
- H2: 24px/32px, Semibold 600 - Section headers
- H3: 20px/28px, Semibold 600 - Subsections
- H4: 18px/26px, Semibold 600 - Card titles
- Body: 14px/22px, Regular 400 - Standard UI
- Caption: 11px/16px, Regular 400 - Metadata

### Spacing

**8px Base Unit System**:
- xs: 4px - Micro spacing
- sm: 8px - Small spacing
- md: 16px - Default spacing
- lg: 24px - Section spacing
- xl: 32px - Large spacing
- 2xl: 48px - Major separators
- 3xl: 64px - Hero sections

### Elevation

**Shadow System**:
- Level 0: Flat surfaces
- Level 1: Cards, buttons (subtle)
- Level 2: Dropdowns, popovers
- Level 3: Modals, dialogs
- Level 4: Quick capture (top layer)

---

## Key Screen Layouts

### Main Workspace View (Mobile)

```
┌──────────────────────────────────────┐
│  ☰  Personal ▼         🔍    •••     │ Top Bar
├──────────────────────────────────────┤
│  Filters: [All] [Tasks] [Notes]      │ Filter Bar
│           [Lists]                    │
├──────────────────────────────────────┤
│                                      │
│  ┌────────────────────────────────┐ │
│  │║ [☐] Buy groceries            │ │ Task Card
│  │║ Milk, eggs, bread            │ │ (Blue border)
│  │║ 📍Personal  🕐 Today, 5pm     │ │
│  └────────────────────────────────┘ │
│                                      │
│  ┌────────────────────────────────┐ │
│  │║ [📄] Meeting notes           │ │ Note Card
│  │║ Discussed Q2 roadmap...      │ │ (Amber border)
│  │║ 📍Work  🕐 Mar 15             │ │
│  └────────────────────────────────┘ │
│                                      │
│  ┌────────────────────────────────┐ │
│  │║ [☰] Packing list             │ │ List Card
│  │║ • Passport                   │ │ (Violet border)
│  │║ • Charger                    │ │
│  │║ • Sunglasses                 │ │
│  │║ 📍Personal  3/10 items        │ │
│  └────────────────────────────────┘ │
│                                      │
│                                      │
│                                  [+] │ FAB (Amber)
└──────────────────────────────────────┘
│  [🏠] [🔍] [📁] [⚙️]                 │ Bottom Nav
└──────────────────────────────────────┘
```

### Quick Capture Modal (Mobile)

```
┌──────────────────────────────────────┐
│        Backdrop (dimmed)             │
│                                      │
│  ┌────────────────────────────────┐ │
│  │         ────                   │ │ Drag Handle
│  │                                │ │
│  │  Quick Capture            [×]  │ │ Header
│  │  ──────────────────────────────│ │
│  │                                │ │
│  │  ┌──────────────────────────┐ │ │
│  │  │ What's on your mind?     │ │ │ Input Field
│  │  │ [cursor here]            │ │ │
│  │  │                          │ │ │
│  │  │                          │ │ │
│  │  └──────────────────────────┘ │ │
│  │                                │ │
│  │  [🎤] [📷]  [Auto: Task ▼]    │ │ Toolbar
│  │                                │ │
│  │  Current Space: Personal  [▼]  │ │ Space Selector
│  │                                │ │
│  └────────────────────────────────┘ │
└──────────────────────────────────────┘
```

### Desktop Workspace View

```
┌──────────────────────────────────────────────────────────────────────┐
│  Later                    🔍 Search...           [Sync ✓] [⚙️] [👤]  │ Top Bar
├────────────┬─────────────────────────────────────────────────────────┤
│            │  Personal ▼    [All] [Tasks] [Notes] [Lists]    [+ New]│ Content Header
│            ├─────────────────────────────────────────────────────────┤
│  Spaces    │                                                          │
│  ────────  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐  │
│            │  │║[☐] Buy groc │ │║[📄] Meeting  │ │║[☰] Packing  │  │
│  📍 Personal│  │║ Milk, eggs  │ │║ Discussed Q2│ │║ • Passport  │  │
│  💼 Work    │  │║             │ │║ roadmap...  │ │║ • Charger   │  │
│  🏃 Fitness │  │║ Today, 5pm  │ │║ Mar 15      │ │║ 3/10 items  │  │
│  📚 Reading │  │║             │ │║             │ │║             │  │
│            │  └──────────────┘ └──────────────┘ └──────────────┘  │
│  + New     │                                                          │
│   Space    │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐  │
│            │  │║[☐] Call dent│ │║[📄] Project  │ │║[☰] Shopping │  │
│            │  │║             │ │║ ideas...    │ │║ • Milk      │  │
│            │  │║ Mar 20, 3pm │ │║             │ │║ • Eggs      │  │
│  Settings  │  │║             │ │║ Yesterday   │ │║ 8/12 items  │  │
│  ────────  │  └──────────────┘ └──────────────┘ └──────────────┘  │
│            │                                                          │
│  🌓 Theme   │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐  │
│  🔄 Sync    │  │║[☐] Read book│ │║[📄] Recipe   │ │║[☰] Todo list│  │
│  ⚙️ General │  │║             │ │║ Ingredients:│ │║ • Fix bug   │  │
│            │  │║ No date     │ │║ • Flour...  │ │║ • Review PR │  │
│            │  └──────────────┘ └──────────────┘ └──────────────┘  │
│            │                                                          │
└────────────┴─────────────────────────────────────────────────────────┘
```

### Space Switcher (Mobile)

```
┌──────────────────────────────────────┐
│  Switch Space                   [×]  │
├──────────────────────────────────────┤
│  🔍 Search spaces...                 │
├──────────────────────────────────────┤
│                                      │
│  📍 Personal              23 items   │ Selected
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │ (primary bg)
│                                      │
│  💼 Work                  15 items   │
│  ────────────────────────────────    │
│                                      │
│  🏃 Fitness               8 items    │
│  ────────────────────────────────    │
│                                      │
│  📚 Reading               12 items   │
│  ────────────────────────────────    │
│                                      │
│  🎨 Projects              5 items    │
│  ────────────────────────────────    │
│                                      │
├──────────────────────────────────────┤
│  + Create New Space                  │
└──────────────────────────────────────┘
```

### Item Detail View (Mobile)

```
┌──────────────────────────────────────┐
│  ←  Item Details              •••    │ Header
├──────────────────────────────────────┤
│                                      │
│  [Task Badge]                        │ Type indicator
│                                      │
│  Buy groceries                       │ Title (editable)
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                      │
│  Don't forget:                       │
│  - Milk (2%)                         │ Content
│  - Eggs (dozen)                      │ (editable)
│  - Bread                             │
│                                      │
│                                      │
│  ──────────────────────────────────  │
│                                      │
│  Space                               │
│  📍 Personal                     [▼] │ Space selector
│                                      │
│  Due Date                            │
│  📅 Today, 5:00 PM              [▼] │ Date picker
│                                      │
│  Priority                            │
│  ⚠️ High                         [▼] │ Priority selector
│                                      │
│  Tags                                │
│  [groceries] [weekly] [+]            │ Tags
│                                      │
│  ──────────────────────────────────  │
│                                      │
│  Created: Mar 15, 2025 at 10:30 AM   │ Metadata
│  Modified: Mar 18, 2025 at 2:15 PM   │
│                                      │
└──────────────────────────────────────┘
```

---

## Component Library

### Item Cards

**Three Variants**: Task, Note, List

**Common Structure**:
- 4px left border (type color)
- Leading element (checkbox/icon)
- Title (H4, 1-2 lines)
- Content preview (2-3 lines)
- Metadata row (space, tags, date)
- Action menu (three dots)

**States**: Default, Hover, Selected, Pressed, Completed, Dragging

**Responsive**:
- Mobile: 12px padding, 2-line preview
- Desktop: 16px padding, 3-line preview

### Buttons

**Variants**:
- Primary: Solid primary color, white text
- Secondary: Outline, primary color
- Ghost: Transparent, primary text
- Danger: Solid error color, white text

**Sizes**:
- Small: 32px height, 12px padding
- Medium: 40px height, 16px padding
- Large: 48px height, 20px padding

**States**: Default, Hover, Active, Focus, Disabled, Loading

### Floating Action Button (FAB)

**Specifications**:
- Size: 56x56dp visual, 64x64dp touch
- Color: Accent-primary (amber gradient)
- Icon: Plus (+), white, 24px
- Position: Bottom-right, 16px margin
- Shadow: Level 3 elevation
- Animation: Scale 0.95 on press

### Input Fields

**Default Specifications**:
- Height: 40px (medium), 48px (large)
- Padding: 12px horizontal
- Border: 1px Neutral-200
- Border radius: 6px
- Font: Body (14px/22px)

**States**:
- Default: Neutral border
- Focus: Primary border (2px), shadow ring
- Error: Error border, message below
- Disabled: Neutral-100 background
- Success: Success border (rare)

### Navigation

**Bottom Navigation Bar** (Mobile):
- Height: 56px + safe area
- Items: 3-5 max
- Active: Primary color, filled icon
- Inactive: Neutral-600, outlined icon

**Sidebar** (Desktop):
- Width: 240px (collapsed: 72px)
- Background: Neutral-50 (light) / Neutral-100 (dark)
- Items: Icon + label, hover highlight
- Scrollable if many spaces

---

## Interaction Patterns

### Gestures (Mobile)

**Swipe Right** (Tasks): Toggle completion
- Threshold: 30% width
- Visual: Teal background, checkmark

**Swipe Left**: Delete
- Threshold: 50% width
- Visual: Red background, trash icon

**Long Press**: Multi-select mode
- Duration: 500ms
- Haptic: Medium impact

**Pull to Refresh**: Sync/reload
- Threshold: 100px
- Visual: Spinner

### Keyboard Shortcuts (Desktop)

**Global**:
- `Cmd/Ctrl+N`: New item
- `Cmd/Ctrl+F`: Search
- `Cmd/Ctrl+K`: Command palette
- `Cmd/Ctrl+,`: Settings

**Item Operations**:
- `Enter`: Open
- `Space`: Toggle checkbox
- `e`: Edit
- `d`: Duplicate
- `Delete`: Delete (confirm)

**Navigation**:
- `j/k` or `↓/↑`: Next/previous
- `Esc`: Close/cancel
- `Tab`: Next focus
- `1-9`: Switch space

---

## Animation System

### Durations

- Micro: 100ms - Hover, state changes
- Short: 200ms - Dropdowns, tooltips
- Medium: 300ms - Modals, transitions
- Long: 400ms - Complex animations

### Easing

- Ease-out: `cubic-bezier(0.0, 0, 0.2, 1)` - Entrances
- Ease-in-out: `cubic-bezier(0.4, 0, 0.6, 1)` - Transitions
- Ease-in: `cubic-bezier(0.4, 0, 1, 1)` - Exits
- Spring: Tension 300, Friction 20 - Playful interactions

### Common Patterns

**Modal Entry** (Desktop):
- Scale 0.9 → 1.0 + Fade 0 → 1
- Duration: 300ms, Ease-out

**Bottom Sheet** (Mobile):
- Slide up from bottom (translateY 100% → 0)
- Duration: 300ms, Spring easing

**Button Press**:
- Scale 0.95
- Duration: 100ms, Ease-out

---

## Accessibility Standards

### WCAG 2.1 Level AA Compliance

**Color Contrast**:
- Normal text: 4.5:1 minimum
- Large text: 3:1 minimum
- UI components: 3:1 minimum

**Keyboard Navigation**:
- All features accessible via keyboard
- Visible focus indicators (2px primary, 2px offset)
- Logical tab order
- No keyboard traps

**Screen Reader Support**:
- Semantic HTML/proper widgets
- ARIA labels and roles
- Landmark regions
- Dynamic content announcements

**Touch Targets**:
- Minimum: 44x44dp for all interactive elements
- Spacing: 8px minimum between targets

**Motion**:
- Respect `prefers-reduced-motion`
- All animations stoppable
- No flashing (>3 times/second)

---

## Offline-First Architecture

### Core Principles

1. **Local First**: All data stored locally before sync
2. **Always Functional**: Full feature set offline
3. **Clear Status**: Subtle sync indicators
4. **Background Sync**: Non-blocking, opportunistic
5. **Conflict Resolution**: Last-write-wins with merge support

### Sync Status Indicators

**Synced**: Subtle checkmark, "Last synced: 2 min ago"
**Syncing**: Animated spinner, "Syncing..."
**Pending**: Queue icon, "3 items pending sync"
**Error**: Alert icon, "Sync failed. Tap to retry"
**Offline**: Cloud-off icon, "Offline. Changes will sync when online"

### Visual Treatment

- Never block UI for sync
- Indicators in header (subtle)
- Item-level indicators only on errors
- Toast notifications for important events

---

## Performance Targets

- **App Launch**: <2s to interactive
- **Space Switch**: <200ms
- **Search**: <50ms response
- **Item Render**: <16ms (60fps)
- **Scroll**: Smooth 60fps
- **Auto-save**: <100ms (local)

---

## Responsive Breakpoints

- **Mobile**: 320px - 767px
- **Tablet**: 768px - 1023px
- **Desktop**: 1024px - 1439px
- **Wide**: 1440px+

### Adaptive Layouts

**Mobile**:
- Single column
- Bottom navigation
- Full-screen modals
- Swipe gestures

**Tablet**:
- 2-column grid
- Side or bottom navigation
- Modal dialogs
- Mixed touch/mouse

**Desktop**:
- 3-column grid
- Persistent sidebar
- Keyboard-first
- Hover interactions

---

## Flutter Implementation

### Theme Setup

```dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: Color(0xFF6366F1),
    secondary: Color(0xFF8B5CF6),
    error: Color(0xFFEF4444),
    // ...
  ),
  textTheme: AppTypography.textTheme,
  // ...
)
```

### Responsive Helper

```dart
Breakpoints.isMobile(context)
Breakpoints.isTablet(context)
Breakpoints.isDesktop(context)
```

### Design Tokens

All tokens available in JSON format:
`design-documentation/assets/design-tokens.json`

---

## File Structure Summary

```
design-documentation/
├── README.md                           # Project overview
├── design-system/
│   ├── style-guide.md                 # Complete design system
│   ├── components/
│   │   └── item-cards.md              # Item card specs
│   ├── tokens/
│   │   └── colors.md                  # Color palette
│   └── platform-adaptations/
│       └── flutter.md                 # Flutter guidance
├── features/
│   ├── unified-item-management/
│   │   └── README.md                  # Feature specs
│   └── quick-capture/
│       ├── README.md                  # Feature overview
│       └── screen-states.md           # Visual specs
├── accessibility/
│   └── guidelines.md                  # Accessibility standards
└── assets/
    └── design-tokens.json             # Exportable tokens
```

---

## Next Steps for Developers

1. **Review** complete documentation in `design-documentation/`
2. **Import** design tokens from `design-tokens.json`
3. **Implement** theme system using Flutter guide
4. **Build** components following specifications
5. **Test** accessibility with screen readers
6. **Validate** performance targets

---

## Questions Addressed

### How do we visually distinguish tasks, notes, and lists?

**Answer**: Subtle 4px left border in item type color (Blue/Amber/Violet), paired with icon (checkbox/note/list) and optional badge. Color is decorative only - icons and labels ensure accessibility.

### What's the best way to show offline/sync status?

**Answer**: Subtle header indicator showing sync status. Never blocks UI. Item-level indicators only for errors. Toast notifications for important events. Philosophy: "It just works" - don't make users think about sync.

### How do we make space switching fast?

**Answer**:
- Mobile: Bottom nav space icon → full-screen picker with search
- Desktop: Sidebar with keyboard shortcuts (1-9 for first 9 spaces)
- Both: <200ms transition target, predictive prefetch

### What's the ideal quick capture UX?

**Answer**:
- Trigger: FAB (mobile), Cmd/Ctrl+N (desktop), share sheet
- Modal: Auto-focused input, smart type detection, auto-save
- Goal: <3 seconds from thought to captured
- Philosophy: No mandatory fields, zero friction

### How do we balance flexibility with preventing overwhelm?

**Answer**:
- **Progressive disclosure**: Simple surface (just cards), power underneath (filters, bulk ops, keyboard shortcuts)
- **Smart defaults**: Auto-detect type, current space selected, no required fields
- **Visual calm**: Consistent card format, breathable spacing, subtle accents
- **Guided paths**: Empty states with clear CTAs, onboarding for key features

---

**For detailed specifications, always refer to the complete documentation in the `design-documentation/` directory.**

**Last Updated**: 2025-10-18 | **Version**: 1.0.0 | **Status**: Approved
