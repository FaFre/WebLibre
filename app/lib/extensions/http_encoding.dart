import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

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
