import 'package:flutter/material.dart';
import 'animated_empty_state.dart';

/// Empty state displayed when a user has no spaces created
///
/// Displays when a new user starts the app with zero spaces, guiding them
/// to create their first space to get started with the app.
///
/// Features:
/// - Folder icon (64px) representing spaces
/// - Welcoming message explaining spaces
/// - Create first space CTA
/// - Entrance animations and optional FAB pulse
///
/// Example usage:
/// ```dart
/// NoSpacesState(
///   onActionPressed: () => _showCreateSpaceModal(),
///   enableFabPulse: (enabled) => setState(() => _fabPulse = enabled),
/// )
/// ```
class NoSpacesState extends StatelessWidget {
  /// Creates a no spaces empty state widget.
  const NoSpacesState({
    super.key,
    required this.onActionPressed,
    this.onSecondaryPressed,
    this.enableFabPulse,
  });

  /// Callback when "Create Your First Space" button is pressed
  final VoidCallback onActionPressed;

  /// Optional callback for secondary action
  final VoidCallback? onSecondaryPressed;

  /// Optional callback to enable/disable FAB pulse animation
  final ValueChanged<bool>? enableFabPulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedEmptyState(
      icon: Icons.folder_outlined,
      title: 'Welcome to Later',
      message:
          'Spaces organize your tasks, notes, and lists by context. Let\'s create your first one!',
      actionLabel: 'Create Your First Space',
      onActionPressed: onActionPressed,
      secondaryActionLabel:
          onSecondaryPressed != null ? 'Learn more' : null,
      onSecondaryPressed: onSecondaryPressed,
      enableFabPulse: enableFabPulse,
    );
  }
}
