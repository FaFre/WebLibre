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

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/startup/atomic_json_file.dart';

/// The file operations the updater's stores use, behind one seam so the
/// crash-consistency tests can stop after any step.
abstract interface class UpdateFileSystem {
  Future<List<int>?> readBytes(String path);

  /// Temp file in the same directory, flush, rename over [path].
  Future<void> writeAtomic(String path, List<int> bytes);

  Future<void> delete(String path);

  /// Copies [path] aside for diagnosis and leaves it where it is; returns
  /// the copy's name or null. Unlike [AtomicJsonFile]'s quarantine it never
  /// renames: a damaged file must not turn into an absent one (6.2).
  ///
  /// Bounded: bytes identical to the newest copy are not copied again (a
  /// damaged file that can't be replaced is preserved on every start), and
  /// only the newest [maxPreservedCopies] copies of a file are kept.
  Future<String?> preserve(String path);
}

const maxPreservedCopies = 3;

class IoUpdateFileSystem implements UpdateFileSystem {
  const IoUpdateFileSystem();

  @override
  Future<List<int>?> readBytes(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    return await file.readAsBytes();
  }

  @override
  Future<void> writeAtomic(String path, List<int> bytes) =>
      writeFileAtomically(File(path), bytes);

  @override
  Future<void> delete(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<String?> preserve(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final copies = await _copiesOf(path);
      if (copies.isNotEmpty) {
        final newest = copies.last;
        if (const ListEquality<int>().equals(
          await newest.readAsBytes(),
          await file.readAsBytes(),
        )) {
          return newest.path;
        }
      }
      final target =
          '$path$_copyMarker${clock.now().toUtc().millisecondsSinceEpoch}';
      await file.copy(target);
      final all = [...copies, File(target)];
      for (final old in all.take(all.length - maxPreservedCopies)) {
        try {
          await old.delete();
        } catch (_) {}
      }
      return target;
    } catch (_) {
      return null;
    }
  }

  static const _copyMarker = '.damaged.';

  /// The preserved copies of [path], oldest first.
  static Future<List<File>> _copiesOf(String path) async {
    final prefix = '${p.basename(path)}$_copyMarker';
    final copies = <(int, File)>[];
    await for (final entity in Directory(p.dirname(path)).list()) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);
      if (!name.startsWith(prefix)) continue;
      final stamp = int.tryParse(name.substring(prefix.length));
      if (stamp != null) copies.add((stamp, entity));
    }
    copies.sort((a, b) => a.$1.compareTo(b.$1));
    return [for (final (_, file) in copies) file];
  }
}
