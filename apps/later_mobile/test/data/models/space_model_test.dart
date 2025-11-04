import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/models/space_model.dart';

void main() {
  group('Space', () {
    group('construction', () {
      test('creates with all required fields', () {
        final space = Space(id: 'space-1', name: 'Personal', userId: 'user-1');

        expect(space.id, 'space-1');
        expect(space.name, 'Personal');
        expect(space.userId, 'user-1');
        expect(space.isArchived, false);
        expect(space.icon, isNull);
        expect(space.color, isNull);
        expect(space.createdAt, isA<DateTime>());
        expect(space.updatedAt, isA<DateTime>());
      });

      test('creates with all optional fields', () {
        final createdAt = DateTime(2025, 1, 1, 10);
        final updatedAt = DateTime(2025, 10, 25, 14, 30);

        final space = Space(
          id: 'space-2',
          name: 'Work',
          userId: 'user-2',
          icon: '💼',
          color: '#FF5733',
          isArchived: true,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(space.id, 'space-2');
        expect(space.name, 'Work');
        expect(space.userId, 'user-2');
        expect(space.icon, '💼');
        expect(space.color, '#FF5733');
        expect(space.isArchived, true);
        expect(space.createdAt, createdAt);
        expect(space.updatedAt, updatedAt);
      });

      test('initializes dates to now when not provided', () {
        final beforeCreation = DateTime.now();
        final space = Space(id: 'space-3', name: 'Test', userId: 'user-1');
        final afterCreation = DateTime.now();

        expect(
          space.createdAt.isAfter(
            beforeCreation.subtract(const Duration(seconds: 1)),
          ),
          isTrue,
        );
        expect(
          space.createdAt.isBefore(
            afterCreation.add(const Duration(seconds: 1)),
          ),
          isTrue,
        );
        expect(
          space.updatedAt.isAfter(
            beforeCreation.subtract(const Duration(seconds: 1)),
          ),
          isTrue,
        );
        expect(
          space.updatedAt.isBefore(
            afterCreation.add(const Duration(seconds: 1)),
          ),
          isTrue,
        );
      });

      test('defaults isArchived to false', () {
        final space = Space(id: 'space-4', name: 'Active', userId: 'user-1');

        expect(space.isArchived, false);
      });
    });

    group('fromJson', () {
      test('deserializes from JSON with all fields', () {
        final json = {
          'id': 'space-1',
          'name': 'Work Projects',
          'user_id': 'user-1',
          'icon': '💼',
          'color': '#FF5733',
          'is_archived': true,
          'created_at': '2025-01-01T10:00:00.000Z',
          'updated_at': '2025-01-02T15:30:00.000Z',
        };

        final space = Space.fromJson(json);

        expect(space.id, 'space-1');
        expect(space.name, 'Work Projects');
        expect(space.userId, 'user-1');
        expect(space.icon, '💼');
        expect(space.color, '#FF5733');
        expect(space.isArchived, true);
        expect(space.createdAt, DateTime.parse('2025-01-01T10:00:00.000Z'));
        expect(space.updatedAt, DateTime.parse('2025-01-02T15:30:00.000Z'));
      });

      test('deserializes from JSON with minimal fields', () {
        final json = {
          'id': 'space-2',
          'name': 'Personal',
          'user_id': 'user-2',
          'created_at': '2025-01-01T10:00:00.000Z',
          'updated_at': '2025-01-01T10:00:00.000Z',
        };

        final space = Space.fromJson(json);

        expect(space.id, 'space-2');
        expect(space.name, 'Personal');
        expect(space.userId, 'user-2');
        expect(space.icon, isNull);
        expect(space.color, isNull);
        expect(space.isArchived, false);
      });

      test('handles null icon and color', () {
        final json = {
          'id': 'space-3',
          'name': 'Plain Space',
          'user_id': 'user-1',
          'icon': null,
          'color': null,
          'created_at': '2025-01-01T10:00:00.000Z',
          'updated_at': '2025-01-01T10:00:00.000Z',
        };

        final space = Space.fromJson(json);

        expect(space.icon, isNull);
        expect(space.color, isNull);
      });

      test('handles null is_archived with default false', () {
        final json = {
          'id': 'space-4',
          'name': 'Active',
          'user_id': 'user-1',
          'is_archived': null,
          'created_at': '2025-01-01T10:00:00.000Z',
          'updated_at': '2025-01-01T10:00:00.000Z',
        };

        final space = Space.fromJson(json);

        expect(space.isArchived, false);
      });

      test('handles missing is_archived with default false', () {
        final json = {
          'id': 'space-5',
          'name': 'Active',
          'user_id': 'user-1',
          'created_at': '2025-01-01T10:00:00.000Z',
          'updated_at': '2025-01-01T10:00:00.000Z',
        };

        final space = Space.fromJson(json);

        expect(space.isArchived, false);
      });
    });

    group('toJson', () {
      test('serializes to JSON with all fields', () {
        final createdAt = DateTime(2025, 1, 1, 10);
        final updatedAt = DateTime(2025, 1, 2, 15, 30);

        final space = Space(
          id: 'space-1',
          name: 'Work',
          userId: 'user-1',
          icon: '💼',
          color: '#FF5733',
          isArchived: true,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final json = space.toJson();

        expect(json['id'], 'space-1');
        expect(json['name'], 'Work');
        expect(json['user_id'], 'user-1');
        expect(json['icon'], '💼');
        expect(json['color'], '#FF5733');
        expect(json['is_archived'], true);
        expect(json['created_at'], createdAt.toIso8601String());
        expect(json['updated_at'], updatedAt.toIso8601String());
      });

      test('serializes to JSON with minimal fields', () {
        final space = Space(id: 'space-2', name: 'Personal', userId: 'user-2');

        final json = space.toJson();

        expect(json['id'], 'space-2');
        expect(json['name'], 'Personal');
        expect(json['user_id'], 'user-2');
        expect(json['icon'], isNull);
        expect(json['color'], isNull);
        expect(json['is_archived'], false);
      });

      test('preserves null icon in JSON', () {
        final space = Space(id: 'space-3', name: 'No Icon', userId: 'user-1');

        final json = space.toJson();

        expect(json.containsKey('icon'), isTrue);
        expect(json['icon'], isNull);
      });

      test('preserves null color in JSON', () {
        final space = Space(id: 'space-4', name: 'No Color', userId: 'user-1');

        final json = space.toJson();

        expect(json.containsKey('color'), isTrue);
        expect(json['color'], isNull);
      });
    });

    group('copyWith', () {
      test('creates copy with updated name', () {
        final original = Space(
          id: 'space-1',
          name: 'Original',
          userId: 'user-1',
        );

        final updated = original.copyWith(name: 'Updated');

        expect(updated.id, original.id);
        expect(updated.name, 'Updated');
        expect(updated.userId, original.userId);
      });

      test('creates copy with updated icon', () {
        final original = Space(id: 'space-1', name: 'Space', userId: 'user-1');

        final updated = original.copyWith(icon: '🚀');

        expect(updated.icon, '🚀');
      });

      test('creates copy with updated color', () {
        final original = Space(id: 'space-1', name: 'Space', userId: 'user-1');

        final updated = original.copyWith(color: '#00FF00');

        expect(updated.color, '#00FF00');
      });

      test('creates copy with updated userId', () {
        final original = Space(id: 'space-1', name: 'Space', userId: 'user-1');

        final updated = original.copyWith(userId: 'user-2');

        expect(updated.userId, 'user-2');
      });

      test('creates copy with updated isArchived', () {
        final original = Space(id: 'space-1', name: 'Space', userId: 'user-1');

        final updated = original.copyWith(isArchived: true);

        expect(updated.isArchived, true);
      });

      test('preserves unchanged fields', () {
        final createdAt = DateTime(2025);
        final original = Space(
          id: 'space-1',
          name: 'Original',
          userId: 'user-1',
          icon: '🏠',
          color: '#FF0000',
          createdAt: createdAt,
        );

        final updated = original.copyWith(name: 'Updated');

        expect(updated.icon, original.icon);
        expect(updated.color, original.color);
        expect(updated.isArchived, original.isArchived);
        expect(updated.createdAt, original.createdAt);
      });

      test('returns a different instance', () {
        final original = Space(id: 'space-1', name: 'Space', userId: 'user-1');

        final updated = original.copyWith(name: 'Updated');

        expect(identical(original, updated), isFalse);
      });
    });

    group('equality', () {
      test('spaces with same id are equal', () {
        final space1 = Space(id: 'space-1', name: 'Name 1', userId: 'user-1');

        final space2 = Space(id: 'space-1', name: 'Name 2', userId: 'user-2');

        expect(space1, equals(space2));
        expect(space1.hashCode, equals(space2.hashCode));
      });

      test('spaces with different id are not equal', () {
        final space1 = Space(id: 'space-1', name: 'Name', userId: 'user-1');

        final space2 = Space(id: 'space-2', name: 'Name', userId: 'user-1');

        expect(space1, isNot(equals(space2)));
      });

      test('identical instances are equal', () {
        final space = Space(id: 'space-1', name: 'Space', userId: 'user-1');

        // ignore: unrelated_type_equality_checks
        expect(space, equals(space));
        expect(space.hashCode, equals(space.hashCode));
      });
    });

    group('toString', () {
      test('returns readable string representation', () {
        final space = Space(
          id: 'space-1',
          name: 'My Space',
          userId: 'user-1',
          isArchived: true,
        );

        final string = space.toString();

        expect(string, contains('Space'));
        expect(string, contains('space-1'));
        expect(string, contains('My Space'));
        expect(string, contains('true'));
      });
    });

    group('round-trip serialization', () {
      test('survives JSON round trip with all fields', () {
        final original = Space(
          id: 'space-1',
          name: 'Test Space',
          userId: 'user-1',
          icon: '📦',
          color: '#3498db',
          isArchived: true,
          createdAt: DateTime(2025, 1, 1, 10),
          updatedAt: DateTime(2025, 1, 2, 15),
        );

        final json = original.toJson();
        final deserialized = Space.fromJson(json);

        expect(deserialized.id, original.id);
        expect(deserialized.name, original.name);
        expect(deserialized.userId, original.userId);
        expect(deserialized.icon, original.icon);
        expect(deserialized.color, original.color);
        expect(deserialized.isArchived, original.isArchived);
        expect(deserialized.createdAt, original.createdAt);
        expect(deserialized.updatedAt, original.updatedAt);
      });

      test('survives JSON round trip with minimal fields', () {
        final original = Space(
          id: 'space-2',
          name: 'Minimal',
          userId: 'user-2',
        );

        final json = original.toJson();
        final deserialized = Space.fromJson(json);

        expect(deserialized.id, original.id);
        expect(deserialized.name, original.name);
        expect(deserialized.userId, original.userId);
        expect(deserialized.icon, isNull);
        expect(deserialized.color, isNull);
        expect(deserialized.isArchived, false);
      });
    });
  });
}
