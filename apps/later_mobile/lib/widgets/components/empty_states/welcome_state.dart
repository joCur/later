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
    return EmptyState(
      icon: Icons.auto_awesome, // sparkles icon
      iconSize: 64.0,
      title: 'Welcome to later',
      description: 'Your peaceful place for thoughts, tasks, and everything in between',
      ctaText: 'Create your first item',
      onCtaPressed: onCreateFirstItem,
      secondaryText: onLearnMore != null ? 'Learn how it works' : null,
      onSecondaryPressed: onLearnMore,
    );
  }
}
