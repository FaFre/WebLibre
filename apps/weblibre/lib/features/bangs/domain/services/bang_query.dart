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
import 'package:collection/collection.dart';

/// The character DuckDuckGo-style bangs are conventionally written with.
const bangPrefixCharacter = '!';

final _whitespacePattern = RegExp(r'\s+');

/// Whether [token] is written as an explicit bang (`!g`) rather than a plain
/// word. A lone `!` is not a bang — the user has typed the prefix but no
/// trigger yet.
bool isBangToken(String token) =>
    token.length > 1 && token.startsWith(bangPrefixCharacter);

/// Drops the leading `!` from an explicit bang token, leaving the bare trigger.
/// Plain words are returned unchanged.
String stripBangPrefix(String token) =>
    isBangToken(token) ? token.substring(1) : token;

/// Splits [input] into whitespace-delimited tokens, discarding empties.
List<String> tokenizeBangInput(String input) => input
    .trim()
    .split(_whitespacePattern)
    .where((token) => token.isNotEmpty)
    .toList();

/// The trigger the user appears to be reaching for in [input].
///
/// An explicitly written bang wins wherever it sits, so both the leading
/// (`!g cats`) and trailing (`cats !g`) spellings resolve. Failing that the
/// first word is treated as a candidate, because the bang chip strip filters
/// while the user is still typing a trigger and before any `!` is involved.
///
/// Returns an empty string when [input] has no tokens at all; callers read that
/// as "nothing to rank by".
String bangTriggerCandidate(String input) {
  final tokens = tokenizeBangInput(input);
  if (tokens.isEmpty) {
    return '';
  }

  final explicit = tokens.firstWhereOrNull(isBangToken);
  return explicit != null ? stripBangPrefix(explicit) : tokens.first;
}

/// [input] with every explicit bang token reduced to its bare trigger.
///
/// The full-text index stores triggers without the `!`, and FTS5 treats the
/// character as a separator anyway — feeding it through only forces the token
/// down the quoted-phrase path for no gain.
String normalizeBangSearchInput(String input) =>
    tokenizeBangInput(input).map(stripBangPrefix).join(' ');

final _aliasSeparatorPattern = RegExp(r'[,\s]+');

/// Reads the alias field of the bang editor.
///
/// Accepts however the user cares to write them — `!yt, ytm youtube` — and
/// normalises to bare triggers. [trigger] is dropped so a bang cannot list its
/// own primary trigger as an alias, which would put two rows in `bang_triggers`
/// claiming the same word.
///
/// Returns null for an empty field: the column is nullable and the SQL trigger
/// that fans aliases out is gated on `IS NOT NULL`.
Set<String>? parseBangAliases(String input, {required String trigger}) {
  final aliases = input
      .split(_aliasSeparatorPattern)
      .map((alias) => stripBangPrefix(alias.trim()))
      .where(
        (alias) =>
            alias.isNotEmpty && alias.toLowerCase() != trigger.toLowerCase(),
      )
      .toSet();

  return aliases.isEmpty ? null : aliases;
}

/// Renders aliases back into the editor's field.
String formatBangAliases(Iterable<String>? aliases) =>
    aliases?.join(', ') ?? '';

/// Address-bar input split into the bang the user wrote and what is left to
/// search for.
class ParsedBangInput {
  /// The trigger of the explicitly written bang, without its `!`, or null when
  /// the input contains none.
  ///
  /// Only an explicit `!token` counts. A bare first word is deliberately *not*
  /// treated as a bang: `apple pie` must stay a search for apple pie even
  /// though `!apple` exists.
  final String? trigger;

  /// [rawInput] with the bang token removed. Empty when the bang was all the
  /// user typed (`!g`), which every bang reads as "open your home page".
  final String query;

  /// What the user actually typed, untouched.
  final String rawInput;

  bool get hasBang => trigger != null;

  const ParsedBangInput({
    required this.trigger,
    required this.query,
    required this.rawInput,
  });
}

/// Lifts an explicitly written bang out of [input].
///
/// Both the leading (`!g cats`) and trailing (`cats !g`) spellings are
/// accepted, matching what DuckDuckGo and Kagi users expect. Only the first
/// bang token is consumed; a second one stays in the query rather than
/// silently changing which engine runs.
ParsedBangInput parseBangInput(String input) {
  final tokens = tokenizeBangInput(input);
  final index = tokens.indexWhere(isBangToken);

  if (index < 0) {
    return ParsedBangInput(trigger: null, query: input, rawInput: input);
  }

  final remaining = List.of(tokens)..removeAt(index);

  return ParsedBangInput(
    trigger: stripBangPrefix(tokens[index]),
    query: remaining.join(' '),
    rawInput: input,
  );
}
