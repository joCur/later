import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import '../../../core/responsive/breakpoints.dart';
import 'package:later_mobile/design_system/atoms/buttons/primary_button.dart';
import 'package:later_mobile/design_system/atoms/buttons/secondary_button.dart';

/// A responsive container widget that adapts between mobile bottom sheet
/// and desktop dialog presentations.
///
/// Copied structure from QuickCaptureModal for consistency.
class BottomSheetContainer extends StatelessWidget {
  const BottomSheetContainer({
    super.key,
    required this.child,
    this.title,
    this.height,
    this.primaryButtonText,
    this.onPrimaryPressed,
    this.isPrimaryButtonEnabled = true,
    this.isPrimaryButtonLoading = false,
    this.showSecondaryButton = true,
    this.secondaryButtonText = 'Cancel',
    this.onSecondaryPressed,
  });

  final Widget child;
  final String? title;
  final double? height;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final bool isPrimaryButtonEnabled;
  final bool isPrimaryButtonLoading;
  final bool showSecondaryButton;
  final String secondaryButtonText;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.of(context).pop();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  /// Copied from QuickCaptureModal._buildMobileLayout()
  Widget _buildMobileLayout() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surfaceColor = isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight;
        final primaryGradient = isDark
            ? AppColors.primaryGradientDark
            : AppColors.primaryGradient;
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

        return GestureDetector(
          onTap: () => Navigator.of(context).pop(), // Tap outside to dismiss
          child: Container(
            color: Colors.transparent, // Make the backdrop tappable
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {}, // Prevent tap through to outer gesture detector
                child: Padding(
                  padding: EdgeInsets.only(bottom: keyboardHeight),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      // Solid surface background (mobile-first bold design, no glass)
                      color: surfaceColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(
                          24.0,
                        ), // 24px for mobile-first design
                      ),
                      // 4px gradient border on top edge
                      border: Border(
                        top: BorderSide(
                          width: 4.0,
                          color: primaryGradient.colors[0],
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Drag handle
                        _buildDragHandle(),

                        // Header
                        _buildHeader(context, isDark, isMobile: true),

                        // Content
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg, // 24px on mobile
                              vertical: AppSpacing.sm,
                            ),
                            child: child,
                          ),
                        ),

                        // Optional footer buttons
                        if (primaryButtonText != null)
                          _buildFooter(context, isDark, isMobile: true),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Copied from QuickCaptureModal._buildDesktopLayout()
  Widget _buildDesktopLayout() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surfaceColor = isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight;
        final primaryGradient = isDark
            ? AppColors.primaryGradientDark
            : AppColors.primaryGradient;

        return GestureDetector(
          onTap: () => Navigator.of(context).pop(), // Tap outside to dismiss
          child: Container(
            color: Colors.transparent, // Make the backdrop tappable
            child: Center(
              child: GestureDetector(
                onTap: () {}, // Prevent tap through to outer gesture detector
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: AppSpacing.modalMaxWidth,
                  ), // 560px
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.modalRadius),
                    border: Border.all(
                      color: primaryGradient.colors[0].withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? AppColors.shadowDark
                            : AppColors.shadowLight,
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                      // Gradient shadow for glass effect
                      BoxShadow(
                        color: primaryGradient.colors[0].withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.modalRadius),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: AppSpacing.glassBlurRadius,
                        sigmaY: AppSpacing.glassBlurRadius,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          // Glass morphism: semi-transparent background
                          color: surfaceColor.withValues(alpha: 0.85),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            _buildHeader(context, isDark, isMobile: false),

                            // Content
                            Flexible(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                child: child,
                              ),
                            ),

                            // Optional footer buttons
                            if (primaryButtonText != null)
                              _buildFooter(context, isDark, isMobile: false),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Copied from QuickCaptureModal._buildDragHandle()
  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.neutralGray300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  /// Copied from QuickCaptureModal._buildHeader()
  Widget _buildHeader(
    BuildContext context,
    bool isDark, {
    required bool isMobile,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile
            ? AppSpacing.lg
            : AppSpacing.md, // 24px on mobile (mobile-first design)
        isMobile ? AppSpacing.lg : AppSpacing.md, // 24px on mobile
        AppSpacing.xs,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title ?? '',
              style: AppTypography.h3.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            onPressed: () => Navigator.of(context).pop(),
            iconSize: 24,
            constraints: const BoxConstraints(
              minWidth: AppSpacing.minTouchTarget,
              minHeight: AppSpacing.minTouchTarget,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    bool isDark, {
    required bool isMobile,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: showSecondaryButton
              ? Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: secondaryButtonText,
                        onPressed: isPrimaryButtonLoading
                            ? null
                            : (onSecondaryPressed ??
                                  () => Navigator.of(context).pop()),
                        isExpanded: true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: _buildPrimaryButton(isDark)),
                  ],
                )
              : _buildPrimaryButton(isDark),
        ),
        // Bottom padding for mobile (safe area + keyboard)
        if (isMobile) SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }

  Widget _buildPrimaryButton(bool isDark) {
    return PrimaryButton(
      text: primaryButtonText!,
      onPressed: isPrimaryButtonEnabled ? onPrimaryPressed : null,
      isExpanded: true,
      isLoading: isPrimaryButtonLoading,
    );
  }
}
