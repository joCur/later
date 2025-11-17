import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/design_system.dart';
import 'package:later_mobile/l10n/app_localizations.dart';

/// Upgrade prompt banner molecule for anonymous users
///
/// Features:
/// - Glassmorphism background with blur effect
/// - Warning icon with attention-grabbing task gradient
/// - Clear message prompting account creation
/// - Primary CTA button
/// - Dismissible with X icon button
/// - Responsive padding and layout
/// - Accessibility support
class UpgradePromptBanner extends StatelessWidget {
  const UpgradePromptBanner({
    super.key,
    required this.onCreateAccount,
    required this.onDismiss,
  });

  /// Callback when "Create Account" button is tapped
  final VoidCallback onCreateAccount;

  /// Callback when dismiss (X) button is tapped
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: temporalTheme.glassBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: temporalTheme.glassBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: temporalTheme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning icon with gradient
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              gradient: AppColors.taskGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 20,
              semanticLabel: l10n.accessibilityWarning,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Message text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.authUpgradeBannerMessage,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // CTA button
                SizedBox(
                  height: 36,
                  child: PrimaryButton(
                    text: l10n.authUpgradeBannerButton,
                    onPressed: onCreateAccount,
                    size: ButtonSize.small,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Dismiss button
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            tooltip: l10n.buttonDismiss,
          ),
        ],
      ),
    );
  }
}
