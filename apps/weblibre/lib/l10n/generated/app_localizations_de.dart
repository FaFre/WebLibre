// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get common_cancel => 'Abbrechen';

  @override
  String get common_delete => 'Löschen';

  @override
  String get common_close => 'Schließen';

  @override
  String get common_save => 'Speichern';

  @override
  String get common_add => 'Hinzufügen';

  @override
  String get common_edit => 'Bearbeiten';

  @override
  String get common_remove => 'Entfernen';

  @override
  String get common_clear => 'Löschen';

  @override
  String get common_copy => 'Kopieren';

  @override
  String get common_open => 'Öffnen';

  @override
  String get common_reset => 'Zurücksetzen';

  @override
  String get common_retry => 'Erneut versuchen';

  @override
  String get common_done => 'Fertig';

  @override
  String get common_undo => 'Rückgängig';

  @override
  String get common_dismiss => 'Ausblenden';

  @override
  String get common_discard => 'Verwerfen';

  @override
  String get common_showLess => 'Weniger anzeigen';

  @override
  String get common_loading => 'Wird geladen …';

  @override
  String get profileCopy_pickerContents => 'Tabs, Verlauf und Einstellungen';

  @override
  String get profileCopy_dataDescription =>
      'Tabs, Verlauf, Lesezeichen, Einstellungen und gespeicherte Website-Zugangsdaten';

  @override
  String get profileCopy_secretDataDescription =>
      'Anmeldung beim WebLibre-Konto, Sync-Einrichtung und Proxy-Details';

  @override
  String get profileCopy_cannotBeUndone =>
      'Dies kann nicht rückgängig gemacht werden.';

  @override
  String get profileCopy_nothingChanged => 'Es wurde nichts geändert.';

  @override
  String get profileCopy_restartsToWork => 'WebLibre muss dafür neu starten.';

  @override
  String get profileCopy_asksPasswordAfterRestart =>
      'Nach dem Neustart fragt WebLibre nach dem Passwort der Sicherungsdatei.';

  @override
  String get profileCopy_reopenToContinue =>
      'WebLibre schließen und erneut öffnen.';

  @override
  String get profileCopy_signedInFromBackup =>
      'Das wiederhergestellte Profil verwendet das WebLibre-Konto aus der Sicherung.';

  @override
  String get profileCopy_olderBackupKeepsCredentials =>
      'Eine Sicherung aus einer älteren WebLibre-Version enthält nichts davon; das Profil behält dann die aktuellen Daten.';

  @override
  String profileCopy_restartCouldNotBeScheduled(String nothingChanged) {
    return 'WebLibre konnte den für diesen Vorgang nötigen Neustart nicht planen. $nothingChanged';
  }

  @override
  String get profileCopy_shortcutsNeedPinningAgain =>
      'Startbildschirm-Verknüpfungen nach der Wiederherstellung erneut anheften.';

  @override
  String get profileCopy_restartClosesCurrentProfile =>
      'Dabei wird auch das gerade verwendete Profil geschlossen – das ist nicht immer das hier genannte.';

  @override
  String get profileCopy_restartKeepsOtherTabs =>
      'Die übrigen Tabs werden danach wieder geöffnet.';

  @override
  String profileCopy_privateTabsClosedByRestart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count private Tabs werden geschlossen und ihre Browserdaten werden gelöscht.',
      one:
          '1 privater Tab wird geschlossen und seine Browserdaten werden gelöscht.',
    );
    return '$_temp0';
  }

  @override
  String profileCopy_containersClearedByRestart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Container, die Daten beim Beenden löschen, werden geleert.',
      one: '1 Container, der Daten beim Beenden löscht, wird geleert.',
    );
    return '$_temp0';
  }

  @override
  String get httpErrorHandler_socketError => 'Der Dienst ist nicht erreichbar';

  @override
  String get httpErrorHandler_httpError =>
      'Die Webanfrage hat einen Fehler zurückgegeben';

  @override
  String get httpErrorHandler_formatError => 'Ungültiges Antwortformat';

  @override
  String get httpErrorHandler_clientError => 'Der Dienst ist nicht erreichbar';

  @override
  String profileDiscovery_recoveredProfileName(String idFragment) {
    return 'Wiederhergestelltes Profil $idFragment';
  }

  @override
  String get about_copyright => 'Copyright © Fabian Freund, 2024-2026';

  @override
  String get about_geckoVersionTitle => 'Gecko-Version';

  @override
  String get about_notAvailable => 'k. A.';

  @override
  String get about_feedbackTitle => 'Feedback';

  @override
  String get about_donateTitle => 'Spenden';

  @override
  String get about_documentationTitle => 'Dokumentation';

  @override
  String get about_githubTitle => 'GitHub';

  @override
  String get account_screenTitle => 'WebLibre-Konto';

  @override
  String get account_searchHint => 'Kontoeinstellungen durchsuchen';

  @override
  String get account_loadFailed => 'Konto konnte nicht geladen werden';

  @override
  String get account_sectionAccount => 'Konto';

  @override
  String get account_sectionSubscription => 'Abonnement';

  @override
  String get account_sectionSearchCredits => 'Suchguthaben';

  @override
  String get account_sectionSettingsSnapshots => 'Einstellungs-Snapshots';

  @override
  String get account_sectionPreferencesSnapshots => 'Präferenz-Snapshots';

  @override
  String get account_sectionEncryptedSync => 'Verschlüsselte Synchronisierung';

  @override
  String get account_signInTitle => 'Beim WebLibre-Konto anmelden';

  @override
  String get account_signInKeywords =>
      'anmelden, einloggen, Konto, Authentifizierung, Login';

  @override
  String get account_signInSyncKeyKeywords =>
      'Sync-Schlüssel, Sync-Schlüssel zurücksetzen';

  @override
  String get account_signingInTitle => 'Anmeldung läuft';

  @override
  String get account_signedInTitle => 'Angemeldetes Konto';

  @override
  String get account_signInFailedTitle => 'Anmeldung fehlgeschlagen';

  @override
  String get account_syncAcrossDevicesSubtitle =>
      'Einstellungen geräteübergreifend synchronisieren';

  @override
  String get account_signingInSubtitle => 'Anmeldung im Browser abschließen';

  @override
  String get account_signedInFallback => 'Angemeldet';

  @override
  String get account_entrySupporterSubscriptionTitle => 'Supporter-Abonnement';

  @override
  String get account_entrySupporterSubscriptionKeywords =>
      'Abrechnung, Zahlung, Supporter, Unterstützer';

  @override
  String get account_entrySupporterSubscriptionSubtitle =>
      'Status, Abrechnung und Verwaltung des Abonnements';

  @override
  String get account_entrySearchCreditsTitle => 'Suchguthaben';

  @override
  String get account_entrySearchCreditsKeywords =>
      'Tokens, Suchpaket, Guthaben';

  @override
  String get account_entrySearchCreditsSubtitle =>
      'Guthabenstand, Token-Ausgabe und Käufe';

  @override
  String get account_entrySettingsSnapshotsTitle => 'Einstellungs-Snapshots';

  @override
  String get account_entrySettingsSnapshotsKeywords =>
      'Sicherungen, Backups, Einstellungen synchronisieren';

  @override
  String get account_entrySettingsSnapshotsSubtitle =>
      'Synchronisierte App-Einstellungen speichern und wiederherstellen';

  @override
  String get account_entryPreferencesSnapshotsTitle => 'Präferenz-Snapshots';

  @override
  String get account_entryPreferencesSnapshotsKeywords =>
      'Sicherungen, Backups, Prefs synchronisieren';

  @override
  String get account_entryPreferencesSnapshotsSubtitle =>
      'Synchronisierte Präferenzdokumente speichern und wiederherstellen';

  @override
  String get account_entrySetupEncryptedSyncTitle =>
      'Verschlüsselte Synchronisierung einrichten';

  @override
  String get account_entrySetupEncryptedSyncKeywords =>
      'Sync-Schlüssel, Sicherungen, Snapshots';

  @override
  String get account_entrySetupEncryptedSyncSubtitle =>
      'Ende-zu-Ende-verschlüsselte Synchronisierung mit dem Kontopasswort aktivieren';

  @override
  String get account_actionRestore => 'Wiederherstellen';

  @override
  String get account_actionEditLabel => 'Bezeichnung bearbeiten';

  @override
  String get account_actionStore => 'Speichern';

  @override
  String get account_actionTryAgain => 'Erneut versuchen';

  @override
  String get account_actionSignOut => 'Abmelden';

  @override
  String get account_actionEnableSync => 'Synchronisierung aktivieren';

  @override
  String get account_adoptTitleUsable =>
      'Eine ältere Anmeldung ist noch auf diesem Gerät';

  @override
  String get account_adoptTitleUnusable =>
      'Eine ältere Anmeldung kann nicht gelesen werden';

  @override
  String account_adoptBodyUsable(String name) {
    return 'WebLibre hat eine Anmeldung für $name aus der Zeit aufbewahrt, bevor Profile getrennte Konten hatten. Sie stammt nicht aus einer Sicherung, und nichts auf diesem Gerät verrät, zu welchem Profil sie gehörte – deshalb rät WebLibre nicht.';
  }

  @override
  String get account_adoptBodyUnusable =>
      'WebLibre hat eine Anmeldung aus der Zeit aufbewahrt, bevor Profile getrennte Konten hatten, aber die gespeicherten Daten sind beschädigt und können nicht zur Anmeldung verwendet werden. Nur eine erneute Anmeldung hilft weiter; durch Entfernen verschwindet diese Meldung.';

  @override
  String get account_adoptRetryError =>
      'Das hat nicht funktioniert. Verbindung prüfen und erneut versuchen.';

  @override
  String get account_adoptNotMine => 'Gehört nicht mir';

  @override
  String get account_adoptRemoveIt => 'Entfernen';

  @override
  String get account_adoptUseItHere => 'Hier verwenden';

  @override
  String get account_forgetSignInTitle => 'Diese Anmeldung vergessen?';

  @override
  String account_forgetSignInContent(String name) {
    return 'Die gespeicherte Sitzung für $name wird von diesem Gerät gelöscht. Gehörte sie zu einem anderen Profil, ist dort eine erneute Anmeldung nötig.';
  }

  @override
  String get account_actionForgetIt => 'Vergessen';

  @override
  String get account_previousSignInFallback => 'ein früheres Konto';

  @override
  String account_signInAgainAs(String account) {
    return 'Erneut als $account anmelden';
  }

  @override
  String get account_signInExpiredSubtitle =>
      'Die gespeicherte Anmeldung dieses Profils ist abgelaufen. Der Sync-Schlüssel bleibt erhalten.';

  @override
  String get account_signingInEllipsis => 'Anmeldung läuft …';

  @override
  String get account_completeSignInInApp => 'Anmeldung in WebLibre abschließen';

  @override
  String get account_tooltipSignOut => 'Abmelden';

  @override
  String get account_signOutConfirmTitle => 'Abmelden?';

  @override
  String get account_signOutConfirmContent => 'Vom WebLibre-Konto abmelden?';

  @override
  String get account_resetSyncKeyTitle => 'Sync-Schlüssel zurücksetzen';

  @override
  String get account_resetSyncKeySubtitle =>
      'Passwort erneut eingeben, falls es falsch eingegeben oder geändert wurde';

  @override
  String get account_resetSyncKeyConfirmContent =>
      'Das Kontopasswort muss erneut eingegeben werden. Wurde das Passwort geändert, lassen sich vorhandene, mit dem alten Passwort verschlüsselte Snapshots nicht mehr entschlüsseln.';

  @override
  String get account_subscriptionLoadFailed =>
      'Abonnement konnte nicht geladen werden';

  @override
  String get account_checkConnectionRetry =>
      'Verbindung prüfen und erneut versuchen.';

  @override
  String get account_planFallbackSupporter => 'Supporter';

  @override
  String get account_badgeWillNotRenew => 'Wird nicht verlängert';

  @override
  String get account_badgeActive => 'Aktiv';

  @override
  String account_untilDate(String date) {
    return 'Bis $date';
  }

  @override
  String get account_actionManageSubscription => 'Abonnement verwalten';

  @override
  String get account_badgePaused => 'Pausiert';

  @override
  String get account_pausedNote =>
      'Das Abonnement ist pausiert. Zum Wiederherstellen des Zugangs im Kundenportal fortsetzen.';

  @override
  String get account_badgePastDue => 'Überfällig';

  @override
  String get account_pastDueNote =>
      'Zahlung fehlgeschlagen. Zahlungsmethode aktualisieren, damit das Abonnement aktiv bleibt.';

  @override
  String get account_actionUpdatePaymentMethod =>
      'Zahlungsmethode aktualisieren';

  @override
  String get account_endedNote =>
      'Das Abonnement ist beendet. Zum Fortfahren im Kundenportal verlängern.';

  @override
  String get account_actionRenewSubscription => 'Abonnement verlängern';

  @override
  String get account_planSupporterSubscription => 'Supporter-Abonnement';

  @override
  String get account_subscribeSubtitle =>
      'Abonnieren, um Sync-Funktionen freizuschalten';

  @override
  String get account_badgeInactive => 'Inaktiv';

  @override
  String get account_actionSubscribe => 'Abonnieren';

  @override
  String get account_tooltipRefreshStatus => 'Status aktualisieren';

  @override
  String account_subscriptionEndsOn(String date) {
    return 'Das Abonnement endet am $date';
  }

  @override
  String get account_bannerTitle => 'WebLibre unterstützen';

  @override
  String get account_bannerBody =>
      'Supporter ist ein optionales Abonnement, das die Entwicklung von WebLibre finanziert und die Funktionen bereitstellt, die einen gehosteten Dienst benötigen. Der Browser und seine Datenschutzfunktionen brauchen kein Abonnement. <learnMore>Mehr erfahren</learnMore>.';

  @override
  String get account_featureSearchLabel => 'WebLibre Search';

  @override
  String get account_featureSearchDescription =>
      'Eine private, werbefreie Suche direkt im Browser. Sie kombiniert Ergebnisse aus mehreren unabhängigen Quellen, bietet anpassbare Suchmodi, kann über Tor laufen und zeigt Seiten sicher in der Vorschau an. Suchanfragen lassen sich dabei konstruktionsbedingt nicht mit dem Konto verknüpfen.';

  @override
  String get account_featureSyncLabel => 'Verschlüsselte Kontosynchronisierung';

  @override
  String get account_featureSyncDescription =>
      'WebLibre-Einstellungen und -Präferenzen profil- und geräteübergreifend speichern und wiederherstellen. Alles wird vor dem Hochladen auf dem Gerät verschlüsselt und ist nur für den eigenen Zugriff lesbar.';

  @override
  String get account_becomeSupporter => 'Supporter werden';

  @override
  String get account_syncSetupEnterPassword => 'Bitte Passwort eingeben';

  @override
  String get account_syncSetupPasswordsMismatch =>
      'Die Passwörter stimmen nicht überein';

  @override
  String get account_syncSetupPasswordMismatchBackup =>
      'Das Passwort passt nicht zu den vorhandenen verschlüsselten Sicherungen.';

  @override
  String account_syncSetupFailed(String error) {
    return 'Synchronisierung konnte nicht eingerichtet werden: $error';
  }

  @override
  String get account_syncSetupTitle =>
      'Verschlüsselte Synchronisierung einrichten';

  @override
  String get account_syncSetupDescription =>
      'Zum Aktivieren der Ende-zu-Ende-verschlüsselten Synchronisierung das Kontopasswort eingeben. Die Daten werden vor dem Hochladen auf dem Gerät verschlüsselt – der Server sieht die Einstellungen nie.';

  @override
  String get account_fieldAccountPassword => 'Kontopasswort';

  @override
  String get account_fieldConfirmPassword => 'Passwort bestätigen';

  @override
  String account_failedLoadSnapshots(String error) {
    return 'Snapshots konnten nicht geladen werden: $error';
  }

  @override
  String account_syncKindStored(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': 'Einstellungen gespeichert',
      'geckoUserJs': 'Gecko-Prefs gespeichert',
      'other': 'Snapshot gespeichert',
    });
    return '$_temp0';
  }

  @override
  String account_syncKindSnapshotsTitle(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': 'Einstellungs-Snapshots',
      'geckoUserJs': 'Gecko-Prefs-Snapshots',
      'other': 'Snapshots',
    });
    return '$_temp0';
  }

  @override
  String get account_storeCurrentTitle => 'Aktuellen Stand speichern';

  @override
  String account_storeCurrentSubtitle(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings':
          'Die aktuellen Einstellungen verschlüsseln und hochladen',
      'geckoUserJs': 'Die aktuellen Gecko-Prefs verschlüsseln und hochladen',
      'other': 'Die aktuellen Daten verschlüsseln und hochladen',
    });
    return '$_temp0';
  }

  @override
  String get account_noSnapshotsYet => 'Noch keine Snapshots gespeichert';

  @override
  String account_failedToStore(String error) {
    return 'Speichern fehlgeschlagen: $error';
  }

  @override
  String account_syncKindRestored(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': 'Einstellungen wiederhergestellt',
      'geckoUserJs': 'Gecko-Prefs wiederhergestellt',
      'other': 'Snapshot wiederhergestellt',
    });
    return '$_temp0';
  }

  @override
  String get account_snapshotNotFound => 'Snapshot nicht gefunden';

  @override
  String get account_decryptionFailed =>
      'Entschlüsselung fehlgeschlagen – falsches Passwort oder beschädigte Daten. Den Sync-Schlüssel zurückzusetzen kann helfen.';

  @override
  String account_failedToRestore(String error) {
    return 'Wiederherstellen fehlgeschlagen: $error';
  }

  @override
  String account_failedUpdateLabel(String error) {
    return 'Bezeichnung konnte nicht aktualisiert werden: $error';
  }

  @override
  String get account_snapshotDeleted => 'Snapshot gelöscht';

  @override
  String account_failedToDelete(String error) {
    return 'Löschen fehlgeschlagen: $error';
  }

  @override
  String get account_untitledSnapshot => 'Unbenannt';

  @override
  String get account_metaLabel => 'Bezeichnung';

  @override
  String get account_metaStored => 'Gespeichert';

  @override
  String get account_metaAppVersion => 'App-Version';

  @override
  String get account_metaDevice => 'Gerät';

  @override
  String get account_storeSnapshotTitle => 'Snapshot speichern';

  @override
  String get account_fieldLabelOptional => 'Bezeichnung (optional)';

  @override
  String get account_labelHintExample =>
      'z. B. „Vor dem Update“, „Einrichtung zu Hause“';

  @override
  String get account_fieldLabel => 'Bezeichnung';

  @override
  String get account_restoreSnapshotTitle => 'Snapshot wiederherstellen';

  @override
  String get account_restoreOverwriteWarning =>
      'Dadurch werden die aktuellen lokalen Einstellungen überschrieben.';

  @override
  String get account_thisSnapshotFallback => 'diesen Snapshot';

  @override
  String get account_deleteSnapshotTitle => 'Snapshot löschen';

  @override
  String account_deleteSnapshotConfirm(String label) {
    return 'Wirklich $label löschen?';
  }

  @override
  String get account_authNetworkError =>
      'Netzwerkfehler. Bitte Verbindung prüfen und erneut versuchen.';

  @override
  String get account_authSessionExpiredWithKey =>
      'Die gespeicherte Anmeldung ist nicht mehr gültig. Zum Abschließen der Wiederherstellung dieses Kontos erneut anmelden – der Sync-Schlüssel bleibt erhalten.';

  @override
  String get account_authSessionExpiredNoKey =>
      'Die gespeicherte Anmeldung ist nicht mehr gültig. Zum Fortfahren erneut anmelden.';

  @override
  String get account_authRestoreFailedFallback =>
      'Die Kontositzung konnte nicht wiederhergestellt werden. In Kürze wird es erneut versucht.';

  @override
  String get account_authSignInTimedOut =>
      'Zeitüberschreitung bei der Anmeldung. Bitte erneut versuchen.';

  @override
  String get account_authSignInOpenPageFailed =>
      'Die Anmeldeseite konnte nicht geöffnet werden. Bitte erneut versuchen.';

  @override
  String get account_authNoPendingSignIn =>
      'Keine laufende Anmeldung gefunden. Bitte die Anmeldung neu starten.';

  @override
  String get account_authSignInVerificationFailed =>
      'Die Anmeldung konnte nicht bestätigt werden. Bitte erneut versuchen.';

  @override
  String get account_authSignInNotCompleted =>
      'Die Anmeldung konnte nicht abgeschlossen werden. Bitte erneut versuchen.';

  @override
  String get account_authSignInFailedFallback =>
      'Anmeldung fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get addons_managerTitle => 'Erweiterungen';

  @override
  String get addons_tabInstalled => 'Installiert';

  @override
  String get addons_tabBrowse => 'Durchsuchen';

  @override
  String get addons_loadFailedTitle =>
      'Erweiterungen konnten nicht geladen werden';

  @override
  String get addons_noExtensionsFound => 'Keine Erweiterungen gefunden.';

  @override
  String get addons_noneInstalledMessage =>
      'Noch keine Erweiterungen installiert.\nIm Store lassen sich welche finden.';

  @override
  String get addons_genericTitle => 'Erweiterung';

  @override
  String get addons_notFound => 'Diese Erweiterung wurde nicht gefunden.';

  @override
  String get addons_platformAndroid => 'Android';

  @override
  String get addons_platformDesktop => 'Desktop';

  @override
  String get addons_searchHint => 'addons.mozilla.org durchsuchen';

  @override
  String get addons_desktopCompatibilityWarning =>
      'Desktop-Erweiterungen werden nicht für Mobilgeräte geprüft. Manche funktionieren unter Android womöglich nicht, stürzen ab oder verhalten sich unerwartet.';

  @override
  String get addons_actionInstall => 'Installieren';

  @override
  String get addons_actionInstallExtension => 'Erweiterung installieren';

  @override
  String get addons_actionInstallFromFile => 'Aus Datei installieren';

  @override
  String get addons_actionViewPermissions => 'Berechtigungen anzeigen';

  @override
  String get addons_actionRemoveExtension => 'Erweiterung entfernen';

  @override
  String get addons_actionNotNow => 'Nicht jetzt';

  @override
  String get addons_actionUpdate => 'Aktualisieren';

  @override
  String get addons_actionCheckForUpdates => 'Nach Updates suchen';

  @override
  String get addons_actionCheckForUpdatesButton => 'Nach Updates suchen';

  @override
  String get addons_actionCheckingForUpdates => 'Suche nach Updates …';

  @override
  String get addons_actionLearnMore => 'Mehr erfahren';

  @override
  String get addons_actionReadMore => 'Mehr lesen';

  @override
  String get addons_sectionEnabled => 'Aktiviert';

  @override
  String get addons_sectionDisabled => 'Deaktiviert';

  @override
  String get addons_sectionUnsupported => 'Nicht unterstützt';

  @override
  String get addons_sectionDetails => 'Details';

  @override
  String get addons_sectionDescription => 'Beschreibung';

  @override
  String get addons_sectionManagement => 'Verwaltung';

  @override
  String get addons_sectionUpdates => 'Updates';

  @override
  String get addons_sectionAboutExtension => 'Über diese Erweiterung';

  @override
  String get addons_sectionTechnicalPermissions => 'Technische Berechtigungen';

  @override
  String get addons_sectionMoreInformation => 'Weitere Informationen';

  @override
  String get addons_requiredDataCollectionTitle =>
      'Erforderliche Datenerfassung';

  @override
  String get addons_tooltipRemoveExtension => 'Erweiterung entfernen';

  @override
  String addons_extensionRemoved(String name) {
    return '$name entfernt';
  }

  @override
  String addons_extensionInstalled(String name) {
    return '$name installiert';
  }

  @override
  String addons_installFailed(String error) {
    return 'Installation fehlgeschlagen: $error';
  }

  @override
  String get addons_updateChecksStarted =>
      'Update-Prüfung für installierte Erweiterungen im Hintergrund gestartet';

  @override
  String get addons_statusInstalled => 'Installiert';

  @override
  String get addons_statusDisabled => 'Deaktiviert';

  @override
  String get addons_statusAvailable => 'Verfügbar';

  @override
  String get addons_chipPrivateBrowsing => 'Privates Surfen';

  @override
  String get addons_chipRecommended => 'Empfohlen';

  @override
  String get addons_removeConfirmTitle => 'Erweiterung entfernen?';

  @override
  String addons_removeConfirmContent(String name) {
    return '$name aus WebLibre entfernen?';
  }

  @override
  String get addons_autoUpdateGloballyDisabled =>
      'Automatische Updates sind global deaktiviert.';

  @override
  String get addons_autoUpdateNeedsManualRun =>
      'Bevor automatische Updates aktiviert werden können, einmal manuell aktualisieren und die App neu starten.';

  @override
  String get addons_autoUpdateAllow =>
      'Dieser Erweiterung Updates im Hintergrund erlauben.';

  @override
  String get addons_autoUpdateDisabledForExtension =>
      'Updates im Hintergrund sind für diese Erweiterung deaktiviert.';

  @override
  String get addons_switchEnabledTitle => 'Aktiviert';

  @override
  String get addons_switchEnabledSubtitleAllow =>
      'Diese Erweiterung in WebLibre ausführen lassen.';

  @override
  String get addons_switchEnabledSubtitleCannot =>
      'Diese Erweiterung kann nicht sicher aktiviert werden.';

  @override
  String get addons_switchPrivateBrowsingTitle => 'In privaten Tabs erlauben';

  @override
  String get addons_switchPrivateBrowsingSubtitle =>
      'Diese Erweiterung in privaten Tabs ausführen lassen.';

  @override
  String get addons_switchAutoUpdateTitle => 'Automatische Updates';

  @override
  String get addons_switchPinTitle => 'An Symbolleiste anheften';

  @override
  String get addons_switchPinSubtitle =>
      'Diese Erweiterung als Symbol in der Haupt-Tableiste anzeigen.';

  @override
  String get addons_menuExtensionSettingsTitle =>
      'Einstellungen der Erweiterung';

  @override
  String get addons_menuExtensionSettingsSubtitleTab =>
      'Die Einstellungsseite der Erweiterung in einem Browser-Tab öffnen';

  @override
  String get addons_menuExtensionSettingsSubtitleInline =>
      'Die Einstellungsseite der Erweiterung öffnen';

  @override
  String get addons_menuFilterListsTitle => 'Filterlisten & Härtungen';

  @override
  String get addons_menuFilterListsSubtitle =>
      'Filterlisten verwalten und WebLibre-Härtungen anwenden';

  @override
  String get addons_permissionsTitle => 'Berechtigungen';

  @override
  String addons_updateAvailable(String from, String to) {
    return 'Update verfügbar: $from → $to';
  }

  @override
  String get addons_noUpdateAttemptYet =>
      'Es liegen noch keine Informationen zu Update-Versuchen vor.';

  @override
  String addons_lastChecked(String date) {
    return 'Zuletzt geprüft: $date';
  }

  @override
  String get addons_noUpdateAvailable => 'Kein Update verfügbar';

  @override
  String get addons_noRemoteUpdateSource =>
      'Diese lokal installierte Erweiterung hat keine Online-Updatequelle.';

  @override
  String get addons_updateCheckFailed =>
      'Update-Prüfung konnte nicht gestartet werden.';

  @override
  String get addons_updateAvailableDialogTitle => 'Update verfügbar';

  @override
  String addons_updateConfirmContent(String name, String from, String to) {
    return '$name von $from auf $to aktualisieren?';
  }

  @override
  String get addons_noDescriptionProvided => 'Keine Beschreibung vorhanden.';

  @override
  String get addons_loadingDescription => 'Beschreibung wird geladen …';

  @override
  String get addons_fieldAuthor => 'Autor';

  @override
  String get addons_fieldVersion => 'Version';

  @override
  String get addons_fieldLastUpdated => 'Zuletzt aktualisiert';

  @override
  String get addons_fieldLastUpdatedInfo => 'Zuletzt aktualisiert';

  @override
  String get addons_fieldHomepage => 'Website';

  @override
  String get addons_fieldAddonListing => 'Store-Eintrag';

  @override
  String get addons_fieldSize => 'Größe';

  @override
  String get addons_fieldCategories => 'Kategorien';

  @override
  String get addons_fieldLicense => 'Lizenz';

  @override
  String get addons_fieldSupportSite => 'Support-Website';

  @override
  String get addons_fieldReviews => 'Bewertungen';

  @override
  String get addons_fieldPrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get addons_linkViewOnAmo => 'Auf addons.mozilla.org ansehen';

  @override
  String get addons_settingsTitleGeneric => 'Erweiterungsoptionen';

  @override
  String addons_settingsTitleNamed(String name) {
    return 'Einstellungen von $name';
  }

  @override
  String addons_settingsLoadFailed(String error) {
    return 'Einstellungen der Erweiterung konnten nicht geladen werden: $error';
  }

  @override
  String get addons_noSettingsPage =>
      'Diese Erweiterung bietet keine Einstellungsseite.';

  @override
  String get addons_permissionsTitleGeneric => 'Berechtigungen';

  @override
  String addons_permissionsTitleNamed(String name) {
    return 'Berechtigungen von $name';
  }

  @override
  String addons_permissionsLoadFailed(String error) {
    return 'Berechtigungen der Erweiterung konnten nicht geladen werden: $error';
  }

  @override
  String get addons_noSpecialPermissions =>
      'Keine besonderen Berechtigungen aufgeführt';

  @override
  String get addons_noTranslatedPermissionDetails =>
      'Diese Erweiterung stellt derzeit keine übersetzten Berechtigungsdetails bereit.';

  @override
  String addons_versionSentence(String version) {
    return 'Version $version';
  }

  @override
  String addons_usersCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Nutzer',
      one: '1 Nutzer',
    );
    return '$_temp0';
  }

  @override
  String addons_byAuthor(String name) {
    return 'von $name';
  }

  @override
  String get addons_permGroupRequired => 'Erforderlich';

  @override
  String get addons_permGroupWebsites => 'Websites';

  @override
  String get addons_permGroupOptional => 'Optional';

  @override
  String get addons_permGroupDataCollection => 'Datenerfassung';

  @override
  String get addons_dateUnknown => 'Unbekannt';

  @override
  String get addons_statusUpdatedSuccessfully => 'Erfolgreich aktualisiert';

  @override
  String get addons_statusNotInstalled => 'Erweiterung nicht installiert';

  @override
  String addons_updateFailedWithMessage(String message) {
    return 'Update fehlgeschlagen: $message';
  }

  @override
  String get addons_updateFailedGeneric => 'Update fehlgeschlagen';

  @override
  String get addons_noUpdateChecksRecorded =>
      'Noch keine Update-Prüfungen erfasst';

  @override
  String get addons_statusBlocklisted =>
      'Diese Erweiterung wurde gesperrt und sollte deaktiviert bleiben.';

  @override
  String get addons_statusNotCorrectlySigned =>
      'Diese Erweiterung ist nicht korrekt signiert und kann nicht sicher aktiviert werden.';

  @override
  String get addons_statusIncompatible =>
      'Diese Erweiterung ist mit der aktuellen App-Version nicht kompatibel.';

  @override
  String get addons_statusSoftBlockedEnabled =>
      'Diese Erweiterung ist eingeschränkt gesperrt. Solange sie aktiviert bleibt, ist Vorsicht geboten.';

  @override
  String get addons_statusSoftBlockedDisabled =>
      'Diese Erweiterung ist eingeschränkt gesperrt, kann aber wieder aktiviert werden.';

  @override
  String get addons_statusUnsupported =>
      'Diese Erweiterung ist installiert, wird von WebLibre derzeit aber nicht unterstützt.';

  @override
  String get addons_permissionBookmarks => 'Lesezeichen lesen und ändern';

  @override
  String get addons_permissionBrowserSettings =>
      'Browsereinstellungen lesen und ändern';

  @override
  String get addons_permissionBrowsingData =>
      'Neuesten Browserverlauf, Cookies und zugehörige Daten löschen';

  @override
  String get addons_permissionClipboardRead =>
      'Kopierte und eingefügte Daten lesen';

  @override
  String get addons_permissionClipboardWrite =>
      'Daten in die Zwischenablage schreiben';

  @override
  String get addons_permissionContextualIdentities =>
      'Auf Container-Tabs zugreifen und diese ändern';

  @override
  String get addons_permissionCookies =>
      'Auf Cookies besuchter Websites zugreifen';

  @override
  String get addons_permissionDownloads =>
      'Dateien herunterladen und den Download-Verlauf lesen und ändern';

  @override
  String get addons_permissionDownloadsOpen =>
      'Auf das Gerät heruntergeladene Dateien öffnen';

  @override
  String get addons_permissionFind => 'Den Text aller offenen Tabs lesen';

  @override
  String get addons_permissionGeolocation => 'Auf den Standort zugreifen';

  @override
  String get addons_permissionHistory => 'Auf den Browserverlauf zugreifen';

  @override
  String get addons_permissionManagement =>
      'Nutzung von Erweiterungen überwachen und Themes verwalten';

  @override
  String get addons_permissionNativeMessaging =>
      'Nachrichten mit anderen Programmen als dem Browser austauschen';

  @override
  String get addons_permissionNotifications => 'Benachrichtigungen anzeigen';

  @override
  String get addons_permissionPkcs11 =>
      'Kryptografische Authentifizierungsdienste bereitstellen';

  @override
  String get addons_permissionPrivacy =>
      'Datenschutzeinstellungen lesen und ändern';

  @override
  String get addons_permissionProxy =>
      'Proxy-Einstellungen des Browsers steuern';

  @override
  String get addons_permissionSessions =>
      'Auf kürzlich geschlossene Tabs zugreifen';

  @override
  String get addons_permissionTabs => 'Auf Browser-Tabs zugreifen';

  @override
  String get addons_permissionTabHide => 'Browser-Tabs aus- und einblenden';

  @override
  String get addons_permissionTopSites => 'Auf den Browserverlauf zugreifen';

  @override
  String get addons_permissionWebNavigation =>
      'Während der Navigation auf Browseraktivität zugreifen';

  @override
  String get addons_permissionAllUrls => 'Auf Daten aller Websites zugreifen';

  @override
  String addons_permissionAccessDataFor(String host) {
    return 'Auf Daten für $host zugreifen';
  }

  @override
  String appLinks_bannerTitleNamed(String appName) {
    return 'Diesen Link in $appName öffnen?';
  }

  @override
  String get appLinks_bannerTitleGeneric => 'Diesen Link in einer App öffnen?';

  @override
  String appLinks_bannerRememberFor(String scope) {
    return 'Für $scope merken';
  }

  @override
  String get appLinks_bannerStayInBrowser => 'Im Browser bleiben';

  @override
  String get appLinks_bannerOpenApp => 'App öffnen';

  @override
  String appLinks_dialogTitleNamed(String appName) {
    return 'In $appName öffnen?';
  }

  @override
  String get appLinks_dialogTitleGeneric => 'In einer anderen App öffnen?';

  @override
  String get appLinks_dialogBody =>
      'Dieser Link wird von einer App außerhalb von WebLibre verarbeitet.';

  @override
  String appLinks_dialogRememberFor(String scope) {
    return 'Auswahl für $scope merken';
  }

  @override
  String get appLinks_warningProtectedContext =>
      'Dieser Link ist hier geschützt. Die App baut eine eigene Verbindung auf, außerhalb der Regeln, die für diesen Tab gelten.';

  @override
  String get appLinks_warningPrivateTab =>
      'Dies ist ein privater Tab. Die App führt einen eigenen Verlauf und bleibt angemeldet.';

  @override
  String get appLinks_warningWallet =>
      'Dieser Link fordert Zugangsdaten von einer Wallet-App an. Nur öffnen, wenn die Anfrage selbst ausgelöst wurde.';

  @override
  String appLinks_settingsTitleWithContainer(String containerName) {
    return 'App-Links – $containerName';
  }

  @override
  String get appLinks_settingsTitleDefault => 'App-Links des Containers';

  @override
  String get appLinks_settingsIntro =>
      'Diese Einstellungen gelten nur für diesen Container und ersetzen für seine Tabs vollständig die globalen App-Link-Einstellungen.';

  @override
  String get appLinks_modeAlwaysTitle => 'Immer';

  @override
  String get appLinks_modeAlwaysSubtitle =>
      'Links immer ohne Nachfrage in ihren nativen Apps öffnen';

  @override
  String get appLinks_modeAskTitle => 'Vor dem Öffnen fragen';

  @override
  String get appLinks_modeAskSubtitle =>
      'Vor dem Öffnen von Links in Apps nachfragen';

  @override
  String get appLinks_modeNeverTitle => 'Nie';

  @override
  String get appLinks_modeNeverSubtitle =>
      'Links immer im Browser statt in Apps öffnen';

  @override
  String get appLinks_rememberedRulesHeader => 'Gespeicherte Website-Regeln';

  @override
  String get appLinks_ruleAlwaysOpenSubtitle => 'Immer in der App öffnen';

  @override
  String get appLinks_ruleAlwaysKeepSubtitle => 'Immer im Browser behalten';

  @override
  String get appLinks_removeRuleTooltip => 'Regel entfernen';

  @override
  String get bangs_menuTitle => 'Bangs';

  @override
  String get bangs_menuManageUserBangs => 'Eigene Bangs verwalten';

  @override
  String get bangs_menuSearchBangs => 'Bangs durchsuchen';

  @override
  String get bangs_menuBrowseCategories => 'Kategorien durchsuchen';

  @override
  String get bangs_categoriesTitle => 'Bang-Kategorien';

  @override
  String get bangs_loadCategoriesFailedTitle =>
      'Bang-Kategorien konnten nicht geladen werden';

  @override
  String get bangs_loadBangsFailedTitle => 'Bangs konnten nicht geladen werden';

  @override
  String get bangs_searchHint => 'Suchen';

  @override
  String get bangs_searchFailedTitle => 'Bang-Suche fehlgeschlagen';

  @override
  String get bangs_userBangsTitle => 'Eigene Bangs';

  @override
  String get bangs_deleteBangTitle => 'Bang löschen';

  @override
  String get bangs_deleteBangConfirm => 'Diesen Bang löschen?';

  @override
  String get bangs_editTitleCustomize => 'Bang anpassen';

  @override
  String get bangs_editTitleNew => 'Neuer Bang';

  @override
  String get bangs_editTitleEdit => 'Bang bearbeiten';

  @override
  String bangs_triggerAlreadyExists(String trigger) {
    return 'Ein Bang mit dem Auslöser „$trigger“ existiert bereits';
  }

  @override
  String get bangs_fieldNameLabel => 'Name';

  @override
  String get bangs_fieldNameHelper =>
      'Der Name der Website, zu der der Bang gehört';

  @override
  String get bangs_fieldTriggerLabel => 'Auslöser';

  @override
  String get bangs_fieldTriggerHelper =>
      'Das Wort oder die Wortgruppe zum Aufrufen des Bangs.';

  @override
  String get bangs_fieldAdditionalTriggersLabel => 'Weitere Auslöser';

  @override
  String get bangs_fieldAdditionalTriggersHelper =>
      'Weitere Wörter, die diesen Bang aufrufen, getrennt durch Kommas oder Leerzeichen. Ein vorangestelltes ! ist optional.';

  @override
  String get bangs_fieldUrlLabel => 'URL';

  @override
  String bangs_fieldUrlHelper(String token) {
    return 'Die URL-Vorlage für den Aufruf des Bangs; `$token` wird durch die Suchanfrage ersetzt.';
  }

  @override
  String bangs_fieldUrlMissingPlaceholder(String token) {
    return 'Muss den Platzhalter für die Suchanfrage $token enthalten';
  }

  @override
  String get bangs_fieldCategoryLabel => 'Kategorie';

  @override
  String get bangs_fieldSubCategoryLabel => 'Unterkategorie';

  @override
  String get bangs_flagsLabel => 'Optionen';

  @override
  String get bangs_flagOpenBasePathTitle => 'Basispfad öffnen';

  @override
  String get bangs_flagOpenBasePathSubtitle =>
      'Wird der Bang ohne Suchanfrage aufgerufen, öffnet er den Basispfad der URL (/) statt des Pfads aus der Vorlage (z. B. /search)';

  @override
  String get bangs_flagUrlEncodePlaceholderTitle => 'Platzhalter URL-kodieren';

  @override
  String get bangs_flagUrlEncodePlaceholderSubtitle =>
      'Suchbegriffe URL-kodieren. Manche Websites funktionieren nicht mit kodierten Begriffen – für diese Websites die Option deaktivieren.';

  @override
  String get bangs_flagUrlEncodeSpaceToPlusTitle =>
      'Leerzeichen als Plus kodieren';

  @override
  String get bangs_flagUrlEncodeSpaceToPlusSubtitle =>
      'Leerzeichen als + statt als %20 kodieren. Manche Websites erfordern das eine oder das andere Format.';

  @override
  String get bangs_tooltipOfficialSearch => 'Offizielle WebLibre-Suche';

  @override
  String get bangs_tooltipCustomizeAsOwn => 'Als eigenen Bang anpassen';

  @override
  String get bangs_tooltipUnpin => 'Von Suchanbietern lösen';

  @override
  String get bangs_tooltipPin => 'An Suchanbieter anheften';

  @override
  String bangs_tooltipTriggers(String triggers) {
    return 'Auslöser: $triggers';
  }

  @override
  String get browserActions_categoryNavigation => 'Navigation';

  @override
  String get browserActions_categoryScrolling => 'Scrollen';

  @override
  String get browserActions_categoryTabs => 'Tabs';

  @override
  String get browserActions_categoryPage => 'Seite';

  @override
  String get browserActions_categoryOpen => 'Öffnen';

  @override
  String get browserActions_categoryApp => 'App';

  @override
  String get browserActions_focusAddressBarTitle => 'Adressleiste';

  @override
  String get browserActions_focusAddressBarDescription =>
      'Adresse bearbeiten oder eine Suche starten';

  @override
  String get browserActions_backTitle => 'Zurück';

  @override
  String get browserActions_backDescription => 'Im Verlauf zurückgehen';

  @override
  String get browserActions_forwardTitle => 'Vorwärts';

  @override
  String get browserActions_forwardDescription => 'Im Verlauf vorwärtsgehen';

  @override
  String get browserActions_reloadTitle => 'Neu laden';

  @override
  String get browserActions_reloadDescription => 'Die aktuelle Seite neu laden';

  @override
  String get browserActions_hardReloadTitle => 'Vollständig neu laden';

  @override
  String get browserActions_hardReloadDescription =>
      'Die aktuelle Seite unter Umgehung des Caches neu laden';

  @override
  String get browserActions_scrollTopTitle => 'Zum Anfang';

  @override
  String get browserActions_scrollTopDescription =>
      'Zum Anfang der Seite springen';

  @override
  String get browserActions_scrollBottomTitle => 'Zum Ende';

  @override
  String get browserActions_scrollBottomDescription =>
      'Zum Ende der Seite springen';

  @override
  String get browserActions_pageUpTitle => 'Bild auf';

  @override
  String get browserActions_pageUpDescription =>
      'Um eine Bildschirmhöhe nach oben scrollen';

  @override
  String get browserActions_pageDownTitle => 'Bild ab';

  @override
  String get browserActions_pageDownDescription =>
      'Um eine Bildschirmhöhe nach unten scrollen';

  @override
  String get browserActions_newTabTitle => 'Neuer Tab';

  @override
  String get browserActions_newTabDescription => 'Einen neuen Tab öffnen';

  @override
  String get browserActions_newPrivateTabTitle => 'Neuer privater Tab';

  @override
  String get browserActions_newPrivateTabDescription =>
      'Einen neuen privaten Tab öffnen';

  @override
  String get browserActions_closeTabTitle => 'Tab schließen';

  @override
  String get browserActions_closeTabDescription =>
      'Den aktuellen Tab schließen';

  @override
  String get browserActions_reopenClosedTabTitle =>
      'Geschlossenen Tab wieder öffnen';

  @override
  String get browserActions_reopenClosedTabDescription =>
      'Den zuletzt geschlossenen Tab wiederherstellen';

  @override
  String get browserActions_duplicateTabTitle => 'Tab duplizieren';

  @override
  String get browserActions_duplicateTabDescription =>
      'Eine Kopie des aktuellen Tabs öffnen';

  @override
  String get browserActions_nextTabTitle => 'Nächster Tab';

  @override
  String get browserActions_nextTabDescription => 'Zum nächsten Tab wechseln';

  @override
  String get browserActions_previousTabTitle => 'Vorheriger Tab';

  @override
  String get browserActions_previousTabDescription =>
      'Zum vorherigen Tab wechseln';

  @override
  String get browserActions_lastUsedTabTitle => 'Zuletzt verwendeter Tab';

  @override
  String get browserActions_lastUsedTabDescription =>
      'Zum zuvor verwendeten Tab wechseln';

  @override
  String get browserActions_selectTab1Title => 'Tab 1';

  @override
  String get browserActions_selectTab1Description =>
      'Zum ersten Tab in der Tableiste wechseln';

  @override
  String get browserActions_selectTab2Title => 'Tab 2';

  @override
  String get browserActions_selectTab2Description =>
      'Zum zweiten Tab in der Tableiste wechseln';

  @override
  String get browserActions_selectTab3Title => 'Tab 3';

  @override
  String get browserActions_selectTab3Description =>
      'Zum dritten Tab in der Tableiste wechseln';

  @override
  String get browserActions_selectTab4Title => 'Tab 4';

  @override
  String get browserActions_selectTab4Description =>
      'Zum vierten Tab in der Tableiste wechseln';

  @override
  String get browserActions_selectTab5Title => 'Tab 5';

  @override
  String get browserActions_selectTab5Description =>
      'Zum fünften Tab in der Tableiste wechseln';

  @override
  String get browserActions_selectTab6Title => 'Tab 6';

  @override
  String get browserActions_selectTab6Description =>
      'Zum sechsten Tab in der Tableiste wechseln';

  @override
  String get browserActions_selectTab7Title => 'Tab 7';

  @override
  String get browserActions_selectTab7Description =>
      'Zum siebten Tab in der Tableiste wechseln';

  @override
  String get browserActions_selectTab8Title => 'Tab 8';

  @override
  String get browserActions_selectTab8Description =>
      'Zum achten Tab in der Tableiste wechseln';

  @override
  String get browserActions_selectLastTabTitle => 'Letzter Tab';

  @override
  String get browserActions_selectLastTabDescription =>
      'Zum letzten Tab in der Tableiste wechseln';

  @override
  String get browserActions_togglePinTabTitle => 'Tab anheften / lösen';

  @override
  String get browserActions_togglePinTabDescription =>
      'Den aktuellen Tab anheften oder lösen';

  @override
  String get browserActions_moveTabBackwardTitle => 'Tab nach vorne';

  @override
  String get browserActions_moveTabBackwardDescription =>
      'Den aktuellen Tab um eine Stelle Richtung Anfang der Tableiste verschieben';

  @override
  String get browserActions_moveTabForwardTitle => 'Tab nach hinten';

  @override
  String get browserActions_moveTabForwardDescription =>
      'Den aktuellen Tab um eine Stelle Richtung Ende der Tableiste verschieben';

  @override
  String get browserActions_moveTabToStartTitle => 'Tab an den Anfang';

  @override
  String get browserActions_moveTabToStartDescription =>
      'Den aktuellen Tab an den Anfang seiner Gruppe in der Tableiste verschieben';

  @override
  String get browserActions_moveTabToEndTitle => 'Tab ans Ende';

  @override
  String get browserActions_moveTabToEndDescription =>
      'Den aktuellen Tab ans Ende seiner Gruppe in der Tableiste verschieben';

  @override
  String get browserActions_nextContainerTitle => 'Nächster Container';

  @override
  String get browserActions_nextContainerDescription =>
      'Zum nächsten Container und seinem zuletzt verwendeten Tab wechseln';

  @override
  String get browserActions_previousContainerTitle => 'Vorheriger Container';

  @override
  String get browserActions_previousContainerDescription =>
      'Zum vorherigen Container und seinem zuletzt verwendeten Tab wechseln';

  @override
  String get browserActions_toggleReaderModeTitle => 'Leseansicht';

  @override
  String get browserActions_toggleReaderModeDescription =>
      'Leseansicht für die aktuelle Seite ein- oder ausschalten';

  @override
  String get browserActions_toggleDesktopModeTitle => 'Desktop-Version';

  @override
  String get browserActions_toggleDesktopModeDescription =>
      'Desktop-Version für die aktuelle Seite ein- oder ausschalten';

  @override
  String get browserActions_findInPageTitle => 'Auf Seite suchen';

  @override
  String get browserActions_findInPageDescription =>
      'Suche auf der Seite öffnen';

  @override
  String get browserActions_findNextTitle => 'Nächster Treffer';

  @override
  String get browserActions_findNextDescription =>
      'Zum nächsten Treffer der letzten Suche springen';

  @override
  String get browserActions_findPreviousTitle => 'Vorheriger Treffer';

  @override
  String get browserActions_findPreviousDescription =>
      'Zum vorherigen Treffer der letzten Suche springen';

  @override
  String get browserActions_increaseFontSizeTitle => 'Schrift vergrößern';

  @override
  String get browserActions_increaseFontSizeDescription =>
      'Die Schriftgröße der Seite erhöhen';

  @override
  String get browserActions_decreaseFontSizeTitle => 'Schrift verkleinern';

  @override
  String get browserActions_decreaseFontSizeDescription =>
      'Die Schriftgröße der Seite verringern';

  @override
  String get browserActions_resetFontSizeTitle => 'Schrift zurücksetzen';

  @override
  String get browserActions_resetFontSizeDescription =>
      'Die Standard-Schriftgröße der Seite wiederherstellen';

  @override
  String get browserActions_toggleBookmarkTitle => 'Lesezeichen';

  @override
  String get browserActions_toggleBookmarkDescription =>
      'Lesezeichen für die aktuelle Seite setzen oder entfernen';

  @override
  String get browserActions_sharePageTitle => 'Teilen';

  @override
  String get browserActions_sharePageDescription => 'Die aktuelle Seite teilen';

  @override
  String get browserActions_translatePageTitle => 'Übersetzen';

  @override
  String get browserActions_translatePageDescription =>
      'Die Übersetzungsoptionen der Seite öffnen';

  @override
  String get browserActions_printPageTitle => 'Drucken';

  @override
  String get browserActions_printPageDescription =>
      'Die aktuelle Seite drucken';

  @override
  String get browserActions_showHomeTitle => 'Startseite';

  @override
  String get browserActions_showHomeDescription => 'Die Startseite öffnen';

  @override
  String get browserActions_showHistoryTitle => 'Verlauf';

  @override
  String get browserActions_showHistoryDescription =>
      'Den Browserverlauf öffnen';

  @override
  String get browserActions_showBookmarksTitle => 'Lesezeichen';

  @override
  String get browserActions_showBookmarksDescription => 'Lesezeichen öffnen';

  @override
  String get browserActions_showContainersTitle => 'Container';

  @override
  String get browserActions_showContainersDescription =>
      'Die Container-Liste öffnen';

  @override
  String get browserActions_showTabViewTitle => 'Tab-Übersicht';

  @override
  String get browserActions_showTabViewDescription =>
      'Die Übersicht der Tabs öffnen';

  @override
  String get browserActions_showDownloadsTitle => 'Downloads';

  @override
  String get browserActions_showDownloadsDescription => 'Downloads öffnen';

  @override
  String get browserActions_showAddonsTitle => 'Add-ons';

  @override
  String get browserActions_showAddonsDescription => 'Erweiterungen verwalten';

  @override
  String get browserActions_openSettingsTitle => 'Einstellungen';

  @override
  String get browserActions_openSettingsDescription => 'Einstellungen öffnen';

  @override
  String get browserActions_showKeyboardShortcutsTitle => 'Tastenkürzel';

  @override
  String get browserActions_showKeyboardShortcutsDescription =>
      'Die Tasten für Browseraktionen auflisten';

  @override
  String get browserActions_toggleTabBarTitle => 'Tableiste ein-/ausblenden';

  @override
  String get browserActions_toggleTabBarDescription =>
      'Die Tableiste ausblenden oder wieder einblenden';

  @override
  String get browserActions_clearBrowsingDataTitle => 'Browserdaten löschen';

  @override
  String get browserActions_clearBrowsingDataDescription =>
      'Zu löschende Browserdaten auswählen';

  @override
  String get browserActions_moveToBackgroundTitle => 'Minimieren';

  @override
  String get browserActions_moveToBackgroundDescription =>
      'WebLibre in den Hintergrund schicken';

  @override
  String get browserActions_quitBrowserTitle => 'Beenden';

  @override
  String get browserActions_quitBrowserDescription =>
      'Alle Tabs schließen und WebLibre beenden';

  @override
  String get bookmarks_title => 'Lesezeichen';

  @override
  String get bookmarks_filterHint => 'Lesezeichen filtern …';

  @override
  String get bookmarks_emptyFolder => 'Leer';

  @override
  String get bookmarks_searchHiddenByFoldersOnly =>
      'Treffer sind durch „Nur Ordner“ ausgeblendet';

  @override
  String bookmarks_noSearchMatches(String query) {
    return 'Keine Lesezeichen passen zu „$query“';
  }

  @override
  String get bookmarks_loadFailedTitle =>
      'Lesezeichen konnten nicht geladen werden';

  @override
  String get bookmarks_loadFoldersFailedTitle =>
      'Lesezeichenordner konnten nicht geladen werden';

  @override
  String get bookmarks_folderLabel => 'Ordner';

  @override
  String get bookmarks_unnamedFolder => 'Unbenannter Ordner';

  @override
  String bookmarks_selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausgewählt',
      one: '1 ausgewählt',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_tooltipOpenInBackground => 'Im Hintergrund öffnen';

  @override
  String get bookmarks_tooltipMoveSelected => 'Auswahl verschieben';

  @override
  String get bookmarks_tooltipDeleteSelected => 'Auswahl löschen';

  @override
  String get bookmarks_tooltipClearSearch => 'Suche leeren';

  @override
  String get bookmarks_tooltipSearchBookmarks => 'Lesezeichen durchsuchen';

  @override
  String get bookmarks_tooltipCollapse => 'Einklappen';

  @override
  String get bookmarks_tooltipExpand => 'Ausklappen';

  @override
  String get bookmarks_menuAddBookmarkHere => 'Lesezeichen hier hinzufügen';

  @override
  String get bookmarks_menuAddSubfolderHere => 'Unterordner hier hinzufügen';

  @override
  String get bookmarks_menuCollapseAll => 'Alle einklappen';

  @override
  String get bookmarks_menuShowEmptyFolders => 'Leere Ordner anzeigen';

  @override
  String get bookmarks_menuHideEmptyFolders => 'Leere Ordner ausblenden';

  @override
  String get bookmarks_menuShowBookmarks => 'Lesezeichen anzeigen';

  @override
  String get bookmarks_menuFoldersOnly => 'Nur Ordner';

  @override
  String get bookmarks_menuVisibility => 'Sichtbarkeit';

  @override
  String get bookmarks_menuSort => 'Sortieren';

  @override
  String get bookmarks_menuImport => 'Importieren';

  @override
  String get bookmarks_menuExport => 'Exportieren';

  @override
  String get bookmarks_formatJson => 'JSON';

  @override
  String get bookmarks_formatHtml => 'HTML';

  @override
  String get bookmarks_actionOpenInNewTab => 'In neuem Tab öffnen';

  @override
  String get bookmarks_actionOpenInBackground => 'Im Hintergrund öffnen';

  @override
  String get bookmarks_actionShare => 'Teilen';

  @override
  String get bookmarks_actionMove => 'Verschieben';

  @override
  String get bookmarks_actionFlatten => 'Auflösen';

  @override
  String get bookmarks_actionAddSubfolder => 'Unterordner hinzufügen';

  @override
  String get bookmarks_actionAddBookmark => 'Lesezeichen hinzufügen';

  @override
  String get bookmarks_actionMerge => 'Zusammenführen';

  @override
  String get bookmarks_actionReplace => 'Ersetzen';

  @override
  String get bookmarks_noEntriesSelected => 'Keine Lesezeichen ausgewählt';

  @override
  String bookmarks_openedTabsInBackground(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tabs im Hintergrund geöffnet',
      one: '1 Tab im Hintergrund geöffnet',
    );
    return '$_temp0';
  }

  @override
  String bookmarks_movedItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Elemente verschoben',
      one: '1 Element verschoben',
    );
    return '$_temp0';
  }

  @override
  String bookmarks_deletedItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Elemente gelöscht',
      one: '1 Element gelöscht',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_importFailedToReadFile =>
      'Datei konnte nicht gelesen werden';

  @override
  String bookmarks_importSuccessCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Lesezeichen erfolgreich importiert',
      one: '1 Lesezeichen erfolgreich importiert',
    );
    return '$_temp0';
  }

  @override
  String bookmarks_importFailedWithError(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get bookmarks_exportDialogTitle => 'Lesezeichen exportieren';

  @override
  String get bookmarks_exportSuccess => 'Lesezeichen erfolgreich exportiert';

  @override
  String bookmarks_exportFailedWithError(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get bookmarks_sortDefault => 'Standard';

  @override
  String get bookmarks_sortTitleAsc => 'Titel A–Z';

  @override
  String get bookmarks_sortTitleDesc => 'Titel Z–A';

  @override
  String get bookmarks_sortUrlAsc => 'URL A–Z';

  @override
  String get bookmarks_sortUrlDesc => 'URL Z–A';

  @override
  String get bookmarks_sortDateAddedDesc => 'Neueste zuerst';

  @override
  String get bookmarks_sortDateAddedAsc => 'Älteste zuerst';

  @override
  String get bookmarks_deleteBookmarkTitle => 'Lesezeichen löschen';

  @override
  String get bookmarks_deleteBookmarkContent => 'Dieses Lesezeichen löschen?';

  @override
  String get bookmarks_deleteFolderTitle => 'Ordner löschen';

  @override
  String get bookmarks_deleteFolderConfirmUnknown =>
      'Diesen Ordner samt allen enthaltenen Lesezeichen löschen?';

  @override
  String bookmarks_deleteFolderConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Diesen Ordner und die $count enthaltenen Lesezeichen löschen?',
      one: 'Diesen Ordner und das enthaltene Lesezeichen löschen?',
      zero: 'Diesen Ordner löschen?',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_importDialogTitle => 'Lesezeichen importieren';

  @override
  String get bookmarks_importDialogContent =>
      'Vor dem Import alle vorhandenen Lesezeichen löschen?\n\n„Ersetzen“ löscht die vorhandenen Lesezeichen, „Zusammenführen“ behält sie.';

  @override
  String get bookmarks_importProgressTitle => 'Lesezeichen werden importiert';

  @override
  String get bookmarks_importPhaseParsing => 'Datei wird gelesen …';

  @override
  String get bookmarks_importPhaseErasing =>
      'Vorhandene Lesezeichen werden entfernt …';

  @override
  String bookmarks_importPhaseInsertingProgress(int inserted, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$inserted von $total Lesezeichen',
      one: '$inserted von 1 Lesezeichen',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_importPhaseInsertingIndeterminate =>
      'Lesezeichen werden gespeichert …';

  @override
  String get bookmarks_moveToFolderTitle => 'In Ordner verschieben';

  @override
  String get bookmarks_editBookmarkTitle => 'Lesezeichen ändern';

  @override
  String get bookmarks_createBookmarkTitle => 'Lesezeichen erstellen';

  @override
  String get bookmarks_editFolderTitle => 'Ordner bearbeiten';

  @override
  String get bookmarks_createFolderTitle => 'Ordner erstellen';

  @override
  String get bookmarks_fieldNameLabel => 'Name';

  @override
  String get bookmarks_fieldUrlLabel => 'URL';

  @override
  String get bookmarks_addToTop => 'Oben einfügen';

  @override
  String get browser_actionSelect => 'Auswählen';

  @override
  String get browser_actionKeep => 'Behalten';

  @override
  String get browser_actionInstall => 'Installieren';

  @override
  String get browser_bookmarkAllTitle => 'Alle Tabs als Lesezeichen speichern';

  @override
  String get browser_bookmarkAllFastTitle => 'Schnell';

  @override
  String get browser_bookmarkAllFastSubtitle =>
      'Alle Tabs automatisch zu einem ausgewählten Ordner hinzufügen';

  @override
  String get browser_bookmarkAllDetailedTitle => 'Ausführlich';

  @override
  String get browser_bookmarkAllDetailedSubtitle =>
      'Jedes Lesezeichen einzeln prüfen und bearbeiten';

  @override
  String get browser_clearSiteDataTitle => 'Websitedaten löschen';

  @override
  String browser_clearSiteDataContent(String formattedTypes, String host) {
    return 'Für $host werden folgende Daten gelöscht:\n$formattedTypes\n\nMöglicherweise ist danach eine erneute Anmeldung nötig.';
  }

  @override
  String get browser_contentSelectionExtractedTitle => 'Extrahierter Inhalt';

  @override
  String get browser_contentSelectionExtractedSubtitle =>
      'Für das Lesen optimierter Inhalt ohne Navigation und Werbung';

  @override
  String get browser_contentSelectionFullTitle => 'Vollständiger Inhalt';

  @override
  String get browser_contentSelectionFullSubtitle =>
      'Die komplette Seite mit allen Elementen und ihrer Struktur';

  @override
  String get browser_deleteDataTitle => 'Browserdaten löschen';

  @override
  String get browser_installAddonSheetTitle =>
      'Erweiterung aus Datei installieren';

  @override
  String get browser_installAddonSelectFileButton => 'XPI-Datei auswählen';

  @override
  String get browser_installAddonNoFileSelected => 'Keine Datei ausgewählt';

  @override
  String get browser_installAddonPinnedNotice =>
      'Aus einer lokalen XPI-Datei installierte Erweiterungen bleiben auf dieser Version und werden nicht automatisch aktualisiert.';

  @override
  String get browser_installAddonNotXpiError =>
      'Bitte eine .xpi-Datei auswählen';

  @override
  String browser_installAddonPickFileFailed(String error) {
    return 'Datei konnte nicht ausgewählt werden: $error';
  }

  @override
  String get browser_installAddonInstalledMessage =>
      'Erweiterung installiert. Automatische Updates sind für diese lokale Version deaktiviert.';

  @override
  String get browser_installAddonNotSignedError =>
      'Diese Erweiterung ist nicht von Mozilla signiert. Zum Installieren in den Erweiterungseinstellungen „Nicht signierte Erweiterungen erlauben“ aktivieren.';

  @override
  String browser_installAddonInstallFailed(String error) {
    return 'Installation fehlgeschlagen: $error';
  }

  @override
  String get browser_keepTabTitle => 'Tab behalten?';

  @override
  String get browser_keepTabContent => 'Diesen Tab behalten oder verwerfen?';

  @override
  String get browser_qrCodeTitle => 'QR-Code teilen';

  @override
  String get browser_selectFolderTitle => 'Ordner auswählen';

  @override
  String get browser_tabTreeCurrentTabNotInTree =>
      'Der aktuelle Tab gehört nicht zu diesem Baum';

  @override
  String get browser_menuManageExtensions => 'Erweiterungen verwalten';

  @override
  String get browser_menuAddRegularTab => 'Normalen Tab öffnen';

  @override
  String get browser_menuAddChildTab => 'Unter-Tab öffnen';

  @override
  String get browser_menuAddPrivateTab => 'Privaten Tab öffnen';

  @override
  String get browser_menuAddIsolatedTab => 'Isolierten Tab öffnen';

  @override
  String get browser_fontSizeTitle => 'Textgröße';

  @override
  String get browser_fontSizeAutomaticNotice =>
      'Die automatische Schriftgröße ist aktiviert. Zum manuellen Anpassen in den Einstellungen deaktivieren.';

  @override
  String get browser_fontSizeResetButton => 'Auf 100 % zurücksetzen';

  @override
  String get browser_historyNoPreviousPages => 'Keine vorherigen Seiten';

  @override
  String get browser_historyNoForwardPages => 'Keine nächsten Seiten';

  @override
  String get browser_certSandboxedCaptureTitle => 'Sandbox-Erfassung';

  @override
  String get browser_certSandboxedCaptureSubtitle =>
      'Die Seite stammt aus einem Offline-Archiv – keine Live-Verbindung.';

  @override
  String get browser_certConnectionNotSecure => 'Verbindung ist nicht sicher';

  @override
  String get browser_certConnectionSecure => 'Verbindung ist sicher';

  @override
  String browser_certVerifiedBy(String issuer) {
    return 'Verifiziert von: $issuer';
  }

  @override
  String get browser_containerFallbackName => 'Container';

  @override
  String get browser_actionEnable => 'Aktivieren';

  @override
  String get browser_closeAllPrivateTabsTitle => 'Alle privaten Tabs schließen';

  @override
  String get browser_closeAllPrivateTabsContent =>
      'Alle angezeigten privaten Tabs schließen?';

  @override
  String get browser_closeAllTabsTitle => 'Alle Tabs schließen';

  @override
  String get browser_closeAllTabsContent => 'Alle angezeigten Tabs schließen?';

  @override
  String get browser_enableAiTabSuggestionsTitle =>
      'KI-Tab-Vorschläge aktivieren';

  @override
  String get browser_enableAiTabSuggestionsContent =>
      'Für diese Funktion müssen möglicherweise KI-Modelle heruntergeladen werden. Downloadgröße und Fortschritt lassen sich vorab nicht bestimmen.\n\nFortfahren?';

  @override
  String get browser_tooltipExpandGroup => 'Gruppe ausklappen';

  @override
  String get browser_tooltipCollapseGroup => 'Gruppe einklappen';

  @override
  String get browser_searchOrEnterUrl => 'Suchen oder URL eingeben';

  @override
  String get browser_tabCannotBeMovedHere =>
      'Tab kann nicht hierher verschoben werden';

  @override
  String get browser_quickActionNewTab => 'Neuer Tab';

  @override
  String get browser_quickActionNewPrivateTab => 'Neuer privater Tab';

  @override
  String get browser_quickActionNewIsolatedTab => 'Neuer isolierter Tab';

  @override
  String get browser_shareLink => 'Link teilen';

  @override
  String get browser_showQrCode => 'QR-Code anzeigen';

  @override
  String get browser_exportAsPdf => 'Als PDF exportieren';

  @override
  String get browser_failedToPrintPage => 'Seite konnte nicht gedruckt werden';

  @override
  String get browser_print => 'Drucken';

  @override
  String get browser_shareScreenshot => 'Screenshot teilen';

  @override
  String get browser_exportAsPng => 'Als PNG exportieren';

  @override
  String browser_openInNamedApp(String appName) {
    return 'In $appName öffnen';
  }

  @override
  String get browser_openInApp => 'In App öffnen';

  @override
  String get browser_copyAddress => 'Adresse kopieren';

  @override
  String get browser_noTargetDevices => 'Keine Zielgeräte';

  @override
  String browser_sentTabToDevice(String deviceName) {
    return 'Tab an $deviceName gesendet';
  }

  @override
  String get browser_failedToSendTab => 'Tab konnte nicht gesendet werden';

  @override
  String get browser_loadingDevices => 'Geräte werden geladen …';

  @override
  String get browser_failedToLoadDevices =>
      'Geräte konnten nicht geladen werden';

  @override
  String get browser_sendToDevice => 'An Gerät senden';

  @override
  String get browser_containerMenuNewTab => 'Neuer Tab';

  @override
  String get browser_unpinContainer => 'Container lösen';

  @override
  String get browser_pinContainer => 'Container anheften';

  @override
  String get browser_closeSubmenuAllTabs => 'Alle Tabs';

  @override
  String get browser_closeSubmenuPrivateTabs => 'Private Tabs';

  @override
  String get browser_closeSubmenuIsolatedTabs => 'Isolierte Tabs';

  @override
  String get browser_closeSubmenuFilteredTabs => 'Gefilterte Tabs';

  @override
  String get browser_menuCloseTabs => 'Tabs schließen';

  @override
  String get browser_menuBookmarkAll => 'Alle als Lesezeichen';

  @override
  String get browser_menuAssignedSites => 'Zugeordnete Websites …';

  @override
  String get browser_menuClearContainerData => 'Container-Daten löschen';

  @override
  String get browser_menuEditContainer => 'Container bearbeiten …';

  @override
  String get browser_menuDeleteContainer => 'Container löschen';

  @override
  String browser_bookmarksAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Lesezeichen hinzugefügt',
      one: '1 Lesezeichen hinzugefügt',
    );
    return '$_temp0';
  }

  @override
  String get browser_containerDataClearedSuccess =>
      'Container-Daten erfolgreich gelöscht';

  @override
  String browser_containerDataClearedWithTabsClosed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Container-Daten gelöscht. $count Tabs geschlossen.',
      one: 'Container-Daten gelöscht. 1 Tab geschlossen.',
    );
    return '$_temp0';
  }

  @override
  String browser_errorClearingData(String error) {
    return 'Fehler beim Löschen der Daten: $error';
  }

  @override
  String get browser_appLinksSectionTitle => 'App-Links';

  @override
  String get browser_openLinksForThisSite => 'Links dieser Website öffnen';

  @override
  String get browser_followsTheDefault => 'Folgt dem Standard';

  @override
  String get browser_followDefault => 'Standard folgen';

  @override
  String get browser_openInAppOption => 'In App öffnen';

  @override
  String get browser_keepInBrowser => 'Im Browser behalten';

  @override
  String get browser_noAppFoundForSite =>
      'Keine App für diese Website gefunden';

  @override
  String browser_alwaysOpensInApp(String appName) {
    return 'Öffnet sich immer in $appName';
  }

  @override
  String get browser_theAppFallback => 'der App';

  @override
  String get browser_alwaysStaysInBrowser => 'Bleibt immer im Browser';

  @override
  String get browser_followsDefaultOpensInApps =>
      'Folgt dem Standard: öffnet in Apps';

  @override
  String get browser_followsDefaultNoAppFound =>
      'Folgt dem Standard: keine App gefunden';

  @override
  String get browser_followsDefaultAsksFirst =>
      'Folgt dem Standard: fragt zuerst';

  @override
  String get browser_followsDefaultStaysInBrowser =>
      'Folgt dem Standard: bleibt im Browser';

  @override
  String get browser_selectDataTypesToClear =>
      'Zu löschende Datentypen auswählen';

  @override
  String get browser_cookiesCacheAndSiteData =>
      'Cookies, Cache und Websitedaten';

  @override
  String get browser_dataTypeAuthSessions => 'Anmeldesitzungen';

  @override
  String get browser_dataTypeAuthSessionsSubtitle =>
      'Gespeicherte Anmeldungen, aktive Sitzungen';

  @override
  String get browser_dataTypeSiteData => 'Websitedaten';

  @override
  String get browser_dataTypeSiteDataSubtitle =>
      'Offline-Speicher, Datenbanken, lokale Dateien';

  @override
  String get browser_dataTypeCookies => 'Cookies';

  @override
  String get browser_dataTypeCookiesSubtitle =>
      'Anmelde-Tokens, Einstellungen, Tracking-Daten';

  @override
  String get browser_dataTypeCachedFiles => 'Zwischengespeicherte Dateien';

  @override
  String get browser_dataTypeCachedFilesSubtitle =>
      'Bilder, Skripte, Stylesheets';

  @override
  String get browser_closeTabAfterClearing => 'Tab nach dem Löschen schließen';

  @override
  String get browser_closeTabAfterClearingSubtitle =>
      'Diesen Tab schließen, sobald die Daten gelöscht sind';

  @override
  String get browser_clearingEllipsis => 'Wird gelöscht …';

  @override
  String get browser_clearNow => 'Jetzt löschen';

  @override
  String get browser_selectAtLeastOneDataType =>
      'Mindestens einen Datentyp auswählen';

  @override
  String get browser_siteDataCleared => 'Websitedaten gelöscht';

  @override
  String browser_failedToClearSiteData(String error) {
    return 'Websitedaten konnten nicht gelöscht werden: $error';
  }

  @override
  String get browser_alwaysUseDesktopSite => 'Immer Desktop-Version verwenden';

  @override
  String get browser_unavailableOnThisPage =>
      'Auf dieser Seite nicht verfügbar';

  @override
  String browser_setByRuleFor(String host) {
    return 'Durch eine Regel für $host festgelegt';
  }

  @override
  String get browser_siteAlwaysLoadsInDesktopMode =>
      'Diese Website lädt immer die Desktop-Version';

  @override
  String get browser_siteFollowsDefaultMode =>
      'Diese Website folgt dem Standardmodus';

  @override
  String browser_failedToToggleDesktopMode(String error) {
    return 'Desktop-Modus konnte nicht umgeschaltet werden: $error';
  }

  @override
  String get browser_gesturesTitle => 'Gesten';

  @override
  String get browser_gesturesTurnedOffGlobally =>
      'Gesten sind global ausgeschaltet';

  @override
  String get browser_gesturesUnavailableOnThisPage =>
      'Gesten sind auf dieser Seite nicht verfügbar';

  @override
  String browser_gesturesDisabledByRuleFor(String host) {
    return 'Durch eine Regel für $host deaktiviert';
  }

  @override
  String get browser_gesturesDisabledOnThisSite =>
      'Gesten sind auf dieser Website deaktiviert';

  @override
  String get browser_gesturesEnabledOnThisSite =>
      'Gesten sind auf dieser Website aktiviert';

  @override
  String browser_failedToToggleGestures(String error) {
    return 'Gesten konnten nicht umgeschaltet werden: $error';
  }

  @override
  String browser_errorLoadingPermissions(String error) {
    return 'Fehler beim Laden der Berechtigungen: $error';
  }

  @override
  String get browser_permissionsSectionTitle => 'Berechtigungen';

  @override
  String get browser_showAll => 'Alle anzeigen';

  @override
  String get browser_noPermissionsSetForSite =>
      'Für diese Website sind keine Berechtigungen festgelegt';

  @override
  String get browser_permissionAsk => 'Fragen';

  @override
  String get browser_permissionAllow => 'Erlauben';

  @override
  String get browser_permissionBlock => 'Blockieren';

  @override
  String get browser_autoplayTitle => 'Automatische Wiedergabe';

  @override
  String get browser_autoplayAllowAll => 'Alle erlauben';

  @override
  String get browser_autoplayBlockAudible => 'Mit Ton blockieren';

  @override
  String get browser_autoplayBlockAll => 'Alle blockieren';

  @override
  String get browser_failedToLoadTrackingProtection =>
      'Schutz vor Aktivitätenverfolgung konnte nicht geladen werden';

  @override
  String get browser_enhancedTrackingProtection =>
      'Verbesserter Schutz vor Aktivitätenverfolgung';

  @override
  String get browser_trackersBeingBlocked =>
      'Tracker auf dieser Website werden blockiert';

  @override
  String get browser_trackersAllowed =>
      'Tracker auf dieser Website sind erlaubt';

  @override
  String browser_failedToToggleTrackingProtection(String error) {
    return 'Schutz vor Aktivitätenverfolgung konnte nicht umgeschaltet werden: $error';
  }

  @override
  String get browser_resizeSidePanel => 'Größe der Seitenleiste ändern';

  @override
  String get browser_unassignedContainerLabel => 'Nicht zugeordnet';

  @override
  String get browser_tooltipCloseTab => 'Tab schließen';

  @override
  String get browser_urlCleaned => 'URL bereinigt';

  @override
  String get browser_urlPreviewApplied => 'URL-Vorschau übernommen';

  @override
  String browser_trackingParametersDetected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tracking-Parameter erkannt',
      one: '1 Tracking-Parameter erkannt',
    );
    return '$_temp0';
  }

  @override
  String get browser_linkIsClean => 'Link ist sauber';

  @override
  String get browser_removeTrackingTooltip => 'Tracking entfernen';

  @override
  String get browser_menuFindInPage => 'Auf Seite suchen';

  @override
  String get browser_menuReaderMode => 'Leseansicht';

  @override
  String get browser_menuFetchFeedsOnPage => 'Feeds auf der Seite abrufen';

  @override
  String get browser_menuAddBookmark => 'Lesezeichen hinzufügen';

  @override
  String get browser_cloneRegular => 'Normal';

  @override
  String get browser_clonePrivate => 'Privat';

  @override
  String get browser_cloneIsolated => 'Isoliert';

  @override
  String get browser_menuCloneTab => 'Tab klonen';

  @override
  String get browser_menuAssignContainer => 'Container zuweisen';

  @override
  String get browser_menuUrlRelation => 'URL zuordnen';

  @override
  String get browser_menuUnassignUrlRelation => 'URL-Zuordnung aufheben';

  @override
  String get browser_menuUnassignContainer => 'Container-Zuweisung aufheben';

  @override
  String get browser_menuContainerSubmenu => 'Container';

  @override
  String get browser_menuMoveUp => 'Nach oben';

  @override
  String get browser_menuMoveDown => 'Nach unten';

  @override
  String get browser_menuReorder => 'Anordnen';

  @override
  String get browser_menuShare => 'Teilen';

  @override
  String get browser_menuCopyAsMarkdown => 'Als Markdown kopieren';

  @override
  String get browser_markdownCopiedToClipboard =>
      'Markdown in die Zwischenablage kopiert';

  @override
  String get browser_menuExportAsMarkdown => 'Als Markdown exportieren';

  @override
  String get browser_menuExportSubmenu => 'Exportieren';

  @override
  String get browser_menuCloseTab => 'Tab schließen';

  @override
  String get browser_menuReload => 'Neu laden';

  @override
  String get browser_menuDesktopMode => 'Desktop-Modus';

  @override
  String get browser_menuAddToHomeScreen => 'Zum Startbildschirm hinzufügen';

  @override
  String get browser_menuChangeParent => 'Übergeordneten Tab ändern …';

  @override
  String get browser_menuDetachFromParent => 'Vom übergeordneten Tab lösen';

  @override
  String get browser_menuHierarchy => 'Hierarchie';

  @override
  String get browser_pageTranslated => 'Übersetzt';

  @override
  String get browser_menuTranslatePage => 'Seite übersetzen';

  @override
  String get browser_unpinTab => 'Tab lösen';

  @override
  String get browser_pinTab => 'Tab anheften';

  @override
  String browser_errorGeneric(String error) {
    return 'Fehler: $error';
  }

  @override
  String get browser_tabNoLongerExists => 'Tab existiert nicht mehr';

  @override
  String get browser_chooseAParentTab => 'Übergeordneten Tab auswählen';

  @override
  String get browser_makeStandalone => 'Eigenständig machen';

  @override
  String get browser_detachFromCurrentParent =>
      'Vom aktuellen übergeordneten Tab lösen';

  @override
  String get browser_noCandidateTabsInContainer =>
      'Keine passenden Tabs in diesem Container.';

  @override
  String get browser_clearContainerDataIntro =>
      'Dadurch werden alle Daten dieses Containers gelöscht:';

  @override
  String get browser_bulletCookies => '• Cookies';

  @override
  String get browser_bulletSiteData => '• Websitedaten';

  @override
  String get browser_bulletCache => '• Cache';

  @override
  String get browser_bulletPermissions => '• Berechtigungen';

  @override
  String browser_tabsWillBeClosedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tabs werden geschlossen.',
      one: '1 Tab wird geschlossen.',
    );
    return '$_temp0';
  }

  @override
  String get browser_recreateTabsAfterClearing =>
      'Tabs nach dem Löschen neu erstellen';

  @override
  String get browser_actionClearData => 'Daten löschen';

  @override
  String get browser_closeFromSameHost => 'Tabs derselben Website schließen';

  @override
  String get browser_closeTabAndDescendants => 'Tab und Unter-Tabs schließen';

  @override
  String get browser_tabUnpinned => 'Tab gelöst';

  @override
  String browser_createdContainerNamed(String containerName) {
    return 'Container „$containerName“ erstellt';
  }

  @override
  String get browser_newContainerFallback => 'Neuer Container';

  @override
  String get browser_assignedParentTab => 'Übergeordneter Tab zugewiesen';

  @override
  String get browser_couldNotAssignParentTab =>
      'Übergeordneter Tab konnte nicht zugewiesen werden';

  @override
  String get browser_dropTabOntoTabTitle => 'Tab auf Tab ablegen';

  @override
  String get browser_chooseHowTabsRelated =>
      'Festlegen, wie diese Tabs zusammenhängen sollen.';

  @override
  String get browser_createContainerOption => 'Container erstellen';

  @override
  String get browser_createContainerOptionSubtitle =>
      'Einen neuen Container mit beiden Tabs erstellen.';

  @override
  String get browser_assignNewParentOption =>
      'Neuen übergeordneten Tab zuweisen';

  @override
  String get browser_assignNewParentOptionSubtitle =>
      'Den Tab, auf dem abgelegt wurde, zum übergeordneten Tab machen.';

  @override
  String get browser_tabReorderingOnlyInDefaultMode =>
      'Tabs lassen sich nur in der manuellen Standardsortierung anordnen';

  @override
  String get browser_tooltipSearchInsideTabs => 'In Tabs suchen';

  @override
  String get browser_filterTabType => 'Tab-Art';

  @override
  String get browser_sortPinnedFirst => 'Angeheftete zuerst';

  @override
  String get browser_filterSort => 'Sortieren';

  @override
  String get browser_hierarchicalView => 'Hierarchische Ansicht';

  @override
  String get browser_filterDate => 'Nach Datum filtern';

  @override
  String get browser_quickInterval => 'Schneller Zeitraum';

  @override
  String get browser_resetFilter => 'Filter zurücksetzen';

  @override
  String get browser_tooltipFilterAndSort => 'Filtern & sortieren';

  @override
  String get browser_tooltipChangeViewMode => 'Ansicht wechseln';

  @override
  String browser_downloadingAiModelsProgress(int percent) {
    return 'KI-Modelle werden heruntergeladen ($percent %)';
  }

  @override
  String get browser_disableAiTabSuggestions =>
      'KI-Tab-Vorschläge deaktivieren';

  @override
  String get browser_enableAiTabSuggestionsTooltip =>
      'KI-Tab-Vorschläge aktivieren';

  @override
  String get browser_disableReorderingMode => 'Anordnungsmodus beenden';

  @override
  String get browser_enableReorderingMode => 'Anordnungsmodus starten';

  @override
  String get browser_reorderingRequiresDefaultManualMode =>
      'Anordnen erfordert die manuelle Standardsortierung';

  @override
  String get browser_dragAndDropTabsToReorder =>
      'Tabs zum Anordnen ziehen und ablegen';

  @override
  String get browser_tooltipTabActions => 'Tab-Aktionen';

  @override
  String get browser_hintSearchTabs => 'Tabs durchsuchen';

  @override
  String get browser_noSyncedTabsAvailable =>
      'Keine synchronisierten Tabs verfügbar';

  @override
  String browser_failedToLoadSyncedTabs(String error) {
    return 'Synchronisierte Tabs konnten nicht geladen werden: $error';
  }

  @override
  String get browser_translateFromLabel => 'Von';

  @override
  String get browser_translateToLabel => 'Nach';

  @override
  String browser_translationError(String error) {
    return 'Übersetzungsfehler: $error';
  }

  @override
  String get browser_failedToRestorePage =>
      'Die Seite konnte nicht wiederhergestellt werden';

  @override
  String get browser_showOriginal => 'Original anzeigen';

  @override
  String get browser_failedToTranslatePage =>
      'Die Seite konnte nicht übersetzt werden';

  @override
  String get browser_retranslate => 'Neu übersetzen';

  @override
  String get browser_translateAction => 'Übersetzen';

  @override
  String get browser_tabTypeFilterAll => 'Alle Tabs';

  @override
  String get browser_tabTypeFilterRegular => 'Normal';

  @override
  String get browser_tabTypeFilterPrivate => 'Privat';

  @override
  String get browser_tabTypeFilterIsolated => 'Isoliert';

  @override
  String get browser_tabSortDefault => 'Standard';

  @override
  String get browser_tabSortTitleAsc => 'Titel A–Z';

  @override
  String get browser_tabSortTitleDesc => 'Titel Z–A';

  @override
  String get browser_tabSortUrlAsc => 'URL A–Z';

  @override
  String get browser_tabSortUrlDesc => 'URL Z–A';

  @override
  String get browser_tabSortNewestFirst => 'Neueste zuerst';

  @override
  String get browser_tabSortOldestFirst => 'Älteste zuerst';

  @override
  String get browser_tabIntervalLastHour => 'Letzte Stunde';

  @override
  String get browser_tabIntervalLast3Hours => 'Letzte 3 Stunden';

  @override
  String get browser_tabIntervalLast8Hours => 'Letzte 8 Stunden';

  @override
  String get browser_tabIntervalLastDay => 'Letzter Tag';

  @override
  String get browser_tabIntervalLast3Days => 'Letzte 3 Tage';

  @override
  String get browser_tabIntervalLastWeek => 'Letzte Woche';

  @override
  String get browser_tabIntervalLastMonth => 'Letzter Monat';

  @override
  String get browser_tabsViewModeList => 'Liste';

  @override
  String get browser_tabsViewModeGrid => 'Raster';

  @override
  String get browser_tabsViewModeTree => 'Baum';

  @override
  String get browser_permissionCamera => 'Kamera';

  @override
  String get browser_permissionMicrophone => 'Mikrofon';

  @override
  String get browser_permissionLocation => 'Standort';

  @override
  String get browser_permissionNotification => 'Benachrichtigungen';

  @override
  String get browser_permissionPersistentStorage => 'Dauerhafter Speicher';

  @override
  String get browser_permissionCrossOriginStorage =>
      'Websiteübergreifender Speicher';

  @override
  String get browser_permissionMediaKeySystem => 'Media Key System (DRM)';

  @override
  String get browser_tabReorderBlockedMessage =>
      'Zum Anordnen der Tabs Filter oder Suche der Tab-Übersicht zurücksetzen';

  @override
  String get contextualToolbar_tooltipHome => 'Startseite';

  @override
  String get contextualToolbar_tooltipHideTabBar => 'Tableiste ausblenden';

  @override
  String get contextualToolbar_tooltipClearBrowsingData =>
      'Browserdaten löschen';

  @override
  String get contextualToolbar_tooltipAddBookmark => 'Lesezeichen hinzufügen';

  @override
  String get contextualToolbar_tooltipRemoveBookmark => 'Lesezeichen entfernen';

  @override
  String get contextualToolbar_tooltipEnableGestures => 'Gesten aktivieren';

  @override
  String get contextualToolbar_tooltipDisableGestures => 'Gesten deaktivieren';

  @override
  String get contextualToolbar_actionHardRefresh => 'Vollständig neu laden';

  @override
  String get contextualToolbar_actionCloseOthers => 'Andere schließen';

  @override
  String get contextualToolbar_actionCloseFromSameHost =>
      'Tabs derselben Website schließen';

  @override
  String get contextualToolbar_actionCloseTabAndDescendants =>
      'Tab und Unter-Tabs schließen';

  @override
  String get contextualToolbar_actionAddBookmark => 'Lesezeichen hinzufügen';

  @override
  String get contextualToolbar_actionRemoveBookmark => 'Lesezeichen entfernen';

  @override
  String get contextualToolbar_actionCloneAsRegular =>
      'Als normalen Tab klonen';

  @override
  String get contextualToolbar_actionCloneAsPrivate =>
      'Als privaten Tab klonen';

  @override
  String get contextualToolbar_actionCloneAsIsolated =>
      'Als isolierten Tab klonen';

  @override
  String get contextualToolbar_bookmarkAdded => 'Lesezeichen hinzugefügt';

  @override
  String get contextualToolbar_bookmarkRemoved => 'Lesezeichen entfernt';

  @override
  String get contextualToolbar_fontSizeAutoAdjustmentHint =>
      'Zum manuellen Anpassen die automatische Schriftgröße in den Einstellungen deaktivieren';

  @override
  String get contextualToolbar_buttonLabelBack => 'Zurück';

  @override
  String get contextualToolbar_buttonLabelForward => 'Vorwärts';

  @override
  String get contextualToolbar_buttonLabelHome => 'Startseite';

  @override
  String get contextualToolbar_buttonLabelHistory => 'Verlauf';

  @override
  String get contextualToolbar_buttonLabelBookmarks => 'Lesezeichen';

  @override
  String get contextualToolbar_buttonLabelBookmarkToggle =>
      'Lesezeichen setzen';

  @override
  String get contextualToolbar_buttonLabelShare => 'Teilen';

  @override
  String get contextualToolbar_buttonLabelAddTab => 'Neuer Tab';

  @override
  String get contextualToolbar_buttonLabelTabsCount => 'Tabs';

  @override
  String get contextualToolbar_buttonLabelNavigationMenu => 'Menü';

  @override
  String get contextualToolbar_buttonLabelReload => 'Neu laden';

  @override
  String get contextualToolbar_buttonLabelReaderMode => 'Leseansicht';

  @override
  String get contextualToolbar_buttonLabelDesktop => 'Desktop-Version';

  @override
  String get contextualToolbar_buttonLabelTranslation => 'Übersetzen';

  @override
  String get contextualToolbar_buttonLabelFindInPage => 'Auf Seite suchen';

  @override
  String get contextualToolbar_buttonLabelCloseTab => 'Tab schließen';

  @override
  String get contextualToolbar_buttonLabelInputUrl => 'Adressleiste';

  @override
  String get contextualToolbar_buttonLabelQrScan => 'QR-Code scannen';

  @override
  String get contextualToolbar_buttonLabelVoiceSearch => 'Sprachsuche';

  @override
  String get contextualToolbar_buttonLabelDuplicateTab => 'Tab duplizieren';

  @override
  String get contextualToolbar_buttonLabelIncreaseFont => 'Schrift vergrößern';

  @override
  String get contextualToolbar_buttonLabelDecreaseFont => 'Schrift verkleinern';

  @override
  String get contextualToolbar_buttonLabelMoveToBackground => 'Hintergrund';

  @override
  String get contextualToolbar_buttonLabelToggleGestures => 'Gesten';

  @override
  String get contextualToolbar_buttonLabelHideTabBar => 'Tableiste ausblenden';

  @override
  String get contextualToolbar_buttonLabelPageUp => 'Bild auf';

  @override
  String get contextualToolbar_buttonLabelPageDown => 'Bild ab';

  @override
  String get contextualToolbar_buttonLabelFont => 'Textgröße';

  @override
  String get contextualToolbar_buttonLabelExtensionShortcut => 'Erweiterungen';

  @override
  String get contextualToolbar_buttonLabelClearBrowsingData => 'Daten löschen';

  @override
  String get contextualToolbar_buttonLabelQuit => 'Beenden';

  @override
  String get contextualToolbar_longPressBackHistoryMenu =>
      'Verlaufsmenü (vorherige Seiten)';

  @override
  String get contextualToolbar_longPressForwardHistoryMenu =>
      'Verlaufsmenü (nächste Seiten)';

  @override
  String get contextualToolbar_longPressOpenBookmarks => 'Lesezeichen öffnen';

  @override
  String get contextualToolbar_longPressAddRegularTab => 'Normalen Tab öffnen';

  @override
  String get contextualToolbar_longPressAddChildTab => 'Unter-Tab öffnen';

  @override
  String get contextualToolbar_longPressAddPrivateTab => 'Privaten Tab öffnen';

  @override
  String get contextualToolbar_longPressAddIsolatedTab =>
      'Isolierten Tab öffnen';

  @override
  String get contextualToolbar_longPressOpenSettings => 'Einstellungen öffnen';

  @override
  String get contextualToolbar_longPressHardRefresh =>
      'Vollständig neu laden (Cache umgehen)';

  @override
  String get contextualToolbar_longPressShowTranslationOptions =>
      'Übersetzungsoptionen anzeigen';

  @override
  String get contextualToolbar_longPressScrollToTop => 'Zum Anfang scrollen';

  @override
  String get contextualToolbar_longPressScrollToBottom => 'Zum Ende scrollen';

  @override
  String get contextualToolbar_longPressExtensionsMenu => 'Erweiterungsmenü';

  @override
  String get contextualToolbar_longPressQuitWithoutConfirmation =>
      'Ohne Nachfrage beenden';

  @override
  String get menu_sectionQuickToggles => 'Schnellschalter';

  @override
  String get menu_sectionPageActions => 'Seitenaktionen';

  @override
  String get menu_sectionExtensions => 'Erweiterungen';

  @override
  String get menu_sectionTabActions => 'Tab-Aktionen';

  @override
  String get menu_sectionQuickLinks => 'Schnellzugriff';

  @override
  String get menu_sectionConnection => 'Verbindung';

  @override
  String get menu_sectionProfile => 'Profil & App';

  @override
  String get menu_sectionAbout => 'Über';

  @override
  String get menu_itemDesktopMode => 'Desktop';

  @override
  String get menu_itemReaderMode => 'Leseansicht';

  @override
  String get menu_itemGestures => 'Gesten';

  @override
  String get menu_itemAddBookmark => 'Lesezeichen hinzufügen';

  @override
  String get menu_itemFindInPage => 'Auf Seite suchen';

  @override
  String get menu_itemTranslatePage => 'Seite übersetzen';

  @override
  String get menu_itemAddToHomeScreen => 'Zum Startbildschirm hinzufügen';

  @override
  String get menu_itemOpenInApp => 'In App öffnen';

  @override
  String get menu_itemContainers => 'Container';

  @override
  String get menu_itemManageContainers => 'Container verwalten';

  @override
  String get menu_itemAssignContainer => 'Container zuweisen';

  @override
  String get menu_itemAssignUrlToContainer => 'URL dem Container zuordnen';

  @override
  String get menu_itemUnassignUrlFromContainer =>
      'URL-Zuordnung zum Container aufheben';

  @override
  String get menu_itemUnassignContainer => 'Container-Zuweisung aufheben';

  @override
  String get menu_itemShare => 'Teilen';

  @override
  String get menu_itemCopyAddress => 'Adresse kopieren';

  @override
  String get menu_itemShareScreenshot => 'Screenshot teilen';

  @override
  String get menu_itemShareLink => 'Link teilen';

  @override
  String get menu_itemSendToDevice => 'An Gerät senden';

  @override
  String get menu_itemShowQrCode => 'QR-Code anzeigen';

  @override
  String get menu_itemMoreDisclosure => 'Mehr';

  @override
  String get menu_itemCloneTab => 'Tab klonen';

  @override
  String get menu_itemCloneRegularTab => 'Normal';

  @override
  String get menu_itemClonePrivateTab => 'Privat';

  @override
  String get menu_itemCloneIsolatedTab => 'Isoliert';

  @override
  String get menu_itemExport => 'Exportieren';

  @override
  String get menu_itemCopyAsMarkdown => 'Als Markdown kopieren';

  @override
  String get menu_itemExportAsMarkdown => 'Als Markdown exportieren';

  @override
  String get menu_itemExportAsPdf => 'Als PDF exportieren';

  @override
  String get menu_itemExportAsPng => 'Als PNG exportieren';

  @override
  String get menu_itemPrintPage => 'Drucken';

  @override
  String get menu_itemPinTopSite => 'An Verknüpfungen anheften';

  @override
  String get menu_itemFetchFeeds => 'Feeds abrufen';

  @override
  String get menu_itemHistory => 'Verlauf';

  @override
  String get menu_itemBookmarks => 'Lesezeichen';

  @override
  String get menu_itemDownloads => 'Downloads';

  @override
  String get menu_itemBangs => 'Bangs';

  @override
  String get menu_itemFeeds => 'Feeds';

  @override
  String get menu_itemSmallWeb => 'Small Web';

  @override
  String get menu_itemClearData => 'Löschen';

  @override
  String get menu_itemProfileSwitch => 'Profil';

  @override
  String get menu_itemSyncNow => 'Jetzt synchronisieren';

  @override
  String get menu_itemAppSettings => 'Einstellungen';

  @override
  String get menu_itemQuitBrowser => 'Browser beenden';

  @override
  String get menu_itemAbout => 'Über';

  @override
  String get menu_itemMoreDisclosureDescription =>
      'Klappt alles darunter hinter einer „Mehr“-Zeile zusammen';

  @override
  String get menu_itemSendToDeviceDescription =>
      'Die Geräte selbst stammen aus dem Konto';

  @override
  String get menu_reorderHideTooltip => 'Ausblenden';

  @override
  String get menu_reorderShowTooltip => 'Einblenden';

  @override
  String menu_reorderRowsShown(int shown, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$shown von $total Zeilen angezeigt',
      one: '$shown von 1 Zeile angezeigt',
    );
    return '$_temp0';
  }

  @override
  String get menu_reorderDefaultTitle => 'Menü anpassen';

  @override
  String get menu_reorderSubtitleSections =>
      'Zum Anordnen ziehen. Einen Bereich ausschalten, um ihn im Menü auszublenden.';

  @override
  String get menu_reorderSubtitleSectionRows =>
      'Ziehen, um die Zeilen dieses Bereichs anzuordnen.';

  @override
  String get menu_reorderSubtitleItemRows =>
      'Ziehen, um die Zeilen anzuordnen, die diese Zeile öffnet.';

  @override
  String get menu_reorderBackTooltip => 'Zurück zu den Bereichen';

  @override
  String get menu_reorderResetToDefaults => 'Auf Standard zurücksetzen';

  @override
  String get menu_customizeMenuButton => 'Menü anpassen';

  @override
  String get menu_navStop => 'Stopp';

  @override
  String get menu_navBack => 'Zurück';

  @override
  String get menu_navForward => 'Vorwärts';

  @override
  String get menu_navCloseTab => 'Schließen';

  @override
  String get menu_navReload => 'Neu laden';

  @override
  String get menu_navCloseOthers => 'Andere schließen';

  @override
  String get menu_navCloseFromSameHost => 'Tabs derselben Website schließen';

  @override
  String get menu_navCloseTabAndDescendants => 'Tab und Unter-Tabs schließen';

  @override
  String get menu_navHardRefresh => 'Vollständig neu laden';

  @override
  String get menu_profileTapToSwitch => 'Tippen, um das Profil zu wechseln';

  @override
  String get menu_profileSyncComplete => 'Synchronisierung abgeschlossen';

  @override
  String menu_openInApp(String appName) {
    return 'In $appName öffnen';
  }

  @override
  String get menu_pageTranslated => 'Übersetzt';

  @override
  String get menu_extensionsTitle => 'Erweiterungen';

  @override
  String get menu_extensionFallbackTitle => 'Erweiterung';

  @override
  String get menu_extensionsSettingsTooltip => 'Einstellungen der Erweiterung';

  @override
  String get menu_extensionsManage => 'Erweiterungen verwalten';

  @override
  String get menu_containersExpansionTitle => 'Container';

  @override
  String get menu_containersManage => 'Container verwalten';

  @override
  String get menu_containersAssign => 'Container zuweisen';

  @override
  String get menu_containersAssignUrl => 'URL dem Container zuordnen';

  @override
  String get menu_containersUnassignUrl =>
      'URL-Zuordnung zum Container aufheben';

  @override
  String get menu_containersUnassign => 'Container-Zuweisung aufheben';

  @override
  String get menu_shareExpansionTitle => 'Teilen';

  @override
  String get menu_shareUrlCleaned => 'URL bereinigt';

  @override
  String get menu_shareUrlPreviewApplied => 'URL-Vorschau übernommen';

  @override
  String get menu_shareCopyAddress => 'Adresse kopieren';

  @override
  String get menu_shareScreenshot => 'Screenshot teilen';

  @override
  String get menu_shareLink => 'Link teilen';

  @override
  String get menu_shareShowQrCode => 'QR-Code anzeigen';

  @override
  String get menu_sendToDeviceExpansionTitle => 'An Gerät senden';

  @override
  String get menu_sendToDeviceNone => 'Keine Zielgeräte';

  @override
  String get menu_sendToDeviceLoading => 'Geräte werden geladen …';

  @override
  String get menu_sendToDeviceLoadFailed =>
      'Geräte konnten nicht geladen werden';

  @override
  String menu_sendToDeviceSuccess(String deviceName) {
    return 'Tab an $deviceName gesendet';
  }

  @override
  String get menu_sendToDeviceSendFailed => 'Tab konnte nicht gesendet werden';

  @override
  String get menu_cloneTabExpansionTitle => 'Tab klonen';

  @override
  String get menu_cloneTypeRegular => 'Normal';

  @override
  String get menu_cloneTypePrivate => 'Privat';

  @override
  String get menu_cloneTypeIsolated => 'Isoliert';

  @override
  String get menu_exportExpansionTitle => 'Exportieren';

  @override
  String get menu_exportCopyAsMarkdown => 'Als Markdown kopieren';

  @override
  String get menu_exportAsMarkdown => 'Als Markdown exportieren';

  @override
  String get menu_exportAsPdf => 'Als PDF exportieren';

  @override
  String get menu_exportAsPng => 'Als PNG exportieren';

  @override
  String get menu_exportMarkdownCopied =>
      'Markdown in die Zwischenablage kopiert';

  @override
  String get menu_exportPrint => 'Drucken';

  @override
  String get menu_exportPrintFailed => 'Seite konnte nicht gedruckt werden';

  @override
  String get menu_pinUnpinFromShortcuts => 'Von Verknüpfungen lösen';

  @override
  String get menu_pinPinToShortcuts => 'An Verknüpfungen anheften';

  @override
  String get menu_pinUnpinnedMessage => 'Von Verknüpfungen gelöst';

  @override
  String get menu_pinPinnedMessage => 'An Verknüpfungen angeheftet';

  @override
  String get menu_pinUpdateFailed =>
      'Verknüpfungen konnten nicht aktualisiert werden';

  @override
  String get menu_fetchFeedsTitle => 'Feeds auf der Seite abrufen';

  @override
  String get menu_fetchFeedsNone => 'Keine Web-Feeds gefunden';

  @override
  String get menu_fetchFeedsAvailable => 'Verfügbare Web-Feeds';

  @override
  String get menu_fetchFeedsLoading => 'Web-Feeds werden abgerufen …';

  @override
  String get menu_connectionTitle => 'Verbindung';

  @override
  String get menu_connectionRegularTabs => 'Normale Tabs';

  @override
  String get menu_connectionPrivateTabs => 'Private Tabs';

  @override
  String menu_connectionAllThrough(String proxyTitle) {
    return 'Alle über $proxyTitle';
  }

  @override
  String get menu_connectionPerContainer => 'Pro Container';

  @override
  String get menu_connectionPerContainerSubtitle =>
      'Nur Container mit zugewiesenem Proxy werden umgeleitet';

  @override
  String get menu_connectionDirect => 'Direkt';

  @override
  String get menu_connectionPrivateNeverInheritSubtitle =>
      'Private Tabs übernehmen nie die globale Route';

  @override
  String get menu_connectionThisIsolatedTab => 'Dieser isolierte Tab';

  @override
  String get menu_connectionFollowsContainer => 'Folgt seinem Container';

  @override
  String get menu_connectionFollowContainerOption => 'Seinem Container folgen';

  @override
  String get menu_connectionFollowContainerOptionSubtitle =>
      'Die dem Container dieses Tabs zugewiesene Route verwenden';

  @override
  String get menu_connectionIsolatedDirectSubtitle =>
      'Die Route seines Containers umgehen';

  @override
  String get menu_connectionThisContainer => 'Dieser Container';

  @override
  String get menu_connectionFollowsGlobalRouting => 'Folgt der globalen Route';

  @override
  String get menu_connectionContainerFallbackTitle => 'Container';

  @override
  String get menu_connectionFollowGlobalRoutingOption =>
      'Globaler Route folgen';

  @override
  String get menu_connectionFollowGlobalRoutingOptionSubtitle =>
      'Dieselbe Route wie normale Tabs verwenden';

  @override
  String get menu_connectionContainerDirectSubtitle =>
      'Den globalen Proxy für diesen Container umgehen';

  @override
  String menu_connectionFailedToChangeRoute(String error) {
    return 'Route konnte nicht geändert werden: $error';
  }

  @override
  String menu_connectionProxyError(String error) {
    return 'Proxy-Fehler: $error';
  }

  @override
  String menu_connectionNotRoutedByContainer(String container) {
    return 'Nicht über Container „$container“ geleitet';
  }

  @override
  String get menu_connectionNotRoutedByTabContainer =>
      'Nicht über den Container dieses Tabs geleitet';

  @override
  String get menu_connectionCheckingRouting => 'Routing wird geprüft …';

  @override
  String get menu_connectionStartingRouting => 'Routing wird gestartet …';

  @override
  String menu_connectionBlockedNotRunning(String proxyTitle) {
    return 'Blockiert – $proxyTitle läuft nicht';
  }

  @override
  String menu_connectionThisTabVia(String proxyTitle) {
    return 'Dieser Tab: $proxyTitle';
  }

  @override
  String get menu_connectionThisTabDirect => 'Dieser Tab: direkte Verbindung';

  @override
  String menu_connectionStartProxy(String proxyTitle) {
    return '$proxyTitle starten';
  }

  @override
  String get menu_connectionProxySettings => 'Proxy-Einstellungen';

  @override
  String get menu_connectionUnused => 'Von keiner Route verwendet';

  @override
  String menu_connectionUsageContainerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Container',
      one: '1 Container',
    );
    return '$_temp0';
  }

  @override
  String menu_connectionUsageIsolatedTabCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count isolierte Tabs',
      one: '1 isolierter Tab',
    );
    return '$_temp0';
  }

  @override
  String get menu_connectionUsageBlocked => 'Blockiert';

  @override
  String get contextmenu_openInNewTab => 'In neuem Tab öffnen';

  @override
  String get contextmenu_tooltipOpenInDifferentTabType =>
      'In anderer Tab-Art öffnen';

  @override
  String get contextmenu_newRegularTab => 'Neuer normaler Tab';

  @override
  String get contextmenu_newPrivateTab => 'Neuer privater Tab';

  @override
  String get contextmenu_newIsolatedTab => 'Neuer isolierter Tab';

  @override
  String get contextmenu_openImageInNewTab => 'Bild in neuem Tab öffnen';

  @override
  String get contextmenu_openInContainer => 'In Container öffnen';

  @override
  String get contextmenu_selectContainerTitle => 'Container auswählen';

  @override
  String get contextmenu_loadContainersFailedTitle =>
      'Container konnten nicht geladen werden';

  @override
  String get contextmenu_newContainer => 'Neuer Container';

  @override
  String get contextmenu_openInApp => 'In App öffnen';

  @override
  String contextmenu_openInAppNamed(String appName) {
    return 'In $appName öffnen';
  }

  @override
  String get contextmenu_copyLink => 'Link kopieren';

  @override
  String get contextmenu_copyLinkText => 'Linktext kopieren';

  @override
  String get contextmenu_copyImage => 'Bild kopieren';

  @override
  String get contextmenu_copyImageLocation => 'Bildadresse kopieren';

  @override
  String get contextmenu_saveFile => 'Datei speichern';

  @override
  String get contextmenu_saveImage => 'Bild speichern';

  @override
  String get contextmenu_shareImage => 'Bild teilen';

  @override
  String get contextmenu_shareEmailAddress => 'E-Mail-Adresse teilen';

  @override
  String get contextmenu_urlCleanedMessage => 'URL bereinigt';

  @override
  String get contextmenu_urlPreviewAppliedMessage => 'URL-Vorschau übernommen';

  @override
  String get findInPage_hint => 'Auf Seite suchen';

  @override
  String findInPage_matchPosition(int current, int total) {
    return '$current von $total';
  }

  @override
  String get findInPage_noMatches => 'Nicht gefunden';

  @override
  String get history_titleHistory => 'Verlauf';

  @override
  String get history_titleDownloads => 'Downloads';

  @override
  String get history_filterHintHistory => 'Verlauf filtern …';

  @override
  String get history_filterHintDownloads => 'Downloads filtern …';

  @override
  String history_selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausgewählt',
      one: '1 ausgewählt',
    );
    return '$_temp0';
  }

  @override
  String get history_tooltipClearSearch => 'Suche leeren';

  @override
  String get history_tooltipSearchHistory => 'Verlauf durchsuchen';

  @override
  String get history_tooltipSearchDownloads => 'Downloads durchsuchen';

  @override
  String history_tooltipClearContainerHistory(String container) {
    return 'Verlauf für „$container“ löschen';
  }

  @override
  String get history_filterDate => 'Datum';

  @override
  String get history_filterContainer => 'Container';

  @override
  String get history_allContainers => 'Alle Container';

  @override
  String get history_unnamedContainer => 'Unbenannter Container';

  @override
  String history_containerFilterLabel(String container) {
    return 'Container: $container';
  }

  @override
  String get history_resetFilter => 'Filter zurücksetzen';

  @override
  String get history_filterTypeFollowedLinks => 'Aufgerufene Links';

  @override
  String get history_filterTypeTypedAddresses => 'Eingegebene Adressen';

  @override
  String get history_filterTypeEmbeddedPageElements =>
      'Eingebettete Seitenelemente';

  @override
  String get history_filterTypePermanentRedirects =>
      'Dauerhafte Weiterleitungen';

  @override
  String get history_filterTypeTemporaryRedirects =>
      'Temporäre Weiterleitungen';

  @override
  String get history_filterTypeDownloads => 'Downloads';

  @override
  String get history_filterTypeFrames => 'Frames';

  @override
  String get history_filterTypePageReloads => 'Neu geladene Seiten';

  @override
  String get history_filterTypeBookmarks => 'Lesezeichen';

  @override
  String get history_visitTypeFollowedLink => 'Aufgerufener Link';

  @override
  String get history_visitTypeTypedAddress => 'Eingegebene Adresse';

  @override
  String get history_visitTypeEmbeddedPageElement =>
      'Eingebettetes Seitenelement';

  @override
  String get history_visitTypePermanentRedirect => 'Dauerhafte Weiterleitung';

  @override
  String get history_visitTypeTemporaryRedirect => 'Temporäre Weiterleitung';

  @override
  String get history_visitTypeDownload => 'Download';

  @override
  String get history_visitTypeFrame => 'Frame';

  @override
  String get history_visitTypePageReload => 'Neu geladen';

  @override
  String get history_visitTypeBookmark => 'Lesezeichen';

  @override
  String get history_clearContainerHistoryTitle => 'Container-Verlauf löschen';

  @override
  String history_clearContainerHistoryContent(String container) {
    return 'Den gesamten Verlauf für „$container“ löschen?';
  }

  @override
  String get history_downloadedFileNotFound =>
      'Heruntergeladene Datei nicht gefunden';

  @override
  String get history_couldNotOpenDownloadedFile =>
      'Die heruntergeladene Datei konnte nicht geöffnet werden';

  @override
  String get history_loadHistoryFailedTitle =>
      'Verlauf konnte nicht geladen werden';

  @override
  String get history_loadDownloadsFailedTitle =>
      'Downloads konnten nicht geladen werden';

  @override
  String get history_deleteFileTitle => 'Datei löschen';

  @override
  String history_deleteFileConfirm(String fileName) {
    return '$fileName löschen?';
  }

  @override
  String get history_deleteFileWarning =>
      'Dadurch wird die Datei endgültig vom Gerät gelöscht.';

  @override
  String get history_deleteFileRememberChoice =>
      'Auswahl für die übrigen Dateien übernehmen';

  @override
  String get history_deleteFileActionKeep => 'Behalten';

  @override
  String get openLinkTools_openLinkTitle => 'Link öffnen';

  @override
  String get openLinkTools_urlCleanedMessage => 'URL bereinigt';

  @override
  String get openLinkTools_urlPreviewAppliedMessage =>
      'URL-Vorschau übernommen';

  @override
  String get openLinkTools_urlBlockedByClearUrls =>
      'URL von ClearURLs blockiert';

  @override
  String openLinkTools_unshortenFailedWithError(String error) {
    return 'Kurzlink konnte nicht aufgelöst werden: $error';
  }

  @override
  String openLinkTools_unshortenRemainingCalls(int remaining, int limit) {
    return 'Verbleibende Aufrufe: $remaining/$limit';
  }

  @override
  String get openLinkTools_unshortenTileTitle => 'Kurzlink auflösen';

  @override
  String get openLinkTools_unshortenTileSubtitle => 'Gekürzte URL auflösen';

  @override
  String get openLinkTools_unshortenerInfoTooltip =>
      'Infos zur Kurzlink-Auflösung';

  @override
  String openLinkTools_openInAppNamed(String appName) {
    return 'In $appName öffnen';
  }

  @override
  String get openLinkTools_openInAppGeneric => 'In App öffnen';

  @override
  String get openLinkTools_openInAppSubtitle =>
      'In einer installierten App öffnen';

  @override
  String get openLinkTools_couldNotOpenInApp =>
      'Konnte nicht in der App geöffnet werden';

  @override
  String get openLinkTools_openInNewTabTitle => 'In neuem Tab öffnen';

  @override
  String get openLinkTools_openInNewTabSubtitle =>
      'Zu den Browser-Tabs hinzufügen';

  @override
  String get openLinkTools_openInCustomTabTitle => 'In Custom Tab öffnen';

  @override
  String get openLinkTools_openInCustomTabSubtitle =>
      'In einem separaten Fenster öffnen';

  @override
  String get openLinkTools_unshortenerAttributionTitle =>
      'Quellenangabe zur Kurzlink-Auflösung';

  @override
  String openLinkTools_unshortenerAttributionBody(String service) {
    return 'Dieses Modul löst Kurzlinks auf, indem es sie an $service sendet. Der Dienst prüft jeden Link auf seinen Servern und speichert die Weiterleitung für spätere Anfragen. Keine Links senden, die private oder sensible Daten enthalten.';
  }

  @override
  String get openLinkTools_unshortenerRateLimitNotice =>
      'Die kostenlose API ist für neue Prüfungen auf 10 Anfragen pro Stunde begrenzt.';

  @override
  String openLinkTools_privacyPolicyLabel(String link) {
    return 'Datenschutzerklärung: $link';
  }

  @override
  String get openLinkTools_removeTrackingParametersTitle =>
      'Tracking-Parameter entfernen';

  @override
  String get openLinkTools_removeTrackingParametersSubtitle =>
      'Parameter auswählen, die aus dieser URL entfernt werden sollen.';

  @override
  String get openLinkTools_referralMarketingBadge => 'Empfehlungsmarketing';

  @override
  String openLinkTools_selectedForRemovalCount(int selected, int total) {
    return '$selected von $total zum Entfernen ausgewählt';
  }

  @override
  String get openLinkTools_cleanedUrlLabel => 'Bereinigte URL:';

  @override
  String get openLinkTools_restoreDefaultsTitle => 'Standard wiederherstellen?';

  @override
  String get openLinkTools_restoreDefaultsContent =>
      'Dadurch werden die Einstellungen der URL-Bereinigung zurückgesetzt und der lokal gespeicherte Katalog entfernt.';

  @override
  String get openLinkTools_actionRestore => 'Wiederherstellen';

  @override
  String get openLinkTools_actionApplyChanges => 'Änderungen übernehmen';

  @override
  String openLinkTools_couldNotOpenLink(String url) {
    return 'Link konnte nicht geöffnet werden: $url';
  }

  @override
  String get openLinkTools_tileTitleCleaned => 'URL bereinigt';

  @override
  String openLinkTools_tileSubtitleRemovedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tracking-Parameter entfernt',
      one: '1 Tracking-Parameter entfernt',
    );
    return '$_temp0';
  }

  @override
  String get openLinkTools_tileTitlePartiallyCleaned =>
      'URL teilweise bereinigt';

  @override
  String openLinkTools_tileSubtitlePartiallyCleaned(int removed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$removed von $total Tracking-Parametern entfernt',
      one: '$removed von 1 Tracking-Parameter entfernt',
    );
    return '$_temp0';
  }

  @override
  String get openLinkTools_tileTitleTrackingDetected => 'Tracking erkannt';

  @override
  String openLinkTools_tileSubtitleFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tracking-Parameter gefunden',
      one: '1 Tracking-Parameter gefunden',
    );
    return '$_temp0';
  }

  @override
  String get openLinkTools_cleanUrlTooltip => 'URL bereinigen';

  @override
  String get openLinkTools_unshortenerSettingsTitle => 'Kurzlink-Auflösung';

  @override
  String get openLinkTools_unshortenerSettingsSubtitle =>
      'Verhalten beim Auflösen von Kurzlinks, Token-Einrichtung und Quellenangabe.';

  @override
  String get openLinkTools_unshortenerEnabledTitle =>
      'Kurzlink-Auflösung aktivieren';

  @override
  String get openLinkTools_unshortenerEnabledKeywords =>
      'Kurzlinks, Kurz-URL, unshorten';

  @override
  String get openLinkTools_unshortenerEnabledSubtitle =>
      'Gekürzte URLs zu ihrem Ziel auflösen';

  @override
  String get openLinkTools_descriptionLabel => 'Beschreibung';

  @override
  String get openLinkTools_unshortenerDescriptionBody =>
      'Dieses Modul löst Kurzlinks auf, indem es sie an unshorten.me sendet. Der Dienst prüft jeden Link auf seinen Servern und speichert die Weiterleitung für spätere Anfragen. Keine Links senden, die private oder sensible Daten enthalten.';

  @override
  String get openLinkTools_attributionServiceLabel => 'Dienst';

  @override
  String get openLinkTools_attributionPrivacyPolicyLabel =>
      'Datenschutzerklärung';

  @override
  String get openLinkTools_apiTokenLabel => 'API-Token';

  @override
  String get openLinkTools_apiTokenLabelKeywords => 'Token, Schlüssel';

  @override
  String get openLinkTools_apiTokenHint => 'Optionales Token für höhere Limits';

  @override
  String get openLinkTools_urlCleanerSettingsTitle => 'URL-Bereinigung';

  @override
  String get openLinkTools_urlCleanerSettingsSubtitle =>
      'Verhalten der URL-Bereinigung, Aktualisierung des Regelkatalogs und Quellenangabe.';

  @override
  String get openLinkTools_urlCleanerDescriptionBody =>
      'Dieses Modul entfernt Tracking-, Referrer- und andere unnötige Parameter aus URLs. Außerdem kann es gängige URL-Weiterleitungen offline auflösen.';

  @override
  String get openLinkTools_urlCleanerEnabledTitle =>
      'URL-Bereinigung aktivieren';

  @override
  String get openLinkTools_urlCleanerEnabledKeywords =>
      'URLs bereinigen, clean urls, Tracking';

  @override
  String get openLinkTools_urlCleanerEnabledSubtitle =>
      'Tracking-Parameter aus URLs entfernen';

  @override
  String get openLinkTools_autoApplyTitle => 'Automatisch anwenden';

  @override
  String get openLinkTools_autoApplyKeywords => 'automatisch anwenden, auto';

  @override
  String get openLinkTools_autoApplySubtitle =>
      'Die URL automatisch durch eine bereinigte Version ersetzen';

  @override
  String get openLinkTools_allowReferralTitle =>
      'Empfehlungsmarketing erlauben';

  @override
  String get openLinkTools_allowReferralKeywords =>
      'Affiliate, Empfehlung, Referral, Partnerprogramm';

  @override
  String get openLinkTools_allowReferralSubtitle =>
      'Tracking-Parameter für Empfehlungs- und Partnerprogramme behalten';

  @override
  String get openLinkTools_autoUpdateCatalogTitle =>
      'Katalog automatisch aktualisieren';

  @override
  String get openLinkTools_autoUpdateCatalogSubtitle =>
      'Wöchentlich nach Regelaktualisierungen suchen';

  @override
  String get openLinkTools_updateCatalogTitle => 'Katalog aktualisieren';

  @override
  String get openLinkTools_lastUpdateNotAvailable =>
      'Letzte Aktualisierung: nicht verfügbar';

  @override
  String openLinkTools_lastUpdateWithDate(String date) {
    return 'Letzte Aktualisierung: $date';
  }

  @override
  String openLinkTools_lastAutoUpdateWithDate(String date) {
    return 'Letzte Aktualisierung: $date (automatisch)';
  }

  @override
  String openLinkTools_lastCheckWithDate(String date) {
    return 'Letzte Prüfung: $date';
  }

  @override
  String get openLinkTools_catalogUpdatedMessage => 'Katalog aktualisiert';

  @override
  String openLinkTools_updateFailedWithError(String error) {
    return 'Aktualisierung fehlgeschlagen: $error';
  }

  @override
  String get openLinkTools_restoreDefaultsButtonTitle =>
      'Standard wiederherstellen';

  @override
  String get openLinkTools_restoreDefaultsButtonSubtitle =>
      'Auf den mitgelieferten Katalog und die Standardeinstellungen zurücksetzen';

  @override
  String get openLinkTools_clearUrlAttributionText =>
      'Dieses Modul basiert auf den ClearURLs-Regeln:';

  @override
  String get openLinkTools_urlCleanerOverviewSectionTitle => 'Übersicht';

  @override
  String get openLinkTools_indexUrlCleanerDescriptionTitle => 'Beschreibung';

  @override
  String get openLinkTools_indexUrlCleanerDescriptionKeywords =>
      'Tracking-Parameter, Weiterleitungen';

  @override
  String get openLinkTools_indexUrlCleanerDescriptionSubtitle =>
      'Entfernen von Tracking-Parametern und Offline-Auflösung von Weiterleitungen';

  @override
  String get openLinkTools_urlCleanerBehaviorSectionTitle => 'Verhalten';

  @override
  String get openLinkTools_urlCleanerCatalogSectionTitle => 'Katalog';

  @override
  String get openLinkTools_indexUrlCleanerUpdateCatalogSubtitle =>
      'Die neuesten Regeln der URL-Bereinigung abrufen';

  @override
  String get openLinkTools_urlCleanerAttributionSectionTitle => 'Quellenangabe';

  @override
  String get openLinkTools_indexUrlCleanerAttributionTitle => 'Quellenangabe';

  @override
  String get openLinkTools_indexUrlCleanerAttributionSubtitle =>
      'Danksagungen und Quelllinks';

  @override
  String get openLinkTools_unshortenerOverviewSectionTitle => 'Übersicht';

  @override
  String get openLinkTools_indexUnshortenerDescriptionTitle => 'Beschreibung';

  @override
  String get openLinkTools_indexUnshortenerDescriptionKeywords =>
      'Kurzlinks, Weiterleitungen';

  @override
  String get openLinkTools_indexUnshortenerDescriptionSubtitle =>
      'Gekürzte URLs über den Dienst unshorten.me auflösen';

  @override
  String get openLinkTools_unshortenerBehaviorSectionTitle => 'Verhalten';

  @override
  String get openLinkTools_indexUnshortenerApiTokenSubtitle =>
      'Optionales Token für höhere Anfragelimits';

  @override
  String get openLinkTools_unshortenerAttributionSectionTitle =>
      'Quellenangabe';

  @override
  String get openLinkTools_indexUnshortenerAttributionTitle =>
      'Angaben zum Dienst';

  @override
  String get openLinkTools_indexUnshortenerAttributionKeywords =>
      'Datenschutzerklärung, Anfragelimit, Limit';

  @override
  String get openLinkTools_indexUnshortenerAttributionSubtitle =>
      'Anfragelimits, Website des Dienstes und Datenschutzerklärung';

  @override
  String get pwa_addToHomeScreenTitle => 'Zum Startbildschirm hinzufügen';

  @override
  String get pwa_nameFieldLabel => 'Name';

  @override
  String get pwa_storageLabel => 'Speicher';

  @override
  String get pwa_defaultContainerLabel => 'Container';

  @override
  String get pwa_installAsAppTitle => 'Als App installieren';

  @override
  String get pwa_installAsAppSubtitle =>
      'Läuft eigenständig in einem eigenen Fenster.';

  @override
  String get pwa_addShortcutTitle => 'Verknüpfung hinzufügen';

  @override
  String get pwa_addShortcutSubtitle =>
      'Öffnet sich als normaler Tab im Browser.';

  @override
  String get pwa_storageDefaultTitle => 'Standard';

  @override
  String get pwa_storageDefaultSubtitle =>
      'Verwendet den Standardspeicher des Browsers (kein Container).';

  @override
  String pwa_storageContainerTitle(String label) {
    return 'Container „$label“';
  }

  @override
  String get pwa_storageContainerSubtitle =>
      'Teilt Cookies und Daten mit dem ausgewählten Container.';

  @override
  String get pwa_storageInheritIsolatedTitle =>
      'Aktuellen isolierten Kontext übernehmen';

  @override
  String get pwa_storageInheritIsolatedSubtitle =>
      'Teilt den Speicher mit der gerade geöffneten isolierten Sitzung.';

  @override
  String get pwa_storageNewIsolatedTitle => 'Neuer isolierter Kontext';

  @override
  String get pwa_storageNewIsolatedSubtitle =>
      'Legt einen frischen Speicherbereich nur für diese Installation an.';

  @override
  String get pwa_defaultWebAppName => 'diese Web-App';

  @override
  String get pwa_defaultSiteName => 'diese Website';

  @override
  String pwa_addedToHomeScreen(String name) {
    return 'Zum Startbildschirm hinzugefügt: $name';
  }

  @override
  String pwa_installFailedManifestBacked(String name) {
    return 'Hinzufügen von $name fehlgeschlagen. Die Website unterstützt die Installation möglicherweise nicht.';
  }

  @override
  String pwa_installFailedGeneric(String name) {
    return 'Hinzufügen von $name zum Startbildschirm fehlgeschlagen';
  }

  @override
  String get pwa_noTabSelected =>
      'Kein Tab ausgewählt. Bitte erneut versuchen.';

  @override
  String get search_moduleLabelRecentSearches => 'Letzte Suchen';

  @override
  String get search_moduleLabelSearchProviders => 'Suchanbieter';

  @override
  String get search_moduleLabelSearchSuggestions => 'Vorschläge';

  @override
  String get search_moduleLabelTabs => 'Tabs';

  @override
  String get search_moduleLabelArticles => 'Artikel';

  @override
  String get search_moduleLabelBookmarks => 'Lesezeichen';

  @override
  String get search_moduleLabelHistory => 'Verlauf (Engine)';

  @override
  String get search_moduleLabelLocalHistory => 'Lokale Inhalte';

  @override
  String get search_moduleLabelCombinedHistory => 'Verlauf';

  @override
  String get search_moduleLabelPopularSites => 'Beliebte Websites';

  @override
  String get search_moduleLabelHistoryHighlights => 'Verlaufs-Highlights';

  @override
  String get search_moduleLabelTopSites => 'Verknüpfungen';

  @override
  String get search_moduleLabelRecentHistory => 'Kürzlich besucht';

  @override
  String get search_moduleLabelRecentArticles => 'Neueste Artikel';

  @override
  String get search_moduleLabelRecentTabs => 'Letzte Tabs';

  @override
  String get search_moduleLabelContainers => 'Container';

  @override
  String get search_moduleLabelFrequentBangs => 'Häufige Bangs';

  @override
  String get search_moduleLabelQuote => 'Zitat';

  @override
  String get search_moduleLabelQuickActions => 'Schnellaktionen';

  @override
  String get search_couldNotLoadHistory =>
      'Verlauf konnte nicht geladen werden';

  @override
  String get search_couldNotLoadLocalContent =>
      'Lokale Inhalte konnten nicht geladen werden';

  @override
  String get search_failedSearchingArticles => 'Artikelsuche fehlgeschlagen';

  @override
  String get search_contentMatchTooltip => 'Treffer im Inhalt';

  @override
  String get search_tabTypeRegular => 'Normal';

  @override
  String get search_tabTypeChild => 'Unter-Tab';

  @override
  String get search_tabTypePrivate => 'Privat';

  @override
  String get search_tabTypeIsolated => 'Isoliert';

  @override
  String get search_fillLinkFromClipboard => 'Link aus Zwischenablage einfügen';

  @override
  String get search_actionNewTab => 'Neuer Tab';

  @override
  String get search_actionViewTabs => 'Tabs anzeigen';

  @override
  String get search_actionResumeLastTab => 'Letzten Tab fortsetzen';

  @override
  String get search_bangTabAllProviders => 'Alle Anbieter';

  @override
  String get search_bangTabSearchOnThisSite => 'Auf dieser Website suchen';

  @override
  String get search_editShortcutDialogTitle => 'Verknüpfung bearbeiten';

  @override
  String get search_addShortcut => 'Verknüpfung hinzufügen';

  @override
  String get search_titleFieldLabel => 'Titel';

  @override
  String get search_urlFieldLabel => 'URL';

  @override
  String get search_titleCannotBeEmpty => 'Der Titel darf nicht leer sein';

  @override
  String get search_urlCannotBeEmpty => 'Die URL darf nicht leer sein';

  @override
  String get search_enterValidUrl => 'Eine gültige URL eingeben';

  @override
  String get search_actionPin => 'Anheften';

  @override
  String get search_actionUnpin => 'Lösen';

  @override
  String get search_actionResetFrequency => 'Häufigkeit zurücksetzen';

  @override
  String get search_actionEditBang => 'Bang bearbeiten';

  @override
  String get search_actionCustomizeAsOwnBang => 'Als eigenen Bang anpassen';

  @override
  String search_resetBangDialogTitle(String triggerName) {
    return 'Nutzungshäufigkeit von $triggerName zurücksetzen?';
  }

  @override
  String get search_resetBangDialogContent =>
      'Dadurch wird der Bang aus der Schnellauswahl entfernt.';

  @override
  String get search_customizeSectionsButton => 'Bereiche anpassen';

  @override
  String get search_customizeSectionsHeading => 'Bereiche anpassen';

  @override
  String get search_resetToDefaults => 'Auf Standard zurücksetzen';

  @override
  String search_showAllCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count anzeigen',
    );
    return '$_temp0';
  }

  @override
  String get search_disableReorderingMode => 'Anordnungsmodus beenden';

  @override
  String get search_enableReorderingMode => 'Anordnungsmodus starten';

  @override
  String get search_dragDropShortcutsHint =>
      'Verknüpfungen zum Anordnen ziehen und ablegen';

  @override
  String get search_failedReorderShortcut =>
      'Verknüpfung konnte nicht verschoben werden';

  @override
  String search_hideAllFromHost(String host) {
    return 'Alle von $host ausblenden';
  }

  @override
  String search_pinnedSite(String title) {
    return '„$title“ angeheftet';
  }

  @override
  String get search_failedPinSite => 'Website konnte nicht angeheftet werden';

  @override
  String get search_shortcutUpdated => 'Verknüpfung aktualisiert';

  @override
  String get search_failedUpdateShortcut =>
      'Verknüpfung konnte nicht aktualisiert werden';

  @override
  String search_addedSite(String title) {
    return '„$title“ hinzugefügt';
  }

  @override
  String get search_failedAddShortcut =>
      'Verknüpfung konnte nicht hinzugefügt werden';

  @override
  String search_hidAllShortcutsFromHost(String host) {
    return 'Alle Verknüpfungen von $host ausgeblendet';
  }

  @override
  String search_removedSite(String title) {
    return '„$title“ entfernt';
  }

  @override
  String get search_failedRemoveShortcut =>
      'Verknüpfung konnte nicht entfernt werden';

  @override
  String get search_quoteCardTitle => 'Ein Gedanke für unterwegs';

  @override
  String get search_refreshQuoteTooltip => 'Neues Zitat';

  @override
  String get search_quotePlaceholder =>
      'Einen neuen Tab öffnen und diesen Platz mit Leben füllen.';

  @override
  String get search_searchFieldLabel => 'Suchen oder URL eingeben';

  @override
  String get search_invalidAddress => 'Ungültige Adresse';

  @override
  String get tabs_actionSelect => 'Auswählen';

  @override
  String get tabs_actionUnselect => 'Abwählen';

  @override
  String get tabs_unsavedChangesTitle => 'Ungespeicherte Änderungen';

  @override
  String get tabs_unsavedChangesConfirm =>
      'Es gibt ungespeicherte Änderungen. Verwerfen oder speichern?';

  @override
  String get tabs_deleteContainerTitle => 'Container löschen';

  @override
  String get tabs_deleteContainerConfirm =>
      'Diesen Container löschen? Seine Tabs werden geschlossen.';

  @override
  String get tabs_deleteContainerAlsoDeleteHistory =>
      'Auch den Browserverlauf löschen';

  @override
  String get tabs_deleteContainerHistoryKeptNote =>
      'Ohne Häkchen bleiben die Besuche im Verlauf, sind aber keinem Container mehr zugeordnet.';

  @override
  String get tabs_deleteContainerButton => 'Container löschen';

  @override
  String get tabs_containersTitle => 'Container';

  @override
  String get tabs_noContainersYet => 'Noch keine Container';

  @override
  String get tabs_loadContainersFailedTitle =>
      'Container konnten nicht geladen werden';

  @override
  String get tabs_containerFabLabel => 'Neuer Container';

  @override
  String get tabs_untitledContainer => 'Unbenannt';

  @override
  String get tabs_emptyContainerLabel => 'Leer';

  @override
  String tabs_tabCountChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tabs',
      one: '1 Tab',
    );
    return '$_temp0';
  }

  @override
  String get tabs_chipPinned => 'Angeheftet';

  @override
  String get tabs_chipIsolated => 'Isoliert';

  @override
  String get tabs_chipDirect => 'Direkt';

  @override
  String get tabs_chipClearOnExit => 'Beim Beenden leeren';

  @override
  String get tabs_chipActive => 'Aktiv';

  @override
  String get tabs_selectContainerTitle => 'Container auswählen';

  @override
  String get tabs_unassignedTitle => 'Nicht zugeordnet';

  @override
  String get tabs_unassignedSubtitle =>
      'Tabs, die keinem Container zugeordnet sind';

  @override
  String get tabs_draftContainersTitle => 'Vorgeschlagene Container';

  @override
  String get tabs_suggestionsFailedTitle =>
      'Vorschläge konnten nicht geladen werden';

  @override
  String get tabs_siteAssignmentsTitle => 'Website-Zuordnungen';

  @override
  String get tabs_addSiteLabel => 'Website hinzufügen';

  @override
  String get tabs_addSiteHint => 'example.com oder *.example.com';

  @override
  String get tabs_addSiteHelperText =>
      'Eine einzelne Website angeben oder mit *.example.com alle ihre Subdomains erfassen';

  @override
  String get tabs_urlMustBeProvided => 'Eine URL muss angegeben werden';

  @override
  String get tabs_invalidUrl => 'Ungültige URL';

  @override
  String get tabs_siteAlreadyAssigned => 'Diese Website ist bereits zugeordnet';

  @override
  String tabs_siteAlreadyAssignedToNamedContainer(
    String site,
    String containerName,
  ) {
    return '$site ist bereits „$containerName“ zugeordnet';
  }

  @override
  String tabs_siteAlreadyAssignedToAnotherContainer(String site) {
    return '$site ist bereits einem anderen Container zugeordnet';
  }

  @override
  String get tabs_newContainerTitle => 'Neuer Container';

  @override
  String get tabs_editContainerTitle => 'Container bearbeiten';

  @override
  String get tabs_containerNameHint => 'Name des Containers';

  @override
  String get tabs_changeColor => 'Farbe ändern';

  @override
  String get tabs_changeIcon => 'Symbol ändern';

  @override
  String get tabs_sectionDisplay => 'Darstellung';

  @override
  String get tabs_pinContainer => 'Container anheften';

  @override
  String get tabs_pinContainerSubtitle =>
      'Diesen Container oben in der Liste halten';

  @override
  String get tabs_wallpaperLabel => 'Hintergrundbild';

  @override
  String get tabs_wallpaperSelectedSubtitle =>
      'Wird auf der Startseite angezeigt, solange dieser Container ausgewählt ist';

  @override
  String get tabs_wallpaperDefaultSubtitle =>
      'Verwendet das Hintergrundbild aus den Einstellungen';

  @override
  String get tabs_wallpaperEmptyDescription =>
      'Dieser Container verwendet das in den Einstellungen festgelegte Hintergrundbild.';

  @override
  String get tabs_sectionPrivacySecurity => 'Datenschutz & Sicherheit';

  @override
  String get tabs_cookieIsolation => 'Cookie-Isolierung';

  @override
  String get tabs_proxyConnectionLabel => 'Proxy-Verbindung';

  @override
  String get tabs_proxyConnectionNone => 'Keine';

  @override
  String get tabs_bypassGlobalProxy => 'Globalen Proxy umgehen';

  @override
  String get tabs_bypassGlobalProxySubtitle =>
      'Bei aktivem globalem Routing für diesen Container die normale Verbindung verwenden';

  @override
  String get tabs_clearDataOnExit => 'Daten beim Beenden löschen';

  @override
  String get tabs_clearDataOnExitSubtitle =>
      'Cookies und Websitedaten der normalen Tabs dieses Containers beim Schließen der App löschen. Isolierte Tabs behalten eigene Daten.';

  @override
  String get tabs_excludeFromSearchIndex => 'Vom Suchindex ausschließen';

  @override
  String get tabs_excludeFromSearchIndexSubtitle =>
      'Seiten aus diesem Container nicht in den lokalen Suchindex aufnehmen';

  @override
  String get tabs_excludeFromHistory => 'Vom Verlauf ausschließen';

  @override
  String get tabs_excludeFromHistorySubtitle =>
      'Keine neuen Besuche aus den Tabs dieses Containers speichern und seine Seiten aus der lokalen Suche entfernen. Der bestehende Browserverlauf bleibt erhalten.';

  @override
  String get tabs_sectionAssignments => 'Zuordnungen';

  @override
  String get tabs_assignedSites => 'Zugeordnete Websites';

  @override
  String tabs_assignedSitesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Regeln eingerichtet',
      one: '1 Regel eingerichtet',
    );
    return '$_temp0';
  }

  @override
  String get tabs_assignedSitesEmptySubtitle =>
      'Passende Websites in diesem Container öffnen';

  @override
  String get tabs_strictMode => 'Strikter Modus';

  @override
  String get tabs_strictModeSubtitle =>
      'Nur zugeordnete Websites laden; alles andere blockieren';

  @override
  String get tabs_requiresCookieIsolation =>
      'Erfordert aktivierte Cookie-Isolierung';

  @override
  String get tabs_sectionAppLinks => 'App-Links';

  @override
  String get tabs_isolatedAppLinkSettings => 'Eigene App-Link-Einstellungen';

  @override
  String get tabs_isolatedAppLinkSettingsSubtitle =>
      'Für diesen Container einen eigenen Modus für das Öffnen in Apps und eigene gespeicherte Website-Regeln statt der globalen Einstellungen verwenden';

  @override
  String get tabs_appLinkBehavior => 'App-Link-Verhalten';

  @override
  String get tabs_appLinkBehaviorSubtitle =>
      'Modus für das Öffnen in Apps und gespeicherte Websites dieses Containers einrichten';

  @override
  String get tabs_selectColorTitle => 'Farbe auswählen';

  @override
  String get tabs_customColorTitle => 'Eigene Farbe';

  @override
  String get tabs_hexLabel => 'Hex';

  @override
  String get tabs_hueLabel => 'Farbton';

  @override
  String get tabs_saturationLabel => 'Sättigung';

  @override
  String get tabs_lightnessLabel => 'Helligkeit';

  @override
  String get tabs_chooseIconTitle => 'Symbol auswählen';

  @override
  String tabs_iconCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count MDI-Symbole',
      one: '1 MDI-Symbol',
    );
    return '$_temp0';
  }

  @override
  String get tabs_searchIconsHint => 'MDI-Symbole suchen';

  @override
  String get tabs_noIconsFound => 'Keine Symbole gefunden.';

  @override
  String get gestures_screenTitle => 'Gesten';

  @override
  String get gestures_builtInGestureKeywords => 'wischen, Wischgeste, swipe';

  @override
  String get gestures_resetSwipesToDefaultsAction => 'Wischgesten zurücksetzen';

  @override
  String get gestures_twoFingerSwipeTitle => 'Mit zwei Fingern wischen';

  @override
  String get gestures_twoFingerSwipeKeywords => 'Container';

  @override
  String get gestures_twoFingerSwipeAction =>
      'Nächster oder vorheriger Container';

  @override
  String get gestures_pinchTitle => 'Zusammenziehen';

  @override
  String get gestures_pinchKeywords =>
      'Raster, Liste, Baum, Layout, zoomen, Pinch';

  @override
  String get gestures_pinchAction => 'Raster-, Listen- oder Baumansicht';

  @override
  String get gestures_webPagesSectionTitle => 'Webseiten';

  @override
  String get gestures_drawnGesturesTitle => 'Gezeichnete Gesten';

  @override
  String get gestures_drawnGesturesKeywords => 'Strich, zeichnen, Mausgesten';

  @override
  String get gestures_drawnGesturesSubtitle =>
      'Striche auf einer Seite zeichnen, um Aktionen auszuführen';

  @override
  String get gestures_gestureBindingsTitle => 'Gestenzuweisungen';

  @override
  String get gestures_gestureBindingsSubtitle => 'Striche und ihre Aktionen';

  @override
  String get gestures_behaviorTimingTitle => 'Verhalten & Timing';

  @override
  String get gestures_behaviorTimingSubtitleShort =>
      'Strichlänge, Zeitlimit, Sperrzeit';

  @override
  String get gestures_excludedSitesTitle => 'Ausgenommene Websites';

  @override
  String get gestures_excludedSitesSubtitle =>
      'Gesten pro Website deaktivieren';

  @override
  String get gestures_feedbackTitle => 'Rückmeldung';

  @override
  String get gestures_feedbackSubtitleShort => 'Live-Overlay und Vorschläge';

  @override
  String get gestures_pullToRefreshTitle => 'Zum Aktualisieren ziehen';

  @override
  String get gestures_pullToRefreshKeywords => 'neu laden, aktualisieren';

  @override
  String get gestures_pullToRefreshSubtitle =>
      'Oben auf einer Seite nach unten wischen, um sie neu zu laden';

  @override
  String get gestures_toolbarSectionTitle => 'Symbolleiste';

  @override
  String get gestures_longPressButtonsTitle =>
      'Langes Drücken auf Schaltflächen';

  @override
  String get gestures_longPressButtonsSubtitle =>
      'Wird beim Anpassen der Symbolleiste pro Schaltfläche festgelegt';

  @override
  String get gestures_builtInCannotBeChangedDescription =>
      'Integriert, nicht änderbar';

  @override
  String get gestures_doNothingTitle => 'Nichts tun';

  @override
  String get gestures_doNothingSubtitle => 'Die Wischgeste wird ignoriert';

  @override
  String get gestures_restoreDefaultGesturesTooltip =>
      'Standardgesten wiederherstellen';

  @override
  String get gestures_addGestureButtonLabel => 'Geste hinzufügen';

  @override
  String get gestures_restoreDefaultGesturesConfirmTitle =>
      'Standardgesten wiederherstellen?';

  @override
  String get gestures_restoreDefaultGesturesConfirmContent =>
      'Jede Geste erhält wieder ihre Standardaktion. Eigene Änderungen gehen verloren.';

  @override
  String get gestures_noGesturesAssignedMessage =>
      'Noch keine Gesten zugewiesen.';

  @override
  String get gestures_replaceExistingGestureTitle =>
      'Vorhandene Geste ersetzen?';

  @override
  String gestures_replaceExistingGestureContent(String action) {
    return 'Dieser Strich ist bereits „$action“ zugewiesen. Beim Speichern wird diese Zuweisung ersetzt.';
  }

  @override
  String get gestures_createGestureTitle => 'Geste erstellen';

  @override
  String get gestures_editGestureTitle => 'Geste bearbeiten';

  @override
  String get gestures_targetActionLabel => 'Zielaktion';

  @override
  String get gestures_startPositionLabel => 'Startposition';

  @override
  String get gestures_fingersLabel => 'Finger';

  @override
  String get gestures_strokePatternLabel => 'Strichmuster';

  @override
  String get gestures_drawStrokePatternPlaceholder =>
      'Unten ein Strichmuster zeichnen';

  @override
  String get gestures_undoLastAction => 'Letzten rückgängig';

  @override
  String get gestures_replaceGestureButtonLabel => 'Geste ersetzen';

  @override
  String get gestures_saveGestureButtonLabel => 'Geste speichern';

  @override
  String gestures_collisionWarning(String action) {
    return 'Bereits „$action“ zugewiesen. Beim Speichern wird die bestehende Zuweisung ersetzt.';
  }

  @override
  String get gestures_chooseActionTitle => 'Aktion auswählen';

  @override
  String get gestures_behaviorTimingScreenSubtitle =>
      'Strichlänge, Zeitlimit und Sperrzeit.';

  @override
  String get gestures_resetToDefaultsTooltip => 'Auf Standard zurücksetzen';

  @override
  String get gestures_resetBehaviorTimingConfirmTitle =>
      'Verhalten & Timing zurücksetzen?';

  @override
  String get gestures_resetBehaviorTimingConfirmContent =>
      'Strichlänge, Zeitlimit, Sperrzeit und Strichintervall werden auf ihre Standardwerte zurückgesetzt. Gestenzuweisungen und andere Einstellungen bleiben erhalten.';

  @override
  String get gestures_minStrokeLengthTitle => 'Minimale Strichlänge';

  @override
  String get gestures_minStrokeLengthKeywords =>
      'Größe, Länge, Empfindlichkeit';

  @override
  String get gestures_timeoutTitle => 'Zeitlimit';

  @override
  String get gestures_timeoutKeywords => 'Verzögerung, Timeout';

  @override
  String get gestures_timeoutDescription =>
      'Ein Strich wird verworfen, wenn innerhalb dieser Zeit keine neue Richtung gezeichnet wird.';

  @override
  String get gestures_cooldownTitle => 'Sperrzeit';

  @override
  String get gestures_cooldownKeywords => 'Intervall, Abklingzeit, Cooldown';

  @override
  String get gestures_cooldownDescription =>
      'Mindestabstand zwischen dem Auslösen zweier Gesten.';

  @override
  String get gestures_strokeIntervalTitle => 'Strichintervall';

  @override
  String get gestures_strokeIntervalKeywords =>
      'Entprellen, Zittern, versehentlich';

  @override
  String get gestures_strokeIntervalDescription =>
      'Mindestzeit zwischen Richtungswechseln innerhalb einer Geste. Schnellere Wechsel brechen die Geste ab und verhindern so versehentliches Auslösen.';

  @override
  String get gestures_offLabel => 'Aus';

  @override
  String get gestures_excludedSitesDescription =>
      'Auf diesen Websites sind Gesten deaktiviert. Subdomains sind eingeschlossen („example.com“ umfasst z. B. auch „m.example.com“).';

  @override
  String get gestures_noSitesExcludedMessage => 'Keine Websites ausgenommen.';

  @override
  String get gestures_feedbackScreenSubtitle =>
      'Live-Overlay und Gestenvorschläge.';

  @override
  String get gestures_liveFeedbackTitle => 'Live-Rückmeldung';

  @override
  String get gestures_liveFeedbackSubtitle =>
      'Beim Zeichnen den Strich und seine Aktion anzeigen';

  @override
  String get gestures_suggestNextTitle => 'Fortsetzungen vorschlagen';

  @override
  String get gestures_suggestNextSubtitle =>
      'Auch die anderen Gesten anzeigen, die sich noch vervollständigen lassen';

  @override
  String get gestures_suggestAfterTitle => 'Vorschläge ab';

  @override
  String gestures_strokeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Striche',
      one: '1 Strich',
    );
    return '$_temp0';
  }

  @override
  String get gestures_suggestAfterDescription =>
      'Anzahl der Striche, nach denen Vorschläge erscheinen.';

  @override
  String get gestures_actionRestore => 'Wiederherstellen';

  @override
  String get gestures_actionReplace => 'Ersetzen';

  @override
  String get gestures_tabBarSurfaceTitle => 'Wischgesten auf der Tableiste';

  @override
  String get gestures_tabBarSurfaceDescription =>
      'Wischen auf der Tableiste oder der Seitenleiste';

  @override
  String get gestures_tabViewSurfaceTitle => 'Wischgesten in der Tab-Übersicht';

  @override
  String get gestures_tabViewSurfaceDescription =>
      'Wischen auf einem Tab in der Tab-Liste oder im Raster';

  @override
  String get gestures_tabBarSwipeBackwardTitle =>
      'Entlang der Leiste nach links wischen';

  @override
  String get gestures_tabBarSwipeBackwardDescription =>
      'Auf der Seitenleiste bewirkt Wischen nach oben dasselbe';

  @override
  String get gestures_tabBarSwipeForwardTitle =>
      'Entlang der Leiste nach rechts wischen';

  @override
  String get gestures_tabBarSwipeForwardDescription =>
      'Auf der Seitenleiste bewirkt Wischen nach unten dasselbe';

  @override
  String get gestures_tabBarSwipeOutwardTitle => 'Zum Bildschirmrand wischen';

  @override
  String get gestures_tabBarSwipeOutwardDescription =>
      'Nach unten bei Leiste unten, nach oben bei Leiste oben, seitlich aus der Seitenleiste heraus';

  @override
  String get gestures_tabBarSwipeInwardTitle =>
      'Vom Bildschirmrand weg wischen';

  @override
  String get gestures_tabBarSwipeInwardDescription =>
      'Nach oben bei Leiste unten, nach unten bei Leiste oben, seitlich in die Seite hinein bei Seitenleiste';

  @override
  String get gestures_tabSwipeLeftTitle => 'Tab nach links wischen';

  @override
  String get gestures_tabSwipeLeftDescription =>
      'Wirkt auf den gewischten Tab, nicht auf den geöffneten';

  @override
  String get gestures_tabSwipeRightTitle => 'Tab nach rechts wischen';

  @override
  String get gestures_tabSwipeRightDescription =>
      'Wirkt auf den gewischten Tab, nicht auf den geöffneten';

  @override
  String get gestures_startPositionAnywhere => 'Überall';

  @override
  String get gestures_startPositionLeftEdge => 'Linker Rand';

  @override
  String get gestures_startPositionRightEdge => 'Rechter Rand';

  @override
  String get gestures_startPositionTopEdge => 'Oberer Rand';

  @override
  String get gestures_startPositionBottomEdge => 'Unterer Rand';

  @override
  String get gestures_startPositionLeftHalf => 'Linke Hälfte';

  @override
  String get gestures_startPositionRightHalf => 'Rechte Hälfte';

  @override
  String get gestures_strokesSectionTitle => 'Striche';

  @override
  String get gestures_indexMinStrokeLengthSubtitle =>
      'Minimale Wischlänge, die als Richtung erkannt wird';

  @override
  String get gestures_timingSectionTitle => 'Timing';

  @override
  String get gestures_indexTimeoutSubtitle =>
      'Strich verwerfen, wenn keine neue Richtung gezeichnet wird';

  @override
  String get gestures_indexCooldownSubtitle =>
      'Mindestabstand zwischen dem Auslösen zweier Gesten';

  @override
  String get gestures_indexStrokeIntervalSubtitle =>
      'Geste verwerfen, wenn Richtungswechsel zu schnell erfolgen';

  @override
  String get gestures_overlaySectionTitle => 'Overlay';

  @override
  String get gestures_indexSuggestAfterSubtitle =>
      'Anzahl der Striche, nach denen Vorschläge erscheinen';

  @override
  String get intentGatekeeper_dialogTitle => 'Link in WebLibre öffnen?';

  @override
  String intentGatekeeper_appIsTryingToOpenLink(
    String appName,
    String browserName,
  ) {
    return '$appName möchte einen Link in $browserName öffnen.';
  }

  @override
  String get intentGatekeeper_alwaysAllow => 'Immer erlauben';

  @override
  String get intentGatekeeper_allowOnce => 'Einmal erlauben';

  @override
  String get intentGatekeeper_blockOnce => 'Einmal blockieren';

  @override
  String get intentGatekeeper_alwaysBlock => 'Immer blockieren';

  @override
  String get keyboardShortcuts_title => 'Tastenkürzel';

  @override
  String get keyboardShortcuts_searchHint => 'Aktionen oder Tasten suchen';

  @override
  String get keyboardShortcuts_noMatchingActions => 'Keine passenden Aktionen.';

  @override
  String get keyboardShortcuts_overviewNoneAssigned =>
      'Browseraktionen sind keine Tasten zugewiesen.';

  @override
  String get keyboardShortcuts_overviewDisabled =>
      'Tastenkürzel sind ausgeschaltet.';

  @override
  String get keyboardShortcuts_enableTitle => 'Tastenkürzel aktivieren';

  @override
  String get keyboardShortcuts_enableSubtitle =>
      'Browseraktionen über eine Hardwaretastatur, auch wenn eine Seite den Fokus hat';

  @override
  String get keyboardShortcuts_noShortcut => 'Kein Tastenkürzel';

  @override
  String get keyboardShortcuts_tooltipChange => 'Ändern';

  @override
  String keyboardShortcuts_tooltipRemoveChord(String chord) {
    return '$chord entfernen';
  }

  @override
  String get keyboardShortcuts_tooltipResetToDefault =>
      'Auf Standard zurücksetzen';

  @override
  String get keyboardShortcuts_addShortcut => 'Tastenkürzel hinzufügen';

  @override
  String get keyboardShortcuts_changeShortcutTitle => 'Tastenkürzel ändern';

  @override
  String get keyboardShortcuts_restoreDefaultsTooltip =>
      'Standard-Tastenkürzel wiederherstellen';

  @override
  String get keyboardShortcuts_restoreDefaultsTitle =>
      'Standard-Tastenkürzel wiederherstellen?';

  @override
  String get keyboardShortcuts_restoreDefaultsContent =>
      'Jede Aktion erhält wieder ihre Firefox-Standardtasten. Eigene Änderungen gehen verloren.';

  @override
  String keyboardShortcuts_recorderInstructions(String actionTitle) {
    return 'Tastenkombination für „$actionTitle“ drücken.';
  }

  @override
  String get keyboardShortcuts_recorderWaitingForKeys => 'Warten auf Tasten …';

  @override
  String get keyboardShortcuts_recorderProblemNotAssignable =>
      'Webseiten benötigen diese Taste. Zusammen mit Strg, Alt oder Meta drücken oder eine Funktionstaste verwenden.';

  @override
  String get keyboardShortcuts_recorderProblemAlreadyBound =>
      'Dies ist bereits ein Tastenkürzel für diese Aktion.';

  @override
  String keyboardShortcuts_recorderTakesFromOther(String ownerTitle) {
    return 'Wird derzeit von „$ownerTitle“ verwendet. Beim Speichern wird es hierher verschoben.';
  }

  @override
  String get keyboardShortcuts_actionCustomize => 'Anpassen';

  @override
  String get keyboardShortcuts_actionReassign => 'Neu zuweisen';

  @override
  String get keyboardShortcuts_actionRestore => 'Wiederherstellen';

  @override
  String get onboarding_actionPrevious => 'Zurück';

  @override
  String get onboarding_actionNext => 'Weiter';

  @override
  String get onboarding_actionRestore => 'Wiederherstellen';

  @override
  String get onboarding_restoreTargetUnreadable =>
      'Dieses Profil konnte nicht gelesen werden, daher kann nichts darin wiederhergestellt werden.';

  @override
  String get onboarding_welcomeBackTitle => 'Willkommen zurück!';

  @override
  String get onboarding_welcomeReadyTitle => 'WebLibre ist bereit';

  @override
  String get onboarding_chooseExperience => 'Art der Einrichtung wählen:';

  @override
  String get onboarding_modeExpressTitle => 'Schnellstart';

  @override
  String get onboarding_modeExpressSubtitle =>
      'Empfohlene Standardeinstellungen verwenden und lossurfen.';

  @override
  String get onboarding_modeDetailedTitle => 'Individuelle Einrichtung';

  @override
  String get onboarding_modeDetailedSubtitle =>
      'DNS, Symbolleiste, Erweiterungen und mehr einrichten.';

  @override
  String get onboarding_modeRestoreTitle => 'Aus Sicherung wiederherstellen';

  @override
  String get onboarding_modeRestoreSubtitle =>
      'Ein Profil aus einer verschlüsselten Sicherungsdatei importieren.';

  @override
  String get onboarding_updateNoticeTitle => 'Vieles hat sich geändert!';

  @override
  String get onboarding_updateNoticeBody =>
      'Dieses Update enthält wesentliche Änderungen, die eine Überprüfung der Einstellungen erfordern. Bitte die folgenden Seiten durchgehen und die Konfiguration prüfen.';

  @override
  String get onboarding_updateNoticeExtensions =>
      'Wegen bekannter Migrationsprobleme nach diesem Update bitte die Erweiterungen erneut prüfen.';

  @override
  String get onboarding_updateNoticeSettingsPreserved =>
      'Bestehende Einstellungen werden nur überschrieben, wenn sie während dieser Einrichtung ausdrücklich geändert werden.';

  @override
  String get onboarding_eulaAcceptance =>
      'Ich habe die <eula>EULA</eula> und die <privacy>Datenschutzerklärung</privacy> gelesen und akzeptiere sie.';

  @override
  String get onboarding_privacyPolicy => 'Datenschutzerklärung';

  @override
  String get onboarding_eulaDocumentTitle => 'Endbenutzer-Lizenzvertrag';

  @override
  String get onboarding_aiFeaturesTitle => 'KI-Funktionen';

  @override
  String get onboarding_aiOnDeviceTitle => 'KI auf dem Gerät';

  @override
  String get onboarding_aiOnDeviceSubtitle =>
      'Lokale Funktionen auf dem Gerät, darunter Themenvorschläge für Container und Tab-Vorschläge';

  @override
  String get onboarding_aiWarningTitle => 'Gut zu wissen';

  @override
  String get onboarding_aiWarningPoint1 =>
      'WebLibre nutzt ein lokales KI-Modell, das die Titel offener Tabs analysiert und vorschlägt, in welchen Containern die Tabs gruppiert und wie diese Container benannt werden könnten. Die gesamte Verarbeitung findet ausschließlich auf dem Gerät statt.';

  @override
  String get onboarding_aiWarningPoint2 =>
      'KI-Funktionen laufen vollständig im Browser, alle Daten bleiben auf dem Gerät. Die lokale Verarbeitung schützt die Privatsphäre und liefert schnellere Vorschläge für Container-Gruppen und -Namen. Dieses Verhalten lässt sich jederzeit in den Einstellungen anpassen.';

  @override
  String get onboarding_aiWarningPoint3 =>
      'KI kann Fehler machen – vorgeschlagene Gruppennamen und Tab-Auswahlen daher bitte prüfen.';

  @override
  String get onboarding_searchTitle => 'Suche';

  @override
  String get onboarding_searchDefaultProviderLabel => 'Standard-Suchanbieter';

  @override
  String get onboarding_searchMore => 'Weitere suchen';

  @override
  String get onboarding_searchDefaultAutocompleteLabel =>
      'Standard-Anbieter für Suchvorschläge';

  @override
  String get onboarding_searchLoadFailedTitle =>
      'Suchmaschinen konnten nicht geladen werden';

  @override
  String get onboarding_dohTitle => 'DNS über HTTPS';

  @override
  String get onboarding_permissionsTitle => 'Berechtigungen';

  @override
  String get onboarding_permissionsNotificationsTitle => 'Benachrichtigungen';

  @override
  String get onboarding_permissionsNotificationsSubtitle =>
      'Erforderlich für Benachrichtigungen über Downloads';

  @override
  String get onboarding_permissionsDefaultBrowserTitle => 'Standardbrowser';

  @override
  String get onboarding_permissionsDefaultBrowserSubtitle =>
      'WebLibre als Standardbrowser festlegen';

  @override
  String get onboarding_privacyTitle => 'Datenschutz & Härtung';

  @override
  String get onboarding_privacyBrowserLanguagesTitle => 'Browsersprachen';

  @override
  String get onboarding_privacyBrowserLanguagesSubtitle =>
      'Sprachpräferenzen festlegen, die Websites mitgeteilt werden';

  @override
  String get onboarding_multipleLanguagesDetectedTitle =>
      'Mehrere Sprachen erkannt';

  @override
  String onboarding_multipleLanguagesWarning(int count, String locales) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Im Browser sind $count Sprachen eingestellt ($locales).',
    );
    return '$_temp0 Websites können diese eindeutige Sprachkombination nutzen, um den Browser per Fingerprinting im gesamten Web wiederzuerkennen und zu verfolgen.';
  }

  @override
  String get onboarding_multipleLanguagesSuggestion =>
      'Die Browsersprachen am besten auf eine einzige reduzieren, um die Angriffsfläche für Fingerprinting zu verkleinern.';

  @override
  String get onboarding_reviewLanguages => 'Sprachen prüfen';

  @override
  String get onboarding_webEngineHardeningTitle =>
      'Vollständige Härtung der Web-Engine';

  @override
  String get onboarding_webEngineHardeningSubtitle =>
      'Alle empfohlenen Sicherheitseinstellungen auf die Web-Engine anwenden';

  @override
  String get onboarding_fingerprintProtectionTitle =>
      'Verstärkter Fingerprinting-Schutz';

  @override
  String get onboarding_fingerprintProtectionSubtitle =>
      'Umfassende Standardeinstellungen für den Fingerprinting-Schutz laden';

  @override
  String get onboarding_compatibilityWarningTitle => 'Kompatibilitätswarnung';

  @override
  String get onboarding_fingerprintWarningPoint1 =>
      'Der verstärkte Fingerprinting-Schutz aktiviert über 60 Schutzziele, darunter Canvas-Randomisierung, Navigator-Spoofing, Maskierung von Mediengeräten und mehr.';

  @override
  String get onboarding_fingerprintWarningPoint2 =>
      'Dadurch können Websites fehlerhaft oder unerwartet funktionieren. Einzelne Schutzziele lassen sich in den Einstellungen anpassen.';

  @override
  String get onboarding_localNetworkProtectionTitle =>
      'Schutz des lokalen Netzwerks';

  @override
  String get onboarding_localNetworkProtectionSubtitle =>
      'Websites können versuchen, das eigene Gerät und andere Geräte im Heimnetz zu erreichen, etwa Router, Drucker oder Smart-Home-Geräte. Bekannte Tracker werden dabei standardmäßig automatisch blockiert.';

  @override
  String get onboarding_blockAllLocalNetworkTitle =>
      'Alle Anfragen ins lokale Netzwerk blockieren';

  @override
  String get onboarding_blockAllLocalNetworkSubtitle =>
      'Vor jedem Zugriff einer Website auf Geräte im Heimnetz um Erlaubnis fragen, nicht nur bei bekannten Trackern';

  @override
  String get onboarding_toolbarLayoutTitle => 'Symbolleiste & Layout';

  @override
  String get onboarding_ublockTitle => 'uBlock Origin';

  @override
  String get onboarding_ublockDescription =>
      'uBlock Origin (uBO) ist ein CPU- und speichersparender **Inhaltsblocker mit breitem Spektrum** von **Raymond Hill** und als Browsererweiterung für WebLibre verfügbar.\n\nStandardmäßig blockiert er Werbung, Tracker, Krypto-Miner, Pop-ups, lästige Anti-Blocker, Malware-Seiten und mehr – mithilfe von **EasyList, EasyPrivacy, Peter Lowe\'s Blocklist, Online Malicious URL Blocklist und den uBO-Filterlisten**.\n\nViele weitere Listen stehen zur Verfügung, um zusätzliche Inhalte zu blockieren.';

  @override
  String get onboarding_ublockInstallTitle =>
      'Erweiterung uBlock Origin installieren';

  @override
  String get onboarding_ublockApplyDefaultsTitle =>
      'Optimierte Standardeinstellungen anwenden';

  @override
  String get onboarding_ublockApplyDefaultsSubtitle =>
      'Härtungs-Filterlisten von WebLibre aktivieren.';

  @override
  String get proxy_actionChange => 'Ändern';

  @override
  String get proxy_actionFetch => 'Abrufen';

  @override
  String get proxy_actionSelectAll => 'Alle auswählen';

  @override
  String get proxy_actionShare => 'Teilen';

  @override
  String get proxy_actionStart => 'Starten';

  @override
  String get proxy_actionStop => 'Stoppen';

  @override
  String get proxy_actionStopAndDelete => 'Stoppen und löschen';

  @override
  String get proxy_actionTestConnection => 'Verbindung testen';

  @override
  String get proxy_connectionsTitle => 'Proxy-Verbindungen';

  @override
  String get proxy_addProfile => 'Profil hinzufügen';

  @override
  String get proxy_viewLogsTooltip => 'Protokolle anzeigen';

  @override
  String get proxy_profilesSectionTitle => 'Profile';

  @override
  String proxy_loadProfilesFailed(String error) {
    return 'Proxy-Profile konnten nicht geladen werden:\n$error';
  }

  @override
  String get proxy_statusActive => 'Aktiv';

  @override
  String get proxy_statusDisconnected => 'Getrennt';

  @override
  String proxy_statusRoutingTraffic(int running, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$running von $total Proxys aktiv',
      one: '$running von 1 Proxy aktiv',
    );
    return '$_temp0';
  }

  @override
  String get proxy_statusTapToConnect => 'Zum Verbinden auf ein Profil tippen';

  @override
  String get proxy_stopAllTooltip => 'Alle stoppen';

  @override
  String get proxy_onionRoutingLabel => 'Onion-Routing';

  @override
  String get proxy_autostartLabel => 'Autostart';

  @override
  String get proxy_autostartTooltip => 'Startet mit WebLibre';

  @override
  String proxy_egressIpTooltip(String ip) {
    return 'Ausgangs-IP $ip';
  }

  @override
  String get proxy_latencyTesting => 'Test läuft …';

  @override
  String get proxy_latencyTestRunningTooltip => 'Latenztest läuft';

  @override
  String get proxy_latencyNotRunningTooltip => 'Das Profil läuft nicht';

  @override
  String get proxy_latencyFailed => 'Fehlgeschlagen';

  @override
  String proxy_latencyMilliseconds(int ms) {
    return '$ms ms';
  }

  @override
  String proxy_latencyHttpStatusTooltip(int statusCode, int ms) {
    return 'HTTP $statusCode in $ms ms';
  }

  @override
  String proxy_startProxyFailed(String error) {
    return 'Proxy konnte nicht gestartet werden: $error';
  }

  @override
  String proxy_stopProxyFailed(String error) {
    return 'Proxy konnte nicht gestoppt werden: $error';
  }

  @override
  String proxy_startBrandFailed(String brand, String error) {
    return '$brand konnte nicht gestartet werden: $error';
  }

  @override
  String proxy_stopBrandFailed(String brand, String error) {
    return '$brand konnte nicht gestoppt werden: $error';
  }

  @override
  String get proxy_startConnectionDialogTitle => 'Proxy-Verbindung starten?';

  @override
  String proxy_startConnectionDialogContent(String proxyTitle) {
    return 'Dieser Tab benötigt $proxyTitle, aber diese Verbindung läuft nicht. Jetzt starten?';
  }

  @override
  String get proxy_deleteProfileTitle => 'Profil löschen?';

  @override
  String proxy_deleteProfileConfirm(String name) {
    return '$name samt gespeicherten Geheimnissen löschen? Tabs und Container, die diesem Profil zugewiesen sind, werden blockiert, bis ein anderer Proxy gewählt oder die Zuweisung aufgehoben wird.';
  }

  @override
  String proxy_deleteProfileConfirmRunning(String name) {
    return '$name stoppen und anschließend samt gespeicherten Geheimnissen löschen? Tabs und Container, die diesem Profil zugewiesen sind, werden blockiert, bis ein anderer Proxy gewählt oder die Zuweisung aufgehoben wird.';
  }

  @override
  String proxy_deleteProfileFailed(String error) {
    return 'Profil konnte nicht gelöscht werden: $error';
  }

  @override
  String proxy_shareDialogTitle(String name) {
    return '„$name“ teilen';
  }

  @override
  String get proxy_shareDialogWarning =>
      'Dieser Link enthält das vollständige Profil einschließlich gespeicherter Zugangsdaten. Mit Bedacht teilen.';

  @override
  String get proxy_copiedToClipboard => 'In die Zwischenablage kopiert';

  @override
  String get proxy_editProfileTitle => 'Profil bearbeiten';

  @override
  String get proxy_newProfileTitle => 'Neues Profil';

  @override
  String get proxy_saveChanges => 'Änderungen speichern';

  @override
  String get proxy_createProfile => 'Profil erstellen';

  @override
  String get proxy_sectionGeneral => 'Allgemein';

  @override
  String get proxy_sectionDnsOverride => 'Eigener DNS';

  @override
  String get proxy_addMenuTip =>
      'Tipp: Über das Hinzufügen-Menü auf dem vorherigen Bildschirm lässt sich aus einer Datei importieren, ein Freigabelink einfügen oder ein QR-Code scannen.';

  @override
  String proxy_wireGuardTrademarkDisclaimer(String brand) {
    return '$brand ist eine eingetragene Marke von Jason A. Donenfeld; alle Rechte vorbehalten. WebLibre wird von Jason A. Donenfeld weder unterstützt noch gesponsert und ist nicht mit ihm verbunden.';
  }

  @override
  String proxy_wireGuardConfigLabel(String brand) {
    return '$brand-Konfiguration';
  }

  @override
  String get proxy_fieldProfileName => 'Profilname';

  @override
  String get proxy_fieldProtocol => 'Protokoll';

  @override
  String get proxy_protocolFixedHelper =>
      'Das Protokoll kann nach dem Erstellen eines Profils nicht mehr geändert werden.';

  @override
  String get proxy_customOutboundLabel => 'Eigenes Outbound';

  @override
  String get proxy_startAutomaticallyTitle => 'Automatisch starten';

  @override
  String get proxy_startAutomaticallySubtitle =>
      'Dieses Profil beim Start von WebLibre verbinden, damit Tabs, die es nutzen, ohne Nachfrage bereit sind';

  @override
  String proxy_dnsOverrideExplanation(String brand) {
    return 'Namen über einen DNS-Server auflösen, der über diese Verbindung erreichbar ist (z. B. einen internen DoH-Server hinter einem $brand-Tunnel im Firmennetz). Ausgeschaltet lassen, um die automatische DNS-Verarbeitung zu nutzen.';
  }

  @override
  String get proxy_dnsOverrideSwitchTitle =>
      'Profilspezifischen Resolver verwenden';

  @override
  String get proxy_fieldDnsServerAddress => 'Adresse des DNS-Servers';

  @override
  String get proxy_sectionOutbound => 'Outbound';

  @override
  String get proxy_sectionSecrets => 'Geheimnisse';

  @override
  String get proxy_fieldOutboundJson => 'Outbound-JSON';

  @override
  String get proxy_outboundJsonHelper =>
      'Öffentliches sing-box-Outbound-Objekt.';

  @override
  String get proxy_fieldSecretJson => 'Geheimnis-JSON';

  @override
  String get proxy_secretJsonHelper =>
      'Optionale Werte, die zur Laufzeit in das Outbound eingefügt werden.';

  @override
  String get proxy_sectionConnection => 'Verbindung';

  @override
  String get proxy_sectionCredentials => 'Zugangsdaten';

  @override
  String get proxy_sectionProtocolOptions => 'Protokolloptionen';

  @override
  String get proxy_sectionTls => 'TLS';

  @override
  String get proxy_sectionTransport => 'Transport';

  @override
  String get proxy_sectionMultiplex => 'Multiplex';

  @override
  String get proxy_sectionDial => 'Dial';

  @override
  String get proxy_advancedOptionsHint =>
      'Erweiterte Protokolloptionen lassen sich weiterhin über „Eigenes Outbound“ als JSON eingeben.';

  @override
  String get proxy_storedInSecureStorage => 'Im sicheren Speicher abgelegt.';

  @override
  String get proxy_booleanFieldUnset => 'Nicht gesetzt (Standard)';

  @override
  String get proxy_booleanFieldEnabled => 'Aktiviert';

  @override
  String get proxy_booleanFieldDisabled => 'Deaktiviert';

  @override
  String get proxy_addConnectionTitle => 'Verbindung hinzufügen';

  @override
  String get proxy_addConnectionSubtitle =>
      'Festlegen, wie ein Proxy-Profil hinzugefügt werden soll.';

  @override
  String get proxy_methodClipboardTitle => 'Zwischenablage';

  @override
  String get proxy_methodClipboardSubtitle => 'Freigabelink oder URI einfügen';

  @override
  String get proxy_methodScanQrTitle => 'QR scannen';

  @override
  String get proxy_methodScanQrSubtitle => 'Von einem anderen Gerät';

  @override
  String get proxy_methodSubscriptionTitle => 'Abonnement';

  @override
  String get proxy_methodSubscriptionSubtitle => 'Von URL abrufen';

  @override
  String get proxy_methodImportFileTitle => 'Datei importieren';

  @override
  String get proxy_methodImportFileSubtitle => '.conf oder sing-box-JSON';

  @override
  String get proxy_enterManually => 'Manuell eingeben';

  @override
  String get proxy_clipboardEmpty => 'Die Zwischenablage ist leer.';

  @override
  String get proxy_importFromFileTitle => 'Aus Datei importieren';

  @override
  String get proxy_importFileWireGuardSubtitle =>
      '.conf-Datei mit [Interface]/[Peer]';

  @override
  String get proxy_importFileSingboxJsonTitle => 'sing-box-Outbound-JSON';

  @override
  String get proxy_importFileSingboxJsonSubtitle =>
      'Shadowsocks, Trojan, VMess, VLESS, Hysteria, …';

  @override
  String proxy_importedProfileNamed(String name) {
    return 'Profil „$name“ importiert';
  }

  @override
  String get proxy_importSubscriptionTitle => 'Abonnement importieren';

  @override
  String get proxy_fieldSubscriptionUrl => 'Abonnement-URL';

  @override
  String get proxy_subscriptionUrlRequired =>
      'Eine vollständige https://-Abonnement-URL eingeben.';

  @override
  String proxy_subscriptionHttpError(int statusCode) {
    return 'Der Abonnement-Server hat mit HTTP $statusCode geantwortet.';
  }

  @override
  String get proxy_subscriptionTimedOut =>
      'Der Abonnement-Server hat nicht rechtzeitig geantwortet.';

  @override
  String proxy_subscriptionFetchFailed(String error) {
    return 'Das Abonnement konnte nicht abgerufen werden: $error';
  }

  @override
  String get proxy_subscriptionFormatHint =>
      'Unterstützt das Format im Stil von v2rayN: eine base64-kodierte Liste von ss://-, vless://-, vmess://-, trojan://-, hysteria2://-, tuic://- und ähnlichen URIs. Routing-Regeln aus dem Abonnement werden ignoriert – nur Proxy-Knoten werden importiert.';

  @override
  String proxy_importedProfileDefaultName(int n) {
    return 'Import $n';
  }

  @override
  String proxy_importedProfilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Profile importiert',
      one: '1 Profil importiert',
    );
    return '$_temp0';
  }

  @override
  String proxy_importProfilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Profile importieren',
      one: '1 Profil importieren',
    );
    return '$_temp0';
  }

  @override
  String proxy_subscriptionNodeSummary(int usable, int failed) {
    String _temp0 = intl.Intl.pluralLogic(
      usable,
      locale: localeName,
      other: '$usable nutzbare Knoten, $failed fehlerhaft',
      one: '1 nutzbarer Knoten, $failed fehlerhaft',
    );
    String _temp1 = intl.Intl.pluralLogic(
      usable,
      locale: localeName,
      other: '$usable nutzbare Knoten, 1 fehlerhaft',
      one: '1 nutzbarer Knoten, 1 fehlerhaft',
    );
    String _temp2 = intl.Intl.pluralLogic(
      usable,
      locale: localeName,
      other: '$usable nutzbare Knoten',
      one: '1 nutzbarer Knoten',
    );
    String _temp3 = intl.Intl.pluralLogic(
      failed,
      locale: localeName,
      other: '$_temp0',
      one: '$_temp1',
      zero: '$_temp2',
    );
    return '$_temp3';
  }

  @override
  String get proxy_logsTitle => 'Proxy-Protokolle';

  @override
  String get proxy_logsCopyAllTooltip => 'Alles kopieren';

  @override
  String get proxy_logsClearTooltip => 'Protokoll leeren';

  @override
  String get proxy_logsShareSubject => 'Proxy-Protokolle';

  @override
  String get proxy_logsNoLinesMatchFilter =>
      'Keine Protokollzeilen entsprechen dem aktuellen Filter';

  @override
  String proxy_logsCopiedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zeilen in die Zwischenablage kopiert',
      one: '1 Zeile in die Zwischenablage kopiert',
    );
    return '$_temp0';
  }

  @override
  String get proxy_logsShowAllLevels => 'Alle Stufen anzeigen';

  @override
  String get proxy_logsShowErrorsOnly => 'Nur Fehler anzeigen';

  @override
  String get proxy_logsShowWarningsAndAbove => 'Warnungen und höher anzeigen';

  @override
  String get proxy_logsShowInfoAndAbove => 'Info und höher anzeigen';

  @override
  String get proxy_logsShowDebugAndAbove => 'Debug und höher anzeigen';

  @override
  String get proxy_logsShowTraceAndAbove => 'Trace und höher anzeigen';

  @override
  String get proxy_logsLatest => 'Neueste';

  @override
  String get proxy_logsEmptyFiltered =>
      'Keine Protokollzeilen auf dieser Stufe. Den Anzeigefilter senken oder die Protokollstufe des Proxys erhöhen.';

  @override
  String proxy_logsEmpty(String brand) {
    return 'Noch keine Protokollzeilen. Einen Proxy oder $brand starten, um hier Ausgaben zu sehen.';
  }

  @override
  String get proxy_recordingLevelWarn =>
      'Warnungen und Fehler werden aufgezeichnet';

  @override
  String get proxy_recordingLevelInfo =>
      'Info wird aufgezeichnet – das verlangsamt das Surfen';

  @override
  String get proxy_recordingLevelDebug =>
      'Debug wird aufgezeichnet – das verlangsamt das Surfen';

  @override
  String get proxy_recordingLevelTrace =>
      'Trace wird aufgezeichnet – das verlangsamt das Surfen';

  @override
  String get proxy_logLevelAll => 'Alle';

  @override
  String get proxy_logLevelTrace => 'Trace';

  @override
  String get proxy_logLevelDebug => 'Debug';

  @override
  String get proxy_logLevelInfo => 'Info';

  @override
  String get proxy_logLevelWarnings => 'Warnungen';

  @override
  String get proxy_logLevelErrors => 'Fehler';

  @override
  String get proxy_logLevelSheetTitle => 'Protokollstufe des Proxys';

  @override
  String get proxy_logLevelSheetExplanation =>
      'Nur zur Fehlersuche erhöhen und danach wieder zurücksetzen. Eine Änderung startet laufende Proxys neu.';

  @override
  String get proxy_verboseLoggingWarning =>
      'Ausführliche Protokollierung schreibt eine Zeile für jede Verbindung und DNS-Abfrage und verlangsamt das Surfen spürbar.';

  @override
  String get proxy_logVerbosityWarnLabel => 'Warnungen und Fehler';

  @override
  String get proxy_logVerbosityInfoLabel => 'Info';

  @override
  String get proxy_logVerbosityDebugLabel => 'Debug';

  @override
  String get proxy_logVerbosityTraceLabel => 'Trace';

  @override
  String get proxy_logVerbosityWarnDescription =>
      'Normalbetrieb. Probleme werden weiterhin protokolliert.';

  @override
  String get proxy_logVerbosityInfoDescription =>
      'Jede Verbindung und DNS-Abfrage. Verlangsamt das Surfen.';

  @override
  String get proxy_logVerbosityDebugDescription =>
      'Info plus Protokolldetails. Verlangsamt das Surfen.';

  @override
  String get proxy_logVerbosityTraceDescription =>
      'Alles, was sing-box ausgeben kann. Verlangsamt das Surfen stark.';

  @override
  String get proxy_loadingProxyTitle => 'Proxy wird geladen …';

  @override
  String proxy_torConnectionSubtitle(String torBrand) {
    return 'Über das $torBrand-Netzwerk leiten';
  }

  @override
  String get proxy_routingTitle => 'Proxy-Routing';

  @override
  String get proxy_routingSubtitle =>
      'Festlegen, welcher Proxy den Datenverkehr normaler und privater Tabs übernimmt.';

  @override
  String get proxy_routingSectionRegularTabs => 'Normale Tabs';

  @override
  String get proxy_routingSectionRegularTabsKeywords =>
      'Routing, Weiterleitung';

  @override
  String get proxy_routingSectionPrivateTabs => 'Private Tabs';

  @override
  String get proxy_routingSectionPrivateTabsKeywords => 'privat, inkognito';

  @override
  String get proxy_routingRegularTabsModeTitle =>
      'Routing-Modus für normale Tabs';

  @override
  String get proxy_routingRegularTabsModeKeywords => 'Container, global';

  @override
  String get proxy_routingRegularTabsModeSubtitle =>
      'Festlegen, wie normale Tabs über Proxys geleitet werden';

  @override
  String get proxy_routingGlobalProxyTitle => 'Proxy für globales Routing';

  @override
  String get proxy_routingGlobalProxyKeywords => 'Proxy';

  @override
  String get proxy_routingGlobalProxySubtitle =>
      'Ausgewählter Proxy bei aktivem globalem Routing';

  @override
  String get proxy_routingPrivateTabsProxyTitle => 'Proxy für private Tabs';

  @override
  String get proxy_routingPrivateTabsProxyKeywords => 'Proxy';

  @override
  String get proxy_routingPrivateTabsProxySubtitle =>
      'Ausgewählter Proxy, der den Datenverkehr privater Tabs übernimmt';

  @override
  String get proxy_routingContainerBasedTitle => 'Containerbasiertes Routing';

  @override
  String get proxy_routingContainerBasedSubtitle =>
      'Nur Tabs in Containern mit zugewiesenem Proxy werden umgeleitet.';

  @override
  String get proxy_routingGlobalRoutingTitle => 'Globales Routing';

  @override
  String get proxy_routingGlobalRoutingSubtitle =>
      'Normale Tabs über den ausgewählten Proxy leiten, sofern ein Container ihn nicht umgeht.';

  @override
  String get proxy_routingNotUsedTitle =>
      'Beim containerbasierten Routing nicht verwendet';

  @override
  String get proxy_routingNotUsedSubtitle =>
      'Oben zu globalem Routing wechseln, um den Proxy für alle normalen Tabs auszuwählen.';

  @override
  String get proxy_routingNoneTitle => 'Keiner';

  @override
  String get proxy_routingNoneSubtitle =>
      'Die normale Browserverbindung verwenden';

  @override
  String get proxy_routingUnknownProxySubtitle =>
      'Der ausgewählte Proxy existiert nicht mehr.';

  @override
  String get proxy_unknownProxyTitle => 'Unbekannter Proxy';

  @override
  String get proxy_connectionPickerTitle => 'Proxy-Verbindung';

  @override
  String get proxy_pickerUnknownProxySubtitle =>
      'Dieses Proxy-Profil existiert nicht mehr';

  @override
  String get proxy_fieldServerAddress => 'Serveradresse';

  @override
  String get proxy_fieldServerPort => 'Server-Port';

  @override
  String get proxy_fieldUsername => 'Benutzername';

  @override
  String get proxy_fieldPassword => 'Passwort';

  @override
  String get proxy_fieldUuid => 'UUID';

  @override
  String get proxy_fieldTlsEnabled => 'TLS aktiviert';

  @override
  String get proxy_fieldTlsEnabledHelper => 'true oder false.';

  @override
  String get proxy_fieldTlsServerName => 'TLS-Servername';

  @override
  String get proxy_fieldTlsInsecure => 'Ungültige TLS-Zertifikate erlauben';

  @override
  String get proxy_fieldTlsInsecureHelper => 'true oder false.';

  @override
  String get proxy_fieldTlsAlpn => 'TLS ALPN';

  @override
  String get proxy_fieldTlsAlpnHelper =>
      'Kommagetrennt oder ein Wert pro Zeile.';

  @override
  String get proxy_fieldTransportType => 'Transporttyp';

  @override
  String get proxy_fieldTransportTypeHelper =>
      'Zum Beispiel ws, http, grpc oder quic.';

  @override
  String get proxy_fieldTransportPath => 'Transportpfad';

  @override
  String get proxy_fieldGrpcServiceName => 'gRPC-Dienstname';

  @override
  String get proxy_fieldMultiplexEnabled => 'Multiplex aktiviert';

  @override
  String get proxy_fieldMultiplexEnabledHelper => 'true oder false.';

  @override
  String get proxy_fieldMultiplexProtocol => 'Multiplex-Protokoll';

  @override
  String get proxy_fieldMultiplexMaxConnections =>
      'Multiplex max. Verbindungen';

  @override
  String get proxy_fieldDialDetour => 'Dial Detour';

  @override
  String get proxy_fieldBindInterface => 'Bind Interface';

  @override
  String get proxy_fieldRoutingMark => 'Routing Mark';

  @override
  String get proxy_fieldDomainStrategy => 'Domain-Strategie';

  @override
  String get proxy_fieldDomainStrategyHelper =>
      'Zum Beispiel prefer_ipv4 oder prefer_ipv6.';

  @override
  String get proxy_fieldConnectTimeout => 'Verbindungs-Timeout';

  @override
  String get proxy_fieldConnectTimeoutHelper => 'Zum Beispiel 5s.';

  @override
  String get proxy_fieldSocksVersion => 'SOCKS-Version';

  @override
  String get proxy_fieldMethod => 'Methode';

  @override
  String get proxy_fieldSecurity => 'Sicherheit';

  @override
  String get proxy_fieldAlterId => 'Alter ID';

  @override
  String get proxy_fieldFlow => 'Flow';

  @override
  String get proxy_fieldAuthString => 'Auth-String';

  @override
  String get proxy_fieldUploadBandwidth => 'Upload-Bandbreite';

  @override
  String get proxy_fieldDownloadBandwidth => 'Download-Bandbreite';

  @override
  String get proxy_fieldObfuscation => 'Verschleierung';

  @override
  String get proxy_fieldReceiveWindowConn => 'Receive Window Conn';

  @override
  String get proxy_fieldReceiveWindow => 'Receive Window';

  @override
  String get proxy_fieldDisableMtuDiscovery => 'MTU-Erkennung deaktivieren';

  @override
  String get proxy_fieldDisableMtuDiscoveryHelper => 'true oder false.';

  @override
  String get proxy_fieldUploadMbps => 'Upload Mbit/s';

  @override
  String get proxy_fieldDownloadMbps => 'Download Mbit/s';

  @override
  String get proxy_fieldObfuscationType => 'Verschleierungstyp';

  @override
  String get proxy_fieldObfuscationPassword => 'Verschleierungspasswort';

  @override
  String get proxy_fieldCongestionControl => 'Überlastkontrolle';

  @override
  String get proxy_fieldUdpRelayMode => 'UDP-Relay-Modus';

  @override
  String get proxy_fieldZeroRttHandshake => 'Zero-RTT-Handshake';

  @override
  String get proxy_fieldZeroRttHandshakeHelper => 'true oder false.';

  @override
  String get proxy_fieldUser => 'Benutzer';

  @override
  String get proxy_fieldPrivateKey => 'Privater Schlüssel';

  @override
  String get proxy_fieldPrivateKeyPassphrase =>
      'Passphrase des privaten Schlüssels';

  @override
  String get proxy_fieldLocalAddress => 'Lokale Adresse';

  @override
  String get proxy_fieldLocalAddressHelper =>
      'Die Adresse dieses Geräts innerhalb des Tunnels, eine pro Zeile – zum Beispiel 10.0.0.2/32. Eine Adresse ohne Präfix gilt als Einzeladresse (/32 bzw. /128 bei IPv6).';

  @override
  String get proxy_fieldPeerPublicKey => 'Öffentlicher Schlüssel des Peers';

  @override
  String get proxy_fieldWireguardPrivateKey => 'Privater Schlüssel';

  @override
  String get proxy_fieldWireguardPrivateKeyHelper =>
      'Im sicheren Speicher abgelegt, nicht im Profil-JSON.';

  @override
  String get proxy_fieldPreSharedKey => 'Pre-shared Key';

  @override
  String get proxy_fieldPreSharedKeyHelper =>
      'Optional. Im sicheren Speicher abgelegt.';

  @override
  String get proxy_fieldMtu => 'MTU';

  @override
  String get proxy_fieldMtuHelper =>
      'Verringern, wenn die Tunnelverbindung zustande kommt, Seiten aber nicht laden: Pakete, die größer sind als der Pfad erlaubt, werden kommentarlos verworfen. Der Wert 1280 funktioniert fast überall; bei einer bereits bestehenden VPN-Verbindung etwa 1200 verwenden.';

  @override
  String get proxy_fieldPersistentKeepalive => 'Persistent Keepalive';

  @override
  String get proxy_fieldPersistentKeepaliveHelper =>
      'Sekunden zwischen Keepalive-Paketen. Smartphones befinden sich oft hinter NAT; ohne Keepalives kann die Zuordnung im Leerlauf ablaufen. Dann erreicht der Peer das Gerät nicht mehr und Verbindungen hängen bis zum nächsten Handshake. 0 deaktiviert die Funktion.';

  @override
  String get proxy_fieldReservedBytes => 'Reservierte Bytes';

  @override
  String get proxy_fieldReservedBytesHelper =>
      'Optional. Drei kommagetrennte Zahlen, z. B. 0,0,0.';

  @override
  String get proxy_fieldShadowTlsVersion => 'Version';

  @override
  String proxy_fieldErrorRequired(String field) {
    return '$field ist erforderlich.';
  }

  @override
  String proxy_fieldErrorNotPositiveNumber(String field) {
    return '$field muss eine positive Zahl sein.';
  }

  @override
  String proxy_fieldErrorPortRange(String field) {
    return '$field muss zwischen 1 und 65535 liegen.';
  }

  @override
  String proxy_fieldErrorListLength(String field, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$field muss $count Zahlen enthalten.',
      one: '$field muss 1 Zahl enthalten.',
    );
    return '$_temp0';
  }

  @override
  String proxy_fieldErrorNotAllNumbers(String field) {
    return '$field darf nur Zahlen enthalten.';
  }

  @override
  String proxy_fieldErrorBelowMin(String field, int min) {
    return '$field darf nur Zahlen größer oder gleich $min enthalten.';
  }

  @override
  String proxy_fieldErrorAboveMax(String field, int max) {
    return '$field darf nur Zahlen kleiner oder gleich $max enthalten.';
  }

  @override
  String proxy_fieldErrorInvalidCidr(String field, String value) {
    return '$field muss IP-Adressen enthalten, optional mit /Präfix – „$value“ ist keine.';
  }

  @override
  String proxy_fieldErrorNotBoolean(String field) {
    return '$field muss true oder false sein.';
  }

  @override
  String proxy_fieldErrorNotAllowedValue(String field, String values) {
    return '$field muss einer dieser Werte sein: $values.';
  }

  @override
  String get proxy_saveErrorAlreadySaving =>
      'Das Profil wird bereits gespeichert.';

  @override
  String get proxy_saveErrorNameRequired => 'Ein Profilname ist erforderlich.';

  @override
  String get proxy_saveErrorStillLoading =>
      'Das Profil wird noch geladen. Bitte warten.';

  @override
  String get proxy_saveErrorConfigNotJson =>
      'Die Konfiguration muss ein JSON-Objekt sein.';

  @override
  String get proxy_saveErrorSecretsNotJson =>
      'Die Geheimnisse müssen ein JSON-Objekt sein.';

  @override
  String proxy_saveErrorUnexpected(String error) {
    return 'Proxy-Profil konnte nicht gespeichert werden: $error';
  }

  @override
  String get proxy_loadErrorNotFound => 'Proxy-Profil nicht gefunden.';

  @override
  String proxy_loadErrorFailed(String error) {
    return 'Proxy-Profil konnte nicht geladen werden: $error';
  }

  @override
  String get qrScanner_noCameraPermission =>
      'Die Kameraberechtigung wurde nicht erteilt.';

  @override
  String get qrScanner_scanCodeTitle => 'Code scannen';

  @override
  String get searchCredits_couldNotLoadTitle =>
      'Guthaben konnte nicht geladen werden';

  @override
  String get searchCredits_title => 'Suchguthaben';

  @override
  String get searchCredits_errorSubtitle =>
      'Verbindung prüfen und zum erneuten Versuch auf Aktualisieren tippen.';

  @override
  String get searchCredits_emptySubtitle => 'Zum Einstieg ein Suchpaket kaufen';

  @override
  String searchCredits_creditsWithAllowance(
    int credits,
    int allowance,
    int stash,
  ) {
    return 'Guthaben: $credits / $allowance  ·  Gespeicherte Tokens: $stash';
  }

  @override
  String searchCredits_creditsNoAllowance(int credits, int stash) {
    return 'Guthaben: $credits  ·  Gespeicherte Tokens: $stash';
  }

  @override
  String get searchCredits_tooltipRefresh => 'Aktualisieren';

  @override
  String searchCredits_resetsOn(String date) {
    return 'Wird am $date zurückgesetzt';
  }

  @override
  String searchCredits_lastIssuance(String relative, String absolute) {
    return 'Letzte Ausgabe: $relative  ($absolute)';
  }

  @override
  String get searchCredits_requestingTokens => 'Tokens werden angefordert …';

  @override
  String searchCredits_issuanceFailed(String error) {
    return 'Token-Ausgabe fehlgeschlagen: $error';
  }

  @override
  String get searchCredits_needsReauth =>
      'Zum Anfordern von Tokens bitte erneut anmelden.';

  @override
  String get searchCredits_buySearchPackTitle => 'Suchpaket kaufen';

  @override
  String get searchCredits_getTokensTitle => 'Tokens abrufen';

  @override
  String searchCredits_requestTokensCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tokens anfordern',
      one: '1 Token anfordern',
    );
    return '$_temp0';
  }

  @override
  String get searchCredits_noCreditsRemaining => 'Kein Guthaben mehr übrig';

  @override
  String get searchCredits_buyMoreTitle => 'Mehr kaufen';

  @override
  String get settings_advancedTitle => 'Erweitert';

  @override
  String get settings_advancedSubtitle =>
      'Engine-Verhalten, Laufzeitoptionen und Entwicklerwerkzeuge.';

  @override
  String get settings_javascriptTitle => 'JavaScript aktivieren';

  @override
  String get settings_javascriptKeywords => 'javascript, js, Skripte';

  @override
  String get settings_javascriptSubtitle =>
      'Das Deaktivieren von JavaScript kann Sicherheit, Datenschutz und Geschwindigkeit verbessern, aber manche Websites funktionieren dann nicht wie vorgesehen.';

  @override
  String get settings_userAgentLabel => 'Eigener User-Agent';

  @override
  String get settings_userAgentLabelKeywords =>
      'ua, User-Agent, Browserkennung';

  @override
  String get settings_enterpriseRootsTitle =>
      'CA-Zertifikate von Drittanbietern verwenden';

  @override
  String get settings_enterpriseRootsKeywords =>
      'Zertifikate, Enterprise Roots, ca, Zertifizierungsstelle';

  @override
  String get settings_enterpriseRootsSubtitle =>
      'Erlaubt Zertifikate von Drittanbietern aus dem Android-CA-Speicher';

  @override
  String get settings_experimentalFeaturesTitle => 'Experimentelle Funktionen';

  @override
  String get settings_experimentalFeaturesKeywords =>
      'Laufzeit, Start, experimentell';

  @override
  String get settings_experimentalFeaturesSubtitle =>
      'Laufzeitfunktionen auf niedriger Ebene und Startverhalten';

  @override
  String get settings_unmountGeckoViewTitle => 'Engine im Hintergrund entladen';

  @override
  String get settings_unmountGeckoViewKeywords =>
      'geckoview, Speicher, Arbeitsspeicher, Leistung, pausieren';

  @override
  String get settings_unmountGeckoViewSubtitle =>
      'Die Web-Engine aus dem Speicher entfernen, solange eine Vollbildansicht (etwa Einstellungen, Tabs oder Suche) geöffnet ist, und bei der Rückkehr neu aufbauen. Das gibt in der Zwischenzeit Ressourcen frei. Die Rückkehr zur Seite erfordert das erneute Anbinden der Engine und kann ein Flackern oder Neuladen verursachen – es wird also Leistung gegen Speicher getauscht, statt ein Problem zu beheben. Unter Android 12 und älter wird die Engine immer entladen.';

  @override
  String get settings_iconCacheTitle => 'Symbol-Cache';

  @override
  String get settings_iconCacheKeywords => 'Favicons, Cache, Symbole';

  @override
  String get settings_iconCacheSubtitle => 'Gespeicherte Favicons';

  @override
  String get settings_iconCacheSizeLabel => 'Größe';

  @override
  String get settings_clearingAction => 'Wird gelöscht';

  @override
  String get settings_mlDownloadsTitle => 'ML-Downloads';

  @override
  String get settings_mlDownloadsKeywords => 'ki, ai, ml, Modelle, onnx, Cache';

  @override
  String get settings_mlDownloadsSubtitle =>
      'Heruntergeladene KI-Modelle und Laufzeitdateien';

  @override
  String get settings_mlDownloadsClearDialogTitle => 'ML-Downloads löschen?';

  @override
  String get settings_mlDownloadsClearDialogContent =>
      'Dadurch werden heruntergeladene KI-Modelle und ONNX-Laufzeitdateien dieses Profils gelöscht. Sie werden bei Bedarf erneut heruntergeladen. Vor einem erneuten Versuch der ML-Funktionen WebLibre neu starten.';

  @override
  String get settings_mlDownloadsClearedMessage =>
      'ML-Downloads gelöscht. Vor einem erneuten Versuch WebLibre neu starten.';

  @override
  String settings_mlDownloadsClearFailedMessage(String error) {
    return 'ML-Downloads konnten nicht gelöscht werden: $error';
  }

  @override
  String get settings_errorLogsTitle => 'Fehlerprotokolle';

  @override
  String get settings_errorLogsKeywords => 'Protokolle, Logs, Fehler';

  @override
  String get settings_errorLogsSubtitle =>
      'Protokolle für Fehlerberichte ansehen und kopieren';

  @override
  String get settings_dartVmTitle => 'Dart VM';

  @override
  String get settings_dartVmKeywords => 'Service-URL';

  @override
  String get settings_dartVmSubtitle => 'Dart-VM-Service-URL kopieren';

  @override
  String get settings_dartVmCopyErrorFallback => 'Fehler';

  @override
  String get settings_serviceUrlCopiedMessage => 'Service-URL kopiert';

  @override
  String get settings_resetUiTitle => 'Oberfläche zurücksetzen';

  @override
  String get settings_resetUiKeywords =>
      'Oberfläche aktualisieren, UI neu laden';

  @override
  String get settings_resetUiSubtitle =>
      'Die gesamte Browseroberfläche neu aufbauen';

  @override
  String get settings_addonCollectionTitle => 'Eigene Erweiterungssammlung';

  @override
  String get settings_addonCollectionSourceSectionTitle =>
      'Quelle der Sammlung';

  @override
  String get settings_addonCollectionConfigTitle =>
      'Konfiguration der Sammlung';

  @override
  String get settings_addonCollectionConfigKeywords =>
      'Add-ons, Sammlung, Erweiterungen';

  @override
  String get settings_addonCollectionConfigSubtitle =>
      'Mozilla-Server, Besitzer und Name der Sammlung';

  @override
  String get settings_addonCollectionServerUrlLabel => 'Server-URL';

  @override
  String get settings_addonCollectionUserLabel => 'Besitzer der Sammlung';

  @override
  String get settings_addonCollectionNameLabel => 'Name der Sammlung';

  @override
  String get settings_addonCollectionActionsSectionTitle => 'Aktionen';

  @override
  String get settings_addonCollectionSaveRestartTitle =>
      'Speichern & Browser neu starten';

  @override
  String get settings_addonCollectionSaveRestartKeywords =>
      'Neustart, neu starten';

  @override
  String get settings_addonCollectionSaveRestartSubtitle =>
      'Die eigene Sammlung übernehmen und den Browser neu starten';

  @override
  String get settings_bangSettingsTitle => 'Bang-Einstellungen';

  @override
  String get settings_bangSettingsKeywords => 'Kürzel, Bangs, Abkürzungen';

  @override
  String get settings_bangSettingsSubtitle =>
      'Bang-Kürzel, ihre Nutzung und Quellen sowie Synchronisierung bei Bedarf.';

  @override
  String get settings_bangFrequenciesTitle => 'Bang-Häufigkeiten';

  @override
  String get settings_bangFrequenciesKeywords => 'Nutzung, Empfehlungen';

  @override
  String get settings_bangFrequenciesSubtitle =>
      'Erfasste Nutzung für Bang-Empfehlungen';

  @override
  String get settings_browsingTitle => 'Surfen';

  @override
  String get settings_browsingSubtitle =>
      'Tabs, Navigation, App-Links und Small-Web-Verhalten.';

  @override
  String get settings_newTabDefaultTitle => 'Standard für neue Tabs';

  @override
  String get settings_newTabDefaultKeywords => 'normal, privat, isoliert';

  @override
  String get settings_newTabDefaultSubtitle =>
      'Die Standardart für manuell erstellte Tabs festlegen';

  @override
  String get settings_tabTypeRegularLabel => 'Normal';

  @override
  String get settings_tabTypePrivateLabel => 'Privat';

  @override
  String get settings_tabTypeIsolatedLabel => 'Isoliert';

  @override
  String get settings_smallWebTabDefaultTitle => 'Standard-Tab für Small Web';

  @override
  String get settings_smallWebTabDefaultKeywords => 'normal, privat, isoliert';

  @override
  String get settings_smallWebTabDefaultSubtitle =>
      'Die Tab-Art festlegen, die beim Öffnen von Small Web verwendet wird';

  @override
  String get settings_externalLinkHandlingTitle => 'Umgang mit externen Links';

  @override
  String get settings_externalLinkHandlingKeywords =>
      'Intents, externe Links, andere Apps';

  @override
  String get settings_externalLinkHandlingSubtitle =>
      'Festlegen, wie externe Links in WebLibre geöffnet werden';

  @override
  String get settings_promptOptionLabel => 'Nachfragen';

  @override
  String get settings_externalLinkPromptSubtitle =>
      'Nachfragen, wie externe Links geöffnet werden sollen';

  @override
  String get settings_externalLinkRegularSubtitle =>
      'Externe Links in einem normalen Tab öffnen';

  @override
  String get settings_externalLinkPrivateSubtitle =>
      'Externe Links in einem privaten Tab öffnen';

  @override
  String get settings_externalLinkIsolatedSubtitle =>
      'Externe Links in einem isolierten Tab öffnen';

  @override
  String get settings_bookmarkOpenBehaviorTitle => 'Öffnen von Lesezeichen';

  @override
  String get settings_bookmarkOpenBehaviorKeywords =>
      'Lesezeichen, öffnen, Custom Tab, isoliert';

  @override
  String get settings_bookmarkOpenBehaviorSubtitle =>
      'Festlegen, wie ein Lesezeichen beim Antippen geöffnet wird';

  @override
  String get settings_bookmarkOpenPromptSubtitle =>
      'Nachfragen, wie das Lesezeichen geöffnet werden soll';

  @override
  String get settings_bookmarkOpenRegularSubtitle =>
      'Das Lesezeichen in einem normalen Tab öffnen';

  @override
  String get settings_bookmarkOpenPrivateSubtitle =>
      'Das Lesezeichen in einem privaten Tab öffnen';

  @override
  String get settings_customTabOptionLabel => 'Custom Tab';

  @override
  String get settings_bookmarkOpenCustomTabSubtitle =>
      'Das Lesezeichen in einem schlanken Custom Tab öffnen';

  @override
  String get settings_bookmarkOpenIsolatedSubtitle =>
      'Das Lesezeichen in einem isolierten Tab öffnen';

  @override
  String get settings_tabListDirectionTitle => 'Reihenfolge der Tab-Liste';

  @override
  String get settings_tabListDirectionKeywords => 'Sortierung, Reihenfolge';

  @override
  String get settings_tabListDirectionSubtitle =>
      'Festlegen, ob der neueste Tab oben oder unten in der Tab-Liste erscheint';

  @override
  String get settings_directionNewestFirstLabel => 'Neueste zuerst';

  @override
  String get settings_directionOldestFirstLabel => 'Älteste zuerst';

  @override
  String get settings_tabBarDirectionTitle => 'Reihenfolge der Tableiste';

  @override
  String get settings_tabBarDirectionKeywords => 'Sortierung, Reihenfolge';

  @override
  String get settings_tabBarDirectionSubtitle =>
      'Festlegen, ob der neueste Tab links oder rechts im Schnellwechsler erscheint';

  @override
  String get settings_childTabPlacementTitle => 'Position neuer Unter-Tabs';

  @override
  String get settings_childTabPlacementKeywords =>
      'Unter-Tabs, neuer Tab, Position, Reihenfolge, Listenende, nach übergeordnetem Tab';

  @override
  String get settings_childTabPlacementSubtitle =>
      'Festlegen, ob ein aus einem anderen Tab geöffneter Tab direkt nach diesem oder am Ende eingefügt wird. Der öffnende Tab wird in beiden Fällen gemerkt, die Baumansicht ist also nicht betroffen.';

  @override
  String get settings_childTabAfterOpenerLabel => 'Nach dem öffnenden Tab';

  @override
  String get settings_childTabAtEndLabel => 'Am Ende';

  @override
  String get settings_createChildTabsTitle => 'Unter-Tabs erstellen';

  @override
  String get settings_createChildTabsKeywords => 'Unter-Tabs, Kind-Tabs';

  @override
  String get settings_createChildTabsSubtitle =>
      'Eine Schaltfläche zum Erstellen eines Unter-Tabs unter dem aktuellen Tab anzeigen (nur Baumansicht)';

  @override
  String get settings_showContainerUiTitle => 'Container-Oberfläche anzeigen';

  @override
  String get settings_showContainerUiKeywords => 'Container';

  @override
  String get settings_showContainerUiSubtitle =>
      'Container-Auswahl, -Menüs und -Verwaltung anzeigen';

  @override
  String get settings_showIsolatedTabUiTitle =>
      'Oberfläche für isolierte Tabs anzeigen';

  @override
  String get settings_showIsolatedTabUiKeywords => 'isolierte Tabs';

  @override
  String get settings_showIsolatedTabUiSubtitle =>
      'Optionen zum Erstellen isolierter Tabs in der Oberfläche anzeigen';

  @override
  String get settings_backgroundTabBehaviorTitle =>
      'Verhalten bei Hintergrund-Tabs';

  @override
  String get settings_backgroundTabBehaviorKeywords =>
      'wechseln, Hintergrund, neuer Tab, Snackbar, Hinweis';

  @override
  String get settings_backgroundTabBehaviorSubtitle =>
      'Gilt, wenn eine Aktion einen neuen Tab im Hintergrund öffnet, z. B. „In neuem Tab öffnen“ oder das Klonen eines Tabs';

  @override
  String get settings_backgroundTabPromptTitle =>
      'Bleiben und Wechsel anbieten';

  @override
  String get settings_backgroundTabPromptSubtitle =>
      'Den aktuellen Tab behalten und einen Hinweis mit der Aktion „Wechseln“ anzeigen';

  @override
  String get settings_backgroundTabSwitchTitle => 'Sofort wechseln';

  @override
  String get settings_backgroundTabSwitchSubtitle =>
      'Direkt zum neu geöffneten Tab springen';

  @override
  String get settings_tabBarSwipesTitle => 'Wischgesten auf der Tableiste';

  @override
  String get settings_tabBarSwipesKeywords =>
      'Gesten, wischen, Verhalten beim Wischen auf der Tableiste';

  @override
  String get settings_tabBarSwipesSubtitle =>
      'Unter „Gesten“ festlegen, was jede Wischgeste bewirkt';

  @override
  String get settings_sequentialTabNavigationTitle => 'Tab-für-Tab-Navigation';

  @override
  String get settings_sequentialTabNavigationKeywords =>
      'Gesten, wischen, nächster Tab, vorheriger Tab, Container, Schleife, umbrechen';

  @override
  String get settings_sequentialTabNavigationSubtitle =>
      'Gilt für das Wischen auf der Tableiste und die Gesten für nächsten/vorherigen Tab';

  @override
  String get settings_continueIntoNextContainerTitle =>
      'In nächsten Container weitergehen';

  @override
  String get settings_continueIntoNextContainerSubtitle =>
      'Über den ersten oder letzten Tab eines Containers hinaus geht es im benachbarten Container weiter. Ausgeschaltet bleibt die Navigation im aktuellen Container.';

  @override
  String get settings_loopAroundTitle => 'Im Kreis';

  @override
  String get settings_loopAroundSubtitle =>
      'Über den letzten Tab hinaus geht es beim ersten weiter und umgekehrt.';

  @override
  String get settings_openLinksInAppsTitle => 'Links in Apps öffnen';

  @override
  String get settings_openLinksInAppsKeywords => 'App-Links, externe Apps';

  @override
  String get settings_openLinksInAppsSubtitle =>
      'Festlegen, wie Links behandelt werden, die sich in anderen Apps öffnen lassen';

  @override
  String get settings_appLinksAlwaysTitle => 'Immer';

  @override
  String get settings_appLinksAlwaysSubtitle =>
      'Links immer ohne Nachfrage in ihren nativen Apps öffnen';

  @override
  String get settings_appLinksAskTitle => 'Vor dem Öffnen fragen';

  @override
  String get settings_appLinksAskSubtitle =>
      'Vor dem Öffnen von Links in Apps nachfragen';

  @override
  String get settings_appLinksNeverTitle => 'Nie';

  @override
  String get settings_appLinksNeverSubtitle =>
      'Links immer im Browser statt in Apps öffnen';

  @override
  String get settings_waitForAnswerTitle => 'Auf Antwort warten';

  @override
  String get settings_waitForAnswerSubtitle =>
      'Die Seite während der Nachfrage anhalten, statt sie im Hintergrund zu laden. Die Website wird nur kontaktiert, wenn du im Browser bleibst.';

  @override
  String get settings_offerAppStoreFallbackTitle =>
      'App-Store als Ausweichlösung anbieten';

  @override
  String get settings_offerAppStoreFallbackSubtitle =>
      'Verweist ein Link auf eine nicht installierte App und gibt es keine Web-Alternative, das Öffnen des App-Stores anbieten';

  @override
  String get settings_allowLoginAppCallbacksTitle =>
      'Anmelde-Rückrufe an Apps erlauben';

  @override
  String get settings_allowLoginAppCallbacksSubtitle =>
      'Apps, die einen Custom Tab geöffnet haben, ihren Anmelde-Rückruf erhalten lassen – auch wenn Links nie in Apps geöffnet werden sollen';

  @override
  String get settings_appLinkContainerFallbackName => 'Container';

  @override
  String get settings_appLinkOverrideModeAlways => 'Immer in Apps öffnen';

  @override
  String get settings_appLinkOverrideModeAsk => 'Fragt vor dem Öffnen';

  @override
  String get settings_appLinkOverrideModeNever =>
      'Behält Links immer im Browser';

  @override
  String get settings_appLinkContainerOverridesHeader =>
      'Container mit eigenen App-Link-Einstellungen';

  @override
  String settings_appLinkOverrideSummaryWithRules(String mode, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gespeicherte Regeln',
      one: '1 gespeicherte Regel',
    );
    return '$mode · $_temp0';
  }

  @override
  String get settings_appLinkRememberedRulesHeader =>
      'Gespeicherte Website-Regeln';

  @override
  String get settings_appLinkRuleAlwaysOpenLabel => 'Immer in der App öffnen';

  @override
  String get settings_appLinkRuleAlwaysKeepLabel => 'Immer im Browser behalten';

  @override
  String get settings_appLinkRuleRemoveTooltip => 'Regel entfernen';

  @override
  String get settings_globalDesktopModeTitle =>
      'Immer Desktop-Version anfordern';

  @override
  String get settings_globalDesktopModeKeywords =>
      'Desktop-Modus, User-Agent, mobile Website, Tablet';

  @override
  String get settings_globalDesktopModeSubtitle =>
      'Neue Tabs standardmäßig im Desktop-Modus öffnen. Über das Seitenmenü lässt sich der Desktop-Modus weiterhin pro Tab umschalten.';

  @override
  String get settings_desktopModeSitesTitle => 'Websites im Desktop-Modus';

  @override
  String get settings_desktopModeSitesKeywords =>
      'Desktop-Modus, pro Website, User-Agent, Ausnahmen';

  @override
  String get settings_desktopModeSitesSubtitle =>
      'Websites, die immer im Desktop-Modus laden';

  @override
  String get settings_pullToRefreshTitle => 'Zum Aktualisieren ziehen';

  @override
  String get settings_pullToRefreshKeywords => 'neu laden, aktualisieren';

  @override
  String get settings_pullToRefreshSubtitle =>
      'Auf Seiten nach unten wischen, um sie neu zu laden';

  @override
  String get settings_customTabsTitle => 'Custom Tabs';

  @override
  String get settings_customTabsKeywords =>
      'Custom Tabs, In-App-Browser, Chrome Custom Tabs, externe App, teilen';

  @override
  String get settings_customTabsSubtitle =>
      'Andere Apps Links in einem schlanken In-App-Tab öffnen lassen. Ausgeschaltet öffnen sich diese Links und geteilte URLs als normale Tabs im Hauptbrowser.';

  @override
  String get settings_doubleBackCloseTabTitle => 'Zweimal Zurück schließt Tab';

  @override
  String get settings_doubleBackCloseTabKeywords => 'Zurück-Taste, Zurück';

  @override
  String get settings_doubleBackCloseTabSubtitle =>
      'Aktiviert schließt zweimaliges Drücken der Zurück-Taste den Tab. Deaktiviert navigiert die Zurück-Taste nur durch den Seitenverlauf.';

  @override
  String get settings_allowNonManifestPwaInstallTitle =>
      'Websites als Apps installieren';

  @override
  String get settings_allowNonManifestPwaInstallKeywords => 'pwa, Web-Apps';

  @override
  String get settings_allowNonManifestPwaInstallSubtitle =>
      'Installieren von Websites ohne PWA-Manifest als eigenständige Apps erlauben';

  @override
  String get settings_urlCleanerTitle => 'URL-Bereinigung';

  @override
  String get settings_urlCleanerKeywords => 'utm, Tracking-Parameter';

  @override
  String get settings_urlCleanerSubtitle =>
      'Regeln zum Entfernen von Tracking und Katalogaktualisierungen';

  @override
  String get settings_unshortenerTitle => 'Kurzlink-Auflösung';

  @override
  String get settings_unshortenerKeywords =>
      'Kurzlinks, Weiterleitungen, unshorten';

  @override
  String get settings_unshortenerSubtitle =>
      'Auflösung von Kurzlinks und API-Token';

  @override
  String get settings_contextualToolbarSearchHint =>
      'Schaltflächen der Symbolleiste suchen';

  @override
  String get settings_contextualToolbarTitleDefault => 'Symbolleiste anpassen';

  @override
  String get settings_contextualToolbarTitleQuickSwitcher =>
      'Schaltflächen des Wechslers anpassen';

  @override
  String get settings_contextualToolbarResetToDefaults =>
      'Auf Standard zurücksetzen';

  @override
  String get settings_contextualToolbarEnabledSection => 'Aktiviert';

  @override
  String get settings_contextualToolbarDisabledSection => 'Deaktiviert';

  @override
  String get settings_contextualToolbarNoEnabledButtons =>
      'Keine Schaltflächen aktiviert. Unten eine Schaltfläche einschalten, um sie zu aktivieren.';

  @override
  String settings_contextualToolbarNoEnabledButtonsMatch(String query) {
    return 'Keine aktivierten Schaltflächen passen zu „$query“.';
  }

  @override
  String get settings_contextualToolbarAllButtonsEnabled =>
      'Alle Schaltflächen sind aktiviert.';

  @override
  String settings_contextualToolbarNoDisabledButtonsMatch(String query) {
    return 'Keine deaktivierten Schaltflächen passen zu „$query“.';
  }

  @override
  String get settings_longPressNoneTitle => 'Keine';

  @override
  String get settings_longPressNoneDescription =>
      'Standard für diese Schaltfläche: Gedrückthalten bewirkt nichts weiter';

  @override
  String get settings_longPressDefaultDescription =>
      'Standard für diese Schaltfläche';

  @override
  String get settings_longPressTitle => 'Langes Drücken';

  @override
  String get settings_longPressDescription =>
      'Was das Gedrückthalten der Schaltfläche bewirkt';

  @override
  String get settings_fallbackGreyOutLabel => 'Ausgrauen';

  @override
  String get settings_fallbackIfUnavailableTitle => 'Wenn nicht verfügbar';

  @override
  String get settings_fallbackIfUnavailableDescription =>
      'Wird stattdessen angezeigt, solange diese Schaltfläche nicht nutzbar ist';

  @override
  String get settings_customTrackingProtectionTitle =>
      'Benutzerdefinierter Tracking-Schutz';

  @override
  String get settings_customTrackingProtectionSubtitle =>
      'Eigene Einstellungen für Cookies, Inhalte, Tracker und Fingerprinting.';

  @override
  String get settings_fixMajorIssuesTitle => 'Größere Website-Probleme beheben';

  @override
  String get settings_fixMajorIssuesSubtitle =>
      'Ausnahmen anwenden, die nötig sind, um größere Fehlfunktionen von Websites zu vermeiden (empfohlen)';

  @override
  String get settings_fixMinorIssuesTitle =>
      'Kleinere Website-Probleme beheben';

  @override
  String get settings_fixMinorIssuesSubtitle =>
      'Ausnahmen anwenden, um kleinere Probleme zu beheben und Komfortfunktionen zu ermöglichen';

  @override
  String get settings_blockCookiesTitle => 'Cookies blockieren';

  @override
  String get settings_blockCookiesSubtitle =>
      'Cookies nach der folgenden Richtlinie blockieren';

  @override
  String get settings_cookiePolicyTitle => 'Cookie-Richtlinie';

  @override
  String get settings_cookiePolicyTotalProtectionLabel =>
      'Vollständiger Cookie-Schutz (empfohlen)';

  @override
  String get settings_cookiePolicyCrossSiteTrackersLabel =>
      'Websiteübergreifende Tracker und Social-Media-Tracker';

  @override
  String get settings_cookiePolicyUnvisitedLabel => 'Nicht besuchte Websites';

  @override
  String get settings_cookiePolicyThirdPartyLabel =>
      'Alle Drittanbieter-Cookies';

  @override
  String get settings_cookiePolicyAllCookiesLabel =>
      'Alle Cookies (kann Websites beeinträchtigen)';

  @override
  String get settings_blockTrackingContentTitle =>
      'Tracking-Inhalte blockieren';

  @override
  String get settings_blockTrackingContentSubtitle =>
      'In Websites eingebettete Tracking-Skripte und -Ressourcen blockieren';

  @override
  String get settings_trackingScopeApplyToTitle => 'Anwenden auf';

  @override
  String get settings_trackingScopeAllTabsLabel => 'Alle Tabs';

  @override
  String get settings_trackingScopePrivateOnlyLabel => 'Nur private Tabs';

  @override
  String get settings_adsAnalyticsSocialTrackersTitle =>
      'Werbe-, Analyse- und Social-Media-Tracker';

  @override
  String get settings_adsAnalyticsSocialTrackersSubtitle =>
      'Tracker der Kategorien Werbung, Analyse, soziale Netzwerke und Mozilla-Social blockieren';

  @override
  String get settings_cryptominersTitle => 'Krypto-Miner';

  @override
  String get settings_cryptominersSubtitle =>
      'Skripte blockieren, die das Gerät zum Schürfen von Kryptowährung nutzen';

  @override
  String get settings_knownFingerprintersTitle => 'Bekannte Fingerprinter';

  @override
  String get settings_knownFingerprintersSubtitle =>
      'Skripte blockieren, die Informationen sammeln, um das Gerät eindeutig zu identifizieren';

  @override
  String get settings_redirectTrackersTitle => 'Weiterleitungs-Tracker';

  @override
  String get settings_redirectTrackersSubtitle =>
      'Tracker blockieren, die Daten über zwischengeschaltete URL-Weiterleitungen sammeln';

  @override
  String get settings_suspectedFingerprintersTitle => 'Vermutete Fingerprinter';

  @override
  String get settings_suspectedFingerprintersSubtitle =>
      'Weitere Fingerprinting-Techniken blockieren, die zur Verfolgung genutzt werden könnten';

  @override
  String get settings_desktopModeSitesScreenTitle =>
      'Websites im Desktop-Modus';

  @override
  String get settings_desktopModeSitesScreenDescription =>
      'Diese Websites laden abweichend vom Standard immer im Desktop-Modus. Subdomains sind eingeschlossen („example.com“ umfasst z. B. auch „m.example.com“).';

  @override
  String get settings_desktopModeSitesEmptyLabel =>
      'Keine Websites hinzugefügt.';

  @override
  String get settings_dohTitle => 'DNS über HTTPS';

  @override
  String get settings_dohSubtitle =>
      'Schutzstufe für verschlüsseltes DNS und Auswahl des Resolvers.';

  @override
  String get settings_errorLogsCopiedMessage => 'Protokolle kopiert';

  @override
  String get settings_errorLogsSearchHint => 'Protokollmeldungen durchsuchen';

  @override
  String get settings_errorLogsCopyTooltip => 'Protokolle kopieren';

  @override
  String get settings_errorLogsEmptyLabel => 'Keine Protokolle verfügbar';

  @override
  String get settings_experimentalTitle => 'Experimentell';

  @override
  String get settings_experimentalSubtitle =>
      'Laufzeit-Isolierung und Startverhalten.';

  @override
  String get settings_isolatedContentProcessTitle =>
      'Isolierter Inhaltsprozess';

  @override
  String get settings_isolatedContentProcessKeywords =>
      'Neustart, neu starten, Prozess';

  @override
  String get settings_isolatedContentProcessSubtitle =>
      'Webinhalte in einem isolierten Prozess ausführen. Erfordert einen Neustart der App.';

  @override
  String get settings_appZygoteProcessTitle => 'App-Zygote-Prozess';

  @override
  String get settings_appZygoteProcessKeywords => 'Neustart, android 10';

  @override
  String get settings_appZygoteProcessSubtitle =>
      'Den Inhaltsdienst vorladen, damit der isolierte Prozess schneller startet. Erfordert Android 10+ und einen Neustart der App.';

  @override
  String get settings_extensionsTitle => 'Erweiterungen';

  @override
  String get settings_extensionsSubtitle =>
      'Add-ons, Update-Verhalten und Sicherheit von Erweiterungen.';

  @override
  String get settings_manageExtensionsTitle => 'Erweiterungen verwalten';

  @override
  String get settings_manageExtensionsKeywords =>
      'Add-ons, Browsererweiterungen';

  @override
  String get settings_manageExtensionsSubtitle =>
      'Installierte, deaktivierte, verfügbare und nicht unterstützte Erweiterungen durchsuchen';

  @override
  String get settings_customCollectionTitle => 'Eigene Sammlung';

  @override
  String get settings_customCollectionKeywords => 'Add-ons, Sammlung';

  @override
  String get settings_customCollectionSubtitle =>
      'Eine eigene Mozilla-Add-on-Sammlung verwenden';

  @override
  String get settings_automaticUpdatesTitle => 'Automatische Updates';

  @override
  String get settings_automaticUpdatesKeywords => 'Add-ons, Aktualisierungen';

  @override
  String get settings_automaticUpdatesSubtitle =>
      'Alle 12 Stunden automatisch nach Updates für Erweiterungen suchen und sie installieren';

  @override
  String settings_failedToLoadMessage(String error) {
    return 'Laden fehlgeschlagen: $error';
  }

  @override
  String get settings_allowUnsignedExtensionsTitle =>
      'Nicht signierte Erweiterungen erlauben';

  @override
  String get settings_allowUnsignedExtensionsKeywords => 'Add-ons, unsigniert';

  @override
  String get settings_allowUnsignedExtensionsSubtitle =>
      'Nicht signierte Erweiterungen wurden nicht von Mozilla geprüft';

  @override
  String get settings_allowUnsignedWarningText =>
      'Nicht signierte Erweiterungen nur aus vertrauenswürdigen Quellen installieren. Sie können Schadcode enthalten.';

  @override
  String get settings_allowUnsignedConfirmDialogTitle =>
      'Nicht signierte Erweiterungen erlauben?';

  @override
  String get settings_allowUnsignedConfirmWarningBold =>
      'Warnung: Dies schwächt die Sicherheit des Browsers erheblich.';

  @override
  String get settings_allowUnsignedConfirmBody =>
      'Nicht signierte Erweiterungen umgehen die Sicherheitsprüfung von Mozilla. Schädliche Erweiterungen können:\n\n• Alles lesen und ändern, was auf einer beliebigen Website angezeigt wird\n• Passwörter, Bankdaten und persönliche Daten stehlen\n• Die Browseraktivität unbemerkt überwachen\n• Weitere Schadsoftware auf dem Gerät installieren';

  @override
  String get settings_allowUnsignedConfirmFooter =>
      'Nur aktivieren, wenn eine selbst entwickelte Erweiterung installiert werden soll oder der Quelle uneingeschränkt vertraut wird.';

  @override
  String get settings_allowAction => 'Erlauben';

  @override
  String settings_allowActionCountdown(int seconds) {
    return 'Erlauben ($seconds)';
  }

  @override
  String get settings_fingerprintProtectionTitle => 'Fingerprinting-Schutz';

  @override
  String get settings_fingerprintProtectionKeywords =>
      'Datenschutz, Fingerabdruck, Privatsphäre';

  @override
  String get settings_fingerprintSearchHint =>
      'Schutzziele gegen Fingerprinting durchsuchen';

  @override
  String get settings_loadDefaultsAction => 'Standard laden';

  @override
  String get settings_loadHardenedDefaultsAction => 'Gehärteten Standard laden';

  @override
  String get settings_fingerprintOverrideTargetsSection => 'Schutzziele';

  @override
  String get settings_fingerprintInvalidOverride =>
      'Die gespeicherten Fingerprinting-Schutzziele haben kein gültiges Format';

  @override
  String get settings_fingerprintUnknownTarget =>
      'Die gespeicherten Fingerprinting-Schutzziele enthalten ein Ziel, das diese Version nicht kennt';

  @override
  String get settings_homeAndNewTabTitle => 'Startseite & neuer Tab';

  @override
  String get settings_homeAndNewTabSubtitle =>
      'Was die Startseite und neue Tabs anzeigen';

  @override
  String get settings_addressFieldLabel => 'Adresse';

  @override
  String get settings_homeTargetUrlEmptyError =>
      'Eine Adresse eingeben, sonst wird stattdessen die Startseite angezeigt';

  @override
  String get settings_homeTargetUrlInvalidError => 'Keine gültige Adresse';

  @override
  String get settings_applyWhenLastTabClosesTitle =>
      'Beim Schließen des letzten Tabs anwenden';

  @override
  String get settings_applyWhenLastTabClosesKeywords =>
      'schließen, letzter Tab, Container';

  @override
  String get settings_applyWhenLastTabClosesSubtitle =>
      'Nach dem Schließen des letzten Tabs in einem Container dort bleiben, statt einen Tab von woanders zu öffnen';

  @override
  String settings_homeSearchBarCurrentlyLabel(String value) {
    return 'Derzeit: $value';
  }

  @override
  String get settings_wallpaperTitle => 'Hintergrundbild';

  @override
  String get settings_wallpaperKeywords =>
      'Hintergrundbild, Hintergrund, Bild, Foto, Wallpaper, Unschärfe, abdunkeln, Startseite';

  @override
  String get settings_wallpaperSetSubtitle =>
      'Für die Startseite ist ein Hintergrundbild festgelegt';

  @override
  String get settings_wallpaperUnsetSubtitle =>
      'Ein Hintergrundbild für die Startseite festlegen';

  @override
  String get settings_customizeHomeSectionsTitle =>
      'Bereiche der Startseite anpassen';

  @override
  String get settings_customizeHomeSectionsKeywords =>
      'Startseite, Bereiche, Verknüpfungen, Zitat, Schnellaktionen, anordnen';

  @override
  String get settings_customizeHomeSectionsSubtitle =>
      'Auswählen und anordnen, was die Startseite anzeigt';

  @override
  String get settings_customizeNewTabSectionsTitle =>
      'Bereiche neuer Tabs anpassen';

  @override
  String get settings_customizeNewTabSectionsKeywords =>
      'neuer Tab, Bereiche, Verknüpfungen, anordnen';

  @override
  String get settings_customizeNewTabSectionsSubtitle =>
      'Auswählen und anordnen, was die Seite für neue Tabs anzeigt';

  @override
  String get settings_browserLanguagesTitle => 'Browsersprachen';

  @override
  String get settings_browserLanguagesKeywords =>
      'Sprache, Gebietsschema, Locale';

  @override
  String get settings_browserLanguagesSearchHint =>
      'Gebietsschemas nach Kennung suchen';

  @override
  String get settings_languageRegionSettingsSection =>
      'Sprach- & Regionseinstellungen';

  @override
  String get settings_browserLanguagePreferenceLabel =>
      'Sprachpräferenz des Browsers';

  @override
  String get settings_customLocaleSection => 'Eigenes Gebietsschema';

  @override
  String get settings_addCustomLocaleTitle =>
      'Eigenes Gebietsschema hinzufügen';

  @override
  String get settings_addCustomLocaleKeywords => 'Sprachkennung, Locale-Tag';

  @override
  String get settings_addCustomLocaleSubtitle =>
      'Eine Kennung wie en-US eingeben';

  @override
  String get settings_customLocaleFieldLabel => 'Eigenes Gebietsschema';

  @override
  String get settings_invalidLocaleError => 'Ungültige Gebietsschema-Kennung';

  @override
  String get settings_homeTargetHomeLabel => 'Startseite';

  @override
  String get settings_homeTargetResumeLastTabLabel => 'Zuletzt geöffneter Tab';

  @override
  String get settings_homeTargetCustomUrlLabel => 'Eigene Adresse';

  @override
  String get settings_homeTargetHomeDescription =>
      'Verknüpfungen und die ausgewählten Bereiche anzeigen';

  @override
  String get settings_homeTargetResumeLastTabDescription =>
      'Dort weitermachen, wo du aufgehört hast';

  @override
  String get settings_homeTargetCustomUrlDescription =>
      'Eine bestimmte Seite öffnen';

  @override
  String get settings_homeSearchBarAutoLabel => 'Der Tableiste folgen';

  @override
  String get settings_homeSearchBarTopLabel => 'Oben auf der Startseite';

  @override
  String get settings_homeSearchBarTabBarLabel => 'In der Tableiste';

  @override
  String get settings_homeSearchBarAutoDescription =>
      'An dem Rand, an dem die Tableiste ist';

  @override
  String get settings_homeSearchBarTopDescription =>
      'Eine angeheftete Suchleiste über den Bereichen der Startseite';

  @override
  String get settings_homeSearchBarTabBarDescription =>
      'Das Adressfeld der Tableiste, mit QR- und Sprachsuche';

  @override
  String get settings_generalTitle => 'Allgemein';

  @override
  String get settings_generalSubtitle =>
      'Erscheinungsbild, Downloads und Browser-Standards.';

  @override
  String get settings_defaultBrowserTileTitle => 'Standardbrowser';

  @override
  String get settings_defaultBrowserTileKeywords => 'Systembrowser, Standard';

  @override
  String get settings_defaultBrowserTileSubtitleSet =>
      'WebLibre ist der Standardbrowser';

  @override
  String get settings_defaultBrowserTileSubtitleNotSet =>
      'WebLibre als Standardbrowser festlegen';

  @override
  String get settings_defaultBrowserButtonDefault => 'Standard';

  @override
  String get settings_defaultBrowserButtonSet => 'Festlegen';

  @override
  String get settings_backupProfileTitle => 'Dieses Profil sichern';

  @override
  String get settings_backupProfileKeywords =>
      'Sicherung, Backup, Archiv, exportieren, speichern, verschlüsselt, wiederherstellen';

  @override
  String settings_backupProfileSubtitleReady(String name) {
    return '„$name“ in eine verschlüsselte Sicherungsdatei schreiben';
  }

  @override
  String get settings_backupProfileSubtitleError =>
      'Das aktive Profil konnte nicht gelesen werden';

  @override
  String get settings_settingsTransferTileTitle =>
      'Einstellungen exportieren & importieren';

  @override
  String get settings_settingsTransferTileKeywords =>
      'exportieren, importieren, Einstellungen, übertragen, teilen, Zwischenablage, json, kopieren, migrieren';

  @override
  String get settings_settingsTransferTileSubtitle =>
      'Einstellungen in eine Datei oder die Zwischenablage schreiben und wieder einlesen';

  @override
  String get settings_uiZoomTitle => 'Zoom der Oberfläche';

  @override
  String get settings_uiZoomKeywords => 'Skalierung, Zoom, Größe';

  @override
  String get settings_uiZoomSubtitle =>
      'Die Oberfläche verkleinern oder vergrößern';

  @override
  String get settings_disableAnimationsTitle => 'Animationen deaktivieren';

  @override
  String get settings_disableAnimationsKeywords => 'Bewegung, Animation';

  @override
  String get settings_disableAnimationsSubtitle =>
      'Bewegung reduzieren und App-Animationen ausschalten';

  @override
  String get settings_showModalBarrierTitle => 'Hintergrund abdunkeln';

  @override
  String get settings_showModalBarrierKeywords =>
      'Dialoge, Bottom Sheets, Overlay, Modal';

  @override
  String get settings_showModalBarrierSubtitle =>
      'Den Hintergrund hinter Dialogen und von unten eingeblendeten Bereichen abdunkeln';

  @override
  String get settings_showSearchCloseButtonTitle =>
      'Schließen-Schaltfläche anzeigen';

  @override
  String get settings_showSearchCloseButtonKeywords =>
      'zurück, schließen, ausblenden, E-Ink, eink, Barrierefreiheit, neuer Tab';

  @override
  String get settings_showSearchCloseButtonSubtitle =>
      'Eine Schaltfläche hinzufügen, um die Such- oder Neuer-Tab-Seite ohne Zurück-Geste zu schließen. Nützlich auf Geräten ohne Zurück-Taste.';

  @override
  String get settings_pureBlackTitle => 'Reines Schwarz (OLED)';

  @override
  String get settings_pureBlackKeywords =>
      'oled, amoled, hoher Kontrast, schwarz, dunkel';

  @override
  String get settings_pureBlackSubtitle =>
      'Im dunklen Design echtes Schwarz verwenden, um auf OLED-Bildschirmen Energie zu sparen';

  @override
  String get settings_themeTitle => 'Design';

  @override
  String get settings_themeKeywords => 'hell, dunkel, Design, Theme, Darkmode';

  @override
  String get settings_themeModeSystem => 'System';

  @override
  String get settings_themeModeLight => 'Hell';

  @override
  String get settings_themeModeDark => 'Dunkel';

  @override
  String get settings_appLanguageSystemDefault => 'Systemstandard';

  @override
  String settings_appLanguageCurrentlyLabel(String language) {
    return 'Derzeit: $language';
  }

  @override
  String get settings_refreshRateTitle => 'Bildwiederholrate';

  @override
  String get settings_refreshRateKeywords =>
      'fps, hz, hertz, Bildrate, Framerate, 60hz, 90hz, 120hz, flüssig, hohe Bildwiederholrate, Anzeigemodus';

  @override
  String get settings_refreshRateSubtitle =>
      '„Hoch“ für möglichst flüssiges Scrollen und flüssige Animationen auf Bildschirmen mit 90 oder 120 Hz wählen oder „Niedrig“, um Akku zu sparen.';

  @override
  String get settings_refreshRateModeSystem => 'System';

  @override
  String get settings_refreshRateModeHigh => 'Hoch';

  @override
  String get settings_refreshRateModeLow => 'Niedrig';

  @override
  String get settings_downloadFolderTitle => 'Download-Ordner';

  @override
  String get settings_downloadFolderKeywords =>
      'Downloads, Ordner, Verzeichnis, Speicher, speichern';

  @override
  String get settings_downloadFolderSubtitleDefault =>
      'Speichert im Download-Ordner des Systems';

  @override
  String settings_downloadFolderSubtitleUnavailable(String folderName) {
    return 'Nicht mehr verfügbar – speichert im Download-Ordner des Systems ($folderName)';
  }

  @override
  String get settings_downloadFolderSubtitleExternalManager =>
      'Die Download-Manager-App legt fest, wo Dateien gespeichert werden';

  @override
  String get settings_downloadFolderResetTooltip =>
      'Download-Ordner des Systems verwenden';

  @override
  String get settings_externalDownloadManagerTitle =>
      'Externen Download-Manager verwenden';

  @override
  String get settings_externalDownloadManagerKeywords =>
      'Downloads, Download-Manager';

  @override
  String get settings_externalDownloadManagerSubtitle =>
      'Downloads mit einer anderen App verwalten';

  @override
  String get settings_defaultBrowserSectionTitle => 'Standardbrowser';

  @override
  String get settings_defaultBrowserSectionKeywords =>
      'Browser-Standards, Standardbrowser';

  @override
  String get settings_indexDefaultBrowserSubtitle =>
      'WebLibre als Standardbrowser festlegen';

  @override
  String get settings_appearanceSectionTitle => 'Erscheinungsbild';

  @override
  String get settings_indexThemeSubtitle => 'System, hell oder dunkel wählen';

  @override
  String get settings_indexAppLanguageTitle => 'App-Sprache';

  @override
  String get settings_indexAppLanguageKeywords =>
      'Sprache, Gebietsschema, Übersetzung, Oberflächensprache, Deutsch';

  @override
  String get settings_indexAppLanguageSubtitle =>
      'Die Sprache der WebLibre-Oberfläche auswählen';

  @override
  String get settings_indexRefreshRateSubtitle =>
      'Eine hohe oder niedrige Bildwiederholrate anfordern (Android)';

  @override
  String get settings_indexShowCloseButtonSubtitle =>
      'Eine Schaltfläche hinzufügen, um die Such- oder Neuer-Tab-Seite ohne Zurück-Geste zu schließen';

  @override
  String get settings_profileSectionTitle => 'Profil';

  @override
  String get settings_profileSectionKeywords => 'Benutzer, Profil';

  @override
  String get settings_indexBackupProfileSubtitle =>
      'Eine verschlüsselte Sicherung des verwendeten Profils erstellen';

  @override
  String get settings_indexSettingsTransferSubtitle =>
      'Einstellungen zwischen Profilen oder Geräten übertragen oder an einen Fehlerbericht anhängen';

  @override
  String get settings_downloadsSectionTitle => 'Downloads';

  @override
  String get settings_indexDownloadFolderSubtitle =>
      'Festlegen, wo heruntergeladene Dateien gespeichert werden';

  @override
  String get settings_contentIdentitySectionTitle => 'Inhalte & Identität';

  @override
  String get settings_contentIdentitySectionKeywords => 'Engine';

  @override
  String get settings_indexJavascriptSubtitle =>
      'Skripte auf Websites ein- oder ausschalten';

  @override
  String get settings_indexUserAgentSubtitle =>
      'Den User-Agent-String des Browsers überschreiben';

  @override
  String get settings_indexEnterpriseRootsSubtitle =>
      'Zertifikate aus dem Android-CA-Speicher erlauben';

  @override
  String get settings_experimentalSectionTitle => 'Experimentell';

  @override
  String get settings_developerToolsSectionTitle => 'Entwicklerwerkzeuge';

  @override
  String get settings_developerToolsSectionKeywords => 'Debug, Entwickler';

  @override
  String get settings_indexUnmountGeckoViewSubtitle =>
      'Die Web-Engine nach einer Überlagerung neu aufbauen, statt sie bereitzuhalten';

  @override
  String get settings_tabsSectionTitle => 'Tabs';

  @override
  String get settings_indexTabListDirectionSubtitle =>
      'Festlegen, wie Tabs in der Listenansicht sortiert werden';

  @override
  String get settings_indexTabBarDirectionSubtitle =>
      'Festlegen, wie Tabs in der Tableiste sortiert werden';

  @override
  String get settings_indexChildTabPlacementSubtitle =>
      'Festlegen, wo aus einem anderen Tab geöffnete Tabs eingefügt werden';

  @override
  String get settings_indexCreateChildTabsSubtitle =>
      'Eine Schaltfläche anzeigen, die einen Unter-Tab unter dem aktuellen Tab hinzufügt';

  @override
  String get settings_indexBackgroundTabBehaviorSubtitle =>
      'Festlegen, was passiert, nachdem ein Tab im Hintergrund geöffnet wurde';

  @override
  String get settings_navigationSectionTitle => 'Navigation';

  @override
  String get settings_indexDoubleBackCloseTabSubtitle =>
      'Zum Schließen des aktuellen Tabs zweimal die Zurück-Taste drücken';

  @override
  String get settings_indexTabBarSwipesSubtitle =>
      'Festlegen, was Wischgesten auf der Tableiste bewirken';

  @override
  String get settings_indexSequentialTabNavigationSubtitle =>
      'Festlegen, wo das Durchblättern der Tabs endet';

  @override
  String get settings_indexOpenLinksInAppsSubtitle =>
      'Festlegen, wie Links zu externen Apps geöffnet werden';

  @override
  String get settings_desktopModeSectionTitle => 'Desktop-Modus';

  @override
  String get settings_indexGlobalDesktopModeSubtitle =>
      'Neue Tabs standardmäßig im Desktop-Modus öffnen';

  @override
  String get settings_homeScreenSectionTitle => 'Startbildschirm';

  @override
  String get settings_indexAllowNonManifestPwaInstallSubtitle =>
      'Websites ohne Manifest als Apps installieren lassen';

  @override
  String get settings_externalLinksSectionTitle => 'Externe Links';

  @override
  String get settings_indexCustomTabsSubtitle =>
      'Andere Apps Links in einem schlanken In-App-Tab statt im Hauptbrowser öffnen lassen';

  @override
  String get settings_bookmarksSectionTitle => 'Lesezeichen';

  @override
  String get settings_resolverSettingsSectionTitle => 'Resolver-Einstellungen';

  @override
  String get settings_indexDnsOverHttpsResolverTitle => 'DNS über HTTPS';

  @override
  String get settings_indexDnsOverHttpsResolverKeywords =>
      'doh, Resolver, DNS-Anbieter, eigener Resolver';

  @override
  String get settings_indexDnsOverHttpsResolverSubtitle =>
      'Schutzstufe, Anbieterauswahl und gespeicherte eigene Resolver';

  @override
  String get settings_runtimeStartupSectionTitle => 'Laufzeit & Start';

  @override
  String get settings_indexIsolatedContentProcessSubtitle =>
      'Webinhalte in einem isolierten Prozess ausführen';

  @override
  String get settings_indexAppZygoteProcessSubtitle =>
      'Den Inhaltsdienst für einen schnelleren isolierten Start vorladen';

  @override
  String get settings_startupSectionTitle => 'Start';

  @override
  String get settings_startupSectionKeywords =>
      'Start, Startseite, fortsetzen, letzter Tab, eigene URL';

  @override
  String get settings_indexHomeTargetTitle => 'Wenn kein Tab anzuzeigen ist';

  @override
  String get settings_indexHomeTargetKeywords =>
      'Start, fortsetzen, letzter Tab, eigene URL, Startseite, Homepage';

  @override
  String get settings_indexHomeTargetSubtitle =>
      'Beim Start und nach dem Schließen des letzten Tabs';

  @override
  String get settings_indexHomeTargetOnLastTabClosedSubtitle =>
      'Andernfalls wird stattdessen ein Tab aus einem anderen Container geöffnet';

  @override
  String get settings_homeAppearanceSectionTitle => 'Erscheinungsbild';

  @override
  String get settings_homeAppearanceSectionKeywords =>
      'Startseite, Hintergrundbild, Hintergrund, Bild, Unschärfe, abdunkeln';

  @override
  String get settings_indexWallpaperSubtitle =>
      'Ein Hintergrundbild für die Startseite';

  @override
  String get settings_layoutSectionTitle => 'Layout';

  @override
  String get settings_layoutSectionKeywords =>
      'Startseite, neuer Tab, Bereiche, Module, Layout';

  @override
  String get settings_indexHomeSearchBarPlacementTitle =>
      'Position der Suchleiste';

  @override
  String get settings_indexHomeSearchBarPlacementKeywords =>
      'Suche, Leiste, Position, Adresse, URL, oben, unten, Tableiste, Startseite';

  @override
  String get settings_indexHomeSearchBarPlacementSubtitle =>
      'Wo die Startseite ihr Suchfeld anbietet';

  @override
  String get settings_allowlistExceptionsSectionTitle =>
      'Ausnahmen der Positivliste';

  @override
  String get settings_indexAllowlistExceptionsTitle =>
      'Ausnahmen der Positivliste';

  @override
  String get settings_indexAllowlistExceptionsSubtitle =>
      'Kompatibilitätsausnahmen für größere und kleinere Website-Probleme';

  @override
  String get settings_cookiesSectionTitle => 'Cookies';

  @override
  String get settings_indexCookiesSubtitle =>
      'Cookie-Blockiermodus und Richtlinienauswahl';

  @override
  String get settings_trackingContentSectionTitle => 'Tracking-Inhalte';

  @override
  String get settings_indexTrackingContentTitle => 'Tracking-Inhalte';

  @override
  String get settings_indexTrackingContentSubtitle =>
      'Tracking-Skripte und Geltungsbereich der Blockierung';

  @override
  String get settings_trackersSectionTitle => 'Tracker';

  @override
  String get settings_indexTrackersSubtitle =>
      'Krypto-Miner, bekannte Fingerprinter und Weiterleitungs-Tracker';

  @override
  String get settings_advancedFingerprintingProtectionSectionTitle =>
      'Erweiterter Fingerprinting-Schutz';

  @override
  String get settings_indexAdvancedFingerprintingProtectionTitle =>
      'Erweiterter Fingerprinting-Schutz';

  @override
  String get settings_indexAdvancedFingerprintingProtectionSubtitle =>
      'Vermutete Fingerprinter und Geltungsbereich';

  @override
  String get settings_usageDataSectionTitle => 'Nutzungsdaten';

  @override
  String get settings_repositoriesSectionTitle => 'Quellen';

  @override
  String get settings_indexGeneralBangsSubtitle =>
      'Bei Bedarf von GitHub synchronisieren';

  @override
  String get settings_generalBangsTileTitle => 'Allgemeine Bangs';

  @override
  String get settings_generalBangsTileKeywords => 'Quelle, Repository';

  @override
  String get settings_generalBangsTileSubtitle =>
      'Bei Bedarf von GitHub synchronisieren';

  @override
  String get settings_indexKagiBangsSubtitle =>
      'Bei Bedarf von GitHub synchronisieren';

  @override
  String get settings_kagiBangsTileTitle => 'Kagi-Bangs';

  @override
  String get settings_kagiBangsTileKeywords => 'Quelle, Repository';

  @override
  String get settings_kagiBangsTileSubtitle =>
      'Bei Bedarf von GitHub synchronisieren';

  @override
  String get settings_extensionsSectionTitle => 'Erweiterungen';

  @override
  String get settings_updatesSectionTitle => 'Updates';

  @override
  String get settings_securitySectionTitle => 'Sicherheit';

  @override
  String get settings_actionResetToDefaults => 'Auf Standard zurücksetzen';

  @override
  String get settings_menuLayoutTitle => 'Menü anpassen';

  @override
  String get settings_menuLayoutHintSections =>
      'Zum Anordnen ziehen. Einen Bereich ausschalten, um ihn im Menü auszublenden.';

  @override
  String get settings_menuLayoutHintSectionItems =>
      'Ziehen, um die Zeilen dieses Bereichs anzuordnen.';

  @override
  String get settings_menuLayoutHintSubItems =>
      'Ziehen, um die Zeilen anzuordnen, die dieser Eintrag öffnet.';

  @override
  String get settings_moduleSurfaceHint =>
      'Zum Anordnen ziehen. Einen Bereich ausschalten, um ihn hier auszublenden, ohne die andere Seite zu ändern.';

  @override
  String get settings_moduleSurfaceTitleHome => 'Startseite anpassen';

  @override
  String get settings_moduleSurfaceTitleNewTab => 'Neuen Tab anpassen';

  @override
  String get settings_homeSearchBarRowTitle => 'Suchleiste';

  @override
  String get settings_proxyTitle => 'Proxy';

  @override
  String get settings_proxySubtitle =>
      'Proxy-Verbindungen verwalten und festlegen, welche Tabs sie nutzen.';

  @override
  String get settings_proxyConnectionsTitle => 'Proxy-Verbindungen';

  @override
  String get settings_proxyConnectionsKeywords =>
      'sing-box, socks, vpn, wireguard, tor, onion, Brücken, bridges, obfs4, snowflake';

  @override
  String get settings_proxyConnectionsSubtitle =>
      'Proxy-Profile und Verbindungen verwalten';

  @override
  String get settings_proxyRoutingTitle => 'Proxy-Routing';

  @override
  String get settings_proxyRoutingKeywords =>
      'Routing, Container, Weiterleitung';

  @override
  String get settings_proxyRoutingSubtitle =>
      'Festlegen, welcher Proxy normale und private Tabs übernimmt';

  @override
  String get settings_proxyLogsTitle => 'Proxy-Protokolle';

  @override
  String get settings_proxyLogsKeywords =>
      'Protokoll, Protokollierung, Logs, Diagnose, Debug, Trace, ausführlich, Fehlersuche, Stufe';

  @override
  String get settings_toolbarLayoutTitle => 'Symbolleiste & Layout';

  @override
  String get settings_toolbarLayoutSearchHint =>
      'Einstellungen für Symbolleiste und Layout durchsuchen';

  @override
  String get settings_privacySecurityTitle => 'Datenschutz & Sicherheit';

  @override
  String get settings_privacySecuritySubtitle =>
      'Tracking-Schutz, Fingerprinting, Browserdaten und Netzwerkhärtung.';

  @override
  String get settings_trackingProtectionExceptionsTitle =>
      'Ausnahmen vom Tracking-Schutz';

  @override
  String get settings_trackingProtectionExceptionsKeywords => 'Ausnahmen';

  @override
  String get settings_trackingProtectionExceptionsTileSubtitle =>
      'Websites, auf denen der Tracking-Schutz deaktiviert ist';

  @override
  String get settings_incognitoModeTitle => 'Inkognito-Modus';

  @override
  String get settings_incognitoModeKeywords => 'privater Modus, inkognito';

  @override
  String get settings_incognitoModeSubtitle =>
      'Ausgewählte Browserdaten beim Neustart der App löschen';

  @override
  String get settings_trackingProtectionExceptionsSearchHint =>
      'Ausnahme-URLs durchsuchen';

  @override
  String get settings_trackingProtectionExceptionsDeleteAll => 'Alle löschen';

  @override
  String get settings_trackingProtectionExceptionsSectionTitle =>
      'Ausnahmeliste';

  @override
  String get settings_trackingProtectionExceptionsEntrySubtitle =>
      'Website mit deaktiviertem Tracking-Schutz';

  @override
  String get settings_trackingProtectionExceptionsRemoveTooltip =>
      'Ausnahme entfernen';

  @override
  String get settings_trackingProtectionExceptionsEmptyTitle =>
      'Keine Ausnahmen';

  @override
  String get settings_trackingProtectionExceptionsEmptySubtitle =>
      'Zu den Ausnahmen hinzugefügte Websites erscheinen hier';

  @override
  String get settings_trackingProtectionExceptionsErrorTitle =>
      'Fehler beim Laden der Ausnahmen';

  @override
  String settings_trackingProtectionExceptionsDeleteAllFailed(String error) {
    return 'Ausnahmen konnten nicht gelöscht werden: $error';
  }

  @override
  String settings_trackingProtectionExceptionsRemoveFailed(String error) {
    return 'Ausnahme konnte nicht entfernt werden: $error';
  }

  @override
  String get settings_deleteBrowsingDataTileTitle => 'Browserdaten löschen';

  @override
  String get settings_deleteBrowsingDataTileKeywords => 'Daten löschen, leeren';

  @override
  String get settings_autoClearHistoryTitle => 'Verlauf automatisch löschen';

  @override
  String get settings_autoClearHistoryKeywords => 'Aufbewahrung des Verlaufs';

  @override
  String get settings_autoClearHistorySubtitle =>
      'Browserverlauf, der älter als der gewählte Zeitraum ist, automatisch löschen';

  @override
  String get settings_autoClearUnassignedTabsTitle =>
      'Nicht zugeordnete Tabs automatisch schließen';

  @override
  String get settings_autoClearUnassignedTabsKeywords => 'Tabs aufräumen';

  @override
  String get settings_autoClearUnassignedTabsSubtitle =>
      'Nicht zugeordnete Tabs, die älter als der gewählte Zeitraum sind, automatisch schließen';

  @override
  String get settings_durationNever => 'Nie';

  @override
  String get settings_duration1Day => '1 Tag';

  @override
  String get settings_duration3Days => '3 Tage';

  @override
  String get settings_duration1Week => '1 Woche';

  @override
  String get settings_duration2Weeks => '2 Wochen';

  @override
  String get settings_duration1Month => '1 Monat';

  @override
  String get settings_duration3Months => '3 Monate';

  @override
  String get settings_globalPrivacyControlTitle =>
      'Global Privacy Control (GPC)';

  @override
  String get settings_globalPrivacyControlKeywords =>
      'gpc, Datenverkauf, Datenschutz';

  @override
  String get settings_screenshotProtectionTitle => 'Screenshot-Schutz';

  @override
  String get settings_screenshotProtectionKeywords =>
      'Screenshots, Bildschirmfotos';

  @override
  String get settings_screenshotProtectionSubtitle =>
      'Blockiert unter Android Screenshots und Bildschirmaufnahmen dieser App.';

  @override
  String get settings_allowPrivateTabScreenshotsTitle =>
      'Screenshots in privaten Tabs erlauben';

  @override
  String get settings_allowPrivateTabScreenshotsKeywords =>
      'Screenshots, inkognito, privat';

  @override
  String get settings_allowPrivateTabScreenshotsOverriddenSubtitle =>
      'Wird vom Screenshot-Schutz überschrieben, der Aufnahmen in allen Tabs blockiert.';

  @override
  String get settings_allowPrivateTabScreenshotsSubtitle =>
      'Private Tabs können als Screenshot oder Bildschirmaufnahme erfasst werden und erscheinen in der Vorschau des App-Wechslers.';

  @override
  String get settings_httpsOnlyModeTitle =>
      'Unsichere HTTP-Verbindungen blockieren';

  @override
  String get settings_httpsOnlyModeKeywords => 'nur https, https only';

  @override
  String get settings_httpsOnlyModeDisabledLabel => 'Aus';

  @override
  String get settings_httpsOnlyModeEnabledLabel => 'An';

  @override
  String get settings_httpsOnlyModePrivateOnlyLabel => 'Nur privat';

  @override
  String get settings_dnsOverHttpsTileTitle => 'DNS über HTTPS';

  @override
  String get settings_enhancedTrackingProtectionTitle =>
      'Verbesserter Schutz vor Aktivitätenverfolgung';

  @override
  String get settings_enhancedTrackingProtectionKeywords =>
      'etp, Standard, streng, benutzerdefiniert, Tracking-Schutz';

  @override
  String get settings_trackingProtectionDisabledLabel => 'Deaktiviert';

  @override
  String get settings_trackingProtectionStandardLabel => 'Standard';

  @override
  String get settings_trackingProtectionStandardSubtitle =>
      'Bietet eine Balance zwischen Schutz und Kompatibilität, indem weniger Tracker-Kategorien blockiert werden.';

  @override
  String get settings_trackingProtectionStrictLabel => 'Streng';

  @override
  String get settings_trackingProtectionStrictSubtitle =>
      'Blockiert mehr Tracker-Kategorien einschließlich Tracking-Inhalten, kann aber manche Websites beeinträchtigen.';

  @override
  String get settings_trackingProtectionCustomLabel => 'Benutzerdefiniert';

  @override
  String get settings_trackingProtectionCustomSubtitle =>
      'Festlegen, welche Tracker und Skripte blockiert werden.';

  @override
  String get settings_contentBlockingDatabaseTitle =>
      'Datenbank für Inhaltsblockierung';

  @override
  String get settings_contentBlockingDatabaseKeywords =>
      'Werbung, Tracker, Inhaltsblockierung';

  @override
  String get settings_contentBlockingDatabaseSubtitle =>
      'GeckoView-Blocklisten für ETP-Kategorien wie Werbung, Analyse und Social-Media-Tracker verwenden. Erfordert einen Neustart der App.';

  @override
  String get settings_bounceTrackingProtectionTitle =>
      'Schutz vor Bounce-Tracking';

  @override
  String get settings_bounceTrackingProtectionKeywords =>
      'Weiterleitungs-Tracker, Redirect-Tracker';

  @override
  String get settings_bounceTrackingProtectionSubtitle =>
      'Blockiert Weiterleitungs-Tracker, die über zwischengeschaltete URL-Weiterleitungen zwischen Websites Daten sammeln';

  @override
  String get settings_queryParameterStrippingTitle =>
      'Entfernen von Query-Parametern';

  @override
  String get settings_queryParameterStrippingKeywords =>
      'utm, Parameter, Tracking';

  @override
  String get settings_queryParameterStrippingSubtitle =>
      'Entfernt Tracking-Parameter aus URLs, um websiteübergreifendes Tracking zu verhindern';

  @override
  String get settings_queryParameterStrippingDisabledLabel => 'Aus';

  @override
  String get settings_queryParameterStrippingEnabledLabel => 'An';

  @override
  String get settings_queryParameterStrippingPrivateOnlyLabel => 'Nur privat';

  @override
  String get settings_uBlockFilterListsTileTitle =>
      'uBlock-Filterlisten & Härtungen';

  @override
  String get settings_uBlockFilterListsTileKeywords =>
      'ublock, Filter, Werbeblocker';

  @override
  String get settings_uBlockFilterListsTileSubtitle =>
      'Filterlisten verwalten und WebLibre-Härtungen anwenden';

  @override
  String get settings_fissionEnabledTitle => 'Fission (Website-Isolierung)';

  @override
  String get settings_fissionEnabledKeywords =>
      'Website-Isolierung, Site Isolation';

  @override
  String get settings_fissionEnabledSubtitle =>
      'Isoliert jede Website in einem eigenen Betriebssystemprozess für mehr Sicherheit. Erfordert einen Neustart der App.';

  @override
  String get settings_safeBrowsingMalwareTitle =>
      'Safe-Browsing-Schutz vor Schadsoftware';

  @override
  String get settings_safeBrowsingMalwareKeywords =>
      'google safe browsing, Malware, Schadsoftware';

  @override
  String get settings_safeBrowsingMalwareSubtitle =>
      'Vor gefährlichen Websites und schädlichen Downloads warnen.';

  @override
  String get settings_safeBrowsingPhishingTitle =>
      'Safe-Browsing-Schutz vor Phishing';

  @override
  String get settings_safeBrowsingPhishingKeywords =>
      'google safe browsing, Phishing, Betrug';

  @override
  String get settings_safeBrowsingPhishingSubtitle =>
      'Vor betrügerischen Websites und Anmeldeseiten warnen.';

  @override
  String get settings_extensionsWebApiTitle => 'Web-API für Erweiterungen';

  @override
  String get settings_extensionsWebApiKeywords => 'Erweiterungs-API';

  @override
  String get settings_extensionsWebApiSubtitle =>
      'Die mozAddonManager-API für Webinhalte und Erweiterungsseiten bereitstellen. Erfordert einen Neustart der App.';

  @override
  String get settings_appOpeningProtectionSectionHeader =>
      'Schutz vor Öffnen durch Apps';

  @override
  String get settings_blockAppsOpeningBrowserTitle =>
      'Apps am Öffnen des Browsers hindern';

  @override
  String get settings_blockAppsOpeningBrowserKeywords =>
      'Intent-Gatekeeper, externe Apps';

  @override
  String get settings_blockAppsOpeningBrowserSubtitle =>
      'Vor dem Öffnen von Links, die andere Apps an WebLibre senden, nachfragen.';

  @override
  String get settings_managedAppsSectionHeader => 'Verwaltete Apps';

  @override
  String get settings_managedAppAlwaysAllowedLabel => 'Immer erlaubt';

  @override
  String get settings_managedAppAlwaysBlockedLabel => 'Immer blockiert';

  @override
  String get settings_managedAppActionAllow => 'Erlauben';

  @override
  String get settings_managedAppActionBlock => 'Blockieren';

  @override
  String get settings_browserLanguagesTileTitle => 'Browsersprachen';

  @override
  String get settings_browserLanguagesTileSubtitle =>
      'Sprachpräferenzen festlegen, die Websites mitgeteilt werden';

  @override
  String get settings_fingerprintProtectionTileTitle => 'Fingerprinting-Schutz';

  @override
  String get settings_fingerprintProtectionTileSubtitle =>
      'Feinsteuerung des Schutzes vor Browser-Fingerprinting';

  @override
  String get settings_resistFingerprintingTileTitle => 'Resist Fingerprinting';

  @override
  String get settings_resistFingerprintingTileKeywords => 'rfp, Fingerprinting';

  @override
  String get settings_resistFingerprintingTileSubtitle =>
      'Erweiterte Härtung gegen Fingerprinting';

  @override
  String get settings_lnaEnabledTitle => 'Zugriff auf das lokale Netzwerk';

  @override
  String get settings_lnaEnabledKeywords => 'lan, lokales Netzwerk, Heimnetz';

  @override
  String get settings_lnaEnabledSubtitle =>
      'Blockieren von Zugriffen auf das lokale Netzwerk und seine Geräte aktivieren';

  @override
  String get settings_lnaBlockingTitle =>
      'Anfragen ins lokale Netzwerk blockieren';

  @override
  String get settings_lnaBlockingKeywords => 'lan, lokales Netzwerk, Heimnetz';

  @override
  String get settings_lnaBlockingSubtitle =>
      'Anfragen von Webseiten an Adressen im lokalen Netzwerk blockieren';

  @override
  String get settings_lnaBlockTrackersTitle =>
      'Tracker im lokalen Netzwerk blockieren';

  @override
  String get settings_lnaBlockTrackersKeywords =>
      'lan, lokales Netzwerk, Heimnetz';

  @override
  String get settings_lnaBlockTrackersSubtitle =>
      'Trackern den Zugriff auf Ressourcen im lokalen Netzwerk verwehren';

  @override
  String get settings_transferTitle => 'Exportieren & Importieren';

  @override
  String get settings_transferChangeExportFolder => 'Exportordner ändern';

  @override
  String get settings_transferIntro =>
      'Einstellungen zwischen Profilen oder Geräten übertragen oder an einen Fehlerbericht anhängen. Übertragen werden nur Einstellungen – keine Tabs, kein Verlauf, keine Lesezeichen oder Zugangsdaten. Um diese zu übertragen, das gesamte Profil sichern.';

  @override
  String get settings_transferDeviceOnlyNote =>
      'Websuche-Einstellungen, Layout von Startseite und neuem Tab, Menüreihenfolge und angeheftete Add-ons bleiben auf diesem Gerät';

  @override
  String get settings_transferExportSectionTitle => 'Exportieren';

  @override
  String get settings_transferExportSectionSubtitle =>
      'Die ausgewählten Bereiche in eine lesbare Datei exportieren';

  @override
  String get settings_transferSaveFileButton => 'Datei speichern';

  @override
  String get settings_transferImportSectionTitle => 'Importieren';

  @override
  String get settings_transferImportSectionSubtitle =>
      'Nach dem Öffnen der Datei auswählen, welche Einstellungen übernommen werden';

  @override
  String get settings_transferOpenFileButton => 'Datei öffnen';

  @override
  String get settings_transferPasteButton => 'Einfügen';

  @override
  String settings_transferExportFolderChanged(String name) {
    return 'Exporte werden in $name gespeichert';
  }

  @override
  String settings_transferSavedAs(String name) {
    return 'Gespeichert als $name';
  }

  @override
  String get settings_transferExportFolderGone =>
      'Der Exportordner existiert nicht mehr. Erneut einen auswählen und noch einmal versuchen.';

  @override
  String settings_transferSaveFailed(String error) {
    return 'Der Export konnte nicht gespeichert werden: $error';
  }

  @override
  String get settings_transferCopiedToClipboard =>
      'Einstellungen in die Zwischenablage kopiert';

  @override
  String settings_transferCopyFailed(String error) {
    return 'Der Export konnte nicht kopiert werden: $error';
  }

  @override
  String get settings_transferImportNothingApplicable =>
      'Dieser Export enthält nichts, was diese WebLibre-Version übernehmen kann.';

  @override
  String get settings_transferImportedSuccess => 'Einstellungen importiert';

  @override
  String settings_transferImportFailed(String error) {
    return 'Die Einstellungen konnten nicht importiert werden: $error';
  }

  @override
  String get settings_transferNotASettingsFile =>
      'Diese Datei ist kein Einstellungsexport.';

  @override
  String settings_transferReadFileFailed(String error) {
    return 'Die Datei konnte nicht gelesen werden: $error';
  }

  @override
  String get settings_transferClipboardEmpty => 'Die Zwischenablage ist leer.';

  @override
  String settings_transferReadClipboardFailed(String error) {
    return 'Die Zwischenablage konnte nicht gelesen werden: $error';
  }

  @override
  String get settings_transferSectionAppSettingsTitle => 'App-Einstellungen';

  @override
  String settings_transferSectionAppSettingsDescription(String torBrand) {
    return 'Erscheinungsbild, Surfen, Tabs, Datenschutz, $torBrand und Einstellungen der Web-Engine';
  }

  @override
  String get settings_transferSectionGeckoPrefsTitle => 'Gecko-Präferenzen';

  @override
  String get settings_transferSectionGeckoPrefsDescription =>
      'Von Hand geänderte erweiterte Engine-Präferenzen';

  @override
  String get settings_importErrorNotJson => 'Dies ist keine JSON-Datei.';

  @override
  String get settings_importErrorNotSettingsExport =>
      'Dies ist kein Einstellungsexport von WebLibre.';

  @override
  String get settings_importErrorMissingFormatVersion =>
      'Der Export gibt keine Formatversion an.';

  @override
  String settings_importErrorNewerFormatVersion(int version, int supported) {
    return 'Dieser Export stammt von einer neueren WebLibre-Version (Format $version, diese Version liest bis $supported). Die App aktualisieren und erneut versuchen.';
  }

  @override
  String get settings_importErrorNoSettings =>
      'Der Export enthält keine Einstellungen.';

  @override
  String settings_importErrorMalformedSection(String section) {
    return 'Der Bereich „$section“ ist fehlerhaft.';
  }

  @override
  String settings_importErrorMalformedField(String field) {
    return 'Das Feld „$field“ des Exports ist fehlerhaft.';
  }

  @override
  String settings_importErrorUnreadablePrefsLine(String section, String line) {
    return 'Der Bereich „$section“ enthält eine Zeile, die WebLibre nicht lesen kann: „$line“. Ein Import würde Präferenzen zurücksetzen, statt sie wiederherzustellen.';
  }

  @override
  String settings_importErrorNotPrefsSnapshot(String section) {
    return 'Der Bereich „$section“ ist kein Präferenz-Snapshot von WebLibre.';
  }

  @override
  String settings_importErrorMissingSchemaVersion(String section) {
    return 'Der Bereich „$section“ gibt keine Schemaversion an.';
  }

  @override
  String settings_importErrorUnreadablePref(String section, String pref) {
    return 'Der Bereich „$section“ enthält eine Präferenz, die WebLibre nicht zurücklesen konnte: „$pref“.';
  }

  @override
  String settings_importErrorNewerSectionSchema(
    String section,
    int version,
    int supported,
  ) {
    return 'Der Bereich „$section“ stammt von einer neueren WebLibre-Version (Schema $version, diese Version liest bis $supported). Die App aktualisieren und erneut versuchen.';
  }

  @override
  String settings_importPartialFailure(String failed, String error) {
    return 'Der Bereich „$failed“ wurde mittendrin abgebrochen und ist möglicherweise nur teilweise übernommen: $error';
  }

  @override
  String settings_importPartialFailureAfterApplied(
    String applied,
    String failed,
    String error,
  ) {
    return 'Importiert: $applied. Der Bereich „$failed“ wurde danach mittendrin abgebrochen und ist möglicherweise nur teilweise übernommen: $error';
  }

  @override
  String get settings_webEngineHardeningTitle => 'Härtung der Web-Engine';

  @override
  String get settings_webEngineHardeningKeywords =>
      'Härtung, Hardening, Sicherheit';

  @override
  String get settings_webEngineHardeningSearchHint =>
      'Härtungsgruppen durchsuchen';

  @override
  String get settings_webEngineHardeningResetAllMenuItem =>
      'Alle Einstellungen zurücksetzen';

  @override
  String get settings_webEngineHardeningResetAllDialogTitle =>
      'Alle Einstellungen zurücksetzen?';

  @override
  String get settings_webEngineHardeningResetAllDialogContent =>
      'Dadurch werden alle benutzerdefinierten Einstellungen der Web-Engine auf ihre Standardwerte zurückgesetzt.';

  @override
  String get settings_webEngineHardeningOverviewTitle => 'Übersicht';

  @override
  String get settings_webEngineHardeningCompleteTitle => 'Vollständige Härtung';

  @override
  String get settings_webEngineHardeningCompleteSubtitle =>
      'Alle gruppierten Härtungseinstellungen anwenden oder zurücksetzen';

  @override
  String get settings_webEngineHardeningCompleteToggleHint =>
      'Alle gruppierten Härtungseinstellungen auf einmal umschalten.';

  @override
  String get settings_webEngineHardeningGroupsTitle => 'Härtungsgruppen';

  @override
  String get settings_webEngineHardeningLoadFailedTitle =>
      'Einstellungen konnten nicht geladen werden';

  @override
  String get settings_webEngineHardeningGroupSearchHint =>
      'Härtungseinstellungen durchsuchen';

  @override
  String get settings_webEngineHardeningGroupControlsTitle =>
      'Gruppensteuerung';

  @override
  String get settings_webEngineHardeningPreferenceSettingsTitle =>
      'Einzelne Einstellungen';

  @override
  String get settings_webEngineHardeningOptionalBadge => 'Optional';

  @override
  String get settings_settingsHomeTitle => 'Einstellungen';

  @override
  String get settings_settingsHomeSearchHint =>
      'Alle Einstellungen durchsuchen';

  @override
  String get settings_searchTitle => 'Suche';

  @override
  String get settings_searchSubtitle =>
      'Anbieter, Bangs, Verlaufsvorschläge und Suche auf dem Gerät.';

  @override
  String get settings_defaultSearchProviderTitle => 'Standard-Suchanbieter';

  @override
  String get settings_defaultSearchProviderKeywords => 'Suchmaschine';

  @override
  String get settings_defaultAutocompleteProviderTitle =>
      'Standard-Anbieter für Suchvorschläge';

  @override
  String get settings_defaultAutocompleteProviderKeywords =>
      'Vorschläge, Autovervollständigung';

  @override
  String get settings_customSearchEnginesTitle => 'Eigene Suchmaschinen';

  @override
  String get settings_customSearchEnginesKeywords => 'eigene Bangs, Anbieter';

  @override
  String get settings_customSearchEnginesSubtitle =>
      'Eigene Suchanbieter hinzufügen und verwalten';

  @override
  String get settings_bangSettingsListTitle => 'Bang-Einstellungen';

  @override
  String get settings_bangSettingsListSubtitle =>
      'Bang-Quellen und Nutzungsdaten verwalten';

  @override
  String get settings_searchHistoryLimitTitle => 'Größe des Suchverlaufs';

  @override
  String get settings_searchHistoryLimitKeywords => 'Verlauf, Einträge';

  @override
  String get settings_searchHistoryLimitSubtitle =>
      'Höchstzahl gespeicherter letzter Suchen';

  @override
  String get settings_searchHistoryLimitSuffix => 'Einträge';

  @override
  String get settings_validationEnterValue => 'Bitte einen Wert eingeben';

  @override
  String get settings_validationEnterValidNumber =>
      'Bitte eine gültige Zahl eingeben';

  @override
  String get settings_validationValueBetween0And100 =>
      'Der Wert muss zwischen 0 und 100 liegen';

  @override
  String get settings_allowClipboardAccessTitle =>
      'Zugriff auf Zwischenablage für Vorschläge erlauben';

  @override
  String get settings_allowClipboardAccessKeywords => 'Zwischenablage';

  @override
  String get settings_allowClipboardAccessSubtitle =>
      'Der Browser kann die Zwischenablage lesen, um URLs vorzuschlagen';

  @override
  String get settings_acceptSuggestionOnSubmitTitle =>
      'Mit Eingabetaste vervollständigen';

  @override
  String get settings_acceptSuggestionOnSubmitKeywords =>
      'Enter, Eingabetaste, Tastatur, Vorschläge';

  @override
  String get settings_acceptSuggestionOnSubmitSubtitle =>
      'Beim Drücken der Eingabetaste den eingeblendeten Vorschlag übernehmen';

  @override
  String get settings_popularSitesAutocompleteTitle =>
      'Beliebte Websites vorschlagen';

  @override
  String get settings_popularSitesAutocompleteKeywords =>
      'beliebte Websites, Domains, Autovervollständigung';

  @override
  String get settings_popularSitesAutocompleteSubtitle =>
      'Eingaben mit bekannten Domains vervollständigen, wenn der Verlauf keinen Treffer hat';

  @override
  String get settings_localIndexEnabledTitle => 'Lokalen Suchindex aktivieren';

  @override
  String get settings_localIndexEnabledKeywords =>
      'Seitentext, Verlauf, Volltextsuche';

  @override
  String get settings_localIndexEnabledSubtitle =>
      'Besuchte Seiten lokal indizieren, damit der Browser ihren Inhalt durchsuchen kann. Besuchsmetadaten bleiben in der Engine; nur der Seitentext wird auf dem Gerät gespeichert.';

  @override
  String get settings_indexPrivateTabsTitle => 'Private Tabs indizieren';

  @override
  String get settings_indexPrivateTabsKeywords => 'inkognito, privat';

  @override
  String get settings_indexPrivateTabsSubtitle =>
      'In privaten Tabs geöffnete Seiten in den lokalen Index aufnehmen. Standardmäßig aus.';

  @override
  String get settings_clearLocalIndexDialogTitle =>
      'Lokalen Suchindex löschen?';

  @override
  String get settings_clearLocalIndexDialogContent =>
      'Dadurch werden alle lokal indizierten Seiteninhalte entfernt. Der Verlauf der Engine (Besuchsmetadaten) ist davon nicht betroffen.';

  @override
  String get settings_localIndexStatsTitle => 'Indizierte Seiten';

  @override
  String get settings_localIndexStatsKeywords => 'Index löschen, Statistik';

  @override
  String settings_localIndexPagesIndexed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Seiten indiziert',
      one: '1 Seite indiziert',
    );
    return '$_temp0';
  }

  @override
  String get settings_searchSectionProvidersTitle => 'Anbieter';

  @override
  String get settings_searchSectionProvidersKeywords => 'Suchmaschinen';

  @override
  String get settings_searchSectionBangShortcutsTitle => 'Bang-Kürzel';

  @override
  String get settings_searchSectionBangShortcutsKeywords => 'Bangs';

  @override
  String get settings_searchSectionHistorySuggestionsTitle =>
      'Verlauf & Vorschläge';

  @override
  String get settings_searchSectionLocalIndexTitle => 'Lokaler Suchindex';

  @override
  String get settings_searchSectionLocalIndexKeywords =>
      'Suche auf dem Gerät, Index';

  @override
  String get settings_indexDefaultSearchProviderSubtitle =>
      'Die Standard-Suchmaschine auswählen';

  @override
  String get settings_indexDefaultAutocompleteProviderSubtitle =>
      'Den Anbieter für Suchvorschläge auswählen';

  @override
  String get settings_indexAcceptSuggestionOnSubmitSubtitle =>
      'Beim Drücken der Eingabetaste den eingeblendeten Vorschlag übernehmen';

  @override
  String get settings_indexPopularSitesAutocompleteSubtitle =>
      'Eingaben mit bekannten Domains vervollständigen';

  @override
  String get settings_indexLocalIndexEnabledSubtitle =>
      'Besuchte Seiten für die Inhaltssuche lokal indizieren';

  @override
  String get settings_indexIndexPrivateTabsSubtitle =>
      'Private Tabs in den lokalen Index aufnehmen';

  @override
  String get settings_indexLocalIndexStatsSubtitle =>
      'Den lokalen Index ansehen und löschen';

  @override
  String get settings_webContentTitle => 'Webinhalte';

  @override
  String get settings_webContentSubtitle =>
      'Textdarstellung, Leseansicht, PDFs und lokale KI-Funktionen.';

  @override
  String get settings_webFontsTitle => 'Web-Schriftarten';

  @override
  String get settings_webFontsKeywords => 'Schriftarten, Fonts';

  @override
  String get settings_webFontsSubtitle =>
      'Websites eigene Schriftarten verwenden lassen';

  @override
  String get settings_automaticFontSizeTitle => 'Automatische Schriftgröße';

  @override
  String get settings_automaticFontSizeKeywords => 'Textgröße, Schriftgröße';

  @override
  String get settings_automaticFontSizeSubtitle =>
      'Schriftgröße automatisch an die Systemeinstellungen anpassen. Deaktivieren, um Skalierungsfaktor und Textvergrößerung manuell zu steuern.';

  @override
  String get settings_fontSizeFactorTitle => 'Skalierungsfaktor der Schrift';

  @override
  String get settings_fontSizeFactorKeywords => 'Zoom, Text, Schriftgröße';

  @override
  String get settings_fontSizeFactorSubtitle =>
      'Textgröße von Webseiten skalieren';

  @override
  String get settings_disabledWhileAutomaticFontSize =>
      'Deaktiviert, solange die automatische Schriftgröße aktiv ist';

  @override
  String get settings_fontInflationTitle => 'Textvergrößerung';

  @override
  String get settings_fontInflationKeywords => 'Lesbarkeit, Font Inflation';

  @override
  String get settings_fontInflationSubtitle =>
      'Text auf Seiten ohne mobiles Viewport-Meta-Tag vergrößern';

  @override
  String get settings_inputAutoZoomTitle => 'Automatischer Zoom bei Eingaben';

  @override
  String get settings_inputAutoZoomKeywords => 'Formulare, Eingabefelder';

  @override
  String get settings_inputAutoZoomSubtitle =>
      'Beim Fokussieren von Textfeldern automatisch hineinzoomen';

  @override
  String get settings_forceUserScalableTitle => 'Zoom auf allen Websites';

  @override
  String get settings_forceUserScalableKeywords =>
      'zoomen, Pinch, Barrierefreiheit';

  @override
  String get settings_forceUserScalableSubtitle =>
      'Zoomen per Fingergeste erlauben, auch auf Websites, die das verhindern';

  @override
  String get settings_pdfViewerTitle => 'Integrierter PDF-Betrachter';

  @override
  String get settings_pdfViewerKeywords => 'pdf';

  @override
  String get settings_pdfViewerSubtitle =>
      'PDF-Dateien direkt im Browser öffnen, ohne sie herunterzuladen';

  @override
  String get settings_enableReaderModeTitle => 'Leseansicht aktivieren';

  @override
  String get settings_enableReaderModeKeywords =>
      'Leseansicht, Lesemodus, Lesbarkeit';

  @override
  String get settings_enableReaderModeSubtitle =>
      'Fügt der Browserleiste ein optionales Werkzeug hinzu, das Webseiten vereinfacht, indem es Werbung, Seitenleisten und andere unwesentliche Elemente entfernt.';

  @override
  String get settings_enforceReaderModeTitle => 'Leseansicht erzwingen';

  @override
  String get settings_enforceReaderModeKeywords => 'Leseansicht, Lesemodus';

  @override
  String get settings_enforceReaderModeSubtitle =>
      'Die Lesbarkeitsbewertung einer Website ignorieren und die Leseansicht immer anbieten, auch auf Websites, die sie womöglich nicht unterstützen.';

  @override
  String get settings_onDeviceAiTitle => 'KI auf dem Gerät';

  @override
  String get settings_onDeviceAiKeywords => 'lokale KI, KI, Vorschläge';

  @override
  String get settings_onDeviceAiSubtitle =>
      'Funktionen auf dem Gerät, etwa Vorschläge für Container und deren Namen passend zu den offenen Tabs';

  @override
  String get settings_webContentSectionDisplayTitle => 'Darstellung';

  @override
  String get settings_webContentSectionContentFeaturesTitle =>
      'Inhaltsfunktionen';

  @override
  String get settings_indexAutomaticFontSizeSubtitle =>
      'Schriftgröße an die Systemeinstellungen anpassen';

  @override
  String get settings_indexFontInflationSubtitle =>
      'Text auf Seiten ohne mobilen Viewport vergrößern';

  @override
  String get settings_indexInputAutoZoomSubtitle =>
      'Beim Fokussieren von Textfeldern automatisch zoomen';

  @override
  String get settings_indexPdfViewerSubtitle =>
      'PDF-Dateien direkt im Browser öffnen';

  @override
  String get settings_indexEnableReaderModeSubtitle =>
      'Seiten für bessere Lesbarkeit extrahieren und vereinfachen';

  @override
  String get settings_indexEnforceReaderModeSubtitle =>
      'Leseansicht immer anbieten';

  @override
  String get settings_indexOnDeviceAiSubtitle =>
      'Lokale KI-Funktionen, darunter Themen- und Tab-Vorschläge';

  @override
  String get settings_ublockListsTitle => 'uBlock-Filterlisten';

  @override
  String get settings_ublockListsSearchHint =>
      'Listen, Gruppen und externe URLs durchsuchen';

  @override
  String get settings_ublockSectionManagement => 'Verwaltung';

  @override
  String get settings_ublockSectionQuickActions => 'Schnellaktionen';

  @override
  String get settings_ublockSectionFilterLists => 'Filterlisten';

  @override
  String get settings_ublockSectionExternalLists => 'Externe Listen';

  @override
  String get settings_actionApply => 'Anwenden';

  @override
  String get settings_ublockResetDialogTitle => 'Auf Standard zurücksetzen?';

  @override
  String get settings_ublockResetDialogMessage =>
      'Dadurch wird die Standardkonfiguration der Filterlisten von uBlock Origin wiederhergestellt und alle hinzugefügten externen Listen werden entfernt.';

  @override
  String get settings_ublockApplyHardeningsDialogTitle =>
      'WebLibre-Härtungen anwenden?';

  @override
  String get settings_ublockApplyHardeningsDialogMessage =>
      'Dadurch wird eine kuratierte Auswahl zusätzlicher Filterlisten aktiviert und eine Liste legitimer URL-Kürzer als externe Liste hinzugefügt.';

  @override
  String get settings_ublockInfoBannerMessage =>
      'Änderungen an den Filterlisten von uBlock Origin werden erst nach einem Neustart der App wirksam. Wegen Zwischenspeicherung können manche Änderungen einige Minuten und einen weiteren Neustart benötigen, bis sie vollständig greifen.';

  @override
  String settings_ublockLoadFailed(String error) {
    return 'Filterlisten konnten nicht geladen werden: $error';
  }

  @override
  String get settings_ublockQuickResetTitle => 'Auf Standard zurücksetzen';

  @override
  String get settings_ublockQuickResetSubtitle =>
      'Die Standardkonfiguration der Filterlisten von uBlock Origin wiederherstellen.';

  @override
  String get settings_ublockQuickApplyHardeningsTitle =>
      'WebLibre-Härtungen anwenden';

  @override
  String get settings_ublockQuickApplyHardeningsSubtitle =>
      'Eine kuratierte Auswahl zusätzlicher Filterlisten aktivieren.';

  @override
  String get settings_ublockManageTitle => 'Mit WebLibre verwalten';

  @override
  String get settings_ublockManageSubtitle =>
      'WebLibre legt beim nächsten Browserstart fest, welche Filterlisten uBlock Origin verwendet.';

  @override
  String get settings_ublockManageHint =>
      'Die Verwaltung beginnt mit den gängigen Basislisten von uBO und behält „Meine Filter“ bei.';

  @override
  String get settings_ublockAutoSelectTitle => 'Sprachen automatisch auswählen';

  @override
  String get settings_ublockAutoSelectSubtitle =>
      'Regionale Filterlisten passend zu den Gerätesprachen aktivieren.';

  @override
  String get settings_ublockAutoSelectedTooltip =>
      'Automatisch für die Gerätesprache ausgewählt';

  @override
  String get settings_ublockDefaultOnTooltip => 'Standardmäßig aktiv';

  @override
  String get settings_ublockVisitSupportTooltip => 'Support-Seite öffnen';

  @override
  String get settings_ublockExternalListsHint =>
      'Rohe URLs werden als externe Listen an uBlock Origin übergeben. Beschreibungen werden nur hier in WebLibre angezeigt.';

  @override
  String get settings_ublockNoExternalLists =>
      'Keine externen Listen eingerichtet.';

  @override
  String settings_ublockNoExternalListsMatch(String query) {
    return 'Keine externen Listen passen zu „$query“.';
  }

  @override
  String get settings_ublockAddExternalListButton => 'Externe Liste hinzufügen';

  @override
  String get settings_ublockEditListDialogTitle =>
      'Externe Filterliste bearbeiten';

  @override
  String get settings_ublockAddListDialogTitle =>
      'Externe Filterliste hinzufügen';

  @override
  String get settings_ublockListUrlLabel => 'Listen-URL';

  @override
  String get settings_ublockListUrlAlreadyAdded => 'Bereits hinzugefügt';

  @override
  String get settings_ublockDescriptionLabel => 'Beschreibung (optional)';

  @override
  String get settings_ublockDescriptionHint => 'z. B. Störelemente – meinAutor';

  @override
  String get settings_ublockGroupDefault => 'Standard';

  @override
  String get settings_ublockGroupAds => 'Werbung';

  @override
  String get settings_ublockGroupPrivacy => 'Datenschutz';

  @override
  String get settings_ublockGroupMalware => 'Schadsoftware';

  @override
  String get settings_ublockGroupAnnoyances => 'Störelemente';

  @override
  String get settings_ublockGroupMultipurpose => 'Mehrzweck';

  @override
  String get settings_ublockGroupRegions => 'Regionen';

  @override
  String get settings_categoryGeneralTitle => 'Allgemein';

  @override
  String get settings_categoryGeneralKeywords =>
      'Design, Zoom der Oberfläche, Standardbrowser';

  @override
  String get settings_categoryGeneralSubtitle => 'Erscheinungsbild, Downloads';

  @override
  String get settings_categoryBrowsingTitle => 'Surfen';

  @override
  String get settings_categoryBrowsingKeywords =>
      'Tabs, Small Web, URL-Bereinigung, Kurzlinks';

  @override
  String get settings_categoryBrowsingSubtitle =>
      'Tabs, Navigation, externe Links';

  @override
  String get settings_categoryHomeNewTabTitle => 'Startseite & neuer Tab';

  @override
  String get settings_categoryHomeNewTabKeywords =>
      'Startseite, neuer Tab, Bereiche, Verknüpfungen, Top-Seiten, Zitat, Hintergrundbild, Hintergrund';

  @override
  String get settings_categoryHomeNewTabSubtitle =>
      'Was die Startseite und neue Tabs anzeigen';

  @override
  String get settings_categoryGesturesTitle => 'Gesten';

  @override
  String get settings_categoryGesturesKeywords =>
      'Geste, wischen, Strich, Tableiste, langes Drücken, zusammenziehen';

  @override
  String get settings_categoryGesturesSubtitle =>
      'Wischgesten auf der Tableiste und auf Tabs, gezeichnete Gesten';

  @override
  String get settings_categoryKeyboardShortcutsTitle => 'Tastenkürzel';

  @override
  String get settings_categoryKeyboardShortcutsKeywords =>
      'Tastatur, Tastenkürzel, Hotkey, Tastenbelegung, Shortcut';

  @override
  String get settings_categoryKeyboardShortcutsSubtitle =>
      'Tasten einer Hardwaretastatur für Browseraktionen';

  @override
  String get settings_categoryToolbarLayoutTitle => 'Symbolleiste & Layout';

  @override
  String get settings_categoryToolbarLayoutKeywords =>
      'kontextabhängige Symbolleiste, schneller Tab-Wechsler';

  @override
  String get settings_categoryToolbarLayoutSubtitle =>
      'Tableiste, Symbolleiste, Schnellwechsler, Tab-Übersicht';

  @override
  String get settings_categoryWebContentTitle => 'Webinhalte';

  @override
  String get settings_categoryWebContentKeywords =>
      'Leseansicht, pdf, Schriftarten';

  @override
  String get settings_categoryWebContentSubtitle =>
      'Seitendarstellung, PDF, Leseansicht, KI';

  @override
  String get settings_categoryNotificationsTitle => 'Benachrichtigungen';

  @override
  String get settings_categoryNotificationsKeywords =>
      'Push, unifiedpush, ntfy, Distributor, Mitteilungen';

  @override
  String get settings_categoryNotificationsSubtitle =>
      'Web-Push-Zustellung, Distributor, Website-Abonnements';

  @override
  String get settings_categorySearchTitle => 'Suche';

  @override
  String get settings_categorySearchKeywords =>
      'Bangs, Vorschläge, lokaler Suchindex';

  @override
  String get settings_categorySearchSubtitle => 'Anbieter, Bangs, Suchverlauf';

  @override
  String get settings_categoryPrivacySecurityTitle =>
      'Datenschutz & Sicherheit';

  @override
  String get settings_categoryPrivacySecurityKeywords =>
      'Fingerprinting, https, doh, Safe Browsing, Netzwerkschutz, Privatsphäre';

  @override
  String get settings_categoryPrivacySecuritySubtitle =>
      'Tracking-Schutz, Löschen von Daten';

  @override
  String get settings_categoryProxyTitle => 'Proxy';

  @override
  String get settings_categoryProxyKeywords =>
      'Proxy, sing-box, socks, vpn, wireguard, Routing, tor, Container';

  @override
  String get settings_categoryProxySubtitle => 'Verbindungen und Routing';

  @override
  String get settings_categoryExtensionsTitle => 'Erweiterungen';

  @override
  String get settings_categoryExtensionsKeywords =>
      'Add-ons, nicht signierte Erweiterungen';

  @override
  String get settings_categoryExtensionsSubtitle =>
      'Erweiterungen installieren und ihre Quellen verwalten';

  @override
  String get settings_categoryAccountTitle => 'WebLibre-Konto';

  @override
  String get settings_categoryAccountKeywords => 'Konto, Abonnement';

  @override
  String get settings_categoryAccountSubtitle =>
      'Anmelden, Einstellungen synchronisieren';

  @override
  String get settings_categorySyncTitle => 'Firefox Sync';

  @override
  String get settings_categorySyncKeywords => 'koppeln, Gerätename, Datentypen';

  @override
  String get settings_categorySyncSubtitle =>
      'Konto, jetzt synchronisieren, Auswahl der Datentypen';

  @override
  String get settings_categoryAdvancedTitle => 'Erweitert';

  @override
  String get settings_categoryAdvancedKeywords =>
      'experimentell, Fehlerprotokolle, javascript';

  @override
  String get settings_categoryAdvancedSubtitle =>
      'JavaScript, User-Agent, Fehlersuche';

  @override
  String get settings_categoryGroupBrowserTitle => 'Browser';

  @override
  String get settings_categoryGroupServicesAdvancedTitle =>
      'Dienste & erweiterte Einstellungen';

  @override
  String get settings_privacySectionTrackingProtectionTitle =>
      'Tracking-Schutz';

  @override
  String get settings_privacySectionTrackingProtectionKeywords =>
      'Datenschutz, Privatsphäre';

  @override
  String get settings_indexEnhancedTrackingProtectionSubtitle =>
      'Festlegen, wie konsequent Tracker blockiert werden';

  @override
  String get settings_indexContentBlockingDatabaseSubtitle =>
      'GeckoView-Blocklisten für ETP-Kategorien verwenden';

  @override
  String get settings_indexBounceTrackingProtectionSubtitle =>
      'Von Weiterleitungs-Trackern hinterlassene Tracking-Daten entfernen';

  @override
  String get settings_indexQueryParameterStrippingSubtitle =>
      'Tracking-Parameter aus URLs entfernen';

  @override
  String get settings_privacySectionFingerprintingTitle => 'Fingerprinting';

  @override
  String get settings_indexBrowserLanguagesSubtitle =>
      'Festlegen, welche Sprachen Websites sehen können';

  @override
  String get settings_privacySectionConnectionSecurityTitle =>
      'Verbindungssicherheit';

  @override
  String get settings_indexHttpsOnlyModeSubtitle =>
      'HTTPS bevorzugen und unsichere Verbindungen blockieren';

  @override
  String get settings_indexDnsOverHttpsTitle => 'DNS über HTTPS';

  @override
  String get settings_indexDnsOverHttpsKeywords => 'doh, verschlüsseltes DNS';

  @override
  String get settings_indexDnsOverHttpsSubtitle => 'DNS-Abfragen verschlüsseln';

  @override
  String get settings_privacySectionNetworkProtectionTitle => 'Netzwerkschutz';

  @override
  String get settings_indexLnaBlockingSubtitle =>
      'Anfragen an Geräte und Dienste im lokalen Netzwerk blockieren';

  @override
  String get settings_indexLnaBlockTrackersSubtitle =>
      'Tracker-ähnliche Anfragen ins lokale Netzwerk blockieren';

  @override
  String get settings_privacySectionSignalsModesTitle =>
      'Datenschutzsignale & -modi';

  @override
  String get settings_indexScreenshotProtectionSubtitle =>
      'Verhindern, dass App-Inhalte auf Screenshots erscheinen';

  @override
  String get settings_indexAllowPrivateTabScreenshotsSubtitle =>
      'Dem System Aufnahmen privater Tabs erlauben';

  @override
  String get settings_indexGlobalPrivacyControlSubtitle =>
      'Websites ein Datenschutzsignal senden';

  @override
  String get settings_privacySectionAppOpeningProtectionTitle =>
      'Schutz vor Öffnen durch Apps';

  @override
  String get settings_indexAppOpeningProtectionSubtitle =>
      'Festlegen, welche Apps WebLibre direkt starten dürfen';

  @override
  String get settings_privacySectionDataManagementTitle => 'Datenverwaltung';

  @override
  String get settings_indexDeleteBrowsingDataSubtitle =>
      'Verlauf, Cookies und andere Browserdaten löschen';

  @override
  String get settings_indexAutoClearHistorySubtitle =>
      'Verlauf nach einem gewählten Zeitraum automatisch löschen';

  @override
  String get settings_indexAutoClearUnassignedTabsSubtitle =>
      'Tabs, die keinem Container zugeordnet sind, automatisch schließen';

  @override
  String get settings_privacySectionSafeBrowsingTitle => 'Google Safe Browsing';

  @override
  String get settings_indexSafeBrowsingMalwareSubtitle =>
      'Vor Schadsoftware und schädlichen Downloads warnen';

  @override
  String get settings_indexSafeBrowsingPhishingSubtitle =>
      'Vor betrügerischen Websites und Anmeldeseiten warnen';

  @override
  String get settings_privacySectionAdvancedSecurityTitle =>
      'Erweiterte Sicherheit';

  @override
  String get settings_indexWebEngineHardeningSubtitle =>
      'Verhalten und Standardeinstellungen der Browser-Engine härten';

  @override
  String get settings_indexFissionEnabledSubtitle =>
      'Stärkere Isolierung zwischen Websites verwenden';

  @override
  String get settings_indexExtensionsWebAPIEnabledSubtitle =>
      'Erweiterungen erlauben, Web-APIs für Seiten bereitzustellen';

  @override
  String get settings_proxySectionTitle => 'Proxy';

  @override
  String get settings_indexProxyLogsSubtitle =>
      'Das Proxy-Protokoll lesen und festlegen, wie viel es aufzeichnet';

  @override
  String get settings_saveAndUse => 'Speichern und verwenden';

  @override
  String get settings_replace => 'Ersetzen';

  @override
  String get settings_later => 'Später';

  @override
  String get settings_restartNow => 'Jetzt neu starten';

  @override
  String get settings_sync => 'Synchronisieren';

  @override
  String get settings_chooseSearchProvider => 'Suchanbieter auswählen';

  @override
  String get settings_entriesLabel => 'Einträge';

  @override
  String get settings_lastSyncLabel => 'Letzte Synchronisierung';

  @override
  String get settings_notAvailable => 'k. A.';

  @override
  String get settings_protectionLevelTitle => 'Schutzstufe';

  @override
  String get settings_protectionLevelDescription =>
      'DNS über HTTPS sendet Anfragen zu Domainnamen über eine verschlüsselte Verbindung. Das schützt sie und erschwert es anderen zu sehen, welche Websites als Nächstes besucht werden.';

  @override
  String get settings_defaultProtectionTitle => 'Standardschutz';

  @override
  String get settings_defaultProtectionSubtitle =>
      'DoH nur, wenn das Standard-DNS ausfällt';

  @override
  String get settings_increasedProtectionTitle => 'Erhöhter Schutz';

  @override
  String get settings_increasedProtectionSubtitle =>
      'DoH bevorzugt, Standard-DNS als Ausweichlösung';

  @override
  String get settings_maxProtectionTitle => 'Maximaler Schutz';

  @override
  String get settings_maxProtectionSubtitle => 'Nur DoH, keine Ausweichlösung';

  @override
  String get settings_protectionOffTitle => 'Aus';

  @override
  String get settings_protectionOffSubtitle =>
      'Den Standard-DNS-Resolver verwenden';

  @override
  String get settings_dohProviderTitle => 'DoH-Anbieter';

  @override
  String get settings_yourResolvers => 'Eigene Resolver';

  @override
  String get settings_addCustomResolver => 'Eigenen Resolver hinzufügen';

  @override
  String get settings_editCustomResolverTitle => 'Eigenen Resolver bearbeiten';

  @override
  String get settings_resolverUrlLabel => 'Resolver-URL';

  @override
  String get settings_alreadyBuiltInProvider =>
      'Bereits als integrierter Anbieter verfügbar';

  @override
  String get settings_alreadyAdded => 'Bereits hinzugefügt';

  @override
  String get settings_resolverNameLabel => 'Name (optional)';

  @override
  String get settings_resolverNameHint => 'z. B. dnsforge (Werbeblocker)';

  @override
  String get settings_searchHint => 'Einstellungen durchsuchen';

  @override
  String get settings_noSettingsAvailable => 'Keine Einstellungen verfügbar.';

  @override
  String settings_noSettingsMatch(String query) {
    return 'Keine Einstellungen passen zu „$query“.';
  }

  @override
  String get settings_stringListEditorEmpty => 'Noch nichts hinzugefügt.';

  @override
  String get settings_customizeMenu => 'Menü anpassen';

  @override
  String get settings_customizeMenuKeywords => 'Bereiche, Zeilen, anordnen';

  @override
  String get settings_customizeMenuSubtitle =>
      'Bereiche und Zeilen des Drei-Punkte-Menüs auswählen und anordnen';

  @override
  String get settings_tabBarPositionTitle => 'Position der Tableiste';

  @override
  String get settings_tabBarPositionKeywords => 'oben, unten';

  @override
  String settings_currentlyResolvesTo(String text, String value) {
    return '$text (derzeit: $value)';
  }

  @override
  String get settings_tabBarPositionAutoLabel => 'Automatisch';

  @override
  String get settings_tabBarPositionTopLabel => 'Oben';

  @override
  String get settings_tabBarPositionBottomLabel => 'Unten';

  @override
  String get settings_tabBarPositionLeftLabel => 'Links';

  @override
  String get settings_tabBarPositionRightLabel => 'Rechts';

  @override
  String get settings_tabBarPositionAutoDescription =>
      'Seitenleiste auf großen Bildschirmen, untere Leiste auf Smartphones';

  @override
  String get settings_tabBarPositionTopDescription =>
      'Dauerhafte Tableiste ohne automatisches Ausblenden';

  @override
  String get settings_tabBarPositionBottomDescription =>
      'Tableiste mit automatischem Ausblenden';

  @override
  String get settings_tabBarPositionLeftDescription =>
      'Senkrechte Seitenleiste, zum Ausblenden wischen';

  @override
  String get settings_tabBarPositionRightDescription =>
      'Senkrechte Seitenleiste, zum Ausblenden wischen';

  @override
  String get settings_tabBarStyleTitle => 'Stil der Tableiste';

  @override
  String get settings_tabBarStyleKeywords => 'Layout, kompakt';

  @override
  String get settings_withTitleOption => 'Mit Titel';

  @override
  String get settings_withTitleDescription => 'Zeigt Seitentitel und URL-Pfad';

  @override
  String get settings_compactOption => 'Kompakt';

  @override
  String get settings_compactDescription =>
      'Zentrierte URL-Pille ohne Seitentitel';

  @override
  String get settings_showContextualToolbarTitle =>
      'Kontextabhängige Symbolleiste anzeigen';

  @override
  String get settings_showContextualToolbarKeywords => 'untere Symbolleiste';

  @override
  String get settings_showContextualToolbarSubtitle =>
      'Eine zusätzliche untere Symbolleiste für Navigation und Aktionen anzeigen';

  @override
  String get settings_customizeToolbarButtons =>
      'Schaltflächen der Symbolleiste anpassen';

  @override
  String get settings_customizeToolbarButtonsKeywords =>
      'Schaltflächen, Buttons';

  @override
  String get settings_customizeSwitcherButtons =>
      'Schaltflächen des Wechslers anpassen';

  @override
  String get settings_customizeSwitcherButtonsKeywords =>
      'Schaltflächen, neuer Tab, Aktionen, am Ende';

  @override
  String get settings_customizeSwitcherButtonsSubtitle =>
      'Am Ende der Wechslerleiste angeheftete Aktionsschaltflächen (unabhängig von der kontextabhängigen Symbolleiste)';

  @override
  String get settings_tabStackingTitle => 'Tab-Anordnung';

  @override
  String get settings_tabStackingKeywords =>
      'letzte Tabs, zuletzt verwendet, Container-Tabs, Akkordeon, zweistufig, Zeilen, Stapeln, deaktiviert';

  @override
  String get settings_tabStackingSubtitle =>
      'Wie die Leiste des schnellen Tab-Wechslers ihre Tabs anordnet';

  @override
  String get settings_recentlyUsedTabsOption => 'Zuletzt verwendet';

  @override
  String get settings_recentlyUsedTabsDescription =>
      'Zuletzt verwendete Tabs aus allen Containern';

  @override
  String get settings_containerTabsOption => 'Container-Tabs';

  @override
  String get settings_containerTabsDescription =>
      'Sortierte Tabs des ausgewählten Containers';

  @override
  String get settings_accordionOption => 'Akkordeon';

  @override
  String get settings_accordionDescription =>
      'Alle Container als Chips, die Tabs des ausgewählten Containers direkt ausgeklappt';

  @override
  String get settings_twoRowsOption => 'Zwei Zeilen';

  @override
  String get settings_twoRowsDescription =>
      'Oben Tabs des ausgewählten Containers, darunter zuletzt verwendete Tabs';

  @override
  String get settings_disabledOption => 'Deaktiviert';

  @override
  String get settings_disabledDescription =>
      'Die Leiste des schnellen Tab-Wechslers ausblenden';

  @override
  String get settings_closeButtonsTitle =>
      'Schließen-Schaltflächen auf Tab-Chips';

  @override
  String get settings_closeButtonsKeywords =>
      'schließen, X-Schaltfläche, aktiver Tab';

  @override
  String get settings_closeButtonsSubtitle =>
      'Welche Chips des Wechslers eine Schließen-Schaltfläche zeigen';

  @override
  String get settings_activeTabOnlyOption => 'Nur aktiver Tab';

  @override
  String get settings_activeTabOnlyDescription =>
      'Nur der Chip des gerade geöffneten Tabs';

  @override
  String get settings_allTabsOption => 'Alle Tabs';

  @override
  String get settings_allTabsDescription => 'Jeder Chip in der Leiste';

  @override
  String get settings_neverOption => 'Nie';

  @override
  String get settings_neverCloseDescription =>
      'Keine Schließen-Schaltflächen; Tabs über das Menü bei langem Drücken oder durch Wischen auf der Leiste schließen';

  @override
  String get settings_titleWidthTitle =>
      'Titelbreite im schnellen Tab-Wechsler';

  @override
  String get settings_titleWidthKeywords => 'Breite, Titel, Chip, Länge';

  @override
  String get settings_titleWidthSubtitle =>
      'Maximale Breite der Tab-Titel auf den Chips des Wechslers';

  @override
  String get settings_historyFallbackTitle =>
      'Verlauf als Ausweichlösung im schnellen Tab-Wechsler';

  @override
  String get settings_historyFallbackKeywords => 'Vorschläge, Verlauf';

  @override
  String get settings_historyFallbackSubtitle =>
      'Vorschläge aus dem Browserverlauf verwenden, wenn keine Tab-Chips verfügbar sind';

  @override
  String get settings_showTitlesTitle =>
      'Titel im schnellen Tab-Wechsler anzeigen';

  @override
  String get settings_showTitlesKeywords => 'Seitentitel';

  @override
  String get settings_showTitlesSubtitle =>
      'Tab-Titel neben den Symbolen in der Leiste des schnellen Tab-Wechslers anzeigen';

  @override
  String get settings_hierarchyDepthTitle =>
      'Hierarchietiefe im schnellen Tab-Wechsler';

  @override
  String get settings_hierarchyDepthKeywords =>
      'Hierarchie, Verschachtelung, Tiefe, Baum, Pfeile';

  @override
  String get settings_hierarchyDepthSubtitle =>
      'Wie viele Verschachtelungspfeile die Chips des Wechslers zeigen, bevor sie zu einem Zähler zusammengefasst werden (0 blendet die Anzeige aus)';

  @override
  String settings_hierarchyGlyphsLabel(int glyphs) {
    String _temp0 = intl.Intl.pluralLogic(
      glyphs,
      locale: localeName,
      other: '$glyphs Ebenen',
      one: '1 Ebene',
      zero: 'Aus',
    );
    return '$_temp0';
  }

  @override
  String get settings_autoHideTabBarTitle => 'Tableiste automatisch ausblenden';

  @override
  String get settings_autoHideTabBarKeywords => 'scrollen, ausblenden';

  @override
  String get settings_autoHideTabBarSubtitle =>
      'Tableiste beim Scrollen ausblenden';

  @override
  String get settings_autoHideSidePanelTitle =>
      'Seitenleiste automatisch ausblenden';

  @override
  String get settings_autoHideSidePanelKeywords =>
      'Maus, Mauszeiger, Hover, Seitenleiste, Rail';

  @override
  String get settings_autoHideSidePanelSubtitle =>
      'Die linke oder rechte Tableiste aus dem Weg halten und einblenden, sobald die Maus diesen Rand erreicht. Das funktioniert nur bei Verwendung einer Maus oder eines Trackpads; eine Berührung des Bildschirms setzt die Leiste wieder neben die Seite.';

  @override
  String get settings_bottomSheetTabViewTitle =>
      'Tab-Übersicht von unten einblenden';

  @override
  String get settings_bottomSheetTabViewKeywords => 'Bottom Sheet, Leiste';

  @override
  String get settings_bottomSheetTabViewSubtitle =>
      'Tabs in einem von unten eingeblendeten Bereich statt im Vollbild anzeigen';

  @override
  String get settings_longPressUrlCopyTitle =>
      'URL durch langes Drücken kopieren';

  @override
  String get settings_longPressUrlCopyKeywords =>
      'URL kopieren, Adresse kopieren';

  @override
  String get settings_longPressUrlCopySubtitle =>
      'Beim langen Drücken auf die Adressleiste die URL der Seite in die Zwischenablage kopieren';

  @override
  String get settings_showFaviconsTitle =>
      'Favicons in der Listenansicht anzeigen';

  @override
  String get settings_showFaviconsKeywords => 'Symbole, Icons';

  @override
  String get settings_showFaviconsSubtitle =>
      'In der Tab-Liste Website-Symbole statt Seitenvorschauen anzeigen';

  @override
  String get settings_previewPageContent => 'Seiteninhalt';

  @override
  String get settings_previewPageTitle => 'WebLibre-Vorschau';

  @override
  String get settings_previewTabNews => 'Nachrichten';

  @override
  String get settings_previewTabPrivate => 'Privat';

  @override
  String get settings_previewTabBank => 'Bank';

  @override
  String get settings_previewTabSearch => 'Suche';

  @override
  String get settings_livePreviewTitle => 'Live-Vorschau';

  @override
  String get settings_livePreviewSubtitle =>
      'Spiegelt die aktuellen Einstellungen für Symbolleiste und Layout wider';

  @override
  String get settings_deleteAllExceptionsTitle => 'Alle Ausnahmen löschen?';

  @override
  String get settings_deleteAllExceptionsContent =>
      'Dadurch wird der Tracking-Schutz für alle Ausnahme-Websites wieder aktiviert.';

  @override
  String get settings_entryCopied => 'Eintrag kopiert';

  @override
  String get settings_messageLabel => 'Meldung:';

  @override
  String get settings_errorLabel => 'Fehler:';

  @override
  String get settings_stackTraceLabel => 'Stacktrace:';

  @override
  String get settings_importSettingsTitle => 'Einstellungen importieren';

  @override
  String get settings_importSettingsDescription =>
      'Die ausgewählten Bereiche ersetzen den aktuellen Stand dieses Profils. Alles, was nicht angehakt ist, bleibt unverändert.';

  @override
  String settings_unreadableSections(int count, String sections) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Bereiche dieser Datei ($sections) können von dieser WebLibre-Version nicht gelesen werden und werden übersprungen.',
      one:
          '1 Bereich dieser Datei ($sections) kann von dieser WebLibre-Version nicht gelesen werden und wird übersprungen.',
    );
    return '$_temp0';
  }

  @override
  String get settings_exportedLabel => 'Exportiert';

  @override
  String get settings_appVersionLabel => 'App-Version';

  @override
  String get settings_credentialsNotCarried =>
      'Exporte enthalten weder gespeicherte Zugangsdaten noch das Hintergrundbild. Dieses Gerät behält seine eigenen.';

  @override
  String get settings_geckoPrefsRestartNote =>
      'Manche Engine-Einstellungen werden erst nach einem Neustart des Browsers wirksam.';

  @override
  String get settings_userAgentChangedTitle => 'User-Agent geändert';

  @override
  String get settings_userAgentChangedContent =>
      'Der Browser muss neu starten, damit der neue User-Agent wirksam wird.';

  @override
  String get settings_tabBarSectionTitle => 'Tableiste';

  @override
  String get settings_contextualToolbarSectionTitle =>
      'Kontextabhängige Symbolleiste';

  @override
  String get settings_quickTabSwitcherSectionTitle => 'Schneller Tab-Wechsler';

  @override
  String get settings_tabViewSectionTitle => 'Tab-Übersicht';

  @override
  String get settings_menuSectionTitle => 'Menü';

  @override
  String get settings_menuSectionKeywords => 'Drei-Punkte-Menü, Überlaufmenü';

  @override
  String get settings_indexTabBarPositionSubtitle =>
      'Festlegen, ob die Tableiste oben, unten oder seitlich sitzt';

  @override
  String get settings_indexTabBarStyleSubtitle =>
      'Zwischen Layout mit Titel und kompaktem Layout wählen';

  @override
  String get settings_indexAutoHideTabBarSubtitle =>
      'Die Tableiste beim Scrollen ausblenden';

  @override
  String get settings_indexAutoHideSidePanelSubtitle =>
      'Die Seitenleiste einblenden, wenn die Maus ihren Rand erreicht';

  @override
  String get settings_indexLongPressUrlCopySubtitle =>
      'Die aktuelle URL aus der Tableiste kopieren';

  @override
  String get settings_indexShowContextualToolbarSubtitle =>
      'Eine zusätzliche Symbolleiste für Navigation und Aktionen anzeigen';

  @override
  String get settings_indexCustomizeToolbarButtonsSubtitle =>
      'Festlegen, welche Aktionen in der kontextabhängigen Symbolleiste erscheinen';

  @override
  String get settings_indexTabStackingSubtitle =>
      'Festlegen, wie die Leiste des schnellen Tab-Wechslers Tabs anordnet';

  @override
  String get settings_indexCustomizeSwitcherButtonsSubtitle =>
      'Festlegen, welche Aktionsschaltflächen am Ende der Leiste erscheinen';

  @override
  String get settings_indexHistoryFallbackSubtitle =>
      'Verlaufsvorschläge verwenden, wenn keine passenden Tabs vorhanden sind';

  @override
  String get settings_indexShowTitlesSubtitle =>
      'Seitentitel in der Liste des Wechslers anzeigen';

  @override
  String get settings_indexHierarchyDepthSubtitle =>
      'Wie viele Verschachtelungspfeile die Chips des Wechslers zeigen';

  @override
  String get settings_indexBottomSheetTabViewSubtitle =>
      'Die Tab-Übersicht von unten einblenden';

  @override
  String get settings_indexShowFaviconsSubtitle =>
      'Website-Symbole in der Tab-Liste anzeigen';

  @override
  String get smallWeb_sheetTitle => 'Small Web';

  @override
  String get smallWeb_refineCategoryTitle => 'Kategorie eingrenzen';

  @override
  String get smallWeb_allCategoriesChip => 'Alle';

  @override
  String smallWeb_searchingModeTitle(String mode) {
    return 'Suche in $mode';
  }

  @override
  String get smallWeb_discoverButtonLabel => 'Entdecken';

  @override
  String get smallWeb_browseConsolesButtonLabel => 'Konsolen durchsuchen';

  @override
  String get smallWeb_unavailableTitle => 'Small Web nicht verfügbar';

  @override
  String get smallWeb_noConsoleSelectedMessage => 'Keine Konsole ausgewählt';

  @override
  String smallWeb_consoleStats(int linkedConsoles, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      linkedConsoles,
      locale: localeName,
      other: '$linkedConsoles verlinkte Konsolen',
      one: '1 verlinkte Konsole',
    );
    String _temp1 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '$pages Seiten',
      one: '1 Seite',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get smallWeb_modeWebLabel => 'Web';

  @override
  String get smallWeb_modeAppreciatedLabel => 'Beliebt';

  @override
  String get smallWeb_modeVideosLabel => 'Videos';

  @override
  String get smallWeb_modeCodeLabel => 'Code';

  @override
  String get smallWeb_modeComicsLabel => 'Comics';

  @override
  String get smallWeb_modeDescriptionAppreciated =>
      'Sorgfältig kuratierte, von der Small-Web-Community geschätzte Links entdecken.';

  @override
  String get smallWeb_modeDescriptionVideos =>
      'Videoinhalte unabhängiger Kreativer aus dem Small Web entdecken.';

  @override
  String get smallWeb_modeDescriptionCode =>
      'Code-Schnipsel, Repositorys und technische Artikel von persönlichen Websites finden.';

  @override
  String get smallWeb_modeDescriptionComics =>
      'Indie-Comics und Webgrafiken unabhängiger Illustratorinnen und Illustratoren erkunden.';

  @override
  String get smallWeb_sourceKagiLabel => 'Kagi';

  @override
  String get smallWeb_sourceKagiDescription => 'Small Web von Kagi Search';

  @override
  String get smallWeb_sourceWanderLabel => 'Wander';

  @override
  String get smallWeb_sourceWanderDescription => 'Webring aus Konsolen';

  @override
  String get smallWeb_noNewItemsFoundMessage =>
      'Keine neuen Einträge gefunden. Einen anderen Modus oder eine andere Kategorie versuchen.';

  @override
  String get smallWeb_discoveryFailedMessage =>
      'Entdecken fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String smallWeb_sessionErrorWithDetails(String error) {
    return 'Small-Web-Fehler: $error';
  }

  @override
  String get smallWeb_kagiTitle => 'Kagi Small Web';

  @override
  String get smallWeb_kagiAttributionLine =>
      'Von Kagi Search – Open Source unter der MIT-Lizenz.';

  @override
  String get smallWeb_kagiBlogPostAction => 'Blogbeitrag';

  @override
  String get smallWeb_kagiGithubAction => 'GitHub';

  @override
  String get smallWeb_kagiDescriptionWeb =>
      'Kagi Small Web zeigt aktuelle Beiträge von persönlichen Websites und Blogs einzelner Autorinnen und Autoren aus dem Small Web.';

  @override
  String get smallWeb_kagiDescriptionAppreciated =>
      'Dieser Modus von Kagi Small Web hebt geschätzte Beiträge aus dem Small Web hervor, kuratiert vom Open-Source-Projekt.';

  @override
  String get smallWeb_kagiDescriptionVideos =>
      'Dieser Modus von Kagi Small Web konzentriert sich auf Videobeiträge kleinerer unabhängiger Kreativer und kuratierte Startkanäle.';

  @override
  String get smallWeb_kagiDescriptionCode =>
      'Dieser Modus von Kagi Small Web konzentriert sich auf Beiträge rund um Code von persönlichen Websites und anderen Small-Web-Quellen.';

  @override
  String get smallWeb_kagiDescriptionComics =>
      'Dieser Modus von Kagi Small Web konzentriert sich auf Comics und illustrierte Beiträge, die über das Small-Web-Projekt gefunden werden.';

  @override
  String get smallWeb_wanderTitle => 'Wander';

  @override
  String get smallWeb_wanderDescription =>
      'Wander ist ein Netzwerk persönlicher Websites, die über gemeinsame Konsolen verbunden sind und das Stöbern durch Seiten der gesamten Wander-Community erleichtern.';

  @override
  String get smallWeb_wanderAttributionLine =>
      'Von Susam Pal – Open Source unter der MIT-Lizenz.';

  @override
  String get smallWeb_wanderProjectAction => 'Projekt';

  @override
  String get smallWeb_wanderSetupConsoleAction => 'Eigene Konsole einrichten';

  @override
  String get smallWeb_menuTooltip => 'Menü';

  @override
  String get smallWeb_removeBookmarkTooltip => 'Lesezeichen entfernen';

  @override
  String get smallWeb_addBookmarkTooltip => 'Lesezeichen hinzufügen';

  @override
  String get smallWeb_bookmarkRemovedMessage => 'Lesezeichen entfernt';

  @override
  String get smallWeb_bookmarkAddedMessage => 'Lesezeichen hinzugefügt';

  @override
  String get smallWeb_exitTooltip => 'Small Web verlassen';

  @override
  String get smallWeb_selectConsoleTitle => 'Konsole auswählen';

  @override
  String get smallWeb_randomButtonLabel => 'Zufällig';

  @override
  String get smallWeb_filterConsolesHint => 'Konsolen filtern …';

  @override
  String get smallWeb_linkedConsolesToggleLabel => 'Verlinkt';

  @override
  String get smallWeb_allConsolesToggleLabel => 'Alle';

  @override
  String get smallWeb_noConsoleSelectedYetMessage =>
      'Noch keine Konsole ausgewählt. Auf „Entdecken“ tippen.';

  @override
  String get smallWeb_addConsoleByUrlTooltip => 'Konsole per URL hinzufügen';

  @override
  String get smallWeb_couldNotLoadSessionTitle =>
      'Small-Web-Sitzung konnte nicht geladen werden';

  @override
  String get smallWeb_noLinkedConsolesFound =>
      'Keine verlinkten Konsolen gefunden.';

  @override
  String smallWeb_noConsolesMatchingQuery(String query) {
    return 'Keine Konsolen passen zu „$query“.';
  }

  @override
  String get smallWeb_failedToLoadConsoles =>
      'Konsolen konnten nicht geladen werden.';

  @override
  String smallWeb_pageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Seiten',
      one: '1 Seite',
    );
    return '$_temp0';
  }

  @override
  String get smallWeb_noConsolesDiscoveredYet =>
      'Noch keine Konsolen entdeckt.';

  @override
  String smallWeb_addedConsole(String host) {
    return 'Konsole $host hinzugefügt';
  }

  @override
  String get smallWeb_addConsoleDialogTitle => 'Konsole hinzufügen';

  @override
  String get smallWeb_addConsoleDialogBody =>
      'Die URL einer Wander-Konsole eingeben. Die URL kann auf die Startseite der Website oder auf den Pfad /wander/ verweisen.';

  @override
  String get smallWeb_urlFieldLabel => 'URL';

  @override
  String get smallWeb_wanderConsoleFetchFailed =>
      'wander.js konnte von dieser Konsole nicht abgerufen werden.';

  @override
  String get smallWeb_wanderConsoleEmpty =>
      'Die Datei wander.js enthält keine Konsolen oder Seiten';

  @override
  String get smallWeb_wanderConsoleAlreadyAdded =>
      'Diese Konsole wurde bereits hinzugefügt';

  @override
  String get smallWeb_recentDiscoveriesTitle => 'Letzte Entdeckungen';

  @override
  String smallWeb_clearModeHistory(String mode) {
    return '$mode leeren';
  }

  @override
  String get smallWeb_clearAllDiscoveriesConfirmTitle =>
      'Alle Entdeckungen löschen?';

  @override
  String get smallWeb_clearAllDiscoveriesConfirmContent =>
      'Dadurch wird der gesamte Entdeckungsverlauf aller Modi und Quellen endgültig entfernt.';

  @override
  String get smallWeb_actionClearAll => 'Alle löschen';

  @override
  String get smallWeb_clearAllDiscoveriesMenuItem =>
      'Alle Entdeckungen löschen';

  @override
  String get smallWeb_noDiscoveriesYetMessage =>
      'Noch keine Entdeckungen.\nAuf „Entdecken“ tippen und loslegen!';

  @override
  String smallWeb_showMoreCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weitere anzeigen',
    );
    return '$_temp0';
  }

  @override
  String smallWeb_failedToLoadHistory(String error) {
    return 'Verlauf konnte nicht geladen werden: $error';
  }

  @override
  String get sync_screenTitle => 'Firefox Sync';

  @override
  String get sync_searchHint => 'Sync-Einstellungen durchsuchen';

  @override
  String get sync_statusSyncing => 'Synchronisierung läuft';

  @override
  String get sync_statusNeverSynced => 'Noch nie synchronisiert';

  @override
  String sync_statusLastSynced(String date) {
    return 'Zuletzt synchronisiert: $date';
  }

  @override
  String get sync_sectionAccount => 'Konto';

  @override
  String get sync_sectionAccountKeywords =>
      'Kopplung, koppeln, Gerätename, Pairing';

  @override
  String get sync_entrySignedInAccountTitle => 'Angemeldetes Konto';

  @override
  String get sync_entrySignInTitle => 'Anmelden';

  @override
  String get sync_entryAccountSubtitle =>
      'Kontostatus, QR-Kopplung und Gerätename';

  @override
  String get sync_signedIn => 'Angemeldet';

  @override
  String get sync_notSignedIn => 'Nicht angemeldet';

  @override
  String get sync_authExpired =>
      'Anmeldung abgelaufen. Zum Weitersynchronisieren erneut anmelden.';

  @override
  String get sync_syncingTabsBookmarksHistory =>
      'Tabs, Lesezeichen und Verlauf werden synchronisiert';

  @override
  String get sync_signInPrompt =>
      'Anmelden, um Tabs, Lesezeichen und Verlauf zu synchronisieren';

  @override
  String get sync_actionSignOut => 'Abmelden';

  @override
  String get sync_scanQrTitle => 'QR-Code zum Koppeln scannen';

  @override
  String get sync_scanQrSubtitle =>
      'QR-Code von firefox.com/pair am Computer scannen';

  @override
  String get sync_invalidQrCode => 'Ungültiger QR-Code: keine gültige URL';

  @override
  String get sync_deviceNameTitle => 'Gerätename';

  @override
  String get sync_unknown => 'Unbekannt';

  @override
  String get sync_sectionSynchronization => 'Synchronisierung';

  @override
  String get sync_syncNowTitle => 'Jetzt synchronisieren';

  @override
  String get sync_syncNowKeywords => 'Verlauf, Lesezeichen, Tabs, Sync';

  @override
  String get sync_syncHistoryTitle => 'Verlauf synchronisieren';

  @override
  String get sync_syncBookmarksTitle => 'Lesezeichen synchronisieren';

  @override
  String get sync_syncOpenTabsTitle => 'Offene Tabs synchronisieren';

  @override
  String get sync_sectionServerOverrides => 'Eigene Server';

  @override
  String get sync_entryServerOverridesTitle => 'Eigene Server';

  @override
  String get sync_entryServerOverridesKeywords =>
      'fxa, Token-Server, Server, selbst gehostet';

  @override
  String get sync_entryServerOverridesSubtitle =>
      'Eigene Endpunkte für Firefox Account und Token-Server';

  @override
  String get sync_fxaServerOverrideTitle => 'Eigener FxA-Server';

  @override
  String get sync_defaultMozillaServer => 'Standard-Server von Mozilla';

  @override
  String get sync_tokenServerOverrideTitle => 'Eigener Sync-Token-Server';

  @override
  String get sync_automaticFromFxaServer => 'Automatisch vom FxA-Server';

  @override
  String get sync_restartAppNotice =>
      'Nach dem Ändern der Server die App neu starten.';

  @override
  String get sync_signOutDialogTitle => 'Abmelden?';

  @override
  String get sync_signOutDialogContent => 'Von Firefox Sync abmelden?';

  @override
  String get sync_deviceNameHint => 'Gerätename eingeben';

  @override
  String get sync_deviceNameEmpty => 'Der Gerätename darf nicht leer sein';

  @override
  String get sync_deviceNameUpdateFailed =>
      'Gerätename konnte nicht aktualisiert werden';

  @override
  String get sync_mustBeValidHttpsUrl => 'Muss eine gültige HTTPS-URL sein';

  @override
  String get tor_sectionService => 'Dienst';

  @override
  String get tor_sectionServiceKeywords =>
      'Ein, Aus, starten, stoppen, beenden';

  @override
  String get tor_sectionCircumvention => 'Zensurumgehung';

  @override
  String get tor_sectionCircumventionKeywords =>
      'Brücken, Bridges, Transport, obfs4, snowflake, Zensur';

  @override
  String get tor_sectionCountryRestrictions => 'Länderbeschränkungen';

  @override
  String get tor_sectionCountryRestrictionsKeywords =>
      'Eingang, Ausgang, Land, Exit';

  @override
  String get tor_sectionAbout => 'Über';

  @override
  String get tor_sectionAboutKeywords =>
      'Marke, Markenzeichen, rechtlich, Impressum';

  @override
  String tor_proxyLabel(String brand) {
    return '$brand-Proxy';
  }

  @override
  String tor_serviceLabel(String brand) {
    return '$brand-Dienst';
  }

  @override
  String get tor_serviceLabelKeywords => 'aktivieren, verbinden, einschalten';

  @override
  String tor_serviceSubtitle(String brand) {
    return 'Den $brand-Dienst starten oder stoppen';
  }

  @override
  String get tor_startAutomaticallyTitle => 'Automatisch starten';

  @override
  String get tor_startAutomaticallyKeywords =>
      'Autostart, starten, Start, Hochfahren';

  @override
  String tor_startAutomaticallySectionSubtitle(String brand) {
    return 'Den $brand-Dienst beim Start von WebLibre verbinden';
  }

  @override
  String tor_startAutomaticallySubtitle(String brand) {
    return 'Den $brand-Dienst beim Start von WebLibre verbinden, damit Tabs, die ihn nutzen, ohne Nachfrage bereit sind';
  }

  @override
  String get tor_requestNewIdentityTitle => 'Neue Identität anfordern';

  @override
  String get tor_requestNewIdentityKeywords => 'Kanal, Circuit, Verbindung';

  @override
  String get tor_requestNewIdentitySubtitle =>
      'Für neue Verbindungen einen neuen Kanal verwenden';

  @override
  String tor_requestingNewIdentityMessage(String brand) {
    return 'Neue $brand-Identität wird angefordert …';
  }

  @override
  String get tor_autoConfigureTransportTitle =>
      'Transport automatisch einrichten';

  @override
  String get tor_autoConfigureTransportKeywords => 'automatisch, auto';

  @override
  String get tor_autoConfigureSectionSubtitle =>
      'Automatisch den passenden Pluggable Transport für das Netzwerk wählen';

  @override
  String tor_autoConfigureSubtitle(String brand) {
    return 'An manchen Orten ist ein Pluggable Transport nötig, um sich mit $brand zu verbinden';
  }

  @override
  String get tor_requireBridgeTitle =>
      'Ich bin sicher, dass ich mich ohne Brücke nicht verbinden kann';

  @override
  String get tor_transportTitle => 'Transport';

  @override
  String get tor_transportKeywords => 'direkt, obfs4, snowflake';

  @override
  String tor_transportSectionSubtitle(String torBrand) {
    return 'Festlegen, wie das $torBrand-Netzwerk ohne automatische Einrichtung erreicht wird';
  }

  @override
  String get tor_transportAutoConfiguredTitle => 'Automatisch eingerichtet';

  @override
  String get tor_transportAutoConfiguredSubtitle =>
      'Oben die automatische Einrichtung deaktivieren, um einen Transport manuell zu wählen.';

  @override
  String get tor_transportDirectTitle => 'Direkte Verbindung';

  @override
  String tor_transportDirectSubtitle(String brand) {
    return 'Der beste Weg zu $brand, wenn $brand nicht blockiert ist';
  }

  @override
  String get tor_transportObfs4Title => 'obfs4';

  @override
  String get tor_transportObfs4Subtitle =>
      'Geeignet für leicht zensierte Netzwerke und hohe Bandbreite';

  @override
  String get tor_transportSnowflakeTitle => 'Snowflake';

  @override
  String get tor_transportSnowflakeSubtitle => 'Geeignet bei starker Zensur';

  @override
  String get tor_fetchFreshBridgesTitle =>
      'Vor dem Verbinden aktuelle Brücken abrufen';

  @override
  String get tor_entryCountryTitle => 'Eingangsland';

  @override
  String get tor_entryCountrySubtitle =>
      'Land des Eingangswächters (Entry Guard) wählen';

  @override
  String get tor_entryCountryKeywords => 'Wächter, Guard, Eingang';

  @override
  String get tor_exitCountryTitle => 'Ausgangsland';

  @override
  String get tor_exitCountrySubtitle =>
      'Land des Ausgangsknotens (Exit Node) wählen';

  @override
  String get tor_exitCountryKeywords => 'Ausgang, Exit';

  @override
  String get tor_automaticOption => 'Automatisch';

  @override
  String get tor_trademarkTitle => 'Markenzeichen';

  @override
  String get tor_trademarkKeywords => 'rechtlich, Marke';

  @override
  String tor_trademarkDisclaimer(String brand) {
    return '$brand ist eine Marke von The Tor Project; alle Rechte vorbehalten. WebLibre wird vom Tor Project weder unterstützt noch gesponsert und ist nicht mit ihm verbunden.';
  }

  @override
  String get tor_screenSubtitle =>
      'Onion-Routing, Pluggable Transports, Brücken und Länderbeschränkungen.';

  @override
  String tor_dialogContent(String brand) {
    return 'Dieser Container erfordert für sichere Verbindungen einen $brand-Proxy, der gerade nicht läuft.';
  }

  @override
  String get tor_actionEnable => 'Aktivieren';

  @override
  String tor_connectingNotification(String proxyLabel) {
    return '$proxyLabel verbindet sich …';
  }

  @override
  String get tor_countrySearchHint => 'Länder suchen …';

  @override
  String get tor_unnamedCountry => 'Unbenanntes Land';

  @override
  String get user_profilesTitle => 'Profile';

  @override
  String get user_activeProfileLabel => 'Aktiv';

  @override
  String get user_loadProfilesFailedTitle =>
      'Profile konnten nicht geladen werden';

  @override
  String get user_askWhichProfileTitle => 'Beim Start nach Profil fragen';

  @override
  String get user_askWhichProfileSubtitle =>
      'Beim Start, wenn mehr als ein Profil existiert';

  @override
  String get user_createBackupTitle => 'Sicherung erstellen';

  @override
  String get user_restartingToTakeBackup =>
      'Neustart zum Erstellen der Sicherung';

  @override
  String get user_backupRestartsTitle => 'WebLibre startet dafür neu';

  @override
  String user_backupRestartsSubtitle(String restartClosesCurrentProfile) {
    return '$restartClosesCurrentProfile Die Sicherung wird bei geschlossenem Profil erstellt, damit sich sein Inhalt währenddessen nicht ändern kann.';
  }

  @override
  String get user_setPasswordNextTitle =>
      'Das Passwort wird im nächsten Schritt festgelegt';

  @override
  String get user_setPasswordNextSubtitle =>
      'Nach dem Neustart fragt WebLibre nach dem Passwort der Sicherungsdatei.';

  @override
  String get user_verifyBackupIntegrityTitle =>
      'Integrität der Sicherung prüfen';

  @override
  String get user_verifyBackupIntegritySubtitle =>
      'Prüfen, ob sich die Sicherung wiederherstellen lässt';

  @override
  String get user_tempDataSkippedTitle => 'Temporäre Daten werden übersprungen';

  @override
  String user_tempDataSkippedSubtitle(String shortcutsNeedPinningAgain) {
    return 'Cache-Dateien und andere Daten, die WebLibre neu erzeugen kann, werden nicht gespeichert. $shortcutsNeedPinningAgain';
  }

  @override
  String get user_accountDataIncludedTitle =>
      'WebLibre-Kontodaten sind enthalten';

  @override
  String user_accountDataIncludedSubtitle(String profileSecretDataDescription) {
    return 'Die Sicherungsdatei enthält aus diesem Profil: $profileSecretDataDescription. Beim Ersetzen eines Profils werden sie wiederhergestellt, beim Anlegen eines neuen Profils nicht. Ein starkes Passwort verwenden.';
  }

  @override
  String get user_closingToTakeBackup =>
      'WebLibre wird zum Erstellen der Sicherung geschlossen …';

  @override
  String get user_actionBackup => 'Sichern';

  @override
  String get user_backupsTitle => 'Sicherungen';

  @override
  String get user_changeBackupFolderTooltip => 'Sicherungsordner ändern';

  @override
  String get user_chooseBackupFolderPrompt =>
      'Speicherort für Sicherungen auswählen.';

  @override
  String get user_chooseBackupFolderHint =>
      'Einen Ort außerhalb der App wählen, damit die Sicherungen eine Deinstallation überstehen.';

  @override
  String get user_chooseFolderButtonLabel => 'Ordner auswählen';

  @override
  String get user_noBackupsFound => 'Keine Sicherungen gefunden';

  @override
  String get user_loadBackupsFailedTitle =>
      'Sicherungen konnten nicht geladen werden';

  @override
  String get user_authReasonRequireAuth =>
      'Authentifizierung für Profil verlangen';

  @override
  String get user_authReasonConfirmUnlock =>
      'Bestätigen, dass dieses Profil entsperrt werden kann';

  @override
  String get user_authReasonUnlockProfile => 'Profil entsperren';

  @override
  String user_authFailedExisting(String nothingChanged) {
    return 'Die Identität konnte nicht bestätigt werden. $nothingChanged';
  }

  @override
  String get user_authFailedNew =>
      'Die Identität konnte nicht bestätigt werden. Ein gesperrtes Profil wird erst angelegt, wenn dieses Gerät es entsperren kann.';

  @override
  String get user_editProfileTitle => 'Profil bearbeiten';

  @override
  String get user_createProfileTitle => 'Profil erstellen';

  @override
  String get user_nameFieldLabel => 'Name';

  @override
  String get user_authenticationSectionTitle => 'Authentifizierung';

  @override
  String get user_requireAuthenticationTitle => 'Authentifizierung verlangen';

  @override
  String get user_requireAuthenticationSubtitle =>
      'Vor dem Öffnen dieses Profils nachfragen';

  @override
  String get user_autoLockTitle => 'Automatisch sperren';

  @override
  String get user_autoLockSubtitle => 'Wann das Profil wieder gesperrt wird';

  @override
  String get user_lockInBackgroundTitle => 'Im Hintergrund sperren';

  @override
  String get user_lockInBackgroundSubtitle =>
      'Sobald WebLibre den Bildschirm verlässt';

  @override
  String get user_lockAfterTimeoutTitle => 'Nach einer Wartezeit sperren';

  @override
  String get user_lockAfterTimeoutSubtitle => 'Nach einer Zeit der Inaktivität';

  @override
  String get user_lockOnStartupTitle => 'Nur beim Start sperren';

  @override
  String get user_lockOnStartupSubtitle =>
      'Einmal beim Start entsperren, dann entsperrt bleiben, bis WebLibre vollständig geschlossen wird';

  @override
  String get user_timeoutFieldTitle => 'Wartezeit';

  @override
  String get user_timeoutFieldSubtitle =>
      'Wie lange bis zum Sperren gewartet wird';

  @override
  String get user_timeoutOneMinute => '1 Minute';

  @override
  String get user_timeoutFiveMinutes => '5 Minuten';

  @override
  String get user_timeoutFifteenMinutes => '15 Minuten';

  @override
  String get user_timeoutOneHour => '1 Stunde';

  @override
  String get user_profileActionsSectionTitle => 'Profilaktionen';

  @override
  String get user_switchDeleteUnavailableForActive =>
      'Für das gerade verwendete Profil sind Wechseln und Löschen nicht verfügbar.';

  @override
  String get user_switchToThisProfileLabel => 'Zu diesem Profil wechseln';

  @override
  String user_deleteFailedWithError(String error) {
    return 'Löschen fehlgeschlagen: $error';
  }

  @override
  String get user_deleteProfileFailedGeneric =>
      'Dieses Profil konnte nicht gelöscht werden';

  @override
  String get user_restoreBackupTitle => 'Sicherung wiederherstellen';

  @override
  String get user_backupRestoredMessage => 'Sicherung wiederhergestellt';

  @override
  String get user_passwordFieldLabel => 'Passwort';

  @override
  String get user_wrongBackupPassword =>
      'Mit diesem Passwort ließ sich die Sicherungsdatei nicht öffnen';

  @override
  String get user_passwordHelperText =>
      'Das Passwort, mit dem diese Sicherungsdatei erstellt wurde.';

  @override
  String get user_createNewProfileTitle => 'Neues Profil anlegen';

  @override
  String get user_createNewProfileSubtitle =>
      'Vorhandene Profile behalten und diese Sicherung hinzufügen';

  @override
  String get user_replaceExistingProfileTitle => 'Vorhandenes Profil ersetzen';

  @override
  String get user_replaceExistingProfileSubtitle =>
      'Neu starten und ein Profil mit dieser Sicherung überschreiben';

  @override
  String get user_newProfileNoSignInTitle =>
      'Ein neues Profil startet ohne WebLibre-Anmeldung';

  @override
  String get user_newProfileNoSignInSubtitle =>
      'Tabs, Verlauf und Lesezeichen werden wiederhergestellt. Anmelde- und Sync-Daten bleiben beim ursprünglichen Profil.';

  @override
  String user_restoringIntoTitle(String profileLabel) {
    return 'Wiederherstellung in „$profileLabel“';
  }

  @override
  String get user_backupKeepsLockConfigured =>
      'Die Sicherung behält die eingerichtete Sperre.';

  @override
  String get user_profileKeepsNameAndLock =>
      'Das Profil behält seinen Namen und seine Sperre.';

  @override
  String get user_profileToReplaceLabel => 'Zu ersetzendes Profil';

  @override
  String get user_selectProfileToReplaceValidator =>
      'Ein zu ersetzendes Profil auswählen';

  @override
  String user_multipleProfilesShareNameTitle(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Profile heißen „$name“',
    );
    return '$_temp0';
  }

  @override
  String user_multipleProfilesShareNameSubtitle(String cannotBeUndone) {
    return 'Die Sicherung nennt ein Profil, kann aber nicht sagen, welches – daher das zu ersetzende auswählen. $cannotBeUndone';
  }

  @override
  String user_backupTakenFromTitle(String name) {
    return 'Diese Sicherung stammt von „$name“';
  }

  @override
  String user_backupTakenFromSubtitle(
    String targetLabel,
    String shortcutsNeedPinningAgain,
  ) {
    return 'Sie ersetzt „$targetLabel“, das seinen Namen und seine Sperre behält. $shortcutsNeedPinningAgain';
  }

  @override
  String user_profileWillBeCalledTitle(String name) {
    return 'Dieses Profil wird „$name“ heißen';
  }

  @override
  String user_profileWillBeCalledSubtitle(String shortcutsNeedPinningAgain) {
    return 'Der Name stammt aus der Sicherung. $shortcutsNeedPinningAgain';
  }

  @override
  String get user_accountDataRestoredTitle =>
      'WebLibre-Kontodaten werden wiederhergestellt';

  @override
  String user_accountDataRestoredSubtitle(
    String profileSecretDataDescription,
    String signedInFromBackup,
    String olderBackupKeepsCredentials,
  ) {
    return 'Beim Ersetzen wird aus der Sicherungsdatei wiederhergestellt: $profileSecretDataDescription. $signedInFromBackup $olderBackupKeepsCredentials';
  }

  @override
  String get user_replacesSetupProfileTitle =>
      'Dies ersetzt das Profil, das gerade eingerichtet wird';

  @override
  String get user_replacesEverythingTitle =>
      'Dies ersetzt alles in diesem Profil';

  @override
  String user_replacesSetupProfileSubtitle(String restartsThenAsksPassword) {
    return '$restartsThenAsksPassword Alles, was sich bereits in diesem Profil befindet, wird beim Start der Wiederherstellung ersetzt.';
  }

  @override
  String user_replacesEverythingSubtitle(
    String restartsThenAsksPassword,
    String profileDataDescription,
    String targetDescription,
  ) {
    return '$restartsThenAsksPassword Beim Start der Wiederherstellung wird in $targetDescription Folgendes ersetzt: $profileDataDescription.';
  }

  @override
  String get user_thatProfileFallbackLabel => 'diesem Profil';

  @override
  String get user_restoringBackupProgress =>
      'Sicherung wird wiederhergestellt …';

  @override
  String get user_closingToRestoreProgress =>
      'WebLibre wird zum Wiederherstellen geschlossen …';

  @override
  String get user_actionRestore => 'Wiederherstellen';

  @override
  String user_switchToProfileTitle(String profileName) {
    return 'Zu „$profileName“ wechseln?';
  }

  @override
  String user_switchClosesReopensAs(String profileName) {
    return 'WebLibre wird geschlossen und als „$profileName“ wieder geöffnet.';
  }

  @override
  String get user_switchConsequencesList =>
      '• Private Tabs werden gelöscht.\n• Web-Benachrichtigungen des verlassenen Profils werden pausiert.';

  @override
  String get user_actionNotNow => 'Nicht jetzt';

  @override
  String get user_actionSwitchAndRestart => 'Wechseln und neu starten';

  @override
  String get user_passwordConfirmationTitle => 'Passwort bestätigen';

  @override
  String get user_actionConfirm => 'Bestätigen';

  @override
  String get user_selectProfileTitle => 'Profil auswählen';

  @override
  String get user_manageProfilesLabel => 'Profile verwalten';

  @override
  String get user_profileAvatarHint =>
      'Zu diesem Profil wechseln. Lange drücken zum Bearbeiten.';

  @override
  String user_profileAvatarTooltip(String label) {
    return '$label\nLange drücken zum Bearbeiten';
  }

  @override
  String get user_addProfileLabel => 'Profil hinzufügen';

  @override
  String get user_addProfileButtonLabel => 'Hinzufügen';

  @override
  String get user_quitBrowserTitle => 'Browser beenden';

  @override
  String get user_quitBrowserContent =>
      'Dadurch wird der Browser sauber beendet und die Daten privater Tabs werden gelöscht.';

  @override
  String get user_actionQuit => 'Beenden';

  @override
  String user_deleteProfileTitle(String profileName) {
    return '„$profileName“ löschen?';
  }

  @override
  String user_deleteProfileContent(
    String profileDataDescription,
    String cannotBeUndone,
  ) {
    return 'Entfernt wird: $profileDataDescription. $cannotBeUndone';
  }

  @override
  String user_deleteProfileRestartNote(
    String restartsToWork,
    String restartClosesCurrentProfile,
  ) {
    return '$restartsToWork $restartClosesCurrentProfile Das zu löschende Profil wird zuerst geschlossen.';
  }

  @override
  String get user_actionDeleteAndRestart => 'Löschen und neu starten';

  @override
  String user_replaceProfileTitle(String profileName) {
    return '„$profileName“ durch diese Sicherung ersetzen?';
  }

  @override
  String user_replaceProfilePlaceholderContent(String cannotBeUndone) {
    return 'Die Sicherung ersetzt das Profil, das gerade eingerichtet wird. Alles, was bereits darin ist, geht verloren. $cannotBeUndone';
  }

  @override
  String user_replaceProfileContent(
    String profileName,
    String profileDataDescription,
    String cannotBeUndone,
  ) {
    return 'Die Sicherung ersetzt alles in „$profileName“: $profileDataDescription. Alles, was nach der Sicherung hinzugekommen ist, geht verloren. $cannotBeUndone';
  }

  @override
  String user_replaceProfileAccountNote(
    String signedInFromBackup,
    String profileSecretDataDescription,
    String olderBackupKeepsCredentials,
  ) {
    return '$signedInFromBackup Außerdem wird aus der Sicherung wiederhergestellt: $profileSecretDataDescription. $olderBackupKeepsCredentials';
  }

  @override
  String user_replaceProfileRenamedNote(
    String adoptedName,
    String shortcutsNeedPinningAgain,
  ) {
    return 'Das Profil wird in „$adoptedName“ umbenannt und behält seine Sperre. $shortcutsNeedPinningAgain';
  }

  @override
  String user_replaceProfileFromSourceNote(
    String sourceProfileName,
    String profileName,
    String shortcutsNeedPinningAgain,
  ) {
    return 'Die Sicherung stammt von „$sourceProfileName“. „$profileName“ behält seinen Namen und seine Sperre. $shortcutsNeedPinningAgain';
  }

  @override
  String user_replaceProfileRestartNote(
    String restartsThenAsksPassword,
    String restartClosesCurrentProfile,
  ) {
    return '$restartsThenAsksPassword Vorher wird nichts ersetzt. $restartClosesCurrentProfile';
  }

  @override
  String get user_actionReplaceAndRestart => 'Ersetzen und neu starten';

  @override
  String user_backupProfileTitle(String profileName) {
    return '„$profileName“ sichern?';
  }

  @override
  String get user_backupProfileContent =>
      'Die Sicherung wird bei geschlossenem Profil erstellt, sodass sich darin nichts ändert.';

  @override
  String user_backupProfileRestartNote(
    String restartsToWork,
    String restartClosesCurrentProfile,
  ) {
    return '$restartsToWork $restartClosesCurrentProfile';
  }

  @override
  String get user_actionBackupAndRestart => 'Sichern und neu starten';

  @override
  String get user_profileAlreadyActive => 'Dieses Profil ist bereits aktiv';

  @override
  String user_switchProfileFailedWithError(String error) {
    return 'Profilwechsel fehlgeschlagen: $error';
  }

  @override
  String get user_profileLockedTitle => 'Profil ist gesperrt';

  @override
  String get user_unlockingLabel => 'Wird entsperrt …';

  @override
  String get user_unlockButtonLabel => 'Entsperren';

  @override
  String user_restartFailedWithError(String error) {
    return 'Neustart fehlgeschlagen: $error';
  }

  @override
  String get user_restartingLabel => 'Neustart …';

  @override
  String get user_chooseAnotherProfileLabel => 'Anderes Profil wählen';

  @override
  String get user_searchSuggestionProviderNone => 'Deaktiviert';

  @override
  String get user_searchSuggestionProviderBrave => 'Brave';

  @override
  String get user_searchSuggestionProviderDdg => 'DuckDuckGo';

  @override
  String get user_searchSuggestionProviderKagi => 'Kagi';

  @override
  String get user_searchSuggestionProviderQwant => 'Qwant';

  @override
  String get user_deleteBrowsingDataTypeTabsTitle => 'Offene Tabs';

  @override
  String get user_deleteBrowsingDataTypeHistoryTitle => 'Browserverlauf';

  @override
  String get user_deleteBrowsingDataTypeRecentSearchesTitle => 'Letzte Suchen';

  @override
  String get user_deleteBrowsingDataTypeRecentSearchesDescription =>
      'Auf der Suchseite angezeigte Suchanfragen';

  @override
  String get user_deleteBrowsingDataTypeCookiesTitle =>
      'Cookies und Websitedaten';

  @override
  String get user_deleteBrowsingDataTypeCookiesDescription =>
      'Abmeldung von den meisten Websites';

  @override
  String get user_deleteBrowsingDataTypeCacheTitle =>
      'Zwischengespeicherte Bilder und Dateien';

  @override
  String get user_deleteBrowsingDataTypeCacheDescription =>
      'Gibt Speicherplatz frei';

  @override
  String get user_deleteBrowsingDataTypePermissionsTitle =>
      'Website-Berechtigungen';

  @override
  String get user_deleteBrowsingDataTypeDownloadsTitle => 'Downloads';

  @override
  String get wallpaper_title => 'Hintergrundbild';

  @override
  String get wallpaper_settingsDescription =>
      'Wird hinter der Startseite angezeigt – in jedem Container, der kein eigenes festlegt.';

  @override
  String get wallpaper_chooseImage => 'Bild auswählen';

  @override
  String get wallpaper_replace => 'Ersetzen';

  @override
  String get wallpaper_blurLabel => 'Unschärfe';

  @override
  String get wallpaper_dimLabel => 'Abdunkeln';

  @override
  String get wallpaper_dimDescription =>
      'Abdunkeln blendet das Bild in den App-Hintergrund über, damit Text auf der Seite im hellen und im dunklen Design lesbar bleibt.';

  @override
  String get wallpaper_editorDefaultDescription =>
      'Die Startseite behält ihren Standardhintergrund.';

  @override
  String get wallpaper_importErrorUnreadable =>
      'Die Datei konnte nicht gelesen werden';

  @override
  String get wallpaper_importErrorTooLarge => 'Das Bild ist zu groß';

  @override
  String get wallpaper_importErrorNotAnImage => 'Die Datei ist kein Bild';

  @override
  String get wallpaper_importErrorDecodeFailed =>
      'Das Bild konnte nicht gelesen werden';

  @override
  String get webFeed_addFeedTitle => 'Feed hinzufügen';

  @override
  String get webFeed_fieldUrlLabel => 'URL';

  @override
  String get webFeed_actionIgnore => 'Ignorieren';

  @override
  String get webFeed_unnamedFeedTitle => 'Unbenannter Feed';

  @override
  String get webFeed_unnamedArticleTitle => 'Unbenannter Artikel';

  @override
  String get webFeed_fetchFeedFailedTitle =>
      'Feed konnte nicht abgerufen werden';

  @override
  String get webFeed_feedsTitle => 'Feeds';

  @override
  String get webFeed_loadFeedsFailedTitle =>
      'Feeds konnten nicht geladen werden';

  @override
  String get webFeed_feedFabLabel => 'Feed hinzufügen';

  @override
  String get webFeed_loadFeedFailedTitle => 'Feed konnte nicht geladen werden';

  @override
  String get webFeed_newFeedTitle => 'Neuer Feed';

  @override
  String get webFeed_editFeedTitle => 'Feed bearbeiten';

  @override
  String get webFeed_fetchingFeedMessage => 'Feed wird abgerufen …';

  @override
  String get webFeed_fieldTitleLabel => 'Titel';

  @override
  String get webFeed_fieldDescriptionLabel => 'Beschreibung';

  @override
  String get webFeed_fieldIconUrlLabel => 'Symbol-URL';

  @override
  String get webFeed_fieldSiteLinkLabel => 'Website-Link';

  @override
  String get webFeed_fieldFeedUrlLabel => 'Feed-URL';

  @override
  String get webFeed_deleteFeedTitle => 'Feed löschen';

  @override
  String get webFeed_deleteFeedConfirm =>
      'Diesen Feed und alle zugehörigen Artikel löschen?';

  @override
  String get webFeed_articlesTitle => 'Artikel';

  @override
  String get webFeed_searchLabel => 'Suchen';

  @override
  String get webFeed_loadArticlesFailedTitle =>
      'Artikel konnten nicht geladen werden';

  @override
  String webFeed_publishedLabel(String date) {
    return 'Veröffentlicht: $date';
  }

  @override
  String get webFeed_notAvailable => 'k. A.';

  @override
  String webFeed_updatedLabel(String date) {
    return 'Aktualisiert: $date';
  }

  @override
  String get webFeed_authorsLabel => 'Autoren:';

  @override
  String get webFeed_tagsLabel => 'Tags:';

  @override
  String get webFeed_readArticleFailedTitle =>
      'Artikel konnte nicht geladen werden';

  @override
  String webFeed_lastFetchedLabel(String date) {
    return 'Zuletzt abgerufen: $date';
  }

  @override
  String get webFeed_tagsFieldLabel => 'Tags';

  @override
  String get webPush_screenTitle => 'Benachrichtigungen';

  @override
  String get webPush_screenSubtitle =>
      'Website-Benachrichtigungen über UnifiedPush';

  @override
  String get webPush_distributorTileTitle => 'UnifiedPush-Distributor';

  @override
  String get webPush_distributorTileKeywords =>
      'Benachrichtigungen, Push, unifiedpush, ntfy, Mitteilungen';

  @override
  String get webPush_checking => 'Wird geprüft …';

  @override
  String webPush_couldNotReadStatus(String error) {
    return 'Push-Status konnte nicht gelesen werden: $error';
  }

  @override
  String get webPush_updatingDistributor => 'Wird aktualisiert …';

  @override
  String get webPush_registrationRecovering =>
      'Registrierungsfehler wird behoben …';

  @override
  String webPush_lastRegistrationError(String error) {
    return 'Letzter Registrierungsfehler: $error';
  }

  @override
  String get webPush_disablingWebPush => 'Wird deaktiviert …';

  @override
  String get webPush_disableWebPush => 'Web Push deaktivieren';

  @override
  String get webPush_statusNoneAvailable => 'Kein Distributor verfügbar';

  @override
  String get webPush_statusNotSelected => 'Nicht eingerichtet';

  @override
  String get webPush_statusPending => 'Verbindung wird hergestellt …';

  @override
  String get webPush_statusReady => 'Aktiv';

  @override
  String get webPush_statusUnavailable => 'Distributor nicht verfügbar';

  @override
  String get webPush_statusDescNoneAvailable =>
      'Um Website-Benachrichtigungen zu erhalten, eine UnifiedPush-Distributor-App wie ntfy installieren.';

  @override
  String get webPush_statusDescNotSelected =>
      'Unten einen Distributor auswählen, um Website-Benachrichtigungen zu aktivieren.';

  @override
  String get webPush_statusDescPending =>
      'Wartet auf die Bestätigung der Registrierung durch den Distributor.';

  @override
  String get webPush_statusDescReady =>
      'Website-Benachrichtigungen werden über diesen Distributor zugestellt.';

  @override
  String get webPush_statusDescUnavailable =>
      'Der ausgewählte Distributor ist nicht mehr installiert. Website-Benachrichtigungen werden erst wieder zugestellt, wenn ein anderer ausgewählt ist.';

  @override
  String get webPush_noDistributorInstalled =>
      'Es ist kein UnifiedPush-Distributor installiert. Einen installieren, z. B. ntfy, und erneut versuchen.';

  @override
  String get webPush_chooseDistributorTitle => 'Distributor auswählen';

  @override
  String get webPush_distributorConfigured =>
      'UnifiedPush-Distributor eingerichtet.';

  @override
  String webPush_couldNotConfigureDistributor(String error) {
    return 'Distributor konnte nicht eingerichtet werden: $error';
  }

  @override
  String get webPush_webPushDisabled => 'Web Push deaktiviert.';

  @override
  String webPush_couldNotDisableWebPush(String error) {
    return 'Web Push konnte nicht deaktiviert werden: $error';
  }

  @override
  String get webPush_notificationPermissionTitle =>
      'Benachrichtigungsberechtigung';

  @override
  String get webPush_notificationPermissionKeywords =>
      'Benachrichtigungen, Berechtigung, Mitteilungen';

  @override
  String webPush_notificationPermissionCouldNotRead(String error) {
    return 'Berechtigungsstatus konnte nicht gelesen werden: $error';
  }

  @override
  String get webPush_notificationPermissionGranted => 'Erteilt';

  @override
  String get webPush_notificationPermissionDenied =>
      'Verweigert. Push-Nachrichten kommen weiterhin an, es können aber keine Benachrichtigungen angezeigt werden.';

  @override
  String get webPush_grantAction => 'Erteilen';

  @override
  String webPush_couldNotUpdatePermission(String error) {
    return 'Benachrichtigungsberechtigung konnte nicht aktualisiert werden: $error';
  }

  @override
  String get webPush_loadingSubscriptions => 'Abonnements werden geladen …';

  @override
  String get webPush_couldNotReadSubscriptions =>
      'Abonnements konnten nicht gelesen werden';

  @override
  String get webPush_noSiteSubscriptions => 'Keine Website-Abonnements';

  @override
  String get webPush_noSiteSubscriptionsDescription =>
      'Websites, denen Benachrichtigungen erlaubt werden, erscheinen hier.';

  @override
  String get webPush_subscriptionActive => 'Aktiv';

  @override
  String get webPush_subscriptionDelayedDelivery =>
      'Endpunkt gespeichert; Zustellung pausiert, bis der Distributor bereit ist';

  @override
  String get webPush_subscriptionWaitingForEndpoint =>
      'Warten auf die Zuweisung eines Endpunkts durch den Distributor';

  @override
  String get webPush_revokeSubscriptionHint =>
      'Damit eine Website keine Benachrichtigungen mehr sendet, ihre Benachrichtigungsberechtigung in den Website-Einstellungen widerrufen.';

  @override
  String get webPush_deliverySectionTitle => 'Zustellung';

  @override
  String get webPush_indexDistributorSubtitle =>
      'Die App, die Push-Benachrichtigungen von Websites zustellt';

  @override
  String get webPush_indexNotificationPermissionSubtitle =>
      'Erforderlich, um Website-Benachrichtigungen anzuzeigen';

  @override
  String get webPush_subscriptionsSectionTitle => 'Abonnements';

  @override
  String get webPush_indexSiteSubscriptionsTitle => 'Website-Abonnements';

  @override
  String get webPush_indexSiteSubscriptionsKeywords =>
      'Websites, Abonnements, Seiten';

  @override
  String get webPush_indexSiteSubscriptionsSubtitle =>
      'Websites mit abonnierten Push-Benachrichtigungen';

  @override
  String get webSearch_fetchPageDataTitle => 'Seitendaten abrufen';

  @override
  String get webSearch_downloadFailedTapToRetry =>
      'Download fehlgeschlagen – zum Wiederholen tippen';

  @override
  String get webSearch_methodTrafilaturaTitle => 'Extrahierte Vorschau';

  @override
  String get webSearch_methodSinglefileTitle => 'Vollständige Seitenkopie';

  @override
  String get webSearch_methodPdfTitle => 'PDF-Schnappschuss';

  @override
  String get webSearch_methodPngTitle => 'Bild-Schnappschuss';

  @override
  String get webSearch_methodTrafilaturaSubtitle =>
      'Für das Lesen optimierter Text und Metadaten für die Vorschau in der App';

  @override
  String get webSearch_methodSinglefileSubtitle =>
      'Die ganze Seite samt Layout und Ressourcen zur späteren Nutzung archivieren';

  @override
  String get webSearch_methodPdfSubtitle =>
      'Die Seite als PDF zum Offline-Lesen und Teilen erzeugen';

  @override
  String get webSearch_methodPngSubtitle =>
      'Einen PNG-Screenshot der gesamten dargestellten Seite erstellen';

  @override
  String get webSearch_previewUnavailableTitle => 'Vorschau nicht verfügbar';

  @override
  String get webSearch_previewUnavailableMessage =>
      'Vor dem Öffnen einer Vorschau die Seite aus der Ergebnisliste abrufen.';

  @override
  String get webSearch_openInBrowserTooltip => 'Im Browser öffnen';

  @override
  String webSearch_torToggleOn(String brand) {
    return '$brand an';
  }

  @override
  String webSearch_torToggleOff(String brand) {
    return '$brand aus';
  }

  @override
  String get webSearch_languageAuto => 'Auto';

  @override
  String get webSearch_languageAutoDeviceDefault => 'Auto (Gerätestandard)';

  @override
  String get webSearch_countryAny => 'Alle';

  @override
  String get webSearch_countryAnyRegion => 'Alle Regionen';

  @override
  String webSearch_countryDeviceDefault(String name) {
    return '$name (Gerät)';
  }

  @override
  String get webSearch_safeSearchPillDefault => 'Safe: Standard';

  @override
  String get webSearch_safeSearchPillOff => 'Safe: aus';

  @override
  String get webSearch_safeSearchPillModerate => 'Safe: moderat';

  @override
  String get webSearch_safeSearchPillStrict => 'Safe: streng';

  @override
  String get webSearch_safeSearchMenuDefault => 'Standard (moderat)';

  @override
  String get webSearch_safeSearchMenuOff => 'Aus';

  @override
  String get webSearch_safeSearchMenuModerate => 'Moderat';

  @override
  String get webSearch_safeSearchMenuStrict => 'Streng';

  @override
  String get webSearch_freshnessAnyTime => 'Beliebige Zeit';

  @override
  String get webSearch_freshnessPastDay => 'Letzter Tag';

  @override
  String get webSearch_freshnessPastWeek => 'Letzte Woche';

  @override
  String get webSearch_freshnessPastMonth => 'Letzter Monat';

  @override
  String get webSearch_freshnessPastYear => 'Letztes Jahr';

  @override
  String get webSearch_modeGeneralLabel => 'Allgemein';

  @override
  String get webSearch_modeIndependentWebLabel => 'Unabhängiges Web';

  @override
  String get webSearch_modeSmallWebLabel => 'Small Web';

  @override
  String get webSearch_modeGeneralDescription =>
      'Ausgewogene Ergebnisse aus dem offenen Web';

  @override
  String get webSearch_modeIndependentWebDescription =>
      'Kleinere und weniger kommerzielle Quellen bevorzugen';

  @override
  String get webSearch_modeSmallWebDescription =>
      'Unabhängige, persönliche und Nischen-Websites';

  @override
  String get webSearch_fetchTooltip => 'Abrufen';

  @override
  String get webSearch_additionalSnippetsHeading => 'Weitere Auszüge';

  @override
  String get webSearch_questionPrefix => 'F: ';

  @override
  String get webSearch_snippetsTooltip => 'Auszüge';

  @override
  String webSearch_showMoreLinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weitere Links anzeigen',
      one: '1 weiteren Link anzeigen',
    );
    return '$_temp0';
  }

  @override
  String get webSearch_factsheetHeading => 'Steckbrief';

  @override
  String get webSearch_searchFailedTitle => 'Suche fehlgeschlagen';

  @override
  String get webSearch_searchingLabel => 'Das Web wird durchsucht …';

  @override
  String webSearch_noResultsFor(String query) {
    return 'Keine Ergebnisse für „$query“ gefunden.';
  }

  @override
  String webSearch_creditsTokensStatus(int credits, int tokens) {
    String _temp0 = intl.Intl.pluralLogic(
      credits,
      locale: localeName,
      other: '$credits Guthabenpunkte',
      one: '1 Guthabenpunkt',
    );
    String _temp1 = intl.Intl.pluralLogic(
      tokens,
      locale: localeName,
      other: '$tokens Tokens',
      one: '1 Token',
    );
    return '$_temp0  |  $_temp1';
  }

  @override
  String get webSearch_needsCreditsMessage =>
      'Für eine neue Websuche stehen weder Suchguthaben noch Tokens zur Verfügung.';

  @override
  String get webSearch_buySearchPackButton => 'Suchpaket kaufen';

  @override
  String get webSearch_socketConnectionError =>
      'Verbindungsfehler bei der Suche. Bitte erneut versuchen.';

  @override
  String get webSearch_closeErrorSessionTimeout =>
      'Zeitüberschreitung der Suchsitzung. Bitte erneut versuchen.';

  @override
  String get webSearch_closeErrorCreditInvalid =>
      'Das Suchguthaben konnte nicht bestätigt werden. Möglicherweise wurde es bereits verbraucht – bitte erneut versuchen.';

  @override
  String get webSearch_closeErrorPolicyForbidden =>
      'Die angeforderte Seite ist durch die Suchrichtlinie nicht erlaubt.';

  @override
  String get webSearch_closeErrorServerFailed =>
      'Die Suche ist auf dem Server fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String webSearch_closeErrorUnknown(int code) {
    return 'Die Suchverbindung wurde unerwartet beendet (Code $code). Bitte erneut versuchen.';
  }

  @override
  String get webSearch_unknownErrorDetail => 'unbekannter Fehler';

  @override
  String webSearch_streamErrorProtocol(String detail) {
    return 'Protokollfehler bei der Suche. Die Sitzung wurde beendet – bitte erneut versuchen. ($detail)';
  }

  @override
  String webSearch_streamErrorSearchFailed(String detail) {
    return 'Die Suche ist auf dem Server fehlgeschlagen. Bitte erneut versuchen. ($detail)';
  }

  @override
  String webSearch_streamErrorFetchFailed(String detail) {
    return 'Diese Seite konnte nicht von der Quelle abgerufen werden. ($detail)';
  }

  @override
  String webSearch_streamErrorExtractFailed(String detail) {
    return 'Aus dieser Seite konnte keine lesbare Vorschau erstellt werden. ($detail)';
  }

  @override
  String webSearch_streamErrorNotAllowed(String detail) {
    return 'Diese Seite ist durch die Suchrichtlinie nicht erlaubt. ($detail)';
  }

  @override
  String webSearch_streamErrorCaptureFailed(String detail) {
    return 'Seitenerfassung fehlgeschlagen. ($detail)';
  }

  @override
  String webSearch_streamErrorGeneric(String detail) {
    return 'Suchfehler: $detail';
  }

  @override
  String webSearch_torStartFailed(String torBrand) {
    return '$torBrand konnte für die Suche nicht gestartet werden. Den $torBrand-Schalter deaktivieren oder erneut versuchen.';
  }

  @override
  String get webSearch_creditCheckFailed =>
      'Suchguthaben konnte nicht geprüft werden. Bitte erneut versuchen.';

  @override
  String get webSearch_tokenIssuanceFailed =>
      'Such-Tokens konnten nicht ausgestellt werden. Bitte erneut versuchen.';

  @override
  String get mainApp_initializationErrorTitle => 'Initialisierungsfehler';

  @override
  String get mainApp_initializationErrorMessage =>
      'Die App konnte nicht initialisiert werden';

  @override
  String get mainApp_initStageLoadingFormats => 'Formate werden geladen …';

  @override
  String get mainApp_initStageLoadingPackageInfo =>
      'App-Informationen werden geladen …';

  @override
  String get mainApp_initStageSyncingBangs => 'Bangs werden synchronisiert …';

  @override
  String get mainApp_downloadCompleted => 'Download abgeschlossen';

  @override
  String get mainApp_downloadOpenFailed =>
      'Die heruntergeladene Datei konnte nicht geöffnet werden';

  @override
  String mainApp_downloadFailed(String name) {
    return 'Download fehlgeschlagen: $name';
  }

  @override
  String mainApp_containerBlockedWithHost(String host) {
    return '$host ist diesem Container nicht zugewiesen';
  }

  @override
  String get mainApp_containerBlockedNoHost =>
      'Diese Website ist diesem Container nicht zugewiesen';

  @override
  String get mainApp_sandboxNoCredits =>
      'Kein Suchguthaben mehr übrig. Zum Fortfahren weiteres Guthaben kaufen.';

  @override
  String get mainApp_sandboxTokenIssuanceFailed =>
      'Neue Such-Tokens konnten nicht ausgestellt werden. Verbindung prüfen und erneut versuchen.';

  @override
  String mainApp_sandboxFetchPolicyRejected(String detail) {
    return 'Erfassung durch Abrufrichtlinie blockiert: $detail';
  }

  @override
  String get mainApp_sandboxDetailNotAllowed => 'nicht erlaubt';

  @override
  String mainApp_sandboxCaptureFailed(String detail) {
    return 'Erfassung fehlgeschlagen: $detail';
  }

  @override
  String get mainApp_sandboxDetailUnknownError => 'unbekannter Fehler';

  @override
  String get mainApp_sandboxDownloadFailed =>
      'Das Erfassungsergebnis konnte nicht heruntergeladen werden.';

  @override
  String mainApp_sandboxUnknownError(String detail) {
    return 'Fehler bei der Sandbox-Erfassung: $detail';
  }

  @override
  String get mainApp_syncFailed => 'Synchronisierung fehlgeschlagen';

  @override
  String get startup_pickerTitle => 'Profil auswählen';

  @override
  String startup_pickerEachProfileKeepsOwn(String contents) {
    return 'Jedes Profil speichert $contents getrennt.';
  }

  @override
  String get startup_pickerOpensByDefaultLocked =>
      'Standardmäßig geöffnet · Gesperrt';

  @override
  String get startup_pickerOpensByDefault => 'Standardmäßig geöffnet';

  @override
  String get startup_pickerLocked => 'Gesperrt';

  @override
  String get startup_haltMaintenanceTitle => 'Unvollendete Profilarbeiten';

  @override
  String get startup_haltMaintenanceBody =>
      'Eine Sicherung, Wiederherstellung oder Löschung aus einer früheren Sitzung wurde nicht abgeschlossen. WebLibre muss sie beenden, bevor ein Profil geöffnet werden kann.';

  @override
  String get startup_haltUnavailableTitle => 'Start noch nicht bereit';

  @override
  String startup_haltUnavailableBody(String reopenToContinue) {
    return 'WebLibre muss neu starten, bevor ein Profil ausgewählt werden kann. $reopenToContinue';
  }

  @override
  String get startup_haltProfileAccessBusyTitle => 'Profil wird verwendet';

  @override
  String get startup_haltProfileAccessBusyBody =>
      'Eine andere WebLibre-Aufgabe verwendet dieses Profil noch. Gleich noch einmal versuchen.';

  @override
  String get startup_haltNoProfileTitle => 'Kein nutzbares Profil';

  @override
  String get startup_haltNoProfileBody =>
      'WebLibre konnte weder ein vorhandenes Profil lesen noch ein neues anlegen. Der Speicher ist möglicherweise voll oder nicht verfügbar.';

  @override
  String get startup_haltArbitrationFailedTitle =>
      'Unklar, welches Profil geöffnet werden soll';

  @override
  String startup_haltArbitrationFailedBody(String reopenToContinue) {
    return 'WebLibre rät nicht, welches Profil verwendet werden soll. $reopenToContinue';
  }

  @override
  String get startup_tryAgain => 'Erneut versuchen';

  @override
  String get startup_tryingAgain => 'Neuer Versuch …';

  @override
  String get startup_closeWebLibre => 'WebLibre schließen';

  @override
  String get startup_technicalDetails => 'Technische Details';

  @override
  String get startup_copyDetails => 'Details kopieren';

  @override
  String get startup_maintenanceFinishingInterrupted =>
      'Durch einen Neustart unterbrochene Arbeiten werden abgeschlossen …';

  @override
  String get startup_maintenanceNotRunnableUnsupported =>
      'Diese Aufgabe wurde von einer neueren WebLibre-Version erstellt und kann hier nicht ausgeführt werden.';

  @override
  String get startup_maintenanceNotRunnableNoDestination =>
      'Für diese Sicherung ist kein Zielordner hinterlegt.';

  @override
  String get startup_maintenanceNotRunnableNoBackupFile =>
      'Für diese Wiederherstellung ist keine Sicherungsdatei hinterlegt.';

  @override
  String get startup_maintenanceNotRunnableRestoreHere =>
      'WebLibre kann von diesem Startbildschirm aus nicht wiederherstellen.';

  @override
  String get startup_maintenanceNotRunnableDeleteHere =>
      'WebLibre kann von diesem Startbildschirm aus kein Profil löschen.';

  @override
  String get startup_maintenanceRecoveredRestore =>
      'Eine unterbrochene Wiederherstellung wurde abgeschlossen.';

  @override
  String get startup_maintenanceRecoveredRestoreRolledBack =>
      'Eine unterbrochene Wiederherstellung wurde rückgängig gemacht. Das Profil blieb unverändert.';

  @override
  String get startup_maintenanceRecoveredRestoreReconciled =>
      'Eine unterbrochene Wiederherstellung wurde bereinigt. Im Profil prüfen, ob die Sicherung übernommen wurde.';

  @override
  String get startup_maintenanceRecoveredDeletion =>
      'Eine unterbrochene Löschung wurde abgeschlossen.';

  @override
  String get startup_maintenanceTaskDidNotFinish =>
      'Der Vorgang wurde nicht abgeschlossen.';

  @override
  String startup_maintenanceLeaseLost(
    String nothingChanged,
    String reopenToContinue,
  ) {
    return 'WebLibre kann nicht mehr sicher an diesem Profil arbeiten. $nothingChanged $reopenToContinue';
  }

  @override
  String startup_maintenanceTaskCancelled(String task) {
    return 'Abgebrochen: $task';
  }

  @override
  String get startup_maintenanceEvidenceDiscarded =>
      'Der Eintrag der Unterbrechung wurde verworfen.';

  @override
  String get startup_maintenanceEvidenceDiscardedKept =>
      'Der Eintrag der Unterbrechung wurde verworfen. WebLibre konnte nicht erkennen, zu welchem Profil die gespeicherten Daten gehörten, und hat sie deshalb auf dem Gerät behalten statt sie zu entfernen.';

  @override
  String startup_maintenanceWrongPassword(String nothingChanged) {
    return 'Mit diesem Passwort ließ sich die Sicherungsdatei nicht öffnen. Passwort prüfen und erneut versuchen. $nothingChanged';
  }

  @override
  String startup_maintenanceUnreadableArchive(String nothingChanged) {
    return 'Mit diesem Passwort ließ sich die Sicherungsdatei nicht öffnen, oder die Datei ist beschädigt. Passwort prüfen und erneut versuchen. $nothingChanged';
  }

  @override
  String startup_maintenanceDamagedArchive(String nothingChanged) {
    return 'Diese Sicherungsdatei ist beschädigt und konnte nicht gelesen werden. $nothingChanged';
  }

  @override
  String startup_maintenanceUnsupportedArchiveVersion(String nothingChanged) {
    return 'Diese Sicherungsdatei wurde von einer neueren WebLibre-Version erstellt und kann hier nicht gelesen werden. $nothingChanged';
  }

  @override
  String startup_maintenanceNotEnoughStorageWithFree(
    String required,
    String free,
    String nothingChanged,
  ) {
    return 'Nicht genügend freier Speicher: Benötigt werden etwa $required, verfügbar sind nur $free. $nothingChanged';
  }

  @override
  String startup_maintenanceNotEnoughStorageKnown(
    String required,
    String nothingChanged,
  ) {
    return 'Nicht genügend freier Speicher: Benötigt werden etwa $required. $nothingChanged';
  }

  @override
  String startup_maintenanceNotEnoughStorageUnknown(String nothingChanged) {
    return 'Dafür ist nicht genügend freier Speicher vorhanden. $nothingChanged';
  }

  @override
  String startup_maintenanceBackupFolderUnavailable(String nothingChanged) {
    return 'Die Sicherung konnte nicht in den Ordner geschrieben werden. Ordner erneut auswählen und noch einmal versuchen. $nothingChanged';
  }

  @override
  String get startup_maintenanceProfileNoLongerExists =>
      'Dieses Profil existiert nicht mehr.';

  @override
  String get startup_maintenanceRestoreEvidenceUnresolved =>
      'Ein früherer Versuch dieser Wiederherstellung hat einen Eintrag hinterlassen, der noch nicht geklärt ist.';

  @override
  String get startup_maintenanceRestoreWrongProfile =>
      'Diese Sicherung passt nicht zu dem Profil, das ersetzt werden sollte.';

  @override
  String get startup_maintenanceRestoreRejected =>
      'Diese Sicherungsdatei kann nicht wiederhergestellt werden.';

  @override
  String get startup_maintenanceRestoreIncomplete =>
      'Die Sicherungsdatei ist unvollständig.';

  @override
  String get startup_maintenanceRestoreNoMetadata =>
      'Die Sicherungsdatei enthält keine Profil-Metadaten.';

  @override
  String get startup_maintenanceRestoreMalformedMetadata =>
      'Die Profil-Metadaten der Sicherungsdatei konnten nicht gelesen werden.';

  @override
  String get startup_maintenanceRestoreNoProfileData =>
      'Die Sicherungsdatei enthält keine Profildaten.';

  @override
  String get startup_maintenanceHeadline => 'Profilwartung';

  @override
  String get startup_maintenanceMustFinish =>
      'Diese Aufgabe muss abgeschlossen sein, bevor ein Profil geöffnet werden kann. Solange sie läuft, hält WebLibre das Profil geschlossen.';

  @override
  String get startup_maintenanceNothingLeft =>
      'Es ist nichts mehr abzuschließen.';

  @override
  String get startup_maintenanceCannotReadRecord =>
      'WebLibre hat unterbrochene Profilarbeiten gefunden, kann deren Eintrag aber nicht lesen.';

  @override
  String get startup_maintenancePasswordLabel => 'Passwort der Sicherungsdatei';

  @override
  String get startup_maintenancePasswordRejected =>
      'Mit diesem Passwort ließ sich die Sicherungsdatei nicht öffnen';

  @override
  String get startup_maintenancePasswordHelperRequiredBackup =>
      'Erforderlich. Es wird zum Wiederherstellen der Sicherung benötigt und nirgends gespeichert.';

  @override
  String get startup_maintenancePasswordHelperRequiredRestore =>
      'Erforderlich. Das Passwort eingeben, mit dem diese Sicherungsdatei erstellt wurde.';

  @override
  String get startup_maintenancePasswordHelperBackup =>
      'Es wird zum Wiederherstellen der Sicherung benötigt und nirgends gespeichert.';

  @override
  String get startup_maintenancePasswordHelperRestore =>
      'Das Passwort, mit dem diese Sicherungsdatei erstellt wurde.';

  @override
  String get startup_maintenanceTryFinishingAgain =>
      'Abschluss erneut versuchen';

  @override
  String get startup_maintenanceDiscardAndContinueBlocked =>
      'Eintrag verwerfen und fortfahren';

  @override
  String get startup_maintenanceDiscardAndContinueNoTasks =>
      'Eintrag verwerfen und fortfahren';

  @override
  String get startup_maintenanceOpenWebLibreRetry => 'WebLibre öffnen';

  @override
  String get startup_maintenanceOpenWebLibre => 'WebLibre öffnen';

  @override
  String get startup_maintenanceTakesSeveralMinutes =>
      'Das kann einige Minuten dauern. WebLibre bitte geöffnet lassen.';

  @override
  String get startup_maintenanceThenAfterThisOne => 'Danach';

  @override
  String get startup_maintenanceSkipForNow => 'Vorerst überspringen';

  @override
  String get startup_maintenanceInterruptedMustFinish =>
      'Dieser Vorgang wurde nach dem Start unterbrochen. Er muss abgeschlossen sein, bevor ein Profil geöffnet werden kann.';

  @override
  String get startup_maintenanceInterruptedFinishFailed =>
      'Dieser Vorgang wurde nach dem Start unterbrochen und konnte nicht abgeschlossen werden. Ein erneuter Start ist erst nach erfolgreichem Abschluss möglich.';

  @override
  String get startup_maintenanceInterruptedUnreadable =>
      'Dieser Vorgang wurde nach dem Start unterbrochen, und WebLibre kann nicht lesen, was er gerade getan hat. Er kann erst wieder ausgeführt werden, wenn dieser Eintrag geklärt ist.';

  @override
  String get startup_maintenanceDiscardDialogTitle =>
      'Eintrag der Unterbrechung verwerfen?';

  @override
  String get startup_maintenanceDiscardDialogContent =>
      'WebLibre kann nicht lesen, was eine Sicherung, Wiederherstellung oder Löschung beim Abbruch gerade getan hat. Wird der Eintrag verworfen, lässt sich der Browser wieder öffnen. Ein Profil, das gerade ersetzt wurde, sollte danach aber geprüft werden.\n\nFehlt das Profil, stellt WebLibre die vor dem Ersetzen gesicherten Daten wieder her. Ist das Profil vorhanden, entfernt WebLibre diese gesicherten Daten. Kann WebLibre nicht erkennen, zu welchem Profil die gesicherten Daten gehören, werden sie behalten statt entfernt.';

  @override
  String get startup_maintenanceDiscardIt => 'Verwerfen';

  @override
  String get startup_maintenanceBackupVerb => 'Jetzt sichern';

  @override
  String get startup_maintenanceBackupRetry => 'Sicherung erneut versuchen';

  @override
  String get startup_maintenanceBackupCancel => 'Diese Sicherung abbrechen';

  @override
  String startup_maintenanceBackupDescribe(String profileName) {
    return '„$profileName“ sichern';
  }

  @override
  String startup_maintenanceBackupConsequence(String secretDataDescription) {
    return 'Schreibt eine verschlüsselte Sicherungsdatei dieses Profils. Sie enthält auch: $secretDataDescription.';
  }

  @override
  String startup_maintenanceBackupActivity(String profileName) {
    return '„$profileName“ wird gepackt …';
  }

  @override
  String startup_maintenanceBackupDescribeDone(String profileName) {
    return '„$profileName“ wurde im ausgewählten Ordner gesichert.';
  }

  @override
  String get startup_maintenanceRestoreOverVerb => 'Jetzt ersetzen';

  @override
  String get startup_maintenanceRestoreOverRetry =>
      'Wiederherstellung erneut versuchen';

  @override
  String get startup_maintenanceRestoreOverCancel =>
      'Diese Wiederherstellung abbrechen';

  @override
  String startup_maintenanceRestoreOverDescribe(String profileName) {
    return '„$profileName“ ersetzen';
  }

  @override
  String startup_maintenanceRestoreOverConsequenceWithRename(
    String signedInFromBackup,
    String olderBackupKeepsCredentials,
    String cannotBeUndone,
  ) {
    return 'Ersetzt alles in diesem Profil durch die Sicherung. $signedInFromBackup $olderBackupKeepsCredentials Außerdem übernimmt es den Namen aus der Sicherung. $cannotBeUndone';
  }

  @override
  String startup_maintenanceRestoreOverConsequencePlain(
    String signedInFromBackup,
    String olderBackupKeepsCredentials,
    String cannotBeUndone,
  ) {
    return 'Ersetzt alles in diesem Profil durch die Sicherung. $signedInFromBackup $olderBackupKeepsCredentials $cannotBeUndone';
  }

  @override
  String startup_maintenanceRestoreOverActivity(String profileName) {
    return '„$profileName“ wird ersetzt …';
  }

  @override
  String startup_maintenanceRestoreOverDescribeDone(String profileName) {
    return '„$profileName“ wurde durch die Sicherung ersetzt.';
  }

  @override
  String get startup_maintenanceDeleteVerb => 'Jetzt löschen';

  @override
  String get startup_maintenanceDeleteRetry => 'Löschung erneut versuchen';

  @override
  String get startup_maintenanceDeleteCancel => 'Diese Löschung abbrechen';

  @override
  String startup_maintenanceDeleteDescribe(String profileName) {
    return '„$profileName“ löschen';
  }

  @override
  String startup_maintenanceDeleteConsequence(
    String profileDataDescription,
    String cannotBeUndone,
  ) {
    return 'Entfernt dieses Profil. Dabei gehen verloren: $profileDataDescription. $cannotBeUndone';
  }

  @override
  String startup_maintenanceDeleteActivity(String profileName) {
    return '„$profileName“ wird gelöscht …';
  }

  @override
  String startup_maintenanceDeleteDescribeDone(String profileName) {
    return '„$profileName“ wurde gelöscht.';
  }

  @override
  String get startup_maintenanceRestoreCloneVerb => 'Nicht ausführbar';

  @override
  String get startup_maintenanceRestoreCloneRetry =>
      'Wiederherstellung erneut versuchen';

  @override
  String get startup_maintenanceRestoreCloneCancel =>
      'Diese Wiederherstellung abbrechen';

  @override
  String startup_maintenanceRestoreCloneDescribe(String profileName) {
    return '„$profileName“ wiederherstellen';
  }

  @override
  String get startup_maintenanceRestoreCloneConsequence =>
      'Diese Wiederherstellung wurde von einer neueren WebLibre-Version erstellt und kann hier nicht ausgeführt werden.';

  @override
  String startup_maintenanceRestoreCloneActivity(String profileName) {
    return '„$profileName“ wird wiederhergestellt …';
  }

  @override
  String startup_maintenanceRestoreCloneDescribeDone(String profileName) {
    return '„$profileName“ wurde wiederhergestellt.';
  }

  @override
  String get startup_maintenanceUnknownVerb => 'Ausführen';

  @override
  String get startup_maintenanceUnknownRetry => 'Aufgabe erneut versuchen';

  @override
  String get startup_maintenanceUnknownCancel => 'Diese Aufgabe abbrechen';

  @override
  String startup_maintenanceUnknownDescribe(String taskId) {
    return 'Unbekannte Aufgabe $taskId';
  }

  @override
  String get startup_maintenanceUnknownConsequence =>
      'Diese Aufgabe wurde von einer neueren WebLibre-Version erstellt und kann nicht ausgeführt werden.';

  @override
  String get startup_maintenanceUnknownActivity => 'Wird ausgeführt …';

  @override
  String get startup_maintenanceUnknownDescribeDone => 'Fertig.';

  @override
  String units_bytes(String value) {
    return '$value B';
  }

  @override
  String units_kilobytes(String value) {
    return '$value KB';
  }

  @override
  String units_megabytes(String value) {
    return '$value MB';
  }

  @override
  String units_milliseconds(String value) {
    return '$value ms';
  }

  @override
  String get failureWidget_defaultTitle => 'Etwas ist schiefgelaufen';

  @override
  String get failureWidget_unknownError => 'Unbekannter Fehler';

  @override
  String get speechToTextButton_serviceNotAvailable =>
      'Spracherkennung ist nicht verfügbar';

  @override
  String get formValidators_urlRequired => 'Eine URL ist erforderlich';

  @override
  String get formValidators_invalidUrl => 'Ungültige URL';

  @override
  String get formValidators_valueRequired => 'Wert erforderlich';

  @override
  String get formValidators_nameRequired => 'Name erforderlich';

  @override
  String get formValidators_nameInvalidCharacters =>
      'Der Name enthält ungültige Zeichen';

  @override
  String uiHelper_findInPageSuggestion(String query) {
    return '„$query“ auf dieser Seite suchen?';
  }

  @override
  String get uiHelper_actionFind => 'Suchen';

  @override
  String uiHelper_openedTabsFromAnotherDevice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tabs von einem anderen Gerät geöffnet',
      one: '1 Tab von einem anderen Gerät geöffnet',
    );
    return '$_temp0';
  }

  @override
  String get uiHelper_navigateBackToCloseTab =>
      'Erneut ZURÜCK drücken, um den aktuellen Tab zu schließen';

  @override
  String get uiHelper_navigateBackToExitApp =>
      'Erneut ZURÜCK drücken, um die App zu beenden';

  @override
  String uiHelper_newTabOpenedInBackgroundNamed(String tabName) {
    return 'Neuer Tab „$tabName“ im Hintergrund geöffnet';
  }

  @override
  String get uiHelper_newTabOpenedInBackground =>
      'Neuer Tab im Hintergrund geöffnet';

  @override
  String get uiHelper_actionShow => 'Anzeigen';

  @override
  String get uiHelper_wantToOpenLinkFromClipboard =>
      'Link aus der Zwischenablage öffnen?';

  @override
  String uiHelper_newTabOpenedNamed(String tabName) {
    return 'Neuer Tab „$tabName“ geöffnet';
  }

  @override
  String get uiHelper_newTabOpened => 'Neuer Tab geöffnet';

  @override
  String get uiHelper_actionSwitch => 'Wechseln';

  @override
  String uiHelper_couldNotLaunchUrl(String url) {
    return 'URL konnte nicht geöffnet werden ($url)';
  }

  @override
  String uiHelper_canNotHandleScheme(String scheme) {
    return '„$scheme“ kann nicht verarbeitet werden';
  }

  @override
  String uiHelper_tabsClosedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tabs geschlossen',
      one: 'Tab geschlossen',
    );
    return '$_temp0';
  }

  @override
  String get uiHelper_closeIsolatedTabsTitle => 'Isolierte Tabs schließen?';

  @override
  String uiHelper_closeIsolatedTabsConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Dadurch werden die Browserdaten von $count isolierten Sitzungen endgültig gelöscht.',
      one:
          'Dadurch werden alle Browserdaten dieser isolierten Sitzung endgültig gelöscht.',
    );
    return '$_temp0';
  }
}
