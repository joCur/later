import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:later_mobile/core/config/supabase_config.dart';
import 'package:later_mobile/core/permissions/user_role.dart';
import 'package:later_mobile/features/auth/application/providers.dart';

part 'permission_service.g.dart';

/// Service for managing user permissions based on authentication status.
///
/// Determines whether a user is anonymous or authenticated and provides
/// permission checks for feature access.
class PermissionService {
  /// Creates a new PermissionService with the given Supabase client.
  PermissionService(this._supabase);

  final SupabaseClient _supabase;

  /// Gets the current user's role based on their authentication status.
  ///
  /// Returns [UserRole.anonymous] for anonymous users or when no user is found.
  /// Returns [UserRole.authenticated] for fully authenticated (permanent) users.
  UserRole getCurrentUserRole() {
    final user = _supabase.auth.currentUser;

    // No user found - treat as anonymous fallback (shouldn't happen in normal flow)
    if (user == null) {
      return UserRole.anonymous;
    }

    // Check if user is anonymous via isAnonymous flag
    if (user.isAnonymous) {
      return UserRole.anonymous;
    }

    // User is authenticated (permanent account)
    return UserRole.authenticated;
  }

  /// Convenience method to check if the current user is anonymous.
  ///
  /// Returns `true` if the user is anonymous, `false` otherwise.
  bool isAnonymous() => getCurrentUserRole() == UserRole.anonymous;

  /// Convenience method to check if the current user is authenticated.
  ///
  /// Returns `true` if the user is authenticated (permanent), `false` otherwise.
  bool isAuthenticated() => getCurrentUserRole() == UserRole.authenticated;
}

/// Provider for the PermissionService singleton.
///
/// Creates a PermissionService with the global Supabase client.
/// This provider is kept alive to ensure consistent permission checks.
@Riverpod(keepAlive: true)
PermissionService permissionService(Ref ref) {
  return PermissionService(SupabaseConfig.client);
}

/// Provider for the current user's role.
///
/// Watches the auth state and returns the current user role.
/// This provider updates automatically when the user upgrades from anonymous
/// to authenticated or signs in/out.
///
/// Returns:
/// - [UserRole.anonymous] for anonymous (temporary) users
/// - [UserRole.authenticated] for permanent users
@riverpod
UserRole currentUserRole(Ref ref) {
  // Watch auth stream to detect changes (sign in, sign out, upgrade)
  final authStreamValue = ref.watch(authStreamProvider);

  // Get the user from auth stream (AsyncValue wraps the stream automatically)
  final user = authStreamValue.value;

  // No user found - treat as anonymous fallback
  if (user == null) {
    return UserRole.anonymous;
  }

  // Check if user is anonymous via isAnonymous flag
  if (user.isAnonymous) {
    return UserRole.anonymous;
  }

  // User is authenticated (permanent account)
  return UserRole.authenticated;
}
