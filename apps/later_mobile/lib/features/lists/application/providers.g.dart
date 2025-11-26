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

/// Provider for fetching a single list by ID.
///
/// This is a family provider that takes a listId parameter.
/// Returns `AsyncValue<ListModel?>` - null if list not found.
/// Auto-disposes when no longer watched.

@ProviderFor(listById)
const listByIdProvider = ListByIdFamily._();

/// Provider for fetching a single list by ID.
///
/// This is a family provider that takes a listId parameter.
/// Returns `AsyncValue<ListModel?>` - null if list not found.
/// Auto-disposes when no longer watched.

final class ListByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<ListModel?>,
          ListModel?,
          FutureOr<ListModel?>
        >
    with $FutureModifier<ListModel?>, $FutureProvider<ListModel?> {
  /// Provider for fetching a single list by ID.
  ///
  /// This is a family provider that takes a listId parameter.
  /// Returns `AsyncValue<ListModel?>` - null if list not found.
  /// Auto-disposes when no longer watched.
  const ListByIdProvider._({
    required ListByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'listByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listByIdHash();

  @override
  String toString() {
    return r'listByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ListModel?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ListModel?> create(Ref ref) {
    final argument = this.argument as String;
    return listById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ListByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listByIdHash() => r'7c35ca03727d4809521f189dd556cda143e48ba6';

/// Provider for fetching a single list by ID.
///
/// This is a family provider that takes a listId parameter.
/// Returns `AsyncValue<ListModel?>` - null if list not found.
/// Auto-disposes when no longer watched.

final class ListByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ListModel?>, String> {
  const ListByIdFamily._()
    : super(
        retry: null,
        name: r'listByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for fetching a single list by ID.
  ///
  /// This is a family provider that takes a listId parameter.
  /// Returns `AsyncValue<ListModel?>` - null if list not found.
  /// Auto-disposes when no longer watched.

  ListByIdProvider call(String listId) =>
      ListByIdProvider._(argument: listId, from: this);

  @override
  String toString() => r'listByIdProvider';
}
