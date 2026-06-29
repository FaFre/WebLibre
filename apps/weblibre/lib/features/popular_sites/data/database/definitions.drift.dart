// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/popular_sites/data/database/definitions.drift.dart'
    as i1;
import 'package:drift/internal/modular.dart' as i2;

typedef $SitesCreateCompanionBuilder =
    i1.SitesCompanion Function({
      required String domain,
      required int rank,
      i0.Value<int> rowid,
    });
typedef $SitesUpdateCompanionBuilder =
    i1.SitesCompanion Function({
      i0.Value<String> domain,
      i0.Value<int> rank,
      i0.Value<int> rowid,
    });

class $SitesFilterComposer extends i0.Composer<i0.GeneratedDatabase, i1.Sites> {
  $SitesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $SitesOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.Sites> {
  $SitesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $SitesAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.Sites> {
  $SitesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  i0.GeneratedColumn<int> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);
}

class $SitesTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i1.Sites,
          i1.Site,
          i1.$SitesFilterComposer,
          i1.$SitesOrderingComposer,
          i1.$SitesAnnotationComposer,
          $SitesCreateCompanionBuilder,
          $SitesUpdateCompanionBuilder,
          (i1.Site, i0.BaseReferences<i0.GeneratedDatabase, i1.Sites, i1.Site>),
          i1.Site,
          i0.PrefetchHooks Function()
        > {
  $SitesTableManager(i0.GeneratedDatabase db, i1.Sites table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i1.$SitesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i1.$SitesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i1.$SitesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> domain = const i0.Value.absent(),
                i0.Value<int> rank = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.SitesCompanion(domain: domain, rank: rank, rowid: rowid),
          createCompanionCallback:
              ({
                required String domain,
                required int rank,
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.SitesCompanion.insert(
                domain: domain,
                rank: rank,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $SitesProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i1.Sites,
      i1.Site,
      i1.$SitesFilterComposer,
      i1.$SitesOrderingComposer,
      i1.$SitesAnnotationComposer,
      $SitesCreateCompanionBuilder,
      $SitesUpdateCompanionBuilder,
      (i1.Site, i0.BaseReferences<i0.GeneratedDatabase, i1.Sites, i1.Site>),
      i1.Site,
      i0.PrefetchHooks Function()
    >;

class Sites extends i0.Table with i0.TableInfo<Sites, i1.Site> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  Sites(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> domain = i0.GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  late final i0.GeneratedColumn<int> rank = i0.GeneratedColumn<int>(
    'rank',
    aliasedName,
    false,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<i0.GeneratedColumn> get $columns => [domain, rank];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sites';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {domain};
  @override
  i1.Site map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.Site(
      domain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      rank: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}rank'],
      )!,
    );
  }

  @override
  Sites createAlias(String alias) {
    return Sites(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Site extends i0.DataClass implements i0.Insertable<i1.Site> {
  final String domain;
  final int rank;
  const Site({required this.domain, required this.rank});
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['domain'] = i0.Variable<String>(domain);
    map['rank'] = i0.Variable<int>(rank);
    return map;
  }

  factory Site.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return Site(
      domain: serializer.fromJson<String>(json['domain']),
      rank: serializer.fromJson<int>(json['rank']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'domain': serializer.toJson<String>(domain),
      'rank': serializer.toJson<int>(rank),
    };
  }

  i1.Site copyWith({String? domain, int? rank}) =>
      i1.Site(domain: domain ?? this.domain, rank: rank ?? this.rank);
  Site copyWithCompanion(i1.SitesCompanion data) {
    return Site(
      domain: data.domain.present ? data.domain.value : this.domain,
      rank: data.rank.present ? data.rank.value : this.rank,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Site(')
          ..write('domain: $domain, ')
          ..write('rank: $rank')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(domain, rank);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.Site &&
          other.domain == this.domain &&
          other.rank == this.rank);
}

class SitesCompanion extends i0.UpdateCompanion<i1.Site> {
  final i0.Value<String> domain;
  final i0.Value<int> rank;
  final i0.Value<int> rowid;
  const SitesCompanion({
    this.domain = const i0.Value.absent(),
    this.rank = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  SitesCompanion.insert({
    required String domain,
    required int rank,
    this.rowid = const i0.Value.absent(),
  }) : domain = i0.Value(domain),
       rank = i0.Value(rank);
  static i0.Insertable<i1.Site> custom({
    i0.Expression<String>? domain,
    i0.Expression<int>? rank,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (domain != null) 'domain': domain,
      if (rank != null) 'rank': rank,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i1.SitesCompanion copyWith({
    i0.Value<String>? domain,
    i0.Value<int>? rank,
    i0.Value<int>? rowid,
  }) {
    return i1.SitesCompanion(
      domain: domain ?? this.domain,
      rank: rank ?? this.rank,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (domain.present) {
      map['domain'] = i0.Variable<String>(domain.value);
    }
    if (rank.present) {
      map['rank'] = i0.Variable<int>(rank.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SitesCompanion(')
          ..write('domain: $domain, ')
          ..write('rank: $rank, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class DefinitionsDrift extends i2.ModularAccessor {
  DefinitionsDrift(i0.GeneratedDatabase db) : super(db);
  i0.Selectable<i1.Site> searchSitesByPrefix({
    required String pattern,
    required int limit,
  }) {
    return customSelect(
      'SELECT * FROM sites WHERE domain LIKE ?1 ESCAPE \'\\\' ORDER BY rank ASC LIMIT ?2',
      variables: [i0.Variable<String>(pattern), i0.Variable<int>(limit)],
      readsFrom: {sites},
    ).asyncMap(sites.mapFromRow);
  }

  i1.Sites get sites =>
      i2.ReadDatabaseContainer(attachedDatabase).resultSet<i1.Sites>('sites');
}
