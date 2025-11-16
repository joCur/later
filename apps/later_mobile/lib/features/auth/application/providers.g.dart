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
