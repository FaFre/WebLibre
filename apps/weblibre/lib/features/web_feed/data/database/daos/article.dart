/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:drift/drift.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/web_feed/data/database/daos/article.drift.dart';
import 'package:weblibre/features/web_feed/data/database/database.dart';
import 'package:weblibre/features/web_feed/data/database/definitions.drift.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article_query_result.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article_summary.dart';

/// An article's HTML, as read for conversion to markdown and plain text.
typedef ArticleHtml = ({String id, String? contentHtml, String? summaryHtml});

/// What one HTML field of an article converted to.
typedef ConvertedText = ({String markdown, String plain});

/// The conversion of an article read as [source]. A `null` field was not
/// converted.
typedef ProcessedArticle = ({
  ArticleHtml source,
  ConvertedText? content,
  ConvertedText? summary,
});

@DriftAccessor()
class ArticleDao extends DatabaseAccessor<FeedDatabase> with $ArticleDaoMixin {
  ArticleDao(super.attachedDatabase);

  /// The feed's articles, newest first — without their bodies. See
  /// `article_list_view`.
  Selectable<FeedArticleListEntry> getFeedArticles(Uri? url) {
    final select = db.articleListView.select();

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

  /// Whether [article] holds HTML whose markdown or plain text is missing.
  static Expression<bool> _isUnprocessed(Article article) =>
      (article.contentHtml.isNotNull() &
          (article.contentMarkdown.isNull() | article.contentPlain.isNull())) |
      (article.summaryHtml.isNotNull() &
          (article.summaryMarkdown.isNull() | article.summaryPlain.isNull()));

  /// The ids of the articles whose HTML still awaits conversion. Reads no
  /// article body, so it is cheap to watch for work.
  Selectable<String> getUnprocessedArticleIds() {
    final query = selectOnly(db.article)
      ..addColumns([db.article.id])
      ..where(_isUnprocessed(db.article));

    return query.map((row) => row.read(db.article.id)!);
  }

  /// The HTML of up to [limit] articles awaiting conversion, newest first,
  /// leaving out [excluding] and, when given, keeping to [among].
  Selectable<ArticleHtml> getUnprocessedArticles({
    required int limit,
    Iterable<String> excluding = const [],
    Iterable<String>? among,
  }) {
    var filter = _isUnprocessed(db.article) & db.article.id.isNotIn(excluding);
    if (among != null) {
      filter &= db.article.id.isIn(among);
    }

    final query = selectOnly(db.article)
      ..addColumns([
        db.article.id,
        db.article.contentHtml,
        db.article.summaryHtml,
      ])
      ..where(filter)
      ..orderBy([
        OrderingTerm(
          expression: coalesce([db.article.updated, db.article.created]),
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(limit);

    return query.map(
      (row) => (
        id: row.read(db.article.id)!,
        contentHtml: row.read(db.article.contentHtml),
        summaryHtml: row.read(db.article.summaryHtml),
      ),
    );
  }

  SingleOrNullSelectable<FeedArticle> getArticleById(String articleId) {
    return db.articleView.select()..where((row) => row.id.equals(articleId));
  }

  /// Stores what the HTML of [articles] converted to — for each article whose
  /// HTML is still the HTML that was converted.
  ///
  /// A feed refresh can replace an article's HTML while it is being converted.
  /// Writing the old text then would leave the new HTML marked converted with
  /// text that does not match it; skipped, the article stays unprocessed and
  /// is converted again. A field converted to `null` is left as it is.
  Future<void> writeProcessedArticles(List<ProcessedArticle> articles) {
    return batch((batch) {
      for (final (:source, :content, :summary) in articles) {
        if (content == null && summary == null) {
          continue;
        }

        batch.update(
          db.article,
          ArticleCompanion(
            contentMarkdown:
                content.mapNotNull((c) => Value(c.markdown)) ??
                const Value.absent(),
            contentPlain:
                content.mapNotNull((c) => Value(c.plain)) ??
                const Value.absent(),
            summaryMarkdown:
                summary.mapNotNull((s) => Value(s.markdown)) ??
                const Value.absent(),
            summaryPlain:
                summary.mapNotNull((s) => Value(s.plain)) ??
                const Value.absent(),
          ),
          where: (article) =>
              article.id.equals(source.id) &
              article.contentHtml.equalsNullable(source.contentHtml) &
              article.summaryHtml.equalsNullable(source.summaryHtml),
        );
      }
    });
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
                      contentHtml: Value(article.contentHtml),
                      contentMarkdown: Value(article.contentMarkdown),
                      contentPlain: Value(article.contentPlain),
                      links: Value(article.links),
                      summaryHtml: Value(article.summaryHtml),
                      summaryMarkdown: Value(article.summaryMarkdown),
                      summaryPlain: Value(article.summaryPlain),
                      tags: Value(article.tags),
                      title: Value(article.title),
                      updated: Value(article.updated),
                    );
                  },
                  where: (old) =>
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
    final statement = db.article.update()
      ..where((article) => article.id.equals(articleId));

    return statement.write(ArticleCompanion(lastRead: Value(read)));
  }

  Selectable<(String, int)> getUnreadArticleCount() {
    final count = countAll();

    final countByFeed = db.article.selectOnly()
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
    int limit = 25,
  }) {
    final ftsQuery = db.buildFtsQuery(searchString);

    if (ftsQuery.isNotEmpty) {
      return db.definitionsDrift.queryArticlesFullContent(
        feedId: feedId?.toString(),
        query: ftsQuery,
        snippetLength: snippetLength,
        beforeMatch: matchPrefix,
        afterMatch: matchSuffix,
        ellipsis: ellipsis,
        limit: limit,
      );
    } else {
      return db.definitionsDrift.queryArticlesBasic(
        feedId: feedId?.toString(),
        query: db.buildLikeQuery(searchString),
        limit: limit,
      );
    }
  }
}
