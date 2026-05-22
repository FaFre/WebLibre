// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_sync_envelope.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsSyncPayload _$SettingsSyncPayloadFromJson(Map<String, dynamic> json) =>
    SettingsSyncPayload(
      general: json['general'] == null
          ? null
          : GeneralSettings.fromJson(json['general'] as Map<String, dynamic>),
      engine: json['engine'] == null
          ? null
          : EngineSettings.fromJson(json['engine'] as Map<String, dynamic>),
      tor: json['tor'] == null
          ? null
          : TorSettings.fromJson(json['tor'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SettingsSyncPayloadToJson(
  SettingsSyncPayload instance,
) => <String, dynamic>{
  'general': instance.general?.toJson(),
  'engine': instance.engine?.toJson(),
  'tor': instance.tor?.toJson(),
};

SettingsSyncEnvelope _$SettingsSyncEnvelopeFromJson(
  Map<String, dynamic> json,
) => SettingsSyncEnvelope(
  schemaVersion: (json['schema_version'] as num).toInt(),
  exportedAt: json['exported_at'] as String,
  payload: SettingsSyncPayload.fromJson(
    json['payload'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$SettingsSyncEnvelopeToJson(
  SettingsSyncEnvelope instance,
) => <String, dynamic>{
  'schema_version': instance.schemaVersion,
  'exported_at': instance.exportedAt,
  'payload': instance.payload.toJson(),
};
