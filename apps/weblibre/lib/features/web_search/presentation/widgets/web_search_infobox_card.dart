import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:search_protocol/search_protocol.dart';
import 'package:weblibre/features/web_search/domain/controllers/search_controller.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class WebSearchInfoboxCard extends HookConsumerWidget {
  final CompactInfobox info;
  final Future<void> Function(Uri url) onOpen;

  /// When non-null the card uses this externally-controlled expansion state
  /// (e.g. shared across a carousel). When null, the card manages its own
  /// state with a default of expanded.
  final bool? expandedOverride;
  final VoidCallback? onToggleExpanded;

  const WebSearchInfoboxCard({
    super.key,
    required this.info,
    required this.onOpen,
    this.expandedOverride,
    this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final imageUrl = info.imgSrc;
    final imageBytes = (imageUrl == null || imageUrl.isEmpty)
        ? null
        : ref.watch(
            metaSearchControllerProvider.select((s) => s.imagesByUrl[imageUrl]),
          );

    final attributes = info.attributes ?? const <InfoboxAttribute>[];
    final urls = info.urls ?? const <InfoboxUrl>[];
    final heading = _heading(info);

    final localExpanded = useState(true);
    final isExpanded = expandedOverride ?? localExpanded.value;

    void toggle() {
      final external = onToggleExpanded;
      if (external != null) {
        external();
      } else {
        localExpanded.value = !localExpanded.value;
      }
    }

    return Card(
      color: colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: toggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (heading.isNotEmpty)
                          Text(
                            heading,
                            style: textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (info.url case final Uri sourceUrl) ...[
                          const SizedBox(height: 6),
                          UriBreadcrumb(
                            uri: sourceUrl,
                            icon: UrlIcon(
                              [sourceUrl],
                              iconSize: 16,
                              cacheOnly: true,
                            ),
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            _Body(
              info: info,
              imageBytes: imageBytes,
              attributes: attributes,
              urls: urls,
              onOpen: onOpen,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
        ],
      ),
    );
  }

  String _heading(CompactInfobox info) {
    final title = info.title?.trim();
    if (title != null && title.isNotEmpty) return title;
    return info.infobox.trim();
  }
}

class _Body extends StatelessWidget {
  final CompactInfobox info;
  final Uint8List? imageBytes;
  final List<InfoboxAttribute> attributes;
  final List<InfoboxUrl> urls;
  final Future<void> Function(Uri url) onOpen;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _Body({
    required this.info,
    required this.imageBytes,
    required this.attributes,
    required this.urls,
    required this.onOpen,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageBytes != null) ...[
                Align(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        imageBytes!,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (info.content case final String content
                  when content.trim().isNotEmpty) ...[
                Text(
                  content.trim(),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (info.source.isNotEmpty)
                Text(
                  'Source: ${info.source}',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        if (attributes.isNotEmpty)
          _Factsheet(
            attributes: attributes,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        if (urls.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final urlObj in urls) ...[
                    OutlinedButton.icon(
                      onPressed: () => onOpen(urlObj.url),
                      icon: Icon(_iconForLink(urlObj.title), size: 16),
                      label: Text(urlObj.title),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurfaceVariant,
                        side: BorderSide(color: colorScheme.outlineVariant),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          )
        else
          const SizedBox(height: 16),
      ],
    );
  }

  IconData _iconForLink(String title) {
    final lower = title.toLowerCase();

    if (lower.contains('wikipedia') || lower.contains('wiki')) {
      return Icons.article_outlined;
    }
    if (lower.contains('reddit')) return Icons.forum_outlined;
    if (lower.contains('facebook')) return Icons.facebook_outlined;
    if (lower.contains('youtube') || lower.contains('video')) {
      return Icons.play_circle_outline;
    }
    if (lower.contains('twitter') || lower.contains('x.com')) {
      return Icons.alternate_email;
    }
    if (lower.contains('instagram')) return Icons.photo_camera_outlined;
    if (lower.contains('github')) return Icons.code;
    if (lower.contains('mastodon')) return Icons.public;

    return Icons.link;
  }
}

class _Factsheet extends StatelessWidget {
  final List<InfoboxAttribute> attributes;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _Factsheet({
    required this.attributes,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          'Factsheet',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final attr in attributes)
            if (attr.value case final String value when value.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RichText(
                  text: TextSpan(
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text:
                            '${attr.label.replaceAll(RegExp(r':+\s*$'), '')}: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      TextSpan(text: value),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class WebSearchInfoboxCarousel extends HookConsumerWidget {
  final List<CompactInfobox> infos;
  final Future<void> Function(Uri url) onOpen;

  /// Upper bound for the carousel viewport. The PageView gets exactly this
  /// height; if a card is taller, the inner [SingleChildScrollView] handles
  /// the overflow. Picked large enough to fit a typical Wikipedia-style
  /// infobox without scrolling, small enough not to dominate the screen.
  static const _maxCardHeight = 520.0;

  const WebSearchInfoboxCarousel({
    super.key,
    required this.infos,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final controller = usePageController();
    final currentPage = useState(0);
    final expanded = useState(true);

    useEffect(() {
      void listener() {
        final page = controller.page?.round() ?? 0;
        if (page != currentPage.value) {
          currentPage.value = page;
        }
      }

      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

    // Earlier revisions measured each page's real height in a post-frame
    // callback and animated the carousel to match. With SizeChangedLayout
    // notifications + post-frame setState, this created a measurement
    // feedback loop that was vulnerable to floating-point jitter and
    // sometimes spent the whole expand/collapse animation re-measuring.
    // Using a fixed maximum + per-page scrolling sidesteps the loop and is
    // measurably cheaper.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _maxCardHeight,
          child: PageView.builder(
            controller: controller,
            itemCount: infos.length,
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                child: WebSearchInfoboxCard(
                  info: infos[index],
                  onOpen: onOpen,
                  expandedOverride: expanded.value,
                  onToggleExpanded: () => expanded.value = !expanded.value,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < infos.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: currentPage.value == i ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: currentPage.value == i
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
