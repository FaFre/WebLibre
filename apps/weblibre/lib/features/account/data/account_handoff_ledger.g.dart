// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_handoff_ledger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountHandoffRecord _$AccountHandoffRecordFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AccountHandoffRecord', json, ($checkedConvert) {
  final val = AccountHandoffRecord(
    stateHash: $checkedConvert('stateHash', (v) => requiredString(v)),
    profileId: $checkedConvert(
      'profileId',
      (v) => AccountHandoffRecord._profileId(v),
    ),
    mode: $checkedConvert('mode', (v) => AccountHandoffRecord._mode(v)),
    createdAt: $checkedConvert('createdAt', (v) => requiredDateTime(v)),
    expiresAt: $checkedConvert('expiresAt', (v) => requiredDateTime(v)),
  );
  return val;
});

Map<String, dynamic> _$AccountHandoffRecordToJson(
  AccountHandoffRecord instance,
) => <String, dynamic>{
  'stateHash': instance.stateHash,
  'profileId': instance.profileId,
  'mode': instance.mode,
  'createdAt': utcIso(instance.createdAt),
  'expiresAt': utcIso(instance.expiresAt),
};
