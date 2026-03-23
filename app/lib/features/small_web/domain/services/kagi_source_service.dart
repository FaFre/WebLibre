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
import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:rss_dart/dart_rss.dart';
import 'package:uuid/enums.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/uuid.dart';
import 'package:weblibre/extensions/http_encoding.dart';
import 'package:weblibre/features/small_web/data/database/database.dart';
import 'package:weblibre/features/small_web/data/database/definitions.drift.dart';
import 'package:weblibre/features/small_web/data/models/kagi_feed_entry.dart';
import 'package:weblibre/features/small_web/data/models/kagi_small_web_mode.dart';
import 'package:weblibre/features/small_web/data/models/small_web_source_kind.dart';

const _staleDuration = Duration(hours: 3);

typedef _KagiFeedFetchRequest = ({
  RootIsolateToken token,
  String url,
  String mode,
  Map<String, String> categoryRemap,
});

class KagiSourceService {
  final SmallWebDatabase _db;
  final Map<String, String> _categoryRemap;

  KagiSourceService(this._db, this._categoryRemap);

  Future<bool> needsRefresh(KagiSmallWebMode mode) async {
    final latestFetch = await _db.smallWebItemDao
        .getLatestFetchedAt(SmallWebSourceKind.kagi, mode)
        .getSingleOrNull();

    if (latestFetch == null) return true;

    return DateTime.now().difference(latestFetch) > _staleDuration;
  }

  Future<void> fetchAndIngest(KagiSmallWebMode mode) async {
    final request = (
      token: ServicesBinding.rootIsolateToken!,
      url: mode.feedUrl.toString(),
      mode: mode.name,
      categoryRemap: Map<String, String>.from(_categoryRemap),
    );

    final List<KagiFeedEntry> entries;
    try {
      entries = await _runKagiFeedFetch(request);
    } catch (e, st) {
      logger.e(
        'Failed to fetch/parse Kagi feed for $mode',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }

    final now = DateTime.now();
    await _db.batch((batch) {
      for (final entry in entries) {
        final itemId = uuid.v5(Namespace.url.value, entry.url.toString());

        batch.insert(
          _db.smallWebItems,
          SmallWebItemsCompanion.insert(
            id: itemId,
            url: entry.url,
            title: Value(entry.title),
            domain: entry.url.host,
            author: Value(entry.author),
            summary: Value(entry.summary),
            publishedAt: Value(entry.publishedAt),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
          onConflict: DoUpdate(
            (old) => SmallWebItemsCompanion(
              title: entry.title != null
                  ? Value(entry.title)
                  : const Value.absent(),
              author: entry.author != null
                  ? Value(entry.author)
                  : const Value.absent(),
              summary: entry.summary != null
                  ? Value(entry.summary)
                  : const Value.absent(),
              publishedAt: entry.publishedAt != null
                  ? Value(entry.publishedAt)
                  : const Value.absent(),
              updatedAt: Value(now),
            ),
            target: [_db.smallWebItems.url],
          ),
        );

        final membershipId = uuid.v5(
          Namespace.url.value,
          '${SmallWebSourceKind.kagi.name}:${mode.name}:${entry.url}',
        );

        batch.insert(
          _db.smallWebMemberships,
          SmallWebMembershipsCompanion.insert(
            id: membershipId,
            itemId: itemId,
            sourceKind: SmallWebSourceKind.kagi,
            mode: Value(mode.name),
            consoleUrl: const Value(null),
            categories: Value(entry.categories),
            fetchedAt: Value(now),
          ),
          onConflict: DoUpdate(
            (old) => SmallWebMembershipsCompanion(
              categories: Value(entry.categories),
              fetchedAt: Value(now),
            ),
            target: [_db.smallWebMemberships.id],
          ),
        );
      }
    });
  }
}

Future<List<KagiFeedEntry>> _runKagiFeedFetch(_KagiFeedFetchRequest request) {
  return Isolate.run(_createKagiFeedFetchTask(request));
}

Future<List<KagiFeedEntry>> Function() _createKagiFeedFetchTask(
  _KagiFeedFetchRequest request,
) {
  return () => _fetchAndParseFeed(
    request.token,
    Uri.parse(request.url),
    request.mode,
    request.categoryRemap,
  );
}

Future<List<KagiFeedEntry>> _fetchAndParseFeed(
  RootIsolateToken token,
  Uri url,
  String mode,
  Map<String, String> categoryRemap,
) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(token);

  final client = http.Client();
  try {
    final response = await client.get(url).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception(
        'Kagi feed request failed with status ${response.statusCode}',
      );
    }

    final xmlString = response.bodyUnicodeFallback;
    final feed = AtomFeed.parse(xmlString);

    return feed.items
        .map((item) {
          final link = item.links
              .where((l) => l.rel == 'alternate' || l.rel == null)
              .map((l) => l.href)
              .firstOrNull;

          final href = link ?? item.links.firstOrNull?.href;
          final parsedUrl = href != null ? Uri.tryParse(href) : null;
          if (parsedUrl == null) return null;

          if (mode == 'videos' && parsedUrl.path.contains('/shorts/')) {
            return null;
          }

          const kagiScheme = 'https://kagi.com/smallweb/categories';
          final categories = item.categories
              .where(
                (c) =>
                    c.scheme == kagiScheme &&
                    c.term != null &&
                    c.term!.isNotEmpty,
              )
              .map((c) => categoryRemap[c.term!] ?? c.term!)
              .toList();

          final author = item.authors
              .where((a) => a.name != null && a.name!.isNotEmpty)
              .map((a) => a.name!)
              .firstOrNull;

          return KagiFeedEntry(
            url: parsedUrl,
            title: item.title,
            author: author,
            summary: item.summary,
            publishedAt: item.updated != null
                ? DateTime.tryParse(item.updated!)
                : null,
            categories: categories,
          );
        })
        .nonNulls
        .toList();
  } finally {
    client.close();
  }
}
