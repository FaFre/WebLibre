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
      if (field.wireguardKey && value.isNotEmpty && !isWireguardKey(value)) {
        return SingboxFormFieldError(
          field,
          SingboxFieldErrorKind.invalidWireguardKey,
        );
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

  /// The config JSON for [values], written over [baseConfigJson] when given.
  ///
  /// The form shows only some of what sing-box accepts. Building the JSON from
  /// the fields alone dropped every key the form has no field for, on every
  /// save — an imported `udp_fragment` or detour, say, was gone the first time
  /// the profile was edited. So the profile's own JSON is the starting point:
  /// keys the form owns are cleared and rewritten from [values] (an emptied
  /// field really is removed), and everything else is left as it was. Secret
  /// fields are cleared from it too — they belong in [toSecretJson] — and so
  /// is every key the form has no field for but that holds a credential
  /// ([_extractSecrets]), which [toSecretJson] picks up from the same base.
  String toConfigJson(Map<String, String> values, {String? baseConfigJson}) {
    final config = _baseWithoutFields(baseConfigJson);
    _extractSecrets(config);
    config['type'] = outboundType;
    for (final field in fields.where((field) => !field.isSecret)) {
      final value = values[field.key]?.trim() ?? '';
      if (value.isEmpty) continue;
      _setJsonValue(config, field.key, _fieldJsonValue(field, value));
    }

    return const JsonEncoder.withIndent('  ').convert(config);
  }

  /// The secret JSON for [values], written over [baseSecretJson] — see
  /// [toConfigJson]. The credentials [toConfigJson] takes out of
  /// [baseConfigJson] land here, under [baseSecretJson]'s own values.
  String? toSecretJson(
    Map<String, String> values, {
    String? baseSecretJson,
    String? baseConfigJson,
  }) {
    final secrets = _extractSecrets(_baseWithoutFields(baseConfigJson));
    _deepMerge(secrets, _baseWithoutFields(baseSecretJson));
    for (final field in fields.where((field) => field.isSecret)) {
      final value = values[field.key]?.trim() ?? '';
      if (value.isEmpty) continue;
      _setJsonValue(secrets, field.key, _fieldJsonValue(field, value));
    }

    if (secrets.isEmpty) return null;
    return const JsonEncoder.withIndent('  ').convert(secrets);
  }

  /// [baseJson] decoded, minus every key a field of this spec owns.
  Map<String, dynamic> _baseWithoutFields(String? baseJson) {
    final base = baseJson == null
        ? <String, dynamic>{}
        : _decodeJsonObject(baseJson) ?? <String, dynamic>{};
    for (final field in fields) {
      _removeJsonValue(base, field.key);
    }
    return base;
  }

  Map<String, String> valuesFromJson({
    required String configJson,
    String? secretJson,
  }) {
    // Merged the way the runtime merges them: a secret field's key shares an
    // object with plain ones (hysteria2's `obfs.password` and `obfs.type`).
    final merged = _decodeJsonObject(configJson) ?? <String, dynamic>{};
    if (secretJson != null) {
      _deepMerge(merged, _decodeJsonObject(secretJson) ?? const {});
    }

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

/// Keys that hold a credential in some sing-box outbound, wherever they sit.
///
/// A form field marks its own key secret, but the JSON a profile keeps holds
/// keys no field covers — an imported hysteria `auth`, a shadowsocks
/// `plugin_opts` carrying an obfs password — and those would otherwise be
/// stored in the plaintext config instead of secure storage. TLS's
/// `client_key` is the PEM private key of a client certificate.
const _secretKeyNames = {
  'auth',
  'auth_str',
  'client_key',
  'password',
  'plugin_opts',
  'pre_shared_key',
  'private_key',
  'private_key_passphrase',
  'uuid',
  'username',
};

/// Moves every credential out of [config] and returns them, nested as they
/// were, ready to be merged back over it.
///
/// A secret inside a list takes the whole list with it, because a merge
/// replaces lists rather than combining them. hysteria's `obfs` is a password
/// when it is a string and an object holding one in hysteria2.
Map<String, dynamic> _extractSecrets(Map<String, dynamic> config) {
  final secrets = <String, dynamic>{};
  for (final key in config.keys.toList()) {
    final value = config[key];
    final isSecretKey =
        _secretKeyNames.contains(key) || (key == 'obfs' && value is String);
    if (value is Map<String, dynamic> && !isSecretKey) {
      final nested = _extractSecrets(value);
      if (nested.isEmpty) continue;
      secrets[key] = nested;
      if (value.isEmpty) config.remove(key);
    } else if (isSecretKey || (value is List && _containsSecret(value))) {
      secrets[key] = config.remove(key);
    }
  }
  return secrets;
}

bool _containsSecret(Object? value) => switch (value) {
  final Map<String, dynamic> map => map.entries.any(
    (entry) =>
        _secretKeyNames.contains(entry.key) ||
        (entry.key == 'obfs' && entry.value is String) ||
        _containsSecret(entry.value),
  ),
  final List<dynamic> list => list.any(_containsSecret),
  _ => false,
};

/// Merges [source] into [target] the way the runtime merges a profile's
/// secrets over its config: objects combine, everything else replaces.
void _deepMerge(Map<String, dynamic> target, Map<String, dynamic> source) {
  for (final MapEntry(:key, :value) in source.entries) {
    final existing = target[key];
    if (value is Map<String, dynamic> && existing is Map<String, dynamic>) {
      _deepMerge(existing, value);
    } else {
      target[key] = value;
    }
  }
}

/// Removes [path] from [target], and any object the removal leaves empty.
void _removeJsonValue(Map<String, dynamic> target, String path) {
  final segments = path.split('.');
  if (segments.length == 1) {
    target.remove(path);
    return;
  }

  final child = target[segments.first];
  if (child is! Map<String, dynamic>) return;
  _removeJsonValue(child, segments.skip(1).join('.'));
  if (child.isEmpty) target.remove(segments.first);
}

/// Whether [value] is a WireGuard key: standard base64 of exactly 32 bytes.
///
/// Matched rather than decoded: Dart's decoder also takes the URL-safe
/// alphabet and a missing pad, and sing-box (Go's `base64.StdEncoding`)
/// takes neither.
bool isWireguardKey(String value) => _wireguardKey.hasMatch(value.trim());

final _wireguardKey = RegExp(r'^[A-Za-z0-9+/]{43}=$');

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
  invalidWireguardKey,
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
