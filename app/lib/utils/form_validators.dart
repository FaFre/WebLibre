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

import 'package:nullability/nullability.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

String? validateUrl(
  String? value, {
  required bool eagerParsing,
  bool requireAuthority = true,
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

String? validateRequired(String? value, {String message = 'Value required'}) {
  if (value.isNotEmpty) {
    return null;
  }

  return message;
}

String? validatePath(String? value) {
  if (value == null || value.isEmpty) {
    return 'Path cannot be empty';
  }

  // Check for invalid characters
  // ignore: unnecessary_raw_strings
  final invalidChars = RegExp(r'[<>"|?*]');
  if (invalidChars.hasMatch(value)) {
    return 'Path contains invalid characters';
  }

  // Validate path structure
  try {
    p.normalize(value);
  } catch (e) {
    return 'Invalid path format';
  }

  return null;
}

String? validateDirectoryExisting(String? value) {
  if (value == null || value.isEmpty) {
    return 'Path cannot be empty';
  }

  if (!Directory(value).existsSync()) {
    return 'Directory is not existing';
  }

  return null;
}

String? validateDirectoryNotExisting(String? value) {
  if (value == null || value.isEmpty) {
    return 'Path cannot be empty';
  }

  if (Directory(value).existsSync()) {
    return 'Directory already exisits';
  }

  return null;
}

String? validateFileNotExisting(String? value) {
  if (value == null || value.isEmpty) {
    return 'Path cannot be empty';
  }

  if (File(value).existsSync()) {
    return 'File already exisits';
  }

  return null;
}

String? validateFileExisting(String? value) {
  if (value == null || value.isEmpty) {
    return 'Path cannot be empty';
  }

  if (!File(value).existsSync()) {
    return 'File not existing';
  }

  return null;
}

final _profileNamePattern = RegExp(r"""^[^~)('!*<>:;,?"*|/_]+$""");

String? validateProfileName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Name required';
  }

  if (!_profileNamePattern.hasMatch(value)) {
    return 'Name contains invalid caharcters';
  }

  return null;
}
