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
import 'package:nullability/nullability.dart';
import 'package:sqlite3/common.dart';

String _nextRankOrMiddle(List<Object?> args) {
  final parsedBucket = LexoRankBucket.resolve(args[0]! as int);

  if (args[1] != null) {
    final parsedRank = LexoRank.parse(args[1]! as String);

    return parsedRank.genNext().value;
  } else {
    return LexoRank.middle(bucket: parsedBucket).value;
  }
}

String _previousRankOrMiddle(List<Object?> args) {
  final parsedBucket = LexoRankBucket.resolve(args[0]! as int);

  if (args[1] != null) {
    final parsedRank = LexoRank.parse(args[1]! as String);

    return parsedRank.genPrev().value;
  } else {
    return LexoRank.middle(bucket: parsedBucket).value;
  }
}

String _reorderAfter(List<Object?> args) {
  final first = args[0].mapNotNull((arg) => LexoRank.parse(arg as String));
  final last = args[1].mapNotNull((arg) => LexoRank.parse(arg as String));

  if (first == null) {
    throw Exception('Tab not found');
  } else if (last == null) {
    return first.genNext().value;
  } else {
    return first.genBetween(last).value;
  }
}

String _reorderBefore(List<Object?> args) {
  final first = args[0].mapNotNull((arg) => LexoRank.parse(arg as String));
  final last = args[1].mapNotNull((arg) => LexoRank.parse(arg as String));

  if (first == null) {
    throw Exception('Tab not found');
  } else if (last == null) {
    return first.genPrev().value;
  } else {
    return last.genBetween(first).value;
  }
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
