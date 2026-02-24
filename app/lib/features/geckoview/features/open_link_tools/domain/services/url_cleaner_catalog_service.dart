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
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_catalog_file.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_rule.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'url_cleaner_catalog_service.g.dart';

@Riverpod(keepAlive: true)
class UrlCleanerCatalogService extends _$UrlCleanerCatalogService {
  Future<List<UrlCleanerRule>> _loadCatalog() async {
    final fileService = ref.read(urlCleanerCatalogFileServiceProvider.notifier);
    final storedCatalog = await fileService.readCatalog();

    if (storedCatalog != null && storedCatalog.isNotEmpty) {
      return _parseRules(storedCatalog);
    }

    final bundledCatalog = await rootBundle.loadString(
      'assets/preferences/url_cleaner_data.minify.json',
    );
    try {
      await fileService.writeCatalog(bundledCatalog);
    } catch (_) {
      // Continue using bundled rules if local persistence is unavailable.
    }

    return _parseRules(bundledCatalog);
  }

  List<UrlCleanerRule> _parseRules(String rawJson) {
    final catalog = jsonDecode(rawJson) as Map<String, dynamic>;
    final providers = catalog['providers'] as Map<String, dynamic>?;
    if (providers == null) return [];

    final rules = <UrlCleanerRule>[];
    for (final entry in providers.entries) {
      rules.add(
        UrlCleanerRule.fromCatalogEntry(
          entry.key,
          entry.value as Map<String, dynamic>,
        ),
      );
    }

    return rules;
  }

  Future<void> updateCatalog({bool lastUpdateWasAuto = false}) async {
    final settings = ref.read(generalSettingsWithDefaultsProvider);
    final catalogUrl = settings.urlCleanerCatalogUrl;
    final hashUrl = settings.urlCleanerHashUrl;

    // Fetch catalog and hash in parallel since they are independent.
    final catalogFuture = http
        .get(Uri.parse(catalogUrl))
        .timeout(const Duration(seconds: 30));
    final hashFuture = hashUrl.isNotEmpty
        ? http.get(Uri.parse(hashUrl)).timeout(const Duration(seconds: 15))
        : null;

    final results = await Future.wait([
      catalogFuture,
      if (hashFuture != null) hashFuture,
    ]);

    final response = results[0];
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch catalog: ${response.statusCode}');
    }

    final body = response.body;

    // Verify hash if hashUrl is provided
    if (hashFuture != null) {
      final hashResponse = results[1];
      if (hashResponse.statusCode != 200) {
        throw Exception(
          'Failed to fetch catalog hash: ${hashResponse.statusCode}',
        );
      }

      final expectedHash = hashResponse.body.trim();
      final actualHash = sha256.convert(utf8.encode(body)).toString();
      if (actualHash != expectedHash) {
        throw Exception('Catalog hash mismatch');
      }
    }

    // Validate JSON parses correctly
    final newRules = _parseRules(body);
    if (newRules.isEmpty) {
      throw Exception('Catalog contains no providers');
    }

    await ref
        .read(urlCleanerCatalogFileServiceProvider.notifier)
        .writeCatalog(body);

    final now = DateTime.now().millisecondsSinceEpoch;

    await ref
        .read(generalSettingsRepositoryProvider.notifier)
        .updateSettings(
          (current) => current.copyWith(
            urlCleanerLastCheckEpochMs: now,
            urlCleanerLastUpdateWasAuto: lastUpdateWasAuto,
          ),
        );

    // Reload rules from updated catalog
    ref.invalidateSelf();
  }

  Future<DateTime?> lastUpdate() {
    return ref.read(urlCleanerCatalogFileServiceProvider.notifier).lastUpdate();
  }

  Future<void> restoreBundledCatalog() async {
    await ref
        .read(urlCleanerCatalogFileServiceProvider.notifier)
        .deleteCatalog();

    ref.invalidateSelf();
  }

  Future<bool> updateIfNecessary() async {
    final autoUpdate = ref
        .read(generalSettingsWithDefaultsProvider)
        .urlCleanerAutoUpdate;

    if (!autoUpdate) return false;

    final lastUpdate = await this.lastUpdate();
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    if (lastUpdate != null && lastUpdate.isAfter(sevenDaysAgo)) return false;

    await updateCatalog(lastUpdateWasAuto: true);

    return true;
  }

  Future<void> _runAutoUpdateIfNecessary() async {
    try {
      await updateIfNecessary();
    } catch (e, s) {
      logger.w(
        'Failed auto-updating URL cleaner catalog',
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<List<UrlCleanerRule>> build() async {
    final rules = await _loadCatalog();

    // Run auto-update checks in the background so the UI gets local rules fast.
    unawaited(_runAutoUpdateIfNecessary());

    return rules;
  }
}
