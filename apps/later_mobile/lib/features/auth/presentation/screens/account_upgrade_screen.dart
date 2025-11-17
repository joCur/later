import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/core/error/app_error.dart';
import 'package:later_mobile/design_system/design_system.dart';
import 'package:later_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:later_mobile/l10n/app_localizations.dart';

/// Screen for upgrading anonymous users to full accounts
///
/// Provides email/password upgrade with validation and error handling.
/// Shows success message and navigates back on successful upgrade.
class AccountUpgradeScreen extends ConsumerStatefulWidget {
  const AccountUpgradeScreen({super.key});

  @override
  ConsumerState<AccountUpgradeScreen> createState() =>
      _AccountUpgradeScreenState();
}

class _AccountUpgradeScreenState extends ConsumerState<AccountUpgradeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Auto-focus email field after animations complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _emailFocusNode.requestFocus();
        }
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleUpgrade() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref.read(authStateControllerProvider.notifier).upgradeToFullAccount(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) return;

      // Show success message
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.authUpgradeSuccessMessage),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate back after short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    } catch (e) {
      // Error is handled through AsyncValue.error
      // The UI will show the error message automatically
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  String? _validateEmail(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.validationEmailRequired;
    }
    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return l10n.validationEmailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.validationPasswordRequired;
    }
    if (value.length < 8) {
      return l10n.validationPasswordMinLength;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.validationPasswordConfirmRequired;
    }
    if (value != _passwordController.text) {
      return l10n.validationPasswordsDoNotMatch;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Extract error message from AsyncValue
    final errorMessage = authState.when(
      data: (_) => null,
      loading: () => null,
      error: (error, _) {
        if (error is AppError) {
          return error.message;
        }
        return l10n.errorUnexpected;
      },
    );

    // Extract loading state
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          const AnimatedMeshBackground(),

          // Form content with opaque background
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.neutral900.withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Back button
                          _buildBackButton(),
                          const SizedBox(height: AppSpacing.md),

                          // Title
                          _buildTitle(l10n),
                          const SizedBox(height: AppSpacing.sm),

                          // Subtitle
                          _buildSubtitle(l10n),
                          const SizedBox(height: AppSpacing.lg),

                          // Error banner
                          if (errorMessage != null) ...[
                            _buildErrorBanner(errorMessage),
                            const SizedBox(height: AppSpacing.md),
                          ],

                          // Email field
                          _buildEmailField(l10n, isLoading),
                          const SizedBox(height: AppSpacing.md),

                          // Password field
                          _buildPasswordField(l10n, isLoading),
                          const SizedBox(height: AppSpacing.md),

                          // Confirm password field
                          _buildConfirmPasswordField(l10n, isLoading),
                          const SizedBox(height: AppSpacing.lg),

                          // Create Account button
                          _buildCreateAccountButton(l10n, isLoading),
                          const SizedBox(height: AppSpacing.md),

                          // Maybe Later button
                          _buildCancelButton(l10n, isLoading),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                      .slideY(
                        begin: 0.05,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOut,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _handleCancel,
      )
          .animate()
          .fadeIn(delay: 200.ms, duration: 400.ms)
          .slideX(begin: -0.2, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _buildTitle(AppLocalizations l10n) {
    return Text(
      l10n.authUpgradeScreenTitle,
      style: AppTypography.headlineLarge,
      textAlign: TextAlign.center,
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideY(begin: 0.05, end: 0, curve: Curves.easeOut);
  }

  Widget _buildSubtitle(AppLocalizations l10n) {
    return Text(
      l10n.authUpgradeScreenSubtitle,
      style: AppTypography.bodyMedium.copyWith(
        color: Colors.grey[600],
      ),
      textAlign: TextAlign.center,
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 600.ms)
        .slideY(begin: 0.05, end: 0, curve: Curves.easeOut);
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    ).animate().shake(duration: 300.ms);
  }

  Widget _buildEmailField(AppLocalizations l10n, bool isLoading) {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      decoration: InputDecoration(
        labelText: l10n.authUpgradeEmailLabel,
        prefixIcon: const Icon(Icons.email_outlined),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      enabled: !isLoading,
      validator: _validateEmail,
      onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .slideX(begin: -0.05, end: 0, curve: Curves.easeOut);
  }

  Widget _buildPasswordField(AppLocalizations l10n, bool isLoading) {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      decoration: InputDecoration(
        labelText: l10n.authUpgradePasswordLabel,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      enabled: !isLoading,
      validator: _validatePassword,
      onFieldSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
    )
        .animate()
        .fadeIn(delay: 500.ms, duration: 600.ms)
        .slideX(begin: -0.05, end: 0, curve: Curves.easeOut);
  }

  Widget _buildConfirmPasswordField(AppLocalizations l10n, bool isLoading) {
    return TextFormField(
      controller: _confirmPasswordController,
      focusNode: _confirmPasswordFocusNode,
      decoration: InputDecoration(
        labelText: l10n.authUpgradeConfirmPasswordLabel,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () => setState(
            () => _obscureConfirmPassword = !_obscureConfirmPassword,
          ),
        ),
      ),
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      enabled: !isLoading,
      validator: _validateConfirmPassword,
      onFieldSubmitted: (_) => _handleUpgrade(),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 600.ms)
        .slideX(begin: -0.05, end: 0, curve: Curves.easeOut);
  }

  Widget _buildCreateAccountButton(AppLocalizations l10n, bool isLoading) {
    return PrimaryButton(
      text: l10n.authUpgradeSubmitButton,
      onPressed: isLoading ? null : _handleUpgrade,
      isLoading: isLoading,
      size: ButtonSize.large,
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 600.ms)
        .slideY(begin: 0.05, end: 0, curve: Curves.easeOut);
  }

  Widget _buildCancelButton(AppLocalizations l10n, bool isLoading) {
    return GhostButton(
      text: l10n.authUpgradeCancelButton,
      onPressed: isLoading ? null : _handleCancel,
      size: ButtonSize.large,
    )
        .animate()
        .fadeIn(delay: 800.ms, duration: 600.ms)
        .slideY(begin: 0.05, end: 0, curve: Curves.easeOut);
  }
}
