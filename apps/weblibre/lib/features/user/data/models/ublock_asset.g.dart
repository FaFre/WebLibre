// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ublock_asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UBlockAssetEntry _$UBlockAssetEntryFromJson(Map<String, dynamic> json) =>
    UBlockAssetEntry(
      content: json['content'] as String,
      group: $enumDecodeNullable(_$UBlockAssetGroupEnumMap, json['group']),
      group2: $enumDecodeNullable(_$UBlockAssetSubGroupEnumMap, json['group2']),
      parent: json['parent'] as String?,
      title: json['title'] as String?,
      contentURL: json['contentURL'] == null
          ? const []
          : _contentUrlFromJson(json['contentURL']),
      cdnURLs: (json['cdnURLs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      patchURLs: (json['patchURLs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      supportURL: json['supportURL'] as String?,
      instructionURL: json['instructionURL'] as String?,
      tags: json['tags'] as String?,
      lang: json['lang'] as String?,
      ua: json['ua'] as String?,
      off: json['off'] as bool? ?? false,
      preferred: json['preferred'] as bool? ?? false,
      updateAfter: (json['updateAfter'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UBlockAssetEntryToJson(UBlockAssetEntry instance) =>
    <String, dynamic>{
      'content': instance.content,
      'group': ?_$UBlockAssetGroupEnumMap[instance.group],
      'group2': ?_$UBlockAssetSubGroupEnumMap[instance.group2],
      'parent': ?instance.parent,
      'title': ?instance.title,
      'contentURL': ?_contentUrlToJson(instance.contentURL),
      'cdnURLs': ?instance.cdnURLs,
      'patchURLs': ?instance.patchURLs,
      'supportURL': ?instance.supportURL,
      'instructionURL': ?instance.instructionURL,
      'tags': ?instance.tags,
      'lang': ?instance.lang,
      'ua': ?instance.ua,
      'off': instance.off,
      'preferred': instance.preferred,
      'updateAfter': ?instance.updateAfter,
    };

const _$UBlockAssetGroupEnumMap = {
  UBlockAssetGroup.$default: 'default',
  UBlockAssetGroup.ads: 'ads',
  UBlockAssetGroup.privacy: 'privacy',
  UBlockAssetGroup.malware: 'malware',
  UBlockAssetGroup.annoyances: 'annoyances',
  UBlockAssetGroup.multipurpose: 'multipurpose',
  UBlockAssetGroup.regions: 'regions',
};

const _$UBlockAssetSubGroupEnumMap = {
  UBlockAssetSubGroup.cookies: 'cookies',
  UBlockAssetSubGroup.social: 'social',
};
