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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/providers/provider_read.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_close_result.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/tab_lock_actions.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// Closes [tabId] with the shared UX contract: a locked tab only says so;
/// otherwise confirm before closing the last tab of an isolation group, then
/// offer undo via snackbar when the tab actually closed.
Future<void> closeTabWithConfirmationAndUndo(
  BuildContext context,
  WidgetRef ref,
  String tabId,
) => closeTabWithConfirmationAndUndoUsing(context, ref.read, tabId);

/// Says that [tabId] is locked, offering Unlock, and returns true when it
/// counts as locked; a close entry point then stops. Asked before anything
/// else, so a locked isolated tab does not ask about its data before refusing
/// anyway. Only the hint: the close itself checks again.
bool refuseLockedTabClose(
  BuildContext context,
  ProviderRead read,
  String tabId,
) {
  if (!read(isTabLockedProvider(tabId))) return false;
  if (context.mounted) showTabLockedMessage(context, read, tabId);
  return true;
}

/// [closeTabWithConfirmationAndUndo] for callers holding a provider [Ref]
/// rather than a widget, such as the browser action dispatcher.
/// [onClosed] (a menu closing itself) runs once the close ran, before its
/// result is shown; [onRemoved] (the tab tree closing with its last other
/// tab) only when the tab was in fact removed: the close checks the lock
/// again and can still keep it.
Future<void> closeTabWithConfirmationAndUndoUsing(
  BuildContext context,
  ProviderRead read,
  String tabId, {
  VoidCallback? onClosed,
  VoidCallback? onRemoved,
}) async {
  if (refuseLockedTabClose(context, read, tabId)) return;

  // Confirm before closing the last tab in an isolation group
  final tabState = read(tabStateProvider(tabId));
  if (tabState != null && tabState.tabMode is IsolatedTabMode) {
    final allStates = read(tabStatesProvider);
    final groupCount = allStates.values
        .where((s) => s.isolationContextId == tabState.isolationContextId)
        .length;
    if (groupCount <= 1 && context.mounted) {
      final confirmed = await ui_helper.confirmIsolatedTabClose(context, read);
      if (!confirmed) return;
    }
  }

  final result = await read(tabRepositoryProvider.notifier).closeTab(tabId);
  onClosed?.call();
  if (result.isGone(tabId)) onRemoved?.call();

  if (context.mounted) {
    showTabCloseResult(
      context,
      result,
      read(tabRepositoryProvider.notifier).undoClose,
    );
  }
}

/// Reports what a close did ([result]): Undo only when something closed, and
/// how many locked tabs were kept. A close that a lock refused entirely says
/// so instead of offering an Undo that would bring nothing back.
void showTabCloseResult(
  BuildContext context,
  CloseResult result,
  VoidCallback onUndo, {
  Duration duration = const Duration(seconds: 3),
  bool persist = false,
}) {
  final closed = result.removedTabIds.length;
  final locked = result.skippedLockedTabIds.length;

  if (closed == 0) {
    if (result.locksUnavailable) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ui_helper.showErrorMessage(
        context,
        AppLocalizations.of(context).browser_closeFailed,
      );
      return;
    }
    if (locked == 0) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ui_helper.showInfoMessage(
      context,
      AppLocalizations.of(context).browser_lockedTabsKept(locked),
    );
    return;
  }

  if (locked == 0) {
    ui_helper.showTabUndoClose(
      context,
      onUndo,
      count: closed,
      duration: duration,
      persist: persist,
    );
    return;
  }

  ScaffoldMessenger.of(context).clearSnackBars();
  final l10n = AppLocalizations.of(context);
  ui_helper.showInfoMessage(
    context,
    l10n.browser_tabsClosedKeptLocked(closed, locked),
    action: SnackBarAction(label: l10n.common_undo, onPressed: onUndo),
    duration: duration,
    persist: persist,
  );
}

/// For bulk closes that report nothing of their own: says what a lock kept
/// open, and only when a lock kept something.
void showLockedTabsKept(
  BuildContext context,
  CloseResult? result,
  VoidCallback onUndo,
) {
  if (result == null || result.skippedLockedTabIds.isEmpty) return;
  showTabCloseResult(context, result, onUndo);
}
