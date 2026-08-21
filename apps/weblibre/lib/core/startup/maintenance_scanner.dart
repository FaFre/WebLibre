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
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/startup/atomic_json_file.dart';
import 'package:weblibre/core/startup/models/maintenance_journal.dart';
import 'package:weblibre/core/startup/models/startup_config.dart';
import 'package:weblibre/core/startup/startup_paths.dart';

/// A journal file that could not be understood. It reserves maintenance just
/// like a live journal would; the alternative is booting a profile that may be
/// half restored.
class UnreadableJournal {
  const UnreadableJournal(this.path, this.reason);

  final String path;
  final String reason;
}

/// A `restore/<taskId>/` workspace found on disk.
class RestoreArtifact {
  const RestoreArtifact({
    required this.taskId,
    required this.hasStaging,
    required this.hasOld,
  });

  final String taskId;
  final bool hasStaging;

  /// The target profile's previous content was moved aside and has not been
  /// cleaned up, so the profile directory on disk may be incomplete.
  final bool hasOld;

  bool get isEmpty => !hasStaging && !hasOld;
}

/// Everything the startup path needs in order to decide whether this process
/// must enter `MaintenanceReserved` before any profile consumer runs.
class MaintenanceScan {
  const MaintenanceScan({
    required this.journals,
    required this.unreadableJournals,
    required this.artifacts,
  });

  static const empty = MaintenanceScan(
    journals: [],
    unreadableJournals: [],
    artifacts: [],
  );

  final List<MaintenanceJournal> journals;
  final List<UnreadableJournal> unreadableJournals;
  final List<RestoreArtifact> artifacts;

  /// Journals whose operation never reached its completion phase.
  List<MaintenanceJournal> get incompleteJournals =>
      journals.where((journal) => journal.requiresRecovery).toList();

  /// True when the *filesystem alone* proves maintenance was in flight. This is
  /// deliberately independent of `startup_config.json`: a corrupt or deleted
  /// config must not be able to release the reservation.
  bool get hasDurableEvidence =>
      unreadableJournals.isNotEmpty ||
      incompleteJournals.isNotEmpty ||
      artifacts.any((artifact) => !artifact.isEmpty);

  /// Ids of profiles a journal says are mid-operation. Such a profile must not
  /// become the startup candidate.
  Set<String> get profilesUnderMaintenance => {
    for (final journal in journals)
      if (journal.requiresRecovery) journal.targetProfileId,
  };
}

/// Reads the durable maintenance evidence. Runs before candidate resolution and
/// touches nothing inside a profile directory.
class MaintenanceScanner {
  const MaintenanceScanner(this.paths);

  final StartupPaths paths;

  Future<MaintenanceScan> scan() async {
    final journals = <MaintenanceJournal>[];
    final unreadable = <UnreadableJournal>[];

    final journalsDir = paths.maintenanceJournalsDir;
    if (await journalsDir.exists()) {
      await for (final entity in journalsDir.list()) {
        if (entity is! File) continue;
        if (p.extension(entity.path) != '.json') continue;

        // Quarantining here would destroy the only evidence that a destructive
        // operation was in flight, so damaged journals are reported in place.
        final read = await AtomicJsonFile(
          entity,
        ).read(quarantineCorrupt: false);

        switch (read) {
          case AtomicJsonAbsent():
            continue;
          case AtomicJsonCorrupt(:final reason):
            unreadable.add(UnreadableJournal(entity.path, reason));
          case AtomicJsonPresent(:final json):
            // Belt and braces around a parser that is *meant* to be total:
            // every field reads tolerantly, so a wrong-typed value degrades to
            // a default rather than throwing. This scan runs before anything
            // else on the startup path, though, and a field added later without
            // a tolerant reader would otherwise turn one malformed journal into
            // an app that cannot start until the file is deleted by hand.
            MaintenanceJournal? journal;
            String? failure;
            try {
              journal = MaintenanceJournal.tryFromJson(json);
              if (journal == null) failure = 'missing taskId/targetProfileId';
            } catch (error, stackTrace) {
              logger.e(
                'Could not parse journal ${entity.path}',
                error: error,
                stackTrace: stackTrace,
              );
              failure = 'unparseable: $error';
            }

            if (journal != null) {
              journals.add(journal);
            } else {
              unreadable.add(UnreadableJournal(entity.path, failure!));
            }
        }
      }
    }

    final artifacts = <RestoreArtifact>[];
    final restoreDir = paths.maintenanceRestoreDir;
    if (await restoreDir.exists()) {
      await for (final entity in restoreDir.list()) {
        if (entity is! Directory) continue;
        final taskId = p.basename(entity.path);
        artifacts.add(
          RestoreArtifact(
            taskId: taskId,
            hasStaging: await _hasContent(paths.restoreStagingDir(taskId)),
            hasOld: await _hasContent(paths.restoreOldDir(taskId)),
          ),
        );
      }
    }

    final scan = MaintenanceScan(
      journals: List.unmodifiable(journals),
      unreadableJournals: List.unmodifiable(unreadable),
      artifacts: List.unmodifiable(artifacts),
    );

    if (scan.hasDurableEvidence) {
      logger.w(
        'Maintenance evidence found: ${journals.length} journal(s), '
        '${unreadable.length} unreadable, ${artifacts.length} artifact(s)',
      );
    }

    return scan;
  }

  static Future<bool> _hasContent(Directory dir) async {
    if (!await dir.exists()) return false;
    return !await dir.list().isEmpty;
  }
}

/// The startup-time verdict: does this process have to reserve maintenance, and
/// does it have to recover rather than merely execute queued work?
class MaintenanceReservation {
  const MaintenanceReservation({
    required this.required,
    required this.recoveryRequired,
    required this.taskId,
    required this.reason,
    required this.scan,
  });

  final bool required;
  final bool recoveryRequired;

  /// The task the next maintenance lease should start with, when one is known.
  final String? taskId;
  final String reason;
  final MaintenanceScan scan;

  static const none = MaintenanceReservation(
    required: false,
    recoveryRequired: false,
    taskId: null,
    reason: 'no maintenance evidence',
    scan: MaintenanceScan.empty,
  );

  /// Combines the queued task list with durable filesystem evidence.
  ///
  /// Either source alone is sufficient. In particular a config that lost its
  /// task list still yields a reservation when a journal or restore workspace
  /// says an operation was in flight.
  factory MaintenanceReservation.resolve(
    StartupConfig config,
    MaintenanceScan scan,
  ) {
    final durable = scan.hasDurableEvidence;
    final active = config.activeTasks;

    if (!durable && active.isEmpty) {
      return MaintenanceReservation(
        required: false,
        recoveryRequired: false,
        taskId: null,
        reason: 'no maintenance evidence',
        scan: scan,
      );
    }

    final recovery =
        durable &&
            (scan.unreadableJournals.isNotEmpty ||
                scan.incompleteJournals.isNotEmpty ||
                scan.artifacts.any((artifact) => artifact.hasOld)) ||
        config.requiresRecovery;

    // Prefer a task the filesystem says is mid-operation; those must be
    // reconciled before any queued work runs.
    final incompleteIds = {
      for (final journal in scan.incompleteJournals) journal.taskId,
      for (final artifact in scan.artifacts)
        if (!artifact.isEmpty) artifact.taskId,
    };

    final taskId =
        active
            .where((task) => incompleteIds.contains(task.id))
            .firstOrNull
            ?.id ??
        incompleteIds.firstOrNull ??
        active.firstOrNull?.id;

    return MaintenanceReservation(
      required: true,
      recoveryRequired: recovery,
      taskId: taskId,
      reason: durable
          ? 'durable maintenance evidence on disk'
          : 'queued maintenance task',
      scan: scan,
    );
  }
}
