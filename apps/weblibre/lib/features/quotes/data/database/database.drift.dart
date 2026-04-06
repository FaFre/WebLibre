// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/quotes/data/database/definitions.drift.dart'
    as i1;
import 'package:weblibre/features/quotes/data/database/daos/quote.dart' as i2;
import 'package:weblibre/features/quotes/data/database/database.dart' as i3;
import 'package:sqlite3/common.dart' as i4;

abstract class $QuotesDatabase extends i0.GeneratedDatabase {
  $QuotesDatabase(i0.QueryExecutor e) : super(e);
  $QuotesDatabaseManager get managers => $QuotesDatabaseManager(this);
  late final i1.Quotes quotes = i1.Quotes(this);
  late final i2.QuoteDao quoteDao = i2.QuoteDao(this as i3.QuotesDatabase);
  @override
  Iterable<i0.TableInfo<i0.Table, Object?>> get allTables =>
      allSchemaEntities.whereType<i0.TableInfo<i0.Table, Object?>>();
  @override
  List<i0.DatabaseSchemaEntity> get allSchemaEntities => [quotes];
}

class $QuotesDatabaseManager {
  final $QuotesDatabase _db;
  $QuotesDatabaseManager(this._db);
  i1.$QuotesTableManager get quotes => i1.$QuotesTableManager(_db, _db.quotes);
}

extension DefineFunctions on i4.CommonDatabase {
  void defineFunctions({
    required String Function(int, String?) lexoRankNext,
    required String Function(int, String?) lexoRankPrevious,
    required String Function(String?, String?) lexoRankReorderAfter,
    required String Function(String?, String?) lexoRankReorderBefore,
  }) {
    createFunction(
      functionName: 'lexo_rank_next',
      argumentCount: const i4.AllowedArgumentCount(2),
      function: (args) {
        final arg0 = args[0] as int;
        final arg1 = args[1] as String?;
        return lexoRankNext(arg0, arg1);
      },
    );
    createFunction(
      functionName: 'lexo_rank_previous',
      argumentCount: const i4.AllowedArgumentCount(2),
      function: (args) {
        final arg0 = args[0] as int;
        final arg1 = args[1] as String?;
        return lexoRankPrevious(arg0, arg1);
      },
    );
    createFunction(
      functionName: 'lexo_rank_reorder_after',
      argumentCount: const i4.AllowedArgumentCount(2),
      function: (args) {
        final arg0 = args[0] as String?;
        final arg1 = args[1] as String?;
        return lexoRankReorderAfter(arg0, arg1);
      },
    );
    createFunction(
      functionName: 'lexo_rank_reorder_before',
      argumentCount: const i4.AllowedArgumentCount(2),
      function: (args) {
        final arg0 = args[0] as String?;
        final arg1 = args[1] as String?;
        return lexoRankReorderBefore(arg0, arg1);
      },
    );
  }
}
