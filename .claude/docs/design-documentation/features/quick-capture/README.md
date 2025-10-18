---
title: Quick Capture Feature
description: Fast item creation with minimal friction for tasks, notes, and lists
feature: quick-capture
version: 1.0.0
last-updated: 2025-10-18
status: approved
priority: P0
related-files:
  - ./user-journey.md
  - ./screen-states.md
  - ./implementation.md
  - ../../design-system/components/buttons.md
dependencies:
  - unified-item-management
  - offline-first-architecture
---

# Quick Capture Feature

## Feature Overview

Quick Capture enables users to create tasks, notes, or lists with minimal friction, optimized for speed and clarity. It's the primary entry point for new content, designed to never interrupt the user's flow.

**Design Philosophy**: Less than 3 seconds from intent to captured. No decisions required, just capture and move on.

## User Story

**As a** busy user with a fleeting thought
**I want to** quickly capture ideas, tasks, or notes without friction
**So that I can** return to what I'm doing without losing my train of thought

## Success Criteria

- Item creation in <3 seconds from trigger to save
- Zero mandatory fields beyond content
- Works perfectly offline
- Auto-saves without user action
- Smart detection of item type from content
- Accessible via floating button, keyboard shortcut, or share sheet

## Key User Personas

### Sarah Chen - Power User
**Need**: Keyboard shortcut, instant capture during calls/meetings
**Pain Point**: Context switching interrupts focus
**Solution**: Global keyboard shortcut (Cmd/Ctrl+Shift+N), stays in background

### Marcus Thompson - Student
**Need**: Quick note capture during lectures
**Pain Point**: Slow typing on mobile, needs voice input
**Solution**: Voice input support, auto-transcription

### Elena Rodriguez - Creative
**Need**: Visual capture, image notes
**Pain Point**: Ideas are often visual
**Solution**: Image paste/upload, drag and drop support

### David Park - Parent
**Need**: Ultra-fast task capture while juggling
**Pain Point**: No time to categorize or organize
**Solution**: Smart defaults, natural language processing for due dates

## Core Functionality

### Trigger Methods

1. **Floating Action Button (FAB)**
   - Position: Bottom-right corner (mobile/tablet), always visible
   - Size: 56x56dp (touch target: 64x64dp)
   - Color: Accent-primary (amber gradient)
   - Icon: Plus (+), white, 24px
   - Behavior: Opens quick capture modal

2. **Keyboard Shortcut**
   - Primary: `Cmd/Ctrl + N` (new item)
   - Alternative: `Cmd/Ctrl + Shift + Space` (global)
   - Behavior: Opens quick capture modal, focus on input

3. **Share Sheet** (Mobile)
   - Intent: Share text/images to Later
   - Behavior: Opens quick capture with pre-filled content

4. **Widget** (Mobile Home Screen)
   - Tap: Opens quick capture
   - Voice: Long-press for voice input

### Input Methods

1. **Text Input**
   - Primary: Type content directly
   - Auto-focus: Cursor ready immediately
   - Multi-line: Expands as user types
   - Max initial: 3 lines, expandable

2. **Voice Input**
   - Trigger: Microphone button
   - Behavior: Real-time transcription
   - Languages: User's system language
   - Offline: Basic transcription, full when online

3. **Image/File**
   - Drag and drop: Desktop
   - Photo capture: Mobile camera
   - Photo library: Mobile picker
   - Paste: Clipboard images

4. **Natural Language**
   - Parsing: "Buy milk tomorrow at 5pm"
   - Extraction: Due date, time, tags
   - Fallback: Plain text if parsing fails

### Smart Detection

**Item Type Auto-Detection**:
- **Task**: Contains action verbs (buy, call, send), dates, times
- **Note**: Longer text, paragraphs, no dates
- **List**: Multiple bullets, numbered items, "list" keyword

**Examples**:
- "Buy milk tomorrow" → Task with due date tomorrow
- "Meeting notes: discussed project timeline..." → Note
- "Shopping list:\n- Milk\n- Eggs\n- Bread" → List with 3 items

### Auto-Save Behavior

**When**:
- 500ms after user stops typing (debounced)
- On modal close/dismiss
- On navigation away
- On app background

**Where**:
- Local database first (offline-first)
- Sync queue if online
- Never blocks user interaction

**Visual Feedback**:
- Subtle checkmark icon (300ms display)
- "Saved" text (fades after 1s)
- No intrusive confirmation required

## Acceptance Criteria

### Must Have (P0)
- [ ] Opens in <200ms from trigger
- [ ] Auto-focuses input field
- [ ] Works perfectly offline
- [ ] Auto-saves without user action
- [ ] Dismissible via Esc, back button, or outside tap
- [ ] Keyboard shortcut support (desktop)
- [ ] Floating action button (mobile)

### Should Have (P1)
- [ ] Natural language date parsing
- [ ] Voice input support
- [ ] Smart item type detection
- [ ] Image/file attachment
- [ ] Recent items suggestion

### Could Have (P2)
- [ ] Templates quick-insert
- [ ] Location tagging
- [ ] Reminder setting
- [ ] Collaboration mention (@user)

## Design Principles

### Speed Above All
- No loading states
- Instant modal open
- No mandatory fields
- One-tap capture

### Smart Defaults
- Current space selected
- Item type auto-detected
- Today's date assumed
- No priority/tags required

### Forgiving Input
- Any text format accepted
- Parsing failures graceful
- Manual override always available
- Undo support

### Clear Feedback
- Auto-save indication
- Parsing results shown
- Error messages helpful
- Success confirmation subtle

## Accessibility Requirements

- Screen reader: Announces "Quick capture, text input"
- Keyboard navigation: Full support, logical tab order
- Touch targets: 48x48dp minimum
- Color contrast: WCAG AA compliance
- Voice input: Alternative to typing
- Reduced motion: Respect user preference

## Performance Targets

- **Modal open**: <200ms
- **Input response**: <16ms (60fps)
- **Auto-save**: <100ms (local)
- **Voice transcription**: <500ms (online), <2s (offline)
- **Image upload**: Progressive, background

## Technical Constraints

- Works offline completely
- No server dependency for basic capture
- Local database write <100ms
- Memory footprint <10MB
- Battery impact minimal

## Related Documentation

- [User Journey](./user-journey.md) - Complete user flow analysis
- [Screen States](./screen-states.md) - Visual specifications
- [Implementation Guide](./implementation.md) - Developer handoff
- [Buttons Component](../../design-system/components/buttons.md) - FAB specifications

---

**Last Updated**: 2025-10-18 | **Version**: 1.0.0 | **Status**: Approved | **Priority**: P0
