// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for [AuthService] singleton
///
/// Keep alive to maintain the service instance throughout the app lifecycle.
/// The AuthService is lightweight and handles Supabase auth operations.

@ProviderFor(authService)
const authServiceProvider = AuthServiceProvider._();

/// Provider for [AuthService] singleton
///
/// Keep alive to maintain the service instance throughout the app lifecycle.
/// The AuthService is lightweight and handles Supabase auth operations.

final class AuthServiceProvider
    extends $FunctionalProvider<AuthService, AuthService, AuthService>
    with $Provider<AuthService> {
  /// Provider for [AuthService] singleton
  ///
  /// Keep alive to maintain the service instance throughout the app lifecycle.
  /// The AuthService is lightweight and handles Supabase auth operations.
  const AuthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authServiceHash();

  @$internal
  @override
  $ProviderElement<AuthService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthService create(Ref ref) {
    return authService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthService>(value),
    );
  }
}

String _$authServiceHash() => r'1a086f396b6916ee8c5a9a14df3ece637f134805';
