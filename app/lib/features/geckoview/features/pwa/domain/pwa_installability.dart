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

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/extensions/uri.dart';

/// Display modes that are valid for installable PWAs per W3C spec.
const _validDisplayModes = {
  'standalone',
  'fullscreen',
  'minimal-ui',
  'window-controls-overlay',
};

/// Determines if a PWA manifest meets installability criteria per W3C spec.
///
/// A web app is installable if:
/// 1. Served over HTTPS (or localhost for development)
/// 2. Has a valid manifest with required fields:
///    - name (or short_name)
///    - start_url (must be same-origin and within scope)
///    - display mode (standalone, fullscreen, minimal-ui, or
///      window-controls-overlay)
/// 3. start_url is within the scope
/// 4. prefer_related_applications is not true
bool isManifestInstallable(PwaManifest manifest) {
  final currentUrl = Uri.tryParse(manifest.currentUrl);
  final startUrl = Uri.tryParse(manifest.startUrl);

  if (currentUrl == null) {
    return false;
  }

  // Check HTTPS requirement (relaxed for localhost)
  final isSecure =
      currentUrl.isHttps || (currentUrl.isHttp && currentUrl.isLocalhost);

  if (!isSecure) {
    return false;
  }

  // prefer_related_applications must not be true
  if (manifest.preferRelatedApplications) {
    return false;
  }

  // Check required manifest fields
  final hasValidName =
      manifest.name?.isNotEmpty == true ||
      manifest.shortName?.isNotEmpty == true;

  // W3C §1.10.6: start_url must be same-origin as the document URL
  final hasValidStartUrl =
      startUrl != null && _isSameOrigin(startUrl, currentUrl);

  final hasValidDisplay =
      manifest.display != null &&
      _validDisplayModes.contains(manifest.display!.toLowerCase());

  // Check that start_url is within scope
  final isInScope =
      hasValidStartUrl &&
      _isStartUrlInScope(startUrl, manifest.scope.mapNotNull(Uri.tryParse));

  return hasValidName && hasValidStartUrl && hasValidDisplay && isInScope;
}

/// Returns true if two URLs share the same origin (scheme + host + port).
bool _isSameOrigin(Uri uri1, Uri uri2) {
  try {
    return uri1.scheme == uri2.scheme &&
        uri1.host == uri2.host &&
        uri1.port == uri2.port;
  } catch (e) {
    return false;
  }
}

/// Checks if startUrl is within scope using URL path containment.
///
/// Per W3C spec: when scope is absent, the default scope is the start_url
/// with its last path segment, query, and fragment removed.
/// Scope matching uses path-prefix comparison on `/` boundaries.
bool _isStartUrlInScope(Uri startUri, Uri? scopeUri) {
  try {
    if (scopeUri == null) {
      // Per W3C: default scope = start_url with filename/query/fragment removed
      // The start_url is trivially within its own default scope.
      return true;
    }

    // Must be same origin
    if (startUri.scheme != scopeUri.scheme ||
        startUri.host != scopeUri.host ||
        startUri.port != scopeUri.port) {
      return false;
    }

    // Path containment: scope path must be a prefix of start_url path
    // on a `/` boundary to avoid "/app" matching "/application"
    final scopePath = scopeUri.path.endsWith('/')
        ? scopeUri.path
        : '${scopeUri.path}/';
    final startPath = startUri.path.endsWith('/')
        ? startUri.path
        : '${startUri.path}/';

    return startPath.startsWith(scopePath) || startUri.path == scopeUri.path;
  } catch (e) {
    return false;
  }
}
