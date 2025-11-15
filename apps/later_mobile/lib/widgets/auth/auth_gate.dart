import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:later_mobile/widgets/screens/auth/sign_in_screen.dart';
import 'package:later_mobile/features/home/presentation/screens/home_screen.dart';

/// Authentication gate that routes users based on authentication status
///
/// - Shows loading indicator while checking auth status
/// - Routes to HomeScreen if authenticated
/// - Routes to SignInScreen if not authenticated
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
