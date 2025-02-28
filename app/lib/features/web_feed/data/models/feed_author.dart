import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'feed_author.g.dart';

@JsonSerializable()
class FeedAuthor with FastEquatable {
  final String? name;
  final String? email;

  FeedAuthor({this.name, this.email});

  factory FeedAuthor.fromJson(Map<String, dynamic> json) =>
      _$FeedAuthorFromJson(json);

  Map<String, dynamic> toJson() => _$FeedAuthorToJson(this);

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [name, email];
}
