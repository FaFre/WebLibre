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
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/proxy/data/forms/singbox_form_specs.dart';
import 'package:weblibre/features/proxy/data/models/proxy_profile_seed.dart';
import 'package:weblibre/features/proxy/data/models/proxy_share.dart';
import 'package:weblibre/features/proxy/data/models/wireguard_config_import.dart';
import 'package:weblibre/features/proxy/data/parsers/singbox_proxy_uri.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;
import 'package:weblibre/features/user/data/models/proxy_dns_override.dart';

part 'proxy_input_consumer.g.dart';

enum ProxyFileImportKind { wireguardConf, singboxOutboundJson }

sealed class ProxyInputOutcome {
  const ProxyInputOutcome();
}

class ProxyInputImported extends ProxyInputOutcome {
  final ProxyProfile created;

  const ProxyInputImported(this.created);
}

class ProxyInputSeed extends ProxyInputOutcome {
  final ProxyProfileSeed seed;

  const ProxyInputSeed(this.seed);
}

class ProxyInputError extends ProxyInputOutcome {
  final String message;

  const ProxyInputError(this.message);
}

@Riverpod(keepAlive: true)
class ProxyInputConsumer extends _$ProxyInputConsumer {
  Future<ProxyInputOutcome> consumeRawText(String raw) async {
    final trimmed = raw.trim();

    if (trimmed.startsWith('$weblibreProxyShareScheme://')) {
      return _consumeShareUri(trimmed);
    }

    if (_looksLikeWireguardConf(trimmed)) {
      return _seedOutcome(
        () => _seedFromWireguardConf(trimmed, fileName: 'WireGuard'),
        logMessage: 'Failed to parse WireGuard configuration',
      );
    }

    if (_looksLikeJsonObject(trimmed)) {
      return _seedOutcome(
        () => _seedFromSingboxOutboundJson(trimmed, fileName: 'Outbound'),
        logMessage: 'Failed to parse pasted sing-box outbound JSON',
      );
    }

    return _seedOutcome(() {
      final imported = importSingboxProxyUri(trimmed);
      return ProxyProfileSeed(
        type: imported.type,
        name: imported.name,
        values: imported.values,
      );
    }, logMessage: 'Failed to import proxy URI');
  }

  Future<ProxyInputOutcome> consumeFile(
    ProxyFileImportKind kind,
    PlatformFile file,
  ) async {
    final String text;
    try {
      text = await _readFileText(file);
    } catch (error, stackTrace) {
      logger.e(
        'Failed to read proxy import file ${file.name}',
        error: error,
        stackTrace: stackTrace,
      );
      return ProxyInputError('Failed to read file: $error');
    }

    return _seedOutcome(
      () => switch (kind) {
        ProxyFileImportKind.wireguardConf => _seedFromWireguardConf(
          text,
          fileName: file.name,
        ),
        ProxyFileImportKind.singboxOutboundJson => _seedFromSingboxOutboundJson(
          text,
          fileName: file.name,
        ),
      },
      logMessage: 'Invalid proxy import file ${file.name} ($kind)',
    );
  }

  Future<ProxyInputOutcome> _consumeShareUri(String text) async {
    try {
      final envelope = decodeProxyShareUri(text);
      final created = await ref
          .read(singboxProxyProfilesRepositoryProvider.notifier)
          .createProfile(
            name: envelope.name,
            type: envelope.type,
            configJson: envelope.configJson,
            secretJson: envelope.secretJson,
            dnsOverrideJson: envelope.dnsOverrideJson,
          );
      return ProxyInputImported(created);
    } on FormatException catch (error, stackTrace) {
      logger.e(
        'Failed to decode WebLibre proxy share URI',
        error: error,
        stackTrace: stackTrace,
      );
      return ProxyInputError(error.message);
    }
  }

  ProxyInputOutcome _seedOutcome(
    ProxyProfileSeed Function() createSeed, {
    required String logMessage,
  }) {
    try {
      return ProxyInputSeed(createSeed());
    } on FormatException catch (error, stackTrace) {
      logger.e(logMessage, error: error, stackTrace: stackTrace);
      return ProxyInputError(error.message);
    }
  }

  Future<String> _readFileText(PlatformFile file) async {
    final bytes = file.bytes;
    if (bytes != null) {
      return utf8.decode(bytes, allowMalformed: true);
    }
    final path = file.path;
    if (path == null) {
      throw const FormatException('Unable to read file contents.');
    }
    return File(path).readAsString();
  }

  @override
  void build() {}
}

ProxyProfileSeed _seedFromWireguardConf(
  String configText, {
  required String fileName,
}) {
  final imported = WireguardConfigImport.fromConfigText(configText);
  final dnsAddress = imported.primaryDnsAddress;
  final dnsOverrideJson = dnsAddress == null
      ? null
      : jsonEncode(ProxyDnsOverride(remoteServerAddress: dnsAddress).toJson());
  return ProxyProfileSeed(
    type: SingboxProxyProfileType.wireguard,
    name: _stripExtension(fileName),
    values: imported.values,
    dnsOverrideJson: dnsOverrideJson,
  );
}

ProxyProfileSeed _seedFromSingboxOutboundJson(
  String text, {
  required String fileName,
}) {
  final decoded = jsonDecode(text);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Expected a sing-box outbound JSON object.');
  }
  final outboundType = decoded['type'];
  if (outboundType is! String) {
    throw const FormatException(
      'Outbound JSON is missing a top-level "type" field.',
    );
  }
  final spec = singboxProxyFormSpecs.values.firstWhere(
    (entry) => entry.outboundType == outboundType,
    orElse: () => throw FormatException(
      'No structured form for outbound type "$outboundType". '
      'Use Custom Outbound JSON instead.',
    ),
  );
  final values = spec.valuesFromJson(configJson: jsonEncode(decoded));
  return ProxyProfileSeed(
    type: spec.type,
    name: (decoded['tag'] as String?) ?? _stripExtension(fileName),
    values: values,
  );
}

String _stripExtension(String fileName) {
  final dot = fileName.lastIndexOf('.');
  if (dot <= 0) return fileName;
  return fileName.substring(0, dot);
}

bool _looksLikeWireguardConf(String text) {
  return text.contains('[Interface]') &&
      (text.contains('PrivateKey') || text.contains('Address'));
}

bool _looksLikeJsonObject(String text) {
  return text.startsWith('{') && text.endsWith('}');
}
