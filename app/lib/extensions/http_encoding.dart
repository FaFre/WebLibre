/*
 * Copyright (c) 2024-2025 Fabian Freund.
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

import 'package:http/http.dart';

/// This is modified from default latin1 fallback to use utf8
Encoding _encodingForHeaders(Map<String, String> headers) =>
    _encodingForContentTypeHeader(_contentTypeForHeaders(headers), utf8);

/// Returns the [MediaType] object for the given headers' content-type.
///
/// Defaults to `application/octet-stream`.
MediaType _contentTypeForHeaders(Map<String, String> headers) {
  final contentType = headers['content-type'];
  if (contentType != null) return MediaType.parse(contentType);
  return MediaType('application', 'octet-stream');
}

Encoding _encodingForContentTypeHeader(
  MediaType contentTypeHeader, [
  Encoding fallback = latin1,
]) {
  final charset = contentTypeHeader.parameters['charset'];

  // Default to utf8 for application/json when charset is unspecified.
  if (contentTypeHeader.type == 'application' &&
      contentTypeHeader.subtype == 'json' &&
      charset == null) {
    return utf8;
  }

  // Attempt to find the encoding or fall back to the default.
  return charset != null ? Encoding.getByName(charset) ?? fallback : fallback;
}

extension ResponesEncoding on Response {
  String get bodyUnicodeFallback =>
      _encodingForHeaders(headers).decode(bodyBytes);
}
