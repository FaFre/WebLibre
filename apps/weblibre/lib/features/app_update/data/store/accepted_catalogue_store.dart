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
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:synchronized/synchronized.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/app_update/data/metadata/catalogue_reader.dart';
import 'package:weblibre/features/app_update/data/store/update_file_system.dart';
import 'package:weblibre/features/app_update/domain/entities/release_metadata.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';

sealed class AcceptedCatalogueRead {
  const AcceptedCatalogueRead();
}

/// Both copies absent: a fresh installation, with the build-time floor only.
final class NoAcceptedCatalogue extends AcceptedCatalogueRead {
  const NoAcceptedCatalogue();
}

final class AcceptedCatalogueLoaded extends AcceptedCatalogueRead {
  const AcceptedCatalogueLoaded(this.accepted);

  final AcceptedCatalogue accepted;
}

/// Damaged or conflicting trust state (6.1). Survives restarts because the
/// files stay where they are; only an explicit reset clears it.
final class TrustRecoveryRequired extends AcceptedCatalogueRead {
  const TrustRecoveryRequired(this.reason);

  final String reason;
}

/// The accepted catalogue, kept as the exact signed envelope bytes in two
/// copies (plan 6.1). A signed envelope authenticates itself, so neither copy
/// needs a checksum, a generation number or a separately stored revision.
///
/// Accepting writes copy A, then copy B; acceptance is committed when the
/// rename of A returns. The files change only when the revision rises, so a
/// crash between the two leaves A one revision ahead, which the next open
/// repairs.
class AcceptedCatalogueStore {
  AcceptedCatalogueStore({
    required String stateDir,
    required this.reader,
    this.fs = const IoUpdateFileSystem(),
  }) : pathA = p.join(stateDir, 'accepted_a.dsse'),
       pathB = p.join(stateDir, 'accepted_b.dsse');

  final String pathA;
  final String pathB;

  /// Its codec rejects another package's catalogue.
  final CatalogueReader reader;
  final UpdateFileSystem fs;

  final _lock = Lock();
  AcceptedCatalogueRead? _current;

  /// The state after the last [open], [accept] or [reset].
  AcceptedCatalogueRead? get current => _current;

  AcceptedCatalogue? get accepted => switch (_current) {
    AcceptedCatalogueLoaded(:final accepted) => accepted,
    _ => null,
  };

  bool get recoveryRequired => _current is TrustRecoveryRequired;

  /// Reads both copies once at start, before any authorization.
  Future<AcceptedCatalogueRead> open() => _lock.synchronized(_openLocked);

  Future<AcceptedCatalogueRead> _openLocked() async {
    final bytesA = await _readSafely(pathA);
    final bytesB = await _readSafely(pathB);

    final copyA = await _parse(bytesA);
    // The copies are normally identical: verify once.
    final copyB =
        bytesA != null &&
            bytesB != null &&
            const ListEquality<int>().equals(bytesA, bytesB)
        ? copyA
        : await _parse(bytesB);
    final a = copyA.catalogue;
    final b = copyB.catalogue;

    final AcceptedCatalogueRead result;
    if (a == null && b == null) {
      if (copyA.damaged || copyB.damaged) {
        result = const TrustRecoveryRequired('no valid copy');
      } else {
        // Absent, or signed only by keys this build lists as retired (the
        // keys are per year): no evidence either way, so start from the
        // build-time floor as a fresh installation does. That floor is above
        // the stored one: a key is retired only by a release later than every
        // catalogue it signed alone. A key ID that is merely unknown is damage
        // (6.2). The files are replaced by the next accepted catalogue.
        if (bytesA != null || bytesB != null) {
          logger.i('Accepted catalogue was signed by a retired key');
        }
        return _current = const NoAcceptedCatalogue();
      }
    } else if (a != null && b != null) {
      if (a.revision == b.revision) {
        result = a.payloadDigest == b.payloadDigest
            ? AcceptedCatalogueLoaded(a)
            : const TrustRecoveryRequired('same revision, different payloads');
      } else {
        final higher = a.revision > b.revision ? a : b;
        await (higher == a
            ? _rewrite(pathB, bytesB, higher)
            : _rewrite(pathA, bytesA, higher));
        result = AcceptedCatalogueLoaded(higher);
      }
    } else {
      final valid = (a ?? b)!;
      await (a == null
          ? _rewrite(pathA, bytesA, valid)
          : _rewrite(pathB, bytesB, valid));
      result = AcceptedCatalogueLoaded(valid);
    }

    if (result is TrustRecoveryRequired) {
      logger.w('App update trust state needs recovery: ${result.reason}');
    }
    return _current = result;
  }

  /// Stores [candidate] after [FreshnessGuard] accepted it. Refuses to lower
  /// the floor or to act while recovery is required.
  Future<void> accept(AcceptedCatalogue candidate) =>
      _lock.synchronized(() async {
        final current = _current ?? await _openLocked();
        switch (current) {
          case TrustRecoveryRequired():
            throw UpdateFailure(UpdateFailureKind.stateCorrupt);
          case AcceptedCatalogueLoaded(:final accepted):
            if (candidate.revision < accepted.revision) {
              throw UpdateFailure(UpdateFailureKind.metadataRollback);
            }
            if (candidate.revision == accepted.revision) {
              if (candidate.payloadDigest != accepted.payloadDigest) {
                throw UpdateFailure(UpdateFailureKind.metadataRollback);
              }
              return; // Already accepted.
            }
          case NoAcceptedCatalogue():
            break;
        }

        await fs.writeAtomic(pathA, candidate.envelopeBytes);
        // Committed: from here on the new revision is the floor.
        _current = AcceptedCatalogueLoaded(candidate);
        try {
          await fs.writeAtomic(pathB, candidate.envelopeBytes);
        } catch (e, s) {
          // A is ahead; the next open repairs B.
          logger.w('Could not write accepted_b.dsse', error: e, stackTrace: s);
        }
      });

  /// "Reset and check again": the one place the revision floor can be
  /// lowered, and only by a tap (6.1). Staged downloads are kept. Only
  /// damaged copies are kept for diagnosis; valid ones are just removed.
  Future<void> reset() => _lock.synchronized(() async {
    if ((_current ?? await _openLocked()) is TrustRecoveryRequired) {
      await fs.preserve(pathA);
      await fs.preserve(pathB);
    }
    await fs.delete(pathA);
    await fs.delete(pathB);
    _current = const NoAcceptedCatalogue();
  });

  Future<List<int>?> _readSafely(String path) async {
    try {
      return await fs.readBytes(path);
    } catch (e) {
      // Present but unreadable is damage, never absence.
      logger.w('Could not read $path: $e');
      return const [];
    }
  }

  /// Null [bytes] is an absent file. Empty bytes are an unreadable one
  /// ([_readSafely]), which is damage.
  Future<_StoredCopy> _parse(List<int>? bytes) async {
    if (bytes == null) return const _StoredCopy.absent();
    if (bytes.isEmpty) return const _StoredCopy.damaged();
    try {
      return _StoredCopy.valid(await reader.read(bytes));
    } on CatalogueSignerRetired {
      return const _StoredCopy.absent();
    } on UpdateFailure {
      return const _StoredCopy.damaged();
    }
  }

  /// [existing] is what [_openLocked] just read from [path].
  Future<void> _rewrite(
    String path,
    List<int>? existing,
    AcceptedCatalogue from,
  ) async {
    try {
      if (existing != null &&
          const ListEquality<int>().equals(existing, from.envelopeBytes)) {
        return;
      }
      await fs.writeAtomic(path, from.envelopeBytes);
    } catch (e, s) {
      logger.w('Could not repair $path', error: e, stackTrace: s);
    }
  }
}

/// One stored copy as read: a verified catalogue, damaged, or no evidence
/// (absent, or signed only by a retired key).
class _StoredCopy {
  const _StoredCopy.valid(AcceptedCatalogue this.catalogue) : damaged = false;
  const _StoredCopy.absent() : catalogue = null, damaged = false;
  const _StoredCopy.damaged() : catalogue = null, damaged = true;

  final AcceptedCatalogue? catalogue;
  final bool damaged;
}
