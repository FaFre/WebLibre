// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedLink _$FeedLinkFromJson(Map<String, dynamic> json) => FeedLink(
  uri: Uri.parse(json['uri'] as String),
  relation: $enumDecodeNullable(_$FeedLinkRelationEnumMap, json['relation']),
  title: json['title'] as String?,
);

Map<String, dynamic> _$FeedLinkToJson(FeedLink instance) => <String, dynamic>{
  'uri': instance.uri.toString(),
  'relation': _$FeedLinkRelationEnumMap[instance.relation],
  'title': instance.title,
};

const _$FeedLinkRelationEnumMap = {
  FeedLinkRelation.alternate: 'alternate',
  FeedLinkRelation.enclosure: 'enclosure',
  FeedLinkRelation.related: 'related',
  FeedLinkRelation.self: 'self',
  FeedLinkRelation.via: 'via',
};
