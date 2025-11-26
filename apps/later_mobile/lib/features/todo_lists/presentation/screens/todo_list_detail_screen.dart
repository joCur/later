import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:later_mobile/design_system/atoms/inputs/text_area_field.dart';
import 'package:later_mobile/design_system/atoms/inputs/text_input_field.dart';
import 'package:later_mobile/design_system/molecules/app_bars/editable_app_bar_title.dart';
import 'package:later_mobile/design_system/molecules/lists/dismissible_list_item.dart';
import 'package:later_mobile/design_system/organisms/cards/todo_item_card.dart';
import 'package:later_mobile/design_system/organisms/dialogs/delete_confirmation_dialog.dart';
import 'package:later_mobile/design_system/organisms/empty_states/animated_empty_state.dart';
import 'package:later_mobile/design_system/organisms/fab/responsive_fab.dart';
import 'package:later_mobile/design_system/organisms/modals/bottom_sheet_container.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_item.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_list.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_priority.dart';
import 'package:later_mobile/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import 'package:later_mobile/core/utils/responsive_modal.dart';
import '../../application/providers.dart';
import '../controllers/todo_items_controller.dart';
import '../controllers/todo_lists_controller.dart';

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
///
/// The screen now fetches todo list data by ID using the todoListByIdProvider.
/// This enables deep linking and ensures data is always fresh from the source.
class TodoListDetailScreen extends ConsumerStatefulWidget {
  const TodoListDetailScreen({super.key, required this.todoListId});

  /// ID of the todo list to display and edit
  final String todoListId;

  @override
  ConsumerState<TodoListDetailScreen> createState() => _TodoListDetailScreenState();
}

class _TodoListDetailScreenState extends ConsumerState<TodoListDetailScreen> {
  // Text controllers (nullable until todo list loads)
  TextEditingController? _nameController;

  // Local state (nullable until todo list loads)
  TodoList? _currentTodoList;
  List<TodoItem> _currentItems = [];
  bool _isLoadingItems = false;
  Timer? _debounceTimer;
  Timer? _deletionTimer;
  bool _isSaving = false;
  bool _hasChanges = false;
  bool _enableFabPulse = false;

  // Track if controllers have been initialized
  bool _controllersInitialized = false;

  /// Initialize text controllers when todo list data is available
  void _initializeControllers(TodoList todoList) {
    if (_controllersInitialized) return;

    _currentTodoList = todoList;
    _nameController = TextEditingController(text: todoList.name);

    // Listen to text changes for auto-save
    _nameController!.addListener(_onNameChanged);

    _controllersInitialized = true;
  }

  @override
  void initState() {
    super.initState();
    // Controllers will be initialized in build when data loads

    // Listen to todo items controller changes
    ref.listenManual(
      todoItemsControllerProvider(widget.todoListId),
      (previous, next) {
        next.whenData((items) {
          if (mounted) {
            setState(() {
              _currentItems = items;
              _isLoadingItems = false;
            });
          }
        });

        // Handle loading state
        if (next.isLoading && !next.hasValue) {
          if (mounted) {
            setState(() {
              _isLoadingItems = true;
            });
          }
        }

        // Handle errors
        next.whenOrNull(
          error: (error, stackTrace) {
            if (mounted) {
              final l10n = AppLocalizations.of(context)!;
              setState(() {
                _isLoadingItems = false;
              });
              _showSnackBar(l10n.todoDetailLoadFailed, isError: true);
            }
          },
        );
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _deletionTimer?.cancel();
    _nameController?.removeListener(_onNameChanged);
    _nameController?.dispose();
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
    if (!_hasChanges || _isSaving || _currentTodoList == null || _nameController == null) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final currentTodoList = _currentTodoList!;
    final nameController = _nameController!;

    // Validate name
    if (nameController.text.trim().isEmpty) {
      _showSnackBar(l10n.todoDetailNameEmpty, isError: true);
      // Restore previous name
      nameController.text = currentTodoList.name;
      setState(() {
        _hasChanges = false;
      });
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Update todo list name
      final updated = currentTodoList.copyWith(
        name: nameController.text.trim(),
      );

      // Save via Riverpod controller
      await ref
          .read(todoListsControllerProvider(currentTodoList.spaceId).notifier)
          .updateTodoList(updated);

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
    if (_currentTodoList == null) return;

    final result = await _showTodoItemDialog();
    if (result == null || !mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final currentTodoList = _currentTodoList!;

    try {
      // Set sortOrder to be at the end of current items
      final itemWithSortOrder = result.copyWith(
        sortOrder: _currentItems.length,
      );

      // Create item via Riverpod controller
      await ref
          .read(todoItemsControllerProvider(widget.todoListId).notifier)
          .createItem(itemWithSortOrder);

      // Refresh parent list to get updated counts
      await ref
          .read(todoListsControllerProvider(currentTodoList.spaceId).notifier)
          .refreshTodoList(widget.todoListId);

      if (mounted) _showSnackBar(l10n.todoDetailItemAdded);
    } catch (e) {
      if (mounted) _showSnackBar(l10n.todoDetailItemAddFailed, isError: true);
    }
  }

  /// Edit a TodoItem
  Future<void> _editTodoItem(TodoItem item) async {
    if (_currentTodoList == null) return;

    final result = await _showTodoItemDialog(existingItem: item);
    if (result == null || !mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final currentTodoList = _currentTodoList!;

    try {
      // Update item via Riverpod controller
      await ref
          .read(todoItemsControllerProvider(widget.todoListId).notifier)
          .updateItem(result);

      // Refresh parent list to get updated counts
      await ref
          .read(todoListsControllerProvider(currentTodoList.spaceId).notifier)
          .refreshTodoList(widget.todoListId);

      if (mounted) _showSnackBar(l10n.todoDetailItemUpdated);
    } catch (e) {
      if (mounted) {
        _showSnackBar(l10n.todoDetailItemUpdateFailed, isError: true);
      }
    }
  }

  /// Perform the actual deletion without confirmation
  /// Used by Dismissible which handles confirmation separately
  Future<void> _performDeleteTodoItem(TodoItem item) async {
    if (_currentTodoList == null) return;

    final l10n = AppLocalizations.of(context)!;
    final currentTodoList = _currentTodoList!;

    try {
      // Delete item via Riverpod controller
      await ref
          .read(todoItemsControllerProvider(widget.todoListId).notifier)
          .deleteItem(item.id, currentTodoList.id);

      // Refresh parent list to get updated counts
      await ref
          .read(todoListsControllerProvider(currentTodoList.spaceId).notifier)
          .refreshTodoList(widget.todoListId);

      if (mounted) _showSnackBar(l10n.todoDetailItemDeleted);
    } catch (e) {
      if (mounted) {
        _showSnackBar(l10n.todoDetailItemDeleteFailed, isError: true);
      }
    }
  }

  /// Toggle TodoItem completion
  Future<void> _toggleTodoItem(TodoItem item) async {
    if (_currentTodoList == null) return;

    final currentTodoList = _currentTodoList!;

    try {
      // Toggle item via Riverpod controller
      await ref
          .read(todoItemsControllerProvider(widget.todoListId).notifier)
          .toggleItem(item.id, currentTodoList.id);

      // Refresh parent list to get updated counts
      await ref
          .read(todoListsControllerProvider(currentTodoList.spaceId).notifier)
          .refreshTodoList(widget.todoListId);
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

    setState(() {
      _currentItems = reorderedItems;
    });

    // Then persist via Riverpod controller in the background
    try {
      // Extract IDs in the new order
      final orderedIds = reorderedItems.map((item) => item.id).toList();

      // Call controller to reorder
      await ref
          .read(todoItemsControllerProvider(widget.todoListId).notifier)
          .reorderItems(orderedIds);
    } catch (e) {
      // On error, check mounted before any context usage
      if (!mounted) return;

      // Show error to user - controller will reload items from server
      final l10n = AppLocalizations.of(context)!;
      _showSnackBar(l10n.todoDetailReorderFailed, isError: true);
    }
  }

  /// Delete the entire TodoList
  /// Note: Navigation is handled in _showDeleteListConfirmation(), not here
  Future<void> _deleteTodoList() async {
    if (_currentTodoList == null) return;

    final currentTodoList = _currentTodoList!;

    try {
      // Delete list via Riverpod controller
      await ref
          .read(todoListsControllerProvider(currentTodoList.spaceId).notifier)
          .deleteTodoList(currentTodoList.id);

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
    if (_currentTodoList == null) return null;

    final l10n = AppLocalizations.of(context)!;
    final currentTodoList = _currentTodoList!;
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
        title: existingItem == null
            ? l10n.todoDetailAddItemTitle
            : l10n.todoDetailEditItemTitle,
        primaryButtonText: existingItem == null
            ? l10n.buttonAdd
            : l10n.buttonSave,
        showSecondaryButton: false,
        onPrimaryPressed: () {
          if (titleController.text.trim().isEmpty) {
            _showSnackBar(l10n.todoDetailItemTitleRequired, isError: true);
            return;
          }

          final item = TodoItem(
            id: existingItem?.id ?? const Uuid().v4(),
            todoListId: currentTodoList.id, // Foreign key field
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
                  decoration: InputDecoration(
                    labelText: l10n.todoDetailItemPriorityLabel,
                  ),
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
    if (_currentTodoList == null) return;

    final l10n = AppLocalizations.of(context)!;
    final currentTodoList = _currentTodoList!;
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: l10n.todoDetailDeleteListTitle,
      message: l10n.todoDetailDeleteListMessage(
        currentTodoList.name,
        currentTodoList.totalItemCount,
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
    final todoListAsync = ref.watch(todoListByIdProvider(widget.todoListId));

    return todoListAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text(l10n.todoListDetailLoadingTitle),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.todoListDetailErrorTitle),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.todoListDetailErrorMessage,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n.buttonGoBack),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (todoList) {
        if (todoList == null) {
          // TodoList not found
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.todoListDetailNotFoundTitle),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.checklist_outlined,
                      size: 64,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.todoListDetailNotFoundMessage,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: Text(l10n.buttonGoBack),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Initialize controllers with loaded data
        _initializeControllers(todoList);

        // Watch item controller for live count calculation
        final itemsAsyncValue = ref.watch(todoItemsControllerProvider(widget.todoListId));

        // Calculate counts from items for immediate UI updates
        int? calculatedTotalCount;
        int? calculatedCompletedCount;
        double? calculatedProgress;

        itemsAsyncValue.whenOrNull(
          data: (items) {
            calculatedTotalCount = items.length;
            calculatedCompletedCount = items.where((item) => item.isCompleted).length;
            calculatedProgress = calculatedTotalCount! > 0
                ? calculatedCompletedCount! / calculatedTotalCount!
                : 0.0;
          },
        );

        // Build the main UI
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
            text: _currentTodoList?.name ?? '',
            onChanged: (newName) {
              if (_nameController != null) {
                _nameController!.text = newName;
                _saveChanges();
              }
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
                      calculatedCompletedCount ?? todoList.completedItemCount,
                      calculatedTotalCount ?? todoList.totalItemCount,
                    ),
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  LinearProgressIndicator(
                    value: calculatedProgress ?? todoList.progress,
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
          label: l10n.todoDetailFabLabel,
          gradient: AppColors.taskGradient,
          enablePulse: _enableFabPulse,
        ),
      ),
        );
      },
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
