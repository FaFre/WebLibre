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
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    show BackupTreeProbeOutcome, TreePublicationFault;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/maintenance/saf_archive_target.dart';
import 'package:weblibre/features/about/domain/providers.dart';
import 'package:weblibre/features/settings/domain/entities/settings_export_document.dart';
import 'package:weblibre/features/settings/domain/providers/settings_export_directory.dart';
import 'package:weblibre/features/settings/domain/services/settings_transfer_service.dart';
import 'package:weblibre/features/settings/presentation/dialogs/settings_import_dialog.dart';
import 'package:weblibre/features/settings/presentation/utils/settings_export_document_l10n.dart';
import 'package:weblibre/features/settings/presentation/utils/settings_transfer_service_l10n.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/saf_tree_uri.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// MIME type an export is written and picked with. Kept plain `application/json`
/// so other apps — a file manager, a mail client, a bug tracker — recognise it.
const _exportMimeType = 'application/json';

class SettingsTransferScreen extends HookConsumerWidget {
  const SettingsTransferScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final selected = useState<Set<SettingsTransferSection>>(
      SettingsTransferSection.values.toSet(),
    );
    final busy = useState(false);

    // Held across the folder picker rather than read after it: the picker is a
    // different activity, and this screen is not guaranteed to still be mounted
    // when it returns.
    final exportDirectory = ref.read(
      settingsExportDirectoryUriProvider.notifier,
    );

    Future<String> buildExport() {
      final info = ref.read(packageInfoProvider).value;

      return ref
          .read(settingsTransferServiceProvider.notifier)
          .export(
            sections: selected.value,
            appVersion: info == null
                ? null
                : '${info.version}+${info.buildNumber}',
          );
    }

    /// Resolves the folder exports are written to, asking for one only when
    /// there is nothing usable remembered.
    ///
    /// Only the grant list is read here, which costs nothing: a grant that was
    /// revoked asks for a folder straight away. A folder that is gone, or that
    /// refuses files although its grant is still on record (#698), is found
    /// by the write, which says so itself — checking for it here would cost a
    /// test file in the provider on every export. The grant is asked the way
    /// the write asks for it, so a folder that passes here is not turned away
    /// there.
    Future<Uri?> resolveTargetFolder() async {
      final remembered = ref.read(settingsExportDirectoryUriProvider);
      if (remembered != null && await safTreeHasGrant(remembered)) {
        return remembered;
      }

      final picked = await pickWritableSafFolder();
      if (picked == null) return null;

      exportDirectory.set(picked.tree);

      return picked.tree;
    }

    /// Lets the user move exports somewhere else without having to make one
    /// fail first.
    Future<void> chooseExportFolder() async {
      final picked = await pickWritableSafFolder();
      if (picked == null) return;

      exportDirectory.set(picked.tree);

      if (!context.mounted) return;
      showInfoMessage(
        context,
        l10n.settings_transferExportFolderChanged(picked.name),
      );
    }

    Future<void> exportToFile() async {
      busy.value = true;

      try {
        final text = await buildExport();

        final target = await resolveTargetFolder();
        if (target == null) return;

        // Written as `.partial`, checked and only then renamed, the way a
        // profile backup is: a full volume must not leave a truncated export
        // wearing a finished file's name, because it will be imported one day.
        final String written;
        try {
          written = await publishBytesToSaf(
            bytes: Uint8List.fromList(utf8.encode(text)),
            targetTree: target,
            fileName: settingsExportFileName(DateTime.now()),
            mimeType: _exportMimeType,
          );
        } on BackupTargetUnavailable {
          // The grant outlives the folder: a target that was deleted, or lives
          // on a volume that is gone, still passes the grant check, so it would
          // be handed back for every export and each would fail the same way
          // with no picker in sight. Only a write that blames the folder gives
          // it up — a full disk or a provider that failed keeps it.
          exportDirectory.set(null);
          rethrow;
        }

        if (!context.mounted) return;
        // The name SAF actually created, which is not always the one asked
        // for — a second export in the same second gets a suffix.
        showInfoMessage(context, l10n.settings_transferSavedAs(written));
      } catch (error, stackTrace) {
        logger.e(
          'Failed to export settings to a file',
          error: error,
          stackTrace: stackTrace,
        );
        if (context.mounted) {
          showErrorMessage(context, switch (error) {
            BackupTargetUnavailable(outcome: BackupTreeProbeOutcome.missing) =>
              l10n.settings_transferExportFolderGone,
            // Still there, but no grant or no files accepted: choosing it
            // again renews the access, which "no longer there" would not
            // suggest.
            BackupTargetUnavailable() =>
              l10n.settings_transferExportFolderRefused,
            BackupTargetFull() => l10n.settings_transferExportFolderFull,
            BackupWriteFailed(fault: TreePublicationFault.truncated) =>
              l10n.settings_transferExportIncomplete,
            BackupWriteFailed(:final detail?) =>
              l10n.settings_transferSaveFailed(detail),
            BackupWriteFailed() => l10n.settings_transferSaveFailedNoDetail,
            _ => l10n.settings_transferSaveFailed('$error'),
          });
        }
      } finally {
        busy.value = false;
      }
    }

    Future<void> exportToClipboard() async {
      busy.value = true;
      try {
        await Clipboard.setData(ClipboardData(text: await buildExport()));

        if (!context.mounted) return;
        showInfoMessage(context, l10n.settings_transferCopiedToClipboard);
      } catch (error, stackTrace) {
        logger.e(
          'Failed to copy settings to the clipboard',
          error: error,
          stackTrace: stackTrace,
        );
        if (context.mounted) {
          showErrorMessage(context, l10n.settings_transferCopyFailed('$error'));
        }
      } finally {
        busy.value = false;
      }
    }

    Future<void> applyImport(String text) async {
      final service = ref.read(settingsTransferServiceProvider.notifier);

      final SettingsExportDocument document;
      try {
        document = decodeSettingsExport(text);
      } on SettingsExportFormatException catch (error) {
        if (context.mounted) showErrorMessage(context, error.describe(l10n));
        return;
      }

      final available = service.availableSections(document);
      if (available.isEmpty) {
        if (context.mounted) {
          showErrorMessage(
            context,
            l10n.settings_transferImportNothingApplicable,
          );
        }
        return;
      }

      if (!context.mounted) return;
      final sections = await showSettingsImportDialog(
        context,
        document: document,
        available: available,
      );
      if (sections == null || sections.isEmpty) return;

      busy.value = true;
      try {
        await service.import(document: document, sections: sections);

        if (!context.mounted) return;
        showInfoMessage(context, l10n.settings_transferImportedSuccess);
      } on SettingsImportPartialFailure catch (error, stackTrace) {
        logger.e(
          'Settings import applied only some sections',
          error: error,
          stackTrace: stackTrace,
        );
        if (context.mounted) {
          // Deliberately not "the import failed": part of it did not, and a
          // user told otherwise would go looking for settings that are already
          // replaced.
          showErrorMessage(context, error.describe(l10n), persist: true);
        }
      } catch (error, stackTrace) {
        logger.e(
          'Failed to import settings',
          error: error,
          stackTrace: stackTrace,
        );
        if (context.mounted) {
          showErrorMessage(
            context,
            error is SettingsExportFormatException
                ? error.describe(l10n)
                : l10n.settings_transferImportFailed('$error'),
          );
        }
      } finally {
        busy.value = false;
      }
    }

    Future<void> importFromFile() async {
      busy.value = true;
      try {
        final picked = await SafUtil().pickFile(
          mimeTypes: const [_exportMimeType],
        );
        if (picked == null) return;

        final bytes = await SafStream().readFileBytes(picked.uri);
        await applyImport(utf8.decode(bytes));
      } on FormatException {
        // Reached when the picked file is not even text.
        if (context.mounted) {
          showErrorMessage(context, l10n.settings_transferNotASettingsFile);
        }
      } catch (error, stackTrace) {
        logger.e(
          'Failed to read a settings export',
          error: error,
          stackTrace: stackTrace,
        );
        if (context.mounted) {
          showErrorMessage(
            context,
            l10n.settings_transferReadFileFailed('$error'),
          );
        }
      } finally {
        busy.value = false;
      }
    }

    Future<void> importFromClipboard() async {
      busy.value = true;
      try {
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        final text = data?.text;
        if (text == null || text.trim().isEmpty) {
          if (context.mounted) {
            showErrorMessage(context, l10n.settings_transferClipboardEmpty);
          }
          return;
        }

        await applyImport(text);
      } catch (error, stackTrace) {
        // The file path has always had this. Without it here, anything the
        // decoder does not turn into a SettingsExportFormatException — a
        // clipboard full of something else entirely — leaves the button
        // callback with an unhandled exception and the user with no message.
        logger.e(
          'Failed to import settings from the clipboard',
          error: error,
          stackTrace: stackTrace,
        );
        if (context.mounted) {
          showErrorMessage(
            context,
            l10n.settings_transferReadClipboardFailed('$error'),
          );
        }
      } finally {
        busy.value = false;
      }
    }

    return SettingsCustomScrollScaffold(
      title: l10n.settings_transferTitle,
      actions: [
        MenuAnchor(
          menuChildren: [
            MenuItemButton(
              onPressed: busy.value ? null : chooseExportFolder,
              child: Text(l10n.settings_transferChangeExportFolder),
            ),
          ],
          builder: (context, controller, child) => IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () =>
                controller.isOpen ? controller.close() : controller.open(),
          ),
        ),
      ],
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Text(
                  l10n.settings_transferIntro,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                // Said out loud rather than discovered: these live outside the
                // settings repositories an export reads, so neither this nor
                // account sync carries them yet.
                Text(
                  l10n.settings_transferDeviceOnlyNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: theme.colorScheme.surfaceContainerHigh,
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    leading: const Icon(MdiIcons.fileExportOutline),
                    title: Text(l10n.settings_transferExportSectionTitle),
                    subtitle: Text(l10n.settings_transferExportSectionSubtitle),
                  ),
                  for (final section in SettingsTransferSection.values)
                    CheckboxListTile(
                      value: selected.value.contains(section),
                      onChanged: busy.value
                          ? null
                          : (checked) {
                              selected.value = {
                                for (final candidate
                                    in SettingsTransferSection.values)
                                  if (candidate == section
                                      ? checked ?? false
                                      : selected.value.contains(candidate))
                                    candidate,
                              };
                            },
                      title: Text(section.label(l10n)),
                      subtitle: Text(section.description(l10n)),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: busy.value || selected.value.isEmpty
                                ? null
                                : exportToFile,
                            icon: const Icon(Icons.save_outlined),
                            label: Text(l10n.settings_transferSaveFileButton),
                          ),
                        ),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: busy.value || selected.value.isEmpty
                                ? null
                                : exportToClipboard,
                            icon: const Icon(Icons.copy_outlined),
                            label: Text(l10n.common_copy),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Card(
              color: theme.colorScheme.surfaceContainerHigh,
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    leading: const Icon(MdiIcons.fileImportOutline),
                    title: Text(l10n.settings_transferImportSectionTitle),
                    subtitle: Text(l10n.settings_transferImportSectionSubtitle),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: busy.value ? null : importFromFile,
                            icon: const Icon(Icons.folder_open_outlined),
                            label: Text(l10n.settings_transferOpenFileButton),
                          ),
                        ),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: busy.value ? null : importFromClipboard,
                            icon: const Icon(Icons.paste_outlined),
                            label: Text(l10n.settings_transferPasteButton),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
