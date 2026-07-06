// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    as i1;
import 'package:flutter_singbox_proxy/src/singbox_proxy_api.g.dart' as i2;
import 'dart:typed_data' as i3;
import 'package:drift/internal/modular.dart' as i4;

typedef $SettingCreateCompanionBuilder =
    i1.SettingCompanion Function({
      required String key,
      i0.Value<String?> partitionKey,
      i0.Value<i0.DriftAny?> value,
      i0.Value<int> rowid,
    });
typedef $SettingUpdateCompanionBuilder =
    i1.SettingCompanion Function({
      i0.Value<String> key,
      i0.Value<String?> partitionKey,
      i0.Value<i0.DriftAny?> value,
      i0.Value<int> rowid,
    });

class $SettingFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.Setting> {
  $SettingFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get partitionKey => $composableBuilder(
    column: $table.partitionKey,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<i0.DriftAny> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $SettingOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.Setting> {
  $SettingOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get partitionKey => $composableBuilder(
    column: $table.partitionKey,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<i0.DriftAny> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $SettingAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.Setting> {
  $SettingAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  i0.GeneratedColumn<String> get partitionKey => $composableBuilder(
    column: $table.partitionKey,
    builder: (column) => column,
  );

  i0.GeneratedColumn<i0.DriftAny> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $SettingTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i1.Setting,
          i1.SettingData,
          i1.$SettingFilterComposer,
          i1.$SettingOrderingComposer,
          i1.$SettingAnnotationComposer,
          $SettingCreateCompanionBuilder,
          $SettingUpdateCompanionBuilder,
          (
            i1.SettingData,
            i0.BaseReferences<i0.GeneratedDatabase, i1.Setting, i1.SettingData>,
          ),
          i1.SettingData,
          i0.PrefetchHooks Function()
        > {
  $SettingTableManager(i0.GeneratedDatabase db, i1.Setting table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i1.$SettingFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i1.$SettingOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i1.$SettingAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> key = const i0.Value.absent(),
                i0.Value<String?> partitionKey = const i0.Value.absent(),
                i0.Value<i0.DriftAny?> value = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.SettingCompanion(
                key: key,
                partitionKey: partitionKey,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                i0.Value<String?> partitionKey = const i0.Value.absent(),
                i0.Value<i0.DriftAny?> value = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.SettingCompanion.insert(
                key: key,
                partitionKey: partitionKey,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $SettingProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i1.Setting,
      i1.SettingData,
      i1.$SettingFilterComposer,
      i1.$SettingOrderingComposer,
      i1.$SettingAnnotationComposer,
      $SettingCreateCompanionBuilder,
      $SettingUpdateCompanionBuilder,
      (
        i1.SettingData,
        i0.BaseReferences<i0.GeneratedDatabase, i1.Setting, i1.SettingData>,
      ),
      i1.SettingData,
      i0.PrefetchHooks Function()
    >;
typedef $ProxyProfileTableCreateCompanionBuilder =
    i1.ProxyProfileCompanion Function({
      required String id,
      required String name,
      required i2.SingboxProxyProfileType type,
      required String configJson,
      i0.Value<String?> dnsOverrideJson,
      i0.Value<DateTime> createdAt,
      i0.Value<DateTime> updatedAt,
      i0.Value<int> rowid,
    });
typedef $ProxyProfileTableUpdateCompanionBuilder =
    i1.ProxyProfileCompanion Function({
      i0.Value<String> id,
      i0.Value<String> name,
      i0.Value<i2.SingboxProxyProfileType> type,
      i0.Value<String> configJson,
      i0.Value<String?> dnsOverrideJson,
      i0.Value<DateTime> createdAt,
      i0.Value<DateTime> updatedAt,
      i0.Value<int> rowid,
    });

class $ProxyProfileTableFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.ProxyProfileTable> {
  $ProxyProfileTableFilterComposer({
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

  i0.ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<
    i2.SingboxProxyProfileType,
    i2.SingboxProxyProfileType,
    String
  >
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get dnsOverrideJson => $composableBuilder(
    column: $table.dnsOverrideJson,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $ProxyProfileTableOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.ProxyProfileTable> {
  $ProxyProfileTableOrderingComposer({
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

  i0.ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get dnsOverrideJson => $composableBuilder(
    column: $table.dnsOverrideJson,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $ProxyProfileTableAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.ProxyProfileTable> {
  $ProxyProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  i0.GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<i2.SingboxProxyProfileType, String>
  get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  i0.GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get dnsOverrideJson => $composableBuilder(
    column: $table.dnsOverrideJson,
    builder: (column) => column,
  );

  i0.GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  i0.GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $ProxyProfileTableTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i1.ProxyProfileTable,
          i1.ProxyProfile,
          i1.$ProxyProfileTableFilterComposer,
          i1.$ProxyProfileTableOrderingComposer,
          i1.$ProxyProfileTableAnnotationComposer,
          $ProxyProfileTableCreateCompanionBuilder,
          $ProxyProfileTableUpdateCompanionBuilder,
          (
            i1.ProxyProfile,
            i0.BaseReferences<
              i0.GeneratedDatabase,
              i1.ProxyProfileTable,
              i1.ProxyProfile
            >,
          ),
          i1.ProxyProfile,
          i0.PrefetchHooks Function()
        > {
  $ProxyProfileTableTableManager(
    i0.GeneratedDatabase db,
    i1.ProxyProfileTable table,
  ) : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i1.$ProxyProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i1.$ProxyProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i1.$ProxyProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> id = const i0.Value.absent(),
                i0.Value<String> name = const i0.Value.absent(),
                i0.Value<i2.SingboxProxyProfileType> type =
                    const i0.Value.absent(),
                i0.Value<String> configJson = const i0.Value.absent(),
                i0.Value<String?> dnsOverrideJson = const i0.Value.absent(),
                i0.Value<DateTime> createdAt = const i0.Value.absent(),
                i0.Value<DateTime> updatedAt = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.ProxyProfileCompanion(
                id: id,
                name: name,
                type: type,
                configJson: configJson,
                dnsOverrideJson: dnsOverrideJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required i2.SingboxProxyProfileType type,
                required String configJson,
                i0.Value<String?> dnsOverrideJson = const i0.Value.absent(),
                i0.Value<DateTime> createdAt = const i0.Value.absent(),
                i0.Value<DateTime> updatedAt = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.ProxyProfileCompanion.insert(
                id: id,
                name: name,
                type: type,
                configJson: configJson,
                dnsOverrideJson: dnsOverrideJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ProxyProfileTableProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i1.ProxyProfileTable,
      i1.ProxyProfile,
      i1.$ProxyProfileTableFilterComposer,
      i1.$ProxyProfileTableOrderingComposer,
      i1.$ProxyProfileTableAnnotationComposer,
      $ProxyProfileTableCreateCompanionBuilder,
      $ProxyProfileTableUpdateCompanionBuilder,
      (
        i1.ProxyProfile,
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i1.ProxyProfileTable,
          i1.ProxyProfile
        >,
      ),
      i1.ProxyProfile,
      i0.PrefetchHooks Function()
    >;
typedef $IconCacheCreateCompanionBuilder =
    i1.IconCacheCompanion Function({
      required String origin,
      required i3.Uint8List iconData,
      required DateTime fetchDate,
      i0.Value<int> rowid,
    });
typedef $IconCacheUpdateCompanionBuilder =
    i1.IconCacheCompanion Function({
      i0.Value<String> origin,
      i0.Value<i3.Uint8List> iconData,
      i0.Value<DateTime> fetchDate,
      i0.Value<int> rowid,
    });

class $IconCacheFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.IconCache> {
  $IconCacheFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<i3.Uint8List> get iconData => $composableBuilder(
    column: $table.iconData,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get fetchDate => $composableBuilder(
    column: $table.fetchDate,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $IconCacheOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.IconCache> {
  $IconCacheOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<i3.Uint8List> get iconData => $composableBuilder(
    column: $table.iconData,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get fetchDate => $composableBuilder(
    column: $table.fetchDate,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $IconCacheAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.IconCache> {
  $IconCacheAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  i0.GeneratedColumn<i3.Uint8List> get iconData =>
      $composableBuilder(column: $table.iconData, builder: (column) => column);

  i0.GeneratedColumn<DateTime> get fetchDate =>
      $composableBuilder(column: $table.fetchDate, builder: (column) => column);
}

class $IconCacheTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i1.IconCache,
          i1.IconCacheData,
          i1.$IconCacheFilterComposer,
          i1.$IconCacheOrderingComposer,
          i1.$IconCacheAnnotationComposer,
          $IconCacheCreateCompanionBuilder,
          $IconCacheUpdateCompanionBuilder,
          (
            i1.IconCacheData,
            i0.BaseReferences<
              i0.GeneratedDatabase,
              i1.IconCache,
              i1.IconCacheData
            >,
          ),
          i1.IconCacheData,
          i0.PrefetchHooks Function()
        > {
  $IconCacheTableManager(i0.GeneratedDatabase db, i1.IconCache table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i1.$IconCacheFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i1.$IconCacheOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i1.$IconCacheAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> origin = const i0.Value.absent(),
                i0.Value<i3.Uint8List> iconData = const i0.Value.absent(),
                i0.Value<DateTime> fetchDate = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.IconCacheCompanion(
                origin: origin,
                iconData: iconData,
                fetchDate: fetchDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String origin,
                required i3.Uint8List iconData,
                required DateTime fetchDate,
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.IconCacheCompanion.insert(
                origin: origin,
                iconData: iconData,
                fetchDate: fetchDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $IconCacheProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i1.IconCache,
      i1.IconCacheData,
      i1.$IconCacheFilterComposer,
      i1.$IconCacheOrderingComposer,
      i1.$IconCacheAnnotationComposer,
      $IconCacheCreateCompanionBuilder,
      $IconCacheUpdateCompanionBuilder,
      (
        i1.IconCacheData,
        i0.BaseReferences<i0.GeneratedDatabase, i1.IconCache, i1.IconCacheData>,
      ),
      i1.IconCacheData,
      i0.PrefetchHooks Function()
    >;
typedef $OnboardingCreateCompanionBuilder =
    i1.OnboardingCompanion Function({
      required int revision,
      required DateTime completionDate,
      i0.Value<int> rowid,
    });
typedef $OnboardingUpdateCompanionBuilder =
    i1.OnboardingCompanion Function({
      i0.Value<int> revision,
      i0.Value<DateTime> completionDate,
      i0.Value<int> rowid,
    });

class $OnboardingFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.Onboarding> {
  $OnboardingFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get completionDate => $composableBuilder(
    column: $table.completionDate,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $OnboardingOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.Onboarding> {
  $OnboardingOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get completionDate => $composableBuilder(
    column: $table.completionDate,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $OnboardingAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.Onboarding> {
  $OnboardingAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  i0.GeneratedColumn<DateTime> get completionDate => $composableBuilder(
    column: $table.completionDate,
    builder: (column) => column,
  );
}

class $OnboardingTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i1.Onboarding,
          i1.OnboardingData,
          i1.$OnboardingFilterComposer,
          i1.$OnboardingOrderingComposer,
          i1.$OnboardingAnnotationComposer,
          $OnboardingCreateCompanionBuilder,
          $OnboardingUpdateCompanionBuilder,
          (
            i1.OnboardingData,
            i0.BaseReferences<
              i0.GeneratedDatabase,
              i1.Onboarding,
              i1.OnboardingData
            >,
          ),
          i1.OnboardingData,
          i0.PrefetchHooks Function()
        > {
  $OnboardingTableManager(i0.GeneratedDatabase db, i1.Onboarding table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i1.$OnboardingFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i1.$OnboardingOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i1.$OnboardingAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<int> revision = const i0.Value.absent(),
                i0.Value<DateTime> completionDate = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.OnboardingCompanion(
                revision: revision,
                completionDate: completionDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int revision,
                required DateTime completionDate,
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.OnboardingCompanion.insert(
                revision: revision,
                completionDate: completionDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $OnboardingProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i1.Onboarding,
      i1.OnboardingData,
      i1.$OnboardingFilterComposer,
      i1.$OnboardingOrderingComposer,
      i1.$OnboardingAnnotationComposer,
      $OnboardingCreateCompanionBuilder,
      $OnboardingUpdateCompanionBuilder,
      (
        i1.OnboardingData,
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i1.Onboarding,
          i1.OnboardingData
        >,
      ),
      i1.OnboardingData,
      i0.PrefetchHooks Function()
    >;
typedef $RiverpodCreateCompanionBuilder =
    i1.RiverpodCompanion Function({
      required String key,
      required String json,
      i0.Value<DateTime?> expireAt,
      i0.Value<String?> destroyKey,
    });
typedef $RiverpodUpdateCompanionBuilder =
    i1.RiverpodCompanion Function({
      i0.Value<String> key,
      i0.Value<String> json,
      i0.Value<DateTime?> expireAt,
      i0.Value<String?> destroyKey,
    });

class $RiverpodFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.Riverpod> {
  $RiverpodFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get expireAt => $composableBuilder(
    column: $table.expireAt,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get destroyKey => $composableBuilder(
    column: $table.destroyKey,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $RiverpodOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.Riverpod> {
  $RiverpodOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get expireAt => $composableBuilder(
    column: $table.expireAt,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get destroyKey => $composableBuilder(
    column: $table.destroyKey,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $RiverpodAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.Riverpod> {
  $RiverpodAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  i0.GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  i0.GeneratedColumn<DateTime> get expireAt =>
      $composableBuilder(column: $table.expireAt, builder: (column) => column);

  i0.GeneratedColumn<String> get destroyKey => $composableBuilder(
    column: $table.destroyKey,
    builder: (column) => column,
  );
}

class $RiverpodTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i1.Riverpod,
          i1.RiverpodData,
          i1.$RiverpodFilterComposer,
          i1.$RiverpodOrderingComposer,
          i1.$RiverpodAnnotationComposer,
          $RiverpodCreateCompanionBuilder,
          $RiverpodUpdateCompanionBuilder,
          (
            i1.RiverpodData,
            i0.BaseReferences<
              i0.GeneratedDatabase,
              i1.Riverpod,
              i1.RiverpodData
            >,
          ),
          i1.RiverpodData,
          i0.PrefetchHooks Function()
        > {
  $RiverpodTableManager(i0.GeneratedDatabase db, i1.Riverpod table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i1.$RiverpodFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i1.$RiverpodOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i1.$RiverpodAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> key = const i0.Value.absent(),
                i0.Value<String> json = const i0.Value.absent(),
                i0.Value<DateTime?> expireAt = const i0.Value.absent(),
                i0.Value<String?> destroyKey = const i0.Value.absent(),
              }) => i1.RiverpodCompanion(
                key: key,
                json: json,
                expireAt: expireAt,
                destroyKey: destroyKey,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String json,
                i0.Value<DateTime?> expireAt = const i0.Value.absent(),
                i0.Value<String?> destroyKey = const i0.Value.absent(),
              }) => i1.RiverpodCompanion.insert(
                key: key,
                json: json,
                expireAt: expireAt,
                destroyKey: destroyKey,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $RiverpodProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i1.Riverpod,
      i1.RiverpodData,
      i1.$RiverpodFilterComposer,
      i1.$RiverpodOrderingComposer,
      i1.$RiverpodAnnotationComposer,
      $RiverpodCreateCompanionBuilder,
      $RiverpodUpdateCompanionBuilder,
      (
        i1.RiverpodData,
        i0.BaseReferences<i0.GeneratedDatabase, i1.Riverpod, i1.RiverpodData>,
      ),
      i1.RiverpodData,
      i0.PrefetchHooks Function()
    >;
typedef $ToolbarButtonConfigsCreateCompanionBuilder =
    i1.ToolbarButtonConfigsCompanion Function({
      required String buttonId,
      required String orderKey,
      i0.Value<bool> isVisible,
      i0.Value<String?> fallbackId,
      i0.Value<int> rowid,
    });
typedef $ToolbarButtonConfigsUpdateCompanionBuilder =
    i1.ToolbarButtonConfigsCompanion Function({
      i0.Value<String> buttonId,
      i0.Value<String> orderKey,
      i0.Value<bool> isVisible,
      i0.Value<String?> fallbackId,
      i0.Value<int> rowid,
    });

class $ToolbarButtonConfigsFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.ToolbarButtonConfigs> {
  $ToolbarButtonConfigsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get buttonId => $composableBuilder(
    column: $table.buttonId,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get orderKey => $composableBuilder(
    column: $table.orderKey,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get fallbackId => $composableBuilder(
    column: $table.fallbackId,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $ToolbarButtonConfigsOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.ToolbarButtonConfigs> {
  $ToolbarButtonConfigsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get buttonId => $composableBuilder(
    column: $table.buttonId,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get orderKey => $composableBuilder(
    column: $table.orderKey,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get fallbackId => $composableBuilder(
    column: $table.fallbackId,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $ToolbarButtonConfigsAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.ToolbarButtonConfigs> {
  $ToolbarButtonConfigsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get buttonId =>
      $composableBuilder(column: $table.buttonId, builder: (column) => column);

  i0.GeneratedColumn<String> get orderKey =>
      $composableBuilder(column: $table.orderKey, builder: (column) => column);

  i0.GeneratedColumn<bool> get isVisible =>
      $composableBuilder(column: $table.isVisible, builder: (column) => column);

  i0.GeneratedColumn<String> get fallbackId => $composableBuilder(
    column: $table.fallbackId,
    builder: (column) => column,
  );
}

class $ToolbarButtonConfigsTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i1.ToolbarButtonConfigs,
          i1.ToolbarButtonConfig,
          i1.$ToolbarButtonConfigsFilterComposer,
          i1.$ToolbarButtonConfigsOrderingComposer,
          i1.$ToolbarButtonConfigsAnnotationComposer,
          $ToolbarButtonConfigsCreateCompanionBuilder,
          $ToolbarButtonConfigsUpdateCompanionBuilder,
          (
            i1.ToolbarButtonConfig,
            i0.BaseReferences<
              i0.GeneratedDatabase,
              i1.ToolbarButtonConfigs,
              i1.ToolbarButtonConfig
            >,
          ),
          i1.ToolbarButtonConfig,
          i0.PrefetchHooks Function()
        > {
  $ToolbarButtonConfigsTableManager(
    i0.GeneratedDatabase db,
    i1.ToolbarButtonConfigs table,
  ) : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i1.$ToolbarButtonConfigsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i1.$ToolbarButtonConfigsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => i1
              .$ToolbarButtonConfigsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> buttonId = const i0.Value.absent(),
                i0.Value<String> orderKey = const i0.Value.absent(),
                i0.Value<bool> isVisible = const i0.Value.absent(),
                i0.Value<String?> fallbackId = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.ToolbarButtonConfigsCompanion(
                buttonId: buttonId,
                orderKey: orderKey,
                isVisible: isVisible,
                fallbackId: fallbackId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String buttonId,
                required String orderKey,
                i0.Value<bool> isVisible = const i0.Value.absent(),
                i0.Value<String?> fallbackId = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.ToolbarButtonConfigsCompanion.insert(
                buttonId: buttonId,
                orderKey: orderKey,
                isVisible: isVisible,
                fallbackId: fallbackId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ToolbarButtonConfigsProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i1.ToolbarButtonConfigs,
      i1.ToolbarButtonConfig,
      i1.$ToolbarButtonConfigsFilterComposer,
      i1.$ToolbarButtonConfigsOrderingComposer,
      i1.$ToolbarButtonConfigsAnnotationComposer,
      $ToolbarButtonConfigsCreateCompanionBuilder,
      $ToolbarButtonConfigsUpdateCompanionBuilder,
      (
        i1.ToolbarButtonConfig,
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i1.ToolbarButtonConfigs,
          i1.ToolbarButtonConfig
        >,
      ),
      i1.ToolbarButtonConfig,
      i0.PrefetchHooks Function()
    >;
typedef $QuickSwitcherButtonConfigsCreateCompanionBuilder =
    i1.QuickSwitcherButtonConfigsCompanion Function({
      required String buttonId,
      required String orderKey,
      i0.Value<bool> isVisible,
      i0.Value<String?> fallbackId,
      i0.Value<int> rowid,
    });
typedef $QuickSwitcherButtonConfigsUpdateCompanionBuilder =
    i1.QuickSwitcherButtonConfigsCompanion Function({
      i0.Value<String> buttonId,
      i0.Value<String> orderKey,
      i0.Value<bool> isVisible,
      i0.Value<String?> fallbackId,
      i0.Value<int> rowid,
    });

class $QuickSwitcherButtonConfigsFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.QuickSwitcherButtonConfigs> {
  $QuickSwitcherButtonConfigsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get buttonId => $composableBuilder(
    column: $table.buttonId,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get orderKey => $composableBuilder(
    column: $table.orderKey,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get fallbackId => $composableBuilder(
    column: $table.fallbackId,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $QuickSwitcherButtonConfigsOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.QuickSwitcherButtonConfigs> {
  $QuickSwitcherButtonConfigsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get buttonId => $composableBuilder(
    column: $table.buttonId,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get orderKey => $composableBuilder(
    column: $table.orderKey,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get fallbackId => $composableBuilder(
    column: $table.fallbackId,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $QuickSwitcherButtonConfigsAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.QuickSwitcherButtonConfigs> {
  $QuickSwitcherButtonConfigsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get buttonId =>
      $composableBuilder(column: $table.buttonId, builder: (column) => column);

  i0.GeneratedColumn<String> get orderKey =>
      $composableBuilder(column: $table.orderKey, builder: (column) => column);

  i0.GeneratedColumn<bool> get isVisible =>
      $composableBuilder(column: $table.isVisible, builder: (column) => column);

  i0.GeneratedColumn<String> get fallbackId => $composableBuilder(
    column: $table.fallbackId,
    builder: (column) => column,
  );
}

class $QuickSwitcherButtonConfigsTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i1.QuickSwitcherButtonConfigs,
          i1.QuickSwitcherButtonConfig,
          i1.$QuickSwitcherButtonConfigsFilterComposer,
          i1.$QuickSwitcherButtonConfigsOrderingComposer,
          i1.$QuickSwitcherButtonConfigsAnnotationComposer,
          $QuickSwitcherButtonConfigsCreateCompanionBuilder,
          $QuickSwitcherButtonConfigsUpdateCompanionBuilder,
          (
            i1.QuickSwitcherButtonConfig,
            i0.BaseReferences<
              i0.GeneratedDatabase,
              i1.QuickSwitcherButtonConfigs,
              i1.QuickSwitcherButtonConfig
            >,
          ),
          i1.QuickSwitcherButtonConfig,
          i0.PrefetchHooks Function()
        > {
  $QuickSwitcherButtonConfigsTableManager(
    i0.GeneratedDatabase db,
    i1.QuickSwitcherButtonConfigs table,
  ) : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i1.$QuickSwitcherButtonConfigsFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              i1.$QuickSwitcherButtonConfigsOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              i1.$QuickSwitcherButtonConfigsAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                i0.Value<String> buttonId = const i0.Value.absent(),
                i0.Value<String> orderKey = const i0.Value.absent(),
                i0.Value<bool> isVisible = const i0.Value.absent(),
                i0.Value<String?> fallbackId = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.QuickSwitcherButtonConfigsCompanion(
                buttonId: buttonId,
                orderKey: orderKey,
                isVisible: isVisible,
                fallbackId: fallbackId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String buttonId,
                required String orderKey,
                i0.Value<bool> isVisible = const i0.Value.absent(),
                i0.Value<String?> fallbackId = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.QuickSwitcherButtonConfigsCompanion.insert(
                buttonId: buttonId,
                orderKey: orderKey,
                isVisible: isVisible,
                fallbackId: fallbackId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $QuickSwitcherButtonConfigsProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i1.QuickSwitcherButtonConfigs,
      i1.QuickSwitcherButtonConfig,
      i1.$QuickSwitcherButtonConfigsFilterComposer,
      i1.$QuickSwitcherButtonConfigsOrderingComposer,
      i1.$QuickSwitcherButtonConfigsAnnotationComposer,
      $QuickSwitcherButtonConfigsCreateCompanionBuilder,
      $QuickSwitcherButtonConfigsUpdateCompanionBuilder,
      (
        i1.QuickSwitcherButtonConfig,
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i1.QuickSwitcherButtonConfigs,
          i1.QuickSwitcherButtonConfig
        >,
      ),
      i1.QuickSwitcherButtonConfig,
      i0.PrefetchHooks Function()
    >;
typedef $SearchTokensCreateCompanionBuilder =
    i1.SearchTokensCompanion Function({
      i0.Value<int> id,
      required i3.Uint8List token,
      required DateTime insertedAt,
      required String issuerKeyVersion,
      i0.Value<DateTime?> reservedAt,
    });
typedef $SearchTokensUpdateCompanionBuilder =
    i1.SearchTokensCompanion Function({
      i0.Value<int> id,
      i0.Value<i3.Uint8List> token,
      i0.Value<DateTime> insertedAt,
      i0.Value<String> issuerKeyVersion,
      i0.Value<DateTime?> reservedAt,
    });

class $SearchTokensFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.SearchTokens> {
  $SearchTokensFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<i3.Uint8List> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get insertedAt => $composableBuilder(
    column: $table.insertedAt,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get issuerKeyVersion => $composableBuilder(
    column: $table.issuerKeyVersion,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get reservedAt => $composableBuilder(
    column: $table.reservedAt,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $SearchTokensOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.SearchTokens> {
  $SearchTokensOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<i3.Uint8List> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get insertedAt => $composableBuilder(
    column: $table.insertedAt,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get issuerKeyVersion => $composableBuilder(
    column: $table.issuerKeyVersion,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get reservedAt => $composableBuilder(
    column: $table.reservedAt,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $SearchTokensAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.SearchTokens> {
  $SearchTokensAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  i0.GeneratedColumn<i3.Uint8List> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  i0.GeneratedColumn<DateTime> get insertedAt => $composableBuilder(
    column: $table.insertedAt,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get issuerKeyVersion => $composableBuilder(
    column: $table.issuerKeyVersion,
    builder: (column) => column,
  );

  i0.GeneratedColumn<DateTime> get reservedAt => $composableBuilder(
    column: $table.reservedAt,
    builder: (column) => column,
  );
}

class $SearchTokensTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i1.SearchTokens,
          i1.SearchToken,
          i1.$SearchTokensFilterComposer,
          i1.$SearchTokensOrderingComposer,
          i1.$SearchTokensAnnotationComposer,
          $SearchTokensCreateCompanionBuilder,
          $SearchTokensUpdateCompanionBuilder,
          (
            i1.SearchToken,
            i0.BaseReferences<
              i0.GeneratedDatabase,
              i1.SearchTokens,
              i1.SearchToken
            >,
          ),
          i1.SearchToken,
          i0.PrefetchHooks Function()
        > {
  $SearchTokensTableManager(i0.GeneratedDatabase db, i1.SearchTokens table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i1.$SearchTokensFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i1.$SearchTokensOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i1.$SearchTokensAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<int> id = const i0.Value.absent(),
                i0.Value<i3.Uint8List> token = const i0.Value.absent(),
                i0.Value<DateTime> insertedAt = const i0.Value.absent(),
                i0.Value<String> issuerKeyVersion = const i0.Value.absent(),
                i0.Value<DateTime?> reservedAt = const i0.Value.absent(),
              }) => i1.SearchTokensCompanion(
                id: id,
                token: token,
                insertedAt: insertedAt,
                issuerKeyVersion: issuerKeyVersion,
                reservedAt: reservedAt,
              ),
          createCompanionCallback:
              ({
                i0.Value<int> id = const i0.Value.absent(),
                required i3.Uint8List token,
                required DateTime insertedAt,
                required String issuerKeyVersion,
                i0.Value<DateTime?> reservedAt = const i0.Value.absent(),
              }) => i1.SearchTokensCompanion.insert(
                id: id,
                token: token,
                insertedAt: insertedAt,
                issuerKeyVersion: issuerKeyVersion,
                reservedAt: reservedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $SearchTokensProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i1.SearchTokens,
      i1.SearchToken,
      i1.$SearchTokensFilterComposer,
      i1.$SearchTokensOrderingComposer,
      i1.$SearchTokensAnnotationComposer,
      $SearchTokensCreateCompanionBuilder,
      $SearchTokensUpdateCompanionBuilder,
      (
        i1.SearchToken,
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i1.SearchTokens,
          i1.SearchToken
        >,
      ),
      i1.SearchToken,
      i0.PrefetchHooks Function()
    >;

class Setting extends i0.Table with i0.TableInfo<Setting, i1.SettingData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  Setting(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> key = i0.GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  late final i0.GeneratedColumn<String> partitionKey =
      i0.GeneratedColumn<String>(
        'partition_key',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<i0.DriftAny> value =
      i0.GeneratedColumn<i0.DriftAny>(
        'value',
        aliasedName,
        true,
        type: i0.DriftSqlType.any,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  @override
  List<i0.GeneratedColumn> get $columns => [key, partitionKey, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {key};
  @override
  i1.SettingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.SettingData(
      key: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      partitionKey: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}partition_key'],
      ),
      value: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.any,
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

class SettingData extends i0.DataClass
    implements i0.Insertable<i1.SettingData> {
  final String key;
  final String? partitionKey;
  final i0.DriftAny? value;
  const SettingData({required this.key, this.partitionKey, this.value});
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['key'] = i0.Variable<String>(key);
    if (!nullToAbsent || partitionKey != null) {
      map['partition_key'] = i0.Variable<String>(partitionKey);
    }
    if (!nullToAbsent || value != null) {
      map['value'] = i0.Variable<i0.DriftAny>(value);
    }
    return map;
  }

  factory SettingData.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return SettingData(
      key: serializer.fromJson<String>(json['key']),
      partitionKey: serializer.fromJson<String?>(json['partition_key']),
      value: serializer.fromJson<i0.DriftAny?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'partition_key': serializer.toJson<String?>(partitionKey),
      'value': serializer.toJson<i0.DriftAny?>(value),
    };
  }

  i1.SettingData copyWith({
    String? key,
    i0.Value<String?> partitionKey = const i0.Value.absent(),
    i0.Value<i0.DriftAny?> value = const i0.Value.absent(),
  }) => i1.SettingData(
    key: key ?? this.key,
    partitionKey: partitionKey.present ? partitionKey.value : this.partitionKey,
    value: value.present ? value.value : this.value,
  );
  SettingData copyWithCompanion(i1.SettingCompanion data) {
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
      (other is i1.SettingData &&
          other.key == this.key &&
          other.partitionKey == this.partitionKey &&
          other.value == this.value);
}

class SettingCompanion extends i0.UpdateCompanion<i1.SettingData> {
  final i0.Value<String> key;
  final i0.Value<String?> partitionKey;
  final i0.Value<i0.DriftAny?> value;
  final i0.Value<int> rowid;
  const SettingCompanion({
    this.key = const i0.Value.absent(),
    this.partitionKey = const i0.Value.absent(),
    this.value = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  SettingCompanion.insert({
    required String key,
    this.partitionKey = const i0.Value.absent(),
    this.value = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  }) : key = i0.Value(key);
  static i0.Insertable<i1.SettingData> custom({
    i0.Expression<String>? key,
    i0.Expression<String>? partitionKey,
    i0.Expression<i0.DriftAny>? value,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (key != null) 'key': key,
      if (partitionKey != null) 'partition_key': partitionKey,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i1.SettingCompanion copyWith({
    i0.Value<String>? key,
    i0.Value<String?>? partitionKey,
    i0.Value<i0.DriftAny?>? value,
    i0.Value<int>? rowid,
  }) {
    return i1.SettingCompanion(
      key: key ?? this.key,
      partitionKey: partitionKey ?? this.partitionKey,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (key.present) {
      map['key'] = i0.Variable<String>(key.value);
    }
    if (partitionKey.present) {
      map['partition_key'] = i0.Variable<String>(partitionKey.value);
    }
    if (value.present) {
      map['value'] = i0.Variable<i0.DriftAny>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
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

class ProxyProfileTable extends i0.Table
    with i0.TableInfo<ProxyProfileTable, i1.ProxyProfile> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  ProxyProfileTable(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> id = i0.GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  late final i0.GeneratedColumn<String> name = i0.GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumnWithTypeConverter<
    i2.SingboxProxyProfileType,
    String
  >
  type =
      i0.GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<i2.SingboxProxyProfileType>(
        i1.ProxyProfileTable.$convertertype,
      );
  late final i0.GeneratedColumn<String> configJson = i0.GeneratedColumn<String>(
    'config_json',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumn<String> dnsOverrideJson =
      i0.GeneratedColumn<String>(
        'dns_override_json',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<DateTime> createdAt =
      i0.GeneratedColumn<DateTime>(
        'created_at',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: false,
        $customConstraints: 'NOT NULL DEFAULT CURRENT_TIMESTAMP',
        defaultValue: const i0.CustomExpression('CURRENT_TIMESTAMP'),
      );
  late final i0.GeneratedColumn<DateTime> updatedAt =
      i0.GeneratedColumn<DateTime>(
        'updated_at',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: false,
        $customConstraints: 'NOT NULL DEFAULT CURRENT_TIMESTAMP',
        defaultValue: const i0.CustomExpression('CURRENT_TIMESTAMP'),
      );
  @override
  List<i0.GeneratedColumn> get $columns => [
    id,
    name,
    type,
    configJson,
    dnsOverrideJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'proxy_profile';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {id};
  @override
  i1.ProxyProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.ProxyProfile(
      id: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: i1.ProxyProfileTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      configJson: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      )!,
      dnsOverrideJson: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}dns_override_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  ProxyProfileTable createAlias(String alias) {
    return ProxyProfileTable(attachedDatabase, alias);
  }

  static i0.JsonTypeConverter2<i2.SingboxProxyProfileType, String, String>
  $convertertype = const i0.EnumNameConverter<i2.SingboxProxyProfileType>(
    i2.SingboxProxyProfileType.values,
  );
  @override
  bool get dontWriteConstraints => true;
}

class ProxyProfile extends i0.DataClass
    implements i0.Insertable<i1.ProxyProfile> {
  final String id;
  final String name;
  final i2.SingboxProxyProfileType type;
  final String configJson;
  final String? dnsOverrideJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProxyProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.configJson,
    this.dnsOverrideJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['id'] = i0.Variable<String>(id);
    map['name'] = i0.Variable<String>(name);
    {
      map['type'] = i0.Variable<String>(
        i1.ProxyProfileTable.$convertertype.toSql(type),
      );
    }
    map['config_json'] = i0.Variable<String>(configJson);
    if (!nullToAbsent || dnsOverrideJson != null) {
      map['dns_override_json'] = i0.Variable<String>(dnsOverrideJson);
    }
    map['created_at'] = i0.Variable<DateTime>(createdAt);
    map['updated_at'] = i0.Variable<DateTime>(updatedAt);
    return map;
  }

  factory ProxyProfile.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return ProxyProfile(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: i1.ProxyProfileTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      configJson: serializer.fromJson<String>(json['config_json']),
      dnsOverrideJson: serializer.fromJson<String?>(json['dns_override_json']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
      updatedAt: serializer.fromJson<DateTime>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(
        i1.ProxyProfileTable.$convertertype.toJson(type),
      ),
      'config_json': serializer.toJson<String>(configJson),
      'dns_override_json': serializer.toJson<String?>(dnsOverrideJson),
      'created_at': serializer.toJson<DateTime>(createdAt),
      'updated_at': serializer.toJson<DateTime>(updatedAt),
    };
  }

  i1.ProxyProfile copyWith({
    String? id,
    String? name,
    i2.SingboxProxyProfileType? type,
    String? configJson,
    i0.Value<String?> dnsOverrideJson = const i0.Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => i1.ProxyProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    configJson: configJson ?? this.configJson,
    dnsOverrideJson: dnsOverrideJson.present
        ? dnsOverrideJson.value
        : this.dnsOverrideJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProxyProfile copyWithCompanion(i1.ProxyProfileCompanion data) {
    return ProxyProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
      dnsOverrideJson: data.dnsOverrideJson.present
          ? data.dnsOverrideJson.value
          : this.dnsOverrideJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProxyProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('configJson: $configJson, ')
          ..write('dnsOverrideJson: $dnsOverrideJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    configJson,
    dnsOverrideJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.ProxyProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.configJson == this.configJson &&
          other.dnsOverrideJson == this.dnsOverrideJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProxyProfileCompanion extends i0.UpdateCompanion<i1.ProxyProfile> {
  final i0.Value<String> id;
  final i0.Value<String> name;
  final i0.Value<i2.SingboxProxyProfileType> type;
  final i0.Value<String> configJson;
  final i0.Value<String?> dnsOverrideJson;
  final i0.Value<DateTime> createdAt;
  final i0.Value<DateTime> updatedAt;
  final i0.Value<int> rowid;
  const ProxyProfileCompanion({
    this.id = const i0.Value.absent(),
    this.name = const i0.Value.absent(),
    this.type = const i0.Value.absent(),
    this.configJson = const i0.Value.absent(),
    this.dnsOverrideJson = const i0.Value.absent(),
    this.createdAt = const i0.Value.absent(),
    this.updatedAt = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  ProxyProfileCompanion.insert({
    required String id,
    required String name,
    required i2.SingboxProxyProfileType type,
    required String configJson,
    this.dnsOverrideJson = const i0.Value.absent(),
    this.createdAt = const i0.Value.absent(),
    this.updatedAt = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  }) : id = i0.Value(id),
       name = i0.Value(name),
       type = i0.Value(type),
       configJson = i0.Value(configJson);
  static i0.Insertable<i1.ProxyProfile> custom({
    i0.Expression<String>? id,
    i0.Expression<String>? name,
    i0.Expression<String>? type,
    i0.Expression<String>? configJson,
    i0.Expression<String>? dnsOverrideJson,
    i0.Expression<DateTime>? createdAt,
    i0.Expression<DateTime>? updatedAt,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (configJson != null) 'config_json': configJson,
      if (dnsOverrideJson != null) 'dns_override_json': dnsOverrideJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i1.ProxyProfileCompanion copyWith({
    i0.Value<String>? id,
    i0.Value<String>? name,
    i0.Value<i2.SingboxProxyProfileType>? type,
    i0.Value<String>? configJson,
    i0.Value<String?>? dnsOverrideJson,
    i0.Value<DateTime>? createdAt,
    i0.Value<DateTime>? updatedAt,
    i0.Value<int>? rowid,
  }) {
    return i1.ProxyProfileCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      configJson: configJson ?? this.configJson,
      dnsOverrideJson: dnsOverrideJson ?? this.dnsOverrideJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (id.present) {
      map['id'] = i0.Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = i0.Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = i0.Variable<String>(
        i1.ProxyProfileTable.$convertertype.toSql(type.value),
      );
    }
    if (configJson.present) {
      map['config_json'] = i0.Variable<String>(configJson.value);
    }
    if (dnsOverrideJson.present) {
      map['dns_override_json'] = i0.Variable<String>(dnsOverrideJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = i0.Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = i0.Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProxyProfileCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('configJson: $configJson, ')
          ..write('dnsOverrideJson: $dnsOverrideJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

i0.Index get idxProxyProfileUpdatedAt => i0.Index(
  'idx_proxy_profile_updated_at',
  'CREATE INDEX idx_proxy_profile_updated_at ON proxy_profile (updated_at)',
);

class IconCache extends i0.Table
    with i0.TableInfo<IconCache, i1.IconCacheData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  IconCache(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> origin = i0.GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  late final i0.GeneratedColumn<i3.Uint8List> iconData =
      i0.GeneratedColumn<i3.Uint8List>(
        'icon_data',
        aliasedName,
        false,
        type: i0.DriftSqlType.blob,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  late final i0.GeneratedColumn<DateTime> fetchDate =
      i0.GeneratedColumn<DateTime>(
        'fetch_date',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  @override
  List<i0.GeneratedColumn> get $columns => [origin, iconData, fetchDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'icon_cache';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {origin};
  @override
  i1.IconCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.IconCacheData(
      origin: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      iconData: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.blob,
        data['${effectivePrefix}icon_data'],
      )!,
      fetchDate: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
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

class IconCacheData extends i0.DataClass
    implements i0.Insertable<i1.IconCacheData> {
  final String origin;
  final i3.Uint8List iconData;
  final DateTime fetchDate;
  const IconCacheData({
    required this.origin,
    required this.iconData,
    required this.fetchDate,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['origin'] = i0.Variable<String>(origin);
    map['icon_data'] = i0.Variable<i3.Uint8List>(iconData);
    map['fetch_date'] = i0.Variable<DateTime>(fetchDate);
    return map;
  }

  factory IconCacheData.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return IconCacheData(
      origin: serializer.fromJson<String>(json['origin']),
      iconData: serializer.fromJson<i3.Uint8List>(json['icon_data']),
      fetchDate: serializer.fromJson<DateTime>(json['fetch_date']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'origin': serializer.toJson<String>(origin),
      'icon_data': serializer.toJson<i3.Uint8List>(iconData),
      'fetch_date': serializer.toJson<DateTime>(fetchDate),
    };
  }

  i1.IconCacheData copyWith({
    String? origin,
    i3.Uint8List? iconData,
    DateTime? fetchDate,
  }) => i1.IconCacheData(
    origin: origin ?? this.origin,
    iconData: iconData ?? this.iconData,
    fetchDate: fetchDate ?? this.fetchDate,
  );
  IconCacheData copyWithCompanion(i1.IconCacheCompanion data) {
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
      Object.hash(origin, i0.$driftBlobEquality.hash(iconData), fetchDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.IconCacheData &&
          other.origin == this.origin &&
          i0.$driftBlobEquality.equals(other.iconData, this.iconData) &&
          other.fetchDate == this.fetchDate);
}

class IconCacheCompanion extends i0.UpdateCompanion<i1.IconCacheData> {
  final i0.Value<String> origin;
  final i0.Value<i3.Uint8List> iconData;
  final i0.Value<DateTime> fetchDate;
  final i0.Value<int> rowid;
  const IconCacheCompanion({
    this.origin = const i0.Value.absent(),
    this.iconData = const i0.Value.absent(),
    this.fetchDate = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  IconCacheCompanion.insert({
    required String origin,
    required i3.Uint8List iconData,
    required DateTime fetchDate,
    this.rowid = const i0.Value.absent(),
  }) : origin = i0.Value(origin),
       iconData = i0.Value(iconData),
       fetchDate = i0.Value(fetchDate);
  static i0.Insertable<i1.IconCacheData> custom({
    i0.Expression<String>? origin,
    i0.Expression<i3.Uint8List>? iconData,
    i0.Expression<DateTime>? fetchDate,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (origin != null) 'origin': origin,
      if (iconData != null) 'icon_data': iconData,
      if (fetchDate != null) 'fetch_date': fetchDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i1.IconCacheCompanion copyWith({
    i0.Value<String>? origin,
    i0.Value<i3.Uint8List>? iconData,
    i0.Value<DateTime>? fetchDate,
    i0.Value<int>? rowid,
  }) {
    return i1.IconCacheCompanion(
      origin: origin ?? this.origin,
      iconData: iconData ?? this.iconData,
      fetchDate: fetchDate ?? this.fetchDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (origin.present) {
      map['origin'] = i0.Variable<String>(origin.value);
    }
    if (iconData.present) {
      map['icon_data'] = i0.Variable<i3.Uint8List>(iconData.value);
    }
    if (fetchDate.present) {
      map['fetch_date'] = i0.Variable<DateTime>(fetchDate.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
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

class Onboarding extends i0.Table
    with i0.TableInfo<Onboarding, i1.OnboardingData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  Onboarding(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<int> revision = i0.GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumn<DateTime> completionDate =
      i0.GeneratedColumn<DateTime>(
        'completion_date',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  @override
  List<i0.GeneratedColumn> get $columns => [revision, completionDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'onboarding';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => const {};
  @override
  i1.OnboardingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.OnboardingData(
      revision: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      completionDate: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}completion_date'],
      )!,
    );
  }

  @override
  Onboarding createAlias(String alias) {
    return Onboarding(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class OnboardingData extends i0.DataClass
    implements i0.Insertable<i1.OnboardingData> {
  final int revision;
  final DateTime completionDate;
  const OnboardingData({required this.revision, required this.completionDate});
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['revision'] = i0.Variable<int>(revision);
    map['completion_date'] = i0.Variable<DateTime>(completionDate);
    return map;
  }

  factory OnboardingData.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return OnboardingData(
      revision: serializer.fromJson<int>(json['revision']),
      completionDate: serializer.fromJson<DateTime>(json['completion_date']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'revision': serializer.toJson<int>(revision),
      'completion_date': serializer.toJson<DateTime>(completionDate),
    };
  }

  i1.OnboardingData copyWith({int? revision, DateTime? completionDate}) =>
      i1.OnboardingData(
        revision: revision ?? this.revision,
        completionDate: completionDate ?? this.completionDate,
      );
  OnboardingData copyWithCompanion(i1.OnboardingCompanion data) {
    return OnboardingData(
      revision: data.revision.present ? data.revision.value : this.revision,
      completionDate: data.completionDate.present
          ? data.completionDate.value
          : this.completionDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OnboardingData(')
          ..write('revision: $revision, ')
          ..write('completionDate: $completionDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(revision, completionDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.OnboardingData &&
          other.revision == this.revision &&
          other.completionDate == this.completionDate);
}

class OnboardingCompanion extends i0.UpdateCompanion<i1.OnboardingData> {
  final i0.Value<int> revision;
  final i0.Value<DateTime> completionDate;
  final i0.Value<int> rowid;
  const OnboardingCompanion({
    this.revision = const i0.Value.absent(),
    this.completionDate = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  OnboardingCompanion.insert({
    required int revision,
    required DateTime completionDate,
    this.rowid = const i0.Value.absent(),
  }) : revision = i0.Value(revision),
       completionDate = i0.Value(completionDate);
  static i0.Insertable<i1.OnboardingData> custom({
    i0.Expression<int>? revision,
    i0.Expression<DateTime>? completionDate,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (revision != null) 'revision': revision,
      if (completionDate != null) 'completion_date': completionDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i1.OnboardingCompanion copyWith({
    i0.Value<int>? revision,
    i0.Value<DateTime>? completionDate,
    i0.Value<int>? rowid,
  }) {
    return i1.OnboardingCompanion(
      revision: revision ?? this.revision,
      completionDate: completionDate ?? this.completionDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (revision.present) {
      map['revision'] = i0.Variable<int>(revision.value);
    }
    if (completionDate.present) {
      map['completion_date'] = i0.Variable<DateTime>(completionDate.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OnboardingCompanion(')
          ..write('revision: $revision, ')
          ..write('completionDate: $completionDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Riverpod extends i0.Table with i0.TableInfo<Riverpod, i1.RiverpodData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  Riverpod(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> key = i0.GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  late final i0.GeneratedColumn<String> json = i0.GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumn<DateTime> expireAt =
      i0.GeneratedColumn<DateTime>(
        'expireAt',
        aliasedName,
        true,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> destroyKey = i0.GeneratedColumn<String>(
    'destroyKey',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<i0.GeneratedColumn> get $columns => [key, json, expireAt, destroyKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'riverpod';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {key};
  @override
  i1.RiverpodData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.RiverpodData(
      key: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      json: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      expireAt: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}expireAt'],
      ),
      destroyKey: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}destroyKey'],
      ),
    );
  }

  @override
  Riverpod createAlias(String alias) {
    return Riverpod(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  bool get dontWriteConstraints => true;
}

class RiverpodData extends i0.DataClass
    implements i0.Insertable<i1.RiverpodData> {
  final String key;
  final String json;
  final DateTime? expireAt;
  final String? destroyKey;
  const RiverpodData({
    required this.key,
    required this.json,
    this.expireAt,
    this.destroyKey,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['key'] = i0.Variable<String>(key);
    map['json'] = i0.Variable<String>(json);
    if (!nullToAbsent || expireAt != null) {
      map['expireAt'] = i0.Variable<DateTime>(expireAt);
    }
    if (!nullToAbsent || destroyKey != null) {
      map['destroyKey'] = i0.Variable<String>(destroyKey);
    }
    return map;
  }

  factory RiverpodData.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return RiverpodData(
      key: serializer.fromJson<String>(json['key']),
      json: serializer.fromJson<String>(json['json']),
      expireAt: serializer.fromJson<DateTime?>(json['expireAt']),
      destroyKey: serializer.fromJson<String?>(json['destroyKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'json': serializer.toJson<String>(json),
      'expireAt': serializer.toJson<DateTime?>(expireAt),
      'destroyKey': serializer.toJson<String?>(destroyKey),
    };
  }

  i1.RiverpodData copyWith({
    String? key,
    String? json,
    i0.Value<DateTime?> expireAt = const i0.Value.absent(),
    i0.Value<String?> destroyKey = const i0.Value.absent(),
  }) => i1.RiverpodData(
    key: key ?? this.key,
    json: json ?? this.json,
    expireAt: expireAt.present ? expireAt.value : this.expireAt,
    destroyKey: destroyKey.present ? destroyKey.value : this.destroyKey,
  );
  RiverpodData copyWithCompanion(i1.RiverpodCompanion data) {
    return RiverpodData(
      key: data.key.present ? data.key.value : this.key,
      json: data.json.present ? data.json.value : this.json,
      expireAt: data.expireAt.present ? data.expireAt.value : this.expireAt,
      destroyKey: data.destroyKey.present
          ? data.destroyKey.value
          : this.destroyKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RiverpodData(')
          ..write('key: $key, ')
          ..write('json: $json, ')
          ..write('expireAt: $expireAt, ')
          ..write('destroyKey: $destroyKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, json, expireAt, destroyKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.RiverpodData &&
          other.key == this.key &&
          other.json == this.json &&
          other.expireAt == this.expireAt &&
          other.destroyKey == this.destroyKey);
}

class RiverpodCompanion extends i0.UpdateCompanion<i1.RiverpodData> {
  final i0.Value<String> key;
  final i0.Value<String> json;
  final i0.Value<DateTime?> expireAt;
  final i0.Value<String?> destroyKey;
  const RiverpodCompanion({
    this.key = const i0.Value.absent(),
    this.json = const i0.Value.absent(),
    this.expireAt = const i0.Value.absent(),
    this.destroyKey = const i0.Value.absent(),
  });
  RiverpodCompanion.insert({
    required String key,
    required String json,
    this.expireAt = const i0.Value.absent(),
    this.destroyKey = const i0.Value.absent(),
  }) : key = i0.Value(key),
       json = i0.Value(json);
  static i0.Insertable<i1.RiverpodData> custom({
    i0.Expression<String>? key,
    i0.Expression<String>? json,
    i0.Expression<DateTime>? expireAt,
    i0.Expression<String>? destroyKey,
  }) {
    return i0.RawValuesInsertable({
      if (key != null) 'key': key,
      if (json != null) 'json': json,
      if (expireAt != null) 'expireAt': expireAt,
      if (destroyKey != null) 'destroyKey': destroyKey,
    });
  }

  i1.RiverpodCompanion copyWith({
    i0.Value<String>? key,
    i0.Value<String>? json,
    i0.Value<DateTime?>? expireAt,
    i0.Value<String?>? destroyKey,
  }) {
    return i1.RiverpodCompanion(
      key: key ?? this.key,
      json: json ?? this.json,
      expireAt: expireAt ?? this.expireAt,
      destroyKey: destroyKey ?? this.destroyKey,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (key.present) {
      map['key'] = i0.Variable<String>(key.value);
    }
    if (json.present) {
      map['json'] = i0.Variable<String>(json.value);
    }
    if (expireAt.present) {
      map['expireAt'] = i0.Variable<DateTime>(expireAt.value);
    }
    if (destroyKey.present) {
      map['destroyKey'] = i0.Variable<String>(destroyKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RiverpodCompanion(')
          ..write('key: $key, ')
          ..write('json: $json, ')
          ..write('expireAt: $expireAt, ')
          ..write('destroyKey: $destroyKey')
          ..write(')'))
        .toString();
  }
}

class ToolbarButtonConfigs extends i0.Table
    with i0.TableInfo<ToolbarButtonConfigs, i1.ToolbarButtonConfig> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  ToolbarButtonConfigs(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> buttonId = i0.GeneratedColumn<String>(
    'button_id',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  late final i0.GeneratedColumn<String> orderKey = i0.GeneratedColumn<String>(
    'order_key',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumn<bool> isVisible = i0.GeneratedColumn<bool>(
    'is_visible',
    aliasedName,
    false,
    type: i0.DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT TRUE',
    defaultValue: const i0.CustomExpression('TRUE'),
  );
  late final i0.GeneratedColumn<String> fallbackId = i0.GeneratedColumn<String>(
    'fallback_id',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'REFERENCES toolbar_button_configs(button_id)ON DELETE SET NULL',
  );
  @override
  List<i0.GeneratedColumn> get $columns => [
    buttonId,
    orderKey,
    isVisible,
    fallbackId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'toolbar_button_configs';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {buttonId};
  @override
  i1.ToolbarButtonConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.ToolbarButtonConfig(
      buttonId: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}button_id'],
      )!,
      orderKey: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}order_key'],
      )!,
      isVisible: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.bool,
        data['${effectivePrefix}is_visible'],
      )!,
      fallbackId: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}fallback_id'],
      ),
    );
  }

  @override
  ToolbarButtonConfigs createAlias(String alias) {
    return ToolbarButtonConfigs(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class ToolbarButtonConfig extends i0.DataClass
    implements i0.Insertable<i1.ToolbarButtonConfig> {
  final String buttonId;
  final String orderKey;
  final bool isVisible;
  final String? fallbackId;
  const ToolbarButtonConfig({
    required this.buttonId,
    required this.orderKey,
    required this.isVisible,
    this.fallbackId,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['button_id'] = i0.Variable<String>(buttonId);
    map['order_key'] = i0.Variable<String>(orderKey);
    map['is_visible'] = i0.Variable<bool>(isVisible);
    if (!nullToAbsent || fallbackId != null) {
      map['fallback_id'] = i0.Variable<String>(fallbackId);
    }
    return map;
  }

  factory ToolbarButtonConfig.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return ToolbarButtonConfig(
      buttonId: serializer.fromJson<String>(json['button_id']),
      orderKey: serializer.fromJson<String>(json['order_key']),
      isVisible: serializer.fromJson<bool>(json['is_visible']),
      fallbackId: serializer.fromJson<String?>(json['fallback_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'button_id': serializer.toJson<String>(buttonId),
      'order_key': serializer.toJson<String>(orderKey),
      'is_visible': serializer.toJson<bool>(isVisible),
      'fallback_id': serializer.toJson<String?>(fallbackId),
    };
  }

  i1.ToolbarButtonConfig copyWith({
    String? buttonId,
    String? orderKey,
    bool? isVisible,
    i0.Value<String?> fallbackId = const i0.Value.absent(),
  }) => i1.ToolbarButtonConfig(
    buttonId: buttonId ?? this.buttonId,
    orderKey: orderKey ?? this.orderKey,
    isVisible: isVisible ?? this.isVisible,
    fallbackId: fallbackId.present ? fallbackId.value : this.fallbackId,
  );
  ToolbarButtonConfig copyWithCompanion(i1.ToolbarButtonConfigsCompanion data) {
    return ToolbarButtonConfig(
      buttonId: data.buttonId.present ? data.buttonId.value : this.buttonId,
      orderKey: data.orderKey.present ? data.orderKey.value : this.orderKey,
      isVisible: data.isVisible.present ? data.isVisible.value : this.isVisible,
      fallbackId: data.fallbackId.present
          ? data.fallbackId.value
          : this.fallbackId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ToolbarButtonConfig(')
          ..write('buttonId: $buttonId, ')
          ..write('orderKey: $orderKey, ')
          ..write('isVisible: $isVisible, ')
          ..write('fallbackId: $fallbackId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(buttonId, orderKey, isVisible, fallbackId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.ToolbarButtonConfig &&
          other.buttonId == this.buttonId &&
          other.orderKey == this.orderKey &&
          other.isVisible == this.isVisible &&
          other.fallbackId == this.fallbackId);
}

class ToolbarButtonConfigsCompanion
    extends i0.UpdateCompanion<i1.ToolbarButtonConfig> {
  final i0.Value<String> buttonId;
  final i0.Value<String> orderKey;
  final i0.Value<bool> isVisible;
  final i0.Value<String?> fallbackId;
  final i0.Value<int> rowid;
  const ToolbarButtonConfigsCompanion({
    this.buttonId = const i0.Value.absent(),
    this.orderKey = const i0.Value.absent(),
    this.isVisible = const i0.Value.absent(),
    this.fallbackId = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  ToolbarButtonConfigsCompanion.insert({
    required String buttonId,
    required String orderKey,
    this.isVisible = const i0.Value.absent(),
    this.fallbackId = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  }) : buttonId = i0.Value(buttonId),
       orderKey = i0.Value(orderKey);
  static i0.Insertable<i1.ToolbarButtonConfig> custom({
    i0.Expression<String>? buttonId,
    i0.Expression<String>? orderKey,
    i0.Expression<bool>? isVisible,
    i0.Expression<String>? fallbackId,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (buttonId != null) 'button_id': buttonId,
      if (orderKey != null) 'order_key': orderKey,
      if (isVisible != null) 'is_visible': isVisible,
      if (fallbackId != null) 'fallback_id': fallbackId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i1.ToolbarButtonConfigsCompanion copyWith({
    i0.Value<String>? buttonId,
    i0.Value<String>? orderKey,
    i0.Value<bool>? isVisible,
    i0.Value<String?>? fallbackId,
    i0.Value<int>? rowid,
  }) {
    return i1.ToolbarButtonConfigsCompanion(
      buttonId: buttonId ?? this.buttonId,
      orderKey: orderKey ?? this.orderKey,
      isVisible: isVisible ?? this.isVisible,
      fallbackId: fallbackId ?? this.fallbackId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (buttonId.present) {
      map['button_id'] = i0.Variable<String>(buttonId.value);
    }
    if (orderKey.present) {
      map['order_key'] = i0.Variable<String>(orderKey.value);
    }
    if (isVisible.present) {
      map['is_visible'] = i0.Variable<bool>(isVisible.value);
    }
    if (fallbackId.present) {
      map['fallback_id'] = i0.Variable<String>(fallbackId.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ToolbarButtonConfigsCompanion(')
          ..write('buttonId: $buttonId, ')
          ..write('orderKey: $orderKey, ')
          ..write('isVisible: $isVisible, ')
          ..write('fallbackId: $fallbackId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

i0.Index get idxToolbarOrderKey => i0.Index(
  'idx_toolbar_order_key',
  'CREATE INDEX idx_toolbar_order_key ON toolbar_button_configs (order_key)',
);

class QuickSwitcherButtonConfigs extends i0.Table
    with
        i0.TableInfo<QuickSwitcherButtonConfigs, i1.QuickSwitcherButtonConfig> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  QuickSwitcherButtonConfigs(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> buttonId = i0.GeneratedColumn<String>(
    'button_id',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  late final i0.GeneratedColumn<String> orderKey = i0.GeneratedColumn<String>(
    'order_key',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumn<bool> isVisible = i0.GeneratedColumn<bool>(
    'is_visible',
    aliasedName,
    false,
    type: i0.DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT FALSE',
    defaultValue: const i0.CustomExpression('FALSE'),
  );
  late final i0.GeneratedColumn<String> fallbackId = i0.GeneratedColumn<String>(
    'fallback_id',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'REFERENCES quick_switcher_button_configs(button_id)ON DELETE SET NULL',
  );
  @override
  List<i0.GeneratedColumn> get $columns => [
    buttonId,
    orderKey,
    isVisible,
    fallbackId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quick_switcher_button_configs';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {buttonId};
  @override
  i1.QuickSwitcherButtonConfig map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.QuickSwitcherButtonConfig(
      buttonId: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}button_id'],
      )!,
      orderKey: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}order_key'],
      )!,
      isVisible: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.bool,
        data['${effectivePrefix}is_visible'],
      )!,
      fallbackId: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}fallback_id'],
      ),
    );
  }

  @override
  QuickSwitcherButtonConfigs createAlias(String alias) {
    return QuickSwitcherButtonConfigs(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class QuickSwitcherButtonConfig extends i0.DataClass
    implements i0.Insertable<i1.QuickSwitcherButtonConfig> {
  final String buttonId;
  final String orderKey;
  final bool isVisible;
  final String? fallbackId;
  const QuickSwitcherButtonConfig({
    required this.buttonId,
    required this.orderKey,
    required this.isVisible,
    this.fallbackId,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['button_id'] = i0.Variable<String>(buttonId);
    map['order_key'] = i0.Variable<String>(orderKey);
    map['is_visible'] = i0.Variable<bool>(isVisible);
    if (!nullToAbsent || fallbackId != null) {
      map['fallback_id'] = i0.Variable<String>(fallbackId);
    }
    return map;
  }

  factory QuickSwitcherButtonConfig.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return QuickSwitcherButtonConfig(
      buttonId: serializer.fromJson<String>(json['button_id']),
      orderKey: serializer.fromJson<String>(json['order_key']),
      isVisible: serializer.fromJson<bool>(json['is_visible']),
      fallbackId: serializer.fromJson<String?>(json['fallback_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'button_id': serializer.toJson<String>(buttonId),
      'order_key': serializer.toJson<String>(orderKey),
      'is_visible': serializer.toJson<bool>(isVisible),
      'fallback_id': serializer.toJson<String?>(fallbackId),
    };
  }

  i1.QuickSwitcherButtonConfig copyWith({
    String? buttonId,
    String? orderKey,
    bool? isVisible,
    i0.Value<String?> fallbackId = const i0.Value.absent(),
  }) => i1.QuickSwitcherButtonConfig(
    buttonId: buttonId ?? this.buttonId,
    orderKey: orderKey ?? this.orderKey,
    isVisible: isVisible ?? this.isVisible,
    fallbackId: fallbackId.present ? fallbackId.value : this.fallbackId,
  );
  QuickSwitcherButtonConfig copyWithCompanion(
    i1.QuickSwitcherButtonConfigsCompanion data,
  ) {
    return QuickSwitcherButtonConfig(
      buttonId: data.buttonId.present ? data.buttonId.value : this.buttonId,
      orderKey: data.orderKey.present ? data.orderKey.value : this.orderKey,
      isVisible: data.isVisible.present ? data.isVisible.value : this.isVisible,
      fallbackId: data.fallbackId.present
          ? data.fallbackId.value
          : this.fallbackId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuickSwitcherButtonConfig(')
          ..write('buttonId: $buttonId, ')
          ..write('orderKey: $orderKey, ')
          ..write('isVisible: $isVisible, ')
          ..write('fallbackId: $fallbackId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(buttonId, orderKey, isVisible, fallbackId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.QuickSwitcherButtonConfig &&
          other.buttonId == this.buttonId &&
          other.orderKey == this.orderKey &&
          other.isVisible == this.isVisible &&
          other.fallbackId == this.fallbackId);
}

class QuickSwitcherButtonConfigsCompanion
    extends i0.UpdateCompanion<i1.QuickSwitcherButtonConfig> {
  final i0.Value<String> buttonId;
  final i0.Value<String> orderKey;
  final i0.Value<bool> isVisible;
  final i0.Value<String?> fallbackId;
  final i0.Value<int> rowid;
  const QuickSwitcherButtonConfigsCompanion({
    this.buttonId = const i0.Value.absent(),
    this.orderKey = const i0.Value.absent(),
    this.isVisible = const i0.Value.absent(),
    this.fallbackId = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  QuickSwitcherButtonConfigsCompanion.insert({
    required String buttonId,
    required String orderKey,
    this.isVisible = const i0.Value.absent(),
    this.fallbackId = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  }) : buttonId = i0.Value(buttonId),
       orderKey = i0.Value(orderKey);
  static i0.Insertable<i1.QuickSwitcherButtonConfig> custom({
    i0.Expression<String>? buttonId,
    i0.Expression<String>? orderKey,
    i0.Expression<bool>? isVisible,
    i0.Expression<String>? fallbackId,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (buttonId != null) 'button_id': buttonId,
      if (orderKey != null) 'order_key': orderKey,
      if (isVisible != null) 'is_visible': isVisible,
      if (fallbackId != null) 'fallback_id': fallbackId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i1.QuickSwitcherButtonConfigsCompanion copyWith({
    i0.Value<String>? buttonId,
    i0.Value<String>? orderKey,
    i0.Value<bool>? isVisible,
    i0.Value<String?>? fallbackId,
    i0.Value<int>? rowid,
  }) {
    return i1.QuickSwitcherButtonConfigsCompanion(
      buttonId: buttonId ?? this.buttonId,
      orderKey: orderKey ?? this.orderKey,
      isVisible: isVisible ?? this.isVisible,
      fallbackId: fallbackId ?? this.fallbackId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (buttonId.present) {
      map['button_id'] = i0.Variable<String>(buttonId.value);
    }
    if (orderKey.present) {
      map['order_key'] = i0.Variable<String>(orderKey.value);
    }
    if (isVisible.present) {
      map['is_visible'] = i0.Variable<bool>(isVisible.value);
    }
    if (fallbackId.present) {
      map['fallback_id'] = i0.Variable<String>(fallbackId.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuickSwitcherButtonConfigsCompanion(')
          ..write('buttonId: $buttonId, ')
          ..write('orderKey: $orderKey, ')
          ..write('isVisible: $isVisible, ')
          ..write('fallbackId: $fallbackId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

i0.Index get idxQuickSwitcherOrderKey => i0.Index(
  'idx_quick_switcher_order_key',
  'CREATE INDEX idx_quick_switcher_order_key ON quick_switcher_button_configs (order_key)',
);

class SearchTokens extends i0.Table
    with i0.TableInfo<SearchTokens, i1.SearchToken> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  SearchTokens(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<int> id = i0.GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY AUTOINCREMENT',
  );
  late final i0.GeneratedColumn<i3.Uint8List> token =
      i0.GeneratedColumn<i3.Uint8List>(
        'token',
        aliasedName,
        false,
        type: i0.DriftSqlType.blob,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  late final i0.GeneratedColumn<DateTime> insertedAt =
      i0.GeneratedColumn<DateTime>(
        'inserted_at',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  late final i0.GeneratedColumn<String> issuerKeyVersion =
      i0.GeneratedColumn<String>(
        'issuer_key_version',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  late final i0.GeneratedColumn<DateTime> reservedAt =
      i0.GeneratedColumn<DateTime>(
        'reserved_at',
        aliasedName,
        true,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  @override
  List<i0.GeneratedColumn> get $columns => [
    id,
    token,
    insertedAt,
    issuerKeyVersion,
    reservedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_tokens';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {id};
  @override
  i1.SearchToken map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.SearchToken(
      id: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      token: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.blob,
        data['${effectivePrefix}token'],
      )!,
      insertedAt: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}inserted_at'],
      )!,
      issuerKeyVersion: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}issuer_key_version'],
      )!,
      reservedAt: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}reserved_at'],
      ),
    );
  }

  @override
  SearchTokens createAlias(String alias) {
    return SearchTokens(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class SearchToken extends i0.DataClass
    implements i0.Insertable<i1.SearchToken> {
  final int id;
  final i3.Uint8List token;
  final DateTime insertedAt;
  final String issuerKeyVersion;
  final DateTime? reservedAt;
  const SearchToken({
    required this.id,
    required this.token,
    required this.insertedAt,
    required this.issuerKeyVersion,
    this.reservedAt,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['id'] = i0.Variable<int>(id);
    map['token'] = i0.Variable<i3.Uint8List>(token);
    map['inserted_at'] = i0.Variable<DateTime>(insertedAt);
    map['issuer_key_version'] = i0.Variable<String>(issuerKeyVersion);
    if (!nullToAbsent || reservedAt != null) {
      map['reserved_at'] = i0.Variable<DateTime>(reservedAt);
    }
    return map;
  }

  factory SearchToken.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return SearchToken(
      id: serializer.fromJson<int>(json['id']),
      token: serializer.fromJson<i3.Uint8List>(json['token']),
      insertedAt: serializer.fromJson<DateTime>(json['inserted_at']),
      issuerKeyVersion: serializer.fromJson<String>(json['issuer_key_version']),
      reservedAt: serializer.fromJson<DateTime?>(json['reserved_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'token': serializer.toJson<i3.Uint8List>(token),
      'inserted_at': serializer.toJson<DateTime>(insertedAt),
      'issuer_key_version': serializer.toJson<String>(issuerKeyVersion),
      'reserved_at': serializer.toJson<DateTime?>(reservedAt),
    };
  }

  i1.SearchToken copyWith({
    int? id,
    i3.Uint8List? token,
    DateTime? insertedAt,
    String? issuerKeyVersion,
    i0.Value<DateTime?> reservedAt = const i0.Value.absent(),
  }) => i1.SearchToken(
    id: id ?? this.id,
    token: token ?? this.token,
    insertedAt: insertedAt ?? this.insertedAt,
    issuerKeyVersion: issuerKeyVersion ?? this.issuerKeyVersion,
    reservedAt: reservedAt.present ? reservedAt.value : this.reservedAt,
  );
  SearchToken copyWithCompanion(i1.SearchTokensCompanion data) {
    return SearchToken(
      id: data.id.present ? data.id.value : this.id,
      token: data.token.present ? data.token.value : this.token,
      insertedAt: data.insertedAt.present
          ? data.insertedAt.value
          : this.insertedAt,
      issuerKeyVersion: data.issuerKeyVersion.present
          ? data.issuerKeyVersion.value
          : this.issuerKeyVersion,
      reservedAt: data.reservedAt.present
          ? data.reservedAt.value
          : this.reservedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchToken(')
          ..write('id: $id, ')
          ..write('token: $token, ')
          ..write('insertedAt: $insertedAt, ')
          ..write('issuerKeyVersion: $issuerKeyVersion, ')
          ..write('reservedAt: $reservedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    i0.$driftBlobEquality.hash(token),
    insertedAt,
    issuerKeyVersion,
    reservedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.SearchToken &&
          other.id == this.id &&
          i0.$driftBlobEquality.equals(other.token, this.token) &&
          other.insertedAt == this.insertedAt &&
          other.issuerKeyVersion == this.issuerKeyVersion &&
          other.reservedAt == this.reservedAt);
}

class SearchTokensCompanion extends i0.UpdateCompanion<i1.SearchToken> {
  final i0.Value<int> id;
  final i0.Value<i3.Uint8List> token;
  final i0.Value<DateTime> insertedAt;
  final i0.Value<String> issuerKeyVersion;
  final i0.Value<DateTime?> reservedAt;
  const SearchTokensCompanion({
    this.id = const i0.Value.absent(),
    this.token = const i0.Value.absent(),
    this.insertedAt = const i0.Value.absent(),
    this.issuerKeyVersion = const i0.Value.absent(),
    this.reservedAt = const i0.Value.absent(),
  });
  SearchTokensCompanion.insert({
    this.id = const i0.Value.absent(),
    required i3.Uint8List token,
    required DateTime insertedAt,
    required String issuerKeyVersion,
    this.reservedAt = const i0.Value.absent(),
  }) : token = i0.Value(token),
       insertedAt = i0.Value(insertedAt),
       issuerKeyVersion = i0.Value(issuerKeyVersion);
  static i0.Insertable<i1.SearchToken> custom({
    i0.Expression<int>? id,
    i0.Expression<i3.Uint8List>? token,
    i0.Expression<DateTime>? insertedAt,
    i0.Expression<String>? issuerKeyVersion,
    i0.Expression<DateTime>? reservedAt,
  }) {
    return i0.RawValuesInsertable({
      if (id != null) 'id': id,
      if (token != null) 'token': token,
      if (insertedAt != null) 'inserted_at': insertedAt,
      if (issuerKeyVersion != null) 'issuer_key_version': issuerKeyVersion,
      if (reservedAt != null) 'reserved_at': reservedAt,
    });
  }

  i1.SearchTokensCompanion copyWith({
    i0.Value<int>? id,
    i0.Value<i3.Uint8List>? token,
    i0.Value<DateTime>? insertedAt,
    i0.Value<String>? issuerKeyVersion,
    i0.Value<DateTime?>? reservedAt,
  }) {
    return i1.SearchTokensCompanion(
      id: id ?? this.id,
      token: token ?? this.token,
      insertedAt: insertedAt ?? this.insertedAt,
      issuerKeyVersion: issuerKeyVersion ?? this.issuerKeyVersion,
      reservedAt: reservedAt ?? this.reservedAt,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (id.present) {
      map['id'] = i0.Variable<int>(id.value);
    }
    if (token.present) {
      map['token'] = i0.Variable<i3.Uint8List>(token.value);
    }
    if (insertedAt.present) {
      map['inserted_at'] = i0.Variable<DateTime>(insertedAt.value);
    }
    if (issuerKeyVersion.present) {
      map['issuer_key_version'] = i0.Variable<String>(issuerKeyVersion.value);
    }
    if (reservedAt.present) {
      map['reserved_at'] = i0.Variable<DateTime>(reservedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchTokensCompanion(')
          ..write('id: $id, ')
          ..write('token: $token, ')
          ..write('insertedAt: $insertedAt, ')
          ..write('issuerKeyVersion: $issuerKeyVersion, ')
          ..write('reservedAt: $reservedAt')
          ..write(')'))
        .toString();
  }
}

i0.Index get idxSearchTokensInsertedAt => i0.Index(
  'idx_search_tokens_inserted_at',
  'CREATE INDEX idx_search_tokens_inserted_at ON search_tokens (inserted_at)',
);
i0.Index get idxSearchTokensReservedAt => i0.Index(
  'idx_search_tokens_reserved_at',
  'CREATE INDEX idx_search_tokens_reserved_at ON search_tokens (reserved_at)',
);

class DefinitionsDrift extends i4.ModularAccessor {
  DefinitionsDrift(i0.GeneratedDatabase db) : super(db);
  i0.Selectable<String> toolbarLeadingOrderKey({
    required int bucket,
    required bool isVisible,
  }) {
    return customSelect(
      'SELECT lexo_rank_previous(?1, (SELECT order_key FROM toolbar_button_configs WHERE is_visible = ?2 ORDER BY order_key LIMIT 1)) AS _c0',
      variables: [i0.Variable<int>(bucket), i0.Variable<bool>(isVisible)],
      readsFrom: {toolbarButtonConfigs},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> toolbarTrailingOrderKey({
    required int bucket,
    required bool isVisible,
  }) {
    return customSelect(
      'SELECT lexo_rank_next(?1, (SELECT order_key FROM toolbar_button_configs WHERE is_visible = ?2 ORDER BY order_key DESC LIMIT 1)) AS _c0',
      variables: [i0.Variable<int>(bucket), i0.Variable<bool>(isVisible)],
      readsFrom: {toolbarButtonConfigs},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> toolbarOrderKeyAfterButton({
    required bool isVisible,
    required String buttonId,
  }) {
    return customSelect(
      'WITH ordered_table AS (SELECT button_id, order_key, LEAD(order_key)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS next_order_key FROM toolbar_button_configs WHERE is_visible = ?1) SELECT lexo_rank_reorder_after(order_key, next_order_key) AS _c0 FROM ordered_table WHERE button_id = ?2',
      variables: [i0.Variable<bool>(isVisible), i0.Variable<String>(buttonId)],
      readsFrom: {toolbarButtonConfigs},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> toolbarOrderKeyBeforeButton({
    required bool isVisible,
    required String buttonId,
  }) {
    return customSelect(
      'WITH ordered_table AS (SELECT button_id, order_key, LAG(order_key)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS prev_order_key FROM toolbar_button_configs WHERE is_visible = ?1) SELECT lexo_rank_reorder_before(order_key, prev_order_key) AS _c0 FROM ordered_table WHERE button_id = ?2',
      variables: [i0.Variable<bool>(isVisible), i0.Variable<String>(buttonId)],
      readsFrom: {toolbarButtonConfigs},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> quickSwitcherLeadingOrderKey({
    required int bucket,
    required bool isVisible,
  }) {
    return customSelect(
      'SELECT lexo_rank_previous(?1, (SELECT order_key FROM quick_switcher_button_configs WHERE is_visible = ?2 ORDER BY order_key LIMIT 1)) AS _c0',
      variables: [i0.Variable<int>(bucket), i0.Variable<bool>(isVisible)],
      readsFrom: {quickSwitcherButtonConfigs},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> quickSwitcherTrailingOrderKey({
    required int bucket,
    required bool isVisible,
  }) {
    return customSelect(
      'SELECT lexo_rank_next(?1, (SELECT order_key FROM quick_switcher_button_configs WHERE is_visible = ?2 ORDER BY order_key DESC LIMIT 1)) AS _c0',
      variables: [i0.Variable<int>(bucket), i0.Variable<bool>(isVisible)],
      readsFrom: {quickSwitcherButtonConfigs},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> quickSwitcherOrderKeyAfterButton({
    required bool isVisible,
    required String buttonId,
  }) {
    return customSelect(
      'WITH ordered_table AS (SELECT button_id, order_key, LEAD(order_key)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS next_order_key FROM quick_switcher_button_configs WHERE is_visible = ?1) SELECT lexo_rank_reorder_after(order_key, next_order_key) AS _c0 FROM ordered_table WHERE button_id = ?2',
      variables: [i0.Variable<bool>(isVisible), i0.Variable<String>(buttonId)],
      readsFrom: {quickSwitcherButtonConfigs},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> quickSwitcherOrderKeyBeforeButton({
    required bool isVisible,
    required String buttonId,
  }) {
    return customSelect(
      'WITH ordered_table AS (SELECT button_id, order_key, LAG(order_key)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS prev_order_key FROM quick_switcher_button_configs WHERE is_visible = ?1) SELECT lexo_rank_reorder_before(order_key, prev_order_key) AS _c0 FROM ordered_table WHERE button_id = ?2',
      variables: [i0.Variable<bool>(isVisible), i0.Variable<String>(buttonId)],
      readsFrom: {quickSwitcherButtonConfigs},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  Future<int> evictCacheEntries({required int limit}) {
    return customUpdate(
      'DELETE FROM icon_cache WHERE "rowid" IN (SELECT "rowid" FROM icon_cache ORDER BY fetch_date DESC LIMIT -1 OFFSET ?1)',
      variables: [i0.Variable<int>(limit)],
      updates: {iconCache},
      updateKind: i0.UpdateKind.delete,
    );
  }

  i1.ToolbarButtonConfigs get toolbarButtonConfigs => i4.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i1.ToolbarButtonConfigs>('toolbar_button_configs');
  i1.QuickSwitcherButtonConfigs get quickSwitcherButtonConfigs =>
      i4.ReadDatabaseContainer(
        attachedDatabase,
      ).resultSet<i1.QuickSwitcherButtonConfigs>(
        'quick_switcher_button_configs',
      );
  i1.IconCache get iconCache => i4.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i1.IconCache>('icon_cache');
}
