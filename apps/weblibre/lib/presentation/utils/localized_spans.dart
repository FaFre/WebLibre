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
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

// Private-use code points: they never occur in translated text, so a marker
// cannot collide with anything a translator writes around it.
const _markerStart = '\u{E000}';
const _markerEnd = '\u{E001}';
final _markerPattern = RegExp('$_markerStart(\\d+)$_markerEnd');

/// Builds the span for a tagged run of translated text; [text] is what the
/// translator wrote between the tags.
typedef LocalizedTagBuilder = InlineSpan Function(String text);

/// The value to pass for a placeholder that [localizedSpans] should replace
/// with `spans[index]`.
String spanPlaceholder(int index) => '$_markerStart$index$_markerEnd';

/// Splits a translated sentence into spans so parts of it can be styled (bold,
/// a link, a widget) without cutting the sentence into separately translated
/// fragments.
///
/// There are two ways to mark a part, depending on who writes its text:
///
/// * **Values** (a file name, an app name, a URL) are ICU placeholders. Pass
///   [spanPlaceholder]s for them and the matching [spans]; translators only
///   decide where they land.
/// * **Translated text** (link text such as "Privacy Policy") stays inside the
///   message between `<name>…</name>` tags, so translators can inflect it to
///   fit the sentence. [tags] maps each name to a builder for that run.
///
/// ```dart
/// // "Delete {fileName}?"
/// localizedSpans(
///   l10n.history_deleteFileConfirm(spanPlaceholder(0)),
///   spans: [TextSpan(text: fileName, style: bold)],
/// )
///
/// // "… need no subscription. <learnMore>Learn more</learnMore>."
/// localizedSpans(
///   l10n.account_bannerBody,
///   tags: {'learnMore': (text) => TextSpan(text: text, recognizer: tap)},
/// )
/// ```
///
/// The tag parser runs over the finished message and only looks for the names
/// in [tags]. Pass user data in a tagged message as [spans], never as a plain
/// String placeholder, so a value containing `<learnMore>` stays literal text.
/// Tags cannot nest or hold placeholders. In debug builds an assert fails when
/// a translation drops or repeats a placeholder or tag, instead of silently
/// losing a link.
List<InlineSpan> localizedSpans(
  String message, {
  List<InlineSpan> spans = const [],
  Map<String, LocalizedTagBuilder> tags = const {},
}) {
  final pattern = tags.isEmpty
      ? _markerPattern
      : RegExp(
          '${_markerPattern.pattern}'
          '|<(${tags.keys.map(RegExp.escape).join('|')})>(.*?)</\\2>',
          dotAll: true,
        );

  final result = <InlineSpan>[];
  final usedSpans = <int>[];
  final usedTags = <String>[];
  var start = 0;

  for (final match in pattern.allMatches(message)) {
    if (match.start > start) {
      result.add(TextSpan(text: message.substring(start, match.start)));
    }

    if (match.group(1) case final index?) {
      final i = int.parse(index);
      usedSpans.add(i);
      if (i < spans.length) result.add(spans[i]);
    } else {
      final name = match.group(2)!;
      final text = match.group(3)!;
      assert(
        !text.contains(_markerStart),
        'Placeholder inside <$name> in "$message"; tags cannot hold values.',
      );
      usedTags.add(name);
      result.add(tags[name]!(text));
    }

    start = match.end;
  }

  if (start < message.length) {
    result.add(TextSpan(text: message.substring(start)));
  }

  assert(
    listEquals(usedSpans.toList()..sort(), [
      for (var i = 0; i < spans.length; i++) i,
    ]),
    'Expected each of ${spans.length} span placeholders exactly once in '
    '"$message", found $usedSpans.',
  );
  assert(
    usedTags.length == tags.length && usedTags.toSet().length == tags.length,
    'Expected each of the tags ${tags.keys} exactly once in "$message", '
    'found $usedTags.',
  );

  return result;
}
