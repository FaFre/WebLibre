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
import 'package:weblibre/core/startup/maintenance_scanner.dart';
import 'package:weblibre/core/startup/models/maintenance_journal.dart';
import 'package:weblibre/core/startup/startup_paths.dart';
import 'package:weblibre/utils/filesystem.dart' as fs;

/// Reading a [MaintenanceScan] the way the maintenance screen has to.
///
/// Separate from the screen because it is not a presentation question: what
/// counts as evidence decides whether the browser may open, and getting it
/// wrong offers the user actions that cannot work.
extension MaintenanceEvidence on MaintenanceScan {
  /// Every task id named by durable evidence, from all three sources.
  ///
  /// [MaintenanceScan.hasDurableEvidence] is the definition the reservation
  /// actually uses, so anything that keeps the process in maintenance has to
  /// keep its task out of the user's reach here too. Tracking only the
  /// *readable* journals offered to cancel operations whose record this screen
  /// could not read — an unreadable journal is evidence precisely because it
  /// cannot be parsed, and a half-cleared restore workspace is evidence with no
  /// journal at all.
  ///
  /// A journal file is `<taskId>.json`, which is what makes the id recoverable
  /// even when the contents are not.
  Set<String> get evidenceTaskIds => {
    for (final journal in incompleteJournals) journal.taskId,
    for (final entry in unreadableJournals)
      p.basenameWithoutExtension(entry.path),
    for (final artifact in artifacts)
      if (!artifact.isEmpty) artifact.taskId,
  };

  /// Evidence that survives recovery and that nothing automatic can resolve.
  ///
  /// Deliberately not "everything left over": an incomplete journal is handled
  /// by recovery, and a staging-only workspace is swept by
  /// [sweepHarmlessArtifacts]. What is left needs a person — a record we refuse
  /// to parse away, or a restore that moved the user's data aside and left no
  /// readable account of it.
  ///
  /// This is the difference between "nothing left to do" and "nothing *I* can
  /// do". Conflating them left the finish button releasing the lease only for
  /// native to hand it straight back, rendering the same screen forever.
  List<String> get unresolvedEvidence => [
    for (final entry in unreadableJournals)
      'Unreadable record: ${p.basename(entry.path)} (${entry.reason})',
    for (final artifact in artifacts)
      if (artifact.hasOld)
        'Interrupted replace: ${artifact.taskId} left a copy of the previous profile data aside',
  ];

  /// Task ids with a journal of some kind, readable or not.
  Set<String> get _journalledTaskIds => {
    for (final journal in journals) journal.taskId,
    for (final entry in unreadableJournals)
      p.basenameWithoutExtension(entry.path),
  };
}

/// Removes restore workspaces that provably touched nothing.
///
/// `old` is created at `RestorePhase.oldMoved`; before that the target profile
/// has not been touched at all, so a workspace with staging and no `old` is an
/// unpacked archive and nothing more. `RestoreOperation.run` already drops a
/// leftover staging tree before unpacking over it — this only brings that
/// forward to the one place that can otherwise leave a browser refusing to open
/// over a directory nobody needs.
///
/// The whole workspace goes, not just `staging`. An interrupted unpack leaves
/// its scratch beside the staging tree rather than in it — the startup screen's
/// unpacker copies the archive to `incoming.weblibre` there before opening it —
/// and that copy is the size of the backup. Nothing else reclaims it:
/// `RestoreOperation` clears only `staging` and `old`, and a workspace holding
/// nothing else does not count as evidence, so this used to skip past it.
///
/// Skipped when any journal names the task, readable or not: a journal means the
/// record of what happened still exists, and it owns the outcome.
Future<int> sweepHarmlessArtifacts(
  StartupPaths paths,
  MaintenanceScan scan,
) async {
  final journalled = scan._journalledTaskIds;
  var swept = 0;

  for (final artifact in scan.artifacts) {
    // `isEmpty` is deliberately not a reason to skip: it means no `staging` and
    // no `old`, not an empty directory. A workspace with neither and no journal
    // has nothing anyone can still act on, whatever else is lying in it.
    if (artifact.hasOld) continue;
    if (journalled.contains(artifact.taskId)) continue;

    final workspace = paths.restoreWorkspaceDir(artifact.taskId);
    try {
      if (workspace.existsSync()) {
        await workspace.delete(recursive: true);
        swept++;
        logger.i('Cleared an abandoned restore workspace ${artifact.taskId}');
      }
    } catch (error, stackTrace) {
      // One workspace that will not clear is not a reason to stop: it is no
      // worse off than before, and the others still go.
      logger.w(
        'Could not clear the restore workspace ${artifact.taskId}',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  return swept;
}

/// Removes evidence the user explicitly chose to discard.
///
/// Never called except from that choice. The record exists precisely because
/// losing it is how an optimistic boot destroys data, so it is never discarded
/// on a timer, at startup, or as a side effect of anything else — but a browser
/// that can never be opened again is not an acceptable resting state either, and
/// only the user can weigh those against each other.
///
/// The workspace goes with it, because keeping it would leave the reservation in
/// place and that is the one outcome this choice exists to end. But the `old`
/// tree inside it is *the user's profile*, moved aside by an interrupted
/// replace, and it never goes with the workspace: it is put back if its profile
/// directory is missing and parked if nothing can say which profile it is — see
/// [_reclaimAsideProfile]. Deleting it unconditionally meant that discarding a
/// record the app merely could not *parse* silently took a whole profile with
/// it, against a dialog that promises the opposite.
///
/// Returns how many trees had to be parked, so the screen can say that data is
/// still on the device rather than leaving it to a log line the user cannot
/// read.
Future<int> discardUnresolvedEvidence(StartupPaths paths) async {
  final scan = await MaintenanceScanner(paths).scan();
  var parked = 0;

  for (final entry in scan.unreadableJournals) {
    final file = File(entry.path);
    if (file.existsSync()) {
      await file.delete();
    }
    logger.w('Discarded unreadable maintenance journal ${entry.path}');
  }

  for (final artifact in scan.artifacts) {
    if (artifact.isEmpty) continue;

    if (artifact.hasOld) {
      // The delete below is recursive and `old` is the user's only copy of that
      // profile, so it runs only once the tree has been dealt with — put back,
      // parked, or deliberately given up on because the profile is already in
      // place. Anything else fails the discard: that leaves the reservation
      // standing, which is the outcome this choice exists to end, but the user
      // keeps their profile and gets told, and that beats a button that quietly
      // eats one because a rename failed.
      final outcome = await _reclaimAsideProfile(paths, artifact.taskId, scan);
      if (outcome == _AsideOutcome.parked) parked++;

      if (outcome == _AsideOutcome.stuck) {
        // Plain text, because `classifyMaintenanceFailure` shows it to the user
        // as written and this screen has no logs behind it.
        throw Exception(
          'The saved copy of the previous profile could not be moved, so it '
          'was kept rather than deleted.',
        );
      }
    }

    final workspace = paths.restoreWorkspaceDir(artifact.taskId);
    if (workspace.existsSync()) {
      await workspace.delete(recursive: true);
    }
    logger.w('Discarded restore workspace ${artifact.taskId}');
  }

  return parked;
}

/// What became of an interrupted replace's `old` tree.
enum _AsideOutcome {
  /// Dealt with: put back under its profile, or deliberately given up on
  /// because that profile is already in place. The workspace may go.
  resolved,

  /// Still on the device, outside the maintenance workspace. The workspace may
  /// go, and the user is told the data was kept.
  parked,

  /// Still sitting in `old` with nowhere to go. Nothing may be deleted around
  /// it.
  stuck,
}

/// Puts an interrupted replace's `old` tree back, if its profile is gone.
///
/// The tree names itself: `old` is the target profile directory as it was, so
/// its own `metadata.json` carries the uuid it has to go back under. That is the
/// first thing tried and the only one that needs nothing else to be readable.
///
/// When it cannot be read — the metadata was already damaged when the replace
/// moved the directory aside, which is one of the ways a profile ends up being
/// restored over in the first place — the journal for the same task names the
/// profile independently, and it is asked next.
///
/// If neither can say which profile this is, the tree is parked rather than
/// dropped: it is still a whole profile, and the discard dialog promises the
/// user it goes back. See [_parkAsideProfile].
///
/// Nothing is overwritten. A target that already exists is whatever the restore
/// left there, and the user was told to check it; replacing it here would make
/// this an undo rather than the last resort it is described as.
///
/// Reports what became of the tree; only [_AsideOutcome.stuck] forbids deleting
/// the workspace around it.
Future<_AsideOutcome> _reclaimAsideProfile(
  StartupPaths paths,
  String taskId,
  MaintenanceScan scan,
) async {
  final old = paths.restoreOldDir(taskId);
  if (!old.existsSync()) return _AsideOutcome.resolved;

  try {
    final id = await _asideProfileId(old, taskId, scan);

    if (id != null) {
      final target = paths.profileDir(id);
      // The one case where the tree really does go with the workspace, and the
      // dialog says so: the profile is already there, and putting this back over
      // it would make the last resort an undo.
      if (target.existsSync()) {
        logger.w(
          'Profile $id is already in place, so the aside copy from $taskId '
          'is being discarded with the workspace',
        );
        return _AsideOutcome.resolved;
      }

      await target.parent.create(recursive: true);
      await old.rename(target.path);
      logger.w('Put the aside copy of profile $id back (task $taskId)');
      return _AsideOutcome.resolved;
    }

    await _parkAsideProfile(paths, taskId, old);
    return _AsideOutcome.parked;
  } catch (error, stackTrace) {
    // Whatever went wrong, `old` is untouched and the caller stops rather than
    // deleting around it. The discard fails; the profile survives.
    logger.e(
      'Could not put the aside copy for $taskId back',
      error: error,
      stackTrace: stackTrace,
    );
    return _AsideOutcome.stuck;
  }
}

/// Which profile the aside tree is, from whichever record can still say.
///
/// The journal is a genuinely independent answer rather than a second guess at
/// the same file: `targetProfileId` is written by the restore that moved the
/// directory aside, and [MaintenanceJournal.tryFromJson] refuses a journal
/// without one, so a readable journal always carries it.
Future<String?> _asideProfileId(
  Directory old,
  String taskId,
  MaintenanceScan scan,
) async {
  try {
    final id = (await fs.readProfileMetadata(old))?.id;
    if (id != null) return id;
  } catch (error) {
    // Damaged metadata is the case this fallback exists for, so it is not worth
    // a stack trace — the journal is asked next either way.
    logger.w('The aside copy for $taskId has unreadable metadata: $error');
  }

  for (final journal in scan.journals) {
    if (journal.taskId == taskId) {
      logger.w(
        'The aside copy for $taskId does not say which profile it is; '
        'its journal names ${journal.targetProfileId}',
      );
      return journal.targetProfileId;
    }
  }

  return null;
}

/// Moves an unidentifiable `old` tree out of the maintenance workspace.
///
/// Deleting it was the older behaviour and it was wrong in a way the user could
/// not see coming: the discard dialog says the saved data goes back if the
/// profile is missing, and a tree nothing can name is precisely a tree we cannot
/// prove the profile *isn't* missing for. Parking it costs a profile's worth of
/// storage; deleting it cost the profile.
///
/// [StartupPaths.maintenanceOrphanedDir] is outside everything either scanner
/// walks, so this ends the reservation just as deleting it would.
Future<void> _parkAsideProfile(
  StartupPaths paths,
  String taskId,
  Directory old,
) async {
  final parked = paths.orphanedProfileDir(taskId);

  // Same task, parked twice: the first attempt to discard got this far and then
  // failed, and that copy is no less the user's data than this one.
  var destination = parked;
  var attempt = 1;
  while (destination.existsSync()) {
    destination = Directory('${parked.path}-$attempt');
    attempt++;
  }

  await destination.parent.create(recursive: true);
  await old.rename(destination.path);
  logger.w(
    'The aside copy for $taskId does not say which profile it is and no '
    'journal names it; kept at ${destination.path} rather than deleted',
  );
}
