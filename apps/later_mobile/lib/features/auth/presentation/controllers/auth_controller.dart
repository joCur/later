// ignore_for_file: depend_on_referenced_packages
import 'package:later_mobile/features/auth/application/providers.dart';
import 'package:later_mobile/features/auth/data/services/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_controller.g.dart';

/// Controller for authentication operations (stateless)
///
/// Provides methods for authentication actions without managing state.
/// UI components handle local loading states and listen to authStreamProvider for auth state.
///
/// Methods throw errors for UI to handle - they don't manage AsyncValue state.
@riverpod
class AuthController extends _$AuthController {
  @override
  void build() {
    // Stateless controller - no state to build
  }

  /// Sign up a new user with email and password
  ///
  /// Throws error on failure for UI to handle inline.
  /// Auth state updates automatically via authStreamProvider.
  Future<User> signUp({
    required String email,
    required String password,
  }) async {
    final service = ref.read(authApplicationServiceProvider);
    return await service.signUp(email: email, password: password);
  }

  /// Sign in an existing user with email and password
  ///
  /// Throws error on failure for UI to handle inline.
  /// Auth state updates automatically via authStreamProvider.
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    final service = ref.read(authApplicationServiceProvider);
    return await service.signIn(email: email, password: password);
  }

  /// Sign out the current user
  ///
  /// Throws error on failure for UI to handle.
  /// Auth state updates automatically via authStreamProvider.
  Future<void> signOut() async {
    final service = ref.read(authApplicationServiceProvider);
    await service.signOut();
  }

  /// Sign in anonymously
  ///
  /// Creates a new anonymous user session. This allows users to try the app
  /// without creating a permanent account. Anonymous users can later upgrade
  /// to a full account while keeping their data.
  ///
  /// Throws error on failure for UI to handle inline.
  /// Auth state updates automatically via authStreamProvider.
  Future<User> signInAnonymously() async {
    final authService = ref.read(authServiceProvider);
    return await authService.signInAnonymously();
  }

  /// Upgrade an anonymous user to a full account
  ///
  /// Converts the current anonymous user to a permanent account by
  /// adding email and password credentials. The user ID remains the same,
  /// preserving all existing data.
  ///
  /// Throws error on failure for UI to handle inline.
  /// Auth state updates automatically via authStreamProvider.
  Future<User> upgradeToFullAccount({
    required String email,
    required String password,
  }) async {
    final authService = ref.read(authServiceProvider);
    return await authService.upgradeAnonymousUser(
      email: email,
      password: password,
    );
  }
}
