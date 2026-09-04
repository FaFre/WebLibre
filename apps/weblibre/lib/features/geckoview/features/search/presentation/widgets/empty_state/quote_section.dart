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
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_section.dart';
import 'package:weblibre/features/quotes/data/database/definitions.drift.dart';
import 'package:weblibre/features/quotes/domain/providers.dart';

/// The daily quote card.
///
/// Was hardcoded into the browser home; it is a module so it can be switched
/// off, which is the single most-requested change to that page.
///
/// Renders as a card rather than as a section of the page, because it is the
/// one module that is a single object: it has no rows to count, nothing to
/// paginate and nothing to show more of. Given the same uppercase heading as
/// the lists around it, a piece of decorative text with no list under it reads
/// as a section that failed to load.
class QuoteSection extends ConsumerWidget {
  const QuoteSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteAsync = ref.watch(randomQuoteProvider);

    return SearchModuleSection(
      title: 'A thought for the road',
      moduleType: SearchModuleType.quote,
      // A single card rather than a list: nothing to count or paginate.
      totalCount: 0,
      showPagination: false,
      card: true,
      headerLeading: const _QuoteMark(),
      headerTrailing: IconButton.filledTonal(
        tooltip: 'Refresh quote',
        onPressed: () => ref.invalidate(randomQuoteProvider),
        icon: const Icon(Icons.refresh_rounded),
      ),
      contentSliverBuilder: ({required isCollapsed, required visibleCount}) => [
        if (!isCollapsed)
          SliverToBoxAdapter(
            // The card supplies the insets; only the gap under the header is
            // this module's to add.
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: switch (quoteAsync) {
                AsyncData(:final value) => _QuoteBlock(quote: value),
                AsyncError() => const _QuotePlaceholder(),
                _ => const LinearProgressIndicator(minHeight: 3),
              },
            ),
          ),
      ],
    );
  }
}

/// The tile in front of the card's title.
class _QuoteMark extends StatelessWidget {
  const _QuoteMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(MdiIcons.formatQuoteOpen, size: 18),
    );
  }
}

class _QuotePlaceholder extends StatelessWidget {
  const _QuotePlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      'Open a new tab and make this space your own.',
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
    );
  }
}

class _QuoteBlock extends StatelessWidget {
  final Quote? quote;

  const _QuoteBlock({required this.quote});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (quote == null) {
      return const _QuotePlaceholder();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '"${quote!.quote}"',
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.55,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '- ${quote!.author}',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (quote!.source case final String source when source.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            source,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
