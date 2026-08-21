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
import 'package:go_router/go_router.dart';

/// Shows a confirmation dialog for switching user profiles.
///
/// Returns `true` if the user confirms the switch, or null if dismissed.
Future<bool?> showSwitchProfileDialog(
  BuildContext context, {
  required String profileName,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);

      return AlertDialog(
        icon: const Icon(Icons.swap_horiz),
        title: Text('Switch to "$profileName"?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('WebLibre closes and reopens as "$profileName".'),
            const SizedBox(height: 12),
            // The two consequences worth knowing, as their own lines rather than
            // one bolded paragraph: emphasising everything emphasises nothing,
            // and these are consequences to read, not a warning to alarm.
            Text(
              '• Private tabs are cleared.\n'
              '• Web notifications for the profile you leave are paused.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(false);
            },
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () {
              context.pop(true);
            },
            child: const Text('Switch and restart'),
          ),
        ],
      );
    },
  );
}
