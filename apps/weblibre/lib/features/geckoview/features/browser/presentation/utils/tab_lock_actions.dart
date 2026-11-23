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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:weblibre/core/providers/provider_read.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_lock.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/tab_lock_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// The name of the lock action for a tab in that state: Lock tab, Unlock tab,
/// or Retry unlocking tab after an unlock that did not finish.
String lockTabActionLabel(
  AppLocalizations l10n, {
  required bool locked,
  required bool unlockIncomplete,
}) => unlockIncomplete
    ? l10n.browser_retryUnlockTab
    : locked
    ? l10n.browser_unlockTab
    : l10n.browser_lockTab;

/// The icon of the lock action named by [lockTabActionLabel].
IconData lockTabActionIcon({
  required bool locked,
  required bool unlockIncomplete,
}) => unlockIncomplete
    ? MdiIcons.lockAlertOutline
    : locked
    ? MdiIcons.lockOpenVariantOutline
    : MdiIcons.lockOutline;

/// Locks [tabId], or unlocks it when it counts as locked — which includes a
/// tab whose unlock did not finish, so this is also its retry. Says so when
/// that did not work; success shows in the tab's lock badge.
Future<void> toggleTabLock(
  BuildContext context,
  ProviderRead read,
  String tabId,
) async {
  final (:outcome, :wasLocked) = await read(
    tabRepositoryProvider.notifier,
  ).toggleTabLocked(tabId);
  if (!context.mounted) return;

  final described = outcome.describe(
    AppLocalizations.of(context),
    wasLocked: wasLocked,
  );
  if (described case (:final text, :final failed)) {
    ui_helper.showOutcomeMessage(context, text, failed: failed);
  }
}

/// Says that [tabId] is locked, after a close of it was refused, and offers
/// Unlock (which is also the retry of an unlock that did not finish). The
/// Unlock may come after the widget that refused the close is gone (a toolbar
/// that hid, a tray that closed), so what it needs is taken now.
void showTabLockedMessage(
  BuildContext context,
  ProviderRead read,
  String tabId,
) {
  final l10n = AppLocalizations.of(context);
  final repository = read(tabRepositoryProvider.notifier);
  final showError = ui_helper.errorMessengerFor(context);
  ui_helper.showInfoMessage(
    context,
    l10n.browser_tabIsLocked,
    action: SnackBarAction(
      label: l10n.browser_unlockTabShort,
      onPressed: () async {
        final outcome = await repository.setTabLocked(tabId, locked: false);
        // Success shows in the tab itself: its close control comes back.
        if (outcome.describe(l10n, wasLocked: true) case (
          :final text,
          failed: true,
        )) {
          showError(text);
        }
      },
    ),
  );
}

/// Tells the user why a tab did not move to another container, when it did
/// not ([result]).
void showContainerMoveResult(BuildContext context, ContainerMoveResult result) {
  if (result.describe(AppLocalizations.of(context)) case (
    :final text,
    :final failed,
  )) {
    ui_helper.showOutcomeMessage(context, text, failed: failed);
  }
}
