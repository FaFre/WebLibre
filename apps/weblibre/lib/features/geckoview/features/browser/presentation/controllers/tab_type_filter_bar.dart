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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_view_filter_options.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';

part 'tab_type_filter_bar.g.dart';

/// The kinds of tab open right now, as the filters that would list them.
@Riverpod()
EquatableValue<Set<TabTypeFilter>> openTabTypes(Ref ref) => ref.watch(
  tabSortKeysProvider.select(
    (keys) => EquatableValue({
      for (final key in keys.value.values) _filterFor(key.tabMode),
    }),
  ),
);

TabTypeFilter _filterFor(TabMode tabMode) => switch (tabMode) {
  RegularTabMode() => TabTypeFilter.regularOnly,
  PrivateTabMode() => TabTypeFilter.privateOnly,
  IsolatedTabMode() => TabTypeFilter.isolatedOnly,
};

/// Whether the tray's header shows the tab type filter bar.
///
/// Only once there is a choice to make: while tabs of more than one kind are
/// open, or while the filter is set — the filter persists, and must never hide
/// tabs out of sight. Not in the tree view, which ignores the filter, nor for
/// synced tabs, which have no kind.
@Riverpod()
bool tabTypeFilterBarVisible(Ref ref, TabsViewMode tabsViewMode) {
  if (tabsViewMode == TabsViewMode.tree) return false;

  final isSyncedScope = ref.watch(
    effectiveTabsTrayScopeProvider.select(
      (scope) => scope == TabsTrayScope.synced,
    ),
  );
  if (isSyncedScope) return false;

  final selected = ref.watch(
    tabViewFilterControllerProvider.select((options) => options.tabTypeFilter),
  );
  if (selected != TabTypeFilter.all) return true;

  final openTypes = ref.watch(openTabTypesProvider);
  return openTypes.value.length > 1;
}
