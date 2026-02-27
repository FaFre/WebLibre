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

import 'package:weblibre/utils/uri_input_parser.dart';
import 'package:weblibre/utils/uri_policy.dart';

enum NavigationReason {
  explicitScheme,
  schemelessHost,
  localhost,
  ipLiteral,
  aboutLike,
}

enum SearchReason {
  containsWhitespace,
  notHostCandidate,
  invalidHostChars,
  fallback,
}

enum InvalidReason {
  unsupportedScheme,
  malformedUri,
  containsControlChars,
  emptyInput,
  tooLong,
}

sealed class InputClassification {
  const InputClassification();

  const factory InputClassification.navigate(Uri uri, NavigationReason reason) =
      NavigateInputClassification;
  const factory InputClassification.search(String query, SearchReason reason) =
      SearchInputClassification;
  const factory InputClassification.invalid(String raw, InvalidReason reason) =
      InvalidInputClassification;
}

final class NavigateInputClassification extends InputClassification {
  final Uri uri;
  final NavigationReason reason;

  const NavigateInputClassification(this.uri, this.reason);
}

final class SearchInputClassification extends InputClassification {
  final String query;
  final SearchReason reason;

  const SearchInputClassification(this.query, this.reason);
}

final class InvalidInputClassification extends InputClassification {
  final String raw;
  final InvalidReason reason;

  const InvalidInputClassification(this.raw, this.reason);
}

InputClassification classifyAddressBarInput(
  String input, {
  SchemePolicy policy = SchemePolicy.addressBarTyped,
}) {
  final normalizedInput = normalizeInput(input);

  if (normalizedInput.isEmpty) {
    return InputClassification.invalid(
      normalizedInput,
      InvalidReason.emptyInput,
    );
  }

  if (exceedsMaxInputLength(normalizedInput)) {
    return InputClassification.invalid(normalizedInput, InvalidReason.tooLong);
  }

  if (containsControlChars(normalizedInput)) {
    return InputClassification.invalid(
      normalizedInput,
      InvalidReason.containsControlChars,
    );
  }

  if (hasExplicitScheme(normalizedInput)) {
    final explicitUri = parseExplicitUri(normalizedInput, policy: policy);
    if (explicitUri != null) {
      final reason = explicitUri.isScheme('about')
          ? NavigationReason.aboutLike
          : NavigationReason.explicitScheme;

      return InputClassification.navigate(explicitUri, reason);
    }

    if (hasAllowedScheme(normalizedInput, policy.allowedSchemes)) {
      return InputClassification.invalid(
        normalizedInput,
        InvalidReason.malformedUri,
      );
    }

    return InputClassification.invalid(
      normalizedInput,
      InvalidReason.unsupportedScheme,
    );
  }

  if (normalizedInput.contains(whitespaceRegex)) {
    return InputClassification.search(
      normalizedInput,
      SearchReason.containsWhitespace,
    );
  }

  final schemelessUri = parseSchemelessWebHost(
    normalizedInput,
    allowedSchemes: policy.allowedSchemes,
  );

  if (schemelessUri != null) {
    if (schemelessUri.host.toLowerCase() == 'localhost') {
      return InputClassification.navigate(
        schemelessUri,
        NavigationReason.localhost,
      );
    }

    if (InternetAddress.tryParse(schemelessUri.host) != null) {
      return InputClassification.navigate(
        schemelessUri,
        NavigationReason.ipLiteral,
      );
    }

    return InputClassification.navigate(
      schemelessUri,
      NavigationReason.schemelessHost,
    );
  }

  if (looksLikeHostExpression(normalizedInput) &&
      hasInvalidHostLikeChars(normalizedInput)) {
    return InputClassification.search(
      normalizedInput,
      SearchReason.invalidHostChars,
    );
  }

  return InputClassification.search(
    normalizedInput,
    SearchReason.notHostCandidate,
  );
}

Uri? parseSharedIntentUrl(
  String input, {
  SchemePolicy policy = SchemePolicy.sharedIntent,
}) {
  final normalizedInput = normalizeInput(input);
  if (normalizedInput.isEmpty ||
      exceedsMaxInputLength(normalizedInput) ||
      containsControlChars(normalizedInput)) {
    return null;
  }

  if (hasExplicitScheme(normalizedInput)) {
    return parseExplicitUri(normalizedInput, policy: policy);
  }

  if (normalizedInput.contains(whitespaceRegex)) {
    return null;
  }

  return parseSchemelessWebHost(
    normalizedInput,
    allowedSchemes: policy.allowedSchemes,
  );
}
