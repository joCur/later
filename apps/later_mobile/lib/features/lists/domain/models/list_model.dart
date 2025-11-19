import 'package:later_mobile/data/models/list_style.dart';

/// ListModel representing a collection of list items with a specific style
///
/// In Supabase, list items are stored in a separate `list_items` table
/// and fetched via repository methods when needed. This model contains
/// aggregate counts (totalItemCount, checkedItemCount) populated from
/// database GROUP BY queries for efficient list views.
class ListModel {
  ListModel({
    required this.id,
    required this.spaceId,
    required this.userId,
    required this.name,
    this.icon,
    this.style = ListStyle.bullets,
    this.totalItemCount = 0,
    this.checkedItemCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.sortOrder = 0,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Create from JSON for Supabase compatibility
  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      id: json['id'] as String,
      spaceId: json['space_id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      style: ListStyleExtension.fromJson(json['style'] as String? ?? 'bullets'),
      totalItemCount: (json['total_item_count'] as int?) ?? 0,
      checkedItemCount: (json['checked_item_count'] as int?) ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      sortOrder: (json['sort_order'] as int?) ?? 0,
    );
  }

  /// Unique identifier for the list
  final String id;

  /// ID of the space this list belongs to
  final String spaceId;

  /// ID of the user who owns this list
  final String userId;

  /// Name of the list
  final String name;

  /// Optional custom icon name or emoji
  final String? icon;

  /// Display style of the list
  final ListStyle style;

  /// Total number of list items (populated from database aggregate)
  final int totalItemCount;

  /// Number of checked items (populated from database aggregate, only relevant for checkbox style)
  final int checkedItemCount;

  /// When the list was created
  final DateTime createdAt;

  /// When the list was last updated
  final DateTime updatedAt;

  /// Sort order within a space (space-scoped, not global)
  /// Used for user-defined ordering via drag-and-drop
  final int sortOrder;

  /// Total number of items in the list
  int get totalItems => totalItemCount;

  /// Number of checked items in the list (only relevant for checkbox style)
  int get checkedItems => checkedItemCount;

  /// Progress as a value between 0.0 and 1.0 (only relevant for checkbox style)
  /// Returns 0.0 if there are no items to avoid division by zero
  double get progress {
    if (totalItems == 0) return 0.0;
    return checkedItems / totalItems;
  }

  /// Create a copy of this list with updated fields
  ///
  /// Note: To explicitly clear nullable fields like icon, use the clearIcon parameter
  ListModel copyWith({
    String? id,
    String? spaceId,
    String? userId,
    String? name,
    String? icon,
    bool clearIcon = false,
    ListStyle? style,
    int? totalItemCount,
    int? checkedItemCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sortOrder,
  }) {
    return ListModel(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: clearIcon ? null : (icon ?? this.icon),
      style: style ?? this.style,
      totalItemCount: totalItemCount ?? this.totalItemCount,
      checkedItemCount: checkedItemCount ?? this.checkedItemCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Convert to JSON for Supabase compatibility
  ///
  /// Note: totalItemCount and checkedItemCount are computed values from child items
  /// and should not be written to the database.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'space_id': spaceId,
      'user_id': userId,
      'name': name,
      'icon': icon,
      'style': style.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sort_order': sortOrder,
    };
  }

  @override
  String toString() {
    return 'ListModel(id: $id, name: $name, spaceId: $spaceId, userId: $userId, style: $style)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ListModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
