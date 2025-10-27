import 'package:hive/hive.dart';

part 'space_model.g.dart';

/// Space model for organizing items into workspaces
/// Designed for both local storage (Hive) and future backend sync (Supabase)
@HiveType(typeId: 2)
class Space {
  Space({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    this.itemCount = 0,
    this.isArchived = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Create from JSON for future API compatibility
  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      itemCount: json['itemCount'] as int? ?? 0,
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Unique identifier (UUID for future sync compatibility)
  @HiveField(0)
  final String id;

  /// Name of the space
  @HiveField(1)
  final String name;

  /// Optional icon (emoji or icon name)
  @HiveField(2)
  final String? icon;

  /// Optional color (hex string)
  @HiveField(3)
  final String? color;

  /// Number of items in this space
  @HiveField(4)
  final int itemCount;

  /// Whether the space is archived
  @HiveField(5)
  final bool isArchived;

  /// When the space was created
  @HiveField(6)
  final DateTime createdAt;

  /// When the space was last updated
  @HiveField(7)
  final DateTime updatedAt;

  /// Create a copy of this space with updated fields
  Space copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    int? itemCount,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Space(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      itemCount: itemCount ?? this.itemCount,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON for future API compatibility
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'itemCount': itemCount,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Space(id: $id, name: $name, itemCount: $itemCount, isArchived: $isArchived)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Space && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
