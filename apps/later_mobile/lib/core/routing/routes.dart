/// Route path constants for the application
///
/// Defines all route paths used throughout the app. Using constants
/// ensures type safety and prevents typos in route navigation.
///
/// These routes are used with go_router for declarative navigation.

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
String buildNoteDetailRoute(String noteId) => '/notes/$noteId';

/// Helper function to build todo list detail route with ID
String buildTodoListDetailRoute(String todoListId) => '/todos/$todoListId';

/// Helper function to build list detail route with ID
String buildListDetailRoute(String listId) => '/lists/$listId';
