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
import 'package:weblibre/features/account/data/repositories/account_sync_repository.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

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
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) {
      final l10n = AppLocalizations.of(context);

      return AlertDialog(
        title: Text(l10n.account_storeSnapshotTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.account_fieldLabelOptional,
            hintText: l10n.account_labelHintExample,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () {
              final label = controller.text.trim();
              Navigator.of(context).pop(label.isEmpty ? '' : label);
            },
            child: Text(l10n.account_actionStore),
          ),
        ],
      );
    },
  );
}

Future<String?> showEditLabelDialog(
  BuildContext context, {
  String? currentLabel,
}) {
  final controller = TextEditingController(text: currentLabel);

  return showDialog<String?>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) {
      final l10n = AppLocalizations.of(context);

      return AlertDialog(
        title: Text(l10n.account_actionEditLabel),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.account_fieldLabel,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () {
              final label = controller.text.trim();
              Navigator.of(context).pop(label.isEmpty ? '' : label);
            },
            child: Text(l10n.common_save),
          ),
        ],
      );
    },
  );
}

Future<bool?> showRestoreConfirmation(
  BuildContext context, {
  required SyncDocumentMetadata metadata,
}) {
  return showDialog<bool>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) {
      final l10n = AppLocalizations.of(context);

      return AlertDialog(
        title: Text(l10n.account_restoreSnapshotTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.account_restoreOverwriteWarning),
            const SizedBox(height: 16),
            if (metadata.label != null && metadata.label!.isNotEmpty)
              MetadataRow(
                label: l10n.account_metaLabel,
                value: metadata.label!,
              ),
            MetadataRow(
              label: l10n.account_metaStored,
              value: formatDateTime(metadata.updatedAt),
            ),
            if (metadata.sourceAppVersion != null)
              MetadataRow(
                label: l10n.account_metaAppVersion,
                value: metadata.sourceAppVersion!,
              ),
            if (metadata.sourceDeviceId != null)
              MetadataRow(
                label: l10n.account_metaDevice,
                value: metadata.sourceDeviceId!,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.account_actionRestore),
          ),
        ],
      );
    },
  );
}

Future<bool?> showDeleteConfirmation(
  BuildContext context, {
  required SyncDocumentMetadata metadata,
}) {
  return showDialog<bool>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      final label = metadata.label?.isNotEmpty == true
          ? '"${metadata.label}"'
          : l10n.account_thisSnapshotFallback;

      return AlertDialog(
        title: Text(l10n.account_deleteSnapshotTitle),
        content: Text(l10n.account_deleteSnapshotConfirm(label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.common_delete),
          ),
        ],
      );
    },
  );
}
