// Route path constants for the application
//
// All routes are defined as constants for type safety and consistency.
// This file serves as the single source of truth for route paths.
//
// Route Structure:
// - `/` - Home screen (authenticated)
// - `/auth/*` - Authentication routes (unauthenticated)
// - `/*/:id` - Content detail routes with ID path parameters (authenticated)
// - `/search` - Search screen (authenticated)
//
// Usage:
// ```dart
// // Static routes
// context.push(kRouteHome);
// context.push(kRouteSearch);
//
// // Dynamic routes with IDs
// context.push('/notes/${note.id}');
// context.push(buildNoteDetailRoute(note.id)); // Using helper
// ```
//
// Adding New Routes:
// 1. Add constant here with descriptive name (e.g., kRouteMyFeature)
// 2. Add GoRoute definition in app_router.dart
// 3. Use context.push() or context.go() for navigation
//
// Detail Screen Pattern:
// Detail routes use `:id` path parameters. Screens receive the ID and fetch
// full data via Riverpod providers (not passed as route state).

// Home route
const String kRouteHome = '/';

// Authentication routes
const String kRouteSignIn = '/auth/sign-in';
const String kRouteSignUp = '/auth/sign-up';
const String kRouteAccountUpgrade = '/auth/account-upgrade';

// Content detail routes (with :id path parameters)
const String kRouteNoteDetail = '/notes/:id';
const String kRouteNoteDetailPath = '/notes'; // Base path for building routes

const String kRouteTodoListDetail = '/todos/:id';
const String kRouteTodoListDetailPath = '/todos'; // Base path for building routes

const String kRouteListDetail = '/lists/:id';
const String kRouteListDetailPath = '/lists'; // Base path for building routes

// Search route
const String kRouteSearch = '/search';

/// Helper function to build note detail route with ID
///
/// Usage: `context.push(buildNoteDetailRoute(note.id))`
String buildNoteDetailRoute(String noteId) => '/notes/$noteId';

/// Helper function to build todo list detail route with ID
///
/// Usage: `context.push(buildTodoListDetailRoute(todoList.id))`
String buildTodoListDetailRoute(String todoListId) => '/todos/$todoListId';

/// Helper function to build list detail route with ID
///
/// Usage: `context.push(buildListDetailRoute(list.id))`
String buildListDetailRoute(String listId) => '/lists/$listId';
