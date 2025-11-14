// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for SpaceRepository singleton.
///
/// Uses keepAlive to maintain repository instance across app lifecycle.
/// Repository handles all space-related data operations with Supabase.

@ProviderFor(spaceRepository)
const spaceRepositoryProvider = SpaceRepositoryProvider._();

/// Provider for SpaceRepository singleton.
///
/// Uses keepAlive to maintain repository instance across app lifecycle.
/// Repository handles all space-related data operations with Supabase.

final class SpaceRepositoryProvider
    extends
        $FunctionalProvider<SpaceRepository, SpaceRepository, SpaceRepository>
    with $Provider<SpaceRepository> {
  /// Provider for SpaceRepository singleton.
  ///
  /// Uses keepAlive to maintain repository instance across app lifecycle.
  /// Repository handles all space-related data operations with Supabase.
  const SpaceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'spaceRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$spaceRepositoryHash();

  @$internal
  @override
  $ProviderElement<SpaceRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SpaceRepository create(Ref ref) {
    return spaceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpaceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpaceRepository>(value),
    );
  }
}

String _$spaceRepositoryHash() => r'8818de849f523d501b2284bc4bbb320dfaa5a327';
