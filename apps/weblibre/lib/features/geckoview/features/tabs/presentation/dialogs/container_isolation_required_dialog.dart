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
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Explains why a saved container without cookie isolation can't take a proxy,
/// strict mode and the other settings keyed on a Gecko contextId.
///
/// Shown where such a setting is locked rather than leaving a greyed-out row
/// that ignores taps (#678): isolation is fixed when a container is created,
/// so the only way forward is a new container.
Future<void> showContainerIsolationRequiredDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) {
      final l10n = AppLocalizations.of(context);

      return AlertDialog(
        // Two paragraphs outgrow a short landscape window or large text.
        scrollable: true,
        icon: const Icon(MdiIcons.cookieLock),
        title: Text(l10n.tabs_isolationRequiredTitle),
        content: Text(l10n.tabs_isolationRequiredBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.common_close),
          ),
        ],
      );
    },
  );
}
