import 'package:collection/collection.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/web_feed/data/database/database.dart';
import 'package:lensai/features/web_feed/data/models/feed_article.dart';
import 'package:lensai/features/web_feed/data/models/feed_author.dart';
import 'package:lensai/features/web_feed/data/models/feed_link.dart';
import 'package:lensai/features/web_feed/extensions/atom.dart';
import 'package:lensai/features/web_feed/extensions/rss.dart';
import 'package:rss_dart/dart_rss.dart';
import 'package:rss_dart/domain/rss1_feed.dart';

class FeedParser {
  final Uri url;
  late Object _feed;

  FeedParser._(this.url, this._feed);

  factory FeedParser.parse({required Uri url, required String xmlString}) {
    final rssVersion = WebFeed.detectRssVersion(xmlString);
    final feed = switch (rssVersion) {
      RssVersion.rss1 => Rss1Feed.parse(xmlString),
      RssVersion.rss2 => RssFeed.parse(xmlString),
      RssVersion.atom => AtomFeed.parse(xmlString),
      RssVersion.unknown =>
        throw Error.safeToString(
          'Invalid XML String? We cannot detect RSS/Atom version.',
        ),
    };

    return FeedParser._(url, feed);
  }

  FeedData readGeneralData() {
    switch (_feed) {
      case final Rss1Feed feed:
        return FeedData(
          url: url,
          title: feed.title.whenNotEmpty ?? feed.dc?.title,
          description: feed.description.whenNotEmpty ?? feed.dc?.description,
          siteLink: feed.link.mapNotNull(Uri.tryParse),
          authors: feed.dc?.creator.whenNotEmpty.mapNotNull(
            (creator) => [FeedAuthor(name: creator)],
          ),
          tags: feed.dc?.toFeedCategories(),
        );
      case final RssFeed feed:
        final categories = feed.categories.toFeedCategories();

        return FeedData(
          url: url,
          title: feed.title.whenNotEmpty ?? feed.dc?.title,
          description: feed.description.whenNotEmpty ?? feed.dc?.description,
          siteLink: feed.link.mapNotNull(Uri.tryParse),
          authors: (feed.author.whenNotEmpty ?? feed.dc?.creator.whenNotEmpty)
              .mapNotNull((creator) => [FeedAuthor(name: creator)]),
          tags:
              categories.isNotEmpty ? categories : feed.dc?.toFeedCategories(),
        );
      case final AtomFeed feed:
        final authors = feed.authors.toFeedAuthors();
        final tags = feed.categories.toFeedCategories();

        return FeedData(
          url: url,
          title: feed.title.whenNotEmpty,
          icon: feed.icon.mapNotNull(Uri.tryParse),
          siteLink:
              feed.links
                  .toFeedLinks()
                  .getRelation(FeedLinkRelation.alternate)
                  ?.uri,
          description: feed.subtitle.whenNotEmpty,
          authors: authors.isNotEmpty ? authors : null,
          tags: tags,
        );
      default:
        throw Exception();
    }
  }

  Future<List<FeedArticle>> readArticles() async {
    final fetchDate = DateTime.now();

    switch (_feed) {
      case final Rss1Feed feed:
        final processedContents =
            await GeckoBrowserExtensionService.turndownHtml(
              feed.items.map((item) => item.content?.value ?? '').toList(),
            );

        final processedSummaries =
            await GeckoBrowserExtensionService.turndownHtml(
              feed.items
                  .map(
                    (item) =>
                        item.description.whenNotEmpty ??
                        item.dc?.description ??
                        '',
                  )
                  .toList(),
            );

        return feed.items.mapIndexed((i, item) {
          final title = item.title.whenNotEmpty ?? item.dc?.title.whenNotEmpty;

          final itemId = item.dc?.identifier.whenNotEmpty ?? title;
          final uniqueId =
              '${item.link.whenNotEmpty ?? feed.link.whenNotEmpty ?? url}#$itemId';
          final date = SafeParseDateTime.safeParse(item.dc?.date);
          final link = item.link.mapNotNull(Uri.tryParse);

          return FeedArticle(
            id: uniqueId,
            feedId: url,
            title: title,
            fetched: fetchDate,
            created: date,
            authors: item.dc?.creator.whenNotEmpty.mapNotNull(
              (creator) => [FeedAuthor(name: creator)],
            ),
            summaryPlain: processedSummaries[i].plain.whenNotEmpty,
            summaryMarkdown: processedSummaries[i].markdown.whenNotEmpty,
            links: link.mapNotNull((link) => [FeedLink(uri: link)]),
            tags: item.dc?.toFeedCategories(),
            contentPlain: processedContents[i].plain.trim().whenNotEmpty,
            contentMarkdown: processedContents[i].markdown?.trim().whenNotEmpty,
          );
        }).toList();
      case final RssFeed feed:
        final processedContents =
            await GeckoBrowserExtensionService.turndownHtml(
              feed.items.map((item) => item.content?.value ?? '').toList(),
            );

        final processedSummaries =
            await GeckoBrowserExtensionService.turndownHtml(
              feed.items
                  .map(
                    (item) =>
                        item.description.whenNotEmpty ??
                        item.dc?.description ??
                        '',
                  )
                  .toList(),
            );

        return feed.items.mapIndexed((i, item) {
          final title = item.title.whenNotEmpty ?? item.dc?.title.whenNotEmpty;

          final itemId =
              item.guid.whenNotEmpty ??
              item.dc?.identifier.whenNotEmpty ??
              title;

          final uniqueId =
              '${item.link.whenNotEmpty ?? feed.link.whenNotEmpty ?? url}#$itemId';
          final date = SafeParseDateTime.safeParse(
            item.pubDate.whenNotEmpty ?? item.dc?.date,
          );
          final link = item.link.mapNotNull(Uri.tryParse);
          final author =
              item.author.whenNotEmpty ?? item.dc?.creator.whenNotEmpty;

          final categories = item.categories.toFeedCategories();

          return FeedArticle(
            id: uniqueId,
            feedId: url,
            title: title,
            fetched: fetchDate,
            created: date,
            authors: author.mapNotNull(
              (creator) => [FeedAuthor(name: creator)],
            ),
            summaryPlain: processedSummaries[i].plain.whenNotEmpty,
            summaryMarkdown: processedSummaries[i].markdown.whenNotEmpty,
            links: link.mapNotNull((link) => [FeedLink(uri: link)]),
            tags:
                categories.isNotEmpty
                    ? categories
                    : item.dc?.toFeedCategories(),
            contentPlain: processedContents[i].plain.trim().whenNotEmpty,
            contentMarkdown: processedContents[i].markdown?.trim().whenNotEmpty,
          );
        }).toList();
      case final AtomFeed feed:
        final processedContents =
            await GeckoBrowserExtensionService.turndownHtml(
              feed.items.map((item) => item.content ?? '').toList(),
            );

        final processedSummaries =
            await GeckoBrowserExtensionService.turndownHtml(
              feed.items.map((item) => item.summary ?? '').toList(),
            );

        final feedLink = feed.links.toFeedLinks().getRelation(
          FeedLinkRelation.self,
        );

        return feed.items.mapIndexed((i, item) {
          final authors = item.authors.toFeedAuthors();

          final tags = item.categories.toFeedCategories();

          final itemLinks = item.links.toFeedLinks();
          final articleLink = itemLinks.getRelation(FeedLinkRelation.alternate);

          final itemId = item.id.whenNotEmpty ?? item.title;
          final uniqueId =
              '${articleLink?.uri ?? feedLink?.uri ?? url}#$itemId';

          final published = SafeParseDateTime.safeParse(item.published);
          final updated = SafeParseDateTime.safeParse(item.updated);

          return FeedArticle(
            id: uniqueId,
            feedId: url,
            title: item.title.whenNotEmpty,
            summaryPlain: processedSummaries[i].plain.whenNotEmpty,
            summaryMarkdown: processedSummaries[i].markdown.whenNotEmpty,
            links: itemLinks,
            authors: authors.isNotEmpty ? authors : null,
            tags: tags,
            fetched: fetchDate,
            created: published,
            updated: updated,
            contentPlain: processedContents[i].plain.trim().whenNotEmpty,
            contentMarkdown: processedContents[i].markdown?.trim().whenNotEmpty,
          );
        }).toList();
      default:
        throw Exception();
    }
  }
}
