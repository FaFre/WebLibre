// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_search_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WebSearchSettingsCWProxy {
  WebSearchSettings routeThroughTor(bool routeThroughTor);

  WebSearchSettings searchMode(SearchMode searchMode);

  WebSearchSettings language(String? language);

  WebSearchSettings region(String? region);

  WebSearchSettings safeSearch(SafeSearch? safeSearch);

  WebSearchSettings timeRange(TimeRange? timeRange);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `WebSearchSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// WebSearchSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  WebSearchSettings call({
    bool routeThroughTor,
    SearchMode searchMode,
    String? language,
    String? region,
    SafeSearch? safeSearch,
    TimeRange? timeRange,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfWebSearchSettings.copyWith(...)` or call `instanceOfWebSearchSettings.copyWith.fieldName(value)` for a single field.
class _$WebSearchSettingsCWProxyImpl implements _$WebSearchSettingsCWProxy {
  const _$WebSearchSettingsCWProxyImpl(this._value);

  final WebSearchSettings _value;

  @override
  WebSearchSettings routeThroughTor(bool routeThroughTor) =>
      call(routeThroughTor: routeThroughTor);

  @override
  WebSearchSettings searchMode(SearchMode searchMode) =>
      call(searchMode: searchMode);

  @override
  WebSearchSettings language(String? language) => call(language: language);

  @override
  WebSearchSettings region(String? region) => call(region: region);

  @override
  WebSearchSettings safeSearch(SafeSearch? safeSearch) =>
      call(safeSearch: safeSearch);

  @override
  WebSearchSettings timeRange(TimeRange? timeRange) =>
      call(timeRange: timeRange);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `WebSearchSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// WebSearchSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  WebSearchSettings call({
    Object? routeThroughTor = const $CopyWithPlaceholder(),
    Object? searchMode = const $CopyWithPlaceholder(),
    Object? language = const $CopyWithPlaceholder(),
    Object? region = const $CopyWithPlaceholder(),
    Object? safeSearch = const $CopyWithPlaceholder(),
    Object? timeRange = const $CopyWithPlaceholder(),
  }) {
    return WebSearchSettings(
      routeThroughTor:
          routeThroughTor == const $CopyWithPlaceholder() ||
              routeThroughTor == null
          ? _value.routeThroughTor
          // ignore: cast_nullable_to_non_nullable
          : routeThroughTor as bool,
      searchMode:
          searchMode == const $CopyWithPlaceholder() || searchMode == null
          ? _value.searchMode
          // ignore: cast_nullable_to_non_nullable
          : searchMode as SearchMode,
      language: language == const $CopyWithPlaceholder()
          ? _value.language
          // ignore: cast_nullable_to_non_nullable
          : language as String?,
      region: region == const $CopyWithPlaceholder()
          ? _value.region
          // ignore: cast_nullable_to_non_nullable
          : region as String?,
      safeSearch: safeSearch == const $CopyWithPlaceholder()
          ? _value.safeSearch
          // ignore: cast_nullable_to_non_nullable
          : safeSearch as SafeSearch?,
      timeRange: timeRange == const $CopyWithPlaceholder()
          ? _value.timeRange
          // ignore: cast_nullable_to_non_nullable
          : timeRange as TimeRange?,
    );
  }
}

extension $WebSearchSettingsCopyWith on WebSearchSettings {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfWebSearchSettings.copyWith(...)` or `instanceOfWebSearchSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WebSearchSettingsCWProxy get copyWith =>
      _$WebSearchSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebSearchSettings _$WebSearchSettingsFromJson(Map<String, dynamic> json) =>
    WebSearchSettings.withDefaults(
      routeThroughTor: json['routeThroughTor'] as bool?,
      searchMode: $enumDecodeNullable(_$SearchModeEnumMap, json['searchMode']),
      language: json['language'] as String?,
      region: json['region'] as String?,
      safeSearch: $enumDecodeNullable(_$SafeSearchEnumMap, json['safeSearch']),
      timeRange: $enumDecodeNullable(_$TimeRangeEnumMap, json['timeRange']),
    );

Map<String, dynamic> _$WebSearchSettingsToJson(WebSearchSettings instance) =>
    <String, dynamic>{
      'routeThroughTor': instance.routeThroughTor,
      'searchMode': _$SearchModeEnumMap[instance.searchMode]!,
      'language': instance.language,
      'region': instance.region,
      'safeSearch': _$SafeSearchEnumMap[instance.safeSearch],
      'timeRange': _$TimeRangeEnumMap[instance.timeRange],
    };

const _$SearchModeEnumMap = {
  SearchMode.general: 'general',
  SearchMode.independentWeb: 'independentWeb',
  SearchMode.smallWeb: 'smallWeb',
};

const _$SafeSearchEnumMap = {
  SafeSearch.none: 'none',
  SafeSearch.moderate: 'moderate',
  SafeSearch.strict: 'strict',
};

const _$TimeRangeEnumMap = {
  TimeRange.day: 'day',
  TimeRange.week: 'week',
  TimeRange.month: 'month',
  TimeRange.year: 'year',
};
