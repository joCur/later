import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/features/auth/application/auth_application_service.dart';
import 'package:later_mobile/features/auth/application/providers.dart';
import 'package:later_mobile/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../test_helpers.dart';
import 'sign_in_screen_test.mocks.dart';

@GenerateMocks([AuthApplicationService, User, Session])
void main() {
  group('SignInScreen Widget Tests', () {
    late MockAuthApplicationService mockService;
    late MockUser mockUser;

    setUp(() {
      mockService = MockAuthApplicationService();
      mockUser = MockUser();

      // Set up basic user properties
      when(mockUser.id).thenReturn('user-1');
      when(mockUser.email).thenReturn('test@example.com');
    });

    testWidgets('should render email and password fields', (tester) async {
      // Arrange
      when(mockService.checkAuthStatus()).thenReturn(null);
      when(mockService.authStateChanges()).thenAnswer(
        (_) => Stream<AuthState>.value(
          const AuthState(AuthChangeEvent.signedOut, null),
        ),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authApplicationServiceProvider.overrideWithValue(mockService),
          ],
          child: testApp(const SignInScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - verify form fields exist
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('should render sign in button', (tester) async {
      // Arrange
      when(mockService.checkAuthStatus()).thenReturn(null);
      when(mockService.authStateChanges()).thenAnswer(
        (_) => Stream<AuthState>.value(
          const AuthState(AuthChangeEvent.signedOut, null),
        ),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authApplicationServiceProvider.overrideWithValue(mockService),
          ],
          child: testApp(const SignInScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - verify sign in button exists
      // The button text comes from localization
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    // Note: Interactive tests (loading, error states) are difficult with
    // AnimatedMeshBackground which has timers that interfere with widget tests.
    // These behaviors are tested at the controller level.

    // Note: Testing loading state is difficult with AnimatedMeshBackground
    // which has timers that interfere with widget tests.
    // The loading behavior is tested at the controller level.
  });
}
