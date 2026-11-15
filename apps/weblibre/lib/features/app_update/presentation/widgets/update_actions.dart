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
import 'package:weblibre/features/app_update/data/providers.dart';
import 'package:weblibre/features/app_update/domain/entities/distribution_policy.dart';
import 'package:weblibre/features/app_update/domain/entities/update_state.dart';
import 'package:weblibre/features/app_update/domain/providers.dart';
import 'package:weblibre/features/app_update/presentation/dialogs/install_dialogs.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';

/// The install flow behind every "Install" button (8.5): confirm, then
/// install; a missing permission is asked for after the confirmation, and the
/// coordinator continues by itself once it is granted.
Future<void> confirmAndInstall(
  BuildContext context,
  WidgetRef ref,
  String targetId,
) async {
  final policy = ref.read(distributionPolicyProvider).value;
  final controller = ref.read(appUpdateControllerProvider.notifier);

  // Play restarts the app itself, with its own UI.
  if (policy is PlayUpdates) {
    await controller.install(targetId);
    return;
  }

  final privateTabsOpen = ref
      .read(tabStatesProvider)
      .values
      .any((tab) => tab.tabMode == TabMode.private);
  final confirmed = await showInstallConfirmDialog(
    context,
    privateTabsOpen: privateTabsOpen,
  );
  if (!confirmed) return;
  await controller.install(targetId);

  // Permission missing: ask right away rather than leaving the user to find
  // "Allow…" in the status. The install can take long enough for the caller to
  // be gone, and its ref with it.
  if (!context.mounted) return;
  if (ref.read(appUpdateStateProvider) is UpdateAwaitingPermission) {
    await requestInstallPermission(context, ref);
  }
}

/// "Allow…": explains, then opens Android's screen for this package.
Future<void> requestInstallPermission(
  BuildContext context,
  WidgetRef ref,
) async {
  final open = await showInstallPermissionDialog(context);
  if (!open) return;
  await ref.read(appUpdateHostProvider).openInstallPermissionSettings();
}
