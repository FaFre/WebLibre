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

enum SingboxFieldKind {
  text,
  secret,
  integer,
  integerList,
  port,
  boolean,
  stringList,

  /// A value constrained to [SingboxProxyFormField.allowedValues] and always
  /// serialized as a JSON string. Use for sing-box string enums such as the
  /// SOCKS `version` field, whose accepted values ("4", "4a", "5") are
  /// string-typed even when numeric-looking.
  choice,
}

class SingboxProxyFormField {
  final String key;
  final String label;
  final String? helperText;
  final String? defaultValue;
  final bool required;
  final SingboxFieldKind kind;
  final int? exactListLength;
  final int? minValue;
  final int? maxValue;

  /// Permitted values for a [SingboxFieldKind.choice] field, rendered as a
  /// dropdown and enforced during validation.
  final List<String>? allowedValues;

  const SingboxProxyFormField({
    required this.key,
    required this.label,
    this.helperText,
    this.defaultValue,
    this.required = false,
    this.kind = SingboxFieldKind.text,
    this.exactListLength,
    this.minValue,
    this.maxValue,
    this.allowedValues,
  });

  bool get isSecret => kind == SingboxFieldKind.secret;
  bool get isNumber =>
      kind == SingboxFieldKind.integer || kind == SingboxFieldKind.port;
  bool get isIntegerList => kind == SingboxFieldKind.integerList;
  bool get isPort => kind == SingboxFieldKind.port;
  bool get isBoolean => kind == SingboxFieldKind.boolean;
  bool get isStringList => kind == SingboxFieldKind.stringList;
  bool get isChoice => kind == SingboxFieldKind.choice;
}

/// Shared parsing of boolean form values. Returns null when the text doesn't
/// look like a boolean (treated as "unset"), so callers can distinguish absent
/// from explicitly-false.
bool? parseFormBool(String value) {
  return switch (value.trim().toLowerCase()) {
    'true' || 'yes' || '1' || 'on' => true,
    'false' || 'no' || '0' || 'off' => false,
    _ => null,
  };
}

/// Splits a multi-value form input on newlines or commas, trims, drops blanks.
List<String> splitFormStringList(String value) {
  return value
      .split(RegExp(r'[\n,]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}
