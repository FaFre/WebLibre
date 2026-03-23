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

import 'package:weblibre/extensions/uri.dart';

final _lineCommentPattern = RegExp(r'(?<!:)//.*$', multiLine: true);
final _blockCommentPattern = RegExp(r'/\*[\s\S]*?\*/');

final _consolesPattern = RegExp(r'consoles\s*:\s*\[([\s\S]*?)\]', dotAll: true);
final _pagesPattern = RegExp(r'pages\s*:\s*\[([\s\S]*?)\]', dotAll: true);
// ignore: unnecessary_raw_strings
final _stringPattern = RegExp(r'''(?:["'`])([^"'`]+)(?:["'`])''');

List<String> _extractArray(String source, RegExp pattern) {
  final match = pattern.firstMatch(source);
  if (match == null) return [];

  final arrayContent = match.group(1) ?? '';
  return _stringPattern
      .allMatches(arrayContent)
      .map((m) => m.group(1)!)
      .toList();
}

Uri _normalizeUrl(String url) {
  var normalized = url;

  if (normalized.endsWith('/index.html')) {
    normalized = normalized.substring(
      0,
      normalized.length - 'index.html'.length,
    );
  }

  return Uri.parse(normalized);
}

class WanderJsResult {
  final List<Uri> consoles;
  final List<Uri> pages;

  const WanderJsResult({required this.consoles, required this.pages});

  factory WanderJsResult.parse(String jsSource) {
    final cleaned = jsSource
        .replaceAll(_blockCommentPattern, '')
        .replaceAll(_lineCommentPattern, '');

    final consoles = _extractArray(cleaned, _consolesPattern);
    final pages = _extractArray(cleaned, _pagesPattern);

    return WanderJsResult(
      consoles: consoles
          .map(_normalizeUrl)
          .where((uri) => uri.isHttpOrHttps)
          .toList(),
      pages: pages
          .map(_normalizeUrl)
          .where((uri) => uri.isHttpOrHttps)
          .toList(),
    );
  }
}
