/// ListItem model representing an individual item within a list
class ListItem {
  ListItem({
    required this.id,
    required this.listId,
    required this.title,
    this.notes,
    this.isChecked = false,
    required this.sortOrder,
  });

  /// Create from JSON for Supabase compatibility
  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      id: json['id'] as String,
      listId: json['list_id'] as String,
      title: json['title'] as String,
      notes: json['notes'] as String?,
      isChecked: json['is_checked'] as bool? ?? false,
      sortOrder: json['sort_order'] as int,
    );
  }

  /// Unique identifier for the list item
  final String id;

  /// Foreign key to parent ListModel
  final String listId;

  /// Title of the list item
  final String title;

  /// Optional notes providing additional details
  final String? notes;

  /// Whether the item is checked (only used when style is checkboxes)
  final bool isChecked;

  /// Sort order for manual reordering of items
  final int sortOrder;

  /// Create a copy of this list item with updated fields
  ///
  /// Note: To explicitly clear nullable fields like notes, use the clearNotes parameter
  ListItem copyWith({
    String? id,
    String? listId,
    String? title,
    String? notes,
    bool clearNotes = false,
    bool? isChecked,
    int? sortOrder,
  }) {
    return ListItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      title: title ?? this.title,
      notes: clearNotes ? null : (notes ?? this.notes),
      isChecked: isChecked ?? this.isChecked,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Convert to JSON for Supabase compatibility
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'list_id': listId,
      'title': title,
      'notes': notes,
      'is_checked': isChecked,
      'sort_order': sortOrder,
    };
  }

  @override
  String toString() {
    return 'ListItem(id: $id, title: $title, isChecked: $isChecked, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ListItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
