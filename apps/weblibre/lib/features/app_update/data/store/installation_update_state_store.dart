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

import 'package:path/path.dart' as p;
import 'package:synchronized/synchronized.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/startup/atomic_json_file.dart';
import 'package:weblibre/features/app_update/data/store/update_file_system.dart';
import 'package:weblibre/features/app_update/domain/entities/update_preferences.dart';
import 'package:weblibre/features/app_update/domain/repositories/update_state_repository.dart';

/// `update_prefs.json` and `update_misc.json` (plan 6, 6.2), installation-wide
/// under `noBackupFilesDir/app_update/`, outside every profile.
///
/// **Corruption is not absence, and must not turn into absence.** A damaged
/// preferences file is overwritten at once with "automatic checks off,
/// recovery required", so every later start sees "off" until the user
/// answers; no path leads from a damaged file back to the default. If even
/// that write fails, the damaged file stays and reads as damaged again.
///
/// Like `StartupConfigStore`, the lock belongs to the path, not the instance.
class InstallationUpdateStateStore implements UpdateStateRepository {
  InstallationUpdateStateStore({
    required String stateDir,
    this.fs = const IoUpdateFileSystem(),
  }) : prefsPath = p.join(stateDir, 'update_prefs.json'),
       miscPath = p.join(stateDir, 'update_misc.json');

  final String prefsPath;
  final String miscPath;
  final UpdateFileSystem fs;

  static final _locks = <String, Lock>{};

  Lock get _lock => _locks.putIfAbsent(prefsPath, Lock.new);

  @override
  Future<UpdatePreferences> readPreferences() => _lock.synchronized(() async {
    final Map<String, Object?>? json;
    switch (await _readJson(prefsPath)) {
      case AtomicJsonAbsent():
        return UpdatePreferences.defaults;
      case AtomicJsonCorrupt():
        json = null;
      case AtomicJsonPresent(json: final value):
        json = value;
    }

    final parsed = json == null ? null : UpdatePreferences.tryFromJson(json);
    if (parsed != null) return parsed;

    // Damaged: keep the bytes for diagnosis, then make "off" durable before
    // doing anything else.
    await fs.preserve(prefsPath);
    try {
      await _writeJson(prefsPath, UpdatePreferences.recovered.toJson());
    } catch (e, s) {
      logger.e(
        'Could not replace damaged update_prefs.json',
        error: e,
        stackTrace: s,
      );
    }
    return UpdatePreferences.recovered;
  });

  @override
  Future<UpdatePreferences> writePreferences(UpdatePreferences preferences) =>
      _lock.synchronized(() async {
        await _writeJson(prefsPath, preferences.toJson());
        return preferences;
      });

  @override
  Future<UpdateMiscState> readMisc() => _lock.synchronized(_readMiscLocked);

  Future<UpdateMiscState> _readMiscLocked() async {
    switch (await _readJson(miscPath)) {
      case AtomicJsonAbsent():
        return UpdateMiscState.empty;
      case AtomicJsonPresent(:final json):
        final parsed = UpdateMiscState.tryFromJson(json);
        if (parsed != null) return parsed;
      case AtomicJsonCorrupt():
        break;
    }
    // Nothing depends on it: backoff resets, an announcement may repeat once.
    try {
      await _writeJson(miscPath, UpdateMiscState.empty.toJson());
    } catch (_) {}
    return UpdateMiscState.empty;
  }

  @override
  Future<UpdateMiscState> updateMisc(
    UpdateMiscState Function(UpdateMiscState current) update,
  ) => _lock.synchronized(() async {
    final current = await _readMiscLocked();
    final next = update(current);
    if (next != current) await _writeJson(miscPath, next.toJson());
    return next;
  });

  /// Through [fs] rather than [AtomicJsonFile.read], which has no file
  /// system seam: the store's crash and write-failure tests inject one.
  Future<AtomicJsonRead> _readJson(String path) async {
    final List<int>? bytes;
    try {
      bytes = await fs.readBytes(path);
    } catch (e) {
      return AtomicJsonCorrupt('unreadable: $e', null);
    }
    if (bytes == null) return const AtomicJsonAbsent();
    final String contents;
    try {
      contents = utf8.decode(bytes);
    } on FormatException catch (e) {
      return AtomicJsonCorrupt('not UTF-8: $e', null);
    }
    return AtomicJsonFile.parse(contents);
  }

  Future<void> _writeJson(String path, Map<String, Object?> json) =>
      fs.writeAtomic(path, utf8.encode(jsonEncode(json)));
}
