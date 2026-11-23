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
import 'package:synchronized/synchronized.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_close_result.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_lock.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab/tab_close_lock.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab/tab_locks.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/container_membership_gate.dart';

part 'container_deletion.g.dart';

/// Deleting a container with its tabs, for the tab repository (D28, D35 of
/// `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`): its tabs are closed
/// and its row deleted, unless one of its tabs is locked.
///
/// Checked before anything is closed or deleted, against both lock sets:
/// the protocol allows a lock only native holds. The row goes only when the
/// close removed every member — the cascade on `tab.container_id` would take
/// a surviving tab's row with it — and its delete is conditional in SQL as
/// the last guard.
///
/// Holds the membership gate's deleting reservation throughout, so no tab
/// joins the container meanwhile; the lock order is the gate, then the
/// close lock ([tabCloseLockProvider]). A window one of its pages opens
/// meanwhile is closed with it (see `TabRepository.handleTabAdded`), and the
/// pending undo close is dropped when it would bring one of its tabs back.
@Riverpod(keepAlive: true)
class ContainerDeletion extends _$ContainerDeletion {
  final _tabsService = GeckoTabService();

  @override
  void build() {}

  Lock get _closeLock => ref.read(tabCloseLockProvider);

  TabLocks get _locks => ref.read(tabLocksProvider.notifier);

  /// The repository's close, for a caller that holds [_closeLock]: with
  /// tombstones, and off the recently closed list, since reopened the tabs
  /// would come back outside any container, without its proxy.
  Future<CloseResult> _closeTabsLocked(List<String> tabIds) => ref
      .read(tabRepositoryProvider.notifier)
      .closeTabsLocked(
        tabIds,
        recordTombstones: true,
        keepOffRecentlyClosed: true,
      );

  GeckoTabLifecycleService get _tabLifecycle =>
      ref.read(geckoTabLifecycleServiceProvider);

  /// Closes container [containerId]'s tabs and deletes it, unless one of its
  /// tabs is locked; see [ContainerDeletion].
  ///
  /// [deleteSiteData] is the user's answer to "Also delete site data" (D29)
  /// for the container's own storage. Native deletes that storage's data
  /// with it anyway while it has a record (frozen, say): without the answer,
  /// nothing is closed or deleted then ([ContainerDeletionNeedsSiteData]).
  /// Without a record, native deletes it too once the row is gone, if asked,
  /// by the same release procedure: its push subscriptions with it, the
  /// clear acknowledged, and what is left retried at every start. Native
  /// writes that down before the row goes, so a process that ends between
  /// the two still has it. Both are decided under the deletion's
  /// reservation, from the snapshot it goes by.
  Future<ContainerDeletionResult> delete(
    String containerId, {
    bool deleteSiteData = false,
  }) async {
    final result = await ref
        .read(containerMembershipGateProvider.notifier)
        .whileDeleting(
          containerId,
          () => _closeLock.synchronized(() async {
            try {
              return await _deleteLocked(
                containerId,
                deleteSiteData: deleteSiteData,
              );
            } on TabLocksUnavailableException catch (error, stackTrace) {
              // Without the locks nothing says which tabs may close, so the
              // container is kept: deleting its row would cascade through any
              // tab still open in it.
              logger.e(
                'Could not delete container $containerId',
                error: error,
                stackTrace: stackTrace,
              );
              return ContainerDeletionIncomplete(const []);
            } finally {
              // As at the end of every close: completes an unlock a close
              // found unfinished.
              await _locks.reconcileIfDue();
            }
          }),
        );
    if (result is ContainerDeleted) {
      // Outside the close lock: clearing a frozen container's data can take
      // a while, and its row is gone, so nothing can join it.
      final released = await _completeContextDeletion(containerId);
      return ContainerDeleted(siteDataCleanupPending: !released);
    }
    return result ?? const ContainerDeletionWaitForOperation();
  }

  /// The second half of deleting a container (D28): the push subscriptions
  /// of its recorded contexts and of the storage whose data deletion
  /// [_beginContextDeletion] wrote down removed and their data cleared, then
  /// released. A no-op for a container that was never frozen and keeps its
  /// site data. False when something is left: the contexts stay restricted
  /// and native retries at every start.
  Future<bool> _completeContextDeletion(String containerId) async {
    try {
      final result = await _tabLifecycle.completeContextDeletion(containerId);
      // Its released contexts are no phase of the container's: what is left
      // is in the ones native could not release.
      return result.failure == null && result.unsettledContextIds.isEmpty;
    } catch (error, stackTrace) {
      logger.e(
        'Could not release the contexts of deleted container $containerId',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// The first half (D28): a frozen container's contexts are recorded as
  /// being deleted, still restricted, before its row goes, and so is the
  /// data deletion of [deleteDataOf], storage without a record whose data
  /// the user asked to delete (D29). Null when that was written, or there is
  /// nothing to record (no record holds the container: one whose release is
  /// pending stays restricted and is released by [_completeContextDeletion]
  /// as it is); otherwise why the deletion stops before anything is closed.
  Future<ContainerDeletionResult?> _beginContextDeletion(
    String containerId, {
    required List<String> deleteDataOf,
  }) async {
    try {
      final result = await _tabLifecycle.beginContextDeletion(
        containerId,
        deleteDataOf: deleteDataOf,
      );
      // Before the phase: native has no record to report one from then.
      if (result.failure == LifecycleFailure.recoveryPending) {
        return const ContainerDeletionRecoveryPending();
      }
      if (result.failure == null) return null;
      // Nothing to write down (no record holds it, no site data to delete):
      // a refusal changes nothing, as when the components are missing. With
      // site data to delete, the row goes only once that is written: deleted
      // without it, nothing would be left to retry.
      if (deleteDataOf.isEmpty &&
          result.phase == ContextFreezePhase.unrestricted) {
        return null;
      }
      return const ContainerDeletionNotPersisted();
    } catch (error, stackTrace) {
      logger.e(
        'Could not record the deletion of container $containerId',
        error: error,
        stackTrace: stackTrace,
      );
      return const ContainerDeletionNotPersisted();
    }
  }

  /// The row was not deleted: a frozen container's contexts go back to the
  /// phases they had before [_beginContextDeletion].
  Future<void> _cancelContextDeletion(String containerId) async {
    try {
      await _tabLifecycle.cancelContextDeletion(containerId);
    } catch (error, stackTrace) {
      // The next start's reconciliation restores them, the row being there.
      logger.e(
        'Could not cancel the recorded deletion of container $containerId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// [delete] under its reservation and the close lock.
  Future<ContainerDeletionResult> _deleteLocked(
    String containerId, {
    required bool deleteSiteData,
  }) async {
    final db = ref.read(tabDatabaseProvider);
    final gate = ref.read(containerMembershipGateProvider.notifier);
    final contextId =
        (await db.containerDao.getContainerData(containerId).getSingleOrNull())
            ?.metadata
            .contextualIdentity;
    // The contexts only the container's tabs run in: its own cookie store,
    // and those of its isolated tabs, which a window opened from one of them
    // inherits. Read once, before closing takes the rows that name them.
    // Also the isolation groups of a frozen container whose last tab closed
    // while it was frozen: native keeps them restricted for it, and a web app
    // opened from one of them runs there.
    await gate.seed();
    // Without the registry, neither are the frozen container's contexts
    // known: its web app windows and undo closes would be missed.
    if (!gate.hasRegistrySnapshot()) {
      return const ContainerDeletionFreezeStateUnknown();
    }
    // Until the frozen containers are restored, which contexts hold the
    // container's data is not known, and native would delete none of it
    // (D23).
    if (gate.isInRecovery()) {
      return const ContainerDeletionRecoveryPending();
    }
    // Native deletes the data of its own storage with it while that has a
    // record (D28, D29). What the dialog read may have been loading, or older
    // than a freeze since: asked again rather than deleted unasked. No freeze
    // starts while the reservation holds, so no record appears meanwhile.
    final releasedByNative =
        contextId != null && gate.contextRecord(contextId) != null;
    if (releasedByNative && !deleteSiteData) {
      return const ContainerDeletionNeedsSiteData();
    }
    return await _deleteChecked(
      containerId,
      contextId: contextId,
      deleteDataOf: [if (deleteSiteData && !releasedByNative) ?contextId],
    );
  }

  /// [_deleteLocked] once the registry was read and the site data settled.
  Future<ContainerDeletionResult> _deleteChecked(
    String containerId, {
    required String? contextId,
    required List<String> deleteDataOf,
  }) async {
    final db = ref.read(tabDatabaseProvider);
    final gate = ref.read(containerMembershipGateProvider.notifier);
    final contextIds = {
      ?contextId,
      ...await db.tabDao.isolationContextIdsOnlyInContainer(containerId),
      for (final owned in gate.contextsOwnedBy(containerId))
        if (await db.tabDao.tabsInIsolationGroup(owned).getSingle() == 0) owned,
    }.toList();
    // Native deletes the data of every context it records for the container
    // (D28). After a damaged registry, an isolation group tabs of two
    // containers share is restored under one of them only (5.6): deleted
    // with it, its data would go while the other's tabs still use it.
    // Resumed first, the container holds nothing, and the group stays theirs.
    if (gate
        .contextsHolding(containerId)
        .any((held) => !contextIds.contains(held))) {
      return const ContainerDeletionSharedStorage();
    }

    // The container's tabs: its rows, every tab the engine runs in its
    // contexts right now, and the windows its pages opened since the
    // deletion started. The engine's store, not the tab events: a window a
    // member page opened a moment ago is there before any event reports it,
    // and before it has a row. A container sharing the default cookie store
    // has no context of its own; its windows are known once their event
    // arrives (`TabRepository.handleTabAdded`).
    Future<Set<String>> currentTabs() async => {
      ...await _members(containerId),
      for (final id in contextIds) ...await _tabsService.getTabIdsInContext(id),
      ...gate.tabsOpenedDuringDeletion(containerId),
    };

    // A custom tab or web app window is no tab: closing the tabs never
    // reaches it (D18).
    // Every context native restricts for it counts: a frozen one is deleted
    // with it (D28).
    final windowContextIds = {
      ...contextIds,
      ...gate.contextsOwnedBy(containerId),
    }.toList();
    if (windowContextIds.isNotEmpty &&
        (await _tabsService.getCustomTabIdsInContexts(
          windowContextIds,
        )).isNotEmpty) {
      return const ContainerDeletionBlockedByWebApps();
    }

    final candidates = await currentTabs();
    var protectedIds = await _protectedAmong(candidates);

    // A lock only native holds is an unlock the user asked for that did not
    // finish. One reconciliation may complete it.
    final dbLocked = await db.tabDao.lockedTabIdsAmong(protectedIds);
    if (protectedIds.any((id) => !dbLocked.contains(id))) {
      await _locks.reconcile();
      protectedIds = await _protectedAmong(candidates);
    }
    if (protectedIds.isNotEmpty) {
      return ContainerDeletionBlockedByLockedTabs(protectedIds);
    }

    // A frozen container's contexts stay restricted through its deletion,
    // which is written down before anything is closed or deleted (D28,
    // D35), with the site data to delete of one never frozen. A no-op for a
    // container that was never frozen and keeps its site data.
    if (await _beginContextDeletion(containerId, deleteDataOf: deleteDataOf)
        case final refused?) {
      // A write that was not confirmed durable counts as failed, though an
      // earlier one of the same deletion may have left it in native's
      // memory: put back.
      if (refused is ContainerDeletionNotPersisted) {
        await _cancelContextDeletion(containerId);
      }
      return refused;
    }
    var deleted = false;
    try {
      final result = await _closeAndDeleteContainer(
        containerId,
        candidates: candidates,
        contextIds: contextIds,
        currentTabs: currentTabs,
      );
      deleted = result is ContainerDeleted;
      return result;
    } finally {
      // The row stays, also when closing threw (native's locks unreadable):
      // so do the contexts' phases. Left `deletionPending`, they would stay
      // blocked with no Resume until the next start.
      if (!deleted) await _cancelContextDeletion(containerId);
    }
  }

  Future<List<String>> _members(String containerId) => ref
      .read(tabDatabaseProvider)
      .containerDao
      .getContainerTabIds(containerId)
      .get();

  /// Those of [tabIds] that are locked, by the database or native.
  Future<List<String>> _protectedAmong(Iterable<String> tabIds) async {
    final ids = tabIds.toList();
    final (:locked, nativeOnly: _) = await _locks.lockedAmong(ids);
    return [
      for (final id in ids)
        if (locked.contains(id)) id,
    ];
  }

  /// The destructive part of [delete], once its preflight
  /// passed and a frozen container's deletion is recorded.
  Future<ContainerDeletionResult> _closeAndDeleteContainer(
    String containerId, {
    required Set<String> candidates,
    required List<String> contextIds,
    required Future<Set<String>> Function() currentTabs,
  }) async {
    final db = ref.read(tabDatabaseProvider);
    final gate = ref.read(containerMembershipGateProvider.notifier);

    // Closed, or not open to begin with: the rows the cascade may take.
    final closedIds = <String>{};
    var pending = candidates.toList();
    // A tab can join natively after the tabs were read (a window request
    // from one of them, consumed late), so they are read again, an empty
    // container's too, until a pass finds nothing new.
    for (var pass = 0; ; pass++) {
      if (pending.isNotEmpty) {
        // Recorded first: a window one of them opens, reported once its row
        // went with the container, is filed with the container too.
        gate.recordDeletionMembers(containerId, pending);
        final closed = await _closeTabsLocked(pending);
        closedIds
          ..addAll(closed.removedTabIds)
          ..addAll(closed.missingTabIds);

        final survivors = [
          for (final id in pending)
            if (!closedIds.contains(id)) id,
        ];
        if (survivors.isNotEmpty) {
          // A lock the preflight missed, or a removal native refused for
          // another reason: deleting the row now would cascade through them.
          return ContainerDeletionIncomplete(survivors);
        }
      }

      pending = (await currentTabs()).difference(closedIds).toList();
      if (pending.isEmpty) break;
      if (pass == 2) return ContainerDeletionIncomplete(pending);
    }

    final deleted = await db.tabDao.deleteContainerIfOnlyClosedTabs(
      containerId,
      closedTabIds: closedIds,
    );
    if (deleted > 0 ||
        await db.containerDao.getContainerData(containerId).getSingleOrNull() ==
            null) {
      await _finishContainerDeletion(
        containerId,
        closedIds: closedIds,
        contextIds: contextIds,
      );
      return ContainerDeleted();
    }

    // A row joined after the last pass: one no reservation covers, such as a
    // container repair from the engine's state, or a lock arrived.
    final remaining = [
      for (final id in await _members(containerId))
        if (!closedIds.contains(id)) id,
    ];
    final stillLocked = await _protectedAmong(remaining);
    if (stillLocked.isNotEmpty) {
      return ContainerDeletionBlockedByLockedTabs(stillLocked);
    }
    return ContainerDeletionIncomplete(remaining);
  }

  /// After container [containerId]'s row went: closes the windows its pages
  /// opened since the last pass, and drops the pending undo close if it
  /// would bring back one of its tabs — [closedIds], or one closed just
  /// before that ran in one of [contextIds]. Neither may fail the deletion,
  /// which is done.
  Future<void> _finishContainerDeletion(
    String containerId, {
    required Set<String> closedIds,
    required List<String> contextIds,
  }) async {
    final lateTabIds = ref
        .read(containerMembershipGateProvider.notifier)
        .tabsOpenedDuringDeletion(containerId)
        .difference(closedIds);
    try {
      final closedTabIds = {...closedIds};
      if (lateTabIds.isNotEmpty) {
        // Their rows are under no container, so the cascade did not touch
        // them; `TabRepository.handleTabAdded` retries any that does not
        // close here.
        final closed = await _closeTabsLocked(lateTabIds.toList());
        closedTabIds.addAll(closed.removedTabIds);
      }
      await _tabsService.discardUndoOf(
        tabIds: closedTabIds.toList(),
        contextIds: contextIds,
      );
    } catch (error, stackTrace) {
      logger.e(
        'Could not finish deleting container $containerId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
