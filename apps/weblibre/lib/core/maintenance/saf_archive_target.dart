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

import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';
import 'package:weblibre/core/logger.dart';

/// Suffix a backup wears while it is still being written.
///
/// A `.weblibre` file in the backup folder is a promise that it can be restored.
/// A publication that is interrupted — the process dies, the volume fills, the
/// grant is pulled mid-write — must not be able to make that promise, so the
/// name is only claimed once the bytes are all there.
const partialArchiveSuffix = '.partial';

/// The destination folder no longer accepts writes.
class BackupTargetUnavailable implements Exception {
  const BackupTargetUnavailable(this.reason);

  final String reason;

  @override
  String toString() => 'BackupTargetUnavailable($reason)';
}

/// The bytes that arrived are not the bytes that were sent.
class BackupPublicationFailure implements Exception {
  const BackupPublicationFailure(this.reason);

  final String reason;

  @override
  String toString() => 'BackupPublicationFailure($reason)';
}

/// Whether [targetTree] still holds a persisted read/write grant.
///
/// A grant survives reboots but not the user revoking it, the volume being
/// unmounted, or the folder being deleted — and a backup is queued in one process
/// and taken in the next, so there is always a window for that to happen.
Future<bool> safTargetIsWritable(Uri targetTree, {SafUtil? safUtil}) async {
  final util = safUtil ?? SafUtil();

  try {
    return await util.hasPersistedPermission(
      targetTree.toString(),
      checkRead: true,
      checkWrite: true,
    );
  } catch (error, stackTrace) {
    logger.w(
      'Could not check the backup folder grant',
      error: error,
      stackTrace: stackTrace,
    );
    return false;
  }
}

/// Publishes [archive] into [targetTree] as [fileName].
///
/// Writes `<fileName>.partial`, checks the destination is the size it should be,
/// and only then renames. The rename is the commit: until it happens nothing in
/// the folder claims to be a restorable backup, and a leftover `.partial` is
/// self-describing rather than a truncated archive with a trustworthy name.
Future<Uri> publishArchiveToSaf({
  required File archive,
  required Uri targetTree,
  required String fileName,
  SafStream? safStream,
  SafUtil? safUtil,
}) async {
  final stream = safStream ?? SafStream();
  final util = safUtil ?? SafUtil();

  if (!await safTargetIsWritable(targetTree, safUtil: util)) {
    throw const BackupTargetUnavailable(
      'The backup folder is no longer accessible',
    );
  }

  final expectedBytes = await archive.length();
  final partialName = '$fileName$partialArchiveSuffix';

  final written = await stream.pasteLocalFile(
    archive.path,
    targetTree.toString(),
    partialName,
    'application/octet-stream',
    overwrite: true,
  );

  // SAF may hand back a different name than the one asked for, so the returned
  // uri is the only reliable handle on what was actually created.
  final partialUri = written.uri.toString();

  try {
    final stat = await util.stat(partialUri, false);
    if (stat == null) {
      throw const BackupPublicationFailure(
        'The written backup could not be found afterwards',
      );
    }

    if (stat.length != expectedBytes) {
      // The realistic failure: the volume filled, or the write was cut short.
      // Caught here the folder is left with a `.partial` nobody will mistake for
      // a backup, instead of a short archive that looks complete.
      throw BackupPublicationFailure(
        'Wrote $expectedBytes bytes but the destination holds ${stat.length}',
      );
    }

    final finished = await util.rename(partialUri, false, fileName);
    return Uri.parse(finished.uri);
  } catch (_) {
    await _discardPartial(util, partialUri);
    rethrow;
  }
}

Future<void> _discardPartial(SafUtil util, String uri) async {
  try {
    await util.delete(uri, false);
  } catch (error, stackTrace) {
    // Not fatal, and not silent: a stray `.partial` is harmless but should be
    // explainable if the user sees one.
    logger.w(
      'Could not remove the incomplete backup $uri',
      error: error,
      stackTrace: stackTrace,
    );
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
Future<T> withArchiveFromSaf<T>({
  required Uri sourceUri,
  required File local,
  required Future<T> Function(File archive) use,
  SafStream? safStream,
}) async {
  try {
    // Inside the bracket, not before it. A copy that throws part-way — a full
    // volume, a revoked grant — still leaves bytes behind, and those bytes are a
    // copy of somebody's whole profile that nothing else on this path is
    // guaranteed to reach.
    await (safStream ?? SafStream()).copyToLocalFile(
      sourceUri.toString(),
      local.path,
    );

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
