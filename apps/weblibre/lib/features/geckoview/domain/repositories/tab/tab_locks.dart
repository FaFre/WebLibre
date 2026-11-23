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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_lock.dart';
import 'package:weblibre/features/geckoview/domain/providers/restore_complete.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/providers/unlock_incomplete_tabs.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab/tab_close_lock.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';

part 'tab_locks.g.dart';

/// The tab lock protocol of the tab repository (L1, L2 of
/// `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`): a locked tab refuses
/// to close and is skipped by every bulk close until it is unlocked.
///
/// The lock lives in the database (what the user asked for) and natively
/// (what the engine enforces), and native's set always contains the
/// database's. So a lock goes native first, then the database, and an unlock
/// the other way round. A step that fails leaves the tab more locked, never
/// less, and [reconcile] repairs that from the database.
///
/// Every method but [isLocked], a read for choosing what to offer, runs
/// under the close lock ([tabCloseLockProvider]), which this does not take
/// itself: no close can fall between a lock's two writes, and a close's
/// preflight ([lockedAmong]) cannot disagree with native's removal.
@Riverpod(keepAlive: true)
class TabLocks extends _$TabLocks {
  /// Native's copy of the tab locks.
  final _native = GeckoTabLockService();

  /// Native may hold a lock the database does not: a revert or an unlock did
  /// not reach it, or the preflight saw one. Cleared by [reconcile], which
  /// runs at the end of the close lock section that set it.
  bool _reconcileDue = false;

  @override
  void build() {}

  /// For the asserts: past disposal there is nothing left to guard.
  bool get _closeLockHeld =>
      !ref.mounted || ref.read(tabCloseLockProvider).locked;

  /// A close found a lock only native holds ([lockedAmong]'s `nativeOnly`):
  /// an unlock that did not finish, which [reconcileIfDue] completes.
  void markReconcileDue() {
    assert(_closeLockHeld, 'Runs under the close lock');
    _reconcileDue = true;
  }

  /// Which of [requested] are locked, by the database's locks and native's
  /// together: the lock protocol lets native hold a lock the database does
  /// not (a failed unlock or revert), never the other way round.
  /// [nativeOnly] when one of them is such a lock. Throws
  /// [TabLocksUnavailableException] when either set could not be read, and a
  /// reconciliation is due then.
  ///
  /// Private tabs are never asked about: they cannot be locked ([setLocked]),
  /// so closing only private tabs, as Quit does, works even while native's
  /// locks cannot be read.
  Future<({Set<String> locked, bool nativeOnly})> lockedAmong(
    List<String> requested,
  ) async {
    assert(_closeLockHeld, 'Runs under the close lock');
    final states = ref.read(tabStatesProvider);
    final ids = [
      for (final id in requested)
        if (states[id]?.tabMode is! PrivateTabMode) id,
    ];
    if (ids.isEmpty) return (locked: const <String>{}, nativeOnly: false);
    final Set<String> dbLocked;
    final Set<String> nativeLocked;
    try {
      // Both at once: every close waits for this.
      (dbLocked, nativeLocked) = await (
        ref.read(tabDatabaseProvider).tabDao.lockedTabIdsAmong(ids),
        _native.lockedTabIdsAmong(ids),
      ).wait;
    } catch (error, stackTrace) {
      _reconcileDue = true;
      throw TabLocksUnavailableException(error, stackTrace);
    }
    return (
      locked: {...dbLocked, ...nativeLocked},
      nativeOnly: nativeLocked.difference(dbLocked).isNotEmpty,
    );
  }

  /// Locks or unlocks [tabId], then completes what that left native holding
  /// ([reconcileIfDue]).
  Future<TabLockOutcome> setLocked(String tabId, {required bool locked}) async {
    assert(_closeLockHeld, 'Runs under the close lock');
    final outcome = locked ? await _lock(tabId) : await _unlock(tabId);
    await reconcileIfDue();

    // The reconciliation may have finished an unlock that native refused.
    if (outcome == TabLockOutcome.unlockIncomplete &&
        ref.mounted &&
        !ref.read(unlockIncompleteTabsProvider).value.contains(tabId)) {
      return TabLockOutcome.applied;
    }
    return outcome;
  }

  Future<TabLockOutcome> _lock(String tabId) async {
    final tabDao = ref.read(tabDatabaseProvider).tabDao;

    // Refused up front; native and the table's CHECK refuse it as well.
    final mode = await tabDao.getTabMode(tabId).getSingleOrNull();
    if (mode is PrivateTabMode) return TabLockOutcome.privateTab;

    final TabLockChange change;
    try {
      change = await _native.setTabLocked(tabId, locked: true);
    } catch (error, stackTrace) {
      // Whether native applied it is unknown. Locked natively and not in the
      // database is the safe side, and the reconciliation drops it.
      _reconcileDue = true;
      logger.e(
        'Could not lock tab $tabId natively',
        error: error,
        stackTrace: stackTrace,
      );
      return TabLockOutcome.notPersisted;
    }

    switch (change.rejection) {
      case TabLockRejection.privateTab:
        return TabLockOutcome.privateTab;
      case TabLockRejection.unknownTab || TabLockRejection.customTab:
        return TabLockOutcome.unavailable;
      case TabLockRejection.notPersisted:
        // Native may still hold it, if taking it back failed too: the
        // reconciliation at the end of this section drops it.
        _reconcileDue = true;
        return TabLockOutcome.notPersisted;
      case null:
        break;
    }

    var updated = 0;
    try {
      // Also drops the tab's tombstone, so an undo or restore that brings it
      // back never has it closed again as stale.
      updated = await tabDao.lockTab(tabId);
    } catch (error, stackTrace) {
      logger.e(
        'Could not lock tab $tabId in the database',
        error: error,
        stackTrace: stackTrace,
      );
    }
    if (updated > 0) {
      ref.read(unlockIncompleteTabsProvider.notifier).remove(tabId);
      return TabLockOutcome.applied;
    }

    // No row yet, or a private one: the lock does not count. Back to what
    // native held before; if that fails, native stays locked (fail closed).
    if (change.previouslyLocked) {
      // Native held it before this call, and the database may not: a lock
      // never acknowledged. The reconciliation at the end of this section
      // keeps it only if the database does.
      _reconcileDue = true;
    } else {
      try {
        final revert = await _native.setTabLocked(tabId, locked: false);
        if (revert.rejection != null) _reconcileDue = true;
      } catch (error, stackTrace) {
        _reconcileDue = true;
        logger.e(
          'Could not take back the native lock of tab $tabId',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return mode == null
        ? TabLockOutcome.unavailable
        : TabLockOutcome.notPersisted;
  }

  Future<TabLockOutcome> _unlock(String tabId) async {
    try {
      // Zero rows means the database already says unlocked; go on anyway, as
      // native may still hold the lock.
      await ref.read(tabDatabaseProvider).tabDao.unlockTab(tabId);
    } catch (error, stackTrace) {
      logger.e(
        'Could not unlock tab $tabId in the database',
        error: error,
        stackTrace: stackTrace,
      );
      return TabLockOutcome.notPersisted;
    }

    try {
      final change = await _native.setTabLocked(tabId, locked: false);
      if (change.rejection == null) {
        ref.read(unlockIncompleteTabsProvider.notifier).remove(tabId);
        return TabLockOutcome.applied;
      }
    } catch (error, stackTrace) {
      logger.e(
        'Could not unlock tab $tabId natively',
        error: error,
        stackTrace: stackTrace,
      );
    }

    // Native still refuses to close it, and the close preflight with it,
    // until a reconciliation succeeds. Until then it counts as locked.
    _reconcileDue = true;
    ref.read(unlockIncompleteTabsProvider.notifier).add(tabId);
    return TabLockOutcome.unlockIncomplete;
  }

  /// Whether [tabId] counts as locked: in the database, or after an unlock
  /// that did not finish. For choosing what to offer; the close decides.
  Future<bool> isLocked(String tabId) async {
    if (ref.read(unlockIncompleteTabsProvider).value.contains(tabId)) {
      return true;
    }
    final locked = await ref.read(tabDatabaseProvider).tabDao.lockedTabIdsAmong(
      [tabId],
    );
    return locked.isNotEmpty;
  }

  /// [reconcile], when something since the last one left native
  /// holding a lock the database may not.
  Future<void> reconcileIfDue() async {
    if (_reconcileDue) await reconcile();
  }

  /// Makes native's locks the database's, limited to the open tabs: the
  /// only step that drops a native lock without an unlock.
  ///
  /// Only once the session restore is complete and the database caught up
  /// with it: before that, a restored tab is not open yet, and its lock would
  /// be dropped. A reconciliation due before then waits for the catch-up.
  Future<bool> reconcile() async {
    assert(_closeLockHeld, 'Runs under the close lock');
    if (!ref.mounted || !ref.read(browserRestoreCompleteProvider)) {
      _reconcileDue = true;
      return false;
    }

    try {
      final locked = await ref
          .read(tabDatabaseProvider)
          .tabDao
          .getLockedTabIds()
          .get();
      final dropped = await _native.reconcileLockedTabs(locked);
      if (dropped.isNotEmpty) {
        logger.i('Dropped native locks the database does not hold: $dropped');
      }
      _reconcileDue = false;
      // Every unlock native refused is complete now.
      if (ref.mounted) ref.read(unlockIncompleteTabsProvider.notifier).clear();
      return true;
    } catch (error, stackTrace) {
      _reconcileDue = true;
      logger.e(
        'Could not reconcile the native tab locks',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
