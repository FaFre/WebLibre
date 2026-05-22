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

/// Shared prefix for every "we know this URL has no favicon" cache entry.
///
/// The recognised version is appended by [missingIconMarkerBytes]. The
/// [isMissingIconMarker] check matches by *prefix* so a future version
/// bump (`v2`, `v3` …) doesn't silently fail to recognise old entries —
/// those rows would otherwise be handed to consumers as opaque bytes
/// and confuse the image-decode fallback path.
const _missingIconMarkerPrefix = 'weblibre:missing-favicon:';
const _currentMissingIconMarkerVersion = 'v1';

final Uint8List missingIconMarkerBytes = Uint8List.fromList(
  utf8.encode('$_missingIconMarkerPrefix$_currentMissingIconMarkerVersion'),
);

final Uint8List _missingIconMarkerPrefixBytes = Uint8List.fromList(
  utf8.encode(_missingIconMarkerPrefix),
);

bool isMissingIconMarker(Uint8List? bytes) {
  if (bytes == null) return false;
  if (bytes.length < _missingIconMarkerPrefixBytes.length) return false;
  for (var i = 0; i < _missingIconMarkerPrefixBytes.length; i++) {
    if (bytes[i] != _missingIconMarkerPrefixBytes[i]) return false;
  }
  return true;
}
