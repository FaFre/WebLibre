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
enum ProxyImportFailureKind {
  /// The file could not be read; [ProxyImportFailure.detail] says why.
  fileUnreadable,

  /// Not JSON at all; [ProxyImportFailure.detail] is the decoder's complaint.
  invalidJson,
  notJsonObject,

  /// A JSON object that is neither an outbound or endpoint nor a config
  /// holding some.
  noOutbounds,

  /// A config key that has to be a list is not; [ProxyImportFailure.detail]
  /// is the key.
  notAList,

  /// A config whose outbounds are all of kinds that are not proxies.
  noImportableProxy,
  missingType,

  /// An outbound type the form has no spec for; [ProxyImportFailure.detail]
  /// is the type.
  unsupportedType,
  endpointWithoutPeers,

  /// [ProxyImportFailure.count] is how many peers it has.
  endpointWithSeveralPeers,
  peerNotObject,
  wireguardMissingSections,
  wireguardSeveralInterfaces,

  /// [ProxyImportFailure.count] is how many [Peer] sections it has.
  wireguardSeveralPeers,
  wireguardEmptySection,
  wireguardEntryOutsideSection,

  /// [ProxyImportFailure.detail] is the line.
  wireguardInvalidLine,
  wireguardInvalidEndpoint,

  /// An outbound that dials through another outbound of its config — a
  /// chain WebLibre cannot run. [ProxyImportFailure.detail] is that
  /// outbound's tag.
  detourThroughOtherOutbound,

  /// An outbound on its own, without the config its `detour` is defined in,
  /// so what that detour does cannot be told. [ProxyImportFailure.detail] is
  /// the detour's tag.
  unresolvedDetour,
}

/// Why text or a file could not be imported as a proxy.
///
/// A [FormatException], so the parsers throw it where they throw any other
/// and callers catching those keep working. It carries no display text: what
/// the user sees is translated from [kind] where it is shown
/// (`presentation/utils/proxy_import_failure_l10n.dart`).
class ProxyImportFailure implements FormatException {
  final ProxyImportFailureKind kind;
  final int? count;
  final String? detail;

  const ProxyImportFailure(this.kind, {this.count, this.detail});

  /// Diagnostic text for logs, never shown: users see [kind] translated.
  @override
  String get message => [
    kind.name,
    if (count != null) 'count: $count',
    if (detail != null) 'detail: $detail',
  ].join(', ');

  @override
  Object? get source => null;

  @override
  int? get offset => null;

  @override
  String toString() => 'ProxyImportFailure: $message';
}
