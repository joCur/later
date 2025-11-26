// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing search state with debouncing
///
/// This controller handles:
/// - Debounced search queries (300ms delay)
/// - Loading states during search operations
/// - Error handling with AppError
/// - Clearing search results
///
/// Auto-disposes when no longer used.

@ProviderFor(SearchController)
const searchControllerProvider = SearchControllerProvider._();

/// Controller for managing search state with debouncing
///
/// This controller handles:
/// - Debounced search queries (300ms delay)
/// - Loading states during search operations
/// - Error handling with AppError
/// - Clearing search results
///
/// Auto-disposes when no longer used.
final class SearchControllerProvider
    extends $AsyncNotifierProvider<SearchController, List<SearchResult>> {
  /// Controller for managing search state with debouncing
  ///
  /// This controller handles:
  /// - Debounced search queries (300ms delay)
  /// - Loading states during search operations
  /// - Error handling with AppError
  /// - Clearing search results
  ///
  /// Auto-disposes when no longer used.
  const SearchControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchControllerHash();

  @$internal
  @override
  SearchController create() => SearchController();
}

String _$searchControllerHash() => r'fdc341a0739cf16d9542d42644c3f9233a6b9f6e';

/// Controller for managing search state with debouncing
///
/// This controller handles:
/// - Debounced search queries (300ms delay)
/// - Loading states during search operations
/// - Error handling with AppError
/// - Clearing search results
///
/// Auto-disposes when no longer used.

abstract class _$SearchController extends $AsyncNotifier<List<SearchResult>> {
  FutureOr<List<SearchResult>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<SearchResult>>, List<SearchResult>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SearchResult>>, List<SearchResult>>,
              AsyncValue<List<SearchResult>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
