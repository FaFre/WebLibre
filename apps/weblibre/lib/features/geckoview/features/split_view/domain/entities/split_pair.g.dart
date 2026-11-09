// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_pair.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SplitPairCWProxy {
  SplitPair firstTabId(String firstTabId);

  SplitPair secondTabId(String secondTabId);

  SplitPair layout(SplitLayoutPreference layout);

  SplitPair sideBySideRatio(double sideBySideRatio);

  SplitPair stackedRatio(double stackedRatio);

  SplitPair focusedOnly(bool focusedOnly);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `SplitPair(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SplitPair(...).copyWith(id: 12, name: "My name")
  /// ```
  SplitPair call({
    String firstTabId,
    String secondTabId,
    SplitLayoutPreference layout,
    double sideBySideRatio,
    double stackedRatio,
    bool focusedOnly,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfSplitPair.copyWith(...)` or call `instanceOfSplitPair.copyWith.fieldName(value)` for a single field.
class _$SplitPairCWProxyImpl implements _$SplitPairCWProxy {
  const _$SplitPairCWProxyImpl(this._value);

  final SplitPair _value;

  @override
  SplitPair firstTabId(String firstTabId) => call(firstTabId: firstTabId);

  @override
  SplitPair secondTabId(String secondTabId) => call(secondTabId: secondTabId);

  @override
  SplitPair layout(SplitLayoutPreference layout) => call(layout: layout);

  @override
  SplitPair sideBySideRatio(double sideBySideRatio) =>
      call(sideBySideRatio: sideBySideRatio);

  @override
  SplitPair stackedRatio(double stackedRatio) =>
      call(stackedRatio: stackedRatio);

  @override
  SplitPair focusedOnly(bool focusedOnly) => call(focusedOnly: focusedOnly);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `SplitPair(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SplitPair(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  SplitPair call({
    Object? firstTabId = const $CopyWithPlaceholder(),
    Object? secondTabId = const $CopyWithPlaceholder(),
    Object? layout = const $CopyWithPlaceholder(),
    Object? sideBySideRatio = const $CopyWithPlaceholder(),
    Object? stackedRatio = const $CopyWithPlaceholder(),
    Object? focusedOnly = const $CopyWithPlaceholder(),
  }) {
    return SplitPair(
      pairId: _value.pairId,
      firstTabId:
          firstTabId == const $CopyWithPlaceholder() || firstTabId == null
          ? _value.firstTabId
          // ignore: cast_nullable_to_non_nullable
          : firstTabId as String,
      secondTabId:
          secondTabId == const $CopyWithPlaceholder() || secondTabId == null
          ? _value.secondTabId
          // ignore: cast_nullable_to_non_nullable
          : secondTabId as String,
      layout: layout == const $CopyWithPlaceholder() || layout == null
          ? _value.layout
          // ignore: cast_nullable_to_non_nullable
          : layout as SplitLayoutPreference,
      sideBySideRatio:
          sideBySideRatio == const $CopyWithPlaceholder() ||
              sideBySideRatio == null
          ? _value.sideBySideRatio
          // ignore: cast_nullable_to_non_nullable
          : sideBySideRatio as double,
      stackedRatio:
          stackedRatio == const $CopyWithPlaceholder() || stackedRatio == null
          ? _value.stackedRatio
          // ignore: cast_nullable_to_non_nullable
          : stackedRatio as double,
      focusedOnly:
          focusedOnly == const $CopyWithPlaceholder() || focusedOnly == null
          ? _value.focusedOnly
          // ignore: cast_nullable_to_non_nullable
          : focusedOnly as bool,
    );
  }
}

extension $SplitPairCopyWith on SplitPair {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfSplitPair.copyWith(...)` or `instanceOfSplitPair.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SplitPairCWProxy get copyWith => _$SplitPairCWProxyImpl(this);
}
