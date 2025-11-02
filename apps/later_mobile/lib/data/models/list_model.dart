import 'package:hive/hive.dart';

part 'list_model.g.dart';

/// Enum representing the style of list display
@HiveType(typeId: 24)
enum ListStyle {
  /// Bulleted list style
  @HiveField(0)
  bullets,

  /// Numbered list style
  @HiveField(1)
  numbered,

  /// Checkbox list style for tasks
  @HiveField(2)
  checkboxes,

  /// Simple list style (no prefix)
  @HiveField(3)
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

/// ListItem model representing an individual item within a list
@HiveType(typeId: 23)
class ListItem {
  ListItem({
    required this.id,
    required this.title,
    this.notes,
    this.isChecked = false,
    required this.sortOrder,
  });

  /// Create from JSON for serialization
  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      id: json['id'] as String,
      title: json['title'] as String,
      notes: json['notes'] as String?,
      isChecked: json['isChecked'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int,
    );
  }

  /// Unique identifier for the list item
  @HiveField(0)
  final String id;

  /// Title of the list item
  @HiveField(1)
  final String title;

  /// Optional notes providing additional details
  @HiveField(2)
  final String? notes;

  /// Whether the item is checked (only used when style is checkboxes)
  @HiveField(3)
  final bool isChecked;

  /// Sort order for manual reordering of items
  @HiveField(4)
  final int sortOrder;

  /// Create a copy of this list item with updated fields
  ///
  /// Note: To explicitly clear nullable fields like notes, use the clearNotes parameter
  ListItem copyWith({
    String? id,
    String? title,
    String? notes,
    bool clearNotes = false,
    bool? isChecked,
    int? sortOrder,
  }) {
    return ListItem(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: clearNotes ? null : (notes ?? this.notes),
      isChecked: isChecked ?? this.isChecked,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'isChecked': isChecked,
      'sortOrder': sortOrder,
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

/// ListModel representing a collection of list items with a specific style
@HiveType(typeId: 22)
class ListModel {
  ListModel({
    required this.id,
    required this.spaceId,
    required this.name,
    this.icon,
    List<ListItem>? items,
    this.style = ListStyle.bullets,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.sortOrder = 0,
  }) : items = items ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Create from JSON for serialization
  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      id: json['id'] as String,
      spaceId: json['spaceId'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => ListItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      style: ListStyleExtension.fromJson(json['style'] as String? ?? 'bullets'),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      sortOrder: (json['sortOrder'] as int?) ?? 0,
    );
  }

  /// Unique identifier for the list
  @HiveField(0)
  final String id;

  /// ID of the space this list belongs to
  @HiveField(1)
  final String spaceId;

  /// Name of the list
  @HiveField(2)
  final String name;

  /// Optional custom icon name or emoji
  @HiveField(3)
  final String? icon;

  /// Collection of list items
  @HiveField(4)
  final List<ListItem> items;

  /// Display style of the list
  @HiveField(5)
  final ListStyle style;

  /// When the list was created
  @HiveField(6)
  final DateTime createdAt;

  /// When the list was last updated
  @HiveField(7)
  final DateTime updatedAt;

  /// Sort order within a space (space-scoped, not global)
  /// Used for user-defined ordering via drag-and-drop
  @HiveField(8)
  final int sortOrder;

  /// Total number of items in the list
  int get totalItems => items.length;

  /// Number of checked items in the list (only relevant for checkbox style)
  int get checkedItems => items.where((item) => item.isChecked).length;

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
    String? name,
    String? icon,
    bool clearIcon = false,
    List<ListItem>? items,
    ListStyle? style,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sortOrder,
  }) {
    return ListModel(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      name: name ?? this.name,
      icon: clearIcon ? null : (icon ?? this.icon),
      items: items ?? this.items,
      style: style ?? this.style,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spaceId': spaceId,
      'name': name,
      'icon': icon,
      'items': items.map((item) => item.toJson()).toList(),
      'style': style.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'sortOrder': sortOrder,
    };
  }

  @override
  String toString() {
    return 'ListModel(id: $id, name: $name, spaceId: $spaceId, style: $style, totalItems: $totalItems, checkedItems: $checkedItems)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ListModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
