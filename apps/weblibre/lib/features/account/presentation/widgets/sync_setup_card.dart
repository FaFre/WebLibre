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
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:secure_archive/secure_archive.dart';
import 'package:weblibre/features/account/data/repositories/account_sync_repository.dart';
import 'package:weblibre/features/account/domain/repositories/account_auth.dart';

/// Lets a signed-in user derive an end-to-end encryption key from their
/// account password.
///
/// Two safety nets keep a mistyped password from silently locking the
/// user out of future restores:
///
/// 1. **Confirm-password field.** Same password must be typed twice; the
///    enable button stays disabled until the two fields match. This is
///    the only defence on the *first device* because there's nothing
///    remote to validate against yet.
/// 2. **Validation probe.** After the first device successfully enables
///    sync, a small encrypted canary is uploaded under
///    [SyncDocumentKind.syncValidationProbe]. On every *subsequent*
///    device, the probe is decrypted with the candidate key before the
///    key is persisted — wrong passwords are caught immediately rather
///    than silently breaking the next restore.
class SyncSetupCard extends HookConsumerWidget {
  const SyncSetupCard({super.key, required this.email});

  final String? email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordController = useTextEditingController();
    final confirmController = useTextEditingController();
    useListenable(passwordController);
    useListenable(confirmController);

    final busy = useState(false);
    final error = useState<String?>(null);

    final password = passwordController.text;
    final confirm = confirmController.text;
    final passwordsMatch = password.isNotEmpty && password == confirm;

    Future<void> setupSyncKey() async {
      if (password.isEmpty) {
        error.value = 'Please enter your password';
        return;
      }
      if (password != confirm) {
        error.value = 'Passwords do not match';
        return;
      }

      busy.value = true;
      error.value = null;

      try {
        final syncKey = _deriveSyncKey(email: email, password: password);

        // Validate the candidate key against any existing encrypted envelope
        // before persisting. Without this, a wrong password is silently
        // accepted, leaving the in-memory syncKey unable to decrypt future
        // restores — and a "Set up sync" UX that looks successful is
        // actively misleading.
        final syncRepo = ref.read(accountSyncRepositoryProvider.notifier);
        final probe = await _findValidationProbe(syncRepo);
        if (probe != null) {
          final ok = await _canDecrypt(probe.contentBlob, syncKey);
          if (!ok) {
            error.value =
                'Password did not match your existing encrypted backups.';
            return;
          }
        } else {
          // First device on this account — nothing exists to validate
          // against, so we leave a probe behind for the *next* device's
          // setup to verify against. Failing the whole setup if the
          // probe upload fails (rather than silently degrading to "no
          // probe written") keeps the contract simple: if sync is
          // enabled here, a probe exists on the server. The user can
          // retry — probe upload is a single small insert and the most
          // likely failure cause is transient network.
          await _uploadValidationProbe(syncRepo, syncKey);
        }

        await ref
            .read(accountAuthRepositoryProvider.notifier)
            .setSyncKey(syncKey);
      } catch (e) {
        error.value = 'Failed to set up sync: $e';
      } finally {
        busy.value = false;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_outlined),
              const SizedBox(width: 8),
              Text(
                'Set Up Encrypted Sync',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your account password to enable end-to-end encrypted '
            'sync. Your data is encrypted on-device before upload — '
            'the server never sees your settings.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: 'Account Password',
              border: const OutlineInputBorder(),
              errorText: error.value,
            ),
            obscureText: true,
            enabled: !busy.value,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: confirmController,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            enabled: !busy.value,
            onSubmitted: (_) => setupSyncKey(),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: (busy.value || !passwordsMatch) ? null : setupSyncKey,
              child: busy.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enable Sync'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Derives the sync key the rest of the app stores. The output is a
/// 64-char hex string fed to [SecureData] as a passphrase; the real
/// argon2id stretch happens inside [SecureData] every time it
/// encrypts/decrypts.
///
/// This HMAC step is not the cryptographic primitive — it just
/// canonicalises `(email, password)` into a fixed-length deterministic
/// string. Two devices reaching the same [syncKey] is necessary for
/// cross-device decrypt to work.
String _deriveSyncKey({required String? email, required String password}) {
  final normalizedEmail = email?.toLowerCase() ?? '';
  final hmac = Hmac(sha256, utf8.encode('weblibre-sync'));
  final digest = hmac.convert(utf8.encode('$normalizedEmail:$password'));
  return digest.toString();
}

/// Pick any existing remote envelope to verify the candidate sync key
/// against.
///
/// Checks the dedicated [SyncDocumentKind.syncValidationProbe] first so
/// every setup pays the same small-payload decrypt cost regardless of how
/// large the user's settings snapshots are. Falls back to scanning the
/// other kinds in declaration order if no probe is found — that covers
/// users who set up sync before probes were a thing.
Future<SyncDocumentResult?> _findValidationProbe(
  AccountSyncRepository syncRepo,
) async {
  final ordered = [
    SyncDocumentKind.syncValidationProbe,
    ...SyncDocumentKind.values.where(
      (k) => k != SyncDocumentKind.syncValidationProbe,
    ),
  ];
  for (final kind in ordered) {
    final docs = await syncRepo.listDocuments(kind: kind);
    if (docs.isEmpty) continue;
    final result = await syncRepo.fetchDocument(id: docs.first.id);
    if (result != null) return result;
  }
  return null;
}

/// Encrypt a small canary payload under [syncKey] and upload it as a
/// [SyncDocumentKind.syncValidationProbe] document. Future devices fetch
/// this row in [_findValidationProbe] and refuse to persist a mismatching
/// candidate key.
///
/// The probe payload is intentionally tiny and version-tagged so a future
/// migration can recognise it without breaking older clients (they will
/// simply still decrypt-and-succeed, since the marker is opaque to them).
Future<void> _uploadValidationProbe(
  AccountSyncRepository syncRepo,
  String syncKey,
) async {
  final payload = utf8.encode('weblibre:sync-probe:v1');
  final secureData = SecureData(argon2Params: Argon2Params.memoryConstrained());
  final ciphertext = await secureData.encrypt(payload, syncKey);
  await syncRepo.storeDocument(
    kind: SyncDocumentKind.syncValidationProbe,
    schemaVersion: 1,
    contentBlob: base64Encode(ciphertext),
    label: 'sync validation probe',
  );
}

Future<bool> _canDecrypt(String contentBlob, String syncKey) async {
  try {
    final encrypted = base64Decode(contentBlob);
    final secureData = SecureData(
      argon2Params: Argon2Params.memoryConstrained(),
    );
    await secureData.decrypt(encrypted, syncKey);
    return true;
  } catch (_) {
    // Wrong password, corrupted envelope, or unsupported version — in
    // all cases the candidate key is unusable for restoring this
    // backup, so decline to persist it. The user can reset the sync
    // key from the settings UI if their server-side data really is
    // corrupted.
    return false;
  }
}
