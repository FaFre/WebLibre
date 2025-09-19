// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_filter_options.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HistoryFilterOptionsCWProxy {
  HistoryFilterOptions dateRange(DateTimeRange<DateTime>? dateRange);

  HistoryFilterOptions visitTypes(Set<VisitType> visitTypes);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `HistoryFilterOptions(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// HistoryFilterOptions(...).copyWith(id: 12, name: "My name")
  /// ```
  HistoryFilterOptions call({
    DateTimeRange<DateTime>? dateRange,
    Set<VisitType> visitTypes,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfHistoryFilterOptions.copyWith(...)` or call `instanceOfHistoryFilterOptions.copyWith.fieldName(value)` for a single field.
class _$HistoryFilterOptionsCWProxyImpl
    implements _$HistoryFilterOptionsCWProxy {
  const _$HistoryFilterOptionsCWProxyImpl(this._value);

  final HistoryFilterOptions _value;

  @override
  HistoryFilterOptions dateRange(DateTimeRange<DateTime>? dateRange) =>
      call(dateRange: dateRange);

  @override
  HistoryFilterOptions visitTypes(Set<VisitType> visitTypes) =>
      call(visitTypes: visitTypes);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `HistoryFilterOptions(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// HistoryFilterOptions(...).copyWith(id: 12, name: "My name")
  /// ```
  HistoryFilterOptions call({
    Object? dateRange = const $CopyWithPlaceholder(),
    Object? visitTypes = const $CopyWithPlaceholder(),
  }) {
    return HistoryFilterOptions(
      dateRange: dateRange == const $CopyWithPlaceholder()
          ? _value.dateRange
          // ignore: cast_nullable_to_non_nullable
          : dateRange as DateTimeRange<DateTime>?,
      visitTypes:
          visitTypes == const $CopyWithPlaceholder() || visitTypes == null
          ? _value.visitTypes
          // ignore: cast_nullable_to_non_nullable
          : visitTypes as Set<VisitType>,
    );
  }
}

extension $HistoryFilterOptionsCopyWith on HistoryFilterOptions {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfHistoryFilterOptions.copyWith(...)` or `instanceOfHistoryFilterOptions.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HistoryFilterOptionsCWProxy get copyWith =>
      _$HistoryFilterOptionsCWProxyImpl(this);
}
