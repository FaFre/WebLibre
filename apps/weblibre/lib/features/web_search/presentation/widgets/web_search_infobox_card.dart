import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:search_protocol/search_protocol.dart';
import 'package:weblibre/core/providers/persisted_bool.dart';
import 'package:weblibre/features/web_search/domain/controllers/search_controller.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class WebSearchInfoboxCard extends HookConsumerWidget {
  final CompactInfobox info;
  final Future<void> Function(Uri url) onOpen;

  /// "Show all links" and "factsheet expanded" states, mirrored from the
  /// carousel so the off-stage height measurer and the visible card stay in
  /// sync. When null the card manages them locally (single-card path), both
  /// defaulting to collapsed.
  final bool? showAllLinksOverride;
  final VoidCallback? onToggleShowAllLinks;
  final bool? factsheetExpandedOverride;
  final VoidCallback? onToggleFactsheetExpanded;

  const WebSearchInfoboxCard({
    super.key,
    required this.info,
    required this.onOpen,
    this.showAllLinksOverride,
    this.onToggleShowAllLinks,
    this.factsheetExpandedOverride,
    this.onToggleFactsheetExpanded,
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

    final heading = _heading(info);
    final attributes = _meaningfulAttributes(info);
    final urls = _meaningfulUrls(info);

    // Persisted + shared via the provider, so the carousel's off-stage height
    // measurer and the visible card always agree (no per-instance state to
    // desync), and the choice survives app restarts.
    final isExpanded = ref.watch(
      persistedBoolProvider(PersistedBoolKey.infoboxExpanded),
    );

    void toggle() {
      ref
          .read(persistedBoolProvider(PersistedBoolKey.infoboxExpanded).notifier)
          .toggle();
    }

    final localShowAllLinks = useState(false);
    final showAllLinks = showAllLinksOverride ?? localShowAllLinks.value;

    void toggleShowAllLinks() {
      final external = onToggleShowAllLinks;
      if (external != null) {
        external();
      } else {
        localShowAllLinks.value = !localShowAllLinks.value;
      }
    }

    final localFactsheetExpanded = useState(false);
    final factsheetExpanded =
        factsheetExpandedOverride ?? localFactsheetExpanded.value;

    void toggleFactsheetExpanded() {
      final external = onToggleFactsheetExpanded;
      if (external != null) {
        external();
      } else {
        localFactsheetExpanded.value = !localFactsheetExpanded.value;
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
              showAllLinks: showAllLinks,
              onToggleShowAllLinks: toggleShowAllLinks,
              factsheetExpanded: factsheetExpanded,
              onToggleFactsheetExpanded: toggleFactsheetExpanded,
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

  static final RegExp _trailingColon = RegExp(r':+\s*$');

  /// Attributes worth rendering in the factsheet: those with a non-empty value,
  /// minus low-signal entries. We always drop a "type"/"kind" attribute: it is
  /// Brave's weakest classifier (emitted only as a fallback when no `category`
  /// is available) and as a single taxonomy word (e.g. `Type: Code`) it tells
  /// the user nothing the heading/image/links don't already convey.
  static List<InfoboxAttribute> _meaningfulAttributes(CompactInfobox info) {
    return (info.attributes ?? const <InfoboxAttribute>[])
        .where((attr) => attr.value?.trim().isNotEmpty ?? false)
        .where((attr) {
          final label = attr.label.replaceAll(_trailingColon, '').toLowerCase();
          return label != 'type' && label != 'kind';
        })
        .toList();
  }

  /// Link chips to show. These are the card's primary actionable content — the
  /// header breadcrumb only toggles expand/collapse, so a chip is the only way
  /// to actually open the destination (for some cards, e.g. a Brave "Code"
  /// answer, it is the *entire* useful payload). We therefore keep every link
  /// with a real title and only drop empty-title entries.
  static List<InfoboxUrl> _meaningfulUrls(CompactInfobox info) {
    return (info.urls ?? const <InfoboxUrl>[])
        .where((urlObj) => urlObj.title.trim().isNotEmpty)
        .toList();
  }
}

class _Body extends StatelessWidget {
  final CompactInfobox info;
  final Uint8List? imageBytes;
  final List<InfoboxAttribute> attributes;
  final List<InfoboxUrl> urls;
  final Future<void> Function(Uri url) onOpen;
  final bool showAllLinks;
  final VoidCallback onToggleShowAllLinks;
  final bool factsheetExpanded;
  final VoidCallback onToggleFactsheetExpanded;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _Body({
    required this.info,
    required this.imageBytes,
    required this.attributes,
    required this.urls,
    required this.onOpen,
    required this.showAllLinks,
    required this.onToggleShowAllLinks,
    required this.factsheetExpanded,
    required this.onToggleFactsheetExpanded,
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
                  when content.trim().isNotEmpty)
                Text(
                  content.trim(),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
            ],
          ),
        ),
        if (attributes.isNotEmpty)
          _Factsheet(
            attributes: attributes,
            expanded: factsheetExpanded,
            onToggle: onToggleFactsheetExpanded,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        if (urls.isNotEmpty) ...[
          const SizedBox(height: 8),
          _InfoboxLinks(
            links: urls,
            showAll: showAllLinks,
            onToggleShowAll: onToggleShowAllLinks,
            onOpen: onOpen,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 8),
        ] else
          const SizedBox(height: 16),
      ],
    );
  }
}

/// The infobox's links, capped at [_collapsedCount] rows by default with a
/// "Show N more" toggle for the rest. Keeps link-heavy cards (Wikipedia-style)
/// short so the user doesn't have to scroll far to reach the search results,
/// while leaving link-only answers (typically a single link) fully visible.
///
/// The expand state is owned by [WebSearchInfoboxCard] (and, in a carousel,
/// shared with the off-stage height measurer) so expanding actually grows the
/// measured viewport instead of clipping the revealed rows.
class _InfoboxLinks extends StatelessWidget {
  static const _collapsedCount = 3;

  final List<InfoboxUrl> links;
  final bool showAll;
  final VoidCallback onToggleShowAll;
  final Future<void> Function(Uri url) onOpen;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _InfoboxLinks({
    required this.links,
    required this.showAll,
    required this.onToggleShowAll,
    required this.onOpen,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final hasOverflow = links.length > _collapsedCount;
    final visible = (hasOverflow && !showAll)
        ? links.sublist(0, _collapsedCount)
        : links;
    final hiddenCount = links.length - _collapsedCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final link in visible)
          _InfoboxLinkRow(
            link: link,
            onOpen: onOpen,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        if (hasOverflow)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onToggleShowAll,
              icon: Icon(
                showAll ? Icons.expand_less : Icons.expand_more,
                size: 18,
              ),
              label: Text(
                showAll ? 'Show less' : 'Show $hiddenCount more links',
              ),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
            ),
          ),
      ],
    );
  }
}

/// A single infobox link rendered as a full-width row: real favicon, link
/// title, and the destination URL breadcrumb underneath. Unlike a bare chip,
/// this makes it obvious *where* the link goes (the title alone often just
/// repeats the card heading, e.g. the F-Droid "Code" answer).
class _InfoboxLinkRow extends StatelessWidget {
  final InfoboxUrl link;
  final Future<void> Function(Uri url) onOpen;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _InfoboxLinkRow({
    required this.link,
    required this.onOpen,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onOpen(link.url),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            UrlIcon([link.url], iconSize: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    link.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Full destination URL (host › path …) with the breadcrumb's
                  // own horizontal fade when it overflows.
                  UriBreadcrumb(
                    uri: link.url,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// Collapsible factsheet. Unlike a plain [ExpansionTile] it is *fully*
/// controlled by [expanded]/[onToggle] (owned by [WebSearchInfoboxCard] and, in
/// a carousel, shared with the off-stage height measurer) so expanding grows
/// the measured viewport instead of clipping the revealed rows — an
/// [ExpansionTile]'s private internal state would desync the two copies. The
/// state is ephemeral (not persisted).
class _Factsheet extends StatelessWidget {
  final List<InfoboxAttribute> attributes;
  final bool expanded;
  final VoidCallback onToggle;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _Factsheet({
    required this.attributes,
    required this.expanded,
    required this.onToggle,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Factsheet',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
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
        if (expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final attr in attributes)
                  if (attr.value case final String value
                      when value.trim().isNotEmpty)
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
          ),
      ],
    );
  }
}

class WebSearchInfoboxCarousel extends HookConsumerWidget {
  final List<CompactInfobox> infos;
  final Future<void> Function(Uri url) onOpen;

  /// Placeholder viewport height used for a page whose real height has not
  /// been measured yet. Kept small so the very first frame errs on the side
  /// of a slightly-too-short card (corrected within a frame) rather than
  /// flashing a large empty box.
  static const _estimatedCardHeight = 200.0;

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
    final showAllLinks = useState(false);
    final factsheetExpanded = useState(false);

    // Natural (content) height of each page, measured off-stage. `null` until
    // a page has been laid out at least once.
    final heights = useState<List<double?>>(
      List<double?>.filled(infos.length, null),
    );

    // Reset the measurement cache when the page set changes.
    useEffect(() {
      heights.value = List<double?>.filled(infos.length, null);
      return null;
    }, [infos.length]);

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

    // Records a freshly-measured page height. The equality guard is what
    // breaks the measure -> resize -> re-measure feedback loop that plagued
    // earlier dynamic-height attempts: measurement happens in a *separate*
    // off-stage subtree (see below) whose constraints never depend on the
    // visible viewport height, so once a height settles this no-ops.
    void reportHeight(int index, double height) {
      final current = heights.value[index];
      if (current != null && (current - height).abs() < 0.5) {
        return;
      }
      final next = [...heights.value];
      next[index] = height;
      heights.value = next;
    }

    WebSearchInfoboxCard cardFor(int index) => WebSearchInfoboxCard(
      info: infos[index],
      onOpen: onOpen,
      showAllLinksOverride: showAllLinks.value,
      onToggleShowAllLinks: () => showAllLinks.value = !showAllLinks.value,
      factsheetExpandedOverride: factsheetExpanded.value,
      onToggleFactsheetExpanded: () =>
          factsheetExpanded.value = !factsheetExpanded.value,
    );

    final active = currentPage.value.clamp(0, infos.length - 1);
    // The viewport is the active page's *full* natural height — deliberately
    // not capped. A capped viewport made the inner scroll view scrollable,
    // and a scrollable child traps vertical drags instead of letting them
    // bubble up to the parent sheet (so the user could not scroll on to the
    // results). At full height the inner content fits exactly, the scroll
    // view has nothing to consume, and drags pass through to the sheet.
    final viewportHeight = heights.value[active] ?? _estimatedCardHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                // Off-stage measurers. Each card is laid out a second time at
                // the real page width but with unbounded height, so it reports
                // its natural content height. `Offstage` keeps them out of the
                // layout/paint flow of the visible carousel (they report zero
                // size and are never painted).
                Offstage(
                  child: SizedBox(
                    width: pageWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < infos.length; i++)
                          _MeasureSize(
                            onChange: (size) => reportHeight(i, size.height),
                            child: cardFor(i),
                          ),
                      ],
                    ),
                  ),
                ),
                // Visible carousel. The viewport tracks the active page's
                // measured height; AnimatedSize smooths the change on swipe
                // (height settles after the page snaps) and on expand/collapse.
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: viewportHeight,
                    child: PageView.builder(
                      controller: controller,
                      itemCount: infos.length,
                      itemBuilder: (context, index) {
                        // Wrapped in a scroll view only so a page that is
                        // momentarily taller than the viewport (before its
                        // height is measured, or mid-swipe toward a taller
                        // page) clips gracefully instead of throwing an
                        // overflow. Once measured the content fits exactly, so
                        // this never actually scrolls and vertical drags bubble
                        // up to the parent sheet.
                        return SingleChildScrollView(child: cardFor(index));
                      },
                    ),
                  ),
                ),
              ],
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
      },
    );
  }
}

/// Reports its child's laid-out size via [onChange] whenever it changes.
///
/// Used to measure infobox cards off-stage (at the real page width, unbounded
/// height) so the carousel viewport can size to the active page. The callback
/// fires from a post-frame callback to stay clear of the layout phase, and the
/// caller guards on size equality so a settled layout produces no further work.
class _MeasureSize extends SingleChildRenderObjectWidget {
  final ValueChanged<Size> onChange;

  const _MeasureSize({required this.onChange, required Widget super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _MeasureSizeRenderObject(onChange);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _MeasureSizeRenderObject renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  ValueChanged<Size> onChange;
  Size? _oldSize;

  _MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();
    final newSize = child?.size ?? Size.zero;
    if (_oldSize == newSize) {
      return;
    }
    _oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(newSize));
  }
}
