---
title: Later App - Complete Style Guide
description: Comprehensive design system specifications for the Later flexible organizer
version: 1.0.0
last-updated: 2025-10-18
status: approved
related-files:
  - ../design-system/tokens/colors.md
  - ../design-system/tokens/typography.md
  - ../design-system/tokens/spacing.md
  - ../design-system/tokens/animations.md
---

# Later App - Complete Style Guide

## Design Philosophy

Later embodies **bold simplicity with intuitive navigation**, creating a frictionless experience that prioritizes user needs over decorative elements. The design system balances:

- **Flexibility without chaos** - Visual organization that doesn't force rigid structures
- **Offline-first clarity** - Sync status communication without intrusion
- **Beautiful functionality** - Aesthetics that serve usability
- **Cross-platform consistency** - Unified experience across all devices
- **Progressive complexity** - Simple surface with power underneath

### Core Design Values

1. **Breathable Whitespace** - Strategic negative space for cognitive breathing room
2. **Systematic Color Theory** - Purposeful accent placement for visual hierarchy
3. **Typography Hierarchy** - Weight variance for clear information architecture
4. **Motion Choreography** - Physics-based transitions for spatial continuity
5. **Accessibility-Driven** - Universal usability built into every component

## Color System

### Primary Colors

**Primary** - Main brand color, CTAs, active states
- Light Mode: `#6366F1` (Indigo-500)
- Dark Mode: `#818CF8` (Indigo-400)
- Usage: Primary buttons, active tabs, selected items, focus indicators

**Primary Dark** - Hover states, emphasis
- Light Mode: `#4F46E5` (Indigo-600)
- Dark Mode: `#6366F1` (Indigo-500)
- Usage: Button hover states, pressed states

**Primary Light** - Subtle backgrounds, highlights
- Light Mode: `#E0E7FF` (Indigo-100)
- Dark Mode: `#312E81` (Indigo-900)
- Usage: Selected item backgrounds, hover backgrounds, badges

### Secondary Colors

**Secondary** - Supporting elements, less emphasis
- Light Mode: `#8B5CF6` (Violet-500)
- Dark Mode: `#A78BFA` (Violet-400)
- Usage: Secondary actions, decorative accents, tags

**Secondary Light** - Backgrounds, subtle accents
- Light Mode: `#EDE9FE` (Violet-100)
- Dark Mode: `#3B0764` (Violet-950)
- Usage: Section backgrounds, card backgrounds

**Secondary Pale** - Selected states, highlights
- Light Mode: `#F5F3FF` (Violet-50)
- Dark Mode: `#2E1065` (Violet-900)
- Usage: Very subtle backgrounds, hover states

### Accent Colors

**Accent Primary** - Important actions, notifications
- Light Mode: `#F59E0B` (Amber-500)
- Dark Mode: `#FCD34D` (Amber-300)
- Usage: Important notifications, quick capture button, pending sync

**Accent Secondary** - Warnings, highlights
- Light Mode: `#14B8A6` (Teal-500)
- Dark Mode: `#5EEAD4` (Teal-300)
- Usage: Success states, completed items, online status

**Gradient Start** - For gradient elements
- Light Mode: `#6366F1` (Indigo-500)
- Dark Mode: `#818CF8` (Indigo-400)

**Gradient End** - For gradient elements
- Light Mode: `#8B5CF6` (Violet-500)
- Dark Mode: `#A78BFA` (Violet-400)
- Usage: Premium features, onboarding screens, hero sections

### Semantic Colors

**Success** - Positive actions, confirmations
- Light Mode: `#10B981` (Emerald-500)
- Dark Mode: `#34D399` (Emerald-400)
- Usage: Success messages, completed states, sync complete

**Warning** - Caution states, alerts
- Light Mode: `#F59E0B` (Amber-500)
- Dark Mode: `#FBBF24` (Amber-400)
- Usage: Warning messages, sync pending, unsaved changes

**Error** - Errors, destructive actions
- Light Mode: `#EF4444` (Red-500)
- Dark Mode: `#F87171` (Red-400)
- Usage: Error messages, delete actions, sync failed

**Info** - Informational messages
- Light Mode: `#3B82F6` (Blue-500)
- Dark Mode: `#60A5FA` (Blue-400)
- Usage: Tips, informational toasts, help text

### Neutral Palette

**Light Mode Neutrals**
- `Neutral-50`: `#FAFAFA` - Backgrounds, subtle fills
- `Neutral-100`: `#F5F5F5` - Card backgrounds, hover states
- `Neutral-200`: `#E5E5E5` - Borders, dividers
- `Neutral-300`: `#D4D4D4` - Disabled borders, subtle lines
- `Neutral-400`: `#A3A3A3` - Placeholder text, icons
- `Neutral-500`: `#737373` - Secondary text, captions
- `Neutral-600`: `#525252` - Body text, labels
- `Neutral-700`: `#404040` - Primary text, headings
- `Neutral-800`: `#262626` - High emphasis text
- `Neutral-900`: `#171717` - Maximum emphasis text

**Dark Mode Neutrals**
- `Neutral-50`: `#18181B` - Background, app surface
- `Neutral-100`: `#27272A` - Card backgrounds, elevated surfaces
- `Neutral-200`: `#3F3F46` - Borders, dividers
- `Neutral-300`: `#52525B` - Disabled borders, subtle lines
- `Neutral-400`: `#71717A` - Placeholder text, icons
- `Neutral-500`: `#A1A1AA` - Secondary text, captions
- `Neutral-600`: `#D4D4D8` - Body text, labels
- `Neutral-700`: `#E4E4E7` - Primary text, headings
- `Neutral-800`: `#F4F4F5` - High emphasis text
- `Neutral-900`: `#FAFAFA` - Maximum emphasis text

### Item Type Colors

**Task Color**
- Light Mode: `#3B82F6` (Blue-500)
- Dark Mode: `#60A5FA` (Blue-400)
- Usage: Task indicators, task icons, task type badges

**Note Color**
- Light Mode: `#F59E0B` (Amber-500)
- Dark Mode: `#FBBF24` (Amber-400)
- Usage: Note indicators, note icons, note type badges

**List Color**
- Light Mode: `#8B5CF6` (Violet-500)
- Dark Mode: `#A78BFA` (Violet-400)
- Usage: List indicators, list icons, list type badges

### Accessibility Notes

- **All text/background combinations meet WCAG AA standards** (4.5:1 for normal text, 3:1 for large text)
- **Critical interactions maintain 7:1 contrast ratio** for enhanced accessibility
- **Color-blind friendly palette** verified with Coblis and Color Oracle
- **Never rely on color alone** - always pair with icons, text, or patterns

## Typography System

### Font Stack

**Primary Font Family**
```
Inter, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif
```

**Monospace Font Family**
```
'JetBrains Mono', 'Fira Code', Consolas, 'SF Mono', 'Roboto Mono', monospace
```

### Font Weights

- **Light**: 300 - Rarely used, large display text only
- **Regular**: 400 - Body text, default weight
- **Medium**: 500 - Emphasis, buttons, labels
- **Semibold**: 600 - Headings, important labels
- **Bold**: 700 - High emphasis, page titles

### Type Scale

**H1 - Page Titles**
- Size/Line Height: `32px/40px` (2rem/2.5rem)
- Weight: 700 (Bold)
- Letter Spacing: `-0.02em`
- Usage: Main page titles, space names
- Mobile: `28px/36px`

**H2 - Section Headers**
- Size/Line Height: `24px/32px` (1.5rem/2rem)
- Weight: 600 (Semibold)
- Letter Spacing: `-0.01em`
- Usage: Section titles, modal headers
- Mobile: `22px/30px`

**H3 - Subsection Headers**
- Size/Line Height: `20px/28px` (1.25rem/1.75rem)
- Weight: 600 (Semibold)
- Letter Spacing: `-0.01em`
- Usage: Card titles, subsection headers
- Mobile: `18px/26px`

**H4 - Card Titles**
- Size/Line Height: `18px/26px` (1.125rem/1.625rem)
- Weight: 600 (Semibold)
- Letter Spacing: `0`
- Usage: Item titles, settings categories
- Mobile: `16px/24px`

**H5 - Minor Headers**
- Size/Line Height: `16px/24px` (1rem/1.5rem)
- Weight: 600 (Semibold)
- Letter Spacing: `0`
- Usage: List headers, grouped items
- Mobile: `14px/22px`

**Body Large**
- Size/Line Height: `16px/24px` (1rem/1.5rem)
- Weight: 400 (Regular)
- Usage: Primary reading text, item content
- Mobile: Same

**Body**
- Size/Line Height: `14px/22px` (0.875rem/1.375rem)
- Weight: 400 (Regular)
- Usage: Standard UI text, descriptions
- Mobile: Same

**Body Small**
- Size/Line Height: `12px/18px` (0.75rem/1.125rem)
- Weight: 400 (Regular)
- Usage: Secondary information, metadata
- Mobile: Same

**Caption**
- Size/Line Height: `11px/16px` (0.6875rem/1rem)
- Weight: 400 (Regular)
- Usage: Timestamps, subtle labels, counts
- Mobile: Same

**Label**
- Size/Line Height: `12px/16px` (0.75rem/1rem)
- Weight: 500 (Medium)
- Letter Spacing: `0.03em`
- Text Transform: Uppercase
- Usage: Form labels, section labels, badges
- Mobile: Same

**Code**
- Size/Line Height: `13px/20px` (0.8125rem/1.25rem)
- Font Family: Monospace
- Usage: Code blocks, technical text, keyboard shortcuts
- Mobile: Same

### Responsive Typography

Typography scales are optimized for each breakpoint:

- **Mobile (320-767px)**: Slightly smaller headings for limited screen space
- **Tablet (768-1023px)**: Standard scale with optimized line lengths
- **Desktop (1024-1439px)**: Full scale with maximum readability
- **Wide (1440px+)**: Maintains desktop scale, increases line length limits

### Maximum Line Lengths

For optimal readability:
- **Body text**: 65-75 characters (approximately 600-700px)
- **Headings**: No hard limit, but keep concise
- **Captions**: Can extend to 80-90 characters

## Spacing & Layout System

### Base Unit

**Base Unit**: `8px` (0.5rem)

All spacing follows an 8px grid for visual consistency and mathematical harmony.

### Spacing Scale

- `xs`: 4px (0.25rem) - Micro spacing, icon gaps, tight elements
- `sm`: 8px (0.5rem) - Small spacing, internal padding, close relationships
- `md`: 16px (1rem) - Default spacing, standard margins, comfortable separation
- `lg`: 24px (1.5rem) - Medium spacing, section separation, card padding
- `xl`: 32px (2rem) - Large spacing, major sections, screen padding
- `2xl`: 48px (3rem) - Extra large spacing, hero sections, major separators
- `3xl`: 64px (4rem) - Huge spacing, onboarding screens, empty states

### Grid System

**Desktop (1024px+)**
- Columns: 12
- Gutter: 24px
- Margin: 48px (fixed) or 5% (fluid)
- Max Width: 1280px

**Tablet (768-1023px)**
- Columns: 8
- Gutter: 20px
- Margin: 32px or 4%
- Max Width: 100%

**Mobile (320-767px)**
- Columns: 4
- Gutter: 16px
- Margin: 16px or 4%
- Max Width: 100%

### Breakpoints

- **Mobile**: 320px - 767px
- **Tablet**: 768px - 1023px
- **Desktop**: 1024px - 1439px
- **Wide**: 1440px+

### Container Max Widths

- **Narrow**: 640px - Forms, single-column content
- **Standard**: 960px - Most content, list views
- **Wide**: 1280px - Dashboard layouts, multi-column
- **Full**: 100% - Edge-to-edge content

## Elevation & Shadows

### Elevation System

Later uses a subtle elevation system for depth and hierarchy:

**Level 0 - Flat** (No shadow)
- Usage: Base surfaces, backgrounds
- Shadow: None

**Level 1 - Raised** (Subtle)
- Usage: Cards, item containers, buttons
- Light Mode: `0 1px 3px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06)`
- Dark Mode: `0 1px 3px rgba(0, 0, 0, 0.3), 0 1px 2px rgba(0, 0, 0, 0.2)`

**Level 2 - Elevated** (Medium)
- Usage: Dropdown menus, popovers, floating elements
- Light Mode: `0 4px 6px rgba(0, 0, 0, 0.07), 0 2px 4px rgba(0, 0, 0, 0.05)`
- Dark Mode: `0 4px 6px rgba(0, 0, 0, 0.4), 0 2px 4px rgba(0, 0, 0, 0.3)`

**Level 3 - Floating** (Strong)
- Usage: Modals, dialogs, overlays
- Light Mode: `0 10px 15px rgba(0, 0, 0, 0.1), 0 4px 6px rgba(0, 0, 0, 0.05)`
- Dark Mode: `0 10px 15px rgba(0, 0, 0, 0.5), 0 4px 6px rgba(0, 0, 0, 0.3)`

**Level 4 - Top Layer** (Maximum)
- Usage: Quick capture modal, critical alerts, tooltips
- Light Mode: `0 20px 25px rgba(0, 0, 0, 0.1), 0 10px 10px rgba(0, 0, 0, 0.04)`
- Dark Mode: `0 20px 25px rgba(0, 0, 0, 0.6), 0 10px 10px rgba(0, 0, 0, 0.4)`

### Inner Shadows

**Inset - Depth**
- Usage: Input fields, search boxes, pressed states
- Light Mode: `inset 0 2px 4px rgba(0, 0, 0, 0.06)`
- Dark Mode: `inset 0 2px 4px rgba(0, 0, 0, 0.3)`

## Border Radius System

### Radius Scale

- `radius-xs`: 4px - Small elements, badges, tags
- `radius-sm`: 6px - Buttons, inputs, small cards
- `radius-md`: 8px - Standard cards, modals, containers
- `radius-lg`: 12px - Large cards, panels, sheets
- `radius-xl`: 16px - Hero sections, feature cards
- `radius-2xl`: 24px - Bottom sheets, large modals
- `radius-full`: 9999px - Pills, circular avatars, rounded buttons

### Usage Guidelines

- **Cards & Containers**: Use `radius-md` (8px) for consistency
- **Buttons**: Use `radius-sm` (6px) for clickable elements
- **Input Fields**: Use `radius-sm` (6px) to match buttons
- **Modals & Sheets**: Use `radius-lg` (12px) for larger surfaces
- **Badges & Tags**: Use `radius-xs` (4px) or `radius-full` for pills

## Icon System

### Icon Style

- **Style**: Outlined (stroke-based) for consistency
- **Stroke Width**: 2px for optimal clarity
- **Icon Set**: [Lucide Icons](https://lucide.dev/) or custom Flutter icons
- **License**: ISC (permissive)

### Icon Sizes

- `icon-xs`: 12px - Inline with small text, tight spaces
- `icon-sm`: 16px - Standard UI icons, buttons, lists
- `icon-md`: 20px - Emphasized icons, tabs, navigation
- `icon-lg`: 24px - Large buttons, headers, features
- `icon-xl`: 32px - Hero sections, empty states
- `icon-2xl`: 48px - Onboarding, splash, major features

### Icon Colors

Icons inherit text color by default, but can be overridden:
- **Default**: Neutral-600 (light) / Neutral-600 (dark)
- **Emphasis**: Neutral-900 (light) / Neutral-900 (dark)
- **Subtle**: Neutral-400 (light) / Neutral-400 (dark)
- **Branded**: Primary color for active/selected states

## Motion & Animation System

### Timing Functions

**Ease-Out** - `cubic-bezier(0.0, 0, 0.2, 1)`
- Usage: Entrances, expansions, modal opening
- Feel: Quick start, gentle finish

**Ease-In-Out** - `cubic-bezier(0.4, 0, 0.6, 1)`
- Usage: Transitions, movements, property changes
- Feel: Smooth acceleration and deceleration

**Ease-In** - `cubic-bezier(0.4, 0, 1, 1)`
- Usage: Exits, collapses, modal closing
- Feel: Gentle start, quick finish

**Spring** - Custom Flutter spring animation
- Tension: 300, Friction: 20
- Usage: Playful interactions, bottom sheets, pull-to-refresh
- Feel: Bouncy, natural, physics-based

### Duration Scale

- **Micro**: 100ms - State changes, hover effects, ripples
- **Short**: 200ms - Local transitions, dropdowns, tooltips
- **Medium**: 300ms - Page transitions, modals, bottom sheets
- **Long**: 400ms - Complex animations, onboarding flows
- **Extended**: 600ms - Hero transitions, dramatic effects (rare)

### Animation Principles

1. **Performance**: 60fps minimum, use transform and opacity
2. **Purpose**: Every animation serves a functional purpose
3. **Consistency**: Similar actions use similar timings
4. **Accessibility**: Respect `prefers-reduced-motion`
5. **Subtlety**: Animations should enhance, not distract

### Common Animation Patterns

**Fade In/Out**
- Duration: 200ms
- Easing: Ease-out (in) / Ease-in (out)
- Opacity: 0 to 1 (in) / 1 to 0 (out)

**Slide Up** (Bottom Sheet, Modal)
- Duration: 300ms
- Easing: Ease-out
- Transform: `translateY(100%) to translateY(0)`

**Slide Down** (Dropdown, Menu)
- Duration: 200ms
- Easing: Ease-out
- Transform: `translateY(-10px) to translateY(0)` with opacity

**Scale** (Button Press, Pop)
- Duration: 100ms
- Easing: Ease-out
- Transform: `scale(0.95)` on press, `scale(1)` on release

**Ripple** (Material touch feedback)
- Duration: 300ms
- Easing: Ease-out
- Pattern: Expanding circle from touch point

## Interaction States

All interactive elements must support these states:

### Button States

- **Default**: Base appearance
- **Hover**: Darker background, subtle scale (1.01)
- **Active/Pressed**: Even darker, scale (0.98)
- **Focus**: 2px outline in primary color, 2px offset
- **Disabled**: 40% opacity, no interaction
- **Loading**: Spinner replaces content, disabled interaction

### Input Field States

- **Default**: Neutral border, white/dark background
- **Focus**: Primary border, 0 2px 4px primary shadow
- **Error**: Red border, error message below
- **Disabled**: Neutral-100 background, subtle border
- **Success**: Green border (when applicable)

### List Item States

- **Default**: White/dark background
- **Hover**: Neutral-50/100 background
- **Selected**: Primary-light background, primary left border
- **Active**: Primary background, white text
- **Dragging**: Elevated shadow, 70% opacity

## Related Documentation

- [Color Tokens](./tokens/colors.md) - Detailed color specifications
- [Typography Tokens](./tokens/typography.md) - Complete typography system
- [Spacing Tokens](./tokens/spacing.md) - Spacing scale and grid
- [Animation Tokens](./tokens/animations.md) - Motion specifications
- [Component Library](./components/) - Reusable UI components
- [Platform Adaptations](./platform-adaptations/) - Platform-specific guidelines

---

**Last Updated**: 2025-10-18 | **Version**: 1.0.0 | **Status**: Approved
