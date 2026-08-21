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
    await AtomicJsonFile(target).write(entries);
  }

  @override
  Future<void> apply(MaintenanceParticipantContext context) async {
    switch (context.kind) {
      case MaintenanceOperationKind.backup:
        return;

      case MaintenanceOperationKind.restore:
        final staged = await _read(_file(context.stagedDir, _snapshotFile));
        if (staged == null) {
          // An archive from before this participant. Leaving the live records
          // alone beats deleting an account the archive never carried.
          logger.i(
            'Archive carries no secure records; leaving them as they are',
          );
          return;
        }
        await _store(context).replaceAllOwned(staged);

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
        if (staged == null) return;

        final live = await _store(context).readAllOwned();
        final missing = staged.keys.where((key) => !live.containsKey(key));
        if (missing.isNotEmpty) {
          throw StateError(
            'Secure records did not restore: ${missing.join(', ')}',
          );
        }

      case MaintenanceOperationKind.delete:
        final live = await _store(context).readAllOwned();
        if (live.isNotEmpty) {
          throw StateError(
            'Secure records survived the delete: ${live.keys.join(', ')}',
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
    if (snapshot == null) {
      // Not a failure, per the coordinator's rollback contract: recovery cannot
      // know which participants ran, and no undo data means this one either never
      // applied or already finalized. Failing here would turn an ordinary
      // reconciliation into an unrecoverable one.
      logger.i('No secure-storage rollback data; nothing to put back');
      return;
    }

    await _store(context).replaceAllOwned(snapshot);
  }

  Future<Map<String, String>?> _read(File file) async {
    // `quarantineCorrupt: false` deliberately: for a rollback file this is the
    // only copy of what the live state used to be, so it is never moved aside.
    final result = await AtomicJsonFile(file).read(quarantineCorrupt: false);

    if (result is! AtomicJsonPresent) {
      if (result is AtomicJsonCorrupt) {
        logger.w(
          'Could not read secure-storage participant data ${file.path}: '
          '${result.reason}',
        );
      }
      return null;
    }

    return {
      for (final entry in result.json.entries)
        if (entry.value is String) entry.key: entry.value! as String,
    };
  }
}
