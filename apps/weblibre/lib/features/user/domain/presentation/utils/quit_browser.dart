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
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/quit_browser_dialog.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/exit_app.dart';

/// Tears the app down. Injectable so a test can confirm a quit without the real
/// implementation ending the process; [exitApp] is the real one.
typedef ExitAppCallback =
    Future<void> Function(
      ProviderContainer container, {
      Set<DeleteBrowsingDataType>? deleteBrowsingData,
    });

/// An explicit Quit: asks first unless [GeneralSettings.confirmBeforeQuit] is
/// off or [confirm] is false (a long press), then tears down while deleting
/// [GeneralSettings.autoDeleteBrowsingData] and anything picked in the
/// confirmation for this Quit only.
///
/// "Don't ask again" ends the only way to pick data for one Quit, so what was
/// picked along with it is added to the automatic deletion instead of being
/// dropped from every Quit after this one. See [withQuitDeletionSaved].
///
/// Takes the [container] rather than a `ref` because the menu sheet that
/// starts a Quit is gone by the time the confirmation is answered. [context]
/// only has to be mounted when this is called.
Future<void> quitBrowser(
  BuildContext context,
  ProviderContainer container, {
  bool confirm = true,
  ExitAppCallback onExit = exitApp,
}) async {
  // The root navigator outlives the menu sheet [context] may belong to, which
  // is torn down while the settings load. It has to be looked up now.
  final navigatorContext = Navigator.of(context, rootNavigator: true).context;

  // Awaited rather than read from the cached value: deleting less than the
  // user chose because the settings had not loaded yet must not be possible.
  final settings = await container
      .read(generalSettingsRepositoryProvider.notifier)
      .fetchSettings();
  var deletes = settings.autoDeleteBrowsingData;

  if (confirm && settings.confirmBeforeQuit) {
    if (!navigatorContext.mounted) return;

    final result = await showQuitConfirmationDialog(
      navigatorContext,
      alwaysDeleted: deletes ?? const {},
      deletesOnStart: _deletesOnStart(settings),
    );
    if (result == null) return;

    // Includes what was picked for this Quit only, which is never saved.
    deletes = result.deletes;

    if (result.dontAskAgain) {
      // Awaited: the teardown closes the database next. A failed save is no
      // reason to refuse the Quit that was just confirmed.
      try {
        await container
            .read(generalSettingsRepositoryProvider.notifier)
            .updateSettings(
              (current) => withQuitDeletionSaved(
                current,
                result.deletes,
              ).copyWith.confirmBeforeQuit(false),
            );
      } catch (e, st) {
        logger.e(
          'Failed to save the quit confirmation choice',
          error: e,
          stackTrace: st,
        );
      }
    }
  }

  await onExit(container, deleteBrowsingData: deletes);
}

/// Whether the automatic deletion also runs on every start.
bool _deletesOnStart(GeneralSettings settings) =>
    settings.autoDeleteBrowsingData != null &&
    settings.autoDeleteBrowsingDataOnStart;

/// [settings] with [deletes], what a Quit confirmed with "Don't ask again"
/// deleted, made part of the automatic deletion so every later Quit deletes it
/// too.
///
/// Turning automatic deletion on from here keeps it to Quit: the dialog only
/// ever asked about Quit, and deleting on start as well is a separate choice
/// in the settings. Already on, it keeps its own start setting.
@visibleForTesting
GeneralSettings withQuitDeletionSaved(
  GeneralSettings settings,
  Set<DeleteBrowsingDataType> deletes,
) {
  final automatic = settings.autoDeleteBrowsingData;
  if (automatic != null && automatic.containsAll(deletes)) return settings;
  if (automatic == null && deletes.isEmpty) return settings;

  return settings.copyWith(
    autoDeleteBrowsingData: {...?automatic, ...deletes},
    autoDeleteBrowsingDataOnStart:
        automatic != null && settings.autoDeleteBrowsingDataOnStart,
  );
}
