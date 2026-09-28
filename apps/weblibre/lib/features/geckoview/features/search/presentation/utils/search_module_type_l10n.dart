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
import 'package:flutter/widgets.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Display labels for [SearchModuleType].
extension SearchModuleTypeL10n on SearchModuleType {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      SearchModuleType.recentSearches => l10n.search_moduleLabelRecentSearches,
      SearchModuleType.searchProviders =>
        l10n.search_moduleLabelSearchProviders,
      SearchModuleType.searchSuggestions =>
        l10n.search_moduleLabelSearchSuggestions,
      SearchModuleType.tabs => l10n.search_moduleLabelTabs,
      SearchModuleType.articles => l10n.search_moduleLabelArticles,
      SearchModuleType.bookmarks => l10n.search_moduleLabelBookmarks,
      SearchModuleType.history => l10n.search_moduleLabelHistory,
      SearchModuleType.localHistory => l10n.search_moduleLabelLocalHistory,
      SearchModuleType.combinedHistory =>
        l10n.search_moduleLabelCombinedHistory,
      SearchModuleType.popularSites => l10n.search_moduleLabelPopularSites,
      SearchModuleType.historyHighlights =>
        l10n.search_moduleLabelHistoryHighlights,
      SearchModuleType.topSites => l10n.search_moduleLabelTopSites,
      SearchModuleType.recentHistory => l10n.search_moduleLabelRecentHistory,
      SearchModuleType.recentArticles => l10n.search_moduleLabelRecentArticles,
      SearchModuleType.recentTabs => l10n.search_moduleLabelRecentTabs,
      SearchModuleType.containers => l10n.search_moduleLabelContainers,
      SearchModuleType.frequentBangs => l10n.search_moduleLabelFrequentBangs,
      SearchModuleType.quote => l10n.search_moduleLabelQuote,
      SearchModuleType.quickActions => l10n.search_moduleLabelQuickActions,
    };
  }
}
