import 'package:flutter/material.dart';
import 'package:later_mobile/l10n/app_localizations.dart';
import 'animated_empty_state.dart';

/// Welcome state for first app launch
///
/// Displays when the user opens the app for the first time with no items.
///
/// Features:
/// - Sparkles icon (64px)
/// - Welcoming message
/// - Create first item CTA
/// - Optional "Learn how it works" secondary action
/// - Entrance animations and FAB pulse
///
/// Example usage:
/// ```dart
/// WelcomeState(
///   onActionPressed: () => _showCreateContent(),
///   onSecondaryPressed: () => _showOnboarding(), // optional
///   enableFabPulse: (enabled) => setState(() => _fabPulse = enabled),
/// )
/// ```
class WelcomeState extends StatelessWidget {
  /// Creates a welcome state widget.
  const WelcomeState({
    super.key,
    required this.onActionPressed,
    this.onSecondaryPressed,
    this.enableFabPulse,
  });

  /// Callback when "Create your first item" button is pressed
  final VoidCallback onActionPressed;

  /// Optional callback when "Learn how it works" secondary action is pressed
  final VoidCallback? onSecondaryPressed;

  /// Optional callback to enable/disable FAB pulse animation
  final ValueChanged<bool>? enableFabPulse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedEmptyState(
      icon: Icons.auto_awesome,
      title: l10n.emptyWelcomeTitle,
      message: l10n.emptyWelcomeMessage,
      actionLabel: l10n.emptyWelcomeAction,
      onActionPressed: onActionPressed,
      secondaryActionLabel:
          onSecondaryPressed != null ? l10n.emptyWelcomeSecondaryAction : null,
      onSecondaryPressed: onSecondaryPressed,
      enableFabPulse: enableFabPulse,
    );
  }
}
