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

/// Structural canonicalization helper used by both the local search index
/// (via SQLite custom functions) and any Dart-side ingestion code that wants
/// to dedupe URLs the same way the trigger does.
///
/// This intentionally does *not* apply url-cleaner rules. The cleaner depends
/// on a runtime-loaded JSON catalog with compiled regexes, which can't be
/// shared into the database isolate cheaply. URL-cleaner integration is
/// tracked as a follow-up; structural canonicalization handles the bulk of
/// dedup (scheme/host casing, fragments, default ports) and keeps the SQL
/// function pure-Dart and isolate-safe.
class CanonicalUrl {
  /// Canonical form used as the dedup key (history.url_canonical PK).
  final String canonical;

  /// Bare host, lowercased.
  final String host;

  /// Path component without query string. Empty string for bare-host URLs.
  final String path;

  const CanonicalUrl({
    required this.canonical,
    required this.host,
    required this.path,
  });
}

/// Schemes Places' `canAddUri` accepts. Anything else is rejected — internal
/// pages, javascript:/data:/blob: URIs etc. shouldn't enter the local index.
const _indexableSchemes = {'http', 'https'};

/// `about:reader?url=...` is the one allowed about: form.
bool _isAboutReader(Uri uri) => uri.scheme == 'about' && uri.path == 'reader';

/// Returns true if [rawUrl] is something the local search index should accept.
/// Mirrors `PlacesHistoryStorage.canAddUri` semantics.
bool isUrlIndexable(String rawUrl) {
  final uri = Uri.tryParse(rawUrl);
  if (uri == null || !uri.hasScheme) return false;
  if (_indexableSchemes.contains(uri.scheme)) return uri.host.isNotEmpty;
  if (_isAboutReader(uri)) return true;
  return false;
}

/// Canonicalize [rawUrl]. Returns `null` if the URL is unparseable or not
/// indexable.
CanonicalUrl? canonicalizeUrl(String rawUrl) {
  final uri = Uri.tryParse(rawUrl);
  if (uri == null || !uri.hasScheme) return null;
  if (!isUrlIndexable(rawUrl)) return null;

  if (_isAboutReader(uri)) {
    final query = uri.hasQuery ? '?${uri.query}' : '';
    return CanonicalUrl(
      canonical: 'about:reader$query',
      host: '',
      path: 'reader',
    );
  }

  // Lowercase scheme + host. Strip default ports. Strip fragment. Normalize
  // a bare-host trailing slash to empty so `https://example.com` and
  // `https://example.com/` collapse.
  final scheme = uri.scheme.toLowerCase();
  final host = uri.host.toLowerCase();
  final port = uri.hasPort && !_isDefaultPort(scheme, uri.port)
      ? ':${uri.port}'
      : '';
  final path = _normalizePath(uri.path);
  final query = uri.hasQuery ? '?${uri.query}' : '';

  final canonical = '$scheme://$host$port$path$query';

  return CanonicalUrl(canonical: canonical, host: host, path: path);
}

bool _isDefaultPort(String scheme, int port) =>
    (scheme == 'http' && port == 80) || (scheme == 'https' && port == 443);

String _normalizePath(String path) {
  if (path.isEmpty || path == '/') return '';
  return path;
}
