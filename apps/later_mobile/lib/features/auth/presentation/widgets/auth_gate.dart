import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:later_mobile/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:later_mobile/features/home/presentation/screens/home_screen.dart';

/// Authentication gate that routes users based on authentication status
///
/// - Shows loading indicator while checking auth status
/// - Routes to HomeScreen if authenticated
/// - Routes to SignInScreen if not authenticated
/// - Shows error screen as fallback for unexpected/system errors
///
/// Note: Auth operation errors (sign in/sign up failures) are handled inline
/// via ref.listen in the auth screens and won't reach this error state.
/// This error screen is only shown for unexpected errors during initialization.
///
/// TODO: Future improvement - migrate to go_router for declarative routing
/// The current error screen creates a dead-end UX with no recovery options.
/// With go_router, we can use redirect guards to gracefully fallback to
/// SignInScreen instead of showing an error screen. This also enables deep
/// linking, web navigation, and better route protection.
/// See: .claude/research/auth-routing-error-handling-best-practices.md
///
/// Usage:
/// ```dart
/// MaterialApp(
///   home: AuthGate(),
/// )
/// ```
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateControllerProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          // User is authenticated - show app
          return const HomeScreen();
        } else {
          // User is not authenticated - show sign in
          return const SignInScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text('Authentication error: ${error.toString()}'),
        ),
      ),
    );
  }
}
