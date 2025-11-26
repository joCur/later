// ignore_for_file: depend_on_referenced_packages
import 'package:go_router/go_router.dart';
import 'package:later_mobile/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Router provider for the application
///
/// Provides a GoRouter instance with:
/// - Initial location: /auth/sign-in (before auth check completes)
/// - Empty routes list (to be filled in Phase 2)
/// - Placeholder redirect callback (to be implemented in Phase 2)
/// - Error builder that falls back to SignInScreen
///
/// This is kept alive to maintain router state throughout app lifetime.
/// Auth integration will be added in Phase 2.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/auth/sign-in',
    routes: [
      // Routes will be added in Phase 2
    ],
    redirect: (context, state) {
      // Redirect logic will be implemented in Phase 2
      return null;
    },
    errorBuilder: (context, state) {
      // Fallback to sign-in screen for errors
      return const SignInScreen();
    },
  );
}
