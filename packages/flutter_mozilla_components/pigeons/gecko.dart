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
  final String? contextId;

  final String url;
  final String title;

  final int progress;

  final bool isPrivate;
  final bool isFullScreen;
  final bool isLoading;

  TabContentState(
    this.id,
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

enum ColorScheme { system, light, dark }

enum CookieBannerHandlingMode { disabled, rejectAll, rejectOrAcceptAll }

enum WebContentIsolationStrategy {
  isolateNothing,
  isolateEverything,
  isolateHighValue,
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

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/gecko.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/eu/lensai/flutter_mozilla_components/pigeons/Gecko.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'eu.lensai.flutter_mozilla_components.pigeons',
    ),
    dartPackageName: 'flutter_mozilla_components',
  ),
)
@HostApi()
abstract class GeckoBrowserApi {
  void initialize();
  bool showNativeFragment();
  void onTrimMemory(int level);
}

@HostApi()
abstract class GeckoEngineSettingsApi {
  void setDefaultSettings(GeckoEngineSettings settings);
  void updateRuntimeSettings(GeckoEngineSettings settings);
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

@HostApi()
abstract class GeckoPrefApi {
  @async
  Map<String, Object> getPrefs(List<String>? preferenceFilter);
  @async
  Map<String, Object> applyPrefs(String prefBuffer);
  @async
  void resetPrefs(List<String>? preferenceNames);
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
