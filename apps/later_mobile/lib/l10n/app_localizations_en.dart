// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get errorDatabaseUniqueConstraint =>
      'A record with this value already exists.';

  @override
  String get errorDatabaseForeignKeyViolation =>
      'Cannot perform this operation because it would break data relationships.';

  @override
  String get errorDatabaseNotNullViolation =>
      'Required data is missing. Please ensure all fields are filled.';

  @override
  String get errorDatabasePermissionDenied =>
      'You don\'t have permission to access this data.';

  @override
  String get errorDatabaseTimeout =>
      'The operation took too long. Please try again.';

  @override
  String get errorDatabaseGeneric =>
      'A database error occurred. Please try again.';

  @override
  String get errorAuthInvalidCredentials =>
      'Invalid email or password. Please try again.';

  @override
  String get errorAuthUserAlreadyExists =>
      'An account with this email already exists. Please sign in instead.';

  @override
  String errorAuthWeakPassword(String minLength) {
    return 'Password is too weak. Please use at least $minLength characters.';
  }

  @override
  String get errorAuthInvalidEmail =>
      'The email address is not valid. Please check and try again.';

  @override
  String get errorAuthEmailNotConfirmed =>
      'Please confirm your email address before signing in.';

  @override
  String get errorAuthSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get errorAuthNetworkError =>
      'Network error during authentication. Please check your connection and try again.';

  @override
  String get errorAuthRateLimitExceeded =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get errorAuthGeneric =>
      'An authentication error occurred. Please try again.';

  @override
  String get errorAuthAnonymousSignInFailed =>
      'Could not start trial. Please try again.';

  @override
  String get errorAuthUpgradeFailed =>
      'Could not create account. Please try again.';

  @override
  String get errorAuthAlreadyAuthenticated => 'You already have an account.';

  @override
  String get errorNetworkTimeout =>
      'Connection timed out. Please check your internet connection and try again.';

  @override
  String get errorNetworkNoConnection =>
      'No internet connection. Please check your network and try again.';

  @override
  String get errorNetworkServerError =>
      'The server encountered an error. Please try again later.';

  @override
  String get errorNetworkBadRequest =>
      'Invalid request. Please check your input and try again.';

  @override
  String get errorNetworkNotFound => 'The requested resource was not found.';

  @override
  String get errorNetworkGeneric =>
      'A network error occurred. Please try again.';

  @override
  String errorValidationRequired(String fieldName) {
    return '$fieldName is required.';
  }

  @override
  String errorValidationInvalidFormat(String fieldName) {
    return '$fieldName has an invalid format.';
  }

  @override
  String errorValidationOutOfRange(String fieldName, String min, String max) {
    return '$fieldName must be between $min and $max.';
  }

  @override
  String errorValidationDuplicate(String fieldName) {
    return '$fieldName already exists.';
  }

  @override
  String get errorSpaceNotFound =>
      'The space you\'re looking for was not found.';

  @override
  String get errorNoteNotFound => 'The note you\'re looking for was not found.';

  @override
  String get errorInsufficientPermissions =>
      'You don\'t have permission to perform this action.';

  @override
  String get errorOperationNotAllowed =>
      'This operation is not allowed in the current state.';

  @override
  String get errorUnknownError =>
      'An unexpected error occurred. Please try again.';

  @override
  String get authTitleSignIn => 'Welcome Back';

  @override
  String get authTitleSignUp => 'Create Account';

  @override
  String get authLabelEmail => 'Email';

  @override
  String get authHintEmail => 'your@email.com';

  @override
  String get authLabelPassword => 'Password';

  @override
  String get authHintPassword => '••••••••';

  @override
  String get authLabelConfirmPassword => 'Confirm Password';

  @override
  String get authValidationEmailRequired => 'Please enter your email';

  @override
  String get authValidationEmailInvalid => 'Please enter a valid email';

  @override
  String get authValidationPasswordRequired => 'Please enter your password';

  @override
  String get authValidationPasswordRequiredSignUp => 'Please enter a password';

  @override
  String get authValidationPasswordMinLength =>
      'Password must be at least 8 characters';

  @override
  String get authValidationConfirmPasswordRequired =>
      'Please confirm your password';

  @override
  String get authValidationPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get authButtonSignIn => 'Sign In';

  @override
  String get authButtonSignUp => 'Sign Up';

  @override
  String get authButtonContinueWithoutAccount => 'Continue without account';

  @override
  String get authLinkSignUp => 'Sign up';

  @override
  String get authLinkSignIn => 'Sign in';

  @override
  String get authTextNoAccount => 'Don\'t have an account? ';

  @override
  String get authTextHaveAccount => 'Already have an account? ';

  @override
  String get authPasswordStrengthWeak => 'Weak';

  @override
  String get authPasswordStrengthMedium => 'Medium';

  @override
  String get authPasswordStrengthStrong => 'Strong';

  @override
  String get authPasswordStrengthHelper => 'Use 8+ characters';

  @override
  String get authAccessibilityPasswordStrength => 'Password strength';

  @override
  String get emptyWelcomeTitle => 'Welcome to later';

  @override
  String get emptyWelcomeMessage =>
      'Your peaceful place for thoughts, tasks, and everything in between';

  @override
  String get emptyWelcomeAction => 'Create your first item';

  @override
  String get emptyWelcomeSecondaryAction => 'Learn how it works';

  @override
  String get emptyNoSpacesTitle => 'Welcome to Later';

  @override
  String get emptyNoSpacesMessage =>
      'Spaces organize your tasks, notes, and lists by context. Let\'s create your first one!';

  @override
  String get emptyNoSpacesAction => 'Create Your First Space';

  @override
  String get emptyNoSpacesSecondaryAction => 'Learn more';

  @override
  String emptySpaceTitle(String spaceName) {
    return 'Your $spaceName is empty';
  }

  @override
  String get emptySpaceMessage =>
      'Start capturing your thoughts, tasks, and ideas';

  @override
  String get emptySpaceAction => 'Create';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationHomeTooltip => 'View your spaces';

  @override
  String get navigationHomeSemanticLabel => 'Home navigation';

  @override
  String get navigationSearch => 'Search';

  @override
  String get navigationSearchTooltip => 'Search items';

  @override
  String get navigationSearchSemanticLabel => 'Search navigation';

  @override
  String get navigationSettings => 'Settings';

  @override
  String get navigationSettingsTooltip => 'App settings';

  @override
  String get navigationSettingsSemanticLabel => 'Settings navigation';

  @override
  String get sidebarSpaces => 'Spaces';

  @override
  String get sidebarCollapse => 'Collapse sidebar';

  @override
  String get sidebarExpand => 'Expand sidebar';

  @override
  String get sidebarSignOut => 'Sign Out';

  @override
  String get sidebarNoSpaces => 'No spaces yet';

  @override
  String get filterAll => 'All';

  @override
  String get filterTodoLists => 'Todo Lists';

  @override
  String get filterLists => 'Lists';

  @override
  String get filterNotes => 'Notes';

  @override
  String get menuSignOut => 'Sign Out';

  @override
  String get noteDetailTitleEmpty => 'Title cannot be empty';

  @override
  String get noteDetailSaveFailed => 'Failed to save changes';

  @override
  String get noteDetailTagEmpty => 'Tag cannot be empty';

  @override
  String noteDetailTagTooLong(String maxLength) {
    return 'Tag is too long (max $maxLength characters)';
  }

  @override
  String get noteDetailTagExists => 'Tag already exists';

  @override
  String get noteDetailTagAdded => 'Tag added';

  @override
  String get noteDetailTagRemoved => 'Tag removed';

  @override
  String get noteDetailTagAddFailed => 'Failed to add tag';

  @override
  String get noteDetailTagRemoveFailed => 'Failed to remove tag';

  @override
  String get noteDetailAddTagTitle => 'Add Tag';

  @override
  String get noteDetailTagNameLabel => 'Tag Name';

  @override
  String get noteDetailTagNameHint => 'Enter tag name';

  @override
  String get noteDetailDeleteTitle => 'Delete Note';

  @override
  String noteDetailDeleteMessage(String noteTitle) {
    return 'Are you sure you want to delete \"$noteTitle\"?\n\nThis action cannot be undone.';
  }

  @override
  String get noteDetailDeleteFailed => 'Failed to delete note';

  @override
  String get noteDetailContentHint => 'Start writing your note...';

  @override
  String get noteDetailTitleHint => 'Note title';

  @override
  String get noteDetailTagsLabel => 'Tags';

  @override
  String get noteDetailTagsEmpty => 'No tags yet. Tap + to add tags.';

  @override
  String get noteDetailMenuDelete => 'Delete Note';

  @override
  String get todoDetailNameEmpty => 'TodoList name cannot be empty';

  @override
  String get todoDetailSaveFailed => 'Failed to save changes';

  @override
  String get todoDetailLoadFailed => 'Failed to load items';

  @override
  String get todoDetailItemAdded => 'TodoItem added';

  @override
  String get todoDetailItemAddFailed => 'Failed to add item';

  @override
  String get todoDetailItemUpdated => 'TodoItem updated';

  @override
  String get todoDetailItemUpdateFailed => 'Failed to update item';

  @override
  String get todoDetailItemDeleted => 'TodoItem deleted';

  @override
  String get todoDetailItemDeleteFailed => 'Failed to delete item';

  @override
  String get todoDetailItemToggleFailed => 'Failed to toggle item';

  @override
  String get todoDetailReorderFailed => 'Failed to reorder items';

  @override
  String get todoDetailDeleteListTitle => 'Delete TodoList';

  @override
  String todoDetailDeleteListMessage(String listName, int itemCount) {
    return 'Are you sure you want to delete \"$listName\"?\n\nThis will delete all $itemCount items in this list. This action cannot be undone.';
  }

  @override
  String get todoDetailDeleteListFailed => 'Failed to delete list';

  @override
  String get todoDetailAddItemTitle => 'Add TodoItem';

  @override
  String get todoDetailEditItemTitle => 'Edit TodoItem';

  @override
  String get todoDetailItemTitleLabel => 'Title *';

  @override
  String get todoDetailItemTitleHint => 'Enter task title';

  @override
  String get todoDetailItemTitleRequired => 'Title is required';

  @override
  String get todoDetailItemDescriptionLabel => 'Description';

  @override
  String get todoDetailItemDescriptionHint => 'Optional description';

  @override
  String get todoDetailItemDueDateNone => 'No due date';

  @override
  String get todoDetailItemPriorityLabel => 'Priority';

  @override
  String get todoDetailPriorityHigh => 'High';

  @override
  String get todoDetailPriorityMedium => 'Medium';

  @override
  String get todoDetailPriorityLow => 'Low';

  @override
  String todoDetailProgressCompleted(int completed, int total) {
    return '$completed/$total completed';
  }

  @override
  String get todoDetailEmptyTitle => 'No tasks yet';

  @override
  String get todoDetailEmptyMessage =>
      'Tap the + button to add your first task';

  @override
  String get todoDetailFabLabel => 'Add Todo';

  @override
  String get todoDetailNameHint => 'TodoList name';

  @override
  String get todoDetailMenuDelete => 'Delete List';

  @override
  String get listDetailNameEmpty => 'List name cannot be empty';

  @override
  String get listDetailSaveFailed => 'Failed to save changes';

  @override
  String get listDetailLoadFailed => 'Failed to load items';

  @override
  String get listDetailItemAdded => 'Item added';

  @override
  String get listDetailItemAddFailed => 'Failed to add item';

  @override
  String get listDetailItemUpdated => 'Item updated';

  @override
  String get listDetailItemUpdateFailed => 'Failed to update item';

  @override
  String get listDetailItemDeleted => 'Item deleted';

  @override
  String get listDetailItemDeleteFailed => 'Failed to delete item';

  @override
  String get listDetailItemToggleFailed => 'Failed to toggle item';

  @override
  String get listDetailReorderFailed => 'Failed to reorder items';

  @override
  String get listDetailStyleUpdated => 'List style updated';

  @override
  String get listDetailStyleChangeFailed => 'Failed to change style';

  @override
  String get listDetailIconUpdated => 'List icon updated';

  @override
  String get listDetailIconChangeFailed => 'Failed to change icon';

  @override
  String get listDetailDeleteTitle => 'Delete List';

  @override
  String listDetailDeleteMessage(String listName, int itemCount) {
    return 'Are you sure you want to delete \"$listName\"?\n\nThis will delete all $itemCount items in this list. This action cannot be undone.';
  }

  @override
  String get listDetailDeleteFailed => 'Failed to delete list';

  @override
  String get listDetailAddItemTitle => 'Add Item';

  @override
  String get listDetailEditItemTitle => 'Edit Item';

  @override
  String get listDetailItemTitleLabel => 'Title *';

  @override
  String get listDetailItemTitleHint => 'Enter item title';

  @override
  String get listDetailItemTitleRequired => 'Title is required';

  @override
  String get listDetailItemNotesLabel => 'Notes';

  @override
  String get listDetailItemNotesHint => 'Optional notes';

  @override
  String get listDetailStyleDialogTitle => 'Select Style';

  @override
  String get listDetailStyleBullets => 'Bullets';

  @override
  String get listDetailStyleBulletsDesc => 'Simple bullet points';

  @override
  String get listDetailStyleNumbered => 'Numbered';

  @override
  String get listDetailStyleNumberedDesc => 'Numbered list items';

  @override
  String get listDetailStyleCheckboxes => 'Checkboxes';

  @override
  String get listDetailStyleCheckboxesDesc => 'Checkable task items';

  @override
  String get listDetailIconDialogTitle => 'Select Icon';

  @override
  String listDetailProgressCompleted(int checked, int total) {
    return '$checked/$total completed';
  }

  @override
  String get listDetailEmptyTitle => 'No items yet';

  @override
  String get listDetailEmptyMessage =>
      'Tap the + button to add your first item';

  @override
  String get listDetailFabLabel => 'Add Item';

  @override
  String get listDetailNameHint => 'List name';

  @override
  String get listDetailMenuChangeStyle => 'Change Style';

  @override
  String get listDetailMenuChangeIcon => 'Change Icon';

  @override
  String get listDetailMenuDelete => 'Delete List';

  @override
  String get spaceModalTitle => 'Switch Space';

  @override
  String get spaceModalSearchHint => 'Search spaces...';

  @override
  String get spaceModalNoSpacesFound => 'No spaces found';

  @override
  String get spaceModalNoSpacesAvailable => 'No spaces available';

  @override
  String get spaceModalArchived => 'Archived';

  @override
  String get spaceModalShowArchived => 'Show Archived Spaces';

  @override
  String get spaceModalCreateNew => 'Create New Space';

  @override
  String get spaceModalMenuEdit => 'Edit Space';

  @override
  String get spaceModalMenuArchive => 'Archive Space';

  @override
  String get spaceModalMenuArchiveHint => 'Switch to another space first';

  @override
  String spaceModalMenuArchiveHintItems(int itemCount) {
    return 'This space contains $itemCount items';
  }

  @override
  String get spaceModalMenuRestore => 'Restore Space';

  @override
  String get spaceModalMenuRestoreHint => 'Make this space active again';

  @override
  String get spaceModalMenuCancel => 'Cancel';

  @override
  String get spaceModalSwitchFailed => 'Failed to switch space';

  @override
  String get spaceModalArchiveCurrent =>
      'Cannot archive the current space. Switch to another space first.';

  @override
  String get spaceModalArchiveConfirmTitle => 'Archive Space?';

  @override
  String spaceModalArchiveConfirmMessage(int itemCount) {
    return 'This space contains $itemCount items. Archiving will hide the space but keep all items. You can restore it later from archived spaces.';
  }

  @override
  String spaceModalArchiveSuccess(String spaceName) {
    return '$spaceName has been archived';
  }

  @override
  String get spaceModalArchiveFailed => 'Failed to archive space';

  @override
  String spaceModalRestoreSuccess(String spaceName) {
    return '$spaceName has been restored';
  }

  @override
  String get spaceModalRestoreFailed => 'Failed to restore space';

  @override
  String get createModalTitle => 'Create';

  @override
  String get createModalTypeTodoList => 'Todo List';

  @override
  String get createModalTypeList => 'List';

  @override
  String get createModalTypeNote => 'Note';

  @override
  String get createModalTodoListNameHint => 'Todo list name';

  @override
  String get createModalListNameHint => 'List name';

  @override
  String get createModalNoteTitleHint => 'Note title';

  @override
  String get createModalNoteContentHint => 'Note content';

  @override
  String get createModalNoteSmartFieldHint =>
      'Note title or content...\n(First line becomes title)';

  @override
  String get createModalListStyleLabel => 'List Style';

  @override
  String get createModalListStyleBullets => 'Bullets';

  @override
  String get createModalListStyleNumbered => 'Numbered';

  @override
  String get createModalListStyleCheckboxes => 'Checklist';

  @override
  String get createModalListStyleSimple => 'Simple';

  @override
  String get createModalTodoDescriptionLabel => 'Description (optional)';

  @override
  String get createModalTodoDescriptionHint => 'Add description (optional)';

  @override
  String get createModalTodoDescriptionAdd => '+ Add description (optional)';

  @override
  String get createModalTodoDescriptionTooLong =>
      'Description too long (max 500 characters)';

  @override
  String get createModalSaveToLabel => 'Save to: ';

  @override
  String get createModalKeyboardShortcutMac =>
      '⌘+Enter to create • Esc to close';

  @override
  String get createModalKeyboardShortcutOther =>
      'Ctrl+Enter to create • Esc to close';

  @override
  String get createModalButtonTodoList => 'Create Todo List';

  @override
  String get createModalButtonList => 'Create List';

  @override
  String get createModalButtonNote => 'Create Note';

  @override
  String get createModalButtonGeneric => 'Create';

  @override
  String get createModalCloseTitle => 'Discard unsaved content?';

  @override
  String get createModalCloseMessage =>
      'You haven\'t created this item yet. Would you like to create it or discard your changes?';

  @override
  String get createModalCloseCancel => 'Cancel';

  @override
  String get createModalCloseDiscard => 'Discard';

  @override
  String get createModalCloseCreate => 'Create & Close';

  @override
  String get buttonAdd => 'Add';

  @override
  String get buttonSave => 'Save';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get buttonClose => 'Close';

  @override
  String get buttonArchive => 'Archive';

  @override
  String get accessibilityCloseButton => 'Close';

  @override
  String get accessibilityAddDescription => 'Add description, collapsed';

  @override
  String get accessibilityAddDescriptionHint =>
      'Tap to add optional description field';

  @override
  String get accessibilityRemoveDescription => 'Remove description field';

  @override
  String get accessibilityCreateNewSpace => 'Create new space';

  @override
  String accessibilitySpaceItemCount(String spaceName, int itemCount) {
    return '$spaceName, $itemCount items';
  }

  @override
  String get spaceSwitcherTitle => 'Switch Space';

  @override
  String get spaceSwitcherSearchHint => 'Search spaces...';

  @override
  String spaceSwitcherErrorSwitch(String error) {
    return 'Failed to switch space: $error';
  }

  @override
  String get spaceSwitcherEmptyNoResults => 'No spaces found';

  @override
  String get spaceSwitcherEmptyNoSpaces => 'No spaces available';

  @override
  String spaceSwitcherItemCount(int count) {
    return '$count items';
  }

  @override
  String get spaceSwitcherMenuEdit => 'Edit Space';

  @override
  String get spaceSwitcherMenuArchive => 'Archive Space';

  @override
  String get spaceSwitcherMenuRestore => 'Restore Space';

  @override
  String get spaceSwitcherMenuCancel => 'Cancel';

  @override
  String get spaceSwitcherSubtitleSwitchFirst =>
      'Switch to another space first';

  @override
  String spaceSwitcherSubtitleContainsItems(int count) {
    return 'This space contains $count items';
  }

  @override
  String get spaceSwitcherSubtitleRestore => 'Make this space active again';

  @override
  String get spaceSwitcherDialogArchiveTitle => 'Archive Space?';

  @override
  String spaceSwitcherDialogArchiveContent(int count) {
    return 'This space contains $count items. Archiving will hide the space but keep all items. You can restore it later from archived spaces.';
  }

  @override
  String spaceSwitcherSuccessArchived(String name) {
    return '$name has been archived';
  }

  @override
  String spaceSwitcherSuccessRestored(String name) {
    return '$name has been restored';
  }

  @override
  String spaceSwitcherErrorArchive(String error) {
    return 'Failed to archive space: $error';
  }

  @override
  String spaceSwitcherErrorRestore(String error) {
    return 'Failed to restore space: $error';
  }

  @override
  String get spaceSwitcherErrorCannotArchiveCurrent =>
      'Cannot archive the current space. Switch to another space first.';

  @override
  String get spaceSwitcherBadgeArchived => 'Archived';

  @override
  String get spaceSwitcherToggleShowArchived => 'Show Archived Spaces';

  @override
  String get spaceSwitcherButtonCreateNew => 'Create New Space';

  @override
  String get searchEmptyTitle => 'No results found';

  @override
  String get searchEmptyMessage =>
      'Try different keywords or check your spelling';

  @override
  String get accessibilityDragHandleHint => 'Double tap and hold to reorder';

  @override
  String get navigationBottomHome => 'Home';

  @override
  String get navigationBottomHomeTooltip => 'View your spaces';

  @override
  String get navigationBottomHomeSemanticLabel => 'Home navigation';

  @override
  String get navigationBottomSearch => 'Search';

  @override
  String get navigationBottomSearchTooltip => 'Search items';

  @override
  String get navigationBottomSearchSemanticLabel => 'Search navigation';

  @override
  String get navigationBottomSettings => 'Settings';

  @override
  String get navigationBottomSettingsTooltip => 'App settings';

  @override
  String get navigationBottomSettingsSemanticLabel => 'Settings navigation';

  @override
  String get dialogDeleteItemTitle => 'Delete Item?';

  @override
  String dialogDeleteItemMessage(String itemName) {
    return 'Are you sure you want to delete \"$itemName\"? This action cannot be undone.';
  }
}
