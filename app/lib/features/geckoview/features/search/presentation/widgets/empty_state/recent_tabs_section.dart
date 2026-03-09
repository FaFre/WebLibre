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
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_icon.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/empty_state_content.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_section.dart';
import 'package:weblibre/presentation/widgets/url_list_tile.dart';

class RecentTabsSection extends ConsumerWidget {
  final void Function(String tabId) onTabSelected;

  const RecentTabsSection({super.key, required this.onTabSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(searchEmptyRecentTabsProvider());

    if (tabs.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SearchModuleSection(
      title: 'Recent Tabs',
      moduleType: SearchModuleType.recentTabs,
      totalCount: tabs.length,
      contentSliverBuilder:
          ({required bool isCollapsed, required int visibleCount}) => [
            if (!isCollapsed)
              SliverList.builder(
                itemCount: visibleCount,
                itemBuilder: (context, index) {
                  final (tabState, containerData) = tabs[index];

                  return UrlListTile(
                    title: tabState.titleOrAuthority,
                    uri: tabState.url,
                    leading: TabIcon(
                      tabState: tabState,
                      iconSize: UrlListTile.iconSize,
                    ),
                    borderColor: containerData?.color,
                    onTap: () => onTabSelected(tabState.id),
                  );
                },
              ),
          ],
    );
  }
}
