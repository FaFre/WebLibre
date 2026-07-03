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
import 'package:flutter_hooks/flutter_hooks.dart';

/// Result of the delete-container confirmation.
class DeleteContainerDecision {
  /// Whether the container's browsing history should also be deleted from
  /// Mozilla Places. When false, the visit→container relation dissolves and the
  /// visits are kept (shown as uncontained).
  final bool wipeHistory;

  const DeleteContainerDecision({required this.wipeHistory});
}

/// Confirm container deletion. Returns the decision on confirm, or `null` if
/// cancelled/dismissed.
Future<DeleteContainerDecision?> showDeleteContainerDialog(
  BuildContext context,
) {
  return showDialog<DeleteContainerDecision?>(
    context: context,
    builder: (context) => const _DeleteContainerDialog(),
  );
}

class _DeleteContainerDialog extends HookWidget {
  const _DeleteContainerDialog();

  @override
  Widget build(BuildContext context) {
    final wipeHistory = useState(false);

    return AlertDialog(
      icon: const Icon(Icons.warning),
      title: const Text('Delete Container'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Are you sure you want to delete this container and close all '
            'attached tabs?',
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: wipeHistory.value,
            onChanged: (value) {
              wipeHistory.value = value ?? false;
            },
            title: const Text("Also delete this container's history"),
            subtitle: const Text(
              'Otherwise it is kept and shown as uncontained',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              DeleteContainerDecision(wipeHistory: wipeHistory.value),
            );
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
