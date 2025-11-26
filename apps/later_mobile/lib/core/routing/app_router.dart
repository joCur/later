// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:later_mobile/core/routing/go_router_refresh_stream.dart';
import 'package:later_mobile/core/routing/routes.dart';
import 'package:later_mobile/features/auth/application/providers.dart';
import 'package:later_mobile/features/auth/presentation/screens/account_upgrade_screen.dart';
import 'package:later_mobile/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:later_mobile/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:later_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:later_mobile/features/lists/presentation/screens/list_detail_screen.dart';
import 'package:later_mobile/features/notes/presentation/screens/note_detail_screen.dart';
import 'package:later_mobile/features/search/presentation/screens/search_screen.dart';
import 'package:later_mobile/features/todo_lists/presentation/screens/todo_list_detail_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Router provider for the application
///
/// Provides a GoRouter instance with:
/// - Initial location: /auth/sign-in (before auth check completes)
/// - Unauthenticated routes: sign-in, sign-up, account-upgrade
/// - Authenticated routes: home, notes, todos, lists, search
/// - Authentication-aware redirect logic with stream-based auth state
/// - Automatic route refresh when auth state changes
/// - Error builder that falls back to SignInScreen
///
/// This is kept alive to maintain router state throughout app lifetime.
/// The router watches the auth stream and rebuilds routes when auth state changes.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  // Get auth service for stream
  final authService = ref.read(authApplicationServiceProvider);

  // Create refresh listenable from auth stream
  // Maps AuthState to User? for go_router reactivity
  final refreshListenable = GoRouterRefreshStream(
    authService.authStateChanges().map((authState) => authState.session?.user),
  );

  return GoRouter(
    initialLocation: kRouteSignIn,
    refreshListenable: refreshListenable,
    routes: [
      // Unauthenticated routes (public access)
      GoRoute(
        path: kRouteSignIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: kRouteSignUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: kRouteAccountUpgrade,
        builder: (context, state) => const AccountUpgradeScreen(),
      ),
      // Authenticated routes (protected by redirect guard)
      GoRoute(
        path: kRouteHome,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: kRouteNoteDetail,
        builder: (context, state) {
          final noteId = state.pathParameters['id']!;
          return NoteDetailScreen(noteId: noteId);
        },
      ),
      GoRoute(
        path: kRouteTodoListDetail,
        builder: (context, state) {
          final todoListId = state.pathParameters['id']!;
          return TodoListDetailScreen(todoListId: todoListId);
        },
      ),
      GoRoute(
        path: kRouteListDetail,
        builder: (context, state) {
          final listId = state.pathParameters['id']!;
          return ListDetailScreen(listId: listId);
        },
      ),
      GoRoute(
        path: kRouteSearch,
        builder: (context, state) => const SearchScreen(),
      ),
    ],
    redirect: (context, state) {
      // Authentication-aware redirect guard
      //
      // This redirect callback evaluates on every route change and when
      // the auth stream emits new values (via refreshListenable).
      //
      // Redirect Logic:
      // 1. Get current user synchronously (no waiting for stream)
      // 2. Extract user (User? = null means unauthenticated)
      // 3. Redirect unauthenticated users to sign-in (except if already on auth routes)
      // 4. Redirect authenticated users away from auth routes to home
      // 5. Return null if no redirect needed (stay on current route)

      // Get current auth state synchronously
      // We use checkAuthStatus() instead of the stream because the stream
      // only emits on *changes*, not immediately on subscription
      final user = authService.checkAuthStatus();
      final isAuthenticated = user != null;

      // Detect if current route is an auth route
      final isOnAuthRoute = state.matchedLocation.startsWith('/auth');

      if (kDebugMode) {
        print('[Router] Auth check: authenticated=$isAuthenticated, '
            'onAuthRoute=$isOnAuthRoute, location=${state.matchedLocation}');
      }

      // Redirect unauthenticated users to sign-in
      if (!isAuthenticated && !isOnAuthRoute) {
        if (kDebugMode) {
          print('[Router] Redirecting unauthenticated user to sign-in');
        }
        return kRouteSignIn;
      }

      // Redirect authenticated users away from auth routes to home
      if (isAuthenticated && isOnAuthRoute) {
        if (kDebugMode) {
          print('[Router] Redirecting authenticated user to home');
        }
        return kRouteHome;
      }

      // No redirect needed - user is on correct route for their auth state
      return null;
    },
    errorBuilder: (context, state) {
      // Fallback to sign-in screen for errors
      // This prevents dead-end error screens as recommended in the research
      if (kDebugMode) {
        print('[Router] Error on route: ${state.matchedLocation}, '
            'falling back to sign-in. Error: ${state.error}');
      }
      return const SignInScreen();
    },
  );
}
