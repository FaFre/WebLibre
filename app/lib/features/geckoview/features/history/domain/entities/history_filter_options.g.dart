// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_filter_options.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HistoryFilterOptionsCWProxy {
  HistoryFilterOptions start(DateTime? start);

  HistoryFilterOptions end(DateTime? end);

  HistoryFilterOptions visitTypes(Set<VisitType> visitTypes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HistoryFilterOptions(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HistoryFilterOptions(...).copyWith(id: 12, name: "My name")
  /// ````
  HistoryFilterOptions call({
    DateTime? start,
    DateTime? end,
    Set<VisitType> visitTypes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHistoryFilterOptions.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHistoryFilterOptions.copyWith.fieldName(...)`
class _$HistoryFilterOptionsCWProxyImpl
    implements _$HistoryFilterOptionsCWProxy {
  const _$HistoryFilterOptionsCWProxyImpl(this._value);

  final HistoryFilterOptions _value;

  @override
  HistoryFilterOptions start(DateTime? start) => this(start: start);

  @override
  HistoryFilterOptions end(DateTime? end) => this(end: end);

  @override
  HistoryFilterOptions visitTypes(Set<VisitType> visitTypes) =>
      this(visitTypes: visitTypes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HistoryFilterOptions(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HistoryFilterOptions(...).copyWith(id: 12, name: "My name")
  /// ````
  HistoryFilterOptions call({
    Object? start = const $CopyWithPlaceholder(),
    Object? end = const $CopyWithPlaceholder(),
    Object? visitTypes = const $CopyWithPlaceholder(),
  }) {
    return HistoryFilterOptions(
      start: start == const $CopyWithPlaceholder()
          ? _value.start
          // ignore: cast_nullable_to_non_nullable
          : start as DateTime?,
      end: end == const $CopyWithPlaceholder()
          ? _value.end
          // ignore: cast_nullable_to_non_nullable
          : end as DateTime?,
      visitTypes: visitTypes == const $CopyWithPlaceholder()
          ? _value.visitTypes
          // ignore: cast_nullable_to_non_nullable
          : visitTypes as Set<VisitType>,
    );
  }
}

extension $HistoryFilterOptionsCopyWith on HistoryFilterOptions {
  /// Returns a callable class that can be used as follows: `instanceOfHistoryFilterOptions.copyWith(...)` or like so:`instanceOfHistoryFilterOptions.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HistoryFilterOptionsCWProxy get copyWith =>
      _$HistoryFilterOptionsCWProxyImpl(this);
}
