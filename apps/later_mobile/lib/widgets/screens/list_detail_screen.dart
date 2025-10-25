import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/list_model.dart';
import '../../providers/content_provider.dart';
import '../../providers/spaces_provider.dart';
import '../components/cards/list_item_card.dart';
import '../components/fab/responsive_fab.dart';
import '../components/modals/bottom_sheet_container.dart';
import '../../core/utils/responsive_modal.dart';
import '../components/text/gradient_text.dart';

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
  const ListDetailScreen({
    super.key,
    required this.list,
  });

  /// List to display and edit
  final ListModel list;

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  // Text controllers
  late TextEditingController _nameController;

  // Local state
  late ListModel _currentList;
  Timer? _debounceTimer;
  bool _isSaving = false;
  bool _hasChanges = false;
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();

    // Initialize current list
    _currentList = widget.list;

    // Initialize text controllers
    _nameController = TextEditingController(text: widget.list.name);

    // Listen to text changes for auto-save
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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

  /// Save changes to the list
  Future<void> _saveChanges() async {
    if (!_hasChanges || _isSaving) return;

    // Validate name
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('List name cannot be empty', isError: true);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Update list name
      final updated = _currentList.copyWith(
        name: _nameController.text.trim(),
      );

      // Save via provider
      final provider = Provider.of<ContentProvider>(context, listen: false);
      await provider.updateList(updated);

      setState(() {
        _currentList = updated;
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

  /// Add a new ListItem
  Future<void> _addListItem() async {
    final result = await _showListItemDialog();
    if (result == null || !mounted) return;

    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      await provider.addListItem(_currentList.id, result);

      // Reload current list
      final updated = provider.lists.firstWhere((l) => l.id == _currentList.id);
      if (mounted) {
        setState(() {
          _currentList = updated;
        });
      }

      if (mounted) _showSnackBar('Item added');
    } catch (e) {
      if (mounted) _showSnackBar('Failed to add item: $e', isError: true);
    }
  }

  /// Edit a ListItem
  Future<void> _editListItem(ListItem item) async {
    final result = await _showListItemDialog(existingItem: item);
    if (result == null || !mounted) return;

    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      await provider.updateListItem(_currentList.id, item.id, result);

      // Reload current list
      final updated = provider.lists.firstWhere((l) => l.id == _currentList.id);
      if (mounted) {
        setState(() {
          _currentList = updated;
        });
      }

      if (mounted) _showSnackBar('Item updated');
    } catch (e) {
      if (mounted) _showSnackBar('Failed to update item: $e', isError: true);
    }
  }

  /// Perform ListItem deletion without confirmation
  /// Used by Dismissible after confirmDismiss has already shown confirmation
  Future<void> _performDeleteListItem(ListItem item) async {
    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      await provider.deleteListItem(_currentList.id, item.id);

      // Reload current list
      final updated = provider.lists.firstWhere((l) => l.id == _currentList.id);
      if (mounted) {
        setState(() {
          _currentList = updated;
        });
      }

      if (mounted) _showSnackBar('Item deleted');
    } catch (e) {
      if (mounted) _showSnackBar('Failed to delete item: $e', isError: true);
    }
  }

  /// Toggle ListItem checkbox
  Future<void> _toggleListItem(ListItem item) async {
    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      await provider.toggleListItem(_currentList.id, item.id);

      // Reload current list
      final updated = provider.lists.firstWhere((l) => l.id == _currentList.id);
      setState(() {
        _currentList = updated;
      });
    } catch (e) {
      _showSnackBar('Failed to toggle item: $e', isError: true);
    }
  }

  /// Reorder ListItems
  Future<void> _reorderListItems(int oldIndex, int newIndex) async {
    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      await provider.reorderListItems(_currentList.id, oldIndex, newIndex);

      // Reload current list
      final updated = provider.lists.firstWhere((l) => l.id == _currentList.id);
      setState(() {
        _currentList = updated;
      });
    } catch (e) {
      _showSnackBar('Failed to reorder items: $e', isError: true);
    }
  }

  /// Change list style
  Future<void> _changeListStyle() async {
    final result = await _showStyleSelectionDialog();
    if (result == null || !mounted) return;

    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      final updated = _currentList.copyWith(style: result);
      await provider.updateList(updated);

      if (mounted) {
        setState(() {
          _currentList = updated;
        });
      }

      if (mounted) _showSnackBar('List style updated');
    } catch (e) {
      if (mounted) _showSnackBar('Failed to change style: $e', isError: true);
    }
  }

  /// Change list icon
  Future<void> _changeListIcon() async {
    final result = await _showIconSelectionDialog();
    if (result == null || !mounted) return;

    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      final updated = _currentList.copyWith(icon: result);
      await provider.updateList(updated);

      if (mounted) {
        setState(() {
          _currentList = updated;
        });
      }

      if (mounted) _showSnackBar('List icon updated');
    } catch (e) {
      if (mounted) _showSnackBar('Failed to change icon: $e', isError: true);
    }
  }

  /// Delete the entire List
  Future<void> _deleteList() async {
    final confirmed = await _showDeleteListConfirmation();
    if (!confirmed || !mounted) return;

    try {
      final provider = Provider.of<ContentProvider>(context, listen: false);
      final spacesProvider = Provider.of<SpacesProvider>(context, listen: false);

      await provider.deleteList(_currentList.id, spacesProvider);

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) _showSnackBar('List deleted');
    } catch (e) {
      if (mounted) _showSnackBar('Failed to delete list: $e', isError: true);
    }
  }

  /// Show ListItem edit/create dialog
  Future<ListItem?> _showListItemDialog({ListItem? existingItem}) async {
    final titleController = TextEditingController(text: existingItem?.title ?? '');
    final notesController = TextEditingController(text: existingItem?.notes ?? '');

    return ResponsiveModal.show<ListItem>(
      context: context,
      child: BottomSheetContainer(
        title: existingItem == null ? 'Add Item' : 'Edit Item',
        primaryButtonText: existingItem == null ? 'Add' : 'Save',
        onPrimaryPressed: () {
          if (titleController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Title is required')),
            );
            return;
          }

          final item = ListItem(
            id: existingItem?.id ?? const Uuid().v4(),
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
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Title *',
              hintText: 'Enter item title',
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: AppSpacing.md),

          // Notes field
          TextField(
            controller: notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Optional notes',
            ),
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
    return ResponsiveModal.show<ListStyle>(
      context: context,
      child: BottomSheetContainer(
        title: 'Select Style',
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.circle, size: 8),
            title: const Text('Bullets'),
            subtitle: const Text('Simple bullet points'),
            onTap: () => Navigator.of(context).pop(ListStyle.bullets),
          ),
          ListTile(
            leading: const Text('1.', style: TextStyle(fontWeight: FontWeight.bold)),
            title: const Text('Numbered'),
            subtitle: const Text('Numbered list items'),
            onTap: () => Navigator.of(context).pop(ListStyle.numbered),
          ),
          ListTile(
            leading: const Icon(Icons.check_box_outline_blank),
            title: const Text('Checkboxes'),
            subtitle: const Text('Checkable task items'),
            onTap: () => Navigator.of(context).pop(ListStyle.checkboxes),
          ),
        ],
        ),
      ),
    );
  }

  /// Show icon selection dialog
  Future<String?> _showIconSelectionDialog() async {
    final commonIcons = [
      '📝', '📋', '🛒', '✅', '📌', '⭐',
      '❤️', '🏠', '💼', '🎯', '🔖', '📚',
    ];

    return ResponsiveModal.show<String>(
      context: context,
      child: BottomSheetContainer(
        title: 'Select Icon',
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
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
          );
        },
        ),
      ),
    );
  }

  /// Show delete item confirmation
  Future<bool> _showDeleteItemConfirmation(String itemTitle) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Text('Are you sure you want to delete "$itemTitle"?'),
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
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  /// Show delete list confirmation
  Future<bool> _showDeleteListConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete List'),
          content: Text(
            'Are you sure you want to delete "${_currentList.name}"?\n\n'
            'This will delete all ${_currentList.items.length} items in this list. '
            'This action cannot be undone.',
          ),
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
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return result ?? false;
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
              if (_currentList.icon != null) ...[
                Text(_currentList.icon!, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: AppSpacing.sm),
              ],

              // Editable name
              Flexible(
                child: _isEditingName
                    ? TextField(
                        controller: _nameController,
                        autofocus: true,
                        style: AppTypography.h3,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'List name',
                        ),
                        onSubmitted: (_) {
                          setState(() {
                            _isEditingName = false;
                          });
                          _saveChanges();
                        },
                      )
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            _isEditingName = true;
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: GradientText(
                                _currentList.name,
                                gradient: AppColors.listGradient,
                                style: AppTypography.h3,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            const Icon(Icons.edit, size: 16),
                          ],
                        ),
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
                    _deleteList();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'changeStyle',
                  child: Row(
                    children: [
                      Icon(Icons.format_list_bulleted),
                      SizedBox(width: AppSpacing.sm),
                      Text('Change Style'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'changeIcon',
                  child: Row(
                    children: [
                      Icon(Icons.emoji_emotions),
                      SizedBox(width: AppSpacing.sm),
                      Text('Change Icon'),
                    ],
                  ),
                ),
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
            // Progress section (only for checkboxes style)
            if (_currentList.style == ListStyle.checkboxes)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: AppColors.listGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.listGradient.colors.first.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_currentList.checkedItems}/${_currentList.totalItems} completed',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(
                      value: _currentList.progress,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),

            // List items
            Expanded(
              child: _currentList.items.isEmpty
                  ? _buildEmptyState()
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _currentList.items.length,
                      onReorder: (oldIndex, newIndex) {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        _reorderListItems(oldIndex, newIndex);
                      },
                      itemBuilder: (context, index) {
                        final item = _currentList.items[index];
                        return Dismissible(
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
                          onDismissed: (_) => _performDeleteListItem(item),
                          child: ListItemCard(
                            listItem: item,
                            listStyle: _currentList.style,
                            itemIndex: index + 1, // 1-based for display
                            onCheckboxChanged: _currentList.style == ListStyle.checkboxes
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
          label: 'Add Item',
          onPressed: _addListItem,
          gradient: AppColors.listGradient,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt,
              size: 64,
              color: AppColors.listGradient.colors.first.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No items yet',
              style: AppTypography.h3.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tap the + button to add your first item',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
