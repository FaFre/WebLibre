import 'package:drift/drift.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lensai/features/web_feed/data/database/database.dart';
import 'package:lensai/features/web_feed/data/models/feed_author.dart';
import 'package:lensai/features/web_feed/data/models/feed_category.dart';
import 'package:lensai/features/web_feed/data/models/feed_link.dart';

part 'feed_article.g.dart';

@JsonSerializable()
class FeedArticle with FastEquatable implements Insertable<FeedArticle> {
  final String id;
  final Uri feedId;
  final DateTime fetched;
  final DateTime? created;
  final DateTime? updated;
  final DateTime? lastRead;
  final String? title;
  final List<FeedAuthor>? authors;
  final List<FeedCategory>? tags;
  final List<FeedLink>? links;
  final String? summaryMarkdown;
  final String? summaryPlain;
  final String? contentMarkdown;
  final String? contentPlain;

  FeedArticle({
    required this.id,
    required this.feedId,
    required this.fetched,
    this.created,
    this.updated,
    this.lastRead,
    this.title,
    this.authors,
    this.tags,
    this.links,
    this.summaryMarkdown,
    this.summaryPlain,
    this.contentMarkdown,
    this.contentPlain,
  });

  factory FeedArticle.fromJson(Map<String, dynamic> json) =>
      _$FeedArticleFromJson(json);

  Map<String, dynamic> toJson() => _$FeedArticleToJson(this);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['feed_id'] = Variable<String>(Article.$converterfeedId.toSql(feedId));
    }
    map['fetched'] = Variable<DateTime>(fetched);
    if (!nullToAbsent || created != null) {
      map['created'] = Variable<DateTime>(created);
    }
    if (!nullToAbsent || updated != null) {
      map['updated'] = Variable<DateTime>(updated);
    }
    if (!nullToAbsent || lastRead != null) {
      map['last_read'] = Variable<DateTime>(lastRead);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || authors != null) {
      map['authors'] = Variable<String>(
        Article.$converterauthorsn.toSql(authors),
      );
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(Article.$convertertagsn.toSql(tags));
    }
    if (!nullToAbsent || links != null) {
      map['links'] = Variable<String>(Article.$converterlinksn.toSql(links));
    }
    if (!nullToAbsent || summaryMarkdown != null) {
      map['summaryMarkdown'] = Variable<String>(summaryMarkdown);
    }
    if (!nullToAbsent || summaryPlain != null) {
      map['summaryPlain'] = Variable<String>(summaryPlain);
    }
    if (!nullToAbsent || contentMarkdown != null) {
      map['contentMarkdown'] = Variable<String>(contentMarkdown);
    }
    if (!nullToAbsent || contentPlain != null) {
      map['contentPlain'] = Variable<String>(contentPlain);
    }
    return map;
  }

  @override
  List<Object?> get hashParameters => [
    id,
    feedId,
    fetched,
    created,
    updated,
    lastRead,
    title,
    authors,
    tags,
    links,
    summaryMarkdown,
    summaryPlain,
    contentMarkdown,
    contentPlain,
  ];
}
