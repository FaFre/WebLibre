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
import 'package:universal_io/io.dart';

final _domainRegex = RegExp(r'\.[a-zA-Z]{2,}$');
const _supportedSchemes = {'https', 'http', 'ftp', 'file', 'content', 'about'};

Uri? tryParseUrl(String? input, {bool eagerParsing = false}) {
  if (input != null) {
    var uri = Uri.tryParse(input);
    if (uri != null) {
      if (uri.authority.isEmpty && eagerParsing) {
        if (uri.pathSegments.isNotEmpty) {
          if (_domainRegex.hasMatch(uri.pathSegments.first)) {
            uri = Uri.tryParse('https://$input');
          } else if (InternetAddress.tryParse(uri.pathSegments.first) != null) {
            uri = Uri.tryParse('https://$input');
          }
        }
      }

      if (uri != null) {
        if (uri.isScheme('about')) {
          return uri;
        }

        if (uri.authority.isNotEmpty) {
          if (_supportedSchemes.contains(uri.scheme) || !uri.hasScheme) {
            return uri;
          }
        }
      }
    }
  }
  return null;
}
