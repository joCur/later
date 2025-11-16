import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/local/preferences_service.dart';
import 'package:later_mobile/features/theme/application/theme_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'theme_service_test.mocks.dart';

@GenerateMocks([PreferencesService])
void main() {
  group('ThemeService', () {
    late MockPreferencesService mockPreferencesService;
    late ThemeService service;

    setUp(() {
      mockPreferencesService = MockPreferencesService();
      service = ThemeService(preferencesService: mockPreferencesService);
    });

    group('loadThemePreference', () {
      test('should return light mode when preference is "light"', () {
        // Arrange
        when(mockPreferencesService.getThemeMode()).thenReturn('light');

        // Act
        final result = service.loadThemePreference();

        // Assert
        expect(result, ThemeMode.light);
        verify(mockPreferencesService.getThemeMode()).called(1);
      });

      test('should return dark mode when preference is "dark"', () {
        // Arrange
        when(mockPreferencesService.getThemeMode()).thenReturn('dark');

        // Act
        final result = service.loadThemePreference();

        // Assert
        expect(result, ThemeMode.dark);
      });

      test('should return system mode when preference is "system"', () {
        // Arrange
        when(mockPreferencesService.getThemeMode()).thenReturn('system');

        // Act
        final result = service.loadThemePreference();

        // Assert
        expect(result, ThemeMode.system);
      });

      test('should return system mode when preference is null', () {
        // Arrange
        when(mockPreferencesService.getThemeMode()).thenReturn(null);

        // Act
        final result = service.loadThemePreference();

        // Assert
        expect(result, ThemeMode.system);
      });

      test('should return system mode for invalid preference value', () {
        // Arrange
        when(mockPreferencesService.getThemeMode()).thenReturn('invalid');

        // Act
        final result = service.loadThemePreference();

        // Assert
        expect(result, ThemeMode.system);
      });
    });

    group('saveThemePreference', () {
      test('should save "light" for ThemeMode.light', () async {
        // Arrange
        when(mockPreferencesService.setThemeMode(any))
            .thenAnswer((_) async => {});

        // Act
        await service.saveThemePreference(ThemeMode.light);

        // Assert
        verify(mockPreferencesService.setThemeMode('light')).called(1);
      });

      test('should save "dark" for ThemeMode.dark', () async {
        // Arrange
        when(mockPreferencesService.setThemeMode(any))
            .thenAnswer((_) async => {});

        // Act
        await service.saveThemePreference(ThemeMode.dark);

        // Assert
        verify(mockPreferencesService.setThemeMode('dark')).called(1);
      });

      test('should save "system" for ThemeMode.system', () async {
        // Arrange
        when(mockPreferencesService.setThemeMode(any))
            .thenAnswer((_) async => {});

        // Act
        await service.saveThemePreference(ThemeMode.system);

        // Assert
        verify(mockPreferencesService.setThemeMode('system')).called(1);
      });
    });

    group('parseThemeMode', () {
      test('should parse "light" to ThemeMode.light', () {
        expect(service.parseThemeMode('light'), ThemeMode.light);
      });

      test('should parse "dark" to ThemeMode.dark', () {
        expect(service.parseThemeMode('dark'), ThemeMode.dark);
      });

      test('should parse "system" to ThemeMode.system', () {
        expect(service.parseThemeMode('system'), ThemeMode.system);
      });

      test('should return system mode for invalid string', () {
        expect(service.parseThemeMode('invalid'), ThemeMode.system);
      });

      test('should return system mode for empty string', () {
        expect(service.parseThemeMode(''), ThemeMode.system);
      });
    });

    group('isDarkMode', () {
      test('should return true for ThemeMode.dark', () {
        expect(service.isDarkMode(ThemeMode.dark), isTrue);
      });

      test('should return false for ThemeMode.light', () {
        expect(service.isDarkMode(ThemeMode.light), isFalse);
      });

      // Note: Testing ThemeMode.system requires platform brightness mocking
      // which is complex in unit tests. This is covered in controller tests.
    });

    group('getNextThemeMode', () {
      test('should return dark mode when current is light', () {
        expect(
          service.getNextThemeMode(ThemeMode.light),
          ThemeMode.dark,
        );
      });

      test('should return light mode when current is dark', () {
        expect(
          service.getNextThemeMode(ThemeMode.dark),
          ThemeMode.light,
        );
      });

      // Note: System mode behavior depends on platform brightness
      // and is covered in integration tests
    });
  });
}
