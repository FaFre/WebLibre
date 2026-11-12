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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/providers/backup_directory.dart';
import 'package:weblibre/features/user/domain/services/user_backup.dart';
import 'package:weblibre/utils/saf_tree_uri.dart';

/// Opens the system folder picker and makes the answer the backup folder.
///
/// Returns the folder picked, or null when the picker was cancelled.
///
/// Picking the folder that is already set is not a no-op: the picker takes the
/// persistable grant afresh. [BackupDirectoryUri] announces it like any other
/// pick, so whatever is read from the folder is read again.
///
/// [migrateLegacyBackups] also moves backups an old version kept in app
/// storage into the chosen folder. Only where backups are being managed: it
/// copies every one of them, and the backup screen has a backup to start, not
/// hundreds of megabytes to wait on before its folder check even runs. The
/// folder is set first, so its list shows straight away, and read again once
/// the migration has written into it.
///
/// [accept] decides whether the pick becomes the backup folder. A pick it turns
/// down is still returned, and leaves the folder that was set in place.
///
/// Everything it writes to is captured before the picker opens. The picker is
/// a different activity, and the screen that asked is not guaranteed to still
/// be mounted when it returns.
Future<Uri?> chooseBackupFolder(
  WidgetRef ref, {
  bool migrateLegacyBackups = false,
  Future<bool> Function(Uri picked)? accept,
}) async {
  final backupDirectory = ref.read(backupDirectoryUriProvider.notifier);
  final backupService = ref.read(userBackupServiceProvider.notifier);
  final container = ref.container;

  final picked = await pickWritableSafFolder();
  if (picked == null) return null;

  final dirUri = picked.tree;
  if (accept != null && !await accept(dirUri)) return dirUri;

  backupDirectory.set(dirUri);

  if (migrateLegacyBackups) {
    final migrated = await backupService.migrateOldBackups(dirUri);
    if (migrated > 0) {
      container.invalidate(backupListProvider);
    }
  }

  return dirUri;
}
