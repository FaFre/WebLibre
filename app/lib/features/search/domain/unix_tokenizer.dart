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
