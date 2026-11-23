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
import 'package:weblibre/presentation/utils/units_l10n.dart';

/// The choices of "Freeze automatically" (phase C2), in minutes. Counted
/// while WebLibre is open, so longer ones would rarely come due.
const autoFreezeChoices = [15, 30, 60, 120, 240];

/// The "Off" choice of [showAutoFreezeDialog].
const autoFreezeOff = 0;

/// Asks after how long unused a container freezes automatically. Returns the
/// minutes, [autoFreezeOff], or null when dismissed. [current] stays a choice
/// when it is not one of [autoFreezeChoices].
Future<int?> showAutoFreezeDialog(BuildContext context, {int? current}) {
  final l10n = AppLocalizations.of(context);
  final choices = {...autoFreezeChoices, ?current}.toList()..sort();
  return showDialog<int>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) => AlertDialog(
      icon: const Icon(MdiIcons.pause),
      title: Text(l10n.tabs_autoFreezeTitle),
      contentPadding: const EdgeInsets.only(top: 16, bottom: 8),
      content: SingleChildScrollView(
        child: RadioGroup<int>(
          groupValue: current ?? autoFreezeOff,
          onChanged: (value) => Navigator.pop(context, value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(l10n.tabs_autoFreezeExplanation),
              ),
              const SizedBox(height: 8),
              RadioListTile<int>(
                value: autoFreezeOff,
                title: Text(l10n.tabs_autoFreezeOff),
              ),
              for (final minutes in choices)
                RadioListTile<int>(
                  value: minutes,
                  title: Text(formatMinutes(l10n, minutes)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.common_cancel),
        ),
      ],
    ),
  );
}
