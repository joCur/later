import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/src/framework.dart' show Override;
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/l10n/app_localizations.dart';

/// Creates a MaterialApp with proper theme configuration for Riverpod tests
/// (widget tests with ProviderScope).
///
/// This helper ensures that all design system components have access to
/// the required [TemporalFlowTheme] extension.
///
/// Example usage:
/// ```dart
/// await tester.pumpWidget(
///   testApp(
///     MyWidget(),
///     overrides: [
///       spacesControllerProvider.overrideWith(() => mockController),
///     ],
///   ),
/// );
/// ```
Widget testApp(
  Widget child, {
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
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
      supportedLocales: const [Locale('en'), Locale('de')],
      home: Scaffold(body: child),
    ),
  );
}

/// Creates a MaterialApp with dark theme configuration for Riverpod tests
/// (widget tests with ProviderScope).
///
/// This helper ensures that all design system components have access to
/// the required [TemporalFlowTheme] extension in dark mode.
///
/// Example usage:
/// ```dart
/// await tester.pumpWidget(
///   testAppDark(
///     MyWidget(),
///     overrides: [
///       spacesControllerProvider.overrideWith(() => mockController),
///     ],
///   ),
/// );
/// ```
Widget testAppDark(
  Widget child, {
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
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
      supportedLocales: const [Locale('en'), Locale('de')],
      home: Scaffold(body: child),
    ),
  );
}
