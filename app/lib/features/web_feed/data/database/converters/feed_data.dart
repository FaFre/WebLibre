import 'package:json_annotation/json_annotation.dart';
import 'package:lensai/features/web_feed/data/database/database.dart';

class FeedDataConverter extends JsonConverter<FeedData, Map<String, dynamic>> {
  const FeedDataConverter();

  @override
  FeedData fromJson(Map<String, dynamic> json) {
    return FeedData.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(FeedData object) {
    return object.toJson();
  }
}
