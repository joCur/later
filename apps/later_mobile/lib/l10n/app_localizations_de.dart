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
}
