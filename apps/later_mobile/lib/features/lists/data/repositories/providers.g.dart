// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for ListRepository.
///
/// Uses keepAlive: true to maintain a singleton instance throughout the app lifecycle.
/// The repository handles all data access for ListModel and ListItem entities.

@ProviderFor(listRepository)
const listRepositoryProvider = ListRepositoryProvider._();

/// Provider for ListRepository.
///
/// Uses keepAlive: true to maintain a singleton instance throughout the app lifecycle.
/// The repository handles all data access for ListModel and ListItem entities.

final class ListRepositoryProvider
    extends $FunctionalProvider<ListRepository, ListRepository, ListRepository>
    with $Provider<ListRepository> {
  /// Provider for ListRepository.
  ///
  /// Uses keepAlive: true to maintain a singleton instance throughout the app lifecycle.
  /// The repository handles all data access for ListModel and ListItem entities.
  const ListRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listRepositoryHash();

  @$internal
  @override
  $ProviderElement<ListRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ListRepository create(Ref ref) {
    return listRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListRepository>(value),
    );
  }
}

String _$listRepositoryHash() => r'01f1c3b9ff4386af3d0810d6dfed76a740c71c19';
