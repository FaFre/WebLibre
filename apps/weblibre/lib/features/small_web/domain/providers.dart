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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/features/small_web/data/database/definitions.drift.dart';
import 'package:weblibre/features/small_web/data/models/kagi_small_web_mode.dart';
import 'package:weblibre/features/small_web/data/models/small_web_source_kind.dart';
import 'package:weblibre/features/small_web/data/providers.dart';
import 'package:weblibre/features/small_web/domain/services/kagi_source_service.dart';
import 'package:weblibre/features/small_web/domain/services/small_web_discover_service.dart';
import 'package:weblibre/features/small_web/domain/services/wander_source_service.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
Future<KagiSourceService> kagiSourceService(Ref ref) async {
  final categories = await ref.watch(kagiCategoriesProvider.future);
  return KagiSourceService(
    ref.watch(smallWebDatabaseProvider),
    categories.remap,
  );
}

@Riverpod(keepAlive: true)
WanderSourceService wanderSourceService(Ref ref) {
  return WanderSourceService(ref.watch(smallWebDatabaseProvider));
}

@Riverpod(keepAlive: true)
Future<SmallWebDiscoverService> smallWebDiscoverService(Ref ref) async {
  final kagiService = await ref.watch(kagiSourceServiceProvider.future);

  return SmallWebDiscoverService(
    ref.watch(smallWebDatabaseProvider),
    kagiService,
    ref.watch(wanderSourceServiceProvider),
  );
}

@Riverpod()
Stream<List<GetRecentVisitsResult>> smallWebRecentVisits(
  Ref ref,
  SmallWebSourceKind sourceKind,
  KagiSmallWebMode? mode,
) {
  final db = ref.watch(smallWebDatabaseProvider);
  return db.smallWebVisitDao
      .getRecentVisits(sourceKind: sourceKind, mode: mode)
      .watch();
}

@Riverpod()
Stream<Map<KagiSmallWebMode, int>> smallWebAllModeItemCounts(Ref ref) {
  final db = ref.watch(smallWebDatabaseProvider);
  return db.definitionsDrift.getAllModeItemCounts().watch().map((rows) {
    final counts = <KagiSmallWebMode, int>{};
    for (final row in rows) {
      if (row.mode == null) continue;
      final mode = KagiSmallWebMode.values
          .where((m) => m.name == row.mode)
          .firstOrNull;
      if (mode != null) counts[mode] = (counts[mode] ?? 0) + row.c;
    }
    return counts;
  });
}

@Riverpod()
Stream<({int linkedConsoles, int pages})> wanderConsoleStats(
  Ref ref,
  Uri consoleUrl,
) {
  final db = ref.watch(smallWebDatabaseProvider);

  final linkedConsoles = db.definitionsDrift
      .getConsoleNeighborCount(consoleUrl: consoleUrl.toString())
      .watchSingle();

  final pages = db.definitionsDrift
      .getWanderPagesForConsole(
        sourceKind: SmallWebSourceKind.wander,
        consoleUrl: consoleUrl.toString(),
      )
      .watch();

  return CombineLatestStream.combine2(
    linkedConsoles,
    pages,
    (a, b) => (linkedConsoles: a, pages: b.length),
  );
}

@Riverpod()
Stream<List<GetNeighborConsolesWithPageCountsResult>> wanderNeighborConsoles(
  Ref ref,
  Uri consoleUrl,
) {
  final db = ref.watch(smallWebDatabaseProvider);

  return db.definitionsDrift
      .getNeighborConsolesWithPageCounts(
        sourceKind: SmallWebSourceKind.wander,
        sourceConsoleUrl: consoleUrl.toString(),
      )
      .watch();
}

@Riverpod()
Stream<List<GetAllConsolesWithPageCountsResult>> wanderAllConsoles(
  Ref ref,
  String query,
) {
  final db = ref.watch(smallWebDatabaseProvider);
  return db.definitionsDrift
      .getAllConsolesWithPageCounts(
        sourceKind: SmallWebSourceKind.wander,
        query: query,
      )
      .watch();
}
