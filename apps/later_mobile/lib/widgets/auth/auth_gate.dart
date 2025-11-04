import 'package:flutter/material.dart';
import 'package:later_mobile/providers/auth_provider.dart';
import 'package:later_mobile/widgets/screens/home_screen.dart';
import 'package:later_mobile/widgets/screens/auth/sign_in_screen.dart';
import 'package:provider/provider.dart';

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
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading indicator while checking auth status
        if (authProvider.authStatus == AuthStatus.loading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Route based on authentication status
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const SignInScreen();
        }
      },
    );
  }
}
