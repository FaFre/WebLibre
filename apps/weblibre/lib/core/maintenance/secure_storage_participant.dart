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
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/maintenance/maintenance_participant.dart';
import 'package:weblibre/core/secure_storage/legacy_proxy_secrets.dart';
import 'package:weblibre/core/secure_storage/profile_secure_store.dart';
import 'package:weblibre/core/secure_storage/secure_storage_migration.dart';
import 'package:weblibre/core/startup/atomic_json_file.dart';

/// Carries a profile's secure-storage records through backup, restore and delete.
///
/// The only participant implemented in **Dart** rather than Kotlin, and
/// deliberately so. `flutter_secure_storage` v10 encrypts with a custom AES-GCM
/// scheme under a Keystore-wrapped key, and reaching those records from native
/// code would mean reimplementing the plugin's cipher against its private
/// storage layout — a copy that breaks silently the next time the plugin changes
/// how it writes. The plugin channel is available during maintenance because
/// plugins are registered before any profile is activated, which is the whole
/// reason the maintenance isolate can do this at all.
///
/// What it covers: the account session (refresh token, e2e sync key, in-flight
/// PKCE verifier) and the sing-box proxy credentials. Ownership comes from the
/// key suffix — see [ProfileSecureStore] — because secure storage has no notion
/// of a profile of its own.
class SecureStorageParticipant implements MaintenanceParticipant {
  SecureStorageParticipant({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const participantId = 'secureStorage';

  static const _snapshotFile = 'secure_storage.json';
  static const _rollbackFile = 'secure_storage.rollback.json';

  final FlutterSecureStorage _storage;

  @override
  String get id => participantId;

  @override
  int get version => 1;

  ProfileSecureStore _store(MaintenanceParticipantContext context) =>
      ProfileSecureStore(profileId: context.profileId, storage: _storage);

  File _file(Directory root, String name) => File(p.join(root.path, id, name));

  @override
  Future<void> discover(MaintenanceParticipantContext context) async {}

  /// Captures the live records, as archive content or as undo data.
  ///
  /// A profile that has never signed in and configured no proxy is a valid,
  /// empty capture rather than an error.
  @override
  Future<void> prepare(MaintenanceParticipantContext context) async {
    // Legacy first, owned second, and the order is load-bearing: both maps are
    // keyed by *base* name, so whichever comes last wins.
    //
    // Records this profile owns but has never claimed. `migrateUnqualified
    // SecureRecords` runs only for the profile a process activated, so a profile
    // backed up or deleted before it was ever opened on this build still has its
    // proxy credentials under unqualified keys — invisible to the suffix
    // enumeration below.
    //
    // They fill gaps and never override. The two can coexist: the migration
    // writes the scoped key and *then* deletes the legacy one, so a process that
    // died between those two steps leaves both, and a secret changed since then
    // exists as a current scoped value beside a stale legacy one. The scoped
    // record is what `ProfileSecureStore` reads, so it is the live value by
    // definition — archiving the legacy one over it would back up a credential
    // the app itself no longer uses.
    final entries = {
      ...await _claimableLegacyRecords(context),
      ...await _store(context).readAllOwned(),
    };

    final target = switch (context.kind) {
      // Into the archive, so restoring it finds them. A backup mutates nothing,
      // so there is nothing to undo.
      MaintenanceOperationKind.backup => _file(
        context.stagedDir,
        _snapshotFile,
      ),
      // Restore and delete replace or remove live credentials, so the only thing
      // that can undo them is what was there beforehand.
      MaintenanceOperationKind.restore || MaintenanceOperationKind.delete =>
        _file(context.rollbackDir, _rollbackFile),
    };

    await target.parent.create(recursive: true);
    // Atomic like every other durable record on this path — and this is the one
    // whose payload is credentials, so a torn write is the worst case here.
    //
    // Only the archive copy is sanitised. Rollback data is what the live store
    // looked like a moment ago and has to go back byte for byte; "improving" it
    // would mean an undo that restores something other than what was undone.
    await AtomicJsonFile(target).write(
      context.kind == MaintenanceOperationKind.backup
          ? _archivable(entries)
          : entries,
    );
  }

  /// [entries] with the account record made fit to travel.
  ///
  /// Two things happen to it, and only to it:
  ///
  /// - **An in-flight sign-in is dropped.** The PKCE verifier is one half of an
  ///   exchange whose other half — the one-time handoff code and the state nonce
  ///   that authenticates the callback — is not in the archive and never will
  ///   be. Restoring it re-arms a sign-in that can no longer be completed, on a
  ///   device and in a process that never started it, and the callback path
  ///   still accepts a nonce-less callback for backwards compatibility. It is
  ///   the one field here with a lifetime measured in minutes.
  /// - **A record that is not JSON is left out.** Values are opaque strings to
  ///   this participant, so `"account_auth_data": "not json"` used to install and
  ///   verify perfectly while the account layer quietly read it as "never signed
  ///   in" — a restore reporting success over a credential nothing can use.
  ///   Dropping it reaches the same signed-out end state without also planting
  ///   the corrupt blob, and, unlike failing, does not cost the user the tabs and
  ///   history the archive is mostly made of.
  ///
  /// The shallow JSON check is deliberate: `core` cannot import the account
  /// model, and the deep one already exists where it belongs, in
  /// `AccountSecureStore.read`.
  Map<String, String> _archivable(Map<String, String> entries) {
    final account = entries[accountSecureBaseKey];
    if (account == null) return entries;

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(account) as Map<String, dynamic>;
    } catch (error) {
      logger.w(
        'Leaving an account record that is not readable JSON out of the '
        'secure-storage snapshot: $error',
      );
      return {
        for (final entry in entries.entries)
          if (entry.key != accountSecureBaseKey) entry.key: entry.value,
      };
    }

    if (!decoded.containsKey(accountPendingCodeVerifierField)) return entries;

    decoded.remove(accountPendingCodeVerifierField);
    return {...entries, accountSecureBaseKey: jsonEncode(decoded)};
  }

  @override
  Future<void> apply(MaintenanceParticipantContext context) async {
    switch (context.kind) {
      case MaintenanceOperationKind.backup:
        return;

      case MaintenanceOperationKind.restore:
        final staged = await _read(_file(context.stagedDir, _snapshotFile));
        switch (staged) {
          case _SnapshotAbsent():
            // An archive from before this participant. Leaving the live records
            // alone beats deleting an account the archive never carried.
            logger.i(
              'Archive carries no secure records; leaving them as they are',
            );
            return;
          case _SnapshotUnreadable(:final reason):
            // Not the same as absent, and the difference decides whether the
            // user keeps an account. An archive that *does* carry credentials
            // but whose snapshot will not parse must not be silently downgraded
            // to "carried none": that would report a successful restore over a
            // profile whose live credentials are still the pre-restore ones, or
            // — for a restore that also replaced the databases — an account
            // paired with somebody else's browsing data.
            throw StateError(
              'Secure records in the archive are unusable: $reason',
            );
          case _SnapshotPresent(:final entries):
            // Sanitised again on the way in, not only on the way out: archives
            // written before this participant learned to strip an in-flight
            // sign-in — or damaged since — are exactly the ones being restored.
            await _store(context).replaceAllOwned(_archivable(entries));
        }

      case MaintenanceOperationKind.delete:
        await _store(context).deleteAllOwned();
        await _deleteClaimableLegacyRecords(context);
    }
  }

  /// This profile's records that are still under pre-scheme keys.
  ///
  /// Returned under their *base* names, so a backup archives them exactly as if
  /// they had been claimed, and restoring that archive installs them properly
  /// attributed. The claim is a lookup, never a guess: a secret belongs here
  /// only when this profile's own `user.db` holds the proxy profile that uses
  /// it — the same evidence the activation-time migration relies on.
  Future<Map<String, String>> _claimableLegacyRecords(
    MaintenanceParticipantContext context,
  ) async {
    final keys = await _legacyKeysOwnedBy(context);
    if (keys.isEmpty) return const {};

    final all = await _storage.readAll();
    return {
      for (final key in keys)
        if (all[key] case final String value) key: value,
    };
  }

  Future<void> _deleteClaimableLegacyRecords(
    MaintenanceParticipantContext context,
  ) async {
    for (final key in await _legacyKeysOwnedBy(context)) {
      await _storage.delete(key: key);
    }
  }

  Future<Set<String>> _legacyKeysOwnedBy(
    MaintenanceParticipantContext context,
  ) async {
    final directory = context.profileDir;
    if (directory == null || !directory.existsSync()) return const {};

    final ownership = await readProxyProfileIds(directory);
    if (!ownership.readable) {
      // Could not look, which is not the same as nothing being there. Acting on
      // it would mean deleting — or declaring absent — records whose ownership
      // was never actually established.
      logger.w(
        'Could not establish legacy proxy ownership for ${context.profileId}; '
        'leaving those records alone',
      );
      return const {};
    }

    return {
      for (final id in ownership.proxyProfileIds) '$proxySecretKeyPrefix$id',
    };
  }

  @override
  Future<void> verify(MaintenanceParticipantContext context) async {
    switch (context.kind) {
      case MaintenanceOperationKind.backup:
        return;

      case MaintenanceOperationKind.restore:
        final staged = await _read(_file(context.stagedDir, _snapshotFile));
        // Unreadable already threw in `apply`; reaching here with one would mean
        // the file rotted between the two calls, and that is still not a restore
        // anybody should be told succeeded.
        if (staged is _SnapshotAbsent) return;
        if (staged is! _SnapshotPresent) {
          throw StateError('Secure records in the archive became unreadable');
        }
        final expected = _archivable(staged.entries);

        final live = await _store(context).readAllOwned();

        // Values, not just keys. `replaceAllOwned` deletes what it does not
        // write, so the live set should equal the staged set exactly — and a key
        // that exists holding the *previous* profile's refresh token is the one
        // outcome a presence check calls a success.
        final wrong = [
          for (final entry in expected.entries)
            if (live[entry.key] != entry.value) entry.key,
        ];
        if (wrong.isNotEmpty) {
          throw StateError(
            'Secure records did not restore: ${wrong.join(', ')}',
          );
        }

        final extra = live.keys.where((key) => !expected.containsKey(key));
        if (extra.isNotEmpty) {
          throw StateError(
            'Secure records the archive never carried survived the restore: '
            '${extra.join(', ')}',
          );
        }

      case MaintenanceOperationKind.delete:
        final live = await _store(context).readAllOwned();
        if (live.isNotEmpty) {
          throw StateError(
            'Secure records survived the delete: ${live.keys.join(', ')}',
          );
        }

        // The unqualified records this profile owns are deleted by `apply` too,
        // and they are invisible to the suffix enumeration above — so without
        // this a delete could leave a proxy credential behind and still report
        // that it had removed everything.
        final all = await _storage.readAll();
        final legacy = (await _legacyKeysOwnedBy(
          context,
        )).where(all.containsKey);
        if (legacy.isNotEmpty) {
          throw StateError(
            'Legacy secure records survived the delete: ${legacy.join(', ')}',
          );
        }
    }
  }

  /// Drops the undo data. Never fails the operation.
  @override
  Future<void> finalizeWork(MaintenanceParticipantContext context) async {
    final file = _file(context.rollbackDir, _rollbackFile);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  @override
  Future<void> rollback(MaintenanceParticipantContext context) async {
    final snapshot = await _read(_file(context.rollbackDir, _rollbackFile));

    switch (snapshot) {
      case _SnapshotAbsent():
        // Not a failure, per the coordinator's rollback contract: recovery cannot
        // know which participants ran, and no undo data means this one either never
        // applied or already finalized. Failing here would turn an ordinary
        // reconciliation into an unrecoverable one.
        logger.i('No secure-storage rollback data; nothing to put back');
      case _SnapshotUnreadable(:final reason):
        // A file that exists and will not parse is the opposite case: the undo
        // data was written, so this participant did apply, and there is no
        // second copy of what the live credentials used to be. Reporting a
        // successful rollback here would tell recovery the profile is back when
        // its account is gone.
        throw StateError('Secure-storage rollback data is unusable: $reason');
      case _SnapshotPresent(:final entries):
        await _store(context).replaceAllOwned(entries);
    }
  }

  Future<_SnapshotRead> _read(File file) async {
    // `quarantineCorrupt: false` deliberately: for a rollback file this is the
    // only copy of what the live state used to be, so it is never moved aside.
    final result = await AtomicJsonFile(file).read(quarantineCorrupt: false);

    switch (result) {
      case AtomicJsonAbsent():
        return const _SnapshotAbsent();
      case AtomicJsonCorrupt(:final reason):
        logger.w(
          'Could not read secure-storage participant data ${file.path}: '
          '$reason',
        );
        return _SnapshotUnreadable(reason);
      case AtomicJsonPresent(:final json):
        // A non-string value is not a record this participant ever wrote.
        // Dropping it quietly, as this used to, turns a mangled snapshot into a
        // smaller valid-looking one — which restores as "the archive did not
        // carry that credential" and deletes it from the live store.
        final bad = json.entries.where((entry) => entry.value is! String);
        if (bad.isNotEmpty) {
          final reason =
              'non-string values for ${bad.map((entry) => entry.key).join(', ')}';
          logger.w(
            'Malformed secure-storage participant data ${file.path}: $reason',
          );
          return _SnapshotUnreadable(reason);
        }

        return _SnapshotPresent({
          for (final entry in json.entries) entry.key: entry.value! as String,
        });
    }
  }
}

/// What a staged or rollback snapshot file turned out to be.
///
/// Three answers, not two: "there was none" and "there was one and it is
/// damaged" lead to opposite decisions everywhere this is used, and collapsing
/// them into a nullable map is what let a damaged snapshot pass for an archive
/// that simply predated this participant.
sealed class _SnapshotRead {
  const _SnapshotRead();
}

class _SnapshotAbsent extends _SnapshotRead {
  const _SnapshotAbsent();
}

class _SnapshotUnreadable extends _SnapshotRead {
  const _SnapshotUnreadable(this.reason);

  final String reason;
}

class _SnapshotPresent extends _SnapshotRead {
  const _SnapshotPresent(this.entries);

  final Map<String, String> entries;
}
