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
/// - Optional "Learn how it works" secondary link
///
/// Example usage:
/// ```dart
/// WelcomeState(
///   onCreateFirstItem: () => _showQuickCapture(),
///   onLearnMore: () => _showOnboarding(), // optional
/// )
/// ```
class WelcomeState extends StatelessWidget {
  /// Creates a welcome state widget.
  const WelcomeState({
    super.key,
    required this.onCreateFirstItem,
    this.onLearnMore,
  });

  /// Callback when "Create your first item" button is pressed
  final VoidCallback onCreateFirstItem;

  /// Optional callback when "Learn how it works" link is pressed
  final VoidCallback? onLearnMore;

  @override
  Widget build(BuildContext context) {
    // Note: Simplified to work with EmptyState API
    // Custom gradient title and secondary action removed for API compatibility
    return EmptyState(
      icon: Icons.auto_awesome, // sparkles icon
      title: 'Welcome to later',
      message: 'Your peaceful place for thoughts, tasks, and everything in between',
      actionLabel: 'Create your first item',
      onActionPressed: onCreateFirstItem,
    );
  }
}
