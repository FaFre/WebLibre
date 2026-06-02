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

import 'package:weblibre/utils/uri_input_parser.dart';
import 'package:weblibre/utils/uri_policy.dart';

Uri? tryParseUrl(String? input, {bool eagerParsing = false}) {
  return parseUserInputUrl(
    input,
    policy: SchemePolicy.internalIntent,
    allowSchemelessHosts: eagerParsing,
  );
}

/// Generic subdomain labels that don't identify a distinct site. Search engines
/// routinely redirect between these (e.g. `bing.com` → `www.bing.com`,
/// `www.youtube.com` → `m.youtube.com`), so they are treated as equivalent when
/// matching a live URL against a bang template host.
const _genericHostPrefixes = {'www', 'm', 'mobile'};

/// Strips a single leading generic subdomain label ([_genericHostPrefixes])
/// from [host] so hosts differing only by such a prefix compare equal.
///
/// `www.bing.com` and `bing.com` → `bing.com`; `m.youtube.com` → `youtube.com`.
/// Non-generic subdomains (e.g. `cn.bing.com`) are left untouched.
String normalizeHost(String host) {
  final lower = host.toLowerCase();
  final dot = lower.indexOf('.');
  if (dot <= 0) return lower;

  final label = lower.substring(0, dot);
  if (_genericHostPrefixes.contains(label)) {
    return lower.substring(dot + 1);
  }
  return lower;
}

/// All host spellings that should be considered the same site as [host] for the
/// purposes of bang template lookup: the normalized base plus each generic
/// subdomain variant.
Set<String> hostVariants(String host) {
  final base = normalizeHost(host);
  return {base, for (final prefix in _genericHostPrefixes) '$prefix.$base'};
}
