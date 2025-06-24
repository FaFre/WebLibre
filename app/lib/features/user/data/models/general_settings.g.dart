// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'general_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GeneralSettingsCWProxy {
  GeneralSettings themeMode(ThemeMode themeMode);

  GeneralSettings enableReadability(bool enableReadability);

  GeneralSettings enforceReadability(bool enforceReadability);

  GeneralSettings deleteBrowsingDataOnQuit(
    Set<DeleteBrowsingDataType>? deleteBrowsingDataOnQuit,
  );

  GeneralSettings defaultSearchProvider(String defaultSearchProvider);

  GeneralSettings createChildTabsOption(bool createChildTabsOption);

  GeneralSettings proxyPrivateTabsTor(bool proxyPrivateTabsTor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneralSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneralSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneralSettings call({
    ThemeMode themeMode,
    bool enableReadability,
    bool enforceReadability,
    Set<DeleteBrowsingDataType>? deleteBrowsingDataOnQuit,
    String defaultSearchProvider,
    bool createChildTabsOption,
    bool proxyPrivateTabsTor,
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
  GeneralSettings enforceReadability(bool enforceReadability) =>
      this(enforceReadability: enforceReadability);

  @override
  GeneralSettings deleteBrowsingDataOnQuit(
    Set<DeleteBrowsingDataType>? deleteBrowsingDataOnQuit,
  ) => this(deleteBrowsingDataOnQuit: deleteBrowsingDataOnQuit);

  @override
  GeneralSettings defaultSearchProvider(String defaultSearchProvider) =>
      this(defaultSearchProvider: defaultSearchProvider);

  @override
  GeneralSettings createChildTabsOption(bool createChildTabsOption) =>
      this(createChildTabsOption: createChildTabsOption);

  @override
  GeneralSettings proxyPrivateTabsTor(bool proxyPrivateTabsTor) =>
      this(proxyPrivateTabsTor: proxyPrivateTabsTor);

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
    Object? enforceReadability = const $CopyWithPlaceholder(),
    Object? deleteBrowsingDataOnQuit = const $CopyWithPlaceholder(),
    Object? defaultSearchProvider = const $CopyWithPlaceholder(),
    Object? createChildTabsOption = const $CopyWithPlaceholder(),
    Object? proxyPrivateTabsTor = const $CopyWithPlaceholder(),
  }) {
    return GeneralSettings(
      themeMode: themeMode == const $CopyWithPlaceholder()
          ? _value.themeMode
          // ignore: cast_nullable_to_non_nullable
          : themeMode as ThemeMode,
      enableReadability: enableReadability == const $CopyWithPlaceholder()
          ? _value.enableReadability
          // ignore: cast_nullable_to_non_nullable
          : enableReadability as bool,
      enforceReadability: enforceReadability == const $CopyWithPlaceholder()
          ? _value.enforceReadability
          // ignore: cast_nullable_to_non_nullable
          : enforceReadability as bool,
      deleteBrowsingDataOnQuit:
          deleteBrowsingDataOnQuit == const $CopyWithPlaceholder()
          ? _value.deleteBrowsingDataOnQuit
          // ignore: cast_nullable_to_non_nullable
          : deleteBrowsingDataOnQuit as Set<DeleteBrowsingDataType>?,
      defaultSearchProvider:
          defaultSearchProvider == const $CopyWithPlaceholder()
          ? _value.defaultSearchProvider
          // ignore: cast_nullable_to_non_nullable
          : defaultSearchProvider as String,
      createChildTabsOption:
          createChildTabsOption == const $CopyWithPlaceholder()
          ? _value.createChildTabsOption
          // ignore: cast_nullable_to_non_nullable
          : createChildTabsOption as bool,
      proxyPrivateTabsTor: proxyPrivateTabsTor == const $CopyWithPlaceholder()
          ? _value.proxyPrivateTabsTor
          // ignore: cast_nullable_to_non_nullable
          : proxyPrivateTabsTor as bool,
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
      enforceReadability: json['enforceReadability'] as bool?,
      deleteBrowsingDataOnQuit:
          (json['deleteBrowsingDataOnQuit'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$DeleteBrowsingDataTypeEnumMap, e))
              .toSet(),
      defaultSearchProvider: json['defaultSearchProvider'] as String?,
      createChildTabsOption: json['createChildTabsOption'] as bool?,
      proxyPrivateTabsTor: json['proxyPrivateTabsTor'] as bool?,
    );

Map<String, dynamic> _$GeneralSettingsToJson(GeneralSettings instance) =>
    <String, dynamic>{
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'enableReadability': instance.enableReadability,
      'enforceReadability': instance.enforceReadability,
      'deleteBrowsingDataOnQuit': instance.deleteBrowsingDataOnQuit
          ?.map((e) => _$DeleteBrowsingDataTypeEnumMap[e]!)
          .toList(),
      'defaultSearchProvider': instance.defaultSearchProvider,
      'createChildTabsOption': instance.createChildTabsOption,
      'proxyPrivateTabsTor': instance.proxyPrivateTabsTor,
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
