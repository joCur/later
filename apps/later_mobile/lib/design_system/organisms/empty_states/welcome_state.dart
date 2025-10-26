import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/design_system/atoms/text/gradient_text.dart';
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
      title: 'Welcome to later', // Fallback for accessibility
      titleWidget: const Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Welcome to ',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 20.0, // Mobile-first: 20px bold title
              fontWeight: FontWeight.bold,
              height: 1.3,
              letterSpacing: -0.15,
            ),
            textAlign: TextAlign.center,
          ),
          GradientText(
            'later',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 20.0, // Mobile-first: 20px bold title
              fontWeight: FontWeight.bold,
              height: 1.3,
              letterSpacing: -0.15,
            ),
          ),
        ],
      ),
      description: 'Your peaceful place for thoughts, tasks, and everything in between',
      ctaText: 'Create your first item',
      onCtaPressed: onCreateFirstItem,
      secondaryText: onLearnMore != null ? 'Learn how it works' : null,
      onSecondaryPressed: onLearnMore,
    );
  }
}
