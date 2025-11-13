import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:later_mobile/l10n/app_localizations.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/data/models/list_model.dart';
import 'package:later_mobile/data/models/list_item_model.dart';
import 'package:later_mobile/data/models/list_style.dart';
import '../../providers/content_provider.dart';
import 'package:later_mobile/design_system/organisms/cards/list_item_card.dart';
import 'package:later_mobile/design_system/organisms/fab/responsive_fab.dart';
import 'package:later_mobile/design_system/organisms/modals/bottom_sheet_container.dart';
import '../../core/utils/responsive_modal.dart';
import 'package:later_mobile/design_system/atoms/inputs/text_input_field.dart';
import 'package:later_mobile/design_system/atoms/inputs/text_area_field.dart';
import 'package:later_mobile/design_system/organisms/dialogs/delete_confirmation_dialog.dart';
import 'package:later_mobile/design_system/molecules/app_bars/editable_app_bar_title.dart';
import 'package:later_mobile/design_system/molecules/lists/dismissible_list_item.dart';
import 'package:later_mobile/core/mixins/auto_save_mixin.dart';
import 'package:later_mobile/design_system/organisms/empty_states/animated_empty_state.dart';

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
class ListDetailScreen extends StatefulWidget {
  const ListDetailScreen({super.key, required this.list});

  /// List to display and edit
  final ListModel list;

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen>
    with AutoSaveMixin {
  // Text controllers
  late TextEditingController _nameController;

  // Local state
  late ListModel _currentList;
  List<ListItem> _currentItems = [];
  bool _isLoadingItems = false;
  bool _enableFabPulse = false;

  @override
  void initState() {
    super.initState();

    // Initialize current list
    _currentList = widget.list;

    // Initialize text controllers
    _nameController = TextEditingController(text: widget.list.name);

    // Listen to text changes for auto-save
    _nameController.addListener(() => onFieldChanged());

    // Load list items for this list
    _loadListItems();
  }

  /// Load list items from the provider
  Future<void> _loadListItems() async {
    setState(() {
      _isLoadingItems = true;
    });

    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      final items = await provider.loadListItemsForList(widget.list.id);

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
        _showSnackBar(l10n.listDetailLoadFailed, isError: true);
      }
    }
  }

  /// Refresh the parent list from the provider to get updated counts
  Future<void> _refreshListData() async {
    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      final updated = provider.lists.firstWhere(
        (l) => l.id == _currentList.id,
      );
      if (mounted) {
        setState(() {
          _currentList = updated;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to refresh list data: $e', isError: true);
      }
    }
  }

  @override
  int get autoSaveDelayMs => 500;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Save changes to the list
  @override
  Future<void> saveChanges() async {
    if (!hasChanges || isSaving) return;

    final l10n = AppLocalizations.of(context)!;

    // Validate name
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar(l10n.listDetailNameEmpty, isError: true);
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // Update list name
      final updated = _currentList.copyWith(name: _nameController.text.trim());

      // Save via provider
      final provider = Provider.of<ContentProvider>(context, listen: false);
      await provider.updateList(updated);

      setState(() {
        _currentList = updated;
        hasChanges = false;
      });
    } catch (e) {
      _showSnackBar(l10n.listDetailSaveFailed, isError: true);
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  /// Add a new ListItem
  Future<void> _addListItem() async {
    final result = await _showListItemDialog();
    if (result == null || !mounted) return;

    final l10n = AppLocalizations.of(context)!;

    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      // Set sortOrder to be at the end of current items
      final itemWithSortOrder = result.copyWith(sortOrder: _currentItems.length);
      // createListItem takes a ListItem directly
      await provider.createListItem(itemWithSortOrder);

      // Reload items and refresh parent list data
      await _loadListItems();
      await _refreshListData();

      if (mounted) _showSnackBar(l10n.listDetailItemAdded);
    } catch (e) {
      if (mounted) _showSnackBar(l10n.listDetailItemAddFailed, isError: true);
    }
  }

  /// Edit a ListItem
  Future<void> _editListItem(ListItem item) async {
    final result = await _showListItemDialog(existingItem: item);
    if (result == null || !mounted) return;

    final l10n = AppLocalizations.of(context)!;

    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      // updateListItem takes just a ListItem
      await provider.updateListItem(result);

      // Reload items and refresh parent list data
      await _loadListItems();
      await _refreshListData();

      if (mounted) _showSnackBar(l10n.listDetailItemUpdated);
    } catch (e) {
      if (mounted) _showSnackBar(l10n.listDetailItemUpdateFailed, isError: true);
    }
  }

  /// Perform ListItem deletion without confirmation
  /// Used by Dismissible after confirmDismiss has already shown confirmation
  Future<void> _performDeleteListItem(ListItem item) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      await provider.deleteListItem(item.id, _currentList.id);

      // Reload items and refresh parent list data
      await _loadListItems();
      await _refreshListData();

      if (mounted) _showSnackBar(l10n.listDetailItemDeleted);
    } catch (e) {
      if (mounted) _showSnackBar(l10n.listDetailItemDeleteFailed, isError: true);
    }
  }

  /// Toggle ListItem checkbox
  Future<void> _toggleListItem(ListItem item) async {
    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);

      // Toggle the item by updating it with updateListItem
      final toggled = item.copyWith(isChecked: !item.isChecked);
      await provider.updateListItem(toggled);

      // Reload items and refresh parent list data
      await _loadListItems();
      await _refreshListData();
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      _showSnackBar(l10n.listDetailItemToggleFailed, isError: true);
    }
  }

  /// Reorder ListItems with optimistic UI update
  Future<void> _reorderListItems(int oldIndex, int newIndex) async {
    // Adjust newIndex when moving item down (Flutter's ReorderableListView pattern)
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    // Optimistically update local state first for immediate UI feedback
    final reorderedItems = List<ListItem>.from(_currentItems);
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
      // reorderListItems takes (listId, List<ListItem>)
      await provider.reorderListItems(_currentList.id, reorderedItems);
    } catch (e) {
      // On error, check mounted before any context usage
      if (!mounted) return;

      // Show error to user and reload items from server
      final l10n = AppLocalizations.of(context)!;
      _showSnackBar(l10n.listDetailReorderFailed, isError: true);
      await _loadListItems();
    }
  }

  /// Change list style
  Future<void> _changeListStyle() async {
    final result = await _showStyleSelectionDialog();
    if (result == null || !mounted) return;

    final l10n = AppLocalizations.of(context)!;

    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      final updated = _currentList.copyWith(style: result);
      await provider.updateList(updated);

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
    final result = await _showIconSelectionDialog();
    if (result == null || !mounted) return;

    final l10n = AppLocalizations.of(context)!;

    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      final updated = _currentList.copyWith(icon: result);
      await provider.updateList(updated);

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
    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);

      await provider.deleteList(_currentList.id);

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
    final l10n = AppLocalizations.of(context)!;
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
            listId: _currentList.id,  // Foreign key field
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
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: l10n.listDetailDeleteTitle,
      message: l10n.listDetailDeleteMessage(
        _currentList.name,
        _currentList.totalItemCount,
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          // Save before leaving
          await saveChanges();
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
              if (_currentList.icon != null) ...[
                Text(_currentList.icon!, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: AppSpacing.sm),
              ],

              // Editable name
              Flexible(
                child: EditableAppBarTitle(
                  text: _currentList.name,
                  onChanged: (newName) {
                    _nameController.text = newName;
                    saveChanges();
                  },
                  gradient: AppColors.listGradient,
                  hintText: l10n.listDetailNameHint,
                ),
              ),
            ],
          ),
          actions: [
            if (isSaving)
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
            if (_currentList.style == ListStyle.checkboxes)
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
                        _currentList.checkedItemCount,
                        _currentList.totalItemCount,
                      ),
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(
                      value: _currentList.progress,
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
                                listStyle: _currentList.style,
                                itemIndex: index,
                                onCheckboxChanged:
                                    _currentList.style == ListStyle.checkboxes
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
