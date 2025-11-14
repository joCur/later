/// Space model for organizing items into workspaces
/// Designed for cloud storage with Supabase
class Space {
  Space({
    required this.id,
    required this.name,
    required this.userId,
    this.icon,
    this.color,
    this.isArchived = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Create from JSON for Supabase compatibility
  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
      id: json['id'] as String,
      name: json['name'] as String,
      userId: json['user_id'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Unique identifier (UUID for Supabase)
  final String id;

  /// Name of the space
  final String name;

  /// ID of the user who owns this space
  final String userId;

  /// Optional icon (emoji or icon name)
  final String? icon;

  /// Optional color (hex string)
  final String? color;

  /// Whether the space is archived
  final bool isArchived;

  /// When the space was created
  final DateTime createdAt;

  /// When the space was last updated
  final DateTime updatedAt;

  /// Create a copy of this space with updated fields
  Space copyWith({
    String? id,
    String? name,
    String? userId,
    String? icon,
    String? color,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Space(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON for Supabase compatibility
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'user_id': userId,
      'icon': icon,
      'color': color,
      'is_archived': isArchived,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Space(id: $id, name: $name, isArchived: $isArchived)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Space && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
