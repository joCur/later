import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/atoms/buttons/danger_button.dart';
import 'package:later_mobile/design_system/atoms/buttons/ghost_button.dart';

/// Shows a delete confirmation dialog with a title, message, and action buttons.
///
/// Returns `true` if the user confirms the deletion, `false` if cancelled,
/// or `null` if the dialog is dismissed (e.g., by tapping outside).
///
/// Example usage:
/// ```dart
/// final confirmed = await showDeleteConfirmationDialog(
///   context: context,
///   title: 'Delete Item?',
///   message: 'This action cannot be undone.',
/// );
///
/// if (confirmed == true) {
///   // Perform delete operation
/// }
/// ```
Future<bool?> showDeleteConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmButtonText = 'Delete',
}) async {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          GhostButton(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(false),
          ),
          DangerButton(
            text: confirmButtonText,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );
}
