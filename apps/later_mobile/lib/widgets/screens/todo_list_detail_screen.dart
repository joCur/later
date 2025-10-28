import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import '../../core/utils/responsive_modal.dart';
import '../../data/models/todo_list_model.dart';
import '../../providers/content_provider.dart';
import '../../providers/spaces_provider.dart';
import 'package:later_mobile/design_system/organisms/cards/todo_item_card.dart';
import 'package:later_mobile/design_system/organisms/fab/responsive_fab.dart';
import 'package:later_mobile/design_system/organisms/modals/bottom_sheet_container.dart';
import 'package:later_mobile/design_system/atoms/inputs/text_input_field.dart';
import 'package:later_mobile/design_system/atoms/inputs/text_area_field.dart';
import 'package:later_mobile/design_system/organisms/dialogs/delete_confirmation_dialog.dart';
import 'package:later_mobile/design_system/molecules/app_bars/editable_app_bar_title.dart';
import 'package:later_mobile/design_system/molecules/lists/dismissible_list_item.dart';
import 'package:later_mobile/design_system/organisms/empty_states/animated_empty_state.dart';

/// TodoList Detail Screen for viewing and editing TodoList with TodoItems
///
/// Features:
/// - Editable TodoList name in AppBar
/// - Progress indicator showing completion (e.g., "4/7 completed")
/// - Linear progress bar
/// - Reorderable list of TodoItems
/// - Add new TodoItem button
/// - Edit TodoItem dialog (title, description, due date, priority)
/// - Swipe-to-delete for TodoItems
/// - Menu: Edit list properties, Delete list
/// - Auto-save with debounce
class TodoListDetailScreen extends StatefulWidget {
  const TodoListDetailScreen({super.key, required this.todoList});

  /// TodoList to display and edit
  final TodoList todoList;

  @override
  State<TodoListDetailScreen> createState() => _TodoListDetailScreenState();
}

class _TodoListDetailScreenState extends State<TodoListDetailScreen> {
  // Form key for validation

  // Text controllers
  late TextEditingController _nameController;

  // Local state
  late TodoList _currentTodoList;
  Timer? _debounceTimer;
  Timer? _deletionTimer;
  bool _isSaving = false;
  bool _hasChanges = false;
  bool _enableFabPulse = false;

  @override
  void initState() {
    super.initState();

    // Initialize current todo list
    _currentTodoList = widget.todoList;

    // Initialize text controllers
    _nameController = TextEditingController(text: widget.todoList.name);

    // Listen to text changes for auto-save
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _deletionTimer?.cancel();
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  /// Handle name changes and trigger debounced save
  void _onNameChanged() {
    setState(() {
      _hasChanges = true;
    });

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new debounce timer (500ms)
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _saveChanges();
    });
  }

  /// Save changes to the todo list
  Future<void> _saveChanges() async {
    if (!_hasChanges || _isSaving) return;

    // Validate name
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('TodoList name cannot be empty', isError: true);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Update todo list name
      final updated = _currentTodoList.copyWith(
        name: _nameController.text.trim(),
      );

      // Save via provider
      final provider = Provider.of<ContentProvider>(context, listen: false);
      await provider.updateTodoList(updated);

      setState(() {
        _currentTodoList = updated;
        _hasChanges = false;
      });
    } catch (e) {
      _showSnackBar('Failed to save changes: $e', isError: true);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  /// Add a new TodoItem
  Future<void> _addTodoItem() async {
    final result = await _showTodoItemDialog();
    if (result == null || !mounted) return;

    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      await provider.addTodoItem(_currentTodoList.id, result);

      // Reload current todo list
      final updated = provider.todoLists.firstWhere(
        (tl) => tl.id == _currentTodoList.id,
      );
      if (mounted) {
        setState(() {
          _currentTodoList = updated;
        });
      }

      if (mounted) _showSnackBar('TodoItem added');
    } catch (e) {
      if (mounted) _showSnackBar('Failed to add item: $e', isError: true);
    }
  }

  /// Edit a TodoItem
  Future<void> _editTodoItem(TodoItem item) async {
    final result = await _showTodoItemDialog(existingItem: item);
    if (result == null || !mounted) return;

    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      await provider.updateTodoItem(_currentTodoList.id, item.id, result);

      // Reload current todo list
      final updated = provider.todoLists.firstWhere(
        (tl) => tl.id == _currentTodoList.id,
      );
      if (mounted) {
        setState(() {
          _currentTodoList = updated;
        });
      }

      if (mounted) _showSnackBar('TodoItem updated');
    } catch (e) {
      if (mounted) _showSnackBar('Failed to update item: $e', isError: true);
    }
  }

  /// Perform the actual deletion without confirmation
  /// Used by Dismissible which handles confirmation separately
  Future<void> _performDeleteTodoItem(TodoItem item) async {
    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      await provider.deleteTodoItem(_currentTodoList.id, item.id);

      // Reload current todo list
      final updated = provider.todoLists.firstWhere(
        (tl) => tl.id == _currentTodoList.id,
      );
      if (mounted) {
        setState(() {
          _currentTodoList = updated;
        });
      }

      if (mounted) _showSnackBar('TodoItem deleted');
    } catch (e) {
      if (mounted) _showSnackBar('Failed to delete item: $e', isError: true);
    }
  }

  /// Toggle TodoItem completion
  Future<void> _toggleTodoItem(TodoItem item) async {
    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      await provider.toggleTodoItem(_currentTodoList.id, item.id);

      // Reload current todo list
      final updated = provider.todoLists.firstWhere(
        (tl) => tl.id == _currentTodoList.id,
      );
      setState(() {
        _currentTodoList = updated;
      });
    } catch (e) {
      _showSnackBar('Failed to toggle item: $e', isError: true);
    }
  }

  /// Reorder TodoItems with optimistic UI update
  Future<void> _reorderTodoItems(int oldIndex, int newIndex) async {
    // Optimistically update local state first for immediate UI feedback
    final reorderedItems = List<TodoItem>.from(_currentTodoList.items);
    final item = reorderedItems.removeAt(oldIndex);
    reorderedItems.insert(newIndex, item);

    setState(() {
      _currentTodoList = _currentTodoList.copyWith(items: reorderedItems);
    });

    // Then persist to provider in the background
    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      await provider.reorderTodoItems(_currentTodoList.id, oldIndex, newIndex);
    } catch (e) {
      // On error, reload from provider to revert
      if (!mounted) return;
      final provider = Provider.of<ContentProvider>(context, listen: false);
      final updated = provider.todoLists.firstWhere(
        (tl) => tl.id == _currentTodoList.id,
      );
      setState(() {
        _currentTodoList = updated;
      });
      _showSnackBar('Failed to reorder items: $e', isError: true);
    }
  }

  /// Delete the entire TodoList
  Future<void> _deleteTodoList() async {
    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      final spacesProvider = Provider.of<SpacesProvider>(
        context,
        listen: false,
      );

      await provider.deleteTodoList(_currentTodoList.id, spacesProvider);

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) _showSnackBar('TodoList deleted');
    } catch (e) {
      if (mounted) _showSnackBar('Failed to delete list: $e', isError: true);
    }
  }

  /// Show TodoItem edit/create dialog
  Future<TodoItem?> _showTodoItemDialog({TodoItem? existingItem}) async {
    final titleController = TextEditingController(
      text: existingItem?.title ?? '',
    );
    final descriptionController = TextEditingController(
      text: existingItem?.description ?? '',
    );
    DateTime? selectedDueDate = existingItem?.dueDate;
    TodoPriority selectedPriority =
        existingItem?.priority ?? TodoPriority.medium;

    return ResponsiveModal.show<TodoItem>(
      context: context,
      child: BottomSheetContainer(
        title: existingItem == null ? 'Add TodoItem' : 'Edit TodoItem',
        primaryButtonText: existingItem == null ? 'Add' : 'Save',
        showSecondaryButton: false,
        onPrimaryPressed: () {
          if (titleController.text.trim().isEmpty) {
            _showSnackBar('Title is required', isError: true);
            return;
          }

          final item = TodoItem(
            id: existingItem?.id ?? const Uuid().v4(),
            title: titleController.text.trim(),
            description: descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
            isCompleted: existingItem?.isCompleted ?? false,
            dueDate: selectedDueDate,
            priority: selectedPriority,
            tags: existingItem?.tags ?? [],
            sortOrder: existingItem?.sortOrder ?? 0,
          );

          Navigator.of(context).pop(item);
        },
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title field
                TextInputField(
                  controller: titleController,
                  label: 'Title *',
                  hintText: 'Enter task title',
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) {
                    // Force rebuild to enable/disable button
                    setDialogState(() {});
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Description field
                TextAreaField(
                  controller: descriptionController,
                  label: 'Description',
                  hintText: 'Optional description',
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: AppSpacing.md),

                // Due date picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    selectedDueDate == null
                        ? 'No due date'
                        : DateFormat.yMMMd().format(selectedDueDate!),
                  ),
                  trailing: selectedDueDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setDialogState(() {
                              selectedDueDate = null;
                            });
                          },
                        )
                      : null,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedDueDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Priority dropdown
                DropdownButtonFormField<TodoPriority>(
                  initialValue: selectedPriority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: TodoPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(_getPriorityLabel(priority)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedPriority = value;
                      });
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Show delete list confirmation
  Future<void> _showDeleteListConfirmation() async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: 'Delete TodoList',
      message:
          'Are you sure you want to delete "${_currentTodoList.name}"?\n\n'
          'This will delete all ${_currentTodoList.items.length} items in this list. '
          'This action cannot be undone.',
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop(); // Return to previous screen
      await _deleteTodoList();
    }
  }

  /// Show SnackBar message
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

  /// Get priority label
  String _getPriorityLabel(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return 'High';
      case TodoPriority.medium:
        return 'Medium';
      case TodoPriority.low:
        return 'Low';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          // Save before leaving
          await _saveChanges();
          if (mounted && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: EditableAppBarTitle(
            text: _currentTodoList.name,
            onChanged: (newName) {
              _nameController.text = newName;
              _saveChanges();
            },
            gradient: AppColors.taskGradient,
            hintText: 'TodoList name',
          ),
          actions: [
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteListConfirmation();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.error),
                      SizedBox(width: AppSpacing.sm),
                      Text('Delete List'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress section
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: AppColors.taskGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.taskGradient.colors.first.withValues(
                      alpha: 0.3,
                    ),
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
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),

            // TodoItems list
            Expanded(
              child: _currentTodoList.items.isEmpty
                  ? _buildEmptyState()
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _currentTodoList.items.length,
                      onReorder: (oldIndex, newIndex) {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        _reorderTodoItems(oldIndex, newIndex);
                      },
                      itemBuilder: (context, index) {
                        final item = _currentTodoList.items[index];
                        final itemKey = ValueKey(item.id);
                        return DismissibleListItem(
                          key: itemKey,
                          itemKey: itemKey,
                          itemName: item.title,
                          onDelete: () => _performDeleteTodoItem(item),
                          child: TodoItemCard(
                            todoItem: item,
                            index: index,
                            onCheckboxChanged: (value) => _toggleTodoItem(item),
                            onLongPress: () => _editTodoItem(item),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: ResponsiveFab(
          onPressed: _addTodoItem,
          icon: Icons.add,
          label: 'Add Todo',
          gradient: AppColors.taskGradient,
          enablePulse: _enableFabPulse,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return AnimatedEmptyState(
      icon: Icons.check_circle_outline,
      title: 'No tasks yet',
      message: 'Tap the + button to add your first task',
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
