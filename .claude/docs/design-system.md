# Temporal Flow Design System

**Version:** 2.0.0
**Last Updated:** October 26, 2025
**Status:** Production Ready

---

## Table of Contents

1. [Overview](#overview)
2. [Atomic Design Structure](#atomic-design-structure)
3. [Design Tokens](#design-tokens)
4. [Component Library](#component-library)
5. [Usage Guide](#usage-guide)
6. [Adding New Components](#adding-new-components)
7. [Testing Guidelines](#testing-guidelines)
8. [Best Practices](#best-practices)
9. [Migration Notes](#migration-notes)

---

## Overview

The Temporal Flow Design System is built on **Atomic Design principles**, organizing components into a hierarchical structure that promotes reusability, consistency, and scalability.

### Key Principles

1. **Gradient-First Design**: Colors use gradients for depth and visual identity
2. **Glass Morphism**: Frosted glass effects create luminous depth
3. **Physics-Based Motion**: Spring animations for natural interactions
4. **Chromatic Intelligence**: Colors carry semantic meaning
5. **Atomic Organization**: Components organized from simple to complex

### Design System Goals

- **Consistency**: Unified UI/UX across the entire application
- **Efficiency**: Faster development with reusable components
- **Maintainability**: Single source of truth for design decisions
- **Scalability**: Easy to add new components following established patterns
- **Accessibility**: WCAG AA compliance built-in

---

## Atomic Design Structure

```
lib/design_system/
├── tokens/              # Design tokens (colors, typography, spacing, animations)
├── atoms/               # Basic building blocks
├── molecules/           # Simple combinations of atoms
├── organisms/           # Complex components
└── templates/           # Page-level layouts (future)
```

### When to Use Each Level

**Atoms**: Use for the smallest, indivisible UI elements
- Buttons, inputs, icons, text styles, loading indicators

**Molecules**: Use for simple, functional combinations of atoms
- Search bars (input + icon), form fields (label + input + error), labeled buttons

**Organisms**: Use for complex, standalone sections
- Cards, navigation bars, modals, empty states, complete forms

**Templates**: Use for page-level layouts (not yet implemented)
- Screen scaffolds, responsive layouts, navigation wrappers

---

## Design Tokens

Design tokens are the visual design atoms of the design system — specifically, they are named entities that store visual design attributes.

### Location

```
lib/design_system/tokens/
├── colors.dart          # AppColors
├── typography.dart      # AppTypography
├── spacing.dart         # AppSpacing
├── animations.dart      # AppAnimations
└── tokens.dart          # Barrel file (exports all)
```

### Usage

```dart
// Import all tokens at once
import 'package:later_mobile/design_system/tokens/tokens.dart';

// Use tokens
Container(
  padding: const EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
  ),
  child: Text(
    'Hello World',
    style: AppTypography.h3,
  ),
)
```

### Token Categories

**Colors** (`AppColors`):
- Primary/Secondary gradients and solids
- Type-specific colors (task, note, list)
- Semantic colors (success, error, warning, info)
- Surface colors (background, card, border)
- Text colors with proper contrast

**Typography** (`AppTypography`):
- Display styles (h1, h2, h3, h4, h5)
- Body styles (bodyLarge, bodyMedium, bodySmall)
- Specialized styles (label, caption, code)
- All styles are theme-aware (light/dark)

**Spacing** (`AppSpacing`):
- Size tokens (xs, sm, md, lg, xl, xxl, xxxl)
- Radius tokens (radiusSm, radiusMd, radiusLg)
- Icon sizes (iconSm, iconMd, iconLg)
- Based on 4px grid system

**Animations** (`AppAnimations`):
- Durations (fast, medium, slow)
- Curves (easeInOut, spring, bounce)
- Haptic feedback patterns
- Respect reduced motion preferences

---

## Component Library

### Atoms

#### Buttons

**Location**: `lib/design_system/atoms/buttons/`

**Components**:
- `PrimaryButton` - Primary CTAs with gradient background
- `SecondaryButton` - Secondary actions with gradient border
- `GhostButton` - Low-emphasis actions, transparent background
- `DangerButton` - Destructive actions with red gradient
- `ThemeToggleButton` - Theme switching control
- `GradientButton` - Legacy (consider deprecating)

**Sizes**: `small` (36px), `medium` (44px), `large` (52px)

**Example**:
```dart
import 'package:later_mobile/design_system/atoms/buttons/primary_button.dart';

PrimaryButton(
  text: 'Save Changes',
  onPressed: () => _save(),
  size: ButtonSize.medium,
  isLoading: _isSaving,
)
```

#### Inputs

**Location**: `lib/design_system/atoms/inputs/`

**Components**:
- `TextInputField` - Single-line text input with glass design
- `TextAreaField` - Multi-line text input with glass design

**Features**:
- Optional labels
- Error states with validation messages
- Character counters with gradient warnings
- Prefix/suffix icons
- Auto-focus support
- Keyboard action handling

**Example**:
```dart
import 'package:later_mobile/design_system/atoms/inputs/text_input_field.dart';

TextInputField(
  label: 'Email',
  controller: _emailController,
  hintText: 'Enter your email',
  prefixIcon: Icons.email,
  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
  keyboardType: TextInputType.emailAddress,
)
```

#### Text

**Location**: `lib/design_system/atoms/text/`

**Components**:
- `GradientText` - Text with gradient fill

**Available Gradients**:
- `AppColors.primaryGradient`
- `AppColors.secondaryGradient`
- `AppColors.taskGradient`
- `AppColors.noteGradient`
- `AppColors.listGradient`

**Example**:
```dart
import 'package:later_mobile/design_system/atoms/text/gradient_text.dart';

GradientText(
  'Later',
  gradient: AppColors.primaryGradient,
  style: AppTypography.h1,
)
```

#### Loading

**Location**: `lib/design_system/atoms/loading/`

**Components**:
- `SkeletonLine` - Animated loading line
- `SkeletonBox` - Animated loading box
- `GradientSpinner` - Circular progress with gradient

**Example**:
```dart
import 'package:later_mobile/design_system/atoms/loading/gradient_spinner.dart';

if (_isLoading) GradientSpinner()
```

---

### Molecules

#### Loading

**Location**: `lib/design_system/molecules/loading/`

**Components**:
- `SkeletonLoader` - Configurable skeleton loader with multiple shapes
- `SkeletonCard` - Pre-configured skeleton for item cards

**Example**:
```dart
import 'package:later_mobile/design_system/molecules/loading/skeleton_loader.dart';

SkeletonLoader(
  shape: SkeletonShape.card,
  count: 3,
)
```

#### FAB

**Location**: `lib/design_system/molecules/fab/`

**Components**:
- `QuickCaptureFab` - Quick capture floating action button with gradient

**Example**:
```dart
import 'package:later_mobile/design_system/molecules/fab/quick_capture_fab.dart';

QuickCaptureFab(
  onPressed: () => _showQuickCapture(),
)
```

---

### Organisms

#### Cards

**Location**: `lib/design_system/organisms/cards/`

**Components**:
- `TodoItemCard` - Todo item display with checkbox
- `TodoListCard` - Todo list summary card
- `NoteCard` - Note preview card
- `ListCard` - List summary card
- `ListItemCard` - Generic list item card
- `ItemCard` - Base item card

**Features**:
- Type-specific color coding
- Swipe actions support
- Completion states
- Due date indicators
- Priority badges

**Example**:
```dart
import 'package:later_mobile/design_system/organisms/cards/todo_item_card.dart';

TodoItemCard(
  title: 'Complete design system docs',
  isCompleted: false,
  priority: Priority.high,
  dueDate: DateTime.now().add(Duration(days: 1)),
  onTap: () => _viewDetails(),
  onComplete: () => _markComplete(),
)
```

#### Modals

**Location**: `lib/design_system/organisms/modals/`

**Components**:
- `BottomSheetContainer` - Glass morphism bottom sheet wrapper

**Example**:
```dart
import 'package:later_mobile/design_system/organisms/modals/bottom_sheet_container.dart';

showModalBottomSheet(
  context: context,
  builder: (context) => BottomSheetContainer(
    title: 'Edit Item',
    child: YourContentWidget(),
  ),
)
```

#### Dialogs

**Location**: `lib/design_system/organisms/dialogs/`

**Components**:
- `DeleteConfirmationDialog` - Reusable delete confirmation
- `ErrorDialog` - Error display dialog

**Example**:
```dart
import 'package:later_mobile/design_system/organisms/dialogs/delete_confirmation_dialog.dart';

final confirmed = await showDeleteConfirmationDialog(
  context: context,
  title: 'Delete Note',
  message: 'Are you sure you want to delete "${note.title}"? This cannot be undone.',
);

if (confirmed) {
  // Perform delete
}
```

#### Empty States

**Location**: `lib/design_system/organisms/empty_states/`

**Components**:
- `EmptyState` - Generic empty state with icon and action
- `WelcomeState` - Welcome message for new users
- `EmptySpaceState` - Empty space indicator
- `EmptySearchState` - No search results found

**Example**:
```dart
import 'package:later_mobile/design_system/organisms/empty_states/empty_state.dart';

if (items.isEmpty)
  EmptyState(
    icon: Icons.inbox,
    title: 'No items yet',
    message: 'Create your first item to get started',
    actionText: 'Create Item',
    onAction: () => _showCreateDialog(),
  )
```

---

## Usage Guide

### Importing Components

**Option 1: Import specific component**
```dart
import 'package:later_mobile/design_system/atoms/buttons/primary_button.dart';
```

**Option 2: Import entire layer**
```dart
import 'package:later_mobile/design_system/atoms/atoms.dart';
// Now you have access to all atoms
```

**Option 3: Import entire design system**
```dart
import 'package:later_mobile/design_system/design_system.dart';
// Now you have access to tokens + all components
```

### Common Patterns

#### Form with Validation

```dart
import 'package:later_mobile/design_system/atoms/atoms.dart';

Column(
  children: [
    TextInputField(
      label: 'Title',
      controller: _titleController,
      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
    ),
    const SizedBox(height: AppSpacing.md),
    TextAreaField(
      label: 'Description',
      controller: _descController,
      minLines: 3,
      maxLines: 6,
    ),
    const SizedBox(height: AppSpacing.lg),
    Row(
      children: [
        Expanded(
          child: GhostButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: PrimaryButton(
            text: 'Save',
            onPressed: _save,
            isLoading: _isSaving,
          ),
        ),
      ],
    ),
  ],
)
```

#### Delete Confirmation Flow

```dart
import 'package:later_mobile/design_system/organisms/organisms.dart';

Future<void> _deleteItem() async {
  final confirmed = await showDeleteConfirmationDialog(
    context: context,
    title: 'Delete Item',
    message: 'Are you sure? This cannot be undone.',
  );

  if (confirmed) {
    await _performDelete();
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
```

#### Loading States

```dart
import 'package:later_mobile/design_system/molecules/molecules.dart';

Widget build(BuildContext context) {
  if (_isLoading) {
    return SkeletonLoader(
      shape: SkeletonShape.card,
      count: 5,
    );
  }

  return ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) => ItemCard(item: items[index]),
  );
}
```

---

## Adding New Components

### Decision Tree

1. **Is it a single, indivisible element?** → Create an Atom
   - Examples: Button variant, icon, badge, chip

2. **Is it a simple combination of 2-3 atoms?** → Create a Molecule
   - Examples: Search bar (input + icon), labeled button, form field

3. **Is it a complex, standalone section?** → Create an Organism
   - Examples: Navigation bar, card with multiple elements, modal

### Steps to Add a New Component

#### 1. Choose the Right Layer

Follow the decision tree above to determine if your component is an atom, molecule, or organism.

#### 2. Create the Component File

```dart
// lib/design_system/atoms/buttons/my_new_button.dart

import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

/// Brief description of what this button does
class MyNewButton extends StatelessWidget {
  const MyNewButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = ButtonSize.medium,
  });

  final String text;
  final VoidCallback? onPressed;
  final ButtonSize size;

  @override
  Widget build(BuildContext context) {
    // Implementation
  }
}
```

#### 3. Add to Barrel File

Update the appropriate barrel file to export your new component:

```dart
// lib/design_system/atoms/buttons/buttons.dart
export 'my_new_button.dart';
```

#### 4. Write Tests

```dart
// test/widgets/components/buttons/my_new_button_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/atoms/buttons/my_new_button.dart';

void main() {
  group('MyNewButton', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyNewButton(
              text: 'Test',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyNewButton(
              text: 'Test',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MyNewButton));
      expect(pressed, isTrue);
    });
  });
}
```

#### 5. Add to Component Showcase

Update `lib/widgets/screens/component_showcase_screen.dart` to include your new component in the appropriate section.

#### 6. Document Usage

Add examples to this documentation file showing how to use your new component.

---

## Testing Guidelines

### Component Tests

All components should have comprehensive widget tests covering:

1. **Rendering**: Component displays correctly with default props
2. **States**: All states render correctly (loading, disabled, error, etc.)
3. **Interactions**: User interactions trigger expected behaviors
4. **Accessibility**: Semantic labels and screen reader support
5. **Theming**: Works in both light and dark mode

### Test Structure

```dart
group('ComponentName', () {
  group('Rendering', () {
    testWidgets('renders with default props', (tester) async { ... });
    testWidgets('renders with custom props', (tester) async { ... });
  });

  group('States', () {
    testWidgets('shows loading state', (tester) async { ... });
    testWidgets('shows disabled state', (tester) async { ... });
    testWidgets('shows error state', (tester) async { ... });
  });

  group('Interactions', () {
    testWidgets('handles tap', (tester) async { ... });
    testWidgets('handles long press', (tester) async { ... });
  });

  group('Accessibility', () {
    testWidgets('has semantic labels', (tester) async { ... });
    testWidgets('meets contrast requirements', (tester) async { ... });
  });
});
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widgets/components/buttons/primary_button_test.dart

# Run tests with coverage
flutter test --coverage
```

---

## Best Practices

### DO

✅ **Use design tokens for all styling**
```dart
// Good
Container(
  padding: const EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
  ),
)
```

✅ **Use const constructors when possible**
```dart
// Good
const PrimaryButton(
  text: 'Save',
  onPressed: null,
)
```

✅ **Import from barrel files for cleaner code**
```dart
// Good
import 'package:later_mobile/design_system/atoms/atoms.dart';
```

✅ **Follow existing component APIs**
```dart
// Good - consistent with other buttons
DangerButton(
  text: 'Delete',
  onPressed: _delete,
  size: ButtonSize.medium,
)
```

✅ **Write comprehensive tests**
```dart
// Good - test all states and interactions
testWidgets('shows loading state', (tester) async { ... });
testWidgets('handles disabled state', (tester) async { ... });
```

### DON'T

❌ **Don't use hardcoded colors**
```dart
// Bad
Container(color: Color(0xFF6366F1))

// Good
Container(color: AppColors.primaryStart)
```

❌ **Don't use hardcoded spacing**
```dart
// Bad
Padding(padding: const EdgeInsets.all(16))

// Good
Padding(padding: const EdgeInsets.all(AppSpacing.md))
```

❌ **Don't create inline widgets when components exist**
```dart
// Bad
ElevatedButton(
  onPressed: _save,
  child: Text('Save'),
)

// Good
PrimaryButton(
  text: 'Save',
  onPressed: _save,
)
```

❌ **Don't skip testing**
```dart
// Bad - no tests for new component

// Good - comprehensive test coverage
group('MyNewComponent', () { ... });
```

❌ **Don't mix old and new import paths**
```dart
// Bad
import '../widgets/components/buttons/primary_button.dart';

// Good
import 'package:later_mobile/design_system/atoms/buttons/primary_button.dart';
```

---

## Migration Notes

### Phase 1: Component Consolidation ✅

**Completed**: October 26, 2025

- Replaced 16 inline TextFields with TextInputField/TextAreaField
- Replaced 17 inline buttons with PrimaryButton/SecondaryButton/GhostButton/DangerButton
- Created DeleteConfirmationDialog (replaced 5 instances)
- Enhanced TextInputField with optional labels, focusNode, textCapitalization
- Total: 641 lines of duplicated code eliminated

### Phase 2: Atomic Design Restructure ✅

**Completed**: October 26, 2025

- Created design_system folder structure (tokens/, atoms/, molecules/, organisms/)
- Moved design tokens from lib/core/theme/ to design_system/tokens/
- Categorized and moved 31 components to atomic structure
- Created barrel files for all layers
- Updated 64 files (39 lib + 25 test) to use new import paths
- Created component showcase screen (866 lines)
- Created comprehensive design system documentation

**Component Distribution**:
- **Atoms**: 13 components (buttons, inputs, text, borders, loading)
- **Molecules**: 3 components (loading, fab)
- **Organisms**: 15 components (cards, modals, dialogs, empty states, error)

### Old Component Location

Old components remain at `lib/widgets/components/` until full migration is verified. They will be removed in a future cleanup.

**DO NOT** import from the old location. Always use:
```dart
import 'package:later_mobile/design_system/[layer]/[category]/[component].dart';
```

---

## Component Showcase

The design system includes a component showcase screen for visual testing and documentation.

**Access**: Navigate to `ComponentShowcaseScreen`

**Features**:
- Visual display of all components
- Interactive examples
- Light/dark mode toggle
- Code snippets for each component
- Organized by atomic level

**Usage**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ComponentShowcaseScreen(),
  ),
);
```

---

## API Design Conventions

When creating new components, follow these conventions:

### Required vs Optional Parameters

```dart
class MyComponent extends StatelessWidget {
  const MyComponent({
    super.key,
    required this.title,        // Always required
    this.subtitle,               // Optional, nullable
    this.onTap,                  // Optional callback
    this.size = ComponentSize.medium,  // Optional with default
  });
}
```

### Naming Conventions

- **Components**: PascalCase (e.g., `PrimaryButton`, `TextInputField`)
- **Files**: snake_case (e.g., `primary_button.dart`, `text_input_field.dart`)
- **Parameters**: camelCase (e.g., `onPressed`, `isLoading`, `backgroundColor`)
- **Enums**: PascalCase for type, camelCase for values (e.g., `ButtonSize.medium`)

### Callbacks

```dart
// Simple action
final VoidCallback? onPressed;

// Action with value
final ValueChanged<String>? onChanged;

// Async action
final Future<void> Function()? onSave;

// Action with result
final Future<bool> Function()? onConfirm;
```

### Size Variants

```dart
enum ComponentSize {
  small,   // Compact variant
  medium,  // Default variant (most common)
  large,   // Prominent variant
}
```

---

## Resources

### Design Documentation

- **Style Guide**: `/design-documentation/design-system/style-guide.md`
- **Component Specs**: `/design-documentation/design-system/components/`
- **Design Summary**: `/DESIGN-SYSTEM-SUMMARY.md`
- **Implementation Guide**: `/design-documentation/IMPLEMENTATION-GUIDE.md`

### Code References

- **Design System**: `lib/design_system/`
- **Design Tokens**: `lib/design_system/tokens/`
- **Component Showcase**: `lib/widgets/screens/component_showcase_screen.dart`
- **Tests**: `test/widgets/components/`

### External Resources

- [Atomic Design Methodology](https://atomicdesign.bradfrost.com/)
- [Flutter Widget Catalog](https://docs.flutter.dev/ui/widgets)
- [Material Design 3](https://m3.material.io/)

---

## Version History

**v2.0.0** (October 26, 2025) - Atomic Design Restructure
- Reorganized components into atomic design structure
- Created design_system folder with tokens/, atoms/, molecules/, organisms/
- Updated all imports to use new structure
- Created component showcase screen
- Comprehensive documentation

**v1.0.0** (October 26, 2025) - Component Consolidation
- Replaced inline TextFields with reusable components
- Replaced inline buttons with reusable components
- Created DeleteConfirmationDialog
- Enhanced TextInputField and TextAreaField
- Eliminated 641 lines of duplicated code

---

## Support

For questions or issues with the design system:

1. Check this documentation first
2. Review the component showcase for usage examples
3. Examine existing components for patterns
4. Consult the design system summary for principles
5. Create an issue or discussion in the project

---

**Design System Maintainer**: Claude Code
**Last Review**: October 26, 2025
**Next Review**: As needed based on component additions

---

**Happy Building! 🎨✨**
