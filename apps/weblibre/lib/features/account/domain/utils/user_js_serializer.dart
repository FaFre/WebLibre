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
/// Unsyncable URL-style pref value prefixes (inspired by Firefox Sync).
const unsyncablePrefPrefixes = ['moz-extension:', 'blob:', 'data:', 'file:'];

/// Returns true if a persisted Gecko pref value is syncable (supported scalar
/// type and not an unsyncable URL-style string value).
bool isSyncablePrefValue(Object value) {
  if (value is bool || value is int) return true;
  if (value is String) {
    return !unsyncablePrefPrefixes.any(value.startsWith);
  }
  // Unsupported type (e.g. double, list)
  return false;
}

/// Serializes persisted Gecko user prefs into canonical `user.js` text.
///
/// [userPrefs] is the map of user-set prefs parsed from the active Gecko
/// profile's `prefs.js` file.
///
/// String-valued prefs starting with unsyncable URL prefixes are excluded.
String serializeUserJs({
  required Map<String, Object> userPrefs,
  required int schemaVersion,
  String? exportedAt,
}) {
  final buffer = StringBuffer();
  buffer.writeln('// WebLibre Gecko prefs snapshot');
  buffer.writeln('// schema_version=$schemaVersion');
  buffer.writeln(
    '// exported_at=${exportedAt ?? DateTime.now().toUtc().toIso8601String()}',
  );

  final syncable =
      userPrefs.entries.where((e) => isSyncablePrefValue(e.value)).toList()
        ..sort((a, b) => a.key.compareTo(b.key));

  for (final entry in syncable) {
    final literal = _toLiteral(entry.value);
    if (literal == null) continue;
    final escapedName = _escapeString(entry.key);
    buffer.writeln('user_pref("$escapedName", $literal);');
  }

  return buffer.toString();
}

String? _toLiteral(Object? value) {
  if (value is bool) return value.toString();
  if (value is int) return value.toString();
  if (value is String) return '"${_escapeString(value)}"';
  return null;
}

String _escapeString(String value) {
  return value
      .replaceAll('\\', r'\\')
      .replaceAll('"', r'\"')
      .replaceAll('\n', r'\n')
      .replaceAll('\r', r'\r');
}
