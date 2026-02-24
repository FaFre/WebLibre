// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unshorten_response_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnshortenResponseData _$UnshortenResponseDataFromJson(
  Map<String, dynamic> json,
) => UnshortenResponseData(
  success: json['success'] as bool? ?? false,
  error: json['error'] as String?,
  unshortenedUrl: json['unshortened_url'] as String?,
  resolvedUrl: json['resolved_url'] as String?,
  remainingCalls: _toInt(json['remaining_calls']),
  usageCount: _toInt(json['usage_count']),
);

Map<String, dynamic> _$UnshortenResponseDataToJson(
  UnshortenResponseData instance,
) => <String, dynamic>{
  'success': instance.success,
  'error': instance.error,
  'unshortened_url': instance.unshortenedUrl,
  'resolved_url': instance.resolvedUrl,
  'remaining_calls': instance.remainingCalls,
  'usage_count': instance.usageCount,
};
