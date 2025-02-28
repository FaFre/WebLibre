// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedArticle _$FeedArticleFromJson(Map<String, dynamic> json) => FeedArticle(
  id: json['id'] as String,
  feedId: Uri.parse(json['feedId'] as String),
  fetched: DateTime.parse(json['fetched'] as String),
  created:
      json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
  updated:
      json['updated'] == null
          ? null
          : DateTime.parse(json['updated'] as String),
  lastRead:
      json['lastRead'] == null
          ? null
          : DateTime.parse(json['lastRead'] as String),
  title: json['title'] as String?,
  authors:
      (json['authors'] as List<dynamic>?)
          ?.map((e) => FeedAuthor.fromJson(e as Map<String, dynamic>))
          .toList(),
  tags:
      (json['tags'] as List<dynamic>?)
          ?.map((e) => FeedCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
  links:
      (json['links'] as List<dynamic>?)
          ?.map((e) => FeedLink.fromJson(e as Map<String, dynamic>))
          .toList(),
  summaryMarkdown: json['summaryMarkdown'] as String?,
  summaryPlain: json['summaryPlain'] as String?,
  contentMarkdown: json['contentMarkdown'] as String?,
  contentPlain: json['contentPlain'] as String?,
);

Map<String, dynamic> _$FeedArticleToJson(FeedArticle instance) =>
    <String, dynamic>{
      'id': instance.id,
      'feedId': instance.feedId.toString(),
      'fetched': instance.fetched.toIso8601String(),
      'created': instance.created?.toIso8601String(),
      'updated': instance.updated?.toIso8601String(),
      'lastRead': instance.lastRead?.toIso8601String(),
      'title': instance.title,
      'authors': instance.authors?.map((e) => e.toJson()).toList(),
      'tags': instance.tags?.map((e) => e.toJson()).toList(),
      'links': instance.links?.map((e) => e.toJson()).toList(),
      'summaryMarkdown': instance.summaryMarkdown,
      'summaryPlain': instance.summaryPlain,
      'contentMarkdown': instance.contentMarkdown,
      'contentPlain': instance.contentPlain,
    };
