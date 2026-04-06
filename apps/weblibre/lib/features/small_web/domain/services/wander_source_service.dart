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
import 'package:uuid/enums.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/uuid.dart';
import 'package:weblibre/features/small_web/data/database/database.dart';
import 'package:weblibre/features/small_web/data/database/definitions.drift.dart';
import 'package:weblibre/features/small_web/data/models/small_web_source_kind.dart';
import 'package:weblibre/features/small_web/data/models/wander_console_source.dart';
import 'package:weblibre/features/small_web/data/wander_seed_consoles.dart';
import 'package:weblibre/features/small_web/domain/services/wander_js_parser.dart';

const _staleDuration = Duration(hours: 3);
const _retryAfterError = Duration(minutes: 30);

typedef _WanderJsFetchRequest = ({RootIsolateToken token, String url});

class WanderSourceService {
  final SmallWebDatabase _db;

  WanderSourceService(this._db);

  Future<bool> shouldRefreshConsole(
    Uri consoleUrl, {
    bool forceRetry = false,
  }) async {
    final console = await _db.wanderConsoleDao
        .getConsole(consoleUrl)
        .getSingleOrNull();

    if (console == null || console.lastFetchedAt == null) return true;

    final age = DateTime.now().difference(console.lastFetchedAt!);
    if (console.lastFetchFailed == true) {
      return forceRetry || age > _retryAfterError;
    }

    return age > _staleDuration;
  }

  Future<void> syncSeeds() async {
    final now = DateTime.now();
    await _db.batch((batch) {
      for (final seedUrl in wanderSeedConsoles) {
        final url = Uri.parse(seedUrl);
        batch.insert(
          _db.wanderConsoles,
          WanderConsolesCompanion.insert(
            url: url,
            wanderJsUrl: url.resolve('wander.js'),
            source: WanderConsoleSource.seed,
            createdAt: Value(now),
          ),
          onConflict: DoNothing(),
        );
      }
    });
  }

  Future<WanderJsResult?> fetchAndIngestConsole(
    Uri consoleUrl, {
    required WanderConsoleSource source,
  }) async {
    final wanderJsUrl = consoleUrl.resolve('wander.js');
    final now = DateTime.now();

    try {
      final result = await _runWanderJsFetch((
        token: ServicesBinding.rootIsolateToken!,
        url: wanderJsUrl.toString(),
      ));

      if (result == null) {
        await _saveConsoleWithError(consoleUrl, wanderJsUrl, now, source);
        return null;
      }

      final existingUrls = await _db.wanderConsoleDao
          .getExistingConsoleUrls(result.consoles)
          .get();

      await _db.transaction(() async {
        await _db.wanderConsoleDao.upsertConsole(
          WanderConsole(
            url: consoleUrl,
            wanderJsUrl: wanderJsUrl,
            lastFetchedAt: now,
            lastFetchFailed: false,
            source: source,
            createdAt: now,
          ),
        );

        await _db.batch((batch) {
          for (final neighborUrl in result.consoles) {
            batch.insert(
              _db.wanderConsoleNeighbors,
              WanderConsoleNeighborsCompanion.insert(
                sourceConsoleUrl: consoleUrl.toString(),
                targetConsoleUrl: neighborUrl.toString(),
                discoveredAt: Value(now),
              ),
              onConflict: DoNothing(),
            );

            if (!existingUrls.contains(neighborUrl)) {
              batch.insert(
                _db.wanderConsoles,
                WanderConsolesCompanion.insert(
                  url: neighborUrl,
                  wanderJsUrl: neighborUrl.resolve('wander.js'),
                  discoveredFromUrl: Value(consoleUrl),
                  source: WanderConsoleSource.discovered,
                  createdAt: Value(now),
                ),
                onConflict: DoNothing(),
              );
            }
          }

          for (final pageUrl in result.pages) {
            final itemId = uuid.v5(Namespace.url.value, pageUrl.toString());

            batch.insert(
              _db.smallWebItems,
              SmallWebItemsCompanion.insert(
                id: itemId,
                url: pageUrl,
                domain: pageUrl.host,
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
              onConflict: DoUpdate(
                (old) => SmallWebItemsCompanion(updatedAt: Value(now)),
                target: [_db.smallWebItems.url],
              ),
            );

            final membershipId = uuid.v5(
              Namespace.url.value,
              '${SmallWebSourceKind.wander.name}:$consoleUrl:$pageUrl',
            );

            batch.insert(
              _db.smallWebMemberships,
              SmallWebMembershipsCompanion.insert(
                id: membershipId,
                itemId: itemId,
                sourceKind: SmallWebSourceKind.wander,
                consoleUrl: Value(consoleUrl),
                fetchedAt: Value(now),
              ),
              onConflict: DoUpdate(
                (old) => SmallWebMembershipsCompanion(fetchedAt: Value(now)),
                target: [_db.smallWebMemberships.id],
              ),
            );
          }
        });
      });

      return result;
    } catch (e, st) {
      logger.e(
        'Failed to fetch wander.js from $wanderJsUrl',
        error: e,
        stackTrace: st,
      );
      await _saveConsoleWithError(consoleUrl, wanderJsUrl, now, source);
      rethrow;
    }
  }

  /// Normalizes a user-input URL to a wander console URL.
  ///
  /// Accepts URLs like:
  /// - `https://example.com/wander/` → kept as-is
  /// - `https://example.com/wander` → trailing slash added
  /// - `https://example.com` → `/wander/` appended
  /// - `https://example.com/` → `wander/` appended
  ///
  /// Returns the normalized console URL (always ends with `/wander/`).
  static Uri normalizeConsoleUrl(Uri url) {
    var path = url.path;

    // Strip trailing wander.js if someone pasted the full JS URL
    if (path.endsWith('/wander.js')) {
      path = path.substring(0, path.length - 'wander.js'.length);
    }

    // Ensure the path ends with /wander/
    if (!path.endsWith('/wander/')) {
      if (path.endsWith('/wander')) {
        path = '$path/';
      } else {
        if (!path.endsWith('/')) {
          path = '$path/';
        }
        path = '${path}wander/';
      }
    }

    return url.replace(path: path);
  }

  /// Checks if a console URL already exists in the database.
  Future<bool> consoleExists(Uri consoleUrl) async {
    final console = await _db.wanderConsoleDao
        .getConsole(consoleUrl)
        .getSingleOrNull();

    return console != null;
  }

  /// Validates that a URL points to a valid wander console by fetching its
  /// wander.js and checking it contains valid consoles or pages data.
  ///
  /// Returns the parsed [WanderJsResult] if valid, or throws with a
  /// descriptive error message.
  Future<WanderJsResult> validateConsole(Uri consoleUrl) async {
    final wanderJsUrl = consoleUrl.resolve('wander.js');

    final result = await _runWanderJsFetch((
      token: ServicesBinding.rootIsolateToken!,
      url: wanderJsUrl.toString(),
    ));

    if (result == null) {
      throw Exception('Could not fetch wander.js from $wanderJsUrl');
    }

    if (result.consoles.isEmpty && result.pages.isEmpty) {
      throw Exception('The wander.js file contains no consoles or pages');
    }

    return result;
  }

  /// Validates and adds a user-provided console URL.
  ///
  /// The URL is normalized, checked for duplicates, validated by fetching
  /// wander.js, then ingested into the database.
  ///
  /// Returns the normalized console URL.
  Future<Uri> addConsoleFromUrl(Uri rawUrl) async {
    final consoleUrl = normalizeConsoleUrl(rawUrl);

    if (await consoleExists(consoleUrl)) {
      throw Exception('This console has already been added');
    }

    // Validate by fetching wander.js
    await validateConsole(consoleUrl);

    // Now do the full ingest
    await fetchAndIngestConsole(consoleUrl, source: WanderConsoleSource.manual);

    return consoleUrl;
  }

  Future<List<Uri>> getDiscoveredConsoleUrls() {
    return _db.wanderConsoleDao.getDiscoveredConsoleUrls().get();
  }

  Future<List<SmallWebItem>> getPagesForConsole(Uri consoleUrl) {
    return _db.definitionsDrift
        .getWanderPagesForConsole(
          sourceKind: SmallWebSourceKind.wander,
          consoleUrl: consoleUrl.toString(),
        )
        .get();
  }

  Future<void> _saveConsoleWithError(
    Uri consoleUrl,
    Uri wanderJsUrl,
    DateTime now,
    WanderConsoleSource source,
  ) async {
    await _db.wanderConsoleDao.upsertConsole(
      WanderConsole(
        url: consoleUrl,
        wanderJsUrl: wanderJsUrl,
        lastFetchedAt: now,
        lastFetchFailed: true,
        source: source,
        createdAt: now,
      ),
    );
  }
}

Future<WanderJsResult?> _runWanderJsFetch(_WanderJsFetchRequest request) {
  return Isolate.run(_createWanderJsFetchTask(request));
}

Future<WanderJsResult?> Function() _createWanderJsFetchTask(
  _WanderJsFetchRequest request,
) {
  return () => _fetchAndParseWanderJs(request.token, Uri.parse(request.url));
}

Future<WanderJsResult?> _fetchAndParseWanderJs(
  RootIsolateToken token,
  Uri url,
) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(token);

  final client = http.Client();
  try {
    final response = await client.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) return null;

    return WanderJsResult.parse(response.body);
  } finally {
    client.close();
  }
}
