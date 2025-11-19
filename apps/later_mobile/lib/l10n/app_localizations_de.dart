// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get errorDatabaseUniqueConstraint =>
      'Ein Eintrag mit diesem Wert existiert bereits.';

  @override
  String get errorDatabaseForeignKeyViolation =>
      'Diese Operation kann nicht durchgeführt werden, da sie Datenbeziehungen verletzen würde.';

  @override
  String get errorDatabaseNotNullViolation =>
      'Erforderliche Daten fehlen. Bitte stellen Sie sicher, dass alle Felder ausgefüllt sind.';

  @override
  String get errorDatabasePermissionDenied =>
      'Sie haben keine Berechtigung, auf diese Daten zuzugreifen.';

  @override
  String get errorDatabaseTimeout =>
      'Die Operation hat zu lange gedauert. Bitte versuchen Sie es erneut.';

  @override
  String get errorDatabaseGeneric =>
      'Ein Datenbankfehler ist aufgetreten. Bitte versuchen Sie es erneut.';

  @override
  String get errorAuthInvalidCredentials =>
      'Ungültige E-Mail oder Passwort. Bitte versuchen Sie es erneut.';

  @override
  String get errorAuthUserAlreadyExists =>
      'Ein Konto mit dieser E-Mail existiert bereits. Bitte melden Sie sich stattdessen an.';

  @override
  String errorAuthWeakPassword(String minLength) {
    return 'Das Passwort ist zu schwach. Bitte verwenden Sie mindestens $minLength Zeichen.';
  }

  @override
  String get errorAuthInvalidEmail =>
      'Die E-Mail-Adresse ist nicht gültig. Bitte überprüfen Sie sie und versuchen Sie es erneut.';

  @override
  String get errorAuthEmailNotConfirmed =>
      'Bitte bestätigen Sie Ihre E-Mail-Adresse, bevor Sie sich anmelden.';

  @override
  String get errorAuthSessionExpired =>
      'Ihre Sitzung ist abgelaufen. Bitte melden Sie sich erneut an.';

  @override
  String get errorAuthNetworkError =>
      'Netzwerkfehler bei der Authentifizierung. Bitte überprüfen Sie Ihre Verbindung und versuchen Sie es erneut.';

  @override
  String get errorAuthRateLimitExceeded =>
      'Zu viele Versuche. Bitte warten Sie einen Moment und versuchen Sie es erneut.';

  @override
  String get errorAuthGeneric =>
      'Ein Authentifizierungsfehler ist aufgetreten. Bitte versuchen Sie es erneut.';

  @override
  String get errorAuthAnonymousSignInFailed =>
      'Test konnte nicht gestartet werden. Bitte versuchen Sie es erneut.';

  @override
  String get errorAuthUpgradeFailed =>
      'Konto konnte nicht erstellt werden. Bitte versuchen Sie es erneut.';

  @override
  String get errorAuthAlreadyAuthenticated => 'Sie haben bereits ein Konto.';

  @override
  String get errorNetworkTimeout =>
      'Zeitüberschreitung der Verbindung. Bitte überprüfen Sie Ihre Internetverbindung und versuchen Sie es erneut.';

  @override
  String get errorNetworkNoConnection =>
      'Keine Internetverbindung. Bitte überprüfen Sie Ihr Netzwerk und versuchen Sie es erneut.';

  @override
  String get errorNetworkServerError =>
      'Der Server hat einen Fehler festgestellt. Bitte versuchen Sie es später erneut.';

  @override
  String get errorNetworkBadRequest =>
      'Ungültige Anfrage. Bitte überprüfen Sie Ihre Eingabe und versuchen Sie es erneut.';

  @override
  String get errorNetworkNotFound =>
      'Die angeforderte Ressource wurde nicht gefunden.';

  @override
  String get errorNetworkGeneric =>
      'Ein Netzwerkfehler ist aufgetreten. Bitte versuchen Sie es erneut.';

  @override
  String errorValidationRequired(String fieldName) {
    return '$fieldName ist erforderlich.';
  }

  @override
  String errorValidationInvalidFormat(String fieldName) {
    return '$fieldName hat ein ungültiges Format.';
  }

  @override
  String errorValidationOutOfRange(String fieldName, String min, String max) {
    return '$fieldName muss zwischen $min und $max liegen.';
  }

  @override
  String errorValidationDuplicate(String fieldName) {
    return '$fieldName existiert bereits.';
  }

  @override
  String get errorSpaceNotFound => 'Der gesuchte Bereich wurde nicht gefunden.';

  @override
  String get errorNoteNotFound => 'Die gesuchte Notiz wurde nicht gefunden.';

  @override
  String get errorInsufficientPermissions =>
      'Sie haben keine Berechtigung, diese Aktion auszuführen.';

  @override
  String get errorOperationNotAllowed =>
      'Diese Operation ist im aktuellen Zustand nicht erlaubt.';

  @override
  String get errorUnknownError =>
      'Ein unerwarteter Fehler ist aufgetreten. Bitte versuchen Sie es erneut.';

  @override
  String get authTitleSignIn => 'Willkommen zurück';

  @override
  String get authTitleSignUp => 'Konto erstellen';

  @override
  String get authLabelEmail => 'E-Mail';

  @override
  String get authHintEmail => 'deine@email.de';

  @override
  String get authLabelPassword => 'Passwort';

  @override
  String get authHintPassword => '••••••••';

  @override
  String get authLabelConfirmPassword => 'Passwort bestätigen';

  @override
  String get authValidationEmailRequired => 'Bitte geben Sie Ihre E-Mail ein';

  @override
  String get authValidationEmailInvalid =>
      'Bitte geben Sie eine gültige E-Mail ein';

  @override
  String get authValidationPasswordRequired =>
      'Bitte geben Sie Ihr Passwort ein';

  @override
  String get authValidationPasswordRequiredSignUp =>
      'Bitte geben Sie ein Passwort ein';

  @override
  String get authValidationPasswordMinLength =>
      'Passwort muss mindestens 8 Zeichen lang sein';

  @override
  String get authValidationConfirmPasswordRequired =>
      'Bitte bestätigen Sie Ihr Passwort';

  @override
  String get authValidationPasswordsDoNotMatch =>
      'Passwörter stimmen nicht überein';

  @override
  String get authButtonSignIn => 'Anmelden';

  @override
  String get authButtonSignUp => 'Registrieren';

  @override
  String get authButtonContinueWithoutAccount => 'Ohne Konto fortfahren';

  @override
  String get authLinkSignUp => 'Registrieren';

  @override
  String get authLinkSignIn => 'Anmelden';

  @override
  String get authTextNoAccount => 'Noch kein Konto? ';

  @override
  String get authTextHaveAccount => 'Bereits ein Konto? ';

  @override
  String get authPasswordStrengthWeak => 'Schwach';

  @override
  String get authPasswordStrengthMedium => 'Mittel';

  @override
  String get authPasswordStrengthStrong => 'Stark';

  @override
  String get authPasswordStrengthHelper => 'Mindestens 8 Zeichen';

  @override
  String get authAccessibilityPasswordStrength => 'Passwortstärke';

  @override
  String get emptyWelcomeTitle => 'Willkommen bei later';

  @override
  String get emptyWelcomeMessage =>
      'Dein friedlicher Ort für Gedanken, Aufgaben und alles dazwischen';

  @override
  String get emptyWelcomeAction => 'Erstelle dein erstes Element';

  @override
  String get emptyWelcomeSecondaryAction => 'Erfahre, wie es funktioniert';

  @override
  String get emptyNoSpacesTitle => 'Willkommen bei Later';

  @override
  String get emptyNoSpacesMessage =>
      'Bereiche organisieren deine Aufgaben, Notizen und Listen nach Kontext. Lass uns deinen ersten erstellen!';

  @override
  String get emptyNoSpacesAction => 'Erstelle deinen ersten Bereich';

  @override
  String get emptyNoSpacesSecondaryAction => 'Mehr erfahren';

  @override
  String emptySpaceTitle(String spaceName) {
    return 'Dein $spaceName ist leer';
  }

  @override
  String get emptySpaceMessage =>
      'Beginne, deine Gedanken, Aufgaben und Ideen festzuhalten';

  @override
  String get emptySpaceAction => 'Erstellen';

  @override
  String get navigationHome => 'Startseite';

  @override
  String get navigationHomeTooltip => 'Ihre Bereiche anzeigen';

  @override
  String get navigationHomeSemanticLabel => 'Startseite-Navigation';

  @override
  String get navigationSearch => 'Suchen';

  @override
  String get navigationSearchTooltip => 'Einträge suchen';

  @override
  String get navigationSearchSemanticLabel => 'Such-Navigation';

  @override
  String get navigationSettings => 'Einstellungen';

  @override
  String get navigationSettingsTooltip => 'App-Einstellungen';

  @override
  String get navigationSettingsSemanticLabel => 'Einstellungen-Navigation';

  @override
  String get sidebarSpaces => 'Bereiche';

  @override
  String get sidebarCollapse => 'Seitenleiste einklappen';

  @override
  String get sidebarExpand => 'Seitenleiste ausklappen';

  @override
  String get sidebarSignOut => 'Abmelden';

  @override
  String get sidebarNoSpaces => 'Noch keine Bereiche';

  @override
  String get filterAll => 'Alle';

  @override
  String get filterTodoLists => 'Aufgabenlisten';

  @override
  String get filterLists => 'Listen';

  @override
  String get filterNotes => 'Notizen';

  @override
  String get menuSignOut => 'Abmelden';

  @override
  String get noteDetailTitleEmpty => 'Titel darf nicht leer sein';

  @override
  String get noteDetailSaveFailed =>
      'Änderungen konnten nicht gespeichert werden';

  @override
  String get noteDetailTagEmpty => 'Tag darf nicht leer sein';

  @override
  String noteDetailTagTooLong(String maxLength) {
    return 'Tag ist zu lang (max $maxLength Zeichen)';
  }

  @override
  String get noteDetailTagExists => 'Tag existiert bereits';

  @override
  String get noteDetailTagAdded => 'Tag hinzugefügt';

  @override
  String get noteDetailTagRemoved => 'Tag entfernt';

  @override
  String get noteDetailTagAddFailed => 'Tag konnte nicht hinzugefügt werden';

  @override
  String get noteDetailTagRemoveFailed => 'Tag konnte nicht entfernt werden';

  @override
  String get noteDetailAddTagTitle => 'Tag hinzufügen';

  @override
  String get noteDetailTagNameLabel => 'Tag-Name';

  @override
  String get noteDetailTagNameHint => 'Tag-Namen eingeben';

  @override
  String get noteDetailDeleteTitle => 'Notiz löschen';

  @override
  String noteDetailDeleteMessage(String noteTitle) {
    return 'Sind Sie sicher, dass Sie \"$noteTitle\" löschen möchten?\n\nDiese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String get noteDetailDeleteFailed => 'Notiz konnte nicht gelöscht werden';

  @override
  String get noteDetailContentHint =>
      'Beginnen Sie mit dem Schreiben Ihrer Notiz...';

  @override
  String get noteDetailTitleHint => 'Notiz-Titel';

  @override
  String get noteDetailTagsLabel => 'Tags';

  @override
  String get noteDetailTagsEmpty =>
      'Noch keine Tags. Tippen Sie auf +, um Tags hinzuzufügen.';

  @override
  String get noteDetailMenuDelete => 'Notiz löschen';

  @override
  String get todoDetailNameEmpty =>
      'Name der Aufgabenliste darf nicht leer sein';

  @override
  String get todoDetailSaveFailed =>
      'Änderungen konnten nicht gespeichert werden';

  @override
  String get todoDetailLoadFailed => 'Einträge konnten nicht geladen werden';

  @override
  String get todoDetailItemAdded => 'Aufgabe hinzugefügt';

  @override
  String get todoDetailItemAddFailed =>
      'Eintrag konnte nicht hinzugefügt werden';

  @override
  String get todoDetailItemUpdated => 'Aufgabe aktualisiert';

  @override
  String get todoDetailItemUpdateFailed =>
      'Eintrag konnte nicht aktualisiert werden';

  @override
  String get todoDetailItemDeleted => 'Aufgabe gelöscht';

  @override
  String get todoDetailItemDeleteFailed =>
      'Eintrag konnte nicht gelöscht werden';

  @override
  String get todoDetailItemToggleFailed =>
      'Eintrag konnte nicht umgeschaltet werden';

  @override
  String get todoDetailReorderFailed =>
      'Einträge konnten nicht neu angeordnet werden';

  @override
  String get todoDetailDeleteListTitle => 'Aufgabenliste löschen';

  @override
  String todoDetailDeleteListMessage(String listName, int itemCount) {
    return 'Sind Sie sicher, dass Sie \"$listName\" löschen möchten?\n\nDadurch werden alle $itemCount Einträge in dieser Liste gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String get todoDetailDeleteListFailed => 'Liste konnte nicht gelöscht werden';

  @override
  String get todoDetailAddItemTitle => 'Aufgabe hinzufügen';

  @override
  String get todoDetailEditItemTitle => 'Aufgabe bearbeiten';

  @override
  String get todoDetailItemTitleLabel => 'Titel *';

  @override
  String get todoDetailItemTitleHint => 'Aufgabentitel eingeben';

  @override
  String get todoDetailItemTitleRequired => 'Titel ist erforderlich';

  @override
  String get todoDetailItemDescriptionLabel => 'Beschreibung';

  @override
  String get todoDetailItemDescriptionHint => 'Optionale Beschreibung';

  @override
  String get todoDetailItemDueDateNone => 'Kein Fälligkeitsdatum';

  @override
  String get todoDetailItemPriorityLabel => 'Priorität';

  @override
  String get todoDetailPriorityHigh => 'Hoch';

  @override
  String get todoDetailPriorityMedium => 'Mittel';

  @override
  String get todoDetailPriorityLow => 'Niedrig';

  @override
  String todoDetailProgressCompleted(int completed, int total) {
    return '$completed/$total abgeschlossen';
  }

  @override
  String get todoDetailEmptyTitle => 'Noch keine Aufgaben';

  @override
  String get todoDetailEmptyMessage =>
      'Tippen Sie auf die +-Schaltfläche, um Ihre erste Aufgabe hinzuzufügen';

  @override
  String get todoDetailFabLabel => 'Aufgabe hinzufügen';

  @override
  String get todoDetailNameHint => 'Name der Aufgabenliste';

  @override
  String get todoDetailMenuDelete => 'Liste löschen';

  @override
  String get listDetailNameEmpty => 'Listenname darf nicht leer sein';

  @override
  String get listDetailSaveFailed =>
      'Änderungen konnten nicht gespeichert werden';

  @override
  String get listDetailLoadFailed => 'Einträge konnten nicht geladen werden';

  @override
  String get listDetailItemAdded => 'Eintrag hinzugefügt';

  @override
  String get listDetailItemAddFailed =>
      'Eintrag konnte nicht hinzugefügt werden';

  @override
  String get listDetailItemUpdated => 'Eintrag aktualisiert';

  @override
  String get listDetailItemUpdateFailed =>
      'Eintrag konnte nicht aktualisiert werden';

  @override
  String get listDetailItemDeleted => 'Eintrag gelöscht';

  @override
  String get listDetailItemDeleteFailed =>
      'Eintrag konnte nicht gelöscht werden';

  @override
  String get listDetailItemToggleFailed =>
      'Kontrollkästchen konnte nicht umgeschaltet werden';

  @override
  String get listDetailReorderFailed =>
      'Einträge konnten nicht neu angeordnet werden';

  @override
  String get listDetailStyleUpdated => 'Listenstil aktualisiert';

  @override
  String get listDetailStyleChangeFailed => 'Stil konnte nicht geändert werden';

  @override
  String get listDetailIconUpdated => 'Listensymbol aktualisiert';

  @override
  String get listDetailIconChangeFailed =>
      'Symbol konnte nicht geändert werden';

  @override
  String get listDetailDeleteTitle => 'Liste löschen';

  @override
  String listDetailDeleteMessage(String listName, int itemCount) {
    return 'Sind Sie sicher, dass Sie \"$listName\" löschen möchten?\n\nDadurch werden alle $itemCount Einträge in dieser Liste gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String get listDetailDeleteFailed => 'Liste konnte nicht gelöscht werden';

  @override
  String get listDetailAddItemTitle => 'Eintrag hinzufügen';

  @override
  String get listDetailEditItemTitle => 'Eintrag bearbeiten';

  @override
  String get listDetailItemTitleLabel => 'Titel *';

  @override
  String get listDetailItemTitleHint => 'Eintragstitel eingeben';

  @override
  String get listDetailItemTitleRequired => 'Titel ist erforderlich';

  @override
  String get listDetailItemNotesLabel => 'Notizen';

  @override
  String get listDetailItemNotesHint => 'Optionale Notizen';

  @override
  String get listDetailStyleDialogTitle => 'Stil auswählen';

  @override
  String get listDetailStyleBullets => 'Aufzählung';

  @override
  String get listDetailStyleBulletsDesc => 'Einfache Aufzählungspunkte';

  @override
  String get listDetailStyleNumbered => 'Nummeriert';

  @override
  String get listDetailStyleNumberedDesc => 'Nummerierte Listeneinträge';

  @override
  String get listDetailStyleCheckboxes => 'Kontrollkästchen';

  @override
  String get listDetailStyleCheckboxesDesc => 'Abhakbare Aufgabeneinträge';

  @override
  String get listDetailIconDialogTitle => 'Symbol auswählen';

  @override
  String listDetailProgressCompleted(int checked, int total) {
    return '$checked/$total abgeschlossen';
  }

  @override
  String get listDetailEmptyTitle => 'Noch keine Einträge';

  @override
  String get listDetailEmptyMessage =>
      'Tippen Sie auf die +-Schaltfläche, um Ihren ersten Eintrag hinzuzufügen';

  @override
  String get listDetailFabLabel => 'Eintrag hinzufügen';

  @override
  String get listDetailNameHint => 'Listenname';

  @override
  String get listDetailMenuChangeStyle => 'Stil ändern';

  @override
  String get listDetailMenuChangeIcon => 'Symbol ändern';

  @override
  String get listDetailMenuDelete => 'Liste löschen';

  @override
  String get spaceModalTitle => 'Bereich wechseln';

  @override
  String get spaceModalSearchHint => 'Bereiche durchsuchen...';

  @override
  String get spaceModalNoSpacesFound => 'Keine Bereiche gefunden';

  @override
  String get spaceModalNoSpacesAvailable => 'Keine Bereiche verfügbar';

  @override
  String get spaceModalArchived => 'Archiviert';

  @override
  String get spaceModalShowArchived => 'Archivierte Bereiche anzeigen';

  @override
  String get spaceModalCreateNew => 'Neuen Bereich erstellen';

  @override
  String get spaceModalMenuEdit => 'Bereich bearbeiten';

  @override
  String get spaceModalMenuArchive => 'Bereich archivieren';

  @override
  String get spaceModalMenuArchiveHint =>
      'Wechseln Sie zuerst zu einem anderen Bereich';

  @override
  String spaceModalMenuArchiveHintItems(int itemCount) {
    return 'Dieser Bereich enthält $itemCount Einträge';
  }

  @override
  String get spaceModalMenuRestore => 'Bereich wiederherstellen';

  @override
  String get spaceModalMenuRestoreHint => 'Diesen Bereich wieder aktivieren';

  @override
  String get spaceModalMenuCancel => 'Abbrechen';

  @override
  String get spaceModalSwitchFailed => 'Bereich konnte nicht gewechselt werden';

  @override
  String get spaceModalArchiveCurrent =>
      'Der aktuelle Bereich kann nicht archiviert werden. Wechseln Sie zuerst zu einem anderen Bereich.';

  @override
  String get spaceModalArchiveConfirmTitle => 'Bereich archivieren?';

  @override
  String spaceModalArchiveConfirmMessage(int itemCount) {
    return 'Dieser Bereich enthält $itemCount Einträge. Das Archivieren verbirgt den Bereich, behält aber alle Einträge bei. Sie können ihn später aus archivierten Bereichen wiederherstellen.';
  }

  @override
  String spaceModalArchiveSuccess(String spaceName) {
    return '$spaceName wurde archiviert';
  }

  @override
  String get spaceModalArchiveFailed =>
      'Bereich konnte nicht archiviert werden';

  @override
  String spaceModalRestoreSuccess(String spaceName) {
    return '$spaceName wurde wiederhergestellt';
  }

  @override
  String get spaceModalRestoreFailed =>
      'Bereich konnte nicht wiederhergestellt werden';

  @override
  String get createModalTitle => 'Erstellen';

  @override
  String get createModalTypeTodoList => 'Aufgabenliste';

  @override
  String get createModalTypeList => 'Liste';

  @override
  String get createModalTypeNote => 'Notiz';

  @override
  String get createModalTodoListNameHint => 'Name der Aufgabenliste';

  @override
  String get createModalListNameHint => 'Listenname';

  @override
  String get createModalNoteTitleHint => 'Notiz-Titel';

  @override
  String get createModalNoteContentHint => 'Notiz-Inhalt';

  @override
  String get createModalNoteSmartFieldHint =>
      'Notiz-Titel oder Inhalt...\n(Erste Zeile wird zum Titel)';

  @override
  String get createModalListStyleLabel => 'Listenstil';

  @override
  String get createModalListStyleBullets => 'Aufzählung';

  @override
  String get createModalListStyleNumbered => 'Nummeriert';

  @override
  String get createModalListStyleCheckboxes => 'Checkliste';

  @override
  String get createModalListStyleSimple => 'Einfach';

  @override
  String get createModalTodoDescriptionLabel => 'Beschreibung (optional)';

  @override
  String get createModalTodoDescriptionHint =>
      'Beschreibung hinzufügen (optional)';

  @override
  String get createModalTodoDescriptionAdd =>
      '+ Beschreibung hinzufügen (optional)';

  @override
  String get createModalTodoDescriptionTooLong =>
      'Beschreibung zu lang (max. 500 Zeichen)';

  @override
  String get createModalSaveToLabel => 'Speichern in: ';

  @override
  String get createModalKeyboardShortcutMac =>
      '⌘+Eingabe zum Erstellen • Esc zum Schließen';

  @override
  String get createModalKeyboardShortcutOther =>
      'Strg+Eingabe zum Erstellen • Esc zum Schließen';

  @override
  String get createModalButtonTodoList => 'Aufgabenliste erstellen';

  @override
  String get createModalButtonList => 'Liste erstellen';

  @override
  String get createModalButtonNote => 'Notiz erstellen';

  @override
  String get createModalButtonGeneric => 'Erstellen';

  @override
  String get createModalCloseTitle => 'Nicht gespeicherte Inhalte verwerfen?';

  @override
  String get createModalCloseMessage =>
      'Sie haben diesen Eintrag noch nicht erstellt. Möchten Sie ihn erstellen oder Ihre Änderungen verwerfen?';

  @override
  String get createModalCloseCancel => 'Abbrechen';

  @override
  String get createModalCloseDiscard => 'Verwerfen';

  @override
  String get createModalCloseCreate => 'Erstellen & Schließen';

  @override
  String get buttonAdd => 'Hinzufügen';

  @override
  String get buttonSave => 'Speichern';

  @override
  String get buttonCancel => 'Abbrechen';

  @override
  String get buttonDelete => 'Löschen';

  @override
  String get buttonClose => 'Schließen';

  @override
  String get buttonArchive => 'Archivieren';

  @override
  String get accessibilityCloseButton => 'Schließen';

  @override
  String get accessibilityAddDescription =>
      'Beschreibung hinzufügen, eingeklappt';

  @override
  String get accessibilityAddDescriptionHint =>
      'Tippen, um optionales Beschreibungsfeld hinzuzufügen';

  @override
  String get accessibilityRemoveDescription => 'Beschreibungsfeld entfernen';

  @override
  String get accessibilityCreateNewSpace => 'Neuen Bereich erstellen';

  @override
  String accessibilitySpaceItemCount(String spaceName, int itemCount) {
    return '$spaceName, $itemCount Einträge';
  }

  @override
  String get spaceSwitcherTitle => 'Bereich wechseln';

  @override
  String get spaceSwitcherSearchHint => 'Bereiche durchsuchen...';

  @override
  String spaceSwitcherErrorSwitch(String error) {
    return 'Bereich konnte nicht gewechselt werden: $error';
  }

  @override
  String get spaceSwitcherEmptyNoResults => 'Keine Bereiche gefunden';

  @override
  String get spaceSwitcherEmptyNoSpaces => 'Keine Bereiche verfügbar';

  @override
  String spaceSwitcherItemCount(int count) {
    return '$count Einträge';
  }

  @override
  String get spaceSwitcherMenuEdit => 'Bereich bearbeiten';

  @override
  String get spaceSwitcherMenuArchive => 'Bereich archivieren';

  @override
  String get spaceSwitcherMenuRestore => 'Bereich wiederherstellen';

  @override
  String get spaceSwitcherMenuCancel => 'Abbrechen';

  @override
  String get spaceSwitcherSubtitleSwitchFirst =>
      'Wechseln Sie zuerst zu einem anderen Bereich';

  @override
  String spaceSwitcherSubtitleContainsItems(int count) {
    return 'Dieser Bereich enthält $count Einträge';
  }

  @override
  String get spaceSwitcherSubtitleRestore => 'Diesen Bereich wieder aktivieren';

  @override
  String get spaceSwitcherDialogArchiveTitle => 'Bereich archivieren?';

  @override
  String spaceSwitcherDialogArchiveContent(int count) {
    return 'Dieser Bereich enthält $count Einträge. Das Archivieren verbirgt den Bereich, behält aber alle Einträge bei. Sie können ihn später aus archivierten Bereichen wiederherstellen.';
  }

  @override
  String spaceSwitcherSuccessArchived(String name) {
    return '$name wurde archiviert';
  }

  @override
  String spaceSwitcherSuccessRestored(String name) {
    return '$name wurde wiederhergestellt';
  }

  @override
  String spaceSwitcherErrorArchive(String error) {
    return 'Bereich konnte nicht archiviert werden: $error';
  }

  @override
  String spaceSwitcherErrorRestore(String error) {
    return 'Bereich konnte nicht wiederhergestellt werden: $error';
  }

  @override
  String get spaceSwitcherErrorCannotArchiveCurrent =>
      'Der aktuelle Bereich kann nicht archiviert werden. Wechseln Sie zuerst zu einem anderen Bereich.';

  @override
  String get spaceSwitcherBadgeArchived => 'Archiviert';

  @override
  String get spaceSwitcherToggleShowArchived => 'Archivierte Bereiche anzeigen';

  @override
  String get spaceSwitcherButtonCreateNew => 'Neuen Bereich erstellen';

  @override
  String get searchEmptyTitle => 'Keine Ergebnisse gefunden';

  @override
  String get searchEmptyMessage =>
      'Versuchen Sie andere Suchbegriffe oder überprüfen Sie die Rechtschreibung';

  @override
  String get searchBarHint => 'Notizen, Aufgaben, Listen durchsuchen...';

  @override
  String get searchClearButton => 'Löschen';

  @override
  String get searchScreenTitle => 'Suchen';

  @override
  String searchInCurrentSpace(String spaceName) {
    return 'In $spaceName suchen';
  }

  @override
  String get filterTodoItems => 'Todo-Einträge';

  @override
  String get filterListItems => 'Listeneinträge';

  @override
  String searchResultInTodoList(String todoListName) {
    return 'in $todoListName';
  }

  @override
  String searchResultInList(String listName) {
    return 'in $listName';
  }

  @override
  String get accessibilityDragHandleHint =>
      'Doppeltippen und halten zum Neuanordnen';

  @override
  String get navigationBottomHome => 'Startseite';

  @override
  String get navigationBottomHomeTooltip => 'Ihre Spaces anzeigen';

  @override
  String get navigationBottomHomeSemanticLabel => 'Startseite-Navigation';

  @override
  String get navigationBottomSearch => 'Suchen';

  @override
  String get navigationBottomSearchTooltip => 'Elemente suchen';

  @override
  String get navigationBottomSearchSemanticLabel => 'Such-Navigation';

  @override
  String get navigationBottomSettings => 'Einstellungen';

  @override
  String get navigationBottomSettingsTooltip => 'App-Einstellungen';

  @override
  String get navigationBottomSettingsSemanticLabel =>
      'Einstellungen-Navigation';

  @override
  String get dialogDeleteItemTitle => 'Element löschen?';

  @override
  String dialogDeleteItemMessage(String itemName) {
    return 'Möchten Sie \"$itemName\" wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String get authUpgradeBannerMessage =>
      'Erstellen Sie ein Konto, um Ihre Daten zu sichern';

  @override
  String get authUpgradeBannerButton => 'Konto erstellen';

  @override
  String get authUpgradeScreenTitle => 'Erstellen Sie Ihr Konto';

  @override
  String get authUpgradeScreenSubtitle =>
      'Upgraden Sie, um unbegrenzte Funktionen freizuschalten';

  @override
  String get authUpgradeEmailLabel => 'E-Mail';

  @override
  String get authUpgradePasswordLabel => 'Passwort';

  @override
  String get authUpgradeConfirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get authUpgradeSubmitButton => 'Konto erstellen';

  @override
  String get authUpgradeCancelButton => 'Vielleicht später';

  @override
  String get authUpgradeSuccessMessage => 'Konto erfolgreich erstellt!';

  @override
  String get buttonDismiss => 'Schließen';

  @override
  String get accessibilityWarning => 'Warnung';

  @override
  String get validationEmailRequired => 'E-Mail ist erforderlich';

  @override
  String get validationEmailInvalid =>
      'Bitte geben Sie eine gültige E-Mail ein';

  @override
  String get validationPasswordRequired => 'Passwort ist erforderlich';

  @override
  String get validationPasswordMinLength =>
      'Passwort muss mindestens 8 Zeichen lang sein';

  @override
  String get validationPasswordConfirmRequired =>
      'Bitte bestätigen Sie Ihr Passwort';

  @override
  String get validationPasswordsDoNotMatch =>
      'Passwörter stimmen nicht überein';

  @override
  String get errorUnexpected => 'Ein unerwarteter Fehler ist aufgetreten';

  @override
  String get authUpgradeDialogTitle => 'Upgrade erforderlich';

  @override
  String get authUpgradeDialogNotNow => 'Jetzt nicht';

  @override
  String get authUpgradeLimitSpaces =>
      'Anonyme Benutzer sind auf 1 Bereich beschränkt. Erstellen Sie ein Konto, um unbegrenzte Bereiche freizuschalten.';

  @override
  String get authUpgradeLimitNotes =>
      'Anonyme Benutzer sind auf 20 Notizen pro Bereich beschränkt. Erstellen Sie ein Konto, um unbegrenzte Notizen freizuschalten.';

  @override
  String get authUpgradeLimitTodoLists =>
      'Anonyme Benutzer sind auf 10 Todo-Listen pro Bereich beschränkt. Erstellen Sie ein Konto, um unbegrenzte Todo-Listen freizuschalten.';

  @override
  String get authUpgradeLimitLists =>
      'Anonyme Benutzer sind auf 5 benutzerdefinierte Listen pro Bereich beschränkt. Erstellen Sie ein Konto, um unbegrenzte Listen freizuschalten.';

  @override
  String get spaceModalTitleCreate => 'Bereich erstellen';

  @override
  String get spaceModalTitleEdit => 'Bereich bearbeiten';

  @override
  String get spaceModalButtonCreate => 'Erstellen';

  @override
  String get spaceModalButtonSave => 'Speichern';

  @override
  String get spaceModalLabelName => 'Bereichsname';

  @override
  String get spaceModalHintName => 'Bereichsnamen eingeben';

  @override
  String get spaceModalLabelIcon => 'Symbol';

  @override
  String get spaceModalLabelColor => 'Farbe';

  @override
  String get spaceModalValidationNameRequired => 'Name ist erforderlich';

  @override
  String get spaceModalValidationNameLength =>
      'Name muss zwischen 1 und 100 Zeichen lang sein';

  @override
  String get spaceModalErrorNotSignedIn =>
      'Sie sind nicht angemeldet. Bitte melden Sie sich an und versuchen Sie es erneut.';
}
