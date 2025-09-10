// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tor_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TorSettingsCWProxy {
  TorSettings proxyPrivateTabsTor(bool proxyPrivateTabsTor);

  TorSettings autoConfig(bool autoConfig);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TorSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TorSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  TorSettings call({bool proxyPrivateTabsTor, bool autoConfig});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTorSettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTorSettings.copyWith.fieldName(...)`
class _$TorSettingsCWProxyImpl implements _$TorSettingsCWProxy {
  const _$TorSettingsCWProxyImpl(this._value);

  final TorSettings _value;

  @override
  TorSettings proxyPrivateTabsTor(bool proxyPrivateTabsTor) =>
      this(proxyPrivateTabsTor: proxyPrivateTabsTor);

  @override
  TorSettings autoConfig(bool autoConfig) => this(autoConfig: autoConfig);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TorSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TorSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  TorSettings call({
    Object? proxyPrivateTabsTor = const $CopyWithPlaceholder(),
    Object? autoConfig = const $CopyWithPlaceholder(),
  }) {
    return TorSettings(
      proxyPrivateTabsTor: proxyPrivateTabsTor == const $CopyWithPlaceholder()
          ? _value.proxyPrivateTabsTor
          // ignore: cast_nullable_to_non_nullable
          : proxyPrivateTabsTor as bool,
      autoConfig: autoConfig == const $CopyWithPlaceholder()
          ? _value.autoConfig
          // ignore: cast_nullable_to_non_nullable
          : autoConfig as bool,
    );
  }
}

extension $TorSettingsCopyWith on TorSettings {
  /// Returns a callable class that can be used as follows: `instanceOfTorSettings.copyWith(...)` or like so:`instanceOfTorSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TorSettingsCWProxy get copyWith => _$TorSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TorSettings _$TorSettingsFromJson(Map<String, dynamic> json) =>
    TorSettings.withDefaults(
      proxyPrivateTabsTor: json['proxyPrivateTabsTor'] as bool?,
      autoConfig: json['autoConfig'] as bool?,
    );

Map<String, dynamic> _$TorSettingsToJson(TorSettings instance) =>
    <String, dynamic>{
      'proxyPrivateTabsTor': instance.proxyPrivateTabsTor,
      'autoConfig': instance.autoConfig,
    };
