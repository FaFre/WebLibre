// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsRequest _$SettingsRequestFromJson(Map<String, dynamic> json) =>
    SettingsRequest(
      country: json['country'] as String?,
      transports: json['transports'] == null
          ? const [
              TransportType.obfs4,
              TransportType.snowflake,
              TransportType.webtunnel,
            ]
          : SettingsRequest._transportsFromJson(json['transports'] as List),
    );

Map<String, dynamic> _$SettingsRequestToJson(SettingsRequest instance) =>
    <String, dynamic>{
      'country': instance.country,
      'transports': SettingsRequest._transportsToJson(instance.transports),
    };

SettingsResponse _$SettingsResponseFromJson(Map<String, dynamic> json) =>
    SettingsResponse(
      settings: (json['settings'] as List<dynamic>?)
          ?.map((e) => Setting.fromJson(e as Map<String, dynamic>))
          .toList(),
      country: json['country'] as String?,
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => MoatError.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SettingsResponseToJson(SettingsResponse instance) =>
    <String, dynamic>{
      'settings': instance.settings,
      'country': instance.country,
      'errors': instance.errors,
    };

Setting _$SettingFromJson(Map<String, dynamic> json) =>
    Setting(bridge: Bridge.fromJson(json['bridges'] as Map<String, dynamic>));

Map<String, dynamic> _$SettingToJson(Setting instance) => <String, dynamic>{
  'bridges': instance.bridge,
};

Bridge _$BridgeFromJson(Map<String, dynamic> json) => Bridge(
  type: Bridge._transportFromJson(json['type']),
  source: json['source'] as String,
  bridges: (json['bridge_strings'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$BridgeToJson(Bridge instance) => <String, dynamic>{
  'type': Bridge._transportToJson(instance.type),
  'source': instance.source,
  'bridge_strings': instance.bridges,
};

MoatError _$MoatErrorFromJson(Map<String, dynamic> json) => MoatError(
  id: json['id'] as String?,
  type: json['type'] as String?,
  version: json['version'] as String?,
  code: (json['code'] as num?)?.toInt(),
  status: json['status'] as String?,
  detail: json['detail'] as String?,
);

Map<String, dynamic> _$MoatErrorToJson(MoatError instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'version': instance.version,
  'code': instance.code,
  'status': instance.status,
  'detail': instance.detail,
};

BuiltInBridges _$BuiltInBridgesFromJson(Map<String, dynamic> json) =>
    BuiltInBridges(
      meek: (json['meek'] as List<dynamic>).map((e) => e as String).toList(),
      meekAzure: (json['meek-azure'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      obfs4: (json['obfs4'] as List<dynamic>).map((e) => e as String).toList(),
      snowflake: (json['snowflake'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$BuiltInBridgesToJson(BuiltInBridges instance) =>
    <String, dynamic>{
      'meek': instance.meek,
      'meek-azure': instance.meekAzure,
      'obfs4': instance.obfs4,
      'snowflake': instance.snowflake,
    };
