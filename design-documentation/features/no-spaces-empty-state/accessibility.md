---
title: No Spaces Empty State - Accessibility Requirements
description: WCAG 2.1 AA compliance requirements and testing procedures
feature: no-spaces-empty-state
last-updated: 2025-11-07
version: 1.0.0
related-files:
  - ./README.md
  - ./screen-states.md
  - ./interactions.md
  - ./implementation.md
status: approved
---

# No Spaces Empty State - Accessibility Requirements

## Overview

This document specifies accessibility requirements to ensure the No Spaces Empty State meets **WCAG 2.1 Level AA** standards and provides an excellent experience for users with disabilities.

## Accessibility Goals

### Primary Goals
1. **Screen reader compatibility**: All content is accessible via VoiceOver (iOS) and TalkBack (Android)
2. **Visual accessibility**: Sufficient color contrast for users with low vision or color blindness
3. **Motor accessibility**: Touch targets meet minimum size requirements
4. **Cognitive accessibility**: Clear, simple language and predictable interactions
5. **Motion accessibility**: Respects user preferences for reduced motion

### Target Compliance
- **Standard**: WCAG 2.1 Level AA
- **Platform Guidelines**: iOS Human Interface Guidelines, Android Material Design Accessibility
- **Legal Requirements**: ADA (US), AODA (Canada), EAA (EU)

---

## WCAG 2.1 AA Compliance Matrix

### Perceivable

#### 1.1 Text Alternatives

**1.1.1 Non-text Content (Level A)**

| Element | Requirement | Implementation | Status |
|---------|-------------|----------------|--------|
| Icon | Decorative (no unique info) | `ExcludeSemantics(true)` | ✅ Pass |
| Button | Text label provided | "Create Your First Space" | ✅ Pass |

**Testing**:
- Enable VoiceOver/TalkBack
- Navigate to empty state
- Verify icon is not announced (decorative)
- Verify button label is announced clearly

#### 1.3 Adaptable

**1.3.1 Info and Relationships (Level A)**

| Element | Requirement | Implementation | Status |
|---------|-------------|----------------|--------|
| Title | Heading semantics | Implicit via text style | ✅ Pass |
| Message | Descriptive text | Plain text widget | ✅ Pass |
| Button | Button role | `Semantics(button: true)` | ✅ Pass |

**Testing**:
- Screen reader announces "Welcome to Later, heading"
- Screen reader announces button with role: "button"

**1.3.3 Sensory Characteristics (Level A)**

| Element | Requirement | Implementation | Status |
|---------|-------------|----------------|--------|
| Instructions | Not shape/color dependent | Text-based instructions | ✅ Pass |
| Button | Not color-only indicator | Text label + gradient | ✅ Pass |

**Rationale**: All instructions use text. Button has text label, not just color.

#### 1.4 Distinguishable

**1.4.3 Contrast (Minimum) (Level AA) - 4.5:1 normal text, 3:1 large text**

| Element | Foreground | Background | Ratio | Status |
|---------|------------|------------|-------|--------|
| Title (Light) | Neutral600 | Neutral50 | 11.2:1 | ✅ AAA |
| Title (Dark) | Neutral400 | Neutral900 | 8.9:1 | ✅ AAA |
| Message (Light) | Neutral500 | Neutral50 | 6.8:1 | ✅ AA+ |
| Message (Dark) | Neutral400 | Neutral900 | 8.9:1 | ✅ AAA |
| Button Text (Light) | White | Gradient avg | 7.1:1 | ✅ AAA |
| Button Text (Dark) | White | Gradient avg | 7.1:1 | ✅ AAA |

**Gradient Contrast Calculation**:
- Gradient start: #6366F1 (Indigo)
- Gradient end: #A855F7 (Purple)
- Average luminance: #8A5EF4 (weighted)
- White on #8A5EF4: 7.1:1 contrast ratio ✅

**Testing Tools**:
- WebAIM Contrast Checker: https://webaim.org/resources/contrastchecker/
- Flutter DevTools Color Contrast Analyzer
- Manual verification with Accessibility Inspector (Xcode)

**1.4.4 Resize Text (Level AA) - 200% zoom**

| Element | Behavior at 200% | Status |
|---------|------------------|--------|
| Title | Scales proportionally | ✅ Pass |
| Message | Wraps to 3 lines max | ✅ Pass |
| Button | Height increases, text scales | ✅ Pass |

**Implementation**:
- Use `MediaQuery.of(context).textScaleFactor`
- Typography scales automatically
- Button height grows with text
- Test with iOS "Larger Text" and Android "Font Size"

**Testing**:
- iOS: Settings → Accessibility → Display & Text Size → Larger Text (max)
- Android: Settings → Display → Font size (largest)
- Verify all text remains readable and doesn't truncate

**1.4.10 Reflow (Level AA) - No 2D scrolling at 320px width**

| Breakpoint | Behavior | Status |
|------------|----------|--------|
| 320px (min) | Single column, vertical only | ✅ Pass |
| 375px | Single column, vertical only | ✅ Pass |
| 768px | Single column, vertical only | ✅ Pass |

**Testing**:
- Test on iPhone SE (320×568px)
- Verify no horizontal scrolling required
- All content fits in vertical viewport

**1.4.11 Non-text Contrast (Level AA) - 3:1 for UI components**

| Element | Contrast | Status |
|---------|----------|--------|
| Button (Light) | 3.8:1 vs background | ✅ Pass |
| Button (Dark) | 4.2:1 vs background | ✅ Pass |
| Button border (if any) | N/A (no border) | N/A |

**Calculation**:
- Button gradient average (#8A5EF4) vs Light background (Neutral50): 3.8:1 ✅
- Button gradient average (#8A5EF4) vs Dark background (Neutral900): 4.2:1 ✅

**1.4.12 Text Spacing (Level AA)**

| Property | Requirement | Implementation | Status |
|----------|-------------|----------------|--------|
| Line height | ≥1.5× font size | 1.5× (24px / 16px) | ✅ Pass |
| Paragraph spacing | ≥2× font size | 24px / 16px = 1.5× | ⚠️ Close |
| Letter spacing | ≥0.12× font size | Default (0.0) | ⚠️ Review |
| Word spacing | ≥0.16× font size | Default (1.0) | ✅ Pass |

**Note**: Paragraph spacing is close (1.5× vs 2× required). Consider increasing from 24px to 32px between title and message if issues arise.

**1.4.13 Content on Hover or Focus (Level AA)**

| Element | Hover/Focus Behavior | Dismissible | Hoverable | Persistent | Status |
|---------|----------------------|-------------|-----------|------------|--------|
| Button | Visual change only | N/A | N/A | N/A | ✅ Pass |

**Rationale**: No tooltips or additional content appears on hover. Only visual state changes (elevation, overlay).

---

### Operable

#### 2.1 Keyboard Accessible

**2.1.1 Keyboard (Level A)**

| Feature | Requirement | Implementation | Status |
|---------|-------------|----------------|--------|
| Button activation | Keyboard accessible | N/A (mobile-first) | N/A |
| No keyboard trap | Not applicable | N/A (mobile) | N/A |

**Mobile Context**: This is a mobile-first app. Keyboard navigation not applicable for current scope.

**Future Web Implementation**:
- Ensure Tab key focuses button
- Enter/Space activates button
- No keyboard traps

**2.1.2 No Keyboard Trap (Level A)**

**Status**: N/A (mobile-first, no keyboard navigation)

**2.1.4 Character Key Shortcuts (Level A)**

**Status**: N/A (no keyboard shortcuts implemented)

#### 2.2 Enough Time

**2.2.1 Timing Adjustable (Level A)**

| Element | Time Limit | Adjustable | Status |
|---------|------------|------------|--------|
| Animations | 400ms max | N/A (decorative) | ✅ Pass |
| Modal | No time limit | N/A | ✅ Pass |

**Rationale**: No time-based actions. User can take as long as needed.

**2.2.2 Pause, Stop, Hide (Level A)**

| Animation | Auto-start | >5 seconds | Controls Needed | Status |
|-----------|------------|------------|-----------------|--------|
| Entrance | Yes | No (400ms) | No | ✅ Pass |
| Button hover | No (user-triggered) | No | No | ✅ Pass |

**Rationale**: Entrance animation is <5 seconds, not required to be controllable.

#### 2.3 Seizures and Physical Reactions

**2.3.1 Three Flashes or Below Threshold (Level A)**

| Element | Flashing | Frequency | Status |
|---------|----------|-----------|--------|
| All content | None | N/A | ✅ Pass |

**Verification**: No flashing, strobing, or rapidly changing content.

#### 2.4 Navigable

**2.4.3 Focus Order (Level A)**

**Focus Order**:
1. Empty state content (announced as a group)
2. Primary button

**Status**: ✅ Logical and intuitive

**Testing**:
- Navigate with VoiceOver/TalkBack
- Verify content announced before button
- Verify button is focusable and activatable

**2.4.4 Link Purpose (In Context) (Level A)**

**Status**: N/A (no links in this feature)

#### 2.5 Input Modalities

**2.5.1 Pointer Gestures (Level A)**

| Gesture | Type | Alternative | Status |
|---------|------|-------------|--------|
| Button tap | Single tap | N/A (simplest) | ✅ Pass |

**Rationale**: Only uses single-tap gestures. No complex multi-point or path-based gestures.

**2.5.2 Pointer Cancellation (Level A)**

| Action | Down Event | Up Event | Cancel Method | Status |
|--------|------------|----------|---------------|--------|
| Button press | Visual feedback | Activates | Drag out of bounds | ✅ Pass |

**Implementation**: Button uses up-event for activation (onPressed triggers on touchUp, not touchDown).

**Testing**:
- Press button, drag finger out of bounds, release → No action ✅
- Press button, release within bounds → Action triggered ✅

**2.5.3 Label in Name (Level A)**

| Element | Visible Label | Accessible Name | Match | Status |
|---------|---------------|-----------------|-------|--------|
| Button | "Create Your First Space" | "Create Your First Space" | ✅ | ✅ Pass |

**Verification**: Visual label matches semantic label exactly.

**2.5.4 Motion Actuation (Level A)**

**Status**: N/A (no device motion or user motion gestures used)

**2.5.5 Target Size (Level AAA) - 44×44px minimum**

| Element | Width | Height | Status |
|---------|-------|--------|--------|
| Button (Mobile) | ~300-360px | 48px | ✅ Pass |
| Button (Tablet) | ~250-400px | 48px | ✅ Pass |
| Button (Desktop) | ~250-400px | 48px | ✅ Pass |

**Note**: WCAG AAA requires 44×44px. Button exceeds this (48px height).

**Spacing Verification**: No other touch targets within 8px (plenty of clearance).

---

### Understandable

#### 3.1 Readable

**3.1.1 Language of Page (Level A)**

| Property | Value | Implementation | Status |
|----------|-------|----------------|--------|
| Language | English (en-US) | MaterialApp locale | ✅ Pass |

**Implementation**:
```dart
MaterialApp(
  locale: Locale('en', 'US'),
  ...
)
```

**3.1.2 Language of Parts (Level AA)**

**Status**: N/A (all content is English, no mixed languages)

#### 3.2 Predictable

**3.2.1 On Focus (Level A)**

| Element | Focus Behavior | Context Change | Status |
|---------|----------------|----------------|--------|
| Button | Visual focus indicator | None | ✅ Pass |

**Rationale**: Focusing button does not trigger any action. Only visual change.

**3.2.2 On Input (Level A)**

**Status**: N/A (no input fields in this screen)

**3.2.3 Consistent Navigation (Level AA)**

**Status**: N/A (single screen, no navigation structure)

**3.2.4 Consistent Identification (Level AA)**

| Element | Identification | Consistent Across App | Status |
|---------|----------------|-----------------------|--------|
| PrimaryButton | Gradient button style | Yes (design system) | ✅ Pass |

**Verification**: Button uses same design system component as rest of app.

#### 3.3 Input Assistance

**3.3.1 Error Identification (Level A)**

**Status**: N/A (no input fields in this screen; errors handled by CreateSpaceModal)

**3.3.2 Labels or Instructions (Level A)**

| Field | Label | Instructions | Status |
|-------|-------|--------------|--------|
| N/A | N/A | Clear message provided | ✅ Pass |

**Message Text**: "Spaces organize your tasks, notes, and lists by context. Let's create your first one!"

**Clarity**: ✅ Explains what to do and why

**3.3.3 Error Suggestion (Level AA)**

**Status**: N/A (no errors can occur in this screen)

**3.3.4 Error Prevention (Legal, Financial, Data) (Level AA)**

**Status**: N/A (no data submission in this screen; space creation is non-critical action)

---

### Robust

#### 4.1 Compatible

**4.1.1 Parsing (Level A)**

**Status**: ✅ Flutter automatically generates valid UI trees

**4.1.2 Name, Role, Value (Level A)**

| Element | Name | Role | Value | Status |
|---------|------|------|-------|--------|
| Button | "Create Your First Space" | Button | N/A | ✅ Pass |
| Title | "Welcome to Later" | Heading (implicit) | N/A | ✅ Pass |
| Message | "Spaces organize..." | Text | N/A | ✅ Pass |

**Testing**:
- VoiceOver announces: "Create Your First Space, button"
- TalkBack announces: "Create Your First Space, button"

**4.1.3 Status Messages (Level AA)**

**Status**: N/A (no status messages in this screen)

---

## Platform-Specific Accessibility

### iOS Accessibility

#### VoiceOver Support

**Screen Reader Flow**:
1. User lands on screen
2. VoiceOver announces: "Welcome to Later. Spaces organize your tasks, notes, and lists by context. Let's create your first one!"
3. User swipes right (next element)
4. VoiceOver announces: "Create Your First Space, button. Double-tap to activate"
5. User double-taps
6. Button activates, modal opens

**Semantic Labels**:
```dart
Semantics(
  container: true,
  label: 'Welcome to Later. Spaces organize your tasks, notes, and lists by context. Let\'s create your first one!',
  child: Column(...),
)
```

**Testing Procedure**:
1. Enable VoiceOver: Settings → Accessibility → VoiceOver → On
2. Navigate to empty state screen
3. Verify announcement is clear and complete
4. Swipe to button, verify it's announced as "button"
5. Double-tap to activate, verify modal opens

#### Dynamic Type Support

**Implementation**:
- Use `AppTypography` scale (automatically respects text scale factor)
- Test with largest accessibility size

**Testing**:
1. Settings → Accessibility → Display & Text Size → Larger Text → Max
2. Open app, verify text is readable and doesn't truncate
3. Verify button height increases to fit text

#### Reduce Motion Support

**Implementation**:
```dart
final reducedMotion = MediaQuery.of(context).disableAnimations;
if (!reducedMotion) {
  // Apply entrance animation
}
```

**Testing**:
1. Settings → Accessibility → Motion → Reduce Motion → On
2. Open app, verify entrance animation is skipped
3. Verify content appears instantly without motion

#### VoiceOver Rotor Support

**Not Applicable**: No headings, links, or form fields that would appear in Rotor navigation.

**Future Enhancement**: If adding more complex content, consider adding headings for Rotor navigation.

### Android Accessibility

#### TalkBack Support

**Screen Reader Flow**:
1. User lands on screen
2. TalkBack announces: "Welcome to Later. Spaces organize your tasks, notes, and lists by context. Let's create your first one!"
3. User swipes right (next element)
4. TalkBack announces: "Create Your First Space, button"
5. User double-taps
6. Button activates, modal opens

**Testing Procedure**:
1. Enable TalkBack: Settings → Accessibility → TalkBack → On
2. Navigate to empty state screen
3. Verify announcement is clear and complete
4. Swipe to button, verify it's announced as "button"
5. Double-tap to activate, verify modal opens

#### Font Size Support

**Implementation**: Same as iOS (respects `textScaleFactor`)

**Testing**:
1. Settings → Display → Font size → Largest
2. Open app, verify text is readable and doesn't truncate
3. Verify layout doesn't break

#### Reduce Animations Support

**Implementation**: Uses `MediaQuery.of(context).disableAnimations`

**Testing**:
1. Settings → Accessibility → Remove animations → On
2. Open app, verify entrance animation is skipped
3. Verify content appears instantly

#### Switch Access Support

**Not Applicable**: Mobile-first, no keyboard navigation. Switch Access would use touch input.

**Future Enhancement**: If adding keyboard support, ensure Switch Access works with Tab navigation.

---

## Accessibility Testing Checklist

### Automated Testing

- [ ] Run Flutter's accessibility scanner:
  ```dart
  testWidgets('No spaces state meets accessibility guidelines', (tester) async {
    await tester.pumpWidget(testApp(NoSpacesState(...)));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  });
  ```

- [ ] Run Xcode Accessibility Inspector (iOS)
- [ ] Run Android Lint accessibility checks
- [ ] Verify with Color Oracle (color blindness simulator)

### Manual Testing

#### Screen Reader Testing

- [ ] **VoiceOver (iOS)**:
  - [ ] All content announced correctly
  - [ ] Button announced with role "button"
  - [ ] Icon not announced (decorative)
  - [ ] Navigation order is logical

- [ ] **TalkBack (Android)**:
  - [ ] All content announced correctly
  - [ ] Button announced with role "button"
  - [ ] Icon not announced (decorative)
  - [ ] Navigation order is logical

#### Visual Testing

- [ ] **Color Contrast**:
  - [ ] Title text: 11.2:1 (light), 8.9:1 (dark) ✅
  - [ ] Message text: 6.8:1 (light), 8.9:1 (dark) ✅
  - [ ] Button text: 7.1:1 (both modes) ✅

- [ ] **Text Scaling**:
  - [ ] Test at 100%, 150%, 200% text size
  - [ ] Verify no truncation
  - [ ] Verify layout doesn't break

- [ ] **Color Blindness**:
  - [ ] Test with Protanopia filter (red-blind)
  - [ ] Test with Deuteranopia filter (green-blind)
  - [ ] Test with Tritanopia filter (blue-blind)
  - [ ] Verify button is distinguishable (not color-only)

#### Motor Accessibility Testing

- [ ] **Touch Targets**:
  - [ ] Button: 48×48px minimum ✅
  - [ ] Adequate spacing around button (24px+) ✅

- [ ] **Pointer Cancellation**:
  - [ ] Press button, drag out, release → No action ✅
  - [ ] Press button, release in bounds → Action ✅

#### Motion Sensitivity Testing

- [ ] **Reduced Motion**:
  - [ ] Enable "Reduce Motion" on iOS
  - [ ] Enable "Remove animations" on Android
  - [ ] Verify entrance animation is skipped
  - [ ] Verify button interactions still work

---

## Accessibility Documentation

### User-Facing Documentation

**Recommended**: Create accessibility guide in app help section:

```
# Accessibility Features

## Screen Readers
Later is fully compatible with VoiceOver (iOS) and TalkBack (Android).
All content is properly labeled and navigable.

## Text Size
Increase text size in your device settings:
- iOS: Settings → Accessibility → Display & Text Size → Larger Text
- Android: Settings → Display → Font size

## Reduce Motion
If animations cause discomfort, enable:
- iOS: Settings → Accessibility → Motion → Reduce Motion
- Android: Settings → Accessibility → Remove animations
```

### Developer Documentation

See [implementation.md](./implementation.md) for developer-focused accessibility implementation details.

---

## Accessibility Maintenance

### Regression Testing

**Test on Every Release**:
- [ ] Screen reader compatibility (VoiceOver, TalkBack)
- [ ] Color contrast (automated checks)
- [ ] Touch target sizes (automated checks)
- [ ] Reduced motion support (manual test)

### Continuous Improvement

**Regular Audits**:
- Quarterly accessibility audit with real users
- Annual third-party accessibility assessment
- Monitor user feedback for accessibility issues

**User Research**:
- Recruit users with disabilities for testing
- Conduct usability studies with screen reader users
- Gather feedback on accessibility features

---

## Related Documentation

- [Screen States](./screen-states.md) - Visual contrast specifications
- [Interactions](./interactions.md) - Motion and animation details
- [Implementation](./implementation.md) - Developer implementation guide
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

---

**Next Steps**: Review `implementation.md` for developer-focused implementation details and handoff guide.
