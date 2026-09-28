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
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/web_search/domain/controllers/search_controller.dart';
import 'package:weblibre/features/web_search/presentation/open_in_new_tab.dart';
import 'package:weblibre/features/web_search/presentation/widgets/search_result_metadata_chips.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class PagePreviewScreen extends ConsumerWidget {
  final Uri uri;
  final WebSearchOpenTarget Function() resolveOpenTarget;

  const PagePreviewScreen({
    super.key,
    required this.uri,
    required this.resolveOpenTarget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // The preview screen only depends on the document for this one URL and
    // the matching result row. Selecting both via a record means unrelated
    // controller updates (favicons, image streams, other URLs' fetches)
    // don't rebuild the (potentially-large) Markdown body below.
    final (document, result) = ref.watch(
      metaSearchControllerProvider.select(
        (s) => (
          s.documentsByUrl[uri],
          s.results.where((item) => item.url == uri).firstOrNull,
        ),
      ),
    );
    final title = result?.title ?? document?.metadata.title ?? uri.authority;

    if (document == null) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: FailureWidget(
          title: l10n.webSearch_previewUnavailableTitle,
          exception: l10n.webSearch_previewUnavailableMessage,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: l10n.webSearch_openInBrowserTooltip,
            onPressed: () async {
              await ref
                  .read(webSearchTabOpenerProvider)
                  .open(context, ref, uri, target: resolveOpenTarget());
            },
            icon: const Icon(Icons.open_in_new),
          ),
        ],
      ),
      body: FadingScroll(
        fadingSize: 25,
        builder: (context, controller) {
          return SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UriBreadcrumb(
                  uri: uri,
                  icon: UrlIcon([uri], iconSize: 16, cacheOnly: true),
                ),
                SearchResultMetadataSection(
                  metadata: result?.metadata ?? const [],
                  pageMetadata: document.metadata,
                  padding: const EdgeInsets.only(top: 16),
                ),
                if (resolveSnippetEntries(result?.metadata ?? const [])
                    case final entries when entries.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SearchResultSnippetsPanel(
                    entries: entries,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
                const SizedBox(height: 16),
                MarkdownBody(selectable: true, data: document.content),
              ],
            ),
          );
        },
      ),
    );
  }
}
