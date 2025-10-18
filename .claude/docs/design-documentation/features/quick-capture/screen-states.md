---
title: Quick Capture - Screen States
description: Complete visual specifications for all quick capture modal states
feature: quick-capture
version: 1.0.0
last-updated: 2025-10-18
status: approved
related-files:
  - ./README.md
  - ./user-journey.md
  - ../../design-system/style-guide.md
---

# Quick Capture - Screen States

## Modal Specifications

### Container Layout

**Desktop (1024px+)**:
- Width: 600px fixed
- Max height: 80vh
- Position: Center screen
- Backdrop: Neutral-900 @ 40% opacity, blur 8px

**Tablet (768-1023px)**:
- Width: 90% viewport width, max 600px
- Max height: 70vh
- Position: Center screen
- Backdrop: Same as desktop

**Mobile (320-767px)**:
- Width: 100% viewport width
- Height: Auto (from bottom)
- Position: Bottom sheet
- Border radius: 16px 16px 0 0 (top corners only)
- Backdrop: Neutral-900 @ 60% opacity

### Visual Design

**Container**:
- Background: White (light) / Neutral-100 (dark)
- Border radius: 12px (desktop/tablet), 16px 16px 0 0 (mobile)
- Shadow: Level 4 elevation
- Padding: 24px (desktop), 20px (tablet), 16px (mobile)

**Drag Handle** (Mobile only):
- Width: 40px
- Height: 4px
- Color: Neutral-300
- Position: Top center, 8px from top
- Border radius: Full (pill shape)
- Interaction: Drag down to dismiss

## State: Default (Empty)

### Layout Structure

```
┌────────────────────────────────────────┐
│  [Drag Handle] (mobile only)          │
│                                        │
│  Quick Capture                    [×]  │
│  ────────────────────────────────────  │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │ What's on your mind?             │ │
│  │ [cursor here]                    │ │
│  │                                  │ │
│  └──────────────────────────────────┘ │
│                                        │
│  [🎤]  [📷]  [Auto: Task ▼]           │
│                                        │
│  Current Space: Personal          [▼] │
│                                        │
└────────────────────────────────────────┘
```

### Visual Specifications

**Header**:
- Typography: H3 (20px/28px, Semibold 600)
- Color: Neutral-900 (light) / Neutral-900 (dark)
- Alignment: Left
- Close button: 32x32px, Neutral-600, hover Neutral-900

**Input Field**:
- Background: Neutral-50 (light) / Neutral-50 (dark)
- Border: 1px Neutral-200, focus Primary 2px
- Border radius: 8px (radius-md)
- Padding: 12px
- Min height: 120px
- Max height: 400px (scrollable after)
- Typography: Body (14px/22px, Regular 400)
- Placeholder: "What's on your mind?" (Neutral-400)

**Toolbar** (Below input):
- Layout: Horizontal row, space-between
- Gap: 12px between items
- Alignment: Items center

**Voice Button**:
- Size: 40x40dp
- Icon: Microphone (20px)
- Color: Neutral-600, hover Primary
- Background: Transparent, hover Neutral-100
- Border radius: 8px
- Touch target: 44x44dp

**Image Button**:
- Size: 40x40dp
- Icon: Image or Camera (20px)
- Color: Neutral-600, hover Primary
- Background: Transparent, hover Neutral-100
- Border radius: 8px
- Touch target: 44x44dp

**Item Type Selector**:
- Display: "Auto: Task" (example)
- Typography: Body small (12px/18px, Medium 500)
- Color: Neutral-700
- Icon: Chevron-down (16px)
- Background: Neutral-100, hover Neutral-200
- Padding: 8px 12px
- Border radius: 6px
- Dropdown: Shows Task, Note, List, Auto options

**Space Selector**:
- Display: "Current Space: Personal"
- Typography: Caption (11px/16px, Regular 400)
- Color: Neutral-600
- Icon: Chevron-down (12px)
- Background: Transparent, hover Neutral-100
- Padding: 4px 8px
- Border radius: 4px

### Interaction Specifications

**Auto-focus**:
- Input field receives focus on modal open
- Cursor positioned at start
- Keyboard immediately ready

**Keyboard Navigation**:
- Tab order: Input → Voice → Image → Type → Space → Close
- Enter: Save and close (Cmd/Ctrl+Enter for new line)
- Esc: Close modal (with confirmation if content)

**Modal Dismiss**:
- Click outside: Closes (saves content if any)
- Esc key: Closes (saves content if any)
- Drag down (mobile): Closes if dragged >40% height
- Close button: Closes (saves content if any)

## State: Typing

### Visual Changes

**Input Field**:
- Border: Primary color (2px)
- Shadow: 0 0 0 4px Primary @ 10% (focus ring)
- Background: White (light) / Neutral-50 (dark)

**Auto-Save Indicator**:
- Position: Bottom-right of modal
- Typography: Caption (11px/16px, Regular 400)
- Color: Neutral-500
- Text: "Saving..." → "Saved ✓" (transition)
- Animation: Fade in/out, 300ms

**Character Count** (if needed):
- Position: Bottom-right, above auto-save
- Typography: Caption (11px/16px, Regular 400)
- Color: Neutral-400, Warning (>500 chars), Error (>1000)
- Display: Only when >400 characters

### Smart Detection Feedback

**Item Type Auto-Update**:
- When: User types content suggesting type change
- Animation: Type selector badge updates with 200ms fade
- Example: "Auto: Task" → "Auto: Note" (if no action verbs)

**Date/Time Highlight**:
- When: Natural language date detected
- Visual: Underline with primary color (subtle)
- Tooltip: "Tomorrow, 5:00 PM" (parsed result)
- Position: Below detected text
- Duration: 2 seconds, then fades

## State: Voice Input Active

### Visual Changes

**Voice Button**:
- Background: Error color (recording red)
- Icon: Waveform animation (pulse)
- Size: Scales to 48x48dp
- Shadow: Level 2 elevation, pulsing

**Recording Indicator**:
- Position: Above input field
- Background: Error-light
- Padding: 8px 12px
- Border radius: 6px
- Typography: Body small (12px/18px, Medium 500)
- Text: "🔴 Recording... Tap to stop"
- Animation: Pulse opacity 1.0 → 0.7 → 1.0 (1s loop)

**Input Field**:
- Placeholder: "Listening..."
- Real-time transcription appears as user speaks
- Color: Primary (indicates live)

**Waveform Visualization** (Optional):
- Position: Bottom of input field
- Height: 40px
- Color: Primary gradient
- Animation: Audio reactive bars
- Bars: 20-30 vertical bars, animated by volume

### Interaction

**Tap to Stop**:
- Voice button tap: Stops recording
- Outside tap: Stops and saves
- Esc: Stops and discards

**Transcription**:
- Real-time: Text appears as spoken (if online)
- Offline: Processing indicator, then batch insert
- Error: "Couldn't transcribe" with retry button

## State: Image Attached

### Visual Changes

**Image Thumbnail**:
- Position: Above input field, below header
- Size: 120px × 80px (3:2 aspect ratio maintained)
- Border radius: 8px
- Border: 1px Neutral-200
- Shadow: Level 1 elevation

**Remove Button**:
- Position: Top-right corner of thumbnail
- Size: 24x24dp (16x16dp icon)
- Background: Neutral-900 @ 80%, backdrop blur
- Icon: X (white)
- Border radius: Full (circle)
- Hover: Error background

**Image Counter** (Multiple):
- Position: Bottom-right of first thumbnail
- Display: "+2 more" (if >1 image)
- Background: Primary @ 90%
- Typography: Caption (11px/16px, Medium 500)
- Color: White
- Padding: 4px 8px
- Border radius: 4px

**Layout Adjustment**:
- Input field moves below thumbnail(s)
- Modal height expands (up to max)
- Scroll: If content exceeds max height

## State: Dropdown Menus Open

### Item Type Selector Dropdown

**Container**:
- Width: 200px
- Position: Below type selector button
- Background: White (light) / Neutral-100 (dark)
- Border: 1px Neutral-200
- Border radius: 8px
- Shadow: Level 2 elevation
- Padding: 4px

**Menu Items**:
- Height: 36px each
- Padding: 8px 12px
- Border radius: 4px
- Hover: Neutral-100 background
- Selected: Primary-light background, primary text

**Options**:
1. Auto (Smart detection) - Icon: Wand
2. Task - Icon: Check-square, Blue accent
3. Note - Icon: File-text, Amber accent
4. List - Icon: List, Violet accent

**Item Layout**:
```
[Icon 16px]  Type Name          [Selected ✓]
```

### Space Selector Dropdown

**Container**:
- Width: 280px
- Position: Below space selector button
- Background: White (light) / Neutral-100 (dark)
- Border: 1px Neutral-200
- Border radius: 8px
- Shadow: Level 2 elevation
- Padding: 4px

**Search Input** (if >5 spaces):
- Height: 36px
- Padding: 8px 12px
- Border: 1px Neutral-200
- Border radius: 6px
- Icon: Search (16px)
- Placeholder: "Search spaces..."

**Space List**:
- Max height: 240px (scrollable)
- Padding: 4px

**Space Item**:
- Height: 40px
- Padding: 8px 12px
- Border radius: 4px
- Hover: Neutral-100 background
- Selected: Primary-light background

**Item Layout**:
```
[Color Dot 8px]  Space Name       [Item Count]
                 Last updated
```

## State: Loading (Rare)

### When Shown

- Large file upload in progress
- Voice transcription processing (offline)
- Network request pending (online features)

### Visual Specifications

**Progress Indicator**:
- Type: Linear progress bar (determinate if possible)
- Position: Top of modal (just below header)
- Height: 2px
- Color: Primary gradient
- Animation: Indeterminate slide (if percentage unknown)

**Loading Overlay** (Heavy operations only):
- Background: White @ 80% (light) / Neutral-100 @ 80% (dark)
- Backdrop filter: Blur 4px
- Spinner: 32px, Primary color, center positioned
- Text: "Processing..." (below spinner)

### Interaction

**User Actions**:
- Input: Still functional
- Buttons: Disabled during loading
- Cancel: X button available to cancel operation

## State: Error

### Visual Specifications

**Error Message Container**:
- Position: Below input field, above toolbar
- Background: Error-light
- Border: 1px Error (left: 4px)
- Border radius: 6px
- Padding: 12px
- Margin: 8px 0

**Error Icon**:
- Icon: Alert-triangle (20px)
- Color: Error
- Position: Left aligned with message

**Error Text**:
- Typography: Body small (12px/18px, Medium 500)
- Color: Error (dark variant for readability)
- Max lines: 3

**Retry Action** (if applicable):
- Display: "Try again" link
- Color: Error
- Underline: On hover
- Position: Below error message

### Error Types

**Network Error**:
- Message: "No internet connection. Item saved locally and will sync when online."
- Icon: Wifi-off
- Color: Warning (not error - not user's fault)

**Voice Error**:
- Message: "Couldn't transcribe audio. Please try typing or try again."
- Action: "Retry" button

**File Upload Error**:
- Message: "File too large (max 10MB). Please choose a smaller file."
- Action: "Choose another file"

**Validation Error**:
- Message: "Please add some content before saving."
- Icon: Alert-circle
- Focus: Returns to input field

## State: Success/Saved

### Visual Specifications

**Success Indicator**:
- Position: Bottom-right corner
- Display: Checkmark icon + "Saved"
- Background: Success color
- Typography: Caption (11px/16px, Medium 500)
- Color: White
- Padding: 6px 12px
- Border radius: 16px (pill)
- Shadow: Level 1 elevation

**Animation**:
- Entry: Slide up + fade in (200ms ease-out)
- Duration: Display for 1500ms
- Exit: Fade out (300ms ease-in)

**Automatic Dismiss**:
- When: 500ms after success indicator appears
- Animation: Modal slides down (mobile) or fades out (desktop)
- Duration: 300ms ease-in-out

## Responsive Adaptations

### Mobile (320-767px)

**Bottom Sheet Behavior**:
- Swipe down: Dismisses (with spring animation)
- Over-scroll: Rubber band effect at top
- Keyboard: Pushes modal up, maintains visible input

**Toolbar Adjustments**:
- Space selector: Moves to separate row if space constrained
- Icons: Slightly smaller (18px vs 20px)

### Tablet (768-1023px)

**Standard Desktop Layout**:
- No significant differences from desktop
- May use bottom sheet on iPad in portrait if preferred

### Desktop (1024px+)

**Keyboard Shortcuts Visible**:
- Hint text: "Press Esc to close" (subtle, in footer)
- Shortcut badges: "⌘+Enter to save"

**Hover States**:
- All interactive elements show hover feedback
- Cursor changes appropriately

## Accessibility Specifications

### Screen Reader Announcements

**On Open**:
- "Quick capture dialog opened. Text input focused."

**On Type Change**:
- "Item type changed to Task"

**On Save**:
- "Item saved successfully"

**On Error**:
- "Error: [error message]"

### Keyboard Navigation

**Focus Ring**:
- Width: 2px
- Color: Primary
- Offset: 2px
- Style: Solid

**Tab Order**:
1. Input field (auto-focused)
2. Voice button
3. Image button
4. Type selector
5. Space selector
6. Close button

**Shortcuts**:
- `Cmd/Ctrl+Enter`: Save and close
- `Cmd/Ctrl+Shift+V`: Voice input
- `Cmd/Ctrl+Shift+I`: Image upload
- `Esc`: Close modal

### Touch Accessibility

**Minimum Targets**:
- All buttons: 44x44dp minimum
- Drag handle: 44px wide × 32px tall (mobile)
- Close button: 44x44dp

**Haptic Feedback**:
- Voice start: Light impact
- Voice stop: Medium impact
- Save: Success haptic
- Error: Warning haptic

## Animation Specifications

### Modal Entry

**Desktop/Tablet**:
- Animation: Scale 0.9 → 1.0 + fade 0 → 1
- Duration: 300ms
- Easing: Ease-out
- Backdrop: Fade in 200ms

**Mobile (Bottom Sheet)**:
- Animation: Slide up from bottom (translateY 100% → 0)
- Duration: 300ms
- Easing: Spring (tension 300, friction 20)
- Backdrop: Fade in 200ms

### Modal Exit

**Desktop/Tablet**:
- Animation: Scale 1.0 → 0.9 + fade 1 → 0
- Duration: 200ms
- Easing: Ease-in

**Mobile**:
- Animation: Slide down (translateY 0 → 100%)
- Duration: 250ms
- Easing: Ease-in-out

### Interactive Feedback

**Button Press**:
- Scale: 0.95
- Duration: 100ms
- Easing: Ease-out

**Input Focus**:
- Border color: Transition 150ms
- Shadow: Fade in 150ms

## Related Documentation

- [Quick Capture Overview](./README.md) - Feature requirements
- [User Journey](./user-journey.md) - Complete user flow
- [Implementation Guide](./implementation.md) - Developer handoff
- [Style Guide](../../design-system/style-guide.md) - Design system

---

**Last Updated**: 2025-10-18 | **Version**: 1.0.0 | **Status**: Approved
