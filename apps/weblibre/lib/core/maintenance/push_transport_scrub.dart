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

/// Where a profile tree keeps its UnifiedPush transport, profile-relative and
/// POSIX-style.
///
/// The transport is the connector's database (tokens, the distributor and the
/// Keystore-wrapped Web Push keys) and the queue of decrypted payloads Gecko
/// has not received yet. Both identify the profile they were made for: a tree
/// that kept them in another profile could decrypt and deliver the source's
/// messages. Archives leave them out, and every restore and clone strips them.
///
/// Every name here is duplicated in Kotlin's `PushTransportFiles`, which reads
/// the markers and runs the one-time migration over the same files.
abstract final class PushTransportPaths {
  static const connectorDatabase = 'databases/unifiedpush-connector';

  /// The database and the SQLite side files that hold part of it.
  static const connectorFiles = [
    connectorDatabase,
    '$connectorDatabase-journal',
    '$connectorDatabase-wal',
    '$connectorDatabase-shm',
  ];

  static const queuedMessages = 'no_backup/queued_push_messages';

  /// The subscription rows still carry the endpoints and keys of a transport
  /// the tree no longer has; push's startup clears them before anything reads
  /// them, and keeps the scopes so each registers again.
  static const endpointResetMarker = 'no_backup/push_endpoint_reset';

  /// Recovery could not tell whether the tree is the original or an
  /// unscrubbed replacement; the migration treats its transport as shared.
  static const transportUnknownMarker = 'no_backup/push_transport_unknown';
}

/// Strips [tree]'s push transport before it becomes, or stays, a profile.
///
/// For a clone and for a replacement alike, even when the target had a
/// subscription for the same scope: a backup can hold a different site
/// account's state, so the replaced transport is never reused. The marker is
/// written first, so an interruption leaves a tree that is stripped again
/// rather than one whose rows still name a dead transport. Idempotent; throws
/// when anything could not be removed, because a profile with the archive's
/// keys must not come into being.
Future<void> scrubPushTransport(Directory tree) async {
  await _writeMarker(tree, PushTransportPaths.endpointResetMarker);
  for (final relative in PushTransportPaths.connectorFiles) {
    final file = File(_resolve(tree, relative));
    if (file.existsSync()) await file.delete();
  }
  await _deleteQueue(tree);
}

/// Marks [tree]'s transport as one that may be another profile's.
///
/// For a restore an older build left in a state recovery cannot read: the tree
/// may be the original or an unscrubbed replacement. Its queued payloads go at
/// once, since either could be a message the archive's source received. The
/// connector database stays for the one-time migration, which resets it
/// together with every transport it may share credentials with.
///
/// Once recovery deletes the journal, the marker is the only evidence left, so
/// its directory entry is synced first through [syncDirectory]. That is best
/// effort, as for the journal itself: a sync that cannot be taken narrows no
/// window, and refusing to finish recovery over it would be worse.
Future<void> markPushTransportUnknown(
  Directory tree, {
  Future<bool> Function(String path)? syncDirectory,
}) async {
  await _deleteQueue(tree);
  final marker = _resolve(tree, PushTransportPaths.transportUnknownMarker);
  await _writeMarker(tree, PushTransportPaths.transportUnknownMarker);
  if (syncDirectory != null && !await syncDirectory(p.dirname(marker))) {
    logger.w('Could not sync the push transport marker in ${tree.path}');
  }
}

Future<void> _deleteQueue(Directory tree) async {
  final queue = Directory(_resolve(tree, PushTransportPaths.queuedMessages));
  if (queue.existsSync()) await queue.delete(recursive: true);
}

Future<void> _writeMarker(Directory tree, String relative) =>
    AtomicJsonFile(File(_resolve(tree, relative))).write({'version': 1});

String _resolve(Directory tree, String relative) =>
    p.joinAll([tree.path, ...p.posix.split(relative)]);
