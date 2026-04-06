// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/small_web/data/database/definitions.drift.dart'
    as i1;
import 'package:weblibre/features/small_web/data/database/daos/small_web_item_dao.dart'
    as i2;
import 'package:weblibre/features/small_web/data/database/database.dart' as i3;
import 'package:weblibre/features/small_web/data/database/daos/small_web_visit_dao.dart'
    as i4;
import 'package:weblibre/features/small_web/data/database/daos/wander_console_dao.dart'
    as i5;
import 'package:drift/internal/modular.dart' as i6;
import 'package:sqlite3/common.dart' as i7;

abstract class $SmallWebDatabase extends i0.GeneratedDatabase {
  $SmallWebDatabase(i0.QueryExecutor e) : super(e);
  $SmallWebDatabaseManager get managers => $SmallWebDatabaseManager(this);
  late final i1.SmallWebItems smallWebItems = i1.SmallWebItems(this);
  late final i1.SmallWebMemberships smallWebMemberships =
      i1.SmallWebMemberships(this);
  late final i1.WanderConsoles wanderConsoles = i1.WanderConsoles(this);
  late final i1.WanderConsoleNeighbors wanderConsoleNeighbors =
      i1.WanderConsoleNeighbors(this);
  late final i1.SmallWebVisits smallWebVisits = i1.SmallWebVisits(this);
  late final i2.SmallWebItemDao smallWebItemDao = i2.SmallWebItemDao(
    this as i3.SmallWebDatabase,
  );
  late final i4.SmallWebVisitDao smallWebVisitDao = i4.SmallWebVisitDao(
    this as i3.SmallWebDatabase,
  );
  late final i5.WanderConsoleDao wanderConsoleDao = i5.WanderConsoleDao(
    this as i3.SmallWebDatabase,
  );
  i1.DefinitionsDrift get definitionsDrift => i6.ReadDatabaseContainer(
    this,
  ).accessor<i1.DefinitionsDrift>(i1.DefinitionsDrift.new);
  @override
  Iterable<i0.TableInfo<i0.Table, Object?>> get allTables =>
      allSchemaEntities.whereType<i0.TableInfo<i0.Table, Object?>>();
  @override
  List<i0.DatabaseSchemaEntity> get allSchemaEntities => [
    smallWebItems,
    smallWebMemberships,
    i1.idxMembershipSourceMode,
    i1.idxMembershipItem,
    wanderConsoles,
    wanderConsoleNeighbors,
    smallWebVisits,
    i1.idxVisitMode,
    i1.idxVisitItem,
  ];
  @override
  i0.StreamQueryUpdateRules get streamUpdateRules =>
      const i0.StreamQueryUpdateRules([
        i0.WritePropagation(
          on: i0.TableUpdateQuery.onTableName(
            'small_web_items',
            limitUpdateKind: i0.UpdateKind.delete,
          ),
          result: [
            i0.TableUpdate('small_web_memberships', kind: i0.UpdateKind.delete),
          ],
        ),
        i0.WritePropagation(
          on: i0.TableUpdateQuery.onTableName(
            'wander_consoles',
            limitUpdateKind: i0.UpdateKind.delete,
          ),
          result: [
            i0.TableUpdate(
              'wander_console_neighbors',
              kind: i0.UpdateKind.delete,
            ),
          ],
        ),
        i0.WritePropagation(
          on: i0.TableUpdateQuery.onTableName(
            'small_web_items',
            limitUpdateKind: i0.UpdateKind.delete,
          ),
          result: [
            i0.TableUpdate('small_web_visits', kind: i0.UpdateKind.delete),
          ],
        ),
      ]);
}

class $SmallWebDatabaseManager {
  final $SmallWebDatabase _db;
  $SmallWebDatabaseManager(this._db);
  i1.$SmallWebItemsTableManager get smallWebItems =>
      i1.$SmallWebItemsTableManager(_db, _db.smallWebItems);
  i1.$SmallWebMembershipsTableManager get smallWebMemberships =>
      i1.$SmallWebMembershipsTableManager(_db, _db.smallWebMemberships);
  i1.$WanderConsolesTableManager get wanderConsoles =>
      i1.$WanderConsolesTableManager(_db, _db.wanderConsoles);
  i1.$WanderConsoleNeighborsTableManager get wanderConsoleNeighbors =>
      i1.$WanderConsoleNeighborsTableManager(_db, _db.wanderConsoleNeighbors);
  i1.$SmallWebVisitsTableManager get smallWebVisits =>
      i1.$SmallWebVisitsTableManager(_db, _db.smallWebVisits);
}

extension DefineFunctions on i7.CommonDatabase {
  void defineFunctions({
    required String Function(int, String?) lexoRankNext,
    required String Function(int, String?) lexoRankPrevious,
    required String Function(String?, String?) lexoRankReorderAfter,
    required String Function(String?, String?) lexoRankReorderBefore,
  }) {
    createFunction(
      functionName: 'lexo_rank_next',
      argumentCount: const i7.AllowedArgumentCount(2),
      function: (args) {
        final arg0 = args[0] as int;
        final arg1 = args[1] as String?;
        return lexoRankNext(arg0, arg1);
      },
    );
    createFunction(
      functionName: 'lexo_rank_previous',
      argumentCount: const i7.AllowedArgumentCount(2),
      function: (args) {
        final arg0 = args[0] as int;
        final arg1 = args[1] as String?;
        return lexoRankPrevious(arg0, arg1);
      },
    );
    createFunction(
      functionName: 'lexo_rank_reorder_after',
      argumentCount: const i7.AllowedArgumentCount(2),
      function: (args) {
        final arg0 = args[0] as String?;
        final arg1 = args[1] as String?;
        return lexoRankReorderAfter(arg0, arg1);
      },
    );
    createFunction(
      functionName: 'lexo_rank_reorder_before',
      argumentCount: const i7.AllowedArgumentCount(2),
      function: (args) {
        final arg0 = args[0] as String?;
        final arg1 = args[1] as String?;
        return lexoRankReorderBefore(arg0, arg1);
      },
    );
  }
}
