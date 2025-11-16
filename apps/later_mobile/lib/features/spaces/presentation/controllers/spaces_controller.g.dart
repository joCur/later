// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spaces_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing spaces state.
///
/// Manages AsyncValue with list of spaces for all spaces.
/// Provides methods for CRUD operations on spaces.
/// Uses SpaceService for business logic.
/// keepAlive: true prevents disposal and avoids unnecessary re-fetches.

@ProviderFor(SpacesController)
const spacesControllerProvider = SpacesControllerProvider._();

/// Controller for managing spaces state.
///
/// Manages AsyncValue with list of spaces for all spaces.
/// Provides methods for CRUD operations on spaces.
/// Uses SpaceService for business logic.
/// keepAlive: true prevents disposal and avoids unnecessary re-fetches.
final class SpacesControllerProvider
    extends $AsyncNotifierProvider<SpacesController, List<Space>> {
  /// Controller for managing spaces state.
  ///
  /// Manages AsyncValue with list of spaces for all spaces.
  /// Provides methods for CRUD operations on spaces.
  /// Uses SpaceService for business logic.
  /// keepAlive: true prevents disposal and avoids unnecessary re-fetches.
  const SpacesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'spacesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$spacesControllerHash();

  @$internal
  @override
  SpacesController create() => SpacesController();
}

String _$spacesControllerHash() => r'1f858904416c0fba15957ef92069e9988f0ffc9c';

/// Controller for managing spaces state.
///
/// Manages AsyncValue with list of spaces for all spaces.
/// Provides methods for CRUD operations on spaces.
/// Uses SpaceService for business logic.
/// keepAlive: true prevents disposal and avoids unnecessary re-fetches.

abstract class _$SpacesController extends $AsyncNotifier<List<Space>> {
  FutureOr<List<Space>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Space>>, List<Space>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Space>>, List<Space>>,
              AsyncValue<List<Space>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
