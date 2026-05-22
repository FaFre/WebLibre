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
import 'package:weblibre/features/account/data/repositories/account_sync_repository.dart';

/// Contract for document kinds that can be synced.
///
/// Implementations handle serialization and deserialization of their domain
/// data. Encryption, repository interaction, and UI are handled externally
/// by the reusable [SyncDocumentListSection] widget.
abstract class SyncDocumentService {
  /// The document kind identifier for Supabase storage.
  SyncDocumentKind get kind;

  /// Current schema version for this document kind.
  int get schemaVersion;

  /// Serializes the current app state to plaintext bytes for encryption.
  Future<List<int>> serializeCurrent();

  /// Deserializes decrypted plaintext bytes and applies them to app state.
  Future<void> applyRestored(List<int> plaintext);
}
