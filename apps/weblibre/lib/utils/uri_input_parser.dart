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

import 'package:weblibre/utils/uri_policy.dart';

const maxUriInputLength = 4096;

final _controlCharacterRegex = RegExp(r'[\x00-\x1F\u007F-\u009F]');
final _explicitSchemeRegex = RegExp(r'^([a-zA-Z][a-zA-Z0-9+\-.]*):');
final _hostPortSuffixRegex = RegExp(r'^\d{1,5}([/?#].*)?$');
final _hostLabelRegex = RegExp(r'^[a-zA-Z0-9-]{1,63}$');
final _topLevelDomainRegex = RegExp(r'^[a-zA-Z]{2,63}$');
final _possibleHostCharsRegex = RegExp(
  r"^[a-zA-Z0-9\-._~:/?#\[\]@!$&'()*+,;=%]+$",
);
final whitespaceRegex = RegExp(r'\s');

String normalizeInput(String input) {
  return input.trim();
}

bool containsControlChars(String input) {
  return _controlCharacterRegex.hasMatch(input);
}

bool hasAllowedScheme(String input, Set<String> allowedSchemes) {
  final scheme = _extractExplicitScheme(input);
  if (scheme == null) {
    return false;
  }

  return allowedSchemes.contains(scheme);
}

bool hasExplicitScheme(String input) {
  final match = _explicitSchemeRegex.firstMatch(input);
  if (match == null) {
    return false;
  }

  final scheme = match.group(1)?.toLowerCase();
  if (scheme == null) {
    return false;
  }

  final suffix = input.substring(match.end);
  if (suffix.startsWith('//')) {
    return true;
  }

  // Keep host:port shorthand treated as schemeless input.
  if ((scheme == 'localhost' || scheme.contains('.')) &&
      _hostPortSuffixRegex.hasMatch(suffix)) {
    return false;
  }

  return true;
}

bool exceedsMaxInputLength(String input, {int limit = maxUriInputLength}) {
  return input.length > limit;
}

bool isValidHostCandidate(String hostCandidate) {
  final host = hostCandidate.trim().toLowerCase();
  if (host.isEmpty) {
    return false;
  }

  if (host == 'localhost') {
    return true;
  }

  if (InternetAddress.tryParse(host) != null) {
    return true;
  }

  final labels = host.split('.');
  if (labels.length < 2) {
    return false;
  }

  if (!_topLevelDomainRegex.hasMatch(labels.last)) {
    return false;
  }

  for (final label in labels) {
    if (!_hostLabelRegex.hasMatch(label) ||
        label.startsWith('-') ||
        label.endsWith('-')) {
      return false;
    }
  }

  return true;
}

bool looksLikeHostExpression(String input) {
  return input.contains('.') ||
      input.contains(':') ||
      input.startsWith('[') ||
      input.contains('/');
}

bool hasInvalidHostLikeChars(String input) {
  return !_possibleHostCharsRegex.hasMatch(input);
}

Uri? parseExplicitUri(
  String input, {
  required SchemePolicy policy,
  bool enforceMaxInputLength = false,
}) {
  final normalizedInput = normalizeInput(input);
  if (normalizedInput.isEmpty ||
      (enforceMaxInputLength && exceedsMaxInputLength(normalizedInput)) ||
      containsControlChars(normalizedInput) ||
      !hasExplicitScheme(normalizedInput) ||
      !hasAllowedScheme(normalizedInput, policy.allowedSchemes)) {
    return null;
  }

  final uri = Uri.tryParse(normalizedInput);
  if (uri == null) {
    return null;
  }

  final scheme = uri.scheme.toLowerCase();
  if (!policy.allows(scheme)) {
    return null;
  }

  if (schemeRequiresAuthority(scheme) && uri.authority.isEmpty) {
    return null;
  }

  return uri.replace(scheme: scheme);
}

Uri? parseSchemelessWebHost(
  String input, {
  Set<String>? allowedSchemes,
  bool enforceMaxInputLength = false,
}) {
  final normalizedInput = normalizeInput(input);
  if (normalizedInput.isEmpty ||
      (enforceMaxInputLength && exceedsMaxInputLength(normalizedInput)) ||
      containsControlChars(normalizedInput) ||
      hasExplicitScheme(normalizedInput) ||
      normalizedInput.contains(whitespaceRegex)) {
    return null;
  }

  final probeUri = Uri.tryParse('https://$normalizedInput');
  if (probeUri == null || probeUri.host.isEmpty) {
    return null;
  }

  if (!isValidHostCandidate(probeUri.host)) {
    return null;
  }

  if (probeUri.hasPort && (probeUri.port < 1 || probeUri.port > 65535)) {
    return null;
  }

  final scheme = probeUri.host.toLowerCase() == 'localhost' ? 'http' : 'https';
  if (allowedSchemes != null && !allowedSchemes.contains(scheme)) {
    return null;
  }

  return probeUri.replace(scheme: scheme);
}

Uri? parseUserInputUrl(
  String? input, {
  required SchemePolicy policy,
  bool allowSchemelessHosts = false,
  bool enforceMaxInputLength = false,
}) {
  if (input == null) {
    return null;
  }

  final normalizedInput = normalizeInput(input);
  if (normalizedInput.isEmpty ||
      (enforceMaxInputLength && exceedsMaxInputLength(normalizedInput)) ||
      containsControlChars(normalizedInput)) {
    return null;
  }

  if (hasExplicitScheme(normalizedInput)) {
    return parseExplicitUri(
      normalizedInput,
      policy: policy,
      enforceMaxInputLength: enforceMaxInputLength,
    );
  }

  if (!allowSchemelessHosts) {
    return null;
  }

  return parseSchemelessWebHost(
    normalizedInput,
    allowedSchemes: policy.allowedSchemes,
    enforceMaxInputLength: enforceMaxInputLength,
  );
}

Uri redactUriCredentials(Uri uri) {
  if (uri.userInfo.isEmpty) {
    return uri;
  }

  return uri.replace(userInfo: '');
}

String? _extractExplicitScheme(String input) {
  final match = _explicitSchemeRegex.firstMatch(input);
  if (match == null) {
    return null;
  }

  return match.group(1)?.toLowerCase();
}
