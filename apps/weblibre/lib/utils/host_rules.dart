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

/// Helpers for per-site rule lists keyed by host (e.g. gesture exclusions,
/// per-site desktop mode). Entries are stored as bare lowercase hosts and match
/// a page's host exactly or as a parent domain.
///
/// Note: this is intentionally distinct from `uri_parser.dart`'s `normalizeHost`
/// /`hostVariants`, which strip generic `www`/`m`/`mobile` prefixes for fuzzy
/// bang-template matching — a different semantic that must not be conflated.

/// Normalises a user-entered site into a bare lowercase host, e.g.
/// `https://News.example.com/foo` → `news.example.com`. Accepts either a full
/// URL or a bare host, and validates the result with the same rules the address
/// bar uses ([isValidHostCandidate]). Returns null for input without a valid
/// host.
String? normalizeRuleHost(String input) {
  final trimmed = input.trim().toLowerCase();
  if (trimmed.isEmpty) return null;

  final candidate = trimmed.contains('://') ? trimmed : 'https://$trimmed';
  final host = Uri.tryParse(candidate)?.host;
  if (host == null || host.isEmpty) return null;

  return isValidHostCandidate(host) ? host : null;
}

/// Whether [url] is covered by any entry in [patterns]. An entry matches the
/// URL's host exactly or as a parent domain (so `example.com` also covers
/// `m.example.com`).
bool hostMatchesRule(Uri url, List<String> patterns) {
  final host = url.host.toLowerCase();
  if (host.isEmpty) return false;

  for (final entry in patterns) {
    final pattern = entry.toLowerCase();
    if (pattern.isEmpty) continue;
    if (host == pattern || host.endsWith('.$pattern')) return true;
  }
  return false;
}

/// Returns an entry in [patterns] that covers [url]'s host as a *parent domain*
/// (a strict suffix, not an exact match), or null if none does. Used to detect
/// when a page is governed by a broader rule that a per-site toggle for the
/// exact host cannot override — e.g. `example.com` covering `m.example.com`.
/// (If both the exact host and a parent are listed, the parent is still
/// returned, since removing the exact entry would not clear the page.)
String? coveringParentRule(Uri url, List<String> patterns) {
  final host = url.host.toLowerCase();
  if (host.isEmpty) return null;

  for (final entry in patterns) {
    final pattern = entry.toLowerCase();
    if (pattern.isEmpty || pattern == host) continue;
    if (host.endsWith('.$pattern')) return pattern;
  }
  return null;
}
