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
/// Tolerant readers for the startup records that cross the native boundary.
///
/// These records are written by Kotlin and read by Dart (and the reverse), so
/// a field that is absent, null, or of the wrong type has to degrade to "not
/// set" rather than throw — a malformed record must never be what stops the
/// app from starting. Kotlin's half of this contract lives in
/// `startup/JsonExtensions.kt`; keep the two readers behaving the same.
library;

import 'package:json_annotation/json_annotation.dart';

/// [fromJson] (a generated `checked: true` reader) applied to [json], or null
/// when it rejects a required field ([requiredString] and its siblings).
T? tryCheckedFromJson<T>(
  Map<String, Object?> json,
  T Function(Map<String, dynamic> json) fromJson,
) {
  try {
    return fromJson(json);
  } on CheckedFromJsonException {
    return null;
  }
}

/// The records of a JSON list that [tryFromJson] can read; any other entry
/// is dropped.
List<T> recordsFromJson<T>(
  Object? value,
  T? Function(Map<String, Object?> json) tryFromJson,
) {
  if (value is! List) return const [];
  return [
    for (final entry in value)
      if (entry is Map)
        ?tryFromJson(
          entry.map((key, value) => MapEntry(key.toString(), value)),
        ),
  ];
}

/// A non-empty string, or null for anything else.
String? stringOrNull(Object? value) =>
    value is String && value.isNotEmpty ? value : null;

/// A string, or the empty string for anything else.
///
/// Mirrors Kotlin's `stringOrEmpty`.
String stringOrEmpty(Object? value) => value is String ? value : '';

/// An int, or [fallback] for anything else — including a numeric *string*,
/// which is the shape a hand-edited or foreign-written record arrives in.
///
/// Mirrors Kotlin's `intOr`.
int intOr(Object? value, int fallback) => value is int ? value : fallback;

/// A bool, or [fallback] for anything else. Mirrors Kotlin's `booleanOr`.
bool boolOr(Object? value, bool fallback) => value is bool ? value : fallback;

/// A bool, or null for anything else.
bool? boolOrNull(Object? value) => value is bool ? value : null;

/// An ISO-8601 timestamp normalised to UTC, or null if unparseable.
DateTime? dateTimeOrNull(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toUtc();
}

/// Like [dateTimeOrNull], with the epoch for anything unparseable.
DateTime dateTimeOrEpoch(Object? value) =>
    dateTimeOrNull(value) ?? DateTime.utc(1970);

/// For a field without which the whole record is unusable: a non-empty
/// string, or a [FormatException]. A generated `fromJson` in checked mode
/// turns that into `CheckedFromJsonException`, which [tryCheckedFromJson]
/// maps to null.
String requiredString(Object? value) => value is String && value.isNotEmpty
    ? value
    : throw const FormatException('not a non-empty string');

/// Like [requiredString], for an int.
int requiredInt(Object? value) =>
    value is int ? value : throw const FormatException('not an integer');

/// Like [requiredString], for a timestamp.
DateTime requiredDateTime(Object? value) =>
    dateTimeOrNull(value) ?? (throw const FormatException('not a timestamp'));

/// How every record writes a timestamp: ISO-8601 in UTC.
String utcIso(DateTime value) => value.toUtc().toIso8601String();

String? utcIsoOrNull(DateTime? value) => value?.toUtc().toIso8601String();

/// The string elements of a list, ignoring any other members.
List<String> stringList(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable(value.whereType<String>());
}

/// The value in [this] whose [Enum.name] is [name], or null.
///
/// Persisted enum ids are the member names verbatim, so the name *is* the id
/// and no parallel `id` field has to be kept in step with it. Tolerant like the
/// readers above: a value written by a newer build reads back as null rather
/// than throwing, which is what lets an unknown task or phase be skipped
/// instead of taking the whole record down.
extension EnumTryByName<T extends Enum> on List<T> {
  T? tryByName(Object? name) {
    if (name is! String) return null;
    for (final value in this) {
      if (value.name == name) return value;
    }
    return null;
  }
}
