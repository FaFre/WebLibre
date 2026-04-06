// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/bangs/data/database/definitions.drift.dart'
    as i1;
import 'package:weblibre/features/bangs/data/database/daos/bang.dart' as i2;
import 'package:weblibre/features/bangs/data/database/database.dart' as i3;
import 'package:weblibre/features/bangs/data/database/daos/sync.dart' as i4;
import 'package:drift/internal/modular.dart' as i5;
import 'package:sqlite3/common.dart' as i6;

abstract class $BangDatabase extends i0.GeneratedDatabase {
  $BangDatabase(i0.QueryExecutor e) : super(e);
  $BangDatabaseManager get managers => $BangDatabaseManager(this);
  late final i1.BangTable bang = i1.BangTable(this);
  late final i1.BangTriggers bangTriggers = i1.BangTriggers(this);
  late final i1.BangSync bangSync = i1.BangSync(this);
  late final i1.BangFrequency bangFrequency = i1.BangFrequency(this);
  late final i1.BangHistory bangHistory = i1.BangHistory(this);
  late final i1.BangFts bangFts = i1.BangFts(this);
  late final i1.BangTriggersFts bangTriggersFts = i1.BangTriggersFts(this);
  late final i1.BangDataView bangDataView = i1.BangDataView(this);
  late final i2.BangDao bangDao = i2.BangDao(this as i3.BangDatabase);
  late final i4.SyncDao syncDao = i4.SyncDao(this as i3.BangDatabase);
  i1.DefinitionsDrift get definitionsDrift => i5.ReadDatabaseContainer(
    this,
  ).accessor<i1.DefinitionsDrift>(i1.DefinitionsDrift.new);
  @override
  Iterable<i0.TableInfo<i0.Table, Object?>> get allTables =>
      allSchemaEntities.whereType<i0.TableInfo<i0.Table, Object?>>();
  @override
  List<i0.DatabaseSchemaEntity> get allSchemaEntities => [
    bang,
    bangTriggers,
    i1.idxBangTriggersLookup,
    i1.bangTriggersAfterInsert,
    i1.bangTriggersAfterUpdate,
    bangSync,
    bangFrequency,
    bangHistory,
    bangFts,
    bangTriggersFts,
    bangDataView,
    i1.bangAfterInsert,
    i1.bangAfterDelete,
    i1.bangAfterUpdate,
    i1.bangTriggersAfterInsertFts,
    i1.bangTriggersAfterDeleteFts,
    i1.bangTriggersAfterUpdateFts,
  ];
  @override
  i0.StreamQueryUpdateRules
  get streamUpdateRules => const i0.StreamQueryUpdateRules([
    i0.WritePropagation(
      on: i0.TableUpdateQuery.onTableName(
        'bang',
        limitUpdateKind: i0.UpdateKind.delete,
      ),
      result: [i0.TableUpdate('bang_triggers', kind: i0.UpdateKind.delete)],
    ),
    i0.WritePropagation(
      on: i0.TableUpdateQuery.onTableName(
        'bang',
        limitUpdateKind: i0.UpdateKind.insert,
      ),
      result: [i0.TableUpdate('bang_triggers', kind: i0.UpdateKind.insert)],
    ),
    i0.WritePropagation(
      on: i0.TableUpdateQuery.onTableName(
        'bang',
        limitUpdateKind: i0.UpdateKind.update,
      ),
      result: [
        i0.TableUpdate('bang_triggers', kind: i0.UpdateKind.delete),
        i0.TableUpdate('bang_triggers', kind: i0.UpdateKind.insert),
      ],
    ),
    i0.WritePropagation(
      on: i0.TableUpdateQuery.onTableName(
        'bang',
        limitUpdateKind: i0.UpdateKind.delete,
      ),
      result: [i0.TableUpdate('bang_frequency', kind: i0.UpdateKind.delete)],
    ),
    i0.WritePropagation(
      on: i0.TableUpdateQuery.onTableName(
        'bang',
        limitUpdateKind: i0.UpdateKind.delete,
      ),
      result: [i0.TableUpdate('bang_history', kind: i0.UpdateKind.delete)],
    ),
    i0.WritePropagation(
      on: i0.TableUpdateQuery.onTableName(
        'bang',
        limitUpdateKind: i0.UpdateKind.insert,
      ),
      result: [i0.TableUpdate('bang_fts', kind: i0.UpdateKind.insert)],
    ),
    i0.WritePropagation(
      on: i0.TableUpdateQuery.onTableName(
        'bang',
        limitUpdateKind: i0.UpdateKind.delete,
      ),
      result: [i0.TableUpdate('bang_fts', kind: i0.UpdateKind.insert)],
    ),
    i0.WritePropagation(
      on: i0.TableUpdateQuery.onTableName(
        'bang',
        limitUpdateKind: i0.UpdateKind.update,
      ),
      result: [i0.TableUpdate('bang_fts', kind: i0.UpdateKind.insert)],
    ),
    i0.WritePropagation(
      on: i0.TableUpdateQuery.onTableName(
        'bang_triggers',
        limitUpdateKind: i0.UpdateKind.insert,
      ),
      result: [i0.TableUpdate('bang_triggers_fts', kind: i0.UpdateKind.insert)],
    ),
    i0.WritePropagation(
      on: i0.TableUpdateQuery.onTableName(
        'bang_triggers',
        limitUpdateKind: i0.UpdateKind.delete,
      ),
      result: [i0.TableUpdate('bang_triggers_fts', kind: i0.UpdateKind.insert)],
    ),
    i0.WritePropagation(
      on: i0.TableUpdateQuery.onTableName(
        'bang_triggers',
        limitUpdateKind: i0.UpdateKind.update,
      ),
      result: [i0.TableUpdate('bang_triggers_fts', kind: i0.UpdateKind.insert)],
    ),
  ]);
}

class $BangDatabaseManager {
  final $BangDatabase _db;
  $BangDatabaseManager(this._db);
  i1.$BangTableTableManager get bang =>
      i1.$BangTableTableManager(_db, _db.bang);
  i1.$BangTriggersTableManager get bangTriggers =>
      i1.$BangTriggersTableManager(_db, _db.bangTriggers);
  i1.$BangSyncTableManager get bangSync =>
      i1.$BangSyncTableManager(_db, _db.bangSync);
  i1.$BangFrequencyTableManager get bangFrequency =>
      i1.$BangFrequencyTableManager(_db, _db.bangFrequency);
  i1.$BangHistoryTableManager get bangHistory =>
      i1.$BangHistoryTableManager(_db, _db.bangHistory);
  i1.$BangFtsTableManager get bangFts =>
      i1.$BangFtsTableManager(_db, _db.bangFts);
  i1.$BangTriggersFtsTableManager get bangTriggersFts =>
      i1.$BangTriggersFtsTableManager(_db, _db.bangTriggersFts);
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
