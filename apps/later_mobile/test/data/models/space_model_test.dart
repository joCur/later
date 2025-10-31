import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/models/space_model.dart';

void main() {
  group('SpaceModel', () {
    test('creates a space with all required fields', () {
      final space = Space(id: 'space-1', name: 'Personal');

      expect(space.id, 'space-1');
      expect(space.name, 'Personal');
      expect(space.isArchived, false);
      expect(space.icon, isNull);
      expect(space.color, isNull);
    });

    test('creates a space with optional fields', () {
      final space = Space(
        id: 'space-1',
        name: 'Work',
        icon: '💼',
        color: '#FF5733',
      );

      expect(space.icon, '💼');
      expect(space.color, '#FF5733');
      expect(space.isArchived, false);
    });

    test('copyWith creates a new instance with updated fields', () {
      final original = Space(
        id: 'space-1',
        name: 'Original Name',
      );

      final updated = original.copyWith(
        name: 'Updated Name',
        isArchived: true,
      );

      expect(updated.id, original.id);
      expect(updated.name, 'Updated Name');
      expect(updated.isArchived, true);
    });

    test('toJson serializes correctly', () {
      final space = Space(
        id: 'space-1',
        name: 'Work',
        icon: '💼',
        color: '#FF5733',
      );

      final json = space.toJson();

      expect(json['id'], 'space-1');
      expect(json['name'], 'Work');
      expect(json['icon'], '💼');
      expect(json['color'], '#FF5733');
      expect(json['isArchived'], false);
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'space-1',
        'name': 'Personal',
        'icon': '🏠',
        'color': '#3498db',
        'isArchived': false,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-02T00:00:00.000Z',
      };

      final space = Space.fromJson(json);

      expect(space.id, 'space-1');
      expect(space.name, 'Personal');
      expect(space.icon, '🏠');
      expect(space.color, '#3498db');
      expect(space.isArchived, false);
    });

    test('roundtrip JSON serialization preserves data', () {
      final original = Space(
        id: 'space-1',
        name: 'Projects',
        icon: '📁',
        color: '#9b59b6',
      );

      final json = original.toJson();
      final restored = Space.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.icon, original.icon);
      expect(restored.color, original.color);
      expect(restored.isArchived, original.isArchived);
    });

    test('equality is based on id', () {
      final space1 = Space(id: 'same-id', name: 'Name 1');

      final space2 = Space(id: 'same-id', name: 'Name 2');

      final space3 = Space(id: 'different-id', name: 'Name 1');

      expect(space1, equals(space2));
      expect(space1, isNot(equals(space3)));
    });

    test('toString includes key fields', () {
      final space = Space(id: 'space-1', name: 'Work');

      final string = space.toString();

      expect(string, contains('space-1'));
      expect(string, contains('Work'));
      expect(string, contains('false'));
    });

    test('archived spaces can be identified', () {
      final activeSpace = Space(id: 'space-1', name: 'Active');

      final archivedSpace = Space(
        id: 'space-2',
        name: 'Archived',
        isArchived: true,
      );

      expect(activeSpace.isArchived, false);
      expect(archivedSpace.isArchived, true);
    });
  });
}
