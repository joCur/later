import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:later_mobile/core/error/error.dart';
import 'package:later_mobile/features/search/application/providers.dart';
import 'package:later_mobile/features/search/domain/models/models.dart';

part 'search_controller.g.dart';

/// Controller for managing search state with debouncing
///
/// This controller handles:
/// - Debounced search queries (300ms delay)
/// - Loading states during search operations
/// - Error handling with AppError
/// - Clearing search results
///
/// Auto-disposes when no longer used.
@riverpod
class SearchController extends _$SearchController {
  /// Timer for debouncing search requests
  Timer? _debounceTimer;

  @override
  Future<List<SearchResult>> build() async {
    // Register cleanup callback to prevent memory leaks
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    // Initial state: empty list
    return [];
  }

  /// Performs a search with debouncing
  ///
  /// Cancels any pending search and schedules a new one after 300ms.
  /// Sets loading state immediately for UI feedback.
  void search(SearchQuery query) {
    // Cancel previous timer if exists
    _debounceTimer?.cancel();

    // Check if still mounted before updating
    if (!ref.mounted) return;

    // Set loading state immediately (UI feedback)
    state = const AsyncValue.loading();

    // Create new timer with 300ms duration
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        // Check if still mounted before starting search
        if (!ref.mounted) return;

        // Get search service
        final searchService = ref.read(searchServiceProvider);

        // Perform search
        final results = await searchService.search(query);

        // Check if still mounted before updating (Riverpod 3.0 best practice)
        if (!ref.mounted) return;

        // Update state with results
        state = AsyncValue.data(results);
      } on AppError catch (e) {
        // Log and store AppError
        ErrorLogger.logError(e, context: 'SearchController.search');

        if (!ref.mounted) return;
        state = AsyncValue.error(e, StackTrace.current);
      } catch (e, stackTrace) {
        // Wrap unknown errors
        final error = AppError(
          code: ErrorCode.unknownError,
          message: 'Unexpected error during search: $e',
          technicalDetails: e.toString(),
        );
        ErrorLogger.logError(error, context: 'SearchController.search');

        if (!ref.mounted) return;
        state = AsyncValue.error(error, stackTrace);
      }
    });
  }

  /// Clears the search results and cancels any pending search
  void clear() {
    // Cancel debounce timer if running
    _debounceTimer?.cancel();

    // Check if still mounted before updating
    if (!ref.mounted) return;

    // Reset to empty results
    state = const AsyncValue.data([]);
  }
}
