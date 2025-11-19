import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:later_mobile/core/enums/content_type.dart';
import 'package:later_mobile/features/search/domain/models/models.dart';

part 'search_filters_controller.g.dart';

/// Controller for managing search filters
///
/// This controller handles:
/// - Content type filtering (notes, todo lists, lists, etc.)
/// - Tag-based filtering
/// - Filter reset functionality
///
/// Auto-disposes when no longer used.
@riverpod
class SearchFiltersController extends _$SearchFiltersController {
  @override
  SearchFilters build() {
    // Initial state: no filters (all types, no tags)
    return SearchFilters();
  }

  /// Sets the content types filter
  ///
  /// Pass null or empty list to clear the filter (show all types).
  void setContentTypes(List<ContentType>? types) {
    state = state.copyWith(
      contentTypes: types,
      clearContentTypes: types == null,
    );
  }

  /// Sets the tags filter
  ///
  /// Pass null or empty list to clear the filter (show all tags).
  void setTags(List<String>? tags) {
    state = state.copyWith(
      tags: tags,
      clearTags: tags == null,
    );
  }

  /// Resets all filters to default state
  void reset() {
    state = SearchFilters();
  }
}
