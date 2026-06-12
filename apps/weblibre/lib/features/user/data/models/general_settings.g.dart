// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'general_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GeneralSettingsCWProxy {
  GeneralSettings themeMode(ThemeMode themeMode);

  GeneralSettings uiScaleFactor(double uiScaleFactor);

  GeneralSettings disableAnimations(bool disableAnimations);

  GeneralSettings refreshRateMode(RefreshRateMode refreshRateMode);

  GeneralSettings showModalBarrier(bool showModalBarrier);

  GeneralSettings enableReadability(bool enableReadability);

  GeneralSettings enforceReadability(bool enforceReadability);

  GeneralSettings deleteBrowsingDataOnQuit(
    Set<DeleteBrowsingDataType>? deleteBrowsingDataOnQuit,
  );

  GeneralSettings screenshotProtectionEnabled(bool screenshotProtectionEnabled);

  GeneralSettings defaultSearchProvider(BangKey? defaultSearchProvider);

  GeneralSettings defaultSearchSuggestionsProvider(
    SearchSuggestionProviders defaultSearchSuggestionsProvider,
  );

  GeneralSettings createChildTabsOption(bool createChildTabsOption);

  GeneralSettings enableLocalAiFeatures(bool enableLocalAiFeatures);

  GeneralSettings showContainerUi(bool showContainerUi);

  GeneralSettings showIsolatedTabUi(bool showIsolatedTabUi);

  GeneralSettings showSearchCloseButton(bool showSearchCloseButton);

  GeneralSettings storedDefaultCreateTabType(
    TabType storedDefaultCreateTabType,
  );

  GeneralSettings tabListDirection(TabDirection tabListDirection);

  GeneralSettings tabBarDirection(TabDirection tabBarDirection);

  GeneralSettings tabIntentOpenSetting(
    TabIntentOpenSetting tabIntentOpenSetting,
  );

  GeneralSettings autoHideTabBar(bool autoHideTabBar);

  GeneralSettings tabBarSwipeAction(TabBarSwipeAction tabBarSwipeAction);

  GeneralSettings historyAutoCleanInterval(Duration historyAutoCleanInterval);

  GeneralSettings tabViewBottomSheet(bool tabViewBottomSheet);

  GeneralSettings tabBarShowContextualBar(bool tabBarShowContextualBar);

  GeneralSettings tabBarPosition(TabBarPosition tabBarPosition);

  GeneralSettings tabBarLayout(TabBarLayout tabBarLayout);

  GeneralSettings tabBarStackingMode(TabBarStackingMode tabBarStackingMode);

  GeneralSettings pullToRefreshEnabled(bool pullToRefreshEnabled);

  GeneralSettings useExternalDownloadManager(bool useExternalDownloadManager);

  GeneralSettings doubleBackCloseTab(bool doubleBackCloseTab);

  GeneralSettings unassignedTabsAutoCleanInterval(
    Duration unassignedTabsAutoCleanInterval,
  );

  GeneralSettings maxSearchHistoryEntries(int maxSearchHistoryEntries);

  GeneralSettings allowClipboardAccess(bool allowClipboardAccess);

  GeneralSettings tabListShowFavicons(bool tabListShowFavicons);

  GeneralSettings quickTabSwitcherShowTitles(bool quickTabSwitcherShowTitles);

  GeneralSettings quickTabSwitcherHierarchyGlyphs(
    int quickTabSwitcherHierarchyGlyphs,
  );

  GeneralSettings quickTabSwitcherShowHistorySuggestions(
    bool quickTabSwitcherShowHistorySuggestions,
  );

  GeneralSettings quickTabSwitcherTitleWidth(double quickTabSwitcherTitleWidth);

  GeneralSettings quickTabSwitcherShowCloseButtonOnAllTabs(
    bool quickTabSwitcherShowCloseButtonOnAllTabs,
  );

  GeneralSettings syncServerOverride(String syncServerOverride);

  GeneralSettings syncTokenServerOverride(String syncTokenServerOverride);

  GeneralSettings urlCleanerEnabled(bool urlCleanerEnabled);

  GeneralSettings urlCleanerAutoApply(bool urlCleanerAutoApply);

  GeneralSettings urlCleanerAllowReferralMarketing(
    bool urlCleanerAllowReferralMarketing,
  );

  GeneralSettings urlCleanerCatalogUrl(String urlCleanerCatalogUrl);

  GeneralSettings urlCleanerHashUrl(String urlCleanerHashUrl);

  GeneralSettings urlCleanerAutoUpdate(bool urlCleanerAutoUpdate);

  GeneralSettings urlCleanerLastCheckEpochMs(int? urlCleanerLastCheckEpochMs);

  GeneralSettings urlCleanerLastUpdateWasAuto(bool urlCleanerLastUpdateWasAuto);

  GeneralSettings smallWebTabType(TabType smallWebTabType);

  GeneralSettings tabBarLongPressUrlCopy(bool tabBarLongPressUrlCopy);

  GeneralSettings unshortenerEnabled(bool unshortenerEnabled);

  GeneralSettings unshortenerToken(String unshortenerToken);

  GeneralSettings allowNonManifestPwaInstall(bool allowNonManifestPwaInstall);

  GeneralSettings blockExternalAppsEnabled(bool blockExternalAppsEnabled);

  GeneralSettings externalAppIntentPolicies(
    Map<String, IntentSourcePolicy> externalAppIntentPolicies,
  );

  GeneralSettings enableLocalSearchIndex(bool enableLocalSearchIndex);

  GeneralSettings indexPrivateTabs(bool indexPrivateTabs);

  GeneralSettings acceptSuggestionOnSubmit(bool acceptSuggestionOnSubmit);

  GeneralSettings pureBlack(bool pureBlack);

  GeneralSettings globalDesktopMode(bool globalDesktopMode);

  GeneralSettings desktopModeSites(List<String> desktopModeSites);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `GeneralSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// GeneralSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  GeneralSettings call({
    ThemeMode themeMode,
    double uiScaleFactor,
    bool disableAnimations,
    RefreshRateMode refreshRateMode,
    bool showModalBarrier,
    bool enableReadability,
    bool enforceReadability,
    Set<DeleteBrowsingDataType>? deleteBrowsingDataOnQuit,
    bool screenshotProtectionEnabled,
    BangKey? defaultSearchProvider,
    SearchSuggestionProviders defaultSearchSuggestionsProvider,
    bool createChildTabsOption,
    bool enableLocalAiFeatures,
    bool showContainerUi,
    bool showIsolatedTabUi,
    bool showSearchCloseButton,
    TabType storedDefaultCreateTabType,
    TabDirection tabListDirection,
    TabDirection tabBarDirection,
    TabIntentOpenSetting tabIntentOpenSetting,
    bool autoHideTabBar,
    TabBarSwipeAction tabBarSwipeAction,
    Duration historyAutoCleanInterval,
    bool tabViewBottomSheet,
    bool tabBarShowContextualBar,
    TabBarPosition tabBarPosition,
    TabBarLayout tabBarLayout,
    TabBarStackingMode tabBarStackingMode,
    bool pullToRefreshEnabled,
    bool useExternalDownloadManager,
    bool doubleBackCloseTab,
    Duration unassignedTabsAutoCleanInterval,
    int maxSearchHistoryEntries,
    bool allowClipboardAccess,
    bool tabListShowFavicons,
    bool quickTabSwitcherShowTitles,
    int quickTabSwitcherHierarchyGlyphs,
    bool quickTabSwitcherShowHistorySuggestions,
    double quickTabSwitcherTitleWidth,
    bool quickTabSwitcherShowCloseButtonOnAllTabs,
    String syncServerOverride,
    String syncTokenServerOverride,
    bool urlCleanerEnabled,
    bool urlCleanerAutoApply,
    bool urlCleanerAllowReferralMarketing,
    String urlCleanerCatalogUrl,
    String urlCleanerHashUrl,
    bool urlCleanerAutoUpdate,
    int? urlCleanerLastCheckEpochMs,
    bool urlCleanerLastUpdateWasAuto,
    TabType smallWebTabType,
    bool tabBarLongPressUrlCopy,
    bool unshortenerEnabled,
    String unshortenerToken,
    bool allowNonManifestPwaInstall,
    bool blockExternalAppsEnabled,
    Map<String, IntentSourcePolicy> externalAppIntentPolicies,
    bool enableLocalSearchIndex,
    bool indexPrivateTabs,
    bool acceptSuggestionOnSubmit,
    bool pureBlack,
    bool globalDesktopMode,
    List<String> desktopModeSites,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfGeneralSettings.copyWith(...)` or call `instanceOfGeneralSettings.copyWith.fieldName(value)` for a single field.
class _$GeneralSettingsCWProxyImpl implements _$GeneralSettingsCWProxy {
  const _$GeneralSettingsCWProxyImpl(this._value);

  final GeneralSettings _value;

  @override
  GeneralSettings themeMode(ThemeMode themeMode) => call(themeMode: themeMode);

  @override
  GeneralSettings uiScaleFactor(double uiScaleFactor) =>
      call(uiScaleFactor: uiScaleFactor);

  @override
  GeneralSettings disableAnimations(bool disableAnimations) =>
      call(disableAnimations: disableAnimations);

  @override
  GeneralSettings refreshRateMode(RefreshRateMode refreshRateMode) =>
      call(refreshRateMode: refreshRateMode);

  @override
  GeneralSettings showModalBarrier(bool showModalBarrier) =>
      call(showModalBarrier: showModalBarrier);

  @override
  GeneralSettings enableReadability(bool enableReadability) =>
      call(enableReadability: enableReadability);

  @override
  GeneralSettings enforceReadability(bool enforceReadability) =>
      call(enforceReadability: enforceReadability);

  @override
  GeneralSettings deleteBrowsingDataOnQuit(
    Set<DeleteBrowsingDataType>? deleteBrowsingDataOnQuit,
  ) => call(deleteBrowsingDataOnQuit: deleteBrowsingDataOnQuit);

  @override
  GeneralSettings screenshotProtectionEnabled(
    bool screenshotProtectionEnabled,
  ) => call(screenshotProtectionEnabled: screenshotProtectionEnabled);

  @override
  GeneralSettings defaultSearchProvider(BangKey? defaultSearchProvider) =>
      call(defaultSearchProvider: defaultSearchProvider);

  @override
  GeneralSettings defaultSearchSuggestionsProvider(
    SearchSuggestionProviders defaultSearchSuggestionsProvider,
  ) => call(defaultSearchSuggestionsProvider: defaultSearchSuggestionsProvider);

  @override
  GeneralSettings createChildTabsOption(bool createChildTabsOption) =>
      call(createChildTabsOption: createChildTabsOption);

  @override
  GeneralSettings enableLocalAiFeatures(bool enableLocalAiFeatures) =>
      call(enableLocalAiFeatures: enableLocalAiFeatures);

  @override
  GeneralSettings showContainerUi(bool showContainerUi) =>
      call(showContainerUi: showContainerUi);

  @override
  GeneralSettings showIsolatedTabUi(bool showIsolatedTabUi) =>
      call(showIsolatedTabUi: showIsolatedTabUi);

  @override
  GeneralSettings showSearchCloseButton(bool showSearchCloseButton) =>
      call(showSearchCloseButton: showSearchCloseButton);

  @override
  GeneralSettings storedDefaultCreateTabType(
    TabType storedDefaultCreateTabType,
  ) => call(storedDefaultCreateTabType: storedDefaultCreateTabType);

  @override
  GeneralSettings tabListDirection(TabDirection tabListDirection) =>
      call(tabListDirection: tabListDirection);

  @override
  GeneralSettings tabBarDirection(TabDirection tabBarDirection) =>
      call(tabBarDirection: tabBarDirection);

  @override
  GeneralSettings tabIntentOpenSetting(
    TabIntentOpenSetting tabIntentOpenSetting,
  ) => call(tabIntentOpenSetting: tabIntentOpenSetting);

  @override
  GeneralSettings autoHideTabBar(bool autoHideTabBar) =>
      call(autoHideTabBar: autoHideTabBar);

  @override
  GeneralSettings tabBarSwipeAction(TabBarSwipeAction tabBarSwipeAction) =>
      call(tabBarSwipeAction: tabBarSwipeAction);

  @override
  GeneralSettings historyAutoCleanInterval(Duration historyAutoCleanInterval) =>
      call(historyAutoCleanInterval: historyAutoCleanInterval);

  @override
  GeneralSettings tabViewBottomSheet(bool tabViewBottomSheet) =>
      call(tabViewBottomSheet: tabViewBottomSheet);

  @override
  GeneralSettings tabBarShowContextualBar(bool tabBarShowContextualBar) =>
      call(tabBarShowContextualBar: tabBarShowContextualBar);

  @override
  GeneralSettings tabBarPosition(TabBarPosition tabBarPosition) =>
      call(tabBarPosition: tabBarPosition);

  @override
  GeneralSettings tabBarLayout(TabBarLayout tabBarLayout) =>
      call(tabBarLayout: tabBarLayout);

  @override
  GeneralSettings tabBarStackingMode(TabBarStackingMode tabBarStackingMode) =>
      call(tabBarStackingMode: tabBarStackingMode);

  @override
  GeneralSettings pullToRefreshEnabled(bool pullToRefreshEnabled) =>
      call(pullToRefreshEnabled: pullToRefreshEnabled);

  @override
  GeneralSettings useExternalDownloadManager(bool useExternalDownloadManager) =>
      call(useExternalDownloadManager: useExternalDownloadManager);

  @override
  GeneralSettings doubleBackCloseTab(bool doubleBackCloseTab) =>
      call(doubleBackCloseTab: doubleBackCloseTab);

  @override
  GeneralSettings unassignedTabsAutoCleanInterval(
    Duration unassignedTabsAutoCleanInterval,
  ) => call(unassignedTabsAutoCleanInterval: unassignedTabsAutoCleanInterval);

  @override
  GeneralSettings maxSearchHistoryEntries(int maxSearchHistoryEntries) =>
      call(maxSearchHistoryEntries: maxSearchHistoryEntries);

  @override
  GeneralSettings allowClipboardAccess(bool allowClipboardAccess) =>
      call(allowClipboardAccess: allowClipboardAccess);

  @override
  GeneralSettings tabListShowFavicons(bool tabListShowFavicons) =>
      call(tabListShowFavicons: tabListShowFavicons);

  @override
  GeneralSettings quickTabSwitcherShowTitles(bool quickTabSwitcherShowTitles) =>
      call(quickTabSwitcherShowTitles: quickTabSwitcherShowTitles);

  @override
  GeneralSettings quickTabSwitcherHierarchyGlyphs(
    int quickTabSwitcherHierarchyGlyphs,
  ) => call(quickTabSwitcherHierarchyGlyphs: quickTabSwitcherHierarchyGlyphs);

  @override
  GeneralSettings quickTabSwitcherShowHistorySuggestions(
    bool quickTabSwitcherShowHistorySuggestions,
  ) => call(
    quickTabSwitcherShowHistorySuggestions:
        quickTabSwitcherShowHistorySuggestions,
  );

  @override
  GeneralSettings quickTabSwitcherTitleWidth(
    double quickTabSwitcherTitleWidth,
  ) => call(quickTabSwitcherTitleWidth: quickTabSwitcherTitleWidth);

  @override
  GeneralSettings quickTabSwitcherShowCloseButtonOnAllTabs(
    bool quickTabSwitcherShowCloseButtonOnAllTabs,
  ) => call(
    quickTabSwitcherShowCloseButtonOnAllTabs:
        quickTabSwitcherShowCloseButtonOnAllTabs,
  );

  @override
  GeneralSettings syncServerOverride(String syncServerOverride) =>
      call(syncServerOverride: syncServerOverride);

  @override
  GeneralSettings syncTokenServerOverride(String syncTokenServerOverride) =>
      call(syncTokenServerOverride: syncTokenServerOverride);

  @override
  GeneralSettings urlCleanerEnabled(bool urlCleanerEnabled) =>
      call(urlCleanerEnabled: urlCleanerEnabled);

  @override
  GeneralSettings urlCleanerAutoApply(bool urlCleanerAutoApply) =>
      call(urlCleanerAutoApply: urlCleanerAutoApply);

  @override
  GeneralSettings urlCleanerAllowReferralMarketing(
    bool urlCleanerAllowReferralMarketing,
  ) => call(urlCleanerAllowReferralMarketing: urlCleanerAllowReferralMarketing);

  @override
  GeneralSettings urlCleanerCatalogUrl(String urlCleanerCatalogUrl) =>
      call(urlCleanerCatalogUrl: urlCleanerCatalogUrl);

  @override
  GeneralSettings urlCleanerHashUrl(String urlCleanerHashUrl) =>
      call(urlCleanerHashUrl: urlCleanerHashUrl);

  @override
  GeneralSettings urlCleanerAutoUpdate(bool urlCleanerAutoUpdate) =>
      call(urlCleanerAutoUpdate: urlCleanerAutoUpdate);

  @override
  GeneralSettings urlCleanerLastCheckEpochMs(int? urlCleanerLastCheckEpochMs) =>
      call(urlCleanerLastCheckEpochMs: urlCleanerLastCheckEpochMs);

  @override
  GeneralSettings urlCleanerLastUpdateWasAuto(
    bool urlCleanerLastUpdateWasAuto,
  ) => call(urlCleanerLastUpdateWasAuto: urlCleanerLastUpdateWasAuto);

  @override
  GeneralSettings smallWebTabType(TabType smallWebTabType) =>
      call(smallWebTabType: smallWebTabType);

  @override
  GeneralSettings tabBarLongPressUrlCopy(bool tabBarLongPressUrlCopy) =>
      call(tabBarLongPressUrlCopy: tabBarLongPressUrlCopy);

  @override
  GeneralSettings unshortenerEnabled(bool unshortenerEnabled) =>
      call(unshortenerEnabled: unshortenerEnabled);

  @override
  GeneralSettings unshortenerToken(String unshortenerToken) =>
      call(unshortenerToken: unshortenerToken);

  @override
  GeneralSettings allowNonManifestPwaInstall(bool allowNonManifestPwaInstall) =>
      call(allowNonManifestPwaInstall: allowNonManifestPwaInstall);

  @override
  GeneralSettings blockExternalAppsEnabled(bool blockExternalAppsEnabled) =>
      call(blockExternalAppsEnabled: blockExternalAppsEnabled);

  @override
  GeneralSettings externalAppIntentPolicies(
    Map<String, IntentSourcePolicy> externalAppIntentPolicies,
  ) => call(externalAppIntentPolicies: externalAppIntentPolicies);

  @override
  GeneralSettings enableLocalSearchIndex(bool enableLocalSearchIndex) =>
      call(enableLocalSearchIndex: enableLocalSearchIndex);

  @override
  GeneralSettings indexPrivateTabs(bool indexPrivateTabs) =>
      call(indexPrivateTabs: indexPrivateTabs);

  @override
  GeneralSettings acceptSuggestionOnSubmit(bool acceptSuggestionOnSubmit) =>
      call(acceptSuggestionOnSubmit: acceptSuggestionOnSubmit);

  @override
  GeneralSettings pureBlack(bool pureBlack) => call(pureBlack: pureBlack);

  @override
  GeneralSettings globalDesktopMode(bool globalDesktopMode) =>
      call(globalDesktopMode: globalDesktopMode);

  @override
  GeneralSettings desktopModeSites(List<String> desktopModeSites) =>
      call(desktopModeSites: desktopModeSites);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `GeneralSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// GeneralSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  GeneralSettings call({
    Object? themeMode = const $CopyWithPlaceholder(),
    Object? uiScaleFactor = const $CopyWithPlaceholder(),
    Object? disableAnimations = const $CopyWithPlaceholder(),
    Object? refreshRateMode = const $CopyWithPlaceholder(),
    Object? showModalBarrier = const $CopyWithPlaceholder(),
    Object? enableReadability = const $CopyWithPlaceholder(),
    Object? enforceReadability = const $CopyWithPlaceholder(),
    Object? deleteBrowsingDataOnQuit = const $CopyWithPlaceholder(),
    Object? screenshotProtectionEnabled = const $CopyWithPlaceholder(),
    Object? defaultSearchProvider = const $CopyWithPlaceholder(),
    Object? defaultSearchSuggestionsProvider = const $CopyWithPlaceholder(),
    Object? createChildTabsOption = const $CopyWithPlaceholder(),
    Object? enableLocalAiFeatures = const $CopyWithPlaceholder(),
    Object? showContainerUi = const $CopyWithPlaceholder(),
    Object? showIsolatedTabUi = const $CopyWithPlaceholder(),
    Object? showSearchCloseButton = const $CopyWithPlaceholder(),
    Object? storedDefaultCreateTabType = const $CopyWithPlaceholder(),
    Object? tabListDirection = const $CopyWithPlaceholder(),
    Object? tabBarDirection = const $CopyWithPlaceholder(),
    Object? tabIntentOpenSetting = const $CopyWithPlaceholder(),
    Object? autoHideTabBar = const $CopyWithPlaceholder(),
    Object? tabBarSwipeAction = const $CopyWithPlaceholder(),
    Object? historyAutoCleanInterval = const $CopyWithPlaceholder(),
    Object? tabViewBottomSheet = const $CopyWithPlaceholder(),
    Object? tabBarShowContextualBar = const $CopyWithPlaceholder(),
    Object? tabBarPosition = const $CopyWithPlaceholder(),
    Object? tabBarLayout = const $CopyWithPlaceholder(),
    Object? tabBarStackingMode = const $CopyWithPlaceholder(),
    Object? pullToRefreshEnabled = const $CopyWithPlaceholder(),
    Object? useExternalDownloadManager = const $CopyWithPlaceholder(),
    Object? doubleBackCloseTab = const $CopyWithPlaceholder(),
    Object? unassignedTabsAutoCleanInterval = const $CopyWithPlaceholder(),
    Object? maxSearchHistoryEntries = const $CopyWithPlaceholder(),
    Object? allowClipboardAccess = const $CopyWithPlaceholder(),
    Object? tabListShowFavicons = const $CopyWithPlaceholder(),
    Object? quickTabSwitcherShowTitles = const $CopyWithPlaceholder(),
    Object? quickTabSwitcherHierarchyGlyphs = const $CopyWithPlaceholder(),
    Object? quickTabSwitcherShowHistorySuggestions =
        const $CopyWithPlaceholder(),
    Object? quickTabSwitcherTitleWidth = const $CopyWithPlaceholder(),
    Object? quickTabSwitcherShowCloseButtonOnAllTabs =
        const $CopyWithPlaceholder(),
    Object? syncServerOverride = const $CopyWithPlaceholder(),
    Object? syncTokenServerOverride = const $CopyWithPlaceholder(),
    Object? urlCleanerEnabled = const $CopyWithPlaceholder(),
    Object? urlCleanerAutoApply = const $CopyWithPlaceholder(),
    Object? urlCleanerAllowReferralMarketing = const $CopyWithPlaceholder(),
    Object? urlCleanerCatalogUrl = const $CopyWithPlaceholder(),
    Object? urlCleanerHashUrl = const $CopyWithPlaceholder(),
    Object? urlCleanerAutoUpdate = const $CopyWithPlaceholder(),
    Object? urlCleanerLastCheckEpochMs = const $CopyWithPlaceholder(),
    Object? urlCleanerLastUpdateWasAuto = const $CopyWithPlaceholder(),
    Object? smallWebTabType = const $CopyWithPlaceholder(),
    Object? tabBarLongPressUrlCopy = const $CopyWithPlaceholder(),
    Object? unshortenerEnabled = const $CopyWithPlaceholder(),
    Object? unshortenerToken = const $CopyWithPlaceholder(),
    Object? allowNonManifestPwaInstall = const $CopyWithPlaceholder(),
    Object? blockExternalAppsEnabled = const $CopyWithPlaceholder(),
    Object? externalAppIntentPolicies = const $CopyWithPlaceholder(),
    Object? enableLocalSearchIndex = const $CopyWithPlaceholder(),
    Object? indexPrivateTabs = const $CopyWithPlaceholder(),
    Object? acceptSuggestionOnSubmit = const $CopyWithPlaceholder(),
    Object? pureBlack = const $CopyWithPlaceholder(),
    Object? globalDesktopMode = const $CopyWithPlaceholder(),
    Object? desktopModeSites = const $CopyWithPlaceholder(),
  }) {
    return GeneralSettings(
      themeMode: themeMode == const $CopyWithPlaceholder() || themeMode == null
          ? _value.themeMode
          // ignore: cast_nullable_to_non_nullable
          : themeMode as ThemeMode,
      uiScaleFactor:
          uiScaleFactor == const $CopyWithPlaceholder() || uiScaleFactor == null
          ? _value.uiScaleFactor
          // ignore: cast_nullable_to_non_nullable
          : uiScaleFactor as double,
      disableAnimations:
          disableAnimations == const $CopyWithPlaceholder() ||
              disableAnimations == null
          ? _value.disableAnimations
          // ignore: cast_nullable_to_non_nullable
          : disableAnimations as bool,
      refreshRateMode:
          refreshRateMode == const $CopyWithPlaceholder() ||
              refreshRateMode == null
          ? _value.refreshRateMode
          // ignore: cast_nullable_to_non_nullable
          : refreshRateMode as RefreshRateMode,
      showModalBarrier:
          showModalBarrier == const $CopyWithPlaceholder() ||
              showModalBarrier == null
          ? _value.showModalBarrier
          // ignore: cast_nullable_to_non_nullable
          : showModalBarrier as bool,
      enableReadability:
          enableReadability == const $CopyWithPlaceholder() ||
              enableReadability == null
          ? _value.enableReadability
          // ignore: cast_nullable_to_non_nullable
          : enableReadability as bool,
      enforceReadability:
          enforceReadability == const $CopyWithPlaceholder() ||
              enforceReadability == null
          ? _value.enforceReadability
          // ignore: cast_nullable_to_non_nullable
          : enforceReadability as bool,
      deleteBrowsingDataOnQuit:
          deleteBrowsingDataOnQuit == const $CopyWithPlaceholder()
          ? _value.deleteBrowsingDataOnQuit
          // ignore: cast_nullable_to_non_nullable
          : deleteBrowsingDataOnQuit as Set<DeleteBrowsingDataType>?,
      screenshotProtectionEnabled:
          screenshotProtectionEnabled == const $CopyWithPlaceholder() ||
              screenshotProtectionEnabled == null
          ? _value.screenshotProtectionEnabled
          // ignore: cast_nullable_to_non_nullable
          : screenshotProtectionEnabled as bool,
      defaultSearchProvider:
          defaultSearchProvider == const $CopyWithPlaceholder()
          ? _value.defaultSearchProvider
          // ignore: cast_nullable_to_non_nullable
          : defaultSearchProvider as BangKey?,
      defaultSearchSuggestionsProvider:
          defaultSearchSuggestionsProvider == const $CopyWithPlaceholder() ||
              defaultSearchSuggestionsProvider == null
          ? _value.defaultSearchSuggestionsProvider
          // ignore: cast_nullable_to_non_nullable
          : defaultSearchSuggestionsProvider as SearchSuggestionProviders,
      createChildTabsOption:
          createChildTabsOption == const $CopyWithPlaceholder() ||
              createChildTabsOption == null
          ? _value.createChildTabsOption
          // ignore: cast_nullable_to_non_nullable
          : createChildTabsOption as bool,
      enableLocalAiFeatures:
          enableLocalAiFeatures == const $CopyWithPlaceholder() ||
              enableLocalAiFeatures == null
          ? _value.enableLocalAiFeatures
          // ignore: cast_nullable_to_non_nullable
          : enableLocalAiFeatures as bool,
      showContainerUi:
          showContainerUi == const $CopyWithPlaceholder() ||
              showContainerUi == null
          ? _value.showContainerUi
          // ignore: cast_nullable_to_non_nullable
          : showContainerUi as bool,
      showIsolatedTabUi:
          showIsolatedTabUi == const $CopyWithPlaceholder() ||
              showIsolatedTabUi == null
          ? _value.showIsolatedTabUi
          // ignore: cast_nullable_to_non_nullable
          : showIsolatedTabUi as bool,
      showSearchCloseButton:
          showSearchCloseButton == const $CopyWithPlaceholder() ||
              showSearchCloseButton == null
          ? _value.showSearchCloseButton
          // ignore: cast_nullable_to_non_nullable
          : showSearchCloseButton as bool,
      storedDefaultCreateTabType:
          storedDefaultCreateTabType == const $CopyWithPlaceholder() ||
              storedDefaultCreateTabType == null
          ? _value.storedDefaultCreateTabType
          // ignore: cast_nullable_to_non_nullable
          : storedDefaultCreateTabType as TabType,
      tabListDirection:
          tabListDirection == const $CopyWithPlaceholder() ||
              tabListDirection == null
          ? _value.tabListDirection
          // ignore: cast_nullable_to_non_nullable
          : tabListDirection as TabDirection,
      tabBarDirection:
          tabBarDirection == const $CopyWithPlaceholder() ||
              tabBarDirection == null
          ? _value.tabBarDirection
          // ignore: cast_nullable_to_non_nullable
          : tabBarDirection as TabDirection,
      tabIntentOpenSetting:
          tabIntentOpenSetting == const $CopyWithPlaceholder() ||
              tabIntentOpenSetting == null
          ? _value.tabIntentOpenSetting
          // ignore: cast_nullable_to_non_nullable
          : tabIntentOpenSetting as TabIntentOpenSetting,
      autoHideTabBar:
          autoHideTabBar == const $CopyWithPlaceholder() ||
              autoHideTabBar == null
          ? _value.autoHideTabBar
          // ignore: cast_nullable_to_non_nullable
          : autoHideTabBar as bool,
      tabBarSwipeAction:
          tabBarSwipeAction == const $CopyWithPlaceholder() ||
              tabBarSwipeAction == null
          ? _value.tabBarSwipeAction
          // ignore: cast_nullable_to_non_nullable
          : tabBarSwipeAction as TabBarSwipeAction,
      historyAutoCleanInterval:
          historyAutoCleanInterval == const $CopyWithPlaceholder() ||
              historyAutoCleanInterval == null
          ? _value.historyAutoCleanInterval
          // ignore: cast_nullable_to_non_nullable
          : historyAutoCleanInterval as Duration,
      tabViewBottomSheet:
          tabViewBottomSheet == const $CopyWithPlaceholder() ||
              tabViewBottomSheet == null
          ? _value.tabViewBottomSheet
          // ignore: cast_nullable_to_non_nullable
          : tabViewBottomSheet as bool,
      tabBarShowContextualBar:
          tabBarShowContextualBar == const $CopyWithPlaceholder() ||
              tabBarShowContextualBar == null
          ? _value.tabBarShowContextualBar
          // ignore: cast_nullable_to_non_nullable
          : tabBarShowContextualBar as bool,
      tabBarPosition:
          tabBarPosition == const $CopyWithPlaceholder() ||
              tabBarPosition == null
          ? _value.tabBarPosition
          // ignore: cast_nullable_to_non_nullable
          : tabBarPosition as TabBarPosition,
      tabBarLayout:
          tabBarLayout == const $CopyWithPlaceholder() || tabBarLayout == null
          ? _value.tabBarLayout
          // ignore: cast_nullable_to_non_nullable
          : tabBarLayout as TabBarLayout,
      tabBarStackingMode:
          tabBarStackingMode == const $CopyWithPlaceholder() ||
              tabBarStackingMode == null
          ? _value.tabBarStackingMode
          // ignore: cast_nullable_to_non_nullable
          : tabBarStackingMode as TabBarStackingMode,
      pullToRefreshEnabled:
          pullToRefreshEnabled == const $CopyWithPlaceholder() ||
              pullToRefreshEnabled == null
          ? _value.pullToRefreshEnabled
          // ignore: cast_nullable_to_non_nullable
          : pullToRefreshEnabled as bool,
      useExternalDownloadManager:
          useExternalDownloadManager == const $CopyWithPlaceholder() ||
              useExternalDownloadManager == null
          ? _value.useExternalDownloadManager
          // ignore: cast_nullable_to_non_nullable
          : useExternalDownloadManager as bool,
      doubleBackCloseTab:
          doubleBackCloseTab == const $CopyWithPlaceholder() ||
              doubleBackCloseTab == null
          ? _value.doubleBackCloseTab
          // ignore: cast_nullable_to_non_nullable
          : doubleBackCloseTab as bool,
      unassignedTabsAutoCleanInterval:
          unassignedTabsAutoCleanInterval == const $CopyWithPlaceholder() ||
              unassignedTabsAutoCleanInterval == null
          ? _value.unassignedTabsAutoCleanInterval
          // ignore: cast_nullable_to_non_nullable
          : unassignedTabsAutoCleanInterval as Duration,
      maxSearchHistoryEntries:
          maxSearchHistoryEntries == const $CopyWithPlaceholder() ||
              maxSearchHistoryEntries == null
          ? _value.maxSearchHistoryEntries
          // ignore: cast_nullable_to_non_nullable
          : maxSearchHistoryEntries as int,
      allowClipboardAccess:
          allowClipboardAccess == const $CopyWithPlaceholder() ||
              allowClipboardAccess == null
          ? _value.allowClipboardAccess
          // ignore: cast_nullable_to_non_nullable
          : allowClipboardAccess as bool,
      tabListShowFavicons:
          tabListShowFavicons == const $CopyWithPlaceholder() ||
              tabListShowFavicons == null
          ? _value.tabListShowFavicons
          // ignore: cast_nullable_to_non_nullable
          : tabListShowFavicons as bool,
      quickTabSwitcherShowTitles:
          quickTabSwitcherShowTitles == const $CopyWithPlaceholder() ||
              quickTabSwitcherShowTitles == null
          ? _value.quickTabSwitcherShowTitles
          // ignore: cast_nullable_to_non_nullable
          : quickTabSwitcherShowTitles as bool,
      quickTabSwitcherHierarchyGlyphs:
          quickTabSwitcherHierarchyGlyphs == const $CopyWithPlaceholder() ||
              quickTabSwitcherHierarchyGlyphs == null
          ? _value.quickTabSwitcherHierarchyGlyphs
          // ignore: cast_nullable_to_non_nullable
          : quickTabSwitcherHierarchyGlyphs as int,
      quickTabSwitcherShowHistorySuggestions:
          quickTabSwitcherShowHistorySuggestions ==
                  const $CopyWithPlaceholder() ||
              quickTabSwitcherShowHistorySuggestions == null
          ? _value.quickTabSwitcherShowHistorySuggestions
          // ignore: cast_nullable_to_non_nullable
          : quickTabSwitcherShowHistorySuggestions as bool,
      quickTabSwitcherTitleWidth:
          quickTabSwitcherTitleWidth == const $CopyWithPlaceholder() ||
              quickTabSwitcherTitleWidth == null
          ? _value.quickTabSwitcherTitleWidth
          // ignore: cast_nullable_to_non_nullable
          : quickTabSwitcherTitleWidth as double,
      quickTabSwitcherShowCloseButtonOnAllTabs:
          quickTabSwitcherShowCloseButtonOnAllTabs ==
                  const $CopyWithPlaceholder() ||
              quickTabSwitcherShowCloseButtonOnAllTabs == null
          ? _value.quickTabSwitcherShowCloseButtonOnAllTabs
          // ignore: cast_nullable_to_non_nullable
          : quickTabSwitcherShowCloseButtonOnAllTabs as bool,
      syncServerOverride:
          syncServerOverride == const $CopyWithPlaceholder() ||
              syncServerOverride == null
          ? _value.syncServerOverride
          // ignore: cast_nullable_to_non_nullable
          : syncServerOverride as String,
      syncTokenServerOverride:
          syncTokenServerOverride == const $CopyWithPlaceholder() ||
              syncTokenServerOverride == null
          ? _value.syncTokenServerOverride
          // ignore: cast_nullable_to_non_nullable
          : syncTokenServerOverride as String,
      urlCleanerEnabled:
          urlCleanerEnabled == const $CopyWithPlaceholder() ||
              urlCleanerEnabled == null
          ? _value.urlCleanerEnabled
          // ignore: cast_nullable_to_non_nullable
          : urlCleanerEnabled as bool,
      urlCleanerAutoApply:
          urlCleanerAutoApply == const $CopyWithPlaceholder() ||
              urlCleanerAutoApply == null
          ? _value.urlCleanerAutoApply
          // ignore: cast_nullable_to_non_nullable
          : urlCleanerAutoApply as bool,
      urlCleanerAllowReferralMarketing:
          urlCleanerAllowReferralMarketing == const $CopyWithPlaceholder() ||
              urlCleanerAllowReferralMarketing == null
          ? _value.urlCleanerAllowReferralMarketing
          // ignore: cast_nullable_to_non_nullable
          : urlCleanerAllowReferralMarketing as bool,
      urlCleanerCatalogUrl:
          urlCleanerCatalogUrl == const $CopyWithPlaceholder() ||
              urlCleanerCatalogUrl == null
          ? _value.urlCleanerCatalogUrl
          // ignore: cast_nullable_to_non_nullable
          : urlCleanerCatalogUrl as String,
      urlCleanerHashUrl:
          urlCleanerHashUrl == const $CopyWithPlaceholder() ||
              urlCleanerHashUrl == null
          ? _value.urlCleanerHashUrl
          // ignore: cast_nullable_to_non_nullable
          : urlCleanerHashUrl as String,
      urlCleanerAutoUpdate:
          urlCleanerAutoUpdate == const $CopyWithPlaceholder() ||
              urlCleanerAutoUpdate == null
          ? _value.urlCleanerAutoUpdate
          // ignore: cast_nullable_to_non_nullable
          : urlCleanerAutoUpdate as bool,
      urlCleanerLastCheckEpochMs:
          urlCleanerLastCheckEpochMs == const $CopyWithPlaceholder()
          ? _value.urlCleanerLastCheckEpochMs
          // ignore: cast_nullable_to_non_nullable
          : urlCleanerLastCheckEpochMs as int?,
      urlCleanerLastUpdateWasAuto:
          urlCleanerLastUpdateWasAuto == const $CopyWithPlaceholder() ||
              urlCleanerLastUpdateWasAuto == null
          ? _value.urlCleanerLastUpdateWasAuto
          // ignore: cast_nullable_to_non_nullable
          : urlCleanerLastUpdateWasAuto as bool,
      smallWebTabType:
          smallWebTabType == const $CopyWithPlaceholder() ||
              smallWebTabType == null
          ? _value.smallWebTabType
          // ignore: cast_nullable_to_non_nullable
          : smallWebTabType as TabType,
      tabBarLongPressUrlCopy:
          tabBarLongPressUrlCopy == const $CopyWithPlaceholder() ||
              tabBarLongPressUrlCopy == null
          ? _value.tabBarLongPressUrlCopy
          // ignore: cast_nullable_to_non_nullable
          : tabBarLongPressUrlCopy as bool,
      unshortenerEnabled:
          unshortenerEnabled == const $CopyWithPlaceholder() ||
              unshortenerEnabled == null
          ? _value.unshortenerEnabled
          // ignore: cast_nullable_to_non_nullable
          : unshortenerEnabled as bool,
      unshortenerToken:
          unshortenerToken == const $CopyWithPlaceholder() ||
              unshortenerToken == null
          ? _value.unshortenerToken
          // ignore: cast_nullable_to_non_nullable
          : unshortenerToken as String,
      allowNonManifestPwaInstall:
          allowNonManifestPwaInstall == const $CopyWithPlaceholder() ||
              allowNonManifestPwaInstall == null
          ? _value.allowNonManifestPwaInstall
          // ignore: cast_nullable_to_non_nullable
          : allowNonManifestPwaInstall as bool,
      blockExternalAppsEnabled:
          blockExternalAppsEnabled == const $CopyWithPlaceholder() ||
              blockExternalAppsEnabled == null
          ? _value.blockExternalAppsEnabled
          // ignore: cast_nullable_to_non_nullable
          : blockExternalAppsEnabled as bool,
      externalAppIntentPolicies:
          externalAppIntentPolicies == const $CopyWithPlaceholder() ||
              externalAppIntentPolicies == null
          ? _value.externalAppIntentPolicies
          // ignore: cast_nullable_to_non_nullable
          : externalAppIntentPolicies as Map<String, IntentSourcePolicy>,
      enableLocalSearchIndex:
          enableLocalSearchIndex == const $CopyWithPlaceholder() ||
              enableLocalSearchIndex == null
          ? _value.enableLocalSearchIndex
          // ignore: cast_nullable_to_non_nullable
          : enableLocalSearchIndex as bool,
      indexPrivateTabs:
          indexPrivateTabs == const $CopyWithPlaceholder() ||
              indexPrivateTabs == null
          ? _value.indexPrivateTabs
          // ignore: cast_nullable_to_non_nullable
          : indexPrivateTabs as bool,
      acceptSuggestionOnSubmit:
          acceptSuggestionOnSubmit == const $CopyWithPlaceholder() ||
              acceptSuggestionOnSubmit == null
          ? _value.acceptSuggestionOnSubmit
          // ignore: cast_nullable_to_non_nullable
          : acceptSuggestionOnSubmit as bool,
      pureBlack: pureBlack == const $CopyWithPlaceholder() || pureBlack == null
          ? _value.pureBlack
          // ignore: cast_nullable_to_non_nullable
          : pureBlack as bool,
      globalDesktopMode:
          globalDesktopMode == const $CopyWithPlaceholder() ||
              globalDesktopMode == null
          ? _value.globalDesktopMode
          // ignore: cast_nullable_to_non_nullable
          : globalDesktopMode as bool,
      desktopModeSites:
          desktopModeSites == const $CopyWithPlaceholder() ||
              desktopModeSites == null
          ? _value.desktopModeSites
          // ignore: cast_nullable_to_non_nullable
          : desktopModeSites as List<String>,
    );
  }
}

extension $GeneralSettingsCopyWith on GeneralSettings {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfGeneralSettings.copyWith(...)` or `instanceOfGeneralSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GeneralSettingsCWProxy get copyWith => _$GeneralSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneralSettings _$GeneralSettingsFromJson(
  Map<String, dynamic> json,
) => GeneralSettings.withDefaults(
  themeMode: $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']),
  uiScaleFactor: (json['uiScaleFactor'] as num?)?.toDouble(),
  disableAnimations: json['disableAnimations'] as bool?,
  refreshRateMode: $enumDecodeNullable(
    _$RefreshRateModeEnumMap,
    json['refreshRateMode'],
  ),
  showModalBarrier: json['showModalBarrier'] as bool?,
  enableReadability: json['enableReadability'] as bool?,
  enforceReadability: json['enforceReadability'] as bool?,
  deleteBrowsingDataOnQuit: (json['deleteBrowsingDataOnQuit'] as List<dynamic>?)
      ?.map((e) => $enumDecode(_$DeleteBrowsingDataTypeEnumMap, e))
      .toSet(),
  screenshotProtectionEnabled: json['screenshotProtectionEnabled'] as bool?,
  defaultSearchProvider: const BangKeyConverter().fromJson(
    json['defaultSearchProvider'] as String?,
  ),
  defaultSearchSuggestionsProvider: $enumDecodeNullable(
    _$SearchSuggestionProvidersEnumMap,
    json['defaultSearchSuggestionsProvider'],
  ),
  createChildTabsOption: json['createChildTabsOption'] as bool?,
  enableLocalAiFeatures: json['enableLocalAiFeatures'] as bool?,
  showContainerUi: json['showContainerUi'] as bool?,
  showIsolatedTabUi: json['showIsolatedTabUi'] as bool?,
  showSearchCloseButton: json['showSearchCloseButton'] as bool?,
  storedDefaultCreateTabType: $enumDecodeNullable(
    _$TabTypeEnumMap,
    json['defaultCreateTabType'],
  ),
  tabListDirection: $enumDecodeNullable(
    _$TabDirectionEnumMap,
    json['tabListDirection'],
  ),
  tabBarDirection: $enumDecodeNullable(
    _$TabDirectionEnumMap,
    json['tabBarDirection'],
  ),
  tabIntentOpenSetting: $enumDecodeNullable(
    _$TabIntentOpenSettingEnumMap,
    json['tabIntentOpenSetting'],
  ),
  autoHideTabBar: json['autoHideTabBar'] as bool?,
  tabBarSwipeAction: $enumDecodeNullable(
    _$TabBarSwipeActionEnumMap,
    json['tabBarSwipeAction'],
  ),
  historyAutoCleanInterval: json['historyAutoCleanInterval'] == null
      ? null
      : Duration(
          microseconds: (json['historyAutoCleanInterval'] as num).toInt(),
        ),
  tabViewBottomSheet: json['tabViewBottomSheet'] as bool?,
  tabBarShowContextualBar: json['tabBarShowContextualBar'] as bool?,
  tabBarPosition: $enumDecodeNullable(
    _$TabBarPositionEnumMap,
    json['tabBarPosition'],
  ),
  tabBarLayout: $enumDecodeNullable(
    _$TabBarLayoutEnumMap,
    json['tabBarLayout'],
  ),
  tabBarStackingMode: $enumDecodeNullable(
    _$TabBarStackingModeEnumMap,
    json['tabBarStackingMode'],
  ),
  pullToRefreshEnabled: json['pullToRefreshEnabled'] as bool?,
  useExternalDownloadManager: json['useExternalDownloadManager'] as bool?,
  doubleBackCloseTab: json['doubleBackCloseTab'] as bool?,
  unassignedTabsAutoCleanInterval:
      json['unassignedTabsAutoCleanInterval'] == null
      ? null
      : Duration(
          microseconds: (json['unassignedTabsAutoCleanInterval'] as num)
              .toInt(),
        ),
  maxSearchHistoryEntries: (json['maxSearchHistoryEntries'] as num?)?.toInt(),
  allowClipboardAccess: json['allowClipboardAccess'] as bool?,
  tabListShowFavicons: json['tabListShowFavicons'] as bool?,
  quickTabSwitcherShowTitles: json['quickTabSwitcherShowTitles'] as bool?,
  quickTabSwitcherHierarchyGlyphs:
      (json['quickTabSwitcherHierarchyGlyphs'] as num?)?.toInt(),
  quickTabSwitcherShowHistorySuggestions:
      json['quickTabSwitcherShowHistorySuggestions'] as bool?,
  quickTabSwitcherTitleWidth: (json['quickTabSwitcherTitleWidth'] as num?)
      ?.toDouble(),
  quickTabSwitcherShowCloseButtonOnAllTabs:
      json['quickTabSwitcherShowCloseButtonOnAllTabs'] as bool?,
  syncServerOverride: json['syncServerOverride'] as String?,
  syncTokenServerOverride: json['syncTokenServerOverride'] as String?,
  urlCleanerEnabled: json['urlCleanerEnabled'] as bool?,
  urlCleanerAutoApply: json['urlCleanerAutoApply'] as bool?,
  urlCleanerAllowReferralMarketing:
      json['urlCleanerAllowReferralMarketing'] as bool?,
  urlCleanerCatalogUrl: json['urlCleanerCatalogUrl'] as String?,
  urlCleanerHashUrl: json['urlCleanerHashUrl'] as String?,
  urlCleanerAutoUpdate: json['urlCleanerAutoUpdate'] as bool?,
  urlCleanerLastCheckEpochMs: (json['urlCleanerLastCheckEpochMs'] as num?)
      ?.toInt(),
  urlCleanerLastUpdateWasAuto: json['urlCleanerLastUpdateWasAuto'] as bool?,
  smallWebTabType: $enumDecodeNullable(
    _$TabTypeEnumMap,
    json['smallWebTabType'],
  ),
  tabBarLongPressUrlCopy: json['tabBarLongPressUrlCopy'] as bool?,
  unshortenerEnabled: json['unshortenerEnabled'] as bool?,
  unshortenerToken: json['unshortenerToken'] as String?,
  allowNonManifestPwaInstall: json['allowNonManifestPwaInstall'] as bool?,
  blockExternalAppsEnabled: json['blockExternalAppsEnabled'] as bool?,
  externalAppIntentPolicies:
      (json['externalAppIntentPolicies'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, $enumDecode(_$IntentSourcePolicyEnumMap, e)),
      ),
  enableLocalSearchIndex: json['enableLocalSearchIndex'] as bool?,
  indexPrivateTabs: json['indexPrivateTabs'] as bool?,
  acceptSuggestionOnSubmit: json['acceptSuggestionOnSubmit'] as bool?,
  pureBlack: json['pureBlack'] as bool?,
  globalDesktopMode: json['globalDesktopMode'] as bool?,
  desktopModeSites: (json['desktopModeSites'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$GeneralSettingsToJson(
  GeneralSettings instance,
) => <String, dynamic>{
  'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
  'uiScaleFactor': instance.uiScaleFactor,
  'disableAnimations': instance.disableAnimations,
  'refreshRateMode': _$RefreshRateModeEnumMap[instance.refreshRateMode]!,
  'showModalBarrier': instance.showModalBarrier,
  'enableReadability': instance.enableReadability,
  'enforceReadability': instance.enforceReadability,
  'deleteBrowsingDataOnQuit': instance.deleteBrowsingDataOnQuit
      ?.map((e) => _$DeleteBrowsingDataTypeEnumMap[e]!)
      .toList(),
  'screenshotProtectionEnabled': instance.screenshotProtectionEnabled,
  'defaultSearchProvider': const BangKeyConverter().toJson(
    instance.defaultSearchProvider,
  ),
  'defaultSearchSuggestionsProvider':
      _$SearchSuggestionProvidersEnumMap[instance
          .defaultSearchSuggestionsProvider]!,
  'createChildTabsOption': instance.createChildTabsOption,
  'enableLocalAiFeatures': instance.enableLocalAiFeatures,
  'showContainerUi': instance.showContainerUi,
  'showIsolatedTabUi': instance.showIsolatedTabUi,
  'showSearchCloseButton': instance.showSearchCloseButton,
  'defaultCreateTabType':
      _$TabTypeEnumMap[instance.storedDefaultCreateTabType]!,
  'tabListDirection': _$TabDirectionEnumMap[instance.tabListDirection]!,
  'tabBarDirection': _$TabDirectionEnumMap[instance.tabBarDirection]!,
  'tabIntentOpenSetting':
      _$TabIntentOpenSettingEnumMap[instance.tabIntentOpenSetting]!,
  'autoHideTabBar': instance.autoHideTabBar,
  'tabBarSwipeAction': _$TabBarSwipeActionEnumMap[instance.tabBarSwipeAction]!,
  'historyAutoCleanInterval': instance.historyAutoCleanInterval.inMicroseconds,
  'tabViewBottomSheet': instance.tabViewBottomSheet,
  'tabBarShowContextualBar': instance.tabBarShowContextualBar,
  'tabBarPosition': _$TabBarPositionEnumMap[instance.tabBarPosition]!,
  'tabBarLayout': _$TabBarLayoutEnumMap[instance.tabBarLayout]!,
  'tabBarStackingMode':
      _$TabBarStackingModeEnumMap[instance.tabBarStackingMode]!,
  'pullToRefreshEnabled': instance.pullToRefreshEnabled,
  'useExternalDownloadManager': instance.useExternalDownloadManager,
  'doubleBackCloseTab': instance.doubleBackCloseTab,
  'unassignedTabsAutoCleanInterval':
      instance.unassignedTabsAutoCleanInterval.inMicroseconds,
  'maxSearchHistoryEntries': instance.maxSearchHistoryEntries,
  'allowClipboardAccess': instance.allowClipboardAccess,
  'tabListShowFavicons': instance.tabListShowFavicons,
  'quickTabSwitcherShowTitles': instance.quickTabSwitcherShowTitles,
  'quickTabSwitcherHierarchyGlyphs': instance.quickTabSwitcherHierarchyGlyphs,
  'quickTabSwitcherShowHistorySuggestions':
      instance.quickTabSwitcherShowHistorySuggestions,
  'quickTabSwitcherTitleWidth': instance.quickTabSwitcherTitleWidth,
  'quickTabSwitcherShowCloseButtonOnAllTabs':
      instance.quickTabSwitcherShowCloseButtonOnAllTabs,
  'syncServerOverride': instance.syncServerOverride,
  'syncTokenServerOverride': instance.syncTokenServerOverride,
  'urlCleanerEnabled': instance.urlCleanerEnabled,
  'urlCleanerAutoApply': instance.urlCleanerAutoApply,
  'urlCleanerAllowReferralMarketing': instance.urlCleanerAllowReferralMarketing,
  'urlCleanerCatalogUrl': instance.urlCleanerCatalogUrl,
  'urlCleanerHashUrl': instance.urlCleanerHashUrl,
  'urlCleanerAutoUpdate': instance.urlCleanerAutoUpdate,
  'urlCleanerLastCheckEpochMs': instance.urlCleanerLastCheckEpochMs,
  'urlCleanerLastUpdateWasAuto': instance.urlCleanerLastUpdateWasAuto,
  'smallWebTabType': _$TabTypeEnumMap[instance.smallWebTabType]!,
  'tabBarLongPressUrlCopy': instance.tabBarLongPressUrlCopy,
  'unshortenerEnabled': instance.unshortenerEnabled,
  'unshortenerToken': instance.unshortenerToken,
  'allowNonManifestPwaInstall': instance.allowNonManifestPwaInstall,
  'blockExternalAppsEnabled': instance.blockExternalAppsEnabled,
  'externalAppIntentPolicies': instance.externalAppIntentPolicies.map(
    (k, e) => MapEntry(k, _$IntentSourcePolicyEnumMap[e]!),
  ),
  'enableLocalSearchIndex': instance.enableLocalSearchIndex,
  'indexPrivateTabs': instance.indexPrivateTabs,
  'acceptSuggestionOnSubmit': instance.acceptSuggestionOnSubmit,
  'pureBlack': instance.pureBlack,
  'globalDesktopMode': instance.globalDesktopMode,
  'desktopModeSites': instance.desktopModeSites,
};

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$RefreshRateModeEnumMap = {
  RefreshRateMode.system: 'system',
  RefreshRateMode.high: 'high',
  RefreshRateMode.low: 'low',
};

const _$DeleteBrowsingDataTypeEnumMap = {
  DeleteBrowsingDataType.tabs: 'tabs',
  DeleteBrowsingDataType.history: 'history',
  DeleteBrowsingDataType.cookies: 'cookies',
  DeleteBrowsingDataType.cache: 'cache',
  DeleteBrowsingDataType.permissions: 'permissions',
  DeleteBrowsingDataType.downloads: 'downloads',
};

const _$SearchSuggestionProvidersEnumMap = {
  SearchSuggestionProviders.none: 'none',
  SearchSuggestionProviders.brave: 'brave',
  SearchSuggestionProviders.ddg: 'ddg',
  SearchSuggestionProviders.kagi: 'kagi',
  SearchSuggestionProviders.qwant: 'qwant',
};

const _$TabTypeEnumMap = {
  TabType.regular: 'regular',
  TabType.private: 'private',
  TabType.child: 'child',
  TabType.isolated: 'isolated',
};

const _$TabDirectionEnumMap = {
  TabDirection.newestFirst: 'newestFirst',
  TabDirection.oldestFirst: 'oldestFirst',
};

const _$TabIntentOpenSettingEnumMap = {
  TabIntentOpenSetting.regular: 'regular',
  TabIntentOpenSetting.private: 'private',
  TabIntentOpenSetting.isolated: 'isolated',
  TabIntentOpenSetting.ask: 'ask',
};

const _$TabBarSwipeActionEnumMap = {
  TabBarSwipeAction.switchLastOpened: 'switchLastOpened',
  TabBarSwipeAction.navigateOrderedTabs: 'navigateOrderedTabs',
};

const _$TabBarPositionEnumMap = {
  TabBarPosition.top: 'top',
  TabBarPosition.bottom: 'bottom',
};

const _$TabBarLayoutEnumMap = {
  TabBarLayout.withTitle: 'withTitle',
  TabBarLayout.compact: 'compact',
};

const _$TabBarStackingModeEnumMap = {
  TabBarStackingMode.lastUsedTabs: 'lastUsedTabs',
  TabBarStackingMode.containerTabs: 'containerTabs',
  TabBarStackingMode.accordion: 'accordion',
  TabBarStackingMode.twoLevel: 'twoLevel',
  TabBarStackingMode.disabled: 'disabled',
};

const _$IntentSourcePolicyEnumMap = {
  IntentSourcePolicy.allow: 'allow',
  IntentSourcePolicy.block: 'block',
};
