// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    as i1;
import 'dart:typed_data' as i2;
import 'package:drift/internal/modular.dart' as i3;

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
typedef $IconCacheCreateCompanionBuilder =
    i1.IconCacheCompanion Function({
      required String origin,
      required i2.Uint8List iconData,
      required DateTime fetchDate,
      i0.Value<int> rowid,
    });
typedef $IconCacheUpdateCompanionBuilder =
    i1.IconCacheCompanion Function({
      i0.Value<String> origin,
      i0.Value<i2.Uint8List> iconData,
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

  i0.ColumnFilters<i2.Uint8List> get iconData => $composableBuilder(
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

  i0.ColumnOrderings<i2.Uint8List> get iconData => $composableBuilder(
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

  i0.GeneratedColumn<i2.Uint8List> get iconData =>
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
                i0.Value<i2.Uint8List> iconData = const i0.Value.absent(),
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
                required i2.Uint8List iconData,
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
  late final i0.GeneratedColumn<i2.Uint8List> iconData =
      i0.GeneratedColumn<i2.Uint8List>(
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
  final i2.Uint8List iconData;
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
    map['icon_data'] = i0.Variable<i2.Uint8List>(iconData);
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
      iconData: serializer.fromJson<i2.Uint8List>(json['icon_data']),
      fetchDate: serializer.fromJson<DateTime>(json['fetch_date']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'origin': serializer.toJson<String>(origin),
      'icon_data': serializer.toJson<i2.Uint8List>(iconData),
      'fetch_date': serializer.toJson<DateTime>(fetchDate),
    };
  }

  i1.IconCacheData copyWith({
    String? origin,
    i2.Uint8List? iconData,
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
  final i0.Value<i2.Uint8List> iconData;
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
    required i2.Uint8List iconData,
    required DateTime fetchDate,
    this.rowid = const i0.Value.absent(),
  }) : origin = i0.Value(origin),
       iconData = i0.Value(iconData),
       fetchDate = i0.Value(fetchDate);
  static i0.Insertable<i1.IconCacheData> custom({
    i0.Expression<String>? origin,
    i0.Expression<i2.Uint8List>? iconData,
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
    i0.Value<i2.Uint8List>? iconData,
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
      map['icon_data'] = i0.Variable<i2.Uint8List>(iconData.value);
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

class DefinitionsDrift extends i3.ModularAccessor {
  DefinitionsDrift(i0.GeneratedDatabase db) : super(db);
  i0.Selectable<String> toolbarLeadingOrderKey({required int bucket}) {
    return customSelect(
      'SELECT lexo_rank_previous(?1, (SELECT order_key FROM toolbar_button_configs ORDER BY order_key LIMIT 1)) AS _c0',
      variables: [i0.Variable<int>(bucket)],
      readsFrom: {toolbarButtonConfigs},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> toolbarTrailingOrderKey({required int bucket}) {
    return customSelect(
      'SELECT lexo_rank_next(?1, (SELECT order_key FROM toolbar_button_configs ORDER BY order_key DESC LIMIT 1)) AS _c0',
      variables: [i0.Variable<int>(bucket)],
      readsFrom: {toolbarButtonConfigs},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> toolbarOrderKeyAfterButton({required String buttonId}) {
    return customSelect(
      'WITH ordered_table AS (SELECT button_id, order_key, LEAD(order_key)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS next_order_key FROM toolbar_button_configs) SELECT lexo_rank_reorder_after(order_key, next_order_key) AS _c0 FROM ordered_table WHERE button_id = ?1',
      variables: [i0.Variable<String>(buttonId)],
      readsFrom: {toolbarButtonConfigs},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> toolbarOrderKeyBeforeButton({
    required String buttonId,
  }) {
    return customSelect(
      'WITH ordered_table AS (SELECT button_id, order_key, LAG(order_key)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS prev_order_key FROM toolbar_button_configs) SELECT lexo_rank_reorder_before(order_key, prev_order_key) AS _c0 FROM ordered_table WHERE button_id = ?1',
      variables: [i0.Variable<String>(buttonId)],
      readsFrom: {toolbarButtonConfigs},
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

  i1.ToolbarButtonConfigs get toolbarButtonConfigs => i3.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i1.ToolbarButtonConfigs>('toolbar_button_configs');
  i1.IconCache get iconCache => i3.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i1.IconCache>('icon_cache');
}
