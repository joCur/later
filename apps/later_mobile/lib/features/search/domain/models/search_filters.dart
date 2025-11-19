import 'package:later_mobile/core/enums/content_type.dart';

/// SearchFilters model representing active search filters
///
/// This model holds the current filter state for the search UI.
/// Filters can be applied to narrow down search results by content type and tags.
class SearchFilters {
  SearchFilters({
    this.contentTypes,
    this.tags,
  });

  /// Optional filter for specific content types
  /// If null, show all content types
  final List<ContentType>? contentTypes;

  /// Optional filter for tags
  /// If provided, only show results with these tags
  final List<String>? tags;

  /// Whether any filters are currently active
  bool get hasActiveFilters =>
      (contentTypes != null && contentTypes!.isNotEmpty) ||
      (tags != null && tags!.isNotEmpty);

  /// Create a copy of this filter state with updated fields
  SearchFilters copyWith({
    List<ContentType>? contentTypes,
    List<String>? tags,
    bool clearContentTypes = false,
    bool clearTags = false,
  }) {
    return SearchFilters(
      contentTypes: clearContentTypes ? null : (contentTypes ?? this.contentTypes),
      tags: clearTags ? null : (tags ?? this.tags),
    );
  }

  /// Reset all filters to default (no filters)
  SearchFilters reset() {
    return SearchFilters();
  }

  @override
  String toString() {
    return 'SearchFilters(contentTypes: $contentTypes, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchFilters &&
        _listEquals(other.contentTypes, contentTypes) &&
        _listEquals(other.tags, tags);
  }

  @override
  int get hashCode => contentTypes.hashCode ^ tags.hashCode;

  /// Helper method to compare lists
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
