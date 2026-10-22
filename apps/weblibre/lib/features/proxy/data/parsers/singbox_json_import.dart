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
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/proxy/data/forms/singbox_form_spec.dart';
import 'package:weblibre/features/proxy/data/forms/singbox_form_specs.dart';
import 'package:weblibre/features/proxy/data/models/proxy_import_failure.dart';
import 'package:weblibre/features/proxy/data/models/proxy_profile_seed.dart';
import 'package:weblibre/features/proxy/data/parsers/cidr.dart';

/// What [seedsFromSingboxJson] could read, and how many proxies it could not.
typedef SingboxJsonSeeds = ({List<ProxyProfileSeed> seeds, int skipped});

/// Outbound types that are not proxies of their own: routing, blocking and
/// grouping in a full config, with nothing to connect to.
const _nonProxyOutboundTypes = {
  'direct',
  'block',
  'dns',
  'selector',
  'urltest',
};

/// The DNS server every runtime has (`SingboxConfigBuilder`'s bootstrap), so
/// a `domain_resolver` naming it still resolves.
const _runtimeDnsServerTag = 'local';

/// Seeds from sing-box JSON: one outbound or endpoint object, or a whole
/// config, from whose `outbounds` and `endpoints` every proxy is taken.
///
/// Only a single object used to be understood. A full config — what "sing-box
/// JSON" usually means, and what the import offers — failed with "missing a
/// top-level type".
///
/// Seeds are named after their tag, or else after [fallbackName]; with
/// neither they have no name, which the importer supplies.
SingboxJsonSeeds seedsFromSingboxJson(String text, {String? fallbackName}) {
  final json = _decodeObject(text);
  if (json['type'] is String) {
    return (
      seeds: [_seedFromObject(json, fallbackName: fallbackName)],
      skipped: 0,
    );
  }
  return _seedsFromConfig(json, fallbackName: fallbackName);
}

Map<String, dynamic> _decodeObject(String text) {
  final Object? decoded;
  try {
    decoded = jsonDecode(text);
  } on FormatException catch (error) {
    throw ProxyImportFailure(
      ProxyImportFailureKind.invalidJson,
      detail: error.message,
    );
  }
  if (decoded is! Map<String, dynamic>) {
    throw const ProxyImportFailure(ProxyImportFailureKind.notJsonObject);
  }
  return decoded;
}

/// Every proxy in a whole sing-box [config].
///
/// A proxy that cannot be read — a WireGuard endpoint with two peers, say — is
/// counted as skipped: one of them used to fail the whole config, the usable
/// proxies with it. Only when none can be read is the first one's failure the
/// answer.
SingboxJsonSeeds _seedsFromConfig(
  Map<String, dynamic> config, {
  required String? fallbackName,
}) {
  final items = [
    ..._listField(config, 'outbounds'),
    ..._listField(config, 'endpoints'),
  ].whereType<Map<String, dynamic>>();
  if (items.isEmpty) {
    throw const ProxyImportFailure(ProxyImportFailureKind.noOutbounds);
  }

  final proxies = items.where(_isImportableProxy).toList();
  if (proxies.isEmpty) {
    throw const ProxyImportFailure(ProxyImportFailureKind.noImportableProxy);
  }

  final outboundsByTag = {
    for (final item in items)
      if (item['tag'] case final String tag) tag: item,
  };

  final seeds = <ProxyProfileSeed>[];
  ProxyImportFailure? firstFailure;
  for (final (index, item) in proxies.indexed) {
    final name = fallbackName == null || proxies.length == 1
        ? fallbackName
        : '$fallbackName ${index + 1}';
    try {
      seeds.add(
        _seedFromObject(
          item,
          fallbackName: name,
          outboundsByTag: outboundsByTag,
        ),
      );
    } on ProxyImportFailure catch (failure) {
      logger.w('Skipped unreadable proxy in sing-box config: $failure');
      firstFailure ??= failure;
    }
  }
  if (seeds.isEmpty) throw firstFailure!;

  return (seeds: seeds, skipped: proxies.length - seeds.length);
}

/// [config]'s [key] as a list, empty when absent.
List<dynamic> _listField(Map<String, dynamic> config, String key) {
  return switch (config[key]) {
    null => const [],
    final List<dynamic> items => items,
    _ => throw ProxyImportFailure(ProxyImportFailureKind.notAList, detail: key),
  };
}

bool _isImportableProxy(Map<String, dynamic> item) => switch (item['type']) {
  final String type =>
    !_nonProxyOutboundTypes.contains(type) && _specFor(type) != null,
  _ => false,
};

SingboxProxyFormSpec? _specFor(String outboundType) {
  for (final spec in singboxProxyFormSpecs.values) {
    if (spec.outboundType == outboundType) return spec;
  }
  return null;
}

/// [item] as the seed of a profile.
///
/// [outboundsByTag] is every outbound in the config [item] came from, by tag,
/// to tell what its `detour` dials through; empty for an object on its own.
ProxyProfileSeed _seedFromObject(
  Map<String, dynamic> item, {
  required String? fallbackName,
  Map<String, Map<String, dynamic>> outboundsByTag = const {},
}) {
  final outboundType = item['type'];
  if (outboundType is! String) {
    throw const ProxyImportFailure(ProxyImportFailureKind.missingType);
  }
  final spec =
      _specFor(outboundType) ??
      (throw ProxyImportFailure(
        ProxyImportFailureKind.unsupportedType,
        detail: outboundType,
      ));

  // A WireGuard endpoint — sing-box's current format — is turned into the
  // outbound-style object profiles store, which the runtime converts back.
  final object = outboundType == 'wireguard' && item.containsKey('peers')
      ? _wireguardEndpointAsOutbound(item)
      : {...item};
  final tag = object.remove('tag');
  _dropSourceConfigTags(object, outboundsByTag);

  final values = spec.valuesFromJson(configJson: jsonEncode(object));
  return ProxyProfileSeed(
    type: spec.type,
    name: tag is String && tag.isNotEmpty ? tag : fallbackName,
    values: values,
    baseConfigJson: jsonEncode(object),
    notes: [?_splitTunnelNote(spec, values)],
  );
}

/// Removes from [object] the references to other tags of its source config.
///
/// Those tags do not exist in the runtime a profile runs in, and sing-box
/// refuses a config that names one that is missing:
///  * A `detour` is refused, not dropped. It names the proxy this one dials
///    through, and without it the saved profile would dial the server
///    directly — showing it the address the chain was there to hide. Only a
///    detour into a bare `direct` outbound goes ([_isBareDirect]), since that
///    is what dialing without one does. An object on its own has no config
///    to look the tag up in, and its detour is refused whatever it is called:
///    a `direct` outbound can bind an interface or a routing mark, and
///    dropping the detour would quietly take the proxy off that route.
///  * A `domain_resolver` only picks the server that resolves the proxy's
///    hostname, so it goes, and the runtime's bootstrap resolver — the
///    browser's DoH — takes over. One naming that bootstrap stays.
void _dropSourceConfigTags(
  Map<String, dynamic> object,
  Map<String, Map<String, dynamic>> outboundsByTag,
) {
  if (object['detour'] case final String detour) {
    if (outboundsByTag.isEmpty) {
      throw ProxyImportFailure(
        ProxyImportFailureKind.unresolvedDetour,
        detail: detour,
      );
    }
    if (!_isBareDirect(outboundsByTag[detour])) {
      throw ProxyImportFailure(
        ProxyImportFailureKind.detourThroughOtherOutbound,
        detail: detour,
      );
    }
    object.remove('detour');
  }

  final resolver = switch (object['domain_resolver']) {
    final String tag => tag,
    {'server': final String tag} => tag,
    _ => null,
  };
  if (resolver != null && resolver != _runtimeDnsServerTag) {
    object.remove('domain_resolver');
  }
}

/// Whether [outbound] is a `direct` outbound with nothing set but its tag:
/// one that dials exactly as no detour does.
///
/// A configured one does not. It can bind a network interface or a source
/// address, set a routing mark, or name its own resolver, and the proxy
/// dialing through it relies on that — without it the dial takes the default
/// network, which may not reach the server at all, or reach it by the route
/// the binding was there to avoid.
bool _isBareDirect(Map<String, dynamic>? outbound) {
  if (outbound == null || outbound['type'] != 'direct') return false;
  return outbound.keys.every((key) => key == 'type' || key == 'tag');
}

/// A note for a WireGuard tunnel that carries only some address ranges.
ProxyImportSplitTunnel? _splitTunnelNote(
  SingboxProxyFormSpec spec,
  Map<String, String> values,
) {
  if (spec.type != SingboxProxyProfileType.wireguard) return null;

  final allowedIps = splitTunnelRanges(
    (values['allowed_ips'] ?? '')
        .split('\n')
        .map((range) => range.trim())
        .where((range) => range.isNotEmpty)
        .toList(),
  );
  return allowedIps == null ? null : ProxyImportSplitTunnel(allowedIps);
}

/// [endpoint] (sing-box's `endpoints` format, with a `peers` list) as the
/// outbound-style object the WireGuard form and the runtime read.
Map<String, dynamic> _wireguardEndpointAsOutbound(
  Map<String, dynamic> endpoint,
) {
  final peers = endpoint['peers'];
  if (peers is! List || peers.isEmpty) {
    throw const ProxyImportFailure(ProxyImportFailureKind.endpointWithoutPeers);
  }
  if (peers.length > 1) {
    throw ProxyImportFailure(
      ProxyImportFailureKind.endpointWithSeveralPeers,
      count: peers.length,
    );
  }
  final peer = peers.single;
  if (peer is! Map<String, dynamic>) {
    throw const ProxyImportFailure(ProxyImportFailureKind.peerNotObject);
  }

  final outbound = {...endpoint}
    ..remove('peers')
    ..remove('address');
  void copy(String from, String to) {
    final value = peer[from];
    if (value != null) outbound[to] = value;
  }

  copy('address', 'server');
  copy('port', 'server_port');
  copy('public_key', 'peer_public_key');
  copy('pre_shared_key', 'pre_shared_key');
  copy('allowed_ips', 'allowed_ips');
  copy('persistent_keepalive_interval', 'persistent_keepalive_interval');
  copy('reserved', 'reserved');
  if (endpoint['address'] case final Object address) {
    outbound['local_address'] = address;
  }

  return outbound;
}
