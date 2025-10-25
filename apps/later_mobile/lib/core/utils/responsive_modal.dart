import 'package:flutter/material.dart';
import '../responsive/breakpoints.dart';

/// Responsive modal utility for displaying content as either a bottom sheet on mobile
/// or a dialog on desktop/tablet.
///
/// This utility provides a consistent API for showing modals across different screen sizes,
/// automatically choosing the appropriate presentation style based on the current breakpoint.
///
/// Example usage:
/// ```dart
/// final result = await ResponsiveModal.show<String>(
///   context: context,
///   child: MyModalContent(),
///   isScrollControlled: true, // Optional, defaults to true
/// );
/// ```
///
/// On mobile (< 768px):
/// - Shows as a modal bottom sheet with transparent background
/// - Uses `isScrollControlled: true` to allow the sheet to expand with content
/// - Supports swipe-to-dismiss gesture
///
/// On desktop/tablet (>= 768px):
/// - Shows as a centered dialog
/// - Uses standard Material dialog presentation
class ResponsiveModal {
  ResponsiveModal._();

  /// Shows a responsive modal that adapts to screen size.
  ///
  /// On mobile devices, this displays as a bottom sheet. On larger screens,
  /// it displays as a dialog.
  ///
  /// Parameters:
  /// - [context]: BuildContext for determining screen size and showing the modal
  /// - [child]: The widget to display inside the modal
  /// - [isScrollControlled]: For bottom sheets, whether the sheet should expand with content
  ///   Defaults to true to support keyboard interactions and scrollable content
  /// - [barrierDismissible]: Whether tapping outside dismisses the modal (default: true)
  ///
  /// Returns:
  /// A Future that resolves to the result passed to Navigator.pop, or null if dismissed
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    bool barrierDismissible = true,
  }) {
    final isMobile = Breakpoints.isMobile(context);

    if (isMobile) {
      // Show as bottom sheet on mobile
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: isScrollControlled,
        backgroundColor: Colors.transparent,
        isDismissible: barrierDismissible,
        enableDrag: barrierDismissible,
        builder: (context) => child,
      );
    } else {
      // Show as dialog on desktop/tablet
      return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) => child,
      );
    }
  }
}
