// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restart_authorization_store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestartAuthorization _$RestartAuthorizationFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RestartAuthorization', json, ($checkedConvert) {
  final val = RestartAuthorization(
    tokenHash: $checkedConvert('tokenHash', (v) => requiredString(v)),
    targetProfileId: $checkedConvert(
      'targetProfileId',
      (v) => RestartAuthorization._profileId(v),
    ),
    createdAt: $checkedConvert('createdAt', (v) => requiredDateTime(v)),
    expiresAt: $checkedConvert('expiresAt', (v) => requiredDateTime(v)),
    version: $checkedConvert(
      'version',
      (v) => v == null
          ? restartAuthorizationVersion
          : RestartAuthorization._version(v),
    ),
  );
  return val;
});

Map<String, dynamic> _$RestartAuthorizationToJson(
  RestartAuthorization instance,
) => <String, dynamic>{
  'version': instance.version,
  'tokenHash': instance.tokenHash,
  'targetProfileId': instance.targetProfileId,
  'createdAt': utcIso(instance.createdAt),
  'expiresAt': utcIso(instance.expiresAt),
};
