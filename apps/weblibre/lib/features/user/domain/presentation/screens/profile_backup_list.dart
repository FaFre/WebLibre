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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:saf_util/saf_util.dart';
import 'package:weblibre/core/maintenance/backup_archive_name.dart';
import 'package:weblibre/core/providers/format.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/providers/backup_directory.dart';
import 'package:weblibre/features/user/domain/services/user_backup.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class ProfileBackupListScreen extends HookConsumerWidget {
  final void Function(BuildContext context, Uri backupFileUri)?
  onBackupSelected;

  const ProfileBackupListScreen({super.key, this.onBackupSelected});

  Future<void> _handleSelection(BuildContext context, Uri backupFileUri) async {
    if (onBackupSelected != null) {
      onBackupSelected!(context, backupFileUri);
    } else {
      await RestoreProfileRoute(
        backupFileUri: backupFileUri.toString(),
      ).push(context);
    }
  }

  Future<void> _pickDirectory(WidgetRef ref) async {
    final dir = await SafUtil().pickDirectory(
      writePermission: true,
      persistablePermission: true,
    );

    if (dir != null) {
      final dirUri = Uri.parse(dir.uri);
      ref.read(backupDirectoryUriProvider.notifier).set(dirUri);

      final migrated = await ref
          .read(userBackupServiceProvider.notifier)
          .migrateOldBackups(dirUri);

      if (migrated > 0) {
        ref.invalidate(backupListProvider);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dirUri = ref.watch(backupDirectoryUriProvider);
    final backupListAsync = ref.watch(backupListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backups'),
        actions: [
          IconButton(
            icon: const Icon(MdiIcons.folderCog),
            tooltip: 'Change backup folder',
            onPressed: () => _pickDirectory(ref),
          ),
        ],
      ),
      body: SafeArea(
        child: dirUri == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(MdiIcons.folderOpen, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'Choose where to store your backups.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pick a location outside the app, so the backups '
                        'survive uninstalling it.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        icon: const Icon(MdiIcons.folderPlus),
                        label: const Text('Choose folder'),
                        onPressed: () => _pickDirectory(ref),
                      ),
                    ],
                  ),
                ),
              )
            : backupListAsync.when(
                data: (backupList) {
                  if (backupList.isEmpty) {
                    return const Center(child: Text('No backups found'));
                  }

                  return ListView.builder(
                    itemCount: backupList.length,
                    itemBuilder: (context, index) {
                      final file = backupList[index];
                      final parsed = BackupArchiveName.tryParse(file.name);

                      if (parsed != null) {
                        final profileName = parsed.profileName;
                        final dateTime = parsed.createdAt;

                        return ListTile(
                          key: ValueKey(file.uri),
                          title: Text(profileName),
                          subtitle: Text(
                            ref
                                .read(formatProvider.notifier)
                                .fullDateTime(dateTime),
                          ),
                          onTap: () =>
                              _handleSelection(context, Uri.parse(file.uri)),
                        );
                      } else {
                        return ListTile(
                          key: ValueKey(file.uri),
                          title: Text(file.name),
                          onTap: () =>
                              _handleSelection(context, Uri.parse(file.uri)),
                        );
                      }
                    },
                  );
                },
                error: (error, stackTrace) => FailureWidget(
                  title: 'Could not load backups',
                  exception: error,
                  onRetry: () {
                    ref.invalidate(backupListProvider);
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
      ),
    );
  }
}
