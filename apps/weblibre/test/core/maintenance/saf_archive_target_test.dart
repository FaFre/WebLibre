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
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_stream/saf_stream_platform_interface.dart';
import 'package:saf_util/saf_util.dart';
import 'package:saf_util/saf_util_platform_interface.dart';
import 'package:weblibre/core/maintenance/saf_archive_target.dart';

/// An in-memory document tree: uri -> (name, bytes).
class _FakeTree {
  final Map<String, ({String name, int length})> documents = {};
  final deleted = <String>[];

  String uriFor(String name) => 'content://tree/$name';
}

class _FakeSafUtil implements SafUtil {
  _FakeSafUtil(this.tree, {this.writable = true, this.renameThrows = false});

  final _FakeTree tree;
  final bool writable;
  final bool renameThrows;

  @override
  Future<bool> hasPersistedPermission(
    String uri, {
    bool checkRead = true,
    bool checkWrite = false,
  }) async => writable;

  @override
  Future<SafDocumentFile?> stat(String uri, bool? isDir, {bool? throws}) async {
    final entry = tree.documents[uri];
    if (entry == null) return null;
    return SafDocumentFile(
      uri: uri,
      name: entry.name,
      isDir: false,
      length: entry.length,
      lastModified: 0,
    );
  }

  @override
  Future<SafDocumentFile> rename(
    String uri,
    bool isDir,
    String newName,
  ) async {
    if (renameThrows) throw const FileSystemException('rename refused');

    final entry = tree.documents.remove(uri)!;
    final newUri = tree.uriFor(newName);
    tree.documents[newUri] = (name: newName, length: entry.length);
    return SafDocumentFile(
      uri: newUri,
      name: newName,
      isDir: false,
      length: entry.length,
      lastModified: 0,
    );
  }

  @override
  Future<void> delete(String uri, bool isDir) async {
    tree.documents.remove(uri);
    tree.deleted.add(uri);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _FakeSafStream implements SafStream {
  _FakeSafStream(this.tree, {this.shortBy = 0});

  final _FakeTree tree;

  /// Simulates a truncated write, e.g. the volume filling up.
  final int shortBy;

  @override
  Future<SafNewFile> pasteLocalFile(
    String srcPath,
    String treeUri,
    String fileName,
    String mime, {
    bool? overwrite,
    bool? append,
  }) async {
    final length = await File(srcPath).length() - shortBy;
    final uri = tree.uriFor(fileName);
    tree.documents[uri] = (name: fileName, length: length);
    return SafNewFile(Uri.parse(uri), fileName);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  late Directory root;
  late File archive;
  late _FakeTree tree;

  final target = Uri.parse('content://tree');
  const fileName = 'backup_Work_2026-08-19_101500.weblibre';

  setUp(() {
    root = Directory.systemTemp.createTempSync('weblibre_saf');
    archive = File(p.join(root.path, 'archive.weblibre'))
      ..writeAsStringSync('a complete archive');
    tree = _FakeTree();
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  Future<Uri> publish({int shortBy = 0, bool renameThrows = false}) =>
      publishArchiveToSaf(
        archive: archive,
        targetTree: target,
        fileName: fileName,
        safStream: _FakeSafStream(tree, shortBy: shortBy),
        safUtil: _FakeSafUtil(tree, renameThrows: renameThrows),
      );

  group('publishing a backup', () {
    test('the final name is claimed only after the bytes are there', () async {
      final uri = await publish();

      expect(tree.documents[uri.toString()]?.name, fileName);
      expect(
        tree.documents.keys.any((key) => key.endsWith(partialArchiveSuffix)),
        isFalse,
      );
    });

    test('a truncated write never takes the final name', () {
      // The realistic failure — the volume fills mid-copy. A short archive under
      // a `.weblibre` name is a backup that claims to be restorable and is not.
      expect(publish(shortBy: 3), throwsA(isA<BackupPublicationFailure>()));
    });

    test('a truncated write leaves nothing behind', () async {
      await publish(shortBy: 3).then((_) {}, onError: (_) {});

      expect(tree.documents, isEmpty);
      expect(tree.deleted, isNotEmpty);
    });

    test('a failed rename discards the partial too', () async {
      await publish(renameThrows: true).then((_) {}, onError: (_) {});

      expect(tree.documents, isEmpty);
    });

    test('a revoked grant fails before anything is written', () {
      expect(
        publishArchiveToSaf(
          archive: archive,
          targetTree: target,
          fileName: fileName,
          safStream: _FakeSafStream(tree),
          safUtil: _FakeSafUtil(tree, writable: false),
        ),
        throwsA(isA<BackupTargetUnavailable>()),
      );
      expect(tree.documents, isEmpty);
    });

    test('a partial file is not a backup the list would offer', () {
      // The list filters on `.weblibre`, and `.weblibre.partial` does not match —
      // so an interrupted publication cannot be picked for a restore.
      expect('$fileName$partialArchiveSuffix'.endsWith('.weblibre'), isFalse);
    });
  });

  group('checking the target', () {
    test('a live grant is writable', () async {
      expect(
        await safTargetIsWritable(target, safUtil: _FakeSafUtil(tree)),
        isTrue,
      );
    });

    test('a revoked grant is not', () async {
      expect(
        await safTargetIsWritable(
          target,
          safUtil: _FakeSafUtil(tree, writable: false),
        ),
        isFalse,
      );
    });
  });
}
