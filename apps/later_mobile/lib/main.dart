import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'data/local/hive_database.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database
  await HiveDatabase.initialize();

  runApp(const LaterApp());
}

class LaterApp extends StatefulWidget {
  const LaterApp({super.key});

  @override
  State<LaterApp> createState() => _LaterAppState();
}

class _LaterAppState extends State<LaterApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Later',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: ThemeTestScreen(onToggleTheme: _toggleTheme),
    );
  }
}

/// Test screen to verify theme implementation
class ThemeTestScreen extends StatelessWidget {
  const ThemeTestScreen({
    super.key,
    required this.onToggleTheme,
  });

  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Later - Theme Test'),
        actions: [
          IconButton(
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: onToggleTheme,
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Design System Test',
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: 24),

            // Typography samples
            _buildSection(
              context,
              'Typography',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Headline Large', style: theme.textTheme.headlineLarge),
                  Text('Headline Medium', style: theme.textTheme.headlineMedium),
                  Text('Title Large', style: theme.textTheme.titleLarge),
                  Text('Body Large', style: theme.textTheme.bodyLarge),
                  Text('Body Medium', style: theme.textTheme.bodyMedium),
                  Text('Label Small', style: theme.textTheme.labelSmall),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Button samples
            _buildSection(
              context,
              'Buttons',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Elevated'),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Outlined'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Text'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Color samples
            _buildSection(
              context,
              'Colors',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _colorChip(context, 'Primary', colorScheme.primary),
                  _colorChip(context, 'Secondary', colorScheme.secondary),
                  _colorChip(context, 'Error', colorScheme.error),
                  _colorChip(context, 'Surface', colorScheme.surface),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Input field sample
            _buildSection(
              context,
              'Input Fields',
              const Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Standard Input',
                      hintText: 'Enter text here',
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Input with Error',
                      hintText: 'This has an error',
                      errorText: 'This field is required',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Card sample
            _buildSection(
              context,
              'Cards',
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sample Card',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This is a sample card demonstrating the card theme with proper spacing and typography.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Chips
            _buildSection(
              context,
              'Chips',
              const Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text('All')),
                  Chip(label: Text('Tasks')),
                  Chip(label: Text('Notes')),
                  Chip(label: Text('Lists')),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Quick Capture',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _colorChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _getContrastColor(color),
            ),
      ),
    );
  }

  Color _getContrastColor(Color color) {
    // Simple luminance check for text contrast
    final r = (color.r * 255.0).round() & 0xff;
    final g = (color.g * 255.0).round() & 0xff;
    final b = (color.b * 255.0).round() & 0xff;
    final luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
