// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rfp_target.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RFPTarget _$RFPTargetFromJson(Map<String, dynamic> json) => RFPTarget(
  name: json['name'] as String,
  id: (json['id'] as num).toInt(),
  description: json['description'] as String?,
  keywords: (json['keywords'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$RFPTargetToJson(RFPTarget instance) => <String, dynamic>{
  'name': instance.name,
  'id': instance.id,
  'description': instance.description,
  'keywords': instance.keywords,
};
