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
import 'package:nullability/nullability.dart';
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

String? validateUrl(
  String? value, {
  bool requireAuthority = true,
  bool eagerParsing = true,
  bool onlyHttpProtocol = false,
  bool required = true,
}) {
  if (value.isEmpty) {
    if (required) {
      return 'URL must be provided';
    } else {
      return null;
    }
  }

  if (uri_parser.tryParseUrl(value, eagerParsing: eagerParsing)
      case final Uri url) {
    if (!requireAuthority || url.authority.isNotEmpty) {
      if (!onlyHttpProtocol ||
          (url.isScheme('https') || url.isScheme('http'))) {
        return null;
      }
    }
  }

  return 'Inavlid URL';
}
