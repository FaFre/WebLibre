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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/providers/bookmarks.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_section.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class BookmarkSearch extends HookConsumerWidget {
  final ValueListenable<TextEditingValue> searchTextListenable;
  final void Function(Uri uri) onUriSelected;

  const BookmarkSearch({
    super.key,
    required this.searchTextListenable,
    required this.onUriSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkResults = ref.watch(bookmarkSearchResultsProvider);
    final totalResults = bookmarkResults.length;

    useOnListenableChange(searchTextListenable, () async {
      await ref
          .read(bookmarkSearchResultsProvider.notifier)
          .search(searchTextListenable.value.text);
    });

    if (bookmarkResults.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SearchModuleSection(
      title: 'Bookmarks',
      moduleType: SearchModuleType.bookmarks,
      totalCount: totalResults,
      contentSliverBuilder:
          ({required bool isCollapsed, required int visibleCount}) => [
            if (!isCollapsed)
              SliverList.builder(
                itemCount: visibleCount,
                itemBuilder: (context, index) {
                  final bookmark = bookmarkResults[index];

                  return ListTile(
                    leading: RepaintBoundary(
                      child: UrlIcon([bookmark.url], iconSize: 24),
                    ),
                    title: Text(
                      bookmark.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: UriBreadcrumb(uri: bookmark.url),
                    onTap: () => onUriSelected(bookmark.url),
                  );
                },
              ),
          ],
    );
  }
}
