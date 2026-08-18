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
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/container_history.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/dialogs/delete_container_dialog.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

/// Remove any per-container app-link overrides (§ container isolation) stored
/// for [contextIds] in GeneralSettings. Null ids are ignored; a no-op when none
/// are present. Keeps overrides from lingering after a container drops
/// isolation or is deleted.
Future<void> removeContainerAppLinkOverrides(
  WidgetRef ref,
  Set<String?> contextIds,
) async {
  final ids = contextIds.nonNulls.toSet();
  if (ids.isEmpty) return;

  await ref.read(generalSettingsRepositoryProvider.notifier).updateSettings((
    current,
  ) {
    if (!ids.any(current.appLinkContextOverrides.containsKey)) return current;
    return current.copyWith.appLinkContextOverrides(
      {...current.appLinkContextOverrides}
        ..removeWhere((key, _) => ids.contains(key)),
    );
  });
}

/// Ask for confirmation and delete [container], honouring the dialog's
/// wipe-history choice. Returns whether the container was deleted.
///
/// Shared by the container edit screen and the container context menu so both
/// entry points perform the same cleanup.
Future<bool> confirmAndDeleteContainer(
  BuildContext context,
  WidgetRef ref,
  ContainerData container,
) async {
  final result = await showDeleteContainerDialog(context);
  if (result == null) {
    return false;
  }

  // Delete the container's Places visits BEFORE the container itself so the
  // relation rows still exist to find them; deleting the container then
  // dissolves the relations via ON DELETE CASCADE.
  if (result.wipeHistory) {
    await ref
        .read(containerHistoryRepositoryProvider.notifier)
        .deletePlacesVisitsForContainer(container.id);
  }

  await ref
      .read(containerRepositoryProvider.notifier)
      .deleteContainer(container.id);

  // Drop the container's app-link override so it doesn't outlive it.
  await removeContainerAppLinkOverrides(ref, {
    container.metadata.contextualIdentity,
  });

  return true;
}
