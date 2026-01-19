/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

/// Result of the switch profile dialog.
/// - `shouldSwitch`: Whether the user confirmed the switch.
/// - `clearCache`: Whether to clear the shared cache.
typedef SwitchProfileDialogResult = ({bool shouldSwitch, bool clearCache});

/// Shows a confirmation dialog for switching user profiles.
///
/// Returns a [SwitchProfileDialogResult] if the user confirms, or null if dismissed.
/// If [duplicateMozillaProfile] is provided, shows an option to clear shared cache.
Future<SwitchProfileDialogResult?> showSwitchProfileDialog(
  BuildContext context, {
  required String profileName,
  String? duplicateMozillaProfile,
}) {
  return showDialog<SwitchProfileDialogResult>(
    context: context,
    builder: (context) => HookBuilder(
      builder: (context) {
        final clearCache = useState(false);

        return AlertDialog(
          icon: const Icon(Icons.warning),
          title: const Text('Switch User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Switching to User '$profileName' will require a restart of the Browser.",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (duplicateMozillaProfile != null)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: clearCache.value,
                  title: const Text('Clear Shared Cache'),
                  subtitle: const Text(
                    'This User has been created based on an exisiting Mozilla Profile Identifier. Clearing cache will affect all linked accounts.',
                  ),
                  onChanged: (value) {
                    clearCache.value = value;
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop((shouldSwitch: false, clearCache: false));
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.pop((shouldSwitch: true, clearCache: clearCache.value));
              },
              child: const Text('Switch Profile'),
            ),
          ],
        );
      },
    ),
  );
}
