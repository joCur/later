# Repeated Widget Patterns Analysis - Later Mobile App

**Analysis Date:** October 26, 2025  
**Scope:** Screen and Modal Files  
**Thoroughness Level:** Medium  
**Files Analyzed:**
- `lib/widgets/screens/home_screen.dart`
- `lib/widgets/screens/todo_list_detail_screen.dart`
- `lib/widgets/screens/note_detail_screen.dart`
- `lib/widgets/screens/list_detail_screen.dart`
- `lib/widgets/modals/quick_capture_modal.dart`
- `lib/widgets/modals/create_space_modal.dart`

---

## PATTERN 1: Delete Confirmation Dialogs (5 Occurrences)

**Frequency:** 5+ times  
**Reusability:** HIGHLY REUSABLE  
**Priority:** IMMEDIATE EXTRACTION  

### Locations
- `todo_list_detail_screen.dart` - lines 397-420 (delete item), 422-449 (delete list)
- `note_detail_screen.dart` - lines 299-325 (delete note)
- `list_detail_screen.dart` - lines 446-469 (delete item), 471-498 (delete list)

### Pattern Description
Standard alert dialogs showing deletion confirmation with:
- Title customized per content type
- Content describing what will be deleted
- Two action buttons: GhostButton (Cancel) + DangerButton (Delete)
- Returns bool indicating if user confirmed

### Code Example
```dart
Future<bool> _showDeleteListConfirmation() async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete TodoList'),
        content: Text(
          'Are you sure you want to delete "${_currentTodoList.name}"?\n\n'
          'This will delete all ${_currentTodoList.items.length} items in this list. '
          'This action cannot be undone.',
        ),
        actions: [
          GhostButton(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(false),
          ),
          DangerButton(
            text: 'Delete',
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
```

### Variables Between Instances
- Dialog title (Delete TodoList, Delete TodoItem, Delete Note, Delete Item)
- Content text (item name, count of sub-items, specific warnings)
- Button text (sometimes "Delete", sometimes context-specific)

### Suggested Component Name
`DeleteConfirmationDialog`

### Proposed API
```dart
class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({
    required this.title,
    required this.content,
    this.confirmText = 'Delete',
    this.cancelText = 'Cancel',
    this.isDangerous = true,
  });
  
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final bool isDangerous;
  
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmationDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    ) ?? false;
  }
}
```

---

## PATTERN 2: Editable Title AppBar with Gradient Text (3 Occurrences)

**Frequency:** 3 times  
**Reusability:** HIGHLY REUSABLE  
**Priority:** IMMEDIATE EXTRACTION  

### Locations
- `todo_list_detail_screen.dart` - lines 490-527
- `note_detail_screen.dart` - lines 354-391
- `list_detail_screen.dart` - lines 527-577

### Pattern Description
AppBar with dual-mode title:
1. **Display mode:** GradientText with edit icon
2. **Edit mode:** TextField for inline editing
Manages editing state with `_isEditingName` flag, includes PopupMenuButton with destructive actions

### Code Example
```dart
title: _isEditingTitle
    ? TextField(
        controller: _titleController,
        autofocus: true,
        style: AppTypography.h3,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Note title',
        ),
        onSubmitted: (_) {
          setState(() {
            _isEditingTitle = false;
          });
          _saveChanges();
        },
      )
    : GestureDetector(
        onTap: () {
          setState(() {
            _isEditingTitle = true;
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: GradientText(
                _currentNote.title,
                gradient: AppColors.noteGradient,
                style: AppTypography.h3,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.edit, size: 16),
          ],
        ),
      ),
```

### Variables Between Instances
- Gradient color (noteGradient, taskGradient, listGradient)
- Optional icon display (list has icon + name, others just name)
- Menu items and callbacks
- Placeholder text
- Loading indicator for saving state

### Suggested Component Name
`EditableGradientAppBar` or `GradientTitleAppBar`

### Proposed API
```dart
class EditableGradientAppBar extends StatefulWidget {
  const EditableGradientAppBar({
    required this.title,
    required this.gradient,
    required this.onTitleChanged,
    required this.menuItems,
    this.leadingIcon,
    this.isSaving = false,
  });

  static PreferredSizeWidget create({
    required BuildContext context,
    required String title,
    required LinearGradient gradient,
    required ValueChanged<String> onTitleChanged,
    required List<PopupMenuItemModel> menuItems,
    String? leadingIcon,
    bool isSaving = false,
  }) => AppBar(
    // Implementation
  );
}
```

---

## PATTERN 3: Swipe-to-Delete Dismissible (2 Occurrences)

**Frequency:** 2 times (identical pattern)  
**Reusability:** HIGHLY REUSABLE  
**Priority:** IMMEDIATE EXTRACTION  

### Locations
- `todo_list_detail_screen.dart` - lines 615-642
- `list_detail_screen.dart` - lines 695-727

### Pattern Description
Dismissible wrapper for list items with:
- Red background showing trash icon (right-aligned)
- ClipRRect with borderRadius 8.0
- Confirmation dialog before actual dismissal
- Exact same styling across both files

### Code Example
```dart
Dismissible(
  key: ValueKey(item.id),
  background: Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
    ),
  ),
  direction: DismissDirection.endToStart,
  confirmDismiss: (_) => _showDeleteItemConfirmation(item.title),
  onDismissed: (_) => _performDeleteTodoItem(item),
  child: TodoItemCard(...),
);
```

### Variables Between Instances
- Key/Item ID
- Child widget (TodoItemCard vs ListItemCard)
- Confirmation function
- OnDismissed callback

### Suggested Component Name
`SwipeDeleteDismissible`

### Proposed API
```dart
class SwipeDeleteDismissible<T> extends StatelessWidget {
  const SwipeDeleteDismissible({
    required this.key,
    required this.itemId,
    required this.child,
    required this.onConfirmDelete,
    required this.onDelete,
  });

  final ValueKey<dynamic> key;
  final dynamic itemId;
  final Widget child;
  final Future<bool> Function() onConfirmDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key,
      background: _buildDeleteBackground(),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => onConfirmDelete(),
      onDismissed: (_) => onDelete(),
      child: child,
    );
  }

  Widget _buildDeleteBackground() => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
    ),
  );
}
```

---

## PATTERN 4: Gradient Progress Section (2 Occurrences)

**Frequency:** 2 times (near-identical)  
**Reusability:** HIGHLY REUSABLE  
**Priority:** IMMEDIATE EXTRACTION  

### Locations
- `todo_list_detail_screen.dart` - lines 562-598
- `list_detail_screen.dart` - lines 642-678 (only for checkboxes style)

### Pattern Description
Gradient container with:
- Gradient background (task/list gradient)
- Box shadow matching gradient color
- Progress text (X/Y completed)
- LinearProgressIndicator with white styling
- Column layout with consistent spacing

### Code Example
```dart
Container(
  padding: const EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(
    gradient: AppColors.taskGradient,
    boxShadow: [
      BoxShadow(
        color: AppColors.taskGradient.colors.first.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '${_currentTodoList.completedItems}/${_currentTodoList.totalItems} completed',
        style: AppTypography.bodyMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      LinearProgressIndicator(
        value: _currentTodoList.progress,
        backgroundColor: Colors.white.withValues(alpha: 0.3),
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        minHeight: 8,
        borderRadius: BorderRadius.circular(4),
      ),
    ],
  ),
);
```

### Variables Between Instances
- Gradient color (taskGradient vs listGradient)
- Progress values (completed/total)
- Progress percentage (0.0-1.0)
- Label text

### Suggested Component Name
`GradientProgressSection`

### Proposed API
```dart
class GradientProgressSection extends StatelessWidget {
  const GradientProgressSection({
    required this.gradient,
    required this.completed,
    required this.total,
    required this.progress,
    this.label = 'completed',
  });

  final LinearGradient gradient;
  final int completed;
  final int total;
  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$completed/$total $label',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
```

---

## PATTERN 5: SnackBar Display Helper (3 Occurrences)

**Frequency:** 3 times (identical)  
**Reusability:** HIGHLY REUSABLE  
**Priority:** HIGH (Move to utility/extension)  

### Locations
- `todo_list_detail_screen.dart` - lines 451-462
- `note_detail_screen.dart` - lines 327-338
- `list_detail_screen.dart` - lines 500-511

### Pattern Description
Identical helper method repeated across all detail screens with:
- Mount check before showing
- Optional error state (red background for errors)
- 2-second duration
- Simple text message

### Code Example
```dart
void _showSnackBar(String message, {bool isError = false}) {
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppColors.error : null,
      duration: const Duration(seconds: 2),
    ),
  );
}
```

### Suggested Implementation
Convert to extension on BuildContext:

```dart
extension SnackBarHelper on BuildContext {
  void showSnackBar(
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : null,
        duration: duration,
      ),
    );
  }
}
```

**Usage:** `context.showSnackBar('Item saved'); context.showSnackBar('Error occurred', isError: true);`

---

## PATTERN 6: Auto-Save Debounce Pattern (3+ Occurrences)

**Frequency:** 3+ times (identical)  
**Reusability:** HIGH - Candidate for mixin  
**Priority:** HIGH EXTRACTION  

### Locations
- `todo_list_detail_screen.dart` - lines 81-94, 96-131
- `note_detail_screen.dart` - lines 85-112, 115-160
- `list_detail_screen.dart` - lines 77-90, 92-125

### Pattern Description
Debounced auto-save mechanism with:
- TextEditingController listeners triggering debounce
- Timer-based delay (500ms typical)
- State flags: `_hasChanges`, `_isSaving`
- Validation before save
- Error handling

### Code Example
```dart
void _onNameChanged() {
  setState(() {
    _hasChanges = true;
  });

  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(milliseconds: 500), () {
    _saveChanges();
  });
}

Future<void> _saveChanges() async {
  if (!_hasChanges || _isSaving) return;

  if (_nameController.text.trim().isEmpty) {
    _showSnackBar('Name cannot be empty', isError: true);
    return;
  }

  setState(() {
    _isSaving = true;
  });

  try {
    // Validation and update logic
  } catch (e) {
    _showSnackBar('Failed to save: $e', isError: true);
  } finally {
    setState(() {
      _isSaving = false;
    });
  }
}
```

### Suggested Implementation
Create as a mixin to share across detail screens:

```dart
mixin AutoSaveMixin<T extends StatefulWidget> on State<T> {
  Timer? _debounceTimer;
  bool _hasChanges = false;
  bool _isSaving = false;

  static const int _defaultDebounceMs = 500;

  void setupAutoSave(TextEditingController controller) {
    controller.addListener(onAutoSaveTriggered);
  }

  void onAutoSaveTriggered() {
    setState(() => _hasChanges = true);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: _defaultDebounceMs),
      performAutoSave,
    );
  }

  Future<void> performAutoSave() async; // To be implemented

  void cancelAutoSave() => _debounceTimer?.cancel();

  @override
  void dispose() {
    cancelAutoSave();
    super.dispose();
  }
}
```

---

## PATTERN 7: Popup Menu with Icon + Text (4 Occurrences)

**Frequency:** 4 times  
**Reusability:** HIGHLY REUSABLE  
**Priority:** MEDIUM EXTRACTION  

### Locations
- `home_screen.dart` - lines 278-302 (search/menu buttons)
- `todo_list_detail_screen.dart` - lines 538-556
- `note_detail_screen.dart` - lines 402-420
- `list_detail_screen.dart` - lines 589-635

### Pattern Description
PopupMenuButton with icon+text Row styling for each menu item

### Code Example
```dart
PopupMenuButton<String>(
  onSelected: (value) {
    if (value == 'delete') {
      _deleteNote();
    }
  },
  itemBuilder: (context) => [
    const PopupMenuItem(
      value: 'delete',
      child: Row(
        children: [
          Icon(Icons.delete, color: AppColors.error),
          SizedBox(width: AppSpacing.sm),
          Text('Delete Note'),
        ],
      ),
    ),
  ],
),
```

### Suggested Component
Could create helper to reduce boilerplate

---

## PATTERN 8: Empty State Widgets (2 Occurrences)

**Frequency:** 2 times  
**Reusability:** MEDIUM (variations exist)  
**Priority:** MEDIUM (already partially abstracted)  

### Locations
- `todo_list_detail_screen.dart` - lines 658-689
- `list_detail_screen.dart` - lines 743-774

### Note
EmptyState components already exist in `components/empty_states/`. Consider consolidating these implementations with factory constructors or using existing components directly.

---

## PATTERN 9: Icon Picker (2 Occurrences)

**Frequency:** 2 times  
**Reusability:** MEDIUM-HIGH  
**Priority:** MEDIUM EXTRACTION  

### Locations
- `create_space_modal.dart` - lines 254-325 (Wrap layout)
- `list_detail_screen.dart` - lines 394-443 (GridView layout)

### Pattern Description
Emoji/icon selection with:
- 48x48 container size
- Selection state (border/checkmark)
- GestureDetector for selection
- Consistent styling

### Suggested Component Name
`IconPickerGrid` or `EmojiPickerGrid`

---

## PATTERN 10: Color Picker (1 Occurrence)

**Frequency:** 1 (but reusable)  
**Reusability:** MEDIUM-HIGH  
**Priority:** MEDIUM EXTRACTION  

### Locations
- `create_space_modal.dart` - lines 327-389

### Pattern Description
Circular color swatches with selection state, uses hex color codes

### Suggested Component Name
`ColorPickerGrid` or `ColorSwatchPicker`

---

## Summary & Recommendations

### Immediate Extraction (High Value, Low Complexity)
1. **DeleteConfirmationDialog** - 5 occurrences
2. **SwipeDeleteDismissible** - 2 occurrences  
3. **GradientProgressSection** - 2 occurrences
4. **SnackBar Helper** - 3 occurrences (→ BuildContext extension)
5. **AutoSaveMixin** - 3+ occurrences (→ mixin)

### Medium Priority
6. **EditableGradientAppBar** - 3 occurrences
7. **IconPickerGrid** - 2 occurrences
8. **ColorPickerGrid** - 1 occurrence (reusable pattern)
9. **Popup Menu Helpers** - 4 occurrences

### Lower Priority (Already Partially Abstracted)
10. Empty states - consolidate with existing components
11. Reorderable lists - domain-specific patterns
12. Space selector - specific to quick capture flow

### Expected Benefits
- **Code Reduction:** 30-40% less duplicated code
- **Maintainability:** Single source of truth for common patterns
- **Consistency:** Unified UI/UX across all screens
- **Testability:** Centralized components easier to unit test
- **Scalability:** New screens can reuse components immediately

---

**Generated:** October 26, 2025  
**Analysis Tool:** Claude Code - File Search & Pattern Analysis
