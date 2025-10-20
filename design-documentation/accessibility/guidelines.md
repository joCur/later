---
title: Accessibility Guidelines
description: Comprehensive accessibility standards and requirements for later
last-updated: 2025-10-19
version: 1.0.0
status: approved
related-files:
  - ../design-system/style-guide.md
  - ./testing.md
  - ./compliance.md
---

# Accessibility Guidelines

## Overview

later is built to be accessible to all users, regardless of ability. We follow **WCAG 2.1 AA standards** as our minimum baseline, with AAA standards for critical interactions.

## Core Principles

### 1. Perceivable
Information and UI components must be presentable to users in ways they can perceive.

### 2. Operable
UI components and navigation must be operable by all users.

### 3. Understandable
Information and UI operation must be understandable.

### 4. Robust
Content must be robust enough to be interpreted by a wide variety of user agents, including assistive technologies.

---

## Visual Accessibility

### Color Contrast

**Minimum Requirements** (WCAG AA)
- Normal text (< 18px): **4.5:1** contrast ratio
- Large text (≥ 18px): **3.0:1** contrast ratio
- UI components: **3.0:1** contrast ratio
- Focus indicators: **3.0:1** contrast ratio

**Target Standards** (WCAG AAA)
- Normal text: **7.0:1** contrast ratio
- Large text: **4.5:1** contrast ratio

**later Standards**
```dart
// Light mode text colors (on white)
AppColors.neutral700  // 11.2:1 (AAA) - Headings
AppColors.neutral600  // 7.8:1 (AAA) - Body text
AppColors.neutral500  // 4.9:1 (AA) - Secondary text

// Dark mode text colors (on Neutral-950)
AppColors.neutral300  // 11.8:1 (AAA) - Headings
AppColors.neutral400  // 7.2:1 (AAA) - Body text
AppColors.neutral500  // 4.2:1 (AA) - Secondary text

// Interactive elements
AppColors.primarySolid on white    // 7.2:1 (AAA)
AppColors.taskColor on white       // 5.9:1 (AA+)
AppColors.success on white         // 4.8:1 (AA)
```

**Color Usage Rules**

✓ **Do:**
- Use sufficient contrast for all text
- Test contrast on all background colors
- Provide high contrast mode option
- Use color + icon/text for information

✗ **Don't:**
- Rely solely on color to convey information
- Use color combinations that fail contrast tests
- Use pure white (#FFFFFF) or pure black (#000000)
- Ignore gradient backgrounds when testing contrast

### Typography

**Size Requirements**
- Minimum body text: **16px** on mobile, **15px** minimum
- Minimum touch target labels: **14px**
- Maximum text: No limit, but optimize for readability
- Line height: Minimum **1.5** for body text
- Paragraph spacing: At least **2x** font size

**Weight and Style**
- Avoid font weights below 300
- Use weight for hierarchy, not color alone
- Never use uppercase for full sentences
- Maintain sentence case for better readability

**Scalability**
```dart
// Respect system font scaling
Text(
  content,
  textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.85, 2.0),
)
```

**Requirements**:
- Support up to **2.0x** text scale
- Layout must not break at max scale
- No horizontal scrolling caused by text scaling
- Test at 0.85x, 1.0x, 1.3x, 1.5x, 2.0x

### Visual Focus Indicators

**Keyboard Focus**
```dart
FocusableActionDetector(
  onFocusChange: (focused) {
    setState(() => _isFocused = focused);
  },
  child: Container(
    decoration: BoxDecoration(
      border: _isFocused
          ? Border.all(
              color: AppColors.primarySolid,
              width: 3,
            )
          : null,
      borderRadius: BorderRadius.circular(AppRadius.sm),
    ),
    child: Widget(),
  ),
)
```

**Focus Requirements**:
- **3px** minimum outline width
- **2px** offset from element edge
- High contrast color (primary color)
- Visible on all backgrounds
- Animated appearance (100ms)
- Never remove focus indicator

**Focus Order**
- Logical tab order (left-to-right, top-to-bottom)
- Skip to main content link
- Trapped focus in modals
- Return focus on modal close

---

## Touch & Interaction Accessibility

### Touch Target Sizes

**Minimum Sizes**
- iOS HIG: **44 × 44 px**
- Android Material: **48 × 48 px**
- later standard: **48 × 48 px** (all platforms)
- Comfortable: **56 × 56 px** for primary actions

**Implementation**
```dart
// Ensure minimum touch target
Container(
  constraints: BoxConstraints(
    minWidth: 48,
    minHeight: 48,
  ),
  child: IconButton(
    icon: Icon(icon),
    onPressed: onPressed,
  ),
)
```

**Spacing Between Targets**
- Minimum: **8px** between touch targets
- Comfortable: **12px** for dense UIs
- Optimal: **16px** for standard layouts

### Gesture Support

**Required Alternatives**
- All swipe actions must have button alternatives
- Pinch-to-zoom must have button controls
- Long-press must have tap-and-hold alternative
- Drag-and-drop must have button-based reorder

**Gesture Examples**
```dart
// Swipe to delete with button alternative
Slidable(
  endActionPane: ActionPane(
    motion: const DrawerMotion(),
    children: [
      SlidableAction(
        onPressed: (_) => _deleteItem(),
        backgroundColor: AppColors.error,
        icon: Lucide.trash2,
        label: 'Delete',
      ),
    ],
  ),
  child: ListTile(
    // Also provide delete in long-press menu
    onLongPress: () => _showContextMenu(),
  ),
)
```

### Haptic Feedback

**Usage Guidelines**
- Light: Checkbox, selection changes
- Medium: Button presses, item taps
- Heavy: Destructive actions, completions
- Respect user preferences (can be disabled)

**Implementation**
```dart
// Check if haptics are enabled
final hapticsEnabled = Prefs.getBool('haptics_enabled') ?? true;

void triggerHaptic(HapticFeedbackType type) {
  if (!hapticsEnabled) return;

  switch (type) {
    case HapticFeedbackType.light:
      HapticFeedback.lightImpact();
      break;
    case HapticFeedbackType.medium:
      HapticFeedback.mediumImpact();
      break;
    case HapticFeedbackType.heavy:
      HapticFeedback.heavyImpact();
      break;
  }
}
```

---

## Screen Reader Accessibility

### Semantic Labels

**Principles**
- Provide descriptive labels for all interactive elements
- Include context and purpose
- Avoid redundant words like "button" (screen readers announce type)
- Use hints for additional context

**Examples**
```dart
// Good
Semantics(
  label: 'Quick capture',
  hint: 'Opens modal to create tasks, notes, or lists',
  button: true,
  child: FAB(),
)

// Bad
Semantics(
  label: 'Button', // Too vague
  child: FAB(),
)
```

### Semantic Properties

**Common Properties**
```dart
Semantics(
  // Basic properties
  label: 'Task: Buy groceries',         // What it is
  hint: 'Double tap to open',           // How to use
  value: 'Completed',                   // Current state

  // Interactive properties
  button: true,                         // It's a button
  enabled: true,                        // Can be interacted with
  focusable: true,                      // Can receive focus
  selected: isSelected,                 // Selection state
  checked: isChecked,                   // Checkbox state

  // Actions
  onTap: () => _handleTap(),           // Tap action
  onLongPress: () => _handleLongPress(), // Long press action
  onScrollDown: () => _scrollDown(),   // Scroll actions

  // Live regions
  liveRegion: true,                    // Announces changes
  hidden: false,                       // Visibility

  child: Widget(),
)
```

### Image Descriptions

**Alt Text Guidelines**
```dart
// Decorative images
Semantics(
  excludeSemantics: true, // Hidden from screen readers
  child: Image(...),
)

// Informative images
Semantics(
  label: 'Empty inbox illustration showing a mailbox with checkmarks',
  image: true,
  child: Image(...),
)

// Icons with adjacent text
Semantics(
  excludeSemantics: true, // Let text convey meaning
  child: Icon(Lucide.check),
)
```

### Dynamic Content

**Live Regions**
```dart
// Announce changes to screen readers
Semantics(
  label: 'Task completed',
  liveRegion: true,
  child: SuccessMessage(),
)
```

**Loading States**
```dart
Semantics(
  label: 'Loading tasks',
  liveRegion: true,
  child: CircularProgressIndicator(),
)
```

---

## Keyboard Accessibility

### Keyboard Navigation

**Tab Order**
- Logical and predictable order
- Skip to main content link at top
- No keyboard traps (unless intentional, like modals)
- Return focus when closing overlays

**Common Shortcuts**
```dart
// Global shortcuts
Cmd/Ctrl + N      // Quick capture
Cmd/Ctrl + K      // Search
Cmd/Ctrl + ,      // Settings
Escape            // Close modal/overlay

// Navigation
Tab               // Next element
Shift + Tab       // Previous element
Arrow keys        // Navigate lists/grids
Enter/Space       // Activate element

// Actions
Cmd/Ctrl + Enter  // Save/Submit
Cmd/Ctrl + Z      // Undo
Delete            // Delete (with confirmation)
```

**Implementation**
```dart
Focus(
  onKey: (node, event) {
    if (event is RawKeyDownEvent) {
      // Cmd/Ctrl + N for quick capture
      if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyN) {
        _openQuickCapture();
        return KeyEventResult.handled;
      }

      // Escape to close
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.pop(context);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  },
  child: Widget(),
)
```

### Keyboard-Only Navigation

**Requirements**
- All functionality available via keyboard
- Visible focus indicators
- Logical tab order
- Keyboard shortcuts for common actions
- No keyboard traps

**Testing Checklist**
- [ ] Can navigate entire app with keyboard only
- [ ] All interactive elements are focusable
- [ ] Focus indicators are visible
- [ ] Tab order is logical
- [ ] Shortcuts work as expected
- [ ] Modals trap focus appropriately
- [ ] Focus returns correctly when closing overlays

---

## Motion & Animation Accessibility

### Reduced Motion

**Detection**
```dart
bool get reduceMotion {
  return WidgetsBinding.instance.window.accessibilityFeatures.disableAnimations;
}
```

**Implementation**
```dart
// Conditional animation
widget.animate()
  .fadeIn(
    duration: reduceMotion ? 0.ms : 300.ms,
  );

// Alternative: Provide static version
if (reduceMotion) {
  return StaticWidget();
} else {
  return AnimatedWidget();
}
```

**Guidelines**

**Disable completely**:
- Parallax effects
- Auto-playing animations
- Continuous motion
- Decorative animations
- Complex transitions

**Keep (simplified)**:
- Essential state changes (instant or <100ms)
- Focus indicators (instant)
- Critical feedback (simplified, fast)

**Example**
```dart
class AccessibleAnimation {
  static Duration getDuration(Duration normal) {
    if (reduceMotion) return Duration.zero;
    return normal;
  }

  static Widget fadeIn(Widget child) {
    return AnimatedOpacity(
      opacity: 1,
      duration: getDuration(Duration(milliseconds: 300)),
      child: child,
    );
  }
}
```

### Vestibular Disorders

**Avoid**:
- Parallax scrolling
- Zoom effects
- Rapid flashing
- Spinning animations
- Excessive motion

**Implement**:
- Reduce motion preference
- Static alternatives
- Slower, gentler animations
- No auto-play by default

---

## Form Accessibility

### Form Labels

**Requirements**
```dart
// Explicit labels
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      'Task title',
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),
    SizedBox(height: 8),
    TextField(
      decoration: InputDecoration(
        hintText: 'Enter task title',
        // Associate with label for screen readers
      ),
    ),
  ],
)

// Or use Semantics
Semantics(
  label: 'Task title',
  child: TextField(),
)
```

### Error Messages

**Accessible Errors**
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    TextField(
      decoration: InputDecoration(
        errorText: errorMessage,
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
    ),
    if (errorMessage != null)
      Semantics(
        liveRegion: true,
        child: Text(
          errorMessage,
          style: TextStyle(color: AppColors.error),
        ),
      ),
  ],
)
```

**Error Guidelines**:
- Clear, specific error messages
- Visible and announced to screen readers
- Use color + icon + text (not color alone)
- Provide suggestions for fixing
- Don't clear errors until user acts

### Validation

**Inline Validation**
- Validate on blur (not on every keystroke)
- Show success indicators
- Provide helpful hints
- Allow correction before submission

**Submit Validation**
- Focus first error field
- Summarize errors at top
- Announce errors to screen readers
- Maintain user input (don't clear valid fields)

---

## Content Accessibility

### Plain Language

**Guidelines**:
- Use simple, clear language
- Avoid jargon and technical terms
- Write short sentences (< 20 words)
- Use active voice
- Define abbreviations on first use

**Examples**

Good:
- "Save your task"
- "Delete this item?"
- "Search your notes"

Bad:
- "Persist this entity to the data store"
- "Are you sure you want to permanently remove this item from the database?"
- "Utilize the query functionality to locate documents"

### Error Messages

**Structure**
1. What happened (problem)
2. Why it happened (cause)
3. How to fix it (solution)

**Examples**

Good:
```
"Couldn't save task"
"You're offline. Connect to save changes."
[Retry Button]
```

Bad:
```
"Error: Network request failed (ERR_CONN_REFUSED)"
```

### Instructions

**Guidelines**:
- Provide clear, step-by-step instructions
- Use numbered lists for sequences
- Include visual aids when helpful
- Don't rely on color alone
- Provide alternative text for images

---

## Platform-Specific Considerations

### iOS

**VoiceOver Support**
```dart
Semantics(
  label: 'Navigation button, Inbox',
  hint: 'Shows all uncategorized items',
  selected: isActive,
  button: true,
  child: NavItem(),
)
```

**Dynamic Type**
```dart
// Use TextStyle that scales with Dynamic Type
Text(
  'Title',
  style: Theme.of(context).textTheme.titleLarge,
)
```

**Accessibility Traits**
- Button
- Header
- Link
- Image
- Search field
- Selected
- Adjustable

### Android

**TalkBack Support**
```dart
Semantics(
  label: 'Inbox navigation button',
  hint: 'Double tap to view inbox',
  selected: isActive,
  button: true,
  child: NavItem(),
)
```

**Content Descriptions**
- Provide for all images
- Include state information
- Describe purpose, not appearance
- Keep concise

**Accessibility Services**
- TalkBack
- Select to Speak
- Switch Access
- Voice Access

---

## Testing Requirements

### Manual Testing

**Screen Reader Testing**
- iOS: VoiceOver
- Android: TalkBack
- Desktop: Screen reader of choice

**Keyboard Testing**
- Navigate entire app
- Activate all functions
- Verify focus indicators
- Test all shortcuts

**Visual Testing**
- High contrast mode
- Dark mode
- Color blindness simulators
- Various text sizes (0.85x - 2.0x)

### Automated Testing

**Tools**
- Accessibility Scanner (Android)
- Xcode Accessibility Inspector (iOS)
- axe DevTools
- Lighthouse accessibility audit

**Example Tests**
```dart
// Test contrast ratios
testWidgets('Button has sufficient contrast', (tester) async {
  await tester.pumpWidget(MyButton());

  final button = find.byType(MyButton);
  final widget = tester.widget<MyButton>(button);

  // Test contrast ratio
  expect(
    contrastRatio(widget.backgroundColor, widget.textColor),
    greaterThan(4.5),
  );
});

// Test touch targets
testWidgets('Button meets minimum size', (tester) async {
  await tester.pumpWidget(MyButton());

  final button = find.byType(MyButton);
  final size = tester.getSize(button);

  expect(size.width, greaterThanOrEqualTo(48));
  expect(size.height, greaterThanOrEqualTo(48));
});

// Test semantics
testWidgets('Button has proper semantics', (tester) async {
  await tester.pumpWidget(MyButton());

  final button = tester.getSemantics(find.byType(MyButton));

  expect(button.hasAction(SemanticsAction.tap), true);
  expect(button.label, isNotEmpty);
  expect(button.hasFlag(SemanticsFlag.isButton), true);
});
```

---

## Accessibility Settings

### User Preferences

**Provide Settings For**:
- Font size adjustments
- High contrast mode
- Reduce motion
- Haptic feedback toggle
- Color theme (dark/light/auto)
- Screen reader optimizations

**Implementation**
```dart
class AccessibilitySettings {
  static bool get reduceMotion => _prefs.getBool('reduce_motion') ?? _systemReduceMotion;
  static bool get highContrast => _prefs.getBool('high_contrast') ?? false;
  static bool get hapticsEnabled => _prefs.getBool('haptics') ?? true;
  static double get textScale => _prefs.getDouble('text_scale') ?? _systemTextScale;

  static void setReduceMotion(bool value) {
    _prefs.setBool('reduce_motion', value);
  }

  // ... other setters
}
```

---

## Quick Reference Checklist

### Visual
- [ ] All text meets 4.5:1 contrast minimum
- [ ] Color not sole means of conveying information
- [ ] Focus indicators visible (3:1 contrast)
- [ ] UI scales to 2.0x text size without breaking
- [ ] Minimum 16px body text

### Interaction
- [ ] All touch targets minimum 48×48px
- [ ] 8px minimum spacing between targets
- [ ] All gestures have button alternatives
- [ ] Haptic feedback can be disabled

### Screen Reader
- [ ] All interactive elements have labels
- [ ] Images have alt text or are hidden
- [ ] Live regions announce changes
- [ ] Form errors announced properly
- [ ] Semantic structure is logical

### Keyboard
- [ ] All functionality available via keyboard
- [ ] Logical tab order
- [ ] Visible focus indicators
- [ ] No keyboard traps
- [ ] Common shortcuts implemented

### Motion
- [ ] Respects reduce motion preference
- [ ] No auto-playing animations
- [ ] No excessive motion
- [ ] Essential animations preserved

### Content
- [ ] Plain language used
- [ ] Clear error messages
- [ ] Instructions are clear
- [ ] Abbreviations defined
- [ ] Reading level appropriate

---

**Related Documentation**
- [Style Guide](../design-system/style-guide.md)
- [Accessibility Testing](./testing.md)
- [WCAG Compliance](./compliance.md)

**Last Updated**: October 19, 2025
**Version**: 1.0.0
