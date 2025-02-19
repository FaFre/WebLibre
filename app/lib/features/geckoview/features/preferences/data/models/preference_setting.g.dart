// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference_setting.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PreferenceSettingGroupCWProxy {
  PreferenceSettingGroup description(String? description);

  PreferenceSettingGroup settings(Map<String, PreferenceSetting> settings);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PreferenceSettingGroup(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PreferenceSettingGroup(...).copyWith(id: 12, name: "My name")
  /// ````
  PreferenceSettingGroup call({
    String? description,
    Map<String, PreferenceSetting> settings,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPreferenceSettingGroup.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPreferenceSettingGroup.copyWith.fieldName(...)`
class _$PreferenceSettingGroupCWProxyImpl
    implements _$PreferenceSettingGroupCWProxy {
  const _$PreferenceSettingGroupCWProxyImpl(this._value);

  final PreferenceSettingGroup _value;

  @override
  PreferenceSettingGroup description(String? description) =>
      this(description: description);

  @override
  PreferenceSettingGroup settings(Map<String, PreferenceSetting> settings) =>
      this(settings: settings);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PreferenceSettingGroup(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PreferenceSettingGroup(...).copyWith(id: 12, name: "My name")
  /// ````
  PreferenceSettingGroup call({
    Object? description = const $CopyWithPlaceholder(),
    Object? settings = const $CopyWithPlaceholder(),
  }) {
    return PreferenceSettingGroup(
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      settings: settings == const $CopyWithPlaceholder()
          ? _value.settings
          // ignore: cast_nullable_to_non_nullable
          : settings as Map<String, PreferenceSetting>,
    );
  }
}

extension $PreferenceSettingGroupCopyWith on PreferenceSettingGroup {
  /// Returns a callable class that can be used as follows: `instanceOfPreferenceSettingGroup.copyWith(...)` or like so:`instanceOfPreferenceSettingGroup.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PreferenceSettingGroupCWProxy get copyWith =>
      _$PreferenceSettingGroupCWProxyImpl(this);
}

abstract class _$PreferenceSettingCWProxy {
  PreferenceSetting value(Object value);

  PreferenceSetting title(String? title);

  PreferenceSetting description(String? description);

  PreferenceSetting actualValue(Object? actualValue);

  PreferenceSetting requireUserOptIn(bool requireUserOptIn);

  PreferenceSetting shouldBeDefault(bool shouldBeDefault);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PreferenceSetting(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PreferenceSetting(...).copyWith(id: 12, name: "My name")
  /// ````
  PreferenceSetting call({
    Object value,
    String? title,
    String? description,
    Object? actualValue,
    bool requireUserOptIn,
    bool shouldBeDefault,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPreferenceSetting.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPreferenceSetting.copyWith.fieldName(...)`
class _$PreferenceSettingCWProxyImpl implements _$PreferenceSettingCWProxy {
  const _$PreferenceSettingCWProxyImpl(this._value);

  final PreferenceSetting _value;

  @override
  PreferenceSetting value(Object value) => this(value: value);

  @override
  PreferenceSetting title(String? title) => this(title: title);

  @override
  PreferenceSetting description(String? description) =>
      this(description: description);

  @override
  PreferenceSetting actualValue(Object? actualValue) =>
      this(actualValue: actualValue);

  @override
  PreferenceSetting requireUserOptIn(bool requireUserOptIn) =>
      this(requireUserOptIn: requireUserOptIn);

  @override
  PreferenceSetting shouldBeDefault(bool shouldBeDefault) =>
      this(shouldBeDefault: shouldBeDefault);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PreferenceSetting(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PreferenceSetting(...).copyWith(id: 12, name: "My name")
  /// ````
  PreferenceSetting call({
    Object? value = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? actualValue = const $CopyWithPlaceholder(),
    Object? requireUserOptIn = const $CopyWithPlaceholder(),
    Object? shouldBeDefault = const $CopyWithPlaceholder(),
  }) {
    return PreferenceSetting(
      value: value == const $CopyWithPlaceholder()
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
      actualValue: actualValue == const $CopyWithPlaceholder()
          ? _value.actualValue
          // ignore: cast_nullable_to_non_nullable
          : actualValue as Object?,
      requireUserOptIn: requireUserOptIn == const $CopyWithPlaceholder()
          ? _value.requireUserOptIn
          // ignore: cast_nullable_to_non_nullable
          : requireUserOptIn as bool,
      shouldBeDefault: shouldBeDefault == const $CopyWithPlaceholder()
          ? _value.shouldBeDefault
          // ignore: cast_nullable_to_non_nullable
          : shouldBeDefault as bool,
    );
  }
}

extension $PreferenceSettingCopyWith on PreferenceSetting {
  /// Returns a callable class that can be used as follows: `instanceOfPreferenceSetting.copyWith(...)` or like so:`instanceOfPreferenceSetting.copyWith.fieldName(...)`.
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
