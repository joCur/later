// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for ListService (singleton).
///
/// The service layer handles business logic and validation.
/// Uses keepAlive to maintain service instance across the app.

@ProviderFor(listService)
const listServiceProvider = ListServiceProvider._();

/// Provider for ListService (singleton).
///
/// The service layer handles business logic and validation.
/// Uses keepAlive to maintain service instance across the app.

final class ListServiceProvider
    extends $FunctionalProvider<ListService, ListService, ListService>
    with $Provider<ListService> {
  /// Provider for ListService (singleton).
  ///
  /// The service layer handles business logic and validation.
  /// Uses keepAlive to maintain service instance across the app.
  const ListServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listServiceHash();

  @$internal
  @override
  $ProviderElement<ListService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ListService create(Ref ref) {
    return listService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListService>(value),
    );
  }
}

String _$listServiceHash() => r'4476e84eb59db3311cd7a1a91e9bbfcb6adf30ad';
