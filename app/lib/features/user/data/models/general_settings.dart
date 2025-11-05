/*
 * Copyright (c) 2024-2025 Fabian Freund.
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

enum TabBarSwipeAction { switchLastOpened, navigateOrderedTabs }

enum TabIntentOpenSetting { regular, private, ask }

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
  final bool enableReadability;
  final bool enforceReadability;
  final Set<DeleteBrowsingDataType>? deleteBrowsingDataOnQuit;
  @BangKeyConverter()
  final BangKey? defaultSearchProvider;
  final SearchSuggestionProviders defaultSearchSuggestionsProvider;
  final bool createChildTabsOption;
  final bool showExtensionShortcut;
  final bool enableLocalAiFeatures;
  final TabType defaultCreateTabType;
  final TabIntentOpenSetting tabIntentOpenSetting;
  final bool autoHideTabBar;
  final TabBarSwipeAction tabBarSwipeAction;
  final Duration historyAutoCleanInterval;
  final bool tabViewBottomSheet;
  final bool tabBarReaderView;

  GeneralSettings({
    required this.themeMode,
    required this.enableReadability,
    required this.enforceReadability,
    required this.deleteBrowsingDataOnQuit,
    required this.defaultSearchProvider,
    required this.defaultSearchSuggestionsProvider,
    required this.createChildTabsOption,
    required this.showExtensionShortcut,
    required this.enableLocalAiFeatures,
    required this.defaultCreateTabType,
    required this.tabIntentOpenSetting,
    required this.autoHideTabBar,
    required this.tabBarSwipeAction,
    required this.historyAutoCleanInterval,
    required this.tabViewBottomSheet,
    required this.tabBarReaderView,
  });

  GeneralSettings.withDefaults({
    ThemeMode? themeMode,
    bool? enableReadability,
    bool? enforceReadability,
    this.deleteBrowsingDataOnQuit,
    BangKey? defaultSearchProvider,
    SearchSuggestionProviders? defaultSearchSuggestionsProvider,
    bool? createChildTabsOption,
    bool? showExtensionShortcut,
    bool? enableLocalAiFeatures,
    TabType? defaultCreateTabType,
    TabIntentOpenSetting? tabIntentOpenSetting,
    bool? autoHideTabBar,
    TabBarSwipeAction? tabBarSwipeAction,
    Duration? historyAutoCleanInterval,
    bool? tabViewBottomSheet,
    bool? tabBarReaderView,
  }) : themeMode = themeMode ?? ThemeMode.dark,
       enableReadability = enableReadability ?? true,
       enforceReadability = enforceReadability ?? false,
       defaultSearchProvider = defaultSearchProvider ?? _fallbackSearchProvider,
       defaultSearchSuggestionsProvider =
           defaultSearchSuggestionsProvider ?? _fallbackAutocompleteProvider,
       createChildTabsOption = createChildTabsOption ?? false,
       showExtensionShortcut = showExtensionShortcut ?? false,
       enableLocalAiFeatures = enableLocalAiFeatures ?? true,
       defaultCreateTabType = defaultCreateTabType ?? TabType.regular,
       tabIntentOpenSetting = tabIntentOpenSetting ?? TabIntentOpenSetting.ask,
       autoHideTabBar = autoHideTabBar ?? true,
       tabBarSwipeAction =
           tabBarSwipeAction ?? TabBarSwipeAction.switchLastOpened,
       historyAutoCleanInterval =
           historyAutoCleanInterval ?? const Duration(days: 90),
       tabViewBottomSheet = tabViewBottomSheet ?? false,
       tabBarReaderView = tabBarReaderView ?? false;

  factory GeneralSettings.fromJson(Map<String, dynamic> json) =>
      _$GeneralSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$GeneralSettingsToJson(this);

  @override
  List<Object?> get hashParameters => [
    themeMode,
    enableReadability,
    enforceReadability,
    deleteBrowsingDataOnQuit,
    defaultSearchProvider,
    defaultSearchSuggestionsProvider,
    createChildTabsOption,
    showExtensionShortcut,
    enableLocalAiFeatures,
    defaultCreateTabType,
    tabIntentOpenSetting,
    autoHideTabBar,
    tabBarSwipeAction,
    historyAutoCleanInterval,
    tabViewBottomSheet,
    tabBarReaderView,
  ];
}
