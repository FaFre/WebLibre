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
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/pwa/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/pwa/presentation/dialogs/pwa_install_dialog.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// Shows the install bottom sheet for sites with a valid PWA manifest.
///
/// The manifest supplies the default name; the sheet itself offers both
/// "Install as App" and a plain shortcut, so the choice comes back in
/// [ShortcutInstallConfig.type].
Future<void> showPwaInstallDialog(BuildContext context, WidgetRef ref) async {
  final selectedTabId = ref.read(selectedTabProvider);
  final manifest = ref.read(currentTabManifestProvider);
  final defaultName = manifest?.shortName ?? manifest?.name ?? 'this web app';
  final tabState = selectedTabId != null
      ? ref.read(tabStateProvider(selectedTabId))
      : null;
  final url = tabState?.url ?? Uri.parse('about:blank');

  final config = await showPwaInstallBottomSheet(
    context,
    defaultName: defaultName,
    url: url,
  );

  if (!context.mounted) return;
  if (config == null) return;

  await _performInstall(
    context,
    ref,
    config: config,
    defaultName: defaultName,
    manifestBacked: true,
  );
}

/// Shows choice dialog for sites without a manifest.
/// Offers "Add as Shortcut" (always) and "Add as App" (if setting enabled).
Future<void> showShortcutInstallDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final selectedTabId = ref.read(selectedTabProvider);
  if (selectedTabId == null) return;

  final tabState = ref.read(tabStateProvider(selectedTabId));
  final defaultName = tabState?.title.trim().isNotEmpty == true
      ? tabState!.title
      : 'this site';
  final url = tabState?.url ?? Uri.parse('about:blank');

  final settings = ref.read(generalSettingsWithDefaultsProvider);
  final showAppOption = settings.allowNonManifestPwaInstall;

  final config = await showShortcutChoiceBottomSheet(
    context,
    defaultName: defaultName,
    url: url,
    showAppOption: showAppOption,
  );

  if (!context.mounted) return;
  if (config == null) return;

  await _performInstall(
    context,
    ref,
    config: config,
    defaultName: defaultName,
    manifestBacked: false,
  );
}

/// Runs the install the user picked and reports the outcome.
///
/// Shared by both sheets: with a manifest present or not, the same two
/// install types can come back, so the dispatch lives in one place.
/// [manifestBacked] says which sheet asked, which the failure copy needs.
Future<void> _performInstall(
  BuildContext context,
  WidgetRef ref, {
  required ShortcutInstallConfig config,
  required String defaultName,
  required bool manifestBacked,
}) async {
  final name = config.name;

  // A null override leaves the label to native's own fallback, which is not
  // the same string for both installs. `installWebApp` falls back to the
  // manifest's `short_name ?? name` — exactly what the sheet put in the field
  // — so an unchanged name can still be nulled there. `installBasicShortcut`
  // falls back to the *tab title*, which on a manifest site is a different
  // string than the manifest name the user just confirmed, so the shortcut
  // path always sends the chosen name.
  final overrideName = switch (config.type) {
    ShortcutInstallType.shortcut => name,
    ShortcutInstallType.app => name == defaultName ? null : name,
  };

  try {
    final bool success;
    switch (config.type) {
      case ShortcutInstallType.shortcut:
        success = await ref.read(
          installBasicShortcutProvider(
            overrideName: overrideName,
            contextId: config.contextId,
          ).future,
        );
      case ShortcutInstallType.app:
        success = await ref.read(
          installCurrentWebAppProvider(
            overrideName: overrideName,
            contextId: config.contextId,
          ).future,
        );
    }

    if (context.mounted) {
      if (success) {
        showInfoMessage(context, '$name added to home screen');
      } else {
        showErrorMessage(context, switch (config.type) {
          ShortcutInstallType.app when manifestBacked =>
            'Failed to add $name. The site may not support installation.',
          _ => 'Failed to add $name to home screen',
        });
      }
    }
  } catch (e, stackTrace) {
    logger.e('Failed to add to home screen', error: e, stackTrace: stackTrace);

    if (context.mounted) {
      showErrorMessage(
        context,
        e is StateError
            ? 'No tab selected. Please try again.'
            : 'Failed to add $name to home screen',
      );
    }
  }
}
