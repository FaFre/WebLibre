import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:search_protocol/search_protocol.dart';
import 'package:weblibre/features/search_credits/domain/repositories/web_search_settings.dart';
import 'package:weblibre/features/web_search/domain/controllers/search_controller.dart';
import 'package:weblibre/features/web_search/domain/entities/fetch_method.dart';
import 'package:weblibre/features/web_search/presentation/widgets/search_result_metadata_chips.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class WebSearchResultCard extends HookConsumerWidget {
  final CompactSearchResult result;

  final Future<void> Function(Uri url) onOpen;

  /// Opens the fetch sheet, which is now the single place that drives every
  /// per-method action (preview, open capture, retry) and surfaces their
  /// status and errors. The card only needs to launch it.
  final Future<void> Function(Uri url) onFetch;

  const WebSearchResultCard({
    super.key,
    required this.result,
    required this.onOpen,
    required this.onFetch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final imageUrl = (result.imgSrc?.isNotEmpty ?? false)
        ? result.imgSrc
        : (result.thumbnail?.isNotEmpty ?? false)
        ? result.thumbnail
        : null;

    final imageBytes = imageUrl.mapNotNull(
      (imageUrl) => ref.watch(
        metaSearchControllerProvider.select((s) => s.imagesByUrl[imageUrl]),
      ),
    );

    final document = ref.watch(
      metaSearchControllerProvider.select((s) => s.documentsByUrl[result.url]),
    );

    final queryLanguage = ref.watch(
      webSearchSettingsControllerProvider.select((s) => s.language),
    );

    final snippetEntries = resolveSnippetEntries(result.metadata ?? const []);
    final snippetsExpanded = useState(false);

    return Card(
      color: colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => onOpen(result.url),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    result: result,
                    imageBytes: imageBytes,
                    onFetch: onFetch,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  if (result.content case final String content
                      when content.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _ExpandableDescription(
                      text: content.trim(),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                  SearchResultMetadataSection(
                    metadata: result.metadata ?? const [],
                    pageMetadata: document?.metadata,
                    queryLanguage: queryLanguage,
                    publishedDate: result.publishedDate,
                    padding: const EdgeInsets.only(top: 10),
                    trailing: snippetEntries.isEmpty
                        ? null
                        : SearchResultSnippetsToggle(
                            expanded: snippetsExpanded.value,
                            onToggle: () => snippetsExpanded.value =
                                !snippetsExpanded.value,
                          ),
                  ),
                ],
              ),
            ),
            // Full-bleed expanding snippets panel, outside the content padding
            // so it spans the card edge to edge; the card's antiAlias clip
            // rounds its bottom corners.
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.fastOutSlowIn,
              alignment: Alignment.topCenter,
              child: (snippetEntries.isNotEmpty && snippetsExpanded.value)
                  ? SearchResultSnippetsPanel(entries: snippetEntries)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact header: small content thumbnail (when present), the site breadcrumb
/// and the result title, plus a trailing tonal "Fetch" icon button. The button
/// carries a count badge of the artifacts already fetched for this result; the
/// fetch sheet it opens is where their status and any errors are surfaced.
class _Header extends ConsumerWidget {
  final CompactSearchResult result;
  final Uint8List? imageBytes;
  final Future<void> Function(Uri url) onFetch;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _Header({
    required this.result,
    required this.imageBytes,
    required this.onFetch,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A single record select rebuilds this header only when the session state
    // or the number of ready artifacts for *this* result changes.
    final fetch = ref.watch(
      metaSearchControllerProvider.select((s) {
        var ready = 0;
        for (final choice in FetchMethodChoice.values) {
          if (s.isMethodReady(result.url, choice)) ready++;
        }
        final busy = s.isFetching(result.url) || s.isAnyCapturing(result.url);
        return (open: s.hasOpenSession, ready: ready, busy: busy);
      }),
    );

    // Once the WebSocket session has closed no further fetch/capture commands
    // can be issued — keep the button only while the session is open or there
    // are already-fetched artifacts to (re)open via the sheet.
    final showFetch = fetch.open || fetch.ready > 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageBytes != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              imageBytes!,
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UriBreadcrumb(
                uri: result.url,
                icon: UrlIcon([result.url], iconSize: 14, cacheOnly: true),
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                result.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        if (showFetch) ...[
          const SizedBox(width: 8),
          Badge.count(
            count: fetch.ready,
            isLabelVisible: fetch.ready > 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Live progress ring while any method for this result is
                // fetching/capturing — the badge keeps counting ready artifacts.
                if (fetch.busy)
                  const SizedBox.square(
                    dimension: 40,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                IconButton.filledTonal(
                  onPressed: () => onFetch(result.url),
                  icon: const Icon(Icons.download_rounded, size: 16),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Fetch',
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ExpandableDescription extends HookWidget {
  static const _collapsedMaxLines = 2;

  final String text;
  final TextStyle? style;

  const _ExpandableDescription({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () {
        expanded.value = !expanded.value;
      },
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Text(
          text,
          maxLines: expanded.value ? null : _collapsedMaxLines,
          overflow: expanded.value ? TextOverflow.clip : TextOverflow.ellipsis,
          style: style,
        ),
      ),
    );
  }
}
