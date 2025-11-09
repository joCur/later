import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/l10n/app_localizations.dart';
import 'package:later_mobile/providers/auth_provider.dart';
import 'package:later_mobile/providers/content_provider.dart';
import 'package:later_mobile/providers/spaces_provider.dart';
import 'package:later_mobile/providers/theme_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'test_helpers.mocks.dart';

/// Creates a MaterialApp with proper theme configuration and mock providers
/// for widget tests.
///
/// This helper ensures that all design system components have access to
/// the required [TemporalFlowTheme] extension and provides mock providers
/// for AuthProvider, SpacesProvider, and ContentProvider.
///
/// Example usage:
/// ```dart
/// await tester.pumpWidget(
///   testApp(
///     MyWidget(),
///   ),
/// );
/// ```
Widget testApp(Widget child) {
  final mockAuth = MockAuthProvider();
  final mockSpaces = MockSpacesProvider();
  final mockContent = MockContentProvider();
  final mockTheme = MockThemeProvider();

  // Set up basic mock behavior - stub async methods that return Futures
  when(mockSpaces.getSpaceItemCount(any)).thenAnswer((_) async => 0);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: mockAuth),
      ChangeNotifierProvider<SpacesProvider>.value(value: mockSpaces),
      ChangeNotifierProvider<ContentProvider>.value(value: mockContent),
      ChangeNotifierProvider<ThemeProvider>.value(value: mockTheme),
    ],
    child: MaterialApp(
      theme: ThemeData.light().copyWith(
        extensions: <ThemeExtension<dynamic>>[TemporalFlowTheme.light()],
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('de'),
      ],
      home: Scaffold(body: child),
    ),
  );
}

/// Creates a MaterialApp with dark theme configuration and mock providers
/// for widget tests.
///
/// This helper ensures that all design system components have access to
/// the required [TemporalFlowTheme] extension in dark mode and provides
/// mock providers for AuthProvider, SpacesProvider, and ContentProvider.
///
/// Example usage:
/// ```dart
/// await tester.pumpWidget(
///   testAppDark(
///     MyWidget(),
///   ),
/// );
/// ```
Widget testAppDark(Widget child) {
  final mockAuth = MockAuthProvider();
  final mockSpaces = MockSpacesProvider();
  final mockContent = MockContentProvider();
  final mockTheme = MockThemeProvider();

  // Set up basic mock behavior - stub async methods that return Futures
  when(mockSpaces.getSpaceItemCount(any)).thenAnswer((_) async => 0);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: mockAuth),
      ChangeNotifierProvider<SpacesProvider>.value(value: mockSpaces),
      ChangeNotifierProvider<ContentProvider>.value(value: mockContent),
      ChangeNotifierProvider<ThemeProvider>.value(value: mockTheme),
    ],
    child: MaterialApp(
      theme: ThemeData.dark().copyWith(
        extensions: <ThemeExtension<dynamic>>[TemporalFlowTheme.dark()],
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('de'),
      ],
      home: Scaffold(body: child),
    ),
  );
}
