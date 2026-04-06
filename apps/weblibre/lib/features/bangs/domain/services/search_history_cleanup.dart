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
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/bangs/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'search_history_cleanup.g.dart';

/// Service that listens to maxSearchHistoryEntries setting changes
/// and cleans up search history when the limit is reduced.
@Riverpod(keepAlive: true)
class SearchHistoryCleanupService extends _$SearchHistoryCleanupService {
  @override
  void build() {
    ref.listen(
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.maxSearchHistoryEntries,
      ),
      (previous, next) async {
        // Only cleanup when limit is reduced (including to 0)
        if (previous != null && next < previous) {
          final db = ref.read(bangDatabaseProvider);
          await db.definitionsDrift.evictHistoryEntries(limit: next);
        }
      },
    );
  }
}
