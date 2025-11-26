import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:later_mobile/core/routing/app_router.dart';
import 'package:later_mobile/features/auth/application/auth_application_service.dart';
import 'package:later_mobile/features/auth/application/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Smoke test for router integration
// This validates the most critical function: "Can the router be created with proper dependencies?"
// This would catch: provider errors, missing dependencies, initialization failures
//
// Other routing functionality (navigation, redirects, route parameters) is validated through:
// 1. Manual testing (see .claude/research/phase-5-manual-testing-checklist.md)
// 2. The app running successfully (integration test)
// 3. Existing widget tests that implicitly use the router
void main() {
  test('routerProvider creates GoRouter instance with mocked dependencies', () {
    // Create a mock auth service that returns an unauthenticated stream
    final mockAuthService = _MockAuthApplicationService();

    // Override the auth application service provider
    final container = ProviderContainer(
      overrides: [
        authApplicationServiceProvider.overrideWithValue(mockAuthService),
      ],
    );
    addTearDown(container.dispose);

    // Read the router provider - validates it can be instantiated
    final router = container.read(routerProvider);

    // Verify router was created successfully
    expect(router, isA<GoRouter>());
  });
}

/// Mock implementation of AuthApplicationService for testing
class _MockAuthApplicationService implements AuthApplicationService {
  @override
  Stream<AuthState> authStateChanges() {
    // Return a stream that emits an unauthenticated state
    return Stream.value(
      const AuthState(
        AuthChangeEvent.signedOut,
        null, // no session
      ),
    );
  }

  @override
  User? checkAuthStatus() => null;

  @override
  Future<User> signIn({required String email, required String password}) async {
    throw UnimplementedError('Mock does not implement signIn');
  }

  @override
  Future<User> signUp({required String email, required String password}) async {
    throw UnimplementedError('Mock does not implement signUp');
  }

  @override
  Future<void> signOut() async {
    throw UnimplementedError('Mock does not implement signOut');
  }
}
