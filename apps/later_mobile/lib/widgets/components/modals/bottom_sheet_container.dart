import 'package:flutter/material.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// A responsive container widget that adapts between mobile bottom sheet
/// and desktop dialog presentations.
///
/// On mobile (< 768px):
/// - Displays as a bottom sheet with rounded top corners (24px radius)
/// - Includes a drag handle at the top (32×4px, 12px from top)
/// - Solid background color (no glass effect)
/// - Expands to fit child content
///
/// On desktop/tablet (>= 768px):
/// - Displays as a dialog with standard rounded corners
/// - No drag handle (not needed for dialogs)
/// - Constrained to 560px max width
/// - Centered on screen
///
/// Example usage:
/// ```dart
/// ResponsiveModal.show(
///   context: context,
///   child: BottomSheetContainer(
///     title: 'Add Item',
///     child: MyFormWidget(),
///   ),
/// );
/// ```
class BottomSheetContainer extends StatelessWidget {
  const BottomSheetContainer({
    super.key,
    required this.child,
    this.title,
    this.height,
  });

  /// The widget to display inside the container
  final Widget child;

  /// Optional title to display at the top of the container
  final String? title;

  /// Optional height constraint for mobile bottom sheets
  /// If null, the sheet will size to fit its content
  final double? height;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    if (isMobile) {
      return _buildMobileBottomSheet(context);
    } else {
      return _buildDesktopDialog(context);
    }
  }

  /// Build mobile bottom sheet layout
  Widget _buildMobileBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = theme.scaffoldBackgroundColor;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24.0), // 24px top corner radius
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            const SizedBox(height: AppSpacing.sm), // 12px from top
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.neutral400
                    : AppColors.neutral400.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Optional title
            if (title != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Text(
                  title!,
                  style: AppTypography.h3,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Content
            Flexible(
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  /// Build desktop dialog layout
  Widget _buildDesktopDialog(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.modalRadius),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: AppSpacing.modalMaxWidth, // 560px
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Optional title
            if (title != null) ...[
              Text(
                title!,
                style: AppTypography.h3,
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Content
            Flexible(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
