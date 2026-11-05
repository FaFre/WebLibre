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
import 'package:lexo_rank/lexo_rank.dart';
import 'package:lexo_rank/lexo_rank/lexo_rank_bucket.dart';
import 'package:sqlite3/common.dart';

/// A rank between [before] and [after], either of which may be absent: the
/// middle of [bucket] when both are, otherwise next to the one given.
///
/// The one place rank neighbours are worked out, for the SQL functions below
/// and for code that orders rows in Dart (the toolbar button editor).
String lexoRankBetween(String? before, String? after, {int bucket = 0}) =>
    switch ((before, after)) {
      (null, null) => LexoRank.middle(
        bucket: LexoRankBucket.resolve(bucket),
      ).value,
      (null, final after?) => LexoRank.parse(after).genPrev().value,
      (final before?, null) => LexoRank.parse(before).genNext().value,
      (final before?, final after?) => LexoRank.parse(
        before,
      ).genBetween(LexoRank.parse(after)).value,
    };

String _nextRankOrMiddle(List<Object?> args) =>
    lexoRankBetween(args[1] as String?, null, bucket: args[0]! as int);

String _previousRankOrMiddle(List<Object?> args) =>
    lexoRankBetween(null, args[1] as String?, bucket: args[0]! as int);

String _reorderAfter(List<Object?> args) {
  final first = args[0] as String?;
  if (first == null) throw Exception('Tab not found');
  return lexoRankBetween(first, args[1] as String?);
}

String _reorderBefore(List<Object?> args) {
  final first = args[0] as String?;
  if (first == null) throw Exception('Tab not found');
  return lexoRankBetween(args[1] as String?, first);
}

void registerLexorankFunctions(CommonDatabase database) {
  database.createFunction(
    functionName: 'lexo_rank_next',
    argumentCount: const AllowedArgumentCount(2),
    function: _nextRankOrMiddle,
  );
  database.createFunction(
    functionName: 'lexo_rank_previous',
    argumentCount: const AllowedArgumentCount(2),
    function: _previousRankOrMiddle,
  );
  database.createFunction(
    functionName: 'lexo_rank_reorder_after',
    argumentCount: const AllowedArgumentCount(2),
    function: _reorderAfter,
  );
  database.createFunction(
    functionName: 'lexo_rank_reorder_before',
    argumentCount: const AllowedArgumentCount(2),
    function: _reorderBefore,
  );
}
