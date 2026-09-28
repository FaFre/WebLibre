// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_close => 'Close';

  @override
  String get common_save => 'Save';

  @override
  String get common_add => 'Add';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_remove => 'Remove';

  @override
  String get common_clear => 'Clear';

  @override
  String get common_copy => 'Copy';

  @override
  String get common_open => 'Open';

  @override
  String get common_reset => 'Reset';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_done => 'Done';

  @override
  String get common_undo => 'Undo';

  @override
  String get common_dismiss => 'Dismiss';

  @override
  String get common_discard => 'Discard';

  @override
  String get common_showLess => 'Show less';

  @override
  String get common_loading => 'Loading…';

  @override
  String get profileCopy_pickerContents => 'tabs, history and settings';

  @override
  String get profileCopy_dataDescription =>
      'tabs, history, bookmarks, settings and saved site logins';

  @override
  String get profileCopy_secretDataDescription =>
      'WebLibre account sign-in, sync setup and proxy details';

  @override
  String get profileCopy_cannotBeUndone => 'This cannot be undone.';

  @override
  String get profileCopy_nothingChanged => 'Nothing has been changed.';

  @override
  String get profileCopy_restartsToWork => 'WebLibre must restart to do this.';

  @override
  String get profileCopy_asksPasswordAfterRestart =>
      'After restarting, WebLibre asks for the backup file password.';

  @override
  String get profileCopy_reopenToContinue =>
      'Close WebLibre and open it again.';

  @override
  String get profileCopy_signedInFromBackup =>
      'The restored profile uses the WebLibre account from the backup.';

  @override
  String get profileCopy_olderBackupKeepsCredentials =>
      'A backup made by an older version of WebLibre carries none of these, and the profile keeps the ones it has now.';

  @override
  String profileCopy_restartCouldNotBeScheduled(String nothingChanged) {
    return 'WebLibre could not schedule the restart required for this operation. $nothingChanged';
  }

  @override
  String get profileCopy_shortcutsNeedPinningAgain =>
      'Pin home-screen shortcuts again after restore.';

  @override
  String get profileCopy_restartClosesCurrentProfile =>
      'It also closes the profile you are using now, which is not always the profile named here.';

  @override
  String get profileCopy_restartKeepsOtherTabs =>
      'Your other tabs reopen afterward.';

  @override
  String profileCopy_privateTabsClosedByRestart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count private tabs close and their browsing data is cleared.',
      one: '1 private tab closes and its browsing data is cleared.',
    );
    return '$_temp0';
  }

  @override
  String profileCopy_containersClearedByRestart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count containers set to clear data on exit are cleared.',
      one: '1 container set to clear data on exit is cleared.',
    );
    return '$_temp0';
  }

  @override
  String get httpErrorHandler_socketError => 'Could not contact remote service';

  @override
  String get httpErrorHandler_httpError => 'The web request returned an error';

  @override
  String get httpErrorHandler_formatError => 'Bad response format';

  @override
  String get httpErrorHandler_clientError => 'Could not contact remote service';

  @override
  String profileDiscovery_recoveredProfileName(String idFragment) {
    return 'Recovered profile $idFragment';
  }

  @override
  String get about_copyright => 'Copyright © Fabian Freund, 2024-2026';

  @override
  String get about_geckoVersionTitle => 'Gecko Version';

  @override
  String get about_notAvailable => 'N/A';

  @override
  String get about_feedbackTitle => 'Feedback';

  @override
  String get about_donateTitle => 'Donate';

  @override
  String get about_documentationTitle => 'Documentation';

  @override
  String get about_githubTitle => 'GitHub';

  @override
  String get account_screenTitle => 'WebLibre Account';

  @override
  String get account_searchHint => 'Search account settings';

  @override
  String get account_loadFailed => 'Failed to load account';

  @override
  String get account_sectionAccount => 'Account';

  @override
  String get account_sectionSubscription => 'Subscription';

  @override
  String get account_sectionSearchCredits => 'Search Credits';

  @override
  String get account_sectionSettingsSnapshots => 'Settings Snapshots';

  @override
  String get account_sectionPreferencesSnapshots => 'Preferences Snapshots';

  @override
  String get account_sectionEncryptedSync => 'Encrypted Sync';

  @override
  String get account_signInTitle => 'Sign in to WebLibre Account';

  @override
  String get account_signInKeywords => 'sign in, account, authentication';

  @override
  String get account_signInSyncKeyKeywords => 'sync key, reset sync key';

  @override
  String get account_signingInTitle => 'Signing in';

  @override
  String get account_signedInTitle => 'Signed in account';

  @override
  String get account_signInFailedTitle => 'Sign-in failed';

  @override
  String get account_syncAcrossDevicesSubtitle =>
      'Sync your settings across devices';

  @override
  String get account_signingInSubtitle => 'Complete sign-in in your browser';

  @override
  String get account_signedInFallback => 'Signed in';

  @override
  String get account_entrySupporterSubscriptionTitle =>
      'Supporter subscription';

  @override
  String get account_entrySupporterSubscriptionKeywords => 'billing, supporter';

  @override
  String get account_entrySupporterSubscriptionSubtitle =>
      'Status, billing, and subscription management';

  @override
  String get account_entrySearchCreditsTitle => 'Search credits';

  @override
  String get account_entrySearchCreditsKeywords => 'tokens, search pack';

  @override
  String get account_entrySearchCreditsSubtitle =>
      'Credits balance, token issuance, and purchases';

  @override
  String get account_entrySettingsSnapshotsTitle => 'Settings snapshots';

  @override
  String get account_entrySettingsSnapshotsKeywords => 'backups, settings sync';

  @override
  String get account_entrySettingsSnapshotsSubtitle =>
      'Store and restore synced application settings';

  @override
  String get account_entryPreferencesSnapshotsTitle => 'Preferences snapshots';

  @override
  String get account_entryPreferencesSnapshotsKeywords => 'backups, prefs sync';

  @override
  String get account_entryPreferencesSnapshotsSubtitle =>
      'Store and restore synced preference documents';

  @override
  String get account_entrySetupEncryptedSyncTitle => 'Set up encrypted sync';

  @override
  String get account_entrySetupEncryptedSyncKeywords =>
      'sync key, backups, snapshots';

  @override
  String get account_entrySetupEncryptedSyncSubtitle =>
      'Enable end-to-end encrypted sync using your account password';

  @override
  String get account_actionRestore => 'Restore';

  @override
  String get account_actionEditLabel => 'Edit Label';

  @override
  String get account_actionStore => 'Store';

  @override
  String get account_actionTryAgain => 'Try Again';

  @override
  String get account_actionSignOut => 'Sign Out';

  @override
  String get account_actionEnableSync => 'Enable Sync';

  @override
  String get account_adoptTitleUsable =>
      'An older sign-in is still on this device';

  @override
  String get account_adoptTitleUnusable => 'An older sign-in cannot be read';

  @override
  String account_adoptBodyUsable(String name) {
    return 'WebLibre kept a sign-in for $name from before profiles had separate accounts. It is not from a backup, and nothing on this device records which profile it belonged to, so WebLibre will not guess.';
  }

  @override
  String get account_adoptBodyUnusable =>
      'WebLibre kept a sign-in from before profiles had separate accounts, but the saved data is damaged and cannot be used to sign in. Signing in again is the only way back; removing it clears this message.';

  @override
  String get account_adoptRetryError =>
      'That did not work. Check your connection and try again.';

  @override
  String get account_adoptNotMine => 'Not mine';

  @override
  String get account_adoptRemoveIt => 'Remove it';

  @override
  String get account_adoptUseItHere => 'Use it here';

  @override
  String get account_forgetSignInTitle => 'Forget this sign-in?';

  @override
  String account_forgetSignInContent(String name) {
    return 'The saved session for $name is deleted from this device. If it belonged to another profile, you have to sign in again there.';
  }

  @override
  String get account_actionForgetIt => 'Forget it';

  @override
  String get account_previousSignInFallback => 'a previous sign-in';

  @override
  String account_signInAgainAs(String account) {
    return 'Sign in again as $account';
  }

  @override
  String get account_signInExpiredSubtitle =>
      'This profile\'s saved sign-in expired. Your sync key is kept.';

  @override
  String get account_signingInEllipsis => 'Signing in...';

  @override
  String get account_completeSignInInApp => 'Complete sign-in in WebLibre';

  @override
  String get account_tooltipSignOut => 'Sign Out';

  @override
  String get account_signOutConfirmTitle => 'Sign out?';

  @override
  String get account_signOutConfirmContent =>
      'Are you sure you want to sign out of your WebLibre Account?';

  @override
  String get account_resetSyncKeyTitle => 'Reset Sync Key';

  @override
  String get account_resetSyncKeySubtitle =>
      'Re-enter your password if you mistyped it or changed it';

  @override
  String get account_resetSyncKeyConfirmContent =>
      'You will need to re-enter your account password. If your password changed, existing snapshots encrypted with the old password will no longer be decryptable.';

  @override
  String get account_subscriptionLoadFailed => 'Could not load subscription';

  @override
  String get account_checkConnectionRetry =>
      'Check your connection and try again.';

  @override
  String get account_planFallbackSupporter => 'Supporter';

  @override
  String get account_badgeWillNotRenew => 'Will not renew';

  @override
  String get account_badgeActive => 'Active';

  @override
  String account_untilDate(String date) {
    return 'Until $date';
  }

  @override
  String get account_actionManageSubscription => 'Manage Subscription';

  @override
  String get account_badgePaused => 'Paused';

  @override
  String get account_pausedNote =>
      'Your subscription is paused. Resume it from the customer portal to restore access.';

  @override
  String get account_badgePastDue => 'Past due';

  @override
  String get account_pastDueNote =>
      'Payment failed. Update your payment method to keep your subscription active.';

  @override
  String get account_actionUpdatePaymentMethod => 'Update Payment Method';

  @override
  String get account_endedNote =>
      'Your subscription has ended. Renew from the customer portal to continue.';

  @override
  String get account_actionRenewSubscription => 'Renew Subscription';

  @override
  String get account_planSupporterSubscription => 'Supporter Subscription';

  @override
  String get account_subscribeSubtitle => 'Subscribe to unlock sync features';

  @override
  String get account_badgeInactive => 'Inactive';

  @override
  String get account_actionSubscribe => 'Subscribe';

  @override
  String get account_tooltipRefreshStatus => 'Refresh status';

  @override
  String account_subscriptionEndsOn(String date) {
    return 'Your subscription will end on $date';
  }

  @override
  String get account_bannerTitle => 'Support WebLibre';

  @override
  String get account_bannerBody =>
      'Supporter is an optional subscription that funds WebLibre\'s development and provides the features that need a hosted service to work. The browser and its privacy features need no subscription. <learnMore>Learn more</learnMore>.';

  @override
  String get account_featureSearchLabel => 'WebLibre Search';

  @override
  String get account_featureSearchDescription =>
      'A private, ad-free search built into the browser. It blends results from several independent sources, offers tunable search modes, can route over Tor, and lets you preview pages safely — while keeping your searches unlinkable to your account by design.';

  @override
  String get account_featureSyncLabel => 'Encrypted account sync';

  @override
  String get account_featureSyncDescription =>
      'Store and restore your WebLibre settings and preferences across profiles and devices. Everything is encrypted on your device before upload, so only you can read it.';

  @override
  String get account_becomeSupporter => 'Become a Supporter';

  @override
  String get account_syncSetupEnterPassword => 'Please enter your password';

  @override
  String get account_syncSetupPasswordsMismatch => 'Passwords do not match';

  @override
  String get account_syncSetupPasswordMismatchBackup =>
      'Password did not match your existing encrypted backups.';

  @override
  String account_syncSetupFailed(String error) {
    return 'Failed to set up sync: $error';
  }

  @override
  String get account_syncSetupTitle => 'Set Up Encrypted Sync';

  @override
  String get account_syncSetupDescription =>
      'Enter your account password to enable end-to-end encrypted sync. Your data is encrypted on-device before upload — the server never sees your settings.';

  @override
  String get account_fieldAccountPassword => 'Account Password';

  @override
  String get account_fieldConfirmPassword => 'Confirm Password';

  @override
  String account_failedLoadSnapshots(String error) {
    return 'Failed to load snapshots: $error';
  }

  @override
  String account_syncKindStored(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': 'Settings stored',
      'geckoUserJs': 'Gecko Prefs stored',
      'other': 'Snapshot stored',
    });
    return '$_temp0';
  }

  @override
  String account_syncKindSnapshotsTitle(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': 'Settings Snapshots',
      'geckoUserJs': 'Gecko Prefs Snapshots',
      'other': 'Snapshots',
    });
    return '$_temp0';
  }

  @override
  String get account_storeCurrentTitle => 'Store Current';

  @override
  String account_storeCurrentSubtitle(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': 'Encrypt and upload the current settings',
      'geckoUserJs': 'Encrypt and upload the current Gecko prefs',
      'other': 'Encrypt and upload the current data',
    });
    return '$_temp0';
  }

  @override
  String get account_noSnapshotsYet => 'No snapshots stored yet';

  @override
  String account_failedToStore(String error) {
    return 'Failed to store: $error';
  }

  @override
  String account_syncKindRestored(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': 'Settings restored',
      'geckoUserJs': 'Gecko Prefs restored',
      'other': 'Snapshot restored',
    });
    return '$_temp0';
  }

  @override
  String get account_snapshotNotFound => 'Snapshot not found';

  @override
  String get account_decryptionFailed =>
      'Decryption failed — wrong password or data corrupted. Try resetting your sync key.';

  @override
  String account_failedToRestore(String error) {
    return 'Failed to restore: $error';
  }

  @override
  String account_failedUpdateLabel(String error) {
    return 'Failed to update label: $error';
  }

  @override
  String get account_snapshotDeleted => 'Snapshot deleted';

  @override
  String account_failedToDelete(String error) {
    return 'Failed to delete: $error';
  }

  @override
  String get account_untitledSnapshot => 'Untitled';

  @override
  String get account_metaLabel => 'Label';

  @override
  String get account_metaStored => 'Stored';

  @override
  String get account_metaAppVersion => 'App version';

  @override
  String get account_metaDevice => 'Device';

  @override
  String get account_storeSnapshotTitle => 'Store Snapshot';

  @override
  String get account_fieldLabelOptional => 'Label (optional)';

  @override
  String get account_labelHintExample =>
      'e.g. \"Before update\", \"Home setup\"';

  @override
  String get account_fieldLabel => 'Label';

  @override
  String get account_restoreSnapshotTitle => 'Restore Snapshot';

  @override
  String get account_restoreOverwriteWarning =>
      'This will overwrite your current local settings.';

  @override
  String get account_thisSnapshotFallback => 'this snapshot';

  @override
  String get account_deleteSnapshotTitle => 'Delete Snapshot';

  @override
  String account_deleteSnapshotConfirm(String label) {
    return 'Are you sure you want to delete $label?';
  }

  @override
  String get account_authNetworkError =>
      'Network error. Please check your connection and try again.';

  @override
  String get account_authSessionExpiredWithKey =>
      'Your saved sign-in is no longer valid. Sign in again to finish restoring this account — your sync key is kept.';

  @override
  String get account_authSessionExpiredNoKey =>
      'Your saved sign-in is no longer valid. Sign in again to continue.';

  @override
  String get account_authRestoreFailedFallback =>
      'Could not restore your account session. Retrying shortly.';

  @override
  String get account_authSignInTimedOut =>
      'Sign-in timed out. Please try again.';

  @override
  String get account_authSignInOpenPageFailed =>
      'Could not open the sign-in page. Please try again.';

  @override
  String get account_authNoPendingSignIn =>
      'No pending sign-in found. Please start sign-in again.';

  @override
  String get account_authSignInVerificationFailed =>
      'Sign-in could not be verified. Please try again.';

  @override
  String get account_authSignInNotCompleted =>
      'Sign-in could not be completed. Please try again.';

  @override
  String get account_authSignInFailedFallback =>
      'Sign-in failed. Please try again.';

  @override
  String get addons_managerTitle => 'Extensions';

  @override
  String get addons_tabInstalled => 'Installed';

  @override
  String get addons_tabBrowse => 'Browse';

  @override
  String get addons_loadFailedTitle => 'Failed to load extensions';

  @override
  String get addons_noExtensionsFound => 'No extensions found.';

  @override
  String get addons_noneInstalledMessage =>
      'No extensions installed yet.\nBrowse the store to find some.';

  @override
  String get addons_genericTitle => 'Extension';

  @override
  String get addons_notFound => 'This extension could not be found.';

  @override
  String get addons_platformAndroid => 'Android';

  @override
  String get addons_platformDesktop => 'Desktop';

  @override
  String get addons_searchHint => 'Search addons.mozilla.org';

  @override
  String get addons_desktopCompatibilityWarning =>
      'Desktop extensions are not reviewed for mobile. Some may not work, may crash, or may behave unexpectedly on Android.';

  @override
  String get addons_actionInstall => 'Install';

  @override
  String get addons_actionInstallExtension => 'Install Extension';

  @override
  String get addons_actionInstallFromFile => 'Install from file';

  @override
  String get addons_actionViewPermissions => 'View Permissions';

  @override
  String get addons_actionRemoveExtension => 'Remove Extension';

  @override
  String get addons_actionNotNow => 'Not now';

  @override
  String get addons_actionUpdate => 'Update';

  @override
  String get addons_actionCheckForUpdates => 'Check for updates';

  @override
  String get addons_actionCheckForUpdatesButton => 'Check for Updates';

  @override
  String get addons_actionCheckingForUpdates => 'Checking for Updates';

  @override
  String get addons_actionLearnMore => 'Learn More';

  @override
  String get addons_actionReadMore => 'Read more';

  @override
  String get addons_sectionEnabled => 'Enabled';

  @override
  String get addons_sectionDisabled => 'Disabled';

  @override
  String get addons_sectionUnsupported => 'Unsupported';

  @override
  String get addons_sectionDetails => 'Details';

  @override
  String get addons_sectionDescription => 'Description';

  @override
  String get addons_sectionManagement => 'Management';

  @override
  String get addons_sectionUpdates => 'Updates';

  @override
  String get addons_sectionAboutExtension => 'About this extension';

  @override
  String get addons_sectionTechnicalPermissions => 'Technical permissions';

  @override
  String get addons_sectionMoreInformation => 'More information';

  @override
  String get addons_requiredDataCollectionTitle => 'Required Data Collection';

  @override
  String get addons_tooltipRemoveExtension => 'Remove extension';

  @override
  String addons_extensionRemoved(String name) {
    return '$name removed';
  }

  @override
  String addons_extensionInstalled(String name) {
    return '$name installed';
  }

  @override
  String addons_installFailed(String error) {
    return 'Install failed: $error';
  }

  @override
  String get addons_updateChecksStarted =>
      'Background update checks started for installed extensions';

  @override
  String get addons_statusInstalled => 'Installed';

  @override
  String get addons_statusDisabled => 'Disabled';

  @override
  String get addons_statusAvailable => 'Available';

  @override
  String get addons_chipPrivateBrowsing => 'Private Browsing';

  @override
  String get addons_chipRecommended => 'Recommended';

  @override
  String get addons_removeConfirmTitle => 'Remove extension?';

  @override
  String addons_removeConfirmContent(String name) {
    return 'Remove $name from WebLibre?';
  }

  @override
  String get addons_autoUpdateGloballyDisabled =>
      'Global automatic updates are disabled.';

  @override
  String get addons_autoUpdateNeedsManualRun =>
      'Run a manual update once and restart the app before automatic updates can be enabled.';

  @override
  String get addons_autoUpdateAllow =>
      'Allow this extension to receive background updates.';

  @override
  String get addons_autoUpdateDisabledForExtension =>
      'Background updates are disabled for this extension.';

  @override
  String get addons_switchEnabledTitle => 'Enabled';

  @override
  String get addons_switchEnabledSubtitleAllow =>
      'Allow this extension to run in WebLibre.';

  @override
  String get addons_switchEnabledSubtitleCannot =>
      'This extension cannot be safely enabled.';

  @override
  String get addons_switchPrivateBrowsingTitle => 'Allow in Private Browsing';

  @override
  String get addons_switchPrivateBrowsingSubtitle =>
      'Let this extension run in private browsing tabs.';

  @override
  String get addons_switchAutoUpdateTitle => 'Automatic updates';

  @override
  String get addons_switchPinTitle => 'Pin to toolbar';

  @override
  String get addons_switchPinSubtitle =>
      'Show this extension as an icon in the main tab bar.';

  @override
  String get addons_menuExtensionSettingsTitle => 'Extension Settings';

  @override
  String get addons_menuExtensionSettingsSubtitleTab =>
      'Open the extension options page in a browser tab';

  @override
  String get addons_menuExtensionSettingsSubtitleInline =>
      'Open the extension options page';

  @override
  String get addons_menuFilterListsTitle => 'Filter Lists & Hardenings';

  @override
  String get addons_menuFilterListsSubtitle =>
      'Manage filter lists and apply WebLibre hardenings';

  @override
  String get addons_permissionsTitle => 'Permissions';

  @override
  String addons_updateAvailable(String from, String to) {
    return 'Update available: $from → $to';
  }

  @override
  String get addons_noUpdateAttemptYet =>
      'No recent update attempt information is available yet.';

  @override
  String addons_lastChecked(String date) {
    return 'Last checked: $date';
  }

  @override
  String get addons_noUpdateAvailable => 'No update available';

  @override
  String get addons_noRemoteUpdateSource =>
      'This locally installed extension has no remote update source.';

  @override
  String get addons_updateCheckFailed => 'Failed to start update check.';

  @override
  String get addons_updateAvailableDialogTitle => 'Update available';

  @override
  String addons_updateConfirmContent(String name, String from, String to) {
    return 'Update $name from $from to $to?';
  }

  @override
  String get addons_noDescriptionProvided => 'No description provided.';

  @override
  String get addons_loadingDescription => 'Loading description…';

  @override
  String get addons_fieldAuthor => 'Author';

  @override
  String get addons_fieldVersion => 'Version';

  @override
  String get addons_fieldLastUpdated => 'Last Updated';

  @override
  String get addons_fieldLastUpdatedInfo => 'Last updated';

  @override
  String get addons_fieldHomepage => 'Homepage';

  @override
  String get addons_fieldAddonListing => 'Addon Listing';

  @override
  String get addons_fieldSize => 'Size';

  @override
  String get addons_fieldCategories => 'Categories';

  @override
  String get addons_fieldLicense => 'License';

  @override
  String get addons_fieldSupportSite => 'Support site';

  @override
  String get addons_fieldReviews => 'Reviews';

  @override
  String get addons_fieldPrivacyPolicy => 'Privacy policy';

  @override
  String get addons_linkViewOnAmo => 'View on addons.mozilla.org';

  @override
  String get addons_settingsTitleGeneric => 'Extension Settings';

  @override
  String addons_settingsTitleNamed(String name) {
    return '$name Settings';
  }

  @override
  String addons_settingsLoadFailed(String error) {
    return 'Failed to load extension settings: $error';
  }

  @override
  String get addons_noSettingsPage =>
      'This extension does not expose a settings page.';

  @override
  String get addons_permissionsTitleGeneric => 'Extension Permissions';

  @override
  String addons_permissionsTitleNamed(String name) {
    return '$name Permissions';
  }

  @override
  String addons_permissionsLoadFailed(String error) {
    return 'Failed to load extension permissions: $error';
  }

  @override
  String get addons_noSpecialPermissions => 'No special permissions listed';

  @override
  String get addons_noTranslatedPermissionDetails =>
      'This extension does not currently expose any translated permission details.';

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
      other: '$countString users',
      one: '1 user',
    );
    return '$_temp0';
  }

  @override
  String addons_byAuthor(String name) {
    return 'by $name';
  }

  @override
  String get addons_permGroupRequired => 'Required';

  @override
  String get addons_permGroupWebsites => 'Websites';

  @override
  String get addons_permGroupOptional => 'Optional';

  @override
  String get addons_permGroupDataCollection => 'Data collection';

  @override
  String get addons_dateUnknown => 'Unknown';

  @override
  String get addons_statusUpdatedSuccessfully => 'Updated successfully';

  @override
  String get addons_statusNotInstalled => 'Extension not installed';

  @override
  String addons_updateFailedWithMessage(String message) {
    return 'Update failed: $message';
  }

  @override
  String get addons_updateFailedGeneric => 'Update failed';

  @override
  String get addons_noUpdateChecksRecorded => 'No update checks recorded yet';

  @override
  String get addons_statusBlocklisted =>
      'This extension has been blocklisted and should remain disabled.';

  @override
  String get addons_statusNotCorrectlySigned =>
      'This extension is not correctly signed and cannot be safely enabled.';

  @override
  String get addons_statusIncompatible =>
      'This extension is incompatible with the current app version.';

  @override
  String get addons_statusSoftBlockedEnabled =>
      'This extension is soft-blocked. Use caution while it remains enabled.';

  @override
  String get addons_statusSoftBlockedDisabled =>
      'This extension is soft-blocked, but it can still be re-enabled.';

  @override
  String get addons_statusUnsupported =>
      'This extension is installed, but WebLibre does not currently support it.';

  @override
  String get addons_permissionBookmarks => 'Read and modify bookmarks';

  @override
  String get addons_permissionBrowserSettings =>
      'Read and modify browser settings';

  @override
  String get addons_permissionBrowsingData =>
      'Clear recent browsing history, cookies, and related data';

  @override
  String get addons_permissionClipboardRead => 'Read data you copy and paste';

  @override
  String get addons_permissionClipboardWrite => 'Input data to the clipboard';

  @override
  String get addons_permissionContextualIdentities =>
      'Access and modify container tabs';

  @override
  String get addons_permissionCookies => 'Access cookies for visited sites';

  @override
  String get addons_permissionDownloads =>
      'Download files and read/modify download history';

  @override
  String get addons_permissionDownloadsOpen =>
      'Open files downloaded to your computer';

  @override
  String get addons_permissionFind => 'Read the text of all open tabs';

  @override
  String get addons_permissionGeolocation => 'Access your location';

  @override
  String get addons_permissionHistory => 'Access browsing history';

  @override
  String get addons_permissionManagement =>
      'Monitor extension usage and manage themes';

  @override
  String get addons_permissionNativeMessaging =>
      'Exchange messages with programs other than the browser';

  @override
  String get addons_permissionNotifications => 'Display notifications';

  @override
  String get addons_permissionPkcs11 =>
      'Provide cryptographic authentication services';

  @override
  String get addons_permissionPrivacy => 'Read and modify privacy settings';

  @override
  String get addons_permissionProxy => 'Control browser proxy settings';

  @override
  String get addons_permissionSessions => 'Access recently closed tabs';

  @override
  String get addons_permissionTabs => 'Access browser tabs';

  @override
  String get addons_permissionTabHide => 'Hide and show browser tabs';

  @override
  String get addons_permissionTopSites => 'Access browsing history';

  @override
  String get addons_permissionWebNavigation =>
      'Access browser activity during navigation';

  @override
  String get addons_permissionAllUrls => 'Access your data for all websites';

  @override
  String addons_permissionAccessDataFor(String host) {
    return 'Access your data for $host';
  }

  @override
  String appLinks_bannerTitleNamed(String appName) {
    return 'Open this link in $appName?';
  }

  @override
  String get appLinks_bannerTitleGeneric => 'Open this link in an app?';

  @override
  String appLinks_bannerRememberFor(String scope) {
    return 'Remember for $scope';
  }

  @override
  String get appLinks_bannerStayInBrowser => 'Stay in browser';

  @override
  String get appLinks_bannerOpenApp => 'Open app';

  @override
  String appLinks_dialogTitleNamed(String appName) {
    return 'Open in $appName?';
  }

  @override
  String get appLinks_dialogTitleGeneric => 'Open in another app?';

  @override
  String get appLinks_dialogBody =>
      'This link is handled by an app outside WebLibre.';

  @override
  String appLinks_dialogRememberFor(String scope) {
    return 'Remember my choice for $scope';
  }

  @override
  String get appLinks_warningProtectedContext =>
      'This link is protected here. The app opens its own connection, outside the rules this tab follows.';

  @override
  String get appLinks_warningPrivateTab =>
      'This is a private tab. The app keeps its own history and sign-in state.';

  @override
  String get appLinks_warningWallet =>
      'This link asks a wallet app for credentials. Open it only if you initiated the request.';

  @override
  String appLinks_settingsTitleWithContainer(String containerName) {
    return 'App Links — $containerName';
  }

  @override
  String get appLinks_settingsTitleDefault => 'Container App Links';

  @override
  String get appLinks_settingsIntro =>
      'These settings apply only to this container and fully replace the global app-link settings for its tabs.';

  @override
  String get appLinks_modeAlwaysTitle => 'Always';

  @override
  String get appLinks_modeAlwaysSubtitle =>
      'Always open links in their native apps without asking';

  @override
  String get appLinks_modeAskTitle => 'Ask before opening';

  @override
  String get appLinks_modeAskSubtitle =>
      'Show a prompt before opening links in apps';

  @override
  String get appLinks_modeNeverTitle => 'Never';

  @override
  String get appLinks_modeNeverSubtitle =>
      'Always open links in the browser instead of apps';

  @override
  String get appLinks_rememberedRulesHeader => 'Remembered site rules';

  @override
  String get appLinks_ruleAlwaysOpenSubtitle => 'Always open in the app';

  @override
  String get appLinks_ruleAlwaysKeepSubtitle => 'Always keep in the browser';

  @override
  String get appLinks_removeRuleTooltip => 'Remove rule';

  @override
  String get bangs_menuTitle => 'Bangs';

  @override
  String get bangs_menuManageUserBangs => 'Manage User Bangs';

  @override
  String get bangs_menuSearchBangs => 'Search Bangs';

  @override
  String get bangs_menuBrowseCategories => 'Browse Categories';

  @override
  String get bangs_categoriesTitle => 'Bang Categories';

  @override
  String get bangs_loadCategoriesFailedTitle =>
      'Failed to load Bang Categories';

  @override
  String get bangs_loadBangsFailedTitle => 'Failed to load Bangs';

  @override
  String get bangs_searchHint => 'Search';

  @override
  String get bangs_searchFailedTitle => 'Bang Search failed';

  @override
  String get bangs_userBangsTitle => 'User Bangs';

  @override
  String get bangs_deleteBangTitle => 'Delete Bang';

  @override
  String get bangs_deleteBangConfirm =>
      'Are you sure you want to delete this Bang?';

  @override
  String get bangs_editTitleCustomize => 'Customize Bang';

  @override
  String get bangs_editTitleNew => 'New Bang';

  @override
  String get bangs_editTitleEdit => 'Edit Bang';

  @override
  String bangs_triggerAlreadyExists(String trigger) {
    return 'A bang with the trigger \"$trigger\" already exists';
  }

  @override
  String get bangs_fieldNameLabel => 'Name';

  @override
  String get bangs_fieldNameHelper =>
      'The name of the website associated with the bang';

  @override
  String get bangs_fieldTriggerLabel => 'Trigger';

  @override
  String get bangs_fieldTriggerHelper =>
      'The specific trigger word or phrase used to invoke the bang.';

  @override
  String get bangs_fieldAdditionalTriggersLabel => 'Additional triggers';

  @override
  String get bangs_fieldAdditionalTriggersHelper =>
      'Other words that invoke this bang, separated by commas or spaces. A leading ! is optional.';

  @override
  String get bangs_fieldUrlLabel => 'URL';

  @override
  String bangs_fieldUrlHelper(String token) {
    return 'The URL template to use when the bang is invoked, where `$token` is replaced by the user\'s query.';
  }

  @override
  String bangs_fieldUrlMissingPlaceholder(String token) {
    return 'Must contain the query placeholder $token';
  }

  @override
  String get bangs_fieldCategoryLabel => 'Category';

  @override
  String get bangs_fieldSubCategoryLabel => 'Subcategory';

  @override
  String get bangs_flagsLabel => 'Flags';

  @override
  String get bangs_flagOpenBasePathTitle => 'Open Base Path';

  @override
  String get bangs_flagOpenBasePathSubtitle =>
      'When a bang is invoked with no query, it opens the base path of the URL (/) instead of the path in the template (e.g., /search)';

  @override
  String get bangs_flagUrlEncodePlaceholderTitle => 'URL Encode Placeholder';

  @override
  String get bangs_flagUrlEncodePlaceholderSubtitle =>
      'URL-encode the search terms. Some sites do not work with encoded terms, so disable this option for those sites.';

  @override
  String get bangs_flagUrlEncodeSpaceToPlusTitle => 'URL Encode Space to Plus';

  @override
  String get bangs_flagUrlEncodeSpaceToPlusSubtitle =>
      'Encode spaces as + instead of %20. Some sites require one format or the other.';

  @override
  String get bangs_tooltipOfficialSearch => 'Official WebLibre search';

  @override
  String get bangs_tooltipCustomizeAsOwn => 'Customize as your own bang';

  @override
  String get bangs_tooltipUnpin => 'Unpin from search providers';

  @override
  String get bangs_tooltipPin => 'Pin to search providers';

  @override
  String bangs_tooltipTriggers(String triggers) {
    return 'Triggers: $triggers';
  }

  @override
  String get browserActions_categoryNavigation => 'Navigation';

  @override
  String get browserActions_categoryScrolling => 'Scrolling';

  @override
  String get browserActions_categoryTabs => 'Tabs';

  @override
  String get browserActions_categoryPage => 'Page';

  @override
  String get browserActions_categoryOpen => 'Open';

  @override
  String get browserActions_categoryApp => 'App';

  @override
  String get browserActions_focusAddressBarTitle => 'Address Bar';

  @override
  String get browserActions_focusAddressBarDescription =>
      'Edit the address or start a search';

  @override
  String get browserActions_backTitle => 'Back';

  @override
  String get browserActions_backDescription => 'Go back in history';

  @override
  String get browserActions_forwardTitle => 'Forward';

  @override
  String get browserActions_forwardDescription => 'Go forward in history';

  @override
  String get browserActions_reloadTitle => 'Reload';

  @override
  String get browserActions_reloadDescription => 'Reload the current page';

  @override
  String get browserActions_hardReloadTitle => 'Hard Reload';

  @override
  String get browserActions_hardReloadDescription =>
      'Reload the current page, bypassing the cache';

  @override
  String get browserActions_scrollTopTitle => 'Scroll to Top';

  @override
  String get browserActions_scrollTopDescription =>
      'Jump to the top of the page';

  @override
  String get browserActions_scrollBottomTitle => 'Scroll to Bottom';

  @override
  String get browserActions_scrollBottomDescription =>
      'Jump to the bottom of the page';

  @override
  String get browserActions_pageUpTitle => 'Page Up';

  @override
  String get browserActions_pageUpDescription => 'Scroll up by one screen';

  @override
  String get browserActions_pageDownTitle => 'Page Down';

  @override
  String get browserActions_pageDownDescription => 'Scroll down by one screen';

  @override
  String get browserActions_newTabTitle => 'New Tab';

  @override
  String get browserActions_newTabDescription => 'Open a new tab';

  @override
  String get browserActions_newPrivateTabTitle => 'New Private Tab';

  @override
  String get browserActions_newPrivateTabDescription =>
      'Open a new private tab';

  @override
  String get browserActions_closeTabTitle => 'Close Tab';

  @override
  String get browserActions_closeTabDescription => 'Close the current tab';

  @override
  String get browserActions_reopenClosedTabTitle => 'Reopen Closed Tab';

  @override
  String get browserActions_reopenClosedTabDescription =>
      'Bring back the most recently closed tab';

  @override
  String get browserActions_duplicateTabTitle => 'Duplicate Tab';

  @override
  String get browserActions_duplicateTabDescription =>
      'Open a copy of the current tab';

  @override
  String get browserActions_nextTabTitle => 'Next Tab';

  @override
  String get browserActions_nextTabDescription => 'Switch to the next tab';

  @override
  String get browserActions_previousTabTitle => 'Previous Tab';

  @override
  String get browserActions_previousTabDescription =>
      'Switch to the previous tab';

  @override
  String get browserActions_lastUsedTabTitle => 'Last Used Tab';

  @override
  String get browserActions_lastUsedTabDescription =>
      'Switch to the previously used tab';

  @override
  String get browserActions_selectTab1Title => 'Tab 1';

  @override
  String get browserActions_selectTab1Description =>
      'Switch to the first tab in the tab bar';

  @override
  String get browserActions_selectTab2Title => 'Tab 2';

  @override
  String get browserActions_selectTab2Description =>
      'Switch to the second tab in the tab bar';

  @override
  String get browserActions_selectTab3Title => 'Tab 3';

  @override
  String get browserActions_selectTab3Description =>
      'Switch to the third tab in the tab bar';

  @override
  String get browserActions_selectTab4Title => 'Tab 4';

  @override
  String get browserActions_selectTab4Description =>
      'Switch to the fourth tab in the tab bar';

  @override
  String get browserActions_selectTab5Title => 'Tab 5';

  @override
  String get browserActions_selectTab5Description =>
      'Switch to the fifth tab in the tab bar';

  @override
  String get browserActions_selectTab6Title => 'Tab 6';

  @override
  String get browserActions_selectTab6Description =>
      'Switch to the sixth tab in the tab bar';

  @override
  String get browserActions_selectTab7Title => 'Tab 7';

  @override
  String get browserActions_selectTab7Description =>
      'Switch to the seventh tab in the tab bar';

  @override
  String get browserActions_selectTab8Title => 'Tab 8';

  @override
  String get browserActions_selectTab8Description =>
      'Switch to the eighth tab in the tab bar';

  @override
  String get browserActions_selectLastTabTitle => 'Last Tab';

  @override
  String get browserActions_selectLastTabDescription =>
      'Switch to the last tab in the tab bar';

  @override
  String get browserActions_togglePinTabTitle => 'Pin / Unpin Tab';

  @override
  String get browserActions_togglePinTabDescription =>
      'Toggle the pinned state of the current tab';

  @override
  String get browserActions_moveTabBackwardTitle => 'Move Tab Back';

  @override
  String get browserActions_moveTabBackwardDescription =>
      'Move the current tab one place toward the start of the tab bar';

  @override
  String get browserActions_moveTabForwardTitle => 'Move Tab Forward';

  @override
  String get browserActions_moveTabForwardDescription =>
      'Move the current tab one place toward the end of the tab bar';

  @override
  String get browserActions_moveTabToStartTitle => 'Move Tab to Start';

  @override
  String get browserActions_moveTabToStartDescription =>
      'Move the current tab to the start of its group in the tab bar';

  @override
  String get browserActions_moveTabToEndTitle => 'Move Tab to End';

  @override
  String get browserActions_moveTabToEndDescription =>
      'Move the current tab to the end of its group in the tab bar';

  @override
  String get browserActions_nextContainerTitle => 'Next Container';

  @override
  String get browserActions_nextContainerDescription =>
      'Switch to the next container and its last used tab';

  @override
  String get browserActions_previousContainerTitle => 'Previous Container';

  @override
  String get browserActions_previousContainerDescription =>
      'Switch to the previous container and its last used tab';

  @override
  String get browserActions_toggleReaderModeTitle => 'Reader Mode';

  @override
  String get browserActions_toggleReaderModeDescription =>
      'Toggle reader mode for the current page';

  @override
  String get browserActions_toggleDesktopModeTitle => 'Desktop Site';

  @override
  String get browserActions_toggleDesktopModeDescription =>
      'Toggle desktop site for the current page';

  @override
  String get browserActions_findInPageTitle => 'Find in Page';

  @override
  String get browserActions_findInPageDescription => 'Open find in page';

  @override
  String get browserActions_findNextTitle => 'Find Next';

  @override
  String get browserActions_findNextDescription =>
      'Jump to the next match of the last search';

  @override
  String get browserActions_findPreviousTitle => 'Find Previous';

  @override
  String get browserActions_findPreviousDescription =>
      'Jump to the previous match of the last search';

  @override
  String get browserActions_increaseFontSizeTitle => 'Increase Font';

  @override
  String get browserActions_increaseFontSizeDescription =>
      'Increase the page font size';

  @override
  String get browserActions_decreaseFontSizeTitle => 'Decrease Font';

  @override
  String get browserActions_decreaseFontSizeDescription =>
      'Decrease the page font size';

  @override
  String get browserActions_resetFontSizeTitle => 'Reset Font';

  @override
  String get browserActions_resetFontSizeDescription =>
      'Restore the default page font size';

  @override
  String get browserActions_toggleBookmarkTitle => 'Bookmark';

  @override
  String get browserActions_toggleBookmarkDescription =>
      'Bookmark or unbookmark the current page';

  @override
  String get browserActions_sharePageTitle => 'Share';

  @override
  String get browserActions_sharePageDescription => 'Share the current page';

  @override
  String get browserActions_translatePageTitle => 'Translate';

  @override
  String get browserActions_translatePageDescription =>
      'Open the page translation sheet';

  @override
  String get browserActions_printPageTitle => 'Print';

  @override
  String get browserActions_printPageDescription => 'Print the current page';

  @override
  String get browserActions_showHomeTitle => 'Home';

  @override
  String get browserActions_showHomeDescription => 'Open the home screen';

  @override
  String get browserActions_showHistoryTitle => 'History';

  @override
  String get browserActions_showHistoryDescription => 'Open browsing history';

  @override
  String get browserActions_showBookmarksTitle => 'Bookmarks';

  @override
  String get browserActions_showBookmarksDescription => 'Open bookmarks';

  @override
  String get browserActions_showContainersTitle => 'Containers';

  @override
  String get browserActions_showContainersDescription =>
      'Open the container list';

  @override
  String get browserActions_showTabViewTitle => 'Tab View';

  @override
  String get browserActions_showTabViewDescription => 'Open the tab overview';

  @override
  String get browserActions_showDownloadsTitle => 'Downloads';

  @override
  String get browserActions_showDownloadsDescription => 'Open downloads';

  @override
  String get browserActions_showAddonsTitle => 'Add-ons';

  @override
  String get browserActions_showAddonsDescription => 'Manage extensions';

  @override
  String get browserActions_openSettingsTitle => 'Settings';

  @override
  String get browserActions_openSettingsDescription => 'Open settings';

  @override
  String get browserActions_showKeyboardShortcutsTitle => 'Keyboard Shortcuts';

  @override
  String get browserActions_showKeyboardShortcutsDescription =>
      'List the keys that run browser actions';

  @override
  String get browserActions_toggleTabBarTitle => 'Hide / Show Tab Bar';

  @override
  String get browserActions_toggleTabBarDescription =>
      'Hide the tab bar, or bring it back';

  @override
  String get browserActions_clearBrowsingDataTitle => 'Clear Browsing Data';

  @override
  String get browserActions_clearBrowsingDataDescription =>
      'Choose browsing data to delete';

  @override
  String get browserActions_moveToBackgroundTitle => 'Minimize';

  @override
  String get browserActions_moveToBackgroundDescription =>
      'Send WebLibre to the background';

  @override
  String get browserActions_quitBrowserTitle => 'Quit';

  @override
  String get browserActions_quitBrowserDescription =>
      'Close all tabs and quit WebLibre';

  @override
  String get bookmarks_title => 'Bookmarks';

  @override
  String get bookmarks_filterHint => 'Filter bookmarks...';

  @override
  String get bookmarks_emptyFolder => 'Empty';

  @override
  String get bookmarks_searchHiddenByFoldersOnly =>
      'Search matches bookmarks hidden by \"Folders Only\"';

  @override
  String bookmarks_noSearchMatches(String query) {
    return 'No bookmarks match \"$query\"';
  }

  @override
  String get bookmarks_loadFailedTitle => 'Failed to load bookmarks';

  @override
  String get bookmarks_loadFoldersFailedTitle =>
      'Failed to load bookmark folders';

  @override
  String get bookmarks_folderLabel => 'Folder';

  @override
  String get bookmarks_unnamedFolder => 'Unnamed Folder';

  @override
  String bookmarks_selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_tooltipOpenInBackground => 'Open in background';

  @override
  String get bookmarks_tooltipMoveSelected => 'Move selected';

  @override
  String get bookmarks_tooltipDeleteSelected => 'Delete selected';

  @override
  String get bookmarks_tooltipClearSearch => 'Clear search';

  @override
  String get bookmarks_tooltipSearchBookmarks => 'Search bookmarks';

  @override
  String get bookmarks_tooltipCollapse => 'Collapse';

  @override
  String get bookmarks_tooltipExpand => 'Expand';

  @override
  String get bookmarks_menuAddBookmarkHere => 'Add Bookmark Here';

  @override
  String get bookmarks_menuAddSubfolderHere => 'Add Subfolder Here';

  @override
  String get bookmarks_menuCollapseAll => 'Collapse All';

  @override
  String get bookmarks_menuShowEmptyFolders => 'Show Empty Folders';

  @override
  String get bookmarks_menuHideEmptyFolders => 'Hide Empty Folders';

  @override
  String get bookmarks_menuShowBookmarks => 'Show Bookmarks';

  @override
  String get bookmarks_menuFoldersOnly => 'Folders Only';

  @override
  String get bookmarks_menuVisibility => 'Visibility';

  @override
  String get bookmarks_menuSort => 'Sort';

  @override
  String get bookmarks_menuImport => 'Import';

  @override
  String get bookmarks_menuExport => 'Export';

  @override
  String get bookmarks_formatJson => 'JSON';

  @override
  String get bookmarks_formatHtml => 'HTML';

  @override
  String get bookmarks_actionOpenInNewTab => 'Open in New Tab';

  @override
  String get bookmarks_actionOpenInBackground => 'Open in Background';

  @override
  String get bookmarks_actionShare => 'Share';

  @override
  String get bookmarks_actionMove => 'Move';

  @override
  String get bookmarks_actionFlatten => 'Flatten';

  @override
  String get bookmarks_actionAddSubfolder => 'Add Subfolder';

  @override
  String get bookmarks_actionAddBookmark => 'Add Bookmark';

  @override
  String get bookmarks_actionMerge => 'Merge';

  @override
  String get bookmarks_actionReplace => 'Replace';

  @override
  String get bookmarks_noEntriesSelected => 'No bookmark entries selected';

  @override
  String bookmarks_openedTabsInBackground(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Opened $count tabs in background',
      one: 'Opened 1 tab in background',
    );
    return '$_temp0';
  }

  @override
  String bookmarks_movedItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moved $count items',
      one: 'Moved 1 item',
    );
    return '$_temp0';
  }

  @override
  String bookmarks_deletedItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deleted $count items',
      one: 'Deleted 1 item',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_importFailedToReadFile => 'Failed to read file';

  @override
  String bookmarks_importSuccessCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count bookmarks successfully',
      one: 'Imported 1 bookmark successfully',
    );
    return '$_temp0';
  }

  @override
  String bookmarks_importFailedWithError(String error) {
    return 'Import failed: $error';
  }

  @override
  String get bookmarks_exportDialogTitle => 'Export Bookmarks';

  @override
  String get bookmarks_exportSuccess => 'Bookmarks exported successfully';

  @override
  String bookmarks_exportFailedWithError(String error) {
    return 'Export failed: $error';
  }

  @override
  String get bookmarks_sortDefault => 'Default';

  @override
  String get bookmarks_sortTitleAsc => 'Title A-Z';

  @override
  String get bookmarks_sortTitleDesc => 'Title Z-A';

  @override
  String get bookmarks_sortUrlAsc => 'URL A-Z';

  @override
  String get bookmarks_sortUrlDesc => 'URL Z-A';

  @override
  String get bookmarks_sortDateAddedDesc => 'Newest First';

  @override
  String get bookmarks_sortDateAddedAsc => 'Oldest First';

  @override
  String get bookmarks_deleteBookmarkTitle => 'Delete Bookmark';

  @override
  String get bookmarks_deleteBookmarkContent =>
      'Are you sure you want to delete this bookmark?';

  @override
  String get bookmarks_deleteFolderTitle => 'Delete Folder';

  @override
  String get bookmarks_deleteFolderConfirmUnknown =>
      'Are you sure you want to delete this folder, including all its bookmarks?';

  @override
  String bookmarks_deleteFolderConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Are you sure you want to delete this folder and its $count bookmarks?',
      one: 'Are you sure you want to delete this folder and its one bookmark?',
      zero: 'Are you sure you want to delete this folder?',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_importDialogTitle => 'Import Bookmarks';

  @override
  String get bookmarks_importDialogContent =>
      'Do you want to erase all existing bookmarks before importing?\n\nChoose \"Replace\" to delete existing bookmarks, or \"Merge\" to keep them.';

  @override
  String get bookmarks_importProgressTitle => 'Importing bookmarks';

  @override
  String get bookmarks_importPhaseParsing => 'Reading the file…';

  @override
  String get bookmarks_importPhaseErasing => 'Removing existing bookmarks…';

  @override
  String bookmarks_importPhaseInsertingProgress(int inserted, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$inserted of $total bookmarks',
      one: '$inserted of 1 bookmark',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_importPhaseInsertingIndeterminate => 'Saving bookmarks…';

  @override
  String get bookmarks_moveToFolderTitle => 'Move to Folder';

  @override
  String get bookmarks_editBookmarkTitle => 'Edit Bookmark';

  @override
  String get bookmarks_createBookmarkTitle => 'Create Bookmark';

  @override
  String get bookmarks_editFolderTitle => 'Edit Folder';

  @override
  String get bookmarks_createFolderTitle => 'Create Folder';

  @override
  String get bookmarks_fieldNameLabel => 'Name';

  @override
  String get bookmarks_fieldUrlLabel => 'URL';

  @override
  String get bookmarks_addToTop => 'Add to top';

  @override
  String get browser_actionSelect => 'Select';

  @override
  String get browser_actionKeep => 'Keep';

  @override
  String get browser_actionInstall => 'Install';

  @override
  String get browser_bookmarkAllTitle => 'Bookmark All Tabs';

  @override
  String get browser_bookmarkAllFastTitle => 'Fast';

  @override
  String get browser_bookmarkAllFastSubtitle =>
      'Automatically add all tabs to a selected folder';

  @override
  String get browser_bookmarkAllDetailedTitle => 'Detailed';

  @override
  String get browser_bookmarkAllDetailedSubtitle =>
      'Review and edit each bookmark individually';

  @override
  String get browser_clearSiteDataTitle => 'Clear Site Data';

  @override
  String browser_clearSiteDataContent(String formattedTypes, String host) {
    return 'This will clear the following data for $host:\n$formattedTypes\n\nYou may need to log in again.';
  }

  @override
  String get browser_contentSelectionExtractedTitle => 'Extracted Content';

  @override
  String get browser_contentSelectionExtractedSubtitle =>
      'Reader-optimized content without navigation and ads';

  @override
  String get browser_contentSelectionFullTitle => 'Full Content';

  @override
  String get browser_contentSelectionFullSubtitle =>
      'Complete page including all elements and structure';

  @override
  String get browser_deleteDataTitle => 'Delete Browsing Data';

  @override
  String get browser_installAddonSheetTitle => 'Install Extension from File';

  @override
  String get browser_installAddonSelectFileButton => 'Select XPI File';

  @override
  String get browser_installAddonNoFileSelected => 'No file selected';

  @override
  String get browser_installAddonPinnedNotice =>
      'Extensions installed from a local XPI stay pinned to that version and will not update automatically.';

  @override
  String get browser_installAddonNotXpiError => 'Please select an .xpi file';

  @override
  String browser_installAddonPickFileFailed(String error) {
    return 'Failed to pick file: $error';
  }

  @override
  String get browser_installAddonInstalledMessage =>
      'Extension installed. Automatic updates are disabled for this local version.';

  @override
  String get browser_installAddonNotSignedError =>
      'This extension is not signed by Mozilla. Enable \"Allow unsigned extensions\" in Extensions settings to install it.';

  @override
  String browser_installAddonInstallFailed(String error) {
    return 'Installation failed: $error';
  }

  @override
  String get browser_keepTabTitle => 'Keep tab?';

  @override
  String get browser_keepTabContent =>
      'Do you want to keep this tab or discard it?';

  @override
  String get browser_qrCodeTitle => 'Share QR Code';

  @override
  String get browser_selectFolderTitle => 'Select folder';

  @override
  String get browser_tabTreeCurrentTabNotInTree =>
      'The current tab is not part of this tree';

  @override
  String get browser_menuManageExtensions => 'Manage extensions';

  @override
  String get browser_menuAddRegularTab => 'Add Regular Tab';

  @override
  String get browser_menuAddChildTab => 'Add Child Tab';

  @override
  String get browser_menuAddPrivateTab => 'Add Private Tab';

  @override
  String get browser_menuAddIsolatedTab => 'Add Isolated Tab';

  @override
  String get browser_fontSizeTitle => 'Text Size';

  @override
  String get browser_fontSizeAutomaticNotice =>
      'Automatic font size is enabled. Disable in Settings to adjust manually.';

  @override
  String get browser_fontSizeResetButton => 'Reset to 100%';

  @override
  String get browser_historyNoPreviousPages => 'No previous pages';

  @override
  String get browser_historyNoForwardPages => 'No forward pages';

  @override
  String get browser_certSandboxedCaptureTitle => 'Sandboxed capture';

  @override
  String get browser_certSandboxedCaptureSubtitle =>
      'The page is served from an offline archive — no live connection.';

  @override
  String get browser_certConnectionNotSecure => 'Connection is not secure';

  @override
  String get browser_certConnectionSecure => 'Connection is secure';

  @override
  String browser_certVerifiedBy(String issuer) {
    return 'Verified By: $issuer';
  }

  @override
  String get browser_containerFallbackName => 'Container';

  @override
  String get browser_actionEnable => 'Enable';

  @override
  String get browser_closeAllPrivateTabsTitle => 'Close All Private Tabs';

  @override
  String get browser_closeAllPrivateTabsContent =>
      'Are you sure you want to close all displayed private tabs?';

  @override
  String get browser_closeAllTabsTitle => 'Close All Tabs';

  @override
  String get browser_closeAllTabsContent =>
      'Are you sure you want to close all displayed tabs?';

  @override
  String get browser_enableAiTabSuggestionsTitle => 'Enable AI Tab Suggestions';

  @override
  String get browser_enableAiTabSuggestionsContent =>
      'Enabling this feature may require downloading AI models. The download size and progress cannot be determined in advance.\n\nDo you want to continue?';

  @override
  String get browser_tooltipExpandGroup => 'Expand group';

  @override
  String get browser_tooltipCollapseGroup => 'Collapse group';

  @override
  String get browser_searchOrEnterUrl => 'Search or enter URL';

  @override
  String get browser_tabCannotBeMovedHere => 'Tab cannot be moved here';

  @override
  String get browser_quickActionNewTab => 'New Tab';

  @override
  String get browser_quickActionNewPrivateTab => 'New Private Tab';

  @override
  String get browser_quickActionNewIsolatedTab => 'New Isolated Tab';

  @override
  String get browser_shareLink => 'Share Link';

  @override
  String get browser_showQrCode => 'Show QR Code';

  @override
  String get browser_exportAsPdf => 'Export as PDF';

  @override
  String get browser_failedToPrintPage => 'Failed to print page';

  @override
  String get browser_print => 'Print';

  @override
  String get browser_shareScreenshot => 'Share Screenshot';

  @override
  String get browser_exportAsPng => 'Export as PNG';

  @override
  String browser_openInNamedApp(String appName) {
    return 'Open in $appName';
  }

  @override
  String get browser_openInApp => 'Open in App';

  @override
  String get browser_copyAddress => 'Copy Address';

  @override
  String get browser_noTargetDevices => 'No target devices';

  @override
  String browser_sentTabToDevice(String deviceName) {
    return 'Sent tab to $deviceName';
  }

  @override
  String get browser_failedToSendTab => 'Failed to send tab';

  @override
  String get browser_loadingDevices => 'Loading devices...';

  @override
  String get browser_failedToLoadDevices => 'Failed to load devices';

  @override
  String get browser_sendToDevice => 'Send To Device';

  @override
  String get browser_containerMenuNewTab => 'New Tab';

  @override
  String get browser_unpinContainer => 'Unpin Container';

  @override
  String get browser_pinContainer => 'Pin Container';

  @override
  String get browser_closeSubmenuAllTabs => 'All Tabs';

  @override
  String get browser_closeSubmenuPrivateTabs => 'Private Tabs';

  @override
  String get browser_closeSubmenuIsolatedTabs => 'Isolated Tabs';

  @override
  String get browser_closeSubmenuFilteredTabs => 'Filtered Tabs';

  @override
  String get browser_menuCloseTabs => 'Close Tabs';

  @override
  String get browser_menuBookmarkAll => 'Bookmark all';

  @override
  String get browser_menuAssignedSites => 'Assigned Sites…';

  @override
  String get browser_menuClearContainerData => 'Clear Container Data';

  @override
  String get browser_menuEditContainer => 'Edit Container…';

  @override
  String get browser_menuDeleteContainer => 'Delete Container';

  @override
  String browser_bookmarksAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bookmarks added',
      one: '1 bookmark added',
    );
    return '$_temp0';
  }

  @override
  String get browser_containerDataClearedSuccess =>
      'Container data cleared successfully';

  @override
  String browser_containerDataClearedWithTabsClosed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Container data cleared. $count tabs closed.',
      one: 'Container data cleared. 1 tab closed.',
    );
    return '$_temp0';
  }

  @override
  String browser_errorClearingData(String error) {
    return 'Error clearing data: $error';
  }

  @override
  String get browser_appLinksSectionTitle => 'App Links';

  @override
  String get browser_openLinksForThisSite => 'Open links for this site';

  @override
  String get browser_followsTheDefault => 'Follows the default';

  @override
  String get browser_followDefault => 'Follow default';

  @override
  String get browser_openInAppOption => 'Open in app';

  @override
  String get browser_keepInBrowser => 'Keep in browser';

  @override
  String get browser_noAppFoundForSite => 'No app found for this site';

  @override
  String browser_alwaysOpensInApp(String appName) {
    return 'Always opens in $appName';
  }

  @override
  String get browser_theAppFallback => 'the app';

  @override
  String get browser_alwaysStaysInBrowser => 'Always stays in the browser';

  @override
  String get browser_followsDefaultOpensInApps =>
      'Follows the default: opens in apps';

  @override
  String get browser_followsDefaultNoAppFound =>
      'Follows the default: no app found';

  @override
  String get browser_followsDefaultAsksFirst =>
      'Follows the default: asks first';

  @override
  String get browser_followsDefaultStaysInBrowser =>
      'Follows the default: stays in the browser';

  @override
  String get browser_selectDataTypesToClear => 'Select data types to clear';

  @override
  String get browser_cookiesCacheAndSiteData => 'Cookies, cache, and site data';

  @override
  String get browser_dataTypeAuthSessions => 'Auth Sessions';

  @override
  String get browser_dataTypeAuthSessionsSubtitle =>
      'Saved logins, active sessions';

  @override
  String get browser_dataTypeSiteData => 'Site Data';

  @override
  String get browser_dataTypeSiteDataSubtitle =>
      'Offline storage, databases, local files';

  @override
  String get browser_dataTypeCookies => 'Cookies';

  @override
  String get browser_dataTypeCookiesSubtitle =>
      'Login tokens, preferences, tracking data';

  @override
  String get browser_dataTypeCachedFiles => 'Cached Files';

  @override
  String get browser_dataTypeCachedFilesSubtitle =>
      'Images, scripts, stylesheets';

  @override
  String get browser_closeTabAfterClearing => 'Close tab after clearing';

  @override
  String get browser_closeTabAfterClearingSubtitle =>
      'Close this tab once data is cleared';

  @override
  String get browser_clearingEllipsis => 'Clearing...';

  @override
  String get browser_clearNow => 'Clear Now';

  @override
  String get browser_selectAtLeastOneDataType =>
      'Select at least one data type';

  @override
  String get browser_siteDataCleared => 'Site data cleared';

  @override
  String browser_failedToClearSiteData(String error) {
    return 'Failed to clear site data: $error';
  }

  @override
  String get browser_alwaysUseDesktopSite => 'Always use desktop site';

  @override
  String get browser_unavailableOnThisPage => 'Unavailable on this page';

  @override
  String browser_setByRuleFor(String host) {
    return 'Set by a rule for $host';
  }

  @override
  String get browser_siteAlwaysLoadsInDesktopMode =>
      'This site always loads in desktop mode';

  @override
  String get browser_siteFollowsDefaultMode =>
      'This site follows the default mode';

  @override
  String browser_failedToToggleDesktopMode(String error) {
    return 'Failed to toggle desktop mode: $error';
  }

  @override
  String get browser_gesturesTitle => 'Gestures';

  @override
  String get browser_gesturesTurnedOffGlobally =>
      'Gestures are turned off globally';

  @override
  String get browser_gesturesUnavailableOnThisPage =>
      'Gestures are unavailable on this page';

  @override
  String browser_gesturesDisabledByRuleFor(String host) {
    return 'Disabled by a rule for $host';
  }

  @override
  String get browser_gesturesDisabledOnThisSite =>
      'Gestures are disabled on this site';

  @override
  String get browser_gesturesEnabledOnThisSite =>
      'Gestures are enabled on this site';

  @override
  String browser_failedToToggleGestures(String error) {
    return 'Failed to toggle gestures: $error';
  }

  @override
  String browser_errorLoadingPermissions(String error) {
    return 'Error loading permissions: $error';
  }

  @override
  String get browser_permissionsSectionTitle => 'Permissions';

  @override
  String get browser_showAll => 'Show all';

  @override
  String get browser_noPermissionsSetForSite =>
      'No permissions set for this site';

  @override
  String get browser_permissionAsk => 'Ask';

  @override
  String get browser_permissionAllow => 'Allow';

  @override
  String get browser_permissionBlock => 'Block';

  @override
  String get browser_autoplayTitle => 'Autoplay';

  @override
  String get browser_autoplayAllowAll => 'Allow All';

  @override
  String get browser_autoplayBlockAudible => 'Block Audible';

  @override
  String get browser_autoplayBlockAll => 'Block All';

  @override
  String get browser_failedToLoadTrackingProtection =>
      'Failed to load tracking protection';

  @override
  String get browser_enhancedTrackingProtection =>
      'Enhanced Tracking Protection';

  @override
  String get browser_trackersBeingBlocked =>
      'Trackers on this site are being blocked';

  @override
  String get browser_trackersAllowed => 'Trackers on this site are allowed';

  @override
  String browser_failedToToggleTrackingProtection(String error) {
    return 'Failed to toggle tracking protection: $error';
  }

  @override
  String get browser_resizeSidePanel => 'Resize side panel';

  @override
  String get browser_unassignedContainerLabel => 'Unassigned';

  @override
  String get browser_tooltipCloseTab => 'Close tab';

  @override
  String get browser_urlCleaned => 'URL cleaned';

  @override
  String get browser_urlPreviewApplied => 'URL preview applied';

  @override
  String browser_trackingParametersDetected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracking parameters detected',
      one: '1 tracking parameter detected',
    );
    return '$_temp0';
  }

  @override
  String get browser_linkIsClean => 'Link is clean';

  @override
  String get browser_removeTrackingTooltip => 'Remove tracking';

  @override
  String get browser_menuFindInPage => 'Find in Page';

  @override
  String get browser_menuReaderMode => 'Reader Mode';

  @override
  String get browser_menuFetchFeedsOnPage => 'Fetch Feeds on Page';

  @override
  String get browser_menuAddBookmark => 'Add Bookmark';

  @override
  String get browser_cloneRegular => 'Regular';

  @override
  String get browser_clonePrivate => 'Private';

  @override
  String get browser_cloneIsolated => 'Isolated';

  @override
  String get browser_menuCloneTab => 'Clone Tab';

  @override
  String get browser_menuAssignContainer => 'Assign Container';

  @override
  String get browser_menuUrlRelation => 'URL relation';

  @override
  String get browser_menuUnassignUrlRelation => 'Unassign URL relation';

  @override
  String get browser_menuUnassignContainer => 'Unassign Container';

  @override
  String get browser_menuContainerSubmenu => 'Container';

  @override
  String get browser_menuMoveUp => 'Move up';

  @override
  String get browser_menuMoveDown => 'Move down';

  @override
  String get browser_menuReorder => 'Reorder';

  @override
  String get browser_menuShare => 'Share';

  @override
  String get browser_menuCopyAsMarkdown => 'Copy as Markdown';

  @override
  String get browser_markdownCopiedToClipboard =>
      'Markdown copied to clipboard';

  @override
  String get browser_menuExportAsMarkdown => 'Export as Markdown';

  @override
  String get browser_menuExportSubmenu => 'Export';

  @override
  String get browser_menuCloseTab => 'Close Tab';

  @override
  String get browser_menuReload => 'Reload';

  @override
  String get browser_menuDesktopMode => 'Desktop Mode';

  @override
  String get browser_menuAddToHomeScreen => 'Add to Home Screen';

  @override
  String get browser_menuChangeParent => 'Change parent…';

  @override
  String get browser_menuDetachFromParent => 'Detach from parent';

  @override
  String get browser_menuHierarchy => 'Hierarchy';

  @override
  String get browser_pageTranslated => 'Translated';

  @override
  String get browser_menuTranslatePage => 'Translate Page';

  @override
  String get browser_unpinTab => 'Unpin tab';

  @override
  String get browser_pinTab => 'Pin tab';

  @override
  String browser_errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get browser_tabNoLongerExists => 'Tab no longer exists';

  @override
  String get browser_chooseAParentTab => 'Choose a parent tab';

  @override
  String get browser_makeStandalone => 'Make standalone';

  @override
  String get browser_detachFromCurrentParent => 'Detach from current parent';

  @override
  String get browser_noCandidateTabsInContainer =>
      'No candidate tabs in this container.';

  @override
  String get browser_clearContainerDataIntro =>
      'This will clear all data for this container:';

  @override
  String get browser_bulletCookies => '• Cookies';

  @override
  String get browser_bulletSiteData => '• Site data';

  @override
  String get browser_bulletCache => '• Cache';

  @override
  String get browser_bulletPermissions => '• Permissions';

  @override
  String browser_tabsWillBeClosedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tabs will be closed.',
      one: '1 tab will be closed.',
    );
    return '$_temp0';
  }

  @override
  String get browser_recreateTabsAfterClearing =>
      'Recreate tabs after clearing';

  @override
  String get browser_actionClearData => 'Clear Data';

  @override
  String get browser_closeFromSameHost => 'Close from Same Host';

  @override
  String get browser_closeTabAndDescendants => 'Close Tab and Descendants';

  @override
  String get browser_tabUnpinned => 'Tab unpinned';

  @override
  String browser_createdContainerNamed(String containerName) {
    return 'Created container \"$containerName\"';
  }

  @override
  String get browser_newContainerFallback => 'New Container';

  @override
  String get browser_assignedParentTab => 'Assigned parent tab';

  @override
  String get browser_couldNotAssignParentTab => 'Could not assign parent tab';

  @override
  String get browser_dropTabOntoTabTitle => 'Drop tab onto tab';

  @override
  String get browser_chooseHowTabsRelated =>
      'Choose how these tabs should be related.';

  @override
  String get browser_createContainerOption => 'Create container';

  @override
  String get browser_createContainerOptionSubtitle =>
      'Create a new container with both tabs.';

  @override
  String get browser_assignNewParentOption => 'Assign new parent';

  @override
  String get browser_assignNewParentOptionSubtitle =>
      'Make the dropped-on tab the parent.';

  @override
  String get browser_tabReorderingOnlyInDefaultMode =>
      'Tab reordering is only available in default manual mode';

  @override
  String get browser_tooltipSearchInsideTabs => 'Search inside tabs';

  @override
  String get browser_filterTabType => 'Tab Type';

  @override
  String get browser_sortPinnedFirst => 'Sort Pinned First';

  @override
  String get browser_filterSort => 'Sort';

  @override
  String get browser_hierarchicalView => 'Hierarchical View';

  @override
  String get browser_filterDate => 'Filter Date';

  @override
  String get browser_quickInterval => 'Quick Interval';

  @override
  String get browser_resetFilter => 'Reset Filter';

  @override
  String get browser_tooltipFilterAndSort => 'Filter & Sort';

  @override
  String get browser_tooltipChangeViewMode => 'Change view mode';

  @override
  String browser_downloadingAiModelsProgress(int percent) {
    return 'Downloading AI models ($percent%)';
  }

  @override
  String get browser_disableAiTabSuggestions => 'Disable AI tab suggestions';

  @override
  String get browser_enableAiTabSuggestionsTooltip =>
      'Enable AI tab suggestions';

  @override
  String get browser_disableReorderingMode => 'Disable reordering mode';

  @override
  String get browser_enableReorderingMode => 'Enable reordering mode';

  @override
  String get browser_reorderingRequiresDefaultManualMode =>
      'Reordering requires default manual mode';

  @override
  String get browser_dragAndDropTabsToReorder =>
      'Drag and drop tabs to reorder them';

  @override
  String get browser_tooltipTabActions => 'Tab actions';

  @override
  String get browser_hintSearchTabs => 'Search tabs';

  @override
  String get browser_noSyncedTabsAvailable => 'No synced tabs available';

  @override
  String browser_failedToLoadSyncedTabs(String error) {
    return 'Failed to load synced tabs: $error';
  }

  @override
  String get browser_translateFromLabel => 'From';

  @override
  String get browser_translateToLabel => 'To';

  @override
  String browser_translationError(String error) {
    return 'Translation error: $error';
  }

  @override
  String get browser_failedToRestorePage => 'Failed to restore the page';

  @override
  String get browser_showOriginal => 'Show Original';

  @override
  String get browser_failedToTranslatePage => 'Failed to translate the page';

  @override
  String get browser_retranslate => 'Retranslate';

  @override
  String get browser_translateAction => 'Translate';

  @override
  String get browser_tabTypeFilterAll => 'All Tabs';

  @override
  String get browser_tabTypeFilterRegular => 'Regular';

  @override
  String get browser_tabTypeFilterPrivate => 'Private';

  @override
  String get browser_tabTypeFilterIsolated => 'Isolated';

  @override
  String get browser_tabSortDefault => 'Default';

  @override
  String get browser_tabSortTitleAsc => 'Title A-Z';

  @override
  String get browser_tabSortTitleDesc => 'Title Z-A';

  @override
  String get browser_tabSortUrlAsc => 'URL A-Z';

  @override
  String get browser_tabSortUrlDesc => 'URL Z-A';

  @override
  String get browser_tabSortNewestFirst => 'Newest First';

  @override
  String get browser_tabSortOldestFirst => 'Oldest First';

  @override
  String get browser_tabIntervalLastHour => 'Last Hour';

  @override
  String get browser_tabIntervalLast3Hours => 'Last 3 Hours';

  @override
  String get browser_tabIntervalLast8Hours => 'Last 8 Hours';

  @override
  String get browser_tabIntervalLastDay => 'Last Day';

  @override
  String get browser_tabIntervalLast3Days => 'Last 3 Days';

  @override
  String get browser_tabIntervalLastWeek => 'Last Week';

  @override
  String get browser_tabIntervalLastMonth => 'Last Month';

  @override
  String get browser_tabsViewModeList => 'List';

  @override
  String get browser_tabsViewModeGrid => 'Grid';

  @override
  String get browser_tabsViewModeTree => 'Tree';

  @override
  String get browser_permissionCamera => 'Camera';

  @override
  String get browser_permissionMicrophone => 'Microphone';

  @override
  String get browser_permissionLocation => 'Location';

  @override
  String get browser_permissionNotification => 'Notifications';

  @override
  String get browser_permissionPersistentStorage => 'Persistent Storage';

  @override
  String get browser_permissionCrossOriginStorage => 'Cross-Origin Storage';

  @override
  String get browser_permissionMediaKeySystem => 'Media Key System (DRM)';

  @override
  String get browser_tabReorderBlockedMessage =>
      'Clear the tab view filter or search to reorder tabs';

  @override
  String get contextualToolbar_tooltipHome => 'Home';

  @override
  String get contextualToolbar_tooltipHideTabBar => 'Hide tab bar';

  @override
  String get contextualToolbar_tooltipClearBrowsingData =>
      'Clear browsing data';

  @override
  String get contextualToolbar_tooltipAddBookmark => 'Add bookmark';

  @override
  String get contextualToolbar_tooltipRemoveBookmark => 'Remove bookmark';

  @override
  String get contextualToolbar_tooltipEnableGestures => 'Enable gestures';

  @override
  String get contextualToolbar_tooltipDisableGestures => 'Disable gestures';

  @override
  String get contextualToolbar_actionHardRefresh => 'Hard Refresh';

  @override
  String get contextualToolbar_actionCloseOthers => 'Close Others';

  @override
  String get contextualToolbar_actionCloseFromSameHost =>
      'Close from Same Host';

  @override
  String get contextualToolbar_actionCloseTabAndDescendants =>
      'Close Tab and Descendants';

  @override
  String get contextualToolbar_actionAddBookmark => 'Add Bookmark';

  @override
  String get contextualToolbar_actionRemoveBookmark => 'Remove Bookmark';

  @override
  String get contextualToolbar_actionCloneAsRegular => 'Clone as Regular';

  @override
  String get contextualToolbar_actionCloneAsPrivate => 'Clone as Private';

  @override
  String get contextualToolbar_actionCloneAsIsolated => 'Clone as Isolated';

  @override
  String get contextualToolbar_bookmarkAdded => 'Bookmark added';

  @override
  String get contextualToolbar_bookmarkRemoved => 'Bookmark removed';

  @override
  String get contextualToolbar_fontSizeAutoAdjustmentHint =>
      'Disable automatic font size in settings to adjust manually';

  @override
  String get contextualToolbar_buttonLabelBack => 'Back';

  @override
  String get contextualToolbar_buttonLabelForward => 'Forward';

  @override
  String get contextualToolbar_buttonLabelHome => 'Home';

  @override
  String get contextualToolbar_buttonLabelHistory => 'History';

  @override
  String get contextualToolbar_buttonLabelBookmarks => 'Bookmarks';

  @override
  String get contextualToolbar_buttonLabelBookmarkToggle => 'Bookmark';

  @override
  String get contextualToolbar_buttonLabelShare => 'Share';

  @override
  String get contextualToolbar_buttonLabelAddTab => 'New Tab';

  @override
  String get contextualToolbar_buttonLabelTabsCount => 'Tabs';

  @override
  String get contextualToolbar_buttonLabelNavigationMenu => 'Menu';

  @override
  String get contextualToolbar_buttonLabelReload => 'Reload';

  @override
  String get contextualToolbar_buttonLabelReaderMode => 'Reader Mode';

  @override
  String get contextualToolbar_buttonLabelDesktop => 'Desktop Site';

  @override
  String get contextualToolbar_buttonLabelTranslation => 'Translate';

  @override
  String get contextualToolbar_buttonLabelFindInPage => 'Find in Page';

  @override
  String get contextualToolbar_buttonLabelCloseTab => 'Close Tab';

  @override
  String get contextualToolbar_buttonLabelInputUrl => 'Address Bar';

  @override
  String get contextualToolbar_buttonLabelQrScan => 'Scan QR Code';

  @override
  String get contextualToolbar_buttonLabelVoiceSearch => 'Voice Search';

  @override
  String get contextualToolbar_buttonLabelDuplicateTab => 'Duplicate Tab';

  @override
  String get contextualToolbar_buttonLabelIncreaseFont => 'Increase Font';

  @override
  String get contextualToolbar_buttonLabelDecreaseFont => 'Decrease Font';

  @override
  String get contextualToolbar_buttonLabelMoveToBackground => 'Background';

  @override
  String get contextualToolbar_buttonLabelToggleGestures => 'Gestures';

  @override
  String get contextualToolbar_buttonLabelHideTabBar => 'Hide Tab Bar';

  @override
  String get contextualToolbar_buttonLabelPageUp => 'Page Up';

  @override
  String get contextualToolbar_buttonLabelPageDown => 'Page Down';

  @override
  String get contextualToolbar_buttonLabelFont => 'Text Size';

  @override
  String get contextualToolbar_buttonLabelExtensionShortcut => 'Extensions';

  @override
  String get contextualToolbar_buttonLabelClearBrowsingData => 'Clear Data';

  @override
  String get contextualToolbar_buttonLabelQuit => 'Quit';

  @override
  String get contextualToolbar_longPressBackHistoryMenu =>
      'History Menu (Previous pages)';

  @override
  String get contextualToolbar_longPressForwardHistoryMenu =>
      'History Menu (Forward pages)';

  @override
  String get contextualToolbar_longPressOpenBookmarks => 'Open Bookmarks';

  @override
  String get contextualToolbar_longPressAddRegularTab => 'Add Regular Tab';

  @override
  String get contextualToolbar_longPressAddChildTab => 'Add Child Tab';

  @override
  String get contextualToolbar_longPressAddPrivateTab => 'Add Private Tab';

  @override
  String get contextualToolbar_longPressAddIsolatedTab => 'Add Isolated Tab';

  @override
  String get contextualToolbar_longPressOpenSettings => 'Open Settings';

  @override
  String get contextualToolbar_longPressHardRefresh =>
      'Hard Refresh (bypass cache)';

  @override
  String get contextualToolbar_longPressShowTranslationOptions =>
      'Show Translation Options';

  @override
  String get contextualToolbar_longPressScrollToTop => 'Scroll to Top';

  @override
  String get contextualToolbar_longPressScrollToBottom => 'Scroll to Bottom';

  @override
  String get contextualToolbar_longPressExtensionsMenu => 'Extensions Menu';

  @override
  String get contextualToolbar_longPressQuitWithoutConfirmation =>
      'Quit without confirmation';

  @override
  String get menu_sectionQuickToggles => 'Quick Toggles';

  @override
  String get menu_sectionPageActions => 'Page Actions';

  @override
  String get menu_sectionExtensions => 'Extensions';

  @override
  String get menu_sectionTabActions => 'Tab Actions';

  @override
  String get menu_sectionQuickLinks => 'Quick Links';

  @override
  String get menu_sectionConnection => 'Connection';

  @override
  String get menu_sectionProfile => 'Profile & App';

  @override
  String get menu_sectionAbout => 'About';

  @override
  String get menu_itemDesktopMode => 'Desktop';

  @override
  String get menu_itemReaderMode => 'Reader';

  @override
  String get menu_itemGestures => 'Gestures';

  @override
  String get menu_itemAddBookmark => 'Add Bookmark';

  @override
  String get menu_itemFindInPage => 'Find in Page';

  @override
  String get menu_itemTranslatePage => 'Translate Page';

  @override
  String get menu_itemAddToHomeScreen => 'Add to Home Screen';

  @override
  String get menu_itemOpenInApp => 'Open in App';

  @override
  String get menu_itemContainers => 'Containers';

  @override
  String get menu_itemManageContainers => 'Manage Containers';

  @override
  String get menu_itemAssignContainer => 'Assign Container';

  @override
  String get menu_itemAssignUrlToContainer => 'Assign URL to Container';

  @override
  String get menu_itemUnassignUrlFromContainer => 'Unassign URL from Container';

  @override
  String get menu_itemUnassignContainer => 'Unassign Container';

  @override
  String get menu_itemShare => 'Share';

  @override
  String get menu_itemCopyAddress => 'Copy Address';

  @override
  String get menu_itemShareScreenshot => 'Share Screenshot';

  @override
  String get menu_itemShareLink => 'Share Link';

  @override
  String get menu_itemSendToDevice => 'Send To Device';

  @override
  String get menu_itemShowQrCode => 'Show QR Code';

  @override
  String get menu_itemMoreDisclosure => 'More';

  @override
  String get menu_itemCloneTab => 'Clone Tab';

  @override
  String get menu_itemCloneRegularTab => 'Regular';

  @override
  String get menu_itemClonePrivateTab => 'Private';

  @override
  String get menu_itemCloneIsolatedTab => 'Isolated';

  @override
  String get menu_itemExport => 'Export';

  @override
  String get menu_itemCopyAsMarkdown => 'Copy as Markdown';

  @override
  String get menu_itemExportAsMarkdown => 'Export as Markdown';

  @override
  String get menu_itemExportAsPdf => 'Export as PDF';

  @override
  String get menu_itemExportAsPng => 'Export as PNG';

  @override
  String get menu_itemPrintPage => 'Print';

  @override
  String get menu_itemPinTopSite => 'Pin to Shortcuts';

  @override
  String get menu_itemFetchFeeds => 'Fetch Feeds';

  @override
  String get menu_itemHistory => 'History';

  @override
  String get menu_itemBookmarks => 'Bookmarks';

  @override
  String get menu_itemDownloads => 'Downloads';

  @override
  String get menu_itemBangs => 'Bangs';

  @override
  String get menu_itemFeeds => 'Feeds';

  @override
  String get menu_itemSmallWeb => 'Small Web';

  @override
  String get menu_itemClearData => 'Clear Data';

  @override
  String get menu_itemProfileSwitch => 'Profile';

  @override
  String get menu_itemSyncNow => 'Sync Now';

  @override
  String get menu_itemAppSettings => 'Settings';

  @override
  String get menu_itemQuitBrowser => 'Quit Browser';

  @override
  String get menu_itemAbout => 'About';

  @override
  String get menu_itemMoreDisclosureDescription =>
      'Folds everything below it behind a \"More\" row';

  @override
  String get menu_itemSendToDeviceDescription =>
      'The devices themselves come from your account';

  @override
  String get menu_reorderHideTooltip => 'Hide';

  @override
  String get menu_reorderShowTooltip => 'Show';

  @override
  String menu_reorderRowsShown(int shown, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$shown of $total rows shown',
      one: '$shown of 1 row shown',
    );
    return '$_temp0';
  }

  @override
  String get menu_reorderDefaultTitle => 'Customize Menu';

  @override
  String get menu_reorderSubtitleSections =>
      'Drag to reorder. Switch a section off to hide it from the menu.';

  @override
  String get menu_reorderSubtitleSectionRows =>
      'Drag to reorder the rows in this section.';

  @override
  String get menu_reorderSubtitleItemRows =>
      'Drag to reorder the rows this one opens.';

  @override
  String get menu_reorderBackTooltip => 'Back to sections';

  @override
  String get menu_reorderResetToDefaults => 'Reset to Defaults';

  @override
  String get menu_customizeMenuButton => 'Customize menu';

  @override
  String get menu_navStop => 'Stop';

  @override
  String get menu_navBack => 'Back';

  @override
  String get menu_navForward => 'Forward';

  @override
  String get menu_navCloseTab => 'Close Tab';

  @override
  String get menu_navReload => 'Reload';

  @override
  String get menu_navCloseOthers => 'Close Others';

  @override
  String get menu_navCloseFromSameHost => 'Close from Same Host';

  @override
  String get menu_navCloseTabAndDescendants => 'Close Tab and Descendants';

  @override
  String get menu_navHardRefresh => 'Hard Refresh';

  @override
  String get menu_profileTapToSwitch => 'Tap to switch profile';

  @override
  String get menu_profileSyncComplete => 'Synchronization complete';

  @override
  String menu_openInApp(String appName) {
    return 'Open in $appName';
  }

  @override
  String get menu_pageTranslated => 'Translated';

  @override
  String get menu_extensionsTitle => 'Extensions';

  @override
  String get menu_extensionFallbackTitle => 'Extension';

  @override
  String get menu_extensionsSettingsTooltip => 'Extension settings';

  @override
  String get menu_extensionsManage => 'Manage Extensions';

  @override
  String get menu_containersExpansionTitle => 'Containers';

  @override
  String get menu_containersManage => 'Manage Containers';

  @override
  String get menu_containersAssign => 'Assign Container';

  @override
  String get menu_containersAssignUrl => 'Assign URL to Container';

  @override
  String get menu_containersUnassignUrl => 'Unassign URL from Container';

  @override
  String get menu_containersUnassign => 'Unassign Container';

  @override
  String get menu_shareExpansionTitle => 'Share';

  @override
  String get menu_shareUrlCleaned => 'URL cleaned';

  @override
  String get menu_shareUrlPreviewApplied => 'URL preview applied';

  @override
  String get menu_shareCopyAddress => 'Copy Address';

  @override
  String get menu_shareScreenshot => 'Share Screenshot';

  @override
  String get menu_shareLink => 'Share Link';

  @override
  String get menu_shareShowQrCode => 'Show QR Code';

  @override
  String get menu_sendToDeviceExpansionTitle => 'Send To Device';

  @override
  String get menu_sendToDeviceNone => 'No target devices';

  @override
  String get menu_sendToDeviceLoading => 'Loading devices...';

  @override
  String get menu_sendToDeviceLoadFailed => 'Failed to load devices';

  @override
  String menu_sendToDeviceSuccess(String deviceName) {
    return 'Sent tab to $deviceName';
  }

  @override
  String get menu_sendToDeviceSendFailed => 'Failed to send tab';

  @override
  String get menu_cloneTabExpansionTitle => 'Clone Tab';

  @override
  String get menu_cloneTypeRegular => 'Regular';

  @override
  String get menu_cloneTypePrivate => 'Private';

  @override
  String get menu_cloneTypeIsolated => 'Isolated';

  @override
  String get menu_exportExpansionTitle => 'Export';

  @override
  String get menu_exportCopyAsMarkdown => 'Copy as Markdown';

  @override
  String get menu_exportAsMarkdown => 'Export as Markdown';

  @override
  String get menu_exportAsPdf => 'Export as PDF';

  @override
  String get menu_exportAsPng => 'Export as PNG';

  @override
  String get menu_exportMarkdownCopied => 'Markdown copied to clipboard';

  @override
  String get menu_exportPrint => 'Print';

  @override
  String get menu_exportPrintFailed => 'Failed to print page';

  @override
  String get menu_pinUnpinFromShortcuts => 'Unpin from Shortcuts';

  @override
  String get menu_pinPinToShortcuts => 'Pin to Shortcuts';

  @override
  String get menu_pinUnpinnedMessage => 'Unpinned from Shortcuts';

  @override
  String get menu_pinPinnedMessage => 'Pinned to Shortcuts';

  @override
  String get menu_pinUpdateFailed => 'Failed to update Shortcuts';

  @override
  String get menu_fetchFeedsTitle => 'Fetch Feeds on Page';

  @override
  String get menu_fetchFeedsNone => 'No Web Feeds Found';

  @override
  String get menu_fetchFeedsAvailable => 'Available Web Feeds';

  @override
  String get menu_fetchFeedsLoading => 'Fetching Web Feeds...';

  @override
  String get menu_connectionTitle => 'Connection';

  @override
  String get menu_connectionRegularTabs => 'Regular tabs';

  @override
  String get menu_connectionPrivateTabs => 'Private tabs';

  @override
  String menu_connectionAllThrough(String proxyTitle) {
    return 'All through $proxyTitle';
  }

  @override
  String get menu_connectionPerContainer => 'Per container';

  @override
  String get menu_connectionPerContainerSubtitle =>
      'Only containers with a proxy assigned are routed';

  @override
  String get menu_connectionDirect => 'Direct';

  @override
  String get menu_connectionPrivateNeverInheritSubtitle =>
      'Private tabs never inherit the global route';

  @override
  String get menu_connectionThisIsolatedTab => 'This isolated tab';

  @override
  String get menu_connectionFollowsContainer => 'Follows its container';

  @override
  String get menu_connectionFollowContainerOption => 'Follow its container';

  @override
  String get menu_connectionFollowContainerOptionSubtitle =>
      'Use the route assigned to this tab\'s container';

  @override
  String get menu_connectionIsolatedDirectSubtitle =>
      'Bypass the route its container would apply';

  @override
  String get menu_connectionThisContainer => 'This container';

  @override
  String get menu_connectionFollowsGlobalRouting => 'Follows global routing';

  @override
  String get menu_connectionContainerFallbackTitle => 'Container';

  @override
  String get menu_connectionFollowGlobalRoutingOption =>
      'Follow global routing';

  @override
  String get menu_connectionFollowGlobalRoutingOptionSubtitle =>
      'Use the same route as regular tabs';

  @override
  String get menu_connectionContainerDirectSubtitle =>
      'Bypass the global proxy for this container';

  @override
  String menu_connectionFailedToChangeRoute(String error) {
    return 'Failed to change route: $error';
  }

  @override
  String menu_connectionProxyError(String error) {
    return 'Proxy error: $error';
  }

  @override
  String menu_connectionNotRoutedByContainer(String container) {
    return 'Not routed by container \"$container\"';
  }

  @override
  String get menu_connectionNotRoutedByTabContainer =>
      'Not routed by this tab\'s container';

  @override
  String get menu_connectionCheckingRouting => 'Checking routing…';

  @override
  String get menu_connectionStartingRouting => 'Starting routing…';

  @override
  String menu_connectionBlockedNotRunning(String proxyTitle) {
    return 'Blocked — $proxyTitle is not running';
  }

  @override
  String menu_connectionThisTabVia(String proxyTitle) {
    return 'This tab: $proxyTitle';
  }

  @override
  String get menu_connectionThisTabDirect => 'This tab: direct connection';

  @override
  String menu_connectionStartProxy(String proxyTitle) {
    return 'Start $proxyTitle';
  }

  @override
  String get menu_connectionProxySettings => 'Proxy Settings';

  @override
  String get menu_connectionUnused => 'Not used by any route';

  @override
  String menu_connectionUsageContainerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count containers',
      one: '1 container',
    );
    return '$_temp0';
  }

  @override
  String menu_connectionUsageIsolatedTabCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count isolated tabs',
      one: '1 isolated tab',
    );
    return '$_temp0';
  }

  @override
  String get menu_connectionUsageBlocked => 'Blocked';

  @override
  String get contextmenu_openInNewTab => 'Open in new tab';

  @override
  String get contextmenu_tooltipOpenInDifferentTabType =>
      'Open in a different tab type';

  @override
  String get contextmenu_newRegularTab => 'New regular tab';

  @override
  String get contextmenu_newPrivateTab => 'New private tab';

  @override
  String get contextmenu_newIsolatedTab => 'New isolated tab';

  @override
  String get contextmenu_openImageInNewTab => 'Open image in new tab';

  @override
  String get contextmenu_openInContainer => 'Open in container';

  @override
  String get contextmenu_selectContainerTitle => 'Select Container';

  @override
  String get contextmenu_loadContainersFailedTitle =>
      'Failed to load containers';

  @override
  String get contextmenu_newContainer => 'New Container';

  @override
  String get contextmenu_openInApp => 'Open in App';

  @override
  String contextmenu_openInAppNamed(String appName) {
    return 'Open in $appName';
  }

  @override
  String get contextmenu_copyLink => 'Copy link';

  @override
  String get contextmenu_copyLinkText => 'Copy link text';

  @override
  String get contextmenu_copyImage => 'Copy image';

  @override
  String get contextmenu_copyImageLocation => 'Copy image location';

  @override
  String get contextmenu_saveFile => 'Save file';

  @override
  String get contextmenu_saveImage => 'Save image';

  @override
  String get contextmenu_shareImage => 'Share image';

  @override
  String get contextmenu_shareEmailAddress => 'Share email address';

  @override
  String get contextmenu_urlCleanedMessage => 'URL cleaned';

  @override
  String get contextmenu_urlPreviewAppliedMessage => 'URL preview applied';

  @override
  String get findInPage_hint => 'Find in Page';

  @override
  String findInPage_matchPosition(int current, int total) {
    return '$current of $total';
  }

  @override
  String get findInPage_noMatches => 'Not found';

  @override
  String get history_titleHistory => 'History';

  @override
  String get history_titleDownloads => 'Downloads';

  @override
  String get history_filterHintHistory => 'Filter history…';

  @override
  String get history_filterHintDownloads => 'Filter downloads…';

  @override
  String history_selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String get history_tooltipClearSearch => 'Clear search';

  @override
  String get history_tooltipSearchHistory => 'Search history';

  @override
  String get history_tooltipSearchDownloads => 'Search downloads';

  @override
  String history_tooltipClearContainerHistory(String container) {
    return 'Clear history for \"$container\"';
  }

  @override
  String get history_filterDate => 'Date';

  @override
  String get history_filterContainer => 'Container';

  @override
  String get history_allContainers => 'All Containers';

  @override
  String get history_unnamedContainer => 'Unnamed Container';

  @override
  String history_containerFilterLabel(String container) {
    return 'Container: $container';
  }

  @override
  String get history_resetFilter => 'Reset Filter';

  @override
  String get history_filterTypeFollowedLinks => 'Followed Links';

  @override
  String get history_filterTypeTypedAddresses => 'Typed Addresses';

  @override
  String get history_filterTypeEmbeddedPageElements => 'Embedded Page Elements';

  @override
  String get history_filterTypePermanentRedirects => 'Permanent Redirects';

  @override
  String get history_filterTypeTemporaryRedirects => 'Temporary Redirects';

  @override
  String get history_filterTypeDownloads => 'Downloads';

  @override
  String get history_filterTypeFrames => 'Frames';

  @override
  String get history_filterTypePageReloads => 'Page Reloads';

  @override
  String get history_filterTypeBookmarks => 'Bookmarks';

  @override
  String get history_visitTypeFollowedLink => 'Followed link';

  @override
  String get history_visitTypeTypedAddress => 'Typed address';

  @override
  String get history_visitTypeEmbeddedPageElement => 'Embedded page element';

  @override
  String get history_visitTypePermanentRedirect => 'Permanent redirect';

  @override
  String get history_visitTypeTemporaryRedirect => 'Temporary redirect';

  @override
  String get history_visitTypeDownload => 'Download';

  @override
  String get history_visitTypeFrame => 'Frame';

  @override
  String get history_visitTypePageReload => 'Page reload';

  @override
  String get history_visitTypeBookmark => 'Bookmark';

  @override
  String get history_clearContainerHistoryTitle => 'Clear Container History';

  @override
  String history_clearContainerHistoryContent(String container) {
    return 'Are you sure you want to clear all history for \"$container\"?';
  }

  @override
  String get history_downloadedFileNotFound => 'Downloaded file not found';

  @override
  String get history_couldNotOpenDownloadedFile =>
      'Could not open downloaded file';

  @override
  String get history_loadHistoryFailedTitle => 'Failed to load history';

  @override
  String get history_loadDownloadsFailedTitle => 'Failed to load downloads';

  @override
  String get history_deleteFileTitle => 'Delete File';

  @override
  String history_deleteFileConfirm(String fileName) {
    return 'Are you sure you want to delete $fileName?';
  }

  @override
  String get history_deleteFileWarning =>
      'This will permanently delete the file from your device.';

  @override
  String get history_deleteFileRememberChoice =>
      'Remember my choice for the remaining files';

  @override
  String get history_deleteFileActionKeep => 'Keep';

  @override
  String get openLinkTools_openLinkTitle => 'Open link';

  @override
  String get openLinkTools_urlCleanedMessage => 'URL cleaned';

  @override
  String get openLinkTools_urlPreviewAppliedMessage => 'URL preview applied';

  @override
  String get openLinkTools_urlBlockedByClearUrls => 'URL blocked by ClearURLs';

  @override
  String openLinkTools_unshortenFailedWithError(String error) {
    return 'Could not unshorten the link: $error';
  }

  @override
  String openLinkTools_unshortenRemainingCalls(int remaining, int limit) {
    return 'Remaining calls: $remaining/$limit';
  }

  @override
  String get openLinkTools_unshortenTileTitle => 'Unshorten';

  @override
  String get openLinkTools_unshortenTileSubtitle => 'Resolve shortened URL';

  @override
  String get openLinkTools_unshortenerInfoTooltip => 'Unshortener info';

  @override
  String openLinkTools_openInAppNamed(String appName) {
    return 'Open in $appName';
  }

  @override
  String get openLinkTools_openInAppGeneric => 'Open in App';

  @override
  String get openLinkTools_openInAppSubtitle => 'Open in an installed app';

  @override
  String get openLinkTools_couldNotOpenInApp => 'Could not open in app';

  @override
  String get openLinkTools_openInNewTabTitle => 'Open in new tab';

  @override
  String get openLinkTools_openInNewTabSubtitle => 'Add to your browser tabs';

  @override
  String get openLinkTools_openInCustomTabTitle => 'Open in custom tab';

  @override
  String get openLinkTools_openInCustomTabSubtitle =>
      'Open in a separate window';

  @override
  String get openLinkTools_unshortenerAttributionTitle =>
      'Unshortener Attribution';

  @override
  String openLinkTools_unshortenerAttributionBody(String service) {
    return 'This module resolves shortened links by sending them to $service. The service checks each link on its servers and saves the redirect for future requests. Avoid sending links that contain private or sensitive data.';
  }

  @override
  String get openLinkTools_unshortenerRateLimitNotice =>
      'The free API is rate limited to 10 requests per hour for new checks.';

  @override
  String openLinkTools_privacyPolicyLabel(String link) {
    return 'Privacy policy: $link';
  }

  @override
  String get openLinkTools_removeTrackingParametersTitle =>
      'Remove Tracking Parameters';

  @override
  String get openLinkTools_removeTrackingParametersSubtitle =>
      'Select parameters to strip from this URL.';

  @override
  String get openLinkTools_referralMarketingBadge => 'Referral marketing';

  @override
  String openLinkTools_selectedForRemovalCount(int selected, int total) {
    return '$selected of $total selected for removal';
  }

  @override
  String get openLinkTools_cleanedUrlLabel => 'Cleaned URL:';

  @override
  String get openLinkTools_restoreDefaultsTitle => 'Restore defaults?';

  @override
  String get openLinkTools_restoreDefaultsContent =>
      'This will reset URL cleaner settings and remove the locally stored catalog.';

  @override
  String get openLinkTools_actionRestore => 'Restore';

  @override
  String get openLinkTools_actionApplyChanges => 'Apply Changes';

  @override
  String openLinkTools_couldNotOpenLink(String url) {
    return 'Could not open link: $url';
  }

  @override
  String get openLinkTools_tileTitleCleaned => 'URL cleaned';

  @override
  String openLinkTools_tileSubtitleRemovedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracking parameters removed',
      one: '1 tracking parameter removed',
    );
    return '$_temp0';
  }

  @override
  String get openLinkTools_tileTitlePartiallyCleaned => 'URL partially cleaned';

  @override
  String openLinkTools_tileSubtitlePartiallyCleaned(int removed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$removed of $total tracking parameters removed',
      one: '$removed of 1 tracking parameter removed',
    );
    return '$_temp0';
  }

  @override
  String get openLinkTools_tileTitleTrackingDetected => 'Tracking detected';

  @override
  String openLinkTools_tileSubtitleFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracking parameters found',
      one: '1 tracking parameter found',
    );
    return '$_temp0';
  }

  @override
  String get openLinkTools_cleanUrlTooltip => 'Clean URL';

  @override
  String get openLinkTools_unshortenerSettingsTitle => 'Unshortener';

  @override
  String get openLinkTools_unshortenerSettingsSubtitle =>
      'Short-link resolution behavior, token configuration, and attribution.';

  @override
  String get openLinkTools_unshortenerEnabledTitle => 'Enable Unshortener';

  @override
  String get openLinkTools_unshortenerEnabledKeywords => 'short links';

  @override
  String get openLinkTools_unshortenerEnabledSubtitle =>
      'Resolve shortened URLs to their destination';

  @override
  String get openLinkTools_descriptionLabel => 'Description';

  @override
  String get openLinkTools_unshortenerDescriptionBody =>
      'This module resolves shortened links by sending them to unshorten.me. The service checks each link on its servers and saves the redirect for future requests. Avoid sending links that contain private or sensitive data.';

  @override
  String get openLinkTools_attributionServiceLabel => 'Service';

  @override
  String get openLinkTools_attributionPrivacyPolicyLabel => 'Privacy policy';

  @override
  String get openLinkTools_apiTokenLabel => 'API Token';

  @override
  String get openLinkTools_apiTokenLabelKeywords => 'token';

  @override
  String get openLinkTools_apiTokenHint => 'Optional token for higher limits';

  @override
  String get openLinkTools_urlCleanerSettingsTitle => 'URL Cleaner';

  @override
  String get openLinkTools_urlCleanerSettingsSubtitle =>
      'URL cleanup behavior, rule catalog updates, and attribution.';

  @override
  String get openLinkTools_urlCleanerDescriptionBody =>
      'This module removes tracking, referrer, and other unnecessary parameters from URLs. It can also resolve common URL redirects offline.';

  @override
  String get openLinkTools_urlCleanerEnabledTitle => 'Enable URL Cleaner';

  @override
  String get openLinkTools_urlCleanerEnabledKeywords => 'clean urls';

  @override
  String get openLinkTools_urlCleanerEnabledSubtitle =>
      'Remove tracking parameters from URLs';

  @override
  String get openLinkTools_autoApplyTitle => 'Auto-apply';

  @override
  String get openLinkTools_autoApplyKeywords => 'auto apply';

  @override
  String get openLinkTools_autoApplySubtitle =>
      'Automatically replace the URL with a cleaned version';

  @override
  String get openLinkTools_allowReferralTitle => 'Allow referral marketing';

  @override
  String get openLinkTools_allowReferralKeywords => 'affiliate, referral';

  @override
  String get openLinkTools_allowReferralSubtitle =>
      'Keep referral and affiliate tracking parameters';

  @override
  String get openLinkTools_autoUpdateCatalogTitle => 'Auto-update catalog';

  @override
  String get openLinkTools_autoUpdateCatalogSubtitle =>
      'Check for rule updates weekly';

  @override
  String get openLinkTools_updateCatalogTitle => 'Update catalog';

  @override
  String get openLinkTools_lastUpdateNotAvailable =>
      'Last update: not available';

  @override
  String openLinkTools_lastUpdateWithDate(String date) {
    return 'Last update: $date';
  }

  @override
  String openLinkTools_lastAutoUpdateWithDate(String date) {
    return 'Last update: $date (auto)';
  }

  @override
  String openLinkTools_lastCheckWithDate(String date) {
    return 'Last check: $date';
  }

  @override
  String get openLinkTools_catalogUpdatedMessage => 'Catalog updated';

  @override
  String openLinkTools_updateFailedWithError(String error) {
    return 'Update failed: $error';
  }

  @override
  String get openLinkTools_restoreDefaultsButtonTitle => 'Restore defaults';

  @override
  String get openLinkTools_restoreDefaultsButtonSubtitle =>
      'Reset to bundled catalog and default settings';

  @override
  String get openLinkTools_clearUrlAttributionText =>
      'This module is based on the ClearURL rules:';

  @override
  String get openLinkTools_urlCleanerOverviewSectionTitle => 'Overview';

  @override
  String get openLinkTools_indexUrlCleanerDescriptionTitle => 'Description';

  @override
  String get openLinkTools_indexUrlCleanerDescriptionKeywords =>
      'tracking parameters, redirects';

  @override
  String get openLinkTools_indexUrlCleanerDescriptionSubtitle =>
      'Tracking parameter removal and offline redirect cleanup';

  @override
  String get openLinkTools_urlCleanerBehaviorSectionTitle => 'Behavior';

  @override
  String get openLinkTools_urlCleanerCatalogSectionTitle => 'Catalog';

  @override
  String get openLinkTools_indexUrlCleanerUpdateCatalogSubtitle =>
      'Fetch the latest URL cleaner rules';

  @override
  String get openLinkTools_urlCleanerAttributionSectionTitle => 'Attribution';

  @override
  String get openLinkTools_indexUrlCleanerAttributionTitle => 'Attribution';

  @override
  String get openLinkTools_indexUrlCleanerAttributionSubtitle =>
      'Credits and source links';

  @override
  String get openLinkTools_unshortenerOverviewSectionTitle => 'Overview';

  @override
  String get openLinkTools_indexUnshortenerDescriptionTitle => 'Description';

  @override
  String get openLinkTools_indexUnshortenerDescriptionKeywords =>
      'short links, redirects';

  @override
  String get openLinkTools_indexUnshortenerDescriptionSubtitle =>
      'Resolve shortened URLs using the unshorten.me service';

  @override
  String get openLinkTools_unshortenerBehaviorSectionTitle => 'Behavior';

  @override
  String get openLinkTools_indexUnshortenerApiTokenSubtitle =>
      'Optional token for higher request limits';

  @override
  String get openLinkTools_unshortenerAttributionSectionTitle => 'Attribution';

  @override
  String get openLinkTools_indexUnshortenerAttributionTitle =>
      'Service attribution';

  @override
  String get openLinkTools_indexUnshortenerAttributionKeywords =>
      'privacy policy, rate limit';

  @override
  String get openLinkTools_indexUnshortenerAttributionSubtitle =>
      'Rate limits, service homepage, and privacy policy';

  @override
  String get pwa_addToHomeScreenTitle => 'Add to Home Screen';

  @override
  String get pwa_nameFieldLabel => 'Name';

  @override
  String get pwa_storageLabel => 'Storage';

  @override
  String get pwa_defaultContainerLabel => 'Container';

  @override
  String get pwa_installAsAppTitle => 'Install as App';

  @override
  String get pwa_installAsAppSubtitle => 'Runs standalone with its own window.';

  @override
  String get pwa_addShortcutTitle => 'Add Shortcut';

  @override
  String get pwa_addShortcutSubtitle =>
      'Opens as a standard tab in the browser.';

  @override
  String get pwa_storageDefaultTitle => 'Default';

  @override
  String get pwa_storageDefaultSubtitle =>
      'Uses the default browser storage (no container).';

  @override
  String pwa_storageContainerTitle(String label) {
    return 'Container \"$label\"';
  }

  @override
  String get pwa_storageContainerSubtitle =>
      'Shares cookies and data with the selected container.';

  @override
  String get pwa_storageInheritIsolatedTitle =>
      'Inherit current isolated context';

  @override
  String get pwa_storageInheritIsolatedSubtitle =>
      'Shares storage with the currently open isolated session.';

  @override
  String get pwa_storageNewIsolatedTitle => 'New isolated context';

  @override
  String get pwa_storageNewIsolatedSubtitle =>
      'Creates a fresh storage jar just for this installation.';

  @override
  String get pwa_defaultWebAppName => 'this web app';

  @override
  String get pwa_defaultSiteName => 'this site';

  @override
  String pwa_addedToHomeScreen(String name) {
    return '$name added to home screen';
  }

  @override
  String pwa_installFailedManifestBacked(String name) {
    return 'Failed to add $name. The site may not support installation.';
  }

  @override
  String pwa_installFailedGeneric(String name) {
    return 'Failed to add $name to home screen';
  }

  @override
  String get pwa_noTabSelected => 'No tab selected. Please try again.';

  @override
  String get search_moduleLabelRecentSearches => 'Recent Searches';

  @override
  String get search_moduleLabelSearchProviders => 'Search Providers';

  @override
  String get search_moduleLabelSearchSuggestions => 'Suggestions';

  @override
  String get search_moduleLabelTabs => 'Tabs';

  @override
  String get search_moduleLabelArticles => 'Articles';

  @override
  String get search_moduleLabelBookmarks => 'Bookmarks';

  @override
  String get search_moduleLabelHistory => 'History (engine)';

  @override
  String get search_moduleLabelLocalHistory => 'Local content';

  @override
  String get search_moduleLabelCombinedHistory => 'History';

  @override
  String get search_moduleLabelPopularSites => 'Popular Sites';

  @override
  String get search_moduleLabelHistoryHighlights => 'History Highlights';

  @override
  String get search_moduleLabelTopSites => 'Shortcuts';

  @override
  String get search_moduleLabelRecentHistory => 'Recent History';

  @override
  String get search_moduleLabelRecentArticles => 'Recent Articles';

  @override
  String get search_moduleLabelRecentTabs => 'Recent Tabs';

  @override
  String get search_moduleLabelContainers => 'Containers';

  @override
  String get search_moduleLabelFrequentBangs => 'Frequent Bangs';

  @override
  String get search_moduleLabelQuote => 'Quote';

  @override
  String get search_moduleLabelQuickActions => 'Quick Actions';

  @override
  String get search_couldNotLoadHistory => 'Could not load history';

  @override
  String get search_couldNotLoadLocalContent => 'Could not load local content';

  @override
  String get search_failedSearchingArticles => 'Article search failed';

  @override
  String get search_contentMatchTooltip => 'Content match';

  @override
  String get search_tabTypeRegular => 'Regular';

  @override
  String get search_tabTypeChild => 'Child';

  @override
  String get search_tabTypePrivate => 'Private';

  @override
  String get search_tabTypeIsolated => 'Isolated';

  @override
  String get search_fillLinkFromClipboard => 'Fill link from clipboard';

  @override
  String get search_actionNewTab => 'New tab';

  @override
  String get search_actionViewTabs => 'View tabs';

  @override
  String get search_actionResumeLastTab => 'Resume last tab';

  @override
  String get search_bangTabAllProviders => 'All Providers';

  @override
  String get search_bangTabSearchOnThisSite => 'Search On This Site';

  @override
  String get search_editShortcutDialogTitle => 'Edit Shortcut';

  @override
  String get search_addShortcut => 'Add shortcut';

  @override
  String get search_titleFieldLabel => 'Title';

  @override
  String get search_urlFieldLabel => 'URL';

  @override
  String get search_titleCannotBeEmpty => 'Title cannot be empty';

  @override
  String get search_urlCannotBeEmpty => 'URL cannot be empty';

  @override
  String get search_enterValidUrl => 'Enter a valid URL';

  @override
  String get search_actionPin => 'Pin';

  @override
  String get search_actionUnpin => 'Unpin';

  @override
  String get search_actionResetFrequency => 'Reset frequency';

  @override
  String get search_actionEditBang => 'Edit bang';

  @override
  String get search_actionCustomizeAsOwnBang => 'Customize as your own bang';

  @override
  String search_resetBangDialogTitle(String triggerName) {
    return 'Reset usage frequency of $triggerName?';
  }

  @override
  String get search_resetBangDialogContent =>
      'This will remove the bang from the quick-select list.';

  @override
  String get search_customizeSectionsButton => 'Customize sections';

  @override
  String get search_customizeSectionsHeading => 'Customize Sections';

  @override
  String get search_resetToDefaults => 'Reset to Defaults';

  @override
  String search_showAllCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show all $count',
    );
    return '$_temp0';
  }

  @override
  String get search_disableReorderingMode => 'Disable reordering mode';

  @override
  String get search_enableReorderingMode => 'Enable reordering mode';

  @override
  String get search_dragDropShortcutsHint =>
      'Drag and drop shortcuts to reorder';

  @override
  String get search_failedReorderShortcut => 'Failed to reorder shortcut';

  @override
  String search_hideAllFromHost(String host) {
    return 'Hide all from $host';
  }

  @override
  String search_pinnedSite(String title) {
    return 'Pinned \"$title\"';
  }

  @override
  String get search_failedPinSite => 'Failed to pin site';

  @override
  String get search_shortcutUpdated => 'Shortcut updated';

  @override
  String get search_failedUpdateShortcut => 'Failed to update shortcut';

  @override
  String search_addedSite(String title) {
    return 'Added \"$title\"';
  }

  @override
  String get search_failedAddShortcut => 'Failed to add shortcut';

  @override
  String search_hidAllShortcutsFromHost(String host) {
    return 'Hid all shortcuts from $host';
  }

  @override
  String search_removedSite(String title) {
    return 'Removed \"$title\"';
  }

  @override
  String get search_failedRemoveShortcut => 'Failed to remove shortcut';

  @override
  String get search_quoteCardTitle => 'A thought for the road';

  @override
  String get search_refreshQuoteTooltip => 'Refresh quote';

  @override
  String get search_quotePlaceholder =>
      'Open a new tab and make this space your own.';

  @override
  String get search_searchFieldLabel => 'Search or enter URL';

  @override
  String get search_invalidAddress => 'Invalid address';

  @override
  String get tabs_actionSelect => 'Select';

  @override
  String get tabs_actionUnselect => 'Unselect';

  @override
  String get tabs_unsavedChangesTitle => 'Unsaved Changes';

  @override
  String get tabs_unsavedChangesConfirm =>
      'You have unsaved changes. Do you want to discard them or save?';

  @override
  String get tabs_deleteContainerTitle => 'Delete Container';

  @override
  String get tabs_deleteContainerConfirm =>
      'Are you sure you want to delete this container? Its tabs will be closed.';

  @override
  String get tabs_deleteContainerAlsoDeleteHistory =>
      'Also delete browsing history';

  @override
  String get tabs_deleteContainerHistoryKeptNote =>
      'When this is unchecked, visits remain in history but are no longer assigned to a container.';

  @override
  String get tabs_deleteContainerButton => 'Delete Container';

  @override
  String get tabs_containersTitle => 'Containers';

  @override
  String get tabs_noContainersYet => 'No containers yet';

  @override
  String get tabs_loadContainersFailedTitle => 'Failed to load Containers';

  @override
  String get tabs_containerFabLabel => 'New Container';

  @override
  String get tabs_untitledContainer => 'Untitled';

  @override
  String get tabs_emptyContainerLabel => 'Empty';

  @override
  String tabs_tabCountChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tabs',
      one: '1 tab',
    );
    return '$_temp0';
  }

  @override
  String get tabs_chipPinned => 'Pinned';

  @override
  String get tabs_chipIsolated => 'Isolated';

  @override
  String get tabs_chipDirect => 'Direct';

  @override
  String get tabs_chipClearOnExit => 'Clears on Exit';

  @override
  String get tabs_chipActive => 'Active';

  @override
  String get tabs_selectContainerTitle => 'Select Container';

  @override
  String get tabs_unassignedTitle => 'Unassigned';

  @override
  String get tabs_unassignedSubtitle => 'Tabs not assigned to a container';

  @override
  String get tabs_draftContainersTitle => 'Suggested Containers';

  @override
  String get tabs_suggestionsFailedTitle => 'Failed to load suggestions';

  @override
  String get tabs_siteAssignmentsTitle => 'Site Assignments';

  @override
  String get tabs_addSiteLabel => 'Add site';

  @override
  String get tabs_addSiteHint => 'example.com or *.example.com';

  @override
  String get tabs_addSiteHelperText =>
      'Match a single site, or use *.example.com to match all its subdomains';

  @override
  String get tabs_urlMustBeProvided => 'A URL must be provided';

  @override
  String get tabs_invalidUrl => 'Invalid URL';

  @override
  String get tabs_siteAlreadyAssigned => 'This site is already assigned';

  @override
  String tabs_siteAlreadyAssignedToNamedContainer(
    String site,
    String containerName,
  ) {
    return '$site is already assigned to \"$containerName\"';
  }

  @override
  String tabs_siteAlreadyAssignedToAnotherContainer(String site) {
    return '$site is already assigned to another container';
  }

  @override
  String get tabs_newContainerTitle => 'New Container';

  @override
  String get tabs_editContainerTitle => 'Edit Container';

  @override
  String get tabs_containerNameHint => 'Container Name';

  @override
  String get tabs_changeColor => 'Change Color';

  @override
  String get tabs_changeIcon => 'Change Icon';

  @override
  String get tabs_sectionDisplay => 'Display';

  @override
  String get tabs_pinContainer => 'Pin Container';

  @override
  String get tabs_pinContainerSubtitle =>
      'Keep this container at the top of the list';

  @override
  String get tabs_wallpaperLabel => 'Wallpaper';

  @override
  String get tabs_wallpaperSelectedSubtitle =>
      'Shown on home while this container is selected';

  @override
  String get tabs_wallpaperDefaultSubtitle =>
      'Uses the wallpaper from settings';

  @override
  String get tabs_wallpaperEmptyDescription =>
      'This container falls back to the wallpaper set in settings.';

  @override
  String get tabs_sectionPrivacySecurity => 'Privacy & Security';

  @override
  String get tabs_cookieIsolation => 'Cookie Isolation';

  @override
  String get tabs_proxyConnectionLabel => 'Proxy Connection';

  @override
  String get tabs_proxyConnectionNone => 'None';

  @override
  String get tabs_bypassGlobalProxy => 'Bypass Global Proxy';

  @override
  String get tabs_bypassGlobalProxySubtitle =>
      'Use the normal connection for this container when global routing is enabled';

  @override
  String get tabs_clearDataOnExit => 'Clear Data on Exit';

  @override
  String get tabs_clearDataOnExitSubtitle =>
      'Clear cookies and site data for this container\'s regular tabs when the app closes. Isolated tabs keep separate data.';

  @override
  String get tabs_excludeFromSearchIndex => 'Exclude from Search Index';

  @override
  String get tabs_excludeFromSearchIndexSubtitle =>
      'Keep pages in this container out of the local search index';

  @override
  String get tabs_excludeFromHistory => 'Exclude from History';

  @override
  String get tabs_excludeFromHistorySubtitle =>
      'Don\'t record new visits from this container\'s tabs, and drop its pages from local search. Existing browsing history is kept.';

  @override
  String get tabs_sectionAssignments => 'Assignments';

  @override
  String get tabs_assignedSites => 'Assigned Sites';

  @override
  String tabs_assignedSitesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rules configured',
      one: '1 rule configured',
    );
    return '$_temp0';
  }

  @override
  String get tabs_assignedSitesEmptySubtitle =>
      'Route matching origins into this container';

  @override
  String get tabs_strictMode => 'Strict Mode';

  @override
  String get tabs_strictModeSubtitle =>
      'Only allow assigned sites to load; block everything else';

  @override
  String get tabs_requiresCookieIsolation =>
      'Requires cookie isolation to be enabled';

  @override
  String get tabs_sectionAppLinks => 'App Links';

  @override
  String get tabs_isolatedAppLinkSettings => 'Isolated App Link Settings';

  @override
  String get tabs_isolatedAppLinkSettingsSubtitle =>
      'Use a separate open-in-app mode and remembered site rules for this container instead of the global settings';

  @override
  String get tabs_appLinkBehavior => 'App Link Behavior';

  @override
  String get tabs_appLinkBehaviorSubtitle =>
      'Configure this container\'s open-in-app mode and remembered sites';

  @override
  String get tabs_selectColorTitle => 'Select Color';

  @override
  String get tabs_customColorTitle => 'Custom Color';

  @override
  String get tabs_hexLabel => 'Hex';

  @override
  String get tabs_hueLabel => 'Hue';

  @override
  String get tabs_saturationLabel => 'Saturation';

  @override
  String get tabs_lightnessLabel => 'Lightness';

  @override
  String get tabs_chooseIconTitle => 'Choose Icon';

  @override
  String tabs_iconCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count MDI icons',
      one: '1 MDI icon',
    );
    return '$_temp0';
  }

  @override
  String get tabs_searchIconsHint => 'Search MDI icons';

  @override
  String get tabs_noIconsFound => 'No icons found.';

  @override
  String get gestures_screenTitle => 'Gestures';

  @override
  String get gestures_builtInGestureKeywords => 'swipe';

  @override
  String get gestures_resetSwipesToDefaultsAction => 'Reset Swipes to Defaults';

  @override
  String get gestures_twoFingerSwipeTitle => 'Two-finger swipe';

  @override
  String get gestures_twoFingerSwipeKeywords => 'container';

  @override
  String get gestures_twoFingerSwipeAction => 'Next or previous container';

  @override
  String get gestures_pinchTitle => 'Pinch';

  @override
  String get gestures_pinchKeywords => 'grid, list, tree, layout';

  @override
  String get gestures_pinchAction => 'Grid, list or tree layout';

  @override
  String get gestures_webPagesSectionTitle => 'Web Pages';

  @override
  String get gestures_drawnGesturesTitle => 'Drawn gestures';

  @override
  String get gestures_drawnGesturesKeywords => 'stroke';

  @override
  String get gestures_drawnGesturesSubtitle =>
      'Draw strokes on a page to run actions';

  @override
  String get gestures_gestureBindingsTitle => 'Gesture bindings';

  @override
  String get gestures_gestureBindingsSubtitle => 'Strokes mapped to actions';

  @override
  String get gestures_behaviorTimingTitle => 'Behavior & timing';

  @override
  String get gestures_behaviorTimingSubtitleShort =>
      'Stroke length, timeout, cooldown';

  @override
  String get gestures_excludedSitesTitle => 'Excluded sites';

  @override
  String get gestures_excludedSitesSubtitle => 'Disable gestures per site';

  @override
  String get gestures_feedbackTitle => 'Feedback';

  @override
  String get gestures_feedbackSubtitleShort => 'Live overlay and suggestions';

  @override
  String get gestures_pullToRefreshTitle => 'Pull to refresh';

  @override
  String get gestures_pullToRefreshKeywords => 'reload';

  @override
  String get gestures_pullToRefreshSubtitle =>
      'Swipe down at the top of a page to reload it';

  @override
  String get gestures_toolbarSectionTitle => 'Toolbar';

  @override
  String get gestures_longPressButtonsTitle => 'Long press on buttons';

  @override
  String get gestures_longPressButtonsSubtitle =>
      'Chosen per button when customizing the toolbar';

  @override
  String get gestures_builtInCannotBeChangedDescription =>
      'Built-in, cannot be changed';

  @override
  String get gestures_doNothingTitle => 'Do nothing';

  @override
  String get gestures_doNothingSubtitle => 'The swipe is ignored';

  @override
  String get gestures_restoreDefaultGesturesTooltip =>
      'Restore default gestures';

  @override
  String get gestures_addGestureButtonLabel => 'Add gesture';

  @override
  String get gestures_restoreDefaultGesturesConfirmTitle =>
      'Restore default gestures?';

  @override
  String get gestures_restoreDefaultGesturesConfirmContent =>
      'Every gesture goes back to its default action. Your changes are lost.';

  @override
  String get gestures_noGesturesAssignedMessage => 'No gestures assigned yet.';

  @override
  String get gestures_replaceExistingGestureTitle =>
      'Replace existing gesture?';

  @override
  String gestures_replaceExistingGestureContent(String action) {
    return 'This stroke is already assigned to \"$action\". Saving will replace that binding.';
  }

  @override
  String get gestures_createGestureTitle => 'Create gesture';

  @override
  String get gestures_editGestureTitle => 'Edit gesture';

  @override
  String get gestures_targetActionLabel => 'Target action';

  @override
  String get gestures_startPositionLabel => 'Start position';

  @override
  String get gestures_fingersLabel => 'Fingers';

  @override
  String get gestures_strokePatternLabel => 'Stroke pattern';

  @override
  String get gestures_drawStrokePatternPlaceholder =>
      'Draw a stroke pattern below';

  @override
  String get gestures_undoLastAction => 'Undo last';

  @override
  String get gestures_replaceGestureButtonLabel => 'Replace gesture';

  @override
  String get gestures_saveGestureButtonLabel => 'Save gesture';

  @override
  String gestures_collisionWarning(String action) {
    return 'Already assigned to \"$action\". Saving replaces it.';
  }

  @override
  String get gestures_chooseActionTitle => 'Choose action';

  @override
  String get gestures_behaviorTimingScreenSubtitle =>
      'Stroke length, timeout, and cooldown.';

  @override
  String get gestures_resetToDefaultsTooltip => 'Reset to defaults';

  @override
  String get gestures_resetBehaviorTimingConfirmTitle =>
      'Reset behavior & timing?';

  @override
  String get gestures_resetBehaviorTimingConfirmContent =>
      'Stroke length, timeout, cooldown and stroke interval will be restored to their defaults. Your gesture bindings and other settings are kept.';

  @override
  String get gestures_minStrokeLengthTitle => 'Minimum stroke length';

  @override
  String get gestures_minStrokeLengthKeywords => 'size, length, sensitivity';

  @override
  String get gestures_timeoutTitle => 'Timeout';

  @override
  String get gestures_timeoutKeywords => 'delay';

  @override
  String get gestures_timeoutDescription =>
      'A stroke is dropped if no new direction is drawn within this time.';

  @override
  String get gestures_cooldownTitle => 'Cooldown';

  @override
  String get gestures_cooldownKeywords => 'interval';

  @override
  String get gestures_cooldownDescription =>
      'Minimum delay between two gestures firing.';

  @override
  String get gestures_strokeIntervalTitle => 'Stroke interval';

  @override
  String get gestures_strokeIntervalKeywords => 'debounce, jitter, accidental';

  @override
  String get gestures_strokeIntervalDescription =>
      'Minimum time between direction changes within one gesture. Faster changes abort the gesture, guarding against accidental triggers.';

  @override
  String get gestures_offLabel => 'Off';

  @override
  String get gestures_excludedSitesDescription =>
      'Gestures are disabled on these sites. Subdomains are included (e.g. \"example.com\" also covers \"m.example.com\").';

  @override
  String get gestures_noSitesExcludedMessage => 'No sites excluded.';

  @override
  String get gestures_feedbackScreenSubtitle =>
      'Live overlay and gesture suggestions.';

  @override
  String get gestures_liveFeedbackTitle => 'Live feedback';

  @override
  String get gestures_liveFeedbackSubtitle =>
      'Show the stroke and its action while you draw';

  @override
  String get gestures_suggestNextTitle => 'Suggest next';

  @override
  String get gestures_suggestNextSubtitle =>
      'Also show the other gestures you can complete';

  @override
  String get gestures_suggestAfterTitle => 'Suggest after';

  @override
  String gestures_strokeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count strokes',
      one: '1 stroke',
    );
    return '$_temp0';
  }

  @override
  String get gestures_suggestAfterDescription =>
      'Number of strokes to draw before suggestions appear.';

  @override
  String get gestures_actionRestore => 'Restore';

  @override
  String get gestures_actionReplace => 'Replace';

  @override
  String get gestures_tabBarSurfaceTitle => 'Tab Bar Swipes';

  @override
  String get gestures_tabBarSurfaceDescription =>
      'Swipes on the tab bar or the side rail';

  @override
  String get gestures_tabViewSurfaceTitle => 'Tab View Swipes';

  @override
  String get gestures_tabViewSurfaceDescription =>
      'Swipes on a tab in the tab list or grid';

  @override
  String get gestures_tabBarSwipeBackwardTitle => 'Swipe left along the bar';

  @override
  String get gestures_tabBarSwipeBackwardDescription =>
      'Swiping up on the side rail does the same';

  @override
  String get gestures_tabBarSwipeForwardTitle => 'Swipe right along the bar';

  @override
  String get gestures_tabBarSwipeForwardDescription =>
      'Swiping down on the side rail does the same';

  @override
  String get gestures_tabBarSwipeOutwardTitle => 'Swipe toward the screen edge';

  @override
  String get gestures_tabBarSwipeOutwardDescription =>
      'Down on a bottom bar, up on a top bar, sideways off a rail';

  @override
  String get gestures_tabBarSwipeInwardTitle =>
      'Swipe away from the screen edge';

  @override
  String get gestures_tabBarSwipeInwardDescription =>
      'Up on a bottom bar, down on a top bar, sideways into the page on a rail';

  @override
  String get gestures_tabSwipeLeftTitle => 'Swipe a tab left';

  @override
  String get gestures_tabSwipeLeftDescription =>
      'Acts on the swiped tab, not the open one';

  @override
  String get gestures_tabSwipeRightTitle => 'Swipe a tab right';

  @override
  String get gestures_tabSwipeRightDescription =>
      'Acts on the swiped tab, not the open one';

  @override
  String get gestures_startPositionAnywhere => 'Anywhere';

  @override
  String get gestures_startPositionLeftEdge => 'Left edge';

  @override
  String get gestures_startPositionRightEdge => 'Right edge';

  @override
  String get gestures_startPositionTopEdge => 'Top edge';

  @override
  String get gestures_startPositionBottomEdge => 'Bottom edge';

  @override
  String get gestures_startPositionLeftHalf => 'Left half';

  @override
  String get gestures_startPositionRightHalf => 'Right half';

  @override
  String get gestures_strokesSectionTitle => 'Strokes';

  @override
  String get gestures_indexMinStrokeLengthSubtitle =>
      'Minimum swipe length recognized as a direction';

  @override
  String get gestures_timingSectionTitle => 'Timing';

  @override
  String get gestures_indexTimeoutSubtitle =>
      'Drop a stroke if no new direction is drawn';

  @override
  String get gestures_indexCooldownSubtitle =>
      'Minimum delay between two gestures firing';

  @override
  String get gestures_indexStrokeIntervalSubtitle =>
      'Reject a gesture when direction changes come too fast';

  @override
  String get gestures_overlaySectionTitle => 'Overlay';

  @override
  String get gestures_indexSuggestAfterSubtitle =>
      'Number of strokes to draw before suggestions appear';

  @override
  String get intentGatekeeper_dialogTitle => 'Open link in WebLibre?';

  @override
  String intentGatekeeper_appIsTryingToOpenLink(
    String appName,
    String browserName,
  ) {
    return '$appName is trying to open a link in $browserName.';
  }

  @override
  String get intentGatekeeper_alwaysAllow => 'Always allow';

  @override
  String get intentGatekeeper_allowOnce => 'Allow once';

  @override
  String get intentGatekeeper_blockOnce => 'Block once';

  @override
  String get intentGatekeeper_alwaysBlock => 'Always block';

  @override
  String get keyboardShortcuts_title => 'Keyboard Shortcuts';

  @override
  String get keyboardShortcuts_searchHint => 'Search actions or keys';

  @override
  String get keyboardShortcuts_noMatchingActions => 'No matching actions.';

  @override
  String get keyboardShortcuts_overviewNoneAssigned =>
      'No keys are assigned to browser actions.';

  @override
  String get keyboardShortcuts_overviewDisabled =>
      'Keyboard shortcuts are switched off.';

  @override
  String get keyboardShortcuts_enableTitle => 'Enable Keyboard Shortcuts';

  @override
  String get keyboardShortcuts_enableSubtitle =>
      'Browser actions on a hardware keyboard, even while a page has focus';

  @override
  String get keyboardShortcuts_noShortcut => 'No shortcut';

  @override
  String get keyboardShortcuts_tooltipChange => 'Change';

  @override
  String keyboardShortcuts_tooltipRemoveChord(String chord) {
    return 'Remove $chord';
  }

  @override
  String get keyboardShortcuts_tooltipResetToDefault => 'Reset to default';

  @override
  String get keyboardShortcuts_addShortcut => 'Add shortcut';

  @override
  String get keyboardShortcuts_changeShortcutTitle => 'Change shortcut';

  @override
  String get keyboardShortcuts_restoreDefaultsTooltip =>
      'Restore default shortcuts';

  @override
  String get keyboardShortcuts_restoreDefaultsTitle =>
      'Restore default shortcuts?';

  @override
  String get keyboardShortcuts_restoreDefaultsContent =>
      'Every action goes back to its Firefox default keys. Your changes are lost.';

  @override
  String keyboardShortcuts_recorderInstructions(String actionTitle) {
    return 'Press the key combination for \"$actionTitle\".';
  }

  @override
  String get keyboardShortcuts_recorderWaitingForKeys => 'Waiting for keys…';

  @override
  String get keyboardShortcuts_recorderProblemNotAssignable =>
      'Web pages need this key. Hold Ctrl, Alt or Meta with it, or use a function key.';

  @override
  String get keyboardShortcuts_recorderProblemAlreadyBound =>
      'This is already a shortcut for this action.';

  @override
  String keyboardShortcuts_recorderTakesFromOther(String ownerTitle) {
    return 'Currently used by \"$ownerTitle\". Saving moves it here.';
  }

  @override
  String get keyboardShortcuts_actionCustomize => 'Customize';

  @override
  String get keyboardShortcuts_actionReassign => 'Reassign';

  @override
  String get keyboardShortcuts_actionRestore => 'Restore';

  @override
  String get onboarding_actionPrevious => 'Previous';

  @override
  String get onboarding_actionNext => 'Next';

  @override
  String get onboarding_actionRestore => 'Restore';

  @override
  String get onboarding_restoreTargetUnreadable =>
      'This profile could not be read, so nothing can be restored into it.';

  @override
  String get onboarding_welcomeBackTitle => 'Welcome back!';

  @override
  String get onboarding_welcomeReadyTitle => 'WebLibre is ready';

  @override
  String get onboarding_chooseExperience =>
      'Choose your onboarding experience:';

  @override
  String get onboarding_modeExpressTitle => 'Quick Start';

  @override
  String get onboarding_modeExpressSubtitle =>
      'Use recommended defaults and get browsing.';

  @override
  String get onboarding_modeDetailedTitle => 'Custom Setup';

  @override
  String get onboarding_modeDetailedSubtitle =>
      'Configure DNS, toolbar, extensions, and more.';

  @override
  String get onboarding_modeRestoreTitle => 'Restore from Backup';

  @override
  String get onboarding_modeRestoreSubtitle =>
      'Import a profile from an encrypted backup file.';

  @override
  String get onboarding_updateNoticeTitle => 'A lot has changed!';

  @override
  String get onboarding_updateNoticeBody =>
      'This update includes significant changes that require you to review your settings. Please go through the following pages to check your configuration.';

  @override
  String get onboarding_updateNoticeExtensions =>
      'Please re-check your extensions after this update due to known migration issues.';

  @override
  String get onboarding_updateNoticeSettingsPreserved =>
      'Your existing settings will not be overridden unless you explicitly change them during this setup.';

  @override
  String get onboarding_eulaAcceptance =>
      'I have read and accept the <eula>EULA</eula> and <privacy>Privacy Policy</privacy>.';

  @override
  String get onboarding_privacyPolicy => 'Privacy Policy';

  @override
  String get onboarding_eulaDocumentTitle => 'End User License Agreement';

  @override
  String get onboarding_aiFeaturesTitle => 'AI Features';

  @override
  String get onboarding_aiOnDeviceTitle => 'On-device AI';

  @override
  String get onboarding_aiOnDeviceSubtitle =>
      'Local on-device features including container topic and tab suggestions';

  @override
  String get onboarding_aiWarningTitle => 'Things to keep in mind';

  @override
  String get onboarding_aiWarningPoint1 =>
      'WebLibre uses a local AI model to analyze your open tab titles and suggest which containers to group the tabs into and what to name those containers. All processing happens entirely on your device.';

  @override
  String get onboarding_aiWarningPoint2 =>
      'AI enhancements operate entirely within your browser, keeping all data on your device. Local AI processing respects your privacy and provides faster suggestions for container groups and names. You can control this behavior at any time in Settings.';

  @override
  String get onboarding_aiWarningPoint3 =>
      'AI can sometimes make mistakes, so please review suggested group names and tab selections.';

  @override
  String get onboarding_searchTitle => 'Search';

  @override
  String get onboarding_searchDefaultProviderLabel => 'Default Search Provider';

  @override
  String get onboarding_searchMore => 'Search more';

  @override
  String get onboarding_searchDefaultAutocompleteLabel =>
      'Default Autocomplete Provider';

  @override
  String get onboarding_searchLoadFailedTitle =>
      'Could not load search engines';

  @override
  String get onboarding_dohTitle => 'DNS over HTTPS';

  @override
  String get onboarding_permissionsTitle => 'Permissions';

  @override
  String get onboarding_permissionsNotificationsTitle => 'Notifications';

  @override
  String get onboarding_permissionsNotificationsSubtitle =>
      'Required to notify you about downloads';

  @override
  String get onboarding_permissionsDefaultBrowserTitle => 'Default Browser';

  @override
  String get onboarding_permissionsDefaultBrowserSubtitle =>
      'Set WebLibre as your default browser';

  @override
  String get onboarding_privacyTitle => 'Privacy & Hardening';

  @override
  String get onboarding_privacyBrowserLanguagesTitle => 'Browser Languages';

  @override
  String get onboarding_privacyBrowserLanguagesSubtitle =>
      'Configure language preferences exposed to websites';

  @override
  String get onboarding_multipleLanguagesDetectedTitle =>
      'Multiple Languages Detected';

  @override
  String onboarding_multipleLanguagesWarning(int count, String locales) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your browser has $count languages configured ($locales).',
    );
    return '$_temp0 Websites can use your unique language combination to fingerprint and track you across the web.';
  }

  @override
  String get onboarding_multipleLanguagesSuggestion =>
      'Consider reducing your browser languages to a single language to minimize your fingerprint surface.';

  @override
  String get onboarding_reviewLanguages => 'Review Languages';

  @override
  String get onboarding_webEngineHardeningTitle =>
      'Complete Web Engine Hardening';

  @override
  String get onboarding_webEngineHardeningSubtitle =>
      'Apply all recommended security hardening preferences to the web engine';

  @override
  String get onboarding_fingerprintProtectionTitle =>
      'Hardened Fingerprint Protection';

  @override
  String get onboarding_fingerprintProtectionSubtitle =>
      'Load comprehensive fingerprint protection defaults';

  @override
  String get onboarding_compatibilityWarningTitle => 'Compatibility Warning';

  @override
  String get onboarding_fingerprintWarningPoint1 =>
      'Hardened fingerprint protection enables 60+ protection targets including canvas randomization, navigator spoofing, media device masking, and more.';

  @override
  String get onboarding_fingerprintWarningPoint2 =>
      'This may cause websites to break or behave unexpectedly. You can fine-tune individual targets in settings.';

  @override
  String get onboarding_localNetworkProtectionTitle =>
      'Local Network Protection';

  @override
  String get onboarding_localNetworkProtectionSubtitle =>
      'Websites can try to reach your device and other devices on your home network, like routers, printers, or smart home devices. By default, known trackers are automatically blocked from doing this.';

  @override
  String get onboarding_blockAllLocalNetworkTitle =>
      'Block All Local Network Requests';

  @override
  String get onboarding_blockAllLocalNetworkSubtitle =>
      'Ask for permission before any website accesses devices on your home network, not just known trackers';

  @override
  String get onboarding_toolbarLayoutTitle => 'Toolbar & Layout';

  @override
  String get onboarding_ublockTitle => 'uBlock Origin';

  @override
  String get onboarding_ublockDescription =>
      'uBlock Origin (uBO) is a CPU- and memory-efficient **wide-spectrum content blocker** by **Raymond Hill** and is available as a browser extension for WebLibre.\n\nBy default, it blocks ads, trackers, coin miners, pop-ups, annoying anti-blockers, malware sites, and more using **EasyList, EasyPrivacy, Peter Lowe\'s Blocklist, Online Malicious URL Blocklist, and uBO filter lists**.\n\nMany other lists are available to block additional content.';

  @override
  String get onboarding_ublockInstallTitle => 'Install uBlock Origin Extension';

  @override
  String get onboarding_ublockApplyDefaultsTitle => 'Apply optimized defaults';

  @override
  String get onboarding_ublockApplyDefaultsSubtitle =>
      'Enable WebLibre hardening filter lists.';

  @override
  String get proxy_actionChange => 'Change';

  @override
  String get proxy_actionFetch => 'Fetch';

  @override
  String get proxy_actionSelectAll => 'Select all';

  @override
  String get proxy_actionShare => 'Share';

  @override
  String get proxy_actionStart => 'Start';

  @override
  String get proxy_actionStop => 'Stop';

  @override
  String get proxy_actionStopAndDelete => 'Stop and Delete';

  @override
  String get proxy_actionTestConnection => 'Test connection';

  @override
  String get proxy_connectionsTitle => 'Proxy Connections';

  @override
  String get proxy_addProfile => 'Add Profile';

  @override
  String get proxy_viewLogsTooltip => 'View logs';

  @override
  String get proxy_profilesSectionTitle => 'Profiles';

  @override
  String proxy_loadProfilesFailed(String error) {
    return 'Failed to load proxy profiles:\n$error';
  }

  @override
  String get proxy_statusActive => 'Active';

  @override
  String get proxy_statusDisconnected => 'Disconnected';

  @override
  String proxy_statusRoutingTraffic(int running, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$running of $total proxies running',
      one: '$running of 1 proxy running',
    );
    return '$_temp0';
  }

  @override
  String get proxy_statusTapToConnect => 'Tap a profile to connect';

  @override
  String get proxy_stopAllTooltip => 'Stop all';

  @override
  String get proxy_onionRoutingLabel => 'Onion routing';

  @override
  String get proxy_autostartLabel => 'Autostart';

  @override
  String get proxy_autostartTooltip => 'Starts with WebLibre';

  @override
  String proxy_egressIpTooltip(String ip) {
    return 'Egress IP $ip';
  }

  @override
  String get proxy_latencyTesting => 'Testing...';

  @override
  String get proxy_latencyTestRunningTooltip => 'Latency test running';

  @override
  String get proxy_latencyNotRunningTooltip => 'The profile is not running';

  @override
  String get proxy_latencyFailed => 'Failed';

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
    return 'Failed to start proxy: $error';
  }

  @override
  String proxy_stopProxyFailed(String error) {
    return 'Failed to stop proxy: $error';
  }

  @override
  String proxy_startBrandFailed(String brand, String error) {
    return 'Failed to start $brand: $error';
  }

  @override
  String proxy_stopBrandFailed(String brand, String error) {
    return 'Failed to stop $brand: $error';
  }

  @override
  String get proxy_startConnectionDialogTitle => 'Start Proxy Connection?';

  @override
  String proxy_startConnectionDialogContent(String proxyTitle) {
    return 'This tab needs $proxyTitle, but that connection is not running. Start it now?';
  }

  @override
  String get proxy_deleteProfileTitle => 'Delete Profile?';

  @override
  String proxy_deleteProfileConfirm(String name) {
    return 'Delete $name and its stored secrets? Tabs and containers assigned to this profile will be blocked until you choose another proxy or clear the assignment.';
  }

  @override
  String proxy_deleteProfileConfirmRunning(String name) {
    return 'Stop $name, then delete it and its stored secrets? Tabs and containers assigned to this profile will be blocked until you choose another proxy or clear the assignment.';
  }

  @override
  String proxy_deleteProfileFailed(String error) {
    return 'Failed to delete profile: $error';
  }

  @override
  String proxy_shareDialogTitle(String name) {
    return 'Share \"$name\"';
  }

  @override
  String get proxy_shareDialogWarning =>
      'This link contains the full profile, including any stored credentials. Share carefully.';

  @override
  String get proxy_copiedToClipboard => 'Copied to clipboard';

  @override
  String get proxy_editProfileTitle => 'Edit Profile';

  @override
  String get proxy_newProfileTitle => 'New Profile';

  @override
  String get proxy_saveChanges => 'Save Changes';

  @override
  String get proxy_createProfile => 'Create Profile';

  @override
  String get proxy_sectionGeneral => 'General';

  @override
  String get proxy_sectionDnsOverride => 'DNS Override';

  @override
  String get proxy_addMenuTip =>
      'Tip: Use the add menu on the previous screen to import from a file, paste a share link, or scan a QR code.';

  @override
  String proxy_wireGuardTrademarkDisclaimer(String brand) {
    return '$brand is a registered trademark of Jason A. Donenfeld; all rights reserved. WebLibre is not endorsed or sponsored by, or affiliated with, Jason A. Donenfeld.';
  }

  @override
  String proxy_wireGuardConfigLabel(String brand) {
    return '$brand config';
  }

  @override
  String get proxy_fieldProfileName => 'Profile Name';

  @override
  String get proxy_fieldProtocol => 'Protocol';

  @override
  String get proxy_protocolFixedHelper =>
      'Protocol is fixed once a profile is created.';

  @override
  String get proxy_customOutboundLabel => 'Custom Outbound';

  @override
  String get proxy_startAutomaticallyTitle => 'Start Automatically';

  @override
  String get proxy_startAutomaticallySubtitle =>
      'Connect this profile when WebLibre starts, so tabs using it are ready without a prompt';

  @override
  String proxy_dnsOverrideExplanation(String brand) {
    return 'Resolve names through a DNS server reachable over this connection (e.g., an internal DoH server behind a corporate $brand tunnel). Leave this off to use automatic DNS handling.';
  }

  @override
  String get proxy_dnsOverrideSwitchTitle => 'Use a profile-specific resolver';

  @override
  String get proxy_fieldDnsServerAddress => 'DNS server address';

  @override
  String get proxy_sectionOutbound => 'Outbound';

  @override
  String get proxy_sectionSecrets => 'Secrets';

  @override
  String get proxy_fieldOutboundJson => 'Outbound JSON';

  @override
  String get proxy_outboundJsonHelper => 'Public sing-box outbound object.';

  @override
  String get proxy_fieldSecretJson => 'Secret JSON';

  @override
  String get proxy_secretJsonHelper =>
      'Optional values merged into the outbound at runtime.';

  @override
  String get proxy_sectionConnection => 'Connection';

  @override
  String get proxy_sectionCredentials => 'Credentials';

  @override
  String get proxy_sectionProtocolOptions => 'Protocol Options';

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
      'Advanced protocol options can still be entered with Custom Outbound JSON.';

  @override
  String get proxy_storedInSecureStorage => 'Stored in secure storage.';

  @override
  String get proxy_booleanFieldUnset => 'Unset (uses default)';

  @override
  String get proxy_booleanFieldEnabled => 'Enabled';

  @override
  String get proxy_booleanFieldDisabled => 'Disabled';

  @override
  String get proxy_addConnectionTitle => 'Add Connection';

  @override
  String get proxy_addConnectionSubtitle =>
      'Choose how you want to add a proxy profile.';

  @override
  String get proxy_methodClipboardTitle => 'Clipboard';

  @override
  String get proxy_methodClipboardSubtitle => 'Paste a share link or URI';

  @override
  String get proxy_methodScanQrTitle => 'Scan QR';

  @override
  String get proxy_methodScanQrSubtitle => 'From another device';

  @override
  String get proxy_methodSubscriptionTitle => 'Subscription';

  @override
  String get proxy_methodSubscriptionSubtitle => 'Fetch from URL';

  @override
  String get proxy_methodImportFileTitle => 'Import file';

  @override
  String get proxy_methodImportFileSubtitle => '.conf or sing-box JSON';

  @override
  String get proxy_enterManually => 'Enter manually';

  @override
  String get proxy_clipboardEmpty => 'The clipboard is empty.';

  @override
  String get proxy_importFromFileTitle => 'Import from file';

  @override
  String get proxy_importFileWireGuardSubtitle =>
      '.conf file with [Interface]/[Peer]';

  @override
  String get proxy_importFileSingboxJsonTitle => 'Sing-box outbound JSON';

  @override
  String get proxy_importFileSingboxJsonSubtitle =>
      'Shadowsocks, Trojan, VMess, VLESS, Hysteria, …';

  @override
  String proxy_importedProfileNamed(String name) {
    return 'Imported profile \"$name\"';
  }

  @override
  String get proxy_importSubscriptionTitle => 'Import Subscription';

  @override
  String get proxy_fieldSubscriptionUrl => 'Subscription URL';

  @override
  String get proxy_subscriptionUrlRequired =>
      'Enter a full https:// subscription URL.';

  @override
  String proxy_subscriptionHttpError(int statusCode) {
    return 'The subscription server answered with HTTP $statusCode.';
  }

  @override
  String get proxy_subscriptionTimedOut =>
      'The subscription server did not answer in time.';

  @override
  String proxy_subscriptionFetchFailed(String error) {
    return 'Could not fetch the subscription: $error';
  }

  @override
  String get proxy_subscriptionFormatHint =>
      'Supports the v2rayN-style format: a base64-encoded list of ss://, vless://, vmess://, trojan://, hysteria2://, tuic:// and similar URIs. Routing rules from the subscription are ignored — only proxy nodes are imported.';

  @override
  String proxy_importedProfileDefaultName(int n) {
    return 'Imported $n';
  }

  @override
  String proxy_importedProfilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count profiles',
      one: 'Imported 1 profile',
    );
    return '$_temp0';
  }

  @override
  String proxy_importProfilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import $count profiles',
      one: 'Import 1 profile',
    );
    return '$_temp0';
  }

  @override
  String proxy_subscriptionNodeSummary(int usable, int failed) {
    String _temp0 = intl.Intl.pluralLogic(
      usable,
      locale: localeName,
      other: '$usable usable nodes, $failed failed',
      one: '1 usable node, $failed failed',
    );
    String _temp1 = intl.Intl.pluralLogic(
      usable,
      locale: localeName,
      other: '$usable usable nodes, 1 failed',
      one: '1 usable node, 1 failed',
    );
    String _temp2 = intl.Intl.pluralLogic(
      usable,
      locale: localeName,
      other: '$usable usable nodes',
      one: '1 usable node',
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
  String get proxy_logsTitle => 'Proxy Logs';

  @override
  String get proxy_logsCopyAllTooltip => 'Copy all';

  @override
  String get proxy_logsClearTooltip => 'Clear log';

  @override
  String get proxy_logsShareSubject => 'proxy logs';

  @override
  String get proxy_logsNoLinesMatchFilter =>
      'No log lines match the current filter';

  @override
  String proxy_logsCopiedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copied $count lines to clipboard',
      one: 'Copied 1 line to clipboard',
    );
    return '$_temp0';
  }

  @override
  String get proxy_logsShowAllLevels => 'Show all levels';

  @override
  String get proxy_logsShowErrorsOnly => 'Show errors only';

  @override
  String get proxy_logsShowWarningsAndAbove => 'Show warnings and above';

  @override
  String get proxy_logsShowInfoAndAbove => 'Show info and above';

  @override
  String get proxy_logsShowDebugAndAbove => 'Show debug and above';

  @override
  String get proxy_logsShowTraceAndAbove => 'Show trace and above';

  @override
  String get proxy_logsLatest => 'Latest';

  @override
  String get proxy_logsEmptyFiltered =>
      'No log lines at this level. Lower the display filter or increase the proxy\'s logging level.';

  @override
  String proxy_logsEmpty(String brand) {
    return 'No log lines yet. Start a proxy or $brand to see output here.';
  }

  @override
  String get proxy_recordingLevelWarn => 'Recording warnings and errors';

  @override
  String get proxy_recordingLevelInfo => 'Recording info — this slows browsing';

  @override
  String get proxy_recordingLevelDebug =>
      'Recording debug — this slows browsing';

  @override
  String get proxy_recordingLevelTrace =>
      'Recording trace — this slows browsing';

  @override
  String get proxy_logLevelAll => 'All';

  @override
  String get proxy_logLevelTrace => 'Trace';

  @override
  String get proxy_logLevelDebug => 'Debug';

  @override
  String get proxy_logLevelInfo => 'Info';

  @override
  String get proxy_logLevelWarnings => 'Warnings';

  @override
  String get proxy_logLevelErrors => 'Errors';

  @override
  String get proxy_logLevelSheetTitle => 'Proxy log level';

  @override
  String get proxy_logLevelSheetExplanation =>
      'Raise this only while diagnosing a problem, then put it back. Changing it restarts any running proxy.';

  @override
  String get proxy_verboseLoggingWarning =>
      'Verbose logging writes a line for every connection and DNS lookup, which noticeably slows browsing.';

  @override
  String get proxy_logVerbosityWarnLabel => 'Warnings and errors';

  @override
  String get proxy_logVerbosityInfoLabel => 'Info';

  @override
  String get proxy_logVerbosityDebugLabel => 'Debug';

  @override
  String get proxy_logVerbosityTraceLabel => 'Trace';

  @override
  String get proxy_logVerbosityWarnDescription =>
      'Normal operation. Problems are still logged.';

  @override
  String get proxy_logVerbosityInfoDescription =>
      'Every connection and DNS lookup. Slows browsing.';

  @override
  String get proxy_logVerbosityDebugDescription =>
      'Info plus protocol detail. Slows browsing.';

  @override
  String get proxy_logVerbosityTraceDescription =>
      'Everything sing-box can say. Slows browsing a lot.';

  @override
  String get proxy_loadingProxyTitle => 'Loading proxy...';

  @override
  String proxy_torConnectionSubtitle(String torBrand) {
    return 'Route through the $torBrand network';
  }

  @override
  String get proxy_routingTitle => 'Proxy Routing';

  @override
  String get proxy_routingSubtitle =>
      'Choose which proxy carries regular and private tab traffic.';

  @override
  String get proxy_routingSectionRegularTabs => 'Regular Tabs';

  @override
  String get proxy_routingSectionRegularTabsKeywords => 'routing';

  @override
  String get proxy_routingSectionPrivateTabs => 'Private Tabs';

  @override
  String get proxy_routingSectionPrivateTabsKeywords => 'private, incognito';

  @override
  String get proxy_routingRegularTabsModeTitle => 'Regular Tabs Routing Mode';

  @override
  String get proxy_routingRegularTabsModeKeywords => 'container, global';

  @override
  String get proxy_routingRegularTabsModeSubtitle =>
      'Choose how regular tabs are routed through proxies';

  @override
  String get proxy_routingGlobalProxyTitle => 'Proxy for global routing';

  @override
  String get proxy_routingGlobalProxyKeywords => 'proxy';

  @override
  String get proxy_routingGlobalProxySubtitle =>
      'Selected proxy when global routing is enabled';

  @override
  String get proxy_routingPrivateTabsProxyTitle => 'Proxy for private tabs';

  @override
  String get proxy_routingPrivateTabsProxyKeywords => 'proxy';

  @override
  String get proxy_routingPrivateTabsProxySubtitle =>
      'Selected proxy that carries private-tab traffic';

  @override
  String get proxy_routingContainerBasedTitle => 'Container-Based Routing';

  @override
  String get proxy_routingContainerBasedSubtitle =>
      'Only tabs in containers with a proxy assigned are routed.';

  @override
  String get proxy_routingGlobalRoutingTitle => 'Global Routing';

  @override
  String get proxy_routingGlobalRoutingSubtitle =>
      'Route regular tabs through the selected proxy unless a container bypasses it.';

  @override
  String get proxy_routingNotUsedTitle => 'Not used in container-based routing';

  @override
  String get proxy_routingNotUsedSubtitle =>
      'Switch to global routing above to pick the proxy that carries every regular tab.';

  @override
  String get proxy_routingNoneTitle => 'None';

  @override
  String get proxy_routingNoneSubtitle => 'Use the normal browser connection';

  @override
  String get proxy_routingUnknownProxySubtitle =>
      'The selected proxy no longer exists.';

  @override
  String get proxy_unknownProxyTitle => 'Unknown proxy';

  @override
  String get proxy_connectionPickerTitle => 'Proxy Connection';

  @override
  String get proxy_pickerUnknownProxySubtitle =>
      'This proxy profile no longer exists';

  @override
  String get proxy_fieldServerAddress => 'Server Address';

  @override
  String get proxy_fieldServerPort => 'Server Port';

  @override
  String get proxy_fieldUsername => 'Username';

  @override
  String get proxy_fieldPassword => 'Password';

  @override
  String get proxy_fieldUuid => 'UUID';

  @override
  String get proxy_fieldTlsEnabled => 'TLS Enabled';

  @override
  String get proxy_fieldTlsEnabledHelper => 'true or false.';

  @override
  String get proxy_fieldTlsServerName => 'TLS Server Name';

  @override
  String get proxy_fieldTlsInsecure => 'Allow Invalid TLS Certificates';

  @override
  String get proxy_fieldTlsInsecureHelper => 'true or false.';

  @override
  String get proxy_fieldTlsAlpn => 'TLS ALPN';

  @override
  String get proxy_fieldTlsAlpnHelper =>
      'Comma-separated or one value per line.';

  @override
  String get proxy_fieldTransportType => 'Transport Type';

  @override
  String get proxy_fieldTransportTypeHelper =>
      'For example ws, http, grpc, or quic.';

  @override
  String get proxy_fieldTransportPath => 'Transport Path';

  @override
  String get proxy_fieldGrpcServiceName => 'gRPC Service Name';

  @override
  String get proxy_fieldMultiplexEnabled => 'Multiplex Enabled';

  @override
  String get proxy_fieldMultiplexEnabledHelper => 'true or false.';

  @override
  String get proxy_fieldMultiplexProtocol => 'Multiplex Protocol';

  @override
  String get proxy_fieldMultiplexMaxConnections => 'Multiplex Max Connections';

  @override
  String get proxy_fieldDialDetour => 'Dial Detour';

  @override
  String get proxy_fieldBindInterface => 'Bind Interface';

  @override
  String get proxy_fieldRoutingMark => 'Routing Mark';

  @override
  String get proxy_fieldDomainStrategy => 'Domain Strategy';

  @override
  String get proxy_fieldDomainStrategyHelper =>
      'For example prefer_ipv4 or prefer_ipv6.';

  @override
  String get proxy_fieldConnectTimeout => 'Connect Timeout';

  @override
  String get proxy_fieldConnectTimeoutHelper => 'For example 5s.';

  @override
  String get proxy_fieldSocksVersion => 'SOCKS Version';

  @override
  String get proxy_fieldMethod => 'Method';

  @override
  String get proxy_fieldSecurity => 'Security';

  @override
  String get proxy_fieldAlterId => 'Alter ID';

  @override
  String get proxy_fieldFlow => 'Flow';

  @override
  String get proxy_fieldAuthString => 'Auth String';

  @override
  String get proxy_fieldUploadBandwidth => 'Upload Bandwidth';

  @override
  String get proxy_fieldDownloadBandwidth => 'Download Bandwidth';

  @override
  String get proxy_fieldObfuscation => 'Obfuscation';

  @override
  String get proxy_fieldReceiveWindowConn => 'Receive Window Conn';

  @override
  String get proxy_fieldReceiveWindow => 'Receive Window';

  @override
  String get proxy_fieldDisableMtuDiscovery => 'Disable MTU Discovery';

  @override
  String get proxy_fieldDisableMtuDiscoveryHelper => 'true or false.';

  @override
  String get proxy_fieldUploadMbps => 'Upload Mbps';

  @override
  String get proxy_fieldDownloadMbps => 'Download Mbps';

  @override
  String get proxy_fieldObfuscationType => 'Obfuscation Type';

  @override
  String get proxy_fieldObfuscationPassword => 'Obfuscation Password';

  @override
  String get proxy_fieldCongestionControl => 'Congestion Control';

  @override
  String get proxy_fieldUdpRelayMode => 'UDP Relay Mode';

  @override
  String get proxy_fieldZeroRttHandshake => 'Zero RTT Handshake';

  @override
  String get proxy_fieldZeroRttHandshakeHelper => 'true or false.';

  @override
  String get proxy_fieldUser => 'User';

  @override
  String get proxy_fieldPrivateKey => 'Private Key';

  @override
  String get proxy_fieldPrivateKeyPassphrase => 'Private Key Passphrase';

  @override
  String get proxy_fieldLocalAddress => 'Local Address';

  @override
  String get proxy_fieldLocalAddressHelper =>
      'The address this device has inside the tunnel, one per line — for example, 10.0.0.2/32. A bare address is treated as a single address (/32, or /128 for IPv6).';

  @override
  String get proxy_fieldPeerPublicKey => 'Peer Public Key';

  @override
  String get proxy_fieldWireguardPrivateKey => 'Private Key';

  @override
  String get proxy_fieldWireguardPrivateKeyHelper =>
      'Stored in secure storage, not profile JSON.';

  @override
  String get proxy_fieldPreSharedKey => 'Pre-shared Key';

  @override
  String get proxy_fieldPreSharedKeyHelper =>
      'Optional. Stored in secure storage.';

  @override
  String get proxy_fieldMtu => 'MTU';

  @override
  String get proxy_fieldMtuHelper =>
      'Lower this if the tunnel connects but pages never load: packets larger than the path allows are dropped outright. A value of 1280 is safe almost everywhere; use around 1200 when already connected to another VPN.';

  @override
  String get proxy_fieldPersistentKeepalive => 'Persistent Keepalive';

  @override
  String get proxy_fieldPersistentKeepaliveHelper =>
      'Seconds between keepalive packets. Phones often sit behind NAT; without keepalives, the mapping can expire while idle. The peer can then no longer reach the phone, so connections stall until the next handshake. Set to 0 to disable.';

  @override
  String get proxy_fieldReservedBytes => 'Reserved Bytes';

  @override
  String get proxy_fieldReservedBytesHelper =>
      'Optional. Three comma-separated numbers, e.g. 0,0,0.';

  @override
  String get proxy_fieldShadowTlsVersion => 'Version';

  @override
  String proxy_fieldErrorRequired(String field) {
    return '$field is required.';
  }

  @override
  String proxy_fieldErrorNotPositiveNumber(String field) {
    return '$field must be a positive number.';
  }

  @override
  String proxy_fieldErrorPortRange(String field) {
    return '$field must be between 1 and 65535.';
  }

  @override
  String proxy_fieldErrorListLength(String field, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$field must contain $count numbers.',
      one: '$field must contain 1 number.',
    );
    return '$_temp0';
  }

  @override
  String proxy_fieldErrorNotAllNumbers(String field) {
    return '$field must contain only numbers.';
  }

  @override
  String proxy_fieldErrorBelowMin(String field, int min) {
    return '$field must contain numbers greater than or equal to $min.';
  }

  @override
  String proxy_fieldErrorAboveMax(String field, int max) {
    return '$field must contain numbers less than or equal to $max.';
  }

  @override
  String proxy_fieldErrorInvalidCidr(String field, String value) {
    return '$field must contain IP addresses, optionally with a /prefix — \"$value\" is not one.';
  }

  @override
  String proxy_fieldErrorNotBoolean(String field) {
    return '$field must be true or false.';
  }

  @override
  String proxy_fieldErrorNotAllowedValue(String field, String values) {
    return '$field must be one of: $values.';
  }

  @override
  String get proxy_saveErrorAlreadySaving => 'Profile is already saving.';

  @override
  String get proxy_saveErrorNameRequired => 'Profile name is required.';

  @override
  String get proxy_saveErrorStillLoading =>
      'The profile is still loading. Please wait.';

  @override
  String get proxy_saveErrorConfigNotJson => 'Config must be a JSON object.';

  @override
  String get proxy_saveErrorSecretsNotJson => 'Secrets must be a JSON object.';

  @override
  String proxy_saveErrorUnexpected(String error) {
    return 'Failed to save proxy profile: $error';
  }

  @override
  String get proxy_loadErrorNotFound => 'Proxy profile not found.';

  @override
  String proxy_loadErrorFailed(String error) {
    return 'Failed to load proxy profile: $error';
  }

  @override
  String get qrScanner_noCameraPermission =>
      'Camera permission has not been granted.';

  @override
  String get qrScanner_scanCodeTitle => 'Scan code';

  @override
  String get searchCredits_couldNotLoadTitle => 'Could not load credits';

  @override
  String get searchCredits_title => 'Search credits';

  @override
  String get searchCredits_errorSubtitle =>
      'Check your connection and tap refresh to retry.';

  @override
  String get searchCredits_emptySubtitle => 'Buy a search pack to get started';

  @override
  String searchCredits_creditsWithAllowance(
    int credits,
    int allowance,
    int stash,
  ) {
    return 'Credits: $credits / $allowance  ·  Stashed tokens: $stash';
  }

  @override
  String searchCredits_creditsNoAllowance(int credits, int stash) {
    return 'Credits: $credits  ·  Stashed tokens: $stash';
  }

  @override
  String get searchCredits_tooltipRefresh => 'Refresh';

  @override
  String searchCredits_resetsOn(String date) {
    return 'Resets on $date';
  }

  @override
  String searchCredits_lastIssuance(String relative, String absolute) {
    return 'Last issuance: $relative  ($absolute)';
  }

  @override
  String get searchCredits_requestingTokens => 'Requesting tokens...';

  @override
  String searchCredits_issuanceFailed(String error) {
    return 'Token issuance failed: $error';
  }

  @override
  String get searchCredits_needsReauth =>
      'Please sign in again to request tokens.';

  @override
  String get searchCredits_buySearchPackTitle => 'Buy a search pack';

  @override
  String get searchCredits_getTokensTitle => 'Get tokens';

  @override
  String searchCredits_requestTokensCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Request $count tokens',
      one: 'Request 1 token',
    );
    return '$_temp0';
  }

  @override
  String get searchCredits_noCreditsRemaining => 'No credits remaining';

  @override
  String get searchCredits_buyMoreTitle => 'Buy more';

  @override
  String get settings_advancedTitle => 'Advanced';

  @override
  String get settings_advancedSubtitle =>
      'Engine behavior, runtime overrides, and developer tools.';

  @override
  String get settings_javascriptTitle => 'Enable JavaScript';

  @override
  String get settings_javascriptKeywords => 'javascript';

  @override
  String get settings_javascriptSubtitle =>
      'Turning off JavaScript can improve security, privacy, and speed, but may cause some sites not to work as intended.';

  @override
  String get settings_userAgentLabel => 'Custom User Agent';

  @override
  String get settings_userAgentLabelKeywords => 'ua';

  @override
  String get settings_enterpriseRootsTitle => 'Use third-party CA certificates';

  @override
  String get settings_enterpriseRootsKeywords =>
      'certificates, enterprise roots, ca';

  @override
  String get settings_enterpriseRootsSubtitle =>
      'Allows the use of third-party certificates from the Android CA store';

  @override
  String get settings_experimentalFeaturesTitle => 'Experimental Features';

  @override
  String get settings_experimentalFeaturesKeywords => 'runtime, startup';

  @override
  String get settings_experimentalFeaturesSubtitle =>
      'Low-level runtime features and startup behavior';

  @override
  String get settings_unmountGeckoViewTitle => 'Unmount Engine Off-Screen';

  @override
  String get settings_unmountGeckoViewKeywords =>
      'geckoview, memory, performance, suspend';

  @override
  String get settings_unmountGeckoViewSubtitle =>
      'Remove the web engine from memory while a full-screen view (such as settings, tabs, or search) is open, then rebuild it when you return. This frees resources in the meantime. Returning to the page requires reattaching the engine and may cause a flicker or reload, so this trades performance for memory rather than fixing a problem. On Android 12 and earlier, the engine is always unmounted.';

  @override
  String get settings_iconCacheTitle => 'Icon Cache';

  @override
  String get settings_iconCacheKeywords => 'favicons, cache';

  @override
  String get settings_iconCacheSubtitle => 'Stored favicons';

  @override
  String get settings_iconCacheSizeLabel => 'Size';

  @override
  String get settings_clearingAction => 'Clearing';

  @override
  String get settings_mlDownloadsTitle => 'ML Downloads';

  @override
  String get settings_mlDownloadsKeywords => 'ai, ml, models, onnx, cache';

  @override
  String get settings_mlDownloadsSubtitle =>
      'Downloaded AI models and runtime files';

  @override
  String get settings_mlDownloadsClearDialogTitle => 'Clear ML downloads?';

  @override
  String get settings_mlDownloadsClearDialogContent =>
      'This clears downloaded AI models and ONNX runtime files for this profile. They will be downloaded again when needed. Restart WebLibre before retrying ML features.';

  @override
  String get settings_mlDownloadsClearedMessage =>
      'ML downloads cleared. Restart WebLibre before retrying.';

  @override
  String settings_mlDownloadsClearFailedMessage(String error) {
    return 'Failed to clear ML downloads: $error';
  }

  @override
  String get settings_errorLogsTitle => 'Error Logs';

  @override
  String get settings_errorLogsKeywords => 'logs';

  @override
  String get settings_errorLogsSubtitle =>
      'View and copy logs for issue reporting';

  @override
  String get settings_dartVmTitle => 'Dart VM';

  @override
  String get settings_dartVmKeywords => 'service url';

  @override
  String get settings_dartVmSubtitle => 'Copy Dart VM service URL';

  @override
  String get settings_dartVmCopyErrorFallback => 'Error';

  @override
  String get settings_serviceUrlCopiedMessage => 'Service URL copied';

  @override
  String get settings_resetUiTitle => 'Reset UI';

  @override
  String get settings_resetUiKeywords => 'refresh ui';

  @override
  String get settings_resetUiSubtitle => 'Rebuild the entire browser UI';

  @override
  String get settings_addonCollectionTitle => 'Custom Extension Collection';

  @override
  String get settings_addonCollectionSourceSectionTitle => 'Collection Source';

  @override
  String get settings_addonCollectionConfigTitle => 'Collection configuration';

  @override
  String get settings_addonCollectionConfigKeywords => 'addons, collection';

  @override
  String get settings_addonCollectionConfigSubtitle =>
      'Mozilla server, collection owner, and collection name';

  @override
  String get settings_addonCollectionServerUrlLabel => 'Server URL';

  @override
  String get settings_addonCollectionUserLabel => 'Collection User';

  @override
  String get settings_addonCollectionNameLabel => 'Collection Name';

  @override
  String get settings_addonCollectionActionsSectionTitle => 'Actions';

  @override
  String get settings_addonCollectionSaveRestartTitle =>
      'Save & Restart Browser';

  @override
  String get settings_addonCollectionSaveRestartKeywords => 'restart';

  @override
  String get settings_addonCollectionSaveRestartSubtitle =>
      'Apply the custom collection and restart the browser';

  @override
  String get settings_bangSettingsTitle => 'Bang Settings';

  @override
  String get settings_bangSettingsKeywords => 'shortcuts, bangs';

  @override
  String get settings_bangSettingsSubtitle =>
      'Bang shortcuts usage, repositories, and on-demand sync.';

  @override
  String get settings_bangFrequenciesTitle => 'Bang Frequencies';

  @override
  String get settings_bangFrequenciesKeywords => 'usage, recommendations';

  @override
  String get settings_bangFrequenciesSubtitle =>
      'Tracked usage for bang recommendations';

  @override
  String get settings_browsingTitle => 'Browsing';

  @override
  String get settings_browsingSubtitle =>
      'Tabs, navigation, app links, and Small Web behavior.';

  @override
  String get settings_newTabDefaultTitle => 'New Tab Default';

  @override
  String get settings_newTabDefaultKeywords => 'regular, private, isolated';

  @override
  String get settings_newTabDefaultSubtitle =>
      'Choose the default type for manually created tabs';

  @override
  String get settings_tabTypeRegularLabel => 'Regular';

  @override
  String get settings_tabTypePrivateLabel => 'Private';

  @override
  String get settings_tabTypeIsolatedLabel => 'Isolated';

  @override
  String get settings_smallWebTabDefaultTitle => 'Small Web Tab Default';

  @override
  String get settings_smallWebTabDefaultKeywords =>
      'regular, private, isolated';

  @override
  String get settings_smallWebTabDefaultSubtitle =>
      'Choose the tab type used when entering Small Web';

  @override
  String get settings_externalLinkHandlingTitle => 'External Link Handling';

  @override
  String get settings_externalLinkHandlingKeywords => 'intents';

  @override
  String get settings_externalLinkHandlingSubtitle =>
      'Choose how external links open in WebLibre';

  @override
  String get settings_promptOptionLabel => 'Prompt';

  @override
  String get settings_externalLinkPromptSubtitle =>
      'Ask how external links should open';

  @override
  String get settings_externalLinkRegularSubtitle =>
      'Open external links in a regular tab';

  @override
  String get settings_externalLinkPrivateSubtitle =>
      'Open external links in a private tab';

  @override
  String get settings_externalLinkIsolatedSubtitle =>
      'Open external links in an isolated tab';

  @override
  String get settings_bookmarkOpenBehaviorTitle => 'Bookmark Open Behavior';

  @override
  String get settings_bookmarkOpenBehaviorKeywords =>
      'bookmarks, open, custom tab, isolated';

  @override
  String get settings_bookmarkOpenBehaviorSubtitle =>
      'Choose how tapping a bookmark opens it';

  @override
  String get settings_bookmarkOpenPromptSubtitle =>
      'Ask how the bookmark should open';

  @override
  String get settings_bookmarkOpenRegularSubtitle =>
      'Open the bookmark in a regular tab';

  @override
  String get settings_bookmarkOpenPrivateSubtitle =>
      'Open the bookmark in a private tab';

  @override
  String get settings_customTabOptionLabel => 'Custom Tab';

  @override
  String get settings_bookmarkOpenCustomTabSubtitle =>
      'Open the bookmark in a lightweight custom tab';

  @override
  String get settings_bookmarkOpenIsolatedSubtitle =>
      'Open the bookmark in an isolated tab';

  @override
  String get settings_tabListDirectionTitle => 'Tab List Direction';

  @override
  String get settings_tabListDirectionKeywords => 'sorting, order';

  @override
  String get settings_tabListDirectionSubtitle =>
      'Choose whether the newest tab appears at the top or bottom of the tab list';

  @override
  String get settings_directionNewestFirstLabel => 'Newest first';

  @override
  String get settings_directionOldestFirstLabel => 'Oldest first';

  @override
  String get settings_tabBarDirectionTitle => 'Tab Bar Direction';

  @override
  String get settings_tabBarDirectionKeywords => 'sorting, order';

  @override
  String get settings_tabBarDirectionSubtitle =>
      'Choose whether the newest tab appears on the left or right of the quick switcher';

  @override
  String get settings_childTabPlacementTitle => 'New Child Tab Position';

  @override
  String get settings_childTabPlacementKeywords =>
      'child tabs, new tab, position, order, end of list, after parent';

  @override
  String get settings_childTabPlacementSubtitle =>
      'Choose whether a tab opened from another tab follows its opener or goes to the end. The opener is still remembered either way, so the tree view is unaffected.';

  @override
  String get settings_childTabAfterOpenerLabel => 'After opener';

  @override
  String get settings_childTabAtEndLabel => 'At the end';

  @override
  String get settings_createChildTabsTitle => 'Create Child Tabs';

  @override
  String get settings_createChildTabsKeywords => 'child tabs';

  @override
  String get settings_createChildTabsSubtitle =>
      'Display a button to create a child tab under the current tab (tree view only)';

  @override
  String get settings_showContainerUiTitle => 'Show Container UI';

  @override
  String get settings_showContainerUiKeywords => 'containers';

  @override
  String get settings_showContainerUiSubtitle =>
      'Show container selectors, menus, and management';

  @override
  String get settings_showIsolatedTabUiTitle => 'Show Isolated Tab UI';

  @override
  String get settings_showIsolatedTabUiKeywords => 'isolated tabs';

  @override
  String get settings_showIsolatedTabUiSubtitle =>
      'Show isolated-tab creation options in the UI';

  @override
  String get settings_backgroundTabBehaviorTitle => 'Background Tab Behavior';

  @override
  String get settings_backgroundTabBehaviorKeywords =>
      'switch, background, new tab, snackbar, prompt';

  @override
  String get settings_backgroundTabBehaviorSubtitle =>
      'Applies when an action opens a new tab in the background, e.g. \"Open in new tab\" or cloning a tab';

  @override
  String get settings_backgroundTabPromptTitle => 'Stay and Offer to Switch';

  @override
  String get settings_backgroundTabPromptSubtitle =>
      'Keep the current tab and show a notice with a Switch action';

  @override
  String get settings_backgroundTabSwitchTitle => 'Switch Immediately';

  @override
  String get settings_backgroundTabSwitchSubtitle =>
      'Jump straight to the newly opened tab';

  @override
  String get settings_tabBarSwipesTitle => 'Tab Bar Swipes';

  @override
  String get settings_tabBarSwipesKeywords =>
      'gestures, swipe, tab bar swipe behavior';

  @override
  String get settings_tabBarSwipesSubtitle =>
      'Choose what each swipe does in Gestures';

  @override
  String get settings_sequentialTabNavigationTitle =>
      'Sequential Tab Navigation';

  @override
  String get settings_sequentialTabNavigationKeywords =>
      'gestures, swipe, next tab, previous tab, containers, loop, wrap around';

  @override
  String get settings_sequentialTabNavigationSubtitle =>
      'Applies to the tab bar swipe and the next/previous tab gestures';

  @override
  String get settings_continueIntoNextContainerTitle =>
      'Continue Into Next Container';

  @override
  String get settings_continueIntoNextContainerSubtitle =>
      'Stepping past the first or last tab of a container moves into the neighboring one. When off, navigation stays inside the current container.';

  @override
  String get settings_loopAroundTitle => 'Loop Around';

  @override
  String get settings_loopAroundSubtitle =>
      'Stepping past the last tab continues at the first one, and the other way round.';

  @override
  String get settings_openLinksInAppsTitle => 'Open Links in Apps';

  @override
  String get settings_openLinksInAppsKeywords => 'app links, external apps';

  @override
  String get settings_openLinksInAppsSubtitle =>
      'Choose how links that can be opened in other apps are handled';

  @override
  String get settings_appLinksAlwaysTitle => 'Always';

  @override
  String get settings_appLinksAlwaysSubtitle =>
      'Always open links in their native apps without asking';

  @override
  String get settings_appLinksAskTitle => 'Ask before opening';

  @override
  String get settings_appLinksAskSubtitle =>
      'Show a prompt before opening links in apps';

  @override
  String get settings_appLinksNeverTitle => 'Never';

  @override
  String get settings_appLinksNeverSubtitle =>
      'Always open links in the browser instead of apps';

  @override
  String get settings_waitForAnswerTitle => 'Wait for your answer';

  @override
  String get settings_waitForAnswerSubtitle =>
      'Hold the page while asking instead of loading it in the background. The site is not contacted unless you stay in the browser.';

  @override
  String get settings_offerAppStoreFallbackTitle => 'Offer app store fallback';

  @override
  String get settings_offerAppStoreFallbackSubtitle =>
      'When a link points to an app you don\'t have installed and there is no web fallback, offer to open the app store';

  @override
  String get settings_allowLoginAppCallbacksTitle =>
      'Allow login app callbacks';

  @override
  String get settings_allowLoginAppCallbacksSubtitle =>
      'Let apps that opened a Custom Tab receive their login callback, even when links are set to never open in apps';

  @override
  String get settings_appLinkContainerFallbackName => 'Container';

  @override
  String get settings_appLinkOverrideModeAlways => 'Always open in apps';

  @override
  String get settings_appLinkOverrideModeAsk => 'Asks before opening';

  @override
  String get settings_appLinkOverrideModeNever =>
      'Always keeps links in the browser';

  @override
  String get settings_appLinkContainerOverridesHeader =>
      'Containers with their own app-link settings';

  @override
  String settings_appLinkOverrideSummaryWithRules(String mode, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count remembered rules',
      one: '1 remembered rule',
    );
    return '$mode · $_temp0';
  }

  @override
  String get settings_appLinkRememberedRulesHeader => 'Remembered site rules';

  @override
  String get settings_appLinkRuleAlwaysOpenLabel => 'Always open in the app';

  @override
  String get settings_appLinkRuleAlwaysKeepLabel =>
      'Always keep in the browser';

  @override
  String get settings_appLinkRuleRemoveTooltip => 'Remove rule';

  @override
  String get settings_globalDesktopModeTitle => 'Always Request Desktop Site';

  @override
  String get settings_globalDesktopModeKeywords =>
      'desktop mode, user agent, mobile site, tablet';

  @override
  String get settings_globalDesktopModeSubtitle =>
      'Open new tabs in desktop mode by default. You can still toggle desktop mode per tab from the page menu.';

  @override
  String get settings_desktopModeSitesTitle => 'Desktop Mode Sites';

  @override
  String get settings_desktopModeSitesKeywords =>
      'desktop mode, per-site, user agent, exceptions';

  @override
  String get settings_desktopModeSitesSubtitle =>
      'Sites that always load in desktop mode';

  @override
  String get settings_pullToRefreshTitle => 'Pull to Refresh';

  @override
  String get settings_pullToRefreshKeywords => 'reload';

  @override
  String get settings_pullToRefreshSubtitle =>
      'Swipe down on pages to reload them';

  @override
  String get settings_customTabsTitle => 'Custom Tabs';

  @override
  String get settings_customTabsKeywords =>
      'custom tabs, in-app browser, chrome custom tabs, external app, share';

  @override
  String get settings_customTabsSubtitle =>
      'Let other apps open links in a lightweight in-app tab. When off, these links and shared URLs open as normal tabs in the main browser.';

  @override
  String get settings_doubleBackCloseTabTitle => 'Double Back to Close Tab';

  @override
  String get settings_doubleBackCloseTabKeywords => 'back button';

  @override
  String get settings_doubleBackCloseTabSubtitle =>
      'When enabled, press the Back button twice to close the tab. When disabled, the Back button only navigates through the page history.';

  @override
  String get settings_allowNonManifestPwaInstallTitle =>
      'Install Sites as Apps';

  @override
  String get settings_allowNonManifestPwaInstallKeywords => 'pwa, web apps';

  @override
  String get settings_allowNonManifestPwaInstallSubtitle =>
      'Allow installing websites without a PWA manifest as standalone apps';

  @override
  String get settings_urlCleanerTitle => 'URL Cleaner';

  @override
  String get settings_urlCleanerKeywords => 'utm, tracking parameters';

  @override
  String get settings_urlCleanerSubtitle =>
      'Tracking removal rules and catalog updates';

  @override
  String get settings_unshortenerTitle => 'Unshortener';

  @override
  String get settings_unshortenerKeywords => 'short links, redirects';

  @override
  String get settings_unshortenerSubtitle =>
      'Short link resolver and API token';

  @override
  String get settings_contextualToolbarSearchHint => 'Search toolbar buttons';

  @override
  String get settings_contextualToolbarTitleDefault => 'Customize Toolbar';

  @override
  String get settings_contextualToolbarTitleQuickSwitcher =>
      'Customize Switcher Buttons';

  @override
  String get settings_contextualToolbarResetToDefaults => 'Reset to Defaults';

  @override
  String get settings_contextualToolbarEnabledSection => 'Enabled';

  @override
  String get settings_contextualToolbarDisabledSection => 'Disabled';

  @override
  String get settings_contextualToolbarNoEnabledButtons =>
      'No enabled buttons. Toggle a button below to enable it.';

  @override
  String settings_contextualToolbarNoEnabledButtonsMatch(String query) {
    return 'No enabled buttons match \"$query\".';
  }

  @override
  String get settings_contextualToolbarAllButtonsEnabled =>
      'All buttons are enabled.';

  @override
  String settings_contextualToolbarNoDisabledButtonsMatch(String query) {
    return 'No disabled buttons match \"$query\".';
  }

  @override
  String get settings_longPressNoneTitle => 'None';

  @override
  String get settings_longPressNoneDescription =>
      'Default for this button: holding it does nothing extra';

  @override
  String get settings_longPressDefaultDescription => 'Default for this button';

  @override
  String get settings_longPressTitle => 'Long press';

  @override
  String get settings_longPressDescription => 'What holding the button does';

  @override
  String get settings_fallbackGreyOutLabel => 'Grey out';

  @override
  String get settings_fallbackIfUnavailableTitle => 'If unavailable';

  @override
  String get settings_fallbackIfUnavailableDescription =>
      'Shown instead while this button can\'t be used';

  @override
  String get settings_customTrackingProtectionTitle =>
      'Custom Tracking Protection';

  @override
  String get settings_customTrackingProtectionSubtitle =>
      'Custom cookie, content, tracker, and fingerprinting controls.';

  @override
  String get settings_fixMajorIssuesTitle => 'Fix website major issues';

  @override
  String get settings_fixMajorIssuesSubtitle =>
      'Apply exceptions required to avoid major website breakage (recommended)';

  @override
  String get settings_fixMinorIssuesTitle => 'Fix website minor issues';

  @override
  String get settings_fixMinorIssuesSubtitle =>
      'Apply exceptions to fix minor issues and enable convenience features';

  @override
  String get settings_blockCookiesTitle => 'Block Cookies';

  @override
  String get settings_blockCookiesSubtitle =>
      'Block cookies based on the policy below';

  @override
  String get settings_cookiePolicyTitle => 'Cookie Policy';

  @override
  String get settings_cookiePolicyTotalProtectionLabel =>
      'Total Cookie Protection (Recommended)';

  @override
  String get settings_cookiePolicyCrossSiteTrackersLabel =>
      'Cross-site and social media trackers';

  @override
  String get settings_cookiePolicyUnvisitedLabel => 'Unvisited sites';

  @override
  String get settings_cookiePolicyThirdPartyLabel => 'All third-party cookies';

  @override
  String get settings_cookiePolicyAllCookiesLabel =>
      'All cookies (may break sites)';

  @override
  String get settings_blockTrackingContentTitle => 'Block Tracking Content';

  @override
  String get settings_blockTrackingContentSubtitle =>
      'Block tracking scripts and resources embedded in websites';

  @override
  String get settings_trackingScopeApplyToTitle => 'Apply to';

  @override
  String get settings_trackingScopeAllTabsLabel => 'All tabs';

  @override
  String get settings_trackingScopePrivateOnlyLabel => 'Private tabs only';

  @override
  String get settings_adsAnalyticsSocialTrackersTitle =>
      'Ads, Analytics, and Social Trackers';

  @override
  String get settings_adsAnalyticsSocialTrackersSubtitle =>
      'Block advertising, analytics, social, and Mozilla social tracker categories';

  @override
  String get settings_cryptominersTitle => 'Cryptominers';

  @override
  String get settings_cryptominersSubtitle =>
      'Block scripts that use your device to mine cryptocurrency';

  @override
  String get settings_knownFingerprintersTitle => 'Known Fingerprinters';

  @override
  String get settings_knownFingerprintersSubtitle =>
      'Block scripts that collect information to uniquely identify your device';

  @override
  String get settings_redirectTrackersTitle => 'Redirect Trackers';

  @override
  String get settings_redirectTrackersSubtitle =>
      'Block trackers that collect data through intermediate URL redirects';

  @override
  String get settings_suspectedFingerprintersTitle =>
      'Suspected Fingerprinters';

  @override
  String get settings_suspectedFingerprintersSubtitle =>
      'Block additional fingerprinting techniques that may be used to track you';

  @override
  String get settings_desktopModeSitesScreenTitle => 'Desktop mode sites';

  @override
  String get settings_desktopModeSitesScreenDescription =>
      'These sites always load in desktop mode, overriding the default. Subdomains are included (e.g. \"example.com\" also covers \"m.example.com\").';

  @override
  String get settings_desktopModeSitesEmptyLabel => 'No sites added.';

  @override
  String get settings_dohTitle => 'DNS over HTTPS';

  @override
  String get settings_dohSubtitle =>
      'Encrypted DNS protection level and resolver selection.';

  @override
  String get settings_errorLogsCopiedMessage => 'Logs copied';

  @override
  String get settings_errorLogsSearchHint => 'Search log messages';

  @override
  String get settings_errorLogsCopyTooltip => 'Copy logs';

  @override
  String get settings_errorLogsEmptyLabel => 'No logs available';

  @override
  String get settings_experimentalTitle => 'Experimental';

  @override
  String get settings_experimentalSubtitle =>
      'Runtime isolation and startup behavior.';

  @override
  String get settings_isolatedContentProcessTitle => 'Isolated Content Process';

  @override
  String get settings_isolatedContentProcessKeywords => 'restart';

  @override
  String get settings_isolatedContentProcessSubtitle =>
      'Run web content in an isolated process. Requires an app restart.';

  @override
  String get settings_appZygoteProcessTitle => 'App Zygote Process';

  @override
  String get settings_appZygoteProcessKeywords => 'restart, android 10';

  @override
  String get settings_appZygoteProcessSubtitle =>
      'Preload the content service for faster isolated process startup. Requires Android 10+ and app restart.';

  @override
  String get settings_extensionsTitle => 'Extensions';

  @override
  String get settings_extensionsSubtitle =>
      'Manage add-ons, update behavior, and extension security.';

  @override
  String get settings_manageExtensionsTitle => 'Manage Extensions';

  @override
  String get settings_manageExtensionsKeywords => 'addons, browser extensions';

  @override
  String get settings_manageExtensionsSubtitle =>
      'Browse installed, disabled, available, and unsupported extensions';

  @override
  String get settings_customCollectionTitle => 'Custom Collection';

  @override
  String get settings_customCollectionKeywords => 'addons';

  @override
  String get settings_customCollectionSubtitle =>
      'Use a custom Mozilla add-on collection';

  @override
  String get settings_automaticUpdatesTitle => 'Automatic updates';

  @override
  String get settings_automaticUpdatesKeywords => 'addons';

  @override
  String get settings_automaticUpdatesSubtitle =>
      'Automatically check for and install extension updates every 12 hours';

  @override
  String settings_failedToLoadMessage(String error) {
    return 'Failed to load: $error';
  }

  @override
  String get settings_allowUnsignedExtensionsTitle =>
      'Allow unsigned extensions';

  @override
  String get settings_allowUnsignedExtensionsKeywords => 'addons';

  @override
  String get settings_allowUnsignedExtensionsSubtitle =>
      'Unsigned extensions have not been verified by Mozilla';

  @override
  String get settings_allowUnsignedWarningText =>
      'Only install unsigned extensions from sources you trust. They may contain malicious code.';

  @override
  String get settings_allowUnsignedConfirmDialogTitle =>
      'Allow unsigned extensions?';

  @override
  String get settings_allowUnsignedConfirmWarningBold =>
      'Warning: This significantly weakens your browser\'s security.';

  @override
  String get settings_allowUnsignedConfirmBody =>
      'Unsigned extensions bypass Mozilla\'s safety review process. Malicious extensions can:\n\n• Read and modify everything you see on any website\n• Steal passwords, banking details, and personal data\n• Monitor your browsing activity silently\n• Install additional malware on your device';

  @override
  String get settings_allowUnsignedConfirmFooter =>
      'Only enable this if you are a developer installing your own extension or absolutely trust the source.';

  @override
  String get settings_allowAction => 'Allow';

  @override
  String settings_allowActionCountdown(int seconds) {
    return 'Allow ($seconds)';
  }

  @override
  String get settings_fingerprintProtectionTitle => 'Fingerprint Protection';

  @override
  String get settings_fingerprintProtectionKeywords => 'privacy';

  @override
  String get settings_fingerprintSearchHint =>
      'Search fingerprint override targets';

  @override
  String get settings_loadDefaultsAction => 'Load Defaults';

  @override
  String get settings_loadHardenedDefaultsAction => 'Load Hardened Defaults';

  @override
  String get settings_fingerprintOverrideTargetsSection => 'Override Targets';

  @override
  String get settings_fingerprintInvalidOverride =>
      'The saved fingerprint overrides are not in a valid format';

  @override
  String get settings_fingerprintUnknownTarget =>
      'The saved fingerprint overrides name a target this version does not know';

  @override
  String get settings_homeAndNewTabTitle => 'Home & New Tab';

  @override
  String get settings_homeAndNewTabSubtitle =>
      'What the home and new tab pages show';

  @override
  String get settings_addressFieldLabel => 'Address';

  @override
  String get settings_homeTargetUrlEmptyError =>
      'Enter an address or the home page will be shown instead';

  @override
  String get settings_homeTargetUrlInvalidError => 'Not a valid address';

  @override
  String get settings_applyWhenLastTabClosesTitle =>
      'Apply when the last tab closes';

  @override
  String get settings_applyWhenLastTabClosesKeywords =>
      'close, last tab, container';

  @override
  String get settings_applyWhenLastTabClosesSubtitle =>
      'Closing the last tab in a container stays there instead of opening a tab from somewhere else';

  @override
  String settings_homeSearchBarCurrentlyLabel(String value) {
    return 'Currently: $value';
  }

  @override
  String get settings_wallpaperTitle => 'Wallpaper';

  @override
  String get settings_wallpaperKeywords =>
      'wallpaper, background, image, photo, picture, blur, dim, home';

  @override
  String get settings_wallpaperSetSubtitle =>
      'A background image is set for the home page';

  @override
  String get settings_wallpaperUnsetSubtitle =>
      'Set a background image for the home page';

  @override
  String get settings_customizeHomeSectionsTitle => 'Customize home sections';

  @override
  String get settings_customizeHomeSectionsKeywords =>
      'home, sections, shortcuts, quote, quick actions, reorder';

  @override
  String get settings_customizeHomeSectionsSubtitle =>
      'Choose and order what the home page shows';

  @override
  String get settings_customizeNewTabSectionsTitle =>
      'Customize new tab sections';

  @override
  String get settings_customizeNewTabSectionsKeywords =>
      'new tab, sections, shortcuts, reorder';

  @override
  String get settings_customizeNewTabSectionsSubtitle =>
      'Choose and order what the new tab page shows';

  @override
  String get settings_browserLanguagesTitle => 'Browser Languages';

  @override
  String get settings_browserLanguagesKeywords => 'locale';

  @override
  String get settings_browserLanguagesSearchHint => 'Search locales by tag';

  @override
  String get settings_languageRegionSettingsSection =>
      'Language & Region Settings';

  @override
  String get settings_browserLanguagePreferenceLabel =>
      'Browser language preference';

  @override
  String get settings_customLocaleSection => 'Custom Locale';

  @override
  String get settings_addCustomLocaleTitle => 'Add custom locale';

  @override
  String get settings_addCustomLocaleKeywords => 'locale tag';

  @override
  String get settings_addCustomLocaleSubtitle =>
      'Enter a locale tag such as en-US';

  @override
  String get settings_customLocaleFieldLabel => 'Custom Locale';

  @override
  String get settings_invalidLocaleError => 'Invalid locale identifier';

  @override
  String get settings_homeTargetHomeLabel => 'Home page';

  @override
  String get settings_homeTargetResumeLastTabLabel => 'Last opened tab';

  @override
  String get settings_homeTargetCustomUrlLabel => 'Custom address';

  @override
  String get settings_homeTargetHomeDescription =>
      'Show shortcuts and the sections you have chosen';

  @override
  String get settings_homeTargetResumeLastTabDescription =>
      'Pick up where you left off';

  @override
  String get settings_homeTargetCustomUrlDescription => 'Open a specific page';

  @override
  String get settings_homeSearchBarAutoLabel => 'Follow the tab bar';

  @override
  String get settings_homeSearchBarTopLabel => 'Top of the home page';

  @override
  String get settings_homeSearchBarTabBarLabel => 'In the tab bar';

  @override
  String get settings_homeSearchBarAutoDescription =>
      'Whichever edge the tab bar is on';

  @override
  String get settings_homeSearchBarTopDescription =>
      'A pinned search bar above the home sections';

  @override
  String get settings_homeSearchBarTabBarDescription =>
      'The tab bar\'s address field, with QR and voice search';

  @override
  String get settings_generalTitle => 'General';

  @override
  String get settings_generalSubtitle =>
      'Appearance, downloads, and browser defaults.';

  @override
  String get settings_defaultBrowserTileTitle => 'Default Browser';

  @override
  String get settings_defaultBrowserTileKeywords => 'system browser';

  @override
  String get settings_defaultBrowserTileSubtitleSet =>
      'WebLibre is your default browser';

  @override
  String get settings_defaultBrowserTileSubtitleNotSet =>
      'Set WebLibre as your default browser';

  @override
  String get settings_defaultBrowserButtonDefault => 'Default';

  @override
  String get settings_defaultBrowserButtonSet => 'Set';

  @override
  String get settings_backupProfileTitle => 'Back up this profile';

  @override
  String get settings_backupProfileKeywords =>
      'backup, archive, export, save, encrypted, restore';

  @override
  String settings_backupProfileSubtitleReady(String name) {
    return 'Write \"$name\" to an encrypted backup file';
  }

  @override
  String get settings_backupProfileSubtitleError =>
      'Could not read the active profile';

  @override
  String get settings_settingsTransferTileTitle => 'Export & Import Settings';

  @override
  String get settings_settingsTransferTileKeywords =>
      'export, import, settings, transfer, share, clipboard, json, copy, migrate';

  @override
  String get settings_settingsTransferTileSubtitle =>
      'Write settings to a file or the clipboard, and read them back';

  @override
  String get settings_uiZoomTitle => 'User Interface Zoom';

  @override
  String get settings_uiZoomKeywords => 'ui scale, zoom';

  @override
  String get settings_uiZoomSubtitle =>
      'Make the user interface smaller or larger';

  @override
  String get settings_disableAnimationsTitle => 'Disable Animations';

  @override
  String get settings_disableAnimationsKeywords => 'motion';

  @override
  String get settings_disableAnimationsSubtitle =>
      'Reduce motion and turn off app animations';

  @override
  String get settings_showModalBarrierTitle => 'Show Modal Barrier';

  @override
  String get settings_showModalBarrierKeywords =>
      'dialogs, bottom sheets, overlay';

  @override
  String get settings_showModalBarrierSubtitle =>
      'Dim the background behind dialogs and bottom sheets';

  @override
  String get settings_showSearchCloseButtonTitle => 'Show Close Button';

  @override
  String get settings_showSearchCloseButtonKeywords =>
      'back, close, dismiss, e-ink, eink, accessibility, new tab';

  @override
  String get settings_showSearchCloseButtonSubtitle =>
      'Add a button to dismiss the search or new-tab page without a back gesture. This is useful on devices without a back button.';

  @override
  String get settings_pureBlackTitle => 'Pure Black (OLED)';

  @override
  String get settings_pureBlackKeywords =>
      'oled, amoled, high contrast, black, dark';

  @override
  String get settings_pureBlackSubtitle =>
      'Use true-black surfaces in dark mode to save power on OLED screens';

  @override
  String get settings_themeTitle => 'Theme';

  @override
  String get settings_themeKeywords => 'light, dark, theme mode';

  @override
  String get settings_themeModeSystem => 'System';

  @override
  String get settings_themeModeLight => 'Light';

  @override
  String get settings_themeModeDark => 'Dark';

  @override
  String get settings_appLanguageSystemDefault => 'System default';

  @override
  String settings_appLanguageCurrentlyLabel(String language) {
    return 'Currently: $language';
  }

  @override
  String get settings_refreshRateTitle => 'Refresh Rate';

  @override
  String get settings_refreshRateKeywords =>
      'fps, hz, hertz, frame rate, framerate, 60hz, 90hz, 120hz, smooth, high refresh, display mode';

  @override
  String get settings_refreshRateSubtitle =>
      'Choose \"High\" for the smoothest scrolling and animations on 90/120Hz screens, or \"Low\" to save battery.';

  @override
  String get settings_refreshRateModeSystem => 'System';

  @override
  String get settings_refreshRateModeHigh => 'High';

  @override
  String get settings_refreshRateModeLow => 'Low';

  @override
  String get settings_downloadFolderTitle => 'Download folder';

  @override
  String get settings_downloadFolderKeywords =>
      'downloads, folder, directory, storage, save';

  @override
  String get settings_downloadFolderSubtitleDefault =>
      'Saving to the system Downloads folder';

  @override
  String settings_downloadFolderSubtitleUnavailable(String folderName) {
    return 'No longer available — saving to the system Downloads folder ($folderName)';
  }

  @override
  String get settings_downloadFolderSubtitleExternalManager =>
      'The download manager app chooses where files are saved';

  @override
  String get settings_downloadFolderResetTooltip =>
      'Use the system Downloads folder';

  @override
  String get settings_externalDownloadManagerTitle =>
      'Use external download manager';

  @override
  String get settings_externalDownloadManagerKeywords => 'downloads';

  @override
  String get settings_externalDownloadManagerSubtitle =>
      'Manage downloads with another app';

  @override
  String get settings_defaultBrowserSectionTitle => 'Default Browser';

  @override
  String get settings_defaultBrowserSectionKeywords => 'browser defaults';

  @override
  String get settings_indexDefaultBrowserSubtitle =>
      'Set WebLibre as your default browser';

  @override
  String get settings_appearanceSectionTitle => 'Appearance';

  @override
  String get settings_indexThemeSubtitle =>
      'Choose system, light, or dark mode';

  @override
  String get settings_indexAppLanguageTitle => 'App Language';

  @override
  String get settings_indexAppLanguageKeywords =>
      'locale, translation, ui language';

  @override
  String get settings_indexAppLanguageSubtitle =>
      'Choose the language WebLibre\'s own interface uses';

  @override
  String get settings_indexRefreshRateSubtitle =>
      'Request a high or low display refresh rate (Android)';

  @override
  String get settings_indexShowCloseButtonSubtitle =>
      'Add a button to dismiss the search / new-tab page without a back gesture';

  @override
  String get settings_profileSectionTitle => 'Profile';

  @override
  String get settings_profileSectionKeywords => 'user, profile';

  @override
  String get settings_indexBackupProfileSubtitle =>
      'Create an encrypted backup of the profile you are using';

  @override
  String get settings_indexSettingsTransferSubtitle =>
      'Move settings between profiles or devices, or attach them to a bug report';

  @override
  String get settings_downloadsSectionTitle => 'Downloads';

  @override
  String get settings_indexDownloadFolderSubtitle =>
      'Choose where downloaded files are saved';

  @override
  String get settings_contentIdentitySectionTitle => 'Content & Identity';

  @override
  String get settings_contentIdentitySectionKeywords => 'engine';

  @override
  String get settings_indexJavascriptSubtitle =>
      'Turn website scripting on or off';

  @override
  String get settings_indexUserAgentSubtitle =>
      'Override the browser user agent string';

  @override
  String get settings_indexEnterpriseRootsSubtitle =>
      'Allow Android CA store certificates';

  @override
  String get settings_experimentalSectionTitle => 'Experimental';

  @override
  String get settings_developerToolsSectionTitle => 'Developer Tools';

  @override
  String get settings_developerToolsSectionKeywords => 'debug';

  @override
  String get settings_indexUnmountGeckoViewSubtitle =>
      'Rebuild the web engine after an overlay, instead of keeping it warm';

  @override
  String get settings_tabsSectionTitle => 'Tabs';

  @override
  String get settings_indexTabListDirectionSubtitle =>
      'Choose how tabs are ordered in the list view';

  @override
  String get settings_indexTabBarDirectionSubtitle =>
      'Choose how tabs are ordered in the tab bar';

  @override
  String get settings_indexChildTabPlacementSubtitle =>
      'Choose where tabs opened from another tab are inserted';

  @override
  String get settings_indexCreateChildTabsSubtitle =>
      'Show a button that adds a child tab under the current tab';

  @override
  String get settings_indexBackgroundTabBehaviorSubtitle =>
      'Choose what happens after a tab opens in the background';

  @override
  String get settings_navigationSectionTitle => 'Navigation';

  @override
  String get settings_indexDoubleBackCloseTabSubtitle =>
      'Require two Back-button presses to close the current tab';

  @override
  String get settings_indexTabBarSwipesSubtitle =>
      'Choose what swipes on the tab bar do';

  @override
  String get settings_indexSequentialTabNavigationSubtitle =>
      'Choose where stepping through tabs in order ends';

  @override
  String get settings_indexOpenLinksInAppsSubtitle =>
      'Choose how external app links open';

  @override
  String get settings_desktopModeSectionTitle => 'Desktop Mode';

  @override
  String get settings_indexGlobalDesktopModeSubtitle =>
      'Open new tabs in desktop mode by default';

  @override
  String get settings_homeScreenSectionTitle => 'Home Screen';

  @override
  String get settings_indexAllowNonManifestPwaInstallSubtitle =>
      'Allow websites without a manifest to be installed as apps';

  @override
  String get settings_externalLinksSectionTitle => 'External Links';

  @override
  String get settings_indexCustomTabsSubtitle =>
      'Let other apps open links in a lightweight in-app tab, instead of the main browser';

  @override
  String get settings_bookmarksSectionTitle => 'Bookmarks';

  @override
  String get settings_resolverSettingsSectionTitle => 'Resolver Settings';

  @override
  String get settings_indexDnsOverHttpsResolverTitle => 'DNS over HTTPS';

  @override
  String get settings_indexDnsOverHttpsResolverKeywords =>
      'doh, resolver, dns provider, custom resolver';

  @override
  String get settings_indexDnsOverHttpsResolverSubtitle =>
      'Protection level, provider choice, and saved custom resolvers';

  @override
  String get settings_runtimeStartupSectionTitle => 'Runtime & Startup';

  @override
  String get settings_indexIsolatedContentProcessSubtitle =>
      'Run web content in an isolated process';

  @override
  String get settings_indexAppZygoteProcessSubtitle =>
      'Preload the content service for faster isolated startup';

  @override
  String get settings_startupSectionTitle => 'Startup';

  @override
  String get settings_startupSectionKeywords =>
      'startup, home, resume, last tab, custom url';

  @override
  String get settings_indexHomeTargetTitle => 'When there is no tab to show';

  @override
  String get settings_indexHomeTargetKeywords =>
      'startup, resume, last tab, custom url, homepage';

  @override
  String get settings_indexHomeTargetSubtitle =>
      'On startup and after closing the last tab';

  @override
  String get settings_indexHomeTargetOnLastTabClosedSubtitle =>
      'Otherwise a tab from another container is opened instead';

  @override
  String get settings_homeAppearanceSectionTitle => 'Appearance';

  @override
  String get settings_homeAppearanceSectionKeywords =>
      'home, wallpaper, background, image, blur, dim';

  @override
  String get settings_indexWallpaperSubtitle =>
      'A background image for the home page';

  @override
  String get settings_layoutSectionTitle => 'Layout';

  @override
  String get settings_layoutSectionKeywords =>
      'home, new tab, sections, modules, layout';

  @override
  String get settings_indexHomeSearchBarPlacementTitle => 'Search bar position';

  @override
  String get settings_indexHomeSearchBarPlacementKeywords =>
      'search, bar, position, address, url, top, bottom, tab bar, home';

  @override
  String get settings_indexHomeSearchBarPlacementSubtitle =>
      'Where the home page offers its search field';

  @override
  String get settings_allowlistExceptionsSectionTitle => 'Allowlist Exceptions';

  @override
  String get settings_indexAllowlistExceptionsTitle => 'Allowlist exceptions';

  @override
  String get settings_indexAllowlistExceptionsSubtitle =>
      'Compatibility exceptions for major and minor website issues';

  @override
  String get settings_cookiesSectionTitle => 'Cookies';

  @override
  String get settings_indexCookiesSubtitle =>
      'Cookie blocking mode and policy selection';

  @override
  String get settings_trackingContentSectionTitle => 'Tracking Content';

  @override
  String get settings_indexTrackingContentTitle => 'Tracking content';

  @override
  String get settings_indexTrackingContentSubtitle =>
      'Tracking scripts and scope for blocking';

  @override
  String get settings_trackersSectionTitle => 'Trackers';

  @override
  String get settings_indexTrackersSubtitle =>
      'Cryptominers, known fingerprinters, and redirect trackers';

  @override
  String get settings_advancedFingerprintingProtectionSectionTitle =>
      'Advanced Fingerprinting Protection';

  @override
  String get settings_indexAdvancedFingerprintingProtectionTitle =>
      'Advanced fingerprinting protection';

  @override
  String get settings_indexAdvancedFingerprintingProtectionSubtitle =>
      'Suspected fingerprinters and tab scope';

  @override
  String get settings_usageDataSectionTitle => 'Usage Data';

  @override
  String get settings_repositoriesSectionTitle => 'Repositories';

  @override
  String get settings_indexGeneralBangsSubtitle => 'Sync on demand from GitHub';

  @override
  String get settings_generalBangsTileTitle => 'General Bangs';

  @override
  String get settings_generalBangsTileKeywords => 'repository';

  @override
  String get settings_generalBangsTileSubtitle => 'Sync on demand from GitHub';

  @override
  String get settings_indexKagiBangsSubtitle => 'Sync on demand from GitHub';

  @override
  String get settings_kagiBangsTileTitle => 'Kagi Bangs';

  @override
  String get settings_kagiBangsTileKeywords => 'repository';

  @override
  String get settings_kagiBangsTileSubtitle => 'Sync on demand from GitHub';

  @override
  String get settings_extensionsSectionTitle => 'Extensions';

  @override
  String get settings_updatesSectionTitle => 'Updates';

  @override
  String get settings_securitySectionTitle => 'Security';

  @override
  String get settings_actionResetToDefaults => 'Reset to Defaults';

  @override
  String get settings_menuLayoutTitle => 'Customize Menu';

  @override
  String get settings_menuLayoutHintSections =>
      'Drag to reorder. Switch a section off to hide it from the menu.';

  @override
  String get settings_menuLayoutHintSectionItems =>
      'Drag to reorder the rows in this section.';

  @override
  String get settings_menuLayoutHintSubItems =>
      'Drag to reorder the rows opened from this item.';

  @override
  String get settings_moduleSurfaceHint =>
      'Drag to reorder. Switch a section off to hide it here without affecting the other page.';

  @override
  String get settings_moduleSurfaceTitleHome => 'Customize Home';

  @override
  String get settings_moduleSurfaceTitleNewTab => 'Customize New Tab';

  @override
  String get settings_homeSearchBarRowTitle => 'Search bar';

  @override
  String get settings_proxyTitle => 'Proxy';

  @override
  String get settings_proxySubtitle =>
      'Manage proxy connections and choose which tabs use them.';

  @override
  String get settings_proxyConnectionsTitle => 'Proxy Connections';

  @override
  String get settings_proxyConnectionsKeywords =>
      'sing-box, socks, vpn, wireguard, tor, onion, bridges, obfs4, snowflake';

  @override
  String get settings_proxyConnectionsSubtitle =>
      'Manage proxy profiles and connections';

  @override
  String get settings_proxyRoutingTitle => 'Proxy Routing';

  @override
  String get settings_proxyRoutingKeywords => 'routing, container';

  @override
  String get settings_proxyRoutingSubtitle =>
      'Choose which proxy carries regular and private tabs';

  @override
  String get settings_proxyLogsTitle => 'Proxy Logs';

  @override
  String get settings_proxyLogsKeywords =>
      'log, logging, logs, diagnostics, debug, trace, verbose, troubleshoot, level';

  @override
  String get settings_toolbarLayoutTitle => 'Toolbar & Layout';

  @override
  String get settings_toolbarLayoutSearchHint =>
      'Search toolbar and layout settings';

  @override
  String get settings_privacySecurityTitle => 'Privacy & Security';

  @override
  String get settings_privacySecuritySubtitle =>
      'Tracking protection, fingerprinting, browsing data, and network hardening.';

  @override
  String get settings_trackingProtectionExceptionsTitle =>
      'Tracking Protection Exceptions';

  @override
  String get settings_trackingProtectionExceptionsKeywords => 'exceptions';

  @override
  String get settings_trackingProtectionExceptionsTileSubtitle =>
      'Sites where tracking protection is disabled';

  @override
  String get settings_incognitoModeTitle => 'Incognito Mode';

  @override
  String get settings_incognitoModeKeywords => 'private mode';

  @override
  String get settings_incognitoModeSubtitle =>
      'Delete selected browsing data on app restart';

  @override
  String get settings_trackingProtectionExceptionsSearchHint =>
      'Search exception URLs';

  @override
  String get settings_trackingProtectionExceptionsDeleteAll => 'Delete All';

  @override
  String get settings_trackingProtectionExceptionsSectionTitle =>
      'Exception List';

  @override
  String get settings_trackingProtectionExceptionsEntrySubtitle =>
      'Site with tracking protection disabled';

  @override
  String get settings_trackingProtectionExceptionsRemoveTooltip =>
      'Remove exception';

  @override
  String get settings_trackingProtectionExceptionsEmptyTitle => 'No exceptions';

  @override
  String get settings_trackingProtectionExceptionsEmptySubtitle =>
      'Sites added to exceptions will appear here';

  @override
  String get settings_trackingProtectionExceptionsErrorTitle =>
      'Error loading exceptions';

  @override
  String settings_trackingProtectionExceptionsDeleteAllFailed(String error) {
    return 'Failed to delete exceptions: $error';
  }

  @override
  String settings_trackingProtectionExceptionsRemoveFailed(String error) {
    return 'Failed to remove exception: $error';
  }

  @override
  String get settings_deleteBrowsingDataTileTitle => 'Delete Browsing Data';

  @override
  String get settings_deleteBrowsingDataTileKeywords => 'clear data';

  @override
  String get settings_autoClearHistoryTitle => 'Auto-Clear History';

  @override
  String get settings_autoClearHistoryKeywords => 'history retention';

  @override
  String get settings_autoClearHistorySubtitle =>
      'Automatically delete browsing history older than the selected time period';

  @override
  String get settings_autoClearUnassignedTabsTitle =>
      'Auto-Clear Unassigned Tabs';

  @override
  String get settings_autoClearUnassignedTabsKeywords => 'cleanup tabs';

  @override
  String get settings_autoClearUnassignedTabsSubtitle =>
      'Automatically close unassigned tabs older than the selected time period';

  @override
  String get settings_durationNever => 'Never';

  @override
  String get settings_duration1Day => '1 Day';

  @override
  String get settings_duration3Days => '3 Days';

  @override
  String get settings_duration1Week => '1 Week';

  @override
  String get settings_duration2Weeks => '2 Weeks';

  @override
  String get settings_duration1Month => '1 Month';

  @override
  String get settings_duration3Months => '3 Months';

  @override
  String get settings_globalPrivacyControlTitle =>
      'Global Privacy Control (GPC)';

  @override
  String get settings_globalPrivacyControlKeywords => 'gpc';

  @override
  String get settings_screenshotProtectionTitle => 'Screenshot protection';

  @override
  String get settings_screenshotProtectionKeywords => 'screenshots';

  @override
  String get settings_screenshotProtectionSubtitle =>
      'Blocks screenshots and screen recordings for this app on Android.';

  @override
  String get settings_allowPrivateTabScreenshotsTitle =>
      'Allow screenshots in private tabs';

  @override
  String get settings_allowPrivateTabScreenshotsKeywords =>
      'screenshots, incognito, private';

  @override
  String get settings_allowPrivateTabScreenshotsOverriddenSubtitle =>
      'Overridden by screenshot protection, which blocks capture in every tab.';

  @override
  String get settings_allowPrivateTabScreenshotsSubtitle =>
      'Private tabs can be screenshotted and recorded, and appear in the app switcher preview.';

  @override
  String get settings_httpsOnlyModeTitle => 'Block insecure HTTP connections';

  @override
  String get settings_httpsOnlyModeKeywords => 'https only';

  @override
  String get settings_httpsOnlyModeDisabledLabel => 'Disabled';

  @override
  String get settings_httpsOnlyModeEnabledLabel => 'Enabled';

  @override
  String get settings_httpsOnlyModePrivateOnlyLabel => 'Private mode only';

  @override
  String get settings_dnsOverHttpsTileTitle => 'DNS over HTTPS';

  @override
  String get settings_enhancedTrackingProtectionTitle =>
      'Enhanced Tracking Protection';

  @override
  String get settings_enhancedTrackingProtectionKeywords =>
      'etp, standard, strict, custom';

  @override
  String get settings_trackingProtectionDisabledLabel => 'Disabled';

  @override
  String get settings_trackingProtectionStandardLabel => 'Standard';

  @override
  String get settings_trackingProtectionStandardSubtitle =>
      'Balances protection and compatibility by blocking fewer tracker categories.';

  @override
  String get settings_trackingProtectionStrictLabel => 'Strict';

  @override
  String get settings_trackingProtectionStrictSubtitle =>
      'Blocks more tracker categories, including tracking content, but may break some sites.';

  @override
  String get settings_trackingProtectionCustomLabel => 'Custom';

  @override
  String get settings_trackingProtectionCustomSubtitle =>
      'Choose which trackers and scripts to block.';

  @override
  String get settings_contentBlockingDatabaseTitle =>
      'Content Blocking Database';

  @override
  String get settings_contentBlockingDatabaseKeywords =>
      'ads, trackers, content blocking';

  @override
  String get settings_contentBlockingDatabaseSubtitle =>
      'Use GeckoView blocker lists for ETP categories such as ads, analytics, and social trackers. Requires an app restart.';

  @override
  String get settings_bounceTrackingProtectionTitle =>
      'Bounce Tracking Protection';

  @override
  String get settings_bounceTrackingProtectionKeywords => 'redirect trackers';

  @override
  String get settings_bounceTrackingProtectionSubtitle =>
      'Blocks redirect trackers that collect data through intermediate URL redirects between websites';

  @override
  String get settings_queryParameterStrippingTitle =>
      'Query Parameter Stripping';

  @override
  String get settings_queryParameterStrippingKeywords => 'utm';

  @override
  String get settings_queryParameterStrippingSubtitle =>
      'Removes tracking parameters from URLs to prevent cross-site user tracking';

  @override
  String get settings_queryParameterStrippingDisabledLabel => 'Disabled';

  @override
  String get settings_queryParameterStrippingEnabledLabel => 'Enabled';

  @override
  String get settings_queryParameterStrippingPrivateOnlyLabel =>
      'Private mode only';

  @override
  String get settings_uBlockFilterListsTileTitle =>
      'uBlock Filter Lists & Hardenings';

  @override
  String get settings_uBlockFilterListsTileKeywords => 'ublock, filters';

  @override
  String get settings_uBlockFilterListsTileSubtitle =>
      'Manage filter lists and apply WebLibre hardenings';

  @override
  String get settings_fissionEnabledTitle => 'Fission (Site Isolation)';

  @override
  String get settings_fissionEnabledKeywords => 'site isolation';

  @override
  String get settings_fissionEnabledSubtitle =>
      'Isolates each site into a separate OS process for improved security. Requires an app restart.';

  @override
  String get settings_safeBrowsingMalwareTitle =>
      'Safe Browsing Malware Protection';

  @override
  String get settings_safeBrowsingMalwareKeywords => 'google safe browsing';

  @override
  String get settings_safeBrowsingMalwareSubtitle =>
      'Warn about dangerous websites and malicious downloads.';

  @override
  String get settings_safeBrowsingPhishingTitle =>
      'Safe Browsing Phishing Protection';

  @override
  String get settings_safeBrowsingPhishingKeywords => 'google safe browsing';

  @override
  String get settings_safeBrowsingPhishingSubtitle =>
      'Warn about deceptive websites and login pages.';

  @override
  String get settings_extensionsWebApiTitle => 'Extensions Web API';

  @override
  String get settings_extensionsWebApiKeywords => 'extension api';

  @override
  String get settings_extensionsWebApiSubtitle =>
      'Enable mozAddonManager API exposure for web content and extension pages. Requires an app restart.';

  @override
  String get settings_appOpeningProtectionSectionHeader =>
      'App-Opening Protection';

  @override
  String get settings_blockAppsOpeningBrowserTitle =>
      'Block apps from opening your browser';

  @override
  String get settings_blockAppsOpeningBrowserKeywords =>
      'intent gatekeeper, external apps';

  @override
  String get settings_blockAppsOpeningBrowserSubtitle =>
      'Ask before opening links that other apps send to WebLibre.';

  @override
  String get settings_managedAppsSectionHeader => 'Managed apps';

  @override
  String get settings_managedAppAlwaysAllowedLabel => 'Always allowed';

  @override
  String get settings_managedAppAlwaysBlockedLabel => 'Always blocked';

  @override
  String get settings_managedAppActionAllow => 'Allow';

  @override
  String get settings_managedAppActionBlock => 'Block';

  @override
  String get settings_browserLanguagesTileTitle => 'Browser Languages';

  @override
  String get settings_browserLanguagesTileSubtitle =>
      'Configure language preferences exposed to websites';

  @override
  String get settings_fingerprintProtectionTileTitle =>
      'Fingerprint Protection';

  @override
  String get settings_fingerprintProtectionTileSubtitle =>
      'Granular control over browser fingerprinting';

  @override
  String get settings_resistFingerprintingTileTitle => 'Resist Fingerprinting';

  @override
  String get settings_resistFingerprintingTileKeywords => 'rfp';

  @override
  String get settings_resistFingerprintingTileSubtitle =>
      'Advanced fingerprinting protection hardening';

  @override
  String get settings_lnaEnabledTitle => 'Local Network Access';

  @override
  String get settings_lnaEnabledKeywords => 'lan';

  @override
  String get settings_lnaEnabledSubtitle =>
      'Enable local network and device access blocking';

  @override
  String get settings_lnaBlockingTitle => 'Block Local Network Requests';

  @override
  String get settings_lnaBlockingKeywords => 'lan';

  @override
  String get settings_lnaBlockingSubtitle =>
      'Block web page requests to local network addresses';

  @override
  String get settings_lnaBlockTrackersTitle => 'Block Local Network Trackers';

  @override
  String get settings_lnaBlockTrackersKeywords => 'lan';

  @override
  String get settings_lnaBlockTrackersSubtitle =>
      'Block trackers from accessing local network resources';

  @override
  String get settings_transferTitle => 'Export & Import';

  @override
  String get settings_transferChangeExportFolder => 'Change export folder';

  @override
  String get settings_transferIntro =>
      'Move settings between profiles or devices, or attach them to a bug report. This carries settings only — no tabs, history, bookmarks, or logins. To transfer those, back up the whole profile.';

  @override
  String get settings_transferDeviceOnlyNote =>
      'Web search preferences, home and new-tab layout, menu order and pinned add-ons stay on this device';

  @override
  String get settings_transferExportSectionTitle => 'Export';

  @override
  String get settings_transferExportSectionSubtitle =>
      'Export the selected sections to a readable file';

  @override
  String get settings_transferSaveFileButton => 'Save file';

  @override
  String get settings_transferImportSectionTitle => 'Import';

  @override
  String get settings_transferImportSectionSubtitle =>
      'Choose which settings to apply after opening the file';

  @override
  String get settings_transferOpenFileButton => 'Open file';

  @override
  String get settings_transferPasteButton => 'Paste';

  @override
  String settings_transferExportFolderChanged(String name) {
    return 'Exports will be saved to $name';
  }

  @override
  String settings_transferSavedAs(String name) {
    return 'Saved as $name';
  }

  @override
  String get settings_transferExportFolderGone =>
      'The export folder is no longer there. Choose one again and retry.';

  @override
  String settings_transferSaveFailed(String error) {
    return 'Could not save the export: $error';
  }

  @override
  String get settings_transferCopiedToClipboard =>
      'Settings copied to the clipboard';

  @override
  String settings_transferCopyFailed(String error) {
    return 'Could not copy the export: $error';
  }

  @override
  String get settings_transferImportNothingApplicable =>
      'This export holds nothing this version of WebLibre can apply.';

  @override
  String get settings_transferImportedSuccess => 'Settings imported';

  @override
  String settings_transferImportFailed(String error) {
    return 'Could not import the settings: $error';
  }

  @override
  String get settings_transferNotASettingsFile =>
      'That file is not a settings export.';

  @override
  String settings_transferReadFileFailed(String error) {
    return 'Could not read the file: $error';
  }

  @override
  String get settings_transferClipboardEmpty => 'The clipboard is empty.';

  @override
  String settings_transferReadClipboardFailed(String error) {
    return 'Could not read the clipboard: $error';
  }

  @override
  String get settings_transferSectionAppSettingsTitle => 'App settings';

  @override
  String settings_transferSectionAppSettingsDescription(String torBrand) {
    return 'Appearance, browsing, tabs, privacy, $torBrand and web engine settings';
  }

  @override
  String get settings_transferSectionGeckoPrefsTitle => 'Gecko preferences';

  @override
  String get settings_transferSectionGeckoPrefsDescription =>
      'Advanced engine preferences you changed by hand';

  @override
  String get settings_importErrorNotJson => 'This is not a JSON file.';

  @override
  String get settings_importErrorNotSettingsExport =>
      'This is not a WebLibre settings export.';

  @override
  String get settings_importErrorMissingFormatVersion =>
      'The export does not say which format version it is.';

  @override
  String settings_importErrorNewerFormatVersion(int version, int supported) {
    return 'This export was written by a newer version of WebLibre (format $version, this version reads up to $supported). Update the app and try again.';
  }

  @override
  String get settings_importErrorNoSettings =>
      'The export contains no settings.';

  @override
  String settings_importErrorMalformedSection(String section) {
    return 'The \"$section\" section is malformed.';
  }

  @override
  String settings_importErrorMalformedField(String field) {
    return 'The export\'s \"$field\" field is malformed.';
  }

  @override
  String settings_importErrorUnreadablePrefsLine(String section, String line) {
    return 'The \"$section\" section has a line WebLibre cannot read: \"$line\". Importing it would reset preferences rather than restore them.';
  }

  @override
  String settings_importErrorNotPrefsSnapshot(String section) {
    return 'The \"$section\" section is not a WebLibre preferences snapshot.';
  }

  @override
  String settings_importErrorMissingSchemaVersion(String section) {
    return 'The \"$section\" section does not say which schema version it is.';
  }

  @override
  String settings_importErrorUnreadablePref(String section, String pref) {
    return 'The \"$section\" section holds a preference WebLibre could not read back: \"$pref\".';
  }

  @override
  String settings_importErrorNewerSectionSchema(
    String section,
    int version,
    int supported,
  ) {
    return 'The \"$section\" section was written by a newer version of WebLibre (schema $version, this version reads up to $supported). Update the app and try again.';
  }

  @override
  String settings_importPartialFailure(String failed, String error) {
    return 'The \"$failed\" section stopped part way through and may be half-applied: $error';
  }

  @override
  String settings_importPartialFailureAfterApplied(
    String applied,
    String failed,
    String error,
  ) {
    return 'Imported: $applied. The \"$failed\" section then stopped part way through and may be half-applied: $error';
  }

  @override
  String get settings_webEngineHardeningTitle => 'Web Engine Hardening';

  @override
  String get settings_webEngineHardeningKeywords => 'hardening';

  @override
  String get settings_webEngineHardeningSearchHint => 'Search hardening groups';

  @override
  String get settings_webEngineHardeningResetAllMenuItem =>
      'Reset all preferences';

  @override
  String get settings_webEngineHardeningResetAllDialogTitle =>
      'Reset all preferences?';

  @override
  String get settings_webEngineHardeningResetAllDialogContent =>
      'This will reset all user-defined web engine preferences to their defaults.';

  @override
  String get settings_webEngineHardeningOverviewTitle => 'Overview';

  @override
  String get settings_webEngineHardeningCompleteTitle => 'Complete Hardening';

  @override
  String get settings_webEngineHardeningCompleteSubtitle =>
      'Apply or reset all grouped hardening preferences';

  @override
  String get settings_webEngineHardeningCompleteToggleHint =>
      'Toggle all grouped hardening preferences at once.';

  @override
  String get settings_webEngineHardeningGroupsTitle => 'Hardening Groups';

  @override
  String get settings_webEngineHardeningLoadFailedTitle =>
      'Could not load preference settings';

  @override
  String get settings_webEngineHardeningGroupSearchHint =>
      'Search hardening settings';

  @override
  String get settings_webEngineHardeningGroupControlsTitle => 'Group Controls';

  @override
  String get settings_webEngineHardeningPreferenceSettingsTitle =>
      'Preference Settings';

  @override
  String get settings_webEngineHardeningOptionalBadge => 'Optional';

  @override
  String get settings_settingsHomeTitle => 'Settings';

  @override
  String get settings_settingsHomeSearchHint => 'Search all settings';

  @override
  String get settings_searchTitle => 'Search';

  @override
  String get settings_searchSubtitle =>
      'Providers, bangs, history suggestions, and on-device search.';

  @override
  String get settings_defaultSearchProviderTitle => 'Default Search Provider';

  @override
  String get settings_defaultSearchProviderKeywords => 'search engine';

  @override
  String get settings_defaultAutocompleteProviderTitle =>
      'Default Autocomplete Provider';

  @override
  String get settings_defaultAutocompleteProviderKeywords => 'suggestions';

  @override
  String get settings_customSearchEnginesTitle => 'Custom Search Engines';

  @override
  String get settings_customSearchEnginesKeywords => 'user bangs, providers';

  @override
  String get settings_customSearchEnginesSubtitle =>
      'Add and manage your own search providers';

  @override
  String get settings_bangSettingsListTitle => 'Bang Settings';

  @override
  String get settings_bangSettingsListSubtitle =>
      'Manage bang repositories and usage data';

  @override
  String get settings_searchHistoryLimitTitle => 'Search History Limit';

  @override
  String get settings_searchHistoryLimitKeywords => 'history, entries';

  @override
  String get settings_searchHistoryLimitSubtitle =>
      'Maximum number of recent searches to remember';

  @override
  String get settings_searchHistoryLimitSuffix => 'entries';

  @override
  String get settings_validationEnterValue => 'Please enter a value';

  @override
  String get settings_validationEnterValidNumber =>
      'Please enter a valid number';

  @override
  String get settings_validationValueBetween0And100 =>
      'Value must be between 0 and 100';

  @override
  String get settings_allowClipboardAccessTitle =>
      'Allow clipboard access for suggestions';

  @override
  String get settings_allowClipboardAccessKeywords => 'clipboard';

  @override
  String get settings_allowClipboardAccessSubtitle =>
      'The browser can read the clipboard to suggest URLs';

  @override
  String get settings_acceptSuggestionOnSubmitTitle => 'Autocomplete on Enter';

  @override
  String get settings_acceptSuggestionOnSubmitKeywords =>
      'submit, keyboard, suggestions';

  @override
  String get settings_acceptSuggestionOnSubmitSubtitle =>
      'Accept the inline suggestion when pressing Enter on the keyboard';

  @override
  String get settings_popularSitesAutocompleteTitle =>
      'Popular site suggestions';

  @override
  String get settings_popularSitesAutocompleteKeywords =>
      'popular sites, domains, ghost text, autocomplete';

  @override
  String get settings_popularSitesAutocompleteSubtitle =>
      'Complete typed text with well-known domains when your history has no match';

  @override
  String get settings_localIndexEnabledTitle => 'Enable local search index';

  @override
  String get settings_localIndexEnabledKeywords => 'page text, history';

  @override
  String get settings_localIndexEnabledSubtitle =>
      'Index visited pages locally so the browser can search their content. Visit metadata stays in the engine; only page text is stored on-device.';

  @override
  String get settings_indexPrivateTabsTitle => 'Index private tabs';

  @override
  String get settings_indexPrivateTabsKeywords => 'incognito';

  @override
  String get settings_indexPrivateTabsSubtitle =>
      'Include pages opened in private tabs in the local index. Off by default.';

  @override
  String get settings_clearLocalIndexDialogTitle => 'Clear local search index?';

  @override
  String get settings_clearLocalIndexDialogContent =>
      'This removes all locally indexed page content. Engine history (visit metadata) is not affected.';

  @override
  String get settings_localIndexStatsTitle => 'Indexed pages';

  @override
  String get settings_localIndexStatsKeywords => 'clear index, stats';

  @override
  String settings_localIndexPagesIndexed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages indexed',
      one: '1 page indexed',
    );
    return '$_temp0';
  }

  @override
  String get settings_searchSectionProvidersTitle => 'Providers';

  @override
  String get settings_searchSectionProvidersKeywords => 'engines';

  @override
  String get settings_searchSectionBangShortcutsTitle => 'Bang Shortcuts';

  @override
  String get settings_searchSectionBangShortcutsKeywords => 'bangs';

  @override
  String get settings_searchSectionHistorySuggestionsTitle =>
      'History & Suggestions';

  @override
  String get settings_searchSectionLocalIndexTitle => 'Local Search Index';

  @override
  String get settings_searchSectionLocalIndexKeywords =>
      'on device search, index';

  @override
  String get settings_indexDefaultSearchProviderSubtitle =>
      'Choose the default engine for searches';

  @override
  String get settings_indexDefaultAutocompleteProviderSubtitle =>
      'Choose the provider for search suggestions';

  @override
  String get settings_indexAcceptSuggestionOnSubmitSubtitle =>
      'Accept the inline suggestion when pressing enter';

  @override
  String get settings_indexPopularSitesAutocompleteSubtitle =>
      'Complete typed text with well-known domains';

  @override
  String get settings_indexLocalIndexEnabledSubtitle =>
      'Index visited pages locally for content search';

  @override
  String get settings_indexIndexPrivateTabsSubtitle =>
      'Include private tabs in the local index';

  @override
  String get settings_indexLocalIndexStatsSubtitle =>
      'View and clear the local index';

  @override
  String get settings_webContentTitle => 'Web Content';

  @override
  String get settings_webContentSubtitle =>
      'Text rendering, reader mode, PDFs, and local AI features.';

  @override
  String get settings_webFontsTitle => 'Web Fonts';

  @override
  String get settings_webFontsKeywords => 'fonts';

  @override
  String get settings_webFontsSubtitle => 'Allow websites to use custom fonts';

  @override
  String get settings_automaticFontSizeTitle => 'Automatic Font Size';

  @override
  String get settings_automaticFontSizeKeywords => 'text size';

  @override
  String get settings_automaticFontSizeSubtitle =>
      'Automatically adjust font size based on system settings. Disable to manually control font size factor and inflation.';

  @override
  String get settings_fontSizeFactorTitle => 'Font Size Factor';

  @override
  String get settings_fontSizeFactorKeywords => 'zoom, text';

  @override
  String get settings_fontSizeFactorSubtitle => 'Scale web page text size';

  @override
  String get settings_disabledWhileAutomaticFontSize =>
      'Disabled while automatic font size is enabled';

  @override
  String get settings_fontInflationTitle => 'Font Inflation';

  @override
  String get settings_fontInflationKeywords => 'readability';

  @override
  String get settings_fontInflationSubtitle =>
      'Enlarge text on pages that lack a mobile viewport meta tag';

  @override
  String get settings_inputAutoZoomTitle => 'Input Auto Zoom';

  @override
  String get settings_inputAutoZoomKeywords => 'forms';

  @override
  String get settings_inputAutoZoomSubtitle =>
      'Automatically zoom in when focusing text inputs';

  @override
  String get settings_forceUserScalableTitle => 'Zoom on All Websites';

  @override
  String get settings_forceUserScalableKeywords => 'pinch, accessibility';

  @override
  String get settings_forceUserScalableSubtitle =>
      'Allow pinch and zoom, even on websites that prevent this gesture';

  @override
  String get settings_pdfViewerTitle => 'Built-in PDF Viewer';

  @override
  String get settings_pdfViewerKeywords => 'pdf';

  @override
  String get settings_pdfViewerSubtitle =>
      'Open PDF files directly in the browser without downloading';

  @override
  String get settings_enableReaderModeTitle => 'Enable Reader Mode';

  @override
  String get settings_enableReaderModeKeywords => 'reader, readability';

  @override
  String get settings_enableReaderModeSubtitle =>
      'Adds an optional tool to the browser app bar that simplifies web pages by removing ads, sidebars, and other nonessential elements.';

  @override
  String get settings_enforceReaderModeTitle => 'Enforce Reader Mode';

  @override
  String get settings_enforceReaderModeKeywords => 'reader';

  @override
  String get settings_enforceReaderModeSubtitle =>
      'Ignore a site\'s readability score and always show Reader Mode, even on sites that may not support it.';

  @override
  String get settings_onDeviceAiTitle => 'On-device AI';

  @override
  String get settings_onDeviceAiKeywords => 'local ai, suggestions';

  @override
  String get settings_onDeviceAiSubtitle =>
      'On-device features such as suggesting containers for your open tabs and names for them';

  @override
  String get settings_webContentSectionDisplayTitle => 'Display';

  @override
  String get settings_webContentSectionContentFeaturesTitle =>
      'Content Features';

  @override
  String get settings_indexAutomaticFontSizeSubtitle =>
      'Adjust font size based on system settings';

  @override
  String get settings_indexFontInflationSubtitle =>
      'Enlarge text on pages without a mobile viewport';

  @override
  String get settings_indexInputAutoZoomSubtitle =>
      'Automatically zoom when focusing text inputs';

  @override
  String get settings_indexPdfViewerSubtitle =>
      'Open PDF files directly in the browser';

  @override
  String get settings_indexEnableReaderModeSubtitle =>
      'Extract and simplify pages for readability';

  @override
  String get settings_indexEnforceReaderModeSubtitle =>
      'Always show Reader Mode capabilities';

  @override
  String get settings_indexOnDeviceAiSubtitle =>
      'Local AI features including topic and tab suggestions';

  @override
  String get settings_ublockListsTitle => 'uBlock Filter Lists';

  @override
  String get settings_ublockListsSearchHint =>
      'Search lists, groups, and external URLs';

  @override
  String get settings_ublockSectionManagement => 'Management';

  @override
  String get settings_ublockSectionQuickActions => 'Quick Actions';

  @override
  String get settings_ublockSectionFilterLists => 'Filter Lists';

  @override
  String get settings_ublockSectionExternalLists => 'External Lists';

  @override
  String get settings_actionApply => 'Apply';

  @override
  String get settings_ublockResetDialogTitle => 'Reset to defaults?';

  @override
  String get settings_ublockResetDialogMessage =>
      'This will restore uBlock Origin to its default filter list configuration and remove any external lists you added.';

  @override
  String get settings_ublockApplyHardeningsDialogTitle =>
      'Apply WebLibre Hardenings?';

  @override
  String get settings_ublockApplyHardeningsDialogMessage =>
      'This will enable a curated set of additional filter lists and add a legitimate URL shortener list as an external list.';

  @override
  String get settings_ublockInfoBannerMessage =>
      'Changes to uBlock Origin filter lists require an app restart to take effect. Due to caching, some changes may need a few minutes and an additional restart to fully apply.';

  @override
  String settings_ublockLoadFailed(String error) {
    return 'Failed to load filter list assets: $error';
  }

  @override
  String get settings_ublockQuickResetTitle => 'Reset to defaults';

  @override
  String get settings_ublockQuickResetSubtitle =>
      'Restore uBlock Origin\'s default filter list configuration.';

  @override
  String get settings_ublockQuickApplyHardeningsTitle =>
      'Apply WebLibre Hardenings';

  @override
  String get settings_ublockQuickApplyHardeningsSubtitle =>
      'Enable a curated set of additional filter lists.';

  @override
  String get settings_ublockManageTitle => 'Manage with WebLibre';

  @override
  String get settings_ublockManageSubtitle =>
      'WebLibre controls uBlock Origin\'s enabled filter lists at the next browser start.';

  @override
  String get settings_ublockManageHint =>
      'Enabling management starts from uBO\'s common baseline lists and preserves My filters.';

  @override
  String get settings_ublockAutoSelectTitle => 'Auto-select languages';

  @override
  String get settings_ublockAutoSelectSubtitle =>
      'Enable regional filter lists matching your device languages.';

  @override
  String get settings_ublockAutoSelectedTooltip =>
      'Auto-selected for your language';

  @override
  String get settings_ublockDefaultOnTooltip => 'Default on';

  @override
  String get settings_ublockVisitSupportTooltip => 'Visit support page';

  @override
  String get settings_ublockExternalListsHint =>
      'Raw URLs are forwarded to uBlock Origin as external lists. Descriptions are only shown here in WebLibre.';

  @override
  String get settings_ublockNoExternalLists => 'No external lists configured.';

  @override
  String settings_ublockNoExternalListsMatch(String query) {
    return 'No external lists match \"$query\".';
  }

  @override
  String get settings_ublockAddExternalListButton => 'Add external list';

  @override
  String get settings_ublockEditListDialogTitle => 'Edit external filter list';

  @override
  String get settings_ublockAddListDialogTitle => 'Add external filter list';

  @override
  String get settings_ublockListUrlLabel => 'List URL';

  @override
  String get settings_ublockListUrlAlreadyAdded => 'Already added';

  @override
  String get settings_ublockDescriptionLabel => 'Description (optional)';

  @override
  String get settings_ublockDescriptionHint => 'e.g. Annoyances — myAuthor';

  @override
  String get settings_ublockGroupDefault => 'Default';

  @override
  String get settings_ublockGroupAds => 'Ads';

  @override
  String get settings_ublockGroupPrivacy => 'Privacy';

  @override
  String get settings_ublockGroupMalware => 'Malware';

  @override
  String get settings_ublockGroupAnnoyances => 'Annoyances';

  @override
  String get settings_ublockGroupMultipurpose => 'Multipurpose';

  @override
  String get settings_ublockGroupRegions => 'Regions';

  @override
  String get settings_categoryGeneralTitle => 'General';

  @override
  String get settings_categoryGeneralKeywords =>
      'theme, ui zoom, default browser';

  @override
  String get settings_categoryGeneralSubtitle => 'Appearance, downloads';

  @override
  String get settings_categoryBrowsingTitle => 'Browsing';

  @override
  String get settings_categoryBrowsingKeywords =>
      'tabs, small web, url cleaner, unshortener';

  @override
  String get settings_categoryBrowsingSubtitle =>
      'Tabs, navigation, external links';

  @override
  String get settings_categoryHomeNewTabTitle => 'Home & New Tab';

  @override
  String get settings_categoryHomeNewTabKeywords =>
      'home, new tab, start page, sections, shortcuts, top sites, quote, wallpaper, background';

  @override
  String get settings_categoryHomeNewTabSubtitle =>
      'What the home and new tab pages show';

  @override
  String get settings_categoryGesturesTitle => 'Gestures';

  @override
  String get settings_categoryGesturesKeywords =>
      'gesture, swipe, stroke, tab bar, long press, pinch';

  @override
  String get settings_categoryGesturesSubtitle =>
      'Swipes on the tab bar and tabs, drawn gestures';

  @override
  String get settings_categoryKeyboardShortcutsTitle => 'Keyboard Shortcuts';

  @override
  String get settings_categoryKeyboardShortcutsKeywords =>
      'keyboard, shortcut, hotkey, key binding';

  @override
  String get settings_categoryKeyboardShortcutsSubtitle =>
      'Hardware keyboard keys for browser actions';

  @override
  String get settings_categoryToolbarLayoutTitle => 'Toolbar & Layout';

  @override
  String get settings_categoryToolbarLayoutKeywords =>
      'contextual toolbar, quick tab switcher';

  @override
  String get settings_categoryToolbarLayoutSubtitle =>
      'Tab bar, toolbar, quick switcher, tab view';

  @override
  String get settings_categoryWebContentTitle => 'Web Content';

  @override
  String get settings_categoryWebContentKeywords => 'reader mode, pdf, fonts';

  @override
  String get settings_categoryWebContentSubtitle =>
      'Page display, PDF, reader mode, AI';

  @override
  String get settings_categoryNotificationsTitle => 'Notifications';

  @override
  String get settings_categoryNotificationsKeywords =>
      'push, unifiedpush, ntfy, distributor';

  @override
  String get settings_categoryNotificationsSubtitle =>
      'Web push delivery, distributor, site subscriptions';

  @override
  String get settings_categorySearchTitle => 'Search';

  @override
  String get settings_categorySearchKeywords =>
      'bangs, suggestions, local search index';

  @override
  String get settings_categorySearchSubtitle =>
      'Providers, bangs, search history';

  @override
  String get settings_categoryPrivacySecurityTitle => 'Privacy & Security';

  @override
  String get settings_categoryPrivacySecurityKeywords =>
      'fingerprinting, https, doh, safe browsing, network protection';

  @override
  String get settings_categoryPrivacySecuritySubtitle =>
      'Tracking protection, data clearing';

  @override
  String get settings_categoryProxyTitle => 'Proxy';

  @override
  String get settings_categoryProxyKeywords =>
      'proxy, sing-box, socks, vpn, wireguard, routing, tor, container';

  @override
  String get settings_categoryProxySubtitle => 'Connections and routing';

  @override
  String get settings_categoryExtensionsTitle => 'Extensions';

  @override
  String get settings_categoryExtensionsKeywords =>
      'addons, unsigned extensions';

  @override
  String get settings_categoryExtensionsSubtitle =>
      'Install and manage extension sources';

  @override
  String get settings_categoryAccountTitle => 'WebLibre Account';

  @override
  String get settings_categoryAccountKeywords => 'account, subscription';

  @override
  String get settings_categoryAccountSubtitle => 'Sign in, sync settings';

  @override
  String get settings_categorySyncTitle => 'Firefox Sync';

  @override
  String get settings_categorySyncKeywords => 'pair, device name, engines';

  @override
  String get settings_categorySyncSubtitle =>
      'Account, sync now, engine selection';

  @override
  String get settings_categoryAdvancedTitle => 'Advanced';

  @override
  String get settings_categoryAdvancedKeywords =>
      'experimental, error logs, javascript';

  @override
  String get settings_categoryAdvancedSubtitle =>
      'JavaScript, user agent, debugging';

  @override
  String get settings_categoryGroupBrowserTitle => 'Browser';

  @override
  String get settings_categoryGroupServicesAdvancedTitle =>
      'Services & Advanced';

  @override
  String get settings_privacySectionTrackingProtectionTitle =>
      'Tracking Protection';

  @override
  String get settings_privacySectionTrackingProtectionKeywords => 'privacy';

  @override
  String get settings_indexEnhancedTrackingProtectionSubtitle =>
      'Choose how aggressively trackers are blocked';

  @override
  String get settings_indexContentBlockingDatabaseSubtitle =>
      'Use GeckoView blocker lists for ETP categories';

  @override
  String get settings_indexBounceTrackingProtectionSubtitle =>
      'Remove tracking state left by redirect-based trackers';

  @override
  String get settings_indexQueryParameterStrippingSubtitle =>
      'Remove tracking parameters from URLs';

  @override
  String get settings_privacySectionFingerprintingTitle => 'Fingerprinting';

  @override
  String get settings_indexBrowserLanguagesSubtitle =>
      'Choose which languages websites can see';

  @override
  String get settings_privacySectionConnectionSecurityTitle =>
      'Connection Security';

  @override
  String get settings_indexHttpsOnlyModeSubtitle =>
      'Prefer HTTPS and block insecure connections';

  @override
  String get settings_indexDnsOverHttpsTitle => 'DNS over HTTPS';

  @override
  String get settings_indexDnsOverHttpsKeywords => 'doh';

  @override
  String get settings_indexDnsOverHttpsSubtitle => 'Encrypt DNS lookups';

  @override
  String get settings_privacySectionNetworkProtectionTitle =>
      'Network Protection';

  @override
  String get settings_indexLnaBlockingSubtitle =>
      'Block requests to local network devices and services';

  @override
  String get settings_indexLnaBlockTrackersSubtitle =>
      'Block tracker-like local network requests';

  @override
  String get settings_privacySectionSignalsModesTitle =>
      'Privacy Signals & Modes';

  @override
  String get settings_indexScreenshotProtectionSubtitle =>
      'Prevent app content from appearing in screenshots';

  @override
  String get settings_indexAllowPrivateTabScreenshotsSubtitle =>
      'Let the system capture private tabs';

  @override
  String get settings_indexGlobalPrivacyControlSubtitle =>
      'Send a privacy preference signal to websites';

  @override
  String get settings_privacySectionAppOpeningProtectionTitle =>
      'App-Opening Protection';

  @override
  String get settings_indexAppOpeningProtectionSubtitle =>
      'Control which apps may launch WebLibre directly';

  @override
  String get settings_privacySectionDataManagementTitle => 'Data Management';

  @override
  String get settings_indexDeleteBrowsingDataSubtitle =>
      'Clear history, cookies, and other browsing data';

  @override
  String get settings_indexAutoClearHistorySubtitle =>
      'Automatically clear history after a chosen duration';

  @override
  String get settings_indexAutoClearUnassignedTabsSubtitle =>
      'Automatically close tabs not assigned to a container';

  @override
  String get settings_privacySectionSafeBrowsingTitle => 'Google Safe Browsing';

  @override
  String get settings_indexSafeBrowsingMalwareSubtitle =>
      'Warn about malware and harmful downloads';

  @override
  String get settings_indexSafeBrowsingPhishingSubtitle =>
      'Warn about deceptive websites and login pages';

  @override
  String get settings_privacySectionAdvancedSecurityTitle =>
      'Advanced Security';

  @override
  String get settings_indexWebEngineHardeningSubtitle =>
      'Harden browser engine behavior and defaults';

  @override
  String get settings_indexFissionEnabledSubtitle =>
      'Use stronger site isolation between origins';

  @override
  String get settings_indexExtensionsWebAPIEnabledSubtitle =>
      'Allow extensions to expose web APIs to pages';

  @override
  String get settings_proxySectionTitle => 'Proxy';

  @override
  String get settings_indexProxyLogsSubtitle =>
      'Read the proxy log and set how much it records';

  @override
  String get settings_saveAndUse => 'Save and use';

  @override
  String get settings_replace => 'Replace';

  @override
  String get settings_later => 'Later';

  @override
  String get settings_restartNow => 'Restart Now';

  @override
  String get settings_sync => 'Sync';

  @override
  String get settings_chooseSearchProvider => 'Choose a search provider';

  @override
  String get settings_entriesLabel => 'Entries';

  @override
  String get settings_lastSyncLabel => 'Last Sync';

  @override
  String get settings_notAvailable => 'N/A';

  @override
  String get settings_protectionLevelTitle => 'Protection Level';

  @override
  String get settings_protectionLevelDescription =>
      'Domain Name System (DNS) over HTTPS sends domain-name requests through an encrypted connection, protecting them and making it harder for others to see which websites you’re about to visit.';

  @override
  String get settings_defaultProtectionTitle => 'Default Protection';

  @override
  String get settings_defaultProtectionSubtitle =>
      'DoH used only when default DNS fails';

  @override
  String get settings_increasedProtectionTitle => 'Increased Protection';

  @override
  String get settings_increasedProtectionSubtitle =>
      'DoH preferred, default DNS as fallback';

  @override
  String get settings_maxProtectionTitle => 'Max Protection';

  @override
  String get settings_maxProtectionSubtitle => 'DoH only, no fallback';

  @override
  String get settings_protectionOffTitle => 'Off';

  @override
  String get settings_protectionOffSubtitle => 'Use your default DNS resolver';

  @override
  String get settings_dohProviderTitle => 'DoH Provider';

  @override
  String get settings_yourResolvers => 'Your resolvers';

  @override
  String get settings_addCustomResolver => 'Add custom resolver';

  @override
  String get settings_editCustomResolverTitle => 'Edit custom resolver';

  @override
  String get settings_resolverUrlLabel => 'Resolver URL';

  @override
  String get settings_alreadyBuiltInProvider =>
      'Already available as a built-in provider';

  @override
  String get settings_alreadyAdded => 'Already added';

  @override
  String get settings_resolverNameLabel => 'Name (optional)';

  @override
  String get settings_resolverNameHint => 'e.g. dnsforge (adblock)';

  @override
  String get settings_searchHint => 'Search settings';

  @override
  String get settings_noSettingsAvailable => 'No settings available.';

  @override
  String settings_noSettingsMatch(String query) {
    return 'No settings match \"$query\".';
  }

  @override
  String get settings_stringListEditorEmpty => 'Nothing added yet.';

  @override
  String get settings_customizeMenu => 'Customize Menu';

  @override
  String get settings_customizeMenuKeywords => 'sections, rows, reorder';

  @override
  String get settings_customizeMenuSubtitle =>
      'Choose and order the sections and rows of the three-dot menu';

  @override
  String get settings_tabBarPositionTitle => 'Tab Bar Position';

  @override
  String get settings_tabBarPositionKeywords => 'top, bottom';

  @override
  String settings_currentlyResolvesTo(String text, String value) {
    return '$text (currently: $value)';
  }

  @override
  String get settings_tabBarPositionAutoLabel => 'Automatic';

  @override
  String get settings_tabBarPositionTopLabel => 'Top';

  @override
  String get settings_tabBarPositionBottomLabel => 'Bottom';

  @override
  String get settings_tabBarPositionLeftLabel => 'Left';

  @override
  String get settings_tabBarPositionRightLabel => 'Right';

  @override
  String get settings_tabBarPositionAutoDescription =>
      'A side rail on large screens, a bottom bar on phones';

  @override
  String get settings_tabBarPositionTopDescription =>
      'Persistent tab bar without auto-hide';

  @override
  String get settings_tabBarPositionBottomDescription =>
      'Tab bar with auto-hide support';

  @override
  String get settings_tabBarPositionLeftDescription =>
      'Vertical side rail, swipe to hide';

  @override
  String get settings_tabBarPositionRightDescription =>
      'Vertical side rail, swipe to hide';

  @override
  String get settings_tabBarStyleTitle => 'Tab Bar Style';

  @override
  String get settings_tabBarStyleKeywords => 'layout, compact';

  @override
  String get settings_withTitleOption => 'With Title';

  @override
  String get settings_withTitleDescription =>
      'Shows page title and URL breadcrumb';

  @override
  String get settings_compactOption => 'Compact';

  @override
  String get settings_compactDescription =>
      'Centered URL pill without page title';

  @override
  String get settings_showContextualToolbarTitle => 'Show Contextual Toolbar';

  @override
  String get settings_showContextualToolbarKeywords => 'bottom toolbar';

  @override
  String get settings_showContextualToolbarSubtitle =>
      'Show additional bottom toolbar for navigation and actions';

  @override
  String get settings_customizeToolbarButtons => 'Customize Toolbar Buttons';

  @override
  String get settings_customizeToolbarButtonsKeywords => 'buttons';

  @override
  String get settings_customizeSwitcherButtons => 'Customize Switcher Buttons';

  @override
  String get settings_customizeSwitcherButtonsKeywords =>
      'buttons, new tab, actions, trailing';

  @override
  String get settings_customizeSwitcherButtonsSubtitle =>
      'Action buttons pinned at the end of the switcher bar (independent of the contextual toolbar)';

  @override
  String get settings_tabStackingTitle => 'Tab Stacking';

  @override
  String get settings_tabStackingKeywords =>
      'recent tabs, recently used, container tabs, accordion, two level, rows, stacking, disabled';

  @override
  String get settings_tabStackingSubtitle =>
      'How the quick tab switcher bar arranges its tabs';

  @override
  String get settings_recentlyUsedTabsOption => 'Recently Used Tabs';

  @override
  String get settings_recentlyUsedTabsDescription =>
      'Recently used tabs across all containers';

  @override
  String get settings_containerTabsOption => 'Container Tabs';

  @override
  String get settings_containerTabsDescription =>
      'Ordered tabs of the selected container';

  @override
  String get settings_accordionOption => 'Accordion';

  @override
  String get settings_accordionDescription =>
      'All containers as chips, with the selected container\'s tabs expanded inline';

  @override
  String get settings_twoRowsOption => 'Two Rows';

  @override
  String get settings_twoRowsDescription =>
      'Tabs of the selected container on top, recently used tabs below';

  @override
  String get settings_disabledOption => 'Disabled';

  @override
  String get settings_disabledDescription => 'Hide the quick tab switcher bar';

  @override
  String get settings_closeButtonsTitle => 'Close Buttons on Tab Chips';

  @override
  String get settings_closeButtonsKeywords => 'close, x button, active tab';

  @override
  String get settings_closeButtonsSubtitle =>
      'Which switcher chips show a close button';

  @override
  String get settings_activeTabOnlyOption => 'Active Tab Only';

  @override
  String get settings_activeTabOnlyDescription =>
      'Only the chip of the tab currently open';

  @override
  String get settings_allTabsOption => 'All Tabs';

  @override
  String get settings_allTabsDescription => 'Every chip on the bar';

  @override
  String get settings_neverOption => 'Never';

  @override
  String get settings_neverCloseDescription =>
      'No close buttons; close tabs from the long press menu or by swiping the bar';

  @override
  String get settings_titleWidthTitle => 'Title Width in Quick Tab Switcher';

  @override
  String get settings_titleWidthKeywords => 'width, title, chip, length';

  @override
  String get settings_titleWidthSubtitle =>
      'Maximum width of tab titles on switcher chips';

  @override
  String get settings_historyFallbackTitle =>
      'History Fallback in Quick Tab Switcher';

  @override
  String get settings_historyFallbackKeywords => 'suggestions';

  @override
  String get settings_historyFallbackSubtitle =>
      'Use browsing history suggestions when no tab chips are available';

  @override
  String get settings_showTitlesTitle => 'Show Titles in Quick Tab Switcher';

  @override
  String get settings_showTitlesKeywords => 'page titles';

  @override
  String get settings_showTitlesSubtitle =>
      'Display tab titles alongside icons in the quick tab switcher bar';

  @override
  String get settings_hierarchyDepthTitle =>
      'Hierarchy Depth in Quick Tab Switcher';

  @override
  String get settings_hierarchyDepthKeywords =>
      'hierarchy, nesting, depth, tree, chevrons';

  @override
  String get settings_hierarchyDepthSubtitle =>
      'How many nesting chevrons to show on switcher chips before collapsing into a count badge (0 hides the indicator)';

  @override
  String settings_hierarchyGlyphsLabel(int glyphs) {
    String _temp0 = intl.Intl.pluralLogic(
      glyphs,
      locale: localeName,
      other: '$glyphs levels',
      one: '1 level',
      zero: 'Off',
    );
    return '$_temp0';
  }

  @override
  String get settings_autoHideTabBarTitle => 'Auto Hide Tab Bar';

  @override
  String get settings_autoHideTabBarKeywords => 'scroll';

  @override
  String get settings_autoHideTabBarSubtitle => 'Hide tab bar when scrolling';

  @override
  String get settings_autoHideSidePanelTitle => 'Auto Hide Side Panel';

  @override
  String get settings_autoHideSidePanelKeywords =>
      'mouse, cursor, hover, rail, sidebar';

  @override
  String get settings_autoHideSidePanelSubtitle =>
      'Keep the left or right tab bar out of the way and slide it in when the mouse reaches that edge. This works only while a mouse or trackpad is in use; touching the screen puts the panel back beside the page.';

  @override
  String get settings_bottomSheetTabViewTitle => 'Bottom Sheet Tab View';

  @override
  String get settings_bottomSheetTabViewKeywords => 'sheet';

  @override
  String get settings_bottomSheetTabViewSubtitle =>
      'Display tabs in a bottom sheet instead of fullscreen';

  @override
  String get settings_longPressUrlCopyTitle => 'Long Press URL to Copy';

  @override
  String get settings_longPressUrlCopyKeywords => 'copy url';

  @override
  String get settings_longPressUrlCopySubtitle =>
      'Copy the page URL to clipboard when long pressing the address bar';

  @override
  String get settings_showFaviconsTitle => 'Show Favicons in List View';

  @override
  String get settings_showFaviconsKeywords => 'icons';

  @override
  String get settings_showFaviconsSubtitle =>
      'Display website icons instead of page thumbnails in tab list view';

  @override
  String get settings_previewPageContent => 'Page Content';

  @override
  String get settings_previewPageTitle => 'WebLibre Preview';

  @override
  String get settings_previewTabNews => 'News';

  @override
  String get settings_previewTabPrivate => 'Private';

  @override
  String get settings_previewTabBank => 'Bank';

  @override
  String get settings_previewTabSearch => 'Search';

  @override
  String get settings_livePreviewTitle => 'Live Preview';

  @override
  String get settings_livePreviewSubtitle =>
      'Reflects your current toolbar and layout settings';

  @override
  String get settings_deleteAllExceptionsTitle => 'Delete All Exceptions?';

  @override
  String get settings_deleteAllExceptionsContent =>
      'This will re-enable tracking protection for all exception sites.';

  @override
  String get settings_entryCopied => 'Entry copied';

  @override
  String get settings_messageLabel => 'Message:';

  @override
  String get settings_errorLabel => 'Error:';

  @override
  String get settings_stackTraceLabel => 'Stack Trace:';

  @override
  String get settings_importSettingsTitle => 'Import settings';

  @override
  String get settings_importSettingsDescription =>
      'The sections you pick replace what this profile has now. Anything you leave unchecked stays as it is.';

  @override
  String settings_unreadableSections(int count, String sections) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count sections in this file ($sections) can\'t be read by this version of WebLibre and will be skipped.',
      one:
          '1 section in this file ($sections) can\'t be read by this version of WebLibre and will be skipped.',
    );
    return '$_temp0';
  }

  @override
  String get settings_exportedLabel => 'Exported';

  @override
  String get settings_appVersionLabel => 'App version';

  @override
  String get settings_credentialsNotCarried =>
      'Exports do not include saved credentials or the wallpaper image. This device keeps its own.';

  @override
  String get settings_geckoPrefsRestartNote =>
      'Some engine preferences only take effect after restarting the browser.';

  @override
  String get settings_userAgentChangedTitle => 'User Agent Changed';

  @override
  String get settings_userAgentChangedContent =>
      'The browser needs to restart for the new user agent to take effect.';

  @override
  String get settings_tabBarSectionTitle => 'Tab Bar';

  @override
  String get settings_contextualToolbarSectionTitle => 'Contextual Toolbar';

  @override
  String get settings_quickTabSwitcherSectionTitle => 'Quick Tab Switcher';

  @override
  String get settings_tabViewSectionTitle => 'Tab View';

  @override
  String get settings_menuSectionTitle => 'Menu';

  @override
  String get settings_menuSectionKeywords => 'three dot, overflow';

  @override
  String get settings_indexTabBarPositionSubtitle =>
      'Choose whether the tab bar sits at the top, at the bottom or at the side';

  @override
  String get settings_indexTabBarStyleSubtitle =>
      'Choose between title and compact layouts';

  @override
  String get settings_indexAutoHideTabBarSubtitle =>
      'Hide the tab bar when scrolling';

  @override
  String get settings_indexAutoHideSidePanelSubtitle =>
      'Reveal the side panel when the mouse reaches its edge';

  @override
  String get settings_indexLongPressUrlCopySubtitle =>
      'Copy the current URL from the tab bar';

  @override
  String get settings_indexShowContextualToolbarSubtitle =>
      'Show an additional toolbar for navigation and actions';

  @override
  String get settings_indexCustomizeToolbarButtonsSubtitle =>
      'Choose which actions appear in the contextual toolbar';

  @override
  String get settings_indexTabStackingSubtitle =>
      'Choose how the quick tab switcher bar arranges tabs';

  @override
  String get settings_indexCustomizeSwitcherButtonsSubtitle =>
      'Choose which action buttons appear at the end of the bar';

  @override
  String get settings_indexHistoryFallbackSubtitle =>
      'Use history suggestions when there are no matching tabs';

  @override
  String get settings_indexShowTitlesSubtitle =>
      'Display page titles in the switcher list';

  @override
  String get settings_indexHierarchyDepthSubtitle =>
      'How many nesting chevrons to show on switcher chips';

  @override
  String get settings_indexBottomSheetTabViewSubtitle =>
      'Open the tab switcher as a bottom sheet';

  @override
  String get settings_indexShowFaviconsSubtitle =>
      'Display site icons in the tab list';

  @override
  String get smallWeb_sheetTitle => 'Small Web';

  @override
  String get smallWeb_refineCategoryTitle => 'Refine Category';

  @override
  String get smallWeb_allCategoriesChip => 'All';

  @override
  String smallWeb_searchingModeTitle(String mode) {
    return 'Searching $mode';
  }

  @override
  String get smallWeb_discoverButtonLabel => 'Discover';

  @override
  String get smallWeb_browseConsolesButtonLabel => 'Browse Consoles';

  @override
  String get smallWeb_unavailableTitle => 'Small Web unavailable';

  @override
  String get smallWeb_noConsoleSelectedMessage => 'No console selected';

  @override
  String smallWeb_consoleStats(int linkedConsoles, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      linkedConsoles,
      locale: localeName,
      other: '$linkedConsoles linked consoles',
      one: '1 linked console',
    );
    String _temp1 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '$pages pages',
      one: '1 page',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get smallWeb_modeWebLabel => 'Web';

  @override
  String get smallWeb_modeAppreciatedLabel => 'Appreciated';

  @override
  String get smallWeb_modeVideosLabel => 'Videos';

  @override
  String get smallWeb_modeCodeLabel => 'Code';

  @override
  String get smallWeb_modeComicsLabel => 'Comics';

  @override
  String get smallWeb_modeDescriptionAppreciated =>
      'Browse highly curated, user-appreciated links from the small web community.';

  @override
  String get smallWeb_modeDescriptionVideos =>
      'Discover video content from independent creators across the small web.';

  @override
  String get smallWeb_modeDescriptionCode =>
      'Find code snippets, repositories, and technical articles from personal sites.';

  @override
  String get smallWeb_modeDescriptionComics =>
      'Explore indie comics and web graphics by independent illustrators.';

  @override
  String get smallWeb_sourceKagiLabel => 'Kagi';

  @override
  String get smallWeb_sourceKagiDescription => 'Small Web by Kagi Search';

  @override
  String get smallWeb_sourceWanderLabel => 'Wander';

  @override
  String get smallWeb_sourceWanderDescription => 'Console-based web ring';

  @override
  String get smallWeb_noNewItemsFoundMessage =>
      'No new items found. Try a different mode or category.';

  @override
  String get smallWeb_discoveryFailedMessage =>
      'Discovery failed. Please try again.';

  @override
  String smallWeb_sessionErrorWithDetails(String error) {
    return 'Small web error: $error';
  }

  @override
  String get smallWeb_kagiTitle => 'Kagi Small Web';

  @override
  String get smallWeb_kagiAttributionLine =>
      'By Kagi Search - open source under the MIT License.';

  @override
  String get smallWeb_kagiBlogPostAction => 'Blog Post';

  @override
  String get smallWeb_kagiGithubAction => 'GitHub';

  @override
  String get smallWeb_kagiDescriptionWeb =>
      'Kagi Small Web surfaces recent posts from personal sites and blogs by individual authors across the small web.';

  @override
  String get smallWeb_kagiDescriptionAppreciated =>
      'This Kagi Small Web mode highlights appreciated posts from the small web as curated by the open-source project.';

  @override
  String get smallWeb_kagiDescriptionVideos =>
      'This Kagi Small Web mode focuses on video posts from smaller independent creators and curated channel seeds.';

  @override
  String get smallWeb_kagiDescriptionCode =>
      'This Kagi Small Web mode focuses on code-oriented posts from personal sites and other small web sources.';

  @override
  String get smallWeb_kagiDescriptionComics =>
      'This Kagi Small Web mode focuses on comics and illustrated posts surfaced through the Small Web project.';

  @override
  String get smallWeb_wanderTitle => 'Wander';

  @override
  String get smallWeb_wanderDescription =>
      'Wander is a network of personal websites connected through shared consoles that help people browse pages across the wider Wander community.';

  @override
  String get smallWeb_wanderAttributionLine =>
      'By Susam Pal - open source under the MIT License.';

  @override
  String get smallWeb_wanderProjectAction => 'Project';

  @override
  String get smallWeb_wanderSetupConsoleAction => 'Set up your Console';

  @override
  String get smallWeb_menuTooltip => 'Menu';

  @override
  String get smallWeb_removeBookmarkTooltip => 'Remove bookmark';

  @override
  String get smallWeb_addBookmarkTooltip => 'Add bookmark';

  @override
  String get smallWeb_bookmarkRemovedMessage => 'Bookmark removed';

  @override
  String get smallWeb_bookmarkAddedMessage => 'Bookmark added';

  @override
  String get smallWeb_exitTooltip => 'Exit Small Web';

  @override
  String get smallWeb_selectConsoleTitle => 'Select Console';

  @override
  String get smallWeb_randomButtonLabel => 'Random';

  @override
  String get smallWeb_filterConsolesHint => 'Filter consoles...';

  @override
  String get smallWeb_linkedConsolesToggleLabel => 'Linked';

  @override
  String get smallWeb_allConsolesToggleLabel => 'All';

  @override
  String get smallWeb_noConsoleSelectedYetMessage =>
      'No console selected yet. Press Discover.';

  @override
  String get smallWeb_addConsoleByUrlTooltip => 'Add console by URL';

  @override
  String get smallWeb_couldNotLoadSessionTitle =>
      'Could not load Small Web session';

  @override
  String get smallWeb_noLinkedConsolesFound => 'No linked consoles found.';

  @override
  String smallWeb_noConsolesMatchingQuery(String query) {
    return 'No consoles match \"$query\".';
  }

  @override
  String get smallWeb_failedToLoadConsoles => 'Failed to load consoles.';

  @override
  String smallWeb_pageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String get smallWeb_noConsolesDiscoveredYet => 'No consoles discovered yet.';

  @override
  String smallWeb_addedConsole(String host) {
    return 'Added console $host';
  }

  @override
  String get smallWeb_addConsoleDialogTitle => 'Add Console';

  @override
  String get smallWeb_addConsoleDialogBody =>
      'Enter the URL of a Wander console. The URL can point to the site root or the /wander/ path.';

  @override
  String get smallWeb_urlFieldLabel => 'URL';

  @override
  String get smallWeb_wanderConsoleFetchFailed =>
      'Could not fetch wander.js from this console.';

  @override
  String get smallWeb_wanderConsoleEmpty =>
      'The wander.js file contains no consoles or pages';

  @override
  String get smallWeb_wanderConsoleAlreadyAdded =>
      'This console has already been added';

  @override
  String get smallWeb_recentDiscoveriesTitle => 'Recent Discoveries';

  @override
  String smallWeb_clearModeHistory(String mode) {
    return 'Clear $mode';
  }

  @override
  String get smallWeb_clearAllDiscoveriesConfirmTitle =>
      'Clear all discoveries?';

  @override
  String get smallWeb_clearAllDiscoveriesConfirmContent =>
      'This will permanently remove all recent discovery history across every mode and source.';

  @override
  String get smallWeb_actionClearAll => 'Clear All';

  @override
  String get smallWeb_clearAllDiscoveriesMenuItem => 'Clear all discoveries';

  @override
  String get smallWeb_noDiscoveriesYetMessage =>
      'No discoveries yet.\nTap Discover to start exploring!';

  @override
  String smallWeb_showMoreCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count more',
    );
    return '$_temp0';
  }

  @override
  String smallWeb_failedToLoadHistory(String error) {
    return 'Failed to load history: $error';
  }

  @override
  String get sync_screenTitle => 'Firefox Sync';

  @override
  String get sync_searchHint => 'Search sync settings';

  @override
  String get sync_statusSyncing => 'Synchronization in progress';

  @override
  String get sync_statusNeverSynced => 'Never synced';

  @override
  String sync_statusLastSynced(String date) {
    return 'Last synced: $date';
  }

  @override
  String get sync_sectionAccount => 'Account';

  @override
  String get sync_sectionAccountKeywords => 'pairing, device name';

  @override
  String get sync_entrySignedInAccountTitle => 'Signed in account';

  @override
  String get sync_entrySignInTitle => 'Sign in';

  @override
  String get sync_entryAccountSubtitle =>
      'Account status, QR pairing, and device name';

  @override
  String get sync_signedIn => 'Signed in';

  @override
  String get sync_notSignedIn => 'Not signed in';

  @override
  String get sync_authExpired =>
      'Authentication expired. Sign in again to continue syncing.';

  @override
  String get sync_syncingTabsBookmarksHistory =>
      'Syncing tabs, bookmarks, and history';

  @override
  String get sync_signInPrompt =>
      'Sign in to synchronize tabs, bookmarks, and history';

  @override
  String get sync_actionSignOut => 'Sign Out';

  @override
  String get sync_scanQrTitle => 'Scan QR Code to pair';

  @override
  String get sync_scanQrSubtitle =>
      'Scan a QR code from firefox.com/pair on desktop';

  @override
  String get sync_invalidQrCode => 'Invalid QR code: not a valid URL';

  @override
  String get sync_deviceNameTitle => 'Device Name';

  @override
  String get sync_unknown => 'Unknown';

  @override
  String get sync_sectionSynchronization => 'Synchronization';

  @override
  String get sync_syncNowTitle => 'Sync Now';

  @override
  String get sync_syncNowKeywords => 'history, bookmarks, tabs';

  @override
  String get sync_syncHistoryTitle => 'Sync History';

  @override
  String get sync_syncBookmarksTitle => 'Sync Bookmarks';

  @override
  String get sync_syncOpenTabsTitle => 'Sync Open Tabs';

  @override
  String get sync_sectionServerOverrides => 'Server Overrides';

  @override
  String get sync_entryServerOverridesTitle => 'Server overrides';

  @override
  String get sync_entryServerOverridesKeywords => 'fxa, token server';

  @override
  String get sync_entryServerOverridesSubtitle =>
      'Custom Firefox Account and token server endpoints';

  @override
  String get sync_fxaServerOverrideTitle => 'FxA Server Override';

  @override
  String get sync_defaultMozillaServer => 'Default Mozilla server';

  @override
  String get sync_tokenServerOverrideTitle => 'Sync Token Server Override';

  @override
  String get sync_automaticFromFxaServer => 'Automatic from FxA server';

  @override
  String get sync_restartAppNotice =>
      'Restart the app after changing server overrides.';

  @override
  String get sync_signOutDialogTitle => 'Sign out?';

  @override
  String get sync_signOutDialogContent =>
      'Are you sure you want to sign out of Firefox Sync?';

  @override
  String get sync_deviceNameHint => 'Enter device name';

  @override
  String get sync_deviceNameEmpty => 'Device name cannot be empty';

  @override
  String get sync_deviceNameUpdateFailed => 'Failed to update device name';

  @override
  String get sync_mustBeValidHttpsUrl => 'Must be a valid HTTPS URL';

  @override
  String get tor_sectionService => 'Service';

  @override
  String get tor_sectionServiceKeywords => 'power, start, stop';

  @override
  String get tor_sectionCircumvention => 'Circumvention';

  @override
  String get tor_sectionCircumventionKeywords =>
      'bridges, transport, obfs4, snowflake';

  @override
  String get tor_sectionCountryRestrictions => 'Country Restrictions';

  @override
  String get tor_sectionCountryRestrictionsKeywords => 'entry, exit, country';

  @override
  String get tor_sectionAbout => 'About';

  @override
  String get tor_sectionAboutKeywords => 'trademark, legal';

  @override
  String tor_proxyLabel(String brand) {
    return '$brand Proxy';
  }

  @override
  String tor_serviceLabel(String brand) {
    return '$brand Service';
  }

  @override
  String get tor_serviceLabelKeywords => 'enable, connect';

  @override
  String tor_serviceSubtitle(String brand) {
    return 'Start or stop the $brand service';
  }

  @override
  String get tor_startAutomaticallyTitle => 'Start Automatically';

  @override
  String get tor_startAutomaticallyKeywords =>
      'autostart, launch, startup, boot';

  @override
  String tor_startAutomaticallySectionSubtitle(String brand) {
    return 'Connect the $brand service when WebLibre starts';
  }

  @override
  String tor_startAutomaticallySubtitle(String brand) {
    return 'Connect the $brand service when WebLibre starts, so tabs using it are ready without a prompt';
  }

  @override
  String get tor_requestNewIdentityTitle => 'Request New Identity';

  @override
  String get tor_requestNewIdentityKeywords => 'circuit';

  @override
  String get tor_requestNewIdentitySubtitle =>
      'Use a fresh circuit for new connections';

  @override
  String tor_requestingNewIdentityMessage(String brand) {
    return 'Requesting new $brand identity...';
  }

  @override
  String get tor_autoConfigureTransportTitle => 'Auto Configure Transport';

  @override
  String get tor_autoConfigureTransportKeywords => 'auto';

  @override
  String get tor_autoConfigureSectionSubtitle =>
      'Pick the right pluggable transport for your network automatically';

  @override
  String tor_autoConfigureSubtitle(String brand) {
    return 'From some locations, it is necessary to use a pluggable transport to connect to $brand';
  }

  @override
  String get tor_requireBridgeTitle =>
      'I\'m sure I cannot connect without a bridge';

  @override
  String get tor_transportTitle => 'Transport';

  @override
  String get tor_transportKeywords => 'direct, obfs4, snowflake';

  @override
  String tor_transportSectionSubtitle(String torBrand) {
    return 'Choose how to reach the $torBrand network when not auto-configured';
  }

  @override
  String get tor_transportAutoConfiguredTitle => 'Auto-configured';

  @override
  String get tor_transportAutoConfiguredSubtitle =>
      'Disable auto-configure above to pick a transport manually.';

  @override
  String get tor_transportDirectTitle => 'Direct Connection';

  @override
  String tor_transportDirectSubtitle(String brand) {
    return 'The best way to connect to $brand if $brand is not blocked';
  }

  @override
  String get tor_transportObfs4Title => 'obfs4';

  @override
  String get tor_transportObfs4Subtitle =>
      'Suitable for lightly censored networks and high-bandwidth use';

  @override
  String get tor_transportSnowflakeTitle => 'Snowflake';

  @override
  String get tor_transportSnowflakeSubtitle => 'Suitable for heavy censorship';

  @override
  String get tor_fetchFreshBridgesTitle =>
      'Fetch fresh bridges before connecting';

  @override
  String get tor_entryCountryTitle => 'Entry Country';

  @override
  String get tor_entryCountrySubtitle =>
      'Choose the country of the entry guard';

  @override
  String get tor_entryCountryKeywords => 'guard';

  @override
  String get tor_exitCountryTitle => 'Exit Country';

  @override
  String get tor_exitCountrySubtitle => 'Choose the country of the exit node';

  @override
  String get tor_exitCountryKeywords => 'exit';

  @override
  String get tor_automaticOption => 'Automatic';

  @override
  String get tor_trademarkTitle => 'Trademark';

  @override
  String get tor_trademarkKeywords => 'legal';

  @override
  String tor_trademarkDisclaimer(String brand) {
    return '$brand is a trademark of The Tor Project; all rights reserved. WebLibre is not endorsed or sponsored by, or affiliated with, the Tor Project.';
  }

  @override
  String get tor_screenSubtitle =>
      'Onion routing, pluggable transports, bridges and country restrictions.';

  @override
  String tor_dialogContent(String brand) {
    return 'This container requires a $brand proxy for secure connections, which is not currently running.';
  }

  @override
  String get tor_actionEnable => 'Enable';

  @override
  String tor_connectingNotification(String proxyLabel) {
    return '$proxyLabel is connecting...';
  }

  @override
  String get tor_countrySearchHint => 'Search countries...';

  @override
  String get tor_unnamedCountry => 'Unnamed Country';

  @override
  String get user_profilesTitle => 'Profiles';

  @override
  String get user_activeProfileLabel => 'Active';

  @override
  String get user_loadProfilesFailedTitle => 'Could not load profiles';

  @override
  String get user_askWhichProfileTitle => 'Ask which profile to open';

  @override
  String get user_askWhichProfileSubtitle =>
      'At startup, when more than one profile exists';

  @override
  String get user_createBackupTitle => 'Create Backup';

  @override
  String get user_restartingToTakeBackup => 'Restarting to take the backup';

  @override
  String get user_backupRestartsTitle => 'WebLibre restarts to do this';

  @override
  String user_backupRestartsSubtitle(String restartClosesCurrentProfile) {
    return '$restartClosesCurrentProfile The backup is taken while the profile is closed, so its contents cannot change during the backup.';
  }

  @override
  String get user_setPasswordNextTitle => 'You set the password next';

  @override
  String get user_setPasswordNextSubtitle =>
      'After restarting, WebLibre asks for the backup file password.';

  @override
  String get user_verifyBackupIntegrityTitle => 'Verify backup integrity';

  @override
  String get user_verifyBackupIntegritySubtitle =>
      'Check that the backup can be restored';

  @override
  String get user_tempDataSkippedTitle => 'Temporary data is skipped';

  @override
  String user_tempDataSkippedSubtitle(String shortcutsNeedPinningAgain) {
    return 'Cache files and other data WebLibre can rebuild are not saved. $shortcutsNeedPinningAgain';
  }

  @override
  String get user_accountDataIncludedTitle =>
      'WebLibre account data is included';

  @override
  String user_accountDataIncludedSubtitle(String profileSecretDataDescription) {
    return 'The backup file includes this profile’s $profileSecretDataDescription. Replacing a profile restores them; creating a new profile does not. Use a strong password.';
  }

  @override
  String get user_closingToTakeBackup => 'Closing WebLibre to take the backup…';

  @override
  String get user_actionBackup => 'Backup';

  @override
  String get user_backupsTitle => 'Backups';

  @override
  String get user_changeBackupFolderTooltip => 'Change backup folder';

  @override
  String get user_chooseBackupFolderPrompt =>
      'Choose where to store your backups.';

  @override
  String get user_chooseBackupFolderHint =>
      'Pick a location outside the app, so the backups survive uninstalling it.';

  @override
  String get user_chooseFolderButtonLabel => 'Choose folder';

  @override
  String get user_noBackupsFound => 'No backups found';

  @override
  String get user_loadBackupsFailedTitle => 'Could not load backups';

  @override
  String get user_authReasonRequireAuth => 'Require authentication for profile';

  @override
  String get user_authReasonConfirmUnlock =>
      'Confirm you can unlock this profile';

  @override
  String get user_authReasonUnlockProfile => 'Unlock profile';

  @override
  String user_authFailedExisting(String nothingChanged) {
    return 'Could not confirm your identity. $nothingChanged';
  }

  @override
  String get user_authFailedNew =>
      'Could not confirm your identity. A locked profile is only created once this device can unlock it.';

  @override
  String get user_editProfileTitle => 'Edit Profile';

  @override
  String get user_createProfileTitle => 'Create Profile';

  @override
  String get user_nameFieldLabel => 'Name';

  @override
  String get user_authenticationSectionTitle => 'Authentication';

  @override
  String get user_requireAuthenticationTitle => 'Require authentication';

  @override
  String get user_requireAuthenticationSubtitle =>
      'Ask before this profile can be opened';

  @override
  String get user_autoLockTitle => 'Auto-lock';

  @override
  String get user_autoLockSubtitle => 'When to lock the profile again';

  @override
  String get user_lockInBackgroundTitle => 'Lock in background';

  @override
  String get user_lockInBackgroundSubtitle =>
      'As soon as WebLibre leaves the screen';

  @override
  String get user_lockAfterTimeoutTitle => 'Lock after a timeout';

  @override
  String get user_lockAfterTimeoutSubtitle => 'After a period of inactivity';

  @override
  String get user_lockOnStartupTitle => 'Lock on startup only';

  @override
  String get user_lockOnStartupSubtitle =>
      'Unlock once at startup, then stay unlocked until WebLibre is fully closed';

  @override
  String get user_timeoutFieldTitle => 'Timeout';

  @override
  String get user_timeoutFieldSubtitle => 'How long to wait before locking';

  @override
  String get user_timeoutOneMinute => '1 minute';

  @override
  String get user_timeoutFiveMinutes => '5 minutes';

  @override
  String get user_timeoutFifteenMinutes => '15 minutes';

  @override
  String get user_timeoutOneHour => '1 hour';

  @override
  String get user_profileActionsSectionTitle => 'Profile actions';

  @override
  String get user_switchDeleteUnavailableForActive =>
      'Switching and deleting are unavailable for the profile you are using.';

  @override
  String get user_switchToThisProfileLabel => 'Switch to this profile';

  @override
  String user_deleteFailedWithError(String error) {
    return 'Could not delete: $error';
  }

  @override
  String get user_deleteProfileFailedGeneric => 'Could not delete this profile';

  @override
  String get user_restoreBackupTitle => 'Restore Backup';

  @override
  String get user_backupRestoredMessage => 'Backup restored';

  @override
  String get user_passwordFieldLabel => 'Password';

  @override
  String get user_wrongBackupPassword =>
      'This password did not open the backup file';

  @override
  String get user_passwordHelperText =>
      'The password this backup file was created with.';

  @override
  String get user_createNewProfileTitle => 'Create a new profile';

  @override
  String get user_createNewProfileSubtitle =>
      'Keep your existing profiles and add this backup';

  @override
  String get user_replaceExistingProfileTitle => 'Replace an existing profile';

  @override
  String get user_replaceExistingProfileSubtitle =>
      'Restart and overwrite one profile with this backup';

  @override
  String get user_newProfileNoSignInTitle =>
      'A new profile starts without WebLibre sign-in';

  @override
  String get user_newProfileNoSignInSubtitle =>
      'Tabs, history and bookmarks are restored. Sign-in and sync data stay with the original profile.';

  @override
  String user_restoringIntoTitle(String profileLabel) {
    return 'Restoring into \"$profileLabel\"';
  }

  @override
  String get user_backupKeepsLockConfigured =>
      'The backup keeps the lock you configured.';

  @override
  String get user_profileKeepsNameAndLock =>
      'The profile keeps its name and lock.';

  @override
  String get user_profileToReplaceLabel => 'Profile to replace';

  @override
  String get user_selectProfileToReplaceValidator =>
      'Select a profile to replace';

  @override
  String user_multipleProfilesShareNameTitle(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count profiles are called \"$name\"',
    );
    return '$_temp0';
  }

  @override
  String user_multipleProfilesShareNameSubtitle(String cannotBeUndone) {
    return 'The backup names a profile but cannot say which one, so pick the one to replace. $cannotBeUndone';
  }

  @override
  String user_backupTakenFromTitle(String name) {
    return 'This backup was taken from \"$name\"';
  }

  @override
  String user_backupTakenFromSubtitle(
    String targetLabel,
    String shortcutsNeedPinningAgain,
  ) {
    return 'It replaces \"$targetLabel\", which keeps its name and lock. $shortcutsNeedPinningAgain';
  }

  @override
  String user_profileWillBeCalledTitle(String name) {
    return 'This profile will be called \"$name\"';
  }

  @override
  String user_profileWillBeCalledSubtitle(String shortcutsNeedPinningAgain) {
    return 'The name comes from the backup. $shortcutsNeedPinningAgain';
  }

  @override
  String get user_accountDataRestoredTitle =>
      'WebLibre account data is restored';

  @override
  String user_accountDataRestoredSubtitle(
    String profileSecretDataDescription,
    String signedInFromBackup,
    String olderBackupKeepsCredentials,
  ) {
    return 'Replacing restores the backup file\'s $profileSecretDataDescription. $signedInFromBackup $olderBackupKeepsCredentials';
  }

  @override
  String get user_replacesSetupProfileTitle =>
      'This replaces the profile you are setting up';

  @override
  String get user_replacesEverythingTitle =>
      'This replaces everything in that profile';

  @override
  String user_replacesSetupProfileSubtitle(String restartsThenAsksPassword) {
    return '$restartsThenAsksPassword Anything already in this profile will be replaced when the restore starts.';
  }

  @override
  String user_replacesEverythingSubtitle(
    String restartsThenAsksPassword,
    String profileDataDescription,
    String targetDescription,
  ) {
    return '$restartsThenAsksPassword When the restore starts, it replaces the current $profileDataDescription in $targetDescription.';
  }

  @override
  String get user_thatProfileFallbackLabel => 'that profile';

  @override
  String get user_restoringBackupProgress => 'Restoring backup…';

  @override
  String get user_closingToRestoreProgress => 'Closing WebLibre to restore…';

  @override
  String get user_actionRestore => 'Restore';

  @override
  String user_switchToProfileTitle(String profileName) {
    return 'Switch to \"$profileName\"?';
  }

  @override
  String user_switchClosesReopensAs(String profileName) {
    return 'WebLibre closes and reopens as \"$profileName\".';
  }

  @override
  String get user_switchConsequencesList =>
      '• Private tabs are cleared.\n• Web notifications for the profile you leave are paused.';

  @override
  String get user_actionNotNow => 'Not now';

  @override
  String get user_actionSwitchAndRestart => 'Switch and restart';

  @override
  String get user_passwordConfirmationTitle => 'Password Confirmation';

  @override
  String get user_actionConfirm => 'Confirm';

  @override
  String get user_selectProfileTitle => 'Select profile';

  @override
  String get user_manageProfilesLabel => 'Manage profiles';

  @override
  String get user_profileAvatarHint =>
      'Switch to this profile. Long press to edit it.';

  @override
  String user_profileAvatarTooltip(String label) {
    return '$label\nLong press to edit';
  }

  @override
  String get user_addProfileLabel => 'Add a profile';

  @override
  String get user_addProfileButtonLabel => 'Add profile';

  @override
  String get user_quitBrowserTitle => 'Quit Browser';

  @override
  String get user_quitBrowserContent =>
      'This will shut down the browser cleanly and clear private-tab data.';

  @override
  String get user_actionQuit => 'Quit';

  @override
  String user_deleteProfileTitle(String profileName) {
    return 'Delete \"$profileName\"?';
  }

  @override
  String user_deleteProfileContent(
    String profileDataDescription,
    String cannotBeUndone,
  ) {
    return 'Its $profileDataDescription are removed. $cannotBeUndone';
  }

  @override
  String user_deleteProfileRestartNote(
    String restartsToWork,
    String restartClosesCurrentProfile,
  ) {
    return '$restartsToWork $restartClosesCurrentProfile The profile being deleted is closed first.';
  }

  @override
  String get user_actionDeleteAndRestart => 'Delete and restart';

  @override
  String user_replaceProfileTitle(String profileName) {
    return 'Replace \"$profileName\" with this backup?';
  }

  @override
  String user_replaceProfilePlaceholderContent(String cannotBeUndone) {
    return 'The backup replaces the profile you are setting up. Anything already in it is lost. $cannotBeUndone';
  }

  @override
  String user_replaceProfileContent(
    String profileName,
    String profileDataDescription,
    String cannotBeUndone,
  ) {
    return 'The backup replaces everything in \"$profileName\" — its $profileDataDescription. Anything added after the backup is lost. $cannotBeUndone';
  }

  @override
  String user_replaceProfileAccountNote(
    String signedInFromBackup,
    String profileSecretDataDescription,
    String olderBackupKeepsCredentials,
  ) {
    return '$signedInFromBackup The restore also includes $profileSecretDataDescription from the backup. $olderBackupKeepsCredentials';
  }

  @override
  String user_replaceProfileRenamedNote(
    String adoptedName,
    String shortcutsNeedPinningAgain,
  ) {
    return 'The profile is renamed to \"$adoptedName\" and keeps its lock. $shortcutsNeedPinningAgain';
  }

  @override
  String user_replaceProfileFromSourceNote(
    String sourceProfileName,
    String profileName,
    String shortcutsNeedPinningAgain,
  ) {
    return 'The backup came from \"$sourceProfileName\". \"$profileName\" keeps its name and lock. $shortcutsNeedPinningAgain';
  }

  @override
  String user_replaceProfileRestartNote(
    String restartsThenAsksPassword,
    String restartClosesCurrentProfile,
  ) {
    return '$restartsThenAsksPassword Nothing is replaced before that. $restartClosesCurrentProfile';
  }

  @override
  String get user_actionReplaceAndRestart => 'Replace and restart';

  @override
  String user_backupProfileTitle(String profileName) {
    return 'Back up \"$profileName\"?';
  }

  @override
  String get user_backupProfileContent =>
      'The backup is taken with the profile closed, so nothing in it changes.';

  @override
  String user_backupProfileRestartNote(
    String restartsToWork,
    String restartClosesCurrentProfile,
  ) {
    return '$restartsToWork $restartClosesCurrentProfile';
  }

  @override
  String get user_actionBackupAndRestart => 'Back up and restart';

  @override
  String get user_profileAlreadyActive => 'This profile is already active';

  @override
  String user_switchProfileFailedWithError(String error) {
    return 'Could not switch profile: $error';
  }

  @override
  String get user_profileLockedTitle => 'Profile is locked';

  @override
  String get user_unlockingLabel => 'Unlocking...';

  @override
  String get user_unlockButtonLabel => 'Unlock';

  @override
  String user_restartFailedWithError(String error) {
    return 'Could not restart: $error';
  }

  @override
  String get user_restartingLabel => 'Restarting…';

  @override
  String get user_chooseAnotherProfileLabel => 'Choose another profile';

  @override
  String get user_searchSuggestionProviderNone => 'Disabled';

  @override
  String get user_searchSuggestionProviderBrave => 'Brave';

  @override
  String get user_searchSuggestionProviderDdg => 'DuckDuckGo';

  @override
  String get user_searchSuggestionProviderKagi => 'Kagi';

  @override
  String get user_searchSuggestionProviderQwant => 'Qwant';

  @override
  String get user_deleteBrowsingDataTypeTabsTitle => 'Open tabs';

  @override
  String get user_deleteBrowsingDataTypeHistoryTitle => 'Browsing history';

  @override
  String get user_deleteBrowsingDataTypeRecentSearchesTitle =>
      'Recent searches';

  @override
  String get user_deleteBrowsingDataTypeRecentSearchesDescription =>
      'Queries shown on the search page';

  @override
  String get user_deleteBrowsingDataTypeCookiesTitle => 'Cookies and site data';

  @override
  String get user_deleteBrowsingDataTypeCookiesDescription =>
      'You’ll be logged out of most sites';

  @override
  String get user_deleteBrowsingDataTypeCacheTitle => 'Cached images and files';

  @override
  String get user_deleteBrowsingDataTypeCacheDescription =>
      'Frees up storage space';

  @override
  String get user_deleteBrowsingDataTypePermissionsTitle => 'Site permissions';

  @override
  String get user_deleteBrowsingDataTypeDownloadsTitle => 'Downloads';

  @override
  String get wallpaper_title => 'Wallpaper';

  @override
  String get wallpaper_settingsDescription =>
      'Shown behind the home page, in every container that does not set its own.';

  @override
  String get wallpaper_chooseImage => 'Choose image';

  @override
  String get wallpaper_replace => 'Replace';

  @override
  String get wallpaper_blurLabel => 'Blur';

  @override
  String get wallpaper_dimLabel => 'Dim';

  @override
  String get wallpaper_dimDescription =>
      'Dim blends the image into the app background, so page text stays readable in both light and dark themes.';

  @override
  String get wallpaper_editorDefaultDescription =>
      'The home page keeps its default backdrop.';

  @override
  String get wallpaper_importErrorUnreadable => 'That file could not be read';

  @override
  String get wallpaper_importErrorTooLarge => 'That image is too large';

  @override
  String get wallpaper_importErrorNotAnImage => 'That file is not an image';

  @override
  String get wallpaper_importErrorDecodeFailed =>
      'That image could not be read';

  @override
  String get webFeed_addFeedTitle => 'Add Feed';

  @override
  String get webFeed_fieldUrlLabel => 'URL';

  @override
  String get webFeed_actionIgnore => 'Ignore';

  @override
  String get webFeed_unnamedFeedTitle => 'Untitled Feed';

  @override
  String get webFeed_unnamedArticleTitle => 'Unnamed Article';

  @override
  String get webFeed_fetchFeedFailedTitle => 'Failed to fetch feed';

  @override
  String get webFeed_feedsTitle => 'Feeds';

  @override
  String get webFeed_loadFeedsFailedTitle => 'Failed to load feeds';

  @override
  String get webFeed_feedFabLabel => 'Add Feed';

  @override
  String get webFeed_loadFeedFailedTitle => 'Failed to load feed';

  @override
  String get webFeed_newFeedTitle => 'New Feed';

  @override
  String get webFeed_editFeedTitle => 'Edit Feed';

  @override
  String get webFeed_fetchingFeedMessage => 'Fetching feed…';

  @override
  String get webFeed_fieldTitleLabel => 'Title';

  @override
  String get webFeed_fieldDescriptionLabel => 'Description';

  @override
  String get webFeed_fieldIconUrlLabel => 'Icon URL';

  @override
  String get webFeed_fieldSiteLinkLabel => 'Site Link';

  @override
  String get webFeed_fieldFeedUrlLabel => 'Feed URL';

  @override
  String get webFeed_deleteFeedTitle => 'Delete Feed';

  @override
  String get webFeed_deleteFeedConfirm =>
      'Are you sure you want to delete this feed and all its articles?';

  @override
  String get webFeed_articlesTitle => 'Articles';

  @override
  String get webFeed_searchLabel => 'Search';

  @override
  String get webFeed_loadArticlesFailedTitle => 'Failed to load articles';

  @override
  String webFeed_publishedLabel(String date) {
    return 'Published: $date';
  }

  @override
  String get webFeed_notAvailable => 'N/A';

  @override
  String webFeed_updatedLabel(String date) {
    return 'Updated: $date';
  }

  @override
  String get webFeed_authorsLabel => 'Authors:';

  @override
  String get webFeed_tagsLabel => 'Tags:';

  @override
  String get webFeed_readArticleFailedTitle => 'Failed to load article';

  @override
  String webFeed_lastFetchedLabel(String date) {
    return 'Last fetched: $date';
  }

  @override
  String get webFeed_tagsFieldLabel => 'Tags';

  @override
  String get webPush_screenTitle => 'Notifications';

  @override
  String get webPush_screenSubtitle =>
      'Website notifications delivered through UnifiedPush';

  @override
  String get webPush_distributorTileTitle => 'UnifiedPush Distributor';

  @override
  String get webPush_distributorTileKeywords =>
      'notifications, push, unifiedpush, ntfy';

  @override
  String get webPush_checking => 'Checking…';

  @override
  String webPush_couldNotReadStatus(String error) {
    return 'Could not read push status: $error';
  }

  @override
  String get webPush_updatingDistributor => 'Updating…';

  @override
  String get webPush_registrationRecovering =>
      'Recovering from a registration error…';

  @override
  String webPush_lastRegistrationError(String error) {
    return 'Last registration error: $error';
  }

  @override
  String get webPush_disablingWebPush => 'Disabling…';

  @override
  String get webPush_disableWebPush => 'Disable web push';

  @override
  String get webPush_statusNoneAvailable => 'No distributor available';

  @override
  String get webPush_statusNotSelected => 'Not configured';

  @override
  String get webPush_statusPending => 'Connecting…';

  @override
  String get webPush_statusReady => 'Active';

  @override
  String get webPush_statusUnavailable => 'Distributor unavailable';

  @override
  String get webPush_statusDescNoneAvailable =>
      'Install a UnifiedPush distributor app, such as ntfy, to receive website notifications.';

  @override
  String get webPush_statusDescNotSelected =>
      'Choose a distributor below to enable website notifications.';

  @override
  String get webPush_statusDescPending =>
      'Waiting for the distributor to acknowledge registration.';

  @override
  String get webPush_statusDescReady =>
      'Website notifications are delivered through this distributor.';

  @override
  String get webPush_statusDescUnavailable =>
      'The chosen distributor is no longer installed. Website notifications will not be delivered until you choose another one.';

  @override
  String get webPush_noDistributorInstalled =>
      'No UnifiedPush distributor is installed. Install one, such as ntfy, and try again.';

  @override
  String get webPush_chooseDistributorTitle => 'Choose distributor';

  @override
  String get webPush_distributorConfigured =>
      'UnifiedPush distributor configured.';

  @override
  String webPush_couldNotConfigureDistributor(String error) {
    return 'Could not configure distributor: $error';
  }

  @override
  String get webPush_webPushDisabled => 'Web push disabled.';

  @override
  String webPush_couldNotDisableWebPush(String error) {
    return 'Could not disable web push: $error';
  }

  @override
  String get webPush_notificationPermissionTitle => 'Notification Permission';

  @override
  String get webPush_notificationPermissionKeywords =>
      'notifications, permission';

  @override
  String webPush_notificationPermissionCouldNotRead(String error) {
    return 'Could not read permission state: $error';
  }

  @override
  String get webPush_notificationPermissionGranted => 'Granted';

  @override
  String get webPush_notificationPermissionDenied =>
      'Denied. Push messages still arrive, but no notifications can be shown.';

  @override
  String get webPush_grantAction => 'Grant';

  @override
  String webPush_couldNotUpdatePermission(String error) {
    return 'Could not update notification permission: $error';
  }

  @override
  String get webPush_loadingSubscriptions => 'Loading subscriptions…';

  @override
  String get webPush_couldNotReadSubscriptions =>
      'Could not read subscriptions';

  @override
  String get webPush_noSiteSubscriptions => 'No site subscriptions';

  @override
  String get webPush_noSiteSubscriptionsDescription =>
      'Websites you allow to send notifications will appear here.';

  @override
  String get webPush_subscriptionActive => 'Active';

  @override
  String get webPush_subscriptionDelayedDelivery =>
      'Endpoint saved; delivery is paused until the distributor is ready';

  @override
  String get webPush_subscriptionWaitingForEndpoint =>
      'Waiting for the distributor to assign an endpoint';

  @override
  String get webPush_revokeSubscriptionHint =>
      'To stop a site from sending notifications, revoke its notification permission in the site settings.';

  @override
  String get webPush_deliverySectionTitle => 'Delivery';

  @override
  String get webPush_indexDistributorSubtitle =>
      'The app that delivers website push notifications';

  @override
  String get webPush_indexNotificationPermissionSubtitle =>
      'Required to display website notifications';

  @override
  String get webPush_subscriptionsSectionTitle => 'Subscriptions';

  @override
  String get webPush_indexSiteSubscriptionsTitle => 'Site Subscriptions';

  @override
  String get webPush_indexSiteSubscriptionsKeywords => 'sites, subscriptions';

  @override
  String get webPush_indexSiteSubscriptionsSubtitle =>
      'Websites subscribed to push notifications';

  @override
  String get webSearch_fetchPageDataTitle => 'Fetch Page Data';

  @override
  String get webSearch_downloadFailedTapToRetry =>
      'Download failed — tap to retry';

  @override
  String get webSearch_methodTrafilaturaTitle => 'Extracted Preview';

  @override
  String get webSearch_methodSinglefileTitle => 'Full Page Capture';

  @override
  String get webSearch_methodPdfTitle => 'PDF Snapshot';

  @override
  String get webSearch_methodPngTitle => 'Image Snapshot';

  @override
  String get webSearch_methodTrafilaturaSubtitle =>
      'Reader-optimized text and metadata for the in-app preview';

  @override
  String get webSearch_methodSinglefileSubtitle =>
      'Archive the full page with layout and assets for later use';

  @override
  String get webSearch_methodPdfSubtitle =>
      'Render the page to a PDF for offline reading and sharing';

  @override
  String get webSearch_methodPngSubtitle =>
      'Capture a full-page PNG screenshot of the rendered page';

  @override
  String get webSearch_previewUnavailableTitle => 'Preview unavailable';

  @override
  String get webSearch_previewUnavailableMessage =>
      'Fetch the page from the result list before opening a preview.';

  @override
  String get webSearch_openInBrowserTooltip => 'Open in browser';

  @override
  String webSearch_torToggleOn(String brand) {
    return '$brand on';
  }

  @override
  String webSearch_torToggleOff(String brand) {
    return '$brand off';
  }

  @override
  String get webSearch_languageAuto => 'Auto';

  @override
  String get webSearch_languageAutoDeviceDefault => 'Auto (device default)';

  @override
  String get webSearch_countryAny => 'Any';

  @override
  String get webSearch_countryAnyRegion => 'Any region';

  @override
  String webSearch_countryDeviceDefault(String name) {
    return '$name (device)';
  }

  @override
  String get webSearch_safeSearchPillDefault => 'Safe: default';

  @override
  String get webSearch_safeSearchPillOff => 'Safe: off';

  @override
  String get webSearch_safeSearchPillModerate => 'Safe: moderate';

  @override
  String get webSearch_safeSearchPillStrict => 'Safe: strict';

  @override
  String get webSearch_safeSearchMenuDefault => 'Default (moderate)';

  @override
  String get webSearch_safeSearchMenuOff => 'Off';

  @override
  String get webSearch_safeSearchMenuModerate => 'Moderate';

  @override
  String get webSearch_safeSearchMenuStrict => 'Strict';

  @override
  String get webSearch_freshnessAnyTime => 'Any time';

  @override
  String get webSearch_freshnessPastDay => 'Past day';

  @override
  String get webSearch_freshnessPastWeek => 'Past week';

  @override
  String get webSearch_freshnessPastMonth => 'Past month';

  @override
  String get webSearch_freshnessPastYear => 'Past year';

  @override
  String get webSearch_modeGeneralLabel => 'General';

  @override
  String get webSearch_modeIndependentWebLabel => 'Independent Web';

  @override
  String get webSearch_modeSmallWebLabel => 'Small Web';

  @override
  String get webSearch_modeGeneralDescription =>
      'Balanced results across the open web';

  @override
  String get webSearch_modeIndependentWebDescription =>
      'Favor smaller and less corporate sources';

  @override
  String get webSearch_modeSmallWebDescription =>
      'Independent, personal & niche sites';

  @override
  String get webSearch_fetchTooltip => 'Fetch';

  @override
  String get webSearch_additionalSnippetsHeading => 'Additional Snippets';

  @override
  String get webSearch_questionPrefix => 'Q: ';

  @override
  String get webSearch_snippetsTooltip => 'Snippets';

  @override
  String webSearch_showMoreLinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count more links',
      one: 'Show 1 more link',
    );
    return '$_temp0';
  }

  @override
  String get webSearch_factsheetHeading => 'Factsheet';

  @override
  String get webSearch_searchFailedTitle => 'Search failed';

  @override
  String get webSearch_searchingLabel => 'Searching the web...';

  @override
  String webSearch_noResultsFor(String query) {
    return 'No results found for \"$query\".';
  }

  @override
  String webSearch_creditsTokensStatus(int credits, int tokens) {
    String _temp0 = intl.Intl.pluralLogic(
      credits,
      locale: localeName,
      other: '$credits credits',
      one: '1 credit',
    );
    String _temp1 = intl.Intl.pluralLogic(
      tokens,
      locale: localeName,
      other: '$tokens tokens',
      one: '1 token',
    );
    return '$_temp0  |  $_temp1';
  }

  @override
  String get webSearch_needsCreditsMessage =>
      'No search credits or tokens are available for a new web search.';

  @override
  String get webSearch_buySearchPackButton => 'Buy a search pack';

  @override
  String get webSearch_socketConnectionError =>
      'Search connection error. Please try again.';

  @override
  String get webSearch_closeErrorSessionTimeout =>
      'Search session timed out. Please try again.';

  @override
  String get webSearch_closeErrorCreditInvalid =>
      'Your search credit could not be validated. The credit may have been spent — please try again.';

  @override
  String get webSearch_closeErrorPolicyForbidden =>
      'The requested page is not permitted by the search policy.';

  @override
  String get webSearch_closeErrorServerFailed =>
      'The search failed on the server. Please try again.';

  @override
  String webSearch_closeErrorUnknown(int code) {
    return 'Search connection closed unexpectedly (code $code). Please try again.';
  }

  @override
  String get webSearch_unknownErrorDetail => 'unknown error';

  @override
  String webSearch_streamErrorProtocol(String detail) {
    return 'Search protocol error. The session has ended — please try again. ($detail)';
  }

  @override
  String webSearch_streamErrorSearchFailed(String detail) {
    return 'The search failed on the server. Please try again. ($detail)';
  }

  @override
  String webSearch_streamErrorFetchFailed(String detail) {
    return 'Could not fetch this page from the source. ($detail)';
  }

  @override
  String webSearch_streamErrorExtractFailed(String detail) {
    return 'Could not extract a readable preview from this page. ($detail)';
  }

  @override
  String webSearch_streamErrorNotAllowed(String detail) {
    return 'This page is not permitted by the search policy. ($detail)';
  }

  @override
  String webSearch_streamErrorCaptureFailed(String detail) {
    return 'Page capture failed. ($detail)';
  }

  @override
  String webSearch_streamErrorGeneric(String detail) {
    return 'Search error: $detail';
  }

  @override
  String webSearch_torStartFailed(String torBrand) {
    return 'Could not start $torBrand for the search. Disable the $torBrand toggle or try again.';
  }

  @override
  String get webSearch_creditCheckFailed =>
      'Could not check search credits. Please try again.';

  @override
  String get webSearch_tokenIssuanceFailed =>
      'Could not issue search tokens. Please try again.';

  @override
  String get mainApp_initializationErrorTitle => 'Initialization Error';

  @override
  String get mainApp_initializationErrorMessage =>
      'Could not initialize the app';

  @override
  String get mainApp_initStageLoadingFormats => 'Loading formats…';

  @override
  String get mainApp_initStageLoadingPackageInfo => 'Loading app information…';

  @override
  String get mainApp_initStageSyncingBangs => 'Synchronizing bangs…';

  @override
  String get mainApp_downloadCompleted => 'Download completed';

  @override
  String get mainApp_downloadOpenFailed => 'Could not open downloaded file';

  @override
  String mainApp_downloadFailed(String name) {
    return 'Download failed: $name';
  }

  @override
  String mainApp_containerBlockedWithHost(String host) {
    return '$host is not assigned to this container';
  }

  @override
  String get mainApp_containerBlockedNoHost =>
      'This site is not assigned to this container';

  @override
  String get mainApp_sandboxNoCredits =>
      'You have no search credits left. Purchase more to continue.';

  @override
  String get mainApp_sandboxTokenIssuanceFailed =>
      'Could not issue new search tokens. Check your connection and try again.';

  @override
  String mainApp_sandboxFetchPolicyRejected(String detail) {
    return 'Capture blocked by fetch policy: $detail';
  }

  @override
  String get mainApp_sandboxDetailNotAllowed => 'not allowed';

  @override
  String mainApp_sandboxCaptureFailed(String detail) {
    return 'Capture failed: $detail';
  }

  @override
  String get mainApp_sandboxDetailUnknownError => 'unknown error';

  @override
  String get mainApp_sandboxDownloadFailed =>
      'Capture artifact download failed.';

  @override
  String mainApp_sandboxUnknownError(String detail) {
    return 'Sandbox capture error: $detail';
  }

  @override
  String get mainApp_syncFailed => 'Synchronization failed';

  @override
  String get startup_pickerTitle => 'Choose a profile';

  @override
  String startup_pickerEachProfileKeepsOwn(String contents) {
    return 'Each profile keeps its own $contents.';
  }

  @override
  String get startup_pickerOpensByDefaultLocked => 'Opens by default · Locked';

  @override
  String get startup_pickerOpensByDefault => 'Opens by default';

  @override
  String get startup_pickerLocked => 'Locked';

  @override
  String get startup_haltMaintenanceTitle => 'Unfinished profile work';

  @override
  String get startup_haltMaintenanceBody =>
      'A backup, restore or deletion from an earlier run did not finish. WebLibre must finish it before any profile can open.';

  @override
  String get startup_haltUnavailableTitle => 'Startup is not ready';

  @override
  String startup_haltUnavailableBody(String reopenToContinue) {
    return 'WebLibre needs to restart before it can choose a profile. $reopenToContinue';
  }

  @override
  String get startup_haltProfileAccessBusyTitle => 'Profile is in use';

  @override
  String get startup_haltProfileAccessBusyBody =>
      'Another WebLibre task is still using this profile. Try again in a moment.';

  @override
  String get startup_haltNoProfileTitle => 'No usable profile';

  @override
  String get startup_haltNoProfileBody =>
      'WebLibre could not read an existing profile or create a new one. Storage may be full or unavailable.';

  @override
  String get startup_haltArbitrationFailedTitle =>
      'Cannot tell which profile to open';

  @override
  String startup_haltArbitrationFailedBody(String reopenToContinue) {
    return 'WebLibre will not guess which profile to use. $reopenToContinue';
  }

  @override
  String get startup_tryAgain => 'Try again';

  @override
  String get startup_tryingAgain => 'Trying again…';

  @override
  String get startup_closeWebLibre => 'Close WebLibre';

  @override
  String get startup_technicalDetails => 'Technical details';

  @override
  String get startup_copyDetails => 'Copy details';

  @override
  String get startup_maintenanceFinishingInterrupted =>
      'Finishing work interrupted by a previous restart…';

  @override
  String get startup_maintenanceNotRunnableUnsupported =>
      'This task was created by a newer version of WebLibre and cannot run here.';

  @override
  String get startup_maintenanceNotRunnableNoDestination =>
      'This backup has no destination folder recorded.';

  @override
  String get startup_maintenanceNotRunnableNoBackupFile =>
      'This restore has no backup file recorded.';

  @override
  String get startup_maintenanceNotRunnableRestoreHere =>
      'WebLibre cannot restore from this startup screen.';

  @override
  String get startup_maintenanceNotRunnableDeleteHere =>
      'WebLibre cannot delete a profile from this startup screen.';

  @override
  String get startup_maintenanceRecoveredRestore =>
      'An interrupted restore was completed.';

  @override
  String get startup_maintenanceRecoveredRestoreRolledBack =>
      'An interrupted restore was undone. The profile was left as it was.';

  @override
  String get startup_maintenanceRecoveredRestoreReconciled =>
      'An interrupted restore was reconciled. Check the profile to see whether the backup was applied.';

  @override
  String get startup_maintenanceRecoveredDeletion =>
      'An interrupted deletion was completed.';

  @override
  String get startup_maintenanceTaskDidNotFinish => 'It did not finish.';

  @override
  String startup_maintenanceLeaseLost(
    String nothingChanged,
    String reopenToContinue,
  ) {
    return 'WebLibre can no longer safely work on this profile. $nothingChanged $reopenToContinue';
  }

  @override
  String startup_maintenanceTaskCancelled(String task) {
    return '$task was canceled.';
  }

  @override
  String get startup_maintenanceEvidenceDiscarded =>
      'The interrupted record was discarded.';

  @override
  String get startup_maintenanceEvidenceDiscardedKept =>
      'The interrupted record was discarded. WebLibre could not tell which profile the saved data belonged to, so it kept the saved data on the device rather than removing it.';

  @override
  String startup_maintenanceWrongPassword(String nothingChanged) {
    return 'The password did not open this backup file. Check it and try again. $nothingChanged';
  }

  @override
  String startup_maintenanceUnreadableArchive(String nothingChanged) {
    return 'The password did not open this backup file, or the file is damaged. Check the password and try again. $nothingChanged';
  }

  @override
  String startup_maintenanceDamagedArchive(String nothingChanged) {
    return 'This backup file is damaged and could not be read. $nothingChanged';
  }

  @override
  String startup_maintenanceUnsupportedArchiveVersion(String nothingChanged) {
    return 'This backup file was created by a newer version of WebLibre and cannot be read here. $nothingChanged';
  }

  @override
  String startup_maintenanceNotEnoughStorageWithFree(
    String required,
    String free,
    String nothingChanged,
  ) {
    return 'There is not enough free space: this needs about $required, but only $free is available. $nothingChanged';
  }

  @override
  String startup_maintenanceNotEnoughStorageKnown(
    String required,
    String nothingChanged,
  ) {
    return 'There is not enough free space: this needs about $required. $nothingChanged';
  }

  @override
  String startup_maintenanceNotEnoughStorageUnknown(String nothingChanged) {
    return 'There is not enough free space to do this. $nothingChanged';
  }

  @override
  String startup_maintenanceBackupFolderUnavailable(String nothingChanged) {
    return 'The backup could not be written to the folder. Choose the folder again and retry. $nothingChanged';
  }

  @override
  String get startup_maintenanceProfileNoLongerExists =>
      'That profile no longer exists.';

  @override
  String get startup_maintenanceRestoreEvidenceUnresolved =>
      'An earlier attempt at this restore left a record that has not been resolved yet.';

  @override
  String get startup_maintenanceRestoreWrongProfile =>
      'This backup does not match the profile it was going to replace.';

  @override
  String get startup_maintenanceRestoreRejected =>
      'This backup file cannot be restored.';

  @override
  String get startup_maintenanceRestoreIncomplete =>
      'The backup file is incomplete.';

  @override
  String get startup_maintenanceRestoreNoMetadata =>
      'The backup file has no profile metadata.';

  @override
  String get startup_maintenanceRestoreMalformedMetadata =>
      'The backup file\'s profile metadata could not be read.';

  @override
  String get startup_maintenanceRestoreNoProfileData =>
      'The backup file has no profile data.';

  @override
  String get startup_maintenanceHeadline => 'Profile maintenance';

  @override
  String get startup_maintenanceMustFinish =>
      'This task must finish before any profile can open. WebLibre keeps the profile closed while it works.';

  @override
  String get startup_maintenanceNothingLeft => 'Nothing is left to finish.';

  @override
  String get startup_maintenanceCannotReadRecord =>
      'WebLibre found interrupted profile work, but cannot read its record.';

  @override
  String get startup_maintenancePasswordLabel => 'Backup file password';

  @override
  String get startup_maintenancePasswordRejected =>
      'This password did not open the backup file';

  @override
  String get startup_maintenancePasswordHelperRequiredBackup =>
      'Required. You need this to restore the backup, and it is not stored anywhere.';

  @override
  String get startup_maintenancePasswordHelperRequiredRestore =>
      'Required. Enter the password used to create this backup file.';

  @override
  String get startup_maintenancePasswordHelperBackup =>
      'You need this to restore the backup. It is not stored anywhere.';

  @override
  String get startup_maintenancePasswordHelperRestore =>
      'The password this backup file was created with.';

  @override
  String get startup_maintenanceTryFinishingAgain => 'Try finishing it again';

  @override
  String get startup_maintenanceDiscardAndContinueBlocked =>
      'Discard the record and continue';

  @override
  String get startup_maintenanceDiscardAndContinueNoTasks =>
      'Discard the record and continue';

  @override
  String get startup_maintenanceOpenWebLibreRetry => 'Open WebLibre';

  @override
  String get startup_maintenanceOpenWebLibre => 'Open WebLibre';

  @override
  String get startup_maintenanceTakesSeveralMinutes =>
      'This can take several minutes. Keep WebLibre open.';

  @override
  String get startup_maintenanceThenAfterThisOne => 'Then, after this one';

  @override
  String get startup_maintenanceSkipForNow => 'Skip for now';

  @override
  String get startup_maintenanceInterruptedMustFinish =>
      'This was interrupted after it started. It must finish before any profile can open.';

  @override
  String get startup_maintenanceInterruptedFinishFailed =>
      'This was interrupted after it started, and finishing it did not succeed. It cannot be started over until it has been finished.';

  @override
  String get startup_maintenanceInterruptedUnreadable =>
      'This was interrupted after it started, and WebLibre cannot read what it was doing. It cannot be run again until that record is dealt with.';

  @override
  String get startup_maintenanceDiscardDialogTitle =>
      'Discard the interrupted record?';

  @override
  String get startup_maintenanceDiscardDialogContent =>
      'WebLibre cannot read what a backup, restore or deletion was doing when it stopped. Discarding the record lets the browser open again, but a profile that was being replaced may need to be checked afterward.\n\nIf the profile is missing, WebLibre restores the data it saved before replacing it. If the profile is present, WebLibre removes that saved data. If WebLibre cannot tell which profile the saved data belongs to, it keeps the data rather than removing it.';

  @override
  String get startup_maintenanceDiscardIt => 'Discard it';

  @override
  String get startup_maintenanceBackupVerb => 'Back up now';

  @override
  String get startup_maintenanceBackupRetry => 'Try the backup again';

  @override
  String get startup_maintenanceBackupCancel => 'Cancel this backup';

  @override
  String startup_maintenanceBackupDescribe(String profileName) {
    return 'Back up \"$profileName\"';
  }

  @override
  String startup_maintenanceBackupConsequence(String secretDataDescription) {
    return 'Writes an encrypted backup file of this profile, including its $secretDataDescription.';
  }

  @override
  String startup_maintenanceBackupActivity(String profileName) {
    return 'Packing \"$profileName\"…';
  }

  @override
  String startup_maintenanceBackupDescribeDone(String profileName) {
    return '\"$profileName\" was backed up to the folder you chose.';
  }

  @override
  String get startup_maintenanceRestoreOverVerb => 'Replace now';

  @override
  String get startup_maintenanceRestoreOverRetry => 'Try the restore again';

  @override
  String get startup_maintenanceRestoreOverCancel => 'Cancel this restore';

  @override
  String startup_maintenanceRestoreOverDescribe(String profileName) {
    return 'Replace \"$profileName\"';
  }

  @override
  String startup_maintenanceRestoreOverConsequenceWithRename(
    String signedInFromBackup,
    String olderBackupKeepsCredentials,
    String cannotBeUndone,
  ) {
    return 'Replaces everything in this profile with the backup. $signedInFromBackup $olderBackupKeepsCredentials It also takes the backup\'s name. $cannotBeUndone';
  }

  @override
  String startup_maintenanceRestoreOverConsequencePlain(
    String signedInFromBackup,
    String olderBackupKeepsCredentials,
    String cannotBeUndone,
  ) {
    return 'Replaces everything in this profile with the backup. $signedInFromBackup $olderBackupKeepsCredentials $cannotBeUndone';
  }

  @override
  String startup_maintenanceRestoreOverActivity(String profileName) {
    return 'Replacing \"$profileName\"…';
  }

  @override
  String startup_maintenanceRestoreOverDescribeDone(String profileName) {
    return '\"$profileName\" was replaced with the backup.';
  }

  @override
  String get startup_maintenanceDeleteVerb => 'Delete now';

  @override
  String get startup_maintenanceDeleteRetry => 'Try the deletion again';

  @override
  String get startup_maintenanceDeleteCancel => 'Cancel this deletion';

  @override
  String startup_maintenanceDeleteDescribe(String profileName) {
    return 'Delete \"$profileName\"';
  }

  @override
  String startup_maintenanceDeleteConsequence(
    String profileDataDescription,
    String cannotBeUndone,
  ) {
    return 'Removes this profile and its $profileDataDescription. $cannotBeUndone';
  }

  @override
  String startup_maintenanceDeleteActivity(String profileName) {
    return 'Deleting \"$profileName\"…';
  }

  @override
  String startup_maintenanceDeleteDescribeDone(String profileName) {
    return '\"$profileName\" was deleted.';
  }

  @override
  String get startup_maintenanceRestoreCloneVerb => 'Cannot run this';

  @override
  String get startup_maintenanceRestoreCloneRetry => 'Try the restore again';

  @override
  String get startup_maintenanceRestoreCloneCancel => 'Cancel this restore';

  @override
  String startup_maintenanceRestoreCloneDescribe(String profileName) {
    return 'Restore \"$profileName\"';
  }

  @override
  String get startup_maintenanceRestoreCloneConsequence =>
      'This restore was created by a newer version of WebLibre and cannot run here.';

  @override
  String startup_maintenanceRestoreCloneActivity(String profileName) {
    return 'Restoring \"$profileName\"…';
  }

  @override
  String startup_maintenanceRestoreCloneDescribeDone(String profileName) {
    return '\"$profileName\" was restored.';
  }

  @override
  String get startup_maintenanceUnknownVerb => 'Run';

  @override
  String get startup_maintenanceUnknownRetry => 'Try the task again';

  @override
  String get startup_maintenanceUnknownCancel => 'Cancel this task';

  @override
  String startup_maintenanceUnknownDescribe(String taskId) {
    return 'Unknown task $taskId';
  }

  @override
  String get startup_maintenanceUnknownConsequence =>
      'This task was created by a newer version of WebLibre and cannot run.';

  @override
  String get startup_maintenanceUnknownActivity => 'Working…';

  @override
  String get startup_maintenanceUnknownDescribeDone => 'Done.';

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
  String get failureWidget_defaultTitle => 'Something went wrong';

  @override
  String get failureWidget_unknownError => 'Unknown error';

  @override
  String get speechToTextButton_serviceNotAvailable =>
      'Speech recognition is not available';

  @override
  String get formValidators_urlRequired => 'A URL is required';

  @override
  String get formValidators_invalidUrl => 'Invalid URL';

  @override
  String get formValidators_valueRequired => 'Value required';

  @override
  String get formValidators_nameRequired => 'Name required';

  @override
  String get formValidators_nameInvalidCharacters =>
      'Name contains invalid characters';

  @override
  String uiHelper_findInPageSuggestion(String query) {
    return 'Find \"$query\" on this page?';
  }

  @override
  String get uiHelper_actionFind => 'Find';

  @override
  String uiHelper_openedTabsFromAnotherDevice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Opened $count tabs from another device',
      one: 'Opened 1 tab from another device',
    );
    return '$_temp0';
  }

  @override
  String get uiHelper_navigateBackToCloseTab =>
      'Press BACK again to close the current tab';

  @override
  String get uiHelper_navigateBackToExitApp =>
      'Press BACK again to exit the app';

  @override
  String uiHelper_newTabOpenedInBackgroundNamed(String tabName) {
    return 'New tab \'$tabName\' opened in background';
  }

  @override
  String get uiHelper_newTabOpenedInBackground =>
      'New tab opened in background';

  @override
  String get uiHelper_actionShow => 'Show';

  @override
  String get uiHelper_wantToOpenLinkFromClipboard =>
      'Open the link from your clipboard?';

  @override
  String uiHelper_newTabOpenedNamed(String tabName) {
    return 'New tab \'$tabName\' opened';
  }

  @override
  String get uiHelper_newTabOpened => 'New tab opened';

  @override
  String get uiHelper_actionSwitch => 'Switch';

  @override
  String uiHelper_couldNotLaunchUrl(String url) {
    return 'Could not launch URL ($url)';
  }

  @override
  String uiHelper_canNotHandleScheme(String scheme) {
    return 'Cannot handle \"$scheme\"';
  }

  @override
  String uiHelper_tabsClosedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tabs closed',
      one: 'Tab closed',
    );
    return '$_temp0';
  }

  @override
  String get uiHelper_closeIsolatedTabsTitle => 'Close isolated tabs?';

  @override
  String uiHelper_closeIsolatedTabsConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'This will permanently clear browsing data for $count isolated sessions.',
      one:
          'This will permanently clear all browsing data for this isolated session.',
    );
    return '$_temp0';
  }
}
