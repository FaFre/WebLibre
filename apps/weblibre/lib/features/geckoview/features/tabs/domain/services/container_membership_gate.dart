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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_freeze.dart';
import 'package:weblibre/utils/lru_cache.dart';

part 'container_membership_gate.g.dart';

/// What a change does to a container's membership.
enum ContainerChange {
  /// A regular tab joins it (opened, duplicated or restored into it). Allowed
  /// into a frozen container: the tab runs in the container's context, which
  /// holds it until Resume.
  addition,

  /// A tab moves in or out, an isolated tab is created in it (its own
  /// context would be outside the freeze), or its storage identity changes.
  /// Refused while the container is restricted.
  membership,
}

/// One deletion in flight.
class _Deletion {
  final finished = Completer<void>();

  /// Tabs the engine opened from the container's pages meanwhile, refused
  /// by [ContainerMembershipGate.whileChanging].
  final openedTabIds = <String>{};
}

/// Coordinates operations that change which tabs belong to a container with
/// the operations that need that membership to hold still: deleting a
/// container, and freezing or resuming one (5.7 of the tab lock and freeze
/// plan).
///
/// **Deletion.** Every operation that adds a tab to a
/// container, restores one into it or moves one in or out holds a **change**
/// reservation on it from its decision until its row is written
/// ([whileChanging]). A deletion takes a **deleting** reservation
/// ([whileDeleting]) only while no change is in flight, and while it holds
/// one no change can start. So no tab can join a container after its deletion
/// read the members, and lose its row to the cascade: a check before the
/// addition would not do, since the addition goes on after it.
///
/// **Freeze** (D19, D21, D27). The gate knows which containers native
/// restricts from a revisioned snapshot of native's registry
/// ([GeckoTabLifecycleService.lifecycleSnapshot]), read before it decides
/// anything ([seed]), and a freeze or Resume holds an **operation**
/// reservation on its container while it runs ([whileOperating]). A container
/// is restricted while the snapshot says so, while an operation holds it, or
/// while native is in recovery mode (every container then). Changes of kind
/// [ContainerChange.membership] are refused for a restricted container
/// ([ContainerFrozenException]); regular additions are not. When an operation
/// ends, the gate reads a fresh snapshot, while the reservation still holds
/// the container; if that read fails, every container counts as restricted
/// until a read succeeds. Native's own changes (a background relift, a
/// release, the start-time reconciliation) arrive as snapshots on
/// [GeckoEventService.contextFreezeEvents]. Every snapshot, read or reported,
/// is taken only when its revision is not older than the one held, so a
/// delayed one cannot undo a newer Resume or freeze. Operation replies never
/// set the gate's state.
///
/// A deletion refuses rather than waits, and a change nested in another's
/// reservation (a move that reopens the tab with `addTab`) passes: the outer
/// reservation already keeps the deletion from starting.
///
/// Two kinds of change cannot simply be refused:
///
/// - A tab the engine opened by itself from one of the container's pages (a
///   popup) exists already. Its refusal is recorded ([whileChanging]'s
///   `openedTabId`), the deletion closes it with the container's own tabs
///   ([tabsOpenedDuringDeletion]), and its owner settles what is left once
///   the deletion is over ([deletionFinished]).
///   Its own windows, and any window whose opener's row is gone by the time
///   the engine reports it, belong to the container as well: the gate keeps
///   the tabs a deletion took or refused ([deletionLineageOf]), so that the
///   tab repository can file them with it.
/// - An undo close restores tabs whose containers are known only once they
///   are back. It holds off every deletion ([whileChangingAnywhere]) until
///   their rows are written, and a Resume's release of isolation groups
///   ([whileReleasing]) with it: neither starts while the other runs.
///
/// Lock order, everywhere: this gate first, then the tab repository's close
/// lock. The gate's decisions are synchronous and never wait on the engine,
/// so a slow or hung engine call cannot hold up another decision.
@Riverpod(keepAlive: true)
class ContainerMembershipGate extends _$ContainerMembershipGate {
  final _deletions = <String, _Deletion>{};

  /// In-flight changes per container.
  final _changes = <String, int>{};

  /// In-flight changes that may touch any container.
  int _changesAnywhere = 0;

  /// Isolation group releases of Resumes in flight ([whileReleasing]).
  int _releases = 0;

  /// Tabs a deletion took (its members) or refused (windows its pages opened),
  /// with the container; the 1000 recorded last. Their rows no longer say so:
  /// refused into no container, or gone with the container.
  final _deletionLineage = LRUCache<String, String>(1000);

  /// Freezes and Resumes running, per container.
  final _operations = <String, int>{};

  /// Native's registry as last read; null until [seed] succeeded.
  LifecycleSnapshot? _snapshot;

  /// Whether [_snapshot] may be behind native: the read after an operation
  /// failed, so a freeze it ran may be missing. Every container counts as
  /// restricted then, and the next [seed] reads again.
  bool _stale = false;

  /// The read [seed] is waiting for, shared by every decision meanwhile.
  Future<void>? _seeding;

  /// The containers [_snapshot]'s records hold, by native's account
  /// ([OwnerFreezeState]): not one that only has an isolation group whose
  /// release did not finish.
  Map<String, OwnerFreezeState> _restrictedOwners = const {};

  GeckoTabLifecycleService get _lifecycle =>
      ref.read(geckoTabLifecycleServiceProvider);

  /// Reads native's registry before the gate decides anything, once it
  /// succeeded and since the last one failed. A failure is not remembered:
  /// the next decision tries again, and treats every container as restricted
  /// meanwhile (fail closed).
  Future<void> seed() {
    if (_snapshot != null && !_stale) return Future.value();
    return _seeding ??= refresh().whenComplete(() => _seeding = null);
  }

  /// Reads native's registry now, and takes it unless it is older than the
  /// one held. A read that fails leaves the gate [_stale].
  Future<void> refresh() async {
    try {
      _adopt(await _lifecycle.lifecycleSnapshot());
      _stale = false;
    } catch (error, stackTrace) {
      _stale = true;
      logger.e(
        'Could not read the container freeze registry; treating every '
        'container as frozen',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Takes [snapshot] unless it is older than the one held.
  void _adopt(LifecycleSnapshot snapshot) {
    final current = _snapshot;
    if (current != null && snapshot.revision < current.revision) return;
    _snapshot = snapshot;
    _restrictedOwners = {
      for (final owner in snapshot.owners) owner.ownerId: owner,
    };
  }

  /// Takes the snapshot native returned from the startup reconciliation or
  /// reconstruction (5.5, 5.6). Until it arrives, decisions go by the
  /// snapshot held.
  void adoptStartupSnapshot(LifecycleSnapshot snapshot) {
    _adopt(snapshot);
    _stale = false;
  }

  /// Whether [containerId] is restricted as far as membership is concerned:
  /// frozen in some phase, being frozen or resumed, or in recovery. Also true
  /// while the registry could not be read. Null, the unassigned tabs, never
  /// is.
  bool isRestricted(String? containerId) {
    if (containerId == null) return false;
    final snapshot = _snapshot;
    if (snapshot == null || _stale) return true;
    return snapshot.mode == LifecycleRegistryMode.recovery ||
        _restrictedOwners.containsKey(containerId) ||
        _operations.containsKey(containerId);
  }

  /// Whether the last snapshot says [containerId] is restricted (frozen in
  /// some phase, or every container in recovery). False while no snapshot
  /// was read, or the last read failed: unlike [isRestricted], for decisions
  /// that must not loosen anything on a guess, such as skipping a routing
  /// check.
  bool isFrozen(String? containerId) {
    final snapshot = _snapshot;
    if (containerId == null || snapshot == null || _stale) return false;
    return snapshot.mode == LifecycleRegistryMode.recovery ||
        _restrictedOwners.containsKey(containerId);
  }

  /// Whether the last snapshot says [contextId] is restricted: a record of
  /// its own, or recovery. False while no snapshot was read, or the last
  /// read failed ([hasRegistrySnapshot]).
  bool isContextRestricted(String contextId) {
    final snapshot = _snapshot;
    if (snapshot == null || _stale) return false;
    return snapshot.mode == LifecycleRegistryMode.recovery ||
        contextRecord(contextId) != null;
  }

  /// [contextId]'s record in the last snapshot; null without one, or while
  /// no snapshot was read.
  ContextFreezeState? contextRecord(String contextId) => _snapshot?.contexts
      .firstWhereOrNull((context) => context.contextId == contextId);

  /// The contexts whose records in the last snapshot hold [containerId]
  /// ([isFrozen]); unlike [contextsOwnedBy], not one only waiting for its
  /// data to be deleted.
  List<String> contextsHolding(String containerId) =>
      _restrictedOwners[containerId]?.contextIds ?? const [];

  /// The contexts the last snapshot records for [containerId], in any phase.
  List<String> contextsOwnedBy(String containerId) => [
    for (final context in _snapshot?.contexts ?? const <ContextFreezeState>[])
      if (context.ownerId == containerId) context.contextId,
  ];

  /// Whether a snapshot of native's registry was read, and the last read did
  /// not fail since.
  bool hasRegistrySnapshot() => _snapshot != null && !_stale;

  /// The containers with a context in [phase], as of the last snapshot.
  Set<String> ownersInPhase(ContextFreezePhase phase) => {
    for (final context in _snapshot?.contexts ?? const <ContextFreezeState>[])
      if (context.phase == phase) ?context.ownerId,
  };

  /// Whether native is in recovery mode (D23), as of the last snapshot.
  bool isInRecovery() => _snapshot?.mode == LifecycleRegistryMode.recovery;

  /// Runs [operation], a freeze or Resume of [containerId], holding an
  /// operation reservation on it, then reads a fresh snapshot. Returns null
  /// without running it while the container is being deleted, while a
  /// membership change of it is in flight, or, unless [concurrentWithOthers],
  /// while another operation on it runs (a second freeze is ignored, 5.4). A
  /// Resume passes [concurrentWithOthers]: it is how "Stop freezing and
  /// resume" reaches a running freeze.
  Future<T?> whileOperating<T>(
    String containerId,
    Future<T> Function() operation, {
    bool concurrentWithOthers = false,
  }) async {
    await seed();
    if (_deletions.containsKey(containerId) ||
        _changes.containsKey(containerId) ||
        _changesAnywhere > 0 ||
        (!concurrentWithOthers && _operations.containsKey(containerId))) {
      return null;
    }
    _acquire(_operations, containerId);

    try {
      return await operation();
    } finally {
      // Read while the reservation still holds the container, so no change
      // gets in between the reservation's end and the fresh snapshot.
      await refresh();
      _release(_operations, containerId);
    }
  }

  /// How many freezes and Resumes of [containerId] hold an operation
  /// reservation ([whileOperating]) right now, the caller's own included.
  int operationsOn(String containerId) => _operations[containerId] ?? 0;

  /// Counts one more reservation of [id] in [reservations].
  static void _acquire(Map<String, int> reservations, String id) =>
      reservations.update(id, (count) => count + 1, ifAbsent: () => 1);

  /// Counts one reservation of [id] in [reservations] less; none left drops
  /// it.
  static void _release(Map<String, int> reservations, String id) {
    final count = reservations[id]! - 1;
    if (count == 0) {
      reservations.remove(id);
    } else {
      reservations[id] = count;
    }
  }

  void _rememberLineage(String tabId, String containerId) =>
      _deletionLineage.set(tabId, containerId);

  /// Runs [change], which adds, restores or moves tabs into or out of
  /// [containerIds], holding a change reservation on each of them. Null ids,
  /// the unassigned tabs, need none.
  ///
  /// Throws [ContainerBeingDeletedException], running nothing, when one of
  /// them is being deleted. An automatic change is dropped with it rather than
  /// redirected: another container would route the page differently.
  ///
  /// A change of kind [ContainerChange.membership] also throws
  /// [ContainerFrozenException] for a restricted container (D19).
  ///
  /// [openedTabId] names a tab the engine already opened from one of the
  /// container's pages. On a refusal it is recorded for the deletion to close
  /// (see the class documentation).
  Future<T> whileChanging<T>(
    Iterable<String?> containerIds,
    Future<T> Function() change, {
    String? openedTabId,
    ContainerChange kind = ContainerChange.addition,
  }) async {
    final ids = containerIds.nonNulls.toSet();
    if (ids.isEmpty) return await change();

    if (kind == ContainerChange.membership) await seed();
    for (final id in ids) {
      final deletion = _deletions[id];
      if (deletion != null) {
        if (openedTabId != null) {
          deletion.openedTabIds.add(openedTabId);
          _rememberLineage(openedTabId, id);
        }
        throw ContainerBeingDeletedException(id);
      }
    }
    if (kind == ContainerChange.membership) {
      for (final id in ids) {
        if (isRestricted(id)) throw ContainerFrozenException(id);
      }
    }
    for (final id in ids) {
      _acquire(_changes, id);
    }

    try {
      return await change();
    } finally {
      for (final id in ids) {
        _release(_changes, id);
      }
    }
  }

  /// Runs [change] holding off every deletion, for a change whose containers
  /// are known only once it is done. Returns null without running it while a
  /// deletion is in flight, or while a Resume releases isolation groups
  /// ([whileReleasing]).
  Future<T?> whileChangingAnywhere<T>(Future<T> Function() change) async {
    if (_deletions.isNotEmpty || _releases > 0) return null;
    _changesAnywhere++;

    try {
      return await change();
    } finally {
      _changesAnywhere--;
    }
  }

  /// Runs [release], a Resume deleting the data of isolation groups whose
  /// last tab closed while their container was frozen (D32), while no change
  /// of unknown containers runs ([whileChangingAnywhere]); returns null
  /// without running it while one does. An undo close restores tabs into
  /// the storage they were closed in, and its check that the freeze still
  /// holds that storage would pass for a group whose release has not been
  /// recorded yet: back meanwhile, its tab would lose its site data. The
  /// Resume already holds its container ([whileOperating]).
  Future<T?> whileReleasing<T>(Future<T> Function() release) async {
    if (_changesAnywhere > 0) return null;
    _releases++;

    try {
      return await release();
    } finally {
      _releases--;
    }
  }

  /// Runs [delete] holding a deleting reservation on [containerId], or
  /// returns null without running it while another deletion of it, a change
  /// to it, or a freeze or Resume of it is in flight (D35).
  Future<T?> whileDeleting<T>(
    String containerId,
    Future<T> Function() delete,
  ) async {
    if (_changes.containsKey(containerId) ||
        _changesAnywhere > 0 ||
        _operations.containsKey(containerId) ||
        _deletions.containsKey(containerId)) {
      return null;
    }
    final deletion = _deletions[containerId] = _Deletion();

    try {
      return await delete();
    } finally {
      _deletions.remove(containerId);
      deletion.finished.complete();
    }
  }

  /// The tabs the engine opened from [containerId]'s pages since its deletion
  /// started, which that deletion closes with the container's own tabs.
  Set<String> tabsOpenedDuringDeletion(String containerId) => {
    ...?_deletions[containerId]?.openedTabIds,
  };

  /// Records [tabIds] as taken by the deletion of [containerId], before it
  /// closes them: a window one of them opens, reported after its row went
  /// with the container, belongs to the container too.
  void recordDeletionMembers(String containerId, Iterable<String> tabIds) {
    for (final tabId in tabIds) {
      _rememberLineage(tabId, containerId);
    }
  }

  /// Records [tabId], a window opened from a tab of [containerId] whose own
  /// row no longer says so, for the deletion of [containerId] if one is in
  /// flight (it closes it with the container's tabs) and for the windows it
  /// opens in turn.
  void recordOpenedFrom(String containerId, String tabId) {
    _rememberLineage(tabId, containerId);
    _deletions[containerId]?.openedTabIds.add(tabId);
  }

  /// The container whose deletion took or refused [tabId], or that [tabId]
  /// was opened from by such a tab; null for any other tab. It may no longer
  /// exist, and a deletion that was refused leaves it in place.
  String? deletionLineageOf(String tabId) => _deletionLineage.peek(tabId);

  /// Completes once [containerId] is not being deleted.
  Future<void> deletionFinished(String containerId) =>
      _deletions[containerId]?.finished.future ?? Future.value();

  /// Whether [containerId] is being deleted. Null, the unassigned tabs, never
  /// is.
  bool isBeingDeleted(String? containerId) =>
      containerId != null && _deletions.containsKey(containerId);

  @override
  void build() {
    final snapshots = ref
        .watch(eventServiceProvider)
        .contextFreezeEvents
        .listen(_adopt);
    ref.onDispose(snapshots.cancel);
  }
}
