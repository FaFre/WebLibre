import 'package:drift/drift.dart';
import 'package:weblibre/data/database/converters/uri.dart';
import 'package:weblibre/features/search/domain/fts_tokenizer.dart';
import 'package:weblibre/features/web_feed/data/database/converters/feed_authors.dart';
import 'package:weblibre/features/web_feed/data/database/converters/feed_categories.dart';
import 'package:weblibre/features/web_feed/data/database/converters/feed_links.dart';
import 'package:weblibre/features/web_feed/data/database/daos/article.dart';
import 'package:weblibre/features/web_feed/data/database/daos/feed.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article_query_result.dart';
import 'package:weblibre/features/web_feed/data/models/feed_author.dart';
import 'package:weblibre/features/web_feed/data/models/feed_category.dart';
import 'package:weblibre/features/web_feed/data/models/feed_link.dart';

part 'database.g.dart';

@DriftDatabase(include: {'database.drift'}, daos: [ArticleDao, FeedDao])
class FeedDatabase extends _$FeedDatabase with TrigramQueryBuilderMixin {
  @override
  final int schemaVersion = 1;

  @override
  final int ftsTokenLimit = 10;
  @override
  final int ftsMinTokenLength = 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
      await optimizeFtsIndex();
    },
  );

  FeedDatabase(super.e);
}
