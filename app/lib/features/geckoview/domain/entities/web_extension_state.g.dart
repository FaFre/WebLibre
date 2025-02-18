// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_extension_state.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WebExtensionStateCWProxy {
  WebExtensionState extensionId(String extensionId);

  WebExtensionState enabled(bool enabled);

  WebExtensionState title(String? title);

  WebExtensionState badgeText(String? badgeText);

  WebExtensionState badgeTextColor(Color? badgeTextColor);

  WebExtensionState badgeBackgroundColor(Color? badgeBackgroundColor);

  WebExtensionState icon(EquatableImage? icon);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WebExtensionState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WebExtensionState(...).copyWith(id: 12, name: "My name")
  /// ````
  WebExtensionState call({
    String extensionId,
    bool enabled,
    String? title,
    String? badgeText,
    Color? badgeTextColor,
    Color? badgeBackgroundColor,
    EquatableImage? icon,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWebExtensionState.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWebExtensionState.copyWith.fieldName(...)`
class _$WebExtensionStateCWProxyImpl implements _$WebExtensionStateCWProxy {
  const _$WebExtensionStateCWProxyImpl(this._value);

  final WebExtensionState _value;

  @override
  WebExtensionState extensionId(String extensionId) =>
      this(extensionId: extensionId);

  @override
  WebExtensionState enabled(bool enabled) => this(enabled: enabled);

  @override
  WebExtensionState title(String? title) => this(title: title);

  @override
  WebExtensionState badgeText(String? badgeText) => this(badgeText: badgeText);

  @override
  WebExtensionState badgeTextColor(Color? badgeTextColor) =>
      this(badgeTextColor: badgeTextColor);

  @override
  WebExtensionState badgeBackgroundColor(Color? badgeBackgroundColor) =>
      this(badgeBackgroundColor: badgeBackgroundColor);

  @override
  WebExtensionState icon(EquatableImage? icon) => this(icon: icon);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WebExtensionState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WebExtensionState(...).copyWith(id: 12, name: "My name")
  /// ````
  WebExtensionState call({
    Object? extensionId = const $CopyWithPlaceholder(),
    Object? enabled = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? badgeText = const $CopyWithPlaceholder(),
    Object? badgeTextColor = const $CopyWithPlaceholder(),
    Object? badgeBackgroundColor = const $CopyWithPlaceholder(),
    Object? icon = const $CopyWithPlaceholder(),
  }) {
    return WebExtensionState(
      extensionId:
          extensionId == const $CopyWithPlaceholder()
              ? _value.extensionId
              // ignore: cast_nullable_to_non_nullable
              : extensionId as String,
      enabled:
          enabled == const $CopyWithPlaceholder()
              ? _value.enabled
              // ignore: cast_nullable_to_non_nullable
              : enabled as bool,
      title:
          title == const $CopyWithPlaceholder()
              ? _value.title
              // ignore: cast_nullable_to_non_nullable
              : title as String?,
      badgeText:
          badgeText == const $CopyWithPlaceholder()
              ? _value.badgeText
              // ignore: cast_nullable_to_non_nullable
              : badgeText as String?,
      badgeTextColor:
          badgeTextColor == const $CopyWithPlaceholder()
              ? _value.badgeTextColor
              // ignore: cast_nullable_to_non_nullable
              : badgeTextColor as Color?,
      badgeBackgroundColor:
          badgeBackgroundColor == const $CopyWithPlaceholder()
              ? _value.badgeBackgroundColor
              // ignore: cast_nullable_to_non_nullable
              : badgeBackgroundColor as Color?,
      icon:
          icon == const $CopyWithPlaceholder()
              ? _value.icon
              // ignore: cast_nullable_to_non_nullable
              : icon as EquatableImage?,
    );
  }
}

extension $WebExtensionStateCopyWith on WebExtensionState {
  /// Returns a callable class that can be used as follows: `instanceOfWebExtensionState.copyWith(...)` or like so:`instanceOfWebExtensionState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WebExtensionStateCWProxy get copyWith =>
      _$WebExtensionStateCWProxyImpl(this);
}
