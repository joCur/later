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
/// - Empty routes list (to be filled in Phase 2)
/// - Placeholder redirect callback (to be implemented in Phase 2)
/// - Error builder that falls back to SignInScreen
///
/// This is kept alive to maintain router state throughout app lifetime.
/// Auth integration will be added in Phase 2.

@ProviderFor(router)
const routerProvider = RouterProvider._();

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

final class RouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
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

String _$routerHash() => r'49c8c77d0a0ac8fae3ce971be6b5c5d66f3b914a';
