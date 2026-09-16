// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyboard_shortcut_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$KeyboardShortcutSettingsCWProxy {
  KeyboardShortcutSettings enabled(bool enabled);

  KeyboardShortcutSettings overrides(
    Map<BrowserAction, List<KeyChord>> overrides,
  );

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `KeyboardShortcutSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// KeyboardShortcutSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  KeyboardShortcutSettings call({
    bool enabled,
    Map<BrowserAction, List<KeyChord>> overrides,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfKeyboardShortcutSettings.copyWith(...)` or call `instanceOfKeyboardShortcutSettings.copyWith.fieldName(value)` for a single field.
class _$KeyboardShortcutSettingsCWProxyImpl
    implements _$KeyboardShortcutSettingsCWProxy {
  const _$KeyboardShortcutSettingsCWProxyImpl(this._value);

  final KeyboardShortcutSettings _value;

  @override
  KeyboardShortcutSettings enabled(bool enabled) => call(enabled: enabled);

  @override
  KeyboardShortcutSettings overrides(
    Map<BrowserAction, List<KeyChord>> overrides,
  ) => call(overrides: overrides);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `KeyboardShortcutSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// KeyboardShortcutSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  KeyboardShortcutSettings call({
    Object? enabled = const $CopyWithPlaceholder(),
    Object? overrides = const $CopyWithPlaceholder(),
  }) {
    return KeyboardShortcutSettings(
      enabled: enabled == const $CopyWithPlaceholder() || enabled == null
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool,
      overrides: overrides == const $CopyWithPlaceholder() || overrides == null
          ? _value.overrides
          // ignore: cast_nullable_to_non_nullable
          : overrides as Map<BrowserAction, List<KeyChord>>,
    );
  }
}

extension $KeyboardShortcutSettingsCopyWith on KeyboardShortcutSettings {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfKeyboardShortcutSettings.copyWith(...)` or `instanceOfKeyboardShortcutSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$KeyboardShortcutSettingsCWProxy get copyWith =>
      _$KeyboardShortcutSettingsCWProxyImpl(this);
}
