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

/// Normalizes a URL's host for shortcut blacklist matching.
///
/// Lowercases, drops the port and strips a single leading `www.`, so hiding
/// `https://www.Example.com:443/x` also hides `http://example.com/y`.
///
/// Deliberately *not* registrable-domain (eTLD+1) matching: that needs the
/// public suffix list, and collapsing `foo.github.io` into `github.io` would
/// hide unrelated sites. Subdomains stay distinct — hiding `discord.com` does
/// not hide `app.discord.com`.
///
/// `Uri.host` is already empty for URLs without an authority (`about:blank`,
/// `data:`), which yields an empty string here and therefore never matches.
String canonicalTopSiteHost(Uri url) {
  final host = url.host.toLowerCase();
  if (host.isEmpty) {
    return '';
  }

  const wwwPrefix = 'www.';
  // Only strip when something remains, so a literal host of "www." is kept
  // rather than collapsing to the empty string that matches nothing.
  if (host.startsWith(wwwPrefix) && host.length > wwwPrefix.length) {
    return host.substring(wwwPrefix.length);
  }

  return host;
}
