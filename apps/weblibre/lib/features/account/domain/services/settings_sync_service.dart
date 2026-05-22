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

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/account/data/models/settings_sync_envelope.dart';
import 'package:weblibre/features/account/data/repositories/account_sync_repository.dart';
import 'package:weblibre/features/account/domain/services/sync_document_service.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/tor_settings.dart';

part 'settings_sync_service.g.dart';

const _schemaVersion = 1;

@Riverpod(keepAlive: true)
class SettingsSyncService extends _$SettingsSyncService
    implements SyncDocumentService {
  @override
  void build() {}

  @override
  SyncDocumentKind get kind => SyncDocumentKind.weblibreSettings;

  @override
  int get schemaVersion => _schemaVersion;

  @override
  Future<List<int>> serializeCurrent() async {
    final (general, engine, tor) = await (
      ref.read(generalSettingsRepositoryProvider.notifier).fetchSettings(),
      ref.read(engineSettingsRepositoryProvider.notifier).fetchSettings(),
      ref.read(torSettingsRepositoryProvider.notifier).fetchSettings(),
    ).wait;

    final envelope = SettingsSyncEnvelope(
      schemaVersion: _schemaVersion,
      exportedAt: DateTime.now().toUtc().toIso8601String(),
      payload: SettingsSyncPayload(general: general, engine: engine, tor: tor),
    );

    return utf8.encode(jsonEncode(envelope.toJson()));
  }

  @override
  Future<void> applyRestored(List<int> plaintext) async {
    final json = jsonDecode(utf8.decode(plaintext)) as Map<String, dynamic>;
    final envelope = SettingsSyncEnvelope.fromJson(json);

    if (envelope.schemaVersion > _schemaVersion) {
      throw Exception(
        'Unsupported settings schema version: ${envelope.schemaVersion} '
        '(this app supports up to $_schemaVersion)',
      );
    }

    final payload = envelope.payload;

    if (payload.general != null) {
      await ref
          .read(generalSettingsRepositoryProvider.notifier)
          .updateSettings((_) => payload.general!);
    }
    if (payload.engine != null) {
      await ref
          .read(engineSettingsRepositoryProvider.notifier)
          .updateSettings((_) => payload.engine!);
    }
    if (payload.tor != null) {
      await ref
          .read(torSettingsRepositoryProvider.notifier)
          .updateSettings((_) => payload.tor!);
    }
  }
}
