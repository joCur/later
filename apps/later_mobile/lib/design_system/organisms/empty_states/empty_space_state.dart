import 'package:flutter/material.dart';
import 'animated_empty_state.dart';

/// Empty state for spaces with no items
///
/// Displays when a space has no items, encouraging the user to create content.
///
/// Features:
/// - Dynamic space name in title
/// - Inbox icon (64px)
/// - Create CTA
/// - Entrance animations and optional FAB pulse
///
/// Example usage:
/// ```dart
/// EmptySpaceState(
///   spaceName: 'Work',
///   onActionPressed: () => _showCreateContent(),
///   enableFabPulse: (enabled) => setState(() => _fabPulse = enabled),
/// )
/// ```
class EmptySpaceState extends StatelessWidget {
  /// Creates an empty space state widget.
  const EmptySpaceState({
    super.key,
    required this.spaceName,
    required this.onActionPressed,
    this.enableFabPulse,
  });

  /// Name of the current space
  final String spaceName;

  /// Callback when Create button is pressed
  final VoidCallback onActionPressed;

  /// Optional callback to enable/disable FAB pulse animation
  final ValueChanged<bool>? enableFabPulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedEmptyState(
      icon: Icons.inbox,
      title: 'Your $spaceName is empty',
      message: 'Start capturing your thoughts, tasks, and ideas',
      actionLabel: 'Create',
      onActionPressed: onActionPressed,
      enableFabPulse: enableFabPulse,
    );
  }
}
