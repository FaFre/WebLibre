import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/locale.dart' as intl;
import 'package:search_protocol/search_protocol.dart';
import 'package:weblibre/domain/repositories/locale_resolver.dart';

const _expandableKeys = {'snippet', 'review', 'question'};

const _keyOrder = <String>[
  // Badges
  'type',
  'subtype',
  'access',
  // Time / freshness
  'released',
  'duration',
  'time',
  'hours',
  // Quality / popularity
  'rating',
  'answers',
  'stars',
  'forks',
  // Identity
  'author',
  'publisher',
  'organization',
  'sitename',
  'forum',
  // Commerce
  'price',
  'price_range',
  // Content descriptors
  'genre',
  'cuisine',
  'categories',
  'pages',
  'servings',
  'calories',
  'version',
  'distance',
  // Meta
  'language',
  'license',
  'pagetype',
];

const _hiddenKeys = {
  // The publisher-declared article date duplicates the result's own
  // `publishedDate`, surfaced as the `released` chip. Keep only that one.
  'date',
  'score',
  'gravity',
  'quality',
  'phrases',
  'size',
  'format',
  'results_from_domain',
  'more_from_domain',
  'content_type',
  'tags',
};

// Built once at import time so the sort comparator doesn't rebuild it on
// every widget rebuild.
final Map<String, int> _keyOrderIndex = {
  for (var i = 0; i < _keyOrder.length; i++) _keyOrder[i]: i,
};

IconData _iconFor(String key) {
  switch (key) {
    case 'type':
      return Icons.label_outline;
    case 'subtype':
      return Icons.category_outlined;
    case 'rating':
      return Icons.star_outline;
    case 'language':
      return Icons.language;
    case 'author':
      return Icons.person_outline;
    case 'publisher':
    case 'organization':
    case 'sitename':
      return MdiIcons.domain;
    case 'forum':
      return MdiIcons.forum;
    case 'answers':
      return Icons.question_answer_outlined;
    case 'price':
    case 'price_range':
      return MdiIcons.currencyUsd;
    case 'access':
      return Icons.lock_outline;
    case 'duration':
    case 'time':
    case 'hours':
      return Icons.schedule;
    case 'pages':
      return MdiIcons.bookOpenPageVariantOutline;
    // `date` is in `_hiddenKeys`, so only `released` reaches this branch in
    // practice — keep the case for safety should `date` ever be un-hidden.
    case 'released':
    case 'date':
      return Icons.calendar_month;
    case 'genre':
    case 'cuisine':
    case 'categories':
      return Icons.local_offer_outlined;
    case 'servings':
      return MdiIcons.silverwareForkKnife;
    case 'calories':
      return MdiIcons.fire;
    case 'stars':
      return Icons.star_border;
    case 'forks':
      return MdiIcons.sourceFork;
    case 'version':
      return MdiIcons.tagOutline;
    case 'distance':
      return Icons.place_outlined;
    case 'license':
      return MdiIcons.license;
    case 'pagetype':
      return Icons.article_outlined;
    default:
      return Icons.info_outline;
  }
}

String? _formatValue(String key, String value) {
  switch (key) {
    case 'released':
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return DateFormat.yMMMd().format(parsed);
      return value;
    default:
      return value;
  }
}

/// Compare the primary subtag of two BCP 47-ish language strings, ignoring
/// region and case. `null`/empty `queryTag` means "no preference set", so
/// the result language is always shown.
bool _languageMatchesQuery(String resultLanguage, String? queryTag) {
  if (queryTag == null || queryTag.isEmpty) return false;

  final result = resultLanguage
      .trim()
      .toLowerCase()
      .split(RegExp('[-_]'))
      .first;

  final query = queryTag.trim().toLowerCase().split(RegExp('[-_]')).first;

  if (result.isEmpty || query.isEmpty) return false;

  return result == query;
}

List<MetadataItem> _metadataFromPage(PageMetadata? pageMetadata) {
  if (pageMetadata == null) return const [];

  final items = <MetadataItem>[];

  if (pageMetadata.date case final String date when date.isNotEmpty) {
    items.add(MetadataItem(key: 'released', value: date));
  }
  if (pageMetadata.sitename case final String sitename
      when sitename.isNotEmpty) {
    items.add(MetadataItem(key: 'sitename', value: sitename));
  }
  if (pageMetadata.author case final String author when author.isNotEmpty) {
    items.add(MetadataItem(key: 'author', value: author));
  }
  if (pageMetadata.language case final String language
      when language.isNotEmpty) {
    items.add(MetadataItem(key: 'language', value: language));
  }
  if (pageMetadata.license case final String license when license.isNotEmpty) {
    items.add(MetadataItem(key: 'license', value: license));
  }
  if (pageMetadata.pagetype case final String pagetype
      when pagetype.isNotEmpty) {
    items.add(MetadataItem(key: 'pagetype', value: pagetype));
  }

  return items;
}

/// Resolves and de-duplicates the decorative chips for a result. The result's
/// own published date wins over any publisher-declared date from the fetched
/// page; page metadata then takes priority over result metadata on
/// per-key deduplication. Returns the list already sorted into [_keyOrder].
List<_ResolvedMetadataItem> _resolveChips({
  required List<MetadataItem> metadata,
  required PageMetadata? pageMetadata,
  required String? queryLanguage,
  required String? publishedDate,
}) {
  final seen = <String>{};
  final merged = <_ResolvedMetadataItem>[];

  if (publishedDate?.trim() case final String date when date.isNotEmpty) {
    seen.add('released');
    merged.add(
      _ResolvedMetadataItem(
        item: MetadataItem(key: 'released', value: date),
        isLanguage: false,
      ),
    );
  }

  void absorb(List<MetadataItem> items) {
    for (final item in items) {
      if (_expandableKeys.contains(item.key)) continue;
      if (_hiddenKeys.contains(item.key)) continue;
      if (item.value.trim().isEmpty) continue;
      if (item.key == 'language' &&
          _languageMatchesQuery(item.value, queryLanguage)) {
        continue;
      }
      if (!seen.add(item.key)) continue;
      merged.add(
        _ResolvedMetadataItem(item: item, isLanguage: item.key == 'language'),
      );
    }
  }

  // Page metadata first so it takes priority on deduplication.
  absorb(_metadataFromPage(pageMetadata));
  absorb(metadata);

  merged.sort((a, b) {
    final ai = _keyOrderIndex[a.item.key] ?? _keyOrder.length;
    final bi = _keyOrderIndex[b.item.key] ?? _keyOrder.length;
    return ai.compareTo(bi);
  });

  return merged;
}

/// The snippet/review/question entries worth revealing in the snippets panel.
/// Exposed so a parent (e.g. the result card) can decide whether to show the
/// snippets toggle and render the panel itself.
List<MetadataItem> resolveSnippetEntries(List<MetadataItem> metadata) {
  return metadata
      .where((item) => _expandableKeys.contains(item.key))
      .where((item) => item.value.trim().isNotEmpty)
      .toList();
}

/// Decorative metadata chips for a search result. An optional [trailing] action
/// (the snippets toggle) is pinned to the end of the same row, outside the
/// horizontal scroll. The expanding snippets panel itself is *not* rendered
/// here — the parent owns it so it can sit full-bleed at the card's edge rather
/// than nested inside the chip row's padding.
///
/// Collapses to nothing when there are neither chips nor a trailing action.
class SearchResultMetadataSection extends StatelessWidget {
  final List<MetadataItem> metadata;
  final PageMetadata? pageMetadata;

  /// ISO 639-1 language code of the query (e.g. `en`, `de`). When the
  /// result's `language` metadata matches by primary subtag, the language
  /// chip is suppressed as redundant.
  final String? queryLanguage;

  /// The result's published date, surfaced as a leading `released` chip
  /// (calendar icon, formatted).
  final String? publishedDate;

  /// Applied only when the section actually renders content, so callers can
  /// reserve spacing without having to predict whether the section is empty.
  final EdgeInsetsGeometry padding;

  /// Optional trailing action pinned to the end of the chip row (typically a
  /// [SearchResultSnippetsToggle]).
  final Widget? trailing;

  const SearchResultMetadataSection({
    super.key,
    required this.metadata,
    this.pageMetadata,
    this.queryLanguage,
    this.publishedDate,
    this.padding = EdgeInsets.zero,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final chips = _resolveChips(
      metadata: metadata,
      pageMetadata: pageMetadata,
      queryLanguage: queryLanguage,
      publishedDate: publishedDate,
    );

    final trailingAction = trailing;

    if (chips.isEmpty && trailingAction == null) {
      return const SizedBox.shrink();
    }

    final Widget header;
    if (trailingAction == null) {
      header = _MetadataChipRow(items: chips);
    } else if (chips.isEmpty) {
      header = Align(alignment: Alignment.centerLeft, child: trailingAction);
    } else {
      header = Row(
        children: [
          Expanded(child: _MetadataChipRow(items: chips)),
          const SizedBox(width: 8),
          trailingAction,
        ],
      );
    }

    return Padding(padding: padding, child: header);
  }
}

/// Horizontally-scrolling run of decorative metadata, rendered as a single
/// [Text.rich] rather than bordered chips: each item is an inline icon followed
/// by its value, with neighbouring items joined by a faded middot. This is far
/// more horizontally compact than a row of pills (no per-chip border, padding
/// or background), and since the items are purely decorative there's no tap
/// target to preserve. The leading icon of each group doubles as a visual
/// separator; the middot keeps multi-word values from blurring into the next
/// icon.
class _MetadataChipRow extends StatelessWidget {
  final List<_ResolvedMetadataItem> items;

  const _MetadataChipRow({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final labelStyle = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    final spans = <InlineSpan>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) {
        spans.add(
          TextSpan(
            text: '  ·  ',
            style: labelStyle?.copyWith(color: colorScheme.outlineVariant),
          ),
        );
      }

      final item = items[i];

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              _iconFor(item.item.key),
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );

      if (item.isLanguage) {
        // The language value resolves asynchronously via a provider, so it has
        // to be an embedded consumer widget rather than a plain TextSpan.
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _ResolvedLanguageLabel(
              languageTag: item.item.value,
              style: labelStyle,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text:
                _formatValue(item.item.key, item.item.value) ?? item.item.value,
            style: labelStyle,
          ),
        );
      }
    }

    return FadingScroll(
      fadingSize: 15,
      builder: (context, controller) {
        return SingleChildScrollView(
          controller: controller,
          scrollDirection: Axis.horizontal,
          child: Text.rich(
            TextSpan(children: spans),
            maxLines: 1,
            softWrap: false,
          ),
        );
      },
    );
  }
}

/// The trailing chevron toggle for the snippets panel. Mirrors the card's
/// Fetch button (tonal fill, compact density) so the two trailing actions read
/// as a consistent pair; the chevron rotates to reflect the expanded state.
class SearchResultSnippetsToggle extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;

  const SearchResultSnippetsToggle({
    super.key,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      icon: AnimatedRotation(
        turns: expanded ? 0.5 : 0,
        duration: const Duration(milliseconds: 200),
        child: const Icon(Icons.expand_more, size: 16),
      ),
      visualDensity: VisualDensity.compact,
      tooltip: 'Snippets',
    );
  }
}

/// The expanded snippet/review/question entries, in a tinted full-bleed panel.
/// Intended to be placed *outside* the card's content padding so it spans edge
/// to edge and its bottom corners are clipped by the card (pass [borderRadius]
/// when used somewhere without a clipping ancestor). Questions get a bold `Q:`
/// prefix and italic body; snippets and reviews render plain.
class SearchResultSnippetsPanel extends StatelessWidget {
  final List<MetadataItem> entries;
  final BorderRadius borderRadius;

  const SearchResultSnippetsPanel({
    super.key,
    required this.entries,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: borderRadius,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Snippets',
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          for (final item in entries) ...[
            if (item != entries.first) const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  if (item.key == 'question')
                    TextSpan(
                      text: 'Q: ',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  TextSpan(
                    text: item.value,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                      fontStyle: item.key == 'question'
                          ? FontStyle.italic
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResolvedMetadataItem {
  final MetadataItem item;
  final bool isLanguage;
  const _ResolvedMetadataItem({required this.item, required this.isLanguage});
}

class _ResolvedLanguageLabel extends ConsumerWidget {
  final String languageTag;
  final TextStyle? style;

  const _ResolvedLanguageLabel({required this.languageTag, this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = intl.Locale.tryParse(languageTag);

    if (locale == null) return Text(languageTag, style: style);

    final resolved = ref.watch(resolveLocaleProvider(locale));

    return Text(
      resolved.maybeWhen(
        data: (data) => data.languageName,
        orElse: () => languageTag,
      ),
      style: style,
    );
  }
}
