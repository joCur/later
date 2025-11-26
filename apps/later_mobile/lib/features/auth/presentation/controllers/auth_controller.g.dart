// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for authentication operations (stateless)
///
/// Provides methods for authentication actions without managing state.
/// UI components handle local loading states and listen to authStreamProvider for auth state.
///
/// Methods throw errors for UI to handle - they don't manage AsyncValue state.

@ProviderFor(AuthController)
const authControllerProvider = AuthControllerProvider._();

/// Controller for authentication operations (stateless)
///
/// Provides methods for authentication actions without managing state.
/// UI components handle local loading states and listen to authStreamProvider for auth state.
///
/// Methods throw errors for UI to handle - they don't manage AsyncValue state.
final class AuthControllerProvider
    extends $NotifierProvider<AuthController, void> {
  /// Controller for authentication operations (stateless)
  ///
  /// Provides methods for authentication actions without managing state.
  /// UI components handle local loading states and listen to authStreamProvider for auth state.
  ///
  /// Methods throw errors for UI to handle - they don't manage AsyncValue state.
  const AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$authControllerHash() => r'e1eaf662bbfae2487f5f4b86c8e06439dbb7e552';

/// Controller for authentication operations (stateless)
///
/// Provides methods for authentication actions without managing state.
/// UI components handle local loading states and listen to authStreamProvider for auth state.
///
/// Methods throw errors for UI to handle - they don't manage AsyncValue state.

abstract class _$AuthController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
