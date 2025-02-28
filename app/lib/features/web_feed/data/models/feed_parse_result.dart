import 'package:json_annotation/json_annotation.dart';
import 'package:lensai/features/web_feed/data/database/converters/feed_data.dart';
import 'package:lensai/features/web_feed/data/database/database.dart';
import 'package:lensai/features/web_feed/data/models/feed_article.dart';

part 'feed_parse_result.g.dart';

@JsonSerializable()
class FeedParseResult {
  @FeedDataConverter()
  final FeedData feedData;
  final List<FeedArticle> articleData;

  FeedParseResult({required this.feedData, required this.articleData});

  factory FeedParseResult.fromJson(Map<String, dynamic> json) =>
      _$FeedParseResultFromJson(json);

  Map<String, dynamic> toJson() => _$FeedParseResultToJson(this);
}
