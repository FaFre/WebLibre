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

import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/history/domain/entities/history_entry.dart';
import 'package:weblibre/features/geckoview/features/history/domain/entities/history_filter_options.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/history.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/visit_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/local_index_pruner.dart';
import 'package:weblibre/utils/url_canonical.dart';

part 'container_history.g.dart';

/// Mutations that combine the visit→container relation (`visit_container`) with
/// Mozilla Places, the source of truth for the visits themselves.
@Riverpod(keepAlive: true)
class ContainerHistoryRepository extends _$ContainerHistoryRepository {
  /// Delete a single history entry: remove the Places visit precisely by its own
  /// `(url, time)`, then drop the `visit_container` relation row that tagged it.
  ///
  /// Dropping the relation matters: left behind, the nearest-time join in
  /// `_annotateVisits` could reattach that now-orphaned tag to a *different*
  /// same-URL visit within [historyVisitContainerMatchWindowMs], mislabeling an
  /// uncontained (or different-container) visit. We delete exactly the relation
  /// the annotation paired with this visit — carried on the entry as
  /// [HistoryEntry.containerRelationId] — rather than re-deriving "the nearest
  /// relation", which greedy one-to-one pairing may have assigned to a sibling
  /// same-URL visit (deleting that would strip the sibling's tag and leave this
  /// visit's real relation dangling).
  Future<void> deleteVisit(HistoryEntry entry) async {
    await ref.read(historyRepositoryProvider.notifier).deleteVisit(entry.visit);

    final relationId = entry.containerRelationId;
    if (relationId == null) return;

    await ref
        .read(tabDatabaseProvider)
        .visitContainerDao
        .deleteById(relationId);
  }

  /// Delete everything the history screen lists between [start] and [end]
  /// (inclusive), in all containers: the Places visits, their container tags
  /// and the download list entries created in the range. Downloaded files are
  /// kept.
  ///
  /// Local index rows whose URL has no visit left are pruned in the
  /// background, as after the automatic history clean-up.
  Future<void> deleteVisitsBetween(DateTime start, DateTime end) async {
    final history = ref.read(historyRepositoryProvider.notifier);

    final relationIds = await _relationIdsForVisitsBetween(
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
    );

    await history.deleteVisitsBetween(start, end);
    // The download list is the engine's download store, not Places, so the
    // range delete above doesn't reach it.
    await history.deleteDownloadsBetween(start, end);
    await ref
        .read(tabDatabaseProvider)
        .visitContainerDao
        .deleteByIds(relationIds);

    unawaited(ref.read(localIndexPrunerProvider.notifier).prune());
  }

  /// The relation rows that belong to the visits between [startMillis] and
  /// [endMillis]: the ones the timeline pairs with those page visits, and the
  /// ones stamped in or near the range that pair with no visit at all.
  ///
  /// Found by pairing, not by the rows' own `visit_time`: that time is stamped
  /// near, not at, the Places visit time, so near a boundary a deleted visit's
  /// tag can lie outside the range and a surviving visit's tag inside it.
  ///
  /// The second kind covers visits Places hides from [getDetailedVisits]
  /// (redirect hops, framed and embedded loads), which the range delete removes
  /// all the same: the recorder tags them like any other visit. Their times
  /// can't be read back, and a tag can be stamped up to a match window from its
  /// visit, across a boundary. So every row stamped within a window of the
  /// range that no loaded visit takes goes: such a row changes nothing the
  /// timeline shows, and left behind it could tag a later visit of the URL.
  /// The cost is that a hidden visit just outside the range may lose its tag;
  /// the timeline never shows it either way.
  ///
  /// The visit query widens until it holds every visit that can influence
  /// these pairs ([pairingDependencyWindow]); usually the first query does.
  Future<List<int>> _relationIdsForVisitsBetween(
    int startMillis,
    int endMillis,
  ) async {
    final history = ref.read(historyRepositoryProvider.notifier);
    final dao = ref.read(tabDatabaseProvider).visitContainerDao;
    bool inRange(int time) => time >= startMillis && time <= endMillis;

    const window = historyVisitContainerMatchWindowMs;
    bool nearRange(int time) =>
        time >= startMillis - window && time <= endMillis + window;

    final canonicalsTaggedNearRange = {
      for (final relation in await dao.relationsBetween(
        startMillis - window,
        endMillis + window,
      ))
        relation.urlCanonical,
    };

    var lower = startMillis - window;
    var upper = endMillis + window;
    while (true) {
      final visits = await history.getDetailedVisits(
        HistoryFilterOptions(
          dateRange: DateTimeRange(
            start: DateTime.fromMillisecondsSinceEpoch(lower),
            end: DateTime.fromMillisecondsSinceEpoch(upper),
          ),
          // Tags are only ever recorded for page visits.
          visitTypes: VisitType.values
              .where((type) => type != VisitType.download)
              .toSet(),
        ),
      );

      final visitsByCanonical = <String, List<VisitInfo>>{
        for (final canonical in canonicalsTaggedNearRange)
          canonical: <VisitInfo>[],
      };
      for (final visit in visits) {
        final canonical = canonicalizeUrl(visit.url)?.canonical;
        if (canonical != null) {
          (visitsByCanonical[canonical] ??= <VisitInfo>[]).add(visit);
        }
      }
      visitsByCanonical.removeWhere(
        (canonical, visits) =>
            !canonicalsTaggedNearRange.contains(canonical) &&
            !visits.any((visit) => inRange(visit.visitTime)),
      );

      final relationsByCanonical = <String, List<VisitContainerData>>{};
      for (final relation in await dao.relationsForCanonicalUrls(
        visitsByCanonical.keys.toSet(),
      )) {
        (relationsByCanonical[relation.urlCanonical] ??= <VisitContainerData>[])
            .add(relation);
      }

      var neededLower = lower;
      var neededUpper = upper;
      for (final MapEntry(key: canonical, value: candidates)
          in visitsByCanonical.entries) {
        final dependencies = pairingDependencyWindow(
          visitTimes: [for (final visit in candidates) visit.visitTime],
          relationTimes: [
            for (final relation
                in relationsByCanonical[canonical] ??
                    const <VisitContainerData>[])
              relation.visitTime,
          ],
          rangeStart: startMillis,
          rangeEnd: endMillis,
          relationMargin: window,
        );
        if (dependencies == null) continue;
        if (dependencies.start < neededLower) {
          neededLower = dependencies.start;
        }
        if (dependencies.end > neededUpper) neededUpper = dependencies.end;
      }
      if (neededLower < lower || neededUpper > upper) {
        lower = neededLower;
        upper = neededUpper;
        continue;
      }

      final ids = <int>[];
      for (final MapEntry(key: canonical, value: candidates)
          in visitsByCanonical.entries) {
        final relations = relationsByCanonical[canonical];
        if (relations == null) continue;

        final pairing = pairVisitsToRelationsByTime(
          [for (final visit in candidates) visit.visitTime],
          [for (final relation in relations) relation.visitTime],
        );
        final paired = pairing.values.toSet();
        pairing.forEach((visitIndex, relationIndex) {
          if (inRange(candidates[visitIndex].visitTime)) {
            ids.add(relations[relationIndex].id);
          }
        });
        for (var index = 0; index < relations.length; index++) {
          if (!paired.contains(index) &&
              nearRange(relations[index].visitTime)) {
            ids.add(relations[index].id);
          }
        }
      }
      return ids;
    }
  }

  /// Clear a container's history: delete the container's Places visits, then
  /// remove its relation rows.
  Future<void> deleteContainerHistory(String containerId) async {
    await deletePlacesVisitsForContainer(containerId);
    await ref
        .read(tabDatabaseProvider)
        .visitContainerDao
        .deleteForContainer(containerId);
  }

  /// Delete from Mozilla Places exactly the visits recorded for [containerId] in
  /// the relation, matched by canonical URL and nearest time. Only visits that
  /// have a relation row are touched — uncontained Places visits (including of
  /// the same URL) are never deleted. Leaves the relation rows in place; callers
  /// remove them separately (explicit clear) or let ON DELETE CASCADE do it
  /// (container deletion). Safe to call before the container itself is deleted.
  Future<void> deletePlacesVisitsForContainer(String containerId) async {
    final relations = await ref
        .read(tabDatabaseProvider)
        .visitContainerDao
        .relationsForContainer(containerId);
    if (relations.isEmpty) return;

    var minTime = relations.first.visitTime;
    var maxTime = relations.first.visitTime;
    for (final relation in relations) {
      if (relation.visitTime < minTime) minTime = relation.visitTime;
      if (relation.visitTime > maxTime) maxTime = relation.visitTime;
    }

    final visits = await ref
        .read(historyRepositoryProvider.notifier)
        .getDetailedVisits(
          HistoryFilterOptions(
            dateRange: DateTimeRange(
              start: DateTime.fromMillisecondsSinceEpoch(
                minTime - historyVisitContainerMatchWindowMs,
              ),
              end: DateTime.fromMillisecondsSinceEpoch(
                maxTime + historyVisitContainerMatchWindowMs,
              ),
            ),
            // Relations are only ever recorded for page visits (onVisited), so
            // never let a download that merely shares a canonical URL + time
            // window become a delete candidate — it would delete an unrelated
            // download (and deleteVisit routes downloads to
            // deleteDownload(contentId!), which throws on a null contentId).
            visitTypes: VisitType.values
                .where((type) => type != VisitType.download)
                .toSet(),
          ),
        );

    // Index candidate Places visits by canonical URL for nearest-time matching.
    final visitsByCanonical = <String, List<VisitInfo>>{};
    for (final visit in visits) {
      final canonical = canonicalizeUrl(visit.url)?.canonical;
      if (canonical != null) {
        (visitsByCanonical[canonical] ??= <VisitInfo>[]).add(visit);
      }
    }

    final relationsByCanonical = <String, List<VisitContainerData>>{};
    for (final relation in relations) {
      (relationsByCanonical[relation.urlCanonical] ??= <VisitContainerData>[])
          .add(relation);
    }

    // Collect matched Places visits using the same one-to-one nearest-time
    // strategy as history annotation, so two relation rows never consume the
    // same Places row and leave a sibling visit behind.
    final toDelete = <(String, int), VisitInfo>{};
    for (final MapEntry(key: canonical, value: candidates)
        in visitsByCanonical.entries) {
      final canonicalRelations = relationsByCanonical[canonical];
      if (canonicalRelations == null) continue;

      final pairing = pairVisitsToRelationsByTime(
        [for (final visit in candidates) visit.visitTime],
        [for (final relation in canonicalRelations) relation.visitTime],
      );
      for (final visitIndex in pairing.keys) {
        final visit = candidates[visitIndex];
        toDelete[(visit.url, visit.visitTime)] = visit;
      }
    }

    final historyRepository = ref.read(historyRepositoryProvider.notifier);
    for (final visit in toDelete.values) {
      await historyRepository.deleteVisit(visit);
    }
  }

  @override
  void build() {}
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
Future<List<HistoryEntry>> annotateVisitsWithContainers(
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
