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
import 'package:weblibre/features/geckoview/features/search/domain/providers/empty_state_content.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_section.dart';
import 'package:weblibre/presentation/widgets/url_list_tile.dart';

class RecentHistorySection extends ConsumerWidget {
  final void Function(Uri uri) onUriSelected;

  const RecentHistorySection({super.key, required this.onUriSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(searchEmptyRecentHistoryProvider());
    final visits = historyAsync.value ?? [];

    if (historyAsync.hasValue && visits.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SearchModuleSection(
      title: 'Recent History',
      moduleType: SearchModuleType.recentHistory,
      totalCount: visits.length,
      contentSliverBuilder:
          ({required bool isCollapsed, required int visibleCount}) => [
            if (!isCollapsed)
              SliverList.builder(
                itemCount: visibleCount,
                itemBuilder: (context, index) {
                  final visit = visits[index];
                  final uri = Uri.parse(visit.url);

                  return UrlListTile(
                    title: visit.title ?? uri.authority,
                    uri: uri,
                    onTap: () => onUriSelected(uri),
                  );
                },
              ),
          ],
    );
  }
}
