import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('id'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// Generic button that closes a dialog or leaves an editor without doing anything. Used throughout the app.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// Generic button or menu item that permanently deletes the selected item. Used throughout the app, often in confirmation dialogs.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// Generic button that closes a dialog or panel; also used as the confirm button of "close tabs" dialogs, where it means closing browser tabs. Used throughout the app.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// Generic button that saves changes in a dialog or editor. Used throughout the app.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// Generic button that adds the item entered in a dialog or form (e.g. a feed, a site). Used throughout the app.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get common_add;

  /// Generic button, menu item or tooltip that opens an editor for the selected item. Used throughout the app.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// Generic button or menu item that removes an item from a list (e.g. an extension, a shortcut) or confirms its removal. Used throughout the app.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get common_remove;

  /// Generic button that deletes stored data such as history or site data, usually confirming a dialog. Used throughout the app.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get common_clear;

  /// Generic button that copies text to the clipboard. Used throughout the app.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get common_copy;

  /// Generic button or menu item that opens an item, e.g. a finished download or a bookmark. Used throughout the app.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get common_open;

  /// Generic button that restores something to its default state, usually confirming a dialog. Used throughout the app.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get common_reset;

  /// Generic button or tooltip that repeats an action that failed. Used throughout the app.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// Generic button that ends an editing or reordering mode. Used throughout the app.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get common_done;

  /// Generic action on a short message at the bottom of the screen that reverses the action just performed (e.g. closing a tab). Used throughout the app.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get common_undo;

  /// Generic tooltip or button that hides a banner or notice without acting on it. Used throughout the app.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get common_dismiss;

  /// Generic button that throws away unsaved changes or a temporary item instead of keeping it. Used throughout the app.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get common_discard;

  /// Generic button that collapses an expanded list or text back to its short form. Used throughout the app.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get common_showLess;

  /// Generic placeholder text shown while a value is being loaded. Used throughout the app.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get common_loading;

  /// List fragment inserted into another sentence on the startup profile picker ("each profile keeps its own …"). Names what a browser profile holds. Lowercase, no final period.
  ///
  /// In en, this message translates to:
  /// **'tabs, history and settings'**
  String get profileCopy_pickerContents;

  /// List fragment inserted into sentences about deleting, restoring or replacing a browser profile. Names everything the profile holds that would be lost. Lowercase, no final period.
  ///
  /// In en, this message translates to:
  /// **'tabs, history, bookmarks, settings and saved site logins'**
  String get profileCopy_dataDescription;

  /// List fragment inserted into sentences about profile backups. Names the sensitive account data that backups include. Lowercase, no final period. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'WebLibre account sign-in, sync setup and proxy details'**
  String get profileCopy_secretDataDescription;

  /// Standalone sentence appended to warnings before deleting or overwriting a browser profile.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get profileCopy_cannotBeUndone;

  /// Standalone sentence appended to error messages when a profile backup, restore or delete stopped before touching any data, reassuring the user that it is safe to retry.
  ///
  /// In en, this message translates to:
  /// **'Nothing has been changed.'**
  String get profileCopy_nothingChanged;

  /// Standalone sentence in profile backup, restore and delete screens: the app has to restart to carry out the operation. Always followed by further sentences.
  ///
  /// In en, this message translates to:
  /// **'WebLibre must restart to do this.'**
  String get profileCopy_restartsToWork;

  /// Standalone sentence in the backup restore flow: after restarting, the app asks for the backup file password.
  ///
  /// In en, this message translates to:
  /// **'After restarting, WebLibre asks for the backup file password.'**
  String get profileCopy_asksPasswordAfterRestart;

  /// Standalone instruction appended to startup error messages that can only be cleared by fully closing and reopening the app.
  ///
  /// In en, this message translates to:
  /// **'Close WebLibre and open it again.'**
  String get profileCopy_reopenToContinue;

  /// Standalone sentence in the warning before restoring a backup over an existing profile: account sign-ins are taken from the backup, not kept from the replaced profile.
  ///
  /// In en, this message translates to:
  /// **'The restored profile uses the WebLibre account from the backup.'**
  String get profileCopy_signedInFromBackup;

  /// Standalone sentence that follows the note that a restored profile uses the account from the backup. "These" refers to the account sign-in and credentials; backups from older app versions have none, so the current ones are kept.
  ///
  /// In en, this message translates to:
  /// **'A backup made by an older version of WebLibre carries none of these, and the profile keeps the ones it has now.'**
  String get profileCopy_olderBackupKeepsCredentials;

  /// Error message when a profile backup, restore or delete needs an app restart that the system refused to schedule. nothingChanged is the sentence "Nothing has been changed."
  ///
  /// In en, this message translates to:
  /// **'WebLibre could not schedule the restart required for this operation. {nothingChanged}'**
  String profileCopy_restartCouldNotBeScheduled(String nothingChanged);

  /// Standalone sentence in profile backup and restore screens: home-screen shortcuts that open a profile stop working after a restore and must be added to the home screen again.
  ///
  /// In en, this message translates to:
  /// **'Pin home-screen shortcuts again after restore.'**
  String get profileCopy_shortcutsNeedPinningAgain;

  /// Standalone sentence that follows a note that the app restarts for a profile operation: the restart also closes the profile the user is currently browsing in, which may differ from the profile being backed up or deleted.
  ///
  /// In en, this message translates to:
  /// **'It also closes the profile you are using now, which is not always the profile named here.'**
  String get profileCopy_restartClosesCurrentProfile;

  /// Reassurance under the list of what an app restart for a profile operation will lose: regular tabs are restored after the restart.
  ///
  /// In en, this message translates to:
  /// **'Your other tabs reopen afterward.'**
  String get profileCopy_restartKeepsOtherTabs;

  /// Item in the list of what an app restart for a profile operation will lose. count is the number of open private tabs, which do not survive a restart.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 private tab closes and its browsing data is cleared.} other{{count} private tabs close and their browsing data is cleared.}}'**
  String profileCopy_privateTabsClosedByRestart(int count);

  /// Item in the list of what an app restart for a profile operation will lose. count is the number of containers (separate browsing identities) configured to delete their browsing data when the app exits.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 container set to clear data on exit is cleared.} other{{count} containers set to clear data on exit are cleared.}}'**
  String profileCopy_containersClearedByRestart(int count);

  /// Error message when a network request failed because the server could not be reached (no connection, DNS or socket failure).
  ///
  /// In en, this message translates to:
  /// **'Could not contact remote service'**
  String get httpErrorHandler_socketError;

  /// Error message when a server answered a network request with an HTTP error status.
  ///
  /// In en, this message translates to:
  /// **'The web request returned an error'**
  String get httpErrorHandler_httpError;

  /// Error message when a server answered but its response could not be parsed.
  ///
  /// In en, this message translates to:
  /// **'Bad response format'**
  String get httpErrorHandler_formatError;

  /// Error message when a network request failed inside the HTTP client before any response arrived.
  ///
  /// In en, this message translates to:
  /// **'Could not contact remote service'**
  String get httpErrorHandler_clientError;

  /// Name given to a browser profile the app found on disk without its metadata and recovered. idFragment is the last 8 characters of the profile id, so recovered profiles can be told apart. Must not contain brackets: profile names with brackets are rejected.
  ///
  /// In en, this message translates to:
  /// **'Recovered profile {idFragment}'**
  String profileDiscovery_recoveredProfileName(String idFragment);

  /// Copyright line in the About dialog. Keep the name and years unchanged.
  ///
  /// In en, this message translates to:
  /// **'Copyright © Fabian Freund, 2024-2026'**
  String get about_copyright;

  /// Row title in the About dialog; the version number of the Gecko browser engine is shown below it. Gecko is a product name.
  ///
  /// In en, this message translates to:
  /// **'Gecko Version'**
  String get about_geckoVersionTitle;

  /// Abbreviation for "not available", shown in the About dialog when the Gecko engine version cannot be determined.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get about_notAvailable;

  /// Row in the About dialog that opens the page for sending feedback or reporting issues.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get about_feedbackTitle;

  /// Row in the About dialog that opens the page for donating to the project.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get about_donateTitle;

  /// Row in the About dialog that opens the online documentation.
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get about_documentationTitle;

  /// Row in the About dialog that opens the project repository on GitHub. GitHub is a brand name.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get about_githubTitle;

  /// Title of the settings screen for the WebLibre Account (the app's own optional online account for the supporter subscription, search credits and encrypted settings sync). WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'WebLibre Account'**
  String get account_screenTitle;

  /// Placeholder of the search field on the WebLibre Account screen.
  ///
  /// In en, this message translates to:
  /// **'Search account settings'**
  String get account_searchHint;

  /// Error shown in place of the account screen content when the account state could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Failed to load account'**
  String get account_loadFailed;

  /// Section heading on the WebLibre Account screen for sign-in status.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account_sectionAccount;

  /// Section heading on the WebLibre Account screen for the supporter subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get account_sectionSubscription;

  /// Section heading on the WebLibre Account screen for prepaid search credits.
  ///
  /// In en, this message translates to:
  /// **'Search Credits'**
  String get account_sectionSearchCredits;

  /// Section heading for encrypted copies of the app's settings stored in the account ("snapshots").
  ///
  /// In en, this message translates to:
  /// **'Settings Snapshots'**
  String get account_sectionSettingsSnapshots;

  /// Section heading for encrypted copies of the browser engine preferences stored in the account.
  ///
  /// In en, this message translates to:
  /// **'Preferences Snapshots'**
  String get account_sectionPreferencesSnapshots;

  /// Section heading for setting up end-to-end encrypted sync of settings.
  ///
  /// In en, this message translates to:
  /// **'Encrypted Sync'**
  String get account_sectionEncryptedSync;

  /// Row that starts signing in to the WebLibre Account; also the title of the account section while signed out.
  ///
  /// In en, this message translates to:
  /// **'Sign in to WebLibre Account'**
  String get account_signInTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'sign in, account, authentication'**
  String get account_signInKeywords;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'sync key, reset sync key'**
  String get account_signInSyncKeyKeywords;

  /// Title of the account section while sign-in is in progress.
  ///
  /// In en, this message translates to:
  /// **'Signing in'**
  String get account_signingInTitle;

  /// Title of the account section while signed in.
  ///
  /// In en, this message translates to:
  /// **'Signed in account'**
  String get account_signedInTitle;

  /// Title of the account section, and heading of the error card, when signing in failed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed'**
  String get account_signInFailedTitle;

  /// Line under the sign-in row explaining what the account is for.
  ///
  /// In en, this message translates to:
  /// **'Sync your settings across devices'**
  String get account_syncAcrossDevicesSubtitle;

  /// Line under the account section while sign-in waits for the user to finish it on the sign-in web page.
  ///
  /// In en, this message translates to:
  /// **'Complete sign-in in your browser'**
  String get account_signingInSubtitle;

  /// Shown in place of the user's name or email when signed in but neither is known.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get account_signedInFallback;

  /// Title of the supporter subscription entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Supporter subscription'**
  String get account_entrySupporterSubscriptionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'billing, supporter'**
  String get account_entrySupporterSubscriptionKeywords;

  /// Summary of the supporter subscription entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Status, billing, and subscription management'**
  String get account_entrySupporterSubscriptionSubtitle;

  /// Title of the search credits entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Search credits'**
  String get account_entrySearchCreditsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'tokens, search pack'**
  String get account_entrySearchCreditsKeywords;

  /// Summary of the search credits entry, shown as a settings search result. Tokens are anonymous search tokens created from credits.
  ///
  /// In en, this message translates to:
  /// **'Credits balance, token issuance, and purchases'**
  String get account_entrySearchCreditsSubtitle;

  /// Title of the settings snapshots entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Settings snapshots'**
  String get account_entrySettingsSnapshotsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'backups, settings sync'**
  String get account_entrySettingsSnapshotsKeywords;

  /// Summary of the settings snapshots entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Store and restore synced application settings'**
  String get account_entrySettingsSnapshotsSubtitle;

  /// Title of the preferences snapshots entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Preferences snapshots'**
  String get account_entryPreferencesSnapshotsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'backups, prefs sync'**
  String get account_entryPreferencesSnapshotsKeywords;

  /// Summary of the preferences snapshots entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Store and restore synced preference documents'**
  String get account_entryPreferencesSnapshotsSubtitle;

  /// Title of the encrypted sync setup entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Set up encrypted sync'**
  String get account_entrySetupEncryptedSyncTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'sync key, backups, snapshots'**
  String get account_entrySetupEncryptedSyncKeywords;

  /// Summary of the encrypted sync setup entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Enable end-to-end encrypted sync using your account password'**
  String get account_entrySetupEncryptedSyncSubtitle;

  /// Menu item of a stored snapshot, and confirm button of the restore dialog: replace the current settings with the snapshot.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get account_actionRestore;

  /// Menu item of a stored snapshot that renames it, and title of the rename dialog.
  ///
  /// In en, this message translates to:
  /// **'Edit Label'**
  String get account_actionEditLabel;

  /// Confirm button of the dialog that uploads a new encrypted snapshot.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get account_actionStore;

  /// Button on the sign-in error card that starts sign-in again.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get account_actionTryAgain;

  /// Confirm button of the sign-out dialog.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get account_actionSignOut;

  /// Button that sets up encrypted sync with the entered password.
  ///
  /// In en, this message translates to:
  /// **'Enable Sync'**
  String get account_actionEnableSync;

  /// Heading of a card about an account sign-in left over from an older app version, before each profile had its own account.
  ///
  /// In en, this message translates to:
  /// **'An older sign-in is still on this device'**
  String get account_adoptTitleUsable;

  /// Heading of the same card when the leftover sign-in is damaged.
  ///
  /// In en, this message translates to:
  /// **'An older sign-in cannot be read'**
  String get account_adoptTitleUnusable;

  /// Body of the leftover sign-in card. name is the account's email or name, or "a previous sign-in".
  ///
  /// In en, this message translates to:
  /// **'WebLibre kept a sign-in for {name} from before profiles had separate accounts. It is not from a backup, and nothing on this device records which profile it belonged to, so WebLibre will not guess.'**
  String account_adoptBodyUsable(String name);

  /// Body of the card when the leftover sign-in is damaged and can only be removed.
  ///
  /// In en, this message translates to:
  /// **'WebLibre kept a sign-in from before profiles had separate accounts, but the saved data is damaged and cannot be used to sign in. Signing in again is the only way back; removing it clears this message.'**
  String get account_adoptBodyUnusable;

  /// Error on the leftover sign-in card when using or removing it failed.
  ///
  /// In en, this message translates to:
  /// **'That did not work. Check your connection and try again.'**
  String get account_adoptRetryError;

  /// Button on the leftover sign-in card: this sign-in does not belong to this profile (removes it after confirmation).
  ///
  /// In en, this message translates to:
  /// **'Not mine'**
  String get account_adoptNotMine;

  /// Button on the damaged leftover sign-in card that deletes it.
  ///
  /// In en, this message translates to:
  /// **'Remove it'**
  String get account_adoptRemoveIt;

  /// Button on the leftover sign-in card that signs this profile in with it.
  ///
  /// In en, this message translates to:
  /// **'Use it here'**
  String get account_adoptUseItHere;

  /// Title of the confirmation dialog before deleting a leftover sign-in.
  ///
  /// In en, this message translates to:
  /// **'Forget this sign-in?'**
  String get account_forgetSignInTitle;

  /// Body of that dialog. name is the account's email or name, or "a previous sign-in".
  ///
  /// In en, this message translates to:
  /// **'The saved session for {name} is deleted from this device. If it belonged to another profile, you have to sign in again there.'**
  String account_forgetSignInContent(String name);

  /// Confirm button of that dialog.
  ///
  /// In en, this message translates to:
  /// **'Forget it'**
  String get account_actionForgetIt;

  /// Fallback phrase for a leftover sign-in with no known email or name, inserted into sentences such as "…a sign-in for {name}…". Lowercase.
  ///
  /// In en, this message translates to:
  /// **'a previous sign-in'**
  String get account_previousSignInFallback;

  /// Row and heading prompting to sign in again with a known account. account is the email address.
  ///
  /// In en, this message translates to:
  /// **'Sign in again as {account}'**
  String account_signInAgainAs(String account);

  /// Line under "Sign in again as …": the saved session expired but the sync encryption key is still on the device.
  ///
  /// In en, this message translates to:
  /// **'This profile\'s saved sign-in expired. Your sync key is kept.'**
  String get account_signInExpiredSubtitle;

  /// Progress text while sign-in is in progress.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get account_signingInEllipsis;

  /// Instruction under the sign-in progress: finish signing in on the web page opened in WebLibre.
  ///
  /// In en, this message translates to:
  /// **'Complete sign-in in WebLibre'**
  String get account_completeSignInInApp;

  /// Tooltip of the sign-out button on the signed-in account row.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get account_tooltipSignOut;

  /// Title of the sign-out confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get account_signOutConfirmTitle;

  /// Body of the sign-out confirmation dialog. "WebLibre Account" is the account's name.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of your WebLibre Account?'**
  String get account_signOutConfirmContent;

  /// Row, and dialog title, for resetting the encryption key used for sync; the account password must be entered again.
  ///
  /// In en, this message translates to:
  /// **'Reset Sync Key'**
  String get account_resetSyncKeyTitle;

  /// Explanation under "Reset Sync Key".
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password if you mistyped it or changed it'**
  String get account_resetSyncKeySubtitle;

  /// Body of the reset sync key dialog: snapshots encrypted with an old password become unreadable.
  ///
  /// In en, this message translates to:
  /// **'You will need to re-enter your account password. If your password changed, existing snapshots encrypted with the old password will no longer be decryptable.'**
  String get account_resetSyncKeyConfirmContent;

  /// Error heading when the subscription status could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Could not load subscription'**
  String get account_subscriptionLoadFailed;

  /// Line under that error heading.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get account_checkConnectionRetry;

  /// Name shown for the subscription plan when the server gives none. Plan name.
  ///
  /// In en, this message translates to:
  /// **'Supporter'**
  String get account_planFallbackSupporter;

  /// Status badge on the subscription card: the subscription was canceled and ends at the end of the period, or has ended.
  ///
  /// In en, this message translates to:
  /// **'Will not renew'**
  String get account_badgeWillNotRenew;

  /// Status badge on the subscription card: the subscription is active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get account_badgeActive;

  /// Line on the subscription card. date is the formatted end date of the paid period.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String account_untilDate(String date);

  /// Button on the subscription card that opens the billing portal website.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get account_actionManageSubscription;

  /// Status badge on the subscription card: the subscription is paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get account_badgePaused;

  /// Note on the subscription card while it is paused. The customer portal is the billing website.
  ///
  /// In en, this message translates to:
  /// **'Your subscription is paused. Resume it from the customer portal to restore access.'**
  String get account_pausedNote;

  /// Status badge on the subscription card: the last payment failed.
  ///
  /// In en, this message translates to:
  /// **'Past due'**
  String get account_badgePastDue;

  /// Note on the subscription card after a failed payment.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Update your payment method to keep your subscription active.'**
  String get account_pastDueNote;

  /// Button on the subscription card that opens the billing portal to change the payment method.
  ///
  /// In en, this message translates to:
  /// **'Update Payment Method'**
  String get account_actionUpdatePaymentMethod;

  /// Note on the subscription card after the subscription ended. The customer portal is the billing website.
  ///
  /// In en, this message translates to:
  /// **'Your subscription has ended. Renew from the customer portal to continue.'**
  String get account_endedNote;

  /// Button on the subscription card that opens the billing portal to subscribe again.
  ///
  /// In en, this message translates to:
  /// **'Renew Subscription'**
  String get account_actionRenewSubscription;

  /// Title of the subscription card for users without a subscription. Plan name.
  ///
  /// In en, this message translates to:
  /// **'Supporter Subscription'**
  String get account_planSupporterSubscription;

  /// Line under the subscription title for users without a subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to unlock sync features'**
  String get account_subscribeSubtitle;

  /// Status badge on the subscription card: no subscription.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get account_badgeInactive;

  /// Button on the subscription card that opens the page for subscribing.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get account_actionSubscribe;

  /// Tooltip of the button that reloads the subscription status.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get account_tooltipRefreshStatus;

  /// Warning on the subscription card after canceling. date is the formatted end date.
  ///
  /// In en, this message translates to:
  /// **'Your subscription will end on {date}'**
  String account_subscriptionEndsOn(String date);

  /// Heading of the home screen banner inviting users to become supporters.
  ///
  /// In en, this message translates to:
  /// **'Support WebLibre'**
  String get account_bannerTitle;

  /// Body of the supporter banner on the home screen. The text between <learnMore>…</learnMore> becomes a tappable link to more information; keep the tag pair and translate the text inside it. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'Supporter is an optional subscription that funds WebLibre\'s development and provides the features that need a hosted service to work. The browser and its privacy features need no subscription. <learnMore>Learn more</learnMore>.'**
  String get account_bannerBody;

  /// Bullet heading in the supporter banner naming the search feature. Product name.
  ///
  /// In en, this message translates to:
  /// **'WebLibre Search'**
  String get account_featureSearchLabel;

  /// Bullet text in the supporter banner describing WebLibre Search. Tor is a product name.
  ///
  /// In en, this message translates to:
  /// **'A private, ad-free search built into the browser. It blends results from several independent sources, offers tunable search modes, can route over Tor, and lets you preview pages safely — while keeping your searches unlinkable to your account by design.'**
  String get account_featureSearchDescription;

  /// Bullet heading in the supporter banner naming encrypted settings sync.
  ///
  /// In en, this message translates to:
  /// **'Encrypted account sync'**
  String get account_featureSyncLabel;

  /// Bullet text in the supporter banner describing encrypted settings sync.
  ///
  /// In en, this message translates to:
  /// **'Store and restore your WebLibre settings and preferences across profiles and devices. Everything is encrypted on your device before upload, so only you can read it.'**
  String get account_featureSyncDescription;

  /// Button in the supporter banner that opens the account screen to subscribe.
  ///
  /// In en, this message translates to:
  /// **'Become a Supporter'**
  String get account_becomeSupporter;

  /// Error under the password field when setting up encrypted sync without a password.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get account_syncSetupEnterPassword;

  /// Error when the password and its confirmation differ.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get account_syncSetupPasswordsMismatch;

  /// Error when the entered password cannot decrypt snapshots already stored in the account.
  ///
  /// In en, this message translates to:
  /// **'Password did not match your existing encrypted backups.'**
  String get account_syncSetupPasswordMismatchBackup;

  /// Error message when setting up encrypted sync failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to set up sync: {error}'**
  String account_syncSetupFailed(String error);

  /// Heading of the card for setting up encrypted sync.
  ///
  /// In en, this message translates to:
  /// **'Set Up Encrypted Sync'**
  String get account_syncSetupTitle;

  /// Explanation on the encrypted sync setup card.
  ///
  /// In en, this message translates to:
  /// **'Enter your account password to enable end-to-end encrypted sync. Your data is encrypted on-device before upload — the server never sees your settings.'**
  String get account_syncSetupDescription;

  /// Label of the password field on the encrypted sync setup card.
  ///
  /// In en, this message translates to:
  /// **'Account Password'**
  String get account_fieldAccountPassword;

  /// Label of the field for typing the password a second time.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get account_fieldConfirmPassword;

  /// Error message when the list of stored snapshots could not be loaded. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to load snapshots: {error}'**
  String account_failedLoadSnapshots(String error);

  /// Confirmation after uploading a snapshot. kind selects the kind of data: weblibreSettings is WebLibre's own settings, geckoUserJs the browser engine preferences. Translate each case; keep the case names unchanged.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, weblibreSettings{Settings stored} geckoUserJs{Gecko Prefs stored} other{Snapshot stored}}'**
  String account_syncKindStored(String kind);

  /// Heading of a list of stored snapshots. kind selects the kind of data: weblibreSettings is WebLibre's own settings, geckoUserJs the browser engine preferences (Gecko is the engine's name). Translate each case; keep the case names unchanged.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, weblibreSettings{Settings Snapshots} geckoUserJs{Gecko Prefs Snapshots} other{Snapshots}}'**
  String account_syncKindSnapshotsTitle(String kind);

  /// Row that encrypts and uploads the current data as a new snapshot.
  ///
  /// In en, this message translates to:
  /// **'Store Current'**
  String get account_storeCurrentTitle;

  /// Line under "Store Current". kind selects the kind of data: weblibreSettings is WebLibre's own settings, geckoUserJs the browser engine preferences. Translate each case; keep the case names unchanged.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, weblibreSettings{Encrypt and upload the current settings} geckoUserJs{Encrypt and upload the current Gecko prefs} other{Encrypt and upload the current data}}'**
  String account_storeCurrentSubtitle(String kind);

  /// Shown when no snapshots are stored in the account.
  ///
  /// In en, this message translates to:
  /// **'No snapshots stored yet'**
  String get account_noSnapshotsYet;

  /// Error message when uploading a snapshot failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to store: {error}'**
  String account_failedToStore(String error);

  /// Confirmation after restoring a snapshot. kind selects the kind of data: weblibreSettings is WebLibre's own settings, geckoUserJs the browser engine preferences. Translate each case; keep the case names unchanged.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, weblibreSettings{Settings restored} geckoUserJs{Gecko Prefs restored} other{Snapshot restored}}'**
  String account_syncKindRestored(String kind);

  /// Error message when the chosen snapshot no longer exists on the server.
  ///
  /// In en, this message translates to:
  /// **'Snapshot not found'**
  String get account_snapshotNotFound;

  /// Error message when a snapshot could not be decrypted.
  ///
  /// In en, this message translates to:
  /// **'Decryption failed — wrong password or data corrupted. Try resetting your sync key.'**
  String get account_decryptionFailed;

  /// Error message when restoring a snapshot failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore: {error}'**
  String account_failedToRestore(String error);

  /// Error message when renaming a snapshot failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to update label: {error}'**
  String account_failedUpdateLabel(String error);

  /// Confirmation after deleting a stored snapshot.
  ///
  /// In en, this message translates to:
  /// **'Snapshot deleted'**
  String get account_snapshotDeleted;

  /// Error message when deleting a stored snapshot failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete: {error}'**
  String account_failedToDelete(String error);

  /// Fallback name of a snapshot without a label.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get account_untitledSnapshot;

  /// Label of a snapshot detail row showing its name.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get account_metaLabel;

  /// Label of a snapshot detail row showing when it was stored.
  ///
  /// In en, this message translates to:
  /// **'Stored'**
  String get account_metaStored;

  /// Label of a snapshot detail row showing the app version that stored it.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get account_metaAppVersion;

  /// Label of a snapshot detail row showing the device that stored it.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get account_metaDevice;

  /// Title of the dialog for uploading a new snapshot.
  ///
  /// In en, this message translates to:
  /// **'Store Snapshot'**
  String get account_storeSnapshotTitle;

  /// Label of the optional name field in the store-snapshot dialog.
  ///
  /// In en, this message translates to:
  /// **'Label (optional)'**
  String get account_fieldLabelOptional;

  /// Example placeholder of the snapshot name field. The quoted examples may be translated.
  ///
  /// In en, this message translates to:
  /// **'e.g. \"Before update\", \"Home setup\"'**
  String get account_labelHintExample;

  /// Label of the name field in the rename-snapshot dialog.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get account_fieldLabel;

  /// Title of the dialog confirming a snapshot restore.
  ///
  /// In en, this message translates to:
  /// **'Restore Snapshot'**
  String get account_restoreSnapshotTitle;

  /// Warning in the restore-snapshot dialog.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite your current local settings.'**
  String get account_restoreOverwriteWarning;

  /// Fallback phrase inserted into "Are you sure you want to delete {label}?" when the snapshot has no name. Lowercase.
  ///
  /// In en, this message translates to:
  /// **'this snapshot'**
  String get account_thisSnapshotFallback;

  /// Title of the confirmation dialog before deleting a stored snapshot.
  ///
  /// In en, this message translates to:
  /// **'Delete Snapshot'**
  String get account_deleteSnapshotTitle;

  /// Body of that dialog. label is the snapshot's name in quotes, or "this snapshot".
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {label}?'**
  String account_deleteSnapshotConfirm(String label);

  /// Account sign-in error: no network connection.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection and try again.'**
  String get account_authNetworkError;

  /// Account error when the saved session expired but the sync key was kept.
  ///
  /// In en, this message translates to:
  /// **'Your saved sign-in is no longer valid. Sign in again to finish restoring this account — your sync key is kept.'**
  String get account_authSessionExpiredWithKey;

  /// Account error when the saved session expired.
  ///
  /// In en, this message translates to:
  /// **'Your saved sign-in is no longer valid. Sign in again to continue.'**
  String get account_authSessionExpiredNoKey;

  /// Account error when the saved session could not be restored at startup; the app retries automatically.
  ///
  /// In en, this message translates to:
  /// **'Could not restore your account session. Retrying shortly.'**
  String get account_authRestoreFailedFallback;

  /// Account error when sign-in took too long.
  ///
  /// In en, this message translates to:
  /// **'Sign-in timed out. Please try again.'**
  String get account_authSignInTimedOut;

  /// Account error when the sign-in web page could not be opened.
  ///
  /// In en, this message translates to:
  /// **'Could not open the sign-in page. Please try again.'**
  String get account_authSignInOpenPageFailed;

  /// Account error when the sign-in web page returned but the app had no sign-in in progress.
  ///
  /// In en, this message translates to:
  /// **'No pending sign-in found. Please start sign-in again.'**
  String get account_authNoPendingSignIn;

  /// Account error when the sign-in response could not be verified as genuine.
  ///
  /// In en, this message translates to:
  /// **'Sign-in could not be verified. Please try again.'**
  String get account_authSignInVerificationFailed;

  /// Account error when sign-in was left unfinished.
  ///
  /// In en, this message translates to:
  /// **'Sign-in could not be completed. Please try again.'**
  String get account_authSignInNotCompleted;

  /// Generic account sign-in error.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please try again.'**
  String get account_authSignInFailedFallback;

  /// Title of the screen for managing browser extensions (add-ons).
  ///
  /// In en, this message translates to:
  /// **'Extensions'**
  String get addons_managerTitle;

  /// Tab on the extensions screen listing installed extensions.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get addons_tabInstalled;

  /// Tab on the extensions screen for finding extensions in Mozilla's add-on store.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get addons_tabBrowse;

  /// Error heading when the list of extensions could not be loaded; technical details follow below.
  ///
  /// In en, this message translates to:
  /// **'Failed to load extensions'**
  String get addons_loadFailedTitle;

  /// Shown when a search in the add-on store finds nothing.
  ///
  /// In en, this message translates to:
  /// **'No extensions found.'**
  String get addons_noExtensionsFound;

  /// Shown on the Installed tab when no extension is installed. Keep the line break (\n).
  ///
  /// In en, this message translates to:
  /// **'No extensions installed yet.\nBrowse the store to find some.'**
  String get addons_noneInstalledMessage;

  /// Title of the extension details screen when the extension could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Extension'**
  String get addons_genericTitle;

  /// Message when the requested extension does not exist (e.g. it was removed).
  ///
  /// In en, this message translates to:
  /// **'This extension could not be found.'**
  String get addons_notFound;

  /// Segment of the store switch: browse extensions made for Firefox on Android.
  ///
  /// In en, this message translates to:
  /// **'Android'**
  String get addons_platformAndroid;

  /// Segment of the store switch: browse extensions made for desktop Firefox.
  ///
  /// In en, this message translates to:
  /// **'Desktop'**
  String get addons_platformDesktop;

  /// Placeholder of the add-on store search field. addons.mozilla.org is a web address; keep it unchanged.
  ///
  /// In en, this message translates to:
  /// **'Search addons.mozilla.org'**
  String get addons_searchHint;

  /// Warning shown while browsing desktop extensions: they were not tested on phones.
  ///
  /// In en, this message translates to:
  /// **'Desktop extensions are not reviewed for mobile. Some may not work, may crash, or may behave unexpectedly on Android.'**
  String get addons_desktopCompatibilityWarning;

  /// Button on an add-on store listing that installs the extension.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get addons_actionInstall;

  /// Button on the extension details screen that installs the extension.
  ///
  /// In en, this message translates to:
  /// **'Install Extension'**
  String get addons_actionInstallExtension;

  /// Menu item that installs an extension from a file on the device.
  ///
  /// In en, this message translates to:
  /// **'Install from file'**
  String get addons_actionInstallFromFile;

  /// Button that opens the list of permissions the extension asks for.
  ///
  /// In en, this message translates to:
  /// **'View Permissions'**
  String get addons_actionViewPermissions;

  /// Row on the extension details screen that uninstalls the extension (asks for confirmation).
  ///
  /// In en, this message translates to:
  /// **'Remove Extension'**
  String get addons_actionRemoveExtension;

  /// Button in the update dialog that postpones the update.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get addons_actionNotNow;

  /// Button in the update dialog that installs the new version.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get addons_actionUpdate;

  /// Menu item on the extensions screen that checks all extensions for updates in the background.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get addons_actionCheckForUpdates;

  /// Button on an extension's details screen that checks that extension for an update.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get addons_actionCheckForUpdatesButton;

  /// Label of that button while the check runs.
  ///
  /// In en, this message translates to:
  /// **'Checking for Updates'**
  String get addons_actionCheckingForUpdates;

  /// Button on the permissions screen that opens Mozilla's help page about extension permissions.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get addons_actionLearnMore;

  /// Button that expands a shortened extension description; toggles with "Show less".
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get addons_actionReadMore;

  /// Section heading on the Installed tab for extensions that are turned on.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get addons_sectionEnabled;

  /// Section heading on the Installed tab for extensions that are turned off.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get addons_sectionDisabled;

  /// Section heading on the Installed tab for extensions that cannot run in this app.
  ///
  /// In en, this message translates to:
  /// **'Unsupported'**
  String get addons_sectionUnsupported;

  /// Section heading on the extension details screen for author, version and links.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get addons_sectionDetails;

  /// Section heading on the extension details screen for the extension's description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get addons_sectionDescription;

  /// Section heading on the extension details screen for its switches (enabled, private browsing, updates).
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get addons_sectionManagement;

  /// Section heading on the extension details screen for update status.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get addons_sectionUpdates;

  /// Section heading on a store listing above the full description.
  ///
  /// In en, this message translates to:
  /// **'About this extension'**
  String get addons_sectionAboutExtension;

  /// Section heading on a store listing for permissions that have no plain-language description (raw technical names).
  ///
  /// In en, this message translates to:
  /// **'Technical permissions'**
  String get addons_sectionTechnicalPermissions;

  /// Section heading on a store listing for version, license and links.
  ///
  /// In en, this message translates to:
  /// **'More information'**
  String get addons_sectionMoreInformation;

  /// Heading on the permissions screen for data the extension says it must collect.
  ///
  /// In en, this message translates to:
  /// **'Required Data Collection'**
  String get addons_requiredDataCollectionTitle;

  /// Tooltip of the remove button on an extension card.
  ///
  /// In en, this message translates to:
  /// **'Remove extension'**
  String get addons_tooltipRemoveExtension;

  /// Confirmation after uninstalling an extension. name is the extension's name.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String addons_extensionRemoved(String name);

  /// Confirmation after installing an extension. name is the extension's name.
  ///
  /// In en, this message translates to:
  /// **'{name} installed'**
  String addons_extensionInstalled(String name);

  /// Error message when installing an extension failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Install failed: {error}'**
  String addons_installFailed(String error);

  /// Confirmation after starting background update checks for all extensions.
  ///
  /// In en, this message translates to:
  /// **'Background update checks started for installed extensions'**
  String get addons_updateChecksStarted;

  /// Status chip or disabled button label: the extension is installed and enabled.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get addons_statusInstalled;

  /// Status chip: the extension is installed but turned off.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get addons_statusDisabled;

  /// Status chip: the extension is not installed and can be installed.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get addons_statusAvailable;

  /// Chip on an extension card: it is allowed to run in private tabs.
  ///
  /// In en, this message translates to:
  /// **'Private Browsing'**
  String get addons_chipPrivateBrowsing;

  /// Chip on a store listing: Mozilla recommends this extension.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get addons_chipRecommended;

  /// Title of the confirmation dialog before uninstalling an extension.
  ///
  /// In en, this message translates to:
  /// **'Remove extension?'**
  String get addons_removeConfirmTitle;

  /// Body of that dialog. name is the extension's name; WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from WebLibre?'**
  String addons_removeConfirmContent(String name);

  /// Line under the automatic updates switch when automatic extension updates are turned off app-wide.
  ///
  /// In en, this message translates to:
  /// **'Global automatic updates are disabled.'**
  String get addons_autoUpdateGloballyDisabled;

  /// Line under the automatic updates switch for an extension installed from a file: it must be updated manually once, then the app restarted.
  ///
  /// In en, this message translates to:
  /// **'Run a manual update once and restart the app before automatic updates can be enabled.'**
  String get addons_autoUpdateNeedsManualRun;

  /// Line under the automatic updates switch while it is on.
  ///
  /// In en, this message translates to:
  /// **'Allow this extension to receive background updates.'**
  String get addons_autoUpdateAllow;

  /// Line under the automatic updates switch while it is off.
  ///
  /// In en, this message translates to:
  /// **'Background updates are disabled for this extension.'**
  String get addons_autoUpdateDisabledForExtension;

  /// Switch on the extension details screen that turns the extension on or off.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get addons_switchEnabledTitle;

  /// Line under the enabled switch.
  ///
  /// In en, this message translates to:
  /// **'Allow this extension to run in WebLibre.'**
  String get addons_switchEnabledSubtitleAllow;

  /// Line under the enabled switch when it cannot be turned on for safety reasons.
  ///
  /// In en, this message translates to:
  /// **'This extension cannot be safely enabled.'**
  String get addons_switchEnabledSubtitleCannot;

  /// Switch: allow the extension to run in private tabs.
  ///
  /// In en, this message translates to:
  /// **'Allow in Private Browsing'**
  String get addons_switchPrivateBrowsingTitle;

  /// Line under that switch.
  ///
  /// In en, this message translates to:
  /// **'Let this extension run in private browsing tabs.'**
  String get addons_switchPrivateBrowsingSubtitle;

  /// Switch: let this extension update itself in the background.
  ///
  /// In en, this message translates to:
  /// **'Automatic updates'**
  String get addons_switchAutoUpdateTitle;

  /// Switch: show the extension's button in the browser toolbar.
  ///
  /// In en, this message translates to:
  /// **'Pin to toolbar'**
  String get addons_switchPinTitle;

  /// Line under the pin switch.
  ///
  /// In en, this message translates to:
  /// **'Show this extension as an icon in the main tab bar.'**
  String get addons_switchPinSubtitle;

  /// Row that opens the extension's own settings page.
  ///
  /// In en, this message translates to:
  /// **'Extension Settings'**
  String get addons_menuExtensionSettingsTitle;

  /// Line under "Extension Settings" when the settings page opens in a browser tab.
  ///
  /// In en, this message translates to:
  /// **'Open the extension options page in a browser tab'**
  String get addons_menuExtensionSettingsSubtitleTab;

  /// Line under "Extension Settings" when the settings page opens inside this screen.
  ///
  /// In en, this message translates to:
  /// **'Open the extension options page'**
  String get addons_menuExtensionSettingsSubtitleInline;

  /// Row shown only for the uBlock Origin extension: manage its filter lists and WebLibre's extra hardening lists.
  ///
  /// In en, this message translates to:
  /// **'Filter Lists & Hardenings'**
  String get addons_menuFilterListsTitle;

  /// Line under "Filter Lists & Hardenings".
  ///
  /// In en, this message translates to:
  /// **'Manage filter lists and apply WebLibre hardenings'**
  String get addons_menuFilterListsSubtitle;

  /// Heading of the list of permissions, and row opening that list, on the extension screens.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get addons_permissionsTitle;

  /// Line on the extension details screen. from is the installed version; to is the new version. Keep the arrow.
  ///
  /// In en, this message translates to:
  /// **'Update available: {from} → {to}'**
  String addons_updateAvailable(String from, String to);

  /// Line on the extension details screen when no update check has been recorded.
  ///
  /// In en, this message translates to:
  /// **'No recent update attempt information is available yet.'**
  String get addons_noUpdateAttemptYet;

  /// Line on the extension details screen. date is when updates were last checked.
  ///
  /// In en, this message translates to:
  /// **'Last checked: {date}'**
  String addons_lastChecked(String date);

  /// Result of an update check: the extension is up to date.
  ///
  /// In en, this message translates to:
  /// **'No update available'**
  String get addons_noUpdateAvailable;

  /// Error message when checking for updates of an extension installed from a file, which has no online source.
  ///
  /// In en, this message translates to:
  /// **'This locally installed extension has no remote update source.'**
  String get addons_noRemoteUpdateSource;

  /// Error message when an update check could not be started.
  ///
  /// In en, this message translates to:
  /// **'Failed to start update check.'**
  String get addons_updateCheckFailed;

  /// Title of the dialog offering to install an extension update.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get addons_updateAvailableDialogTitle;

  /// Body of that dialog. name is the extension's name; from and to are the old and new version numbers.
  ///
  /// In en, this message translates to:
  /// **'Update {name} from {from} to {to}?'**
  String addons_updateConfirmContent(String name, String from, String to);

  /// Shown when the extension has no description.
  ///
  /// In en, this message translates to:
  /// **'No description provided.'**
  String get addons_noDescriptionProvided;

  /// Placeholder while the extension description loads.
  ///
  /// In en, this message translates to:
  /// **'Loading description…'**
  String get addons_loadingDescription;

  /// Label of the row showing the extension's author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get addons_fieldAuthor;

  /// Label of the row showing the extension's version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get addons_fieldVersion;

  /// Label of the row showing when the installed extension was last updated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get addons_fieldLastUpdated;

  /// Label of the row on a store listing showing when the extension was last updated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get addons_fieldLastUpdatedInfo;

  /// Label of the link to the extension's website.
  ///
  /// In en, this message translates to:
  /// **'Homepage'**
  String get addons_fieldHomepage;

  /// Label of the link to the extension's page in the add-on store.
  ///
  /// In en, this message translates to:
  /// **'Addon Listing'**
  String get addons_fieldAddonListing;

  /// Label of the row showing the extension's download size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get addons_fieldSize;

  /// Label of the row showing the extension's store categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get addons_fieldCategories;

  /// Label of the row showing the extension's software license.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get addons_fieldLicense;

  /// Label of the link to the extension's support website.
  ///
  /// In en, this message translates to:
  /// **'Support site'**
  String get addons_fieldSupportSite;

  /// Label of the link to user reviews of the extension.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get addons_fieldReviews;

  /// Label of the link to the extension's privacy policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get addons_fieldPrivacyPolicy;

  /// Link that opens the listing on Mozilla's add-on website. addons.mozilla.org is a web address; keep it unchanged.
  ///
  /// In en, this message translates to:
  /// **'View on addons.mozilla.org'**
  String get addons_linkViewOnAmo;

  /// Title of the screen showing an extension's own settings page, when the name is unknown.
  ///
  /// In en, this message translates to:
  /// **'Extension Settings'**
  String get addons_settingsTitleGeneric;

  /// Title of the screen showing an extension's own settings page. name is the extension's name.
  ///
  /// In en, this message translates to:
  /// **'{name} Settings'**
  String addons_settingsTitleNamed(String name);

  /// Error message when the extension's settings page could not be loaded. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to load extension settings: {error}'**
  String addons_settingsLoadFailed(String error);

  /// Shown when the extension has no settings page.
  ///
  /// In en, this message translates to:
  /// **'This extension does not expose a settings page.'**
  String get addons_noSettingsPage;

  /// Title of the extension permissions screen when the name is unknown.
  ///
  /// In en, this message translates to:
  /// **'Extension Permissions'**
  String get addons_permissionsTitleGeneric;

  /// Title of the extension permissions screen. name is the extension's name.
  ///
  /// In en, this message translates to:
  /// **'{name} Permissions'**
  String addons_permissionsTitleNamed(String name);

  /// Error message when the permissions could not be loaded. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to load extension permissions: {error}'**
  String addons_permissionsLoadFailed(String error);

  /// Shown when the extension requests no permissions that need explaining.
  ///
  /// In en, this message translates to:
  /// **'No special permissions listed'**
  String get addons_noSpecialPermissions;

  /// Line under "No special permissions listed".
  ///
  /// In en, this message translates to:
  /// **'This extension does not currently expose any translated permission details.'**
  String get addons_noTranslatedPermissionDetails;

  /// Line on a store listing. version is the latest version number.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String addons_versionSentence(String version);

  /// Chip on a store listing. count is the average number of daily users, shown in compact form (e.g. 1.2K).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 user} other{{count} users}}'**
  String addons_usersCount(int count);

  /// Author line on a store listing. name is the author's name.
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String addons_byAuthor(String name);

  /// Heading of the permissions the extension needs in order to work.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get addons_permGroupRequired;

  /// Heading of the list of websites whose data the extension can access.
  ///
  /// In en, this message translates to:
  /// **'Websites'**
  String get addons_permGroupWebsites;

  /// Heading of the permissions the extension may ask for later.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get addons_permGroupOptional;

  /// Heading of the kinds of data the extension says it collects.
  ///
  /// In en, this message translates to:
  /// **'Data collection'**
  String get addons_permGroupDataCollection;

  /// Shown in place of a date that is unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get addons_dateUnknown;

  /// Result of the last update check: the extension was updated.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully'**
  String get addons_statusUpdatedSuccessfully;

  /// Result of the last update check: the extension is no longer installed.
  ///
  /// In en, this message translates to:
  /// **'Extension not installed'**
  String get addons_statusNotInstalled;

  /// Result of the last update check when it failed. message is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {message}'**
  String addons_updateFailedWithMessage(String message);

  /// Result of the last update check when it failed without details.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get addons_updateFailedGeneric;

  /// Shown when no update check has been recorded for the extension.
  ///
  /// In en, this message translates to:
  /// **'No update checks recorded yet'**
  String get addons_noUpdateChecksRecorded;

  /// Warning on an extension that Mozilla has blocked for security or policy reasons.
  ///
  /// In en, this message translates to:
  /// **'This extension has been blocklisted and should remain disabled.'**
  String get addons_statusBlocklisted;

  /// Warning on an extension whose Mozilla signature is missing or invalid.
  ///
  /// In en, this message translates to:
  /// **'This extension is not correctly signed and cannot be safely enabled.'**
  String get addons_statusNotCorrectlySigned;

  /// Warning on an extension that does not work with this app version.
  ///
  /// In en, this message translates to:
  /// **'This extension is incompatible with the current app version.'**
  String get addons_statusIncompatible;

  /// Warning on an enabled extension that Mozilla marked as risky ("soft-blocked") but still allows.
  ///
  /// In en, this message translates to:
  /// **'This extension is soft-blocked. Use caution while it remains enabled.'**
  String get addons_statusSoftBlockedEnabled;

  /// Warning on a disabled extension that Mozilla marked as risky ("soft-blocked"); it can still be turned on.
  ///
  /// In en, this message translates to:
  /// **'This extension is soft-blocked, but it can still be re-enabled.'**
  String get addons_statusSoftBlockedDisabled;

  /// Warning on an installed extension this app cannot run. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'This extension is installed, but WebLibre does not currently support it.'**
  String get addons_statusUnsupported;

  /// Plain-language description of the "bookmarks" extension permission, shown in permission lists. Mirrors Firefox's wording; reuse its translation if available.
  ///
  /// In en, this message translates to:
  /// **'Read and modify bookmarks'**
  String get addons_permissionBookmarks;

  /// Plain-language description of the "browserSettings" extension permission, shown in permission lists. Mirrors Firefox's wording.
  ///
  /// In en, this message translates to:
  /// **'Read and modify browser settings'**
  String get addons_permissionBrowserSettings;

  /// Plain-language description of the "browsingData" extension permission, shown in permission lists. Mirrors Firefox's wording.
  ///
  /// In en, this message translates to:
  /// **'Clear recent browsing history, cookies, and related data'**
  String get addons_permissionBrowsingData;

  /// Plain-language description of the "clipboardRead" extension permission, shown in permission lists. Mirrors Firefox's wording.
  ///
  /// In en, this message translates to:
  /// **'Read data you copy and paste'**
  String get addons_permissionClipboardRead;

  /// Plain-language description of the "clipboardWrite" extension permission (writing to the clipboard), shown in permission lists. Mirrors Firefox's wording.
  ///
  /// In en, this message translates to:
  /// **'Input data to the clipboard'**
  String get addons_permissionClipboardWrite;

  /// Plain-language description of the "contextualIdentities" extension permission (containers), shown in permission lists. Mirrors Firefox's wording.
  ///
  /// In en, this message translates to:
  /// **'Access and modify container tabs'**
  String get addons_permissionContextualIdentities;

  /// Plain-language description of the "cookies" extension permission, shown in permission lists. Mirrors Firefox's wording.
  ///
  /// In en, this message translates to:
  /// **'Access cookies for visited sites'**
  String get addons_permissionCookies;

  /// Plain-language description of the "downloads" extension permission, shown in permission lists. Mirrors Firefox's wording.
  ///
  /// In en, this message translates to:
  /// **'Download files and read/modify download history'**
  String get addons_permissionDownloads;

  /// Plain-language description of the "downloads.open" extension permission, shown in permission lists. Mirrors Firefox's wording ("computer" comes from Firefox).
  ///
  /// In en, this message translates to:
  /// **'Open files downloaded to your computer'**
  String get addons_permissionDownloadsOpen;

  /// Plain-language description of the "find" extension permission, shown in permission lists. Mirrors Firefox's wording.
  ///
  /// In en, this message translates to:
  /// **'Read the text of all open tabs'**
  String get addons_permissionFind;

  /// Plain-language description of the "geolocation" extension permission, shown in permission lists. Mirrors Firefox's wording.
  ///
  /// In en, this message translates to:
  /// **'Access your location'**
  String get addons_permissionGeolocation;

  /// Plain-language description of the "history" extension permission, shown in permission lists. Mirrors Firefox's wording.
  ///
  /// In en, this message translates to:
  /// **'Access browsing history'**
  String get addons_permissionHistory;

  /// Plain-language description of the "management" extension permission, shown in permission lists. Mirrors Firefox's wording.
  ///
  /// In en, this message translates to:
  /// **'Monitor extension usage and manage themes'**
  String get addons_permissionManagement;

  /// Plain-language description of the "nativeMessaging" extension permission, shown in permission lists. Mirrors Firefox's wording.
  ///
  /// In en, this message translates to:
  /// **'Exchange messages with programs other than the browser'**
  String get addons_permissionNativeMessaging;

  /// Plain-language description of the "notifications" extension permission, shown in permission lists. Mirrors Firefox's wording.
  ///
  /// In en, this message translates to:
  /// **'Display notifications'**
  String get addons_permissionNotifications;

  /// Plain-language description of the "pkcs11" extension permission (security devices), shown in permission lists. Mirrors Firefox's wording.
  ///
  /// In en, this message translates to:
  /// **'Provide cryptographic authentication services'**
  String get addons_permissionPkcs11;

  /// Plain-language description of the "privacy" extension permission, shown in permission lists. Mirrors Firefox's wording.
  ///
  /// In en, this message translates to:
  /// **'Read and modify privacy settings'**
  String get addons_permissionPrivacy;

  /// Plain-language description of the "proxy" extension permission, shown in permission lists. Mirrors Firefox's wording.
  ///
  /// In en, this message translates to:
  /// **'Control browser proxy settings'**
  String get addons_permissionProxy;

  /// Plain-language description of the "sessions" extension permission, shown in permission lists. Mirrors Firefox's wording.
  ///
  /// In en, this message translates to:
  /// **'Access recently closed tabs'**
  String get addons_permissionSessions;

  /// Plain-language description of the "tabs" extension permission, shown in permission lists. Mirrors Firefox's wording.
  ///
  /// In en, this message translates to:
  /// **'Access browser tabs'**
  String get addons_permissionTabs;

  /// Plain-language description of the "tabHide" extension permission, shown in permission lists. Mirrors Firefox's wording.
  ///
  /// In en, this message translates to:
  /// **'Hide and show browser tabs'**
  String get addons_permissionTabHide;

  /// Plain-language description of the "topSites" extension permission, shown in permission lists. Same wording as the history permission, as in Firefox.
  ///
  /// In en, this message translates to:
  /// **'Access browsing history'**
  String get addons_permissionTopSites;

  /// Plain-language description of the "webNavigation" extension permission, shown in permission lists. Mirrors Firefox's wording.
  ///
  /// In en, this message translates to:
  /// **'Access browser activity during navigation'**
  String get addons_permissionWebNavigation;

  /// Plain-language description of the permission to access every website, shown in permission lists. Mirrors Firefox's wording.
  ///
  /// In en, this message translates to:
  /// **'Access your data for all websites'**
  String get addons_permissionAllUrls;

  /// Plain-language description of a permission to access specific websites. host is a website pattern such as "*://*.example.com/*".
  ///
  /// In en, this message translates to:
  /// **'Access your data for {host}'**
  String addons_permissionAccessDataFor(String host);

  /// Question in the banner shown when a tapped link can be opened by an installed app instead of the browser. appName is that app's name.
  ///
  /// In en, this message translates to:
  /// **'Open this link in {appName}?'**
  String appLinks_bannerTitleNamed(String appName);

  /// Question in the banner shown when a tapped link can be opened by an installed app instead of the browser, when the app's name is unknown.
  ///
  /// In en, this message translates to:
  /// **'Open this link in an app?'**
  String get appLinks_bannerTitleGeneric;

  /// Checkbox label in the open-in-app banner. scope is a website domain (e.g. example.com) or an Android app package name; the choice is remembered for it.
  ///
  /// In en, this message translates to:
  /// **'Remember for {scope}'**
  String appLinks_bannerRememberFor(String scope);

  /// Button in the open-in-app banner: keep the link in the browser.
  ///
  /// In en, this message translates to:
  /// **'Stay in browser'**
  String get appLinks_bannerStayInBrowser;

  /// Button in the open-in-app banner: open the link in the app.
  ///
  /// In en, this message translates to:
  /// **'Open app'**
  String get appLinks_bannerOpenApp;

  /// Title of the dialog asking whether to open a link in an installed app. appName is that app's name.
  ///
  /// In en, this message translates to:
  /// **'Open in {appName}?'**
  String appLinks_dialogTitleNamed(String appName);

  /// Title of the dialog asking whether to open a link in an installed app, when the app's name is unknown.
  ///
  /// In en, this message translates to:
  /// **'Open in another app?'**
  String get appLinks_dialogTitleGeneric;

  /// Body of the dialog asking whether to open a link in an installed app. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'This link is handled by an app outside WebLibre.'**
  String get appLinks_dialogBody;

  /// Checkbox label in the open-in-app dialog. scope is a website domain (e.g. example.com) or an Android app package name; the choice is remembered for it.
  ///
  /// In en, this message translates to:
  /// **'Remember my choice for {scope}'**
  String appLinks_dialogRememberFor(String scope);

  /// Warning in the open-in-app prompt when WebLibre applies extra protection to this link (for example its connection rules or privacy settings): the other app connects on its own and does not follow them.
  ///
  /// In en, this message translates to:
  /// **'This link is protected here. The app opens its own connection, outside the rules this tab follows.'**
  String get appLinks_warningProtectedContext;

  /// Warning in the open-in-app prompt when the link comes from a private tab: the other app keeps its own history and stays signed in.
  ///
  /// In en, this message translates to:
  /// **'This is a private tab. The app keeps its own history and sign-in state.'**
  String get appLinks_warningPrivateTab;

  /// Warning in the open-in-app prompt when the link would hand a request for identity credentials to a wallet app.
  ///
  /// In en, this message translates to:
  /// **'This link asks a wallet app for credentials. Open it only if you initiated the request.'**
  String get appLinks_warningWallet;

  /// Title of the per-container settings for opening links in apps. containerName is the container's name. "App Links" means links that installed apps can open.
  ///
  /// In en, this message translates to:
  /// **'App Links — {containerName}'**
  String appLinks_settingsTitleWithContainer(String containerName);

  /// Title of the per-container settings for opening links in apps, when the container has no name.
  ///
  /// In en, this message translates to:
  /// **'Container App Links'**
  String get appLinks_settingsTitleDefault;

  /// Explanation at the top of the per-container app link settings: these settings override the global ones for tabs in this container.
  ///
  /// In en, this message translates to:
  /// **'These settings apply only to this container and fully replace the global app-link settings for its tabs.'**
  String get appLinks_settingsIntro;

  /// Option in the app link settings: always open supported links in their apps.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get appLinks_modeAlwaysTitle;

  /// Explanation under the "Always" option for opening links in apps.
  ///
  /// In en, this message translates to:
  /// **'Always open links in their native apps without asking'**
  String get appLinks_modeAlwaysSubtitle;

  /// Option in the app link settings: ask each time before opening a link in an app.
  ///
  /// In en, this message translates to:
  /// **'Ask before opening'**
  String get appLinks_modeAskTitle;

  /// Explanation under the "Ask before opening" option for opening links in apps.
  ///
  /// In en, this message translates to:
  /// **'Show a prompt before opening links in apps'**
  String get appLinks_modeAskSubtitle;

  /// Option in the app link settings: never open links in apps.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get appLinks_modeNeverTitle;

  /// Explanation under the "Never" option for opening links in apps.
  ///
  /// In en, this message translates to:
  /// **'Always open links in the browser instead of apps'**
  String get appLinks_modeNeverSubtitle;

  /// Section heading above the list of sites and apps for which an open-in-app choice was remembered.
  ///
  /// In en, this message translates to:
  /// **'Remembered site rules'**
  String get appLinks_rememberedRulesHeader;

  /// Line under a remembered site or app: its links always open in the app.
  ///
  /// In en, this message translates to:
  /// **'Always open in the app'**
  String get appLinks_ruleAlwaysOpenSubtitle;

  /// Line under a remembered site or app: its links always stay in the browser.
  ///
  /// In en, this message translates to:
  /// **'Always keep in the browser'**
  String get appLinks_ruleAlwaysKeepSubtitle;

  /// Tooltip of the button that deletes a remembered open-in-app choice.
  ///
  /// In en, this message translates to:
  /// **'Remove rule'**
  String get appLinks_removeRuleTooltip;

  /// Title of the bangs screen. A "bang" is a shortcut such as "!w" typed before a search to search a specific website directly (a DuckDuckGo convention); keep the term unless your language has an established equivalent.
  ///
  /// In en, this message translates to:
  /// **'Bangs'**
  String get bangs_menuTitle;

  /// Row on the bangs screen that opens the list of bangs the user created or customized.
  ///
  /// In en, this message translates to:
  /// **'Manage User Bangs'**
  String get bangs_menuManageUserBangs;

  /// Row on the bangs screen that opens a search across all available bangs.
  ///
  /// In en, this message translates to:
  /// **'Search Bangs'**
  String get bangs_menuSearchBangs;

  /// Row on the bangs screen that opens the list of bang categories (e.g. News, Shopping).
  ///
  /// In en, this message translates to:
  /// **'Browse Categories'**
  String get bangs_menuBrowseCategories;

  /// Title of the screen listing the categories bangs are grouped in.
  ///
  /// In en, this message translates to:
  /// **'Bang Categories'**
  String get bangs_categoriesTitle;

  /// Error heading when the list of bang categories could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Failed to load Bang Categories'**
  String get bangs_loadCategoriesFailedTitle;

  /// Error heading when a list of bangs could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Failed to load Bangs'**
  String get bangs_loadBangsFailedTitle;

  /// Placeholder of the search field on the bang search screen.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get bangs_searchHint;

  /// Error heading when searching the list of bangs failed.
  ///
  /// In en, this message translates to:
  /// **'Bang Search failed'**
  String get bangs_searchFailedTitle;

  /// Title of the screen listing bangs the user created or customized.
  ///
  /// In en, this message translates to:
  /// **'User Bangs'**
  String get bangs_userBangsTitle;

  /// Title of the confirmation dialog before deleting a user-created bang.
  ///
  /// In en, this message translates to:
  /// **'Delete Bang'**
  String get bangs_deleteBangTitle;

  /// Body of the confirmation dialog before deleting a user-created bang.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this Bang?'**
  String get bangs_deleteBangConfirm;

  /// Title of the bang editor when making an editable personal copy of a built-in bang.
  ///
  /// In en, this message translates to:
  /// **'Customize Bang'**
  String get bangs_editTitleCustomize;

  /// Title of the bang editor when creating a new bang.
  ///
  /// In en, this message translates to:
  /// **'New Bang'**
  String get bangs_editTitleNew;

  /// Title of the bang editor when changing an existing user bang.
  ///
  /// In en, this message translates to:
  /// **'Edit Bang'**
  String get bangs_editTitleEdit;

  /// Error message when saving a bang whose trigger word is already used by another bang. trigger is that word, without the "!".
  ///
  /// In en, this message translates to:
  /// **'A bang with the trigger \"{trigger}\" already exists'**
  String bangs_triggerAlreadyExists(String trigger);

  /// Label of the field for the bang's display name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get bangs_fieldNameLabel;

  /// Help text under the bang name field.
  ///
  /// In en, this message translates to:
  /// **'The name of the website associated with the bang'**
  String get bangs_fieldNameHelper;

  /// Label of the field for the bang's trigger: the word typed after "!" to use the bang (e.g. "w" for Wikipedia).
  ///
  /// In en, this message translates to:
  /// **'Trigger'**
  String get bangs_fieldTriggerLabel;

  /// Help text under the bang trigger field.
  ///
  /// In en, this message translates to:
  /// **'The specific trigger word or phrase used to invoke the bang.'**
  String get bangs_fieldTriggerHelper;

  /// Label of the field for extra trigger words that also invoke the same bang.
  ///
  /// In en, this message translates to:
  /// **'Additional triggers'**
  String get bangs_fieldAdditionalTriggersLabel;

  /// Help text under the additional triggers field. Keep the "!" character.
  ///
  /// In en, this message translates to:
  /// **'Other words that invoke this bang, separated by commas or spaces. A leading ! is optional.'**
  String get bangs_fieldAdditionalTriggersHelper;

  /// Label of the field for the bang's search address template.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get bangs_fieldUrlLabel;

  /// Help text under the bang URL field. token is the literal marker {{{s}}} that must appear in the address and is replaced by the search terms. Keep the backticks around it.
  ///
  /// In en, this message translates to:
  /// **'The URL template to use when the bang is invoked, where `{token}` is replaced by the user\'s query.'**
  String bangs_fieldUrlHelper(String token);

  /// Validation error under the bang URL field when the address lacks the search-terms marker. token is the literal marker {{{s}}}.
  ///
  /// In en, this message translates to:
  /// **'Must contain the query placeholder {token}'**
  String bangs_fieldUrlMissingPlaceholder(String token);

  /// Label of the drop-down for the bang's category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get bangs_fieldCategoryLabel;

  /// Label of the drop-down for the bang's subcategory within its category.
  ///
  /// In en, this message translates to:
  /// **'Subcategory'**
  String get bangs_fieldSubCategoryLabel;

  /// Heading above the checkboxes for technical options of a bang.
  ///
  /// In en, this message translates to:
  /// **'Flags'**
  String get bangs_flagsLabel;

  /// Checkbox in the bang editor for how a bang used without search terms behaves. "Base path" is the root of the website's address.
  ///
  /// In en, this message translates to:
  /// **'Open Base Path'**
  String get bangs_flagOpenBasePathTitle;

  /// Explanation under "Open Base Path": when the bang is used with no search terms, open the site's root address instead of the path in the template. "/" and "/search" are literal address parts.
  ///
  /// In en, this message translates to:
  /// **'When a bang is invoked with no query, it opens the base path of the URL (/) instead of the path in the template (e.g., /search)'**
  String get bangs_flagOpenBasePathSubtitle;

  /// Checkbox in the bang editor: encode the search terms for safe use in a web address (percent-encoding).
  ///
  /// In en, this message translates to:
  /// **'URL Encode Placeholder'**
  String get bangs_flagUrlEncodePlaceholderTitle;

  /// Explanation under "URL Encode Placeholder": some sites break when search terms are encoded, so this can be turned off.
  ///
  /// In en, this message translates to:
  /// **'URL-encode the search terms. Some sites do not work with encoded terms, so disable this option for those sites.'**
  String get bangs_flagUrlEncodePlaceholderSubtitle;

  /// Checkbox in the bang editor: encode spaces in the search terms as "+".
  ///
  /// In en, this message translates to:
  /// **'URL Encode Space to Plus'**
  String get bangs_flagUrlEncodeSpaceToPlusTitle;

  /// Explanation under "URL Encode Space to Plus". "+" and "%20" are literal characters and must stay unchanged.
  ///
  /// In en, this message translates to:
  /// **'Encode spaces as + instead of %20. Some sites require one format or the other.'**
  String get bangs_flagUrlEncodeSpaceToPlusSubtitle;

  /// Tooltip of the crown icon marking a bang provided by WebLibre itself.
  ///
  /// In en, this message translates to:
  /// **'Official WebLibre search'**
  String get bangs_tooltipOfficialSearch;

  /// Tooltip of the button that makes an editable personal copy of a built-in bang.
  ///
  /// In en, this message translates to:
  /// **'Customize as your own bang'**
  String get bangs_tooltipCustomizeAsOwn;

  /// Tooltip of the pin button when the bang is pinned: removes it from the quick list of search providers.
  ///
  /// In en, this message translates to:
  /// **'Unpin from search providers'**
  String get bangs_tooltipUnpin;

  /// Tooltip of the pin button when the bang is not pinned: adds it to the quick list of search providers.
  ///
  /// In en, this message translates to:
  /// **'Pin to search providers'**
  String get bangs_tooltipPin;

  /// Tooltip listing all words that invoke a bang. triggers is a comma-separated list such as "w, !wiki".
  ///
  /// In en, this message translates to:
  /// **'Triggers: {triggers}'**
  String bangs_tooltipTriggers(String triggers);

  /// Heading of a group of browser actions (moving between pages) in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get browserActions_categoryNavigation;

  /// Heading of a group of browser actions (scrolling the page) in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions.
  ///
  /// In en, this message translates to:
  /// **'Scrolling'**
  String get browserActions_categoryScrolling;

  /// Heading of a group of browser actions (opening, closing and switching tabs) in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions.
  ///
  /// In en, this message translates to:
  /// **'Tabs'**
  String get browserActions_categoryTabs;

  /// Heading of a group of browser actions (actions on the current page) in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get browserActions_categoryPage;

  /// Heading of a group of browser actions (opening screens such as history or settings) in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get browserActions_categoryOpen;

  /// Heading of a group of browser actions (app-level actions such as quitting) in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get browserActions_categoryApp;

  /// Name of the browser action that puts the cursor in the address field to type a web address or search, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Address Bar'**
  String get browserActions_focusAddressBarTitle;

  /// Explanation under that browser action's name in the action lists: it puts the cursor in the address field to type a web address or search.
  ///
  /// In en, this message translates to:
  /// **'Edit the address or start a search'**
  String get browserActions_focusAddressBarDescription;

  /// Name of the browser action that goes to the previous page in the tab, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get browserActions_backTitle;

  /// Explanation under that browser action's name in the action lists: it goes to the previous page in the tab.
  ///
  /// In en, this message translates to:
  /// **'Go back in history'**
  String get browserActions_backDescription;

  /// Name of the browser action that goes to the next page in the tab, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get browserActions_forwardTitle;

  /// Explanation under that browser action's name in the action lists: it goes to the next page in the tab.
  ///
  /// In en, this message translates to:
  /// **'Go forward in history'**
  String get browserActions_forwardDescription;

  /// Name of the browser action that reloads the page, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get browserActions_reloadTitle;

  /// Explanation under that browser action's name in the action lists: it reloads the page.
  ///
  /// In en, this message translates to:
  /// **'Reload the current page'**
  String get browserActions_reloadDescription;

  /// Name of the browser action that reloads the page ignoring cached copies, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Hard Reload'**
  String get browserActions_hardReloadTitle;

  /// Explanation under that browser action's name in the action lists: it reloads the page ignoring cached copies.
  ///
  /// In en, this message translates to:
  /// **'Reload the current page, bypassing the cache'**
  String get browserActions_hardReloadDescription;

  /// Name of the browser action that scrolls to the top of the page, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Scroll to Top'**
  String get browserActions_scrollTopTitle;

  /// Explanation under that browser action's name in the action lists: it scrolls to the top of the page.
  ///
  /// In en, this message translates to:
  /// **'Jump to the top of the page'**
  String get browserActions_scrollTopDescription;

  /// Name of the browser action that scrolls to the bottom of the page, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Scroll to Bottom'**
  String get browserActions_scrollBottomTitle;

  /// Explanation under that browser action's name in the action lists: it scrolls to the bottom of the page.
  ///
  /// In en, this message translates to:
  /// **'Jump to the bottom of the page'**
  String get browserActions_scrollBottomDescription;

  /// Name of the browser action that scrolls up by one screen height, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Page Up'**
  String get browserActions_pageUpTitle;

  /// Explanation under that browser action's name in the action lists: it scrolls up by one screen height.
  ///
  /// In en, this message translates to:
  /// **'Scroll up by one screen'**
  String get browserActions_pageUpDescription;

  /// Name of the browser action that scrolls down by one screen height, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Page Down'**
  String get browserActions_pageDownTitle;

  /// Explanation under that browser action's name in the action lists: it scrolls down by one screen height.
  ///
  /// In en, this message translates to:
  /// **'Scroll down by one screen'**
  String get browserActions_pageDownDescription;

  /// Name of the browser action that opens a new tab, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'New Tab'**
  String get browserActions_newTabTitle;

  /// Explanation under that browser action's name in the action lists: it opens a new tab.
  ///
  /// In en, this message translates to:
  /// **'Open a new tab'**
  String get browserActions_newTabDescription;

  /// Name of the browser action that opens a new private tab, which keeps no history, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'New Private Tab'**
  String get browserActions_newPrivateTabTitle;

  /// Explanation under that browser action's name in the action lists: it opens a new private tab, which keeps no history.
  ///
  /// In en, this message translates to:
  /// **'Open a new private tab'**
  String get browserActions_newPrivateTabDescription;

  /// Name of the browser action that closes the current tab, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Close Tab'**
  String get browserActions_closeTabTitle;

  /// Explanation under that browser action's name in the action lists: it closes the current tab.
  ///
  /// In en, this message translates to:
  /// **'Close the current tab'**
  String get browserActions_closeTabDescription;

  /// Name of the browser action that reopens the most recently closed tab, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Reopen Closed Tab'**
  String get browserActions_reopenClosedTabTitle;

  /// Explanation under that browser action's name in the action lists: it reopens the most recently closed tab.
  ///
  /// In en, this message translates to:
  /// **'Bring back the most recently closed tab'**
  String get browserActions_reopenClosedTabDescription;

  /// Name of the browser action that copies the current tab into a new tab, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Tab'**
  String get browserActions_duplicateTabTitle;

  /// Explanation under that browser action's name in the action lists: it copies the current tab into a new tab.
  ///
  /// In en, this message translates to:
  /// **'Open a copy of the current tab'**
  String get browserActions_duplicateTabDescription;

  /// Name of the browser action that switches to the next tab, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Next Tab'**
  String get browserActions_nextTabTitle;

  /// Explanation under that browser action's name in the action lists: it switches to the next tab.
  ///
  /// In en, this message translates to:
  /// **'Switch to the next tab'**
  String get browserActions_nextTabDescription;

  /// Name of the browser action that switches to the previous tab, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Previous Tab'**
  String get browserActions_previousTabTitle;

  /// Explanation under that browser action's name in the action lists: it switches to the previous tab.
  ///
  /// In en, this message translates to:
  /// **'Switch to the previous tab'**
  String get browserActions_previousTabDescription;

  /// Name of the browser action that switches back to the tab used before the current one, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Last Used Tab'**
  String get browserActions_lastUsedTabTitle;

  /// Explanation under that browser action's name in the action lists: it switches back to the tab used before the current one.
  ///
  /// In en, this message translates to:
  /// **'Switch to the previously used tab'**
  String get browserActions_lastUsedTabDescription;

  /// Name of the browser action that switches to the first tab in the tab bar, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. "Tab 1" to "Tab 8" are numbered positions; keep the number. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Tab 1'**
  String get browserActions_selectTab1Title;

  /// Explanation under that browser action's name in the action lists: it switches to the first tab in the tab bar.
  ///
  /// In en, this message translates to:
  /// **'Switch to the first tab in the tab bar'**
  String get browserActions_selectTab1Description;

  /// Name of the browser action that switches to the second tab in the tab bar, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. "Tab 1" to "Tab 8" are numbered positions; keep the number. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Tab 2'**
  String get browserActions_selectTab2Title;

  /// Explanation under that browser action's name in the action lists: it switches to the second tab in the tab bar.
  ///
  /// In en, this message translates to:
  /// **'Switch to the second tab in the tab bar'**
  String get browserActions_selectTab2Description;

  /// Name of the browser action that switches to the third tab in the tab bar, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. "Tab 1" to "Tab 8" are numbered positions; keep the number. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Tab 3'**
  String get browserActions_selectTab3Title;

  /// Explanation under that browser action's name in the action lists: it switches to the third tab in the tab bar.
  ///
  /// In en, this message translates to:
  /// **'Switch to the third tab in the tab bar'**
  String get browserActions_selectTab3Description;

  /// Name of the browser action that switches to the fourth tab in the tab bar, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. "Tab 1" to "Tab 8" are numbered positions; keep the number. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Tab 4'**
  String get browserActions_selectTab4Title;

  /// Explanation under that browser action's name in the action lists: it switches to the fourth tab in the tab bar.
  ///
  /// In en, this message translates to:
  /// **'Switch to the fourth tab in the tab bar'**
  String get browserActions_selectTab4Description;

  /// Name of the browser action that switches to the fifth tab in the tab bar, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. "Tab 1" to "Tab 8" are numbered positions; keep the number. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Tab 5'**
  String get browserActions_selectTab5Title;

  /// Explanation under that browser action's name in the action lists: it switches to the fifth tab in the tab bar.
  ///
  /// In en, this message translates to:
  /// **'Switch to the fifth tab in the tab bar'**
  String get browserActions_selectTab5Description;

  /// Name of the browser action that switches to the sixth tab in the tab bar, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. "Tab 1" to "Tab 8" are numbered positions; keep the number. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Tab 6'**
  String get browserActions_selectTab6Title;

  /// Explanation under that browser action's name in the action lists: it switches to the sixth tab in the tab bar.
  ///
  /// In en, this message translates to:
  /// **'Switch to the sixth tab in the tab bar'**
  String get browserActions_selectTab6Description;

  /// Name of the browser action that switches to the seventh tab in the tab bar, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. "Tab 1" to "Tab 8" are numbered positions; keep the number. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Tab 7'**
  String get browserActions_selectTab7Title;

  /// Explanation under that browser action's name in the action lists: it switches to the seventh tab in the tab bar.
  ///
  /// In en, this message translates to:
  /// **'Switch to the seventh tab in the tab bar'**
  String get browserActions_selectTab7Description;

  /// Name of the browser action that switches to the eighth tab in the tab bar, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. "Tab 1" to "Tab 8" are numbered positions; keep the number. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Tab 8'**
  String get browserActions_selectTab8Title;

  /// Explanation under that browser action's name in the action lists: it switches to the eighth tab in the tab bar.
  ///
  /// In en, this message translates to:
  /// **'Switch to the eighth tab in the tab bar'**
  String get browserActions_selectTab8Description;

  /// Name of the browser action that switches to the last tab in the tab bar, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Last Tab'**
  String get browserActions_selectLastTabTitle;

  /// Explanation under that browser action's name in the action lists: it switches to the last tab in the tab bar.
  ///
  /// In en, this message translates to:
  /// **'Switch to the last tab in the tab bar'**
  String get browserActions_selectLastTabDescription;

  /// Name of the browser action that pins or unpins the current tab (pinned tabs stay at the start of the tab bar), shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Pin / Unpin Tab'**
  String get browserActions_togglePinTabTitle;

  /// Explanation under that browser action's name in the action lists: it pins or unpins the current tab (pinned tabs stay at the start of the tab bar).
  ///
  /// In en, this message translates to:
  /// **'Toggle the pinned state of the current tab'**
  String get browserActions_togglePinTabDescription;

  /// Name of the browser action that moves the current tab one place toward the start of the tab bar, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Move Tab Back'**
  String get browserActions_moveTabBackwardTitle;

  /// Explanation under that browser action's name in the action lists: it moves the current tab one place toward the start of the tab bar.
  ///
  /// In en, this message translates to:
  /// **'Move the current tab one place toward the start of the tab bar'**
  String get browserActions_moveTabBackwardDescription;

  /// Name of the browser action that moves the current tab one place toward the end of the tab bar, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Move Tab Forward'**
  String get browserActions_moveTabForwardTitle;

  /// Explanation under that browser action's name in the action lists: it moves the current tab one place toward the end of the tab bar.
  ///
  /// In en, this message translates to:
  /// **'Move the current tab one place toward the end of the tab bar'**
  String get browserActions_moveTabForwardDescription;

  /// Name of the browser action that moves the current tab to the start of its group, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Move Tab to Start'**
  String get browserActions_moveTabToStartTitle;

  /// Explanation under that browser action's name in the action lists: it moves the current tab to the start of its group.
  ///
  /// In en, this message translates to:
  /// **'Move the current tab to the start of its group in the tab bar'**
  String get browserActions_moveTabToStartDescription;

  /// Name of the browser action that moves the current tab to the end of its group, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Move Tab to End'**
  String get browserActions_moveTabToEndTitle;

  /// Explanation under that browser action's name in the action lists: it moves the current tab to the end of its group.
  ///
  /// In en, this message translates to:
  /// **'Move the current tab to the end of its group in the tab bar'**
  String get browserActions_moveTabToEndDescription;

  /// Name of the browser action that switches to the next container (a separate browsing identity with its own tabs), shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Next Container'**
  String get browserActions_nextContainerTitle;

  /// Explanation under that browser action's name in the action lists: it switches to the next container (a separate browsing identity with its own tabs).
  ///
  /// In en, this message translates to:
  /// **'Switch to the next container and its last used tab'**
  String get browserActions_nextContainerDescription;

  /// Name of the browser action that switches to the previous container (a separate browsing identity with its own tabs), shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Previous Container'**
  String get browserActions_previousContainerTitle;

  /// Explanation under that browser action's name in the action lists: it switches to the previous container (a separate browsing identity with its own tabs).
  ///
  /// In en, this message translates to:
  /// **'Switch to the previous container and its last used tab'**
  String get browserActions_previousContainerDescription;

  /// Name of the browser action that turns reader mode (simplified, easy-to-read text) on or off, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Reader Mode'**
  String get browserActions_toggleReaderModeTitle;

  /// Explanation under that browser action's name in the action lists: it turns reader mode (simplified, easy-to-read text) on or off.
  ///
  /// In en, this message translates to:
  /// **'Toggle reader mode for the current page'**
  String get browserActions_toggleReaderModeDescription;

  /// Name of the browser action that switches between the mobile and desktop version of the website, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Desktop Site'**
  String get browserActions_toggleDesktopModeTitle;

  /// Explanation under that browser action's name in the action lists: it switches between the mobile and desktop version of the website.
  ///
  /// In en, this message translates to:
  /// **'Toggle desktop site for the current page'**
  String get browserActions_toggleDesktopModeDescription;

  /// Name of the browser action that opens the bar for searching text on the page, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Find in Page'**
  String get browserActions_findInPageTitle;

  /// Explanation under that browser action's name in the action lists: it opens the bar for searching text on the page.
  ///
  /// In en, this message translates to:
  /// **'Open find in page'**
  String get browserActions_findInPageDescription;

  /// Name of the browser action that jumps to the next match of the last find-in-page search, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Find Next'**
  String get browserActions_findNextTitle;

  /// Explanation under that browser action's name in the action lists: it jumps to the next match of the last find-in-page search.
  ///
  /// In en, this message translates to:
  /// **'Jump to the next match of the last search'**
  String get browserActions_findNextDescription;

  /// Name of the browser action that jumps to the previous match of the last find-in-page search, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Find Previous'**
  String get browserActions_findPreviousTitle;

  /// Explanation under that browser action's name in the action lists: it jumps to the previous match of the last find-in-page search.
  ///
  /// In en, this message translates to:
  /// **'Jump to the previous match of the last search'**
  String get browserActions_findPreviousDescription;

  /// Name of the browser action that makes page text larger, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Increase Font'**
  String get browserActions_increaseFontSizeTitle;

  /// Explanation under that browser action's name in the action lists: it makes page text larger.
  ///
  /// In en, this message translates to:
  /// **'Increase the page font size'**
  String get browserActions_increaseFontSizeDescription;

  /// Name of the browser action that makes page text smaller, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Decrease Font'**
  String get browserActions_decreaseFontSizeTitle;

  /// Explanation under that browser action's name in the action lists: it makes page text smaller.
  ///
  /// In en, this message translates to:
  /// **'Decrease the page font size'**
  String get browserActions_decreaseFontSizeDescription;

  /// Name of the browser action that restores the default page text size, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Reset Font'**
  String get browserActions_resetFontSizeTitle;

  /// Explanation under that browser action's name in the action lists: it restores the default page text size.
  ///
  /// In en, this message translates to:
  /// **'Restore the default page font size'**
  String get browserActions_resetFontSizeDescription;

  /// Name of the browser action that bookmarks the current page, or removes its bookmark, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get browserActions_toggleBookmarkTitle;

  /// Explanation under that browser action's name in the action lists: it bookmarks the current page, or removes its bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark or unbookmark the current page'**
  String get browserActions_toggleBookmarkDescription;

  /// Name of the browser action that shares the current page, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get browserActions_sharePageTitle;

  /// Explanation under that browser action's name in the action lists: it shares the current page.
  ///
  /// In en, this message translates to:
  /// **'Share the current page'**
  String get browserActions_sharePageDescription;

  /// Name of the browser action that opens the page translation options, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get browserActions_translatePageTitle;

  /// Explanation under that browser action's name in the action lists: it opens the page translation options.
  ///
  /// In en, this message translates to:
  /// **'Open the page translation sheet'**
  String get browserActions_translatePageDescription;

  /// Name of the browser action that prints the current page, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get browserActions_printPageTitle;

  /// Explanation under that browser action's name in the action lists: it prints the current page.
  ///
  /// In en, this message translates to:
  /// **'Print the current page'**
  String get browserActions_printPageDescription;

  /// Name of the browser action that opens the home screen, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get browserActions_showHomeTitle;

  /// Explanation under that browser action's name in the action lists: it opens the home screen.
  ///
  /// In en, this message translates to:
  /// **'Open the home screen'**
  String get browserActions_showHomeDescription;

  /// Name of the browser action that opens browsing history, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get browserActions_showHistoryTitle;

  /// Explanation under that browser action's name in the action lists: it opens browsing history.
  ///
  /// In en, this message translates to:
  /// **'Open browsing history'**
  String get browserActions_showHistoryDescription;

  /// Name of the browser action that opens the bookmarks list, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get browserActions_showBookmarksTitle;

  /// Explanation under that browser action's name in the action lists: it opens the bookmarks list.
  ///
  /// In en, this message translates to:
  /// **'Open bookmarks'**
  String get browserActions_showBookmarksDescription;

  /// Name of the browser action that opens the list of containers, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Containers'**
  String get browserActions_showContainersTitle;

  /// Explanation under that browser action's name in the action lists: it opens the list of containers.
  ///
  /// In en, this message translates to:
  /// **'Open the container list'**
  String get browserActions_showContainersDescription;

  /// Name of the browser action that opens the overview of all open tabs, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Tab View'**
  String get browserActions_showTabViewTitle;

  /// Explanation under that browser action's name in the action lists: it opens the overview of all open tabs.
  ///
  /// In en, this message translates to:
  /// **'Open the tab overview'**
  String get browserActions_showTabViewDescription;

  /// Name of the browser action that opens the list of downloads, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get browserActions_showDownloadsTitle;

  /// Explanation under that browser action's name in the action lists: it opens the list of downloads.
  ///
  /// In en, this message translates to:
  /// **'Open downloads'**
  String get browserActions_showDownloadsDescription;

  /// Name of the browser action that opens the browser extensions (add-ons) screen, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Add-ons'**
  String get browserActions_showAddonsTitle;

  /// Explanation under that browser action's name in the action lists: it opens the browser extensions (add-ons) screen.
  ///
  /// In en, this message translates to:
  /// **'Manage extensions'**
  String get browserActions_showAddonsDescription;

  /// Name of the browser action that opens settings, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get browserActions_openSettingsTitle;

  /// Explanation under that browser action's name in the action lists: it opens settings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get browserActions_openSettingsDescription;

  /// Name of the browser action that shows the list of keyboard shortcuts, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Keyboard Shortcuts'**
  String get browserActions_showKeyboardShortcutsTitle;

  /// Explanation under that browser action's name in the action lists: it shows the list of keyboard shortcuts.
  ///
  /// In en, this message translates to:
  /// **'List the keys that run browser actions'**
  String get browserActions_showKeyboardShortcutsDescription;

  /// Name of the browser action that hides the tab bar, or shows it again, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Hide / Show Tab Bar'**
  String get browserActions_toggleTabBarTitle;

  /// Explanation under that browser action's name in the action lists: it hides the tab bar, or shows it again.
  ///
  /// In en, this message translates to:
  /// **'Hide the tab bar, or bring it back'**
  String get browserActions_toggleTabBarDescription;

  /// Name of the browser action that opens the dialog for deleting browsing data, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Clear Browsing Data'**
  String get browserActions_clearBrowsingDataTitle;

  /// Explanation under that browser action's name in the action lists: it opens the dialog for deleting browsing data.
  ///
  /// In en, this message translates to:
  /// **'Choose browsing data to delete'**
  String get browserActions_clearBrowsingDataDescription;

  /// Name of the browser action that sends the app to the background, like pressing the Home button, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Minimize'**
  String get browserActions_moveToBackgroundTitle;

  /// Explanation under that browser action's name in the action lists: it sends the app to the background, like pressing the Home button. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'Send WebLibre to the background'**
  String get browserActions_moveToBackgroundDescription;

  /// Name of the browser action that closes all tabs and exits the app, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get browserActions_quitBrowserTitle;

  /// Explanation under that browser action's name in the action lists: it closes all tabs and exits the app. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'Close all tabs and quit WebLibre'**
  String get browserActions_quitBrowserDescription;

  /// Heading of a group of browser actions that create something new (a container, a bookmark folder, a profile, ...) in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get browserActions_categoryCreate;

  /// Name of the browser action that opens the current page again in a new private tab, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions, and in the Actions section of the search screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Open in Private Tab'**
  String get browserActions_openInPrivateTabTitle;

  /// Explanation under that browser action's name in the action lists: it opens the current page again in a new private tab.
  ///
  /// In en, this message translates to:
  /// **'Open the current page in a new private tab'**
  String get browserActions_openInPrivateTabDescription;

  /// Name of the browser action that moves the current tab into a container the user picks, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions, and in the Actions section of the search screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Move to Container'**
  String get browserActions_moveTabToContainerTitle;

  /// Explanation under that browser action's name in the action lists: it moves the current tab into a container the user picks.
  ///
  /// In en, this message translates to:
  /// **'Move the current tab to another container'**
  String get browserActions_moveTabToContainerDescription;

  /// Name of the browser action that copies the current page's address to the clipboard, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions, and in the Actions section of the search screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get browserActions_copyLinkTitle;

  /// Explanation under that browser action's name in the action lists: it copies the current page's address to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy the address of the current page'**
  String get browserActions_copyLinkDescription;

  /// Name of the browser action that opens the sheet with the current site's permissions and tracking protection, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions, and in the Actions section of the search screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Site Settings'**
  String get browserActions_siteSettingsTitle;

  /// Explanation under that browser action's name in the action lists: it opens the sheet with the current site's permissions and tracking protection.
  ///
  /// In en, this message translates to:
  /// **'Permissions and tracking protection for this site'**
  String get browserActions_siteSettingsDescription;

  /// Name of the browser action that installs the current site on the Android home screen as an app or shortcut, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions, and in the Actions section of the search screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Add to Home Screen'**
  String get browserActions_addToHomeScreenTitle;

  /// Explanation under that browser action's name in the action lists: it installs the current site on the Android home screen as an app or shortcut.
  ///
  /// In en, this message translates to:
  /// **'Install the current site as an app or shortcut'**
  String get browserActions_addToHomeScreenDescription;

  /// Name of the browser action that looks for RSS/Atom feeds on the current page and offers to subscribe, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions, and in the Actions section of the search screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Page'**
  String get browserActions_subscribeToPageFeedTitle;

  /// Explanation under that browser action's name in the action lists: it looks for RSS/Atom feeds on the current page and offers to subscribe.
  ///
  /// In en, this message translates to:
  /// **'Find and follow the feeds of the current page'**
  String get browserActions_subscribeToPageFeedDescription;

  /// Name of the browser action that opens the list of subscribed RSS/Atom feeds, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions, and in the Actions section of the search screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Feeds'**
  String get browserActions_showFeedsTitle;

  /// Explanation under that browser action's name in the action lists: it opens the list of subscribed RSS/Atom feeds.
  ///
  /// In en, this message translates to:
  /// **'Open your feeds'**
  String get browserActions_showFeedsDescription;

  /// Name of the browser action that opens the list of browser profiles, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions, and in the Actions section of the search screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get browserActions_showProfilesTitle;

  /// Explanation under that browser action's name in the action lists: it opens the list of browser profiles.
  ///
  /// In en, this message translates to:
  /// **'Manage your profiles'**
  String get browserActions_showProfilesDescription;

  /// Name of the browser action that opens the proxy settings, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions, and in the Actions section of the search screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Proxy'**
  String get browserActions_showProxySettingsTitle;

  /// Explanation under that browser action's name in the action lists: it opens the proxy settings.
  ///
  /// In en, this message translates to:
  /// **'Open proxy settings'**
  String get browserActions_showProxySettingsDescription;

  /// Name of the browser action that opens the Tor proxy screen. Tor is a brand name, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions, and in the Actions section of the search screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Tor'**
  String get browserActions_showTorTitle;

  /// Explanation under that browser action's name in the action lists: it opens the Tor proxy screen. Tor is a brand name.
  ///
  /// In en, this message translates to:
  /// **'Open Tor settings'**
  String get browserActions_showTorDescription;

  /// Name of the browser action that opens the sync settings, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions, and in the Actions section of the search screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get browserActions_showSyncSettingsTitle;

  /// Explanation under that browser action's name in the action lists: it opens the sync settings.
  ///
  /// In en, this message translates to:
  /// **'Open sync settings'**
  String get browserActions_showSyncSettingsDescription;

  /// Name of the browser action that opens the filter lists of the uBlock Origin content blocker, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions, and in the Actions section of the search screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Filter Lists'**
  String get browserActions_showContentBlockerListsTitle;

  /// Explanation under that browser action's name in the action lists: it opens the filter lists of the uBlock Origin content blocker.
  ///
  /// In en, this message translates to:
  /// **'Manage the content blocker\'s filter lists'**
  String get browserActions_showContentBlockerListsDescription;

  /// Name of the browser action that opens the screen with the app's error logs, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions, and in the Actions section of the search screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Error Logs'**
  String get browserActions_showErrorLogsTitle;

  /// Explanation under that browser action's name in the action lists: it opens the screen with the app's error logs.
  ///
  /// In en, this message translates to:
  /// **'View the app\'s error logs'**
  String get browserActions_showErrorLogsDescription;

  /// Name of the browser action that opens the About screen. WebLibre is the app name, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions, and in the Actions section of the search screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get browserActions_showAboutTitle;

  /// Explanation under that browser action's name in the action lists: it opens the About screen. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'About WebLibre'**
  String get browserActions_showAboutDescription;

  /// Name of the browser action that starts creating a new container (a separate browsing identity), shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions, and in the Actions section of the search screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'New Container'**
  String get browserActions_newContainerTitle;

  /// Explanation under that browser action's name in the action lists: it starts creating a new container (a separate browsing identity).
  ///
  /// In en, this message translates to:
  /// **'Create a container'**
  String get browserActions_newContainerDescription;

  /// Name of the browser action that starts creating a new bookmark folder, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions, and in the Actions section of the search screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'New Bookmark Folder'**
  String get browserActions_newBookmarkFolderTitle;

  /// Explanation under that browser action's name in the action lists: it starts creating a new bookmark folder.
  ///
  /// In en, this message translates to:
  /// **'Create a bookmark folder'**
  String get browserActions_newBookmarkFolderDescription;

  /// Name of the browser action that opens the dialog for subscribing to an RSS/Atom feed by address, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions, and in the Actions section of the search screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Add Feed'**
  String get browserActions_addFeedTitle;

  /// Explanation under that browser action's name in the action lists: it opens the dialog for subscribing to an RSS/Atom feed by address.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to a feed by its address'**
  String get browserActions_addFeedDescription;

  /// Name of the browser action that starts creating a custom bang (a search shortcut such as \"!w\"), shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions, and in the Actions section of the search screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'New Search Shortcut'**
  String get browserActions_newSearchEngineTitle;

  /// Explanation under that browser action's name in the action lists: it starts creating a custom bang (a search shortcut such as \"!w\").
  ///
  /// In en, this message translates to:
  /// **'Create your own bang search shortcut'**
  String get browserActions_newSearchEngineDescription;

  /// Name of the browser action that starts creating a new browser profile, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions, and in the Actions section of the search screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'New Profile'**
  String get browserActions_newProfileTitle;

  /// Explanation under that browser action's name in the action lists: it starts creating a new browser profile.
  ///
  /// In en, this message translates to:
  /// **'Create a browser profile'**
  String get browserActions_newProfileDescription;

  /// Name of the browser action that starts adding a new proxy server profile, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions, and in the Actions section of the search screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'New Proxy Profile'**
  String get browserActions_newProxyProfileTitle;

  /// Explanation under that browser action's name in the action lists: it starts adding a new proxy server profile.
  ///
  /// In en, this message translates to:
  /// **'Add a proxy server'**
  String get browserActions_newProxyProfileDescription;

  /// Name of the browser action that starts backing up the current browser profile, shown in the lists for assigning keyboard shortcuts, drawn gestures and swipe or long-press actions, and in the Actions section of the search screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Back Up Profile'**
  String get browserActions_backupProfileTitle;

  /// Explanation under that browser action's name in the action lists: it starts backing up the current browser profile.
  ///
  /// In en, this message translates to:
  /// **'Create a backup of the current profile'**
  String get browserActions_backupProfileDescription;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'favorite, save page, star'**
  String get browserActions_toggleBookmarkKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'search in page, search text, find text'**
  String get browserActions_findInPageKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'copy url, copy address, clipboard'**
  String get browserActions_copyLinkKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'send, share link, send to'**
  String get browserActions_sharePageKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'reader view, reading mode, article, simplify page'**
  String get browserActions_toggleReaderModeKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'desktop version, request desktop site, mobile site, user agent'**
  String get browserActions_toggleDesktopModeKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'translation, language, translator'**
  String get browserActions_translatePageKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'permissions, cookies, tracking protection, camera, microphone, location, site info'**
  String get browserActions_siteSettingsKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'pwa, install, web app, shortcut, launcher, app'**
  String get browserActions_addToHomeScreenKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'rss, atom, feed, subscribe, follow, news'**
  String get browserActions_subscribeToPageFeedKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'pdf, save as pdf, printer'**
  String get browserActions_printPageKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'zoom in, bigger text, larger font, text size'**
  String get browserActions_increaseFontSizeKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'zoom out, smaller text, smaller font, text size'**
  String get browserActions_decreaseFontSizeKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'default text size, reset zoom, text size'**
  String get browserActions_resetFontSizeKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'incognito, private browsing, private mode'**
  String get browserActions_openInPrivateTabKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'assign container, identity, tab group'**
  String get browserActions_moveTabToContainerKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'clone tab, copy tab'**
  String get browserActions_duplicateTabKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'pin tab, unpin, sticky'**
  String get browserActions_togglePinTabKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'close, remove tab'**
  String get browserActions_closeTabKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'undo close, restore tab, recently closed'**
  String get browserActions_reopenClosedTabKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'visited pages, browsing history, recently visited'**
  String get browserActions_showHistoryKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'favorites, saved pages, bookmark manager'**
  String get browserActions_showBookmarksKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'downloaded files, files, download manager'**
  String get browserActions_showDownloadsKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'tab overview, all tabs, tab switcher, open tabs'**
  String get browserActions_showTabViewKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'identities, container list, workspaces'**
  String get browserActions_showContainersKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'rss, atom, news, subscriptions'**
  String get browserActions_showFeedsKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'users, accounts, switch profile'**
  String get browserActions_showProfilesKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'vpn, sing-box, socks, connection, network'**
  String get browserActions_showProxySettingsKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'onion, anonymous, bridges, anonymity'**
  String get browserActions_showTorKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'account, synchronize, devices'**
  String get browserActions_showSyncSettingsKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'extensions, plugins, webextensions'**
  String get browserActions_showAddonsKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'ublock, adblock, ad blocker, filters, blocklists'**
  String get browserActions_showContentBlockerListsKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'preferences, options, configuration'**
  String get browserActions_openSettingsKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'hotkeys, key bindings, keys'**
  String get browserActions_showKeyboardShortcutsKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'logs, debug, crash, bug report'**
  String get browserActions_showErrorLogsKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'version, license, info'**
  String get browserActions_showAboutKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'add container, create identity, workspace'**
  String get browserActions_newContainerKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'add folder, create folder, organize bookmarks'**
  String get browserActions_newBookmarkFolderKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'rss, atom, subscribe, add subscription'**
  String get browserActions_addFeedKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'bang, custom search, add search engine, search shortcut'**
  String get browserActions_newSearchEngineKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'add user, create profile, new account'**
  String get browserActions_newProfileKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'add proxy, vpn, server, sing-box, socks'**
  String get browserActions_newProxyProfileKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'backup, export, save data, archive'**
  String get browserActions_backupProfileKeywords;

  /// Comma-separated search terms for this browser action in the search screen's Actions section. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'delete history, clear cache, cookies, erase, wipe, privacy'**
  String get browserActions_clearBrowsingDataKeywords;

  /// Title of the bookmarks screen.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks_title;

  /// Placeholder of the search field on the bookmarks screen.
  ///
  /// In en, this message translates to:
  /// **'Filter bookmarks...'**
  String get bookmarks_filterHint;

  /// Shown inside a bookmark folder that contains nothing.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get bookmarks_emptyFolder;

  /// Shown when a bookmark search finds bookmarks but the "Folders Only" view hides them. "Folders Only" is the menu option of that name and must match it.
  ///
  /// In en, this message translates to:
  /// **'Search matches bookmarks hidden by \"Folders Only\"'**
  String get bookmarks_searchHiddenByFoldersOnly;

  /// Shown when no bookmark matches the search. query is the search text.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks match \"{query}\"'**
  String bookmarks_noSearchMatches(String query);

  /// Error heading when bookmarks could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Failed to load bookmarks'**
  String get bookmarks_loadFailedTitle;

  /// Error heading when the bookmark folder tree could not be loaded in the folder picker.
  ///
  /// In en, this message translates to:
  /// **'Failed to load bookmark folders'**
  String get bookmarks_loadFoldersFailedTitle;

  /// Label above the folder picker in the bookmark and folder editors.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get bookmarks_folderLabel;

  /// Shown in place of the name of a bookmark folder that has none.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Folder'**
  String get bookmarks_unnamedFolder;

  /// Title of the bookmarks screen while items are selected. count is the number of selected items.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 selected} other{{count} selected}}'**
  String bookmarks_selectionCount(int count);

  /// Tooltip of the button that opens all selected bookmarks in new tabs without switching to them.
  ///
  /// In en, this message translates to:
  /// **'Open in background'**
  String get bookmarks_tooltipOpenInBackground;

  /// Tooltip of the button that moves the selected bookmarks to another folder.
  ///
  /// In en, this message translates to:
  /// **'Move selected'**
  String get bookmarks_tooltipMoveSelected;

  /// Tooltip of the button that deletes the selected bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Delete selected'**
  String get bookmarks_tooltipDeleteSelected;

  /// Tooltip of the search button while the search field has text: clears it.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get bookmarks_tooltipClearSearch;

  /// Tooltip of the search button that opens the bookmark search field.
  ///
  /// In en, this message translates to:
  /// **'Search bookmarks'**
  String get bookmarks_tooltipSearchBookmarks;

  /// Tooltip of the folder icon of an expanded bookmark folder: collapses it.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get bookmarks_tooltipCollapse;

  /// Tooltip of the folder icon of a collapsed bookmark folder: shows its contents inline.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get bookmarks_tooltipExpand;

  /// Item in the bookmarks screen menu that creates a new bookmark in the folder currently shown.
  ///
  /// In en, this message translates to:
  /// **'Add Bookmark Here'**
  String get bookmarks_menuAddBookmarkHere;

  /// Item in the bookmarks screen menu that creates a new folder inside the folder currently shown.
  ///
  /// In en, this message translates to:
  /// **'Add Subfolder Here'**
  String get bookmarks_menuAddSubfolderHere;

  /// Item in the bookmarks screen menu that collapses all expanded folders.
  ///
  /// In en, this message translates to:
  /// **'Collapse All'**
  String get bookmarks_menuCollapseAll;

  /// Item in the bookmarks visibility menu: show built-in folders that contain nothing.
  ///
  /// In en, this message translates to:
  /// **'Show Empty Folders'**
  String get bookmarks_menuShowEmptyFolders;

  /// Item in the bookmarks visibility menu: hide built-in folders that contain nothing.
  ///
  /// In en, this message translates to:
  /// **'Hide Empty Folders'**
  String get bookmarks_menuHideEmptyFolders;

  /// Item in the bookmarks visibility menu: show bookmarks again after "Folders Only" was chosen.
  ///
  /// In en, this message translates to:
  /// **'Show Bookmarks'**
  String get bookmarks_menuShowBookmarks;

  /// Item in the bookmarks visibility menu: show only folders, hiding the bookmarks in them.
  ///
  /// In en, this message translates to:
  /// **'Folders Only'**
  String get bookmarks_menuFoldersOnly;

  /// Submenu in the bookmarks screen menu with options for what is shown.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get bookmarks_menuVisibility;

  /// Submenu in the bookmarks screen menu for choosing the sort order.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get bookmarks_menuSort;

  /// Submenu in the bookmarks screen menu for importing bookmarks from a file.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get bookmarks_menuImport;

  /// Submenu in the bookmarks screen menu for saving bookmarks to a file.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get bookmarks_menuExport;

  /// File format option in the bookmark import and export menus. Technical name; do not translate.
  ///
  /// In en, this message translates to:
  /// **'JSON'**
  String get bookmarks_formatJson;

  /// File format option in the bookmark import and export menus (the standard format browsers use for bookmark files). Technical name; do not translate.
  ///
  /// In en, this message translates to:
  /// **'HTML'**
  String get bookmarks_formatHtml;

  /// Menu item of a bookmark: open it in a new tab and switch to it.
  ///
  /// In en, this message translates to:
  /// **'Open in New Tab'**
  String get bookmarks_actionOpenInNewTab;

  /// Menu item of a bookmark: open it in a new tab without switching to it.
  ///
  /// In en, this message translates to:
  /// **'Open in Background'**
  String get bookmarks_actionOpenInBackground;

  /// Menu item of a bookmark: share its address.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get bookmarks_actionShare;

  /// Menu item of a bookmark or folder: move it to another folder.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get bookmarks_actionMove;

  /// Menu item of a bookmark folder: remove the folder but keep its contents by moving them up one level.
  ///
  /// In en, this message translates to:
  /// **'Flatten'**
  String get bookmarks_actionFlatten;

  /// Menu item of a bookmark folder: create a new folder inside it.
  ///
  /// In en, this message translates to:
  /// **'Add Subfolder'**
  String get bookmarks_actionAddSubfolder;

  /// Menu item of a bookmark folder: create a new bookmark inside it.
  ///
  /// In en, this message translates to:
  /// **'Add Bookmark'**
  String get bookmarks_actionAddBookmark;

  /// Button in the import dialog: keep existing bookmarks and add the imported ones.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get bookmarks_actionMerge;

  /// Button in the import dialog: delete existing bookmarks, then import.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get bookmarks_actionReplace;

  /// Message when "open in background" is used but the selection contains only folders and no bookmarks.
  ///
  /// In en, this message translates to:
  /// **'No bookmark entries selected'**
  String get bookmarks_noEntriesSelected;

  /// Confirmation after opening selected bookmarks in background tabs. count is the number of tabs opened.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Opened 1 tab in background} other{Opened {count} tabs in background}}'**
  String bookmarks_openedTabsInBackground(int count);

  /// Confirmation after moving selected bookmarks and folders. count is the number of items moved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Moved 1 item} other{Moved {count} items}}'**
  String bookmarks_movedItemsCount(int count);

  /// Confirmation after deleting selected bookmarks and folders. count is the number of items deleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Deleted 1 item} other{Deleted {count} items}}'**
  String bookmarks_deletedItemsCount(int count);

  /// Error message when the file chosen for bookmark import could not be opened.
  ///
  /// In en, this message translates to:
  /// **'Failed to read file'**
  String get bookmarks_importFailedToReadFile;

  /// Confirmation after a bookmark import. count is the number of bookmarks imported.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 bookmark successfully} other{Imported {count} bookmarks successfully}}'**
  String bookmarks_importSuccessCount(int count);

  /// Error message when a bookmark import failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String bookmarks_importFailedWithError(String error);

  /// Title of the system file dialog for choosing where to save exported bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Export Bookmarks'**
  String get bookmarks_exportDialogTitle;

  /// Confirmation after bookmarks were saved to a file.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks exported successfully'**
  String get bookmarks_exportSuccess;

  /// Error message when saving bookmarks to a file failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String bookmarks_exportFailedWithError(String error);

  /// Sort order option for bookmarks: the order they were arranged in (manual order).
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get bookmarks_sortDefault;

  /// Sort order option for bookmarks: by name, alphabetically A to Z.
  ///
  /// In en, this message translates to:
  /// **'Title A-Z'**
  String get bookmarks_sortTitleAsc;

  /// Sort order option for bookmarks: by name, alphabetically Z to A.
  ///
  /// In en, this message translates to:
  /// **'Title Z-A'**
  String get bookmarks_sortTitleDesc;

  /// Sort order option for bookmarks: by web address, alphabetically A to Z.
  ///
  /// In en, this message translates to:
  /// **'URL A-Z'**
  String get bookmarks_sortUrlAsc;

  /// Sort order option for bookmarks: by web address, alphabetically Z to A.
  ///
  /// In en, this message translates to:
  /// **'URL Z-A'**
  String get bookmarks_sortUrlDesc;

  /// Sort order option for bookmarks: most recently added first.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get bookmarks_sortDateAddedDesc;

  /// Sort order option for bookmarks: earliest added first.
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get bookmarks_sortDateAddedAsc;

  /// Title of the confirmation dialog before deleting a bookmark.
  ///
  /// In en, this message translates to:
  /// **'Delete Bookmark'**
  String get bookmarks_deleteBookmarkTitle;

  /// Body of the confirmation dialog before deleting a bookmark.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this bookmark?'**
  String get bookmarks_deleteBookmarkContent;

  /// Title of the confirmation dialog before deleting a bookmark folder.
  ///
  /// In en, this message translates to:
  /// **'Delete Folder'**
  String get bookmarks_deleteFolderTitle;

  /// Body of the confirmation dialog before deleting a bookmark folder, used when the number of bookmarks inside is not known.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this folder, including all its bookmarks?'**
  String get bookmarks_deleteFolderConfirmUnknown;

  /// Body of the confirmation dialog before deleting a bookmark folder. count is the number of bookmarks inside it, which are deleted too.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Are you sure you want to delete this folder?} =1{Are you sure you want to delete this folder and its one bookmark?} other{Are you sure you want to delete this folder and its {count} bookmarks?}}'**
  String bookmarks_deleteFolderConfirmCount(int count);

  /// Title of the dialog asking whether imported bookmarks replace or add to the existing ones.
  ///
  /// In en, this message translates to:
  /// **'Import Bookmarks'**
  String get bookmarks_importDialogTitle;

  /// Body of the import dialog. "Replace" and "Merge" are the dialog's button labels and must match their translations. Keep the blank line (\n\n).
  ///
  /// In en, this message translates to:
  /// **'Do you want to erase all existing bookmarks before importing?\n\nChoose \"Replace\" to delete existing bookmarks, or \"Merge\" to keep them.'**
  String get bookmarks_importDialogContent;

  /// Title of the progress dialog while bookmarks are imported.
  ///
  /// In en, this message translates to:
  /// **'Importing bookmarks'**
  String get bookmarks_importProgressTitle;

  /// Progress step while the import file is read.
  ///
  /// In en, this message translates to:
  /// **'Reading the file…'**
  String get bookmarks_importPhaseParsing;

  /// Progress step while existing bookmarks are deleted before a "Replace" import.
  ///
  /// In en, this message translates to:
  /// **'Removing existing bookmarks…'**
  String get bookmarks_importPhaseErasing;

  /// Progress step while imported bookmarks are saved. inserted is how many are done; total is how many there are.
  ///
  /// In en, this message translates to:
  /// **'{total, plural, =1{{inserted} of 1 bookmark} other{{inserted} of {total} bookmarks}}'**
  String bookmarks_importPhaseInsertingProgress(int inserted, int total);

  /// Progress step while imported bookmarks are saved, when the total is not known.
  ///
  /// In en, this message translates to:
  /// **'Saving bookmarks…'**
  String get bookmarks_importPhaseInsertingIndeterminate;

  /// Title of the dialog for choosing the folder to move bookmarks to.
  ///
  /// In en, this message translates to:
  /// **'Move to Folder'**
  String get bookmarks_moveToFolderTitle;

  /// Title of the screen for editing an existing bookmark.
  ///
  /// In en, this message translates to:
  /// **'Edit Bookmark'**
  String get bookmarks_editBookmarkTitle;

  /// Title of the screen for creating a new bookmark.
  ///
  /// In en, this message translates to:
  /// **'Create Bookmark'**
  String get bookmarks_createBookmarkTitle;

  /// Title of the screen for editing an existing bookmark folder.
  ///
  /// In en, this message translates to:
  /// **'Edit Folder'**
  String get bookmarks_editFolderTitle;

  /// Title of the screen for creating a new bookmark folder.
  ///
  /// In en, this message translates to:
  /// **'Create Folder'**
  String get bookmarks_createFolderTitle;

  /// Label of the name field in the bookmark and folder editors.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get bookmarks_fieldNameLabel;

  /// Label of the web address field in the bookmark editor.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get bookmarks_fieldUrlLabel;

  /// Switch in the bookmark and folder editors: place the new item first in its folder instead of last.
  ///
  /// In en, this message translates to:
  /// **'Add to top'**
  String get bookmarks_addToTop;

  /// Confirm button of the bookmark folder picker dialog.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get browser_actionSelect;

  /// Button in the "Keep tab?" dialog: keep the tab that was opened by another app.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get browser_actionKeep;

  /// Button that installs the chosen extension file.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get browser_actionInstall;

  /// Title of the dialog for bookmarking all open tabs at once.
  ///
  /// In en, this message translates to:
  /// **'Bookmark All Tabs'**
  String get browser_bookmarkAllTitle;

  /// Option in that dialog: bookmark everything into one folder without further questions.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get browser_bookmarkAllFastTitle;

  /// Explanation under "Fast".
  ///
  /// In en, this message translates to:
  /// **'Automatically add all tabs to a selected folder'**
  String get browser_bookmarkAllFastSubtitle;

  /// Option in that dialog: go through the bookmarks one by one.
  ///
  /// In en, this message translates to:
  /// **'Detailed'**
  String get browser_bookmarkAllDetailedTitle;

  /// Explanation under "Detailed".
  ///
  /// In en, this message translates to:
  /// **'Review and edit each bookmark individually'**
  String get browser_bookmarkAllDetailedSubtitle;

  /// Title of the dialog, and row in the site info sheet, for deleting data stored by the current website.
  ///
  /// In en, this message translates to:
  /// **'Clear Site Data'**
  String get browser_clearSiteDataTitle;

  /// Body of the clear site data dialog. host is the website domain; formattedTypes is the chosen data types, one bulleted line each, using the checkbox labels (e.g. "• Cookies"). Keep the line breaks (\n) around it.
  ///
  /// In en, this message translates to:
  /// **'This will clear the following data for {host}:\n{formattedTypes}\n\nYou may need to log in again.'**
  String browser_clearSiteDataContent(String formattedTypes, String host);

  /// Option in the page content dialog (e.g. for copying or exporting as Markdown): use only the main article text.
  ///
  /// In en, this message translates to:
  /// **'Extracted Content'**
  String get browser_contentSelectionExtractedTitle;

  /// Explanation under "Extracted Content".
  ///
  /// In en, this message translates to:
  /// **'Reader-optimized content without navigation and ads'**
  String get browser_contentSelectionExtractedSubtitle;

  /// Option in the page content dialog: use the whole page.
  ///
  /// In en, this message translates to:
  /// **'Full Content'**
  String get browser_contentSelectionFullTitle;

  /// Explanation under "Full Content".
  ///
  /// In en, this message translates to:
  /// **'Complete page including all elements and structure'**
  String get browser_contentSelectionFullSubtitle;

  /// Title of the sheet for deleting browsing data (history, cookies, cache, etc.).
  ///
  /// In en, this message translates to:
  /// **'Delete Browsing Data'**
  String get browser_deleteDataTitle;

  /// Title of the sheet for installing a browser extension from a file on the device.
  ///
  /// In en, this message translates to:
  /// **'Install Extension from File'**
  String get browser_installAddonSheetTitle;

  /// Button that opens the file picker for an extension file. XPI is the extension file format; keep it unchanged.
  ///
  /// In en, this message translates to:
  /// **'Select XPI File'**
  String get browser_installAddonSelectFileButton;

  /// Shown in place of the file name until an extension file is chosen.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get browser_installAddonNoFileSelected;

  /// Note in the install sheet: extensions installed from a file do not update themselves. XPI is the file format.
  ///
  /// In en, this message translates to:
  /// **'Extensions installed from a local XPI stay pinned to that version and will not update automatically.'**
  String get browser_installAddonPinnedNotice;

  /// Error when the chosen file is not an extension file. ".xpi" is a file extension; keep it unchanged.
  ///
  /// In en, this message translates to:
  /// **'Please select an .xpi file'**
  String get browser_installAddonNotXpiError;

  /// Error when the file picker failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick file: {error}'**
  String browser_installAddonPickFileFailed(String error);

  /// Confirmation after installing an extension from a file.
  ///
  /// In en, this message translates to:
  /// **'Extension installed. Automatic updates are disabled for this local version.'**
  String get browser_installAddonInstalledMessage;

  /// Error when the extension file is not signed by Mozilla. "Allow unsigned extensions" is the name of a setting and must match its translation.
  ///
  /// In en, this message translates to:
  /// **'This extension is not signed by Mozilla. Enable \"Allow unsigned extensions\" in Extensions settings to install it.'**
  String get browser_installAddonNotSignedError;

  /// Error when installing an extension file failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Installation failed: {error}'**
  String browser_installAddonInstallFailed(String error);

  /// Title of the dialog asking whether to keep a tab another app opened, after returning from it.
  ///
  /// In en, this message translates to:
  /// **'Keep tab?'**
  String get browser_keepTabTitle;

  /// Body of the "Keep tab?" dialog.
  ///
  /// In en, this message translates to:
  /// **'Do you want to keep this tab or discard it?'**
  String get browser_keepTabContent;

  /// Title of the dialog showing the page address as a QR code for another device to scan.
  ///
  /// In en, this message translates to:
  /// **'Share QR Code'**
  String get browser_qrCodeTitle;

  /// Title of the bookmark folder picker dialog.
  ///
  /// In en, this message translates to:
  /// **'Select folder'**
  String get browser_selectFolderTitle;

  /// Message in the tab tree view (tabs shown with the tabs they were opened from) when the current tab is in a different tree.
  ///
  /// In en, this message translates to:
  /// **'The current tab is not part of this tree'**
  String get browser_tabTreeCurrentTabNotInTree;

  /// Last item of the extensions menu: open extension management.
  ///
  /// In en, this message translates to:
  /// **'Manage extensions'**
  String get browser_menuManageExtensions;

  /// Item of the new-tab menu: open a regular tab.
  ///
  /// In en, this message translates to:
  /// **'Add Regular Tab'**
  String get browser_menuAddRegularTab;

  /// Item of the new-tab menu: open a tab nested under the current tab.
  ///
  /// In en, this message translates to:
  /// **'Add Child Tab'**
  String get browser_menuAddChildTab;

  /// Item of the new-tab menu: open a private tab.
  ///
  /// In en, this message translates to:
  /// **'Add Private Tab'**
  String get browser_menuAddPrivateTab;

  /// Item of the new-tab menu: open an isolated tab (own separate cookies and site data).
  ///
  /// In en, this message translates to:
  /// **'Add Isolated Tab'**
  String get browser_menuAddIsolatedTab;

  /// Title of the sheet for changing the page text size.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get browser_fontSizeTitle;

  /// Note in the text size sheet while automatic font size is on.
  ///
  /// In en, this message translates to:
  /// **'Automatic font size is enabled. Disable in Settings to adjust manually.'**
  String get browser_fontSizeAutomaticNotice;

  /// Button that restores the normal text size. Keep "100%" as a percentage in your locale's format.
  ///
  /// In en, this message translates to:
  /// **'Reset to 100%'**
  String get browser_fontSizeResetButton;

  /// Shown in the back-button history list when there is no earlier page.
  ///
  /// In en, this message translates to:
  /// **'No previous pages'**
  String get browser_historyNoPreviousPages;

  /// Shown in the forward-button history list when there is no later page.
  ///
  /// In en, this message translates to:
  /// **'No forward pages'**
  String get browser_historyNoForwardPages;

  /// Connection status in the site info sheet for a page shown from a server-made capture (not loaded live).
  ///
  /// In en, this message translates to:
  /// **'Sandboxed capture'**
  String get browser_certSandboxedCaptureTitle;

  /// Explanation under "Sandboxed capture".
  ///
  /// In en, this message translates to:
  /// **'The page is served from an offline archive — no live connection.'**
  String get browser_certSandboxedCaptureSubtitle;

  /// Connection status in the site info sheet when the page is not loaded over a secure (HTTPS) connection.
  ///
  /// In en, this message translates to:
  /// **'Connection is not secure'**
  String get browser_certConnectionNotSecure;

  /// Connection status in the site info sheet when the connection is encrypted.
  ///
  /// In en, this message translates to:
  /// **'Connection is secure'**
  String get browser_certConnectionSecure;

  /// Line under "Connection is secure". issuer is the name of the certificate authority.
  ///
  /// In en, this message translates to:
  /// **'Verified By: {issuer}'**
  String browser_certVerifiedBy(String issuer);

  /// Fallback name shown on the home page for a container without a name.
  ///
  /// In en, this message translates to:
  /// **'Container'**
  String get browser_containerFallbackName;

  /// Confirm button of the dialog enabling AI tab suggestions.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get browser_actionEnable;

  /// Title of the confirmation dialog before closing all shown private tabs.
  ///
  /// In en, this message translates to:
  /// **'Close All Private Tabs'**
  String get browser_closeAllPrivateTabsTitle;

  /// Body of that dialog.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close all displayed private tabs?'**
  String get browser_closeAllPrivateTabsContent;

  /// Title of the confirmation dialog before closing all shown tabs.
  ///
  /// In en, this message translates to:
  /// **'Close All Tabs'**
  String get browser_closeAllTabsTitle;

  /// Body of that dialog.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close all displayed tabs?'**
  String get browser_closeAllTabsContent;

  /// Title of the dialog before enabling on-device AI suggestions for grouping tabs.
  ///
  /// In en, this message translates to:
  /// **'Enable AI Tab Suggestions'**
  String get browser_enableAiTabSuggestionsTitle;

  /// Body of that dialog: AI model files may need to be downloaded. Keep the blank line (\n\n).
  ///
  /// In en, this message translates to:
  /// **'Enabling this feature may require downloading AI models. The download size and progress cannot be determined in advance.\n\nDo you want to continue?'**
  String get browser_enableAiTabSuggestionsContent;

  /// Tooltip of the button that expands a collapsed group of tabs in the tab overview.
  ///
  /// In en, this message translates to:
  /// **'Expand group'**
  String get browser_tooltipExpandGroup;

  /// Tooltip of the button that collapses a group of tabs in the tab overview.
  ///
  /// In en, this message translates to:
  /// **'Collapse group'**
  String get browser_tooltipCollapseGroup;

  /// Placeholder of the address bar: type a search or a web address.
  ///
  /// In en, this message translates to:
  /// **'Search or enter URL'**
  String get browser_searchOrEnterUrl;

  /// Message when a dragged tab is dropped where it is not allowed.
  ///
  /// In en, this message translates to:
  /// **'Tab cannot be moved here'**
  String get browser_tabCannotBeMovedHere;

  /// Android app shortcut (long-press on the app icon): open a new tab.
  ///
  /// In en, this message translates to:
  /// **'New Tab'**
  String get browser_quickActionNewTab;

  /// Android app shortcut (long-press on the app icon): open a new private tab.
  ///
  /// In en, this message translates to:
  /// **'New Private Tab'**
  String get browser_quickActionNewPrivateTab;

  /// Android app shortcut (long-press on the app icon): open a new isolated tab.
  ///
  /// In en, this message translates to:
  /// **'New Isolated Tab'**
  String get browser_quickActionNewIsolatedTab;

  /// Menu item or row that shares the page address.
  ///
  /// In en, this message translates to:
  /// **'Share Link'**
  String get browser_shareLink;

  /// Menu item or row that shows the page address as a QR code.
  ///
  /// In en, this message translates to:
  /// **'Show QR Code'**
  String get browser_showQrCode;

  /// Menu item that saves the page as a PDF file.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get browser_exportAsPdf;

  /// Error message when printing the page failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to print page'**
  String get browser_failedToPrintPage;

  /// Menu item that prints the page.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get browser_print;

  /// Menu item or row that shares a screenshot of the page.
  ///
  /// In en, this message translates to:
  /// **'Share Screenshot'**
  String get browser_shareScreenshot;

  /// Menu item that saves the page as a PNG image.
  ///
  /// In en, this message translates to:
  /// **'Export as PNG'**
  String get browser_exportAsPng;

  /// Menu item or row that opens the page in an installed app. appName is that app's name.
  ///
  /// In en, this message translates to:
  /// **'Open in {appName}'**
  String browser_openInNamedApp(String appName);

  /// Menu item or row that opens the page in an installed app, when its name is unknown.
  ///
  /// In en, this message translates to:
  /// **'Open in App'**
  String get browser_openInApp;

  /// Menu item or row that copies the page address.
  ///
  /// In en, this message translates to:
  /// **'Copy Address'**
  String get browser_copyAddress;

  /// Shown in the send-to-device list when no other synced device can receive tabs.
  ///
  /// In en, this message translates to:
  /// **'No target devices'**
  String get browser_noTargetDevices;

  /// Confirmation after sending the tab to another device. deviceName is that device's name.
  ///
  /// In en, this message translates to:
  /// **'Sent tab to {deviceName}'**
  String browser_sentTabToDevice(String deviceName);

  /// Error message when sending the tab to another device failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send tab'**
  String get browser_failedToSendTab;

  /// Placeholder while the list of synced devices loads.
  ///
  /// In en, this message translates to:
  /// **'Loading devices...'**
  String get browser_loadingDevices;

  /// Error when the list of synced devices could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Failed to load devices'**
  String get browser_failedToLoadDevices;

  /// Menu item or expandable row listing synced devices (Firefox Sync) to send the current tab to.
  ///
  /// In en, this message translates to:
  /// **'Send To Device'**
  String get browser_sendToDevice;

  /// Item in a container's menu: open a new tab in this container.
  ///
  /// In en, this message translates to:
  /// **'New Tab'**
  String get browser_containerMenuNewTab;

  /// Item in a container's menu: stop keeping this container at the top.
  ///
  /// In en, this message translates to:
  /// **'Unpin Container'**
  String get browser_unpinContainer;

  /// Item in a container's menu: keep this container at the top of lists.
  ///
  /// In en, this message translates to:
  /// **'Pin Container'**
  String get browser_pinContainer;

  /// Item in the "Close Tabs" submenu: close all tabs of this container or view.
  ///
  /// In en, this message translates to:
  /// **'All Tabs'**
  String get browser_closeSubmenuAllTabs;

  /// Item in the "Close Tabs" submenu: close only private tabs.
  ///
  /// In en, this message translates to:
  /// **'Private Tabs'**
  String get browser_closeSubmenuPrivateTabs;

  /// Item in the "Close Tabs" submenu: close only isolated tabs.
  ///
  /// In en, this message translates to:
  /// **'Isolated Tabs'**
  String get browser_closeSubmenuIsolatedTabs;

  /// Item in the "Close Tabs" submenu: close the tabs matching the current search filter.
  ///
  /// In en, this message translates to:
  /// **'Filtered Tabs'**
  String get browser_closeSubmenuFilteredTabs;

  /// Submenu in a container's menu with options for closing several tabs.
  ///
  /// In en, this message translates to:
  /// **'Close Tabs'**
  String get browser_menuCloseTabs;

  /// Item in a container's menu: bookmark all its tabs.
  ///
  /// In en, this message translates to:
  /// **'Bookmark all'**
  String get browser_menuBookmarkAll;

  /// Item in a container's menu: edit the websites that always open in it.
  ///
  /// In en, this message translates to:
  /// **'Assigned Sites…'**
  String get browser_menuAssignedSites;

  /// Item in a container's menu, and title of its dialog: delete the container's cookies and site data.
  ///
  /// In en, this message translates to:
  /// **'Clear Container Data'**
  String get browser_menuClearContainerData;

  /// Item in a container's menu: open the container editor.
  ///
  /// In en, this message translates to:
  /// **'Edit Container…'**
  String get browser_menuEditContainer;

  /// Item in a container's menu: delete the container.
  ///
  /// In en, this message translates to:
  /// **'Delete Container'**
  String get browser_menuDeleteContainer;

  /// Confirmation after bookmarking all tabs. count is the number of bookmarks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bookmark added} other{{count} bookmarks added}}'**
  String browser_bookmarksAddedCount(int count);

  /// Confirmation after clearing a container's data (its tabs were reopened).
  ///
  /// In en, this message translates to:
  /// **'Container data cleared successfully'**
  String get browser_containerDataClearedSuccess;

  /// Confirmation after clearing a container's data. count is how many of its tabs were closed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Container data cleared. 1 tab closed.} other{Container data cleared. {count} tabs closed.}}'**
  String browser_containerDataClearedWithTabsClosed(int count);

  /// Error message when clearing container data failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Error clearing data: {error}'**
  String browser_errorClearingData(String error);

  /// Section heading in the site info sheet for opening this site's links in installed apps.
  ///
  /// In en, this message translates to:
  /// **'App Links'**
  String get browser_appLinksSectionTitle;

  /// Row in that section with a choice of how links to this site open.
  ///
  /// In en, this message translates to:
  /// **'Open links for this site'**
  String get browser_openLinksForThisSite;

  /// Line under that row while its value is loading: the app-wide setting applies.
  ///
  /// In en, this message translates to:
  /// **'Follows the default'**
  String get browser_followsTheDefault;

  /// Choice in that row: use the app-wide setting for this site.
  ///
  /// In en, this message translates to:
  /// **'Follow default'**
  String get browser_followDefault;

  /// Choice in that row: always open this site's links in its app.
  ///
  /// In en, this message translates to:
  /// **'Open in app'**
  String get browser_openInAppOption;

  /// Choice in that row: always keep this site's links in the browser.
  ///
  /// In en, this message translates to:
  /// **'Keep in browser'**
  String get browser_keepInBrowser;

  /// Line under that row when no installed app handles this site.
  ///
  /// In en, this message translates to:
  /// **'No app found for this site'**
  String get browser_noAppFoundForSite;

  /// Line under that row. appName is the app's package name or "the app".
  ///
  /// In en, this message translates to:
  /// **'Always opens in {appName}'**
  String browser_alwaysOpensInApp(String appName);

  /// Fallback phrase inserted into "Always opens in {appName}" when the app is unknown. Lowercase.
  ///
  /// In en, this message translates to:
  /// **'the app'**
  String get browser_theAppFallback;

  /// Line under that row when this site's links always stay in the browser.
  ///
  /// In en, this message translates to:
  /// **'Always stays in the browser'**
  String get browser_alwaysStaysInBrowser;

  /// Line under that row: following the app-wide setting, which opens links in apps.
  ///
  /// In en, this message translates to:
  /// **'Follows the default: opens in apps'**
  String get browser_followsDefaultOpensInApps;

  /// Line under that row: following the app-wide setting, but no app handles this site.
  ///
  /// In en, this message translates to:
  /// **'Follows the default: no app found'**
  String get browser_followsDefaultNoAppFound;

  /// Line under that row: following the app-wide setting, which asks each time.
  ///
  /// In en, this message translates to:
  /// **'Follows the default: asks first'**
  String get browser_followsDefaultAsksFirst;

  /// Line under that row: following the app-wide setting, which keeps links in the browser.
  ///
  /// In en, this message translates to:
  /// **'Follows the default: stays in the browser'**
  String get browser_followsDefaultStaysInBrowser;

  /// Line under "Clear Site Data" while its options are expanded.
  ///
  /// In en, this message translates to:
  /// **'Select data types to clear'**
  String get browser_selectDataTypesToClear;

  /// Line under "Clear Site Data" while collapsed, listing what can be cleared.
  ///
  /// In en, this message translates to:
  /// **'Cookies, cache, and site data'**
  String get browser_cookiesCacheAndSiteData;

  /// Checkbox in the clear site data options: sign-in sessions for this site.
  ///
  /// In en, this message translates to:
  /// **'Auth Sessions'**
  String get browser_dataTypeAuthSessions;

  /// Explanation under "Auth Sessions".
  ///
  /// In en, this message translates to:
  /// **'Saved logins, active sessions'**
  String get browser_dataTypeAuthSessionsSubtitle;

  /// Checkbox in the clear site data options: everything the site stores (includes cookies and cache).
  ///
  /// In en, this message translates to:
  /// **'Site Data'**
  String get browser_dataTypeSiteData;

  /// Explanation under "Site Data".
  ///
  /// In en, this message translates to:
  /// **'Offline storage, databases, local files'**
  String get browser_dataTypeSiteDataSubtitle;

  /// Checkbox in the clear site data options: only cookies.
  ///
  /// In en, this message translates to:
  /// **'Cookies'**
  String get browser_dataTypeCookies;

  /// Explanation under "Cookies".
  ///
  /// In en, this message translates to:
  /// **'Login tokens, preferences, tracking data'**
  String get browser_dataTypeCookiesSubtitle;

  /// Checkbox in the clear site data options: only temporary copies of files.
  ///
  /// In en, this message translates to:
  /// **'Cached Files'**
  String get browser_dataTypeCachedFiles;

  /// Explanation under "Cached Files".
  ///
  /// In en, this message translates to:
  /// **'Images, scripts, stylesheets'**
  String get browser_dataTypeCachedFilesSubtitle;

  /// Checkbox in the clear site data options.
  ///
  /// In en, this message translates to:
  /// **'Close tab after clearing'**
  String get browser_closeTabAfterClearing;

  /// Explanation under that checkbox.
  ///
  /// In en, this message translates to:
  /// **'Close this tab once data is cleared'**
  String get browser_closeTabAfterClearingSubtitle;

  /// Label of the clear button while clearing runs.
  ///
  /// In en, this message translates to:
  /// **'Clearing...'**
  String get browser_clearingEllipsis;

  /// Button that clears the selected site data.
  ///
  /// In en, this message translates to:
  /// **'Clear Now'**
  String get browser_clearNow;

  /// Error when clearing site data with nothing selected.
  ///
  /// In en, this message translates to:
  /// **'Select at least one data type'**
  String get browser_selectAtLeastOneDataType;

  /// Confirmation after clearing site data.
  ///
  /// In en, this message translates to:
  /// **'Site data cleared'**
  String get browser_siteDataCleared;

  /// Error message when clearing site data failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear site data: {error}'**
  String browser_failedToClearSiteData(String error);

  /// Switch in the site info sheet: always load this site's desktop version.
  ///
  /// In en, this message translates to:
  /// **'Always use desktop site'**
  String get browser_alwaysUseDesktopSite;

  /// Line under a site setting when the page has no website domain (e.g. a local file).
  ///
  /// In en, this message translates to:
  /// **'Unavailable on this page'**
  String get browser_unavailableOnThisPage;

  /// Line under a site setting controlled by a broader rule. host is the domain the rule is for.
  ///
  /// In en, this message translates to:
  /// **'Set by a rule for {host}'**
  String browser_setByRuleFor(String host);

  /// Line under the desktop site switch when it is on.
  ///
  /// In en, this message translates to:
  /// **'This site always loads in desktop mode'**
  String get browser_siteAlwaysLoadsInDesktopMode;

  /// Line under the desktop site switch when it is off.
  ///
  /// In en, this message translates to:
  /// **'This site follows the default mode'**
  String get browser_siteFollowsDefaultMode;

  /// Error message when changing the desktop site setting failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to toggle desktop mode: {error}'**
  String browser_failedToToggleDesktopMode(String error);

  /// Switch in the site info sheet: allow drawn gestures on this site.
  ///
  /// In en, this message translates to:
  /// **'Gestures'**
  String get browser_gesturesTitle;

  /// Line under that switch when gestures are off in settings.
  ///
  /// In en, this message translates to:
  /// **'Gestures are turned off globally'**
  String get browser_gesturesTurnedOffGlobally;

  /// Line under that switch when the page has no website domain.
  ///
  /// In en, this message translates to:
  /// **'Gestures are unavailable on this page'**
  String get browser_gesturesUnavailableOnThisPage;

  /// Line under that switch when a broader rule turns gestures off. host is the domain the rule is for.
  ///
  /// In en, this message translates to:
  /// **'Disabled by a rule for {host}'**
  String browser_gesturesDisabledByRuleFor(String host);

  /// Line under that switch when it is off for this site.
  ///
  /// In en, this message translates to:
  /// **'Gestures are disabled on this site'**
  String get browser_gesturesDisabledOnThisSite;

  /// Line under that switch when it is on for this site.
  ///
  /// In en, this message translates to:
  /// **'Gestures are enabled on this site'**
  String get browser_gesturesEnabledOnThisSite;

  /// Error message when changing the gesture setting for this site failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to toggle gestures: {error}'**
  String browser_failedToToggleGestures(String error);

  /// Error when the site's permissions could not be loaded. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Error loading permissions: {error}'**
  String browser_errorLoadingPermissions(String error);

  /// Section heading in the site info sheet for permissions granted to this site (camera, location, etc.).
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get browser_permissionsSectionTitle;

  /// Button that shows all site permissions, including ones with default values; toggles with "Show less".
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get browser_showAll;

  /// Shown in the permissions section of the site info sheet when the site has no permission decisions.
  ///
  /// In en, this message translates to:
  /// **'No permissions set for this site'**
  String get browser_noPermissionsSetForSite;

  /// Option for a site permission: ask each time the site wants it.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get browser_permissionAsk;

  /// Option for a site permission: always allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get browser_permissionAllow;

  /// Option for a site permission: always block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get browser_permissionBlock;

  /// Row in the permissions section for whether media plays automatically on this site.
  ///
  /// In en, this message translates to:
  /// **'Autoplay'**
  String get browser_autoplayTitle;

  /// Autoplay option: let audio and video play automatically.
  ///
  /// In en, this message translates to:
  /// **'Allow All'**
  String get browser_autoplayAllowAll;

  /// Autoplay option: block only media with sound.
  ///
  /// In en, this message translates to:
  /// **'Block Audible'**
  String get browser_autoplayBlockAudible;

  /// Autoplay option: block all automatic playback.
  ///
  /// In en, this message translates to:
  /// **'Block All'**
  String get browser_autoplayBlockAll;

  /// Error when the tracking protection state for this site could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Failed to load tracking protection'**
  String get browser_failedToLoadTrackingProtection;

  /// Switch in the site info sheet for Firefox's tracker blocking on this site. "Enhanced Tracking Protection" is Mozilla's feature name; use Firefox's translation if available.
  ///
  /// In en, this message translates to:
  /// **'Enhanced Tracking Protection'**
  String get browser_enhancedTrackingProtection;

  /// Line under that switch when it is on.
  ///
  /// In en, this message translates to:
  /// **'Trackers on this site are being blocked'**
  String get browser_trackersBeingBlocked;

  /// Line under that switch when it is off for this site.
  ///
  /// In en, this message translates to:
  /// **'Trackers on this site are allowed'**
  String get browser_trackersAllowed;

  /// Error message when changing tracking protection for this site failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to toggle tracking protection: {error}'**
  String browser_failedToToggleTrackingProtection(String error);

  /// Screen-reader label of the handle for resizing the side tab panel.
  ///
  /// In en, this message translates to:
  /// **'Resize side panel'**
  String get browser_resizeSidePanel;

  /// Label of the group of tabs that belong to no container.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get browser_unassignedContainerLabel;

  /// Tooltip of the close button on a tab chip.
  ///
  /// In en, this message translates to:
  /// **'Close tab'**
  String get browser_tooltipCloseTab;

  /// Confirmation after tracking parameters were removed from the address being shared.
  ///
  /// In en, this message translates to:
  /// **'URL cleaned'**
  String get browser_urlCleaned;

  /// Confirmation after the chosen tracking parameters were removed from the address being shared.
  ///
  /// In en, this message translates to:
  /// **'URL preview applied'**
  String get browser_urlPreviewApplied;

  /// Warning in the share sheet. count is the number of tracking parameters found in the page address.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 tracking parameter detected} other{{count} tracking parameters detected}}'**
  String browser_trackingParametersDetected(int count);

  /// Note in the share sheet: the page address contains no tracking parameters.
  ///
  /// In en, this message translates to:
  /// **'Link is clean'**
  String get browser_linkIsClean;

  /// Tooltip of the button in the share sheet that removes tracking parameters.
  ///
  /// In en, this message translates to:
  /// **'Remove tracking'**
  String get browser_removeTrackingTooltip;

  /// Item of the tab menu: search for text on the page.
  ///
  /// In en, this message translates to:
  /// **'Find in Page'**
  String get browser_menuFindInPage;

  /// Item of the tab menu with a checkbox: simplified, easy-to-read view of the page.
  ///
  /// In en, this message translates to:
  /// **'Reader Mode'**
  String get browser_menuReaderMode;

  /// Item of the tab menu: look for news feeds (RSS/Atom) on the page.
  ///
  /// In en, this message translates to:
  /// **'Fetch Feeds on Page'**
  String get browser_menuFetchFeedsOnPage;

  /// Item of the tab menu: bookmark the page.
  ///
  /// In en, this message translates to:
  /// **'Add Bookmark'**
  String get browser_menuAddBookmark;

  /// Item in the tab menu's clone submenu: copy into a regular tab.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get browser_cloneRegular;

  /// Item in the tab menu's clone submenu: copy into a private tab.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get browser_clonePrivate;

  /// Item in the tab menu's clone submenu: copy into an isolated tab.
  ///
  /// In en, this message translates to:
  /// **'Isolated'**
  String get browser_cloneIsolated;

  /// Submenu of the tab menu for copying the current tab.
  ///
  /// In en, this message translates to:
  /// **'Clone Tab'**
  String get browser_menuCloneTab;

  /// Item in the tab menu's container submenu: move the tab into a container.
  ///
  /// In en, this message translates to:
  /// **'Assign Container'**
  String get browser_menuAssignContainer;

  /// Item in the tab menu's container submenu: link this site to a container so it always opens there.
  ///
  /// In en, this message translates to:
  /// **'URL relation'**
  String get browser_menuUrlRelation;

  /// Item in the tab menu's container submenu: remove this site's link to the container.
  ///
  /// In en, this message translates to:
  /// **'Unassign URL relation'**
  String get browser_menuUnassignUrlRelation;

  /// Item in the tab menu's container submenu: take the tab out of its container.
  ///
  /// In en, this message translates to:
  /// **'Unassign Container'**
  String get browser_menuUnassignContainer;

  /// Submenu of the tab menu with container actions.
  ///
  /// In en, this message translates to:
  /// **'Container'**
  String get browser_menuContainerSubmenu;

  /// Item in the tab menu's reorder submenu: move the tab one place up in the list.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get browser_menuMoveUp;

  /// Item in the tab menu's reorder submenu: move the tab one place down in the list.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get browser_menuMoveDown;

  /// Submenu of the tab menu for moving the tab in the list.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get browser_menuReorder;

  /// Submenu of the tab menu with sharing actions.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get browser_menuShare;

  /// Item in the tab menu's export submenu: copy the page text as Markdown.
  ///
  /// In en, this message translates to:
  /// **'Copy as Markdown'**
  String get browser_menuCopyAsMarkdown;

  /// Confirmation after copying the page as Markdown.
  ///
  /// In en, this message translates to:
  /// **'Markdown copied to clipboard'**
  String get browser_markdownCopiedToClipboard;

  /// Item in the tab menu's export submenu: save the page text as a Markdown file.
  ///
  /// In en, this message translates to:
  /// **'Export as Markdown'**
  String get browser_menuExportAsMarkdown;

  /// Submenu of the tab menu for saving the page in other formats.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get browser_menuExportSubmenu;

  /// Item of the tab menu: close the tab.
  ///
  /// In en, this message translates to:
  /// **'Close Tab'**
  String get browser_menuCloseTab;

  /// Item of the tab menu: reload the page.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get browser_menuReload;

  /// Item of the tab menu with a checkbox: request the desktop version of the website.
  ///
  /// In en, this message translates to:
  /// **'Desktop Mode'**
  String get browser_menuDesktopMode;

  /// Item of the tab menu: add the site to the Android home screen.
  ///
  /// In en, this message translates to:
  /// **'Add to Home Screen'**
  String get browser_menuAddToHomeScreen;

  /// Item in the tab menu's hierarchy submenu: choose which tab this tab is nested under.
  ///
  /// In en, this message translates to:
  /// **'Change parent…'**
  String get browser_menuChangeParent;

  /// Item in the tab menu's hierarchy submenu: stop nesting this tab under its parent tab.
  ///
  /// In en, this message translates to:
  /// **'Detach from parent'**
  String get browser_menuDetachFromParent;

  /// Submenu of the tab menu for tab nesting (parent and child tabs).
  ///
  /// In en, this message translates to:
  /// **'Hierarchy'**
  String get browser_menuHierarchy;

  /// Label of the translate item after the page was translated.
  ///
  /// In en, this message translates to:
  /// **'Translated'**
  String get browser_pageTranslated;

  /// Item of the tab menu, and title of the translation sheet: translate the page.
  ///
  /// In en, this message translates to:
  /// **'Translate Page'**
  String get browser_menuTranslatePage;

  /// Item of the tab menu for a pinned tab: unpin it.
  ///
  /// In en, this message translates to:
  /// **'Unpin tab'**
  String get browser_unpinTab;

  /// Item of the tab menu: pin the tab to the start of the tab bar.
  ///
  /// In en, this message translates to:
  /// **'Pin tab'**
  String get browser_pinTab;

  /// Generic error line in the parent tab picker. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String browser_errorGeneric(String error);

  /// Shown in the parent tab picker when the tab was closed meanwhile.
  ///
  /// In en, this message translates to:
  /// **'Tab no longer exists'**
  String get browser_tabNoLongerExists;

  /// Heading of the sheet for choosing which tab to nest this tab under.
  ///
  /// In en, this message translates to:
  /// **'Choose a parent tab'**
  String get browser_chooseAParentTab;

  /// Option in the parent tab picker: make the tab top-level.
  ///
  /// In en, this message translates to:
  /// **'Make standalone'**
  String get browser_makeStandalone;

  /// Explanation under "Make standalone".
  ///
  /// In en, this message translates to:
  /// **'Detach from current parent'**
  String get browser_detachFromCurrentParent;

  /// Shown in the parent tab picker when no other tab in the container can be the parent.
  ///
  /// In en, this message translates to:
  /// **'No candidate tabs in this container.'**
  String get browser_noCandidateTabsInContainer;

  /// First line of the clear container data dialog; a bulleted list follows.
  ///
  /// In en, this message translates to:
  /// **'This will clear all data for this container:'**
  String get browser_clearContainerDataIntro;

  /// Bullet in the clear container data list. Keep the "•" bullet.
  ///
  /// In en, this message translates to:
  /// **'• Cookies'**
  String get browser_bulletCookies;

  /// Bullet in the clear container data list. Keep the "•" bullet.
  ///
  /// In en, this message translates to:
  /// **'• Site data'**
  String get browser_bulletSiteData;

  /// Bullet in the clear container data list. Keep the "•" bullet.
  ///
  /// In en, this message translates to:
  /// **'• Cache'**
  String get browser_bulletCache;

  /// Bullet in the clear container data list. Keep the "•" bullet.
  ///
  /// In en, this message translates to:
  /// **'• Permissions'**
  String get browser_bulletPermissions;

  /// Warning in the clear container data dialog. count is the number of the container's tabs that will close.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 tab will be closed.} other{{count} tabs will be closed.}}'**
  String browser_tabsWillBeClosedCount(int count);

  /// Checkbox in that dialog: reopen the container's tabs after clearing.
  ///
  /// In en, this message translates to:
  /// **'Recreate tabs after clearing'**
  String get browser_recreateTabsAfterClearing;

  /// Confirm button of the clear container data dialog.
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get browser_actionClearData;

  /// Long-press menu item on a tab card: close all tabs from the same website. "Host" means the website's domain.
  ///
  /// In en, this message translates to:
  /// **'Close from Same Host'**
  String get browser_closeFromSameHost;

  /// Long-press menu item on a tab card: close the tab and all tabs opened from it.
  ///
  /// In en, this message translates to:
  /// **'Close Tab and Descendants'**
  String get browser_closeTabAndDescendants;

  /// Confirmation after unpinning a tab, with an Undo button.
  ///
  /// In en, this message translates to:
  /// **'Tab unpinned'**
  String get browser_tabUnpinned;

  /// Confirmation after creating a container by dropping one tab onto another. containerName is its name.
  ///
  /// In en, this message translates to:
  /// **'Created container \"{containerName}\"'**
  String browser_createdContainerNamed(String containerName);

  /// Fallback name inserted into that confirmation when the new container has no name.
  ///
  /// In en, this message translates to:
  /// **'New Container'**
  String get browser_newContainerFallback;

  /// Confirmation after nesting a dropped tab under another tab.
  ///
  /// In en, this message translates to:
  /// **'Assigned parent tab'**
  String get browser_assignedParentTab;

  /// Error when nesting a dropped tab under another tab failed.
  ///
  /// In en, this message translates to:
  /// **'Could not assign parent tab'**
  String get browser_couldNotAssignParentTab;

  /// Title of the sheet shown after dropping a tab onto another tab.
  ///
  /// In en, this message translates to:
  /// **'Drop tab onto tab'**
  String get browser_dropTabOntoTabTitle;

  /// Line under that title.
  ///
  /// In en, this message translates to:
  /// **'Choose how these tabs should be related.'**
  String get browser_chooseHowTabsRelated;

  /// Option in that sheet: put both tabs into a new container.
  ///
  /// In en, this message translates to:
  /// **'Create container'**
  String get browser_createContainerOption;

  /// Explanation under "Create container".
  ///
  /// In en, this message translates to:
  /// **'Create a new container with both tabs.'**
  String get browser_createContainerOptionSubtitle;

  /// Option in that sheet: nest the dragged tab under the other tab.
  ///
  /// In en, this message translates to:
  /// **'Assign new parent'**
  String get browser_assignNewParentOption;

  /// Explanation under "Assign new parent".
  ///
  /// In en, this message translates to:
  /// **'Make the dropped-on tab the parent.'**
  String get browser_assignNewParentOptionSubtitle;

  /// Message when trying to reorder tabs while a sort order other than manual is active.
  ///
  /// In en, this message translates to:
  /// **'Tab reordering is only available in default manual mode'**
  String get browser_tabReorderingOnlyInDefaultMode;

  /// Tooltip of the button that searches the text of open tabs.
  ///
  /// In en, this message translates to:
  /// **'Search inside tabs'**
  String get browser_tooltipSearchInsideTabs;

  /// Submenu of the tab overview filter menu: show only a kind of tab.
  ///
  /// In en, this message translates to:
  /// **'Tab Type'**
  String get browser_filterTabType;

  /// Checkbox item in the sort submenu: list pinned tabs first.
  ///
  /// In en, this message translates to:
  /// **'Sort Pinned First'**
  String get browser_sortPinnedFirst;

  /// Submenu of the tab overview filter menu for sort order.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get browser_filterSort;

  /// Checkbox item in the filter menu: show child tabs nested under their parents.
  ///
  /// In en, this message translates to:
  /// **'Hierarchical View'**
  String get browser_hierarchicalView;

  /// Filter menu item that opens a date range picker; replaced by the chosen range once set.
  ///
  /// In en, this message translates to:
  /// **'Filter Date'**
  String get browser_filterDate;

  /// Submenu of the filter menu with preset time ranges (last hour, last day…).
  ///
  /// In en, this message translates to:
  /// **'Quick Interval'**
  String get browser_quickInterval;

  /// Filter menu item that clears all tab filters.
  ///
  /// In en, this message translates to:
  /// **'Reset Filter'**
  String get browser_resetFilter;

  /// Tooltip of the button that opens the tab filter and sort menu.
  ///
  /// In en, this message translates to:
  /// **'Filter & Sort'**
  String get browser_tooltipFilterAndSort;

  /// Tooltip of the button that switches between list, grid and tree views of tabs.
  ///
  /// In en, this message translates to:
  /// **'Change view mode'**
  String get browser_tooltipChangeViewMode;

  /// Tooltip of the AI suggestions button while AI model files download. percent is the progress; keep the "%" sign in your locale's format.
  ///
  /// In en, this message translates to:
  /// **'Downloading AI models ({percent}%)'**
  String browser_downloadingAiModelsProgress(int percent);

  /// Tooltip of the AI suggestions button while suggestions are on.
  ///
  /// In en, this message translates to:
  /// **'Disable AI tab suggestions'**
  String get browser_disableAiTabSuggestions;

  /// Tooltip of the AI suggestions button while suggestions are off.
  ///
  /// In en, this message translates to:
  /// **'Enable AI tab suggestions'**
  String get browser_enableAiTabSuggestionsTooltip;

  /// Tooltip of the reorder button while tab reordering is on.
  ///
  /// In en, this message translates to:
  /// **'Disable reordering mode'**
  String get browser_disableReorderingMode;

  /// Tooltip of the reorder button while tab reordering is off.
  ///
  /// In en, this message translates to:
  /// **'Enable reordering mode'**
  String get browser_enableReorderingMode;

  /// Tooltip of the disabled reorder button when a sort order other than manual is active.
  ///
  /// In en, this message translates to:
  /// **'Reordering requires default manual mode'**
  String get browser_reorderingRequiresDefaultManualMode;

  /// Hint shown after turning tab reordering on.
  ///
  /// In en, this message translates to:
  /// **'Drag and drop tabs to reorder them'**
  String get browser_dragAndDropTabsToReorder;

  /// Tooltip of the menu button with actions for the tabs shown (close all, bookmark all…).
  ///
  /// In en, this message translates to:
  /// **'Tab actions'**
  String get browser_tooltipTabActions;

  /// Placeholder of the tab search field in the tab overview.
  ///
  /// In en, this message translates to:
  /// **'Search tabs'**
  String get browser_hintSearchTabs;

  /// Shown in the synced tabs view when no tabs from other devices are available.
  ///
  /// In en, this message translates to:
  /// **'No synced tabs available'**
  String get browser_noSyncedTabsAvailable;

  /// Error when tabs from other devices could not be loaded. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to load synced tabs: {error}'**
  String browser_failedToLoadSyncedTabs(String error);

  /// Label of the source language drop-down in the translation sheet.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get browser_translateFromLabel;

  /// Label of the target language drop-down in the translation sheet.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get browser_translateToLabel;

  /// Error in the translation sheet. error is the engine's technical error name (English).
  ///
  /// In en, this message translates to:
  /// **'Translation error: {error}'**
  String browser_translationError(String error);

  /// Error when showing the untranslated page again failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore the page'**
  String get browser_failedToRestorePage;

  /// Button in the translation sheet that shows the untranslated page.
  ///
  /// In en, this message translates to:
  /// **'Show Original'**
  String get browser_showOriginal;

  /// Error message when translating the page failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to translate the page'**
  String get browser_failedToTranslatePage;

  /// Button in the translation sheet that translates again with the chosen languages.
  ///
  /// In en, this message translates to:
  /// **'Retranslate'**
  String get browser_retranslate;

  /// Button in the translation sheet that starts translating.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get browser_translateAction;

  /// Tab kind filter option: show all tabs.
  ///
  /// In en, this message translates to:
  /// **'All Tabs'**
  String get browser_tabTypeFilterAll;

  /// Tab kind filter option: show only regular tabs.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get browser_tabTypeFilterRegular;

  /// Tab kind filter option: show only private tabs.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get browser_tabTypeFilterPrivate;

  /// Tab kind filter option: show only isolated tabs.
  ///
  /// In en, this message translates to:
  /// **'Isolated'**
  String get browser_tabTypeFilterIsolated;

  /// Tab sort option: manual order.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get browser_tabSortDefault;

  /// Tab sort option: by title, A to Z.
  ///
  /// In en, this message translates to:
  /// **'Title A-Z'**
  String get browser_tabSortTitleAsc;

  /// Tab sort option: by title, Z to A.
  ///
  /// In en, this message translates to:
  /// **'Title Z-A'**
  String get browser_tabSortTitleDesc;

  /// Tab sort option: by web address, A to Z.
  ///
  /// In en, this message translates to:
  /// **'URL A-Z'**
  String get browser_tabSortUrlAsc;

  /// Tab sort option: by web address, Z to A.
  ///
  /// In en, this message translates to:
  /// **'URL Z-A'**
  String get browser_tabSortUrlDesc;

  /// Tab sort option: newest tabs first.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get browser_tabSortNewestFirst;

  /// Tab sort option: oldest tabs first.
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get browser_tabSortOldestFirst;

  /// Quick time filter for tabs used in the last hour.
  ///
  /// In en, this message translates to:
  /// **'Last Hour'**
  String get browser_tabIntervalLastHour;

  /// Quick time filter for tabs used in the last 3 hours.
  ///
  /// In en, this message translates to:
  /// **'Last 3 Hours'**
  String get browser_tabIntervalLast3Hours;

  /// Quick time filter for tabs used in the last 8 hours.
  ///
  /// In en, this message translates to:
  /// **'Last 8 Hours'**
  String get browser_tabIntervalLast8Hours;

  /// Quick time filter for tabs used in the last 24 hours.
  ///
  /// In en, this message translates to:
  /// **'Last Day'**
  String get browser_tabIntervalLastDay;

  /// Quick time filter for tabs used in the last 3 days.
  ///
  /// In en, this message translates to:
  /// **'Last 3 Days'**
  String get browser_tabIntervalLast3Days;

  /// Quick time filter for tabs used in the last 7 days.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get browser_tabIntervalLastWeek;

  /// Quick time filter for tabs used in the last month.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get browser_tabIntervalLastMonth;

  /// Tab overview layout option: list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get browser_tabsViewModeList;

  /// Tab overview layout option: grid of tab previews.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get browser_tabsViewModeGrid;

  /// Tab overview layout option: tree of parent and child tabs.
  ///
  /// In en, this message translates to:
  /// **'Tree'**
  String get browser_tabsViewModeTree;

  /// Name of a site permission in the site info sheet.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get browser_permissionCamera;

  /// Name of a site permission in the site info sheet.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get browser_permissionMicrophone;

  /// Name of a site permission in the site info sheet: access to the device's location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get browser_permissionLocation;

  /// Name of a site permission in the site info sheet: showing notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get browser_permissionNotification;

  /// Name of a site permission: keep the site's stored data even when space runs low.
  ///
  /// In en, this message translates to:
  /// **'Persistent Storage'**
  String get browser_permissionPersistentStorage;

  /// Name of a site permission: let embedded content from other sites use its storage (storage access).
  ///
  /// In en, this message translates to:
  /// **'Cross-Origin Storage'**
  String get browser_permissionCrossOriginStorage;

  /// Name of a site permission: play copy-protected (DRM) media. DRM is a technical abbreviation.
  ///
  /// In en, this message translates to:
  /// **'Media Key System (DRM)'**
  String get browser_permissionMediaKeySystem;

  /// Message when trying to drag a tab while the tab overview is filtered or searched.
  ///
  /// In en, this message translates to:
  /// **'Clear the tab view filter or search to reorder tabs'**
  String get browser_tabReorderBlockedMessage;

  /// Tooltip of the toolbar button that opens the home page.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get contextualToolbar_tooltipHome;

  /// Tooltip of the toolbar button that hides the tab bar; a floating button brings it back.
  ///
  /// In en, this message translates to:
  /// **'Hide tab bar'**
  String get contextualToolbar_tooltipHideTabBar;

  /// Tooltip of the toolbar button that deletes browsing data (history, cookies, cache).
  ///
  /// In en, this message translates to:
  /// **'Clear browsing data'**
  String get contextualToolbar_tooltipClearBrowsingData;

  /// Tooltip of the toolbar bookmark button when the current page is not bookmarked.
  ///
  /// In en, this message translates to:
  /// **'Add bookmark'**
  String get contextualToolbar_tooltipAddBookmark;

  /// Tooltip of the toolbar bookmark button when the current page is already bookmarked.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get contextualToolbar_tooltipRemoveBookmark;

  /// Tooltip of the toolbar button that turns swipe gestures on, shown while they are off.
  ///
  /// In en, this message translates to:
  /// **'Enable gestures'**
  String get contextualToolbar_tooltipEnableGestures;

  /// Tooltip of the toolbar button that turns swipe gestures off, shown while they are on.
  ///
  /// In en, this message translates to:
  /// **'Disable gestures'**
  String get contextualToolbar_tooltipDisableGestures;

  /// Item in the long-press menu of the toolbar reload button: reload the page ignoring cached copies.
  ///
  /// In en, this message translates to:
  /// **'Hard Refresh'**
  String get contextualToolbar_actionHardRefresh;

  /// Item in the long-press menu of the toolbar close-tab button: close all tabs except the current one.
  ///
  /// In en, this message translates to:
  /// **'Close Others'**
  String get contextualToolbar_actionCloseOthers;

  /// Item in the long-press menu of the toolbar close-tab button: close all tabs from the same website as the current one. "Host" means the website's domain.
  ///
  /// In en, this message translates to:
  /// **'Close from Same Host'**
  String get contextualToolbar_actionCloseFromSameHost;

  /// Item in the long-press menu of the toolbar close-tab button: close the current tab and every tab opened from it (its child tabs, their children, and so on).
  ///
  /// In en, this message translates to:
  /// **'Close Tab and Descendants'**
  String get contextualToolbar_actionCloseTabAndDescendants;

  /// Item in the long-press menu of the toolbar bookmarks button: bookmark the current page.
  ///
  /// In en, this message translates to:
  /// **'Add Bookmark'**
  String get contextualToolbar_actionAddBookmark;

  /// Item in the long-press menu of the toolbar bookmarks button: remove the current page's bookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove Bookmark'**
  String get contextualToolbar_actionRemoveBookmark;

  /// Item in the long-press menu of the toolbar duplicate-tab button: copy the current tab into a new regular tab.
  ///
  /// In en, this message translates to:
  /// **'Clone as Regular'**
  String get contextualToolbar_actionCloneAsRegular;

  /// Item in the long-press menu of the toolbar duplicate-tab button: copy the current tab into a new private tab.
  ///
  /// In en, this message translates to:
  /// **'Clone as Private'**
  String get contextualToolbar_actionCloneAsPrivate;

  /// Item in the long-press menu of the toolbar duplicate-tab button: copy the current tab into a new isolated tab (with its own separate cookies and site data).
  ///
  /// In en, this message translates to:
  /// **'Clone as Isolated'**
  String get contextualToolbar_actionCloneAsIsolated;

  /// Confirmation after the current page was bookmarked from the toolbar.
  ///
  /// In en, this message translates to:
  /// **'Bookmark added'**
  String get contextualToolbar_bookmarkAdded;

  /// Confirmation after the current page's bookmark was removed from the toolbar.
  ///
  /// In en, this message translates to:
  /// **'Bookmark removed'**
  String get contextualToolbar_bookmarkRemoved;

  /// Message when a text size toolbar button is tapped while automatic font size is on: it must be turned off in settings first.
  ///
  /// In en, this message translates to:
  /// **'Disable automatic font size in settings to adjust manually'**
  String get contextualToolbar_fontSizeAutoAdjustmentHint;

  /// Name of the Back toolbar button (previous page), shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get contextualToolbar_buttonLabelBack;

  /// Name of the Forward toolbar button (next page), shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get contextualToolbar_buttonLabelForward;

  /// Name of the Home toolbar button, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get contextualToolbar_buttonLabelHome;

  /// Name of the toolbar button that opens browsing history, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get contextualToolbar_buttonLabelHistory;

  /// Name of the toolbar button that opens the bookmarks list, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get contextualToolbar_buttonLabelBookmarks;

  /// Name of the toolbar button that bookmarks or un-bookmarks the current page, shown in toolbar customization. Verb or noun as fits a button name.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get contextualToolbar_buttonLabelBookmarkToggle;

  /// Name of the toolbar button that shares the current page, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get contextualToolbar_buttonLabelShare;

  /// Name of the toolbar button that opens a new tab, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'New Tab'**
  String get contextualToolbar_buttonLabelAddTab;

  /// Name of the toolbar button that shows the number of open tabs and opens the tab overview, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Tabs'**
  String get contextualToolbar_buttonLabelTabsCount;

  /// Name of the toolbar button that opens the main browser menu, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get contextualToolbar_buttonLabelNavigationMenu;

  /// Name of the toolbar button that reloads the page, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get contextualToolbar_buttonLabelReload;

  /// Name of the toolbar button that shows the page as simplified, easy-to-read text, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Reader Mode'**
  String get contextualToolbar_buttonLabelReaderMode;

  /// Name of the toolbar button that requests the desktop version of the website, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Desktop Site'**
  String get contextualToolbar_buttonLabelDesktop;

  /// Name of the toolbar button that translates the page, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get contextualToolbar_buttonLabelTranslation;

  /// Name of the toolbar button that searches for text on the page, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Find in Page'**
  String get contextualToolbar_buttonLabelFindInPage;

  /// Name of the toolbar button that closes the current tab, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Close Tab'**
  String get contextualToolbar_buttonLabelCloseTab;

  /// Name of the toolbar item that shows the address field for typing a web address or search, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Address Bar'**
  String get contextualToolbar_buttonLabelInputUrl;

  /// Name of the toolbar button that scans a QR code with the camera, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get contextualToolbar_buttonLabelQrScan;

  /// Name of the toolbar button that starts a search by voice, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Voice Search'**
  String get contextualToolbar_buttonLabelVoiceSearch;

  /// Name of the toolbar button that copies the current tab into a new tab, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Tab'**
  String get contextualToolbar_buttonLabelDuplicateTab;

  /// Name of the toolbar button that makes page text larger, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Increase Font'**
  String get contextualToolbar_buttonLabelIncreaseFont;

  /// Name of the toolbar button that makes page text smaller, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Decrease Font'**
  String get contextualToolbar_buttonLabelDecreaseFont;

  /// Name of the toolbar button that sends the app to the background (like pressing Home), shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get contextualToolbar_buttonLabelMoveToBackground;

  /// Name of the toolbar button that turns swipe gestures on or off, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Gestures'**
  String get contextualToolbar_buttonLabelToggleGestures;

  /// Name of the toolbar button that hides the tab bar, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Hide Tab Bar'**
  String get contextualToolbar_buttonLabelHideTabBar;

  /// Name of the toolbar button that scrolls the page up by one screen, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Page Up'**
  String get contextualToolbar_buttonLabelPageUp;

  /// Name of the toolbar button that scrolls the page down by one screen, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Page Down'**
  String get contextualToolbar_buttonLabelPageDown;

  /// Name of the toolbar button for adjusting the page's text size, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get contextualToolbar_buttonLabelFont;

  /// Name of the toolbar button that opens the menu of installed browser extensions, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Extensions'**
  String get contextualToolbar_buttonLabelExtensionShortcut;

  /// Name of the toolbar button that deletes browsing data, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get contextualToolbar_buttonLabelClearBrowsingData;

  /// Name of the toolbar button that closes the app completely, shown in toolbar customization.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get contextualToolbar_buttonLabelQuit;

  /// Description, in toolbar customization, of what long-pressing the Back button does: shows a list of previous pages in this tab.
  ///
  /// In en, this message translates to:
  /// **'History Menu (Previous pages)'**
  String get contextualToolbar_longPressBackHistoryMenu;

  /// Description, in toolbar customization, of what long-pressing the Forward button does: shows a list of later pages in this tab.
  ///
  /// In en, this message translates to:
  /// **'History Menu (Forward pages)'**
  String get contextualToolbar_longPressForwardHistoryMenu;

  /// Description, in toolbar customization, of what long-pressing the bookmark button does: opens the bookmarks list.
  ///
  /// In en, this message translates to:
  /// **'Open Bookmarks'**
  String get contextualToolbar_longPressOpenBookmarks;

  /// Description, in toolbar customization, of an option offered by long-pressing the new-tab or tab-count button: open a new regular tab.
  ///
  /// In en, this message translates to:
  /// **'Add Regular Tab'**
  String get contextualToolbar_longPressAddRegularTab;

  /// Description, in toolbar customization, of an option offered by long-pressing the new-tab or tab-count button: open a new tab nested under the current tab.
  ///
  /// In en, this message translates to:
  /// **'Add Child Tab'**
  String get contextualToolbar_longPressAddChildTab;

  /// Description, in toolbar customization, of an option offered by long-pressing the new-tab or tab-count button: open a new private tab.
  ///
  /// In en, this message translates to:
  /// **'Add Private Tab'**
  String get contextualToolbar_longPressAddPrivateTab;

  /// Description, in toolbar customization, of an option offered by long-pressing the new-tab or tab-count button: open a new isolated tab (with its own separate cookies and site data).
  ///
  /// In en, this message translates to:
  /// **'Add Isolated Tab'**
  String get contextualToolbar_longPressAddIsolatedTab;

  /// Description, in toolbar customization, of what long-pressing the menu button does: opens settings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get contextualToolbar_longPressOpenSettings;

  /// Description, in toolbar customization, of what long-pressing the reload button does: reload without using cached copies.
  ///
  /// In en, this message translates to:
  /// **'Hard Refresh (bypass cache)'**
  String get contextualToolbar_longPressHardRefresh;

  /// Description, in toolbar customization, of what long-pressing the translate button does: shows language and translation options.
  ///
  /// In en, this message translates to:
  /// **'Show Translation Options'**
  String get contextualToolbar_longPressShowTranslationOptions;

  /// Description, in toolbar customization, of what long-pressing the Page Up button does.
  ///
  /// In en, this message translates to:
  /// **'Scroll to Top'**
  String get contextualToolbar_longPressScrollToTop;

  /// Description, in toolbar customization, of what long-pressing the Page Down button does.
  ///
  /// In en, this message translates to:
  /// **'Scroll to Bottom'**
  String get contextualToolbar_longPressScrollToBottom;

  /// Description, in toolbar customization, of what long-pressing the extensions button does: opens the menu of installed extensions.
  ///
  /// In en, this message translates to:
  /// **'Extensions Menu'**
  String get contextualToolbar_longPressExtensionsMenu;

  /// Description, in toolbar customization, of what long-pressing the Quit button does: closes the app without asking first.
  ///
  /// In en, this message translates to:
  /// **'Quit without confirmation'**
  String get contextualToolbar_longPressQuitWithoutConfirmation;

  /// Name of a section of the main browser menu with on/off toggles (desktop site, reader mode, gestures); shown when customizing the menu.
  ///
  /// In en, this message translates to:
  /// **'Quick Toggles'**
  String get menu_sectionQuickToggles;

  /// Name of the browser menu section with actions on the current page; shown when customizing the menu.
  ///
  /// In en, this message translates to:
  /// **'Page Actions'**
  String get menu_sectionPageActions;

  /// Name of the browser menu section listing browser extensions; shown when customizing the menu.
  ///
  /// In en, this message translates to:
  /// **'Extensions'**
  String get menu_sectionExtensions;

  /// Name of the browser menu section with actions on the current tab (share, clone, export…); shown when customizing the menu.
  ///
  /// In en, this message translates to:
  /// **'Tab Actions'**
  String get menu_sectionTabActions;

  /// Name of the browser menu section with links to history, bookmarks and other screens; shown when customizing the menu.
  ///
  /// In en, this message translates to:
  /// **'Quick Links'**
  String get menu_sectionQuickLinks;

  /// Name of the browser menu section showing how the tab connects (proxy/Tor routing); shown when customizing the menu.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get menu_sectionConnection;

  /// Name of the browser menu section with profile switching, sync and settings; shown when customizing the menu.
  ///
  /// In en, this message translates to:
  /// **'Profile & App'**
  String get menu_sectionProfile;

  /// Name of the browser menu section with app information; shown when customizing the menu.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get menu_sectionAbout;

  /// Browser menu toggle and its name in menu customization: request the desktop version of the website. Keep it short (shown under an icon).
  ///
  /// In en, this message translates to:
  /// **'Desktop'**
  String get menu_itemDesktopMode;

  /// Browser menu toggle and its name in menu customization: simplified, easy-to-read view of the page. Keep it short (shown under an icon).
  ///
  /// In en, this message translates to:
  /// **'Reader'**
  String get menu_itemReaderMode;

  /// Browser menu toggle and its name in menu customization: turn drawn gestures on or off. Keep it short (shown under an icon).
  ///
  /// In en, this message translates to:
  /// **'Gestures'**
  String get menu_itemGestures;

  /// Browser menu row and its name in menu customization: bookmark the current page.
  ///
  /// In en, this message translates to:
  /// **'Add Bookmark'**
  String get menu_itemAddBookmark;

  /// Browser menu row and its name in menu customization: search for text on the page.
  ///
  /// In en, this message translates to:
  /// **'Find in Page'**
  String get menu_itemFindInPage;

  /// Browser menu row and its name in menu customization: translate the page.
  ///
  /// In en, this message translates to:
  /// **'Translate Page'**
  String get menu_itemTranslatePage;

  /// Browser menu row and its name in menu customization: add the site to the Android home screen.
  ///
  /// In en, this message translates to:
  /// **'Add to Home Screen'**
  String get menu_itemAddToHomeScreen;

  /// Browser menu row and its name in menu customization: open the page in the installed app that handles it.
  ///
  /// In en, this message translates to:
  /// **'Open in App'**
  String get menu_itemOpenInApp;

  /// Name, in menu customization, of the expandable browser menu group with container actions.
  ///
  /// In en, this message translates to:
  /// **'Containers'**
  String get menu_itemContainers;

  /// Name, in menu customization, of the menu row that opens the container list.
  ///
  /// In en, this message translates to:
  /// **'Manage Containers'**
  String get menu_itemManageContainers;

  /// Name, in menu customization, of the menu row that moves the current tab into a container.
  ///
  /// In en, this message translates to:
  /// **'Assign Container'**
  String get menu_itemAssignContainer;

  /// Name, in menu customization, of the menu row that makes the current site always open in the tab's container.
  ///
  /// In en, this message translates to:
  /// **'Assign URL to Container'**
  String get menu_itemAssignUrlToContainer;

  /// Name, in menu customization, of the menu row that removes the current site from the container's assigned sites.
  ///
  /// In en, this message translates to:
  /// **'Unassign URL from Container'**
  String get menu_itemUnassignUrlFromContainer;

  /// Name, in menu customization, of the menu row that takes the current tab out of its container.
  ///
  /// In en, this message translates to:
  /// **'Unassign Container'**
  String get menu_itemUnassignContainer;

  /// Name, in menu customization, of the expandable browser menu group with sharing actions.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get menu_itemShare;

  /// Name, in menu customization, of the menu row that copies the page address.
  ///
  /// In en, this message translates to:
  /// **'Copy Address'**
  String get menu_itemCopyAddress;

  /// Name, in menu customization, of the menu row that shares a screenshot of the page.
  ///
  /// In en, this message translates to:
  /// **'Share Screenshot'**
  String get menu_itemShareScreenshot;

  /// Name, in menu customization, of the menu row that shares the page address.
  ///
  /// In en, this message translates to:
  /// **'Share Link'**
  String get menu_itemShareLink;

  /// Name, in menu customization, of the menu row that sends the tab to another device via sync.
  ///
  /// In en, this message translates to:
  /// **'Send To Device'**
  String get menu_itemSendToDevice;

  /// Name, in menu customization, of the menu row that shows the page address as a QR code.
  ///
  /// In en, this message translates to:
  /// **'Show QR Code'**
  String get menu_itemShowQrCode;

  /// Name, in menu customization, of a row that collapses the rows after it behind "More".
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get menu_itemMoreDisclosure;

  /// Name, in menu customization, of the expandable menu group for copying the current tab.
  ///
  /// In en, this message translates to:
  /// **'Clone Tab'**
  String get menu_itemCloneTab;

  /// Name, in menu customization, of the clone option that copies the tab into a regular tab.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get menu_itemCloneRegularTab;

  /// Name, in menu customization, of the clone option that copies the tab into a private tab.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get menu_itemClonePrivateTab;

  /// Name, in menu customization, of the clone option that copies the tab into an isolated tab (own separate cookies and site data).
  ///
  /// In en, this message translates to:
  /// **'Isolated'**
  String get menu_itemCloneIsolatedTab;

  /// Name, in menu customization, of the expandable menu group for saving the page in other formats.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get menu_itemExport;

  /// Name, in menu customization, of the menu row that copies the page text as Markdown. Markdown is a text format name.
  ///
  /// In en, this message translates to:
  /// **'Copy as Markdown'**
  String get menu_itemCopyAsMarkdown;

  /// Name, in menu customization, of the menu row that saves the page text as a Markdown file.
  ///
  /// In en, this message translates to:
  /// **'Export as Markdown'**
  String get menu_itemExportAsMarkdown;

  /// Name, in menu customization, of the menu row that saves the page as a PDF file.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get menu_itemExportAsPdf;

  /// Name, in menu customization, of the menu row that saves the page as a PNG image.
  ///
  /// In en, this message translates to:
  /// **'Export as PNG'**
  String get menu_itemExportAsPng;

  /// Name, in menu customization, of the menu row that prints the page.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get menu_itemPrintPage;

  /// Name, in menu customization, of the menu row that pins the site to the home screen shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Pin to Shortcuts'**
  String get menu_itemPinTopSite;

  /// Name, in menu customization, of the menu row that looks for news feeds (RSS/Atom) on the page.
  ///
  /// In en, this message translates to:
  /// **'Fetch Feeds'**
  String get menu_itemFetchFeeds;

  /// Browser menu link and its name in menu customization: opens browsing history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get menu_itemHistory;

  /// Browser menu link and its name in menu customization: opens bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get menu_itemBookmarks;

  /// Browser menu link and its name in menu customization: opens downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get menu_itemDownloads;

  /// Browser menu link and its name in menu customization: opens bang search shortcuts. Keep "Bangs" consistent with the bangs feature.
  ///
  /// In en, this message translates to:
  /// **'Bangs'**
  String get menu_itemBangs;

  /// Browser menu link and its name in menu customization: opens subscribed news feeds.
  ///
  /// In en, this message translates to:
  /// **'Feeds'**
  String get menu_itemFeeds;

  /// Browser menu link and its name in menu customization: opens Small Web discovery. Keep consistent with the Small Web feature.
  ///
  /// In en, this message translates to:
  /// **'Small Web'**
  String get menu_itemSmallWeb;

  /// Browser menu link and its name in menu customization: opens the delete browsing data dialog. Shown under an icon in a four-column grid: keep it to about 10 characters.
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get menu_itemClearData;

  /// Name, in menu customization, of the menu row showing the current profile; tapping it switches profiles.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get menu_itemProfileSwitch;

  /// Browser menu row and its name in menu customization: run Firefox Sync now.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get menu_itemSyncNow;

  /// Browser menu row and its name in menu customization: open settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menu_itemAppSettings;

  /// Browser menu row and its name in menu customization: close the app completely.
  ///
  /// In en, this message translates to:
  /// **'Quit Browser'**
  String get menu_itemQuitBrowser;

  /// Browser menu row and its name in menu customization: show app information.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get menu_itemAbout;

  /// Explanation, in menu customization, of the "More" row. "More" must match the translation of that row's name.
  ///
  /// In en, this message translates to:
  /// **'Folds everything below it behind a \"More\" row'**
  String get menu_itemMoreDisclosureDescription;

  /// Explanation, in menu customization, of the "Send To Device" row: the list of devices comes from the Firefox Sync account.
  ///
  /// In en, this message translates to:
  /// **'The devices themselves come from your account'**
  String get menu_itemSendToDeviceDescription;

  /// Tooltip of the eye button in menu customization while a row is visible: hide it from the menu.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get menu_reorderHideTooltip;

  /// Tooltip of the eye button in menu customization while a row is hidden: show it in the menu.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get menu_reorderShowTooltip;

  /// Summary under a section in menu customization. shown is how many rows are visible; total is how many rows the section has.
  ///
  /// In en, this message translates to:
  /// **'{total, plural, =1{{shown} of 1 row shown} other{{shown} of {total} rows shown}}'**
  String menu_reorderRowsShown(int shown, int total);

  /// Heading of the menu customization view.
  ///
  /// In en, this message translates to:
  /// **'Customize Menu'**
  String get menu_reorderDefaultTitle;

  /// Instruction under the menu customization heading at the section level.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder. Switch a section off to hide it from the menu.'**
  String get menu_reorderSubtitleSections;

  /// Instruction under the heading while editing the rows of one section.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder the rows in this section.'**
  String get menu_reorderSubtitleSectionRows;

  /// Instruction under the heading while editing the rows inside an expandable row.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder the rows this one opens.'**
  String get menu_reorderSubtitleItemRows;

  /// Tooltip of the back button in menu customization: return to the list of sections.
  ///
  /// In en, this message translates to:
  /// **'Back to sections'**
  String get menu_reorderBackTooltip;

  /// Menu item that restores the default menu layout.
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get menu_reorderResetToDefaults;

  /// Button at the bottom of the browser menu that opens menu customization.
  ///
  /// In en, this message translates to:
  /// **'Customize menu'**
  String get menu_customizeMenuButton;

  /// Label of the navigation button while a page loads: stop loading. Keep it short (shown under an icon).
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get menu_navStop;

  /// Label of the navigation button in the browser menu: previous page. Keep it short (shown under an icon).
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get menu_navBack;

  /// Label of the navigation button in the browser menu: next page. Keep it short (shown under an icon).
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get menu_navForward;

  /// Label of the button in the browser menu that closes the current tab; long-press shows more close options. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Close Tab'**
  String get menu_navCloseTab;

  /// Label of the reload button in the browser menu; long-press offers a hard refresh. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get menu_navReload;

  /// Long-press option of the close-tab button: close all tabs except the current one.
  ///
  /// In en, this message translates to:
  /// **'Close Others'**
  String get menu_navCloseOthers;

  /// Long-press option of the close-tab button: close all tabs from the same website. "Host" means the website's domain.
  ///
  /// In en, this message translates to:
  /// **'Close from Same Host'**
  String get menu_navCloseFromSameHost;

  /// Long-press option of the close-tab button: close the current tab and all tabs opened from it.
  ///
  /// In en, this message translates to:
  /// **'Close Tab and Descendants'**
  String get menu_navCloseTabAndDescendants;

  /// Long-press option of the reload button: reload ignoring cached copies.
  ///
  /// In en, this message translates to:
  /// **'Hard Refresh'**
  String get menu_navHardRefresh;

  /// Line under the profile name in the browser menu.
  ///
  /// In en, this message translates to:
  /// **'Tap to switch profile'**
  String get menu_profileTapToSwitch;

  /// Confirmation after a manual Firefox Sync finished.
  ///
  /// In en, this message translates to:
  /// **'Synchronization complete'**
  String get menu_profileSyncComplete;

  /// Browser menu row. appName is the installed app that can open the page.
  ///
  /// In en, this message translates to:
  /// **'Open in {appName}'**
  String menu_openInApp(String appName);

  /// Label of the translate row after the page has been translated.
  ///
  /// In en, this message translates to:
  /// **'Translated'**
  String get menu_pageTranslated;

  /// Title of the expandable extensions group in the browser menu.
  ///
  /// In en, this message translates to:
  /// **'Extensions'**
  String get menu_extensionsTitle;

  /// Fallback name for an extension with no title in the browser menu.
  ///
  /// In en, this message translates to:
  /// **'Extension'**
  String get menu_extensionFallbackTitle;

  /// Tooltip of the gear button next to an extension in the browser menu.
  ///
  /// In en, this message translates to:
  /// **'Extension settings'**
  String get menu_extensionsSettingsTooltip;

  /// Row in the browser menu's extensions group that opens extension management.
  ///
  /// In en, this message translates to:
  /// **'Manage Extensions'**
  String get menu_extensionsManage;

  /// Title of the expandable containers group in the browser menu.
  ///
  /// In en, this message translates to:
  /// **'Containers'**
  String get menu_containersExpansionTitle;

  /// Row in the containers group that opens the container list.
  ///
  /// In en, this message translates to:
  /// **'Manage Containers'**
  String get menu_containersManage;

  /// Row in the containers group that moves the current tab into a container.
  ///
  /// In en, this message translates to:
  /// **'Assign Container'**
  String get menu_containersAssign;

  /// Row in the containers group that makes the current site always open in this tab's container.
  ///
  /// In en, this message translates to:
  /// **'Assign URL to Container'**
  String get menu_containersAssignUrl;

  /// Row in the containers group that removes the current site from the container's assigned sites.
  ///
  /// In en, this message translates to:
  /// **'Unassign URL from Container'**
  String get menu_containersUnassignUrl;

  /// Row in the containers group that takes the current tab out of its container.
  ///
  /// In en, this message translates to:
  /// **'Unassign Container'**
  String get menu_containersUnassign;

  /// Title of the expandable share group in the browser menu.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get menu_shareExpansionTitle;

  /// Confirmation after tracking parameters were removed from the address being shared.
  ///
  /// In en, this message translates to:
  /// **'URL cleaned'**
  String get menu_shareUrlCleaned;

  /// Confirmation after the chosen tracking parameters were removed from the address being shared.
  ///
  /// In en, this message translates to:
  /// **'URL preview applied'**
  String get menu_shareUrlPreviewApplied;

  /// Row in the share group that copies the page address.
  ///
  /// In en, this message translates to:
  /// **'Copy Address'**
  String get menu_shareCopyAddress;

  /// Row in the share group that shares a screenshot of the visible page.
  ///
  /// In en, this message translates to:
  /// **'Share Screenshot'**
  String get menu_shareScreenshot;

  /// Row in the share group that shares the page address.
  ///
  /// In en, this message translates to:
  /// **'Share Link'**
  String get menu_shareLink;

  /// Row in the share group that shows the page address as a QR code.
  ///
  /// In en, this message translates to:
  /// **'Show QR Code'**
  String get menu_shareShowQrCode;

  /// Title of the expandable list of synced devices to send the tab to.
  ///
  /// In en, this message translates to:
  /// **'Send To Device'**
  String get menu_sendToDeviceExpansionTitle;

  /// Shown when no other synced device can receive tabs.
  ///
  /// In en, this message translates to:
  /// **'No target devices'**
  String get menu_sendToDeviceNone;

  /// Placeholder while the list of synced devices loads.
  ///
  /// In en, this message translates to:
  /// **'Loading devices...'**
  String get menu_sendToDeviceLoading;

  /// Error when the list of synced devices could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Failed to load devices'**
  String get menu_sendToDeviceLoadFailed;

  /// Confirmation after sending the tab. deviceName is the receiving device's name.
  ///
  /// In en, this message translates to:
  /// **'Sent tab to {deviceName}'**
  String menu_sendToDeviceSuccess(String deviceName);

  /// Error message when sending the tab failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send tab'**
  String get menu_sendToDeviceSendFailed;

  /// Title of the expandable group for copying the current tab into a new tab.
  ///
  /// In en, this message translates to:
  /// **'Clone Tab'**
  String get menu_cloneTabExpansionTitle;

  /// Clone option: copy into a regular tab.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get menu_cloneTypeRegular;

  /// Clone option: copy into a private tab.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get menu_cloneTypePrivate;

  /// Clone option: copy into an isolated tab (own separate cookies and site data).
  ///
  /// In en, this message translates to:
  /// **'Isolated'**
  String get menu_cloneTypeIsolated;

  /// Title of the expandable group for saving the page in other formats.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get menu_exportExpansionTitle;

  /// Row in the export group that copies the page text as Markdown. Markdown is a text format name.
  ///
  /// In en, this message translates to:
  /// **'Copy as Markdown'**
  String get menu_exportCopyAsMarkdown;

  /// Row in the export group that saves the page text as a Markdown file.
  ///
  /// In en, this message translates to:
  /// **'Export as Markdown'**
  String get menu_exportAsMarkdown;

  /// Row in the export group that saves the page as a PDF file.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get menu_exportAsPdf;

  /// Row in the export group that saves the page as a PNG image.
  ///
  /// In en, this message translates to:
  /// **'Export as PNG'**
  String get menu_exportAsPng;

  /// Confirmation after copying the page as Markdown.
  ///
  /// In en, this message translates to:
  /// **'Markdown copied to clipboard'**
  String get menu_exportMarkdownCopied;

  /// Row in the export group that prints the page.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get menu_exportPrint;

  /// Error message when printing failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to print page'**
  String get menu_exportPrintFailed;

  /// Browser menu row when the site is pinned: remove it from the home screen shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Unpin from Shortcuts'**
  String get menu_pinUnpinFromShortcuts;

  /// Browser menu row when the site is not pinned: add it to the home screen shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Pin to Shortcuts'**
  String get menu_pinPinToShortcuts;

  /// Confirmation after removing the site from the home screen shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Unpinned from Shortcuts'**
  String get menu_pinUnpinnedMessage;

  /// Confirmation after adding the site to the home screen shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Pinned to Shortcuts'**
  String get menu_pinPinnedMessage;

  /// Error message when changing the home screen shortcuts failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update Shortcuts'**
  String get menu_pinUpdateFailed;

  /// Browser menu row that looks for news feeds (RSS/Atom) on the current page.
  ///
  /// In en, this message translates to:
  /// **'Fetch Feeds on Page'**
  String get menu_fetchFeedsTitle;

  /// Shown when the page offers no news feeds.
  ///
  /// In en, this message translates to:
  /// **'No Web Feeds Found'**
  String get menu_fetchFeedsNone;

  /// Row or menu item listing the news feeds found on the page; opens a dialog to subscribe.
  ///
  /// In en, this message translates to:
  /// **'Available Web Feeds'**
  String get menu_fetchFeedsAvailable;

  /// Progress text while looking for news feeds on the page.
  ///
  /// In en, this message translates to:
  /// **'Fetching Web Feeds...'**
  String get menu_fetchFeedsLoading;

  /// Title of the connection group in the browser menu, summarizing how this tab's traffic is routed (directly, via proxy or Tor).
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get menu_connectionTitle;

  /// Row label for how regular (non-private) tabs are routed; also title of its proxy picker.
  ///
  /// In en, this message translates to:
  /// **'Regular tabs'**
  String get menu_connectionRegularTabs;

  /// Row label for how private tabs are routed; also title of its proxy picker.
  ///
  /// In en, this message translates to:
  /// **'Private tabs'**
  String get menu_connectionPrivateTabs;

  /// Value of the regular tabs route when all of them go through one proxy. proxyTitle is the proxy's name.
  ///
  /// In en, this message translates to:
  /// **'All through {proxyTitle}'**
  String menu_connectionAllThrough(String proxyTitle);

  /// Value, and picker option, meaning each container decides its own route.
  ///
  /// In en, this message translates to:
  /// **'Per container'**
  String get menu_connectionPerContainer;

  /// Explanation under the "Per container" picker option.
  ///
  /// In en, this message translates to:
  /// **'Only containers with a proxy assigned are routed'**
  String get menu_connectionPerContainerSubtitle;

  /// Route value and picker option: no proxy, connect directly.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get menu_connectionDirect;

  /// Explanation under the "Direct" option for private tabs.
  ///
  /// In en, this message translates to:
  /// **'Private tabs never inherit the global route'**
  String get menu_connectionPrivateNeverInheritSubtitle;

  /// Row label for the route of the current isolated tab; also title of its proxy picker.
  ///
  /// In en, this message translates to:
  /// **'This isolated tab'**
  String get menu_connectionThisIsolatedTab;

  /// Route value of an isolated tab that uses its container's route.
  ///
  /// In en, this message translates to:
  /// **'Follows its container'**
  String get menu_connectionFollowsContainer;

  /// Picker option for an isolated tab: use its container's route.
  ///
  /// In en, this message translates to:
  /// **'Follow its container'**
  String get menu_connectionFollowContainerOption;

  /// Explanation under "Follow its container".
  ///
  /// In en, this message translates to:
  /// **'Use the route assigned to this tab\'s container'**
  String get menu_connectionFollowContainerOptionSubtitle;

  /// Explanation under "Direct" for an isolated tab.
  ///
  /// In en, this message translates to:
  /// **'Bypass the route its container would apply'**
  String get menu_connectionIsolatedDirectSubtitle;

  /// Fallback row label for the current container's route when it has no name.
  ///
  /// In en, this message translates to:
  /// **'This container'**
  String get menu_connectionThisContainer;

  /// Route value of a container that uses the app-wide route.
  ///
  /// In en, this message translates to:
  /// **'Follows global routing'**
  String get menu_connectionFollowsGlobalRouting;

  /// Fallback title of the proxy picker for an unnamed container.
  ///
  /// In en, this message translates to:
  /// **'Container'**
  String get menu_connectionContainerFallbackTitle;

  /// Picker option for a container: use the app-wide route.
  ///
  /// In en, this message translates to:
  /// **'Follow global routing'**
  String get menu_connectionFollowGlobalRoutingOption;

  /// Explanation under "Follow global routing".
  ///
  /// In en, this message translates to:
  /// **'Use the same route as regular tabs'**
  String get menu_connectionFollowGlobalRoutingOptionSubtitle;

  /// Explanation under "Direct" for a container.
  ///
  /// In en, this message translates to:
  /// **'Bypass the global proxy for this container'**
  String get menu_connectionContainerDirectSubtitle;

  /// Error message when changing a route failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to change route: {error}'**
  String menu_connectionFailedToChangeRoute(String error);

  /// Error message when starting a proxy failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Proxy error: {error}'**
  String menu_connectionProxyError(String error);

  /// Summary line when this tab's storage differs from its container's, so the container's route does not apply. container is the container's name.
  ///
  /// In en, this message translates to:
  /// **'Not routed by container \"{container}\"'**
  String menu_connectionNotRoutedByContainer(String container);

  /// Same summary line when the container has no name.
  ///
  /// In en, this message translates to:
  /// **'Not routed by this tab\'s container'**
  String get menu_connectionNotRoutedByTabContainer;

  /// Summary line while the tab's routing is being determined.
  ///
  /// In en, this message translates to:
  /// **'Checking routing…'**
  String get menu_connectionCheckingRouting;

  /// Summary line while the tab's proxy is starting.
  ///
  /// In en, this message translates to:
  /// **'Starting routing…'**
  String get menu_connectionStartingRouting;

  /// Summary line when the tab's traffic is blocked because its proxy is off. proxyTitle is the proxy's name.
  ///
  /// In en, this message translates to:
  /// **'Blocked — {proxyTitle} is not running'**
  String menu_connectionBlockedNotRunning(String proxyTitle);

  /// Summary line: this tab's traffic goes through a proxy. proxyTitle is the proxy's name.
  ///
  /// In en, this message translates to:
  /// **'This tab: {proxyTitle}'**
  String menu_connectionThisTabVia(String proxyTitle);

  /// Summary line: this tab connects directly without a proxy.
  ///
  /// In en, this message translates to:
  /// **'This tab: direct connection'**
  String get menu_connectionThisTabDirect;

  /// Button that starts the stopped proxy. proxyTitle is the proxy's name.
  ///
  /// In en, this message translates to:
  /// **'Start {proxyTitle}'**
  String menu_connectionStartProxy(String proxyTitle);

  /// Row in the connection group that opens proxy settings.
  ///
  /// In en, this message translates to:
  /// **'Proxy Settings'**
  String get menu_connectionProxySettings;

  /// Line under a proxy in the connection group when no route uses it.
  ///
  /// In en, this message translates to:
  /// **'Not used by any route'**
  String get menu_connectionUnused;

  /// Part of a proxy's usage line. count is how many containers use it.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 container} other{{count} containers}}'**
  String menu_connectionUsageContainerCount(int count);

  /// Part of a proxy's usage line. count is how many isolated tabs use it.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 isolated tab} other{{count} isolated tabs}}'**
  String menu_connectionUsageIsolatedTabCount(int count);

  /// First word of a proxy's usage line when tabs using it are blocked because it is off.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get menu_connectionUsageBlocked;

  /// Item in the menu shown when long-pressing a link on a web page; opens the link in a new tab of the current kind.
  ///
  /// In en, this message translates to:
  /// **'Open in new tab'**
  String get contextmenu_openInNewTab;

  /// Tooltip of the arrow next to "Open in new tab" in the link long-press menu; it lists other tab kinds (regular, private, isolated) to open the link in.
  ///
  /// In en, this message translates to:
  /// **'Open in a different tab type'**
  String get contextmenu_tooltipOpenInDifferentTabType;

  /// Choice in the link long-press menu's tab-kind list: open the link in a normal (non-private) tab.
  ///
  /// In en, this message translates to:
  /// **'New regular tab'**
  String get contextmenu_newRegularTab;

  /// Choice in the link long-press menu's tab-kind list: open the link in a private tab, which keeps no history.
  ///
  /// In en, this message translates to:
  /// **'New private tab'**
  String get contextmenu_newPrivateTab;

  /// Choice in the link long-press menu's tab-kind list: open the link in an isolated tab, which has its own temporary cookies and site data.
  ///
  /// In en, this message translates to:
  /// **'New isolated tab'**
  String get contextmenu_newIsolatedTab;

  /// Item in the menu shown when long-pressing an image on a web page; opens the image by itself in a new tab.
  ///
  /// In en, this message translates to:
  /// **'Open image in new tab'**
  String get contextmenu_openImageInNewTab;

  /// Item in the link long-press menu; lets the user pick a container (a separate browsing identity with its own cookies) to open the link in.
  ///
  /// In en, this message translates to:
  /// **'Open in container'**
  String get contextmenu_openInContainer;

  /// Heading of the list of containers shown after choosing "Open in container" in the link long-press menu.
  ///
  /// In en, this message translates to:
  /// **'Select Container'**
  String get contextmenu_selectContainerTitle;

  /// Error heading when the list of containers could not be loaded for "Open in container".
  ///
  /// In en, this message translates to:
  /// **'Failed to load containers'**
  String get contextmenu_loadContainersFailedTitle;

  /// Last entry in the "Open in container" list; creates a new container and opens the link in it.
  ///
  /// In en, this message translates to:
  /// **'New Container'**
  String get contextmenu_newContainer;

  /// Item in the link long-press menu; opens the link in the installed app that handles it, when the app's name is unknown.
  ///
  /// In en, this message translates to:
  /// **'Open in App'**
  String get contextmenu_openInApp;

  /// Item in the link long-press menu; opens the link in the installed app that handles it. appName is that app's name.
  ///
  /// In en, this message translates to:
  /// **'Open in {appName}'**
  String contextmenu_openInAppNamed(String appName);

  /// Item in the long-press menu of a link; copies the link address to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get contextmenu_copyLink;

  /// Item in the long-press menu of a link; copies the visible text of the link, not its address.
  ///
  /// In en, this message translates to:
  /// **'Copy link text'**
  String get contextmenu_copyLinkText;

  /// Item in the long-press menu of an image; copies the image itself to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy image'**
  String get contextmenu_copyImage;

  /// Item in the long-press menu of an image; copies the image's web address to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy image location'**
  String get contextmenu_copyImageLocation;

  /// Item in the long-press menu of a link; downloads the linked file.
  ///
  /// In en, this message translates to:
  /// **'Save file'**
  String get contextmenu_saveFile;

  /// Item in the long-press menu of an image; downloads the image to the device.
  ///
  /// In en, this message translates to:
  /// **'Save image'**
  String get contextmenu_saveImage;

  /// Item in the long-press menu of an image; opens the system share sheet for the image.
  ///
  /// In en, this message translates to:
  /// **'Share image'**
  String get contextmenu_shareImage;

  /// Item in the long-press menu of an email link (mailto:); copies or shares the email address. Same text for both actions.
  ///
  /// In en, this message translates to:
  /// **'Share email address'**
  String get contextmenu_shareEmailAddress;

  /// Short confirmation shown after tracking parameters were removed from the long-pressed link.
  ///
  /// In en, this message translates to:
  /// **'URL cleaned'**
  String get contextmenu_urlCleanedMessage;

  /// Short confirmation shown after the user picked which tracking parameters to remove from the long-pressed link and the cleaned address was applied.
  ///
  /// In en, this message translates to:
  /// **'URL preview applied'**
  String get contextmenu_urlPreviewAppliedMessage;

  /// Placeholder text in the search field of the find-in-page bar, which searches for text on the current web page.
  ///
  /// In en, this message translates to:
  /// **'Find in Page'**
  String get findInPage_hint;

  /// Match counter in the find-in-page bar. current is the position of the highlighted match, total is the number of matches on the page (e.g. "3 of 12").
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String findInPage_matchPosition(int current, int total);

  /// Shown in the find-in-page bar in place of the match counter when the search text does not appear on the page.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get findInPage_noMatches;

  /// Title of the browsing history screen.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history_titleHistory;

  /// Title of the same screen when it shows downloaded files instead of browsing history.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get history_titleDownloads;

  /// Placeholder of the search field on the history screen.
  ///
  /// In en, this message translates to:
  /// **'Filter history…'**
  String get history_filterHintHistory;

  /// Placeholder of the search field on the downloads screen.
  ///
  /// In en, this message translates to:
  /// **'Filter downloads…'**
  String get history_filterHintDownloads;

  /// Title of the history or downloads screen while entries are selected. count is the number of selected entries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 selected} other{{count} selected}}'**
  String history_selectionCount(int count);

  /// Tooltip of the button that closes and empties the search field on the history or downloads screen.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get history_tooltipClearSearch;

  /// Tooltip of the button that opens the search field on the history screen.
  ///
  /// In en, this message translates to:
  /// **'Search history'**
  String get history_tooltipSearchHistory;

  /// Tooltip of the button that opens the search field on the downloads screen.
  ///
  /// In en, this message translates to:
  /// **'Search downloads'**
  String get history_tooltipSearchDownloads;

  /// Tooltip of the button that deletes the history of the container the list is filtered to. container is the container name. A container is a separate browsing identity with its own cookies and history.
  ///
  /// In en, this message translates to:
  /// **'Clear history for \"{container}\"'**
  String history_tooltipClearContainerHistory(String container);

  /// Label of the filter button that restricts history to a date range; replaced by the chosen range once set.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get history_filterDate;

  /// Label of the filter button that restricts history to one container, when no container is selected.
  ///
  /// In en, this message translates to:
  /// **'Container'**
  String get history_filterContainer;

  /// Choice in the container filter: show history from all containers.
  ///
  /// In en, this message translates to:
  /// **'All Containers'**
  String get history_allContainers;

  /// Fallback name for a container that has no name.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Container'**
  String get history_unnamedContainer;

  /// Label of the container filter button while a container is selected. container is its name.
  ///
  /// In en, this message translates to:
  /// **'Container: {container}'**
  String history_containerFilterLabel(String container);

  /// Menu item that clears all history filters.
  ///
  /// In en, this message translates to:
  /// **'Reset Filter'**
  String get history_resetFilter;

  /// Checkbox in the history filter menu: show visits reached by clicking a link.
  ///
  /// In en, this message translates to:
  /// **'Followed Links'**
  String get history_filterTypeFollowedLinks;

  /// Checkbox in the history filter menu: show visits reached by typing the address.
  ///
  /// In en, this message translates to:
  /// **'Typed Addresses'**
  String get history_filterTypeTypedAddresses;

  /// Checkbox in the history filter menu: show loads of content embedded in a page (such as images or scripts), not pages the user opened.
  ///
  /// In en, this message translates to:
  /// **'Embedded Page Elements'**
  String get history_filterTypeEmbeddedPageElements;

  /// Checkbox in the history filter menu: show visits that were permanent redirects (HTTP 301) to another address.
  ///
  /// In en, this message translates to:
  /// **'Permanent Redirects'**
  String get history_filterTypePermanentRedirects;

  /// Checkbox in the history filter menu: show visits that were temporary redirects (HTTP 302) to another address.
  ///
  /// In en, this message translates to:
  /// **'Temporary Redirects'**
  String get history_filterTypeTemporaryRedirects;

  /// Checkbox in the history filter menu: show visits that started a file download.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get history_filterTypeDownloads;

  /// Checkbox in the history filter menu: show pages loaded inside a frame of another page.
  ///
  /// In en, this message translates to:
  /// **'Frames'**
  String get history_filterTypeFrames;

  /// Checkbox in the history filter menu: show visits caused by reloading a page.
  ///
  /// In en, this message translates to:
  /// **'Page Reloads'**
  String get history_filterTypePageReloads;

  /// Checkbox in the history filter menu: show visits reached by opening a bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get history_filterTypeBookmarks;

  /// Label on a history entry: the page was reached by clicking a link.
  ///
  /// In en, this message translates to:
  /// **'Followed link'**
  String get history_visitTypeFollowedLink;

  /// Label on a history entry: the page was reached by typing its address.
  ///
  /// In en, this message translates to:
  /// **'Typed address'**
  String get history_visitTypeTypedAddress;

  /// Label on a history entry: content embedded in another page (such as an image or script), not a page the user opened.
  ///
  /// In en, this message translates to:
  /// **'Embedded page element'**
  String get history_visitTypeEmbeddedPageElement;

  /// Label on a history entry: the address permanently redirected (HTTP 301) to another one.
  ///
  /// In en, this message translates to:
  /// **'Permanent redirect'**
  String get history_visitTypePermanentRedirect;

  /// Label on a history entry: the address temporarily redirected (HTTP 302) to another one.
  ///
  /// In en, this message translates to:
  /// **'Temporary redirect'**
  String get history_visitTypeTemporaryRedirect;

  /// Label on a history entry: the visit started a file download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get history_visitTypeDownload;

  /// Label on a history entry: the page was loaded inside a frame of another page.
  ///
  /// In en, this message translates to:
  /// **'Frame'**
  String get history_visitTypeFrame;

  /// Label on a history entry: the visit was a reload of the page.
  ///
  /// In en, this message translates to:
  /// **'Page reload'**
  String get history_visitTypePageReload;

  /// Label on a history entry: the page was reached by opening a bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get history_visitTypeBookmark;

  /// Title of the confirmation dialog before deleting all history of one container.
  ///
  /// In en, this message translates to:
  /// **'Clear Container History'**
  String get history_clearContainerHistoryTitle;

  /// Body of the confirmation dialog before deleting all history of one container. container is the container name.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all history for \"{container}\"?'**
  String history_clearContainerHistoryContent(String container);

  /// Error message when opening a download whose file no longer exists on the device.
  ///
  /// In en, this message translates to:
  /// **'Downloaded file not found'**
  String get history_downloadedFileNotFound;

  /// Error message when no app can open a downloaded file.
  ///
  /// In en, this message translates to:
  /// **'Could not open downloaded file'**
  String get history_couldNotOpenDownloadedFile;

  /// Error heading when browsing history could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Failed to load history'**
  String get history_loadHistoryFailedTitle;

  /// Error heading when the list of downloads could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Failed to load downloads'**
  String get history_loadDownloadsFailedTitle;

  /// Title of the dialog asking whether to delete the downloaded file from the device when removing a download from the list.
  ///
  /// In en, this message translates to:
  /// **'Delete File'**
  String get history_deleteFileTitle;

  /// Question in the delete-file dialog. fileName is the downloaded file's name, rendered in bold.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {fileName}?'**
  String history_deleteFileConfirm(String fileName);

  /// Small warning under the delete-file question: the file is removed from the device's storage, not only from the list.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the file from your device.'**
  String get history_deleteFileWarning;

  /// Checkbox in the delete-file dialog when several downloads are removed at once: apply the same answer to the selected files that have not been asked about yet.
  ///
  /// In en, this message translates to:
  /// **'Remember my choice for the remaining files'**
  String get history_deleteFileRememberChoice;

  /// Button in the delete-file dialog: remove the download from the list but keep the file on the device.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get history_deleteFileActionKeep;

  /// Checkbox in the history filter menu: show each address only once, as its newest visit. Older visits are hidden, not deleted.
  ///
  /// In en, this message translates to:
  /// **'Distinct URLs'**
  String get history_filterDistinctUrls;

  /// Chip on a history row when Distinct URLs is on and the row stands for several visits of the same address. count is the number of visits, including the one shown.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 visit} other{{count} visits}}'**
  String history_visitCount(int count);

  /// Tooltip of the delete button in the history screen's app bar, which opens a menu of delete options.
  ///
  /// In en, this message translates to:
  /// **'Delete history'**
  String get history_tooltipDeleteHistory;

  /// Item in the history screen's delete menu: opens a dialog to delete every visit between two chosen dates and times.
  ///
  /// In en, this message translates to:
  /// **'Delete Time Range…'**
  String get history_deleteMenuTimeRange;

  /// Item in the history screen's delete menu: opens the sheet for deleting browsing data (history, cookies, cache, etc.).
  ///
  /// In en, this message translates to:
  /// **'Delete Browsing Data…'**
  String get history_deleteMenuBrowsingData;

  /// Title of the dialog where a start and end date and time are chosen and every history visit between them is deleted.
  ///
  /// In en, this message translates to:
  /// **'Delete History for a Time Range'**
  String get history_deleteTimeRangeTitle;

  /// Label of the row showing the start date and time of the range to delete. Tapping it opens a date picker, then a time picker.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get history_deleteTimeRangeFrom;

  /// Label of the row showing the end date and time of the range to delete. The whole end minute is included.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get history_deleteTimeRangeTo;

  /// Preset chip in the delete-time-range dialog: sets the range to the past 60 minutes.
  ///
  /// In en, this message translates to:
  /// **'Last hour'**
  String get history_deleteTimeRangeLastHour;

  /// Preset chip in the delete-time-range dialog: sets the range from midnight until now.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get history_deleteTimeRangeToday;

  /// Preset chip in the delete-time-range dialog: sets the range to the past seven days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get history_deleteTimeRangeLastWeek;

  /// Explanation in the delete-time-range dialog of what is removed. Visits from every container are deleted; entries of finished and failed downloads disappear from the list but downloaded files are kept; running or paused downloads stay listed.
  ///
  /// In en, this message translates to:
  /// **'Every visit in this range is deleted, in all containers. Finished and failed downloads from this range also leave the downloads list; the files stay on the device. Downloads still in progress are kept.'**
  String get history_deleteTimeRangeExplanation;

  /// Error under the chosen range in the delete-time-range dialog when the start is not earlier than the end. The Delete button is disabled.
  ///
  /// In en, this message translates to:
  /// **'The start must be before the end.'**
  String get history_deleteTimeRangeInvalid;

  /// Title of the sheet shown when a link is shared to or opened in WebLibre, offering ways to open it (new tab, custom tab, app) and to clean it.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get openLinkTools_openLinkTitle;

  /// Confirmation after tracking parameters were removed from the link in the open-link sheet.
  ///
  /// In en, this message translates to:
  /// **'URL cleaned'**
  String get openLinkTools_urlCleanedMessage;

  /// Confirmation after the user picked which tracking parameters to remove and the cleaned link was applied.
  ///
  /// In en, this message translates to:
  /// **'URL preview applied'**
  String get openLinkTools_urlPreviewAppliedMessage;

  /// Warning in the open-link sheet when the link's destination is on the ClearURLs block list (e.g. a known tracking or ad domain). ClearURLs is a project name.
  ///
  /// In en, this message translates to:
  /// **'URL blocked by ClearURLs'**
  String get openLinkTools_urlBlockedByClearUrls;

  /// Error line when resolving a shortened link (e.g. bit.ly) to its real destination failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Could not unshorten the link: {error}'**
  String openLinkTools_unshortenFailedWithError(String error);

  /// Line under the unshorten action when the free quota is running low. remaining is the number of requests left; limit is the hourly limit.
  ///
  /// In en, this message translates to:
  /// **'Remaining calls: {remaining}/{limit}'**
  String openLinkTools_unshortenRemainingCalls(int remaining, int limit);

  /// Action in the open-link sheet that resolves a shortened link (e.g. bit.ly) to its real destination.
  ///
  /// In en, this message translates to:
  /// **'Unshorten'**
  String get openLinkTools_unshortenTileTitle;

  /// Explanation under the "Unshorten" action.
  ///
  /// In en, this message translates to:
  /// **'Resolve shortened URL'**
  String get openLinkTools_unshortenTileSubtitle;

  /// Tooltip of the info button next to the "Unshorten" action; opens details about the online service used.
  ///
  /// In en, this message translates to:
  /// **'Unshortener info'**
  String get openLinkTools_unshortenerInfoTooltip;

  /// Action in the open-link sheet that opens the link in the installed app that handles it. appName is that app's name.
  ///
  /// In en, this message translates to:
  /// **'Open in {appName}'**
  String openLinkTools_openInAppNamed(String appName);

  /// Action in the open-link sheet that opens the link in the installed app that handles it, when the app's name is unknown.
  ///
  /// In en, this message translates to:
  /// **'Open in App'**
  String get openLinkTools_openInAppGeneric;

  /// Explanation under the open-in-app action.
  ///
  /// In en, this message translates to:
  /// **'Open in an installed app'**
  String get openLinkTools_openInAppSubtitle;

  /// Error message when the link could not be handed to the app.
  ///
  /// In en, this message translates to:
  /// **'Could not open in app'**
  String get openLinkTools_couldNotOpenInApp;

  /// Action in the open-link sheet that opens the link in a new browser tab.
  ///
  /// In en, this message translates to:
  /// **'Open in new tab'**
  String get openLinkTools_openInNewTabTitle;

  /// Explanation under the "Open in new tab" action: the link is added to the regular tab list.
  ///
  /// In en, this message translates to:
  /// **'Add to your browser tabs'**
  String get openLinkTools_openInNewTabSubtitle;

  /// Action in the open-link sheet that opens the link in a custom tab: a lightweight browser window that closes back to the app it came from, without joining the regular tab list.
  ///
  /// In en, this message translates to:
  /// **'Open in custom tab'**
  String get openLinkTools_openInCustomTabTitle;

  /// Explanation under the "Open in custom tab" action.
  ///
  /// In en, this message translates to:
  /// **'Open in a separate window'**
  String get openLinkTools_openInCustomTabSubtitle;

  /// Title of the dialog explaining which online service resolves shortened links.
  ///
  /// In en, this message translates to:
  /// **'Unshortener Attribution'**
  String get openLinkTools_unshortenerAttributionTitle;

  /// Body of the unshortener info dialog: links are sent to an online service. service is the service's name (unshorten.me), rendered as a tappable link.
  ///
  /// In en, this message translates to:
  /// **'This module resolves shortened links by sending them to {service}. The service checks each link on its servers and saves the redirect for future requests. Avoid sending links that contain private or sensitive data.'**
  String openLinkTools_unshortenerAttributionBody(String service);

  /// Notice in the unshortener info dialog and settings about the free service's limit of 10 new lookups per hour.
  ///
  /// In en, this message translates to:
  /// **'The free API is rate limited to 10 requests per hour for new checks.'**
  String get openLinkTools_unshortenerRateLimitNotice;

  /// Line in the unshortener info dialog. link is the address of the service's privacy policy, rendered as a tappable link.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy: {link}'**
  String openLinkTools_privacyPolicyLabel(String link);

  /// Title of the dialog for choosing which tracking parameters to remove from a link. Tracking parameters are parts of a web address (such as utm_source=…) used to follow the user.
  ///
  /// In en, this message translates to:
  /// **'Remove Tracking Parameters'**
  String get openLinkTools_removeTrackingParametersTitle;

  /// Instruction under the title of the tracking-parameter dialog.
  ///
  /// In en, this message translates to:
  /// **'Select parameters to strip from this URL.'**
  String get openLinkTools_removeTrackingParametersSubtitle;

  /// Small badge on a tracking parameter that is used for referral or affiliate programs (the sender earns money from the click).
  ///
  /// In en, this message translates to:
  /// **'Referral marketing'**
  String get openLinkTools_referralMarketingBadge;

  /// Counter in the tracking-parameter dialog. selected is how many parameters are ticked for removal; total is how many were found.
  ///
  /// In en, this message translates to:
  /// **'{selected} of {total} selected for removal'**
  String openLinkTools_selectedForRemovalCount(int selected, int total);

  /// Label above the preview of the link after removing the selected parameters.
  ///
  /// In en, this message translates to:
  /// **'Cleaned URL:'**
  String get openLinkTools_cleanedUrlLabel;

  /// Title of the confirmation dialog before resetting the URL cleaner.
  ///
  /// In en, this message translates to:
  /// **'Restore defaults?'**
  String get openLinkTools_restoreDefaultsTitle;

  /// Body of the confirmation dialog before resetting the URL cleaner: settings return to defaults and the downloaded rule catalog is deleted.
  ///
  /// In en, this message translates to:
  /// **'This will reset URL cleaner settings and remove the locally stored catalog.'**
  String get openLinkTools_restoreDefaultsContent;

  /// Confirm button of the dialog that resets the URL cleaner.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get openLinkTools_actionRestore;

  /// Button in the tracking-parameter dialog that applies the chosen removals to the link.
  ///
  /// In en, this message translates to:
  /// **'Apply Changes'**
  String get openLinkTools_actionApplyChanges;

  /// Error message when a link could not be opened in a custom tab. url is the link text.
  ///
  /// In en, this message translates to:
  /// **'Could not open link: {url}'**
  String openLinkTools_couldNotOpenLink(String url);

  /// Title of the URL cleaner row in the open-link sheet after all tracking parameters were removed.
  ///
  /// In en, this message translates to:
  /// **'URL cleaned'**
  String get openLinkTools_tileTitleCleaned;

  /// Line under "URL cleaned". count is the number of tracking parameters removed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 tracking parameter removed} other{{count} tracking parameters removed}}'**
  String openLinkTools_tileSubtitleRemovedCount(int count);

  /// Title of the URL cleaner row when only some tracking parameters were removed.
  ///
  /// In en, this message translates to:
  /// **'URL partially cleaned'**
  String get openLinkTools_tileTitlePartiallyCleaned;

  /// Line under "URL partially cleaned". removed is how many were removed; total is how many were found.
  ///
  /// In en, this message translates to:
  /// **'{total, plural, =1{{removed} of 1 tracking parameter removed} other{{removed} of {total} tracking parameters removed}}'**
  String openLinkTools_tileSubtitlePartiallyCleaned(int removed, int total);

  /// Title of the URL cleaner row when the link contains tracking parameters that are not removed yet.
  ///
  /// In en, this message translates to:
  /// **'Tracking detected'**
  String get openLinkTools_tileTitleTrackingDetected;

  /// Line under "Tracking detected". count is the number of tracking parameters found.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 tracking parameter found} other{{count} tracking parameters found}}'**
  String openLinkTools_tileSubtitleFoundCount(int count);

  /// Tooltip of the button that removes the tracking parameters from the link.
  ///
  /// In en, this message translates to:
  /// **'Clean URL'**
  String get openLinkTools_cleanUrlTooltip;

  /// Title of the settings screen for resolving shortened links to their destination.
  ///
  /// In en, this message translates to:
  /// **'Unshortener'**
  String get openLinkTools_unshortenerSettingsTitle;

  /// Subtitle of the unshortener settings screen listing what it contains.
  ///
  /// In en, this message translates to:
  /// **'Short-link resolution behavior, token configuration, and attribution.'**
  String get openLinkTools_unshortenerSettingsSubtitle;

  /// Switch that turns on the option to resolve shortened links.
  ///
  /// In en, this message translates to:
  /// **'Enable Unshortener'**
  String get openLinkTools_unshortenerEnabledTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'short links'**
  String get openLinkTools_unshortenerEnabledKeywords;

  /// Explanation under "Enable Unshortener".
  ///
  /// In en, this message translates to:
  /// **'Resolve shortened URLs to their destination'**
  String get openLinkTools_unshortenerEnabledSubtitle;

  /// Heading of the row explaining what the URL cleaner or unshortener does.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get openLinkTools_descriptionLabel;

  /// Explanation of the unshortener in its settings: links are sent to the online service unshorten.me (a service name; keep unchanged).
  ///
  /// In en, this message translates to:
  /// **'This module resolves shortened links by sending them to unshorten.me. The service checks each link on its servers and saves the redirect for future requests. Avoid sending links that contain private or sensitive data.'**
  String get openLinkTools_unshortenerDescriptionBody;

  /// Label in front of the link to the unshortener service's website.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get openLinkTools_attributionServiceLabel;

  /// Label in front of the link to the unshortener service's privacy policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get openLinkTools_attributionPrivacyPolicyLabel;

  /// Label of the field for a personal access key of the unshortener service. API is a technical abbreviation.
  ///
  /// In en, this message translates to:
  /// **'API Token'**
  String get openLinkTools_apiTokenLabel;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'token'**
  String get openLinkTools_apiTokenLabelKeywords;

  /// Placeholder of the API token field: a token is optional and raises the request limit.
  ///
  /// In en, this message translates to:
  /// **'Optional token for higher limits'**
  String get openLinkTools_apiTokenHint;

  /// Title of the settings screen for the URL cleaner, which removes tracking parameters from links.
  ///
  /// In en, this message translates to:
  /// **'URL Cleaner'**
  String get openLinkTools_urlCleanerSettingsTitle;

  /// Subtitle of the URL cleaner settings screen listing what it contains. The catalog is the downloadable list of cleaning rules.
  ///
  /// In en, this message translates to:
  /// **'URL cleanup behavior, rule catalog updates, and attribution.'**
  String get openLinkTools_urlCleanerSettingsSubtitle;

  /// Explanation of the URL cleaner in its settings. "Offline redirections" means resolving known redirect links on the device without contacting the server.
  ///
  /// In en, this message translates to:
  /// **'This module removes tracking, referrer, and other unnecessary parameters from URLs. It can also resolve common URL redirects offline.'**
  String get openLinkTools_urlCleanerDescriptionBody;

  /// Switch that turns the URL cleaner on.
  ///
  /// In en, this message translates to:
  /// **'Enable URL Cleaner'**
  String get openLinkTools_urlCleanerEnabledTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'clean urls'**
  String get openLinkTools_urlCleanerEnabledKeywords;

  /// Explanation under "Enable URL Cleaner".
  ///
  /// In en, this message translates to:
  /// **'Remove tracking parameters from URLs'**
  String get openLinkTools_urlCleanerEnabledSubtitle;

  /// Switch in the URL cleaner settings: clean links automatically without asking.
  ///
  /// In en, this message translates to:
  /// **'Auto-apply'**
  String get openLinkTools_autoApplyTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'auto apply'**
  String get openLinkTools_autoApplyKeywords;

  /// Explanation under "Auto-apply".
  ///
  /// In en, this message translates to:
  /// **'Automatically replace the URL with a cleaned version'**
  String get openLinkTools_autoApplySubtitle;

  /// Switch in the URL cleaner settings: do not remove referral and affiliate parameters (which may pay the site that shared the link).
  ///
  /// In en, this message translates to:
  /// **'Allow referral marketing'**
  String get openLinkTools_allowReferralTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'affiliate, referral'**
  String get openLinkTools_allowReferralKeywords;

  /// Explanation under "Allow referral marketing".
  ///
  /// In en, this message translates to:
  /// **'Keep referral and affiliate tracking parameters'**
  String get openLinkTools_allowReferralSubtitle;

  /// Switch in the URL cleaner settings: download updated cleaning rules automatically.
  ///
  /// In en, this message translates to:
  /// **'Auto-update catalog'**
  String get openLinkTools_autoUpdateCatalogTitle;

  /// Explanation under "Auto-update catalog".
  ///
  /// In en, this message translates to:
  /// **'Check for rule updates weekly'**
  String get openLinkTools_autoUpdateCatalogSubtitle;

  /// Row in the URL cleaner settings that downloads the latest cleaning rules now.
  ///
  /// In en, this message translates to:
  /// **'Update catalog'**
  String get openLinkTools_updateCatalogTitle;

  /// Line under "Update catalog" when the rules were never updated.
  ///
  /// In en, this message translates to:
  /// **'Last update: not available'**
  String get openLinkTools_lastUpdateNotAvailable;

  /// Line under "Update catalog". date is the date of the last manual rule update.
  ///
  /// In en, this message translates to:
  /// **'Last update: {date}'**
  String openLinkTools_lastUpdateWithDate(String date);

  /// Line under "Update catalog". date is the date of the last rule update, which happened automatically.
  ///
  /// In en, this message translates to:
  /// **'Last update: {date} (auto)'**
  String openLinkTools_lastAutoUpdateWithDate(String date);

  /// Line under "Update catalog". date is when the app last checked for new rules.
  ///
  /// In en, this message translates to:
  /// **'Last check: {date}'**
  String openLinkTools_lastCheckWithDate(String date);

  /// Confirmation after the URL cleaner rules were updated.
  ///
  /// In en, this message translates to:
  /// **'Catalog updated'**
  String get openLinkTools_catalogUpdatedMessage;

  /// Error message when updating the URL cleaner rules failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String openLinkTools_updateFailedWithError(String error);

  /// Row in the URL cleaner settings that resets it (asks for confirmation).
  ///
  /// In en, this message translates to:
  /// **'Restore defaults'**
  String get openLinkTools_restoreDefaultsButtonTitle;

  /// Explanation under "Restore defaults": return to the rule catalog shipped with the app and the default settings.
  ///
  /// In en, this message translates to:
  /// **'Reset to bundled catalog and default settings'**
  String get openLinkTools_restoreDefaultsButtonSubtitle;

  /// Credit line in the URL cleaner settings, followed by a link to the ClearURLs rules. ClearURL is a project name.
  ///
  /// In en, this message translates to:
  /// **'This module is based on the ClearURL rules:'**
  String get openLinkTools_clearUrlAttributionText;

  /// Section heading on the URL cleaner settings screen for the feature description.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get openLinkTools_urlCleanerOverviewSectionTitle;

  /// Title of the URL cleaner description entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get openLinkTools_indexUrlCleanerDescriptionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'tracking parameters, redirects'**
  String get openLinkTools_indexUrlCleanerDescriptionKeywords;

  /// Summary of the URL cleaner, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Tracking parameter removal and offline redirect cleanup'**
  String get openLinkTools_indexUrlCleanerDescriptionSubtitle;

  /// Section heading on the URL cleaner settings screen for how cleaning works.
  ///
  /// In en, this message translates to:
  /// **'Behavior'**
  String get openLinkTools_urlCleanerBehaviorSectionTitle;

  /// Section heading on the URL cleaner settings screen for the downloadable rule list.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get openLinkTools_urlCleanerCatalogSectionTitle;

  /// Summary of the "Update catalog" setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Fetch the latest URL cleaner rules'**
  String get openLinkTools_indexUrlCleanerUpdateCatalogSubtitle;

  /// Section heading on the URL cleaner settings screen for credits to the rule list's creators.
  ///
  /// In en, this message translates to:
  /// **'Attribution'**
  String get openLinkTools_urlCleanerAttributionSectionTitle;

  /// Title of the URL cleaner credits entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Attribution'**
  String get openLinkTools_indexUrlCleanerAttributionTitle;

  /// Summary of the URL cleaner credits entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Credits and source links'**
  String get openLinkTools_indexUrlCleanerAttributionSubtitle;

  /// Section heading on the unshortener settings screen for the feature description.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get openLinkTools_unshortenerOverviewSectionTitle;

  /// Title of the unshortener description entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get openLinkTools_indexUnshortenerDescriptionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'short links, redirects'**
  String get openLinkTools_indexUnshortenerDescriptionKeywords;

  /// Summary of the unshortener, shown as a settings search result. unshorten.me is a service name.
  ///
  /// In en, this message translates to:
  /// **'Resolve shortened URLs using the unshorten.me service'**
  String get openLinkTools_indexUnshortenerDescriptionSubtitle;

  /// Section heading on the unshortener settings screen for how it works.
  ///
  /// In en, this message translates to:
  /// **'Behavior'**
  String get openLinkTools_unshortenerBehaviorSectionTitle;

  /// Summary of the API token setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Optional token for higher request limits'**
  String get openLinkTools_indexUnshortenerApiTokenSubtitle;

  /// Section heading on the unshortener settings screen for information about the online service used.
  ///
  /// In en, this message translates to:
  /// **'Attribution'**
  String get openLinkTools_unshortenerAttributionSectionTitle;

  /// Title of the unshortener service information entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Service attribution'**
  String get openLinkTools_indexUnshortenerAttributionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'privacy policy, rate limit'**
  String get openLinkTools_indexUnshortenerAttributionKeywords;

  /// Summary of the unshortener service information entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Rate limits, service homepage, and privacy policy'**
  String get openLinkTools_indexUnshortenerAttributionSubtitle;

  /// Title of the sheet for adding the current website to the Android home screen, either as a standalone web app or as a shortcut.
  ///
  /// In en, this message translates to:
  /// **'Add to Home Screen'**
  String get pwa_addToHomeScreenTitle;

  /// Label of the text field for the name shown under the home-screen icon.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get pwa_nameFieldLabel;

  /// Section heading in the add-to-home-screen sheet; below it the user picks which cookies and site data the home-screen app uses.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get pwa_storageLabel;

  /// Fallback name for a container that has no name, shown in the storage choices of the add-to-home-screen sheet. A container is a separate browsing identity with its own cookies.
  ///
  /// In en, this message translates to:
  /// **'Container'**
  String get pwa_defaultContainerLabel;

  /// Option in the add-to-home-screen sheet: install the website as a web app that opens in its own window.
  ///
  /// In en, this message translates to:
  /// **'Install as App'**
  String get pwa_installAsAppTitle;

  /// Explanation under "Install as App": the web app opens in its own window, separate from the browser.
  ///
  /// In en, this message translates to:
  /// **'Runs standalone with its own window.'**
  String get pwa_installAsAppSubtitle;

  /// Option in the add-to-home-screen sheet: add a plain home-screen shortcut to the page.
  ///
  /// In en, this message translates to:
  /// **'Add Shortcut'**
  String get pwa_addShortcutTitle;

  /// Explanation under "Add Shortcut": the shortcut opens the page in a normal browser tab.
  ///
  /// In en, this message translates to:
  /// **'Opens as a standard tab in the browser.'**
  String get pwa_addShortcutSubtitle;

  /// Storage choice in the add-to-home-screen sheet: use the browser's normal cookies and site data, not a container.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get pwa_storageDefaultTitle;

  /// Explanation under the "Default" storage choice.
  ///
  /// In en, this message translates to:
  /// **'Uses the default browser storage (no container).'**
  String get pwa_storageDefaultSubtitle;

  /// Storage choice in the add-to-home-screen sheet: use the cookies and site data of a container. label is the container name.
  ///
  /// In en, this message translates to:
  /// **'Container \"{label}\"'**
  String pwa_storageContainerTitle(String label);

  /// Explanation under a container storage choice: the home-screen app shares cookies and site data with that container.
  ///
  /// In en, this message translates to:
  /// **'Shares cookies and data with the selected container.'**
  String get pwa_storageContainerSubtitle;

  /// Storage choice in the add-to-home-screen sheet, offered from an isolated tab: keep using that isolated tab's own storage. An isolated tab has its own separate cookies and site data.
  ///
  /// In en, this message translates to:
  /// **'Inherit current isolated context'**
  String get pwa_storageInheritIsolatedTitle;

  /// Explanation under the choice to reuse the current isolated tab's storage.
  ///
  /// In en, this message translates to:
  /// **'Shares storage with the currently open isolated session.'**
  String get pwa_storageInheritIsolatedSubtitle;

  /// Storage choice in the add-to-home-screen sheet: give the home-screen app its own new, separate storage.
  ///
  /// In en, this message translates to:
  /// **'New isolated context'**
  String get pwa_storageNewIsolatedTitle;

  /// Explanation under "New isolated context": the app gets its own fresh set of cookies and site data ("storage jar") used by nothing else.
  ///
  /// In en, this message translates to:
  /// **'Creates a fresh storage jar just for this installation.'**
  String get pwa_storageNewIsolatedSubtitle;

  /// Fallback name for a web app being added to the home screen when the site declares no name. Inserted into messages such as "{name} added to home screen"; lowercase phrase.
  ///
  /// In en, this message translates to:
  /// **'this web app'**
  String get pwa_defaultWebAppName;

  /// Fallback name for a page being added to the home screen when it has no title. Inserted into messages such as "{name} added to home screen"; lowercase phrase.
  ///
  /// In en, this message translates to:
  /// **'this site'**
  String get pwa_defaultSiteName;

  /// Confirmation after an icon was added to the home screen. name is the chosen name, the site name, or a fallback phrase such as "this site".
  ///
  /// In en, this message translates to:
  /// **'{name} added to home screen'**
  String pwa_addedToHomeScreen(String name);

  /// Error message when installing a website as a web app failed. name is the app name or a fallback phrase such as "this web app".
  ///
  /// In en, this message translates to:
  /// **'Failed to add {name}. The site may not support installation.'**
  String pwa_installFailedManifestBacked(String name);

  /// Error message when adding a home-screen icon failed. name is the chosen name or a fallback phrase such as "this site".
  ///
  /// In en, this message translates to:
  /// **'Failed to add {name} to home screen'**
  String pwa_installFailedGeneric(String name);

  /// Error message when adding to the home screen failed because no browser tab was active at that moment.
  ///
  /// In en, this message translates to:
  /// **'No tab selected. Please try again.'**
  String get pwa_noTabSelected;

  /// Heading of the section on the search and home screens listing the user's recent search terms; also its name when reordering sections.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get search_moduleLabelRecentSearches;

  /// Heading of the section on the search screen listing search engines and bang shortcuts to search with; also its name when reordering sections.
  ///
  /// In en, this message translates to:
  /// **'Search Providers'**
  String get search_moduleLabelSearchProviders;

  /// Heading of the section on the search screen with search terms suggested by the search engine while typing; also its name when reordering sections.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get search_moduleLabelSearchSuggestions;

  /// Heading of the section on the search screen with open tabs matching the typed text; also its name when reordering sections.
  ///
  /// In en, this message translates to:
  /// **'Tabs'**
  String get search_moduleLabelTabs;

  /// Heading of the section on the search screen with news feed articles matching the typed text; also its name when reordering sections.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get search_moduleLabelArticles;

  /// Heading of the section on the search screen with bookmarks matching the typed text; also its name when reordering sections.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get search_moduleLabelBookmarks;

  /// Name, when reordering sections, of the search section with matches from the browser engine's own history. "(engine)" tells it apart from "Local content".
  ///
  /// In en, this message translates to:
  /// **'History (engine)'**
  String get search_moduleLabelHistory;

  /// Heading of the search section with matches from the text of previously visited pages, searched on the device; also its name when reordering sections.
  ///
  /// In en, this message translates to:
  /// **'Local content'**
  String get search_moduleLabelLocalHistory;

  /// Heading of the search section combining history matches by address and by page content; also its name when reordering sections.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get search_moduleLabelCombinedHistory;

  /// Heading of the search section suggesting well-known websites matching the typed text; also its name when reordering sections.
  ///
  /// In en, this message translates to:
  /// **'Popular Sites'**
  String get search_moduleLabelPopularSites;

  /// Heading of the home screen section with frequently or recently visited pages worth returning to; also its name when reordering sections.
  ///
  /// In en, this message translates to:
  /// **'History Highlights'**
  String get search_moduleLabelHistoryHighlights;

  /// Heading of the home screen grid of website shortcuts (pinned and most-visited sites); also its name when reordering sections.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get search_moduleLabelTopSites;

  /// Heading of the home screen section with the most recently visited pages; also its name when reordering sections.
  ///
  /// In en, this message translates to:
  /// **'Recent History'**
  String get search_moduleLabelRecentHistory;

  /// Heading of the home screen section with the newest news feed articles; also its name when reordering sections.
  ///
  /// In en, this message translates to:
  /// **'Recent Articles'**
  String get search_moduleLabelRecentArticles;

  /// Heading of the home screen section with recently used tabs; also its name when reordering sections.
  ///
  /// In en, this message translates to:
  /// **'Recent Tabs'**
  String get search_moduleLabelRecentTabs;

  /// Heading of the home screen section for switching containers (separate browsing identities); also its name when reordering sections.
  ///
  /// In en, this message translates to:
  /// **'Containers'**
  String get search_moduleLabelContainers;

  /// Heading of the section with the most used bang search shortcuts (e.g. "!w"); also its name when reordering sections.
  ///
  /// In en, this message translates to:
  /// **'Frequent Bangs'**
  String get search_moduleLabelFrequentBangs;

  /// Name, when reordering home screen sections, of the section that shows a random quote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get search_moduleLabelQuote;

  /// Heading of the home screen section with buttons such as New tab and View tabs; also its name when reordering sections.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get search_moduleLabelQuickActions;

  /// Heading of the search results section listing browser actions (Reload, History, Settings, ...) whose name matches the typed text; tapping one runs it. Also its name when reordering sections.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get search_moduleLabelActions;

  /// Error heading in the search screen when history matches could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Could not load history'**
  String get search_couldNotLoadHistory;

  /// Error heading in the search screen when matches from the content of visited pages could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Could not load local content'**
  String get search_couldNotLoadLocalContent;

  /// Error heading in the search screen when searching news feed articles failed.
  ///
  /// In en, this message translates to:
  /// **'Article search failed'**
  String get search_failedSearchingArticles;

  /// Tooltip of the icon on a history search result that matched the page's text rather than its title or address.
  ///
  /// In en, this message translates to:
  /// **'Content match'**
  String get search_contentMatchTooltip;

  /// Segment of the tab-type switch on the search screen: open the result in a regular tab. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get search_tabTypeRegular;

  /// Segment of the tab-type switch on the search screen: open the result in a new tab nested under the current tab. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get search_tabTypeChild;

  /// Segment of the tab-type switch on the search screen: open the result in a private tab. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get search_tabTypePrivate;

  /// Segment of the tab-type switch on the search screen: open the result in an isolated tab with its own separate cookies and site data. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Isolated'**
  String get search_tabTypeIsolated;

  /// Suggestion row in the search screen that pastes the web address currently on the clipboard into the search field.
  ///
  /// In en, this message translates to:
  /// **'Fill link from clipboard'**
  String get search_fillLinkFromClipboard;

  /// Button in the home screen's quick actions that opens a new tab.
  ///
  /// In en, this message translates to:
  /// **'New tab'**
  String get search_actionNewTab;

  /// Button in the home screen's quick actions that opens the overview of open tabs.
  ///
  /// In en, this message translates to:
  /// **'View tabs'**
  String get search_actionViewTabs;

  /// Button in the home screen's quick actions that returns to the most recently used tab.
  ///
  /// In en, this message translates to:
  /// **'Resume last tab'**
  String get search_actionResumeLastTab;

  /// Tab of the search provider selector: show all search engines and bangs.
  ///
  /// In en, this message translates to:
  /// **'All Providers'**
  String get search_bangTabAllProviders;

  /// Tab of the search provider selector: show bangs that search within the website currently open.
  ///
  /// In en, this message translates to:
  /// **'Search On This Site'**
  String get search_bangTabSearchOnThisSite;

  /// Title of the dialog for editing a home screen shortcut's name and address.
  ///
  /// In en, this message translates to:
  /// **'Edit Shortcut'**
  String get search_editShortcutDialogTitle;

  /// Tooltip of the "+" tile in the home screen shortcut grid, and title of the dialog it opens for adding a shortcut.
  ///
  /// In en, this message translates to:
  /// **'Add shortcut'**
  String get search_addShortcut;

  /// Label of the name field in the add/edit shortcut dialog.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get search_titleFieldLabel;

  /// Label of the web address field in the add/edit shortcut dialog.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get search_urlFieldLabel;

  /// Validation error when the shortcut name is empty.
  ///
  /// In en, this message translates to:
  /// **'Title cannot be empty'**
  String get search_titleCannotBeEmpty;

  /// Validation error when the shortcut address is empty.
  ///
  /// In en, this message translates to:
  /// **'URL cannot be empty'**
  String get search_urlCannotBeEmpty;

  /// Validation error when the shortcut address is not a valid web address.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid URL'**
  String get search_enterValidUrl;

  /// Menu item that pins a shortcut or bang so it always stays visible.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get search_actionPin;

  /// Menu item that unpins a pinned bang.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get search_actionUnpin;

  /// Menu item on a bang chip that resets how often it counts as used, removing it from the frequent bangs list.
  ///
  /// In en, this message translates to:
  /// **'Reset frequency'**
  String get search_actionResetFrequency;

  /// Menu item on a bang chip that edits a bang the user created.
  ///
  /// In en, this message translates to:
  /// **'Edit bang'**
  String get search_actionEditBang;

  /// Menu item on a bang chip that makes an editable personal copy of a built-in bang.
  ///
  /// In en, this message translates to:
  /// **'Customize as your own bang'**
  String get search_actionCustomizeAsOwnBang;

  /// Title of the confirmation dialog for resetting a bang's usage count. triggerName is the bang's trigger word, e.g. "w".
  ///
  /// In en, this message translates to:
  /// **'Reset usage frequency of {triggerName}?'**
  String search_resetBangDialogTitle(String triggerName);

  /// Body of the confirmation dialog for resetting a bang's usage count: it disappears from the quick-select list of frequent bangs.
  ///
  /// In en, this message translates to:
  /// **'This will remove the bang from the quick-select list.'**
  String get search_resetBangDialogContent;

  /// Button at the bottom of the home or search screen that enters a mode for reordering and hiding its sections.
  ///
  /// In en, this message translates to:
  /// **'Customize sections'**
  String get search_customizeSectionsButton;

  /// Heading shown while reordering and hiding sections of the home or search screen.
  ///
  /// In en, this message translates to:
  /// **'Customize Sections'**
  String get search_customizeSectionsHeading;

  /// Menu item that restores the default order and visibility of home or search screen sections.
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get search_resetToDefaults;

  /// Button in a section header that expands the section. count is the total number of items in the section.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{Show all {count}}}'**
  String search_showAllCount(int count);

  /// Tooltip of the button that ends rearranging the home screen shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Disable reordering mode'**
  String get search_disableReorderingMode;

  /// Tooltip of the button that starts rearranging the home screen shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Enable reordering mode'**
  String get search_enableReorderingMode;

  /// Hint shown after starting to rearrange home screen shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Drag and drop shortcuts to reorder'**
  String get search_dragDropShortcutsHint;

  /// Error message when the new position of a home screen shortcut could not be saved.
  ///
  /// In en, this message translates to:
  /// **'Failed to reorder shortcut'**
  String get search_failedReorderShortcut;

  /// Menu item on a home screen shortcut that hides every suggested shortcut from that website. host is the website domain, e.g. example.com.
  ///
  /// In en, this message translates to:
  /// **'Hide all from {host}'**
  String search_hideAllFromHost(String host);

  /// Confirmation after pinning a site to the home screen shortcuts. title is the site's name.
  ///
  /// In en, this message translates to:
  /// **'Pinned \"{title}\"'**
  String search_pinnedSite(String title);

  /// Error message when pinning a site to the home screen shortcuts failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to pin site'**
  String get search_failedPinSite;

  /// Confirmation after editing a home screen shortcut.
  ///
  /// In en, this message translates to:
  /// **'Shortcut updated'**
  String get search_shortcutUpdated;

  /// Error message when saving changes to a home screen shortcut failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update shortcut'**
  String get search_failedUpdateShortcut;

  /// Confirmation after adding a home screen shortcut. title is the shortcut's name.
  ///
  /// In en, this message translates to:
  /// **'Added \"{title}\"'**
  String search_addedSite(String title);

  /// Error message when adding a home screen shortcut failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add shortcut'**
  String get search_failedAddShortcut;

  /// Confirmation after hiding all suggested shortcuts from one website, with an Undo button. host is the website domain.
  ///
  /// In en, this message translates to:
  /// **'Hid all shortcuts from {host}'**
  String search_hidAllShortcutsFromHost(String host);

  /// Confirmation after removing a home screen shortcut, with an Undo button. title is the shortcut's name.
  ///
  /// In en, this message translates to:
  /// **'Removed \"{title}\"'**
  String search_removedSite(String title);

  /// Error message when removing a home screen shortcut failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove shortcut'**
  String get search_failedRemoveShortcut;

  /// Heading of the home screen card showing a random inspirational quote. A friendly, casual phrase.
  ///
  /// In en, this message translates to:
  /// **'A thought for the road'**
  String get search_quoteCardTitle;

  /// Tooltip of the button that shows a different random quote.
  ///
  /// In en, this message translates to:
  /// **'Refresh quote'**
  String get search_refreshQuoteTooltip;

  /// Text shown in the quote card when no quote is available, encouraging the user to start browsing.
  ///
  /// In en, this message translates to:
  /// **'Open a new tab and make this space your own.'**
  String get search_quotePlaceholder;

  /// Label of the main address field on the search screen, which accepts both search terms and web addresses.
  ///
  /// In en, this message translates to:
  /// **'Search or enter URL'**
  String get search_searchFieldLabel;

  /// Error message when the text entered in the address field cannot be opened as a web address.
  ///
  /// In en, this message translates to:
  /// **'Invalid address'**
  String get search_invalidAddress;

  /// Subtitle under a container's name in the search screen's Actions section; tapping the row switches to that container (a separate browsing identity).
  ///
  /// In en, this message translates to:
  /// **'Switch to container'**
  String get search_actionSwitchToContainer;

  /// Subtitle under a browser profile's name in the search screen's Actions section; tapping the row switches to that profile, which restarts the app.
  ///
  /// In en, this message translates to:
  /// **'Switch to this profile (restarts the browser)'**
  String get search_actionSwitchToProfile;

  /// Subtitle under a subscribed RSS/Atom feed's name in the search screen's Actions section; tapping the row opens the feed's articles.
  ///
  /// In en, this message translates to:
  /// **'Open feed'**
  String get search_actionOpenFeed;

  /// Where a setting found by the search screen's Actions section lives: the settings category and the section within it, shown under the setting's name. Tapping the row opens that settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings › {category} › {section}'**
  String search_actionSettingLocation(String category, String section);

  /// Shown under a settings screen found by the search screen's Actions section: where it lives. Tapping the row opens that settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings › {category}'**
  String search_actionSettingCategory(String category);

  /// Row title in the search screen's Actions section for a container the user never named.
  ///
  /// In en, this message translates to:
  /// **'Unnamed container'**
  String get search_actionUnnamedContainer;

  /// Row title in the search screen's Actions section for a subscribed feed that has no title.
  ///
  /// In en, this message translates to:
  /// **'Untitled feed'**
  String get search_actionUntitledFeed;

  /// Button that picks an item: a container in the container list, or the chosen color in the color picker.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get tabs_actionSelect;

  /// Button in the container list that deselects the currently selected container.
  ///
  /// In en, this message translates to:
  /// **'Unselect'**
  String get tabs_actionUnselect;

  /// Title of the dialog shown when leaving the container editor with unsaved changes.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get tabs_unsavedChangesTitle;

  /// Body of the unsaved-changes dialog in the container editor; its buttons are Cancel, Discard and Save.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to discard them or save?'**
  String get tabs_unsavedChangesConfirm;

  /// Title of the confirmation dialog before deleting a container (a separate browsing identity with its own tabs and cookies).
  ///
  /// In en, this message translates to:
  /// **'Delete Container'**
  String get tabs_deleteContainerTitle;

  /// Body of the confirmation dialog before deleting a container.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this container? Its tabs will be closed.'**
  String get tabs_deleteContainerConfirm;

  /// Checkbox in the delete-container dialog: also delete the browsing history recorded in this container.
  ///
  /// In en, this message translates to:
  /// **'Also delete browsing history'**
  String get tabs_deleteContainerAlsoDeleteHistory;

  /// Explanation under that checkbox: if left unticked, the history remains but no longer belongs to any container.
  ///
  /// In en, this message translates to:
  /// **'When this is unchecked, visits remain in history but are no longer assigned to a container.'**
  String get tabs_deleteContainerHistoryKeptNote;

  /// Button at the bottom of the container editor that deletes the container (asks for confirmation).
  ///
  /// In en, this message translates to:
  /// **'Delete Container'**
  String get tabs_deleteContainerButton;

  /// Title of the screen listing all containers. A container is a separate browsing identity with its own tabs, cookies and settings.
  ///
  /// In en, this message translates to:
  /// **'Containers'**
  String get tabs_containersTitle;

  /// Shown on the containers screen when no container exists.
  ///
  /// In en, this message translates to:
  /// **'No containers yet'**
  String get tabs_noContainersYet;

  /// Error heading when the list of containers could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Failed to load Containers'**
  String get tabs_loadContainersFailedTitle;

  /// Label of the floating button that creates a new container.
  ///
  /// In en, this message translates to:
  /// **'New Container'**
  String get tabs_containerFabLabel;

  /// Fallback name of a container that has tabs but no name.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get tabs_untitledContainer;

  /// Fallback label of a container that has no name and no tabs.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get tabs_emptyContainerLabel;

  /// Small label on a container card. count is the number of tabs in it.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 tab} other{{count} tabs}}'**
  String tabs_tabCountChip(int count);

  /// Small label on a container card: the container is pinned to the top of the list.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get tabs_chipPinned;

  /// Small label on a container card: the container keeps its own separate cookies and site data.
  ///
  /// In en, this message translates to:
  /// **'Isolated'**
  String get tabs_chipIsolated;

  /// Small label on a container card: the container ignores the app-wide proxy and connects directly.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get tabs_chipDirect;

  /// Small label on a container card: its cookies and site data are deleted when the app closes.
  ///
  /// In en, this message translates to:
  /// **'Clears on Exit'**
  String get tabs_chipClearOnExit;

  /// Small label on the currently selected container.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get tabs_chipActive;

  /// Title of the screen for choosing which container to switch to.
  ///
  /// In en, this message translates to:
  /// **'Select Container'**
  String get tabs_selectContainerTitle;

  /// Name of the pseudo-container holding tabs that belong to no container; shown in container pickers.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get tabs_unassignedTitle;

  /// Explanation under "Unassigned" in the container picker.
  ///
  /// In en, this message translates to:
  /// **'Tabs not assigned to a container'**
  String get tabs_unassignedSubtitle;

  /// Title of the screen where on-device AI suggests grouping open tabs into new containers.
  ///
  /// In en, this message translates to:
  /// **'Suggested Containers'**
  String get tabs_draftContainersTitle;

  /// Error heading when AI container suggestions could not be created.
  ///
  /// In en, this message translates to:
  /// **'Failed to load suggestions'**
  String get tabs_suggestionsFailedTitle;

  /// Title of the screen listing websites that always open in this container.
  ///
  /// In en, this message translates to:
  /// **'Site Assignments'**
  String get tabs_siteAssignmentsTitle;

  /// Label of the field for adding a website to the container's assigned sites.
  ///
  /// In en, this message translates to:
  /// **'Add site'**
  String get tabs_addSiteLabel;

  /// Example placeholder of the add-site field. Domain examples; keep them unchanged.
  ///
  /// In en, this message translates to:
  /// **'example.com or *.example.com'**
  String get tabs_addSiteHint;

  /// Help text under the add-site field: "*." matches all subdomains. Keep "*.example.com" unchanged.
  ///
  /// In en, this message translates to:
  /// **'Match a single site, or use *.example.com to match all its subdomains'**
  String get tabs_addSiteHelperText;

  /// Validation error when the add-site field is empty.
  ///
  /// In en, this message translates to:
  /// **'A URL must be provided'**
  String get tabs_urlMustBeProvided;

  /// Validation error when the add-site field does not contain a valid domain.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get tabs_invalidUrl;

  /// Validation error when the site is already in this container's list.
  ///
  /// In en, this message translates to:
  /// **'This site is already assigned'**
  String get tabs_siteAlreadyAssigned;

  /// Error message when the site is already assigned to a different container. site is the domain; containerName is that container's name.
  ///
  /// In en, this message translates to:
  /// **'{site} is already assigned to \"{containerName}\"'**
  String tabs_siteAlreadyAssignedToNamedContainer(
    String site,
    String containerName,
  );

  /// Error message when the site is already assigned to a different, unnamed container. site is the domain.
  ///
  /// In en, this message translates to:
  /// **'{site} is already assigned to another container'**
  String tabs_siteAlreadyAssignedToAnotherContainer(String site);

  /// Title of the container editor when creating a container.
  ///
  /// In en, this message translates to:
  /// **'New Container'**
  String get tabs_newContainerTitle;

  /// Title of the container editor when changing an existing container.
  ///
  /// In en, this message translates to:
  /// **'Edit Container'**
  String get tabs_editContainerTitle;

  /// Placeholder of the name field in the container editor.
  ///
  /// In en, this message translates to:
  /// **'Container Name'**
  String get tabs_containerNameHint;

  /// Item in the container appearance menu that opens the color picker.
  ///
  /// In en, this message translates to:
  /// **'Change Color'**
  String get tabs_changeColor;

  /// Item in the container appearance menu that opens the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Change Icon'**
  String get tabs_changeIcon;

  /// Section heading in the container editor for appearance settings.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get tabs_sectionDisplay;

  /// Switch in the container editor: keep the container at the top of lists.
  ///
  /// In en, this message translates to:
  /// **'Pin Container'**
  String get tabs_pinContainer;

  /// Explanation under the pin-container switch.
  ///
  /// In en, this message translates to:
  /// **'Keep this container at the top of the list'**
  String get tabs_pinContainerSubtitle;

  /// Title of the expandable section in the container editor for this container's own home page wallpaper.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper'**
  String get tabs_wallpaperLabel;

  /// Line under "Wallpaper" when the container has its own wallpaper.
  ///
  /// In en, this message translates to:
  /// **'Shown on home while this container is selected'**
  String get tabs_wallpaperSelectedSubtitle;

  /// Line under "Wallpaper" when the container uses the app-wide wallpaper.
  ///
  /// In en, this message translates to:
  /// **'Uses the wallpaper from settings'**
  String get tabs_wallpaperDefaultSubtitle;

  /// Shown in the container's wallpaper editor while no image is chosen.
  ///
  /// In en, this message translates to:
  /// **'This container falls back to the wallpaper set in settings.'**
  String get tabs_wallpaperEmptyDescription;

  /// Section heading in the container editor for privacy and security settings.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get tabs_sectionPrivacySecurity;

  /// Switch in the container editor: give the container its own separate cookies and site data. Can only be set when the container is created.
  ///
  /// In en, this message translates to:
  /// **'Cookie Isolation'**
  String get tabs_cookieIsolation;

  /// Row in the container editor for choosing a proxy that all of the container's traffic goes through.
  ///
  /// In en, this message translates to:
  /// **'Proxy Connection'**
  String get tabs_proxyConnectionLabel;

  /// Value of the proxy row when the container uses no proxy of its own.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get tabs_proxyConnectionNone;

  /// Switch in the container editor: this container does not use the app-wide proxy.
  ///
  /// In en, this message translates to:
  /// **'Bypass Global Proxy'**
  String get tabs_bypassGlobalProxy;

  /// Explanation under "Bypass Global Proxy": the container connects directly even when a proxy is set for the whole app.
  ///
  /// In en, this message translates to:
  /// **'Use the normal connection for this container when global routing is enabled'**
  String get tabs_bypassGlobalProxySubtitle;

  /// Switch in the container editor: delete this container's cookies and site data when the app closes.
  ///
  /// In en, this message translates to:
  /// **'Clear Data on Exit'**
  String get tabs_clearDataOnExit;

  /// Explanation under "Clear Data on Exit". Isolated tabs are tabs with their own separate temporary storage.
  ///
  /// In en, this message translates to:
  /// **'Clear cookies and site data for this container\'s regular tabs when the app closes. Isolated tabs keep separate data.'**
  String get tabs_clearDataOnExitSubtitle;

  /// Switch in the container editor: do not add pages from this container to the on-device full-text search.
  ///
  /// In en, this message translates to:
  /// **'Exclude from Search Index'**
  String get tabs_excludeFromSearchIndex;

  /// Explanation under "Exclude from Search Index".
  ///
  /// In en, this message translates to:
  /// **'Keep pages in this container out of the local search index'**
  String get tabs_excludeFromSearchIndexSubtitle;

  /// Switch in the container editor: do not record browsing history for this container.
  ///
  /// In en, this message translates to:
  /// **'Exclude from History'**
  String get tabs_excludeFromHistory;

  /// Explanation under "Exclude from History".
  ///
  /// In en, this message translates to:
  /// **'Don\'t record new visits from this container\'s tabs, and drop its pages from local search. Existing browsing history is kept.'**
  String get tabs_excludeFromHistorySubtitle;

  /// Section heading in the container editor for rules that send websites into this container.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get tabs_sectionAssignments;

  /// Row in the container editor that opens the list of websites always opened in this container.
  ///
  /// In en, this message translates to:
  /// **'Assigned Sites'**
  String get tabs_assignedSites;

  /// Line under "Assigned Sites". count is the number of site rules.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 rule configured} other{{count} rules configured}}'**
  String tabs_assignedSitesCount(int count);

  /// Line under "Assigned Sites" when there are none: explains that matching websites are opened in this container. "Origins" means websites.
  ///
  /// In en, this message translates to:
  /// **'Route matching origins into this container'**
  String get tabs_assignedSitesEmptySubtitle;

  /// Switch in the container editor: the container may load only its assigned sites.
  ///
  /// In en, this message translates to:
  /// **'Strict Mode'**
  String get tabs_strictMode;

  /// Explanation under "Strict Mode".
  ///
  /// In en, this message translates to:
  /// **'Only allow assigned sites to load; block everything else'**
  String get tabs_strictModeSubtitle;

  /// Line under a disabled container setting explaining that it needs "Cookie Isolation" to be turned on.
  ///
  /// In en, this message translates to:
  /// **'Requires cookie isolation to be enabled'**
  String get tabs_requiresCookieIsolation;

  /// Section heading in the container editor for opening links in installed apps.
  ///
  /// In en, this message translates to:
  /// **'App Links'**
  String get tabs_sectionAppLinks;

  /// Switch in the container editor: use separate open-in-app settings for this container.
  ///
  /// In en, this message translates to:
  /// **'Isolated App Link Settings'**
  String get tabs_isolatedAppLinkSettings;

  /// Explanation under "Isolated App Link Settings".
  ///
  /// In en, this message translates to:
  /// **'Use a separate open-in-app mode and remembered site rules for this container instead of the global settings'**
  String get tabs_isolatedAppLinkSettingsSubtitle;

  /// Row in the container editor that opens this container's own open-in-app settings.
  ///
  /// In en, this message translates to:
  /// **'App Link Behavior'**
  String get tabs_appLinkBehavior;

  /// Explanation under "App Link Behavior".
  ///
  /// In en, this message translates to:
  /// **'Configure this container\'s open-in-app mode and remembered sites'**
  String get tabs_appLinkBehaviorSubtitle;

  /// Title of the color picker dialog for a container.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get tabs_selectColorTitle;

  /// Title of the dialog for mixing a custom container color.
  ///
  /// In en, this message translates to:
  /// **'Custom Color'**
  String get tabs_customColorTitle;

  /// Label of the field for a color as a hexadecimal code (e.g. FF0000). Technical abbreviation.
  ///
  /// In en, this message translates to:
  /// **'Hex'**
  String get tabs_hexLabel;

  /// Label of the slider for the color's hue (its position on the color wheel).
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get tabs_hueLabel;

  /// Label of the slider for the color's saturation (how vivid it is).
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get tabs_saturationLabel;

  /// Label of the slider for the color's lightness.
  ///
  /// In en, this message translates to:
  /// **'Lightness'**
  String get tabs_lightnessLabel;

  /// Title of the sheet for choosing a container icon.
  ///
  /// In en, this message translates to:
  /// **'Choose Icon'**
  String get tabs_chooseIconTitle;

  /// Number of icons shown in the icon picker. count is the number of icons. "MDI" is the name of the icon set (Material Design Icons); keep it.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 MDI icon} other{{count} MDI icons}}'**
  String tabs_iconCountLabel(int count);

  /// Placeholder of the search field in the container icon picker. MDI is the name of the icon set (Material Design Icons).
  ///
  /// In en, this message translates to:
  /// **'Search MDI icons'**
  String get tabs_searchIconsHint;

  /// Shown when no icon matches the search in the container icon picker.
  ///
  /// In en, this message translates to:
  /// **'No icons found.'**
  String get tabs_noIconsFound;

  /// Title of the gesture settings screen (swipes and drawn gestures that trigger browser actions).
  ///
  /// In en, this message translates to:
  /// **'Gestures'**
  String get gestures_screenTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'swipe'**
  String get gestures_builtInGestureKeywords;

  /// Menu item on the gesture settings screen that restores the default actions of the built-in tab bar and tab swipes.
  ///
  /// In en, this message translates to:
  /// **'Reset Swipes to Defaults'**
  String get gestures_resetSwipesToDefaultsAction;

  /// Name of a fixed gesture in the tab overview: swiping sideways with two fingers.
  ///
  /// In en, this message translates to:
  /// **'Two-finger swipe'**
  String get gestures_twoFingerSwipeTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'container'**
  String get gestures_twoFingerSwipeKeywords;

  /// What the two-finger swipe in the tab overview does: switch to the next or previous container (a separate browsing identity).
  ///
  /// In en, this message translates to:
  /// **'Next or previous container'**
  String get gestures_twoFingerSwipeAction;

  /// Name of a fixed gesture in the tab overview: pinching with two fingers.
  ///
  /// In en, this message translates to:
  /// **'Pinch'**
  String get gestures_pinchTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'grid, list, tree, layout'**
  String get gestures_pinchKeywords;

  /// What pinching in the tab overview does: switch between grid, list and tree layouts of the tabs.
  ///
  /// In en, this message translates to:
  /// **'Grid, list or tree layout'**
  String get gestures_pinchAction;

  /// Section heading on the gesture settings screen for gestures used on web pages.
  ///
  /// In en, this message translates to:
  /// **'Web Pages'**
  String get gestures_webPagesSectionTitle;

  /// Switch that enables drawn gestures: drawing a stroke pattern (like "left, then down") on a page to run an action.
  ///
  /// In en, this message translates to:
  /// **'Drawn gestures'**
  String get gestures_drawnGesturesTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'stroke'**
  String get gestures_drawnGesturesKeywords;

  /// Explanation under "Drawn gestures".
  ///
  /// In en, this message translates to:
  /// **'Draw strokes on a page to run actions'**
  String get gestures_drawnGesturesSubtitle;

  /// Row, and screen title, for the list of drawn stroke patterns and the action each one runs.
  ///
  /// In en, this message translates to:
  /// **'Gesture bindings'**
  String get gestures_gestureBindingsTitle;

  /// Explanation under "Gesture bindings".
  ///
  /// In en, this message translates to:
  /// **'Strokes mapped to actions'**
  String get gestures_gestureBindingsSubtitle;

  /// Row, and screen title, for the sensitivity and timing settings of drawn gestures.
  ///
  /// In en, this message translates to:
  /// **'Behavior & timing'**
  String get gestures_behaviorTimingTitle;

  /// Summary under "Behavior & timing" listing the settings inside. A cooldown is a waiting time between gestures.
  ///
  /// In en, this message translates to:
  /// **'Stroke length, timeout, cooldown'**
  String get gestures_behaviorTimingSubtitleShort;

  /// Row, and screen title, for the list of websites where drawn gestures are turned off.
  ///
  /// In en, this message translates to:
  /// **'Excluded sites'**
  String get gestures_excludedSitesTitle;

  /// Explanation under "Excluded sites".
  ///
  /// In en, this message translates to:
  /// **'Disable gestures per site'**
  String get gestures_excludedSitesSubtitle;

  /// Row, and screen title, for the visual feedback shown while drawing a gesture.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get gestures_feedbackTitle;

  /// Summary under "Feedback": an on-screen overlay while drawing and suggestions of gestures that can be completed.
  ///
  /// In en, this message translates to:
  /// **'Live overlay and suggestions'**
  String get gestures_feedbackSubtitleShort;

  /// Switch for pull to refresh: dragging down at the top of a page reloads it.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get gestures_pullToRefreshTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'reload'**
  String get gestures_pullToRefreshKeywords;

  /// Explanation under "Pull to refresh".
  ///
  /// In en, this message translates to:
  /// **'Swipe down at the top of a page to reload it'**
  String get gestures_pullToRefreshSubtitle;

  /// Section heading on the gesture settings screen for gestures on toolbar buttons.
  ///
  /// In en, this message translates to:
  /// **'Toolbar'**
  String get gestures_toolbarSectionTitle;

  /// Row about long-pressing toolbar buttons; opens the toolbar customization where each button's long-press action is chosen.
  ///
  /// In en, this message translates to:
  /// **'Long press on buttons'**
  String get gestures_longPressButtonsTitle;

  /// Explanation under "Long press on buttons".
  ///
  /// In en, this message translates to:
  /// **'Chosen per button when customizing the toolbar'**
  String get gestures_longPressButtonsSubtitle;

  /// Line under a fixed gesture (such as pinch) that cannot be reassigned.
  ///
  /// In en, this message translates to:
  /// **'Built-in, cannot be changed'**
  String get gestures_builtInCannotBeChangedDescription;

  /// Option when choosing the action of a built-in swipe: the swipe does nothing.
  ///
  /// In en, this message translates to:
  /// **'Do nothing'**
  String get gestures_doNothingTitle;

  /// Explanation under "Do nothing".
  ///
  /// In en, this message translates to:
  /// **'The swipe is ignored'**
  String get gestures_doNothingSubtitle;

  /// Tooltip of the button that restores the default list of drawn gestures.
  ///
  /// In en, this message translates to:
  /// **'Restore default gestures'**
  String get gestures_restoreDefaultGesturesTooltip;

  /// Floating button that creates a new drawn gesture.
  ///
  /// In en, this message translates to:
  /// **'Add gesture'**
  String get gestures_addGestureButtonLabel;

  /// Title of the confirmation dialog before restoring the default drawn gestures.
  ///
  /// In en, this message translates to:
  /// **'Restore default gestures?'**
  String get gestures_restoreDefaultGesturesConfirmTitle;

  /// Body of the confirmation dialog before restoring the default drawn gestures.
  ///
  /// In en, this message translates to:
  /// **'Every gesture goes back to its default action. Your changes are lost.'**
  String get gestures_restoreDefaultGesturesConfirmContent;

  /// Shown when the list of drawn gestures is empty.
  ///
  /// In en, this message translates to:
  /// **'No gestures assigned yet.'**
  String get gestures_noGesturesAssignedMessage;

  /// Title of the dialog shown when saving a drawn gesture whose stroke pattern is already used.
  ///
  /// In en, this message translates to:
  /// **'Replace existing gesture?'**
  String get gestures_replaceExistingGestureTitle;

  /// Body of that dialog. action is the name of the action the pattern currently runs.
  ///
  /// In en, this message translates to:
  /// **'This stroke is already assigned to \"{action}\". Saving will replace that binding.'**
  String gestures_replaceExistingGestureContent(String action);

  /// Title of the editor for a new drawn gesture.
  ///
  /// In en, this message translates to:
  /// **'Create gesture'**
  String get gestures_createGestureTitle;

  /// Title of the editor for an existing drawn gesture.
  ///
  /// In en, this message translates to:
  /// **'Edit gesture'**
  String get gestures_editGestureTitle;

  /// Label of the row in the gesture editor showing the action the gesture runs; tapping it changes the action.
  ///
  /// In en, this message translates to:
  /// **'Target action'**
  String get gestures_targetActionLabel;

  /// Heading in the gesture editor for where on the screen the stroke must start.
  ///
  /// In en, this message translates to:
  /// **'Start position'**
  String get gestures_startPositionLabel;

  /// Label in the gesture editor for how many fingers draw the stroke.
  ///
  /// In en, this message translates to:
  /// **'Fingers'**
  String get gestures_fingersLabel;

  /// Heading in the gesture editor for the sequence of directions the gesture consists of.
  ///
  /// In en, this message translates to:
  /// **'Stroke pattern'**
  String get gestures_strokePatternLabel;

  /// Placeholder in the stroke pattern box until directions are entered with the arrow buttons below.
  ///
  /// In en, this message translates to:
  /// **'Draw a stroke pattern below'**
  String get gestures_drawStrokePatternPlaceholder;

  /// Button in the gesture editor that removes the last direction from the stroke pattern.
  ///
  /// In en, this message translates to:
  /// **'Undo last'**
  String get gestures_undoLastAction;

  /// Save button of the gesture editor when the pattern is already used by another action and will be moved.
  ///
  /// In en, this message translates to:
  /// **'Replace gesture'**
  String get gestures_replaceGestureButtonLabel;

  /// Save button of the gesture editor.
  ///
  /// In en, this message translates to:
  /// **'Save gesture'**
  String get gestures_saveGestureButtonLabel;

  /// Warning in the gesture editor. action is the name of the action the pattern currently runs.
  ///
  /// In en, this message translates to:
  /// **'Already assigned to \"{action}\". Saving replaces it.'**
  String gestures_collisionWarning(String action);

  /// Title of the list of browser actions to choose from for a gesture.
  ///
  /// In en, this message translates to:
  /// **'Choose action'**
  String get gestures_chooseActionTitle;

  /// Subtitle of the gesture behavior & timing screen listing what it contains.
  ///
  /// In en, this message translates to:
  /// **'Stroke length, timeout, and cooldown.'**
  String get gestures_behaviorTimingScreenSubtitle;

  /// Tooltip of the button that resets the gesture behavior & timing settings.
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults'**
  String get gestures_resetToDefaultsTooltip;

  /// Title of the confirmation dialog before resetting the gesture behavior & timing settings.
  ///
  /// In en, this message translates to:
  /// **'Reset behavior & timing?'**
  String get gestures_resetBehaviorTimingConfirmTitle;

  /// Body of the confirmation dialog before resetting gesture behavior & timing.
  ///
  /// In en, this message translates to:
  /// **'Stroke length, timeout, cooldown and stroke interval will be restored to their defaults. Your gesture bindings and other settings are kept.'**
  String get gestures_resetBehaviorTimingConfirmContent;

  /// Slider: how far a finger must move before the movement counts as a direction in a drawn gesture.
  ///
  /// In en, this message translates to:
  /// **'Minimum stroke length'**
  String get gestures_minStrokeLengthTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'size, length, sensitivity'**
  String get gestures_minStrokeLengthKeywords;

  /// Slider: how long drawing may pause before an unfinished gesture is dropped.
  ///
  /// In en, this message translates to:
  /// **'Timeout'**
  String get gestures_timeoutTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'delay'**
  String get gestures_timeoutKeywords;

  /// Explanation under the gesture timeout slider.
  ///
  /// In en, this message translates to:
  /// **'A stroke is dropped if no new direction is drawn within this time.'**
  String get gestures_timeoutDescription;

  /// Slider: the waiting time after one gesture before another can run.
  ///
  /// In en, this message translates to:
  /// **'Cooldown'**
  String get gestures_cooldownTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'interval'**
  String get gestures_cooldownKeywords;

  /// Explanation under the gesture cooldown slider.
  ///
  /// In en, this message translates to:
  /// **'Minimum delay between two gestures firing.'**
  String get gestures_cooldownDescription;

  /// Slider: the shortest allowed time between two direction changes in one gesture.
  ///
  /// In en, this message translates to:
  /// **'Stroke interval'**
  String get gestures_strokeIntervalTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'debounce, jitter, accidental'**
  String get gestures_strokeIntervalKeywords;

  /// Explanation under the stroke interval slider.
  ///
  /// In en, this message translates to:
  /// **'Minimum time between direction changes within one gesture. Faster changes abort the gesture, guarding against accidental triggers.'**
  String get gestures_strokeIntervalDescription;

  /// Value shown on a gesture timing slider when it is set to zero (the check is turned off).
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get gestures_offLabel;

  /// Explanation at the top of the excluded sites list. The domains are examples; keep them unchanged.
  ///
  /// In en, this message translates to:
  /// **'Gestures are disabled on these sites. Subdomains are included (e.g. \"example.com\" also covers \"m.example.com\").'**
  String get gestures_excludedSitesDescription;

  /// Shown when the excluded sites list is empty.
  ///
  /// In en, this message translates to:
  /// **'No sites excluded.'**
  String get gestures_noSitesExcludedMessage;

  /// Subtitle of the gesture feedback screen listing what it contains.
  ///
  /// In en, this message translates to:
  /// **'Live overlay and gesture suggestions.'**
  String get gestures_feedbackScreenSubtitle;

  /// Switch: show the stroke being drawn and the action it will run.
  ///
  /// In en, this message translates to:
  /// **'Live feedback'**
  String get gestures_liveFeedbackTitle;

  /// Explanation under "Live feedback".
  ///
  /// In en, this message translates to:
  /// **'Show the stroke and its action while you draw'**
  String get gestures_liveFeedbackSubtitle;

  /// Switch: while drawing, also show which other gestures can still be completed from the current stroke.
  ///
  /// In en, this message translates to:
  /// **'Suggest next'**
  String get gestures_suggestNextTitle;

  /// Explanation under "Suggest next".
  ///
  /// In en, this message translates to:
  /// **'Also show the other gestures you can complete'**
  String get gestures_suggestNextSubtitle;

  /// Slider: how many directions must be drawn before gesture suggestions appear.
  ///
  /// In en, this message translates to:
  /// **'Suggest after'**
  String get gestures_suggestAfterTitle;

  /// Value label of the "Suggest after" slider. count is the number of strokes (directions) drawn.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 stroke} other{{count} strokes}}'**
  String gestures_strokeCount(int count);

  /// Explanation under the "Suggest after" slider.
  ///
  /// In en, this message translates to:
  /// **'Number of strokes to draw before suggestions appear.'**
  String get gestures_suggestAfterDescription;

  /// Confirm button of the dialog that restores the default drawn gestures.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get gestures_actionRestore;

  /// Confirm button of the dialog that moves a stroke pattern from another action to this one.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get gestures_actionReplace;

  /// Section heading for the configurable swipes on the tab bar.
  ///
  /// In en, this message translates to:
  /// **'Tab Bar Swipes'**
  String get gestures_tabBarSurfaceTitle;

  /// Explanation of the tab bar swipes section. The side rail is the tab bar placed vertically at the side of the screen.
  ///
  /// In en, this message translates to:
  /// **'Swipes on the tab bar or the side rail'**
  String get gestures_tabBarSurfaceDescription;

  /// Section heading for the configurable swipes on tabs in the tab overview.
  ///
  /// In en, this message translates to:
  /// **'Tab View Swipes'**
  String get gestures_tabViewSurfaceTitle;

  /// Explanation of the tab overview swipes section.
  ///
  /// In en, this message translates to:
  /// **'Swipes on a tab in the tab list or grid'**
  String get gestures_tabViewSurfaceDescription;

  /// Name of a built-in swipe: swiping left along the tab bar.
  ///
  /// In en, this message translates to:
  /// **'Swipe left along the bar'**
  String get gestures_tabBarSwipeBackwardTitle;

  /// Note under that swipe: when the tab bar is a vertical side rail, swiping up does the same.
  ///
  /// In en, this message translates to:
  /// **'Swiping up on the side rail does the same'**
  String get gestures_tabBarSwipeBackwardDescription;

  /// Name of a built-in swipe: swiping right along the tab bar.
  ///
  /// In en, this message translates to:
  /// **'Swipe right along the bar'**
  String get gestures_tabBarSwipeForwardTitle;

  /// Note under that swipe: when the tab bar is a vertical side rail, swiping down does the same.
  ///
  /// In en, this message translates to:
  /// **'Swiping down on the side rail does the same'**
  String get gestures_tabBarSwipeForwardDescription;

  /// Name of a built-in swipe: swiping from the tab bar toward the nearest screen edge.
  ///
  /// In en, this message translates to:
  /// **'Swipe toward the screen edge'**
  String get gestures_tabBarSwipeOutwardTitle;

  /// Explanation of which direction that is for each tab bar position (bottom, top or side rail).
  ///
  /// In en, this message translates to:
  /// **'Down on a bottom bar, up on a top bar, sideways off a rail'**
  String get gestures_tabBarSwipeOutwardDescription;

  /// Name of a built-in swipe: swiping from the tab bar away from the screen edge, into the page.
  ///
  /// In en, this message translates to:
  /// **'Swipe away from the screen edge'**
  String get gestures_tabBarSwipeInwardTitle;

  /// Explanation of which direction that is for each tab bar position (bottom, top or side rail).
  ///
  /// In en, this message translates to:
  /// **'Up on a bottom bar, down on a top bar, sideways into the page on a rail'**
  String get gestures_tabBarSwipeInwardDescription;

  /// Name of a built-in swipe: swiping a tab card to the left in the tab overview.
  ///
  /// In en, this message translates to:
  /// **'Swipe a tab left'**
  String get gestures_tabSwipeLeftTitle;

  /// Note under that swipe: it affects the tab that was swiped, not the tab currently open.
  ///
  /// In en, this message translates to:
  /// **'Acts on the swiped tab, not the open one'**
  String get gestures_tabSwipeLeftDescription;

  /// Name of a built-in swipe: swiping a tab card to the right in the tab overview.
  ///
  /// In en, this message translates to:
  /// **'Swipe a tab right'**
  String get gestures_tabSwipeRightTitle;

  /// Note under that swipe: it affects the tab that was swiped, not the tab currently open.
  ///
  /// In en, this message translates to:
  /// **'Acts on the swiped tab, not the open one'**
  String get gestures_tabSwipeRightDescription;

  /// Start position option for a drawn gesture: the stroke may start anywhere on the screen.
  ///
  /// In en, this message translates to:
  /// **'Anywhere'**
  String get gestures_startPositionAnywhere;

  /// Start position option for a drawn gesture: the stroke must start at the left edge of the screen.
  ///
  /// In en, this message translates to:
  /// **'Left edge'**
  String get gestures_startPositionLeftEdge;

  /// Start position option for a drawn gesture: the stroke must start at the right edge of the screen.
  ///
  /// In en, this message translates to:
  /// **'Right edge'**
  String get gestures_startPositionRightEdge;

  /// Start position option for a drawn gesture: the stroke must start at the top edge of the screen.
  ///
  /// In en, this message translates to:
  /// **'Top edge'**
  String get gestures_startPositionTopEdge;

  /// Start position option for a drawn gesture: the stroke must start at the bottom edge of the screen.
  ///
  /// In en, this message translates to:
  /// **'Bottom edge'**
  String get gestures_startPositionBottomEdge;

  /// Start position option for a drawn gesture: the stroke must start in the left half of the screen.
  ///
  /// In en, this message translates to:
  /// **'Left half'**
  String get gestures_startPositionLeftHalf;

  /// Start position option for a drawn gesture: the stroke must start in the right half of the screen.
  ///
  /// In en, this message translates to:
  /// **'Right half'**
  String get gestures_startPositionRightHalf;

  /// Section heading on the behavior & timing screen for stroke recognition settings.
  ///
  /// In en, this message translates to:
  /// **'Strokes'**
  String get gestures_strokesSectionTitle;

  /// Summary of the minimum stroke length setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Minimum swipe length recognized as a direction'**
  String get gestures_indexMinStrokeLengthSubtitle;

  /// Section heading on the behavior & timing screen for timing settings.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get gestures_timingSectionTitle;

  /// Summary of the gesture timeout setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Drop a stroke if no new direction is drawn'**
  String get gestures_indexTimeoutSubtitle;

  /// Summary of the gesture cooldown setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Minimum delay between two gestures firing'**
  String get gestures_indexCooldownSubtitle;

  /// Summary of the stroke interval setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Reject a gesture when direction changes come too fast'**
  String get gestures_indexStrokeIntervalSubtitle;

  /// Section heading on the gesture feedback screen for the on-screen overlay shown while drawing.
  ///
  /// In en, this message translates to:
  /// **'Overlay'**
  String get gestures_overlaySectionTitle;

  /// Summary of the "Suggest after" setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Number of strokes to draw before suggestions appear'**
  String get gestures_indexSuggestAfterSubtitle;

  /// Title of the dialog shown when another app asks WebLibre to open a link, letting the user allow or block that app.
  ///
  /// In en, this message translates to:
  /// **'Open link in WebLibre?'**
  String get intentGatekeeper_dialogTitle;

  /// Body of the dialog shown when another app asks WebLibre to open a link. appName is the requesting app; browserName is the app name, WebLibre. Both placeholders are rendered in bold.
  ///
  /// In en, this message translates to:
  /// **'{appName} is trying to open a link in {browserName}.'**
  String intentGatekeeper_appIsTryingToOpenLink(
    String appName,
    String browserName,
  );

  /// Button in the link-request dialog: open the link and remember to always allow links from this app.
  ///
  /// In en, this message translates to:
  /// **'Always allow'**
  String get intentGatekeeper_alwaysAllow;

  /// Button in the link-request dialog: open this one link without remembering the choice.
  ///
  /// In en, this message translates to:
  /// **'Allow once'**
  String get intentGatekeeper_allowOnce;

  /// Button in the link-request dialog: refuse this one link without remembering the choice.
  ///
  /// In en, this message translates to:
  /// **'Block once'**
  String get intentGatekeeper_blockOnce;

  /// Button in the link-request dialog: refuse the link and remember to always block links from this app.
  ///
  /// In en, this message translates to:
  /// **'Always block'**
  String get intentGatekeeper_alwaysBlock;

  /// Title of the settings screen and of the overview dialog listing keyboard shortcuts for a hardware keyboard.
  ///
  /// In en, this message translates to:
  /// **'Keyboard Shortcuts'**
  String get keyboardShortcuts_title;

  /// Placeholder of the search field on the keyboard shortcuts screen; the user can search by action name or by key.
  ///
  /// In en, this message translates to:
  /// **'Search actions or keys'**
  String get keyboardShortcuts_searchHint;

  /// Shown on the keyboard shortcuts screen when the search matches no action.
  ///
  /// In en, this message translates to:
  /// **'No matching actions.'**
  String get keyboardShortcuts_noMatchingActions;

  /// Shown in the keyboard shortcuts overview dialog when no browser action has a key assigned.
  ///
  /// In en, this message translates to:
  /// **'No keys are assigned to browser actions.'**
  String get keyboardShortcuts_overviewNoneAssigned;

  /// Shown in the keyboard shortcuts overview dialog when the user has turned keyboard shortcuts off in settings.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts are switched off.'**
  String get keyboardShortcuts_overviewDisabled;

  /// Title of the switch at the top of the keyboard shortcuts screen that turns all shortcuts on or off.
  ///
  /// In en, this message translates to:
  /// **'Enable Keyboard Shortcuts'**
  String get keyboardShortcuts_enableTitle;

  /// Explanation under the switch that turns keyboard shortcuts on: browser actions can be triggered with keys on a physical keyboard, even while the web page is focused.
  ///
  /// In en, this message translates to:
  /// **'Browser actions on a hardware keyboard, even while a page has focus'**
  String get keyboardShortcuts_enableSubtitle;

  /// Shown under a browser action in the keyboard shortcuts list when it has no key assigned.
  ///
  /// In en, this message translates to:
  /// **'No shortcut'**
  String get keyboardShortcuts_noShortcut;

  /// Tooltip of a key-combination chip under an action; tapping it records a different combination.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get keyboardShortcuts_tooltipChange;

  /// Tooltip of the remove button on a key-combination chip. chord is the key combination as shown, e.g. "Ctrl+T".
  ///
  /// In en, this message translates to:
  /// **'Remove {chord}'**
  String keyboardShortcuts_tooltipRemoveChord(String chord);

  /// Tooltip of the button that restores one action's default key combinations.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get keyboardShortcuts_tooltipResetToDefault;

  /// Tooltip of the button that records a new key combination for an action, and title of the recording dialog opened by it.
  ///
  /// In en, this message translates to:
  /// **'Add shortcut'**
  String get keyboardShortcuts_addShortcut;

  /// Title of the dialog that records a replacement for an existing key combination.
  ///
  /// In en, this message translates to:
  /// **'Change shortcut'**
  String get keyboardShortcuts_changeShortcutTitle;

  /// Tooltip of the toolbar button that resets all keyboard shortcuts to their defaults.
  ///
  /// In en, this message translates to:
  /// **'Restore default shortcuts'**
  String get keyboardShortcuts_restoreDefaultsTooltip;

  /// Title of the confirmation dialog before resetting all keyboard shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Restore default shortcuts?'**
  String get keyboardShortcuts_restoreDefaultsTitle;

  /// Body of the confirmation dialog before resetting all keyboard shortcuts. The defaults are the keys Firefox uses.
  ///
  /// In en, this message translates to:
  /// **'Every action goes back to its Firefox default keys. Your changes are lost.'**
  String get keyboardShortcuts_restoreDefaultsContent;

  /// Instruction in the dialog that records a key combination. actionTitle is the name of the browser action being assigned.
  ///
  /// In en, this message translates to:
  /// **'Press the key combination for \"{actionTitle}\".'**
  String keyboardShortcuts_recorderInstructions(String actionTitle);

  /// Placeholder in the key recording dialog until the user presses keys; replaced by the pressed combination.
  ///
  /// In en, this message translates to:
  /// **'Waiting for keys…'**
  String get keyboardShortcuts_recorderWaitingForKeys;

  /// Error in the key recording dialog when the pressed key alone would be taken away from web pages (e.g. a letter or arrow key). Ctrl, Alt and Meta are keyboard key names.
  ///
  /// In en, this message translates to:
  /// **'Web pages need this key. Hold Ctrl, Alt or Meta with it, or use a function key.'**
  String get keyboardShortcuts_recorderProblemNotAssignable;

  /// Error in the key recording dialog when the pressed combination is already assigned to this same action.
  ///
  /// In en, this message translates to:
  /// **'This is already a shortcut for this action.'**
  String get keyboardShortcuts_recorderProblemAlreadyBound;

  /// Warning in the key recording dialog when the pressed combination belongs to another action. ownerTitle is that other action's name; saving removes the combination from it.
  ///
  /// In en, this message translates to:
  /// **'Currently used by \"{ownerTitle}\". Saving moves it here.'**
  String keyboardShortcuts_recorderTakesFromOther(String ownerTitle);

  /// Button in the keyboard shortcuts overview dialog that opens the settings screen for editing shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get keyboardShortcuts_actionCustomize;

  /// Save button of the key recording dialog when the combination will be moved from another action to this one.
  ///
  /// In en, this message translates to:
  /// **'Reassign'**
  String get keyboardShortcuts_actionReassign;

  /// Confirm button of the dialog that resets all keyboard shortcuts to their defaults.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get keyboardShortcuts_actionRestore;

  /// Button at the bottom of the first-run setup that goes back to the previous page.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get onboarding_actionPrevious;

  /// Button at the bottom of the first-run setup that goes to the next page.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboarding_actionNext;

  /// Button at the bottom of the first-run setup's welcome page when "Restore from Backup" is chosen; starts restoring a backup file.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get onboarding_actionRestore;

  /// Error message when restoring a backup during first-run setup fails because the current profile's data could not be read.
  ///
  /// In en, this message translates to:
  /// **'This profile could not be read, so nothing can be restored into it.'**
  String get onboarding_restoreTargetUnreadable;

  /// Heading of the first-run welcome page when the user has used WebLibre before (e.g. after a major update).
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get onboarding_welcomeBackTitle;

  /// Heading of the first-run welcome page for a new user. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'WebLibre is ready'**
  String get onboarding_welcomeReadyTitle;

  /// Label above the choice between quick start, custom setup and restoring a backup on the first-run welcome page.
  ///
  /// In en, this message translates to:
  /// **'Choose your onboarding experience:'**
  String get onboarding_chooseExperience;

  /// First-run setup choice: skip configuration and use recommended settings.
  ///
  /// In en, this message translates to:
  /// **'Quick Start'**
  String get onboarding_modeExpressTitle;

  /// Explanation under "Quick Start".
  ///
  /// In en, this message translates to:
  /// **'Use recommended defaults and get browsing.'**
  String get onboarding_modeExpressSubtitle;

  /// First-run setup choice: go through configuration pages one by one.
  ///
  /// In en, this message translates to:
  /// **'Custom Setup'**
  String get onboarding_modeDetailedTitle;

  /// Explanation under "Custom Setup" listing what can be configured. DNS is a technical abbreviation.
  ///
  /// In en, this message translates to:
  /// **'Configure DNS, toolbar, extensions, and more.'**
  String get onboarding_modeDetailedSubtitle;

  /// First-run setup choice: restore a profile from a backup file made earlier.
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup'**
  String get onboarding_modeRestoreTitle;

  /// Explanation under "Restore from Backup".
  ///
  /// In en, this message translates to:
  /// **'Import a profile from an encrypted backup file.'**
  String get onboarding_modeRestoreSubtitle;

  /// Heading of a notice on the welcome page shown to existing users after a major update.
  ///
  /// In en, this message translates to:
  /// **'A lot has changed!'**
  String get onboarding_updateNoticeTitle;

  /// Body of the notice shown to existing users after a major update, asking them to go through the setup pages again.
  ///
  /// In en, this message translates to:
  /// **'This update includes significant changes that require you to review your settings. Please go through the following pages to check your configuration.'**
  String get onboarding_updateNoticeBody;

  /// Point in the update notice: browser extensions may need to be checked because of known problems carrying them over to the new version.
  ///
  /// In en, this message translates to:
  /// **'Please re-check your extensions after this update due to known migration issues.'**
  String get onboarding_updateNoticeExtensions;

  /// Point in the update notice: going through setup does not reset existing settings.
  ///
  /// In en, this message translates to:
  /// **'Your existing settings will not be overridden unless you explicitly change them during this setup.'**
  String get onboarding_updateNoticeSettingsPreserved;

  /// Checkbox on the welcome page that must be ticked to continue. The text between <eula>…</eula> and <privacy>…</privacy> becomes a tappable link to the license agreement and the privacy policy; keep both tag pairs and translate the text inside them. EULA is short for End User License Agreement.
  ///
  /// In en, this message translates to:
  /// **'I have read and accept the <eula>EULA</eula> and <privacy>Privacy Policy</privacy>.'**
  String get onboarding_eulaAcceptance;

  /// Title of the page showing the full privacy policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get onboarding_privacyPolicy;

  /// Title of the page showing the full license agreement.
  ///
  /// In en, this message translates to:
  /// **'End User License Agreement'**
  String get onboarding_eulaDocumentTitle;

  /// Heading of the first-run setup page about optional AI features.
  ///
  /// In en, this message translates to:
  /// **'AI Features'**
  String get onboarding_aiFeaturesTitle;

  /// Switch that enables AI features that run only on the device, without sending data anywhere.
  ///
  /// In en, this message translates to:
  /// **'On-device AI'**
  String get onboarding_aiOnDeviceTitle;

  /// Explanation under the on-device AI switch. Containers are separate browsing identities; the AI suggests topics for them and which tabs belong together.
  ///
  /// In en, this message translates to:
  /// **'Local on-device features including container topic and tab suggestions'**
  String get onboarding_aiOnDeviceSubtitle;

  /// Heading of the notice box listing things to know about the AI features.
  ///
  /// In en, this message translates to:
  /// **'Things to keep in mind'**
  String get onboarding_aiWarningTitle;

  /// Bullet point in the AI notice box.
  ///
  /// In en, this message translates to:
  /// **'WebLibre uses a local AI model to analyze your open tab titles and suggest which containers to group the tabs into and what to name those containers. All processing happens entirely on your device.'**
  String get onboarding_aiWarningPoint1;

  /// Bullet point in the AI notice box.
  ///
  /// In en, this message translates to:
  /// **'AI enhancements operate entirely within your browser, keeping all data on your device. Local AI processing respects your privacy and provides faster suggestions for container groups and names. You can control this behavior at any time in Settings.'**
  String get onboarding_aiWarningPoint2;

  /// Bullet point in the AI notice box.
  ///
  /// In en, this message translates to:
  /// **'AI can sometimes make mistakes, so please review suggested group names and tab selections.'**
  String get onboarding_aiWarningPoint3;

  /// Heading of the first-run setup page for choosing search engines.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get onboarding_searchTitle;

  /// Label above the choice of default search engine.
  ///
  /// In en, this message translates to:
  /// **'Default Search Provider'**
  String get onboarding_searchDefaultProviderLabel;

  /// Button after the suggested search engines that opens a search across all available engines.
  ///
  /// In en, this message translates to:
  /// **'Search more'**
  String get onboarding_searchMore;

  /// Label above the choice of service that suggests search terms while typing.
  ///
  /// In en, this message translates to:
  /// **'Default Autocomplete Provider'**
  String get onboarding_searchDefaultAutocompleteLabel;

  /// Error heading when the list of search engines could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Could not load search engines'**
  String get onboarding_searchLoadFailedTitle;

  /// Heading of the first-run setup page for DNS over HTTPS, which encrypts the lookups that turn website names into addresses. Technical term; usually kept in English.
  ///
  /// In en, this message translates to:
  /// **'DNS over HTTPS'**
  String get onboarding_dohTitle;

  /// Heading of the first-run setup page for Android permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get onboarding_permissionsTitle;

  /// Switch that asks Android for permission to show notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get onboarding_permissionsNotificationsTitle;

  /// Explanation under the notifications permission switch: needed to report progress of downloads.
  ///
  /// In en, this message translates to:
  /// **'Required to notify you about downloads'**
  String get onboarding_permissionsNotificationsSubtitle;

  /// Switch that makes WebLibre the device's default browser.
  ///
  /// In en, this message translates to:
  /// **'Default Browser'**
  String get onboarding_permissionsDefaultBrowserTitle;

  /// Explanation under the default browser switch. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'Set WebLibre as your default browser'**
  String get onboarding_permissionsDefaultBrowserSubtitle;

  /// Heading of the first-run setup page for privacy and security settings. "Hardening" means stricter security settings.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Hardening'**
  String get onboarding_privacyTitle;

  /// Row that opens the settings for which languages websites are told the user prefers.
  ///
  /// In en, this message translates to:
  /// **'Browser Languages'**
  String get onboarding_privacyBrowserLanguagesTitle;

  /// Explanation under "Browser Languages".
  ///
  /// In en, this message translates to:
  /// **'Configure language preferences exposed to websites'**
  String get onboarding_privacyBrowserLanguagesSubtitle;

  /// Heading of a warning shown when several preferred languages are configured, which makes the browser easier to identify.
  ///
  /// In en, this message translates to:
  /// **'Multiple Languages Detected'**
  String get onboarding_multipleLanguagesDetectedTitle;

  /// Warning body. count is the number of configured languages; locales is a comma-separated list of language codes such as "en-US, de-DE". "Fingerprint" means to identify a browser by its unique characteristics.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{Your browser has {count} languages configured ({locales}).}} Websites can use your unique language combination to fingerprint and track you across the web.'**
  String onboarding_multipleLanguagesWarning(int count, String locales);

  /// Suggestion in the language warning. "Fingerprint surface" means the characteristics that make the browser identifiable.
  ///
  /// In en, this message translates to:
  /// **'Consider reducing your browser languages to a single language to minimize your fingerprint surface.'**
  String get onboarding_multipleLanguagesSuggestion;

  /// Button in the language warning that opens the language settings.
  ///
  /// In en, this message translates to:
  /// **'Review Languages'**
  String get onboarding_reviewLanguages;

  /// Switch that applies all recommended security settings to the browser engine (Gecko).
  ///
  /// In en, this message translates to:
  /// **'Complete Web Engine Hardening'**
  String get onboarding_webEngineHardeningTitle;

  /// Explanation under the web engine hardening switch.
  ///
  /// In en, this message translates to:
  /// **'Apply all recommended security hardening preferences to the web engine'**
  String get onboarding_webEngineHardeningSubtitle;

  /// Switch that turns on the strict set of protections against browser fingerprinting (identifying a browser by its unique characteristics).
  ///
  /// In en, this message translates to:
  /// **'Hardened Fingerprint Protection'**
  String get onboarding_fingerprintProtectionTitle;

  /// Explanation under the fingerprint protection switch.
  ///
  /// In en, this message translates to:
  /// **'Load comprehensive fingerprint protection defaults'**
  String get onboarding_fingerprintProtectionSubtitle;

  /// Heading of the warning box shown when strict fingerprint protection is on.
  ///
  /// In en, this message translates to:
  /// **'Compatibility Warning'**
  String get onboarding_compatibilityWarningTitle;

  /// Bullet point in the fingerprint protection warning. Canvas, navigator and media devices are names of web technologies that websites read to identify browsers.
  ///
  /// In en, this message translates to:
  /// **'Hardened fingerprint protection enables 60+ protection targets including canvas randomization, navigator spoofing, media device masking, and more.'**
  String get onboarding_fingerprintWarningPoint1;

  /// Bullet point in the fingerprint protection warning.
  ///
  /// In en, this message translates to:
  /// **'This may cause websites to break or behave unexpectedly. You can fine-tune individual targets in settings.'**
  String get onboarding_fingerprintWarningPoint2;

  /// Heading of the settings that stop websites from reaching devices on the user's local network.
  ///
  /// In en, this message translates to:
  /// **'Local Network Protection'**
  String get onboarding_localNetworkProtectionTitle;

  /// Explanation under "Local Network Protection".
  ///
  /// In en, this message translates to:
  /// **'Websites can try to reach your device and other devices on your home network, like routers, printers, or smart home devices. By default, known trackers are automatically blocked from doing this.'**
  String get onboarding_localNetworkProtectionSubtitle;

  /// Switch: require permission for every website that tries to reach local network devices, not only known trackers.
  ///
  /// In en, this message translates to:
  /// **'Block All Local Network Requests'**
  String get onboarding_blockAllLocalNetworkTitle;

  /// Explanation under the switch that blocks all local network requests.
  ///
  /// In en, this message translates to:
  /// **'Ask for permission before any website accesses devices on your home network, not just known trackers'**
  String get onboarding_blockAllLocalNetworkSubtitle;

  /// Heading of the first-run setup page for arranging the browser toolbar and screen layout.
  ///
  /// In en, this message translates to:
  /// **'Toolbar & Layout'**
  String get onboarding_toolbarLayoutTitle;

  /// Heading of the first-run setup page offering the uBlock Origin ad blocker. Product name; do not translate.
  ///
  /// In en, this message translates to:
  /// **'uBlock Origin'**
  String get onboarding_ublockTitle;

  /// Description of the uBlock Origin extension on its setup page. Uses Markdown: keep the ** markers around bold text. Names of people, products and filter lists stay unchanged.
  ///
  /// In en, this message translates to:
  /// **'uBlock Origin (uBO) is a CPU- and memory-efficient **wide-spectrum content blocker** by **Raymond Hill** and is available as a browser extension for WebLibre.\n\nBy default, it blocks ads, trackers, coin miners, pop-ups, annoying anti-blockers, malware sites, and more using **EasyList, EasyPrivacy, Peter Lowe\'s Blocklist, Online Malicious URL Blocklist, and uBO filter lists**.\n\nMany other lists are available to block additional content.'**
  String get onboarding_ublockDescription;

  /// Switch that installs the uBlock Origin browser extension. Product name; do not translate.
  ///
  /// In en, this message translates to:
  /// **'Install uBlock Origin Extension'**
  String get onboarding_ublockInstallTitle;

  /// Switch, available once uBlock Origin is being installed: apply WebLibre's recommended uBlock Origin settings.
  ///
  /// In en, this message translates to:
  /// **'Apply optimized defaults'**
  String get onboarding_ublockApplyDefaultsTitle;

  /// Explanation under "Apply optimized defaults": turns on WebLibre's own stricter filter lists in uBlock Origin.
  ///
  /// In en, this message translates to:
  /// **'Enable WebLibre hardening filter lists.'**
  String get onboarding_ublockApplyDefaultsSubtitle;

  /// Button next to the current log level on the proxy logs screen; opens the log level sheet.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get proxy_actionChange;

  /// Button that downloads the proxy list from the entered subscription address.
  ///
  /// In en, this message translates to:
  /// **'Fetch'**
  String get proxy_actionFetch;

  /// Button that selects every usable proxy found in a subscription for import.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get proxy_actionSelectAll;

  /// Tooltip or menu item: share the proxy logs, or share a proxy profile as a link.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get proxy_actionShare;

  /// Button or tooltip that starts a proxy connection.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get proxy_actionStart;

  /// Tooltip of the run button while a proxy connection is running: stop it.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get proxy_actionStop;

  /// Confirm button of the delete dialog when the proxy profile is running.
  ///
  /// In en, this message translates to:
  /// **'Stop and Delete'**
  String get proxy_actionStopAndDelete;

  /// Menu item that measures how fast a running proxy responds.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get proxy_actionTestConnection;

  /// Title of the screen listing proxy connections (Tor and user-configured proxy profiles).
  ///
  /// In en, this message translates to:
  /// **'Proxy Connections'**
  String get proxy_connectionsTitle;

  /// Floating button that adds a proxy profile.
  ///
  /// In en, this message translates to:
  /// **'Add Profile'**
  String get proxy_addProfile;

  /// Tooltip of the button that opens the proxy logs.
  ///
  /// In en, this message translates to:
  /// **'View logs'**
  String get proxy_viewLogsTooltip;

  /// Section heading above the list of user-configured proxy profiles.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get proxy_profilesSectionTitle;

  /// Error when proxy profiles could not be loaded. error is technical error text, usually English. Keep the line break (\n).
  ///
  /// In en, this message translates to:
  /// **'Failed to load proxy profiles:\n{error}'**
  String proxy_loadProfilesFailed(String error);

  /// Heading of the status card when at least one proxy is running.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get proxy_statusActive;

  /// Heading of the status card when no proxy is running.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get proxy_statusDisconnected;

  /// Line on the status card. running is how many proxies are running; total is how many exist.
  ///
  /// In en, this message translates to:
  /// **'{total, plural, =1{{running} of 1 proxy running} other{{running} of {total} proxies running}}'**
  String proxy_statusRoutingTraffic(int running, int total);

  /// Line on the status card when no proxy is running.
  ///
  /// In en, this message translates to:
  /// **'Tap a profile to connect'**
  String get proxy_statusTapToConnect;

  /// Tooltip of the button that stops every running proxy.
  ///
  /// In en, this message translates to:
  /// **'Stop all'**
  String get proxy_stopAllTooltip;

  /// Type label under the Tor entry in the proxy list ("onion routing" is how Tor works).
  ///
  /// In en, this message translates to:
  /// **'Onion routing'**
  String get proxy_onionRoutingLabel;

  /// Small chip on a proxy that starts automatically with the app. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Autostart'**
  String get proxy_autostartLabel;

  /// Tooltip of the autostart chip. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'Starts with WebLibre'**
  String get proxy_autostartTooltip;

  /// Tooltip of the chip showing the public IP address websites see when using this proxy. ip is that address.
  ///
  /// In en, this message translates to:
  /// **'Egress IP {ip}'**
  String proxy_egressIpTooltip(String ip);

  /// Chip text while a connection speed test runs. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Testing...'**
  String get proxy_latencyTesting;

  /// Tooltip of that chip.
  ///
  /// In en, this message translates to:
  /// **'Latency test running'**
  String get proxy_latencyTestRunningTooltip;

  /// Tooltip on a failed latency chip: the test could not run because this proxy profile is not started.
  ///
  /// In en, this message translates to:
  /// **'The profile is not running'**
  String get proxy_latencyNotRunningTooltip;

  /// Chip text when the connection speed test failed. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get proxy_latencyFailed;

  /// Chip showing the measured response time. ms is the number of milliseconds; "ms" is the unit abbreviation.
  ///
  /// In en, this message translates to:
  /// **'{ms} ms'**
  String proxy_latencyMilliseconds(int ms);

  /// Tooltip of the response time chip. statusCode is the HTTP status number (e.g. 204); ms is milliseconds.
  ///
  /// In en, this message translates to:
  /// **'HTTP {statusCode} in {ms} ms'**
  String proxy_latencyHttpStatusTooltip(int statusCode, int ms);

  /// Error message when starting a proxy failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to start proxy: {error}'**
  String proxy_startProxyFailed(String error);

  /// Error message when stopping a proxy failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to stop proxy: {error}'**
  String proxy_stopProxyFailed(String error);

  /// Error message when starting Tor failed. brand is "Tor™"; error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to start {brand}: {error}'**
  String proxy_startBrandFailed(String brand, String error);

  /// Error message when stopping Tor failed. brand is "Tor™"; error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to stop {brand}: {error}'**
  String proxy_stopBrandFailed(String brand, String error);

  /// Title of the dialog asking to start a proxy that a tab needs.
  ///
  /// In en, this message translates to:
  /// **'Start Proxy Connection?'**
  String get proxy_startConnectionDialogTitle;

  /// Body of that dialog. proxyTitle is the proxy's name.
  ///
  /// In en, this message translates to:
  /// **'This tab needs {proxyTitle}, but that connection is not running. Start it now?'**
  String proxy_startConnectionDialogContent(String proxyTitle);

  /// Title of the confirmation dialog before deleting a proxy profile.
  ///
  /// In en, this message translates to:
  /// **'Delete Profile?'**
  String get proxy_deleteProfileTitle;

  /// Body of that dialog. name is the profile's name. Secrets are stored passwords and keys.
  ///
  /// In en, this message translates to:
  /// **'Delete {name} and its stored secrets? Tabs and containers assigned to this profile will be blocked until you choose another proxy or clear the assignment.'**
  String proxy_deleteProfileConfirm(String name);

  /// Body of that dialog when the profile is running. name is the profile's name.
  ///
  /// In en, this message translates to:
  /// **'Stop {name}, then delete it and its stored secrets? Tabs and containers assigned to this profile will be blocked until you choose another proxy or clear the assignment.'**
  String proxy_deleteProfileConfirmRunning(String name);

  /// Error message when deleting a proxy profile failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete profile: {error}'**
  String proxy_deleteProfileFailed(String error);

  /// Title of the dialog that shares a proxy profile as a link or QR code. name is the profile's name.
  ///
  /// In en, this message translates to:
  /// **'Share \"{name}\"'**
  String proxy_shareDialogTitle(String name);

  /// Warning in that dialog: the link includes passwords and keys.
  ///
  /// In en, this message translates to:
  /// **'This link contains the full profile, including any stored credentials. Share carefully.'**
  String get proxy_shareDialogWarning;

  /// Confirmation after copying the share link.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get proxy_copiedToClipboard;

  /// Title of the proxy profile editor for an existing profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get proxy_editProfileTitle;

  /// Title of the proxy profile editor for a new profile.
  ///
  /// In en, this message translates to:
  /// **'New Profile'**
  String get proxy_newProfileTitle;

  /// Button that saves changes to an existing proxy profile.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get proxy_saveChanges;

  /// Button that creates the new proxy profile.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get proxy_createProfile;

  /// Section heading in the proxy editor for name, protocol and autostart.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get proxy_sectionGeneral;

  /// Section heading in the proxy editor for a custom DNS server (the service that turns website names into addresses).
  ///
  /// In en, this message translates to:
  /// **'DNS Override'**
  String get proxy_sectionDnsOverride;

  /// Tip at the bottom of the new-profile editor pointing to other ways to add a profile.
  ///
  /// In en, this message translates to:
  /// **'Tip: Use the add menu on the previous screen to import from a file, paste a share link, or scan a QR code.'**
  String get proxy_addMenuTip;

  /// Legal trademark notice. brand is "WireGuard®"; Jason A. Donenfeld is a person's name; WebLibre is the app name. Keep the legal meaning exact.
  ///
  /// In en, this message translates to:
  /// **'{brand} is a registered trademark of Jason A. Donenfeld; all rights reserved. WebLibre is not endorsed or sponsored by, or affiliated with, Jason A. Donenfeld.'**
  String proxy_wireGuardTrademarkDisclaimer(String brand);

  /// Import option for a WireGuard configuration file. brand is "WireGuard®".
  ///
  /// In en, this message translates to:
  /// **'{brand} config'**
  String proxy_wireGuardConfigLabel(String brand);

  /// Label of the proxy profile name field.
  ///
  /// In en, this message translates to:
  /// **'Profile Name'**
  String get proxy_fieldProfileName;

  /// Label of the proxy protocol field (e.g. SOCKS, Shadowsocks, WireGuard).
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get proxy_fieldProtocol;

  /// Help text under the protocol field when editing an existing profile.
  ///
  /// In en, this message translates to:
  /// **'Protocol is fixed once a profile is created.'**
  String get proxy_protocolFixedHelper;

  /// Protocol option in the proxy editor: enter a raw sing-box outbound configuration in JSON. "Outbound" is a sing-box term.
  ///
  /// In en, this message translates to:
  /// **'Custom Outbound'**
  String get proxy_customOutboundLabel;

  /// Switch in the proxy editor: connect this proxy when the app starts.
  ///
  /// In en, this message translates to:
  /// **'Start Automatically'**
  String get proxy_startAutomaticallyTitle;

  /// Explanation under that switch. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'Connect this profile when WebLibre starts, so tabs using it are ready without a prompt'**
  String get proxy_startAutomaticallySubtitle;

  /// Explanation of the DNS override section. brand is "WireGuard®". DoH means DNS over HTTPS.
  ///
  /// In en, this message translates to:
  /// **'Resolve names through a DNS server reachable over this connection (e.g., an internal DoH server behind a corporate {brand} tunnel). Leave this off to use automatic DNS handling.'**
  String proxy_dnsOverrideExplanation(String brand);

  /// Switch that turns on a custom DNS server for this proxy profile.
  ///
  /// In en, this message translates to:
  /// **'Use a profile-specific resolver'**
  String get proxy_dnsOverrideSwitchTitle;

  /// Label of the DNS server address field.
  ///
  /// In en, this message translates to:
  /// **'DNS server address'**
  String get proxy_fieldDnsServerAddress;

  /// Section heading in the custom outbound editor for the JSON configuration. "Outbound" is a sing-box term.
  ///
  /// In en, this message translates to:
  /// **'Outbound'**
  String get proxy_sectionOutbound;

  /// Section heading in the custom outbound editor for stored passwords and keys.
  ///
  /// In en, this message translates to:
  /// **'Secrets'**
  String get proxy_sectionSecrets;

  /// Label of the field for the sing-box outbound JSON. Technical term.
  ///
  /// In en, this message translates to:
  /// **'Outbound JSON'**
  String get proxy_fieldOutboundJson;

  /// Help text under the outbound JSON field. sing-box is a product name.
  ///
  /// In en, this message translates to:
  /// **'Public sing-box outbound object.'**
  String get proxy_outboundJsonHelper;

  /// Label of the field for secret values (passwords, keys) as JSON.
  ///
  /// In en, this message translates to:
  /// **'Secret JSON'**
  String get proxy_fieldSecretJson;

  /// Help text under the secret JSON field.
  ///
  /// In en, this message translates to:
  /// **'Optional values merged into the outbound at runtime.'**
  String get proxy_secretJsonHelper;

  /// Section heading in the proxy editor for server address and port.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get proxy_sectionConnection;

  /// Section heading in the proxy editor for username, password and keys.
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get proxy_sectionCredentials;

  /// Section heading in the proxy editor for protocol-specific settings.
  ///
  /// In en, this message translates to:
  /// **'Protocol Options'**
  String get proxy_sectionProtocolOptions;

  /// Section heading in the proxy editor for TLS encryption settings. Technical abbreviation.
  ///
  /// In en, this message translates to:
  /// **'TLS'**
  String get proxy_sectionTls;

  /// Section heading in the proxy editor for the transport layer (WebSocket, gRPC, etc.).
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get proxy_sectionTransport;

  /// Section heading in the proxy editor for connection multiplexing (sharing one connection for many requests).
  ///
  /// In en, this message translates to:
  /// **'Multiplex'**
  String get proxy_sectionMultiplex;

  /// Section heading in the proxy editor for low-level connection ("dial") options. sing-box term.
  ///
  /// In en, this message translates to:
  /// **'Dial'**
  String get proxy_sectionDial;

  /// Note under the proxy form: other options can be set with the Custom Outbound protocol.
  ///
  /// In en, this message translates to:
  /// **'Advanced protocol options can still be entered with Custom Outbound JSON.'**
  String get proxy_advancedOptionsHint;

  /// Default help text under secret fields: the value is kept in the device's encrypted storage.
  ///
  /// In en, this message translates to:
  /// **'Stored in secure storage.'**
  String get proxy_storedInSecureStorage;

  /// Value of an on/off field in the proxy editor that is not set, so the default applies.
  ///
  /// In en, this message translates to:
  /// **'Unset (uses default)'**
  String get proxy_booleanFieldUnset;

  /// Value of an on/off field in the proxy editor that is on.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get proxy_booleanFieldEnabled;

  /// Value of an on/off field in the proxy editor that is off.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get proxy_booleanFieldDisabled;

  /// Title of the sheet with the ways to add a proxy profile.
  ///
  /// In en, this message translates to:
  /// **'Add Connection'**
  String get proxy_addConnectionTitle;

  /// Line under that title.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to add a proxy profile.'**
  String get proxy_addConnectionSubtitle;

  /// Card in the add-proxy sheet: import from a link on the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Clipboard'**
  String get proxy_methodClipboardTitle;

  /// Explanation under "Clipboard". URI means a proxy link such as ss://… or vless://….
  ///
  /// In en, this message translates to:
  /// **'Paste a share link or URI'**
  String get proxy_methodClipboardSubtitle;

  /// Card in the add-proxy sheet: scan a QR code containing a proxy link.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get proxy_methodScanQrTitle;

  /// Explanation under "Scan QR".
  ///
  /// In en, this message translates to:
  /// **'From another device'**
  String get proxy_methodScanQrSubtitle;

  /// Card in the add-proxy sheet: import a list of proxies from a subscription address.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get proxy_methodSubscriptionTitle;

  /// Explanation under "Subscription".
  ///
  /// In en, this message translates to:
  /// **'Fetch from URL'**
  String get proxy_methodSubscriptionSubtitle;

  /// Card in the add-proxy sheet: import a configuration file.
  ///
  /// In en, this message translates to:
  /// **'Import file'**
  String get proxy_methodImportFileTitle;

  /// Explanation under "Import file". ".conf" and "sing-box JSON" are file types; keep them unchanged.
  ///
  /// In en, this message translates to:
  /// **'.conf or sing-box JSON'**
  String get proxy_methodImportFileSubtitle;

  /// Button in the add-proxy sheet that opens an empty profile editor.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get proxy_enterManually;

  /// Message when the clipboard has no text to import.
  ///
  /// In en, this message translates to:
  /// **'The clipboard is empty.'**
  String get proxy_clipboardEmpty;

  /// Title of the list of importable file types.
  ///
  /// In en, this message translates to:
  /// **'Import from file'**
  String get proxy_importFromFileTitle;

  /// Explanation under the WireGuard config option. "[Interface]" and "[Peer]" are literal file section names; keep them unchanged.
  ///
  /// In en, this message translates to:
  /// **'.conf file with [Interface]/[Peer]'**
  String get proxy_importFileWireGuardSubtitle;

  /// Import option for a sing-box outbound configuration in JSON. sing-box is a product name.
  ///
  /// In en, this message translates to:
  /// **'Sing-box outbound JSON'**
  String get proxy_importFileSingboxJsonTitle;

  /// List of protocol names supported by that import. Keep the names unchanged.
  ///
  /// In en, this message translates to:
  /// **'Shadowsocks, Trojan, VMess, VLESS, Hysteria, …'**
  String get proxy_importFileSingboxJsonSubtitle;

  /// Confirmation after importing a proxy profile. name is its name.
  ///
  /// In en, this message translates to:
  /// **'Imported profile \"{name}\"'**
  String proxy_importedProfileNamed(String name);

  /// Title of the screen that imports proxies from a subscription address.
  ///
  /// In en, this message translates to:
  /// **'Import Subscription'**
  String get proxy_importSubscriptionTitle;

  /// Label of the subscription address field.
  ///
  /// In en, this message translates to:
  /// **'Subscription URL'**
  String get proxy_fieldSubscriptionUrl;

  /// Error when the subscription address is not a complete https address.
  ///
  /// In en, this message translates to:
  /// **'Enter a full https:// subscription URL.'**
  String get proxy_subscriptionUrlRequired;

  /// Error on the subscription import screen: the server returned an error status. statusCode is the HTTP status number (such as 404).
  ///
  /// In en, this message translates to:
  /// **'The subscription server answered with HTTP {statusCode}.'**
  String proxy_subscriptionHttpError(int statusCode);

  /// Error on the subscription import screen: the request timed out.
  ///
  /// In en, this message translates to:
  /// **'The subscription server did not answer in time.'**
  String get proxy_subscriptionTimedOut;

  /// Error on the subscription import screen for any other failure. error is the technical reason, often English.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch the subscription: {error}'**
  String proxy_subscriptionFetchFailed(String error);

  /// Explanation of supported subscription formats. v2rayN is a product name; the ss://… entries are literal link prefixes.
  ///
  /// In en, this message translates to:
  /// **'Supports the v2rayN-style format: a base64-encoded list of ss://, vless://, vmess://, trojan://, hysteria2://, tuic:// and similar URIs. Routing rules from the subscription are ignored — only proxy nodes are imported.'**
  String get proxy_subscriptionFormatHint;

  /// Default name for an imported proxy without a name. n is a sequence number.
  ///
  /// In en, this message translates to:
  /// **'Imported {n}'**
  String proxy_importedProfileDefaultName(int n);

  /// Confirmation after importing proxies from a subscription. count is the number imported.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 profile} other{Imported {count} profiles}}'**
  String proxy_importedProfilesCount(int count);

  /// Import button on the subscription screen. count is the number of selected proxies.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Import 1 profile} other{Import {count} profiles}}'**
  String proxy_importProfilesCount(int count);

  /// Summary of a fetched subscription. usable is how many proxies ("nodes") can be imported; failed is how many could not be read.
  ///
  /// In en, this message translates to:
  /// **'{failed, plural, =0{{usable, plural, =1{1 usable node} other{{usable} usable nodes}}} =1{{usable, plural, =1{1 usable node, 1 failed} other{{usable} usable nodes, 1 failed}}} other{{usable, plural, =1{1 usable node, {failed} failed} other{{usable} usable nodes, {failed} failed}}}}'**
  String proxy_subscriptionNodeSummary(int usable, int failed);

  /// Title of the proxy logs screen.
  ///
  /// In en, this message translates to:
  /// **'Proxy Logs'**
  String get proxy_logsTitle;

  /// Tooltip of the button that copies all shown log lines.
  ///
  /// In en, this message translates to:
  /// **'Copy all'**
  String get proxy_logsCopyAllTooltip;

  /// Tooltip of the button that deletes the log.
  ///
  /// In en, this message translates to:
  /// **'Clear log'**
  String get proxy_logsClearTooltip;

  /// Subject line used when sharing the proxy logs (e.g. as an email subject). Lowercase.
  ///
  /// In en, this message translates to:
  /// **'proxy logs'**
  String get proxy_logsShareSubject;

  /// Message when copying or sharing is not possible because the level filter hides all lines.
  ///
  /// In en, this message translates to:
  /// **'No log lines match the current filter'**
  String get proxy_logsNoLinesMatchFilter;

  /// Confirmation after copying log lines. count is the number of lines.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Copied 1 line to clipboard} other{Copied {count} lines to clipboard}}'**
  String proxy_logsCopiedCount(int count);

  /// Screen-reader label of the "All" log level filter chip.
  ///
  /// In en, this message translates to:
  /// **'Show all levels'**
  String get proxy_logsShowAllLevels;

  /// Screen-reader label of the "Errors" log level filter chip.
  ///
  /// In en, this message translates to:
  /// **'Show errors only'**
  String get proxy_logsShowErrorsOnly;

  /// Screen-reader label of the "Warnings" log filter chip: shows lines of this level and every more severe one.
  ///
  /// In en, this message translates to:
  /// **'Show warnings and above'**
  String get proxy_logsShowWarningsAndAbove;

  /// Screen-reader label of the "Info" log filter chip: shows lines of this level and every more severe one.
  ///
  /// In en, this message translates to:
  /// **'Show info and above'**
  String get proxy_logsShowInfoAndAbove;

  /// Screen-reader label of the "Debug" log filter chip: shows lines of this level and every more severe one.
  ///
  /// In en, this message translates to:
  /// **'Show debug and above'**
  String get proxy_logsShowDebugAndAbove;

  /// Screen-reader label of the "Trace" log filter chip: shows lines of this level and every more severe one.
  ///
  /// In en, this message translates to:
  /// **'Show trace and above'**
  String get proxy_logsShowTraceAndAbove;

  /// Button that jumps to the newest log lines.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get proxy_logsLatest;

  /// Shown when the log has lines but none at the selected level.
  ///
  /// In en, this message translates to:
  /// **'No log lines at this level. Lower the display filter or increase the proxy\'s logging level.'**
  String get proxy_logsEmptyFiltered;

  /// Shown when the log is empty. brand is "Tor™".
  ///
  /// In en, this message translates to:
  /// **'No log lines yet. Start a proxy or {brand} to see output here.'**
  String proxy_logsEmpty(String brand);

  /// Line showing that the proxy log records only warnings and errors (the default). Shown on the proxy logs screen and under "Proxy Logs" in settings.
  ///
  /// In en, this message translates to:
  /// **'Recording warnings and errors'**
  String get proxy_recordingLevelWarn;

  /// Line showing that the proxy log records informational messages, which slows browsing. Shown on the proxy logs screen and under "Proxy Logs" in settings. "Info" is the log level name as shown in proxy_logVerbosityInfoLabel.
  ///
  /// In en, this message translates to:
  /// **'Recording info — this slows browsing'**
  String get proxy_recordingLevelInfo;

  /// Line showing that the proxy log records debugging messages, which slows browsing. Shown on the proxy logs screen and under "Proxy Logs" in settings. "Debug" is the log level name as shown in proxy_logVerbosityDebugLabel.
  ///
  /// In en, this message translates to:
  /// **'Recording debug — this slows browsing'**
  String get proxy_recordingLevelDebug;

  /// Line showing that the proxy log records everything, which slows browsing. Shown on the proxy logs screen and under "Proxy Logs" in settings. "Trace" is the log level name as shown in proxy_logVerbosityTraceLabel.
  ///
  /// In en, this message translates to:
  /// **'Recording trace — this slows browsing'**
  String get proxy_recordingLevelTrace;

  /// Log filter chip: show all lines. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get proxy_logLevelAll;

  /// Log filter chip and level name: most detailed messages. Technical term; keep short.
  ///
  /// In en, this message translates to:
  /// **'Trace'**
  String get proxy_logLevelTrace;

  /// Log filter chip and level name: debugging messages. Technical term; keep short.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get proxy_logLevelDebug;

  /// Log filter chip and level name: informational messages. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get proxy_logLevelInfo;

  /// Log filter chip: warnings and worse. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get proxy_logLevelWarnings;

  /// Log filter chip: errors only. Keep short.
  ///
  /// In en, this message translates to:
  /// **'Errors'**
  String get proxy_logLevelErrors;

  /// Title of the sheet for choosing how much the proxy records in its log.
  ///
  /// In en, this message translates to:
  /// **'Proxy log level'**
  String get proxy_logLevelSheetTitle;

  /// Explanation in that sheet.
  ///
  /// In en, this message translates to:
  /// **'Raise this only while diagnosing a problem, then put it back. Changing it restarts any running proxy.'**
  String get proxy_logLevelSheetExplanation;

  /// Warning in that sheet when a detailed level is selected.
  ///
  /// In en, this message translates to:
  /// **'Verbose logging writes a line for every connection and DNS lookup, which noticeably slows browsing.'**
  String get proxy_verboseLoggingWarning;

  /// Log level option: record only warnings and errors.
  ///
  /// In en, this message translates to:
  /// **'Warnings and errors'**
  String get proxy_logVerbosityWarnLabel;

  /// Log level option: record informational messages. Technical term.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get proxy_logVerbosityInfoLabel;

  /// Log level option: record debugging messages. Technical term.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get proxy_logVerbosityDebugLabel;

  /// Log level option: record everything. Technical term.
  ///
  /// In en, this message translates to:
  /// **'Trace'**
  String get proxy_logVerbosityTraceLabel;

  /// Explanation under the "Warnings and errors" log level.
  ///
  /// In en, this message translates to:
  /// **'Normal operation. Problems are still logged.'**
  String get proxy_logVerbosityWarnDescription;

  /// Explanation under the "Info" log level.
  ///
  /// In en, this message translates to:
  /// **'Every connection and DNS lookup. Slows browsing.'**
  String get proxy_logVerbosityInfoDescription;

  /// Explanation under the "Debug" log level.
  ///
  /// In en, this message translates to:
  /// **'Info plus protocol detail. Slows browsing.'**
  String get proxy_logVerbosityDebugDescription;

  /// Explanation under the "Trace" log level. sing-box is a product name.
  ///
  /// In en, this message translates to:
  /// **'Everything sing-box can say. Slows browsing a lot.'**
  String get proxy_logVerbosityTraceDescription;

  /// Placeholder name while the proxy list loads.
  ///
  /// In en, this message translates to:
  /// **'Loading proxy...'**
  String get proxy_loadingProxyTitle;

  /// Description of the Tor entry in proxy pickers. torBrand is "Tor™"; keep it unchanged.
  ///
  /// In en, this message translates to:
  /// **'Route through the {torBrand} network'**
  String proxy_torConnectionSubtitle(String torBrand);

  /// Title of the settings screen for which proxy carries which tabs' traffic.
  ///
  /// In en, this message translates to:
  /// **'Proxy Routing'**
  String get proxy_routingTitle;

  /// Subtitle of the proxy routing screen.
  ///
  /// In en, this message translates to:
  /// **'Choose which proxy carries regular and private tab traffic.'**
  String get proxy_routingSubtitle;

  /// Section heading for routing regular (non-private) tabs.
  ///
  /// In en, this message translates to:
  /// **'Regular Tabs'**
  String get proxy_routingSectionRegularTabs;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'routing'**
  String get proxy_routingSectionRegularTabsKeywords;

  /// Section heading for routing private tabs.
  ///
  /// In en, this message translates to:
  /// **'Private Tabs'**
  String get proxy_routingSectionPrivateTabs;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'private, incognito'**
  String get proxy_routingSectionPrivateTabsKeywords;

  /// Setting for how regular tabs are routed (per container or all through one proxy).
  ///
  /// In en, this message translates to:
  /// **'Regular Tabs Routing Mode'**
  String get proxy_routingRegularTabsModeTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'container, global'**
  String get proxy_routingRegularTabsModeKeywords;

  /// Explanation of that setting, also shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Choose how regular tabs are routed through proxies'**
  String get proxy_routingRegularTabsModeSubtitle;

  /// Setting for the proxy used when all regular tabs are routed through one proxy.
  ///
  /// In en, this message translates to:
  /// **'Proxy for global routing'**
  String get proxy_routingGlobalProxyTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'proxy'**
  String get proxy_routingGlobalProxyKeywords;

  /// Explanation of that setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Selected proxy when global routing is enabled'**
  String get proxy_routingGlobalProxySubtitle;

  /// Setting for the proxy used by private tabs.
  ///
  /// In en, this message translates to:
  /// **'Proxy for private tabs'**
  String get proxy_routingPrivateTabsProxyTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'proxy'**
  String get proxy_routingPrivateTabsProxyKeywords;

  /// Explanation of that setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Selected proxy that carries private-tab traffic'**
  String get proxy_routingPrivateTabsProxySubtitle;

  /// Routing mode option: each container chooses its own proxy.
  ///
  /// In en, this message translates to:
  /// **'Container-Based Routing'**
  String get proxy_routingContainerBasedTitle;

  /// Explanation under "Container-Based Routing".
  ///
  /// In en, this message translates to:
  /// **'Only tabs in containers with a proxy assigned are routed.'**
  String get proxy_routingContainerBasedSubtitle;

  /// Routing mode option: all regular tabs go through one proxy.
  ///
  /// In en, this message translates to:
  /// **'Global Routing'**
  String get proxy_routingGlobalRoutingTitle;

  /// Explanation under "Global Routing".
  ///
  /// In en, this message translates to:
  /// **'Route regular tabs through the selected proxy unless a container bypasses it.'**
  String get proxy_routingGlobalRoutingSubtitle;

  /// Shown instead of the proxy choice while container-based routing is selected.
  ///
  /// In en, this message translates to:
  /// **'Not used in container-based routing'**
  String get proxy_routingNotUsedTitle;

  /// Explanation under that message.
  ///
  /// In en, this message translates to:
  /// **'Switch to global routing above to pick the proxy that carries every regular tab.'**
  String get proxy_routingNotUsedSubtitle;

  /// Option in proxy pickers: use no proxy. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get proxy_routingNoneTitle;

  /// Explanation under "None".
  ///
  /// In en, this message translates to:
  /// **'Use the normal browser connection'**
  String get proxy_routingNoneSubtitle;

  /// Line under "Unknown proxy" when the chosen proxy was deleted.
  ///
  /// In en, this message translates to:
  /// **'The selected proxy no longer exists.'**
  String get proxy_routingUnknownProxySubtitle;

  /// Name shown for a chosen proxy that no longer exists.
  ///
  /// In en, this message translates to:
  /// **'Unknown proxy'**
  String get proxy_unknownProxyTitle;

  /// Default title of the sheet for picking a proxy connection.
  ///
  /// In en, this message translates to:
  /// **'Proxy Connection'**
  String get proxy_connectionPickerTitle;

  /// Line under "Unknown proxy" in the proxy picker.
  ///
  /// In en, this message translates to:
  /// **'This proxy profile no longer exists'**
  String get proxy_pickerUnknownProxySubtitle;

  /// Label of a field in the proxy profile editor for the sing-box option "server". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Server Address'**
  String get proxy_fieldServerAddress;

  /// Label of a field in the proxy profile editor for the sing-box option "server_port". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Server Port'**
  String get proxy_fieldServerPort;

  /// Label of a field in the proxy profile editor for the sing-box option "username". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get proxy_fieldUsername;

  /// Label of a field in the proxy profile editor for the sing-box option "password". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get proxy_fieldPassword;

  /// Label of a field in the proxy profile editor for the sing-box option "uuid". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'UUID'**
  String get proxy_fieldUuid;

  /// Label of a field in the proxy profile editor for the sing-box option "tls.enabled". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'TLS Enabled'**
  String get proxy_fieldTlsEnabled;

  /// Help text under a proxy editor field (sing-box option "tls.enabled"). "true" and "false" are literal values; keep them unchanged. Keep literal examples unchanged.
  ///
  /// In en, this message translates to:
  /// **'true or false.'**
  String get proxy_fieldTlsEnabledHelper;

  /// Label of a field in the proxy profile editor for the sing-box option "tls.server_name". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'TLS Server Name'**
  String get proxy_fieldTlsServerName;

  /// Label of a field in the proxy profile editor for the sing-box option "tls.insecure". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Allow Invalid TLS Certificates'**
  String get proxy_fieldTlsInsecure;

  /// Help text under a proxy editor field (sing-box option "tls.insecure"). "true" and "false" are literal values; keep them unchanged. Keep literal examples unchanged.
  ///
  /// In en, this message translates to:
  /// **'true or false.'**
  String get proxy_fieldTlsInsecureHelper;

  /// Label of a field in the proxy profile editor for the sing-box option "tls.alpn". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'TLS ALPN'**
  String get proxy_fieldTlsAlpn;

  /// Help text under a proxy editor field (sing-box option "tls.alpn"). Keep literal examples unchanged.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated or one value per line.'**
  String get proxy_fieldTlsAlpnHelper;

  /// Label of a field in the proxy profile editor for the sing-box option "transport.type". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Transport Type'**
  String get proxy_fieldTransportType;

  /// Help text under a proxy editor field (sing-box option "transport.type"). Keep literal examples unchanged.
  ///
  /// In en, this message translates to:
  /// **'For example ws, http, grpc, or quic.'**
  String get proxy_fieldTransportTypeHelper;

  /// Label of a field in the proxy profile editor for the sing-box option "transport.path". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Transport Path'**
  String get proxy_fieldTransportPath;

  /// Label of a field in the proxy profile editor for the sing-box option "transport.service_name". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'gRPC Service Name'**
  String get proxy_fieldGrpcServiceName;

  /// Label of a field in the proxy profile editor for the sing-box option "multiplex.enabled". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Multiplex Enabled'**
  String get proxy_fieldMultiplexEnabled;

  /// Help text under a proxy editor field (sing-box option "multiplex.enabled"). "true" and "false" are literal values; keep them unchanged. Keep literal examples unchanged.
  ///
  /// In en, this message translates to:
  /// **'true or false.'**
  String get proxy_fieldMultiplexEnabledHelper;

  /// Label of a field in the proxy profile editor for the sing-box option "multiplex.protocol". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Multiplex Protocol'**
  String get proxy_fieldMultiplexProtocol;

  /// Label of a field in the proxy profile editor for the sing-box option "multiplex.max_connections". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Multiplex Max Connections'**
  String get proxy_fieldMultiplexMaxConnections;

  /// Label of a field in the proxy profile editor for the sing-box option "detour". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Dial Detour'**
  String get proxy_fieldDialDetour;

  /// Label of a field in the proxy profile editor for the sing-box option "bind_interface". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Bind Interface'**
  String get proxy_fieldBindInterface;

  /// Label of a field in the proxy profile editor for the sing-box option "routing_mark". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Routing Mark'**
  String get proxy_fieldRoutingMark;

  /// Label of a field in the proxy profile editor for the sing-box option "domain_strategy". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Domain Strategy'**
  String get proxy_fieldDomainStrategy;

  /// Help text under a proxy editor field (sing-box option "domain_strategy"). Keep literal examples unchanged.
  ///
  /// In en, this message translates to:
  /// **'For example prefer_ipv4 or prefer_ipv6.'**
  String get proxy_fieldDomainStrategyHelper;

  /// Label of a field in the proxy profile editor for the sing-box option "connect_timeout". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Connect Timeout'**
  String get proxy_fieldConnectTimeout;

  /// Help text under a proxy editor field (sing-box option "connect_timeout"). Keep literal examples unchanged.
  ///
  /// In en, this message translates to:
  /// **'For example 5s.'**
  String get proxy_fieldConnectTimeoutHelper;

  /// Label of a field in the proxy profile editor for the sing-box option "version". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'SOCKS Version'**
  String get proxy_fieldSocksVersion;

  /// Label of a field in the proxy profile editor for the sing-box option "method". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get proxy_fieldMethod;

  /// Label of a field in the proxy profile editor for the sing-box option "security". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get proxy_fieldSecurity;

  /// Label of a field in the proxy profile editor for the sing-box option "alter_id". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Alter ID'**
  String get proxy_fieldAlterId;

  /// Label of a field in the proxy profile editor for the sing-box option "flow". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Flow'**
  String get proxy_fieldFlow;

  /// Label of a field in the proxy profile editor for the sing-box option "auth_str". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Auth String'**
  String get proxy_fieldAuthString;

  /// Label of a field in the proxy profile editor for the sing-box option "up". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Upload Bandwidth'**
  String get proxy_fieldUploadBandwidth;

  /// Label of a field in the proxy profile editor for the sing-box option "down". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Download Bandwidth'**
  String get proxy_fieldDownloadBandwidth;

  /// Label of a field in the proxy profile editor for the sing-box option "obfs". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Obfuscation'**
  String get proxy_fieldObfuscation;

  /// Label of a field in the proxy profile editor for the sing-box option "recv_window_conn". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Receive Window Conn'**
  String get proxy_fieldReceiveWindowConn;

  /// Label of a field in the proxy profile editor for the sing-box option "recv_window". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Receive Window'**
  String get proxy_fieldReceiveWindow;

  /// Label of a field in the proxy profile editor for the sing-box option "disable_mtu_discovery". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Disable MTU Discovery'**
  String get proxy_fieldDisableMtuDiscovery;

  /// Help text under a proxy editor field (sing-box option "disable_mtu_discovery"). "true" and "false" are literal values; keep them unchanged. Keep literal examples unchanged.
  ///
  /// In en, this message translates to:
  /// **'true or false.'**
  String get proxy_fieldDisableMtuDiscoveryHelper;

  /// Label of a field in the proxy profile editor for the sing-box option "up_mbps". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Upload Mbps'**
  String get proxy_fieldUploadMbps;

  /// Label of a field in the proxy profile editor for the sing-box option "down_mbps". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Download Mbps'**
  String get proxy_fieldDownloadMbps;

  /// Label of a field in the proxy profile editor for the sing-box option "obfs.type". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Obfuscation Type'**
  String get proxy_fieldObfuscationType;

  /// Label of a field in the proxy profile editor for the sing-box option "obfs.password". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Obfuscation Password'**
  String get proxy_fieldObfuscationPassword;

  /// Label of a field in the proxy profile editor for the sing-box option "congestion_control". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Congestion Control'**
  String get proxy_fieldCongestionControl;

  /// Label of a field in the proxy profile editor for the sing-box option "udp_relay_mode". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'UDP Relay Mode'**
  String get proxy_fieldUdpRelayMode;

  /// Label of a field in the proxy profile editor for the sing-box option "zero_rtt_handshake". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Zero RTT Handshake'**
  String get proxy_fieldZeroRttHandshake;

  /// Help text under a proxy editor field (sing-box option "zero_rtt_handshake"). "true" and "false" are literal values; keep them unchanged. Keep literal examples unchanged.
  ///
  /// In en, this message translates to:
  /// **'true or false.'**
  String get proxy_fieldZeroRttHandshakeHelper;

  /// Label of a field in the proxy profile editor for the sing-box option "user". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get proxy_fieldUser;

  /// Label of a field in the proxy profile editor for the sing-box option "private_key". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Private Key'**
  String get proxy_fieldPrivateKey;

  /// Label of a field in the proxy profile editor for the sing-box option "private_key_passphrase". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Private Key Passphrase'**
  String get proxy_fieldPrivateKeyPassphrase;

  /// Label of a field in the proxy profile editor for the sing-box option "local_address". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Local Address'**
  String get proxy_fieldLocalAddress;

  /// Help text under a proxy editor field (sing-box option "local_address"). Keep literal examples unchanged.
  ///
  /// In en, this message translates to:
  /// **'The address this device has inside the tunnel, one per line — for example, 10.0.0.2/32. A bare address is treated as a single address (/32, or /128 for IPv6).'**
  String get proxy_fieldLocalAddressHelper;

  /// Label of a field in the proxy profile editor for the sing-box option "peer_public_key". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Peer Public Key'**
  String get proxy_fieldPeerPublicKey;

  /// Label of a field in the proxy profile editor for the sing-box option "wireguardPrivateKey". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Private Key'**
  String get proxy_fieldWireguardPrivateKey;

  /// Help text under a proxy editor field (sing-box option "wireguardPrivateKey"). Keep literal examples unchanged.
  ///
  /// In en, this message translates to:
  /// **'Stored in secure storage, not profile JSON.'**
  String get proxy_fieldWireguardPrivateKeyHelper;

  /// Label of a field in the proxy profile editor for the sing-box option "pre_shared_key". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Pre-shared Key'**
  String get proxy_fieldPreSharedKey;

  /// Help text under a proxy editor field (sing-box option "pre_shared_key"). Keep literal examples unchanged.
  ///
  /// In en, this message translates to:
  /// **'Optional. Stored in secure storage.'**
  String get proxy_fieldPreSharedKeyHelper;

  /// Label of a field in the proxy profile editor for the sing-box option "mtu". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'MTU'**
  String get proxy_fieldMtu;

  /// Help text under a proxy editor field (sing-box option "mtu"). Keep literal examples unchanged.
  ///
  /// In en, this message translates to:
  /// **'Lower this if the tunnel connects but pages never load: packets larger than the path allows are dropped outright. A value of 1280 is safe almost everywhere; use around 1200 when already connected to another VPN.'**
  String get proxy_fieldMtuHelper;

  /// Label of a field in the proxy profile editor for the sing-box option "persistent_keepalive_interval". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Persistent Keepalive'**
  String get proxy_fieldPersistentKeepalive;

  /// Help text under the WireGuard persistent keepalive field (sing-box option "persistent_keepalive_interval"). NAT is a networking abbreviation; "0" is a literal value.
  ///
  /// In en, this message translates to:
  /// **'Seconds between keepalive packets. Phones often sit behind NAT; without keepalives, the mapping can expire while idle. The peer can then no longer reach the phone, so connections stall until the next handshake. Set to 0 to disable.'**
  String get proxy_fieldPersistentKeepaliveHelper;

  /// Label of a field in the proxy profile editor for the sing-box option "reserved". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Reserved Bytes'**
  String get proxy_fieldReservedBytes;

  /// Help text under a proxy editor field (sing-box option "reserved"). Keep literal examples unchanged.
  ///
  /// In en, this message translates to:
  /// **'Optional. Three comma-separated numbers, e.g. 0,0,0.'**
  String get proxy_fieldReservedBytesHelper;

  /// Label of a field in the proxy profile editor for the sing-box option "shadowTlsVersion". Technical networking term; keep established English terms where usual.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get proxy_fieldShadowTlsVersion;

  /// Validation error in the proxy editor. field is the field's label.
  ///
  /// In en, this message translates to:
  /// **'{field} is required.'**
  String proxy_fieldErrorRequired(String field);

  /// Validation error in the proxy editor. field is the field's label.
  ///
  /// In en, this message translates to:
  /// **'{field} must be a positive number.'**
  String proxy_fieldErrorNotPositiveNumber(String field);

  /// Validation error for a network port in the proxy editor. field is the field's label.
  ///
  /// In en, this message translates to:
  /// **'{field} must be between 1 and 65535.'**
  String proxy_fieldErrorPortRange(String field);

  /// Validation error in the proxy editor. field is the field's label; count is the required number of values.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{field} must contain 1 number.} other{{field} must contain {count} numbers.}}'**
  String proxy_fieldErrorListLength(String field, int count);

  /// Validation error in the proxy editor. field is the field's label.
  ///
  /// In en, this message translates to:
  /// **'{field} must contain only numbers.'**
  String proxy_fieldErrorNotAllNumbers(String field);

  /// Validation error in the proxy editor. field is the field's label; min is the smallest allowed value.
  ///
  /// In en, this message translates to:
  /// **'{field} must contain numbers greater than or equal to {min}.'**
  String proxy_fieldErrorBelowMin(String field, int min);

  /// Validation error in the proxy editor. field is the field's label; max is the largest allowed value.
  ///
  /// In en, this message translates to:
  /// **'{field} must contain numbers less than or equal to {max}.'**
  String proxy_fieldErrorAboveMax(String field, int max);

  /// Validation error in the proxy editor. field is the field's label; value is the invalid entry. "/prefix" refers to network notation like /32.
  ///
  /// In en, this message translates to:
  /// **'{field} must contain IP addresses, optionally with a /prefix — \"{value}\" is not one.'**
  String proxy_fieldErrorInvalidCidr(String field, String value);

  /// Validation error in the proxy editor. field is the field's label. "true" and "false" are literal values; keep them unchanged.
  ///
  /// In en, this message translates to:
  /// **'{field} must be true or false.'**
  String proxy_fieldErrorNotBoolean(String field);

  /// Validation error in the proxy editor. field is the field's label; values is a comma-separated list of allowed literal values.
  ///
  /// In en, this message translates to:
  /// **'{field} must be one of: {values}.'**
  String proxy_fieldErrorNotAllowedValue(String field, String values);

  /// Error when saving a proxy profile while a save is still running.
  ///
  /// In en, this message translates to:
  /// **'Profile is already saving.'**
  String get proxy_saveErrorAlreadySaving;

  /// Error when saving a proxy profile without a name.
  ///
  /// In en, this message translates to:
  /// **'Profile name is required.'**
  String get proxy_saveErrorNameRequired;

  /// Error when saving a proxy profile before it finished loading.
  ///
  /// In en, this message translates to:
  /// **'The profile is still loading. Please wait.'**
  String get proxy_saveErrorStillLoading;

  /// Error when the custom outbound configuration is not a JSON object.
  ///
  /// In en, this message translates to:
  /// **'Config must be a JSON object.'**
  String get proxy_saveErrorConfigNotJson;

  /// Error when the secret values are not a JSON object.
  ///
  /// In en, this message translates to:
  /// **'Secrets must be a JSON object.'**
  String get proxy_saveErrorSecretsNotJson;

  /// Error message when saving a proxy profile failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to save proxy profile: {error}'**
  String proxy_saveErrorUnexpected(String error);

  /// Error when the proxy profile to edit no longer exists.
  ///
  /// In en, this message translates to:
  /// **'Proxy profile not found.'**
  String get proxy_loadErrorNotFound;

  /// Error message when a proxy profile could not be loaded. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to load proxy profile: {error}'**
  String proxy_loadErrorFailed(String error);

  /// Error message shown when the QR code scanner cannot open because camera access was denied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission has not been granted.'**
  String get qrScanner_noCameraPermission;

  /// Title of the full-screen QR code scanner.
  ///
  /// In en, this message translates to:
  /// **'Scan code'**
  String get qrScanner_scanCodeTitle;

  /// Title of the search credits panel in account settings when the credit balance could not be loaded from the server.
  ///
  /// In en, this message translates to:
  /// **'Could not load credits'**
  String get searchCredits_couldNotLoadTitle;

  /// Title of the panel in account settings showing the user's balance of prepaid search credits (paid units for privacy-preserving web search).
  ///
  /// In en, this message translates to:
  /// **'Search credits'**
  String get searchCredits_title;

  /// Line under "Could not load credits" telling the user to retry with the refresh button next to it.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and tap refresh to retry.'**
  String get searchCredits_errorSubtitle;

  /// Line under the search credits title when the user has never bought credits.
  ///
  /// In en, this message translates to:
  /// **'Buy a search pack to get started'**
  String get searchCredits_emptySubtitle;

  /// Balance line of the search credits panel. credits is the remaining credits, allowance is the monthly allowance of the user's plan, stash is the number of anonymous search tokens already downloaded to the device. Keep the "·" separators.
  ///
  /// In en, this message translates to:
  /// **'Credits: {credits} / {allowance}  ·  Stashed tokens: {stash}'**
  String searchCredits_creditsWithAllowance(
    int credits,
    int allowance,
    int stash,
  );

  /// Balance line of the search credits panel for users without a monthly allowance. credits is the remaining credits, stash is the number of anonymous search tokens already downloaded to the device. Keep the "·" separator.
  ///
  /// In en, this message translates to:
  /// **'Credits: {credits}  ·  Stashed tokens: {stash}'**
  String searchCredits_creditsNoAllowance(int credits, int stash);

  /// Tooltip of the button that reloads the search credit balance.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get searchCredits_tooltipRefresh;

  /// Line in the search credits panel. date is the formatted date when the monthly credit allowance renews.
  ///
  /// In en, this message translates to:
  /// **'Resets on {date}'**
  String searchCredits_resetsOn(String date);

  /// Line in the search credits panel about when search tokens were last downloaded. relative is a relative time such as "5 minutes ago"; absolute is the formatted date and time.
  ///
  /// In en, this message translates to:
  /// **'Last issuance: {relative}  ({absolute})'**
  String searchCredits_lastIssuance(String relative, String absolute);

  /// Progress text shown while the app downloads new anonymous search tokens.
  ///
  /// In en, this message translates to:
  /// **'Requesting tokens...'**
  String get searchCredits_requestingTokens;

  /// Error line when downloading anonymous search tokens failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Token issuance failed: {error}'**
  String searchCredits_issuanceFailed(String error);

  /// Error line when downloading search tokens failed because the account session expired; the user must sign in to their WebLibre account again.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to request tokens.'**
  String get searchCredits_needsReauth;

  /// Row in the search credits panel that opens the store page for buying a first pack of search credits.
  ///
  /// In en, this message translates to:
  /// **'Buy a search pack'**
  String get searchCredits_buySearchPackTitle;

  /// Row in the search credits panel that converts credits into anonymous search tokens stored on the device.
  ///
  /// In en, this message translates to:
  /// **'Get tokens'**
  String get searchCredits_getTokensTitle;

  /// Subtitle under "Get tokens" saying how many search tokens a tap will request. count is at most 25.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Request 1 token} other{Request {count} tokens}}'**
  String searchCredits_requestTokensCount(int count);

  /// Subtitle under "Get tokens" when no credits are left to convert into tokens.
  ///
  /// In en, this message translates to:
  /// **'No credits remaining'**
  String get searchCredits_noCreditsRemaining;

  /// Row in the search credits panel that opens the store page for buying more search credits.
  ///
  /// In en, this message translates to:
  /// **'Buy more'**
  String get searchCredits_buyMoreTitle;

  /// Title of the advanced settings screen.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get settings_advancedTitle;

  /// Subtitle of the advanced settings screen listing what it contains.
  ///
  /// In en, this message translates to:
  /// **'Engine behavior, runtime overrides, and developer tools.'**
  String get settings_advancedSubtitle;

  /// Switch that turns JavaScript on web pages on or off. JavaScript is a product name.
  ///
  /// In en, this message translates to:
  /// **'Enable JavaScript'**
  String get settings_javascriptTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'javascript'**
  String get settings_javascriptKeywords;

  /// Explanation under the JavaScript switch.
  ///
  /// In en, this message translates to:
  /// **'Turning off JavaScript can improve security, privacy, and speed, but may cause some sites not to work as intended.'**
  String get settings_javascriptSubtitle;

  /// Label of the text field for a custom user agent: the text the browser sends to identify itself to websites. "User agent" is a technical term.
  ///
  /// In en, this message translates to:
  /// **'Custom User Agent'**
  String get settings_userAgentLabel;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'ua'**
  String get settings_userAgentLabelKeywords;

  /// Switch: trust certificate authorities installed on the device by the user or an organization. CA stands for certificate authority.
  ///
  /// In en, this message translates to:
  /// **'Use third-party CA certificates'**
  String get settings_enterpriseRootsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'certificates, enterprise roots, ca'**
  String get settings_enterpriseRootsKeywords;

  /// Explanation under that switch. CA stands for certificate authority.
  ///
  /// In en, this message translates to:
  /// **'Allows the use of third-party certificates from the Android CA store'**
  String get settings_enterpriseRootsSubtitle;

  /// Row in advanced settings that opens experimental (unstable) options.
  ///
  /// In en, this message translates to:
  /// **'Experimental Features'**
  String get settings_experimentalFeaturesTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'runtime, startup'**
  String get settings_experimentalFeaturesKeywords;

  /// Explanation under "Experimental Features".
  ///
  /// In en, this message translates to:
  /// **'Low-level runtime features and startup behavior'**
  String get settings_experimentalFeaturesSubtitle;

  /// Developer switch: remove the web page view from memory while another full-screen screen covers it. "Engine" means the browser engine.
  ///
  /// In en, this message translates to:
  /// **'Unmount Engine Off-Screen'**
  String get settings_unmountGeckoViewTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'geckoview, memory, performance, suspend'**
  String get settings_unmountGeckoViewKeywords;

  /// Long explanation under that switch describing the memory trade-off.
  ///
  /// In en, this message translates to:
  /// **'Remove the web engine from memory while a full-screen view (such as settings, tabs, or search) is open, then rebuild it when you return. This frees resources in the meantime. Returning to the page requires reattaching the engine and may cause a flicker or reload, so this trades performance for memory rather than fixing a problem. On Android 12 and earlier, the engine is always unmounted.'**
  String get settings_unmountGeckoViewSubtitle;

  /// Row in advanced settings showing the storage used by saved website icons, with a clear button.
  ///
  /// In en, this message translates to:
  /// **'Icon Cache'**
  String get settings_iconCacheTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'favicons, cache'**
  String get settings_iconCacheKeywords;

  /// Explanation under "Icon Cache": saved website icons (favicons).
  ///
  /// In en, this message translates to:
  /// **'Stored favicons'**
  String get settings_iconCacheSubtitle;

  /// Label in front of the size of the icon cache; the value is shown in MB.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get settings_iconCacheSizeLabel;

  /// Label of a clear button while clearing runs.
  ///
  /// In en, this message translates to:
  /// **'Clearing'**
  String get settings_clearingAction;

  /// Row in advanced settings showing downloaded AI model files, with a clear button. ML means machine learning.
  ///
  /// In en, this message translates to:
  /// **'ML Downloads'**
  String get settings_mlDownloadsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'ai, ml, models, onnx, cache'**
  String get settings_mlDownloadsKeywords;

  /// Explanation under "ML Downloads".
  ///
  /// In en, this message translates to:
  /// **'Downloaded AI models and runtime files'**
  String get settings_mlDownloadsSubtitle;

  /// Title of the confirmation dialog before deleting downloaded AI model files.
  ///
  /// In en, this message translates to:
  /// **'Clear ML downloads?'**
  String get settings_mlDownloadsClearDialogTitle;

  /// Body of that dialog. ONNX is a technical name; WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'This clears downloaded AI models and ONNX runtime files for this profile. They will be downloaded again when needed. Restart WebLibre before retrying ML features.'**
  String get settings_mlDownloadsClearDialogContent;

  /// Confirmation after deleting downloaded AI model files. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'ML downloads cleared. Restart WebLibre before retrying.'**
  String get settings_mlDownloadsClearedMessage;

  /// Error message when deleting AI model files failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear ML downloads: {error}'**
  String settings_mlDownloadsClearFailedMessage(String error);

  /// Title of the error log screen, and of the row that opens it.
  ///
  /// In en, this message translates to:
  /// **'Error Logs'**
  String get settings_errorLogsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'logs'**
  String get settings_errorLogsKeywords;

  /// Explanation under "Error Logs".
  ///
  /// In en, this message translates to:
  /// **'View and copy logs for issue reporting'**
  String get settings_errorLogsSubtitle;

  /// Developer-only row (debug builds). "Dart VM" is a technical name; do not translate.
  ///
  /// In en, this message translates to:
  /// **'Dart VM'**
  String get settings_dartVmTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'service url'**
  String get settings_dartVmKeywords;

  /// Explanation under "Dart VM" (debug builds only).
  ///
  /// In en, this message translates to:
  /// **'Copy Dart VM service URL'**
  String get settings_dartVmSubtitle;

  /// Text copied instead of the service address when it is unavailable (debug builds only).
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get settings_dartVmCopyErrorFallback;

  /// Confirmation after copying the Dart VM service address (debug builds only).
  ///
  /// In en, this message translates to:
  /// **'Service URL copied'**
  String get settings_serviceUrlCopiedMessage;

  /// Row in advanced settings that rebuilds the whole app interface (troubleshooting).
  ///
  /// In en, this message translates to:
  /// **'Reset UI'**
  String get settings_resetUiTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'refresh ui'**
  String get settings_resetUiKeywords;

  /// Explanation under "Reset UI".
  ///
  /// In en, this message translates to:
  /// **'Rebuild the entire browser UI'**
  String get settings_resetUiSubtitle;

  /// Title of the screen for choosing a custom Mozilla add-on collection as the extension store source.
  ///
  /// In en, this message translates to:
  /// **'Custom Extension Collection'**
  String get settings_addonCollectionTitle;

  /// Section heading for the collection address fields.
  ///
  /// In en, this message translates to:
  /// **'Collection Source'**
  String get settings_addonCollectionSourceSectionTitle;

  /// Title of the collection configuration entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Collection configuration'**
  String get settings_addonCollectionConfigTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'addons, collection'**
  String get settings_addonCollectionConfigKeywords;

  /// Summary of that entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Mozilla server, collection owner, and collection name'**
  String get settings_addonCollectionConfigSubtitle;

  /// Label of the field for the add-on server address.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get settings_addonCollectionServerUrlLabel;

  /// Label of the field for the account that owns the add-on collection.
  ///
  /// In en, this message translates to:
  /// **'Collection User'**
  String get settings_addonCollectionUserLabel;

  /// Label of the field for the add-on collection's name.
  ///
  /// In en, this message translates to:
  /// **'Collection Name'**
  String get settings_addonCollectionNameLabel;

  /// Section heading on the add-on collection screen for the save button.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get settings_addonCollectionActionsSectionTitle;

  /// Button that saves the collection and restarts the app.
  ///
  /// In en, this message translates to:
  /// **'Save & Restart Browser'**
  String get settings_addonCollectionSaveRestartTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'restart'**
  String get settings_addonCollectionSaveRestartKeywords;

  /// Explanation of that button, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Apply the custom collection and restart the browser'**
  String get settings_addonCollectionSaveRestartSubtitle;

  /// Title of the bang settings screen and of the row that opens it. A bang is a shortcut like "!w" for searching a specific site.
  ///
  /// In en, this message translates to:
  /// **'Bang Settings'**
  String get settings_bangSettingsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'shortcuts, bangs'**
  String get settings_bangSettingsKeywords;

  /// Subtitle of the bang settings screen listing what it contains.
  ///
  /// In en, this message translates to:
  /// **'Bang shortcuts usage, repositories, and on-demand sync.'**
  String get settings_bangSettingsSubtitle;

  /// Row in bang settings showing recorded bang usage, with a clear button.
  ///
  /// In en, this message translates to:
  /// **'Bang Frequencies'**
  String get settings_bangFrequenciesTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'usage, recommendations'**
  String get settings_bangFrequenciesKeywords;

  /// Explanation under "Bang Frequencies".
  ///
  /// In en, this message translates to:
  /// **'Tracked usage for bang recommendations'**
  String get settings_bangFrequenciesSubtitle;

  /// Title of the browsing settings screen and its category.
  ///
  /// In en, this message translates to:
  /// **'Browsing'**
  String get settings_browsingTitle;

  /// Subtitle of the browsing settings screen listing what it contains. Keep "Small Web" consistent with that feature.
  ///
  /// In en, this message translates to:
  /// **'Tabs, navigation, app links, and Small Web behavior.'**
  String get settings_browsingSubtitle;

  /// Setting for which kind of tab (regular, private, isolated) new tabs are by default.
  ///
  /// In en, this message translates to:
  /// **'New Tab Default'**
  String get settings_newTabDefaultTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'regular, private, isolated'**
  String get settings_newTabDefaultKeywords;

  /// Explanation under "New Tab Default".
  ///
  /// In en, this message translates to:
  /// **'Choose the default type for manually created tabs'**
  String get settings_newTabDefaultSubtitle;

  /// Choice of tab kind: regular tab. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get settings_tabTypeRegularLabel;

  /// Choice of tab kind: private tab. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get settings_tabTypePrivateLabel;

  /// Choice of tab kind: isolated tab (own separate cookies and site data). Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Isolated'**
  String get settings_tabTypeIsolatedLabel;

  /// Setting for which kind of tab Small Web browsing opens in.
  ///
  /// In en, this message translates to:
  /// **'Small Web Tab Default'**
  String get settings_smallWebTabDefaultTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'regular, private, isolated'**
  String get settings_smallWebTabDefaultKeywords;

  /// Explanation under that setting.
  ///
  /// In en, this message translates to:
  /// **'Choose the tab type used when entering Small Web'**
  String get settings_smallWebTabDefaultSubtitle;

  /// Setting for how links opened from other apps are opened.
  ///
  /// In en, this message translates to:
  /// **'External Link Handling'**
  String get settings_externalLinkHandlingTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'intents'**
  String get settings_externalLinkHandlingKeywords;

  /// Explanation under that setting. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'Choose how external links open in WebLibre'**
  String get settings_externalLinkHandlingSubtitle;

  /// Option: ask each time how to open the link.
  ///
  /// In en, this message translates to:
  /// **'Prompt'**
  String get settings_promptOptionLabel;

  /// Explanation under the "Prompt" option for links from other apps.
  ///
  /// In en, this message translates to:
  /// **'Ask how external links should open'**
  String get settings_externalLinkPromptSubtitle;

  /// Explanation under the "Regular" option for links from other apps.
  ///
  /// In en, this message translates to:
  /// **'Open external links in a regular tab'**
  String get settings_externalLinkRegularSubtitle;

  /// Explanation under the "Private" option for links from other apps.
  ///
  /// In en, this message translates to:
  /// **'Open external links in a private tab'**
  String get settings_externalLinkPrivateSubtitle;

  /// Explanation under the "Isolated" option for links from other apps.
  ///
  /// In en, this message translates to:
  /// **'Open external links in an isolated tab'**
  String get settings_externalLinkIsolatedSubtitle;

  /// Setting for how a bookmark opens when tapped.
  ///
  /// In en, this message translates to:
  /// **'Bookmark Open Behavior'**
  String get settings_bookmarkOpenBehaviorTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'bookmarks, open, custom tab, isolated'**
  String get settings_bookmarkOpenBehaviorKeywords;

  /// Explanation under that setting.
  ///
  /// In en, this message translates to:
  /// **'Choose how tapping a bookmark opens it'**
  String get settings_bookmarkOpenBehaviorSubtitle;

  /// Explanation under the "Prompt" option for bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Ask how the bookmark should open'**
  String get settings_bookmarkOpenPromptSubtitle;

  /// Explanation under the "Regular" option for bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Open the bookmark in a regular tab'**
  String get settings_bookmarkOpenRegularSubtitle;

  /// Explanation under the "Private" option for bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Open the bookmark in a private tab'**
  String get settings_bookmarkOpenPrivateSubtitle;

  /// Option: open in a custom tab, a lightweight separate browser window.
  ///
  /// In en, this message translates to:
  /// **'Custom Tab'**
  String get settings_customTabOptionLabel;

  /// Explanation under the "Custom Tab" option for bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Open the bookmark in a lightweight custom tab'**
  String get settings_bookmarkOpenCustomTabSubtitle;

  /// Explanation under the "Isolated" option for bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Open the bookmark in an isolated tab'**
  String get settings_bookmarkOpenIsolatedSubtitle;

  /// Setting for the order of the tab list (newest at top or bottom).
  ///
  /// In en, this message translates to:
  /// **'Tab List Direction'**
  String get settings_tabListDirectionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'sorting, order'**
  String get settings_tabListDirectionKeywords;

  /// Explanation under "Tab List Direction".
  ///
  /// In en, this message translates to:
  /// **'Choose whether the newest tab appears at the top or bottom of the tab list'**
  String get settings_tabListDirectionSubtitle;

  /// Order option: newest tab first. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get settings_directionNewestFirstLabel;

  /// Order option: oldest tab first. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get settings_directionOldestFirstLabel;

  /// Setting for the order of tabs in the quick tab switcher bar (newest on the left or right).
  ///
  /// In en, this message translates to:
  /// **'Tab Bar Direction'**
  String get settings_tabBarDirectionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'sorting, order'**
  String get settings_tabBarDirectionKeywords;

  /// Explanation under "Tab Bar Direction".
  ///
  /// In en, this message translates to:
  /// **'Choose whether the newest tab appears on the left or right of the quick switcher'**
  String get settings_tabBarDirectionSubtitle;

  /// Setting for where a tab opened from another tab is placed in the list.
  ///
  /// In en, this message translates to:
  /// **'New Child Tab Position'**
  String get settings_childTabPlacementTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'child tabs, new tab, position, order, end of list, after parent'**
  String get settings_childTabPlacementKeywords;

  /// Explanation under that setting. "Opener" is the tab the new tab was opened from.
  ///
  /// In en, this message translates to:
  /// **'Choose whether a tab opened from another tab follows its opener or goes to the end. The opener is still remembered either way, so the tree view is unaffected.'**
  String get settings_childTabPlacementSubtitle;

  /// Placement option: put the new tab right after the tab it was opened from. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'After opener'**
  String get settings_childTabAfterOpenerLabel;

  /// Placement option: put the new tab at the end of the list. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'At the end'**
  String get settings_childTabAtEndLabel;

  /// Switch: show a button for creating a tab nested under the current tab.
  ///
  /// In en, this message translates to:
  /// **'Create Child Tabs'**
  String get settings_createChildTabsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'child tabs'**
  String get settings_createChildTabsKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Display a button to create a child tab under the current tab (tree view only)'**
  String get settings_createChildTabsSubtitle;

  /// Switch: show container features in the interface (a container is a separate browsing identity).
  ///
  /// In en, this message translates to:
  /// **'Show Container UI'**
  String get settings_showContainerUiTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'containers'**
  String get settings_showContainerUiKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Show container selectors, menus, and management'**
  String get settings_showContainerUiSubtitle;

  /// Switch: show options for creating isolated tabs (tabs with their own temporary cookies and site data).
  ///
  /// In en, this message translates to:
  /// **'Show Isolated Tab UI'**
  String get settings_showIsolatedTabUiTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'isolated tabs'**
  String get settings_showIsolatedTabUiKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Show isolated-tab creation options in the UI'**
  String get settings_showIsolatedTabUiSubtitle;

  /// Setting for what happens when an action opens a tab in the background.
  ///
  /// In en, this message translates to:
  /// **'Background Tab Behavior'**
  String get settings_backgroundTabBehaviorTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'switch, background, new tab, snackbar, prompt'**
  String get settings_backgroundTabBehaviorKeywords;

  /// Explanation under that setting. "Open in new tab" must match the translation of that menu item.
  ///
  /// In en, this message translates to:
  /// **'Applies when an action opens a new tab in the background, e.g. \"Open in new tab\" or cloning a tab'**
  String get settings_backgroundTabBehaviorSubtitle;

  /// Option: stay on the current tab and show a message offering to switch.
  ///
  /// In en, this message translates to:
  /// **'Stay and Offer to Switch'**
  String get settings_backgroundTabPromptTitle;

  /// Explanation under that option. "Switch" must match the translation of that button.
  ///
  /// In en, this message translates to:
  /// **'Keep the current tab and show a notice with a Switch action'**
  String get settings_backgroundTabPromptSubtitle;

  /// Option: switch to the new tab right away.
  ///
  /// In en, this message translates to:
  /// **'Switch Immediately'**
  String get settings_backgroundTabSwitchTitle;

  /// Explanation under "Switch Immediately".
  ///
  /// In en, this message translates to:
  /// **'Jump straight to the newly opened tab'**
  String get settings_backgroundTabSwitchSubtitle;

  /// Row that opens the gesture settings for swipes on the tab bar.
  ///
  /// In en, this message translates to:
  /// **'Tab Bar Swipes'**
  String get settings_tabBarSwipesTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'gestures, swipe, tab bar swipe behavior'**
  String get settings_tabBarSwipesKeywords;

  /// Explanation under "Tab Bar Swipes". "Gestures" is the name of the gesture settings screen.
  ///
  /// In en, this message translates to:
  /// **'Choose what each swipe does in Gestures'**
  String get settings_tabBarSwipesSubtitle;

  /// Setting group for how next/previous tab navigation behaves at the ends of the list.
  ///
  /// In en, this message translates to:
  /// **'Sequential Tab Navigation'**
  String get settings_sequentialTabNavigationTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'gestures, swipe, next tab, previous tab, containers, loop, wrap around'**
  String get settings_sequentialTabNavigationKeywords;

  /// Explanation under that heading.
  ///
  /// In en, this message translates to:
  /// **'Applies to the tab bar swipe and the next/previous tab gestures'**
  String get settings_sequentialTabNavigationSubtitle;

  /// Switch: moving past the last tab of a container continues into the next container.
  ///
  /// In en, this message translates to:
  /// **'Continue Into Next Container'**
  String get settings_continueIntoNextContainerTitle;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Stepping past the first or last tab of a container moves into the neighboring one. When off, navigation stays inside the current container.'**
  String get settings_continueIntoNextContainerSubtitle;

  /// Switch: moving past the last tab jumps to the first one and vice versa.
  ///
  /// In en, this message translates to:
  /// **'Loop Around'**
  String get settings_loopAroundTitle;

  /// Explanation under "Loop Around".
  ///
  /// In en, this message translates to:
  /// **'Stepping past the last tab continues at the first one, and the other way round.'**
  String get settings_loopAroundSubtitle;

  /// Setting for whether links that an installed app can handle open in that app.
  ///
  /// In en, this message translates to:
  /// **'Open Links in Apps'**
  String get settings_openLinksInAppsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'app links, external apps'**
  String get settings_openLinksInAppsKeywords;

  /// Explanation under "Open Links in Apps".
  ///
  /// In en, this message translates to:
  /// **'Choose how links that can be opened in other apps are handled'**
  String get settings_openLinksInAppsSubtitle;

  /// Option: always open such links in their apps.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get settings_appLinksAlwaysTitle;

  /// Explanation under "Always".
  ///
  /// In en, this message translates to:
  /// **'Always open links in their native apps without asking'**
  String get settings_appLinksAlwaysSubtitle;

  /// Option: ask each time before opening a link in an app.
  ///
  /// In en, this message translates to:
  /// **'Ask before opening'**
  String get settings_appLinksAskTitle;

  /// Explanation under "Ask before opening".
  ///
  /// In en, this message translates to:
  /// **'Show a prompt before opening links in apps'**
  String get settings_appLinksAskSubtitle;

  /// Option: never open links in apps.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get settings_appLinksNeverTitle;

  /// Explanation under "Never".
  ///
  /// In en, this message translates to:
  /// **'Always open links in the browser instead of apps'**
  String get settings_appLinksNeverSubtitle;

  /// Switch: while asking whether to open a link in an app, do not start loading the page.
  ///
  /// In en, this message translates to:
  /// **'Wait for your answer'**
  String get settings_waitForAnswerTitle;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Hold the page while asking instead of loading it in the background. The site is not contacted unless you stay in the browser.'**
  String get settings_waitForAnswerSubtitle;

  /// Switch: offer to open the app store when a link needs an app that is not installed.
  ///
  /// In en, this message translates to:
  /// **'Offer app store fallback'**
  String get settings_offerAppStoreFallbackTitle;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'When a link points to an app you don\'t have installed and there is no web fallback, offer to open the app store'**
  String get settings_offerAppStoreFallbackSubtitle;

  /// Switch: let apps that opened a sign-in page in a custom tab receive the sign-in result.
  ///
  /// In en, this message translates to:
  /// **'Allow login app callbacks'**
  String get settings_allowLoginAppCallbacksTitle;

  /// Explanation under that switch. "Custom Tab" is a lightweight in-app browser window.
  ///
  /// In en, this message translates to:
  /// **'Let apps that opened a Custom Tab receive their login callback, even when links are set to never open in apps'**
  String get settings_allowLoginAppCallbacksSubtitle;

  /// Fallback name for an unnamed container in the list of container app-link settings.
  ///
  /// In en, this message translates to:
  /// **'Container'**
  String get settings_appLinkContainerFallbackName;

  /// Summary line for a container that always opens links in apps.
  ///
  /// In en, this message translates to:
  /// **'Always open in apps'**
  String get settings_appLinkOverrideModeAlways;

  /// Summary line for a container that asks before opening links in apps.
  ///
  /// In en, this message translates to:
  /// **'Asks before opening'**
  String get settings_appLinkOverrideModeAsk;

  /// Summary line for a container that always keeps links in the browser.
  ///
  /// In en, this message translates to:
  /// **'Always keeps links in the browser'**
  String get settings_appLinkOverrideModeNever;

  /// Heading above containers that have their own app-link settings.
  ///
  /// In en, this message translates to:
  /// **'Containers with their own app-link settings'**
  String get settings_appLinkContainerOverridesHeader;

  /// Summary line for a container. mode is one of the summary lines above; count is the number of remembered site rules. Keep the "·" separator.
  ///
  /// In en, this message translates to:
  /// **'{mode} · {count, plural, =1{1 remembered rule} other{{count} remembered rules}}'**
  String settings_appLinkOverrideSummaryWithRules(String mode, int count);

  /// Heading above sites with a remembered open-in-app choice.
  ///
  /// In en, this message translates to:
  /// **'Remembered site rules'**
  String get settings_appLinkRememberedRulesHeader;

  /// Line under a remembered site: its links always open in the app.
  ///
  /// In en, this message translates to:
  /// **'Always open in the app'**
  String get settings_appLinkRuleAlwaysOpenLabel;

  /// Line under a remembered site: its links always stay in the browser.
  ///
  /// In en, this message translates to:
  /// **'Always keep in the browser'**
  String get settings_appLinkRuleAlwaysKeepLabel;

  /// Tooltip of the button that deletes a remembered open-in-app choice.
  ///
  /// In en, this message translates to:
  /// **'Remove rule'**
  String get settings_appLinkRuleRemoveTooltip;

  /// Switch: request the desktop version of websites by default.
  ///
  /// In en, this message translates to:
  /// **'Always Request Desktop Site'**
  String get settings_globalDesktopModeTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'desktop mode, user agent, mobile site, tablet'**
  String get settings_globalDesktopModeKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Open new tabs in desktop mode by default. You can still toggle desktop mode per tab from the page menu.'**
  String get settings_globalDesktopModeSubtitle;

  /// Row that opens the list of sites that always load their desktop version.
  ///
  /// In en, this message translates to:
  /// **'Desktop Mode Sites'**
  String get settings_desktopModeSitesTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'desktop mode, per-site, user agent, exceptions'**
  String get settings_desktopModeSitesKeywords;

  /// Explanation under "Desktop Mode Sites".
  ///
  /// In en, this message translates to:
  /// **'Sites that always load in desktop mode'**
  String get settings_desktopModeSitesSubtitle;

  /// Switch: drag down at the top of a page to reload it.
  ///
  /// In en, this message translates to:
  /// **'Pull to Refresh'**
  String get settings_pullToRefreshTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'reload'**
  String get settings_pullToRefreshKeywords;

  /// Explanation under "Pull to Refresh".
  ///
  /// In en, this message translates to:
  /// **'Swipe down on pages to reload them'**
  String get settings_pullToRefreshSubtitle;

  /// Switch: let other apps open links in custom tabs (a lightweight in-app browser window).
  ///
  /// In en, this message translates to:
  /// **'Custom Tabs'**
  String get settings_customTabsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'custom tabs, in-app browser, chrome custom tabs, external app, share'**
  String get settings_customTabsKeywords;

  /// Explanation under "Custom Tabs".
  ///
  /// In en, this message translates to:
  /// **'Let other apps open links in a lightweight in-app tab. When off, these links and shared URLs open as normal tabs in the main browser.'**
  String get settings_customTabsSubtitle;

  /// Switch: pressing the Back button twice at the start of a tab's history closes the tab.
  ///
  /// In en, this message translates to:
  /// **'Double Back to Close Tab'**
  String get settings_doubleBackCloseTabTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'back button'**
  String get settings_doubleBackCloseTabKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'When enabled, press the Back button twice to close the tab. When disabled, the Back button only navigates through the page history.'**
  String get settings_doubleBackCloseTabSubtitle;

  /// Switch: allow installing any website as an app on the home screen, not only proper web apps.
  ///
  /// In en, this message translates to:
  /// **'Install Sites as Apps'**
  String get settings_allowNonManifestPwaInstallTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'pwa, web apps'**
  String get settings_allowNonManifestPwaInstallKeywords;

  /// Explanation under that switch. PWA (progressive web app) is a technical abbreviation.
  ///
  /// In en, this message translates to:
  /// **'Allow installing websites without a PWA manifest as standalone apps'**
  String get settings_allowNonManifestPwaInstallSubtitle;

  /// Row that opens the URL cleaner settings (removes tracking parameters from links).
  ///
  /// In en, this message translates to:
  /// **'URL Cleaner'**
  String get settings_urlCleanerTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'utm, tracking parameters'**
  String get settings_urlCleanerKeywords;

  /// Explanation under "URL Cleaner".
  ///
  /// In en, this message translates to:
  /// **'Tracking removal rules and catalog updates'**
  String get settings_urlCleanerSubtitle;

  /// Row that opens the unshortener settings (resolves shortened links).
  ///
  /// In en, this message translates to:
  /// **'Unshortener'**
  String get settings_unshortenerTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'short links, redirects'**
  String get settings_unshortenerKeywords;

  /// Explanation under "Unshortener".
  ///
  /// In en, this message translates to:
  /// **'Short link resolver and API token'**
  String get settings_unshortenerSubtitle;

  /// Placeholder of the search field on the toolbar customization screen.
  ///
  /// In en, this message translates to:
  /// **'Search toolbar buttons'**
  String get settings_contextualToolbarSearchHint;

  /// Title of the screen for choosing and arranging toolbar buttons.
  ///
  /// In en, this message translates to:
  /// **'Customize Toolbar'**
  String get settings_contextualToolbarTitleDefault;

  /// Title of the screen for choosing buttons shown in the quick tab switcher bar.
  ///
  /// In en, this message translates to:
  /// **'Customize Switcher Buttons'**
  String get settings_contextualToolbarTitleQuickSwitcher;

  /// Menu item that restores the default toolbar buttons.
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get settings_contextualToolbarResetToDefaults;

  /// Heading above the toolbar buttons that are shown.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get settings_contextualToolbarEnabledSection;

  /// Heading above the toolbar buttons that are hidden.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get settings_contextualToolbarDisabledSection;

  /// Shown when no toolbar button is enabled.
  ///
  /// In en, this message translates to:
  /// **'No enabled buttons. Toggle a button below to enable it.'**
  String get settings_contextualToolbarNoEnabledButtons;

  /// Shown when no enabled toolbar button matches the search. query is the search text.
  ///
  /// In en, this message translates to:
  /// **'No enabled buttons match \"{query}\".'**
  String settings_contextualToolbarNoEnabledButtonsMatch(String query);

  /// Shown in the hidden-buttons section when every button is enabled.
  ///
  /// In en, this message translates to:
  /// **'All buttons are enabled.'**
  String get settings_contextualToolbarAllButtonsEnabled;

  /// Shown when no hidden toolbar button matches the search. query is the search text.
  ///
  /// In en, this message translates to:
  /// **'No disabled buttons match \"{query}\".'**
  String settings_contextualToolbarNoDisabledButtonsMatch(String query);

  /// Value of a toolbar button's long-press setting when holding it does nothing. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get settings_longPressNoneTitle;

  /// Explanation of that value.
  ///
  /// In en, this message translates to:
  /// **'Default for this button: holding it does nothing extra'**
  String get settings_longPressNoneDescription;

  /// Explanation shown for the button's built-in long-press action (the action names are shown as the value).
  ///
  /// In en, this message translates to:
  /// **'Default for this button'**
  String get settings_longPressDefaultDescription;

  /// Setting for what holding (long-pressing) a toolbar button does.
  ///
  /// In en, this message translates to:
  /// **'Long press'**
  String get settings_longPressTitle;

  /// Explanation of the long-press setting.
  ///
  /// In en, this message translates to:
  /// **'What holding the button does'**
  String get settings_longPressDescription;

  /// Option for a toolbar button that cannot be used at the moment: show it greyed out instead of replacing it.
  ///
  /// In en, this message translates to:
  /// **'Grey out'**
  String get settings_fallbackGreyOutLabel;

  /// Setting for which button replaces a toolbar button while it cannot be used.
  ///
  /// In en, this message translates to:
  /// **'If unavailable'**
  String get settings_fallbackIfUnavailableTitle;

  /// Explanation of that setting.
  ///
  /// In en, this message translates to:
  /// **'Shown instead while this button can\'t be used'**
  String get settings_fallbackIfUnavailableDescription;

  /// Title of the screen for custom tracking protection settings.
  ///
  /// In en, this message translates to:
  /// **'Custom Tracking Protection'**
  String get settings_customTrackingProtectionTitle;

  /// Subtitle of that screen listing what it contains.
  ///
  /// In en, this message translates to:
  /// **'Custom cookie, content, tracker, and fingerprinting controls.'**
  String get settings_customTrackingProtectionSubtitle;

  /// Switch: apply Mozilla's exceptions that prevent tracking protection from badly breaking websites.
  ///
  /// In en, this message translates to:
  /// **'Fix website major issues'**
  String get settings_fixMajorIssuesTitle;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Apply exceptions required to avoid major website breakage (recommended)'**
  String get settings_fixMajorIssuesSubtitle;

  /// Switch: also apply exceptions for minor website problems and convenience features.
  ///
  /// In en, this message translates to:
  /// **'Fix website minor issues'**
  String get settings_fixMinorIssuesTitle;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Apply exceptions to fix minor issues and enable convenience features'**
  String get settings_fixMinorIssuesSubtitle;

  /// Switch: block cookies according to the policy below.
  ///
  /// In en, this message translates to:
  /// **'Block Cookies'**
  String get settings_blockCookiesTitle;

  /// Explanation under "Block Cookies".
  ///
  /// In en, this message translates to:
  /// **'Block cookies based on the policy below'**
  String get settings_blockCookiesSubtitle;

  /// Heading of the drop-down for which cookies to block.
  ///
  /// In en, this message translates to:
  /// **'Cookie Policy'**
  String get settings_cookiePolicyTitle;

  /// Cookie policy option: keep each site's cookies separate. "Total Cookie Protection" is Mozilla's feature name; use Firefox's translation if available.
  ///
  /// In en, this message translates to:
  /// **'Total Cookie Protection (Recommended)'**
  String get settings_cookiePolicyTotalProtectionLabel;

  /// Cookie policy option: block cookies from cross-site and social media trackers.
  ///
  /// In en, this message translates to:
  /// **'Cross-site and social media trackers'**
  String get settings_cookiePolicyCrossSiteTrackersLabel;

  /// Cookie policy option: block cookies from sites you have not visited.
  ///
  /// In en, this message translates to:
  /// **'Unvisited sites'**
  String get settings_cookiePolicyUnvisitedLabel;

  /// Cookie policy option: block all cookies from sites other than the one you are on.
  ///
  /// In en, this message translates to:
  /// **'All third-party cookies'**
  String get settings_cookiePolicyThirdPartyLabel;

  /// Cookie policy option: block every cookie.
  ///
  /// In en, this message translates to:
  /// **'All cookies (may break sites)'**
  String get settings_cookiePolicyAllCookiesLabel;

  /// Switch: block tracking scripts and content on websites.
  ///
  /// In en, this message translates to:
  /// **'Block Tracking Content'**
  String get settings_blockTrackingContentTitle;

  /// Explanation under "Block Tracking Content".
  ///
  /// In en, this message translates to:
  /// **'Block tracking scripts and resources embedded in websites'**
  String get settings_blockTrackingContentSubtitle;

  /// Heading of the choice of which tabs a protection applies to.
  ///
  /// In en, this message translates to:
  /// **'Apply to'**
  String get settings_trackingScopeApplyToTitle;

  /// Scope option: apply to all tabs.
  ///
  /// In en, this message translates to:
  /// **'All tabs'**
  String get settings_trackingScopeAllTabsLabel;

  /// Scope option: apply only to private tabs.
  ///
  /// In en, this message translates to:
  /// **'Private tabs only'**
  String get settings_trackingScopePrivateOnlyLabel;

  /// Switch: block advertising, analytics and social media trackers.
  ///
  /// In en, this message translates to:
  /// **'Ads, Analytics, and Social Trackers'**
  String get settings_adsAnalyticsSocialTrackersTitle;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Block advertising, analytics, social, and Mozilla social tracker categories'**
  String get settings_adsAnalyticsSocialTrackersSubtitle;

  /// Switch: block scripts that mine cryptocurrency.
  ///
  /// In en, this message translates to:
  /// **'Cryptominers'**
  String get settings_cryptominersTitle;

  /// Explanation under "Cryptominers".
  ///
  /// In en, this message translates to:
  /// **'Block scripts that use your device to mine cryptocurrency'**
  String get settings_cryptominersSubtitle;

  /// Switch: block scripts known to fingerprint (identify) browsers.
  ///
  /// In en, this message translates to:
  /// **'Known Fingerprinters'**
  String get settings_knownFingerprintersTitle;

  /// Explanation under "Known Fingerprinters".
  ///
  /// In en, this message translates to:
  /// **'Block scripts that collect information to uniquely identify your device'**
  String get settings_knownFingerprintersSubtitle;

  /// Switch: block trackers that bounce you through tracking addresses.
  ///
  /// In en, this message translates to:
  /// **'Redirect Trackers'**
  String get settings_redirectTrackersTitle;

  /// Explanation under "Redirect Trackers".
  ///
  /// In en, this message translates to:
  /// **'Block trackers that collect data through intermediate URL redirects'**
  String get settings_redirectTrackersSubtitle;

  /// Switch: also block techniques that might be used for fingerprinting.
  ///
  /// In en, this message translates to:
  /// **'Suspected Fingerprinters'**
  String get settings_suspectedFingerprintersTitle;

  /// Explanation under "Suspected Fingerprinters".
  ///
  /// In en, this message translates to:
  /// **'Block additional fingerprinting techniques that may be used to track you'**
  String get settings_suspectedFingerprintersSubtitle;

  /// Title of the list of sites that always load their desktop version.
  ///
  /// In en, this message translates to:
  /// **'Desktop mode sites'**
  String get settings_desktopModeSitesScreenTitle;

  /// Explanation at the top of that list. The domains are examples; keep them unchanged.
  ///
  /// In en, this message translates to:
  /// **'These sites always load in desktop mode, overriding the default. Subdomains are included (e.g. \"example.com\" also covers \"m.example.com\").'**
  String get settings_desktopModeSitesScreenDescription;

  /// Shown when the desktop mode site list is empty.
  ///
  /// In en, this message translates to:
  /// **'No sites added.'**
  String get settings_desktopModeSitesEmptyLabel;

  /// Title of the DNS over HTTPS settings screen (encrypted lookups of website addresses). Technical term; usually kept in English.
  ///
  /// In en, this message translates to:
  /// **'DNS over HTTPS'**
  String get settings_dohTitle;

  /// Subtitle of that screen listing what it contains.
  ///
  /// In en, this message translates to:
  /// **'Encrypted DNS protection level and resolver selection.'**
  String get settings_dohSubtitle;

  /// Confirmation after copying the error logs.
  ///
  /// In en, this message translates to:
  /// **'Logs copied'**
  String get settings_errorLogsCopiedMessage;

  /// Placeholder of the search field on the error logs screen.
  ///
  /// In en, this message translates to:
  /// **'Search log messages'**
  String get settings_errorLogsSearchHint;

  /// Tooltip of the button that copies the error logs.
  ///
  /// In en, this message translates to:
  /// **'Copy logs'**
  String get settings_errorLogsCopyTooltip;

  /// Shown when there are no log entries.
  ///
  /// In en, this message translates to:
  /// **'No logs available'**
  String get settings_errorLogsEmptyLabel;

  /// Title of the experimental settings screen.
  ///
  /// In en, this message translates to:
  /// **'Experimental'**
  String get settings_experimentalTitle;

  /// Subtitle of that screen listing what it contains.
  ///
  /// In en, this message translates to:
  /// **'Runtime isolation and startup behavior.'**
  String get settings_experimentalSubtitle;

  /// Switch: run web pages in a separate, isolated Android process for extra security.
  ///
  /// In en, this message translates to:
  /// **'Isolated Content Process'**
  String get settings_isolatedContentProcessTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'restart'**
  String get settings_isolatedContentProcessKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Run web content in an isolated process. Requires an app restart.'**
  String get settings_isolatedContentProcessSubtitle;

  /// Switch: speed up starting the isolated process. "App Zygote" is an Android technical term; usually kept in English.
  ///
  /// In en, this message translates to:
  /// **'App Zygote Process'**
  String get settings_appZygoteProcessTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'restart, android 10'**
  String get settings_appZygoteProcessKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Preload the content service for faster isolated process startup. Requires Android 10+ and app restart.'**
  String get settings_appZygoteProcessSubtitle;

  /// Title of the extension settings screen.
  ///
  /// In en, this message translates to:
  /// **'Extensions'**
  String get settings_extensionsTitle;

  /// Subtitle of that screen listing what it contains.
  ///
  /// In en, this message translates to:
  /// **'Manage add-ons, update behavior, and extension security.'**
  String get settings_extensionsSubtitle;

  /// Row that opens the extension manager.
  ///
  /// In en, this message translates to:
  /// **'Manage Extensions'**
  String get settings_manageExtensionsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'addons, browser extensions'**
  String get settings_manageExtensionsKeywords;

  /// Explanation under "Manage Extensions".
  ///
  /// In en, this message translates to:
  /// **'Browse installed, disabled, available, and unsupported extensions'**
  String get settings_manageExtensionsSubtitle;

  /// Row that opens settings for a custom Mozilla add-on collection as extension source.
  ///
  /// In en, this message translates to:
  /// **'Custom Collection'**
  String get settings_customCollectionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'addons'**
  String get settings_customCollectionKeywords;

  /// Explanation under "Custom Collection".
  ///
  /// In en, this message translates to:
  /// **'Use a custom Mozilla add-on collection'**
  String get settings_customCollectionSubtitle;

  /// Switch: update extensions automatically.
  ///
  /// In en, this message translates to:
  /// **'Automatic updates'**
  String get settings_automaticUpdatesTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'addons'**
  String get settings_automaticUpdatesKeywords;

  /// Explanation under "Automatic updates".
  ///
  /// In en, this message translates to:
  /// **'Automatically check for and install extension updates every 12 hours'**
  String get settings_automaticUpdatesSubtitle;

  /// Line under a setting whose current value could not be loaded. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {error}'**
  String settings_failedToLoadMessage(String error);

  /// Switch: allow installing extensions that Mozilla has not signed (verified). Must match the reference in the unsigned-extension install error.
  ///
  /// In en, this message translates to:
  /// **'Allow unsigned extensions'**
  String get settings_allowUnsignedExtensionsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'addons'**
  String get settings_allowUnsignedExtensionsKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Unsigned extensions have not been verified by Mozilla'**
  String get settings_allowUnsignedExtensionsSubtitle;

  /// Warning shown while unsigned extensions are allowed.
  ///
  /// In en, this message translates to:
  /// **'Only install unsigned extensions from sources you trust. They may contain malicious code.'**
  String get settings_allowUnsignedWarningText;

  /// Title of the confirmation dialog before allowing unsigned extensions.
  ///
  /// In en, this message translates to:
  /// **'Allow unsigned extensions?'**
  String get settings_allowUnsignedConfirmDialogTitle;

  /// Bold first line of that dialog.
  ///
  /// In en, this message translates to:
  /// **'Warning: This significantly weakens your browser\'s security.'**
  String get settings_allowUnsignedConfirmWarningBold;

  /// Body of that dialog. Keep the bullets ("•") and line breaks (\n).
  ///
  /// In en, this message translates to:
  /// **'Unsigned extensions bypass Mozilla\'s safety review process. Malicious extensions can:\n\n• Read and modify everything you see on any website\n• Steal passwords, banking details, and personal data\n• Monitor your browsing activity silently\n• Install additional malware on your device'**
  String get settings_allowUnsignedConfirmBody;

  /// Last paragraph of that dialog.
  ///
  /// In en, this message translates to:
  /// **'Only enable this if you are a developer installing your own extension or absolutely trust the source.'**
  String get settings_allowUnsignedConfirmFooter;

  /// Confirm button of that dialog once the waiting time is over.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get settings_allowAction;

  /// Confirm button of that dialog during the forced waiting time. seconds is the remaining time.
  ///
  /// In en, this message translates to:
  /// **'Allow ({seconds})'**
  String settings_allowActionCountdown(int seconds);

  /// Title of the fingerprint protection screen, and its row: settings that hide characteristics websites use to identify the browser.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint Protection'**
  String get settings_fingerprintProtectionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'privacy'**
  String get settings_fingerprintProtectionKeywords;

  /// Placeholder of the search field on the fingerprint protection screen.
  ///
  /// In en, this message translates to:
  /// **'Search fingerprint override targets'**
  String get settings_fingerprintSearchHint;

  /// Menu item that restores the default fingerprint protection settings.
  ///
  /// In en, this message translates to:
  /// **'Load Defaults'**
  String get settings_loadDefaultsAction;

  /// Menu item that applies the stricter ("hardened") fingerprint protection defaults.
  ///
  /// In en, this message translates to:
  /// **'Load Hardened Defaults'**
  String get settings_loadHardenedDefaultsAction;

  /// Heading above the list of individual fingerprint protections (targets) that can be switched on or off.
  ///
  /// In en, this message translates to:
  /// **'Override Targets'**
  String get settings_fingerprintOverrideTargetsSection;

  /// Error title on the fingerprint protection screen: the stored override list cannot be read.
  ///
  /// In en, this message translates to:
  /// **'The saved fingerprint overrides are not in a valid format'**
  String get settings_fingerprintInvalidOverride;

  /// Error title on the fingerprint protection screen: the stored override list names a protection target this app version does not have.
  ///
  /// In en, this message translates to:
  /// **'The saved fingerprint overrides name a target this version does not know'**
  String get settings_fingerprintUnknownTarget;

  /// Title of the home and new tab settings screen and category.
  ///
  /// In en, this message translates to:
  /// **'Home & New Tab'**
  String get settings_homeAndNewTabTitle;

  /// Subtitle of that screen.
  ///
  /// In en, this message translates to:
  /// **'What the home and new tab pages show'**
  String get settings_homeAndNewTabSubtitle;

  /// Label of the web address field for a custom home page.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get settings_addressFieldLabel;

  /// Validation error when the custom home page address is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter an address or the home page will be shown instead'**
  String get settings_homeTargetUrlEmptyError;

  /// Validation error when the custom home page address is not valid.
  ///
  /// In en, this message translates to:
  /// **'Not a valid address'**
  String get settings_homeTargetUrlInvalidError;

  /// Switch: when the last tab of a container is closed, show the home target there instead of switching to a tab elsewhere.
  ///
  /// In en, this message translates to:
  /// **'Apply when the last tab closes'**
  String get settings_applyWhenLastTabClosesTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'close, last tab, container'**
  String get settings_applyWhenLastTabClosesKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Closing the last tab in a container stays there instead of opening a tab from somewhere else'**
  String get settings_applyWhenLastTabClosesSubtitle;

  /// Line under the automatic search bar placement option. value is the name of the placement it currently uses, exactly as shown in the option list, e.g. "In the tab bar".
  ///
  /// In en, this message translates to:
  /// **'Currently: {value}'**
  String settings_homeSearchBarCurrentlyLabel(String value);

  /// Row that opens the home page wallpaper settings.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper'**
  String get settings_wallpaperTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'wallpaper, background, image, photo, picture, blur, dim, home'**
  String get settings_wallpaperKeywords;

  /// Line under "Wallpaper" when an image is set.
  ///
  /// In en, this message translates to:
  /// **'A background image is set for the home page'**
  String get settings_wallpaperSetSubtitle;

  /// Line under "Wallpaper" when no image is set.
  ///
  /// In en, this message translates to:
  /// **'Set a background image for the home page'**
  String get settings_wallpaperUnsetSubtitle;

  /// Row that opens the editor for choosing and ordering home page sections.
  ///
  /// In en, this message translates to:
  /// **'Customize home sections'**
  String get settings_customizeHomeSectionsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'home, sections, shortcuts, quote, quick actions, reorder'**
  String get settings_customizeHomeSectionsKeywords;

  /// Explanation under that row.
  ///
  /// In en, this message translates to:
  /// **'Choose and order what the home page shows'**
  String get settings_customizeHomeSectionsSubtitle;

  /// Row that opens the editor for choosing and ordering new tab page sections.
  ///
  /// In en, this message translates to:
  /// **'Customize new tab sections'**
  String get settings_customizeNewTabSectionsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'new tab, sections, shortcuts, reorder'**
  String get settings_customizeNewTabSectionsKeywords;

  /// Explanation under that row.
  ///
  /// In en, this message translates to:
  /// **'Choose and order what the new tab page shows'**
  String get settings_customizeNewTabSectionsSubtitle;

  /// Title of the screen and row for the languages websites are told the user prefers (not the app's own language).
  ///
  /// In en, this message translates to:
  /// **'Browser Languages'**
  String get settings_browserLanguagesTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'locale'**
  String get settings_browserLanguagesKeywords;

  /// Placeholder of the search field on the browser languages screen. A locale tag is a code like "en-US".
  ///
  /// In en, this message translates to:
  /// **'Search locales by tag'**
  String get settings_browserLanguagesSearchHint;

  /// Section heading above the list of selectable languages and regions.
  ///
  /// In en, this message translates to:
  /// **'Language & Region Settings'**
  String get settings_languageRegionSettingsSection;

  /// Line under each language code in that list.
  ///
  /// In en, this message translates to:
  /// **'Browser language preference'**
  String get settings_browserLanguagePreferenceLabel;

  /// Section heading for adding a language code that is not in the list.
  ///
  /// In en, this message translates to:
  /// **'Custom Locale'**
  String get settings_customLocaleSection;

  /// Title of the entry for adding a custom language code.
  ///
  /// In en, this message translates to:
  /// **'Add custom locale'**
  String get settings_addCustomLocaleTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'locale tag'**
  String get settings_addCustomLocaleKeywords;

  /// Explanation of that entry. "en-US" is an example code; keep it unchanged.
  ///
  /// In en, this message translates to:
  /// **'Enter a locale tag such as en-US'**
  String get settings_addCustomLocaleSubtitle;

  /// Label of the field for a custom language code.
  ///
  /// In en, this message translates to:
  /// **'Custom Locale'**
  String get settings_customLocaleFieldLabel;

  /// Validation error when the entered language code is not valid.
  ///
  /// In en, this message translates to:
  /// **'Invalid locale identifier'**
  String get settings_invalidLocaleError;

  /// Option for what the Home button and new windows show: the app's home page.
  ///
  /// In en, this message translates to:
  /// **'Home page'**
  String get settings_homeTargetHomeLabel;

  /// Option for what the Home button shows: the last opened tab.
  ///
  /// In en, this message translates to:
  /// **'Last opened tab'**
  String get settings_homeTargetResumeLastTabLabel;

  /// Option for what the Home button shows: a chosen web address.
  ///
  /// In en, this message translates to:
  /// **'Custom address'**
  String get settings_homeTargetCustomUrlLabel;

  /// Explanation under "Home page".
  ///
  /// In en, this message translates to:
  /// **'Show shortcuts and the sections you have chosen'**
  String get settings_homeTargetHomeDescription;

  /// Explanation under "Last opened tab".
  ///
  /// In en, this message translates to:
  /// **'Pick up where you left off'**
  String get settings_homeTargetResumeLastTabDescription;

  /// Explanation under "Custom address".
  ///
  /// In en, this message translates to:
  /// **'Open a specific page'**
  String get settings_homeTargetCustomUrlDescription;

  /// Option for where the home page search bar appears: wherever the tab bar is.
  ///
  /// In en, this message translates to:
  /// **'Follow the tab bar'**
  String get settings_homeSearchBarAutoLabel;

  /// Option for where the home page search bar appears: at the top of the home page.
  ///
  /// In en, this message translates to:
  /// **'Top of the home page'**
  String get settings_homeSearchBarTopLabel;

  /// Option for where the home page search bar appears: inside the tab bar.
  ///
  /// In en, this message translates to:
  /// **'In the tab bar'**
  String get settings_homeSearchBarTabBarLabel;

  /// Explanation under "Follow the tab bar".
  ///
  /// In en, this message translates to:
  /// **'Whichever edge the tab bar is on'**
  String get settings_homeSearchBarAutoDescription;

  /// Explanation under "Top of the home page".
  ///
  /// In en, this message translates to:
  /// **'A pinned search bar above the home sections'**
  String get settings_homeSearchBarTopDescription;

  /// Explanation under "In the tab bar". QR means QR code scanning.
  ///
  /// In en, this message translates to:
  /// **'The tab bar\'s address field, with QR and voice search'**
  String get settings_homeSearchBarTabBarDescription;

  /// Title of the general settings screen and category.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settings_generalTitle;

  /// Subtitle of that screen listing what it contains.
  ///
  /// In en, this message translates to:
  /// **'Appearance, downloads, and browser defaults.'**
  String get settings_generalSubtitle;

  /// Row showing whether WebLibre is the device's default browser, with a button to change it.
  ///
  /// In en, this message translates to:
  /// **'Default Browser'**
  String get settings_defaultBrowserTileTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'system browser'**
  String get settings_defaultBrowserTileKeywords;

  /// Line under that row when WebLibre is the default browser.
  ///
  /// In en, this message translates to:
  /// **'WebLibre is your default browser'**
  String get settings_defaultBrowserTileSubtitleSet;

  /// Line under that row when it is not.
  ///
  /// In en, this message translates to:
  /// **'Set WebLibre as your default browser'**
  String get settings_defaultBrowserTileSubtitleNotSet;

  /// Label of the disabled button when WebLibre is already the default browser. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get settings_defaultBrowserButtonDefault;

  /// Button that asks Android to make WebLibre the default browser. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get settings_defaultBrowserButtonSet;

  /// Row that starts a backup of the current profile.
  ///
  /// In en, this message translates to:
  /// **'Back up this profile'**
  String get settings_backupProfileTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'backup, archive, export, save, encrypted, restore'**
  String get settings_backupProfileKeywords;

  /// Line under that row. name is the current profile's name.
  ///
  /// In en, this message translates to:
  /// **'Write \"{name}\" to an encrypted backup file'**
  String settings_backupProfileSubtitleReady(String name);

  /// Line under that row when the current profile could not be read.
  ///
  /// In en, this message translates to:
  /// **'Could not read the active profile'**
  String get settings_backupProfileSubtitleError;

  /// Row that opens the screen for exporting and importing settings.
  ///
  /// In en, this message translates to:
  /// **'Export & Import Settings'**
  String get settings_settingsTransferTileTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'export, import, settings, transfer, share, clipboard, json, copy, migrate'**
  String get settings_settingsTransferTileKeywords;

  /// Explanation under that row.
  ///
  /// In en, this message translates to:
  /// **'Write settings to a file or the clipboard, and read them back'**
  String get settings_settingsTransferTileSubtitle;

  /// Setting that scales the whole app interface.
  ///
  /// In en, this message translates to:
  /// **'User Interface Zoom'**
  String get settings_uiZoomTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'ui scale, zoom'**
  String get settings_uiZoomKeywords;

  /// Explanation under that setting.
  ///
  /// In en, this message translates to:
  /// **'Make the user interface smaller or larger'**
  String get settings_uiZoomSubtitle;

  /// Switch that turns off interface animations.
  ///
  /// In en, this message translates to:
  /// **'Disable Animations'**
  String get settings_disableAnimationsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'motion'**
  String get settings_disableAnimationsKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion and turn off app animations'**
  String get settings_disableAnimationsSubtitle;

  /// Switch: dim the screen behind dialogs and sheets. "Modal barrier" is the darkened layer behind them.
  ///
  /// In en, this message translates to:
  /// **'Show Modal Barrier'**
  String get settings_showModalBarrierTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'dialogs, bottom sheets, overlay'**
  String get settings_showModalBarrierKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Dim the background behind dialogs and bottom sheets'**
  String get settings_showModalBarrierSubtitle;

  /// Switch: show a close button on the search / new tab page.
  ///
  /// In en, this message translates to:
  /// **'Show Close Button'**
  String get settings_showSearchCloseButtonTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'back, close, dismiss, e-ink, eink, accessibility, new tab'**
  String get settings_showSearchCloseButtonKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Add a button to dismiss the search or new-tab page without a back gesture. This is useful on devices without a back button.'**
  String get settings_showSearchCloseButtonSubtitle;

  /// Switch: use pure black backgrounds in dark mode. OLED is a screen technology.
  ///
  /// In en, this message translates to:
  /// **'Pure Black (OLED)'**
  String get settings_pureBlackTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'oled, amoled, high contrast, black, dark'**
  String get settings_pureBlackKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Use true-black surfaces in dark mode to save power on OLED screens'**
  String get settings_pureBlackSubtitle;

  /// Heading of the choice between system, light and dark appearance.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_themeTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'light, dark, theme mode'**
  String get settings_themeKeywords;

  /// Theme option: follow the device setting. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settings_themeModeSystem;

  /// Theme option: light. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_themeModeLight;

  /// Theme option: dark. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_themeModeDark;

  /// Option in the app language list: use the device's language.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settings_appLanguageSystemDefault;

  /// Line under the "System default" app language option. language is the name of the language the device settings currently select, written in that language itself, e.g. "English" or "Deutsch". Differs from the device language when WebLibre is not translated into it.
  ///
  /// In en, this message translates to:
  /// **'Currently: {language}'**
  String settings_appLanguageCurrentlyLabel(String language);

  /// Setting for the screen refresh rate the app requests.
  ///
  /// In en, this message translates to:
  /// **'Refresh Rate'**
  String get settings_refreshRateTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'fps, hz, hertz, frame rate, framerate, 60hz, 90hz, 120hz, smooth, high refresh, display mode'**
  String get settings_refreshRateKeywords;

  /// Explanation under that setting. "High" and "Low" must match the option labels; "90/120Hz" is a unit value.
  ///
  /// In en, this message translates to:
  /// **'Choose \"High\" for the smoothest scrolling and animations on 90/120Hz screens, or \"Low\" to save battery.'**
  String get settings_refreshRateSubtitle;

  /// Refresh rate option: let Android decide. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settings_refreshRateModeSystem;

  /// Refresh rate option: high (smooth). Keep it short.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get settings_refreshRateModeHigh;

  /// Refresh rate option: low (saves battery). Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get settings_refreshRateModeLow;

  /// Row for choosing where downloads are saved.
  ///
  /// In en, this message translates to:
  /// **'Download folder'**
  String get settings_downloadFolderTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'downloads, folder, directory, storage, save'**
  String get settings_downloadFolderKeywords;

  /// Line under that row when the system Downloads folder is used.
  ///
  /// In en, this message translates to:
  /// **'Saving to the system Downloads folder'**
  String get settings_downloadFolderSubtitleDefault;

  /// Line under that row when the chosen folder can no longer be accessed. folderName is the chosen folder's name.
  ///
  /// In en, this message translates to:
  /// **'No longer available — saving to the system Downloads folder ({folderName})'**
  String settings_downloadFolderSubtitleUnavailable(String folderName);

  /// Line under that row while an external download manager app is used.
  ///
  /// In en, this message translates to:
  /// **'The download manager app chooses where files are saved'**
  String get settings_downloadFolderSubtitleExternalManager;

  /// Tooltip of the button that goes back to the system Downloads folder.
  ///
  /// In en, this message translates to:
  /// **'Use the system Downloads folder'**
  String get settings_downloadFolderResetTooltip;

  /// Switch: hand downloads to another app instead of downloading in WebLibre.
  ///
  /// In en, this message translates to:
  /// **'Use external download manager'**
  String get settings_externalDownloadManagerTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'downloads'**
  String get settings_externalDownloadManagerKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Manage downloads with another app'**
  String get settings_externalDownloadManagerSubtitle;

  /// Row showing which app downloads go to without asking, as remembered from the download manager chooser.
  ///
  /// In en, this message translates to:
  /// **'Preferred download manager'**
  String get settings_preferredDownloadManagerTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'downloads, download manager, always use, default app, chooser, ask'**
  String get settings_preferredDownloadManagerKeywords;

  /// Line under that row when no app is remembered. The row itself cannot be tapped: an app is remembered by ticking the “Always use this app” box in the download manager chooser that appears when a download starts. Quote that box's label as the chooser shows it in your language.
  ///
  /// In en, this message translates to:
  /// **'Not set — tick “Always use this app” the next time the chooser appears'**
  String get settings_preferredDownloadManagerSubtitleNotSet;

  /// Line under that row when the browser itself is remembered: the chooser is skipped, but the browser's own download confirmation still shows. appName is the browser's name.
  ///
  /// In en, this message translates to:
  /// **'{appName}, with a confirmation before each download'**
  String settings_preferredDownloadManagerSubtitleThisApp(String appName);

  /// Line under that row when the remembered app was uninstalled; the chooser shows until another app is remembered. packageName is the Android package id of the removed app.
  ///
  /// In en, this message translates to:
  /// **'No longer installed ({packageName}) — asking every time'**
  String settings_preferredDownloadManagerSubtitleUnavailable(
    String packageName,
  );

  /// Line under that row when no app is remembered and the external download manager switch is off, so WebLibre downloads everything itself and no chooser appears.
  ///
  /// In en, this message translates to:
  /// **'Not set — only used with an external download manager'**
  String get settings_preferredDownloadManagerSubtitleExternalOff;

  /// Line under that row when an app is remembered but the external download manager switch is off, so WebLibre downloads everything itself. appName is the remembered app's name, or its Android package id when it is no longer installed.
  ///
  /// In en, this message translates to:
  /// **'{appName} — not used while the external download manager is off'**
  String settings_preferredDownloadManagerSubtitleInactive(String appName);

  /// Tooltip of the button that forgets the remembered download manager, so the chooser asks again.
  ///
  /// In en, this message translates to:
  /// **'Clear preferred manager'**
  String get settings_preferredDownloadManagerClearTooltip;

  /// Section heading on the general settings screen for the default browser setting.
  ///
  /// In en, this message translates to:
  /// **'Default Browser'**
  String get settings_defaultBrowserSectionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'browser defaults'**
  String get settings_defaultBrowserSectionKeywords;

  /// Summary of the default browser setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Set WebLibre as your default browser'**
  String get settings_indexDefaultBrowserSubtitle;

  /// Section heading on the general settings screen for appearance settings.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settings_appearanceSectionTitle;

  /// Summary of the theme setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Choose system, light, or dark mode'**
  String get settings_indexThemeSubtitle;

  /// Title of the app language setting (the language of WebLibre's own interface).
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get settings_indexAppLanguageTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'locale, translation, ui language'**
  String get settings_indexAppLanguageKeywords;

  /// Summary of the app language setting.
  ///
  /// In en, this message translates to:
  /// **'Choose the language WebLibre\'s own interface uses'**
  String get settings_indexAppLanguageSubtitle;

  /// Summary of the refresh rate setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Request a high or low display refresh rate (Android)'**
  String get settings_indexRefreshRateSubtitle;

  /// Summary of the close button setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Add a button to dismiss the search / new-tab page without a back gesture'**
  String get settings_indexShowCloseButtonSubtitle;

  /// Section heading on the general settings screen for profile backup and settings transfer.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settings_profileSectionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'user, profile'**
  String get settings_profileSectionKeywords;

  /// Summary of the profile backup entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Create an encrypted backup of the profile you are using'**
  String get settings_indexBackupProfileSubtitle;

  /// Summary of the settings export/import entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Move settings between profiles or devices, or attach them to a bug report'**
  String get settings_indexSettingsTransferSubtitle;

  /// Section heading on the general settings screen for download settings.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get settings_downloadsSectionTitle;

  /// Summary of the download folder setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Choose where downloaded files are saved'**
  String get settings_indexDownloadFolderSubtitle;

  /// Summary of the preferred download manager setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'The app downloads go to without asking'**
  String get settings_indexPreferredDownloadManagerSubtitle;

  /// Section heading on the advanced settings screen for JavaScript, user agent and certificate settings.
  ///
  /// In en, this message translates to:
  /// **'Content & Identity'**
  String get settings_contentIdentitySectionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'engine'**
  String get settings_contentIdentitySectionKeywords;

  /// Summary of the JavaScript setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Turn website scripting on or off'**
  String get settings_indexJavascriptSubtitle;

  /// Summary of the custom user agent setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Override the browser user agent string'**
  String get settings_indexUserAgentSubtitle;

  /// Summary of the third-party certificate setting, shown as a settings search result. CA stands for certificate authority.
  ///
  /// In en, this message translates to:
  /// **'Allow Android CA store certificates'**
  String get settings_indexEnterpriseRootsSubtitle;

  /// Section heading on the advanced settings screen for experimental options.
  ///
  /// In en, this message translates to:
  /// **'Experimental'**
  String get settings_experimentalSectionTitle;

  /// Section heading on the advanced settings screen for troubleshooting and developer tools.
  ///
  /// In en, this message translates to:
  /// **'Developer Tools'**
  String get settings_developerToolsSectionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'debug'**
  String get settings_developerToolsSectionKeywords;

  /// Summary of the unmount-engine setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Rebuild the web engine after an overlay, instead of keeping it warm'**
  String get settings_indexUnmountGeckoViewSubtitle;

  /// Section heading on the browsing settings screen for tab settings.
  ///
  /// In en, this message translates to:
  /// **'Tabs'**
  String get settings_tabsSectionTitle;

  /// Summary of the tab list direction setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Choose how tabs are ordered in the list view'**
  String get settings_indexTabListDirectionSubtitle;

  /// Summary of the tab bar direction setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Choose how tabs are ordered in the tab bar'**
  String get settings_indexTabBarDirectionSubtitle;

  /// Summary of the child tab position setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Choose where tabs opened from another tab are inserted'**
  String get settings_indexChildTabPlacementSubtitle;

  /// Summary of the "Create Child Tabs" setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Show a button that adds a child tab under the current tab'**
  String get settings_indexCreateChildTabsSubtitle;

  /// Summary of the background tab setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Choose what happens after a tab opens in the background'**
  String get settings_indexBackgroundTabBehaviorSubtitle;

  /// Section heading on the browsing settings screen for navigation settings.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get settings_navigationSectionTitle;

  /// Summary of the double-back setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Require two Back-button presses to close the current tab'**
  String get settings_indexDoubleBackCloseTabSubtitle;

  /// Summary of the tab bar swipes entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Choose what swipes on the tab bar do'**
  String get settings_indexTabBarSwipesSubtitle;

  /// Summary of the sequential tab navigation setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Choose where stepping through tabs in order ends'**
  String get settings_indexSequentialTabNavigationSubtitle;

  /// Summary of the open-links-in-apps setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Choose how external app links open'**
  String get settings_indexOpenLinksInAppsSubtitle;

  /// Section heading on the browsing settings screen for desktop site settings.
  ///
  /// In en, this message translates to:
  /// **'Desktop Mode'**
  String get settings_desktopModeSectionTitle;

  /// Summary of the desktop mode setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Open new tabs in desktop mode by default'**
  String get settings_indexGlobalDesktopModeSubtitle;

  /// Section heading on the browsing settings screen for adding sites to the Android home screen.
  ///
  /// In en, this message translates to:
  /// **'Home Screen'**
  String get settings_homeScreenSectionTitle;

  /// Summary of the install-sites-as-apps setting, shown as a settings search result. A manifest is the file that describes a web app.
  ///
  /// In en, this message translates to:
  /// **'Allow websites without a manifest to be installed as apps'**
  String get settings_indexAllowNonManifestPwaInstallSubtitle;

  /// Section heading on the browsing settings screen for links coming from other apps.
  ///
  /// In en, this message translates to:
  /// **'External Links'**
  String get settings_externalLinksSectionTitle;

  /// Summary of the custom tabs setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Let other apps open links in a lightweight in-app tab, instead of the main browser'**
  String get settings_indexCustomTabsSubtitle;

  /// Section heading on the browsing settings screen for bookmark settings.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get settings_bookmarksSectionTitle;

  /// Section heading on the DNS over HTTPS screen.
  ///
  /// In en, this message translates to:
  /// **'Resolver Settings'**
  String get settings_resolverSettingsSectionTitle;

  /// Title of the DNS over HTTPS entry, shown as a settings search result. Technical term; usually kept in English.
  ///
  /// In en, this message translates to:
  /// **'DNS over HTTPS'**
  String get settings_indexDnsOverHttpsResolverTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'doh, resolver, dns provider, custom resolver'**
  String get settings_indexDnsOverHttpsResolverKeywords;

  /// Summary of that entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Protection level, provider choice, and saved custom resolvers'**
  String get settings_indexDnsOverHttpsResolverSubtitle;

  /// Section heading on the experimental settings screen.
  ///
  /// In en, this message translates to:
  /// **'Runtime & Startup'**
  String get settings_runtimeStartupSectionTitle;

  /// Summary of the isolated process setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Run web content in an isolated process'**
  String get settings_indexIsolatedContentProcessSubtitle;

  /// Summary of the App Zygote setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Preload the content service for faster isolated startup'**
  String get settings_indexAppZygoteProcessSubtitle;

  /// Section heading on the home settings screen for what is shown at startup.
  ///
  /// In en, this message translates to:
  /// **'Startup'**
  String get settings_startupSectionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'startup, home, resume, last tab, custom url'**
  String get settings_startupSectionKeywords;

  /// Setting for what to show when no tab is open (at startup or after closing the last tab).
  ///
  /// In en, this message translates to:
  /// **'When there is no tab to show'**
  String get settings_indexHomeTargetTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'startup, resume, last tab, custom url, homepage'**
  String get settings_indexHomeTargetKeywords;

  /// Explanation of that setting.
  ///
  /// In en, this message translates to:
  /// **'On startup and after closing the last tab'**
  String get settings_indexHomeTargetSubtitle;

  /// Summary of the "Apply when the last tab closes" setting: explains what happens when it is off.
  ///
  /// In en, this message translates to:
  /// **'Otherwise a tab from another container is opened instead'**
  String get settings_indexHomeTargetOnLastTabClosedSubtitle;

  /// Section heading on the home settings screen for wallpaper settings.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settings_homeAppearanceSectionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'home, wallpaper, background, image, blur, dim'**
  String get settings_homeAppearanceSectionKeywords;

  /// Summary of the wallpaper entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'A background image for the home page'**
  String get settings_indexWallpaperSubtitle;

  /// Section heading on the home settings screen for the search bar and page sections.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get settings_layoutSectionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'home, new tab, sections, modules, layout'**
  String get settings_layoutSectionKeywords;

  /// Setting for where the home page search bar appears.
  ///
  /// In en, this message translates to:
  /// **'Search bar position'**
  String get settings_indexHomeSearchBarPlacementTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'search, bar, position, address, url, top, bottom, tab bar, home'**
  String get settings_indexHomeSearchBarPlacementKeywords;

  /// Explanation of that setting.
  ///
  /// In en, this message translates to:
  /// **'Where the home page offers its search field'**
  String get settings_indexHomeSearchBarPlacementSubtitle;

  /// Section heading on the custom tracking protection screen for compatibility exceptions (Mozilla's allowlist).
  ///
  /// In en, this message translates to:
  /// **'Allowlist Exceptions'**
  String get settings_allowlistExceptionsSectionTitle;

  /// Title of the allowlist entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Allowlist exceptions'**
  String get settings_indexAllowlistExceptionsTitle;

  /// Summary of that entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Compatibility exceptions for major and minor website issues'**
  String get settings_indexAllowlistExceptionsSubtitle;

  /// Section heading and entry title on the custom tracking protection screen for cookie blocking.
  ///
  /// In en, this message translates to:
  /// **'Cookies'**
  String get settings_cookiesSectionTitle;

  /// Summary of the cookie entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Cookie blocking mode and policy selection'**
  String get settings_indexCookiesSubtitle;

  /// Section heading on the custom tracking protection screen for tracking content.
  ///
  /// In en, this message translates to:
  /// **'Tracking Content'**
  String get settings_trackingContentSectionTitle;

  /// Title of the tracking content entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Tracking content'**
  String get settings_indexTrackingContentTitle;

  /// Summary of that entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Tracking scripts and scope for blocking'**
  String get settings_indexTrackingContentSubtitle;

  /// Section heading and entry title on the custom tracking protection screen for tracker categories.
  ///
  /// In en, this message translates to:
  /// **'Trackers'**
  String get settings_trackersSectionTitle;

  /// Summary of the trackers entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Cryptominers, known fingerprinters, and redirect trackers'**
  String get settings_indexTrackersSubtitle;

  /// Section heading on the custom tracking protection screen. "Fingerprinting" means identifying a browser by its characteristics.
  ///
  /// In en, this message translates to:
  /// **'Advanced Fingerprinting Protection'**
  String get settings_advancedFingerprintingProtectionSectionTitle;

  /// Title of that entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Advanced fingerprinting protection'**
  String get settings_indexAdvancedFingerprintingProtectionTitle;

  /// Summary of that entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Suspected fingerprinters and tab scope'**
  String get settings_indexAdvancedFingerprintingProtectionSubtitle;

  /// Section heading on the bang settings screen for recorded usage.
  ///
  /// In en, this message translates to:
  /// **'Usage Data'**
  String get settings_usageDataSectionTitle;

  /// Section heading on the bang settings screen for bang lists downloaded from online sources.
  ///
  /// In en, this message translates to:
  /// **'Repositories'**
  String get settings_repositoriesSectionTitle;

  /// Summary of the general bang list entry, shown as a settings search result. GitHub is a website name.
  ///
  /// In en, this message translates to:
  /// **'Sync on demand from GitHub'**
  String get settings_indexGeneralBangsSubtitle;

  /// Name of the general bang list (DuckDuckGo-style bangs), with a sync button.
  ///
  /// In en, this message translates to:
  /// **'General Bangs'**
  String get settings_generalBangsTileTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'repository'**
  String get settings_generalBangsTileKeywords;

  /// Line under "General Bangs". GitHub is a website name.
  ///
  /// In en, this message translates to:
  /// **'Sync on demand from GitHub'**
  String get settings_generalBangsTileSubtitle;

  /// Summary of the Kagi bang list entry, shown as a settings search result. GitHub is a website name.
  ///
  /// In en, this message translates to:
  /// **'Sync on demand from GitHub'**
  String get settings_indexKagiBangsSubtitle;

  /// Name of the bang list from the Kagi search engine, with a sync button. Kagi is a brand name.
  ///
  /// In en, this message translates to:
  /// **'Kagi Bangs'**
  String get settings_kagiBangsTileTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'repository'**
  String get settings_kagiBangsTileKeywords;

  /// Line under "Kagi Bangs". GitHub is a website name.
  ///
  /// In en, this message translates to:
  /// **'Sync on demand from GitHub'**
  String get settings_kagiBangsTileSubtitle;

  /// Section heading on the extension settings screen.
  ///
  /// In en, this message translates to:
  /// **'Extensions'**
  String get settings_extensionsSectionTitle;

  /// Section heading on the extension settings screen for update settings.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get settings_updatesSectionTitle;

  /// Section heading on the extension settings screen for security settings.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settings_securitySectionTitle;

  /// Menu item that restores the default layout (home/new tab sections or browser menu).
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get settings_actionResetToDefaults;

  /// Title of the screen for arranging the browser menu.
  ///
  /// In en, this message translates to:
  /// **'Customize Menu'**
  String get settings_menuLayoutTitle;

  /// Instruction at the top of the menu layout screen (section level).
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder. Switch a section off to hide it from the menu.'**
  String get settings_menuLayoutHintSections;

  /// Instruction while editing the rows of one menu section.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder the rows in this section.'**
  String get settings_menuLayoutHintSectionItems;

  /// Instruction while editing the rows inside an expandable menu row.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder the rows opened from this item.'**
  String get settings_menuLayoutHintSubItems;

  /// Instruction at the top of the home/new tab section editor. "The other page" means the new tab page when editing home, and vice versa.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder. Switch a section off to hide it here without affecting the other page.'**
  String get settings_moduleSurfaceHint;

  /// Title of the editor for home page sections.
  ///
  /// In en, this message translates to:
  /// **'Customize Home'**
  String get settings_moduleSurfaceTitleHome;

  /// Title of the editor for new tab page sections.
  ///
  /// In en, this message translates to:
  /// **'Customize New Tab'**
  String get settings_moduleSurfaceTitleNewTab;

  /// Row in the home section editor for the search bar position.
  ///
  /// In en, this message translates to:
  /// **'Search bar'**
  String get settings_homeSearchBarRowTitle;

  /// Title of the proxy settings screen and category.
  ///
  /// In en, this message translates to:
  /// **'Proxy'**
  String get settings_proxyTitle;

  /// Subtitle of that screen.
  ///
  /// In en, this message translates to:
  /// **'Manage proxy connections and choose which tabs use them.'**
  String get settings_proxySubtitle;

  /// Row that opens the list of proxy connections.
  ///
  /// In en, this message translates to:
  /// **'Proxy Connections'**
  String get settings_proxyConnectionsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'sing-box, socks, vpn, wireguard, tor, onion, bridges, obfs4, snowflake'**
  String get settings_proxyConnectionsKeywords;

  /// Explanation under that row.
  ///
  /// In en, this message translates to:
  /// **'Manage proxy profiles and connections'**
  String get settings_proxyConnectionsSubtitle;

  /// Row that opens the proxy routing settings.
  ///
  /// In en, this message translates to:
  /// **'Proxy Routing'**
  String get settings_proxyRoutingTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'routing, container'**
  String get settings_proxyRoutingKeywords;

  /// Explanation under that row.
  ///
  /// In en, this message translates to:
  /// **'Choose which proxy carries regular and private tabs'**
  String get settings_proxyRoutingSubtitle;

  /// Row that opens the proxy logs.
  ///
  /// In en, this message translates to:
  /// **'Proxy Logs'**
  String get settings_proxyLogsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'log, logging, logs, diagnostics, debug, trace, verbose, troubleshoot, level'**
  String get settings_proxyLogsKeywords;

  /// Title of the toolbar & layout settings screen and category.
  ///
  /// In en, this message translates to:
  /// **'Toolbar & Layout'**
  String get settings_toolbarLayoutTitle;

  /// Placeholder of the search field on that screen.
  ///
  /// In en, this message translates to:
  /// **'Search toolbar and layout settings'**
  String get settings_toolbarLayoutSearchHint;

  /// Title of the privacy & security settings screen and category.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get settings_privacySecurityTitle;

  /// Subtitle under the header of the Privacy & Security settings screen, summarizing everything on it. The shorter line on the settings home tile is settings_categoryPrivacySecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tracking protection, fingerprinting, browsing data, and network hardening.'**
  String get settings_privacySecuritySubtitle;

  /// Title of the list of sites where tracking protection is turned off, and of its row.
  ///
  /// In en, this message translates to:
  /// **'Tracking Protection Exceptions'**
  String get settings_trackingProtectionExceptionsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'exceptions'**
  String get settings_trackingProtectionExceptionsKeywords;

  /// Explanation under that row.
  ///
  /// In en, this message translates to:
  /// **'Sites where tracking protection is disabled'**
  String get settings_trackingProtectionExceptionsTileSubtitle;

  /// Switch: delete the chosen browsing data every time the app restarts.
  ///
  /// In en, this message translates to:
  /// **'Incognito Mode'**
  String get settings_incognitoModeTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'private mode'**
  String get settings_incognitoModeKeywords;

  /// Explanation under "Incognito Mode".
  ///
  /// In en, this message translates to:
  /// **'Delete selected browsing data on app restart'**
  String get settings_incognitoModeSubtitle;

  /// Placeholder of the search field on the exceptions list.
  ///
  /// In en, this message translates to:
  /// **'Search exception URLs'**
  String get settings_trackingProtectionExceptionsSearchHint;

  /// Menu item that removes every tracking protection exception.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get settings_trackingProtectionExceptionsDeleteAll;

  /// Section heading above the list of exception sites.
  ///
  /// In en, this message translates to:
  /// **'Exception List'**
  String get settings_trackingProtectionExceptionsSectionTitle;

  /// Line under each site in the exception list.
  ///
  /// In en, this message translates to:
  /// **'Site with tracking protection disabled'**
  String get settings_trackingProtectionExceptionsEntrySubtitle;

  /// Tooltip of the button that removes one exception.
  ///
  /// In en, this message translates to:
  /// **'Remove exception'**
  String get settings_trackingProtectionExceptionsRemoveTooltip;

  /// Heading shown when the exception list is empty.
  ///
  /// In en, this message translates to:
  /// **'No exceptions'**
  String get settings_trackingProtectionExceptionsEmptyTitle;

  /// Line under that heading.
  ///
  /// In en, this message translates to:
  /// **'Sites added to exceptions will appear here'**
  String get settings_trackingProtectionExceptionsEmptySubtitle;

  /// Error heading when the exception list could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Error loading exceptions'**
  String get settings_trackingProtectionExceptionsErrorTitle;

  /// Error message when removing all exceptions failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete exceptions: {error}'**
  String settings_trackingProtectionExceptionsDeleteAllFailed(String error);

  /// Error message when removing an exception failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove exception: {error}'**
  String settings_trackingProtectionExceptionsRemoveFailed(String error);

  /// Row that opens the delete browsing data options.
  ///
  /// In en, this message translates to:
  /// **'Delete Browsing Data'**
  String get settings_deleteBrowsingDataTileTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'clear data'**
  String get settings_deleteBrowsingDataTileKeywords;

  /// Setting for automatically deleting old browsing history.
  ///
  /// In en, this message translates to:
  /// **'Auto-Clear History'**
  String get settings_autoClearHistoryTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'history retention'**
  String get settings_autoClearHistoryKeywords;

  /// Explanation under that setting.
  ///
  /// In en, this message translates to:
  /// **'Automatically delete browsing history older than the selected time period'**
  String get settings_autoClearHistorySubtitle;

  /// Setting for automatically closing old tabs that belong to no container.
  ///
  /// In en, this message translates to:
  /// **'Auto-Clear Unassigned Tabs'**
  String get settings_autoClearUnassignedTabsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'cleanup tabs'**
  String get settings_autoClearUnassignedTabsKeywords;

  /// Explanation under that setting.
  ///
  /// In en, this message translates to:
  /// **'Automatically close unassigned tabs older than the selected time period'**
  String get settings_autoClearUnassignedTabsSubtitle;

  /// Time period option for automatic clearing: never clear.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get settings_durationNever;

  /// Time period option for automatic clearing.
  ///
  /// In en, this message translates to:
  /// **'1 Day'**
  String get settings_duration1Day;

  /// Time period option for automatic clearing.
  ///
  /// In en, this message translates to:
  /// **'3 Days'**
  String get settings_duration3Days;

  /// Time period option for automatic clearing.
  ///
  /// In en, this message translates to:
  /// **'1 Week'**
  String get settings_duration1Week;

  /// Time period option for automatic clearing.
  ///
  /// In en, this message translates to:
  /// **'2 Weeks'**
  String get settings_duration2Weeks;

  /// Time period option for automatic clearing.
  ///
  /// In en, this message translates to:
  /// **'1 Month'**
  String get settings_duration1Month;

  /// Time period option for automatic clearing.
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get settings_duration3Months;

  /// Switch that tells websites the user does not want their data sold or shared. "Global Privacy Control" is the name of a web standard; GPC is its abbreviation.
  ///
  /// In en, this message translates to:
  /// **'Global Privacy Control (GPC)'**
  String get settings_globalPrivacyControlTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'gpc'**
  String get settings_globalPrivacyControlKeywords;

  /// Switch that blocks screenshots and screen recordings of the app.
  ///
  /// In en, this message translates to:
  /// **'Screenshot protection'**
  String get settings_screenshotProtectionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'screenshots'**
  String get settings_screenshotProtectionKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Blocks screenshots and screen recordings for this app on Android.'**
  String get settings_screenshotProtectionSubtitle;

  /// Switch: allow screenshots while a private tab is shown.
  ///
  /// In en, this message translates to:
  /// **'Allow screenshots in private tabs'**
  String get settings_allowPrivateTabScreenshotsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'screenshots, incognito, private'**
  String get settings_allowPrivateTabScreenshotsKeywords;

  /// Line under that switch while screenshot protection blocks all screenshots anyway.
  ///
  /// In en, this message translates to:
  /// **'Overridden by screenshot protection, which blocks capture in every tab.'**
  String get settings_allowPrivateTabScreenshotsOverriddenSubtitle;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Private tabs can be screenshotted and recorded, and appear in the app switcher preview.'**
  String get settings_allowPrivateTabScreenshotsSubtitle;

  /// Setting for only loading pages over encrypted HTTPS connections.
  ///
  /// In en, this message translates to:
  /// **'Block insecure HTTP connections'**
  String get settings_httpsOnlyModeTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'https only'**
  String get settings_httpsOnlyModeKeywords;

  /// HTTPS-only option: off. One of three segments sharing a single row on a phone: keep it to one or two short words.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get settings_httpsOnlyModeDisabledLabel;

  /// HTTPS-only option: on in all tabs. One of three segments sharing a single row on a phone: keep it to one or two short words.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get settings_httpsOnlyModeEnabledLabel;

  /// HTTPS-only option: on in private tabs only. One of three segments sharing a single row on a phone: keep it to one or two short words.
  ///
  /// In en, this message translates to:
  /// **'Private mode only'**
  String get settings_httpsOnlyModePrivateOnlyLabel;

  /// Row that opens the DNS over HTTPS settings. Technical term; usually kept in English.
  ///
  /// In en, this message translates to:
  /// **'DNS over HTTPS'**
  String get settings_dnsOverHttpsTileTitle;

  /// Heading of the choice of tracker blocking level. "Enhanced Tracking Protection" is Mozilla's feature name; use Firefox's translation if available.
  ///
  /// In en, this message translates to:
  /// **'Enhanced Tracking Protection'**
  String get settings_enhancedTrackingProtectionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'etp, standard, strict, custom'**
  String get settings_enhancedTrackingProtectionKeywords;

  /// Tracking protection level option: off.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get settings_trackingProtectionDisabledLabel;

  /// Tracking protection level option: standard (Firefox's name for the balanced level).
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get settings_trackingProtectionStandardLabel;

  /// Explanation under "Standard".
  ///
  /// In en, this message translates to:
  /// **'Balances protection and compatibility by blocking fewer tracker categories.'**
  String get settings_trackingProtectionStandardSubtitle;

  /// Tracking protection level option: strict (Firefox's name).
  ///
  /// In en, this message translates to:
  /// **'Strict'**
  String get settings_trackingProtectionStrictLabel;

  /// Explanation under "Strict".
  ///
  /// In en, this message translates to:
  /// **'Blocks more tracker categories, including tracking content, but may break some sites.'**
  String get settings_trackingProtectionStrictSubtitle;

  /// Tracking protection level option: custom choices.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get settings_trackingProtectionCustomLabel;

  /// Explanation under "Custom".
  ///
  /// In en, this message translates to:
  /// **'Choose which trackers and scripts to block.'**
  String get settings_trackingProtectionCustomSubtitle;

  /// Switch: use the browser engine's built-in block lists for tracker categories.
  ///
  /// In en, this message translates to:
  /// **'Content Blocking Database'**
  String get settings_contentBlockingDatabaseTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'ads, trackers, content blocking'**
  String get settings_contentBlockingDatabaseKeywords;

  /// Explanation under that switch. GeckoView is the engine's name; ETP means Enhanced Tracking Protection.
  ///
  /// In en, this message translates to:
  /// **'Use GeckoView blocker lists for ETP categories such as ads, analytics, and social trackers. Requires an app restart.'**
  String get settings_contentBlockingDatabaseSubtitle;

  /// Switch: block trackers that bounce you through their own sites while navigating. Mozilla feature name.
  ///
  /// In en, this message translates to:
  /// **'Bounce Tracking Protection'**
  String get settings_bounceTrackingProtectionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'redirect trackers'**
  String get settings_bounceTrackingProtectionKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Blocks redirect trackers that collect data through intermediate URL redirects between websites'**
  String get settings_bounceTrackingProtectionSubtitle;

  /// Setting for removing tracking parameters from web addresses.
  ///
  /// In en, this message translates to:
  /// **'Query Parameter Stripping'**
  String get settings_queryParameterStrippingTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'utm'**
  String get settings_queryParameterStrippingKeywords;

  /// Explanation under that setting.
  ///
  /// In en, this message translates to:
  /// **'Removes tracking parameters from URLs to prevent cross-site user tracking'**
  String get settings_queryParameterStrippingSubtitle;

  /// Parameter stripping option: off. One of three segments sharing a single row on a phone: keep it to one or two short words.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get settings_queryParameterStrippingDisabledLabel;

  /// Parameter stripping option: on in all tabs. One of three segments sharing a single row on a phone: keep it to one or two short words.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get settings_queryParameterStrippingEnabledLabel;

  /// Parameter stripping option: on in private tabs only. One of three segments sharing a single row on a phone: keep it to one or two short words.
  ///
  /// In en, this message translates to:
  /// **'Private mode only'**
  String get settings_queryParameterStrippingPrivateOnlyLabel;

  /// Row that opens the filter list settings of the uBlock Origin extension. uBlock is a product name.
  ///
  /// In en, this message translates to:
  /// **'uBlock Filter Lists & Hardenings'**
  String get settings_uBlockFilterListsTileTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'ublock, filters'**
  String get settings_uBlockFilterListsTileKeywords;

  /// Explanation under that row. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'Manage filter lists and apply WebLibre hardenings'**
  String get settings_uBlockFilterListsTileSubtitle;

  /// Switch for site isolation (each website in its own process). "Fission" is Mozilla's project name.
  ///
  /// In en, this message translates to:
  /// **'Fission (Site Isolation)'**
  String get settings_fissionEnabledTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'site isolation'**
  String get settings_fissionEnabledKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Isolates each site into a separate OS process for improved security. Requires an app restart.'**
  String get settings_fissionEnabledSubtitle;

  /// Switch: warn about websites and downloads known to contain malware. "Safe Browsing" is a Google service name.
  ///
  /// In en, this message translates to:
  /// **'Safe Browsing Malware Protection'**
  String get settings_safeBrowsingMalwareTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'google safe browsing'**
  String get settings_safeBrowsingMalwareKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Warn about dangerous websites and malicious downloads.'**
  String get settings_safeBrowsingMalwareSubtitle;

  /// Switch: warn about known fake login (phishing) websites. "Safe Browsing" is a Google service name.
  ///
  /// In en, this message translates to:
  /// **'Safe Browsing Phishing Protection'**
  String get settings_safeBrowsingPhishingTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'google safe browsing'**
  String get settings_safeBrowsingPhishingKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Warn about deceptive websites and login pages.'**
  String get settings_safeBrowsingPhishingSubtitle;

  /// Switch: let Mozilla's add-on website talk to the browser to install extensions.
  ///
  /// In en, this message translates to:
  /// **'Extensions Web API'**
  String get settings_extensionsWebApiTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'extension api'**
  String get settings_extensionsWebApiKeywords;

  /// Explanation under that switch. mozAddonManager is a technical API name; keep it unchanged.
  ///
  /// In en, this message translates to:
  /// **'Enable mozAddonManager API exposure for web content and extension pages. Requires an app restart.'**
  String get settings_extensionsWebApiSubtitle;

  /// Heading of the settings that control which other apps may open links in WebLibre.
  ///
  /// In en, this message translates to:
  /// **'App-Opening Protection'**
  String get settings_appOpeningProtectionSectionHeader;

  /// Switch: ask before opening links that other apps send.
  ///
  /// In en, this message translates to:
  /// **'Block apps from opening your browser'**
  String get settings_blockAppsOpeningBrowserTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'intent gatekeeper, external apps'**
  String get settings_blockAppsOpeningBrowserKeywords;

  /// Explanation under that switch. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'Ask before opening links that other apps send to WebLibre.'**
  String get settings_blockAppsOpeningBrowserSubtitle;

  /// Heading above the list of apps with a remembered allow/block choice.
  ///
  /// In en, this message translates to:
  /// **'Managed apps'**
  String get settings_managedAppsSectionHeader;

  /// Status of an app in that list: its links are always allowed.
  ///
  /// In en, this message translates to:
  /// **'Always allowed'**
  String get settings_managedAppAlwaysAllowedLabel;

  /// Status of an app in that list: its links are always blocked.
  ///
  /// In en, this message translates to:
  /// **'Always blocked'**
  String get settings_managedAppAlwaysBlockedLabel;

  /// Menu item that sets the app to always allowed.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get settings_managedAppActionAllow;

  /// Menu item that sets the app to always blocked.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get settings_managedAppActionBlock;

  /// Row that opens the browser languages settings (languages websites are told you prefer).
  ///
  /// In en, this message translates to:
  /// **'Browser Languages'**
  String get settings_browserLanguagesTileTitle;

  /// Explanation under that row.
  ///
  /// In en, this message translates to:
  /// **'Configure language preferences exposed to websites'**
  String get settings_browserLanguagesTileSubtitle;

  /// Row that opens the fingerprint protection settings.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint Protection'**
  String get settings_fingerprintProtectionTileTitle;

  /// Explanation under that row.
  ///
  /// In en, this message translates to:
  /// **'Granular control over browser fingerprinting'**
  String get settings_fingerprintProtectionTileSubtitle;

  /// Row that opens the "Resist Fingerprinting" settings. Mozilla feature name; use Firefox's translation if available.
  ///
  /// In en, this message translates to:
  /// **'Resist Fingerprinting'**
  String get settings_resistFingerprintingTileTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'rfp'**
  String get settings_resistFingerprintingTileKeywords;

  /// Explanation under that row.
  ///
  /// In en, this message translates to:
  /// **'Advanced fingerprinting protection hardening'**
  String get settings_resistFingerprintingTileSubtitle;

  /// Switch that turns on protection against websites reaching devices on the local network. "Local Network Access" is the feature name.
  ///
  /// In en, this message translates to:
  /// **'Local Network Access'**
  String get settings_lnaEnabledTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'lan'**
  String get settings_lnaEnabledKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Enable local network and device access blocking'**
  String get settings_lnaEnabledSubtitle;

  /// Switch: block all web page requests to local network addresses.
  ///
  /// In en, this message translates to:
  /// **'Block Local Network Requests'**
  String get settings_lnaBlockingTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'lan'**
  String get settings_lnaBlockingKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Block web page requests to local network addresses'**
  String get settings_lnaBlockingSubtitle;

  /// Switch: block trackers from reaching local network addresses.
  ///
  /// In en, this message translates to:
  /// **'Block Local Network Trackers'**
  String get settings_lnaBlockTrackersTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'lan'**
  String get settings_lnaBlockTrackersKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Block trackers from accessing local network resources'**
  String get settings_lnaBlockTrackersSubtitle;

  /// Title of the screen for exporting and importing settings.
  ///
  /// In en, this message translates to:
  /// **'Export & Import'**
  String get settings_transferTitle;

  /// Menu item for choosing a different folder for exported settings files.
  ///
  /// In en, this message translates to:
  /// **'Change export folder'**
  String get settings_transferChangeExportFolder;

  /// Explanation at the top of the export & import screen.
  ///
  /// In en, this message translates to:
  /// **'Move settings between profiles or devices, or attach them to a bug report. This carries settings only — no tabs, history, bookmarks, or logins. To transfer those, back up the whole profile.'**
  String get settings_transferIntro;

  /// Note on the export & import screen listing settings that are not included and stay on this device.
  ///
  /// In en, this message translates to:
  /// **'Web search preferences, home and new-tab layout, menu order and pinned add-ons stay on this device'**
  String get settings_transferDeviceOnlyNote;

  /// Heading of the export card.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get settings_transferExportSectionTitle;

  /// Line under "Export".
  ///
  /// In en, this message translates to:
  /// **'Export the selected sections to a readable file'**
  String get settings_transferExportSectionSubtitle;

  /// Button that saves the chosen settings to a file.
  ///
  /// In en, this message translates to:
  /// **'Save file'**
  String get settings_transferSaveFileButton;

  /// Heading of the import card.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get settings_transferImportSectionTitle;

  /// Line under "Import".
  ///
  /// In en, this message translates to:
  /// **'Choose which settings to apply after opening the file'**
  String get settings_transferImportSectionSubtitle;

  /// Button that opens a settings export file to import.
  ///
  /// In en, this message translates to:
  /// **'Open file'**
  String get settings_transferOpenFileButton;

  /// Button that imports a settings export from the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get settings_transferPasteButton;

  /// Confirmation after choosing an export folder. name is the folder's name.
  ///
  /// In en, this message translates to:
  /// **'Exports will be saved to {name}'**
  String settings_transferExportFolderChanged(String name);

  /// Confirmation after saving an export. name is the file name.
  ///
  /// In en, this message translates to:
  /// **'Saved as {name}'**
  String settings_transferSavedAs(String name);

  /// Error when the chosen export folder can no longer be accessed.
  ///
  /// In en, this message translates to:
  /// **'The export folder is no longer there. Choose one again and retry.'**
  String get settings_transferExportFolderGone;

  /// Error message when saving the export failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Could not save the export: {error}'**
  String settings_transferSaveFailed(String error);

  /// Confirmation after copying the export to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Settings copied to the clipboard'**
  String get settings_transferCopiedToClipboard;

  /// Error message when copying the export failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Could not copy the export: {error}'**
  String settings_transferCopyFailed(String error);

  /// Error when the export contains no settings this app version understands. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'This export holds nothing this version of WebLibre can apply.'**
  String get settings_transferImportNothingApplicable;

  /// Confirmation after importing settings.
  ///
  /// In en, this message translates to:
  /// **'Settings imported'**
  String get settings_transferImportedSuccess;

  /// Error message when importing settings failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Could not import the settings: {error}'**
  String settings_transferImportFailed(String error);

  /// Error when the chosen file is not a settings export.
  ///
  /// In en, this message translates to:
  /// **'That file is not a settings export.'**
  String get settings_transferNotASettingsFile;

  /// Error message when the chosen file could not be read. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Could not read the file: {error}'**
  String settings_transferReadFileFailed(String error);

  /// Error when importing from an empty clipboard.
  ///
  /// In en, this message translates to:
  /// **'The clipboard is empty.'**
  String get settings_transferClipboardEmpty;

  /// Error message when the clipboard could not be read. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Could not read the clipboard: {error}'**
  String settings_transferReadClipboardFailed(String error);

  /// Name of the export section holding WebLibre's own settings, shown as a checkbox on the export screen and in the import dialog.
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get settings_transferSectionAppSettingsTitle;

  /// Line under "App settings" listing what that section holds. torBrand is the Tor brand name and stays untranslated.
  ///
  /// In en, this message translates to:
  /// **'Appearance, browsing, tabs, privacy, {torBrand} and web engine settings'**
  String settings_transferSectionAppSettingsDescription(String torBrand);

  /// Name of the export section holding the browser engine preferences (Gecko is the engine's name), shown as a checkbox on the export screen and in the import dialog.
  ///
  /// In en, this message translates to:
  /// **'Gecko preferences'**
  String get settings_transferSectionGeckoPrefsTitle;

  /// Line under "Gecko preferences" explaining what that section holds.
  ///
  /// In en, this message translates to:
  /// **'Advanced engine preferences you changed by hand'**
  String get settings_transferSectionGeckoPrefsDescription;

  /// Error when importing settings: the chosen file or clipboard text is not JSON at all.
  ///
  /// In en, this message translates to:
  /// **'This is not a JSON file.'**
  String get settings_importErrorNotJson;

  /// Error when importing settings: the JSON is not a WebLibre settings export. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'This is not a WebLibre settings export.'**
  String get settings_importErrorNotSettingsExport;

  /// Error when importing settings: the file lacks its format version number.
  ///
  /// In en, this message translates to:
  /// **'The export does not say which format version it is.'**
  String get settings_importErrorMissingFormatVersion;

  /// Error when importing settings from a newer app version. version is the file's format number; supported is the highest this app reads.
  ///
  /// In en, this message translates to:
  /// **'This export was written by a newer version of WebLibre (format {version}, this version reads up to {supported}). Update the app and try again.'**
  String settings_importErrorNewerFormatVersion(int version, int supported);

  /// Error when importing settings: the file holds no sections.
  ///
  /// In en, this message translates to:
  /// **'The export contains no settings.'**
  String get settings_importErrorNoSettings;

  /// Error when importing settings: one section of the file has the wrong shape. section is the name of an export section as shown in the export and import lists (such as "App settings"), or the raw key a file used for a section this version does not know.
  ///
  /// In en, this message translates to:
  /// **'The \"{section}\" section is malformed.'**
  String settings_importErrorMalformedSection(String section);

  /// Error when importing settings: an informational field of the file (such as app_version) has the wrong type. field is that field's name as written in the file.
  ///
  /// In en, this message translates to:
  /// **'The export\'s \"{field}\" field is malformed.'**
  String settings_importErrorMalformedField(String field);

  /// Error when importing engine preferences: one line of the section is not in the expected format. section is the name of an export section as shown in the export and import lists (such as "App settings"), or the raw key a file used for a section this version does not know. line is that line from the file, possibly shortened.
  ///
  /// In en, this message translates to:
  /// **'The \"{section}\" section has a line WebLibre cannot read: \"{line}\". Importing it would reset preferences rather than restore them.'**
  String settings_importErrorUnreadablePrefsLine(String section, String line);

  /// Error when importing engine preferences: the section lacks the marker WebLibre writes. section is the name of an export section as shown in the export and import lists (such as "App settings"), or the raw key a file used for a section this version does not know.
  ///
  /// In en, this message translates to:
  /// **'The \"{section}\" section is not a WebLibre preferences snapshot.'**
  String settings_importErrorNotPrefsSnapshot(String section);

  /// Error when importing engine preferences: the section lacks its schema version. section is the name of an export section as shown in the export and import lists (such as "App settings"), or the raw key a file used for a section this version does not know.
  ///
  /// In en, this message translates to:
  /// **'The \"{section}\" section does not say which schema version it is.'**
  String settings_importErrorMissingSchemaVersion(String section);

  /// Error when importing engine preferences: one preference would be lost on import. section is the name of an export section as shown in the export and import lists (such as "App settings"), or the raw key a file used for a section this version does not know. pref is the preference name.
  ///
  /// In en, this message translates to:
  /// **'The \"{section}\" section holds a preference WebLibre could not read back: \"{pref}\".'**
  String settings_importErrorUnreadablePref(String section, String pref);

  /// Error when importing settings: one section comes from a newer app version. section is the name of an export section as shown in the export and import lists (such as "App settings"), or the raw key a file used for a section this version does not know. version is its schema number; supported is the highest this app reads.
  ///
  /// In en, this message translates to:
  /// **'The \"{section}\" section was written by a newer version of WebLibre (schema {version}, this version reads up to {supported}). Update the app and try again.'**
  String settings_importErrorNewerSectionSchema(
    String section,
    int version,
    int supported,
  );

  /// Error when an import failed while applying a section, before any other section was applied. failed is the section name (such as "App settings"); error is the reason.
  ///
  /// In en, this message translates to:
  /// **'The \"{failed}\" section stopped part way through and may be half-applied: {error}'**
  String settings_importPartialFailure(String failed, String error);

  /// Error when an import failed while applying a section after others were already applied. applied is the comma-separated names of the sections already imported; failed is the failing section; error is the reason.
  ///
  /// In en, this message translates to:
  /// **'Imported: {applied}. The \"{failed}\" section then stopped part way through and may be half-applied: {error}'**
  String settings_importPartialFailureAfterApplied(
    String applied,
    String failed,
    String error,
  );

  /// Title of the screen, and its row, for extra security settings of the browser engine ("hardening" means stricter security).
  ///
  /// In en, this message translates to:
  /// **'Web Engine Hardening'**
  String get settings_webEngineHardeningTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'hardening'**
  String get settings_webEngineHardeningKeywords;

  /// Placeholder of the search field on that screen.
  ///
  /// In en, this message translates to:
  /// **'Search hardening groups'**
  String get settings_webEngineHardeningSearchHint;

  /// Menu item that resets all engine hardening preferences.
  ///
  /// In en, this message translates to:
  /// **'Reset all preferences'**
  String get settings_webEngineHardeningResetAllMenuItem;

  /// Title of the confirmation dialog for that reset.
  ///
  /// In en, this message translates to:
  /// **'Reset all preferences?'**
  String get settings_webEngineHardeningResetAllDialogTitle;

  /// Body of that dialog.
  ///
  /// In en, this message translates to:
  /// **'This will reset all user-defined web engine preferences to their defaults.'**
  String get settings_webEngineHardeningResetAllDialogContent;

  /// Section heading above the switch that applies all hardening groups at once.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get settings_webEngineHardeningOverviewTitle;

  /// Switch that turns every hardening group on or off at once.
  ///
  /// In en, this message translates to:
  /// **'Complete Hardening'**
  String get settings_webEngineHardeningCompleteTitle;

  /// Summary of that switch, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Apply or reset all grouped hardening preferences'**
  String get settings_webEngineHardeningCompleteSubtitle;

  /// Line under that switch.
  ///
  /// In en, this message translates to:
  /// **'Toggle all grouped hardening preferences at once.'**
  String get settings_webEngineHardeningCompleteToggleHint;

  /// Section heading above the list of hardening groups.
  ///
  /// In en, this message translates to:
  /// **'Hardening Groups'**
  String get settings_webEngineHardeningGroupsTitle;

  /// Error heading when the hardening preferences could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Could not load preference settings'**
  String get settings_webEngineHardeningLoadFailedTitle;

  /// Placeholder of the search field inside a hardening group.
  ///
  /// In en, this message translates to:
  /// **'Search hardening settings'**
  String get settings_webEngineHardeningGroupSearchHint;

  /// Section heading above a group's master switch.
  ///
  /// In en, this message translates to:
  /// **'Group Controls'**
  String get settings_webEngineHardeningGroupControlsTitle;

  /// Section heading above a group's individual preferences.
  ///
  /// In en, this message translates to:
  /// **'Preference Settings'**
  String get settings_webEngineHardeningPreferenceSettingsTitle;

  /// Small badge on a hardening preference that is optional (not part of the recommended set). Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get settings_webEngineHardeningOptionalBadge;

  /// Title of the main settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_settingsHomeTitle;

  /// Placeholder of the search field on the main settings screen.
  ///
  /// In en, this message translates to:
  /// **'Search all settings'**
  String get settings_settingsHomeSearchHint;

  /// Title of the search settings screen and category.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get settings_searchTitle;

  /// Subtitle of that screen listing what it contains.
  ///
  /// In en, this message translates to:
  /// **'Providers, bangs, history suggestions, and on-device search.'**
  String get settings_searchSubtitle;

  /// Heading of the choice of default search engine.
  ///
  /// In en, this message translates to:
  /// **'Default Search Provider'**
  String get settings_defaultSearchProviderTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'search engine'**
  String get settings_defaultSearchProviderKeywords;

  /// Heading of the choice of service that suggests search terms while typing.
  ///
  /// In en, this message translates to:
  /// **'Default Autocomplete Provider'**
  String get settings_defaultAutocompleteProviderTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'suggestions'**
  String get settings_defaultAutocompleteProviderKeywords;

  /// Row that opens the list of user-created search engines (user bangs).
  ///
  /// In en, this message translates to:
  /// **'Custom Search Engines'**
  String get settings_customSearchEnginesTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'user bangs, providers'**
  String get settings_customSearchEnginesKeywords;

  /// Explanation under that row.
  ///
  /// In en, this message translates to:
  /// **'Add and manage your own search providers'**
  String get settings_customSearchEnginesSubtitle;

  /// Row that opens the bang settings.
  ///
  /// In en, this message translates to:
  /// **'Bang Settings'**
  String get settings_bangSettingsListTitle;

  /// Explanation under that row.
  ///
  /// In en, this message translates to:
  /// **'Manage bang repositories and usage data'**
  String get settings_bangSettingsListSubtitle;

  /// Setting for how many recent searches are remembered.
  ///
  /// In en, this message translates to:
  /// **'Search History Limit'**
  String get settings_searchHistoryLimitTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'history, entries'**
  String get settings_searchHistoryLimitKeywords;

  /// Explanation under that setting.
  ///
  /// In en, this message translates to:
  /// **'Maximum number of recent searches to remember'**
  String get settings_searchHistoryLimitSubtitle;

  /// Unit shown after the number field for the search history limit (e.g. "20 entries"). Lowercase.
  ///
  /// In en, this message translates to:
  /// **'entries'**
  String get settings_searchHistoryLimitSuffix;

  /// Validation error when the number field is empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a value'**
  String get settings_validationEnterValue;

  /// Validation error when the entry is not a number.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get settings_validationEnterValidNumber;

  /// Validation error when the number is out of range.
  ///
  /// In en, this message translates to:
  /// **'Value must be between 0 and 100'**
  String get settings_validationValueBetween0And100;

  /// Switch: let the search screen read the clipboard to suggest a copied address.
  ///
  /// In en, this message translates to:
  /// **'Allow clipboard access for suggestions'**
  String get settings_allowClipboardAccessTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'clipboard'**
  String get settings_allowClipboardAccessKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'The browser can read the clipboard to suggest URLs'**
  String get settings_allowClipboardAccessSubtitle;

  /// Switch: while typing in the address bar, suggest pages from the saved browsing history (result rows and inline completion).
  ///
  /// In en, this message translates to:
  /// **'Suggest from history'**
  String get settings_historySuggestionsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'history suggestions, visited pages, autocomplete, ghost text, privacy'**
  String get settings_historySuggestionsKeywords;

  /// Explanation under that switch. Makes clear that turning it off hides suggestions without deleting history.
  ///
  /// In en, this message translates to:
  /// **'Show visited pages and complete addresses from your history while typing. Turning this off keeps your history.'**
  String get settings_historySuggestionsSubtitle;

  /// Switch: let searches typed in a private tab use the search suggestion provider and the saved browsing history, like regular tabs do. Off by default.
  ///
  /// In en, this message translates to:
  /// **'Suggestions in private tabs'**
  String get settings_privateSearchSuggestionsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'private, incognito, search suggestions, history, privacy'**
  String get settings_privateSearchSuggestionsKeywords;

  /// Explanation under that switch. Warns that turning it on sends the text typed in private tabs to the search suggestion provider.
  ///
  /// In en, this message translates to:
  /// **'Use the suggestion provider and your history while typing in a private tab. What you type is sent to the provider.'**
  String get settings_privateSearchSuggestionsSubtitle;

  /// Switch: pressing Enter accepts the suggested completion shown in the address field.
  ///
  /// In en, this message translates to:
  /// **'Autocomplete on Enter'**
  String get settings_acceptSuggestionOnSubmitTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'submit, keyboard, suggestions'**
  String get settings_acceptSuggestionOnSubmitKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Accept the inline suggestion when pressing Enter on the keyboard'**
  String get settings_acceptSuggestionOnSubmitSubtitle;

  /// Switch: complete typed addresses with well-known websites.
  ///
  /// In en, this message translates to:
  /// **'Popular site suggestions'**
  String get settings_popularSitesAutocompleteTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'popular sites, domains, ghost text, autocomplete'**
  String get settings_popularSitesAutocompleteKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Complete typed text with well-known domains when your history and bookmarks have no match'**
  String get settings_popularSitesAutocompleteSubtitle;

  /// Switch: store the text of visited pages on the device so it can be searched.
  ///
  /// In en, this message translates to:
  /// **'Enable local search index'**
  String get settings_localIndexEnabledTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'page text, history'**
  String get settings_localIndexEnabledKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Index visited pages locally so the browser can search their content. Visit metadata stays in the engine; only page text is stored on-device.'**
  String get settings_localIndexEnabledSubtitle;

  /// Switch: also store the text of pages visited in private tabs.
  ///
  /// In en, this message translates to:
  /// **'Index private tabs'**
  String get settings_indexPrivateTabsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'incognito'**
  String get settings_indexPrivateTabsKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Include pages opened in private tabs in the local index. Off by default.'**
  String get settings_indexPrivateTabsSubtitle;

  /// Title of the confirmation dialog before deleting the local page index.
  ///
  /// In en, this message translates to:
  /// **'Clear local search index?'**
  String get settings_clearLocalIndexDialogTitle;

  /// Body of that dialog.
  ///
  /// In en, this message translates to:
  /// **'This removes all locally indexed page content. Engine history (visit metadata) is not affected.'**
  String get settings_clearLocalIndexDialogContent;

  /// Row showing how many pages are stored in the local index, with a clear button.
  ///
  /// In en, this message translates to:
  /// **'Indexed pages'**
  String get settings_localIndexStatsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'clear index, stats'**
  String get settings_localIndexStatsKeywords;

  /// Line under "Indexed pages". count is the number of pages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page indexed} other{{count} pages indexed}}'**
  String settings_localIndexPagesIndexed(int count);

  /// Section heading on the search settings screen for search engines.
  ///
  /// In en, this message translates to:
  /// **'Providers'**
  String get settings_searchSectionProvidersTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'engines'**
  String get settings_searchSectionProvidersKeywords;

  /// Section heading on the search settings screen for bangs.
  ///
  /// In en, this message translates to:
  /// **'Bang Shortcuts'**
  String get settings_searchSectionBangShortcutsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'bangs'**
  String get settings_searchSectionBangShortcutsKeywords;

  /// Section heading on the search settings screen for history and suggestions.
  ///
  /// In en, this message translates to:
  /// **'History & Suggestions'**
  String get settings_searchSectionHistorySuggestionsTitle;

  /// Section heading on the search settings screen for the on-device page index.
  ///
  /// In en, this message translates to:
  /// **'Local Search Index'**
  String get settings_searchSectionLocalIndexTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'on device search, index'**
  String get settings_searchSectionLocalIndexKeywords;

  /// Summary of the default search engine setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Choose the default engine for searches'**
  String get settings_indexDefaultSearchProviderSubtitle;

  /// Summary of the autocomplete provider setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Choose the provider for search suggestions'**
  String get settings_indexDefaultAutocompleteProviderSubtitle;

  /// Summary of the "Autocomplete on enter" setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Accept the inline suggestion when pressing enter'**
  String get settings_indexAcceptSuggestionOnSubmitSubtitle;

  /// Summary of the history suggestions setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Suggest visited pages while typing'**
  String get settings_indexHistorySuggestionsSubtitle;

  /// Summary of the private tab suggestions setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Use suggestions and history in private tabs'**
  String get settings_indexPrivateSearchSuggestionsSubtitle;

  /// Summary of the popular site suggestions setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Complete typed text with well-known domains'**
  String get settings_indexPopularSitesAutocompleteSubtitle;

  /// Summary of the local search index setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Index visited pages locally for content search'**
  String get settings_indexLocalIndexEnabledSubtitle;

  /// Summary of the "Index private tabs" setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Include private tabs in the local index'**
  String get settings_indexIndexPrivateTabsSubtitle;

  /// Summary of the indexed pages entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'View and clear the local index'**
  String get settings_indexLocalIndexStatsSubtitle;

  /// Title of the web content settings screen and category.
  ///
  /// In en, this message translates to:
  /// **'Web Content'**
  String get settings_webContentTitle;

  /// Subtitle of that screen listing what it contains.
  ///
  /// In en, this message translates to:
  /// **'Text rendering, reader mode, PDFs, and local AI features.'**
  String get settings_webContentSubtitle;

  /// Switch: let websites use their own downloadable fonts.
  ///
  /// In en, this message translates to:
  /// **'Web Fonts'**
  String get settings_webFontsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'fonts'**
  String get settings_webFontsKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Allow websites to use custom fonts'**
  String get settings_webFontsSubtitle;

  /// Switch: let Android's text size setting control page text size.
  ///
  /// In en, this message translates to:
  /// **'Automatic Font Size'**
  String get settings_automaticFontSizeTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'text size'**
  String get settings_automaticFontSizeKeywords;

  /// Explanation under that switch. "Font size factor" and "inflation" refer to the two settings below it.
  ///
  /// In en, this message translates to:
  /// **'Automatically adjust font size based on system settings. Disable to manually control font size factor and inflation.'**
  String get settings_automaticFontSizeSubtitle;

  /// Slider that scales the text size of web pages.
  ///
  /// In en, this message translates to:
  /// **'Font Size Factor'**
  String get settings_fontSizeFactorTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'zoom, text'**
  String get settings_fontSizeFactorKeywords;

  /// Explanation under that slider.
  ///
  /// In en, this message translates to:
  /// **'Scale web page text size'**
  String get settings_fontSizeFactorSubtitle;

  /// Line under a text size setting that cannot be changed while automatic font size is on.
  ///
  /// In en, this message translates to:
  /// **'Disabled while automatic font size is enabled'**
  String get settings_disabledWhileAutomaticFontSize;

  /// Switch that enlarges text on pages not designed for phones. "Font inflation" is the browser engine's term.
  ///
  /// In en, this message translates to:
  /// **'Font Inflation'**
  String get settings_fontInflationTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'readability'**
  String get settings_fontInflationKeywords;

  /// Explanation under that switch. "Viewport meta tag" is a web technical term.
  ///
  /// In en, this message translates to:
  /// **'Enlarge text on pages that lack a mobile viewport meta tag'**
  String get settings_fontInflationSubtitle;

  /// Switch: zoom in automatically when a text field on a page is tapped.
  ///
  /// In en, this message translates to:
  /// **'Input Auto Zoom'**
  String get settings_inputAutoZoomTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'forms'**
  String get settings_inputAutoZoomKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Automatically zoom in when focusing text inputs'**
  String get settings_inputAutoZoomSubtitle;

  /// Switch: allow pinch-to-zoom on every website, even ones that block it.
  ///
  /// In en, this message translates to:
  /// **'Zoom on All Websites'**
  String get settings_forceUserScalableTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'pinch, accessibility'**
  String get settings_forceUserScalableKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Allow pinch and zoom, even on websites that prevent this gesture'**
  String get settings_forceUserScalableSubtitle;

  /// Switch: show PDF files inside the browser.
  ///
  /// In en, this message translates to:
  /// **'Built-in PDF Viewer'**
  String get settings_pdfViewerTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'pdf'**
  String get settings_pdfViewerKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Open PDF files directly in the browser without downloading'**
  String get settings_pdfViewerSubtitle;

  /// Switch: offer reader mode (a simplified, easy-to-read view of articles).
  ///
  /// In en, this message translates to:
  /// **'Enable Reader Mode'**
  String get settings_enableReaderModeTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'reader, readability'**
  String get settings_enableReaderModeKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Adds an optional tool to the browser app bar that simplifies web pages by removing ads, sidebars, and other nonessential elements.'**
  String get settings_enableReaderModeSubtitle;

  /// Switch: offer reader mode on every page, even ones it may not work on.
  ///
  /// In en, this message translates to:
  /// **'Enforce Reader Mode'**
  String get settings_enforceReaderModeTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'reader'**
  String get settings_enforceReaderModeKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Ignore a site\'s readability score and always show Reader Mode, even on sites that may not support it.'**
  String get settings_enforceReaderModeSubtitle;

  /// Switch for AI features that run only on the device.
  ///
  /// In en, this message translates to:
  /// **'On-device AI'**
  String get settings_onDeviceAiTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'local ai, suggestions'**
  String get settings_onDeviceAiKeywords;

  /// Explanation under that switch. Containers are separate browsing identities.
  ///
  /// In en, this message translates to:
  /// **'On-device features such as suggesting containers for your open tabs and names for them'**
  String get settings_onDeviceAiSubtitle;

  /// Section heading on the web content screen for text display settings.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get settings_webContentSectionDisplayTitle;

  /// Section heading on the web content screen for PDF, reader mode and AI features.
  ///
  /// In en, this message translates to:
  /// **'Content Features'**
  String get settings_webContentSectionContentFeaturesTitle;

  /// Summary of the automatic font size setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Adjust font size based on system settings'**
  String get settings_indexAutomaticFontSizeSubtitle;

  /// Summary of the font inflation setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Enlarge text on pages without a mobile viewport'**
  String get settings_indexFontInflationSubtitle;

  /// Summary of the input auto zoom setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Automatically zoom when focusing text inputs'**
  String get settings_indexInputAutoZoomSubtitle;

  /// Summary of the PDF viewer setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Open PDF files directly in the browser'**
  String get settings_indexPdfViewerSubtitle;

  /// Summary of the reader mode setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Extract and simplify pages for readability'**
  String get settings_indexEnableReaderModeSubtitle;

  /// Summary of the enforce reader mode setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Always show Reader Mode capabilities'**
  String get settings_indexEnforceReaderModeSubtitle;

  /// Summary of the on-device AI setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Local AI features including topic and tab suggestions'**
  String get settings_indexOnDeviceAiSubtitle;

  /// Title of the screen for managing uBlock Origin filter lists. uBlock is a product name.
  ///
  /// In en, this message translates to:
  /// **'uBlock Filter Lists'**
  String get settings_ublockListsTitle;

  /// Placeholder of the search field on that screen.
  ///
  /// In en, this message translates to:
  /// **'Search lists, groups, and external URLs'**
  String get settings_ublockListsSearchHint;

  /// Section heading for whether WebLibre manages uBlock Origin's lists.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get settings_ublockSectionManagement;

  /// Section heading for one-tap actions (reset, apply hardenings).
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get settings_ublockSectionQuickActions;

  /// Section heading above the available filter lists.
  ///
  /// In en, this message translates to:
  /// **'Filter Lists'**
  String get settings_ublockSectionFilterLists;

  /// Section heading for filter lists added by address.
  ///
  /// In en, this message translates to:
  /// **'External Lists'**
  String get settings_ublockSectionExternalLists;

  /// Confirm button of the apply-hardenings dialog.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get settings_actionApply;

  /// Title of the confirmation dialog before resetting uBlock Origin's filter lists.
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults?'**
  String get settings_ublockResetDialogTitle;

  /// Body of that dialog.
  ///
  /// In en, this message translates to:
  /// **'This will restore uBlock Origin to its default filter list configuration and remove any external lists you added.'**
  String get settings_ublockResetDialogMessage;

  /// Title of the confirmation dialog before enabling WebLibre's recommended extra filter lists. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'Apply WebLibre Hardenings?'**
  String get settings_ublockApplyHardeningsDialogTitle;

  /// Body of that dialog.
  ///
  /// In en, this message translates to:
  /// **'This will enable a curated set of additional filter lists and add a legitimate URL shortener list as an external list.'**
  String get settings_ublockApplyHardeningsDialogMessage;

  /// Note above the filter lists: changes need an app restart.
  ///
  /// In en, this message translates to:
  /// **'Changes to uBlock Origin filter lists require an app restart to take effect. Due to caching, some changes may need a few minutes and an additional restart to fully apply.'**
  String get settings_ublockInfoBannerMessage;

  /// Error when the filter list catalog could not be loaded. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to load filter list assets: {error}'**
  String settings_ublockLoadFailed(String error);

  /// Row that resets uBlock Origin's filter lists (asks for confirmation).
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults'**
  String get settings_ublockQuickResetTitle;

  /// Explanation under that row.
  ///
  /// In en, this message translates to:
  /// **'Restore uBlock Origin\'s default filter list configuration.'**
  String get settings_ublockQuickResetSubtitle;

  /// Row that enables WebLibre's recommended extra filter lists (asks for confirmation).
  ///
  /// In en, this message translates to:
  /// **'Apply WebLibre Hardenings'**
  String get settings_ublockQuickApplyHardeningsTitle;

  /// Explanation under that row.
  ///
  /// In en, this message translates to:
  /// **'Enable a curated set of additional filter lists.'**
  String get settings_ublockQuickApplyHardeningsSubtitle;

  /// Switch: let WebLibre control which filter lists uBlock Origin uses.
  ///
  /// In en, this message translates to:
  /// **'Manage with WebLibre'**
  String get settings_ublockManageTitle;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'WebLibre controls uBlock Origin\'s enabled filter lists at the next browser start.'**
  String get settings_ublockManageSubtitle;

  /// Note shown while management is off. uBO is short for uBlock Origin; "My filters" is uBlock Origin's name for the user's own rules.
  ///
  /// In en, this message translates to:
  /// **'Enabling management starts from uBO\'s common baseline lists and preserves My filters.'**
  String get settings_ublockManageHint;

  /// Switch: turn on regional filter lists for the device's languages.
  ///
  /// In en, this message translates to:
  /// **'Auto-select languages'**
  String get settings_ublockAutoSelectTitle;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Enable regional filter lists matching your device languages.'**
  String get settings_ublockAutoSelectSubtitle;

  /// Tooltip of the globe icon on a filter list that was turned on because of the device language.
  ///
  /// In en, this message translates to:
  /// **'Auto-selected for your language'**
  String get settings_ublockAutoSelectedTooltip;

  /// Tooltip of the icon on a filter list that uBlock Origin enables by default.
  ///
  /// In en, this message translates to:
  /// **'Default on'**
  String get settings_ublockDefaultOnTooltip;

  /// Tooltip of the button that opens a filter list's support website.
  ///
  /// In en, this message translates to:
  /// **'Visit support page'**
  String get settings_ublockVisitSupportTooltip;

  /// Explanation above the external filter lists.
  ///
  /// In en, this message translates to:
  /// **'Raw URLs are forwarded to uBlock Origin as external lists. Descriptions are only shown here in WebLibre.'**
  String get settings_ublockExternalListsHint;

  /// Shown when no external filter list is added.
  ///
  /// In en, this message translates to:
  /// **'No external lists configured.'**
  String get settings_ublockNoExternalLists;

  /// Shown when no external list matches the search. query is the search text.
  ///
  /// In en, this message translates to:
  /// **'No external lists match \"{query}\".'**
  String settings_ublockNoExternalListsMatch(String query);

  /// Button that adds a filter list by address.
  ///
  /// In en, this message translates to:
  /// **'Add external list'**
  String get settings_ublockAddExternalListButton;

  /// Title of the dialog for editing an external filter list.
  ///
  /// In en, this message translates to:
  /// **'Edit external filter list'**
  String get settings_ublockEditListDialogTitle;

  /// Title of the dialog for adding an external filter list.
  ///
  /// In en, this message translates to:
  /// **'Add external filter list'**
  String get settings_ublockAddListDialogTitle;

  /// Label of the field for the filter list's web address.
  ///
  /// In en, this message translates to:
  /// **'List URL'**
  String get settings_ublockListUrlLabel;

  /// Validation error when the address is already in the list.
  ///
  /// In en, this message translates to:
  /// **'Already added'**
  String get settings_ublockListUrlAlreadyAdded;

  /// Label of the optional description field for an external list.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get settings_ublockDescriptionLabel;

  /// Example placeholder of the description field. The example may be translated; the author name is invented.
  ///
  /// In en, this message translates to:
  /// **'e.g. Annoyances — myAuthor'**
  String get settings_ublockDescriptionHint;

  /// Filter list group name used by uBlock Origin: lists enabled by default.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get settings_ublockGroupDefault;

  /// Filter list group name used by uBlock Origin: ad blocking.
  ///
  /// In en, this message translates to:
  /// **'Ads'**
  String get settings_ublockGroupAds;

  /// Filter list group name used by uBlock Origin: privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settings_ublockGroupPrivacy;

  /// Filter list group name used by uBlock Origin: malware domains.
  ///
  /// In en, this message translates to:
  /// **'Malware'**
  String get settings_ublockGroupMalware;

  /// Filter list group name used by uBlock Origin: annoyances such as cookie banners and pop-ups.
  ///
  /// In en, this message translates to:
  /// **'Annoyances'**
  String get settings_ublockGroupAnnoyances;

  /// Filter list group name used by uBlock Origin: lists covering several categories.
  ///
  /// In en, this message translates to:
  /// **'Multipurpose'**
  String get settings_ublockGroupMultipurpose;

  /// Filter list group name used by uBlock Origin: regional and language-specific lists.
  ///
  /// In en, this message translates to:
  /// **'Regions'**
  String get settings_ublockGroupRegions;

  /// Category on the main settings screen.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settings_categoryGeneralTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'theme, ui zoom, default browser'**
  String get settings_categoryGeneralKeywords;

  /// Summary under the "General" category.
  ///
  /// In en, this message translates to:
  /// **'Appearance, downloads'**
  String get settings_categoryGeneralSubtitle;

  /// Category on the main settings screen.
  ///
  /// In en, this message translates to:
  /// **'Browsing'**
  String get settings_categoryBrowsingTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'tabs, small web, url cleaner, unshortener'**
  String get settings_categoryBrowsingKeywords;

  /// Summary under the "Browsing" category.
  ///
  /// In en, this message translates to:
  /// **'Tabs, navigation, external links'**
  String get settings_categoryBrowsingSubtitle;

  /// Category on the main settings screen.
  ///
  /// In en, this message translates to:
  /// **'Home & New Tab'**
  String get settings_categoryHomeNewTabTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'home, new tab, start page, sections, shortcuts, top sites, quote, wallpaper, background'**
  String get settings_categoryHomeNewTabKeywords;

  /// Summary under the "Home & New Tab" category.
  ///
  /// In en, this message translates to:
  /// **'What the home and new tab pages show'**
  String get settings_categoryHomeNewTabSubtitle;

  /// Category on the main settings screen.
  ///
  /// In en, this message translates to:
  /// **'Gestures'**
  String get settings_categoryGesturesTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'gesture, swipe, stroke, tab bar, long press, pinch'**
  String get settings_categoryGesturesKeywords;

  /// Summary under the "Gestures" category.
  ///
  /// In en, this message translates to:
  /// **'Swipes on the tab bar and tabs, drawn gestures'**
  String get settings_categoryGesturesSubtitle;

  /// Category on the main settings screen.
  ///
  /// In en, this message translates to:
  /// **'Keyboard Shortcuts'**
  String get settings_categoryKeyboardShortcutsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'keyboard, shortcut, hotkey, key binding'**
  String get settings_categoryKeyboardShortcutsKeywords;

  /// Summary under the "Keyboard Shortcuts" category.
  ///
  /// In en, this message translates to:
  /// **'Hardware keyboard keys for browser actions'**
  String get settings_categoryKeyboardShortcutsSubtitle;

  /// Category on the main settings screen.
  ///
  /// In en, this message translates to:
  /// **'Toolbar & Layout'**
  String get settings_categoryToolbarLayoutTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'contextual toolbar, quick tab switcher'**
  String get settings_categoryToolbarLayoutKeywords;

  /// Summary under the "Toolbar & Layout" category.
  ///
  /// In en, this message translates to:
  /// **'Tab bar, toolbar, quick switcher, tab view'**
  String get settings_categoryToolbarLayoutSubtitle;

  /// Category on the main settings screen.
  ///
  /// In en, this message translates to:
  /// **'Web Content'**
  String get settings_categoryWebContentTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'reader mode, pdf, fonts'**
  String get settings_categoryWebContentKeywords;

  /// Summary under the "Web Content" category.
  ///
  /// In en, this message translates to:
  /// **'Page display, PDF, reader mode, AI'**
  String get settings_categoryWebContentSubtitle;

  /// Category on the main settings screen, for website push notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_categoryNotificationsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'push, unifiedpush, ntfy, distributor'**
  String get settings_categoryNotificationsKeywords;

  /// Summary under the "Notifications" category. A distributor is the app that delivers push messages.
  ///
  /// In en, this message translates to:
  /// **'Web push delivery, distributor, site subscriptions'**
  String get settings_categoryNotificationsSubtitle;

  /// Category on the main settings screen.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get settings_categorySearchTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'bangs, suggestions, local search index'**
  String get settings_categorySearchKeywords;

  /// Summary under the "Search" category.
  ///
  /// In en, this message translates to:
  /// **'Providers, bangs, search history'**
  String get settings_categorySearchSubtitle;

  /// Category on the main settings screen.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get settings_categoryPrivacySecurityTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'fingerprinting, https, doh, safe browsing, network protection'**
  String get settings_categoryPrivacySecurityKeywords;

  /// Summary under the "Privacy & Security" category.
  ///
  /// In en, this message translates to:
  /// **'Tracking protection, data clearing'**
  String get settings_categoryPrivacySecuritySubtitle;

  /// Category on the main settings screen.
  ///
  /// In en, this message translates to:
  /// **'Proxy'**
  String get settings_categoryProxyTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'proxy, sing-box, socks, vpn, wireguard, routing, tor, container'**
  String get settings_categoryProxyKeywords;

  /// Summary under the "Proxy" category.
  ///
  /// In en, this message translates to:
  /// **'Connections and routing'**
  String get settings_categoryProxySubtitle;

  /// Category on the main settings screen.
  ///
  /// In en, this message translates to:
  /// **'Extensions'**
  String get settings_categoryExtensionsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'addons, unsigned extensions'**
  String get settings_categoryExtensionsKeywords;

  /// Summary under the "Extensions" category.
  ///
  /// In en, this message translates to:
  /// **'Install and manage extension sources'**
  String get settings_categoryExtensionsSubtitle;

  /// Category on the main settings screen for the app's own account. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'WebLibre Account'**
  String get settings_categoryAccountTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'account, subscription'**
  String get settings_categoryAccountKeywords;

  /// Summary under the account category.
  ///
  /// In en, this message translates to:
  /// **'Sign in, sync settings'**
  String get settings_categoryAccountSubtitle;

  /// Category on the main settings screen. "Firefox Sync" is Mozilla's product name; usually left untranslated.
  ///
  /// In en, this message translates to:
  /// **'Firefox Sync'**
  String get settings_categorySyncTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'pair, device name, engines'**
  String get settings_categorySyncKeywords;

  /// Summary under the Firefox Sync category. "Engine selection" means choosing which data types are synced.
  ///
  /// In en, this message translates to:
  /// **'Account, sync now, engine selection'**
  String get settings_categorySyncSubtitle;

  /// Category on the main settings screen.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get settings_categoryAdvancedTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'experimental, error logs, javascript'**
  String get settings_categoryAdvancedKeywords;

  /// Summary under the "Advanced" category.
  ///
  /// In en, this message translates to:
  /// **'JavaScript, user agent, debugging'**
  String get settings_categoryAdvancedSubtitle;

  /// Heading of the first group of categories on the main settings screen.
  ///
  /// In en, this message translates to:
  /// **'Browser'**
  String get settings_categoryGroupBrowserTitle;

  /// Heading of the second group of categories on the main settings screen.
  ///
  /// In en, this message translates to:
  /// **'Services & Advanced'**
  String get settings_categoryGroupServicesAdvancedTitle;

  /// Section heading on the privacy & security screen.
  ///
  /// In en, this message translates to:
  /// **'Tracking Protection'**
  String get settings_privacySectionTrackingProtectionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'privacy'**
  String get settings_privacySectionTrackingProtectionKeywords;

  /// Summary of the tracking protection level setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Choose how aggressively trackers are blocked'**
  String get settings_indexEnhancedTrackingProtectionSubtitle;

  /// Summary of the content blocking database setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Use GeckoView blocker lists for ETP categories'**
  String get settings_indexContentBlockingDatabaseSubtitle;

  /// Summary of the bounce tracking protection setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Remove tracking state left by redirect-based trackers'**
  String get settings_indexBounceTrackingProtectionSubtitle;

  /// Summary of the query parameter stripping setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Remove tracking parameters from URLs'**
  String get settings_indexQueryParameterStrippingSubtitle;

  /// Section heading on the privacy & security screen.
  ///
  /// In en, this message translates to:
  /// **'Fingerprinting'**
  String get settings_privacySectionFingerprintingTitle;

  /// Summary of the browser languages setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Choose which languages websites can see'**
  String get settings_indexBrowserLanguagesSubtitle;

  /// Section heading on the privacy & security screen.
  ///
  /// In en, this message translates to:
  /// **'Connection Security'**
  String get settings_privacySectionConnectionSecurityTitle;

  /// Summary of the HTTPS-only setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Prefer HTTPS and block insecure connections'**
  String get settings_indexHttpsOnlyModeSubtitle;

  /// Title of the DNS over HTTPS entry on the privacy & security screen. Technical term.
  ///
  /// In en, this message translates to:
  /// **'DNS over HTTPS'**
  String get settings_indexDnsOverHttpsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'doh'**
  String get settings_indexDnsOverHttpsKeywords;

  /// Summary of that entry. DNS is a technical abbreviation.
  ///
  /// In en, this message translates to:
  /// **'Encrypt DNS lookups'**
  String get settings_indexDnsOverHttpsSubtitle;

  /// Section heading on the privacy & security screen for local network protection.
  ///
  /// In en, this message translates to:
  /// **'Network Protection'**
  String get settings_privacySectionNetworkProtectionTitle;

  /// Summary of the block local network requests setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Block requests to local network devices and services'**
  String get settings_indexLnaBlockingSubtitle;

  /// Summary of the block local network trackers setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Block tracker-like local network requests'**
  String get settings_indexLnaBlockTrackersSubtitle;

  /// Section heading on the privacy & security screen.
  ///
  /// In en, this message translates to:
  /// **'Privacy Signals & Modes'**
  String get settings_privacySectionSignalsModesTitle;

  /// Summary of the screenshot protection setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Prevent app content from appearing in screenshots'**
  String get settings_indexScreenshotProtectionSubtitle;

  /// Summary of the private tab screenshots setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Let the system capture private tabs'**
  String get settings_indexAllowPrivateTabScreenshotsSubtitle;

  /// Summary of the Global Privacy Control setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Send a privacy preference signal to websites'**
  String get settings_indexGlobalPrivacyControlSubtitle;

  /// Section heading on the privacy & security screen.
  ///
  /// In en, this message translates to:
  /// **'App-Opening Protection'**
  String get settings_privacySectionAppOpeningProtectionTitle;

  /// Summary of the app-opening protection setting, shown as a settings search result. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'Control which apps may launch WebLibre directly'**
  String get settings_indexAppOpeningProtectionSubtitle;

  /// Section heading on the privacy & security screen.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get settings_privacySectionDataManagementTitle;

  /// Summary of the delete browsing data entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Clear history, cookies, and other browsing data'**
  String get settings_indexDeleteBrowsingDataSubtitle;

  /// Summary of the auto-clear history setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Automatically clear history after a chosen duration'**
  String get settings_indexAutoClearHistorySubtitle;

  /// Summary of the auto-clear unassigned tabs setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Automatically close tabs not assigned to a container'**
  String get settings_indexAutoClearUnassignedTabsSubtitle;

  /// Section heading on the privacy & security screen. "Google Safe Browsing" is a service name.
  ///
  /// In en, this message translates to:
  /// **'Google Safe Browsing'**
  String get settings_privacySectionSafeBrowsingTitle;

  /// Summary of the malware protection setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Warn about malware and harmful downloads'**
  String get settings_indexSafeBrowsingMalwareSubtitle;

  /// Summary of the phishing protection setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Warn about deceptive websites and login pages'**
  String get settings_indexSafeBrowsingPhishingSubtitle;

  /// Section heading on the privacy & security screen.
  ///
  /// In en, this message translates to:
  /// **'Advanced Security'**
  String get settings_privacySectionAdvancedSecurityTitle;

  /// Summary of the web engine hardening entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Harden browser engine behavior and defaults'**
  String get settings_indexWebEngineHardeningSubtitle;

  /// Summary of the site isolation setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Use stronger site isolation between origins'**
  String get settings_indexFissionEnabledSubtitle;

  /// Summary of the extensions web API setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Allow extensions to expose web APIs to pages'**
  String get settings_indexExtensionsWebAPIEnabledSubtitle;

  /// Section heading on the proxy settings screen.
  ///
  /// In en, this message translates to:
  /// **'Proxy'**
  String get settings_proxySectionTitle;

  /// Summary of the proxy logs entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Read the proxy log and set how much it records'**
  String get settings_indexProxyLogsSubtitle;

  /// Button in the custom DNS resolver dialog: save the new resolver and switch to it.
  ///
  /// In en, this message translates to:
  /// **'Save and use'**
  String get settings_saveAndUse;

  /// Confirm button of the settings import dialog: replace the current settings in the chosen sections.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get settings_replace;

  /// Button in the restart dialog: restart later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get settings_later;

  /// Button in the restart dialog: restart the app now.
  ///
  /// In en, this message translates to:
  /// **'Restart Now'**
  String get settings_restartNow;

  /// Button that downloads the latest version of a bang list.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get settings_sync;

  /// Button shown when no default search engine is chosen; opens the list of engines.
  ///
  /// In en, this message translates to:
  /// **'Choose a search provider'**
  String get settings_chooseSearchProvider;

  /// Label in front of the number of bangs in a list.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get settings_entriesLabel;

  /// Label in front of when a bang list was last downloaded.
  ///
  /// In en, this message translates to:
  /// **'Last Sync'**
  String get settings_lastSyncLabel;

  /// Abbreviation for "not available", shown when a value is unknown.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get settings_notAvailable;

  /// Heading of the DNS over HTTPS protection level choice.
  ///
  /// In en, this message translates to:
  /// **'Protection Level'**
  String get settings_protectionLevelTitle;

  /// Explanation under that heading. DNS and HTTPS are technical abbreviations.
  ///
  /// In en, this message translates to:
  /// **'Domain Name System (DNS) over HTTPS sends domain-name requests through an encrypted connection, protecting them and making it harder for others to see which websites you’re about to visit.'**
  String get settings_protectionLevelDescription;

  /// DNS over HTTPS level option: the browser engine's default behavior.
  ///
  /// In en, this message translates to:
  /// **'Default Protection'**
  String get settings_defaultProtectionTitle;

  /// Explanation under the "Default Protection" DNS over HTTPS option. DoH is short for DNS over HTTPS.
  ///
  /// In en, this message translates to:
  /// **'DoH used only when default DNS fails'**
  String get settings_defaultProtectionSubtitle;

  /// DNS over HTTPS level option: use encrypted DNS when possible.
  ///
  /// In en, this message translates to:
  /// **'Increased Protection'**
  String get settings_increasedProtectionTitle;

  /// Explanation under "Increased Protection". DoH is short for DNS over HTTPS.
  ///
  /// In en, this message translates to:
  /// **'DoH preferred, default DNS as fallback'**
  String get settings_increasedProtectionSubtitle;

  /// DNS over HTTPS level option: always use encrypted DNS.
  ///
  /// In en, this message translates to:
  /// **'Max Protection'**
  String get settings_maxProtectionTitle;

  /// Explanation under "Max Protection". DoH is short for DNS over HTTPS.
  ///
  /// In en, this message translates to:
  /// **'DoH only, no fallback'**
  String get settings_maxProtectionSubtitle;

  /// DNS over HTTPS level option: off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settings_protectionOffTitle;

  /// Explanation under "Off": the device's normal DNS server is used.
  ///
  /// In en, this message translates to:
  /// **'Use your default DNS resolver'**
  String get settings_protectionOffSubtitle;

  /// Heading above the list of DNS over HTTPS servers to choose from. DoH is short for DNS over HTTPS.
  ///
  /// In en, this message translates to:
  /// **'DoH Provider'**
  String get settings_dohProviderTitle;

  /// Heading above the DNS over HTTPS servers the user added.
  ///
  /// In en, this message translates to:
  /// **'Your resolvers'**
  String get settings_yourResolvers;

  /// Button that adds a DNS over HTTPS server by address; also the title of the dialog it opens.
  ///
  /// In en, this message translates to:
  /// **'Add custom resolver'**
  String get settings_addCustomResolver;

  /// Title of the dialog for editing a user-added DNS over HTTPS server.
  ///
  /// In en, this message translates to:
  /// **'Edit custom resolver'**
  String get settings_editCustomResolverTitle;

  /// Label of the field for the DNS over HTTPS server address.
  ///
  /// In en, this message translates to:
  /// **'Resolver URL'**
  String get settings_resolverUrlLabel;

  /// Validation error when the entered server is already in the built-in list.
  ///
  /// In en, this message translates to:
  /// **'Already available as a built-in provider'**
  String get settings_alreadyBuiltInProvider;

  /// Validation error when the entered server was already added by the user.
  ///
  /// In en, this message translates to:
  /// **'Already added'**
  String get settings_alreadyAdded;

  /// Label of the optional name field for a DNS over HTTPS server.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get settings_resolverNameLabel;

  /// Example placeholder of that name field. "dnsforge" is a service name; keep it.
  ///
  /// In en, this message translates to:
  /// **'e.g. dnsforge (adblock)'**
  String get settings_resolverNameHint;

  /// Default placeholder of the search field on settings screens.
  ///
  /// In en, this message translates to:
  /// **'Search settings'**
  String get settings_searchHint;

  /// Shown on a settings screen that has no entries.
  ///
  /// In en, this message translates to:
  /// **'No settings available.'**
  String get settings_noSettingsAvailable;

  /// Shown when no setting matches the search. query is the search text.
  ///
  /// In en, this message translates to:
  /// **'No settings match \"{query}\".'**
  String settings_noSettingsMatch(String query);

  /// Shown in an editable list of text entries while it is empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing added yet.'**
  String get settings_stringListEditorEmpty;

  /// Row that opens the editor for the browser's three-dot menu.
  ///
  /// In en, this message translates to:
  /// **'Customize Menu'**
  String get settings_customizeMenu;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'sections, rows, reorder'**
  String get settings_customizeMenuKeywords;

  /// Explanation under that row.
  ///
  /// In en, this message translates to:
  /// **'Choose and order the sections and rows of the three-dot menu'**
  String get settings_customizeMenuSubtitle;

  /// Heading of the choice where the tab bar is placed.
  ///
  /// In en, this message translates to:
  /// **'Tab Bar Position'**
  String get settings_tabBarPositionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'top, bottom'**
  String get settings_tabBarPositionKeywords;

  /// An automatic choice followed by what it currently resolves to. text is the automatic option's label or description (e.g. "Follow the tab bar"); value is the name of the option it currently uses, exactly as shown in the option list (e.g. "In the tab bar").
  ///
  /// In en, this message translates to:
  /// **'{text} (currently: {value})'**
  String settings_currentlyResolvesTo(String text, String value);

  /// Tab bar position option: chosen automatically by screen size. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get settings_tabBarPositionAutoLabel;

  /// Tab bar position option: top of the screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get settings_tabBarPositionTopLabel;

  /// Tab bar position option: bottom of the screen. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Bottom'**
  String get settings_tabBarPositionBottomLabel;

  /// Tab bar position option: left edge (side rail). Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get settings_tabBarPositionLeftLabel;

  /// Tab bar position option: right edge (side rail). Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get settings_tabBarPositionRightLabel;

  /// Explanation under "Automatic".
  ///
  /// In en, this message translates to:
  /// **'A side rail on large screens, a bottom bar on phones'**
  String get settings_tabBarPositionAutoDescription;

  /// Explanation under "Top".
  ///
  /// In en, this message translates to:
  /// **'Persistent tab bar without auto-hide'**
  String get settings_tabBarPositionTopDescription;

  /// Explanation under "Bottom".
  ///
  /// In en, this message translates to:
  /// **'Tab bar with auto-hide support'**
  String get settings_tabBarPositionBottomDescription;

  /// Explanation under "Left".
  ///
  /// In en, this message translates to:
  /// **'Vertical side rail, swipe to hide'**
  String get settings_tabBarPositionLeftDescription;

  /// Explanation under "Right".
  ///
  /// In en, this message translates to:
  /// **'Vertical side rail, swipe to hide'**
  String get settings_tabBarPositionRightDescription;

  /// Heading of the choice of tab bar layout.
  ///
  /// In en, this message translates to:
  /// **'Tab Bar Style'**
  String get settings_tabBarStyleTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'layout, compact'**
  String get settings_tabBarStyleKeywords;

  /// Tab bar style option: shows the page title. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'With Title'**
  String get settings_withTitleOption;

  /// Explanation under "With Title". A breadcrumb is the shortened path of the address.
  ///
  /// In en, this message translates to:
  /// **'Shows page title and URL breadcrumb'**
  String get settings_withTitleDescription;

  /// Tab bar style option: compact, address only. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get settings_compactOption;

  /// Explanation under "Compact". A pill is a rounded box.
  ///
  /// In en, this message translates to:
  /// **'Centered URL pill without page title'**
  String get settings_compactDescription;

  /// Switch that shows an extra toolbar at the bottom with navigation and action buttons.
  ///
  /// In en, this message translates to:
  /// **'Show Contextual Toolbar'**
  String get settings_showContextualToolbarTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'bottom toolbar'**
  String get settings_showContextualToolbarKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Show additional bottom toolbar for navigation and actions'**
  String get settings_showContextualToolbarSubtitle;

  /// Row that opens the editor for the buttons of the contextual toolbar.
  ///
  /// In en, this message translates to:
  /// **'Customize Toolbar Buttons'**
  String get settings_customizeToolbarButtons;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'buttons'**
  String get settings_customizeToolbarButtonsKeywords;

  /// Row that opens the editor for the buttons at the end of the quick tab switcher bar.
  ///
  /// In en, this message translates to:
  /// **'Customize Switcher Buttons'**
  String get settings_customizeSwitcherButtons;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'buttons, new tab, actions, trailing'**
  String get settings_customizeSwitcherButtonsKeywords;

  /// Explanation under that row.
  ///
  /// In en, this message translates to:
  /// **'Action buttons pinned at the end of the switcher bar (independent of the contextual toolbar)'**
  String get settings_customizeSwitcherButtonsSubtitle;

  /// Heading of the choice how the quick tab switcher bar (a row of tab chips) arranges tabs.
  ///
  /// In en, this message translates to:
  /// **'Tab Stacking'**
  String get settings_tabStackingTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'recent tabs, recently used, container tabs, accordion, two level, rows, stacking, disabled'**
  String get settings_tabStackingKeywords;

  /// Line under that heading.
  ///
  /// In en, this message translates to:
  /// **'How the quick tab switcher bar arranges its tabs'**
  String get settings_tabStackingSubtitle;

  /// Tab stacking option: most recently used tabs. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Recently Used Tabs'**
  String get settings_recentlyUsedTabsOption;

  /// Explanation under "Recently Used Tabs". Containers are separate browsing identities.
  ///
  /// In en, this message translates to:
  /// **'Recently used tabs across all containers'**
  String get settings_recentlyUsedTabsDescription;

  /// Tab stacking option: tabs of one container. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Container Tabs'**
  String get settings_containerTabsOption;

  /// Explanation under "Container Tabs".
  ///
  /// In en, this message translates to:
  /// **'Ordered tabs of the selected container'**
  String get settings_containerTabsDescription;

  /// Tab stacking option: containers that expand to show their tabs, like an accordion. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Accordion'**
  String get settings_accordionOption;

  /// Explanation under "Accordion". Chips are small rounded buttons.
  ///
  /// In en, this message translates to:
  /// **'All containers as chips, with the selected container\'s tabs expanded inline'**
  String get settings_accordionDescription;

  /// Tab stacking option: two rows of tabs. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Two Rows'**
  String get settings_twoRowsOption;

  /// Explanation under "Two Rows".
  ///
  /// In en, this message translates to:
  /// **'Tabs of the selected container on top, recently used tabs below'**
  String get settings_twoRowsDescription;

  /// Tab stacking option: no quick tab switcher bar. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get settings_disabledOption;

  /// Explanation under "Disabled".
  ///
  /// In en, this message translates to:
  /// **'Hide the quick tab switcher bar'**
  String get settings_disabledDescription;

  /// Heading of the choice which tab chips in the switcher bar show a close (X) button.
  ///
  /// In en, this message translates to:
  /// **'Close Buttons on Tab Chips'**
  String get settings_closeButtonsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'close, x button, active tab'**
  String get settings_closeButtonsKeywords;

  /// Line under that heading; also shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Which switcher chips show a close button'**
  String get settings_closeButtonsSubtitle;

  /// Close button option: only on the open tab. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Active Tab Only'**
  String get settings_activeTabOnlyOption;

  /// Explanation under "Active Tab Only".
  ///
  /// In en, this message translates to:
  /// **'Only the chip of the tab currently open'**
  String get settings_activeTabOnlyDescription;

  /// Close button option: on every tab chip. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'All Tabs'**
  String get settings_allTabsOption;

  /// Explanation under "All Tabs".
  ///
  /// In en, this message translates to:
  /// **'Every chip on the bar'**
  String get settings_allTabsDescription;

  /// Close button option: no close buttons. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get settings_neverOption;

  /// Explanation under "Never".
  ///
  /// In en, this message translates to:
  /// **'No close buttons; close tabs from the long press menu or by swiping the bar'**
  String get settings_neverCloseDescription;

  /// Slider for the maximum width of tab titles on the switcher bar's chips.
  ///
  /// In en, this message translates to:
  /// **'Title Width in Quick Tab Switcher'**
  String get settings_titleWidthTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'width, title, chip, length'**
  String get settings_titleWidthKeywords;

  /// Line under that slider; also shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Maximum width of tab titles on switcher chips'**
  String get settings_titleWidthSubtitle;

  /// Switch: show history suggestions in the quick tab switcher bar when it has no tabs to show.
  ///
  /// In en, this message translates to:
  /// **'History Fallback in Quick Tab Switcher'**
  String get settings_historyFallbackTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'suggestions'**
  String get settings_historyFallbackKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Use browsing history suggestions when no tab chips are available'**
  String get settings_historyFallbackSubtitle;

  /// Switch: show tab titles, not only icons, in the quick tab switcher bar.
  ///
  /// In en, this message translates to:
  /// **'Show Titles in Quick Tab Switcher'**
  String get settings_showTitlesTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'page titles'**
  String get settings_showTitlesKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Display tab titles alongside icons in the quick tab switcher bar'**
  String get settings_showTitlesSubtitle;

  /// Slider for how many nesting arrows (chevrons) switcher chips show for child tabs.
  ///
  /// In en, this message translates to:
  /// **'Hierarchy Depth in Quick Tab Switcher'**
  String get settings_hierarchyDepthTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'hierarchy, nesting, depth, tree, chevrons'**
  String get settings_hierarchyDepthKeywords;

  /// Explanation under that slider. "0" is the literal slider value.
  ///
  /// In en, this message translates to:
  /// **'How many nesting chevrons to show on switcher chips before collapsing into a count badge (0 hides the indicator)'**
  String get settings_hierarchyDepthSubtitle;

  /// Value label of that slider. glyphs is the number of nesting levels shown; 0 means the indicator is off.
  ///
  /// In en, this message translates to:
  /// **'{glyphs, plural, =0{Off} =1{1 level} other{{glyphs} levels}}'**
  String settings_hierarchyGlyphsLabel(int glyphs);

  /// Switch: hide the tab bar while scrolling a page.
  ///
  /// In en, this message translates to:
  /// **'Auto Hide Tab Bar'**
  String get settings_autoHideTabBarTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'scroll'**
  String get settings_autoHideTabBarKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Hide tab bar when scrolling'**
  String get settings_autoHideTabBarSubtitle;

  /// Switch: hide the side tab bar (left or right rail) until the mouse reaches the screen edge.
  ///
  /// In en, this message translates to:
  /// **'Auto Hide Side Panel'**
  String get settings_autoHideSidePanelTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'mouse, cursor, hover, rail, sidebar'**
  String get settings_autoHideSidePanelKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Keep the left or right tab bar out of the way and slide it in when the mouse reaches that edge. This works only while a mouse or trackpad is in use; touching the screen puts the panel back beside the page.'**
  String get settings_autoHideSidePanelSubtitle;

  /// Switch: open the tab overview as a panel from the bottom instead of full screen.
  ///
  /// In en, this message translates to:
  /// **'Bottom Sheet Tab View'**
  String get settings_bottomSheetTabViewTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'sheet'**
  String get settings_bottomSheetTabViewKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Display tabs in a bottom sheet instead of fullscreen'**
  String get settings_bottomSheetTabViewSubtitle;

  /// Switch: long pressing the address bar copies the page address.
  ///
  /// In en, this message translates to:
  /// **'Long Press URL to Copy'**
  String get settings_longPressUrlCopyTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'copy url'**
  String get settings_longPressUrlCopyKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Copy the page URL to clipboard when long pressing the address bar'**
  String get settings_longPressUrlCopySubtitle;

  /// Switch: the tab overview's list layout shows site icons instead of page thumbnails.
  ///
  /// In en, this message translates to:
  /// **'Show Favicons in List View'**
  String get settings_showFaviconsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'icons'**
  String get settings_showFaviconsKeywords;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Display website icons instead of page thumbnails in tab list view'**
  String get settings_showFaviconsSubtitle;

  /// Placeholder text in the page area of the toolbar preview.
  ///
  /// In en, this message translates to:
  /// **'Page Content'**
  String get settings_previewPageContent;

  /// Title of the sample page shown in the toolbar preview. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'WebLibre Preview'**
  String get settings_previewPageTitle;

  /// Title of a sample regular tab in the toolbar preview.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get settings_previewTabNews;

  /// Title of a sample private tab in the toolbar preview.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get settings_previewTabPrivate;

  /// Title of a sample isolated tab in the toolbar preview.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get settings_previewTabBank;

  /// Title of a sample history suggestion in the toolbar preview.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get settings_previewTabSearch;

  /// Heading of the toolbar preview on the toolbar & layout screen.
  ///
  /// In en, this message translates to:
  /// **'Live Preview'**
  String get settings_livePreviewTitle;

  /// Line under that heading.
  ///
  /// In en, this message translates to:
  /// **'Reflects your current toolbar and layout settings'**
  String get settings_livePreviewSubtitle;

  /// Title of the confirmation dialog before removing all tracking protection exceptions.
  ///
  /// In en, this message translates to:
  /// **'Delete All Exceptions?'**
  String get settings_deleteAllExceptionsTitle;

  /// Body of that dialog.
  ///
  /// In en, this message translates to:
  /// **'This will re-enable tracking protection for all exception sites.'**
  String get settings_deleteAllExceptionsContent;

  /// Confirmation after copying a proxy log entry.
  ///
  /// In en, this message translates to:
  /// **'Entry copied'**
  String get settings_entryCopied;

  /// Bold label above the message of a log entry in the log details dialog.
  ///
  /// In en, this message translates to:
  /// **'Message:'**
  String get settings_messageLabel;

  /// Bold label above the error of a log entry in the log details dialog.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get settings_errorLabel;

  /// Bold label above the stack trace (technical call list) of a log entry.
  ///
  /// In en, this message translates to:
  /// **'Stack Trace:'**
  String get settings_stackTraceLabel;

  /// Title of the dialog for choosing which sections of an export to import.
  ///
  /// In en, this message translates to:
  /// **'Import settings'**
  String get settings_importSettingsTitle;

  /// Explanation at the top of that dialog.
  ///
  /// In en, this message translates to:
  /// **'The sections you pick replace what this profile has now. Anything you leave unchecked stays as it is.'**
  String get settings_importSettingsDescription;

  /// Note in the import dialog when the export contains sections from a newer app version. count is the number of those sections; sections is their keys as written in the file, quoted and comma-separated (they have no translatable name). WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 section in this file ({sections}) can\'t be read by this version of WebLibre and will be skipped.} other{{count} sections in this file ({sections}) can\'t be read by this version of WebLibre and will be skipped.}}'**
  String settings_unreadableSections(int count, String sections);

  /// Label in front of when the export file was created.
  ///
  /// In en, this message translates to:
  /// **'Exported'**
  String get settings_exportedLabel;

  /// Label in front of the app version that created the export.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get settings_appVersionLabel;

  /// Note in the import dialog while the settings section is selected.
  ///
  /// In en, this message translates to:
  /// **'Exports do not include saved credentials or the wallpaper image. This device keeps its own.'**
  String get settings_credentialsNotCarried;

  /// Note in the import dialog while the engine preferences section is selected.
  ///
  /// In en, this message translates to:
  /// **'Some engine preferences only take effect after restarting the browser.'**
  String get settings_geckoPrefsRestartNote;

  /// Title of the dialog shown after changing the user agent (the browser identification sent to websites).
  ///
  /// In en, this message translates to:
  /// **'User Agent Changed'**
  String get settings_userAgentChangedTitle;

  /// Body of that dialog: the app must restart for the change to apply.
  ///
  /// In en, this message translates to:
  /// **'The browser needs to restart for the new user agent to take effect.'**
  String get settings_userAgentChangedContent;

  /// Section heading on the toolbar & layout screen.
  ///
  /// In en, this message translates to:
  /// **'Tab Bar'**
  String get settings_tabBarSectionTitle;

  /// Section heading on the toolbar & layout screen for the extra bottom toolbar.
  ///
  /// In en, this message translates to:
  /// **'Contextual Toolbar'**
  String get settings_contextualToolbarSectionTitle;

  /// Section heading on the toolbar & layout screen for the bar of tab chips.
  ///
  /// In en, this message translates to:
  /// **'Quick Tab Switcher'**
  String get settings_quickTabSwitcherSectionTitle;

  /// Section heading on the toolbar & layout screen for the tab overview.
  ///
  /// In en, this message translates to:
  /// **'Tab View'**
  String get settings_tabViewSectionTitle;

  /// Section heading on the toolbar & layout screen for the three-dot menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get settings_menuSectionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'three dot, overflow'**
  String get settings_menuSectionKeywords;

  /// Summary of the tab bar position setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Choose whether the tab bar sits at the top, at the bottom or at the side'**
  String get settings_indexTabBarPositionSubtitle;

  /// Summary of the tab bar style setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Choose between title and compact layouts'**
  String get settings_indexTabBarStyleSubtitle;

  /// Summary of the auto-hide tab bar setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Hide the tab bar when scrolling'**
  String get settings_indexAutoHideTabBarSubtitle;

  /// Summary of the auto-hide side panel setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Reveal the side panel when the mouse reaches its edge'**
  String get settings_indexAutoHideSidePanelSubtitle;

  /// Summary of the long-press-to-copy setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Copy the current URL from the tab bar'**
  String get settings_indexLongPressUrlCopySubtitle;

  /// Summary of the contextual toolbar setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Show an additional toolbar for navigation and actions'**
  String get settings_indexShowContextualToolbarSubtitle;

  /// Summary of the toolbar buttons entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Choose which actions appear in the contextual toolbar'**
  String get settings_indexCustomizeToolbarButtonsSubtitle;

  /// Summary of the tab stacking setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Choose how the quick tab switcher bar arranges tabs'**
  String get settings_indexTabStackingSubtitle;

  /// Summary of the switcher buttons entry, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Choose which action buttons appear at the end of the bar'**
  String get settings_indexCustomizeSwitcherButtonsSubtitle;

  /// Summary of the history fallback setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Use history suggestions when there are no matching tabs'**
  String get settings_indexHistoryFallbackSubtitle;

  /// Summary of the show titles setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Display page titles in the switcher list'**
  String get settings_indexShowTitlesSubtitle;

  /// Summary of the hierarchy depth setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'How many nesting chevrons to show on switcher chips'**
  String get settings_indexHierarchyDepthSubtitle;

  /// Summary of the bottom sheet tab view setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Open the tab switcher as a bottom sheet'**
  String get settings_indexBottomSheetTabViewSubtitle;

  /// Summary of the favicons setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Display site icons in the tab list'**
  String get settings_indexShowFaviconsSubtitle;

  /// Title of the Small Web panel. The "small web" is personal, non-commercial websites and blogs; this feature opens random pages from them. Keep the term consistent throughout.
  ///
  /// In en, this message translates to:
  /// **'Small Web'**
  String get smallWeb_sheetTitle;

  /// Label above the category chips that narrow which kind of small web pages are discovered.
  ///
  /// In en, this message translates to:
  /// **'Refine Category'**
  String get smallWeb_refineCategoryTitle;

  /// Category chip that removes the category filter (all categories).
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get smallWeb_allCategoriesChip;

  /// Progress text while looking for a small web page. mode is the name of the chosen discovery mode, e.g. "Videos" or "Comics".
  ///
  /// In en, this message translates to:
  /// **'Searching {mode}'**
  String smallWeb_searchingModeTitle(String mode);

  /// Main button of the Small Web panel: open a new randomly discovered page.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get smallWeb_discoverButtonLabel;

  /// Button that opens the list of Wander consoles. A console is a small website that lists other personal sites, forming a web ring.
  ///
  /// In en, this message translates to:
  /// **'Browse Consoles'**
  String get smallWeb_browseConsolesButtonLabel;

  /// Error heading when the Small Web panel could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Small Web unavailable'**
  String get smallWeb_unavailableTitle;

  /// Shown on the console card when no Wander console has been picked yet.
  ///
  /// In en, this message translates to:
  /// **'No console selected'**
  String get smallWeb_noConsoleSelectedMessage;

  /// Statistics of the current Wander console. linkedConsoles is how many other consoles it links to; pages is how many pages it lists. Keep the "·" separator.
  ///
  /// In en, this message translates to:
  /// **'{linkedConsoles, plural, =1{1 linked console} other{{linkedConsoles} linked consoles}} · {pages, plural, =1{1 page} other{{pages} pages}}'**
  String smallWeb_consoleStats(int linkedConsoles, int pages);

  /// Discovery mode of Kagi Small Web: recent posts from personal websites and blogs.
  ///
  /// In en, this message translates to:
  /// **'Web'**
  String get smallWeb_modeWebLabel;

  /// Discovery mode of Kagi Small Web: posts readers marked as appreciated (liked).
  ///
  /// In en, this message translates to:
  /// **'Appreciated'**
  String get smallWeb_modeAppreciatedLabel;

  /// Discovery mode of Kagi Small Web: videos from independent creators.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get smallWeb_modeVideosLabel;

  /// Discovery mode of Kagi Small Web: programming-related posts.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get smallWeb_modeCodeLabel;

  /// Discovery mode of Kagi Small Web: web comics.
  ///
  /// In en, this message translates to:
  /// **'Comics'**
  String get smallWeb_modeComicsLabel;

  /// Explanation shown when the "Appreciated" discovery mode is selected.
  ///
  /// In en, this message translates to:
  /// **'Browse highly curated, user-appreciated links from the small web community.'**
  String get smallWeb_modeDescriptionAppreciated;

  /// Explanation shown when the "Videos" discovery mode is selected.
  ///
  /// In en, this message translates to:
  /// **'Discover video content from independent creators across the small web.'**
  String get smallWeb_modeDescriptionVideos;

  /// Explanation shown when the "Code" discovery mode is selected.
  ///
  /// In en, this message translates to:
  /// **'Find code snippets, repositories, and technical articles from personal sites.'**
  String get smallWeb_modeDescriptionCode;

  /// Explanation shown when the "Comics" discovery mode is selected.
  ///
  /// In en, this message translates to:
  /// **'Explore indie comics and web graphics by independent illustrators.'**
  String get smallWeb_modeDescriptionComics;

  /// Name of a small web discovery source run by the Kagi search engine. Brand name; do not translate.
  ///
  /// In en, this message translates to:
  /// **'Kagi'**
  String get smallWeb_sourceKagiLabel;

  /// Short description of the Kagi small web source. Kagi Search is a brand name.
  ///
  /// In en, this message translates to:
  /// **'Small Web by Kagi Search'**
  String get smallWeb_sourceKagiDescription;

  /// Name of a small web discovery source called Wander. Project name; do not translate.
  ///
  /// In en, this message translates to:
  /// **'Wander'**
  String get smallWeb_sourceWanderLabel;

  /// Short description of the Wander source: a web ring (a chain of linked personal sites) built from "consoles".
  ///
  /// In en, this message translates to:
  /// **'Console-based web ring'**
  String get smallWeb_sourceWanderDescription;

  /// Message when discovery found no page the user has not already seen.
  ///
  /// In en, this message translates to:
  /// **'No new items found. Try a different mode or category.'**
  String get smallWeb_noNewItemsFoundMessage;

  /// Error message when finding a new small web page failed.
  ///
  /// In en, this message translates to:
  /// **'Discovery failed. Please try again.'**
  String get smallWeb_discoveryFailedMessage;

  /// Error message for other small web failures. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Small web error: {error}'**
  String smallWeb_sessionErrorWithDetails(String error);

  /// Title of the information card about the Kagi Small Web source. Brand name.
  ///
  /// In en, this message translates to:
  /// **'Kagi Small Web'**
  String get smallWeb_kagiTitle;

  /// Credit line on the Kagi Small Web card. Kagi Search and MIT License are names.
  ///
  /// In en, this message translates to:
  /// **'By Kagi Search - open source under the MIT License.'**
  String get smallWeb_kagiAttributionLine;

  /// Button on the Kagi Small Web card that opens Kagi's blog post about the project.
  ///
  /// In en, this message translates to:
  /// **'Blog Post'**
  String get smallWeb_kagiBlogPostAction;

  /// Button on the Kagi Small Web card that opens the project's source code on GitHub. Brand name.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get smallWeb_kagiGithubAction;

  /// Description on the Kagi Small Web card while the "Web" mode is selected.
  ///
  /// In en, this message translates to:
  /// **'Kagi Small Web surfaces recent posts from personal sites and blogs by individual authors across the small web.'**
  String get smallWeb_kagiDescriptionWeb;

  /// Description on the Kagi Small Web card while the "Appreciated" mode is selected.
  ///
  /// In en, this message translates to:
  /// **'This Kagi Small Web mode highlights appreciated posts from the small web as curated by the open-source project.'**
  String get smallWeb_kagiDescriptionAppreciated;

  /// Description on the Kagi Small Web card while the "Videos" mode is selected. "Channel seeds" are the starting list of channels the project collects from.
  ///
  /// In en, this message translates to:
  /// **'This Kagi Small Web mode focuses on video posts from smaller independent creators and curated channel seeds.'**
  String get smallWeb_kagiDescriptionVideos;

  /// Description on the Kagi Small Web card while the "Code" mode is selected.
  ///
  /// In en, this message translates to:
  /// **'This Kagi Small Web mode focuses on code-oriented posts from personal sites and other small web sources.'**
  String get smallWeb_kagiDescriptionCode;

  /// Description on the Kagi Small Web card while the "Comics" mode is selected.
  ///
  /// In en, this message translates to:
  /// **'This Kagi Small Web mode focuses on comics and illustrated posts surfaced through the Small Web project.'**
  String get smallWeb_kagiDescriptionComics;

  /// Title of the information card about the Wander source. Project name.
  ///
  /// In en, this message translates to:
  /// **'Wander'**
  String get smallWeb_wanderTitle;

  /// Description on the Wander card. A console is a page on a personal site that links to other members' pages.
  ///
  /// In en, this message translates to:
  /// **'Wander is a network of personal websites connected through shared consoles that help people browse pages across the wider Wander community.'**
  String get smallWeb_wanderDescription;

  /// Credit line on the Wander card. Susam Pal is a person's name; MIT License is a license name.
  ///
  /// In en, this message translates to:
  /// **'By Susam Pal - open source under the MIT License.'**
  String get smallWeb_wanderAttributionLine;

  /// Button on the Wander card that opens the project's website.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get smallWeb_wanderProjectAction;

  /// Button on the Wander card that opens instructions for running your own Wander console on your website.
  ///
  /// In en, this message translates to:
  /// **'Set up your Console'**
  String get smallWeb_wanderSetupConsoleAction;

  /// Tooltip of the button in the Small Web bottom bar that opens the Small Web panel.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get smallWeb_menuTooltip;

  /// Tooltip of the bookmark button in the Small Web bottom bar when the current page is bookmarked.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get smallWeb_removeBookmarkTooltip;

  /// Tooltip of the bookmark button in the Small Web bottom bar when the current page is not bookmarked.
  ///
  /// In en, this message translates to:
  /// **'Add bookmark'**
  String get smallWeb_addBookmarkTooltip;

  /// Confirmation after removing the current small web page's bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark removed'**
  String get smallWeb_bookmarkRemovedMessage;

  /// Confirmation after bookmarking the current small web page.
  ///
  /// In en, this message translates to:
  /// **'Bookmark added'**
  String get smallWeb_bookmarkAddedMessage;

  /// Tooltip of the button that leaves Small Web browsing and returns to the normal browser.
  ///
  /// In en, this message translates to:
  /// **'Exit Small Web'**
  String get smallWeb_exitTooltip;

  /// Title of the sheet for choosing which Wander console to discover pages from.
  ///
  /// In en, this message translates to:
  /// **'Select Console'**
  String get smallWeb_selectConsoleTitle;

  /// Button in the console sheet that switches to a randomly chosen console.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get smallWeb_randomButtonLabel;

  /// Placeholder of the search field that filters the list of Wander consoles.
  ///
  /// In en, this message translates to:
  /// **'Filter consoles...'**
  String get smallWeb_filterConsolesHint;

  /// Toggle option in the console sheet: show only consoles linked from the current one. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get smallWeb_linkedConsolesToggleLabel;

  /// Toggle option in the console sheet: show all known consoles. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get smallWeb_allConsolesToggleLabel;

  /// Shown in the console sheet when no console is chosen yet. "Discover" is the button label in the Small Web panel and must match it.
  ///
  /// In en, this message translates to:
  /// **'No console selected yet. Press Discover.'**
  String get smallWeb_noConsoleSelectedYetMessage;

  /// Tooltip of the "+" button that adds a Wander console by entering its web address.
  ///
  /// In en, this message translates to:
  /// **'Add console by URL'**
  String get smallWeb_addConsoleByUrlTooltip;

  /// Error heading when the Small Web browsing state could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Could not load Small Web session'**
  String get smallWeb_couldNotLoadSessionTitle;

  /// Shown when the current console links to no other consoles.
  ///
  /// In en, this message translates to:
  /// **'No linked consoles found.'**
  String get smallWeb_noLinkedConsolesFound;

  /// Shown when no console matches the filter text. query is the text typed in the filter field.
  ///
  /// In en, this message translates to:
  /// **'No consoles match \"{query}\".'**
  String smallWeb_noConsolesMatchingQuery(String query);

  /// Error message when the list of Wander consoles could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Failed to load consoles.'**
  String get smallWeb_failedToLoadConsoles;

  /// Number of pages listed by a Wander console, shown under its name. count is the page count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String smallWeb_pageCount(int count);

  /// Shown in the list of all consoles when none has been found yet.
  ///
  /// In en, this message translates to:
  /// **'No consoles discovered yet.'**
  String get smallWeb_noConsolesDiscoveredYet;

  /// Confirmation after adding a Wander console. host is the console's domain, e.g. example.com.
  ///
  /// In en, this message translates to:
  /// **'Added console {host}'**
  String smallWeb_addedConsole(String host);

  /// Title of the dialog for adding a Wander console by address.
  ///
  /// In en, this message translates to:
  /// **'Add Console'**
  String get smallWeb_addConsoleDialogTitle;

  /// Explanation in the add-console dialog. "/wander/" is a literal address path and must stay unchanged.
  ///
  /// In en, this message translates to:
  /// **'Enter the URL of a Wander console. The URL can point to the site root or the /wander/ path.'**
  String get smallWeb_addConsoleDialogBody;

  /// Label of the web address field in the add-console dialog.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get smallWeb_urlFieldLabel;

  /// Error in the add-console dialog when the console's configuration file could not be downloaded. wander.js is a file name; keep it unchanged.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch wander.js from this console.'**
  String get smallWeb_wanderConsoleFetchFailed;

  /// Error in the add-console dialog when the console's configuration file lists nothing. wander.js is a file name; keep it unchanged.
  ///
  /// In en, this message translates to:
  /// **'The wander.js file contains no consoles or pages'**
  String get smallWeb_wanderConsoleEmpty;

  /// Error in the add-console dialog when the console is already in the list.
  ///
  /// In en, this message translates to:
  /// **'This console has already been added'**
  String get smallWeb_wanderConsoleAlreadyAdded;

  /// Heading of the list of recently discovered small web pages.
  ///
  /// In en, this message translates to:
  /// **'Recent Discoveries'**
  String get smallWeb_recentDiscoveriesTitle;

  /// Menu item that deletes the discovery history of one mode. mode is the mode's name, e.g. "Videos".
  ///
  /// In en, this message translates to:
  /// **'Clear {mode}'**
  String smallWeb_clearModeHistory(String mode);

  /// Title of the confirmation dialog before deleting the whole small web discovery history.
  ///
  /// In en, this message translates to:
  /// **'Clear all discoveries?'**
  String get smallWeb_clearAllDiscoveriesConfirmTitle;

  /// Body of the confirmation dialog before deleting the whole small web discovery history.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove all recent discovery history across every mode and source.'**
  String get smallWeb_clearAllDiscoveriesConfirmContent;

  /// Confirm button of the dialog that deletes the whole small web discovery history.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get smallWeb_actionClearAll;

  /// Menu item that deletes the whole small web discovery history (asks for confirmation first).
  ///
  /// In en, this message translates to:
  /// **'Clear all discoveries'**
  String get smallWeb_clearAllDiscoveriesMenuItem;

  /// Shown when the discovery history is empty. "Discover" is the button label and must match it. Keep the line break (\n).
  ///
  /// In en, this message translates to:
  /// **'No discoveries yet.\nTap Discover to start exploring!'**
  String get smallWeb_noDiscoveriesYetMessage;

  /// Button under the discovery history that reveals older entries. count is the number of hidden entries (at least 1).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{Show {count} more}}'**
  String smallWeb_showMoreCount(int count);

  /// Error message when the discovery history could not be loaded. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Failed to load history: {error}'**
  String smallWeb_failedToLoadHistory(String error);

  /// Title of the settings screen for Firefox Sync, Mozilla's service for syncing bookmarks, history and tabs between devices. Product name; usually left untranslated.
  ///
  /// In en, this message translates to:
  /// **'Firefox Sync'**
  String get sync_screenTitle;

  /// Placeholder of the search field on the Firefox Sync settings screen.
  ///
  /// In en, this message translates to:
  /// **'Search sync settings'**
  String get sync_searchHint;

  /// Status line under "Sync Now" while a sync is running.
  ///
  /// In en, this message translates to:
  /// **'Synchronization in progress'**
  String get sync_statusSyncing;

  /// Status line under "Sync Now" when this device has never completed a sync.
  ///
  /// In en, this message translates to:
  /// **'Never synced'**
  String get sync_statusNeverSynced;

  /// Status line under "Sync Now". date is the formatted date and time of the last completed sync.
  ///
  /// In en, this message translates to:
  /// **'Last synced: {date}'**
  String sync_statusLastSynced(String date);

  /// Section heading on the Firefox Sync settings screen for the signed-in Mozilla account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sync_sectionAccount;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'pairing, device name'**
  String get sync_sectionAccountKeywords;

  /// Title of the account section on the Firefox Sync settings screen when signed in.
  ///
  /// In en, this message translates to:
  /// **'Signed in account'**
  String get sync_entrySignedInAccountTitle;

  /// Title of the account section on the Firefox Sync settings screen when not signed in.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get sync_entrySignInTitle;

  /// Summary of what the account section of the Firefox Sync settings contains. "QR pairing" means signing in by scanning a QR code shown on a computer.
  ///
  /// In en, this message translates to:
  /// **'Account status, QR pairing, and device name'**
  String get sync_entryAccountSubtitle;

  /// Shown in place of the account email address when signed in but the address is unknown.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get sync_signedIn;

  /// Shown in place of the account email address when not signed in to Firefox Sync.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get sync_notSignedIn;

  /// Line under the account row when the Mozilla account session expired and the user must sign in again.
  ///
  /// In en, this message translates to:
  /// **'Authentication expired. Sign in again to continue syncing.'**
  String get sync_authExpired;

  /// Line under the account row when signed in and no display name is available; says what is being synced.
  ///
  /// In en, this message translates to:
  /// **'Syncing tabs, bookmarks, and history'**
  String get sync_syncingTabsBookmarksHistory;

  /// Line under the account row when not signed in, inviting the user to sign in.
  ///
  /// In en, this message translates to:
  /// **'Sign in to synchronize tabs, bookmarks, and history'**
  String get sync_signInPrompt;

  /// Tooltip of the sign-out button on the account row, and confirm button of the sign-out dialog.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get sync_actionSignOut;

  /// Row that opens the camera to scan the pairing QR code shown on a computer, to sign in to Firefox Sync.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code to pair'**
  String get sync_scanQrTitle;

  /// Explanation under the pairing row. firefox.com/pair is a web address and must stay unchanged; "desktop" means a desktop computer running Firefox.
  ///
  /// In en, this message translates to:
  /// **'Scan a QR code from firefox.com/pair on desktop'**
  String get sync_scanQrSubtitle;

  /// Error message when the scanned QR code does not contain a web address.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code: not a valid URL'**
  String get sync_invalidQrCode;

  /// Title of the row and dialog for the name this device has in Firefox Sync, as shown on the user's other devices.
  ///
  /// In en, this message translates to:
  /// **'Device Name'**
  String get sync_deviceNameTitle;

  /// Shown as the device name when it could not be determined.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get sync_unknown;

  /// Section heading on the Firefox Sync settings screen for sync actions and what data types to sync.
  ///
  /// In en, this message translates to:
  /// **'Synchronization'**
  String get sync_sectionSynchronization;

  /// Row that starts a sync immediately.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get sync_syncNowTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'history, bookmarks, tabs'**
  String get sync_syncNowKeywords;

  /// Switch: include browsing history in Firefox Sync.
  ///
  /// In en, this message translates to:
  /// **'Sync History'**
  String get sync_syncHistoryTitle;

  /// Switch: include bookmarks in Firefox Sync.
  ///
  /// In en, this message translates to:
  /// **'Sync Bookmarks'**
  String get sync_syncBookmarksTitle;

  /// Switch: share the list of open tabs through Firefox Sync.
  ///
  /// In en, this message translates to:
  /// **'Sync Open Tabs'**
  String get sync_syncOpenTabsTitle;

  /// Section heading for advanced settings that point Firefox Sync at self-hosted servers instead of Mozilla's.
  ///
  /// In en, this message translates to:
  /// **'Server Overrides'**
  String get sync_sectionServerOverrides;

  /// Title of the settings entry for custom Firefox Sync servers.
  ///
  /// In en, this message translates to:
  /// **'Server overrides'**
  String get sync_entryServerOverridesTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'fxa, token server'**
  String get sync_entryServerOverridesKeywords;

  /// Explanation under "Server overrides": addresses of self-hosted Firefox Account (sign-in) and token servers. "Firefox Account" is a product name.
  ///
  /// In en, this message translates to:
  /// **'Custom Firefox Account and token server endpoints'**
  String get sync_entryServerOverridesSubtitle;

  /// Row and dialog title for a custom Firefox Account sign-in server address. FxA is Mozilla's abbreviation for Firefox Account.
  ///
  /// In en, this message translates to:
  /// **'FxA Server Override'**
  String get sync_fxaServerOverrideTitle;

  /// Shown under the account server row when no custom server is set, meaning Mozilla's own server is used.
  ///
  /// In en, this message translates to:
  /// **'Default Mozilla server'**
  String get sync_defaultMozillaServer;

  /// Row and dialog title for a custom Firefox Sync token server address (the server that hands out access to sync storage).
  ///
  /// In en, this message translates to:
  /// **'Sync Token Server Override'**
  String get sync_tokenServerOverrideTitle;

  /// Shown under the token server row when no custom server is set: the address is taken from the Firefox Account server's configuration. FxA is Mozilla's abbreviation for Firefox Account.
  ///
  /// In en, this message translates to:
  /// **'Automatic from FxA server'**
  String get sync_automaticFromFxaServer;

  /// Small note under the server override rows: changes only take effect after restarting the app.
  ///
  /// In en, this message translates to:
  /// **'Restart the app after changing server overrides.'**
  String get sync_restartAppNotice;

  /// Title of the confirmation dialog before signing out of Firefox Sync.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get sync_signOutDialogTitle;

  /// Body of the confirmation dialog before signing out of Firefox Sync.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of Firefox Sync?'**
  String get sync_signOutDialogContent;

  /// Placeholder of the text field in the device name dialog.
  ///
  /// In en, this message translates to:
  /// **'Enter device name'**
  String get sync_deviceNameHint;

  /// Error message when saving an empty device name.
  ///
  /// In en, this message translates to:
  /// **'Device name cannot be empty'**
  String get sync_deviceNameEmpty;

  /// Error message when the new device name could not be saved to Firefox Sync.
  ///
  /// In en, this message translates to:
  /// **'Failed to update device name'**
  String get sync_deviceNameUpdateFailed;

  /// Error message when a custom sync server address is not a valid web address starting with https.
  ///
  /// In en, this message translates to:
  /// **'Must be a valid HTTPS URL'**
  String get sync_mustBeValidHttpsUrl;

  /// Section heading on the Tor settings screen for starting and stopping the Tor service. Tor is an anonymity network.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get tor_sectionService;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'power, start, stop'**
  String get tor_sectionServiceKeywords;

  /// Section heading on the Tor settings screen for ways of reaching Tor where it is blocked or censored ("censorship circumvention").
  ///
  /// In en, this message translates to:
  /// **'Circumvention'**
  String get tor_sectionCircumvention;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'bridges, transport, obfs4, snowflake'**
  String get tor_sectionCircumventionKeywords;

  /// Section heading on the Tor settings screen for limiting which countries the Tor connection enters or leaves the network through.
  ///
  /// In en, this message translates to:
  /// **'Country Restrictions'**
  String get tor_sectionCountryRestrictions;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'entry, exit, country'**
  String get tor_sectionCountryRestrictionsKeywords;

  /// Section heading on the Tor settings screen for legal information.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get tor_sectionAbout;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'trademark, legal'**
  String get tor_sectionAboutKeywords;

  /// Name of the built-in Tor proxy, used as screen title, dialog title and connection menu label. brand is "Tor™" (trademark, never translated).
  ///
  /// In en, this message translates to:
  /// **'{brand} Proxy'**
  String tor_proxyLabel(String brand);

  /// Title of the switch that starts or stops the Tor service. brand is "Tor™".
  ///
  /// In en, this message translates to:
  /// **'{brand} Service'**
  String tor_serviceLabel(String brand);

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'enable, connect'**
  String get tor_serviceLabelKeywords;

  /// Explanation under the Tor service switch. brand is "Tor™".
  ///
  /// In en, this message translates to:
  /// **'Start or stop the {brand} service'**
  String tor_serviceSubtitle(String brand);

  /// Switch on the Tor settings screen: connect to Tor automatically when the app starts.
  ///
  /// In en, this message translates to:
  /// **'Start Automatically'**
  String get tor_startAutomaticallyTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'autostart, launch, startup, boot'**
  String get tor_startAutomaticallyKeywords;

  /// Short explanation of the Tor auto-start switch, shown as a settings search result. brand is "Tor™"; WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'Connect the {brand} service when WebLibre starts'**
  String tor_startAutomaticallySectionSubtitle(String brand);

  /// Explanation under the Tor auto-start switch: tabs that must use Tor can load right away without asking to start it. brand is "Tor™"; WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'Connect the {brand} service when WebLibre starts, so tabs using it are ready without a prompt'**
  String tor_startAutomaticallySubtitle(String brand);

  /// Row that switches Tor to new routes through the network, so new connections appear to come from a different place. "New Identity" is Tor's own term.
  ///
  /// In en, this message translates to:
  /// **'Request New Identity'**
  String get tor_requestNewIdentityTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'circuit'**
  String get tor_requestNewIdentityKeywords;

  /// Explanation under "Request New Identity". A circuit is the path of relays a Tor connection goes through.
  ///
  /// In en, this message translates to:
  /// **'Use a fresh circuit for new connections'**
  String get tor_requestNewIdentitySubtitle;

  /// Confirmation shown after requesting a new Tor identity. brand is "Tor™".
  ///
  /// In en, this message translates to:
  /// **'Requesting new {brand} identity...'**
  String tor_requestingNewIdentityMessage(String brand);

  /// Switch: let the app detect automatically how to connect to Tor on the current network. A transport is the method used to disguise the connection.
  ///
  /// In en, this message translates to:
  /// **'Auto Configure Transport'**
  String get tor_autoConfigureTransportTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'auto'**
  String get tor_autoConfigureTransportKeywords;

  /// Short explanation of the automatic transport setting, shown as a settings search result. "Pluggable transport" is Tor's term for a method that disguises Tor traffic to get past censorship.
  ///
  /// In en, this message translates to:
  /// **'Pick the right pluggable transport for your network automatically'**
  String get tor_autoConfigureSectionSubtitle;

  /// Explanation under the automatic transport switch. brand is "Tor™". "Pluggable transport" is Tor's term for a method that disguises Tor traffic.
  ///
  /// In en, this message translates to:
  /// **'From some locations, it is necessary to use a pluggable transport to connect to {brand}'**
  String tor_autoConfigureSubtitle(String brand);

  /// Switch shown with automatic transport selection: tells it to only use connection methods through a bridge (a hidden entry point to Tor). Written in the first person, as a statement by the user.
  ///
  /// In en, this message translates to:
  /// **'I\'m sure I cannot connect without a bridge'**
  String get tor_requireBridgeTitle;

  /// Title of the setting for manually choosing how to connect to Tor.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get tor_transportTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'direct, obfs4, snowflake'**
  String get tor_transportKeywords;

  /// Short explanation of the manual transport setting, shown as a settings search result. torBrand is "Tor™"; keep it unchanged.
  ///
  /// In en, this message translates to:
  /// **'Choose how to reach the {torBrand} network when not auto-configured'**
  String tor_transportSectionSubtitle(String torBrand);

  /// Shown in place of the manual transport choices while automatic configuration is on.
  ///
  /// In en, this message translates to:
  /// **'Auto-configured'**
  String get tor_transportAutoConfiguredTitle;

  /// Explanation under "Auto-configured": turn off the switch above to choose manually.
  ///
  /// In en, this message translates to:
  /// **'Disable auto-configure above to pick a transport manually.'**
  String get tor_transportAutoConfiguredSubtitle;

  /// Choice of Tor transport: connect to Tor directly, without disguise.
  ///
  /// In en, this message translates to:
  /// **'Direct Connection'**
  String get tor_transportDirectTitle;

  /// Explanation under "Direct Connection". brand is "Tor™" and appears twice.
  ///
  /// In en, this message translates to:
  /// **'The best way to connect to {brand} if {brand} is not blocked'**
  String tor_transportDirectSubtitle(String brand);

  /// Choice of Tor transport named obfs4. Technical name; do not translate.
  ///
  /// In en, this message translates to:
  /// **'obfs4'**
  String get tor_transportObfs4Title;

  /// Explanation under the obfs4 transport choice: suited to networks with little censorship where speed matters.
  ///
  /// In en, this message translates to:
  /// **'Suitable for lightly censored networks and high-bandwidth use'**
  String get tor_transportObfs4Subtitle;

  /// Choice of Tor transport named Snowflake. Product name; do not translate.
  ///
  /// In en, this message translates to:
  /// **'Snowflake'**
  String get tor_transportSnowflakeTitle;

  /// Explanation under the Snowflake transport choice: suited to networks with strong censorship.
  ///
  /// In en, this message translates to:
  /// **'Suitable for heavy censorship'**
  String get tor_transportSnowflakeSubtitle;

  /// Checkbox: download an up-to-date list of bridges (hidden entry points to Tor) before connecting, instead of only using the built-in ones.
  ///
  /// In en, this message translates to:
  /// **'Fetch fresh bridges before connecting'**
  String get tor_fetchFreshBridgesTitle;

  /// Title of the setting for the country of the first relay the Tor connection enters through.
  ///
  /// In en, this message translates to:
  /// **'Entry Country'**
  String get tor_entryCountryTitle;

  /// Explanation of the entry country setting. The entry guard is the first relay of a Tor connection.
  ///
  /// In en, this message translates to:
  /// **'Choose the country of the entry guard'**
  String get tor_entryCountrySubtitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'guard'**
  String get tor_entryCountryKeywords;

  /// Title of the setting for the country of the last relay, where the connection leaves Tor and reaches websites.
  ///
  /// In en, this message translates to:
  /// **'Exit Country'**
  String get tor_exitCountryTitle;

  /// Explanation of the exit country setting. The exit node is the last relay of a Tor connection; websites see its address.
  ///
  /// In en, this message translates to:
  /// **'Choose the country of the exit node'**
  String get tor_exitCountrySubtitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'exit'**
  String get tor_exitCountryKeywords;

  /// Choice in the Tor country settings: let Tor pick the country. Also shown as the current value when no country is chosen.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get tor_automaticOption;

  /// Title of the trademark notice on the Tor settings screen.
  ///
  /// In en, this message translates to:
  /// **'Trademark'**
  String get tor_trademarkTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'legal'**
  String get tor_trademarkKeywords;

  /// Legal trademark notice. brand is "Tor™". "The Tor Project" is an organization name; WebLibre is the app name. Keep the legal meaning exact.
  ///
  /// In en, this message translates to:
  /// **'{brand} is a trademark of The Tor Project; all rights reserved. WebLibre is not endorsed or sponsored by, or affiliated with, the Tor Project.'**
  String tor_trademarkDisclaimer(String brand);

  /// Subtitle of the Tor settings screen listing what it configures. "Onion routing" is how Tor works; bridges are hidden entry points; pluggable transports disguise the traffic.
  ///
  /// In en, this message translates to:
  /// **'Onion routing, pluggable transports, bridges and country restrictions.'**
  String get tor_screenSubtitle;

  /// Body of the dialog shown when opening a container that must use Tor while the Tor proxy is not running. brand is "Tor™". A container is a separate browsing identity.
  ///
  /// In en, this message translates to:
  /// **'This container requires a {brand} proxy for secure connections, which is not currently running.'**
  String tor_dialogContent(String brand);

  /// Confirm button of that dialog: start the Tor proxy.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get tor_actionEnable;

  /// Status banner while the Tor proxy connects. proxyLabel is the proxy's name, "Tor™ Proxy" (already translated).
  ///
  /// In en, this message translates to:
  /// **'{proxyLabel} is connecting...'**
  String tor_connectingNotification(String proxyLabel);

  /// Placeholder of the search field in the country picker for Tor entry and exit countries.
  ///
  /// In en, this message translates to:
  /// **'Search countries...'**
  String get tor_countrySearchHint;

  /// Fallback name in the country picker for a country with no known name.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Country'**
  String get tor_unnamedCountry;

  /// Title of the screen listing browser profiles. Each profile is a fully separate browser with its own tabs, history and settings.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get user_profilesTitle;

  /// Line under the profile currently in use, in the profile list.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get user_activeProfileLabel;

  /// Error heading when the list of profiles could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Could not load profiles'**
  String get user_loadProfilesFailedTitle;

  /// Switch in the profile list: show a profile picker every time the app starts.
  ///
  /// In en, this message translates to:
  /// **'Ask which profile to open'**
  String get user_askWhichProfileTitle;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'At startup, when more than one profile exists'**
  String get user_askWhichProfileSubtitle;

  /// Title of the screen for backing up a profile to an encrypted file.
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get user_createBackupTitle;

  /// Message shown when the app restarts to create the backup.
  ///
  /// In en, this message translates to:
  /// **'Restarting to take the backup'**
  String get user_restartingToTakeBackup;

  /// Row on the backup screen explaining that the app restarts to take the backup. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'WebLibre restarts to do this'**
  String get user_backupRestartsTitle;

  /// Explanation under that row. restartClosesCurrentProfile is a full sentence saying the restart also closes the profile currently in use.
  ///
  /// In en, this message translates to:
  /// **'{restartClosesCurrentProfile} The backup is taken while the profile is closed, so its contents cannot change during the backup.'**
  String user_backupRestartsSubtitle(String restartClosesCurrentProfile);

  /// Row on the backup screen: the backup password is asked for in the next step, after the restart.
  ///
  /// In en, this message translates to:
  /// **'You set the password next'**
  String get user_setPasswordNextTitle;

  /// Explanation under that row.
  ///
  /// In en, this message translates to:
  /// **'After restarting, WebLibre asks for the backup file password.'**
  String get user_setPasswordNextSubtitle;

  /// Switch on the backup screen: check the finished backup file by test-reading it.
  ///
  /// In en, this message translates to:
  /// **'Verify backup integrity'**
  String get user_verifyBackupIntegrityTitle;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Check that the backup can be restored'**
  String get user_verifyBackupIntegritySubtitle;

  /// Row on the backup screen: temporary data is not included in backups.
  ///
  /// In en, this message translates to:
  /// **'Temporary data is skipped'**
  String get user_tempDataSkippedTitle;

  /// Explanation under that row. shortcutsNeedPinningAgain is a full sentence about re-adding home-screen shortcuts after restoring.
  ///
  /// In en, this message translates to:
  /// **'Cache files and other data WebLibre can rebuild are not saved. {shortcutsNeedPinningAgain}'**
  String user_tempDataSkippedSubtitle(String shortcutsNeedPinningAgain);

  /// Row on the backup screen: WebLibre account sign-in data is included in the backup file.
  ///
  /// In en, this message translates to:
  /// **'WebLibre account data is included'**
  String get user_accountDataIncludedTitle;

  /// Explanation under that row. profileSecretDataDescription is a lowercase list such as "WebLibre account sign-in, sync setup and proxy details".
  ///
  /// In en, this message translates to:
  /// **'The backup file includes this profile’s {profileSecretDataDescription}. Replacing a profile restores them; creating a new profile does not. Use a strong password.'**
  String user_accountDataIncludedSubtitle(String profileSecretDataDescription);

  /// Progress text while the app closes to take a backup.
  ///
  /// In en, this message translates to:
  /// **'Closing WebLibre to take the backup…'**
  String get user_closingToTakeBackup;

  /// Button that starts a profile backup (asks for confirmation).
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get user_actionBackup;

  /// Title of the screen listing backup files in the chosen folder.
  ///
  /// In en, this message translates to:
  /// **'Backups'**
  String get user_backupsTitle;

  /// Tooltip of the button that picks a different folder for backups.
  ///
  /// In en, this message translates to:
  /// **'Change backup folder'**
  String get user_changeBackupFolderTooltip;

  /// Shown on the backups screen before a backup folder is chosen.
  ///
  /// In en, this message translates to:
  /// **'Choose where to store your backups.'**
  String get user_chooseBackupFolderPrompt;

  /// Advice under that prompt: choose a folder outside the app's own storage.
  ///
  /// In en, this message translates to:
  /// **'Pick a location outside the app, so the backups survive uninstalling it.'**
  String get user_chooseBackupFolderHint;

  /// Button that opens the system folder picker for backups.
  ///
  /// In en, this message translates to:
  /// **'Choose folder'**
  String get user_chooseFolderButtonLabel;

  /// Shown when the backup folder contains no backups.
  ///
  /// In en, this message translates to:
  /// **'No backups found'**
  String get user_noBackupsFound;

  /// Error heading when the list of backups could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Could not load backups'**
  String get user_loadBackupsFailedTitle;

  /// Reason shown in the system fingerprint/PIN prompt when turning on authentication for an existing profile.
  ///
  /// In en, this message translates to:
  /// **'Require authentication for profile'**
  String get user_authReasonRequireAuth;

  /// Reason shown in the system fingerprint/PIN prompt when creating a locked profile, to prove the device can unlock it.
  ///
  /// In en, this message translates to:
  /// **'Confirm you can unlock this profile'**
  String get user_authReasonConfirmUnlock;

  /// Reason shown in the system biometric or device-credential prompt when opening a locked profile.
  ///
  /// In en, this message translates to:
  /// **'Unlock profile'**
  String get user_authReasonUnlockProfile;

  /// Error message when authentication failed while changing a profile's lock. nothingChanged is "Nothing has been changed."
  ///
  /// In en, this message translates to:
  /// **'Could not confirm your identity. {nothingChanged}'**
  String user_authFailedExisting(String nothingChanged);

  /// Error message when authentication failed while creating a locked profile.
  ///
  /// In en, this message translates to:
  /// **'Could not confirm your identity. A locked profile is only created once this device can unlock it.'**
  String get user_authFailedNew;

  /// Title of the screen for editing a profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get user_editProfileTitle;

  /// Title of the screen for creating a profile.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get user_createProfileTitle;

  /// Label of the profile name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get user_nameFieldLabel;

  /// Section heading in the profile editor for locking the profile behind fingerprint or device PIN.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get user_authenticationSectionTitle;

  /// Switch: require fingerprint or device PIN to open this profile.
  ///
  /// In en, this message translates to:
  /// **'Require authentication'**
  String get user_requireAuthenticationTitle;

  /// Explanation under that switch.
  ///
  /// In en, this message translates to:
  /// **'Ask before this profile can be opened'**
  String get user_requireAuthenticationSubtitle;

  /// Heading of the choice of when a locked profile locks again.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock'**
  String get user_autoLockTitle;

  /// Explanation under "Auto-lock".
  ///
  /// In en, this message translates to:
  /// **'When to lock the profile again'**
  String get user_autoLockSubtitle;

  /// Auto-lock option: lock as soon as the app is left.
  ///
  /// In en, this message translates to:
  /// **'Lock in background'**
  String get user_lockInBackgroundTitle;

  /// Explanation under "Lock in background". WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'As soon as WebLibre leaves the screen'**
  String get user_lockInBackgroundSubtitle;

  /// Auto-lock option: lock after a period without use.
  ///
  /// In en, this message translates to:
  /// **'Lock after a timeout'**
  String get user_lockAfterTimeoutTitle;

  /// Explanation under "Lock after a timeout".
  ///
  /// In en, this message translates to:
  /// **'After a period of inactivity'**
  String get user_lockAfterTimeoutSubtitle;

  /// Auto-lock option: lock only when the app starts.
  ///
  /// In en, this message translates to:
  /// **'Lock on startup only'**
  String get user_lockOnStartupTitle;

  /// Explanation under "Lock on startup only". WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'Unlock once at startup, then stay unlocked until WebLibre is fully closed'**
  String get user_lockOnStartupSubtitle;

  /// Row for choosing how long before the profile locks.
  ///
  /// In en, this message translates to:
  /// **'Timeout'**
  String get user_timeoutFieldTitle;

  /// Explanation under "Timeout".
  ///
  /// In en, this message translates to:
  /// **'How long to wait before locking'**
  String get user_timeoutFieldSubtitle;

  /// Auto-lock timeout option.
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get user_timeoutOneMinute;

  /// Auto-lock timeout option.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get user_timeoutFiveMinutes;

  /// Auto-lock timeout option.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get user_timeoutFifteenMinutes;

  /// Auto-lock timeout option.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get user_timeoutOneHour;

  /// Section heading in the profile editor for backup, switch and delete buttons.
  ///
  /// In en, this message translates to:
  /// **'Profile actions'**
  String get user_profileActionsSectionTitle;

  /// Note in the profile editor for the profile in use.
  ///
  /// In en, this message translates to:
  /// **'Switching and deleting are unavailable for the profile you are using.'**
  String get user_switchDeleteUnavailableForActive;

  /// Button in the profile editor that restarts the app with this profile.
  ///
  /// In en, this message translates to:
  /// **'Switch to this profile'**
  String get user_switchToThisProfileLabel;

  /// Error message when deleting a profile failed. error is a translated failure description.
  ///
  /// In en, this message translates to:
  /// **'Could not delete: {error}'**
  String user_deleteFailedWithError(String error);

  /// Error message when a profile could not be deleted (already gone or damaged).
  ///
  /// In en, this message translates to:
  /// **'Could not delete this profile'**
  String get user_deleteProfileFailedGeneric;

  /// Title of the screen for restoring a profile backup file.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get user_restoreBackupTitle;

  /// Confirmation after a backup was restored into a new profile.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get user_backupRestoredMessage;

  /// Label of the backup password field.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get user_passwordFieldLabel;

  /// Error under the password field when it does not open the backup file.
  ///
  /// In en, this message translates to:
  /// **'This password did not open the backup file'**
  String get user_wrongBackupPassword;

  /// Help text under the backup password field.
  ///
  /// In en, this message translates to:
  /// **'The password this backup file was created with.'**
  String get user_passwordHelperText;

  /// Restore option: restore the backup as an additional new profile.
  ///
  /// In en, this message translates to:
  /// **'Create a new profile'**
  String get user_createNewProfileTitle;

  /// Explanation under "Create a new profile".
  ///
  /// In en, this message translates to:
  /// **'Keep your existing profiles and add this backup'**
  String get user_createNewProfileSubtitle;

  /// Restore option: overwrite an existing profile with the backup.
  ///
  /// In en, this message translates to:
  /// **'Replace an existing profile'**
  String get user_replaceExistingProfileTitle;

  /// Explanation under "Replace an existing profile".
  ///
  /// In en, this message translates to:
  /// **'Restart and overwrite one profile with this backup'**
  String get user_replaceExistingProfileSubtitle;

  /// Note when restoring as a new profile: WebLibre account sign-in is not carried over.
  ///
  /// In en, this message translates to:
  /// **'A new profile starts without WebLibre sign-in'**
  String get user_newProfileNoSignInTitle;

  /// Explanation under that note.
  ///
  /// In en, this message translates to:
  /// **'Tabs, history and bookmarks are restored. Sign-in and sync data stay with the original profile.'**
  String get user_newProfileNoSignInSubtitle;

  /// Line naming the profile the backup will replace. profileLabel is its name.
  ///
  /// In en, this message translates to:
  /// **'Restoring into \"{profileLabel}\"'**
  String user_restoringIntoTitle(String profileLabel);

  /// Line under "Restoring into …" when the profile takes the backup's name: the lock settings stay.
  ///
  /// In en, this message translates to:
  /// **'The backup keeps the lock you configured.'**
  String get user_backupKeepsLockConfigured;

  /// Line under "Restoring into …": the profile keeps its name and lock settings.
  ///
  /// In en, this message translates to:
  /// **'The profile keeps its name and lock.'**
  String get user_profileKeepsNameAndLock;

  /// Label of the drop-down for choosing which profile the backup replaces.
  ///
  /// In en, this message translates to:
  /// **'Profile to replace'**
  String get user_profileToReplaceLabel;

  /// Validation error when no profile to replace was chosen.
  ///
  /// In en, this message translates to:
  /// **'Select a profile to replace'**
  String get user_selectProfileToReplaceValidator;

  /// Heading when several profiles have the name the backup refers to. count is how many (always more than one); name is the profile name.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} profiles are called \"{name}\"}}'**
  String user_multipleProfilesShareNameTitle(int count, String name);

  /// Explanation under that heading. cannotBeUndone is "This cannot be undone."
  ///
  /// In en, this message translates to:
  /// **'The backup names a profile but cannot say which one, so pick the one to replace. {cannotBeUndone}'**
  String user_multipleProfilesShareNameSubtitle(String cannotBeUndone);

  /// Heading when the backup comes from a different profile than the one being replaced. name is the original profile's name.
  ///
  /// In en, this message translates to:
  /// **'This backup was taken from \"{name}\"'**
  String user_backupTakenFromTitle(String name);

  /// Explanation under that heading. targetLabel is the profile being replaced; shortcutsNeedPinningAgain is a full sentence about re-adding home-screen shortcuts.
  ///
  /// In en, this message translates to:
  /// **'It replaces \"{targetLabel}\", which keeps its name and lock. {shortcutsNeedPinningAgain}'**
  String user_backupTakenFromSubtitle(
    String targetLabel,
    String shortcutsNeedPinningAgain,
  );

  /// Heading when the replaced profile takes the backup's name. name is that name.
  ///
  /// In en, this message translates to:
  /// **'This profile will be called \"{name}\"'**
  String user_profileWillBeCalledTitle(String name);

  /// Explanation under that heading. shortcutsNeedPinningAgain is a full sentence about re-adding home-screen shortcuts.
  ///
  /// In en, this message translates to:
  /// **'The name comes from the backup. {shortcutsNeedPinningAgain}'**
  String user_profileWillBeCalledSubtitle(String shortcutsNeedPinningAgain);

  /// Note when replacing a profile: WebLibre account sign-in data from the backup is restored.
  ///
  /// In en, this message translates to:
  /// **'WebLibre account data is restored'**
  String get user_accountDataRestoredTitle;

  /// Explanation under that note. profileSecretDataDescription is a lowercase list; signedInFromBackup and olderBackupKeepsCredentials are full sentences.
  ///
  /// In en, this message translates to:
  /// **'Replacing restores the backup file\'s {profileSecretDataDescription}. {signedInFromBackup} {olderBackupKeepsCredentials}'**
  String user_accountDataRestoredSubtitle(
    String profileSecretDataDescription,
    String signedInFromBackup,
    String olderBackupKeepsCredentials,
  );

  /// Warning heading when the restore replaces the profile being created during first-run setup.
  ///
  /// In en, this message translates to:
  /// **'This replaces the profile you are setting up'**
  String get user_replacesSetupProfileTitle;

  /// Warning heading when the restore replaces an existing profile.
  ///
  /// In en, this message translates to:
  /// **'This replaces everything in that profile'**
  String get user_replacesEverythingTitle;

  /// Warning text under that heading. restartsThenAsksPassword is two sentences: the app restarts, then asks for the backup password.
  ///
  /// In en, this message translates to:
  /// **'{restartsThenAsksPassword} Anything already in this profile will be replaced when the restore starts.'**
  String user_replacesSetupProfileSubtitle(String restartsThenAsksPassword);

  /// Warning text. restartsThenAsksPassword is two sentences about the restart; profileDataDescription is a lowercase list such as "tabs, history, bookmarks, settings and saved site logins"; targetDescription is the quoted profile name or "that profile".
  ///
  /// In en, this message translates to:
  /// **'{restartsThenAsksPassword} When the restore starts, it replaces the current {profileDataDescription} in {targetDescription}.'**
  String user_replacesEverythingSubtitle(
    String restartsThenAsksPassword,
    String profileDataDescription,
    String targetDescription,
  );

  /// Fallback phrase inserted as targetDescription in the replace warning when no profile is chosen yet. Lowercase.
  ///
  /// In en, this message translates to:
  /// **'that profile'**
  String get user_thatProfileFallbackLabel;

  /// Progress text while a backup is restored into a new profile.
  ///
  /// In en, this message translates to:
  /// **'Restoring backup…'**
  String get user_restoringBackupProgress;

  /// Progress text while the app closes to replace a profile with a backup. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'Closing WebLibre to restore…'**
  String get user_closingToRestoreProgress;

  /// Button that starts restoring the backup.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get user_actionRestore;

  /// Title of the confirmation dialog before switching profiles. profileName is the target profile.
  ///
  /// In en, this message translates to:
  /// **'Switch to \"{profileName}\"?'**
  String user_switchToProfileTitle(String profileName);

  /// Body of that dialog. profileName is the target profile; WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'WebLibre closes and reopens as \"{profileName}\".'**
  String user_switchClosesReopensAs(String profileName);

  /// Bulleted list in the switch dialog. Keep the "•" bullets and line break (\n).
  ///
  /// In en, this message translates to:
  /// **'• Private tabs are cleared.\n• Web notifications for the profile you leave are paused.'**
  String get user_switchConsequencesList;

  /// Button that cancels the profile switch dialog.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get user_actionNotNow;

  /// Button that confirms switching profiles, which restarts the app.
  ///
  /// In en, this message translates to:
  /// **'Switch and restart'**
  String get user_actionSwitchAndRestart;

  /// Title of a dialog asking the user to type a password again.
  ///
  /// In en, this message translates to:
  /// **'Password Confirmation'**
  String get user_passwordConfirmationTitle;

  /// Button that confirms the entered password.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get user_actionConfirm;

  /// Title of the sheet for choosing a profile to switch to.
  ///
  /// In en, this message translates to:
  /// **'Select profile'**
  String get user_selectProfileTitle;

  /// Button in the profile picker that opens the profile list.
  ///
  /// In en, this message translates to:
  /// **'Manage profiles'**
  String get user_manageProfilesLabel;

  /// Accessibility hint read by screen readers for a profile in the picker.
  ///
  /// In en, this message translates to:
  /// **'Switch to this profile. Long press to edit it.'**
  String get user_profileAvatarHint;

  /// Tooltip of a profile in the picker. label is the profile's name. Keep the line break (\n).
  ///
  /// In en, this message translates to:
  /// **'{label}\nLong press to edit'**
  String user_profileAvatarTooltip(String label);

  /// Accessibility label of the "+" tile in the profile picker that creates a profile.
  ///
  /// In en, this message translates to:
  /// **'Add a profile'**
  String get user_addProfileLabel;

  /// Text under the "+" tile in the profile picker. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Add profile'**
  String get user_addProfileButtonLabel;

  /// Title of the confirmation dialog before quitting the app.
  ///
  /// In en, this message translates to:
  /// **'Quit Browser'**
  String get user_quitBrowserTitle;

  /// Body of that dialog.
  ///
  /// In en, this message translates to:
  /// **'This will shut down the browser cleanly and clear private-tab data.'**
  String get user_quitBrowserContent;

  /// Confirm button of that dialog.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get user_actionQuit;

  /// Title of the confirmation dialog before deleting a profile. profileName is its name.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{profileName}\"?'**
  String user_deleteProfileTitle(String profileName);

  /// Body of that dialog. profileDataDescription is a lowercase list such as "tabs, history, bookmarks, settings and saved site logins"; cannotBeUndone is "This cannot be undone."
  ///
  /// In en, this message translates to:
  /// **'Its {profileDataDescription} are removed. {cannotBeUndone}'**
  String user_deleteProfileContent(
    String profileDataDescription,
    String cannotBeUndone,
  );

  /// Restart note in the delete dialog. restartsToWork and restartClosesCurrentProfile are full sentences about the restart.
  ///
  /// In en, this message translates to:
  /// **'{restartsToWork} {restartClosesCurrentProfile} The profile being deleted is closed first.'**
  String user_deleteProfileRestartNote(
    String restartsToWork,
    String restartClosesCurrentProfile,
  );

  /// Confirm button of the delete-profile dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete and restart'**
  String get user_actionDeleteAndRestart;

  /// Title of the confirmation dialog before replacing a profile with a backup. profileName is its name.
  ///
  /// In en, this message translates to:
  /// **'Replace \"{profileName}\" with this backup?'**
  String user_replaceProfileTitle(String profileName);

  /// Body of that dialog during first-run setup. cannotBeUndone is "This cannot be undone."
  ///
  /// In en, this message translates to:
  /// **'The backup replaces the profile you are setting up. Anything already in it is lost. {cannotBeUndone}'**
  String user_replaceProfilePlaceholderContent(String cannotBeUndone);

  /// Body of that dialog. profileName is the profile; profileDataDescription is a lowercase list; cannotBeUndone is "This cannot be undone."
  ///
  /// In en, this message translates to:
  /// **'The backup replaces everything in \"{profileName}\" — its {profileDataDescription}. Anything added after the backup is lost. {cannotBeUndone}'**
  String user_replaceProfileContent(
    String profileName,
    String profileDataDescription,
    String cannotBeUndone,
  );

  /// Note in that dialog. signedInFromBackup and olderBackupKeepsCredentials are full sentences; profileSecretDataDescription is a lowercase list.
  ///
  /// In en, this message translates to:
  /// **'{signedInFromBackup} The restore also includes {profileSecretDataDescription} from the backup. {olderBackupKeepsCredentials}'**
  String user_replaceProfileAccountNote(
    String signedInFromBackup,
    String profileSecretDataDescription,
    String olderBackupKeepsCredentials,
  );

  /// Note in that dialog. adoptedName is the name taken from the backup; shortcutsNeedPinningAgain is a full sentence.
  ///
  /// In en, this message translates to:
  /// **'The profile is renamed to \"{adoptedName}\" and keeps its lock. {shortcutsNeedPinningAgain}'**
  String user_replaceProfileRenamedNote(
    String adoptedName,
    String shortcutsNeedPinningAgain,
  );

  /// Note in that dialog. sourceProfileName is the profile the backup came from; profileName is the profile being replaced; shortcutsNeedPinningAgain is a full sentence.
  ///
  /// In en, this message translates to:
  /// **'The backup came from \"{sourceProfileName}\". \"{profileName}\" keeps its name and lock. {shortcutsNeedPinningAgain}'**
  String user_replaceProfileFromSourceNote(
    String sourceProfileName,
    String profileName,
    String shortcutsNeedPinningAgain,
  );

  /// Restart note in that dialog. restartsThenAsksPassword and restartClosesCurrentProfile are full sentences.
  ///
  /// In en, this message translates to:
  /// **'{restartsThenAsksPassword} Nothing is replaced before that. {restartClosesCurrentProfile}'**
  String user_replaceProfileRestartNote(
    String restartsThenAsksPassword,
    String restartClosesCurrentProfile,
  );

  /// Confirm button of the replace-profile dialog.
  ///
  /// In en, this message translates to:
  /// **'Replace and restart'**
  String get user_actionReplaceAndRestart;

  /// Title of the confirmation dialog before backing up a profile. profileName is its name.
  ///
  /// In en, this message translates to:
  /// **'Back up \"{profileName}\"?'**
  String user_backupProfileTitle(String profileName);

  /// Body of that dialog.
  ///
  /// In en, this message translates to:
  /// **'The backup is taken with the profile closed, so nothing in it changes.'**
  String get user_backupProfileContent;

  /// Restart note in that dialog; both placeholders are full sentences about the restart. Usually kept as-is.
  ///
  /// In en, this message translates to:
  /// **'{restartsToWork} {restartClosesCurrentProfile}'**
  String user_backupProfileRestartNote(
    String restartsToWork,
    String restartClosesCurrentProfile,
  );

  /// Confirm button of the backup dialog.
  ///
  /// In en, this message translates to:
  /// **'Back up and restart'**
  String get user_actionBackupAndRestart;

  /// Message when choosing the profile already in use.
  ///
  /// In en, this message translates to:
  /// **'This profile is already active'**
  String get user_profileAlreadyActive;

  /// Error message when switching profiles failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Could not switch profile: {error}'**
  String user_switchProfileFailedWithError(String error);

  /// Heading of the lock screen shown while a profile is locked.
  ///
  /// In en, this message translates to:
  /// **'Profile is locked'**
  String get user_profileLockedTitle;

  /// Label of the unlock button while authentication runs.
  ///
  /// In en, this message translates to:
  /// **'Unlocking...'**
  String get user_unlockingLabel;

  /// Button on the lock screen that starts fingerprint or PIN authentication.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get user_unlockButtonLabel;

  /// Error message when restarting into another profile failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Could not restart: {error}'**
  String user_restartFailedWithError(String error);

  /// Label of the choose-another-profile button while the app restarts.
  ///
  /// In en, this message translates to:
  /// **'Restarting…'**
  String get user_restartingLabel;

  /// Button on the lock screen that restarts the app with a different profile.
  ///
  /// In en, this message translates to:
  /// **'Choose another profile'**
  String get user_chooseAnotherProfileLabel;

  /// Option for the search suggestion service: no suggestions while typing.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get user_searchSuggestionProviderNone;

  /// Search suggestion service option. Brand name; do not translate.
  ///
  /// In en, this message translates to:
  /// **'Brave'**
  String get user_searchSuggestionProviderBrave;

  /// Search suggestion service option. Brand name; do not translate.
  ///
  /// In en, this message translates to:
  /// **'DuckDuckGo'**
  String get user_searchSuggestionProviderDdg;

  /// Search suggestion service option. Brand name; do not translate.
  ///
  /// In en, this message translates to:
  /// **'Kagi'**
  String get user_searchSuggestionProviderKagi;

  /// Search suggestion service option. Brand name; do not translate.
  ///
  /// In en, this message translates to:
  /// **'Qwant'**
  String get user_searchSuggestionProviderQwant;

  /// Checkbox in the delete browsing data dialog: close all open tabs.
  ///
  /// In en, this message translates to:
  /// **'Open tabs'**
  String get user_deleteBrowsingDataTypeTabsTitle;

  /// Checkbox in the delete browsing data dialog.
  ///
  /// In en, this message translates to:
  /// **'Browsing history'**
  String get user_deleteBrowsingDataTypeHistoryTitle;

  /// Checkbox in the delete browsing data dialog: the list of recent search terms.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get user_deleteBrowsingDataTypeRecentSearchesTitle;

  /// Explanation under "Recent searches".
  ///
  /// In en, this message translates to:
  /// **'Queries shown on the search page'**
  String get user_deleteBrowsingDataTypeRecentSearchesDescription;

  /// Checkbox in the delete browsing data dialog.
  ///
  /// In en, this message translates to:
  /// **'Cookies and site data'**
  String get user_deleteBrowsingDataTypeCookiesTitle;

  /// Explanation under "Cookies and site data".
  ///
  /// In en, this message translates to:
  /// **'You’ll be logged out of most sites'**
  String get user_deleteBrowsingDataTypeCookiesDescription;

  /// Checkbox in the delete browsing data dialog: temporary copies of web content.
  ///
  /// In en, this message translates to:
  /// **'Cached images and files'**
  String get user_deleteBrowsingDataTypeCacheTitle;

  /// Explanation under "Cached images and files".
  ///
  /// In en, this message translates to:
  /// **'Frees up storage space'**
  String get user_deleteBrowsingDataTypeCacheDescription;

  /// Checkbox in the delete browsing data dialog: permissions granted to websites (camera, location, etc.).
  ///
  /// In en, this message translates to:
  /// **'Site permissions'**
  String get user_deleteBrowsingDataTypePermissionsTitle;

  /// Checkbox in the delete browsing data dialog: the list of downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get user_deleteBrowsingDataTypeDownloadsTitle;

  /// Title of the settings screen for choosing the home page wallpaper image.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper'**
  String get wallpaper_title;

  /// Explanation at the top of the wallpaper settings screen. Containers (separate browsing identities) can set their own wallpaper, which overrides this one.
  ///
  /// In en, this message translates to:
  /// **'Shown behind the home page, in every container that does not set its own.'**
  String get wallpaper_settingsDescription;

  /// Button that opens the file picker to pick a wallpaper image, shown while no wallpaper is set.
  ///
  /// In en, this message translates to:
  /// **'Choose image'**
  String get wallpaper_chooseImage;

  /// Button that opens the file picker to pick a different wallpaper image, shown while a wallpaper is already set.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get wallpaper_replace;

  /// Label of the slider that controls how strongly the wallpaper image is blurred.
  ///
  /// In en, this message translates to:
  /// **'Blur'**
  String get wallpaper_blurLabel;

  /// Label of the slider that controls how strongly the wallpaper image is faded into the app background color.
  ///
  /// In en, this message translates to:
  /// **'Dim'**
  String get wallpaper_dimLabel;

  /// Help text under the wallpaper dim slider explaining why the image is dimmed.
  ///
  /// In en, this message translates to:
  /// **'Dim blends the image into the app background, so page text stays readable in both light and dark themes.'**
  String get wallpaper_dimDescription;

  /// Shown in the wallpaper editor while no image is chosen, explaining that the home page then uses its normal background.
  ///
  /// In en, this message translates to:
  /// **'The home page keeps its default backdrop.'**
  String get wallpaper_editorDefaultDescription;

  /// Error message when the file picked as a wallpaper could not be opened or read.
  ///
  /// In en, this message translates to:
  /// **'That file could not be read'**
  String get wallpaper_importErrorUnreadable;

  /// Error message when the image picked as a wallpaper exceeds the size limit.
  ///
  /// In en, this message translates to:
  /// **'That image is too large'**
  String get wallpaper_importErrorTooLarge;

  /// Error message when the file picked as a wallpaper is not an image file.
  ///
  /// In en, this message translates to:
  /// **'That file is not an image'**
  String get wallpaper_importErrorNotAnImage;

  /// Error message when the file picked as a wallpaper looks like an image but its contents could not be decoded (e.g. corrupt or unsupported format).
  ///
  /// In en, this message translates to:
  /// **'That image could not be read'**
  String get wallpaper_importErrorDecodeFailed;

  /// Title of the dialog for subscribing to an RSS/Atom news feed.
  ///
  /// In en, this message translates to:
  /// **'Add Feed'**
  String get webFeed_addFeedTitle;

  /// Label of the field for the web address of the feed to subscribe to.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get webFeed_fieldUrlLabel;

  /// Button in the add-feed dialog offered when a site's feed was detected automatically: do not subscribe and stop suggesting this feed.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get webFeed_actionIgnore;

  /// Fallback name for a news feed that has no title.
  ///
  /// In en, this message translates to:
  /// **'Untitled Feed'**
  String get webFeed_unnamedFeedTitle;

  /// Fallback title for a feed article that has no title.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Article'**
  String get webFeed_unnamedArticleTitle;

  /// Error heading when a news feed could not be downloaded.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch feed'**
  String get webFeed_fetchFeedFailedTitle;

  /// Title of the screen listing the user's subscribed news feeds.
  ///
  /// In en, this message translates to:
  /// **'Feeds'**
  String get webFeed_feedsTitle;

  /// Error heading when the list of subscribed news feeds could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Failed to load feeds'**
  String get webFeed_loadFeedsFailedTitle;

  /// Label of the floating button on the feeds screen that adds a new feed subscription.
  ///
  /// In en, this message translates to:
  /// **'Add Feed'**
  String get webFeed_feedFabLabel;

  /// Error heading when a single news feed could not be loaded for editing.
  ///
  /// In en, this message translates to:
  /// **'Failed to load feed'**
  String get webFeed_loadFeedFailedTitle;

  /// Title of the screen for setting up a new feed subscription.
  ///
  /// In en, this message translates to:
  /// **'New Feed'**
  String get webFeed_newFeedTitle;

  /// Title of the screen for editing an existing feed subscription.
  ///
  /// In en, this message translates to:
  /// **'Edit Feed'**
  String get webFeed_editFeedTitle;

  /// Progress text while a news feed is being downloaded.
  ///
  /// In en, this message translates to:
  /// **'Fetching feed…'**
  String get webFeed_fetchingFeedMessage;

  /// Label of the field for the feed's display name.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get webFeed_fieldTitleLabel;

  /// Label of the field for the feed's description text.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get webFeed_fieldDescriptionLabel;

  /// Label of the field for the web address of the feed's icon image.
  ///
  /// In en, this message translates to:
  /// **'Icon URL'**
  String get webFeed_fieldIconUrlLabel;

  /// Label of the field for the address of the website the feed belongs to.
  ///
  /// In en, this message translates to:
  /// **'Site Link'**
  String get webFeed_fieldSiteLinkLabel;

  /// Label of the field for the address of the feed file itself.
  ///
  /// In en, this message translates to:
  /// **'Feed URL'**
  String get webFeed_fieldFeedUrlLabel;

  /// Title of the confirmation dialog before unsubscribing from a feed.
  ///
  /// In en, this message translates to:
  /// **'Delete Feed'**
  String get webFeed_deleteFeedTitle;

  /// Body of the confirmation dialog before unsubscribing from a feed; its downloaded articles are deleted too.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this feed and all its articles?'**
  String get webFeed_deleteFeedConfirm;

  /// Title of the article list when showing articles from all feeds, or when the feed has no name.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get webFeed_articlesTitle;

  /// Label of the search field above the list of feed articles.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get webFeed_searchLabel;

  /// Error heading when the list of feed articles could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Failed to load articles'**
  String get webFeed_loadArticlesFailedTitle;

  /// Publication date line of a feed article. date is a full date or a relative time such as "3 hours ago", or "N/A".
  ///
  /// In en, this message translates to:
  /// **'Published: {date}'**
  String webFeed_publishedLabel(String date);

  /// Abbreviation for "not available", inserted as the date in feed article and feed date lines when the date is unknown.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get webFeed_notAvailable;

  /// Last-modified date line of a feed article. date is a full date or a relative time such as "3 hours ago".
  ///
  /// In en, this message translates to:
  /// **'Updated: {date}'**
  String webFeed_updatedLabel(String date);

  /// Label in front of the list of authors of a feed article.
  ///
  /// In en, this message translates to:
  /// **'Authors:'**
  String get webFeed_authorsLabel;

  /// Label in front of the list of tags (categories) of a feed article.
  ///
  /// In en, this message translates to:
  /// **'Tags:'**
  String get webFeed_tagsLabel;

  /// Error heading when a feed article could not be opened.
  ///
  /// In en, this message translates to:
  /// **'Failed to load article'**
  String get webFeed_readArticleFailedTitle;

  /// Line on a feed card saying when the feed was last downloaded. date is a relative time such as "5 minutes ago", or "N/A".
  ///
  /// In en, this message translates to:
  /// **'Last fetched: {date}'**
  String webFeed_lastFetchedLabel(String date);

  /// Label of the field for adding tags (categories) to a feed.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get webFeed_tagsFieldLabel;

  /// Title of the settings screen for website push notifications. "Web Push" is the name of the web standard that lets websites send notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get webPush_screenTitle;

  /// Subtitle of the web push settings screen. UnifiedPush is the name of an open notification delivery system and must not be translated.
  ///
  /// In en, this message translates to:
  /// **'Website notifications delivered through UnifiedPush'**
  String get webPush_screenSubtitle;

  /// Title of the setting for the UnifiedPush distributor: a separate app (such as ntfy) that receives push messages from the internet and passes them to WebLibre. UnifiedPush is a product name.
  ///
  /// In en, this message translates to:
  /// **'UnifiedPush Distributor'**
  String get webPush_distributorTileTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'notifications, push, unifiedpush, ntfy'**
  String get webPush_distributorTileKeywords;

  /// Status text while the app checks the push distributor or the notification permission.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get webPush_checking;

  /// Error line under the distributor setting when its state could not be read. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Could not read push status: {error}'**
  String webPush_couldNotReadStatus(String error);

  /// Status text under the distributor setting while a new distributor is being set or removed.
  ///
  /// In en, this message translates to:
  /// **'Updating…'**
  String get webPush_updatingDistributor;

  /// Status text under the distributor setting while the app retries after a failed registration with the distributor.
  ///
  /// In en, this message translates to:
  /// **'Recovering from a registration error…'**
  String get webPush_registrationRecovering;

  /// Error line under the distributor setting. error is the technical error from the last failed registration, usually English.
  ///
  /// In en, this message translates to:
  /// **'Last registration error: {error}'**
  String webPush_lastRegistrationError(String error);

  /// Label of the disable button while web push is being turned off.
  ///
  /// In en, this message translates to:
  /// **'Disabling…'**
  String get webPush_disablingWebPush;

  /// Button that turns web push off by removing the chosen distributor.
  ///
  /// In en, this message translates to:
  /// **'Disable web push'**
  String get webPush_disableWebPush;

  /// Short status of the push distributor: no distributor app is installed on the device. Shown after the distributor's name or alone.
  ///
  /// In en, this message translates to:
  /// **'No distributor available'**
  String get webPush_statusNoneAvailable;

  /// Short status of the push distributor: distributor apps are installed but none is chosen.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get webPush_statusNotSelected;

  /// Short status of the push distributor: registration with the distributor is in progress.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get webPush_statusPending;

  /// Short status of the push distributor: working and delivering notifications. Shown after the distributor's name, e.g. "ntfy — Active".
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get webPush_statusReady;

  /// Short status of the push distributor: the chosen distributor app can no longer be reached.
  ///
  /// In en, this message translates to:
  /// **'Distributor unavailable'**
  String get webPush_statusUnavailable;

  /// Explanation under the distributor setting when no distributor app is installed. ntfy is an app name.
  ///
  /// In en, this message translates to:
  /// **'Install a UnifiedPush distributor app, such as ntfy, to receive website notifications.'**
  String get webPush_statusDescNoneAvailable;

  /// Explanation under the distributor setting when distributor apps are installed but none is chosen.
  ///
  /// In en, this message translates to:
  /// **'Choose a distributor below to enable website notifications.'**
  String get webPush_statusDescNotSelected;

  /// Explanation under the distributor setting while waiting for the distributor app to confirm registration.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the distributor to acknowledge registration.'**
  String get webPush_statusDescPending;

  /// Explanation under the distributor setting when push notifications are working.
  ///
  /// In en, this message translates to:
  /// **'Website notifications are delivered through this distributor.'**
  String get webPush_statusDescReady;

  /// Explanation under the distributor setting when the previously chosen distributor app was uninstalled.
  ///
  /// In en, this message translates to:
  /// **'The chosen distributor is no longer installed. Website notifications will not be delivered until you choose another one.'**
  String get webPush_statusDescUnavailable;

  /// Error message when the user tries to choose a distributor but no UnifiedPush distributor app is installed. ntfy is an app name.
  ///
  /// In en, this message translates to:
  /// **'No UnifiedPush distributor is installed. Install one, such as ntfy, and try again.'**
  String get webPush_noDistributorInstalled;

  /// Title of the dialog listing installed UnifiedPush distributor apps to choose from.
  ///
  /// In en, this message translates to:
  /// **'Choose distributor'**
  String get webPush_chooseDistributorTitle;

  /// Confirmation after a push distributor was chosen successfully.
  ///
  /// In en, this message translates to:
  /// **'UnifiedPush distributor configured.'**
  String get webPush_distributorConfigured;

  /// Error message when setting the chosen push distributor failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Could not configure distributor: {error}'**
  String webPush_couldNotConfigureDistributor(String error);

  /// Confirmation after web push was turned off.
  ///
  /// In en, this message translates to:
  /// **'Web push disabled.'**
  String get webPush_webPushDisabled;

  /// Error message when turning web push off failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Could not disable web push: {error}'**
  String webPush_couldNotDisableWebPush(String error);

  /// Title of the setting showing whether WebLibre has the Android permission to show notifications.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get webPush_notificationPermissionTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'notifications, permission'**
  String get webPush_notificationPermissionKeywords;

  /// Error line under the notification permission setting. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Could not read permission state: {error}'**
  String webPush_notificationPermissionCouldNotRead(String error);

  /// Status under the notification permission setting: the permission is granted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get webPush_notificationPermissionGranted;

  /// Status under the notification permission setting when the permission is denied: push messages still arrive but cannot be shown to the user.
  ///
  /// In en, this message translates to:
  /// **'Denied. Push messages still arrive, but no notifications can be shown.'**
  String get webPush_notificationPermissionDenied;

  /// Button next to the denied notification permission that asks Android for the permission or opens the app's system settings.
  ///
  /// In en, this message translates to:
  /// **'Grant'**
  String get webPush_grantAction;

  /// Error message when requesting the notification permission failed. error is technical error text, usually English.
  ///
  /// In en, this message translates to:
  /// **'Could not update notification permission: {error}'**
  String webPush_couldNotUpdatePermission(String error);

  /// Placeholder while the list of websites subscribed to push notifications loads.
  ///
  /// In en, this message translates to:
  /// **'Loading subscriptions…'**
  String get webPush_loadingSubscriptions;

  /// Error heading when the list of push subscriptions could not be read; technical details follow below.
  ///
  /// In en, this message translates to:
  /// **'Could not read subscriptions'**
  String get webPush_couldNotReadSubscriptions;

  /// Shown in place of the subscription list when no website is subscribed to push notifications.
  ///
  /// In en, this message translates to:
  /// **'No site subscriptions'**
  String get webPush_noSiteSubscriptions;

  /// Explanation under "No site subscriptions".
  ///
  /// In en, this message translates to:
  /// **'Websites you allow to send notifications will appear here.'**
  String get webPush_noSiteSubscriptionsDescription;

  /// Status under a website in the push subscription list: notifications from it are delivered.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get webPush_subscriptionActive;

  /// Status under a website in the push subscription list: the delivery address ("endpoint") is set up, but notifications are held back until the distributor app works again.
  ///
  /// In en, this message translates to:
  /// **'Endpoint saved; delivery is paused until the distributor is ready'**
  String get webPush_subscriptionDelayedDelivery;

  /// Status under a website in the push subscription list: the distributor app has not yet provided the delivery address ("endpoint") for it.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the distributor to assign an endpoint'**
  String get webPush_subscriptionWaitingForEndpoint;

  /// Hint under the push subscription list explaining how to stop a website's notifications: via that site's permissions.
  ///
  /// In en, this message translates to:
  /// **'To stop a site from sending notifications, revoke its notification permission in the site settings.'**
  String get webPush_revokeSubscriptionHint;

  /// Section heading on the web push settings screen for how notifications are delivered (distributor app and notification permission).
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get webPush_deliverySectionTitle;

  /// Short explanation of the UnifiedPush distributor setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'The app that delivers website push notifications'**
  String get webPush_indexDistributorSubtitle;

  /// Short explanation of the notification permission setting, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Required to display website notifications'**
  String get webPush_indexNotificationPermissionSubtitle;

  /// Section heading on the web push settings screen for the list of websites that receive push notifications.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get webPush_subscriptionsSectionTitle;

  /// Title of the list of websites subscribed to push notifications.
  ///
  /// In en, this message translates to:
  /// **'Site Subscriptions'**
  String get webPush_indexSiteSubscriptionsTitle;

  /// Comma-separated search terms for this setting. Not displayed; include synonyms users might type.
  ///
  /// In en, this message translates to:
  /// **'sites, subscriptions'**
  String get webPush_indexSiteSubscriptionsKeywords;

  /// Short explanation of the site subscriptions list, shown as a settings search result.
  ///
  /// In en, this message translates to:
  /// **'Websites subscribed to push notifications'**
  String get webPush_indexSiteSubscriptionsSubtitle;

  /// Title of the dialog for choosing how to fetch a web search result page through the privacy-preserving server (as a text preview, full copy, PDF or image).
  ///
  /// In en, this message translates to:
  /// **'Fetch Page Data'**
  String get webSearch_fetchPageDataTitle;

  /// Error line in the fetch dialog when downloading a server-captured page failed; tapping retries.
  ///
  /// In en, this message translates to:
  /// **'Download failed — tap to retry'**
  String get webSearch_downloadFailedTapToRetry;

  /// Fetch method: a text-only preview of the page extracted on the server.
  ///
  /// In en, this message translates to:
  /// **'Extracted Preview'**
  String get webSearch_methodTrafilaturaTitle;

  /// Fetch method: a complete copy of the page including layout and images, saved as one file.
  ///
  /// In en, this message translates to:
  /// **'Full Page Capture'**
  String get webSearch_methodSinglefileTitle;

  /// Fetch method: a PDF file of the rendered page.
  ///
  /// In en, this message translates to:
  /// **'PDF Snapshot'**
  String get webSearch_methodPdfTitle;

  /// Fetch method: a picture (PNG screenshot) of the whole rendered page.
  ///
  /// In en, this message translates to:
  /// **'Image Snapshot'**
  String get webSearch_methodPngTitle;

  /// Explanation under "Extracted Preview".
  ///
  /// In en, this message translates to:
  /// **'Reader-optimized text and metadata for the in-app preview'**
  String get webSearch_methodTrafilaturaSubtitle;

  /// Explanation under "Full Page Capture". "Assets" are the page's images, styles and similar files.
  ///
  /// In en, this message translates to:
  /// **'Archive the full page with layout and assets for later use'**
  String get webSearch_methodSinglefileSubtitle;

  /// Explanation under "PDF Snapshot".
  ///
  /// In en, this message translates to:
  /// **'Render the page to a PDF for offline reading and sharing'**
  String get webSearch_methodPdfSubtitle;

  /// Explanation under "Image Snapshot". PNG is an image file format.
  ///
  /// In en, this message translates to:
  /// **'Capture a full-page PNG screenshot of the rendered page'**
  String get webSearch_methodPngSubtitle;

  /// Error heading when opening a preview of a search result that was not fetched yet.
  ///
  /// In en, this message translates to:
  /// **'Preview unavailable'**
  String get webSearch_previewUnavailableTitle;

  /// Explanation under "Preview unavailable": the page must first be fetched with the button in the search results.
  ///
  /// In en, this message translates to:
  /// **'Fetch the page from the result list before opening a preview.'**
  String get webSearch_previewUnavailableMessage;

  /// Tooltip of the button on the page preview screen that opens the original page in a browser tab.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get webSearch_openInBrowserTooltip;

  /// Label of the web search toggle while searches are routed through Tor. brand is "Tor™".
  ///
  /// In en, this message translates to:
  /// **'{brand} on'**
  String webSearch_torToggleOn(String brand);

  /// Label of the web search toggle while searches are not routed through Tor. brand is "Tor™".
  ///
  /// In en, this message translates to:
  /// **'{brand} off'**
  String webSearch_torToggleOff(String brand);

  /// Label of the search language filter button when no language is chosen (automatic).
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get webSearch_languageAuto;

  /// Choice in the search language filter menu: pick the language automatically from the device settings.
  ///
  /// In en, this message translates to:
  /// **'Auto (device default)'**
  String get webSearch_languageAutoDeviceDefault;

  /// Label of the search region filter button when no region is chosen.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get webSearch_countryAny;

  /// Choice in the search region filter menu: results from any country.
  ///
  /// In en, this message translates to:
  /// **'Any region'**
  String get webSearch_countryAnyRegion;

  /// Choice in the search region filter menu for the device's own country. name is the country name.
  ///
  /// In en, this message translates to:
  /// **'{name} (device)'**
  String webSearch_countryDeviceDefault(String name);

  /// Label of the SafeSearch filter button (hides explicit content) when the default level is used. "Safe" is short for SafeSearch; keep it short.
  ///
  /// In en, this message translates to:
  /// **'Safe: default'**
  String get webSearch_safeSearchPillDefault;

  /// Label of the SafeSearch filter button when explicit content is not filtered. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Safe: off'**
  String get webSearch_safeSearchPillOff;

  /// Label of the SafeSearch filter button at the moderate filter level. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Safe: moderate'**
  String get webSearch_safeSearchPillModerate;

  /// Label of the SafeSearch filter button at the strict filter level. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'Safe: strict'**
  String get webSearch_safeSearchPillStrict;

  /// Choice in the SafeSearch menu: use the default level, which is moderate.
  ///
  /// In en, this message translates to:
  /// **'Default (moderate)'**
  String get webSearch_safeSearchMenuDefault;

  /// Choice in the SafeSearch menu: do not filter explicit content.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get webSearch_safeSearchMenuOff;

  /// Choice in the SafeSearch menu: moderate filtering of explicit content.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get webSearch_safeSearchMenuModerate;

  /// Choice in the SafeSearch menu: strict filtering of explicit content.
  ///
  /// In en, this message translates to:
  /// **'Strict'**
  String get webSearch_safeSearchMenuStrict;

  /// Label and choice of the search date filter: results of any age.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get webSearch_freshnessAnyTime;

  /// Label and choice of the search date filter: only results from the last 24 hours.
  ///
  /// In en, this message translates to:
  /// **'Past day'**
  String get webSearch_freshnessPastDay;

  /// Label and choice of the search date filter: only results from the last 7 days.
  ///
  /// In en, this message translates to:
  /// **'Past week'**
  String get webSearch_freshnessPastWeek;

  /// Label and choice of the search date filter: only results from the last month.
  ///
  /// In en, this message translates to:
  /// **'Past month'**
  String get webSearch_freshnessPastMonth;

  /// Label and choice of the search date filter: only results from the last year.
  ///
  /// In en, this message translates to:
  /// **'Past year'**
  String get webSearch_freshnessPastYear;

  /// Web search mode: normal search across the whole web.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get webSearch_modeGeneralLabel;

  /// Web search mode that prefers independent websites over large corporate ones.
  ///
  /// In en, this message translates to:
  /// **'Independent Web'**
  String get webSearch_modeIndependentWebLabel;

  /// Web search mode limited to the "small web": personal and non-commercial websites. Keep "Small Web" consistent with the app's Small Web feature.
  ///
  /// In en, this message translates to:
  /// **'Small Web'**
  String get webSearch_modeSmallWebLabel;

  /// Explanation under the "General" search mode.
  ///
  /// In en, this message translates to:
  /// **'Balanced results across the open web'**
  String get webSearch_modeGeneralDescription;

  /// Explanation under the "Independent Web" search mode.
  ///
  /// In en, this message translates to:
  /// **'Favor smaller and less corporate sources'**
  String get webSearch_modeIndependentWebDescription;

  /// Explanation under the "Small Web" search mode.
  ///
  /// In en, this message translates to:
  /// **'Independent, personal & niche sites'**
  String get webSearch_modeSmallWebDescription;

  /// Tooltip of the download button on a search result that fetches the page through the privacy-preserving server.
  ///
  /// In en, this message translates to:
  /// **'Fetch'**
  String get webSearch_fetchTooltip;

  /// Heading above extra text excerpts from the page, shown when a search result is expanded.
  ///
  /// In en, this message translates to:
  /// **'Additional Snippets'**
  String get webSearch_additionalSnippetsHeading;

  /// Prefix in front of a question in a search result's excerpts ("Q" for question). Keep the trailing space.
  ///
  /// In en, this message translates to:
  /// **'Q: '**
  String get webSearch_questionPrefix;

  /// Tooltip of the button that expands a search result to show more text excerpts from the page.
  ///
  /// In en, this message translates to:
  /// **'Snippets'**
  String get webSearch_snippetsTooltip;

  /// Button in a search info box that reveals hidden links. count is the number of hidden links.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Show 1 more link} other{Show {count} more links}}'**
  String webSearch_showMoreLinks(int count);

  /// Heading of the section in a search info box that lists key facts about the topic (like an encyclopedia fact box).
  ///
  /// In en, this message translates to:
  /// **'Factsheet'**
  String get webSearch_factsheetHeading;

  /// Error heading when a web search failed; the error message follows below.
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get webSearch_searchFailedTitle;

  /// Progress text while a web search runs.
  ///
  /// In en, this message translates to:
  /// **'Searching the web...'**
  String get webSearch_searchingLabel;

  /// Shown when a web search returned nothing. query is the search text.
  ///
  /// In en, this message translates to:
  /// **'No results found for \"{query}\".'**
  String webSearch_noResultsFor(String query);

  /// Status line above web search results. credits is the remaining prepaid search credits; tokens is the number of anonymous search tokens stored on the device. Keep the "|" separator.
  ///
  /// In en, this message translates to:
  /// **'{credits, plural, =1{1 credit} other{{credits} credits}}  |  {tokens, plural, =1{1 token} other{{tokens} tokens}}'**
  String webSearch_creditsTokensStatus(int credits, int tokens);

  /// Shown instead of results when the user has no search credits or tokens left for a web search.
  ///
  /// In en, this message translates to:
  /// **'No search credits or tokens are available for a new web search.'**
  String get webSearch_needsCreditsMessage;

  /// Button under that message that opens the store page for buying search credits.
  ///
  /// In en, this message translates to:
  /// **'Buy a search pack'**
  String get webSearch_buySearchPackButton;

  /// Error message when the connection to the search server failed.
  ///
  /// In en, this message translates to:
  /// **'Search connection error. Please try again.'**
  String get webSearch_socketConnectionError;

  /// Error message when the search server ended the session because it took too long.
  ///
  /// In en, this message translates to:
  /// **'Search session timed out. Please try again.'**
  String get webSearch_closeErrorSessionTimeout;

  /// Error message when the search server rejected the search credit (it may already have been used).
  ///
  /// In en, this message translates to:
  /// **'Your search credit could not be validated. The credit may have been spent — please try again.'**
  String get webSearch_closeErrorCreditInvalid;

  /// Error message when the search server refused to fetch a page because its rules do not allow that site.
  ///
  /// In en, this message translates to:
  /// **'The requested page is not permitted by the search policy.'**
  String get webSearch_closeErrorPolicyForbidden;

  /// Error message when the search server reported an internal failure.
  ///
  /// In en, this message translates to:
  /// **'The search failed on the server. Please try again.'**
  String get webSearch_closeErrorServerFailed;

  /// Error message when the search server closed the connection for an unknown reason. code is the numeric close code.
  ///
  /// In en, this message translates to:
  /// **'Search connection closed unexpectedly (code {code}). Please try again.'**
  String webSearch_closeErrorUnknown(int code);

  /// Fallback detail inserted into the "({detail})" part of search error messages when the server gave none. Lowercase fragment, not a sentence.
  ///
  /// In en, this message translates to:
  /// **'unknown error'**
  String get webSearch_unknownErrorDetail;

  /// Error message when the app and search server disagreed about the data format. detail is the server's reason (often English) or "unknown error".
  ///
  /// In en, this message translates to:
  /// **'Search protocol error. The session has ended — please try again. ({detail})'**
  String webSearch_streamErrorProtocol(String detail);

  /// Error message when the search failed on the server. detail is the server's reason (often English) or "unknown error".
  ///
  /// In en, this message translates to:
  /// **'The search failed on the server. Please try again. ({detail})'**
  String webSearch_streamErrorSearchFailed(String detail);

  /// Error message when the server could not download a result page from its website. detail is the server's reason (often English) or "unknown error".
  ///
  /// In en, this message translates to:
  /// **'Could not fetch this page from the source. ({detail})'**
  String webSearch_streamErrorFetchFailed(String detail);

  /// Error message when the server could not produce a text preview of a result page. detail is the server's reason (often English) or "unknown error".
  ///
  /// In en, this message translates to:
  /// **'Could not extract a readable preview from this page. ({detail})'**
  String webSearch_streamErrorExtractFailed(String detail);

  /// Error message when the server's rules do not allow fetching this page. detail is the server's reason (often English) or "unknown error".
  ///
  /// In en, this message translates to:
  /// **'This page is not permitted by the search policy. ({detail})'**
  String webSearch_streamErrorNotAllowed(String detail);

  /// Error message when the server failed to capture a result page as a file. detail is the server's reason (often English) or "unknown error".
  ///
  /// In en, this message translates to:
  /// **'Page capture failed. ({detail})'**
  String webSearch_streamErrorCaptureFailed(String detail);

  /// Error message for any other search failure. detail is the server's reason (often English) or "unknown error".
  ///
  /// In en, this message translates to:
  /// **'Search error: {detail}'**
  String webSearch_streamErrorGeneric(String detail);

  /// Error message when a web search should go through Tor but Tor could not be started. torBrand is "Tor™" and appears twice.
  ///
  /// In en, this message translates to:
  /// **'Could not start {torBrand} for the search. Disable the {torBrand} toggle or try again.'**
  String webSearch_torStartFailed(String torBrand);

  /// Error message when the app could not check the user's search credit balance before searching.
  ///
  /// In en, this message translates to:
  /// **'Could not check search credits. Please try again.'**
  String get webSearch_creditCheckFailed;

  /// Error message when the app could not obtain the anonymous search tokens needed for a web search.
  ///
  /// In en, this message translates to:
  /// **'Could not issue search tokens. Please try again.'**
  String get webSearch_tokenIssuanceFailed;

  /// Title bar of the error screen shown when the app fails to start.
  ///
  /// In en, this message translates to:
  /// **'Initialization Error'**
  String get mainApp_initializationErrorTitle;

  /// Heading on the error screen shown when the app fails to start; technical error details and a Retry button follow.
  ///
  /// In en, this message translates to:
  /// **'Could not initialize the app'**
  String get mainApp_initializationErrorMessage;

  /// Startup progress line under the spinner: loading date and number formats.
  ///
  /// In en, this message translates to:
  /// **'Loading formats…'**
  String get mainApp_initStageLoadingFormats;

  /// Startup progress line under the spinner: reading the app's version information.
  ///
  /// In en, this message translates to:
  /// **'Loading app information…'**
  String get mainApp_initStageLoadingPackageInfo;

  /// Startup progress line under the spinner: importing the bundled bang shortcuts (search shortcuts such as !w).
  ///
  /// In en, this message translates to:
  /// **'Synchronizing bangs…'**
  String get mainApp_initStageSyncingBangs;

  /// Short message shown at the bottom of the screen when a file download finishes, next to an Open button.
  ///
  /// In en, this message translates to:
  /// **'Download completed'**
  String get mainApp_downloadCompleted;

  /// Error message when the user taps Open on a finished download and no app can open the file.
  ///
  /// In en, this message translates to:
  /// **'Could not open downloaded file'**
  String get mainApp_downloadOpenFailed;

  /// Error message when a file download fails. name is the file name, or the download URL when the name is unknown.
  ///
  /// In en, this message translates to:
  /// **'Download failed: {name}'**
  String mainApp_downloadFailed(String name);

  /// Message when a page was blocked from loading in the current container because the site is assigned to a different container (a container is a separate browsing identity). host is the website domain, e.g. example.com.
  ///
  /// In en, this message translates to:
  /// **'{host} is not assigned to this container'**
  String mainApp_containerBlockedWithHost(String host);

  /// Message when a page was blocked from loading in the current container because the site is assigned to a different container. Used when the domain cannot be determined.
  ///
  /// In en, this message translates to:
  /// **'This site is not assigned to this container'**
  String get mainApp_containerBlockedNoHost;

  /// Error message when a privacy-preserving page capture from a web search cannot run because the user's prepaid search credits are used up.
  ///
  /// In en, this message translates to:
  /// **'You have no search credits left. Purchase more to continue.'**
  String get mainApp_sandboxNoCredits;

  /// Error message when the app could not obtain new anonymous search tokens from the server for a privacy-preserving page capture.
  ///
  /// In en, this message translates to:
  /// **'Could not issue new search tokens. Check your connection and try again.'**
  String get mainApp_sandboxTokenIssuanceFailed;

  /// Error message when a privacy-preserving page capture was refused by the server's rules for which pages may be fetched. detail is the reason given by the server (may be English) or the fragment "not allowed".
  ///
  /// In en, this message translates to:
  /// **'Capture blocked by fetch policy: {detail}'**
  String mainApp_sandboxFetchPolicyRejected(String detail);

  /// Fallback reason inserted into "Capture blocked by fetch policy: {detail}" when the server gave no reason. Lowercase fragment, not a sentence.
  ///
  /// In en, this message translates to:
  /// **'not allowed'**
  String get mainApp_sandboxDetailNotAllowed;

  /// Error message when the server failed to capture a web page for a privacy-preserving preview. detail is the reason given by the server (may be English) or the fragment "unknown error".
  ///
  /// In en, this message translates to:
  /// **'Capture failed: {detail}'**
  String mainApp_sandboxCaptureFailed(String detail);

  /// Fallback reason inserted into page-capture error messages ("Capture failed: {detail}") when the server gave no reason. Lowercase fragment, not a sentence.
  ///
  /// In en, this message translates to:
  /// **'unknown error'**
  String get mainApp_sandboxDetailUnknownError;

  /// Error message when a web page was captured on the server for a privacy-preserving preview but the result could not be downloaded to the device.
  ///
  /// In en, this message translates to:
  /// **'Capture artifact download failed.'**
  String get mainApp_sandboxDownloadFailed;

  /// Error message for an unexpected failure of a privacy-preserving page capture. detail is the reason given by the server (may be English) or the fragment "unknown error".
  ///
  /// In en, this message translates to:
  /// **'Sandbox capture error: {detail}'**
  String mainApp_sandboxUnknownError(String detail);

  /// Error message when Firefox Sync of bookmarks, history or tabs fails and no more specific error is available.
  ///
  /// In en, this message translates to:
  /// **'Synchronization failed'**
  String get mainApp_syncFailed;

  /// Heading of the screen shown at app start when the user must choose which browser profile to open.
  ///
  /// In en, this message translates to:
  /// **'Choose a profile'**
  String get startup_pickerTitle;

  /// Line under the profile picker heading. contents is a lowercase list such as "tabs, history and settings".
  ///
  /// In en, this message translates to:
  /// **'Each profile keeps its own {contents}.'**
  String startup_pickerEachProfileKeepsOwn(String contents);

  /// Line under a profile in the startup picker: it is the one opened by default, and it requires authentication (such as fingerprint or device PIN) to open. Keep the "·" separator.
  ///
  /// In en, this message translates to:
  /// **'Opens by default · Locked'**
  String get startup_pickerOpensByDefaultLocked;

  /// Line under a profile in the startup picker: it is the one opened by default.
  ///
  /// In en, this message translates to:
  /// **'Opens by default'**
  String get startup_pickerOpensByDefault;

  /// Line under a profile in the startup picker: it requires authentication (such as fingerprint or device PIN) to open.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get startup_pickerLocked;

  /// Heading of the startup screen shown when a profile backup, restore or deletion from a previous session did not finish.
  ///
  /// In en, this message translates to:
  /// **'Unfinished profile work'**
  String get startup_haltMaintenanceTitle;

  /// Body of that startup screen. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'A backup, restore or deletion from an earlier run did not finish. WebLibre must finish it before any profile can open.'**
  String get startup_haltMaintenanceBody;

  /// Heading of the startup screen shown when the app cannot choose a profile yet and must restart.
  ///
  /// In en, this message translates to:
  /// **'Startup is not ready'**
  String get startup_haltUnavailableTitle;

  /// Body of that startup screen. reopenToContinue is the sentence "Close WebLibre and open it again."
  ///
  /// In en, this message translates to:
  /// **'WebLibre needs to restart before it can choose a profile. {reopenToContinue}'**
  String startup_haltUnavailableBody(String reopenToContinue);

  /// Heading of the startup screen shown when the chosen profile is still being used by a background task.
  ///
  /// In en, this message translates to:
  /// **'Profile is in use'**
  String get startup_haltProfileAccessBusyTitle;

  /// Body of that startup screen.
  ///
  /// In en, this message translates to:
  /// **'Another WebLibre task is still using this profile. Try again in a moment.'**
  String get startup_haltProfileAccessBusyBody;

  /// Heading of the startup screen shown when no browser profile can be opened or created.
  ///
  /// In en, this message translates to:
  /// **'No usable profile'**
  String get startup_haltNoProfileTitle;

  /// Body of that startup screen: probably a storage problem.
  ///
  /// In en, this message translates to:
  /// **'WebLibre could not read an existing profile or create a new one. Storage may be full or unavailable.'**
  String get startup_haltNoProfileBody;

  /// Heading of the startup screen shown when the app cannot safely decide which profile to open.
  ///
  /// In en, this message translates to:
  /// **'Cannot tell which profile to open'**
  String get startup_haltArbitrationFailedTitle;

  /// Body of that startup screen. reopenToContinue is the sentence "Close WebLibre and open it again."
  ///
  /// In en, this message translates to:
  /// **'WebLibre will not guess which profile to use. {reopenToContinue}'**
  String startup_haltArbitrationFailedBody(String reopenToContinue);

  /// Button on a startup problem screen that retries opening a profile.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get startup_tryAgain;

  /// Label of the retry button on a startup problem screen while the retry is running.
  ///
  /// In en, this message translates to:
  /// **'Trying again…'**
  String get startup_tryingAgain;

  /// Button on a startup problem screen that closes the app. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'Close WebLibre'**
  String get startup_closeWebLibre;

  /// Expandable section on a startup problem screen showing technical error details.
  ///
  /// In en, this message translates to:
  /// **'Technical details'**
  String get startup_technicalDetails;

  /// Button that copies the technical error details to the clipboard, e.g. for a bug report.
  ///
  /// In en, this message translates to:
  /// **'Copy details'**
  String get startup_copyDetails;

  /// Progress text on the profile maintenance screen while the app completes a backup, restore or deletion that was interrupted by a restart.
  ///
  /// In en, this message translates to:
  /// **'Finishing work interrupted by a previous restart…'**
  String get startup_maintenanceFinishingInterrupted;

  /// Reason shown when a pending profile task cannot be run: a newer app version created it.
  ///
  /// In en, this message translates to:
  /// **'This task was created by a newer version of WebLibre and cannot run here.'**
  String get startup_maintenanceNotRunnableUnsupported;

  /// Reason shown when a pending profile backup cannot be run: the folder to save it to is unknown.
  ///
  /// In en, this message translates to:
  /// **'This backup has no destination folder recorded.'**
  String get startup_maintenanceNotRunnableNoDestination;

  /// Reason shown when a pending profile restore cannot be run: the backup file to restore is unknown.
  ///
  /// In en, this message translates to:
  /// **'This restore has no backup file recorded.'**
  String get startup_maintenanceNotRunnableNoBackupFile;

  /// Reason shown when a pending restore cannot be run from the startup maintenance screen.
  ///
  /// In en, this message translates to:
  /// **'WebLibre cannot restore from this startup screen.'**
  String get startup_maintenanceNotRunnableRestoreHere;

  /// Reason shown when a pending profile deletion cannot be run from the startup maintenance screen.
  ///
  /// In en, this message translates to:
  /// **'WebLibre cannot delete a profile from this startup screen.'**
  String get startup_maintenanceNotRunnableDeleteHere;

  /// Result message after the app completed a profile restore that had been interrupted.
  ///
  /// In en, this message translates to:
  /// **'An interrupted restore was completed.'**
  String get startup_maintenanceRecoveredRestore;

  /// Result message after the app reversed an interrupted profile restore, leaving the profile unchanged.
  ///
  /// In en, this message translates to:
  /// **'An interrupted restore was undone. The profile was left as it was.'**
  String get startup_maintenanceRecoveredRestoreRolledBack;

  /// Result message after the app cleaned up an interrupted restore but cannot tell whether the backup ended up applied.
  ///
  /// In en, this message translates to:
  /// **'An interrupted restore was reconciled. Check the profile to see whether the backup was applied.'**
  String get startup_maintenanceRecoveredRestoreReconciled;

  /// Result message after the app completed a profile deletion that had been interrupted.
  ///
  /// In en, this message translates to:
  /// **'An interrupted deletion was completed.'**
  String get startup_maintenanceRecoveredDeletion;

  /// Generic result message when a profile backup, restore or deletion failed without a more specific reason.
  ///
  /// In en, this message translates to:
  /// **'It did not finish.'**
  String get startup_maintenanceTaskDidNotFinish;

  /// Error message when the profile task had to stop because another part of the app took over the profile. nothingChanged is "Nothing has been changed."; reopenToContinue is "Close WebLibre and open it again."
  ///
  /// In en, this message translates to:
  /// **'WebLibre can no longer safely work on this profile. {nothingChanged} {reopenToContinue}'**
  String startup_maintenanceLeaseLost(
    String nothingChanged,
    String reopenToContinue,
  );

  /// Result message after the user canceled a pending profile task. task is the task's title, e.g. 'Back up "Work"'.
  ///
  /// In en, this message translates to:
  /// **'{task} was canceled.'**
  String startup_maintenanceTaskCancelled(String task);

  /// Result message after the user discarded the leftover record of an interrupted profile task.
  ///
  /// In en, this message translates to:
  /// **'The interrupted record was discarded.'**
  String get startup_maintenanceEvidenceDiscarded;

  /// Result message after discarding that record, when saved profile data of unknown ownership was kept on the device.
  ///
  /// In en, this message translates to:
  /// **'The interrupted record was discarded. WebLibre could not tell which profile the saved data belonged to, so it kept the saved data on the device rather than removing it.'**
  String get startup_maintenanceEvidenceDiscardedKept;

  /// Error message when the entered password does not open the backup file. nothingChanged is "Nothing has been changed."
  ///
  /// In en, this message translates to:
  /// **'The password did not open this backup file. Check it and try again. {nothingChanged}'**
  String startup_maintenanceWrongPassword(String nothingChanged);

  /// Error message when the backup file could not be opened: wrong password or damaged file. nothingChanged is "Nothing has been changed."
  ///
  /// In en, this message translates to:
  /// **'The password did not open this backup file, or the file is damaged. Check the password and try again. {nothingChanged}'**
  String startup_maintenanceUnreadableArchive(String nothingChanged);

  /// Error message when the backup file is damaged. nothingChanged is "Nothing has been changed."
  ///
  /// In en, this message translates to:
  /// **'This backup file is damaged and could not be read. {nothingChanged}'**
  String startup_maintenanceDamagedArchive(String nothingChanged);

  /// Error message when the backup file comes from a newer app version. nothingChanged is "Nothing has been changed."
  ///
  /// In en, this message translates to:
  /// **'This backup file was created by a newer version of WebLibre and cannot be read here. {nothingChanged}'**
  String startup_maintenanceUnsupportedArchiveVersion(String nothingChanged);

  /// Error message when the device lacks space for a profile task. required and free are formatted sizes such as "1.2 GB"; nothingChanged is "Nothing has been changed."
  ///
  /// In en, this message translates to:
  /// **'There is not enough free space: this needs about {required}, but only {free} is available. {nothingChanged}'**
  String startup_maintenanceNotEnoughStorageWithFree(
    String required,
    String free,
    String nothingChanged,
  );

  /// Error message when the device lacks space for a profile task. required is a formatted size such as "1.2 GB"; nothingChanged is "Nothing has been changed."
  ///
  /// In en, this message translates to:
  /// **'There is not enough free space: this needs about {required}. {nothingChanged}'**
  String startup_maintenanceNotEnoughStorageKnown(
    String required,
    String nothingChanged,
  );

  /// Error message when the device lacks space for a profile task and the amounts are unknown. nothingChanged is "Nothing has been changed."
  ///
  /// In en, this message translates to:
  /// **'There is not enough free space to do this. {nothingChanged}'**
  String startup_maintenanceNotEnoughStorageUnknown(String nothingChanged);

  /// Error message when the backup file could not be written to the chosen folder (e.g. access to it was lost). nothingChanged is "Nothing has been changed."
  ///
  /// In en, this message translates to:
  /// **'The backup could not be written to the folder. Choose the folder again and retry. {nothingChanged}'**
  String startup_maintenanceBackupFolderUnavailable(String nothingChanged);

  /// Error message when a pending profile task refers to a profile that has since been deleted.
  ///
  /// In en, this message translates to:
  /// **'That profile no longer exists.'**
  String get startup_maintenanceProfileNoLongerExists;

  /// Error message when a restore cannot start because a record left by an earlier attempt still needs to be dealt with.
  ///
  /// In en, this message translates to:
  /// **'An earlier attempt at this restore left a record that has not been resolved yet.'**
  String get startup_maintenanceRestoreEvidenceUnresolved;

  /// Reason a backup file was rejected for restore: it belongs to a different profile than the one to be replaced.
  ///
  /// In en, this message translates to:
  /// **'This backup does not match the profile it was going to replace.'**
  String get startup_maintenanceRestoreWrongProfile;

  /// Fallback when the specific reason a backup was rejected is not known to this version.
  ///
  /// In en, this message translates to:
  /// **'This backup file cannot be restored.'**
  String get startup_maintenanceRestoreRejected;

  /// Reason a backup file was rejected for restore: parts of it are missing.
  ///
  /// In en, this message translates to:
  /// **'The backup file is incomplete.'**
  String get startup_maintenanceRestoreIncomplete;

  /// Reason a backup file was rejected for restore: it lacks the information describing the profile.
  ///
  /// In en, this message translates to:
  /// **'The backup file has no profile metadata.'**
  String get startup_maintenanceRestoreNoMetadata;

  /// Reason a backup file was rejected for restore: the information describing the profile is corrupt.
  ///
  /// In en, this message translates to:
  /// **'The backup file\'s profile metadata could not be read.'**
  String get startup_maintenanceRestoreMalformedMetadata;

  /// Reason a backup file was rejected for restore: it contains no profile data.
  ///
  /// In en, this message translates to:
  /// **'The backup file has no profile data.'**
  String get startup_maintenanceRestoreNoProfileData;

  /// Heading of the startup screen for pending profile backups, restores and deletions.
  ///
  /// In en, this message translates to:
  /// **'Profile maintenance'**
  String get startup_maintenanceHeadline;

  /// Line under the maintenance heading while a task is pending. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'This task must finish before any profile can open. WebLibre keeps the profile closed while it works.'**
  String get startup_maintenanceMustFinish;

  /// Line under the maintenance heading when all pending tasks are done.
  ///
  /// In en, this message translates to:
  /// **'Nothing is left to finish.'**
  String get startup_maintenanceNothingLeft;

  /// Line under the maintenance heading when interrupted work was found but its record is unreadable.
  ///
  /// In en, this message translates to:
  /// **'WebLibre found interrupted profile work, but cannot read its record.'**
  String get startup_maintenanceCannotReadRecord;

  /// Label of the password field for encrypting a new backup file or opening one to restore.
  ///
  /// In en, this message translates to:
  /// **'Backup file password'**
  String get startup_maintenancePasswordLabel;

  /// Error under the password field when the password does not open the backup file.
  ///
  /// In en, this message translates to:
  /// **'This password did not open the backup file'**
  String get startup_maintenancePasswordRejected;

  /// Help text under the empty password field when creating a backup: a password is required and cannot be recovered later.
  ///
  /// In en, this message translates to:
  /// **'Required. You need this to restore the backup, and it is not stored anywhere.'**
  String get startup_maintenancePasswordHelperRequiredBackup;

  /// Help text under the empty password field when restoring a backup: enter the password the backup was created with.
  ///
  /// In en, this message translates to:
  /// **'Required. Enter the password used to create this backup file.'**
  String get startup_maintenancePasswordHelperRequiredRestore;

  /// Help text under the password field when creating a backup: remember it, it is not stored.
  ///
  /// In en, this message translates to:
  /// **'You need this to restore the backup. It is not stored anywhere.'**
  String get startup_maintenancePasswordHelperBackup;

  /// Help text under the password field when restoring a backup.
  ///
  /// In en, this message translates to:
  /// **'The password this backup file was created with.'**
  String get startup_maintenancePasswordHelperRestore;

  /// Button that retries completing an interrupted profile task.
  ///
  /// In en, this message translates to:
  /// **'Try finishing it again'**
  String get startup_maintenanceTryFinishingAgain;

  /// Button that throws away the unreadable record of an interrupted task so the browser can open (asks for confirmation). Shown while a task is blocked.
  ///
  /// In en, this message translates to:
  /// **'Discard the record and continue'**
  String get startup_maintenanceDiscardAndContinueBlocked;

  /// Same button as the previous one, shown when no task is listed but an unreadable record remains. Same wording.
  ///
  /// In en, this message translates to:
  /// **'Discard the record and continue'**
  String get startup_maintenanceDiscardAndContinueNoTasks;

  /// Secondary button after a failed profile task: leave the maintenance screen and open the browser anyway. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'Open WebLibre'**
  String get startup_maintenanceOpenWebLibreRetry;

  /// Button after all profile tasks are done: continue into the browser. WebLibre is the app name.
  ///
  /// In en, this message translates to:
  /// **'Open WebLibre'**
  String get startup_maintenanceOpenWebLibre;

  /// Note under the progress text while a profile task runs.
  ///
  /// In en, this message translates to:
  /// **'This can take several minutes. Keep WebLibre open.'**
  String get startup_maintenanceTakesSeveralMinutes;

  /// Heading above the list of profile tasks queued after the current one.
  ///
  /// In en, this message translates to:
  /// **'Then, after this one'**
  String get startup_maintenanceThenAfterThisOne;

  /// Button that postpones the pending profile tasks and opens the browser.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get startup_maintenanceSkipForNow;

  /// Note on a task that was interrupted midway: it must be completed before any profile opens.
  ///
  /// In en, this message translates to:
  /// **'This was interrupted after it started. It must finish before any profile can open.'**
  String get startup_maintenanceInterruptedMustFinish;

  /// Note on an interrupted task whose completion attempt also failed.
  ///
  /// In en, this message translates to:
  /// **'This was interrupted after it started, and finishing it did not succeed. It cannot be started over until it has been finished.'**
  String get startup_maintenanceInterruptedFinishFailed;

  /// Note on an interrupted task whose record cannot be read.
  ///
  /// In en, this message translates to:
  /// **'This was interrupted after it started, and WebLibre cannot read what it was doing. It cannot be run again until that record is dealt with.'**
  String get startup_maintenanceInterruptedUnreadable;

  /// Title of the confirmation dialog before discarding the record of an interrupted profile task.
  ///
  /// In en, this message translates to:
  /// **'Discard the interrupted record?'**
  String get startup_maintenanceDiscardDialogTitle;

  /// Body of that dialog explaining what happens to data saved during an interrupted profile replacement. Keep the blank line (\n\n).
  ///
  /// In en, this message translates to:
  /// **'WebLibre cannot read what a backup, restore or deletion was doing when it stopped. Discarding the record lets the browser open again, but a profile that was being replaced may need to be checked afterward.\n\nIf the profile is missing, WebLibre restores the data it saved before replacing it. If the profile is present, WebLibre removes that saved data. If WebLibre cannot tell which profile the saved data belongs to, it keeps the data rather than removing it.'**
  String get startup_maintenanceDiscardDialogContent;

  /// Confirm button of that dialog.
  ///
  /// In en, this message translates to:
  /// **'Discard it'**
  String get startup_maintenanceDiscardIt;

  /// Button that starts a pending profile backup.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get startup_maintenanceBackupVerb;

  /// Button that retries a profile backup after it failed.
  ///
  /// In en, this message translates to:
  /// **'Try the backup again'**
  String get startup_maintenanceBackupRetry;

  /// Button that cancels a profile backup before it starts.
  ///
  /// In en, this message translates to:
  /// **'Cancel this backup'**
  String get startup_maintenanceBackupCancel;

  /// Title of a pending backup task, also inserted into "{task} was canceled.". profileName is the profile's name.
  ///
  /// In en, this message translates to:
  /// **'Back up \"{profileName}\"'**
  String startup_maintenanceBackupDescribe(String profileName);

  /// Explanation under a pending backup task. secretDataDescription is a lowercase list such as "WebLibre account sign-in, sync setup and proxy details".
  ///
  /// In en, this message translates to:
  /// **'Writes an encrypted backup file of this profile, including its {secretDataDescription}.'**
  String startup_maintenanceBackupConsequence(String secretDataDescription);

  /// Progress text while a backup is created. profileName is the profile's name.
  ///
  /// In en, this message translates to:
  /// **'Packing \"{profileName}\"…'**
  String startup_maintenanceBackupActivity(String profileName);

  /// Result message after a backup finished. profileName is the profile's name.
  ///
  /// In en, this message translates to:
  /// **'\"{profileName}\" was backed up to the folder you chose.'**
  String startup_maintenanceBackupDescribeDone(String profileName);

  /// Button that starts a pending restore that replaces an existing profile with a backup.
  ///
  /// In en, this message translates to:
  /// **'Replace now'**
  String get startup_maintenanceRestoreOverVerb;

  /// Button that retries a restore that replaces an existing profile after it failed.
  ///
  /// In en, this message translates to:
  /// **'Try the restore again'**
  String get startup_maintenanceRestoreOverRetry;

  /// Button that cancels a restore that replaces an existing profile before it starts.
  ///
  /// In en, this message translates to:
  /// **'Cancel this restore'**
  String get startup_maintenanceRestoreOverCancel;

  /// Title of a pending task that replaces a profile with a backup, also inserted into "{task} was canceled.". profileName is the profile's name.
  ///
  /// In en, this message translates to:
  /// **'Replace \"{profileName}\"'**
  String startup_maintenanceRestoreOverDescribe(String profileName);

  /// Explanation under a pending replace task where the profile also takes the backup's name. The placeholders are complete sentences: signedInFromBackup, olderBackupKeepsCredentials, and cannotBeUndone ("This cannot be undone.").
  ///
  /// In en, this message translates to:
  /// **'Replaces everything in this profile with the backup. {signedInFromBackup} {olderBackupKeepsCredentials} It also takes the backup\'s name. {cannotBeUndone}'**
  String startup_maintenanceRestoreOverConsequenceWithRename(
    String signedInFromBackup,
    String olderBackupKeepsCredentials,
    String cannotBeUndone,
  );

  /// Explanation under a pending replace task. The placeholders are complete sentences: signedInFromBackup, olderBackupKeepsCredentials, and cannotBeUndone ("This cannot be undone.").
  ///
  /// In en, this message translates to:
  /// **'Replaces everything in this profile with the backup. {signedInFromBackup} {olderBackupKeepsCredentials} {cannotBeUndone}'**
  String startup_maintenanceRestoreOverConsequencePlain(
    String signedInFromBackup,
    String olderBackupKeepsCredentials,
    String cannotBeUndone,
  );

  /// Progress text while a profile is replaced with a backup. profileName is the profile's name.
  ///
  /// In en, this message translates to:
  /// **'Replacing \"{profileName}\"…'**
  String startup_maintenanceRestoreOverActivity(String profileName);

  /// Result message after a profile was replaced with a backup. profileName is the profile's name.
  ///
  /// In en, this message translates to:
  /// **'\"{profileName}\" was replaced with the backup.'**
  String startup_maintenanceRestoreOverDescribeDone(String profileName);

  /// Button that starts a pending profile deletion.
  ///
  /// In en, this message translates to:
  /// **'Delete now'**
  String get startup_maintenanceDeleteVerb;

  /// Button that retries a profile deletion after it failed.
  ///
  /// In en, this message translates to:
  /// **'Try the deletion again'**
  String get startup_maintenanceDeleteRetry;

  /// Button that cancels a profile deletion before it starts.
  ///
  /// In en, this message translates to:
  /// **'Cancel this deletion'**
  String get startup_maintenanceDeleteCancel;

  /// Title of a pending deletion task, also inserted into "{task} was canceled.". profileName is the profile's name.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{profileName}\"'**
  String startup_maintenanceDeleteDescribe(String profileName);

  /// Explanation under a pending deletion task. profileDataDescription is a lowercase list such as "tabs, history, bookmarks, settings and saved site logins"; cannotBeUndone is "This cannot be undone."
  ///
  /// In en, this message translates to:
  /// **'Removes this profile and its {profileDataDescription}. {cannotBeUndone}'**
  String startup_maintenanceDeleteConsequence(
    String profileDataDescription,
    String cannotBeUndone,
  );

  /// Progress text while a profile is deleted. profileName is the profile's name.
  ///
  /// In en, this message translates to:
  /// **'Deleting \"{profileName}\"…'**
  String startup_maintenanceDeleteActivity(String profileName);

  /// Result message after a profile was deleted. profileName is the profile's name.
  ///
  /// In en, this message translates to:
  /// **'\"{profileName}\" was deleted.'**
  String startup_maintenanceDeleteDescribeDone(String profileName);

  /// Disabled button label for a restore-as-new-profile task that this screen cannot run.
  ///
  /// In en, this message translates to:
  /// **'Cannot run this'**
  String get startup_maintenanceRestoreCloneVerb;

  /// Button that retries a restore into a new profile after it failed.
  ///
  /// In en, this message translates to:
  /// **'Try the restore again'**
  String get startup_maintenanceRestoreCloneRetry;

  /// Button that cancels a restore into a new profile before it starts.
  ///
  /// In en, this message translates to:
  /// **'Cancel this restore'**
  String get startup_maintenanceRestoreCloneCancel;

  /// Title of a pending task that restores a backup as a new profile, also inserted into "{task} was canceled.". profileName is the profile's name.
  ///
  /// In en, this message translates to:
  /// **'Restore \"{profileName}\"'**
  String startup_maintenanceRestoreCloneDescribe(String profileName);

  /// Explanation under that task: it cannot run here.
  ///
  /// In en, this message translates to:
  /// **'This restore was created by a newer version of WebLibre and cannot run here.'**
  String get startup_maintenanceRestoreCloneConsequence;

  /// Progress text while a backup is restored as a new profile. profileName is the profile's name.
  ///
  /// In en, this message translates to:
  /// **'Restoring \"{profileName}\"…'**
  String startup_maintenanceRestoreCloneActivity(String profileName);

  /// Result message after a backup was restored as a new profile. profileName is the profile's name.
  ///
  /// In en, this message translates to:
  /// **'\"{profileName}\" was restored.'**
  String startup_maintenanceRestoreCloneDescribeDone(String profileName);

  /// Button label for a pending task of an unknown kind.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get startup_maintenanceUnknownVerb;

  /// Button that retries a task of a kind this version does not know after it failed.
  ///
  /// In en, this message translates to:
  /// **'Try the task again'**
  String get startup_maintenanceUnknownRetry;

  /// Button that cancels a task of a kind this version does not know before it starts.
  ///
  /// In en, this message translates to:
  /// **'Cancel this task'**
  String get startup_maintenanceUnknownCancel;

  /// Title of a pending task of an unknown kind. taskId is its technical identifier.
  ///
  /// In en, this message translates to:
  /// **'Unknown task {taskId}'**
  String startup_maintenanceUnknownDescribe(String taskId);

  /// Explanation under a task of an unknown kind: it was created by a newer app version.
  ///
  /// In en, this message translates to:
  /// **'This task was created by a newer version of WebLibre and cannot run.'**
  String get startup_maintenanceUnknownConsequence;

  /// Progress text while a task of an unknown kind runs.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get startup_maintenanceUnknownActivity;

  /// Result message after a task of an unknown kind finished.
  ///
  /// In en, this message translates to:
  /// **'Done.'**
  String get startup_maintenanceUnknownDescribeDone;

  /// A file or storage size in bytes, e.g. "512 B". value is the already formatted number. Use your language's usual unit symbol.
  ///
  /// In en, this message translates to:
  /// **'{value} B'**
  String units_bytes(String value);

  /// A file or storage size in kilobytes, e.g. "12.5 KB". value is the already formatted number. Use your language's usual unit symbol.
  ///
  /// In en, this message translates to:
  /// **'{value} KB'**
  String units_kilobytes(String value);

  /// A file or storage size in megabytes, e.g. "3.25 MB". value is the already formatted number. Use your language's usual unit symbol.
  ///
  /// In en, this message translates to:
  /// **'{value} MB'**
  String units_megabytes(String value);

  /// A duration in milliseconds, e.g. "300 ms" on a slider. value is the already formatted number. Use your language's usual unit symbol.
  ///
  /// In en, this message translates to:
  /// **'{value} ms'**
  String units_milliseconds(String value);

  /// Generic heading of an error panel shown in place of content that failed to load, when the caller gives no specific title. The error details appear below it.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get failureWidget_defaultTitle;

  /// Shown as the error details when a failure carries no message of its own.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get failureWidget_unknownError;

  /// Error message shown when the user taps the voice-input button but the device has no speech recognition service.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition is not available'**
  String get speechToTextButton_serviceNotAvailable;

  /// Validation error under a URL input field that was left empty but is required.
  ///
  /// In en, this message translates to:
  /// **'A URL is required'**
  String get formValidators_urlRequired;

  /// Validation error under a URL input field when the entered text is not a valid web address.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get formValidators_invalidUrl;

  /// Generic validation error under a required input field that was left empty.
  ///
  /// In en, this message translates to:
  /// **'Value required'**
  String get formValidators_valueRequired;

  /// Validation error under the profile name field when it was left empty.
  ///
  /// In en, this message translates to:
  /// **'Name required'**
  String get formValidators_nameRequired;

  /// Validation error under the profile name field when the name contains characters that are not allowed (such as brackets, quotes, slashes or punctuation).
  ///
  /// In en, this message translates to:
  /// **'Name contains invalid characters'**
  String get formValidators_nameInvalidCharacters;

  /// Short message at the bottom of the screen offering to search the current page for text the user typed or selected. query is that text, possibly shortened.
  ///
  /// In en, this message translates to:
  /// **'Find \"{query}\" on this page?'**
  String uiHelper_findInPageSuggestion(String query);

  /// Action button on the "Find … on this page?" message; starts searching the page for the text.
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get uiHelper_actionFind;

  /// Short message at the bottom of the screen after tabs sent from another device via sync were opened. count is the number of tabs.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Opened 1 tab from another device} other{Opened {count} tabs from another device}}'**
  String uiHelper_openedTabsFromAnotherDevice(int count);

  /// Short message after pressing the system Back button with no page history left: pressing Back once more closes the current tab. "BACK" refers to the Back button/gesture and is capitalized for emphasis.
  ///
  /// In en, this message translates to:
  /// **'Press BACK again to close the current tab'**
  String get uiHelper_navigateBackToCloseTab;

  /// Short message after pressing the system Back button with nothing left to go back to: pressing Back once more leaves the app. "BACK" refers to the Back button/gesture and is capitalized for emphasis.
  ///
  /// In en, this message translates to:
  /// **'Press BACK again to exit the app'**
  String get uiHelper_navigateBackToExitApp;

  /// Short message at the bottom of the screen after a link was opened in a new tab without switching to it. tabName is the page title.
  ///
  /// In en, this message translates to:
  /// **'New tab \'{tabName}\' opened in background'**
  String uiHelper_newTabOpenedInBackgroundNamed(String tabName);

  /// Short message at the bottom of the screen after a link was opened in a new tab without switching to it, when the page has no title yet.
  ///
  /// In en, this message translates to:
  /// **'New tab opened in background'**
  String get uiHelper_newTabOpenedInBackground;

  /// Action button on the "New tab opened in background" message; switches to that tab.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get uiHelper_actionShow;

  /// Short message at the bottom of the screen offering to open a web address found on the clipboard, with an Open button.
  ///
  /// In en, this message translates to:
  /// **'Open the link from your clipboard?'**
  String get uiHelper_wantToOpenLinkFromClipboard;

  /// Short message at the bottom of the screen after a new tab was created. tabName is the page title.
  ///
  /// In en, this message translates to:
  /// **'New tab \'{tabName}\' opened'**
  String uiHelper_newTabOpenedNamed(String tabName);

  /// Short message at the bottom of the screen after a new tab was created, when the page has no title yet.
  ///
  /// In en, this message translates to:
  /// **'New tab opened'**
  String get uiHelper_newTabOpened;

  /// Action button on the "New tab opened" message; switches to that tab.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get uiHelper_actionSwitch;

  /// Error message when a link could not be handed to another app. url is the full web address.
  ///
  /// In en, this message translates to:
  /// **'Could not launch URL ({url})'**
  String uiHelper_couldNotLaunchUrl(String url);

  /// Error message when a link uses a protocol no installed app can open. scheme is the protocol prefix of the link, e.g. "tel" or "market".
  ///
  /// In en, this message translates to:
  /// **'Cannot handle \"{scheme}\"'**
  String uiHelper_canNotHandleScheme(String scheme);

  /// Short message at the bottom of the screen after closing tabs, with an Undo button. count is the number of closed tabs.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Tab closed} other{{count} tabs closed}}'**
  String uiHelper_tabsClosedCount(int count);

  /// Title of the confirmation dialog before closing isolated tabs. Isolated tabs each keep their own temporary cookies and site data, which is deleted when they close.
  ///
  /// In en, this message translates to:
  /// **'Close isolated tabs?'**
  String get uiHelper_closeIsolatedTabsTitle;

  /// Body of the confirmation dialog before closing isolated tabs. count is the number of isolated sessions (groups of tabs sharing one temporary storage) whose data will be deleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This will permanently clear all browsing data for this isolated session.} other{This will permanently clear browsing data for {count} isolated sessions.}}'**
  String uiHelper_closeIsolatedTabsConfirm(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'id',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'id':
      return AppLocalizationsId();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
