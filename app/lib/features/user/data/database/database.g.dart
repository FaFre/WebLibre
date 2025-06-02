// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class Setting extends Table with TableInfo<Setting, SettingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Setting(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  late final GeneratedColumn<String> partitionKey = GeneratedColumn<String>(
    'partition_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumn<DriftAny> value = GeneratedColumn<DriftAny>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.any,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [key, partitionKey, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting';
  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      partitionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partition_key'],
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.any,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  Setting createAlias(String alias) {
    return Setting(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  bool get dontWriteConstraints => true;
}

class SettingData extends DataClass implements Insertable<SettingData> {
  final String key;
  final String? partitionKey;
  final DriftAny? value;
  const SettingData({required this.key, this.partitionKey, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || partitionKey != null) {
      map['partition_key'] = Variable<String>(partitionKey);
    }
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<DriftAny>(value);
    }
    return map;
  }

  factory SettingData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingData(
      key: serializer.fromJson<String>(json['key']),
      partitionKey: serializer.fromJson<String?>(json['partition_key']),
      value: serializer.fromJson<DriftAny?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'partition_key': serializer.toJson<String?>(partitionKey),
      'value': serializer.toJson<DriftAny?>(value),
    };
  }

  SettingData copyWith({
    String? key,
    Value<String?> partitionKey = const Value.absent(),
    Value<DriftAny?> value = const Value.absent(),
  }) => SettingData(
    key: key ?? this.key,
    partitionKey: partitionKey.present ? partitionKey.value : this.partitionKey,
    value: value.present ? value.value : this.value,
  );
  SettingData copyWithCompanion(SettingCompanion data) {
    return SettingData(
      key: data.key.present ? data.key.value : this.key,
      partitionKey: data.partitionKey.present
          ? data.partitionKey.value
          : this.partitionKey,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingData(')
          ..write('key: $key, ')
          ..write('partitionKey: $partitionKey, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, partitionKey, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingData &&
          other.key == this.key &&
          other.partitionKey == this.partitionKey &&
          other.value == this.value);
}

class SettingCompanion extends UpdateCompanion<SettingData> {
  final Value<String> key;
  final Value<String?> partitionKey;
  final Value<DriftAny?> value;
  final Value<int> rowid;
  const SettingCompanion({
    this.key = const Value.absent(),
    this.partitionKey = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingCompanion.insert({
    required String key,
    this.partitionKey = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<SettingData> custom({
    Expression<String>? key,
    Expression<String>? partitionKey,
    Expression<DriftAny>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (partitionKey != null) 'partition_key': partitionKey,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingCompanion copyWith({
    Value<String>? key,
    Value<String?>? partitionKey,
    Value<DriftAny?>? value,
    Value<int>? rowid,
  }) {
    return SettingCompanion(
      key: key ?? this.key,
      partitionKey: partitionKey ?? this.partitionKey,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (partitionKey.present) {
      map['partition_key'] = Variable<String>(partitionKey.value);
    }
    if (value.present) {
      map['value'] = Variable<DriftAny>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingCompanion(')
          ..write('key: $key, ')
          ..write('partitionKey: $partitionKey, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class IconCache extends Table with TableInfo<IconCache, IconCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  IconCache(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  late final GeneratedColumn<Uint8List> iconData = GeneratedColumn<Uint8List>(
    'icon_data',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<DateTime> fetchDate = GeneratedColumn<DateTime>(
    'fetch_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [origin, iconData, fetchDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'icon_cache';
  @override
  Set<GeneratedColumn> get $primaryKey => {origin};
  @override
  IconCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IconCacheData(
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      iconData: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}icon_data'],
      )!,
      fetchDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetch_date'],
      )!,
    );
  }

  @override
  IconCache createAlias(String alias) {
    return IconCache(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class IconCacheData extends DataClass implements Insertable<IconCacheData> {
  final String origin;
  final Uint8List iconData;
  final DateTime fetchDate;
  const IconCacheData({
    required this.origin,
    required this.iconData,
    required this.fetchDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['origin'] = Variable<String>(origin);
    map['icon_data'] = Variable<Uint8List>(iconData);
    map['fetch_date'] = Variable<DateTime>(fetchDate);
    return map;
  }

  factory IconCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IconCacheData(
      origin: serializer.fromJson<String>(json['origin']),
      iconData: serializer.fromJson<Uint8List>(json['icon_data']),
      fetchDate: serializer.fromJson<DateTime>(json['fetch_date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'origin': serializer.toJson<String>(origin),
      'icon_data': serializer.toJson<Uint8List>(iconData),
      'fetch_date': serializer.toJson<DateTime>(fetchDate),
    };
  }

  IconCacheData copyWith({
    String? origin,
    Uint8List? iconData,
    DateTime? fetchDate,
  }) => IconCacheData(
    origin: origin ?? this.origin,
    iconData: iconData ?? this.iconData,
    fetchDate: fetchDate ?? this.fetchDate,
  );
  IconCacheData copyWithCompanion(IconCacheCompanion data) {
    return IconCacheData(
      origin: data.origin.present ? data.origin.value : this.origin,
      iconData: data.iconData.present ? data.iconData.value : this.iconData,
      fetchDate: data.fetchDate.present ? data.fetchDate.value : this.fetchDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IconCacheData(')
          ..write('origin: $origin, ')
          ..write('iconData: $iconData, ')
          ..write('fetchDate: $fetchDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(origin, $driftBlobEquality.hash(iconData), fetchDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IconCacheData &&
          other.origin == this.origin &&
          $driftBlobEquality.equals(other.iconData, this.iconData) &&
          other.fetchDate == this.fetchDate);
}

class IconCacheCompanion extends UpdateCompanion<IconCacheData> {
  final Value<String> origin;
  final Value<Uint8List> iconData;
  final Value<DateTime> fetchDate;
  final Value<int> rowid;
  const IconCacheCompanion({
    this.origin = const Value.absent(),
    this.iconData = const Value.absent(),
    this.fetchDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IconCacheCompanion.insert({
    required String origin,
    required Uint8List iconData,
    required DateTime fetchDate,
    this.rowid = const Value.absent(),
  }) : origin = Value(origin),
       iconData = Value(iconData),
       fetchDate = Value(fetchDate);
  static Insertable<IconCacheData> custom({
    Expression<String>? origin,
    Expression<Uint8List>? iconData,
    Expression<DateTime>? fetchDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (origin != null) 'origin': origin,
      if (iconData != null) 'icon_data': iconData,
      if (fetchDate != null) 'fetch_date': fetchDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IconCacheCompanion copyWith({
    Value<String>? origin,
    Value<Uint8List>? iconData,
    Value<DateTime>? fetchDate,
    Value<int>? rowid,
  }) {
    return IconCacheCompanion(
      origin: origin ?? this.origin,
      iconData: iconData ?? this.iconData,
      fetchDate: fetchDate ?? this.fetchDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (iconData.present) {
      map['icon_data'] = Variable<Uint8List>(iconData.value);
    }
    if (fetchDate.present) {
      map['fetch_date'] = Variable<DateTime>(fetchDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IconCacheCompanion(')
          ..write('origin: $origin, ')
          ..write('iconData: $iconData, ')
          ..write('fetchDate: $fetchDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$UserDatabase extends GeneratedDatabase {
  _$UserDatabase(QueryExecutor e) : super(e);
  $UserDatabaseManager get managers => $UserDatabaseManager(this);
  late final Setting setting = Setting(this);
  late final IconCache iconCache = IconCache(this);
  late final SettingDao settingDao = SettingDao(this as UserDatabase);
  late final CacheDao cacheDao = CacheDao(this as UserDatabase);
  Future<int> evictCacheEntries({required int limit}) {
    return customUpdate(
      'DELETE FROM icon_cache WHERE "rowid" IN (SELECT "rowid" FROM icon_cache ORDER BY fetch_date DESC LIMIT -1 OFFSET ?1)',
      variables: [Variable<int>(limit)],
      updates: {iconCache},
      updateKind: UpdateKind.delete,
    );
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [setting, iconCache];
}

typedef $SettingCreateCompanionBuilder =
    SettingCompanion Function({
      required String key,
      Value<String?> partitionKey,
      Value<DriftAny?> value,
      Value<int> rowid,
    });
typedef $SettingUpdateCompanionBuilder =
    SettingCompanion Function({
      Value<String> key,
      Value<String?> partitionKey,
      Value<DriftAny?> value,
      Value<int> rowid,
    });

class $SettingFilterComposer extends Composer<_$UserDatabase, Setting> {
  $SettingFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partitionKey => $composableBuilder(
    column: $table.partitionKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DriftAny> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $SettingOrderingComposer extends Composer<_$UserDatabase, Setting> {
  $SettingOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partitionKey => $composableBuilder(
    column: $table.partitionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DriftAny> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SettingAnnotationComposer extends Composer<_$UserDatabase, Setting> {
  $SettingAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get partitionKey => $composableBuilder(
    column: $table.partitionKey,
    builder: (column) => column,
  );

  GeneratedColumn<DriftAny> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $SettingTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          Setting,
          SettingData,
          $SettingFilterComposer,
          $SettingOrderingComposer,
          $SettingAnnotationComposer,
          $SettingCreateCompanionBuilder,
          $SettingUpdateCompanionBuilder,
          (SettingData, BaseReferences<_$UserDatabase, Setting, SettingData>),
          SettingData,
          PrefetchHooks Function()
        > {
  $SettingTableManager(_$UserDatabase db, Setting table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SettingFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SettingOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SettingAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> partitionKey = const Value.absent(),
                Value<DriftAny?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingCompanion(
                key: key,
                partitionKey: partitionKey,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> partitionKey = const Value.absent(),
                Value<DriftAny?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingCompanion.insert(
                key: key,
                partitionKey: partitionKey,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $SettingProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      Setting,
      SettingData,
      $SettingFilterComposer,
      $SettingOrderingComposer,
      $SettingAnnotationComposer,
      $SettingCreateCompanionBuilder,
      $SettingUpdateCompanionBuilder,
      (SettingData, BaseReferences<_$UserDatabase, Setting, SettingData>),
      SettingData,
      PrefetchHooks Function()
    >;
typedef $IconCacheCreateCompanionBuilder =
    IconCacheCompanion Function({
      required String origin,
      required Uint8List iconData,
      required DateTime fetchDate,
      Value<int> rowid,
    });
typedef $IconCacheUpdateCompanionBuilder =
    IconCacheCompanion Function({
      Value<String> origin,
      Value<Uint8List> iconData,
      Value<DateTime> fetchDate,
      Value<int> rowid,
    });

class $IconCacheFilterComposer extends Composer<_$UserDatabase, IconCache> {
  $IconCacheFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get iconData => $composableBuilder(
    column: $table.iconData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchDate => $composableBuilder(
    column: $table.fetchDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $IconCacheOrderingComposer extends Composer<_$UserDatabase, IconCache> {
  $IconCacheOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get iconData => $composableBuilder(
    column: $table.iconData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchDate => $composableBuilder(
    column: $table.fetchDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $IconCacheAnnotationComposer extends Composer<_$UserDatabase, IconCache> {
  $IconCacheAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<Uint8List> get iconData =>
      $composableBuilder(column: $table.iconData, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchDate =>
      $composableBuilder(column: $table.fetchDate, builder: (column) => column);
}

class $IconCacheTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          IconCache,
          IconCacheData,
          $IconCacheFilterComposer,
          $IconCacheOrderingComposer,
          $IconCacheAnnotationComposer,
          $IconCacheCreateCompanionBuilder,
          $IconCacheUpdateCompanionBuilder,
          (
            IconCacheData,
            BaseReferences<_$UserDatabase, IconCache, IconCacheData>,
          ),
          IconCacheData,
          PrefetchHooks Function()
        > {
  $IconCacheTableManager(_$UserDatabase db, IconCache table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $IconCacheFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $IconCacheOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $IconCacheAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> origin = const Value.absent(),
                Value<Uint8List> iconData = const Value.absent(),
                Value<DateTime> fetchDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IconCacheCompanion(
                origin: origin,
                iconData: iconData,
                fetchDate: fetchDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String origin,
                required Uint8List iconData,
                required DateTime fetchDate,
                Value<int> rowid = const Value.absent(),
              }) => IconCacheCompanion.insert(
                origin: origin,
                iconData: iconData,
                fetchDate: fetchDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $IconCacheProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      IconCache,
      IconCacheData,
      $IconCacheFilterComposer,
      $IconCacheOrderingComposer,
      $IconCacheAnnotationComposer,
      $IconCacheCreateCompanionBuilder,
      $IconCacheUpdateCompanionBuilder,
      (IconCacheData, BaseReferences<_$UserDatabase, IconCache, IconCacheData>),
      IconCacheData,
      PrefetchHooks Function()
    >;

class $UserDatabaseManager {
  final _$UserDatabase _db;
  $UserDatabaseManager(this._db);
  $SettingTableManager get setting => $SettingTableManager(_db, _db.setting);
  $IconCacheTableManager get iconCache =>
      $IconCacheTableManager(_db, _db.iconCache);
}
