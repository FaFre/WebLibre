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
import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/history/domain/entities/history_entry.dart';
import 'package:weblibre/features/geckoview/features/history/domain/entities/history_filter_options.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/history.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/visit_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/utils/url_canonical.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
@JsonPersist()
class HistoryVisitsFilter extends _$HistoryVisitsFilter {
  void updateVisitType(VisitType type, bool value) {
    if (value) {
      state = state.copyWith.visitTypes({...state.visitTypes, type});
    } else {
      state = state.copyWith.visitTypes({...state.visitTypes}..remove(type));
    }
  }

  void setContainer(String? containerId) {
    state = state.copyWith.containerId(containerId);
  }

  void reset() {
    state = HistoryFilterOptions.withDefaults();
  }

  void setDateRange(DateTimeRange<DateTime>? range) {
    state = state.copyWith.dateRange(range);
  }

  @override
  HistoryFilterOptions build() {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: 'HistoryVisitsFilterOptions',
    );

    return stateOrNull ?? HistoryFilterOptions.withDefaults();
  }
}

@Riverpod(keepAlive: true)
@JsonPersist()
class HistoryDownloadsFilter extends _$HistoryDownloadsFilter {
  void reset() {
    state = HistoryFilterOptions(
      dateRange: null,
      visitTypes: const {VisitType.download},
    );
  }

  void setDateRange(DateTimeRange<DateTime>? range) {
    state = state.copyWith.dateRange(range);
  }

  @override
  HistoryFilterOptions build() {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: 'HistoryDownloadsFilterOptions',
    );

    return stateOrNull ??
        HistoryFilterOptions(
          dateRange: null,
          visitTypes: const {VisitType.download},
        );
  }
}

/// Annotate Mozilla Places [visits] with the WebLibre container each belonged
/// to (from the `visit_container` relation), matched by canonical URL and
/// nearest visit time. Uncontained visits get an empty tag list. When
/// [filterContainerId] is set, only visits resolving to that container are
/// returned.
///
/// The match is **one-to-one within each canonical URL**: every relation row
/// tags at most one visit, and every visit takes at most one relation. Without
/// this, the same URL opened in several containers one after another (or a
/// container visit followed by an uncontained one of the same URL, within the
/// [historyVisitContainerMatchWindowMs] window) would let one relation bleed
/// onto neighbouring visits — an uncontained visit stealing the previous
/// container's tag. Pairs are assigned greedily from the smallest time delta,
/// consuming both sides, which approximates the minimum-skew assignment.
Future<List<HistoryEntry>> _annotateVisits(
  VisitContainerDao dao,
  List<VisitInfo> visits, {
  String? filterContainerId,
}) async {
  // Visit indices grouped by canonical URL (Places rows without an
  // indexable/canonicalizable URL simply carry no container).
  final canonicals = <String>{};
  final visitIndicesByCanonical = <String, List<int>>{};
  for (var i = 0; i < visits.length; i++) {
    final canonical = canonicalizeUrl(visits[i].url)?.canonical;
    if (canonical != null) {
      canonicals.add(canonical);
      (visitIndicesByCanonical[canonical] ??= <int>[]).add(i);
    }
  }

  final relations = await dao.relationsForCanonicalUrls(canonicals);
  final byCanonical = <String, List<VisitContainerData>>{};
  for (final relation in relations) {
    (byCanonical[relation.urlCanonical] ??= <VisitContainerData>[]).add(
      relation,
    );
  }

  // Resolve the relation per visit via one-to-one nearest-time matching within
  // each canonical URL group.
  final relationByVisitIndex = <int, VisitContainerData>{};
  for (final MapEntry(key: canonical, value: visitIndices)
      in visitIndicesByCanonical.entries) {
    final candidates = byCanonical[canonical];
    if (candidates == null) continue;

    final pairing = pairVisitsToRelationsByTime(
      [for (final visitIndex in visitIndices) visits[visitIndex].visitTime],
      [for (final candidate in candidates) candidate.visitTime],
    );
    pairing.forEach((localVisitIndex, relationIndex) {
      relationByVisitIndex[visitIndices[localVisitIndex]] =
          candidates[relationIndex];
    });
  }

  final entries = <HistoryEntry>[];
  for (var i = 0; i < visits.length; i++) {
    final relation = relationByVisitIndex[i];

    if (filterContainerId != null &&
        relation?.containerId != filterContainerId) {
      continue;
    }

    entries.add(
      HistoryEntry(
        visit: visits[i],
        containerIds: relation == null ? const [] : [relation.containerId],
        containerRelationId: relation?.id,
      ),
    );
  }

  return entries;
}

@Riverpod()
Future<List<HistoryEntry>> browsingHistory(Ref ref) async {
  final options = ref.watch(historyVisitsFilterProvider);

  final visits = await ref
      .read(historyRepositoryProvider.notifier)
      .getDetailedVisits(options);

  return _annotateVisits(
    ref.read(tabDatabaseProvider).visitContainerDao,
    visits,
    filterContainerId: options.containerId,
  );
}

@Riverpod()
Future<List<HistoryEntry>> browsingDownloads(Ref ref) async {
  final options = ref.watch(historyDownloadsFilterProvider);

  final visits = await ref
      .read(historyRepositoryProvider.notifier)
      .getDetailedVisits(options);

  // Downloads are never recorded in the visit→container relation (it is written
  // only from page-visit `onVisited` events). Do NOT run the nearest-time
  // annotation here: a download sharing a canonical URL + time window with a
  // contained page visit would otherwise steal that visit's tag, show a bogus
  // container chip, and — on delete — drop the page visit's relation row.
  return visits
      .map((visit) => HistoryEntry(visit: visit, containerIds: const []))
      .toList(growable: false);
}
