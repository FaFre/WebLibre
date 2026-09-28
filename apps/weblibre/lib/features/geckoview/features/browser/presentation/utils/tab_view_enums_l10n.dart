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
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_view_filter_options.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Display labels for the tab view's filter/sort/mode enums.
extension TabTypeFilterL10n on TabTypeFilter {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      TabTypeFilter.all => l10n.browser_tabTypeFilterAll,
      TabTypeFilter.regularOnly => l10n.browser_tabTypeFilterRegular,
      TabTypeFilter.privateOnly => l10n.browser_tabTypeFilterPrivate,
      TabTypeFilter.isolatedOnly => l10n.browser_tabTypeFilterIsolated,
    };
  }
}

extension TabSortTypeL10n on TabSortType {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      TabSortType.manual => l10n.browser_tabSortDefault,
      TabSortType.titleAsc => l10n.browser_tabSortTitleAsc,
      TabSortType.titleDesc => l10n.browser_tabSortTitleDesc,
      TabSortType.urlAsc => l10n.browser_tabSortUrlAsc,
      TabSortType.urlDesc => l10n.browser_tabSortUrlDesc,
      TabSortType.newestFirst => l10n.browser_tabSortNewestFirst,
      TabSortType.oldestFirst => l10n.browser_tabSortOldestFirst,
    };
  }
}

extension TabQuickIntervalL10n on TabQuickInterval {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      TabQuickInterval.last1h => l10n.browser_tabIntervalLastHour,
      TabQuickInterval.last3h => l10n.browser_tabIntervalLast3Hours,
      TabQuickInterval.last8h => l10n.browser_tabIntervalLast8Hours,
      TabQuickInterval.last1d => l10n.browser_tabIntervalLastDay,
      TabQuickInterval.last3d => l10n.browser_tabIntervalLast3Days,
      TabQuickInterval.last1w => l10n.browser_tabIntervalLastWeek,
      TabQuickInterval.last1m => l10n.browser_tabIntervalLastMonth,
    };
  }
}

extension TabsViewModeL10n on TabsViewMode {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      TabsViewMode.list => l10n.browser_tabsViewModeList,
      TabsViewMode.grid => l10n.browser_tabsViewModeGrid,
      TabsViewMode.tree => l10n.browser_tabsViewModeTree,
    };
  }
}
