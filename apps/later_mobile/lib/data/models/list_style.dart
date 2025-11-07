/// Enum representing the style of list display
enum ListStyle {
  /// Bulleted list style
  bullets,

  /// Numbered list style
  numbered,

  /// Checkbox list style for tasks
  checkboxes,

  /// Simple list style (no prefix)
  simple,
}

/// Extension for ListStyle enum serialization
extension ListStyleExtension on ListStyle {
  /// Convert enum to string for JSON serialization
  String toJson() => toString().split('.').last;

  /// Create enum from string for JSON deserialization
  static ListStyle fromJson(String value) {
    return ListStyle.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => ListStyle.bullets,
    );
  }
}
