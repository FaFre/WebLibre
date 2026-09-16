// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_chord.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeyChord _$KeyChordFromJson(Map<String, dynamic> json) => KeyChord(
  (json['keyId'] as num).toInt(),
  control: json['control'] as bool? ?? false,
  alt: json['alt'] as bool? ?? false,
  shift: json['shift'] as bool? ?? false,
  meta: json['meta'] as bool? ?? false,
);

Map<String, dynamic> _$KeyChordToJson(KeyChord instance) => <String, dynamic>{
  'keyId': instance.keyId,
  'control': instance.control,
  'alt': instance.alt,
  'shift': instance.shift,
  'meta': instance.meta,
};
