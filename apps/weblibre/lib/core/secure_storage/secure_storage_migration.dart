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
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/secure_storage/profile_secure_keys.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';

/// Base key of the account session, sync key and in-flight PKCE verifier.
const accountSecureBaseKey = 'account_auth_data';

/// Field of the account record holding the PKCE verifier of a sign-in that is
/// still in progress.
///
/// Named here rather than in the account feature because the maintenance
/// participant has to strip it on the way into an archive, and `core` may not
/// reach into a feature to ask. It must stay equal to
/// `AccountPersistedData.pendingCodeVerifier`'s JSON key; there is a test that
/// says so.
const accountPendingCodeVerifierField = 'pendingCodeVerifier';

/// Prefix of the per-proxy-profile sing-box credential records.
const proxySecretKeyPrefix = 'singbox_proxy.secret.';

/// What a migration run did, for logging and tests.
class SecureStorageMigrationResult {
  const SecureStorageMigrationResult({
    this.claimedProxySecrets = 0,
    this.leftForOtherProfiles = 0,
    this.parkedAccountRecord = false,
  });

  final int claimedProxySecrets;
  final int leftForOtherProfiles;

  /// An account record exists that belongs to no profile yet. Not an action —
  /// the record is untouched — just the observation that one is waiting.
  final bool parkedAccountRecord;

  bool get changedAnything => claimedProxySecrets > 0;
}

/// Moves pre-profile secure records onto the key scheme that carries ownership.
///
/// Runs on every activation and is a no-op once there is nothing unqualified
/// left; the records it moves are the records it consumes, so it needs no
/// "already migrated" marker to be exactly-once.
///
/// The two record kinds get deliberately different treatment, because only one
/// of them can be attributed:
///
/// - **Proxy credentials** are keyed by proxy-profile UUID, and the row that
///   uses them lives in *this* profile's `user.db`. So ownership is a lookup,
///   not a guess: a secret is claimed only when this profile actually has the
///   proxy profile that references it. Another profile's secrets are left
///   untouched for it to claim when it activates.
/// - **The account record** has no such evidence anywhere — no profile database
///   holds account state, it all lives in secure storage. So it is *left alone*
///   rather than attributed. Handing it to whichever profile happens to boot
///   first would be the same mistake as filing another profile's push message
///   under whichever profile won startup, and this plan refuses that everywhere
///   else.
///
/// Leaving it un-attributed would cost the user a sign-in they never asked for,
/// which is why it is not the end of the story: the one party that *does* know
/// which profile the account belongs to is the user, and
/// `findUnclaimedAccountRecord` offers it to them by name rather than guessing
/// or discarding. Until they answer, the record stays readable under its
/// original key so nothing — including an older build — loses access to it.
Future<SecureStorageMigrationResult> migrateUnqualifiedSecureRecords({
  required String profileId,
  required Set<String> ownedProxyProfileIds,
  FlutterSecureStorage? storage,
}) async {
  final store = storage ?? const FlutterSecureStorage();

  final Map<String, String> all;
  try {
    all = await store.readAll();
  } catch (error, stackTrace) {
    // A store that cannot be enumerated is not a reason to fail startup: the
    // legacy records stay where they are and the next launch tries again.
    logger.w(
      'Could not enumerate secure storage; leaving legacy records in place',
      error: error,
      stackTrace: stackTrace,
    );
    return const SecureStorageMigrationResult();
  }

  var claimed = 0;
  var left = 0;
  var parked = false;

  for (final entry in all.entries) {
    final key = entry.key;

    // Already carries an owner, or already parked.
    if (profileOfSecureKey(key) != null) continue;
    if (key.endsWith(secureKeyUnattributedSuffix)) continue;

    if (key == accountSecureBaseKey) {
      // Left exactly where it is, and deliberately not rewritten.
      //
      // The earlier version moved it to an `@unattributed` key and deleted the
      // original. That destroyed nothing in principle, but in practice it made
      // the record unreadable to any build that had not learned the new key —
      // so a user who went back to a previous version found themselves signed
      // out with their session sitting under a name that version had never
      // heard of. Renaming a credential is not a free operation.
      //
      // Leaving it costs a no-op pass over one key on every launch and keeps
      // every reader that ever existed able to find it. Attribution is offered
      // to the user instead; see `findUnclaimedAccountRecord`.
      parked = true;
      continue;
    }

    if (key.startsWith(proxySecretKeyPrefix)) {
      final proxyProfileId = key.substring(proxySecretKeyPrefix.length);
      if (!ownedProxyProfileIds.contains(proxyProfileId)) {
        left++;
        continue;
      }

      await store.write(
        key: profileScopedSecureKey(key, profileId),
        value: entry.value,
      );
      await store.delete(key: key);
      claimed++;
    }
  }

  final result = SecureStorageMigrationResult(
    claimedProxySecrets: claimed,
    leftForOtherProfiles: left,
    parkedAccountRecord: parked,
  );

  if (result.changedAnything || left > 0) {
    logger.i(
      'Secure storage migration: claimed $claimed proxy secret(s), '
      'left $left for other profiles, '
      '${parked ? 'found an' : 'found no'} unclaimed account record',
    );
  }

  return result;
}

/// Runs the migration for the profile this isolate has activated.
///
/// Takes the repository rather than a `Ref`, because the two entry points hold
/// different kinds of ref — `Ref` in the initialization service, `WidgetRef` in
/// `main` — and the migration has no business caring which.
///
/// Failure is recorded and swallowed: legacy records staying put for another
/// launch is a far better outcome than a profile that will not start.
Future<void> migrateSecureStorageForActiveProfile(
  SingboxProxyProfilesRepository proxyProfilesRepository,
) async {
  try {
    final proxyProfiles = await proxyProfilesRepository.fetchProfiles();

    await migrateUnqualifiedSecureRecords(
      profileId: filesystem.selectedProfile.uuid,
      // The ownership evidence: a proxy secret belongs to this profile exactly
      // when this profile's database holds the proxy profile that uses it.
      ownedProxyProfileIds: proxyProfiles.map((profile) => profile.id).toSet(),
    );
  } catch (error, stackTrace) {
    logger.w(
      'Secure storage migration did not run',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
