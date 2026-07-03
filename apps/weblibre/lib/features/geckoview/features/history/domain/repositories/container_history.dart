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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/history/domain/entities/history_entry.dart';
import 'package:weblibre/features/geckoview/features/history/domain/entities/history_filter_options.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/history.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
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
