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
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:secure_archive/secure_archive.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/account/data/repositories/account_sync_repository.dart';
import 'package:weblibre/features/account/domain/services/sync_document_service.dart';
import 'package:weblibre/features/account/presentation/widgets/sync_document_dialogs.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_content_card.dart';
import 'package:weblibre/utils/ui_helper.dart';

class SyncDocumentListSection extends HookWidget {
  const SyncDocumentListSection({
    super.key,
    required this.service,
    required this.syncRepo,
    required this.syncKey,
    this.sourceDeviceId,
    this.sourceAppVersion,
    this.embedded = false,
  });

  final SyncDocumentService service;
  final AccountSyncRepository syncRepo;
  final String syncKey;
  final String? sourceDeviceId;
  final String? sourceAppVersion;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final documents = useState<List<SyncDocumentMetadata>?>(null);
    final loading = useState(true);
    final busy = useState(false);

    final secureData = useMemoized(
      () => SecureData(argon2Params: Argon2Params.memoryConstrained()),
    );

    Future<void> refresh() async {
      try {
        final docs = await syncRepo.listDocuments(kind: service.kind);

        if (!context.mounted) return;

        documents.value = docs;
      } catch (error, stackTrace) {
        logger.e(
          'Failed to list ${service.kind.name} sync documents',
          error: error,
          stackTrace: stackTrace,
        );
        if (context.mounted) {
          showErrorMessage(context, 'Failed to load snapshots: $error');
        }
      } finally {
        if (context.mounted) {
          loading.value = false;
        }
      }
    }

    useEffect(() {
      unawaited(refresh());
      return null;
    }, const []);

    Future<void> storeCurrent() async {
      final labelResult = await showStoreLabelDialog(context);
      if (labelResult == null) return;

      busy.value = true;
      try {
        final plaintext = await service.serializeCurrent();
        final encrypted = await secureData.encrypt(
          plaintext,
          syncKey,
          compress: true,
        );
        final blob = base64Encode(encrypted);
        final label = labelResult.isEmpty ? null : labelResult;

        await syncRepo.storeDocument(
          kind: service.kind,
          schemaVersion: service.schemaVersion,
          contentBlob: blob,
          label: label,
          sourceDeviceId: sourceDeviceId,
          sourceAppVersion: sourceAppVersion,
        );

        if (context.mounted) {
          showInfoMessage(context, '${service.kind.displayName} stored');
        }
        await refresh();
      } catch (error, stackTrace) {
        logger.e(
          'Failed to store ${service.kind.name} sync document',
          error: error,
          stackTrace: stackTrace,
        );
        if (context.mounted) {
          showErrorMessage(context, 'Failed to store: $error');
        }
      } finally {
        if (context.mounted) {
          busy.value = false;
        }
      }
    }

    Future<void> restore(SyncDocumentMetadata metadata) async {
      final confirmed = await showRestoreConfirmation(
        context,
        metadata: metadata,
      );
      if (confirmed != true) return;

      busy.value = true;
      try {
        final result = await syncRepo.fetchDocument(id: metadata.id);
        if (result == null) {
          if (context.mounted) {
            showErrorMessage(context, 'Snapshot not found');
          }
          return;
        }

        final encrypted = base64Decode(result.contentBlob);
        final plaintext = await secureData.decrypt(encrypted, syncKey);
        await service.applyRestored(plaintext);

        if (context.mounted) {
          showInfoMessage(context, '${service.kind.displayName} restored');
        }
      } catch (error, stackTrace) {
        logger.e(
          'Failed to restore ${service.kind.name} sync document ${metadata.id}',
          error: error,
          stackTrace: stackTrace,
        );
        if (context.mounted) {
          if (_isDecryptionFailure(error)) {
            showErrorMessage(
              context,
              'Decryption failed — wrong password or data corrupted. '
              'Try resetting your sync key.',
            );
          } else {
            showErrorMessage(context, 'Failed to restore: $error');
          }
        }
      } finally {
        if (context.mounted) {
          busy.value = false;
        }
      }
    }

    Future<void> editLabel(SyncDocumentMetadata metadata) async {
      final newLabel = await showEditLabelDialog(
        context,
        currentLabel: metadata.label,
      );
      if (newLabel == null) return;

      try {
        await syncRepo.updateLabel(
          id: metadata.id,
          label: newLabel.isEmpty ? null : newLabel,
        );
        await refresh();
      } catch (error, stackTrace) {
        logger.e(
          'Failed to update label for sync document ${metadata.id}',
          error: error,
          stackTrace: stackTrace,
        );
        if (context.mounted) {
          showErrorMessage(context, 'Failed to update label: $error');
        }
      }
    }

    Future<void> delete(SyncDocumentMetadata metadata) async {
      final confirmed = await showDeleteConfirmation(
        context,
        metadata: metadata,
      );
      if (confirmed != true) return;

      try {
        await syncRepo.deleteDocument(id: metadata.id);
        if (context.mounted) {
          showInfoMessage(context, 'Snapshot deleted');
        }
        await refresh();
      } catch (error, stackTrace) {
        logger.e(
          'Failed to delete sync document ${metadata.id}',
          error: error,
          stackTrace: stackTrace,
        );
        if (context.mounted) {
          showErrorMessage(context, 'Failed to delete: $error');
        }
      }
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            '${service.kind.displayName} Snapshots',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        ListTile(
          leading: busy.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.cloud_upload_outlined),
          title: const Text('Store Current'),
          subtitle: Text(
            'Encrypt and upload current ${service.kind.displayName.toLowerCase()}',
          ),
          enabled: !busy.value,
          onTap: storeCurrent,
        ),
        if (loading.value)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (documents.value == null || documents.value!.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Text(
              'No snapshots stored yet',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else ...[
          const Divider(height: 1),
          for (final doc in documents.value!)
            _DocumentTile(
              metadata: doc,
              busy: busy.value,
              onRestore: () => restore(doc),
              onEditLabel: () => editLabel(doc),
              onDelete: () => delete(doc),
            ),
        ],
      ],
    );

    return SettingsContentCard(embedded: embedded, child: content);
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.metadata,
    required this.busy,
    required this.onRestore,
    required this.onEditLabel,
    required this.onDelete,
  });

  final SyncDocumentMetadata metadata;
  final bool busy;
  final VoidCallback onRestore;
  final VoidCallback onEditLabel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final title = metadata.label?.isNotEmpty == true
        ? metadata.label!
        : 'Untitled';
    final subtitle = StringBuffer(formatDateTime(metadata.updatedAt));
    if (metadata.sourceDeviceId != null) {
      subtitle.write(' · ${metadata.sourceDeviceId}');
    }

    return ListTile(
      leading: const Icon(Icons.description_outlined),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        subtitle.toString(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: MenuAnchor(
        builder: (context, controller, _) => IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: busy
              ? null
              : () =>
                    controller.isOpen ? controller.close() : controller.open(),
        ),
        menuChildren: [
          MenuItemButton(
            leadingIcon: const Icon(Icons.cloud_download_outlined),
            onPressed: onRestore,
            child: const Text('Restore'),
          ),
          MenuItemButton(
            leadingIcon: const Icon(Icons.edit_outlined),
            onPressed: onEditLabel,
            child: const Text('Edit Label'),
          ),
          MenuItemButton(
            leadingIcon: Icon(
              Icons.delete_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            onPressed: onDelete,
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Canonical secure_archive error message fragments that all map to
/// "the candidate key cannot open this blob" (wrong password, MAC failure,
/// corrupted ciphertext). Sourced from `secure_archive/lib/src/data/`:
///
/// - "wrong password or corrupted data" — from `secure_data.dart` (thrown
///   on `SecretBoxAuthenticationError` from chacha20-poly1305 MAC check).
/// - "Could not validate backup integrity" — from the archive layer.
/// - "Corrupt output" — from the streaming gzip decoder.
///
/// If `secure_archive` upstream switches to typed exceptions, prefer
/// catching the type and delete these strings.
const _secureArchiveDecryptionFailureFragments = <String>{
  'wrong password or corrupted data',
  'Could not validate backup integrity',
  'Corrupt output',
};

/// True when [error] indicates the candidate sync key could not open the
/// snapshot — either it's wrong, the envelope is corrupted, or the format
/// version isn't recognised. Used to present a key/integrity problem
/// instead of a generic failure.
///
/// `FormatException` covers header-level failures (unsupported version,
/// bad framing), which `secure_archive` raises before any crypto runs.
/// Other `Exception` instances are sniffed by message contents — see
/// [_secureArchiveDecryptionFailureFragments] for the contract.
bool _isDecryptionFailure(Object error) {
  if (error is FormatException) return true;
  if (error is Exception) {
    final message = error.toString();
    return _secureArchiveDecryptionFailureFragments.any(message.contains);
  }
  return false;
}
