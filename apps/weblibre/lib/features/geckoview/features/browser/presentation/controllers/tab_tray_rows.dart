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
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_list_scope.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_view_item.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_entity.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab_search.dart';

part 'tab_tray_rows.g.dart';

/// Whether the tab tray is showing search results.
@Riverpod()
bool tabTraySearchActive(Ref ref) => ref.watch(
  tabSearchRepositoryProvider(
    TabSearchPartition.preview,
  ).select((value) => (value.value?.query ?? '').isNotEmpty),
);

/// The rows the tab tray's list and grid draw for [containerId]: the flat
/// search results while a search is active, otherwise the tray's grouped
/// tab list. Only the source in use is watched.
@Riverpod()
List<TabViewItem> tabTrayRows(Ref ref, String? containerId) {
  final searchActive = ref.watch(tabTraySearchActiveProvider);
  if (searchActive) {
    final flat = ref.watch(
      seamlessFilteredTabEntitiesProvider(
        searchPartition: TabSearchPartition.preview,
        // ignore: document_ignores using fast equatable
        // ignore: provider_parameters
        containerFilter: ContainerFilterById(containerId: containerId),
        groupTrees: false,
      ),
    );
    return [
      for (final entity in flat.value)
        TabViewItem.search(
          tabId: entity.tabId,
          sourceSearchQuery: switch (entity) {
            DefaultTabEntity _ => null,
            final SearchResultTabEntity e => e.searchQuery,
            TabTreeEntity _ => null,
          },
        ),
    ];
  }

  final showHierarchicalTabs = ref.watch(effectiveShowHierarchicalTabsProvider);
  final visibleItems = ref.watch(
    visibleTabListItemsProvider(
      containerId: containerId,
      scope: TabListScope.tray,
    ),
  );
  return [
    for (final item in visibleItems.value)
      switch (item) {
        TabListStandaloneItem(:final tabId) => TabViewItem.standalone(
          tabId: tabId,
        ),
        final TabListParentGroup g =>
          showHierarchicalTabs
              ? TabViewItem.parent(tabId: g.tabId, parentGroup: g)
              : TabViewItem.standalone(tabId: g.tabId),
        final TabListChildItem c =>
          showHierarchicalTabs
              ? TabViewItem.child(tabId: c.tabId, childItem: c)
              : TabViewItem.standalone(tabId: c.tabId),
      },
  ];
}
