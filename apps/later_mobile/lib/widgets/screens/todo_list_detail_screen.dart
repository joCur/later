import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:later_mobile/l10n/app_localizations.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import '../../core/utils/responsive_modal.dart';
import 'package:later_mobile/data/models/todo_list_model.dart';
import 'package:later_mobile/data/models/todo_item_model.dart';
import 'package:later_mobile/data/models/todo_priority.dart';
import '../../providers/content_provider.dart';
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
  // Text controllers
  late TextEditingController _nameController;

  // Local state
  late TodoList _currentTodoList;
  List<TodoItem> _currentItems = [];
  bool _isLoadingItems = false;
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

    // Load todo items for this list
    _loadTodoItems();
  }

  /// Load todo items from the provider
  Future<void> _loadTodoItems() async {
    setState(() {
      _isLoadingItems = true;
    });

    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      final items = await provider.loadTodoItemsForList(widget.todoList.id);

      if (mounted) {
        setState(() {
          _currentItems = items;
          _isLoadingItems = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _isLoadingItems = false;
        });
        _showSnackBar(l10n.todoDetailLoadFailed, isError: true);
      }
    }
  }

  /// Refresh the parent todo list from the provider to get updated counts
  Future<void> _refreshTodoListData() async {
    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      final updated = provider.todoLists.firstWhere(
        (tl) => tl.id == _currentTodoList.id,
      );
      if (mounted) {
        setState(() {
          _currentTodoList = updated;
        });
      }
    } catch (e) {
      // Todo list might have been deleted
      if (mounted) {
        _showSnackBar('Failed to refresh list data: $e', isError: true);
      }
    }
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

    final l10n = AppLocalizations.of(context)!;

    // Validate name
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar(l10n.todoDetailNameEmpty, isError: true);
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
      _showSnackBar(l10n.todoDetailSaveFailed, isError: true);
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

    final l10n = AppLocalizations.of(context)!;

    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      // Set sortOrder to be at the end of current items
      final itemWithSortOrder = result.copyWith(sortOrder: _currentItems.length);
      // createTodoItem takes a TodoItem directly
      await provider.createTodoItem(itemWithSortOrder);

      // Reload items and refresh parent list data
      await _loadTodoItems();
      await _refreshTodoListData();

      if (mounted) _showSnackBar(l10n.todoDetailItemAdded);
    } catch (e) {
      if (mounted) _showSnackBar(l10n.todoDetailItemAddFailed, isError: true);
    }
  }

  /// Edit a TodoItem
  Future<void> _editTodoItem(TodoItem item) async {
    final result = await _showTodoItemDialog(existingItem: item);
    if (result == null || !mounted) return;

    final l10n = AppLocalizations.of(context)!;

    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      // updateTodoItem takes just a TodoItem
      await provider.updateTodoItem(result);

      // Reload items and refresh parent list data
      await _loadTodoItems();
      await _refreshTodoListData();

      if (mounted) _showSnackBar(l10n.todoDetailItemUpdated);
    } catch (e) {
      if (mounted) _showSnackBar(l10n.todoDetailItemUpdateFailed, isError: true);
    }
  }

  /// Perform the actual deletion without confirmation
  /// Used by Dismissible which handles confirmation separately
  Future<void> _performDeleteTodoItem(TodoItem item) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      await provider.deleteTodoItem(item.id, _currentTodoList.id);

      // Reload items and refresh parent list data
      await _loadTodoItems();
      await _refreshTodoListData();

      if (mounted) _showSnackBar(l10n.todoDetailItemDeleted);
    } catch (e) {
      if (mounted) _showSnackBar(l10n.todoDetailItemDeleteFailed, isError: true);
    }
  }

  /// Toggle TodoItem completion
  Future<void> _toggleTodoItem(TodoItem item) async {
    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);

      // Toggle the item by updating it with updateTodoItem
      final toggled = item.copyWith(isCompleted: !item.isCompleted);
      await provider.updateTodoItem(toggled);

      // Reload items and refresh parent list data
      await _loadTodoItems();
      await _refreshTodoListData();
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      _showSnackBar(l10n.todoDetailItemToggleFailed, isError: true);
    }
  }

  /// Reorder TodoItems with optimistic UI update
  Future<void> _reorderTodoItems(int oldIndex, int newIndex) async {
    // Adjust newIndex when moving item down (Flutter's ReorderableListView pattern)
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    // Optimistically update local state first for immediate UI feedback
    final reorderedItems = List<TodoItem>.from(_currentItems);
    final item = reorderedItems.removeAt(oldIndex);
    reorderedItems.insert(newIndex, item);

    // Update sortOrder values
    for (int i = 0; i < reorderedItems.length; i++) {
      reorderedItems[i] = reorderedItems[i].copyWith(sortOrder: i);
    }

    setState(() {
      _currentItems = reorderedItems;
    });

    // Then persist to provider in the background
    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      // reorderTodoItems takes (todoListId, List<TodoItem>)
      await provider.reorderTodoItems(_currentTodoList.id, reorderedItems);
    } catch (e) {
      // On error, check mounted before any context usage
      if (!mounted) return;

      // Show error to user and reload items from server
      final l10n = AppLocalizations.of(context)!;
      _showSnackBar(l10n.todoDetailReorderFailed, isError: true);
      await _loadTodoItems();
    }
  }

  /// Delete the entire TodoList
  /// Note: Navigation is handled in _showDeleteListConfirmation(), not here
  Future<void> _deleteTodoList() async {
    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);

      await provider.deleteTodoList(_currentTodoList.id);

      // Navigation already handled in confirmation dialog
      // Success feedback is provided by UI update (todo list removed from list)
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showSnackBar(l10n.todoDetailDeleteListFailed, isError: true);
      }
    }
  }

  /// Show TodoItem edit/create dialog
  Future<TodoItem?> _showTodoItemDialog({TodoItem? existingItem}) async {
    final l10n = AppLocalizations.of(context)!;
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
        title: existingItem == null ? l10n.todoDetailAddItemTitle : l10n.todoDetailEditItemTitle,
        primaryButtonText: existingItem == null ? 'Add' : 'Save',
        showSecondaryButton: false,
        onPrimaryPressed: () {
          if (titleController.text.trim().isEmpty) {
            _showSnackBar(l10n.todoDetailItemTitleRequired, isError: true);
            return;
          }

          final item = TodoItem(
            id: existingItem?.id ?? const Uuid().v4(),
            todoListId: _currentTodoList.id,  // Foreign key field
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
                  label: l10n.todoDetailItemTitleLabel,
                  hintText: l10n.todoDetailItemTitleHint,
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
                  label: l10n.todoDetailItemDescriptionLabel,
                  hintText: l10n.todoDetailItemDescriptionHint,
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
                        ? l10n.todoDetailItemDueDateNone
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
                  decoration: InputDecoration(labelText: l10n.todoDetailItemPriorityLabel),
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
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: l10n.todoDetailDeleteListTitle,
      message: l10n.todoDetailDeleteListMessage(
        _currentTodoList.name,
        _currentTodoList.totalItemCount,
      ),
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
    final l10n = AppLocalizations.of(context)!;
    switch (priority) {
      case TodoPriority.high:
        return l10n.todoDetailPriorityHigh;
      case TodoPriority.medium:
        return l10n.todoDetailPriorityMedium;
      case TodoPriority.low:
        return l10n.todoDetailPriorityLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
            hintText: l10n.todoDetailNameHint,
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
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: AppColors.error),
                      const SizedBox(width: AppSpacing.sm),
                      Text(l10n.todoDetailMenuDelete),
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
                    l10n.todoDetailProgressCompleted(
                      _currentTodoList.completedItemCount,
                      _currentTodoList.totalItemCount,
                    ),
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
              child: _isLoadingItems
                  ? const Center(child: CircularProgressIndicator())
                  : _currentItems.isEmpty
                      ? _buildEmptyState()
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: _currentItems.length,
                          onReorder: _reorderTodoItems,
                          itemBuilder: (context, index) {
                            final item = _currentItems[index];
                            final itemKey = ValueKey(item.id);
                            return DismissibleListItem(
                              key: itemKey,
                              itemKey: itemKey,
                              itemName: item.title,
                              onDelete: () => _performDeleteTodoItem(item),
                              child: TodoItemCard(
                                todoItem: item,
                                index: index,
                                onCheckboxChanged: (value) =>
                                    _toggleTodoItem(item),
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
          label: l10n.todoDetailFabLabel,
          gradient: AppColors.taskGradient,
          enablePulse: _enableFabPulse,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedEmptyState(
      icon: Icons.check_circle_outline,
      title: l10n.todoDetailEmptyTitle,
      message: l10n.todoDetailEmptyMessage,
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
