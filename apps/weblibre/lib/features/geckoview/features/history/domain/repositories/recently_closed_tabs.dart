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

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';

part 'recently_closed_tabs.g.dart';

/// A tab on the recently closed list, with the container it was closed in.
class RecentlyClosedTabEntry {
  final RecentlyClosedTab tab;

  /// Null when it ran outside any container, or [containerDeleted].
  final ContainerData? container;

  /// Whether its container is gone. It then reopens outside any container.
  final bool containerDeleted;

  /// Null for a close WebLibre did not record.
  final DateTime? closedAt;

  const RecentlyClosedTabEntry({
    required this.tab,
    required this.container,
    required this.containerDeleted,
    required this.closedAt,
  });

  Uri? get uri => Uri.tryParse(tab.url);
}

/// How long a closed tab can be undone, after which the engine adds it to the
/// recently closed list (AC's `UndoMiddleware`).
const _undoWindow = Duration(seconds: 5);

/// How long the record of a close the list does not have yet is kept for it.
/// Far longer than [_undoWindow], for an engine whose process was paused.
const _pendingCloseGrace = Duration(minutes: 1);

/// The engine's recently closed list (Fenix's "Recently closed tabs"), newest
/// close first.
@Riverpod()
class RecentlyClosedTabsRepository extends _$RecentlyClosedTabsRepository {
  /// The [service] seam is test-only injection; production always constructs
  /// the default.
  @visibleForTesting
  RecentlyClosedTabsRepository({GeckoRecentlyClosedTabsService? service})
    : _service = service ?? GeckoRecentlyClosedTabsService();

  final GeckoRecentlyClosedTabsService _service;

  @override
  Future<List<RecentlyClosedTabEntry>> build() async {
    final tabDao = ref.read(tabDatabaseProvider).tabDao;
    final containersById = {
      for (final container in await ref.watch(watchContainersProvider.future))
        container.id: container,
    };
    // Watched, not read: the tab list reaches Dart a moment after a close, so
    // the record often arrives after this build, and has to start the refresh
    // below all the same.
    final records = {
      for (final record in await ref.watch(
        watchClosedTabContainersProvider.future,
      ))
        record.tabId: record,
    };

    final tabs = await _service.getTabs();
    final ids = {for (final tab in tabs) tab.id};
    // Also drops the records of closes the list never kept: undone ones, and
    // tabs removed without an undo. Dropping any rebuilds this once more.
    await tabDao.retainClosedTabContainers(
      ids,
      recordedSince: DateTime.now().subtract(_pendingCloseGrace),
    );

    _refreshWhenPendingClosesArrive(
      records.values.where((record) => !ids.contains(record.tabId)),
    );

    RecentlyClosedTabEntry entryFor(RecentlyClosedTab tab) {
      final record = records[tab.id];
      final containerId = record?.containerId;

      return RecentlyClosedTabEntry(
        tab: tab,
        container: containersById[containerId],
        containerDeleted:
            containerId != null && !containersById.containsKey(containerId),
        closedAt: record?.closedAt,
      );
    }

    final entries = [for (final tab in tabs) entryFor(tab)];

    // The engine orders by when a tab was last selected, which puts a
    // background tab closed a moment ago at the bottom. Closes are recorded to
    // the second, so tabs closed together fall back to the engine's order.
    return entries..sort((a, b) {
      final byClose = switch ((a.closedAt, b.closedAt)) {
        (final aClosed?, final bClosed?) => bClosed.compareTo(aClosed),
        (_?, null) => -1,
        (null, _?) => 1,
        (null, null) => 0,
      };
      return byClose != 0
          ? byClose
          : b.tab.lastAccess.compareTo(a.tab.lastAccess);
    });
  }

  /// Reads the list again once the engine has added the tabs of [pending],
  /// closes it does not list yet because they could still be undone. Without
  /// this, tabs closed just before the list was opened would not show up on it.
  void _refreshWhenPendingClosesArrive(
    Iterable<ClosedTabContainerData> pending,
  ) {
    final newest = pending.map((record) => record.closedAt).maxOrNull;
    if (newest == null) return;

    // Two seconds' margin: the record is stored to the second, rounded down,
    // and the engine saves the list a moment after the undo runs out.
    final due = newest
        .add(_undoWindow + const Duration(seconds: 2))
        .difference(DateTime.now());
    // An older one was undone, or was a close the list never keeps.
    if (due.isNegative) return;

    final timer = Timer(due, ref.invalidateSelf);
    ref.onDispose(timer.cancel);
  }

  /// Reopens [entry] with its back history; see
  /// [TabRepository.restoreClosedTab].
  Future<String?> restore(
    RecentlyClosedTabEntry entry, {
    required bool selectTab,
  }) async {
    final tabId = await ref
        .read(tabRepositoryProvider.notifier)
        .restoreClosedTab(entry.tab, selectTab: selectTab);
    if (ref.mounted) ref.invalidateSelf();
    return tabId;
  }

  Future<void> remove(RecentlyClosedTabEntry entry) async {
    await _service.remove(entry.tab.id);
    await ref.read(tabDatabaseProvider).tabDao.deleteClosedTabContainers([
      entry.tab.id,
    ]);
    if (ref.mounted) ref.invalidateSelf();
  }

  Future<void> removeAll() async {
    await _service.removeAll();
    await ref
        .read(tabDatabaseProvider)
        .tabDao
        .retainClosedTabContainers(const []);
    if (ref.mounted) ref.invalidateSelf();
  }
}
