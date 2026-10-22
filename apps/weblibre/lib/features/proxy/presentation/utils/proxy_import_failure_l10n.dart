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
import 'package:flutter/widgets.dart';
import 'package:weblibre/core/branding/proxy_brands.dart';
import 'package:weblibre/features/proxy/data/models/proxy_import_failure.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

extension ProxyImportErrorL10n on FormatException {
  /// What to tell the user about an import that failed with this error.
  ///
  /// Only a [ProxyImportFailure] is translated. Any other [FormatException]
  /// comes from a parser that has no structured errors yet, and its own
  /// message is all there is.
  String describe(BuildContext context) {
    final failure = this;
    if (failure is! ProxyImportFailure) return message;

    final l10n = AppLocalizations.of(context);
    return switch (failure.kind) {
      ProxyImportFailureKind.fileUnreadable => l10n.proxy_importFileUnreadable(
        failure.detail ?? '',
      ),
      ProxyImportFailureKind.invalidJson => l10n.proxy_importInvalidJson(
        failure.detail ?? '',
      ),
      ProxyImportFailureKind.notJsonObject => l10n.proxy_importNotJsonObject,
      ProxyImportFailureKind.noOutbounds => l10n.proxy_importNoOutbounds,
      ProxyImportFailureKind.notAList => l10n.proxy_importNotAList(
        failure.detail ?? '',
      ),
      ProxyImportFailureKind.noImportableProxy =>
        l10n.proxy_importNoImportableProxy,
      ProxyImportFailureKind.missingType => l10n.proxy_importMissingType,
      ProxyImportFailureKind.unsupportedType =>
        l10n.proxy_importUnsupportedType(failure.detail ?? ''),
      ProxyImportFailureKind.endpointWithoutPeers =>
        l10n.proxy_importEndpointWithoutPeers(wireGuardBrand),
      ProxyImportFailureKind.endpointWithSeveralPeers =>
        l10n.proxy_importEndpointWithSeveralPeers(
          failure.count ?? 0,
          wireGuardBrand,
        ),
      ProxyImportFailureKind.peerNotObject => l10n.proxy_importPeerNotObject(
        wireGuardBrand,
      ),
      ProxyImportFailureKind.wireguardMissingSections =>
        l10n.proxy_importWireguardMissingSections(wireGuardBrand),
      ProxyImportFailureKind.wireguardSeveralInterfaces =>
        l10n.proxy_importWireguardSeveralInterfaces(wireGuardBrand),
      ProxyImportFailureKind.wireguardSeveralPeers =>
        l10n.proxy_importWireguardSeveralPeers(
          failure.count ?? 0,
          wireGuardBrand,
        ),
      ProxyImportFailureKind.wireguardEmptySection =>
        l10n.proxy_importWireguardEmptySection(wireGuardBrand),
      ProxyImportFailureKind.wireguardEntryOutsideSection =>
        l10n.proxy_importWireguardEntryOutsideSection(wireGuardBrand),
      ProxyImportFailureKind.wireguardInvalidLine =>
        l10n.proxy_importWireguardInvalidLine(
          wireGuardBrand,
          failure.detail ?? '',
        ),
      ProxyImportFailureKind.wireguardInvalidEndpoint =>
        l10n.proxy_importWireguardInvalidEndpoint(wireGuardBrand),
      ProxyImportFailureKind.detourThroughOtherOutbound =>
        l10n.proxy_importDetourThroughOtherOutbound(failure.detail ?? ''),
      ProxyImportFailureKind.unresolvedDetour =>
        l10n.proxy_importUnresolvedDetour(failure.detail ?? ''),
    };
  }
}
