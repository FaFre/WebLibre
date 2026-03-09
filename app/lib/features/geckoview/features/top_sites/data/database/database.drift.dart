// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/geckoview/features/top_sites/data/database/definitions.drift.dart'
    as i1;
import 'package:weblibre/features/geckoview/features/top_sites/data/database/daos/top_site.dart'
    as i2;
import 'package:weblibre/features/geckoview/features/top_sites/data/database/database.dart'
    as i3;
import 'package:weblibre/features/geckoview/features/top_sites/data/database/daos/seed_state.dart'
    as i4;
import 'package:drift/internal/modular.dart' as i5;
import 'package:sqlite3/common.dart' as i6;

abstract class $TopSiteDatabase extends i0.GeneratedDatabase {
  $TopSiteDatabase(i0.QueryExecutor e) : super(e);
  $TopSiteDatabaseManager get managers => $TopSiteDatabaseManager(this);
  late final i1.TopSite topSite = i1.TopSite(this);
  late final i1.TopSiteSeedState topSiteSeedState = i1.TopSiteSeedState(this);
  late final i2.TopSiteDao topSiteDao = i2.TopSiteDao(
    this as i3.TopSiteDatabase,
  );
  late final i4.TopSiteSeedStateDao topSiteSeedStateDao =
      i4.TopSiteSeedStateDao(this as i3.TopSiteDatabase);
  i1.DefinitionsDrift get definitionsDrift => i5.ReadDatabaseContainer(
    this,
  ).accessor<i1.DefinitionsDrift>(i1.DefinitionsDrift.new);
  @override
  Iterable<i0.TableInfo<i0.Table, Object?>> get allTables =>
      allSchemaEntities.whereType<i0.TableInfo<i0.Table, Object?>>();
  @override
  List<i0.DatabaseSchemaEntity> get allSchemaEntities => [
    topSite,
    i1.idxTopSiteOrderKey,
    topSiteSeedState,
  ];
}

class $TopSiteDatabaseManager {
  final $TopSiteDatabase _db;
  $TopSiteDatabaseManager(this._db);
  i1.$TopSiteTableManager get topSite =>
      i1.$TopSiteTableManager(_db, _db.topSite);
  i1.$TopSiteSeedStateTableManager get topSiteSeedState =>
      i1.$TopSiteSeedStateTableManager(_db, _db.topSiteSeedState);
}

extension DefineFunctions on i6.CommonDatabase {
  void defineFunctions({
    required String Function(int, String?) lexoRankNext,
    required String Function(int, String?) lexoRankPrevious,
    required String Function(String?, String?) lexoRankReorderAfter,
    required String Function(String?, String?) lexoRankReorderBefore,
  }) {
    createFunction(
      functionName: 'lexo_rank_next',
      argumentCount: const i6.AllowedArgumentCount(2),
      function: (args) {
        final arg0 = args[0] as int;
        final arg1 = args[1] as String?;
        return lexoRankNext(arg0, arg1);
      },
    );
    createFunction(
      functionName: 'lexo_rank_previous',
      argumentCount: const i6.AllowedArgumentCount(2),
      function: (args) {
        final arg0 = args[0] as int;
        final arg1 = args[1] as String?;
        return lexoRankPrevious(arg0, arg1);
      },
    );
    createFunction(
      functionName: 'lexo_rank_reorder_after',
      argumentCount: const i6.AllowedArgumentCount(2),
      function: (args) {
        final arg0 = args[0] as String?;
        final arg1 = args[1] as String?;
        return lexoRankReorderAfter(arg0, arg1);
      },
    );
    createFunction(
      functionName: 'lexo_rank_reorder_before',
      argumentCount: const i6.AllowedArgumentCount(2),
      function: (args) {
        final arg0 = args[0] as String?;
        final arg1 = args[1] as String?;
        return lexoRankReorderBefore(arg0, arg1);
      },
    );
  }
}
