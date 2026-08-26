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

import 'package:weblibre/core/logger.dart';

/// Removes [directory], and if it cannot, empties what is inside it.
///
/// For the workspaces that hold a participant payload — the secure-storage
/// snapshot is the account refresh token, the end-to-end sync key and the proxy
/// credentials as plain JSON, unencrypted because the archive around it was the
/// thing providing the encryption.
///
/// Every one of these call sites is *past* the point of no return: the restore
/// has installed, or the clone has been abandoned. Throwing would turn a
/// finished operation into a permanent maintenance reservation, so they all
/// logged the failure and moved on — which meant one failed `delete` left a
/// readable credential inside the live profile directory forever, and put it in
/// every later backup of that profile.
///
/// So failure stops being all-or-nothing. If the tree cannot go, its *contents*
/// can: truncating each file removes the readable copy, which is what actually
/// matters here. It is not forensic erasure — the underlying blocks are the
/// filesystem's business, and on Android this storage is encrypted at rest
/// anyway — it is making sure that what survives a cleanup failure is not a
/// working credential.
Future<void> shredDirectory(Directory directory, String what) async {
  if (!directory.existsSync()) return;

  try {
    await directory.delete(recursive: true);
    return;
  } catch (error, stackTrace) {
    logger.w(
      'Could not remove $what ${directory.path}; emptying it instead',
      error: error,
      stackTrace: stackTrace,
    );
  }

  var emptied = 0;
  var failed = 0;
  try {
    for (final entity in directory.listSync(recursive: true)) {
      if (entity is! File) continue;
      try {
        await entity.writeAsBytes(const [], flush: true);
        emptied++;
      } catch (_) {
        failed++;
      }
    }
  } catch (error, stackTrace) {
    logger.e(
      'Could not even enumerate $what ${directory.path}; a plaintext copy of '
      'the participant payload may survive there',
      error: error,
      stackTrace: stackTrace,
    );
    return;
  }

  // Emptying may be exactly what unblocked the delete — a file held open, a
  // partial write — so it is worth one more attempt now that nothing in the
  // tree carries content.
  try {
    await directory.delete(recursive: true);
    return;
  } catch (_) {
    // Expected when the original failure was the directory itself. The point
    // was the contents, and those are gone.
  }

  if (failed > 0) {
    logger.e(
      'Emptied $emptied file(s) of $what ${directory.path} but $failed would '
      'not be written; a plaintext copy may survive there',
    );
  } else {
    logger.w('Emptied $emptied file(s) of $what ${directory.path}');
  }
}
