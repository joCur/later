import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:later_mobile/core/config/supabase_config.dart';
import 'package:later_mobile/core/permissions/user_role.dart';

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
/// Watches the permission service and returns the current user role.
/// This provider is kept alive to maintain auth state consistency.
///
/// Returns:
/// - [UserRole.anonymous] for anonymous (temporary) users
/// - [UserRole.authenticated] for permanent users
@Riverpod(keepAlive: true)
UserRole currentUserRole(Ref ref) {
  final service = ref.watch(permissionServiceProvider);
  return service.getCurrentUserRole();
}
