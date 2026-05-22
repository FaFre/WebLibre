// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_routing_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProxyRoutingSettingsCWProxy {
  ProxyRoutingSettings regularTabsMode(
    ProxyRegularTabRoutingMode regularTabsMode,
  );

  ProxyRoutingSettings regularTabsProxyConnectionId(
    ProxyConnectionId? regularTabsProxyConnectionId,
  );

  ProxyRoutingSettings privateTabsProxyConnectionId(
    ProxyConnectionId? privateTabsProxyConnectionId,
  );

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ProxyRoutingSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ProxyRoutingSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  ProxyRoutingSettings call({
    ProxyRegularTabRoutingMode regularTabsMode,
    ProxyConnectionId? regularTabsProxyConnectionId,
    ProxyConnectionId? privateTabsProxyConnectionId,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfProxyRoutingSettings.copyWith(...)` or call `instanceOfProxyRoutingSettings.copyWith.fieldName(value)` for a single field.
class _$ProxyRoutingSettingsCWProxyImpl
    implements _$ProxyRoutingSettingsCWProxy {
  const _$ProxyRoutingSettingsCWProxyImpl(this._value);

  final ProxyRoutingSettings _value;

  @override
  ProxyRoutingSettings regularTabsMode(
    ProxyRegularTabRoutingMode regularTabsMode,
  ) => call(regularTabsMode: regularTabsMode);

  @override
  ProxyRoutingSettings regularTabsProxyConnectionId(
    ProxyConnectionId? regularTabsProxyConnectionId,
  ) => call(regularTabsProxyConnectionId: regularTabsProxyConnectionId);

  @override
  ProxyRoutingSettings privateTabsProxyConnectionId(
    ProxyConnectionId? privateTabsProxyConnectionId,
  ) => call(privateTabsProxyConnectionId: privateTabsProxyConnectionId);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `ProxyRoutingSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ProxyRoutingSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  ProxyRoutingSettings call({
    Object? regularTabsMode = const $CopyWithPlaceholder(),
    Object? regularTabsProxyConnectionId = const $CopyWithPlaceholder(),
    Object? privateTabsProxyConnectionId = const $CopyWithPlaceholder(),
  }) {
    return ProxyRoutingSettings(
      regularTabsMode:
          regularTabsMode == const $CopyWithPlaceholder() ||
              regularTabsMode == null
          ? _value.regularTabsMode
          // ignore: cast_nullable_to_non_nullable
          : regularTabsMode as ProxyRegularTabRoutingMode,
      regularTabsProxyConnectionId:
          regularTabsProxyConnectionId == const $CopyWithPlaceholder()
          ? _value.regularTabsProxyConnectionId
          // ignore: cast_nullable_to_non_nullable
          : regularTabsProxyConnectionId as ProxyConnectionId?,
      privateTabsProxyConnectionId:
          privateTabsProxyConnectionId == const $CopyWithPlaceholder()
          ? _value.privateTabsProxyConnectionId
          // ignore: cast_nullable_to_non_nullable
          : privateTabsProxyConnectionId as ProxyConnectionId?,
    );
  }
}

extension $ProxyRoutingSettingsCopyWith on ProxyRoutingSettings {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfProxyRoutingSettings.copyWith(...)` or `instanceOfProxyRoutingSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProxyRoutingSettingsCWProxy get copyWith =>
      _$ProxyRoutingSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProxyRoutingSettings _$ProxyRoutingSettingsFromJson(
  Map<String, dynamic> json,
) => ProxyRoutingSettings.withDefaults(
  regularTabsMode: $enumDecodeNullable(
    _$ProxyRegularTabRoutingModeEnumMap,
    json['regularTabsMode'],
  ),
  regularTabsProxyConnectionId: _proxyConnectionIdFromJson(
    json['regularTabsProxyConnectionId'] as String?,
  ),
  privateTabsProxyConnectionId: _proxyConnectionIdFromJson(
    json['privateTabsProxyConnectionId'] as String?,
  ),
);

Map<String, dynamic> _$ProxyRoutingSettingsToJson(
  ProxyRoutingSettings instance,
) => <String, dynamic>{
  'regularTabsMode':
      _$ProxyRegularTabRoutingModeEnumMap[instance.regularTabsMode]!,
  'regularTabsProxyConnectionId': _proxyConnectionIdToJson(
    instance.regularTabsProxyConnectionId,
  ),
  'privateTabsProxyConnectionId': _proxyConnectionIdToJson(
    instance.privateTabsProxyConnectionId,
  ),
};

const _$ProxyRegularTabRoutingModeEnumMap = {
  ProxyRegularTabRoutingMode.container: 'container',
  ProxyRegularTabRoutingMode.all: 'all',
};
