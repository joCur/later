import 'package:flutter/material.dart';
import 'empty_state.dart';

/// Empty state for spaces with no items
///
/// Displays when a space has no items, encouraging the user to create content.
///
/// Features:
/// - Dynamic space name in title
/// - Inbox icon (64px)
/// - Quick Capture CTA
///
/// Example usage:
/// ```dart
/// EmptySpaceState(
///   spaceName: 'Work',
///   onQuickCapture: () => _showQuickCapture(),
/// )
/// ```
class EmptySpaceState extends StatelessWidget {
  /// Creates an empty space state widget.
  const EmptySpaceState({
    super.key,
    required this.spaceName,
    required this.onQuickCapture,
  });

  /// Name of the current space
  final String spaceName;

  /// Callback when Quick Capture button is pressed
  final VoidCallback onQuickCapture;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.inbox,
      iconSize: 64.0,
      title: 'Your $spaceName is empty',
      description: 'Start capturing your thoughts, tasks, and ideas',
      ctaText: 'Quick Capture',
      onCtaPressed: onQuickCapture,
    );
  }
}
