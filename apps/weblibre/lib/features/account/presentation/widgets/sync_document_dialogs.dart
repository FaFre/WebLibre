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
import 'package:weblibre/features/account/data/repositories/account_sync_repository.dart';

// -- Metadata display helpers ------------------------------------------------

class MetadataRow extends StatelessWidget {
  const MetadataRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

String formatDateTime(DateTime dt) {
  final local = dt.toLocal();
  return '${local.year}-${_pad(local.month)}-${_pad(local.day)} '
      '${_pad(local.hour)}:${_pad(local.minute)}';
}

String _pad(int n) => n.toString().padLeft(2, '0');

// -- Dialogs -----------------------------------------------------------------

Future<String?> showStoreLabelDialog(BuildContext context) {
  final controller = TextEditingController();

  return showDialog<String?>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Store Snapshot'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Label (optional)',
          hintText: 'e.g. "Before update", "Home setup"',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final label = controller.text.trim();
            Navigator.of(context).pop(label.isEmpty ? '' : label);
          },
          child: const Text('Store'),
        ),
      ],
    ),
  );
}

Future<String?> showEditLabelDialog(
  BuildContext context, {
  String? currentLabel,
}) {
  final controller = TextEditingController(text: currentLabel);

  return showDialog<String?>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Label'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Label',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final label = controller.text.trim();
            Navigator.of(context).pop(label.isEmpty ? '' : label);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

Future<bool?> showRestoreConfirmation(
  BuildContext context, {
  required SyncDocumentMetadata metadata,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Restore Snapshot'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('This will overwrite your current local settings.'),
          const SizedBox(height: 16),
          if (metadata.label != null && metadata.label!.isNotEmpty)
            MetadataRow(label: 'Label', value: metadata.label!),
          MetadataRow(
            label: 'Stored',
            value: formatDateTime(metadata.updatedAt),
          ),
          if (metadata.sourceAppVersion != null)
            MetadataRow(
              label: 'App version',
              value: metadata.sourceAppVersion!,
            ),
          if (metadata.sourceDeviceId != null)
            MetadataRow(label: 'Device', value: metadata.sourceDeviceId!),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Restore'),
        ),
      ],
    ),
  );
}

Future<bool?> showDeleteConfirmation(
  BuildContext context, {
  required SyncDocumentMetadata metadata,
}) {
  final label = metadata.label?.isNotEmpty == true
      ? '"${metadata.label}"'
      : 'this snapshot';

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Snapshot'),
      content: Text('Are you sure you want to delete $label?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
