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
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/core/sort_field.dart';
import 'package:weblibre/data/database/converters/date_time_range.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_list_scope.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';

part 'tab_view_filter_options.g.dart';

enum TabTypeFilter {
  all,
  regularOnly,
  privateOnly,
  isolatedOnly;

  bool matches(TabMode? tabMode) => switch (this) {
    all => true,
    regularOnly => tabMode is RegularTabMode,
    privateOnly => tabMode is PrivateTabMode,
    isolatedOnly => tabMode is IsolatedTabMode,
  };
}

enum TabSortType {
  manual(null),
  titleAsc(SortField.titleAsc),
  titleDesc(SortField.titleDesc),
  urlAsc(SortField.urlAsc),
  urlDesc(SortField.urlDesc),
  newestFirst(SortField.dateDesc),
  oldestFirst(SortField.dateAsc);

  final SortField? sortField;

  const TabSortType(this.sortField);
}

enum TabQuickInterval {
  last1h(Duration(hours: 1)),
  last3h(Duration(hours: 3)),
  last8h(Duration(hours: 8)),
  last1d(Duration(days: 1)),
  last3d(Duration(days: 3)),
  last1w(Duration(days: 7)),
  last1m(Duration(days: 30));

  final Duration duration;

  const TabQuickInterval(this.duration);

  DateTimeRange<DateTime> toDateRange() {
    final now = DateTime.now();
    return DateTimeRange(start: now.subtract(duration), end: now);
  }
}

@JsonSerializable()
@CopyWith()
class TabViewFilterOptions with FastEquatable {
  final TabTypeFilter tabTypeFilter;
  final TabSortType sortType;
  final bool sortPinnedFirst;
  @JsonKey(defaultValue: true)
  final bool showHierarchicalTabs;
  @DateTimeRangeConverter()
  final DateTimeRange<DateTime>? dateRange;
  final TabQuickInterval? quickInterval;

  TabViewFilterOptions({
    required this.tabTypeFilter,
    required this.sortType,
    required this.sortPinnedFirst,
    required this.showHierarchicalTabs,
    required this.dateRange,
    required this.quickInterval,
  });

  TabViewFilterOptions.withDefaults()
    : this(
        tabTypeFilter: TabTypeFilter.all,
        sortType: TabSortType.manual,
        sortPinnedFirst: true,
        showHierarchicalTabs: true,
        dateRange: null,
        quickInterval: null,
      );

  bool get hasActiveFilter =>
      tabTypeFilter != TabTypeFilter.all ||
      sortType != TabSortType.manual ||
      dateRange != null ||
      quickInterval != null;

  DateTimeRange<DateTime>? get effectiveDateRange =>
      quickInterval?.toDateRange() ?? dateRange;

  bool matchesTab(TabMode? tabMode, DateTime? timestamp) {
    if (!tabTypeFilter.matches(tabMode)) return false;
    final range = effectiveDateRange;
    if (range != null &&
        timestamp != null &&
        (timestamp.isBefore(range.start) || timestamp.isAfter(range.end))) {
      return false;
    }
    return true;
  }

  /// The same options with everything the tray owns stripped back to its
  /// default, for surfaces outside the tray ([TabListScope.presentation]).
  ///
  /// The tab-type filter, the date range and the title/URL/date sort are
  /// controls the user can only reach with the tray open, yet they persist well
  /// past it. Neutralising them here — rather than branching at each of the
  /// half-dozen places the grouping code reads them — is what stops them
  /// reordering or hiding rows on a surface that is on screen while the tray is
  /// closed.
  ///
  /// [sortPinnedFirst] and [showHierarchicalTabs] deliberately survive: they
  /// describe how tabs are structured everywhere, not what the tray is
  /// currently showing.
  TabViewFilterOptions toPresentationScope() => TabViewFilterOptions(
    tabTypeFilter: TabTypeFilter.all,
    sortType: TabSortType.manual,
    sortPinnedFirst: sortPinnedFirst,
    showHierarchicalTabs: showHierarchicalTabs,
    dateRange: null,
    quickInterval: null,
  );

  @override
  List<Object?> get hashParameters => [
    tabTypeFilter,
    sortType,
    sortPinnedFirst,
    showHierarchicalTabs,
    dateRange,
    quickInterval,
  ];

  factory TabViewFilterOptions.fromJson(Map<String, dynamic> json) =>
      _$TabViewFilterOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$TabViewFilterOptionsToJson(this);
}
