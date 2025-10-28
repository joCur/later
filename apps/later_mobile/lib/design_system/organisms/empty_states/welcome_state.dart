import 'package:flutter/material.dart';
import 'empty_state.dart';

/// Welcome state for first app launch
///
/// Displays when the user opens the app for the first time with no items.
///
/// Features:
/// - Sparkles icon (64px)
/// - Welcoming message
/// - Create first item CTA
/// - Optional "Learn how it works" secondary action
///
/// Example usage:
/// ```dart
/// WelcomeState(
///   onActionPressed: () => _showCreateContent(),
///   onSecondaryPressed: () => _showOnboarding(), // optional
/// )
/// ```
class WelcomeState extends StatelessWidget {
  /// Creates a welcome state widget.
  const WelcomeState({
    super.key,
    required this.onActionPressed,
    this.onSecondaryPressed,
  });

  /// Callback when "Create your first item" button is pressed
  final VoidCallback onActionPressed;

  /// Optional callback when "Learn how it works" secondary action is pressed
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.auto_awesome, // sparkles icon
      title: 'Welcome to later',
      message:
          'Your peaceful place for thoughts, tasks, and everything in between',
      actionLabel: 'Create your first item',
      onActionPressed: onActionPressed,
      secondaryActionLabel: onSecondaryPressed != null
          ? 'Learn how it works'
          : null,
      onSecondaryPressed: onSecondaryPressed,
    );
  }
}
