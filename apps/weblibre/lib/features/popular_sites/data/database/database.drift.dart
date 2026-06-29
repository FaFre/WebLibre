// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/popular_sites/data/database/definitions.drift.dart'
    as i1;
import 'package:weblibre/features/popular_sites/data/database/daos/site.dart'
    as i2;
import 'package:weblibre/features/popular_sites/data/database/database.dart'
    as i3;
import 'package:drift/internal/modular.dart' as i4;
import 'package:sqlite3/common.dart' as i5;

abstract class $SitesDatabase extends i0.GeneratedDatabase {
  $SitesDatabase(i0.QueryExecutor e) : super(e);
  $SitesDatabaseManager get managers => $SitesDatabaseManager(this);
  late final i1.Sites sites = i1.Sites(this);
  late final i2.SiteDao siteDao = i2.SiteDao(this as i3.SitesDatabase);
  i1.DefinitionsDrift get definitionsDrift => i4.ReadDatabaseContainer(
    this,
  ).accessor<i1.DefinitionsDrift>(i1.DefinitionsDrift.new);
  @override
  Iterable<i0.TableInfo<i0.Table, Object?>> get allTables =>
      allSchemaEntities.whereType<i0.TableInfo<i0.Table, Object?>>();
  @override
  List<i0.DatabaseSchemaEntity> get allSchemaEntities => [sites];
}

class $SitesDatabaseManager {
  final $SitesDatabase _db;
  $SitesDatabaseManager(this._db);
  i1.$SitesTableManager get sites => i1.$SitesTableManager(_db, _db.sites);
}

extension DefineFunctions on i5.CommonDatabase {
  void defineFunctions({
    required String Function(int, String?) lexoRankNext,
    required String Function(int, String?) lexoRankPrevious,
    required String Function(String?, String?) lexoRankReorderAfter,
    required String Function(String?, String?) lexoRankReorderBefore,
    required int Function() generateContentHash,
    required bool Function(String?) urlIndexable,
    required String Function(String?) urlCanonical,
    required String Function(String?) urlHost,
    required String Function(String?) urlPath,
  }) {
    createFunction(
      functionName: 'lexo_rank_next',
      argumentCount: const i5.AllowedArgumentCount(2),
      function: (args) {
        final arg0 = args[0] as int;
        final arg1 = args[1] as String?;
        return lexoRankNext(arg0, arg1);
      },
    );
    createFunction(
      functionName: 'lexo_rank_previous',
      argumentCount: const i5.AllowedArgumentCount(2),
      function: (args) {
        final arg0 = args[0] as int;
        final arg1 = args[1] as String?;
        return lexoRankPrevious(arg0, arg1);
      },
    );
    createFunction(
      functionName: 'lexo_rank_reorder_after',
      argumentCount: const i5.AllowedArgumentCount(2),
      function: (args) {
        final arg0 = args[0] as String?;
        final arg1 = args[1] as String?;
        return lexoRankReorderAfter(arg0, arg1);
      },
    );
    createFunction(
      functionName: 'lexo_rank_reorder_before',
      argumentCount: const i5.AllowedArgumentCount(2),
      function: (args) {
        final arg0 = args[0] as String?;
        final arg1 = args[1] as String?;
        return lexoRankReorderBefore(arg0, arg1);
      },
    );
    createFunction(
      functionName: 'generate_content_hash',
      argumentCount: const i5.AllowedArgumentCount(0),
      function: (args) {
        return generateContentHash();
      },
    );
    createFunction(
      functionName: 'url_indexable',
      argumentCount: const i5.AllowedArgumentCount(1),
      function: (args) {
        final arg0 = args[0] as String?;
        return urlIndexable(arg0);
      },
    );
    createFunction(
      functionName: 'url_canonical',
      argumentCount: const i5.AllowedArgumentCount(1),
      function: (args) {
        final arg0 = args[0] as String?;
        return urlCanonical(arg0);
      },
    );
    createFunction(
      functionName: 'url_host',
      argumentCount: const i5.AllowedArgumentCount(1),
      function: (args) {
        final arg0 = args[0] as String?;
        return urlHost(arg0);
      },
    );
    createFunction(
      functionName: 'url_path',
      argumentCount: const i5.AllowedArgumentCount(1),
      function: (args) {
        final arg0 = args[0] as String?;
        return urlPath(arg0);
      },
    );
  }
}
