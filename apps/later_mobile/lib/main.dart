import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/config/supabase_config.dart';
import 'core/error/error_handler.dart';
import 'core/theme/app_theme.dart';
import 'data/local/hive_database.dart';
import 'data/local/preferences_service.dart';
import 'data/local/seed_data.dart';
import 'data/repositories/list_repository.dart';
import 'data/repositories/note_repository.dart';
import 'data/repositories/space_repository.dart';
import 'data/repositories/todo_list_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/content_provider.dart';
import 'providers/spaces_provider.dart';
import 'providers/theme_provider.dart';
import 'widgets/auth/auth_gate.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize global error handler
  ErrorHandler.initialize();

  // Initialize preferences service for app settings (before Hive)
  await PreferencesService.initialize();

  // Load environment variables
  try {
    await dotenv.load();
  } catch (e) {
    // Continue without .env - will fail gracefully when trying to use Supabase
    debugPrint('Warning: .env file not found. Authentication will be unavailable.');
  }

  // Initialize Supabase (optional - graceful degradation for offline mode)
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Warning: Supabase initialization failed. Running in offline mode.');
  }

  // Initialize Hive database
  await HiveDatabase.initialize();

  // Initialize seed data for first run
  await SeedData.initialize();

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..loadThemePreference(),
        ),
        ChangeNotifierProvider(
          create: (_) => SpacesProvider(SpaceRepository())..loadSpaces(),
        ),
        ChangeNotifierProvider(
          create: (_) => ContentProvider(
            todoListRepository: TodoListRepository(),
            listRepository: ListRepository(),
            noteRepository: NoteRepository(),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Later',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            // Add theme animation for smooth transitions
            themeAnimationDuration: const Duration(milliseconds: 250),
            themeAnimationCurve: Curves.easeInOut,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
