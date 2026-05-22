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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_section.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/history_search.dart';
import 'package:weblibre/presentation/hooks/on_listenable_change_selector.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/text_highlight.dart';

/// FTS5-backed search over the local history index. Sits next to the engine
/// "History" module (which is frecency-ranked from Places). Future iteration
/// will merge the two into a single ranked list once weights are tuned.
class LocalHistorySuggestions extends HookConsumerWidget {
  final ValueListenable<TextEditingValue> searchTextListenable;
  final void Function(Uri uri, {String? findInPageQuery}) onUriSelected;

  const LocalHistorySuggestions({
    super.key,
    required this.onUriSelected,
    required this.searchTextListenable,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(historySearchRepositoryProvider);
    final results = searchAsync.value?.results ?? const [];

    useOnListenableChangeSelector(
      searchTextListenable,
      () => searchTextListenable.value.text,
      () async {
        // matchPrefix/matchSuffix default to historyHighlightPrefix/Suffix
        // — the same constants used below for highlight scanning.
        await ref
            .read(historySearchRepositoryProvider.notifier)
            .addQuery(searchTextListenable.value.text);
      },
    );

    return SearchModuleSection(
      title: 'Local content',
      moduleType: SearchModuleType.localHistory,
      totalCount: results.length,
      contentSliverBuilder:
          ({required bool isCollapsed, required int visibleCount}) => [
            SliverSkeletonizer(
              enabled: searchAsync.isLoading,
              child: searchAsync.when(
                skipLoadingOnReload: true,
                data: (data) {
                  if (data == null || data.results.isEmpty) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }
                  return SliverList.builder(
                    itemCount: visibleCount,
                    itemBuilder: (context, index) {
                      final result = data.results[index];
                      final uri = Uri.tryParse(result.urlCanonical);

                      final content =
                          (result.extractedContent?.contains(
                                historyHighlightPrefix,
                              ) ==
                              true)
                          ? result.extractedContent
                          : result.fullContent;
                      final titleHasMatch =
                          result.title?.contains(historyHighlightPrefix) ??
                          false;
                      final bodyHasMatch =
                          content?.contains(historyHighlightPrefix) ?? false;

                      final theme = Theme.of(context);

                      return ListTile(
                        leading: RepaintBoundary(
                          child: uri != null
                              ? UrlIcon([uri], iconSize: 24)
                              : const Icon(MdiIcons.history, size: 24),
                        ),
                        title: result.title.mapNotNull(
                          (title) => Text.rich(
                            buildHighlightedText(
                              title,
                              theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                              theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                              historyHighlightPrefix,
                              historyHighlightSuffix,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        subtitle: bodyHasMatch
                            ? Text.rich(
                                buildHighlightedText(
                                  content!,
                                  theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  historyHighlightPrefix,
                                  historyHighlightSuffix,
                                  normalizeWhitespaces: true,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              )
                            : (uri != null && !titleHasMatch
                                  ? UriBreadcrumb(
                                      uri: uri,
                                      showHttpScheme: false,
                                    )
                                  : null),
                        onTap: () {
                          if (uri != null) {
                            onUriSelected(
                              uri,
                              findInPageQuery: bodyHasMatch
                                  ? searchTextListenable.value.text
                                  : null,
                            );
                          }
                        },
                      );
                    },
                  );
                },
                error: (error, stackTrace) => SliverToBoxAdapter(
                  child: FailureWidget(
                    title: 'Could not load local content',
                    exception: error,
                  ),
                ),
                loading: () => SliverList.builder(
                  itemCount: isCollapsed ? 0 : 5,
                  itemBuilder: (context, index) =>
                      const ListTile(title: Bone.text()),
                ),
              ),
            ),
          ],
    );
  }
}
