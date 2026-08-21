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
 */
import 'package:weblibre/core/startup/atomic_json_file.dart';
import 'package:weblibre/core/startup/models/maintenance_journal.dart';
import 'package:weblibre/core/startup/startup_paths.dart';

/// Durable write-ahead record of a destructive maintenance operation.
///
/// It lives outside the profile namespace on purpose: it has to survive the
/// profile directory being moved out from under it, which is the entire point of
/// the operations it describes.
///
/// A corrupt journal is never quarantined away like a config file. Losing the
/// record of a half-finished restore is exactly the case where booting
/// optimistically destroys data, so an unreadable journal keeps the process in
/// maintenance instead.
class MaintenanceJournalStore {
  const MaintenanceJournalStore(this.paths, {this.syncDirectory});

  final StartupPaths paths;

  /// Flushes a directory's own metadata, when the platform can.
  ///
  /// Injected rather than reached for directly so the journal stays testable
  /// without a running Android side, and so a build with no native half simply
  /// keeps the tolerated window rather than failing.
  final Future<bool> Function(String path)? syncDirectory;

  Future<MaintenanceJournal?> read(String taskId) async {
    final result = await AtomicJsonFile(
      paths.journalFile(taskId),
    ).read(quarantineCorrupt: false);

    return switch (result) {
      AtomicJsonPresent(:final json) => MaintenanceJournal.tryFromJson(json),
      _ => null,
    };
  }

  /// Writes [journal] durably, then returns it.
  ///
  /// The file contents are flushed by the atomic write, and the *directory*
  /// entry created by its rename is flushed by [syncDirectory] when one is
  /// available — a rename is recorded in the parent directory, not in either
  /// file, so flushing the file alone leaves the newest phase losable.
  ///
  /// Without that helper the window stays open, and that is survivable by
  /// design: recovery never trusts the phase alone, and re-derives the true
  /// state from the target, staging and old directories. Narrowing the window is
  /// an improvement, not the thing correctness rests on — which is why a failed
  /// sync is not allowed to fail the write.
  Future<MaintenanceJournal> write(MaintenanceJournal journal) async {
    await AtomicJsonFile(
      paths.journalFile(journal.taskId),
    ).write(journal.toJson());

    final sync = syncDirectory;
    if (sync != null) {
      await sync(paths.maintenanceJournalsDir.path);
    }

    return journal;
  }

  Future<void> delete(String taskId) async {
    final file = paths.journalFile(taskId);
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
