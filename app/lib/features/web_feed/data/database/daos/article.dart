import 'package:drift/drift.dart';
import 'package:lensai/features/web_feed/data/database/database.dart';
import 'package:lensai/features/web_feed/data/models/feed_article.dart';
import 'package:lensai/features/web_feed/data/models/feed_article_query_result.dart';

part 'article.g.dart';

@DriftAccessor()
class ArticleDao extends DatabaseAccessor<FeedDatabase> with _$ArticleDaoMixin {
  ArticleDao(super.attachedDatabase);

  Selectable<FeedArticle> getFeedArticles(Uri? url) {
    final select = db.articleView.select();

    if (url != null) {
      select.where((article) => article.feedId.equalsValue(url));
    }

    return select..orderBy([
      (row) => OrderingTerm(
        expression: coalesce([row.updated, row.created]),
        mode: OrderingMode.desc,
      ),
    ]);
  }

  SingleOrNullSelectable<FeedArticle> getArticleById(String articleId) {
    return db.articleView.select()..where((row) => row.id.equals(articleId));
  }

  Future<void> upsertArticles(List<FeedArticle> articles) {
    return db.transaction(() async {
      await Future.wait(
        articles
            .map(
              (article) => db.article.insertOne(
                article,
                onConflict: DoUpdate(
                  (old) {
                    return ArticleCompanion(
                      authors: Value(article.authors),
                      contentMarkdown: Value(article.contentMarkdown),
                      contentPlain: Value(article.contentPlain),
                      links: Value(article.links),
                      summaryMarkdown: Value(article.summaryMarkdown),
                      summaryPlain: Value(article.summaryPlain),
                      tags: Value(article.tags),
                      title: Value(article.title),
                      updated: Value(article.updated),
                    );
                  },
                  where:
                      (old) =>
                          old.updated.isNotNull() &
                          old.updated.isSmallerThanValue(
                            article.updated ?? DateTime(0),
                          ),
                ),
              ),
            )
            .toList(),
      );
    });
  }

  Future<int> updateArticleRead(String articleId, DateTime? read) {
    final statement =
        db.article.update()..where((article) => article.id.equals(articleId));

    return statement.write(ArticleCompanion(lastRead: Value(read)));
  }

  Selectable<(String, int)> getUnreadArticleCount() {
    final count = countAll();

    final countByFeed =
        db.article.selectOnly()
          ..addColumns([db.article.feedId, count])
          ..where(
            db.article.lastRead.isNull() |
                (db.article.updated.isNotNull() &
                    db.article.lastRead.isSmallerThan(db.article.lastRead)),
          )
          ..groupBy([db.article.feedId]);

    return countByFeed.map(
      (result) => (result.read(db.article.feedId)!, result.read(count)!),
    );
  }

  Selectable<FeedArticleQueryResult> queryArticles({
    required String matchPrefix,
    required String matchSuffix,
    required String ellipsis,
    required int snippetLength,
    required String searchString,
    required Uri? feedId,
  }) {
    final ftsQuery = db.buildFtsQuery(searchString);

    if (ftsQuery.isNotEmpty) {
      return db.queryArticlesFullContent(
        feedId: feedId?.toString(),
        query: ftsQuery,
        snippetLength: snippetLength,
        beforeMatch: matchPrefix,
        afterMatch: matchSuffix,
        ellipsis: ellipsis,
      );
    } else {
      return db.queryArticlesBasic(
        feedId: feedId?.toString(),
        query: db.buildLikeQuery(searchString),
      );
    }
  }
}
