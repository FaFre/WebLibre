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
import 'package:fast_equatable/fast_equatable.dart';

/// A close did nothing because the tab locks, the database's or native's,
/// could not be read: without them nothing says which of the tabs may close.
class TabLocksUnavailableException implements Exception {
  final Object cause;
  final StackTrace causeStackTrace;

  const TabLocksUnavailableException(this.cause, this.causeStackTrace);

  @override
  String toString() =>
      'TabLocksUnavailableException: the tab locks could not be read '
      '($cause)';
}

/// What came of locking or unlocking a tab.
enum TabLockOutcome {
  /// The change was made.
  applied,

  /// Private tabs cannot be locked.
  privateTab,

  /// The tab is not open, or is not a tab that can be locked.
  unavailable,

  /// Nothing changed: the lock could not be saved.
  notPersisted,

  /// An unlock whose last step failed: the database says unlocked, but the
  /// engine still keeps the tab from closing until the next reconciliation.
  /// Until then the tab counts as locked.
  unlockIncomplete,
}

/// The result of replacing a tab with one that takes its place (a container
/// change, a reopen in the assigned container).
sealed class ReplacementResult with FastEquatable {
  ReplacementResult();

  /// The tab now in the original's place, or null when the original stayed.
  String? get replacementTabId;
}

/// The original closed and [newTabId] took its place.
final class TabReplaced extends ReplacementResult {
  final String newTabId;

  TabReplaced(this.newTabId);

  @override
  String? get replacementTabId => newTabId;

  @override
  List<Object?> get hashParameters => [newTabId];
}

/// The original survived its close because it is locked, or because the
/// locks could not be read ([locksUnavailable]), so nothing took its place.
/// A replacement opened before the close was tried stays open beside it.
final class OriginalKept extends ReplacementResult {
  final bool locksUnavailable;

  OriginalKept({this.locksUnavailable = false});

  @override
  String? get replacementTabId => null;

  @override
  List<Object?> get hashParameters => [locksUnavailable];
}

/// What came of moving a tab into or out of a container.
enum ContainerMoveResult {
  /// Moved, or already where it was asked to go.
  moved,

  /// A locked tab cannot move to a container with other cookie storage: that
  /// recreates it, and a locked tab does not close.
  lockedNeedsSameContext,

  /// Such a move did not happen because the tab locks could not be read:
  /// nothing says whether the tab may close. Trying again usually works.
  locksUnavailable,

  /// The source or target container is being deleted.
  containerBeingDeleted,

  /// The source or target container is frozen, or being frozen or resumed
  /// (D19): resume it first.
  containerFrozen,
}

/// What came of deleting a container with its tabs.
///
/// The case without data is `const` (FastEquatable needs a field to hash), so
/// every instance of it is the same.
sealed class ContainerDeletionResult {
  const ContainerDeletionResult();
}

/// The container and its tabs are gone. [historyKept] when its history was to
/// be deleted too and that failed: the visits stay, without a container.
/// [siteDataCleanupPending] when it was frozen and its site data could not be
/// deleted yet: its contexts stay restricted and the deletion of their data is
/// retried (D28, D32).
final class ContainerDeleted extends ContainerDeletionResult
    with FastEquatable {
  final bool historyKept;
  final bool siteDataCleanupPending;

  ContainerDeleted({
    this.historyKept = false,
    this.siteDataCleanupPending = false,
  });

  @override
  List<Object?> get hashParameters => [historyKept, siteDataCleanupPending];
}

/// Nothing was deleted: the container is frozen, and its deletion could not
/// be recorded before its row would have gone (D28).
final class ContainerDeletionNotPersisted extends ContainerDeletionResult {
  const ContainerDeletionNotPersisted();
}

/// Nothing was closed or deleted: [tabIds] are locked.
final class ContainerDeletionBlockedByLockedTabs extends ContainerDeletionResult
    with FastEquatable {
  final List<String> tabIds;

  ContainerDeletionBlockedByLockedTabs(this.tabIds);

  int get count => tabIds.length;

  @override
  List<Object?> get hashParameters => [tabIds];
}

/// Nothing was closed or deleted: a custom tab or web app runs in the
/// container's storage. It is no tab, so closing the tabs would leave it
/// loading pages in storage being deleted, without the container's routing;
/// it is closed first, as for a freeze (D18).
final class ContainerDeletionBlockedByWebApps extends ContainerDeletionResult {
  const ContainerDeletionBlockedByWebApps();
}

/// Another operation on the container is still running.
final class ContainerDeletionWaitForOperation extends ContainerDeletionResult {
  const ContainerDeletionWaitForOperation();
}

/// Nothing was closed or deleted: native's freeze registry could not be read
/// (D27), so whether the container is frozen, and which contexts it holds, is
/// not known.
final class ContainerDeletionFreezeStateUnknown
    extends ContainerDeletionResult {
  const ContainerDeletionFreezeStateUnknown();
}

/// Nothing was closed or deleted: native's freeze record was found damaged and
/// the frozen containers are not restored yet (D23). Every container counts
/// as frozen until then, and which contexts hold its site data is not known,
/// so they could not be deleted.
final class ContainerDeletionRecoveryPending extends ContainerDeletionResult {
  const ContainerDeletionRecoveryPending();
}

/// Nothing was closed or deleted: native would delete the site data of the
/// container's own storage with it (it is frozen, or a freeze or Resume of it
/// did not finish, D28), and that was not agreed to (D29). Asked again.
final class ContainerDeletionNeedsSiteData extends ContainerDeletionResult {
  const ContainerDeletionNeedsSiteData();
}

/// Nothing was closed or deleted: the container is frozen and holds the
/// storage of an isolated tab in another container, which a damaged freeze
/// record restored under it (5.6). Its data would be deleted with the
/// container while that tab still uses it; the container is resumed first.
final class ContainerDeletionSharedStorage extends ContainerDeletionResult {
  const ContainerDeletionSharedStorage();
}

/// Some tabs could not be closed, so the container was kept: deleting it
/// would have taken their rows with it.
final class ContainerDeletionIncomplete extends ContainerDeletionResult
    with FastEquatable {
  final List<String> survivorTabIds;

  ContainerDeletionIncomplete(this.survivorTabIds);

  @override
  List<Object?> get hashParameters => [survivorTabIds];
}
