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
import 'dart:typed_data';

import 'package:sqlite3/common.dart';
import 'package:weblibre/utils/url_canonical.dart';
import 'package:xxh3/xxh3.dart';

/// Bytes 0x1F (Unit Separator) between hashed parts. Prevents collisions
/// where `(a, b)` and `(ab, '')` would otherwise hash to the same value.
const _hashSeparator = 0x1F;

/// xxh3-64 over the trigger-relevant content fields.
///
/// Inputs may be any nullable mix of TEXT columns. The hash is stable for
/// the same content + ordering, and `IS NOT` comparison on the resulting
/// INTEGER is enough to gate downstream FTS / fan-out triggers.
int? _contentHash(List<Object?> args) {
  if (args.every((a) => a == null)) return null;
  final builder = BytesBuilder(copy: false);
  for (final part in args) {
    if (part is String) {
      builder.add(utf8.encode(part));
    }
    builder.addByte(_hashSeparator);
  }
  // xxh3 returns an unsigned 64-bit value, but Dart ints on 64-bit platforms
  // are signed 64-bit. The bit pattern round-trips fine through SQLite as
  // INTEGER; we just lose the unsigned interpretation, which doesn't matter
  // for `IS NOT` comparisons.
  return xxh3(builder.toBytes());
}

String? _urlCanonical(List<Object?> args) {
  final url = args.first as String?;
  if (url == null) return null;
  return canonicalizeUrl(url)?.canonical;
}

String? _urlHost(List<Object?> args) {
  final url = args.first as String?;
  if (url == null) return null;
  return canonicalizeUrl(url)?.host;
}

String? _urlPath(List<Object?> args) {
  final url = args.first as String?;
  if (url == null) return null;
  return canonicalizeUrl(url)?.path;
}

/// Boolean-as-INTEGER (0/1) for use in trigger `WHEN` clauses.
int _urlIndexable(List<Object?> args) {
  final url = args.first as String?;
  if (url == null) return 0;
  return isUrlIndexable(url) ? 1 : 0;
}

void registerUrlFunctions(CommonDatabase database) {
  database.createFunction(
    functionName: 'url_canonical',
    argumentCount: const AllowedArgumentCount(1),
    deterministic: true,
    directOnly: false,
    function: _urlCanonical,
  );
  database.createFunction(
    functionName: 'url_host',
    argumentCount: const AllowedArgumentCount(1),
    deterministic: true,
    directOnly: false,
    function: _urlHost,
  );
  database.createFunction(
    functionName: 'url_path',
    argumentCount: const AllowedArgumentCount(1),
    deterministic: true,
    directOnly: false,
    function: _urlPath,
  );
  database.createFunction(
    functionName: 'url_indexable',
    argumentCount: const AllowedArgumentCount(1),
    deterministic: true,
    directOnly: false,
    function: _urlIndexable,
  );
  // 3-arg form covers the (title, extracted_plain, full_plain) trigger guard.
  // Marked deterministic so generated columns can use it.
  database.createFunction(
    functionName: 'generate_content_hash',
    argumentCount: const AllowedArgumentCount(3),
    deterministic: true,
    directOnly: false,
    function: _contentHash,
  );
}
