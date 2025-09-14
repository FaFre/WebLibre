// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tor_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TorSettingsCWProxy {
  TorSettings proxyPrivateTabsTor(bool proxyPrivateTabsTor);

  TorSettings config(TorConnectionConfig config);

  TorSettings requireBridge(bool requireBridge);

  TorSettings fetchRemoteBridges(bool fetchRemoteBridges);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TorSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TorSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  TorSettings call({
    bool proxyPrivateTabsTor,
    TorConnectionConfig config,
    bool requireBridge,
    bool fetchRemoteBridges,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTorSettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTorSettings.copyWith.fieldName(...)`
class _$TorSettingsCWProxyImpl implements _$TorSettingsCWProxy {
  const _$TorSettingsCWProxyImpl(this._value);

  final TorSettings _value;

  @override
  TorSettings proxyPrivateTabsTor(bool proxyPrivateTabsTor) =>
      this(proxyPrivateTabsTor: proxyPrivateTabsTor);

  @override
  TorSettings config(TorConnectionConfig config) => this(config: config);

  @override
  TorSettings requireBridge(bool requireBridge) =>
      this(requireBridge: requireBridge);

  @override
  TorSettings fetchRemoteBridges(bool fetchRemoteBridges) =>
      this(fetchRemoteBridges: fetchRemoteBridges);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TorSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TorSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  TorSettings call({
    Object? proxyPrivateTabsTor = const $CopyWithPlaceholder(),
    Object? config = const $CopyWithPlaceholder(),
    Object? requireBridge = const $CopyWithPlaceholder(),
    Object? fetchRemoteBridges = const $CopyWithPlaceholder(),
  }) {
    return TorSettings(
      proxyPrivateTabsTor: proxyPrivateTabsTor == const $CopyWithPlaceholder()
          ? _value.proxyPrivateTabsTor
          // ignore: cast_nullable_to_non_nullable
          : proxyPrivateTabsTor as bool,
      config: config == const $CopyWithPlaceholder()
          ? _value.config
          // ignore: cast_nullable_to_non_nullable
          : config as TorConnectionConfig,
      requireBridge: requireBridge == const $CopyWithPlaceholder()
          ? _value.requireBridge
          // ignore: cast_nullable_to_non_nullable
          : requireBridge as bool,
      fetchRemoteBridges: fetchRemoteBridges == const $CopyWithPlaceholder()
          ? _value.fetchRemoteBridges
          // ignore: cast_nullable_to_non_nullable
          : fetchRemoteBridges as bool,
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
      config: $enumDecodeNullable(_$TorConnectionConfigEnumMap, json['config']),
      requireBridge: json['requireBridge'] as bool?,
      fetchRemoteBridges: json['fetchRemoteBridges'] as bool?,
    );

Map<String, dynamic> _$TorSettingsToJson(TorSettings instance) =>
    <String, dynamic>{
      'proxyPrivateTabsTor': instance.proxyPrivateTabsTor,
      'config': _$TorConnectionConfigEnumMap[instance.config]!,
      'requireBridge': instance.requireBridge,
      'fetchRemoteBridges': instance.fetchRemoteBridges,
    };

const _$TorConnectionConfigEnumMap = {
  TorConnectionConfig.auto: 'auto',
  TorConnectionConfig.direct: 'direct',
  TorConnectionConfig.obfs4: 'obfs4',
  TorConnectionConfig.snowflake: 'snowflake',
};
