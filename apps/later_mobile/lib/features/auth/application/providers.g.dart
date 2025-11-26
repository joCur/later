// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for [AuthApplicationService] singleton
///
/// This service coordinates authentication business logic and depends
/// on the auth data service. Kept alive for the app lifetime.

@ProviderFor(authApplicationService)
const authApplicationServiceProvider = AuthApplicationServiceProvider._();

/// Provider for [AuthApplicationService] singleton
///
/// This service coordinates authentication business logic and depends
/// on the auth data service. Kept alive for the app lifetime.

final class AuthApplicationServiceProvider
    extends
        $FunctionalProvider<
          AuthApplicationService,
          AuthApplicationService,
          AuthApplicationService
        >
    with $Provider<AuthApplicationService> {
  /// Provider for [AuthApplicationService] singleton
  ///
  /// This service coordinates authentication business logic and depends
  /// on the auth data service. Kept alive for the app lifetime.
  const AuthApplicationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authApplicationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authApplicationServiceHash();

  @$internal
  @override
  $ProviderElement<AuthApplicationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthApplicationService create(Ref ref) {
    return authApplicationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthApplicationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthApplicationService>(value),
    );
  }
}

String _$authApplicationServiceHash() =>
    r'90bd600b88ca61a010f194110d8ba8ab00dfe0a0';

/// Stream provider for authentication state
///
/// Emits the current [User] when authenticated, null when unauthenticated.
/// This stream is used by go_router for reactive authentication-based routing.
///
/// The stream emits immediately with the current user state and then
/// on every auth state change (sign in, sign out, session refresh).

@ProviderFor(authStream)
const authStreamProvider = AuthStreamProvider._();

/// Stream provider for authentication state
///
/// Emits the current [User] when authenticated, null when unauthenticated.
/// This stream is used by go_router for reactive authentication-based routing.
///
/// The stream emits immediately with the current user state and then
/// on every auth state change (sign in, sign out, session refresh).

final class AuthStreamProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  /// Stream provider for authentication state
  ///
  /// Emits the current [User] when authenticated, null when unauthenticated.
  /// This stream is used by go_router for reactive authentication-based routing.
  ///
  /// The stream emits immediately with the current user state and then
  /// on every auth state change (sign in, sign out, session refresh).
  const AuthStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStreamHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return authStream(ref);
  }
}

String _$authStreamHash() => r'e2247e4e07f452d898b97b418ada8bbc824412cb';
