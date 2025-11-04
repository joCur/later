import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/design_system.dart';
import 'package:later_mobile/providers/auth_provider.dart';
import 'package:later_mobile/widgets/screens/sign_up_screen.dart';
import 'package:provider/provider.dart';

/// Screen for signing in existing users
///
/// Provides email/password sign in with validation and error handling.
/// Links to sign up screen for new users.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    // Error handling is done through AuthProvider.errorMessage
    // The UI will show the error message automatically
  }

  void _navigateToSignUp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => const SignUpScreen(),
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
                      'Sign in to continue',
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
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      onSuffixIconPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      onSubmitted: (_) => _handleSignIn(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
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

                    // Sign in button
                    PrimaryButton(
                      text: 'Sign In',
                      onPressed: authProvider.isLoading ? null : _handleSignIn,
                      isLoading: authProvider.isLoading,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Sign up link
                    TextButton(
                      onPressed: _navigateToSignUp,
                      child: Text(
                        'Don\'t have an account? Sign up',
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
