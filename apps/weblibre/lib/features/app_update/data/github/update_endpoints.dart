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
import 'package:weblibre/features/app_update/data/metadata/signed_envelope.dart';

/// Compiled hosts, path prefixes and limits (plan 5.6, 7.2). Release builds
/// have no runtime or dart-define override; tests construct their own.
class UpdateEndpoints {
  const UpdateEndpoints({
    required this.catalogueHost,
    required this.artifactHost,
    required this.artifactPathPrefix,
    required this.artifactRedirectHosts,
    required this.releaseNotesPrefix,
    this.port,
  });

  static const production = UpdateEndpoints(
    catalogueHost: 'updates.weblibre.eu',
    artifactHost: 'github.com',
    artifactPathPrefix: '/FaFre/WebLibre/releases/download/',
    // GitHub's release asset hosts. Confirm against real responses (Phase 4).
    artifactRedirectHosts: {
      'objects.githubusercontent.com',
      'release-assets.githubusercontent.com',
    },
    releaseNotesPrefix: 'https://github.com/FaFre/WebLibre/releases/tag/',
  );

  final String catalogueHost;
  final String artifactHost;
  final String artifactPathPrefix;
  final Set<String> artifactRedirectHosts;
  final String releaseNotesPrefix;

  /// Only for tests against a local fixture server; production uses 443.
  final int? port;

  Uri catalogueUrl(String packageId) => Uri(
    scheme: 'https',
    host: catalogueHost,
    port: port,
    path: '/v1/$packageId/catalogue.json',
  );

  bool _baseOk(Uri uri) =>
      uri.scheme == 'https' &&
      uri.userInfo.isEmpty &&
      (port == null ? !uri.hasPort || uri.port == 443 : uri.port == port) &&
      uri.fragment.isEmpty;

  bool isCatalogueUrl(Uri uri) => _baseOk(uri) && uri.host == catalogueHost;

  /// The first hop of an artifact download.
  bool isArtifactUrl(Uri uri) =>
      _baseOk(uri) &&
      uri.host == artifactHost &&
      uri.path.startsWith(artifactPathPrefix) &&
      !uri.path.contains('..');

  /// Where an artifact download may be redirected.
  bool isArtifactRedirect(Uri uri) =>
      _baseOk(uri) &&
      (artifactRedirectHosts.contains(uri.host) || isArtifactUrl(uri));

  bool isReleaseNotesUrl(Uri uri) {
    final text = uri.toString();
    return text.startsWith(releaseNotesPrefix) &&
        uri.scheme == 'https' &&
        uri.userInfo.isEmpty &&
        !uri.path.contains('..');
  }
}

/// Fetch limits (7.2).
class FetchLimits {
  const FetchLimits({
    this.catalogueBytes = maxEnvelopeBytes,
    this.catalogueTimeout = const Duration(seconds: 20),
    this.artifactHardCap = 512 * 1024 * 1024,
    this.connectTimeout = const Duration(seconds: 30),
    this.stallTimeout = const Duration(seconds: 60),
    this.maxRedirects = 5,
    this.attempts = 3,
  });

  final int catalogueBytes;
  final Duration catalogueTimeout;
  final int artifactHardCap;
  final Duration connectTimeout;
  final Duration stallTimeout;
  final int maxRedirects;
  final int attempts;
}
