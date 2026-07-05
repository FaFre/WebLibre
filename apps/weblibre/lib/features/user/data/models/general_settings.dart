/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/data/models/bang_key.dart';
import 'package:weblibre/features/intent_gatekeeper/domain/entities/intent_source_policy.dart';
import 'package:weblibre/features/search/domain/entities/abstract/i_search_suggestion_provider.dart';

part 'general_settings.g.dart';

const _fallbackSearchProvider = BangKey(
  group: BangGroup.general,
  trigger: 'wikipedia',
);
const _fallbackAutocompleteProvider = SearchSuggestionProviders.none;

const defaultUiScaleFactor = 1.0;
const minUiScaleFactor = 0.5;
const maxUiScaleFactor = 1.5;
const uiScaleFactorStep = 0.05;

/// Max number of inline chevron glyphs shown on a quick tab switcher chip
/// before the depth indicator collapses into a single icon + count badge.
/// A value of 0 hides the hierarchy indicator entirely.
const defaultQuickTabSwitcherHierarchyGlyphs = 2;
const minQuickTabSwitcherHierarchyGlyphs = 0;
const maxQuickTabSwitcherHierarchyGlyphs = 4;

/// Max width (logical px) of the title text on a quick tab switcher chip.
/// The default of 64 sits at the 1/3 position of the slider scale.
const defaultQuickTabSwitcherTitleWidth = 64.0;
const minQuickTabSwitcherTitleWidth = 32.0;
const maxQuickTabSwitcherTitleWidth = 128.0;
const quickTabSwitcherTitleWidthStep = 8.0;

/// Controls the Android display refresh rate the app requests at startup.
///
/// Flutter does not request a high refresh rate by default, so on many devices
/// (Samsung, OnePlus, Xiaomi, …) the app is left at 60Hz even on a 90/120Hz
/// panel. [high] asks the OS for the fastest available mode, [low] for the
/// slowest (battery saving), and [system] leaves the OS-managed default in
/// place. Android-only; ignored on other platforms.
enum RefreshRateMode { system, high, low }

enum TabBarSwipeAction { switchLastOpened, navigateOrderedTabs }

/// Row kind rendered inside the quick tab switcher bar. [TabBarStackingMode]
/// decides which row(s) are shown; this enum identifies a single row.
enum QuickTabSwitcherMode { lastUsedTabs, containerTabs }

/// Layout of the quick tab switcher bar. Merges the former
/// "show tab switcher bar" toggle and [QuickTabSwitcherMode] selection.
///
/// [accordion] renders all containers as header chips with the selected
/// container's tabs expanded inline. [twoLevel] stacks a container-tabs row
/// on top of a recently-used row. [disabled] hides the bar entirely.
enum TabBarStackingMode {
  lastUsedTabs,
  containerTabs,
  accordion,
  twoLevel,
  disabled,
}

enum TabIntentOpenSetting { regular, private, isolated, ask }

enum TabDirection { newestFirst, oldestFirst }

enum TabBarPosition {
  top,
  bottom,
  left,
  right;

  /// Whether the tab bar is rendered as a vertical side rail (left/right)
  /// rather than a horizontal bar (top/bottom).
  bool get isVertical =>
      this == TabBarPosition.left || this == TabBarPosition.right;

  /// Whether the tab bar is rendered as a horizontal bar (top/bottom).
  bool get isHorizontal => !isVertical;

  /// Main axis along which the bar's content flows.
  Axis get axis => isVertical ? Axis.vertical : Axis.horizontal;
}

enum TabBarLayout { withTitle, compact }

enum DeleteBrowsingDataType {
  tabs('Open tabs'),
  history('Browsing history'),
  recentSearches('Recent searches', 'Queries shown on the search page'),
  cookies('Cookies and site data', 'You’ll be logged out of most sites'),
  cache('Cached images and files', 'Frees up storage space'),
  permissions('Site permissions'),
  downloads('Downloads');

  final String title;
  final String? description;

  const DeleteBrowsingDataType(this.title, [this.description]);
}

@CopyWith()
@JsonSerializable(includeIfNull: true, constructor: 'withDefaults')
class GeneralSettings with FastEquatable {
  final ThemeMode themeMode;
  final double uiScaleFactor;
  final bool disableAnimations;

  /// Android display refresh rate requested at startup. See [RefreshRateMode].
  final RefreshRateMode refreshRateMode;
  final bool showModalBarrier;
  final bool enableReadability;
  final bool enforceReadability;
  final Set<DeleteBrowsingDataType>? deleteBrowsingDataOnQuit;
  final bool screenshotProtectionEnabled;
  @BangKeyConverter()
  final BangKey? defaultSearchProvider;
  final SearchSuggestionProviders defaultSearchSuggestionsProvider;
  final bool createChildTabsOption;
  final bool enableLocalAiFeatures;
  final bool showContainerUi;
  final bool showIsolatedTabUi;

  /// Whether the search / new-tab page shows a leading close button so it can
  /// be dismissed without a system back button or back gesture (e.g. on e-ink
  /// devices). Defaults to false. Only shown when the route can be popped.
  final bool showSearchCloseButton;
  @JsonKey(name: 'defaultCreateTabType')
  final TabType storedDefaultCreateTabType;
  final TabDirection tabListDirection;
  final TabDirection tabBarDirection;
  final TabIntentOpenSetting tabIntentOpenSetting;
  final bool autoHideTabBar;
  final TabBarSwipeAction tabBarSwipeAction;
  final Duration historyAutoCleanInterval;
  final bool tabViewBottomSheet;
  final bool tabBarShowContextualBar;
  final TabBarPosition tabBarPosition;
  final TabBarLayout tabBarLayout;
  final TabBarStackingMode tabBarStackingMode;
  final bool pullToRefreshEnabled;
  final bool useExternalDownloadManager;
  final bool doubleBackCloseTab;
  final Duration unassignedTabsAutoCleanInterval;
  final int maxSearchHistoryEntries;
  final bool allowClipboardAccess;
  final bool tabListShowFavicons;
  final bool quickTabSwitcherShowTitles;
  final int quickTabSwitcherHierarchyGlyphs;
  final bool quickTabSwitcherShowHistorySuggestions;

  /// Max width (logical px) for chip titles in the quick tab switcher.
  final double quickTabSwitcherTitleWidth;

  /// Whether every tab chip in the quick tab switcher shows a close button.
  /// The selected tab's chip always shows one regardless of this setting.
  final bool quickTabSwitcherShowCloseButtonOnAllTabs;
  final String syncServerOverride;
  final String syncTokenServerOverride;
  final bool urlCleanerEnabled;
  final bool urlCleanerAutoApply;
  final bool urlCleanerAllowReferralMarketing;
  final String urlCleanerCatalogUrl;
  final String urlCleanerHashUrl;
  final bool urlCleanerAutoUpdate;
  final int? urlCleanerLastCheckEpochMs;
  final bool urlCleanerLastUpdateWasAuto;
  final TabType smallWebTabType;
  final bool tabBarLongPressUrlCopy;
  final bool unshortenerEnabled;
  final String unshortenerToken;
  final bool allowNonManifestPwaInstall;
  final bool blockExternalAppsEnabled;
  final Map<String, IntentSourcePolicy> externalAppIntentPolicies;

  /// Whether the local search index (`history` table populated via tab→
  /// history triggers) is active. When false, the SQL trigger guard returns
  /// without writing; existing rows stay until the user clears them.
  final bool enableLocalSearchIndex;

  /// Whether private tabs feed the local search index. Defaults to false.
  final bool indexPrivateTabs;

  /// Whether pressing the keyboard submit/enter button should automatically
  /// accept and complete an inline search suggestion. Defaults to false.
  final bool acceptSuggestionOnSubmit;

  /// Whether dark mode should use pure-black ("OLED"/high-contrast) surfaces.
  /// Only takes effect when the effective brightness is dark. Defaults to false.
  final bool pureBlack;

  /// Browser-wide default desktop mode. When true, newly opened tabs request
  /// the desktop version of sites by default. The per-tab desktop-mode toggle
  /// still overrides this for an individual tab. Defaults to false.
  final bool globalDesktopMode;

  /// Hosts that should always load in desktop mode. A tab navigating to a
  /// matching host (or any of its subdomains) is switched to desktop mode,
  /// overriding [globalDesktopMode] for that visit. See `hostMatchesRule`.
  final List<String> desktopModeSites;

  /// Developer setting: when true, the GeckoView is unmounted whenever a
  /// full-cover route (settings, tab tray, search, …) is on top, freeing the
  /// engine's resources while it is occluded. On Android 12 and lower (API
  /// <= 31) this behavior is always applied to work around a native
  /// visibility bug; on Android 13+ the engine normally stays mounted to
  /// avoid reload/flicker, and this flag opts into the off-route unmounting
  /// there too. Defaults to false.
  final bool unmountGeckoViewOffRoute;

  GeneralSettings({
    required this.themeMode,
    required this.uiScaleFactor,
    required this.disableAnimations,
    required this.refreshRateMode,
    required this.showModalBarrier,
    required this.enableReadability,
    required this.enforceReadability,
    required this.deleteBrowsingDataOnQuit,
    required this.screenshotProtectionEnabled,
    required this.defaultSearchProvider,
    required this.defaultSearchSuggestionsProvider,
    required this.createChildTabsOption,
    required this.enableLocalAiFeatures,
    required this.showContainerUi,
    required this.showIsolatedTabUi,
    required this.showSearchCloseButton,
    required this.storedDefaultCreateTabType,
    required this.tabListDirection,
    required this.tabBarDirection,
    required this.tabIntentOpenSetting,
    required this.autoHideTabBar,
    required this.tabBarSwipeAction,
    required this.historyAutoCleanInterval,
    required this.tabViewBottomSheet,
    required this.tabBarShowContextualBar,
    required this.tabBarPosition,
    required this.tabBarLayout,
    required this.tabBarStackingMode,
    required this.pullToRefreshEnabled,
    required this.useExternalDownloadManager,
    required this.doubleBackCloseTab,
    required this.unassignedTabsAutoCleanInterval,
    required this.maxSearchHistoryEntries,
    required this.allowClipboardAccess,
    required this.tabListShowFavicons,
    required this.quickTabSwitcherShowTitles,
    required this.quickTabSwitcherHierarchyGlyphs,
    required this.quickTabSwitcherShowHistorySuggestions,
    required this.quickTabSwitcherTitleWidth,
    required this.quickTabSwitcherShowCloseButtonOnAllTabs,
    required this.syncServerOverride,
    required this.syncTokenServerOverride,
    required this.urlCleanerEnabled,
    required this.urlCleanerAutoApply,
    required this.urlCleanerAllowReferralMarketing,
    required this.urlCleanerCatalogUrl,
    required this.urlCleanerHashUrl,
    required this.urlCleanerAutoUpdate,
    required this.urlCleanerLastCheckEpochMs,
    required this.urlCleanerLastUpdateWasAuto,
    required this.smallWebTabType,
    required this.tabBarLongPressUrlCopy,
    required this.unshortenerEnabled,
    required this.unshortenerToken,
    required this.allowNonManifestPwaInstall,
    required this.blockExternalAppsEnabled,
    required this.externalAppIntentPolicies,
    required this.enableLocalSearchIndex,
    required this.indexPrivateTabs,
    required this.acceptSuggestionOnSubmit,
    required this.pureBlack,
    required this.globalDesktopMode,
    required this.desktopModeSites,
    required this.unmountGeckoViewOffRoute,
  });

  GeneralSettings.withDefaults({
    ThemeMode? themeMode,
    double? uiScaleFactor,
    bool? disableAnimations,
    RefreshRateMode? refreshRateMode,
    bool? showModalBarrier,
    bool? enableReadability,
    bool? enforceReadability,
    this.deleteBrowsingDataOnQuit,
    bool? screenshotProtectionEnabled,
    BangKey? defaultSearchProvider,
    SearchSuggestionProviders? defaultSearchSuggestionsProvider,
    bool? createChildTabsOption,
    bool? enableLocalAiFeatures,
    bool? showContainerUi,
    bool? showIsolatedTabUi,
    bool? showSearchCloseButton,
    TabType? storedDefaultCreateTabType,
    TabDirection? tabListDirection,
    TabDirection? tabBarDirection,
    TabIntentOpenSetting? tabIntentOpenSetting,
    bool? autoHideTabBar,
    TabBarSwipeAction? tabBarSwipeAction,
    Duration? historyAutoCleanInterval,
    bool? tabViewBottomSheet,
    bool? tabBarShowContextualBar,
    TabBarPosition? tabBarPosition,
    TabBarLayout? tabBarLayout,
    TabBarStackingMode? tabBarStackingMode,
    bool? pullToRefreshEnabled,
    bool? useExternalDownloadManager,
    bool? doubleBackCloseTab,
    Duration? unassignedTabsAutoCleanInterval,
    int? maxSearchHistoryEntries,
    bool? allowClipboardAccess,
    bool? tabListShowFavicons,
    bool? quickTabSwitcherShowTitles,
    int? quickTabSwitcherHierarchyGlyphs,
    bool? quickTabSwitcherShowHistorySuggestions,
    double? quickTabSwitcherTitleWidth,
    bool? quickTabSwitcherShowCloseButtonOnAllTabs,
    String? syncServerOverride,
    String? syncTokenServerOverride,
    bool? urlCleanerEnabled,
    bool? urlCleanerAutoApply,
    bool? urlCleanerAllowReferralMarketing,
    String? urlCleanerCatalogUrl,
    String? urlCleanerHashUrl,
    bool? urlCleanerAutoUpdate,
    this.urlCleanerLastCheckEpochMs,
    bool? urlCleanerLastUpdateWasAuto,
    TabType? smallWebTabType,
    bool? tabBarLongPressUrlCopy,
    bool? unshortenerEnabled,
    String? unshortenerToken,
    bool? allowNonManifestPwaInstall,
    bool? blockExternalAppsEnabled,
    Map<String, IntentSourcePolicy>? externalAppIntentPolicies,
    bool? enableLocalSearchIndex,
    bool? indexPrivateTabs,
    bool? acceptSuggestionOnSubmit,
    bool? pureBlack,
    bool? globalDesktopMode,
    List<String>? desktopModeSites,
    bool? unmountGeckoViewOffRoute,
  }) : themeMode = themeMode ?? ThemeMode.dark,
       uiScaleFactor = uiScaleFactor ?? defaultUiScaleFactor,
       disableAnimations = disableAnimations ?? false,
       refreshRateMode = refreshRateMode ?? RefreshRateMode.high,
       showModalBarrier = showModalBarrier ?? true,
       enableReadability = enableReadability ?? true,
       enforceReadability = enforceReadability ?? false,
       screenshotProtectionEnabled = screenshotProtectionEnabled ?? false,
       defaultSearchProvider = defaultSearchProvider ?? _fallbackSearchProvider,
       defaultSearchSuggestionsProvider =
           defaultSearchSuggestionsProvider ?? _fallbackAutocompleteProvider,
       createChildTabsOption = createChildTabsOption ?? false,
       enableLocalAiFeatures = enableLocalAiFeatures ?? true,
       showContainerUi = showContainerUi ?? true,
       showIsolatedTabUi = showIsolatedTabUi ?? true,
       showSearchCloseButton = showSearchCloseButton ?? false,
       storedDefaultCreateTabType =
           storedDefaultCreateTabType ?? TabType.regular,
       tabListDirection = tabListDirection ?? TabDirection.newestFirst,
       tabBarDirection = tabBarDirection ?? TabDirection.newestFirst,
       tabIntentOpenSetting = tabIntentOpenSetting ?? TabIntentOpenSetting.ask,
       autoHideTabBar = autoHideTabBar ?? true,
       tabBarSwipeAction =
           tabBarSwipeAction ?? TabBarSwipeAction.switchLastOpened,
       historyAutoCleanInterval =
           historyAutoCleanInterval ?? const Duration(days: 90),
       tabViewBottomSheet = tabViewBottomSheet ?? false,
       tabBarShowContextualBar = tabBarShowContextualBar ?? true,
       tabBarPosition = tabBarPosition ?? TabBarPosition.bottom,
       tabBarLayout = tabBarLayout ?? TabBarLayout.compact,
       tabBarStackingMode = tabBarStackingMode ?? TabBarStackingMode.accordion,
       pullToRefreshEnabled = pullToRefreshEnabled ?? true,
       useExternalDownloadManager = useExternalDownloadManager ?? false,
       doubleBackCloseTab = doubleBackCloseTab ?? true,
       unassignedTabsAutoCleanInterval =
           unassignedTabsAutoCleanInterval ?? Duration.zero,
       maxSearchHistoryEntries = maxSearchHistoryEntries ?? 5,
       allowClipboardAccess = allowClipboardAccess ?? true,
       tabListShowFavicons = tabListShowFavicons ?? false,
       quickTabSwitcherShowTitles = quickTabSwitcherShowTitles ?? true,
       quickTabSwitcherHierarchyGlyphs =
           quickTabSwitcherHierarchyGlyphs ??
           defaultQuickTabSwitcherHierarchyGlyphs,
       quickTabSwitcherShowHistorySuggestions =
           quickTabSwitcherShowHistorySuggestions ?? true,
       quickTabSwitcherTitleWidth =
           quickTabSwitcherTitleWidth ?? defaultQuickTabSwitcherTitleWidth,
       quickTabSwitcherShowCloseButtonOnAllTabs =
           quickTabSwitcherShowCloseButtonOnAllTabs ?? false,
       syncServerOverride = syncServerOverride ?? '',
       syncTokenServerOverride = syncTokenServerOverride ?? '',
       urlCleanerEnabled = urlCleanerEnabled ?? true,
       urlCleanerAutoApply = urlCleanerAutoApply ?? false,
       urlCleanerAllowReferralMarketing =
           urlCleanerAllowReferralMarketing ?? false,
       urlCleanerCatalogUrl =
           urlCleanerCatalogUrl ??
           'https://rules2.clearurls.xyz/data.minify.json',
       urlCleanerHashUrl =
           urlCleanerHashUrl ??
           'https://rules2.clearurls.xyz/rules.minify.hash',
       urlCleanerAutoUpdate = urlCleanerAutoUpdate ?? false,
       urlCleanerLastUpdateWasAuto = urlCleanerLastUpdateWasAuto ?? false,
       smallWebTabType = smallWebTabType ?? TabType.private,
       tabBarLongPressUrlCopy = tabBarLongPressUrlCopy ?? true,
       unshortenerEnabled = unshortenerEnabled ?? false,
       unshortenerToken = unshortenerToken ?? '',
       allowNonManifestPwaInstall = allowNonManifestPwaInstall ?? false,
       blockExternalAppsEnabled = blockExternalAppsEnabled ?? false,
       externalAppIntentPolicies = externalAppIntentPolicies ?? const {},
       enableLocalSearchIndex = enableLocalSearchIndex ?? true,
       indexPrivateTabs = indexPrivateTabs ?? false,
       acceptSuggestionOnSubmit = acceptSuggestionOnSubmit ?? false,
       pureBlack = pureBlack ?? false,
       globalDesktopMode = globalDesktopMode ?? false,
       desktopModeSites = desktopModeSites ?? const [],
       unmountGeckoViewOffRoute = unmountGeckoViewOffRoute ?? false;

  factory GeneralSettings.fromJson(Map<String, dynamic> json) {
    // Migrate legacy `newTabPosition` setting to direction settings.
    // Old `first` (new tabs at top) → newestFirst; `end` → oldestFirst.
    // TODO: Drop this fallback (and the `newTabPosition` row in the user
    // settings DB) once enough releases have shipped that rolling back to a
    // version without `tabListDirection`/`tabBarDirection` is no longer a
    // concern.
    final legacyNewTabPosition = json['newTabPosition'];
    if (legacyNewTabPosition != null) {
      final mapped = legacyNewTabPosition == 'end'
          ? 'oldestFirst'
          : 'newestFirst';
      json.putIfAbsent('tabListDirection', () => mapped);
      json.putIfAbsent('tabBarDirection', () => mapped);
    }

    // Migrate the legacy `tabBarShowQuickTabSwitcherBar` toggle and
    // `quickTabSwitcherMode` selection to the merged `tabBarStackingMode`.
    // The legacy mode names are a subset of the new enum's, so values map
    // verbatim.
    // TODO: Drop this fallback (and the legacy rows in the user settings DB)
    // once enough releases have shipped that rolling back to a version
    // without `tabBarStackingMode` is no longer a concern.
    final legacyShowSwitcherBar = json['tabBarShowQuickTabSwitcherBar'];
    final legacySwitcherMode = json['quickTabSwitcherMode'];
    if (json['tabBarStackingMode'] == null) {
      if (legacyShowSwitcherBar == false) {
        json['tabBarStackingMode'] = 'disabled';
      } else if (legacySwitcherMode != null) {
        json['tabBarStackingMode'] = legacySwitcherMode;
      }
    }

    return _$GeneralSettingsFromJson(json);
  }

  Map<String, dynamic> toJson() => _$GeneralSettingsToJson(this);

  TabType get effectiveDefaultCreateTabType {
    if (!showIsolatedTabUi && storedDefaultCreateTabType == TabType.isolated) {
      return TabType.regular;
    }
    return storedDefaultCreateTabType;
  }

  TabType get effectiveSmallWebTabType {
    if (!showIsolatedTabUi && smallWebTabType == TabType.isolated) {
      return TabType.private;
    }
    return smallWebTabType;
  }

  TabIntentOpenSetting get effectiveTabIntentOpenSetting {
    if (!showIsolatedTabUi &&
        tabIntentOpenSetting == TabIntentOpenSetting.isolated) {
      return TabIntentOpenSetting.ask;
    }
    return tabIntentOpenSetting;
  }

  /// Container-dependent stacking modes degrade to a single recently-used
  /// row when the container UI is disabled.
  TabBarStackingMode effectiveTabBarStackingMode() {
    if (!showContainerUi &&
        const {
          TabBarStackingMode.containerTabs,
          TabBarStackingMode.accordion,
          TabBarStackingMode.twoLevel,
        }.contains(tabBarStackingMode)) {
      return TabBarStackingMode.lastUsedTabs;
    }
    return tabBarStackingMode;
  }

  @override
  List<Object?> get hashParameters => [
    themeMode,
    uiScaleFactor,
    disableAnimations,
    refreshRateMode,
    showModalBarrier,
    enableReadability,
    enforceReadability,
    deleteBrowsingDataOnQuit,
    screenshotProtectionEnabled,
    defaultSearchProvider,
    defaultSearchSuggestionsProvider,
    createChildTabsOption,
    enableLocalAiFeatures,
    showContainerUi,
    showIsolatedTabUi,
    showSearchCloseButton,
    storedDefaultCreateTabType,
    tabListDirection,
    tabBarDirection,
    tabIntentOpenSetting,
    autoHideTabBar,
    tabBarSwipeAction,
    historyAutoCleanInterval,
    tabViewBottomSheet,
    tabBarShowContextualBar,
    tabBarPosition,
    tabBarLayout,
    tabBarStackingMode,
    pullToRefreshEnabled,
    useExternalDownloadManager,
    doubleBackCloseTab,
    unassignedTabsAutoCleanInterval,
    maxSearchHistoryEntries,
    allowClipboardAccess,
    tabListShowFavicons,
    quickTabSwitcherShowTitles,
    quickTabSwitcherHierarchyGlyphs,
    quickTabSwitcherShowHistorySuggestions,
    quickTabSwitcherTitleWidth,
    quickTabSwitcherShowCloseButtonOnAllTabs,
    syncServerOverride,
    syncTokenServerOverride,
    urlCleanerEnabled,
    urlCleanerAutoApply,
    urlCleanerAllowReferralMarketing,
    urlCleanerCatalogUrl,
    urlCleanerHashUrl,
    urlCleanerAutoUpdate,
    urlCleanerLastCheckEpochMs,
    urlCleanerLastUpdateWasAuto,
    smallWebTabType,
    tabBarLongPressUrlCopy,
    unshortenerEnabled,
    unshortenerToken,
    allowNonManifestPwaInstall,
    blockExternalAppsEnabled,
    externalAppIntentPolicies,
    enableLocalSearchIndex,
    indexPrivateTabs,
    acceptSuggestionOnSubmit,
    pureBlack,
    globalDesktopMode,
    desktopModeSites,
    unmountGeckoViewOffRoute,
  ];
}
