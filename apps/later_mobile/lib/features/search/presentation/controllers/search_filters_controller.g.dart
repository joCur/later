// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_filters_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing search filters
///
/// This controller handles:
/// - Content type filtering (notes, todo lists, lists, etc.)
/// - Tag-based filtering
/// - Filter reset functionality
///
/// Auto-disposes when no longer used.

@ProviderFor(SearchFiltersController)
const searchFiltersControllerProvider = SearchFiltersControllerProvider._();

/// Controller for managing search filters
///
/// This controller handles:
/// - Content type filtering (notes, todo lists, lists, etc.)
/// - Tag-based filtering
/// - Filter reset functionality
///
/// Auto-disposes when no longer used.
final class SearchFiltersControllerProvider
    extends $NotifierProvider<SearchFiltersController, SearchFilters> {
  /// Controller for managing search filters
  ///
  /// This controller handles:
  /// - Content type filtering (notes, todo lists, lists, etc.)
  /// - Tag-based filtering
  /// - Filter reset functionality
  ///
  /// Auto-disposes when no longer used.
  const SearchFiltersControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchFiltersControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchFiltersControllerHash();

  @$internal
  @override
  SearchFiltersController create() => SearchFiltersController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchFilters value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchFilters>(value),
    );
  }
}

String _$searchFiltersControllerHash() =>
    r'9216c4652084ef7e662a96d4e5b884b798b20158';

/// Controller for managing search filters
///
/// This controller handles:
/// - Content type filtering (notes, todo lists, lists, etc.)
/// - Tag-based filtering
/// - Filter reset functionality
///
/// Auto-disposes when no longer used.

abstract class _$SearchFiltersController extends $Notifier<SearchFilters> {
  SearchFilters build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SearchFilters, SearchFilters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchFilters, SearchFilters>,
              SearchFilters,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
