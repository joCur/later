---
title: No Spaces Empty State - User Journey Analysis
description: Complete user journey mapping for the no spaces empty state
feature: no-spaces-empty-state
last-updated: 2025-11-07
version: 1.0.0
related-files:
  - ./README.md
  - ./screen-states.md
  - ./interactions.md
status: approved
---

# No Spaces Empty State - User Journey Analysis

## 1. User Experience Analysis

### Primary User Goal
**What the user wants to accomplish**: Understand how to start using the Later app and create their first organizational space to begin capturing content.

### Success Criteria
- User understands what a "space" is conceptually
- User successfully creates their first space
- User experiences smooth transition to next step (adding content)
- User feels welcomed and confident, not confused or frustrated

### Key Pain Points Addressed

#### Current Pain Points
1. **Confusion**: No explanation when app is empty
2. **Blocked**: No clear path forward from blank screen
3. **Disorientation**: "No Space" text is cryptic and unhelpful
4. **Poor first impression**: App appears broken or incomplete

#### How This Design Solves Them
1. **Clear explanation**: "Spaces organize your tasks, notes, and lists by context"
2. **Obvious action**: Large, prominent "Create Your First Space" button
3. **Welcoming tone**: Friendly microcopy that encourages action
4. **Polished experience**: Smooth animations and professional design

### User Personas

#### Primary Persona: First-Time User (New to Later)
- **Context**: Just downloaded the app or completed authentication
- **Mental Model**: Familiar with productivity apps (Notion, Todoist, Apple Notes)
- **Expectations**: Should be able to start organizing immediately
- **Pain Points**: Needs to understand app structure before creating content
- **Needs**: Clear guidance, education about "spaces" concept

#### Secondary Persona: Returning User (Lost All Spaces)
- **Context**: Deleted all spaces or data reset
- **Mental Model**: Already understands spaces concept
- **Expectations**: Quick path to recreate organizational structure
- **Pain Points**: Wants to move fast, not re-learn basics
- **Needs**: Fast-track to space creation

## 2. Information Architecture

### Content Hierarchy

#### Primary Elements (Top → Bottom)
1. **Icon** (64px) - Visual anchor, friendly welcome
2. **Title** - "Welcome to Later" - Establishes context
3. **Message** - Brief explanation of spaces concept
4. **Primary CTA** - "Create Your First Space" - Clear action

#### Visual Hierarchy Strategy
- **Icon**: Gradient-tinted, draws eye first
- **Title**: Largest text, establishes context
- **Message**: Secondary text, educates briefly
- **CTA Button**: Gradient-filled, stands out as clear action

### Navigation Structure

#### Entry Points
1. **App Launch** → Authentication complete → No spaces exist
2. **Space Deletion** → User deletes last remaining space
3. **Data Reset** → User clears app data or reinstalls

#### Exit Points
1. **Primary**: Tap CTA → CreateSpaceModal → Space created → WelcomeState
2. **Secondary**: Press back/close app (edge case)

### Mental Model Alignment

#### User's Conceptual Model
"I need to create containers/folders before I can add content"

#### App's Implementation Model
Spaces → Content (Notes, TodoLists, Lists)

#### Alignment Strategy
- Use familiar language: "organize" (not "structure")
- Reference known concepts: "tasks, notes, and lists" (not "content types")
- Visual metaphor: Folder/box icon suggests containment

## 3. User Journey Mapping

### Core Experience Flow

#### Step 1: Entry Point - App Launch (No Spaces)

**Trigger**: User opens app, `SpacesProvider.loadSpaces()` returns empty list

**State Description**:
- **Layout**: Centered empty state, vertically and horizontally centered
- **Visual Elements**:
  - Gradient-tinted folder/box icon (64px on mobile, 80-100px on tablet)
  - Title: "Welcome to Later"
  - Message: "Spaces organize your tasks, notes, and lists by context. Let's create your first one!"
  - Primary button: "Create Your First Space"
- **Information Density**: Minimal, focused on single action
- **Key Elements**: Icon, title, message, CTA button

**Available Actions**:
- **Primary**: Tap "Create Your First Space" button
- **Secondary**: None (intentionally single-path)

**Visual Hierarchy**:
1. Icon draws attention first (gradient shimmer)
2. Title establishes context
3. Message educates briefly
4. CTA button invites action (gradient fill, prominent)

**System Feedback**:
- **On Load**: Fade-in + scale entrance animation (400ms)
- **FAB**: No FAB pulse (not applicable here)
- **Accessibility**: Screen reader announces "Welcome to Later. Spaces organize..."

#### Step 2: Primary Action - Create First Space

**Task Flow**:
1. User reads empty state content (3-5 seconds)
2. User taps "Create Your First Space" button
3. Button shows press state (scale 0.96, 120ms)
4. `CreateSpaceModal` opens with bottom sheet slide-up animation (250ms)
5. User fills in space details (name, icon, color)
6. User taps "Create" in modal
7. Space is saved to Supabase via `SpacesProvider.createSpace()`
8. Modal dismisses with slide-down animation (120ms)
9. Home screen updates to show new space

**State Changes**:
- Button press: Scale 0.96, light haptic feedback
- Modal enter: Slide up from bottom + fade backdrop
- Loading: Button shows loading spinner if save takes >200ms
- Success: Modal dismisses, home screen refreshes

**Error Prevention**:
- Modal validates space name (required, 1-100 chars)
- Duplicate names allowed (spaces have unique IDs)
- Network errors show error message in modal

**Progressive Disclosure**:
- Empty state: Simple message, single action
- Modal: Full space creation form (name, icon, color)
- Post-creation: Next empty state (WelcomeState for empty space)

**Microcopy**:
- **Button label**: "Create Your First Space" (encouraging, action-oriented)
- **Button on hover/press**: Visual feedback only (no text change)
- **Error states**: Handled by CreateSpaceModal (not in empty state)

#### Step 3: Completion - Transition to WelcomeState

**Success State**:
- Space created successfully
- `SpacesProvider` updates with new space
- Home screen rebuilds with `spaces.length > 0`
- Logic now shows `WelcomeState` (empty space, no content yet)

**Visual Confirmation**:
- Empty state fades out (120ms)
- New space appears in space switcher dropdown
- `WelcomeState` fades in with "Your Inbox is empty" message
- FAB pulse animation begins (guiding user to add first content)

**Next Steps**:
- User sees `WelcomeState` with "Create your first item" CTA
- User can tap FAB or CTA to create first piece of content
- User journey continues to content creation flow

**Exit Options**:
- Natural progression: Continue to content creation
- Alternative: Switch spaces, explore settings, etc.

### Advanced Users & Edge Cases

#### Edge Case 1: Network Error During Space Creation

**Scenario**: User taps CTA, modal opens, user creates space, but network fails

**Handling**:
- Error occurs in `CreateSpaceModal`, not empty state
- Modal shows error message: "Could not create space. Check your connection."
- User can retry or cancel
- Empty state remains visible behind modal
- No change to empty state component itself

**Recovery Path**:
- User fixes network issue
- User retries space creation
- Success flow continues normally

#### Edge Case 2: User Closes App Immediately

**Scenario**: User sees empty state, doesn't interact, closes app

**Handling**:
- Empty state entrance animation completes normally
- No destructive actions taken
- Next app launch shows same empty state
- User journey resumes from same point

**Expected Behavior**:
- App should be resilient to abandonment
- No data loss or corruption
- Graceful handling of immediate exit

#### Edge Case 3: User Deletes Last Space

**Scenario**: Existing user deletes their last remaining space

**Handling**:
- `SpacesProvider` updates, `spaces.length == 0`
- Home screen rebuilds
- Shows `NoSpacesState` (this component)
- **Difference from first-time user**: User already knows what spaces are

**UX Consideration**:
- Message is still helpful: "Spaces organize your tasks..."
- But experienced users can skip reading and go straight to CTA
- Same visual design works for both first-time and returning users

#### Edge Case 4: Very Small Screens (320px width)

**Scenario**: User on iPhone SE (1st gen) or similar small device

**Responsive Adaptations**:
- Icon size: 64px (not larger)
- Typography: Mobile scale (h3, not h2)
- Padding: 16px horizontal (AppSpacing.md)
- Button: Full width or comfortable width within margins
- Vertical spacing: Reduced to fit in viewport without scrolling

**Testing Requirements**:
- Must fit in 320×568px viewport (iPhone SE)
- No scrolling required to see CTA
- All touch targets meet 48px minimum

#### Edge Case 5: Reduced Motion Preferences

**Scenario**: User has enabled "Reduce Motion" in system accessibility settings

**Adaptive Behavior**:
- Skip entrance animations (fade, scale, slide)
- Show content immediately on load
- Button press: Instant state change (no animation)
- Modal: Instant appear (no slide-up)
- Haptic feedback: Still provided (unaffected by motion preference)

**Implementation**:
- `AnimatedEmptyState` checks `MediaQuery.of(context).disableAnimations`
- Conditionally applies animations only if motion is allowed
- Ensures accessibility compliance

#### Power User Shortcuts

**Consideration**: No keyboard shortcuts or advanced options

**Rationale**:
- This is a first-time user experience
- Single, clear path reduces cognitive load
- Advanced features come later in user journey
- Mobile-first design (no keyboard expected)

**Future Enhancement**:
- Could add "Skip" or "Import spaces" for advanced users
- Not necessary for MVP

## 4. Screen-by-Screen Specifications

### Screen: Home Screen (No Spaces State)

**Purpose**: Welcome first-time users and guide them to create their first space

**Layout Structure**:
- **Container**: Full screen height, centered content
- **Grid System**: 4 columns on mobile, 8 on tablet, 12 on desktop
- **Responsive**: Single-column centered layout on all breakpoints
- **Spacing**: 16px horizontal padding on mobile, 24px on tablet

**Content Strategy**:
- **Information Prioritization**: Most important → least important
  1. "I need to do something" (CTA button)
  2. "What do I need to do?" (Title)
  3. "Why do I need to do it?" (Message)
  4. "What is this thing?" (Icon as visual cue)
- **Content Organization**: Vertical stack, centered alignment
- **Reading Flow**: Top to bottom, single column (natural F-pattern not needed)

## 5. Quality Assurance Checklist

### User Experience Validation
- ✅ User goal clearly supported: Create first space
- ✅ Navigation intuitive: Single obvious action (CTA button)
- ✅ Error states provide clear guidance: Handled by modal
- ✅ Loading states communicate progress: Button loading spinner
- ✅ Empty state guides toward productive action: Yes, explicit CTA
- ✅ Success state provides clear confirmation: Transition to WelcomeState

### Interaction Flow Validation
- ✅ All entry points identified: App launch, last space deletion
- ✅ All exit points identified: Space created, app closed
- ✅ Edge cases documented: Network errors, small screens, reduced motion
- ✅ State transitions clear: Empty state → Modal → WelcomeState
- ✅ Error recovery paths defined: Retry in modal, cancel returns to empty state
- ✅ Loading states defined: Button loading spinner in modal

### Content & Microcopy Validation
- ✅ Title concise and welcoming: "Welcome to Later"
- ✅ Message educates without overwhelming: 1-2 sentences max
- ✅ CTA clear and action-oriented: "Create Your First Space"
- ✅ Tone friendly and encouraging: Yes, "Let's create your first one!"
- ✅ Language accessible: Avoids jargon, uses familiar terms

## Related Documentation

- [Screen States](./screen-states.md) - Detailed visual specifications
- [Interactions](./interactions.md) - Animation and interaction details
- [Accessibility](./accessibility.md) - WCAG compliance and testing
- [Implementation](./implementation.md) - Developer handoff guide

---

**Next Steps**: Review `screen-states.md` for detailed visual specifications of each state.
