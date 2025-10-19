// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference_setting.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PreferenceSettingGroupCWProxy {
  PreferenceSettingGroup description(String? description);

  PreferenceSettingGroup settings(Map<String, PreferenceSetting> settings);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `PreferenceSettingGroup(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PreferenceSettingGroup(...).copyWith(id: 12, name: "My name")
  /// ```
  PreferenceSettingGroup call({
    String? description,
    Map<String, PreferenceSetting> settings,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfPreferenceSettingGroup.copyWith(...)` or call `instanceOfPreferenceSettingGroup.copyWith.fieldName(value)` for a single field.
class _$PreferenceSettingGroupCWProxyImpl
    implements _$PreferenceSettingGroupCWProxy {
  const _$PreferenceSettingGroupCWProxyImpl(this._value);

  final PreferenceSettingGroup _value;

  @override
  PreferenceSettingGroup description(String? description) =>
      call(description: description);

  @override
  PreferenceSettingGroup settings(Map<String, PreferenceSetting> settings) =>
      call(settings: settings);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `PreferenceSettingGroup(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PreferenceSettingGroup(...).copyWith(id: 12, name: "My name")
  /// ```
  PreferenceSettingGroup call({
    Object? description = const $CopyWithPlaceholder(),
    Object? settings = const $CopyWithPlaceholder(),
  }) {
    return PreferenceSettingGroup(
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      settings: settings == const $CopyWithPlaceholder() || settings == null
          ? _value.settings
          // ignore: cast_nullable_to_non_nullable
          : settings as Map<String, PreferenceSetting>,
    );
  }
}

extension $PreferenceSettingGroupCopyWith on PreferenceSettingGroup {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfPreferenceSettingGroup.copyWith(...)` or `instanceOfPreferenceSettingGroup.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PreferenceSettingGroupCWProxy get copyWith =>
      _$PreferenceSettingGroupCWProxyImpl(this);
}

abstract class _$PreferenceSettingCWProxy {
  PreferenceSetting value(Object value);

  PreferenceSetting title(String? title);

  PreferenceSetting description(String? description);

  PreferenceSetting current(GeckoPref? current);

  PreferenceSetting requireUserOptIn(bool requireUserOptIn);

  PreferenceSetting shouldBeDefault(bool shouldBeDefault);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `PreferenceSetting(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PreferenceSetting(...).copyWith(id: 12, name: "My name")
  /// ```
  PreferenceSetting call({
    Object value,
    String? title,
    String? description,
    GeckoPref? current,
    bool requireUserOptIn,
    bool shouldBeDefault,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfPreferenceSetting.copyWith(...)` or call `instanceOfPreferenceSetting.copyWith.fieldName(value)` for a single field.
class _$PreferenceSettingCWProxyImpl implements _$PreferenceSettingCWProxy {
  const _$PreferenceSettingCWProxyImpl(this._value);

  final PreferenceSetting _value;

  @override
  PreferenceSetting value(Object value) => call(value: value);

  @override
  PreferenceSetting title(String? title) => call(title: title);

  @override
  PreferenceSetting description(String? description) =>
      call(description: description);

  @override
  PreferenceSetting current(GeckoPref? current) => call(current: current);

  @override
  PreferenceSetting requireUserOptIn(bool requireUserOptIn) =>
      call(requireUserOptIn: requireUserOptIn);

  @override
  PreferenceSetting shouldBeDefault(bool shouldBeDefault) =>
      call(shouldBeDefault: shouldBeDefault);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `PreferenceSetting(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PreferenceSetting(...).copyWith(id: 12, name: "My name")
  /// ```
  PreferenceSetting call({
    Object? value = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? current = const $CopyWithPlaceholder(),
    Object? requireUserOptIn = const $CopyWithPlaceholder(),
    Object? shouldBeDefault = const $CopyWithPlaceholder(),
  }) {
    return PreferenceSetting(
      value: value == const $CopyWithPlaceholder() || value == null
          ? _value.value
          // ignore: cast_nullable_to_non_nullable
          : value as Object,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      current: current == const $CopyWithPlaceholder()
          ? _value.current
          // ignore: cast_nullable_to_non_nullable
          : current as GeckoPref?,
      requireUserOptIn:
          requireUserOptIn == const $CopyWithPlaceholder() ||
              requireUserOptIn == null
          ? _value.requireUserOptIn
          // ignore: cast_nullable_to_non_nullable
          : requireUserOptIn as bool,
      shouldBeDefault:
          shouldBeDefault == const $CopyWithPlaceholder() ||
              shouldBeDefault == null
          ? _value.shouldBeDefault
          // ignore: cast_nullable_to_non_nullable
          : shouldBeDefault as bool,
    );
  }
}

extension $PreferenceSettingCopyWith on PreferenceSetting {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfPreferenceSetting.copyWith(...)` or `instanceOfPreferenceSetting.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PreferenceSettingCWProxy get copyWith =>
      _$PreferenceSettingCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreferenceSetting _$PreferenceSettingFromJson(Map<String, dynamic> json) =>
    PreferenceSetting(
      value: json['value'] as Object,
      title: json['title'] as String?,
      description: json['description'] as String?,
      requireUserOptIn: json['requireUserOptIn'] as bool? ?? false,
      shouldBeDefault: json['shouldBeDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$PreferenceSettingToJson(PreferenceSetting instance) =>
    <String, dynamic>{
      'value': instance.value,
      'title': instance.title,
      'description': instance.description,
      'requireUserOptIn': instance.requireUserOptIn,
      'shouldBeDefault': instance.shouldBeDefault,
    };
