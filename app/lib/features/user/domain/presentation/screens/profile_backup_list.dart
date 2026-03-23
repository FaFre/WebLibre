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
import 'package:weblibre/core/providers/format.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/providers/backup_directory.dart';
import 'package:weblibre/features/user/domain/services/user_backup.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

final _filenamePattern = RegExp(
  r'^backup_(?<profile>.+?)_(?<timestamp>\d{4}-\d{2}-\d{2}_\d{6})\.weblibre$',
);

class ProfileBackupListScreen extends HookConsumerWidget {
  const ProfileBackupListScreen({super.key});

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
            tooltip: 'Change backup directory',
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
                        'Select a directory to store your backups.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Choose a location outside of the app to keep your backups safe across reinstalls.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        icon: const Icon(MdiIcons.folderPlus),
                        label: const Text('Select Backup Directory'),
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
                      final match = _filenamePattern.firstMatch(file.name);

                      if (match != null) {
                        final profileName = match.group(1)!;
                        final datePart = match.group(2)!;

                        final dateTime = UserBackupService.dateFormatter.decode(
                          datePart,
                        );

                        return ListTile(
                          key: ValueKey(file.uri),
                          title: Text(profileName),
                          subtitle: Text(
                            ref
                                .read(formatProvider.notifier)
                                .fullDateTime(dateTime),
                          ),
                          onTap: () async {
                            await RestoreProfileRoute(
                              backupFileUri: file.uri,
                            ).push(context);
                          },
                        );
                      } else {
                        return ListTile(
                          key: ValueKey(file.uri),
                          title: Text(file.name),
                          onTap: () async {
                            await RestoreProfileRoute(
                              backupFileUri: file.uri,
                            ).push(context);
                          },
                        );
                      }
                    },
                  );
                },
                error: (error, stackTrace) => FailureWidget(
                  title: 'Failed to get backups',
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
