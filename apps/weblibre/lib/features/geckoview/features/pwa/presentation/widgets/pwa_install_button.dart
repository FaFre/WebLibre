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

/// Shows install bottom sheet for sites with a valid PWA manifest (existing flow).
Future<void> showPwaInstallDialog(BuildContext context, WidgetRef ref) async {
  final selectedTabId = ref.read(selectedTabProvider);
  final manifest = ref.read(currentTabManifestProvider);
  final defaultName =
      manifest?.shortName ?? manifest?.name ?? 'this web app';
  final tabState = selectedTabId != null
      ? ref.read(tabStateProvider(selectedTabId))
      : null;
  final url = tabState?.url ?? Uri.parse('about:blank');

  final config = await showPwaInstallBottomSheet(
    context,
    defaultName: defaultName,
    url: url,
  );

  if (config == null) return;

  final name = config.name;

  try {
    final success = await ref.read(
      installCurrentWebAppProvider(
        overrideName: name == defaultName ? null : name,
        contextId: config.contextId,
      ).future,
    );

    if (context.mounted) {
      if (success) {
        showInfoMessage(context, '$name added to home screen');
      } else {
        showErrorMessage(
          context,
          'Failed to add $name. The site may not support installation.',
        );
      }
    }
  } catch (e, stackTrace) {
    logger.e('Failed to install PWA', error: e, stackTrace: stackTrace);

    if (context.mounted) {
      var errorMessage = 'Failed to add $name to home screen';

      if (e is StateError) {
        errorMessage = 'No tab selected. Please try again.';
      }

      showErrorMessage(context, errorMessage);
    }
  }
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

  if (config == null) return;

  final name = config.name;
  final overrideName = name == defaultName ? null : name;

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
        showErrorMessage(context, 'Failed to add $name to home screen');
      }
    }
  } catch (e, stackTrace) {
    logger.e('Failed to create shortcut', error: e, stackTrace: stackTrace);

    if (context.mounted) {
      var errorMessage = 'Failed to add $name to home screen';

      if (e is StateError) {
        errorMessage = 'No tab selected. Please try again.';
      }

      showErrorMessage(context, errorMessage);
    }
  }
}
