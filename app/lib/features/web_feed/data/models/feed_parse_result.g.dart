// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_parse_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedParseResult _$FeedParseResultFromJson(Map<String, dynamic> json) =>
    FeedParseResult(
      feedData: const FeedDataConverter().fromJson(
        json['feedData'] as Map<String, dynamic>,
      ),
      articleData:
          (json['articleData'] as List<dynamic>)
              .map((e) => FeedArticle.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$FeedParseResultToJson(FeedParseResult instance) =>
    <String, dynamic>{
      'feedData': const FeedDataConverter().toJson(instance.feedData),
      'articleData': instance.articleData.map((e) => e.toJson()).toList(),
    };
