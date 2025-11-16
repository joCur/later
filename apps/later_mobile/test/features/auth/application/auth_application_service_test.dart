import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/error/error.dart';
import 'package:later_mobile/features/auth/application/auth_application_service.dart';
import 'package:later_mobile/features/auth/data/services/auth_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@GenerateMocks([AuthService, User, Session])
import 'auth_application_service_test.mocks.dart';

void main() {
  group('AuthApplicationService', () {
    late MockAuthService mockAuthService;
    late AuthApplicationService service;
    late MockUser mockUser;

    setUp(() {
      mockAuthService = MockAuthService();
      service = AuthApplicationService(authService: mockAuthService);
      mockUser = MockUser();

      // Set up basic user properties
      when(mockUser.id).thenReturn('user-1');
      when(mockUser.email).thenReturn('test@example.com');
    });

    group('signUp', () {
      test('should sign up with valid email and password', () async {
        // Arrange
        when(mockAuthService.signUpWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => mockUser);

        // Act
        final result = await service.signUp(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(result, mockUser);
        verify(mockAuthService.signUpWithEmail(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });

      test('should throw ValidationError when email is empty', () async {
        // Act & Assert
        expect(
          () => service.signUp(
            email: '',
            password: 'password123',
          ),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify service was never called
        verifyNever(mockAuthService.signUpWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ));
      });

      test('should throw ValidationError when email is only whitespace',
          () async {
        // Act & Assert
        expect(
          () => service.signUp(
            email: '   ',
            password: 'password123',
          ),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify service was never called
        verifyNever(mockAuthService.signUpWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ));
      });

      test('should throw ValidationError when email format is invalid',
          () async {
        // Act & Assert
        expect(
          () => service.signUp(
            email: 'invalid-email',
            password: 'password123',
          ),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationInvalidFormat),
          ),
        );

        // Verify service was never called
        verifyNever(mockAuthService.signUpWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ));
      });

      test('should throw ValidationError when password is empty', () async {
        // Act & Assert
        expect(
          () => service.signUp(
            email: 'test@example.com',
            password: '',
          ),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify service was never called
        verifyNever(mockAuthService.signUpWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ));
      });

      test('should throw AppError when password is too weak (<6 chars)',
          () async {
        // Act & Assert
        expect(
          () => service.signUp(
            email: 'test@example.com',
            password: '12345',
          ),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.authWeakPassword),
          ),
        );

        // Verify service was never called
        verifyNever(mockAuthService.signUpWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ));
      });

      test('should trim email whitespace before calling service', () async {
        // Arrange
        when(mockAuthService.signUpWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => mockUser);

        // Act
        await service.signUp(
          email: '  test@example.com  ',
          password: 'password123',
        );

        // Assert - verify trimmed email was passed
        verify(mockAuthService.signUpWithEmail(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });

      test('should propagate AppError from AuthService', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.authUserAlreadyExists,
          message: 'User already exists',
        );
        when(mockAuthService.signUpWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.signUp(
            email: 'test@example.com',
            password: 'password123',
          ),
          throwsA(expectedError),
        );
      });
    });

    group('signIn', () {
      test('should sign in with valid email and password', () async {
        // Arrange
        when(mockAuthService.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => mockUser);

        // Act
        final result = await service.signIn(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(result, mockUser);
        verify(mockAuthService.signInWithEmail(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });

      test('should throw ValidationError when email is empty', () async {
        // Act & Assert
        expect(
          () => service.signIn(
            email: '',
            password: 'password123',
          ),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify service was never called
        verifyNever(mockAuthService.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ));
      });

      test('should throw ValidationError when email is only whitespace',
          () async {
        // Act & Assert
        expect(
          () => service.signIn(
            email: '   ',
            password: 'password123',
          ),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify service was never called
        verifyNever(mockAuthService.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ));
      });

      test('should throw ValidationError when password is empty', () async {
        // Act & Assert
        expect(
          () => service.signIn(
            email: 'test@example.com',
            password: '',
          ),
          throwsA(
            isA<AppError>()
                .having((e) => e.code, 'code', ErrorCode.validationRequired),
          ),
        );

        // Verify service was never called
        verifyNever(mockAuthService.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ));
      });

      test('should trim email whitespace before calling service', () async {
        // Arrange
        when(mockAuthService.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => mockUser);

        // Act
        await service.signIn(
          email: '  test@example.com  ',
          password: 'password123',
        );

        // Assert - verify trimmed email was passed
        verify(mockAuthService.signInWithEmail(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });

      test('should propagate AppError from AuthService', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.authInvalidCredentials,
          message: 'Invalid credentials',
        );
        when(mockAuthService.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.signIn(
            email: 'test@example.com',
            password: 'password123',
          ),
          throwsA(expectedError),
        );
      });
    });

    group('signOut', () {
      test('should sign out successfully', () async {
        // Arrange
        when(mockAuthService.signOut()).thenAnswer((_) async => {});

        // Act
        await service.signOut();

        // Assert
        verify(mockAuthService.signOut()).called(1);
      });

      test('should propagate AppError from AuthService', () async {
        // Arrange
        const expectedError = AppError(
          code: ErrorCode.authGeneric,
          message: 'Sign out failed',
        );
        when(mockAuthService.signOut()).thenThrow(expectedError);

        // Act & Assert
        expect(
          () => service.signOut(),
          throwsA(expectedError),
        );
      });
    });

    group('checkAuthStatus', () {
      test('should return current user when authenticated', () {
        // Arrange
        when(mockAuthService.getCurrentUser()).thenReturn(mockUser);

        // Act
        final result = service.checkAuthStatus();

        // Assert
        expect(result, mockUser);
        verify(mockAuthService.getCurrentUser()).called(1);
      });

      test('should return null when not authenticated', () {
        // Arrange
        when(mockAuthService.getCurrentUser()).thenReturn(null);

        // Act
        final result = service.checkAuthStatus();

        // Assert
        expect(result, isNull);
        verify(mockAuthService.getCurrentUser()).called(1);
      });
    });

    group('authStateChanges', () {
      test('should return auth state changes stream', () {
        // Arrange
        final mockSession = MockSession();
        when(mockSession.user).thenReturn(mockUser);
        final authStateStream = Stream<AuthState>.value(
          AuthState(AuthChangeEvent.signedIn, mockSession),
        );
        when(mockAuthService.authStateChanges()).thenAnswer(
          (_) => authStateStream,
        );

        // Act
        final result = service.authStateChanges();

        // Assert
        expect(result, authStateStream);
        verify(mockAuthService.authStateChanges()).called(1);
      });

      test('should emit auth state when user signs in', () async {
        // Arrange
        final mockSession = MockSession();
        when(mockSession.user).thenReturn(mockUser);
        final authStateStream = Stream<AuthState>.value(
          AuthState(AuthChangeEvent.signedIn, mockSession),
        );
        when(mockAuthService.authStateChanges()).thenAnswer(
          (_) => authStateStream,
        );

        // Act
        final result = service.authStateChanges();
        final authState = await result.first;

        // Assert
        expect(authState.event, AuthChangeEvent.signedIn);
        expect(authState.session?.user, mockUser);
      });

      test('should emit auth state when user signs out', () async {
        // Arrange
        final authStateStream = Stream<AuthState>.value(
          const AuthState(AuthChangeEvent.signedOut, null),
        );
        when(mockAuthService.authStateChanges()).thenAnswer(
          (_) => authStateStream,
        );

        // Act
        final result = service.authStateChanges();
        final authState = await result.first;

        // Assert
        expect(authState.event, AuthChangeEvent.signedOut);
        expect(authState.session, isNull);
      });
    });
  });
}
