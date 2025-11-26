import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:later_mobile/l10n/app_localizations.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/features/lists/domain/models/list_model.dart';
import 'package:later_mobile/features/lists/domain/models/list_item_model.dart';
import 'package:later_mobile/data/models/list_style.dart';
import 'package:later_mobile/design_system/organisms/cards/list_item_card.dart';
import 'package:later_mobile/design_system/organisms/fab/responsive_fab.dart';
import 'package:later_mobile/design_system/organisms/modals/bottom_sheet_container.dart';
import 'package:later_mobile/core/utils/responsive_modal.dart';
import 'package:later_mobile/design_system/atoms/inputs/text_input_field.dart';
import 'package:later_mobile/design_system/atoms/inputs/text_area_field.dart';
import 'package:later_mobile/design_system/organisms/dialogs/delete_confirmation_dialog.dart';
import 'package:later_mobile/design_system/molecules/app_bars/editable_app_bar_title.dart';
import 'package:later_mobile/design_system/molecules/lists/dismissible_list_item.dart';
import 'package:later_mobile/design_system/organisms/empty_states/animated_empty_state.dart';

import '../../application/providers.dart';
import '../controllers/list_items_controller.dart';
import '../controllers/lists_controller.dart';

/// List Detail Screen for viewing and editing List with ListItems
///
/// Features:
/// - Editable List name in AppBar with gradient text
/// - Custom icon display
/// - List items displayed in chosen style (bullets/numbered/checkboxes)
/// - Progress indicator for checkboxes style
/// - Add new item button (FAB)
/// - Edit item dialog (title, notes, checkbox state)
/// - Swipe-to-delete for items
/// - Drag-and-drop reordering
/// - Menu: Change style, Change icon, Delete list
/// - Auto-save with debounce (500ms)
///
/// The screen now fetches list data by ID using the listByIdProvider.
/// This enables deep linking and ensures data is always fresh from the source.
class ListDetailScreen extends ConsumerStatefulWidget {
  const ListDetailScreen({super.key, required this.listId});

  /// ID of the list to display and edit
  final String listId;

  @override
  ConsumerState<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends ConsumerState<ListDetailScreen> {
  // Text controllers (nullable until list loads)
  TextEditingController? _nameController;

  // Local state (nullable until list loads)
  ListModel? _currentList;
  List<ListItem> _currentItems = [];
  bool _isLoadingItems = false;
  Timer? _debounceTimer;
  bool _isSaving = false;
  bool _hasChanges = false;
  bool _enableFabPulse = false;

  // Track if controllers have been initialized
  bool _controllersInitialized = false;

  /// Initialize text controllers when list data is available
  void _initializeControllers(ListModel list) {
    if (_controllersInitialized) return;

    _currentList = list;
    _nameController = TextEditingController(text: list.name);

    // Listen to text changes for auto-save
    _nameController!.addListener(_onNameChanged);

    // Listen to list items controller changes
    ref.listenManual(
      listItemsControllerProvider(list.id),
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
              _showSnackBar(l10n.listDetailLoadFailed, isError: true);
            }
          },
        );
      },
      fireImmediately: true,
    );

    // Listen to lists controller to update current list
    ref.listenManual(
      listsControllerProvider(list.spaceId),
      (previous, next) {
        next.whenData((lists) {
          final updated = lists.firstWhere(
            (l) => l.id == _currentList!.id,
            orElse: () => _currentList!,
          );
          if (mounted) {
            setState(() {
              _currentList = updated;
            });
          }
        });
      },
      fireImmediately: true,
    );

    _controllersInitialized = true;
  }

  @override
  void initState() {
    super.initState();
    // Controllers will be initialized in build when data loads
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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

  /// Save changes to the list
  Future<void> _saveChanges() async {
    if (!_hasChanges || _isSaving || _currentList == null || _nameController == null) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final currentList = _currentList!;
    final nameController = _nameController!;

    // Validate name
    if (nameController.text.trim().isEmpty) {
      _showSnackBar(l10n.listDetailNameEmpty, isError: true);
      // Restore previous name
      nameController.text = currentList.name;
      setState(() {
        _hasChanges = false;
      });
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Update list name
      final updated = currentList.copyWith(
        name: nameController.text.trim(),
      );

      // Save via Riverpod controller
      await ref
          .read(listsControllerProvider(currentList.spaceId).notifier)
          .updateList(updated);

      setState(() {
        _currentList = updated;
        _hasChanges = false;
      });
    } catch (e) {
      _showSnackBar(l10n.listDetailSaveFailed, isError: true);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  /// Add a new ListItem
  Future<void> _addListItem() async {
    if (_currentList == null) return;

    final result = await _showListItemDialog();
    if (result == null || !mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final currentList = _currentList!;

    try {
      // Set sortOrder to be at the end of current items
      final itemWithSortOrder = result.copyWith(
        sortOrder: _currentItems.length,
      );

      // Create item via Riverpod controller
      await ref
          .read(listItemsControllerProvider(currentList.id).notifier)
          .createItem(itemWithSortOrder);

      // Refresh parent list to get updated counts
      await ref
          .read(listsControllerProvider(currentList.spaceId).notifier)
          .refresh();

      if (mounted) _showSnackBar(l10n.listDetailItemAdded);
    } catch (e) {
      if (mounted) _showSnackBar(l10n.listDetailItemAddFailed, isError: true);
    }
  }

  /// Edit a ListItem
  Future<void> _editListItem(ListItem item) async {
    if (_currentList == null) return;

    final result = await _showListItemDialog(existingItem: item);
    if (result == null || !mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final currentList = _currentList!;

    try {
      // Update item via Riverpod controller
      await ref
          .read(listItemsControllerProvider(currentList.id).notifier)
          .updateItem(result);

      // Refresh parent list to get updated counts
      await ref
          .read(listsControllerProvider(currentList.spaceId).notifier)
          .refresh();

      if (mounted) _showSnackBar(l10n.listDetailItemUpdated);
    } catch (e) {
      if (mounted) {
        _showSnackBar(l10n.listDetailItemUpdateFailed, isError: true);
      }
    }
  }

  /// Perform the actual deletion without confirmation
  /// Used by Dismissible which handles confirmation separately
  Future<void> _performDeleteListItem(ListItem item) async {
    if (_currentList == null) return;

    final l10n = AppLocalizations.of(context)!;
    final currentList = _currentList!;

    try {
      // Delete item via Riverpod controller
      await ref
          .read(listItemsControllerProvider(currentList.id).notifier)
          .deleteItem(item.id, currentList.id);

      // Refresh parent list to get updated counts
      await ref
          .read(listsControllerProvider(currentList.spaceId).notifier)
          .refresh();

      if (mounted) _showSnackBar(l10n.listDetailItemDeleted);
    } catch (e) {
      if (mounted) {
        _showSnackBar(l10n.listDetailItemDeleteFailed, isError: true);
      }
    }
  }

  /// Toggle ListItem checkbox
  Future<void> _toggleListItem(ListItem item) async {
    if (_currentList == null) return;

    final currentList = _currentList!;

    try {
      // Toggle item via Riverpod controller
      await ref
          .read(listItemsControllerProvider(currentList.id).notifier)
          .toggleItem(item);

      // Refresh parent list to get updated counts
      await ref
          .read(listsControllerProvider(currentList.spaceId).notifier)
          .refresh();
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      _showSnackBar(l10n.listDetailItemToggleFailed, isError: true);
    }
  }

  /// Reorder ListItems with optimistic UI update
  Future<void> _reorderListItems(int oldIndex, int newIndex) async {
    if (_currentList == null) return;

    // Adjust newIndex when moving item down (Flutter's ReorderableListView pattern)
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    // Optimistically update local state first for immediate UI feedback
    final reorderedItems = List<ListItem>.from(_currentItems);
    final item = reorderedItems.removeAt(oldIndex);
    reorderedItems.insert(newIndex, item);

    setState(() {
      _currentItems = reorderedItems;
    });

    final currentList = _currentList!;

    // Then persist via Riverpod controller in the background
    try {
      // Extract IDs in the new order
      final orderedIds = reorderedItems.map((item) => item.id).toList();

      // Call controller to reorder
      await ref
          .read(listItemsControllerProvider(currentList.id).notifier)
          .reorderItems(orderedIds);
    } catch (e) {
      // On error, check mounted before any context usage
      if (!mounted) return;

      // Show error to user - controller will reload items from server
      final l10n = AppLocalizations.of(context)!;
      _showSnackBar(l10n.listDetailReorderFailed, isError: true);
    }
  }

  /// Change list style
  Future<void> _changeListStyle() async {
    if (_currentList == null) return;

    final result = await _showStyleSelectionDialog();
    if (result == null || !mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final currentList = _currentList!;

    try {
      final updated = currentList.copyWith(style: result);
      await ref
          .read(listsControllerProvider(currentList.spaceId).notifier)
          .updateList(updated);

      if (mounted) {
        setState(() {
          _currentList = updated;
        });
      }

      if (mounted) _showSnackBar(l10n.listDetailStyleUpdated);
    } catch (e) {
      if (mounted) _showSnackBar(l10n.listDetailStyleChangeFailed, isError: true);
    }
  }

  /// Change list icon
  Future<void> _changeListIcon() async {
    if (_currentList == null) return;

    final result = await _showIconSelectionDialog();
    if (result == null || !mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final currentList = _currentList!;

    try {
      final updated = currentList.copyWith(icon: result);
      await ref
          .read(listsControllerProvider(currentList.spaceId).notifier)
          .updateList(updated);

      if (mounted) {
        setState(() {
          _currentList = updated;
        });
      }

      if (mounted) _showSnackBar(l10n.listDetailIconUpdated);
    } catch (e) {
      if (mounted) _showSnackBar(l10n.listDetailIconChangeFailed, isError: true);
    }
  }

  /// Delete the entire List
  /// Note: Navigation is handled in _showDeleteListConfirmation(), not here
  Future<void> _deleteList() async {
    if (_currentList == null) return;

    final currentList = _currentList!;

    try {
      // Delete list via Riverpod controller
      await ref
          .read(listsControllerProvider(currentList.spaceId).notifier)
          .deleteList(currentList.id);

      // Navigation already handled in confirmation dialog
      // Success feedback is provided by UI update (list removed from list)
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showSnackBar(l10n.listDetailDeleteFailed, isError: true);
      }
    }
  }

  /// Show ListItem edit/create dialog
  Future<ListItem?> _showListItemDialog({ListItem? existingItem}) async {
    if (_currentList == null) return null;

    final l10n = AppLocalizations.of(context)!;
    final currentList = _currentList!;
    final titleController = TextEditingController(
      text: existingItem?.title ?? '',
    );
    final notesController = TextEditingController(
      text: existingItem?.notes ?? '',
    );

    return ResponsiveModal.show<ListItem>(
      context: context,
      child: BottomSheetContainer(
        title: existingItem == null ? l10n.listDetailAddItemTitle : l10n.listDetailEditItemTitle,
        primaryButtonText: existingItem == null ? l10n.buttonAdd : l10n.buttonSave,
        showSecondaryButton: false,
        onPrimaryPressed: () {
          if (titleController.text.trim().isEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.listDetailItemTitleRequired)));
            return;
          }

          final item = ListItem(
            id: existingItem?.id ?? const Uuid().v4(),
            listId: currentList.id,  // Foreign key field
            title: titleController.text.trim(),
            notes: notesController.text.trim().isEmpty
                ? null
                : notesController.text.trim(),
            isChecked: existingItem?.isChecked ?? false,
            sortOrder: existingItem?.sortOrder ?? 0,
          );

          Navigator.of(context).pop(item);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            TextInputField(
              controller: titleController,
              label: l10n.listDetailItemTitleLabel,
              hintText: l10n.listDetailItemTitleHint,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.md),

            // Notes field
            TextAreaField(
              controller: notesController,
              label: l10n.listDetailItemNotesLabel,
              hintText: l10n.listDetailItemNotesHint,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
    );
  }

  /// Show style selection dialog
  Future<ListStyle?> _showStyleSelectionDialog() async {
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveModal.show<ListStyle>(
      context: context,
      child: BottomSheetContainer(
        title: l10n.listDetailStyleDialogTitle,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.circle, size: 8),
              title: Text(l10n.listDetailStyleBullets),
              subtitle: Text(l10n.listDetailStyleBulletsDesc),
              onTap: () => Navigator.of(context).pop(ListStyle.bullets),
            ),
            ListTile(
              leading: const Text(
                '1.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              title: Text(l10n.listDetailStyleNumbered),
              subtitle: Text(l10n.listDetailStyleNumberedDesc),
              onTap: () => Navigator.of(context).pop(ListStyle.numbered),
            ),
            ListTile(
              leading: const Icon(Icons.check_box_outline_blank),
              title: Text(l10n.listDetailStyleCheckboxes),
              subtitle: Text(l10n.listDetailStyleCheckboxesDesc),
              onTap: () => Navigator.of(context).pop(ListStyle.checkboxes),
            ),
          ],
        ),
      ),
    );
  }

  /// Show icon selection dialog
  Future<String?> _showIconSelectionDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final commonIcons = [
      '📝',
      '📋',
      '🛒',
      '✅',
      '📌',
      '⭐',
      '❤️',
      '🏠',
      '💼',
      '🎯',
      '🔖',
      '📚',
    ];

    return ResponsiveModal.show<String>(
      context: context,
      child: BottomSheetContainer(
        title: l10n.listDetailIconDialogTitle,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            mainAxisExtent: 56, // Minimum 48px touch target + padding
          ),
          itemCount: commonIcons.length,
          itemBuilder: (context, index) {
            final icon = commonIcons[index];
            return InkWell(
              onTap: () => Navigator.of(context).pop(icon),
              borderRadius: BorderRadius.circular(AppSpacing.xs),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border(context)),
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 32)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Show delete list confirmation
  Future<void> _showDeleteListConfirmation() async {
    if (_currentList == null) return;

    final l10n = AppLocalizations.of(context)!;
    final currentList = _currentList!;
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: l10n.listDetailDeleteTitle,
      message: l10n.listDetailDeleteMessage(
        currentList.name,
        currentList.totalItemCount,
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop(); // Return to previous screen
      await _deleteList();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final listAsync = ref.watch(listByIdProvider(widget.listId));

    return listAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text(l10n.listDetailLoadingTitle),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.listDetailErrorTitle),
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
                  l10n.listDetailErrorMessage,
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
      data: (list) {
        if (list == null) {
          // List not found
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.listDetailNotFoundTitle),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.list_alt_outlined,
                      size: 64,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.listDetailNotFoundMessage,
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

        // Initialize controllers with the loaded list
        _initializeControllers(list);

        // Watch item controller for live count calculation
        final itemsAsyncValue = ref.watch(listItemsControllerProvider(list.id));

    // Calculate counts from items for live updates
    final int? calculatedTotalCount = itemsAsyncValue.whenOrNull(
      data: (items) => items.length,
    );
    final int? calculatedCheckedCount = itemsAsyncValue.whenOrNull(
      data: (items) => items.where((item) => item.isChecked).length,
    );
    final double? calculatedProgress = itemsAsyncValue.whenOrNull(
      data: (items) {
        if (items.isEmpty) return 0.0;
        final checkedCount = items.where((item) => item.isChecked).length;
        return checkedCount / items.length;
      },
    );

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
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon (if available)
              if (list.icon != null) ...[
                Text(list.icon!, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: AppSpacing.sm),
              ],

              // Editable name
              Flexible(
                child: EditableAppBarTitle(
                  text: list.name,
                  onChanged: (newName) {
                    _nameController!.text = newName;
                    _saveChanges();
                  },
                  gradient: AppColors.listGradient,
                  hintText: l10n.listDetailNameHint,
                ),
              ),
            ],
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
                switch (value) {
                  case 'changeStyle':
                    _changeListStyle();
                    break;
                  case 'changeIcon':
                    _changeListIcon();
                    break;
                  case 'delete':
                    _showDeleteListConfirmation();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'changeStyle',
                  child: Row(
                    children: [
                      const Icon(Icons.format_list_bulleted),
                      const SizedBox(width: AppSpacing.sm),
                      Text(l10n.listDetailMenuChangeStyle),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'changeIcon',
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_emotions),
                      const SizedBox(width: AppSpacing.sm),
                      Text(l10n.listDetailMenuChangeIcon),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: AppColors.error),
                      const SizedBox(width: AppSpacing.sm),
                      Text(l10n.listDetailMenuDelete),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress section (only for checkboxes style)
            if (list.style == ListStyle.checkboxes)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: AppColors.listGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.listGradient.colors.first.withValues(
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
                      l10n.listDetailProgressCompleted(
                        calculatedCheckedCount ?? list.checkedItemCount,
                        calculatedTotalCount ?? list.totalItemCount,
                      ),
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(
                      value: calculatedProgress ?? list.progress,
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

            // List items
            Expanded(
              child: _isLoadingItems
                  ? const Center(child: CircularProgressIndicator())
                  : _currentItems.isEmpty
                      ? _buildEmptyState()
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: _currentItems.length,
                          onReorder: _reorderListItems,
                          itemBuilder: (context, index) {
                            final item = _currentItems[index];
                            final itemKey = ValueKey(item.id);
                            return DismissibleListItem(
                              key: itemKey,
                              itemKey: itemKey,
                              itemName: item.title,
                              onDelete: () => _performDeleteListItem(item),
                              child: ListItemCard(
                                listItem: item,
                                listStyle: list.style,
                                itemIndex: index,
                                onCheckboxChanged:
                                    list.style == ListStyle.checkboxes
                                    ? (value) => _toggleListItem(item)
                                    : null,
                                onLongPress: () => _editListItem(item),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
        floatingActionButton: ResponsiveFab(
          icon: Icons.add,
          label: l10n.listDetailFabLabel,
          onPressed: _addListItem,
          gradient: AppColors.listGradient,
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
      icon: Icons.list_alt,
      title: l10n.listDetailEmptyTitle,
      message: l10n.listDetailEmptyMessage,
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
