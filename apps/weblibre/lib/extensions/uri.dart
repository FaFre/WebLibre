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

import 'package:weblibre/utils/uri_policy.dart';

extension UriX on Uri {
  Uri get base => Uri.parse('$scheme://$authority');

  bool get hasSupportedScheme =>
      allSupportedSchemes.any((s) => s.name == scheme);

  bool get isHttp => isScheme('http');
  bool get isHttps => isScheme('https');
  bool get isHttpOrHttps => isHttp || isHttps;

  bool get isLocalhost => host == 'localhost' || host == '127.0.0.1';

  /// Removes a bare root path (`/`) when there is no query or fragment, so
  /// that `https://example.com/` and `https://example.com` are treated as
  /// equivalent.
  Uri get normalized {
    if (path == '/' && !hasQuery && !hasFragment) {
      return replace(path: '');
    }
    return this;
  }

  String get displayPath {
    if (path.isEmpty) {
      return '';
    }

    try {
      return Uri.decodeComponent(path);
    } on FormatException {
      return path;
    }
  }

  String get displayString {
    final buffer = StringBuffer();

    if (scheme.isNotEmpty) {
      buffer.write('$scheme:');
    }
    if (authority.isNotEmpty) {
      buffer
        ..write('//')
        ..write(authority);
    }
    buffer.write(displayPath);
    if (query.isNotEmpty) {
      buffer
        ..write('?')
        ..write(query);
    }
    if (fragment.isNotEmpty) {
      buffer
        ..write('#')
        ..write(fragment);
    }

    return buffer.toString();
  }
}

extension UriStringX on String {
  String get uriDisplayString {
    final uri = Uri.tryParse(this);
    if (uri == null || uri.toString() != this) {
      return this;
    }
    try {
      return uri.displayString;
    } on FormatException {
      return this;
    }
  }
}
