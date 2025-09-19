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

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `TorSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// TorSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  TorSettings call({
    bool proxyPrivateTabsTor,
    TorConnectionConfig config,
    bool requireBridge,
    bool fetchRemoteBridges,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfTorSettings.copyWith(...)` or call `instanceOfTorSettings.copyWith.fieldName(value)` for a single field.
class _$TorSettingsCWProxyImpl implements _$TorSettingsCWProxy {
  const _$TorSettingsCWProxyImpl(this._value);

  final TorSettings _value;

  @override
  TorSettings proxyPrivateTabsTor(bool proxyPrivateTabsTor) =>
      call(proxyPrivateTabsTor: proxyPrivateTabsTor);

  @override
  TorSettings config(TorConnectionConfig config) => call(config: config);

  @override
  TorSettings requireBridge(bool requireBridge) =>
      call(requireBridge: requireBridge);

  @override
  TorSettings fetchRemoteBridges(bool fetchRemoteBridges) =>
      call(fetchRemoteBridges: fetchRemoteBridges);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `TorSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// TorSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  TorSettings call({
    Object? proxyPrivateTabsTor = const $CopyWithPlaceholder(),
    Object? config = const $CopyWithPlaceholder(),
    Object? requireBridge = const $CopyWithPlaceholder(),
    Object? fetchRemoteBridges = const $CopyWithPlaceholder(),
  }) {
    return TorSettings(
      proxyPrivateTabsTor:
          proxyPrivateTabsTor == const $CopyWithPlaceholder() ||
              proxyPrivateTabsTor == null
          ? _value.proxyPrivateTabsTor
          // ignore: cast_nullable_to_non_nullable
          : proxyPrivateTabsTor as bool,
      config: config == const $CopyWithPlaceholder() || config == null
          ? _value.config
          // ignore: cast_nullable_to_non_nullable
          : config as TorConnectionConfig,
      requireBridge:
          requireBridge == const $CopyWithPlaceholder() || requireBridge == null
          ? _value.requireBridge
          // ignore: cast_nullable_to_non_nullable
          : requireBridge as bool,
      fetchRemoteBridges:
          fetchRemoteBridges == const $CopyWithPlaceholder() ||
              fetchRemoteBridges == null
          ? _value.fetchRemoteBridges
          // ignore: cast_nullable_to_non_nullable
          : fetchRemoteBridges as bool,
    );
  }
}

extension $TorSettingsCopyWith on TorSettings {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfTorSettings.copyWith(...)` or `instanceOfTorSettings.copyWith.fieldName(...)`.
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
