// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_extension.dart';

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

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `WebExtensionState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// WebExtensionState(...).copyWith(id: 12, name: "My name")
  /// ```
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

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfWebExtensionState.copyWith(...)` or call `instanceOfWebExtensionState.copyWith.fieldName(value)` for a single field.
class _$WebExtensionStateCWProxyImpl implements _$WebExtensionStateCWProxy {
  const _$WebExtensionStateCWProxyImpl(this._value);

  final WebExtensionState _value;

  @override
  WebExtensionState extensionId(String extensionId) =>
      call(extensionId: extensionId);

  @override
  WebExtensionState enabled(bool enabled) => call(enabled: enabled);

  @override
  WebExtensionState title(String? title) => call(title: title);

  @override
  WebExtensionState badgeText(String? badgeText) => call(badgeText: badgeText);

  @override
  WebExtensionState badgeTextColor(Color? badgeTextColor) =>
      call(badgeTextColor: badgeTextColor);

  @override
  WebExtensionState badgeBackgroundColor(Color? badgeBackgroundColor) =>
      call(badgeBackgroundColor: badgeBackgroundColor);

  @override
  WebExtensionState icon(EquatableImage? icon) => call(icon: icon);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `WebExtensionState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// WebExtensionState(...).copyWith(id: 12, name: "My name")
  /// ```
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
          extensionId == const $CopyWithPlaceholder() || extensionId == null
          ? _value.extensionId
          // ignore: cast_nullable_to_non_nullable
          : extensionId as String,
      enabled: enabled == const $CopyWithPlaceholder() || enabled == null
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      badgeText: badgeText == const $CopyWithPlaceholder()
          ? _value.badgeText
          // ignore: cast_nullable_to_non_nullable
          : badgeText as String?,
      badgeTextColor: badgeTextColor == const $CopyWithPlaceholder()
          ? _value.badgeTextColor
          // ignore: cast_nullable_to_non_nullable
          : badgeTextColor as Color?,
      badgeBackgroundColor: badgeBackgroundColor == const $CopyWithPlaceholder()
          ? _value.badgeBackgroundColor
          // ignore: cast_nullable_to_non_nullable
          : badgeBackgroundColor as Color?,
      icon: icon == const $CopyWithPlaceholder()
          ? _value.icon
          // ignore: cast_nullable_to_non_nullable
          : icon as EquatableImage?,
    );
  }
}

extension $WebExtensionStateCopyWith on WebExtensionState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfWebExtensionState.copyWith(...)` or `instanceOfWebExtensionState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WebExtensionStateCWProxy get copyWith =>
      _$WebExtensionStateCWProxyImpl(this);
}
