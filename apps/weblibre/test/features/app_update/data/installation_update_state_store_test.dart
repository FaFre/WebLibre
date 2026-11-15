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

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/app_update/data/store/installation_update_state_store.dart';
import 'package:weblibre/features/app_update/data/store/update_file_system.dart';
import 'package:weblibre/features/app_update/domain/entities/update_preferences.dart';

class FailingWrites extends IoUpdateFileSystem {
  const FailingWrites();

  @override
  Future<void> writeAtomic(String path, List<int> bytes) =>
      Future.error(const FileSystemException('read-only'));
}

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('update_state');
  });

  tearDown(() => dir.delete(recursive: true));

  InstallationUpdateStateStore store([
    UpdateFileSystem fs = const IoUpdateFileSystem(),
  ]) => InstallationUpdateStateStore(stateDir: dir.path, fs: fs);

  test('absent files give the defaults: automatic checks on', () async {
    expect(await store().readPreferences(), UpdatePreferences.defaults);
    expect(await store().readMisc(), UpdateMiscState.empty);
  });

  test('preferences round-trip', () async {
    final off = UpdatePreferences(
      automaticChecks: false,
      recoveryRequired: false,
    );
    await store().writePreferences(off);
    expect(await store().readPreferences(), off);
  });

  test(
    'opted out, then corrupted: off across two restarts without answering',
    () async {
      await store().writePreferences(
        UpdatePreferences(automaticChecks: false, recoveryRequired: false),
      );
      await File(store().prefsPath).writeAsString('{"automaticChecks": tr');

      for (var restart = 0; restart < 2; restart++) {
        final read = await store().readPreferences();
        expect(read.automaticChecks, isFalse);
        expect(read.recoveryRequired, isTrue);
      }
      // The damaged bytes were kept for diagnosis.
      expect(
        dir.listSync().map((e) => e.path).where((p) => p.contains('.damaged.')),
        isNotEmpty,
      );
    },
  );

  test(
    'corrupt and the replacement write fails: the damaged file stays and reads off',
    () async {
      await File(store().prefsPath).writeAsString('not json');
      final read = await store(const FailingWrites()).readPreferences();
      expect(read, UpdatePreferences.recovered);
      expect(await File(store().prefsPath).readAsString(), 'not json');
      expect(
        (await store(const FailingWrites()).readPreferences()).automaticChecks,
        isFalse,
      );
    },
  );

  test('damaged copies are bounded across restarts', () async {
    List<String> copies() => [
      for (final e in dir.listSync())
        if (e.path.contains('update_prefs.json.damaged.')) e.path,
    ];
    // The replacement keeps failing: the same damaged bytes are preserved on
    // every start, but copied once.
    await File(store().prefsPath).writeAsString('not json');
    for (var restart = 0; restart < 5; restart++) {
      await store(const FailingWrites()).readPreferences();
    }
    expect(copies(), hasLength(1));

    // New damage each time: only the newest few are kept.
    for (var i = 0; i < 6; i++) {
      await File(store().prefsPath).writeAsString('not json $i');
      await store(const FailingWrites()).readPreferences();
      // Distinct names: the copies are stamped in milliseconds.
      await Future<void>.delayed(const Duration(milliseconds: 2));
    }
    expect(copies(), hasLength(maxPreservedCopies));
    expect([
      for (final c in copies()) File(c).readAsStringSync(),
    ], unorderedEquals(['not json 3', 'not json 4', 'not json 5']));
  });

  test('a well-formed file of the wrong shape counts as corrupt', () async {
    await File(store().prefsPath).writeAsString('{"automaticChecks": "yes"}');
    expect(await store().readPreferences(), UpdatePreferences.recovered);
  });

  test('a damaged misc file is replaced by an empty one', () async {
    await File(store().miscPath).writeAsString('[]');
    expect(await store().readMisc(), UpdateMiscState.empty);
  });

  test('misc round-trips', () async {
    final now = DateTime.utc(2026, 12, 1, 6);
    await store().updateMisc(
      (m) =>
          m.copyWith(lastAttempt: now, backoffStep: 2, announcedSequence: 44),
    );
    final read = await store().readMisc();
    expect(read.lastAttempt, now);
    expect(read.backoffStep, 2);
    expect(read.announcedSequence, 44);
  });
}
