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

import 'package:weblibre/extensions/uri.dart';

final _domainRegex = RegExp(r'\.[a-zA-Z]{2,}$');

Uri? tryParseUrl(String? input, {bool eagerParsing = false}) {
  if (input != null) {
    var uri = Uri.tryParse(input);
    if (uri != null) {
      if (uri.authority.isEmpty && eagerParsing) {
        if (uri.pathSegments.isNotEmpty) {
          int? port;
          var firstSegment = uri.pathSegments.first;

          //When there is no scheme while aprsing, the port becomse the first segment because : is treated as delimeter
          if (int.tryParse(firstSegment) case final int segmentPort) {
            port = segmentPort;
            firstSegment = uri.scheme;
          }

          if (_domainRegex.hasMatch(firstSegment)) {
            uri = Uri.tryParse('https://$input')?.replace(port: port);
          } else if (firstSegment == 'localhost') {
            uri = Uri.tryParse('http://$input')?.replace(port: port);
          } else if (InternetAddress.tryParse(firstSegment) != null) {
            uri = Uri.tryParse('https://$input')?.replace(port: port);
          }
        }
      }

      if (uri != null) {
        if (uri.isScheme('about')) {
          return uri;
        }

        if (uri.authority.isNotEmpty) {
          if (uri.hasSupportedScheme || !uri.hasScheme) {
            return uri;
          }
        }
      }
    }
  }
  return null;
}
