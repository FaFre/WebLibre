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
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/maintenance/backup_manifest.dart';
import 'package:weblibre/core/maintenance/maintenance_lease.dart';
import 'package:weblibre/core/maintenance/maintenance_participant.dart';

/// Not enough room to stage the copy and the archive.
///
/// Raised *before* anything is written. A backup that runs out of space halfway
/// leaves a truncated archive that looks like a backup, which is worse than one
/// that never started.
class InsufficientStorage implements Exception {
  const InsufficientStorage({
    required this.requiredBytes,
    required this.availableBytes,
  });

  final int requiredBytes;
  final int availableBytes;

  @override
  String toString() =>
      'InsufficientStorage(required: $requiredBytes, available: $availableBytes)';
}

class BackupOptions {
  const BackupOptions({
    this.integrityCheck = true,
    this.storageHeadroomFactor = 2.2,
  });

  /// Verify the archive after packing.
  final bool integrityCheck;

  /// Multiple of the source size that must be free before starting.
  ///
  /// Above two because the staged copy and the archive coexist, plus slack for
  /// compression that does not compress and for the filesystem's own overhead.
  final double storageHeadroomFactor;
}

class BackupResult {
  const BackupResult({required this.manifest, required this.archive});

  final BackupManifest manifest;
  final File archive;
}

/// Packs [profileDir] into an encrypted archive, provider-free.
///
/// Everything environmental is a parameter: the lease, the directories, how the
/// archive is produced, and where it goes. That is what makes this callable from
/// the startup host — which has no `ProviderScope`, no profile database, and no
/// routes — as well as from the normal settings UI.
///
/// The order is deliberate. Preflight before any write, then the staged copy,
/// then the archive, then publication. The lease is re-asserted at each of those
/// boundaries rather than once at the top, because the failure worth catching is
/// a process that stalled mid-copy and lost the reservation while it slept.
Future<BackupResult> backupProfile({
  required MaintenanceLease lease,
  required Directory profileDir,
  required String profileId,
  required String profileName,
  String taskId = 'backup',
  required Directory workDir,
  required Future<void> Function(Directory source, File output) pack,
  required Future<void> Function(File archive) publish,
  BackupOptions options = const BackupOptions(),
  List<MaintenanceParticipant> participants = const [],
  Future<int?> Function()? availableBytes,
  DateTime? now,
}) async {
  await lease.assertHeld('backup.start');

  final staging = Directory(p.join(workDir.path, 'source'));
  final archive = File(p.join(workDir.path, 'archive.weblibre'));

  try {
    await _preflight(profileDir, options, availableBytes);

    await lease.assertHeld('backup.stage');
    final copied = await _stageSource(profileDir, staging);

    // Participants stage into the archive tree, so what they write here is what
    // a later restore of this archive reads back. State that lives outside the
    // profile directory — preferences, shortcuts, push records — reaches the
    // archive by no other route.
    final participantDir = Directory(
      p.join(staging.path, participantStagingDirName),
    );
    await participantDir.create(recursive: true);

    // A backup mutates nothing, so nothing here is ever read back. It exists so
    // participants have a well-formed context in every operation rather than a
    // nullable one they have to reason about.
    final participantScratch = Directory(p.join(workDir.path, 'participants'));
    await participantScratch.create(recursive: true);

    await ParticipantCoordinator(
      lease: lease,
      participants: participants,
    ).prepareAll(
      MaintenanceParticipantContext(
        taskId: taskId,
        profileId: profileId,
        kind: MaintenanceOperationKind.backup,
        stagedDir: participantDir,
        rollbackDir: participantScratch,
        // The staged copy, not the live tree: what a participant reads for
        // ownership evidence should be the same data the archive carries.
        profileDir: staging,
      ),
    );

    final manifest = BackupManifest(
      profileId: profileId,
      profileName: profileName,
      createdAt: (now ?? DateTime.now()).toUtc(),
      sourceBytes: copied.bytes,
      entryCount: copied.files,
    );

    // Inside the archive, so a restored profile can explain its own gaps without
    // the original device being around.
    await File(p.join(staging.path, backupManifestFileName)).writeAsString(
      const JsonEncoder.withIndent('  ').convert(manifest.toJson()),
      flush: true,
    );

    await lease.assertHeld('backup.pack');
    await pack(staging, archive);

    await lease.assertHeld('backup.publish');
    final digest = await _sha256OfFile(archive);
    await publish(archive);

    return BackupResult(
      manifest: manifest.withDigest(digest),
      archive: archive,
    );
  } finally {
    // The staged copy is a full second copy of the profile; leaving it behind on
    // a failure would be a silent, recurring disk leak.
    await _deleteQuietly(staging);
  }
}

/// Copies [source] into [target], applying the §11.4 exclusions.
///
/// Always a copy, never an in-place pack. The exclusions are unconditional, and
/// the manifest has to be written somewhere that is not the live profile.
Future<Directory> stageBackupSource(Directory source, Directory target) async {
  await _stageSource(source, target);
  return target;
}

/// Whether [relativePath] is left out of the staged copy.
///
/// The exclusion list is the backup contract. The participant directory is left
/// out for a second, unrelated reason: this operation *writes* it into the staging
/// tree a few steps later, so a copy of it inside the live profile can only be a
/// leftover from an earlier restore — and carrying that into a new archive would
/// re-publish a stale snapshot of the credentials the participants staged.
bool _isSkipped(String relativePath) {
  if (BackupExclusions.isExcluded(relativePath)) return true;

  final normalized = p.posix.normalize(relativePath.replaceAll(r'\', '/'));
  return normalized == participantStagingDirName ||
      p.posix.isWithin(participantStagingDirName, normalized);
}

Future<({int bytes, int files})> _measureIncludedBytes(Directory source) async {
  var bytes = 0;
  var files = 0;

  await for (final entity in source.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;

    final relative = p.relative(entity.path, from: source.path);
    if (_isSkipped(relative)) continue;

    bytes += await entity.length();
    files += 1;
  }

  return (bytes: bytes, files: files);
}

Future<void> _preflight(
  Directory source,
  BackupOptions options,
  Future<int?> Function()? availableBytes,
) async {
  if (availableBytes == null) return;

  final available = await availableBytes();
  // A device that will not say how much room it has is not a reason to refuse a
  // backup; it is a reason not to claim the check happened.
  if (available == null) return;

  // Measured only once there is a figure to compare it against: this is a full
  // recursive walk of the profile tree with a `stat` per file, and `_stageSource`
  // recomputes the counts that actually reach the manifest anyway.
  final sourceBytes = (await _measureIncludedBytes(source)).bytes;

  final required = (sourceBytes * options.storageHeadroomFactor).ceil();
  if (available < required) {
    throw InsufficientStorage(
      requiredBytes: required,
      availableBytes: available,
    );
  }
}

Future<({int bytes, int files})> _stageSource(
  Directory source,
  Directory target,
) async {
  await target.create(recursive: true);

  var bytes = 0;
  var files = 0;

  // A profile tree holds tens of thousands of files, nearly all of them in a
  // directory a previous entity already created. Remembering which saves one
  // `mkdir` syscall per file.
  final created = <String>{target.path};
  Future<void> ensureDir(String path) async {
    if (created.add(path)) await Directory(path).create(recursive: true);
  }

  await for (final entity in source.list(recursive: true, followLinks: false)) {
    final relative = p.relative(entity.path, from: source.path);
    if (_isSkipped(relative)) continue;

    final destination = p.join(target.path, relative);

    if (entity is Directory) {
      await ensureDir(destination);
    } else if (entity is File) {
      await ensureDir(p.dirname(destination));
      await entity.copy(destination);
      bytes += await entity.length();
      files += 1;
    } else if (entity is Link) {
      await ensureDir(p.dirname(destination));
      await Link(destination).create(await entity.target());
    }
  }

  return (bytes: bytes, files: files);
}

Future<String> _sha256OfFile(File file) async {
  final digest = await file.openRead().transform(sha256).first;
  return digest.toString();
}

Future<void> _deleteQuietly(Directory directory) async {
  try {
    if (directory.existsSync()) {
      await directory.delete(recursive: true);
    }
  } catch (_) {
    // Cleanup failure must not mask the operation's own outcome.
  }
}
