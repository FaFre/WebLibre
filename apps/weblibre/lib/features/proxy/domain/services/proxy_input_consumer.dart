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

import 'package:file_picker/file_picker.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/branding/proxy_brands.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/uuid.dart';
import 'package:weblibre/features/proxy/data/forms/singbox_form_specs.dart';
import 'package:weblibre/features/proxy/data/models/proxy_import_failure.dart';
import 'package:weblibre/features/proxy/data/models/proxy_profile_seed.dart';
import 'package:weblibre/features/proxy/data/models/proxy_share.dart';
import 'package:weblibre/features/proxy/data/models/wireguard_config_import.dart';
import 'package:weblibre/features/proxy/data/parsers/singbox_json_import.dart';
import 'package:weblibre/features/proxy/data/parsers/singbox_proxy_uri.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;
import 'package:weblibre/features/user/data/models/proxy_dns_override.dart';

part 'proxy_input_consumer.g.dart';

enum ProxyFileImportKind { wireguardConf, singboxOutboundJson }

/// Something an import noted about one of the proxies it stored, by the name
/// that proxy was stored under.
typedef ImportedProfileNote = ({String profileName, ProxyImportNote note});

sealed class ProxyInputOutcome {
  const ProxyInputOutcome();
}

class ProxyInputImported extends ProxyInputOutcome {
  final ProxyProfile created;

  const ProxyInputImported(this.created);
}

/// Several proxies, imported straight away — a whole sing-box config holds as
/// many as it likes, and one editor per proxy is no way to take them in.
class ProxyInputImportedMany extends ProxyInputOutcome {
  final List<ProxyProfile> created;

  /// Proxies in the config that could not be used: their fields did not
  /// validate, or sing-box refused them.
  final int skipped;

  /// What the import noted about the proxies in [created]. The editor shows a single proxy's notes before it is
  /// saved; these are stored without one, so the notes come back here — a
  /// split tunnel cannot reach most sites, which is no thing to keep quiet.
  final List<ImportedProfileNote> notes;

  const ProxyInputImportedMany(
    this.created, {
    required this.skipped,
    this.notes = const [],
  });
}

class ProxyInputSeed extends ProxyInputOutcome {
  final ProxyProfileSeed seed;

  const ProxyInputSeed(this.seed);
}

class ProxyInputError extends ProxyInputOutcome {
  /// A [ProxyImportFailure] to translate where it is shown, or another
  /// [FormatException] whose message is all there is to say.
  final FormatException error;

  const ProxyInputError(this.error);
}

/// The name for the [n]th proxy of an import that names none of its own
/// (1-based). Supplied by the caller, which can translate it.
typedef ProxyImportDefaultName = String Function(int n);

@Riverpod(keepAlive: true)
class ProxyInputConsumer extends _$ProxyInputConsumer {
  Future<ProxyInputOutcome> consumeRawText(
    String raw, {
    required ProxyImportDefaultName defaultName,
  }) async {
    final trimmed = raw.trim();

    if (trimmed.startsWith('$weblibreProxyShareScheme://')) {
      return await _consumeShareUri(trimmed);
    }

    if (_looksLikeWireguardConf(trimmed)) {
      return _seedOutcome(
        () => _seedFromWireguardConf(trimmed, fileName: wireGuardBrand),
        logMessage: 'Failed to parse $wireGuardBrand configuration',
      );
    }

    if (_looksLikeJsonObject(trimmed)) {
      return await _consumeSingboxJson(
        trimmed,
        fileName: null,
        defaultName: defaultName,
        logMessage: 'Failed to parse pasted sing-box JSON',
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
    PlatformFile file, {
    required ProxyImportDefaultName defaultName,
  }) async {
    final String text;
    try {
      text = await _readFileText(file);
    } catch (error, stackTrace) {
      logger.e(
        'Failed to read proxy import file ${file.name}',
        error: error,
        stackTrace: stackTrace,
      );
      return ProxyInputError(
        ProxyImportFailure(
          ProxyImportFailureKind.fileUnreadable,
          detail: '$error',
        ),
      );
    }

    final logMessage = 'Invalid proxy import file ${file.name} ($kind)';
    return switch (kind) {
      ProxyFileImportKind.wireguardConf => _seedOutcome(
        () => _seedFromWireguardConf(text, fileName: file.name),
        logMessage: logMessage,
      ),
      ProxyFileImportKind.singboxOutboundJson => await _consumeSingboxJson(
        text,
        fileName: file.name,
        defaultName: defaultName,
        logMessage: logMessage,
      ),
    };
  }

  /// One proxy from sing-box JSON goes to the editor; several are validated
  /// and imported as they are.
  Future<ProxyInputOutcome> _consumeSingboxJson(
    String text, {
    required String? fileName,
    required ProxyImportDefaultName defaultName,
    required String logMessage,
  }) async {
    final SingboxJsonSeeds parsed;
    try {
      parsed = seedsFromSingboxJson(
        text,
        fallbackName: fileName == null ? null : _stripExtension(fileName),
      );
    } on FormatException catch (error, stackTrace) {
      logger.e(logMessage, error: error, stackTrace: stackTrace);
      return ProxyInputError(error);
    }

    final SingboxJsonSeeds(:seeds, :skipped) = parsed;
    if (seeds.length == 1 && skipped == 0) return ProxyInputSeed(seeds.single);
    return await _importSeeds(
      seeds,
      skipped: skipped,
      defaultName: defaultName,
    );
  }

  /// Validates and stores each of [seeds]; one that fails for any reason is
  /// counted in [ProxyInputImportedMany.skipped], on top of the [skipped] the
  /// config already had.
  ///
  /// A failure is per proxy, never for the whole import: by the time one
  /// fails, the ones before it are stored, and an error that escaped here
  /// said nothing about them.
  Future<ProxyInputOutcome> _importSeeds(
    List<ProxyProfileSeed> seeds, {
    required int skipped,
    required ProxyImportDefaultName defaultName,
  }) async {
    final created = <ProxyProfile>[];
    final notes = <ImportedProfileNote>[];
    var skippedCount = skipped;

    for (final (index, seed) in seeds.indexed) {
      final name = seed.name ?? defaultName(index + 1);
      try {
        if (await _importSeed(seed, name: name) case final profile?) {
          created.add(profile);
          for (final note in seed.notes) {
            notes.add((profileName: profile.name, note: note));
          }
        } else {
          skippedCount += 1;
        }
      } catch (error, stackTrace) {
        logger.e(
          'Failed to import proxy "$name"',
          error: error,
          stackTrace: stackTrace,
        );
        skippedCount += 1;
      }
    }

    return ProxyInputImportedMany(created, skipped: skippedCount, notes: notes);
  }

  /// [seed] stored as a profile, or null when it does not validate.
  Future<ProxyProfile?> _importSeed(
    ProxyProfileSeed seed, {
    required String name,
  }) async {
    final spec = singboxProxyFormSpecs[seed.type]!;
    if (spec.validate(seed.values) != null) return null;

    final configJson = spec.toConfigJson(
      seed.values,
      baseConfigJson: seed.baseConfigJson,
    );
    final secretJson = spec.toSecretJson(
      seed.values,
      baseConfigJson: seed.baseConfigJson,
    );

    // What the editor checks before saving, so a bulk import cannot store a
    // profile the editor would have refused.
    final validationMessage = await ref
        .read(singboxProxyRuntimeRepositoryProvider.notifier)
        .validateProfileDraft(
          ProxyProfile(
            id: uuid.v4(),
            name: name,
            type: seed.type,
            configJson: configJson,
            dnsOverrideJson: seed.dnsOverrideJson,
            autostart: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          secretJson: secretJson,
        );
    if (validationMessage != null) {
      logger.w('Skipped imported proxy "$name": $validationMessage');
      return null;
    }

    return await ref
        .read(singboxProxyProfilesRepositoryProvider.notifier)
        .createProfile(
          name: name,
          type: seed.type,
          configJson: configJson,
          secretJson: secretJson,
          dnsOverrideJson: seed.dnsOverrideJson,
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
      return ProxyInputError(error);
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
      return ProxyInputError(error);
    }
  }

  Future<String> _readFileText(PlatformFile file) async {
    final bytes = await file.readAsBytes();
    return utf8.decode(bytes, allowMalformed: true);
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
  final extraDnsServers = imported.extraDnsServers;
  final splitTunnel = imported.splitTunnelAllowedIps;

  return ProxyProfileSeed(
    type: SingboxProxyProfileType.wireguard,
    name: _stripExtension(fileName),
    values: imported.values,
    dnsOverrideJson: dnsOverrideJson,
    notes: [
      if (dnsAddress != null && extraDnsServers.isNotEmpty)
        ProxyImportExtraDnsServers(
          used: imported.dnsServers.first,
          dropped: extraDnsServers,
        ),
      if (splitTunnel != null) ProxyImportSplitTunnel(splitTunnel),
    ],
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
