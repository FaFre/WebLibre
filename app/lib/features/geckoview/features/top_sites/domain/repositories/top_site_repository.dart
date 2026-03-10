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

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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
  Future<void> ensureSeeded() async {
    final db = ref.read(topSiteDatabaseProvider);
    final seeds = ref.read(topSiteDefaultSeedsProvider);

    await db.transaction(() async {
      final alreadySeeded = await db.topSiteSeedStateDao.hasSeed(
        'initial-defaults-v1',
      );
      if (alreadySeeded) return;

      final now = DateTime.now();

      for (var i = 0; i < seeds.length; i++) {
        final orderKey = await db.topSiteDao
            .generateTrailingOrderKey()
            .getSingle();
        // Insert one-by-one so trailing key advances
        await db.topSite.insertOne(
          TopSiteCompanion.insert(
            id: uuid.v7(),
            title: seeds[i].title,
            url: seeds[i].url.normalized,
            source: StoredTopSiteSource.seeded,
            orderKey: orderKey,
            createdAt: now,
          ),
        );
      }

      await db.topSiteSeedStateDao.markSeedApplied('initial-defaults-v1');
    });
  }

  Future<List<TopSiteItem>> getTopSites({int limit = 8}) async {
    final persisted = await _getPersistedItems();
    final targetCount = limit < 0 ? 0 : limit;

    // Always keep all persisted items. The limit is only used as a history
    // padding target.
    if (persisted.length >= targetCount) {
      return persisted;
    }

    final remaining = targetCount - persisted.length;
    final historyItems = await _getHistoryItems(
      limit: remaining,
      excludeUrls: persisted.map((s) => s.url.normalized.toString()).toSet(),
    );

    return [...persisted, ...historyItems];
  }

  Stream<List<TopSiteItem>> watchTopSites({int limit = 8}) {
    final db = ref.read(topSiteDatabaseProvider);
    return db.topSiteDao.selectPersistedTopSites().watch().asyncMap((
      persistedRows,
    ) async {
      final persistedItems = persistedRows.map(_mapPersistedRow).toList();
      final targetCount = limit < 0 ? 0 : limit;

      // Always keep all persisted items. The limit is only used as a history
      // padding target.
      if (persistedItems.length >= targetCount) {
        return persistedItems;
      }

      final remaining = targetCount - persistedItems.length;
      final historyItems = await _getHistoryItems(
        limit: remaining,
        excludeUrls: persistedItems
            .map((s) => s.url.normalized.toString())
            .toSet(),
      );

      return [...persistedItems, ...historyItems];
    });
  }

  Future<List<TopSiteItem>> getPersistedTopSites() {
    return _getPersistedItems();
  }

  Stream<List<TopSiteItem>> watchPersistedTopSites() {
    final db = ref.read(topSiteDatabaseProvider);
    return db.topSiteDao.selectPersistedTopSites().watch().map(
      (rows) => rows.map(_mapPersistedRow).toList(),
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

  Future<String> addPinnedSite({
    required String title,
    required Uri url,
  }) async {
    _validateUrl(url);
    final db = ref.read(topSiteDatabaseProvider);

    // Check if URL already exists as a persisted site
    final existing = await db.topSiteDao.getPersistedTopSiteByUrl(url);
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
    await db.topSiteDao.insertPinnedSite(
      id: id,
      title: title,
      url: url,
      orderKey: orderKey,
    );
    return id;
  }

  Future<void> updatePersistedSite({
    required String id,
    required String title,
    required Uri url,
  }) {
    _validateUrl(url);
    return ref
        .read(topSiteDatabaseProvider)
        .topSiteDao
        .updatePersistedSite(id, title: title, url: url);
  }

  Future<void> removePersistedSite(String id) {
    return ref.read(topSiteDatabaseProvider).topSiteDao.deletePersistedSite(id);
  }

  Future<TopSiteItem?> getPersistedTopSiteByUrl(Uri url) async {
    final row = await ref
        .read(topSiteDatabaseProvider)
        .topSiteDao
        .getPersistedTopSiteByUrl(url);
    return row != null ? _mapPersistedRow(row) : null;
  }

  Future<bool> isPersistedTopSiteUrl(Uri url) async {
    final row = await ref
        .read(topSiteDatabaseProvider)
        .topSiteDao
        .getPersistedTopSiteByUrl(url);
    return row != null;
  }

  Future<bool> unpinSiteByUrl(Uri url) async {
    final row = await ref
        .read(topSiteDatabaseProvider)
        .topSiteDao
        .getPersistedTopSiteByUrl(url);
    if (row == null) return false;
    await ref
        .read(topSiteDatabaseProvider)
        .topSiteDao
        .deletePersistedSite(row.id);
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

  Future<List<TopSiteItem>> _getPersistedItems() async {
    final rows = await ref
        .read(topSiteDatabaseProvider)
        .topSiteDao
        .getPersistedTopSites();
    return rows.map(_mapPersistedRow).toList();
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

  TopSiteItem _mapPersistedRow(TopSiteData row) {
    return TopSiteItem(
      id: row.id,
      title: row.title,
      url: row.url,
      source: row.source == StoredTopSiteSource.seeded
          ? TopSiteSource.seeded
          : TopSiteSource.pinned,
      orderKey: row.orderKey,
      createdAt: row.createdAt,
    );
  }

  @override
  void build() {
    unawaited(ensureSeeded());
  }
}
