import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/organisms/dialogs/delete_confirmation_dialog.dart';
import 'package:later_mobile/design_system/tokens/colors.dart';
import 'package:later_mobile/design_system/tokens/spacing.dart';
import 'package:later_mobile/l10n/app_localizations.dart';

/// A reusable dismissible list item component that provides swipe-to-delete
/// functionality with optional confirmation dialog.
///
/// This molecule component encapsulates the common pattern of dismissible list
/// items with a red error background, delete icon, and confirmation flow.
///
/// ## Features
/// - Swipe from right-to-left (end-to-start) to reveal delete action
/// - Red error background with delete icon on the right
/// - Optional confirmation dialog before deletion
/// - Rounded corners with consistent padding
/// - Standard icon size and colors matching design system
///
/// ## Usage Example
///
/// ```dart
/// ListView.builder(
///   itemCount: items.length,
///   itemBuilder: (context, index) {
///     final item = items[index];
///     return DismissibleListItem(
///       itemKey: ValueKey(item.id),
///       itemName: item.title,
///       confirmDelete: true,
///       onDelete: () => _deleteItem(item),
///       child: ListTile(
///         title: Text(item.title),
///         subtitle: Text(item.description),
///       ),
///     );
///   },
/// )
/// ```
///
/// ## Important Notes
///
/// - **itemKey**: Must be unique for each item in the list. Use `ValueKey` with
///   the item's unique identifier (e.g., `ValueKey(item.id)`). This is crucial
///   for proper list animations and state management.
///
/// - **confirmDelete**: When `true`, shows a confirmation dialog before deletion.
///   When `false`, immediately calls `onDelete` when swiped.
///
/// - **itemName**: Used in the confirmation dialog message to provide context
///   to the user about what they're deleting.
///
/// ## Accessibility
///
/// - Provides clear visual feedback during swipe gesture
/// - Uses high-contrast error color for delete background
/// - Confirmation dialog supports screen readers
/// - Keyboard navigation support through dialog buttons
class DismissibleListItem extends StatelessWidget {
  /// Creates a dismissible list item with swipe-to-delete functionality.
  ///
  /// The [itemKey] parameter must be unique for each item in the list and is
  /// required for proper list animations. Use `ValueKey(item.id)` or similar.
  ///
  /// The [child] parameter is the widget to be displayed and made dismissible.
  ///
  /// The [onDelete] callback is invoked when the item is deleted (after
  /// confirmation if [confirmDelete] is `true`).
  ///
  /// The [itemName] is used in the confirmation dialog message to provide
  /// context about what is being deleted.
  ///
  /// The [confirmDelete] parameter determines whether to show a confirmation
  /// dialog before deletion. Defaults to `true`.
  const DismissibleListItem({
    super.key,
    required this.itemKey,
    required this.child,
    required this.onDelete,
    required this.itemName,
    this.confirmDelete = true,
  });

  /// Unique key for the dismissible item. Required for list animations.
  /// Use `ValueKey(item.id)` or similar unique identifier.
  final Key itemKey;

  /// The widget to be displayed and made dismissible.
  final Widget child;

  /// Callback invoked when the item is deleted.
  /// Called after user confirms deletion if [confirmDelete] is `true`.
  final VoidCallback onDelete;

  /// Name of the item being deleted, used in confirmation dialog message.
  /// Should be a user-friendly identifier (e.g., item title).
  final String itemName;

  /// Whether to show a confirmation dialog before deletion.
  /// When `false`, deletion happens immediately on swipe.
  /// Defaults to `true`.
  final bool confirmDelete;

  /// Shows a delete confirmation dialog.
  ///
  /// Returns a [Future] that completes with `true` if the user confirms,
  /// `false` if cancelled, or `null` if dismissed.
  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    return showDeleteConfirmationDialog(
      context: context,
      title: l10n.dialogDeleteItemTitle,
      message: l10n.dialogDeleteItemMessage(itemName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: itemKey,
      background: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            color: AppColors.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: const Icon(Icons.delete, color: Colors.white, size: 24),
          ),
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: confirmDelete
          ? (_) => _showDeleteConfirmation(context)
          : null,
      onDismissed: (_) => onDelete(),
      child: child,
    );
  }
}
