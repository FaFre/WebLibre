/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:pigeon/pigeon.dart';

/// Translation options that map to the Gecko Translations Options.
///
/// @property downloadModel If the necessary models should be downloaded on request. If false, then
/// the translation will not complete and throw an exception if the models are not already available.
class TranslationOptions {
  final bool downloadModel;

  TranslationOptions({this.downloadModel = true});
}

/// Value type that represents the state of reader mode/view.
class ReaderState {
  /// Whether or not the current page can be transformed to
  /// be displayed in a reader view.
  final bool readerable;

  /// Whether or not reader view is active.
  final bool active;

  /// Whether or not a readerable check is required for the
  /// current page.
  final bool checkRequired;

  /// Whether or not a new connection to the reader view
  /// content script is required.
  final bool connectRequired;

  /// The base URL of the reader view extension page.
  final String? baseUrl;

  /// The URL of the page currently displayed in reader view.
  final String? activeUrl;

  /// The vertical scroll position of the page currently
  /// displayed in reader view.
  final int? scrollY;

  const ReaderState({
    this.readerable = false,
    this.active = false,
    this.checkRequired = false,
    this.connectRequired = false,
    this.baseUrl,
    this.activeUrl,
    this.scrollY,
  });
}

/// Parameters for adding a new tab.
class AddTabParams {
  final String url;
  final bool startLoading;
  final String? parentId;
  final LoadUrlFlagsValue flags;
  final String? contextId;
  final SourceValue source;
  final bool private;
  final HistoryMetadataKey? historyMetadata;
  final Map<String, String>? additionalHeaders;

  const AddTabParams({
    required this.url,
    required this.startLoading,
    this.parentId,
    required this.flags,
    this.contextId,
    required this.source,
    required this.private,
    this.historyMetadata,
    this.additionalHeaders,
  });
}

/// Details about the last playing media in this tab.
class LastMediaAccessState {
  /// [TabContentState.url] when media started playing.
  /// This is not the URL of the media but of the page when media started.
  /// Defaults to "" (an empty String) if media hasn't started playing.
  /// This value is only updated when media starts playing.
  /// Can be used as a backup to [mediaSessionActive] for knowing the user is still on the same website
  /// on which media was playing before media started playing in another tab.
  final String lastMediaUrl;

  /// The last time media started playing in the current web document.
  /// Defaults to [0] if media hasn't started playing.
  /// This value is only updated when media starts playing.
  final int lastMediaAccess;

  /// Whether or not the last accessed media is still active.
  /// Can be used as a backup to [lastMediaUrl] on websites which allow media to continue playing
  /// even when the users accesses another page (with another URL) in that same HTML document.
  final bool mediaSessionActive;

  const LastMediaAccessState({
    this.lastMediaUrl = "",
    this.lastMediaAccess = 0,
    this.mediaSessionActive = false,
  });
}

/// Represents a set of history metadata values that uniquely identify a record. Note that
/// when recording observations, the same set of values may or may not cause a new record to be
/// created, depending on the de-bouncing logic of the underlying storage i.e. recording history
/// metadata observations with the exact same values may be combined into a single record.
class HistoryMetadataKey {
  /// A url of the page.
  final String url;

  /// An optional search term if this record was
  /// created as part of a search by the user.
  final String? searchTerm;

  /// An optional url of the parent/referrer if
  /// this record was created in response to a user opening
  /// a page in a new tab.
  final String? referrerUrl;

  const HistoryMetadataKey({
    required this.url,
    this.searchTerm,
    this.referrerUrl,
  });
}

class PackageCategoryValue {
  final int value;

  const PackageCategoryValue(this.value);
}

/// Describes an external package.
class ExternalPackage {
  /// An Android package id.
  final String packageId;

  /// A [PackageCategory] as defined by the application.
  final PackageCategoryValue category;

  const ExternalPackage(this.packageId, this.category);
}

class LoadUrlFlagsValue {
  final int value;

  const LoadUrlFlagsValue(this.value);
}

class SourceValue {
  final int id;
  final ExternalPackage? caller;

  const SourceValue(this.id, this.caller);
}

/// A tab that is no longer open and in the list of tabs, but that can be restored (recovered) at
/// any time if it's combined with an [EngineSessionState] to form a [RecoverableTab].
///
/// The values of this data class are usually filled with the values of a [TabSessionState] when
/// getting closed.
class TabState {
  /// Unique ID identifying this tab.
  final String id;

  /// The last URL of this tab.
  final String url;

  /// The unique ID of the parent tab if this tab was opened from another tab (e.g. via
  /// the context menu).
  final String? parentId;

  /// The last title of this tab (or an empty String).
  final String title;

  /// The last used search terms, or an empty string if no
  /// search was executed for this session.
  final String searchTerm;

  /// The context ID ("container") this tab used (or null).
  final String? contextId;

  /// The last [ReaderState] of the tab.
  final ReaderState readerState;

  /// The last time this tab was selected.
  final int lastAccess;

  /// Timestamp of the tab's creation.
  final int createdAt;

  /// Details about the last time was playing in this tab.
  final LastMediaAccessState lastMediaAccessState;

  /// If tab was private.
  final bool private;

  /// The last [HistoryMetadataKey] of the tab.
  final HistoryMetadataKey? historyMetadata;

  /// The last [IconSource] of the tab.
  final SourceValue source;

  /// The index the tab should be restored at.
  final int index;

  /// Whether the tab has form data.
  final bool hasFormData;

  TabState({
    required this.id,
    required this.url,
    this.parentId,
    this.title = "",
    this.searchTerm = "",
    this.contextId,
    this.readerState = const ReaderState(),
    this.lastAccess = 0,
    this.createdAt = 0,
    this.lastMediaAccessState = const LastMediaAccessState(),
    this.private = false,
    this.historyMetadata,
    required this.source, //= Internal.none,
    this.index = -1,
    this.hasFormData = false,
  });
}

/// A recoverable version of [TabState].
class RecoverableTab {
  /// The [EngineSessionState] needed for restoring the previous state of this tab.
  final String? engineSessionStateJson;

  /// A [TabState] instance containing basic tab state.
  final TabState state;

  const RecoverableTab({this.engineSessionStateJson, required this.state});
}

/// A restored browser state, read from disk.
class RecoverableBrowserState {
  /// The list of restored tabs.
  final List<RecoverableTab?> tabs;

  /// The ID of the selected tab in [tabs]. Or `null` if no selection was restored.
  final String? selectedTabId;

  const RecoverableBrowserState({required this.tabs, this.selectedTabId});
}

/// Indicates what location the tabs should be restored at
enum RestoreLocation {
  /// Restore tabs at the beginning of the tab list
  beginning,

  /// Restore tabs at the end of the tab list
  end,

  /// Restore tabs at a specific index in the tab list
  atIndex,
}

/// An icon resource type.
enum IconType {
  favicon,
  appleTouchIcon,
  fluidIcon,
  imageSrc,
  openGraph,
  twitter,
  microsoftTile,
  tippyTop,
  manifestIcon,
}

/// Supported sizes.
///
/// We are trying to limit the supported sizes in order to optimize our caching strategy.
enum IconSize { defaultSize, launcher, launcherAdaptive }

/// A request to load an [Icon].
class IconRequest {
  final String url;
  final IconSize size;
  final List<Resource?> resources;
  final int? color;
  final bool isPrivate;
  final bool waitOnNetworkLoad;

  IconRequest({
    required this.url,
    this.size = IconSize.defaultSize,
    this.resources = const [],
    this.color,
    this.isPrivate = false,
    this.waitOnNetworkLoad = true,
  });
}

class ResourceSize {
  final int height;
  final int width;

  const ResourceSize({required this.height, required this.width});
}

/// An icon resource that can be loaded.
class Resource {
  final String url;
  final IconType type;
  final List<ResourceSize?> sizes;
  final String? mimeType;
  final bool maskable;

  Resource({
    required this.url,
    required this.type,
    this.sizes = const [],
    this.mimeType,
    this.maskable = false,
  });
}

/// An [Icon] returned by [BrowserIcons] after processing an [IconRequest]
class IconResult {
  /// The loaded icon as an [Uint8List].
  final Uint8List image;

  /// The dominant color of the icon. Will be null if no color could be extracted.
  final int? color;

  /// The source of the icon.
  final IconSource source;

  /// True if the icon represents as full-bleed icon that can be cropped to other shapes.
  final bool maskable;

  IconResult({
    required this.image,
    this.color,
    required this.source,
    this.maskable = false,
  });
}

/// The source of an [Icon].
enum IconSource {
  /// This icon was generated.
  generator,

  /// This icon was downloaded.
  download,

  /// This icon was inlined in the document.
  inline,

  /// This icon was loaded from an in-memory cache.
  memory,

  /// This icon was loaded from a disk cache.
  disk,
}

enum CookieSameSiteStatus { noRestriction, lax, strict, unspecified }

class CookiePartitionKey {
  final String topLevelSite;

  CookiePartitionKey(this.topLevelSite);
}

class Cookie {
  final String domain;
  final int? expirationDate;
  final String firstPartyDomain;
  final bool hostOnly;
  final bool httpOnly;
  final String name;
  final CookiePartitionKey? partitionKey;
  final String path;
  final bool secure;
  final bool session;
  final CookieSameSiteStatus sameSite;
  final String storeId;
  final String value;

  Cookie(
    this.domain,
    this.expirationDate,
    this.firstPartyDomain,
    this.hostOnly,
    this.httpOnly,
    this.name,
    this.partitionKey,
    this.path,
    this.secure,
    this.session,
    this.sameSite,
    this.storeId,
    this.value,
  );
}

enum VisitType {
  /// The user followed a link and got a new toplevel window.
  link,

  /// The user typed the page's URL in the URL bar or selected it from
  /// URL bar autocomplete results, clicked on it from a history query
  /// (from the History sidebar, History menu, or history query in the
  /// personal toolbar or Places organizer.
  typed,

  /// The user followed a bookmark to get to the page.
  bookmark,

  /// Some inner content is loaded. This is true of all images on a
  /// page, and the contents of the iframe. It is also true of any
  /// content in a frame if the user did not explicitly follow a link
  /// to get there.
  embed,

  /// Set when the transition was a permanent redirect.
  redirectPermanent,

  /// Set when the transition was a temporary redirect.
  redirectTemporary,

  /// Set when the transition is a download.
  download,

  /// The user followed a link and got a visit in a frame.
  framedLink,

  /// The user reloaded a page.
  reload,
}

class VisitInfo {
  final String url;
  final String? title;
  final int visitTime;
  final VisitType visitType;
  final String? previewImageUrl;
  final bool isRemote;

  final String? contentId;

  VisitInfo(
    this.url,
    this.title,
    this.visitTime,
    this.visitType,
    this.previewImageUrl,
    this.isRemote,
    this.contentId,
  );
}

class HistoryItem {
  final String url;
  final String title;

  HistoryItem(this.url, this.title);
}

class HistoryState {
  final List<HistoryItem?> items;
  final int currentIndex;

  final bool canGoBack;
  final bool canGoForward;

  HistoryState(
    this.items,
    this.currentIndex,
    this.canGoBack,
    this.canGoForward,
  );
}

class ReaderableState {
  /// Whether or not the current page can be transformed to
  /// be displayed in a reader view.
  final bool readerable;

  /// Whether or not reader view is active.
  final bool active;

  ReaderableState(this.readerable, this.active);
}

class SecurityInfoState {
  final bool secure;
  final String host;
  final String issuer;

  SecurityInfoState(this.secure, this.host, this.issuer);
}

class TabContentState {
  final String id;
  final String? parentId;
  final String? contextId;

  final String url;
  final String title;

  final int progress;

  final bool isPrivate;
  final bool isFullScreen;
  final bool isLoading;

  TabContentState(
    this.id,
    this.parentId,
    this.contextId,
    this.url,
    this.title,
    this.progress,
    this.isPrivate,
    this.isFullScreen,
    this.isLoading,
  );
}

class FindResultState {
  final int activeMatchOrdinal;
  final int numberOfMatches;
  final bool isDoneCounting;

  FindResultState(
    this.activeMatchOrdinal,
    this.numberOfMatches,
    this.isDoneCounting,
  );
}

enum SelectionPattern { phone, email }

class CustomSelectionAction {
  final String id;
  final String title;
  final SelectionPattern? pattern;

  CustomSelectionAction(this.id, this.title, this.pattern);
}

enum WebExtensionActionType { browser, page }

class WebExtensionData {
  final String extensionId;
  final String? title;
  final bool? enabled;
  final String? badgeText;
  final int? badgeTextColor;
  final int? badgeBackgroundColor;

  WebExtensionData(
    this.extensionId,
    this.title,
    this.enabled,
    this.badgeText,
    this.badgeTextColor,
    this.badgeBackgroundColor,
  );
}

enum GeckoSuggestionType { session, clipboard, history }

class GeckoSuggestion {
  final String id;
  final GeckoSuggestionType type;
  final int score;
  final String? title;
  final String? description;
  final String? editSuggestion;
  final Uint8List? icon;

  GeckoSuggestion(
    this.id,
    this.type,
    this.score,
    this.title,
    this.description,
    this.editSuggestion,
    this.icon,
  );
}

class TabContent {
  final String tabId;
  final String? fullContentMarkdown;
  final String? fullContentPlain;
  final bool isProbablyReaderable;
  final String? extractedContentMarkdown;
  final String? extractedContentPlain;

  TabContent(
    this.tabId,
    this.fullContentMarkdown,
    this.fullContentPlain,
    this.isProbablyReaderable,
    this.extractedContentMarkdown,
    this.extractedContentPlain,
  );
}

enum TrackingProtectionPolicy { none, recommended, strict, custom }

enum HttpsOnlyMode { disabled, privateOnly, enabled }

enum QueryParameterStripping { disabled, privateOnly, enabled }

enum BounceTrackingProtectionMode {
  /// Fully disabled.
  disabled,

  /// Fully enabled.
  enabled,

  /// Disabled, but collects user interaction data. Use this mode as the
  /// "disabled" state when the feature can be toggled on and off, e.g. via
  /// preferences.
  enabledStandby,

  /// Feature enabled, but tracker purging is only simulated. Used for
  /// testing and telemetry collection.
  enabledDryRun,
}

enum ColorScheme { system, light, dark }

enum CookieBannerHandlingMode { disabled, rejectAll, rejectOrAcceptAll }

enum WebContentIsolationStrategy {
  isolateNothing,
  isolateEverything,
  isolateHighValue,
}

/// Cookie blocking policy for Custom tracking protection mode.
/// Note: These only apply when blockCookies is true.
enum CustomCookiePolicy {
  /// Total Cookie Protection - Dynamic First-Party Isolation (dFPI)
  /// Most private option, isolates cookies per site
  totalProtection,

  /// Block cross-site and social media tracker cookies
  /// Allows most cookies but blocks tracking cookies
  crossSiteTrackers,

  /// Block cookies from sites you haven't visited
  /// Balances privacy with functionality
  unvisited,

  /// Block all third-party cookies
  /// Only allows first-party cookies
  thirdParty,

  /// Block all cookies (may break many sites)
  allCookies,
}

/// Scope for applying tracking protection features
enum TrackingScope {
  /// Apply to all browsing (normal + private)
  all,

  /// Apply only to private browsing tabs
  privateOnly,
}

class ContentBlocking {
  QueryParameterStripping queryParameterStripping;
  String queryParameterStrippingAllowList;
  String queryParameterStrippingStripList;
  BounceTrackingProtectionMode bounceTrackingProtectionMode;

  ContentBlocking(
    this.queryParameterStripping,
    this.queryParameterStrippingAllowList,
    this.queryParameterStrippingStripList,
    this.bounceTrackingProtectionMode,
  );
}

enum DohSettingsMode { geckoDefault, increased, max, off }

class DohSettings {
  final DohSettingsMode dohSettingsMode;
  final String dohProviderUrl;
  final String dohDefaultProviderUrl;
  final List<String> dohExceptionsList;

  DohSettings(
    this.dohSettingsMode,
    this.dohProviderUrl,
    this.dohDefaultProviderUrl,
    this.dohExceptionsList,
  );
}

class GeckoEngineSettings {
  final bool? javascriptEnabled;
  final TrackingProtectionPolicy? trackingProtectionPolicy;
  final HttpsOnlyMode? httpsOnlyMode;
  final bool? globalPrivacyControlEnabled;
  final ColorScheme? preferredColorScheme;
  final CookieBannerHandlingMode? cookieBannerHandlingMode;
  final CookieBannerHandlingMode? cookieBannerHandlingModePrivateBrowsing;
  final bool? cookieBannerHandlingGlobalRules;
  final bool? cookieBannerHandlingGlobalRulesSubFrames;
  final WebContentIsolationStrategy? webContentIsolationStrategy;
  final String? userAgent;
  final ContentBlocking? contentBlocking;
  final bool? enterpriseRootsEnabled;
  final DohSettings? dohSettings;
  final String? fingerprintingProtectionOverrides;
  final List<String>? locales;

  // Custom Tracking Protection Settings
  /// Master toggle for cookie blocking in Custom mode
  final bool? blockCookies;

  /// Cookie policy selection (only applies when blockCookies is true)
  final CustomCookiePolicy? customCookiePolicy;

  /// Block tracking scripts and content
  final bool? blockTrackingContent;

  /// Scope for tracking content blocking
  final TrackingScope? trackingContentScope;

  /// Block cryptomining scripts
  final bool? blockCryptominers;

  /// Block known fingerprinters (FINGERPRINTING tracking category)
  final bool? blockFingerprinters;

  /// Block redirect trackers via cookie purging
  final bool? blockRedirectTrackers;

  /// Block suspected fingerprinters (separate from FINGERPRINTING category)
  /// Controls GeckoView's fingerprintingProtection settings
  final bool? blockSuspectedFingerprinters;

  /// Scope for suspected fingerprinters blocking
  final TrackingScope? suspectedFingerprintersScope;

  /// Allow baseline tracking protection exceptions (prevents major site breakage)
  final bool? allowListBaseline;

  /// Allow convenience tracking protection exceptions (fixes minor issues)
  final bool? allowListConvenience;

  GeckoEngineSettings(
    this.javascriptEnabled,
    this.trackingProtectionPolicy,
    this.httpsOnlyMode,
    this.globalPrivacyControlEnabled,
    this.preferredColorScheme,
    this.cookieBannerHandlingMode,
    this.cookieBannerHandlingModePrivateBrowsing,
    this.cookieBannerHandlingGlobalRules,
    this.cookieBannerHandlingGlobalRulesSubFrames,
    this.webContentIsolationStrategy,
    this.userAgent,
    this.contentBlocking,
    this.enterpriseRootsEnabled,
    this.dohSettings,
    this.fingerprintingProtectionOverrides,
    this.locales,
    this.blockCookies,
    this.customCookiePolicy,
    this.blockTrackingContent,
    this.trackingContentScope,
    this.blockCryptominers,
    this.blockFingerprinters,
    this.blockRedirectTrackers,
    this.blockSuspectedFingerprinters,
    this.suspectedFingerprintersScope,
    this.allowListBaseline,
    this.allowListConvenience,
  );
}

class AutocompleteResult {
  final String input;
  final String text;
  final String url;
  final String source;
  final int totalItems;

  AutocompleteResult(
    this.input,
    this.text,
    this.url,
    this.source,
    this.totalItems,
  );
}

/// Represents all the different supported types of data that can be found from long clicking
/// an element.
sealed class HitResult {}

/// Default type if we're unable to match the type to anything. It may or may not have a src.
class UnknownHitResult extends HitResult {
  final String src;

  UnknownHitResult(this.src);
}

/// If the HTML element was of type 'HTMLImageElement'.
class ImageHitResult extends HitResult {
  final String src;
  final String? title;

  ImageHitResult(this.src, {this.title});
}

/// If the HTML element was of type 'HTMLVideoElement'.
class VideoHitResult extends HitResult {
  final String src;
  final String? title;

  VideoHitResult(this.src, {this.title});
}

/// If the HTML element was of type 'HTMLAudioElement'.
class AudioHitResult extends HitResult {
  final String src;
  final String? title;

  AudioHitResult(this.src, {this.title});
}

/// If the HTML element was of type 'HTMLImageElement' and contained a URI.
class ImageSrcHitResult extends HitResult {
  final String src;
  final String uri;

  ImageSrcHitResult(this.src, this.uri);
}

/// The type used if the URI is prepended with 'tel:'.
class PhoneHitResult extends HitResult {
  final String src;

  PhoneHitResult(this.src);
}

/// The type used if the URI is prepended with 'mailto:'.
class EmailHitResult extends HitResult {
  final String src;

  EmailHitResult(this.src);
}

/// The type used if the URI is prepended with 'geo:'.
class GeoHitResult extends HitResult {
  final String src;

  GeoHitResult(this.src);
}

/// Status that represents every state that a download can be in.
enum DownloadStatus {
  /// Indicates that the download is in the first state after creation but not yet [DOWNLOADING].
  initiated,

  /// Indicates that an [INITIATED] download is now actively being downloaded.
  downloading,

  /// Indicates that the download that has been [DOWNLOADING] has been paused.
  paused,

  /// Indicates that the download that has been [DOWNLOADING] has been cancelled.
  cancelled,

  /// Indicates that the download that has been [DOWNLOADING] has moved to failed because
  /// something unexpected has happened.
  failed,

  /// Indicates that the [DOWNLOADING] download has been completed.
  completed,
}

class DownloadState {
  final String url;
  final String? fileName;
  final String? contentType;
  final int? contentLength;
  final int? currentBytesCopied;
  final DownloadStatus? status;
  final String? userAgent;
  final String? destinationDirectory;
  final String? directoryPath;
  final String? referrerUrl;
  final bool? skipConfirmation;
  final bool? openInApp;
  final String? id;
  final String? sessionId;
  final bool? private;
  final int? createdTime;
  //final Response? response;
  final int? notificationId;

  DownloadState(
    this.url,
    this.fileName,
    this.contentType,
    this.contentLength,
    this.currentBytesCopied,
    this.status,
    this.userAgent,
    this.destinationDirectory,
    this.directoryPath,
    this.referrerUrl,
    this.skipConfirmation,
    this.openInApp,
    this.id,
    this.sessionId,
    this.private,
    this.createdTime,
    this.notificationId,
  );
}

class ShareInternetResourceState {
  final String url;
  final String? contentType;
  final bool private;
  // final Response? response ;
  final String? referrerUrl;

  ShareInternetResourceState(
    this.url,
    this.contentType,
    this.private,
    this.referrerUrl,
  );
}

enum LogLevel { debug, info, warn, error }

class AddonCollection {
  final String serverURL;
  final String collectionUser;
  final String collectionName;

  AddonCollection({
    required this.serverURL,
    required this.collectionUser,
    required this.collectionName,
  });
}

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/gecko.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/pigeons/Gecko.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'eu.weblibre.flutter_mozilla_components.pigeons',
    ),
    dartPackageName: 'flutter_mozilla_components',
  ),
)
@HostApi()
abstract class GeckoBrowserApi {
  String getGeckoVersion();
  void initialize(
    String profileFolder,
    LogLevel logLevel,
    ContentBlocking contentBlocking,
    AddonCollection? addonCollection,
  );
  bool showNativeFragment();
  void onTrimMemory(int level);
}

@HostApi()
abstract class GeckoEngineSettingsApi {
  void setDefaultSettings(GeckoEngineSettings settings);
  void updateRuntimeSettings(GeckoEngineSettings settings);
  void setPullToRefreshEnabled(bool enabled);
}

@HostApi()
abstract class GeckoSessionApi {
  void loadUrl({
    required String? tabId, //If null = current tab
    required String url,
    required LoadUrlFlagsValue flags, //== LoadUrlFlagsBuilder.NONE,
    required Map<String, String>? additionalHeaders,
  });

  void loadData({
    required String? tabId, //If null = current tab
    required String data,
    required String mimeType,
    required String encoding,
  });

  void reload({
    required String? tabId, //If null = current tab
    required LoadUrlFlagsValue flags, //== LoadUrlFlagsBuilder.NONE,
  });

  void stopLoading({
    required String? tabId, //If null = current tab
  });

  void goBack({
    required String? tabId, //If null = current tab
    required bool userInteraction,
  });

  void goForward({
    required String? tabId, //If null = current tab
    required bool userInteraction,
  });

  void goToHistoryIndex({
    required int index,
    required String? tabId, //If null = current tab
  });

  void requestDesktopSite({
    required String? tabId, //If null = current tab
    required bool enable,
  });

  void exitFullscreen({
    required String? tabId, //If null = current tab
  });

  void saveToPdf({
    required String? tabId, //If null = current tab
  });

  void printContent({
    required String? tabId, //If null = current tab
  });

  void translate({
    required String? tabId, //If null = current tab
    required String fromLanguage,
    required String toLanguage,
    required TranslationOptions? options,
  });

  void translateRestore({
    required String? tabId, //If null = current tab
  });

  void crashRecovery({required List<String>? tabIds});

  void purgeHistory();

  void updateLastAccess({
    required String? tabId, //If null = current tab
    required int? lastAccess, //If null datetime.now
  });

  @async
  Uint8List? requestScreenshot(bool sendBack);
}

@HostApi()
abstract class GeckoTabsApi {
  void syncEvents({
    required bool onSelectedTabChange,
    required bool onTabListChange,
    required bool onTabContentStateChange,
    required bool onIconChange,
    required bool onSecurityInfoStateChange,
    required bool onReaderableStateChange,
    required bool onHistoryStateChange,
    required bool onFindResults,
    required bool onThumbnailChange,
  });

  void selectTab({required String tabId});

  void removeTab({required String tabId});

  String addTab({
    required String url,
    required bool selectTab,
    required bool startLoading,
    required String? parentId,
    required LoadUrlFlagsValue flags,
    required String? contextId,
    //engineSession: EngineSession? = null,
    required SourceValue source, //Internal.NewTab
    //searchTerms: String = "",
    required bool private,
    required HistoryMetadataKey? historyMetadata,
    //isSearch: Boolean = false,
    //searchEngineName: String? = null,
    required Map<String, String>? additionalHeaders,
  });

  List<String> addMultipleTabs({
    required List<AddTabParams> tabs,
    required String? selectTabId,
  });

  void removeAllTabs({required bool recoverable});

  void removeTabs({required List<String> ids});

  void removeNormalTabs();

  void removePrivateTabs();

  void undo();

  //restoreTabs invokes splitted
  void restoreTabsByList({
    required List<RecoverableTab> tabs,
    required String? selectTabId,
    required RestoreLocation restoreLocation,
  });
  void restoreTabsByBrowserState({
    required RecoverableBrowserState state,
    required RestoreLocation restoreLocation,
  });
  //The calls with engin storage for restore are not supported at the moment

  //selectOrAddTab invokes splitted
  /// Selects an already existing tab with the matching [HistoryMetadataKey] or otherwise
  /// creates a new tab with the given [url].
  String selectOrAddTabByHistory({
    required String url,
    required HistoryMetadataKey historyMetadata,
  });

  /// Selects an already existing tab displaying [url] or otherwise creates a new tab.
  String selectOrAddTabByUrl({
    required String url,
    required bool private,
    required SourceValue source, // = Internal.newTab,
    required LoadUrlFlagsValue flags,
    required bool ignoreFragment,
  });

  String duplicateTab({
    required String? selectTabId,
    required bool selectNewTab,
    required String? newContextId,
  });

  void moveTabs({
    required List<String> tabIds,
    required String targetTabId,
    required bool placeAfter,
  });

  String migratePrivateTabUseCase({
    required String tabId,
    required String? alternativeUrl,
  });
}

@HostApi()
abstract class GeckoFindApi {
  void findAll(String? tabId, String text);
  void findNext(String? tabId, bool forward);
  void clearMatches(String? tabId);
}

@HostApi()
abstract class GeckoIconsApi {
  @async
  IconResult loadIcon(IconRequest request);
}

class GeckoPref {
  final String name;
  final Object? value;
  final Object? defaultValue;
  final Object? userValue;
  final bool hasUserChangedValue;

  GeckoPref(
    this.name,
    this.value,
    this.defaultValue,
    this.userValue,
    this.hasUserChangedValue,
  );
}

@HostApi()
abstract class GeckoPrefApi {
  @async
  List<String> getPrefList();
  @async
  Map<String, GeckoPref> getPrefs(List<String> preferenceFilter);
  @async
  Map<String, GeckoPref> applyPrefs(Map<String, Object> prefs);
  @async
  void resetPrefs(List<String> preferenceNames);

  void startObserveChanges();
  void stopObserveChanges();
  @async
  void registerPrefForObservation(String name);
  @async
  void unregisterPrefForObservation(String name);
}

/// Type of ML model operation
enum MlProgressType { downloading, loadingFromCache, runningInference }

/// Status of the ML operation
enum MlProgressStatus { initiate, sizeEstimate, inProgress, done }

/// Progress information for ML model operations
class MlProgressData {
  /// The type of ML model being loaded
  final String modelType;

  /// Percentage of completion (0-100)
  final double progress;

  /// Type of operation (download, cache load, or inference)
  final MlProgressType type;

  /// Current status of the operation
  final MlProgressStatus status;

  /// Total bytes loaded so far
  final int totalLoaded;

  /// Bytes loaded in current update
  final int currentLoaded;

  /// Total size estimate
  final int total;

  /// Units of measurement (e.g., "bytes")
  final String units;

  /// Whether the operation completed successfully
  final bool ok;

  /// Unique identifier for this operation
  final String? id;

  const MlProgressData({
    required this.modelType,
    required this.progress,
    required this.type,
    required this.status,
    required this.totalLoaded,
    required this.currentLoaded,
    required this.total,
    required this.units,
    required this.ok,
    this.id,
  });
}

@HostApi()
abstract class GeckoMlApi {
  @async
  String predictDocumentTopic(List<String> documents);
  @async
  List generateDocumentEmbeddings(List<String> documents);
}

@HostApi()
abstract class GeckoBrowserExtensionApi {
  @async
  List<Object> getMarkdown(List<String> htmlList);
}

@HostApi()
abstract class GeckoContainerProxyApi {
  void setProxyPort(int port);
  void addContainerProxy(String contextId);
  void removeContainerProxy(String contextId);
  void setSiteAssignments(Map<String, String> assignments);

  @async
  bool healthcheck();
}

@HostApi()
abstract class GeckoCookieApi {
  @async
  Cookie getCookie(
    String? firstPartyDomain,
    String name,
    CookiePartitionKey? partitionKey,
    String? storeId,
    String url,
  );

  @async
  List<Cookie> getAllCookies(
    String? domain,
    String? firstPartyDomain,
    String? name,
    CookiePartitionKey? partitionKey,
    String? storeId,
    String url,
  );

  @async
  void setCookie(
    String? domain,
    int? expirationDate,
    String? firstPartyDomain,
    bool? httpOnly,
    String? name,
    CookiePartitionKey? partitionKey,
    String? path,
    CookieSameSiteStatus? sameSite,
    bool? secure,
    String? storeId,
    String url,
    String? value,
  );

  @async
  void removeCookie(
    String? firstPartyDomain,
    String name,
    CookiePartitionKey? partitionKey,
    String? storeId,
    String url,
  );
}

class ContainerSiteAssignment {
  final String requestId;
  final String? tabId;
  final String? originUrl;
  final String url;
  final bool blocked;

  ContainerSiteAssignment({
    required this.requestId,
    required this.tabId,
    required this.originUrl,
    required this.url,
    required this.blocked,
  });
}

@FlutterApi()
abstract class GeckoStateEvents {
  void onViewReadyStateChange(int timestamp, bool state);
  void onEngineReadyStateChange(int timestamp, bool state);
  void onIconUpdate(int timestamp, String url, Uint8List bytes);

  void onTabAdded(int timestamp, String tabId);

  void onTabListChange(int timestamp, List<String> tabIds);
  void onSelectedTabChange(int timestamp, String? id);

  void onTabContentStateChange(int timestamp, TabContentState state);
  void onHistoryStateChange(int timestamp, String id, HistoryState state);
  void onReaderableStateChange(int timestamp, String id, ReaderableState state);
  void onSecurityInfoStateChange(
    int timestamp,
    String id,
    SecurityInfoState state,
  );
  void onIconChange(int timestamp, String id, Uint8List? bytes);
  void onThumbnailChange(int timestamp, String id, Uint8List? bytes);

  void onFindResults(int timestamp, String id, List<FindResultState> results);
  void onLongPress(int timestamp, String id, HitResult hitResult);

  // void onScrollChange(int timestamp, String tabId, int scrollY);
  void onPreferenceChange(int timestamp, GeckoPref value);

  void onContainerSiteAssignment(
    int timestamp,
    ContainerSiteAssignment details,
  );

  void onMlProgress(int timestamp, MlProgressData progress);
}

@FlutterApi()
abstract class GeckoLogging {
  void onLog(LogLevel level, String message);
}

@HostApi()
abstract class ReaderViewEvents {
  void onToggleReaderView(bool enable);
  void onAppearanceButtonTap();
}

@FlutterApi()
abstract class ReaderViewController {
  void appearanceButtonVisibility(int timestamp, bool visible);
}

@HostApi()
abstract class GeckoSelectionActionController {
  void setActions(List<CustomSelectionAction> actions);
}

@FlutterApi()
abstract class GeckoSelectionActionEvents {
  void performSelectionAction(String id, String selectedText);
}

@HostApi()
abstract class GeckoAddonsApi {
  void startAddonManagerActivity();

  void invokeAddonAction(String extensionId, WebExtensionActionType actionType);

  @async
  void installAddon(String url);
}

@FlutterApi()
abstract class GeckoAddonEvents {
  void onUpsertWebExtensionAction(
    int timestamp,
    String extensionId,
    WebExtensionActionType actionType,
    WebExtensionData extensionData,
  );

  void onRemoveWebExtensionAction(
    int timestamp,
    String extensionId,
    WebExtensionActionType actionType,
  );

  void onUpdateWebExtensionIcon(
    int timestamp,
    String extensionId,
    WebExtensionActionType actionType,
    Uint8List icon,
  );
}

@HostApi()
abstract class GeckoSuggestionApi {
  @async
  AutocompleteResult? getAutocompleteSuggestion(String query);
  void querySuggestions(String text, List<GeckoSuggestionType> providers);
}

@FlutterApi()
abstract class GeckoSuggestionEvents {
  void onSuggestionResult(
    int timestamp,
    GeckoSuggestionType suggestionType,
    List<GeckoSuggestion> suggestions,
  );
}

@FlutterApi()
abstract class GeckoTabContentEvents {
  void onContentUpdate(int timestamp, TabContent content);
}

@HostApi()
abstract class GeckoDeleteBrowsingDataController {
  @async
  void deleteTabs();
  @async
  void deleteBrowsingHistory();
  @async
  void deleteCookiesAndSiteData();
  @async
  void deleteCachedFiles();
  @async
  void deleteSitePermissions();
  @async
  void deleteDownloads();

  @async
  void clearDataForSessionContext(String contextId);

  /// Clear browsing data for a specific host/domain
  @async
  void clearDataForHost(String host, List<ClearDataType> dataTypes);
}

/// Types of browsing data that can be cleared
enum ClearDataType {
  /// Authentication sessions
  authSessions,

  /// All site data (cookies, storage, etc.)
  allSiteData,

  /// Cookies only
  cookies,

  /// Cache only
  allCaches,
}

@HostApi()
abstract class GeckoHistoryApi {
  @async
  List<VisitInfo> getDetailedVisits(
    int startMillis,
    int endMillis,
    List<VisitType> excludeTypes,
  );

  @async
  List<VisitInfo> getVisitsPaginated(
    int offset,
    int count,
    List<VisitType> excludeTypes,
  );

  @async
  void deleteVisit(String url, int timestamp);

  @async
  void deleteDownload(String id);

  @async
  void deleteVisitsBetween(int startMillis, int endMillis);
}

@HostApi()
abstract class GeckoDownloadsApi {
  void requestDownload(String tabId, DownloadState state);
  void copyInternetResource(String tabId, ShareInternetResourceState state);
  void shareInternetResource(String tabId, ShareInternetResourceState state);
}

@FlutterApi()
abstract class BrowserExtensionEvents {
  void onFeedRequested(int timestamp, String url);
}

class GeckoHeader {
  final String key;
  final String value;

  GeckoHeader({required this.key, required this.value});
}

enum GeckoFetchMethod { get, head, post, put, delete, connect, options, trace }

enum GeckoFetchRedircet { follow, manual }

enum GeckoFetchCookiePolicy { include, omit }

class GeckoFetchRequest {
  final String url;
  final GeckoFetchMethod method;
  final List<GeckoHeader> headers;
  final int? connectTimeoutMillis;
  final int? readTimeoutMillis;
  final String? body;
  final GeckoFetchRedircet redirect;
  final GeckoFetchCookiePolicy cookiePolicy;
  final bool useCaches;
  final bool private;
  final bool useOhttp;
  final String? referrerUrl;
  final bool conservative;

  GeckoFetchRequest({
    required this.url,
    required this.method,
    required this.headers,
    required this.connectTimeoutMillis,
    required this.readTimeoutMillis,
    required this.body,
    required this.redirect,
    required this.cookiePolicy,
    required this.useCaches,
    required this.private,
    required this.useOhttp,
    required this.referrerUrl,
    required this.conservative,
  });
}

class GeckoFetchResponse {
  final String url;
  final int status;
  final List<GeckoHeader> headers;
  final Uint8List body;

  GeckoFetchResponse({
    required this.url,
    required this.status,
    required this.headers,
    required this.body,
  });
}

@HostApi()
abstract class GeckoFetchApi {
  @async
  GeckoFetchResponse fetch(GeckoFetchRequest request);
}

enum BookmarkNodeType { item, folder, separator }

class BookmarkNode {
  final BookmarkNodeType type;
  final String guid;
  final String? parentGuid;
  final int? position;
  final String? title;
  final String? url;
  final int dateAdded;
  final int lastModified;
  final List<BookmarkNode>? children;

  BookmarkNode({
    required this.type,
    required this.guid,
    required this.parentGuid,
    required this.position,
    required this.title,
    required this.url,
    required this.dateAdded,
    required this.lastModified,
    required this.children,
  });
}

/// Class for making alterations to any bookmark node
class BookmarkInfo {
  final String? parentGuid;
  final int? position;
  final String? title;
  final String? url;

  BookmarkInfo({
    required this.parentGuid,
    required this.position,
    required this.title,
    required this.url,
  });
}

// =============================================================================
// Viewport & Dynamic Toolbar APIs
// =============================================================================

/// Controls GeckoView's viewport behavior for dynamic toolbar and keyboard handling.
///
/// This API allows Flutter to control how GeckoView adjusts its internal viewport
/// without resizing the platform view itself, avoiding visual flickering.
///
/// The dynamic toolbar system works by:
/// 1. Setting the maximum toolbar height via [setDynamicToolbarMaxHeight]
/// 2. Updating the vertical clipping as toolbar animates via [setVerticalClipping]
/// 3. GeckoView internally adjusts viewport and notifies the website
@HostApi()
abstract class GeckoViewportApi {
  /// Sets the maximum height that dynamic toolbars (top + bottom) can occupy.
  ///
  /// GeckoView will adjust its internal viewport calculations to account for
  /// this space. The website will receive proper viewport dimensions through
  /// standard web APIs (CSS viewport units, window.innerHeight).
  ///
  /// Call this once when toolbar dimensions are known, and again if they change.
  ///
  /// [heightPx] Combined height of top and bottom toolbars in pixels.
  void setDynamicToolbarMaxHeight(int heightPx);

  /// Sets the vertical clipping offset for the GeckoView content.
  ///
  /// Use this as the toolbar animates to clip content at the bottom.
  /// Negative values clip from the bottom (for bottom toolbar sliding up).
  /// Positive values clip from the top (for top toolbar sliding down).
  ///
  /// Call this during toolbar animation frames to smoothly adjust the visible area.
  ///
  /// [clippingPx] The clipping offset in pixels. Negative = bottom clip.
  void setVerticalClipping(int clippingPx);
}

/// Events from native side about viewport and input-related changes.
///
/// These events allow Flutter to react to native viewport changes,
/// particularly keyboard visibility which is detected natively.
@FlutterApi()
abstract class GeckoViewportEvents {
  /// Called when keyboard visibility changes.
  ///
  /// This is detected natively using WindowInsets API and provides
  /// accurate keyboard height information.
  ///
  /// [timestamp] Event timestamp for ordering.
  /// [heightPx] Keyboard height in pixels (0 when hidden).
  /// [isVisible] Whether the keyboard is currently visible.
  /// [isAnimating] Whether the keyboard is currently animating.
  void onKeyboardVisibilityChanged(
    int timestamp,
    int heightPx,
    bool isVisible,
    bool isAnimating,
  );
}

// =============================================================================
// Bookmarks API
// =============================================================================

@HostApi()
abstract class GeckoBookmarksApi {
  /// Produces a bookmarks tree for the given guid string.
  ///
  /// @param guid The bookmark guid to obtain.
  /// @param recursive Whether to recurse and obtain all levels of children.
  /// @return The populated root starting from the guid.
  @async
  BookmarkNode? getTree(String guid, bool recursive);

  /// Obtains the details of a bookmark without children, if one exists with that guid. Otherwise, null.
  ///
  /// @param guid The bookmark guid to obtain.
  /// @return The bookmark node or null if it does not exist.
  @async
  BookmarkNode? getBookmark(String guid);

  /// Produces a list of all bookmarks with the given URL.
  ///
  /// @param url The URL string.
  /// @return The list of bookmarks that match the URL
  @async
  List<BookmarkNode> getBookmarksWithUrl(String url);

  /// Produces a list of the most recently added bookmarks.
  ///
  /// @param limit The maximum number of entries to return.
  /// @param maxAge Optional parameter used to filter out entries older than this number of milliseconds.
  /// @param currentTime Optional parameter for current time. Defaults toSystem.currentTimeMillis()
  /// @return The list of bookmarks that have been recently added up to the limit number of items.
  @async
  List<BookmarkNode> getRecentBookmarks(
    int limit,
    int? maxAge,
    int currentTime,
  );

  /// Searches bookmarks with a query string.
  ///
  /// @param query The query string to search.
  /// @param limit The maximum number of entries to return.
  /// @return The list of matching bookmark nodes up to the limit number of items.
  @async
  List<BookmarkNode> searchBookmarks(String query, int limit);

  /// Adds a new bookmark item to a given node.
  ///
  /// Sync behavior: will add new bookmark item to remote devices.
  ///
  /// @param parentGuid The parent guid of the new node.
  /// @param url The URL of the bookmark item to add.
  /// @param title The title of the bookmark item to add.
  /// @param position The optional position to add the new node or null to append.
  /// @return The guid of the newly inserted bookmark item.
  @async
  String addItem(String parentGuid, String url, String title, int? position);

  /// Adds a new bookmark folder to a given node.
  ///
  /// Sync behavior: will add new separator to remote devices.
  ///
  /// @param parentGuid The parent guid of the new node.
  /// @param title The title of the bookmark folder to add.
  /// @param position The optional position to add the new node or null to append.
  /// @return The guid of the newly inserted bookmark item.
  @async
  String addFolder(String parentGuid, String title, int? position);

  /// Edits the properties of an existing bookmark item and/or moves an existing one underneath a new parent guid.
  ///
  /// Sync behavior: will alter bookmark item on remote devices.
  ///
  /// @param guid The guid of the item to update.
  /// @param info The info to change in the bookmark.
  @async
  void updateNode(String guid, BookmarkInfo info);

  /// Deletes a bookmark node and all of its children, if any.
  ///
  /// Sync behavior: will remove bookmark from remote devices.
  ///
  /// @return Whether the bookmark existed or not.
  @async
  bool deleteNode(String guid);
}

// =============================================================================
// Site Permissions API
// =============================================================================

/// Permission status for a site permission
enum SitePermissionStatus {
  /// Permission has been granted
  allowed,

  /// Permission has been denied
  blocked,

  /// No decision has been made yet (ask to allow)
  noDecision,
}

/// Autoplay permission values (matches Fenix's 4 states)
enum AutoplayStatus {
  /// Allow all autoplay (audible and inaudible)
  allowed,

  /// Block all autoplay
  blocked,

  /// Block audible autoplay only (allow inaudible)
  blockAudible,

  /// Allow autoplay on WiFi only
  allowOnWifi,
}

/// Site permissions data structure
class SitePermissions {
  final String origin;
  final SitePermissionStatus? camera;
  final SitePermissionStatus? microphone;
  final SitePermissionStatus? location;
  final SitePermissionStatus? notification;
  final SitePermissionStatus? persistentStorage;
  final SitePermissionStatus? crossOriginStorageAccess;
  final SitePermissionStatus? mediaKeySystemAccess;
  final SitePermissionStatus? localDeviceAccess;
  final SitePermissionStatus? localNetworkAccess;
  final AutoplayStatus? autoplayAudible;
  final AutoplayStatus? autoplayInaudible;
  final int savedAt;

  SitePermissions({
    required this.origin,
    this.camera,
    this.microphone,
    this.location,
    this.notification,
    this.persistentStorage,
    this.crossOriginStorageAccess,
    this.mediaKeySystemAccess,
    this.localDeviceAccess,
    this.localNetworkAccess,
    this.autoplayAudible,
    this.autoplayInaudible,
    this.savedAt = 0,
  });
}

/// API for managing site permissions stored in GeckoView
@HostApi()
abstract class GeckoSitePermissionsApi {
  /// Get permissions for origin (single source of truth from GeckoView)
  @async
  SitePermissions? getSitePermissions(String origin, bool private);

  /// Save/update permissions (persisted by GeckoView)
  @async
  void setSitePermissions(SitePermissions permissions, bool private);

  /// Delete permissions for origin (removed from GeckoView storage)
  @async
  void deleteSitePermissions(String origin, bool private);
}

// =============================================================================
// Public Suffix List API
// =============================================================================

/// Native wrapper for Mozilla's Public Suffix List
@HostApi()
abstract class GeckoPublicSuffixListApi {
  /// Get base domain (eTLD+1) from host using Mozilla's Public Suffix List
  /// Returns the host unchanged if PSL lookup fails
  @async
  String getPublicSuffixPlusOne(String host);
}

/// Tracking protection exception for a site
///
/// This represents a site that has been added to the exceptions list,
/// meaning tracking protection is disabled for this specific site.
class TrackingProtectionException {
  final String url;

  TrackingProtectionException({required this.url});
}

/// API for managing per-site tracking protection exceptions
///
/// This API wraps Mozilla Android Components' TrackingProtectionUseCases
/// to allow Flutter code to add/remove/check tracking protection exceptions
/// on a per-site basis.
@HostApi()
abstract class GeckoTrackingProtectionApi {
  /// Check if a tab has a tracking protection exception
  ///
  /// Uses callback pattern to match Mozilla Android Components API.
  /// Returns true if the site is in the exceptions list (ETP disabled).
  @async
  bool containsException(String tabId);

  /// Add tracking protection exception for a tab (disable ETP for this site)
  ///
  /// This adds the current tab's URL to the exceptions list.
  /// ETP will be disabled for this site until the exception is removed.
  void addException(String tabId);

  /// Remove tracking protection exception for a tab (enable ETP for this site)
  ///
  /// This removes the current tab's URL from the exceptions list.
  /// ETP will be re-enabled for this site.
  void removeException(String tabId);

  /// Remove a specific exception by URL
  ///
  /// Alternative to removeException(tabId) for cases where you
  /// have a URL rather than a tabId.
  @async
  void removeExceptionByUrl(String url);

  /// Fetch all tracking protection exceptions
  ///
  /// Returns list of all sites that have exceptions (ETP disabled).
  @async
  List<TrackingProtectionException> fetchExceptions();

  /// Remove all tracking protection exceptions
  ///
  /// This re-enables ETP for all exception sites.
  @async
  void removeAllExceptions();
}
