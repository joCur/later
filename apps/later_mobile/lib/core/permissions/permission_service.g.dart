// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the PermissionService singleton.
///
/// Creates a PermissionService with the global Supabase client.
/// This provider is kept alive to ensure consistent permission checks.

@ProviderFor(permissionService)
const permissionServiceProvider = PermissionServiceProvider._();

/// Provider for the PermissionService singleton.
///
/// Creates a PermissionService with the global Supabase client.
/// This provider is kept alive to ensure consistent permission checks.

final class PermissionServiceProvider
    extends
        $FunctionalProvider<
          PermissionService,
          PermissionService,
          PermissionService
        >
    with $Provider<PermissionService> {
  /// Provider for the PermissionService singleton.
  ///
  /// Creates a PermissionService with the global Supabase client.
  /// This provider is kept alive to ensure consistent permission checks.
  const PermissionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'permissionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$permissionServiceHash();

  @$internal
  @override
  $ProviderElement<PermissionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PermissionService create(Ref ref) {
    return permissionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PermissionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PermissionService>(value),
    );
  }
}

String _$permissionServiceHash() => r'7f9681784aaf48ceb682adb5ce34433e320cb75d';

/// Provider for the current user's role.
///
/// Watches the permission service and returns the current user role.
/// This provider is kept alive to maintain auth state consistency.
///
/// Returns:
/// - [UserRole.anonymous] for anonymous (temporary) users
/// - [UserRole.authenticated] for permanent users

@ProviderFor(currentUserRole)
const currentUserRoleProvider = CurrentUserRoleProvider._();

/// Provider for the current user's role.
///
/// Watches the permission service and returns the current user role.
/// This provider is kept alive to maintain auth state consistency.
///
/// Returns:
/// - [UserRole.anonymous] for anonymous (temporary) users
/// - [UserRole.authenticated] for permanent users

final class CurrentUserRoleProvider
    extends $FunctionalProvider<UserRole, UserRole, UserRole>
    with $Provider<UserRole> {
  /// Provider for the current user's role.
  ///
  /// Watches the permission service and returns the current user role.
  /// This provider is kept alive to maintain auth state consistency.
  ///
  /// Returns:
  /// - [UserRole.anonymous] for anonymous (temporary) users
  /// - [UserRole.authenticated] for permanent users
  const CurrentUserRoleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserRoleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserRoleHash();

  @$internal
  @override
  $ProviderElement<UserRole> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserRole create(Ref ref) {
    return currentUserRole(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserRole value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserRole>(value),
    );
  }
}

String _$currentUserRoleHash() => r'69397b22c73bbbf33e05d6f63f295972979ea16c';
