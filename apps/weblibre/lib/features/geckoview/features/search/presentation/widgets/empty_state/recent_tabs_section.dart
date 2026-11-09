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
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_url_list_tile.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/empty_state_content.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_section.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

class RecentTabsSection extends ConsumerWidget {
  final void Function(String tabId) onTabSelected;

  /// Tabs left out of the list (the split view picker's source and the tabs
  /// that could not be shown beside it).
  final Set<String> excludedTabIds;

  const RecentTabsSection({
    super.key,
    required this.onTabSelected,
    this.excludedTabIds = const {},
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final allTabs = ref.watch(searchEmptyRecentTabsProvider());
    final tabs = excludedTabIds.isEmpty
        ? allTabs
        : [
            for (final entry in allTabs)
              if (!excludedTabIds.contains(entry.$1.id)) entry,
          ];

    if (tabs.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SearchModuleSection(
      title: l10n.search_moduleLabelRecentTabs,
      moduleType: SearchModuleType.recentTabs,
      totalCount: tabs.length,
      contentSliverBuilder:
          ({required bool isCollapsed, required int visibleCount}) => [
            if (!isCollapsed)
              SliverList.builder(
                itemCount: visibleCount,
                itemBuilder: (context, index) {
                  final (tabState, containerData) = tabs[index];
                  return TabUrlListTile(
                    tabState: tabState,
                    containerData: containerData,
                    onTap: () => onTabSelected(tabState.id),
                  );
                },
              ),
          ],
    );
  }
}
