import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/features/theme/application/providers.dart';
import 'package:later_mobile/features/theme/application/theme_service.dart';
import 'package:later_mobile/features/theme/presentation/controllers/theme_controller.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'theme_controller_test.mocks.dart';

@GenerateMocks([ThemeService])
void main() {
  group('ThemeController', () {
    late MockThemeService mockService;

    setUp(() {
      mockService = MockThemeService();
    });

    group('build (initialization)', () {
      test('should load theme preference on initialization', () {
        // Arrange
        when(mockService.loadThemePreference()).thenReturn(ThemeMode.dark);

        // Act - NEW in 3.0: Use ProviderContainer.test()
        final container = ProviderContainer.test(
          overrides: [
            themeServiceProvider.overrideWithValue(mockService),
          ],
        );
        // Automatically disposed after test

        addTearDown(container.dispose);

        final themeMode = container.read(themeControllerProvider);

        // Assert
        expect(themeMode, ThemeMode.dark);
        verify(mockService.loadThemePreference()).called(1);
      });

      test('should default to system mode if no preference exists', () {
        // Arrange
        when(mockService.loadThemePreference()).thenReturn(ThemeMode.system);

        // Act
        final container = ProviderContainer.test(
          overrides: [
            themeServiceProvider.overrideWithValue(mockService),
          ],
        );

        addTearDown(container.dispose);

        final themeMode = container.read(themeControllerProvider);

        // Assert
        expect(themeMode, ThemeMode.system);
      });
    });

    group('setThemeMode', () {
      test('should call save preference with correct mode', () async {
        // Note: State updates with animation delays are tested in widget tests
        // This test verifies the business logic (saving preference) works correctly

        // Arrange
        when(mockService.loadThemePreference()).thenReturn(ThemeMode.light);
        when(mockService.saveThemePreference(any))
            .thenAnswer((_) async => {});

        final container = ProviderContainer.test(
          overrides: [
            themeServiceProvider.overrideWithValue(mockService),
          ],
        );

        addTearDown(container.dispose);

        // Initial state
        expect(container.read(themeControllerProvider), ThemeMode.light);

        // Act
        await container
            .read(themeControllerProvider.notifier)
            .setThemeMode(ThemeMode.dark);

        // Assert - Verify service was called correctly
        verify(mockService.saveThemePreference(ThemeMode.dark)).called(1);
      });

      test('should still save preference even if mode unchanged', () async {
        // Arrange
        when(mockService.loadThemePreference()).thenReturn(ThemeMode.light);
        when(mockService.saveThemePreference(any))
            .thenAnswer((_) async => {});

        final container = ProviderContainer.test(
          overrides: [
            themeServiceProvider.overrideWithValue(mockService),
          ],
        );

        addTearDown(container.dispose);

        // Act - Set same mode
        await container
            .read(themeControllerProvider.notifier)
            .setThemeMode(ThemeMode.light);

        // Assert
        expect(container.read(themeControllerProvider), ThemeMode.light);
        verify(mockService.saveThemePreference(ThemeMode.light)).called(1);
      });

      test('should call save for all theme modes', () async {
        // Arrange
        when(mockService.loadThemePreference()).thenReturn(ThemeMode.system);
        when(mockService.saveThemePreference(any))
            .thenAnswer((_) async => {});

        final container = ProviderContainer.test(
          overrides: [
            themeServiceProvider.overrideWithValue(mockService),
          ],
        );

        addTearDown(container.dispose);

        // Act & Assert - Light
        await container
            .read(themeControllerProvider.notifier)
            .setThemeMode(ThemeMode.light);
        verify(mockService.saveThemePreference(ThemeMode.light)).called(1);

        // Act & Assert - Dark
        await container
            .read(themeControllerProvider.notifier)
            .setThemeMode(ThemeMode.dark);
        verify(mockService.saveThemePreference(ThemeMode.dark)).called(1);

        // Act & Assert - System
        await container
            .read(themeControllerProvider.notifier)
            .setThemeMode(ThemeMode.system);
        verify(mockService.saveThemePreference(ThemeMode.system)).called(1);
      });
    });

    group('toggleTheme', () {
      test('should call service to get next mode and save it', () async {
        // Arrange
        when(mockService.loadThemePreference()).thenReturn(ThemeMode.light);
        when(mockService.getNextThemeMode(any)).thenReturn(ThemeMode.dark);
        when(mockService.saveThemePreference(any))
            .thenAnswer((_) async => {});

        final container = ProviderContainer.test(
          overrides: [
            themeServiceProvider.overrideWithValue(mockService),
          ],
        );

        addTearDown(container.dispose);

        // Act
        await container.read(themeControllerProvider.notifier).toggleTheme();

        // Assert
        verify(mockService.getNextThemeMode(ThemeMode.light)).called(1);
        verify(mockService.saveThemePreference(ThemeMode.dark)).called(1);
      });

      test('should toggle in both directions', () async {
        // Arrange - Start with dark
        when(mockService.loadThemePreference()).thenReturn(ThemeMode.dark);
        when(mockService.getNextThemeMode(any)).thenReturn(ThemeMode.light);
        when(mockService.saveThemePreference(any))
            .thenAnswer((_) async => {});

        final container = ProviderContainer.test(
          overrides: [
            themeServiceProvider.overrideWithValue(mockService),
          ],
        );

        addTearDown(container.dispose);

        // Act
        await container.read(themeControllerProvider.notifier).toggleTheme();

        // Assert
        verify(mockService.getNextThemeMode(ThemeMode.dark)).called(1);
        verify(mockService.saveThemePreference(ThemeMode.light)).called(1);
      });
    });

    group('isDarkMode getter', () {
      test('should delegate to service for dark mode check', () {
        // Arrange
        when(mockService.loadThemePreference()).thenReturn(ThemeMode.dark);
        when(mockService.isDarkMode(ThemeMode.dark)).thenReturn(true);

        final container = ProviderContainer.test(
          overrides: [
            themeServiceProvider.overrideWithValue(mockService),
          ],
        );

        addTearDown(container.dispose);

        // Act
        final isDark =
            container.read(themeControllerProvider.notifier).isDarkMode;

        // Assert
        expect(isDark, isTrue);
        verify(mockService.isDarkMode(ThemeMode.dark)).called(1);
      });

      test('should delegate to service for light mode check', () {
        // Arrange
        when(mockService.loadThemePreference()).thenReturn(ThemeMode.light);
        when(mockService.isDarkMode(ThemeMode.light)).thenReturn(false);

        final container = ProviderContainer.test(
          overrides: [
            themeServiceProvider.overrideWithValue(mockService),
          ],
        );

        addTearDown(container.dispose);

        // Act
        final isDark =
            container.read(themeControllerProvider.notifier).isDarkMode;

        // Assert
        expect(isDark, isFalse);
        verify(mockService.isDarkMode(ThemeMode.light)).called(1);
      });
    });

    group('Riverpod 3.0 features', () {
      test('demonstrates ProviderContainer.test() usage', () {
        // This test demonstrates the NEW Riverpod 3.0 feature: ProviderContainer.test()
        // It automatically disposes the container after the test completes
        // No manual tearDown with container.dispose() is needed

        when(mockService.loadThemePreference()).thenReturn(ThemeMode.system);

        final container = ProviderContainer.test(
          overrides: [
            themeServiceProvider.overrideWithValue(mockService),
          ],
        );

        // Container will be automatically disposed after test
        expect(container.read(themeControllerProvider), ThemeMode.system);
      });

      test('demonstrates provider overrides pattern', () {
        // This test shows how to override providers in tests
        // This is the standard pattern for testing Riverpod controllers

        when(mockService.loadThemePreference()).thenReturn(ThemeMode.light);

        final container = ProviderContainer.test(
          overrides: [
            // Override the service provider with a mock
            themeServiceProvider.overrideWithValue(mockService),
          ],
        );

        addTearDown(container.dispose);

        // Now when the controller uses themeServiceProvider,
        // it gets our mock instead
        final mode = container.read(themeControllerProvider);
        expect(mode, ThemeMode.light);
      });
    });
  });
}
