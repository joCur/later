import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/error/error.dart';
import 'package:later_mobile/features/auth/application/auth_application_service.dart';
import 'package:later_mobile/features/auth/application/providers.dart';
import 'package:later_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@GenerateMocks([AuthApplicationService, User, Session])
import 'auth_state_controller_test.mocks.dart';

void main() {
  group('AuthStateController', () {
    late MockAuthApplicationService mockService;
    late MockUser mockUser;
    late MockSession mockSession;

    setUp(() {
      mockService = MockAuthApplicationService();
      mockUser = MockUser();
      mockSession = MockSession();

      // Set up basic user and session properties
      when(mockUser.id).thenReturn('user-1');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockSession.user).thenReturn(mockUser);
    });

    test('should initialize with current user when authenticated', () async {
      // Arrange
      when(mockService.checkAuthStatus()).thenReturn(mockUser);
      when(mockService.authStateChanges()).thenAnswer(
        (_) => Stream<AuthState>.value(
          AuthState(AuthChangeEvent.signedIn, mockSession),
        ),
      );

      // Create container with overrides using Riverpod 3.0 test API
      final container = ProviderContainer(
        overrides: [
          authApplicationServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      // Act
      final state = await container.read(authStateControllerProvider.future);

      // Assert
      expect(state, mockUser);
      verify(mockService.checkAuthStatus()).called(1);
    });

    test('should initialize with null when not authenticated', () async {
      // Arrange
      when(mockService.checkAuthStatus()).thenReturn(null);
      when(mockService.authStateChanges()).thenAnswer(
        (_) => Stream<AuthState>.value(
          const AuthState(AuthChangeEvent.signedOut, null),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          authApplicationServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      // Act
      final state = await container.read(authStateControllerProvider.future);

      // Assert
      expect(state, isNull);
      verify(mockService.checkAuthStatus()).called(1);
    });

    test('should update state to loading then data on successful sign up',
        () async {
      // Arrange
      when(mockService.checkAuthStatus()).thenReturn(null);
      when(mockService.authStateChanges()).thenAnswer(
        (_) => Stream<AuthState>.value(
          const AuthState(AuthChangeEvent.signedOut, null),
        ),
      );
      when(mockService.signUp(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUser);

      final container = ProviderContainer(
        overrides: [
          authApplicationServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      // Wait for initial state
      await container.read(authStateControllerProvider.future);

      // Act
      final controller = container.read(authStateControllerProvider.notifier);
      final future = controller.signUp(
        email: 'test@example.com',
        password: 'password123',
      );

      // Verify loading state (Riverpod 3.0 preserves previous value in loading state)
      expect(
        container.read(authStateControllerProvider).isLoading,
        true,
      );

      // Wait for completion
      await future;

      // Assert - final state should have user
      final finalState = container.read(authStateControllerProvider);
      expect(finalState.hasValue, true);
      expect(finalState.value, mockUser);
      expect(finalState.hasError, false);
    });

    test('should update state to loading then error on failed sign up',
        () async {
      // Arrange
      const expectedError = AppError(
        code: ErrorCode.authUserAlreadyExists,
        message: 'User already exists',
      );
      when(mockService.checkAuthStatus()).thenReturn(null);
      when(mockService.authStateChanges()).thenAnswer(
        (_) => Stream<AuthState>.value(
          const AuthState(AuthChangeEvent.signedOut, null),
        ),
      );
      when(mockService.signUp(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(expectedError);

      final container = ProviderContainer(
        overrides: [
          authApplicationServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      // Wait for initial state
      await container.read(authStateControllerProvider.future);

      // Act
      final controller = container.read(authStateControllerProvider.notifier);
      await controller.signUp(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      final finalState = container.read(authStateControllerProvider);
      expect(finalState.hasError, true);
      expect(finalState.error, expectedError);
      // In Riverpod 3.0, error state can still have a value (previous value)
      // We just check that error is present
    });

    test('should update state to loading then data on successful sign in',
        () async {
      // Arrange
      when(mockService.checkAuthStatus()).thenReturn(null);
      when(mockService.authStateChanges()).thenAnswer(
        (_) => Stream<AuthState>.value(
          const AuthState(AuthChangeEvent.signedOut, null),
        ),
      );
      when(mockService.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUser);

      final container = ProviderContainer(
        overrides: [
          authApplicationServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      // Wait for initial state
      await container.read(authStateControllerProvider.future);

      // Act
      final controller = container.read(authStateControllerProvider.notifier);
      final future = controller.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      // Verify loading state (Riverpod 3.0 preserves previous value in loading state)
      expect(
        container.read(authStateControllerProvider).isLoading,
        true,
      );

      // Wait for completion
      await future;

      // Assert - final state should have user
      final finalState = container.read(authStateControllerProvider);
      expect(finalState.hasValue, true);
      expect(finalState.value, mockUser);
      expect(finalState.hasError, false);
    });

    test('should update state to loading then error on failed sign in',
        () async {
      // Arrange
      const expectedError = AppError(
        code: ErrorCode.authInvalidCredentials,
        message: 'Invalid credentials',
      );
      when(mockService.checkAuthStatus()).thenReturn(null);
      when(mockService.authStateChanges()).thenAnswer(
        (_) => Stream<AuthState>.value(
          const AuthState(AuthChangeEvent.signedOut, null),
        ),
      );
      when(mockService.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(expectedError);

      final container = ProviderContainer(
        overrides: [
          authApplicationServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      // Wait for initial state
      await container.read(authStateControllerProvider.future);

      // Act
      final controller = container.read(authStateControllerProvider.notifier);
      await controller.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      final finalState = container.read(authStateControllerProvider);
      expect(finalState.hasError, true);
      expect(finalState.error, expectedError);
      // In Riverpod 3.0, error state can still have a value (previous value)
      // We just check that error is present
    });

    test('should update state to loading then data(null) on successful sign out',
        () async {
      // Arrange
      when(mockService.checkAuthStatus()).thenReturn(mockUser);
      when(mockService.authStateChanges()).thenAnswer(
        (_) => Stream<AuthState>.value(
          AuthState(AuthChangeEvent.signedIn, mockSession),
        ),
      );
      when(mockService.signOut()).thenAnswer((_) async => {});

      final container = ProviderContainer(
        overrides: [
          authApplicationServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      // Wait for initial state (authenticated)
      await container.read(authStateControllerProvider.future);

      // Act
      final controller = container.read(authStateControllerProvider.notifier);
      final future = controller.signOut();

      // Verify loading state (Riverpod 3.0 preserves previous value in loading state)
      expect(
        container.read(authStateControllerProvider).isLoading,
        true,
      );

      // Wait for completion
      await future;

      // Assert - final state should be null (unauthenticated)
      final finalState = container.read(authStateControllerProvider);
      expect(finalState.hasValue, true);
      expect(finalState.value, isNull);
      expect(finalState.hasError, false);
    });

    test('should update state to loading then error on failed sign out',
        () async {
      // Arrange
      const expectedError = AppError(
        code: ErrorCode.authGeneric,
        message: 'Sign out failed',
      );
      when(mockService.checkAuthStatus()).thenReturn(mockUser);
      when(mockService.authStateChanges()).thenAnswer(
        (_) => Stream<AuthState>.value(
          AuthState(AuthChangeEvent.signedIn, mockSession),
        ),
      );
      when(mockService.signOut()).thenThrow(expectedError);

      final container = ProviderContainer(
        overrides: [
          authApplicationServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      // Wait for initial state (authenticated)
      await container.read(authStateControllerProvider.future);

      // Act
      final controller = container.read(authStateControllerProvider.notifier);
      await controller.signOut();

      // Assert
      final finalState = container.read(authStateControllerProvider);
      expect(finalState.hasError, true);
      expect(finalState.error, expectedError);
      // In Riverpod 3.0, error state can still have a value (previous value)
      // We just check that error is present
    });

    test('should refresh auth state on initialize', () async {
      // Arrange
      when(mockService.checkAuthStatus()).thenReturn(null);
      when(mockService.authStateChanges()).thenAnswer(
        (_) => Stream<AuthState>.value(
          const AuthState(AuthChangeEvent.signedOut, null),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          authApplicationServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      // Wait for initial state
      await container.read(authStateControllerProvider.future);

      // Change the mock to return a user
      when(mockService.checkAuthStatus()).thenReturn(mockUser);

      // Act
      final controller = container.read(authStateControllerProvider.notifier);
      await controller.initialize();

      // Assert
      final finalState = container.read(authStateControllerProvider);
      expect(finalState.hasValue, true);
      expect(finalState.value, mockUser);
      verify(mockService.checkAuthStatus()).called(2); // Initial + initialize
    });

    // Note: Testing auth state stream updates is complex in unit tests
    // because the controller's stream subscription runs asynchronously.
    // This behavior is verified through the other controller tests
    // and through integration/widget tests.
  });
}
