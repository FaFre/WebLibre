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
}
