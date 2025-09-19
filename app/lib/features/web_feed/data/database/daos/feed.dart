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
import 'package:weblibre/features/web_feed/data/database/daos/feed.drift.dart';
import 'package:weblibre/features/web_feed/data/database/database.dart';
import 'package:weblibre/features/web_feed/data/database/definitions.drift.dart';

@DriftAccessor()
class FeedDao extends DatabaseAccessor<FeedDatabase> with $FeedDaoMixin {
  FeedDao(super.attachedDatabase);

  Selectable<FeedData> getFeeds() {
    return db.feed.select();
  }

  SingleOrNullSelectable<FeedData> getFeed(Uri feedId) {
    return db.feed.select()..where((feed) => feed.url.equalsValue(feedId));
  }

  Future<int> updateFeedFetched(Uri feedId, DateTime fetched) {
    final statement = db.feed.update()
      ..where((feed) => feed.url.equalsValue(feedId));

    return statement.write(FeedCompanion(lastFetched: Value(fetched)));
  }

  Future<int> deleteFeed(Uri feedId) {
    return db.feed.deleteWhere((feed) => feed.url.equals(feedId.toString()));
  }

  Future<int> upsertFeed(FeedData feedData) {
    return db.feed.insertOne(
      feedData,
      onConflict: DoUpdate((old) {
        return FeedCompanion(
          authors: Value(feedData.authors),
          title: Value(feedData.title),
          description: Value(feedData.description),
          tags: Value(feedData.tags),
        );
      }),
    );
  }
}
