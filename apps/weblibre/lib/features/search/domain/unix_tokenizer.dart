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
import 'package:weblibre/features/search/domain/entities/bareword.dart';

typedef _Phrase = List<Bareword>;

sealed class UnixTokenizer {
  ///Matching quoted strings like "xda bda" (group 1), as well as strings delimetered by
  ///a whitespace (group 2)
  static final _tokenizePattern = RegExp('"([^"]+)"|([^ ]+)');

  late final _Phrase _tokens;

  bool get hasTokens => _tokens.isNotEmpty;

  static void _mergeShortBarewords(
    List<Bareword> barewords,
    int minTokenLength,
  ) {
    for (var i = 0; i < barewords.length; i++) {
      final bareword = barewords[i];

      if (i != 0) {
        if (bareword.word.length < minTokenLength) {
          barewords[i] = barewords[i - 1].join(bareword);
        }
      }
    }
  }

  UnixTokenizer.tokenize({
    required String input,
    required int minTokenLength,
    required int tokenLimit,
  }) {
    final matches = _tokenizePattern.allMatches(input);

    final barewords = matches
        .map((match) {
          if (match.group(1) != null) {
            return EnclosedBareword(match.group(1)!);
          } else {
            return SimpleBareword(match.group(2)!);
          }
        })
        .where((token) => token.word.isNotEmpty)
        .toList();

    //Merge short tokens
    _mergeShortBarewords(barewords, minTokenLength);

    _tokens = barewords.take(tokenLimit).toList();
  }

  String build({bool wildcard});
}

final class UnixLikeQueryBuilder extends UnixTokenizer {
  UnixLikeQueryBuilder.tokenize({
    required super.input,
    required super.minTokenLength,
    required super.tokenLimit,
  }) : super.tokenize();

  @override
  String build({bool wildcard = true}) {
    final joined = _tokens.join('%');
    return wildcard ? '%$joined%' : joined;
  }
}
