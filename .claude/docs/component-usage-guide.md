# Component Library Usage Guide

## Overview

This guide provides comprehensive documentation for the Later app's reusable component library. The component library was created to improve code consistency, maintainability, and reduce duplication across the application.

### Benefits

- **Consistency**: All UI elements follow the Temporal Flow design system with consistent styling, animations, and behavior
- **Maintainability**: Changes to component APIs propagate automatically across all usage locations
- **Reduced Code**: Eliminated ~641 lines of duplicated styling and configuration code
- **Developer Experience**: Clear, well-documented APIs make building features faster and more intuitive
- **Accessibility**: Built-in semantic markup, focus management, and screen reader support

### Related Documentation

- [Component Library Refactoring Plan](../plans/component-library-refactoring.md)
- [Design System Summary](../../DESIGN-SYSTEM-SUMMARY.md)

---

## Button Components

All button components share a consistent API and support the following features:

- Three sizes: `ButtonSize.small` (36px), `ButtonSize.medium` (44px), `ButtonSize.large` (52px)
- Spring press animation (scale 1.0 → 0.92)
- Loading state with spinner
- Disabled state (40% opacity)
- Optional icon support
- Haptic feedback on mobile
- Full width expansion via `isExpanded` parameter
- Accessibility: semantic labels and focus indicators

### PrimaryButton

**When to Use**: Primary call-to-action buttons for the most important action on a screen or modal.

**Visual Design**: Gradient background (adapts to light/dark mode), white text, soft shadows

**Common Use Cases**:
- Submit/Save buttons in forms
- Create buttons (Create Space, Add Item)
- Primary action in modals and dialogs
- Confirm actions

**API Parameters**:

```dart
PrimaryButton({
  required String text,              // Button label
  required VoidCallback? onPressed,  // Tap handler (null = disabled)
  IconData? icon,                    // Optional leading icon
  ButtonSize size = ButtonSize.medium,
  bool isLoading = false,            // Show loading spinner
  bool isExpanded = false,           // Full width
})
```

**Examples**:

```dart
// Basic primary button
PrimaryButton(
  text: 'Save',
  onPressed: () => _handleSave(),
)

// With icon
PrimaryButton(
  text: 'Create Space',
  icon: Icons.add,
  onPressed: () => _handleCreateSpace(),
)

// Loading state
PrimaryButton(
  text: 'Saving...',
  isLoading: true,
  onPressed: null, // Disabled during loading
)

// Disabled state
PrimaryButton(
  text: 'Submit',
  onPressed: _isFormValid ? () => _handleSubmit() : null,
)

// Full width (common in modals)
PrimaryButton(
  text: 'Continue',
  onPressed: () => _handleContinue(),
  isExpanded: true,
)

// Large size for emphasis
PrimaryButton(
  text: 'Get Started',
  size: ButtonSize.large,
  onPressed: () => _handleStart(),
)
```

---

### SecondaryButton

**When to Use**: Supporting actions that are important but not the primary focus.

**Visual Design**: Gradient border (50% opacity), transparent background with glass hover effect, gradient-colored text

**Common Use Cases**:
- Cancel buttons in modals (paired with PrimaryButton)
- Alternative actions
- Navigation to secondary flows
- Edit or modify actions

**API Parameters**:

```dart
SecondaryButton({
  required String text,
  required VoidCallback? onPressed,
  IconData? icon,
  ButtonSize size = ButtonSize.medium,
  bool isLoading = false,
  bool isExpanded = false,
})
```

**Examples**:

```dart
// Modal button pair (common pattern)
Row(
  children: [
    Expanded(
      child: SecondaryButton(
        text: 'Cancel',
        onPressed: () => Navigator.pop(context),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: PrimaryButton(
        text: 'Save',
        onPressed: () => _handleSave(),
      ),
    ),
  ],
)

// With icon
SecondaryButton(
  text: 'Edit',
  icon: Icons.edit_outlined,
  onPressed: () => _handleEdit(),
)

// Loading state
SecondaryButton(
  text: 'Processing...',
  isLoading: true,
  onPressed: null,
)
```

---

### DangerButton

**When to Use**: Destructive actions that delete or permanently remove data.

**Visual Design**: Red error gradient background, white text, prominent appearance to signal caution

**Common Use Cases**:
- Delete operations (Delete Item, Remove Space)
- Permanently destructive actions (Clear All Data)
- Actions that cannot be easily undone
- Confirmation dialogs for destructive operations

**API Parameters**:

```dart
DangerButton({
  required String text,
  required VoidCallback? onPressed,
  IconData? icon,
  ButtonSize size = ButtonSize.medium,
  bool isLoading = false,
  bool isExpanded = false,
})
```

**Examples**:

```dart
// Basic delete button
DangerButton(
  text: 'Delete',
  onPressed: () => _handleDelete(),
)

// With icon
DangerButton(
  text: 'Delete Item',
  icon: Icons.delete_outline,
  onPressed: () => _showDeleteConfirmation(),
)

// In confirmation dialog (see DeleteConfirmationDialog component)
DangerButton(
  text: 'Delete Space',
  onPressed: () => _confirmDelete(),
)

// Loading state during deletion
DangerButton(
  text: 'Deleting...',
  isLoading: true,
  onPressed: null,
)

// Full width in modal
DangerButton(
  text: 'Remove Account',
  isExpanded: true,
  onPressed: () => _handleRemoveAccount(),
)
```

---

### GhostButton

**When to Use**: Low-emphasis actions, tertiary actions, or dismissal actions.

**Visual Design**: Transparent background, gradient text color, subtle 5% overlay on hover

**Common Use Cases**:
- Cancel buttons in dialogs (non-modal contexts)
- Tertiary actions (Skip, Dismiss, Not Now)
- Navigation back actions
- Low-priority options

**API Parameters**:

```dart
GhostButton({
  required String text,
  required VoidCallback? onPressed,
  IconData? icon,
  ButtonSize size = ButtonSize.medium,
  bool isLoading = false,
  bool isExpanded = false,
})
```

**Examples**:

```dart
// Cancel in dialog
GhostButton(
  text: 'Cancel',
  onPressed: () => Navigator.pop(context),
)

// With icon
GhostButton(
  text: 'Skip',
  icon: Icons.arrow_forward,
  onPressed: () => _handleSkip(),
)

// Small size for compact layouts
GhostButton(
  text: 'Dismiss',
  size: ButtonSize.small,
  onPressed: () => _handleDismiss(),
)

// In DeleteConfirmationDialog
actions: [
  GhostButton(
    text: 'Cancel',
    onPressed: () => Navigator.of(context).pop(false),
  ),
  DangerButton(
    text: 'Delete',
    onPressed: () => Navigator.of(context).pop(true),
  ),
]
```

---

## Input Components

### TextInputField

**When to Use**: Single-line text inputs (names, titles, search fields, email, etc.)

**Visual Design**: Glass background (3% opacity), gradient border on focus (30% opacity), glass overlay effect (5%), focus shadow with gradient tint, smooth 200ms transitions

**Features**:
- Optional label (omit for search fields or quick capture)
- Character counter with gradient warning (>80% capacity)
- Error state with red gradient border
- Focus management via `focusNode`
- Text capitalization control
- Prefix/suffix icon support
- Auto-focus capability
- Keyboard action customization

**API Parameters**:

```dart
TextInputField({
  String? label,                    // Optional field label
  String? hintText,                 // Placeholder text
  TextEditingController? controller,
  String? initialValue,             // If controller not provided
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onSubmitted,
  FormFieldValidator<String>? validator,
  String? errorText,                // Error message to display
  bool enabled = true,
  bool obscureText = false,         // For passwords
  bool autofocus = false,
  TextInputType? keyboardType,
  TextInputAction? textInputAction,
  int? maxLength,                   // Shows character counter
  int maxLines = 1,
  IconData? prefixIcon,
  IconData? suffixIcon,
  VoidCallback? onSuffixIconPressed,
  FocusNode? focusNode,             // External focus control
  TextCapitalization textCapitalization = TextCapitalization.none,
})
```

**Examples**:

```dart
// Form field with label
TextInputField(
  label: 'Space Name',
  hintText: 'Enter a name for your space',
  controller: _nameController,
)

// Search field without label
TextInputField(
  hintText: 'Search spaces...',
  prefixIcon: Icons.search,
  controller: _searchController,
  onChanged: (value) => _performSearch(value),
)

// With character limit and counter
TextInputField(
  label: 'Title',
  hintText: 'Enter title',
  controller: _titleController,
  maxLength: 100,  // Shows "45 / 100" counter
)

// With error state
TextInputField(
  label: 'Email',
  hintText: 'you@example.com',
  controller: _emailController,
  errorText: _emailError,  // Shows red gradient border
  keyboardType: TextInputType.emailAddress,
)

// With external focus control
final _focusNode = FocusNode();

TextInputField(
  hintText: 'Quick capture',
  controller: _controller,
  focusNode: _focusNode,  // Can call _focusNode.requestFocus()
  autofocus: true,
  textInputAction: TextInputAction.done,
)

// With text capitalization (for names/titles)
TextInputField(
  label: 'Name',
  hintText: 'Enter your name',
  controller: _nameController,
  textCapitalization: TextCapitalization.words,
)

// Password field
TextInputField(
  label: 'Password',
  hintText: 'Enter password',
  controller: _passwordController,
  obscureText: true,
  suffixIcon: _showPassword ? Icons.visibility_off : Icons.visibility,
  onSuffixIconPressed: () => setState(() => _showPassword = !_showPassword),
)

// Disabled state
TextInputField(
  label: 'Generated ID',
  controller: _idController,
  enabled: false,  // Grayed out
)
```

---

### TextAreaField

**When to Use**: Multi-line text inputs (descriptions, notes, long-form content)

**Visual Design**: Same as TextInputField but optimized for multi-line content with vertical padding (16px vs 12px)

**Features**:
- All TextInputField features
- Configurable min/max lines
- Auto-expanding support (set `maxLines: null`)
- Optimized padding for readability
- Multi-line keyboard type
- Newline text input action

**API Parameters**:

```dart
TextAreaField({
  String? label,
  String? hintText,
  TextEditingController? controller,
  String? initialValue,
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onSubmitted,
  FormFieldValidator<String>? validator,
  String? errorText,
  bool enabled = true,
  bool autofocus = false,
  int? maxLength,
  int minLines = 3,                 // Minimum visible lines
  int? maxLines = 8,                // null = unlimited auto-expand
  FocusNode? focusNode,
  TextCapitalization textCapitalization = TextCapitalization.none,
})
```

**Examples**:

```dart
// Basic text area with fixed height
TextAreaField(
  label: 'Description',
  hintText: 'Enter a description...',
  controller: _descriptionController,
  minLines: 3,
  maxLines: 5,
)

// Auto-expanding text area
TextAreaField(
  label: 'Notes',
  hintText: 'Add your notes here...',
  controller: _notesController,
  minLines: 5,
  maxLines: null,  // Expands as user types
)

// With character limit
TextAreaField(
  label: 'Content',
  hintText: 'Write your content...',
  controller: _contentController,
  maxLength: 500,  // Shows "245 / 500" counter
  minLines: 4,
  maxLines: 10,
)

// Quick capture (no label)
TextAreaField(
  hintText: 'What\'s on your mind?',
  controller: _captureController,
  autofocus: true,
  minLines: 3,
  maxLines: null,  // Auto-expand
  textCapitalization: TextCapitalization.sentences,
)

// With error state
TextAreaField(
  label: 'Description',
  hintText: 'Enter description',
  controller: _descriptionController,
  errorText: 'Description is required',
  minLines: 3,
  maxLines: 6,
)

// Compact single-line to multi-line
TextAreaField(
  hintText: 'Add a note',
  controller: _noteController,
  minLines: 1,  // Starts small
  maxLines: 8,  // Expands up to 8 lines
)
```

---

## Dialog Components

### DeleteConfirmationDialog

**When to Use**: Any destructive action requiring user confirmation before proceeding.

**Function**: `showDeleteConfirmationDialog()`

**Features**:
- Standard AlertDialog with component buttons
- Returns `true` (confirmed), `false` (cancelled), or `null` (dismissed)
- Customizable title and message
- Customizable confirm button text (defaults to "Delete")
- Consistent styling across all delete operations
- Async/await pattern for result handling

**API Parameters**:

```dart
Future<bool?> showDeleteConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmButtonText = 'Delete',
})
```

**Return Values**:
- `true`: User confirmed deletion
- `false`: User cancelled
- `null`: Dialog dismissed (tapped outside)

**Examples**:

```dart
// Basic usage
final confirmed = await showDeleteConfirmationDialog(
  context: context,
  title: 'Delete Item?',
  message: 'This action cannot be undone.',
);

if (confirmed == true) {
  await _deleteItem();
}

// Custom confirm button text
final confirmed = await showDeleteConfirmationDialog(
  context: context,
  title: 'Remove Space?',
  message: 'All items in this space will also be removed.',
  confirmButtonText: 'Remove',
);

// Handle all cases
final result = await showDeleteConfirmationDialog(
  context: context,
  title: 'Delete Todo List?',
  message: 'This will permanently delete the list and all its tasks.',
);

if (result == true) {
  // User confirmed - proceed with deletion
  await _performDelete();
  Navigator.pop(context);
} else if (result == false) {
  // User cancelled - do nothing
  print('Delete cancelled');
} else {
  // Dialog dismissed (null) - do nothing
  print('Dialog dismissed');
}

// With error handling
try {
  final confirmed = await showDeleteConfirmationDialog(
    context: context,
    title: 'Delete Note?',
    message: 'This note will be permanently deleted.',
  );

  if (confirmed == true) {
    await _deleteNote();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note deleted')),
      );
    }
  }
} catch (e) {
  // Handle error
  print('Delete error: $e');
}
```

---

## Before/After Examples

Real examples from the Phase 1 refactoring showing the improvements.

### Example 1: TextField Replacement (QuickCaptureModal)

**Before**:
```dart
// Inline TextField with custom styling (~50 lines)
TextField(
  controller: _textController,
  focusNode: _focusNode,
  autofocus: true,
  maxLines: null,
  textCapitalization: TextCapitalization.sentences,
  style: AppTypography.input.copyWith(
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
  ),
  decoration: InputDecoration(
    hintText: 'What\'s on your mind?',
    hintStyle: AppTypography.input.copyWith(
      color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
          .withOpacity(0.6),
    ),
    border: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 12.0,
      vertical: 16.0,
    ),
  ),
  // ... additional configuration
)
```

**After**:
```dart
// Reusable component (~5 lines)
TextAreaField(
  hintText: 'What\'s on your mind?',
  controller: _textController,
  focusNode: _focusNode,
  autofocus: true,
  minLines: 3,
  maxLines: null,
  textCapitalization: TextCapitalization.sentences,
)
```

**Result**: 90% code reduction, automatic design system compliance, consistent behavior

---

### Example 2: Button Replacement (CreateSpaceModal)

**Before**:
```dart
// Inline ElevatedButton with custom styling (~35 lines)
ElevatedButton(
  onPressed: _isLoading ? null : _handleCreate,
  style: ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 44),
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    padding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
    ),
  ),
  child: Ink(
    decoration: BoxDecoration(
      gradient: isDark
          ? AppColors.primaryGradientDark
          : AppColors.primaryGradient,
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
    ),
    child: Container(
      height: 44,
      alignment: Alignment.center,
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Create Space', style: TextStyle(color: Colors.white)),
    ),
  ),
)
```

**After**:
```dart
// Reusable component (~5 lines)
PrimaryButton(
  text: 'Create Space',
  onPressed: _handleCreate,
  isLoading: _isLoading,
  isExpanded: true,
)
```

**Result**: 85% code reduction, automatic animations, consistent haptic feedback

---

### Example 3: Delete Dialog Replacement (ListDetailScreen)

**Before**:
```dart
// Inline AlertDialog implementation (~25 lines)
final confirmed = await showDialog<bool>(
  context: context,
  builder: (context) {
    return AlertDialog(
      title: const Text('Delete List?'),
      content: const Text('This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
          ),
          child: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  },
);
```

**After**:
```dart
// Reusable function (~4 lines)
final confirmed = await showDeleteConfirmationDialog(
  context: context,
  title: 'Delete List?',
  message: 'This action cannot be undone.',
);
```

**Result**: 80% code reduction, consistent button styling, automatic design system compliance

---

## Common Patterns

### Pattern 1: Form with Validation

```dart
class CreateItemForm extends StatefulWidget {
  @override
  State<CreateItemForm> createState() => _CreateItemFormState();
}

class _CreateItemFormState extends State<CreateItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _titleError;
  bool _isLoading = false;

  void _handleSubmit() async {
    // Validate
    setState(() => _titleError = null);

    if (_titleController.text.trim().isEmpty) {
      setState(() => _titleError = 'Title is required');
      return;
    }

    // Submit
    setState(() => _isLoading = true);
    try {
      await _createItem();
      Navigator.pop(context);
    } catch (e) {
      setState(() => _titleError = 'Failed to create item');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextInputField(
          label: 'Title',
          hintText: 'Enter item title',
          controller: _titleController,
          errorText: _titleError,
          maxLength: 100,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        TextAreaField(
          label: 'Description',
          hintText: 'Add details...',
          controller: _descriptionController,
          minLines: 3,
          maxLines: 6,
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          text: 'Create Item',
          onPressed: _handleSubmit,
          isLoading: _isLoading,
          isExpanded: true,
        ),
      ],
    );
  }
}
```

---

### Pattern 2: Modal with Primary + Secondary Actions

```dart
// Standard modal button layout
Padding(
  padding: const EdgeInsets.all(16),
  child: Row(
    children: [
      Expanded(
        child: SecondaryButton(
          text: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: PrimaryButton(
          text: 'Save',
          onPressed: _handleSave,
          isLoading: _isSaving,
        ),
      ),
    ],
  ),
)
```

---

### Pattern 3: Delete with Confirmation

```dart
Future<void> _handleDelete() async {
  final confirmed = await showDeleteConfirmationDialog(
    context: context,
    title: 'Delete ${widget.item.name}?',
    message: 'This action cannot be undone.',
  );

  if (confirmed == true) {
    try {
      await _performDelete();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }
}

// Usage in UI
DangerButton(
  text: 'Delete Item',
  icon: Icons.delete_outline,
  onPressed: _handleDelete,
)
```

---

### Pattern 4: Search Field

```dart
// Clean search implementation
final _searchController = TextEditingController();

TextInputField(
  hintText: 'Search...',
  prefixIcon: Icons.search,
  controller: _searchController,
  onChanged: (value) => _performSearch(value),
  suffixIcon: _searchController.text.isNotEmpty ? Icons.clear : null,
  onSuffixIconPressed: () {
    _searchController.clear();
    _performSearch('');
  },
)
```

---

## Migration Guide

For developers working with existing code that needs to be updated to use the component library.

### Step 1: Identify Inline Widgets

Search for these patterns in your files:
- `TextField(` - Replace with `TextInputField` or `TextAreaField`
- `ElevatedButton(` - Replace with `PrimaryButton`
- `OutlinedButton(` - Replace with `SecondaryButton`
- `TextButton(` - Replace with `GhostButton`
- Delete confirmation dialogs - Replace with `showDeleteConfirmationDialog`

**Exceptions** (do NOT replace):
- AppBar title editing fields (specialized behavior)
- Custom search bars with complex logic (evaluate case-by-case)
- Buttons with highly specialized styling (rare)

### Step 2: Replace Widget

1. **Add imports**:
```dart
import 'package:later_mobile/widgets/components/buttons/primary_button.dart';
import 'package:later_mobile/widgets/components/inputs/text_input_field.dart';
import 'package:later_mobile/widgets/components/dialogs/delete_confirmation_dialog.dart';
// Import specific components as needed
```

2. **Map old parameters to new API**:

**TextField → TextInputField/TextAreaField**:
- `decoration: InputDecoration(labelText: 'X')` → `label: 'X'`
- `decoration: InputDecoration(hintText: 'X')` → `hintText: 'X'`
- `maxLines: 1` → Use `TextInputField`
- `maxLines: 3+` → Use `TextAreaField`
- Keep: `controller`, `focusNode`, `autofocus`, `enabled`, `onChanged`

**ElevatedButton → PrimaryButton**:
- `onPressed` → `onPressed`
- `child: Text('X')` → `text: 'X'`
- `child: Row(Icon + Text)` → `text: 'X', icon: Icons.Y`
- Remove: `style`, `Ink`, custom `decoration`

**TextButton → GhostButton**:
- `onPressed` → `onPressed`
- `child: Text('X')` → `text: 'X'`
- Remove: `style`

### Step 3: Test the Replacement

**Visual Testing**:
- [ ] Component appears correctly in light mode
- [ ] Component appears correctly in dark mode
- [ ] Focus states work (for inputs)
- [ ] Hover states work (for buttons)
- [ ] Loading states work (if applicable)
- [ ] Disabled states work (if applicable)

**Functional Testing**:
- [ ] Tap/click handlers fire correctly
- [ ] Form validation works (for inputs)
- [ ] Keyboard actions work (for inputs)
- [ ] Navigation works (for buttons)
- [ ] Data flows correctly

**Accessibility Testing**:
- [ ] Screen reader announces component correctly
- [ ] Focus order is logical
- [ ] Keyboard navigation works

### Step 4: Clean Up

- Remove unused imports
- Remove custom styling variables
- Remove custom decoration code
- Update any comments

---

## Troubleshooting

### Issue: "Label is required" error

**Symptom**: Getting an error that label parameter is required

**Solution**: Label is now optional (as of recent update). Update your component import to latest version. Omit label for search fields and quick capture.

```dart
// This is now valid
TextInputField(
  hintText: 'Search...',
  controller: _searchController,
)
```

---

### Issue: Focus not working

**Symptom**: Input field doesn't auto-focus or focus isn't controllable

**Solution**: Use the `focusNode` parameter for external control:

```dart
final _focusNode = FocusNode();

// In build:
TextInputField(
  focusNode: _focusNode,
  controller: _controller,
)

// To focus programmatically:
_focusNode.requestFocus();

// Don't forget to dispose:
@override
void dispose() {
  _focusNode.dispose();
  super.dispose();
}
```

---

### Issue: Character counter not showing

**Symptom**: MaxLength set but no counter appears

**Solution**: Ensure `maxLength` parameter is provided:

```dart
TextInputField(
  maxLength: 100,  // This shows "45 / 100"
  controller: _controller,
)
```

---

### Issue: Button doesn't expand to full width

**Symptom**: Button is narrower than expected

**Solution**: Use `isExpanded: true`:

```dart
PrimaryButton(
  text: 'Submit',
  isExpanded: true,  // Full width
  onPressed: _handleSubmit,
)
```

---

### Issue: Text capitalization not working

**Symptom**: First letters not capitalizing in text fields

**Solution**: Use `textCapitalization` parameter:

```dart
TextInputField(
  textCapitalization: TextCapitalization.words,  // For names
  controller: _controller,
)

TextAreaField(
  textCapitalization: TextCapitalization.sentences,  // For content
  controller: _controller,
)
```

---

### Issue: Loading spinner doesn't show

**Symptom**: Button doesn't show loading state

**Solution**: Set both `isLoading: true` and `onPressed: null`:

```dart
PrimaryButton(
  text: _isLoading ? 'Saving...' : 'Save',
  isLoading: _isLoading,
  onPressed: _isLoading ? null : _handleSave,  // Null when loading
)
```

---

### Issue: Delete dialog doesn't match design system

**Symptom**: Old-style dialog with inconsistent buttons

**Solution**: Replace with `showDeleteConfirmationDialog`:

```dart
// Before
showDialog(
  context: context,
  builder: (context) => AlertDialog(...),
);

// After
showDeleteConfirmationDialog(
  context: context,
  title: 'Delete Item?',
  message: 'This cannot be undone.',
);
```

---

## Best Practices

### DO

- Use `PrimaryButton` for the single most important action on a screen
- Use `SecondaryButton` for Cancel actions in modals
- Use `GhostButton` for low-priority actions
- Use `DangerButton` for any destructive operation
- Use `TextInputField` for single-line inputs
- Use `TextAreaField` for multi-line content
- Use `showDeleteConfirmationDialog` for all delete operations
- Provide clear, action-oriented button text ("Save Changes" not "OK")
- Use `isExpanded: true` for modal buttons
- Use `maxLength` for inputs with limits
- Use `textCapitalization` appropriately
- Handle all dialog result cases (true, false, null)

### DON'T

- Don't create inline TextField or Button widgets
- Don't use ElevatedButton, OutlinedButton, or TextButton directly
- Don't create custom delete confirmation dialogs
- Don't use multiple PrimaryButtons on the same screen
- Don't use DangerButton for non-destructive actions
- Don't forget to handle loading states
- Don't forget to dispose focusNodes you create
- Don't use vague button text ("OK", "Submit" without context)
- Don't hardcode sizes - use ButtonSize enum
- Don't bypass component APIs for styling

---

## Summary

The component library provides a complete set of reusable UI elements that enforce design system consistency while reducing code duplication. By using these components, you benefit from:

- Automatic design system compliance
- Reduced development time
- Consistent user experience
- Built-in accessibility
- Easier maintenance

Always prefer components over inline widgets. If you need functionality not covered by existing components, discuss with the team before creating custom implementations.
