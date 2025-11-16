import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/permissions/permission_service.dart';
import 'package:later_mobile/core/permissions/user_role.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@GenerateMocks([SupabaseClient, GoTrueClient, User])
import 'permission_service_test.mocks.dart';

void main() {
  group('PermissionService', () {
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockAuth;
    late MockUser mockUser;
    late PermissionService service;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      mockUser = MockUser();

      // Set up basic mocks
      when(mockSupabaseClient.auth).thenReturn(mockAuth);

      service = PermissionService(mockSupabaseClient);
    });

    group('getCurrentUserRole', () {
      test('returns UserRole.anonymous when user is null', () {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);

        // Act
        final result = service.getCurrentUserRole();

        // Assert
        expect(result, UserRole.anonymous);
      });

      test('returns UserRole.anonymous when user.isAnonymous is true', () {
        // Arrange
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.isAnonymous).thenReturn(true);

        // Act
        final result = service.getCurrentUserRole();

        // Assert
        expect(result, UserRole.anonymous);
      });

      test('returns UserRole.authenticated when user.isAnonymous is false', () {
        // Arrange
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.isAnonymous).thenReturn(false);

        // Act
        final result = service.getCurrentUserRole();

        // Assert
        expect(result, UserRole.authenticated);
      });
    });

    group('isAnonymous', () {
      test('returns true when user is anonymous', () {
        // Arrange
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.isAnonymous).thenReturn(true);

        // Act
        final result = service.isAnonymous();

        // Assert
        expect(result, true);
      });

      test('returns false when user is authenticated', () {
        // Arrange
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.isAnonymous).thenReturn(false);

        // Act
        final result = service.isAnonymous();

        // Assert
        expect(result, false);
      });

      test('returns true when user is null (fallback)', () {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);

        // Act
        final result = service.isAnonymous();

        // Assert
        expect(result, true);
      });
    });

    group('isAuthenticated', () {
      test('returns false when user is anonymous', () {
        // Arrange
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.isAnonymous).thenReturn(true);

        // Act
        final result = service.isAuthenticated();

        // Assert
        expect(result, false);
      });

      test('returns true when user is authenticated', () {
        // Arrange
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.isAnonymous).thenReturn(false);

        // Act
        final result = service.isAuthenticated();

        // Assert
        expect(result, true);
      });

      test('returns false when user is null (fallback)', () {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);

        // Act
        final result = service.isAuthenticated();

        // Assert
        expect(result, false);
      });
    });
  });

  group('UserRolePermissions', () {
    group('permission getters', () {
      test('authenticated user can create unlimited spaces', () {
        expect(UserRole.authenticated.canCreateUnlimitedSpaces, true);
      });

      test('anonymous user cannot create unlimited spaces', () {
        expect(UserRole.anonymous.canCreateUnlimitedSpaces, false);
      });

      test('authenticated user can create unlimited notes', () {
        expect(UserRole.authenticated.canCreateUnlimitedNotes, true);
      });

      test('anonymous user cannot create unlimited notes', () {
        expect(UserRole.anonymous.canCreateUnlimitedNotes, false);
      });

      test('authenticated user can create unlimited todo lists', () {
        expect(UserRole.authenticated.canCreateUnlimitedTodoLists, true);
      });

      test('anonymous user cannot create unlimited todo lists', () {
        expect(UserRole.anonymous.canCreateUnlimitedTodoLists, false);
      });

      test('authenticated user can create unlimited custom lists', () {
        expect(UserRole.authenticated.canCreateUnlimitedLists, true);
      });

      test('anonymous user cannot create unlimited custom lists', () {
        expect(UserRole.anonymous.canCreateUnlimitedLists, false);
      });
    });

    group('limit getters', () {
      test('maxSpacesForAnonymous returns 1', () {
        expect(UserRole.anonymous.maxSpacesForAnonymous, 1);
        expect(UserRole.authenticated.maxSpacesForAnonymous, 1);
      });

      test('maxNotesPerSpaceForAnonymous returns 20', () {
        expect(UserRole.anonymous.maxNotesPerSpaceForAnonymous, 20);
        expect(UserRole.authenticated.maxNotesPerSpaceForAnonymous, 20);
      });

      test('maxTodoListsPerSpaceForAnonymous returns 10', () {
        expect(UserRole.anonymous.maxTodoListsPerSpaceForAnonymous, 10);
        expect(UserRole.authenticated.maxTodoListsPerSpaceForAnonymous, 10);
      });

      test('maxListsPerSpaceForAnonymous returns 5', () {
        expect(UserRole.anonymous.maxListsPerSpaceForAnonymous, 5);
        expect(UserRole.authenticated.maxListsPerSpaceForAnonymous, 5);
      });
    });
  });
}
