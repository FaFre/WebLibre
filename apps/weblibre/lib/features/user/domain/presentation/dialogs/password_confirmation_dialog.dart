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
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Dialog to confirm password during backup creation.
/// Returns the entered password string if confirmed, null if cancelled or dismissed.
Future<String?> showPasswordConfirmationDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) {
      final controller = TextEditingController();
      final l10n = AppLocalizations.of(context);

      return AlertDialog(
        title: Text(l10n.user_passwordConfirmationTitle),
        content: TextField(
          controller: controller,
          enableSuggestions: false,
          autocorrect: false,
          enableIMEPersonalizedLearning: false,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.user_passwordFieldLabel,
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(controller.text);
            },
            child: Text(l10n.user_actionConfirm),
          ),
        ],
      );
    },
  );
}
