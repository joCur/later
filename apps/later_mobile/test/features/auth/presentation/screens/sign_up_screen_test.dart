import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/features/auth/application/auth_application_service.dart';
import 'package:later_mobile/features/auth/application/providers.dart';
import 'package:later_mobile/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:later_mobile/l10n/app_localizations.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'sign_up_screen_test.mocks.dart';

@GenerateMocks([AuthApplicationService, User, Session])
void main() {
  group('SignUpScreen Widget Tests', () {
    late MockAuthApplicationService mockService;
    late MockUser mockUser;

    setUp(() {
      mockService = MockAuthApplicationService();
      mockUser = MockUser();

      // Set up basic user properties
      when(mockUser.id).thenReturn('user-1');
      when(mockUser.email).thenReturn('test@example.com');
    });

    testWidgets('should render email, password, and confirm password fields',
        (tester) async {
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
          child: MaterialApp(
            theme: ThemeData.light().copyWith(
              extensions: <ThemeExtension<dynamic>>[
                TemporalFlowTheme.light(),
              ],
            ),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('de')],
            home: const SignUpScreen(),
          ),
        ),
      );
      // Wait for async provider initialization and all animations
      await tester.pump(); // Initial build
      await tester.pump(); // Provider build complete
      await tester.pump(); // Stream subscription

      // Pump multiple frames to allow animations (with durations) to progress
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pump(); // Final frame

      // Assert - verify form fields exist (email, password, confirm password)
      expect(find.byType(TextFormField), findsNWidgets(3));
    });

    testWidgets('should render sign up button', (tester) async {
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
          child: MaterialApp(
            theme: ThemeData.light().copyWith(
              extensions: <ThemeExtension<dynamic>>[
                TemporalFlowTheme.light(),
              ],
            ),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('de')],
            home: const SignUpScreen(),
          ),
        ),
      );
      // Wait for async provider initialization and all animations
      await tester.pump(); // Initial build
      await tester.pump(); // Provider build complete
      await tester.pump(); // Stream subscription

      // Pump multiple frames to allow animations (with durations) to progress
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pump(); // Final frame

      // Assert - verify sign up button exists
      // The button text comes from localization
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    // Note: Interactive tests (loading, error states) are difficult with
    // AnimatedMeshBackground which has timers that interfere with widget tests.
    // These behaviors are tested at the controller level.

    // Note: Testing loading state and password strength indicator is difficult
    // with AnimatedMeshBackground which has timers that interfere with widget tests.
    // These behaviors are tested at the controller level and in integration tests.
  });
}
