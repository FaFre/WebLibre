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
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_view_filter_options.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'tab_view_controllers.g.dart';

enum TabsViewMode {
  list(MdiIcons.folderTable),
  grid(MdiIcons.table),
  tree(MdiIcons.familyTree);

  final IconData icon;

  const TabsViewMode(this.icon);
}

@Riverpod(keepAlive: true)
class TabsViewModeController extends _$TabsViewModeController {
  void set(TabsViewMode mode) {
    if (mode != state) {
      state = mode;
    }
  }

  @override
  TabsViewMode build() {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: 'TabsViewMode',
      options: const StorageOptions(cacheTime: StorageCacheTime.unsafe_forever),
      encode: (state) => jsonEncode([state.name]),
      decode: (encoded) {
        final name = (jsonDecode(encoded) as List<dynamic>).first as String;
        return TabsViewMode.values.firstWhere((e) => e.name == name);
      },
    );

    return stateOrNull ?? TabsViewMode.list;
  }
}

/// Whether the Tree layout is offered (`tabs.tree_view_mode`, guarded by
/// `switch.tree_tabs`).
@Riverpod(keepAlive: true)
bool treeViewModeShown(Ref ref) => ref.watch(
  generalSettingsWithDefaultsProvider.select(
    (s) => s.isFeatureShown(FeatureId.tabsTreeViewMode),
  ),
);

/// The layout the tab view draws: the saved [TabsViewModeController] choice,
/// except that a hidden Tree layout is drawn as List. The saved choice is left
/// alone, so Tree comes back when it is shown again (acceptance scenario 18).
/// Tree relationships are recorded either way; Tab Groups read them.
@Riverpod(keepAlive: true)
TabsViewMode effectiveTabsViewMode(Ref ref) {
  final mode = ref.watch(tabsViewModeControllerProvider);
  if (mode == TabsViewMode.tree && !ref.watch(treeViewModeShownProvider)) {
    return TabsViewMode.list;
  }
  return mode;
}

/// Whether List and Grid draw the tab hierarchy: the saved filter choice,
/// while `tabs.hierarchy_display` is shown. The choice is kept while hidden,
/// like a hidden Tree layout.
@Riverpod(keepAlive: true)
bool effectiveShowHierarchicalTabs(Ref ref) {
  final shown = ref.watch(
    generalSettingsWithDefaultsProvider.select(
      (s) => s.isFeatureShown(FeatureId.tabsHierarchyDisplay),
    ),
  );
  final enabled = ref.watch(
    tabViewFilterControllerProvider.select((o) => o.showHierarchicalTabs),
  );
  return shown && enabled;
}

/// The layouts the view menu and the pinch cycle offer, in [order].
List<TabsViewMode> offeredTabsViewModes({
  required bool treeShown,
  List<TabsViewMode> order = TabsViewMode.values,
}) => [
  for (final mode in order)
    if (mode != TabsViewMode.tree || treeShown) mode,
];

@Riverpod(keepAlive: true)
@JsonPersist()
class TabViewFilterController extends _$TabViewFilterController {
  void setTabTypeFilter(TabTypeFilter filter) {
    state = state.copyWith.tabTypeFilter(filter);
  }

  void setSortType(TabSortType sort) {
    state = state.copyWith.sortType(sort);
  }

  void setSortPinnedFirst(bool value) {
    state = state.copyWith(sortPinnedFirst: value);
  }

  void setShowHierarchicalTabs(bool value) {
    state = state.copyWith(showHierarchicalTabs: value);
  }

  void setDateRange(DateTimeRange<DateTime>? range) {
    state = state.copyWith(dateRange: range, quickInterval: null);
  }

  void setQuickInterval(TabQuickInterval? interval) {
    state = state.copyWith(quickInterval: interval, dateRange: null);
  }

  void reset() {
    state = TabViewFilterOptions.withDefaults();
  }

  @override
  TabViewFilterOptions build() {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: 'TabViewFilterOptions',
      options: const StorageOptions(
        cacheTime: StorageCacheTime(Duration(days: 7)),
      ),
    );

    return stateOrNull ?? TabViewFilterOptions.withDefaults();
  }
}

/// Tracks which parent groups are *collapsed* in the grouped list/grid views.
///
/// Stored as the collapsed set so groups default to expanded for fresh
/// sessions. In-memory only — group expansion is treated as ephemeral UI
/// state, not a persisted setting.
@Riverpod(keepAlive: true)
class CollapsedGroups extends _$CollapsedGroups {
  @override
  Set<String> build() => const {};

  void toggle(String parentId) {
    state = state.contains(parentId)
        ? (state.toSet()..remove(parentId))
        : (state.toSet()..add(parentId));
  }

  void expandAll() => state = const {};
}

@Riverpod()
class TabsReorderableController extends _$TabsReorderableController {
  void toggle() {
    state = !state;
  }

  void hide() {
    if (state) {
      state = false;
    }
  }

  @override
  bool build() {
    return false;
  }
}

/// Whether the tab tray's search field replaces its action row.
///
/// Shared rather than local to the header because the action row that opens
/// the search can sit at the bottom of the tray (#651) while the field itself
/// always opens at the top, clear of the keyboard.
@Riverpod()
class TabViewSearchModeController extends _$TabViewSearchModeController {
  void show() => state = true;

  void hide() => state = false;

  @override
  bool build() {
    return false;
  }
}
