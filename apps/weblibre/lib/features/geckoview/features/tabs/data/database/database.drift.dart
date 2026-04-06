// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart'
    as i1;
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/container.dart'
    as i2;
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart'
    as i3;
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/tab.dart'
    as i4;
import 'package:drift/internal/modular.dart' as i5;
import 'package:sqlite3/common.dart' as i6;

abstract class $TabDatabase extends i0.GeneratedDatabase {
  $TabDatabase(i0.QueryExecutor e) : super(e);
  $TabDatabaseManager get managers => $TabDatabaseManager(this);
  late final i1.Container container = i1.Container(this);
  late final i1.Tab tab = i1.Tab(this);
  late final i1.TabFts tabFts = i1.TabFts(this);
  late final i2.ContainerDao containerDao = i2.ContainerDao(
    this as i3.TabDatabase,
  );
  late final i4.TabDao tabDao = i4.TabDao(this as i3.TabDatabase);
  i1.DefinitionsDrift get definitionsDrift => i5.ReadDatabaseContainer(
    this,
  ).accessor<i1.DefinitionsDrift>(i1.DefinitionsDrift.new);
  @override
  Iterable<i0.TableInfo<i0.Table, Object?>> get allTables =>
      allSchemaEntities.whereType<i0.TableInfo<i0.Table, Object?>>();
  @override
  List<i0.DatabaseSchemaEntity> get allSchemaEntities => [
    container,
    tab,
    tabFts,
    i1.tabMaintainParentChainOnDelete,
    i1.tabAfterInsert,
    i1.tabAfterDelete,
    i1.tabAfterUpdate,
  ];
  @override
  i0.StreamQueryUpdateRules get streamUpdateRules =>
      const i0.StreamQueryUpdateRules([
        i0.WritePropagation(
          on: i0.TableUpdateQuery.onTableName(
            'container',
            limitUpdateKind: i0.UpdateKind.delete,
          ),
          result: [i0.TableUpdate('tab', kind: i0.UpdateKind.delete)],
        ),
        i0.WritePropagation(
          on: i0.TableUpdateQuery.onTableName(
            'tab',
            limitUpdateKind: i0.UpdateKind.delete,
          ),
          result: [i0.TableUpdate('tab', kind: i0.UpdateKind.update)],
        ),
        i0.WritePropagation(
          on: i0.TableUpdateQuery.onTableName(
            'tab',
            limitUpdateKind: i0.UpdateKind.insert,
          ),
          result: [i0.TableUpdate('tab_fts', kind: i0.UpdateKind.insert)],
        ),
        i0.WritePropagation(
          on: i0.TableUpdateQuery.onTableName(
            'tab',
            limitUpdateKind: i0.UpdateKind.delete,
          ),
          result: [i0.TableUpdate('tab_fts', kind: i0.UpdateKind.insert)],
        ),
        i0.WritePropagation(
          on: i0.TableUpdateQuery.onTableName(
            'tab',
            limitUpdateKind: i0.UpdateKind.update,
          ),
          result: [i0.TableUpdate('tab_fts', kind: i0.UpdateKind.insert)],
        ),
      ]);
}

class $TabDatabaseManager {
  final $TabDatabase _db;
  $TabDatabaseManager(this._db);
  i1.$ContainerTableManager get container =>
      i1.$ContainerTableManager(_db, _db.container);
  i1.$TabTableManager get tab => i1.$TabTableManager(_db, _db.tab);
  i1.$TabFtsTableManager get tabFts => i1.$TabFtsTableManager(_db, _db.tabFts);
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
