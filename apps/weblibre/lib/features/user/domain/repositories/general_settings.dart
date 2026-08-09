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
import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'general_settings.g.dart';

typedef UpdateGeneralSettingsFunc =
    GeneralSettings Function(GeneralSettings currentSettings);

/// Column type for every persisted `general` setting, keyed by its JSON name.
///
/// Also carries legacy keys that no longer exist on [GeneralSettings] but are
/// still read so the migrations in `GeneralSettings.fromJson` keep working.
///
/// **Every field on [GeneralSettings] must appear here or in
/// [generalSettingJsonKeys].** A missing entry means the setting writes fine
/// but silently reverts to its default on the next launch, because it is never
/// read back out of the database. `general_settings_deserialize_test.dart`
/// guards this.
@visibleForTesting
const generalSettingColumnTypes = <String, DriftSqlType>{
  'themeMode': DriftSqlType.string,
  'uiScaleFactor': DriftSqlType.double,
  'disableAnimations': DriftSqlType.bool,
  'refreshRateMode': DriftSqlType.string,
  'showModalBarrier': DriftSqlType.bool,
  'enableReadability': DriftSqlType.bool,
  'enforceReadability': DriftSqlType.bool,
  'screenshotProtectionEnabled': DriftSqlType.bool,
  'defaultSearchProvider': DriftSqlType.string,
  'defaultSearchSuggestionsProvider': DriftSqlType.string,
  'createChildTabsOption': DriftSqlType.bool,
  'enableLocalAiFeatures': DriftSqlType.bool,
  'showContainerUi': DriftSqlType.bool,
  'showIsolatedTabUi': DriftSqlType.bool,
  'defaultCreateTabType': DriftSqlType.string,
  // Legacy: superseded by tabListDirection/tabBarDirection.
  'newTabPosition': DriftSqlType.string,
  'tabListDirection': DriftSqlType.string,
  'tabBarDirection': DriftSqlType.string,
  'tabIntentOpenSetting': DriftSqlType.string,
  'bookmarkOpenSetting': DriftSqlType.string,
  'backgroundTabOpenAction': DriftSqlType.string,
  'autoHideTabBar': DriftSqlType.bool,
  'tabBarSwipeAction': DriftSqlType.string,
  'historyAutoCleanInterval': DriftSqlType.int,
  'tabViewBottomSheet': DriftSqlType.bool,
  'tabBarShowContextualBar': DriftSqlType.bool,
  // Legacy: folded into tabBarStackingMode.
  'tabBarShowQuickTabSwitcherBar': DriftSqlType.bool,
  'tabBarPosition': DriftSqlType.string,
  'tabBarLayout': DriftSqlType.string,
  // Legacy: folded into tabBarStackingMode.
  'quickTabSwitcherMode': DriftSqlType.string,
  'tabBarStackingMode': DriftSqlType.string,
  'pullToRefreshEnabled': DriftSqlType.bool,
  'useExternalDownloadManager': DriftSqlType.bool,
  'doubleBackCloseTab': DriftSqlType.bool,
  'unassignedTabsAutoCleanInterval': DriftSqlType.int,
  'maxSearchHistoryEntries': DriftSqlType.int,
  'allowClipboardAccess': DriftSqlType.bool,
  'tabListShowFavicons': DriftSqlType.bool,
  'quickTabSwitcherShowTitles': DriftSqlType.bool,
  'quickTabSwitcherHierarchyGlyphs': DriftSqlType.int,
  'quickTabSwitcherShowHistorySuggestions': DriftSqlType.bool,
  'quickTabSwitcherTitleWidth': DriftSqlType.double,
  'quickTabSwitcherShowCloseButtonOnAllTabs': DriftSqlType.bool,
  'syncServerOverride': DriftSqlType.string,
  'syncTokenServerOverride': DriftSqlType.string,
  'urlCleanerEnabled': DriftSqlType.bool,
  'urlCleanerAutoApply': DriftSqlType.bool,
  'urlCleanerAllowReferralMarketing': DriftSqlType.bool,
  'urlCleanerCatalogUrl': DriftSqlType.string,
  'urlCleanerHashUrl': DriftSqlType.string,
  'urlCleanerAutoUpdate': DriftSqlType.bool,
  'urlCleanerLastCheckEpochMs': DriftSqlType.int,
  'urlCleanerLastUpdateWasAuto': DriftSqlType.bool,
  'smallWebTabType': DriftSqlType.string,
  'tabBarLongPressUrlCopy': DriftSqlType.bool,
  'unshortenerEnabled': DriftSqlType.bool,
  'unshortenerToken': DriftSqlType.string,
  'allowNonManifestPwaInstall': DriftSqlType.bool,
  'blockExternalAppsEnabled': DriftSqlType.bool,
  'customTabsEnabled': DriftSqlType.bool,
  'appLinksMode': DriftSqlType.string,
  'appLinkMarketplaceFallback': DriftSqlType.bool,
  'appLinkAuthExceptionsEnabled': DriftSqlType.bool,
  'enableLocalSearchIndex': DriftSqlType.bool,
  'indexPrivateTabs': DriftSqlType.bool,
  'acceptSuggestionOnSubmit': DriftSqlType.bool,
  'popularSitesAutocompleteEnabled': DriftSqlType.bool,
  'pureBlack': DriftSqlType.bool,
  'showSearchCloseButton': DriftSqlType.bool,
  'homeTarget': DriftSqlType.string,
  'homeTargetUrl': DriftSqlType.string,
  'homeTargetOnLastTabClosed': DriftSqlType.bool,
  'globalDesktopMode': DriftSqlType.bool,
  'unmountGeckoViewOffRoute': DriftSqlType.bool,
};

/// Settings stored as a JSON document in a TEXT column. Their value has to be
/// decoded before it reaches `GeneralSettings.fromJson`, which expects the
/// already-parsed list/map.
@visibleForTesting
const generalSettingJsonKeys = <String>{
  'deleteBrowsingDataOnQuit',
  'externalAppIntentPolicies',
  'appLinkRules',
  'appLinkContextOverrides',
  'desktopModeSites',
};

@Riverpod(keepAlive: true)
class GeneralSettingsRepository extends _$GeneralSettingsRepository {
  final _partitionKey = 'general';

  GeneralSettings _deserializeSettings(
    List<MapEntry<String, DriftAny?>> entries,
  ) {
    final settings = Map.fromEntries(entries);

    final typeMapping = ref.read(userDatabaseProvider).typeMapping;

    return GeneralSettings.fromJson({
      for (final MapEntry(key: key, value: type)
          in generalSettingColumnTypes.entries)
        key: settings[key]?.readAs(type, typeMapping),
      for (final key in generalSettingJsonKeys)
        key: settings[key]
            ?.readAs(DriftSqlType.string, typeMapping)
            .mapNotNull(jsonDecode),
    });
  }

  //Eager fetch, when up to date settings are required
  Future<GeneralSettings> fetchSettings() {
    return ref
        .read(userDatabaseProvider)
        .settingDao
        .getAllSettingsOfPartitionKey(_partitionKey)
        .get()
        .then(_deserializeSettings);
  }

  Future<void> updateSettings(
    UpdateGeneralSettingsFunc updateWithCurrent,
  ) async {
    final db = ref.read(userDatabaseProvider);

    final current = await fetchSettings();

    final oldJson = current.toJson();
    final newJson = updateWithCurrent(current).toJson();

    return db.transaction(() async {
      for (final MapEntry(:key, :value) in newJson.entries) {
        if (oldJson[key] != value) {
          await db.settingDao.updateSetting(key, _partitionKey, value);
        }
      }
    });
  }

  @override
  Stream<GeneralSettings> build() {
    final db = ref.watch(userDatabaseProvider);

    return db.settingDao
        .getAllSettingsOfPartitionKey(_partitionKey)
        .watch()
        .map((event) {
          return _deserializeSettings(event);
        });
  }
}

@Riverpod(keepAlive: true)
GeneralSettings generalSettingsWithDefaults(Ref ref) {
  return ref.watch(
    generalSettingsRepositoryProvider.select(
      (value) => value.value ?? GeneralSettings.withDefaults(),
    ),
  );
}
