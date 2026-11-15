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
import 'package:weblibre/features/app_update/domain/entities/release_metadata.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';

/// The one freshness rule set (plan 5.3), applied to every catalogue the
/// updater relies on: a fresh download and the stored copy used offline alike.
///
/// Only signed time and the compiled build time are ever floors (D18). Device
/// time is read, never stored, so a clock that was wrong once can't lock
/// updates out after it is corrected.
class FreshnessGuard {
  const FreshnessGuard({required this.buildTime});

  /// The installed app's compiled build time.
  final DateTime? buildTime;

  static const slack = Duration(hours: 24);

  /// The last moment [check] accepts [catalogue] as unexpired. Native refuses
  /// to commit past this point on the raw device clock (7.5), so the two
  /// sides agree on the same catalogue: with the device clock at or above
  /// the floor, [check]'s expiry rule is exactly `deviceNow <= usableUntil`.
  static DateTime usableUntil(ReleaseCatalogue catalogue) =>
      catalogue.expiresAt.add(slack);

  /// The latest point in time the updater has evidence for.
  DateTime floor(AcceptedCatalogue? accepted) {
    final candidates = [?accepted?.catalogue.issuedAt, ?buildTime];
    if (candidates.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
    return candidates.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  DateTime effectiveNow(DateTime deviceNow, AcceptedCatalogue? accepted) {
    final evidence = floor(accepted);
    return deviceNow.isAfter(evidence) ? deviceNow : evidence;
  }

  /// Returns the failure that rejects [candidate], or null when it is fresh.
  ///
  /// [accepted] is the highest catalogue accepted so far (null on a fresh
  /// installation). [candidate] may be that same catalogue, re-checked for
  /// offline use.
  UpdateFailure? check({
    required AcceptedCatalogue candidate,
    required AcceptedCatalogue? accepted,
    required DateTime deviceNow,
  }) {
    final catalogue = candidate.catalogue;

    if (accepted != null) {
      if (candidate.revision < accepted.revision) {
        return UpdateFailure(
          UpdateFailureKind.metadataRollback,
          'revision ${candidate.revision} < ${accepted.revision}',
        );
      }
      if (candidate.revision == accepted.revision &&
          candidate.payloadDigest != accepted.payloadDigest) {
        return UpdateFailure(
          UpdateFailureKind.metadataRollback,
          'revision ${candidate.revision} with a different payload',
        );
      }
    }

    // Older than this very build, so it can't describe it. Not a rollback:
    // between a release and the next signing (hourly) the served catalogue
    // is exactly this, so it fails retryably and the next check gets the
    // re-signed one. Still not accepted: it is the first-run floor.
    final buildTime = this.buildTime;
    if (buildTime != null &&
        catalogue.issuedAt.isBefore(buildTime.subtract(slack))) {
      return UpdateFailure(
        UpdateFailureKind.metadataPredatesBuild,
        'issued before this build',
      );
    }

    if (catalogue.issuedAt.isAfter(deviceNow.add(slack))) {
      return UpdateFailure(
        UpdateFailureKind.clockSuspect,
        'issued in the future of the device clock',
      );
    }

    final now = effectiveNow(deviceNow, accepted);
    if (catalogue.expiresAt.isBefore(now.subtract(slack))) {
      return UpdateFailure(UpdateFailureKind.metadataExpired);
    }

    return null;
  }
}
