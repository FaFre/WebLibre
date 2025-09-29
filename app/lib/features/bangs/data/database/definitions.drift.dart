// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/bangs/data/models/bang.dart' as i1;
import 'package:weblibre/features/bangs/data/models/bang_group.dart' as i2;
import 'package:weblibre/features/bangs/data/database/definitions.drift.dart'
    as i3;
import 'package:weblibre/features/bangs/data/database/drift/converters/bang_format.dart'
    as i4;
import 'package:weblibre/features/bangs/data/models/bang_data.dart' as i5;
import 'package:drift/internal/modular.dart' as i6;
import 'package:weblibre/features/bangs/data/models/search_history_entry.dart'
    as i7;

typedef $BangTableCreateCompanionBuilder =
    i3.BangCompanion Function({
      required String trigger,
      required i2.BangGroup group,
      required String websiteName,
      required String domain,
      required String urlTemplate,
      i0.Value<String?> category,
      i0.Value<String?> subCategory,
      i0.Value<Set<i1.BangFormat>?> format,
      i0.Value<int> rowid,
    });
typedef $BangTableUpdateCompanionBuilder =
    i3.BangCompanion Function({
      i0.Value<String> trigger,
      i0.Value<i2.BangGroup> group,
      i0.Value<String> websiteName,
      i0.Value<String> domain,
      i0.Value<String> urlTemplate,
      i0.Value<String?> category,
      i0.Value<String?> subCategory,
      i0.Value<Set<i1.BangFormat>?> format,
      i0.Value<int> rowid,
    });

class $BangTableFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.BangTable> {
  $BangTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<i2.BangGroup, i2.BangGroup, int>
  get group => $composableBuilder(
    column: $table.group,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.ColumnFilters<String> get websiteName => $composableBuilder(
    column: $table.websiteName,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get urlTemplate => $composableBuilder(
    column: $table.urlTemplate,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get subCategory => $composableBuilder(
    column: $table.subCategory,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<
    Set<i1.BangFormat>?,
    Set<i1.BangFormat>,
    String
  >
  get format => $composableBuilder(
    column: $table.format,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );
}

class $BangTableOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.BangTable> {
  $BangTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<int> get group => $composableBuilder(
    column: $table.group,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get websiteName => $composableBuilder(
    column: $table.websiteName,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get urlTemplate => $composableBuilder(
    column: $table.urlTemplate,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get subCategory => $composableBuilder(
    column: $table.subCategory,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $BangTableAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.BangTable> {
  $BangTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<i2.BangGroup, int> get group =>
      $composableBuilder(column: $table.group, builder: (column) => column);

  i0.GeneratedColumn<String> get websiteName => $composableBuilder(
    column: $table.websiteName,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  i0.GeneratedColumn<String> get urlTemplate => $composableBuilder(
    column: $table.urlTemplate,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  i0.GeneratedColumn<String> get subCategory => $composableBuilder(
    column: $table.subCategory,
    builder: (column) => column,
  );

  i0.GeneratedColumnWithTypeConverter<Set<i1.BangFormat>?, String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);
}

class $BangTableTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i3.BangTable,
          i1.Bang,
          i3.$BangTableFilterComposer,
          i3.$BangTableOrderingComposer,
          i3.$BangTableAnnotationComposer,
          $BangTableCreateCompanionBuilder,
          $BangTableUpdateCompanionBuilder,
          (
            i1.Bang,
            i0.BaseReferences<i0.GeneratedDatabase, i3.BangTable, i1.Bang>,
          ),
          i1.Bang,
          i0.PrefetchHooks Function()
        > {
  $BangTableTableManager(i0.GeneratedDatabase db, i3.BangTable table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i3.$BangTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i3.$BangTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i3.$BangTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> trigger = const i0.Value.absent(),
                i0.Value<i2.BangGroup> group = const i0.Value.absent(),
                i0.Value<String> websiteName = const i0.Value.absent(),
                i0.Value<String> domain = const i0.Value.absent(),
                i0.Value<String> urlTemplate = const i0.Value.absent(),
                i0.Value<String?> category = const i0.Value.absent(),
                i0.Value<String?> subCategory = const i0.Value.absent(),
                i0.Value<Set<i1.BangFormat>?> format = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.BangCompanion(
                trigger: trigger,
                group: group,
                websiteName: websiteName,
                domain: domain,
                urlTemplate: urlTemplate,
                category: category,
                subCategory: subCategory,
                format: format,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trigger,
                required i2.BangGroup group,
                required String websiteName,
                required String domain,
                required String urlTemplate,
                i0.Value<String?> category = const i0.Value.absent(),
                i0.Value<String?> subCategory = const i0.Value.absent(),
                i0.Value<Set<i1.BangFormat>?> format = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.BangCompanion.insert(
                trigger: trigger,
                group: group,
                websiteName: websiteName,
                domain: domain,
                urlTemplate: urlTemplate,
                category: category,
                subCategory: subCategory,
                format: format,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $BangTableProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i3.BangTable,
      i1.Bang,
      i3.$BangTableFilterComposer,
      i3.$BangTableOrderingComposer,
      i3.$BangTableAnnotationComposer,
      $BangTableCreateCompanionBuilder,
      $BangTableUpdateCompanionBuilder,
      (i1.Bang, i0.BaseReferences<i0.GeneratedDatabase, i3.BangTable, i1.Bang>),
      i1.Bang,
      i0.PrefetchHooks Function()
    >;
typedef $BangSyncCreateCompanionBuilder =
    i3.BangSyncCompanion Function({
      i0.Value<i2.BangGroup> group,
      required DateTime lastSync,
    });
typedef $BangSyncUpdateCompanionBuilder =
    i3.BangSyncCompanion Function({
      i0.Value<i2.BangGroup> group,
      i0.Value<DateTime> lastSync,
    });

class $BangSyncFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.BangSync> {
  $BangSyncFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnWithTypeConverterFilters<i2.BangGroup, i2.BangGroup, int>
  get group => $composableBuilder(
    column: $table.group,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.ColumnFilters<DateTime> get lastSync => $composableBuilder(
    column: $table.lastSync,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $BangSyncOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.BangSync> {
  $BangSyncOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<int> get group => $composableBuilder(
    column: $table.group,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get lastSync => $composableBuilder(
    column: $table.lastSync,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $BangSyncAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.BangSync> {
  $BangSyncAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumnWithTypeConverter<i2.BangGroup, int> get group =>
      $composableBuilder(column: $table.group, builder: (column) => column);

  i0.GeneratedColumn<DateTime> get lastSync =>
      $composableBuilder(column: $table.lastSync, builder: (column) => column);
}

class $BangSyncTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i3.BangSync,
          i3.BangSyncData,
          i3.$BangSyncFilterComposer,
          i3.$BangSyncOrderingComposer,
          i3.$BangSyncAnnotationComposer,
          $BangSyncCreateCompanionBuilder,
          $BangSyncUpdateCompanionBuilder,
          (
            i3.BangSyncData,
            i0.BaseReferences<
              i0.GeneratedDatabase,
              i3.BangSync,
              i3.BangSyncData
            >,
          ),
          i3.BangSyncData,
          i0.PrefetchHooks Function()
        > {
  $BangSyncTableManager(i0.GeneratedDatabase db, i3.BangSync table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i3.$BangSyncFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i3.$BangSyncOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i3.$BangSyncAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<i2.BangGroup> group = const i0.Value.absent(),
                i0.Value<DateTime> lastSync = const i0.Value.absent(),
              }) => i3.BangSyncCompanion(group: group, lastSync: lastSync),
          createCompanionCallback:
              ({
                i0.Value<i2.BangGroup> group = const i0.Value.absent(),
                required DateTime lastSync,
              }) =>
                  i3.BangSyncCompanion.insert(group: group, lastSync: lastSync),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $BangSyncProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i3.BangSync,
      i3.BangSyncData,
      i3.$BangSyncFilterComposer,
      i3.$BangSyncOrderingComposer,
      i3.$BangSyncAnnotationComposer,
      $BangSyncCreateCompanionBuilder,
      $BangSyncUpdateCompanionBuilder,
      (
        i3.BangSyncData,
        i0.BaseReferences<i0.GeneratedDatabase, i3.BangSync, i3.BangSyncData>,
      ),
      i3.BangSyncData,
      i0.PrefetchHooks Function()
    >;
typedef $BangFrequencyCreateCompanionBuilder =
    i3.BangFrequencyCompanion Function({
      required String trigger,
      required i2.BangGroup group,
      required int frequency,
      required DateTime lastUsed,
      i0.Value<int> rowid,
    });
typedef $BangFrequencyUpdateCompanionBuilder =
    i3.BangFrequencyCompanion Function({
      i0.Value<String> trigger,
      i0.Value<i2.BangGroup> group,
      i0.Value<int> frequency,
      i0.Value<DateTime> lastUsed,
      i0.Value<int> rowid,
    });

class $BangFrequencyFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.BangFrequency> {
  $BangFrequencyFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<i2.BangGroup, i2.BangGroup, int>
  get group => $composableBuilder(
    column: $table.group,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.ColumnFilters<int> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get lastUsed => $composableBuilder(
    column: $table.lastUsed,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $BangFrequencyOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.BangFrequency> {
  $BangFrequencyOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<int> get group => $composableBuilder(
    column: $table.group,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<int> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get lastUsed => $composableBuilder(
    column: $table.lastUsed,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $BangFrequencyAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.BangFrequency> {
  $BangFrequencyAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<i2.BangGroup, int> get group =>
      $composableBuilder(column: $table.group, builder: (column) => column);

  i0.GeneratedColumn<int> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  i0.GeneratedColumn<DateTime> get lastUsed =>
      $composableBuilder(column: $table.lastUsed, builder: (column) => column);
}

class $BangFrequencyTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i3.BangFrequency,
          i3.BangFrequencyData,
          i3.$BangFrequencyFilterComposer,
          i3.$BangFrequencyOrderingComposer,
          i3.$BangFrequencyAnnotationComposer,
          $BangFrequencyCreateCompanionBuilder,
          $BangFrequencyUpdateCompanionBuilder,
          (
            i3.BangFrequencyData,
            i0.BaseReferences<
              i0.GeneratedDatabase,
              i3.BangFrequency,
              i3.BangFrequencyData
            >,
          ),
          i3.BangFrequencyData,
          i0.PrefetchHooks Function()
        > {
  $BangFrequencyTableManager(i0.GeneratedDatabase db, i3.BangFrequency table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i3.$BangFrequencyFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i3.$BangFrequencyOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i3.$BangFrequencyAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> trigger = const i0.Value.absent(),
                i0.Value<i2.BangGroup> group = const i0.Value.absent(),
                i0.Value<int> frequency = const i0.Value.absent(),
                i0.Value<DateTime> lastUsed = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.BangFrequencyCompanion(
                trigger: trigger,
                group: group,
                frequency: frequency,
                lastUsed: lastUsed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trigger,
                required i2.BangGroup group,
                required int frequency,
                required DateTime lastUsed,
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.BangFrequencyCompanion.insert(
                trigger: trigger,
                group: group,
                frequency: frequency,
                lastUsed: lastUsed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $BangFrequencyProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i3.BangFrequency,
      i3.BangFrequencyData,
      i3.$BangFrequencyFilterComposer,
      i3.$BangFrequencyOrderingComposer,
      i3.$BangFrequencyAnnotationComposer,
      $BangFrequencyCreateCompanionBuilder,
      $BangFrequencyUpdateCompanionBuilder,
      (
        i3.BangFrequencyData,
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i3.BangFrequency,
          i3.BangFrequencyData
        >,
      ),
      i3.BangFrequencyData,
      i0.PrefetchHooks Function()
    >;
typedef $BangHistoryCreateCompanionBuilder =
    i3.BangHistoryCompanion Function({
      required String searchQuery,
      required String trigger,
      required i2.BangGroup group,
      required DateTime searchDate,
      i0.Value<int> rowid,
    });
typedef $BangHistoryUpdateCompanionBuilder =
    i3.BangHistoryCompanion Function({
      i0.Value<String> searchQuery,
      i0.Value<String> trigger,
      i0.Value<i2.BangGroup> group,
      i0.Value<DateTime> searchDate,
      i0.Value<int> rowid,
    });

class $BangHistoryFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.BangHistory> {
  $BangHistoryFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get searchQuery => $composableBuilder(
    column: $table.searchQuery,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<i2.BangGroup, i2.BangGroup, int>
  get group => $composableBuilder(
    column: $table.group,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.ColumnFilters<DateTime> get searchDate => $composableBuilder(
    column: $table.searchDate,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $BangHistoryOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.BangHistory> {
  $BangHistoryOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get searchQuery => $composableBuilder(
    column: $table.searchQuery,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<int> get group => $composableBuilder(
    column: $table.group,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get searchDate => $composableBuilder(
    column: $table.searchDate,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $BangHistoryAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.BangHistory> {
  $BangHistoryAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get searchQuery => $composableBuilder(
    column: $table.searchQuery,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<i2.BangGroup, int> get group =>
      $composableBuilder(column: $table.group, builder: (column) => column);

  i0.GeneratedColumn<DateTime> get searchDate => $composableBuilder(
    column: $table.searchDate,
    builder: (column) => column,
  );
}

class $BangHistoryTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i3.BangHistory,
          i3.BangHistoryData,
          i3.$BangHistoryFilterComposer,
          i3.$BangHistoryOrderingComposer,
          i3.$BangHistoryAnnotationComposer,
          $BangHistoryCreateCompanionBuilder,
          $BangHistoryUpdateCompanionBuilder,
          (
            i3.BangHistoryData,
            i0.BaseReferences<
              i0.GeneratedDatabase,
              i3.BangHistory,
              i3.BangHistoryData
            >,
          ),
          i3.BangHistoryData,
          i0.PrefetchHooks Function()
        > {
  $BangHistoryTableManager(i0.GeneratedDatabase db, i3.BangHistory table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i3.$BangHistoryFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i3.$BangHistoryOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i3.$BangHistoryAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> searchQuery = const i0.Value.absent(),
                i0.Value<String> trigger = const i0.Value.absent(),
                i0.Value<i2.BangGroup> group = const i0.Value.absent(),
                i0.Value<DateTime> searchDate = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.BangHistoryCompanion(
                searchQuery: searchQuery,
                trigger: trigger,
                group: group,
                searchDate: searchDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String searchQuery,
                required String trigger,
                required i2.BangGroup group,
                required DateTime searchDate,
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.BangHistoryCompanion.insert(
                searchQuery: searchQuery,
                trigger: trigger,
                group: group,
                searchDate: searchDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $BangHistoryProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i3.BangHistory,
      i3.BangHistoryData,
      i3.$BangHistoryFilterComposer,
      i3.$BangHistoryOrderingComposer,
      i3.$BangHistoryAnnotationComposer,
      $BangHistoryCreateCompanionBuilder,
      $BangHistoryUpdateCompanionBuilder,
      (
        i3.BangHistoryData,
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i3.BangHistory,
          i3.BangHistoryData
        >,
      ),
      i3.BangHistoryData,
      i0.PrefetchHooks Function()
    >;
typedef $BangFtsCreateCompanionBuilder =
    i3.BangFtsCompanion Function({
      required String trigger,
      required String websiteName,
      i0.Value<int> rowid,
    });
typedef $BangFtsUpdateCompanionBuilder =
    i3.BangFtsCompanion Function({
      i0.Value<String> trigger,
      i0.Value<String> websiteName,
      i0.Value<int> rowid,
    });

class $BangFtsFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.BangFts> {
  $BangFtsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get websiteName => $composableBuilder(
    column: $table.websiteName,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $BangFtsOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.BangFts> {
  $BangFtsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get websiteName => $composableBuilder(
    column: $table.websiteName,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $BangFtsAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.BangFts> {
  $BangFtsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => column);

  i0.GeneratedColumn<String> get websiteName => $composableBuilder(
    column: $table.websiteName,
    builder: (column) => column,
  );
}

class $BangFtsTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i3.BangFts,
          i3.BangFt,
          i3.$BangFtsFilterComposer,
          i3.$BangFtsOrderingComposer,
          i3.$BangFtsAnnotationComposer,
          $BangFtsCreateCompanionBuilder,
          $BangFtsUpdateCompanionBuilder,
          (
            i3.BangFt,
            i0.BaseReferences<i0.GeneratedDatabase, i3.BangFts, i3.BangFt>,
          ),
          i3.BangFt,
          i0.PrefetchHooks Function()
        > {
  $BangFtsTableManager(i0.GeneratedDatabase db, i3.BangFts table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i3.$BangFtsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i3.$BangFtsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i3.$BangFtsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> trigger = const i0.Value.absent(),
                i0.Value<String> websiteName = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.BangFtsCompanion(
                trigger: trigger,
                websiteName: websiteName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trigger,
                required String websiteName,
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.BangFtsCompanion.insert(
                trigger: trigger,
                websiteName: websiteName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $BangFtsProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i3.BangFts,
      i3.BangFt,
      i3.$BangFtsFilterComposer,
      i3.$BangFtsOrderingComposer,
      i3.$BangFtsAnnotationComposer,
      $BangFtsCreateCompanionBuilder,
      $BangFtsUpdateCompanionBuilder,
      (
        i3.BangFt,
        i0.BaseReferences<i0.GeneratedDatabase, i3.BangFts, i3.BangFt>,
      ),
      i3.BangFt,
      i0.PrefetchHooks Function()
    >;

class BangTable extends i0.Table with i0.TableInfo<BangTable, i1.Bang> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  BangTable(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> trigger = i0.GeneratedColumn<String>(
    'trigger',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumnWithTypeConverter<i2.BangGroup, int> group =
      i0.GeneratedColumn<int>(
        'group',
        aliasedName,
        false,
        type: i0.DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<i2.BangGroup>(i3.BangTable.$convertergroup);
  late final i0.GeneratedColumn<String> websiteName =
      i0.GeneratedColumn<String>(
        'website_name',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  late final i0.GeneratedColumn<String> domain = i0.GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumn<String> urlTemplate =
      i0.GeneratedColumn<String>(
        'url_template',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  late final i0.GeneratedColumn<String> category = i0.GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final i0.GeneratedColumn<String> subCategory =
      i0.GeneratedColumn<String>(
        'sub_category',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumnWithTypeConverter<Set<i1.BangFormat>?, String>
  format = i0.GeneratedColumn<String>(
    'format',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  ).withConverter<Set<i1.BangFormat>?>(i3.BangTable.$converterformat);
  @override
  List<i0.GeneratedColumn> get $columns => [
    trigger,
    group,
    websiteName,
    domain,
    urlTemplate,
    category,
    subCategory,
    format,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bang';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {trigger, group};
  @override
  i1.Bang map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.Bang(
      websiteName: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}website_name'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      trigger: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}trigger'],
      )!,
      urlTemplate: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}url_template'],
      )!,
      group: i3.BangTable.$convertergroup.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.int,
          data['${effectivePrefix}group'],
        )!,
      ),
      category: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      subCategory: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}sub_category'],
      ),
      format: i3.BangTable.$converterformat.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}format'],
        ),
      ),
    );
  }

  @override
  BangTable createAlias(String alias) {
    return BangTable(attachedDatabase, alias);
  }

  static i0.JsonTypeConverter2<i2.BangGroup, int, int> $convertergroup =
      const i0.EnumIndexConverter<i2.BangGroup>(i2.BangGroup.values);
  static i0.TypeConverter<Set<i1.BangFormat>?, String?> $converterformat =
      const i4.BangFormatConverter();
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY("trigger", "group")',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class BangCompanion extends i0.UpdateCompanion<i1.Bang> {
  final i0.Value<String> trigger;
  final i0.Value<i2.BangGroup> group;
  final i0.Value<String> websiteName;
  final i0.Value<String> domain;
  final i0.Value<String> urlTemplate;
  final i0.Value<String?> category;
  final i0.Value<String?> subCategory;
  final i0.Value<Set<i1.BangFormat>?> format;
  final i0.Value<int> rowid;
  const BangCompanion({
    this.trigger = const i0.Value.absent(),
    this.group = const i0.Value.absent(),
    this.websiteName = const i0.Value.absent(),
    this.domain = const i0.Value.absent(),
    this.urlTemplate = const i0.Value.absent(),
    this.category = const i0.Value.absent(),
    this.subCategory = const i0.Value.absent(),
    this.format = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  BangCompanion.insert({
    required String trigger,
    required i2.BangGroup group,
    required String websiteName,
    required String domain,
    required String urlTemplate,
    this.category = const i0.Value.absent(),
    this.subCategory = const i0.Value.absent(),
    this.format = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  }) : trigger = i0.Value(trigger),
       group = i0.Value(group),
       websiteName = i0.Value(websiteName),
       domain = i0.Value(domain),
       urlTemplate = i0.Value(urlTemplate);
  static i0.Insertable<i1.Bang> custom({
    i0.Expression<String>? trigger,
    i0.Expression<int>? group,
    i0.Expression<String>? websiteName,
    i0.Expression<String>? domain,
    i0.Expression<String>? urlTemplate,
    i0.Expression<String>? category,
    i0.Expression<String>? subCategory,
    i0.Expression<String>? format,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (trigger != null) 'trigger': trigger,
      if (group != null) 'group': group,
      if (websiteName != null) 'website_name': websiteName,
      if (domain != null) 'domain': domain,
      if (urlTemplate != null) 'url_template': urlTemplate,
      if (category != null) 'category': category,
      if (subCategory != null) 'sub_category': subCategory,
      if (format != null) 'format': format,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i3.BangCompanion copyWith({
    i0.Value<String>? trigger,
    i0.Value<i2.BangGroup>? group,
    i0.Value<String>? websiteName,
    i0.Value<String>? domain,
    i0.Value<String>? urlTemplate,
    i0.Value<String?>? category,
    i0.Value<String?>? subCategory,
    i0.Value<Set<i1.BangFormat>?>? format,
    i0.Value<int>? rowid,
  }) {
    return i3.BangCompanion(
      trigger: trigger ?? this.trigger,
      group: group ?? this.group,
      websiteName: websiteName ?? this.websiteName,
      domain: domain ?? this.domain,
      urlTemplate: urlTemplate ?? this.urlTemplate,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      format: format ?? this.format,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (trigger.present) {
      map['trigger'] = i0.Variable<String>(trigger.value);
    }
    if (group.present) {
      map['group'] = i0.Variable<int>(
        i3.BangTable.$convertergroup.toSql(group.value),
      );
    }
    if (websiteName.present) {
      map['website_name'] = i0.Variable<String>(websiteName.value);
    }
    if (domain.present) {
      map['domain'] = i0.Variable<String>(domain.value);
    }
    if (urlTemplate.present) {
      map['url_template'] = i0.Variable<String>(urlTemplate.value);
    }
    if (category.present) {
      map['category'] = i0.Variable<String>(category.value);
    }
    if (subCategory.present) {
      map['sub_category'] = i0.Variable<String>(subCategory.value);
    }
    if (format.present) {
      map['format'] = i0.Variable<String>(
        i3.BangTable.$converterformat.toSql(format.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BangCompanion(')
          ..write('trigger: $trigger, ')
          ..write('group: $group, ')
          ..write('websiteName: $websiteName, ')
          ..write('domain: $domain, ')
          ..write('urlTemplate: $urlTemplate, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('format: $format, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class BangSync extends i0.Table with i0.TableInfo<BangSync, i3.BangSyncData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  BangSync(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumnWithTypeConverter<i2.BangGroup, int> group =
      i0.GeneratedColumn<int>(
        'group',
        aliasedName,
        false,
        type: i0.DriftSqlType.int,
        requiredDuringInsert: false,
        $customConstraints: 'PRIMARY KEY NOT NULL',
      ).withConverter<i2.BangGroup>(i3.BangSync.$convertergroup);
  late final i0.GeneratedColumn<DateTime> lastSync =
      i0.GeneratedColumn<DateTime>(
        'last_sync',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  @override
  List<i0.GeneratedColumn> get $columns => [group, lastSync];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bang_sync';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {group};
  @override
  i3.BangSyncData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i3.BangSyncData(
      group: i3.BangSync.$convertergroup.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.int,
          data['${effectivePrefix}group'],
        )!,
      ),
      lastSync: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync'],
      )!,
    );
  }

  @override
  BangSync createAlias(String alias) {
    return BangSync(attachedDatabase, alias);
  }

  static i0.JsonTypeConverter2<i2.BangGroup, int, int> $convertergroup =
      const i0.EnumIndexConverter<i2.BangGroup>(i2.BangGroup.values);
  @override
  bool get dontWriteConstraints => true;
}

class BangSyncData extends i0.DataClass
    implements i0.Insertable<i3.BangSyncData> {
  final i2.BangGroup group;
  final DateTime lastSync;
  const BangSyncData({required this.group, required this.lastSync});
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    {
      map['group'] = i0.Variable<int>(i3.BangSync.$convertergroup.toSql(group));
    }
    map['last_sync'] = i0.Variable<DateTime>(lastSync);
    return map;
  }

  factory BangSyncData.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return BangSyncData(
      group: i3.BangSync.$convertergroup.fromJson(
        serializer.fromJson<int>(json['group']),
      ),
      lastSync: serializer.fromJson<DateTime>(json['last_sync']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'group': serializer.toJson<int>(
        i3.BangSync.$convertergroup.toJson(group),
      ),
      'last_sync': serializer.toJson<DateTime>(lastSync),
    };
  }

  i3.BangSyncData copyWith({i2.BangGroup? group, DateTime? lastSync}) =>
      i3.BangSyncData(
        group: group ?? this.group,
        lastSync: lastSync ?? this.lastSync,
      );
  BangSyncData copyWithCompanion(i3.BangSyncCompanion data) {
    return BangSyncData(
      group: data.group.present ? data.group.value : this.group,
      lastSync: data.lastSync.present ? data.lastSync.value : this.lastSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BangSyncData(')
          ..write('group: $group, ')
          ..write('lastSync: $lastSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(group, lastSync);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i3.BangSyncData &&
          other.group == this.group &&
          other.lastSync == this.lastSync);
}

class BangSyncCompanion extends i0.UpdateCompanion<i3.BangSyncData> {
  final i0.Value<i2.BangGroup> group;
  final i0.Value<DateTime> lastSync;
  const BangSyncCompanion({
    this.group = const i0.Value.absent(),
    this.lastSync = const i0.Value.absent(),
  });
  BangSyncCompanion.insert({
    this.group = const i0.Value.absent(),
    required DateTime lastSync,
  }) : lastSync = i0.Value(lastSync);
  static i0.Insertable<i3.BangSyncData> custom({
    i0.Expression<int>? group,
    i0.Expression<DateTime>? lastSync,
  }) {
    return i0.RawValuesInsertable({
      if (group != null) 'group': group,
      if (lastSync != null) 'last_sync': lastSync,
    });
  }

  i3.BangSyncCompanion copyWith({
    i0.Value<i2.BangGroup>? group,
    i0.Value<DateTime>? lastSync,
  }) {
    return i3.BangSyncCompanion(
      group: group ?? this.group,
      lastSync: lastSync ?? this.lastSync,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (group.present) {
      map['group'] = i0.Variable<int>(
        i3.BangSync.$convertergroup.toSql(group.value),
      );
    }
    if (lastSync.present) {
      map['last_sync'] = i0.Variable<DateTime>(lastSync.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BangSyncCompanion(')
          ..write('group: $group, ')
          ..write('lastSync: $lastSync')
          ..write(')'))
        .toString();
  }
}

class BangFrequency extends i0.Table
    with i0.TableInfo<BangFrequency, i3.BangFrequencyData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  BangFrequency(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> trigger = i0.GeneratedColumn<String>(
    'trigger',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumnWithTypeConverter<i2.BangGroup, int> group =
      i0.GeneratedColumn<int>(
        'group',
        aliasedName,
        false,
        type: i0.DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<i2.BangGroup>(i3.BangFrequency.$convertergroup);
  late final i0.GeneratedColumn<int> frequency = i0.GeneratedColumn<int>(
    'frequency',
    aliasedName,
    false,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumn<DateTime> lastUsed =
      i0.GeneratedColumn<DateTime>(
        'last_used',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  @override
  List<i0.GeneratedColumn> get $columns => [
    trigger,
    group,
    frequency,
    lastUsed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bang_frequency';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {trigger, group};
  @override
  i3.BangFrequencyData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i3.BangFrequencyData(
      trigger: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}trigger'],
      )!,
      group: i3.BangFrequency.$convertergroup.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.int,
          data['${effectivePrefix}group'],
        )!,
      ),
      frequency: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}frequency'],
      )!,
      lastUsed: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}last_used'],
      )!,
    );
  }

  @override
  BangFrequency createAlias(String alias) {
    return BangFrequency(attachedDatabase, alias);
  }

  static i0.JsonTypeConverter2<i2.BangGroup, int, int> $convertergroup =
      const i0.EnumIndexConverter<i2.BangGroup>(i2.BangGroup.values);
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY("trigger", "group")',
    'FOREIGN KEY("trigger", "group")REFERENCES bang("trigger", "group")ON DELETE CASCADE',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class BangFrequencyData extends i0.DataClass
    implements i0.Insertable<i3.BangFrequencyData> {
  final String trigger;
  final i2.BangGroup group;
  final int frequency;
  final DateTime lastUsed;
  const BangFrequencyData({
    required this.trigger,
    required this.group,
    required this.frequency,
    required this.lastUsed,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['trigger'] = i0.Variable<String>(trigger);
    {
      map['group'] = i0.Variable<int>(
        i3.BangFrequency.$convertergroup.toSql(group),
      );
    }
    map['frequency'] = i0.Variable<int>(frequency);
    map['last_used'] = i0.Variable<DateTime>(lastUsed);
    return map;
  }

  factory BangFrequencyData.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return BangFrequencyData(
      trigger: serializer.fromJson<String>(json['trigger']),
      group: i3.BangFrequency.$convertergroup.fromJson(
        serializer.fromJson<int>(json['group']),
      ),
      frequency: serializer.fromJson<int>(json['frequency']),
      lastUsed: serializer.fromJson<DateTime>(json['last_used']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trigger': serializer.toJson<String>(trigger),
      'group': serializer.toJson<int>(
        i3.BangFrequency.$convertergroup.toJson(group),
      ),
      'frequency': serializer.toJson<int>(frequency),
      'last_used': serializer.toJson<DateTime>(lastUsed),
    };
  }

  i3.BangFrequencyData copyWith({
    String? trigger,
    i2.BangGroup? group,
    int? frequency,
    DateTime? lastUsed,
  }) => i3.BangFrequencyData(
    trigger: trigger ?? this.trigger,
    group: group ?? this.group,
    frequency: frequency ?? this.frequency,
    lastUsed: lastUsed ?? this.lastUsed,
  );
  BangFrequencyData copyWithCompanion(i3.BangFrequencyCompanion data) {
    return BangFrequencyData(
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      group: data.group.present ? data.group.value : this.group,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      lastUsed: data.lastUsed.present ? data.lastUsed.value : this.lastUsed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BangFrequencyData(')
          ..write('trigger: $trigger, ')
          ..write('group: $group, ')
          ..write('frequency: $frequency, ')
          ..write('lastUsed: $lastUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trigger, group, frequency, lastUsed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i3.BangFrequencyData &&
          other.trigger == this.trigger &&
          other.group == this.group &&
          other.frequency == this.frequency &&
          other.lastUsed == this.lastUsed);
}

class BangFrequencyCompanion extends i0.UpdateCompanion<i3.BangFrequencyData> {
  final i0.Value<String> trigger;
  final i0.Value<i2.BangGroup> group;
  final i0.Value<int> frequency;
  final i0.Value<DateTime> lastUsed;
  final i0.Value<int> rowid;
  const BangFrequencyCompanion({
    this.trigger = const i0.Value.absent(),
    this.group = const i0.Value.absent(),
    this.frequency = const i0.Value.absent(),
    this.lastUsed = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  BangFrequencyCompanion.insert({
    required String trigger,
    required i2.BangGroup group,
    required int frequency,
    required DateTime lastUsed,
    this.rowid = const i0.Value.absent(),
  }) : trigger = i0.Value(trigger),
       group = i0.Value(group),
       frequency = i0.Value(frequency),
       lastUsed = i0.Value(lastUsed);
  static i0.Insertable<i3.BangFrequencyData> custom({
    i0.Expression<String>? trigger,
    i0.Expression<int>? group,
    i0.Expression<int>? frequency,
    i0.Expression<DateTime>? lastUsed,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (trigger != null) 'trigger': trigger,
      if (group != null) 'group': group,
      if (frequency != null) 'frequency': frequency,
      if (lastUsed != null) 'last_used': lastUsed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i3.BangFrequencyCompanion copyWith({
    i0.Value<String>? trigger,
    i0.Value<i2.BangGroup>? group,
    i0.Value<int>? frequency,
    i0.Value<DateTime>? lastUsed,
    i0.Value<int>? rowid,
  }) {
    return i3.BangFrequencyCompanion(
      trigger: trigger ?? this.trigger,
      group: group ?? this.group,
      frequency: frequency ?? this.frequency,
      lastUsed: lastUsed ?? this.lastUsed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (trigger.present) {
      map['trigger'] = i0.Variable<String>(trigger.value);
    }
    if (group.present) {
      map['group'] = i0.Variable<int>(
        i3.BangFrequency.$convertergroup.toSql(group.value),
      );
    }
    if (frequency.present) {
      map['frequency'] = i0.Variable<int>(frequency.value);
    }
    if (lastUsed.present) {
      map['last_used'] = i0.Variable<DateTime>(lastUsed.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BangFrequencyCompanion(')
          ..write('trigger: $trigger, ')
          ..write('group: $group, ')
          ..write('frequency: $frequency, ')
          ..write('lastUsed: $lastUsed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class BangHistory extends i0.Table
    with i0.TableInfo<BangHistory, i3.BangHistoryData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  BangHistory(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> searchQuery =
      i0.GeneratedColumn<String>(
        'search_query',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'UNIQUE NOT NULL',
      );
  late final i0.GeneratedColumn<String> trigger = i0.GeneratedColumn<String>(
    'trigger',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumnWithTypeConverter<i2.BangGroup, int> group =
      i0.GeneratedColumn<int>(
        'group',
        aliasedName,
        false,
        type: i0.DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<i2.BangGroup>(i3.BangHistory.$convertergroup);
  late final i0.GeneratedColumn<DateTime> searchDate =
      i0.GeneratedColumn<DateTime>(
        'search_date',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  @override
  List<i0.GeneratedColumn> get $columns => [
    searchQuery,
    trigger,
    group,
    searchDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bang_history';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => const {};
  @override
  i3.BangHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i3.BangHistoryData(
      searchQuery: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}search_query'],
      )!,
      trigger: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}trigger'],
      )!,
      group: i3.BangHistory.$convertergroup.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.int,
          data['${effectivePrefix}group'],
        )!,
      ),
      searchDate: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}search_date'],
      )!,
    );
  }

  @override
  BangHistory createAlias(String alias) {
    return BangHistory(attachedDatabase, alias);
  }

  static i0.JsonTypeConverter2<i2.BangGroup, int, int> $convertergroup =
      const i0.EnumIndexConverter<i2.BangGroup>(i2.BangGroup.values);
  @override
  List<String> get customConstraints => const [
    'FOREIGN KEY("trigger", "group")REFERENCES bang("trigger", "group")',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class BangHistoryData extends i0.DataClass
    implements i0.Insertable<i3.BangHistoryData> {
  final String searchQuery;
  final String trigger;
  final i2.BangGroup group;
  final DateTime searchDate;
  const BangHistoryData({
    required this.searchQuery,
    required this.trigger,
    required this.group,
    required this.searchDate,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['search_query'] = i0.Variable<String>(searchQuery);
    map['trigger'] = i0.Variable<String>(trigger);
    {
      map['group'] = i0.Variable<int>(
        i3.BangHistory.$convertergroup.toSql(group),
      );
    }
    map['search_date'] = i0.Variable<DateTime>(searchDate);
    return map;
  }

  factory BangHistoryData.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return BangHistoryData(
      searchQuery: serializer.fromJson<String>(json['search_query']),
      trigger: serializer.fromJson<String>(json['trigger']),
      group: i3.BangHistory.$convertergroup.fromJson(
        serializer.fromJson<int>(json['group']),
      ),
      searchDate: serializer.fromJson<DateTime>(json['search_date']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'search_query': serializer.toJson<String>(searchQuery),
      'trigger': serializer.toJson<String>(trigger),
      'group': serializer.toJson<int>(
        i3.BangHistory.$convertergroup.toJson(group),
      ),
      'search_date': serializer.toJson<DateTime>(searchDate),
    };
  }

  i3.BangHistoryData copyWith({
    String? searchQuery,
    String? trigger,
    i2.BangGroup? group,
    DateTime? searchDate,
  }) => i3.BangHistoryData(
    searchQuery: searchQuery ?? this.searchQuery,
    trigger: trigger ?? this.trigger,
    group: group ?? this.group,
    searchDate: searchDate ?? this.searchDate,
  );
  BangHistoryData copyWithCompanion(i3.BangHistoryCompanion data) {
    return BangHistoryData(
      searchQuery: data.searchQuery.present
          ? data.searchQuery.value
          : this.searchQuery,
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      group: data.group.present ? data.group.value : this.group,
      searchDate: data.searchDate.present
          ? data.searchDate.value
          : this.searchDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BangHistoryData(')
          ..write('searchQuery: $searchQuery, ')
          ..write('trigger: $trigger, ')
          ..write('group: $group, ')
          ..write('searchDate: $searchDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(searchQuery, trigger, group, searchDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i3.BangHistoryData &&
          other.searchQuery == this.searchQuery &&
          other.trigger == this.trigger &&
          other.group == this.group &&
          other.searchDate == this.searchDate);
}

class BangHistoryCompanion extends i0.UpdateCompanion<i3.BangHistoryData> {
  final i0.Value<String> searchQuery;
  final i0.Value<String> trigger;
  final i0.Value<i2.BangGroup> group;
  final i0.Value<DateTime> searchDate;
  final i0.Value<int> rowid;
  const BangHistoryCompanion({
    this.searchQuery = const i0.Value.absent(),
    this.trigger = const i0.Value.absent(),
    this.group = const i0.Value.absent(),
    this.searchDate = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  BangHistoryCompanion.insert({
    required String searchQuery,
    required String trigger,
    required i2.BangGroup group,
    required DateTime searchDate,
    this.rowid = const i0.Value.absent(),
  }) : searchQuery = i0.Value(searchQuery),
       trigger = i0.Value(trigger),
       group = i0.Value(group),
       searchDate = i0.Value(searchDate);
  static i0.Insertable<i3.BangHistoryData> custom({
    i0.Expression<String>? searchQuery,
    i0.Expression<String>? trigger,
    i0.Expression<int>? group,
    i0.Expression<DateTime>? searchDate,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (searchQuery != null) 'search_query': searchQuery,
      if (trigger != null) 'trigger': trigger,
      if (group != null) 'group': group,
      if (searchDate != null) 'search_date': searchDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i3.BangHistoryCompanion copyWith({
    i0.Value<String>? searchQuery,
    i0.Value<String>? trigger,
    i0.Value<i2.BangGroup>? group,
    i0.Value<DateTime>? searchDate,
    i0.Value<int>? rowid,
  }) {
    return i3.BangHistoryCompanion(
      searchQuery: searchQuery ?? this.searchQuery,
      trigger: trigger ?? this.trigger,
      group: group ?? this.group,
      searchDate: searchDate ?? this.searchDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (searchQuery.present) {
      map['search_query'] = i0.Variable<String>(searchQuery.value);
    }
    if (trigger.present) {
      map['trigger'] = i0.Variable<String>(trigger.value);
    }
    if (group.present) {
      map['group'] = i0.Variable<int>(
        i3.BangHistory.$convertergroup.toSql(group.value),
      );
    }
    if (searchDate.present) {
      map['search_date'] = i0.Variable<DateTime>(searchDate.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BangHistoryCompanion(')
          ..write('searchQuery: $searchQuery, ')
          ..write('trigger: $trigger, ')
          ..write('group: $group, ')
          ..write('searchDate: $searchDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class BangFts extends i0.Table
    with
        i0.TableInfo<BangFts, i3.BangFt>,
        i0.VirtualTableInfo<BangFts, i3.BangFt> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  BangFts(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> trigger = i0.GeneratedColumn<String>(
    'trigger',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  late final i0.GeneratedColumn<String> websiteName =
      i0.GeneratedColumn<String>(
        'website_name',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: '',
      );
  @override
  List<i0.GeneratedColumn> get $columns => [trigger, websiteName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bang_fts';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => const {};
  @override
  i3.BangFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i3.BangFt(
      trigger: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}trigger'],
      )!,
      websiteName: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}website_name'],
      )!,
    );
  }

  @override
  BangFts createAlias(String alias) {
    return BangFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(trigger, website_name, content=bang, prefix=\'2 3\')';
}

class BangFt extends i0.DataClass implements i0.Insertable<i3.BangFt> {
  final String trigger;
  final String websiteName;
  const BangFt({required this.trigger, required this.websiteName});
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['trigger'] = i0.Variable<String>(trigger);
    map['website_name'] = i0.Variable<String>(websiteName);
    return map;
  }

  factory BangFt.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return BangFt(
      trigger: serializer.fromJson<String>(json['trigger']),
      websiteName: serializer.fromJson<String>(json['website_name']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trigger': serializer.toJson<String>(trigger),
      'website_name': serializer.toJson<String>(websiteName),
    };
  }

  i3.BangFt copyWith({String? trigger, String? websiteName}) => i3.BangFt(
    trigger: trigger ?? this.trigger,
    websiteName: websiteName ?? this.websiteName,
  );
  BangFt copyWithCompanion(i3.BangFtsCompanion data) {
    return BangFt(
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      websiteName: data.websiteName.present
          ? data.websiteName.value
          : this.websiteName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BangFt(')
          ..write('trigger: $trigger, ')
          ..write('websiteName: $websiteName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trigger, websiteName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i3.BangFt &&
          other.trigger == this.trigger &&
          other.websiteName == this.websiteName);
}

class BangFtsCompanion extends i0.UpdateCompanion<i3.BangFt> {
  final i0.Value<String> trigger;
  final i0.Value<String> websiteName;
  final i0.Value<int> rowid;
  const BangFtsCompanion({
    this.trigger = const i0.Value.absent(),
    this.websiteName = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  BangFtsCompanion.insert({
    required String trigger,
    required String websiteName,
    this.rowid = const i0.Value.absent(),
  }) : trigger = i0.Value(trigger),
       websiteName = i0.Value(websiteName);
  static i0.Insertable<i3.BangFt> custom({
    i0.Expression<String>? trigger,
    i0.Expression<String>? websiteName,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (trigger != null) 'trigger': trigger,
      if (websiteName != null) 'website_name': websiteName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i3.BangFtsCompanion copyWith({
    i0.Value<String>? trigger,
    i0.Value<String>? websiteName,
    i0.Value<int>? rowid,
  }) {
    return i3.BangFtsCompanion(
      trigger: trigger ?? this.trigger,
      websiteName: websiteName ?? this.websiteName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (trigger.present) {
      map['trigger'] = i0.Variable<String>(trigger.value);
    }
    if (websiteName.present) {
      map['website_name'] = i0.Variable<String>(websiteName.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BangFtsCompanion(')
          ..write('trigger: $trigger, ')
          ..write('websiteName: $websiteName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class BangDataView extends i0.ViewInfo<i3.BangDataView, i5.BangData>
    implements i0.HasResultSet {
  final String? _alias;
  @override
  final i0.GeneratedDatabase attachedDatabase;
  BangDataView(this.attachedDatabase, [this._alias]);
  @override
  List<i0.GeneratedColumn> get $columns => [
    trigger,
    group,
    websiteName,
    domain,
    urlTemplate,
    category,
    subCategory,
    format,
    frequency,
    lastUsed,
  ];
  @override
  String get aliasedName => _alias ?? entityName;
  @override
  String get entityName => 'bang_data_view';
  @override
  Map<i0.SqlDialect, String> get createViewStatements => {
    i0.SqlDialect.sqlite:
        'CREATE VIEW bang_data_view AS SELECT b.*, bf.frequency, bf.last_used FROM bang AS b LEFT JOIN bang_frequency AS bf ON b."trigger" = bf."trigger" AND b."group" = bf."group"',
  };
  @override
  BangDataView get asDslTable => this;
  @override
  i5.BangData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i5.BangData(
      websiteName: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}website_name'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      trigger: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}trigger'],
      )!,
      urlTemplate: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}url_template'],
      )!,
      category: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      subCategory: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}sub_category'],
      ),
      format: i3.BangTable.$converterformat.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}format'],
        ),
      ),
      frequency: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.int,
        data['${effectivePrefix}frequency'],
      ),
      lastUsed: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}last_used'],
      ),
    );
  }

  late final i0.GeneratedColumn<String> trigger = i0.GeneratedColumn<String>(
    'trigger',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
  );
  late final i0.GeneratedColumnWithTypeConverter<i2.BangGroup, int> group =
      i0.GeneratedColumn<int>(
        'group',
        aliasedName,
        false,
        type: i0.DriftSqlType.int,
      ).withConverter<i2.BangGroup>(i3.BangTable.$convertergroup);
  late final i0.GeneratedColumn<String> websiteName =
      i0.GeneratedColumn<String>(
        'website_name',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
      );
  late final i0.GeneratedColumn<String> domain = i0.GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
  );
  late final i0.GeneratedColumn<String> urlTemplate =
      i0.GeneratedColumn<String>(
        'url_template',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
      );
  late final i0.GeneratedColumn<String> category = i0.GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
  );
  late final i0.GeneratedColumn<String> subCategory =
      i0.GeneratedColumn<String>(
        'sub_category',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
      );
  late final i0.GeneratedColumnWithTypeConverter<Set<i1.BangFormat>?, String>
  format = i0.GeneratedColumn<String>(
    'format',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
  ).withConverter<Set<i1.BangFormat>?>(i3.BangTable.$converterformat);
  late final i0.GeneratedColumn<int> frequency = i0.GeneratedColumn<int>(
    'frequency',
    aliasedName,
    true,
    type: i0.DriftSqlType.int,
  );
  late final i0.GeneratedColumn<DateTime> lastUsed =
      i0.GeneratedColumn<DateTime>(
        'last_used',
        aliasedName,
        true,
        type: i0.DriftSqlType.dateTime,
      );
  @override
  BangDataView createAlias(String alias) {
    return BangDataView(attachedDatabase, alias);
  }

  @override
  i0.Query? get query => null;
  @override
  Set<String> get readTables => const {'bang', 'bang_frequency'};
}

i0.Trigger get bangAfterInsert => i0.Trigger(
  'CREATE TRIGGER bang_after_insert AFTER INSERT ON bang BEGIN INSERT INTO bang_fts ("rowid", "trigger", website_name) VALUES (new."rowid", new."trigger", new.website_name);END',
  'bang_after_insert',
);
i0.Trigger get bangAfterDelete => i0.Trigger(
  'CREATE TRIGGER bang_after_delete AFTER DELETE ON bang BEGIN INSERT INTO bang_fts (bang_fts, "rowid", "trigger", website_name) VALUES (\'delete\', old."rowid", old."trigger", old.website_name);END',
  'bang_after_delete',
);
i0.Trigger get bangAfterUpdate => i0.Trigger(
  'CREATE TRIGGER bang_after_update AFTER UPDATE ON bang BEGIN INSERT INTO bang_fts (bang_fts, "rowid", "trigger", website_name) VALUES (\'delete\', old."rowid", old."trigger", old.website_name);INSERT INTO bang_fts ("rowid", "trigger", website_name) VALUES (new."rowid", new."trigger", new.website_name);END',
  'bang_after_update',
);

class DefinitionsDrift extends i6.ModularAccessor {
  DefinitionsDrift(i0.GeneratedDatabase db) : super(db);
  Future<int> optimizeFtsIndex() {
    return customInsert(
      'INSERT INTO bang_fts (bang_fts) VALUES (\'optimize\')',
      variables: [],
      updates: {bangFts},
    );
  }

  i0.Selectable<i5.BangData> queryBangs({required String query}) {
    return customSelect(
      'WITH weights AS (SELECT 10.0 AS "trigger", 5.0 AS website_name) SELECT b.*, bf.frequency, bf.last_used, bm25(bang_fts, weights."trigger", weights.website_name) AS weighted_rank FROM bang_fts(?1)AS fts INNER JOIN bang AS b ON b."rowid" = fts."rowid" LEFT JOIN bang_frequency AS bf ON b."trigger" = bf."trigger" AND b."group" = bf."group" CROSS JOIN weights ORDER BY weighted_rank ASC, bf.frequency NULLS LAST',
      variables: [i0.Variable<String>(query)],
      readsFrom: {bangFrequency, bangFts, bang},
    ).map(
      (i0.QueryRow row) => i5.BangData(
        websiteName: row.read<String>('website_name'),
        domain: row.read<String>('domain'),
        trigger: row.read<String>('trigger'),
        urlTemplate: row.read<String>('url_template'),
        category: row.readNullable<String>('category'),
        subCategory: row.readNullable<String>('sub_category'),
        format: i3.BangTable.$converterformat.fromSql(
          row.readNullable<String>('format'),
        ),
        frequency: row.readNullable<int>('frequency'),
        lastUsed: row.readNullable<DateTime>('last_used'),
      ),
    );
  }

  i0.Selectable<i5.BangData> queryBangsBasic({required String query}) {
    return customSelect(
      'WITH weights AS (SELECT 10.0 AS "trigger", 5.0 AS website_name) SELECT b.*, bf.frequency, bf.last_used, bm25(bang_fts, weights."trigger", weights.website_name) AS weighted_rank FROM bang_fts AS fts INNER JOIN bang AS b ON b."rowid" = fts."rowid" LEFT JOIN bang_frequency AS bf ON b."trigger" = bf."trigger" AND b."group" = bf."group" CROSS JOIN weights WHERE fts."trigger" LIKE ?1 OR fts.website_name LIKE ?1 ORDER BY weighted_rank ASC, bf.frequency NULLS LAST',
      variables: [i0.Variable<String>(query)],
      readsFrom: {bangFrequency, bangFts, bang},
    ).map(
      (i0.QueryRow row) => i5.BangData(
        websiteName: row.read<String>('website_name'),
        domain: row.read<String>('domain'),
        trigger: row.read<String>('trigger'),
        urlTemplate: row.read<String>('url_template'),
        category: row.readNullable<String>('category'),
        subCategory: row.readNullable<String>('sub_category'),
        format: i3.BangTable.$converterformat.fromSql(
          row.readNullable<String>('format'),
        ),
        frequency: row.readNullable<int>('frequency'),
        lastUsed: row.readNullable<DateTime>('last_used'),
      ),
    );
  }

  i0.Selectable<String> categoriesJson() {
    return customSelect(
      'WITH categories AS (SELECT b.category, json_group_array(DISTINCT b.sub_category ORDER BY b.sub_category)AS sub_categories FROM bang AS b WHERE b.category IS NOT NULL AND b.sub_category IS NOT NULL GROUP BY b.category ORDER BY b.category) SELECT json_group_object(c.category, json(c.sub_categories)) AS categories_json FROM categories AS c',
      variables: [],
      readsFrom: {bang},
    ).map((i0.QueryRow row) => row.read<String>('categories_json'));
  }

  i0.Selectable<i7.SearchHistoryEntry> searchHistoryEntries({
    required int limit,
  }) {
    return customSelect(
      'SELECT * FROM bang_history ORDER BY search_date DESC LIMIT ?1',
      variables: [i0.Variable<int>(limit)],
      readsFrom: {bangHistory},
    ).map(
      (i0.QueryRow row) => i7.SearchHistoryEntry(
        searchQuery: row.read<String>('search_query'),
        trigger: row.read<String>('trigger'),
        searchDate: row.read<DateTime>('search_date'),
      ),
    );
  }

  Future<int> evictHistoryEntries({required int limit}) {
    return customUpdate(
      'DELETE FROM bang_history WHERE "rowid" IN (SELECT "rowid" FROM bang_history ORDER BY search_date DESC LIMIT -1 OFFSET ?1)',
      variables: [i0.Variable<int>(limit)],
      updates: {bangHistory},
      updateKind: i0.UpdateKind.delete,
    );
  }

  i3.BangFts get bangFts => i6.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i3.BangFts>('bang_fts');
  i3.BangTable get bang => i6.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i3.BangTable>('bang');
  i3.BangFrequency get bangFrequency => i6.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i3.BangFrequency>('bang_frequency');
  i3.BangHistory get bangHistory => i6.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i3.BangHistory>('bang_history');
}
