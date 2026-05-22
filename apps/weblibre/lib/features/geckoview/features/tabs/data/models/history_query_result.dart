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
import 'package:fast_equatable/fast_equatable.dart';

/// FTS5 hit against the local history index. Highlight/snippet markers are
/// embedded inline (the same `***`-style markers used for tab results) so the
/// renderer in `utils/text_highlight.dart` can be reused as-is.
class HistoryQueryResult with FastEquatable {
  final String urlCanonical;
  final String urlHost;
  final String? urlPath;
  final String? title;

  /// `snippet()` over `extracted_content_plain`. May contain highlight
  /// markers if the FTS query matched within the extracted content.
  final String? extractedContent;

  /// `snippet()` over `full_content_plain`.
  final String? fullContent;

  /// Smaller is more relevant (BM25 convention). Combine with frecency from
  /// Places at the call site to produce the final ranking.
  final double weightedRank;

  final DateTime observedAt;

  HistoryQueryResult({
    required this.urlCanonical,
    required this.urlHost,
    required this.urlPath,
    required this.title,
    required this.extractedContent,
    required this.fullContent,
    required this.weightedRank,
    required this.observedAt,
  });

  @override
  List<Object?> get hashParameters => [
    urlCanonical,
    urlHost,
    urlPath,
    title,
    extractedContent,
    fullContent,
    weightedRank,
    observedAt,
  ];
}
