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

import 'package:crypto/crypto.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/startup/atomic_json_file.dart';
import 'package:weblibre/core/startup/models/json_read.dart';
import 'package:weblibre/core/startup/startup_paths.dart';

const restartAuthorizationVersion = 1;

/// Proof that a restart-into-profile request came from this app.
///
/// `MainActivity` is exported, so an `ACTION_RESTART_INTO_PROFILE` intent is
/// something any app on the device can send. The action and a well-formed
/// profile UUID are therefore not evidence of anything: without this record,
/// another app could close the browser at will and reopen it on a profile of its
/// choosing — losing whatever the user was doing and moving them into a
/// different profile's data.
///
/// Native writes the record to app-private storage immediately before it sends
/// the intent, and the intent carries the matching token. Nothing outside this
/// app can read the file or guess the token, so a request that does not match
/// one was not issued here.
///
/// **Only the hash of the token is stored**, on the same reasoning as the
/// account handoff ledger: the token itself lives in the in-flight intent and
/// nowhere else, so a copy of this file forges nothing.
class RestartAuthorization {
  const RestartAuthorization({
    required this.tokenHash,
    required this.targetProfileId,
    required this.createdAt,
    required this.expiresAt,
    this.version = restartAuthorizationVersion,
  });

  final int version;
  final String tokenHash;

  /// The profile the request may name, and only that one.
  ///
  /// Bound here rather than trusted from the intent: the id decides what the
  /// next process opens, and an authorization for "some restart" would let a
  /// redirected intent choose the profile.
  final String targetProfileId;

  final DateTime createdAt;
  final DateTime expiresAt;

  bool isExpiredAt(DateTime now) => !now.isBefore(expiresAt);

  Map<String, Object?> toJson() => {
    'version': version,
    'tokenHash': tokenHash,
    'targetProfileId': targetProfileId,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'expiresAt': expiresAt.toUtc().toIso8601String(),
  };

  static RestartAuthorization? tryFromJson(Map<String, Object?> json) {
    final tokenHash = json['tokenHash'];
    if (tokenHash is! String || tokenHash.isEmpty) return null;

    final targetProfileId = json['targetProfileId'];
    if (targetProfileId is! String || targetProfileId.isEmpty) return null;

    final createdAt = dateTimeOrNull(json['createdAt']);
    final expiresAt = dateTimeOrNull(json['expiresAt']);
    if (createdAt == null || expiresAt == null) return null;

    final version = json['version'];

    return RestartAuthorization(
      version: version is int ? version : restartAuthorizationVersion,
      tokenHash: tokenHash,
      targetProfileId: targetProfileId.toLowerCase(),
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }
}

/// The hash a restart token is stored under. Mirrors Kotlin's
/// `restartAuthorizationTokenHash`.
String restartAuthorizationTokenHash(String token) =>
    sha256.convert(utf8.encode(token)).toString();

/// Reader for `weblibre_restart/authorization.json`.
///
/// Read-and-consume only: this side never issues an authorization. Issuing one
/// is the privilege the record exists to prove, and it belongs to the native
/// activity that asked the user.
class RestartAuthorizationStore {
  const RestartAuthorizationStore(this.paths);

  final StartupPaths paths;

  Future<RestartAuthorization?> read() async {
    final result = await AtomicJsonFile(
      paths.restartAuthorizationFile,
    ).read(quarantineCorrupt: false);

    if (result is! AtomicJsonPresent) return null;
    return RestartAuthorization.tryFromJson(result.json);
  }

  Future<void> clear() async {
    await AtomicJsonFile(paths.restartAuthorizationFile).delete();
  }

  /// Validates [token] against the stored record, consuming it on a match.
  ///
  /// Returns the authorized profile id, or null when the token was never
  /// issued, has expired, has already been used, or does not authorize
  /// [claimedProfileId]. All of those mean the same thing to the caller — this
  /// request is not one this app made — and none of them may end the process.
  ///
  /// A request that does *not* match leaves the record where it is. Spending it
  /// on every attempt would look more careful and be strictly worse: the token is
  /// 256 unguessable bits with a two-minute life, so nothing is gained against
  /// brute force, while any app on the device could destroy the restart the user
  /// just asked for by firing one intent with a made-up token. The TTL is what
  /// retires an unanswered record.
  Future<String?> consume(
    String? token, {
    required String? claimedProfileId,
    DateTime? now,
  }) async {
    final at = (now ?? DateTime.now()).toUtc();
    final stored = await read();

    if (stored == null) {
      logger.w('Refusing a restart request with no authorization on record');
      return null;
    }

    if (stored.isExpiredAt(at)) {
      // Gone either way: an expired record authorizes nothing, and leaving it
      // would only make the next read do this again.
      await clear();
      logger.w('Refusing a restart request whose authorization had expired');
      return null;
    }

    if (token == null ||
        token.isEmpty ||
        restartAuthorizationTokenHash(token) != stored.tokenHash) {
      logger.w('Refusing a restart request without a matching authorization');
      return null;
    }

    // The token matched, so this is the request the record was written for and
    // the record is spent — whether or not the rest of it holds up.
    await clear();

    if (claimedProfileId != null &&
        claimedProfileId.toLowerCase() != stored.targetProfileId) {
      // The record names the profile the user answered for. An intent that
      // matched the token but named another one is a redirected request.
      logger.w('Refusing a restart request that named an unauthorized profile');
      return null;
    }

    return stored.targetProfileId;
  }
}
