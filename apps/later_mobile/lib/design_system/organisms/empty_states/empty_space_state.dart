import 'package:flutter/material.dart';
import 'empty_state.dart';

/// Empty state for spaces with no items
///
/// Displays when a space has no items, encouraging the user to create content.
///
/// Features:
/// - Dynamic space name in title
/// - Inbox icon (64px)
/// - Create CTA
///
/// Example usage:
/// ```dart
/// EmptySpaceState(
///   spaceName: 'Work',
///   onActionPressed: () => _showCreateContent(),
/// )
/// ```
class EmptySpaceState extends StatelessWidget {
  /// Creates an empty space state widget.
  const EmptySpaceState({
    super.key,
    required this.spaceName,
    required this.onActionPressed,
  });

  /// Name of the current space
  final String spaceName;

  /// Callback when Create button is pressed
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.inbox,
      title: 'Your $spaceName is empty',
      message: 'Start capturing your thoughts, tasks, and ideas',
      actionLabel: 'Create',
      onActionPressed: onActionPressed,
    );
  }
}
