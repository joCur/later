import 'package:flutter/material.dart';
import 'empty_state.dart';

/// Empty state for search with no results
///
/// Displays when a search query returns no results.
///
/// Features:
/// - Search icon (64px)
/// - Helpful message about trying different keywords
/// - No CTA button (just informational)
/// - Optional query parameter to customize message
///
/// Example usage:
/// ```dart
/// EmptySearchState(query: 'flutter')
/// ```
class EmptySearchState extends StatelessWidget {
  /// Creates an empty search state widget.
  const EmptySearchState({
    super.key,
    this.query,
  });

  /// Optional search query that returned no results
  final String? query;

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.search,
      iconSize: 64.0,
      title: 'No results found',
      description: 'Try different keywords or check your spelling',
    );
  }
}
