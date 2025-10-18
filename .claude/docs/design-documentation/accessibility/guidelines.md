---
title: Accessibility Guidelines
description: WCAG 2.1 AA compliance standards and accessibility requirements for Later app
version: 1.0.0
last-updated: 2025-10-18
status: approved
related-files:
  - ./testing.md
  - ./compliance.md
  - ../design-system/style-guide.md
---

# Accessibility Guidelines

## Overview

Later is committed to providing an accessible experience for all users, meeting WCAG 2.1 Level AA standards minimum, with AAA compliance for critical user journeys.

**Accessibility Commitment**: Every feature must be fully usable by people with diverse abilities, using various assistive technologies.

## Core Principles

### 1. Perceivable
Information and UI components must be presentable to users in ways they can perceive.

### 2. Operable
UI components and navigation must be operable by all users.

### 3. Understandable
Information and UI operation must be understandable.

### 4. Robust
Content must be robust enough to be interpreted by a wide variety of user agents, including assistive technologies.

## Color & Visual Contrast

### Contrast Ratios (WCAG 2.1)

**Level AA Requirements**:
- Normal text (14-18px): 4.5:1 minimum
- Large text (18px+ or 14px+ bold): 3:1 minimum
- UI components and graphics: 3:1 minimum

**Level AAA Requirements** (for critical elements):
- Normal text: 7:1 minimum
- Large text: 4.5:1 minimum

### Later's Contrast Commitments

**Primary Text**:
- Neutral-900 on White (light): 21:1 (AAA ✓✓✓)
- Neutral-900 on Neutral-50 (dark): 13.8:1 (AAA ✓✓✓)

**Secondary Text**:
- Neutral-600 on White (light): 7.3:1 (AAA ✓✓✓)
- Neutral-600 on Neutral-100 (dark): 5.2:1 (AAA ✓✓✓)

**Interactive Elements**:
- Primary on White: 4.6:1 (AA ✓)
- Primary on Primary-light: 3.2:1 (large text only)

**UI Components**:
- Borders, icons, controls: 3:1 minimum (AA ✓)

### Color Independence

**Never rely on color alone**:
- Use icons with color
- Use text labels with color indicators
- Use patterns or textures for data visualization
- Provide text alternatives

**Example - Item Types**:
```
❌ Bad: Only blue border for tasks
✓ Good: Blue border + checkbox icon + "Task" label
```

### Color Blindness Considerations

**Protanopia/Deuteranopia (Red-Green)**:
- Don't use red/green as only distinction
- Success (green) and error (red) always paired with icons
- Item type colors (blue/amber/violet) are distinguishable

**Tritanopia (Blue-Yellow)**:
- Primary (blue) and warning (amber) distinguishable
- High contrast between all semantic colors

**Testing Tools**:
- Coblis Color Blindness Simulator
- Color Oracle (desktop)
- Chrome DevTools vision deficiency emulation

## Typography & Readability

### Font Sizes

**Minimum Sizes**:
- Body text: 14px (0.875rem) minimum
- UI labels: 12px (0.75rem) minimum
- Captions: 11px (0.6875rem) absolute minimum

**User Scaling**:
- Support browser/OS text scaling up to 200%
- Layout must not break with scaled text
- No horizontal scrolling at 200% zoom

### Line Height

**Readability Standards**:
- Body text: 1.5 (150%) minimum
- Headings: 1.2-1.3 (120-130%)
- Tight spacing: 1.375 (137.5%) minimum for UI

### Line Length

**Optimal Reading**:
- Body text: 50-75 characters per line
- Maximum: 90 characters
- Responsive: Adjust for viewport

### Font Weight

**Sufficient Contrast**:
- Regular (400) or higher for body text
- Medium (500) or higher for small text (12px)
- Avoid light weights (300) for text under 18px

## Keyboard Navigation

### Focus Management

**Visible Focus Indicators**:
- Width: 2px minimum
- Color: Primary (high contrast with background)
- Offset: 2px (prevents clipping)
- Style: Solid outline
- Never remove focus outline without replacement

**Focus Order**:
- Logical reading order (left-to-right, top-to-bottom)
- Tab order follows visual order
- Skip links for main content
- Focus trap in modals/dialogs

### Keyboard Shortcuts

**Global Shortcuts**:
- `Cmd/Ctrl + N`: New item (quick capture)
- `Cmd/Ctrl + K`: Search
- `Cmd/Ctrl + ,`: Settings
- `Cmd/Ctrl + /`: Show shortcuts help

**Navigation**:
- `Tab`: Next focusable element
- `Shift+Tab`: Previous focusable element
- `Enter`: Activate button/link
- `Space`: Toggle checkbox, activate button
- `Esc`: Close modal/dialog, cancel action
- `Arrow keys`: Navigate lists, menus

**Item Management**:
- `e`: Edit selected item
- `Delete/Backspace`: Delete selected item (with confirmation)
- `Cmd/Ctrl + D`: Duplicate item
- `c`: Mark task complete/incomplete

**Modifier Guidelines**:
- Use `Cmd` on macOS, `Ctrl` on Windows/Linux
- Avoid overriding browser shortcuts
- Provide visual hints for shortcuts

### Keyboard Traps

**Avoid Traps**:
- Users must be able to navigate away from any component
- Modals: Esc to close, Tab cycles through modal elements
- Infinite carousels: Provide skip button

**Intentional Traps** (in modals):
- Focus remains within modal until dismissed
- Tab cycles: last element → first element
- Shift+Tab cycles backwards

## Screen Reader Support

### Semantic HTML

**Use Proper Elements**:
- `<button>` for buttons, not `<div onclick>`
- `<a>` for links, not `<span onclick>`
- `<input type="checkbox">` for checkboxes
- `<nav>`, `<main>`, `<aside>` for structure

### ARIA Labels & Roles

**Landmark Roles**:
```html
<header role="banner">
<nav role="navigation" aria-label="Main navigation">
<main role="main">
<aside role="complementary">
<footer role="contentinfo">
```

**Widget Roles**:
```html
<div role="dialog" aria-modal="true" aria-labelledby="dialog-title">
<button role="button" aria-pressed="false">
<div role="tablist">
  <button role="tab" aria-selected="true">
```

**Dynamic Content**:
```html
<!-- Live regions for updates -->
<div role="status" aria-live="polite">Saved</div>
<div role="alert" aria-live="assertive">Error occurred</div>

<!-- Loading states -->
<div role="status" aria-busy="true">Loading...</div>
```

### Descriptive Labels

**Form Inputs**:
```html
<label for="task-title">Task title</label>
<input id="task-title" type="text" aria-required="true">
```

**Icon Buttons**:
```html
<button aria-label="Delete item">
  <icon:trash />
</button>
```

**Complex Widgets**:
```html
<button aria-label="Mark task 'Buy groceries' as complete">
  <icon:checkbox />
</button>
```

### Screen Reader Announcements

**State Changes**:
- "Item saved successfully"
- "Task marked as complete"
- "Space switched to Personal"

**Errors**:
- "Error: Please add content before saving"
- "Warning: Sync failed. Retrying..."

**Progress**:
- "Uploading image, 50% complete"
- "Syncing 3 of 10 items"

### VoiceOver & TalkBack Optimization

**iOS VoiceOver**:
- Custom rotor actions for quick navigation
- Hint text for complex interactions
- Grouped elements for efficiency

**Android TalkBack**:
- Content descriptions for all icons
- State descriptions for toggles
- Custom actions for swipe gestures

## Touch & Pointer Accessibility

### Touch Target Sizes

**Minimum Sizes** (WCAG 2.5.5):
- All interactive elements: 44x44dp (CSS pixels)
- Preferred: 48x48dp for better usability
- Icons: 24x24px visual, 44x44dp touch area

**Spacing**:
- Minimum 8px gap between adjacent targets
- Preferred: 16px gap for comfort

### Touch Gestures

**Simple Gestures Only**:
- Single tap: Primary action
- Long press: Context menu
- Swipe: Navigation or item actions
- Pinch: Zoom (if applicable)

**Avoid**:
- Complex multi-finger gestures
- Precise drag-and-drop (provide alternative)
- Time-based gestures

**Alternatives**:
- Every gesture must have a non-gesture alternative
- Swipe actions: Also available via menu
- Drag-and-drop: Also available via cut/paste

### Pointer Cancellation

**Cancel on Up**:
- Actions trigger on pointer up, not down
- User can move pointer away to cancel
- Applies to buttons, links, clickable items

## Motion & Animation

### Reduced Motion

**Respect Preference**:
```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

**Reduced Motion Alternatives**:
- Fade only (no scale, slide, rotation)
- Instant state changes (no animation)
- Maintain functional feedback (color change OK)

### Animation Guidelines

**Safe Animations**:
- Fade in/out
- Opacity changes
- Color transitions
- Position changes (slow, not flickering)

**Avoid**:
- Flashing (>3 times per second)
- Parallax scrolling (motion sickness)
- Auto-playing videos with motion
- Infinite spinning without pause

### Vestibular Disorders

**Considerations**:
- No rapid scrolling or panning
- No zoom animations that fill viewport
- Provide pause/stop for auto-updating content

## Form Accessibility

### Labels & Instructions

**Always Provide Labels**:
```html
<label for="due-date">Due date</label>
<input id="due-date" type="date">
```

**Helper Text**:
```html
<label for="task-title">Task title</label>
<input id="task-title" aria-describedby="title-hint">
<span id="title-hint">Keep it short and actionable</span>
```

### Error Handling

**Error Identification**:
```html
<label for="email">Email</label>
<input
  id="email"
  type="email"
  aria-invalid="true"
  aria-describedby="email-error"
>
<span id="email-error" role="alert">
  Please enter a valid email address
</span>
```

**Visual + Text**:
- Icon + color (red) + error message
- Never color alone
- Error message descriptive, not just "Invalid"

### Required Fields

**Clear Indication**:
```html
<label for="content">
  Content <span aria-label="required">*</span>
</label>
<input id="content" required aria-required="true">
```

**Form Validation**:
- Real-time validation (as user types)
- Clear error messages
- Focus on first error field
- Announce errors to screen readers

## Content Accessibility

### Headings Hierarchy

**Logical Structure**:
- `<h1>`: Page title (one per page)
- `<h2>`: Major sections
- `<h3>`: Subsections
- Don't skip levels (h1 → h3 ❌)

**Screen Reader Navigation**:
- Users navigate by headings
- Descriptive heading text
- Not just "Details" or "Settings"

### Alt Text for Images

**Informative Images**:
```html
<img src="screenshot.png" alt="Later app dashboard showing 5 tasks">
```

**Decorative Images**:
```html
<img src="decoration.png" alt="" role="presentation">
```

**Complex Images**:
```html
<figure>
  <img src="chart.png" alt="Task completion chart">
  <figcaption>
    Task completion rate increased from 60% to 85% in March.
  </figcaption>
</figure>
```

### Link Text

**Descriptive Links**:
```html
❌ <a href="/help">Click here</a>
✓ <a href="/help">View help documentation</a>
```

**Link Purpose**:
- Clear from link text alone
- Not dependent on surrounding context
- "Learn more" → "Learn more about quick capture"

## Assistive Technology Support

### Screen Readers

**Supported**:
- NVDA (Windows)
- JAWS (Windows)
- VoiceOver (macOS, iOS)
- TalkBack (Android)
- Narrator (Windows)

**Testing Requirement**:
- All features tested with at least 2 screen readers
- Critical flows tested on mobile screen readers

### Voice Control

**Voice Commands**:
- All interactive elements labeled for voice
- "Click [button name]" works
- "Show numbers" for numbered navigation

### Switch Control

**Sequential Navigation**:
- Tab order logical
- All features reachable via keyboard
- No timing requirements

## Testing Checklist

### Manual Testing

**Keyboard Only**:
- [ ] All features accessible via keyboard
- [ ] Focus visible at all times
- [ ] Tab order logical
- [ ] No keyboard traps
- [ ] Shortcuts work as documented

**Screen Reader**:
- [ ] All content announced correctly
- [ ] Landmarks and headings logical
- [ ] Forms labeled and described
- [ ] Errors announced
- [ ] Dynamic content updates announced

**Touch**:
- [ ] All targets 44x44dp minimum
- [ ] Gestures have alternatives
- [ ] No precision requirements

**Color**:
- [ ] Contrast ratios meet AA (4.5:1 text, 3:1 UI)
- [ ] Color not only means of information
- [ ] Tested with color blindness simulator

**Zoom**:
- [ ] Layout works at 200% zoom
- [ ] No horizontal scrolling
- [ ] All content visible and usable

**Motion**:
- [ ] Reduced motion preference respected
- [ ] No flashing content
- [ ] Animations pausable

### Automated Testing

**Tools**:
- axe DevTools (browser extension)
- Lighthouse (Chrome DevTools)
- WAVE (Web Accessibility Evaluation Tool)
- Flutter's Semantics debugger

**CI/CD Integration**:
- axe-core in automated tests
- Fail build on accessibility errors
- Warning on accessibility warnings

## Accessibility Statement

Later is committed to ensuring digital accessibility for people with disabilities. We continuously improve the user experience for everyone and apply relevant accessibility standards.

**Conformance Status**: WCAG 2.1 Level AA compliant

**Feedback**: If you encounter accessibility barriers, please contact us with details.

**Third-Party Content**: Some features may rely on third-party services with their own accessibility policies.

## Related Documentation

- [Testing Procedures](./testing.md) - Accessibility testing guide
- [Compliance Audit](./compliance.md) - WCAG compliance checklist
- [Style Guide](../design-system/style-guide.md) - Design system with accessibility specs

---

**Last Updated**: 2025-10-18 | **Version**: 1.0.0 | **Status**: Approved
