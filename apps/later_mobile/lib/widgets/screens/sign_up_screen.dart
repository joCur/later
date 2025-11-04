import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/design_system.dart';
import 'package:later_mobile/providers/auth_provider.dart';
import 'package:later_mobile/widgets/screens/sign_in_screen.dart';
import 'package:provider/provider.dart';

/// Screen for signing up new users
///
/// Provides email/password sign up with validation and error handling.
/// Links to sign in screen for existing users.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    // Error handling is done through AuthProvider.errorMessage
    // The UI will show the error message automatically
  }

  void _navigateToSignIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => const SignInScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo or app name
                    Text(
                      'Later',
                      style: AppTypography.displayLarge.copyWith(
                        foreground: Paint()
                          ..shader = temporalTheme.primaryGradient.createShader(
                            const Rect.fromLTWH(0, 0, 200, 70),
                          ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Create your account',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Email field
                    TextInputField(
                      label: 'Email',
                      hintText: 'your@email.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.email_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Password field
                    TextInputField(
                      label: 'Password',
                      hintText: '••••••••',
                      controller: _passwordController,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Confirm password field
                    TextInputField(
                      label: 'Confirm Password',
                      hintText: '••••••••',
                      controller: _confirmPasswordController,
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
                      onSubmitted: (_) => _handleSignUp(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Error message
                    if (authProvider.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.errorBg,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                          border: Border.all(
                            color: AppColors.errorLight,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                authProvider.errorMessage!,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.errorDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Sign up button
                    PrimaryButton(
                      text: 'Sign Up',
                      onPressed: authProvider.isLoading ? null : _handleSignUp,
                      isLoading: authProvider.isLoading,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Sign in link
                    TextButton(
                      onPressed: _navigateToSignIn,
                      child: Text(
                        'Already have an account? Sign in',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
