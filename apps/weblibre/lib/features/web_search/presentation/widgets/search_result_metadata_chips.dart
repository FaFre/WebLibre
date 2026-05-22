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
  // The publisher-declared article date duplicates the inline `publishedDate`
  // shown under the title. Keep only the inline version.
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
      .split(RegExp(r'[-_]'))
      .first;

  final query = queryTag.trim().toLowerCase().split(RegExp(r'[-_]')).first;

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

class SearchResultMetadataChips extends StatelessWidget {
  final List<MetadataItem> metadata;
  final PageMetadata? pageMetadata;

  /// ISO 639-1 language code of the query (e.g. `en`, `de`). When the
  /// result's `language` metadata matches by primary subtag, the language
  /// chip is suppressed as redundant.
  final String? queryLanguage;

  const SearchResultMetadataChips({
    super.key,
    required this.metadata,
    this.pageMetadata,
    this.queryLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final seen = <String>{};
    final merged = <_ResolvedMetadataItem>[];

    // Page metadata items first so they take priority on deduplication.
    for (final item in _metadataFromPage(pageMetadata)) {
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

    for (final item in metadata) {
      if (_expandableKeys.contains(item.key)) continue;
      if (_hiddenKeys.contains(item.key)) continue;
      if (item.value.trim().isEmpty) continue;
      if (item.key == 'language' &&
          _languageMatchesQuery(item.value, queryLanguage)) {
        continue;
      }
      // Skip if page metadata already provided this key (preview takes priority).
      if (!seen.add(item.key)) continue;
      merged.add(
        _ResolvedMetadataItem(item: item, isLanguage: item.key == 'language'),
      );
    }

    if (merged.isEmpty) return const SizedBox.shrink();

    merged.sort((a, b) {
      final ai = _keyOrderIndex[a.item.key] ?? _keyOrder.length;
      final bi = _keyOrderIndex[b.item.key] ?? _keyOrder.length;
      return ai.compareTo(bi);
    });

    return FadingScroll(
      fadingSize: 15,
      builder: (context, controller) {
        return SingleChildScrollView(
          controller: controller,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < merged.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                // Decorative — these chips don't filter or navigate. Using a
                // plain Chip (instead of an OutlinedButton with an empty
                // onPressed) avoids the misleading tap ripple.
                Chip(
                  avatar: Icon(
                    _iconFor(merged[i].item.key),
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  label: merged[i].isLanguage
                      ? _ResolvedLanguageLabel(
                          languageTag: merged[i].item.value,
                        )
                      : Text(
                          _formatValue(
                                merged[i].item.key,
                                merged[i].item.value,
                              ) ??
                              merged[i].item.value,
                        ),
                  side: BorderSide(color: colorScheme.outlineVariant),
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  backgroundColor: Colors.transparent,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
        );
      },
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

  const _ResolvedLanguageLabel({required this.languageTag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = intl.Locale.tryParse(languageTag);

    if (locale == null) return Text(languageTag);

    final resolved = ref.watch(resolveLocaleProvider(locale));

    return Text(
      resolved.maybeWhen(
        data: (data) => data.languageName,
        orElse: () => languageTag,
      ),
    );
  }
}

class SearchResultMetadataExpandable extends StatelessWidget {
  final List<MetadataItem> metadata;

  const SearchResultMetadataExpandable({super.key, required this.metadata});

  @override
  Widget build(BuildContext context) {
    final entries = metadata
        .where((item) => _expandableKeys.contains(item.key))
        .where((item) => item.value.trim().isNotEmpty)
        .toList();

    if (entries.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasSnippets = entries.any((e) => e.key == 'snippet');
    final hasReview = entries.any((e) => e.key == 'review');
    final hasQuestion = entries.any((e) => e.key == 'question');

    final parts = [
      if (hasQuestion) 'question',
      if (hasSnippets) 'snippets',
      if (hasReview) 'review',
    ];

    final label = parts.isEmpty ? 'More' : 'Show ${parts.join(' & ')}';

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        dense: true,
        visualDensity: VisualDensity.compact,
        title: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        children: [
          for (final item in entries) ...[
            if (item != entries.first) const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text.rich(
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
            ),
          ],
        ],
      ),
    );
  }
}
