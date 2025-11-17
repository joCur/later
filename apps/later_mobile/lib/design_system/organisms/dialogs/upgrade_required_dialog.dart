import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/atoms/buttons/ghost_button.dart';
import 'package:later_mobile/design_system/atoms/buttons/primary_button.dart';
import 'package:later_mobile/features/auth/presentation/screens/account_upgrade_screen.dart';
import 'package:later_mobile/l10n/app_localizations.dart';

/// Shows an upgrade required dialog for anonymous users who have reached a feature limit.
///
/// The dialog displays a title, message explaining the limit, and action buttons.
/// When the user taps "Create Account", they are navigated to the AccountUpgradeScreen.
/// When the user taps "Not Now", the dialog is dismissed.
///
/// The [message] parameter should explain which limit was reached and what benefits
/// upgrading provides (e.g., "Anonymous users are limited to 1 space...").
///
/// Example usage:
/// ```dart
/// await showUpgradeRequiredDialog(
///   context: context,
///   message: l10n.authUpgradeLimitSpaces,
/// );
/// ```
Future<void> showUpgradeRequiredDialog({
  required BuildContext context,
  required String message,
}) async {
  final l10n = AppLocalizations.of(context)!;

  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(l10n.authUpgradeDialogTitle),
        content: Text(message),
        actions: [
          GhostButton(
            text: l10n.authUpgradeDialogNotNow,
            onPressed: () => Navigator.of(context).pop(),
          ),
          PrimaryButton(
            text: l10n.authUpgradeBannerButton,
            onPressed: () {
              // Close the dialog
              Navigator.of(context).pop();
              // Navigate to the upgrade screen
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const AccountUpgradeScreen(),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}
