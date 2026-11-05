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
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_list_scope.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/accordion_expansion.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_entity.dart';

part 'accordion_group_tabs.g.dart';

/// The tabs of an open accordion group, with each child tab's depth in its
/// tree.
typedef AccordionGroupTabs = ({
  List<TabStateWithContainer> tabStates,
  Map<String, int> tabDepthById,
});

/// The tabs of every accordion group shown open, by container id: several
/// groups while [multiple], one otherwise ([AccordionExpansion.displayed]).
/// Depths are only worked out [withDepths]. Collapsed groups subscribe to
/// nothing.
@Riverpod()
Map<String?, AccordionGroupTabs> accordionGroupTabs(
  Ref ref, {
  required bool multiple,
  required bool withDepths,
}) {
  // Only the groups shown open: reordering the expansion history without
  // changing them must not rebuild the map, which compares by identity.
  final expandedIds = ref
      .watch(
        accordionExpansionControllerProvider.select(
          (expansion) =>
              EquatableValue(expansion.displayed(multiple: multiple)),
        ),
      )
      .value;

  return {
    for (final containerId in expandedIds)
      containerId: (
        tabStates: ref
            .watch(containerTabStatesWithContainerProvider(containerId))
            .value,
        // Without depths the grouping is not subscribed to at all.
        tabDepthById: withDepths
            ? ref
                  .watch(
                    groupedTabListItemsProvider(
                      containerId: containerId,
                      scope: TabListScope.presentation,
                    ).select((value) {
                      return EquatableValue(<String, int>{
                        for (final item in value.value)
                          if (item is TabListChildItem) item.tabId: item.depth,
                      });
                    }),
                  )
                  .value
            : const <String, int>{},
      ),
  };
}
