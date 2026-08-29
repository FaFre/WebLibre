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
 */
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/features/wallpaper/domain/services/wallpaper_store.dart';

/// A 1x1 red PNG — the smallest thing the import path will accept.
final _pngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGP4z8AAAAMB'
  'AQDJ/pLvAAAAAElFTkSuQmCC',
);

void main() {
  // The import path decodes through dart:ui, which needs a binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory profileDir;
  late Directory sourceDir;
  late WallpaperStore store;

  setUp(() {
    profileDir = Directory.systemTemp.createTempSync('wallpaper_profile');
    sourceDir = Directory.systemTemp.createTempSync('wallpaper_source');
    store = WallpaperStore(profileDir: () => profileDir);
  });

  tearDown(() {
    profileDir.deleteSync(recursive: true);
    sourceDir.deleteSync(recursive: true);
  });

  File writeSource(String name, List<int> bytes) {
    final file = File(p.join(sourceDir.path, name))..writeAsBytesSync(bytes);
    return file;
  }

  group('import', () {
    test('copies the source into the profile under a fresh name', () async {
      final source = writeSource('picture.png', _pngBytes);

      final fileName = await store.import(source.path);

      final stored = store.resolve(fileName);
      expect(stored.existsSync(), isTrue);
      expect(stored.readAsBytesSync(), _pngBytes);
      expect(
        p.dirname(stored.path),
        p.join(profileDir.path, 'files', wallpaperDirName),
      );
      // A name, not a path: the profile directory moves between installs and
      // restores, so anything that carries one of its segments is a broken
      // reference waiting to happen.
      expect(p.basename(fileName), fileName);
    });

    test('leaves an earlier import in place', () async {
      final source = writeSource('picture.png', _pngBytes);

      final first = await store.import(source.path);
      final second = await store.import(source.path);

      // Distinct names are what evicts the replaced picture from Flutter's
      // image cache; identical bytes at one path would keep showing the old
      // one.
      expect(first, isNot(second));
      expect(store.resolve(first).existsSync(), isTrue);
      expect(store.resolve(second).existsSync(), isTrue);
    });

    test('refuses a file that is not an image', () async {
      final source = writeSource('notes.txt', utf8.encode('not an image'));

      await expectLater(
        store.import(source.path),
        throwsA(isA<WallpaperImportException>()),
      );
      expect(store.directory.existsSync(), isFalse);
    });

    test('refuses a source that does not exist', () async {
      await expectLater(
        store.import(p.join(sourceDir.path, 'missing.png')),
        throwsA(isA<WallpaperImportException>()),
      );
    });
  });

  group('deleteUnreferenced', () {
    test('keeps referenced wallpapers and removes the rest', () async {
      final source = writeSource('picture.png', _pngBytes);

      final kept = await store.import(source.path);
      final dropped = await store.import(source.path);

      expect(await store.deleteUnreferenced({kept}), 1);

      expect(store.resolve(kept).existsSync(), isTrue);
      expect(store.resolve(dropped).existsSync(), isFalse);
    });

    test('collects the remains of an interrupted import', () async {
      final source = writeSource('picture.png', _pngBytes);
      final kept = await store.import(source.path);

      final leftover = File('${store.resolve('crashed.png').path}.part')
        ..writeAsBytesSync(_pngBytes);

      expect(await store.deleteUnreferenced({kept}), 1);
      expect(leftover.existsSync(), isFalse);
    });

    test('is a no-op before anything has been imported', () async {
      expect(await store.deleteUnreferenced({'anything.png'}), 0);
    });
  });

  group('delete', () {
    test('removes the named wallpaper', () async {
      final source = writeSource('picture.png', _pngBytes);
      final fileName = await store.import(source.path);

      await store.delete(fileName);

      expect(store.resolve(fileName).existsSync(), isFalse);
    });

    test('ignores a name that would escape the wallpaper directory', () async {
      final outsider = File(p.join(profileDir.path, 'user.db'))
        ..writeAsStringSync('not a wallpaper');

      await store.delete(p.join('..', '..', 'user.db'));

      expect(outsider.existsSync(), isTrue);
    });

    test('tolerates a wallpaper that is already gone', () async {
      await expectLater(store.delete('missing.png'), completes);
    });
  });
}
