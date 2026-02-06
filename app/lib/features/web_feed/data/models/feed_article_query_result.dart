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
import 'package:weblibre/features/web_feed/data/models/feed_article.dart';

class FeedArticleQueryResult extends FeedArticle {
  final String? titleHighlight;
  final String? summarySnippet;
  final String? contentSnippet;

  final double weightedRank;

  FeedArticleQueryResult({
    required super.id,
    required super.feedId,
    required super.fetched,
    required this.weightedRank,
    required super.created,
    required super.updated,
    required super.lastRead,
    required super.title,
    required super.authors,
    required super.tags,
    required super.links,
    required super.summaryHtml,
    required super.summaryMarkdown,
    required super.summaryPlain,
    required super.contentHtml,
    required super.contentMarkdown,
    required super.contentPlain,
    required super.icon,
    this.titleHighlight,
    this.summarySnippet,
    this.contentSnippet,
  });

  @override
  List<Object?> get hashParameters => [
    ...super.hashParameters,
    weightedRank,
    summarySnippet,
    contentSnippet,
    titleHighlight,
  ];
}
