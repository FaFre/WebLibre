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
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:weblibre/core/logger.dart';

/// Suffix a backup wears while it is still being written.
///
/// A `.weblibre` file in the backup folder is a promise that it can be restored.
/// A publication that is interrupted — the process dies, the volume fills, the
/// grant is pulled mid-write — must not be able to make that promise, so the
/// name is only claimed once the bytes are all there.
const partialArchiveSuffix = '.partial';

/// The destination folder no longer accepts writes: no grant, gone, or access
/// refused.
class BackupTargetUnavailable implements Exception {
  const BackupTargetUnavailable(this.outcome, [this.detail]);

  /// [BackupTreeProbeOutcome.noGrant], [BackupTreeProbeOutcome.missing] or
  /// [BackupTreeProbeOutcome.refused]: a folder that is gone asks for a
  /// different sentence than one that refuses files.
  final BackupTreeProbeOutcome outcome;

  /// The provider's own message, for logs and bug reports.
  final String? detail;

  @override
  String toString() =>
      'BackupTargetUnavailable(${outcome.name}${detail == null ? '' : ': $detail'})';
}

/// The storage holding the destination folder is full, or visibly too small
/// for the file.
///
/// Kept apart from [BackupTargetUnavailable] because it asks for the opposite
/// remedy: the folder is fine and must be kept, and it is space that has to be
/// freed.
class BackupTargetFull implements Exception {
  const BackupTargetFull({
    this.requiredBytes,
    this.availableBytes,
    this.detail,
  });

  /// What the file needs and what is free, when the volume showed before the
  /// copy that it lacks the room. Null when it filled up during the copy.
  final int? requiredBytes;
  final int? availableBytes;

  /// The provider's own message, for logs and bug reports.
  final String? detail;

  @override
  String toString() =>
      'BackupTargetFull(${requiredBytes ?? '?'} needed, '
      '${availableBytes ?? '?'} free${detail == null ? '' : ': $detail'})';
}

/// Writing into the destination failed for a reason that says nothing against
/// the folder or its space: the bytes that arrived are not the bytes that were
/// sent, a provider died, an error nobody recognised, or the local file that
/// was to be copied could not be read.
///
/// Never answered with "choose the folder again".
class BackupWriteFailed implements Exception {
  const BackupWriteFailed({this.fault, this.detail});

  /// Which way it failed, when native could tell; null for a provider that
  /// failed for a reason of its own.
  final TreePublicationFault? fault;

  /// The provider's own message, without the classification or exception
  /// class around it: it is the part a person can read out to a bug report.
  final String? detail;

  @override
  String toString() =>
      'BackupWriteFailed(${fault == null ? '' : '${fault!.name}: '}'
      '${detail ?? ''})';
}

/// Asks native whether a persisted read/write grant covers a SAF tree.
typedef TreeGrantCheck = Future<bool> Function(Uri targetTree);

/// Whether [targetTree] still holds a persisted read/write grant.
///
/// A grant survives reboots but not the user revoking it, the volume being
/// unmounted, or the folder being deleted.
///
/// Only the grant list is read, so this costs nothing but says less than
/// [probeBackupTarget]: a grant can stay on record for a folder the provider no
/// longer writes to (#698).
///
/// Asked natively, the same way the write itself asks before it starts, so the
/// two cannot disagree. `saf_util`'s check threw on the first persisted grant
/// that is not on a tree — which a shared file leaves behind — and made every
/// folder look ungranted.
Future<bool> safTreeHasGrant(Uri targetTree, {TreeGrantCheck? check}) async {
  try {
    return await (check ?? GeckoProfileService().hasPersistedTreeGrant)(
      targetTree,
    );
  } catch (error, stackTrace) {
    logger.w(
      'Could not check the folder grant',
      error: error,
      stackTrace: stackTrace,
    );
    return false;
  }
}

/// What a write check, or a write, says about a SAF folder.
///
/// The one place a [BackupTreeProbeOutcome] is turned into something to act on.
/// Every caller — the queued backup, its publication, the backup screen and
/// settings export — switches over this, so they cannot drift into treating
/// the same answer differently.
enum SafFolderVerdict {
  /// Files can be created in it.
  writable,

  /// The folder itself is to blame: no grant, gone, or access refused. The
  /// only verdict that justifies asking for the folder again or forgetting it.
  lost,

  /// The storage holding it is full. The folder is fine and is kept; it is
  /// space that has to be freed.
  full,

  /// The write check got no answer within its time. Only a check comes back
  /// with this, never an outcome: the provider is hanging — a cloud drive
  /// offline, a USB stick that stopped answering — and the write that would
  /// follow would hang on it the same way, with nothing able to cancel it.
  /// The folder is kept; it is its storage that has to come back.
  unresponsive,

  /// No verdict: the check could not run, or failed for a reason it could not
  /// place. Not evidence against the folder, so whatever was about to happen
  /// goes ahead and reports its own error if it fails.
  unknown;

  /// The verdict on [outcome].
  static SafFolderVerdict of(BackupTreeProbeOutcome outcome) =>
      switch (outcome) {
        BackupTreeProbeOutcome.writable => writable,
        BackupTreeProbeOutcome.noGrant ||
        BackupTreeProbeOutcome.missing ||
        BackupTreeProbeOutcome.refused => lost,
        BackupTreeProbeOutcome.noSpace => full,
        BackupTreeProbeOutcome.inconclusive => unknown,
      };
}

/// What a write check found: the verdict, and the folder's name when the
/// provider gave one.
final class BackupFolderCheck {
  const BackupFolderCheck(this.verdict, {this.folderName});

  final SafFolderVerdict verdict;

  /// Null when the check could not run, got no answer in time, or the provider
  /// did not name the folder.
  final String? folderName;
}

/// Asks native to create, write and delete a hidden file in a SAF tree.
typedef BackupTreeProber = Future<BackupTreeProbe> Function(Uri targetTree);

/// How long [probeBackupTarget] waits for the provider.
///
/// The probe is four calls into whatever provider holds the folder, and a
/// network one (a cloud drive offline, a USB stick that hangs) can block on
/// each of them indefinitely. Long enough for a slow network provider to start
/// up and answer a 4 KiB write. Waiting longer costs a few seconds on a hung
/// provider, while stopping too early can cost a queued backup that has
/// already restarted the app.
const backupProbeTimeout = Duration(seconds: 30);

/// Whether a file can really be created in [targetTree] right now.
///
/// Stronger than [safTreeHasGrant]. Issue #698: the folder existed and its
/// grant was still on record, but the provider refused to create the backup
/// file, and only picking the folder again fixed it. Nothing short of creating
/// a file notices that.
///
/// A check that does not finish within [timeout] is
/// [SafFolderVerdict.unresponsive], and stops whatever it guards: the write
/// that would follow goes to the same provider and cannot be cancelled once it
/// blocks. A check that could not run at all is [SafFolderVerdict.unknown].
/// A timed-out check is not cancelled either, but it removes its own test file
/// whenever it does finish.
Future<BackupFolderCheck> probeBackupTarget(
  Uri targetTree, {
  BackupTreeProber? prober,
  Duration timeout = backupProbeTimeout,
}) async {
  try {
    final probe = await (prober ?? GeckoProfileService().probeBackupTree)(
      targetTree,
    ).timeout(timeout);
    if (probe.outcome != BackupTreeProbeOutcome.writable) {
      logger.w(
        'Backup folder failed its write check: ${probe.outcome.name} '
        '${probe.errorClass ?? ''} ${probe.errorMessage ?? ''}',
      );
    }
    return BackupFolderCheck(
      SafFolderVerdict.of(probe.outcome),
      folderName: probe.folderName,
    );
  } on TimeoutException {
    logger.w(
      'The backup folder write check got no answer within '
      '${timeout.inSeconds} s',
    );
    return const BackupFolderCheck(SafFolderVerdict.unresponsive);
  } catch (error, stackTrace) {
    logger.w(
      'Could not run the backup folder write check',
      error: error,
      stackTrace: stackTrace,
    );
    return const BackupFolderCheck(SafFolderVerdict.unknown);
  }
}

/// Hands a write into a SAF tree to native: the file goes in as [stagingName]
/// and is renamed to [fileName] once it is complete.
typedef SafTreeWrite =
    Future<TreePublication> Function(
      Uri targetTree,
      String fileName,
      String stagingName,
    );

/// Publishes [archive] into [targetTree] as [fileName].
///
/// Writes `<fileName>.partial`, checks the destination holds every byte, and
/// only then renames. The rename is the commit: until it happens nothing in
/// the folder claims to be a restorable backup. Native removes the `.partial`
/// again whenever the publication fails, so a write that died half way does
/// not keep the space it took on the storage that ran out.
///
/// The write goes through the app's own native method rather than
/// `saf_stream`, which reported every refused create as the same bare
/// `PluginError` because AndroidX swallows the provider's exception (#698).
Future<Uri> publishArchiveToSaf({
  required File archive,
  required Uri targetTree,
  required String fileName,
  SafTreeWrite? write,
}) async {
  final publication =
      await (write ??
          (tree, name, staging) => GeckoProfileService().publishFileToTree(
            sourcePath: archive.path,
            treeUri: tree,
            fileName: name,
            stagingName: staging,
            mimeType: 'application/octet-stream',
          ))(targetTree, fileName, '$fileName$partialArchiveSuffix');

  return Uri.parse(_checkPublication(publication).uri!);
}

/// Publishes [bytes] into [targetTree] as [fileName], the way
/// [publishArchiveToSaf] publishes a file, and returns the name the file ended
/// up with.
Future<String> publishBytesToSaf({
  required Uint8List bytes,
  required Uri targetTree,
  required String fileName,
  required String mimeType,
  SafTreeWrite? write,
}) async {
  final publication =
      await (write ??
          (tree, name, staging) => GeckoProfileService().publishBytesToTree(
            bytes: bytes,
            treeUri: tree,
            fileName: name,
            stagingName: staging,
            mimeType: mimeType,
          ))(targetTree, fileName, '$fileName$partialArchiveSuffix');

  return _checkPublication(publication).name ?? fileName;
}

/// [publication] when it succeeded; otherwise the failure it stands for,
/// thrown.
///
/// [BackupTargetUnavailable] only when the folder is to blame,
/// [BackupTargetFull] when its storage is, and otherwise [BackupWriteFailed].
///
/// The whole native answer — outcome, exception class, message — is logged
/// here. What the exceptions carry on is the provider's message alone: callers
/// show it, and an enum name or a Java class name means nothing to the person
/// reading it.
TreePublication _checkPublication(TreePublication publication) {
  final verdict = SafFolderVerdict.of(publication.outcome);
  if (verdict != SafFolderVerdict.writable) {
    logger.w(
      'Writing into the folder failed: ${publication.outcome.name} '
      '${publication.fault?.name ?? ''} ${publication.errorClass ?? ''} '
      '${publication.errorMessage ?? ''}',
    );
  }

  final detail = publication.errorMessage;
  switch (verdict) {
    case SafFolderVerdict.writable:
      if (publication.uri == null) {
        logger.w('The provider reported success without a document');
        throw const BackupWriteFailed();
      }
      return publication;
    case SafFolderVerdict.lost:
      throw BackupTargetUnavailable(publication.outcome, detail);
    case SafFolderVerdict.full:
      throw BackupTargetFull(
        requiredBytes: publication.requiredBytes,
        availableBytes: publication.availableBytes,
        detail: detail,
      );
    // Unresponsive never comes from an outcome; listed for the switch.
    case SafFolderVerdict.unknown || SafFolderVerdict.unresponsive:
      throw BackupWriteFailed(fault: publication.fault, detail: detail);
  }
}

/// Fetches the archive at [sourceUri] to [local], hands it to [use], and removes
/// the copy afterwards.
///
/// The inbound counterpart to [publishArchiveToSaf]. A SAF document cannot be
/// read as a file, so every restore has to land the bytes locally first — and
/// then has to be sure it deletes them again, because what it just wrote is a
/// decryptable copy of somebody's whole profile. Cleanup failures are logged
/// rather than thrown: by then [use] has already produced the answer that
/// matters.
///
/// The copy goes through the app's own native method rather than `saf_stream`,
/// whose `copyToLocalFile` reported every failure as a bare `PluginError` and
/// left restores failing with no reason anyone could act on.
Future<T> withArchiveFromSaf<T>({
  required Uri sourceUri,
  required File local,
  required Future<T> Function(File archive) use,
}) async {
  try {
    // Inside the bracket, not before it. A copy that throws part-way — a full
    // volume, a revoked grant — still leaves bytes behind, and those bytes are a
    // copy of somebody's whole profile that nothing else on this path is
    // guaranteed to reach.
    await GeckoProfileService().copyDocumentToFile(sourceUri, local.path);

    return await use(local);
  } finally {
    try {
      if (await local.exists()) {
        await local.delete();
      }
    } catch (e, s) {
      logger.w(
        'Failed to clean up the fetched archive ${local.path}',
        error: e,
        stackTrace: s,
      );
    }
  }
}
