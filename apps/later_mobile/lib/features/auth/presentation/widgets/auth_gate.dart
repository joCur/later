import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/features/auth/application/providers.dart';
import 'package:later_mobile/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:later_mobile/features/home/presentation/screens/home_screen.dart';

/// Authentication gate that routes users based on authentication status
///
/// - Shows loading indicator while initializing auth stream
/// - Routes to HomeScreen if authenticated
/// - Routes to SignInScreen if not authenticated
/// - Shows error screen as fallback for stream errors
///
/// Note: This is a temporary implementation during go_router migration.
/// Loading state now represents stream initialization, not auth check.
/// Auth stream emits immediately with current user state from Supabase.
///
/// This widget will be deleted after go_router migration is complete.
/// See: .claude/plans/go-router-migration.md
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
    final authStreamValue = ref.watch(authStreamProvider);

    return authStreamValue.when(
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
