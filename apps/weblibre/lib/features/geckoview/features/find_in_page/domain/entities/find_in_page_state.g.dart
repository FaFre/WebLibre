// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_in_page_state.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FindInPageStateCWProxy {
  FindInPageState visible(bool visible);

  FindInPageState lastSearchText(String? lastSearchText);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `FindInPageState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// FindInPageState(...).copyWith(id: 12, name: "My name")
  /// ```
  FindInPageState call({bool visible, String? lastSearchText});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfFindInPageState.copyWith(...)` or call `instanceOfFindInPageState.copyWith.fieldName(value)` for a single field.
class _$FindInPageStateCWProxyImpl implements _$FindInPageStateCWProxy {
  const _$FindInPageStateCWProxyImpl(this._value);

  final FindInPageState _value;

  @override
  FindInPageState visible(bool visible) => call(visible: visible);

  @override
  FindInPageState lastSearchText(String? lastSearchText) =>
      call(lastSearchText: lastSearchText);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `FindInPageState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// FindInPageState(...).copyWith(id: 12, name: "My name")
  /// ```
  FindInPageState call({
    Object? visible = const $CopyWithPlaceholder(),
    Object? lastSearchText = const $CopyWithPlaceholder(),
  }) {
    return FindInPageState(
      visible: visible == const $CopyWithPlaceholder() || visible == null
          ? _value.visible
          // ignore: cast_nullable_to_non_nullable
          : visible as bool,
      lastSearchText: lastSearchText == const $CopyWithPlaceholder()
          ? _value.lastSearchText
          // ignore: cast_nullable_to_non_nullable
          : lastSearchText as String?,
    );
  }
}

extension $FindInPageStateCopyWith on FindInPageState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfFindInPageState.copyWith(...)` or `instanceOfFindInPageState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FindInPageStateCWProxy get copyWith => _$FindInPageStateCWProxyImpl(this);
}
