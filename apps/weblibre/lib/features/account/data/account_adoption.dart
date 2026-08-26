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

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/secure_storage/profile_secure_keys.dart';
import 'package:weblibre/core/secure_storage/profile_secure_store.dart';
import 'package:weblibre/core/secure_storage/secure_storage_migration.dart';
import 'package:weblibre/features/account/data/models/account_persisted_data.dart';

/// An account session on this device that belongs to no profile yet.
///
/// Before profiles had a secure-storage boundary there was exactly one account
/// record, shared by every profile. Qualifying the keys fixed that isolation
/// defect, but it left the existing record with no owner — and nothing on the
/// device records which profile it was for, because no profile database holds
/// account state.
///
/// Guessing is not available: attaching a credential to the wrong profile is the
/// precise failure the boundary exists to prevent. Discarding it is not
/// acceptable either — it signs the user out of an account they never chose to
/// leave. So the record is offered back to the **user**, who is the only party
/// that actually knows the answer, named by the address it belongs to.
class UnclaimedAccountRecord {
  const UnclaimedAccountRecord({
    required this.storageKey,
    required this.rawValue,
    required this.isUsable,
    this.email,
    this.displayName,
  });

  /// Where the record currently lives — the pre-scheme `account_auth_data`, or
  /// the `@unattributed` key an earlier build of this branch moved it to.
  final String storageKey;

  /// Kept verbatim so adoption re-files the record byte for byte rather than
  /// round-tripping it through a model that may not know every field.
  final String rawValue;

  final String? email;
  final String? displayName;

  /// Whether the record can still be turned back into an account.
  ///
  /// False when the stored JSON does not decode into [AccountPersistedData] —
  /// and that is not a cosmetic detail, because `AccountSecureStore.read` parses
  /// it with the same call. Adopting an unreadable record would file a blob no
  /// part of the app can use under this profile's key, where the auth repository
  /// then trips over it on every build. So it is still *shown* — silently
  /// dropping a credential is what this whole flow refuses to do — but only
  /// discarding it is offered.
  final bool isUsable;

  /// What to call the account on screen. Never a bare "an account": a choice
  /// about a credential the user cannot identify is not a choice.
  String get label => email ?? displayName ?? 'a previous sign-in';
}

/// Finds an account record that no profile owns.
///
/// Returns null when there is none, when this profile already has its own (an
/// adoption would clobber a live sign-in), or when secure storage cannot be
/// read.
Future<UnclaimedAccountRecord?> findUnclaimedAccountRecord({
  required String profileId,
  FlutterSecureStorage? storage,
}) async {
  final store = storage ?? const FlutterSecureStorage();

  final Map<String, String> all;
  try {
    all = await store.readAll();
  } catch (error, stackTrace) {
    logger.w(
      'Could not enumerate secure storage for an unclaimed account',
      error: error,
      stackTrace: stackTrace,
    );
    return null;
  }

  // A profile that is already signed in has nothing to adopt, and offering it
  // would mean proposing to replace a session the user is actively using.
  if (all.containsKey(
    profileScopedSecureKey(accountSecureBaseKey, profileId),
  )) {
    return null;
  }

  // The legacy key first: it is where the record still is on a device that
  // upgraded to this build, while `@unattributed` only exists on one that ran an
  // earlier revision of this branch.
  const parked = '$accountSecureBaseKey$secureKeyUnattributedSuffix';
  final key = all.containsKey(accountSecureBaseKey)
      ? accountSecureBaseKey
      : (all.containsKey(parked) ? parked : null);
  if (key == null) return null;

  final raw = all[key]!;

  String? email;
  String? displayName;
  var usable = true;
  try {
    final data = AccountPersistedData.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    email = data.email;
    displayName = data.displayName;
  } catch (error) {
    // Still offered, just unnamed and not adoptable. Refusing to mention it
    // would sign the user out for a reason they can never discover; offering to
    // adopt it would move a blob the app cannot read into this profile's key.
    usable = false;
    logger.w('Unclaimed account record could not be described: $error');
  }

  return UnclaimedAccountRecord(
    storageKey: key,
    rawValue: raw,
    isUsable: usable,
    email: email,
    displayName: displayName,
  );
}

/// Files [record] under [profileId] — the user's answer to the ownership
/// question the device could not answer for itself.
///
/// Written before the old key is removed, so an interruption leaves the record
/// duplicated rather than gone. A duplicate is inert (the second copy simply
/// stops being offered); a loss is a sign-out with no way back.
Future<void> adoptAccountRecord(
  UnclaimedAccountRecord record, {
  required String profileId,
  FlutterSecureStorage? storage,
}) async {
  if (!record.isUsable) {
    // Belt and braces: the tile does not offer adoption for one of these, and a
    // caller that got here anyway is about to install a record that
    // `AccountSecureStore.read` will throw on for the life of the profile.
    throw StateError('Refusing to adopt an unreadable account record');
  }

  final store = storage ?? const FlutterSecureStorage();
  final destination = ProfileSecureStore(profileId: profileId, storage: store);

  // Re-checked here and not only in `findUnclaimedAccountRecord`, because the
  // card can sit on screen indefinitely: the user reads it, thinks about it, and
  // may sign in normally — or have a `weblibre://account/callback` arrive — in
  // between. The record they are answering about is old; the profile's own
  // sign-in would not be, and this write would replace it.
  if (await destination.read(accountSecureBaseKey) != null) {
    throw StateError(
      'Refusing to adopt over an account this profile signed in to since the '
      'record was offered',
    );
  }

  await destination.write(accountSecureBaseKey, record.rawValue);
  // The raw store, deliberately: [record.storageKey] is the *unscoped* key the
  // record is being adopted away from.
  await store.delete(key: record.storageKey);

  logger.i('Account record adopted by $profileId');
}

/// Discards [record] for good.
///
/// Only ever from an explicit choice. This is a credential: the difference
/// between "not mine" and "not now" is the user's to make, and nothing here
/// makes it for them on a timer or at startup.
Future<void> discardAccountRecord(
  UnclaimedAccountRecord record, {
  FlutterSecureStorage? storage,
}) async {
  await (storage ?? const FlutterSecureStorage()).delete(
    key: record.storageKey,
  );
  logger.i('Unclaimed account record discarded');
}
