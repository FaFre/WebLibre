import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'feed_category.g.dart';

@JsonSerializable()
class FeedCategory with FastEquatable {
  final String id;
  final String? title;

  FeedCategory({required this.id, this.title});

  factory FeedCategory.fromJson(Map<String, dynamic> json) =>
      _$FeedCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$FeedCategoryToJson(this);

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [id, title];
}
