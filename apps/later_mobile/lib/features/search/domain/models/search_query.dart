import 'package:later_mobile/core/enums/content_type.dart';

/// SearchQuery model representing a search request
///
/// Contains all parameters needed to perform a search across content types
/// within a specific space.
class SearchQuery {
  SearchQuery({
    required this.query,
    required this.spaceId,
    this.contentTypes,
    this.tags,
    this.limit = 50,
    this.offset = 0,
  });

  /// The search query string entered by the user
  final String query;

  /// ID of the space to search within (space-scoped search)
  final String spaceId;

  /// Optional filter for specific content types
  /// If null, search across all content types
  final List<ContentType>? contentTypes;

  /// Optional filter for tags
  /// If provided, only return results that have ALL of these tags
  final List<String>? tags;

  /// Maximum number of results to return per content type (default: 50)
  final int limit;

  /// Number of results to skip per content type (default: 0)
  final int offset;

  /// Create a copy of this search query with updated fields
  SearchQuery copyWith({
    String? query,
    String? spaceId,
    List<ContentType>? contentTypes,
    List<String>? tags,
    int? limit,
    int? offset,
  }) {
    return SearchQuery(
      query: query ?? this.query,
      spaceId: spaceId ?? this.spaceId,
      contentTypes: contentTypes ?? this.contentTypes,
      tags: tags ?? this.tags,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  String toString() {
    return 'SearchQuery(query: $query, spaceId: $spaceId, contentTypes: $contentTypes, tags: $tags, limit: $limit, offset: $offset)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchQuery &&
        other.query == query &&
        other.spaceId == spaceId &&
        _listEquals(other.contentTypes, contentTypes) &&
        _listEquals(other.tags, tags) &&
        other.limit == limit &&
        other.offset == offset;
  }

  @override
  int get hashCode {
    return query.hashCode ^
        spaceId.hashCode ^
        contentTypes.hashCode ^
        tags.hashCode ^
        limit.hashCode ^
        offset.hashCode;
  }

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
