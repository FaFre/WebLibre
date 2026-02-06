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
import 'package:collection/collection.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article.dart';
import 'package:weblibre/features/web_feed/data/providers.dart';

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
