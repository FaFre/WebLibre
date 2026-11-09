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
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_list_scope.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_view_filter_options.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_tray_rows.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_entity.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab_search.dart';

part 'tab_picker_rows.g.dart';

/// A tab the tray offers while it picks one.
typedef TabPickerRow = ({String tabId, int depth});

/// Whether the tray, picking a tab of the given privacy ([privateTabs]) with
/// its own [typeFilter], offers a tab of [mode]. A tab with no known mode is
/// not offered.
bool tabPickerOffers(
  TabMode? mode, {
  required bool privateTabs,
  required TabTypeFilter typeFilter,
}) =>
    mode != null &&
    (mode is PrivateTabMode) == privateTabs &&
    typeFilter.matches(mode);

/// The tabs of [containerId] the tray offers while it picks one: the tray's
/// search results while it searches, otherwise every tab in the order of the
/// tab bar, which leaves nothing out (the tray's own filters, sort and folded
/// groups are its saved state and stay out of the picker). Only tabs that
/// [tabPickerOffers] are kept.
@Riverpod()
EquatableValue<List<TabPickerRow>> tabPickerRows(
  Ref ref, {
  required String? containerId,
  required bool privateTabs,
  required TabTypeFilter typeFilter,
}) {
  // Only the modes: titles and URLs change all the time and decide nothing
  // here.
  final modes = ref
      .watch(
        tabSortKeysProvider.select(
          (keys) => EquatableValue({
            for (final MapEntry(:key, :value) in keys.value.entries)
              key: value.tabMode,
          }),
        ),
      )
      .value;
  bool offered(String tabId) => tabPickerOffers(
    modes[tabId],
    privateTabs: privateTabs,
    typeFilter: typeFilter,
  );

  if (ref.watch(tabTraySearchActiveProvider)) {
    final results = ref.watch(
      tabSearchRepositoryProvider(
        TabSearchPartition.preview,
      ).select((value) => EquatableValue(value.value?.results ?? const [])),
    );
    return EquatableValue([
      for (final result in results.value)
        if (result.containerId == containerId && offered(result.id))
          (tabId: result.id, depth: 0),
    ]);
  }

  final items = ref.watch(
    visibleTabListItemsProvider(
      containerId: containerId,
      scope: TabListScope.presentation,
    ),
  );
  return EquatableValue([
    for (final item in items.value)
      if (offered(item.tabId))
        (
          tabId: item.tabId,
          depth: switch (item) {
            TabListChildItem(:final depth) => depth,
            _ => 0,
          },
        ),
  ]);
}
