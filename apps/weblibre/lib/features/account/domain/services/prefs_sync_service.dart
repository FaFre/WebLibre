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

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/features/account/data/repositories/account_sync_repository.dart';
import 'package:weblibre/features/account/domain/services/prefs_js_reader.dart';
import 'package:weblibre/features/account/domain/services/sync_document_service.dart';
import 'package:weblibre/features/account/domain/utils/user_js_parser.dart';
import 'package:weblibre/features/account/domain/utils/user_js_serializer.dart';

part 'prefs_sync_service.g.dart';

const _schemaVersion = 1;

@Riverpod(keepAlive: true)
class PrefsSyncService extends _$PrefsSyncService
    implements SyncDocumentService {
  final GeckoPrefService _prefService = GeckoPrefService();
  final PrefsJsReader _prefsReader = PrefsJsReader(
    selectedProfileDir: filesystem.selectedProfileDir,
  );

  @override
  void build() {}

  @override
  SyncDocumentKind get kind => SyncDocumentKind.geckoUserJs;

  @override
  int get schemaVersion => _schemaVersion;

  @override
  Future<List<int>> serializeCurrent() async {
    final userPrefs = await _prefsReader.readUserPrefs();

    final text = serializeUserJs(
      userPrefs: userPrefs,
      schemaVersion: _schemaVersion,
    );

    return utf8.encode(text);
  }

  @override
  Future<void> applyRestored(List<int> plaintext) async {
    final text = utf8.decode(plaintext);
    final parsed = parseUserJs(text);

    if (parsed.schemaVersion != null &&
        parsed.schemaVersion! > _schemaVersion) {
      throw Exception(
        'Unsupported prefs schema version: ${parsed.schemaVersion} '
        '(this app supports up to $_schemaVersion)',
      );
    }

    final remotePrefs = parsed.prefs;

    // Find local user-set prefs whose exported form would have been preserved,
    // so we can reset those absent from the remote snapshot.
    final localPrefs = await _prefsReader.readUserPrefs();
    final syncableLocalKeys = localPrefs.entries
        .where((e) => isSyncablePrefValue(e.value))
        .map((e) => e.key)
        .toSet();

    final prefsToReset = syncableLocalKeys
        .difference(remotePrefs.keys.toSet())
        .toList();

    if (prefsToReset.isNotEmpty) {
      await _prefService.resetPrefs(prefsToReset);
    }

    if (remotePrefs.isNotEmpty) {
      await _prefService.applyPrefs(remotePrefs);
    }
  }
}
