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
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';

part 'tab_view_filter_options.g.dart';

enum TabTypeFilter {
  all('All Tabs'),
  regularOnly('Regular'),
  privateOnly('Private'),
  isolatedOnly('Isolated');

  final String label;

  const TabTypeFilter(this.label);

  bool matches(TabMode? tabMode) => switch (this) {
    all => true,
    regularOnly => tabMode is RegularTabMode,
    privateOnly => tabMode is PrivateTabMode,
    isolatedOnly => tabMode is IsolatedTabMode,
  };
}

enum TabSortType {
  manual('Default', null),
  titleAsc('Title A-Z', SortField.titleAsc),
  titleDesc('Title Z-A', SortField.titleDesc),
  urlAsc('URL A-Z', SortField.urlAsc),
  urlDesc('URL Z-A', SortField.urlDesc),
  newestFirst('Newest First', SortField.dateDesc),
  oldestFirst('Oldest First', SortField.dateAsc);

  final String label;
  final SortField? sortField;

  const TabSortType(this.label, this.sortField);
}

enum TabQuickInterval {
  last1h('Last Hour', Duration(hours: 1)),
  last3h('Last 3 Hours', Duration(hours: 3)),
  last8h('Last 8 Hours', Duration(hours: 8)),
  last1d('Last Day', Duration(days: 1)),
  last3d('Last 3 Days', Duration(days: 3)),
  last1w('Last Week', Duration(days: 7)),
  last1m('Last Month', Duration(days: 30));

  final String label;
  final Duration duration;

  const TabQuickInterval(this.label, this.duration);

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
  @DateTimeRangeConverter()
  final DateTimeRange<DateTime>? dateRange;
  final TabQuickInterval? quickInterval;

  TabViewFilterOptions({
    required this.tabTypeFilter,
    required this.sortType,
    required this.sortPinnedFirst,
    required this.dateRange,
    required this.quickInterval,
  });

  TabViewFilterOptions.withDefaults()
    : this(
        tabTypeFilter: TabTypeFilter.all,
        sortType: TabSortType.manual,
        sortPinnedFirst: true,
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

  @override
  List<Object?> get hashParameters => [
    tabTypeFilter,
    sortType,
    sortPinnedFirst,
    dateRange,
    quickInterval,
  ];

  factory TabViewFilterOptions.fromJson(Map<String, dynamic> json) =>
      _$TabViewFilterOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$TabViewFilterOptionsToJson(this);
}
