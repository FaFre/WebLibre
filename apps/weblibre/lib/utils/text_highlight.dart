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
import 'package:flutter/material.dart';

/// Builds a [TextSpan] with highlighted sections based on prefix/suffix markers.
///
/// This function parses text that contains highlight markers (e.g., from FTS5
/// search results) and creates a [TextSpan] with different styles for regular
/// and highlighted text.
///
/// Example:
/// ```dart
/// final span = buildHighlightedText(
///   'Hello ***world***!',
///   baseStyle,
///   highlightStyle,
///   '***',
///   '***',
/// );
/// // Results in: "Hello " (base) + "world" (highlighted) + "!" (base)
/// ```
///
/// [text] The text to parse for highlights
/// [baseStyle] Style for non-highlighted text
/// [highlightStyle] Style for highlighted text
/// [matchPrefix] Marker that indicates the start of a highlight
/// [matchSuffix] Marker that indicates the end of a highlight
TextSpan buildHighlightedText(
  String text,
  TextStyle? baseStyle,
  TextStyle? highlightStyle,
  String matchPrefix,
  String matchSuffix, {
  bool normalizeWhitespaces = false,
}) {
  final spans = <TextSpan>[];
  var currentIndex = 0;

  if (normalizeWhitespaces) {
    // ignore: parameter_assignments
    text = text.replaceAll(RegExp(r'\s+'), ' ');
  }

  while (currentIndex < text.length) {
    final prefixIndex = text.indexOf(matchPrefix, currentIndex);
    if (prefixIndex == -1) {
      spans.add(TextSpan(text: text.substring(currentIndex), style: baseStyle));
      break;
    }

    if (prefixIndex > currentIndex) {
      spans.add(
        TextSpan(
          text: text.substring(currentIndex, prefixIndex),
          style: baseStyle,
        ),
      );
    }

    final suffixIndex = text.indexOf(
      matchSuffix,
      prefixIndex + matchPrefix.length,
    );
    if (suffixIndex == -1) {
      // No closing marker - highlight everything from prefix to end
      final highlightedText = text.substring(prefixIndex + matchPrefix.length);
      spans.add(TextSpan(text: highlightedText, style: highlightStyle));
      break;
    }

    final highlightedText = text.substring(
      prefixIndex + matchPrefix.length,
      suffixIndex,
    );
    spans.add(TextSpan(text: highlightedText, style: highlightStyle));

    currentIndex = suffixIndex + matchSuffix.length;
  }

  return TextSpan(children: spans);
}
