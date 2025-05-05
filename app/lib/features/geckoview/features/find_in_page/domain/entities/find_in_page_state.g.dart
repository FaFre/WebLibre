// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_in_page_state.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FindInPageStateCWProxy {
  FindInPageState visible(bool visible);

  FindInPageState lastSearchText(String? lastSearchText);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FindInPageState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FindInPageState(...).copyWith(id: 12, name: "My name")
  /// ````
  FindInPageState call({bool visible, String? lastSearchText});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFindInPageState.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFindInPageState.copyWith.fieldName(...)`
class _$FindInPageStateCWProxyImpl implements _$FindInPageStateCWProxy {
  const _$FindInPageStateCWProxyImpl(this._value);

  final FindInPageState _value;

  @override
  FindInPageState visible(bool visible) => this(visible: visible);

  @override
  FindInPageState lastSearchText(String? lastSearchText) =>
      this(lastSearchText: lastSearchText);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FindInPageState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FindInPageState(...).copyWith(id: 12, name: "My name")
  /// ````
  FindInPageState call({
    Object? visible = const $CopyWithPlaceholder(),
    Object? lastSearchText = const $CopyWithPlaceholder(),
  }) {
    return FindInPageState(
      visible:
          visible == const $CopyWithPlaceholder()
              ? _value.visible
              // ignore: cast_nullable_to_non_nullable
              : visible as bool,
      lastSearchText:
          lastSearchText == const $CopyWithPlaceholder()
              ? _value.lastSearchText
              // ignore: cast_nullable_to_non_nullable
              : lastSearchText as String?,
    );
  }
}

extension $FindInPageStateCopyWith on FindInPageState {
  /// Returns a callable class that can be used as follows: `instanceOfFindInPageState.copyWith(...)` or like so:`instanceOfFindInPageState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FindInPageStateCWProxy get copyWith => _$FindInPageStateCWProxyImpl(this);
}
