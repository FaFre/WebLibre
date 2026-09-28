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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:search_protocol/search_protocol.dart';
import 'package:weblibre/features/search_credits/domain/repositories/web_search_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

class SearchModeSelector extends ConsumerWidget {
  const SearchModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final searchMode = ref.watch(
      webSearchSettingsControllerProvider.select((s) => s.searchMode),
    );

    return MenuAnchor(
      builder: (context, controller, _) => InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_iconFor(searchMode), color: colorScheme.primary, size: 18),
              const SizedBox(width: 6),
              Text(
                _labelFor(l10n, searchMode),
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
      menuChildren: [
        for (final mode in SearchMode.values)
          MenuItemButton(
            onPressed: () {
              ref
                  .read(webSearchSettingsControllerProvider.notifier)
                  .setSearchMode(mode);
            },
            leadingIcon: Icon(
              _iconFor(mode),
              size: 20,
              color: mode == searchMode
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            trailingIcon: mode == searchMode
                ? Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _labelFor(l10n, mode),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: mode == searchMode
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                Text(
                  _descriptionFor(l10n, mode),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static IconData _iconFor(SearchMode mode) => switch (mode) {
    SearchMode.general => Icons.public,
    SearchMode.independentWeb => Icons.volunteer_activism,
    SearchMode.smallWeb => Icons.explore,
  };

  static String _labelFor(AppLocalizations l10n, SearchMode mode) =>
      switch (mode) {
        SearchMode.general => l10n.webSearch_modeGeneralLabel,
        SearchMode.independentWeb => l10n.webSearch_modeIndependentWebLabel,
        SearchMode.smallWeb => l10n.webSearch_modeSmallWebLabel,
      };

  static String _descriptionFor(AppLocalizations l10n, SearchMode mode) =>
      switch (mode) {
        SearchMode.general => l10n.webSearch_modeGeneralDescription,
        SearchMode.independentWeb =>
          l10n.webSearch_modeIndependentWebDescription,
        SearchMode.smallWeb => l10n.webSearch_modeSmallWebDescription,
      };
}
