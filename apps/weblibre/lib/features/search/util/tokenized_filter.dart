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
typedef ToString<T> = String? Function(T);

class TokenizedFilter<T> {
  final Iterable<T> original;
  final List<T> filtered;

  static List<String> _tokenize(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .split(RegExp(r'\s+')) // Split on whitespace
        .where((word) => word.isNotEmpty)
        .toList();
  }

  static bool _matchTokens(
    List<String> queryTokens,
    List<String> targetTokens,
  ) {
    return queryTokens.every(
      (queryToken) =>
          targetTokens.any((targetToken) => targetToken.contains(queryToken)),
    );
  }

  static double _calculateScore(
    List<String> queryTokens,
    List<String> targetTokens,
  ) {
    if (queryTokens.isEmpty || targetTokens.isEmpty) return 0.0;

    var score = 0.0;
    var exactMatches = 0;
    var partialMatches = 0;

    for (final queryToken in queryTokens) {
      var hasMatch = false;

      for (int i = 0; i < targetTokens.length; i++) {
        final targetToken = targetTokens[i];

        if (targetToken == queryToken) {
          // Exact match gets 1.0 points
          score += 1.0;
          exactMatches++;
          hasMatch = true;
          break;
        } else if (targetToken.contains(queryToken)) {
          // Partial match gets points based on match length ratio
          final ratio = queryToken.length / targetToken.length;
          score += ratio * 0.8; // Partial matches worth 80% of exact matches
          partialMatches++;
          hasMatch = true;
          break;
        }
      }

      if (!hasMatch) {
        score -= 0.2; // Penalty for unmatched query tokens
      }
    }

    // Normalize score based on number of query tokens and matches
    final matchRatio =
        (exactMatches + partialMatches * 0.8) / queryTokens.length;
    score = score / queryTokens.length; // Normalize by query length

    // Apply match ratio as a multiplier
    score *= matchRatio;

    // Ensure score is between 0 and 1
    return score.clamp(0.0, 1.0);
  }

  factory TokenizedFilter.sort({
    required Iterable<T> items,
    required ToString<T> toString,
    required String query,
  }) {
    final queryTokens = _tokenize(query);

    final scoredItems = items.map((item) {
      final itemString = toString(item);
      if (itemString == null || itemString.isEmpty) {
        return (item, 0.0);
      }

      final itemTokens = _tokenize(itemString);
      final score = _calculateScore(queryTokens, itemTokens);
      return (item, score);
    }).toList();

    // Sort by score in descending order
    scoredItems.sort((a, b) => b.$2.compareTo(a.$2));

    // Extract just the items in sorted order
    final sorted = scoredItems.map((e) => e.$1).toList();

    return TokenizedFilter._(items, sorted);
  }

  factory TokenizedFilter.remove({
    required Iterable<T> items,
    required ToString<T> toString,
    required String query,
  }) {
    final queryTokens = _tokenize(query);

    final filtered = items.where((item) {
      final itemString = toString(item);
      if (itemString == null || itemString.isEmpty) {
        return false;
      }

      final itemTokens = _tokenize(itemString);
      return _matchTokens(queryTokens, itemTokens);
    }).toList();

    return TokenizedFilter._(items, filtered);
  }

  const TokenizedFilter._(this.original, this.filtered);
}
