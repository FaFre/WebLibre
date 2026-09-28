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
import 'dart:convert';

import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:weblibre/features/proxy/data/forms/singbox_form_field.dart';
import 'package:weblibre/features/proxy/data/parsers/cidr.dart';

class SingboxProxyFormSpec {
  final SingboxProxyProfileType type;
  final String outboundType;
  final List<SingboxProxyFormField> fields;

  const SingboxProxyFormSpec({
    required this.type,
    required this.outboundType,
    required this.fields,
  });

  /// Returns the first invalid field, or null when every field is valid.
  SingboxFormFieldError? validate(Map<String, String> values) {
    for (final field in fields) {
      final value = values[field.key]?.trim() ?? '';
      if (field.required && value.isEmpty) {
        return SingboxFormFieldError(field, SingboxFieldErrorKind.required);
      }
      if (field.isNumber && value.isNotEmpty) {
        final parsed = int.tryParse(value);
        if (parsed == null || parsed < 1) {
          return SingboxFormFieldError(
            field,
            SingboxFieldErrorKind.notPositiveNumber,
          );
        }
        if (field.isPort && parsed > 65535) {
          return SingboxFormFieldError(
            field,
            SingboxFieldErrorKind.outOfPortRange,
          );
        }
      }
      if (field.isIntegerList && value.isNotEmpty) {
        final items = splitFormStringList(value);
        final exactListLength = field.exactListLength;
        if (exactListLength != null && items.length != exactListLength) {
          return SingboxFormFieldError(
            field,
            SingboxFieldErrorKind.wrongListLength,
            intParam: exactListLength,
          );
        }
        for (final item in items) {
          final parsed = int.tryParse(item);
          if (parsed == null) {
            return SingboxFormFieldError(
              field,
              SingboxFieldErrorKind.notAllNumbers,
            );
          }
          final minValue = field.minValue;
          if (minValue != null && parsed < minValue) {
            return SingboxFormFieldError(
              field,
              SingboxFieldErrorKind.belowMinValue,
              intParam: minValue,
            );
          }
          final maxValue = field.maxValue;
          if (maxValue != null && parsed > maxValue) {
            return SingboxFormFieldError(
              field,
              SingboxFieldErrorKind.aboveMaxValue,
              intParam: maxValue,
            );
          }
        }
      }
      if (field.isCidrList && value.isNotEmpty) {
        for (final item in splitFormStringList(value)) {
          if (tryParseCidr(item) == null) {
            return SingboxFormFieldError(
              field,
              SingboxFieldErrorKind.invalidCidr,
              stringParam: item,
            );
          }
        }
      }
      if (field.isBoolean && value.isNotEmpty && parseFormBool(value) == null) {
        return SingboxFormFieldError(field, SingboxFieldErrorKind.notBoolean);
      }
      if (field.isChoice && value.isNotEmpty) {
        final allowedValues = field.allowedValues;
        if (allowedValues != null && !allowedValues.contains(value)) {
          return SingboxFormFieldError(
            field,
            SingboxFieldErrorKind.notAllowedValue,
            listParam: allowedValues,
          );
        }
      }
    }

    return null;
  }

  String toConfigJson(Map<String, String> values) {
    final config = <String, dynamic>{'type': outboundType};
    for (final field in fields.where((field) => !field.isSecret)) {
      final value = values[field.key]?.trim() ?? '';
      if (value.isEmpty) continue;
      _setJsonValue(config, field.key, _fieldJsonValue(field, value));
    }

    return const JsonEncoder.withIndent('  ').convert(config);
  }

  String? toSecretJson(Map<String, String> values) {
    final secrets = <String, dynamic>{};
    for (final field in fields.where((field) => field.isSecret)) {
      final value = values[field.key]?.trim() ?? '';
      if (value.isEmpty) continue;
      _setJsonValue(secrets, field.key, _fieldJsonValue(field, value));
    }

    if (secrets.isEmpty) return null;
    return const JsonEncoder.withIndent('  ').convert(secrets);
  }

  Map<String, String> valuesFromJson({
    required String configJson,
    String? secretJson,
  }) {
    final config = _decodeJsonObject(configJson) ?? const <String, dynamic>{};
    final secrets = secretJson == null
        ? const <String, dynamic>{}
        : _decodeJsonObject(secretJson) ?? const <String, dynamic>{};
    final merged = {...config, ...secrets};

    return {
      for (final field in fields)
        field.key: _fieldTextValue(
          _jsonValueAt(merged, field.key),
          field.defaultValue ?? '',
        ),
    };
  }
}

Map<String, dynamic>? _decodeJsonObject(String rawJson) {
  try {
    final decoded = jsonDecode(rawJson) as Object?;
    if (decoded is Map<String, dynamic>) return decoded;
  } catch (_) {
    return null;
  }

  return null;
}

Object _fieldJsonValue(SingboxProxyFormField field, String value) {
  if (field.isNumber) return int.parse(value);
  if (field.isIntegerList) {
    return splitFormStringList(value).map(int.parse).toList();
  }
  if (field.isBoolean) return parseFormBool(value)!;
  // Before [isStringList], which a CIDR list also answers to: the entries are
  // written out as prefixes even when the user typed a bare address, because
  // that is the only shape sing-box accepts.
  if (field.isCidrList) {
    return splitFormStringList(
      value,
    ).map((item) => tryNormalizeCidr(item) ?? item).toList();
  }
  if (field.isStringList) return splitFormStringList(value);
  return value;
}

String _fieldTextValue(Object? value, String fallback) {
  if (value == null) return fallback;
  if (value is List) return value.map((item) => item.toString()).join('\n');
  return value.toString();
}

void _setJsonValue(Map<String, dynamic> target, String path, Object value) {
  final segments = path.split('.');
  var current = target;
  for (final segment in segments.take(segments.length - 1)) {
    current =
        current.putIfAbsent(segment, () => <String, dynamic>{})
            as Map<String, dynamic>;
  }
  current[segments.last] = value;
}

Object? _jsonValueAt(Map<String, dynamic> source, String path) {
  Object? current = source;
  for (final segment in path.split('.')) {
    if (current is! Map<String, dynamic>) return null;
    current = current[segment];
  }
  return current;
}

enum SingboxFieldErrorKind {
  required,
  notPositiveNumber,
  outOfPortRange,
  wrongListLength,
  notAllNumbers,
  belowMinValue,
  aboveMaxValue,
  invalidCidr,
  notBoolean,
  notAllowedValue,
}

/// A single failed [SingboxProxyFormField], plus whatever the failure needs
/// to describe itself (a count, a bound, the offending value, or the choices
/// it had to be one of). Resolved to display text in
/// `presentation/utils/singbox_form_field_l10n.dart`.
class SingboxFormFieldError {
  final SingboxProxyFormField field;
  final SingboxFieldErrorKind kind;
  final int? intParam;
  final String? stringParam;
  final List<String>? listParam;

  const SingboxFormFieldError(
    this.field,
    this.kind, {
    this.intParam,
    this.stringParam,
    this.listParam,
  });
}
