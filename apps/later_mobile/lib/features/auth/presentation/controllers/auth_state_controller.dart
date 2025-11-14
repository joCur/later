// ignore_for_file: depend_on_referenced_packages
import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:later_mobile/features/auth/application/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_state_controller.g.dart';

/// Controller for authentication state management
///
/// Manages the current user's authentication state using AsyncValue\<User?\>.
/// - AsyncValue.loading: Authentication check in progress
/// - AsyncValue.data(user): User is authenticated
/// - AsyncValue.data(null): User is not authenticated
/// - AsyncValue.error: Authentication error occurred
///
/// Riverpod 3.0 features:
/// - Auto-disposed by default
/// - Automatic retry on initialization failures
/// - `ref.mounted` checks for async safety
@riverpod
class AuthStateController extends _$AuthStateController {
  StreamSubscription<AuthState>? _authStateSubscription;

  @override
  Future<User?> build() async {
    // Initialize with current auth status
    final service = ref.watch(authApplicationServiceProvider);
    final user = service.checkAuthStatus();

    // Listen to auth state changes
    _authStateSubscription = service.authStateChanges().listen((authState) {
      // Update state when auth changes (sign in, sign out, session refresh)
      if (ref.mounted) {
        state = AsyncValue.data(authState.session?.user);
      }
    });

    // Clean up subscription when provider is disposed
    ref.onDispose(() {
      _authStateSubscription?.cancel();
    });

    return user;
  }

  /// Sign up a new user with email and password
  ///
  /// Updates state to loading, then data or error based on result.
  /// Uses `ref.mounted` to prevent state updates after disposal.
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    // Set loading state
    state = const AsyncValue.loading();

    try {
      final service = ref.read(authApplicationServiceProvider);
      final user = await service.signUp(email: email, password: password);

      // Check if still mounted before updating
      if (!ref.mounted) return;

      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      // Check if still mounted before updating
      if (!ref.mounted) return;

      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Sign in an existing user with email and password
  ///
  /// Updates state to loading, then data or error based on result.
  /// Uses `ref.mounted` to prevent state updates after disposal.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    // Set loading state
    state = const AsyncValue.loading();

    try {
      final service = ref.read(authApplicationServiceProvider);
      final user = await service.signIn(email: email, password: password);

      // Check if still mounted before updating
      if (!ref.mounted) return;

      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      // Check if still mounted before updating
      if (!ref.mounted) return;

      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Sign out the current user
  ///
  /// Updates state to loading, then data(null) or error based on result.
  /// Uses `ref.mounted` to prevent state updates after disposal.
  Future<void> signOut() async {
    // Set loading state
    state = const AsyncValue.loading();

    try {
      final service = ref.read(authApplicationServiceProvider);
      await service.signOut();

      // Check if still mounted before updating
      if (!ref.mounted) return;

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      // Check if still mounted before updating
      if (!ref.mounted) return;

      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Initialize or re-initialize authentication state
  ///
  /// Forces a refresh of the current auth state.
  /// Useful after errors or manual state resets.
  Future<void> initialize() async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(authApplicationServiceProvider);
      final user = service.checkAuthStatus();

      // Check if still mounted before updating
      if (!ref.mounted) return;

      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      // Check if still mounted before updating
      if (!ref.mounted) return;

      state = AsyncValue.error(error, stackTrace);
    }
  }
}
