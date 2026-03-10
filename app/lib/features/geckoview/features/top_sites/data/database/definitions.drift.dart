// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/geckoview/features/top_sites/data/database/definitions.drift.dart'
    as i1;
import 'package:weblibre/features/geckoview/features/top_sites/data/entities/stored_top_site_source.dart'
    as i2;
import 'package:weblibre/data/database/converters/uri.dart' as i3;
import 'package:drift/internal/modular.dart' as i4;

typedef $TopSiteCreateCompanionBuilder =
    i1.TopSiteCompanion Function({
      required String id,
      required String title,
      required Uri url,
      required i2.StoredTopSiteSource source,
      required String orderKey,
      required DateTime createdAt,
      i0.Value<int> rowid,
    });
typedef $TopSiteUpdateCompanionBuilder =
    i1.TopSiteCompanion Function({
      i0.Value<String> id,
      i0.Value<String> title,
      i0.Value<Uri> url,
      i0.Value<i2.StoredTopSiteSource> source,
      i0.Value<String> orderKey,
      i0.Value<DateTime> createdAt,
      i0.Value<int> rowid,
    });

class $TopSiteFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.TopSite> {
  $TopSiteFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<Uri, Uri, String> get url =>
      $composableBuilder(
        column: $table.url,
        builder: (column) => i0.ColumnWithTypeConverterFilters(column),
      );

  i0.ColumnWithTypeConverterFilters<
    i2.StoredTopSiteSource,
    i2.StoredTopSiteSource,
    int
  >
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.ColumnFilters<String> get orderKey => $composableBuilder(
    column: $table.orderKey,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $TopSiteOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.TopSite> {
  $TopSiteOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<int> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get orderKey => $composableBuilder(
    column: $table.orderKey,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $TopSiteAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.TopSite> {
  $TopSiteAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  i0.GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<Uri, String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<i2.StoredTopSiteSource, int> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  i0.GeneratedColumn<String> get orderKey =>
      $composableBuilder(column: $table.orderKey, builder: (column) => column);

  i0.GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $TopSiteTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i1.TopSite,
          i1.TopSiteData,
          i1.$TopSiteFilterComposer,
          i1.$TopSiteOrderingComposer,
          i1.$TopSiteAnnotationComposer,
          $TopSiteCreateCompanionBuilder,
          $TopSiteUpdateCompanionBuilder,
          (
            i1.TopSiteData,
            i0.BaseReferences<i0.GeneratedDatabase, i1.TopSite, i1.TopSiteData>,
          ),
          i1.TopSiteData,
          i0.PrefetchHooks Function()
        > {
  $TopSiteTableManager(i0.GeneratedDatabase db, i1.TopSite table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i1.$TopSiteFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i1.$TopSiteOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i1.$TopSiteAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> id = const i0.Value.absent(),
                i0.Value<String> title = const i0.Value.absent(),
                i0.Value<Uri> url = const i0.Value.absent(),
                i0.Value<i2.StoredTopSiteSource> source =
                    const i0.Value.absent(),
                i0.Value<String> orderKey = const i0.Value.absent(),
                i0.Value<DateTime> createdAt = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.TopSiteCompanion(
                id: id,
                title: title,
                url: url,
                source: source,
                orderKey: orderKey,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required Uri url,
                required i2.StoredTopSiteSource source,
                required String orderKey,
                required DateTime createdAt,
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.TopSiteCompanion.insert(
                id: id,
                title: title,
                url: url,
                source: source,
                orderKey: orderKey,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $TopSiteProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i1.TopSite,
      i1.TopSiteData,
      i1.$TopSiteFilterComposer,
      i1.$TopSiteOrderingComposer,
      i1.$TopSiteAnnotationComposer,
      $TopSiteCreateCompanionBuilder,
      $TopSiteUpdateCompanionBuilder,
      (
        i1.TopSiteData,
        i0.BaseReferences<i0.GeneratedDatabase, i1.TopSite, i1.TopSiteData>,
      ),
      i1.TopSiteData,
      i0.PrefetchHooks Function()
    >;
typedef $HiddenTopSiteCreateCompanionBuilder =
    i1.HiddenTopSiteCompanion Function({required Uri url, i0.Value<int> rowid});
typedef $HiddenTopSiteUpdateCompanionBuilder =
    i1.HiddenTopSiteCompanion Function({
      i0.Value<Uri> url,
      i0.Value<int> rowid,
    });

class $HiddenTopSiteFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.HiddenTopSite> {
  $HiddenTopSiteFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnWithTypeConverterFilters<Uri, Uri, String> get url =>
      $composableBuilder(
        column: $table.url,
        builder: (column) => i0.ColumnWithTypeConverterFilters(column),
      );
}

class $HiddenTopSiteOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.HiddenTopSite> {
  $HiddenTopSiteOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $HiddenTopSiteAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.HiddenTopSite> {
  $HiddenTopSiteAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumnWithTypeConverter<Uri, String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);
}

class $HiddenTopSiteTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i1.HiddenTopSite,
          i1.HiddenTopSiteData,
          i1.$HiddenTopSiteFilterComposer,
          i1.$HiddenTopSiteOrderingComposer,
          i1.$HiddenTopSiteAnnotationComposer,
          $HiddenTopSiteCreateCompanionBuilder,
          $HiddenTopSiteUpdateCompanionBuilder,
          (
            i1.HiddenTopSiteData,
            i0.BaseReferences<
              i0.GeneratedDatabase,
              i1.HiddenTopSite,
              i1.HiddenTopSiteData
            >,
          ),
          i1.HiddenTopSiteData,
          i0.PrefetchHooks Function()
        > {
  $HiddenTopSiteTableManager(i0.GeneratedDatabase db, i1.HiddenTopSite table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i1.$HiddenTopSiteFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i1.$HiddenTopSiteOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i1.$HiddenTopSiteAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<Uri> url = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.HiddenTopSiteCompanion(url: url, rowid: rowid),
          createCompanionCallback:
              ({
                required Uri url,
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.HiddenTopSiteCompanion.insert(url: url, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $HiddenTopSiteProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i1.HiddenTopSite,
      i1.HiddenTopSiteData,
      i1.$HiddenTopSiteFilterComposer,
      i1.$HiddenTopSiteOrderingComposer,
      i1.$HiddenTopSiteAnnotationComposer,
      $HiddenTopSiteCreateCompanionBuilder,
      $HiddenTopSiteUpdateCompanionBuilder,
      (
        i1.HiddenTopSiteData,
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i1.HiddenTopSite,
          i1.HiddenTopSiteData
        >,
      ),
      i1.HiddenTopSiteData,
      i0.PrefetchHooks Function()
    >;

class TopSite extends i0.Table with i0.TableInfo<TopSite, i1.TopSiteData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  TopSite(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> id = i0.GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  late final i0.GeneratedColumn<String> title = i0.GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumnWithTypeConverter<Uri, String> url =
      i0.GeneratedColumn<String>(
        'url',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Uri>(i1.TopSite.$converterurl);
  late final i0.GeneratedColumnWithTypeConverter<i2.StoredTopSiteSource, int>
  source = i0.GeneratedColumn<int>(
    'source',
    aliasedName,
    false,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  ).withConverter<i2.StoredTopSiteSource>(i1.TopSite.$convertersource);
  late final i0.GeneratedColumn<String> orderKey = i0.GeneratedColumn<String>(
    'order_key',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumn<DateTime> createdAt =
      i0.GeneratedColumn<DateTime>(
        'created_at',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  @override
  List<i0.GeneratedColumn> get $columns => [
    id,
    title,
    url,
    source,
    orderKey,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'top_site';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<i0.GeneratedColumn>> get uniqueKeys => [
    {url},
  ];
  @override
  i1.TopSiteData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.TopSiteData(
      id: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      url: i1.TopSite.$converterurl.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}url'],
        )!,
      ),
      source: i1.TopSite.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.int,
          data['${effectivePrefix}source'],
        )!,
      ),
      orderKey: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}order_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  TopSite createAlias(String alias) {
    return TopSite(attachedDatabase, alias);
  }

  static i0.TypeConverter<Uri, String> $converterurl = const i3.UriConverter();
  static i0.JsonTypeConverter2<i2.StoredTopSiteSource, int, int>
  $convertersource = const i0.EnumIndexConverter<i2.StoredTopSiteSource>(
    i2.StoredTopSiteSource.values,
  );
  @override
  List<String> get customConstraints => const ['UNIQUE(url)'];
  @override
  bool get dontWriteConstraints => true;
}

class TopSiteData extends i0.DataClass
    implements i0.Insertable<i1.TopSiteData> {
  final String id;
  final String title;
  final Uri url;
  final i2.StoredTopSiteSource source;
  final String orderKey;
  final DateTime createdAt;
  const TopSiteData({
    required this.id,
    required this.title,
    required this.url,
    required this.source,
    required this.orderKey,
    required this.createdAt,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['id'] = i0.Variable<String>(id);
    map['title'] = i0.Variable<String>(title);
    {
      map['url'] = i0.Variable<String>(i1.TopSite.$converterurl.toSql(url));
    }
    {
      map['source'] = i0.Variable<int>(
        i1.TopSite.$convertersource.toSql(source),
      );
    }
    map['order_key'] = i0.Variable<String>(orderKey);
    map['created_at'] = i0.Variable<DateTime>(createdAt);
    return map;
  }

  factory TopSiteData.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return TopSiteData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<Uri>(json['url']),
      source: i1.TopSite.$convertersource.fromJson(
        serializer.fromJson<int>(json['source']),
      ),
      orderKey: serializer.fromJson<String>(json['order_key']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<Uri>(url),
      'source': serializer.toJson<int>(
        i1.TopSite.$convertersource.toJson(source),
      ),
      'order_key': serializer.toJson<String>(orderKey),
      'created_at': serializer.toJson<DateTime>(createdAt),
    };
  }

  i1.TopSiteData copyWith({
    String? id,
    String? title,
    Uri? url,
    i2.StoredTopSiteSource? source,
    String? orderKey,
    DateTime? createdAt,
  }) => i1.TopSiteData(
    id: id ?? this.id,
    title: title ?? this.title,
    url: url ?? this.url,
    source: source ?? this.source,
    orderKey: orderKey ?? this.orderKey,
    createdAt: createdAt ?? this.createdAt,
  );
  TopSiteData copyWithCompanion(i1.TopSiteCompanion data) {
    return TopSiteData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      source: data.source.present ? data.source.value : this.source,
      orderKey: data.orderKey.present ? data.orderKey.value : this.orderKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TopSiteData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('source: $source, ')
          ..write('orderKey: $orderKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, url, source, orderKey, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.TopSiteData &&
          other.id == this.id &&
          other.title == this.title &&
          other.url == this.url &&
          other.source == this.source &&
          other.orderKey == this.orderKey &&
          other.createdAt == this.createdAt);
}

class TopSiteCompanion extends i0.UpdateCompanion<i1.TopSiteData> {
  final i0.Value<String> id;
  final i0.Value<String> title;
  final i0.Value<Uri> url;
  final i0.Value<i2.StoredTopSiteSource> source;
  final i0.Value<String> orderKey;
  final i0.Value<DateTime> createdAt;
  final i0.Value<int> rowid;
  const TopSiteCompanion({
    this.id = const i0.Value.absent(),
    this.title = const i0.Value.absent(),
    this.url = const i0.Value.absent(),
    this.source = const i0.Value.absent(),
    this.orderKey = const i0.Value.absent(),
    this.createdAt = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  TopSiteCompanion.insert({
    required String id,
    required String title,
    required Uri url,
    required i2.StoredTopSiteSource source,
    required String orderKey,
    required DateTime createdAt,
    this.rowid = const i0.Value.absent(),
  }) : id = i0.Value(id),
       title = i0.Value(title),
       url = i0.Value(url),
       source = i0.Value(source),
       orderKey = i0.Value(orderKey),
       createdAt = i0.Value(createdAt);
  static i0.Insertable<i1.TopSiteData> custom({
    i0.Expression<String>? id,
    i0.Expression<String>? title,
    i0.Expression<String>? url,
    i0.Expression<int>? source,
    i0.Expression<String>? orderKey,
    i0.Expression<DateTime>? createdAt,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (source != null) 'source': source,
      if (orderKey != null) 'order_key': orderKey,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i1.TopSiteCompanion copyWith({
    i0.Value<String>? id,
    i0.Value<String>? title,
    i0.Value<Uri>? url,
    i0.Value<i2.StoredTopSiteSource>? source,
    i0.Value<String>? orderKey,
    i0.Value<DateTime>? createdAt,
    i0.Value<int>? rowid,
  }) {
    return i1.TopSiteCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      source: source ?? this.source,
      orderKey: orderKey ?? this.orderKey,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (id.present) {
      map['id'] = i0.Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = i0.Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = i0.Variable<String>(
        i1.TopSite.$converterurl.toSql(url.value),
      );
    }
    if (source.present) {
      map['source'] = i0.Variable<int>(
        i1.TopSite.$convertersource.toSql(source.value),
      );
    }
    if (orderKey.present) {
      map['order_key'] = i0.Variable<String>(orderKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = i0.Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TopSiteCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('source: $source, ')
          ..write('orderKey: $orderKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

i0.Index get idxTopSiteOrderKey => i0.Index(
  'idx_top_site_order_key',
  'CREATE INDEX idx_top_site_order_key ON top_site (order_key)',
);

class HiddenTopSite extends i0.Table
    with i0.TableInfo<HiddenTopSite, i1.HiddenTopSiteData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  HiddenTopSite(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumnWithTypeConverter<Uri, String> url =
      i0.GeneratedColumn<String>(
        'url',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'PRIMARY KEY NOT NULL',
      ).withConverter<Uri>(i1.HiddenTopSite.$converterurl);
  @override
  List<i0.GeneratedColumn> get $columns => [url];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hidden_top_site';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {url};
  @override
  i1.HiddenTopSiteData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.HiddenTopSiteData(
      url: i1.HiddenTopSite.$converterurl.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}url'],
        )!,
      ),
    );
  }

  @override
  HiddenTopSite createAlias(String alias) {
    return HiddenTopSite(attachedDatabase, alias);
  }

  static i0.TypeConverter<Uri, String> $converterurl = const i3.UriConverter();
  @override
  bool get dontWriteConstraints => true;
}

class HiddenTopSiteData extends i0.DataClass
    implements i0.Insertable<i1.HiddenTopSiteData> {
  final Uri url;
  const HiddenTopSiteData({required this.url});
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    {
      map['url'] = i0.Variable<String>(
        i1.HiddenTopSite.$converterurl.toSql(url),
      );
    }
    return map;
  }

  factory HiddenTopSiteData.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return HiddenTopSiteData(url: serializer.fromJson<Uri>(json['url']));
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'url': serializer.toJson<Uri>(url)};
  }

  i1.HiddenTopSiteData copyWith({Uri? url}) =>
      i1.HiddenTopSiteData(url: url ?? this.url);
  HiddenTopSiteData copyWithCompanion(i1.HiddenTopSiteCompanion data) {
    return HiddenTopSiteData(url: data.url.present ? data.url.value : this.url);
  }

  @override
  String toString() {
    return (StringBuffer('HiddenTopSiteData(')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => url.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.HiddenTopSiteData && other.url == this.url);
}

class HiddenTopSiteCompanion extends i0.UpdateCompanion<i1.HiddenTopSiteData> {
  final i0.Value<Uri> url;
  final i0.Value<int> rowid;
  const HiddenTopSiteCompanion({
    this.url = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  HiddenTopSiteCompanion.insert({
    required Uri url,
    this.rowid = const i0.Value.absent(),
  }) : url = i0.Value(url);
  static i0.Insertable<i1.HiddenTopSiteData> custom({
    i0.Expression<String>? url,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (url != null) 'url': url,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i1.HiddenTopSiteCompanion copyWith({
    i0.Value<Uri>? url,
    i0.Value<int>? rowid,
  }) {
    return i1.HiddenTopSiteCompanion(
      url: url ?? this.url,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (url.present) {
      map['url'] = i0.Variable<String>(
        i1.HiddenTopSite.$converterurl.toSql(url.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HiddenTopSiteCompanion(')
          ..write('url: $url, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class DefinitionsDrift extends i4.ModularAccessor {
  DefinitionsDrift(i0.GeneratedDatabase db) : super(db);
  i0.Selectable<String> leadingOrderKey({required int bucket}) {
    return customSelect(
      'SELECT lexo_rank_previous(?1, (SELECT order_key FROM top_site ORDER BY order_key LIMIT 1)) AS _c0',
      variables: [i0.Variable<int>(bucket)],
      readsFrom: {topSite},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> trailingOrderKey({required int bucket}) {
    return customSelect(
      'SELECT lexo_rank_next(?1, (SELECT order_key FROM top_site ORDER BY order_key DESC LIMIT 1)) AS _c0',
      variables: [i0.Variable<int>(bucket)],
      readsFrom: {topSite},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> orderKeyAfterSite({required String siteId}) {
    return customSelect(
      'WITH ordered_table AS (SELECT id, order_key, LEAD(order_key)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS next_order_key FROM top_site) SELECT lexo_rank_reorder_after(order_key, next_order_key) AS _c0 FROM ordered_table WHERE id = ?1',
      variables: [i0.Variable<String>(siteId)],
      readsFrom: {topSite},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> orderKeyBeforeSite({required String siteId}) {
    return customSelect(
      'WITH ordered_table AS (SELECT id, order_key, LAG(order_key)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS prev_order_key FROM top_site) SELECT lexo_rank_reorder_before(order_key, prev_order_key) AS _c0 FROM ordered_table WHERE id = ?1',
      variables: [i0.Variable<String>(siteId)],
      readsFrom: {topSite},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i1.TopSite get topSite => i4.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i1.TopSite>('top_site');
}
