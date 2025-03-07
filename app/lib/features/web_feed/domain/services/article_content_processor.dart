import 'package:collection/collection.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/core/logger.dart';
import 'package:lensai/features/web_feed/data/models/feed_article.dart';
import 'package:lensai/features/web_feed/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'article_content_processor.g.dart';

@Riverpod(keepAlive: true)
class ArticleContentProcessorService extends _$ArticleContentProcessorService {
  @override
  void build() {
    final db = ref.watch(feedDatabaseProvider);

    final processSub = db.articleDao.getUnprocessedArticles().watch().listen((
      articles,
    ) async {
      try {
        final content = await GeckoBrowserExtensionService.turndownHtml(
          articles.map((article) => article.contentHtml ?? '').toList(),
        );
        final summary = await GeckoBrowserExtensionService.turndownHtml(
          articles.map((article) => article.summaryHtml ?? '').toList(),
        );

        await db.articleDao.updateArticleContent(
          articles
              .mapIndexed(
                (index, article) => article.copyWith(
                  contentMarkdown: content[index].markdown ?? '',
                  contentPlain: content[index].plain,
                  summaryMarkdown: summary[index].markdown ?? '',
                  summaryPlain: summary[index].plain,
                ),
              )
              .toList(),
        );

        logger.i('Processed ${articles.length} articles');
      } catch (e, s) {
        logger.e('Error processing articles', error: e, stackTrace: s);
      }
    });

    ref.onDispose(() async {
      await processSub.cancel();
    });
  }
}
