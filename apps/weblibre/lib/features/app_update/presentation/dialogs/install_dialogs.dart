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
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Before opening Android's "Install unknown apps" screen (8.5 step 1).
Future<bool> showInstallPermissionDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return _confirm(
    context,
    icon: Icons.security_update_good,
    title: l10n.appUpdate_permissionDialogTitle,
    body: l10n.appUpdate_permissionDialogBody,
    confirmLabel: l10n.appUpdate_permissionDialogOpenSettings,
  );
}

/// Before Android's own install confirmation, which every update shows (#722),
/// and the close that follows (8.5 step 2).
Future<bool> showInstallConfirmDialog(
  BuildContext context, {
  required bool privateTabsOpen,
}) {
  final l10n = AppLocalizations.of(context);
  return _confirm(
    context,
    icon: Icons.system_update,
    title: l10n.appUpdate_installDialogTitle,
    body: privateTabsOpen
        ? l10n.appUpdate_installDialogBodyPrivateTabs
        : l10n.appUpdate_installDialogBody,
    confirmLabel: l10n.appUpdate_actionInstall,
  );
}

Future<bool> _confirm(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String body,
  required String confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(icon),
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(AppLocalizations.of(context).common_cancel),
        ),
        // Text buttons, like the app's other confirmations
        // (RememberablePromptDialog).
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
