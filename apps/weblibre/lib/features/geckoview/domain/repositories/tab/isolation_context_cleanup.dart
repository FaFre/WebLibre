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
import 'dart:convert';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_list.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/container_membership_gate.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/storage_owners.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';

part 'isolation_context_cleanup.g.dart';

/// Deleting the data of isolation contexts no tab uses any more, for the tab
/// repository: an isolated tab's context is cleared once its group's last
/// tab is gone, through native's release procedure while the context is
/// restricted (D32 of `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`).
///
/// Contexts are queued ([add]) as their tabs close or their rows go, and
/// cleaned up by [drain] once the rows are gone. One whose cleanup has to
/// wait stays queued for the next [drain].
///
/// The state is the queue, kept across restarts: a context that has to wait
/// (a web app window still uses its storage, or its container is frozen) has
/// no tab row left that would queue it again, and lost with the process, its
/// cookies and site data would stay for good.
@Riverpod(keepAlive: true)
class IsolationContextCleanup extends _$IsolationContextCleanup {
  final _tabsService = GeckoTabService();

  @override
  List<String> build() {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: 'PendingIsolationContextCleanup',
      options: const StorageOptions(cacheTime: StorageCacheTime.unsafe_forever),
      encode: jsonEncode,
      decode: (encoded) =>
          (jsonDecode(encoded) as List<dynamic>).cast<String>(),
    );
    return stateOrNull ?? const [];
  }

  GeckoTabLifecycleService get _tabLifecycle =>
      ref.read(geckoTabLifecycleServiceProvider);

  /// The queued contexts a [drain] is cleaning up right now; a second drain
  /// leaves them to it.
  final _inFlight = <String>{};

  /// Those of [_inFlight] queued again meanwhile: their cleanup checked a
  /// state that is gone, so they stay queued.
  final _requeued = <String>{};

  /// Queues [contextIds], whose tabs closed or whose rows went, for the next
  /// [drain].
  void addAll(Iterable<String> contextIds) {
    final ids = contextIds.toSet();
    _requeued.addAll(ids.where(_inFlight.contains));
    final added = ids.where((id) => !state.contains(id));
    if (added.isNotEmpty) state = [...state, ...added];
  }

  /// Queues [contextId] for the next [drain].
  void add(String contextId) => addAll([contextId]);

  /// Queues the isolation groups of tab rows just deleted, and remembers the
  /// containers of those rows for each ([StorageOwners.rememberDeletedTabs]),
  /// which [drain] forgets again once a group's data is deleted.
  void addDeletedRows(Map<String, Set<String?>> groupContainers) {
    ref
        .read(storageOwnersProvider.notifier)
        .rememberDeletedTabs(groupContainers);
    addAll(groupContainers.keys);
  }

  /// Releases those of [contextIds] no tab uses any more, isolation groups of
  /// a frozen container whose last tab closed while it was frozen: through
  /// the release procedure while their records still restrict them (D32), so
  /// their data is deleted with an acknowledgment before Resume lifts
  /// anything. One whose release native left `releasing` stays restricted,
  /// and native retries it at every start; any other is tried again later.
  ///
  /// Returns whether the Resume may lift: every one of them was released, is
  /// in use again (a tab, or a web app window), which the lift is for, or is
  /// durably `releasing`, which no Resume lifts. False when one of them still
  /// has the phase it was frozen in: a release whose first write failed only
  /// queued it here, and lifted with the container its workers and push
  /// subscriptions would run again with its data still there.
  Future<bool> releaseEmpty(Iterable<String> contextIds) async {
    var liftable = true;
    for (final contextId in contextIds) {
      if (!ref.mounted) return false;
      switch (await _tryCleanUp(contextId, releaseFrozen: true)) {
        case _Cleanup.done:
          break;
        case _Cleanup.inUseByWindow:
          add(contextId);
        case _Cleanup.retry:
          add(contextId);
          liftable = false;
      }
    }
    return liftable;
  }

  /// Cleans up every queued context ([add]) whose cleanup is due, keeping
  /// the ones that have to wait or failed. Runs after every tab list sync,
  /// and again once what held a context up may be over: a freeze or Resume
  /// of its container, the restoring of the frozen containers, or WebLibre
  /// coming back to the front, which is when a web app window it opened has
  /// most likely closed (nothing reports that).
  ///
  /// Each context leaves the queue only once it is done, so a process that
  /// ends during the drain finds it again at the next start.
  Future<void> drain() async {
    final pending = [
      for (final contextId in state)
        if (!_inFlight.contains(contextId)) contextId,
    ];
    if (pending.isEmpty) return;
    _inFlight.addAll(pending);

    try {
      for (final contextId in pending) {
        if (!ref.mounted) return;
        final done = await _tryCleanUp(contextId) == _Cleanup.done;
        if (!ref.mounted) return;
        if (done && !_requeued.contains(contextId)) {
          state = [
            for (final queued in state)
              if (queued != contextId) queued,
          ];
        }
      }
    } finally {
      _inFlight.removeAll(pending);
      _requeued.removeAll(pending);
    }
  }

  /// Whether nothing uses isolation context [contextId] any more: no tab, also
  /// none that has no row yet, and no web app or custom tab window. Its data
  /// is deleted then, at once, or for a group of a frozen container when the
  /// container is resumed ([releaseEmpty]).
  Future<bool> isUnused(String contextId) async =>
      await _usage(contextId) == _Usage.none;

  /// What still uses isolation context [contextId].
  Future<_Usage> _usage(String contextId) async {
    final tabDao = ref.read(tabDatabaseProvider).tabDao;

    // Re-verify count after close (handles concurrent close races)
    final remaining = await tabDao.tabsInIsolationGroup(contextId).getSingle();
    if (remaining > 0) return _Usage.tab;

    // Guard against debounced DB persistence: a sibling tab can already be
    // active in-memory for this context before isolation_context_id is written.
    final activeTabs = ref.read(tabListProvider).value;
    final activeStates = ref.read(tabStatesProvider);
    final hasActiveSibling = activeTabs.any((tabId) {
      final state = activeStates[tabId];
      if (state == null) return false;

      return state.isolationContextId == contextId ||
          state.contextId == contextId;
    });
    if (hasActiveSibling) return _Usage.tabInMemory;

    // A web app or custom tab window opened from the group runs in its
    // storage too, and is no tab: its cookies and site data stay while it is
    // open. Nothing reports its closing.
    final windows = await _tabsService.getCustomTabIdsInContexts([contextId]);
    if (windows.isNotEmpty) return _Usage.window;

    return _Usage.none;
  }

  /// [_cleanUpIfEmpty], [_Cleanup.retry] when it threw: the context is kept
  /// for the next [drain] rather than dropped, its data still there.
  Future<_Cleanup> _tryCleanUp(
    String contextId, {
    bool releaseFrozen = false,
  }) async {
    try {
      return await _cleanUpIfEmpty(contextId, releaseFrozen: releaseFrozen);
    } catch (error, stackTrace) {
      logger.e(
        'Could not clean up isolation context $contextId',
        error: error,
        stackTrace: stackTrace,
      );
      return _Cleanup.retry;
    }
  }

  /// Clears Gecko browsing data and removes proxy alias for an isolation
  /// context if no more tabs share it.
  ///
  /// [_Cleanup.retry] when it has to be tried again (queued): a freeze,
  /// Resume or deletion of its container is running, the frozen containers
  /// are being restored, or its release failed and native keeps no record
  /// that would retry it. Native retries one it left `releasing` at every
  /// start.
  Future<_Cleanup> _cleanUpIfEmpty(
    String contextId, {
    bool releaseFrozen = false,
  }) async {
    switch (await _usage(contextId)) {
      case _Usage.tab:
        return _Cleanup.done;
      case _Usage.tabInMemory:
        logger.i(
          'Skipping isolation cleanup for active context still in memory: '
          '$contextId',
        );
        return _Cleanup.done;
      case _Usage.window:
        // Nothing reports the window's closing, so the context stays queued,
        // also across a restart, until a later drain finds the window gone.
        logger.i(
          'Skipping isolation cleanup for context $contextId: a web app or '
          'custom tab still uses it',
        );
        return _Cleanup.inUseByWindow;
      case _Usage.none:
        break;
    }

    logger.i('Cleaning up isolation context: $contextId');

    // A restricted context is released only through the release procedure,
    // which keeps it restricted until its data is gone with an
    // acknowledgment (D32, F37). Asked of native too when the registry is
    // not known; it releases a context without a record at once.
    final gate = ref.read(containerMembershipGateProvider.notifier);
    await gate.seed();
    // An isolation group of a frozen container stays restricted with it, its
    // data kept, until the container is resumed, which releases it first
    // ([releaseEmpty]): an undo close brings its tab back into the same
    // context, which must still be held then.
    final record = gate.contextRecord(contextId);
    // One of a container being deleted goes with it, or stays restricted
    // with it when the deletion stops (D28): released here meanwhile, a
    // container that stays would have lost its data.
    if (record?.ownerId != null &&
        record!.phase == ContextFreezePhase.deletionPending) {
      logger.i(
        'Isolation context $contextId is cleaned up once the deletion of '
        'container ${record.ownerId} is over',
      );
      return _Cleanup.retry;
    }
    if (!releaseFrozen && record?.ownerId != null) {
      if (settledFreezePhases.contains(record!.phase)) {
        logger.i(
          'Isolation context $contextId stays restricted with frozen '
          'container ${record.ownerId} until it is resumed',
        );
        return _Cleanup.done;
      }
      // What the running operation leaves decides: frozen keeps it, a
      // lifted one is cleaned up as any other.
      if (const {
        ContextFreezePhase.freezing,
        ContextFreezePhase.resuming,
      }.contains(record.phase)) {
        logger.i(
          'Isolation context $contextId is cleaned up once the freeze or '
          'Resume of container ${record.ownerId} is over',
        );
        return _Cleanup.retry;
      }
    }
    // Native releases nothing until the frozen containers are restored.
    if (gate.isInRecovery()) {
      logger.i(
        'Isolation context $contextId is cleaned up once the frozen '
        'containers are restored',
      );
      return _Cleanup.retry;
    }
    var released = true;
    // Whether native deleted the data itself: it releases a context it has a
    // record of through the release procedure, clear acknowledged, and lifts
    // it. Cleared again here, a web app opened in it since that lift would
    // lose its session and what it stored. One without a record it releases
    // at once, and its data is cleared here.
    var clearedByNative = false;
    if (!gate.hasRegistrySnapshot() || gate.isContextRestricted(contextId)) {
      try {
        final results = await _tabLifecycle.releaseContexts([contextId]);
        released = results.every((result) => result.released);
        clearedByNative = results.every((result) => result.dataCleared);
      } catch (e, st) {
        released = false;
        logger.e(
          'Failed to release isolation context $contextId',
          error: e,
          stackTrace: st,
        );
      }
    }
    // Native retries a release it left `releasing` at every start; one it
    // has no record of is retried here.
    var settled = released;
    if (!released) {
      await gate.refresh();
      settled =
          gate.contextRecord(contextId)?.phase == ContextFreezePhase.releasing;
    }

    // Clear Gecko browsing data for this context. Skipped while a release is
    // pending: it stays restricted until the release is done.
    if (released && !clearedByNative) {
      try {
        await ref
            .read(browserDataServiceProvider.notifier)
            .clearDataForContext(contextId);
      } catch (e, st) {
        logger.e(
          'Failed to clear data for isolation context $contextId',
          error: e,
          stackTrace: st,
        );
      }
    } else if (!released) {
      logger.w(
        'Release of isolation context $contextId is pending'
        '${settled ? '' : '; tried again later'}',
      );
    }

    // The alias derived from the group's container needs no teardown: it is
    // computed from the tabs that reference the context, so dropping those tabs
    // removes it from the next routing snapshot. A route the *user* set on the
    // group is stored, though, and would outlive every tab that could use it.
    final outcome = settled ? _Cleanup.done : _Cleanup.retry;
    if (!ref.mounted) return outcome;
    // No page opens in it any more: what was remembered of its last tabs for
    // one is not needed.
    if (settled) ref.read(storageOwnersProvider.notifier).forget(contextId);

    try {
      await ref
          .read(proxyRoutingSettingsRepositoryProvider.notifier)
          .clearIsolationContextRoute(contextId);
    } catch (e, st) {
      logger.e(
        'Failed to drop the isolation route for $contextId',
        error: e,
        stackTrace: st,
      );
    }
    return outcome;
  }
}

/// What still uses an isolation context.
enum _Usage {
  /// A tab with a row.
  tab,

  /// A tab whose row does not name the context yet.
  tabInMemory,

  /// A web app or custom tab window.
  window,

  /// Nothing.
  none,
}

/// How far a context's cleanup got.
enum _Cleanup {
  /// Nothing left to do: cleaned up or released, its release durably
  /// pending in native, held for its frozen container, or used by a tab
  /// again.
  done,

  /// Not cleaned up: a web app or custom tab window still uses its storage.
  inUseByWindow,

  /// Not cleaned up yet, and not durably pending in native either.
  retry,
}
