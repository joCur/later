// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for [SpaceService] singleton.
///
/// Depends on [spaceRepositoryProvider] for data access.
/// Keep alive to maintain service instance throughout app lifecycle.

@ProviderFor(spaceService)
const spaceServiceProvider = SpaceServiceProvider._();

/// Provider for [SpaceService] singleton.
///
/// Depends on [spaceRepositoryProvider] for data access.
/// Keep alive to maintain service instance throughout app lifecycle.

final class SpaceServiceProvider
    extends $FunctionalProvider<SpaceService, SpaceService, SpaceService>
    with $Provider<SpaceService> {
  /// Provider for [SpaceService] singleton.
  ///
  /// Depends on [spaceRepositoryProvider] for data access.
  /// Keep alive to maintain service instance throughout app lifecycle.
  const SpaceServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'spaceServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$spaceServiceHash();

  @$internal
  @override
  $ProviderElement<SpaceService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SpaceService create(Ref ref) {
    return spaceService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpaceService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpaceService>(value),
    );
  }
}

String _$spaceServiceHash() => r'b890c7adc19e41cf1ad17ef62dca1077c1306e42';
