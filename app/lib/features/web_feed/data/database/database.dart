/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:weblibre/features/search/domain/fts_tokenizer.dart';
import 'package:weblibre/features/web_feed/data/database/daos/article.dart';
import 'package:weblibre/features/web_feed/data/database/daos/feed.dart';
import 'package:weblibre/features/web_feed/data/database/database.drift.dart';

@DriftDatabase(include: {'definitions.drift'}, daos: [ArticleDao, FeedDao])
class FeedDatabase extends $FeedDatabase with TrigramQueryBuilderMixin {
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
      await definitionsDrift.optimizeFtsIndex();
    },
  );

  FeedDatabase(super.e);
}
