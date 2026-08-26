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
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/maintenance/plaintext_cleanup.dart';

void main() {
  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('weblibre_shred');
  });

  tearDown(() {
    if (root.existsSync()) {
      Process.runSync('chmod', ['-R', 'u+w', root.path]);
      root.deleteSync(recursive: true);
    }
  });

  Directory payload() {
    final dir = Directory(p.join(root.path, 'secureStorage'))
      ..createSync(recursive: true);
    File(
      p.join(dir.path, 'secure_storage.json'),
    ).writeAsStringSync('{"account_auth_data@p:abc":"refresh-token"}');
    return dir;
  }

  test('the ordinary case is just a delete', () async {
    final dir = payload();

    await shredDirectory(dir, 'test payload');

    expect(dir.existsSync(), isFalse);
  });

  test('a missing directory is nothing to do', () async {
    await shredDirectory(Directory(p.join(root.path, 'gone')), 'test payload');
  });

  test('a directory that will not delete does not keep its plaintext', () async {
    // Every one of these call sites is past the point of no return, so none of
    // them may throw. Logging and moving on left a readable credential inside
    // the live profile directory forever — and in every later backup of it.
    final dir = payload();
    final file = File(p.join(dir.path, 'secure_storage.json'));

    final chmod = await Process.run('chmod', ['a-w', dir.path]);
    expect(chmod.exitCode, 0, reason: 'test needs a POSIX chmod');

    await shredDirectory(dir, 'test payload');

    expect(file.existsSync(), isTrue, reason: 'the delete really did fail');
    expect(
      file.readAsStringSync(),
      isEmpty,
      reason: 'what survives is not a working credential',
    );
  }, skip: Platform.isWindows ? 'needs POSIX permissions' : null);
}
