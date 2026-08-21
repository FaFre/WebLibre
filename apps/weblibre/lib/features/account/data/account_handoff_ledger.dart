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
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid_value.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/startup/atomic_json_file.dart';
import 'package:weblibre/core/startup/models/json_read.dart';
import 'package:weblibre/core/startup/startup_paths.dart';

/// How long a started sign-in stays redeemable.
///
/// Comfortably longer than the five-minute UI timeout: the record has to
/// outlive a sign-in that took the user through an email round trip, and an
/// expired record fails safely rather than silently.
const accountHandoffTtl = Duration(minutes: 20);

/// At most this many sign-ins may be in flight at once.
///
/// Not a security boundary, a size bound — the file is read on every callback,
/// and a user who repeatedly taps "sign in" should not be able to grow it.
const accountHandoffMaxRecords = 8;

const accountHandoffLedgerVersion = 1;

/// A nonce the app sent with an authentication request, and what it means.
///
/// **Only the hash of the nonce is stored.** The nonce itself exists in the
/// authentication URL and in the callback that echoes it, and nowhere else. So a
/// copy of this file — leaked through a backup, say — does not let anything forge
/// a callback that this app would accept.
class AccountHandoffRecord {
  const AccountHandoffRecord({
    required this.stateHash,
    required this.profileId,
    required this.mode,
    required this.createdAt,
    required this.expiresAt,
  });

  final String stateHash;

  /// The profile that started the sign-in. The reason the ledger is global: a
  /// callback can arrive before any profile is committed, and this is the only
  /// record of where it belongs.
  final String profileId;

  final String mode;
  final DateTime createdAt;
  final DateTime expiresAt;

  bool isExpiredAt(DateTime now) => !now.isBefore(expiresAt);

  Map<String, Object?> toJson() => {
    'stateHash': stateHash,
    'profileId': profileId,
    'mode': mode,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'expiresAt': expiresAt.toUtc().toIso8601String(),
  };

  static AccountHandoffRecord? tryFromJson(Map<String, Object?> json) {
    final stateHash = json['stateHash'];
    if (stateHash is! String || stateHash.isEmpty) return null;

    final profileId = json['profileId'];
    if (profileId is! String || profileId.isEmpty) return null;

    final createdAt = dateTimeOrNull(json['createdAt']);
    final expiresAt = dateTimeOrNull(json['expiresAt']);
    if (createdAt == null || expiresAt == null) return null;

    try {
      UuidValue.withValidation(profileId.toLowerCase());
    } catch (_) {
      // A record that cannot name a real profile can never be honoured, and
      // keeping it would only make the ledger harder to reason about.
      return null;
    }

    return AccountHandoffRecord(
      stateHash: stateHash,
      profileId: profileId.toLowerCase(),
      mode: json['mode'] as String? ?? 'handoff',
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }
}

/// The hash a nonce is stored under.
String accountHandoffStateHash(String stateNonce) =>
    sha256.convert(utf8.encode(stateNonce)).toString();

/// A fresh nonce to send with an authentication request.
String generateAccountHandoffState() {
  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

/// The global, expiring, one-time record of which profile started which sign-in.
///
/// It exists because the callback carries an opaque code and nothing else. A
/// pending sign-in is not proof that a given callback belongs to it: any app on
/// the device can fire `weblibre://account/callback?code=…` at us, and without a
/// nonce to check there is no way to tell that from the real thing. Consuming a
/// record proves the callback answers an authentication *this* app started.
class AccountHandoffLedger {
  AccountHandoffLedger(this.paths);

  final StartupPaths paths;

  Future<List<AccountHandoffRecord>> read() async {
    final result = await AtomicJsonFile(
      paths.accountHandoffFile,
    ).read(quarantineCorrupt: false);

    if (result is! AtomicJsonPresent) return const [];

    final raw = result.json['records'];
    if (raw is! List) return const [];

    return [
      for (final entry in raw)
        if (entry is Map)
          ?AccountHandoffRecord.tryFromJson(
            entry.map((key, value) => MapEntry(key.toString(), value)),
          ),
    ];
  }

  /// Records that [profileId] started a sign-in identified by [stateNonce].
  Future<AccountHandoffRecord> record({
    required String stateNonce,
    required String profileId,
    String mode = 'handoff',
    DateTime? now,
  }) async {
    final at = (now ?? DateTime.now()).toUtc();

    final record = AccountHandoffRecord(
      stateHash: accountHandoffStateHash(stateNonce),
      profileId: profileId.toLowerCase(),
      mode: mode,
      createdAt: at,
      expiresAt: at.add(accountHandoffTtl),
    );

    final existing = await read();
    final retained = existing
        .where((entry) => !entry.isExpiredAt(at))
        .where((entry) => entry.stateHash != record.stateHash)
        .toList();

    // Newest kept: an older in-flight sign-in the user abandoned matters less
    // than the one they just started.
    final all = [record, ...retained].take(accountHandoffMaxRecords).toList();
    await _write(all);

    return record;
  }

  /// Validates [stateNonce] and removes its record.
  ///
  /// Null for a nonce that was never issued, has expired, or has already been
  /// used. All three mean the same thing to the caller — this callback is not
  /// answering a sign-in we can account for — and none of them may select a
  /// profile or disturb a pending flow.
  ///
  /// [ownedBy] is the profile entitled to redeem it, and a record belonging to
  /// any other profile is left exactly where it is. The ledger is global while a
  /// process serves one profile at a time, so a callback can arrive at a profile
  /// that did not start the sign-in — and spending the one-time record there
  /// would destroy a flow this process cannot complete and the right one can.
  /// The nonce is the secret that makes this safe to leave in place: presenting
  /// it already requires having been given it.
  Future<AccountHandoffRecord?> consume(
    String stateNonce, {
    required String ownedBy,
    DateTime? now,
  }) async {
    final at = (now ?? DateTime.now()).toUtc();
    final hash = accountHandoffStateHash(stateNonce);

    final existing = await read();
    final match = existing
        .where((entry) => entry.stateHash == hash)
        .firstOrNull;

    if (match != null &&
        !match.isExpiredAt(at) &&
        match.profileId != ownedBy.toLowerCase()) {
      // Left in place, but the expired sweep below still runs: holding another
      // profile's live record does not entitle this one to keep dead ones.
      logger.w(
        'An account callback for profile ${match.profileId} reached '
        '$ownedBy; leaving its sign-in intact',
      );
      await _pruneExpired(existing, at);
      return null;
    }

    // Removed whether or not it was still valid: a replayed nonce must not be
    // able to keep an expired record alive by being presented repeatedly.
    final retained = existing
        .where((entry) => entry.stateHash != hash)
        .where((entry) => !entry.isExpiredAt(at))
        .toList();

    if (match != null || retained.length != existing.length) {
      await _write(retained);
    }

    if (match == null) return null;
    if (match.isExpiredAt(at)) {
      logger.w('Refusing an account callback whose sign-in had expired');
      return null;
    }

    return match;
  }

  /// Drops expired records from [existing] without touching live ones.
  Future<void> _pruneExpired(
    List<AccountHandoffRecord> existing,
    DateTime at,
  ) async {
    final retained = existing.where((entry) => !entry.isExpiredAt(at)).toList();
    if (retained.length != existing.length) {
      await _write(retained);
    }
  }

  Future<void> prune({DateTime? now}) async {
    final at = (now ?? DateTime.now()).toUtc();
    final existing = await read();
    final retained = existing.where((entry) => !entry.isExpiredAt(at)).toList();
    if (retained.length != existing.length) {
      await _write(retained);
    }
  }

  Future<void> _write(List<AccountHandoffRecord> records) async {
    await AtomicJsonFile(paths.accountHandoffFile).write({
      'version': accountHandoffLedgerVersion,
      'records': [for (final record in records) record.toJson()],
    });
  }
}
