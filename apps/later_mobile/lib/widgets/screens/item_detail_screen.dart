import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/item_model.dart';
import '../../providers/items_provider.dart';
import '../../providers/spaces_provider.dart';
import '../components/text/gradient_text.dart';

/// Item Detail Screen for viewing and editing item details
///
/// Features:
/// - Full screen on mobile and desktop
/// - Editable title (auto-focus) and content fields
/// - Item type badge indicator
/// - Type conversion (task ↔ note ↔ list) with data loss warnings
/// - Space selector dropdown
/// - Due date picker for tasks
/// - Tags display (read-only chips)
/// - Completion checkbox for tasks
/// - Auto-save with 500ms debounce
/// - Save on navigation away
/// - Delete with confirmation dialog and undo functionality (5-second window)
/// - Keyboard shortcuts (Esc, Cmd/Ctrl+S, Cmd/Ctrl+Backspace)
/// - Form validation (title required)
/// - Metadata footer (created/modified timestamps)
class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({
    super.key,
    required this.item,
  });

  /// Item to display and edit
  final Item item;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  // Local state
  late Item _currentItem;
  Timer? _debounceTimer;
  Timer? _deletionTimer;
  bool _isSaving = false;
  bool _hasChanges = false;
  Item? _pendingDeletion;

  @override
  void initState() {
    super.initState();

    // Initialize current item
    _currentItem = widget.item;

    // Initialize text controllers
    _titleController = TextEditingController(text: widget.item.title);
    _contentController = TextEditingController(text: widget.item.content ?? '');

    // Listen to text changes for auto-save
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _deletionTimer?.cancel();
    _titleController.removeListener(_onTextChanged);
    _contentController.removeListener(_onTextChanged);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Handle text changes and trigger debounced save
  void _onTextChanged() {
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

  /// Save changes to the item
  Future<void> _saveChanges() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Skip if no changes
    if (!_hasChanges) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Update item with new values
      final updatedItem = _currentItem.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim().isEmpty
            ? null
            : _contentController.text.trim(),
        updatedAt: DateTime.now(),
      );

      // Save to provider
      await context.read<ItemsProvider>().updateItem(updatedItem);

      // Update local state
      setState(() {
        _currentItem = updatedItem;
        _hasChanges = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Handle back button press (save before exit)
  Future<bool> _onWillPop() async {
    // Save changes if any
    if (_hasChanges) {
      await _saveChanges();
    }
    return true;
  }

  /// Toggle completion status for tasks
  Future<void> _toggleCompletion(bool value) async {
    final updatedItem = _currentItem.copyWith(
      isCompleted: value,
      updatedAt: DateTime.now(),
    );

    setState(() {
      _currentItem = updatedItem;
      _hasChanges = true;
    });

    await context.read<ItemsProvider>().updateItem(updatedItem);

    setState(() {
      _hasChanges = false;
    });
  }

  /// Change space
  Future<void> _changeSpace(String newSpaceId) async {
    if (newSpaceId == _currentItem.spaceId) return;

    final oldSpaceId = _currentItem.spaceId;
    final updatedItem = _currentItem.copyWith(
      spaceId: newSpaceId,
      updatedAt: DateTime.now(),
    );

    setState(() {
      _currentItem = updatedItem;
      _hasChanges = true;
    });

    // Capture providers before async gap
    final itemsProvider = context.read<ItemsProvider>();
    final spacesProvider = context.read<SpacesProvider>();

    await itemsProvider.updateItem(updatedItem);

    // Update space item counts
    await spacesProvider.decrementSpaceItemCount(oldSpaceId);
    await spacesProvider.incrementSpaceItemCount(newSpaceId);

    if (mounted) {
      setState(() {
        _hasChanges = false;
      });
    }
  }

  /// Pick due date for tasks
  Future<void> _pickDueDate() async {
    final initialDate = _currentItem.dueDate ?? DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && mounted) {
      final updatedItem = _currentItem.copyWith(
        dueDate: pickedDate,
        updatedAt: DateTime.now(),
      );

      setState(() {
        _currentItem = updatedItem;
        _hasChanges = true;
      });

      // Capture provider before async gap
      final itemsProvider = context.read<ItemsProvider>();
      await itemsProvider.updateItem(updatedItem);

      if (mounted) {
        setState(() {
          _hasChanges = false;
        });
      }
    }
  }

  /// Clear due date
  Future<void> _clearDueDate() async {
    final updatedItem = _currentItem.copyWith(
      clearDueDate: true,
      updatedAt: DateTime.now(),
    );

    setState(() {
      _currentItem = updatedItem;
      _hasChanges = true;
    });

    // Capture provider before async gap
    final itemsProvider = context.read<ItemsProvider>();
    await itemsProvider.updateItem(updatedItem);

    if (mounted) {
      setState(() {
        _hasChanges = false;
      });
    }
  }

  /// Show delete confirmation dialog with gradient button
  Future<void> _showDeleteConfirmation() async {
    final itemTypeName = _currentItem.type.toString().split('.').last;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $itemTypeName?'),
        content: const Text('You can undo this action within 5 seconds.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.error,
                  AppColors.errorDark,
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
              ),
              child: const Text('Delete'),
            ),
          ),
        ],
        semanticLabel: 'Delete confirmation dialog',
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteItem();
    }
  }

  /// Delete the item with undo functionality
  Future<void> _deleteItem() async {
    // Store the item for potential undo
    _pendingDeletion = _currentItem;

    // Capture context and providers before async gap
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final itemsProvider = context.read<ItemsProvider>();
    final spacesProvider = context.read<SpacesProvider>();

    // Remove from UI immediately (optimistic deletion)
    await itemsProvider.deleteItem(_currentItem.id);

    // Pop screen immediately
    if (mounted) {
      navigator.pop();
    }

    // Show undo snackbar on parent screen
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: const Text('Item deleted'),
        backgroundColor: AppColors.accentGreen,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            _undoDeletion(itemsProvider);
          },
        ),
      ),
    );

    // Set up timer for actual deletion after 5 seconds
    _deletionTimer?.cancel();
    _deletionTimer = Timer(const Duration(seconds: 5), () {
      if (_pendingDeletion != null) {
        _performActualDeletion(_pendingDeletion!, spacesProvider);
        _pendingDeletion = null;
      }
    });
  }

  /// Undo the deletion by restoring the item
  void _undoDeletion(ItemsProvider itemsProvider) {
    if (_pendingDeletion == null) return;

    // Cancel the actual deletion timer
    _deletionTimer?.cancel();

    // Restore the item to the provider
    itemsProvider.addItem(_pendingDeletion!);

    // Clear pending deletion
    _pendingDeletion = null;
  }

  /// Perform the actual deletion (after undo timeout)
  Future<void> _performActualDeletion(
    Item item,
    SpacesProvider spacesProvider,
  ) async {
    try {
      // Decrement space item count
      await spacesProvider.decrementSpaceItemCount(item.spaceId);
    } catch (e) {
      // Silently handle errors in background deletion
      debugPrint('Failed to update space count after deletion: $e');
    }
  }

  /// Show conversion dialog to convert item type
  Future<void> _showConvertDialog() async {
    // Get available conversion types (exclude current type)
    final availableTypes = ItemType.values
        .where((type) => type != _currentItem.type)
        .toList();

    // Check if conversion would lose data
    final hasDataLoss = _currentItem.type == ItemType.task &&
        (_currentItem.dueDate != null || _currentItem.isCompleted);

    final selectedType = await showDialog<ItemType>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Convert to...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasDataLoss)
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryAmber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                  border: Border.all(
                    color: AppColors.primaryAmber,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      color: AppColors.primaryAmber,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        _getDataLossWarning(),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primaryAmber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ...availableTypes.map((type) {
              return ListTile(
                title: Text(_getItemTypeDisplayName(type)),
                onTap: () {
                  Navigator.of(context).pop(type);
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
        semanticLabel: 'Convert item type dialog',
      ),
    );

    if (selectedType != null && mounted) {
      await _convertItemType(selectedType);
    }
  }

  /// Convert item to a different type
  Future<void> _convertItemType(ItemType newType) async {
    // Capture context before any async gaps
    final itemsProvider = context.read<ItemsProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Save any pending changes first
      if (_hasChanges) {
        await _saveChanges();
      }

      // Create converted item
      final convertedItem = _currentItem.copyWith(
        type: newType,
        // Reset type-specific fields based on conversion
        isCompleted: newType == ItemType.task ? false : _currentItem.isCompleted,
        dueDate: newType == ItemType.task
            ? _currentItem.dueDate
            : null, // Clear due date if not converting to task
        clearDueDate: newType != ItemType.task && _currentItem.dueDate != null,
        updatedAt: DateTime.now(),
      );

      // Update in provider
      await itemsProvider.updateItem(convertedItem);

      // Update local state
      if (mounted) {
        setState(() {
          _currentItem = convertedItem;
        });

        // Show success message
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Converted to ${_getItemTypeDisplayName(newType).toLowerCase()}',
            ),
            backgroundColor: AppColors.accentGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to convert: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Get data loss warning message for conversion
  String _getDataLossWarning() {
    if (_currentItem.type != ItemType.task) return '';

    final warnings = <String>[];
    if (_currentItem.dueDate != null) {
      warnings.add('due date');
    }
    if (_currentItem.isCompleted) {
      warnings.add('completion status');
    }

    if (warnings.isEmpty) return '';

    return 'Warning: ${warnings.join(' and ')} will be lost';
  }

  /// Get display name for item type
  String _getItemTypeDisplayName(ItemType type) {
    switch (type) {
      case ItemType.task:
        return 'Task';
      case ItemType.note:
        return 'Note';
      case ItemType.list:
        return 'List';
    }
  }

  /// Handle keyboard shortcuts
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // Escape: Close screen
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }

    // Cmd/Ctrl+S: Force save
    if ((event.logicalKey == LogicalKeyboardKey.keyS) &&
        (HardwareKeyboard.instance.isMetaPressed ||
            HardwareKeyboard.instance.isControlPressed)) {
      _saveChanges();
      return KeyEventResult.handled;
    }

    // Cmd/Ctrl+Backspace: Delete
    if ((event.logicalKey == LogicalKeyboardKey.backspace) &&
        (HardwareKeyboard.instance.isMetaPressed ||
            HardwareKeyboard.instance.isControlPressed)) {
      _showDeleteConfirmation();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  /// Get item type badge color
  Color _getItemTypeBadgeColor() {
    switch (_currentItem.type) {
      case ItemType.task:
        return AppColors.itemBorderTask;
      case ItemType.note:
        return AppColors.itemBorderNote;
      case ItemType.list:
        return AppColors.itemBorderList;
    }
  }

  /// Get item type badge text
  String _getItemTypeBadgeText() {
    switch (_currentItem.type) {
      case ItemType.task:
        return 'Task';
      case ItemType.note:
        return 'Note';
      case ItemType.list:
        return 'List';
    }
  }

  /// Get gradient for item type
  LinearGradient _getTypeGradient() {
    switch (_currentItem.type) {
      case ItemType.task:
        return AppColors.taskGradient;
      case ItemType.note:
        return AppColors.noteGradient;
      case ItemType.list:
        return AppColors.listGradient;
    }
  }

  /// Build item type badge with gradient background
  Widget _buildItemTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        gradient: _getTypeGradient(),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        boxShadow: [
          BoxShadow(
            color: _getItemTypeBadgeColor().withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        _getItemTypeBadgeText(),
        style: AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Build completion checkbox for tasks with gradient styling
  Widget? _buildCompletionCheckbox() {
    if (_currentItem.type != ItemType.task) return null;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: _currentItem.isCompleted
            ? LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.1),
                  AppColors.successLight.withValues(alpha: 0.05),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
      ),
      child: CheckboxListTile(
        title: Text(
          'Mark as complete',
          style: AppTypography.bodyMedium.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            decoration:
                _currentItem.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        value: _currentItem.isCompleted,
        onChanged: (value) {
          if (value != null) {
            _toggleCompletion(value);
          }
        },
        activeColor: AppColors.success,
        checkColor: Colors.white,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
    );
  }

  /// Build space selector dropdown
  Widget _buildSpaceSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spacesProvider = context.watch<SpacesProvider>();
    final spaces = spacesProvider.spaces;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Space',
          style: AppTypography.labelMedium.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSpacing.xxxs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxxs,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currentItem.spaceId,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (value) {
                if (value != null) {
                  _changeSpace(value);
                }
              },
              items: spaces.map((space) {
                return DropdownMenuItem<String>(
                  value: space.id,
                  child: Row(
                    children: [
                      if (space.icon != null) ...[
                        Text(space.icon!, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Text(
                        space.name,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Build due date picker for tasks
  Widget? _buildDueDatePicker() {
    if (_currentItem.type != ItemType.task) return null;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d, y');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date',
          style: AppTypography.labelMedium.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSpacing.xxxs),
        InkWell(
          onTap: _pickDueDate,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    _currentItem.dueDate != null
                        ? dateFormat.format(_currentItem.dueDate!)
                        : 'No due date',
                    style: AppTypography.bodyMedium.copyWith(
                      color: _currentItem.dueDate != null
                          ? (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight)
                          : (isDark
                              ? AppColors.textDisabledDark
                              : AppColors.textDisabledLight),
                    ),
                  ),
                ),
                if (_currentItem.dueDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearDueDate,
                    iconSize: 20,
                    tooltip: 'Clear due date',
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build tags display (read-only)
  Widget? _buildTagsDisplay() {
    if (_currentItem.tags.isEmpty) return null;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: AppTypography.labelMedium.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSpacing.xxxs),
        Wrap(
          spacing: AppSpacing.xxs,
          runSpacing: AppSpacing.xxs,
          children: _currentItem.tags.map((tag) {
            return Chip(
              label: Text(
                tag,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              backgroundColor:
                  isDark ? AppColors.surfaceDarkVariant : AppColors.surfaceLightVariant,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxs,
                vertical: AppSpacing.xxxs,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build metadata footer with softer visual hierarchy
  Widget _buildMetadataFooter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d, y \'at\' h:mm a');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.glassDark : AppColors.glassLight)
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        border: Border.all(
          color: isDark
              ? AppColors.glassBorderDark
              : AppColors.glassBorderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Created icon with subtle gradient tint
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradientAdaptive(context).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: const Icon(
                  Icons.add_circle_outline,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Created: ',
                      style: AppTypography.caption.copyWith(
                        color: (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight)
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    // Date with subtle gradient
                    GradientText.subtle(
                      dateFormat.format(_currentItem.createdAt),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              // Updated icon with subtle gradient tint
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.secondaryGradient.createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: const Icon(
                  Icons.update,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Modified: ',
                      style: AppTypography.caption.copyWith(
                        color: (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight)
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    // Date with subtle secondary gradient
                    GradientText.subtle(
                      dateFormat.format(_currentItem.updatedAt),
                      gradient: AppColors.secondaryGradient,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build saving indicator
  Widget? _buildSavingIndicator() {
    if (!_isSaving) return null;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryAmber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            'Saving...',
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  /// Build gradient separator
  Widget _buildGradientSeparator() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            _getItemTypeBadgeColor().withValues(alpha: 0.3),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  /// Build gradient header
  Widget _buildGradientHeader(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: _getTypeGradient(),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 80, // Fixed height for the action bar
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Back',
                ),
                // Actions
                Row(
                  children: [
                    // Convert type button
                    IconButton(
                      icon: const Icon(Icons.swap_horiz, color: Colors.white),
                      onPressed: _showConvertDialog,
                      tooltip: 'Convert to...',
                    ),
                    // Delete button
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.white),
                      onPressed: _showDeleteConfirmation,
                      tooltip: 'Delete',
                    ),
                    // Save button (optional)
                    if (_hasChanges)
                      IconButton(
                        icon: const Icon(Icons.save_outlined, color: Colors.white),
                        onPressed: _saveChanges,
                        tooltip: 'Save',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build glass container wrapper
  Widget _buildGlassContainer({required Widget child, EdgeInsets? padding}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        border: Border.all(
          color: isDark
              ? AppColors.glassBorderDark
              : AppColors.glassBorderLight,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onWillPop();
        }
      },
      child: Focus(
        onKeyEvent: _handleKeyEvent,
        child: Scaffold(
          backgroundColor:
              isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          body: Column(
            children: [
              // Gradient header
              _buildGradientHeader(isDark),

              // Content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Type badge and saving indicator in glass container
                        _buildGlassContainer(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              _buildItemTypeBadge(),
                              const SizedBox(width: AppSpacing.xs),
                              if (_buildSavingIndicator() != null)
                                _buildSavingIndicator()!,
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Completion checkbox (tasks only) in glass container
                        if (_buildCompletionCheckbox() != null) ...[
                          _buildGlassContainer(
                            padding: EdgeInsets.zero,
                            child: _buildCompletionCheckbox()!,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

                        // Title and content fields in glass container
                        _buildGlassContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title field
                              TextFormField(
                                controller: _titleController,
                                autofocus: true,
                                style: AppTypography.h3.copyWith(
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Title',
                                  hintStyle: AppTypography.h3.copyWith(
                                    color: isDark
                                        ? AppColors.textDisabledDark
                                        : AppColors.textDisabledLight,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Title is required';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                              ),

                              _buildGradientSeparator(),

                              // Content field
                              TextFormField(
                                controller: _contentController,
                                style: AppTypography.bodyLarge.copyWith(
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Add content...',
                                  hintStyle: AppTypography.bodyLarge.copyWith(
                                    color: isDark
                                        ? AppColors.textDisabledDark
                                        : AppColors.textDisabledLight,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                maxLines: null,
                                minLines: 3,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Metadata section in glass container
                        _buildGlassContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Space selector
                              _buildSpaceSelector(context),

                              // Due date picker (tasks only)
                              if (_buildDueDatePicker() != null) ...[
                                _buildGradientSeparator(),
                                _buildDueDatePicker()!,
                              ],

                              // Tags display (if any)
                              if (_buildTagsDisplay() != null) ...[
                                _buildGradientSeparator(),
                                _buildTagsDisplay()!,
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Metadata footer
                        _buildMetadataFooter(),

                        // Extra padding at bottom for comfortable scrolling
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
