import 'package:hive/hive.dart';

part 'item_model.g.dart';

/// Enum representing the type of item
@HiveType(typeId: 0)
enum ItemType {
  @HiveField(0)
  task,
  @HiveField(1)
  note,
  @HiveField(2)
  list,
}

/// Item model for tasks, notes, and lists
/// Designed for both local storage (Hive) and future backend sync (Supabase)
@HiveType(typeId: 1)
class Item {
  /// Unique identifier (UUID for future sync compatibility)
  @HiveField(0)
  final String id;

  /// Type of item (task, note, or list)
  @HiveField(1)
  final ItemType type;

  /// Title/heading of the item
  @HiveField(2)
  final String title;

  /// Optional content/body of the item
  @HiveField(3)
  final String? content;

  /// ID of the space this item belongs to
  @HiveField(4)
  final String spaceId;

  /// Whether the task is completed (only relevant for tasks)
  @HiveField(5)
  final bool isCompleted;

  /// Optional due date (primarily for tasks)
  @HiveField(6)
  final DateTime? dueDate;

  /// Tags associated with the item
  @HiveField(7)
  final List<String> tags;

  /// When the item was created
  @HiveField(8)
  final DateTime createdAt;

  /// When the item was last updated
  @HiveField(9)
  final DateTime updatedAt;

  /// Sync status for future backend integration
  /// null = local-only, 'pending' = waiting to sync, 'synced' = synced with backend
  @HiveField(10)
  final String? syncStatus;

  Item({
    required this.id,
    required this.type,
    required this.title,
    this.content,
    required this.spaceId,
    this.isCompleted = false,
    this.dueDate,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncStatus,
  })  : tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create a copy of this item with updated fields
  Item copyWith({
    String? id,
    ItemType? type,
    String? title,
    String? content,
    String? spaceId,
    bool? isCompleted,
    DateTime? dueDate,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) {
    return Item(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      spaceId: spaceId ?? this.spaceId,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  /// Convert to JSON for future API compatibility
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'content': content,
      'spaceId': spaceId,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'syncStatus': syncStatus,
    };
  }

  /// Create from JSON for future API compatibility
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      type: ItemType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      title: json['title'] as String,
      content: json['content'] as String?,
      spaceId: json['spaceId'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      syncStatus: json['syncStatus'] as String?,
    );
  }

  @override
  String toString() {
    return 'Item(id: $id, type: $type, title: $title, spaceId: $spaceId, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Item && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
