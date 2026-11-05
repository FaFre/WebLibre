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

/// The overflow menu of an arrangement editor (toolbar buttons, the browser
/// menu): "Reset to Defaults" behind ⋮, where an app bar keeps it, rather
/// than a button next to the content it would wipe.
class ResetToDefaultsMenu extends StatelessWidget {
  const ResetToDefaultsMenu({
    super.key,
    required this.onReset,
    this.onOpenFullScreen,
  });

  final VoidCallback onReset;

  /// Offers "Open full screen" too, for an editor shown inline beside the
  /// layout preview, where a small window leaves it little room.
  final VoidCallback? onOpenFullScreen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MenuAnchor(
      menuChildren: [
        if (onOpenFullScreen case final open?)
          MenuItemButton(
            leadingIcon: const Icon(Icons.open_in_full),
            onPressed: open,
            child: Text(l10n.settings_actionOpenFullScreen),
          ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.restore),
          onPressed: onReset,
          child: Text(l10n.settings_actionResetToDefaults),
        ),
      ],
      builder: (context, controller, child) => IconButton(
        tooltip: MaterialLocalizations.of(context).showMenuTooltip,
        icon: const Icon(Icons.more_vert),
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}
