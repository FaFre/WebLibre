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
import 'package:weblibre/core/maintenance/backup_manifest.dart';
import 'package:weblibre/core/maintenance/participant_category.dart';

/// What a restore into a *new* profile does with the participant payload the
/// archive carries.
///
/// Restoring over an existing profile replays every participant, because the
/// archive and the target describe the same profile. A clone does not: the
/// archive's state belongs to the profile it was taken from, and the clone is a
/// different profile that happens to start with the same data.
///
/// Today the answer for every category is **discard**, and the discard is the
/// part that matters most: `SecureStorageParticipant` stages the account refresh
/// token, the end-to-end sync key and the proxy credentials as plain JSON inside
/// `weblibre_participants/`. That is safe inside a password-encrypted archive
/// and *not* safe unpacked into a profile directory, where it would sit
/// unencrypted for the life of the clone — and be picked up by a later backup of
/// the clone as a stale second copy.
///
/// This exists as its own step, rather than as a `delete` call inlined into the
/// restore, so that changing the answer per category later is a change here and
/// nowhere else. The plausible next step is [ClonePolicy.rekey] for proxy
/// credentials: the proxy-profile rows that use them travel inside the clone's
/// `user.db`, so ownership is a lookup rather than a guess — the same evidence
/// `migrateUnqualifiedSecureRecords` already relies on. The account session is
/// the category that should *stay* discarded: copying it would put one login on
/// two profiles, which is the isolation failure the whole profile boundary
/// exists to prevent.
/// Applies each [ParticipantCategory.clonePolicy] to a freshly unpacked clone.
///
/// Every category discards today, so this removes the staged tree wholesale. It
/// is written as a per-category walk anyway: when one category stops discarding,
/// the loop is already the right shape and the removal will not silently take
/// the kept state with it.
Future<void> applyCloneParticipantPolicy(Directory cloneDir) async {
  final staged = Directory(p.join(cloneDir.path, participantStagingDirName));
  if (!staged.existsSync()) return;

  for (final entity in staged.listSync()) {
    final id = p.basename(entity.path);
    // A category this build does not know discards too: a clone has no
    // participant that would ever read it.
    final policy =
        ParticipantCategory.tryById(id)?.clonePolicy ?? ClonePolicy.discard;

    switch (policy) {
      case ClonePolicy.discard:
        try {
          await entity.delete(recursive: true);
        } catch (error, stackTrace) {
          logger.w(
            'Could not drop cloned participant state $id',
            error: error,
            stackTrace: stackTrace,
          );
        }
      case ClonePolicy.rekey:
        // Unreachable while nothing selects it. Left as a case rather than a
        // default so adding a policy is a compile error here first.
        logger.w('No clone re-key implementation for $id');
    }
  }

  // Whatever is left is a category this build does not know. It came out of an
  // archive written by a different version, and a clone has no participant that
  // would ever read it — so leaving it would be dead weight inside the profile
  // and inside every future backup of it.
  try {
    if (staged.existsSync() && staged.listSync().isEmpty) {
      await staged.delete();
    } else if (staged.existsSync()) {
      logger.w('Unrecognised participant state left in the clone; removing');
      await staged.delete(recursive: true);
    }
  } catch (error, stackTrace) {
    logger.w(
      'Could not clear the cloned participant directory',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
