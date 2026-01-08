// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tor_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TorSettingsCWProxy {
  TorSettings proxyRegularTabsMode(TorRegularTabProxyMode proxyRegularTabsMode);

  TorSettings proxyPrivateTabsTor(bool proxyPrivateTabsTor);

  TorSettings config(TorConnectionConfig config);

  TorSettings requireBridge(bool requireBridge);

  TorSettings fetchRemoteBridges(bool fetchRemoteBridges);

  TorSettings entryNodeCountry(String? entryNodeCountry);

  TorSettings exitNodeCountry(String? exitNodeCountry);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `TorSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// TorSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  TorSettings call({
    TorRegularTabProxyMode proxyRegularTabsMode,
    bool proxyPrivateTabsTor,
    TorConnectionConfig config,
    bool requireBridge,
    bool fetchRemoteBridges,
    String? entryNodeCountry,
    String? exitNodeCountry,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfTorSettings.copyWith(...)` or call `instanceOfTorSettings.copyWith.fieldName(value)` for a single field.
class _$TorSettingsCWProxyImpl implements _$TorSettingsCWProxy {
  const _$TorSettingsCWProxyImpl(this._value);

  final TorSettings _value;

  @override
  TorSettings proxyRegularTabsMode(
    TorRegularTabProxyMode proxyRegularTabsMode,
  ) => call(proxyRegularTabsMode: proxyRegularTabsMode);

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
  TorSettings entryNodeCountry(String? entryNodeCountry) =>
      call(entryNodeCountry: entryNodeCountry);

  @override
  TorSettings exitNodeCountry(String? exitNodeCountry) =>
      call(exitNodeCountry: exitNodeCountry);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `TorSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// TorSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  TorSettings call({
    Object? proxyRegularTabsMode = const $CopyWithPlaceholder(),
    Object? proxyPrivateTabsTor = const $CopyWithPlaceholder(),
    Object? config = const $CopyWithPlaceholder(),
    Object? requireBridge = const $CopyWithPlaceholder(),
    Object? fetchRemoteBridges = const $CopyWithPlaceholder(),
    Object? entryNodeCountry = const $CopyWithPlaceholder(),
    Object? exitNodeCountry = const $CopyWithPlaceholder(),
  }) {
    return TorSettings(
      proxyRegularTabsMode:
          proxyRegularTabsMode == const $CopyWithPlaceholder() ||
              proxyRegularTabsMode == null
          ? _value.proxyRegularTabsMode
          // ignore: cast_nullable_to_non_nullable
          : proxyRegularTabsMode as TorRegularTabProxyMode,
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
      entryNodeCountry: entryNodeCountry == const $CopyWithPlaceholder()
          ? _value.entryNodeCountry
          // ignore: cast_nullable_to_non_nullable
          : entryNodeCountry as String?,
      exitNodeCountry: exitNodeCountry == const $CopyWithPlaceholder()
          ? _value.exitNodeCountry
          // ignore: cast_nullable_to_non_nullable
          : exitNodeCountry as String?,
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
      proxyRegularTabsMode: $enumDecodeNullable(
        _$TorRegularTabProxyModeEnumMap,
        json['proxyRegularTabsMode'],
      ),
      proxyPrivateTabsTor: json['proxyPrivateTabsTor'] as bool?,
      config: $enumDecodeNullable(_$TorConnectionConfigEnumMap, json['config']),
      requireBridge: json['requireBridge'] as bool?,
      fetchRemoteBridges: json['fetchRemoteBridges'] as bool?,
      entryNodeCountry: json['entryNodeCountry'] as String?,
      exitNodeCountry: json['exitNodeCountry'] as String?,
    );

Map<String, dynamic> _$TorSettingsToJson(TorSettings instance) =>
    <String, dynamic>{
      'proxyRegularTabsMode':
          _$TorRegularTabProxyModeEnumMap[instance.proxyRegularTabsMode]!,
      'proxyPrivateTabsTor': instance.proxyPrivateTabsTor,
      'config': _$TorConnectionConfigEnumMap[instance.config]!,
      'requireBridge': instance.requireBridge,
      'fetchRemoteBridges': instance.fetchRemoteBridges,
      'entryNodeCountry': instance.entryNodeCountry,
      'exitNodeCountry': instance.exitNodeCountry,
    };

const _$TorRegularTabProxyModeEnumMap = {
  TorRegularTabProxyMode.container: 'container',
  TorRegularTabProxyMode.all: 'all',
};

const _$TorConnectionConfigEnumMap = {
  TorConnectionConfig.auto: 'auto',
  TorConnectionConfig.direct: 'direct',
  TorConnectionConfig.obfs4: 'obfs4',
  TorConnectionConfig.snowflake: 'snowflake',
};
