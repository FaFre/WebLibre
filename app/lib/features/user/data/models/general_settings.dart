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

enum TabBarSwipeAction { switchLastOpened, navigateOrderedTabs }

enum QuickTabSwitcherMode { lastUsedTabs, containerTabs }

enum TabIntentOpenSetting { regular, private, ask }

enum NewTabPosition { first, end }

enum TabBarPosition { top, bottom }

enum TabBarLayout { withTitle, compact }

enum DeleteBrowsingDataType {
  tabs('Open tabs'),
  history('Browsing history'),
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
  final bool showModalBarrier;
  final bool enableReadability;
  final bool enforceReadability;
  final Set<DeleteBrowsingDataType>? deleteBrowsingDataOnQuit;
  @BangKeyConverter()
  final BangKey? defaultSearchProvider;
  final SearchSuggestionProviders defaultSearchSuggestionsProvider;
  final bool createChildTabsOption;
  final bool enableLocalAiFeatures;
  final bool showContainerUi;
  final bool showIsolatedTabUi;
  @JsonKey(name: 'defaultCreateTabType')
  final TabType storedDefaultCreateTabType;
  final NewTabPosition newTabPosition;
  final TabIntentOpenSetting tabIntentOpenSetting;
  final bool autoHideTabBar;
  final TabBarSwipeAction tabBarSwipeAction;
  final Duration historyAutoCleanInterval;
  final bool tabViewBottomSheet;
  final bool tabBarShowContextualBar;
  final bool tabBarShowQuickTabSwitcherBar;
  final TabBarPosition tabBarPosition;
  final TabBarLayout tabBarLayout;
  final QuickTabSwitcherMode quickTabSwitcherMode;
  final bool pullToRefreshEnabled;
  final bool useExternalDownloadManager;
  final bool doubleBackCloseTab;
  final Duration unassignedTabsAutoCleanInterval;
  final int maxSearchHistoryEntries;
  final bool allowClipboardAccess;
  final bool tabListShowFavicons;
  final bool quickTabSwitcherShowTitles;
  final bool quickTabSwitcherShowHistorySuggestions;
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
  final bool unshortenerEnabled;
  final String unshortenerToken;

  GeneralSettings({
    required this.themeMode,
    required this.uiScaleFactor,
    required this.disableAnimations,
    required this.showModalBarrier,
    required this.enableReadability,
    required this.enforceReadability,
    required this.deleteBrowsingDataOnQuit,
    required this.defaultSearchProvider,
    required this.defaultSearchSuggestionsProvider,
    required this.createChildTabsOption,
    required this.enableLocalAiFeatures,
    required this.showContainerUi,
    required this.showIsolatedTabUi,
    required this.storedDefaultCreateTabType,
    required this.newTabPosition,
    required this.tabIntentOpenSetting,
    required this.autoHideTabBar,
    required this.tabBarSwipeAction,
    required this.historyAutoCleanInterval,
    required this.tabViewBottomSheet,
    required this.tabBarShowContextualBar,
    required this.tabBarShowQuickTabSwitcherBar,
    required this.tabBarPosition,
    required this.tabBarLayout,
    required this.quickTabSwitcherMode,
    required this.pullToRefreshEnabled,
    required this.useExternalDownloadManager,
    required this.doubleBackCloseTab,
    required this.unassignedTabsAutoCleanInterval,
    required this.maxSearchHistoryEntries,
    required this.allowClipboardAccess,
    required this.tabListShowFavicons,
    required this.quickTabSwitcherShowTitles,
    required this.quickTabSwitcherShowHistorySuggestions,
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
    required this.unshortenerEnabled,
    required this.unshortenerToken,
  });

  GeneralSettings.withDefaults({
    ThemeMode? themeMode,
    double? uiScaleFactor,
    bool? disableAnimations,
    bool? showModalBarrier,
    bool? enableReadability,
    bool? enforceReadability,
    this.deleteBrowsingDataOnQuit,
    BangKey? defaultSearchProvider,
    SearchSuggestionProviders? defaultSearchSuggestionsProvider,
    bool? createChildTabsOption,
    bool? enableLocalAiFeatures,
    bool? showContainerUi,
    bool? showIsolatedTabUi,
    TabType? storedDefaultCreateTabType,
    NewTabPosition? newTabPosition,
    TabIntentOpenSetting? tabIntentOpenSetting,
    bool? autoHideTabBar,
    TabBarSwipeAction? tabBarSwipeAction,
    Duration? historyAutoCleanInterval,
    bool? tabViewBottomSheet,
    bool? tabBarShowContextualBar,
    bool? tabBarShowQuickTabSwitcherBar,
    TabBarPosition? tabBarPosition,
    TabBarLayout? tabBarLayout,
    QuickTabSwitcherMode? quickTabSwitcherMode,
    bool? pullToRefreshEnabled,
    bool? useExternalDownloadManager,
    bool? doubleBackCloseTab,
    Duration? unassignedTabsAutoCleanInterval,
    int? maxSearchHistoryEntries,
    bool? allowClipboardAccess,
    bool? tabListShowFavicons,
    bool? quickTabSwitcherShowTitles,
    bool? quickTabSwitcherShowHistorySuggestions,
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
    bool? unshortenerEnabled,
    String? unshortenerToken,
  }) : themeMode = themeMode ?? ThemeMode.dark,
       uiScaleFactor = uiScaleFactor ?? defaultUiScaleFactor,
       disableAnimations = disableAnimations ?? false,
       showModalBarrier = showModalBarrier ?? true,
       enableReadability = enableReadability ?? true,
       enforceReadability = enforceReadability ?? false,
       defaultSearchProvider = defaultSearchProvider ?? _fallbackSearchProvider,
       defaultSearchSuggestionsProvider =
           defaultSearchSuggestionsProvider ?? _fallbackAutocompleteProvider,
       createChildTabsOption = createChildTabsOption ?? false,
       enableLocalAiFeatures = enableLocalAiFeatures ?? true,
       showContainerUi = showContainerUi ?? true,
       showIsolatedTabUi = showIsolatedTabUi ?? true,
       storedDefaultCreateTabType =
           storedDefaultCreateTabType ?? TabType.regular,
       newTabPosition = newTabPosition ?? NewTabPosition.first,
       tabIntentOpenSetting = tabIntentOpenSetting ?? TabIntentOpenSetting.ask,
       autoHideTabBar = autoHideTabBar ?? true,
       tabBarSwipeAction =
           tabBarSwipeAction ?? TabBarSwipeAction.switchLastOpened,
       historyAutoCleanInterval =
           historyAutoCleanInterval ?? const Duration(days: 90),
       tabViewBottomSheet = tabViewBottomSheet ?? false,
       tabBarShowContextualBar = tabBarShowContextualBar ?? true,
       tabBarShowQuickTabSwitcherBar = tabBarShowQuickTabSwitcherBar ?? true,
       tabBarPosition = tabBarPosition ?? TabBarPosition.bottom,
       tabBarLayout = tabBarLayout ?? TabBarLayout.compact,
       quickTabSwitcherMode =
           quickTabSwitcherMode ?? QuickTabSwitcherMode.lastUsedTabs,
       pullToRefreshEnabled = pullToRefreshEnabled ?? true,
       useExternalDownloadManager = useExternalDownloadManager ?? false,
       doubleBackCloseTab = doubleBackCloseTab ?? true,
       unassignedTabsAutoCleanInterval =
           unassignedTabsAutoCleanInterval ?? Duration.zero,
       maxSearchHistoryEntries = maxSearchHistoryEntries ?? 5,
       allowClipboardAccess = allowClipboardAccess ?? true,
       tabListShowFavicons = tabListShowFavicons ?? false,
       quickTabSwitcherShowTitles = quickTabSwitcherShowTitles ?? true,
       quickTabSwitcherShowHistorySuggestions =
           quickTabSwitcherShowHistorySuggestions ?? true,
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
       unshortenerEnabled = unshortenerEnabled ?? false,
       unshortenerToken = unshortenerToken ?? '';

  factory GeneralSettings.fromJson(Map<String, dynamic> json) =>
      _$GeneralSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$GeneralSettingsToJson(this);

  TabType get effectiveDefaultCreateTabType {
    if (!showIsolatedTabUi && storedDefaultCreateTabType == TabType.isolated) {
      return TabType.regular;
    }
    return storedDefaultCreateTabType;
  }

  QuickTabSwitcherMode effectiveUiQuickTabSwitcherMode() {
    if (!showContainerUi &&
        quickTabSwitcherMode == QuickTabSwitcherMode.containerTabs) {
      return QuickTabSwitcherMode.lastUsedTabs;
    }
    return quickTabSwitcherMode;
  }

  @override
  List<Object?> get hashParameters => [
    themeMode,
    uiScaleFactor,
    disableAnimations,
    showModalBarrier,
    enableReadability,
    enforceReadability,
    deleteBrowsingDataOnQuit,
    defaultSearchProvider,
    defaultSearchSuggestionsProvider,
    createChildTabsOption,
    enableLocalAiFeatures,
    showContainerUi,
    showIsolatedTabUi,
    storedDefaultCreateTabType,
    newTabPosition,
    tabIntentOpenSetting,
    autoHideTabBar,
    tabBarSwipeAction,
    historyAutoCleanInterval,
    tabViewBottomSheet,
    tabBarShowContextualBar,
    tabBarShowQuickTabSwitcherBar,
    tabBarPosition,
    tabBarLayout,
    quickTabSwitcherMode,
    pullToRefreshEnabled,
    useExternalDownloadManager,
    doubleBackCloseTab,
    unassignedTabsAutoCleanInterval,
    maxSearchHistoryEntries,
    allowClipboardAccess,
    tabListShowFavicons,
    quickTabSwitcherShowTitles,
    quickTabSwitcherShowHistorySuggestions,
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
    unshortenerEnabled,
    unshortenerToken,
  ];
}
