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
import 'package:weblibre/features/geckoview/domain/entities/tab_lock.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

extension TabLockOutcomeL10n on TabLockOutcome {
  /// What to say after a lock change of a tab that [wasLocked] before, and
  /// whether it failed rather than was refused; null when it applied, which
  /// the tab's lock badge shows.
  ({String text, bool failed})? describe(
    AppLocalizations l10n, {
    required bool wasLocked,
  }) => switch (this) {
    TabLockOutcome.applied => null,
    TabLockOutcome.privateTab => (
      text: l10n.browser_tabLockPrivate,
      failed: false,
    ),
    TabLockOutcome.unlockIncomplete => (
      text: l10n.browser_tabUnlockIncompleteMessage,
      failed: true,
    ),
    TabLockOutcome.unavailable || TabLockOutcome.notPersisted => (
      text: wasLocked
          ? l10n.browser_tabUnlockFailed
          : l10n.browser_tabLockFailed,
      failed: true,
    ),
  };
}

extension ContainerMoveResultL10n on ContainerMoveResult {
  /// Why the tab did not move to the other container, and whether that
  /// failed rather than was refused with a hint at what to do next; null when
  /// it moved.
  ({String text, bool failed})? describe(AppLocalizations l10n) =>
      switch (this) {
        ContainerMoveResult.moved => null,
        ContainerMoveResult.lockedNeedsSameContext => (
          text: l10n.browser_lockedTabCannotMove,
          failed: false,
        ),
        ContainerMoveResult.locksUnavailable => (
          text: l10n.browser_tabMoveFailed,
          failed: true,
        ),
        ContainerMoveResult.containerBeingDeleted => (
          text: l10n.browser_containerBeingDeleted,
          failed: false,
        ),
        ContainerMoveResult.containerFrozen => (
          text: l10n.browser_containerFrozen,
          failed: false,
        ),
      };
}

extension ContainerDeletionResultL10n on ContainerDeletionResult {
  /// What to say after deleting a container, and whether it failed rather
  /// than was refused with a hint at what to do next. Null when there is
  /// nothing to say, and for the two results the caller answers with a
  /// dialog instead ([ContainerDeletionBlockedByLockedTabs],
  /// [ContainerDeletionNeedsSiteData]).
  ({String text, bool failed})? describe(AppLocalizations l10n) =>
      switch (this) {
        ContainerDeleted(historyKept: true) => (
          text: l10n.tabs_deleteContainerHistoryFailed,
          failed: true,
        ),
        ContainerDeleted(siteDataCleanupPending: true) => (
          text: l10n.tabs_deleteContainerSiteDataPending,
          failed: false,
        ),
        ContainerDeleted() => null,
        ContainerDeletionNotPersisted() => (
          text: l10n.tabs_deleteContainerNotPersisted,
          failed: true,
        ),
        ContainerDeletionFreezeStateUnknown() => (
          text: l10n.tabs_deleteContainerFreezeStateUnknown,
          failed: true,
        ),
        // Deleting it again from its menu retries; the container is intact.
        ContainerDeletionIncomplete() => (
          text: l10n.tabs_deleteContainerIncomplete,
          failed: true,
        ),
        ContainerDeletionWaitForOperation() => (
          text: l10n.tabs_deleteContainerBusy,
          failed: false,
        ),
        ContainerDeletionRecoveryPending() => (
          text: l10n.tabs_deleteContainerRecoveryPending,
          failed: false,
        ),
        ContainerDeletionBlockedByWebApps() => (
          text: l10n.tabs_deleteContainerOpenInWebApp,
          failed: false,
        ),
        ContainerDeletionSharedStorage() => (
          text: l10n.tabs_deleteContainerSharedStorage,
          failed: false,
        ),
        ContainerDeletionBlockedByLockedTabs() ||
        ContainerDeletionNeedsSiteData() => null,
      };
}
