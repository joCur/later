import 'package:flutter/material.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/providers/content_provider.dart';
import 'package:later_mobile/providers/spaces_provider.dart';
import 'package:provider/provider.dart';

import 'fakes/fake_repositories.dart';

/// Creates a MaterialApp with proper theme configuration and real providers
/// backed by fake repositories for integration-style widget tests.
///
/// This helper is different from [testApp] in that it uses real Provider
/// instances with fake repositories, allowing you to test the actual provider
/// logic and state management.
///
/// Example usage:
/// ```dart
/// final fakeRepos = IntegrationTestRepositories();
/// fakeRepos.spaceRepository.setSpaces([testSpace]);
///
/// await tester.pumpWidget(
///   integrationTestApp(
///     repositories: fakeRepos,
///     child: MyWidget(),
///   ),
/// );
/// ```
Widget integrationTestApp({
  required IntegrationTestRepositories repositories,
  required Widget child,
}) {
  final contentProvider = ContentProvider(
    todoListRepository: repositories.todoListRepository,
    listRepository: repositories.listRepository,
    noteRepository: repositories.noteRepository,
  );

  final spacesProvider = SpacesProvider(repositories.spaceRepository);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ContentProvider>.value(value: contentProvider),
      ChangeNotifierProvider<SpacesProvider>.value(value: spacesProvider),
    ],
    child: MaterialApp(
      theme: ThemeData.light().copyWith(
        extensions: <ThemeExtension<dynamic>>[TemporalFlowTheme.light()],
      ),
      home: Scaffold(body: child),
    ),
  );
}

/// Creates a MaterialApp with dark theme and real providers backed by fake
/// repositories for integration-style widget tests.
Widget integrationTestAppDark({
  required IntegrationTestRepositories repositories,
  required Widget child,
}) {
  final contentProvider = ContentProvider(
    todoListRepository: repositories.todoListRepository,
    listRepository: repositories.listRepository,
    noteRepository: repositories.noteRepository,
  );

  final spacesProvider = SpacesProvider(repositories.spaceRepository);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ContentProvider>.value(value: contentProvider),
      ChangeNotifierProvider<SpacesProvider>.value(value: spacesProvider),
    ],
    child: MaterialApp(
      theme: ThemeData.dark().copyWith(
        extensions: <ThemeExtension<dynamic>>[TemporalFlowTheme.dark()],
      ),
      home: Scaffold(body: child),
    ),
  );
}

/// Container for fake repositories used in integration tests.
///
/// Provides easy access to all fake repositories and allows setting test data
/// via the repository methods.
class IntegrationTestRepositories {
  IntegrationTestRepositories();

  final FakeListRepository listRepository = FakeListRepository();
  final FakeTodoListRepository todoListRepository = FakeTodoListRepository();
  final FakeNoteRepository noteRepository = FakeNoteRepository();
  final FakeSpaceRepository spaceRepository = FakeSpaceRepository();
}
