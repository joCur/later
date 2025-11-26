import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'core/config/supabase_config.dart';
import 'core/error/error_handler.dart';
import 'core/theme/app_theme.dart';
import 'data/local/preferences_service.dart';
import 'features/theme/presentation/controllers/theme_controller.dart';
import 'core/routing/app_router.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize global error handler
  ErrorHandler.initialize();

  // Initialize preferences service for app settings
  await PreferencesService.initialize();

  // Load environment variables
  try {
    await dotenv.load();
  } catch (e) {
    // Continue without .env - will fail gracefully when trying to use Supabase
    debugPrint('Warning: .env file not found. Authentication will be unavailable.');
  }

  // Initialize Supabase
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Warning: Supabase initialization failed: $e');
  }

  runApp(const LaterApp());
}

class LaterApp extends StatefulWidget {
  const LaterApp({super.key});

  @override
  State<LaterApp> createState() => _LaterAppState();
}

class _LaterAppState extends State<LaterApp> {
  @override
  Widget build(BuildContext context) {
    // Wrap with ProviderScope for Riverpod 3.0
    return const ProviderScope(
      child: _MyApp(),
    );
  }
}

/// Internal MaterialApp widget using Riverpod theme controller
///
/// Migrated from Provider to Riverpod 3.0 for theme management.
/// Uses ConsumerWidget to watch themeControllerProvider.
class _MyApp extends ConsumerWidget {
  const _MyApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch Riverpod theme controller instead of Provider
    final themeMode = ref.watch(themeControllerProvider);
    // Watch router provider for go_router-based navigation
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: 'Later',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      // Add theme animation for smooth transitions
      themeAnimationDuration: const Duration(milliseconds: 250),
      themeAnimationCurve: Curves.easeInOut,
      // Localization support
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
    );
  }
}
