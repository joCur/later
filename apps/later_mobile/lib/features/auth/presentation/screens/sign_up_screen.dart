import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/core/error/app_error.dart';
import 'package:later_mobile/design_system/design_system.dart';
import 'package:later_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:later_mobile/l10n/app_localizations.dart';
import 'package:later_mobile/features/auth/presentation/screens/sign_in_screen.dart';

/// Screen for signing up new users
///
/// Provides email/password sign up with validation and error handling.
/// Links to sign in screen for existing users.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
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

    // Listen for password changes to update strength indicator
    _passwordController.addListener(() {
      setState(() {}); // Update strength indicator
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

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(authStateControllerProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    // Error handling is done through AsyncValue.error
    // The UI will show the error message automatically
  }

  void _navigateToSignIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (context) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        return 'An unexpected error occurred';
      },
    );

    // Extract loading state
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background with particles
          const AnimatedMeshBackground(),

          // Form content with opaque background for readability
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child:
                      Container(
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
                                  // Logo
                                  _buildLogo(),
                                  const SizedBox(height: AppSpacing.xl),

                                  // Welcome heading
                                  _buildHeading(),
                                  const SizedBox(height: AppSpacing.lg),

                                  // Error banner
                                  if (errorMessage != null) ...[
                                    _buildErrorBanner(errorMessage),
                                    const SizedBox(height: AppSpacing.md),
                                  ],

                                  // Email field
                                  _buildEmailField(isLoading),
                                  const SizedBox(height: AppSpacing.md),

                                  // Password field
                                  _buildPasswordField(isLoading),
                                  const SizedBox(height: AppSpacing.xs),

                                  // Password strength indicator
                                  _buildPasswordStrengthIndicator(),
                                  const SizedBox(height: AppSpacing.md),

                                  // Confirm password field
                                  _buildConfirmPasswordField(isLoading),
                                  const SizedBox(height: AppSpacing.lg),

                                  // Sign up button
                                  _buildSignUpButton(isLoading),
                                  const SizedBox(height: AppSpacing.md),

                                  // Sign in link
                                  _buildSignInLink(isLoading),
                                ],
                              ),
                            ),
                          )
                          .animate()
                          .slideY(
                            begin: 0.1,
                            end: 0,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                          )
                          .fadeIn(duration: 600.ms),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              'assets/icons/app-icon-monochrome.png',
              color: Colors.white,
            ),
          ),
        )
        .animate(delay: 200.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 400.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 400.ms);
  }

  Widget _buildHeading() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      l10n.authTitleSignUp,
      style: AppTypography.displayMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppColors.neutral900,
      ),
      textAlign: TextAlign.center,
    ).animate(delay: 300.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildErrorBanner(String errorMessage) {
    return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  errorMessage,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: -0.2, end: 0, duration: 200.ms);
  }

  Widget _buildEmailField(bool isLoading) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextInputField(
          label: l10n.authLabelEmail,
          hintText: l10n.authHintEmail,
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          prefixIcon: Icons.email_outlined,
          enabled: !isLoading,
          textColor: isDark ? Colors.white : AppColors.neutral900,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.authValidationEmailRequired;
            }
            if (!value.contains('@')) {
              return l10n.authValidationEmailInvalid;
            }
            return null;
          },
          onSubmitted: (_) {
            _passwordFocusNode.requestFocus();
          },
        )
        .animate(delay: 400.ms)
        .slideY(begin: 0.05, end: 0, duration: 300.ms)
        .fadeIn(duration: 300.ms);
  }

  Widget _buildPasswordField(bool isLoading) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextInputField(
          label: l10n.authLabelPassword,
          hintText: l10n.authHintPassword,
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          prefixIcon: Icons.lock_outlined,
          suffixIcon: _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          onSuffixIconPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          enabled: !isLoading,
          textColor: isDark ? Colors.white : AppColors.neutral900,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.authValidationPasswordRequiredSignUp;
            }
            if (value.length < 8) {
              return l10n.authValidationPasswordMinLength;
            }
            return null;
          },
          onSubmitted: (_) {
            _confirmPasswordFocusNode.requestFocus();
          },
        )
        .animate(delay: 500.ms)
        .slideY(begin: 0.05, end: 0, duration: 300.ms)
        .fadeIn(duration: 300.ms);
  }

  Widget _buildPasswordStrengthIndicator() {
    return PasswordStrengthIndicator(password: _passwordController.text)
        .animate(delay: 600.ms)
        .fadeIn(duration: 300.ms)
        .scaleX(
          begin: 0.0,
          end: 1.0,
          duration: 400.ms,
          curve: Curves.easeOut,
          alignment: Alignment.centerLeft,
        );
  }

  Widget _buildConfirmPasswordField(bool isLoading) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextInputField(
          label: l10n.authLabelConfirmPassword,
          hintText: l10n.authHintPassword,
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocusNode,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          prefixIcon: Icons.lock_outlined,
          suffixIcon: _obscureConfirmPassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          onSuffixIconPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
          enabled: !isLoading,
          textColor: isDark ? Colors.white : AppColors.neutral900,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.authValidationConfirmPasswordRequired;
            }
            if (value != _passwordController.text) {
              return l10n.authValidationPasswordsDoNotMatch;
            }
            return null;
          },
          onSubmitted: (_) {
            _handleSignUp();
          },
        )
        .animate(delay: 700.ms)
        .slideY(begin: 0.05, end: 0, duration: 300.ms)
        .fadeIn(duration: 300.ms);
  }

  Widget _buildSignUpButton(bool isLoading) {
    final l10n = AppLocalizations.of(context)!;
    return PrimaryButton(
          text: l10n.authButtonSignUp,
          onPressed: isLoading ? null : _handleSignUp,
          isLoading: isLoading,
        )
        .animate(delay: 800.ms)
        .slideY(begin: 0.05, end: 0, duration: 300.ms)
        .fadeIn(duration: 300.ms);
  }

  Widget _buildSignInLink(bool isLoading) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.neutral900;

    return GestureDetector(
      onTap: isLoading ? null : _navigateToSignIn,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: l10n.authTextHaveAccount,
          style: AppTypography.bodyMedium.copyWith(
            color: textColor.withValues(alpha: 0.7),
          ),
          children: [
            TextSpan(
              text: l10n.authLinkSignIn,
              style: AppTypography.bodyMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: textColor.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: 900.ms).fadeIn(duration: 300.ms);
  }
}
