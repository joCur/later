import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/local/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PreferencesService Tests', () {
    setUp(() async {
      // Clear any existing preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      // Clean up after each test
      PreferencesService().reset();
      SharedPreferences.setMockInitialValues({});
    });

    group('Singleton Pattern', () {
      test('should return the same instance when accessed multiple times', () {
        // Act
        final instance1 = PreferencesService();
        final instance2 = PreferencesService();

        // Assert
        expect(identical(instance1, instance2), isTrue);
        expect(instance1, equals(instance2));
      });

      test('should maintain state across multiple instance accesses', () async {
        // Arrange
        await PreferencesService.initialize();
        final instance1 = PreferencesService();
        await instance1.setLastSelectedSpaceId('space-123');

        // Act
        final instance2 = PreferencesService();
        final result = instance2.getLastSelectedSpaceId();

        // Assert
        expect(result, equals('space-123'));
      });
    });

    group('initialize', () {
      test('should successfully initialize SharedPreferences', () async {
        // Act & Assert - should not throw
        await expectLater(PreferencesService.initialize(), completes);
      });

      test('should be callable multiple times without error', () async {
        // Act & Assert - should not throw
        await PreferencesService.initialize();
        await expectLater(PreferencesService.initialize(), completes);
      });

      test('should load SharedPreferences instance that can be used', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();

        // Act - Should not throw after initialization
        await service.setLastSelectedSpaceId('test-space');
        final result = service.getLastSelectedSpaceId();

        // Assert
        expect(result, equals('test-space'));
      });
    });

    group('getLastSelectedSpaceId', () {
      test('should return null when no space ID has been set', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();

        // Act
        final result = service.getLastSelectedSpaceId();

        // Assert
        expect(result, isNull);
      });

      test('should return null when preferences are empty', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        await PreferencesService.initialize();
        final service = PreferencesService();

        // Act
        final result = service.getLastSelectedSpaceId();

        // Assert
        expect(result, isNull);
      });

      test('should return the stored space ID when it exists', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'last_selected_space_id': 'space-abc-123',
        });
        await PreferencesService.initialize();
        final service = PreferencesService();

        // Act
        final result = service.getLastSelectedSpaceId();

        // Assert
        expect(result, equals('space-abc-123'));
      });

      test('should return the most recently set space ID', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();
        await service.setLastSelectedSpaceId('space-first');
        await service.setLastSelectedSpaceId('space-second');
        await service.setLastSelectedSpaceId('space-third');

        // Act
        final result = service.getLastSelectedSpaceId();

        // Assert
        expect(result, equals('space-third'));
      });

      test('should return null after space ID has been cleared', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();
        await service.setLastSelectedSpaceId('space-123');
        await service.clearLastSelectedSpaceId();

        // Act
        final result = service.getLastSelectedSpaceId();

        // Assert
        expect(result, isNull);
      });
    });

    group('setLastSelectedSpaceId', () {
      test('should successfully save a space ID', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();

        // Act
        await service.setLastSelectedSpaceId('space-xyz-789');

        // Assert
        final result = service.getLastSelectedSpaceId();
        expect(result, equals('space-xyz-789'));
      });

      test('should overwrite existing space ID with new value', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();
        await service.setLastSelectedSpaceId('space-old');

        // Act
        await service.setLastSelectedSpaceId('space-new');

        // Assert
        final result = service.getLastSelectedSpaceId();
        expect(result, equals('space-new'));
        expect(result, isNot(equals('space-old')));
      });

      test('should persist value across service instance accesses', () async {
        // Arrange
        await PreferencesService.initialize();
        final service1 = PreferencesService();
        await service1.setLastSelectedSpaceId('space-persistent');

        // Act
        final service2 = PreferencesService();
        final result = service2.getLastSelectedSpaceId();

        // Assert
        expect(result, equals('space-persistent'));
      });

      test('should handle setting empty string space ID', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();

        // Act
        await service.setLastSelectedSpaceId('');

        // Assert
        final result = service.getLastSelectedSpaceId();
        expect(result, equals(''));
      });

      test('should handle setting very long space ID', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();
        final longSpaceId = 'space-${'x' * 1000}';

        // Act
        await service.setLastSelectedSpaceId(longSpaceId);

        // Assert
        final result = service.getLastSelectedSpaceId();
        expect(result, equals(longSpaceId));
        expect(result!.length, equals(1006)); // 'space-' + 1000 x's
      });

      test('should handle special characters in space ID', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();
        const spaceIdWithSpecialChars = 'space-123-abc_def@test.com';

        // Act
        await service.setLastSelectedSpaceId(spaceIdWithSpecialChars);

        // Assert
        final result = service.getLastSelectedSpaceId();
        expect(result, equals(spaceIdWithSpecialChars));
      });

      test('should complete successfully without throwing', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();

        // Act & Assert
        await expectLater(
          service.setLastSelectedSpaceId('space-123'),
          completes,
        );
      });

      test('should allow rapid successive updates', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();

        // Act
        await service.setLastSelectedSpaceId('space-1');
        await service.setLastSelectedSpaceId('space-2');
        await service.setLastSelectedSpaceId('space-3');
        await service.setLastSelectedSpaceId('space-4');
        await service.setLastSelectedSpaceId('space-5');

        // Assert
        final result = service.getLastSelectedSpaceId();
        expect(result, equals('space-5'));
      });
    });

    group('clearLastSelectedSpaceId', () {
      test('should successfully remove stored space ID', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();
        await service.setLastSelectedSpaceId('space-to-clear');

        // Act
        await service.clearLastSelectedSpaceId();

        // Assert
        final result = service.getLastSelectedSpaceId();
        expect(result, isNull);
      });

      test('should handle clearing when no space ID is set', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();

        // Act & Assert - should not throw
        await expectLater(service.clearLastSelectedSpaceId(), completes);

        final result = service.getLastSelectedSpaceId();
        expect(result, isNull);
      });

      test('should allow setting new space ID after clearing', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();
        await service.setLastSelectedSpaceId('space-initial');
        await service.clearLastSelectedSpaceId();

        // Act
        await service.setLastSelectedSpaceId('space-new');

        // Assert
        final result = service.getLastSelectedSpaceId();
        expect(result, equals('space-new'));
      });

      test('should complete successfully without throwing', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();
        await service.setLastSelectedSpaceId('space-123');

        // Act & Assert
        await expectLater(service.clearLastSelectedSpaceId(), completes);
      });

      test('should be idempotent - multiple clears should not throw', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();
        await service.setLastSelectedSpaceId('space-123');

        // Act & Assert
        await service.clearLastSelectedSpaceId();
        await expectLater(service.clearLastSelectedSpaceId(), completes);
        await expectLater(service.clearLastSelectedSpaceId(), completes);

        final result = service.getLastSelectedSpaceId();
        expect(result, isNull);
      });

      test('should persist cleared state across instance accesses', () async {
        // Arrange
        await PreferencesService.initialize();
        final service1 = PreferencesService();
        await service1.setLastSelectedSpaceId('space-123');
        await service1.clearLastSelectedSpaceId();

        // Act
        final service2 = PreferencesService();
        final result = service2.getLastSelectedSpaceId();

        // Assert
        expect(result, isNull);
      });
    });

    group('Error Handling', () {
      test(
        'should throw error when getLastSelectedSpaceId is called before initialization',
        () {
          // Arrange - Create service without initializing
          final service = PreferencesService();

          // Act & Assert
          expect(
            () => service.getLastSelectedSpaceId(),
            throwsA(isA<StateError>()),
          );
        },
      );

      test(
        'should throw error when setLastSelectedSpaceId is called before initialization',
        () async {
          // Arrange - Create service without initializing
          final service = PreferencesService();

          // Act & Assert
          await expectLater(
            service.setLastSelectedSpaceId('space-123'),
            throwsA(isA<StateError>()),
          );
        },
      );

      test(
        'should throw error when clearLastSelectedSpaceId is called before initialization',
        () async {
          // Arrange - Create service without initializing
          final service = PreferencesService();

          // Act & Assert
          await expectLater(
            service.clearLastSelectedSpaceId(),
            throwsA(isA<StateError>()),
          );
        },
      );

      test(
        'should handle initialization after failed operations gracefully',
        () async {
          // Arrange
          final service = PreferencesService();

          // Act - Try to use service before initialization (will fail)
          try {
            service.getLastSelectedSpaceId();
          } catch (e) {
            // Expected to fail
          }

          // Now initialize properly
          await PreferencesService.initialize();

          // Assert - Should work after initialization
          await service.setLastSelectedSpaceId('space-recovery');
          final result = service.getLastSelectedSpaceId();
          expect(result, equals('space-recovery'));
        },
      );
    });

    group('Integration Tests', () {
      test(
        'should handle complete workflow: set, get, update, clear',
        () async {
          // Arrange
          await PreferencesService.initialize();
          final service = PreferencesService();

          // Act & Assert - Set initial value
          await service.setLastSelectedSpaceId('space-initial');
          expect(service.getLastSelectedSpaceId(), equals('space-initial'));

          // Act & Assert - Update value
          await service.setLastSelectedSpaceId('space-updated');
          expect(service.getLastSelectedSpaceId(), equals('space-updated'));

          // Act & Assert - Clear value
          await service.clearLastSelectedSpaceId();
          expect(service.getLastSelectedSpaceId(), isNull);

          // Act & Assert - Set again after clearing
          await service.setLastSelectedSpaceId('space-final');
          expect(service.getLastSelectedSpaceId(), equals('space-final'));
        },
      );

      test(
        'should handle multiple services working with same underlying storage',
        () async {
          // Arrange
          await PreferencesService.initialize();
          final service1 = PreferencesService();
          final service2 = PreferencesService();
          final service3 = PreferencesService();

          // Act
          await service1.setLastSelectedSpaceId('space-from-service1');

          // Assert
          expect(
            service1.getLastSelectedSpaceId(),
            equals('space-from-service1'),
          );
          expect(
            service2.getLastSelectedSpaceId(),
            equals('space-from-service1'),
          );
          expect(
            service3.getLastSelectedSpaceId(),
            equals('space-from-service1'),
          );

          // Act
          await service2.setLastSelectedSpaceId('space-from-service2');

          // Assert
          expect(
            service1.getLastSelectedSpaceId(),
            equals('space-from-service2'),
          );
          expect(
            service2.getLastSelectedSpaceId(),
            equals('space-from-service2'),
          );
          expect(
            service3.getLastSelectedSpaceId(),
            equals('space-from-service2'),
          );

          // Act
          await service3.clearLastSelectedSpaceId();

          // Assert
          expect(service1.getLastSelectedSpaceId(), isNull);
          expect(service2.getLastSelectedSpaceId(), isNull);
          expect(service3.getLastSelectedSpaceId(), isNull);
        },
      );

      test('should handle alternating set and clear operations', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();

        // Act & Assert
        await service.setLastSelectedSpaceId('space-1');
        expect(service.getLastSelectedSpaceId(), equals('space-1'));

        await service.clearLastSelectedSpaceId();
        expect(service.getLastSelectedSpaceId(), isNull);

        await service.setLastSelectedSpaceId('space-2');
        expect(service.getLastSelectedSpaceId(), equals('space-2'));

        await service.clearLastSelectedSpaceId();
        expect(service.getLastSelectedSpaceId(), isNull);

        await service.setLastSelectedSpaceId('space-3');
        expect(service.getLastSelectedSpaceId(), equals('space-3'));
      });
    });

    group('Edge Cases', () {
      test('should handle space IDs with Unicode characters', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();
        const unicodeSpaceId = 'space-日本語-emoji-🚀-test';

        // Act
        await service.setLastSelectedSpaceId(unicodeSpaceId);

        // Assert
        final result = service.getLastSelectedSpaceId();
        expect(result, equals(unicodeSpaceId));
      });

      test('should handle space IDs with newlines and tabs', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();
        const spaceIdWithWhitespace = 'space-with\nnewline\tand\ttabs';

        // Act
        await service.setLastSelectedSpaceId(spaceIdWithWhitespace);

        // Assert
        final result = service.getLastSelectedSpaceId();
        expect(result, equals(spaceIdWithWhitespace));
      });

      test('should handle UUID-format space IDs', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();
        const uuidSpaceId = '550e8400-e29b-41d4-a716-446655440000';

        // Act
        await service.setLastSelectedSpaceId(uuidSpaceId);

        // Assert
        final result = service.getLastSelectedSpaceId();
        expect(result, equals(uuidSpaceId));
      });

      test('should handle numeric-only space IDs', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();
        const numericSpaceId = '1234567890';

        // Act
        await service.setLastSelectedSpaceId(numericSpaceId);

        // Assert
        final result = service.getLastSelectedSpaceId();
        expect(result, equals(numericSpaceId));
      });
    });

    group('Performance Tests', () {
      test(
        'should handle multiple rapid operations without degradation',
        () async {
          // Arrange
          await PreferencesService.initialize();
          final service = PreferencesService();

          // Act - Perform 100 operations
          for (int i = 0; i < 100; i++) {
            await service.setLastSelectedSpaceId('space-$i');
            final result = service.getLastSelectedSpaceId();
            expect(result, equals('space-$i'));
          }

          // Assert - Final value should be correct
          final finalResult = service.getLastSelectedSpaceId();
          expect(finalResult, equals('space-99'));
        },
      );

      test('should complete operations within reasonable time', () async {
        // Arrange
        await PreferencesService.initialize();
        final service = PreferencesService();
        final stopwatch = Stopwatch()..start();

        // Act - Perform operations
        await service.setLastSelectedSpaceId('space-timing-test');
        service.getLastSelectedSpaceId();
        await service.clearLastSelectedSpaceId();

        stopwatch.stop();

        // Assert - Should complete in less than 1 second
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
}
