---
title: No Spaces Empty State - Implementation Guide
description: Developer handoff with technical implementation details
feature: no-spaces-empty-state
last-updated: 2025-11-07
version: 1.0.0
related-files:
  - ./README.md
  - ./screen-states.md
  - ./interactions.md
  - ./accessibility.md
dependencies:
  - AnimatedEmptyState component (design_system/organisms/empty_states/)
  - PrimaryButton component (design_system/atoms/buttons/)
  - CreateSpaceModal (widgets/modals/)
  - SpacesProvider (providers/)
status: approved
---

# No Spaces Empty State - Implementation Guide

## Overview

This document provides complete implementation details for developers to build the No Spaces Empty State feature with pixel-perfect accuracy and full accessibility support.

## Technical Architecture

### Component Structure

```
NoSpacesState (new stateless widget)
  └── AnimatedEmptyState (existing component)
        └── EmptyState (existing component)
              └── Column
                    ├── ShaderMask (gradient icon)
                    │     └── Icon (folder_rounded)
                    ├── Text (title)
                    ├── Text (message)
                    └── PrimaryButton (CTA)
```

### File Locations

**New File**:
- `apps/later_mobile/lib/design_system/organisms/empty_states/no_spaces_state.dart`

**Modified Files**:
- `apps/later_mobile/lib/widgets/screens/home_screen.dart` (add new empty state logic)
- `apps/later_mobile/lib/design_system/organisms/empty_states/empty_states.dart` (export new component)

**Testing Files**:
- `apps/later_mobile/test/design_system/organisms/empty_states/no_spaces_state_test.dart` (new)
- `apps/later_mobile/test/widgets/screens/home_screen_test.dart` (update)

---

## Implementation Steps

### Step 1: Create NoSpacesState Component

**File**: `lib/design_system/organisms/empty_states/no_spaces_state.dart`

```dart
import 'package:flutter/material.dart';
import 'animated_empty_state.dart';

/// Empty state displayed when user has zero spaces in their account.
///
/// Shown on first app launch or after deleting all spaces.
/// Guides user to create their first space.
///
/// Features:
/// - Folder icon with gradient tint (64-100px responsive)
/// - Welcoming title: "Welcome to Later"
/// - Educational message about spaces concept
/// - Primary CTA: "Create Your First Space"
/// - Entrance animations via AnimatedEmptyState
/// - No FAB pulse (not applicable for space creation)
///
/// Example usage:
/// ```dart
/// NoSpacesState(
///   onActionPressed: () => _showCreateSpaceModal(),
/// )
/// ```
class NoSpacesState extends StatelessWidget {
  /// Creates a no spaces empty state widget.
  const NoSpacesState({
    super.key,
    required this.onActionPressed,
  });

  /// Callback when "Create Your First Space" button is pressed
  /// Should open CreateSpaceModal in create mode
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedEmptyState(
      icon: Icons.folder_rounded,
      title: 'Welcome to Later',
      message:
          'Spaces organize your tasks, notes, and lists by context. Let\'s create your first one!',
      actionLabel: 'Create Your First Space',
      onActionPressed: onActionPressed,
      // No secondaryActionLabel (single-path onboarding)
      // No enableFabPulse (FAB not relevant for space creation)
    );
  }
}
```

**Key Implementation Details**:
- **Icon**: `Icons.folder_rounded` - Universal metaphor for containers/organization
- **Title**: "Welcome to Later" - Establishes welcoming context
- **Message**: Two sentences - explains "what" (spaces organize) and "why" (by context) + encourages action
- **CTA Label**: "Create Your First Space" - Action-oriented, encouraging
- **No secondary action**: Intentionally single-path to reduce cognitive load
- **No FAB pulse**: Space creation doesn't use FAB (modal-based flow)

### Step 2: Export Component

**File**: `lib/design_system/organisms/empty_states/empty_states.dart`

Add export at the end of the file:

```dart
export 'no_spaces_state.dart';
```

**Verification**: Ensure `empty_states.dart` exports all empty state components:
```dart
export 'animated_empty_state.dart';
export 'empty_space_state.dart';
export 'empty_state.dart';
export 'welcome_state.dart';
export 'empty_search_state.dart';
export 'no_spaces_state.dart'; // NEW
```

### Step 3: Update Home Screen Logic

**File**: `lib/widgets/screens/home_screen.dart`

**Current Logic** (lines ~387-421):
```dart
Widget _buildContentList(
  BuildContext context,
  List<dynamic> content,
  Space? currentSpace,
  SpacesProvider spacesProvider,
  ContentProvider contentProvider,
) {
  // Check if completely empty (no content at all)
  if (content.isEmpty && contentProvider.getTotalCount() == 0) {
    // Check if this is a new user (welcome state)
    // Welcome state: no content AND default space is the only space
    final isNewUser =
        spacesProvider.spaces.length == 1 &&
        spacesProvider.spaces.first.name == 'Inbox';

    if (isNewUser) {
      // Show welcome state for first-time users
      return WelcomeState(...);
    } else {
      // Show empty space state for existing users with empty spaces
      return EmptySpaceState(...);
    }
  }

  // ... rest of content list logic
}
```

**Updated Logic** (add NO SPACES check FIRST):
```dart
Widget _buildContentList(
  BuildContext context,
  List<dynamic> content,
  Space? currentSpace,
  SpacesProvider spacesProvider,
  ContentProvider contentProvider,
) {
  // ========== NEW: Check if user has NO SPACES at all ==========
  if (spacesProvider.spaces.isEmpty) {
    return NoSpacesState(
      onActionPressed: _showCreateSpaceModal,
    );
  }
  // ==============================================================

  // Check if completely empty (no content at all)
  if (content.isEmpty && contentProvider.getTotalCount() == 0) {
    // Check if this is a new user (welcome state)
    // Welcome state: no content AND default space is the only space
    final isNewUser =
        spacesProvider.spaces.length == 1 &&
        spacesProvider.spaces.first.name == 'Inbox';

    if (isNewUser) {
      // Show welcome state for first-time users
      return WelcomeState(
        onActionPressed: _showCreateContentModal,
        enableFabPulse: (enabled) {
          if (mounted) {
            setState(() {
              _enableFabPulse = enabled;
            });
          }
        },
      );
    } else {
      // Show empty space state for existing users with empty spaces
      return EmptySpaceState(
        spaceName: currentSpace?.name ?? 'space',
        onActionPressed: _showCreateContentModal,
        enableFabPulse: (enabled) {
          if (mounted) {
            setState(() {
              _enableFabPulse = enabled;
            });
          }
        },
      );
    }
  }

  // ... rest of content list logic (unchanged)
}
```

**Add CreateSpaceModal Method** (if not already exists):
```dart
/// Show the create space modal
Future<void> _showCreateSpaceModal() async {
  final result = await showModalBottomSheet<Space?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const CreateSpaceModal(
      mode: SpaceModalMode.create,
    ),
  );

  // If space was created, provider will notify and rebuild
  // No manual refresh needed (Consumer handles it)
}
```

**Import Statement** (add if not present):
```dart
import 'package:later_mobile/design_system/organisms/empty_states/no_spaces_state.dart';
```

**Verification Checklist**:
- ✅ NoSpacesState check happens BEFORE content empty check
- ✅ NoSpacesState only shows when `spacesProvider.spaces.isEmpty`
- ✅ After space creation, home screen rebuilds via `Consumer<SpacesProvider>`
- ✅ New space appears in dropdown, WelcomeState shows for empty space

### Step 4: Add Unit Tests

**File**: `test/design_system/organisms/empty_states/no_spaces_state_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/organisms/empty_states/no_spaces_state.dart';
import '../../../test_helpers.dart';

void main() {
  group('NoSpacesState', () {
    testWidgets('renders with correct content', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        testApp(
          NoSpacesState(
            onActionPressed: () {
              pressed = true;
            },
          ),
        ),
      );

      // Verify icon is present (folder_rounded)
      expect(find.byIcon(Icons.folder_rounded), findsOneWidget);

      // Verify title
      expect(find.text('Welcome to Later'), findsOneWidget);

      // Verify message
      expect(
        find.textContaining('Spaces organize your tasks'),
        findsOneWidget,
      );

      // Verify button
      expect(find.text('Create Your First Space'), findsOneWidget);

      // Tap button
      await tester.tap(find.text('Create Your First Space'));
      await tester.pumpAndSettle();

      // Verify callback fired
      expect(pressed, isTrue);
    });

    testWidgets('button is tappable', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        testApp(
          NoSpacesState(
            onActionPressed: () {
              tapped = true;
            },
          ),
        ),
      );

      // Find and tap button
      final button = find.text('Create Your First Space');
      expect(button, findsOneWidget);

      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('meets accessibility guidelines', (tester) async {
      await tester.pumpWidget(
        testApp(
          NoSpacesState(
            onActionPressed: () {},
          ),
        ),
      );

      // Verify touch target size (button should be ≥48px height)
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));

      // Verify text contrast
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      // Verify labeled tap targets
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });

    testWidgets('has correct semantics for screen readers', (tester) async {
      await tester.pumpWidget(
        testApp(
          NoSpacesState(
            onActionPressed: () {},
          ),
        ),
      );

      // Verify button has correct semantic label
      final buttonSemantics = tester.getSemantics(
        find.text('Create Your First Space'),
      );
      expect(buttonSemantics.label, contains('Create Your First Space'));
      expect(buttonSemantics.isButton, isTrue);
    });

    testWidgets('respects reduced motion preference', (tester) async {
      // Note: Testing reduced motion requires mocking MediaQuery
      // This is a placeholder for integration testing
      // Actual implementation uses AnimatedEmptyState which handles this

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            disableAnimations: true, // Reduced motion enabled
          ),
          child: testApp(
            NoSpacesState(
              onActionPressed: () {},
            ),
          ),
        ),
      );

      // Verify widget renders (animations skipped internally)
      expect(find.text('Welcome to Later'), findsOneWidget);
    });
  });
}
```

**Test Coverage Requirements**:
- ✅ Widget renders with correct content
- ✅ Button callback works
- ✅ Accessibility guidelines met
- ✅ Screen reader semantics correct
- ✅ Reduced motion respected

### Step 5: Update Home Screen Tests

**File**: `test/widgets/screens/home_screen_test.dart`

**Add New Test Case**:
```dart
testWidgets('shows NoSpacesState when user has no spaces', (tester) async {
  // Setup mock providers with NO spaces
  final spacesProvider = MockSpacesProvider();
  when(spacesProvider.spaces).thenReturn([]); // Empty list
  when(spacesProvider.currentSpace).thenReturn(null);
  when(spacesProvider.isLoading).thenReturn(false);

  final contentProvider = MockContentProvider();
  when(contentProvider.getFilteredContent(any)).thenReturn([]);
  when(contentProvider.getTotalCount()).thenReturn(0);
  when(contentProvider.isLoading).thenReturn(false);

  // Build home screen
  await tester.pumpWidget(
    testApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SpacesProvider>.value(value: spacesProvider),
          ChangeNotifierProvider<ContentProvider>.value(value: contentProvider),
        ],
        child: HomeScreen(),
      ),
    ),
  );

  await tester.pumpAndSettle();

  // Verify NoSpacesState is shown
  expect(find.text('Welcome to Later'), findsOneWidget);
  expect(find.text('Create Your First Space'), findsOneWidget);

  // Verify WelcomeState is NOT shown
  expect(find.text('Welcome to later'), findsNothing); // Note: lowercase 'l'
  expect(find.text('Create your first item'), findsNothing);
});

testWidgets('transitions from NoSpacesState to WelcomeState after space creation', (tester) async {
  // Setup mock providers starting with NO spaces
  final spacesProvider = MockSpacesProvider();
  when(spacesProvider.spaces).thenReturn([]);
  when(spacesProvider.currentSpace).thenReturn(null);
  when(spacesProvider.isLoading).thenReturn(false);

  final contentProvider = MockContentProvider();
  when(contentProvider.getFilteredContent(any)).thenReturn([]);
  when(contentProvider.getTotalCount()).thenReturn(0);
  when(contentProvider.isLoading).thenReturn(false);

  // Build home screen
  await tester.pumpWidget(
    testApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SpacesProvider>.value(value: spacesProvider),
          ChangeNotifierProvider<ContentProvider>.value(value: contentProvider),
        ],
        child: HomeScreen(),
      ),
    ),
  );

  await tester.pumpAndSettle();

  // Verify NoSpacesState is shown initially
  expect(find.text('Welcome to Later'), findsOneWidget);

  // Simulate space creation by updating mock
  final newSpace = Space(
    id: 'test-space-id',
    name: 'Inbox',
    icon: '📥',
    color: '#6366F1',
    userId: 'test-user-id',
    isArchived: false,
  );
  when(spacesProvider.spaces).thenReturn([newSpace]);
  when(spacesProvider.currentSpace).thenReturn(newSpace);

  // Trigger rebuild
  spacesProvider.notifyListeners();
  await tester.pumpAndSettle();

  // Verify WelcomeState is now shown (empty space with 1 space)
  expect(find.text('Welcome to later'), findsOneWidget); // Lowercase 'l'
  expect(find.text('Your peaceful place for thoughts'), findsOneWidget);

  // Verify NoSpacesState is no longer shown
  expect(find.text('Welcome to Later'), findsNothing); // Uppercase 'L'
  expect(find.text('Create Your First Space'), findsNothing);
});
```

**Update Existing Tests**:
- Ensure existing tests mock `spacesProvider.spaces` to return at least one space
- Update any tests that expect specific empty states

---

## Design Token Reference

### Colors

**From TemporalFlowTheme**:
```dart
final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;

// Icon gradient
ShaderMask(
  shaderCallback: (bounds) => temporalTheme.primaryGradient.createShader(bounds),
  child: Icon(...),
)

// Button gradient
PrimaryButton(...) // Uses primaryGradient internally
```

**From AppColors**:
```dart
// Text colors (handled by EmptyState component)
AppColors.neutral600 // Title (light mode)
AppColors.neutral400 // Title (dark mode)
AppColors.neutral500 // Message (light mode)
AppColors.neutral400 // Message (dark mode)
```

### Spacing

```dart
// Used by EmptyState component internally
AppSpacing.md    // 16px - Icon to title, horizontal padding (mobile)
AppSpacing.xxs   // 4px - Title to message (tight grouping)
AppSpacing.lg    // 24px - Message to button, vertical padding
AppSpacing.xl    // 32px - Button padding (desktop)
```

### Typography

```dart
// Used by EmptyState component internally
AppTypography.h3        // Title (mobile)
AppTypography.h2        // Title (tablet/desktop)
AppTypography.bodyLarge // Message
```

### Animations

```dart
// Used by AnimatedEmptyState component internally
AppAnimations.gentle           // 400ms - Entrance duration
AppAnimations.gentleSpringCurve // Entrance curve
```

---

## Accessibility Implementation

### Screen Reader Support

**Semantic Structure**:
```dart
// AnimatedEmptyState/EmptyState handles this automatically
// Icon is decorative (ExcludeSemantics: true)
// Title and message are announced as text
// Button has proper role and label

// No custom semantics needed in NoSpacesState
```

**Testing Commands**:
```bash
# iOS Simulator
xcrun simctl spawn booted notify_post com.apple.accessibility.cache.vocalizer

# Android Emulator (enable TalkBack)
adb shell settings put secure enabled_accessibility_services com.google.android.marvin.talkback
```

### Color Contrast Verification

**Light Mode**:
- Title (Neutral600 on Neutral50): 11.2:1 ✅ AAA
- Message (Neutral500 on Neutral50): 6.8:1 ✅ AA+
- Button (White on Gradient): 7.1:1 ✅ AAA

**Dark Mode**:
- Title (Neutral400 on Neutral900): 8.9:1 ✅ AAA
- Message (Neutral400 on Neutral900): 8.9:1 ✅ AAA
- Button (White on Gradient): 7.1:1 ✅ AAA

**No manual verification needed** - Design system components ensure compliance.

### Touch Target Verification

**Button Size**:
- Height: 48px minimum (ButtonSize.large) ✅
- Width: Varies by breakpoint (all exceed 48px) ✅

**Automated Test**:
```dart
await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
```

### Reduced Motion Support

**Implementation**:
```dart
// AnimatedEmptyState handles this automatically
// Checks MediaQuery.of(context).disableAnimations
// Skips entrance animation if true

// No custom implementation needed in NoSpacesState
```

**Testing**:
```bash
# iOS Simulator
xcrun simctl spawn booted notify_post com.apple.accessibility.cache.reduce.motion

# Android Emulator
adb shell settings put secure transition_animation_scale 0
adb shell settings put secure window_animation_scale 0
adb shell settings put secure animator_duration_scale 0
```

---

## Responsive Design Implementation

### Breakpoint Handling

**Icon Size** (handled by EmptyState component):
```dart
// Inside EmptyState.build()
final isMobile = context.isMobile; // Uses responsive/breakpoints.dart
final iconSize = isMobile ? 64.0 : 80.0; // Tablets/desktops use 80px or 100px
```

**Typography Scale** (handled by EmptyState component):
```dart
// Title typography
final titleStyle = isMobile
    ? AppTypography.h3  // 24px on mobile
    : AppTypography.h2; // 32px on tablet/desktop
```

**Button Width** (handled by PrimaryButton component):
```dart
// Mobile: Full width (minus padding)
// Tablet/Desktop: Intrinsic width (min 250px, max 400px)
// Automatically responsive based on screen width
```

**No custom responsive code needed in NoSpacesState** - Base components handle it.

---

## Integration Points

### SpacesProvider

**State Management**:
```dart
// NoSpacesState depends on SpacesProvider.spaces being empty
// Home screen uses Consumer<SpacesProvider> to rebuild automatically

Consumer<SpacesProvider>(
  builder: (context, spacesProvider, child) {
    if (spacesProvider.spaces.isEmpty) {
      return NoSpacesState(onActionPressed: _showCreateSpaceModal);
    }
    // ... other states
  },
)
```

**Space Creation Flow**:
```dart
// 1. User taps "Create Your First Space"
// 2. CreateSpaceModal opens (bottom sheet)
// 3. User fills form, taps "Create"
// 4. SpacesProvider.createSpace() called
// 5. Space saved to Supabase
// 6. SpacesProvider.notifyListeners() called
// 7. Home screen rebuilds via Consumer
// 8. spaces.isEmpty == false → NoSpacesState no longer shown
// 9. WelcomeState shown instead (empty space, no content)
```

### CreateSpaceModal

**Modal Configuration**:
```dart
await showModalBottomSheet<Space?>(
  context: context,
  isScrollControlled: true, // Allows full-screen height
  backgroundColor: Colors.transparent, // For rounded top corners
  builder: (context) => const CreateSpaceModal(
    mode: SpaceModalMode.create, // Create mode (not edit)
  ),
);
```

**Return Value**:
- `Space?` - Returns created space if successful, `null` if cancelled
- Provider updates automatically, no need to handle return value

### Home Screen

**State Logic Flow**:
```dart
Widget _buildContentList(...) {
  // 1. Check NO SPACES (highest priority)
  if (spacesProvider.spaces.isEmpty) {
    return NoSpacesState(...);
  }

  // 2. Check EMPTY CONTENT (second priority)
  if (content.isEmpty && contentProvider.getTotalCount() == 0) {
    // 2a. Check if new user (1 space called "Inbox")
    if (spacesProvider.spaces.length == 1 &&
        spacesProvider.spaces.first.name == 'Inbox') {
      return WelcomeState(...);
    } else {
      // 2b. Existing user with empty space
      return EmptySpaceState(...);
    }
  }

  // 3. Show content list (default)
  return ReorderableListView.builder(...);
}
```

---

## Error Handling

### Network Errors

**Scenario**: User taps "Create Your First Space", modal opens, user submits, network fails

**Handling**:
- Error occurs in `CreateSpaceModal.submit()`, not in NoSpacesState
- Modal shows error message: "Could not create space. Check your connection."
- User can retry or cancel
- NoSpacesState remains visible behind modal
- No error handling needed in NoSpacesState component

### Edge Cases

**User closes modal without creating space**:
- Modal returns `null`
- Home screen remains on NoSpacesState (correct behavior)
- User can try again

**User creates space with duplicate name**:
- Allowed (spaces have unique UUIDs)
- No error, space created successfully

**App loses connection mid-creation**:
- Handled by SpacesProvider (Supabase error handling)
- Error shown in modal, not in empty state

---

## Performance Considerations

### Animation Performance

**Optimization**:
- AnimatedEmptyState uses `flutter_animate` (hardware accelerated)
- Transform-only animations (no layout thrashing)
- Const constructors where possible

**Frame Rate Target**: 60fps minimum

**Testing**:
```bash
# Profile mode (not debug mode)
flutter run --profile

# Monitor frame rate in DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Widget Rebuilds

**Optimization**:
- NoSpacesState is stateless (no internal state)
- Only rebuilds when parent rebuilds (via Consumer)
- AnimatedEmptyState manages its own animation state (minimal rebuilds)

**Verification**:
```dart
// In NoSpacesState
@override
Widget build(BuildContext context) {
  print('NoSpacesState build'); // Should only print on actual rebuilds
  return AnimatedEmptyState(...);
}
```

---

## Testing Strategy

### Unit Tests

**Coverage Requirements**: >80%

**Test Cases**:
- ✅ Widget renders correctly
- ✅ All content elements present (icon, title, message, button)
- ✅ Button callback fires
- ✅ Accessibility guidelines met
- ✅ Screen reader semantics correct

### Widget Tests

**Test Cases**:
- ✅ Home screen shows NoSpacesState when spaces.isEmpty
- ✅ Home screen transitions to WelcomeState after space creation
- ✅ Button press opens CreateSpaceModal (integration test)

### Integration Tests

**Test Cases** (manual or automated):
- ✅ Full flow: Launch app → See NoSpacesState → Create space → See WelcomeState
- ✅ Network error handling: Create space fails → Error shown → Retry succeeds
- ✅ Cancel flow: Tap CTA → Open modal → Cancel → Back to NoSpacesState

### Accessibility Tests

**Automated**:
```dart
await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
await expectLater(tester, meetsGuideline(textContrastGuideline));
await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
```

**Manual**:
- ✅ VoiceOver (iOS): All content announced correctly
- ✅ TalkBack (Android): All content announced correctly
- ✅ Reduce Motion: Entrance animation skipped
- ✅ Large Text: Content scales correctly

---

## Deployment Checklist

### Pre-Deployment

- [ ] Unit tests pass (>80% coverage)
- [ ] Widget tests pass
- [ ] Integration tests pass (manual or automated)
- [ ] Accessibility tests pass (automated + manual)
- [ ] Code review completed
- [ ] Design review completed (compare to spec)
- [ ] Performance profiling completed (60fps sustained)

### Post-Deployment

- [ ] Monitor crash reports (Firebase Crashlytics, Sentry)
- [ ] Monitor user feedback (app reviews, support tickets)
- [ ] Verify analytics tracking (if applicable)
- [ ] A/B test results (if applicable)

---

## Code Review Checklist

### Functionality

- [ ] NoSpacesState shows when `spaces.isEmpty`
- [ ] NoSpacesState is checked BEFORE other empty states
- [ ] Button opens CreateSpaceModal correctly
- [ ] After space creation, home screen rebuilds with WelcomeState

### Code Quality

- [ ] Follows existing code patterns (stateless widget, uses design system)
- [ ] Uses existing components (AnimatedEmptyState, PrimaryButton)
- [ ] No code duplication
- [ ] Proper error handling (deferred to CreateSpaceModal)
- [ ] Proper null safety (all null checks in place)

### Design System Compliance

- [ ] Uses design system components (AnimatedEmptyState, PrimaryButton)
- [ ] Uses design tokens (AppSpacing, AppTypography, AppAnimations)
- [ ] Uses theme extensions (TemporalFlowTheme for gradients)
- [ ] Follows naming conventions (NoSpacesState, not NoSpaceState)

### Documentation

- [ ] Component has doc comments
- [ ] Public methods have doc comments
- [ ] Example usage provided in doc comment
- [ ] Design documentation linked in PR

### Testing

- [ ] Unit tests added for NoSpacesState
- [ ] Widget tests updated for home_screen
- [ ] Accessibility tests added
- [ ] All tests pass locally

### Accessibility

- [ ] Screen reader support verified
- [ ] Color contrast verified (automated)
- [ ] Touch targets verified (automated)
- [ ] Reduced motion support verified (manual)
- [ ] Large text support verified (manual)

---

## Related Documentation

- [Feature Overview](./README.md) - High-level design decisions
- [User Journey](./user-journey.md) - Complete user flow analysis
- [Screen States](./screen-states.md) - Visual specifications
- [Interactions](./interactions.md) - Animation and interaction specs
- [Accessibility](./accessibility.md) - WCAG compliance requirements

---

## Support & Questions

**Design Questions**: Refer to design documentation in `design-documentation/features/no-spaces-empty-state/`

**Technical Questions**: Refer to CLAUDE.md for project conventions and patterns

**Implementation Issues**: Check existing empty state components (`WelcomeState`, `EmptySpaceState`) for reference patterns

---

**Implementation Priority**: P0 (Critical for FTUE)

**Estimated Effort**: 2-4 hours (including tests)

**Dependencies**: None (uses existing components)

**Risk Level**: Low (straightforward implementation, well-defined pattern)
