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

@ProviderFor(CurrentSpaceController)
const currentSpaceControllerProvider = CurrentSpaceControllerProvider._();

/// Controller for managing current space selection.
///
/// Manages AsyncValue with current space for the active space.
/// Persists selection to SharedPreferences.
/// Single source of truth for current space selection.
final class CurrentSpaceControllerProvider
    extends $AsyncNotifierProvider<CurrentSpaceController, Space?> {
  /// Controller for managing current space selection.
  ///
  /// Manages AsyncValue with current space for the active space.
  /// Persists selection to SharedPreferences.
  /// Single source of truth for current space selection.
  const CurrentSpaceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentSpaceControllerProvider',
        isAutoDispose: true,
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
    r'8d4db1b7d558cc959f54c8997fbf8c7e1e516264';

/// Controller for managing current space selection.
///
/// Manages AsyncValue with current space for the active space.
/// Persists selection to SharedPreferences.
/// Single source of truth for current space selection.

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
