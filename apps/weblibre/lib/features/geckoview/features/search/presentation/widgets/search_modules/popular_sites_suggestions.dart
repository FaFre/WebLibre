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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_section.dart';
import 'package:weblibre/features/popular_sites/domain/providers/popular_sites_search.dart';
import 'package:weblibre/presentation/hooks/on_listenable_change_selector.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

/// Omnibar module offering popular-domain completions from the bundled
/// Tranco-derived `sites.db`. Ranked below history and bookmarks so a user's
/// own visited/saved sites always win; this fills the long tail with
/// well-known destinations (typing "git" -> github.com) even with no history.
class PopularSitesSuggestions extends HookConsumerWidget {
  final ValueListenable<TextEditingValue> searchTextListenable;
  final void Function(Uri uri) onUriSelected;

  const PopularSitesSuggestions({
    super.key,
    required this.searchTextListenable,
    required this.onUriSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(popularSitesSearchResultsProvider);

    useOnListenableChangeSelector(
      searchTextListenable,
      () => searchTextListenable.value.text,
      () async {
        await ref
            .read(popularSitesSearchResultsProvider.notifier)
            .search(searchTextListenable.value.text);
      },
    );

    if (results.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SearchModuleSection(
      title: 'Popular Sites',
      moduleType: SearchModuleType.popularSites,
      totalCount: results.length,
      contentSliverBuilder:
          ({required bool isCollapsed, required int visibleCount}) => [
            if (!isCollapsed)
              SliverList.builder(
                itemCount: visibleCount,
                itemBuilder: (context, index) {
                  final site = results[index];
                  final uri = Uri.parse('https://${site.domain}');

                  return ListTile(
                    key: ValueKey(site.domain),
                    leading: RepaintBoundary(
                      child: UrlIcon([uri], iconSize: 24),
                    ),
                    title: Text(
                      site.domain,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => onUriSelected(uri),
                  );
                },
              ),
          ],
    );
  }
}
