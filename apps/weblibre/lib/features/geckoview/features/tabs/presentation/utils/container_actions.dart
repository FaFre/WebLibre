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
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_lock.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/tab_lock_l10n.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/dialogs/delete_container_dialog.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/utils/container_freeze_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// Ask for confirmation and delete [container], honouring the dialog's
/// wipe-history choice. Returns whether the container was deleted.
///
/// Shared by the container edit screen and the container context menu so both
/// entry points perform the same cleanup.
///
/// A container with locked tabs is not deleted, and says so before asking.
/// Nothing is destroyed before the deletion has succeeded: the history to
/// delete is only read beforehand (its relation rows go with the container),
/// and the history and the app-link override go once the container did.
Future<bool> confirmAndDeleteContainer(
  BuildContext context,
  WidgetRef ref,
  ContainerData container,
) async {
  final locked = await ref
      .read(tabDataRepositoryProvider.notifier)
      .lockedTabIdsInContainer(container.id);
  if (!context.mounted) return false;
  if (locked.isNotEmpty) {
    await _refuseForLockedTabs(context, ref, container, locked.length);
    return false;
  }

  // A record of its own storage: frozen, being frozen or resumed, or a
  // deletion that did not finish. Native deletes that storage's site data
  // with it either way (D28). A record of an isolation group only is not
  // one: its own storage is cleared only if asked.
  final identity = container.metadata.contextualIdentity;
  final frozen =
      identity != null &&
      (ref
              .read(contextFreezeSnapshotProvider)
              .value
              ?.contexts
              .any((context) => context.contextId == identity) ??
          false);
  final decision = await showDeleteContainerDialog(
    context,
    hasOwnStorage: identity != null,
    frozen: frozen,
  );
  if (decision == null || !context.mounted) {
    return false;
  }

  return await _deleteContainer(context, ref, container, decision);
}

Future<bool> _deleteContainer(
  BuildContext context,
  WidgetRef ref,
  ContainerData container,
  DeleteContainerDecision decision,
) async {
  // The cleanup the deletion owes happens in the repository, whether or not
  // this screen is still there when it finishes; only what is said depends on
  // it.
  final result = await ref
      .read(containerRepositoryProvider.notifier)
      .deleteContainer(
        container.id,
        deleteHistory: decision.wipeHistory,
        deleteSiteData: decision.deleteSiteData,
      );
  if (!context.mounted) return result is ContainerDeleted;

  switch (result) {
    case ContainerDeletionBlockedByLockedTabs(:final count):
      await _refuseForLockedTabs(context, ref, container, count);
      return false;
    case ContainerDeletionNeedsSiteData():
      // Frozen since the dialog was answered, or before its snapshot had
      // loaded: its site data goes with it, which was not agreed to. Asked
      // again, with that said; nothing was closed or deleted.
      final again = await showDeleteContainerDialog(
        context,
        hasOwnStorage: true,
        frozen: true,
      );
      if (again == null || !context.mounted) return false;
      return await _deleteContainer(context, ref, container, again);
    case _:
      final outcome = result.describe(AppLocalizations.of(context));
      if (outcome != null) {
        ui_helper.showOutcomeMessage(
          context,
          outcome.text,
          failed: outcome.failed,
        );
      }
      return result is ContainerDeleted;
  }
}

/// Says that [container] holds [count] locked tabs and offers to show them.
Future<void> _refuseForLockedTabs(
  BuildContext context,
  WidgetRef ref,
  ContainerData container,
  int count,
) async {
  final showTabs = await showContainerHasLockedTabsDialog(
    context,
    count: count,
  );
  if (!showTabs || !context.mounted) return;

  await ref
      .read(selectedContainerProvider.notifier)
      .setContainerId(container.id);
  if (context.mounted) const TabViewRoute().go(context);
}

/// Runs [open], which opens a tab into a container. When the container
/// refuses it, says why and returns null: a frozen one ("Resume the container
/// first": a new isolated tab, or a duplicate of one, would bring a context
/// of its own into it, D19), or one being deleted.
///
/// The message is resolved from [context] before [open] runs, so it still
/// shows when the menu or dialog that asked has closed in the meantime.
Future<T?> openUnlessContainerRefuses<T>(
  BuildContext context,
  Future<T> Function() open,
) async {
  final l10n = AppLocalizations.of(context);
  final showInfo = ui_helper.infoMessengerFor(context);
  try {
    return await open();
  } on ContainerRefusedTabException catch (refusal) {
    showInfo(refusal.describe(l10n));
    return null;
  }
}
