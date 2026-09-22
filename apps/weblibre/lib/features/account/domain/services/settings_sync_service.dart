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
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/features/keyboard_shortcuts/domain/repositories/keyboard_shortcut_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/tor_settings.dart';

part 'settings_sync_service.g.dart';

/// Bumped to 2 when [TabBarPositionSetting.auto] was introduced.
///
/// The generated settings decoder throws on an enum string it does not know,
/// so a build that predates a new value would otherwise accept the envelope
/// (its own version check only rejects *higher* versions) and then fail deep
/// inside `fromJson`. Raising the version makes an older build refuse the
/// document up front, with a message that says why.
///
/// Bump this whenever a new value is added to an enum that settings sync
/// carries.
const _schemaVersion = 4;

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
    final (general, engine, tor, gestures) = await (
      ref.read(generalSettingsRepositoryProvider.notifier).fetchSettings(),
      ref.read(engineSettingsRepositoryProvider.notifier).fetchSettings(),
      ref.read(torSettingsRepositoryProvider.notifier).fetchSettings(),
      ref.read(gestureSettingsRepositoryProvider.notifier).fetchSettings(),
    ).wait;

    final envelope = SettingsSyncEnvelope(
      schemaVersion: _schemaVersion,
      exportedAt: DateTime.now().toUtc().toIso8601String(),
      payload: SettingsSyncPayload(
        general: general,
        engine: engine,
        tor: tor,
        gestures: gestures,
        keyboardShortcuts: ref.read(keyboardShortcutSettingsRepositoryProvider),
      ),
    );

    return utf8.encode(jsonEncode(envelope.toJson()));
  }

  @override
  Future<void> applyRestored(List<int> plaintext) async {
    final json = jsonDecode(utf8.decode(plaintext)) as Map<String, dynamic>;

    // Checked on the raw JSON, before the payload is decoded: a newer
    // snapshot can hold enum values this build does not know (a new
    // BrowserAction, say), and decoding those would throw a decode error
    // instead of this one.
    final schemaVersion = switch (json['schema_version']) {
      final num version => version.toInt(),
      _ => throw const FormatException('Settings snapshot has no schema'),
    };
    if (schemaVersion > _schemaVersion) {
      throw Exception(
        'Unsupported settings schema version: $schemaVersion '
        '(this app supports up to $_schemaVersion)',
      );
    }

    final envelope = SettingsSyncEnvelope.fromJson(json);

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
    if (payload.gestures != null) {
      await ref
          .read(gestureSettingsRepositoryProvider.notifier)
          .updateSettings((_) => payload.gestures!);
    }
    if (payload.keyboardShortcuts != null) {
      ref
          .read(keyboardShortcutSettingsRepositoryProvider.notifier)
          .replace(payload.keyboardShortcuts!);
    }
  }
}
