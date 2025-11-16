// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for authentication state management
///
/// Manages the current user's authentication state using AsyncValue\<User?\>.
/// - AsyncValue.loading: Authentication check in progress
/// - AsyncValue.data(user): User is authenticated
/// - AsyncValue.data(null): User is not authenticated
/// - AsyncValue.error: Authentication error occurred
///
/// Riverpod 3.0 features:
/// - keepAlive: true to prevent disposal and maintain auth stream subscription
/// - Automatic retry on initialization failures
/// - `ref.mounted` checks for async safety

@ProviderFor(AuthStateController)
const authStateControllerProvider = AuthStateControllerProvider._();

/// Controller for authentication state management
///
/// Manages the current user's authentication state using AsyncValue\<User?\>.
/// - AsyncValue.loading: Authentication check in progress
/// - AsyncValue.data(user): User is authenticated
/// - AsyncValue.data(null): User is not authenticated
/// - AsyncValue.error: Authentication error occurred
///
/// Riverpod 3.0 features:
/// - keepAlive: true to prevent disposal and maintain auth stream subscription
/// - Automatic retry on initialization failures
/// - `ref.mounted` checks for async safety
final class AuthStateControllerProvider
    extends $AsyncNotifierProvider<AuthStateController, User?> {
  /// Controller for authentication state management
  ///
  /// Manages the current user's authentication state using AsyncValue\<User?\>.
  /// - AsyncValue.loading: Authentication check in progress
  /// - AsyncValue.data(user): User is authenticated
  /// - AsyncValue.data(null): User is not authenticated
  /// - AsyncValue.error: Authentication error occurred
  ///
  /// Riverpod 3.0 features:
  /// - keepAlive: true to prevent disposal and maintain auth stream subscription
  /// - Automatic retry on initialization failures
  /// - `ref.mounted` checks for async safety
  const AuthStateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateControllerHash();

  @$internal
  @override
  AuthStateController create() => AuthStateController();
}

String _$authStateControllerHash() =>
    r'09cba942f83027d7dca2cf5e095bdf8532516168';

/// Controller for authentication state management
///
/// Manages the current user's authentication state using AsyncValue\<User?\>.
/// - AsyncValue.loading: Authentication check in progress
/// - AsyncValue.data(user): User is authenticated
/// - AsyncValue.data(null): User is not authenticated
/// - AsyncValue.error: Authentication error occurred
///
/// Riverpod 3.0 features:
/// - keepAlive: true to prevent disposal and maintain auth stream subscription
/// - Automatic retry on initialization failures
/// - `ref.mounted` checks for async safety

abstract class _$AuthStateController extends $AsyncNotifier<User?> {
  FutureOr<User?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<User?>, User?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<User?>, User?>,
              AsyncValue<User?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
