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

import 'package:http/http.dart' as http;
import 'package:weblibre/features/proxy/data/parsers/singbox_proxy_uri.dart';

/// One line in a subscription that we attempted to parse. Either a usable
/// [SingboxProxyUriImport] or the [FormatException]-style error explaining
/// why the line failed to parse, so the UI can show a per-line outcome
/// instead of silently dropping nodes.
sealed class SubscriptionImportEntry {
  final String rawLine;

  const SubscriptionImportEntry({required this.rawLine});
}

class SubscriptionEntrySuccess extends SubscriptionImportEntry {
  final SingboxProxyUriImport imported;

  const SubscriptionEntrySuccess({
    required super.rawLine,
    required this.imported,
  });
}

class SubscriptionEntryFailure extends SubscriptionImportEntry {
  final Object error;

  const SubscriptionEntryFailure({required super.rawLine, required this.error});
}

class SubscriptionImportResult {
  final List<SubscriptionImportEntry> entries;

  const SubscriptionImportResult(this.entries);

  Iterable<SubscriptionEntrySuccess> get successes =>
      entries.whereType<SubscriptionEntrySuccess>();

  Iterable<SubscriptionEntryFailure> get failures =>
      entries.whereType<SubscriptionEntryFailure>();
}

/// Fetches a v2rayN-style subscription URL and parses its contents.
///
/// Most subscription servers serve a base64-encoded blob whose decoded body is
/// a newline-delimited list of `ss://`, `vless://`, etc. URIs. Some serve the
/// raw newline-delimited list. We try both: base64 first, then raw, and use
/// whichever produces parseable URIs.
Future<SubscriptionImportResult> fetchSubscription(
  Uri url, {
  http.Client? client,
}) async {
  final ownsClient = client == null;
  final actualClient = client ?? http.Client();
  try {
    final response = await actualClient
        .get(url, headers: {'User-Agent': 'WebLibre/sing-box-subscriber'})
        .timeout(const Duration(seconds: 30));
    if (response.statusCode >= 400) {
      throw http.ClientException(
        'Subscription returned HTTP ${response.statusCode}.',
        url,
      );
    }
    return parseSubscriptionBody(response.body);
  } finally {
    if (ownsClient) actualClient.close();
  }
}

/// Decodes a subscription body into individual proxy entries. Public so the
/// UI can preview a pasted body without making a network call.
SubscriptionImportResult parseSubscriptionBody(String body) {
  final lines = _tryBase64Decode(body) ?? body;
  final entries = <SubscriptionImportEntry>[];
  for (final raw in const LineSplitter().convert(lines)) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    try {
      entries.add(
        SubscriptionEntrySuccess(
          rawLine: line,
          imported: importSingboxProxyUri(line),
        ),
      );
    } on FormatException catch (error) {
      entries.add(SubscriptionEntryFailure(rawLine: line, error: error));
    }
  }
  return SubscriptionImportResult(entries);
}

String? _tryBase64Decode(String body) {
  // Subscription bodies are base64 (sometimes URL-safe) without padding.
  final stripped = body.replaceAll(RegExp(r'\s'), '');
  if (stripped.isEmpty) return null;
  // Only attempt if the body looks like base64 — bail out if it contains
  // characters never present in base64 alphabets.
  if (!RegExp(r'^[A-Za-z0-9+/_=-]+$').hasMatch(stripped)) return null;
  try {
    return utf8.decode(base64.decode(base64.normalize(stripped)));
  } catch (_) {
    try {
      return utf8.decode(base64Url.decode(base64Url.normalize(stripped)));
    } catch (_) {
      return null;
    }
  }
}
