// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Router provider for the application
///
/// Provides a GoRouter instance with:
/// - Initial location: /auth/sign-in (before auth check completes)
/// - Unauthenticated routes: sign-in, sign-up, account-upgrade
/// - Authenticated routes: home, notes, todos, lists, search
/// - Authentication-aware redirect logic with stream-based auth state
/// - Automatic route refresh when auth state changes
/// - Error builder that falls back to SignInScreen
///
/// This is kept alive to maintain router state throughout app lifetime.
/// The router watches the auth stream and rebuilds routes when auth state changes.

@ProviderFor(router)
const routerProvider = RouterProvider._();

/// Router provider for the application
///
/// Provides a GoRouter instance with:
/// - Initial location: /auth/sign-in (before auth check completes)
/// - Unauthenticated routes: sign-in, sign-up, account-upgrade
/// - Authenticated routes: home, notes, todos, lists, search
/// - Authentication-aware redirect logic with stream-based auth state
/// - Automatic route refresh when auth state changes
/// - Error builder that falls back to SignInScreen
///
/// This is kept alive to maintain router state throughout app lifetime.
/// The router watches the auth stream and rebuilds routes when auth state changes.

final class RouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Router provider for the application
  ///
  /// Provides a GoRouter instance with:
  /// - Initial location: /auth/sign-in (before auth check completes)
  /// - Unauthenticated routes: sign-in, sign-up, account-upgrade
  /// - Authenticated routes: home, notes, todos, lists, search
  /// - Authentication-aware redirect logic with stream-based auth state
  /// - Automatic route refresh when auth state changes
  /// - Error builder that falls back to SignInScreen
  ///
  /// This is kept alive to maintain router state throughout app lifetime.
  /// The router watches the auth stream and rebuilds routes when auth state changes.
  const RouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return router(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$routerHash() => r'9ff48a28c7b68dc7ea1db2e537d8a8a756258bb5';
