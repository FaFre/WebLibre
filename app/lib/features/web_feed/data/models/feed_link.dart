import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'feed_link.g.dart';

enum FeedLinkRelation {
  ///an alternate representation of the entry or feed, for example a permalink to the html version of the entry, or the front page of the weblog.
  alternate,

  ///a related resource which is potentially large in size and might require special handling, for example an audio or video recording.
  enclosure,

  ///an document related to the entry or feed.
  related,

  ///the feed itself.
  self,

  ///the source of the information provided in the entry.
  via,
}

@JsonSerializable()
class FeedLink with FastEquatable {
  final Uri uri;
  final FeedLinkRelation? relation;
  final String? title;

  FeedLink({required this.uri, this.relation, this.title});

  factory FeedLink.fromJson(Map<String, dynamic> json) =>
      _$FeedLinkFromJson(json);

  Map<String, dynamic> toJson() => _$FeedLinkToJson(this);

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [uri, relation, title];
}
