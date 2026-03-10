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
import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/core/uuid.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/history.dart';
import 'package:weblibre/features/geckoview/features/top_sites/data/database/definitions.drift.dart';
import 'package:weblibre/features/geckoview/features/top_sites/data/entities/stored_top_site_source.dart';
import 'package:weblibre/features/geckoview/features/top_sites/data/providers.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/entities/top_site_item.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/entities/top_site_source.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/providers.dart';
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

part 'top_site_repository.g.dart';

@Riverpod(keepAlive: true)
class TopSiteRepository extends _$TopSiteRepository {
  Stream<List<TopSiteItem>> watchTopSites({int limit = 8}) {
    final db = ref.read(topSiteDatabaseProvider);

    return CombineLatestStream.combine2(
      db.topSiteDao.selectAllTopSites().watch(),
      db.hiddenTopSiteDao.watchHiddenUrls(),
      (List<TopSiteData> rows, Set<String> hiddenUrls) => (rows, hiddenUrls),
    ).asyncMap((record) async {
      final (rows, hiddenUrls) = record;
      final persistedItems = rows.map(_mapRow).toList();
      final persistedUrls = persistedItems
          .map((s) => s.url.normalized.toString())
          .toSet();

      final defaultItems = _getVisibleDefaults(
        persistedUrls: persistedUrls,
        hiddenUrls: hiddenUrls,
      );

      final combined = [...persistedItems, ...defaultItems];
      final targetCount = limit < 0 ? 0 : limit;

      if (combined.length >= targetCount) {
        return combined;
      }

      final remaining = targetCount - combined.length;
      final excludeUrls = {
        ...persistedUrls,
        ...defaultItems.map((s) => s.url.normalized.toString()),
      };
      final historyItems = await _getHistoryItems(
        limit: remaining,
        excludeUrls: excludeUrls,
      );

      return [...combined, ...historyItems];
    });
  }

  Future<List<TopSiteItem>> getTopSites({int limit = 8}) async {
    final db = ref.read(topSiteDatabaseProvider);
    final rows = await db.topSiteDao.getAllTopSites();
    final hiddenUrls = await db.hiddenTopSiteDao.getHiddenUrls();

    final persistedItems = rows.map(_mapRow).toList();
    final persistedUrls = persistedItems
        .map((s) => s.url.normalized.toString())
        .toSet();

    final defaultItems = _getVisibleDefaults(
      persistedUrls: persistedUrls,
      hiddenUrls: hiddenUrls,
    );

    final combined = [...persistedItems, ...defaultItems];
    final targetCount = limit < 0 ? 0 : limit;

    if (combined.length >= targetCount) {
      return combined;
    }

    final remaining = targetCount - combined.length;
    final excludeUrls = {
      ...persistedUrls,
      ...defaultItems.map((s) => s.url.normalized.toString()),
    };
    final historyItems = await _getHistoryItems(
      limit: remaining,
      excludeUrls: excludeUrls,
    );

    return [...combined, ...historyItems];
  }

  Stream<List<TopSiteItem>> watchPinnedTopSites() {
    final db = ref.read(topSiteDatabaseProvider);
    return db.topSiteDao.selectAllTopSites().watch().map(
      (rows) => rows
          .where((r) => r.source == StoredTopSiteSource.pinned)
          .map(_mapRow)
          .toList(),
    );
  }

  static Uri _validateUrl(Uri url) {
    final normalized = url.normalized;
    final parsed = uri_parser.tryParseUrl(
      normalized.toString(),
      eagerParsing: true,
    );
    if (parsed == null) {
      throw ArgumentError.value(url.toString(), 'url', 'Invalid URL');
    }
    return normalized;
  }

  /// Persists a default site to the database so it can be reordered.
  /// Returns the database ID.
  Future<String> _persistDefault({
    required String title,
    required Uri url,
    required String orderKey,
  }) async {
    final db = ref.read(topSiteDatabaseProvider);
    final id = uuid.v7();
    await db.topSiteDao.insertSite(
      id: id,
      title: title,
      url: url,
      source: StoredTopSiteSource.defaultSite,
      orderKey: orderKey,
    );
    return id;
  }

  /// Ensures a default site is persisted in the database. If it already exists,
  /// returns its existing ID. Otherwise inserts it with a trailing order key.
  Future<String> ensureDefaultPersisted({
    required String title,
    required Uri url,
  }) async {
    final db = ref.read(topSiteDatabaseProvider);
    final existing = await db.topSiteDao.getTopSiteByUrl(url);
    if (existing != null) return existing.id;

    final orderKey = await db.topSiteDao.generateTrailingOrderKey().getSingle();
    return _persistDefault(title: title, url: url, orderKey: orderKey);
  }

  Future<String> addPinnedSite({
    required String title,
    required Uri url,
  }) async {
    _validateUrl(url);
    final db = ref.read(topSiteDatabaseProvider);

    // If it was a hidden default, unhide it
    await db.hiddenTopSiteDao.unhideUrl(url);

    // Check if URL already exists
    final existing = await db.topSiteDao.getTopSiteByUrl(url);
    if (existing != null) {
      final leadingKey = await db.topSiteDao
          .generateLeadingOrderKey()
          .getSingle();
      await db.topSiteDao.promoteToSource(
        existing.id,
        source: StoredTopSiteSource.pinned,
        title: title,
        orderKey: leadingKey,
      );
      return existing.id;
    }

    final id = uuid.v7();
    final orderKey = await db.topSiteDao.generateLeadingOrderKey().getSingle();
    await db.topSiteDao.insertSite(
      id: id,
      title: title,
      url: url,
      source: StoredTopSiteSource.pinned,
      orderKey: orderKey,
    );
    return id;
  }

  Future<void> updateSite({
    required String id,
    required String title,
    required Uri url,
  }) {
    _validateUrl(url);
    return ref
        .read(topSiteDatabaseProvider)
        .topSiteDao
        .updateSite(id, title: title, url: url);
  }

  Future<void> removeSite(String id) {
    return ref.read(topSiteDatabaseProvider).topSiteDao.deleteSite(id);
  }

  Future<void> hideDefaultSite(Uri url) {
    return ref.read(topSiteDatabaseProvider).hiddenTopSiteDao.hideUrl(url);
  }

  Future<bool> isPinnedTopSiteUrl(Uri url) async {
    final row = await ref
        .read(topSiteDatabaseProvider)
        .topSiteDao
        .getTopSiteByUrl(url);
    return row != null && row.source == StoredTopSiteSource.pinned;
  }

  Future<bool> unpinSiteByUrl(Uri url) async {
    final db = ref.read(topSiteDatabaseProvider);
    final row = await db.topSiteDao.getTopSiteByUrl(url);
    if (row == null) return false;

    // If it was a pinned default, demote back to defaultSite source
    final isDefaultUrl = defaultTopSites.any(
      (d) => Uri.parse(d.url).normalized == url.normalized,
    );
    if (isDefaultUrl) {
      final trailingKey = await db.topSiteDao
          .generateTrailingOrderKey()
          .getSingle();
      await db.topSiteDao.promoteToSource(
        row.id,
        source: StoredTopSiteSource.defaultSite,
        title: row.title,
        orderKey: trailingKey,
      );
    } else {
      await db.topSiteDao.deleteSite(row.id);
    }
    return true;
  }

  Future<void> assignOrderKey(String id, String orderKey) {
    return ref
        .read(topSiteDatabaseProvider)
        .topSiteDao
        .assignOrderKey(id, orderKey: orderKey);
  }

  Future<String> getLeadingOrderKey() {
    return ref
        .read(topSiteDatabaseProvider)
        .topSiteDao
        .generateLeadingOrderKey()
        .getSingle();
  }

  Future<String> getTrailingOrderKey() {
    return ref
        .read(topSiteDatabaseProvider)
        .topSiteDao
        .generateTrailingOrderKey()
        .getSingle();
  }

  Future<String?> getOrderKeyAfterSite(String id) {
    return ref
        .read(topSiteDatabaseProvider)
        .topSiteDao
        .generateOrderKeyAfterSiteId(id)
        .getSingleOrNull();
  }

  Future<String> getOrderKeyBeforeSite(String id) {
    return ref
        .read(topSiteDatabaseProvider)
        .topSiteDao
        .generateOrderKeyBeforeSiteId(id)
        .getSingle();
  }

  List<TopSiteItem> _getVisibleDefaults({
    required Set<String> persistedUrls,
    required Set<String> hiddenUrls,
  }) {
    return defaultTopSites
        .where((seed) {
          final normalized = Uri.parse(seed.url).normalized.toString();
          return !persistedUrls.contains(normalized) &&
              !hiddenUrls.contains(normalized);
        })
        .map(
          (seed) => TopSiteItem(
            title: seed.title,
            url: Uri.parse(seed.url),
            source: TopSiteSource.defaultSite,
          ),
        )
        .toList();
  }

  Future<List<TopSiteItem>> _getHistoryItems({
    required int limit,
    required Set<String> excludeUrls,
  }) async {
    final frecentSites = await ref
        .read(historyRepositoryProvider.notifier)
        .getTopFrecentSites(limit: limit + excludeUrls.length);

    final items = <TopSiteItem>[];
    for (final site in frecentSites) {
      if (items.length >= limit) break;

      final uri = Uri.tryParse(site.url);
      if (uri == null) continue;

      if (excludeUrls.contains(uri.normalized.toString())) continue;

      final title = (site.title?.trim().isNotEmpty == true)
          ? site.title!.trim()
          : uri.host;

      items.add(
        TopSiteItem(title: title, url: uri, source: TopSiteSource.history),
      );
    }

    return items;
  }

  TopSiteItem _mapRow(TopSiteData row) {
    return TopSiteItem(
      id: row.id,
      title: row.title,
      url: row.url,
      source: row.source == StoredTopSiteSource.pinned
          ? TopSiteSource.pinned
          : TopSiteSource.defaultSite,
      orderKey: row.orderKey,
      createdAt: row.createdAt,
    );
  }

  @override
  void build() {}
}
