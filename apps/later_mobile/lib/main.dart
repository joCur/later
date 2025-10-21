import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/error/error_handler.dart';
import 'core/theme/app_theme.dart';
import 'data/local/hive_database.dart';
import 'data/local/seed_data.dart';
import 'data/repositories/item_repository.dart';
import 'data/repositories/space_repository.dart';
import 'providers/items_provider.dart';
import 'providers/spaces_provider.dart';
import 'providers/theme_provider.dart';
import 'widgets/screens/home_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize global error handler
  ErrorHandler.initialize();

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
          create: (_) => ThemeProvider()..loadThemePreference(),
        ),
        ChangeNotifierProvider(
          create: (_) => SpacesProvider(SpaceRepository())..loadSpaces(),
        ),
        ChangeNotifierProvider(
          create: (_) => ItemsProvider(ItemRepository())..loadItems(),
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
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
