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
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.warning),
      title: const Text('Switch User'),
      content: Text(
        "Switching to User '$profileName' will require a restart of the Browser.",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop(false);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            context.pop(true);
          },
          child: const Text('Switch Profile'),
        ),
      ],
    ),
  );
}
