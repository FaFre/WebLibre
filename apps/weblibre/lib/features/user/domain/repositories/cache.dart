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
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'cache.g.dart';

@Riverpod(keepAlive: true)
class CacheRepository extends _$CacheRepository {
  Future<void> clearCache() {
    return ref.read(userDatabaseProvider).cacheDao.clearIconCache();
  }

  Future<void> cacheIcon(Uri url, Uint8List bytes) {
    return ref.read(userDatabaseProvider).cacheDao.cacheIcon(url.origin, bytes);
  }

  Future<Uint8List?> getCachedIcon(String origin) {
    return ref
        .read(userDatabaseProvider)
        .cacheDao
        .getCachedIcon(origin)
        .getSingleOrNull();
  }

  @override
  void build() {
    final eventService = ref.watch(eventServiceProvider);

    final db = ref.watch(userDatabaseProvider);

    final sub = eventService.iconUpdateEvents.listen(
      (event) async {
        if (Uri.tryParse(event.url) case final Uri url) {
          await db.cacheDao.cacheIcon(url.origin, event.bytes);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error in icon update events',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.onDispose(() async {
      await sub.cancel();
    });
  }
}
