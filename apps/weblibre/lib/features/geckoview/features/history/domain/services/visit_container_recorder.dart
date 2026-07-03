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

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/utils/url_canonical.dart';

part 'visit_container_recorder.g.dart';

class _HistoryEventsReceiver extends GeckoHistoryEvents {
  _HistoryEventsReceiver(this._onVisit);

  final void Function(String url, int visitTime, String? contextId) _onVisit;

  @override
  void onVisitRecorded(String url, int visitTime, String? contextId) {
    _onVisit(url, visitTime, contextId);
  }
}

/// Records the visit→container relation. Mozilla Places owns the visit itself;
/// on each Places visit the native [WebLibreHistoryDelegate] forwards the
/// producing tab's Gecko contextId, which this service maps to a WebLibre
/// container and persists as a `visit_container` row (keyed on the visit's
/// canonical URL + time so the history UI can join it back to Places).
///
/// Graceful absence: a visit that resolves to no container — uncontained, or a
/// container without a Gecko contextId (cookie isolation off) — writes no row
/// and simply appears untagged. Activated eagerly at startup.
@Riverpod(keepAlive: true)
class VisitContainerRecorder extends _$VisitContainerRecorder {
  @override
  void build() {
    // Cache contextId → container id so each visit event is an O(1) lookup
    // instead of a linear scan of all containers. Kept fresh via ref.listen.
    final contextIdToContainerId = <String, String>{};
    void applyContainers(Iterable<ContainerDataWithCount>? containers) {
      contextIdToContainerId.clear();
      if (containers != null) {
        for (final container in containers) {
          final contextId = container.metadata.contextualIdentity;
          if (contextId != null) {
            contextIdToContainerId[contextId] = container.id;
          }
        }
      }
    }

    // Seed from the stream's current value (may still be empty during startup —
    // watchContainersWithCount is async and often hasn't emitted yet) and keep
    // it fresh on every change.
    applyContainers(ref.read(watchContainersWithCountProvider).value);
    ref.listen(
      watchContainersWithCountProvider,
      (_, next) => applyContainers(next.value),
    );

    Future<void> recordVisit(
      String url,
      int visitTime,
      String contextId,
    ) async {
      var containerId = contextIdToContainerId[contextId];

      // Empty cache means the container stream hasn't emitted yet (the startup
      // window — restored tabs can fire visits before the first emission). A
      // visit carrying a contextId implies a container with that contextId
      // exists, so pull the containers directly rather than dropping the visit
      // permanently. A genuine miss (deleted container) leaves the cache
      // non-empty, so this fallback does not fire repeatedly in steady state.
      if (containerId == null && contextIdToContainerId.isEmpty) {
        applyContainers(await ref.read(watchContainersWithCountProvider.future));
        containerId = contextIdToContainerId[contextId];
      }

      // Resolved to a contextId that maps to no known container (deleted or not
      // yet synced) → skip rather than write a dangling relation.
      if (containerId == null) return;

      final canonical = canonicalizeUrl(url);
      if (canonical == null) return;

      await ref
          .read(tabDatabaseProvider)
          .visitContainerDao
          .insertRelation(
            rawUrl: url,
            urlCanonical: canonical.canonical,
            visitTime: visitTime,
            containerId: containerId,
          );
    }

    final receiver = _HistoryEventsReceiver((url, visitTime, contextId) {
      // No contextId (uncontained / non-isolated / unresolved) → no relation.
      if (contextId == null) return;

      unawaited(recordVisit(url, visitTime, contextId));
    });

    GeckoHistoryEvents.setUp(receiver);
    ref.onDispose(() => GeckoHistoryEvents.setUp(null));
  }
}
