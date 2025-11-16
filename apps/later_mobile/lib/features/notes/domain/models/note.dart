/// Note model for free-form content and documentation
/// Designed for cloud storage with Supabase
///
/// A Note represents a simple piece of content with:
/// - A title (required)
/// - Optional body content
/// - Association with a Space
/// - Tags for organization
/// - Timestamps for creation and updates
class Note {
  Note({
    required this.id,
    required this.title,
    this.content,
    required this.spaceId,
    required this.userId,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.sortOrder = 0,
  }) : tags = tags ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Create from JSON for Supabase compatibility
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      spaceId: json['space_id'] as String,
      userId: json['user_id'] as String,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      sortOrder: (json['sort_order'] as int?) ?? 0,
    );
  }

  /// Unique identifier (UUID for Supabase)
  final String id;

  /// Title/heading of the note
  final String title;

  /// Optional content/body of the note
  final String? content;

  /// ID of the space this note belongs to
  final String spaceId;

  /// ID of the user who owns this note
  final String userId;

  /// Tags associated with the note for organization
  final List<String> tags;

  /// When the note was created
  final DateTime createdAt;

  /// When the note was last updated
  final DateTime updatedAt;

  /// Sort order within a space (space-scoped, not global)
  /// Used for user-defined ordering via drag-and-drop
  final int sortOrder;

  /// Create a copy of this note with updated fields
  ///
  /// Note: To explicitly clear nullable fields like content,
  /// pass null directly (the pattern with clear* parameters is not needed here)
  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? spaceId,
    String? userId,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sortOrder,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      spaceId: spaceId ?? this.spaceId,
      userId: userId ?? this.userId,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Convert to JSON for Supabase compatibility
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'space_id': spaceId,
      'user_id': userId,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sort_order': sortOrder,
    };
  }

  @override
  String toString() {
    return 'Note(id: $id, title: $title, spaceId: $spaceId, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Note && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
