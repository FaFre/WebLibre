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

import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/features/app_update/data/github/update_endpoints.dart';
import 'package:weblibre/features/app_update/domain/entities/release_metadata.dart';

class CatalogueInvalid implements Exception {
  const CatalogueInvalid(this.reason, {this.clientTooOld = false});

  final String reason;

  /// A schema this client doesn't know: an app update is needed to read it.
  final bool clientTooOld;

  @override
  String toString() => 'CatalogueInvalid: $reason';
}

/// Only the newest releases carry summaries (5.2).
const summarizedReleases = 5;

/// Parses a verified catalogue payload (5.2). The entities' generated
/// `fromJson`s read the structure (see `release_metadata.dart`); this adds
/// what needs the reader's context, and what spans releases.
class CatalogueCodec {
  const CatalogueCodec({
    required this.packageId,
    this.endpoints = UpdateEndpoints.production,
  });

  final String packageId;
  final UpdateEndpoints endpoints;

  ReleaseCatalogue decode(List<int> payload) {
    final Object? json;
    try {
      json = jsonDecode(utf8.decode(payload));
    } on FormatException catch (e) {
      throw CatalogueInvalid('malformed payload: ${e.message}');
    }
    if (json is! Map<String, dynamic>) {
      throw const CatalogueInvalid('payload is not an object');
    }

    final schema = json['schemaVersion'];
    if (schema != 1) {
      throw CatalogueInvalid(
        'schemaVersion $schema',
        clientTooOld: schema is int && schema > 1,
      );
    }

    final ReleaseCatalogue parsed;
    try {
      parsed = ReleaseCatalogue.fromJson(json);
    } on CheckedFromJsonException catch (e) {
      throw CatalogueInvalid('${e.className}.${e.key}: ${e.message}');
    }

    if (parsed.packageId != packageId) {
      throw const CatalogueInvalid('catalogue for another package');
    }
    if (!parsed.expiresAt.isAfter(parsed.issuedAt)) {
      throw const CatalogueInvalid('expiresAt before issuedAt');
    }

    final sorted = [...parsed.releases]
      ..sort(
        (a, b) => b.logicalReleaseSequence.compareTo(a.logicalReleaseSequence),
      );
    // The newest releases keep their summaries, whatever order the payload
    // lists them in.
    final releases = [
      for (final (index, release) in sorted.indexed)
        release.copyWith(
          releaseNotes: release.releaseNotes.copyWith(
            url: _allowedNotesUrl(release.releaseNotes.url),
            summary: index < summarizedReleases
                ? release.releaseNotes.summary
                : const {},
          ),
        ),
    ];

    final sequences = releases.map((r) => r.logicalReleaseSequence).toSet();
    if (sequences.length != releases.length) {
      throw const CatalogueInvalid('duplicate release sequence');
    }
    // Across releases, not only within one: authorization looks a target up
    // by ID in the whole catalogue (`targetById`), and must find the one the
    // assessment came from.
    final targetIds = [
      for (final release in releases)
        for (final target in release.targets) target.id,
    ];
    if (targetIds.toSet().length != targetIds.length) {
      throw const CatalogueInvalid('duplicate target id');
    }

    return parsed.copyWith(releases: releases);
  }

  /// Only a link under the compiled prefix is shown (8.1).
  Uri? _allowedNotesUrl(Uri? url) =>
      url != null && endpoints.isReleaseNotesUrl(url) ? url : null;
}
