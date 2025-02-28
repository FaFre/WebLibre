// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'general_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GeneralSettingsCWProxy {
  GeneralSettings themeMode(ThemeMode themeMode);

  GeneralSettings enableReadability(bool enableReadability);

  GeneralSettings deleteBrowsingDataOnQuit(
    Set<DeleteBrowsingDataType>? deleteBrowsingDataOnQuit,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneralSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneralSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneralSettings call({
    ThemeMode themeMode,
    bool enableReadability,
    Set<DeleteBrowsingDataType>? deleteBrowsingDataOnQuit,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGeneralSettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGeneralSettings.copyWith.fieldName(...)`
class _$GeneralSettingsCWProxyImpl implements _$GeneralSettingsCWProxy {
  const _$GeneralSettingsCWProxyImpl(this._value);

  final GeneralSettings _value;

  @override
  GeneralSettings themeMode(ThemeMode themeMode) => this(themeMode: themeMode);

  @override
  GeneralSettings enableReadability(bool enableReadability) =>
      this(enableReadability: enableReadability);

  @override
  GeneralSettings deleteBrowsingDataOnQuit(
    Set<DeleteBrowsingDataType>? deleteBrowsingDataOnQuit,
  ) => this(deleteBrowsingDataOnQuit: deleteBrowsingDataOnQuit);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneralSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneralSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneralSettings call({
    Object? themeMode = const $CopyWithPlaceholder(),
    Object? enableReadability = const $CopyWithPlaceholder(),
    Object? deleteBrowsingDataOnQuit = const $CopyWithPlaceholder(),
  }) {
    return GeneralSettings(
      themeMode:
          themeMode == const $CopyWithPlaceholder()
              ? _value.themeMode
              // ignore: cast_nullable_to_non_nullable
              : themeMode as ThemeMode,
      enableReadability:
          enableReadability == const $CopyWithPlaceholder()
              ? _value.enableReadability
              // ignore: cast_nullable_to_non_nullable
              : enableReadability as bool,
      deleteBrowsingDataOnQuit:
          deleteBrowsingDataOnQuit == const $CopyWithPlaceholder()
              ? _value.deleteBrowsingDataOnQuit
              // ignore: cast_nullable_to_non_nullable
              : deleteBrowsingDataOnQuit as Set<DeleteBrowsingDataType>?,
    );
  }
}

extension $GeneralSettingsCopyWith on GeneralSettings {
  /// Returns a callable class that can be used as follows: `instanceOfGeneralSettings.copyWith(...)` or like so:`instanceOfGeneralSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GeneralSettingsCWProxy get copyWith => _$GeneralSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneralSettings _$GeneralSettingsFromJson(Map<String, dynamic> json) =>
    GeneralSettings.withDefaults(
      themeMode: $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']),
      enableReadability: json['enableReadability'] as bool?,
      deleteBrowsingDataOnQuit:
          (json['deleteBrowsingDataOnQuit'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$DeleteBrowsingDataTypeEnumMap, e))
              .toSet(),
    );

Map<String, dynamic> _$GeneralSettingsToJson(GeneralSettings instance) =>
    <String, dynamic>{
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'enableReadability': instance.enableReadability,
      'deleteBrowsingDataOnQuit':
          instance.deleteBrowsingDataOnQuit
              ?.map((e) => _$DeleteBrowsingDataTypeEnumMap[e]!)
              .toList(),
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$DeleteBrowsingDataTypeEnumMap = {
  DeleteBrowsingDataType.tabs: 'tabs',
  DeleteBrowsingDataType.history: 'history',
  DeleteBrowsingDataType.cookies: 'cookies',
  DeleteBrowsingDataType.cache: 'cache',
  DeleteBrowsingDataType.permissions: 'permissions',
  DeleteBrowsingDataType.downloads: 'downloads',
};
