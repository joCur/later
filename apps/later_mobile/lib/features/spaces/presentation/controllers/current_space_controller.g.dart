// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_space_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing current space selection.
///
/// Manages AsyncValue with current space for the active space.
/// Persists selection to SharedPreferences.
/// Single source of truth for current space selection.
/// keepAlive: true prevents disposal and maintains current space state.

@ProviderFor(CurrentSpaceController)
const currentSpaceControllerProvider = CurrentSpaceControllerProvider._();

/// Controller for managing current space selection.
///
/// Manages AsyncValue with current space for the active space.
/// Persists selection to SharedPreferences.
/// Single source of truth for current space selection.
/// keepAlive: true prevents disposal and maintains current space state.
final class CurrentSpaceControllerProvider
    extends $AsyncNotifierProvider<CurrentSpaceController, Space?> {
  /// Controller for managing current space selection.
  ///
  /// Manages AsyncValue with current space for the active space.
  /// Persists selection to SharedPreferences.
  /// Single source of truth for current space selection.
  /// keepAlive: true prevents disposal and maintains current space state.
  const CurrentSpaceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentSpaceControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentSpaceControllerHash();

  @$internal
  @override
  CurrentSpaceController create() => CurrentSpaceController();
}

String _$currentSpaceControllerHash() =>
    r'a9d8a0ac7f2527c67452a580a8434b10274aedd8';

/// Controller for managing current space selection.
///
/// Manages AsyncValue with current space for the active space.
/// Persists selection to SharedPreferences.
/// Single source of truth for current space selection.
/// keepAlive: true prevents disposal and maintains current space state.

abstract class _$CurrentSpaceController extends $AsyncNotifier<Space?> {
  FutureOr<Space?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<Space?>, Space?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Space?>, Space?>,
              AsyncValue<Space?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
