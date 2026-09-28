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
import 'package:weblibre/features/account/presentation/widgets/sync_document_dialogs.dart';
import 'package:weblibre/features/settings/domain/entities/settings_export_document.dart';
import 'package:weblibre/features/settings/domain/services/settings_transfer_service.dart';
import 'package:weblibre/features/settings/presentation/utils/settings_transfer_service_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Confirms an import and picks which of the file's sections to apply.
///
/// The picking happens here rather than on the screen because the answer
/// depends on the file: offering a section the export does not contain is a
/// checkbox that does nothing.
///
/// Returns the sections to apply, or null if the user backed out.
Future<Set<SettingsTransferSection>?> showSettingsImportDialog(
  BuildContext context, {
  required SettingsExportDocument document,
  required Set<SettingsTransferSection> available,
}) {
  return showDialog<Set<SettingsTransferSection>>(
    context: context,
    builder: (context) =>
        _SettingsImportDialog(document: document, available: available),
  );
}

class _SettingsImportDialog extends HookWidget {
  const _SettingsImportDialog({
    required this.document,
    required this.available,
  });

  final SettingsExportDocument document;
  final Set<SettingsTransferSection> available;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = useState<Set<SettingsTransferSection>>({...available});
    final theme = Theme.of(context);

    // Kinds the file carries that this build has nothing to apply them with.
    // Named rather than dropped: "the file also holds something I can't use"
    // is the difference between an old export and a broken one.
    final unknown = document.documents.keys
        .where((key) => SettingsTransferSection.forKindValue(key) == null)
        .toList();

    return AlertDialog(
      title: Text(l10n.settings_importSettingsTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settings_importSettingsDescription),
            const SizedBox(height: 16),
            for (final section in SettingsTransferSection.values)
              if (available.contains(section))
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  value: selected.value.contains(section),
                  onChanged: (checked) {
                    selected.value = {
                      for (final candidate in SettingsTransferSection.values)
                        if (candidate == section
                            ? checked ?? false
                            : selected.value.contains(candidate))
                          candidate,
                    };
                  },
                  title: Text(section.label(l10n)),
                  subtitle: Text(section.description(l10n)),
                ),
            if (unknown.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.settings_unreadableSections(
                  unknown.length,
                  unknown.map((key) => '"$key"').join(', '),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (document.exportedAt case final exportedAt?)
              MetadataRow(
                label: l10n.settings_exportedLabel,
                value: formatDateTime(exportedAt),
              ),
            if (document.appVersion case final appVersion?)
              MetadataRow(
                label: l10n.settings_appVersionLabel,
                value: appVersion,
              ),
            if (selected.value.contains(SettingsTransferSection.settings)) ...[
              const SizedBox(height: 12),
              Text(
                l10n.settings_credentialsNotCarried,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (selected.value.contains(
              SettingsTransferSection.geckoPrefs,
            )) ...[
              const SizedBox(height: 12),
              Text(
                l10n.settings_geckoPrefsRestartNote,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          onPressed: selected.value.isEmpty
              ? null
              : () => Navigator.of(context).pop(selected.value),
          child: Text(l10n.settings_replace),
        ),
      ],
    );
  }
}
