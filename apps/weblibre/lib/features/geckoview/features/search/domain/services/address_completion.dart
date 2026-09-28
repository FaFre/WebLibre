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

/// Typed text the completion keeps as written: an optional scheme, then an
/// optional `www.`.
final _typedPrefix = RegExp(
  r'^(?:(?<scheme>[a-z][a-z0-9+.-]*)://)?(?<www>www\.)?',
  caseSensitive: false,
);

/// The inline ghost-text completion that one of [candidates] offers for
/// [input], or null when none of them completes it.
///
/// Candidates are tried in order, so pass them best first. A candidate
/// completes [input] when its address continues what was typed:
///
/// - Without a `/` typed, only the host is completed (`git` → `github.com`),
///   like the engine's own domain autofill. A leading `www.` on the host is
///   skipped, so `git` still finds `www.github.com`.
/// - Once a `/` is typed the path is completed too, one segment at a time
///   (`github.com/we` → `github.com/weblibre/`), never into the query string or
///   fragment.
///
/// A scheme or `www.` the user typed is kept and has to match the candidate;
/// completing `http://` into an `https://` address would silently change what
/// gets opened. The result always starts with [input] exactly as typed, which
/// is what the field needs to draw the rest as ghost text.
String? addressCompletionFor(String input, Iterable<Uri> candidates) {
  if (input.isEmpty || input.contains(RegExp(r'\s'))) return null;

  final prefixMatch = _typedPrefix.firstMatch(input)!;
  final typedScheme = prefixMatch.namedGroup('scheme')?.toLowerCase();
  final typedWww = prefixMatch.namedGroup('www') != null;
  final rest = input.substring(prefixMatch.end).toLowerCase();
  if (rest.isEmpty) return null;

  for (final candidate in candidates) {
    if (candidate.scheme != 'http' && candidate.scheme != 'https') continue;
    if (typedScheme != null && typedScheme != candidate.scheme) continue;

    var host = candidate.host.toLowerCase();
    if (host.isEmpty) continue;
    if (host.startsWith('www.')) {
      host = host.substring(4);
    } else if (typedWww) {
      continue;
    }

    final hostPart = candidate.hasPort ? '$host:${candidate.port}' : host;

    final String completion;
    if (!rest.contains('/')) {
      completion = hostPart;
    } else {
      final address =
          '$hostPart${candidate.path.isEmpty ? '/' : candidate.path}';
      if (!address.toLowerCase().startsWith(rest)) continue;

      final nextSlash = address.indexOf('/', rest.length);
      completion = nextSlash == -1
          ? address
          : address.substring(0, nextSlash + 1);
    }

    if (completion.length <= rest.length) continue;
    if (!completion.toLowerCase().startsWith(rest)) continue;

    return input + completion.substring(rest.length);
  }

  return null;
}
