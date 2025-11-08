---
title: No Spaces Empty State - Feature Design Overview
description: First-time user experience for when no spaces exist in the app
feature: no-spaces-empty-state
last-updated: 2025-11-07
version: 1.0.0
related-files:
  - ./user-journey.md
  - ./screen-states.md
  - ./interactions.md
  - ./accessibility.md
  - ./implementation.md
  - ../../design-system/organisms/empty_states/README.md
dependencies:
  - AnimatedEmptyState component
  - CreateSpaceModal component
  - SpacesProvider state management
status: approved
---

# No Spaces Empty State - Feature Design Overview

## Executive Summary

This feature addresses a critical gap in the first-time user experience (FTUE) where new users have **zero spaces** created in the app. Currently, the app shows a blank screen with "No Space" in the header when no spaces exist, providing no guidance or call-to-action.

This design introduces a welcoming, informative empty state that educates users about spaces and encourages them to create their first space through a clear, frictionless flow.

## Problem Statement

### Current Behavior
When a new user opens the Later app and has no spaces created (not even the default "Inbox" space), they encounter:
- **Blank screen** with no content
- **"No Space"** text in the app bar
- **No guidance** on what to do next
- **No explanation** of what a "space" is
- **Poor first impression** that may lead to user abandonment

### User Impact
- **Confusion**: Users don't understand what a "space" is or why they need one
- **Friction**: No clear path forward to start using the app
- **Abandonment risk**: Users may close the app thinking it's broken or unclear
- **Missed opportunity**: First impression should educate and excite users

## Solution Overview

### Design Strategy
Create a dedicated **NoSpacesState** empty state component that:
1. **Welcomes** the user with a friendly, encouraging message
2. **Educates** about what spaces are and why they're useful
3. **Guides** the user to create their first space with a prominent CTA
4. **Delights** with subtle animations and polished interactions
5. **Bridges** smoothly to the next step in the user journey

### Key Design Principles
- **Bold simplicity**: Clear hierarchy, single primary action
- **Educational**: Brief explanation without overwhelming
- **Encouraging**: Friendly tone that reduces friction
- **Consistent**: Follows existing empty state patterns
- **Accessible**: WCAG AA compliant, respects motion preferences

## User Goals

### Primary Goal
**Create their first space** so they can start organizing content

### Secondary Goals
- Understand what a "space" is conceptually
- Feel confident about how to use the app
- Experience smooth, delightful onboarding

## Success Metrics

### Qualitative
- Users immediately understand they need to create a space
- First-time users successfully create at least one space
- Users feel welcomed and guided (not confused or frustrated)

### Quantitative
- **Time to first space creation**: < 30 seconds from app launch
- **Space creation completion rate**: > 85% of users who see this state
- **App abandonment rate**: < 10% on first launch

## Feature Scope

### In Scope
- New `NoSpacesState` empty state component
- Integration into `home_screen.dart` logic flow
- Microcopy for title, message, and CTA
- Entrance animations and polish
- Accessibility support (screen readers, reduced motion)

### Out of Scope
- Space templates or pre-built spaces (future enhancement)
- Detailed onboarding tutorial (handled separately)
- Changes to CreateSpaceModal (use existing)
- Multi-step wizard flows

## User Journey Context

### Entry Point
User opens the Later app for the first time → `SpacesProvider.loadSpaces()` returns empty list → `spaces.length == 0` → Show `NoSpacesState`

### Exit Point
User taps "Create Your First Space" → `CreateSpaceModal` opens → User creates space → Space appears in list → Home screen shows `WelcomeState` (empty space, no content)

### State Hierarchy
```
App Launch
    ↓
No Spaces? → [NoSpacesState] (THIS FEATURE)
    ↓
Space Created → Empty Space? → [WelcomeState]
    ↓
Content Created → [EmptySpaceState] OR Content List
```

## Design Deliverables

This feature design includes:

1. **README.md** (this file) - Feature overview and context
2. **user-journey.md** - Complete user journey mapping with flows
3. **screen-states.md** - Detailed visual specifications for all states
4. **interactions.md** - Interaction patterns and animations
5. **accessibility.md** - Accessibility requirements and testing
6. **implementation.md** - Developer handoff with technical details

## Related Documentation

### Design System Components
- [AnimatedEmptyState](../../design-system/organisms/empty_states/README.md) - Base component
- [PrimaryButton](../../design-system/atoms/buttons/README.md) - CTA button
- [TemporalFlowTheme](../../design-system/tokens/README.md) - Theme system

### Similar Empty States
- [WelcomeState](../../design-system/organisms/empty_states/README.md) - First content empty state
- [EmptySpaceState](../../design-system/organisms/empty_states/README.md) - Empty space state

### State Management
- `SpacesProvider` - Manages spaces and active space selection
- `home_screen.dart` - Home screen with empty state logic

## Implementation Priority

**Priority**: P0 (Critical for FTUE)

**Rationale**: This is a blocking issue that prevents new users from understanding how to use the app. Without this empty state, users encounter a dead-end on first launch.

**Timeline**: Single sprint implementation

## Open Questions & Decisions

### Decided
- ✅ Use existing `AnimatedEmptyState` base component pattern
- ✅ Single primary CTA: "Create Your First Space"
- ✅ Brief educational message (1-2 sentences)
- ✅ Follow existing empty state visual language

### Under Consideration
- 🤔 Should we auto-create a default "Inbox" space on first launch? (Decision: No, user should intentionally create)
- 🤔 Should we offer space templates? (Decision: Future enhancement, not MVP)

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-11-07 | Initial design specification |

---

**Next Steps**: Review `user-journey.md` for complete user flow analysis and `screen-states.md` for detailed visual specifications.
