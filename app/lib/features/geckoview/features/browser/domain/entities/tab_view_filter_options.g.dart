// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_view_filter_options.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TabViewFilterOptionsCWProxy {
  TabViewFilterOptions tabTypeFilter(TabTypeFilter tabTypeFilter);

  TabViewFilterOptions sortType(TabSortType sortType);

  TabViewFilterOptions sortPinnedFirst(bool sortPinnedFirst);

  TabViewFilterOptions dateRange(DateTimeRange<DateTime>? dateRange);

  TabViewFilterOptions quickInterval(TabQuickInterval? quickInterval);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `TabViewFilterOptions(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// TabViewFilterOptions(...).copyWith(id: 12, name: "My name")
  /// ```
  TabViewFilterOptions call({
    TabTypeFilter tabTypeFilter,
    TabSortType sortType,
    bool sortPinnedFirst,
    DateTimeRange<DateTime>? dateRange,
    TabQuickInterval? quickInterval,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfTabViewFilterOptions.copyWith(...)` or call `instanceOfTabViewFilterOptions.copyWith.fieldName(value)` for a single field.
class _$TabViewFilterOptionsCWProxyImpl
    implements _$TabViewFilterOptionsCWProxy {
  const _$TabViewFilterOptionsCWProxyImpl(this._value);

  final TabViewFilterOptions _value;

  @override
  TabViewFilterOptions tabTypeFilter(TabTypeFilter tabTypeFilter) =>
      call(tabTypeFilter: tabTypeFilter);

  @override
  TabViewFilterOptions sortType(TabSortType sortType) =>
      call(sortType: sortType);

  @override
  TabViewFilterOptions sortPinnedFirst(bool sortPinnedFirst) =>
      call(sortPinnedFirst: sortPinnedFirst);

  @override
  TabViewFilterOptions dateRange(DateTimeRange<DateTime>? dateRange) =>
      call(dateRange: dateRange);

  @override
  TabViewFilterOptions quickInterval(TabQuickInterval? quickInterval) =>
      call(quickInterval: quickInterval);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `TabViewFilterOptions(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// TabViewFilterOptions(...).copyWith(id: 12, name: "My name")
  /// ```
  TabViewFilterOptions call({
    Object? tabTypeFilter = const $CopyWithPlaceholder(),
    Object? sortType = const $CopyWithPlaceholder(),
    Object? sortPinnedFirst = const $CopyWithPlaceholder(),
    Object? dateRange = const $CopyWithPlaceholder(),
    Object? quickInterval = const $CopyWithPlaceholder(),
  }) {
    return TabViewFilterOptions(
      tabTypeFilter:
          tabTypeFilter == const $CopyWithPlaceholder() || tabTypeFilter == null
          ? _value.tabTypeFilter
          // ignore: cast_nullable_to_non_nullable
          : tabTypeFilter as TabTypeFilter,
      sortType: sortType == const $CopyWithPlaceholder() || sortType == null
          ? _value.sortType
          // ignore: cast_nullable_to_non_nullable
          : sortType as TabSortType,
      sortPinnedFirst:
          sortPinnedFirst == const $CopyWithPlaceholder() ||
              sortPinnedFirst == null
          ? _value.sortPinnedFirst
          // ignore: cast_nullable_to_non_nullable
          : sortPinnedFirst as bool,
      dateRange: dateRange == const $CopyWithPlaceholder()
          ? _value.dateRange
          // ignore: cast_nullable_to_non_nullable
          : dateRange as DateTimeRange<DateTime>?,
      quickInterval: quickInterval == const $CopyWithPlaceholder()
          ? _value.quickInterval
          // ignore: cast_nullable_to_non_nullable
          : quickInterval as TabQuickInterval?,
    );
  }
}

extension $TabViewFilterOptionsCopyWith on TabViewFilterOptions {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfTabViewFilterOptions.copyWith(...)` or `instanceOfTabViewFilterOptions.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TabViewFilterOptionsCWProxy get copyWith =>
      _$TabViewFilterOptionsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TabViewFilterOptions _$TabViewFilterOptionsFromJson(
  Map<String, dynamic> json,
) => TabViewFilterOptions(
  tabTypeFilter: $enumDecode(_$TabTypeFilterEnumMap, json['tabTypeFilter']),
  sortType: $enumDecode(_$TabSortTypeEnumMap, json['sortType']),
  sortPinnedFirst: json['sortPinnedFirst'] as bool,
  dateRange: const DateTimeRangeConverter().fromJson(
    json['dateRange'] as Map<String, dynamic>?,
  ),
  quickInterval: $enumDecodeNullable(
    _$TabQuickIntervalEnumMap,
    json['quickInterval'],
  ),
);

Map<String, dynamic> _$TabViewFilterOptionsToJson(
  TabViewFilterOptions instance,
) => <String, dynamic>{
  'tabTypeFilter': _$TabTypeFilterEnumMap[instance.tabTypeFilter]!,
  'sortType': _$TabSortTypeEnumMap[instance.sortType]!,
  'sortPinnedFirst': instance.sortPinnedFirst,
  'dateRange': const DateTimeRangeConverter().toJson(instance.dateRange),
  'quickInterval': _$TabQuickIntervalEnumMap[instance.quickInterval],
};

const _$TabTypeFilterEnumMap = {
  TabTypeFilter.all: 'all',
  TabTypeFilter.regularOnly: 'regularOnly',
  TabTypeFilter.privateOnly: 'privateOnly',
  TabTypeFilter.isolatedOnly: 'isolatedOnly',
};

const _$TabSortTypeEnumMap = {
  TabSortType.manual: 'manual',
  TabSortType.titleAsc: 'titleAsc',
  TabSortType.titleDesc: 'titleDesc',
  TabSortType.urlAsc: 'urlAsc',
  TabSortType.urlDesc: 'urlDesc',
  TabSortType.newestFirst: 'newestFirst',
  TabSortType.oldestFirst: 'oldestFirst',
};

const _$TabQuickIntervalEnumMap = {
  TabQuickInterval.last1h: 'last1h',
  TabQuickInterval.last3h: 'last3h',
  TabQuickInterval.last8h: 'last8h',
  TabQuickInterval.last1d: 'last1d',
  TabQuickInterval.last3d: 'last3d',
  TabQuickInterval.last1w: 'last1w',
  TabQuickInterval.last1m: 'last1m',
};
