import 'package:hive/hive.dart';

part 'item_model.g.dart';

/// Note model for free-form content and documentation
/// Designed for both local storage (Hive) and future backend sync (Supabase)
///
/// A Note represents a simple piece of content with:
/// - A title (required)
/// - Optional body content
/// - Association with a Space
/// - Tags for organization
/// - Timestamps for creation and updates
/// - Sync status for future backend integration
@HiveType(typeId: 1)
class Item {
  Item({
    required this.id,
    required this.title,
    this.content,
    required this.spaceId,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncStatus,
  }) : tags = tags ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Create from JSON for future API compatibility
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      spaceId: json['spaceId'] as String,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      syncStatus: json['syncStatus'] as String?,
    );
  }

  /// Unique identifier (UUID for future sync compatibility)
  @HiveField(0)
  final String id;

  /// Title/heading of the note
  @HiveField(2)
  final String title;

  /// Optional content/body of the note
  @HiveField(3)
  final String? content;

  /// ID of the space this note belongs to
  @HiveField(4)
  final String spaceId;

  /// Tags associated with the note for organization
  @HiveField(7)
  final List<String> tags;

  /// When the note was created
  @HiveField(8)
  final DateTime createdAt;

  /// When the note was last updated
  @HiveField(9)
  final DateTime updatedAt;

  /// Sync status for future backend integration
  /// null = local-only, 'pending' = waiting to sync, 'synced' = synced with backend
  @HiveField(10)
  final String? syncStatus;

  /// Create a copy of this note with updated fields
  ///
  /// Note: To explicitly clear nullable fields like content or syncStatus,
  /// pass null directly (the pattern with clear* parameters is not needed here)
  Item copyWith({
    String? id,
    String? title,
    String? content,
    String? spaceId,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      spaceId: spaceId ?? this.spaceId,
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
      'title': title,
      'content': content,
      'spaceId': spaceId,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'syncStatus': syncStatus,
    };
  }

  @override
  String toString() {
    return 'Item(id: $id, title: $title, spaceId: $spaceId, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Item && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
