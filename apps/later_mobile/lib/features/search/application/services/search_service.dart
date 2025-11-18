import 'package:later_mobile/core/error/error.dart';
import 'package:later_mobile/features/search/data/repositories/search_repository.dart';
import 'package:later_mobile/features/search/domain/models/models.dart';

/// Application service for search operations.
///
/// Handles business logic for search functionality including:
/// - Input validation (empty queries, spaceId, contentTypes)
/// - Query string trimming and length limits
/// - Error handling with AppError
class SearchService {
  /// Creates a SearchService with the required repository dependency.
  SearchService(this._repository);

  final SearchRepository _repository;

  /// Maximum allowed length for search queries (characters).
  static const int maxQueryLength = 500;

  /// Performs a search operation with validation.
  ///
  /// Returns an empty list if:
  /// - Query string is empty or whitespace-only (after trimming)
  /// - ContentTypes filter is an empty list
  ///
  /// Throws [AppError] with [ErrorCode.validationRequired] if:
  /// - SpaceId is empty
  ///
  /// Throws [AppError] with [ErrorCode.validationOutOfRange] if:
  /// - Query string exceeds [maxQueryLength] characters
  ///
  /// Propagates [AppError] from repository layer.
  /// Wraps unknown exceptions as [AppError] with [ErrorCode.unknownError].
  Future<List<SearchResult>> search(SearchQuery query) async {
    try {
      // Trim whitespace from query
      final trimmedQuery = query.query.trim();

      // Validate: empty query returns empty list
      if (trimmedQuery.isEmpty) {
        return [];
      }

      // Validate: spaceId required
      if (query.spaceId.isEmpty) {
        throw ValidationErrorMapper.requiredField('Space ID');
      }

      // Validate: query length limit
      if (trimmedQuery.length > maxQueryLength) {
        throw ValidationErrorMapper.outOfRange(
          'Query length',
          '1',
          maxQueryLength.toString(),
        );
      }

      // Validate: empty contentTypes filter returns empty list
      if (query.contentTypes != null && query.contentTypes!.isEmpty) {
        return [];
      }

      // Create query with trimmed string
      final validatedQuery = SearchQuery(
        query: trimmedQuery,
        spaceId: query.spaceId,
        contentTypes: query.contentTypes,
        tags: query.tags,
      );

      // Call repository
      return await _repository.search(validatedQuery);
    } on AppError {
      // Propagate AppError as-is
      rethrow;
    } catch (e) {
      // Wrap unknown errors
      throw AppError(
        code: ErrorCode.unknownError,
        message: 'Unexpected error in search: $e',
        technicalDetails: e.toString(),
      );
    }
  }
}
