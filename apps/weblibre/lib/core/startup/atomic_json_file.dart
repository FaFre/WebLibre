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
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:weblibre/core/logger.dart';

/// Result of a tolerant read of a global JSON record.
sealed class AtomicJsonRead {
  const AtomicJsonRead();
}

/// The file does not exist. Callers substitute their defaults.
class AtomicJsonAbsent extends AtomicJsonRead {
  const AtomicJsonAbsent();
}

class AtomicJsonPresent extends AtomicJsonRead {
  const AtomicJsonPresent(this.json);

  final Map<String, Object?> json;
}

/// The file exists but is unreadable or is not a JSON object. The original
/// bytes are preserved under [quarantinePath] when one could be created;
/// callers must not treat this as "absent" for anything safety relevant.
class AtomicJsonCorrupt extends AtomicJsonRead {
  const AtomicJsonCorrupt(this.reason, this.quarantinePath);

  final String reason;
  final String? quarantinePath;
}

/// Read/write helper for the small global records that live outside any
/// profile: `startup_config.json`, restart requests, intent queues, and
/// maintenance journals.
///
/// Writes go to a temp file in the *same* directory, are flushed, and are then
/// renamed over the target, so a reader never observes a torn file. Renaming
/// within a directory is atomic on the filesystems Android uses.
///
/// Dart cannot fsync directory metadata, so a power loss immediately after the
/// rename can still lose the *name* while keeping both old and new content
/// intact. That is why destructive maintenance additionally reconciles from
/// filesystem evidence rather than trusting a journal phase alone.
class AtomicJsonFile {
  const AtomicJsonFile(this.file);

  final File file;

  /// Reads and parses the file. Never throws; structural problems are reported
  /// as [AtomicJsonCorrupt] and the offending bytes are moved aside so the next
  /// write starts clean without destroying evidence.
  Future<AtomicJsonRead> read({bool quarantineCorrupt = true}) async {
    if (!await file.exists()) {
      return const AtomicJsonAbsent();
    }

    String contents;
    try {
      contents = await file.readAsString();
    } catch (e, s) {
      logger.e('Could not read ${file.path}', error: e, stackTrace: s);
      return AtomicJsonCorrupt(
        'unreadable: $e',
        quarantineCorrupt ? await _quarantine() : null,
      );
    }

    if (contents.trim().isEmpty) {
      return AtomicJsonCorrupt(
        'empty',
        quarantineCorrupt ? await _quarantine() : null,
      );
    }

    Object? decoded;
    try {
      decoded = jsonDecode(contents);
    } catch (e) {
      logger.w('Could not parse ${file.path}: $e');
      return AtomicJsonCorrupt(
        'malformed json: $e',
        quarantineCorrupt ? await _quarantine() : null,
      );
    }

    if (decoded is! Map) {
      return AtomicJsonCorrupt(
        'root is ${decoded.runtimeType}, expected object',
        quarantineCorrupt ? await _quarantine() : null,
      );
    }

    return AtomicJsonPresent(
      decoded.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  Future<void> write(Map<String, Object?> json) async {
    await file.parent.create(recursive: true);

    final temp = File('${file.path}.tmp');
    final handle = await temp.open(mode: FileMode.writeOnly);
    try {
      await handle.truncate(0);
      await handle.writeString(jsonEncode(json));
      await handle.flush();
    } finally {
      await handle.close();
    }

    await temp.rename(file.path);
  }

  Future<void> delete() async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Moves a damaged file aside so it can still be inspected. Returns the new
  /// path, or `null` when even that failed.
  Future<String?> _quarantine() async {
    final stamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    final target = p.join(
      file.parent.path,
      '${p.basename(file.path)}.corrupt.$stamp',
    );
    try {
      await file.rename(target);
      logger.w('Quarantined corrupt ${file.path} to $target');
      return target;
    } catch (e, s) {
      logger.e(
        'Could not quarantine corrupt ${file.path}',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }
}
