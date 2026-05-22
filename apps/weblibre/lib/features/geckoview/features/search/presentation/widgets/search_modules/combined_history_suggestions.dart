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
import 'package:weblibre/features/geckoview/features/search/domain/providers/combined_history.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/engine_suggestions.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/history_row_icon.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_section.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/history_search.dart';
import 'package:weblibre/presentation/hooks/on_listenable_change_selector.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/text_highlight.dart';

/// Combined history view: engine frecency-ranked suggestions augmented with
/// local content snippets, plus local-only content matches appended at the
/// end. Replaces the separate "History" + "Local content" sections in the
/// default search module ordering.
class CombinedHistorySuggestions extends HookConsumerWidget {
  final ValueListenable<TextEditingValue> searchTextListenable;

  /// Tap handler for a row's leading URL.
  ///
  /// [findInPageQuery] is non-null only for rows whose snippet was an FTS
  /// content match — the search screen forwards it to the engine so the
  /// landed page opens with a find-in-page query pre-filled. UI-level
  /// concern bleeding into the callback signature is deliberate so the
  /// host doesn't have to re-derive "did this row come from an FTS match"
  /// when opening the URL.
  final void Function(Uri uri, {String? findInPageQuery}) onUriSelected;

  const CombinedHistorySuggestions({
    super.key,
    required this.onUriSelected,
    required this.searchTextListenable,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Both upstreams need their own kick. Engine sends the suggestion
    // request; local FTS runs the query against the history index.
    useOnListenableChangeSelector(
      searchTextListenable,
      () => searchTextListenable.value.text,
      () async {
        final text = searchTextListenable.value.text;
        if (ref.exists(engineSuggestionsProvider)) {
          await ref.read(engineSuggestionsProvider.notifier).addQuery(text);
        }

        if (!context.mounted) return;

        // matchPrefix/matchSuffix default to historyHighlightPrefix/Suffix,
        // which is the same constant the row builder scans for below.
        // Don't override the defaults here unless those scan constants
        // are kept in sync.
        await ref.read(historySearchRepositoryProvider.notifier).addQuery(text);
      },
    );

    final items = ref.watch(combinedHistorySuggestionsProvider);

    // Pre-build the four text styles used per row. Both `bodyLarge` and
    // `bodyMedium` come with a "base" variant and a bold one for the
    // highlighted-substring spans. Doing this once per build() keeps the
    // per-row itemBuilder from re-running four copyWith()s per visible
    // item — small but completely avoidable allocation on every scroll.
    final theme = Theme.of(context);
    final titleBase = theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onSurface,
    );
    final titleHighlight = titleBase?.copyWith(fontWeight: FontWeight.bold);
    final snippetBase = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final snippetHighlight = snippetBase?.copyWith(fontWeight: FontWeight.bold);

    return SearchModuleSection(
      title: 'History',
      moduleType: SearchModuleType.combinedHistory,
      totalCount: items.length,
      contentSliverBuilder:
          ({required bool isCollapsed, required int visibleCount}) => [
            SliverList.builder(
              itemCount: visibleCount,
              itemBuilder: (context, index) {
                final item = items[index];
                final titleHasMatch =
                    item.highlightedTitle?.contains(historyHighlightPrefix) ??
                    false;
                final snippetHasMatch =
                    item.snippet?.contains(historyHighlightPrefix) ?? false;

                return ListTile(
                  key: ValueKey(item.uri.toString()),
                  leading: HistoryRowIcon(
                    iconBytes: item.engineIcon,
                    fallback: UrlIcon([item.uri], iconSize: 24),
                  ),
                  title: titleHasMatch
                      ? Text.rich(
                          buildHighlightedText(
                            item.highlightedTitle!,
                            titleBase,
                            titleHighlight,
                            historyHighlightPrefix,
                            historyHighlightSuffix,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : item.title.mapNotNull(
                          (title) => Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                  subtitle: snippetHasMatch
                      ? Text.rich(
                          buildHighlightedText(
                            item.snippet!,
                            snippetBase,
                            snippetHighlight,
                            historyHighlightPrefix,
                            historyHighlightSuffix,
                            normalizeWhitespaces: true,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        )
                      : UriBreadcrumb(uri: item.uri, showHttpScheme: false),
                  trailing: item.source == CombinedHistorySource.local
                      ? Tooltip(
                          message: 'Content match',
                          child: Icon(
                            MdiIcons.textBoxSearchOutline,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : null,
                  onTap: () => onUriSelected(
                    item.uri,
                    findInPageQuery: snippetHasMatch
                        ? searchTextListenable.value.text
                        : null,
                  ),
                );
              },
            ),
          ],
    );
  }
}
